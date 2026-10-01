for _, name in ipairs({"dora-test", "dora-test-deps"}) do
    task(name)
        set_category("plugin")
        set_menu {
            usage = "xmake " .. name .. " [--suite=contract|web|web-ide|studio|prototype|art] [--case=NAME] [--repo=PATH] [-- ARGS]",
            description = "Run current engine tests from Dora-Example latest default-branch HEAD (or an explicit local checkout)",
            options = {{nil, "suite", "kv", "contract", "Test suite"},
                {nil, "case", "kv", nil, "Individual test filename without extension"},
                {nil, "repo", "kv", nil, "Local Dora-Example checkout (preserves local edits)"},
                {nil, "list", "k", nil, "List test cases without executing them"},
                {nil, "arguments", "vs", nil, "Test arguments after --"}}
        }
        local deps_only = name == "dora-test-deps"
        on_run(function ()
            import("core.base.option")
            import("lib.detect.find_tool")
            local root = os.projectdir()
            local tests = import("Projects.xmake.testing.repository", {rootdir = root, anonymous = true})(option.get("repo"))
            if deps_only then return end
            if not option.get("list") and (option.get("case") == "test-cli-agent"
                or (option.get("suite") == "web-ide" and not option.get("case"))) then
                os.vrunv(os.programfile(), {"dora-build", "--mode=debug"}, {curdir = root})
            end
            if not option.get("list") and option.get("suite") == "web-ide" and not option.get("case") then
                local pnpm = assert(find_tool("pnpm", {system = true}), "Web IDE acceptance requires pnpm")
                -- Asset/package acceptance needs a freshly prepared runtime and
                -- Vite output, not artifacts left over from a developer build.
                os.vrunv(pnpm.program, {"build"}, {curdir = path.join(root, "Tools/dora-dora")})
            end
            local node = assert(find_tool("node"), "test runner requires Node.js")
            local args = {path.join(tests.directory, "Test/run.mjs"), "--suite=" .. option.get("suite")}
            if option.get("case") then table.insert(args, "--case=" .. option.get("case")) end
            if option.get("list") then table.insert(args, "--list") end
            table.insert(args, "--")
            table.join2(args, option.get("arguments") or {})
            local test_envs = {
                DORA_ENGINE_ROOT = root, DORA_TEST_REPO = tests.directory,
                DORA_TEST_SCRIPTS = tests.scripts, DORA_TEST_WEB = tests.web,
                DORA_TEST_SHA = tests.sha, DORA_XMAKE = os.programfile()
            }
            if not option.get("list") and option.get("suite") == "studio"
                and not table.contains(option.get("arguments") or {}, "--no-build") then
                local directory = path.join(root, "build/studio-tests")
                test_envs.XMAKE_CONFIGDIR = path.join(directory, ".xmake-config")
                os.vrunv(os.programfile(), {"f", "-y", "-p", "wasm", "-a", "wasm32", "-m", "release",
                    "--builddir=" .. path.join(directory, "build"), "--dora_web_outdir=" .. path.join(directory, "artifacts"),
                    "--dora_web_engine=n", "--dora_web_link_player=n", "--dora_web_love_probe=n"},
                    {curdir = root, envs = test_envs})
                os.execv(os.programfile(), table.join({"lua", "Projects/xmake/testing/studio.lua", node.program}, args),
                    {curdir = root, envs = test_envs})
                return
            end
            os.execv(node.program, args, {curdir = root, envs = test_envs})
        end)
    task_end()
end
