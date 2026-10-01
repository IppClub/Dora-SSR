-- Run Studio acceptance with xmake's managed SDK, without building the Player.
function main(node, ...)
    import("core.project.project")
    import("lib.detect.find_tool")
    local root = os.projectdir()
    local tools = assert(project.target("dora-host-tools"), "managed host tools are not configured")
    local envs = tools:pkgenvs()
    envs.PATH = (envs.PATH or "") .. path.envsep() .. os.getenv("PATH")
    local python = assert(find_tool(os.host() == "windows" and "python" or "python3", {system = true}),
        "Studio compiler tests require host Python for Emscripten")
    envs.EMSDK_PYTHON = python.program
    -- The managed Go SDK can omit go.env. Fresh test runners still need
    -- standard module download defaults; preserve explicit user overrides.
    local go_proxy = os.getenv("GOPROXY")
    envs.GOPROXY = go_proxy and #go_proxy > 0 and go_proxy or "https://proxy.golang.org,direct"
    local go_sumdb = os.getenv("GOSUMDB")
    envs.GOSUMDB = go_sumdb and #go_sumdb > 0 and go_sumdb or "sum.golang.org"
    envs.STUDIO_EMCC = os.getenv("STUDIO_EMCC") or assert(find_tool("emcc", {envs = envs}), "managed emcc is missing").program
    envs.STUDIO_EMXX = os.getenv("STUDIO_EMXX") or assert(find_tool("em++", {envs = envs}), "managed em++ is missing").program
    -- Tutorials are generated/ignored assets, not files in a clean checkout.
    -- Use the canonical generator; missing documentation must still fail tests.
    os.vrunv(node, {path.join(root, "Docs/scripts/generate-language-docs.js")}, {curdir = root, envs = envs})
    cprint("${bright}Studio test compilers${clear}: %s; %s", envs.STUDIO_EMCC, envs.STUDIO_EMXX)
    os.execv(node, {...}, {curdir = root, envs = envs})
end
