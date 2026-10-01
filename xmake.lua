set_project("Dora-SSR")
set_version("1.0.0")
set_xmakever("3.0.0")

set_allowedmodes("debug", "release")
set_defaultmode("debug")
set_allowedplats("macosx", "iphoneos", "linux", "windows", "android", "wasm")
set_policy("build.fence", true)

if is_plat("macosx") then
    set_config("target_minver", "12.0")
elseif is_plat("iphoneos") then
    set_config("target_minver", "13.0")
elseif is_plat("android") then
    set_config("ndk_sdkver", "28")
end

add_repositories("dora-packages Projects/xmake/packages")

includes("Projects/xmake/options.lua")
includes("Projects/xmake/web/options.lua")
if is_plat("iphoneos") and (get_config("dora_ios_sign_identity") or "-") == "-" then
    set_config("xcode_codesign_identity", false)
end
includes("Projects/xmake/dependencies/host_tools.lua")
includes("Projects/xmake/dependencies/native_runtime.lua")
includes("Projects/xmake/dependencies/vendor.lua")
includes("Projects/xmake/rules/generated_lua.lua")
if is_plat("wasm") then
    includes("Projects/xmake/web/targets.lua")
else
    includes("Projects/xmake/engine.lua")
end
includes("Projects/xmake/tasks/doctor.lua")
includes("Projects/xmake/tasks/audit.lua")
includes("Projects/xmake/tasks/package.lua")
includes("Projects/xmake/tasks/android.lua")
includes("Projects/xmake/tasks/web.lua")
includes("Projects/xmake/tasks/native.lua")
includes("Projects/xmake/tasks/test.lua")
includes("Projects/xmake/tasks/tools.lua")
includes("Projects/xmake/tasks/wa.lua")

target("dora-build-info")
    -- xmake 3.1.1's Xcode generator only models static/shared/binary
    -- products. This metadata-only kind is used while generating IDE files;
    -- the generated build phase starts a fresh xmake process, where the
    -- target keeps its real phony semantics.
    set_kind(os.getenv("XMAKE_IN_PROJECT_GENERATOR") and "binary" or "phony")
    set_default(false)
    on_build(function ()
        import("core.project.config")
        import("lib.detect.find_tool")
        cprint("${bright}Dora-SSR xmake configuration${clear}")
        local tool = assert(find_tool("xmake", {force = true, check = function () return true end}), "xmake not found")
        local version = os.iorunv(tool.program, {"--version"}):match("([^\r\n]+)")
        cprint("  xmake: %s", version)
        cprint("  platform: %s", config.plat() or "not configured")
        cprint("  architecture: %s", config.arch() or "not configured")
        cprint("  mode: %s", config.mode() or "not configured")
    end)
target_end()
