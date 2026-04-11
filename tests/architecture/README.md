# Architecture Tests

Automated tests that enforce architectural rules defined by the project's ADRs. These tests complement the hook-based and CI-based enforcement in the [ADR enforcement system](../../docs/adr-enforcement.md).

## Status

**Active** -- ArchUnit tests run as part of `./gradlew build` in CI.

## Framework

[ArchUnit](https://www.archunit.org/) -- architecture test library for Java. Rules are expressed as JUnit tests that analyze compiled bytecode.

## Tests

Tests live at `src/test/java/com/keplerops/aphelion/architecture/`.

| Test Class | ADRs | What the ArchUnit Rule Verifies |
|------------|------|--------------------------------|
| `KernelBoundaryTest` | ADR-002, ADR-007 | Packages in `domain` and `api` do not depend on `infrastructure.engine` |
| `NoDistributedCodeTest` | ADR-003, ADR-005, ADR-009 | No classes matching distributed patterns |
| `ServerLayerRequiredTest` | ADR-007 | No public-facing endpoint annotations in the engine layer |
| `OpenCypherExtensionsMarkedTest` | ADR-004, ADR-008 | Domain does not depend on protocol-specific types |

The ADR-004 annotation-based rule (non-standard query functions must carry a `@CypherExtension` marker) will be added when the query function registration mechanism exists (work order step 3).
