local DORA_ROOT = os.projectdir()
local function rootpath(relative)
    return path.join(DORA_ROOT, relative)
end

local dora_includedirs = {
    rootpath("Source"),
    rootpath("Source/3rdParty"),
    rootpath("Source/3rdParty/SDL2/include"),
    rootpath("Source/3rdParty/Lua"),
    rootpath("Source/3rdParty/soloud"),
    rootpath("Source/3rdParty/Zip"),
    rootpath("Source/3rdParty/lodepng"),
    rootpath("Source/3rdParty/imgui"),
    rootpath("Source/3rdParty/implot"),
    rootpath("Source/3rdParty/font"),
    rootpath("Source/3rdParty/sqlite"),
    rootpath("Source/3rdParty/dragonBones"),
    rootpath("Source/3rdParty/wasm3"),
    rootpath("Source/3rdParty/Zip/zlib"),
    rootpath("Source/3rdParty/Effekseer"),
    rootpath("Source/3rdParty/theora/include"),
    rootpath("Source/3rdParty/Love/src"),
    rootpath("Source/3rdParty/Love/src/modules"),
    rootpath("Source/3rdParty/JoltPhysics"),
    rootpath("Source/3rdParty/bgfx/include"),
    rootpath("Source/3rdParty/bimg/include"),
    rootpath("Source/3rdParty/bx/include")
}

target("Dora")
    set_kind(is_plat("android") and "shared" or "binary")
    if is_plat("android") then
        set_basename("main")
    end
    -- IDE solutions must select the runnable engine for Build/Run; native
    -- CLI entrypoints still name Dora explicitly rather than build every tool.
    set_default(os.getenv("XMAKE_IN_PROJECT_GENERATOR") and true or false)
    -- The legacy CMake build kept compiler extensions enabled. GNU C11 is
    -- required by genuine C units such as the amalgamated Vorbis sources
    -- (alloca is a compiler extension there); it does not turn them into C++.
    set_languages("gnu11", "cxx20")
    add_deps("dora-lua-bindings", "SDL2", "love", "theoradec", "bgfx", "shaderc-lib")
    if is_plat("macosx", "linux", "windows", "iphoneos") then
        add_deps("dora-rust-runtime", "dora-wa-runtime")
    elseif is_plat("android") then
        add_deps("dora-rust-runtime")
    end
    add_includedirs(table.unpack(dora_includedirs))
    add_defines("WITH_SDL2_STATIC", "d_m3HasWASI", "SPDLOG_FMT_EXTERNAL")
    add_defines(has_config("dora_native_tests") and "DORA_TEST=1" or "DORA_TEST=0")

    on_load(function (target)
        import("core.project.config")
        if config.get("dora_native_tests") then
            local repo = assert(config.get("dora_test_repo"), "native tests require a resolved Dora-Example checkout")
            assert(os.isfile(path.join(repo, "Test/Native/HelloWorldCpp.cpp")), "external native test sources are missing")
            target:add("includedirs", path.join(repo, "Test"))
            target:add("files", path.join(repo, "Test/Native/HelloWorldCpp.cpp"))
        end
        local manifest = import("Projects.xmake.manifests.engine", {rootdir = os.projectdir(), anonymous = true})()
        for _, source in ipairs(manifest.sources) do
            local config
            if target:is_plat("windows") and source:endswith(".c") then
                -- Genuine C units stay in C mode; C++ code uses .cpp.
                config = {force = {cxflags = {"/TC"}}}
            end
            if source == "Source/Lua/LuaBinding.cpp" or source == "Source/Lua/LuaBindingWeb.cpp"
                or source == "Source/Lua/LuaCode.cpp" or source == "Source/Lua/LuaCodeWeb.cpp"
                or source == "Source/Lua/TealCompiler.cpp" then
                config = {always_added = true}
            end
            if target:is_plat("macosx") and source == "Source/3rdParty/nfd/nfd_portal.cpp" then
                target:add("files", rootpath("Source/3rdParty/nfd/nfd_cocoa.m"), {force = {mflags = {"-fno-objc-arc"}}})
            elseif target:is_plat("iphoneos", "android") and source == "Source/3rdParty/nfd/nfd_portal.cpp" then
                -- Mobile builds have no desktop file-dialog backend.
            elseif target:is_plat("windows") and source == "Source/3rdParty/nfd/nfd_portal.cpp" then
                target:add("files", rootpath("Source/3rdParty/nfd/nfd_win.cpp"))
            else
                if source == "Source/Physics/JoltBridge.cpp" or source == "Source/Physics/JoltSources.cpp" then
                    config = {force = {defines = {"JPH_NO_FORCE_INLINE"}}}
                    if not target:is_plat("windows") then
                        config.force.cxxflags = {"-fno-rtti", "-fno-exceptions", "-ffp-contract=off"}
                    end
                end
                target:add("files", rootpath(source), config)
            end
        end
        target:add("defines", is_mode("debug") and "BX_CONFIG_DEBUG=1" or "BX_CONFIG_DEBUG=0")
    end)

    if is_plat("macosx") then
        add_rules("xcode.application")
        set_values("xcode.bundle_identifier", "IppClub.DoraSSR")
        set_toolchains("xcode", {target_minver = "12.0"})
        add_files(rootpath("Projects/macOS/Dora/Info.plist"), rootpath("Projects/macOS/Dora/Assets.xcassets"))
        add_files(rootpath("Source/Basic/Application.mm"), rootpath("Source/Basic/Content.mm"))
        for _, resource in ipairs({"Audio", "Doc", "Font", "Image", "Script", "Shader", "dora-wa", "www"}) do
            add_installfiles(rootpath("Assets/" .. resource .. "/**"), {rootdir = rootpath("Assets")})
        end
        add_installfiles(rootpath("Assets/LICENSES"), rootpath("Assets/gamecontrollerdb.txt"), {
            rootdir = rootpath("Assets")
        })
        add_includedirs(rootpath("Source/3rdParty/bx/include/compat/osx"))
        add_defines("LUA_USE_MACOSX")
        local runtime_dir = rootpath(path.join(
            "build/runtime/macosx", get_config("arch"), get_config("mode")
        ))
        add_links(
            path.join(runtime_dir, "libwa.a"),
            path.join(runtime_dir, "libdora_runtime.a")
        )
        add_frameworks(
            "AudioToolbox", "AudioUnit", "Carbon", "Cocoa", "CoreAudio",
            "CoreFoundation", "CoreHaptics", "CoreVideo", "ForceFeedback",
            "GameController", "IOKit", "Metal", "QuartzCore", "Security"
        )
    elseif is_plat("iphoneos") then
        add_rules("mode.debug", "mode.release")
        -- Match the checked-in Xcode project's DWARF settings; the mode
        -- rules provide -O0 for Debug and size optimization/NDEBUG for iOS Release.
        set_symbols("debug")
        if is_mode("debug") then add_defines("DEBUG=1") end
        local signing_identity = get_config("dora_ios_sign_identity")
        if signing_identity and signing_identity ~= "-" then
            set_values("xcode.codesign_identity", signing_identity)
        end
        if get_config("dora_ios_provision") then
            set_values("xcode.mobile_provision", get_config("dora_ios_provision"))
        end
        local apple_device = get_config("appledev") == "simulator" and "simulator" or "device"
        set_targetdir(rootpath("build/iphoneos/" .. apple_device .. "/" ..
            get_config("arch") .. "/" .. get_config("mode")))
        -- xcode.info_plist/xcassets/storyboard use separate dependency and
        -- generated-file trees, not just object files. Switching SDKs must
        -- never reuse a rule cache pointed at the other bundle directory.
        set_objectdir(rootpath("build/.objs/iphoneos-" .. apple_device))
        set_dependir(rootpath("build/.deps/iphoneos-" .. apple_device))
        set_autogendir(rootpath("build/.gens/iphoneos-" .. apple_device))
        add_rules("xcode.application")
        set_values("xcode.bundle_identifier", "IppClub.DoraSSR")
        set_toolchains("xcode", {target_minver = "13.0"})
        add_files(
            rootpath("Projects/iOS/Dora/Info.plist"),
            rootpath("Projects/iOS/Dora/Assets.xcassets"),
            rootpath("Projects/iOS/Dora/Base.lproj/Launch Screen.storyboard"),
            rootpath("Projects/iOS/Dora/Base.lproj/Main.storyboard")
        )
        add_files(rootpath("Source/Basic/Application.mm"), rootpath("Source/Basic/Content.mm"))
        for _, resource in ipairs({"Audio", "Doc", "Font", "Image", "Script", "Shader", "dora-wa", "www"}) do
            add_installfiles(rootpath("Assets/" .. resource .. "/**"), {rootdir = rootpath("Assets")})
        end
        add_installfiles(rootpath("Assets/LICENSES"), rootpath("Assets/gamecontrollerdb.txt"), {
            rootdir = rootpath("Assets")
        })
        add_includedirs(rootpath("Source/3rdParty/bx/include/compat/ios"))
        add_defines("LUA_USE_IOS", "HAVE_GETHOSTUUID=0")
        add_cxflags(
            "-Wno-ambiguous-macro", "-Wno-unreachable-code",
            "-Wno-conditional-uninitialized", {force = true}
        )
        add_cxxflags("-Wno-missing-template-arg-list-after-template-kw", {force = true})
        local runtime_dir = rootpath("build/runtime/iphoneos/" .. apple_device .. "/" ..
            get_config("arch") .. "/" .. get_config("mode"))
        add_linkgroups(
            path.join(runtime_dir, "libwa.a"),
            path.join(runtime_dir, "libdora_runtime.a")
        )
        add_frameworks(
            "AudioToolbox", "AVFoundation", "CoreAudio", "CoreBluetooth",
            "CoreGraphics", "CoreHaptics", "CoreMotion", "Foundation",
            "GameController", "Metal", "QuartzCore", "Security", "UIKit"
        )
    elseif is_plat("linux") then
        -- xmake intentionally does not resolve system pkg-config packages
        -- while cross-compiling. Debian/Ubuntu multiarch keeps the DBus
        -- public and generated headers in these canonical locations, which
        -- also work for the corresponding native architecture.
        local multiarch = is_arch("x86_64")
            and "x86_64-linux-gnu" or "aarch64-linux-gnu"
        add_includedirs(
            "/usr/include/dbus-1.0",
            "/usr/lib/" .. multiarch .. "/dbus-1.0/include"
        )
        add_linkdirs("/usr/lib/" .. multiarch)
        add_includedirs(rootpath("Source/3rdParty/bx/include/compat/linux"))
        add_defines("LUA_USE_LINUX", "JPH_NO_FORCE_INLINE")
        local runtime_dir = rootpath(path.join(
            "build/runtime/linux", get_config("arch"), get_config("mode")
        ))
        add_links(
            path.join(runtime_dir, "libwa.a"),
            path.join(runtime_dir, "libdora_runtime.a")
        )
        add_syslinks("z", "EGL", "GLESv2", "X11", "dbus-1", "m", "dl", "pthread", "rt")
        add_cxxflags("-Wno-psabi", {tools = "gcc", force = true})
        set_runargs("--asset", rootpath("Assets"))
        set_rundir(DORA_ROOT)
    elseif is_plat("windows") then
        add_files(rootpath("Projects/Windows/Dora/Resource.rc"))
        add_includedirs(rootpath("Projects/Windows/Dora"))
        add_includedirs(rootpath("Source/3rdParty/bx/include/compat/msvc"))
        add_defines("LUA_USE_WINDOWS", "_CRT_SECURE_NO_WARNINGS", "NOMINMAX")
        if is_mode("debug") then
            set_runtimes("MTd")
            add_defines("_ITERATOR_DEBUG_LEVEL=0")
        else
            set_runtimes("MT")
        end
        -- Preserve the former Visual Studio settings. Several C translation
        -- units contain UTF-8 Chinese comments whose byte sequences are not
        -- safe under the machine's legacy code page.
        add_cxflags(
            "/utf-8", "/Zc:__cplusplus", "/Zc:preprocessor",
            "/wd4200", "/wd4244", "/wd4996", {tools = "cl"}
        )
        local runtime_dir = rootpath(path.join(
            "build/runtime/windows", get_config("arch"), get_config("mode")
        ))
        add_links(path.join(runtime_dir, "dora_runtime.lib"))
        add_syslinks(
            "advapi32", "bcrypt", "crypt32", "dbghelp", "gdi32", "imm32",
            "iphlpapi", "ntdll", "ole32", "psapi", "setupapi", "shell32",
            "user32", "userenv", "version", "winmm", "ws2_32"
        )
        set_runargs("--asset", rootpath("Assets"))
        set_rundir(DORA_ROOT)
        after_build(function (target)
            os.cp(path.join(runtime_dir, "wa.dll"), target:targetdir())
        end)
    elseif is_plat("android") then
        if is_mode("debug") then
            -- Android Studio's LLDB needs C/C++ line tables as well as symbols.
            -- A debug mode name alone does not enable xmake's mode.debug rule.
            set_symbols("debug")
        end
        add_defines("LUA_USE_LINUX")
        add_linkgroups(rootpath("build/runtime/android/" .. get_config("arch") .. "/" ..
            get_config("mode") .. "/libdora_runtime.a"))
        add_syslinks("android", "log", "EGL", "z", "GLESv1_CM", "GLESv2")
        add_cxflags("-fPIC", {force = true})
    end
target_end()
