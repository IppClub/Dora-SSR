function main(target, sync)
    import("core.project.config")
    import("lib.detect.find_tool")
    local root = os.projectdir()
    local envs = target:pkgenvs()
    envs.PATH = (envs.PATH or "") .. path.envsep() .. os.getenv("PATH")
    envs.GOPROXY = os.getenv("GOPROXY") or "https://proxy.golang.org,direct"
    local go = assert(find_tool("go", {envs = envs}), "managed Go toolchain not found")
    local python = sync and assert(find_tool(os.host() == "windows" and "python" or "python3"), "Wa source sync requires Python")
    local source = sync and path.absolute(assert(config.get("dora_wa_sync_source"), "--source is required"), root)
        or path.join(root, "Source/3rdParty/Wa/Source")
    assert(os.isfile(path.join(source, "go.mod")), "Wa source repository not found: " .. source)
    if sync then
        assert(source ~= root and source ~= path.join(root, "Source/3rdParty/Wa/Source"), "sync source must be an upstream Wa checkout")
        if config.get("dora_wa_sync_dryrun") then
            cprint("Wa source: %s; destination: %s", source, path.join(root, "Source/3rdParty/Wa/Source"))
            return
        end
    end
    local stage = os.tmpfile() .. "-dora-wa"
    try {function ()
        if sync then
            os.execv(python.program, {path.join(root, "Projects/xmake/tools/wa/collect_source.py"), source, stage, "wa-lang.org/wa"}, {envs = envs})
            os.execv(go.program, {"mod", "vendor"}, {curdir = stage, envs = envs})
            os.execv(python.program, {path.join(root, "Projects/xmake/tools/wa/collect_vendor.py")}, {curdir = stage, envs = envs})
            local destination = path.join(root, "Source/3rdParty/Wa/Source")
            local backup = path.join(root, "build/wa-sync-backups", os.date("%Y%m%d-%H%M%S"))
            assert(not os.exists(backup), "Wa backup already exists: " .. backup)
            os.mkdir(path.directory(backup))
            os.mv(destination, backup)
            local replaced = try {function () os.mv(stage, destination); return true end}
            if not replaced then os.mv(backup, destination); raise("Wa replacement failed; original restored") end
            cprint("${green}Wa source synchronized; previous source retained at %s${clear}", backup)
        else
            os.cp(source, stage)
            os.mv(path.join(stage, "wa.gomobile"), path.join(stage, "wa.go"))
            os.mv(path.join(stage, "main.go"), path.join(stage, "main.go.native"))
            local output = path.absolute(config.get("dora_wa_outdir") or path.join(root, "result/dora-wa-web"), root)
            os.mkdir(output)
            envs.GOOS = "js"; envs.GOARCH = "wasm"; envs.CGO_ENABLED = "0"; envs.GOFLAGS = "-mod=mod"
            envs.GOCACHE = os.getenv("DORA_WA_GOCACHE") or path.join(root, "build/wa-go-cache")
            os.execv(go.program, {"build", "-buildvcs=false", "-trimpath", "-ldflags=-s -w", "-o", path.join(output, "dora-wa.wasm"), "./web"}, {curdir = stage, envs = envs})
            local goroot = os.iorunv(go.program, {"env", "GOROOT"}, {envs = envs}):trim()
            local runtime = path.join(goroot, "lib/wasm/wasm_exec.js")
            if not os.isfile(runtime) then runtime = path.join(goroot, "misc/wasm/wasm_exec.js") end
            assert(os.isfile(runtime), "Go wasm_exec.js is missing")
            os.cp(runtime, path.join(output, "wasm_exec.js"))
            cprint("${green}Wa Web module: %s${clear}", output)
        end
    end, finally = function () os.tryrm(stage) end}
end
