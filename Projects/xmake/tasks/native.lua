local function settings(option, api)
    local os, assert = api.os, api.ensure
    local platform = option.get("platform") or os.host()
    if platform == "macos" then platform = "macosx" end
    if platform == "ios" then platform = "iphoneos" end
    assert(platform == "macosx" or platform == "linux" or platform == "windows" or platform == "iphoneos", "unsupported native platform")
    local arch = option.get("arch") or (platform == "windows" and "x86" or os.arch())
    if arch == "aarch64" then arch = "arm64" end
    local mode = option.get("mode") or "debug"
    assert(mode == "debug" or mode == "release", "mode must be debug or release")
    return platform, arch, mode
end

local function configure(platform, arch, mode, envs, appledev, api, tests)
    local os = api.os
    if os.host() == "windows" and os.arch() ~= "arm64"
        and (os.getenv("PROCESSOR_IDENTIFIER") or ""):find("ARM", 1, true) then
        api.ensure(false, "Windows ARM64 requires native ARM64 xmake; install the official ARM64 distribution instead of emulated x64 xmake")
    end
    local args = {"f", "-y", "-p", platform, "-a", arch, "-m", mode, "--ccache=n"}
    table.insert(args, "--dora_native_tests=" .. (tests and "y" or "n"))
    table.insert(args, "--dora_test_repo=" .. (tests and tests.directory or ""))
    if platform == "iphoneos" then table.insert(args, "--appledev=" .. (appledev or "simulator")) end
    os.execv(os.programfile(), args, {curdir = os.projectdir(), envs = envs})
end

for _, name in ipairs({"dora-build", "dora-run"}) do
    task(name)
        set_category("plugin")
        set_menu {
            usage = "xmake " .. name .. " [--platform=macosx|linux|windows] [--mode=debug|release]",
            description = "Build the native engine from the single xmake graph" .. (name == "dora-run" and " and launch it" or ""),
            options = {{nil, "platform", "kv", nil, "Native platform"}, {nil, "arch", "kv", nil, "Target architecture"},
                {nil, "mode", "kv", "debug", "debug or release"}, {nil, "jobs", "kv", "6", "Compilation jobs"},
                {nil, "appledev", "kv", "simulator", "iOS SDK"}, {nil, "tests", "k", nil, "Include external native tests"},
                {nil, "arguments", "vs", nil, "Engine arguments (after --)"}}
        }
        local run = name == "dora-run"
        on_run(function ()
            import("core.base.option")
            local api = {os = os, ensure = assert}
            local platform, arch, mode = settings(option, api)
            assert(not run or platform == os.host(), "run requires the host platform")
            local jobs = tonumber(option.get("jobs"))
            assert(jobs and jobs > 0 and jobs == math.floor(jobs), "jobs must be a positive integer")
            local root = os.projectdir()
            local sdk = platform == "iphoneos" and option.get("appledev") or "native"
            local envs = {XMAKE_CONFIGDIR = path.join(root, "build/native-config", platform, sdk, arch, mode)}
            local tests = option.get("tests") and import("Projects.xmake.testing.repository", {rootdir = root, anonymous = true})()
            configure(platform, arch, mode, envs, option.get("appledev"), api, tests)
            os.execv(os.programfile(), {"build", "-j", tostring(jobs), "Dora"}, {curdir = root, envs = envs})
            if run then
                local binary = path.join(root, "build", platform, arch, mode, platform == "windows" and "Dora.exe" or "Dora")
                if platform == "macosx" then binary = path.join(root, "build/macosx", arch, mode, "Dora.app/Contents/MacOS/Dora") end
                assert(os.isfile(binary), "missing engine executable: " .. binary)
                os.execv(binary, table.join({"--asset", path.join(root, "Assets")}, option.get("arguments") or {}), {curdir = root})
            end
        end)
    task_end()
end

task("dora-ide")
    set_category("plugin")
    set_menu {
        usage = "xmake dora-ide [--platform=macosx|iphoneos|windows|linux] [--kind=xcode|vsxmake|compile_commands]",
        description = "Generate disposable IDE projects under build/ide",
        options = {{nil, "platform", "kv", nil, "Native platform"}, {nil, "arch", "kv", nil, "Target architecture"},
            {nil, "mode", "kv", "debug", "Initial mode"}, {nil, "kind", "kv", nil, "IDE generator"},
            {nil, "appledev", "kv", "simulator", "iOS SDK"}}
    }
    on_run(function ()
        import("core.base.option")
        local api = {os = os, ensure = assert}
        local platform, arch, mode = settings(option, api)
        local kind = option.get("kind") or ((platform == "macosx" or platform == "iphoneos") and "xcode" or platform == "windows" and "vsxmake" or "compile_commands")
        assert(kind == "xcode" or kind == "vsxmake" or kind == "compile_commands", "unsupported IDE generator")
        assert(kind ~= "xcode" or os.host() == "macosx", "Xcode generation requires macOS")
        assert(kind ~= "vsxmake" or os.host() == "windows", "VS generation requires Windows")
        local sdk = platform == "iphoneos" and option.get("appledev") or "native"
        local out = path.join(os.projectdir(), "build/ide", platform, sdk, arch)
        local envs = {XMAKE_IN_PROJECT_GENERATOR = "1"}
        configure(platform, arch, mode, envs, option.get("appledev"), api)
        os.execv(os.programfile(), {"project", "-k", kind, "-m", "debug,release", "-a", arch, out}, {curdir = os.projectdir(), envs = envs})
        if kind == "xcode" and platform == "iphoneos" then
            -- The generic generator does not model simulator appledev or
            -- the application rule's SDK-specific output directory.
            local file = path.join(out, "Dora-SSR.xcodeproj/project.pbxproj")
            local text = assert(io.readfile(file), "missing generated Xcode project")
            local appledev = option.get("appledev")
            assert(appledev == "simulator" or appledev == "device", "invalid iOS SDK")
            text = text:gsub("%-p %${PLATFORM_NAME}", "-p iphoneos --appledev=" .. appledev)
            text = text:gsub("SUPPORTED_PLATFORMS = \"macosx iphoneos\";", "SUPPORTED_PLATFORMS = \"" .. (appledev == "simulator" and "iphonesimulator" or "iphoneos") .. "\";")
            text = text:gsub("XMAKE_BUILD_DIR=%${BUILD_DIR}/%${PLATFORM_NAME}/%${NATIVE_ARCH}/%${CONFIGURATION}",
                "XMAKE_BUILD_DIR=\\\"" .. path.join(os.projectdir(), "build/iphoneos", appledev) .. "/${NATIVE_ARCH}/${CONFIGURATION}\\\"")
            io.writefile(file, text)
        elseif kind == "vsxmake" then
            -- A pushd of a UNC checkout creates a temporary drive letter.
            -- Do not bake that letter (or unquoted spaces) into IDE Run args.
            for _, file in ipairs(os.files(path.join(out, "**/Dora.vcxproj"))) do
                local text = assert(io.readfile(file), "missing generated Visual Studio project")
                text = text:gsub("<XmakeRunArgs>.-</XmakeRunArgs>",
                    '<XmakeRunArgs>--asset &quot;$(XmakeProjectDir)\\Assets&quot;</XmakeRunArgs>')
                io.writefile(file, text)
            end
        end
        cprint("${green}Generated IDE project: %s${clear}", out)
    end)
task_end()
