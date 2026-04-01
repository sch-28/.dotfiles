#!/usr/bin/env bash
# pip hardening — supply chain attack mitigation
# pip's attack surface is different: malicious setup.py, typosquatting.
# No postinstall equivalent, but we can enforce virtualenvs and restrict global installs.

set -euo pipefail

if ! command -v pip &>/dev/null && ! command -v pip3 &>/dev/null; then
  echo "  pip not found, skipping"
  exit 0
fi

echo "  Hardening pip..."

PIP_CONF_DIR="$HOME/.config/pip"
PIP_CONF="$PIP_CONF_DIR/pip.conf"

mkdir -p "$PIP_CONF_DIR"

# Write pip config.
# - require-virtualenv: prevents accidental global installs (the most common
#   vector for pip supply chain attacks reaching system Python).
#   Use: pipx for CLI tools, venvs for project deps.
# - no-input: never prompt, fail explicitly instead
if [[ -f "$PIP_CONF" ]]; then
  echo "  $PIP_CONF already exists, checking settings..."
  # Only add settings that are missing
  if ! grep -q 'require-virtualenv' "$PIP_CONF"; then
    if grep -q '^\[global\]' "$PIP_CONF"; then
      sed -i '/^\[global\]/a require-virtualenv = true' "$PIP_CONF"
    else
      printf '\n[global]\nrequire-virtualenv = true\n' >> "$PIP_CONF"
    fi
  fi
  if ! grep -q 'no-input' "$PIP_CONF"; then
    sed -i '/^\[global\]/a no-input = true' "$PIP_CONF"
  fi
else
  cat > "$PIP_CONF" <<'EOF'
[global]
# Prevent installs outside of a virtualenv.
# Forces use of venvs/pipx, reducing blast radius of malicious packages.
# To override: PIP_REQUIRE_VIRTUALENV=false pip install ...
require-virtualenv = true

# Never prompt — fail explicitly
no-input = true
EOF
fi

echo "  pip hardened (via $PIP_CONF)"
