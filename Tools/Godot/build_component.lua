function run_builder(program, arguments, options, builddir, linking)
    local C = import("common", {rootdir = os.scriptdir()})
    local ok, errors = true, nil
    try {function () os.execv(program, arguments, options) end, catch {function (message) ok = false; errors = message end}}
    if not ok then
        local log = path.join(builddir, linking and "link.log" or "build.log")
        if os.isfile(log) then
            local text = C.read(log):sub(-96 * 1024):gsub("\n$", "")
            local lines = text:split("\n", {plain = true, strict = true})
            print("Godot compiler log: %s\n%s", log, table.concat(table.slice(lines, math.max(1, #lines - 179)), "\n"))
        end
        raise(errors)
    end
end

-- Build and stage the production component through the standalone builders.
function stage(package, destination, platform, metadata)
    local C = import("common", {rootdir = os.scriptdir()})
    os.mkdir(destination)
    local changed = false
    local function copy(name, target) changed = C.copy(path.join(package, name), path.join(destination, target or name)) or changed end
    if platform == "ios" or platform == "web" then
        for _, file in ipairs(C.files(package)) do
            local name = C.relative(file, package)
            if platform == "web" then copy(name)
            elseif name:startswith("DoraGodot.framework/") then copy(name, "Frameworks/" .. name) end
        end
        if platform == "web" then return changed end
    else copy(metadata.library) end
    copy("manifest.json", "GodotRuntimeNotices/manifest.json")
    local sidecars = {}
    if table.contains({"macosx", "linux", "windows"}, platform) then
        for name in pairs(metadata.artifacts) do if name ~= metadata.library then sidecars[name] = true end end
    else
        for _, name in ipairs(table.join(metadata.licenses, metadata.dependency_provenance or {})) do sidecars[name] = true end
    end
    for _, name in ipairs(C.keys(sidecars)) do copy(name, "GodotRuntimeNotices/" .. name) end
    return changed
end

function build(args)
    local C = import("common", {rootdir = os.scriptdir()})
    local platform = C.choice(C.required(args, "platform"), {"macosx", "linux", "windows", "android", "web", "ios"})
    local mode = C.choice(C.required(args, "mode"), {"debug", "release"})
    local original = C.required(args, "arch")
    local arch = ({aarch64 = "arm64", x64 = "x86_64", ["arm64-v8a"] = "arm64", ["armeabi-v7a"] = "arm32"})[original] or original
    local supported = {macosx = {"arm64"}, linux = {"arm64", "x86_64"}, windows = {"x86_64"},
        android = {"arm64", "arm32", "x86_64"}, web = {"wasm32"}, ios = {"arm64"}}
    assert(table.contains(supported[platform], arch), "Godot production component does not support " .. platform .. "/" .. arch)
    local device = C.choice(args.device or "simulator", {"simulator", "device"})
    local windows = C.choice(args["windows-backend"] or "d3d12", {"d3d12", "wgl"})
    local jobs = C.number(args.jobs or os.getenv("JOBS") or "2", 1)
    assert(jobs % 1 == 0, "jobs must be an integer")
    if table.contains({"android", "ios", "web"}, platform) then jobs = math.min(jobs, 16) end
    local builddir = path.join(C.root(), "build/godot-component", platform, arch, mode)
    if platform == "ios" then builddir = path.join(builddir, device) end
    if platform == "windows" then builddir = path.join(builddir, windows) end
    local package = C.real(args["runtime-package"] or path.join(builddir, "package"))
    local target = "template_" .. mode
    local envs = {DORA_GODOT_TARGET = target, JOBS = tostring(jobs), DORA_GODOT_XMAKE = os.getenv("DORA_XMAKE") or os.programfile()}
    local function run(name, argv)
        local program, arguments
        if name:endswith(".sh") then program, arguments = "bash", table.join({path.join(C.root(), "Tools/Godot", name)}, argv or {})
        else program, arguments = os.programfile(), table.join({"lua", path.join(C.root(), "Tools/Godot", name .. ".lua")}, argv or {}) end
        run_builder(program, arguments, {curdir = C.root(), envs = envs}, builddir, name == "link_ios_runtime")
    end
    if not args["stage-only"] and not args["runtime-package"] then
        os.mkdir(builddir)
        local base = {"--build-dir", builddir, "--target", target, "--jobs", tostring(jobs)}
        if platform == "macosx" or platform == "linux" then
            envs.DORA_GODOT_BUILD_DIR = builddir; envs.DORA_GODOT_ARCH = arch; envs.DORA_GODOT_LINUX_ARCH = arch
            if platform == "linux" and arch ~= os.arch() then envs.DORA_GODOT_LINUX_CROSS = os.getenv("DORA_GODOT_LINUX_CROSS") or (arch == "arm64" and "aarch64-linux-gnu-" or "x86_64-linux-gnu-") end
            run(platform == "macosx" and "build_runtime.sh" or "build_linux_runtime.sh")
        elseif platform == "windows" then
            table.join2(base, {"--arch", arch, "--backend", windows:upper()})
            if windows == "d3d12" then table.join2(base, {"--mesa-libs", args["mesa-libs"] or import("ensure_nir_sdk", {rootdir = os.scriptdir()}).ensure_sdk()}) end
            run("build_windows_runtime", base)
        elseif platform == "ios" then
            table.join2(base, {"--device", device}); run("build_ios_runtime", base)
            run("link_ios_runtime", {"--build-dir", builddir, "--device", device})
        elseif platform == "android" then
            local sdk = args.sdk or os.getenv("ANDROID_HOME") or os.getenv("ANDROID_SDK_ROOT") or path.join(os.getenv("HOME") or os.getenv("USERPROFILE"), "Library/Android/sdk")
            table.join2(base, {"--sdk", sdk, "--arch", arch}); run("build_android_runtime", base)
        else run("build_web_runtime", base) end
    end
    import("verify_package", {rootdir = os.scriptdir()}).verify(package)
    local metadata = C.load(path.join(package, "manifest.json"))
    assert(metadata.build_target == target, mode .. " host requires " .. target)
    local architectures = platform == "web" and {(metadata.toolchain or {}).arch} or (metadata.architectures or {})
    assert(table.contains(architectures, arch), "Godot runtime architecture does not match the host")
    local backend = ({macosx = "metal", ios = "metal", linux = "egl", android = "egl", windows = windows, web = "webgl2"})[platform]
    assert(metadata.graphics_backend == backend, "Godot runtime graphics backend does not match the production host")
    if platform == "ios" then assert(metadata.device == device, "Godot framework SDK does not match the iOS host") end
    local changed = args.stage and stage(package, C.real(args.stage), platform, metadata) or false
    local result = {package = package, platform = platform, arch = arch, build_target = target,
        graphics_backend = backend, library = metadata.library or "dora-godot.wasm", staged_changed = changed}
    if args.output then C.save(args.output, result) end
    return result
end

function main(...)
    local C = import("common", {rootdir = os.scriptdir()})
    local args = C.args({...}, {platform = "value", arch = "value", mode = "value", device = "value", jobs = "value",
        ["runtime-package"] = "value", stage = "value", ["stage-only"] = "flag", ["windows-backend"] = "value",
        ["mesa-libs"] = "value", sdk = "value", output = "value"})
    import("core.base.json"); print(C.serialize(build(args)))
end
