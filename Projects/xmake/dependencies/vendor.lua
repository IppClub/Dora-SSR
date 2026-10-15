-- Reuse the vendored xmake targets in the canonical graph. Their standalone
-- set_project/set_version calls are intentionally reset after inclusion so the
-- root project remains the only user-facing build entry.
includes(path.join(os.projectdir(), "Source/3rdParty/SDL2/xmake.lua"))
includes(path.join(os.projectdir(), "Source/3rdParty/bgfx/xmake.lua"))
includes(path.join(os.projectdir(), "Source/3rdParty/ogg/xmake.lua"))
includes(path.join(os.projectdir(), "Source/3rdParty/theora/xmake.lua"))
includes(path.join(os.projectdir(), "Source/3rdParty/Love/xmake.lua"))

for _, target_name in ipairs({
    "SDL2",
    "bx",
    "bimg",
    "bimg_decode",
    "bgfx",
    "fcpp",
    "spirv-cross",
    "spirv-opt",
    "glslang",
    "glsl_optimizer",
    "shaderc-lib",
    "ogg",
    "theoradec",
    "openmpt",
    "love-box2d",
    "luasocket-objects",
    "luasocket",
    "love"
}) do
    target(target_name)
        set_default(false)
        if is_plat("windows") then
            add_cxxflags("/Zc:__cplusplus", "/Zc:preprocessor", {tools = "cl", force = true})
            -- Apply only to C source files; never let MSVC's c99 fallback
            -- silently turn a vendored .c translation unit into C++.
            add_cflags("/TC", {tools = "cl", force = true})
        end
        if target_name == "SDL2" then
            -- Emscripten's EM_ASM macros require a GNU C dialect; strict
            -- -std=c* modes deliberately reject the statement-expression
            -- helpers used by SDL's browser backend.
            set_languages(is_plat("wasm") and "gnu11" or "c11", "cxx17")
        elseif target_name == "ogg" or target_name == "theoradec" or target_name == "fcpp"
            or target_name == "luasocket-objects" or target_name == "luasocket" then
            set_languages("c11")
        elseif target_name == "openmpt" then
            set_languages(is_plat("windows") and "c11" or "c99", "cxx17")
        elseif target_name == "love-box2d" then
            set_languages("cxx11")
        else
            set_languages(is_plat("windows") and "c11" or "c99", "cxx20")
        end
        if target_name == "glsl_optimizer" and is_plat("linux") then
            -- strdup is POSIX, not ISO C99; keep these genuine C units in
            -- GNU C mode instead of relying on implicit declarations.
            set_languages("gnu11", "cxx20")
        end
    target_end()
end

set_project("Dora-SSR")
set_version("1.0.0")
