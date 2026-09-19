# Deliberately does not inherit the engine's pthread flags or memory.
file(GLOB DORA_AUDIO_CORE "${DORA_SOURCE_ROOT}/3rdParty/soloud/core/*.cpp")
file(GLOB DORA_AUDIO_FILTERS "${DORA_SOURCE_ROOT}/3rdParty/soloud/filter/*.cpp")
add_executable(dora-web-audio-mixer
	"${DORA_SOURCE_ROOT}/Web/AudioMixer.cpp"
	${DORA_AUDIO_CORE}
	${DORA_AUDIO_FILTERS}
	"${DORA_SOURCE_ROOT}/3rdParty/soloud/audiosource/wav/soloud_wav.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/soloud/audiosource/wav/soloud_wavstream.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/soloud/audiosource/wav/dr_impl.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/soloud/audiosource/wav/stb_vorbis.c")
target_include_directories(dora-web-audio-mixer PRIVATE "${DORA_SOURCE_ROOT}/3rdParty/soloud")
target_compile_definitions(dora-web-audio-mixer PRIVATE WITH_NULL)
target_compile_options(dora-web-audio-mixer PRIVATE -O2)
target_link_options(dora-web-audio-mixer PRIVATE
	-O2 --no-entry -sSTANDALONE_WASM=1 -sFILESYSTEM=0
	-sALLOW_MEMORY_GROWTH=1 -sINITIAL_MEMORY=32MB -sMAXIMUM_MEMORY=256MB
	-sSTACK_SIZE=256KB "-sEXPORTED_FUNCTIONS=['_malloc','_free']")
set_target_properties(dora-web-audio-mixer PROPERTIES OUTPUT_NAME "dora-audio-mixer" SUFFIX ".wasm")
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/audio-worklet.js" "${CMAKE_BINARY_DIR}/audio-worklet.js" COPYONLY)
add_dependencies(dora-web-player dora-web-audio-mixer)

function(dora_enable_worklet target)
	add_dependencies(${target} dora-web-audio-mixer)
	target_link_options(${target} PRIVATE "SHELL:--pre-js \"${CMAKE_CURRENT_SOURCE_DIR}/web-audio.js\"")
	set_property(TARGET ${target} APPEND PROPERTY LINK_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/web-audio.js")
endfunction()
