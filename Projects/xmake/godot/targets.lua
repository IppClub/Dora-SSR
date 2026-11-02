local godot_root = path.join(os.projectdir(), "Source/3rdParty/Godot")
local output_root = path.join(os.projectdir(), "build/godot-xmake")
local generated_root = path.join(output_root, "generated")

local stages = {
    {name = "godot-core", source_roots = {"core"}, deps = {"godot-codegen"}},
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
        import("lib.detect.find_tool")
        local python = find_tool("python3") or find_tool("python")
        assert(python, "Python 3 is required for Godot source generation")
        local arguments = {
            path.join(os.projectdir(), "Tools/Godot/generate_xmake_sources.py"),
            "--output", generated_root
        }
        if is_plat("macosx") then
            table.insert(arguments, "--profile")
            table.insert(arguments, path.join(os.projectdir(), "Projects/xmake/godot/template_release_macos.json"))
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
        set_kind(stage.name == "godot-dora-bridge" and "object" or "static")
        set_default(false)
        set_group("godot/runtime")
        set_languages("gnu17", "gnuxx17")
        set_optimize("fastest")
        set_objectdir(path.join(output_root, "objects", stage.name))
        set_targetdir(path.join(output_root, "lib"))
        add_includedirs(godot_root, generated_root, {public = true})
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
    set_kind(is_plat("macosx") and "shared" or "static")
    set_default(false)
    set_group("godot/runtime")
    set_basename("dora_godot")
    set_languages("gnu17", "gnuxx17")
    set_optimize("fastest")
    set_objectdir(path.join(output_root, "objects", "godot-runtime"))
    set_targetdir(path.join(output_root, "lib"))
    add_includedirs(godot_root, generated_root, {public = true})
    add_deps("godot-dora-bridge")
    set_values("godot.source_root", godot_root)
    set_values("godot.generated_root", generated_root)
    set_values("godot.migration_stage", "XMAKE-01")
    before_build(function ()
        assert(has_config("dora_godot_runtime"),
            "godot-runtime is experimental; configure with --dora_godot_runtime=y")
    end)
target_end()

if is_plat("macosx") and is_arch("arm64") and has_config("dora_godot_runtime") then
    includes(path.join(os.projectdir(), "Projects/xmake/godot/macos_arm64_sources.lua"))
    target("godot-runtime")
        add_frameworks(
            "ForceFeedback", "Cocoa", "Carbon", "AudioUnit", "CoreAudio", "CoreMIDI",
            "IOKit", "GameController", "CoreHaptics", "CoreVideo", "AVFoundation",
            "CoreMedia", "QuartzCore", "Security", "UniformTypeIdentifiers", "IOSurface",
            "Metal", "MetalKit", "AppKit", "ApplicationServices", "CoreFoundation",
            "CoreGraphics", "CoreServices", "CoreText", "Foundation"
        )
        add_frameworks("MetalFX", {weak = true})
        add_syslinks("z")
        add_shflags(
            "-Wl,-exported_symbols_list," .. path.join(godot_root, "dora_bridge.exports"),
            "-Wl,-S", "-Wl,-x", "-Wl,-dead_strip",
            {force = true}
        )
    target_end()
end
