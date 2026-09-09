# Web-only source set needed to turn the portable Dora engine objects into a
# linked browser executable. These libraries are built from source because the
# native archives under Source/3rdParty are platform-specific.
include_guard(GLOBAL)

if(NOT DEFINED DORA_SOURCE_ROOT)
	message(FATAL_ERROR "DORA_SOURCE_ROOT must be set before loading Web link sources")
endif()

file(GLOB DORA_WEB_BX_SOURCES CONFIGURE_DEPENDS
	"${DORA_SOURCE_ROOT}/3rdParty/bx/src/*.cpp")
file(GLOB DORA_WEB_BIMG_SOURCES CONFIGURE_DEPENDS
	"${DORA_SOURCE_ROOT}/3rdParty/bimg/src/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bimg/3rdparty/astc-encoder/source/*.cpp")
file(GLOB DORA_WEB_FCPP_SOURCES CONFIGURE_DEPENDS
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/fcpp/*.c")
list(FILTER DORA_WEB_FCPP_SOURCES EXCLUDE REGEX "/usecpp\\.c$")
set_source_files_properties(${DORA_WEB_FCPP_SOURCES} PROPERTIES COMPILE_DEFINITIONS UNIX)

file(GLOB_RECURSE DORA_WEB_GLSL_OPT_SOURCES CONFIGURE_DEPENDS
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/src/*.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/3rdparty/glsl-optimizer/src/*.c")
list(FILTER DORA_WEB_GLSL_OPT_SOURCES EXCLUDE REGEX "/node/.*")
list(FILTER DORA_WEB_GLSL_OPT_SOURCES EXCLUDE REGEX "/glsl/main\\.cpp$")

set(DORA_WEB_BGFX_SOURCES
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/bgfx.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/debug_renderdoc.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/glcontext_html5.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/renderer_agc.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/renderer_d3d11.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/renderer_d3d12.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/renderer_gl.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/renderer_gnm.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/renderer_noop.cpp"
	"${DORA_SOURCE_ROOT}/3rdParty/bgfx/src/renderer_nvn.cpp"
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

set(DORA_WEB_LINK_SOURCES
	"${DORA_SOURCE_ROOT}/3rdParty/theora/TheoraSources.c"
	${DORA_WEB_BX_SOURCES}
	${DORA_WEB_BIMG_SOURCES}
	${DORA_WEB_FCPP_SOURCES}
	${DORA_WEB_GLSL_OPT_SOURCES}
	${DORA_WEB_BGFX_SOURCES})
