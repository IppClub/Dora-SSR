-- Original Dora Yue compiler adapter for a tool-triggered Studio Agent build.
-- The dedicated host has no real model keys; never load this in a game Player.
local Dora = require("Dora")
local Content, Path, yue = Dora.Content, Dora.Path, Dora.yue
local originalUtils = require("Utils")
local CheckTIC80Code, LintYueGlobals = originalUtils.CheckTIC80Code, originalUtils.LintYueGlobals

local function generatedHeader(codes, file, tic80)
	local header = "-- [yue]: " .. file
	if tic80 then
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. header .. "\n", 1))
		end
		return "-- tic80\n" .. header .. "\n" .. codes
	end
	return header .. "\n" .. codes
end

local function lintMessage(errors)
	if type(errors) == "string" then return errors end
	if type(errors) ~= "table" then return "Yue global lint failed" end
	local lines = {}
	for i = 1, math.min(#errors, 32) do
		local item = errors[i]
		if type(item) == "table" then
			lines[#lines + 1] = tostring(item[1]) .. " at line " .. tostring(item[2]) .. ":" .. tostring(item[3])
		end
	end
	return #lines > 0 and table.concat(lines, "\n") or "Yue global lint failed"
end

local exports = {}
function exports.start(file, source, projectRoot, requestId, stillActive, finish)
	assert(type(yue) == "table" and type(yue.compile) == "function", "Dora Yue compiler is unavailable")
	assert(type(file) == "string" and type(source) == "string" and type(projectRoot) == "string")
	local relativeFile = file:sub(#projectRoot + 2)
	local outputFile = Path:replaceExt(file, "lua")
	-- The native compiler writes its result asynchronously. Keep it transient
	-- until the original Agent tool is still active and compilation succeeds.
	local temporaryFile = file .. ".studio-agent-" .. requestId .. ".lua"
	if Content:exist(temporaryFile) then
		finish({success = false, message = "Yue build temporary path is occupied"})
		return
	end
	local searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua")
	local tic80, tic80APIs = CheckTIC80Code(source)
	local resultCodes, resultError
	local started = pcall(function()
		yue.compile(file, temporaryFile, searchPath, function(codes, err, globals)
			if not stillActive() then return nil end
			if not codes then resultError = tostring(err or "Yue compilation failed"); return nil end
			local success, message = LintYueGlobals(codes, globals or {}, true, tic80 and tic80APIs or nil)
			if not success then resultError = lintMessage(message); return nil end
			resultCodes = codes == "" and "" or generatedHeader(codes, relativeFile, tic80)
			return resultCodes
		end, function(success)
			Content:remove(temporaryFile)
			if not stillActive() then return end
			if Content:load(file) ~= source then
				finish({success = false, message = "Yue source changed during build"})
				return
			end
			if success and resultCodes ~= nil then
				if Content:save(outputFile, resultCodes) then
					finish({success = true, luaCode = resultCodes})
				else
					finish({success = false, message = "failed to save " .. outputFile})
				end
			else
				Content:remove(outputFile)
				finish({success = false, message = resultError or "Yue compilation failed"})
			end
		end)
	end)
	if not started then
		Content:remove(temporaryFile)
		if stillActive() then finish({success = false, message = "Dora Yue compiler could not start"}) end
	end
end
return exports
