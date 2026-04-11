# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2026-04-06

### Added

- ADR-016 allocating Aphelion requirements across kernel, boundary, and product ownership (`docs/adrs/ADR-016.md`)
- UID-level requirement allocation audit supporting ADR-016 (`docs/adrs/ADR-016-requirement-allocation-audit.md`)

### Changed

- ADR-001 now selects `capcom` as the product-owned engine kernel and treats Kuzu only as a temporary reference or stand-in
- Agent guidance, ADR enforcement docs, and architecture checks updated to align with the `capcom` kernel decision
- Storage compatibility baseline wording updated from the Kuzu-fork assumption to `capcom` local storage (`docs/compatibility-versions.yaml`)

## [0.1.0] - 2026-04-05

### Added

- ADR conformance rule for Claude Code agents (`.claude/rules/adr-conformance.md`)
- PreToolUse boundary check hook blocking ADR violations at edit time (`.claude/hooks/adr-boundary-check.sh`)
- Pre-commit ADR conformance hook scanning staged files (`scripts/check-adr-conformance.sh`)
- CI `adr-conformance` job validating architecture decisions on every PR
- Stop hook checks for dependency allowlist and compatibility version updates (`.claude/hooks/verify-extra.sh`)
- ADR checkpoint in `/implement` skill (Step 4.25) for plan-phase conformance review
- ADR boundary check in completion verifier agent (Step 2.5)
- Approved extensions registry for ADR-006 (`docs/approved-extensions.yaml`)
- Compatibility version registry for ADR-010 (`docs/compatibility-versions.yaml`)
- Language deviations registry for ADR-004 (`docs/language-deviations.yaml`)
- ADR enforcement system guide (`docs/adr-enforcement.md`)
- Local MADR-format ADR documents (`docs/adrs/ADR-001.md` through `ADR-010.md`)
- Architectural test templates for kernel boundary, distributed code, server layer, and openCypher extension rules (`tests/architecture/`)
