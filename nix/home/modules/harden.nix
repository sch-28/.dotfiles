# Package-manager supply-chain hardening — declarative version of
# scripts/harden/*.sh. Blocks lifecycle scripts (the #1 npm attack vector),
# enforces release-age delays (catches same-day malicious publishes), and limits
# blast radius. These files are read-only (nix store) so the hardening can't be
# silently weakened — put auth tokens in PROJECT .npmrc or env (NPM_TOKEN), not
# the global config.
{ ... }:
{
  home.file = {
    # npm — block postinstall hooks, pin exact versions, warn on vulns.
    ".npmrc".text = ''
      ignore-scripts=true
      save-exact=true
      audit-level=moderate
      fund=false
    '';

    # pnpm (global) — block scripts + exotic (git/tarball) subdeps + same-day
    # publishes (24h min age); warn on lost provenance attestation.
    ".config/pnpm/rc".text = ''
      ignore-scripts=true
      blockExoticSubdeps=true
      minimumReleaseAge=1440
      trustPolicy=warn
    '';

    # bun — block scripts + 3-day min release age (excl. low-risk type pkgs).
    ".bunfig.toml".text = ''
      [install]
      ignore-scripts = true
      minimumReleaseAge = 259200
      minimumReleaseAgeExcludes = ["@types/node", "typescript"]
    '';

    # pip — force virtualenvs so a malicious package can't reach system Python.
    ".config/pip/pip.conf".text = ''
      [global]
      require-virtualenv = true
      no-input = true
    '';

    # cargo — fetch crates via system git (better key handling). cargo-audit is
    # provided as a package (heavy tier) instead of `cargo install`.
    ".cargo/config.toml".text = ''
      [net]
      git-fetch-with-cli = true
    '';
  };
}
