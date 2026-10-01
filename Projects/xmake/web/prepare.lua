function main(target)
    import("core.project.depend")
    import("lib.detect.find_tool")
    local c = import("Projects.xmake.web.config", {rootdir = os.projectdir(), anonymous = true})()
    local values = {c.profile, tostring(c.pthreads), tostring(c.studio_agent_host), c.complex or "", tostring(c.link_player), tostring(c.love_probe), c.testweb or ""}
    for _, name in ipairs({"physics_2d", "entity", "platformer", "builtin_libs", "ml", "yue", "love", "model_3d", "music"}) do
        table.insert(values, tostring(c.features[name]))
    end
    local envs = target:pkgenvs()
    envs.DORA_ENGINE_ROOT = c.root
    envs.DORA_TEST_WEB = c.testweb
    envs.DORA_TEST_SCRIPTS = c.testweb and path.join(path.directory(c.testweb), "BuildScripts")
    envs.PATH = (envs.PATH or "") .. path.envsep() .. os.getenv("PATH")
    local node = assert(find_tool("node", {envs = envs}), "Web asset generation requires the Emscripten-bundled Node.js")
    local function script(name, args, extra_envs)
        local directory = name == "package_web_game.mjs" and path.join(c.root, "Projects/xmake/tools/web")
            or assert(envs.DORA_TEST_SCRIPTS, "test fixture generation requires external tests")
        os.vrunv(node.program, table.join({path.join(directory, name)}, args or {}), {envs = table.join(envs, extra_envs or {})})
    end
    local inputs = os.files(path.join(c.web, "runtime-assets/**"))
    table.join2(inputs, os.files(path.join(c.root, "Projects/xmake/tools/web/*.mjs")))
    if c.testweb then
        table.join2(inputs, os.files(path.join(c.testweb, "**")))
        table.join2(inputs, os.files(path.join(envs.DORA_TEST_SCRIPTS, "*.mjs")))
    end
    table.insert(inputs, path.join(c.root, "Projects/xmake/web/prepare.lua"))
    table.join2(inputs, {path.join(c.web, "web-features.json.in"), path.join(c.root, "Assets/Image/logo.png"),
        path.join(c.root, "Source/3rdParty/bgfx/src/bgfx_shader.sh"), path.join(c.root, "Source/3rdParty/bgfx/src/bgfx_compute.sh")})
    if c.complex then table.insert(inputs, c.complex); table.insert(inputs, path.join(c.testweb, "love-complex-project.json")) end
    depend.on_changed(function ()
        os.mkdir(c.out)
        if c.testweb then script("check_web_api_parity.mjs") end
        local replacements = {DORA_WEB_PROFILE = c.profile, DORA_WEB_STUDIO_AGENT_HOST_JSON = tostring(not not c.studio_agent_host),
            DORA_WEB_RUST_BRIDGE_JSON = tostring(c.rust), DORA_WEB_THREADS_JSON = tostring(not not c.pthreads),
            DORA_WEB_CROSS_ORIGIN_ISOLATION_JSON = tostring(not not c.pthreads)}
        for feature, enabled in pairs(c.features) do replacements["DORA_WEB_FEATURE_" .. feature:upper() .. "_JSON"] = tostring(enabled) end
        local json = io.readfile(path.join(c.web, "web-features.json.in")):gsub("@([%w_]+)@", function (key) return assert(replacements[key], key) end)
        io.writefile(path.join(c.out, "dora-web-features.json"), json)
        io.writefile(path.join(c.out, "dora-web-features.js"), "(function(global) { const features = " .. json ..
            "; global.DoraWebFeatures = features; (global.Module = global.Module || {}).doraWebFeatures = features; })(globalThis);\n")
        for _, name in ipairs({"bgfx_shader.sh", "bgfx_compute.sh"}) do
            local data = io.readfile(path.join(c.root, "Source/3rdParty/bgfx/src", name), {encoding = "binary"})
            local bytes = data:gsub(".", function (byte) return string.format("0x%02x,", byte:byte()) end)
            local output = path.join(c.out, "bgfx-embedded/generated", name .. ".h")
            os.mkdir(path.directory(output))
            io.writefile(output, bytes .. "0x00\n")
        end
        if c.link_player then
            os.tryrm(path.join(c.out, "assets"))
            local stage = path.join(c.out, "web-game-stage")
            os.tryrm(stage)
            os.cp(c.testweb and path.join(c.testweb, "demo-game") or path.join(c.web, "runtime-assets"), stage)
            os.mkdir(path.join(stage, "Image"))
            os.cp(path.join(c.root, "Assets/Image/logo.png"), path.join(stage, "Image/logo.png"))
            if c.testweb then
                os.mkdir(path.join(stage, "Audio"))
                script("generate_web_audio_fixture.mjs", {path.join(stage, "Audio/fixture.wav"), path.join(stage, "Audio/fixture.ogg")})
                script("generate_web_render_fixtures.mjs", {stage})
            end
            script("package_web_game.mjs", {stage, c.out, "init.lua"}, {DORA_WEB_GAME_PROFILE = c.profile, DORA_WEB_EAGER_GAME_ASSETS = "0"})
        end
        if c.love_probe then
            local stage = path.join(c.out, "love-audio-fixture")
            os.tryrm(stage)
            os.cp(path.join(c.testweb, "love-audio-fixture"), stage)
            script("generate_web_audio_fixture.mjs", {path.join(stage, "fixture.wav"), path.join(stage, "fixture.ogg")})
        end
        if c.complex then
            script("check_web_love_complex_input.mjs", {path.join(c.testweb, "love-complex-project.json")}, {DORA_WEB_LOVE_COMPLEX_PACKAGE = c.complex})
            script("stage_web_love_complex_input.mjs", {c.complex, path.join(c.out, "love-complex-stage")})
        end
    end, {dependfile = path.join(c.out, "prepare.d"), files = inputs,
        -- Nil holes are compacted when xmake serializes dependency values;
        -- keep a dense list so a missing optional complex package is stable.
        values = values,
        changed = not os.isfile(path.join(c.out, "dora-web-features.js")) or
            (c.link_player and not os.isfile(path.join(c.out, "dora-web-manifest.json")))})
end
