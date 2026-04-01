#!/usr/bin/env bash
# pnpm hardening — supply chain attack mitigation
# pnpm is more secure by default (strict node_modules, content-addressable store)
# but postinstall hooks are still the main risk

set -euo pipefail

if ! command -v pnpm &>/dev/null; then
  echo "  pnpm not found, skipping"
  exit 0
fi

echo "  Hardening pnpm..."

# Block lifecycle scripts globally.
# Override per-project in .npmrc or: pnpm install --ignore-scripts=false
pnpm config set ignore-scripts true

# Auto-install peer deps to avoid issues when scripts are disabled
pnpm config set auto-install-peers true

# Resolve peer dep version conflicts without failing
pnpm config set strict-peer-dependencies false

echo "  pnpm hardened"
echo ""
echo "  Note: pnpm supports minimumReleaseAge (v10.16.0+) but it must be set"
echo "  per-project in pnpm-workspace.yaml, not globally. Add to your projects:"
echo "    minimumReleaseAge: 4320  # 3 days in minutes"
