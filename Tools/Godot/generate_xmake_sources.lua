-- Generate off-tree using Lua. Upstream .py files supply literal templates only.
function generate(output, profile_path, disabled)
    local C = import("common", {rootdir = os.scriptdir()})
    local root = path.join(C.root(), "Source/3rdParty/Godot")
    output = C.real(output or path.join(C.root(), "build/godot-xmake/generated"))
    assert(output ~= C.real(root) and not output:startswith(C.real(root) .. path.sep()), "Generate outside the vendored source tree")
    profile_path = C.real(profile_path or path.join(C.root(), "Projects/xmake/godot/template_release.json"))
    local profile = C.load(profile_path)
    for _, name in ipairs(disabled or {}) do
        assert(table.contains(profile.enabled_modules, name), "Cannot disable unknown module: " .. name)
        local modules = {}; for _, candidate in ipairs(profile.enabled_modules) do if candidate ~= name then modules[#modules + 1] = candidate end end; profile.enabled_modules = modules
    end
    local inputs = {profile_path}
    table.join2(inputs, os.files(path.join(os.scriptdir(), "codegen*.lua")), {path.join(os.scriptdir(), "generate_xmake_sources.lua")})
    for _, suffix in ipairs({"py", "glsl", "svg"}) do table.join2(inputs, os.files(path.join(root, "**." .. suffix))) end
    for _, name in ipairs({"AUTHORS.md", "DONORS.md", "COPYRIGHT.txt", "LICENSE.txt", "thirdparty/certs/ca-bundle.crt", "thirdparty/fonts/OpenSans_SemiBold.woff2", "thirdparty/smaa/AreaTex.png", "thirdparty/smaa/SearchTex.png", "main/splash.png", "main/app_icon.png", "core/input/gamecontrollerdb.txt", "core/input/godotcontrollerdb.txt", "core/extension/gdextension_interface.json", "servers/rendering/storage/ltc/ltc_lut1.dds", "servers/rendering/storage/ltc/ltc_lut2.dds"}) do inputs[#inputs + 1] = path.join(root, name) end
    table.sort(inputs)
    import("core.base.json")
    local hashes = {C.serialize(profile, true)}
    for _, file in ipairs(inputs) do hashes[#hashes + 1] = C.relative(file, C.root()) .. "\0" .. C.digest(file) end
    local fingerprint = C.data_digest(table.concat(hashes, "\n"))
    local state = path.join(output, ".xmake-codegen.json")
    if os.isfile(state) then
        local previous = C.load(state)
        local valid = previous.fingerprint == fingerprint and #(previous.outputs or {}) > 0
        for _, name in ipairs(previous.outputs or {}) do if not os.isfile(path.join(output, name)) or os.islink(path.join(output, name)) then valid = false end end
        if valid then print("Godot xmake codegen unchanged: %d outputs", #previous.outputs); return previous end
    end
    local temporary, outputs, changed = os.tmpfile() .. "-godot-codegen", {}, 0
    os.mkdir(output)
    try {function ()
        local function emit(name, text)
            C.safe_relative(name); C.write(path.join(temporary, name), text); outputs[#outputs + 1] = name
        end
        import("codegen_core", {rootdir = os.scriptdir()}).generate(root, profile, emit)
        import("codegen_virtuals", {rootdir = os.scriptdir()}).generate(root, emit)
        import("codegen_interface", {rootdir = os.scriptdir()}).generate(root, emit)
        import("codegen_shaders", {rootdir = os.scriptdir()}).generate(root, emit)
        for _, name in ipairs(outputs) do
            local destination = path.join(output, name)
            assert(not os.islink(destination), "Generated output must not be a symlink: " .. destination)
            assert(C.real(destination):startswith(C.real(output) .. path.sep()), "Generated output escapes its directory")
            if C.copy(path.join(temporary, name), destination) then changed = changed + 1 end
        end
    end, finally {function (ok, errors) os.tryrm(temporary); if not ok then raise(errors) end end}}
    local payload = {fingerprint = fingerprint, generator = "Tools/Godot/generate_xmake_sources.lua", profile = C.relative(profile_path, C.root()), inputs = #inputs, outputs = outputs}
    C.save(state, payload)
    print("Godot xmake codegen generated: %d outputs, %d changed", #outputs, changed)
    return payload
end
function main(...)
    local C = import("common", {rootdir = os.scriptdir()})
    local args = C.args({...}, {output = "value", profile = "value", ["disable-module"] = "many"})
    generate(args.output, args.profile, args["disable-module"])
end
