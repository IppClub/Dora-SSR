-- [ts]: CompletionPolicy.ts
local ____exports = {} -- 1
--- Keep a main Agent working until authored changes have current, successful
-- compiler evidence. The caller feeds this message back as a decision error so
-- the model can build, repair, and retry inside the same task.
function ____exports.getAuthoredCompletionBlocker(state) -- 14
	if state.unbuiltEdits == true then -- 14
		return "authored source changes are still unbuilt; call build for the affected project before completing" -- 16
	end -- 16
	if state.buildRepairPending == true or state.hasBuilt == true and state.lastBuildSucceeded == false then -- 16
		return "the latest project build failed; repair the reported authored-file diagnostics and complete a successful build before completing" -- 19
	end -- 19
	return nil -- 21
end -- 14
return ____exports -- 14