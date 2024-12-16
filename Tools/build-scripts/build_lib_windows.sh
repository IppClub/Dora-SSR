#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../../Source/Rust"

rustup target add i686-pc-windows-msvc
cargo build --release --target i686-pc-windows-msvc
cp target/i686-pc-windows-msvc/release/dora_runtime.lib lib/Windows/dora_runtime.lib

