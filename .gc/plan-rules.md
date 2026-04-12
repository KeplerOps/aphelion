# aphelion plan rules

Mandatory constraints the `/implement` skill applies during plan phase.
These encode the ADR conformance checks previously in
`implement/SKILL.md` Step 4.25.

- Plans MUST NOT introduce dependencies outside
  `docs/approved-extensions.yaml`. Every new dependency requires an
  entry with license, purpose, approval date, and security review
  (ADR-006).
- Plans MUST NOT expose kernel types (`capcom::`, `kuzu::`) outside
  `src/main/java/com/keplerops/aphelion/infrastructure/engine/`. Domain
  and API layers use product-defined interfaces, never kernel types
  directly (ADR-002, ADR-007).
- Plans MUST NOT add distributed systems code: consensus, replication,
  failover, cross-node operations, distributed transactions, shared
  storage (ADR-003, ADR-005, ADR-009). V1 is single-node only.
- Plans MUST NOT commit to a specific public wire protocol (Bolt,
  PostgreSQL wire, gRPC, HTTP-only). The wire protocol choice is
  deferred (ADR-008).
- Plans MUST NOT change a compatibility surface (query language,
  on-disk storage, backup/export, extension API) without updating
  `docs/compatibility-versions.yaml` in the same change (ADR-010).
- Plans that add openCypher query functions MUST mark non-standard
  functions with the extension annotation and record deviations in
  `docs/language-deviations.yaml` (ADR-004).
