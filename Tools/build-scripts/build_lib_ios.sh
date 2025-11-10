#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../../Source/Rust"

rustup target add aarch64-apple-ios
rustup target add aarch64-apple-ios-sim
rustup target add x86_64-apple-ios
cargo build --release --target aarch64-apple-ios
cp target/aarch64-apple-ios/release/libdora_runtime.a lib/iOS/libdora_runtime.a
cargo build --release --target aarch64-apple-ios-sim
cargo build --release --target x86_64-apple-ios
lipo -create target/aarch64-apple-ios-sim/release/libdora_runtime.a target/x86_64-apple-ios/release/libdora_runtime.a -output lib/iOS-Simulator/libdora_runtime.a
