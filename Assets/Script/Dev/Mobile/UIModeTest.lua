-- Run through /command (require), not /run: this exercises the real home shell.
local Dora = require("Dora")
local Entry = require("Script.Dev.Entry")
local resultPath = Dora.Path(Dora.Content.writablePath, "dora-ui-mode.result")
local originalMode = Entry.getUIMode()
local server = package.loaded["Script.Dev.WebServer"]
local windowSize = Dora.App.winSize
local function expect(value, message)
	if value then return end
	Dora.Content:save(resultPath, "failed " .. message .. "\n")
	error(message)
end
local function feeds()
	local count, host = 0, nil
	Dora.Director.systemUI:eachChild(function(node)
		if node.tag == "mobile-feed" then count, host = count + 1, node end
		return false
	end)
	return count, host
end
local function find(root, tag)
	if root.tag == tag then return root end
	local result
	root:eachChild(function(child)
		result = find(child, tag)
		return result ~= nil
	end)
	return result
end
local function persisted(value)
	for _ = 1, 60 do
		local rows = Dora.DB:query("select value_bool from Config where name = 'mobileFeed'")
		if rows and rows[1] and rows[1][1] == value then return true end
		Dora.sleep(0.05)
	end
	return false
end
Dora.Content:save(resultPath, "running\n")
Dora.thread(function()
	expect(not Entry.setUIMode("invalid"), "invalid mode accepted")
	for round = 1, 3 do
		expect(Entry.setUIMode("mobile"), "mobile request rejected")
		Dora.sleep(0.3)
		expect(Entry.getUIMode() == "mobile", "mobile mode did not activate")
		local count, host = feeds()
		expect(count == 1, "expected one Feed host")
		expect(Entry.setUIMode("mobile"), "idempotent request rejected")
		Dora.sleep(0.05)
		expect(feeds() == 1, "duplicate Feed host")
		host.visible = false
		expect(not Entry.setUIMode("traditional"), "hidden Feed should not switch from Remix/play")
		host.visible = true
		local button = find(host, "mobile-ui-mode-switch")
		expect(button ~= nil, "traditional switch button missing")
		button:emit("Tapped")
		Dora.sleep(0.3)
		expect(Entry.getUIMode() == "traditional", "button did not return to traditional UI")
		expect(feeds() == 0, "old Feed host leaked")
		expect(not host.parent, "old host is still attached")
		expect(package.loaded["Script.Dev.WebServer"] == server, "Web server was reloaded")
		expect(Dora.App.winSize == windowSize, "mode switch resized the window")
		expect(persisted(0), "traditional preference was not persisted")
	end
	expect(Entry.setUIMode("mobile"), "mobile persistence request rejected")
	Dora.sleep(0.3)
	expect(persisted(1), "mobile preference was not persisted")
	expect(Entry.setUIMode(originalMode), "could not restore original mode")
	Dora.sleep(0.3)
	Dora.Content:save(resultPath, "passed roundTrips=3 oneHost=1 cleanup=1 busyPageGuard=1 invalid=1 persistentBoth=1 serverUnchanged=1 windowUnchanged=1\n")
end)
