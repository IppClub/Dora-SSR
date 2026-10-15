-- Original Dora XML-to-Lua conversion, only for the Agent's explicit build.
-- This runs in the dedicated Studio Agent host, never in a game Player.
local Dora = require("Dora")
local Content, Path, xml = Dora.Content, Dora.Path, Dora.xml

local exports = {}
function exports.run(file, source, projectRoot)
	if type(xml) ~= "table" or type(xml.tolua) ~= "function" then
		return {success = false, message = "Dora XML compiler is unavailable"}
	end
	local converted, err = xml.tolua(source)
	local outputFile = Path:replaceExt(file, "lua")
	if Content:load(file) ~= source then
		return {success = false, message = "XML source changed during build"}
	end
	if not converted then
		Content:remove(outputFile)
		return {success = false, message = tostring(err or "XML compilation failed")}
	end
	local code = "-- [xml]: " .. file:sub(#projectRoot + 2) .. "\n" .. converted
	if not Content:save(outputFile, code) then
		return {success = false, message = "failed to save " .. outputFile}
	end
	return {success = true, luaCode = code}
end
return exports
