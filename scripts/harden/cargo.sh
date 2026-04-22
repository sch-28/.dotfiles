#!/usr/bin/env bash
# cargo hardening — supply chain attack mitigation
# Rust's build.rs is the equivalent of postinstall, but it's compiled Rust code
# (not arbitrary shell), so the risk profile is different.
# Main hardening: audit dependencies, use git CLI for fetches, limit network exposure.

set -euo pipefail

if ! command -v cargo &>/dev/null; then
  echo "  cargo not found, skipping"
  exit 0
fi

echo "  Hardening cargo..."

CARGO_CONFIG_DIR="$HOME/.cargo"
CARGO_CONFIG="$CARGO_CONFIG_DIR/config.toml"

mkdir -p "$CARGO_CONFIG_DIR"

# Build config additions — only add sections that don't exist yet
add_if_missing() {
  local section="$1"
  local content="$2"
  if [[ -f "$CARGO_CONFIG" ]] && grep -q "^\[$section\]" "$CARGO_CONFIG"; then
    echo "  [$section] already exists, skipping"
  else
    printf '\n[%s]\n%s\n' "$section" "$content" >> "$CARGO_CONFIG"
  fi
}

# Create the file if it doesn't exist
touch "$CARGO_CONFIG"

# Use system git for fetches — better SSH key handling, respects system git config
add_if_missing "net" 'git-fetch-with-cli = true'

# Install cargo-audit if not present — dependency vulnerability scanner
if ! command -v cargo-audit &>/dev/null; then
  echo "  Installing cargo-audit..."
  if ! cargo install cargo-audit; then
    echo "  Warning: cargo-audit install failed (network issue?), skipping"
  fi
fi

echo "  cargo hardened"
echo "  Tip: run 'cargo audit' periodically in your Rust projects"
