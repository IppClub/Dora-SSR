local C = import("common", {rootdir = os.scriptdir()})
local D = import("project_delivery", {rootdir = os.scriptdir()})
function clone(repository, output, timeout)
    assert(not os.exists(output) and not os.islink(output), "Clone into a new directory")
    os.mkdir(path.directory(output))
    D.run_command({"git", "clone", "--", repository, output}, output .. ".clone.log", timeout or 300)
    return {cloned = true, repository = C.real(output), commit = os.iorunv("git", {"-C", output, "rev-parse", "HEAD"}):trim()}
end
function lua_string(value)
    local equals = ""
    while value:find("]" .. equals .. "]", 1, true) do equals = equals .. "=" end
    return "[" .. equals .. "[" .. value .. "]" .. equals .. "]"
end
function require_ordinary_host(binary)
    local stream = assert(io.open(binary, "rb"), "Dora executable is missing")
    try {function ()
        local previous = ""
        local remaining = os.filesize(binary)
        while remaining > 0 do
            local block = assert(stream:read(math.min(remaining, 1024 * 1024)), "Truncated host binary")
            remaining = remaining - #block
            local data = previous .. block
            assert(not data:find("GODOT_NODE_TEST", 1, true) and not data:find("GODOT_CAPABILITY_QUERY matches=", 1, true), "Use an ordinary Dora host, not an opt-in Godot test executable")
            previous = data:sub(-64)
        end
    end, finally {function (ok, errors) stream:close(); if not ok then raise(errors) end end}}
end
function preview(args)
    local binary = args.app and path.join(C.real(args.app), "Contents/MacOS/Dora") or C.real(C.required(args, "binary"))
    require_ordinary_host(binary)
    local original_work = C.required(args, "work-dir"); assert(not os.islink(original_work), "Preview needs a new work directory")
    local work = C.real(original_work); assert(not os.exists(work), "Preview needs a new work directory")
    local input = C.required(args, "source")
    local remote = input:find("://", 1, true) or input:startswith("git@")
    local source = not remote and C.real(input) or nil
    if source and os.isdir(source) then assert(work ~= source and not work:startswith(source .. path.sep()), "Preview work must be outside input repository/game package") end
    local duration = C.number(args.duration or 0, 0)
    local width, height = C.number(args.width or 640, 1, 8192), C.number(args.height or 360, 1, 8192)
    local buffers = C.choice(tonumber(args.buffers or 3), {2, 3, 4})
    os.mkdir(work)
    if remote then source = path.join(work, "repository"); clone(input, source, args.timeout) end
    local info
    if os.isfile(source) and source:lower():match("%.zip$") then
        local Z = import("zip", {rootdir = os.scriptdir()})
        local game = false
        for _, entry in ipairs(Z.entries(source)) do if entry.name == "game.json" then game = true end end
        if game then info = D.install_game(source, path.join(work, "installed"))
        else local repository = path.join(work, "repository"); D.import_repository(source, repository); source = repository end
    end
    info = info or D.inspect(source, args.project)
    local project = info.project
    if info.kind == "project" then project = D.prepare(source, path.join(work, "prepared"), args.godot or os.getenv("DORA_GODOT_EDITOR") or "godot", args.project, tonumber(args.timeout or 300)).project end
    local host_platform = ({macosx = "macOS", linux = "Linux", windows = "Windows Desktop"})[os.host()]
    assert(info.kind ~= "game" or info.platform == host_platform, "Game package targets another platform")
    local runtime = C.real(C.required(args, "runtime-package"))
    import("verify_package", {rootdir = os.scriptdir()}).verify(runtime)
    local manifest = C.load(path.join(runtime, "manifest.json"))
    local library = path.join(runtime, manifest.library)
    local assets, command, app
    if args.app then
        assert(os.host() == "macosx", "--app requires macOS; use --binary and --asset-source elsewhere")
        app = path.join(work, "Dora.app")
        local copied = false
        try {function () os.execv("cp", {"-cR", C.real(args.app), app}); copied = true end}
        if not copied then os.tryrm(app); os.execv("cp", {"-R", C.real(args.app), app}) end
        assets, binary = path.join(app, "Contents/Resources"), path.join(app, "Contents/MacOS/Dora")
        command = {binary}
    else
        assert(args["asset-source"] and os.isdir(args["asset-source"]), "Provide an existing --binary and --asset-source")
        assets = path.join(work, "assets"); os.cp(C.real(args["asset-source"]), assets)
        command = {binary, "--asset", assets}
    end
    local values = {PROJECT = lua_string(project), WIDTH = tostring(width), HEIGHT = tostring(height), BUFFERS = tostring(buffers), DURATION = tostring(duration),
        CAPTURE = lua_string(args.capture and C.real(args.capture) or ""), STATE = lua_string(path.join(work, "player.json")), ERROR = lua_string(path.join(work, "player-error.txt"))}
    if args.capture then os.mkdir(path.directory(C.real(args.capture))) end
    local startup = C.read(path.join(os.scriptdir(), "project_player.lua")):gsub("@([A-Z_]+)@", values)
    C.write(path.join(assets, "Script/init.lua"), startup)
    if app then C.run("codesign", {"--force", "--deep", "--timestamp=none", "--sign", "-", app}); C.run("codesign", {"--verify", "--deep", "--strict", app}) end
    local record = {prepared = true, command = command, project = project, host_sha256 = C.digest(binary), runtime_sha256 = C.digest(library),
        runtime_manifest_sha256 = C.digest(path.join(runtime, "manifest.json")), startup_sha256 = C.digest(path.join(assets, "Script/init.lua")),
        scope = "One game in an ordinary Dora host; does not implement in-process project switching"}
    C.save(path.join(work, "preview.json"), record)
    if args["no-run"] then return record end
    local env = {}
    for name in pairs(os.getenvs()) do if name:startswith("DORA_GODOT_") or name:startswith("DORA_BUILD_") then env[name] = false end end
    env.DORA_GODOT_LIBRARY = library
    if manifest.graphics_backend == "wgl" then env.DORA_GODOT_WINDOWS_GL = "1" end
    D.run_command(command, path.join(work, "run.log"), duration > 0 and duration + 90 or nil, {env = env, cwd = path.directory(binary)})
    local state = os.isfile(path.join(work, "player.json")) and C.load(path.join(work, "player.json")) or {}
    assert(state.ready and not state.failed and (not args.capture or state.captured), "Dora preview failed; see run.log")
    if state.state ~= "closed" then state.state = "closed"; state.reason = "window_closed"; C.save(path.join(work, "player.json"), state) end
    record.played = true; record.exit_code = 0; record.player = state; C.save(path.join(work, "preview.json"), record); return record
end
function main(...)
    local argv = {...}; local command = table.remove(argv, 1)
    if command == "--help" or command == "-h" then
        print("Usage: xmake lua Tools/Godot/project.lua inspect|clone|import|prepare|export|run|archive|install SOURCE [options]")
        return
    end
    local args = C.args(argv, {project = "value", godot = "value", timeout = "value", output = "value", ["work-dir"] = "value", id = "value", version = "value", preset = "value", platform = "value", app = "value", binary = "value", ["asset-source"] = "value", ["runtime-package"] = "value", width = "value", height = "value", buffers = "value", duration = "value", capture = "value", ["no-run"] = "flag", ["max-bytes"] = "value", ["max-files"] = "value"})
    assert(#args.positional == 1, "Usage: xmake lua Tools/Godot/project.lua inspect|clone|import|prepare|export|run|archive|install SOURCE [options]")
    local source = args.positional[1]; local result
    local timeout = tonumber(args.timeout or 300)
    if command == "inspect" then result = D.inspect(source, args.project)
    elseif command == "clone" then result = clone(source, C.required(args, "output"), timeout)
    elseif command == "import" then result = D.import_repository(source, C.required(args, "output"))
    elseif command == "prepare" then result = D.prepare(source, C.required(args, "output"), args.godot or os.getenv("DORA_GODOT_EDITOR") or "godot", args.project, timeout)
    elseif command == "export" then result = D.export_game(source, C.required(args, "output"), C.required(args, "work-dir"), args.godot or os.getenv("DORA_GODOT_EDITOR") or "godot", C.required(args, "id"), args.version, args.project, args.preset, args.platform, timeout)
    elseif command == "archive" then result = D.archive_game(source, C.required(args, "output"))
    elseif command == "install" then result = D.install_game(source, C.required(args, "output"), tonumber(args["max-bytes"]), tonumber(args["max-files"]))
    elseif command == "run" then args.source = source; result = preview(args)
    else raise("Unknown project command: " .. tostring(command)) end
    import("core.base.json"); print(C.serialize(result))
end
