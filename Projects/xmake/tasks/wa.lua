for _, option_name in ipairs({"dora_wa_outdir", "dora_wa_sync_source"}) do
    option(option_name)
        set_showmenu(true)
    option_end()
end
option("dora_wa_sync_dryrun")
    set_default(false)
option_end()

for _, name in ipairs({"web", "sync"}) do
    target("dora-wa-" .. name .. "-tool")
        set_kind(os.getenv("XMAKE_IN_PROJECT_GENERATOR") and "binary" or "phony")
        set_default(false)
        add_packages("dora_go")
        local sync = name == "sync"
        on_build(function (target)
            import("Projects.xmake.tools.wa.build", {rootdir = os.projectdir(), anonymous = true})(target, sync)
        end)
    target_end()
end

for _, name in ipairs({"dora-wa-web", "dora-wa-sync"}) do
    task(name)
        set_category("plugin")
        set_menu {usage = "xmake " .. name .. " [--output=PATH] [--source=WA_CHECKOUT] [--dry-run]",
            description = "Build Wa Web or synchronize vendored Wa sources with managed Go",
            options = {{nil, "output", "kv", nil, "Wa Web output directory"},
                {nil, "source", "kv", nil, "Upstream Wa source checkout"},
                {nil, "dry-run", "k", nil, "Validate source without replacing vendored code"}}}
        local sync = name == "dora-wa-sync"
        on_run(function ()
            import("core.base.option")
            local root = os.projectdir()
            local directory = path.join(root, "build/wa-tools", sync and "sync" or "web")
            local envs = {XMAKE_CONFIGDIR = path.join(directory, ".xmake-config")}
            local args = {"f", "-y", "-p", os.host(), "-a", os.arch(), "-m", "release", "--builddir=" .. directory}
            if sync then
                table.insert(args, "--dora_wa_sync_source=" .. assert(option.get("source"), "--source is required"))
                table.insert(args, "--dora_wa_sync_dryrun=" .. (option.get("dry-run") and "y" or "n"))
            else
                table.insert(args, "--dora_wa_outdir=" .. path.absolute(option.get("output") or "result/dora-wa-web", root))
            end
            os.vrunv(os.programfile(), args, {curdir = root, envs = envs})
            os.execv(os.programfile(), {"build", sync and "dora-wa-sync-tool" or "dora-wa-web-tool"}, {curdir = root, envs = envs})
        end)
    task_end()
end
