function main(...)
    local root = path.absolute(path.join(os.scriptdir(), "../../.."))
    local C = import("Tools.Godot.common", {rootdir = root})
    local P = import("Tools.Godot.project", {rootdir = root})
    local args = C.args({...}, {example = "value", ["runtime-package"] = "value", output = "value", app = "value", binary = "value", ["asset-source"] = "value"})
    local example = C.choice(C.required(args, "example"), {"2d", "3d"})
    assert((args.app ~= nil) ~= (args.binary ~= nil), "Provide --app or --binary")
    local runtime = C.real(C.required(args, "runtime-package")); import("Tools.Godot.verify_package", {rootdir = root}).verify(runtime)
    local manifest = C.load(path.join(runtime, "manifest.json"))
    local out = C.real(C.required(args, "output")); assert(not os.exists(out), "Use a new output directory")
    local binary = args.app and path.join(C.real(args.app), "Contents/MacOS/Dora") or C.real(args.binary)
    P.require_ordinary_host(binary)
    os.mkdir(out)
    local app, assets
    if args.app then
        assert(os.host() == "macosx", "--app requires macOS")
        app = path.join(out, "Dora.app"); os.execv("cp", {"-R", C.real(args.app), app})
        assets, binary = path.join(app, "Contents/Resources"), path.join(app, "Contents/MacOS/Dora")
    else
        assert(args["asset-source"] and os.isdir(args["asset-source"]), "Provide --asset-source")
        assets = path.join(out, "assets"); os.cp(C.real(args["asset-source"]), assets)
    end
    local project = path.join(assets, "GodotProject"); assert(not os.exists(project), "Host assets already contain GodotProject")
    os.cp(path.join(os.scriptdir(), example), project); os.tryrm(path.join(project, ".godot")); C.write(path.join(project, ".godot/global_script_class_cache.cfg"), "list=[]\n")
    C.copy(path.join(os.scriptdir(), "host.lua"), path.join(assets, "Script/GodotExample.lua")); C.write(path.join(assets, "Script/init.lua"), 'return require("Script.GodotExample")\n')
    C.copy(path.join(runtime, manifest.library), path.join(assets, manifest.library))
    local notices = path.join(assets, "GodotNotices")
    for _, name in ipairs(manifest.licenses) do C.copy(path.join(runtime, name), path.join(notices, name)) end
    if app then C.run("codesign", {"--force", "--deep", "--sign", "-", app}); C.run("codesign", {"--verify", "--deep", "--strict", app}) end
    local command = args.app and {binary} or {binary, "--asset", assets}
    local inputs = {binary, path.join(assets, "Script/init.lua"), path.join(assets, "Script/GodotExample.lua"), path.join(assets, manifest.library)}
    table.join2(inputs, C.files(project), C.files(notices))
    local hashes = {}; for _, file in ipairs(inputs) do hashes[file] = C.digest(file) end
    C.save(path.join(out, "example.json"), {prepared = true, example = example, command = command, asset_root = assets,
        runtime_manifest_sha256 = C.digest(path.join(runtime, "manifest.json")), files_sha256 = hashes,
        scope = "Runnable example staging with an ordinary host; not a signed installer or GPU acceptance."})
    import("core.base.json"); print(C.serialize({prepared = true, example = example, command = command}))
end
