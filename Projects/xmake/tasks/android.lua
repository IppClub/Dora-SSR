task("dora-android-prepare")
    set_category("plugin")
    set_menu {
        usage = "xmake dora-android-prepare --sdk=ANDROID_SDK",
        description = "Prepare the xmake-managed Wa AAR and Android assets for Gradle",
        options = {{nil, "sdk", "kv", nil, "Android SDK directory"}}
    }
    on_run(function ()
        import("core.base.option")
        local sdk = option.get("sdk") or os.getenv("ANDROID_HOME") or os.getenv("ANDROID_SDK_ROOT")
        if not sdk and os.host() == "macosx" then
            sdk = path.join(os.getenv("HOME"), "Library/Android/sdk")
        end
        assert(sdk and os.isdir(sdk), "Android SDK not found; set ANDROID_HOME")
        local ndk = path.join(sdk, "ndk/26.1.10909125")
        assert(os.isdir(ndk), "Android NDK 26.1.10909125 not found: " .. ndk)
        local root = os.projectdir()
        local configdir = path.join(root, "build/android-gradle/wa")
        local envs = {XMAKE_CONFIGDIR = configdir, ANDROID_HOME = sdk}
        os.vrunv(os.programfile(), {
            "f", "-q", "-y", "-p", "android", "-a", "arm64-v8a", "-m", "release",
            "--ndk=" .. ndk, "--ndk_sdkver=28", "--builddir=" .. path.join(configdir, "build"), "--ccache=n"
        }, {curdir = root, envs = envs})
        os.vrunv(os.programfile(), {"build", "dora-wa-android"}, {curdir = root, envs = envs})
        local aar = path.join(root, "build/runtime/android/wa.aar")
        assert(os.isfile(aar), "missing xmake Android Wa AAR: " .. aar)
        local destination = path.join(root, "Projects/Android/Dora/app/build/xmake-aar")
        os.mkdir(destination)
        os.cp(aar, path.join(destination, "wa.aar"))
        local assets = path.join(root, "Assets/dora-wa")
        os.mkdir(assets)
        os.cp(path.join(root, "Tools/dora-wa/wa.mod"), path.join(assets, "wa.mod"))
        os.cp(path.join(root, "Tools/dora-wa/vendor"), assets)
    end)
task_end()
