cmake_minimum_required(VERSION 3.4.1)

file(GLOB_RECURSE src-files FOLLOW_SYMLINKS *.cpp)

include_directories(
	src/main/cpp
	src/main/cpp/3rdParty
	src/main/cpp/3rdParty/SDL2/Header
	src/main/cpp/3rdParty/BGFX/Header
	src/main/cpp/3rdParty/Lua/Header
	src/main/cpp/3rdParty/Zip/Header
	src/main/cpp/3rdParty/soloud/Header
	src/main/cpp/3rdParty/lodepng
	src/main/cpp/3rdParty/imgui
	src/main/cpp/3rdParty/font
)

add_library( SDL2-lib SHARED IMPORTED )
set_target_properties(
	SDL2-lib PROPERTIES IMPORTED_LOCATION
	${CMAKE_CURRENT_SOURCE_DIR}/src/main/cpp/3rdParty/SDL2/Lib/Android/${ANDROID_ABI}/libSDL2.so
)

add_library( BGFX-lib STATIC IMPORTED )
set_target_properties(
	BGFX-lib PROPERTIES IMPORTED_LOCATION
	${CMAKE_CURRENT_SOURCE_DIR}/src/main/cpp/3rdParty/BGFX/Lib/Android/${ANDROID_ABI}/libbgfx.a
)

add_library( BX-lib STATIC IMPORTED )
set_target_properties(
	BX-lib PROPERTIES IMPORTED_LOCATION
	${CMAKE_CURRENT_SOURCE_DIR}/src/main/cpp/3rdParty/BGFX/Lib/Android/${ANDROID_ABI}/libbx.a
)

add_library( BIMG-lib STATIC IMPORTED )
set_target_properties(
	BIMG-lib PROPERTIES IMPORTED_LOCATION
	${CMAKE_CURRENT_SOURCE_DIR}/src/main/cpp/3rdParty/BGFX/Lib/Android/${ANDROID_ABI}/libbimg.a
)

add_library( BIMGDE-lib STATIC IMPORTED )
set_target_properties(
	BIMGDE-lib PROPERTIES IMPORTED_LOCATION
	${CMAKE_CURRENT_SOURCE_DIR}/src/main/cpp/3rdParty/BGFX/Lib/Android/${ANDROID_ABI}/libbimg_decode.a
)

add_library( lua-lib STATIC IMPORTED )
set_target_properties(
	lua-lib PROPERTIES IMPORTED_LOCATION
	${CMAKE_CURRENT_SOURCE_DIR}/src/main/cpp/3rdParty/Lua/Lib/Android/${ANDROID_ABI}/liblua.a
)

add_library( soloud-lib STATIC IMPORTED )
set_target_properties(
	soloud-lib PROPERTIES IMPORTED_LOCATION
	${CMAKE_CURRENT_SOURCE_DIR}/src/main/cpp/3rdParty/soloud/Lib/Android/${ANDROID_ABI}/libsoloud.a
)

add_library( main SHARED ${src-files} )

target_link_libraries( main android log EGL z GLESv1_CM GLESv2 SDL2-lib BGFX-lib BIMGDE-lib BIMG-lib BX-lib lua-lib soloud-lib )
