# Experimental override of the SDK SDL2 audio object, built against the same
# port sources/headers rather than the repository's different SDL version.
set(DORA_WEB_SDL2_PORT_SOURCE_DIR "" CACHE PATH "SDL2 source directory used by this Emscripten SDK")
if(NOT EXISTS "${DORA_WEB_SDL2_PORT_SOURCE_DIR}/src/audio/emscripten/SDL_emscriptenaudio.c")
	message(FATAL_ERROR "Experimental main Worker requires DORA_WEB_SDL2_PORT_SOURCE_DIR from the active SDK")
endif()
set(_audio_dir "${DORA_WEB_SDL2_PORT_SOURCE_DIR}/src/audio/emscripten")
file(READ "${_audio_dir}/SDL_emscriptenaudio.c" _audio_source)
set(_old_rate "this->spec.freq = EM_ASM_INT({")
set(_new_rate "this->spec.freq = MAIN_THREAD_EM_ASM_INT({")
string(FIND "${_audio_source}" "${_old_rate}" _rate_index)
if(_rate_index EQUAL -1)
	message(FATAL_ERROR "SDL2 audio source changed; review the experimental sample-rate proxy override")
endif()
string(REPLACE "${_old_rate}" "${_new_rate}" _audio_source "${_audio_source}")
set(_audio_output "${CMAKE_BINARY_DIR}/studio-sdl2-audio.c")
file(CONFIGURE OUTPUT "${_audio_output}" CONTENT "/* Dora experimental modification: proxy sample-rate query to the page. */\n${_audio_source}" @ONLY)
add_library(dora-main-worker-audio OBJECT "${_audio_output}")
target_include_directories(dora-main-worker-audio PRIVATE
	"${_audio_dir}" "${DORA_WEB_SDL2_PORT_SOURCE_DIR}/include")
target_compile_options(dora-main-worker-audio PRIVATE -pthread "-sUSE_SDL=2")
# Resolve EMSCRIPTENAUDIO_bootstrap before the port archive is extracted.
target_sources(dora-web-player PRIVATE $<TARGET_OBJECTS:dora-main-worker-audio>)
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${_audio_dir}/SDL_emscriptenaudio.c")
