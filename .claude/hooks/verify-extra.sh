#!/usr/bin/env bash
# Project-specific implementation checks — ADR enforcement.
# Sourced by the user-level verify-implementation.sh Stop hook.
# $CHANGED is passed in as an env var containing the git diff file list.
# Output any failure reasons to stdout; empty output = all checks pass.
#
# Enforces:
#   ADR-002: Kernel boundary cross-layer warning
#   ADR-006: Extension allowlist must be updated with dependency changes
#   ADR-010: Compatibility versions must be updated with surface changes
#
# See docs/adr-enforcement.md for the full enforcement system reference.

REASONS=""

# ---------------------------------------------------------------------------
# CHECK 1: Extension manifest check (ADR-006)
# If dependency files changed, approved-extensions.yaml must also be updated.
# ---------------------------------------------------------------------------
DEP_FILES="Cargo\.toml|package\.json|pyproject\.toml|go\.mod|go\.sum|requirements.*\.txt|Pipfile|pom\.xml|build\.gradle"
HAS_DEP_CHANGE=$(echo "$CHANGED" | grep -cE "$DEP_FILES" || true)
HAS_EXT_MANIFEST=$(echo "$CHANGED" | grep -c 'docs/approved-extensions.yaml' || true)

if [ "$HAS_DEP_CHANGE" -gt 0 ] && [ "$HAS_EXT_MANIFEST" -eq 0 ]; then
  REASONS="${REASONS}Dependency file changed but docs/approved-extensions.yaml not updated (ADR-006). Add new dependencies to the allowlist before adding them to the project. "
fi

# ---------------------------------------------------------------------------
# CHECK 2: Compatibility version check (ADR-010)
# If files in compatibility-surface paths changed, the version registry
# must also be updated.
# ---------------------------------------------------------------------------
HAS_COMPAT_MANIFEST=$(echo "$CHANGED" | grep -c 'docs/compatibility-versions.yaml' || true)

# Query language / parser surface
HAS_QUERY_CHANGE=$(echo "$CHANGED" | grep -cE 'src/.*/query/|src/.*/parser/|src/.*/cypher/' || true)
# Storage surface
HAS_STORAGE_CHANGE=$(echo "$CHANGED" | grep -cE 'src/.*/storage/' || true)
# Backup/export surface
HAS_BACKUP_CHANGE=$(echo "$CHANGED" | grep -cE 'src/.*/backup/|src/.*/export/|src/.*/import/' || true)
# Extension API surface
HAS_EXTENSION_CHANGE=$(echo "$CHANGED" | grep -cE 'src/.*/extension/|src/.*/plugin/' || true)

SURFACE_CHANGED=0
if [ "$HAS_QUERY_CHANGE" -gt 0 ] || [ "$HAS_STORAGE_CHANGE" -gt 0 ] || \
   [ "$HAS_BACKUP_CHANGE" -gt 0 ] || [ "$HAS_EXTENSION_CHANGE" -gt 0 ]; then
  SURFACE_CHANGED=1
fi

if [ "$SURFACE_CHANGED" -gt 0 ] && [ "$HAS_COMPAT_MANIFEST" -eq 0 ]; then
  REASONS="${REASONS}Compatibility surface files changed but docs/compatibility-versions.yaml not updated (ADR-010). Update the version registry when changing query language, storage, backup/export, or extension API surfaces. "
fi

# ---------------------------------------------------------------------------
# CHECK 3: Kernel boundary cross-layer warning (ADR-002)
# If both API/domain and engine layers changed, flag for review.
# ---------------------------------------------------------------------------
HAS_API_DOMAIN=$(echo "$CHANGED" | grep -cE 'src/(api|domain)/' || true)
HAS_ENGINE=$(echo "$CHANGED" | grep -cE 'src/infrastructure/engine/' || true)

if [ "$HAS_API_DOMAIN" -gt 0 ] && [ "$HAS_ENGINE" -gt 0 ]; then
  REASONS="${REASONS}Both API/domain and engine layers changed in this session — verify kernel boundary is maintained (ADR-002). Kernel types must not leak into domain or API layers. "
fi

echo -n "$REASONS"
