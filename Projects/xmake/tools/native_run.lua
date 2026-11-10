-- Target run hook for the built-in xmake run action, including debugger runs.
local function run_arguments(root, arguments)
    local args = table.join(arguments or {})
    -- xmake's variadic run arguments retain a separator after the target.
    if args[1] == "--" then table.remove(args, 1) end
    local assets
    for i, arg in ipairs(args) do
        local value
        if arg == "--asset" then
            value = args[i + 1]
            assert(value and #value > 0 and not value:startswith("--"), "--asset expects a directory")
            args[i + 1] = path.absolute(value, root)
        elseif arg:startswith("--asset=") then
            value = arg:sub(9)
            assert(#value > 0, "--asset expects a directory")
            args[i] = "--asset=" .. path.absolute(value, root)
        end
        if value then
            assert(not assets, "--asset may only be specified once")
            assets = path.absolute(value, root)
        end
    end
    if not assets then
        assets = path.join(root, "Assets")
        args = table.join({"--asset", assets}, args)
    end
    assert(os.isdir(assets), "asset directory not found: " .. assets)
    return args, assets
end

function main(target)
    import("core.base.option")
    import("core.project.config")
    assert(target:plat() == os.host(), "run requires the host platform")
    local root = os.projectdir()
    local args, assets = run_arguments(root, option.get("arguments") or target:get("runargs"))
    target:set("rundir", root)
    import("Projects.xmake.godot.component", {rootdir = root, anonymous = true})(target, true, assets)
    local configured = os.getenv("DORA_GODOT_LIBRARY")
    if config.get("dora_godot_runtime") and (not configured or configured == "") then
        local library = target:is_plat("windows") and "dora_godot.dll"
            or target:is_plat("macosx") and "libdora_godot.dylib" or "libdora_godot.so"
        target:set("runenv", "DORA_GODOT_LIBRARY", path.join(assets, library))
    end
    import("devel.debugger")
    import("private.action.run.runenvs")
    local binary = path.absolute(target:targetfile())
    if target:is_plat("macosx") then
        binary = path.join(target:data("xcode.bundle.contentsdir"), "MacOS", path.filename(binary))
    end
    local addenvs, setenvs = runenvs.make(target)
    if option.get("debug") then
        debugger.run(binary, args, {curdir = root, addenvs = addenvs, setenvs = setenvs})
    else
        os.execv(binary, args, {curdir = root, detach = option.get("detach"), envs = runenvs.join(addenvs, setenvs)})
    end
end
