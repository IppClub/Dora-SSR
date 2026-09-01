local D = require("Dora")
local Entry = require("Script.Dev.Entry")

local resultPath = "/tmp/dora-mobile-feed-entry-cache.result"

local function expect(condition, message)
	if condition then return end
	D.Content:save(resultPath, "failed " .. message .. "\n")
	error(message)
end

local function writeProject(root, name, title)
	local project = D.Path(root, name)
	D.Content:mkdir(project)
	D.Content:mkdir(D.Path(project, ".dora"))
	D.Content:save(D.Path(project, "init.lua"), "return function() end\n")
	D.Content:save(D.Path(project, ".dora", "repo.json"), string.format(
		'{"title":{"en":"%s","zh":"%s"},"description":{"en":"test","zh":"测试"}}', title, title))
	return project
end

local function byId(items, id)
	for _, item in ipairs(items) do
		if item.id == id then return item end
	end
end

return function()
	local original = D.Content.writablePath
	local root = D.Path(original, "mobile-feed-cache-test-" .. tostring(D.App.runningTime))
	D.Content:mkdir(root)
	local a = writeProject(root, "A", "A1")
	local b = writeProject(root, "B", "B1")
	local ok, err = xpcall(function()
		D.Content.writablePath = root
		local initial = Entry.getMobileFeedEntries(true)
		expect(byId(initial, "A").title == "A1" and byId(initial, "B").title == "B1", "cold full scan did not load both projects")

		D.Content:save(D.Path(a, ".dora", "repo.json"), '{"title":{"en":"A2","zh":"A2"}}')
		D.Content:save(D.Path(b, ".dora", "repo.json"), '{"title":{"en":"B2","zh":"B2"}}')
		local oneDirty = Entry.getMobileFeedEntries(false, a)
		expect(byId(oneDirty, "A").title == "A2", "dirty project was not refreshed")
		expect(byId(oneDirty, "B").title == "B1", "clean project was rescanned")

		local secondDirty = Entry.getMobileFeedEntries(false, b)
		expect(byId(secondDirty, "B").title == "B2", "second dirty project was not refreshed")

		D.Content:remove(D.Path(a, "init.lua"))
		expect(byId(Entry.getMobileFeedEntries(false, a), "A") == nil, "removed project entry stayed cached")

		local c = writeProject(root, "C", "C1")
		expect(byId(Entry.getMobileFeedEntries(false, c), "C") ~= nil, "new project was not inserted incrementally")
	end, debug.traceback)
	D.Content.writablePath = original
	Entry.getMobileFeedEntries(true)
	D.Content:remove(root)
	if not ok then
		D.Content:save(resultPath, "failed " .. tostring(err) .. "\n")
		error(err)
	end
	D.Content:save(resultPath, "passed coldFull=1 dirtyOne=1 cleanStable=1 remove=1 insert=1\n")
end
