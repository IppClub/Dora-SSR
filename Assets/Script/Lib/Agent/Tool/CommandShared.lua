-- [ts]: CommandShared.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local ____exports = {} -- 1
function ____exports.toCommandString(v) -- 2
	if v == false or v == nil then -- 2
		return "" -- 3
	end -- 3
	return tostring(v) -- 4
end -- 2
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 7
local EXECUTE_COMMAND_ERROR_MAX = 4000 -- 8
function ____exports.truncateCommandOutput(output) -- 10
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 10
		return output -- 11
	end -- 11
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 12
end -- 10
function ____exports.truncateCommandError(message) -- 15
	if #message <= EXECUTE_COMMAND_ERROR_MAX then -- 15
		return message -- 16
	end -- 16
	return __TS__StringSlice(message, 0, EXECUTE_COMMAND_ERROR_MAX) .. "\n... error message truncated ..." -- 17
end -- 15
return ____exports -- 15