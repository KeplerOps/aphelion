# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-04-11

### Added

- Gradle 8.12 build system with Java 21 toolchain (`build.gradle.kts`, `settings.gradle.kts`)
- JUnit 5, Testcontainers, jqwik, ArchUnit test dependencies
- Spotless code formatting with Google Java Format
- Error Prone compile-time checks
- SpotBugs static analysis
- Source layout: `com.keplerops.aphelion.{domain,api,infrastructure.engine}` packages
- ArchUnit architecture tests replacing `.pseudo` specs:
  - `KernelBoundaryTest` (ADR-002, ADR-007)
  - `NoDistributedCodeTest` (ADR-003, ADR-005, ADR-009)
  - `ServerLayerRequiredTest` (ADR-007)
  - `OpenCypherExtensionsMarkedTest` (ADR-004, ADR-008)
- CI lint job: Spotless format check and SpotBugs analysis
- CI test job: full Gradle build including ArchUnit tests
- V1 work order with sequenced checklists for capcom and aphelion repos (`notes/work-order.md`)

### Changed

- ADR enforcement scripts updated for Gradle Java source layout (path patterns broadened)
- `docs/approved-extensions.yaml` populated with ADR-011 baseline toolchain
- `CLAUDE.md` build section updated with Gradle commands
- `docs/CODING_STANDARDS.md` filled in tech-stack-dependent sections
- `docs/adr-enforcement.md` control inventory includes ArchUnit tests

### Removed

- Architecture test `.pseudo` spec files (replaced by real ArchUnit tests)

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
