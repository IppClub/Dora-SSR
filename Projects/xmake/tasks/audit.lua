task("audit-manifests")
    set_category("plugin")
    on_run(function ()
        local manifest = import("Projects.xmake.manifests.engine", {rootdir = os.projectdir(), anonymous = true})()
        local seen = {}
        for _, source in ipairs(manifest.sources) do
            assert(source:startswith("Source/") and path.normalize(source) == source, "invalid source path: " .. source)
            assert(not seen[source], "duplicate source path: " .. source)
            assert(os.isfile(path.join(os.projectdir(), source)), "missing source: " .. source)
            seen[source] = true
        end
        for _, source in ipairs({"Source/Basic/Director.cpp", "Source/Lua/LuaEngine.cpp", "Source/Input/TouchDispather.cpp"}) do
            assert(seen[source], "missing core platform coverage: " .. source)
        end
        cprint("${green}OK${clear} %d unique, present engine sources; core coverage passed", #manifest.sources)
    end)
    set_menu {usage = "xmake audit-manifests", description = "Validate the canonical source manifest without a duplicate legacy list"}
task_end()
