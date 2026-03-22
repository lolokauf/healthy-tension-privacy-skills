#!/usr/bin/env bash
# extract-output.sh — Extract skill output from a Claude session transcript
#
# The skill prompt instructs the agent to wrap its final output between
# <!-- EVAL_OUTPUT_START --> and <!-- EVAL_OUTPUT_END --> markers. This script
# extracts that content. If markers aren't found, falls back to the last
# assistant messages.
#
# Usage:
#   ./eval/extract-output.sh <transcript.json> <output.md>
#
# Arguments:
#   transcript.json  — JSON output from `claude -p --output-format json`
#   output.md        — Where to write the extracted skill output

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <transcript.json> <output.md>"
    exit 1
fi

TRANSCRIPT="$1"
OUTPUT="$2"

if [[ ! -f "$TRANSCRIPT" ]]; then
    echo "ERROR: Transcript not found: $TRANSCRIPT"
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "ERROR: jq is required but not installed"
    exit 1
fi

# ─── Extract assistant text from transcript ───────────────────

# The JSON structure from `claude -p --output-format json` has a `result`
# field with the final text, and may have a `messages` array with all turns.
# We try the `result` field first, then fall back to `messages`.

all_text=$(jq -r '.result // empty' "$TRANSCRIPT" 2>/dev/null || echo "")

if [[ -z "$all_text" ]]; then
    # Fallback: extract from messages array
    all_text=$(jq -r '
        [.messages[]? |
            select(.role == "assistant") |
            (.content // "") |
            if type == "array" then
                [.[] | select(.type == "text") | .text] | join("\n")
            elif type == "string" then .
            else ""
            end
        ] | join("\n\n")
    ' "$TRANSCRIPT" 2>/dev/null || echo "")
fi

if [[ -z "$all_text" ]]; then
    echo "ERROR: Could not extract any text from transcript"
    echo "<!-- EXTRACTION FAILED: no assistant text found -->" > "$OUTPUT"
    exit 1
fi

# ─── Primary: marker-based extraction ─────────────────────────

extracted=""

if echo "$all_text" | grep -q "<!-- EVAL_OUTPUT_START -->"; then
    # Extract content between markers
    extracted=$(echo "$all_text" | sed -n '/<!-- EVAL_OUTPUT_START -->/,/<!-- EVAL_OUTPUT_END -->/p' | \
        sed '1d;$d')  # Remove the marker lines themselves

    if [[ -n "$extracted" ]]; then
        echo "$extracted" > "$OUTPUT"
    fi
fi

# ─── Fallback: last portion of result ─────────────────────────

fallback_used=0

if [[ -z "$extracted" ]]; then
    echo "WARNING: EVAL_OUTPUT markers not found in transcript, using full result text" >&2

    # Use the full result text — it's the agent's complete response
    echo "$all_text" > "$OUTPUT"
    fallback_used=1
fi

# ─── Append metadata as comment block ─────────────────────────

{
    echo ""
    echo "<!-- EVAL METADATA"

    # Extract session metadata
    local_cost=$(jq -r '.cost_usd // .cost // "unknown"' "$TRANSCRIPT" 2>/dev/null || echo "unknown")
    local_duration=$(jq -r '.duration_ms // .duration // "unknown"' "$TRANSCRIPT" 2>/dev/null || echo "unknown")
    local_turns=$(jq -r '.num_turns // (.messages | length) // "unknown"' "$TRANSCRIPT" 2>/dev/null || echo "unknown")
    local_session=$(jq -r '.session_id // "unknown"' "$TRANSCRIPT" 2>/dev/null || echo "unknown")

    echo "  cost: $local_cost"
    echo "  duration_ms: $local_duration"
    echo "  turns: $local_turns"
    echo "  session_id: $local_session"
    echo "  extraction: $(if [[ -n "$extracted" ]]; then echo "markers"; else echo "fallback (full result)"; fi)"
    echo "-->"
} >> "$OUTPUT"

# Exit 2 for fallback extraction so callers can detect and skip judging
if [[ "$fallback_used" -eq 1 ]]; then
    exit 2
fi
