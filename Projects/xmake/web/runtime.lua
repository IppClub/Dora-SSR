target("dora-web-rust")
    set_kind("phony")
    set_default(false)
    add_packages("dora_rustup", "dora_emscripten")
    on_build(function (t)
        import("core.project.depend")
        local c = import("Projects.xmake.web.config", {rootdir = os.projectdir(), anonymous = true})()
        local output = path.join(c.out, "libdora_runtime.a")
        local inputs = os.files(path.join(c.root, "Source/Rust/src/**.rs"))
        table.join2(inputs, {path.join(c.root, "Source/Rust/Cargo.toml"), path.join(c.root, "Source/Rust/Cargo.lock")})
        table.join2(inputs, os.files(path.join(c.root, "Tools/dora-rust/dora/src/**.rs")))
        table.join2(inputs, os.files(path.join(c.root, "Tools/dora-rust/dora/Cargo*.toml")))
        table.insert(inputs, path.join(c.root, "Projects/xmake/web/runtime.lua"))
        local envs = t:pkgenvs()
        envs.PATH = (envs.PATH or "") .. path.envsep() .. os.getenv("PATH")
        local rust_version = os.iorunv("rustc", {"--version"}, {envs = envs}):trim()
        local emcc_version = os.iorunv("emcc", {"--version"}, {envs = envs}):match("[^\r\n]+")
        depend.on_changed(function ()
            envs.CARGO_TARGET_DIR = path.join(c.out, "cargo")
            envs.RUSTC_WRAPPER = ""
            envs.RUSTFLAGS = "--remap-path-prefix=" .. c.root .. "=."
            local sysroot = os.iorunv("rustc", {"--print", "sysroot"}, {envs = envs}):trim()
            envs.RUSTFLAGS = envs.RUSTFLAGS .. " --remap-path-prefix=" .. sysroot .. "=/rust-toolchain"
            local rust_home = os.iorunv("rustup", {"show", "home"}, {envs = envs}):trim()
            envs.RUSTFLAGS = envs.RUSTFLAGS .. " --remap-path-prefix=" .. path.directory(rust_home) .. "=/build-user"
            os.vrunv("rustup", {"target", "add", "wasm32-unknown-emscripten"}, {envs = envs})
            local args = {"build", "--locked", "--release", "--no-default-features", "--target", "wasm32-unknown-emscripten"}
            if c.features.music then table.join2(args, {"--features", "music"}) end
            if c.pthreads then
                os.vrunv("rustup", {"component", "add", "rust-src"}, {envs = envs})
                table.join2(args, {"-Z", "build-std=std,panic_abort"})
                envs.RUSTC_BOOTSTRAP = "1"
                envs.RUSTFLAGS = envs.RUSTFLAGS .. " -C target-feature=+atomics,+bulk-memory,+mutable-globals"
            end
            os.vrunv("cargo", args, {envs = envs, curdir = path.join(c.root, "Source/Rust")})
            os.cp(path.join(envs.CARGO_TARGET_DIR, "wasm32-unknown-emscripten/release/libdora_runtime.a"), output)
        end, {dependfile = path.join(c.out, "rust.d"), files = inputs, values = {tostring(c.features.music), tostring(c.pthreads), rust_version, emcc_version}, changed = not os.isfile(output)})
    end)
target_end()

target("dora-web-main-worker-audio")
    set_kind("object")
    set_default(false)
    set_toolchains("emcc@dora_emscripten")
    add_packages("dora_emscripten")
    on_load(function (t)
        local c = import("Projects.xmake.web.config", {rootdir = os.projectdir(), anonymous = true})()
        if not c.experimental_main_worker then return end
        local sdl = assert(get_config("dora_web_sdl2_port_source_dir"), "main worker requires --dora_web_sdl2_port_source_dir")
        local source = path.join(sdl, "src/audio/emscripten/SDL_emscriptenaudio.c")
        local data = io.readfile(source)
        assert(data:find("this->spec.freq = EM_ASM_INT({", 1, true), "unexpected SDL audio source")
        local output = path.join(c.out, "studio-sdl2-audio.c")
        os.mkdir(c.out)
        local patched = data:gsub("this%->spec%.freq = EM_ASM_INT%(%{", "this->spec.freq = MAIN_THREAD_EM_ASM_INT({")
        if not os.isfile(output) or io.readfile(output) ~= patched then io.writefile(output, patched) end
        t:add("files", output)
        t:add("includedirs", path.join(sdl, "include"), path.join(sdl, "src/audio/emscripten"))
        t:add("cxflags", "-pthread", "-sUSE_SDL=2", {force = true})
    end)
target_end()
