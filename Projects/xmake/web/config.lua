function main()
    import("core.project.config")
    local c = {profile = config.get("dora_web_profile") or "dora-preset", features = {}}
    c.mode = config.mode()
    assert(c.profile == "core" or c.profile == "dora-preset" or c.profile == "custom", "invalid Web profile")
    for _, name in ipairs({"physics_2d", "entity", "platformer", "builtin_libs", "ml", "yue", "love", "model_3d", "music"}) do
        local value = (config.get("dora_web_feature_" .. name) or "AUTO"):upper()
        assert(value == "AUTO" or value == "ON" or value == "OFF", "invalid feature: " .. name)
        c.features[name] = value == "ON" or (value == "AUTO" and c.profile == "dora-preset"
            and name ~= "love" and name ~= "model_3d" and name ~= "music")
    end
    for _, name in ipairs({"engine", "link_player", "love_probe", "love_pthread_player", "pthreads", "diagnostics", "studio_agent_host", "experimental_main_worker"}) do
        c[name] = config.get("dora_web_" .. name)
    end
    assert(not c.features.platformer or (c.features.entity and c.features.physics_2d), "platformer requires entity and physics_2d")
    assert(not c.link_player or c.engine, "Web Player requires engine")
    assert(not c.love_pthread_player or (c.pthreads and c.engine and c.love_probe and c.link_player), "Love pthread Player requires pthreads, engine, probes and Player")
    assert(not c.experimental_main_worker or c.pthreads, "main worker requires pthreads")
    assert(not (c.studio_agent_host and c.experimental_main_worker), "Studio host cannot enable experimental main worker")
    c.root = os.projectdir()
    c.web = path.join(c.root, "Projects/Web")
    c.testweb = config.get("dora_web_testdir")
    if c.testweb == "" then c.testweb = nil end
    c.out = path.absolute(config.get("dora_web_outdir") or path.join(config.builddir(), "web"), c.root)
    local ancestor = c.root
    while true do
        assert(c.out ~= ancestor, "Web output must not be the workspace or an ancestor directory")
        if ancestor == "/" or ancestor == "" or ancestor == "." then break end
        local parent = path.directory(ancestor)
        if not parent or parent == ancestor or parent == "" or parent == "." then break end
        ancestor = parent
    end
    c.rust = c.features.music or c.features.model_3d
    c.font = config.get("dora_web_builtin_font")
    if not c.font or c.font == "" then c.font = path.join(c.web, "preset-assets/Font/sarasa-mono-sc-regular.ttf") end
    c.complex = config.get("dora_web_love_complex_package")
    if c.complex == "" then c.complex = nil end
    return c
end
