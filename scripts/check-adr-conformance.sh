#!/usr/bin/env bash
# ADR Conformance Check — pre-commit hook and CI script.
# Scans staged/committed source files for ADR violations.
# adr-override: ADR-003 — This file defines the search patterns, not distributed code.
#
# Enforcement:
#   ADR-001: No banned graph engines
#   ADR-003, 005, 009: No distributed systems primitives
#   ADR-006: Dependency changes require allowlist update
#   ADR-008: No protocol-specific imports in domain layer
#
# Usage:
#   As pre-commit hook: runs against staged files
#   As CI script: runs against all source files under src/
#
# Override: Lines containing "# adr-override: ADR-NNN" are excluded.
#
# See docs/adr-enforcement.md for the full enforcement system reference.

set -euo pipefail

ERRORS=0

# Determine file list: staged files (pre-commit) or all source files (CI)
if git rev-parse --is-inside-work-tree &>/dev/null && [ -n "$(git diff --cached --name-only 2>/dev/null)" ]; then
  # Pre-commit mode: check staged files
  FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(py|rs|ts|tsx|js|jsx|java|go|cpp|c|h|hpp)$' || true)
else
  # CI mode: check all source files
  FILES=$(find src/ -type f \( -name '*.py' -o -name '*.rs' -o -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.java' -o -name '*.go' -o -name '*.cpp' -o -name '*.c' -o -name '*.h' -o -name '*.hpp' \) 2>/dev/null || true)
fi

if [ -z "$FILES" ]; then
  exit 0
fi

# ---------------------------------------------------------------------------
# CHECK 1: Banned graph engines (ADR-001)
# ---------------------------------------------------------------------------
BANNED_ENGINES='\b(millenniumdb|graphflow)\b'

for file in $FILES; do
  [ -f "$file" ] || continue
  MATCHES=$(grep -inE "$BANNED_ENGINES" "$file" | grep -iv 'adr-override:.*ADR-001' || true)
  if [ -n "$MATCHES" ]; then
    echo "FAIL (ADR-001): Banned graph engine reference in $file:"
    echo "$MATCHES"
    echo "  ADR-001 selected capcom as the product-owned engine kernel."
    echo ""
    ERRORS=$((ERRORS + 1))
  fi
done

# ---------------------------------------------------------------------------
# CHECK 2: Distributed systems primitives (ADR-003, ADR-005, ADR-009)
# Patterns are loaded from a variable to keep them in one place.
# ---------------------------------------------------------------------------
# shellcheck disable=SC2034
DIST_TERMS=(
  raft_consensus paxos_consensus leader_election quorum_vote
  two_phase_commit distributed_txn distributed_transaction
  log_shipping log_shipper multi_primary cluster_coordinator
  node_discovery consensus_protocol replication_manager
  failover_controller shard_manager cross_node_query
)
DISTRIBUTED_PATTERN=$(IFS='|'; echo "${DIST_TERMS[*]}")
DISTRIBUTED_PATTERN="\\b(${DISTRIBUTED_PATTERN})\\b"

for file in $FILES; do
  [ -f "$file" ] || continue
  # Strip comment lines before checking
  MATCHES=$(grep -nE "$DISTRIBUTED_PATTERN" "$file" | grep -ivE '^\s*(#|//|/\*|\*|--)' | grep -iv 'adr-override:.*ADR-00[359]' || true)
  if [ -n "$MATCHES" ]; then
    echo "FAIL (ADR-003/005/009): Distributed systems primitive in $file:"
    echo "$MATCHES"
    echo "  V1 is single-node only. Distributed operations are out of scope."
    echo ""
    ERRORS=$((ERRORS + 1))
  fi
done

# ---------------------------------------------------------------------------
# CHECK 3: Dependency file vs. allowlist (ADR-006)
# Only in pre-commit mode (staged files available)
# ---------------------------------------------------------------------------
if git rev-parse --is-inside-work-tree &>/dev/null; then
  STAGED=$(git diff --cached --name-only 2>/dev/null || true)
  DEP_FILES="Cargo\.toml|package\.json|pyproject\.toml|go\.mod|go\.sum|requirements.*\.txt|Pipfile|pom\.xml|build\.gradle"
  HAS_DEP=$(echo "$STAGED" | grep -cE "$DEP_FILES" || true)
  HAS_ALLOWLIST=$(echo "$STAGED" | grep -c 'docs/approved-extensions.yaml' || true)

  if [ "$HAS_DEP" -gt 0 ] && [ "$HAS_ALLOWLIST" -eq 0 ]; then
    echo "FAIL (ADR-006): Dependency file staged without docs/approved-extensions.yaml update."
    echo "  Add new dependencies to the approved extensions registry before adding them to the project."
    echo ""
    ERRORS=$((ERRORS + 1))
  fi
fi

# ---------------------------------------------------------------------------
# CHECK 4: Protocol-specific imports in domain layer (ADR-008)
# ---------------------------------------------------------------------------
PROTO_TERMS=(
  bolt_protocol postgres_wire pgwire
  'grpc\.service' grpc_service 'tonic::service'
  BoltConnection PgWireHandler
)
PROTOCOL_PATTERN=$(IFS='|'; echo "${PROTO_TERMS[*]}")
PROTOCOL_PATTERN="\\b(${PROTOCOL_PATTERN})\\b"

DOMAIN_FILES=""
for file in $FILES; do
  case "$file" in
    */domain/*|domain/*)
      DOMAIN_FILES="$DOMAIN_FILES $file"
      ;;
  esac
done

for file in $DOMAIN_FILES; do
  [ -f "$file" ] || continue
  MATCHES=$(grep -inE "$PROTOCOL_PATTERN" "$file" | grep -iv 'adr-override:.*ADR-008' || true)
  if [ -n "$MATCHES" ]; then
    echo "FAIL (ADR-008): Protocol-specific import in domain layer ($file):"
    echo "$MATCHES"
    echo "  The public wire protocol is deferred. Protocol types belong in infrastructure/."
    echo ""
    ERRORS=$((ERRORS + 1))
  fi
done

# ---------------------------------------------------------------------------
# Result
# ---------------------------------------------------------------------------
if [ "$ERRORS" -gt 0 ]; then
  echo "ADR conformance check failed with $ERRORS violation(s)."
  echo "See docs/adr-enforcement.md for override procedures."
  exit 1
fi

exit 0
