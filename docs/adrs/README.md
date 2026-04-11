# Architecture Decision Records

ADRs are mastered in [Ground Control](https://groundcontrol.dev) (project identifier: `aphelion`). Use `gc_list_adrs` to fetch the authoritative versions. These local copies exist for offline reference and agent consumption.

## Format

Each ADR follows the [MADR](https://adr.github.io/madr/) (Markdown Any Decision Record) format with the following additions:

- **Enforcement Controls** -- lists the automated controls (hooks, CI jobs, architecture tests) that enforce the decision, with file paths.
- **Override Procedure** -- standard process for deliberate deviations.

## Syncing with Ground Control

To update these local copies:

1. Fetch the current ADR list from Ground Control via MCP: `gc_list_adrs` (project: `aphelion`).
2. Fetch each ADR's full content with `gc_get_adr`.
3. Overwrite the corresponding local file (`ADR-NNN.md`).

Do not edit these files by hand. Ground Control is the source of truth.

## Index

| ADR | Title | Status |
|-----|-------|--------|
| [ADR-001](ADR-001.md) | Build capcom as the Product-Owned Engine Kernel | Accepted |
| [ADR-002](ADR-002.md) | Keep the Product Architecture Separate from the Engine Kernel | Accepted |
| [ADR-003](ADR-003.md) | Deliver a Strong Single-Node Product Before Distributed HA | Accepted |
| [ADR-004](ADR-004.md) | Use openCypher as the Initial Language Compatibility Baseline | Accepted |
| [ADR-005](ADR-005.md) | Preserve a Single-Node Local Storage and Transaction Model in V1 | Accepted |
| [ADR-006](ADR-006.md) | Control Extensions Through Product-Owned Review and Packaging | Accepted |
| [ADR-007](ADR-007.md) | Expose the Product as a Server, Not as the Raw Embedded Kernel API | Accepted |
| [ADR-008](ADR-008.md) | Defer the Public Wire Protocol Choice | Accepted |
| [ADR-009](ADR-009.md) | Defer the Replication and HA Mechanism Choice | Accepted |
| [ADR-010](ADR-010.md) | Define and Version Compatibility Surfaces From the First External Release | Accepted |
| [ADR-011](ADR-011.md) | Use Java 21 and a JVM-Native Toolchain for the Product Server and Control Layers | Accepted |
| [ADR-012](ADR-012.md) | Use a Co-Located Out-of-Process Engine Node | Accepted |
| [ADR-013](ADR-013.md) | Split Catalog and Metadata Authority Between the Product and the Engine | Accepted |
| [ADR-014](ADR-014.md) | Use a Capability-Oriented Internal Engine-Node Contract | Accepted |
| [ADR-015](ADR-015.md) | Use Layered Conformance and Verification Harnesses | Accepted |
| [ADR-016](ADR-016.md) | Allocate Aphelion Requirement Ownership Across Kernel, Boundary, and Product Layers | Accepted |
