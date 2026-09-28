cmake_minimum_required(VERSION 3.25)
project(DoraWindows LANGUAGES C CXX RC)

if(NOT WIN32)
	message(FATAL_ERROR "The Windows application must be generated on Windows")
endif()
if(NOT CMAKE_SIZEOF_VOID_P EQUAL 4)
	message(FATAL_ERROR "Dora's prebuilt Windows libraries require a Win32 (x86) generator: use -A Win32")
endif()

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

get_filename_component(DORA_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../.." ABSOLUTE)
set(DORA_SOURCE_ROOT "${DORA_ROOT}/Source")
set(DORA_VENDOR_ROOT "${DORA_SOURCE_ROOT}/3rdParty")

include("${DORA_ROOT}/Projects/CMake/DoraEngineSources.cmake")
include("${DORA_ROOT}/Projects/CMake/DoraGeneratedSources.cmake")

# The shared list is portable; these are the Windows source substitutions.
list(FILTER DORA_ENGINE_SOURCES EXCLUDE REGEX "/3rdParty/nfd/nfd_portal\\.cpp$")
list(FILTER DORA_ENGINE_SOURCES EXCLUDE REGEX "/3rdParty/soloud/backend/sdl/soloud_sdl2(_dll)?\\.(cpp|c)$")
list(APPEND DORA_ENGINE_SOURCES
	"${DORA_VENDOR_ROOT}/nfd/nfd_win.cpp"
	"${DORA_VENDOR_ROOT}/soloud/backend/sdl2_static/soloud_sdl2_static.cpp")

add_executable(Dora WIN32
	${DORA_ENGINE_SOURCES}
	"${CMAKE_CURRENT_SOURCE_DIR}/Dora/Resource.rc")
dora_add_generated_lua_sources(Dora)

set_target_properties(Dora PROPERTIES
	OUTPUT_NAME Dora
	RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/build"
	VS_DEBUGGER_WORKING_DIRECTORY "${DORA_ROOT}/Assets"
	MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

target_include_directories(Dora PRIVATE
	"${DORA_SOURCE_ROOT}"
	"${DORA_VENDOR_ROOT}"
	"${DORA_VENDOR_ROOT}/Love/src"
	"${DORA_VENDOR_ROOT}/Love/src/modules"
	"${DORA_VENDOR_ROOT}/JoltPhysics"
	"${DORA_VENDOR_ROOT}/bx/include/bx/compat/msvc"
	"${DORA_VENDOR_ROOT}/bgfx/include"
	"${DORA_VENDOR_ROOT}/bx/include"
	"${DORA_VENDOR_ROOT}/bimg/include"
	"${DORA_VENDOR_ROOT}/SDL2/include"
	"${DORA_VENDOR_ROOT}/Lua"
	"${DORA_VENDOR_ROOT}/Zip"
	"${DORA_VENDOR_ROOT}/soloud"
	"${DORA_VENDOR_ROOT}/lodepng"
	"${DORA_VENDOR_ROOT}/imgui"
	"${DORA_VENDOR_ROOT}/implot"
	"${DORA_VENDOR_ROOT}/font"
	"${DORA_VENDOR_ROOT}/sqlite"
	"${DORA_VENDOR_ROOT}/dragonBones"
	"${DORA_VENDOR_ROOT}/wasm3"
	"${DORA_VENDOR_ROOT}/Zip/zlib"
	"${DORA_VENDOR_ROOT}/Effekseer"
	"${DORA_VENDOR_ROOT}/theora/include")

target_compile_definitions(Dora PRIVATE
	WIN32 _WINDOWS _MBCS _CRT_SECURE_NO_WARNINGS
	_SILENCE_CXX17_CODECVT_HEADER_DEPRECATION_WARNING
	WITH_SDL2_STATIC SDL_MAIN_HANDLED d_m3HasWASI LUA_USE_WINDOWS
	SPDLOG_FMT_EXTERNAL
	"BX_CONFIG_DEBUG=$<IF:$<CONFIG:Debug>,1,0>"
	"$<$<CONFIG:Debug>:_ITERATOR_DEBUG_LEVEL=0>")
target_compile_options(Dora PRIVATE
	$<$<COMPILE_LANGUAGE:CXX>:/FS>
	$<$<COMPILE_LANGUAGE:CXX>:/Zc:__cplusplus>
	$<$<COMPILE_LANGUAGE:CXX>:/Zc:preprocessor>
	/utf-8 /wd4244 /wd4996 /wd4200 /wd4819)

# The old Visual Studio project used this PCH for engine files, but excluded
# third-party implementation files and several translation units.
target_precompile_headers(Dora PRIVATE "$<$<COMPILE_LANGUAGE:CXX>:${DORA_SOURCE_ROOT}/Const/Header.h>")
foreach(source IN LISTS DORA_ENGINE_SOURCES)
	if(source MATCHES "/3rdParty/" OR
	   source MATCHES "/(Audio/VorbisSources\\.c|Love/LoveRuntime\\.cpp|Love/LoveVideoSources\\.cpp|Physics/JoltBridge\\.cpp|Physics/JoltSources\\.cpp|Test/HelloWorldCpp\\.cpp|Http/XrtNetwork\\.c)$")
		set_source_files_properties("${source}" PROPERTIES SKIP_PRECOMPILE_HEADERS ON)
	endif()
endforeach()

set(DORA_BGFX_DIR "${DORA_VENDOR_ROOT}/bgfx/build/windows/x86/$<LOWER_CASE:$<CONFIG>>")
set(DORA_SDL2_DIR "${DORA_VENDOR_ROOT}/SDL2/Lib/Windows/$<CONFIG>")
set(DORA_THEORA_DIR "${DORA_VENDOR_ROOT}/theora/Lib/Windows/$<CONFIG>")
target_link_libraries(Dora PRIVATE
	"${DORA_SDL2_DIR}/SDL2.lib"
	"${DORA_VENDOR_ROOT}/Love/Artifacts/Windows/love.lib"
	"${DORA_THEORA_DIR}/theoradec.lib"
	"${DORA_SOURCE_ROOT}/Rust/lib/Windows/dora_runtime.lib"
	"${DORA_BGFX_DIR}/bgfx.lib"
	"${DORA_BGFX_DIR}/bimg.lib"
	"${DORA_BGFX_DIR}/bimg_decode.lib"
	"${DORA_BGFX_DIR}/bx.lib"
	"${DORA_BGFX_DIR}/fcpp.lib"
	"${DORA_BGFX_DIR}/shaderc-lib.lib"
	psapi setupapi userenv winmm imm32 version ws2_32 gdi32
	advapi32 crypt32 user32 ntdll)
target_link_options(Dora PRIVATE /SAFESEH:NO
	"$<$<CONFIG:Debug>:/NODEFAULTLIB:libc.lib;/NODEFAULTLIB:libcmt.lib;/NODEFAULTLIB:libcd.lib;/NODEFAULTLIB:msvcrt.lib>"
	"$<$<NOT:$<CONFIG:Debug>>:/NODEFAULTLIB:libcmt.lib>")

add_custom_command(TARGET Dora POST_BUILD
	COMMAND "${CMAKE_COMMAND}" -E copy_if_different
		"${DORA_VENDOR_ROOT}/Wa/Lib/Windows/wa.dll"
		"$<TARGET_FILE_DIR:Dora>/wa.dll"
	COMMENT "Copying wa.dll beside Dora.exe")
