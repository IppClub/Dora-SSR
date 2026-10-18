#!/usr/bin/env bash
set -euo pipefail

# Build out of tree using only bundled runtime and standalone CLI sources.
version=$(awk '/^#define LUA_VERSION_(MAJOR|MINOR|RELEASE)_N[[:space:]]/ {print $3}' Source/3rdParty/Lua/lua.h | paste -sd . -)
directory=$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/dora-test-lua.XXXXXX")
source_dir="$directory/src"
mkdir -p "$source_dir"
cp Source/3rdParty/Lua/*.[ch] "$source_dir/"
cp Source/3rdParty/Lua/cli/{lua.c,luac.c,Makefile} "$source_dir/"
case "$(uname -s)" in
  Linux) platform=linux ;;
  Darwin) platform=macosx ;;
  *) echo 'The CI test interpreter requires Linux or macOS' >&2; exit 1 ;;
esac
make -C "$source_dir" -j2 "$platform"
"$source_dir/lua" -e "assert(_VERSION == 'Lua ${version%.*}'); assert(require('debug')); print(_VERSION)"
"$source_dir/lua" -v
# Cover both the configurable test launcher and tests spawning `lua` directly.
printf 'DORA_LUA=%s/lua\n' "$source_dir" >> "$GITHUB_ENV"
printf '%s\n' "$source_dir" >> "$GITHUB_PATH"
