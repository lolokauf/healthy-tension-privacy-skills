#!/usr/bin/env bash
# clone-targets.sh — Pre-fetch all eval target repos at pinned commits
#
# Run this independently to download repos before an eval run, so the
# actual eval doesn't spend time on network I/O.
#
# Usage:
#   ./eval/clone-targets.sh [--tier public|private|all]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGETS_YAML="$SCRIPT_DIR/targets.yaml"
CLONE_DIR="/tmp/eval-targets"

# ─── Prerequisites ────────────────────────────────────────────

for cmd in git yq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: $cmd is required but not installed"
        exit 1
    fi
done

# ─── Arguments ────────────────────────────────────────────────

# Accept: ./clone-targets.sh public
#     or: ./clone-targets.sh --tier public
#     or: ./clone-targets.sh (defaults to "all")
TIER="all"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --tier) TIER="$2"; shift 2 ;;
        public|private|all) TIER="$1"; shift ;;
        *) echo "Usage: $0 [--tier public|private|all]"; exit 1 ;;
    esac
done

# ─── Clone ────────────────────────────────────────────────────

echo "Cloning eval targets (tier: $TIER)..."
echo "Clone directory: $CLONE_DIR"
echo ""

mkdir -p "$CLONE_DIR"

count=$(yq '.targets | length' "$TARGETS_YAML")
cloned=0
skipped=0
failed=0

for ((i = 0; i < count; i++)); do
    name=$(yq ".targets[$i].name" "$TARGETS_YAML")
    url=$(yq ".targets[$i].url" "$TARGETS_YAML")
    commit=$(yq ".targets[$i].commit" "$TARGETS_YAML")
    tier=$(yq ".targets[$i].tier" "$TARGETS_YAML")
    local_path=$(yq ".targets[$i].local_path // \"null\"" "$TARGETS_YAML")

    # Tier filter
    if [[ "$TIER" == "public" && "$tier" != "public" ]]; then continue; fi
    if [[ "$TIER" == "private" && "$tier" != "private" ]]; then continue; fi

    target_dir="$CLONE_DIR/$name"

    # Skip local paths
    if [[ "$local_path" != "null" && -d "$local_path" ]]; then
        echo "  $name: local path ($local_path)"
        skipped=$((skipped + 1))
        continue
    fi

    # Check if already at correct commit
    if [[ -d "$target_dir/.git" ]]; then
        current_sha=$(git -C "$target_dir" rev-parse HEAD 2>/dev/null || echo "")
        if [[ "$current_sha" == "$commit" ]]; then
            size=$(du -sh "$target_dir" 2>/dev/null | cut -f1)
            echo "  $name: OK at ${commit:0:12}... ($size)"
            skipped=$((skipped + 1))
            continue
        fi
        echo "  $name: wrong commit, re-cloning..."
        rm -rf "$target_dir"
    fi

    # Clone and checkout
    echo "  $name: cloning..."
    if git clone --quiet "$url" "$target_dir" 2>/dev/null && \
       git -C "$target_dir" checkout --quiet "$commit" 2>/dev/null; then
        size=$(du -sh "$target_dir" 2>/dev/null | cut -f1)
        echo "  $name: cloned at ${commit:0:12}... ($size)"
        cloned=$((cloned + 1))
    else
        echo "  $name: FAILED"
        failed=$((failed + 1))
    fi
done

echo ""
echo "Done: $cloned cloned, $skipped already present, $failed failed"

# Report total disk usage
if [[ -d "$CLONE_DIR" ]]; then
    total_size=$(du -sh "$CLONE_DIR" 2>/dev/null | cut -f1)
    echo "Total disk usage: $total_size ($CLONE_DIR)"
fi
