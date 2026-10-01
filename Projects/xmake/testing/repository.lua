function main(directory)
    import("lib.detect.find_tool")
    local git = assert(find_tool("git"), "test dependencies require Git")
    local root = os.projectdir()
    local override = directory or os.getenv("DORA_TEST_REPO")
    local repo = override and path.absolute(override, root) or path.join(root, "build/tests/Dora-Example")
    if override then
        local checkout = os.iorunv(git.program, {"-C", repo, "rev-parse", "--show-toplevel"}):trim()
        assert(path.absolute(checkout) == repo, "local test path must be a Git checkout root: " .. repo)
    else
        os.mkdir(path.directory(repo))
        local lock = assert(io.openlock(path.join(root, "build/tests/fetch.lock")))
        lock:lock()
        if not os.isdir(path.join(repo, ".git")) then
            assert(not os.exists(repo), "refusing to overwrite test dependency directory: " .. repo)
            os.vrunv(git.program, {"clone", "--depth=1",
                "https://github.com/IppClub/Dora-Example.git", repo})
        else
            local origin = os.iorunv(git.program, {"-C", repo, "remote", "get-url", "origin"}):trim()
            assert(origin == "https://github.com/IppClub/Dora-Example.git", "unexpected managed test repository origin")
            local changes = os.iorunv(git.program, {"-C", repo, "status", "--porcelain"})
            assert(changes:trim() == "", "managed test checkout has local changes; use --repo for development")
            -- Follow the remote default branch (currently master), not a pinned ref.
            -- No cached fallback: failure to obtain latest HEAD fails the run.
            os.vrunv(git.program, {"-C", repo, "fetch", "--depth=1", "origin", "HEAD"})
            os.vrunv(git.program, {"-C", repo, "checkout", "--detach", "FETCH_HEAD"})
        end
        -- Each run resolves latest HEAD, then uses an immutable revision path.
        -- Another task fetching newer tests cannot rewrite active build inputs.
        local revision = os.iorunv(git.program, {"-C", repo, "rev-parse", "HEAD"}):trim()
        local snapshot = path.join(root, "build/tests/revisions", revision)
        if not os.exists(snapshot) then
            os.mkdir(path.directory(snapshot))
            os.vrunv(git.program, {"-C", repo, "worktree", "add", "--detach", snapshot, revision})
        else
            local current = os.iorunv(git.program, {"-C", snapshot, "rev-parse", "HEAD"}):trim()
            local changes = os.iorunv(git.program, {"-C", snapshot, "status", "--porcelain"}):trim()
            assert(current == revision and changes == "", "managed test snapshot was modified; use --repo for development")
        end
        repo = snapshot
        lock:close()
    end
    local sha = os.iorunv(git.program, {"-C", repo, "rev-parse", "HEAD"}):trim()
    cprint("${bright}Dora-Example tests${clear}: %s (%s)", repo, sha)
    assert(os.isfile(path.join(repo, "Test/manifest.json")),
        "Dora-Example latest HEAD does not contain the migrated test suite yet; publish it or use --repo/DORA_TEST_REPO")
    return {directory = repo, sha = sha, scripts = path.join(repo, "Test/BuildScripts"), web = path.join(repo, "Test/Web")}
end
