cmake_minimum_required(VERSION 3.13)

project(Dora-SSR-Web LANGUAGES C CXX)

if(NOT EMSCRIPTEN)
	message(FATAL_ERROR "Projects/Emscripten must be configured with emcmake")
endif()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXECUTABLE_SUFFIX ".html")

set(DORA_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../..")
set(DORA_SOURCE_ROOT "${DORA_ROOT}/Source")
set(DORA_BGFX_ROOT "${DORA_SOURCE_ROOT}/3rdParty/bgfx")
set(DORA_SDL2_ROOT "${DORA_SOURCE_ROOT}/3rdParty/SDL2")
set(DORA_ASSETS_ROOT "${DORA_ROOT}/Assets")
set(DORA_OPENMPT_ROOT "${DORA_SOURCE_ROOT}/3rdParty/libopenmpt")
set(DORA_THEORA_ROOT "${DORA_SOURCE_ROOT}/3rdParty/theora")
set(DORA_RUST_RUNTIME
	"${DORA_ROOT}/Source/Rust/target/wasm32-unknown-emscripten/release/libdora_runtime.a"
	CACHE FILEPATH "Rust runtime static library for the Emscripten target")

if(NOT EXISTS "${DORA_RUST_RUNTIME}")
	message(FATAL_ERROR
		"Rust Emscripten runtime not found: ${DORA_RUST_RUNTIME}. "
		"Build Source/Rust for wasm32-unknown-emscripten first.")
endif()

set(DORA_EMSCRIPTEN_SHELL
	"${CMAKE_CURRENT_SOURCE_DIR}/shell.html"
	CACHE FILEPATH "HTML shell passed to the Emscripten linker")

if(NOT EXISTS "${DORA_EMSCRIPTEN_SHELL}")
	message(FATAL_ERROR "Emscripten shell file does not exist: ${DORA_EMSCRIPTEN_SHELL}")
endif()
if(NOT EXISTS "${DORA_ASSETS_ROOT}")
	message(FATAL_ERROR "Dora assets directory does not exist: ${DORA_ASSETS_ROOT}")
endif()
file(GLOB_RECURSE DORA_ASSET_FILES CONFIGURE_DEPENDS
	"${DORA_ASSETS_ROOT}/*")

# Keep the web source manifest aligned with the maintained Linux engine
# manifest. The two targets share the same portable Dora sources; only the
# platform libraries and entry-point/link flags differ.
file(STRINGS "${DORA_ROOT}/Projects/Linux/CMakeLists.txt" DORA_LINUX_SOURCE_LINES
	REGEX "^[ \t]*\\.\\./\\.\\./Source/.*\\.(cpp|c)$")
set(DORA_ENGINE_SOURCES)
foreach(DORA_LINUX_SOURCE_LINE IN LISTS DORA_LINUX_SOURCE_LINES)
	string(STRIP "${DORA_LINUX_SOURCE_LINE}" DORA_LINUX_SOURCE_LINE)
	string(REGEX REPLACE "^\\.\\./\\.\\./" "" DORA_ENGINE_SOURCE "${DORA_LINUX_SOURCE_LINE}")
	list(APPEND DORA_ENGINE_SOURCES "${DORA_ROOT}/${DORA_ENGINE_SOURCE}")
endforeach()

list(FILTER DORA_ENGINE_SOURCES EXCLUDE REGEX ".*/Source/Http/HttpServer\\.cpp$")
list(FILTER DORA_ENGINE_SOURCES EXCLUDE REGEX ".*/Source/Http/XrtNetwork\\.c$")
list(FILTER DORA_ENGINE_SOURCES EXCLUDE REGEX ".*/Source/3rdParty/nfd/nfd_portal\\.cpp$")
list(FILTER DORA_ENGINE_SOURCES EXCLUDE REGEX ".*/Source/3rdParty/soloud/backend/sdl/soloud_sdl2\\.cpp$")
list(FILTER DORA_ENGINE_SOURCES EXCLUDE REGEX ".*/Source/3rdParty/soloud/backend/sdl/soloud_sdl2_dll\\.c$")
list(APPEND DORA_ENGINE_SOURCES "${DORA_SOURCE_ROOT}/Http/HttpServerEmscripten.cpp")
list(APPEND DORA_ENGINE_SOURCES "${DORA_SOURCE_ROOT}/Http/XrtNetworkEmscripten.cpp")
list(APPEND DORA_ENGINE_SOURCES
	"${DORA_SOURCE_ROOT}/3rdParty/soloud/backend/sdl2_static/soloud_sdl2_static.cpp")
list(APPEND DORA_ENGINE_SOURCES
	"${DORA_SOURCE_ROOT}/Wasm/WasmRuntimeEmscripten.cpp")

# Linux links these portable LOVE pieces from liblove. Web builds them in the
# engine target because the native archive is platform-specific. Keep this
# first set limited to modules used by Dora's embedded runtime; platform
# backends and the upstream LOVE main loop are intentionally excluded.
file(GLOB DORA_LOVE_COMMON_WASM_SOURCES CONFIGURE_DEPENDS
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/common/*.cpp")
file(GLOB DORA_LOVE_IMAGE_WASM_SOURCES CONFIGURE_DEPENDS
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/image/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/image/**/*.cpp")
file(GLOB DORA_LOVE_FONT_WASM_SOURCES CONFIGURE_DEPENDS
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/font/*.cpp")
file(GLOB_RECURSE DORA_LOVE_BOX2D_WASM_SOURCES CONFIGURE_DEPENDS
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/libraries/Box2D/*.cpp")
list(FILTER DORA_LOVE_COMMON_WASM_SOURCES EXCLUDE REGEX "/(Data|Stream|floattypes)\\.cpp$")
file(GLOB DORA_LOVE_MODULE_WASM_SOURCES CONFIGURE_DEPENDS
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/math/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/data/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/audio/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/event/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/window/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/keyboard/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/mouse/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/touch/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/joystick/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/physics/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/physics/box2d/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/filesystem/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/graphics/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/sound/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/system/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/timer/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/thread/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules/video/wrap_VideoStream.cpp")
list(FILTER DORA_LOVE_MODULE_WASM_SOURCES EXCLUDE REGEX "/modules/audio/wrap_(Audio|RecordingDevice)\\.cpp$")
list(FILTER DORA_LOVE_MODULE_WASM_SOURCES EXCLUDE REGEX "/modules/thread/threads\\.cpp$")
list(FILTER DORA_LOVE_MODULE_WASM_SOURCES EXCLUDE REGEX "/modules/graphics/wrap_Graphics\\.cpp$")
list(FILTER DORA_LOVE_MODULE_WASM_SOURCES EXCLUDE REGEX "/modules/filesystem/(File|FileData)\\.cpp$")
file(GLOB DORA_OPENMPT_COMMON_WASM_SOURCES CONFIGURE_DEPENDS
	"${DORA_OPENMPT_ROOT}/common/*.cpp")
file(GLOB DORA_OPENMPT_SOUNDLIB_WASM_SOURCES CONFIGURE_DEPENDS
	"${DORA_OPENMPT_ROOT}/soundlib/*.cpp"
	"${DORA_OPENMPT_ROOT}/soundlib/plugins/*.cpp"
	"${DORA_OPENMPT_ROOT}/soundlib/plugins/dmo/*.cpp")
file(GLOB DORA_OPENMPT_DSP_WASM_SOURCES CONFIGURE_DEPENDS
	"${DORA_OPENMPT_ROOT}/sounddsp/*.cpp")
set(DORA_OPENMPT_API_WASM_SOURCES
	"${DORA_OPENMPT_ROOT}/libopenmpt/libopenmpt_c.cpp"
	"${DORA_OPENMPT_ROOT}/libopenmpt/libopenmpt_cxx.cpp"
	"${DORA_OPENMPT_ROOT}/libopenmpt/libopenmpt_impl.cpp"
	"${DORA_OPENMPT_ROOT}/libopenmpt/libopenmpt_ext_impl.cpp")
set(DORA_THEORA_WASM_SOURCES "${DORA_THEORA_ROOT}/TheoraSources.c")
set(DORA_LOVE_OPENMPT_WASM_SOURCES
	"${DORA_SOURCE_ROOT}/3rdParty/soloud/audiosource/openmpt/soloud_openmpt.cpp")
set(DORA_LOVE_NOISE_WASM_SOURCES
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/libraries/noise1234/noise1234.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/libraries/noise1234/simplexnoise1234.cpp")
set(DORA_LOVE_LZ4_WASM_SOURCES
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/libraries/lz4/lz4.c"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/libraries/lz4/lz4hc.c")
list(APPEND DORA_ENGINE_SOURCES
	${DORA_LOVE_COMMON_WASM_SOURCES}
	${DORA_LOVE_IMAGE_WASM_SOURCES}
	${DORA_LOVE_FONT_WASM_SOURCES}
	${DORA_LOVE_BOX2D_WASM_SOURCES}
	${DORA_LOVE_MODULE_WASM_SOURCES}
	${DORA_OPENMPT_COMMON_WASM_SOURCES}
	${DORA_OPENMPT_SOUNDLIB_WASM_SOURCES}
	${DORA_OPENMPT_DSP_WASM_SOURCES}
	${DORA_OPENMPT_API_WASM_SOURCES}
	${DORA_THEORA_WASM_SOURCES}
	${DORA_LOVE_OPENMPT_WASM_SOURCES}
	${DORA_LOVE_NOISE_WASM_SOURCES}
	${DORA_LOVE_LZ4_WASM_SOURCES})
set_source_files_properties(
	${DORA_OPENMPT_COMMON_WASM_SOURCES}
	${DORA_OPENMPT_SOUNDLIB_WASM_SOURCES}
	${DORA_OPENMPT_DSP_WASM_SOURCES}
	${DORA_OPENMPT_API_WASM_SOURCES}
	PROPERTIES COMPILE_DEFINITIONS MPT_COMPILER_QUIRK_NO_WCHAR)

file(GLOB DORA_BX_WASM_SOURCES CONFIGURE_DEPENDS "${DORA_SOURCE_ROOT}/3rdParty/bx/src/*.cpp")
file(GLOB DORA_BIMG_WASM_SOURCES CONFIGURE_DEPENDS "${DORA_SOURCE_ROOT}/3rdParty/bimg/src/*.cpp")
file(GLOB DORA_ASTC_WASM_SOURCES CONFIGURE_DEPENDS
	"${DORA_SOURCE_ROOT}/3rdParty/bimg/3rdparty/astc-encoder/source/*.cpp")
file(GLOB DORA_FCPP_WASM_SOURCES CONFIGURE_DEPENDS
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/fcpp/*.c")
list(FILTER DORA_FCPP_WASM_SOURCES EXCLUDE REGEX "/usecpp\.c$")
set_source_files_properties(${DORA_FCPP_WASM_SOURCES} PROPERTIES
	COMPILE_DEFINITIONS UNIX)
file(GLOB_RECURSE DORA_GLSL_OPT_WASM_SOURCES CONFIGURE_DEPENDS
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/src/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/src/*.c")
list(FILTER DORA_GLSL_OPT_WASM_SOURCES EXCLUDE REGEX "/node/.*")
list(FILTER DORA_GLSL_OPT_WASM_SOURCES EXCLUDE REGEX "/glsl/main\.cpp$")
list(APPEND DORA_ENGINE_SOURCES
	${DORA_BX_WASM_SOURCES}
	${DORA_FCPP_WASM_SOURCES}
	${DORA_GLSL_OPT_WASM_SOURCES})

set(DORA_BGFX_WASM_SOURCES
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/bgfx.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/debug_renderdoc.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/glcontext_html5.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/renderer_agc.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/renderer_d3d11.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/renderer_d3d12.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/renderer_gnm.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/renderer_gl.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/renderer_nvn.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/renderer_noop.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/renderer_vk.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/shader.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/shader_dxbc.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/shader_spirv.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/topology.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/vertexlayout.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/dora/DoraShaderc.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/tools/shaderc/shaderc.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/tools/shaderc/shaderc_glsl.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/tools/shaderc/shaderc_hlsl.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/tools/shaderc/shaderc_metal.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/tools/shaderc/shaderc_pssl.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/tools/shaderc/shaderc_spirv.cpp")
list(APPEND DORA_ENGINE_SOURCES ${DORA_BGFX_WASM_SOURCES})

if(NOT DORA_ENGINE_SOURCES)
	message(FATAL_ERROR "Could not derive Dora source manifest from Projects/Linux/CMakeLists.txt")
endif()

add_library(dora-engine OBJECT ${DORA_ENGINE_SOURCES})
add_library(dora-bimg OBJECT
	${DORA_BIMG_WASM_SOURCES}
	${DORA_ASTC_WASM_SOURCES})
add_executable(dora-ssr
	$<TARGET_OBJECTS:dora-engine>
	$<TARGET_OBJECTS:dora-bimg>)
target_compile_definitions(dora-ssr PRIVATE
	BX_CONFIG_DEBUG=0
	DORA_EMSCRIPTEN)
target_include_directories(dora-ssr PRIVATE
	"${DORA_SOURCE_ROOT}"
	"${DORA_SOURCE_ROOT}/3rdParty"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/libraries"
	"${DORA_SOURCE_ROOT}/3rdParty/lodepng"
	"${DORA_SOURCE_ROOT}/3rdParty/bx/include"
	"${DORA_SOURCE_ROOT}/3rdParty/bx/3rdparty"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/include"
	"${DORA_SOURCE_ROOT}/3rdParty/bimg/include"
	"${DORA_SOURCE_ROOT}/3rdParty/bimg/3rdparty/astc-encoder/include"
	"${DORA_SOURCE_ROOT}/3rdParty/bimg/3rdparty"
	"${DORA_SOURCE_ROOT}/3rdParty/Lua"
	"${DORA_SOURCE_ROOT}/3rdParty/Zip"
	"${DORA_SOURCE_ROOT}/3rdParty/Zip/zlib"
	"${DORA_SOURCE_ROOT}/3rdParty/soloud"
	"${DORA_SOURCE_ROOT}/3rdParty/imgui"
	"${DORA_SOURCE_ROOT}/3rdParty/implot"
	"${DORA_SOURCE_ROOT}/3rdParty/font"
	"${DORA_SOURCE_ROOT}/3rdParty/sqlite"
	"${DORA_SOURCE_ROOT}/3rdParty/dragonBones"
	"${DORA_SOURCE_ROOT}/3rdParty/JoltPhysics"
	"${DORA_SOURCE_ROOT}/3rdParty/wasm3"
	"${DORA_SOURCE_ROOT}/3rdParty/Effekseer"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/fcpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/include"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/src"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/src/mesa"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/src/glsl"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/tools/shaderc"
	"${DORA_SOURCE_ROOT}/3rdParty/theora/include"
	"${DORA_OPENMPT_ROOT}"
	"${DORA_OPENMPT_ROOT}/common"
	"${DORA_OPENMPT_ROOT}/include"
	"${DORA_OPENMPT_ROOT}/libopenmpt"
	"${DORA_SDL2_ROOT}/include")

target_compile_options(dora-ssr PRIVATE
	-Wno-deprecated-declarations
	-Wno-deprecated-pragma
	-Wno-macro-redefined)

target_compile_definitions(dora-engine PRIVATE
	BX_CONFIG_DEBUG=0
	DORA_EMSCRIPTEN
	WITH_SDL2_STATIC
	LOVE_LINUX
	LOVE_PROXY_USERVALUES=5
	LIBOPENMPT_BUILD
	MPT_BUILD_DORA
	MPT_WITH_MINIZ
	SPDLOG_FMT_EXTERNAL
	BGFX_CONFIG_RENDERER_OPENGLES=30
	BGFX_CONFIG_MAX_FRAME_BUFFERS=256
	SHADERC_CONFIG_CLI=0
	SHADERC_CONFIG_GLSL=1
	SHADERC_CONFIG_HLSL=0
	SHADERC_CONFIG_METAL=0
	SHADERC_CONFIG_SPIRV=0
	d_m3HasWASI
	SQLITE_OMIT_LOAD_EXTENSION)
target_compile_definitions(dora-bimg PRIVATE
	BX_CONFIG_DEBUG=0
	DORA_EMSCRIPTEN)
target_compile_options(dora-engine PRIVATE
	-Wno-deprecated-declarations
	-Wno-deprecated-pragma
	-Wno-macro-redefined)
target_compile_options(dora-bimg PRIVATE
	-Wno-deprecated-declarations
	-Wno-deprecated-pragma
	-Wno-macro-redefined)
target_include_directories(dora-engine PRIVATE
	"${DORA_SOURCE_ROOT}"
	"${DORA_SOURCE_ROOT}/3rdParty"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules"
	"${DORA_SOURCE_ROOT}/3rdParty/Love/src/libraries"
	"${DORA_SOURCE_ROOT}/3rdParty/lodepng"
	"${DORA_SOURCE_ROOT}/3rdParty/bx/include"
	"${DORA_SOURCE_ROOT}/3rdParty/bx/3rdparty"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/include"
	"${DORA_SOURCE_ROOT}/3rdParty/bimg/include"
	"${DORA_SOURCE_ROOT}/3rdParty/bimg/3rdparty/astc-encoder/include"
	"${DORA_SOURCE_ROOT}/3rdParty/bimg/3rdparty"
	"${DORA_SOURCE_ROOT}/3rdParty/Lua"
	"${DORA_SOURCE_ROOT}/3rdParty/Zip"
	"${DORA_SOURCE_ROOT}/3rdParty/Zip/zlib"
	"${DORA_SOURCE_ROOT}/3rdParty/soloud"
	"${DORA_SOURCE_ROOT}/3rdParty/imgui"
	"${DORA_SOURCE_ROOT}/3rdParty/implot"
	"${DORA_SOURCE_ROOT}/3rdParty/font"
	"${DORA_SOURCE_ROOT}/3rdParty/sqlite"
	"${DORA_SOURCE_ROOT}/3rdParty/dragonBones"
	"${DORA_SOURCE_ROOT}/3rdParty/JoltPhysics"
	"${DORA_SOURCE_ROOT}/3rdParty/wasm3"
	"${DORA_SOURCE_ROOT}/3rdParty/Effekseer"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/fcpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/include"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/src"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/src/mesa"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/src/glsl"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/tools/shaderc"
	"${DORA_SOURCE_ROOT}/3rdParty/theora/include"
	"${DORA_OPENMPT_ROOT}"
	"${DORA_OPENMPT_ROOT}/common"
	"${DORA_OPENMPT_ROOT}/include"
	"${DORA_OPENMPT_ROOT}/libopenmpt"
	"${DORA_SDL2_ROOT}/include")
target_include_directories(dora-bimg BEFORE PRIVATE
	"${DORA_SOURCE_ROOT}/3rdParty/bimg/3rdparty")
target_include_directories(dora-bimg PRIVATE
	"${DORA_SOURCE_ROOT}"
	"${DORA_SOURCE_ROOT}/3rdParty"
	"${DORA_SOURCE_ROOT}/3rdParty/bx/include"
	"${DORA_SOURCE_ROOT}/3rdParty/bimg/include"
	"${DORA_SOURCE_ROOT}/3rdParty/bimg/3rdparty/astc-encoder/include"
	"${DORA_SOURCE_ROOT}/3rdParty/Zip")

target_link_options(dora-ssr PRIVATE
	"--ignore-dynamic-linking"
	"-sUSE_SDL=2"
	"-sUSE_WEBGL2=1"
	"-sFULL_ES3=1"
	"-sALLOW_MEMORY_GROWTH=1"
	"-sINITIAL_MEMORY=256MB"
	"-sMAXIMUM_MEMORY=1GB"
	"-sASSERTIONS=1"
	"-sEXIT_RUNTIME=0"
	"-sFILESYSTEM=1"
	"-sFETCH=1"
	"-sASYNCIFY=1"
	"-sUSE_PTHREADS=0"
	"-sEXPORTED_RUNTIME_METHODS=['ccall','cwrap']"
	"SHELL:--shell-file \"${DORA_EMSCRIPTEN_SHELL}\""
	"SHELL:--exclude-file \"${DORA_ASSETS_ROOT}/www\""
	"SHELL:--preload-file \"${DORA_ASSETS_ROOT}@/Assets\"")

target_link_libraries(dora-ssr PRIVATE "${DORA_RUST_RUNTIME}")

set_target_properties(dora-ssr PROPERTIES
	OUTPUT_NAME "dora-ssr"
	RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
set_property(TARGET dora-ssr APPEND PROPERTY LINK_DEPENDS "${DORA_EMSCRIPTEN_SHELL}")
set_property(TARGET dora-ssr APPEND PROPERTY LINK_DEPENDS ${DORA_ASSET_FILES})
