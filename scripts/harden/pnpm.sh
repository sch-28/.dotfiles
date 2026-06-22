#!/usr/bin/env bash
# pnpm hardening — supply chain attack mitigation
# Reference: https://pnpm.io/supply-chain-security
# To override scripts per-install: pnpm install --allow-build=<pkg>

set -euo pipefail

if ! command -v pnpm &>/dev/null; then
  echo "  pnpm not found, skipping"
  exit 0
fi

echo "  Hardening pnpm..."

# Block all postinstall/preinstall lifecycle scripts by default.
# Packages that need build scripts must be explicitly listed via allowBuilds
# in pnpm-workspace.yaml. Never use dangerouslyAllowAllBuilds=true.
pnpm config set ignore-scripts true

# Block transitive dependencies sourced via git repos or tarball URLs.
# All deps must come from a trusted registry; exotic sources are a common
# vector in staged supply chain attacks.
pnpm config set blockExoticSubdeps true

# Require packages to have been published for at least 24 hours (1440 minutes)
# before they can be installed. Catches same-day malicious publishes — high-profile
# npm compromises are typically detected and unpublished within hours.
pnpm config set minimumReleaseAge 1440

# Warn (but don't block) when a package loses provenance attestation vs earlier versions.
# no-downgrade is too aggressive in practice — legitimate packages frequently republish
# without attestation, causing false positives.
pnpm config set trustPolicy warn

echo "  pnpm hardened"
