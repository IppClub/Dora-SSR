cmake_minimum_required(VERSION 3.22.1)
project(Dora-SSR LANGUAGES C CXX ASM)

get_filename_component(DORA_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../../.." ABSOLUTE)
if(NOT ANDROID)
    message(FATAL_ERROR "This entry point requires the Android NDK CMake toolchain")
endif()
if(NOT ANDROID_ABI MATCHES "^(armeabi-v7a|arm64-v8a|x86_64)$")
    message(FATAL_ERROR "Unsupported Dora Android ABI: ${ANDROID_ABI}")
endif()
find_program(DORA_XMAKE NAMES xmake xmake.exe HINTS "$ENV{DORA_XMAKE_DIR}" /opt/homebrew/bin /usr/local/bin REQUIRED)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(DORA_XMAKE_MODE debug)
else()
    set(DORA_XMAKE_MODE release)
endif()
# Each Gradle ABI/variant has independent xmake configuration and host objects.
# No native source list, compiler flags or dependency graph is maintained here.
set(DORA_XMAKE_CONFIG "${CMAKE_CURRENT_BINARY_DIR}/xmake-config")
set(DORA_XMAKE_EXPORT "${CMAKE_CURRENT_BINARY_DIR}/xmake-targets.cmake")
file(MAKE_DIRECTORY "${DORA_ROOT}/build")
file(LOCK "${DORA_ROOT}/build/android-xmake-prepare.lock" GUARD PROCESS TIMEOUT 900)
execute_process(
    COMMAND "${CMAKE_COMMAND}" -E env "XMAKE_CONFIGDIR=${DORA_XMAKE_CONFIG}"
        "${DORA_XMAKE}" f -q -y -p android -a "${ANDROID_ABI}" -m "${DORA_XMAKE_MODE}"
        "--ndk=${ANDROID_NDK}" "--ndk_sdkver=${ANDROID_PLATFORM_LEVEL}"
        "--builddir=${DORA_XMAKE_CONFIG}/build" --ccache=n
    WORKING_DIRECTORY "${DORA_ROOT}"
    RESULT_VARIABLE result)
if(NOT result EQUAL 0)
    message(FATAL_ERROR "xmake Android configuration failed: ${result}")
endif()
execute_process(
    COMMAND "${CMAKE_COMMAND}" -E env "XMAKE_CONFIGDIR=${DORA_XMAKE_CONFIG}"
        "${DORA_XMAKE}" l Projects/xmake/android/export.lua "${DORA_XMAKE_EXPORT}"
    WORKING_DIRECTORY "${DORA_ROOT}"
    RESULT_VARIABLE result)
if(NOT result EQUAL 0)
    message(FATAL_ERROR "xmake Android CMake export failed: ${result}")
endif()
file(LOCK "${DORA_ROOT}/build/android-xmake-prepare.lock" RELEASE)

set(DORA_RUST_LIBRARY "${DORA_ROOT}/build/runtime/android/${ANDROID_ABI}/${DORA_XMAKE_MODE}/libdora_runtime.a")
add_custom_target(dora_xmake_prepare
    COMMAND "${CMAKE_COMMAND}" "-DDORA_ROOT=${DORA_ROOT}" "-DDORA_XMAKE=${DORA_XMAKE}"
        "-DDORA_XMAKE_CONFIG=${DORA_XMAKE_CONFIG}" "-DDORA_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}"
        -P "${DORA_ROOT}/Projects/xmake/android/prepare.cmake"
    BYPRODUCTS "${DORA_RUST_LIBRARY}" "${CMAKE_CURRENT_BINARY_DIR}/xmake-bindings.stamp"
    USES_TERMINAL)
include("${DORA_XMAKE_EXPORT}")

# Make the shared STL an explicit runtime dependency in AGP's CMake model.
# This also works when Studio has regenerated a model before the next build;
# packaging must not depend on an earlier build having staged the STL.
if(ANDROID_STL STREQUAL "c++_shared")
    find_library(DORA_ANDROID_STL_RUNTIME NAMES c++_shared REQUIRED)
    add_library(dora_android_stl SHARED IMPORTED)
    set_target_properties(dora_android_stl PROPERTIES IMPORTED_LOCATION "${DORA_ANDROID_STL_RUNTIME}")
    target_link_libraries(Dora PRIVATE dora_android_stl)
endif()

# Re-evaluate Lua conditions/globs when a target definition or manifest changes.
file(GLOB_RECURSE DORA_XMAKE_INPUTS CONFIGURE_DEPENDS
    "${DORA_ROOT}/Projects/xmake/*.lua" "${DORA_ROOT}/Source/3rdParty/*/xmake.lua")
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
    "${DORA_ROOT}/xmake.lua" ${DORA_XMAKE_INPUTS})
file(GLOB_RECURSE DORA_NATIVE_MEMBERSHIP CONFIGURE_DEPENDS
    "${DORA_ROOT}/Source/*.c" "${DORA_ROOT}/Source/*.cpp" "${DORA_ROOT}/Source/*.cc"
    "${DORA_ROOT}/Source/*.cxx" "${DORA_ROOT}/Source/*.S" "${DORA_ROOT}/Source/*.s")
