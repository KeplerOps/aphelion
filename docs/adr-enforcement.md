# ADR Enforcement System

This document is the authoritative reference for how Aphelion's Architecture Decision Records (ADRs) are enforced through automated controls. It covers what each control does, which ADRs it enforces, how to work with the controls, and how to maintain them as the project evolves.

## Overview

Aphelion has 15 accepted ADRs that define the product's architectural boundaries. These are mastered in Ground Control (project: `aphelion`) with local copies in `docs/adrs/`.

ADRs are enforced through layered controls so that the path of least resistance for a coding agent or developer is to follow the architectural decisions. Controls are organized by enforcement strength:

1. **Hard blocks** — prevent violations at edit time, commit time, or PR time
2. **Soft guidance** — inform agents and developers of the rules during every session
3. **Auditable artifacts** — make decisions visible and traceable

This layered approach means a violation must bypass multiple independent checks to reach production. ADR-011 through ADR-015 currently rely more heavily on explicit guidance, planning checkpoints, and verification strategy than on bespoke hard-block hooks.

## Control Inventory

| Control | File | Type | Trigger | Strength | ADRs |
|---------|------|------|---------|----------|------|
| ADR conformance rule | `.claude/rules/adr-conformance.md` | Claude Code rule | Every session | Soft | All |
| Boundary check hook | `.claude/hooks/adr-boundary-check.sh` | PreToolUse hook | Edit/Write | Hard block | 001-003, 005, 007-009 |
| Stop hook checks | `.claude/hooks/verify-extra.sh` | Stop hook | Session end (after /implement) | Hard block | 002, 006, 010 |
| Pre-commit script | `scripts/check-adr-conformance.sh` | Pre-commit hook | `git commit` | Hard block | 001, 003, 005, 006, 008, 009 |
| CI conformance job | `.github/workflows/ci.yml` (adr-conformance) | CI job | PR/push | Hard block | All |
| Implement skill checkpoint | `.claude/skills/implement/SKILL.md` Step 4.25 | Skill | Plan phase | Soft | All |
| Completion verifier | `.claude/agents/completion-verifier.md` Step 2.5 | Agent | Session end | Soft | 002, 006, 010 |
| Extensions registry | `docs/approved-extensions.yaml` | Manifest | Manual | Audit trail | 006 |
| Compatibility versions | `docs/compatibility-versions.yaml` | Manifest | Manual | Audit trail | 010 |
| Language deviations | `docs/language-deviations.yaml` | Manifest | Manual | Audit trail | 004 |

## Per-ADR Enforcement Detail

### ADR-001: Kuzu Fork as Engine Kernel

**What it decides**: The only permitted engine kernel is a Kuzu fork. MillenniumDB, Graphflow, and greenfield implementations are rejected.

**What violation looks like**:
- Importing or depending on `millenniumdb` or `graphflow` in any source file
- Adding a dependency on an alternative graph engine
- Building a custom graph engine from scratch (new storage layer, new query processor) rather than using the Kuzu fork

**How it's enforced**:
- **Edit/Write time**: `adr-boundary-check.sh` blocks content containing `millenniumdb` or `graphflow`
- **Commit time**: `check-adr-conformance.sh` scans staged files for banned engine references
- **PR time**: CI `adr-conformance` job runs the same checks
- **Every session**: `adr-conformance.md` rule instructs agents to never use banned engines

**Override**: `# adr-override: ADR-001 — <rationale>`

**If superseded**: Remove banned engine patterns from `adr-boundary-check.sh`, `check-adr-conformance.sh`, and update the `adr-conformance.md` rule.

---

### ADR-002: Product Architecture Owns Boundaries

**What it decides**: The product architecture owns system boundaries. The Kuzu kernel is an internal subsystem behind product-defined interfaces.

**What violation looks like**:
- Importing Kuzu types (`kuzu::`, `from kuzu import`) in `src/domain/` or `src/api/`
- Exposing kernel transaction objects or engine handles in public APIs
- Letting security, audit, or metadata logic live in the kernel layer

**How it's enforced**:
- **Edit/Write time**: `adr-boundary-check.sh` blocks kernel imports in domain/API layers
- **Session end**: `verify-extra.sh` warns when both API/domain and engine layers change in the same session
- **Plan phase**: `/implement` Step 4.25 checks plans for kernel type exposure
- **Session end**: Completion verifier Step 2.5 scans for kernel imports in domain/API files
- **Architecture tests** (when active): `test_kernel_boundary` verifies import rules

**Override**: `# adr-override: ADR-002 — <rationale>`

**If superseded**: Update boundary check patterns in `adr-boundary-check.sh`, remove cross-layer warning from `verify-extra.sh`, update `adr-conformance.md` rule.

---

### ADR-003: Single-Node Product First

**What it decides**: V1 is single-node only. Distributed consensus, replication, failover, distributed transactions, and cross-node queries are out of scope.

**What violation looks like**:
- Defining functions or classes with names like `raft_consensus`, `leader_election`, `cluster_coordinator`, `distributed_txn`
- Adding distributed systems libraries as dependencies
- Writing code that assumes or coordinates multiple nodes

**How it's enforced**:
- **Edit/Write time**: `adr-boundary-check.sh` blocks distributed primitive patterns in non-comment code
- **Commit time**: `check-adr-conformance.sh` scans for distributed primitives
- **PR time**: CI `adr-conformance` job runs the same checks
- **Plan phase**: `/implement` Step 4.25 checks for distributed code in plans
- **Architecture tests** (when active): `test_no_distributed_code` verifies no distributed types outside feature gates

**Override**: `# adr-override: ADR-003 — <rationale>`

**If superseded**: Remove distributed primitive patterns from `adr-boundary-check.sh` and `check-adr-conformance.sh`, update the rule. This will likely coincide with a new ADR selecting a specific replication/HA mechanism.

---

### ADR-004: openCypher as Initial Language Baseline

**What it decides**: openCypher is the query language baseline. Extensions must be explicitly marked. No second query language. No silent redefinition of openCypher semantics.

**What violation looks like**:
- Adding a Gremlin, SPARQL, SQL, or GQL parser
- Implementing a function that redefines openCypher behavior without documentation
- Adding a product-specific extension without marking it in code and in `language-deviations.yaml`

**How it's enforced**:
- **Every session**: `adr-conformance.md` rule instructs agents to mark extensions and update the deviations registry
- **Audit trail**: `docs/language-deviations.yaml` records every deviation
- **Architecture tests** (when active): `test_opencypher_extensions_marked` verifies extension markers

**Override**: Not typically needed — deviations are managed through the registry, not overrides.

---

### ADR-005: Single-Node Local Storage and Transaction Model in V1

**What it decides**: V1 uses single-node local persistent storage and single-node transactions. No distributed transactions, shared storage, or log shipping.

**What violation looks like**:
- Same as ADR-003 (distributed primitives), plus: `two_phase_commit`, `log_shipping`, `shared_storage`
- Implementing a remote storage backend
- Adding cross-node transaction coordination

**How it's enforced**: Same controls as ADR-003 (shared pattern set).

**Override**: `# adr-override: ADR-005 — <rationale>`

---

### ADR-006: Extension Allowlist

**What it decides**: All extensions and engine-adjacent dependencies must pass product-owned review. An allowlist is maintained.

**What violation looks like**:
- Adding a dependency to `Cargo.toml`, `package.json`, `pyproject.toml`, etc. without adding an entry to `docs/approved-extensions.yaml`
- Loading extensions from unmanaged or public sources at runtime
- Using a GPL-licensed dependency without explicit approval

**How it's enforced**:
- **Session end**: `verify-extra.sh` blocks if dependency files changed without allowlist update
- **Commit time**: `check-adr-conformance.sh` checks dependency files vs. allowlist
- **PR time**: CI validates `approved-extensions.yaml` exists and is valid YAML
- **Plan phase**: `/implement` Step 4.25 checks for unapproved dependencies
- **Session end**: Completion verifier Step 2.5 flags dependency changes without allowlist update
- **Audit trail**: `docs/approved-extensions.yaml` records every approved extension

**Override**: Not applicable — use the allowlist process instead.

---

### ADR-007: Server, Not Embedded Library

**What it decides**: The product is a server process. Raw kernel API is internal. Auth, audit, observability attach at the server layer.

**What violation looks like**:
- Exporting kernel types in public API signatures
- Putting authentication logic in the kernel layer
- Creating a public embedded library API that bypasses the server

**How it's enforced**:
- **Edit/Write time**: `adr-boundary-check.sh` blocks kernel imports in API layer (same patterns as ADR-002)
- **Plan phase**: `/implement` Step 4.25 checks for kernel type exposure
- **Architecture tests** (when active): `test_server_layer_required` verifies public functions are in API layer

**Override**: `# adr-override: ADR-007 — <rationale>` (rarely needed — typically indicates an architecture problem)

---

### ADR-008: Defer Wire Protocol Choice

**What it decides**: No public wire protocol commitment yet. Internal interfaces OK. Protocol selection deferred.

**What violation looks like**:
- Importing `bolt_protocol`, `postgres_wire`, `pgwire`, or `grpc` service definitions in `src/domain/`
- Treating an internal protocol as the permanent external contract
- Documenting a specific protocol as the product's wire protocol

**How it's enforced**:
- **Edit/Write time**: `adr-boundary-check.sh` blocks protocol-specific imports in domain layer
- **Commit time**: `check-adr-conformance.sh` checks domain files for protocol imports
- **PR time**: CI runs the same checks
- **Plan phase**: `/implement` Step 4.25 checks for protocol commitments

**Override**: `# adr-override: ADR-008 — <rationale>`

**If superseded**: This ADR will be superseded when a protocol is selected via a new ADR. Remove protocol patterns from domain-layer checks, add the chosen protocol to the compatibility surfaces in `compatibility-versions.yaml`.

---

### ADR-009: Defer Replication/HA Mechanism

**What it decides**: No specific replication or HA mechanism is selected. Boundaries must be preserved for future work.

**What violation looks like**: Same as ADR-003 (distributed primitives). Additionally: implementing a specific replication protocol without a new ADR authorizing it.

**How it's enforced**: Same controls as ADR-003 (shared pattern set).

**Override**: `# adr-override: ADR-009 — <rationale>`

---

### ADR-010: Compatibility Surface Versioning

**What it decides**: Four compatibility surfaces are versioned independently: query language, storage format, backup/export format, extension API.

**What violation looks like**:
- Changing query language behavior without updating `docs/compatibility-versions.yaml`
- Modifying storage format without a version bump
- Breaking backup/export compatibility silently

**How it's enforced**:
- **Session end**: `verify-extra.sh` blocks if compatibility-surface files changed without version registry update
- **PR time**: CI validates `compatibility-versions.yaml` exists and is valid YAML
- **Plan phase**: `/implement` Step 4.25 checks for surface changes without version tracking
- **Session end**: Completion verifier Step 2.5 flags surface changes without registry update
- **Audit trail**: `docs/compatibility-versions.yaml` records all surface versions

**Override**: Not applicable — use the version registry instead.

---

### ADR-011: Java 21 Product Stack

**What it decides**: Product server and control layers use Java 21. The engine kernel remains native. Performance validation at the boundary is mandatory.

**What violation looks like**:
- Replacing the product stack with a different language without a superseding ADR
- Treating "native kernel" as permission to skip latency, throughput, or memory measurement

**How it's enforced**:
- **Every session**: `adr-conformance.md` reminds agents of the Java 21 + native-kernel split
- **Plan phase**: `/implement` Step 4.25 checks proposed work against the accepted ADR set
- **Session end**: completion verifier Step 2.5 supplements architectural warnings

**Override**: `# adr-override: ADR-011 — <rationale>`

---

### ADR-012: Co-Located Out-of-Process Engine Node

**What it decides**: The engine runs as a separate co-located process behind a product-owned internal interface.

**What violation looks like**:
- Treating in-process embedding as the product architecture
- Designing the product around a remote engine service before the current scope requires it

**How it's enforced**:
- **Every session**: `adr-conformance.md` reminds agents that the engine is out-of-process
- **Plan phase**: `/implement` Step 4.25 checks proposed work against the accepted ADR set
- **Architecture tests** (when active): `test_server_layer_required` and `test_kernel_boundary`

**Override**: `# adr-override: ADR-012 — <rationale>`

---

### ADR-013: Split Catalog and Metadata Authority

**What it decides**: Product owns DBMS/control-plane metadata. Engine owns database-local transactional and physical metadata.

**What violation looks like**:
- Duplicating authority for the same metadata class in both product and engine
- Moving engine-owned schema or recovery metadata into the product control plane by default

**How it's enforced**:
- **Every session**: `adr-conformance.md` explains metadata authority boundaries
- **Plan phase**: `/implement` Step 4.25 checks proposed work against the accepted ADR set
- **Architecture tests** (when active): `test_kernel_boundary`

**Override**: `# adr-override: ADR-013 — <rationale>`

---

### ADR-014: Capability-Oriented Internal Engine-Node Contract

**What it decides**: The internal engine-node contract is product-owned, capability-oriented, handle-based, and streaming-first.

**What violation looks like**:
- Mirroring raw kernel APIs or classes directly into the product layer
- Making the contract object-graph-oriented or materialization-first by default

**How it's enforced**:
- **Every session**: `adr-conformance.md` explains the contract shape
- **Plan phase**: `/implement` Step 4.25 checks proposed work against the accepted ADR set
- **Architecture tests** (when active): `test_kernel_boundary`

**Override**: `# adr-override: ADR-014 — <rationale>`

---

### ADR-015: Layered Conformance and Verification Harnesses

**What it decides**: Compatibility and correctness claims are backed by layered executable harnesses rather than by ad hoc testing or the openCypher TCK alone.

**What violation looks like**:
- Claiming support for a compatibility surface without an executable verification path
- Relying on a single TCK or black-box integration suite as the entire verification strategy

**How it's enforced**:
- **Every session**: `adr-conformance.md` reminds agents that compatibility claims need harnesses
- **Plan phase**: `/implement` Step 4.25 and Step 14 enforce test-planning and test-quality review
- **Session end**: completion verifier Step 2.5 adds informational architectural warnings
- **PR time**: CI remains the hard gate for any enforceable automated checks

**Override**: `# adr-override: ADR-015 — <rationale>`

---

## Working With the Controls

### For Coding Agents

The controls are designed to make compliance automatic:

1. **Rules load every session** — `.claude/rules/adr-conformance.md` provides do/don't guidance before you write any code.
2. **Hard blocks catch violations at edit time** — if you try to write code that violates an ADR, the PreToolUse hook will block the operation and tell you which ADR is violated.
3. **Stop hooks catch omissions** — if you change dependency files without updating the allowlist, or change compatibility surfaces without updating the version registry, the stop hook will block session completion.
4. **Pre-commit and CI catch anything that slips through** — even if hooks are bypassed, the pre-commit and CI checks will catch violations.

**When blocked by a hook**: Read the error message. It tells you which ADR is violated and how to fix it. The fix is almost always to restructure the code to follow the architectural decision, not to add an override.

**When you need an override**: Add `# adr-override: ADR-NNN — <rationale>` to the specific code that needs to deviate. This is for rare, deliberate, documented deviations. If you find yourself adding overrides frequently, the architecture may need revisiting.

### For Human Developers

**Adding a new dependency**:
1. Add an entry to `docs/approved-extensions.yaml` with license, purpose, and review details.
2. Then add the dependency to the build configuration.
3. The stop hook and CI will verify both files are updated together.

**Adding a query language extension**:
1. Add an entry to `docs/language-deviations.yaml` with type, description, and rationale.
2. Mark the extension in the code (annotation, naming convention, or comment).
3. Implement the extension.

**Changing a compatibility surface**:
1. Update `docs/compatibility-versions.yaml` with the new version number, date, and notes.
2. Update `CHANGELOG.md` with the surface change.
3. Make the code change.

### Override Mechanism

The `# adr-override: ADR-NNN` comment tells automated checks to allow a specific deviation. Rules:

- The override comment must be in the same content block as the violation (same file, near the violating line).
- A rationale must accompany the override: `# adr-override: ADR-003 — Benchmark harness needs cluster simulation code`.
- Overrides do not grant blanket permission — they apply only to the specific code they annotate.
- Overrides should be rare. If overrides accumulate, it may indicate the ADR itself needs revision.

### Adding a New ADR

When a new ADR is accepted in Ground Control:

1. **Create local copy**: Add `docs/adrs/ADR-NNN.md` in MADR format with enforcement controls and override procedure sections.
2. **Update the rule**: Add relevant guidance to `.claude/rules/adr-conformance.md`.
3. **Determine enforcement type**:
   - If it defines a **prohibition** (don't do X): add patterns to `adr-boundary-check.sh` and `check-adr-conformance.sh`.
   - If it requires a **manifest/registry**: create a new YAML file in `docs/` and add validation to `verify-extra.sh` and CI.
   - If it defines a **structural rule**: add an architectural test template to `tests/architecture/`.
4. **Register any new hooks**: Update `.claude/settings.json` if new hooks are needed.
5. **Update CI**: Add validation steps to the `adr-conformance` job in `ci.yml`.
6. **Update this document**: Add the ADR to the Per-ADR Enforcement Detail section and the Control Inventory table.
7. **Update project docs**: Add the constraint to CLAUDE.md, AGENTS.md, and CODING_STANDARDS.md as appropriate.

## Maintenance and Evolution

### Activating ArchUnit Tests

The product stack is Java. Architecture tests use [ArchUnit](https://www.archunit.org/) (`com.tngtech.archunit:archunit-junit5`). The `.pseudo` files in `tests/architecture/` describe what each rule must verify — convert them to real ArchUnit tests, delete the pseudocode files, and wire them into CI alongside regular tests.

When scaffolding the project:

- **Add ArchUnit dependency** to the test configuration (Gradle or Maven).
- **Write ArchUnit rules** that satisfy each `.pseudo` file's requirements (layer checks, package dependency rules, annotation enforcement).
- **Add Java-specific import patterns** to `adr-boundary-check.sh` if the current patterns don't cover the actual import syntax used.
- **Add Java linting and formatting** to pre-commit hooks.
- **Add build, test, and coverage steps** to CI.

### When an ADR is Superseded

1. Update the ADR status in Ground Control: `gc_transition_adr_status`.
2. Update the local copy in `docs/adrs/ADR-NNN.md` with the superseding ADR reference.
3. Remove or update enforcement patterns:
   - Remove patterns from `adr-boundary-check.sh` and `check-adr-conformance.sh`.
   - Update `adr-conformance.md` rule text.
   - Update or remove related manifests.
   - Update CI validation steps.
4. Update this document.

### Periodic Review

Quarterly, review:

- [ ] Are hook patterns still accurate for the current codebase?
- [ ] Are manifests up to date (extensions, compatibility versions, language deviations)?
- [ ] Have any `adr-override` comments accumulated? Do they indicate an ADR needs revision?
- [ ] Are local ADR copies in sync with Ground Control?
- [ ] Are architectural tests activated and passing (if tech stack is chosen)?
