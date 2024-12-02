#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../../Source/Rust"
rustup target add aarch64-apple-darwin
rustup target add x86_64-apple-darwin
cargo build --release --target aarch64-apple-darwin
cargo build --release --target x86_64-apple-darwin
lipo -create target/aarch64-apple-darwin/release/libdora_runtime.a target/x86_64-apple-darwin/release/libdora_runtime.a -output lib/macOS/libdora_runtime.a
xcodebuild archive -project ../../Projects/macOS/Dora.xcodeproj -scheme Dora -configuration Release -archivePath ../../Projects/macOS/build/Release/dora.xcarchive -arch arm64 -arch x86_64 ONLY_ACTIVE_ARCH=NO

echo "Built APP in 'Projects/macOS/build/Release/dora.xcarchive/Products/Applications'"
