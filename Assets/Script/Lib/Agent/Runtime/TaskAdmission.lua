-- [ts]: TaskAdmission.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local ____exports = {} -- 1
local holds = {} -- 2
function ____exports.isProjectTaskAdmissionClosed(projectRoot) -- 4
	return (holds[projectRoot] or 0) > 0 -- 5
end -- 4
--- Use the canonical project root from the session record.
function ____exports.holdProjectTaskAdmission(projectRoot) -- 9
	if projectRoot == "" then -- 9
		error("project root is required") -- 10
	end -- 10
	holds[projectRoot] = (holds[projectRoot] or 0) + 1 -- 11
	local released = false -- 12
	return function() -- 13
		if released then -- 13
			return -- 14
		end -- 14
		released = true -- 15
		local remaining = (holds[projectRoot] or 1) - 1 -- 16
		if remaining > 0 then -- 16
			holds[projectRoot] = remaining -- 17
		else -- 17
			__TS__Delete(holds, projectRoot) -- 18
		end -- 18
	end -- 13
end -- 9
return ____exports -- 9