#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
	echo "usage: $0 /path/to/love-11.5-git-checkout" >&2
	exit 2
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "$script_dir/../.." && pwd)
upstream=$1
expected_commit=6eb8d546736d5915a8b5af30b2cf33456dfdcb1a
actual_commit=$(git -C "$upstream" rev-parse '11.5^{commit}')

if [[ "$actual_commit" != "$expected_commit" ]]; then
	echo "LOVE 11.5 commit mismatch: expected $expected_commit, got $actual_commit" >&2
	exit 1
fi

replay_dir=$(mktemp -d "${TMPDIR:-/tmp}/dora-love-replay.XXXXXX")
trap 'rm -rf "$replay_dir"' EXIT

git -C "$upstream" archive 11.5 | tar -x -C "$replay_dir"
gzip -dc "$repo_root/Source/Love/Patches/dora-love-11.5-consolidated.patch.gz" \
	| git -C "$replay_dir" apply --whitespace=nowarn --check -
gzip -dc "$repo_root/Source/Love/Patches/dora-love-11.5-consolidated.patch.gz" \
	| git -C "$replay_dir" apply --whitespace=nowarn -

checked=0
while IFS= read -r -d '' source_file; do
	relative=${source_file#"$repo_root/Source/3rdParty/Love/"}
	if ! cmp -s "$source_file" "$replay_dir/$relative"; then
		echo "replay mismatch: $relative" >&2
		exit 1
	fi
	checked=$((checked + 1))
done < <(find "$repo_root/Source/3rdParty/Love/src" -type f -print0)

if ! cmp -s "$repo_root/Source/3rdParty/Love/xmake.lua" "$replay_dir/xmake.lua"; then
	echo "replay mismatch: xmake.lua" >&2
	exit 1
fi
checked=$((checked + 1))

echo "LOVE 11.5 consolidated replay passed: $checked files"
