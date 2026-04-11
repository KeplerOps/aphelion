#!/usr/bin/env bash
# ADR Boundary Check — PreToolUse hook for Edit/Write operations.
# Blocks code that violates architectural decisions (ADR-001 through ADR-009).
#
# Enforcement:
#   ADR-001: No banned graph engines (MillenniumDB, Graphflow)
#   ADR-002: Kernel types only in infrastructure/engine/
#   ADR-003, 005, 009: No distributed systems primitives in v1
#   ADR-007: Kernel types not in API layer
#   ADR-008: No protocol-specific imports in domain layer
#
# Override: Include "# adr-override: ADR-NNN" in the content to bypass
# a specific check. Overrides must include a rationale comment.
#
# See docs/adr-enforcement.md for the full enforcement system reference.

set -euo pipefail

# Read tool input from stdin (JSON with file_path + new_string or content)
TOOL_INPUT=$(cat)

FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.tool_input.file_path // empty')
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Extract the content being written — Edit uses new_string, Write uses content
CONTENT=$(echo "$TOOL_INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')
if [[ -z "$CONTENT" ]]; then
  exit 0
fi

# Skip non-source files (docs, configs, tests/architecture templates, this hook itself)
case "$FILE_PATH" in
  */docs/*|*/.claude/*|*/.github/*|*/tests/architecture/*|*.md|*.yaml|*.yml|*.json|*.toml|*.lock|*.txt)
    exit 0
    ;;
esac

# ---------------------------------------------------------------------------
# Helper: check if content contains an override for the given ADR
# ---------------------------------------------------------------------------
has_override() {
  local adr="$1"
  echo "$CONTENT" | grep -qi "adr-override:.*${adr}" && return 0
  return 1
}

# ---------------------------------------------------------------------------
# CHECK 1: Banned graph engines (ADR-001)
# ---------------------------------------------------------------------------
if echo "$CONTENT" | grep -qiE '\b(millenniumdb|graphflow)\b'; then
  if ! has_override "ADR-001"; then
    echo "BLOCKED (ADR-001): Reference to a banned graph engine detected." >&2
    echo "ADR-001 selected capcom as the product-owned engine kernel." >&2
    echo "MillenniumDB (GPL, not production-ready) and Graphflow (research artifact) were rejected." >&2
    echo "To override, add: # adr-override: ADR-001 — <rationale>" >&2
    exit 2
  fi
fi

# ---------------------------------------------------------------------------
# CHECK 2: Kernel types in wrong layer (ADR-002, ADR-007)
# ---------------------------------------------------------------------------
# Only applies to files in domain/ or api/ layers
case "$FILE_PATH" in
  */src/domain/*|*/src/api/*)
    if echo "$CONTENT" | grep -qiE '(capcom::|kuzu::|from\s+(capcom|kuzu)\s+import|require\s*\(\s*['\''"](capcom|kuzu)|import\s+(capcom|kuzu)|use\s+(capcom|kuzu)::)'; then
      if ! has_override "ADR-002"; then
        echo "BLOCKED (ADR-002/ADR-007): Direct kernel import in domain or API layer." >&2
        echo "Kernel engine types must only be imported in src/infrastructure/engine/." >&2
        echo "Domain and API code must use product-defined interfaces, not kernel types directly." >&2
        echo "To override, add: # adr-override: ADR-002 — <rationale>" >&2
        exit 2
      fi
    fi
    ;;
esac

# ---------------------------------------------------------------------------
# CHECK 3: Distributed systems primitives (ADR-003, ADR-005, ADR-009)
# ---------------------------------------------------------------------------
# Match function/class/struct definitions and significant usage — not just comments.
# Uses word-boundary matching to avoid false positives.
DISTRIBUTED_PATTERN='\b(raft_consensus|paxos_consensus|leader_election|quorum_vote|two_phase_commit|distributed_txn|distributed_transaction|log_shipping|log_shipper|multi_primary|cluster_coordinator|node_discovery|consensus_protocol|replication_manager|failover_controller|shard_manager|cross_node_query)\b'

if echo "$CONTENT" | grep -qiE "$DISTRIBUTED_PATTERN"; then
  # Don't flag comments — strip comment lines first and re-check
  STRIPPED=$(echo "$CONTENT" | grep -viE '^\s*(#|//|/\*|\*|--)')
  if echo "$STRIPPED" | grep -qiE "$DISTRIBUTED_PATTERN"; then
    if ! has_override "ADR-003" && ! has_override "ADR-005" && ! has_override "ADR-009"; then
      echo "BLOCKED (ADR-003/ADR-005/ADR-009): Distributed systems primitive detected." >&2
      echo "V1 is single-node only. Distributed consensus, replication, failover, and" >&2
      echo "cross-node operations are out of scope for the current product." >&2
      echo "If this is future-scoped work, place it behind a disabled feature gate." >&2
      echo "To override, add: # adr-override: ADR-003 — <rationale>" >&2
      exit 2
    fi
  fi
fi

# ---------------------------------------------------------------------------
# CHECK 4: Protocol-specific imports in domain layer (ADR-008)
# ---------------------------------------------------------------------------
case "$FILE_PATH" in
  */src/domain/*)
    PROTOCOL_PATTERN='\b(bolt_protocol|postgres_wire|pgwire|grpc\.service|grpc_service|tonic::service|BoltConnection|PgWireHandler)\b'
    if echo "$CONTENT" | grep -qiE "$PROTOCOL_PATTERN"; then
      if ! has_override "ADR-008"; then
        echo "BLOCKED (ADR-008): Protocol-specific import in domain layer." >&2
        echo "The public wire protocol is deferred. Domain code must not import" >&2
        echo "protocol-specific types (Bolt, PostgreSQL wire, gRPC service definitions)." >&2
        echo "Protocol implementations belong in the infrastructure layer." >&2
        echo "To override, add: # adr-override: ADR-008 — <rationale>" >&2
        exit 2
      fi
    fi
    ;;
esac

# All checks passed
exit 0
