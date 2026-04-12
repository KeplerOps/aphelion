# Agent Instructions

This file provides context for AI coding agents (Claude Code, Codex, Copilot, etc.) working in this repository.

## Ground Control Context

This repo's Ground Control project id, workflow commands, and plan
rules live in `.ground-control.yaml` at repo root (with larger rule
files under `.gc/`). Agents read it via the
`gc_get_repo_ground_control_context` MCP tool, which returns the full
workflow config in a single call.

## Ground Control

This project uses **Ground Control** for requirements management and traceability. Ground Control is a requirements engineering platform that stores requirements, relations (parent/child, dependencies), traceability links (code ↔ requirements), ADRs, and project status.

### How it works

- **Requirements** have a UID (e.g. `REQ-001`), title, statement, rationale, type, priority (MoSCoW), status (DRAFT → ACTIVE → DEPRECATED), and wave number.
- **Relations** connect requirements: PARENT (decomposition), DEPENDS_ON, REFINES, RELATED.
- **Traceability links** connect requirements to artifacts: IMPLEMENTS (source files), TESTS (test files), GITHUB_ISSUE (issues).
- **ADRs** (Architecture Decision Records) capture design decisions linked to requirements.

### Integration

Ground Control is available as an MCP (Model Context Protocol) server configured in `.mcp.json`. If your agent supports MCP, the following tools are available:

| Tool | Purpose |
|------|---------|
| `gc_get_requirement` | Fetch a requirement by UID |
| `gc_list_requirements` | List/search requirements with filters |
| `gc_get_relations` | Get parent/child and dependency relations |
| `gc_get_traceability` | Get traceability links for a requirement |
| `gc_create_traceability_link` | Link a requirement to a code file, test, or issue |
| `gc_transition_status` | Move a requirement from DRAFT → ACTIVE |
| `gc_create_github_issue` | Create a GitHub issue from a requirement |
| `gc_list_adrs` | List architecture decision records |

The Ground Control project identifier for this repo is `aphelion`, declared in the Ground Control Context block above. Use it in the `project` parameter for all GC tool calls.

### Workflow

When implementing a feature tied to a requirement:

1. **Fetch the requirement** — read its statement, rationale, and acceptance criteria.
2. **Check existing traceability** — see what's already implemented and tested.
3. **Implement** — satisfy every clause in the requirement statement.
4. **Create traceability links** — IMPLEMENTS links to source files, TESTS links to test files.
5. **Transition status** — move DRAFT requirements to ACTIVE once implemented.

If your agent does not support MCP, you can still follow this workflow manually by referencing requirement UIDs in commit messages and PR descriptions.

## Development Standards

- Write tests for significant behaviors.
- Document architectural decisions in `docs/adrs/` using MADR format.
- Update `CHANGELOG.md` for every commit that changes source code (not required for documentation-only or GC-only changes).
- Never include AI attribution (Co-Authored-By, "Generated with Claude Code", etc.) in commits or PRs.
- Never merge PRs — the maintainer reviews and merges.

## Architecture Decision Conformance

This project enforces the accepted ADR set through automated controls and review gates. See [docs/adr-enforcement.md](docs/adr-enforcement.md) for the full reference.

**Automated enforcement layers:**
- **Claude Code hooks** block edits that violate kernel boundaries, import banned engines, or add distributed primitives.
- **Pre-commit hooks** scan staged files for ADR violations at commit time.
- **CI** validates ADR conformance on every PR.
- **Stop hooks** verify manifest updates when dependencies or compatibility surfaces change.
- **Manifest files** (`docs/approved-extensions.yaml`, `docs/compatibility-versions.yaml`, `docs/language-deviations.yaml`) track auditable decisions.

**If your agent does not support Claude Code hooks**, enforce these rules manually:
1. Treat `capcom` as the engine kernel. Temporary reference-engine work, including Kuzu, must stay behind `infrastructure/engine/` and must not define product contracts.
2. Keep kernel types behind `infrastructure/engine/`. Domain and API layers use product-defined interfaces only.
3. No distributed systems code in v1.
4. New dependencies must be added to `docs/approved-extensions.yaml` first.
5. Query language extensions must be explicitly marked and recorded in `docs/language-deviations.yaml`.

**Override mechanism:** Add `# adr-override: ADR-NNN` with a rationale comment to bypass a specific check. Overrides are for deliberate, documented deviations — not convenience.

## Repository Structure

```
.claude/          # Claude Code agent configuration (settings, hooks, rules, skills)
.github/          # GitHub Actions CI/CD workflows
docs/adrs/        # Architecture Decision Records (when created)
```
