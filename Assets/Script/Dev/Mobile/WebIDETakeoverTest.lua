-- Run with /command and a real test WebSocket, across both local UI preferences.
local D = require("Dora")
local E = require("Script.Dev.Entry")
local path = D.Path(D.Content.writablePath, "dora-webide-takeover.result")
local function expect(ok, message)
	if ok then return end
	D.Content:save(path, "failed " .. message .. "\n")
	error(message)
end
local function localHosts()
	local list = {}
	D.Director.systemUI:eachChild(function(node)
		if node.tag == "mobile-feed" or node.tag == "mobile-remix" or node.tag == "mobile-play-overlay" then list[#list + 1] = node end
		return false
	end)
	return list
end
return {
	prepare = function(mode)
		expect(D.HttpServer.wsConnectionCount == 0, "unexpected connection before prepare")
		expect(E.setUIMode(mode), "cannot select local mode")
		D.thread(function()
			D.sleep(0.5)
			expect(E.getUIMode() == mode, "wrong local mode")
			D.Content:save(path, "ready " .. mode .. "\n")
		end)
	end,
	connected = function(mode)
		D.thread(function()
			D.sleep(0.3)
			expect(D.HttpServer.wsConnectionCount > 0, "not connected")
			expect(E.getUIMode() == mode and E.getConfig().mobileFeed == (mode == "mobile"), "takeover changed preference")
			expect(not E.setUIMode("mobile") and not E.setUIMode("traditional"), "mode switch accepted during takeover")
			for _, node in ipairs(localHosts()) do expect(not node.visible, "local UI visible during takeover") end
			D.App:saveScreenshot(D.Path(D.Content.writablePath, "dora-takeover-" .. mode))
			D.Content:save(path, "connected " .. mode .. "\n")
		end)
	end,
	running = function(mode)
		expect(E.getCurrentEntryStatus().running, "remote run did not start")
		expect(#localHosts() == 0, "local overlays survived remote run")
		expect(D.Director.entry:getChildByTag("webide-controlled-probe"), "remote scene missing")
		expect(E.getConfig().mobileFeed == (mode == "mobile"), "remote run changed preference")
		D.Content:save(path, "running " .. mode .. "\n")
	end,
	stopped = function(mode)
		D.thread(function()
			D.sleep(0.3)
			expect(not E.getCurrentEntryStatus().running, "remote stop failed")
			expect(#localHosts() == 0, "local UI recreated while still connected")
			expect(E.getUIMode() == mode, "remote stop changed preference")
			D.Content:save(path, "stopped " .. mode .. "\n")
		end)
	end,
	disconnected = function(mode)
		D.thread(function()
			D.sleep(0.5)
			expect(D.HttpServer.wsConnectionCount == 0, "connections still active")
			expect(E.getUIMode() == mode, "local preference not restored")
			local hosts = localHosts()
			expect(#hosts == (mode == "mobile" and 1 or 0), "wrong restored host count")
			if mode == "mobile" then expect(hosts[1].visible, "restored Feed hidden") end
			D.Content:save(path, "passed " .. mode .. " takeover=1 multiConnection=1 remoteRunStop=1 restored=1\n")
		end)
	end,
}
