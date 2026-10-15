local TOLUA_DIR = path.join(os.projectdir(), "Tools/tolua++")
local LUA_DIR = path.join(TOLUA_DIR, "tolua++build/lua-5.1.5/src")
local BINDING_OUTPUTS = {
    path.join(os.projectdir(), "Source/Lua/LuaBinding.cpp"),
    path.join(os.projectdir(), "Source/Lua/LuaBindingWeb.cpp"),
    path.join(os.projectdir(), "Source/Lua/LuaCode.cpp"),
    path.join(os.projectdir(), "Source/Lua/LuaCodeWeb.cpp"),
    path.join(os.projectdir(), "Source/Lua/TealCompiler.cpp")
}

target("dora-tolua")
    set_kind("binary")
    set_default(false)
    set_plat(os.host())
    set_arch(os.arch())
    if is_host("macosx") then
        -- A cross iOS configure leaves appledev=simulator in the global
        -- configuration. Give the native generator its own macOS toolchain
        -- so xmake does not try to load a macOS compiler as an iOS simulator.
        set_toolchains("xcode", {
            plat = os.host(), arch = os.arch(), appledev = "macosx"
        })
    end
    -- Keep the generator's Lua 5.1/LFS sources in a real C mode on every
    -- host. MSVC supports C11 directly; using c99 makes xmake fall back to
    -- /TP before our /TC guard and masks language mistakes behind C++ mode.
    set_languages("c11")
    set_targetdir(path.join(os.projectdir(), "build/host", os.host(), os.arch(), "$(mode)", "bin"))
    add_includedirs(LUA_DIR, path.join(TOLUA_DIR, "tolua++build/lfs"))
    add_files(
        path.join(LUA_DIR, "*.c|lua.c|luac.c|print.c"),
        path.join(TOLUA_DIR, "tolua++build/lfs/lfs.c"),
        path.join(os.projectdir(), "Projects/xmake/tools/tolua_main.c")
    )
    if is_host("windows") then
        add_defines("_CRT_SECURE_NO_WARNINGS")
        add_cflags("/TC", {tools = "cl", force = true})
        set_runtimes(is_mode("debug") and "MTd" or "MT")
    else
        add_defines("LUA_USE_POSIX")
        if is_host("linux") then
            add_defines("_GNU_SOURCE")
            add_syslinks("dl", "m")
        end
    end
target_end()

target("dora-lua-bindings")
    -- The Xcode generator cannot serialize phony products. This affects only
    -- generated IDE metadata; the IDE's shell phase invokes normal xmake and
    -- therefore still executes this as a phony code-generation target.
    set_kind(os.getenv("XMAKE_IN_PROJECT_GENERATOR") and "binary" or "phony")
    set_default(false)
    add_deps("dora-tolua")
    set_values("dora.binding_outputs", table.unpack(BINDING_OUTPUTS))
    on_build(function (target)
        import("core.project.depend")
        local generator = assert(target:dep("dora-tolua")):targetfile()
        local script = path.join(TOLUA_DIR, "tolua++.lua")
        local outputs = target:values("dora.binding_outputs")
        -- All SDK/mode configs write these same source-tree outputs. Share
        -- their dependency record and serialize generation across processes.
        local state_dir = path.join(os.projectdir(), "build/host/bindings")
        os.mkdir(state_dir)
        local lock = assert(io.openlock(path.join(state_dir, "generate.lock")))
        lock:lock()
        local inputs = os.files(path.join(TOLUA_DIR, "**.lua"))
        table.join2(inputs, {path.join(os.projectdir(), "Projects/xmake/tools/tolua_main.c"),
            path.join(os.projectdir(), "Projects/xmake/rules/generated_lua.lua")})
        table.join2(inputs, os.files(path.join(TOLUA_DIR, "tolua++build/**.c")))
        table.join2(inputs, os.files(path.join(TOLUA_DIR, "**.h")))
        for _, input in ipairs(os.files(path.join(TOLUA_DIR, "**.pkg"))) do
            table.insert(inputs, input)
        end
        for _, input in ipairs(os.files(path.join(os.projectdir(), "Source/**.h"))) do
            table.insert(inputs, input)
        end
        local missing_output = false
        for _, output in ipairs(outputs) do
            if not os.isfile(output) then
                missing_output = true
                break
            end
        end
        depend.on_changed(function ()
            cprint("${bright}generating Dora Lua bindings${clear}")
            os.vrunv(generator, {script})
        end, {
            dependfile = path.join(state_dir, "generated_lua.d"),
            files = inputs,
            values = outputs,
            changed = missing_output
        })
        lock:close()
    end)
target_end()
