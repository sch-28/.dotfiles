#!/usr/bin/env bash
# bun hardening — supply chain attack mitigation
# Bun has no global config file for ignore-scripts.
# Instead we set up a shell alias and a global bunfig.toml.

set -euo pipefail

if ! command -v bun &>/dev/null; then
  echo "  bun not found, skipping"
  exit 0
fi

echo "  Hardening bun..."

# Bun respects bunfig.toml in ~/.bunfig.toml for global defaults
BUNFIG="$HOME/.bunfig.toml"

# Create or update bunfig.toml with install.ignore-scripts
if [[ -f "$BUNFIG" ]]; then
  # Check if [install] section exists
  if grep -q '^\[install\]' "$BUNFIG"; then
    # Check if ignore-scripts is already set
    if ! grep -q 'ignore-scripts' "$BUNFIG"; then
      sed -i '/^\[install\]/a ignore-scripts = true' "$BUNFIG"
    fi
    # Check if minimumReleaseAge is already set
    if ! grep -q 'minimumReleaseAge' "$BUNFIG"; then
      sed -i '/^\[install\]/a minimumReleaseAge = 259200' "$BUNFIG"
    fi
  else
    # Append [install] section
    printf '\n[install]\nignore-scripts = true\nminimumReleaseAge = 259200\nminimumReleaseAgeExcludes = ["@types/node", "typescript"]\n' >> "$BUNFIG"
  fi
else
  cat > "$BUNFIG" <<'EOF'
[install]
# Block lifecycle scripts (postinstall etc.) by default.
# Override per-project: bun install --ignore-scripts=false
ignore-scripts = true

# Only install package versions published at least 3 days ago.
# Catches staged attacks where malicious versions are published hours before use.
# Value is in seconds: 259200 = 3 days
minimumReleaseAge = 259200
minimumReleaseAgeExcludes = ["@types/node", "typescript"]
EOF
fi

echo "  bun hardened (via ~/.bunfig.toml)"
