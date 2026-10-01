option("dora_web_profile")
    set_default("dora-preset")
    set_values("core", "dora-preset", "custom")
    set_showmenu(true)
option_end()
for _, feature in ipairs({"physics_2d", "entity", "platformer", "builtin_libs", "ml", "yue", "love", "model_3d", "music"}) do
    option("dora_web_feature_" .. feature)
        set_default("AUTO")
        set_values("AUTO", "ON", "OFF")
        set_showmenu(true)
    option_end()
end
for name, default in pairs({engine = true, link_player = true, love_probe = true,
    love_pthread_player = false, diagnostics = false, studio_agent_host = false,
    experimental_main_worker = false}) do
    option("dora_web_" .. name)
        set_default(default)
        set_showmenu(true)
    option_end()
end
for _, name in ipairs({"outdir", "builtin_font", "love_complex_package", "sdl2_port_source_dir"}) do
    option("dora_web_" .. name)
        set_showmenu(true)
    option_end()
end
