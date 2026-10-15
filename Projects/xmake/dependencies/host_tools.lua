local dora_host_arch = os.arch()
-- Install the native xmake distribution on Windows ARM64. xmake resolves
-- executable/toolchain packages against its process host architecture, so
-- an emulated x64 xmake cannot select ARM64 Rust via add_requires.arch.

add_requires("go", {
    alias = "dora_go",
    host = true,
    system = false,
    plat = os.host(),
    arch = dora_host_arch
})

add_requires("rust", {
    alias = "dora_rust",
    host = true,
    system = false,
    plat = os.host(),
    arch = dora_host_arch
})

add_requires("rustup", {
    alias = "dora_rustup",
    host = true,
    system = false,
    plat = os.host(),
    arch = dora_host_arch
})

if is_plat("wasm") then
    add_requires("dora-emscripten", {
        alias = "dora_emscripten",
        host = true,
        system = false,
        plat = os.host(),
        -- xmake-repo does not publish a Windows ARM64 Emscripten package yet.
        arch = os.host() == "windows" and "x64" or dora_host_arch
    })
end

target("dora-host-tools")
    -- See the root dora-build-info target: IDE generation needs a product
    -- kind even though normal builds intentionally keep this target phony.
    set_kind(os.getenv("XMAKE_IN_PROJECT_GENERATOR") and "binary" or "phony")
    set_default(false)
    add_packages("dora_go", "dora_rust", "dora_rustup")
    if is_plat("wasm") then
        add_packages("dora_emscripten")
    end
    on_build(function (target)
        import("lib.detect.find_tool")
        local envs = target:pkgenvs()
        cprint("${bright}xmake-managed host tools${clear}")
        os.execv("go", {"version"}, {envs = envs})
        os.execv("rustc", {"--version"}, {envs = envs})
        os.execv("cargo", {"--version"}, {envs = envs})
        envs.RUSTUP_AUTO_INSTALL = "0"
        os.execv("rustup", {"--version"}, {envs = envs})
        if is_plat("wasm") then
            local python = assert(find_tool(os.host() == "windows" and "python" or "python3", {force = true}),
                "a host Python interpreter is required to run Emscripten")
            envs.EMSDK_PYTHON = python.program
            envs.PATH = envs.PATH and (envs.PATH .. path.envsep() .. os.getenv("PATH")) or os.getenv("PATH")
            os.execv("emcc", {"--version"}, {envs = envs})
        end
    end)
target_end()
