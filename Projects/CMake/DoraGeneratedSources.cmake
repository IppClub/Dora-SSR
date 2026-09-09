# Host-side generators required by every engine target.
include_guard(GLOBAL)

function(dora_add_generated_lua_sources target)
	if(NOT DEFINED DORA_ROOT)
		message(FATAL_ERROR "DORA_ROOT must be set before enabling generated Lua sources")
	endif()

	set(DORA_TOLUA_ROOT "${DORA_ROOT}/Tools/tolua++")
	set(DORA_LUA_GENERATED_SOURCES
		"${DORA_ROOT}/Source/Lua/LuaBinding.cpp"
		"${DORA_ROOT}/Source/Lua/LuaBindingWeb.cpp"
		"${DORA_ROOT}/Source/Lua/LuaCode.cpp"
		"${DORA_ROOT}/Source/Lua/LuaCodeWeb.cpp"
		"${DORA_ROOT}/Source/Lua/TealCompiler.cpp"
	)
	file(GLOB_RECURSE DORA_TOLUA_INPUTS CONFIGURE_DEPENDS
		"${DORA_TOLUA_ROOT}/*.lua"
		"${DORA_TOLUA_ROOT}/*.pkg"
		"${DORA_ROOT}/Source/*.h"
	)

	add_custom_command(
		OUTPUT ${DORA_LUA_GENERATED_SOURCES}
		COMMAND "${DORA_TOLUA_ROOT}/build.sh"
		DEPENDS ${DORA_TOLUA_INPUTS}
		WORKING_DIRECTORY "${DORA_TOLUA_ROOT}"
		COMMENT "Generating Dora Lua bindings"
		VERBATIM
	)
	add_custom_target(dora-lua-bindings DEPENDS ${DORA_LUA_GENERATED_SOURCES})
	add_dependencies(${target} dora-lua-bindings)
endfunction()
