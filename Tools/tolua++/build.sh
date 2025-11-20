#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

LUA_BUILD_DIR="$SCRIPT_DIR/tolua++build/lua-5.1.5"
LUA_SRC_DIR="$LUA_BUILD_DIR/src"
LUA_BIN="$SCRIPT_DIR/lua"
LUA_LIB="$LUA_SRC_DIR/liblua.a"

build_lua() {
    echo "Building Lua 5.1.5..."
    (cd "$LUA_BUILD_DIR" && make macosx)
    cp "$LUA_SRC_DIR/lua" "$LUA_BIN"
}

build_lfs() {
    echo "Building LuaFileSystem..."
    LFS_DIR="$SCRIPT_DIR/tolua++build/lfs"
    cc -O2 -Wall -fPIC -I"$LUA_SRC_DIR" -bundle -undefined dynamic_lookup \
        "$LFS_DIR/lfs.c" "$LUA_LIB" -o "$SCRIPT_DIR/lfs.so"
}

if [ ! -x "$LUA_BIN" ]; then
    (cd "$LUA_BUILD_DIR" && make clean)
    build_lua
fi

if [ ! -f "$SCRIPT_DIR/lfs.so" ]; then
    if [ ! -f "$LUA_LIB" ]; then
        build_lua
    fi
    build_lfs
fi

$LUA_BIN "$SCRIPT_DIR/tolua++.lua"
