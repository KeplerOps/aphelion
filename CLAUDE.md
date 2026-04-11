See [AGENTS.md](AGENTS.md) for Ground Control integration, development standards, and repository structure. Everything in AGENTS.md applies here.

Always use the package manager to install dependencies.
Always follow the coding standards.
Keep docs and ADRs up to date.
Always do the right thing, not the easy thing.

## Project

Aphelion is a brand graph database -- a system for modeling brands, their attributes, relationships, and the networks they form. The domain centers on graph operations: nodes (brands, entities), edges (relationships, associations), traversals, and queries.

## Build

Requires Java 21 (temurin recommended) and Gradle 8.12+ (wrapper included).

- **Rapid dev loop**: `./gradlew classes` (compile only, includes Error Prone)
- **Test**: `./gradlew test`
- **Lint/format check**: `./gradlew spotlessCheck`
- **Format fix**: `./gradlew spotlessApply`
- **Static analysis**: `./gradlew spotbugsMain`
- **Full check**: `./gradlew build` (compile + Error Prone + tests + Spotless + SpotBugs)

## Ground Control

The Ground Control project identifier for this repo is `aphelion`.

## Coding Standards

See [docs/CODING_STANDARDS.md](docs/CODING_STANDARDS.md) for the full reference. Key points:

- **L0 is the default assurance level.** Ship features, not ceremony. One test per significant behavior.
- **L1** for state transitions, security boundaries, and silent-corruption-risk methods.
- **L2** for state machines and graph operations (cycle detection, traversal, reachability).
- Domain logic is framework-independent. Dependency flows inward: `api/ -> domain/ <- infrastructure/`.
- All exceptions extend a single base exception type. No framework exceptions from domain code.
- Imperative commit messages. Every commit updates CHANGELOG.md.

## Architecture Decisions

This project has 16 accepted ADRs in Ground Control (project: `aphelion`). Use `gc_list_adrs` to view them. Local copies are in `docs/adrs/`.

Key constraints enforced by hooks and CI:
- `capcom` is the engine kernel (ADR-001). Temporary reference engines must not define the product contract.
- The canonical kernel source lives in the `capcom` repo (ADR-001).
- Kernel types stay behind `infrastructure/engine/` (ADR-002, 007).
- V1 is single-node only (ADR-003, 005, 009). No distributed code.
- openCypher is the query language baseline (ADR-004). Extensions must be marked.
- New dependencies require an entry in `docs/approved-extensions.yaml` (ADR-006).
- No public wire protocol commitment yet (ADR-008).
- Compatibility surface changes require `docs/compatibility-versions.yaml` update (ADR-010).
- Product server/control layers use Java 21 while the kernel stays native (ADR-011).
- The engine runs as a co-located out-of-process node behind a product-owned contract (ADR-012, 014).
- Product and engine split catalog authority by metadata class (ADR-013).
- Compatibility and correctness claims require layered executable verification (ADR-015).

See [docs/adr-enforcement.md](docs/adr-enforcement.md) for the full enforcement system reference.

## Code Review

Don't surface nitpicks about PR titles or descriptions unless they are grossly misleading.

## Implementation

Always check your work against the requirement you are implementing to be sure you have implemented all the functionality described in the requirement.

## Answer Questions

If you are asked a question that you don't know the answer to but you have the means to find the facts, go find the facts and answer the question. You have all the tools at your disposal to answer any of these questions, so use them.
