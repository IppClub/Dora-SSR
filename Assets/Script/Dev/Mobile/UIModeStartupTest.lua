-- Call verify through /command after a real process restart.
local Dora = require("Dora")
local Entry = require("Script.Dev.Entry")
return {
	verify = function(expected)
		assert(expected == "mobile" or expected == "traditional")
		local path = Dora.Path(Dora.Content.writablePath, "dora-ui-mode-startup-" .. expected .. ".result")
		local mode = Entry.getUIMode()
		local count = 0
		Dora.Director.systemUI:eachChild(function(node)
			if node.tag == "mobile-feed" then count = count + 1 end
			return false
		end)
		local ok = mode == expected and count == (expected == "mobile" and 1 or 0)
		Dora.Content:save(path, (ok and "passed " or "failed ") .. "mode=" .. mode .. " feedHosts=" .. count .. "\n")
		assert(ok, "startup mode differs from remembered selection")
	end,
}
