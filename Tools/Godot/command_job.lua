-- Run a bounded job, retaining logs and terminating only its owned process tree.
function run_command(command, log, timeout, options)
    local C = import("common", {rootdir = os.scriptdir()})
    local temporary = os.tmpfile() .. "-command-job"
    os.mkdir(temporary); os.mkdir(path.directory(log))
    options = options or {}
    local pidfile = path.join(temporary, "pid")
    local program, arguments
    if os.host() == "windows" then
        local request = path.join(temporary, "request.json")
        C.save(request, {program = command[1], arguments = os.args(table.slice(command, 2)), pidfile = pidfile})
        local script = path.join(temporary, "job.ps1")
        C.write(script, [[param([string]$Request)
$ErrorActionPreference = 'Stop'
$job = Get-Content -LiteralPath $Request -Raw -Encoding UTF8 | ConvertFrom-Json
$p = Start-Process -FilePath $job.program -ArgumentList $job.arguments -NoNewWindow -PassThru
[IO.File]::WriteAllText($job.pidfile, [string]$p.Id)
$p.WaitForExit()
exit $p.ExitCode
]])
        program, arguments = "powershell", {"-NoProfile", "-ExecutionPolicy", "Bypass", "-File", script, request}
    else
        -- Bash monitor mode gives this one job its own process group without a setsid dependency.
        program, arguments = "bash", table.join({"-c", 'set -m; pidfile="$1"; shift; "$@" & job=$!; printf "%s" "$job" > "$pidfile"; wait "$job"; exit "$?"', "dora-job", pidfile}, command)
    end
    local output = assert(io.open(log, "w"))
    local success, errors = true, nil
    try {function () os.execv(program, arguments, {envs = options.env, curdir = options.cwd, timeout = timeout and math.floor(timeout * 1000), stdout = output, stderr = output}) end,
        catch {function (message) success = false; errors = message end},
        finally {function ()
            output:close()
            if not success and os.isfile(pidfile) then
                local pid = C.read(pidfile):trim()
                if pid:match("^%d+$") then
                    try {function ()
                        if os.host() == "windows" then os.runv("taskkill", {"/PID", pid, "/T", "/F"})
                        else os.runv("kill", {"-KILL", "--", "-" .. pid}) end
                    end}
                end
            end
            os.tryrm(temporary)
        end}}
    assert(success, "Process job failed or timed out; see " .. log .. ": " .. tostring(errors))
    local text = C.read(log):gsub("\27%[[%d;]*m", "")
    assert(not ("\n" .. text):match("\n%s*SCRIPT ERROR:") and not ("\n" .. text):match("\n%s*ERROR:"), "Editor reported an import/script/export error; see " .. log)
end
