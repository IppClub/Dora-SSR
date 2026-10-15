# These are xmake custom tasks, not a second C/C++ build backend. Serialize
# their shared host generator/output paths across concurrent ABI builds.
file(MAKE_DIRECTORY "${DORA_ROOT}/build")
file(LOCK "${DORA_ROOT}/build/android-xmake-prepare.lock" GUARD PROCESS TIMEOUT 900)
include("${DORA_BINARY_DIR}/xmake-bindings.cmake")
set(previous_hashes "")
foreach(output IN LISTS DORA_BINDING_OUTPUTS)
    if(EXISTS "${output}")
        file(SHA256 "${output}" hash)
        string(APPEND previous_hashes "${hash}")
    endif()
endforeach()
foreach(task IN ITEMS dora-lua-bindings dora-rust-runtime)
    execute_process(
        COMMAND "${CMAKE_COMMAND}" -E env "XMAKE_CONFIGDIR=${DORA_XMAKE_CONFIG}"
            "${DORA_XMAKE}" build "${task}"
        WORKING_DIRECTORY "${DORA_ROOT}"
        RESULT_VARIABLE result)
    if(NOT result EQUAL 0)
        message(FATAL_ERROR "xmake ${task} failed: ${result}")
    endif()
endforeach()
set(current_hashes "")
foreach(output IN LISTS DORA_BINDING_OUTPUTS)
    file(SHA256 "${output}" hash)
    string(APPEND current_hashes "${hash}")
endforeach()
if(NOT current_hashes STREQUAL previous_hashes OR NOT EXISTS "${DORA_BINARY_DIR}/xmake-bindings.stamp")
    file(TOUCH "${DORA_BINARY_DIR}/xmake-bindings.stamp")
endif()
