#!/usr/bin/env bash
# npm hardening — supply chain attack mitigation
# Key defense: ignore-scripts blocks postinstall hooks (the #1 npm attack vector)
# To override per-install: npm install --ignore-scripts=false

set -euo pipefail

if ! command -v npm &>/dev/null; then
  echo "  npm not found, skipping"
  exit 0
fi

echo "  Hardening npm..."

# Block postinstall/preinstall lifecycle scripts by default.
# This is the single most effective defense against supply chain attacks
# like the axios@1.14.1 compromise (postinstall RAT dropper).
# When you need scripts (e.g. esbuild, sharp): npm install --ignore-scripts=false
npm config set ignore-scripts true

# Don't auto-resolve to latest on version conflicts during install
npm config set save-exact true

# Require packages to have been published for at least 3 days.
# Catches staged attacks where malicious versions are published hours before use.
npm config set min-release-age 3

# Set audit level — warn on moderate+ vulnerabilities during install
npm config set audit-level moderate

# Disable funding messages (noise reduction)
npm config set fund false

echo "  npm hardened"
