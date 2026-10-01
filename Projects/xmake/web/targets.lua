local ROOT = os.projectdir()
local function setup(kind, callback)
    set_kind(kind)
    set_default(false)
    set_languages("gnu11", "cxx20")
    set_toolchains("emcc@dora_emscripten")
    add_packages("dora_emscripten")
    set_optimize(is_mode("release") and "fastest" or "none")
    on_load(function (target)
        local c = import("Projects.xmake.web.config", {rootdir = os.projectdir(), anonymous = true})()
        c.ensure = assert
        local m = import("Projects.xmake.web.manifest", {rootdir = os.projectdir(), anonymous = true})()
        -- Relative linker output avoids embedding the host's absolute path
        -- in Emscripten's generated PACKAGE_NAME/datafile dependency names.
        target:set("targetdir", path.relative(c.out, c.root))
        target:data_set("dora.web.config", c)
        target:data_set("dora.web.inputs", {})
        if c.mode == "release" then target:add("defines", "NDEBUG") end
        if c.mode == "debug" then target:set("symbols", "debug") end
        target:add("cxflags", "-ffile-prefix-map=" .. c.root .. "=.",
            "-fdebug-prefix-map=" .. c.root .. "=.", "-Wno-deprecated-declarations", "-Wno-deprecated-pragma", "-Wno-macro-redefined", {force = true})
        callback(target, c, m, {import = import, assert = assert})
        if target:kind() == "binary" and target:targetfile():endswith(".html") then
            target:add("ldflags", "--emit-symbol-map", {force = true})
        end
    end)
end
local function files(t, c, list, options)
    for _, source in ipairs(list) do
        if source:startswith("@testweb@") then
            c.ensure(c.testweb, "test targets require xmake dora-web --tests")
            source = source:gsub("@testweb@", c.testweb)
        end
        t:add("files", path.absolute(source, c.root), options)
    end
end
local function engine_flags(t, c)
    t:add("cxflags", "-fwasm-exceptions", {force = true})
    t:add("defines", "BX_CONFIG_DEBUG=0", "BGFX_GL_CONFIG_TEXTURE_READ_BACK_EMULATION=1", "DORA_DEBUG=0",
        "DORA_EMSCRIPTEN", "DORA_NO_WA", "DORA_TEST=0", "DORA_WEB_MINIMAL", "DORA_WEB_TASK_AUTORELEASE_POOL",
        "WITH_SDL2_STATIC", "SPDLOG_FMT_EXTERNAL", "BGFX_CONFIG_RENDERER_OPENGLES=30", "d_m3HasWASI", "SQLITE_OMIT_LOAD_EXTENSION")
    if c.pthreads then t:add("cxflags", "-pthread", {force = true}) end
    if c.studio_agent_host then t:add("defines", "DORA_WEB_STUDIO_AGENT_HOST") end
    if c.features.music then t:add("defines", "DORA_WEB_MUSIC") end
    if c.features.yue then t:add("defines", "DORA_WEB_YUE") end
    for _, name in ipairs({"physics_2d", "ml", "entity", "platformer", "love"}) do
        if not c.features[name] then t:add("defines", "DORA_WEB_NO_" .. name:upper()) end
    end
    t:add("defines", c.features.model_3d and "DORA_WEB_MODEL_3D" or "DORA_WEB_NO_MODEL_3D")
    if not c.features.model_3d then t:add("defines", "DORA_NO_3D_PHYSICS") end
    t:add("includedirs", path.join(c.out, "bgfx-embedded"))
    for _, dir in ipairs({"Source/3rdParty/SDL2/include", "Source/3rdParty/bgfx/include", "Source/3rdParty/bimg/include",
        "Source/3rdParty/bx/include", "Source/3rdParty/bx/include/compat/emscripten", "Source", "Source/3rdParty",
        "Source/3rdParty/Love/src", "Source/3rdParty/Love/src/modules", "Source/3rdParty/JoltPhysics",
        "Source/3rdParty/Lua", "Source/3rdParty/LuaSocket/src", "Source/3rdParty/Zip", "Source/3rdParty/Zip/zlib",
        "Source/3rdParty/soloud", "Source/3rdParty/lodepng", "Source/3rdParty/imgui", "Source/3rdParty/implot",
        "Source/3rdParty/font", "Source/3rdParty/sqlite", "Source/3rdParty/dragonBones", "Source/3rdParty/wasm3",
        "Source/3rdParty/Effekseer", "Source/3rdParty/theora/include", "Source/3rdParty/theora/Source"}) do
        t:add("includedirs", path.join(c.root, dir))
    end
end
local function linkflag(t, c, flag)
    flag = flag:gsub("@root@", c.root):gsub("@web@", c.web):gsub("@out@", c.out)
    if flag:find("@testweb@", 1, true) then
        c.ensure(c.testweb, "test assets require xmake dora-web --tests")
        flag = flag:gsub("@testweb@", c.testweb)
    end
    local option, argument = flag:match("^(%-%-[%w%-]+) (.+)$")
    if option then
        -- Keep each option/value pair atomic: xmake deduplicates bare flags,
        -- which would collapse repeated --pre-js/--preload-file switches.
        t:add("ldflags", option .. "=" .. argument, {force = true})
        local input = argument:match("^(.-)@/") or argument
        local inputs = t:data("dora.web.inputs")
        if os.isdir(input) then table.join2(inputs, os.files(path.join(input, "**"))) else table.insert(inputs, input) end
    else
        t:add("ldflags", flag, {force = true})
    end
end
local function thread_link(t, c)
    if c.pthreads then t:add("ldflags", "-pthread", "-sUSE_PTHREADS=1", "-sPTHREAD_POOL_SIZE=4", {force = true})
    else t:add("ldflags", "-sUSE_PTHREADS=0", {force = true}) end
end
local function executable_hooks()
    before_link(function (target)
        import("core.project.depend")
        local inputs = target:data("dora.web.inputs")
        -- xmake's linker tracks objects, not pre-js/preload/shell inputs.
        -- Invalidate only the generated binary when those inputs change.
        depend.on_changed(function () os.tryrm(target:targetfile()) end, {
            dependfile = target:dependfile(target:targetfile() .. ".assets"), files = inputs,
            values = target:get("ldflags"), changed = not os.isfile(target:targetfile())})
    end)
end

target("dora-web-prepare")
    set_kind("phony")
    set_default(false)
    add_deps("dora-lua-bindings")
    add_packages("dora_emscripten")
    on_build(function (target)
        import("Projects.xmake.web.prepare", {rootdir = os.projectdir(), anonymous = true})(target)
    end)
target_end()

target("dora-web-engine")
    add_deps("dora-web-prepare")
    setup("object", function (t, c, m, api)
        engine_flags(t, c)
        local sources = api.import("Projects.xmake.manifests.engine", {rootdir = c.root, anonymous = true})().sources
        local excluded = { ["Source/Lua/LuaFromXml.cpp"] = not c.studio_agent_host,
            ["Source/Lua/LuaBinding.cpp"] = true, ["Source/Lua/LuaCode.cpp"] = true,
            ["Source/Lua/TealCompiler.cpp"] = true, ["Source/Lua/LuaManual.cpp"] = true,
            ["Source/Wasm/WasmRuntime.cpp"] = true }
        for _, s in ipairs(sources) do
            local reject = excluded[s] or s:find("/Test/", 1, true) or s:find("/Lua/Xml/", 1, true)
                or s:match("^Source/Love/[^/]+%.cpp$") or s:match("/Node/VideoNode%.cpp$") or s:match("/Node/TIC80Node%.cpp$")
                or s:match("/Http/HttpServer%.cpp$") or s:match("/Http/XrtNetwork%.c$") or s:match("/nfd/nfd_portal%.cpp$")
                or s:find("/soloud/backend/sdl/", 1, true)
            for _, dir in ipairs({"tic80", "JoltPhysics", "wasm3", "yarnflow"}) do reject = reject or s:find("/3rdParty/" .. dir .. "/", 1, true) end
            for feature, dirs in pairs({ml = {"/ML/", "/3rdParty/ml/"}, platformer = {"/Platformer/"}, entity = {"/Entity/"}, yue = {"/3rdParty/yuescript/"}}) do
                if not c.features[feature] then for _, dir in ipairs(dirs) do reject = reject or s:find(dir, 1, true) end end
            end
            if not c.features.model_3d then
                reject = reject or s:match("/Physics/Jolt[^/]+%.cpp$") or s:match("/Cache/Model3DCache%.cpp$") or s:match("/Render/Camera3D%.cpp$")
                for _, name in ipairs({"Node3D", "Surface3D", "Light3D", "Model3D", "Visual3D", "View3D"}) do reject = reject or s:match("/Node/" .. name .. "%.cpp$") end
                if not c.features.physics_2d then reject = reject or s:find("/Physics/", 1, true) end
            end
            if not reject then
                local options
                if s:match("/Physics/Jolt") then options = {force = {defines = {"JPH_NO_FORCE_INLINE"}, cxxflags = {"-fno-rtti", "-fno-exceptions", "-ffp-contract=off"}}} end
                t:add("files", path.join(c.root, s), options)
            end
        end
        files(t, c, {"Source/Lua/LuaBindingWeb.cpp", "Source/Lua/LuaCodeWeb.cpp"}, {always_added = true})
        files(t, c, {"Source/Wasm/CallStack.cpp", "Source/Web/WebTaskQueue.cpp", "Source/Web/WebAssetLoader.cpp", "Source/Web/WebHttp.cpp",
            "Source/Lua/LuaManual.cpp", "Source/Web/WebXrtNetwork.cpp", "Source/3rdParty/soloud/backend/sdl2_static/soloud_sdl2_static.cpp",
            "Source/3rdParty/LuaSocket/src/compat.c", "Source/3rdParty/LuaSocket/src/mime.c"})
        if c.diagnostics then t:add("files", path.join(c.root, "Source/Render/RenderTarget.cpp"), {defines = {"DORA_WEB_READBACK_TRACE"}}) end
    end)
target_end()

target("dora-web-link-deps")
    setup("object", function (t, c, m)
        t:add("cxflags", "-fwasm-exceptions", {force = true})
        if c.pthreads then t:add("cxflags", "-pthread", {force = true}) end
        t:add("cxxflags", "-fno-rtti", {force = true})
        t:add("defines", "BX_CONFIG_DEBUG=0", "BGFX_GL_CONFIG_TEXTURE_READ_BACK_EMULATION=1", "DORA_EMSCRIPTEN",
            "BGFX_CONFIG_RENDERER_OPENGLES=30", "BGFX_CONFIG_MAX_FRAME_BUFFERS=256", "DORA_SHADERC_WEB_RUNTIME",
            "SHADERC_CONFIG_CLI=0", "SHADERC_CONFIG_GLSL=1", "SHADERC_CONFIG_HLSL=0", "SHADERC_CONFIG_METAL=0", "SHADERC_CONFIG_SPIRV=0")
        for _, dir in ipairs({"Source/3rdParty/bimg/3rdparty", "Source", "Source/3rdParty", "Source/3rdParty/bx/include",
            "Source/3rdParty/bx/3rdparty", "Source/3rdParty/bx/include/compat/emscripten", "Source/3rdParty/bimg/include",
            "Source/3rdParty/bimg/3rdparty/astc-encoder/include", "Source/3rdParty/bgfx/include", "Source/3rdParty/bgfx/3rdparty",
            "Source/3rdParty/bgfx/3rdparty/fcpp", "Source/3rdParty/bgfx/3rdparty/glsl-optimizer/include",
            "Source/3rdParty/bgfx/3rdparty/glsl-optimizer/src", "Source/3rdParty/bgfx/3rdparty/glsl-optimizer/src/mesa",
            "Source/3rdParty/bgfx/3rdparty/glsl-optimizer/src/glsl", "Source/3rdParty/bgfx/tools/shaderc",
            "Source/3rdParty/theora/include", "Source/3rdParty/theora/Source", "Source/3rdParty/Zip"}) do t:add("includedirs", path.join(c.root, dir)) end
        files(t, c, m.link)
        files(t, c, {"Source/3rdParty/bx/src/*.cpp", "Source/3rdParty/bimg/src/*.cpp", "Source/3rdParty/bimg/3rdparty/astc-encoder/source/*.cpp"})
        files(t, c, {"Source/3rdParty/bgfx/3rdparty/fcpp/*.c|usecpp.c"}, {defines = {"UNIX"}})
        files(t, c, {"Source/3rdParty/bgfx/3rdparty/glsl-optimizer/src/**.cpp|node/**|glsl/main.cpp", "Source/3rdParty/bgfx/3rdparty/glsl-optimizer/src/**.c|node/**"})
    end)
target_end()

target("dora-web-love-support")
    add_deps("dora-web-prepare")
    setup("static", function (t, c, m)
        t:add("includedirs", path.join(c.root, "Source/3rdParty/Love/src/modules"))
        engine_flags(t, c)
        t:add("includedirs", path.join(c.root, "Source/3rdParty/Love/src/libraries"))
        t:add("defines", "LOVE_PROXY_USERVALUES=5")
        files(t, c, m.love)
    end)
target_end()
for _, name in ipairs({"runtime", "compile-probe", "node-compile-probe"}) do
    target("dora-web-love-" .. name)
        add_deps("dora-web-prepare")
        local variant = name
        setup("object", function (t, c)
            engine_flags(t, c)
            if variant ~= "runtime" then t:add("defines", "DORA_WEB_LOVE_PROBE") end
            if variant ~= "node-compile-probe" then files(t, c, {"Source/Love/LoveRuntime.cpp", "Source/Love/LoveVideoSources.cpp"}) end
            if variant ~= "compile-probe" then files(t, c, {"Source/Love/LoveNode.cpp"}) end
        end)
    target_end()
end

target("dora-web-audio-mixer")
    setup("binary", function (t, c)
        t:set("filename", "dora-audio-mixer.wasm")
        t:add("includedirs", path.join(c.root, "Source/3rdParty/soloud"))
        t:add("defines", "WITH_NULL")
        t:add("cxflags", "-O2", {force = true})
        files(t, c, {"Source/Web/AudioMixer.cpp", "Source/3rdParty/soloud/core/*.cpp", "Source/3rdParty/soloud/filter/*.cpp",
            "Source/3rdParty/soloud/audiosource/wav/soloud_wav.cpp", "Source/3rdParty/soloud/audiosource/wav/soloud_wavstream.cpp",
            "Source/3rdParty/soloud/audiosource/wav/dr_impl.cpp", "Source/3rdParty/soloud/audiosource/wav/stb_vorbis.c"})
        t:add("ldflags", "-O2", "--no-entry", "-sSTANDALONE_WASM=1", "-sFILESYSTEM=0", "-sALLOW_MEMORY_GROWTH=1",
            "-sINITIAL_MEMORY=32MB", "-sMAXIMUM_MEMORY=256MB", "-sSTACK_SIZE=256KB", "-sEXPORTED_FUNCTIONS=['_malloc','_free']", {force = true})
    end)
    after_build(function (t)
        local c = t:data("dora.web.config")
        os.cp(path.join(c.web, "audio-worklet.js"), c.out)
    end)
target_end()

target("dora-web-build-probe")
    setup("binary", function (t, c)
        t:set("filename", "dora-player.html")
        files(t, c, {"Projects/Web/WebBuildProbe.cpp", "Source/Web/WebTaskQueue.cpp"})
        t:add("includedirs", path.join(c.root, "Source"))
        t:add("cxflags", "-fwasm-exceptions", {force = true})
        for _, flag in ipairs({"-fwasm-exceptions", "-sALLOW_MEMORY_GROWTH=1", "-sENVIRONMENT=web,node", "-sEXIT_RUNTIME=0",
            "-sEXPORTED_FUNCTIONS=['_main','_dora_web_build_probe']", "-sEXPORTED_RUNTIME_METHODS=['ccall']", "--shell-file @web@/shell.html"}) do linkflag(t, c, flag) end
    end)
    executable_hooks()
target_end()

target("dora-web-player")
    add_deps("dora-web-engine", "dora-web-link-deps", "dora-web-audio-mixer")
    setup("binary", function (t, c)
        t:set("filename", "dora-player-runtime.html")
        if c.features.love then t:add("deps", "dora-web-love-runtime", "dora-web-love-support") end
        if c.rust then t:add("deps", "dora-web-rust"); t:add("links", path.join(c.out, "libdora_runtime.a")) end
        for _, flag in ipairs({"--ignore-dynamic-linking", "-fwasm-exceptions", "-sSUPPORT_LONGJMP=wasm", "-sUSE_SDL=2", "-sUSE_WEBGL2=1",
            "-sFULL_ES3=1", "-sALLOW_MEMORY_GROWTH=1", "-sSTACK_SIZE=8MB", "-sINITIAL_MEMORY=64MB", "-sMAXIMUM_MEMORY=1GB", "-sEXIT_RUNTIME=0",
            "-sFILESYSTEM=1", "-lidbfs.js", "-sFETCH=1", "-sFETCH_STREAMING=1", "-sEXPORTED_RUNTIME_METHODS=['ccall','cwrap','FS','IDBFS']",
            "--pre-js @out@/dora-web-features.js", "--pre-js @web@/web-audio.js", "--pre-js @web@/web-platform.js",
            "--pre-js @web@/web-network.js", "--pre-js @web@/web-package.js", "--pre-js @web@/web-loader.js",
            "--preload-file @web@/runtime-assets@/builtin", "--shell-file @web@/player-shell.html"}) do linkflag(t, c, flag) end
        local exports = "['_main','_dora_web_stop','_dora_web_set_suspended','_dora_web_release_input','_dora_web_asset_complete'"
        if c.studio_agent_host then exports = exports .. ",'_dora_web_agent_request'" end
        linkflag(t, c, "-sEXPORTED_FUNCTIONS=" .. exports .. "]")
        thread_link(t, c)
        if c.features.builtin_libs then
            for _, module in ipairs({"BodyEx.lua", "Config.lua", "DoraX.lua", "InputManager.lua", "Utils.lua", "lualib_bundle.lua", "utf-8.lua",
                "UI/Control/Basic/CircleButton.lua", "UI/Control/Basic/ScrollArea.lua", "UI/View/Control/Basic/ButtonBase.lua",
                "UI/View/Control/Basic/CircleButton.lua", "UI/View/Control/Basic/ScrollArea.lua", "UI/View/Shape/Circle.lua", "UI/View/Shape/LineCircle.lua",
                "UI/View/Shape/LineRect.lua", "UI/View/Shape/Rectangle.lua", "UI/View/Shape/SolidCircle.lua", "UI/View/Shape/SolidRect.lua", "UI/View/Shape/Star.lua"}) do
                linkflag(t, c, "--preload-file @root@/Assets/Script/Lib/" .. module .. "@/builtin/Script/Lib/" .. module)
            end
            linkflag(t, c, "--preload-file " .. c.font .. "@/builtin/Font/sarasa-mono-sc-regular.ttf")
        end
        if c.diagnostics then t:add("ldflags", "-sASSERTIONS=1", "--profiling-funcs", {force = true}) end
        if c.experimental_main_worker then
            t:add("deps", "dora-web-main-worker-audio")
            t:add("ldflags", "-sPROXY_TO_PTHREAD=1", "-sOFFSCREENCANVAS_SUPPORT=1", "-sOFFSCREENCANVASES_TO_PTHREAD=#canvas", {force = true})
        end
    end)
    executable_hooks()
target_end()

-- Probe descriptors carry only exports, JS adapters and fixture paths.
-- Their engine and vendor source lists are shared with the production Player.
if has_config("dora_web_love_probe") then
for _, name in ipairs({"link-probe", "graphics-probe", "shader-probe", "audio-probe", "pthread-player", "complex-probe"}) do
    target("dora-web-love-" .. name)
        add_deps("dora-web-engine", "dora-web-link-deps", "dora-web-love-support", "dora-web-love-compile-probe", "dora-web-love-node-compile-probe")
        local variant = name
        setup("binary", function (t, c, m, api)
            engine_flags(t, c)
            t:add("defines", "DORA_WEB_LOVE_PROBE")
            local spec
            for _, candidate in ipairs(m.probes) do if candidate.name == t:name() then spec = candidate end end
            api.assert(spec, "missing Web probe descriptor: " .. t:name())
            t:set("filename", spec.output .. ".html")
            files(t, c, {spec.source})
            for _, flag in ipairs(spec.flags) do
                if (variant == "pthread-player" or variant == "complex-probe") and flag:startswith("-sEXPORTED_RUNTIME_METHODS=") then
                    flag = "-sEXPORTED_RUNTIME_METHODS=['ccall','cwrap','UTF8ToString','FS','IDBFS']"
                end
                if c.diagnostics or (flag ~= "-sASSERTIONS=1" and flag ~= "--profiling-funcs") then linkflag(t, c, flag) end
            end
            thread_link(t, c)
            if c.diagnostics then t:add("ldflags", "-sASSERTIONS=1", "--profiling-funcs", {force = true}) end
            if variant == "audio-probe" or variant == "pthread-player" or variant == "complex-probe" then
                t:add("deps", "dora-web-audio-mixer")
                linkflag(t, c, "--pre-js @web@/web-audio.js")
            end
            if c.rust then t:add("deps", "dora-web-rust"); t:add("links", path.join(c.out, "libdora_runtime.a")) end
        end)
        executable_hooks()
    target_end()
end
end

includes("runtime.lua")
target("Dora")
    set_kind("phony")
    set_default(false)
    add_deps("dora-web-player")
target_end()
