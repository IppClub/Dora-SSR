-- Shared standalone xmake orchestration. Third-party compilers retain their own runtimes.
function probe_version(program, arguments)
    local banner = os.iorunv(program, arguments or {"--version"})
    local version = banner:match("xmake%s+v(%d+)%.")
    assert(version and tonumber(version) >= 3, "Godot xmake migration requires xmake 3.x or newer")
    return tonumber(version), banner
end
function build(platform, args)
    local C = import("common", {rootdir = os.scriptdir()})
    local M = import("package_manifest", {rootdir = os.scriptdir()})
    local source, root = path.join(C.root(), "Source/3rdParty/Godot"), C.root()
    local target = C.choice(args.target or "template_debug", {"template_debug", "template_release"})
    local mode = target == "template_release" and "release" or "debug"
    local jobs = C.number(args.jobs or "2", 1, platform ~= "windows" and 16 or nil)
    assert(jobs % 1 == 0, "jobs must be an integer")
    C.choice(args.builder or "xmake", {"xmake", "auto"})
    local arch = platform == "windows" and C.choice(args.arch or "x86_64", {"x86_64", "arm64"})
        or platform == "android" and C.choice(args.arch or "arm64", {"arm64", "arm32", "x86_64"})
        or platform == "web" and "wasm32" or "arm64"
    local backend = platform == "windows" and C.choice(args.backend or "WGL", {"WGL", "D3D12"}):lower()
        or platform == "web" and "webgl2" or platform == "ios" and "metal" or "egl"
    if backend == "d3d12" then assert(args["mesa-libs"] and os.isdir(args["mesa-libs"]), "--mesa-libs must identify the audited Godot NIR SDK root for D3D12") end
    local device = C.choice(args.device or "simulator", {"simulator", "device"})
    local default = platform == "windows" and (backend == "d3d12" and "build/godot-windows-d3d12" or "build/godot-windows")
        or platform == "ios" and "build/godot-ios/" .. device
        or platform == "web" and "build/godot-web" .. (mode == "release" and "/release" or "")
        or "build/godot-android" .. ((mode == "debug" and arch == "arm64") and "" or "/" .. mode .. "/" .. arch)
    local builddir = C.real(args["build-dir"] or path.join(root, default))
    local variant = platform == "windows" and "windows_" .. (backend == "d3d12" and "d3d12_" or "") .. arch
        or platform == "android" and "android_" .. arch or platform == "ios" and "ios_" .. device .. "_arm64" or "web_wasm32"
    local names = {"xmake.lua", "Projects/xmake/options.lua", "Projects/xmake/godot/targets.lua", "Tools/Godot/generate_xmake_sources.lua",
        "Projects/xmake/godot/" .. variant .. "_sources.lua"}
    if platform == "web" or platform == "ios" then
        table.join2(names, {"Projects/xmake/dependencies/host_tools.lua", "Projects/xmake/godot/" .. platform .. "_link.json", "Projects/xmake/godot/template_release_" .. platform .. ".json"})
    end
    local V = import("vendor_source", {rootdir = os.scriptdir()})
    V.verify_common(source)
    if platform ~= "windows" then V["verify_" .. platform](source) end
    import("lib.detect.find_tool")
    local xmake = assert(find_tool(args.xmake or os.getenv("DORA_GODOT_XMAKE") or os.programfile()), "Configured xmake executable is missing").program
    probe_version(xmake)
    local envs = {XMAKE_CONFIGDIR = path.join(builddir, "xmake-config")}
    local plat = ({windows = "mingw", web = "wasm", ios = "iphoneos", android = "android"})[platform]
    local abi = ({arm64 = "arm64-v8a", arm32 = "armeabi-v7a", x86_64 = "x86_64"})[arch]
    local configure = {xmake, "f", "-P", root, "-c", "-p", plat, "-a", platform == "android" and abi or arch,
        "-m", mode, "--dora_godot_runtime=y", "--dora_godot_standalone=y", "--ccache=n", "-y"}
    local ndk, sdk, appledev
    if platform == "windows" then
        configure[#configure + 1] = "--dora_godot_windows_backend=" .. backend
        if args["mesa-libs"] then configure[#configure + 1] = "--dora_godot_mesa_libs=" .. C.real(args["mesa-libs"]) end
        if args["xmake-sdk"] then configure[#configure + 1] = "--sdk=" .. C.real(args["xmake-sdk"]) end
        if args["xmake-cross"] then configure[#configure + 1] = "--cross=" .. args["xmake-cross"] end
    elseif platform == "web" then envs.BINARYEN_CORES = tostring(jobs)
    elseif platform == "android" then
        sdk = C.real(C.required(args, "sdk")); ndk = path.join(sdk, "ndk/29.0.14206865")
        assert(os.isfile(path.join(ndk, "source.properties")), "Install Android NDK29.0.14206865 with the SDK manager first")
        envs.ANDROID_HOME = sdk
        table.join2(configure, {"--ndk=" .. ndk, "--ndk_sdkver=28", "--runtimes=c++_shared"})
    else
        assert(os.host() == "macosx", "iOS builds require macOS and Xcode")
        local sdkname = device == "simulator" and "iphonesimulator" or "iphoneos"
        sdk = os.iorunv("xcrun", {"--sdk", sdkname, "--show-sdk-path"}):trim()
        local sdkversion = os.iorunv("xcrun", {"--sdk", sdkname, "--show-sdk-version"}):trim()
        local xcode = sdk:match("^(.-%.app)/")
        assert(xcode, "Cannot identify the active Xcode application from SDK: " .. sdk)
        appledev = device == "simulator" and "simulator" or "iphoneos"
        table.join2(configure, {"--appledev=" .. appledev, "--xcode=" .. xcode, "--xcode_sdkver=" .. sdkversion})
    end
    os.mkdir(builddir); os.tryrm(path.join(builddir, "compilation.json"))
    local inputs = {}; for _, name in ipairs(names) do inputs[name] = C.digest(path.join(root, name)) end
    local commands = {configure, {xmake, "l", "-P", root, "Projects/xmake/godot/toolchain_info.lua", path.join(builddir, "toolchain.json")},
        {xmake, "build", "-P", root, "-j" .. jobs, "godot-runtime"}}
    C.save(path.join(builddir, platform == "windows" and "command.json" or "commands.json"), commands)
    local log = assert(io.open(path.join(builddir, "build.log"), "w"))
    local toolchain
    try {function ()
        for index, command in ipairs(commands) do
            os.execv(command[1], table.slice(command, 2), {curdir = root, envs = envs, stdout = log, stderr = log})
            if index == 2 then
                toolchain = C.load(path.join(builddir, "toolchain.json"))
                if platform == "ios" then
                    assert(toolchain.plat == "iphoneos" and toolchain.arch == "arm64" and toolchain.appledev == appledev and toolchain.target_minver == "14.0", "Wrong iOS xmake toolchain")
                    assert(C.real(toolchain.sdk) == C.real(sdk), "xmake SDK differs from active xcrun SDK")
                end
            end
        end
    end, finally {function (ok, errors) log:close(); if not ok then raise(errors) end end}}
    for name, expected in pairs(inputs) do assert(C.digest(path.join(root, name)) == expected, "Godot xmake inputs changed during the build: " .. name) end
    local package = path.join(builddir, "package")
    local record = {passed = true, builder = "xmake", source_archive_sha256 = M.source_sha256(), build_target = target,
        commands = commands, command = commands[#commands], toolchain = toolchain, migration_inputs_sha256 = inputs,
        graphics_backend = backend, vendor_validation_sha256 = C.digest(path.join(os.scriptdir(), "vendor_source.lua"))}
    if platform == "ios" then
        local archive = path.absolute(toolchain.targetfile, root); assert(os.isfile(archive), archive)
        record.scope = "iOS standard-module Metal archive compilation only; no app boot or GPU acceptance"
        record.device = device; record.architecture = "arm64"; record.sdk = sdk; record.archive = archive; record.archive_sha256 = C.digest(archive)
    elseif platform == "web" then
        assert(toolchain.plat == "wasm" and toolchain.arch == "wasm32" and toolchain.linker_version:find("Emscripten", 1, true), "Wrong Web toolchain")
        local js = path.absolute(toolchain.targetfile, root)
        C.copy(js, path.join(package, "dora-godot.js")); C.copy(path.join(path.directory(js), path.basename(js) .. ".wasm"), path.join(package, "dora-godot.wasm"))
        for _, name in ipairs({"LICENSE.txt", "COPYRIGHT.txt", "AUTHORS.md"}) do C.copy(path.join(source, name), path.join(package, name)) end
        for _, name in ipairs({"runtime_bridge", "shared_gl"}) do C.copy(path.join(os.scriptdir(), "web", name .. ".js"), path.join(package, name .. ".mjs")) end
        record.scope = "Web standard-module LibGodot compilation only; no browser runtime or shared GPU output acceptance"
        record.optimization = mode == "release" and "speed" or "none"; record.emscripten = toolchain.linker_version:match("^[^\n]+")
        record.licenses = {"LICENSE.txt", "COPYRIGHT.txt", "AUTHORS.md"}; record.profiling_functions = os.getenv("DORA_GODOT_WEB_PROFILE_FUNCTIONS") == "1"
        local deployed = {build_target = target, graphics_backend = backend, licenses = record.licenses, toolchain = {arch = "wasm32"}}
        M.seal(package, deployed); C.save(path.join(package, "manifest.json"), deployed)
        record.vendored_sources_sha256 = {}
        for _, file in ipairs(table.join({path.join(source, "platform/web/SCsub"), path.join(source, "platform/web/detect.py"), path.join(source, "platform/web/audio_driver_web.cpp")}, os.files(path.join(source, "modules/dora_bridge/**.cpp")), os.files(path.join(source, "modules/dora_bridge/**.h")), os.files(path.join(source, "modules/dora_bridge/**.inc")))) do record.vendored_sources_sha256[C.relative(file, source)] = C.digest(file) end
        for _, key in ipairs({"package_format", "package_version", "godot_version", "bridge_abi", "artifacts"}) do record[key] = deployed[key] end
    else
        local output = path.join(root, "build/godot-xmake", platform, platform == "android" and abi or arch)
        if platform == "windows" then output = path.join(output, backend) end
        if mode == "debug" then output = path.join(output, "debug") end
        local library
        if platform == "windows" then
            local found = os.files(path.join(output, "lib/*dora_godot.dll")); assert(#found == 1, "Expected one xmake runtime DLL"); library = found[1]
        else library = path.join(output, "lib/libgodot_android.so") end
        import("package_runtime", {rootdir = os.scriptdir()}).package_runtime({source = source, library = library, output = package,
            ["library-name"] = platform == "android" and "libgodot_android.so" or nil,
            architecture = {arch}, ["build-target"] = target, ["graphics-backend"] = backend})
        record.runtime_sha256 = C.digest(library)
        if platform == "android" then
            local jni = path.join(package, "jni", abi)
            C.copy(library, path.join(jni, "libgodot_android.so"))
            local triple = ({arm64 = "aarch64-linux-android", arm32 = "arm-linux-androideabi", x86_64 = "x86_64-linux-android"})[arch]
            local stl = os.files(path.join(ndk, "toolchains/llvm/prebuilt/*/sysroot/usr/lib", triple, "libc++_shared.so"))
            assert(#stl == 1, "Expected one Android shared C++ runtime"); C.copy(stl[1], path.join(jni, "libc++_shared.so"))
            local metadata = C.load(path.join(package, "manifest.json"))
            metadata.builder = "xmake"; metadata.android_abi = abi; metadata.minimum_api = 28; metadata.ndk_revision = "29.0.14206865"
            for _, name in ipairs({"NOTICE", "NOTICE.toolchain"}) do C.copy(path.join(ndk, name), path.join(package, "ANDROID-NDK-" .. name)); table.insert(metadata.licenses, "ANDROID-NDK-" .. name) end
            C.save(path.join(package, "manifest.json"), M.seal(package, metadata))
            record.android_abi = abi; record.ndk_revision = metadata.ndk_revision; record.minimum_api = 28
            record.scope = "Android standard-module runtime cross-compilation only; no engine boot, Dora node or APK GPU acceptance"
        else
            record.compiled = true; record.target = "Windows " .. arch; record.godot_target = target; record.xmake = xmake; record.gpu_tested = false
            record.scope = "Windows compilation only; no GPU acceptance"
        end
    end
    if platform ~= "ios" then import("verify_package", {rootdir = os.scriptdir()}).verify(package) end
    C.save(path.join(builddir, "compilation.json"), record)
    return record
end

function cli(platform, ...)
    local C = import("common", {rootdir = os.scriptdir()})
    local definitions = {jobs = "value", target = "value", builder = "value", xmake = "value", ["build-dir"] = "value"}
    local extra = ({windows = {"arch", "backend", "mesa-libs", "xmake-sdk", "xmake-cross"}, android = {"sdk", "arch"}, ios = {"device"}, web = {}})[platform]
    for _, name in ipairs(extra) do definitions[name] = "value" end
    local args = C.args({...}, definitions)
    assert(#args.positional == 0, "Unexpected positional arguments")
    import("core.base.json"); print(C.serialize(build(platform, args)))
end
