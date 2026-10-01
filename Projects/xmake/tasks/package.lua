local function package_macos(mode, api)
    local ensure = api.ensure
    local cprint = api.cprint
    local os = api.os
    local path = api.path
    ensure(os.host() == "macosx", "macOS universal packaging requires a macOS host")

    local projectdir = os.projectdir()
    local xmake = os.programfile()
    local apps = {}
    for _, arch in ipairs({"arm64", "x86_64"}) do
        cprint("${bright}building macOS %s %s with xmake${clear}", arch, mode)
        os.vrunv(xmake, {"f", "-y", "-p", "macosx", "-a", arch, "-m", mode}, {
            curdir = projectdir
        })
        os.vrunv(xmake, {"build", "Dora"}, {curdir = projectdir})
        local app = path.join(projectdir, "build/macosx", arch, mode, "Dora.app")
        ensure(os.isdir(app), "missing xmake macOS output: " .. app)
        apps[arch] = app
    end

    local package_dir = path.join(projectdir, "build/package/macosx", mode)
    local universal_app = path.join(package_dir, "Dora.app")
    os.rm(package_dir)
    os.mkdir(package_dir)
    os.vrunv("ditto", {apps.arm64, universal_app})

    local relative_binary = "Contents/MacOS/Dora"
    local arm64_binary = path.join(apps.arm64, relative_binary)
    local x86_64_binary = path.join(apps.x86_64, relative_binary)
    local universal_binary = path.join(universal_app, relative_binary)
    os.vrunv("lipo", {
        "-create", arm64_binary, x86_64_binary, "-output", universal_binary
    })

    -- Replacing the executable invalidates the copied thin bundle signature.
    -- Ad-hoc signing keeps local/CI verification deterministic; distribution
    -- signing and notarization remain a separate release gate.
    os.vrunv("codesign", {"--force", "--deep", "--sign", "-", universal_app})
    os.vrunv("codesign", {"--verify", "--deep", "--strict", "--verbose=2", universal_app})
    os.vrunv("lipo", {"-info", universal_binary})

    local zip = path.join(package_dir, "dora-ssr-macos-universal.zip")
    os.vrunv("ditto", {"-c", "-k", "--sequesterRsrc", "--keepParent", universal_app, zip})
    ensure(os.isfile(zip), "macOS packaging completed without the expected zip: " .. zip)
    cprint("${green}macOS universal app: %s${clear}", universal_app)
    cprint("${green}macOS universal package: %s${clear}", zip)
end

local function package_linux(mode, arch, api)
    local ensure = api.ensure
    local cprint = api.cprint
    local find_tool = api.find_tool
    local os = api.os
    local path = api.path
    ensure(os.host() == "linux", "Linux AppImage packaging requires a Linux host")
    ensure(arch == "x86_64" or arch == "arm64",
        "Linux AppImage architecture must be x86_64 or arm64")

    for _, name in ipairs({"curl", "patchelf"}) do
        ensure(find_tool(name), "Linux AppImage packaging requires " .. name)
    end
    -- Distro lddtree uses /usr/bin/env python3 and distro pyelftools. A
    -- hosted SDK Python ahead of /usr/bin cannot import that system module.
    local lddtree_envs = {PATH = "/usr/bin:/bin:" .. os.getenv("PATH")}
    local lddtree = ensure(find_tool("lddtree", {envs = lddtree_envs, force = true}),
        "Linux AppImage packaging requires lddtree (pax-utils and system pyelftools)")

    local projectdir = os.projectdir()
    local xmake = os.programfile()
    local config_args = {"f", "-y", "-p", "linux", "-a", arch, "-m", mode}
    local host_arch = os.arch()
    if host_arch ~= arch and not (host_arch == "aarch64" and arch == "arm64") then
        table.insert(config_args, "--cross=" .. (arch == "x86_64"
            and "x86_64-linux-gnu-" or "aarch64-linux-gnu-"))
    end
    cprint("${bright}building Linux %s %s with xmake${clear}", arch, mode)
    os.vrunv(xmake, config_args, {curdir = projectdir})
    os.vrunv(xmake, {"build", "Dora"}, {curdir = projectdir})

    local binary = path.join(projectdir, "build/linux", arch, mode, "Dora")
    ensure(os.isfile(binary), "missing xmake Linux output: " .. binary)
    ensure(os.isfile(path.join(projectdir, "Assets/www/index.html")),
        "missing Web IDE assets: build Tools/dora-dora first")

    local package_dir = path.join(projectdir, "build/package/linux", arch, mode)
    local appdir = path.join(package_dir, "AppDir")
    os.rm(package_dir)
    os.mkdir(path.join(appdir, "usr/bin"))
    os.mkdir(path.join(appdir, "usr/lib"))
    os.mkdir(path.join(appdir, "usr/share/dora-ssr"))

    local staged_binary = path.join(appdir, "usr/bin/dora-ssr")
    os.cp(binary, staged_binary)
    os.cp(path.join(projectdir, "Assets"), path.join(appdir, "usr/share/dora-ssr"))
    local wa_mod = path.join(projectdir, "Tools/dora-wa/wa.mod")
    if os.isfile(wa_mod) then
        local wa_assets = path.join(appdir, "usr/share/dora-ssr/Assets/dora-wa")
        os.mkdir(wa_assets)
        os.cp(wa_mod, wa_assets)
        local wa_vendor = path.join(projectdir, "Tools/dora-wa/vendor")
        if os.isdir(wa_vendor) then
            os.cp(wa_vendor, wa_assets)
        end
    end

    local dependencies = os.iorunv(lddtree.program, {"-l", staged_binary}, {envs = lddtree_envs})
    for dependency in dependencies:gmatch("[^\r\n]+") do
        local name = path.filename(dependency)
        local system_runtime = name:find("^ld%-linux")
            or name:find("^libc%.so") or name:find("^libm%.so")
            or name:find("^libpthread") or name:find("^librt%.so")
            or name:find("^libdl%.so") or name:find("^libresolv%.so")
            or name:find("^libutil%.so") or name:find("^libnss_")
        local graphics_runtime = name:find("^libGL") or name:find("^libEGL")
            or name:find("^libdrm") or name:find("^libgbm")
            or name:find("^libvulkan")
        if dependency ~= staged_binary and not dependency:find("^linux%-vdso")
            and not system_runtime and not graphics_runtime then
            ensure(os.isfile(dependency), "unresolved runtime dependency: " .. dependency)
            os.cp(dependency, path.join(appdir, "usr/lib", name), {symlink = false})
        end
    end
    os.vrunv("patchelf", {"--set-rpath", "$ORIGIN/../lib", staged_binary})

    os.cp(path.join(projectdir, "Projects/packaging/appimage/AppRun"), appdir)
    os.cp(path.join(projectdir, "Projects/packaging/appimage/dora-ssr.desktop"), appdir)
    os.cp(path.join(projectdir, "Assets/Image/logo.png"),
        path.join(appdir, "dora-ssr.png"))
    os.vrunv("chmod", {"+x", path.join(appdir, "AppRun"), staged_binary})
    -- Shared folders can preserve owner-only modes on copied assets. The
    -- distributed AppDir must remain readable by a different local user.
    os.vrunv("chmod", {"-R", "a+rX", appdir})

    local target_tool_arch = arch == "arm64" and "aarch64" or "x86_64"
    local host_tool_arch
    if host_arch == "aarch64" or host_arch == "arm64" then
        host_tool_arch = "aarch64"
    elseif host_arch == "x86_64" then
        host_tool_arch = "x86_64"
    else
        ensure(false, "unsupported Linux packaging host architecture: " .. host_arch)
    end
    local tool_cache_dir = path.join(projectdir, "build/tools")
    local appimagetool = path.join(tool_cache_dir,
        "appimagetool-" .. host_tool_arch .. ".AppImage")
    if not os.isfile(appimagetool) then
        os.mkdir(tool_cache_dir)
        local download = appimagetool .. ".download"
        os.rm(download)
        os.vrunv("curl", {
            "--fail", "--location", "--silent", "--show-error",
            "--retry", "4", "--retry-all-errors", "--retry-delay", "2",
            "-o", download,
            "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-"
                .. host_tool_arch .. ".AppImage"
        })
        os.mv(download, appimagetool)
    end
    os.vrunv("chmod", {"a+rx", appimagetool})
    local output = path.join(package_dir,
        "dora-ssr-linux-" .. target_tool_arch .. ".AppImage")
    os.vrunv(appimagetool, {"--appimage-extract-and-run", appdir, output}, {
        envs = {ARCH = target_tool_arch}
    })
    os.vrunv("chmod", {"+x", output})
    ensure(os.isfile(output), "AppImage packaging completed without the expected output")
    cprint("${green}Linux AppImage: %s${clear}", output)
end

local function package_windows(mode, api)
    local ensure = api.ensure
    local cprint = api.cprint
    local find_tool = api.find_tool
    local os = api.os
    local path = api.path
    ensure(os.host() == "windows", "Windows ZIP packaging requires a Windows host")
    local seven_zip = find_tool("7z") or find_tool("7za")
    ensure(seven_zip, "Windows ZIP packaging requires 7-Zip")

    local projectdir = os.projectdir()
    local xmake = os.programfile()
    cprint("${bright}building Windows x86 %s with xmake${clear}", mode)
    os.vrunv(xmake, {"f", "-y", "-p", "windows", "-a", "x86", "-m", mode}, {
        curdir = projectdir
    })
    os.vrunv(xmake, {"build", "Dora"}, {curdir = projectdir})

    local targetdir = path.join(projectdir, "build/windows/x86", mode)
    local assets = path.join(projectdir, "Assets")
    local package_dir = path.join(projectdir, "build/package/windows/x86", mode)
    local stage = path.join(package_dir, "stage")
    local output = path.join(package_dir, "dora-ssr-windows-x86.zip")
    for _, name in ipairs({"Dora.exe", "wa.dll"}) do
        ensure(os.isfile(path.join(targetdir, name)), "missing Windows output: " .. name)
    end
    ensure(os.isfile(path.join(assets, "www/web-player/runtime.json")),
        "missing Web Player runtime: build Tools/dora-dora first")

    os.rm(package_dir)
    os.mkdir(stage)
    for _, name in ipairs({"Dora.exe", "wa.dll"}) do
        os.cp(path.join(targetdir, name), path.join(stage, name))
    end
    for _, name in ipairs({
        "www", "dora-wa", "Audio", "Doc", "Font", "Image",
        "gamecontrollerdb.txt", "LICENSES", "Script"
    }) do
        local source = path.join(assets, name)
        ensure(os.exists(source), "missing Windows package asset: " .. name)
        os.cp(source, path.join(stage, name))
    end
    local shader = "Shader/Love/varying.def.sc"
    ensure(os.isfile(path.join(assets, shader)), "missing Love shader varying definition")
    os.mkdir(path.join(stage, "Shader/Love"))
    os.cp(path.join(assets, shader), path.join(stage, shader))

    local wa_mod = path.join(projectdir, "Tools/dora-wa/wa.mod")
    local wa_vendor = path.join(projectdir, "Tools/dora-wa/vendor")
    ensure(os.isfile(wa_mod) and os.isdir(wa_vendor),
        "missing dora-wa module or vendor assets")
    os.cp(wa_mod, path.join(stage, "dora-wa/wa.mod"))
    os.cp(wa_vendor, path.join(stage, "dora-wa/vendor"))

    os.vrunv(seven_zip.program, {
        "a", "-tzip", "-xr!.DS_Store", "-xr!._*", output, "."
    }, {curdir = stage})
    ensure(os.isfile(output), "Windows packaging completed without the expected ZIP")
    cprint("${green}Windows ZIP: %s${clear}", output)
end

task("dora-package")
    set_category("plugin")
    set_menu {
        usage = "xmake dora-package --platform=android|ios|web|linux|macosx|windows [--mode=debug|release]",
        description = "Build and package Dora through the platform-native packager",
        options = {
            {nil, "platform", "kv", nil, "Package platform: android, ios, web, linux, macosx or windows"},
            {nil, "arch", "kv", nil, "Target architecture (iOS: arm64 or simulator x86_64; Linux: arm64 or x86_64)"},
            {nil, "mode", "kv", "debug", "Build mode: debug or release"},
            {nil, "format", "kv", nil, "Package format: Android apk/aab, iOS zip/ipa"},
            {nil, "appledev", "kv", "simulator", "iOS SDK: simulator or device"},
            {nil, "profile", "kv", nil, "Web profile: core, dora-preset or custom"},
            {nil, "pthreads", "k", nil, "Enable the pthread Web profile"}
        }
    }
    on_run(function ()
        import("core.base.option")
        import("lib.detect.find_tool")

        local platform = option.get("platform")
        local mode = option.get("mode") or "debug"
        assert(mode == "debug" or mode == "release", "--mode must be debug or release")
        if platform == "web" or platform == "wasm" then
            local args = {"dora-web", "--mode=" .. mode}
            if option.get("profile") then table.insert(args, "--profile=" .. option.get("profile")) end
            if option.get("pthreads") then table.insert(args, "--pthreads") end
            os.vrunv(os.programfile(), args, {curdir = os.projectdir()})
            return
        end
        if platform == "iphoneos" or platform == "ios" then
            import("Projects.xmake.tasks.ios_package", {rootdir = os.projectdir(), anonymous = true})({
                mode = mode, arch = option.get("arch"), appledev = option.get("appledev"), format = option.get("format")
            })
            return
        end
        local format = option.get("format") or "apk"
        assert(platform == "android" or platform == "linux" or platform == "macosx"
            or platform == "windows",
            "dora-package supports android, linux, macosx and windows")
        assert(mode == "debug" or mode == "release", "--mode must be debug or release")
        assert(format == "apk" or (platform == "android" and mode == "release" and format == "aab"),
            "--format=aab is supported for Android release only")

        if platform == "macosx" then
            package_macos(mode, {
                ensure = assert,
                cprint = cprint,
                os = os,
                path = path
            })
            return
        end

        if platform == "linux" then
            package_linux(mode, option.get("arch") or os.arch(), {
                ensure = assert,
                cprint = cprint,
                find_tool = find_tool,
                os = os,
                path = path
            })
            return
        end


        if platform == "windows" then
            package_windows(mode, {
                ensure = assert,
                cprint = cprint,
                find_tool = find_tool,
                os = os,
                path = path
            })
            return
        end

        local sdk = os.getenv("ANDROID_HOME") or os.getenv("ANDROID_SDK_ROOT")
        if not sdk and os.host() == "macosx" then
            sdk = path.join(os.getenv("HOME"), "Library/Android/sdk")
        end
        assert(sdk and os.isdir(sdk), "Android SDK not found; set ANDROID_HOME")

        -- Gradle consumes the xmake-generated CMake graph and owns NDK
        -- compilation, ABI outputs and packaging. Its preparation task also
        -- builds the Wa AAR; do not prebuild/stage a second C++ engine here.
        local gradle_root = path.join(os.projectdir(), "Projects/Android/Dora")

        local java_home = os.getenv("JAVA_HOME")
        if os.host() == "macosx" then
            local bundled = "/Applications/Android Studio.app/Contents/jbr/Contents/Home"
            if os.isfile(path.join(bundled, "bin/java")) then
                java_home = bundled
            end
        end
        assert(java_home and os.isfile(path.join(java_home, "bin/java")),
            "Gradle requires JDK 17-20; set JAVA_HOME or install Android Studio")

        local gradlew = path.join(gradle_root, os.host() == "windows" and "gradlew.bat" or "gradlew")
        local gradle_task = format == "aab" and "bundleRelease"
            or (mode == "debug" and "assembleDebug" or "assembleRelease")
        local gradle_args = {gradle_task}
        local signing = {
            store = os.getenv("DORA_ANDROID_SIGNING_STORE_FILE"),
            store_password = os.getenv("DORA_ANDROID_SIGNING_STORE_PASSWORD"),
            alias = os.getenv("DORA_ANDROID_SIGNING_KEY_ALIAS"),
            key_password = os.getenv("DORA_ANDROID_SIGNING_KEY_PASSWORD")
        }
        local any_signing = signing.store or signing.store_password or signing.alias or signing.key_password
        if any_signing then
            assert(mode == "release" and signing.store and signing.store_password
                and signing.alias and signing.key_password and os.isfile(signing.store),
                "Android release signing requires all four DORA_ANDROID_SIGNING_* values and a keystore file")
            table.insert(gradle_args, "-Pandroid.injected.signing.store.file=" .. signing.store)
            table.insert(gradle_args, "-Pandroid.injected.signing.store.password=" .. signing.store_password)
            table.insert(gradle_args, "-Pandroid.injected.signing.key.alias=" .. signing.alias)
            table.insert(gradle_args, "-Pandroid.injected.signing.key.password=" .. signing.key_password)
        end
        cprint("${bright}packaging Android %s %s with Gradle${clear}", mode, format:upper())
        os.vrunv(gradlew, gradle_args, {
            curdir = gradle_root,
            envs = {
                JAVA_HOME = java_home,
                ANDROID_HOME = sdk,
                PATH = path.join(java_home, "bin")
                    .. (os.host() == "windows" and ";" or ":") .. os.getenv("PATH")
            }
        })

        local artifact = format == "aab"
            and path.join(gradle_root, "app/build/outputs/bundle/release/app-release.aab")
            or path.join(gradle_root, "app/build/outputs/apk", mode,
                mode == "debug" and "app-debug.apk"
                    or (any_signing and "app-release.apk" or "app-release-unsigned.apk"))
        assert(os.isfile(artifact), "Gradle completed without the expected Android artifact: " .. artifact)
        cprint("${green}Android package: %s${clear}", artifact)
    end)
task_end()
