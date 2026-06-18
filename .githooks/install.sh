#!/bin/bash
#
# Install Fladder-Custom git hooks
#
# Configures git to use .githooks/ as the hooks directory.
# This script only needs to be run once per clone.
#
# Usage: bash .githooks/install.sh

set -e

HOOKS_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$HOOKS_DIR/.." && pwd)"

echo "Installing git hooks for Fladder-Custom..."
echo "  Hooks directory: ${HOOKS_DIR}"

# Configure git to use .githooks as the hooks path
git config core.hooksPath ".githooks"

echo ""
echo "✓ Hooks installed successfully."
echo ""
echo "Available hooks:"
for hook in "$HOOKS_DIR"/*; do
    [ -f "$hook" ] && [ -x "$hook" ] && echo "  - $(basename "$hook")"
done
echo ""
echo "To verify: git config core.hooksPath"
echo "To uninstall: git config --unset core.hooksPath"
