#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  tools/apply_local_mac_support.sh <target-branch> [--include-bugfix] [--no-bugfix]

Description:
  Applies local mac support commits to a target branch in this E3SM clone.
  Optionally applies the sediment bugfix commit.

Defaults:
  --include-bugfix is on by default.

Commits applied:
  Bugfix (optional): 342b29c514
  Local config:       b2e9d3171d
  Submodule pointers: a3126c62c5
EOF
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

TARGET_BRANCH="$1"
shift

INCLUDE_BUGFIX=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --include-bugfix)
      INCLUDE_BUGFIX=1
      ;;
    --no-bugfix)
      INCLUDE_BUGFIX=0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
  esac
  shift
done

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "Repository: $REPO_ROOT"
echo "Switching to branch: $TARGET_BRANCH"
git switch "$TARGET_BRANCH"

if [[ $INCLUDE_BUGFIX -eq 1 ]]; then
  echo "Applying bugfix commit 342b29c514"
  git cherry-pick 342b29c514
else
  echo "Skipping bugfix commit"
fi

echo "Applying local mac support commits"
git cherry-pick b2e9d3171d
git cherry-pick a3126c62c5

echo "Updating submodules"
git submodule update --init --recursive

echo "Done. Local mac support applied on branch: $TARGET_BRANCH"
