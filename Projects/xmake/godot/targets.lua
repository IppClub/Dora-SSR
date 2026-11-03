local godot_root = path.join(os.projectdir(), "Source/3rdParty/Godot")
local output_root = path.join(os.projectdir(), "build/godot-xmake")
local windows_backend = get_config("dora_godot_windows_backend") or "wgl"
local platform_output_root = output_root
if is_plat("linux") then
    -- Linux is commonly cross-built for both supported architectures from the
    -- same checkout. Keep generated sources shared, but never allow object or
    -- library files from one architecture to satisfy the other build.
    platform_output_root = path.join(output_root, "linux", get_config("arch"))
elseif is_plat("mingw") then
    platform_output_root = path.join(output_root, "windows", get_config("arch"), windows_backend)
elseif is_plat("android") then
    platform_output_root = path.join(output_root, "android", get_config("arch"))
elseif is_plat("wasm") then
    platform_output_root = path.join(output_root, "web", get_config("arch"))
elseif is_plat("iphoneos") then
    platform_output_root = path.join(output_root, "ios", get_config("appledev") or "iphoneos", get_config("arch"))
end
local debug_runtime = is_mode("debug")
if debug_runtime then
    platform_output_root = path.join(platform_output_root, "debug")
end
local generated_root = path.join(output_root, "generated")
if debug_runtime or is_plat("android", "wasm", "iphoneos") or (is_plat("mingw") and windows_backend == "d3d12") then
    -- Android must not replace the macOS Metal profile's generated headers
    -- when both platforms are built from the same host checkout.
    generated_root = path.join(platform_output_root, "generated")
end
DORA_GODOT_GENERATED_ROOT = generated_root

-- xmake appends <target>/<plat>/<arch>/<mode> below dependir itself.  Keep
-- this as a shared root: including the target name here duplicates that path
-- and leaves the final shared-library .d parent absent on Linux.
local platform_depend_root = path.join(platform_output_root, "deps")
local generated_include_dirs = {}
for _, relative in ipairs({
    "core", "core/extension", "core/input", "core/io", "core/object", "core/profiling",
    "drivers/gles3/shaders", "drivers/gles3/shaders/effects", "main", "modules", "platform",
    "platform/android/export", "platform/ios/export", "platform/linuxbsd/export",
    "platform/macos/export", "platform/visionos/export", "platform/web/export",
    "platform/windows/export", "scene/theme", "servers/rendering/renderer_rd/effects",
    "servers/rendering/renderer_rd/shaders", "servers/rendering/renderer_rd/shaders/effects",
    "servers/rendering/renderer_rd/shaders/effects/fsr2",
    "servers/rendering/renderer_rd/shaders/environment",
    "servers/rendering/renderer_rd/shaders/forward_clustered",
    "servers/rendering/renderer_rd/shaders/forward_mobile"
}) do
    table.insert(generated_include_dirs, path.join(generated_root, relative))
end

local stages = {
    {name = "godot-jpeg-8", source_roots = {"thirdparty"}, object = true, deps = {"godot-codegen"}},
    {name = "godot-jpeg-12", source_roots = {"thirdparty"}, object = true, deps = {"godot-codegen"}},
    {name = "godot-pcre2-16", source_roots = {"thirdparty"}, object = true, deps = {"godot-codegen"}},
    {name = "godot-pcre2-32", source_roots = {"thirdparty"}, object = true, deps = {"godot-codegen"}},
    {name = "godot-core", source_roots = {"core"}, deps = {"godot-codegen", "godot-jpeg-8", "godot-jpeg-12", "godot-pcre2-16", "godot-pcre2-32"}},
    {name = "godot-drivers", source_roots = {"drivers"}, deps = {"godot-core"}},
    {name = "godot-servers", source_roots = {"servers"}, deps = {"godot-drivers"}},
    {name = "godot-scene", source_roots = {"scene"}, deps = {"godot-servers"}},
    {name = "godot-modules", source_roots = {"modules"}, deps = {"godot-scene"}},
    {
        name = "godot-main-platform",
        source_roots = {"main", "platform"},
        deps = {"godot-modules"}
    },
    {
        name = "godot-dora-bridge",
        source_roots = {"modules/dora_bridge"},
        deps = {"godot-main-platform"}
    }
}

target("godot-codegen")
    set_kind("phony")
    set_default(false)
    set_group("godot/runtime")
    set_values("godot.generated_root", generated_root)
    on_build(function ()
        assert(has_config("dora_godot_runtime"),
            "godot-codegen is experimental; configure with --dora_godot_runtime=y")
        -- Reject source-side generated headers before variant dependencies compile.
        local conflicts = os.files(path.join(godot_root, "**.gen.*"))
        table.join2(conflicts, os.files(path.join(godot_root, ".sconsign*")))
        if os.isdir(path.join(godot_root, "bin/obj")) then
            table.insert(conflicts, path.join(godot_root, "bin/obj"))
        end
        table.sort(conflicts)
        assert(#conflicts == 0,
            "Godot xmake requires clean vendor inputs. Archive SCons generated files " ..
            "and caches outside Source/3rdParty/Godot, and use a separate checkout " ..
            "for SCons comparisons. First conflict: " .. tostring(conflicts[1]))
        import("lib.detect.find_tool")
        local python = find_tool("python3") or find_tool("python")
        assert(python, "Python 3 is required for Godot source generation")
        if is_plat("mingw") and windows_backend == "d3d12" then
            os.vrunv(python.program, {"-B", path.join(os.projectdir(), "Tools/Godot/verify_d3d12_sdk.py"),
                "--sdk", assert(get_config("dora_godot_mesa_libs")),
                "--architecture", get_config("arch"),
                "--output", path.join(platform_output_root, "sdk-verification.json")})
        end
        local arguments = {
            "-B", -- Upstream Python imports must not write bytecode into vendor.
            path.join(os.projectdir(), "Tools/Godot/generate_xmake_sources.py"),
            "--output", generated_root
        }
        if is_plat("macosx") then
            table.insert(arguments, "--profile")
            table.insert(arguments, path.join(os.projectdir(), "Projects/xmake/godot/template_release_macos.json"))
        elseif is_plat("wasm") then
            table.insert(arguments, "--profile")
            table.insert(arguments, path.join(os.projectdir(), "Projects/xmake/godot/template_release_web.json"))
        elseif is_plat("iphoneos") then
            table.insert(arguments, "--profile")
            table.insert(arguments, path.join(os.projectdir(), "Projects/xmake/godot/template_release_ios.json"))
        elseif is_plat("mingw") and windows_backend == "d3d12" then
            table.insert(arguments, "--profile")
            table.insert(arguments, path.join(os.projectdir(), "Projects/xmake/godot/template_release_windows_d3d12.json"))
        end
        if is_plat("android") and is_arch("armeabi-v7a") then
            table.join2(arguments, {"--disable-module", "raycast"})
        end
        os.vrunv(python.program, arguments)
    end)
target_end()

-- XMAKE-01 deliberately establishes only the dependency and output skeleton.
-- XMAKE-02 will attach generated headers/sources and XMAKE-03+ will add the
-- platform-specific source manifests and flags. Keeping these targets disabled
-- by default prevents an incomplete migration from affecting normal Dora builds.
for _, stage in ipairs(stages) do
    target(stage.name)
        -- Upstream links Android's platform/JNI translation units directly.
        -- A static archive can discard JNI-only entrypoints before Java loads
        -- them; object dependencies keep the same link shape without forcing
        -- an archive twice through xmake's transitive library dependencies.
        local raw_objects = stage.object or stage.name == "godot-dora-bridge" or
            (is_plat("android", "wasm") and stage.name == "godot-main-platform")
        set_kind(raw_objects and "object" or "static")
        set_default(false)
        set_group("godot/runtime")
        if is_plat("wasm") then
            set_toolchains("emcc@dora_emscripten")
            add_packages("dora_emscripten")
            -- Emscripten's SSE emulation flags are valid together with SIMD128.
            -- Probing each flag alone can discard required Jolt definitions.
            set_policy("check.auto_ignore_flags", false)
        end
        set_languages("gnu17", "gnuxx17")
        set_optimize(debug_runtime and "none" or "fastest")
        if debug_runtime then set_symbols("debug") end
        if is_plat("iphoneos") then
            set_toolchains("xcode", {target_minver = "14.0"})
            on_config(function (target)
                import("core.base.json")
                local sdk = assert(target:toolchain("xcode"):config("xcode_sysroot"))
                local profile = json.loadfile(path.join(os.projectdir(), "Projects/xmake/godot/ios_link.json"))
                for _, sourcefile in ipairs(target:sourcefiles()) do
                    local fileconfig = table.clone(assert(target:fileconfig(sourcefile)))
                    for _, language in ipairs({"cflags", "cxxflags", "mflags", "mxxflags"}) do
                        if fileconfig[language] then
                            local flags = {}
                            for _, value in ipairs(fileconfig[language]) do
                                local relative = value:match("^%-I@SDK@/(.+)$")
                                if relative then
                                    assert(table.contains(profile.sdk_include_dirs, relative),
                                        "Unaudited Godot SDK include: " .. relative)
                                    value = "-I" .. path.join(sdk, relative)
                                end
                                table.insert(flags, value)
                            end
                            fileconfig[language] = flags
                        end
                    end
                    target:fileconfig_set(sourcefile, fileconfig)
                end
            end)
        end
        set_objectdir(path.join(platform_output_root, "objects", stage.name))
        set_dependir(platform_depend_root)
        set_targetdir(path.join(platform_output_root, "lib"))
        add_includedirs(godot_root, generated_root, {public = true})
        add_includedirs(table.unpack(generated_include_dirs))
        if is_plat("macosx") then
            add_defines("MODULE_GLSLANG_ENABLED")
        end
        set_values("godot.source_roots", stage.source_roots)
        set_values("godot.generated_root", generated_root)
        if stage.deps then
            add_deps(table.unpack(stage.deps))
        end

    target_end()
end

target("godot-runtime")
    set_kind((is_plat("macosx") or is_plat("linux") or is_plat("mingw") or is_plat("android")) and "shared" or "static")
    set_default(false)
    set_group("godot/runtime")
    if is_plat("wasm") then
        set_toolchains("emcc@dora_emscripten")
        add_packages("dora_emscripten")
    end
    set_basename("dora_godot")
    set_languages("gnu17", "gnuxx17")
    set_optimize(debug_runtime and "none" or "fastest")
        if debug_runtime then set_symbols("debug") end
    set_objectdir(path.join(platform_output_root, "objects", "godot-runtime"))
    set_dependir(platform_depend_root)
    set_targetdir(path.join(platform_output_root, "lib"))
    add_includedirs(godot_root, generated_root, {public = true})
    add_includedirs(table.unpack(generated_include_dirs))
    add_deps("godot-dora-bridge")
    set_values("godot.source_root", godot_root)
    set_values("godot.generated_root", generated_root)
    set_values("godot.migration_stage", "XMAKE-01")
    before_build(function (target)
        assert(has_config("dora_godot_runtime"),
            "godot-runtime is experimental; configure with --dora_godot_runtime=y")
        -- This final target has no source files of its own, so xmake never
        -- creates its dependency directory as a side effect of compilation.
        -- The linker still writes libdora_godot.so.d there.
        os.mkdir(target:dependir())
    end)
target_end()

if is_plat("macosx") and is_arch("arm64") and has_config("dora_godot_runtime") then
    includes(path.join(os.projectdir(), "Projects/xmake/godot/macos_arm64_sources.lua"))
    target("godot-runtime")
        on_config(function (target)
            target:data_add("linkdepfiles", path.join(godot_root, "dora_bridge.exports"))
        end)
        add_frameworks(
            "ForceFeedback", "Cocoa", "Carbon", "AudioUnit", "CoreAudio", "CoreMIDI",
            "IOKit", "GameController", "CoreHaptics", "CoreVideo", "AVFoundation",
            "CoreMedia", "QuartzCore", "Security", "UniformTypeIdentifiers", "IOSurface",
            "Metal", "MetalKit", "AppKit", "ApplicationServices", "CoreFoundation",
            "CoreGraphics", "CoreServices", "CoreText", "Foundation"
        )
        add_frameworks("MetalFX", {weak = true})
        add_syslinks("z")
        if not debug_runtime then add_shflags("-Wl,-S", "-Wl,-x", {force = true}) end
        add_shflags(
            "-Wl,-exported_symbols_list," .. path.join(godot_root, "dora_bridge.exports"),
            "-Wl,-dead_strip",
            {force = true}
        )
    target_end()
end

if is_plat("iphoneos") and is_arch("arm64") and has_config("dora_godot_runtime") then
    local variant = get_config("appledev") == "simulator" and "ios_simulator_arm64" or "ios_device_arm64"
    includes(path.join(os.projectdir(), "Projects/xmake/godot/" .. variant .. "_sources.lua"))
    target("godot-runtime")
        set_toolchains("xcode", {target_minver = "14.0"})
        -- Framework consumers need a complete archive, rather than an archive
        -- that silently omits its static subsystem dependencies.
        set_policy("build.merge_archive", true)
        add_files(path.join(os.projectdir(), "Projects/xmake/godot/runtime_link.cpp"))
    target_end()
end

-- The audited Windows WGL manifest uses GCC/MinGW flags. MSVC needs a separate
-- audited manifest; do not feed these flags to xmake's native windows toolchain.
if is_plat("mingw") and (is_arch("x86_64") or is_arch("arm64")) and has_config("dora_godot_runtime") then
    if windows_backend == "d3d12" then
        includes(path.join(os.projectdir(), "Projects/xmake/godot/windows_d3d12_" .. get_config("arch") .. "_sources.lua"))
    else
        includes(path.join(os.projectdir(), "Projects/xmake/godot/windows_" .. get_config("arch") .. "_sources.lua"))
    end
    local staged_libdir = path.join(platform_output_root, "lib")
    target("godot-runtime")
        if not debug_runtime then add_shflags("-s", {force = true}) end
        if debug_runtime then add_syslinks("psapi", "dbghelp") end
        -- Resource compilation is absent from compile_commands.json, but the
        -- SCons DLL includes the template's version info, icon and manifest.
        add_files(path.join(godot_root, "platform/windows/godot_res_template.rc"))
        -- A resource-only final target selects the resource language's linker
        -- flags in xmake, dropping C/C++ syslinks despite its object deps.
        add_files(path.join(os.projectdir(), "Projects/xmake/godot/runtime_link.cpp"))
        add_syslinks(
            "mingw32", "dsound", "ole32", "d3d9", "winmm", "gdi32", "iphlpapi",
            "shell32", "shlwapi", "shcore", "wsock32", "ws2_32", "kernel32",
            "oleaut32", "sapi", "dinput8", "dxguid", "ksuser", "imm32", "bcrypt",
            "crypt32", "avrt", "uuid", "dwmapi", "dwrite", "wbemuuid", "ntdll", "hid",
            "user32"
        )
        if windows_backend == "wgl" then
            add_syslinks("opengl32")
        else
            add_syslinks("dxgi", "version", "psapi")
            on_load(function (target)
                local mesa = assert(get_config("dora_godot_mesa_libs"), "Configure --dora_godot_mesa_libs for D3D12")
                local library = path.join(mesa, "bin/libNIR.windows." .. get_config("arch") .. ".a")
                assert(os.isfile(library) and os.isfile(path.join(mesa, "godot-mesa/VERSION.info")),
                    "Expected the Godot NIR SDK for the selected Windows architecture")
                target:add("shflags", "-Wl,--start-group", library, "-Wl,--end-group", {force = true})
            end)
        end
        add_shflags(
            "-Wl,--start-group",
            path.join(staged_libdir, "libgodot-main-platform.a"),
            path.join(staged_libdir, "libgodot-modules.a"),
            path.join(staged_libdir, "libgodot-scene.a"),
            path.join(staged_libdir, "libgodot-servers.a"),
            path.join(staged_libdir, "libgodot-drivers.a"),
            path.join(staged_libdir, "libgodot-core.a"),
            "-Wl,--end-group", "-Wl,--no-undefined", "-Wl,--exclude-all-symbols",
            "-Wl,--subsystem,console", "-Wl,--stack,8388608",
            -- Match use_static_cpp=yes, including MinGW POSIX libwinpthread.
            "-static", "-static-libgcc", "-static-libstdc++",
            {force = true}
        )
    target_end()
end

if is_plat("android") and (is_arch("arm64-v8a") or is_arch("armeabi-v7a") or is_arch("x86_64")) and has_config("dora_godot_runtime") then
    local variant = ({["arm64-v8a"]="arm64", ["armeabi-v7a"]="arm32", ["x86_64"]="x86_64"})[get_config("arch")]
    includes(path.join(os.projectdir(), "Projects/xmake/godot/android_" .. variant .. "_sources.lua"))
    if is_arch("x86_64") then
        target("godot-core")
            add_defines("PNG_INTEL_SSE")
        target_end()
    end
    local staged_libdir = path.join(platform_output_root, "lib")
    target("godot-runtime")
        set_basename("godot_android")
        add_files(path.join(os.projectdir(), "Projects/xmake/godot/runtime_link.cpp"))
        add_syslinks("OpenSLES", "EGL", "android", "log", "z", "dl", "GLESv3", "GLESv2",
                     "camera2ndk", "mediandk")
        add_shflags(
            "-Wl,--start-group",
            -- Platform/JNI units arrive through the object dependency above;
            -- the remaining subsystem archives still need cyclic resolution.
            path.join(staged_libdir, "libgodot-modules.a"),
            path.join(staged_libdir, "libgodot-scene.a"),
            path.join(staged_libdir, "libgodot-servers.a"),
            path.join(staged_libdir, "libgodot-drivers.a"),
            path.join(staged_libdir, "libgodot-core.a"),
            "-Wl,--end-group", "-Wl,--gc-sections", "-Wl,--no-undefined",
            "-Wl,-z,now", "-Wl,--build-id", "-Wl,-soname,libgodot_android.so",
            "-Wl,--version-script=" .. path.join(godot_root, "dora_android.map"),
            {force = true}
        )
    target_end()
end

if is_plat("wasm") and is_arch("wasm32") and has_config("dora_godot_runtime") then
    includes(path.join(os.projectdir(), "Projects/xmake/godot/web_wasm32_sources.lua"))
    target("godot-runtime")
        set_kind("binary")
        set_filename("dora-godot.js")
        add_files(path.join(os.projectdir(), "Projects/xmake/godot/runtime_link.cpp"))
        -- The link anchor must carry the same Wasm atomics/longjmp features
        -- as the imported objects in this shared-memory runtime.
        add_cxflags("-sUSE_PTHREADS=1", "-msimd128", "-sSUPPORT_LONGJMP=wasm", {force = true})
        add_cxxflags("-fno-exceptions", {force = true})
        on_load(function (target)
            import("core.base.json")
            local configfile = path.join(os.projectdir(), "Projects/xmake/godot/web_link.json")
            local profile = json.loadfile(configfile)
            local inputs = {configfile}
            local profiling = os.getenv("DORA_GODOT_WEB_PROFILE_FUNCTIONS") == "1"
            for _, value in ipairs(profile.flags) do
                value = value:gsub("@GODOT@", function () return godot_root end)
                if debug_runtime and value:match("^%-O[0-3sz]$") then value = "-O0" end
                if not ((profiling or debug_runtime) and value == "-s") then
                    target:add("ldflags", value, {force = true})
                end
                local input = value:match("^%-%-js%-library=(.+)$") or
                    value:match("^%-%-post%-js=(.+)$") or value:match("^%-%-pre%-js=(.+)$")
                if input then table.insert(inputs, input) end
            end
            if profiling then
                target:add("ldflags", "--profiling-funcs", {force = true})
            end
            target:data_set("godot.web.link_inputs", inputs)
        end)
        before_link(function (target)
            import("core.project.depend")
            -- Emscripten JS libraries are linker inputs, even though they do
            -- not appear in the C++ dependency files tracked by xmake.
            depend.on_changed(function () os.tryrm(target:targetfile()) end, {
                dependfile = target:dependfile(target:targetfile() .. ".js-inputs"),
                files = target:data("godot.web.link_inputs"),
                values = target:get("ldflags"), changed = not os.isfile(target:targetfile())})
        end)
    target_end()
end

if is_plat("linux") and (is_arch("arm64") or is_arch("x86_64")) and has_config("dora_godot_runtime") then
    if is_arch("x86_64") then
        -- The x86_64 baseline includes libpng/libtheora SIMD sources and the
        -- Zstd AMD64 assembler loop which do not exist in the ARM64 graph.
        includes(path.join(os.projectdir(), "Projects/xmake/godot/linux_x86_64_sources.lua"))
    else
        includes(path.join(os.projectdir(), "Projects/xmake/godot/linux_sources.lua"))
    end
    local staged_libdir = path.join(platform_output_root, "lib")
    target("godot-runtime")
        if not debug_runtime then add_shflags("-s", {force = true}) end
        add_syslinks("pthread", "dl", "EGL", "GLESv2")
        add_shflags(
            -- The staged archives deliberately mirror Godot subsystems, but
            -- upstream has valid cross-subsystem references (for example the
            -- ICU data stub in modules is referenced by ICU objects in core).
            -- Rescan the complete group so GNU ld resolves those cycles.
            "-Wl,--start-group",
            path.join(staged_libdir, "libgodot-main-platform.a"),
            path.join(staged_libdir, "libgodot-modules.a"),
            path.join(staged_libdir, "libgodot-scene.a"),
            path.join(staged_libdir, "libgodot-servers.a"),
            path.join(staged_libdir, "libgodot-drivers.a"),
            path.join(staged_libdir, "libgodot-core.a"),
            "-Wl,--end-group",
            "-Wl,--no-undefined",
            "-static-libgcc", "-static-libstdc++",
            "-Wl,--version-script=" .. path.join(godot_root, "dora_bridge.map"),
            {force = true}
        )
    target_end()
end
