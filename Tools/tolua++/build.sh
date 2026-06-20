#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

LUA_BUILD_DIR="$SCRIPT_DIR/tolua++build/lua-5.1.5"
LUA_SRC_DIR="$LUA_BUILD_DIR/src"
PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
OUTPUT_DIR="$SCRIPT_DIR/tolua++build/bin/$PLATFORM-$ARCH"
LUA_BIN="$OUTPUT_DIR/lua"
LUA_LIB="$LUA_SRC_DIR/liblua.a"
LFS_SO="$OUTPUT_DIR/lfs.so"

build_lua() {
    echo "Building Lua 5.1.5..."
    (cd "$LUA_BUILD_DIR" && make clean)
    case "$PLATFORM" in
        darwin)
            (cd "$LUA_BUILD_DIR" && make macosx)
            ;;
        linux)
            (cd "$LUA_SRC_DIR" && make all MYCFLAGS="-DLUA_USE_POSIX -DLUA_USE_DLOPEN" MYLIBS="-Wl,-E -ldl")
            ;;
        *)
            echo "Unsupported platform: $PLATFORM" >&2
            exit 1
            ;;
    esac
    mkdir -p "$OUTPUT_DIR"
    cp "$LUA_SRC_DIR/lua" "$LUA_BIN"
}

build_lfs() {
    echo "Building LuaFileSystem..."
    LFS_DIR="$SCRIPT_DIR/tolua++build/lfs"
    mkdir -p "$OUTPUT_DIR"
    case "$PLATFORM" in
        darwin)
            cc -O2 -Wall -fPIC -I"$LUA_SRC_DIR" -bundle -undefined dynamic_lookup \
                "$LFS_DIR/lfs.c" "$LUA_LIB" -o "$LFS_SO"
            ;;
        linux)
            cc -O2 -Wall -fPIC -I"$LUA_SRC_DIR" -shared \
                "$LFS_DIR/lfs.c" -o "$LFS_SO"
            ;;
        *)
            echo "Unsupported platform: $PLATFORM" >&2
            exit 1
            ;;
    esac
}

if [ ! -x "$LUA_BIN" ] || ! "$LUA_BIN" -v >/dev/null 2>&1; then
    build_lua
fi

if [ ! -f "$LFS_SO" ] || ! LUA_CPATH="$OUTPUT_DIR/?.so;;" "$LUA_BIN" -e 'require("lfs")' >/dev/null 2>&1; then
    if [ ! -f "$LUA_LIB" ]; then
        build_lua
    fi
    build_lfs
fi

LUA_CPATH="$OUTPUT_DIR/?.so;;" "$LUA_BIN" "$SCRIPT_DIR/tolua++.lua"
