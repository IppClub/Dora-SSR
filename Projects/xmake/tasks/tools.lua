local scripts = {
    ["web-game"] = "package_web_game.mjs",
    ["web-preview"] = "package_web_preview.mjs",
    ["web-rollback"] = "rollback_web_preview.mjs",
    ["gallery"] = "build_web_gallery.mjs"
}
for name, script in pairs(scripts) do
    task(name)
        set_category("plugin")
        set_menu {usage = "xmake " .. name .. " [-- ARGS]", description = "Production Web packaging tool",
            options = {{nil, "arguments", "vs", nil, "Tool arguments after --"}}}
        local filename = script
        on_run(function ()
            import("core.base.option")
            import("lib.detect.find_tool")
            local root = os.projectdir()
            local node = assert(find_tool("node"), "Web packaging requires Node.js")
            os.execv(node.program, table.join({path.join(root, "Projects/xmake/tools/web", filename)},
                option.get("arguments") or {}), {curdir = root, envs = {DORA_ENGINE_ROOT = root, DORA_XMAKE = os.programfile()}})
        end)
    task_end()
end

task("web-ide")
    set_category("plugin")
    set_menu {
        usage = "xmake web-ide",
        description = "Build only the Web IDE frontend and sync compressed assets; reuse the prepared Web Player runtime",
        options = {}
    }
    on_run(function ()
        import("lib.detect.find_tool")
        local root = os.projectdir()
        local node = assert(find_tool("node"), "Web IDE frontend builds require Node.js")
        assert(find_tool("pnpm"), "Web IDE frontend builds require pnpm; run pnpm install in Tools/dora-dora first")
        os.execv(node.program, {"scripts/build-project.js", "--frontend-only"}, {curdir = path.join(root, "Tools/dora-dora")})
    end)
task_end()

task("studio")
    set_category("plugin")
    set_menu {usage = "xmake studio", description = "Build Godot-enabled Studio Agent and game Players", options = {}}
    on_run(function ()
        local root = os.projectdir()
        import("lib.detect.find_tool")
        local node = assert(find_tool("node"), "Studio production builds require Node.js")
        local pnpm = assert(find_tool("pnpm"), "Studio production builds require pnpm")
        -- Agent support packages consume generated tutorials absent from a
        -- clean checkout. Generate them before building either engine.
        os.vrunv(node.program, {path.join(root, "Docs/scripts/generate-language-docs.js")}, {curdir = root})
        -- The runtime bundler imports this package before the recursive UI
        -- build. A clean checkout has no contracts/dist yet.
        os.vrunv(pnpm.program, {"--dir", path.join(root, "Studio"), "--filter", "@dora-studio/contracts", "build"}, {curdir = root})
        local output = path.join(root, "result/dora-studio-agent-engine")
        os.vrunv(os.programfile(), {"web"}, {curdir = root, envs = {
            DORA_WEB_STUDIO_AGENT_HOST = "1", DORA_WEB_BUILD_ENGINE = "1", DORA_WEB_LINK_PLAYER = "1",
            DORA_WEB_BUILD_LOVE_PROBE = "0", DORA_WEB_BUILD_LOVE_PTHREAD_PLAYER = "0", DORA_WEB_PTHREADS = "0",
            DORA_WEB_PROFILE = "dora-preset", DORA_WEB_FEATURE_MUSIC = "ON",
            DORA_WEB_GODOT = "1",
            DORA_WEB_BUILD_DIR = path.join(root, "build/studio-agent-host"),
            DORA_WEB_PACKAGE_DIR = path.join(root, "result/dora-studio-agent-build-probe"),
            DORA_WEB_PLAYER_PACKAGE_DIR = output
        }})
        import("core.base.json")
        local features = json.loadfile(path.join(output, "dora-web-features.json"))
        assert(features.studioAgentHost and features.activeProfile == "dora-preset", "invalid Studio Agent engine manifest")
        assert(features.modules and features.modules.godotNode, "Studio Agent engine must include Godot")
        assert(os.isfile(path.join(output, "godot/manifest.json")), "Studio Agent engine is missing LibGodot")
        for _, name in ipairs({"dora-player-runtime.js", "dora-player-runtime.wasm", "dora-player-runtime.data"}) do
            assert(os.isfile(path.join(output, name)) and os.filesize(path.join(output, name)) > 0, "missing Studio engine asset: " .. name)
        end
        local runtime = io.readfile(path.join(output, "dora-player-runtime.js"))
        assert(runtime:find("_dora_web_agent_request", 1, true), "Studio snapshot callback was not exported")
        assert(not runtime:find("Streaming is only supported when FETCH_STREAMING is enabled", 1, true), "Studio host lacks Fetch streaming")
        cprint("${green}Studio Agent engine: %s${clear}", output)
        local player = path.join(root, "result/dora-studio-player")
        os.vrunv(os.programfile(), {"web"}, {curdir = root, envs = {
            DORA_WEB_STUDIO_AGENT_HOST = "0", DORA_WEB_BUILD_ENGINE = "1", DORA_WEB_LINK_PLAYER = "1",
            DORA_WEB_BUILD_LOVE_PROBE = "0", DORA_WEB_BUILD_LOVE_PTHREAD_PLAYER = "0", DORA_WEB_PTHREADS = "1",
            DORA_WEB_GODOT = "1", DORA_WEB_PROFILE = "dora-preset", DORA_WEB_FEATURE_YUE = "OFF",
            DORA_WEB_FEATURE_MUSIC = "ON", DORA_WEB_FEATURE_PHYSICS_2D = "ON", DORA_WEB_FEATURE_ENTITY = "ON",
            DORA_WEB_FEATURE_PLATFORMER = "ON", DORA_WEB_FEATURE_BUILTIN_LIBS = "ON", DORA_WEB_FEATURE_ML = "ON",
            DORA_WEB_FEATURE_LOVE = "ON", DORA_WEB_FEATURE_MODEL_3D = "ON",
            DORA_WEB_BUILTIN_FONT = path.join(root, "Assets/Font/sarasa-mono-sc-regular.ttf"),
            DORA_WEB_BUILD_DIR = path.join(root, "build/studio-runtime-engine"),
            DORA_WEB_PACKAGE_DIR = path.join(root, "result/dora-studio-player-build-probe"),
            DORA_WEB_PLAYER_PACKAGE_DIR = player
        }})
        import("lib.detect.find_tool")
        os.vrunv(assert(find_tool("node"), "Studio runtime preparation requires Node.js").program,
            {path.join(root, "Studio/apps/web/scripts/prepare-runtime.mjs")},
            {curdir = root, envs = {STUDIO_RUNTIME_DIR = player}})
    end)
task_end()
