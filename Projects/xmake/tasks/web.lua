task("dora-web")
    set_category("plugin")
    set_menu {
        usage = "xmake dora-web [--mode=release] [--profile=dora-preset] [--pthreads]",
        description = "Build and stage the production Web Player with xmake-managed Emscripten",
        options = {{nil, "mode", "kv", "release", "debug or release"},
            {nil, "profile", "kv", nil, "core, dora-preset or custom"},
            {nil, "pthreads", "k", nil, "Enable pthreads and the Love pthread Player"},
            {nil, "jobs", "kv", nil, "Parallel compilation jobs"}}
    }
    on_run(function ()
        import("core.base.option")
        local root = os.projectdir()
        local function env(name, default) return os.getenv("DORA_WEB_" .. name) or default end
        local function enabled(name, default) local v = env(name, default); return v == "1" or v == "ON" or v == "on" or v == "y" end
        local mode = option.get("mode") or "release"
        assert(mode == "debug" or mode == "release", "--mode must be debug or release")
        local profile = option.get("profile") or env("PROFILE", "dora-preset")
        local threads = option.get("pthreads") or enabled("PTHREADS", "0")
        local engine = enabled("BUILD_ENGINE", "1")
        local player = enabled("LINK_PLAYER", engine and "1" or "0")
        local probes = enabled("BUILD_LOVE_PROBE", engine and "1" or "0")
        local love_player = enabled("BUILD_LOVE_PTHREAD_PLAYER", threads and "1" or "0")
        local studio = enabled("STUDIO_AGENT_HOST", "0")
        local out = path.absolute(env("BUILD_DIR", path.join(root, "build/web-xmake", profile, threads and "pthread" or "single", mode)), root)
        local probe_dir = path.absolute(env("PACKAGE_DIR", path.join(root, "result/dora-web-build-probe")), root)
        local player_dir = path.absolute(env("PLAYER_PACKAGE_DIR", path.join(root, threads and "result/dora-web-player-pthreads" or "result/dora-web-player")), root)
        local love_dir = path.absolute(env("LOVE_PLAYER_PACKAGE_DIR", path.join(root, "result/love-pthread-player")), root)
        local function safe_directory(dir)
            local ancestor = root
            while true do
                assert(dir ~= ancestor, "output must not be the workspace or an ancestor: " .. dir)
                if ancestor == "/" or ancestor == "" or ancestor == "." then break end
                local parent = path.directory(ancestor)
                if not parent or parent == ancestor or parent == "" or parent == "." then break end
                ancestor = parent
            end
        end
        for _, dir in ipairs({out, probe_dir, player_dir, love_dir}) do safe_directory(dir) end
        local destinations = {probe_dir}
        if player then table.insert(destinations, player_dir) end
        if love_player then table.insert(destinations, love_dir) end
        for i, dir in ipairs(destinations) do
            assert(dir ~= out and not out:startswith(dir .. path.sep()), "staging must not contain build output")
            for j = i + 1, #destinations do
                local other = destinations[j]
                assert(dir ~= other and not dir:startswith(other .. path.sep()) and not other:startswith(dir .. path.sep()),
                    "Web staging directories must be separate")
            end
        end
        if studio then
            assert(not enabled("EXPERIMENTAL_MAIN_WORKER", "0"), "Studio host cannot enable experimental main worker")
            assert(os.getenv("DORA_WEB_BUILD_DIR") and os.getenv("DORA_WEB_PACKAGE_DIR") and os.getenv("DORA_WEB_PLAYER_PACKAGE_DIR") and engine and player,
                "Studio host requires explicit separate build/probe/player directories and a linked engine")
            local studio_dirs = {out, probe_dir, player_dir}
            if love_player then table.insert(studio_dirs, love_dir) end
            for _, dir in ipairs(studio_dirs) do
                assert(dir ~= path.join(root, "build/web") and not dir:startswith(path.join(root, "build/web-xmake"))
                    and dir ~= path.join(root, "result/dora-web-build-probe") and dir ~= path.join(root, "result/dora-web-player")
                    and dir ~= path.join(root, "result/dora-web-player-pthreads") and dir ~= path.join(root, "result/love-pthread-player"),
                    "Studio host cannot overwrite public Player output: " .. dir)
            end
        end
        local configdir = path.join(out, ".xmake-config")
        local jobs = option.get("jobs") or os.getenv("JOBS") or "6"
        local job_count = tonumber(jobs)
        assert(job_count and job_count > 0 and job_count == math.floor(job_count), "jobs must be a positive integer")
        local envs = {XMAKE_CONFIGDIR = configdir, BINARYEN_CORES = tostring(job_count)}
        local args = {"f", "-y", "-p", "wasm", "-a", "wasm32", "-m", mode, "--ccache=n", "--builddir=" .. path.join(out, "build"),
            "--dora_web_outdir=" .. out, "--dora_web_profile=" .. profile}
        for key, value in pairs({engine = engine, link_player = player, love_probe = probes, love_pthread_player = love_player,
            pthreads = threads, diagnostics = enabled("DIAGNOSTICS", "0"), studio_agent_host = studio,
            experimental_main_worker = not studio and enabled("EXPERIMENTAL_MAIN_WORKER", "0")}) do
            table.insert(args, "--dora_web_" .. key .. "=" .. (value and "y" or "n"))
        end
        for _, name in ipairs({"PHYSICS_2D", "ENTITY", "PLATFORMER", "BUILTIN_LIBS", "ML", "YUE", "LOVE", "MODEL_3D", "MUSIC"}) do
            table.insert(args, "--dora_web_feature_" .. name:lower() .. "=" .. env("FEATURE_" .. name, "AUTO"):upper())
        end
        for _, name in ipairs({"BUILTIN_FONT", "LOVE_COMPLEX_PACKAGE", "SDL2_PORT_SOURCE_DIR"}) do
            table.insert(args, "--dora_web_" .. name:lower() .. "=" .. env(name, ""))
        end
        os.vrunv(os.programfile(), args, {curdir = root, envs = envs})
        local targets = {"dora-web-build-probe"}
        if engine then table.insert(targets, "dora-web-engine") end
        if probes then table.join2(targets, {"dora-web-love-support", "dora-web-love-compile-probe", "dora-web-love-node-compile-probe"}) end
        if player then table.insert(targets, "dora-web-player") end
        if probes and player then
            for _, name in ipairs({"link", "graphics", "shader", "audio"}) do table.insert(targets, "dora-web-love-" .. name .. "-probe") end
            if env("LOVE_COMPLEX_PACKAGE", "") ~= "" then table.insert(targets, "dora-web-love-complex-probe") end
        end
        if love_player then table.insert(targets, "dora-web-love-pthread-player") end
        for _, target in ipairs(targets) do os.vrunv(os.programfile(), {"build", "-j", jobs, target}, {curdir = root, envs = envs}) end
        local function stage(destination, stem, extras)
            assert(destination ~= root and destination ~= out and destination ~= path.directory(root), "unsafe staging directory")
            os.mkdir(destination)
            for _, extension in ipairs({"html", "js", "wasm"}) do
                local file = path.join(out, stem .. "." .. extension)
                assert(os.isfile(file), "missing Web output: " .. file)
                os.cp(file, destination)
            end
            os.cp(path.join(out, stem .. ".html"), path.join(destination, "index.html"))
            for _, file in ipairs(extras or {}) do
                assert(os.exists(path.join(out, file)), "missing Web output: " .. file)
                if file == "assets" and os.isdir(path.join(destination, file)) then
                    assert(os.isfile(path.join(destination, "dora-web-manifest.json")), "refusing to replace an unrecognized assets directory")
                    os.tryrm(path.join(destination, file))
                end
                os.cp(path.join(out, file), destination)
            end
            local worker = stem .. ".worker.js"
            if os.isfile(path.join(out, worker)) then os.cp(path.join(out, worker), destination)
            else os.tryrm(path.join(destination, worker)) end
            cprint("${green}Web package: %s${clear}", destination)
        end
        stage(probe_dir, "dora-player")
        if player then stage(player_dir, "dora-player-runtime", {"dora-player-runtime.data", "dora-web-manifest.json", "dora-web-features.json", "dora-audio-mixer.wasm", "audio-worklet.js", "assets"}) end
        if love_player then stage(love_dir, "love-pthread-player", {"love-pthread-player.data", "dora-audio-mixer.wasm", "audio-worklet.js"}) end
    end)
task_end()

task("dora-web-env")
    set_category("plugin")
    set_menu {usage = "xmake dora-web-env", description = "Install managed Web tools and check the host environment"}
    on_run(function ()
        local root = os.projectdir()
        local directory = path.join(root, "build/web-env")
        local envs = {XMAKE_CONFIGDIR = path.join(directory, ".xmake-config")}
        os.vrunv(os.programfile(), {"f", "-y", "-p", "wasm", "-a", "wasm32", "-m", "release",
            "--builddir=" .. path.join(directory, "build"), "--dora_web_outdir=" .. path.join(directory, "artifacts"),
            "--dora_web_engine=n", "--dora_web_link_player=n", "--dora_web_love_probe=n"}, {curdir = root, envs = envs})
        os.execv(os.programfile(), {"doctor", "--platform=wasm"}, {curdir = root, envs = envs})
    end)
task_end()
