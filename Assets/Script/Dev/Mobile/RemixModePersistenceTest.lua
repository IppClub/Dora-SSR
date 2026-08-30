-- Two-stage, real-process restart regression. Only generated fixtures are changed.
local D = require("Dora")
local S = require("Agent.Session")
local U = require("Agent.Utils")
local T = require("Agent.Storage.Database")
local R = require("Dev.Mobile.Remix")
local manifest = "/tmp/dora-remix-mode-persistence.json"
local result = "/tmp/dora-remix-mode-persistence.result"
local M = {}

local function find(node, tag)
	if node.tag == tag then return node end
	local found
	node:eachChild(function(child) found = find(child, tag); return found ~= nil end)
	return found
end

local function selected(host, mode)
	local button = assert(find(host, "remix-mode-" .. mode), "Missing mode button")
	local active = false
	button:eachChild(function(child)
		local label = D.tolua.cast(child, "Label")
		if label then active = label.color3.r == 23 end
		return false
	end)
	return active
end

local function open(fixture)
	return R.startMobileRemix({
		entry = {id = fixture.root, title = "Mode persistence test", workDir = fixture.root},
		onBack = function() end, onPlay = function() end,
	})
end

function M.prepare()
	assert(not D.Content:exist(manifest), "Previous fixture exists; verify or clean it before preparing again")
	local fixtures = {}
	for i, mode in ipairs({"plan", "code"}) do
		local root = D.Path(D.Content.writablePath, "remix-mode-persistence-" .. tostring(D.App.runningTime) .. "-" .. i)
		assert(D.Content:mkdir(root))
		assert(D.Content:mkdir(D.Path(root, ".agent/plan")))
		assert(D.Content:save(D.Path(root, ".agent/plan/PLAN.md"), "# Existing plan\n"))
		assert(D.Content:save(D.Path(root, ".agent/plan/PROGRESS.md"), "# Existing progress\n"))
		local created = S.createSession(root, "Mode persistence test")
		assert(created.success and created.session.workMode == "code", "Plan files enabled planning for a new session")
		local fixture = {root = root, id = created.session.id, mode = mode}
		fixtures[#fixtures + 1] = fixture
		assert(D.Content:save(manifest, assert(U.safeJsonEncode(fixtures))))
		local host = open(fixture)
		assert(selected(host, "code") and not selected(host, "plan"), "Default code selection not rendered")
		find(host, "remix-mode-plan"):emit("Tapped")
		assert(selected(host, "plan"), "Plan selection not rendered")
		if mode == "code" then find(host, "remix-mode-code"):emit("Tapped") end
		local saved = S.getSession(fixture.id)
		assert(saved.success and saved.session.workMode == mode and #saved.messages == 0, "Mode was not saved without a prompt")
		host:removeFromParent(true)
	end
	D.Content:save(result, "prepared plan=1 code=1 defaultCodeWithPlanFiles=1; restart Dora before verify\n")
end

function M.verify()
	D.thread(function()
		local fixtures = assert(U.safeJsonDecode(D.Content:load(manifest)))
		local host
		local ok, err = xpcall(function()
			for _, fixture in ipairs(fixtures) do
				local created = S.createSession(fixture.root)
				assert(created.success and created.session.id == fixture.id and created.session.workMode == fixture.mode, "Restart lost session/mode")
				host = open(fixture)
				assert(selected(host, fixture.mode), "Restart did not restore selected control")
				local other = fixture.mode == "plan" and "code" or "plan"
				assert(S.setWorkMode(fixture.id, other).success) -- Same service used by Web IDE.
				D.sleep(0.35)
				assert(selected(host, other) and not selected(host, fixture.mode), "Shared service change did not refresh selection")
				find(host, "remix-mode-" .. fixture.mode):emit("Tapped")
				local saved = S.getSession(fixture.id)
				assert(saved.success and saved.session.workMode == fixture.mode and #saved.messages == 0, "Remix change not visible through shared service")
				local row = D.DB:query("SELECT work_mode FROM " .. T.TABLE_SESSION .. " WHERE id = ?", {fixture.id})
				assert(row[1][1] == fixture.mode, "Shared database preference differs")
				host:removeFromParent(true); host = nil
			end
		end, debug.traceback)
		if host then host:removeFromParent(true) end
		if ok then
			for _, fixture in ipairs(fixtures) do
				local prefix = D.Path(D.Content.writablePath, "remix-mode-persistence-")
				assert(fixture.root:sub(1, #prefix) == prefix and fixture.root:sub(#prefix + 1):match("^[%d%.%-]+$"), "Not an isolated fixture")
				S.deleteSessionsByProjectRoot(fixture.root)
				D.Content:remove(fixture.root)
			end
			D.Content:remove(manifest)
		end
		D.Content:save(result, ok and "passed coldRestart=1 savedPlan=1 savedCode=1 projectIsolation=1 oldPlanFiles=1 sharedServiceBothDirections=1 selectedControls=1 noPrompts=1 cleanup=1\n" or "failed: " .. tostring(err))
	end)
end

return M
