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
#   --results-dir <path>   Write results to this directory instead of eval/results/<timestamp>
#   --skills-dir <path>    Use skills from this directory instead of $REPO_ROOT/skills
#   --dry-run              Validate setup without invoking Claude
#   --help                 Show this help message

set -euo pipefail

# ─── Constants ────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGETS_YAML="$SCRIPT_DIR/targets.yaml"
JUDGE_PROMPT="$SCRIPT_DIR/judge-prompt.md"
SKILLS_DIR="$REPO_ROOT/skills"

# Judge prompt — maintainer-only file. When absent, skill runs proceed but judging is skipped.
if [[ -f "$JUDGE_PROMPT" ]]; then
    JUDGE_AVAILABLE=true
else
    JUDGE_AVAILABLE=false
fi
CLONE_DIR="/tmp/eval-targets"
MAX_TURNS=50
MAX_BUDGET="5.00"

# ─── Argument Parsing ─────────────────────────────────────────

FILTER_SKILL=""
FILTER_TARGET=""
TIER="public"
HOLDOUT_PATH=""
RESULTS_DIR=""
SKILLS_DIR_OVERRIDE=""
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
        --results-dir)  RESULTS_DIR="$2"; shift 2 ;;
        --skills-dir)   SKILLS_DIR_OVERRIDE="$2"; shift 2 ;;
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

# Apply --skills-dir override (default: $REPO_ROOT/skills)
if [[ -n "$SKILLS_DIR_OVERRIDE" ]]; then
    SKILLS_DIR="$SKILLS_DIR_OVERRIDE"
    if [[ ! -d "$SKILLS_DIR" ]]; then
        echo "ERROR: --skills-dir path does not exist: $SKILLS_DIR"
        exit 1
    fi
    if ! ls "$SKILLS_DIR"/*/SKILL.md &>/dev/null; then
        echo "ERROR: --skills-dir contains no */SKILL.md files: $SKILLS_DIR"
        exit 1
    fi
    echo "Using custom skills directory: $SKILLS_DIR"
    echo ""
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

    local prompt="Run the ${skill} skill against this codebase. Follow the skill's Process section step by step. Produce the complete output specified in the Output Format section. Wrap your final compiled output between <!-- EVAL_OUTPUT_START --> and <!-- EVAL_OUTPUT_END --> markers. IMPORTANT: Your FINAL message must contain the complete report between the EVAL_OUTPUT markers. The extraction pipeline only reads your last message — do not produce the report earlier and then summarize."

    # Run claude in print mode with full tool access (read-only)
    if ! (cd "$tgt_dir" && claude -p \
        --system-prompt "$system_prompt" \
        --allowedTools "Read,Grep,Glob,Bash" \
        --output-format json \
        --max-turns "$MAX_TURNS" \
        --max-budget-usd "$MAX_BUDGET" \
        "$prompt" \
    ) < /dev/null > "$transcript_file" 2>>"$results_dir/errors.log"; then
        echo "SKILL_RUN_FAILED" >> "$results_dir/errors.log"
        return 1
    fi

    # Extract output from transcript
    local extract_exit=0
    "$SCRIPT_DIR/extract-output.sh" \
        "$transcript_file" \
        "$results_dir/${skill}--${target}--output.md" \
        || extract_exit=$?

    # Record extraction status (parallels gt-types.txt pattern)
    if [[ $extract_exit -eq 0 ]]; then
        echo "${skill}--${target}:markers" >> "$results_dir/extraction-status.txt"
    elif [[ $extract_exit -eq 2 ]]; then
        echo "${skill}--${target}:fallback" >> "$results_dir/extraction-status.txt"
        echo "EXTRACTION_FALLBACK: ${skill} × ${target} — markers not found, used full result text" >> "$results_dir/errors.log"
        return 2
    else
        echo "${skill}--${target}:failed" >> "$results_dir/extraction-status.txt"
        return 1
    fi
}

# ─── Phase 3: Run Judges ─────────────────────────────────────

# Determines which ground truth file to use for a skill × target pair.
# Writes the resolved path to GT_RESOLVED_PATH and type to GT_RESOLVED_TYPE.
# Uses file-based communication to avoid subshell variable loss.
GT_RESOLVED_PATH=""
GT_RESOLVED_TYPE=""

resolve_ground_truth() {
    local skill="$1" target="$2" results_dir="$3"
    local gt_file

    # Ground truth files are maintained privately — all GT resolves from --holdout-path.
    # Without --holdout-path, GT is auto-generated (correct for contributor self-evals).

    # Check for human-reviewed ground truth in holdout path
    if [[ -n "$HOLDOUT_PATH" ]]; then
        gt_file="$HOLDOUT_PATH/targets/$target/ground-truth-${skill}.md"
        if [[ -f "$gt_file" ]]; then
            GT_RESOLVED_PATH="$gt_file"
            GT_RESOLVED_TYPE="human"
            return
        fi
    fi

    # No human GT — auto-generate via auditor
    echo "  Auto-generating ground truth (no human GT found)..."
    local auto_gt_dir="$results_dir/auto-ground-truth"

    "$SCRIPT_DIR/generate-ground-truth.sh" \
        --skill "$skill" \
        --target "$target" \
        --tier "$TIER" \
        ${HOLDOUT_PATH:+--holdout-path "$HOLDOUT_PATH"} \
        --output-dir "$auto_gt_dir" \
        2>>"$results_dir/errors.log" || true

    gt_file="$auto_gt_dir/$target/ground-truth-${skill}.md"

    if [[ -f "$gt_file" ]]; then
        GT_RESOLVED_PATH="$gt_file"
        GT_RESOLVED_TYPE="auto"
        echo "  NOTE: Auto-generated GT used — review $gt_file before relying on accuracy scores" >> "$results_dir/errors.log"
    else
        GT_RESOLVED_PATH=""
        GT_RESOLVED_TYPE=""
    fi
}

# Extracts the Output Format section from a skill's SKILL.md.
extract_output_format() {
    local skill="$1"
    local skill_file="$SKILLS_DIR/$skill/SKILL.md"

    if [[ ! -f "$skill_file" ]]; then
        echo ""
        return
    fi

    # Extract from "## Output Format" to the next "##" heading (or EOF)
    local output_format
    output_format=$(sed -n '/^## Output Format/,/^## [^O]/p' "$skill_file" | sed '$d' 2>/dev/null || echo "")

    # If capture missed (last section), try without delimiter
    if [[ -z "$output_format" ]]; then
        output_format=$(sed -n '/^## Output Format/,$p' "$skill_file" 2>/dev/null || echo "")
    fi

    echo "$output_format"
}

# Runs the accuracy judge on skill output vs. ground truth.
run_judge_accuracy() {
    if [[ "$JUDGE_AVAILABLE" != true ]]; then
        echo "  Skipping accuracy judge (judge-prompt.md not available)"
        return 0
    fi

    local skill="$1" target="$2" results_dir="$3"
    local output_file gt_file judge_json scores_file

    output_file="$results_dir/${skill}--${target}--output.md"
    judge_json="$results_dir/transcripts/${skill}--${target}--judge-accuracy.json"
    scores_file="$results_dir/${skill}--${target}--scores-accuracy.md"

    if [[ ! -f "$output_file" ]]; then
        echo "ERROR: No output file for $skill × $target" >> "$results_dir/errors.log"
        return 1
    fi

    # Resolve ground truth (human or auto-generated)
    resolve_ground_truth "$skill" "$target" "$results_dir"
    gt_file="$GT_RESOLVED_PATH"
    if [[ -z "$gt_file" ]]; then
        echo "WARNING: No ground truth for $skill × $target — skipping accuracy judge" >> "$results_dir/errors.log"
        return 1
    fi

    local rubric ground_truth skill_output judge_input
    rubric=$(cat "$JUDGE_PROMPT")
    ground_truth=$(cat "$gt_file")
    skill_output=$(cat "$output_file")

    judge_input="${rubric}

Use the Accuracy Rubric for this evaluation. Do not produce Quality Scores — those are handled by a separate judge run. Your output should contain only the Evaluation Scores block (SCORE_DIMENSION_1 through VERDICT_REASONING).

## Ground Truth

${ground_truth}

## Skill Output Being Evaluated

${skill_output}"

    if ! echo "$judge_input" | claude -p \
        --output-format json \
        --max-turns 1 \
        --tools "" \
        > "$judge_json" 2>>"$results_dir/errors.log"; then
        echo "ACCURACY_JUDGE_FAILED for $skill × $target" >> "$results_dir/errors.log"
        return 1
    fi

    local judge_text
    judge_text=$(jq -r '.result // empty' "$judge_json" 2>/dev/null || echo "")

    if [[ -z "$judge_text" ]]; then
        echo "WARNING: Empty accuracy judge response for $skill × $target" >> "$results_dir/errors.log"
        return 1
    fi

    echo "$judge_text" > "$scores_file"
}

# Runs the quality judge on skill output — no ground truth needed.
run_judge_quality() {
    if [[ "$JUDGE_AVAILABLE" != true ]]; then
        return 0
    fi

    local skill="$1" target="$2" results_dir="$3"
    local output_file judge_json scores_file

    output_file="$results_dir/${skill}--${target}--output.md"
    judge_json="$results_dir/transcripts/${skill}--${target}--judge-quality.json"
    scores_file="$results_dir/${skill}--${target}--scores-quality.md"

    if [[ ! -f "$output_file" ]]; then
        return 1
    fi

    # Extract the skill's Output Format section for format compliance checking
    local output_format_spec
    output_format_spec=$(extract_output_format "$skill")

    local rubric skill_output judge_input
    rubric=$(cat "$JUDGE_PROMPT")
    skill_output=$(cat "$output_file")

    judge_input="${rubric}

Use the Quality Rubric for this evaluation (no ground truth comparison — evaluate structural quality only).

## Skill Output Format Specification

${output_format_spec}

## Skill Output Being Evaluated

${skill_output}"

    if ! echo "$judge_input" | claude -p \
        --output-format json \
        --max-turns 1 \
        --tools "" \
        > "$judge_json" 2>>"$results_dir/errors.log"; then
        echo "QUALITY_JUDGE_FAILED for $skill × $target" >> "$results_dir/errors.log"
        return 1
    fi

    local judge_text
    judge_text=$(jq -r '.result // empty' "$judge_json" 2>/dev/null || echo "")

    if [[ -z "$judge_text" ]]; then
        echo "WARNING: Empty quality judge response for $skill × $target" >> "$results_dir/errors.log"
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

    # Build scores table (accuracy + quality)
    echo "## Scores" >> "$summary_file"
    echo "" >> "$summary_file"
    echo "| Skill | Target | GT | D1 | D2 | D3 | D4 | D5 | Accuracy | Quality | Verdict |" >> "$summary_file"
    echo "|-------|--------|----|----|----|----|----|----|----------|---------|---------|" >> "$summary_file"

    local pair_count=0
    local pass_count=0

    # Count no-judge pairs for summary
    local no_judge_count=0
    if [[ -f "$results_dir/gt-types.txt" ]]; then
        no_judge_count=$(grep -c ':no-judge$' "$results_dir/gt-types.txt" || echo 0)
    fi

    # Iterate over accuracy score files (one per pair)
    for scores_file in "$results_dir"/*--*--scores-accuracy.md; do
        [[ -f "$scores_file" ]] || continue
        pair_count=$((pair_count + 1))

        # Parse skill and target from filename
        local fname
        fname=$(basename -- "$scores_file" | sed 's/--scores-accuracy\.md$//')
        local skill target
        skill="${fname%%--*}"
        target="${fname#*--}"

        # Extract accuracy scores (macOS-compatible)
        local d1 d2 d3 d4 d5 accuracy verdict
        d1=$(grep -oE 'SCORE_DIMENSION_1:[[:space:]]*[0-9]+' "$scores_file" 2>/dev/null | grep -oE '[0-9]+$' || echo "?")
        d2=$(grep -oE 'SCORE_DIMENSION_2:[[:space:]]*[0-9]+' "$scores_file" 2>/dev/null | grep -oE '[0-9]+$' || echo "?")
        d3=$(grep -oE 'SCORE_DIMENSION_3:[[:space:]]*[0-9]+' "$scores_file" 2>/dev/null | grep -oE '[0-9]+$' || echo "?")
        d4=$(grep -oE 'SCORE_DIMENSION_4:[[:space:]]*[0-9]+' "$scores_file" 2>/dev/null | grep -oE '[0-9]+$' || echo "?")
        d5=$(grep -oE 'SCORE_DIMENSION_5:[[:space:]]*[0-9]+' "$scores_file" 2>/dev/null | grep -oE '[0-9]+$' || echo "?")
        accuracy=$(grep -E '^AGGREGATE:' "$scores_file" 2>/dev/null | head -1 | grep -oE '[0-9]+$' || echo "?")
        verdict=$(grep -E '^VERDICT:' "$scores_file" 2>/dev/null | sed 's/^VERDICT:[[:space:]]*//' || echo "?")

        # Extract quality score from companion file
        local quality_file="$results_dir/${skill}--${target}--scores-quality.md"
        local quality="—"
        if [[ -f "$quality_file" ]]; then
            quality=$(grep -oE 'QUALITY_AGGREGATE:[[:space:]]*[0-9]+' "$quality_file" 2>/dev/null | grep -oE '[0-9]+$' || echo "?")
        fi

        # Look up GT type from recorded types
        local gt_type="?"
        if [[ -f "$results_dir/gt-types.txt" ]]; then
            gt_type=$(grep "^${skill}--${target}:" "$results_dir/gt-types.txt" 2>/dev/null | cut -d: -f2 || echo "?")
        fi

        # Flag discrepancy: high quality but low coverage
        local flag=""
        if [[ "$d1" =~ ^[0-9]+$ && "$d1" -le 2 && "$quality" =~ ^[0-9]+$ && "$quality" -ge 20 ]]; then
            flag=" ⚠️"
        fi

        echo "| $skill | $target | $gt_type | $d1 | $d2 | $d3 | $d4 | $d5 | $accuracy | $quality | ${verdict}${flag} |" >> "$summary_file"

        if [[ "$verdict" == *"PASS"* ]]; then
            pass_count=$((pass_count + 1))
        fi
    done

    # Add placeholder rows for fallback extraction pairs (no score files created)
    if [[ -f "$results_dir/extraction-status.txt" ]]; then
        while IFS=: read -r pair status; do
            if [[ "$status" == "fallback" ]]; then
                local fb_skill="${pair%%--*}"
                local fb_target="${pair#*--}"
                echo "| $fb_skill | $fb_target | — | — | — | — | — | — | — | — | EXTRACTION FAILED |" >> "$summary_file"
            fi
        done < "$results_dir/extraction-status.txt"
    fi

    echo "" >> "$summary_file"
    echo "**Pairs evaluated:** $pair_count" >> "$summary_file"
    echo "**Passing (PASS or STRONG PASS):** $pass_count / $pair_count" >> "$summary_file"
    echo "" >> "$summary_file"

    # Extraction stats
    local markers_count=0 fallback_count=0 failed_count=0
    if [[ -f "$results_dir/extraction-status.txt" ]]; then
        markers_count=$(grep -c ':markers$' "$results_dir/extraction-status.txt" || echo 0)
        fallback_count=$(grep -c ':fallback$' "$results_dir/extraction-status.txt" || echo 0)
        failed_count=$(grep -c ':failed$' "$results_dir/extraction-status.txt" || echo 0)
    fi
    echo "**Extraction:** $markers_count marker-based, $fallback_count fallback (skipped judging), $failed_count failed" >> "$summary_file"
    echo "_⚠️ = Quality ≥ 20 but Coverage ≤ 2 — skill produced polished output that missed most findings_" >> "$summary_file"
    echo "" >> "$summary_file"

    if [[ $pair_count -eq 0 && $no_judge_count -gt 0 ]]; then
        echo "**Note:** Judge prompt not available — judging was skipped for all $no_judge_count pair(s). Skill outputs are in this directory for manual review. The maintainer runs authoritative scoring during PR review." >> "$summary_file"
        echo "" >> "$summary_file"
        echo "**Skill outputs:**" >> "$summary_file"
        for output_file in "$results_dir"/*--*--output.md; do
            [[ -f "$output_file" ]] && echo "- $(basename "$output_file")" >> "$summary_file"
        done
        echo "" >> "$summary_file"
    fi

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
        while IFS= read -r target <&3; do
            local url commit tier
            url=$(target_field "$target" "url")
            commit=$(target_field "$target" "commit")
            tier=$(target_field "$target" "tier")
            echo "  $target ($tier): $url @ ${commit:0:12}..."
        done 3<<< "$targets"
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

    # Check ground truth availability (direct file check — no auto-generation in dry run)
    # All GT is maintained privately via --holdout-path. Without it, GT auto-generates at runtime.
    echo "Ground truth:"
    if [[ -z "$HOLDOUT_PATH" ]]; then
        echo "  No --holdout-path provided — all GT will be auto-generated at runtime"
    else
        while IFS= read -r target <&3; do
            for skill in $skills; do
                local gt_file
                gt_file="$HOLDOUT_PATH/targets/$target/ground-truth-${skill}.md"
                if [[ -f "$gt_file" ]]; then
                    echo "  $skill × $target: OK ($gt_file)"
                else
                    echo "  $skill × $target: NOT FOUND (will auto-generate at runtime)"
                fi
            done
        done 3<<< "$targets"
    fi
    echo ""

    # Check judge prompt
    if [[ -f "$JUDGE_PROMPT" ]]; then
        echo "Judge prompt: OK ($JUDGE_PROMPT)"
    else
        echo "Judge prompt: NOT FOUND — judging will be skipped (maintainer runs authoritative scoring)"
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
    while IFS= read -r _ <&3; do target_count=$((target_count + 1)); done 3<<< "$targets"
    for _ in $skills; do skill_count=$((skill_count + 1)); done
    pair_count=$((target_count * skill_count))

    echo "Plan: $skill_count skill(s) × $target_count target(s) = $pair_count pair(s)"
    echo "Estimated time: ~$((pair_count * 4)) minutes"
    echo ""

    # Create results directory
    local timestamp results_dir
    timestamp=$(date '+%Y-%m-%d-%H-%M')
    if [[ -n "$RESULTS_DIR" ]]; then
        results_dir="$RESULTS_DIR"
    else
        results_dir="$SCRIPT_DIR/results/$timestamp"
    fi
    mkdir -p "$results_dir/transcripts"
    touch "$results_dir/errors.log"

    local start_time
    start_time=$(date +%s)

    # ── Phase 1: Clone Targets ──

    echo "Phase 1: Cloning targets..."
    mkdir -p "$CLONE_DIR"
    while IFS= read -r target <&3; do
        clone_target "$target" || echo "CLONE_FAILED: $target" >> "$results_dir/errors.log"
    done 3<<< "$targets"
    echo ""

    # ── Phase 2 & 3: Run skills + judge ──

    local current=0
    local elapsed_total=0

    while IFS= read -r target <&3; do
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
            local skill_exit=0
            run_skill "$skill" "$target" "$results_dir" || skill_exit=$?

            case $skill_exit in
                0)  # Success — markers found
                    if [[ "$JUDGE_AVAILABLE" == true ]]; then
                        run_judge_accuracy "$skill" "$target" "$results_dir" || true
                        run_judge_quality "$skill" "$target" "$results_dir" || true
                        echo "${skill}--${target}:${GT_RESOLVED_TYPE}" >> "$results_dir/gt-types.txt"
                    else
                        echo "  Judging skipped (judge-prompt.md not available)"
                        echo "${skill}--${target}:no-judge" >> "$results_dir/gt-types.txt"
                    fi
                    ;;
                2)  # Extraction fallback — skill ran but markers missing
                    echo "  EXTRACTION FALLBACK — skipping judges"
                    ;;
                *)  # Skill run failed
                    echo "  FAILED — see errors.log"
                    ;;
            esac

            local pair_end
            pair_end=$(date +%s)
            elapsed_total=$(( elapsed_total + pair_end - pair_start ))
        done
    done 3<<< "$targets"

    echo ""

    # ── Phase 4: Aggregate ──

    echo "Phase 4: Aggregating results..."
    aggregate_results "$results_dir" "$start_time"

    echo ""
    echo "Results: $results_dir/"
    echo "Review summary.md and spot-check transcripts before making merge decisions."
}

main "$@"
