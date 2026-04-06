# Architecture Tests

Automated tests that enforce architectural rules defined by the project's ADRs. These tests complement the hook-based and CI-based enforcement in the [ADR enforcement system](../../docs/adr-enforcement.md).

## Status

**Pending implementation** — the `.pseudo` files describe what each ArchUnit rule must verify. Convert them to real ArchUnit tests when the project scaffolding is in place.

## Framework

[ArchUnit](https://www.archunit.org/) — the standard architecture test library for Java. Rules are expressed as JUnit tests that analyze compiled bytecode.

## Test Requirements

| Requirement File | ADRs | What the ArchUnit Rule Must Verify |
|------------------|------|-------------------------------------|
| `test_kernel_boundary.pseudo` | ADR-002 | Packages in `domain` and `api` do not depend on `infrastructure.engine` |
| `test_no_distributed_code.pseudo` | ADR-003, 005 | No classes matching distributed patterns outside feature-gated packages |
| `test_server_layer_required.pseudo` | ADR-007 | All public-facing endpoints are in the `api` package |
| `test_opencypher_extensions_marked.pseudo` | ADR-004 | All non-standard query functions carry an extension annotation |

## Activating

1. Add ArchUnit as a test dependency (e.g., `com.tngtech.archunit:archunit-junit5`).
2. Write ArchUnit rules that satisfy each `.pseudo` file's requirements.
3. Delete the `.pseudo` files.
4. Wire the tests into CI alongside regular unit tests.
5. Update `docs/adr-enforcement.md` to reflect the active tests.
