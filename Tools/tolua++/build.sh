#!/bin/sh
cd "$( dirname "${BASH_SOURCE[0]}" )"
./tolua++mac -t -D -L basic.lua -o ../../Source/Lua/LuaBinding.cpp LuaBinding.pkg
./tolua++mac -t -D -L basic.lua -o ../../Source/Lua/LuaCode.cpp LuaCode.pkg

