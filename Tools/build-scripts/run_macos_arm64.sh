#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../../Source/Rust"
cargo build --target aarch64-apple-darwin
cp target/aarch64-apple-darwin/debug/libdora_runtime.a lib/macOS/libdora_runtime.a
xcodebuild ARCHS=arm64 ONLY_ACTIVE_ARCH=NO -project ../../Projects/macOS/Dora.xcodeproj -target Dora -configuration Debug CONFIGURATION_BUILD_DIR=./build/Debug
../../Projects/macOS/build/Debug/Dora.app/Contents/MacOS/Dora —asset ../../Assets

