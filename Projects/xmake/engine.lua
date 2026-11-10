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

if is_plat("windows") then
    add_requires("dora-webview2 1.0.2903.40")
end

target("Dora")
    local csharp_native = os.getenv("DORA_BUILD_CSHARP_NATIVE") == "1"
    set_kind((is_plat("android") or csharp_native) and "shared" or "binary")
    if is_plat("android") then
        set_basename("main")
    end
    -- Native xmake build/run select the engine; auxiliary tools stay opt-in.
    set_default(true)
    if is_plat("macosx", "linux", "windows") then
        on_run(function (target)
            import("Projects.xmake.tools.native_run", {rootdir = DORA_ROOT, anonymous = true})(target)
        end)
    end
    -- The legacy CMake build kept compiler extensions enabled. GNU C11 is
    -- required by genuine C units such as the amalgamated Vorbis sources
    -- (alloca is a compiler extension there); it does not turn them into C++.
    set_languages("gnu11", "cxx20")
    -- A mode name alone does not enable xmake's compiler policies. Keep these
    -- common to every native host, including direct Android builds: Release
    -- must define NDEBUG so App.debugging and LLM context dumps are disabled.
    add_rules("mode.debug", "mode.release")
    if is_plat("macosx", "iphoneos", "linux", "windows") then
        if has_config("dora_godot_runtime") then add_deps("godot-component", {inherit = false}) end
        add_rules("dora.godot-component")
    end
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
        if os.host() == "windows" and os.arch() ~= "arm64"
            and (os.getenv("PROCESSOR_IDENTIFIER") or ""):find("ARM", 1, true) then
            raise("Windows ARM64 requires native ARM64 xmake; install the official ARM64 distribution instead of emulated x64 xmake")
        end
        assert(not csharp_native or target:is_plat("windows"), "The C# native host currently supports Windows only")
        import("core.project.config")
        local function godot_test(relative)
            local repo = config.get("dora_test_repo") or os.getenv("DORA_TEST_REPO")
            if not repo then
                repo = import("Projects.xmake.testing.repository", {rootdir = DORA_ROOT, anonymous = true})().directory
            end
            local source = path.join(repo, relative)
            assert(os.isfile(source), "external Godot test source is missing: " .. source)
            return source
        end
        if config.get("dora_native_tests") then
            local repo = assert(config.get("dora_test_repo"), "native tests require a resolved Dora-Example checkout")
            assert(os.isfile(path.join(repo, "Test/Native/HelloWorldCpp.cpp")), "external native test sources are missing")
            target:add("includedirs", path.join(repo, "Test"))
            target:add("files", path.join(repo, "Test/Native/HelloWorldCpp.cpp"))
        end
        if target:is_plat("macosx") and os.getenv("DORA_BUILD_LIBGODOT_METAL_PROBE") == "1" then
            target:add("files", godot_test("Test/LibGodotMetalProbe/DoraMetalProbe.mm"), {force = {mxxflags = {"-fobjc-arc"}}})
        end
        if target:is_plat("macosx", "iphoneos", "linux", "windows", "android") and os.getenv("DORA_BUILD_GODOT_NODE_TEST") == "1" then
            target:add("files", godot_test("Test/Godot/tests/GodotNodeTest.cpp"),
                csharp_native and {defines = {"DORA_AS_LIB"}} or nil)
            if target:is_plat("macosx", "iphoneos") then
                target:add("files", godot_test("Test/Godot/tests/GodotResourceProbe.mm"), {force = {mxxflags = {"-fobjc-arc"}}})
            end
        end
        local manifest = import("Projects.xmake.manifests.engine", {rootdir = os.projectdir(), anonymous = true})()
        for _, source in ipairs(manifest.sources) do
            local config
            if target:is_plat("windows") and get_config("toolchain") ~= "mingw"
                and source:endswith(".c") then
                -- Genuine C units stay in C mode; C++ code uses .cpp.
                config = {force = {cxflags = {"/TC"}}}
            end
            -- Only the native entrypoint and exported C ABI layer use this
            -- host mode. Keep other engine/vendor units reusable by the GUI.
            if csharp_native and (source == "Source/Basic/Application.cpp" or source == "Source/Wasm/WasmRuntime.cpp"
                or source == "Source/Wasm/RustRuntimeBridge.cpp") then
                config = {defines = {"DORA_AS_LIB"}}
            end
            if source == "Source/Basic/Application.cpp" and target:is_plat("macosx")
                and os.getenv("DORA_BUILD_LIBGODOT_METAL_PROBE") == "1" then
                config = {defines = {"DORA_LIBGODOT_METAL_PROBE=1"}}
            end
            if source == "Source/Basic/Application.cpp" and target:is_plat("macosx", "iphoneos", "linux", "windows", "android")
                and os.getenv("DORA_BUILD_GODOT_NODE_TEST") == "1" then
                config = {defines = csharp_native
                    and {"DORA_GODOT_NODE_TEST=1", "DORA_AS_LIB"}
                    or {"DORA_GODOT_NODE_TEST=1"}}
            end
            if source == "Source/Godot/GodotNode.cpp" and target:is_plat("macosx", "iphoneos", "linux", "windows", "android")
                and os.getenv("DORA_BUILD_GODOT_NODE_TEST") == "1" then
                config = {defines = {"DORA_GODOT_NODE_TEST=1"}}
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
        local bx_debug = is_mode("debug") and os.getenv("DORA_GODOT_D3D12_WARP") ~= "1"
        target:add("defines", bx_debug and "BX_CONFIG_DEBUG=1" or "BX_CONFIG_DEBUG=0")
    end)

    if is_plat("macosx") then
        if os.getenv("DORA_BUILD_LIBGODOT_METAL_PROBE") == "1" then
            set_targetdir(rootpath("build/godot-metal-probe/dora"))
        end
        if os.getenv("DORA_BUILD_GODOT_NODE_TEST") == "1" then
            set_targetdir(os.getenv("DORA_GODOT_TEST_TARGETDIR")
                or rootpath("build/godot-runtime/dora"))
        end
        add_rules("xcode.application")
        before_build(function (target)
            import("Projects.xmake.tools.macos_bundle", {rootdir = DORA_ROOT})(target)
        end)
        set_values("xcode.bundle_identifier", "IppClub.DoraSSR")
        set_toolchains("xcode", {target_minver = "12.0"})
        add_files(rootpath("Projects/macOS/Dora/Info.plist"), rootpath("Projects/macOS/Dora/Assets.xcassets"))
        add_files(rootpath("Source/Basic/Application.mm"), rootpath("Source/Basic/Content.mm"))
        add_files(rootpath("Source/Godot/GodotRuntimeMetal.mm"), {force = {mxxflags = {"-fobjc-arc"}}})
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
            "GameController", "IOKit", "Metal", "QuartzCore", "Security", "WebKit"
        )
    elseif is_plat("iphoneos") then
        add_files(rootpath("Source/Godot/GodotRuntimeMetal.mm"), {force = {mxxflags = {"-fobjc-arc"}}})
        local godot_test = os.getenv("DORA_BUILD_GODOT_NODE_TEST") == "1"
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
        local ios_output = godot_test and "build/godot-ios/host/" or "build/iphoneos/"
        set_targetdir(rootpath(ios_output .. apple_device .. "/" ..
            get_config("arch") .. "/" .. get_config("mode")))
        -- xcode.info_plist/xcassets/storyboard use separate dependency and
        -- generated-file trees, not just object files. Switching SDKs must
        -- never reuse a rule cache pointed at the other bundle directory.
        local ios_cache = godot_test and "godot-ios-" or "iphoneos-"
        set_objectdir(rootpath("build/.objs/" .. ios_cache .. apple_device))
        set_dependir(rootpath("build/.deps/" .. ios_cache .. apple_device))
        set_autogendir(rootpath("build/.gens/" .. ios_cache .. apple_device))
        add_rules("xcode.application")
        set_values("xcode.bundle_identifier", godot_test and "org.ippclub.dorassr.godotprototype.ios" or "IppClub.DoraSSR")
        set_toolchains("xcode", {target_minver = godot_test and "14.0" or "13.0"})
        add_files(
            rootpath("Projects/iOS/Dora/Info.plist"),
            rootpath("Projects/iOS/Dora/Assets.xcassets"),
            rootpath("Projects/iOS/Dora/Base.lproj/Launch Screen.storyboard"),
            rootpath("Projects/iOS/Dora/Base.lproj/Main.storyboard")
        )
        add_files(rootpath("Source/Basic/Application.mm"), rootpath("Source/Basic/Content.mm"))
        local ios_assets = godot_test and "build/godot-ios/test-assets" or "Assets"
        for _, resource in ipairs({"Audio", "Doc", "Font", "Image", "Script", "Shader", "dora-wa", "www"}) do
            add_installfiles(rootpath(ios_assets .. "/" .. resource .. "/**"), {rootdir = rootpath(ios_assets)})
        end
        add_installfiles(rootpath(ios_assets .. "/LICENSES"), rootpath(ios_assets .. "/gamecontrollerdb.txt"), {
            rootdir = rootpath(ios_assets)
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
        add_files(rootpath("Source/Godot/GodotRuntimeGL.cpp"))
        if os.getenv("DORA_BUILD_GODOT_NODE_TEST") == "1" then
            set_targetdir(os.getenv("DORA_GODOT_TEST_TARGETDIR")
                or rootpath("build/godot-runtime/dora"))
        end
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
        -- xmake 3.1.1 treats every Windows Clang driver as MSVC-compatible
        -- and otherwise injects its default MT/MTd runtime. LLVM-MinGW then
        -- receives -nostdlib and loses its CRT and libc++ startup libraries.
        -- A non-MSVC runtime marker prevents that default; the MinGW driver
        -- still selects its own UCRT and libc++ in the normal way.
        if get_config("toolchain") == "mingw" then
            set_runtimes("MINGW")
        end
        -- Retain both adapters in source, but link exactly one Godot bridge
        -- into a host. Like Godot's rendering-driver selection, the backend is
        -- fixed for the lifetime of the process rather than hot-switched.
        add_syslinks("opengl32")
        if (get_config("dora_godot_windows_backend") or "d3d12") == "d3d12" then
            add_files(rootpath("Source/Godot/GodotRuntimeD3D12.cpp"))
            add_defines("DORA_GODOT_WINDOWS_D3D12_BACKEND=1")
            add_syslinks("d3d12", "dxgi")
        else
            add_files(rootpath("Source/Godot/GodotRuntimeGL.cpp"))
            add_defines("DORA_GODOT_WINDOWS_GL_BACKEND=1")
        end
        if os.getenv("DORA_BUILD_GODOT_NODE_TEST") == "1" then
            set_targetdir(os.getenv("DORA_GODOT_TEST_TARGETDIR")
                or rootpath("build/godot-runtime/dora"))
        end
        if csharp_native then
            set_targetdir(rootpath("build/dora-csharp/native"))
        end
        add_packages("dora-webview2")
        add_files(rootpath("Source/Basic/CompilerWebViewWin.cpp"))
        add_files(rootpath("Projects/Windows/Dora/Resource.rc"))
        -- xmake's standalone .manifest rule is MSVC-specific. MinGW embeds
        -- the same file from Resource.rc so cross-built Windows hosts retain
        -- the requested-execution-level metadata without an unknown input.
        if get_config("toolchain") ~= "mingw" then
            add_files(rootpath("Projects/Windows/Dora/Dora.manifest"))
        end
        add_includedirs(rootpath("Projects/Windows/Dora"))
        add_includedirs(rootpath("Source/3rdParty/bx/include/compat/msvc"))
        add_defines("LUA_USE_WINDOWS", "_CRT_SECURE_NO_WARNINGS", "NOMINMAX")
        if get_config("toolchain") ~= "mingw" then
            set_runtimes(is_mode("debug") and "MTd" or "MT")
        end
        if is_mode("debug") then
            add_defines("_ITERATOR_DEBUG_LEVEL=0")
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
        add_links(path.join(runtime_dir,
            get_config("toolchain") == "mingw" and "libdora_runtime.a" or "dora_runtime.lib"))
        if get_config("toolchain") == "mingw" then
            add_syslinks("winpthread")
        end
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
        add_files(rootpath("Source/Godot/GodotRuntimeGL.cpp"))
        add_defines("LUA_USE_LINUX")
        add_linkgroups(rootpath("build/runtime/android/" .. get_config("arch") .. "/" ..
            get_config("mode") .. "/libdora_runtime.a"))
        add_syslinks("android", "log", "EGL", "z", "GLESv1_CM", "GLESv2")
        add_cxflags("-fPIC", {force = true})
    end
target_end()
