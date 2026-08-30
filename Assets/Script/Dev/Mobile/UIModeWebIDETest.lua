-- Exercise the real connection guard through /command while a test WebSocket connects.
local D = require("Dora")
local E = require("Script.Dev.Entry")
local result = D.Path(D.Content.writablePath, "dora-ui-mode-webide.result")
local originalMode = E.getUIMode()
local preference
local function expect(value, message)
	if value then return end
	D.Content:save(result, "failed " .. message .. "\n")
	error(message)
end
return {
	prepare = function()
		expect(D.HttpServer.wsConnectionCount == 0, "close Web IDE before the test")
		expect(E.setUIMode("traditional"), "traditional request failed")
		D.thread(function()
			D.sleep(0.5)
			expect(E.getUIMode() == "traditional", "traditional shell missing")
			preference = E.getConfig().mobileFeed
			D.Content:save(result, "ready\n")
		end)
	end,
	connected = function()
		expect(D.HttpServer.wsConnectionCount > 0, "WebSocket not connected")
		expect(not E.setUIMode("mobile"), "Web IDE allowed a Mobile request")
		D.thread(function()
			D.sleep(0.3)
			expect(E.getUIMode() == "traditional", "connected shell switched mode")
			expect(E.getConfig().mobileFeed == preference, "blocked request changed preference")
			expect(not D.Director.systemUI:getChildByTag("mobile-feed"), "blocked request created Feed")
			D.App:saveScreenshot(D.Path(D.Content.writablePath, "dora-ui-mode-webide-connected"))
			D.Content:save(result, "connected passed\n")
		end)
	end,
	disconnected = function()
		expect(D.HttpServer.wsConnectionCount == 0, "WebSocket still connected")
		expect(E.setUIMode("mobile"), "disconnected shell rejected Mobile")
		D.thread(function()
			D.sleep(0.3)
			expect(E.getUIMode() == "mobile", "Mobile did not recover after disconnect")
			expect(E.setUIMode(originalMode), "failed to restore mode")
			D.sleep(0.3)
			D.Content:save(result, "passed connectedBlocked=1 preferenceUnchanged=1 noFeed=1 disconnectedRestored=1\n")
		end)
	end,
}
