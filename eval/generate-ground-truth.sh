#!/usr/bin/env bash
# generate-ground-truth.sh — Auto-generate ground truth for a skill via independent auditor
#
# Runs an independent auditor session against target codebases to produce
# ground truth that a skill's output can be judged against. The auditor
# receives the skill's goals and output format but NOT its process steps,
# ensuring independence.
#
# Usage:
#   ./eval/generate-ground-truth.sh --skill <name> [--target <name>] [--tier public|private|all] [--holdout-path <path>]
#
# Output:
#   eval/results/<timestamp>/auto-ground-truth/<target>/ground-truth-<skill>.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGETS_YAML="$SCRIPT_DIR/targets.yaml"
AUDITOR_PROMPT="$SCRIPT_DIR/auditor-prompt.md"
SKILLS_DIR="$REPO_ROOT/skills"
CLONE_DIR="/tmp/eval-targets"
MAX_TURNS=50

# ─── Arguments ────────────────────────────────────────────────

FILTER_SKILL=""
FILTER_TARGET=""
TIER="public"
HOLDOUT_PATH=""
OUTPUT_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --skill)        FILTER_SKILL="$2"; shift 2 ;;
        --target)       FILTER_TARGET="$2"; shift 2 ;;
        --tier)         TIER="$2"; shift 2 ;;
        --holdout-path) HOLDOUT_PATH="$2"; shift 2 ;;
        --output-dir)   OUTPUT_DIR="$2"; shift 2 ;;
        --help|-h)      sed -n '2,/^$/p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'; exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$FILTER_SKILL" ]]; then
    echo "ERROR: --skill is required"
    exit 1
fi

# Note: --holdout-path is NOT required for generate-ground-truth.sh
# (unlike run-eval.sh which needs it for GT resolution). The generate script
# only needs to know which targets to run against (from targets.yaml)
# and where to write output (--output-dir).

# ─── Prerequisites ────────────────────────────────────────────

for cmd in claude git yq jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: $cmd is required but not installed"
        exit 1
    fi
done

# ─── Extract Skill Context (excluding Process section) ────────

extract_skill_context() {
    local skill="$1"
    local skill_file="$SKILLS_DIR/$skill/SKILL.md"

    if [[ ! -f "$skill_file" ]]; then
        echo "ERROR: SKILL.md not found at $skill_file" >&2
        return 1
    fi

    # Extract YAML frontmatter description
    local description
    description=$(sed -n '/^---$/,/^---$/p' "$skill_file" | yq '.description // ""' 2>/dev/null || echo "")

    # Extract "When to Use" section (stop at the next ## heading)
    local when_to_use
    when_to_use=$(sed -n '/^## When to Use/,/^## /{ /^## When to Use/p; /^## /!p; }' "$skill_file" || echo "")

    # Extract "Output Format" section (between ## Output Format and the next ## heading)
    local output_format
    output_format=$(sed -n '/^## Output Format/,/^## [^O]/p' "$skill_file" | sed '$d' || echo "")

    # If output_format capture missed (last section in file), try without delimiter
    if [[ -z "$output_format" ]]; then
        output_format=$(sed -n '/^## Output Format/,$p' "$skill_file" || echo "")
    fi

    # Build the parameterised auditor prompt
    local auditor_template
    auditor_template=$(cat "$AUDITOR_PROMPT")

    # Replace placeholders
    auditor_template="${auditor_template//\{\{SKILL_DESCRIPTION\}\}/$description}"
    auditor_template="${auditor_template//\{\{SKILL_FOCUS\}\}/$when_to_use}"
    auditor_template="${auditor_template//\{\{SKILL_OUTPUT_FORMAT\}\}/$output_format}"

    echo "$auditor_template"
}

# ─── Discover Targets (reused from run-eval.sh pattern) ───────

discover_targets() {
    local count
    count=$(yq '.targets | length' "$TARGETS_YAML")

    for ((i = 0; i < count; i++)); do
        local name tier
        name=$(yq ".targets[$i].name" "$TARGETS_YAML")
        tier=$(yq ".targets[$i].tier" "$TARGETS_YAML")

        if [[ "$TIER" == "public" && "$tier" != "public" ]]; then continue; fi
        if [[ "$TIER" == "private" && "$tier" != "private" ]]; then continue; fi

        if [[ -n "$FILTER_TARGET" && "$name" != "$FILTER_TARGET" ]]; then continue; fi

        echo "$name"
    done
}

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

# ─── Generate Ground Truth ────────────────────────────────────

main() {
    echo "Generating ground truth for skill: $FILTER_SKILL"
    echo ""

    # Set up output directory
    local timestamp
    timestamp=$(date '+%Y-%m-%d-%H-%M')
    if [[ -z "$OUTPUT_DIR" ]]; then
        OUTPUT_DIR="$SCRIPT_DIR/results/$timestamp/auto-ground-truth"
    fi

    # Build auditor prompt with skill context
    local auditor_prompt
    auditor_prompt=$(extract_skill_context "$FILTER_SKILL")

    if [[ -z "$auditor_prompt" ]]; then
        echo "ERROR: Failed to extract skill context"
        exit 1
    fi

    # Discover targets
    local targets
    targets=$(discover_targets)

    if [[ -z "$targets" ]]; then
        echo "ERROR: No targets matched (tier=$TIER, target=$FILTER_TARGET)"
        exit 1
    fi

    local count=0
    local total
    total=$(echo "$targets" | wc -l | tr -d ' ')

    while IFS= read -r target; do
        count=$((count + 1))
        local tgt_dir gt_dir gt_file transcript_file

        tgt_dir=$(target_dir "$target")
        gt_dir="$OUTPUT_DIR/$target"
        gt_file="$gt_dir/ground-truth-${FILTER_SKILL}.md"
        transcript_file="$gt_dir/auditor-transcript-${FILTER_SKILL}.json"

        mkdir -p "$gt_dir"

        if [[ ! -d "$tgt_dir" ]]; then
            echo "[$count/$total] $target: SKIPPED (target dir missing: $tgt_dir)"
            continue
        fi

        echo "[$count/$total] Auditing $target for $FILTER_SKILL..."

        # Prepend read-only instruction
        local system_prompt="IMPORTANT: Do not modify, delete, or write any files in this repository. You are conducting a read-only privacy audit.

$auditor_prompt"

        # Run auditor session
        if ! (cd "$tgt_dir" && claude -p \
            --system-prompt "$system_prompt" \
            --allowedTools "Read,Grep,Glob,Bash" \
            --output-format json \
            --max-turns "$MAX_TURNS" \
            "Audit this codebase and produce ground truth findings for the skill focus area described in your instructions. Be thorough — explore schemas, models, routes, configs, and integrations. Wrap your final output between <!-- EVAL_OUTPUT_START --> and <!-- EVAL_OUTPUT_END --> markers." \
        ) > "$transcript_file" 2>/dev/null; then
            echo "  FAILED — auditor session error"
            continue
        fi

        # Extract auditor output
        "$SCRIPT_DIR/extract-output.sh" "$transcript_file" "$gt_file"

        # Prepend auto-generated header
        local header="<!-- AUTO-GENERATED by auditor on $(date '+%Y-%m-%d') — requires maintainer review before promotion -->
"
        local content
        content=$(cat "$gt_file")
        echo "${header}${content}" > "$gt_file"

        local word_count
        word_count=$(wc -w < "$gt_file" | tr -d ' ')
        echo "  Done ($word_count words) → $gt_file"

    done <<< "$targets"

    echo ""
    echo "Auto-generated ground truth: $OUTPUT_DIR/"
    echo "Review before promoting to permanent ground truth."
}

main
