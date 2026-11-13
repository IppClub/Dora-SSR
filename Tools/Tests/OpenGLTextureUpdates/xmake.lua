-- Build the matching Windows Dora dependencies first, then:
-- xmake f -P Tools/Tests/OpenGLTextureUpdates -p windows -a x86 -m debug
-- xmake run -P Tools/Tests/OpenGLTextureUpdates
set_project("OpenGLTextureUpdates")
set_languages("cxx17")
local root = path.absolute("../../..", os.projectdir())
target("GLTextureRegression")
    set_kind("binary")
    add_files("main.cpp")
    add_includedirs(path.join(root, "Source/3rdParty/bgfx/include"),
        path.join(root, "Source/3rdParty/bx/include"),
        path.join(root, "Source/3rdParty/bx/include/compat/msvc"),
        path.join(root, "Source/3rdParty/SDL2/include"))
    add_defines("WITH_SDL2_STATIC", "BX_CONFIG_DEBUG=" .. (is_mode("debug") and "1" or "0"))
    if is_mode("debug") then add_defines("_ITERATOR_DEBUG_LEVEL=0") end
    set_runtimes(is_mode("debug") and "MTd" or "MT")
    add_linkdirs(path.join(root, "build/windows", get_config("arch"), get_config("mode")))
    add_links("bgfx", "bimg", "bimg_decode", "bx", "SDL2")
    add_syslinks("opengl32", "gdi32", "user32", "imm32", "winmm", "version",
        "setupapi", "ole32", "oleaut32", "shell32", "advapi32", "uuid", "ws2_32")
