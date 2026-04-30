-- [ts]: CodingAgent.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__Iterator = ____lualib.__TS__Iterator -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery -- 1
local __TS__PromiseAll = ____lualib.__TS__PromiseAll -- 1
local ____exports = {} -- 1
local isArray, stripWrappingQuotes, parseSimpleYAML, emitAgentEvent, truncateText, getReplyLanguageDirective, replacePromptVars, getDecisionToolDefinitions, getFinishMessage, persistHistoryState, getActiveConversationMessages, getActiveRealMessageCount, applyCompressedSessionState, getDecisionPath, clampIntegerParam, parseReadLineParam, validateDecision, getAllowedToolsForRole, buildAgentSystemPrompt, buildSkillsSection, buildXmlDecisionInstruction, emitAgentTaskFinishEvent, canPreExecuteTool, clearPreExecutedResults, startPreExecutedToolAction, executeToolActionWithPreExecution, createPreExecutableActionFromStream, executeToolAction, READ_FILE_DEFAULT_LIMIT, SEARCH_DORA_API_LIMIT_MAX, SEARCH_FILES_LIMIT_DEFAULT, LIST_FILES_MAX_ENTRIES_DEFAULT -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Path = ____Dora.Path -- 2
local Content = ____Dora.Content -- 2
local ____flow = require("Agent.flow") -- 3
local Flow = ____flow.Flow -- 3
local Node = ____flow.Node -- 3
local ____Utils = require("Agent.Utils") -- 4
local callLLM = ____Utils.callLLM -- 4
local callLLMStreamAggregated = ____Utils.callLLMStreamAggregated -- 4
local Log = ____Utils.Log -- 4
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 4
local createLocalToolCallId = ____Utils.createLocalToolCallId -- 4
local parseSimpleXMLChildren = ____Utils.parseSimpleXMLChildren -- 4
local parseXMLObjectFromText = ____Utils.parseXMLObjectFromText -- 4
local safeJsonDecode = ____Utils.safeJsonDecode -- 4
local safeJsonEncode = ____Utils.safeJsonEncode -- 4
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 4
local Tools = require("Agent.Tools") -- 6
local ____Memory = require("Agent.Memory") -- 7
local MemoryCompressor = ____Memory.MemoryCompressor -- 7
function isArray(value) -- 14
	return __TS__ArrayIsArray(value) -- 15
end -- 15
function stripWrappingQuotes(value) -- 44
	local result = string.gsub(value, "^\"(.*)\"$", "%1") -- 45
	result = string.gsub(result, "^'(.*)'$", "%1") -- 46
	return result -- 47
end -- 47
function parseSimpleYAML(text) -- 97
	if not text or __TS__StringTrim(text) == "" then -- 97
		return nil -- 99
	end -- 99
	local result = {} -- 102
	local lines = __TS__StringSplit(text, "\n") -- 103
	local currentKey = "" -- 104
	local currentArray = nil -- 105
	do -- 105
		local i = 0 -- 107
		while i < #lines do -- 107
			do -- 107
				local line = lines[i + 1] -- 108
				local trimmed = __TS__StringTrim(line) -- 109
				if trimmed == "" or __TS__StringStartsWith(trimmed, "#") then -- 109
					goto __continue16 -- 112
				end -- 112
				if __TS__StringStartsWith(trimmed, "- ") then -- 112
					if currentArray ~= nil and currentKey ~= "" then -- 112
						local value = __TS__StringTrim(__TS__StringSubstring(trimmed, 2)) -- 117
						local cleaned = stripWrappingQuotes(value) -- 118
						currentArray[#currentArray + 1] = cleaned -- 119
					end -- 119
					goto __continue16 -- 121
				end -- 121
				local colonIndex = (string.find(trimmed, ":", nil, true) or 0) - 1 -- 124
				if colonIndex > 0 then -- 124
					if currentArray ~= nil and currentKey ~= "" then -- 124
						result[currentKey] = currentArray -- 127
						currentArray = nil -- 128
					end -- 128
					local key = __TS__StringTrim(__TS__StringSubstring(trimmed, 0, colonIndex)) -- 131
					local value = __TS__StringTrim(__TS__StringSubstring(trimmed, colonIndex + 1)) -- 132
					if __TS__StringStartsWith(value, "[") and __TS__StringEndsWith(value, "]") then -- 132
						local arrayText = __TS__StringSubstring(value, 1, #value - 1) -- 135
						local items = __TS__ArrayMap( -- 136
							__TS__StringSplit(arrayText, ","), -- 136
							function(____, item) -- 136
								local cleaned = stripWrappingQuotes(__TS__StringTrim(item)) -- 137
								return cleaned -- 138
							end -- 136
						) -- 136
						result[key] = items -- 140
						goto __continue16 -- 141
					end -- 141
					if value == "true" then -- 141
						result[key] = true -- 145
						goto __continue16 -- 146
					end -- 146
					if value == "false" then -- 146
						result[key] = false -- 149
						goto __continue16 -- 150
					end -- 150
					if value == "" then -- 150
						currentKey = key -- 154
						currentArray = {} -- 155
						if i + 1 < #lines then -- 155
							local nextLine = __TS__StringTrim(lines[i + 1 + 1]) -- 157
							if not __TS__StringStartsWith(nextLine, "- ") then -- 157
								currentArray = nil -- 159
								result[key] = "" -- 160
							end -- 160
						else -- 160
							currentArray = nil -- 163
							result[key] = "" -- 164
						end -- 164
						goto __continue16 -- 166
					end -- 166
					local cleaned = stripWrappingQuotes(value) -- 169
					result[key] = cleaned -- 170
					currentKey = "" -- 171
					currentArray = nil -- 172
				end -- 172
			end -- 172
			::__continue16:: -- 172
			i = i + 1 -- 107
		end -- 107
	end -- 107
	if currentArray ~= nil and currentKey ~= "" then -- 107
		result[currentKey] = currentArray -- 177
	end -- 177
	return result -- 180
end -- 180
function emitAgentEvent(shared, event) -- 726
	if shared.onEvent then -- 726
		do -- 726
			local function ____catch(____error) -- 726
				Log( -- 731
					"Error", -- 731
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 731
				) -- 731
			end -- 731
			local ____try, ____hasReturned = pcall(function() -- 731
				shared:onEvent(event) -- 729
			end) -- 729
			if not ____try then -- 729
				____catch(____hasReturned) -- 729
			end -- 729
		end -- 729
	end -- 729
end -- 729
function truncateText(text, maxLen) -- 975
	if #text <= maxLen then -- 975
		return text -- 976
	end -- 976
	local nextPos = utf8.offset(text, maxLen + 1) -- 977
	if nextPos == nil then -- 977
		return text -- 978
	end -- 978
	return string.sub(text, 1, nextPos - 1) .. "..." -- 979
end -- 979
function getReplyLanguageDirective(shared) -- 989
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 990
end -- 990
function replacePromptVars(template, vars) -- 995
	local output = template -- 996
	for key in pairs(vars) do -- 997
		output = table.concat( -- 998
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 998
			vars[key] or "" or "," -- 998
		) -- 998
	end -- 998
	return output -- 1000
end -- 1000
function getDecisionToolDefinitions(shared) -- 1124
	local base = replacePromptVars( -- 1125
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1126
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1127
	) -- 1127
	local spawnTool = "\n\n9. list_sub_agents: Query sub-agent state under the current main session\n\t- Parameters: status(optional), limit(optional), offset(optional), query(optional)\n\t- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.\n\t- status defaults to active_or_recent and may also be running, done, failed, or all.\n\t- limit defaults to a small recent window. Use offset to page older items.\n\t- query filters by title, goal, or summary text.\n\t- Do not use this after a successful spawn_sub_agent in the same turn.\n\n10. spawn_sub_agent: Create and start a sub agent session for delegated implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n\t- For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.\n\t- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.\n\t- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.\n\t- filesHint is an optional list of likely files or directories." -- 1129
	local availability = shared and (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat( -- 1150
		getAllowedToolsForRole(shared.role), -- 1151
		", " -- 1151
	) or "" -- 1151
	local withRole = (base .. ((shared and shared.role) == "main" and spawnTool or "")) .. availability -- 1153
	if (shared and shared.decisionMode) ~= "xml" then -- 1153
		return withRole -- 1155
	end -- 1155
	return withRole .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1157
end -- 1157
function getFinishMessage(params, fallback) -- 1420
	if fallback == nil then -- 1420
		fallback = "" -- 1420
	end -- 1420
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1420
		return __TS__StringTrim(params.message) -- 1422
	end -- 1422
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1422
		return __TS__StringTrim(params.response) -- 1425
	end -- 1425
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1425
		return __TS__StringTrim(params.summary) -- 1428
	end -- 1428
	return __TS__StringTrim(fallback) -- 1430
end -- 1430
function persistHistoryState(shared) -- 1433
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1434
end -- 1434
function getActiveConversationMessages(shared) -- 1441
	local activeMessages = {} -- 1442
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1442
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1449
	end -- 1449
	do -- 1449
		local i = shared.lastConsolidatedIndex -- 1453
		while i < #shared.messages do -- 1453
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1454
			i = i + 1 -- 1453
		end -- 1453
	end -- 1453
	return activeMessages -- 1456
end -- 1456
function getActiveRealMessageCount(shared) -- 1459
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1460
end -- 1460
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1463
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1468
	local previousActiveStart = shared.lastConsolidatedIndex -- 1469
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1470
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1471
	if type(carryMessageIndex) == "number" then -- 1471
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1471
		else -- 1471
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1479
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1482
		end -- 1482
	else -- 1482
		shared.carryMessageIndex = nil -- 1487
	end -- 1487
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1487
		shared.carryMessageIndex = nil -- 1497
	end -- 1497
end -- 1497
function getDecisionPath(params) -- 1731
	if type(params.path) == "string" then -- 1731
		return __TS__StringTrim(params.path) -- 1732
	end -- 1732
	if type(params.target_file) == "string" then -- 1732
		return __TS__StringTrim(params.target_file) -- 1733
	end -- 1733
	return "" -- 1734
end -- 1734
function clampIntegerParam(value, fallback, minValue, maxValue) -- 1737
	local num = __TS__Number(value) -- 1738
	if not __TS__NumberIsFinite(num) then -- 1738
		num = fallback -- 1739
	end -- 1739
	num = math.floor(num) -- 1740
	if num < minValue then -- 1740
		num = minValue -- 1741
	end -- 1741
	if maxValue ~= nil and num > maxValue then -- 1741
		num = maxValue -- 1742
	end -- 1742
	return num -- 1743
end -- 1743
function parseReadLineParam(value, fallback, paramName) -- 1746
	local num = __TS__Number(value) -- 1751
	if not __TS__NumberIsFinite(num) then -- 1751
		num = fallback -- 1752
	end -- 1752
	num = math.floor(num) -- 1753
	if num == 0 then -- 1753
		return {success = false, message = paramName .. " cannot be 0"} -- 1755
	end -- 1755
	return {success = true, value = num} -- 1757
end -- 1757
function validateDecision(tool, params) -- 1760
	if tool == "finish" then -- 1760
		local message = getFinishMessage(params) -- 1765
		if message == "" then -- 1765
			return {success = false, message = "finish requires params.message"} -- 1766
		end -- 1766
		params.message = message -- 1767
		return {success = true, params = params} -- 1768
	end -- 1768
	if tool == "read_file" then -- 1768
		local path = getDecisionPath(params) -- 1772
		if path == "" then -- 1772
			return {success = false, message = "read_file requires path"} -- 1773
		end -- 1773
		params.path = path -- 1774
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1775
		if not startLineRes.success then -- 1775
			return startLineRes -- 1776
		end -- 1776
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1777
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1778
		if not endLineRes.success then -- 1778
			return endLineRes -- 1779
		end -- 1779
		params.startLine = startLineRes.value -- 1780
		params.endLine = endLineRes.value -- 1781
		return {success = true, params = params} -- 1782
	end -- 1782
	if tool == "edit_file" then -- 1782
		local path = getDecisionPath(params) -- 1786
		if path == "" then -- 1786
			return {success = false, message = "edit_file requires path"} -- 1787
		end -- 1787
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1788
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1789
		params.path = path -- 1790
		params.old_str = oldStr -- 1791
		params.new_str = newStr -- 1792
		return {success = true, params = params} -- 1793
	end -- 1793
	if tool == "delete_file" then -- 1793
		local targetFile = getDecisionPath(params) -- 1797
		if targetFile == "" then -- 1797
			return {success = false, message = "delete_file requires target_file"} -- 1798
		end -- 1798
		params.target_file = targetFile -- 1799
		return {success = true, params = params} -- 1800
	end -- 1800
	if tool == "grep_files" then -- 1800
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1804
		if pattern == "" then -- 1804
			return {success = false, message = "grep_files requires pattern"} -- 1805
		end -- 1805
		params.pattern = pattern -- 1806
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1807
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1808
		return {success = true, params = params} -- 1809
	end -- 1809
	if tool == "search_dora_api" then -- 1809
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1813
		if pattern == "" then -- 1813
			return {success = false, message = "search_dora_api requires pattern"} -- 1814
		end -- 1814
		params.pattern = pattern -- 1815
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1816
		return {success = true, params = params} -- 1817
	end -- 1817
	if tool == "glob_files" then -- 1817
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1821
		return {success = true, params = params} -- 1822
	end -- 1822
	if tool == "build" then -- 1822
		local path = getDecisionPath(params) -- 1826
		if path ~= "" then -- 1826
			params.path = path -- 1828
		end -- 1828
		return {success = true, params = params} -- 1830
	end -- 1830
	if tool == "list_sub_agents" then -- 1830
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 1834
		if status ~= "" then -- 1834
			params.status = status -- 1836
		end -- 1836
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 1838
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1839
		if type(params.query) == "string" then -- 1839
			params.query = __TS__StringTrim(params.query) -- 1841
		end -- 1841
		return {success = true, params = params} -- 1843
	end -- 1843
	if tool == "spawn_sub_agent" then -- 1843
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 1847
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 1848
		if prompt == "" then -- 1848
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 1849
		end -- 1849
		if title == "" then -- 1849
			return {success = false, message = "spawn_sub_agent requires title"} -- 1850
		end -- 1850
		params.prompt = prompt -- 1851
		params.title = title -- 1852
		if type(params.expectedOutput) == "string" then -- 1852
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 1854
		end -- 1854
		if isArray(params.filesHint) then -- 1854
			params.filesHint = __TS__ArrayMap( -- 1857
				__TS__ArrayFilter( -- 1857
					params.filesHint, -- 1857
					function(____, item) return type(item) == "string" end -- 1858
				), -- 1858
				function(____, item) return sanitizeUTF8(item) end -- 1859
			) -- 1859
		end -- 1859
		return {success = true, params = params} -- 1861
	end -- 1861
	return {success = true, params = params} -- 1864
end -- 1864
function getAllowedToolsForRole(role) -- 1890
	return role == "main" and ({ -- 1891
		"read_file", -- 1892
		"edit_file", -- 1892
		"delete_file", -- 1892
		"grep_files", -- 1892
		"search_dora_api", -- 1892
		"glob_files", -- 1892
		"build", -- 1892
		"list_sub_agents", -- 1892
		"spawn_sub_agent", -- 1892
		"finish" -- 1892
	}) or ({ -- 1892
		"read_file", -- 1893
		"edit_file", -- 1893
		"delete_file", -- 1893
		"grep_files", -- 1893
		"search_dora_api", -- 1893
		"glob_files", -- 1893
		"build", -- 1893
		"finish" -- 1893
	}) -- 1893
end -- 1893
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 1999
	if includeToolDefinitions == nil then -- 1999
		includeToolDefinitions = false -- 1999
	end -- 1999
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2000
	local sections = { -- 2003
		shared.promptPack.agentIdentityPrompt, -- 2004
		rolePrompt, -- 2005
		getReplyLanguageDirective(shared) -- 2006
	} -- 2006
	if shared.decisionMode == "tool_calling" then -- 2006
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2009
	end -- 2009
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2011
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2012
	if memoryContext ~= "" then -- 2012
		sections[#sections + 1] = memoryContext -- 2014
	end -- 2014
	if includeToolDefinitions then -- 2014
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2017
		if shared.decisionMode == "xml" then -- 2017
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2019
		end -- 2019
	end -- 2019
	local skillsSection = buildSkillsSection(shared) -- 2023
	if skillsSection ~= "" then -- 2023
		sections[#sections + 1] = skillsSection -- 2025
	end -- 2025
	return table.concat(sections, "\n\n") -- 2027
end -- 2027
function buildSkillsSection(shared) -- 2030
	local ____opt_34 = shared.skills -- 2030
	if not (____opt_34 and ____opt_34.loader) then -- 2030
		return "" -- 2032
	end -- 2032
	return shared.skills.loader:buildSkillsPromptSection() -- 2034
end -- 2034
function buildXmlDecisionInstruction(shared, feedback) -- 2146
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2147
end -- 2147
function emitAgentTaskFinishEvent(shared, success, message) -- 3530
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3531
	emitAgentEvent(shared, { -- 3537
		type = "task_finished", -- 3538
		sessionId = shared.sessionId, -- 3539
		taskId = shared.taskId, -- 3540
		success = result.success, -- 3541
		message = result.message, -- 3542
		steps = result.steps -- 3543
	}) -- 3543
	return result -- 3545
end -- 3545
local function isRecord(value) -- 10
	return type(value) == "table" -- 11
end -- 10
local SkillPriority = SkillPriority or ({}) -- 33
SkillPriority.BuiltIn = 0 -- 34
SkillPriority[SkillPriority.BuiltIn] = "BuiltIn" -- 34
SkillPriority.User = 1 -- 35
SkillPriority[SkillPriority.User] = "User" -- 35
SkillPriority.Project = 2 -- 36
SkillPriority[SkillPriority.Project] = "Project" -- 36
local function escapeXMLText(text) -- 50
	local result = string.gsub(text, "&", "&amp;") -- 51
	result = string.gsub(result, "<", "&lt;") -- 52
	result = string.gsub(result, ">", "&gt;") -- 53
	result = string.gsub(result, "\"", "&quot;") -- 54
	result = string.gsub(result, "'", "&apos;") -- 55
	return result -- 56
end -- 50
local function parseYAMLFrontmatter(content) -- 59
	if not content or __TS__StringTrim(content) == "" then -- 59
		return {metadata = nil, body = "", error = "empty content"} -- 65
	end -- 65
	local trimmed = __TS__StringTrim(content) -- 68
	if not __TS__StringStartsWith(trimmed, "---") then
		return {metadata = nil, body = content} -- 70
	end -- 70
	local lines = __TS__StringSplit(trimmed, "\n") -- 73
	local endLine = -1 -- 74
	do -- 74
		local i = 1 -- 75
		while i < #lines do -- 75
			if __TS__StringTrim(lines[i + 1]) == "---" then
				endLine = i -- 77
				break -- 78
			end -- 78
			i = i + 1 -- 75
		end -- 75
	end -- 75
	if endLine < 0 then -- 75
		return {metadata = nil, body = content, error = "missing closing ---"}
	end -- 83
	local frontmatterLines = __TS__ArraySlice(lines, 1, endLine) -- 86
	local frontmatterText = __TS__StringTrim(table.concat(frontmatterLines, "\n")) -- 87
	local metadata = parseSimpleYAML(frontmatterText) -- 89
	local bodyLines = __TS__ArraySlice(lines, endLine + 1) -- 91
	local body = __TS__StringTrim(table.concat(bodyLines, "\n")) -- 92
	return {metadata = metadata, body = body} -- 94
end -- 59
local function validateSkillMetadata(metadata) -- 183
	if not metadata then -- 183
		return {metadata = {name = "", description = ""}, error = "missing frontmatter"} -- 187
	end -- 187
	local name = type(metadata.name) == "string" and __TS__StringTrim(metadata.name) or "" -- 196
	if name == "" then -- 196
		return {metadata = {name = "", description = ""}, error = "missing name in frontmatter"} -- 198
	end -- 198
	local description = type(metadata.description) == "string" and __TS__StringTrim(metadata.description) or "" -- 207
	local always = metadata.always == true -- 211
	return {metadata = {name = name, description = description, always = always}} -- 213
end -- 183
local SkillsLoader = __TS__Class() -- 222
SkillsLoader.name = "SkillsLoader" -- 222
function SkillsLoader.prototype.____constructor(self, config) -- 227
	self.skills = __TS__New(Map) -- 224
	self.loaded = false -- 225
	self.config = config -- 228
end -- 227
function SkillsLoader.prototype.load(self) -- 231
	self.skills:clear() -- 232
	local builtInDir = Path(Content.assetPath, "Doc", "skills") -- 234
	local builtInParent = Content.assetPath -- 235
	self:loadSkillsFromDir(builtInDir, builtInParent, SkillPriority.BuiltIn) -- 236
	local userDir = Path(Content.writablePath, ".agent", "skills") -- 238
	local userParent = Content.writablePath -- 239
	self:loadSkillsFromDir(userDir, userParent, SkillPriority.User) -- 240
	local projectDir = Path(self.config.projectDir, ".agent", "skills") -- 242
	local projectParent = self.config.projectDir -- 243
	self:loadSkillsFromDir(projectDir, projectParent, SkillPriority.Project) -- 244
	self.loaded = true -- 246
	Log( -- 247
		"Info", -- 247
		("[SkillsLoader] Loaded " .. tostring(self.skills.size)) .. " skills" -- 247
	) -- 247
end -- 231
function SkillsLoader.prototype.loadSkillsFromDir(self, dir, parent, priority) -- 250
	if not Content:exist(dir) or not Content:isdir(dir) then -- 250
		return -- 252
	end -- 252
	local subdirs = Content:getDirs(dir) -- 255
	if not subdirs or #subdirs == 0 then -- 255
		return -- 257
	end -- 257
	for ____, subdir in ipairs(subdirs) do -- 260
		do -- 260
			local skillPath = Path(dir, subdir, "SKILL.md") -- 261
			if not Content:exist(skillPath) then -- 261
				goto __continue39 -- 263
			end -- 263
			local skill = self:loadSkillFile(skillPath) -- 266
			if not skill then -- 266
				goto __continue39 -- 268
			end -- 268
			skill.location = Path:getRelative(skillPath, parent) -- 271
			local existing = self.skills:get(skill.name) -- 273
			if existing and existing.priority >= priority then -- 273
				goto __continue39 -- 275
			end -- 275
			self.skills:set(skill.name, {skill = skill, priority = priority}) -- 278
		end -- 278
		::__continue39:: -- 278
	end -- 278
end -- 250
function SkillsLoader.prototype.loadSkillFile(self, skillPath) -- 282
	local content = Content:load(skillPath) -- 283
	if not content then -- 283
		Log("Warn", "[SkillsLoader] Failed to read " .. skillPath) -- 285
		return nil -- 286
	end -- 286
	local parsed = parseYAMLFrontmatter(content) -- 289
	local validated = validateSkillMetadata(parsed.metadata) -- 290
	if validated.error then -- 290
		Log("Warn", (("[SkillsLoader] Invalid SKILL.md at " .. skillPath) .. ": ") .. validated.error) -- 293
		return nil -- 294
	end -- 294
	local displayLocation = skillPath -- 297
	if __TS__StringStartsWith(skillPath, self.config.projectDir) then -- 297
		displayLocation = Path:getRelative(skillPath, self.config.projectDir) -- 299
	end -- 299
	local skill = __TS__ObjectAssign({}, validated.metadata, {location = displayLocation, body = parsed.body}) -- 302
	return skill -- 308
end -- 282
function SkillsLoader.prototype.getAllSkills(self) -- 311
	if not self.loaded then -- 311
		self:load() -- 313
	end -- 313
	local result = {} -- 316
	for ____, entry in __TS__Iterator(self.skills:values()) do -- 317
		result[#result + 1] = entry.skill -- 318
	end -- 318
	__TS__ArraySort( -- 321
		result, -- 321
		function(____, a, b) -- 321
			if a.name < b.name then -- 321
				return -1 -- 323
			end -- 323
			if a.name > b.name then -- 323
				return 1 -- 326
			end -- 326
			if a.location < b.location then -- 326
				return -1 -- 329
			end -- 329
			if a.location > b.location then -- 329
				return 1 -- 332
			end -- 332
			return 0 -- 334
		end -- 321
	) -- 321
	return result -- 337
end -- 311
function SkillsLoader.prototype.getSkill(self, name) -- 340
	if not self.loaded then -- 340
		self:load() -- 342
	end -- 342
	local ____opt_0 = self.skills:get(name) -- 342
	return ____opt_0 and ____opt_0.skill -- 345
end -- 340
function SkillsLoader.prototype.getAlwaysSkills(self) -- 348
	local all = self:getAllSkills() -- 349
	return __TS__ArrayFilter( -- 350
		all, -- 350
		function(____, skill) return skill.always == true end -- 350
	) -- 350
end -- 348
function SkillsLoader.prototype.getSummarySkills(self) -- 353
	local all = self:getAllSkills() -- 354
	return __TS__ArrayFilter( -- 355
		all, -- 355
		function(____, skill) return skill.always ~= true end -- 355
	) -- 355
end -- 353
function SkillsLoader.prototype.buildLevel1Summary(self) -- 358
	local skills = self:getSummarySkills() -- 359
	if #skills == 0 then -- 359
		return "" -- 362
	end -- 362
	local parts = {} -- 365
	for ____, skill in ipairs(skills) do -- 367
		local skillXML = "<skill>\n" -- 368
		skillXML = skillXML .. ("\t<name>" .. self:escapeXML(skill.name)) .. "</name>\n" -- 369
		skillXML = skillXML .. ("\t<description>" .. self:escapeXML(skill.description)) .. "</description>\n" -- 370
		skillXML = skillXML .. ("\t<location>" .. self:escapeXML(skill.location)) .. "</location>\n" -- 371
		skillXML = skillXML .. "</skill>" -- 372
		parts[#parts + 1] = skillXML -- 373
	end -- 373
	return table.concat(parts, "\n\n") -- 376
end -- 358
function SkillsLoader.prototype.buildActiveSkillsContent(self) -- 379
	local skills = self:getAlwaysSkills() -- 380
	if #skills == 0 then -- 380
		return "" -- 383
	end -- 383
	local parts = {} -- 386
	for ____, skill in ipairs(skills) do -- 388
		parts[#parts + 1] = ("## Skill: " .. skill.name) .. "\n" -- 389
		if skill.description ~= nil then -- 389
			parts[#parts + 1] = skill.description .. "\n" -- 391
		end -- 391
		if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 391
			parts[#parts + 1] = "\n" .. skill.body -- 394
		end -- 394
		parts[#parts + 1] = "" -- 396
	end -- 396
	return table.concat(parts, "\n") -- 399
end -- 379
function SkillsLoader.prototype.loadSkillContent(self, name) -- 402
	local skill = self:getSkill(name) -- 403
	if not skill then -- 403
		return nil -- 405
	end -- 405
	if skill.body and __TS__StringTrim(skill.body) ~= "" then -- 405
		return skill.body -- 409
	end -- 409
	local content = Content:load(skill.location) -- 412
	if not content then -- 412
		return nil -- 414
	end -- 414
	local parsed = parseYAMLFrontmatter(content) -- 417
	return parsed.body or nil -- 418
end -- 402
function SkillsLoader.prototype.buildSkillsPromptSection(self) -- 421
	if not self.loaded then -- 421
		self:load() -- 423
	end -- 423
	local sections = {} -- 426
	local activeContent = self:buildActiveSkillsContent() -- 428
	sections[#sections + 1] = "# Active Skills\n\n" .. activeContent -- 429
	local summary = self:buildLevel1Summary() -- 431
	sections[#sections + 1] = "# Skills\n\nRead a skill's SKILL.md with `read_file` for full instructions.\n\n" .. summary -- 432
	return table.concat(sections, "\n\n---\n\n")
end -- 421
function SkillsLoader.prototype.escapeXML(self, text) -- 437
	return escapeXMLText(text) -- 438
end -- 437
function SkillsLoader.prototype.reload(self) -- 441
	self.loaded = false -- 442
	self:load() -- 443
end -- 441
function SkillsLoader.prototype.getSkillCount(self) -- 446
	if not self.loaded then -- 446
		self:load() -- 448
	end -- 448
	return self.skills.size -- 450
end -- 446
local function createSkillsLoader(config) -- 454
	return __TS__New(SkillsLoader, config) -- 455
end -- 454
____exports.AGENT_USER_PROMPT_MAX_CHARS = 12000 -- 539
local HISTORY_READ_FILE_MAX_CHARS = 12000 -- 642
local HISTORY_READ_FILE_MAX_LINES = 300 -- 643
READ_FILE_DEFAULT_LIMIT = 300 -- 644
local HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 645
local HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 646
local HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 647
SEARCH_DORA_API_LIMIT_MAX = 20 -- 648
SEARCH_FILES_LIMIT_DEFAULT = 20 -- 649
LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 650
local SEARCH_PREVIEW_CONTEXT = 80 -- 651
local AGENT_DEFAULT_MAX_STEPS = 100 -- 652
local AGENT_DEFAULT_LLM_MAX_TRY = 5 -- 653
local AGENT_DEFAULT_LLM_TEMPERATURE = 0.1 -- 654
local AGENT_DEFAULT_LLM_MAX_TOKENS = 8192 -- 655
local function buildLLMOptions(llmConfig, overrides) -- 657
	local options = {temperature = llmConfig.temperature or AGENT_DEFAULT_LLM_TEMPERATURE, max_tokens = llmConfig.maxTokens or AGENT_DEFAULT_LLM_MAX_TOKENS} -- 658
	if llmConfig.reasoningEffort then -- 658
		options.reasoning_effort = llmConfig.reasoningEffort -- 663
	end -- 663
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 665
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 665
		__TS__Delete(merged, "reasoning_effort") -- 670
	else -- 670
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 672
	end -- 672
	return merged -- 674
end -- 657
local function emitAgentStartEvent(shared, action) -- 736
	emitAgentEvent(shared, { -- 737
		type = "tool_started", -- 738
		sessionId = shared.sessionId, -- 739
		taskId = shared.taskId, -- 740
		step = action.step, -- 741
		tool = action.tool -- 742
	}) -- 742
end -- 736
local function emitAgentFinishEvent(shared, action) -- 746
	emitAgentEvent(shared, { -- 747
		type = "tool_finished", -- 748
		sessionId = shared.sessionId, -- 749
		taskId = shared.taskId, -- 750
		step = action.step, -- 751
		tool = action.tool, -- 752
		result = action.result or ({}) -- 753
	}) -- 753
end -- 746
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 757
	emitAgentEvent(shared, { -- 758
		type = "assistant_message_updated", -- 759
		sessionId = shared.sessionId, -- 760
		taskId = shared.taskId, -- 761
		step = shared.step + 1, -- 762
		content = content, -- 763
		reasoningContent = reasoningContent -- 764
	}) -- 764
end -- 757
local function getMemoryCompressionStartReason(shared) -- 768
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 769
end -- 768
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 774
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 775
end -- 774
local function getMemoryCompressionFailureReason(shared, ____error) -- 780
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 781
end -- 780
local function summarizeHistoryEntryPreview(text, maxChars) -- 786
	if maxChars == nil then -- 786
		maxChars = 180 -- 786
	end -- 786
	local trimmed = __TS__StringTrim(text) -- 787
	if trimmed == "" then -- 787
		return "" -- 788
	end -- 788
	return truncateText(trimmed, maxChars) -- 789
end -- 786
local function getCancelledReason(shared) -- 792
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 792
		return shared.stopToken.reason -- 793
	end -- 793
	return shared.useChineseResponse and "已取消" or "cancelled" -- 794
end -- 792
local function getMaxStepsReachedReason(shared) -- 797
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 798
end -- 797
local function getFailureSummaryFallback(shared, ____error) -- 803
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 804
end -- 803
local function finalizeAgentFailure(shared, ____error) -- 809
	if shared.stopToken.stopped then -- 809
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 811
		return emitAgentTaskFinishEvent( -- 812
			shared, -- 812
			false, -- 812
			getCancelledReason(shared) -- 812
		) -- 812
	end -- 812
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 814
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 815
end -- 809
local function getPromptCommand(prompt) -- 818
	local trimmed = __TS__StringTrim(prompt) -- 819
	if trimmed == "/compact" then -- 819
		return "compact" -- 820
	end -- 820
	if trimmed == "/clear" then -- 820
		return "clear" -- 821
	end -- 821
	return nil -- 822
end -- 818
function ____exports.truncateAgentUserPrompt(prompt) -- 825
	if not prompt then -- 825
		return "" -- 826
	end -- 826
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 826
		return prompt -- 827
	end -- 827
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 828
	if offset == nil then -- 828
		return prompt -- 829
	end -- 829
	return string.sub(prompt, 1, offset - 1) -- 830
end -- 825
local function canWriteStepLLMDebug(shared, stepId) -- 833
	if stepId == nil then -- 833
		stepId = shared.step + 1 -- 833
	end -- 833
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 834
end -- 833
local function ensureDirRecursive(dir) -- 841
	if not dir then -- 841
		return false -- 842
	end -- 842
	if Content:exist(dir) then -- 842
		return Content:isdir(dir) -- 843
	end -- 843
	local parent = Path:getPath(dir) -- 844
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 844
		return false -- 846
	end -- 846
	return Content:mkdir(dir) -- 848
end -- 841
local function encodeDebugJSON(value) -- 851
	local text, err = safeJsonEncode(value) -- 852
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 853
end -- 851
local function getStepLLMDebugDir(shared) -- 856
	return Path( -- 857
		shared.workingDir, -- 858
		".agent", -- 859
		tostring(shared.sessionId), -- 860
		tostring(shared.taskId) -- 861
	) -- 861
end -- 856
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 865
	return Path( -- 866
		getStepLLMDebugDir(shared), -- 866
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 866
	) -- 866
end -- 865
local function getLatestStepLLMDebugSeq(shared, stepId) -- 869
	if not canWriteStepLLMDebug(shared, stepId) then -- 869
		return 0 -- 870
	end -- 870
	local dir = getStepLLMDebugDir(shared) -- 871
	if not Content:exist(dir) or not Content:isdir(dir) then -- 871
		return 0 -- 872
	end -- 872
	local latest = 0 -- 873
	for ____, file in ipairs(Content:getFiles(dir)) do -- 874
		do -- 874
			local name = Path:getFilename(file) -- 875
			local seqText = string.match( -- 876
				name, -- 876
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 876
			) -- 876
			if seqText ~= nil then -- 876
				latest = math.max( -- 878
					latest, -- 878
					tonumber(seqText) -- 878
				) -- 878
				goto __continue124 -- 879
			end -- 879
			local legacyMatch = string.match( -- 881
				name, -- 881
				("^" .. tostring(stepId)) .. "_in%.md$" -- 881
			) -- 881
			if legacyMatch ~= nil then -- 881
				latest = math.max(latest, 1) -- 883
			end -- 883
		end -- 883
		::__continue124:: -- 883
	end -- 883
	return latest -- 886
end -- 869
local function writeStepLLMDebugFile(path, content) -- 889
	if not Content:save(path, content) then -- 889
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 891
		return false -- 892
	end -- 892
	return true -- 894
end -- 889
local function createStepLLMDebugPair(shared, stepId, inContent) -- 897
	if not canWriteStepLLMDebug(shared, stepId) then -- 897
		return 0 -- 898
	end -- 898
	local dir = getStepLLMDebugDir(shared) -- 899
	if not ensureDirRecursive(dir) then -- 899
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 901
		return 0 -- 902
	end -- 902
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 904
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 905
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 906
	if not writeStepLLMDebugFile(inPath, inContent) then -- 906
		return 0 -- 908
	end -- 908
	writeStepLLMDebugFile(outPath, "") -- 910
	return seq -- 911
end -- 897
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 914
	if not canWriteStepLLMDebug(shared, stepId) then -- 914
		return -- 915
	end -- 915
	local dir = getStepLLMDebugDir(shared) -- 916
	if not ensureDirRecursive(dir) then -- 916
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 918
		return -- 919
	end -- 919
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 921
	if latestSeq <= 0 then -- 921
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 923
		writeStepLLMDebugFile(outPath, content) -- 924
		return -- 925
	end -- 925
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 927
	writeStepLLMDebugFile(outPath, content) -- 928
end -- 914
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 931
	if not canWriteStepLLMDebug(shared, stepId) then -- 931
		return -- 932
	end -- 932
	local sections = { -- 933
		"# LLM Input", -- 934
		"session_id: " .. tostring(shared.sessionId), -- 935
		"task_id: " .. tostring(shared.taskId), -- 936
		"step_id: " .. tostring(stepId), -- 937
		"phase: " .. phase, -- 938
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 939
		"## Options", -- 940
		"```json", -- 941
		encodeDebugJSON(options), -- 942
		"```" -- 943
	} -- 943
	do -- 943
		local i = 0 -- 945
		while i < #messages do -- 945
			local message = messages[i + 1] -- 946
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 947
			sections[#sections + 1] = encodeDebugJSON(message) -- 948
			i = i + 1 -- 945
		end -- 945
	end -- 945
	createStepLLMDebugPair( -- 950
		shared, -- 950
		stepId, -- 950
		table.concat(sections, "\n") -- 950
	) -- 950
end -- 931
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 953
	if not canWriteStepLLMDebug(shared, stepId) then -- 953
		return -- 954
	end -- 954
	local ____array_2 = __TS__SparseArrayNew( -- 954
		"# LLM Output", -- 956
		"session_id: " .. tostring(shared.sessionId), -- 957
		"task_id: " .. tostring(shared.taskId), -- 958
		"step_id: " .. tostring(stepId), -- 959
		"phase: " .. phase, -- 960
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 961
		table.unpack(meta and ({ -- 962
			"## Meta", -- 962
			"```json", -- 962
			encodeDebugJSON(meta), -- 962
			"```" -- 962
		}) or ({})) -- 962
	) -- 962
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 962
	local sections = {__TS__SparseArraySpread(____array_2)} -- 955
	updateLatestStepLLMDebugOutput( -- 966
		shared, -- 966
		stepId, -- 966
		table.concat(sections, "\n") -- 966
	) -- 966
end -- 953
local function toJson(value) -- 969
	local text, err = safeJsonEncode(value) -- 970
	if text ~= nil then -- 970
		return text -- 971
	end -- 971
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 972
end -- 969
local function utf8TakeHead(text, maxChars) -- 982
	if maxChars <= 0 or text == "" then -- 982
		return "" -- 983
	end -- 983
	local nextPos = utf8.offset(text, maxChars + 1) -- 984
	if nextPos == nil then -- 984
		return text -- 985
	end -- 985
	return string.sub(text, 1, nextPos - 1) -- 986
end -- 982
local function limitReadContentForHistory(content, tool) -- 1003
	local lines = __TS__StringSplit(content, "\n") -- 1004
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 1005
	local limitedByLines = overLineLimit and table.concat( -- 1006
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 1007
		"\n" -- 1007
	) or content -- 1007
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 1007
		return content -- 1010
	end -- 1010
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 1012
	local reasons = {} -- 1015
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 1015
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 1016
	end -- 1016
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 1016
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 1017
	end -- 1017
	local hint = "Narrow the requested line range." -- 1018
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 1019
end -- 1003
local function summarizeEditTextParamForHistory(value, key) -- 1022
	if type(value) ~= "string" then -- 1022
		return nil -- 1023
	end -- 1023
	local text = value -- 1024
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 1025
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 1026
end -- 1022
local function sanitizeReadResultForHistory(tool, result) -- 1034
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 1034
		return result -- 1036
	end -- 1036
	local clone = {} -- 1038
	for key in pairs(result) do -- 1039
		clone[key] = result[key] -- 1040
	end -- 1040
	clone.content = limitReadContentForHistory(result.content, tool) -- 1042
	return clone -- 1043
end -- 1034
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 1046
	local shown = math.min(#items, maxItems) -- 1050
	local out = {} -- 1051
	do -- 1051
		local i = 0 -- 1052
		while i < shown do -- 1052
			local row = items[i + 1] -- 1053
			out[#out + 1] = { -- 1054
				file = row.file, -- 1055
				line = row.line, -- 1056
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1057
			} -- 1057
			i = i + 1 -- 1052
		end -- 1052
	end -- 1052
	return out -- 1062
end -- 1046
local function sanitizeSearchResultForHistory(tool, result) -- 1065
	if result.success ~= true or not isArray(result.results) then -- 1065
		return result -- 1069
	end -- 1069
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1069
		return result -- 1070
	end -- 1070
	local clone = {} -- 1071
	for key in pairs(result) do -- 1072
		clone[key] = result[key] -- 1073
	end -- 1073
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 1075
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1076
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1076
		local grouped = result.groupedResults -- 1081
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 1082
		local sanitizedGroups = {} -- 1083
		do -- 1083
			local i = 0 -- 1084
			while i < shown do -- 1084
				local row = grouped[i + 1] -- 1085
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1086
					file = row.file, -- 1087
					totalMatches = row.totalMatches, -- 1088
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1089
				} -- 1089
				i = i + 1 -- 1084
			end -- 1084
		end -- 1084
		clone.groupedResults = sanitizedGroups -- 1094
	end -- 1094
	return clone -- 1096
end -- 1065
local function sanitizeListFilesResultForHistory(result) -- 1099
	if result.success ~= true or not isArray(result.files) then -- 1099
		return result -- 1100
	end -- 1100
	local clone = {} -- 1101
	for key in pairs(result) do -- 1102
		clone[key] = result[key] -- 1103
	end -- 1103
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1105
	return clone -- 1106
end -- 1099
local function sanitizeActionParamsForHistory(tool, params) -- 1109
	if tool ~= "edit_file" then -- 1109
		return params -- 1110
	end -- 1110
	local clone = {} -- 1111
	for key in pairs(params) do -- 1112
		if key == "old_str" then -- 1112
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1114
		elseif key == "new_str" then -- 1114
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1116
		else -- 1116
			clone[key] = params[key] -- 1118
		end -- 1118
	end -- 1118
	return clone -- 1121
end -- 1109
local function isToolAllowedForRole(role, tool) -- 1166
	return __TS__ArrayIndexOf( -- 1167
		getAllowedToolsForRole(role), -- 1167
		tool -- 1167
	) >= 0 -- 1167
end -- 1166
local PRE_EXEC_SAFE_TOOLS = {
	"read_file",
	"grep_files",
	"search_dora_api",
	"glob_files",
	"list_sub_agents"
}
function canPreExecuteTool(tool)
	return __TS__ArrayIndexOf(PRE_EXEC_SAFE_TOOLS, tool) >= 0
end
function clearPreExecutedResults(shared)
	shared.preExecutedResults = nil
end
function startPreExecutedToolAction(shared, action)
	return __TS__AsyncAwaiter(function(____awaiter_resolve)
		local ____try = __TS__AsyncAwaiter(function()
			return ____awaiter_resolve(
				nil,
				__TS__Await(executeToolAction(shared, action))
			)
		end)
		__TS__Await(____try.catch(
			____try,
			function(____, err)
				local message = tostring(err)
				Log("Error", ((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId .. ": ") .. message)
				return ____awaiter_resolve(nil, {success = false, message = message})
			end
		))
	end)
end
function executeToolActionWithPreExecution(shared, action)
	return __TS__AsyncAwaiter(function(____awaiter_resolve)
		local preResult = shared.preExecutedResults and shared.preExecutedResults:get(action.toolCallId) or nil
		if preResult then
			Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId)
			if shared.preExecutedResults then
				shared.preExecutedResults:delete(action.toolCallId)
			end
			return ____awaiter_resolve(
				nil,
				__TS__Await(preResult)
			)
		end
		return ____awaiter_resolve(
			nil,
			executeToolAction(shared, action)
		)
	end)
end
local function maybeCompressHistory(shared) -- 1170
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1170
		local ____shared_9 = shared -- 1171
		local memory = ____shared_9.memory -- 1171
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1172
		local changed = false -- 1173
		do -- 1173
			local round = 0 -- 1174
			while round < maxRounds do -- 1174
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1175
				local activeMessages = getActiveConversationMessages(shared) -- 1176
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1180
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 1180
					if changed then -- 1180
						persistHistoryState(shared) -- 1189
					end -- 1189
					return ____awaiter_resolve(nil) -- 1189
				end -- 1189
				local compressionRound = round + 1 -- 1193
				shared.step = shared.step + 1 -- 1194
				local stepId = shared.step -- 1195
				local pendingMessages = #activeMessages -- 1196
				emitAgentEvent( -- 1197
					shared, -- 1197
					{ -- 1197
						type = "memory_compression_started", -- 1198
						sessionId = shared.sessionId, -- 1199
						taskId = shared.taskId, -- 1200
						step = stepId, -- 1201
						tool = "compress_memory", -- 1202
						reason = getMemoryCompressionStartReason(shared), -- 1203
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1204
					} -- 1204
				) -- 1204
				local result = __TS__Await(memory.compressor:compress( -- 1210
					activeMessages, -- 1211
					shared.llmOptions, -- 1212
					shared.llmMaxTry, -- 1213
					shared.decisionMode, -- 1214
					{ -- 1215
						onInput = function(____, phase, messages, options) -- 1216
							saveStepLLMDebugInput( -- 1217
								shared, -- 1217
								stepId, -- 1217
								phase, -- 1217
								messages, -- 1217
								options -- 1217
							) -- 1217
						end, -- 1216
						onOutput = function(____, phase, text, meta) -- 1219
							saveStepLLMDebugOutput( -- 1220
								shared, -- 1220
								stepId, -- 1220
								phase, -- 1220
								text, -- 1220
								meta -- 1220
							) -- 1220
						end -- 1219
					}, -- 1219
					"default", -- 1223
					systemPrompt, -- 1224
					toolDefinitions -- 1225
				)) -- 1225
				if not (result and result.success and result.compressedCount > 0) then -- 1225
					emitAgentEvent( -- 1228
						shared, -- 1228
						{ -- 1228
							type = "memory_compression_finished", -- 1229
							sessionId = shared.sessionId, -- 1230
							taskId = shared.taskId, -- 1231
							step = stepId, -- 1232
							tool = "compress_memory", -- 1233
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1234
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1238
						} -- 1238
					) -- 1238
					if changed then -- 1238
						persistHistoryState(shared) -- 1246
					end -- 1246
					return ____awaiter_resolve(nil) -- 1246
				end -- 1246
				local effectiveCompressedCount = math.max( -- 1250
					0, -- 1251
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1252
				) -- 1252
				if effectiveCompressedCount <= 0 then -- 1252
					if changed then -- 1252
						persistHistoryState(shared) -- 1256
					end -- 1256
					return ____awaiter_resolve(nil) -- 1256
				end -- 1256
				emitAgentEvent( -- 1260
					shared, -- 1260
					{ -- 1260
						type = "memory_compression_finished", -- 1261
						sessionId = shared.sessionId, -- 1262
						taskId = shared.taskId, -- 1263
						step = stepId, -- 1264
						tool = "compress_memory", -- 1265
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1266
						result = { -- 1267
							success = true, -- 1268
							round = compressionRound, -- 1269
							compressedCount = effectiveCompressedCount, -- 1270
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1271
						} -- 1271
					} -- 1271
				) -- 1271
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1274
				changed = true -- 1275
				Log( -- 1276
					"Info", -- 1276
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1276
				) -- 1276
				round = round + 1 -- 1174
			end -- 1174
		end -- 1174
		if changed then -- 1174
			persistHistoryState(shared) -- 1279
		end -- 1279
	end) -- 1279
end -- 1170
local function compactAllHistory(shared) -- 1283
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1283
		local ____shared_16 = shared -- 1284
		local memory = ____shared_16.memory -- 1284
		local rounds = 0 -- 1285
		local totalCompressed = 0 -- 1286
		while getActiveRealMessageCount(shared) > 0 do -- 1286
			if shared.stopToken.stopped then -- 1286
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1289
				return ____awaiter_resolve( -- 1289
					nil, -- 1289
					emitAgentTaskFinishEvent( -- 1290
						shared, -- 1290
						false, -- 1290
						getCancelledReason(shared) -- 1290
					) -- 1290
				) -- 1290
			end -- 1290
			rounds = rounds + 1 -- 1292
			shared.step = shared.step + 1 -- 1293
			local stepId = shared.step -- 1294
			local activeMessages = getActiveConversationMessages(shared) -- 1295
			local pendingMessages = #activeMessages -- 1296
			emitAgentEvent( -- 1297
				shared, -- 1297
				{ -- 1297
					type = "memory_compression_started", -- 1298
					sessionId = shared.sessionId, -- 1299
					taskId = shared.taskId, -- 1300
					step = stepId, -- 1301
					tool = "compress_memory", -- 1302
					reason = getMemoryCompressionStartReason(shared), -- 1303
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1304
				} -- 1304
			) -- 1304
			local result = __TS__Await(memory.compressor:compress( -- 1311
				activeMessages, -- 1312
				shared.llmOptions, -- 1313
				shared.llmMaxTry, -- 1314
				shared.decisionMode, -- 1315
				{ -- 1316
					onInput = function(____, phase, messages, options) -- 1317
						saveStepLLMDebugInput( -- 1318
							shared, -- 1318
							stepId, -- 1318
							phase, -- 1318
							messages, -- 1318
							options -- 1318
						) -- 1318
					end, -- 1317
					onOutput = function(____, phase, text, meta) -- 1320
						saveStepLLMDebugOutput( -- 1321
							shared, -- 1321
							stepId, -- 1321
							phase, -- 1321
							text, -- 1321
							meta -- 1321
						) -- 1321
					end -- 1320
				}, -- 1320
				"budget_max" -- 1324
			)) -- 1324
			if not (result and result.success and result.compressedCount > 0) then -- 1324
				emitAgentEvent( -- 1327
					shared, -- 1327
					{ -- 1327
						type = "memory_compression_finished", -- 1328
						sessionId = shared.sessionId, -- 1329
						taskId = shared.taskId, -- 1330
						step = stepId, -- 1331
						tool = "compress_memory", -- 1332
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1333
						result = { -- 1337
							success = false, -- 1338
							rounds = rounds, -- 1339
							error = result and result.error or "compression returned no changes", -- 1340
							compressedCount = result and result.compressedCount or 0, -- 1341
							fullCompaction = true -- 1342
						} -- 1342
					} -- 1342
				) -- 1342
				return ____awaiter_resolve( -- 1342
					nil, -- 1342
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1345
				) -- 1345
			end -- 1345
			local effectiveCompressedCount = math.max( -- 1350
				0, -- 1351
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1352
			) -- 1352
			if effectiveCompressedCount <= 0 then -- 1352
				return ____awaiter_resolve( -- 1352
					nil, -- 1352
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1355
				) -- 1355
			end -- 1355
			emitAgentEvent( -- 1362
				shared, -- 1362
				{ -- 1362
					type = "memory_compression_finished", -- 1363
					sessionId = shared.sessionId, -- 1364
					taskId = shared.taskId, -- 1365
					step = stepId, -- 1366
					tool = "compress_memory", -- 1367
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1368
					result = { -- 1369
						success = true, -- 1370
						round = rounds, -- 1371
						compressedCount = effectiveCompressedCount, -- 1372
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1373
						fullCompaction = true -- 1374
					} -- 1374
				} -- 1374
			) -- 1374
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1377
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1378
			persistHistoryState(shared) -- 1379
			Log( -- 1380
				"Info", -- 1380
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1380
			) -- 1380
		end -- 1380
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1382
		return ____awaiter_resolve( -- 1382
			nil, -- 1382
			emitAgentTaskFinishEvent( -- 1383
				shared, -- 1384
				true, -- 1385
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1386
			) -- 1386
		) -- 1386
	end) -- 1386
end -- 1283
local function clearSessionHistory(shared) -- 1392
	shared.messages = {} -- 1393
	shared.lastConsolidatedIndex = 0 -- 1394
	shared.carryMessageIndex = nil -- 1395
	persistHistoryState(shared) -- 1396
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1397
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1398
end -- 1392
local function isKnownToolName(name) -- 1407
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1408
end -- 1407
local function appendConversationMessage(shared, message) -- 1501
	local ____shared_messages_25 = shared.messages -- 1501
	____shared_messages_25[#____shared_messages_25 + 1] = __TS__ObjectAssign( -- 1502
		{}, -- 1502
		message, -- 1503
		{ -- 1502
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1504
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1505
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1506
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1507
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1508
		} -- 1508
	) -- 1508
end -- 1501
local function ensureToolCallId(toolCallId) -- 1512
	if toolCallId and toolCallId ~= "" then -- 1512
		return toolCallId -- 1513
	end -- 1513
	return createLocalToolCallId() -- 1514
end -- 1512
local function appendToolResultMessage(shared, action) -- 1517
	appendConversationMessage( -- 1518
		shared, -- 1518
		{ -- 1518
			role = "tool", -- 1519
			tool_call_id = action.toolCallId, -- 1520
			name = action.tool, -- 1521
			content = action.result and toJson(action.result) or "" -- 1522
		} -- 1522
	) -- 1522
end -- 1517
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1526
	appendConversationMessage( -- 1532
		shared, -- 1532
		{ -- 1532
			role = "assistant", -- 1533
			content = content or "", -- 1534
			reasoning_content = reasoningContent, -- 1535
			tool_calls = __TS__ArrayMap( -- 1536
				actions, -- 1536
				function(____, action) return { -- 1536
					id = action.toolCallId, -- 1537
					type = "function", -- 1538
					["function"] = { -- 1539
						name = action.tool, -- 1540
						arguments = toJson(action.params) -- 1541
					} -- 1541
				} end -- 1541
			) -- 1541
		} -- 1541
	) -- 1541
end -- 1526
local function parseXMLToolCallObjectFromText(text) -- 1547
	local children = parseXMLObjectFromText(text, "tool_call") -- 1548
	if not children.success then -- 1548
		return children -- 1549
	end -- 1549
	local rawObj = children.obj -- 1550
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1551
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1552
	if not params.success then -- 1552
		return {success = false, message = params.message} -- 1556
	end -- 1556
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1558
end -- 1547
local function llm(shared, messages, phase) -- 1578
	if phase == nil then -- 1578
		phase = "decision_xml" -- 1581
	end -- 1581
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1581
		local stepId = shared.step + 1 -- 1583
		saveStepLLMDebugInput( -- 1584
			shared, -- 1584
			stepId, -- 1584
			phase, -- 1584
			messages, -- 1584
			shared.llmOptions -- 1584
		) -- 1584
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1585
		if res.success then -- 1585
			local ____opt_28 = res.response.choices -- 1585
			local ____opt_26 = ____opt_28 and ____opt_28[1] -- 1585
			local message = ____opt_26 and ____opt_26.message -- 1587
			local text = message and message.content -- 1588
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1589
			if text then -- 1589
				saveStepLLMDebugOutput( -- 1593
					shared, -- 1593
					stepId, -- 1593
					phase, -- 1593
					text, -- 1593
					{success = true} -- 1593
				) -- 1593
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1593
			else -- 1593
				saveStepLLMDebugOutput( -- 1596
					shared, -- 1596
					stepId, -- 1596
					phase, -- 1596
					"empty LLM response", -- 1596
					{success = false} -- 1596
				) -- 1596
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1596
			end -- 1596
		else -- 1596
			saveStepLLMDebugOutput( -- 1600
				shared, -- 1600
				stepId, -- 1600
				phase, -- 1600
				res.raw or res.message, -- 1600
				{success = false} -- 1600
			) -- 1600
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1600
		end -- 1600
	end) -- 1600
end -- 1578
local function isDecisionBatchSuccess(result) -- 1624
	return result.kind == "batch" -- 1625
end -- 1624
local function parseDecisionObject(rawObj) -- 1628
	if type(rawObj.tool) ~= "string" then -- 1628
		return {success = false, message = "missing tool"} -- 1629
	end -- 1629
	local tool = rawObj.tool -- 1630
	if not isKnownToolName(tool) then -- 1630
		return {success = false, message = "unknown tool: " .. tool} -- 1632
	end -- 1632
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1634
	if tool ~= "finish" and (not reason or reason == "") then -- 1634
		return {success = false, message = tool .. " requires top-level reason"} -- 1638
	end -- 1638
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1640
	return {success = true, tool = tool, params = params, reason = reason} -- 1641
end -- 1628
local function parseDecisionToolCall(functionName, rawObj) -- 1649
	if not isKnownToolName(functionName) then -- 1649
		return {success = false, message = "unknown tool: " .. functionName} -- 1651
	end -- 1651
	if rawObj == nil or rawObj == nil then -- 1651
		return {success = true, tool = functionName, params = {}} -- 1654
	end -- 1654
	if not isRecord(rawObj) then -- 1654
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1657
	end -- 1657
	return {success = true, tool = functionName, params = rawObj} -- 1659
end -- 1649
local function parseToolCallArguments(functionName, argsText) -- 1666
	if __TS__StringTrim(argsText) == "" then -- 1666
		return {} -- 1668
	end -- 1668
	local rawObj, err = safeJsonDecode(argsText) -- 1670
	if err ~= nil or rawObj == nil then -- 1670
		return { -- 1672
			success = false, -- 1673
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1674
			raw = argsText -- 1675
		} -- 1675
	end -- 1675
	local encodedRaw = safeJsonEncode(rawObj) -- 1678
	if encodedRaw == "null" or not isRecord(rawObj) or isArray(rawObj) then -- 1678
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1680
	end -- 1680
	return rawObj -- 1686
end -- 1666
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1689
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1697
	if isRecord(rawArgs) and rawArgs.success == false then -- 1697
		return rawArgs -- 1699
	end -- 1699
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1701
	if not decision.success then -- 1701
		return {success = false, message = decision.message, raw = argsText} -- 1703
	end -- 1703
	local validation = validateDecision(decision.tool, decision.params) -- 1709
	if not validation.success then -- 1709
		return {success = false, message = validation.message, raw = argsText} -- 1711
	end -- 1711
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1711
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1718
	end -- 1718
	decision.params = validation.params -- 1724
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1725
	decision.reason = reason -- 1726
	decision.reasoningContent = reasoningContent -- 1727
	return decision -- 1728
end -- 1689
function createPreExecutableActionFromStream(shared, toolCall)
	local fn = toolCall and toolCall["function"]
	local functionName = fn and fn.name or nil
	local argsText = fn and fn.arguments or ""
	local toolCallId = type(toolCall and toolCall.id) == "string" and toolCall.id or nil
	if not functionName or not toolCallId then
		return nil
	end
	local rawArgs = parseToolCallArguments(functionName, argsText)
	if isRecord(rawArgs) and rawArgs.success == false then
		return nil
	end
	local decision = parseDecisionToolCall(functionName, rawArgs)
	if not decision.success or not canPreExecuteTool(decision.tool) then
		return nil
	end
	local validation = validateDecision(decision.tool, decision.params)
	if not validation.success then
		return nil
	end
	if not isToolAllowedForRole(shared.role, decision.tool) then
		return nil
	end
	return {
		step = shared.step + 1,
		toolCallId = toolCallId,
		tool = decision.tool,
		reason = "",
		params = validation.params,
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
	}
end
local function createFunctionToolSchema(name, description, properties, required) -- 1867
	if required == nil then -- 1867
		required = {} -- 1871
	end -- 1871
	local parameters = {type = "object", properties = properties} -- 1873
	if #required > 0 then -- 1873
		parameters.required = required -- 1878
	end -- 1878
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1880
end -- 1867
local function buildDecisionToolSchema(shared) -- 1896
	local allowed = getAllowedToolsForRole(shared.role) -- 1897
	local tools = { -- 1898
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 1899
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 1909
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1919
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1927
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1931
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1932
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1933
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1934
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1935
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1936
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1937
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1938
		}, {"pattern"}), -- 1938
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 1942
		createFunctionToolSchema( -- 1951
			"search_dora_api", -- 1952
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 1952
			{ -- 1954
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 1955
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 1956
				programmingLanguage = {type = "string", enum = { -- 1957
					"ts", -- 1959
					"tsx", -- 1959
					"lua", -- 1959
					"yue", -- 1959
					"teal", -- 1959
					"tl", -- 1959
					"wa" -- 1959
				}, description = "Preferred language variant to search."}, -- 1959
				limit = { -- 1962
					type = "number", -- 1962
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 1962
				}, -- 1962
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 1963
			}, -- 1963
			{"pattern"} -- 1965
		), -- 1965
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 1967
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 1974
			"active_or_recent", -- 1978
			"running", -- 1978
			"done", -- 1978
			"failed", -- 1978
			"all" -- 1978
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 1978
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 1984
	} -- 1984
	return __TS__ArrayFilter( -- 1996
		tools, -- 1996
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 1996
	) -- 1996
end -- 1896
local function sanitizeMessagesForLLMInput(messages) -- 2037
	local sanitized = {} -- 2038
	local droppedAssistantToolCalls = 0 -- 2039
	local droppedToolResults = 0 -- 2040
	do -- 2040
		local i = 0 -- 2041
		while i < #messages do -- 2041
			do -- 2041
				local message = messages[i + 1] -- 2042
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2042
					local requiredIds = {} -- 2044
					do -- 2044
						local j = 0 -- 2045
						while j < #message.tool_calls do -- 2045
							local toolCall = message.tool_calls[j + 1] -- 2046
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2047
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2047
								requiredIds[#requiredIds + 1] = id -- 2049
							end -- 2049
							j = j + 1 -- 2045
						end -- 2045
					end -- 2045
					if #requiredIds == 0 then -- 2045
						sanitized[#sanitized + 1] = message -- 2053
						goto __continue313 -- 2054
					end -- 2054
					local matchedIds = {} -- 2056
					local matchedTools = {} -- 2057
					local j = i + 1 -- 2058
					while j < #messages do -- 2058
						local toolMessage = messages[j + 1] -- 2060
						if toolMessage.role ~= "tool" then -- 2060
							break -- 2061
						end -- 2061
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2062
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2062
							matchedIds[toolCallId] = true -- 2064
							matchedTools[#matchedTools + 1] = toolMessage -- 2065
						else -- 2065
							droppedToolResults = droppedToolResults + 1 -- 2067
						end -- 2067
						j = j + 1 -- 2069
					end -- 2069
					local complete = true -- 2071
					do -- 2071
						local j = 0 -- 2072
						while j < #requiredIds do -- 2072
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2072
								complete = false -- 2074
								break -- 2075
							end -- 2075
							j = j + 1 -- 2072
						end -- 2072
					end -- 2072
					if complete then -- 2072
						__TS__ArrayPush( -- 2079
							sanitized, -- 2079
							message, -- 2079
							table.unpack(matchedTools) -- 2079
						) -- 2079
					else -- 2079
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2081
						droppedToolResults = droppedToolResults + #matchedTools -- 2082
					end -- 2082
					i = j - 1 -- 2084
					goto __continue313 -- 2085
				end -- 2085
				if message.role == "tool" then -- 2085
					droppedToolResults = droppedToolResults + 1 -- 2088
					goto __continue313 -- 2089
				end -- 2089
				sanitized[#sanitized + 1] = message -- 2091
			end -- 2091
			::__continue313:: -- 2091
			i = i + 1 -- 2041
		end -- 2041
	end -- 2041
	return sanitized -- 2093
end -- 2037
local function getUnconsolidatedMessages(shared) -- 2096
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2097
end -- 2096
local function getFinalDecisionTurnPrompt(shared) -- 2100
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2101
end -- 2100
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2106
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2106
		return messages -- 2107
	end -- 2107
	local next = __TS__ArrayMap( -- 2108
		messages, -- 2108
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2108
	) -- 2108
	do -- 2108
		local i = #next - 1 -- 2109
		while i >= 0 do -- 2109
			do -- 2109
				local message = next[i + 1] -- 2110
				if message.role ~= "assistant" and message.role ~= "user" then -- 2110
					goto __continue335 -- 2111
				end -- 2111
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2112
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2113
				return next -- 2116
			end -- 2116
			::__continue335:: -- 2116
			i = i - 1 -- 2109
		end -- 2109
	end -- 2109
	next[#next + 1] = {role = "user", content = prompt} -- 2118
	return next -- 2119
end -- 2106
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2122
	if attempt == nil then -- 2122
		attempt = 1 -- 2122
	end -- 2122
	local messages = { -- 2123
		{ -- 2124
			role = "system", -- 2124
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 2124
		}, -- 2124
		table.unpack(getUnconsolidatedMessages(shared)) -- 2125
	} -- 2125
	if shared.step + 1 >= shared.maxSteps then -- 2125
		messages = appendPromptToLatestDecisionMessage( -- 2128
			messages, -- 2128
			getFinalDecisionTurnPrompt(shared) -- 2128
		) -- 2128
	end -- 2128
	if lastError and lastError ~= "" then -- 2128
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2131
		messages[#messages + 1] = { -- 2134
			role = "user", -- 2135
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2136
		} -- 2136
	end -- 2136
	return messages -- 2143
end -- 2122
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2150
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2157
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2158
	local repairPrompt = replacePromptVars( -- 2166
		shared.promptPack.xmlDecisionRepairPrompt, -- 2166
		{ -- 2166
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2167
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2168
			CANDIDATE_SECTION = candidateSection, -- 2169
			LAST_ERROR = lastError, -- 2170
			ATTEMPT = tostring(attempt) -- 2171
		} -- 2171
	) -- 2171
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2173
end -- 2150
local function tryParseAndValidateDecision(rawText) -- 2185
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2186
	if not parsed.success then -- 2186
		return {success = false, message = parsed.message, raw = rawText} -- 2188
	end -- 2188
	local decision = parseDecisionObject(parsed.obj) -- 2190
	if not decision.success then -- 2190
		return {success = false, message = decision.message, raw = rawText} -- 2192
	end -- 2192
	local validation = validateDecision(decision.tool, decision.params) -- 2194
	if not validation.success then -- 2194
		return {success = false, message = validation.message, raw = rawText} -- 2196
	end -- 2196
	decision.params = validation.params -- 2198
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2199
	return decision -- 2200
end -- 2185
local function normalizeLineEndings(text) -- 2203
	local res = string.gsub(text, "\r\n", "\n") -- 2204
	res = string.gsub(res, "\r", "\n") -- 2205
	return res -- 2206
end -- 2203
local function countOccurrences(text, searchStr) -- 2209
	if searchStr == "" then -- 2209
		return 0 -- 2210
	end -- 2210
	local count = 0 -- 2211
	local pos = 0 -- 2212
	while true do -- 2212
		local idx = (string.find( -- 2214
			text, -- 2214
			searchStr, -- 2214
			math.max(pos + 1, 1), -- 2214
			true -- 2214
		) or 0) - 1 -- 2214
		if idx < 0 then -- 2214
			break -- 2215
		end -- 2215
		count = count + 1 -- 2216
		pos = idx + #searchStr -- 2217
	end -- 2217
	return count -- 2219
end -- 2209
local function replaceFirst(text, oldStr, newStr) -- 2222
	if oldStr == "" then -- 2222
		return text -- 2223
	end -- 2223
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2224
	if idx < 0 then -- 2224
		return text -- 2225
	end -- 2225
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2226
end -- 2222
local function splitLines(text) -- 2229
	return __TS__StringSplit(text, "\n") -- 2230
end -- 2229
local function getLeadingWhitespace(text) -- 2233
	local i = 0 -- 2234
	while i < #text do -- 2234
		local ch = __TS__StringAccess(text, i) -- 2236
		if ch ~= " " and ch ~= "\t" then -- 2236
			break -- 2237
		end -- 2237
		i = i + 1 -- 2238
	end -- 2238
	return __TS__StringSubstring(text, 0, i) -- 2240
end -- 2233
local function getCommonIndentPrefix(lines) -- 2243
	local common -- 2244
	do -- 2244
		local i = 0 -- 2245
		while i < #lines do -- 2245
			do -- 2245
				local line = lines[i + 1] -- 2246
				if __TS__StringTrim(line) == "" then -- 2246
					goto __continue360 -- 2247
				end -- 2247
				local indent = getLeadingWhitespace(line) -- 2248
				if common == nil then -- 2248
					common = indent -- 2250
					goto __continue360 -- 2251
				end -- 2251
				local j = 0 -- 2253
				local maxLen = math.min(#common, #indent) -- 2254
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2254
					j = j + 1 -- 2256
				end -- 2256
				common = __TS__StringSubstring(common, 0, j) -- 2258
				if common == "" then -- 2258
					break -- 2259
				end -- 2259
			end -- 2259
			::__continue360:: -- 2259
			i = i + 1 -- 2245
		end -- 2245
	end -- 2245
	return common or "" -- 2261
end -- 2243
local function removeIndentPrefix(line, indent) -- 2264
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2264
		return __TS__StringSubstring(line, #indent) -- 2266
	end -- 2266
	local lineIndent = getLeadingWhitespace(line) -- 2268
	local j = 0 -- 2269
	local maxLen = math.min(#lineIndent, #indent) -- 2270
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2270
		j = j + 1 -- 2272
	end -- 2272
	return __TS__StringSubstring(line, j) -- 2274
end -- 2264
local function dedentLines(lines) -- 2277
	local indent = getCommonIndentPrefix(lines) -- 2278
	return { -- 2279
		indent = indent, -- 2280
		lines = __TS__ArrayMap( -- 2281
			lines, -- 2281
			function(____, line) return removeIndentPrefix(line, indent) end -- 2281
		) -- 2281
	} -- 2281
end -- 2277
local function joinLines(lines) -- 2285
	return table.concat(lines, "\n") -- 2286
end -- 2285
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2289
	local contentLines = splitLines(content) -- 2294
	local oldLines = splitLines(oldStr) -- 2295
	if #oldLines == 0 then -- 2295
		return {success = false, message = "old_str not found in file"} -- 2297
	end -- 2297
	local dedentedOld = dedentLines(oldLines) -- 2299
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2300
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2301
	local matches = {} -- 2302
	do -- 2302
		local start = 0 -- 2303
		while start <= #contentLines - #oldLines do -- 2303
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2304
			local dedentedCandidate = dedentLines(candidateLines) -- 2305
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2305
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2307
			end -- 2307
			start = start + 1 -- 2303
		end -- 2303
	end -- 2303
	if #matches == 0 then -- 2303
		return {success = false, message = "old_str not found in file"} -- 2315
	end -- 2315
	if #matches > 1 then -- 2315
		return { -- 2318
			success = false, -- 2319
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2320
		} -- 2320
	end -- 2320
	local match = matches[1] -- 2323
	local rebuiltNewLines = __TS__ArrayMap( -- 2324
		dedentedNew.lines, -- 2324
		function(____, line) return line == "" and "" or match.indent .. line end -- 2324
	) -- 2324
	local ____array_38 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2324
	__TS__SparseArrayPush( -- 2324
		____array_38, -- 2324
		table.unpack(rebuiltNewLines) -- 2327
	) -- 2327
	__TS__SparseArrayPush( -- 2327
		____array_38, -- 2327
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2328
	) -- 2328
	local nextLines = {__TS__SparseArraySpread(____array_38)} -- 2325
	return { -- 2330
		success = true, -- 2330
		content = joinLines(nextLines) -- 2330
	} -- 2330
end -- 2289
local MainDecisionAgent = __TS__Class() -- 2333
MainDecisionAgent.name = "MainDecisionAgent" -- 2333
__TS__ClassExtends(MainDecisionAgent, Node) -- 2333
function MainDecisionAgent.prototype.prep(self, shared) -- 2334
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2334
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2334
			return ____awaiter_resolve(nil, {shared = shared}) -- 2334
		end -- 2334
		__TS__Await(maybeCompressHistory(shared)) -- 2339
		return ____awaiter_resolve(nil, {shared = shared}) -- 2339
	end) -- 2339
end -- 2334
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2344
	if attempt == nil then -- 2344
		attempt = 1 -- 2347
	end -- 2347
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2347
		if shared.stopToken.stopped then -- 2347
			return ____awaiter_resolve( -- 2347
				nil, -- 2347
				{ -- 2351
					success = false, -- 2351
					message = getCancelledReason(shared) -- 2351
				} -- 2351
			) -- 2351
		end -- 2351
		Log( -- 2353
			"Info", -- 2353
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2353
		) -- 2353
		local tools = buildDecisionToolSchema(shared) -- 2354
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2355
		local stepId = shared.step + 1 -- 2356
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2357
		saveStepLLMDebugInput( -- 2361
			shared, -- 2361
			stepId, -- 2361
			"decision_tool_calling", -- 2361
			messages, -- 2361
			llmOptions -- 2361
		) -- 2361
		local lastStreamContent = "" -- 2362
		local lastStreamReasoning = "" -- 2363
		local preExecutedResults = __TS__New(Map)
		shared.preExecutedResults = preExecutedResults
		local res = __TS__Await(callLLMStreamAggregated( -- 2364
			messages, -- 2365
			llmOptions, -- 2366
			shared.stopToken, -- 2367
			shared.llmConfig, -- 2368
			function(response) -- 2369
				local ____opt_41 = response.choices -- 2369
				local ____opt_39 = ____opt_41 and ____opt_41[1] -- 2369
				local streamMessage = ____opt_39 and ____opt_39.message -- 2370
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2371
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2374
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2374
					return -- 2378
				end -- 2378
				lastStreamContent = nextContent -- 2380
				lastStreamReasoning = nextReasoning -- 2381
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2382
			end, -- 2369
			function(tc)
				if shared.stopToken.stopped then
					return
				end
				local action = createPreExecutableActionFromStream(shared, tc)
				if not action or preExecutedResults:has(action.toolCallId) then
					return
				end
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId)
				preExecutedResults:set(
					action.toolCallId,
					startPreExecutedToolAction(shared, action)
				)
			end
		)) -- 2369
		if shared.stopToken.stopped then -- 2369
			clearPreExecutedResults(shared)
			return ____awaiter_resolve( -- 2369
				nil, -- 2369
				{ -- 2386
					success = false, -- 2386
					message = getCancelledReason(shared) -- 2386
				} -- 2386
			) -- 2386
		end -- 2386
		if not res.success then -- 2386
			saveStepLLMDebugOutput( -- 2389
				shared, -- 2389
				stepId, -- 2389
				"decision_tool_calling", -- 2389
				res.raw or res.message, -- 2389
				{success = false} -- 2389
			) -- 2389
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2390
			clearPreExecutedResults(shared)
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2390
		end -- 2390
		saveStepLLMDebugOutput( -- 2393
			shared, -- 2393
			stepId, -- 2393
			"decision_tool_calling", -- 2393
			encodeDebugJSON(res.response), -- 2393
			{success = true} -- 2393
		) -- 2393
		local choice = res.response.choices and res.response.choices[1] -- 2394
		local message = choice and choice.message -- 2395
		local toolCalls = message and message.tool_calls -- 2396
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2397
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2400
		Log( -- 2403
			"Info", -- 2403
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2403
		) -- 2403
		if not toolCalls or #toolCalls == 0 then -- 2403
			if messageContent and messageContent ~= "" then -- 2403
				Log( -- 2406
					"Info", -- 2406
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2406
				) -- 2406
				clearPreExecutedResults(shared)
				return ____awaiter_resolve(nil, { -- 2406
					success = true, -- 2408
					tool = "finish", -- 2409
					params = {}, -- 2410
					reason = messageContent, -- 2411
					reasoningContent = reasoningContent, -- 2412
					directSummary = messageContent -- 2413
				}) -- 2413
			end -- 2413
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2416
			clearPreExecutedResults(shared)
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 2416
		end -- 2416
		local decisions = {} -- 2423
		do -- 2423
			local i = 0 -- 2424
			while i < #toolCalls do -- 2424
				local toolCall = toolCalls[i + 1] -- 2425
				local fn = toolCall and toolCall["function"] -- 2426
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2426
					Log( -- 2428
						"Error", -- 2428
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2428
					) -- 2428
					clearPreExecutedResults(shared)
					return ____awaiter_resolve( -- 2428
						nil, -- 2428
						{ -- 2429
							success = false, -- 2430
							message = "missing function name for tool call " .. tostring(i + 1), -- 2431
							raw = messageContent -- 2432
						} -- 2432
					) -- 2432
				end -- 2432
				local functionName = fn.name -- 2435
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2436
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2437
				Log( -- 2440
					"Info", -- 2440
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2440
				) -- 2440
				local decision = parseAndValidateToolCallDecision( -- 2441
					shared, -- 2442
					functionName, -- 2443
					argsText, -- 2444
					toolCallId, -- 2445
					messageContent, -- 2446
					reasoningContent -- 2447
				) -- 2447
				if not decision.success then -- 2447
					Log( -- 2450
						"Error", -- 2450
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2450
					) -- 2450
					clearPreExecutedResults(shared)
					return ____awaiter_resolve(nil, decision) -- 2450
				end -- 2450
				decisions[#decisions + 1] = decision -- 2453
				i = i + 1 -- 2424
			end -- 2424
		end -- 2424
		if #decisions == 1 then -- 2424
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2456
			return ____awaiter_resolve(nil, decisions[1]) -- 2456
		end -- 2456
		do
			local i = 0
			while i < #decisions do
				if decisions[i + 1].tool == "finish" then
					clearPreExecutedResults(shared)
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent})
				end
				i = i + 1
			end
		end
		Log( -- 2459
			"Info", -- 2459
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2459
				__TS__ArrayMap( -- 2459
					decisions, -- 2459
					function(____, decision) return decision.tool end -- 2459
				), -- 2459
				"," -- 2459
			) -- 2459
		) -- 2459
		return ____awaiter_resolve(nil, { -- 2459
			success = true, -- 2461
			kind = "batch", -- 2462
			decisions = decisions, -- 2463
			content = messageContent, -- 2464
			reasoningContent = reasoningContent -- 2465
		}) -- 2465
	end) -- 2465
end -- 2344
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2469
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2469
		Log( -- 2474
			"Info", -- 2474
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2474
		) -- 2474
		local lastError = initialError -- 2475
		local candidateRaw = "" -- 2476
		do -- 2476
			local attempt = 0 -- 2477
			while attempt < shared.llmMaxTry do -- 2477
				do -- 2477
					Log( -- 2478
						"Info", -- 2478
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2478
					) -- 2478
					local messages = buildXmlRepairMessages( -- 2479
						shared, -- 2480
						originalRaw, -- 2481
						candidateRaw, -- 2482
						lastError, -- 2483
						attempt + 1 -- 2484
					) -- 2484
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2486
					if shared.stopToken.stopped then -- 2486
						return ____awaiter_resolve( -- 2486
							nil, -- 2486
							{ -- 2488
								success = false, -- 2488
								message = getCancelledReason(shared) -- 2488
							} -- 2488
						) -- 2488
					end -- 2488
					if not llmRes.success then -- 2488
						lastError = llmRes.message -- 2491
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2492
						goto __continue397 -- 2493
					end -- 2493
					candidateRaw = llmRes.text -- 2495
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2496
					if decision.success then -- 2496
						decision.reasoningContent = llmRes.reasoningContent -- 2498
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2499
						return ____awaiter_resolve(nil, decision) -- 2499
					end -- 2499
					lastError = decision.message -- 2502
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2503
				end -- 2503
				::__continue397:: -- 2503
				attempt = attempt + 1 -- 2477
			end -- 2477
		end -- 2477
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2505
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2505
	end) -- 2505
end -- 2469
function MainDecisionAgent.prototype.exec(self, input) -- 2513
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2513
		local shared = input.shared -- 2514
		if shared.stopToken.stopped then -- 2514
			return ____awaiter_resolve( -- 2514
				nil, -- 2514
				{ -- 2516
					success = false, -- 2516
					message = getCancelledReason(shared) -- 2516
				} -- 2516
			) -- 2516
		end -- 2516
		if shared.step >= shared.maxSteps then -- 2516
			Log( -- 2519
				"Warn", -- 2519
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2519
			) -- 2519
			return ____awaiter_resolve( -- 2519
				nil, -- 2519
				{ -- 2520
					success = false, -- 2520
					message = getMaxStepsReachedReason(shared) -- 2520
				} -- 2520
			) -- 2520
		end -- 2520
		if shared.decisionMode == "tool_calling" then -- 2520
			Log( -- 2524
				"Info", -- 2524
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2524
			) -- 2524
			local lastError = "tool calling validation failed" -- 2525
			local lastRaw = "" -- 2526
			do -- 2526
				local attempt = 0 -- 2527
				while attempt < shared.llmMaxTry do -- 2527
					Log( -- 2528
						"Info", -- 2528
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2528
					) -- 2528
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2529
					if shared.stopToken.stopped then -- 2529
						return ____awaiter_resolve( -- 2529
							nil, -- 2529
							{ -- 2536
								success = false, -- 2536
								message = getCancelledReason(shared) -- 2536
							} -- 2536
						) -- 2536
					end -- 2536
					if decision.success then -- 2536
						return ____awaiter_resolve(nil, decision) -- 2536
					end -- 2536
					lastError = decision.message -- 2541
					lastRaw = decision.raw or "" -- 2542
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2543
					attempt = attempt + 1 -- 2527
				end -- 2527
			end -- 2527
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2545
			return ____awaiter_resolve( -- 2545
				nil, -- 2545
				{ -- 2546
					success = false, -- 2546
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2546
				} -- 2546
			) -- 2546
		end -- 2546
		local lastError = "xml validation failed" -- 2549
		local lastRaw = "" -- 2550
		do -- 2550
			local attempt = 0 -- 2551
			while attempt < shared.llmMaxTry do -- 2551
				do -- 2551
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 2552
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2560
					if shared.stopToken.stopped then -- 2560
						return ____awaiter_resolve( -- 2560
							nil, -- 2560
							{ -- 2562
								success = false, -- 2562
								message = getCancelledReason(shared) -- 2562
							} -- 2562
						) -- 2562
					end -- 2562
					if not llmRes.success then -- 2562
						lastError = llmRes.message -- 2565
						lastRaw = llmRes.text or "" -- 2566
						goto __continue410 -- 2567
					end -- 2567
					lastRaw = llmRes.text -- 2569
					local decision = tryParseAndValidateDecision(llmRes.text) -- 2570
					if decision.success then -- 2570
						decision.reasoningContent = llmRes.reasoningContent -- 2572
						if not isToolAllowedForRole(shared.role, decision.tool) then -- 2572
							lastError = (decision.tool .. " is not allowed for role ") .. shared.role -- 2574
							return ____awaiter_resolve( -- 2574
								nil, -- 2574
								self:repairDecisionXml(shared, llmRes.text, lastError) -- 2575
							) -- 2575
						end -- 2575
						return ____awaiter_resolve(nil, decision) -- 2575
					end -- 2575
					lastError = decision.message -- 2579
					return ____awaiter_resolve( -- 2579
						nil, -- 2579
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 2580
					) -- 2580
				end -- 2580
				::__continue410:: -- 2580
				attempt = attempt + 1 -- 2551
			end -- 2551
		end -- 2551
		return ____awaiter_resolve( -- 2551
			nil, -- 2551
			{ -- 2582
				success = false, -- 2582
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2582
			} -- 2582
		) -- 2582
	end) -- 2582
end -- 2513
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2585
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2585
		local result = execRes -- 2586
		if not result.success then -- 2586
			if shared.stopToken.stopped then -- 2586
				shared.error = getCancelledReason(shared) -- 2589
				shared.done = true -- 2590
				return ____awaiter_resolve(nil, "done") -- 2590
			end -- 2590
			shared.error = result.message -- 2593
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2594
			shared.done = true -- 2595
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2596
			persistHistoryState(shared) -- 2600
			return ____awaiter_resolve(nil, "done") -- 2600
		end -- 2600
		if isDecisionBatchSuccess(result) then -- 2600
			local startStep = shared.step -- 2604
			local actions = {} -- 2605
			do -- 2605
				local i = 0 -- 2606
				while i < #result.decisions do -- 2606
					local decision = result.decisions[i + 1] -- 2607
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2608
					local step = startStep + i + 1 -- 2609
					local ____temp_47 -- 2610
					if i == 0 then -- 2610
						____temp_47 = decision.reason -- 2610
					else -- 2610
						____temp_47 = "" -- 2610
					end -- 2610
					local actionReason = ____temp_47 -- 2610
					local ____temp_48 -- 2611
					if i == 0 then -- 2611
						____temp_48 = decision.reasoningContent -- 2611
					else -- 2611
						____temp_48 = nil -- 2611
					end -- 2611
					local actionReasoningContent = ____temp_48 -- 2611
					emitAgentEvent(shared, { -- 2612
						type = "decision_made", -- 2613
						sessionId = shared.sessionId, -- 2614
						taskId = shared.taskId, -- 2615
						step = step, -- 2616
						tool = decision.tool, -- 2617
						reason = actionReason, -- 2618
						reasoningContent = actionReasoningContent, -- 2619
						params = decision.params -- 2620
					}) -- 2620
					local action = { -- 2622
						step = step, -- 2623
						toolCallId = toolCallId, -- 2624
						tool = decision.tool, -- 2625
						reason = actionReason or "", -- 2626
						reasoningContent = actionReasoningContent, -- 2627
						params = decision.params, -- 2628
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2629
					} -- 2629
					local ____shared_history_49 = shared.history -- 2629
					____shared_history_49[#____shared_history_49 + 1] = action -- 2631
					actions[#actions + 1] = action -- 2632
					i = i + 1 -- 2606
				end -- 2606
			end -- 2606
			shared.step = startStep + #actions -- 2634
			shared.pendingToolActions = actions -- 2635
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2636
			persistHistoryState(shared) -- 2642
			return ____awaiter_resolve(nil, "batch_tools") -- 2642
		end -- 2642
		if result.directSummary and result.directSummary ~= "" then -- 2642
			shared.response = result.directSummary -- 2646
			shared.done = true -- 2647
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2648
			persistHistoryState(shared) -- 2653
			return ____awaiter_resolve(nil, "done") -- 2653
		end -- 2653
		if result.tool == "finish" then -- 2653
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2657
			shared.response = finalMessage -- 2658
			shared.done = true -- 2659
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2660
			persistHistoryState(shared) -- 2665
			return ____awaiter_resolve(nil, "done") -- 2665
		end -- 2665
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2668
		shared.step = shared.step + 1 -- 2669
		local step = shared.step -- 2670
		emitAgentEvent(shared, { -- 2671
			type = "decision_made", -- 2672
			sessionId = shared.sessionId, -- 2673
			taskId = shared.taskId, -- 2674
			step = step, -- 2675
			tool = result.tool, -- 2676
			reason = result.reason, -- 2677
			reasoningContent = result.reasoningContent, -- 2678
			params = result.params -- 2679
		}) -- 2679
		local ____shared_history_50 = shared.history -- 2679
		____shared_history_50[#____shared_history_50 + 1] = { -- 2681
			step = step, -- 2682
			toolCallId = toolCallId, -- 2683
			tool = result.tool, -- 2684
			reason = result.reason or "", -- 2685
			reasoningContent = result.reasoningContent, -- 2686
			params = result.params, -- 2687
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2688
		} -- 2688
		local action = shared.history[#shared.history] -- 2690
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 2691
		if canPreExecuteTool(action.tool) then
			shared.pendingToolActions = {action}
			persistHistoryState(shared) -- 2692
			return ____awaiter_resolve(nil, "batch_tools")
		end
		clearPreExecutedResults(shared)
		persistHistoryState(shared) -- 2692
		return ____awaiter_resolve(nil, result.tool) -- 2692
	end) -- 2692
end -- 2585
local ReadFileAction = __TS__Class() -- 2697
ReadFileAction.name = "ReadFileAction" -- 2697
__TS__ClassExtends(ReadFileAction, Node) -- 2697
function ReadFileAction.prototype.prep(self, shared) -- 2698
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2698
		local last = shared.history[#shared.history] -- 2699
		if not last then -- 2699
			error( -- 2700
				__TS__New(Error, "no history"), -- 2700
				0 -- 2700
			) -- 2700
		end -- 2700
		emitAgentStartEvent(shared, last) -- 2701
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2702
		if __TS__StringTrim(path) == "" then -- 2702
			error( -- 2705
				__TS__New(Error, "missing path"), -- 2705
				0 -- 2705
			) -- 2705
		end -- 2705
		local ____path_53 = path -- 2707
		local ____shared_workingDir_54 = shared.workingDir -- 2709
		local ____temp_55 = shared.useChineseResponse and "zh" or "en" -- 2710
		local ____last_params_startLine_51 = last.params.startLine -- 2711
		if ____last_params_startLine_51 == nil then -- 2711
			____last_params_startLine_51 = 1 -- 2711
		end -- 2711
		local ____TS__Number_result_56 = __TS__Number(____last_params_startLine_51) -- 2711
		local ____last_params_endLine_52 = last.params.endLine -- 2712
		if ____last_params_endLine_52 == nil then -- 2712
			____last_params_endLine_52 = READ_FILE_DEFAULT_LIMIT -- 2712
		end -- 2712
		return ____awaiter_resolve( -- 2712
			nil, -- 2712
			{ -- 2706
				path = ____path_53, -- 2707
				tool = "read_file", -- 2708
				workDir = ____shared_workingDir_54, -- 2709
				docLanguage = ____temp_55, -- 2710
				startLine = ____TS__Number_result_56, -- 2711
				endLine = __TS__Number(____last_params_endLine_52) -- 2712
			} -- 2712
		) -- 2712
	end) -- 2712
end -- 2698
function ReadFileAction.prototype.exec(self, input) -- 2716
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2716
		return ____awaiter_resolve( -- 2716
			nil, -- 2716
			Tools.readFile( -- 2717
				input.workDir, -- 2718
				input.path, -- 2719
				__TS__Number(input.startLine or 1), -- 2720
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2721
				input.docLanguage -- 2722
			) -- 2722
		) -- 2722
	end) -- 2722
end -- 2716
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2726
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2726
		local result = execRes -- 2727
		local last = shared.history[#shared.history] -- 2728
		if last ~= nil then -- 2728
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2730
			appendToolResultMessage(shared, last) -- 2731
			emitAgentFinishEvent(shared, last) -- 2732
		end -- 2732
		persistHistoryState(shared) -- 2734
		__TS__Await(maybeCompressHistory(shared)) -- 2735
		persistHistoryState(shared) -- 2736
		return ____awaiter_resolve(nil, "main") -- 2736
	end) -- 2736
end -- 2726
local SearchFilesAction = __TS__Class() -- 2741
SearchFilesAction.name = "SearchFilesAction" -- 2741
__TS__ClassExtends(SearchFilesAction, Node) -- 2741
function SearchFilesAction.prototype.prep(self, shared) -- 2742
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2742
		local last = shared.history[#shared.history] -- 2743
		if not last then -- 2743
			error( -- 2744
				__TS__New(Error, "no history"), -- 2744
				0 -- 2744
			) -- 2744
		end -- 2744
		emitAgentStartEvent(shared, last) -- 2745
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2745
	end) -- 2745
end -- 2742
function SearchFilesAction.prototype.exec(self, input) -- 2749
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2749
		local params = input.params -- 2750
		local ____Tools_searchFiles_70 = Tools.searchFiles -- 2751
		local ____input_workDir_63 = input.workDir -- 2752
		local ____temp_64 = params.path or "" -- 2753
		local ____temp_65 = params.pattern or "" -- 2754
		local ____params_globs_66 = params.globs -- 2755
		local ____params_useRegex_67 = params.useRegex -- 2756
		local ____params_caseSensitive_68 = params.caseSensitive -- 2757
		local ____math_max_59 = math.max -- 2760
		local ____math_floor_58 = math.floor -- 2760
		local ____params_limit_57 = params.limit -- 2760
		if ____params_limit_57 == nil then -- 2760
			____params_limit_57 = SEARCH_FILES_LIMIT_DEFAULT -- 2760
		end -- 2760
		local ____math_max_59_result_69 = ____math_max_59( -- 2760
			1, -- 2760
			____math_floor_58(__TS__Number(____params_limit_57)) -- 2760
		) -- 2760
		local ____math_max_62 = math.max -- 2761
		local ____math_floor_61 = math.floor -- 2761
		local ____params_offset_60 = params.offset -- 2761
		if ____params_offset_60 == nil then -- 2761
			____params_offset_60 = 0 -- 2761
		end -- 2761
		local result = __TS__Await(____Tools_searchFiles_70({ -- 2751
			workDir = ____input_workDir_63, -- 2752
			path = ____temp_64, -- 2753
			pattern = ____temp_65, -- 2754
			globs = ____params_globs_66, -- 2755
			useRegex = ____params_useRegex_67, -- 2756
			caseSensitive = ____params_caseSensitive_68, -- 2757
			includeContent = true, -- 2758
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2759
			limit = ____math_max_59_result_69, -- 2760
			offset = ____math_max_62( -- 2761
				0, -- 2761
				____math_floor_61(__TS__Number(____params_offset_60)) -- 2761
			), -- 2761
			groupByFile = params.groupByFile == true -- 2762
		})) -- 2762
		return ____awaiter_resolve(nil, result) -- 2762
	end) -- 2762
end -- 2749
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2767
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2767
		local last = shared.history[#shared.history] -- 2768
		if last ~= nil then -- 2768
			local result = execRes -- 2770
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2771
			appendToolResultMessage(shared, last) -- 2772
			emitAgentFinishEvent(shared, last) -- 2773
		end -- 2773
		persistHistoryState(shared) -- 2775
		__TS__Await(maybeCompressHistory(shared)) -- 2776
		persistHistoryState(shared) -- 2777
		return ____awaiter_resolve(nil, "main") -- 2777
	end) -- 2777
end -- 2767
local SearchDoraAPIAction = __TS__Class() -- 2782
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2782
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2782
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2783
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2783
		local last = shared.history[#shared.history] -- 2784
		if not last then -- 2784
			error( -- 2785
				__TS__New(Error, "no history"), -- 2785
				0 -- 2785
			) -- 2785
		end -- 2785
		emitAgentStartEvent(shared, last) -- 2786
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2786
	end) -- 2786
end -- 2783
function SearchDoraAPIAction.prototype.exec(self, input) -- 2790
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2790
		local params = input.params -- 2791
		local ____Tools_searchDoraAPI_78 = Tools.searchDoraAPI -- 2792
		local ____temp_74 = params.pattern or "" -- 2793
		local ____temp_75 = params.docSource or "api" -- 2794
		local ____temp_76 = input.useChineseResponse and "zh" or "en" -- 2795
		local ____temp_77 = params.programmingLanguage or "ts" -- 2796
		local ____math_min_73 = math.min -- 2797
		local ____math_max_72 = math.max -- 2797
		local ____params_limit_71 = params.limit -- 2797
		if ____params_limit_71 == nil then -- 2797
			____params_limit_71 = 8 -- 2797
		end -- 2797
		local result = __TS__Await(____Tools_searchDoraAPI_78({ -- 2792
			pattern = ____temp_74, -- 2793
			docSource = ____temp_75, -- 2794
			docLanguage = ____temp_76, -- 2795
			programmingLanguage = ____temp_77, -- 2796
			limit = ____math_min_73( -- 2797
				SEARCH_DORA_API_LIMIT_MAX, -- 2797
				____math_max_72( -- 2797
					1, -- 2797
					__TS__Number(____params_limit_71) -- 2797
				) -- 2797
			), -- 2797
			useRegex = params.useRegex, -- 2798
			caseSensitive = false, -- 2799
			includeContent = true, -- 2800
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2801
		})) -- 2801
		return ____awaiter_resolve(nil, result) -- 2801
	end) -- 2801
end -- 2790
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2806
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2806
		local last = shared.history[#shared.history] -- 2807
		if last ~= nil then -- 2807
			local result = execRes -- 2809
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2810
			appendToolResultMessage(shared, last) -- 2811
			emitAgentFinishEvent(shared, last) -- 2812
		end -- 2812
		persistHistoryState(shared) -- 2814
		__TS__Await(maybeCompressHistory(shared)) -- 2815
		persistHistoryState(shared) -- 2816
		return ____awaiter_resolve(nil, "main") -- 2816
	end) -- 2816
end -- 2806
local ListFilesAction = __TS__Class() -- 2821
ListFilesAction.name = "ListFilesAction" -- 2821
__TS__ClassExtends(ListFilesAction, Node) -- 2821
function ListFilesAction.prototype.prep(self, shared) -- 2822
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2822
		local last = shared.history[#shared.history] -- 2823
		if not last then -- 2823
			error( -- 2824
				__TS__New(Error, "no history"), -- 2824
				0 -- 2824
			) -- 2824
		end -- 2824
		emitAgentStartEvent(shared, last) -- 2825
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2825
	end) -- 2825
end -- 2822
function ListFilesAction.prototype.exec(self, input) -- 2829
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2829
		local params = input.params -- 2830
		local ____Tools_listFiles_85 = Tools.listFiles -- 2831
		local ____input_workDir_82 = input.workDir -- 2832
		local ____temp_83 = params.path or "" -- 2833
		local ____params_globs_84 = params.globs -- 2834
		local ____math_max_81 = math.max -- 2835
		local ____math_floor_80 = math.floor -- 2835
		local ____params_maxEntries_79 = params.maxEntries -- 2835
		if ____params_maxEntries_79 == nil then -- 2835
			____params_maxEntries_79 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2835
		end -- 2835
		local result = ____Tools_listFiles_85({ -- 2831
			workDir = ____input_workDir_82, -- 2832
			path = ____temp_83, -- 2833
			globs = ____params_globs_84, -- 2834
			maxEntries = ____math_max_81( -- 2835
				1, -- 2835
				____math_floor_80(__TS__Number(____params_maxEntries_79)) -- 2835
			) -- 2835
		}) -- 2835
		return ____awaiter_resolve(nil, result) -- 2835
	end) -- 2835
end -- 2829
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2840
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2840
		local last = shared.history[#shared.history] -- 2841
		if last ~= nil then -- 2841
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2843
			appendToolResultMessage(shared, last) -- 2844
			emitAgentFinishEvent(shared, last) -- 2845
		end -- 2845
		persistHistoryState(shared) -- 2847
		__TS__Await(maybeCompressHistory(shared)) -- 2848
		persistHistoryState(shared) -- 2849
		return ____awaiter_resolve(nil, "main") -- 2849
	end) -- 2849
end -- 2840
local DeleteFileAction = __TS__Class() -- 2854
DeleteFileAction.name = "DeleteFileAction" -- 2854
__TS__ClassExtends(DeleteFileAction, Node) -- 2854
function DeleteFileAction.prototype.prep(self, shared) -- 2855
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2855
		local last = shared.history[#shared.history] -- 2856
		if not last then -- 2856
			error( -- 2857
				__TS__New(Error, "no history"), -- 2857
				0 -- 2857
			) -- 2857
		end -- 2857
		emitAgentStartEvent(shared, last) -- 2858
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 2859
		if __TS__StringTrim(targetFile) == "" then -- 2859
			error( -- 2862
				__TS__New(Error, "missing target_file"), -- 2862
				0 -- 2862
			) -- 2862
		end -- 2862
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 2862
	end) -- 2862
end -- 2855
function DeleteFileAction.prototype.exec(self, input) -- 2866
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2866
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 2867
		if not result.success then -- 2867
			return ____awaiter_resolve(nil, result) -- 2867
		end -- 2867
		return ____awaiter_resolve(nil, { -- 2867
			success = true, -- 2875
			changed = true, -- 2876
			mode = "delete", -- 2877
			checkpointId = result.checkpointId, -- 2878
			checkpointSeq = result.checkpointSeq, -- 2879
			files = {{path = input.targetFile, op = "delete"}} -- 2880
		}) -- 2880
	end) -- 2880
end -- 2866
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2884
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2884
		local last = shared.history[#shared.history] -- 2885
		if last ~= nil then -- 2885
			last.result = execRes -- 2887
			appendToolResultMessage(shared, last) -- 2888
			emitAgentFinishEvent(shared, last) -- 2889
			local result = last.result -- 2890
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2890
				emitAgentEvent(shared, { -- 2895
					type = "checkpoint_created", -- 2896
					sessionId = shared.sessionId, -- 2897
					taskId = shared.taskId, -- 2898
					step = last.step, -- 2899
					tool = "delete_file", -- 2900
					checkpointId = result.checkpointId, -- 2901
					checkpointSeq = result.checkpointSeq, -- 2902
					files = result.files -- 2903
				}) -- 2903
			end -- 2903
		end -- 2903
		persistHistoryState(shared) -- 2907
		__TS__Await(maybeCompressHistory(shared)) -- 2908
		persistHistoryState(shared) -- 2909
		return ____awaiter_resolve(nil, "main") -- 2909
	end) -- 2909
end -- 2884
local BuildAction = __TS__Class() -- 2914
BuildAction.name = "BuildAction" -- 2914
__TS__ClassExtends(BuildAction, Node) -- 2914
function BuildAction.prototype.prep(self, shared) -- 2915
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2915
		local last = shared.history[#shared.history] -- 2916
		if not last then -- 2916
			error( -- 2917
				__TS__New(Error, "no history"), -- 2917
				0 -- 2917
			) -- 2917
		end -- 2917
		emitAgentStartEvent(shared, last) -- 2918
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2918
	end) -- 2918
end -- 2915
function BuildAction.prototype.exec(self, input) -- 2922
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2922
		local params = input.params -- 2923
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 2924
		return ____awaiter_resolve(nil, result) -- 2924
	end) -- 2924
end -- 2922
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 2931
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2931
		local last = shared.history[#shared.history] -- 2932
		if last ~= nil then -- 2932
			last.result = execRes -- 2934
			appendToolResultMessage(shared, last) -- 2935
			emitAgentFinishEvent(shared, last) -- 2936
		end -- 2936
		persistHistoryState(shared) -- 2938
		__TS__Await(maybeCompressHistory(shared)) -- 2939
		persistHistoryState(shared) -- 2940
		return ____awaiter_resolve(nil, "main") -- 2940
	end) -- 2940
end -- 2931
local SpawnSubAgentAction = __TS__Class() -- 2945
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 2945
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 2945
function SpawnSubAgentAction.prototype.prep(self, shared) -- 2946
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2946
		local last = shared.history[#shared.history] -- 2955
		if not last then -- 2955
			error( -- 2956
				__TS__New(Error, "no history"), -- 2956
				0 -- 2956
			) -- 2956
		end -- 2956
		emitAgentStartEvent(shared, last) -- 2957
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 2958
			last.params.filesHint, -- 2959
			function(____, item) return type(item) == "string" end -- 2959
		) or nil -- 2959
		return ____awaiter_resolve( -- 2959
			nil, -- 2959
			{ -- 2961
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 2962
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 2963
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 2964
				filesHint = filesHint, -- 2965
				sessionId = shared.sessionId, -- 2966
				projectRoot = shared.workingDir, -- 2967
				spawnSubAgent = shared.spawnSubAgent -- 2968
			} -- 2968
		) -- 2968
	end) -- 2968
end -- 2946
function SpawnSubAgentAction.prototype.exec(self, input) -- 2972
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2972
		if not input.spawnSubAgent then -- 2972
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 2972
		end -- 2972
		if input.sessionId == nil or input.sessionId <= 0 then -- 2972
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 2972
		end -- 2972
		local ____Log_91 = Log -- 2987
		local ____temp_88 = #input.title -- 2987
		local ____temp_89 = #input.prompt -- 2987
		local ____temp_90 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 2987
		local ____opt_86 = input.filesHint -- 2987
		____Log_91( -- 2987
			"Info", -- 2987
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_88)) .. " prompt_len=") .. tostring(____temp_89)) .. " expected_len=") .. tostring(____temp_90)) .. " files_hint_count=") .. tostring(____opt_86 and #____opt_86 or 0) -- 2987
		) -- 2987
		local result = __TS__Await(input.spawnSubAgent({ -- 2988
			parentSessionId = input.sessionId, -- 2989
			projectRoot = input.projectRoot, -- 2990
			title = input.title, -- 2991
			prompt = input.prompt, -- 2992
			expectedOutput = input.expectedOutput, -- 2993
			filesHint = input.filesHint -- 2994
		})) -- 2994
		if not result.success then -- 2994
			return ____awaiter_resolve(nil, result) -- 2994
		end -- 2994
		return ____awaiter_resolve(nil, { -- 2994
			success = true, -- 3000
			sessionId = result.sessionId, -- 3001
			taskId = result.taskId, -- 3002
			title = result.title, -- 3003
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3004
		}) -- 3004
	end) -- 3004
end -- 2972
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3008
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3008
		local last = shared.history[#shared.history] -- 3009
		if last ~= nil then -- 3009
			last.result = execRes -- 3011
			appendToolResultMessage(shared, last) -- 3012
			emitAgentFinishEvent(shared, last) -- 3013
		end -- 3013
		persistHistoryState(shared) -- 3015
		__TS__Await(maybeCompressHistory(shared)) -- 3016
		persistHistoryState(shared) -- 3017
		return ____awaiter_resolve(nil, "main") -- 3017
	end) -- 3017
end -- 3008
local ListSubAgentsAction = __TS__Class() -- 3022
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3022
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3022
function ListSubAgentsAction.prototype.prep(self, shared) -- 3023
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3023
		local last = shared.history[#shared.history] -- 3032
		if not last then -- 3032
			error( -- 3033
				__TS__New(Error, "no history"), -- 3033
				0 -- 3033
			) -- 3033
		end -- 3033
		emitAgentStartEvent(shared, last) -- 3034
		return ____awaiter_resolve( -- 3034
			nil, -- 3034
			{ -- 3035
				sessionId = shared.sessionId, -- 3036
				projectRoot = shared.workingDir, -- 3037
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3038
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3039
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3040
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3041
				listSubAgents = shared.listSubAgents -- 3042
			} -- 3042
		) -- 3042
	end) -- 3042
end -- 3023
function ListSubAgentsAction.prototype.exec(self, input) -- 3046
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3046
		if not input.listSubAgents then -- 3046
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3046
		end -- 3046
		if input.sessionId == nil or input.sessionId <= 0 then -- 3046
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3046
		end -- 3046
		local result = __TS__Await(input.listSubAgents({ -- 3061
			sessionId = input.sessionId, -- 3062
			projectRoot = input.projectRoot, -- 3063
			status = input.status, -- 3064
			limit = input.limit, -- 3065
			offset = input.offset, -- 3066
			query = input.query -- 3067
		})) -- 3067
		return ____awaiter_resolve(nil, result) -- 3067
	end) -- 3067
end -- 3046
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3072
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3072
		local last = shared.history[#shared.history] -- 3073
		if last ~= nil then -- 3073
			last.result = execRes -- 3075
			appendToolResultMessage(shared, last) -- 3076
			emitAgentFinishEvent(shared, last) -- 3077
		end -- 3077
		persistHistoryState(shared) -- 3079
		__TS__Await(maybeCompressHistory(shared)) -- 3080
		persistHistoryState(shared) -- 3081
		return ____awaiter_resolve(nil, "main") -- 3081
	end) -- 3081
end -- 3072
local EditFileAction = __TS__Class() -- 3086
EditFileAction.name = "EditFileAction" -- 3086
__TS__ClassExtends(EditFileAction, Node) -- 3086
function EditFileAction.prototype.prep(self, shared) -- 3087
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3087
		local last = shared.history[#shared.history] -- 3088
		if not last then -- 3088
			error( -- 3089
				__TS__New(Error, "no history"), -- 3089
				0 -- 3089
			) -- 3089
		end -- 3089
		emitAgentStartEvent(shared, last) -- 3090
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3091
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3094
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3095
		if __TS__StringTrim(path) == "" then -- 3095
			error( -- 3096
				__TS__New(Error, "missing path"), -- 3096
				0 -- 3096
			) -- 3096
		end -- 3096
		return ____awaiter_resolve(nil, { -- 3096
			path = path, -- 3097
			oldStr = oldStr, -- 3097
			newStr = newStr, -- 3097
			taskId = shared.taskId, -- 3097
			workDir = shared.workingDir -- 3097
		}) -- 3097
	end) -- 3097
end -- 3087
function EditFileAction.prototype.exec(self, input) -- 3100
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3100
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3101
		if not readRes.success then -- 3101
			if input.oldStr ~= "" then -- 3101
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3101
			end -- 3101
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3106
			if not createRes.success then -- 3106
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3106
			end -- 3106
			return ____awaiter_resolve(nil, { -- 3106
				success = true, -- 3114
				changed = true, -- 3115
				mode = "create", -- 3116
				checkpointId = createRes.checkpointId, -- 3117
				checkpointSeq = createRes.checkpointSeq, -- 3118
				files = {{path = input.path, op = "create"}} -- 3119
			}) -- 3119
		end -- 3119
		if input.oldStr == "" then -- 3119
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3123
			if not overwriteRes.success then -- 3123
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3123
			end -- 3123
			return ____awaiter_resolve(nil, { -- 3123
				success = true, -- 3131
				changed = true, -- 3132
				mode = "overwrite", -- 3133
				checkpointId = overwriteRes.checkpointId, -- 3134
				checkpointSeq = overwriteRes.checkpointSeq, -- 3135
				files = {{path = input.path, op = "write"}} -- 3136
			}) -- 3136
		end -- 3136
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3141
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3142
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3143
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3146
		if occurrences == 0 then -- 3146
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3148
			if not indentTolerant.success then -- 3148
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3148
			end -- 3148
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3152
			if not applyRes.success then -- 3152
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3152
			end -- 3152
			return ____awaiter_resolve(nil, { -- 3152
				success = true, -- 3160
				changed = true, -- 3161
				mode = "replace_indent_tolerant", -- 3162
				checkpointId = applyRes.checkpointId, -- 3163
				checkpointSeq = applyRes.checkpointSeq, -- 3164
				files = {{path = input.path, op = "write"}} -- 3165
			}) -- 3165
		end -- 3165
		if occurrences > 1 then -- 3165
			return ____awaiter_resolve( -- 3165
				nil, -- 3165
				{ -- 3169
					success = false, -- 3169
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3169
				} -- 3169
			) -- 3169
		end -- 3169
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3173
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3174
		if not applyRes.success then -- 3174
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3174
		end -- 3174
		return ____awaiter_resolve(nil, { -- 3174
			success = true, -- 3182
			changed = true, -- 3183
			mode = "replace", -- 3184
			checkpointId = applyRes.checkpointId, -- 3185
			checkpointSeq = applyRes.checkpointSeq, -- 3186
			files = {{path = input.path, op = "write"}} -- 3187
		}) -- 3187
	end) -- 3187
end -- 3100
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3191
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3191
		local last = shared.history[#shared.history] -- 3192
		if last ~= nil then -- 3192
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3194
			last.result = execRes -- 3195
			appendToolResultMessage(shared, last) -- 3196
			emitAgentFinishEvent(shared, last) -- 3197
			local result = last.result -- 3198
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3198
				emitAgentEvent(shared, { -- 3203
					type = "checkpoint_created", -- 3204
					sessionId = shared.sessionId, -- 3205
					taskId = shared.taskId, -- 3206
					step = last.step, -- 3207
					tool = last.tool, -- 3208
					checkpointId = result.checkpointId, -- 3209
					checkpointSeq = result.checkpointSeq, -- 3210
					files = result.files -- 3211
				}) -- 3211
			end -- 3211
		end -- 3211
		persistHistoryState(shared) -- 3215
		__TS__Await(maybeCompressHistory(shared)) -- 3216
		persistHistoryState(shared) -- 3217
		return ____awaiter_resolve(nil, "main") -- 3217
	end) -- 3217
end -- 3191
local function emitCheckpointEventForAction(shared, action) -- 3222
	local result = action.result -- 3223
	if not result then -- 3223
		return -- 3224
	end -- 3224
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3224
		emitAgentEvent(shared, { -- 3229
			type = "checkpoint_created", -- 3230
			sessionId = shared.sessionId, -- 3231
			taskId = shared.taskId, -- 3232
			step = action.step, -- 3233
			tool = action.tool, -- 3234
			checkpointId = result.checkpointId, -- 3235
			checkpointSeq = result.checkpointSeq, -- 3236
			files = result.files -- 3237
		}) -- 3237
	end -- 3237
end -- 3222
function executeToolAction(shared, action) -- 3242
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3242
		if shared.stopToken.stopped then -- 3242
			return ____awaiter_resolve( -- 3242
				nil, -- 3242
				{ -- 3244
					success = false, -- 3244
					message = getCancelledReason(shared) -- 3244
				} -- 3244
			) -- 3244
		end -- 3244
		local params = action.params -- 3246
		if action.tool == "read_file" then -- 3246
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3248
			if __TS__StringTrim(path) == "" then -- 3248
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3248
			end -- 3248
			local ____Tools_readFile_96 = Tools.readFile -- 3252
			local ____shared_workingDir_94 = shared.workingDir -- 3253
			local ____params_startLine_92 = params.startLine -- 3255
			if ____params_startLine_92 == nil then -- 3255
				____params_startLine_92 = 1 -- 3255
			end -- 3255
			local ____TS__Number_result_95 = __TS__Number(____params_startLine_92) -- 3255
			local ____params_endLine_93 = params.endLine -- 3256
			if ____params_endLine_93 == nil then -- 3256
				____params_endLine_93 = READ_FILE_DEFAULT_LIMIT -- 3256
			end -- 3256
			return ____awaiter_resolve( -- 3256
				nil, -- 3256
				____Tools_readFile_96( -- 3252
					____shared_workingDir_94, -- 3253
					path, -- 3254
					____TS__Number_result_95, -- 3255
					__TS__Number(____params_endLine_93), -- 3256
					shared.useChineseResponse and "zh" or "en" -- 3257
				) -- 3257
			) -- 3257
		end -- 3257
		if action.tool == "grep_files" then -- 3257
			local ____Tools_searchFiles_110 = Tools.searchFiles -- 3261
			local ____shared_workingDir_103 = shared.workingDir -- 3262
			local ____temp_104 = params.path or "" -- 3263
			local ____temp_105 = params.pattern or "" -- 3264
			local ____params_globs_106 = params.globs -- 3265
			local ____params_useRegex_107 = params.useRegex -- 3266
			local ____params_caseSensitive_108 = params.caseSensitive -- 3267
			local ____math_max_99 = math.max -- 3270
			local ____math_floor_98 = math.floor -- 3270
			local ____params_limit_97 = params.limit -- 3270
			if ____params_limit_97 == nil then -- 3270
				____params_limit_97 = SEARCH_FILES_LIMIT_DEFAULT -- 3270
			end -- 3270
			local ____math_max_99_result_109 = ____math_max_99( -- 3270
				1, -- 3270
				____math_floor_98(__TS__Number(____params_limit_97)) -- 3270
			) -- 3270
			local ____math_max_102 = math.max -- 3271
			local ____math_floor_101 = math.floor -- 3271
			local ____params_offset_100 = params.offset -- 3271
			if ____params_offset_100 == nil then -- 3271
				____params_offset_100 = 0 -- 3271
			end -- 3271
			local result = __TS__Await(____Tools_searchFiles_110({ -- 3261
				workDir = ____shared_workingDir_103, -- 3262
				path = ____temp_104, -- 3263
				pattern = ____temp_105, -- 3264
				globs = ____params_globs_106, -- 3265
				useRegex = ____params_useRegex_107, -- 3266
				caseSensitive = ____params_caseSensitive_108, -- 3267
				includeContent = true, -- 3268
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3269
				limit = ____math_max_99_result_109, -- 3270
				offset = ____math_max_102( -- 3271
					0, -- 3271
					____math_floor_101(__TS__Number(____params_offset_100)) -- 3271
				), -- 3271
				groupByFile = params.groupByFile == true -- 3272
			})) -- 3272
			return ____awaiter_resolve(nil, result) -- 3272
		end -- 3272
		if action.tool == "search_dora_api" then -- 3272
			local ____Tools_searchDoraAPI_118 = Tools.searchDoraAPI -- 3277
			local ____temp_114 = params.pattern or "" -- 3278
			local ____temp_115 = params.docSource or "api" -- 3279
			local ____temp_116 = shared.useChineseResponse and "zh" or "en" -- 3280
			local ____temp_117 = params.programmingLanguage or "ts" -- 3281
			local ____math_min_113 = math.min -- 3282
			local ____math_max_112 = math.max -- 3282
			local ____params_limit_111 = params.limit -- 3282
			if ____params_limit_111 == nil then -- 3282
				____params_limit_111 = 8 -- 3282
			end -- 3282
			local result = __TS__Await(____Tools_searchDoraAPI_118({ -- 3277
				pattern = ____temp_114, -- 3278
				docSource = ____temp_115, -- 3279
				docLanguage = ____temp_116, -- 3280
				programmingLanguage = ____temp_117, -- 3281
				limit = ____math_min_113( -- 3282
					SEARCH_DORA_API_LIMIT_MAX, -- 3282
					____math_max_112( -- 3282
						1, -- 3282
						__TS__Number(____params_limit_111) -- 3282
					) -- 3282
				), -- 3282
				useRegex = params.useRegex, -- 3283
				caseSensitive = false, -- 3284
				includeContent = true, -- 3285
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3286
			})) -- 3286
			return ____awaiter_resolve(nil, result) -- 3286
		end -- 3286
		if action.tool == "glob_files" then -- 3286
			local ____Tools_listFiles_125 = Tools.listFiles -- 3291
			local ____shared_workingDir_122 = shared.workingDir -- 3292
			local ____temp_123 = params.path or "" -- 3293
			local ____params_globs_124 = params.globs -- 3294
			local ____math_max_121 = math.max -- 3295
			local ____math_floor_120 = math.floor -- 3295
			local ____params_maxEntries_119 = params.maxEntries -- 3295
			if ____params_maxEntries_119 == nil then -- 3295
				____params_maxEntries_119 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3295
			end -- 3295
			local result = ____Tools_listFiles_125({ -- 3291
				workDir = ____shared_workingDir_122, -- 3292
				path = ____temp_123, -- 3293
				globs = ____params_globs_124, -- 3294
				maxEntries = ____math_max_121( -- 3295
					1, -- 3295
					____math_floor_120(__TS__Number(____params_maxEntries_119)) -- 3295
				) -- 3295
			}) -- 3295
			return ____awaiter_resolve(nil, result) -- 3295
		end -- 3295
		if action.tool == "delete_file" then -- 3295
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3300
			if __TS__StringTrim(targetFile) == "" then -- 3300
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3300
			end -- 3300
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3304
			if not result.success then -- 3304
				return ____awaiter_resolve(nil, result) -- 3304
			end -- 3304
			return ____awaiter_resolve(nil, { -- 3304
				success = true, -- 3312
				changed = true, -- 3313
				mode = "delete", -- 3314
				checkpointId = result.checkpointId, -- 3315
				checkpointSeq = result.checkpointSeq, -- 3316
				files = {{path = targetFile, op = "delete"}} -- 3317
			}) -- 3317
		end -- 3317
		if action.tool == "build" then -- 3317
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3321
			return ____awaiter_resolve(nil, result) -- 3321
		end -- 3321
		if action.tool == "spawn_sub_agent" then -- 3321
			if not shared.spawnSubAgent then -- 3321
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3321
			end -- 3321
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3321
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3321
			end -- 3321
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3334
				params.filesHint, -- 3335
				function(____, item) return type(item) == "string" end -- 3335
			) or nil -- 3335
			local result = __TS__Await(shared.spawnSubAgent({ -- 3337
				parentSessionId = shared.sessionId, -- 3338
				projectRoot = shared.workingDir, -- 3339
				title = type(params.title) == "string" and params.title or "Sub", -- 3340
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3341
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3342
				filesHint = filesHint -- 3343
			})) -- 3343
			if not result.success then -- 3343
				return ____awaiter_resolve(nil, result) -- 3343
			end -- 3343
			return ____awaiter_resolve(nil, { -- 3343
				success = true, -- 3349
				sessionId = result.sessionId, -- 3350
				taskId = result.taskId, -- 3351
				title = result.title, -- 3352
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3353
			}) -- 3353
		end -- 3353
		if action.tool == "list_sub_agents" then -- 3353
			if not shared.listSubAgents then -- 3353
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3353
			end -- 3353
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3353
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3353
			end -- 3353
			local result = __TS__Await(shared.listSubAgents({ -- 3363
				sessionId = shared.sessionId, -- 3364
				projectRoot = shared.workingDir, -- 3365
				status = type(params.status) == "string" and params.status or nil, -- 3366
				limit = type(params.limit) == "number" and params.limit or nil, -- 3367
				offset = type(params.offset) == "number" and params.offset or nil, -- 3368
				query = type(params.query) == "string" and params.query or nil -- 3369
			})) -- 3369
			return ____awaiter_resolve(nil, result) -- 3369
		end -- 3369
		if action.tool == "edit_file" then -- 3369
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3374
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3377
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3378
			if __TS__StringTrim(path) == "" then -- 3378
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3378
			end -- 3378
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3380
			return ____awaiter_resolve( -- 3380
				nil, -- 3380
				actionNode:exec({ -- 3381
					path = path, -- 3382
					oldStr = oldStr, -- 3383
					newStr = newStr, -- 3384
					taskId = shared.taskId, -- 3385
					workDir = shared.workingDir -- 3386
				}) -- 3386
			) -- 3386
		end -- 3386
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3386
	end) -- 3386
end -- 3242
local function sanitizeToolActionResultForHistory(action, result) -- 3392
	if action.tool == "read_file" then -- 3392
		return sanitizeReadResultForHistory(action.tool, result) -- 3394
	end -- 3394
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3394
		return sanitizeSearchResultForHistory(action.tool, result) -- 3397
	end -- 3397
	if action.tool == "glob_files" then -- 3397
		return sanitizeListFilesResultForHistory(result) -- 3400
	end -- 3400
	return result -- 3402
end -- 3392
local function canRunBatchActionInParallel(self, action) -- 3405
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 3406
end -- 3405
local BatchToolAction = __TS__Class() -- 3413
BatchToolAction.name = "BatchToolAction" -- 3413
__TS__ClassExtends(BatchToolAction, Node) -- 3413
function BatchToolAction.prototype.prep(self, shared) -- 3414
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3414
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3414
	end) -- 3414
end -- 3414
function BatchToolAction.prototype.exec(self, input) -- 3418
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3418
		local shared = input.shared -- 3419
		local preExecuted = shared.preExecutedResults
		local allParallelSafe = #input.actions > 1 and __TS__ArrayEvery(input.actions, canRunBatchActionInParallel) -- 3420
		if not allParallelSafe then -- 3420
			do -- 3420
				local i = 0 -- 3422
				while i < #input.actions do -- 3422
					local action = input.actions[i + 1] -- 3423
					emitAgentStartEvent(shared, action) -- 3424
					local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3425
					action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3426
					action.result = sanitizeToolActionResultForHistory(action, result) -- 3427
					appendToolResultMessage(shared, action) -- 3428
					emitAgentFinishEvent(shared, action) -- 3429
					emitCheckpointEventForAction(shared, action) -- 3430
					persistHistoryState(shared) -- 3431
					if shared.stopToken.stopped then -- 3431
						break -- 3433
					end -- 3433
					i = i + 1 -- 3422
				end -- 3422
			end -- 3422
			return ____awaiter_resolve(nil, input.actions) -- 3422
		end -- 3422
		local preExecCount = #__TS__ArrayFilter(
			input.actions,
			function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end
		)
		Log( -- 3439
			"Info", -- 3439
			(("[CodingAgent] batch read-only tools executing in parallel count=" .. tostring(#input.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3439
		) -- 3439
		do -- 3439
			local i = 0 -- 3440
			while i < #input.actions do -- 3440
				emitAgentStartEvent(shared, input.actions[i + 1]) -- 3441
				i = i + 1 -- 3440
			end -- 3440
		end -- 3440
		__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3443
			input.actions, -- 3443
			function(____, action) -- 3443
				return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3443
					if shared.stopToken.stopped then -- 3443
						action.result = { -- 3445
							success = false, -- 3445
							message = getCancelledReason(shared) -- 3445
						} -- 3445
						return ____awaiter_resolve(nil, action) -- 3445
					end -- 3445
					local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3448
					action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3449
					action.result = sanitizeToolActionResultForHistory(action, result) -- 3450
					return ____awaiter_resolve(nil, action) -- 3450
				end) -- 3450
			end -- 3443
		))) -- 3443
		do -- 3443
			local i = 0 -- 3453
			while i < #input.actions do -- 3453
				local action = input.actions[i + 1] -- 3454
				if not action.result then -- 3454
					action.result = {success = false, message = "tool did not produce a result"} -- 3456
				end -- 3456
				appendToolResultMessage(shared, action) -- 3458
				emitAgentFinishEvent(shared, action) -- 3459
				emitCheckpointEventForAction(shared, action) -- 3460
				i = i + 1 -- 3453
			end -- 3453
		end -- 3453
		persistHistoryState(shared) -- 3462
		return ____awaiter_resolve(nil, input.actions) -- 3462
	end) -- 3462
end -- 3418
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3466
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3466
		shared.pendingToolActions = nil -- 3467
		shared.preExecutedResults = nil
		persistHistoryState(shared) -- 3468
		__TS__Await(maybeCompressHistory(shared)) -- 3469
		persistHistoryState(shared) -- 3470
		return ____awaiter_resolve(nil, "main") -- 3470
	end) -- 3470
end -- 3466
local EndNode = __TS__Class() -- 3475
EndNode.name = "EndNode" -- 3475
__TS__ClassExtends(EndNode, Node) -- 3475
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3476
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3476
		return ____awaiter_resolve(nil, nil) -- 3476
	end) -- 3476
end -- 3476
local CodingAgentFlow = __TS__Class() -- 3481
CodingAgentFlow.name = "CodingAgentFlow" -- 3481
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3481
function CodingAgentFlow.prototype.____constructor(self, role) -- 3482
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3483
	local read = __TS__New(ReadFileAction, 1, 0) -- 3484
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3485
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3486
	local list = __TS__New(ListFilesAction, 1, 0) -- 3487
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3488
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3489
	local build = __TS__New(BuildAction, 1, 0) -- 3490
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3491
	local edit = __TS__New(EditFileAction, 1, 0) -- 3492
	local batch = __TS__New(BatchToolAction, 1, 0) -- 3493
	local done = __TS__New(EndNode, 1, 0) -- 3494
	main:on("batch_tools", batch) -- 3496
	main:on("grep_files", search) -- 3497
	main:on("search_dora_api", searchDora) -- 3498
	main:on("glob_files", list) -- 3499
	if role == "main" then -- 3499
		main:on("read_file", read) -- 3501
		main:on("delete_file", del) -- 3502
		main:on("build", build) -- 3503
		main:on("edit_file", edit) -- 3504
		main:on("list_sub_agents", listSub) -- 3505
		main:on("spawn_sub_agent", spawn) -- 3506
	else -- 3506
		main:on("read_file", read) -- 3508
		main:on("delete_file", del) -- 3509
		main:on("build", build) -- 3510
		main:on("edit_file", edit) -- 3511
	end -- 3511
	main:on("done", done) -- 3513
	search:on("main", main) -- 3515
	searchDora:on("main", main) -- 3516
	list:on("main", main) -- 3517
	listSub:on("main", main) -- 3518
	spawn:on("main", main) -- 3519
	batch:on("main", main) -- 3520
	read:on("main", main) -- 3521
	del:on("main", main) -- 3522
	build:on("main", main) -- 3523
	edit:on("main", main) -- 3524
	Flow.prototype.____constructor(self, main) -- 3526
end -- 3482
local function runCodingAgentAsync(options) -- 3548
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3548
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3548
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3548
		end -- 3548
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3552
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3553
		if not llmConfigRes.success then -- 3553
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3553
		end -- 3553
		local llmConfig = llmConfigRes.config -- 3559
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3560
		if not taskRes.success then -- 3560
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3560
		end -- 3560
		local compressor = __TS__New(MemoryCompressor, { -- 3567
			compressionThreshold = 0.8, -- 3568
			compressionTargetThreshold = 0.5, -- 3569
			maxCompressionRounds = 3, -- 3570
			projectDir = options.workDir, -- 3571
			llmConfig = llmConfig, -- 3572
			promptPack = options.promptPack, -- 3573
			scope = options.memoryScope -- 3574
		}) -- 3574
		local persistedSession = compressor:getStorage():readSessionState() -- 3576
		local promptPack = compressor:getPromptPack() -- 3577
		local shared = { -- 3579
			sessionId = options.sessionId, -- 3580
			taskId = taskRes.taskId, -- 3581
			role = options.role or "main", -- 3582
			maxSteps = math.max( -- 3583
				1, -- 3583
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 3583
			), -- 3583
			llmMaxTry = math.max( -- 3584
				1, -- 3584
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 3584
			), -- 3584
			step = 0, -- 3585
			done = false, -- 3586
			stopToken = options.stopToken or ({stopped = false}), -- 3587
			response = "", -- 3588
			userQuery = normalizedPrompt, -- 3589
			workingDir = options.workDir, -- 3590
			useChineseResponse = options.useChineseResponse == true, -- 3591
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3592
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 3595
			llmConfig = llmConfig, -- 3596
			onEvent = options.onEvent, -- 3597
			promptPack = promptPack, -- 3598
			history = {}, -- 3599
			messages = persistedSession.messages, -- 3600
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 3601
			carryMessageIndex = persistedSession.carryMessageIndex, -- 3602
			memory = {compressor = compressor}, -- 3604
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 3608
			spawnSubAgent = options.spawnSubAgent, -- 3613
			listSubAgents = options.listSubAgents -- 3614
		} -- 3614
		local ____try = __TS__AsyncAwaiter(function() -- 3614
			emitAgentEvent(shared, { -- 3618
				type = "task_started", -- 3619
				sessionId = shared.sessionId, -- 3620
				taskId = shared.taskId, -- 3621
				prompt = shared.userQuery, -- 3622
				workDir = shared.workingDir, -- 3623
				maxSteps = shared.maxSteps -- 3624
			}) -- 3624
			if shared.stopToken.stopped then -- 3624
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3627
				return ____awaiter_resolve( -- 3627
					nil, -- 3627
					emitAgentTaskFinishEvent( -- 3628
						shared, -- 3628
						false, -- 3628
						getCancelledReason(shared) -- 3628
					) -- 3628
				) -- 3628
			end -- 3628
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3630
			local promptCommand = getPromptCommand(shared.userQuery) -- 3631
			if promptCommand == "clear" then -- 3631
				return ____awaiter_resolve( -- 3631
					nil, -- 3631
					clearSessionHistory(shared) -- 3633
				) -- 3633
			end -- 3633
			if promptCommand == "compact" then -- 3633
				if shared.role == "sub" then -- 3633
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 3637
					return ____awaiter_resolve( -- 3637
						nil, -- 3637
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 3638
					) -- 3638
				end -- 3638
				return ____awaiter_resolve( -- 3638
					nil, -- 3638
					__TS__Await(compactAllHistory(shared)) -- 3646
				) -- 3646
			end -- 3646
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3648
			persistHistoryState(shared) -- 3652
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3653
			__TS__Await(flow:run(shared)) -- 3654
			if shared.stopToken.stopped then -- 3654
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3656
				return ____awaiter_resolve( -- 3656
					nil, -- 3656
					emitAgentTaskFinishEvent( -- 3657
						shared, -- 3657
						false, -- 3657
						getCancelledReason(shared) -- 3657
					) -- 3657
				) -- 3657
			end -- 3657
			if shared.error then -- 3657
				return ____awaiter_resolve( -- 3657
					nil, -- 3657
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3660
				) -- 3660
			end -- 3660
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3663
			return ____awaiter_resolve( -- 3663
				nil, -- 3663
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3664
			) -- 3664
		end) -- 3664
		__TS__Await(____try.catch( -- 3617
			____try, -- 3617
			function(____, e) -- 3617
				return ____awaiter_resolve( -- 3617
					nil, -- 3617
					finalizeAgentFailure( -- 3667
						shared, -- 3667
						tostring(e) -- 3667
					) -- 3667
				) -- 3667
			end -- 3667
		)) -- 3667
	end) -- 3667
end -- 3548
function ____exports.runCodingAgent(options, callback) -- 3671
	local ____self_126 = runCodingAgentAsync(options) -- 3671
	____self_126["then"]( -- 3671
		____self_126, -- 3671
		function(____, result) return callback(result) end -- 3672
	) -- 3672
end -- 3671
return ____exports -- 3671