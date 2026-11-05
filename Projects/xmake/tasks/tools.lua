local scripts = {
    ["dora-web-game"] = "package_web_game.mjs",
    ["dora-web-preview"] = "package_web_preview.mjs",
    ["dora-web-rollback"] = "rollback_web_preview.mjs",
    ["dora-gallery"] = "build_web_gallery.mjs"
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

task("dora-studio")
    set_category("plugin")
    set_menu {usage = "xmake dora-studio", description = "Build Godot-enabled Studio Agent and game Players"}
    on_run(function ()
        local root = os.projectdir()
        local output = path.join(root, "result/dora-studio-agent-engine")
        os.vrunv(os.programfile(), {"dora-web"}, {curdir = root, envs = {
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
        os.vrunv(os.programfile(), {"dora-web"}, {curdir = root, envs = {
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
