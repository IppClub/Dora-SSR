#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../../Source/Rust"

rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add x86_64-linux-android
cargo build --release --target aarch64-linux-android
cp target/aarch64-linux-android/release/libdora_runtime.a lib/Android/arm64-v8a/libdora_runtime.a
cargo build --release --target armv7-linux-androideabi
cp target/armv7-linux-androideabi/release/libdora_runtime.a lib/Android/armeabi-v7a/libdora_runtime.a
cargo build --release --target x86_64-linux-android
cp target/x86_64-linux-android/release/libdora_runtime.a lib/Android/x86_64/libdora_runtime.a

