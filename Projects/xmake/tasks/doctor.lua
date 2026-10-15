task("doctor")
    set_category("plugin")
    on_run(function ()
        import("core.base.option")
        import("core.project.project")
        import("lib.detect.find_tool")

        local requested = option.get("platform") or "host"
        local host = os.host()
        local failures = 0
        local warnings = 0

        local function first_line(value)
            if not value or value == "" then
                return nil
            end
            return value:match("([^\r\n]+)")
        end

        local function probe_version(program, argv, envs)
            local output = try {function ()
                local stdout, stderr = os.iorunv(program, argv or {"--version"}, {envs = envs})
                return stdout ~= "" and stdout or stderr
            end}
            return first_line(output)
        end

        local function report(level, name, detail, hint)
            local color = level == "OK" and "green" or (level == "WARN" and "yellow" or "red")
            cprint("${%s}%s${clear} %-20s %s", color, level, name, detail or "")
            if hint then
                cprint("      ${dim}%s${clear}", hint)
            end
            if level == "ERROR" then
                failures = failures + 1
            elseif level == "WARN" then
                warnings = warnings + 1
            end
        end

        local function tool(name, hint, opts)
            opts = opts or {}
            local found = opts.program and os.isfile(opts.program) and {program = opts.program} or find_tool(opts.program or name, {
                force = true,
                check = function () return true end,
                envs = opts.envs
            })
            if not found then
                report(opts.optional and "WARN" or "ERROR", name, "not found", hint)
                return nil
            end
            local version = probe_version(found.program, opts.argv, opts.envs)
            report("OK", opts.label or name, found.program .. (version and (" | " .. version) or ""))
            return found.program
        end

        local function java_tool(preferred)
            local program = tool("java", "Install JDK 17-20 or use Android Studio's bundled JBR.", {program = preferred, argv = {"-version"}})
            if not program then
                return
            end
            local output = try {function ()
                local stdout, stderr = os.iorunv(program, {"-version"})
                return stdout ~= "" and stdout or stderr
            end}
            local major = output and output:match('version "(%d+)')
            if major and (tonumber(major) < 17 or tonumber(major) > 20) then
                report("WARN", "Gradle JDK", "Java " .. major .. " is outside the supported 17-20 range",
                    "Use Android Studio's bundled JBR or set JAVA_HOME to JDK 17.")
            end
        end

        local function environment(name, values, hint)
            for _, key in ipairs(values) do
                local value = os.getenv(key)
                if value and value ~= "" then
                    report("OK", name, key .. "=" .. value)
                    return value
                end
            end
            report("WARN", name, "not set", hint)
        end

        local function applies(platform)
            return requested == "all" or requested == platform or
                (requested == "host" and platform == host)
        end

        cprint("${bright}Dora-SSR build doctor${clear}")
        cprint("  requested platform: %s", requested)
        cprint("  host: %s/%s", host, os.arch())

        local xmake = tool("xmake", "Install the latest stable xmake release.", {program = os.programfile()})
        local host_target = project.target("dora-host-tools")
        local managed_envs = host_target and host_target:pkgenvs() or nil
        if managed_envs and applies("wasm") then
            local python = find_tool(os.host() == "windows" and "python" or "python3", {
                force = true,
                check = function () return true end
            })
            if python then
                managed_envs.EMSDK_PYTHON = python.program
            end
            managed_envs.PATH = managed_envs.PATH and
                (managed_envs.PATH .. path.envsep() .. os.getenv("PATH")) or os.getenv("PATH")
        end
        tool("go", "The dora_go host package should have been installed during configure.",
            {label = "Go (xmake)", argv = {"version"}, envs = managed_envs})
        tool("cargo", "The dora_rust host package should have been installed during configure.",
            {label = "Cargo (xmake)", envs = managed_envs})
        tool("rustc", "The dora_rust host package should have been installed during configure.",
            {label = "Rust (xmake)", envs = managed_envs})
        tool("rustup", "The dora_rustup host package should have been installed during configure.",
            {label = "rustup (xmake)", envs = managed_envs})
        if xmake then
            report("OK", "xmake policy", "latest stable; detected version is recorded above")
        end

        if applies("macosx") or applies("iphoneos") then
            tool("xcodebuild", "Install Xcode and select it with xcode-select.", {argv = {"-version"}})
            tool("xcrun", "Install Xcode command-line tools.", {argv = {"--version"}})
            tool("lipo", "Install Xcode command-line tools.", {argv = {"-version"}})
            if applies("iphoneos") then
                local sdk = find_tool("xcrun", {force = true, check = function () return true end})
                if sdk then
                    local path = try {function ()
                        return os.iorunv(sdk.program, {"--sdk", "iphonesimulator", "--show-sdk-path"})
                    end}
                    if path then
                        report("OK", "iOS simulator SDK", first_line(path))
                    else
                        report("ERROR", "iOS simulator SDK", "not available", "Install an iOS simulator runtime from Xcode.")
                    end
                end
            end
        end

        if applies("linux") then
            tool("cc", "Install the distribution C compiler.")
            tool("c++", "Install the distribution C++ compiler.")
            tool("pkg-config", "Install pkg-config and the native development packages listed by the Linux CI job.")
        end

        if applies("windows") then
            local vsenvs
            if host == "windows" then
                import("core.tool.toolchain")
                local msvc = toolchain.load("msvc", {plat = "windows", arch = "x86"})
                if msvc and msvc:check() then vsenvs = msvc:runenvs() end
                local emulated = os.arch() ~= "arm64" and (os.getenv("PROCESSOR_IDENTIFIER") or ""):find("ARM", 1, true)
                if emulated then
                    report("ERROR", "xmake host arch", os.arch(), "Install the official native ARM64 xmake distribution on Windows ARM64.")
                end
            end
            tool("cl", "Install Visual Studio Build Tools with the Desktop C++ workload.", {envs = vsenvs})
            tool("msbuild", "MSBuild is optional for opening/building generated Visual Studio projects.", {optional = true, envs = vsenvs})
            local gcc = os.getenv("CC") or (find_tool("i686-w64-mingw32-gcc", {force = true}) or {}).program
            gcc = tool("gcc", "Install 32-bit MinGW GCC for Wa cgo, or set CC.", {program = gcc})
            if gcc then
                local triple = try {function () return first_line(os.iorunv(gcc, {"-dumpmachine"})) end}
                report(triple and triple:find("i686", 1, true) and "OK" or "ERROR", "Wa cgo target", triple or "unknown",
                    not (triple and triple:find("i686", 1, true)) and "CC must select a 32-bit MinGW compiler." or nil)
            end
        end

        if applies("android") then
            local java_home = os.getenv("JAVA_HOME")
            local bundled = "/Applications/Android Studio.app/Contents/jbr/Contents/Home"
            if host == "macosx" and os.isfile(path.join(bundled, "bin/java")) then java_home = bundled end
            java_tool(java_home and path.join(java_home, "bin", host == "windows" and "java.exe" or "java"))
            tool("adb", "Install Android SDK platform-tools.", {optional = true})
            local sdk = os.getenv("ANDROID_HOME") or os.getenv("ANDROID_SDK_ROOT")
            if not sdk and host == "macosx" then sdk = path.join(os.getenv("HOME"), "Library/Android/sdk") end
            if not sdk and host == "windows" and os.getenv("LOCALAPPDATA") then
                sdk = path.join(os.getenv("LOCALAPPDATA"), "Android/Sdk")
            end
            if sdk and os.isdir(sdk) then
                report("OK", "Android SDK", sdk)
                for _, component in ipairs({"ndk/26.1.10909125", "cmake/3.22.1", "platforms/android-34", "build-tools/34.0.0"}) do
                    local directory = path.join(sdk, component)
                    report(os.isdir(directory) and "OK" or "ERROR", component, directory,
                        not os.isdir(directory) and "Install this component through Android Studio's SDK Manager." or nil)
                end
            else
                report("ERROR", "Android SDK", "not found", "Set ANDROID_HOME or configure Android Studio's SDK.")
            end
            local wrapper = path.join(os.projectdir(), "Projects/Android/Dora", host == "windows" and "gradlew.bat" or "gradlew")
            report(os.isfile(wrapper) and "OK" or "ERROR", "Gradle wrapper", wrapper)
        end

        if applies("wasm") then
            tool("emcc", "Configure with -p wasm so xmake can resolve its managed Emscripten package.",
                {label = "Emscripten (xmake)", envs = managed_envs})
            tool("node", "Install Node.js for the retained browser and package checks.")
        end

        cprint("\n${bright}Summary:${clear} %d error(s), %d warning(s)", failures, warnings)
        if failures > 0 then
            raise("build environment is incomplete for '%s'", requested)
        end
    end)
    set_menu {
        usage = "xmake doctor [options]",
        description = "Diagnose Dora-SSR build tools and platform SDKs.",
        options = {
            {nil, "platform", "kv", "host", "Platform to check: host, all, macosx, iphoneos, linux, windows, android, wasm"}
        }
    }
task_end()
