-- Keep the embedded IDE visible until an asynchronous Godot startup has a
-- texture and Dora has submitted the frames that sample it.
local Dora = require("Dora")
local App, Director, tolua = Dora.App, Dora.Director, Dora.tolua
local M = {}

function M.waitForFrameAsync(entry, runId, expectGodot, checkPreview)
	local started = App.runningTime
	local nodes, seen = {}, {}
	local function collect()
		for _, root in ipairs({Director.entry, Director.ui, Director.ui3D, Director.postNode}) do
			root:traverseAll(function(node)
				local game = tolua.cast(node, "GodotNode")
				if game and not seen[game] then
					seen[game] = true
					nodes[#nodes + 1] = game
				end
				return false
			end)
		end
	end
	local function check(beforeFirstFrame)
		if beforeFirstFrame and checkPreview then checkPreview() end
		local status = entry.getCurrentEntryStatus()
		if not status.running or status.runId ~= runId then
			return false, "Run stopped or superseded before its first frame."
		end
		for _, game in ipairs(nodes) do
			if game.lastError ~= "" then return false, game.lastError end
			if game.unloaded or not game.parent then
				return false, "Godot node was removed before its first frame."
			end
		end
		if beforeFirstFrame and App.runningTime - started >= 60 then
			return false, "Godot startup timed out before its first frame."
		end
		return true
	end
	-- Retain explicit scene children now so an update that removes a failed
	-- node cannot discard its diagnostic; collect implicit children next tick.
	collect()
	Dora.sleep()
	collect()
	if expectGodot and #nodes == 0 then
		return false, "Godot project entry did not create a GodotNode. Check the runtime and startup log."
	end
	local readyFrame
	while true do
		local ok, err = check(true)
		if not ok then return false, err end
		local ready = true
		for _, game in ipairs(nodes) do
			if not game.running then ready = false end
		end
		if ready then
			readyFrame = readyFrame or App.frame
			-- running becomes true when the texture is published on the logic
			-- thread. Cross two frame boundaries before allowing native hide.
			if App.frame - readyFrame >= 2 then
				return true, nil, function()
					collect()
					return check(false)
				end
			end
		else
			readyFrame = nil
		end
		Dora.sleep()
	end
end

return M
