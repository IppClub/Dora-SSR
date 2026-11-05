if is_plat("macosx", "iphoneos", "linux", "windows") then
    target("godot-component")
        set_kind(os.getenv("XMAKE_IN_PROJECT_GENERATOR") and "binary" or "phony")
        set_default(false)
        set_group("godot/runtime")
        on_build(function (target)
            import("Projects.xmake.godot.component", {rootdir = os.projectdir()})(target, false)
        end)
    target_end()
    rule("dora.godot-component")
        before_build(function (target)
            import("Projects.xmake.godot.component", {rootdir = os.projectdir()})(target, true)
        end)
        on_config(function (target)
            import("core.project.config")
            if config.get("dora_godot_runtime") and target:is_plat("linux", "windows") then
                target:set("runenv", "DORA_GODOT_LIBRARY", os.getenv("DORA_GODOT_LIBRARY") or path.absolute(path.join(target:targetdir(), "Assets",
                    target:is_plat("windows") and "dora_godot.dll" or "libdora_godot.so")))
            end
        end)
    rule_end()
end
