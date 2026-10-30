#!/bin/bash
# Header/ABI syntax coverage only. This does not prove engine/GPU platform support.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
OUT="$ROOT/build/godot-runtime/abi"
mkdir -p "$OUT"
cd "$ROOT"
for entry in 'windows-x64:x86_64-pc-windows-msvc' 'linux-x64:x86_64-unknown-linux-gnu' \
    'android-arm64:aarch64-linux-android21' 'ios-arm64:arm64-apple-ios13.0' \
    'web-wasm32:wasm32-unknown-unknown'; do
    name="${entry%%:*}"; target="${entry#*:}"
    if [[ "$name" == ios-arm64 ]]; then
        sdk="$(xcode-select -p)/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
        [[ -d "$sdk" ]] || { echo 'iOS SDK not found' >&2; exit 1; }
        clang -isysroot "$sdk" --target="$target" -ffreestanding -std=c11 -Wall -Wextra -Werror -I . \
            -c Tools/Godot/tests/bridge_abi.c -o "$OUT/$name.o"
    else
        clang --target="$target" -ffreestanding -std=c11 -Wall -Wextra -Werror -I . \
            -c Tools/Godot/tests/bridge_abi.c -o "$OUT/$name.o"
    fi
    printf '%s C ABI header: PASS\n' "$name"
done
