-- Production packaging uses the same standalone xmake builders as maintainers.
-- The Windows DLL deliberately has its own MinGW toolchain; Dora stays MSVC.
function main(target, staging)
    import("lib.detect.find_tool")
    import("core.base.json")
    import("core.project.config")
    local root = os.projectdir()
    local platform = target:plat() == "iphoneos" and "ios" or target:plat()
    if staging and not config.get("dora_godot_runtime") then
        local bundle = target:data("xcode.bundle.rootdir")
        local assets = bundle and target:data("xcode.bundle.resourcesdir") or path.join(target:targetdir(), "Assets")
        local changed = false
        for _, name in ipairs({"libdora_godot.dylib", "libdora_godot.so", "dora_godot.dll", "GodotRuntimeNotices", "Frameworks/DoraGodot.framework"}) do
            local file = path.join(assets, name)
            if os.exists(file) then os.rm(file); changed = true end
        end
        if bundle and changed then os.tryrm(target:dependfile(path.absolute(bundle))) end
        return
    end
    local args = {path.join(root, "Tools/Godot/build_component.py"),
        "--platform", platform, "--arch", target:arch(), "--mode", config.mode()}
    local runtime = os.getenv("DORA_GODOT_RUNTIME_DIR")
    if runtime and runtime ~= "" then table.join2(args, {"--runtime-package", runtime}) end
    if platform == "windows" then
        table.join2(args, {"--windows-backend", config.get("dora_godot_windows_backend") or "d3d12"})
        if config.get("dora_godot_mesa_libs") then table.join2(args, {"--mesa-libs", config.get("dora_godot_mesa_libs")}) end
    end
    if platform == "ios" then
        table.join2(args, {"--device", config.get("appledev") == "simulator" and "simulator" or "device"})
    end
    local output = path.join(root, "build/godot-component/receipts", platform,
        target:arch(), config.mode(), (platform == "windows" and config.get("dora_godot_windows_backend") or config.get("appledev") or "host"), staging and "stage.json" or "build.json")
    table.join2(args, {"--output", output})
    if staging then
        local bundle = target:data("xcode.bundle.rootdir")
        local assets = bundle and target:data("xcode.bundle.resourcesdir") or path.join(target:targetdir(), "Assets")
        table.join2(args, {"--stage-only", "--stage", path.absolute(assets)})
    end
    os.vrunv(assert(find_tool("python3") or find_tool("python"), "Godot requires Python 3").program,
        args, {curdir = root, envs = {DORA_XMAKE = os.programfile()}})
    local receipt = json.loadfile(output)
    if staging and receipt.staged_changed and target:data("xcode.bundle.rootdir") then
        -- A new runtime must invalidate the cached bundle signature, even if
        -- the executable and installfiles did not change.
        os.tryrm(target:dependfile(path.absolute(target:data("xcode.bundle.rootdir"))))
    end
end
