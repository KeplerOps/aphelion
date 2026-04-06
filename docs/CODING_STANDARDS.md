# Aphelion -- Coding Standards

These are mandatory rules. Follow them exactly when writing or modifying code.

## Development Workflow

This project uses a phased approach to rigor. During **pre-alpha** (current), the priority is velocity -- get the differentiating features built. The bar rises at beta.

### Pre-alpha workflow

1. **Write code.** Implementation first. Get it working.
2. **Write one test per significant behavior.** No mandatory coverage theatrics.
3. **Run the rapid dev loop.** Format + compile. Tests run in CI.

### Assurance levels

| Level | Name | When to use (pre-alpha) | What you must produce |
|-------|------|-------------------------|----------------------|
| L0 | Standard | **Default.** Everything unless escalated below | Working code + one test per significant behavior |
| L1 | Contracted | State transitions, security boundaries, methods where invalid input causes silent data corruption | Explicit precondition/postcondition checks + tests for the contracted behavior |
| L2 | Property-Verified | State machines, graph operations (cycle detection, traversal, reachability) | L1 + property-based tests |
| L3 | Formally Specified | Future | L2 + formal proofs |

**When in doubt, use L0.** Ship features. The bar rises at beta.

### Decision rules

| If you are writing... | Level |
|-----------------------|-------|
| A state machine, transition table, or workflow | **L2** |
| Graph operations (cycle detection, traversal, reachability, subgraph queries) | **L2** |
| Security boundary logic (auth checks, permission guards) | **L1** |
| A domain model method where invalid input causes silent data corruption | **L1** |
| Everything else | **L0** |

### Post-alpha target

At beta, the default rises to L1. Every L1+ public method gets explicit contracts, every contract gets a happy-path and violation test, and a full Specify-Test-Code-Verify loop becomes mandatory.

## Architecture Rules

> **Update this section with enforcement tooling once the tech stack is chosen.**

### General principles

- **Domain logic is framework-independent.** The domain layer must not import web framework, HTTP, or adapter-specific types.
- **Dependency flows inward.** API/controller layers depend on domain. Infrastructure/adapter layers implement interfaces defined by domain. Domain depends on neither.
- **Exceptions are uniform.** All application exceptions extend a single base exception type. Framework-specific exceptions (HTTP status exceptions, ORM exceptions) are never thrown from domain code.

```
api/ -> domain/ <- infrastructure/
```

### ADR-Enforced Boundaries

The following boundaries are enforced by automated hooks and CI. See [docs/adr-enforcement.md](docs/adr-enforcement.md) for full detail including override procedures.

| Boundary | Rule | Enforced By |
|----------|------|-------------|
| Engine isolation | Only `infrastructure/engine/` imports kernel types | Hook, pre-commit, CI |
| No banned engines | MillenniumDB, Graphflow, etc. are blocked | Hook, pre-commit, CI |
| Single-node v1 | No distributed consensus, replication, or transactions | Hook, pre-commit, CI |
| Extension allowlist | New deps require `docs/approved-extensions.yaml` entry | Stop hook, CI |
| openCypher baseline | Extensions must be explicitly marked | Rule, arch tests |
| No protocol lock-in | Domain layer cannot import protocol-specific types | Hook, CI |
| Compatibility tracking | Surface changes require `docs/compatibility-versions.yaml` update | Stop hook, CI |

### When to add architecture enforcement rules

Add an automated architecture test whenever you:
- Add a new top-level package or module (enforce its dependency constraints)
- Introduce a naming convention that must hold project-wide
- Add a new annotation/decorator that must only appear in specific layers
- Discover a dependency violation pattern that could recur

## Package / Module Structure

> **Update with concrete paths once the tech stack is chosen.**

Follow this general pattern:

```
src/
├── domain/           # Business logic. No framework imports.
│   ├── model/        # Entities, value objects, aggregates
│   ├── service/      # Domain services (write-owners of entities)
│   └── repository/   # Repository interfaces (not implementations)
├── api/              # Controllers / route handlers. Thin delegation to services.
├── infrastructure/   # External adapters (graph DB driver, external APIs)
└── shared/           # Cross-cutting concerns (logging, utilities)
```

**Placement rules:**
- New domain concept? Create a sub-package under `domain/`.
- New API endpoint? Add a handler in `api/`. It must only call domain services.
- New external integration? Add an adapter in `infrastructure/`. Domain defines the interface.
- New cross-cutting concern? Add to `shared/`.

## Exceptions / Error Handling

All application exceptions must extend a single base exception type.

**Rules:**
- Domain layer throws domain exceptions. Never throw framework-specific HTTP exceptions from domain code.
- A global exception handler maps domain exceptions to the API error envelope. Do not create additional exception handlers per controller.
- Never catch `Exception` broadly. Catch the specific exception you expect.
- Wrap external library exceptions in the infrastructure layer -- domain code must never leak third-party exception types.

### Error response envelope

All error responses use this format. Do not invent new formats.

```json
{
  "error": {
    "code": "not_found",
    "message": "Brand node BN-42 not found",
    "detail": null
  }
}
```

- `code`: machine-readable, matches the exception's error code
- `message`: human-readable description
- `detail`: optional structured context

## Testing

### Test organization

> **Update concrete paths once the tech stack is chosen.**

```
tests/
├── unit/             # No DB, no external services. Fast. Run always.
├── integration/      # Real database via containers. Slow. Run in CI.
└── architecture/     # Automated architecture rule enforcement. Fast. Run always.
```

### Test requirements by assurance level (pre-alpha)

| Level | Required tests |
|-------|---------------|
| L0 | One test per significant behavior. Skip trivial getters/setters. |
| L1 | L0 + at least one test per contract (precondition/postcondition) |
| L2 | L1 + property-based tests |
| L3 | Future |

Integration tests: write smoke tests to verify the feature works end-to-end. Exhaustive endpoint coverage is a post-alpha concern.

### Naming and style

- Test class/file: `FooTest` for unit, `FooIntegrationTest` for integration
- Test method/function: describes behavior, not implementation -- `archiveFromDraftFails`, not `testArchiveMethod`
- Group related tests logically (nested classes, describe blocks, etc.)
- Use the assertion library idiomatic to the chosen stack
- Test exception paths with dedicated assertions, not try/catch

### Coverage

- Pre-alpha: 30% minimum. Will increase as the platform matures.
- Post-alpha targets: domain 80%, API/infrastructure 70%.

## Logging

Use the structured logging library appropriate to the chosen stack. Never use print-to-stdout for application logging.

**Rules:**
- Use semantic event names: `brand_node_created`, `relationship_changed`, not `"Created a new brand node"`
- Never log secrets, tokens, passwords, or PII
- Bind request IDs to the logging context at the middleware level
- Production uses structured (JSON) output. Dev uses human-readable console output.

## Code Style

> **Update with specific formatter/linter configuration once the tech stack is chosen.**

### General principles

- Formatting is automated. Run the formatter before committing. No style debates.
- Line length: follow the formatter's default (typically 100-120 chars).
- Documentation: on public API boundaries only. Do not document private methods or obvious code.
- Use the type system to prevent bugs. Avoid untyped escape hatches (`any`, `Object`, raw types).
- Use immutable data structures (records, frozen dataclasses, readonly) for DTOs and value objects.

### Naming

| Element | Convention |
|---------|-----------|
| Packages/modules | `lowercase` or `snake_case` per language convention |
| Classes/types | `PascalCase` |
| Methods/functions | `camelCase` or `snake_case` per language convention |
| Constants | `UPPER_SNAKE_CASE` |
| Test classes/files | `FooTest` / `FooIntegrationTest` |

## Git & CI

- All code goes through PR targeting `dev`. No direct push to `main` or `dev`.
- PRs require: build passes, tests pass, linter/formatter clean, no coverage regression.
- Commit messages: imperative mood. `Add brand node search` not `Added brand node search`.
- Every commit updates `CHANGELOG.md`.
- Pre-commit hooks enforce formatting, linting, and secret detection. Do not bypass with `--no-verify`.

## Branch Strategy

- `main` -- production-ready, protected
- `dev` -- integration branch, all PRs target this
- `feature/*` -- feature branches, branched from `dev`
