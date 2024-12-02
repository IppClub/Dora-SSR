#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../../Source/Rust"
cargo build --release --target aarch64-apple-darwin
cargo build --release --target x86_64-apple-darwin
lipo -create target/aarch64-apple-darwin/release/libdora_runtime.a target/x86_64-apple-darwin/release/libdora_runtime.a -output lib/macOS/libdora_runtime.a
xcodebuild ONLY_ACTIVE_ARCH=NO -project ../../Projects/macOS/Dora.xcodeproj -target Dora -configuration Release CONFIGURATION_BUILD_DIR=./build/Release
