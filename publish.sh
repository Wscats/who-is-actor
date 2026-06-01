#!/usr/bin/env bash
# Publish who-is-actor skill to ClawHub.
# Usage: ./publish.sh [version]
# Example: ./publish.sh v1.0.11

set -euo pipefail

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------
SLUG="who-is-actor"
DEFAULT_VERSION="v1.0.12"
SKILL_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="${1:-$DEFAULT_VERSION}"

# Strip leading 'v' if present, since semver expects 1.0.11 (clawhub accepts both, normalize anyway).
VERSION_SEMVER="${VERSION#v}"

# ------------------------------------------------------------
# Pre-flight checks
# ------------------------------------------------------------
if ! command -v clawhub >/dev/null 2>&1; then
  echo "[error] clawhub CLI not found in PATH." >&2
  echo "        Install it first, then re-run this script." >&2
  exit 1
fi

if [ ! -f "${SKILL_PATH}/skill.yaml" ] && [ ! -f "${SKILL_PATH}/SKILL.md" ]; then
  echo "[error] Neither skill.yaml nor SKILL.md found in ${SKILL_PATH}" >&2
  exit 1
fi

# ------------------------------------------------------------
# Auth check
# ------------------------------------------------------------
echo "[info] Verifying ClawHub login status..."
if ! clawhub whoami >/dev/null 2>&1; then
  echo "[info] Not logged in. Launching login flow..."
  clawhub login
fi

# ------------------------------------------------------------
# Publish
# ------------------------------------------------------------
echo "[info] Publishing ${SLUG} @ ${VERSION_SEMVER} from ${SKILL_PATH}"

clawhub publish "${SKILL_PATH}" \
  --slug "${SLUG}" \
  --version "${VERSION_SEMVER}" \
  --tags "latest"

echo "[done] Published: https://clawhub.ai/${SLUG} (v${VERSION_SEMVER})"
