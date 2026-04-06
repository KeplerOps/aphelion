## ADR Conformance Rules

This project has 15 accepted Architecture Decision Records enforced through a mix of automated controls and explicit review gates.
See `docs/adr-enforcement.md` for the full reference. Violations trigger hard blocks from
hooks, pre-commit, and CI. These rules are the first line of defense — follow them and the
automated checks will pass.

### Engine and Kernel Boundary (ADR-001, ADR-002, ADR-007)

- The engine kernel is a **Kuzu fork**. It is the only graph engine permitted in this project.
- **Never** import, depend on, or reference MillenniumDB, Graphflow, Neo4j (GPL components),
  or any other graph database engine. ADR-001 evaluated and rejected these alternatives.
- Kuzu kernel types belong **exclusively** in `src/infrastructure/engine/` (or the equivalent
  adapter layer). Code in `src/domain/` and `src/api/` must never import from the kernel
  directly — no `kuzu::`, `from kuzu import`, `require('kuzu')`, or equivalent.
- The product is exposed as a **server process** (ADR-007), not as the raw embedded kernel API.
  Authentication, authorization, auditing, and observability attach at the server/product layer.
  Never expose kernel transaction objects, engine handles, or internal storage types in
  public-facing interfaces.
- If you need kernel functionality in domain or API code, define a product-owned interface in
  the domain layer and implement it in the infrastructure/engine adapter.

### Single-Node Only in V1 (ADR-003, ADR-005, ADR-009)

- V1 is a **single-node product**. Do not write code for distributed operation.
- **Prohibited in V1** (unless behind an explicit, disabled-by-default feature gate):
  - Distributed consensus (Raft, Paxos, leader election, quorum)
  - Multi-node replication or log shipping
  - Distributed transactions or two-phase commit
  - Cross-node query execution or work distribution
  - Shared storage, disaggregated storage, or remote storage access
  - Cluster coordination, node discovery, or topology management
  - Transparent failover or automatic HA
- The storage and transaction model is **single-node local** (ADR-005). All transactions
  are local to the database node. All storage is local node-managed persistent storage.
- The replication/HA mechanism is **explicitly deferred** (ADR-009). No specific mechanism
  is selected — not log shipping, not consensus replication, not shared-storage failover.
- If you find yourself writing code that assumes or coordinates multiple nodes, **stop and
  reconsider**. The architectural boundaries from ADR-002 must be preserved for future HA
  work, but the implementation is out of scope.

### Query Language (ADR-004)

- **openCypher** is the initial language compatibility baseline. All query behavior targets
  openCypher semantics first.
- Do **not** add a second query language (Gremlin, SPARQL, SQL, GQL) without a new ADR.
- Any product-specific extensions to the query language must be:
  - Explicitly marked as extensions in the parser/AST (annotation, naming convention, or marker)
  - Recorded in `docs/language-deviations.yaml` with type, rationale, and affected syntax
- Never silently redefine existing openCypher semantics (null handling, comparison behavior,
  function signatures, etc.). If behavior must differ, document it as a deviation.

### Extension and Dependency Management (ADR-006)

- All extensions and engine-adjacent third-party components require **product-owned review**.
- Before adding any new dependency or extension to the project:
  1. Add an entry to `docs/approved-extensions.yaml` with name, version, license, purpose,
     and approval details.
  2. Verify the license is compatible (no GPL/AGPL/strong-copyleft without explicit approval).
  3. Then add the dependency to the build configuration.
- Production deployments must not load extensions from unmanaged or public sources.
- The stop hook will block session completion if dependency files change without a
  corresponding update to `docs/approved-extensions.yaml`.

### Wire Protocol (ADR-008)

- The public wire protocol is **deferred**. Do not commit to Bolt, PostgreSQL wire protocol,
  gRPC, HTTP, or any specific protocol as THE public contract.
- Internal service interfaces for implementation work are fine — just don't treat them as
  the permanent external API.
- Domain code (`src/domain/`) must not import protocol-specific types (bolt, postgres_wire,
  grpc service definitions). Protocol implementations belong in the infrastructure layer
  behind a product-owned interface.

### Compatibility Surfaces (ADR-010)

- From the first external release, four compatibility surfaces are versioned independently:
  1. Query language behavior
  2. On-disk storage format
  3. Backup/export format
  4. Extension/plugin API interfaces
- When changing any of these surfaces, update `docs/compatibility-versions.yaml` with the
  new version number, change date, and notes.
- The stop hook will block session completion if compatibility-surface-related files change
  without a corresponding update to `docs/compatibility-versions.yaml`.

### Product Stack and Kernel Integration (ADR-011, ADR-012, ADR-014)

- The product server and control layers use **Java 21**. The engine kernel remains native.
- The engine runs as a **co-located out-of-process node**. Do not design the product around
  in-process embedding as the primary architecture.
- The internal engine-node contract is **product-owned**, capability-oriented, handle-based,
  and streaming-first. Do not mirror raw kernel classes or object graphs in product-facing
  interfaces.
- Query submission across the internal boundary is text-plus-parameters initially. Do not
  centralize parser or planner ownership in the product layer without a new ADR.

### Catalog and Metadata Authority (ADR-013)

- DBMS-level catalog, security, compatibility, extension-policy, and audit metadata are
  product-owned control-plane concerns.
- Per-database schema/index metadata and engine-internal transactional or physical metadata
  remain engine-owned.
- Each metadata class must have exactly one source of truth. Do not duplicate authority
  across the product and engine layers.

### Verification Architecture (ADR-015)

- Compatibility claims require executable verification behind them.
- The openCypher TCK is a normative input, but it is **not** the whole verification strategy.
- Driver/protocol claims, durability/recovery claims, backup/restore claims, and performance
  claims must each have dedicated harness coverage.
- Do not describe a compatibility surface as supported if there is no corresponding harness
  or explicit validation strategy.

### Override Mechanism

If you must deliberately deviate from an ADR (rare, requires justification):
- Add a comment `# adr-override: ADR-NNN` on the line or block that deviates.
- Include a rationale comment on the same or adjacent line explaining why.
- The automated hooks will allow the override to pass.
- Overrides are for deliberate, documented deviations — not convenience shortcuts.
