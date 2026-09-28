# Shared macOS and iOS application target. CMake generates the Xcode project.

include_guard(GLOBAL)
function(dora_add_apple_app)
	set(options)
	set(one TARGET PLATFORM)
	cmake_parse_arguments(DA "${options}" "${one}" "" ${ARGN})

	set(app ${DA_TARGET})
	set(platform ${DA_PLATFORM}) # macos | ios

	set(DORA_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../..")
	set(DORA_SOURCE_ROOT "${DORA_ROOT}/Source")
	set(DORA_BGFX_ROOT "${DORA_SOURCE_ROOT}/3rdParty/bgfx")
	set(DORA_SDL2_ROOT "${DORA_SOURCE_ROOT}/3rdParty/SDL2")

	if(platform STREQUAL "macos")
		set(DORA_LIB_SUFFIX macOS)
		set(DORA_BX_COMPAT osx)
	else()
		set(DORA_BX_COMPAT ios)
		if(NOT DORA_IOS_VARIANT)
			set(DORA_IOS_VARIANT simulator)
		endif()
		# Simulator and device libraries have different output directories.
		if(DORA_IOS_VARIANT STREQUAL "simulator")
			set(DORA_LIB_SUFFIX iOS-Simulator)
		else()
			set(DORA_LIB_SUFFIX iOS)
		endif()
	endif()

	# Paths must match Tools/build-scripts/build_lib_*.sh.
	if(platform STREQUAL "macos")
		set(DORA_BGFX_LIB_DIR "${DORA_BGFX_ROOT}/build/macosx/universal")
	else()
		if(NOT DORA_IOS_VARIANT)
			set(DORA_IOS_VARIANT simulator)
		endif()
		set(DORA_BGFX_LIB_DIR "${DORA_BGFX_ROOT}/build/ios/${DORA_IOS_VARIANT}")
	endif()
	set(DORA_SDL2_LIB "${DORA_SDL2_ROOT}/Lib/${DORA_LIB_SUFFIX}/libSDL2.a")
	set(DORA_LOVE_LIB "${DORA_SOURCE_ROOT}/3rdParty/Love/Artifacts/${DORA_LIB_SUFFIX}/liblove.a")
	set(DORA_THEORA_LIB "${DORA_SOURCE_ROOT}/3rdParty/theora/Lib/${DORA_LIB_SUFFIX}/libtheoradec.a")
	set(DORA_WA_LIB "${DORA_SOURCE_ROOT}/3rdParty/Wa/Lib/${DORA_LIB_SUFFIX}/libwa.a")
	set(DORA_RUNTIME_LIB "${DORA_SOURCE_ROOT}/Rust/lib/${DORA_LIB_SUFFIX}/libdora_runtime.a")

	# Reuse the portable source list, then add the Apple implementation files.
	include("${DORA_ROOT}/Projects/CMake/DoraEngineSources.cmake")
	include("${DORA_ROOT}/Projects/CMake/DoraGeneratedSources.cmake")

	# nfd_portal is Linux-only. The .mm files complement the portable .cpp files.
	list(FILTER DORA_ENGINE_SOURCES EXCLUDE REGEX "/3rdParty/nfd/nfd_portal\\.cpp$")
	list(APPEND DORA_ENGINE_SOURCES
		"${DORA_SOURCE_ROOT}/3rdParty/soloud/backend/sdl2_static/soloud_sdl2_static.cpp")

	set(DORA_APPLE_SOURCES
		"${DORA_SOURCE_ROOT}/Basic/Application.mm"
		"${DORA_SOURCE_ROOT}/Basic/Content.mm")
	if(platform STREQUAL "macos")
		list(APPEND DORA_APPLE_SOURCES "${DORA_SOURCE_ROOT}/3rdParty/nfd/nfd_cocoa.m")
		set_source_files_properties("${DORA_SOURCE_ROOT}/3rdParty/nfd/nfd_cocoa.m"
			PROPERTIES COMPILE_OPTIONS "-fno-objc-arc")
	endif()

	add_executable(${app}
		${DORA_ENGINE_SOURCES}
		${DORA_APPLE_SOURCES})
	dora_add_generated_lua_sources(${app})

	set_target_properties(${app} PROPERTIES
		OUTPUT_NAME "Dora"
		MACOSX_BUNDLE TRUE
		MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Dora/Info.plist"
		XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "IppClub.DoraSSR"
		XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon"
		XCODE_ATTRIBUTE_CLANG_ENABLE_MODULES "YES")
	if(platform STREQUAL "ios")
		set_target_properties(${app} PROPERTIES XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2")
	endif()

	# Xcode copies these directories into the bundle with their original names.
	if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Dora/Assets.xcassets")
		target_sources(${app} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/Dora/Assets.xcassets")
		set_source_files_properties("${CMAKE_CURRENT_SOURCE_DIR}/Dora/Assets.xcassets" PROPERTIES
			MACOSX_PACKAGE_LOCATION Resources)
	endif()
	foreach(resource Audio Doc Font Image Script Shader LICENSES gamecontrollerdb.txt dora-wa www)
		if(EXISTS "${DORA_ROOT}/Assets/${resource}")
			target_sources(${app} PRIVATE "${DORA_ROOT}/Assets/${resource}")
			set_source_files_properties("${DORA_ROOT}/Assets/${resource}" PROPERTIES
				MACOSX_PACKAGE_LOCATION Resources)
		endif()
	endforeach()
	if(platform STREQUAL "ios")
		foreach(storyboard Main "Launch Screen")
			set(storyboard_path "${CMAKE_CURRENT_SOURCE_DIR}/Dora/Base.lproj/${storyboard}.storyboard")
			if(EXISTS "${storyboard_path}")
				target_sources(${app} PRIVATE "${storyboard_path}")
				set_source_files_properties("${storyboard_path}" PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
			endif()
		endforeach()
	endif()

	# Apple headers and compile definitions.
	target_include_directories(${app} PRIVATE
		"${DORA_SDL2_ROOT}/include"
		"${DORA_BGFX_ROOT}/include"
		"${DORA_SOURCE_ROOT}/3rdParty/bimg/include"
		"${DORA_SOURCE_ROOT}/3rdParty/bx/include"
		"${DORA_SOURCE_ROOT}/3rdParty/bx/include/compat/${DORA_BX_COMPAT}"
		"${DORA_SOURCE_ROOT}"
		"${DORA_SOURCE_ROOT}/3rdParty"
		"${DORA_SOURCE_ROOT}/3rdParty/Love/src"
		"${DORA_SOURCE_ROOT}/3rdParty/Love/src/modules"
		"${DORA_SOURCE_ROOT}/3rdParty/JoltPhysics"
		"${DORA_SOURCE_ROOT}/3rdParty/Lua"
		"${DORA_SOURCE_ROOT}/3rdParty/Zip"
		"${DORA_SOURCE_ROOT}/3rdParty/soloud"
		"${DORA_SOURCE_ROOT}/3rdParty/lodepng"
		"${DORA_SOURCE_ROOT}/3rdParty/imgui"
		"${DORA_SOURCE_ROOT}/3rdParty/implot"
		"${DORA_SOURCE_ROOT}/3rdParty/font"
		"${DORA_SOURCE_ROOT}/3rdParty/sqlite"
		"${DORA_SOURCE_ROOT}/3rdParty/dragonBones"
		"${DORA_SOURCE_ROOT}/3rdParty/wasm3"
		"${DORA_SOURCE_ROOT}/3rdParty/Zip/zlib"
		"${DORA_SOURCE_ROOT}/3rdParty/Effekseer"
		"${DORA_SOURCE_ROOT}/3rdParty/theora/include")

	target_compile_definitions(${app} PRIVATE
		WITH_SDL2_STATIC
		BX_CONFIG_DEBUG=0
		d_m3HasWASI
		SPDLOG_FMT_EXTERNAL
		JPH_NO_FORCE_INLINE)
	if(platform STREQUAL "ios")
		# iOS uses the Lua system() stub.
		target_compile_definitions(${app} PRIVATE LUA_USE_IOS=1)
	endif()

	# Prebuilt dependencies.
	set(DORA_VENDOR_LIBS "")
	foreach(lib bgfx bimg bimg_decode bx fcpp shaderc-lib glslang spirv-cross spirv-opt)
		add_library(apple-${lib} STATIC IMPORTED)
		set_target_properties(apple-${lib} PROPERTIES IMPORTED_LOCATION
			"${DORA_BGFX_LIB_DIR}/lib${lib}.a")
		list(APPEND DORA_VENDOR_LIBS apple-${lib})
	endforeach()

	target_link_libraries(${app} PRIVATE
		"${DORA_SDL2_LIB}"
		"${DORA_LOVE_LIB}"
		"${DORA_THEORA_LIB}"
		"${DORA_WA_LIB}"
		"${DORA_RUNTIME_LIB}"
		${DORA_VENDOR_LIBS}
		z)

	# System frameworks.
	if(platform STREQUAL "macos")
		target_link_libraries(${app} PRIVATE
			"-framework Cocoa" "-framework IOKit" "-framework Carbon"
			"-framework OpenGL" "-framework QuartzCore" "-framework Metal"
			"-framework MetalKit" "-framework CoreVideo" "-framework CoreMedia"
			"-framework VideoToolbox" "-framework AudioToolbox" "-framework AudioUnit"
			"-framework CoreAudio" "-framework CoreFoundation" "-framework CoreHaptics"
			"-framework GameController" "-framework ForceFeedback"
			"-framework AVFoundation" "-framework UniformTypeIdentifiers"
			"-framework CoreBluetooth")
	else()
		target_link_libraries(${app} PRIVATE
			"-framework UIKit" "-framework Foundation" "-framework CoreGraphics"
			"-framework QuartzCore" "-framework Metal" "-framework CoreVideo"
			"-framework CoreMedia" "-framework VideoToolbox" "-framework AudioToolbox"
			"-framework CoreAudio" "-framework CoreHaptics" "-framework CoreBluetooth"
			"-framework CoreMotion" "-framework GameController" "-framework AVFoundation"
			"-framework UniformTypeIdentifiers" "-framework OpenGLES")
	endif()
endfunction()
