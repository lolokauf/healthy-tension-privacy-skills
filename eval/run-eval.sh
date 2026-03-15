#!/usr/bin/env bash
# run-eval.sh — Privacy Skills Evaluation Suite orchestrator
#
# Runs skills against target codebases, judges output against ground truth,
# and aggregates scores into a summary report.
#
# Usage:
#   ./eval/run-eval.sh [OPTIONS]
#
# Options:
#   --skill <name>         Run only this skill (e.g., pbd-code-review, data-mapping)
#   --target <name>        Run against only this target (e.g., documenso, open-saas)
#   --tier <tier>          Target tier: public (default), private, all
#   --holdout-path <path>  Path to private holdout ground truths (required for --tier private|all)
#   --dry-run              Validate setup without invoking Claude
#   --help                 Show this help message

set -euo pipefail

# ─── Constants ────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGETS_YAML="$SCRIPT_DIR/targets.yaml"
JUDGE_PROMPT="$SCRIPT_DIR/judge-prompt.md"
SKILLS_DIR="$REPO_ROOT/skills"
CLONE_DIR="/tmp/eval-targets"
MAX_TURNS=50
MAX_BUDGET="5.00"

# ─── Argument Parsing ─────────────────────────────────────────

FILTER_SKILL=""
FILTER_TARGET=""
TIER="public"
HOLDOUT_PATH=""
DRY_RUN=false

show_help() {
    sed -n '2,/^$/p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skill)    FILTER_SKILL="$2"; shift 2 ;;
        --target)   FILTER_TARGET="$2"; shift 2 ;;
        --tier)     TIER="$2"; shift 2 ;;
        --holdout-path) HOLDOUT_PATH="$2"; shift 2 ;;
        --dry-run)  DRY_RUN=true; shift ;;
        --help|-h)  show_help ;;
        *) echo "Unknown option: $1"; show_help ;;
    esac
done

# Validate tier + holdout-path combination
if [[ "$TIER" == "private" || "$TIER" == "all" ]] && [[ -z "$HOLDOUT_PATH" ]]; then
    echo "ERROR: --holdout-path is required when --tier is 'private' or 'all'"
    exit 1
fi

# ─── Prerequisites Check ──────────────────────────────────────

check_prereqs() {
    local missing=()

    for cmd in claude git yq jq; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "ERROR: Missing required tools: ${missing[*]}"
        echo ""
        echo "Install with:"
        [[ " ${missing[*]} " =~ " claude " ]] && echo "  claude: https://claude.ai/code"
        [[ " ${missing[*]} " =~ " yq " ]]    && echo "  yq:     brew install yq  (mikefarah/yq)"
        [[ " ${missing[*]} " =~ " jq " ]]    && echo "  jq:     brew install jq"
        exit 1
    fi

    echo "Prerequisites OK:"
    echo "  claude $(claude --version 2>&1 | head -1)"
    echo "  git    $(git --version | cut -d' ' -f3)"
    echo "  yq     $(yq --version 2>&1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')"
    echo "  jq     $(jq --version 2>&1)"
    echo ""
}

# ─── Discover Skills ──────────────────────────────────────────

discover_skills() {
    local skills=()
    for skill_dir in "$SKILLS_DIR"/*/; do
        local name
        name="$(basename "$skill_dir")"
        if [[ -f "$skill_dir/SKILL.md" ]]; then
            # Apply filter if set
            if [[ -z "$FILTER_SKILL" || "$FILTER_SKILL" == "$name" ]]; then
                skills+=("$name")
            fi
        fi
    done

    if [[ ${#skills[@]} -eq 0 ]]; then
        echo "ERROR: No skills found"
        [[ -n "$FILTER_SKILL" ]] && echo "  --skill '$FILTER_SKILL' did not match any skill in $SKILLS_DIR/"
        exit 1
    fi

    echo "${skills[@]}"
}

# ─── Discover Targets ─────────────────────────────────────────

# Reads targets.yaml and returns target names matching the current tier + filter.
# Outputs one target name per line.
discover_targets() {
    local count
    count=$(yq '.targets | length' "$TARGETS_YAML")

    for ((i = 0; i < count; i++)); do
        local name tier
        name=$(yq ".targets[$i].name" "$TARGETS_YAML")
        tier=$(yq ".targets[$i].tier" "$TARGETS_YAML")

        # Tier filter
        if [[ "$TIER" == "public" && "$tier" != "public" ]]; then continue; fi
        if [[ "$TIER" == "private" && "$tier" != "private" ]]; then continue; fi
        # "all" includes both tiers

        # Target name filter
        if [[ -n "$FILTER_TARGET" && "$name" != "$FILTER_TARGET" ]]; then continue; fi

        echo "$name"
    done
}

# ─── Target Info Helpers ──────────────────────────────────────

# Get a field from targets.yaml for a given target name.
target_field() {
    local name="$1" field="$2"
    local count
    count=$(yq '.targets | length' "$TARGETS_YAML")

    for ((i = 0; i < count; i++)); do
        local entry_name
        entry_name=$(yq ".targets[$i].name" "$TARGETS_YAML")
        if [[ "$entry_name" == "$name" ]]; then
            yq ".targets[$i].$field" "$TARGETS_YAML"
            return
        fi
    done
}

# ─── Phase 1: Clone Targets ──────────────────────────────────

clone_target() {
    local name="$1"
    local url commit local_path target_dir

    url=$(target_field "$name" "url")
    commit=$(target_field "$name" "commit")
    local_path=$(target_field "$name" "local_path")
    target_dir="$CLONE_DIR/$name"

    # If target has a local_path, use it directly
    if [[ "$local_path" != "null" && -n "$local_path" && -d "$local_path" ]]; then
        echo "  $name: using local path $local_path"
        return 0
    fi

    # Check if already cloned at correct commit
    if [[ -d "$target_dir/.git" ]]; then
        local current_sha
        current_sha=$(git -C "$target_dir" rev-parse HEAD 2>/dev/null || echo "")
        if [[ "$current_sha" == "$commit" ]]; then
            echo "  $name: already at $commit (skipped)"
            return 0
        fi
        echo "  $name: wrong commit ($current_sha), re-cloning..."
        rm -rf "$target_dir"
    fi

    echo "  $name: cloning $url at $commit..."
    if ! git clone --quiet "$url" "$target_dir" 2>/dev/null; then
        echo "  $name: FAILED to clone $url"
        return 1
    fi

    if ! git -C "$target_dir" checkout --quiet "$commit" 2>/dev/null; then
        echo "  $name: FAILED to checkout $commit"
        return 1
    fi

    local size
    size=$(du -sh "$target_dir" 2>/dev/null | cut -f1)
    echo "  $name: cloned ($size)"
}

# Returns the local directory path for a target.
target_dir() {
    local name="$1"
    local local_path
    local_path=$(target_field "$name" "local_path")

    if [[ "$local_path" != "null" && -n "$local_path" && -d "$local_path" ]]; then
        echo "$local_path"
    else
        echo "$CLONE_DIR/$name"
    fi
}

# ─── Phase 2: Run Skill ──────────────────────────────────────

# Builds the system prompt from SKILL.md + supporting files.
build_skill_context() {
    local skill="$1"
    local skill_dir="$SKILLS_DIR/$skill"
    local context=""

    # Always include SKILL.md
    context=$(cat "$skill_dir/SKILL.md")

    # Append any checklists
    if ls "$skill_dir"/checklists/*.md &>/dev/null; then
        for f in "$skill_dir"/checklists/*.md; do
            context+=$'\n\n---\n\n'
            context+=$(cat "$f")
        done
    fi

    # Append any templates
    if ls "$skill_dir"/templates/*.md &>/dev/null; then
        for f in "$skill_dir"/templates/*.md; do
            context+=$'\n\n---\n\n'
            context+=$(cat "$f")
        done
    fi

    echo "$context"
}

# Runs a skill against a target. Writes transcript JSON to results dir.
run_skill() {
    local skill="$1" target="$2" results_dir="$3"
    local tgt_dir transcript_file

    tgt_dir=$(target_dir "$target")
    transcript_file="$results_dir/transcripts/${skill}--${target}--transcript.json"

    # Verify target directory exists
    if [[ ! -d "$tgt_dir" ]]; then
        echo "ERROR: Target directory missing: $tgt_dir" >> "$results_dir/errors.log"
        return 1
    fi

    # Build skill context (SKILL.md + supporting files)
    local skill_context
    skill_context=$(build_skill_context "$skill")

    # Prepend the no-modify instruction
    local system_prompt
    system_prompt="IMPORTANT: Do not modify, delete, or write any files in this repository. You are running a read-only privacy audit.

$skill_context"

    local prompt="Run the ${skill} skill against this codebase. Follow the skill's Process section step by step. Produce the complete output specified in the Output Format section. Wrap your final compiled output between <!-- EVAL_OUTPUT_START --> and <!-- EVAL_OUTPUT_END --> markers."

    # Run claude in print mode with full tool access (read-only)
    if ! (cd "$tgt_dir" && claude -p \
        --system-prompt "$system_prompt" \
        --allowedTools "Read,Grep,Glob,Bash" \
        --output-format json \
        --max-turns "$MAX_TURNS" \
        --max-budget-usd "$MAX_BUDGET" \
        "$prompt" \
    ) > "$transcript_file" 2>>"$results_dir/errors.log"; then
        echo "SKILL_RUN_FAILED" >> "$results_dir/errors.log"
        return 1
    fi

    # Extract output from transcript
    "$SCRIPT_DIR/extract-output.sh" \
        "$transcript_file" \
        "$results_dir/${skill}--${target}--output.md"
}

# ─── Phase 3: Run Judge ──────────────────────────────────────

# Determines which ground truth file to use for a skill × target pair.
resolve_ground_truth() {
    local skill="$1" target="$2"
    local gt_type gt_file

    # Map skill name to ground truth file suffix
    case "$skill" in
        pbd-code-review) gt_type="pbd" ;;
        data-mapping)    gt_type="inventory" ;;
        *)               gt_type="$skill" ;;
    esac

    local tier
    tier=$(target_field "$target" "tier")

    if [[ "$tier" == "public" ]]; then
        gt_file="$SCRIPT_DIR/targets/$target/ground-truth-${gt_type}.md"
    else
        gt_file="$HOLDOUT_PATH/targets/$target/ground-truth-${gt_type}.md"
    fi

    if [[ ! -f "$gt_file" ]]; then
        echo ""
        return
    fi

    echo "$gt_file"
}

# Runs the judge on a skill output. Writes scores to results dir.
run_judge() {
    local skill="$1" target="$2" results_dir="$3"
    local output_file gt_file judge_json scores_file

    output_file="$results_dir/${skill}--${target}--output.md"
    judge_json="$results_dir/transcripts/${skill}--${target}--judge.json"
    scores_file="$results_dir/${skill}--${target}--scores.md"

    # Check output exists
    if [[ ! -f "$output_file" ]]; then
        echo "ERROR: No output file for $skill × $target" >> "$results_dir/errors.log"
        return 1
    fi

    # Resolve ground truth
    gt_file=$(resolve_ground_truth "$skill" "$target")
    if [[ -z "$gt_file" ]]; then
        echo "WARNING: No ground truth for $skill × $target — skipping judge" >> "$results_dir/errors.log"
        return 1
    fi

    # Build judge input: rubric + ground truth + skill output
    local rubric ground_truth skill_output judge_input
    rubric=$(cat "$JUDGE_PROMPT")
    ground_truth=$(cat "$gt_file")
    skill_output=$(cat "$output_file")

    judge_input="${rubric}

## Ground Truth

${ground_truth}

## Skill Output Being Evaluated

${skill_output}"

    # Run judge (non-interactive, no tools, single turn)
    if ! claude -p \
        --output-format json \
        --max-turns 1 \
        --tools "" \
        "$judge_input" \
        > "$judge_json" 2>>"$results_dir/errors.log"; then
        echo "JUDGE_RUN_FAILED for $skill × $target" >> "$results_dir/errors.log"
        return 1
    fi

    # Extract scores from judge response
    local judge_text
    judge_text=$(jq -r '.result // empty' "$judge_json" 2>/dev/null || echo "")

    if [[ -z "$judge_text" ]]; then
        echo "WARNING: Empty judge response for $skill × $target" >> "$results_dir/errors.log"
        return 1
    fi

    echo "$judge_text" > "$scores_file"
}

# ─── Phase 4: Aggregate ──────────────────────────────────────

aggregate_results() {
    local results_dir="$1"
    local summary_file="$results_dir/summary.md"
    local total_cost=0
    local start_time="$2"
    local end_time
    end_time=$(date +%s)

    cat > "$summary_file" << 'HEADER'
# Evaluation Suite — Results Summary

HEADER

    echo "**Run date:** $(date -u '+%Y-%m-%d %H:%M UTC')" >> "$summary_file"

    local elapsed=$(( end_time - start_time ))
    local minutes=$(( elapsed / 60 ))
    local seconds=$(( elapsed % 60 ))
    echo "**Duration:** ${minutes}m ${seconds}s" >> "$summary_file"
    echo "" >> "$summary_file"

    # Build scores table
    echo "## Scores" >> "$summary_file"
    echo "" >> "$summary_file"
    echo "| Skill | Target | D1 | D2 | D3 | D4 | D5 | Total | Verdict |" >> "$summary_file"
    echo "|-------|--------|----|----|----|----|----|----|---------|" >> "$summary_file"

    local pair_count=0
    local pass_count=0

    for scores_file in "$results_dir"/*--*--scores.md; do
        [[ -f "$scores_file" ]] || continue
        pair_count=$((pair_count + 1))

        # Parse skill and target from filename (uses -- as delimiter)
        # e.g., "pbd-code-review--documenso--scores.md" → skill="pbd-code-review", target="documenso"
        local fname
        fname=$(basename "$scores_file" --scores.md)
        local skill target
        skill="${fname%%--*}"
        target="${fname#*--}"

        # Extract scores via grep (macOS-compatible, no -P flag)
        local d1 d2 d3 d4 d5 total verdict
        d1=$(grep -oE 'SCORE_DIMENSION_1:[[:space:]]*[0-9]+' "$scores_file" 2>/dev/null | grep -oE '[0-9]+$' || echo "?")
        d2=$(grep -oE 'SCORE_DIMENSION_2:[[:space:]]*[0-9]+' "$scores_file" 2>/dev/null | grep -oE '[0-9]+$' || echo "?")
        d3=$(grep -oE 'SCORE_DIMENSION_3:[[:space:]]*[0-9]+' "$scores_file" 2>/dev/null | grep -oE '[0-9]+$' || echo "?")
        d4=$(grep -oE 'SCORE_DIMENSION_4:[[:space:]]*[0-9]+' "$scores_file" 2>/dev/null | grep -oE '[0-9]+$' || echo "?")
        d5=$(grep -oE 'SCORE_DIMENSION_5:[[:space:]]*[0-9]+' "$scores_file" 2>/dev/null | grep -oE '[0-9]+$' || echo "?")
        total=$(grep -oE 'AGGREGATE:[[:space:]]*[0-9]+' "$scores_file" 2>/dev/null | grep -oE '[0-9]+$' || echo "?")
        verdict=$(grep -E '^VERDICT:' "$scores_file" 2>/dev/null | sed 's/^VERDICT:[[:space:]]*//' || echo "?")

        echo "| $skill | $target | $d1 | $d2 | $d3 | $d4 | $d5 | $total | $verdict |" >> "$summary_file"

        if [[ "$verdict" == *"PASS"* ]]; then
            pass_count=$((pass_count + 1))
        fi
    done

    echo "" >> "$summary_file"
    echo "**Pairs evaluated:** $pair_count" >> "$summary_file"
    echo "**Passing (PASS or STRONG PASS):** $pass_count / $pair_count" >> "$summary_file"
    echo "" >> "$summary_file"

    # Cost summary from transcripts
    echo "## Cost" >> "$summary_file"
    echo "" >> "$summary_file"

    local total_cost_cents=0
    for transcript in "$results_dir"/transcripts/*.json; do
        [[ -f "$transcript" ]] || continue
        local cost
        cost=$(jq -r '.cost_usd // .cost // 0' "$transcript" 2>/dev/null || echo "0")
        # Accumulate (jq handles float arithmetic)
        total_cost_cents=$(echo "$total_cost_cents + $cost" | bc 2>/dev/null || echo "$total_cost_cents")
    done
    echo "**Total API cost:** \$${total_cost_cents}" >> "$summary_file"
    echo "" >> "$summary_file"

    # Errors
    if [[ -s "$results_dir/errors.log" ]]; then
        echo "## Errors" >> "$summary_file"
        echo "" >> "$summary_file"
        echo '```' >> "$summary_file"
        cat "$results_dir/errors.log" >> "$summary_file"
        echo '```' >> "$summary_file"
    fi

    echo ""
    echo "Summary written to: $summary_file"
}

# ─── Dry Run ──────────────────────────────────────────────────

run_dry_run() {
    echo "=== DRY RUN — validating setup ==="
    echo ""

    local errors=0

    # Check targets.yaml
    echo "Targets (targets.yaml):"
    local targets
    targets=$(discover_targets)
    if [[ -z "$targets" ]]; then
        echo "  ERROR: No targets matched"
        errors=$((errors + 1))
    else
        while IFS= read -r target; do
            local url commit tier
            url=$(target_field "$target" "url")
            commit=$(target_field "$target" "commit")
            tier=$(target_field "$target" "tier")
            echo "  $target ($tier): $url @ ${commit:0:12}..."
        done <<< "$targets"
    fi
    echo ""

    # Check skills
    echo "Skills:"
    local skills
    skills=$(discover_skills)
    for skill in $skills; do
        local skill_file="$SKILLS_DIR/$skill/SKILL.md"
        if [[ -f "$skill_file" ]]; then
            echo "  $skill: OK ($skill_file)"
        else
            echo "  $skill: MISSING SKILL.md"
            errors=$((errors + 1))
        fi
    done
    echo ""

    # Check ground truth availability
    echo "Ground truth:"
    while IFS= read -r target; do
        for skill in $skills; do
            local gt_file
            gt_file=$(resolve_ground_truth "$skill" "$target")
            if [[ -n "$gt_file" && -f "$gt_file" ]]; then
                echo "  $skill × $target: OK ($gt_file)"
            else
                echo "  $skill × $target: NOT FOUND (will skip judge)"
            fi
        done
    done <<< "$targets"
    echo ""

    # Check judge prompt
    if [[ -f "$JUDGE_PROMPT" ]]; then
        echo "Judge prompt: OK ($JUDGE_PROMPT)"
    else
        echo "Judge prompt: MISSING"
        errors=$((errors + 1))
    fi
    echo ""

    if [[ $errors -gt 0 ]]; then
        echo "Dry run found $errors error(s). Fix before running."
        exit 1
    else
        echo "Dry run passed. Ready to run (will cost API credits)."
    fi
}

# ─── Main ─────────────────────────────────────────────────────

main() {
    echo "╔══════════════════════════════════════════╗"
    echo "║   Privacy Skills Evaluation Suite        ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""

    check_prereqs

    if [[ "$DRY_RUN" == true ]]; then
        run_dry_run
        exit 0
    fi

    # Discover what to run
    local targets skills
    targets=$(discover_targets)
    skills=$(discover_skills)

    if [[ -z "$targets" ]]; then
        echo "ERROR: No targets matched filters (tier=$TIER, target=$FILTER_TARGET)"
        exit 1
    fi

    # Count pairs for progress display
    local target_count=0 skill_count=0 pair_count=0
    while IFS= read -r _; do target_count=$((target_count + 1)); done <<< "$targets"
    for _ in $skills; do skill_count=$((skill_count + 1)); done
    pair_count=$((target_count * skill_count))

    echo "Plan: $skill_count skill(s) × $target_count target(s) = $pair_count pair(s)"
    echo "Estimated time: ~$((pair_count * 4)) minutes"
    echo ""

    # Create results directory
    local timestamp results_dir
    timestamp=$(date '+%Y-%m-%d-%H-%M')
    results_dir="$SCRIPT_DIR/results/$timestamp"
    mkdir -p "$results_dir/transcripts"
    touch "$results_dir/errors.log"

    local start_time
    start_time=$(date +%s)

    # ── Phase 1: Clone Targets ──

    echo "Phase 1: Cloning targets..."
    mkdir -p "$CLONE_DIR"
    while IFS= read -r target; do
        clone_target "$target" || echo "CLONE_FAILED: $target" >> "$results_dir/errors.log"
    done <<< "$targets"
    echo ""

    # ── Phase 2 & 3: Run skills + judge ──

    local current=0
    local elapsed_total=0

    while IFS= read -r target; do
        for skill in $skills; do
            current=$((current + 1))

            # Progress display with time estimate
            local eta=""
            if [[ $current -gt 1 && $elapsed_total -gt 0 ]]; then
                local avg_per_pair=$(( elapsed_total / (current - 1) ))
                local remaining=$(( avg_per_pair * (pair_count - current + 1) ))
                eta=" (~$((remaining / 60))m remaining)"
            fi

            echo "[$current/$pair_count] Running $skill × $target...${eta}"

            local pair_start
            pair_start=$(date +%s)

            # Phase 2: Run skill
            if run_skill "$skill" "$target" "$results_dir"; then
                # Phase 3: Run judge (only if skill succeeded and ground truth exists)
                run_judge "$skill" "$target" "$results_dir" || true
            else
                echo "  FAILED — see errors.log"
            fi

            local pair_end
            pair_end=$(date +%s)
            elapsed_total=$(( elapsed_total + pair_end - pair_start ))
        done
    done <<< "$targets"

    echo ""

    # ── Phase 4: Aggregate ──

    echo "Phase 4: Aggregating results..."
    aggregate_results "$results_dir" "$start_time"

    echo ""
    echo "Results: $results_dir/"
    echo "Review summary.md and spot-check transcripts before making merge decisions."
}

main "$@"
