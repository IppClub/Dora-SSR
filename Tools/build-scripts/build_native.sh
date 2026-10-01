#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLATFORM="${1:?platform required}"
ACTION="${2:-debug}"
if [ "$#" -ge 2 ]; then shift 2; else shift; fi
TASK=dora-build
case "$ACTION" in
  run) TASK=dora-run; MODE=debug ;;
  debug|--debug|-d) MODE=debug ;;
  release|--release|-r) MODE=release ;;
  *) echo "Usage: $0 <platform> [debug|release|run] [engine arguments]" >&2; exit 1 ;;
esac
cd "$SCRIPT_DIR/../.."
exec xmake "$TASK" --platform="$PLATFORM" --mode="$MODE" -- "$@"
