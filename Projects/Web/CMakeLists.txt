cmake_minimum_required(VERSION 3.30)

project(Dora-Web LANGUAGES C CXX)

if(NOT EMSCRIPTEN)
	message(FATAL_ERROR "Projects/Web must be configured with emcmake")
endif()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXECUTABLE_SUFFIX ".html")

get_filename_component(DORA_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../.." REALPATH)
set(DORA_SOURCE_ROOT "${DORA_ROOT}/Source")
set(DORA_WEB_BOOTSTRAP_ASSETS "${CMAKE_CURRENT_SOURCE_DIR}/runtime-assets")
set(DORA_WEB_EMBEDDED_BGFX_DIR "${CMAKE_BINARY_DIR}/bgfx-embedded")
file(MAKE_DIRECTORY "${DORA_WEB_EMBEDDED_BGFX_DIR}/generated")
function(dora_web_embed_text input output)
	file(READ "${input}" hex_data HEX)
	string(REGEX REPLACE "(..)" "0x\\1," byte_data "${hex_data}")
	file(WRITE "${output}" "${byte_data}0x00\n")
endfunction()
dora_web_embed_text(
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/bgfx_shader.sh"
	"${DORA_WEB_EMBEDDED_BGFX_DIR}/generated/bgfx_shader.sh.h")
dora_web_embed_text(
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/bgfx_compute.sh"
	"${DORA_WEB_EMBEDDED_BGFX_DIR}/generated/bgfx_compute.sh.h")
file(GLOB_RECURSE DORA_WEB_BOOTSTRAP_ASSET_FILES CONFIGURE_DEPENDS
	"${DORA_WEB_BOOTSTRAP_ASSETS}/*")
set(DORA_WEB_BUILTIN_LIBS "${DORA_ROOT}/Assets/Script/Lib")
set(DORA_WEB_BUILTIN_FONT "${CMAKE_CURRENT_SOURCE_DIR}/preset-assets/Font/sarasa-mono-sc-regular.ttf" CACHE FILEPATH "Builtin player font (gallery uses full Chinese coverage)")
set(DORA_WEB_PRESET_LUA_MODULES
	BodyEx.lua
	DoraX.lua
	InputManager.lua
	Utils.lua
	lualib_bundle.lua
	UI/Control/Basic/CircleButton.lua
	UI/View/Control/Basic/ButtonBase.lua
	UI/View/Control/Basic/CircleButton.lua
	UI/View/Shape/Circle.lua
	UI/View/Shape/LineCircle.lua
	UI/View/Shape/LineRect.lua
	UI/View/Shape/Rectangle.lua
	UI/View/Shape/SolidCircle.lua
	UI/View/Shape/SolidRect.lua
	UI/View/Shape/Star.lua)
set(DORA_WEB_BUILTIN_LIB_FILES)
set(DORA_WEB_BUILTIN_PRELOAD_OPTIONS)
foreach(DORA_WEB_PRESET_LUA_MODULE IN LISTS DORA_WEB_PRESET_LUA_MODULES)
	list(APPEND DORA_WEB_BUILTIN_LIB_FILES "${DORA_WEB_BUILTIN_LIBS}/${DORA_WEB_PRESET_LUA_MODULE}")
	list(APPEND DORA_WEB_BUILTIN_PRELOAD_OPTIONS
		"SHELL:--preload-file \"${DORA_WEB_BUILTIN_LIBS}/${DORA_WEB_PRESET_LUA_MODULE}@/builtin/Script/Lib/${DORA_WEB_PRESET_LUA_MODULE}\"")
endforeach()
set(DORA_WEB_DEMO_GAME "${CMAKE_CURRENT_SOURCE_DIR}/demo-game")
file(GLOB_RECURSE DORA_WEB_DEMO_GAME_FILES CONFIGURE_DEPENDS
	"${DORA_WEB_DEMO_GAME}/*")
set(DORA_WEB_DEMO_SPRITE "${DORA_ROOT}/Assets/Image/logo.png")
set(DORA_WEB_AUDIO_FIXTURE_SCRIPT "${DORA_ROOT}/Tools/build-scripts/generate_web_audio_fixture.mjs")
set(DORA_WEB_RENDER_FIXTURE_SCRIPT "${DORA_ROOT}/Tools/build-scripts/generate_web_render_fixtures.mjs")
find_program(DORA_WEB_NODE_EXECUTABLE NAMES node REQUIRED)
set(DORA_RUST_RUNTIME
	"${DORA_ROOT}/Source/Rust/target/wasm32-unknown-emscripten/release/libdora_runtime.a"
	CACHE FILEPATH "Rust runtime static library for the Emscripten target"
)
if(NOT EXISTS "${DORA_RUST_RUNTIME}")
	message(FATAL_ERROR "Rust Web runtime not found: ${DORA_RUST_RUNTIME}")
endif()

include("${DORA_ROOT}/Projects/CMake/DoraEngineSources.cmake")
include("${DORA_ROOT}/Projects/CMake/DoraGeneratedSources.cmake")
include("${DORA_ROOT}/Projects/CMake/DoraLoveSources.cmake")

# P0 builds this tiny executable first so CI can prove that the locked
# toolchain produces an instantiable browser package before engine ports are
# allowed to obscure toolchain failures.
set(DORA_WEB_TASK_QUEUE_SOURCE "${DORA_SOURCE_ROOT}/Web/WebTaskQueue.cpp")
add_executable(dora-web-build-probe WebBuildProbe.cpp "${DORA_WEB_TASK_QUEUE_SOURCE}")
target_include_directories(dora-web-build-probe PRIVATE "${DORA_SOURCE_ROOT}")
target_link_libraries(dora-web-build-probe PRIVATE "${DORA_RUST_RUNTIME}")
target_compile_options(dora-web-build-probe PRIVATE -fexceptions)
target_link_options(dora-web-build-probe PRIVATE
	"-sALLOW_MEMORY_GROWTH=1"
	"-sENVIRONMENT=web,node"
	"-sEXIT_RUNTIME=0"
	"-sEXPORTED_FUNCTIONS=['_main','_dora_web_build_probe']"
	"-sEXPORTED_RUNTIME_METHODS=['ccall']"
	"SHELL:--shell-file \"${CMAKE_CURRENT_SOURCE_DIR}/shell.html\""
)
set_target_properties(dora-web-build-probe PROPERTIES
	OUTPUT_NAME "dora-player"
	RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
)

# The real Player target is enabled once P0 platform adapters compile. Keeping
# it on the shared manifest now prevents the Web target from growing a second,
# silently divergent engine source list.
option(DORA_WEB_BUILD_ENGINE "Compile the shared Dora engine sources for Web" OFF)
option(DORA_WEB_BUILD_LOVE_PROBE "Compile the Dora Love runtime as a non-release Web compatibility probe" OFF)
option(DORA_WEB_BUILD_LOVE_PTHREAD_PLAYER "Build the installable Love pthread Web Player" OFF)
option(DORA_WEB_PTHREADS "Build an opt-in shared-memory Web profile with Love thread workers" OFF)
set(DORA_WEB_LOVE_COMPLEX_PACKAGE "" CACHE FILEPATH "Licensed local .dora package used only by the opt-in P5-09 probe")
set(DORA_WEB_PROFILE "dora-preset" CACHE STRING "Dora Web feature preset")
set_property(CACHE DORA_WEB_PROFILE PROPERTY STRINGS core dora-preset custom)
if(NOT DORA_WEB_PROFILE MATCHES "^(core|dora-preset|custom)$")
	message(FATAL_ERROR "Unknown DORA_WEB_PROFILE=${DORA_WEB_PROFILE}; expected core, dora-preset or custom")
endif()

if(DORA_WEB_PROFILE STREQUAL "dora-preset")
	set(DORA_WEB_PRESET_FEATURE_DEFAULT ON)
else()
	set(DORA_WEB_PRESET_FEATURE_DEFAULT OFF)
endif()
foreach(DORA_WEB_TRISTATE_FEATURE IN ITEMS PHYSICS_2D ENTITY PLATFORMER BUILTIN_LIBS ML YUE MODEL_3D)
	set(DORA_WEB_FEATURE_${DORA_WEB_TRISTATE_FEATURE} AUTO CACHE STRING "Include this Dora Web feature: AUTO, ON or OFF")
	set_property(CACHE DORA_WEB_FEATURE_${DORA_WEB_TRISTATE_FEATURE} PROPERTY STRINGS AUTO ON OFF)
	string(TOUPPER "${DORA_WEB_FEATURE_${DORA_WEB_TRISTATE_FEATURE}}" DORA_WEB_FEATURE_VALUE)
	if(DORA_WEB_FEATURE_VALUE STREQUAL "AUTO")
		set(DORA_WEB_FEATURE_${DORA_WEB_TRISTATE_FEATURE} ${DORA_WEB_PRESET_FEATURE_DEFAULT})
	elseif(DORA_WEB_FEATURE_VALUE MATCHES "^(ON|OFF)$")
		set(DORA_WEB_FEATURE_${DORA_WEB_TRISTATE_FEATURE} ${DORA_WEB_FEATURE_VALUE})
	else()
		message(FATAL_ERROR "DORA_WEB_FEATURE_${DORA_WEB_TRISTATE_FEATURE}=${DORA_WEB_FEATURE_VALUE}; expected AUTO, ON or OFF")
	endif()
endforeach()
if(DORA_WEB_FEATURE_PLATFORMER AND NOT DORA_WEB_FEATURE_ENTITY)
	message(FATAL_ERROR "DORA_WEB_FEATURE_PLATFORMER requires DORA_WEB_FEATURE_ENTITY=ON")
endif()
if(DORA_WEB_FEATURE_PLATFORMER AND NOT DORA_WEB_FEATURE_PHYSICS_2D)
	message(FATAL_ERROR "DORA_WEB_FEATURE_PLATFORMER requires DORA_WEB_FEATURE_PHYSICS_2D=ON")
endif()

foreach(DORA_WEB_BOOL_FEATURE IN ITEMS PHYSICS_2D ENTITY PLATFORMER BUILTIN_LIBS ML YUE MODEL_3D)
	if(DORA_WEB_FEATURE_${DORA_WEB_BOOL_FEATURE})
		set(DORA_WEB_FEATURE_${DORA_WEB_BOOL_FEATURE}_JSON true)
	else()
		set(DORA_WEB_FEATURE_${DORA_WEB_BOOL_FEATURE}_JSON false)
	endif()
endforeach()
if(DORA_WEB_PTHREADS)
	set(DORA_WEB_THREAD_COMPILE_OPTIONS -pthread)
	set(DORA_WEB_THREAD_LINK_OPTIONS
		-pthread
		"-sUSE_PTHREADS=1"
		"-sPTHREAD_POOL_SIZE=4")
	set(DORA_WEB_THREADS_JSON true)
	set(DORA_WEB_CROSS_ORIGIN_ISOLATION_JSON true)
else()
	set(DORA_WEB_THREAD_COMPILE_OPTIONS)
	set(DORA_WEB_THREAD_LINK_OPTIONS "-sUSE_PTHREADS=0")
	set(DORA_WEB_THREADS_JSON false)
	set(DORA_WEB_CROSS_ORIGIN_ISOLATION_JSON false)
endif()
if(DORA_WEB_BUILD_LOVE_PTHREAD_PLAYER AND NOT DORA_WEB_PTHREADS)
	message(FATAL_ERROR "DORA_WEB_BUILD_LOVE_PTHREAD_PLAYER requires DORA_WEB_PTHREADS=ON")
endif()
configure_file(
	"${CMAKE_CURRENT_SOURCE_DIR}/web-features.json.in"
	"${CMAKE_BINARY_DIR}/dora-web-features.json"
	@ONLY)
file(READ "${CMAKE_BINARY_DIR}/dora-web-features.json" DORA_WEB_FEATURES_JSON)
file(WRITE "${CMAKE_BINARY_DIR}/dora-web-features.js"
	"(function installDoraWebFeatures(global) {\n"
	"  const features = ${DORA_WEB_FEATURES_JSON};\n"
	"  global.DoraWebFeatures = features;\n"
	"  const module = global.Module = global.Module || {};\n"
	"  module.doraWebFeatures = features;\n"
	"})(globalThis);\n")
if(DORA_WEB_BUILD_ENGINE)
	set(DORA_WEB_ENGINE_SOURCES ${DORA_ENGINE_SOURCES})
	list(REMOVE_ITEM DORA_WEB_ENGINE_SOURCES
		"${DORA_SOURCE_ROOT}/Lua/LuaFromXml.cpp"
		"${DORA_SOURCE_ROOT}/Lua/LuaBinding.cpp"
		"${DORA_SOURCE_ROOT}/Lua/LuaManual.cpp"
		"${DORA_SOURCE_ROOT}/Lua/LuaCode.cpp"
		"${DORA_SOURCE_ROOT}/Lua/TealCompiler.cpp"
		"${DORA_SOURCE_ROOT}/Wasm/WasmRuntime.cpp")
	list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/(Test|Lua/Xml)/")
	if(NOT DORA_WEB_FEATURE_ML)
		list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/(ML|3rdParty/ml)/")
	endif()
	if(NOT DORA_WEB_FEATURE_PLATFORMER)
		list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/Platformer/")
	endif()
	if(NOT DORA_WEB_FEATURE_ENTITY)
		list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/Entity/")
	endif()
	if(NOT DORA_WEB_FEATURE_PHYSICS_2D AND NOT DORA_WEB_FEATURE_MODEL_3D)
		list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/Physics/")
	elseif(NOT DORA_WEB_FEATURE_MODEL_3D)
		list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/Physics/(JoltBridge|JoltSources)\\.cpp$")
	endif()
	if(NOT DORA_WEB_FEATURE_MODEL_3D)
		list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/Cache/Model3DCache\.cpp$")
		list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/Node/(Node3D|Surface3D|Light3D|Model3D|Visual3D|View3D)\.cpp$")
		list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/Render/Camera3D\.cpp$")
	endif()
	list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/Node/(VideoNode|TIC80Node)\.cpp$")
	list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/3rdParty/tic80/")
	list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/3rdParty/(JoltPhysics|wasm3)/")
	list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/3rdParty/yarnflow/")
	if(NOT DORA_WEB_FEATURE_YUE)
		list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/3rdParty/yuescript/")
	endif()
	list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/Love/[^/]+\\.cpp$")
	list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/Http/HttpServer\\.cpp$")
	list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/Http/XrtNetwork\\.c$")
	list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/3rdParty/nfd/nfd_portal\\.cpp$")
	list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/3rdParty/soloud/backend/sdl/soloud_sdl2(_dll)?\\.(cpp|c)$")
	list(APPEND DORA_WEB_ENGINE_SOURCES
		"${DORA_SOURCE_ROOT}/Lua/LuaBindingWeb.cpp"
		"${DORA_SOURCE_ROOT}/Lua/LuaCodeWeb.cpp"
		"${DORA_SOURCE_ROOT}/Wasm/CallStack.cpp"
		"${DORA_WEB_TASK_QUEUE_SOURCE}"
		"${DORA_SOURCE_ROOT}/Web/WebAssetLoader.cpp"
		"${DORA_SOURCE_ROOT}/Web/WebHttp.cpp"
		"${DORA_SOURCE_ROOT}/Lua/LuaManual.cpp"
		"${DORA_SOURCE_ROOT}/Web/WebXrtNetwork.cpp"
		"${DORA_SOURCE_ROOT}/3rdParty/soloud/backend/sdl2_static/soloud_sdl2_static.cpp"
		"${DORA_SOURCE_ROOT}/3rdParty/LuaSocket/src/compat.c"
		"${DORA_SOURCE_ROOT}/3rdParty/LuaSocket/src/mime.c")
	add_library(dora-web-engine OBJECT ${DORA_WEB_ENGINE_SOURCES})
	dora_add_generated_lua_sources(dora-web-engine)
	target_compile_definitions(dora-web-engine PRIVATE
		BX_CONFIG_DEBUG=0
		BGFX_GL_CONFIG_TEXTURE_READ_BACK_EMULATION=1
		DORA_DEBUG=0
		DORA_EMSCRIPTEN
		DORA_NO_WA
		DORA_TEST=0
		DORA_WEB_MINIMAL
		DORA_WEB_TASK_AUTORELEASE_POOL
		WITH_SDL2_STATIC
		SPDLOG_FMT_EXTERNAL
		BGFX_CONFIG_RENDERER_OPENGLES=30
		d_m3HasWASI
		SQLITE_OMIT_LOAD_EXTENSION
	)
	if(NOT DORA_WEB_FEATURE_PHYSICS_2D)
		target_compile_definitions(dora-web-engine PRIVATE DORA_WEB_NO_PHYSICS_2D)
	endif()
	if(NOT DORA_WEB_FEATURE_ML)
		target_compile_definitions(dora-web-engine PRIVATE DORA_WEB_NO_ML)
	endif()
	if(DORA_WEB_FEATURE_YUE)
		target_compile_definitions(dora-web-engine PRIVATE DORA_WEB_YUE)
	endif()
	if(NOT DORA_WEB_FEATURE_ENTITY)
		target_compile_definitions(dora-web-engine PRIVATE DORA_WEB_NO_ENTITY)
	endif()
	if(NOT DORA_WEB_FEATURE_PLATFORMER)
		target_compile_definitions(dora-web-engine PRIVATE DORA_WEB_NO_PLATFORMER)
	endif()
	if(DORA_WEB_FEATURE_MODEL_3D)
		target_compile_definitions(dora-web-engine PRIVATE DORA_WEB_MODEL_3D)
	else()
		target_compile_definitions(dora-web-engine PRIVATE
			DORA_NO_3D_PHYSICS
			DORA_WEB_NO_MODEL_3D)
	endif()
	target_compile_options(dora-web-engine PRIVATE
		${DORA_WEB_THREAD_COMPILE_OPTIONS}
		-fwasm-exceptions
		"-ffile-prefix-map=${DORA_ROOT}=."
		"-fdebug-prefix-map=${DORA_ROOT}=."
		-Wno-deprecated-declarations
		-Wno-deprecated-pragma
		-Wno-macro-redefined
	)
	target_include_directories(dora-web-engine PRIVATE
		"${DORA_WEB_EMBEDDED_BGFX_DIR}"
		"${DORA_SOURCE_ROOT}/3rdParty/SDL2/include"
		"${DORA_SOURCE_ROOT}/3rdParty/bgfx/include"
		"${DORA_SOURCE_ROOT}/3rdParty/bimg/include"
		"${DORA_SOURCE_ROOT}/3rdParty/bx/include"
		"${DORA_SOURCE_ROOT}/3rdParty/bx/include/compat/emscripten"
		"${DORA_SOURCE_ROOT}"
		"${DORA_SOURCE_ROOT}/3rdParty"
		"${DORA_SOURCE_ROOT}/3rdParty/Love/src"
		"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules"
		"${DORA_SOURCE_ROOT}/3rdParty/JoltPhysics"
		"${DORA_SOURCE_ROOT}/3rdParty/Lua"
		"${DORA_SOURCE_ROOT}/3rdParty/LuaSocket/src"
		"${DORA_SOURCE_ROOT}/3rdParty/Zip"
		"${DORA_SOURCE_ROOT}/3rdParty/Zip/zlib"
		"${DORA_SOURCE_ROOT}/3rdParty/soloud"
		"${DORA_SOURCE_ROOT}/3rdParty/lodepng"
		"${DORA_SOURCE_ROOT}/3rdParty/imgui"
		"${DORA_SOURCE_ROOT}/3rdParty/implot"
		"${DORA_SOURCE_ROOT}/3rdParty/font"
		"${DORA_SOURCE_ROOT}/3rdParty/sqlite"
		"${DORA_SOURCE_ROOT}/3rdParty/dragonBones"
		"${DORA_SOURCE_ROOT}/3rdParty/wasm3"
		"${DORA_SOURCE_ROOT}/3rdParty/Effekseer"
	)
	if(DORA_WEB_BUILD_LOVE_PROBE)
		get_target_property(DORA_WEB_ENGINE_DEFINITIONS dora-web-engine COMPILE_DEFINITIONS)
		get_target_property(DORA_WEB_ENGINE_OPTIONS dora-web-engine COMPILE_OPTIONS)
		get_target_property(DORA_WEB_ENGINE_INCLUDES dora-web-engine INCLUDE_DIRECTORIES)
		add_library(dora-web-love-support STATIC
			${DORA_LOVE_SUPPORT_SOURCES})
		target_compile_definitions(dora-web-love-support PRIVATE
			${DORA_WEB_ENGINE_DEFINITIONS}
			LOVE_PROXY_USERVALUES=5)
		target_compile_options(dora-web-love-support PRIVATE
			${DORA_WEB_ENGINE_OPTIONS})
		target_include_directories(dora-web-love-support BEFORE PRIVATE
			"${DORA_LOVE_SOURCE_ROOT}/modules")
		target_include_directories(dora-web-love-support PRIVATE
			${DORA_WEB_ENGINE_INCLUDES}
			"${DORA_LOVE_SOURCE_ROOT}/libraries"
			"${DORA_SOURCE_ROOT}/3rdParty/Zip/zlib")
		add_library(dora-web-love-compile-probe OBJECT
			"${DORA_SOURCE_ROOT}/Love/LoveRuntime.cpp"
			"${DORA_SOURCE_ROOT}/Love/LoveVideoSources.cpp")
		target_compile_definitions(dora-web-love-compile-probe PRIVATE
			${DORA_WEB_ENGINE_DEFINITIONS}
			DORA_WEB_LOVE_PROBE)
		target_compile_options(dora-web-love-compile-probe PRIVATE
			${DORA_WEB_ENGINE_OPTIONS})
		target_include_directories(dora-web-love-compile-probe PRIVATE
			${DORA_WEB_ENGINE_INCLUDES}
			"${DORA_SOURCE_ROOT}/3rdParty/theora/include"
			"${DORA_SOURCE_ROOT}/3rdParty/theora/Source")
		add_library(dora-web-love-node-compile-probe OBJECT
			"${DORA_SOURCE_ROOT}/Love/LoveNode.cpp")
		target_compile_definitions(dora-web-love-node-compile-probe PRIVATE
			${DORA_WEB_ENGINE_DEFINITIONS}
			DORA_WEB_LOVE_PROBE)
		target_compile_options(dora-web-love-node-compile-probe PRIVATE
			${DORA_WEB_ENGINE_OPTIONS})
		target_include_directories(dora-web-love-node-compile-probe PRIVATE
			${DORA_WEB_ENGINE_INCLUDES}
			"${DORA_SOURCE_ROOT}/3rdParty/theora/include"
			"${DORA_SOURCE_ROOT}/3rdParty/theora/Source")
	endif()
endif()

# P0/P1 diagnostic target: build the Web graphics/compiler dependencies and
# attempt a real Dora executable link. It stays opt-in until the minimal
# binding and feature profile removes the remaining native/Love dependencies.
option(DORA_WEB_LINK_PLAYER "Attempt to link the Dora Web Player" OFF)
option(DORA_WEB_DIAGNOSTICS "Keep browser-readable Wasm function names and assertions" OFF)
if(DORA_WEB_BUILD_LOVE_PTHREAD_PLAYER AND (NOT DORA_WEB_BUILD_ENGINE OR NOT DORA_WEB_BUILD_LOVE_PROBE OR NOT DORA_WEB_LINK_PLAYER))
	message(FATAL_ERROR "DORA_WEB_BUILD_LOVE_PTHREAD_PLAYER requires the engine, Love support and Player link targets")
endif()
if(DORA_WEB_LINK_PLAYER)
	if(NOT DORA_WEB_BUILD_ENGINE)
		message(FATAL_ERROR "DORA_WEB_LINK_PLAYER requires DORA_WEB_BUILD_ENGINE=ON")
	endif()
	include("${DORA_ROOT}/Projects/CMake/DoraWebLinkSources.cmake")
	add_library(dora-web-link-deps OBJECT ${DORA_WEB_LINK_SOURCES})
	target_compile_definitions(dora-web-link-deps PRIVATE
		BX_CONFIG_DEBUG=0
		BGFX_GL_CONFIG_TEXTURE_READ_BACK_EMULATION=1
		DORA_EMSCRIPTEN
		BGFX_CONFIG_RENDERER_OPENGLES=30
		BGFX_CONFIG_MAX_FRAME_BUFFERS=256
		DORA_SHADERC_WEB_RUNTIME
		SHADERC_CONFIG_CLI=0
		SHADERC_CONFIG_GLSL=1
		SHADERC_CONFIG_HLSL=0
		SHADERC_CONFIG_METAL=0
		SHADERC_CONFIG_SPIRV=0
	)
	target_compile_options(dora-web-link-deps PRIVATE
		${DORA_WEB_THREAD_COMPILE_OPTIONS}
		-fno-rtti
		-fwasm-exceptions
		"-ffile-prefix-map=${DORA_ROOT}=."
		"-fdebug-prefix-map=${DORA_ROOT}=."
		-Wno-deprecated-declarations
		-Wno-deprecated-pragma
		-Wno-macro-redefined
	)
	target_include_directories(dora-web-link-deps BEFORE PRIVATE
		"${DORA_SOURCE_ROOT}/3rdParty/bimg/3rdparty")
	target_include_directories(dora-web-link-deps PRIVATE
		"${DORA_SOURCE_ROOT}"
		"${DORA_SOURCE_ROOT}/3rdParty"
		"${DORA_SOURCE_ROOT}/3rdParty/bx/include"
		"${DORA_SOURCE_ROOT}/3rdParty/bx/3rdparty"
		"${DORA_SOURCE_ROOT}/3rdParty/bx/include/compat/emscripten"
		"${DORA_SOURCE_ROOT}/3rdParty/bimg/include"
		"${DORA_SOURCE_ROOT}/3rdParty/bimg/3rdparty"
		"${DORA_SOURCE_ROOT}/3rdParty/bimg/3rdparty/astc-encoder/include"
		"${DORA_SOURCE_ROOT}/3rdParty/bgfx/include"
		"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty"
		"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/fcpp"
		"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/include"
		"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/src"
		"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/src/mesa"
		"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/src/glsl"
		"${DORA_SOURCE_ROOT}/3rdParty/bgfx/tools/shaderc"
		"${DORA_SOURCE_ROOT}/3rdParty/theora/include"
		"${DORA_SOURCE_ROOT}/3rdParty/theora/Source"
		"${DORA_SOURCE_ROOT}/3rdParty/Zip"
	)

	add_executable(dora-web-player
		$<TARGET_OBJECTS:dora-web-engine>
		$<TARGET_OBJECTS:dora-web-link-deps>)
	if(DORA_WEB_FEATURE_MODEL_3D)
		target_link_libraries(dora-web-player PRIVATE "${DORA_RUST_RUNTIME}")
	endif()
	target_link_options(dora-web-player PRIVATE
		"--ignore-dynamic-linking"
		"-fwasm-exceptions"
		"-sSUPPORT_LONGJMP=wasm"
		"-sUSE_SDL=2"
		"-sUSE_WEBGL2=1"
		"-sFULL_ES3=1"
		"-sALLOW_MEMORY_GROWTH=1"
		"-sINITIAL_MEMORY=256MB"
		"-sMAXIMUM_MEMORY=1GB"
		"-sEXIT_RUNTIME=0"
		"-sFILESYSTEM=1"
		"-lidbfs.js"
		"-sFETCH=1"
		${DORA_WEB_THREAD_LINK_OPTIONS}
		"-sEXPORTED_FUNCTIONS=['_main','_dora_web_stop','_dora_web_set_suspended','_dora_web_release_input','_dora_web_asset_complete']"
		"-sEXPORTED_RUNTIME_METHODS=['ccall','cwrap']"
		"SHELL:--pre-js \"${CMAKE_BINARY_DIR}/dora-web-features.js\""
		"SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/web-platform.js\""
		"SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/web-network.js\""
		"SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/web-package.js\""
		"SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/web-loader.js\""
		"SHELL:--preload-file \"${DORA_WEB_BOOTSTRAP_ASSETS}@/builtin\""
		"SHELL:--shell-file \"${CMAKE_CURRENT_SOURCE_DIR}/player-shell.html\""
	)
	if(DORA_WEB_FEATURE_BUILTIN_LIBS)
		target_link_options(dora-web-player PRIVATE
			${DORA_WEB_BUILTIN_PRELOAD_OPTIONS}
			"SHELL:--preload-file \"${DORA_WEB_BUILTIN_FONT}@/builtin/Font/sarasa-mono-sc-regular.ttf\"")
	endif()
	if(DORA_WEB_DIAGNOSTICS)
		target_link_options(dora-web-player PRIVATE
			"-sASSERTIONS=1"
			"--profiling-funcs")
	endif()
	set_target_properties(dora-web-player PROPERTIES
		OUTPUT_NAME "dora-player-runtime"
		LINK_DEPENDS "${CMAKE_BINARY_DIR}/dora-web-features.js;${CMAKE_CURRENT_SOURCE_DIR}/player-shell.html;${CMAKE_CURRENT_SOURCE_DIR}/web-platform.js;${CMAKE_CURRENT_SOURCE_DIR}/web-network.js;${CMAKE_CURRENT_SOURCE_DIR}/web-package.js;${CMAKE_CURRENT_SOURCE_DIR}/web-loader.js;${DORA_WEB_BOOTSTRAP_ASSET_FILES};${DORA_WEB_BUILTIN_LIB_FILES};${DORA_WEB_BUILTIN_FONT}"
		RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
	if(DORA_WEB_BUILD_LOVE_PROBE)
		add_executable(dora-web-love-link-probe
			LoveLinkProbe.cpp
			$<TARGET_OBJECTS:dora-web-engine>
			$<TARGET_OBJECTS:dora-web-link-deps>
			$<TARGET_OBJECTS:dora-web-love-compile-probe>)
		target_link_libraries(dora-web-love-link-probe PRIVATE
			dora-web-love-support)
		target_compile_definitions(dora-web-love-link-probe PRIVATE
			${DORA_WEB_ENGINE_DEFINITIONS})
		target_compile_options(dora-web-love-link-probe PRIVATE
			${DORA_WEB_ENGINE_OPTIONS})
		target_include_directories(dora-web-love-link-probe PRIVATE
			${DORA_WEB_ENGINE_INCLUDES})
		target_link_options(dora-web-love-link-probe PRIVATE
			"--ignore-dynamic-linking"
			"--no-entry"
			"-fwasm-exceptions"
			"-sSUPPORT_LONGJMP=wasm"
			"-sUSE_SDL=2"
			"-sUSE_WEBGL2=1"
			"-sFULL_ES3=1"
			"-sALLOW_MEMORY_GROWTH=1"
			"-sINITIAL_MEMORY=256MB"
			"-sMAXIMUM_MEMORY=1GB"
			"-sFILESYSTEM=1"
			"-sFETCH=1"
			${DORA_WEB_THREAD_LINK_OPTIONS}
			"-sEXPORTED_FUNCTIONS=['_dora_web_love_link_probe','_dora_web_love_link_probe_error','_dora_web_love_incremental_probe_begin','_dora_web_love_incremental_probe_step','_dora_web_love_incremental_probe_steps']"
			"-sEXPORTED_RUNTIME_METHODS=['ccall','UTF8ToString']"
			"SHELL:--preload-file \"${DORA_WEB_DEMO_GAME}/Font/web-fixture.ttf@/love-fixture.ttf\""
			"SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/love-link-probe-runner.js\"")
		set_target_properties(dora-web-love-link-probe PROPERTIES
			OUTPUT_NAME "dora-love-runtime-probe"
			LINK_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/love-link-probe-runner.js;${DORA_WEB_DEMO_GAME}/Font/web-fixture.ttf"
			RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")

		add_executable(dora-web-love-graphics-probe
			LoveGraphicsProbe.cpp
			$<TARGET_OBJECTS:dora-web-engine>
			$<TARGET_OBJECTS:dora-web-link-deps>
			$<TARGET_OBJECTS:dora-web-love-compile-probe>
			$<TARGET_OBJECTS:dora-web-love-node-compile-probe>)
		target_link_libraries(dora-web-love-graphics-probe PRIVATE
			dora-web-love-support)
		target_compile_definitions(dora-web-love-graphics-probe PRIVATE
			${DORA_WEB_ENGINE_DEFINITIONS}
			DORA_WEB_LOVE_PROBE)
		target_compile_options(dora-web-love-graphics-probe PRIVATE
			${DORA_WEB_ENGINE_OPTIONS})
		target_include_directories(dora-web-love-graphics-probe PRIVATE
			${DORA_WEB_ENGINE_INCLUDES})
		target_link_options(dora-web-love-graphics-probe PRIVATE
			"--ignore-dynamic-linking"
			"-fwasm-exceptions"
			"-sSUPPORT_LONGJMP=wasm"
			"-sUSE_SDL=2"
			"-sUSE_WEBGL2=1"
			"-sFULL_ES3=1"
			"-sALLOW_MEMORY_GROWTH=1"
			"-sINITIAL_MEMORY=256MB"
			"-sMAXIMUM_MEMORY=1GB"
			"-sEXIT_RUNTIME=0"
			"-sFILESYSTEM=1"
			"-sFETCH=1"
			${DORA_WEB_THREAD_LINK_OPTIONS}
			"-sEXPORTED_FUNCTIONS=['_main','_dora_web_stop','_dora_web_set_suspended','_dora_web_release_input','_dora_web_love_graphics_probe_start','_dora_web_love_graphics_probe_status','_dora_web_love_graphics_probe_release','_dora_web_love_graphics_probe_error']"
			"-sEXPORTED_RUNTIME_METHODS=['ccall','cwrap','UTF8ToString']"
			"SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/love-graphics-probe-runner.js\""
			"SHELL:--preload-file \"${DORA_ROOT}/Assets/Script/Lib/lualib_bundle.lua@/game/Script/Lib/lualib_bundle.lua\""
			"SHELL:--preload-file \"${CMAKE_CURRENT_SOURCE_DIR}/love-graphics-fixture@/love-graphics\""
			"SHELL:--shell-file \"${CMAKE_CURRENT_SOURCE_DIR}/player-shell.html\"")
		if(DORA_WEB_DIAGNOSTICS)
			target_link_options(dora-web-love-graphics-probe PRIVATE
				"-sASSERTIONS=1"
				"--profiling-funcs")
		endif()
		set_target_properties(dora-web-love-graphics-probe PROPERTIES
			OUTPUT_NAME "dora-love-graphics-probe"
			LINK_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/love-graphics-probe-runner.js;${CMAKE_CURRENT_SOURCE_DIR}/love-graphics-fixture/conf.lua;${CMAKE_CURRENT_SOURCE_DIR}/love-graphics-fixture/main.lua;${CMAKE_CURRENT_SOURCE_DIR}/player-shell.html;${DORA_ROOT}/Assets/Script/Lib/lualib_bundle.lua"
			RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")

		add_executable(dora-web-love-shader-probe
			LoveShaderProbe.cpp
			$<TARGET_OBJECTS:dora-web-engine>
			$<TARGET_OBJECTS:dora-web-link-deps>
			$<TARGET_OBJECTS:dora-web-love-compile-probe>
			$<TARGET_OBJECTS:dora-web-love-node-compile-probe>)
		target_link_libraries(dora-web-love-shader-probe PRIVATE
			dora-web-love-support)
		target_compile_definitions(dora-web-love-shader-probe PRIVATE
			${DORA_WEB_ENGINE_DEFINITIONS}
			DORA_WEB_LOVE_PROBE)
		target_compile_options(dora-web-love-shader-probe PRIVATE
			${DORA_WEB_ENGINE_OPTIONS})
		target_include_directories(dora-web-love-shader-probe PRIVATE
			${DORA_WEB_ENGINE_INCLUDES})
		target_link_options(dora-web-love-shader-probe PRIVATE
			"--ignore-dynamic-linking"
			"-fwasm-exceptions"
			"-sSUPPORT_LONGJMP=wasm"
			"-sUSE_SDL=2"
			"-sUSE_WEBGL2=1"
			"-sFULL_ES3=1"
			"-sALLOW_MEMORY_GROWTH=1"
			"-sINITIAL_MEMORY=256MB"
			"-sMAXIMUM_MEMORY=1GB"
			"-sEXIT_RUNTIME=0"
			"-sFILESYSTEM=1"
			"-sFETCH=1"
			${DORA_WEB_THREAD_LINK_OPTIONS}
			"-sEXPORTED_FUNCTIONS=['_main','_dora_web_stop','_dora_web_set_suspended','_dora_web_release_input','_dora_web_love_shader_probe_start','_dora_web_love_shader_probe_status','_dora_web_love_shader_probe_release','_dora_web_love_shader_probe_error']"
			"-sEXPORTED_RUNTIME_METHODS=['ccall','cwrap','UTF8ToString']"
			"SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/love-shader-probe-runner.js\""
			"SHELL:--preload-file \"${DORA_ROOT}/Assets/Script/Lib/lualib_bundle.lua@/game/Script/Lib/lualib_bundle.lua\""
			"SHELL:--preload-file \"${DORA_ROOT}/Assets/Shader/Love/varying.def.sc@/game/Shader/Love/varying.def.sc\""
			"SHELL:--preload-file \"${CMAKE_CURRENT_SOURCE_DIR}/love-shader-fixture@/love-shader\""
			"SHELL:--shell-file \"${CMAKE_CURRENT_SOURCE_DIR}/player-shell.html\"")
		if(DORA_WEB_DIAGNOSTICS)
			target_link_options(dora-web-love-shader-probe PRIVATE
				"-sASSERTIONS=1"
				"--profiling-funcs")
		endif()
		set_target_properties(dora-web-love-shader-probe PROPERTIES
			OUTPUT_NAME "dora-love-shader-probe"
			LINK_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/love-shader-probe-runner.js;${CMAKE_CURRENT_SOURCE_DIR}/love-shader-fixture/conf.lua;${CMAKE_CURRENT_SOURCE_DIR}/love-shader-fixture/main.lua;${CMAKE_CURRENT_SOURCE_DIR}/player-shell.html;${DORA_ROOT}/Assets/Script/Lib/lualib_bundle.lua;${DORA_ROOT}/Assets/Shader/Love/varying.def.sc"
			RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")

		set(DORA_WEB_LOVE_AUDIO_STAGE "${CMAKE_BINARY_DIR}/love-audio-fixture")
		set(DORA_WEB_LOVE_AUDIO_STAGE_FILES
			"${DORA_WEB_LOVE_AUDIO_STAGE}/conf.lua"
			"${DORA_WEB_LOVE_AUDIO_STAGE}/main.lua"
			"${DORA_WEB_LOVE_AUDIO_STAGE}/fixture.wav"
			"${DORA_WEB_LOVE_AUDIO_STAGE}/fixture.ogg")
		add_custom_command(
			OUTPUT ${DORA_WEB_LOVE_AUDIO_STAGE_FILES}
			COMMAND "${CMAKE_COMMAND}" -E make_directory "${DORA_WEB_LOVE_AUDIO_STAGE}"
			COMMAND "${CMAKE_COMMAND}" -E copy_if_different
				"${CMAKE_CURRENT_SOURCE_DIR}/love-audio-fixture/conf.lua"
				"${DORA_WEB_LOVE_AUDIO_STAGE}/conf.lua"
			COMMAND "${CMAKE_COMMAND}" -E copy_if_different
				"${CMAKE_CURRENT_SOURCE_DIR}/love-audio-fixture/main.lua"
				"${DORA_WEB_LOVE_AUDIO_STAGE}/main.lua"
			COMMAND "${DORA_WEB_NODE_EXECUTABLE}" "${DORA_WEB_AUDIO_FIXTURE_SCRIPT}"
				"${DORA_WEB_LOVE_AUDIO_STAGE}/fixture.wav"
				"${DORA_WEB_LOVE_AUDIO_STAGE}/fixture.ogg"
			DEPENDS
				"${CMAKE_CURRENT_SOURCE_DIR}/love-audio-fixture/conf.lua"
				"${CMAKE_CURRENT_SOURCE_DIR}/love-audio-fixture/main.lua"
				"${DORA_WEB_AUDIO_FIXTURE_SCRIPT}"
			VERBATIM)
		add_custom_target(dora-web-love-audio-fixture DEPENDS ${DORA_WEB_LOVE_AUDIO_STAGE_FILES})

		add_executable(dora-web-love-audio-probe
			LoveAudioProbe.cpp
			$<TARGET_OBJECTS:dora-web-engine>
			$<TARGET_OBJECTS:dora-web-link-deps>
			$<TARGET_OBJECTS:dora-web-love-compile-probe>
			$<TARGET_OBJECTS:dora-web-love-node-compile-probe>)
		add_dependencies(dora-web-love-audio-probe dora-web-love-audio-fixture)
		target_link_libraries(dora-web-love-audio-probe PRIVATE
			dora-web-love-support)
		target_compile_definitions(dora-web-love-audio-probe PRIVATE
			${DORA_WEB_ENGINE_DEFINITIONS}
			DORA_WEB_LOVE_PROBE)
		target_compile_options(dora-web-love-audio-probe PRIVATE
			${DORA_WEB_ENGINE_OPTIONS})
		target_include_directories(dora-web-love-audio-probe PRIVATE
			${DORA_WEB_ENGINE_INCLUDES})
		target_link_options(dora-web-love-audio-probe PRIVATE
			"--ignore-dynamic-linking"
			"-fwasm-exceptions"
			"-sSUPPORT_LONGJMP=wasm"
			"-sUSE_SDL=2"
			"-sUSE_WEBGL2=1"
			"-sFULL_ES3=1"
			"-sALLOW_MEMORY_GROWTH=1"
			"-sINITIAL_MEMORY=256MB"
			"-sMAXIMUM_MEMORY=1GB"
			"-sEXIT_RUNTIME=0"
			"-sFILESYSTEM=1"
			"-sFETCH=1"
			${DORA_WEB_THREAD_LINK_OPTIONS}
			"-sEXPORTED_FUNCTIONS=['_main','_dora_web_stop','_dora_web_set_suspended','_dora_web_release_input','_dora_web_love_audio_probe_start','_dora_web_love_audio_probe_status','_dora_web_love_audio_probe_restart_first','_dora_web_love_audio_probe_release_first','_dora_web_love_audio_probe_release','_dora_web_love_audio_probe_instance_count','_dora_web_love_audio_probe_source_count','_dora_web_love_audio_probe_playing_count','_dora_web_love_audio_probe_audio_file_delta','_dora_web_love_audio_probe_voice_delta','_dora_web_love_audio_probe_frame','_dora_web_love_audio_probe_error']"
			"-sEXPORTED_RUNTIME_METHODS=['ccall','cwrap','UTF8ToString']"
			"SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/love-audio-probe-runner.js\""
			"SHELL:--preload-file \"${DORA_ROOT}/Assets/Script/Lib/lualib_bundle.lua@/game/Script/Lib/lualib_bundle.lua\""
			"SHELL:--preload-file \"${DORA_WEB_LOVE_AUDIO_STAGE}@/love-audio\""
			"SHELL:--shell-file \"${CMAKE_CURRENT_SOURCE_DIR}/player-shell.html\"")
		if(DORA_WEB_DIAGNOSTICS)
			target_link_options(dora-web-love-audio-probe PRIVATE
				"-sASSERTIONS=1"
				"--profiling-funcs")
		endif()
		set_target_properties(dora-web-love-audio-probe PROPERTIES
			OUTPUT_NAME "dora-love-audio-probe"
			LINK_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/love-audio-probe-runner.js;${CMAKE_CURRENT_SOURCE_DIR}/love-audio-fixture/conf.lua;${CMAKE_CURRENT_SOURCE_DIR}/love-audio-fixture/main.lua;${CMAKE_CURRENT_SOURCE_DIR}/player-shell.html;${DORA_ROOT}/Assets/Script/Lib/lualib_bundle.lua;${DORA_WEB_AUDIO_FIXTURE_SCRIPT}"
			RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")

		if(DORA_WEB_BUILD_LOVE_PTHREAD_PLAYER)
			add_executable(dora-web-love-pthread-player
				LovePthreadPlayer.cpp
				$<TARGET_OBJECTS:dora-web-engine>
				$<TARGET_OBJECTS:dora-web-link-deps>
				$<TARGET_OBJECTS:dora-web-love-compile-probe>
				$<TARGET_OBJECTS:dora-web-love-node-compile-probe>)
			target_link_libraries(dora-web-love-pthread-player PRIVATE dora-web-love-support)
			target_compile_definitions(dora-web-love-pthread-player PRIVATE
				${DORA_WEB_ENGINE_DEFINITIONS}
				DORA_WEB_LOVE_PROBE)
			target_compile_options(dora-web-love-pthread-player PRIVATE ${DORA_WEB_ENGINE_OPTIONS})
			target_include_directories(dora-web-love-pthread-player PRIVATE ${DORA_WEB_ENGINE_INCLUDES})
			target_link_options(dora-web-love-pthread-player PRIVATE
				"--ignore-dynamic-linking"
				"-fwasm-exceptions"
				"-sSUPPORT_LONGJMP=wasm"
				"-sUSE_SDL=2"
				"-sUSE_WEBGL2=1"
				"-sFULL_ES3=1"
				"-sALLOW_MEMORY_GROWTH=1"
				"-sINITIAL_MEMORY=256MB"
				"-sMAXIMUM_MEMORY=1GB"
				"-sEXIT_RUNTIME=0"
				"-sFILESYSTEM=1"
				"-sFETCH=1"
				"-lidbfs.js"
				${DORA_WEB_THREAD_LINK_OPTIONS}
				"-sEXPORTED_FUNCTIONS=['_main','_dora_web_stop','_dora_web_set_suspended','_dora_web_release_input','_dora_web_love_player_start','_dora_web_love_player_status','_dora_web_love_player_stop','_dora_web_love_player_error','_dora_web_love_player_project']"
				"-sEXPORTED_RUNTIME_METHODS=['ccall','cwrap','UTF8ToString']"
				"SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/web-platform.js\""
				"SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/web-package.js\""
				"SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/love-pthread-player.js\""
				"SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/web-loader.js\""
				"SHELL:--preload-file \"${DORA_ROOT}/Assets/Script/Lib/lualib_bundle.lua@/game/Script/Lib/lualib_bundle.lua\""
				"SHELL:--preload-file \"${DORA_ROOT}/Assets/Shader/Love/varying.def.sc@/game/Shader/Love/varying.def.sc\""
				"SHELL:--shell-file \"${CMAKE_CURRENT_SOURCE_DIR}/love-pthread-player-shell.html\"")
			if(DORA_WEB_DIAGNOSTICS)
				target_link_options(dora-web-love-pthread-player PRIVATE "-sASSERTIONS=1" "--profiling-funcs")
			endif()
			set_target_properties(dora-web-love-pthread-player PROPERTIES
				OUTPUT_NAME "love-pthread-player"
				LINK_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/web-platform.js;${CMAKE_CURRENT_SOURCE_DIR}/web-package.js;${CMAKE_CURRENT_SOURCE_DIR}/web-loader.js;${CMAKE_CURRENT_SOURCE_DIR}/love-pthread-player.js;${CMAKE_CURRENT_SOURCE_DIR}/love-pthread-player-shell.html"
				RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
		endif()

		if(DORA_WEB_LOVE_COMPLEX_PACKAGE)
			if(NOT EXISTS "${DORA_WEB_LOVE_COMPLEX_PACKAGE}" OR IS_DIRECTORY "${DORA_WEB_LOVE_COMPLEX_PACKAGE}")
				message(FATAL_ERROR "DORA_WEB_LOVE_COMPLEX_PACKAGE is not a file")
			endif()
			set(DORA_WEB_LOVE_COMPLEX_STAGE "${CMAKE_BINARY_DIR}/love-complex-stage")
			add_custom_target(dora-web-love-complex-stage
				COMMAND "${CMAKE_COMMAND}" -E env
					"DORA_WEB_LOVE_COMPLEX_PACKAGE=${DORA_WEB_LOVE_COMPLEX_PACKAGE}"
					"${DORA_WEB_NODE_EXECUTABLE}"
					"${DORA_ROOT}/Tools/build-scripts/check_web_love_complex_input.mjs"
					"${CMAKE_CURRENT_SOURCE_DIR}/love-complex-project.json"
				COMMAND "${DORA_WEB_NODE_EXECUTABLE}"
					"${DORA_ROOT}/Tools/build-scripts/stage_web_love_complex_input.mjs"
					"${DORA_WEB_LOVE_COMPLEX_PACKAGE}"
					"${DORA_WEB_LOVE_COMPLEX_STAGE}"
				BYPRODUCTS "${DORA_WEB_LOVE_COMPLEX_STAGE}/main.lua"
				COMMENT "Verifying and staging the licensed Love complex project"
				VERBATIM)

			add_executable(dora-web-love-complex-probe
				LoveComplexProbe.cpp
				$<TARGET_OBJECTS:dora-web-engine>
				$<TARGET_OBJECTS:dora-web-link-deps>
				$<TARGET_OBJECTS:dora-web-love-compile-probe>
				$<TARGET_OBJECTS:dora-web-love-node-compile-probe>)
			add_dependencies(dora-web-love-complex-probe dora-web-love-complex-stage)
			target_link_libraries(dora-web-love-complex-probe PRIVATE dora-web-love-support)
			target_compile_definitions(dora-web-love-complex-probe PRIVATE
				${DORA_WEB_ENGINE_DEFINITIONS}
				DORA_WEB_LOVE_PROBE)
			target_compile_options(dora-web-love-complex-probe PRIVATE ${DORA_WEB_ENGINE_OPTIONS})
			target_include_directories(dora-web-love-complex-probe PRIVATE ${DORA_WEB_ENGINE_INCLUDES})
			target_link_options(dora-web-love-complex-probe PRIVATE
				"--ignore-dynamic-linking"
				"-fwasm-exceptions"
				"-sSUPPORT_LONGJMP=wasm"
				"-sUSE_SDL=2"
				"-sUSE_WEBGL2=1"
				"-sFULL_ES3=1"
				"-sALLOW_MEMORY_GROWTH=1"
				"-sINITIAL_MEMORY=256MB"
				"-sMAXIMUM_MEMORY=1GB"
				"-sEXIT_RUNTIME=0"
				"-sFILESYSTEM=1"
				"-sFETCH=1"
				"-lidbfs.js"
				${DORA_WEB_THREAD_LINK_OPTIONS}
				"-sEXPORTED_FUNCTIONS=['_main','_dora_web_stop','_dora_web_set_suspended','_dora_web_release_input','_dora_web_love_complex_probe_start','_dora_web_love_complex_probe_status','_dora_web_love_complex_probe_release','_dora_web_love_complex_probe_frame','_dora_web_love_complex_probe_has_graphics','_dora_web_love_complex_probe_is_updating','_dora_web_love_complex_probe_runtime_status','_dora_web_love_complex_probe_audio_sources','_dora_web_love_complex_probe_audio_file_delta','_dora_web_love_complex_probe_voice_delta','_dora_web_love_complex_probe_pointer_presses','_dora_web_love_complex_probe_pointer_button','_dora_web_love_complex_probe_pointer_from_mouse','_dora_web_love_complex_probe_pointer_x','_dora_web_love_complex_probe_pointer_y','_dora_web_love_complex_probe_game_state','_dora_web_love_complex_probe_skip_tutorial','_dora_web_love_complex_probe_force_save','_dora_web_love_complex_probe_error']"
				"-sEXPORTED_RUNTIME_METHODS=['ccall','cwrap','UTF8ToString']"
				"SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/web-platform.js\""
				"SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/love-complex-probe-runner.js\""
				"SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/web-loader.js\""
				"SHELL:--preload-file \"${DORA_ROOT}/Assets/Script/Lib/lualib_bundle.lua@/game/Script/Lib/lualib_bundle.lua\""
				"SHELL:--preload-file \"${DORA_ROOT}/Assets/Shader/Love/varying.def.sc@/game/Shader/Love/varying.def.sc\""
				"SHELL:--preload-file \"${DORA_WEB_LOVE_COMPLEX_STAGE}@/love-complex\""
				"SHELL:--shell-file \"${CMAKE_CURRENT_SOURCE_DIR}/player-shell.html\"")
			if(DORA_WEB_DIAGNOSTICS)
				target_link_options(dora-web-love-complex-probe PRIVATE "-sASSERTIONS=1" "--profiling-funcs")
			endif()
			set_target_properties(dora-web-love-complex-probe PROPERTIES
				OUTPUT_NAME "dora-love-complex-probe"
				LINK_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/web-platform.js;${CMAKE_CURRENT_SOURCE_DIR}/web-loader.js;${CMAKE_CURRENT_SOURCE_DIR}/love-complex-probe-runner.js;${CMAKE_CURRENT_SOURCE_DIR}/player-shell.html;${DORA_ROOT}/Tools/build-scripts/check_web_love_complex_input.mjs;${DORA_ROOT}/Tools/build-scripts/stage_web_love_complex_input.mjs;${CMAKE_CURRENT_SOURCE_DIR}/love-complex-project.json"
				RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
		endif()
	endif()
	set(DORA_WEB_DEMO_STAGE "${CMAKE_BINARY_DIR}/web-game-stage")
	add_custom_target(dora-web-game-package
		COMMAND "${CMAKE_COMMAND}" -E remove_directory "${CMAKE_BINARY_DIR}/assets"
		COMMAND "${CMAKE_COMMAND}" -E remove_directory "${DORA_WEB_DEMO_STAGE}"
		COMMAND "${CMAKE_COMMAND}" -E copy_directory "${DORA_WEB_DEMO_GAME}" "${DORA_WEB_DEMO_STAGE}"
		COMMAND "${CMAKE_COMMAND}" -E make_directory "${DORA_WEB_DEMO_STAGE}/Image"
		COMMAND "${CMAKE_COMMAND}" -E make_directory "${DORA_WEB_DEMO_STAGE}/Audio"
		COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${DORA_WEB_DEMO_SPRITE}" "${DORA_WEB_DEMO_STAGE}/Image/logo.png"
		COMMAND "${DORA_WEB_NODE_EXECUTABLE}" "${DORA_WEB_AUDIO_FIXTURE_SCRIPT}" "${DORA_WEB_DEMO_STAGE}/Audio/fixture.wav" "${DORA_WEB_DEMO_STAGE}/Audio/fixture.ogg"
		COMMAND "${DORA_WEB_NODE_EXECUTABLE}" "${DORA_WEB_RENDER_FIXTURE_SCRIPT}" "${DORA_WEB_DEMO_STAGE}"
		COMMAND "${CMAKE_COMMAND}" -E env
			"DORA_WEB_GAME_PROFILE=${DORA_WEB_PROFILE}"
			"DORA_WEB_EAGER_GAME_ASSETS=0"
			"${DORA_WEB_NODE_EXECUTABLE}"
			"${DORA_ROOT}/Tools/build-scripts/package_web_game.mjs"
			"${DORA_WEB_DEMO_STAGE}"
			"${CMAKE_BINARY_DIR}"
			"init.lua"
		DEPENDS "${DORA_ROOT}/Tools/build-scripts/package_web_game.mjs" "${DORA_WEB_AUDIO_FIXTURE_SCRIPT}" "${DORA_WEB_RENDER_FIXTURE_SCRIPT}" ${DORA_WEB_DEMO_GAME_FILES} "${DORA_WEB_DEMO_SPRITE}"
		COMMENT "Packaging the Dora Web demo manifest")
	add_dependencies(dora-web-player dora-web-game-package)
endif()
