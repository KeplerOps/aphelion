# ADR-016 Requirement Allocation Audit

- **Date**: 2026-04-06
- **Scope**: allocate the current Aphelion requirement set across the kernel repo, the product/kernel boundary, and the product repo
- **Inputs reviewed**:
  - `notes/reqs/01-APH-DM-data-model.md`
  - `notes/reqs/02-APH-QL-query-language.md`
  - `notes/reqs/03-APH-SCH-schema-indexes.md`
  - `notes/reqs/04-APH-TXN-transactions-consistency.md`
  - `notes/reqs/05-APH-CAT-database-catalog.md`
  - `notes/reqs/06-APH-API-protocols-drivers.md`
  - `notes/reqs/07-APH-SEC-security-access-control.md`
  - `notes/reqs/08-APH-HA-clustering-availability.md`
  - `notes/reqs/09-APH-OPS-operations-observability.md`
  - `notes/reqs/10-APH-DIO-data-movement-backup-cdc.md`
  - `notes/reqs/11-APH-EXT-procedures-extensions.md`
  - `notes/reqs/12-APH-TOOL-operator-developer-tools.md`
  - `notes/reqs/13-APH-PERF-planning-runtime.md`
  - `notes/reqs/14-APH-STO-storage-durability.md`
  - `docs/adrs/ADR-002.md`
  - `docs/adrs/ADR-006.md`
  - `docs/adrs/ADR-007.md`
  - `docs/adrs/ADR-012.md`
  - `docs/adrs/ADR-013.md`
  - `docs/adrs/ADR-014.md`

## Definitions

- `kernel-owned`: implementation should primarily land in the future kernel repo. The product repo mainly adapts or consumes the capability.
- `boundary-owned`: the requirement crosses the engine/product boundary. The kernel and product repos both carry implementation work, and issues should usually be paired.
- `product-owned`: implementation should primarily land in the Aphelion product repo. The kernel may expose supporting primitives, but it does not own the requirement.
- `aggregate`: umbrella requirements (`*-000`) that summarize a family. They are not separately actionable and inherit the mixed ownership of their children.

## Summary

Actionable requirement counts:

- `kernel-owned`: 133
- `boundary-owned`: 71
- `product-owned`: 118
- `aggregate`: 14

Family summary:

| Prefix | Kernel | Boundary | Product | Notes |
|---|---:|---:|---:|---|
| `APH-DM` | 26 | 0 | 0 | Core engine data model. |
| `APH-QL` | 28 | 5 | 1 | Query semantics are mostly kernel-owned; admin/introspection and compatibility-baseline publication are not. |
| `APH-SCH` | 27 | 1 | 0 | Schema/index internals are engine-owned; privilege-controlled schema operations cross the boundary. |
| `APH-TXN` | 11 | 7 | 0 | Core ACID and durability are kernel-owned; client-visible retry/bookmark/error surfaces are boundary-owned. |
| `APH-CAT` | 0 | 11 | 12 | No pure kernel ownership because DBMS-level catalog authority is product-owned by ADR-013. |
| `APH-API` | 0 | 9 | 17 | External protocols and drivers are not kernel-owned by ADR-007/ADR-012. |
| `APH-SEC` | 0 | 6 | 26 | Security metadata and auth flows are product-owned; privilege enforcement against graph execution crosses the boundary. |
| `APH-HA` | 0 | 0 | 23 | Product-layer and later distributed work. Not kernel-owned in the current architecture. |
| `APH-OPS` | 0 | 5 | 15 | Operator workflows are product-owned; a few operational hooks depend on engine primitives. |
| `APH-DIO` | 12 | 12 | 4 | Import/CDC core is engine-heavy; backup/restore and policy surfaces are mixed. |
| `APH-EXT` | 10 | 4 | 4 | UDF/runtime capability is engine-heavy; extension policy and packaging are product-owned by ADR-006. |
| `APH-TOOL` | 0 | 0 | 16 | Entirely product-layer. |
| `APH-PERF` | 12 | 3 | 0 | Planning/runtime behavior is engine-owned; explicit control and termination surfaces cross the boundary. |
| `APH-STO` | 7 | 8 | 0 | Recovery/storage internals are engine-owned; operator-facing storage workflows are boundary-owned. |

## Aggregate Umbrella Requirements

The `*-000` requirements are family summaries, not direct implementation items:

- `APH-DM-000`
- `APH-QL-000`
- `APH-SCH-000`
- `APH-TXN-000`
- `APH-CAT-000`
- `APH-API-000`
- `APH-SEC-000`
- `APH-HA-000`
- `APH-OPS-000`
- `APH-DIO-000`
- `APH-EXT-000`
- `APH-TOOL-000`
- `APH-PERF-000`
- `APH-STO-000`

## Kernel-Owned Requirements

- `APH-DM-001..026`
- `APH-QL-001..004`
- `APH-QL-007..018`
- `APH-QL-020..026`
- `APH-QL-028`
- `APH-QL-030..033`
- `APH-SCH-001..027`
- `APH-TXN-001..004`
- `APH-TXN-006..009`
- `APH-TXN-016..018`
- `APH-DIO-001`
- `APH-DIO-003..012`
- `APH-DIO-021`
- `APH-EXT-002..004`
- `APH-EXT-006..007`
- `APH-EXT-009`
- `APH-EXT-013..015`
- `APH-EXT-017`
- `APH-PERF-001..005`
- `APH-PERF-007..011`
- `APH-PERF-014..015`
- `APH-STO-001..005`
- `APH-STO-010`
- `APH-STO-014`

## Boundary-Owned Requirements

- `APH-QL-005..006`
- `APH-QL-019`
- `APH-QL-027`
- `APH-QL-029`
- `APH-SCH-028`
- `APH-TXN-005`
- `APH-TXN-010..015`
- `APH-CAT-001..002`
- `APH-CAT-004`
- `APH-CAT-006..008`
- `APH-CAT-015..017`
- `APH-CAT-021..022`
- `APH-API-004..007`
- `APH-API-009..011`
- `APH-API-016..017`
- `APH-SEC-013..018`
- `APH-OPS-010`
- `APH-OPS-012`
- `APH-OPS-014`
- `APH-OPS-017`
- `APH-OPS-019`
- `APH-DIO-002`
- `APH-DIO-013..016`
- `APH-DIO-018..020`
- `APH-DIO-022..024`
- `APH-DIO-027`
- `APH-EXT-001`
- `APH-EXT-011..012`
- `APH-EXT-016`
- `APH-PERF-006`
- `APH-PERF-012..013`
- `APH-STO-006..009`
- `APH-STO-011..013`
- `APH-STO-015`

## Product-Owned Requirements

- `APH-QL-034`
- `APH-CAT-003`
- `APH-CAT-005`
- `APH-CAT-009..014`
- `APH-CAT-018..020`
- `APH-CAT-023`
- `APH-API-001..003`
- `APH-API-008`
- `APH-API-012..015`
- `APH-API-018..026`
- `APH-SEC-001..012`
- `APH-SEC-019..032`
- `APH-HA-001..023`
- `APH-OPS-001..009`
- `APH-OPS-011`
- `APH-OPS-013`
- `APH-OPS-015..016`
- `APH-OPS-018`
- `APH-OPS-020`
- `APH-DIO-017`
- `APH-DIO-025..026`
- `APH-DIO-028`
- `APH-EXT-005`
- `APH-EXT-008`
- `APH-EXT-010`
- `APH-EXT-018`
- `APH-TOOL-001..016`

## Why the Split Looks Like This

The decisive architectural constraints were already accepted before this audit:

- `ADR-007` keeps the public API, auth, audit, and observability at the product-server layer rather than in the raw kernel.
- `ADR-012` chooses a co-located out-of-process engine node, which means public protocols, drivers, and operator-facing control surfaces are not kernel-owned.
- `ADR-013` splits authority so the product owns DBMS-level catalog, security, compatibility, extension-policy, audit, and future topology metadata, while the engine owns per-database schema/index, storage/recovery, and internal transactional/runtime metadata.
- `ADR-006` makes extension review, packaging, and policy product-owned, even though UDF/runtime capability still needs kernel implementation.

That combination is why the families that looked obviously engine-ish at first pass do not all belong in the kernel repo.

## Findings and Edge Cases

1. `APH-CAT` is not a kernel family.
   `ADR-013` makes DBMS-level catalog authority product-owned. The kernel will still need lifecycle and per-database hooks, but there are no pure `APH-CAT-*` kernel-owned requirements in the current architecture.

2. `APH-API` is not a kernel family.
   The kernel must support sessions, transactions, streaming, typing, and summaries, but the public protocols, URI schemes, routing behavior, driver artifacts, and connection management are product concerns.

3. `APH-SEC` is mostly product-owned, not kernel-owned.
   User stores, auth providers, TLS, role metadata, and audit/event logging live above the kernel. The engine only owns the execution-time enforcement side of privileges, not the whole security model.

4. `APH-HA` is entirely product-owned and presently deferred from kernel ownership.
   The current accepted architecture is single-node-first and explicitly defers the replication/HA mechanism choice. `APH-HA-*` should not be used to drive the initial kernel backlog.

5. `APH-DIO` and `APH-EXT` are genuinely mixed families.
   The importer/CDC/UDF/runtime portions belong in the kernel repo. Artifact handling, cloud/object-store integration, extension review policy, and packaging do not.

6. `APH-STO` is split between deep engine work and operator workflows.
   Recovery, WAL, checkpointing, space reuse, and stable external identity are kernel responsibilities. Store reporting, compatibility disclosure, consistency tooling, and migration/compaction workflows are boundary concerns.

## Requirements That Need Clarification

1. `APH-EXT-008` and `APH-EXT-010`
   The current wording suggests a more permissive runtime extension model than `ADR-006` allows. Those requirements should either be tightened or explicitly interpreted as product-reviewed deployment only.

2. `APH-QL-029`
   This combines schema/procedure introspection, DBMS metadata, security metadata, and cluster topology in one requirement. It is boundary-owned, but it would be cleaner to split it by authority domain.

3. `APH-DIO-019`
   Backup artifacts that include catalog and security metadata cross the product/kernel authority split from `ADR-013`. That requirement is valid, but the authoritative source of those metadata slices must be explicit before implementation planning.

4. `APH-CAT-019..020` and `APH-HA-021..022`
   Partition/shard requirements exist in the requirement set now, but they should not drive the initial kernel repo backlog until the distributed/kernel-topology direction is intentionally chosen.
