cd /d %~dp0
tolua++ -t -D -L basic.lua -o "../../Source/Lua/LuaBinding.cpp" LuaBinding.pkg
tolua++ -t -D -L basic.lua -o "../../Source/Lua/LuaCode.cpp" LuaCode.pkg
