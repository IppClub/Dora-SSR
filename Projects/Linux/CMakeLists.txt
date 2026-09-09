cmake_minimum_required(VERSION 3.5.0)
project(Dora-SSR)

set(CMAKE_CXX_STANDARD 20)

set(DORA_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/../..)
set(DORA_SOURCE_ROOT ${DORA_ROOT}/Source)
set(DORA_BGFX_ROOT ${DORA_SOURCE_ROOT}/3rdParty/bgfx)
set(DORA_SDL2_ROOT ${DORA_SOURCE_ROOT}/3rdParty/SDL2)

if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE release)
endif()

string(TOLOWER "${CMAKE_BUILD_TYPE}" DORA_BUILD_MODE)
if(DORA_BUILD_MODE STREQUAL "debug")
	set(DORA_BX_CONFIG_DEBUG 1)
else()
	set(DORA_BX_CONFIG_DEBUG 0)
endif()

if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64)$")
	set(DORA_BGFX_ARCH x86_64)
	set(DORA_WA_ARCH amd64)
	set(DORA_RUNTIME_ARCH x86_64)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64)$")
	set(DORA_BGFX_ARCH arm64)
	set(DORA_WA_ARCH aarch64)
	set(DORA_RUNTIME_ARCH aarch64)
else()
	set(DORA_BGFX_ARCH ${CMAKE_SYSTEM_PROCESSOR})
	set(DORA_WA_ARCH ${CMAKE_SYSTEM_PROCESSOR})
	set(DORA_RUNTIME_ARCH ${CMAKE_SYSTEM_PROCESSOR})
endif()

set(DORA_BGFX_BUILD_DIR ${DORA_BGFX_ROOT}/build/linux/${DORA_BGFX_ARCH}/${DORA_BUILD_MODE})
set(DORA_SDL2_BUILD_DIR ${DORA_SDL2_ROOT}/Lib/Linux/${DORA_RUNTIME_ARCH})
set(DORA_WA_BUILD_DIR ${DORA_SOURCE_ROOT}/3rdParty/Wa/Lib/Linux/${DORA_WA_ARCH})
set(DORA_RUNTIME_BUILD_DIR ${DORA_SOURCE_ROOT}/Rust/lib/Linux/${DORA_RUNTIME_ARCH})
set(DORA_LOVE_BUILD_DIR ${DORA_SOURCE_ROOT}/3rdParty/Love/Artifacts/Linux/${DORA_RUNTIME_ARCH})
set(DORA_THEORA_BUILD_DIR ${DORA_SOURCE_ROOT}/3rdParty/theora/Lib/Linux/${DORA_RUNTIME_ARCH})
if(DORA_BGFX_ARCH STREQUAL "arm64")
	set(DORA_RENDER_LINK_LIBS EGL GLESv2 X11)
else()
	set(DORA_RENDER_LINK_LIBS GL X11)
endif()

find_package(PkgConfig REQUIRED)
pkg_check_modules(DBUS REQUIRED dbus-1)

include_directories(
	${DORA_SDL2_ROOT}/include
	${DBUS_INCLUDE_DIRS}
	${DORA_BGFX_ROOT}/include
	${DORA_SOURCE_ROOT}/3rdParty/bimg/include
	${DORA_SOURCE_ROOT}/3rdParty/bx/include
	${DORA_SOURCE_ROOT}/3rdParty/bx/include/compat/linux
	${DORA_SOURCE_ROOT}
	${DORA_SOURCE_ROOT}/3rdParty
	${DORA_SOURCE_ROOT}/3rdParty/Love/src
	${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules
	${DORA_SOURCE_ROOT}/3rdParty/JoltPhysics
	${DORA_SOURCE_ROOT}/3rdParty/Lua
	${DORA_SOURCE_ROOT}/3rdParty/Zip
	${DORA_SOURCE_ROOT}/3rdParty/soloud
	${DORA_SOURCE_ROOT}/3rdParty/lodepng
	${DORA_SOURCE_ROOT}/3rdParty/imgui
	${DORA_SOURCE_ROOT}/3rdParty/implot
	${DORA_SOURCE_ROOT}/3rdParty/font
	${DORA_SOURCE_ROOT}/3rdParty/sqlite
	${DORA_SOURCE_ROOT}/3rdParty/dragonBones
	${DORA_SOURCE_ROOT}/3rdParty/wasm3
	${DORA_SOURCE_ROOT}/3rdParty/Zip/zlib
	${DORA_SOURCE_ROOT}/3rdParty/Effekseer
	${DORA_SOURCE_ROOT}/3rdParty/theora/include
)

add_library(BGFX-lib STATIC IMPORTED)
set_target_properties(
	BGFX-lib PROPERTIES IMPORTED_LOCATION
	${DORA_BGFX_BUILD_DIR}/libbgfx.a
)

add_library(LOVE-lib STATIC IMPORTED)
set_target_properties(
	LOVE-lib PROPERTIES IMPORTED_LOCATION
	${DORA_LOVE_BUILD_DIR}/liblove.a
)

add_library(THEORA-lib STATIC IMPORTED)
set_target_properties(
	THEORA-lib PROPERTIES IMPORTED_LOCATION
	${DORA_THEORA_BUILD_DIR}/libtheoradec.a
)

add_library(BX-lib STATIC IMPORTED)
set_target_properties(
	BX-lib PROPERTIES IMPORTED_LOCATION
	${DORA_BGFX_BUILD_DIR}/libbx.a
)

add_library(BIMG-lib STATIC IMPORTED)
set_target_properties(
	BIMG-lib PROPERTIES IMPORTED_LOCATION
	${DORA_BGFX_BUILD_DIR}/libbimg.a
)

add_library(BIMGDE-lib STATIC IMPORTED)
set_target_properties(
	BIMGDE-lib PROPERTIES IMPORTED_LOCATION
	${DORA_BGFX_BUILD_DIR}/libbimg_decode.a
)

add_library(FCPP-lib STATIC IMPORTED)
set_target_properties(
	FCPP-lib PROPERTIES IMPORTED_LOCATION
	${DORA_BGFX_BUILD_DIR}/libfcpp.a
)

add_library(GLSLO-lib STATIC IMPORTED)
set_target_properties(
	GLSLO-lib PROPERTIES IMPORTED_LOCATION
	${DORA_BGFX_BUILD_DIR}/libglsl_optimizer.a
)

add_library(SHADERC-lib STATIC IMPORTED)
set_target_properties(
	SHADERC-lib PROPERTIES IMPORTED_LOCATION
	${DORA_BGFX_BUILD_DIR}/libshaderc-lib.a
)

add_library(SDL2-lib STATIC IMPORTED)
set_target_properties(
	SDL2-lib PROPERTIES IMPORTED_LOCATION
	${DORA_SDL2_BUILD_DIR}/libSDL2.a
)

add_library(WA-lib STATIC IMPORTED)
set_target_properties(
	WA-lib PROPERTIES IMPORTED_LOCATION
	${DORA_WA_BUILD_DIR}/libwa.a
)

add_library(DORA-lib STATIC IMPORTED)
set_target_properties(
	DORA-lib PROPERTIES IMPORTED_LOCATION
	${DORA_RUNTIME_BUILD_DIR}/libdora_runtime.a
)

add_definitions(-DWITH_SDL2 -DBX_CONFIG_DEBUG=${DORA_BX_CONFIG_DEBUG} -Dd_m3HasWASI -DLUA_USE_LINUX -DSPDLOG_FMT_EXTERNAL -DJPH_NO_FORCE_INLINE)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_definitions(-Wno-psabi)
endif()

include("${DORA_ROOT}/Projects/CMake/DoraEngineSources.cmake")
include("${DORA_ROOT}/Projects/CMake/DoraGeneratedSources.cmake")

add_executable(dora-ssr ${DORA_ENGINE_SOURCES})
dora_add_generated_lua_sources(dora-ssr)

target_link_libraries(dora-ssr z SDL2-lib LOVE-lib THEORA-lib BGFX-lib BIMGDE-lib BIMG-lib SHADERC-lib GLSLO-lib FCPP-lib BX-lib ${DORA_RENDER_LINK_LIBS} ${DBUS_LINK_LIBRARIES} DORA-lib WA-lib m dl pthread rt)
