#!/usr/bin/env bash
# harden.sh — harden all package managers against supply chain attacks
# Runs individual hardening scripts for each package manager.
# Safe to run multiple times (idempotent).
#
# Usage: bash scripts/harden/harden.sh
#
# What this does:
#   npm/pnpm:  ignore-scripts=true, save-exact, audit-level
#   bun:       ignore-scripts + minimumReleaseAge via ~/.bunfig.toml
#   pip:       require-virtualenv, no-input
#   cargo:     git-fetch-with-cli, installs cargo-audit
#
# After running, lifecycle scripts (postinstall etc.) are blocked by default.
# To override for a specific install:
#   npm install --ignore-scripts=false
#   pnpm install --ignore-scripts=false
#   bun install --ignore-scripts=false

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

green='\033[0;32m'
yellow='\033[0;33m'
reset='\033[0m'

echo ""
echo "========================================="
echo " Package Manager Hardening"
echo "========================================="
echo ""

managers=(npm pnpm bun pip cargo)
hardened=0
skipped=0

for pm in "${managers[@]}"; do
  script="$SCRIPT_DIR/$pm.sh"
  if [[ -f "$script" ]]; then
    if bash "$script"; then
      hardened=$((hardened + 1))
    fi
  else
    echo -e "  ${yellow}No script found for $pm${reset}"
    skipped=$((skipped + 1))
  fi
  echo ""
done

echo "========================================="
echo -e " ${green}Done.${reset} Hardened: $hardened | Skipped (not installed): $skipped"
echo "========================================="
echo ""
echo "Remember: lifecycle scripts are now blocked by default."
echo "Override per-install when needed:"
echo "  npm install --ignore-scripts=false"
echo "  pnpm install --ignore-scripts=false"
echo "  bun install --ignore-scripts=false"
echo ""
