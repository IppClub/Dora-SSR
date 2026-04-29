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
local __TS__PromiseAll = ____lualib.__TS__PromiseAll -- 1
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
local ____exports = {} -- 1
local isArray, stripWrappingQuotes, parseSimpleYAML, emitAgentEvent, truncateText, getReplyLanguageDirective, replacePromptVars, getDecisionToolDefinitions, getFinishMessage, persistHistoryState, getActiveConversationMessages, getActiveRealMessageCount, applyCompressedSessionState, getDecisionPath, clampIntegerParam, parseReadLineParam, validateDecision, getAllowedToolsForRole, buildAgentSystemPrompt, buildSkillsSection, buildXmlDecisionInstruction, emitAgentTaskFinishEvent, READ_FILE_DEFAULT_LIMIT, SEARCH_DORA_API_LIMIT_MAX, SEARCH_FILES_LIMIT_DEFAULT, LIST_FILES_MAX_ENTRIES_DEFAULT -- 1
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
	local rolePrompt = shared.role == "main" and "### Agent Role\n\nYou are the main agent. Your job is to discuss plans with the user, inspect the codebase, make direct edits when that is the simplest path, and delegate larger or parallelizable implementation work by spawning sub agents.\n\nRules:\n- You may use the full toolset directly, including edit_file, delete_file, and build.\n- Use direct tools for small, focused, or user-interactive changes where staying in the current run gives the clearest result.\n- Use spawn_sub_agent for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n- Use list_sub_agents only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether another delegation is necessary or whether to read a result file.\n- Keep sub-agent titles short and specific.\n- The sub-agent prompt should be self-contained and executable, and should explain the exact task, constraints, expected output, and relevant files when known.\n- After spawn_sub_agent succeeds, immediately finish the current turn and tell the user the work has been delegated.\n- After a successful spawn_sub_agent, do not call list_sub_agents or any other tool in the same turn.\n- Treat the sub-agent completion result as an asynchronous handoff that should be continued in later conversation turns." or "### Agent Role\n\nYou are a sub agent. Your job is to execute concrete implementation, editing, and build work delegated by the main agent.\n\nRules:\n- Focus on completing the delegated task end-to-end.\n- Use the available implementation tools directly when needed, including edit_file, delete_file, and build.\n- Documentation writing tasks are also part of your execution scope when delegated by the main agent.\n- Summaries should stay concise and execution-oriented." -- 2000
	local sections = { -- 2024
		shared.promptPack.agentIdentityPrompt, -- 2025
		rolePrompt, -- 2026
		getReplyLanguageDirective(shared) -- 2027
	} -- 2027
	if shared.decisionMode == "tool_calling" then -- 2027
		sections[#sections + 1] = "### Function Calling\n\nYou may return multiple tool calls in one response when the calls are independent and all results are useful before the next reasoning step. Do not include finish in a multi-tool response." -- 2030
	end -- 2030
	local contextWindow = shared.llmConfig.contextWindow or 64000 -- memory layers
	local memoryBudget = math.max(1200, math.floor(contextWindow * 0.08)) -- memory layers
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2034
	if memoryContext ~= "" then -- 2034
		sections[#sections + 1] = memoryContext -- 2036
	end -- 2036
	if includeToolDefinitions then -- 2036
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2039
		if shared.decisionMode == "xml" then -- 2039
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2041
		end -- 2041
	end -- 2041
	local skillsSection = buildSkillsSection(shared) -- 2045
	if skillsSection ~= "" then -- 2045
		sections[#sections + 1] = skillsSection -- 2047
	end -- 2047
	return table.concat(sections, "\n\n") -- 2049
end -- 2049
function buildSkillsSection(shared) -- 2052
	local ____opt_34 = shared.skills -- 2052
	if not (____opt_34 and ____opt_34.loader) then -- 2052
		return "" -- 2054
	end -- 2054
	return shared.skills.loader:buildSkillsPromptSection() -- 2056
end -- 2056
function buildXmlDecisionInstruction(shared, feedback) -- 2168
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2169
end -- 2169
function emitAgentTaskFinishEvent(shared, success, message) -- 3524
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3525
	emitAgentEvent(shared, { -- 3531
		type = "task_finished", -- 3532
		sessionId = shared.sessionId, -- 3533
		taskId = shared.taskId, -- 3534
		success = result.success, -- 3535
		message = result.message, -- 3536
		steps = result.steps -- 3537
	}) -- 3537
	return result -- 3539
end -- 3539
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
local function sanitizeMessagesForLLMInput(messages) -- 2059
	local sanitized = {} -- 2060
	local droppedAssistantToolCalls = 0 -- 2061
	local droppedToolResults = 0 -- 2062
	do -- 2062
		local i = 0 -- 2063
		while i < #messages do -- 2063
			do -- 2063
				local message = messages[i + 1] -- 2064
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2064
					local requiredIds = {} -- 2066
					do -- 2066
						local j = 0 -- 2067
						while j < #message.tool_calls do -- 2067
							local toolCall = message.tool_calls[j + 1] -- 2068
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2069
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2069
								requiredIds[#requiredIds + 1] = id -- 2071
							end -- 2071
							j = j + 1 -- 2067
						end -- 2067
					end -- 2067
					if #requiredIds == 0 then -- 2067
						sanitized[#sanitized + 1] = message -- 2075
						goto __continue313 -- 2076
					end -- 2076
					local matchedIds = {} -- 2078
					local matchedTools = {} -- 2079
					local j = i + 1 -- 2080
					while j < #messages do -- 2080
						local toolMessage = messages[j + 1] -- 2082
						if toolMessage.role ~= "tool" then -- 2082
							break -- 2083
						end -- 2083
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2084
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2084
							matchedIds[toolCallId] = true -- 2086
							matchedTools[#matchedTools + 1] = toolMessage -- 2087
						else -- 2087
							droppedToolResults = droppedToolResults + 1 -- 2089
						end -- 2089
						j = j + 1 -- 2091
					end -- 2091
					local complete = true -- 2093
					do -- 2093
						local j = 0 -- 2094
						while j < #requiredIds do -- 2094
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2094
								complete = false -- 2096
								break -- 2097
							end -- 2097
							j = j + 1 -- 2094
						end -- 2094
					end -- 2094
					if complete then -- 2094
						__TS__ArrayPush( -- 2101
							sanitized, -- 2101
							message, -- 2101
							table.unpack(matchedTools) -- 2101
						) -- 2101
					else -- 2101
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2103
						droppedToolResults = droppedToolResults + #matchedTools -- 2104
					end -- 2104
					i = j - 1 -- 2106
					goto __continue313 -- 2107
				end -- 2107
				if message.role == "tool" then -- 2107
					droppedToolResults = droppedToolResults + 1 -- 2110
					goto __continue313 -- 2111
				end -- 2111
				sanitized[#sanitized + 1] = message -- 2113
			end -- 2113
			::__continue313:: -- 2113
			i = i + 1 -- 2063
		end -- 2063
	end -- 2063
	return sanitized -- 2115
end -- 2059
local function getUnconsolidatedMessages(shared) -- 2118
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2119
end -- 2118
local function getFinalDecisionTurnPrompt(shared) -- 2122
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2123
end -- 2122
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2128
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2128
		return messages -- 2129
	end -- 2129
	local next = __TS__ArrayMap( -- 2130
		messages, -- 2130
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2130
	) -- 2130
	do -- 2130
		local i = #next - 1 -- 2131
		while i >= 0 do -- 2131
			do -- 2131
				local message = next[i + 1] -- 2132
				if message.role ~= "assistant" and message.role ~= "user" then -- 2132
					goto __continue335 -- 2133
				end -- 2133
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2134
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2135
				return next -- 2138
			end -- 2138
			::__continue335:: -- 2138
			i = i - 1 -- 2131
		end -- 2131
	end -- 2131
	next[#next + 1] = {role = "user", content = prompt} -- 2140
	return next -- 2141
end -- 2128
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2144
	if attempt == nil then -- 2144
		attempt = 1 -- 2144
	end -- 2144
	local messages = { -- 2145
		{ -- 2146
			role = "system", -- 2146
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 2146
		}, -- 2146
		table.unpack(getUnconsolidatedMessages(shared)) -- 2147
	} -- 2147
	if shared.step + 1 >= shared.maxSteps then -- 2147
		messages = appendPromptToLatestDecisionMessage( -- 2150
			messages, -- 2150
			getFinalDecisionTurnPrompt(shared) -- 2150
		) -- 2150
	end -- 2150
	if lastError and lastError ~= "" then -- 2150
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2153
		messages[#messages + 1] = { -- 2156
			role = "user", -- 2157
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2158
		} -- 2158
	end -- 2158
	return messages -- 2165
end -- 2144
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2172
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2179
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2180
	local repairPrompt = replacePromptVars( -- 2188
		shared.promptPack.xmlDecisionRepairPrompt, -- 2188
		{ -- 2188
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2189
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2190
			CANDIDATE_SECTION = candidateSection, -- 2191
			LAST_ERROR = lastError, -- 2192
			ATTEMPT = tostring(attempt) -- 2193
		} -- 2193
	) -- 2193
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2195
end -- 2172
local function tryParseAndValidateDecision(rawText) -- 2207
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2208
	if not parsed.success then -- 2208
		return {success = false, message = parsed.message, raw = rawText} -- 2210
	end -- 2210
	local decision = parseDecisionObject(parsed.obj) -- 2212
	if not decision.success then -- 2212
		return {success = false, message = decision.message, raw = rawText} -- 2214
	end -- 2214
	local validation = validateDecision(decision.tool, decision.params) -- 2216
	if not validation.success then -- 2216
		return {success = false, message = validation.message, raw = rawText} -- 2218
	end -- 2218
	decision.params = validation.params -- 2220
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2221
	return decision -- 2222
end -- 2207
local function normalizeLineEndings(text) -- 2225
	local res = string.gsub(text, "\r\n", "\n") -- 2226
	res = string.gsub(res, "\r", "\n") -- 2227
	return res -- 2228
end -- 2225
local function countOccurrences(text, searchStr) -- 2231
	if searchStr == "" then -- 2231
		return 0 -- 2232
	end -- 2232
	local count = 0 -- 2233
	local pos = 0 -- 2234
	while true do -- 2234
		local idx = (string.find( -- 2236
			text, -- 2236
			searchStr, -- 2236
			math.max(pos + 1, 1), -- 2236
			true -- 2236
		) or 0) - 1 -- 2236
		if idx < 0 then -- 2236
			break -- 2237
		end -- 2237
		count = count + 1 -- 2238
		pos = idx + #searchStr -- 2239
	end -- 2239
	return count -- 2241
end -- 2231
local function replaceFirst(text, oldStr, newStr) -- 2244
	if oldStr == "" then -- 2244
		return text -- 2245
	end -- 2245
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2246
	if idx < 0 then -- 2246
		return text -- 2247
	end -- 2247
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2248
end -- 2244
local function splitLines(text) -- 2251
	return __TS__StringSplit(text, "\n") -- 2252
end -- 2251
local function getLeadingWhitespace(text) -- 2255
	local i = 0 -- 2256
	while i < #text do -- 2256
		local ch = __TS__StringAccess(text, i) -- 2258
		if ch ~= " " and ch ~= "\t" then -- 2258
			break -- 2259
		end -- 2259
		i = i + 1 -- 2260
	end -- 2260
	return __TS__StringSubstring(text, 0, i) -- 2262
end -- 2255
local function getCommonIndentPrefix(lines) -- 2265
	local common -- 2266
	do -- 2266
		local i = 0 -- 2267
		while i < #lines do -- 2267
			do -- 2267
				local line = lines[i + 1] -- 2268
				if __TS__StringTrim(line) == "" then -- 2268
					goto __continue360 -- 2269
				end -- 2269
				local indent = getLeadingWhitespace(line) -- 2270
				if common == nil then -- 2270
					common = indent -- 2272
					goto __continue360 -- 2273
				end -- 2273
				local j = 0 -- 2275
				local maxLen = math.min(#common, #indent) -- 2276
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2276
					j = j + 1 -- 2278
				end -- 2278
				common = __TS__StringSubstring(common, 0, j) -- 2280
				if common == "" then -- 2280
					break -- 2281
				end -- 2281
			end -- 2281
			::__continue360:: -- 2281
			i = i + 1 -- 2267
		end -- 2267
	end -- 2267
	return common or "" -- 2283
end -- 2265
local function removeIndentPrefix(line, indent) -- 2286
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2286
		return __TS__StringSubstring(line, #indent) -- 2288
	end -- 2288
	local lineIndent = getLeadingWhitespace(line) -- 2290
	local j = 0 -- 2291
	local maxLen = math.min(#lineIndent, #indent) -- 2292
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2292
		j = j + 1 -- 2294
	end -- 2294
	return __TS__StringSubstring(line, j) -- 2296
end -- 2286
local function dedentLines(lines) -- 2299
	local indent = getCommonIndentPrefix(lines) -- 2300
	return { -- 2301
		indent = indent, -- 2302
		lines = __TS__ArrayMap( -- 2303
			lines, -- 2303
			function(____, line) return removeIndentPrefix(line, indent) end -- 2303
		) -- 2303
	} -- 2303
end -- 2299
local function joinLines(lines) -- 2307
	return table.concat(lines, "\n") -- 2308
end -- 2307
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2311
	local contentLines = splitLines(content) -- 2316
	local oldLines = splitLines(oldStr) -- 2317
	if #oldLines == 0 then -- 2317
		return {success = false, message = "old_str not found in file"} -- 2319
	end -- 2319
	local dedentedOld = dedentLines(oldLines) -- 2321
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2322
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2323
	local matches = {} -- 2324
	do -- 2324
		local start = 0 -- 2325
		while start <= #contentLines - #oldLines do -- 2325
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2326
			local dedentedCandidate = dedentLines(candidateLines) -- 2327
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2327
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2329
			end -- 2329
			start = start + 1 -- 2325
		end -- 2325
	end -- 2325
	if #matches == 0 then -- 2325
		return {success = false, message = "old_str not found in file"} -- 2337
	end -- 2337
	if #matches > 1 then -- 2337
		return { -- 2340
			success = false, -- 2341
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2342
		} -- 2342
	end -- 2342
	local match = matches[1] -- 2345
	local rebuiltNewLines = __TS__ArrayMap( -- 2346
		dedentedNew.lines, -- 2346
		function(____, line) return line == "" and "" or match.indent .. line end -- 2346
	) -- 2346
	local ____array_38 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2346
	__TS__SparseArrayPush( -- 2346
		____array_38, -- 2346
		table.unpack(rebuiltNewLines) -- 2349
	) -- 2349
	__TS__SparseArrayPush( -- 2349
		____array_38, -- 2349
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2350
	) -- 2350
	local nextLines = {__TS__SparseArraySpread(____array_38)} -- 2347
	return { -- 2352
		success = true, -- 2352
		content = joinLines(nextLines) -- 2352
	} -- 2352
end -- 2311
local MainDecisionAgent = __TS__Class() -- 2355
MainDecisionAgent.name = "MainDecisionAgent" -- 2355
__TS__ClassExtends(MainDecisionAgent, Node) -- 2355
function MainDecisionAgent.prototype.prep(self, shared) -- 2356
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2356
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2356
			return ____awaiter_resolve(nil, {shared = shared}) -- 2356
		end -- 2356
		__TS__Await(maybeCompressHistory(shared)) -- 2361
		return ____awaiter_resolve(nil, {shared = shared}) -- 2361
	end) -- 2361
end -- 2356
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2366
	if attempt == nil then -- 2366
		attempt = 1 -- 2369
	end -- 2369
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2369
		if shared.stopToken.stopped then -- 2369
			return ____awaiter_resolve( -- 2369
				nil, -- 2369
				{ -- 2373
					success = false, -- 2373
					message = getCancelledReason(shared) -- 2373
				} -- 2373
			) -- 2373
		end -- 2373
		Log( -- 2375
			"Info", -- 2375
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2375
		) -- 2375
		local tools = buildDecisionToolSchema(shared) -- 2376
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2377
		local stepId = shared.step + 1 -- 2378
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2379
		saveStepLLMDebugInput( -- 2383
			shared, -- 2383
			stepId, -- 2383
			"decision_tool_calling", -- 2383
			messages, -- 2383
			llmOptions -- 2383
		) -- 2383
		local lastStreamContent = "" -- 2384
		local lastStreamReasoning = "" -- 2385
		local res = __TS__Await(callLLMStreamAggregated( -- 2386
			messages, -- 2387
			llmOptions, -- 2388
			shared.stopToken, -- 2389
			shared.llmConfig, -- 2390
			function(response) -- 2391
				local ____opt_41 = response.choices -- 2391
				local ____opt_39 = ____opt_41 and ____opt_41[1] -- 2391
				local streamMessage = ____opt_39 and ____opt_39.message -- 2392
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2393
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2396
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2396
					return -- 2400
				end -- 2400
				lastStreamContent = nextContent -- 2402
				lastStreamReasoning = nextReasoning -- 2403
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2404
			end -- 2391
		)) -- 2391
		if shared.stopToken.stopped then -- 2391
			return ____awaiter_resolve( -- 2391
				nil, -- 2391
				{ -- 2408
					success = false, -- 2408
					message = getCancelledReason(shared) -- 2408
				} -- 2408
			) -- 2408
		end -- 2408
		if not res.success then -- 2408
			saveStepLLMDebugOutput( -- 2411
				shared, -- 2411
				stepId, -- 2411
				"decision_tool_calling", -- 2411
				res.raw or res.message, -- 2411
				{success = false} -- 2411
			) -- 2411
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2412
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2412
		end -- 2412
		saveStepLLMDebugOutput( -- 2415
			shared, -- 2415
			stepId, -- 2415
			"decision_tool_calling", -- 2415
			encodeDebugJSON(res.response), -- 2415
			{success = true} -- 2415
		) -- 2415
		local choice = res.response.choices and res.response.choices[1] -- 2416
		local message = choice and choice.message -- 2417
		local toolCalls = message and message.tool_calls -- 2418
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2419
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2422
		Log( -- 2425
			"Info", -- 2425
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2425
		) -- 2425
		if not toolCalls or #toolCalls == 0 then -- 2425
			if messageContent and messageContent ~= "" then -- 2425
				Log( -- 2428
					"Info", -- 2428
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2428
				) -- 2428
				return ____awaiter_resolve(nil, { -- 2428
					success = true, -- 2430
					tool = "finish", -- 2431
					params = {}, -- 2432
					reason = messageContent, -- 2433
					reasoningContent = reasoningContent, -- 2434
					directSummary = messageContent -- 2435
				}) -- 2435
			end -- 2435
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2438
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 2438
		end -- 2438
		local decisions = {} -- 2445
		do -- 2445
			local i = 0 -- 2446
			while i < #toolCalls do -- 2446
				local toolCall = toolCalls[i + 1] -- 2447
				local fn = toolCall and toolCall["function"] -- 2448
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2448
					Log( -- 2450
						"Error", -- 2450
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2450
					) -- 2450
					return ____awaiter_resolve( -- 2450
						nil, -- 2450
						{ -- 2451
							success = false, -- 2452
							message = "missing function name for tool call " .. tostring(i + 1), -- 2453
							raw = messageContent -- 2454
						} -- 2454
					) -- 2454
				end -- 2454
				local functionName = fn.name -- 2457
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2458
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2459
				Log( -- 2462
					"Info", -- 2462
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2462
				) -- 2462
				local decision = parseAndValidateToolCallDecision( -- 2463
					shared, -- 2464
					functionName, -- 2465
					argsText, -- 2466
					toolCallId, -- 2467
					messageContent, -- 2468
					reasoningContent -- 2469
				) -- 2469
				if not decision.success then -- 2469
					Log( -- 2472
						"Error", -- 2472
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2472
					) -- 2472
					return ____awaiter_resolve(nil, decision) -- 2472
				end -- 2472
				decisions[#decisions + 1] = decision -- 2475
				i = i + 1 -- 2446
			end -- 2446
		end -- 2446
		if #decisions == 1 then -- 2446
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2478
			return ____awaiter_resolve(nil, decisions[1]) -- 2478
		end -- 2478
		do -- 2478
			local i = 0 -- 2481
			while i < #decisions do -- 2481
				if decisions[i + 1].tool == "finish" then -- 2481
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2481
				end -- 2481
				i = i + 1 -- 2481
			end -- 2481
		end -- 2481
		Log( -- 2490
			"Info", -- 2490
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2490
				__TS__ArrayMap( -- 2490
					decisions, -- 2490
					function(____, decision) return decision.tool end -- 2490
				), -- 2490
				"," -- 2490
			) -- 2490
		) -- 2490
		return ____awaiter_resolve(nil, { -- 2490
			success = true, -- 2492
			kind = "batch", -- 2493
			decisions = decisions, -- 2494
			content = messageContent, -- 2495
			reasoningContent = reasoningContent -- 2496
		}) -- 2496
	end) -- 2496
end -- 2366
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2500
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2500
		Log( -- 2505
			"Info", -- 2505
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2505
		) -- 2505
		local lastError = initialError -- 2506
		local candidateRaw = "" -- 2507
		do -- 2507
			local attempt = 0 -- 2508
			while attempt < shared.llmMaxTry do -- 2508
				do -- 2508
					Log( -- 2509
						"Info", -- 2509
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2509
					) -- 2509
					local messages = buildXmlRepairMessages( -- 2510
						shared, -- 2511
						originalRaw, -- 2512
						candidateRaw, -- 2513
						lastError, -- 2514
						attempt + 1 -- 2515
					) -- 2515
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2517
					if shared.stopToken.stopped then -- 2517
						return ____awaiter_resolve( -- 2517
							nil, -- 2517
							{ -- 2519
								success = false, -- 2519
								message = getCancelledReason(shared) -- 2519
							} -- 2519
						) -- 2519
					end -- 2519
					if not llmRes.success then -- 2519
						lastError = llmRes.message -- 2522
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2523
						goto __continue400 -- 2524
					end -- 2524
					candidateRaw = llmRes.text -- 2526
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2527
					if decision.success then -- 2527
						decision.reasoningContent = llmRes.reasoningContent -- 2529
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2530
						return ____awaiter_resolve(nil, decision) -- 2530
					end -- 2530
					lastError = decision.message -- 2533
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2534
				end -- 2534
				::__continue400:: -- 2534
				attempt = attempt + 1 -- 2508
			end -- 2508
		end -- 2508
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2536
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2536
	end) -- 2536
end -- 2500
function MainDecisionAgent.prototype.exec(self, input) -- 2544
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2544
		local shared = input.shared -- 2545
		if shared.stopToken.stopped then -- 2545
			return ____awaiter_resolve( -- 2545
				nil, -- 2545
				{ -- 2547
					success = false, -- 2547
					message = getCancelledReason(shared) -- 2547
				} -- 2547
			) -- 2547
		end -- 2547
		if shared.step >= shared.maxSteps then -- 2547
			Log( -- 2550
				"Warn", -- 2550
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2550
			) -- 2550
			return ____awaiter_resolve( -- 2550
				nil, -- 2550
				{ -- 2551
					success = false, -- 2551
					message = getMaxStepsReachedReason(shared) -- 2551
				} -- 2551
			) -- 2551
		end -- 2551
		if shared.decisionMode == "tool_calling" then -- 2551
			Log( -- 2555
				"Info", -- 2555
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2555
			) -- 2555
			local lastError = "tool calling validation failed" -- 2556
			local lastRaw = "" -- 2557
			do -- 2557
				local attempt = 0 -- 2558
				while attempt < shared.llmMaxTry do -- 2558
					Log( -- 2559
						"Info", -- 2559
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2559
					) -- 2559
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2560
					if shared.stopToken.stopped then -- 2560
						return ____awaiter_resolve( -- 2560
							nil, -- 2560
							{ -- 2567
								success = false, -- 2567
								message = getCancelledReason(shared) -- 2567
							} -- 2567
						) -- 2567
					end -- 2567
					if decision.success then -- 2567
						return ____awaiter_resolve(nil, decision) -- 2567
					end -- 2567
					lastError = decision.message -- 2572
					lastRaw = decision.raw or "" -- 2573
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2574
					attempt = attempt + 1 -- 2558
				end -- 2558
			end -- 2558
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2576
			return ____awaiter_resolve( -- 2576
				nil, -- 2576
				{ -- 2577
					success = false, -- 2577
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2577
				} -- 2577
			) -- 2577
		end -- 2577
		local lastError = "xml validation failed" -- 2580
		local lastRaw = "" -- 2581
		do -- 2581
			local attempt = 0 -- 2582
			while attempt < shared.llmMaxTry do -- 2582
				do -- 2582
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 2583
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2591
					if shared.stopToken.stopped then -- 2591
						return ____awaiter_resolve( -- 2591
							nil, -- 2591
							{ -- 2593
								success = false, -- 2593
								message = getCancelledReason(shared) -- 2593
							} -- 2593
						) -- 2593
					end -- 2593
					if not llmRes.success then -- 2593
						lastError = llmRes.message -- 2596
						lastRaw = llmRes.text or "" -- 2597
						goto __continue413 -- 2598
					end -- 2598
					lastRaw = llmRes.text -- 2600
					local decision = tryParseAndValidateDecision(llmRes.text) -- 2601
					if decision.success then -- 2601
						decision.reasoningContent = llmRes.reasoningContent -- 2603
						if not isToolAllowedForRole(shared.role, decision.tool) then -- 2603
							lastError = (decision.tool .. " is not allowed for role ") .. shared.role -- 2605
							return ____awaiter_resolve( -- 2605
								nil, -- 2605
								self:repairDecisionXml(shared, llmRes.text, lastError) -- 2606
							) -- 2606
						end -- 2606
						return ____awaiter_resolve(nil, decision) -- 2606
					end -- 2606
					lastError = decision.message -- 2610
					return ____awaiter_resolve( -- 2610
						nil, -- 2610
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 2611
					) -- 2611
				end -- 2611
				::__continue413:: -- 2611
				attempt = attempt + 1 -- 2582
			end -- 2582
		end -- 2582
		return ____awaiter_resolve( -- 2582
			nil, -- 2582
			{ -- 2613
				success = false, -- 2613
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2613
			} -- 2613
		) -- 2613
	end) -- 2613
end -- 2544
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2616
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2616
		local result = execRes -- 2617
		if not result.success then -- 2617
			if shared.stopToken.stopped then -- 2617
				shared.error = getCancelledReason(shared) -- 2620
				shared.done = true -- 2621
				return ____awaiter_resolve(nil, "done") -- 2621
			end -- 2621
			shared.error = result.message -- 2624
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2625
			shared.done = true -- 2626
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2627
			persistHistoryState(shared) -- 2631
			return ____awaiter_resolve(nil, "done") -- 2631
		end -- 2631
		if isDecisionBatchSuccess(result) then -- 2631
			local startStep = shared.step -- 2635
			local actions = {} -- 2636
			do -- 2636
				local i = 0 -- 2637
				while i < #result.decisions do -- 2637
					local decision = result.decisions[i + 1] -- 2638
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2639
					local step = startStep + i + 1 -- 2640
					local ____temp_47 -- 2641
					if i == 0 then -- 2641
						____temp_47 = decision.reason -- 2641
					else -- 2641
						____temp_47 = "" -- 2641
					end -- 2641
					local actionReason = ____temp_47 -- 2641
					local ____temp_48 -- 2642
					if i == 0 then -- 2642
						____temp_48 = decision.reasoningContent -- 2642
					else -- 2642
						____temp_48 = nil -- 2642
					end -- 2642
					local actionReasoningContent = ____temp_48 -- 2642
					emitAgentEvent(shared, { -- 2643
						type = "decision_made", -- 2644
						sessionId = shared.sessionId, -- 2645
						taskId = shared.taskId, -- 2646
						step = step, -- 2647
						tool = decision.tool, -- 2648
						reason = actionReason, -- 2649
						reasoningContent = actionReasoningContent, -- 2650
						params = decision.params -- 2651
					}) -- 2651
					local action = { -- 2653
						step = step, -- 2654
						toolCallId = toolCallId, -- 2655
						tool = decision.tool, -- 2656
						reason = actionReason or "", -- 2657
						reasoningContent = actionReasoningContent, -- 2658
						params = decision.params, -- 2659
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2660
					} -- 2660
					local ____shared_history_49 = shared.history -- 2660
					____shared_history_49[#____shared_history_49 + 1] = action -- 2662
					actions[#actions + 1] = action -- 2663
					i = i + 1 -- 2637
				end -- 2637
			end -- 2637
			shared.step = startStep + #actions -- 2665
			shared.pendingToolActions = actions -- 2666
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2667
			persistHistoryState(shared) -- 2673
			return ____awaiter_resolve(nil, "batch_tools") -- 2673
		end -- 2673
		if result.directSummary and result.directSummary ~= "" then -- 2673
			shared.response = result.directSummary -- 2677
			shared.done = true -- 2678
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2679
			persistHistoryState(shared) -- 2684
			return ____awaiter_resolve(nil, "done") -- 2684
		end -- 2684
		if result.tool == "finish" then -- 2684
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2688
			shared.response = finalMessage -- 2689
			shared.done = true -- 2690
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2691
			persistHistoryState(shared) -- 2696
			return ____awaiter_resolve(nil, "done") -- 2696
		end -- 2696
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2699
		shared.step = shared.step + 1 -- 2700
		local step = shared.step -- 2701
		emitAgentEvent(shared, { -- 2702
			type = "decision_made", -- 2703
			sessionId = shared.sessionId, -- 2704
			taskId = shared.taskId, -- 2705
			step = step, -- 2706
			tool = result.tool, -- 2707
			reason = result.reason, -- 2708
			reasoningContent = result.reasoningContent, -- 2709
			params = result.params -- 2710
		}) -- 2710
		local ____shared_history_50 = shared.history -- 2710
		____shared_history_50[#____shared_history_50 + 1] = { -- 2712
			step = step, -- 2713
			toolCallId = toolCallId, -- 2714
			tool = result.tool, -- 2715
			reason = result.reason or "", -- 2716
			reasoningContent = result.reasoningContent, -- 2717
			params = result.params, -- 2718
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2719
		} -- 2719
		local action = shared.history[#shared.history] -- 2721
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 2722
		persistHistoryState(shared) -- 2723
		return ____awaiter_resolve(nil, result.tool) -- 2723
	end) -- 2723
end -- 2616
local ReadFileAction = __TS__Class() -- 2728
ReadFileAction.name = "ReadFileAction" -- 2728
__TS__ClassExtends(ReadFileAction, Node) -- 2728
function ReadFileAction.prototype.prep(self, shared) -- 2729
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2729
		local last = shared.history[#shared.history] -- 2730
		if not last then -- 2730
			error( -- 2731
				__TS__New(Error, "no history"), -- 2731
				0 -- 2731
			) -- 2731
		end -- 2731
		emitAgentStartEvent(shared, last) -- 2732
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2733
		if __TS__StringTrim(path) == "" then -- 2733
			error( -- 2736
				__TS__New(Error, "missing path"), -- 2736
				0 -- 2736
			) -- 2736
		end -- 2736
		local ____path_53 = path -- 2738
		local ____shared_workingDir_54 = shared.workingDir -- 2740
		local ____temp_55 = shared.useChineseResponse and "zh" or "en" -- 2741
		local ____last_params_startLine_51 = last.params.startLine -- 2742
		if ____last_params_startLine_51 == nil then -- 2742
			____last_params_startLine_51 = 1 -- 2742
		end -- 2742
		local ____TS__Number_result_56 = __TS__Number(____last_params_startLine_51) -- 2742
		local ____last_params_endLine_52 = last.params.endLine -- 2743
		if ____last_params_endLine_52 == nil then -- 2743
			____last_params_endLine_52 = READ_FILE_DEFAULT_LIMIT -- 2743
		end -- 2743
		return ____awaiter_resolve( -- 2743
			nil, -- 2743
			{ -- 2737
				path = ____path_53, -- 2738
				tool = "read_file", -- 2739
				workDir = ____shared_workingDir_54, -- 2740
				docLanguage = ____temp_55, -- 2741
				startLine = ____TS__Number_result_56, -- 2742
				endLine = __TS__Number(____last_params_endLine_52) -- 2743
			} -- 2743
		) -- 2743
	end) -- 2743
end -- 2729
function ReadFileAction.prototype.exec(self, input) -- 2747
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2747
		return ____awaiter_resolve( -- 2747
			nil, -- 2747
			Tools.readFile( -- 2748
				input.workDir, -- 2749
				input.path, -- 2750
				__TS__Number(input.startLine or 1), -- 2751
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2752
				input.docLanguage -- 2753
			) -- 2753
		) -- 2753
	end) -- 2753
end -- 2747
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2757
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2757
		local result = execRes -- 2758
		local last = shared.history[#shared.history] -- 2759
		if last ~= nil then -- 2759
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2761
			appendToolResultMessage(shared, last) -- 2762
			emitAgentFinishEvent(shared, last) -- 2763
		end -- 2763
		persistHistoryState(shared) -- 2765
		__TS__Await(maybeCompressHistory(shared)) -- 2766
		persistHistoryState(shared) -- 2767
		return ____awaiter_resolve(nil, "main") -- 2767
	end) -- 2767
end -- 2757
local SearchFilesAction = __TS__Class() -- 2772
SearchFilesAction.name = "SearchFilesAction" -- 2772
__TS__ClassExtends(SearchFilesAction, Node) -- 2772
function SearchFilesAction.prototype.prep(self, shared) -- 2773
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2773
		local last = shared.history[#shared.history] -- 2774
		if not last then -- 2774
			error( -- 2775
				__TS__New(Error, "no history"), -- 2775
				0 -- 2775
			) -- 2775
		end -- 2775
		emitAgentStartEvent(shared, last) -- 2776
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2776
	end) -- 2776
end -- 2773
function SearchFilesAction.prototype.exec(self, input) -- 2780
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2780
		local params = input.params -- 2781
		local ____Tools_searchFiles_70 = Tools.searchFiles -- 2782
		local ____input_workDir_63 = input.workDir -- 2783
		local ____temp_64 = params.path or "" -- 2784
		local ____temp_65 = params.pattern or "" -- 2785
		local ____params_globs_66 = params.globs -- 2786
		local ____params_useRegex_67 = params.useRegex -- 2787
		local ____params_caseSensitive_68 = params.caseSensitive -- 2788
		local ____math_max_59 = math.max -- 2791
		local ____math_floor_58 = math.floor -- 2791
		local ____params_limit_57 = params.limit -- 2791
		if ____params_limit_57 == nil then -- 2791
			____params_limit_57 = SEARCH_FILES_LIMIT_DEFAULT -- 2791
		end -- 2791
		local ____math_max_59_result_69 = ____math_max_59( -- 2791
			1, -- 2791
			____math_floor_58(__TS__Number(____params_limit_57)) -- 2791
		) -- 2791
		local ____math_max_62 = math.max -- 2792
		local ____math_floor_61 = math.floor -- 2792
		local ____params_offset_60 = params.offset -- 2792
		if ____params_offset_60 == nil then -- 2792
			____params_offset_60 = 0 -- 2792
		end -- 2792
		local result = __TS__Await(____Tools_searchFiles_70({ -- 2782
			workDir = ____input_workDir_63, -- 2783
			path = ____temp_64, -- 2784
			pattern = ____temp_65, -- 2785
			globs = ____params_globs_66, -- 2786
			useRegex = ____params_useRegex_67, -- 2787
			caseSensitive = ____params_caseSensitive_68, -- 2788
			includeContent = true, -- 2789
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2790
			limit = ____math_max_59_result_69, -- 2791
			offset = ____math_max_62( -- 2792
				0, -- 2792
				____math_floor_61(__TS__Number(____params_offset_60)) -- 2792
			), -- 2792
			groupByFile = params.groupByFile == true -- 2793
		})) -- 2793
		return ____awaiter_resolve(nil, result) -- 2793
	end) -- 2793
end -- 2780
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2798
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2798
		local last = shared.history[#shared.history] -- 2799
		if last ~= nil then -- 2799
			local result = execRes -- 2801
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2802
			appendToolResultMessage(shared, last) -- 2803
			emitAgentFinishEvent(shared, last) -- 2804
		end -- 2804
		persistHistoryState(shared) -- 2806
		__TS__Await(maybeCompressHistory(shared)) -- 2807
		persistHistoryState(shared) -- 2808
		return ____awaiter_resolve(nil, "main") -- 2808
	end) -- 2808
end -- 2798
local SearchDoraAPIAction = __TS__Class() -- 2813
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2813
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2813
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2814
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2814
		local last = shared.history[#shared.history] -- 2815
		if not last then -- 2815
			error( -- 2816
				__TS__New(Error, "no history"), -- 2816
				0 -- 2816
			) -- 2816
		end -- 2816
		emitAgentStartEvent(shared, last) -- 2817
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2817
	end) -- 2817
end -- 2814
function SearchDoraAPIAction.prototype.exec(self, input) -- 2821
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2821
		local params = input.params -- 2822
		local ____Tools_searchDoraAPI_78 = Tools.searchDoraAPI -- 2823
		local ____temp_74 = params.pattern or "" -- 2824
		local ____temp_75 = params.docSource or "api" -- 2825
		local ____temp_76 = input.useChineseResponse and "zh" or "en" -- 2826
		local ____temp_77 = params.programmingLanguage or "ts" -- 2827
		local ____math_min_73 = math.min -- 2828
		local ____math_max_72 = math.max -- 2828
		local ____params_limit_71 = params.limit -- 2828
		if ____params_limit_71 == nil then -- 2828
			____params_limit_71 = 8 -- 2828
		end -- 2828
		local result = __TS__Await(____Tools_searchDoraAPI_78({ -- 2823
			pattern = ____temp_74, -- 2824
			docSource = ____temp_75, -- 2825
			docLanguage = ____temp_76, -- 2826
			programmingLanguage = ____temp_77, -- 2827
			limit = ____math_min_73( -- 2828
				SEARCH_DORA_API_LIMIT_MAX, -- 2828
				____math_max_72( -- 2828
					1, -- 2828
					__TS__Number(____params_limit_71) -- 2828
				) -- 2828
			), -- 2828
			useRegex = params.useRegex, -- 2829
			caseSensitive = false, -- 2830
			includeContent = true, -- 2831
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2832
		})) -- 2832
		return ____awaiter_resolve(nil, result) -- 2832
	end) -- 2832
end -- 2821
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2837
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2837
		local last = shared.history[#shared.history] -- 2838
		if last ~= nil then -- 2838
			local result = execRes -- 2840
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2841
			appendToolResultMessage(shared, last) -- 2842
			emitAgentFinishEvent(shared, last) -- 2843
		end -- 2843
		persistHistoryState(shared) -- 2845
		__TS__Await(maybeCompressHistory(shared)) -- 2846
		persistHistoryState(shared) -- 2847
		return ____awaiter_resolve(nil, "main") -- 2847
	end) -- 2847
end -- 2837
local ListFilesAction = __TS__Class() -- 2852
ListFilesAction.name = "ListFilesAction" -- 2852
__TS__ClassExtends(ListFilesAction, Node) -- 2852
function ListFilesAction.prototype.prep(self, shared) -- 2853
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2853
		local last = shared.history[#shared.history] -- 2854
		if not last then -- 2854
			error( -- 2855
				__TS__New(Error, "no history"), -- 2855
				0 -- 2855
			) -- 2855
		end -- 2855
		emitAgentStartEvent(shared, last) -- 2856
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2856
	end) -- 2856
end -- 2853
function ListFilesAction.prototype.exec(self, input) -- 2860
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2860
		local params = input.params -- 2861
		local ____Tools_listFiles_85 = Tools.listFiles -- 2862
		local ____input_workDir_82 = input.workDir -- 2863
		local ____temp_83 = params.path or "" -- 2864
		local ____params_globs_84 = params.globs -- 2865
		local ____math_max_81 = math.max -- 2866
		local ____math_floor_80 = math.floor -- 2866
		local ____params_maxEntries_79 = params.maxEntries -- 2866
		if ____params_maxEntries_79 == nil then -- 2866
			____params_maxEntries_79 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2866
		end -- 2866
		local result = ____Tools_listFiles_85({ -- 2862
			workDir = ____input_workDir_82, -- 2863
			path = ____temp_83, -- 2864
			globs = ____params_globs_84, -- 2865
			maxEntries = ____math_max_81( -- 2866
				1, -- 2866
				____math_floor_80(__TS__Number(____params_maxEntries_79)) -- 2866
			) -- 2866
		}) -- 2866
		return ____awaiter_resolve(nil, result) -- 2866
	end) -- 2866
end -- 2860
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2871
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2871
		local last = shared.history[#shared.history] -- 2872
		if last ~= nil then -- 2872
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2874
			appendToolResultMessage(shared, last) -- 2875
			emitAgentFinishEvent(shared, last) -- 2876
		end -- 2876
		persistHistoryState(shared) -- 2878
		__TS__Await(maybeCompressHistory(shared)) -- 2879
		persistHistoryState(shared) -- 2880
		return ____awaiter_resolve(nil, "main") -- 2880
	end) -- 2880
end -- 2871
local DeleteFileAction = __TS__Class() -- 2885
DeleteFileAction.name = "DeleteFileAction" -- 2885
__TS__ClassExtends(DeleteFileAction, Node) -- 2885
function DeleteFileAction.prototype.prep(self, shared) -- 2886
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2886
		local last = shared.history[#shared.history] -- 2887
		if not last then -- 2887
			error( -- 2888
				__TS__New(Error, "no history"), -- 2888
				0 -- 2888
			) -- 2888
		end -- 2888
		emitAgentStartEvent(shared, last) -- 2889
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 2890
		if __TS__StringTrim(targetFile) == "" then -- 2890
			error( -- 2893
				__TS__New(Error, "missing target_file"), -- 2893
				0 -- 2893
			) -- 2893
		end -- 2893
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 2893
	end) -- 2893
end -- 2886
function DeleteFileAction.prototype.exec(self, input) -- 2897
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2897
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 2898
		if not result.success then -- 2898
			return ____awaiter_resolve(nil, result) -- 2898
		end -- 2898
		return ____awaiter_resolve(nil, { -- 2898
			success = true, -- 2906
			changed = true, -- 2907
			mode = "delete", -- 2908
			checkpointId = result.checkpointId, -- 2909
			checkpointSeq = result.checkpointSeq, -- 2910
			files = {{path = input.targetFile, op = "delete"}} -- 2911
		}) -- 2911
	end) -- 2911
end -- 2897
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2915
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2915
		local last = shared.history[#shared.history] -- 2916
		if last ~= nil then -- 2916
			last.result = execRes -- 2918
			appendToolResultMessage(shared, last) -- 2919
			emitAgentFinishEvent(shared, last) -- 2920
			local result = last.result -- 2921
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2921
				emitAgentEvent(shared, { -- 2926
					type = "checkpoint_created", -- 2927
					sessionId = shared.sessionId, -- 2928
					taskId = shared.taskId, -- 2929
					step = last.step, -- 2930
					tool = "delete_file", -- 2931
					checkpointId = result.checkpointId, -- 2932
					checkpointSeq = result.checkpointSeq, -- 2933
					files = result.files -- 2934
				}) -- 2934
			end -- 2934
		end -- 2934
		persistHistoryState(shared) -- 2938
		__TS__Await(maybeCompressHistory(shared)) -- 2939
		persistHistoryState(shared) -- 2940
		return ____awaiter_resolve(nil, "main") -- 2940
	end) -- 2940
end -- 2915
local BuildAction = __TS__Class() -- 2945
BuildAction.name = "BuildAction" -- 2945
__TS__ClassExtends(BuildAction, Node) -- 2945
function BuildAction.prototype.prep(self, shared) -- 2946
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2946
		local last = shared.history[#shared.history] -- 2947
		if not last then -- 2947
			error( -- 2948
				__TS__New(Error, "no history"), -- 2948
				0 -- 2948
			) -- 2948
		end -- 2948
		emitAgentStartEvent(shared, last) -- 2949
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2949
	end) -- 2949
end -- 2946
function BuildAction.prototype.exec(self, input) -- 2953
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2953
		local params = input.params -- 2954
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 2955
		return ____awaiter_resolve(nil, result) -- 2955
	end) -- 2955
end -- 2953
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 2962
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2962
		local last = shared.history[#shared.history] -- 2963
		if last ~= nil then -- 2963
			last.result = execRes -- 2965
			appendToolResultMessage(shared, last) -- 2966
			emitAgentFinishEvent(shared, last) -- 2967
		end -- 2967
		persistHistoryState(shared) -- 2969
		__TS__Await(maybeCompressHistory(shared)) -- 2970
		persistHistoryState(shared) -- 2971
		return ____awaiter_resolve(nil, "main") -- 2971
	end) -- 2971
end -- 2962
local SpawnSubAgentAction = __TS__Class() -- 2976
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 2976
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 2976
function SpawnSubAgentAction.prototype.prep(self, shared) -- 2977
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2977
		local last = shared.history[#shared.history] -- 2986
		if not last then -- 2986
			error( -- 2987
				__TS__New(Error, "no history"), -- 2987
				0 -- 2987
			) -- 2987
		end -- 2987
		emitAgentStartEvent(shared, last) -- 2988
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 2989
			last.params.filesHint, -- 2990
			function(____, item) return type(item) == "string" end -- 2990
		) or nil -- 2990
		return ____awaiter_resolve( -- 2990
			nil, -- 2990
			{ -- 2992
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 2993
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 2994
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 2995
				filesHint = filesHint, -- 2996
				sessionId = shared.sessionId, -- 2997
				projectRoot = shared.workingDir, -- 2998
				spawnSubAgent = shared.spawnSubAgent -- 2999
			} -- 2999
		) -- 2999
	end) -- 2999
end -- 2977
function SpawnSubAgentAction.prototype.exec(self, input) -- 3003
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3003
		if not input.spawnSubAgent then -- 3003
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3003
		end -- 3003
		if input.sessionId == nil or input.sessionId <= 0 then -- 3003
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3003
		end -- 3003
		local ____Log_91 = Log -- 3018
		local ____temp_88 = #input.title -- 3018
		local ____temp_89 = #input.prompt -- 3018
		local ____temp_90 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3018
		local ____opt_86 = input.filesHint -- 3018
		____Log_91( -- 3018
			"Info", -- 3018
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_88)) .. " prompt_len=") .. tostring(____temp_89)) .. " expected_len=") .. tostring(____temp_90)) .. " files_hint_count=") .. tostring(____opt_86 and #____opt_86 or 0) -- 3018
		) -- 3018
		local result = __TS__Await(input.spawnSubAgent({ -- 3019
			parentSessionId = input.sessionId, -- 3020
			projectRoot = input.projectRoot, -- 3021
			title = input.title, -- 3022
			prompt = input.prompt, -- 3023
			expectedOutput = input.expectedOutput, -- 3024
			filesHint = input.filesHint -- 3025
		})) -- 3025
		if not result.success then -- 3025
			return ____awaiter_resolve(nil, result) -- 3025
		end -- 3025
		return ____awaiter_resolve(nil, { -- 3025
			success = true, -- 3031
			sessionId = result.sessionId, -- 3032
			taskId = result.taskId, -- 3033
			title = result.title, -- 3034
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3035
		}) -- 3035
	end) -- 3035
end -- 3003
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3039
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3039
		local last = shared.history[#shared.history] -- 3040
		if last ~= nil then -- 3040
			last.result = execRes -- 3042
			appendToolResultMessage(shared, last) -- 3043
			emitAgentFinishEvent(shared, last) -- 3044
		end -- 3044
		persistHistoryState(shared) -- 3046
		__TS__Await(maybeCompressHistory(shared)) -- 3047
		persistHistoryState(shared) -- 3048
		return ____awaiter_resolve(nil, "main") -- 3048
	end) -- 3048
end -- 3039
local ListSubAgentsAction = __TS__Class() -- 3053
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3053
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3053
function ListSubAgentsAction.prototype.prep(self, shared) -- 3054
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3054
		local last = shared.history[#shared.history] -- 3063
		if not last then -- 3063
			error( -- 3064
				__TS__New(Error, "no history"), -- 3064
				0 -- 3064
			) -- 3064
		end -- 3064
		emitAgentStartEvent(shared, last) -- 3065
		return ____awaiter_resolve( -- 3065
			nil, -- 3065
			{ -- 3066
				sessionId = shared.sessionId, -- 3067
				projectRoot = shared.workingDir, -- 3068
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3069
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3070
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3071
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3072
				listSubAgents = shared.listSubAgents -- 3073
			} -- 3073
		) -- 3073
	end) -- 3073
end -- 3054
function ListSubAgentsAction.prototype.exec(self, input) -- 3077
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3077
		if not input.listSubAgents then -- 3077
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3077
		end -- 3077
		if input.sessionId == nil or input.sessionId <= 0 then -- 3077
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3077
		end -- 3077
		local result = __TS__Await(input.listSubAgents({ -- 3092
			sessionId = input.sessionId, -- 3093
			projectRoot = input.projectRoot, -- 3094
			status = input.status, -- 3095
			limit = input.limit, -- 3096
			offset = input.offset, -- 3097
			query = input.query -- 3098
		})) -- 3098
		return ____awaiter_resolve(nil, result) -- 3098
	end) -- 3098
end -- 3077
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3103
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3103
		local last = shared.history[#shared.history] -- 3104
		if last ~= nil then -- 3104
			last.result = execRes -- 3106
			appendToolResultMessage(shared, last) -- 3107
			emitAgentFinishEvent(shared, last) -- 3108
		end -- 3108
		persistHistoryState(shared) -- 3110
		__TS__Await(maybeCompressHistory(shared)) -- 3111
		persistHistoryState(shared) -- 3112
		return ____awaiter_resolve(nil, "main") -- 3112
	end) -- 3112
end -- 3103
local EditFileAction = __TS__Class() -- 3117
EditFileAction.name = "EditFileAction" -- 3117
__TS__ClassExtends(EditFileAction, Node) -- 3117
function EditFileAction.prototype.prep(self, shared) -- 3118
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3118
		local last = shared.history[#shared.history] -- 3119
		if not last then -- 3119
			error( -- 3120
				__TS__New(Error, "no history"), -- 3120
				0 -- 3120
			) -- 3120
		end -- 3120
		emitAgentStartEvent(shared, last) -- 3121
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3122
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3125
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3126
		if __TS__StringTrim(path) == "" then -- 3126
			error( -- 3127
				__TS__New(Error, "missing path"), -- 3127
				0 -- 3127
			) -- 3127
		end -- 3127
		return ____awaiter_resolve(nil, { -- 3127
			path = path, -- 3128
			oldStr = oldStr, -- 3128
			newStr = newStr, -- 3128
			taskId = shared.taskId, -- 3128
			workDir = shared.workingDir -- 3128
		}) -- 3128
	end) -- 3128
end -- 3118
function EditFileAction.prototype.exec(self, input) -- 3131
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3131
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3132
		if not readRes.success then -- 3132
			if input.oldStr ~= "" then -- 3132
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3132
			end -- 3132
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3137
			if not createRes.success then -- 3137
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3137
			end -- 3137
			return ____awaiter_resolve(nil, { -- 3137
				success = true, -- 3145
				changed = true, -- 3146
				mode = "create", -- 3147
				checkpointId = createRes.checkpointId, -- 3148
				checkpointSeq = createRes.checkpointSeq, -- 3149
				files = {{path = input.path, op = "create"}} -- 3150
			}) -- 3150
		end -- 3150
		if input.oldStr == "" then -- 3150
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3154
			if not overwriteRes.success then -- 3154
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3154
			end -- 3154
			return ____awaiter_resolve(nil, { -- 3154
				success = true, -- 3162
				changed = true, -- 3163
				mode = "overwrite", -- 3164
				checkpointId = overwriteRes.checkpointId, -- 3165
				checkpointSeq = overwriteRes.checkpointSeq, -- 3166
				files = {{path = input.path, op = "write"}} -- 3167
			}) -- 3167
		end -- 3167
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3172
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3173
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3174
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3177
		if occurrences == 0 then -- 3177
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3179
			if not indentTolerant.success then -- 3179
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3179
			end -- 3179
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3183
			if not applyRes.success then -- 3183
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3183
			end -- 3183
			return ____awaiter_resolve(nil, { -- 3183
				success = true, -- 3191
				changed = true, -- 3192
				mode = "replace_indent_tolerant", -- 3193
				checkpointId = applyRes.checkpointId, -- 3194
				checkpointSeq = applyRes.checkpointSeq, -- 3195
				files = {{path = input.path, op = "write"}} -- 3196
			}) -- 3196
		end -- 3196
		if occurrences > 1 then -- 3196
			return ____awaiter_resolve( -- 3196
				nil, -- 3196
				{ -- 3200
					success = false, -- 3200
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3200
				} -- 3200
			) -- 3200
		end -- 3200
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3204
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3205
		if not applyRes.success then -- 3205
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3205
		end -- 3205
		return ____awaiter_resolve(nil, { -- 3205
			success = true, -- 3213
			changed = true, -- 3214
			mode = "replace", -- 3215
			checkpointId = applyRes.checkpointId, -- 3216
			checkpointSeq = applyRes.checkpointSeq, -- 3217
			files = {{path = input.path, op = "write"}} -- 3218
		}) -- 3218
	end) -- 3218
end -- 3131
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3222
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3222
		local last = shared.history[#shared.history] -- 3223
		if last ~= nil then -- 3223
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3225
			last.result = execRes -- 3226
			appendToolResultMessage(shared, last) -- 3227
			emitAgentFinishEvent(shared, last) -- 3228
			local result = last.result -- 3229
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3229
				emitAgentEvent(shared, { -- 3234
					type = "checkpoint_created", -- 3235
					sessionId = shared.sessionId, -- 3236
					taskId = shared.taskId, -- 3237
					step = last.step, -- 3238
					tool = last.tool, -- 3239
					checkpointId = result.checkpointId, -- 3240
					checkpointSeq = result.checkpointSeq, -- 3241
					files = result.files -- 3242
				}) -- 3242
			end -- 3242
		end -- 3242
		persistHistoryState(shared) -- 3246
		__TS__Await(maybeCompressHistory(shared)) -- 3247
		persistHistoryState(shared) -- 3248
		return ____awaiter_resolve(nil, "main") -- 3248
	end) -- 3248
end -- 3222
local function emitCheckpointEventForAction(shared, action) -- 3253
	local result = action.result -- 3254
	if not result then -- 3254
		return -- 3255
	end -- 3255
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3255
		emitAgentEvent(shared, { -- 3260
			type = "checkpoint_created", -- 3261
			sessionId = shared.sessionId, -- 3262
			taskId = shared.taskId, -- 3263
			step = action.step, -- 3264
			tool = action.tool, -- 3265
			checkpointId = result.checkpointId, -- 3266
			checkpointSeq = result.checkpointSeq, -- 3267
			files = result.files -- 3268
		}) -- 3268
	end -- 3268
end -- 3253
local function executeToolAction(shared, action) -- 3273
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3273
		if shared.stopToken.stopped then -- 3273
			return ____awaiter_resolve( -- 3273
				nil, -- 3273
				{ -- 3275
					success = false, -- 3275
					message = getCancelledReason(shared) -- 3275
				} -- 3275
			) -- 3275
		end -- 3275
		local params = action.params -- 3277
		if action.tool == "read_file" then -- 3277
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3279
			if __TS__StringTrim(path) == "" then -- 3279
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3279
			end -- 3279
			local ____Tools_readFile_96 = Tools.readFile -- 3283
			local ____shared_workingDir_94 = shared.workingDir -- 3284
			local ____params_startLine_92 = params.startLine -- 3286
			if ____params_startLine_92 == nil then -- 3286
				____params_startLine_92 = 1 -- 3286
			end -- 3286
			local ____TS__Number_result_95 = __TS__Number(____params_startLine_92) -- 3286
			local ____params_endLine_93 = params.endLine -- 3287
			if ____params_endLine_93 == nil then -- 3287
				____params_endLine_93 = READ_FILE_DEFAULT_LIMIT -- 3287
			end -- 3287
			return ____awaiter_resolve( -- 3287
				nil, -- 3287
				____Tools_readFile_96( -- 3283
					____shared_workingDir_94, -- 3284
					path, -- 3285
					____TS__Number_result_95, -- 3286
					__TS__Number(____params_endLine_93), -- 3287
					shared.useChineseResponse and "zh" or "en" -- 3288
				) -- 3288
			) -- 3288
		end -- 3288
		if action.tool == "grep_files" then -- 3288
			local ____Tools_searchFiles_110 = Tools.searchFiles -- 3292
			local ____shared_workingDir_103 = shared.workingDir -- 3293
			local ____temp_104 = params.path or "" -- 3294
			local ____temp_105 = params.pattern or "" -- 3295
			local ____params_globs_106 = params.globs -- 3296
			local ____params_useRegex_107 = params.useRegex -- 3297
			local ____params_caseSensitive_108 = params.caseSensitive -- 3298
			local ____math_max_99 = math.max -- 3301
			local ____math_floor_98 = math.floor -- 3301
			local ____params_limit_97 = params.limit -- 3301
			if ____params_limit_97 == nil then -- 3301
				____params_limit_97 = SEARCH_FILES_LIMIT_DEFAULT -- 3301
			end -- 3301
			local ____math_max_99_result_109 = ____math_max_99( -- 3301
				1, -- 3301
				____math_floor_98(__TS__Number(____params_limit_97)) -- 3301
			) -- 3301
			local ____math_max_102 = math.max -- 3302
			local ____math_floor_101 = math.floor -- 3302
			local ____params_offset_100 = params.offset -- 3302
			if ____params_offset_100 == nil then -- 3302
				____params_offset_100 = 0 -- 3302
			end -- 3302
			local result = __TS__Await(____Tools_searchFiles_110({ -- 3292
				workDir = ____shared_workingDir_103, -- 3293
				path = ____temp_104, -- 3294
				pattern = ____temp_105, -- 3295
				globs = ____params_globs_106, -- 3296
				useRegex = ____params_useRegex_107, -- 3297
				caseSensitive = ____params_caseSensitive_108, -- 3298
				includeContent = true, -- 3299
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3300
				limit = ____math_max_99_result_109, -- 3301
				offset = ____math_max_102( -- 3302
					0, -- 3302
					____math_floor_101(__TS__Number(____params_offset_100)) -- 3302
				), -- 3302
				groupByFile = params.groupByFile == true -- 3303
			})) -- 3303
			return ____awaiter_resolve(nil, result) -- 3303
		end -- 3303
		if action.tool == "search_dora_api" then -- 3303
			local ____Tools_searchDoraAPI_118 = Tools.searchDoraAPI -- 3308
			local ____temp_114 = params.pattern or "" -- 3309
			local ____temp_115 = params.docSource or "api" -- 3310
			local ____temp_116 = shared.useChineseResponse and "zh" or "en" -- 3311
			local ____temp_117 = params.programmingLanguage or "ts" -- 3312
			local ____math_min_113 = math.min -- 3313
			local ____math_max_112 = math.max -- 3313
			local ____params_limit_111 = params.limit -- 3313
			if ____params_limit_111 == nil then -- 3313
				____params_limit_111 = 8 -- 3313
			end -- 3313
			local result = __TS__Await(____Tools_searchDoraAPI_118({ -- 3308
				pattern = ____temp_114, -- 3309
				docSource = ____temp_115, -- 3310
				docLanguage = ____temp_116, -- 3311
				programmingLanguage = ____temp_117, -- 3312
				limit = ____math_min_113( -- 3313
					SEARCH_DORA_API_LIMIT_MAX, -- 3313
					____math_max_112( -- 3313
						1, -- 3313
						__TS__Number(____params_limit_111) -- 3313
					) -- 3313
				), -- 3313
				useRegex = params.useRegex, -- 3314
				caseSensitive = false, -- 3315
				includeContent = true, -- 3316
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3317
			})) -- 3317
			return ____awaiter_resolve(nil, result) -- 3317
		end -- 3317
		if action.tool == "glob_files" then -- 3317
			local ____Tools_listFiles_125 = Tools.listFiles -- 3322
			local ____shared_workingDir_122 = shared.workingDir -- 3323
			local ____temp_123 = params.path or "" -- 3324
			local ____params_globs_124 = params.globs -- 3325
			local ____math_max_121 = math.max -- 3326
			local ____math_floor_120 = math.floor -- 3326
			local ____params_maxEntries_119 = params.maxEntries -- 3326
			if ____params_maxEntries_119 == nil then -- 3326
				____params_maxEntries_119 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3326
			end -- 3326
			local result = ____Tools_listFiles_125({ -- 3322
				workDir = ____shared_workingDir_122, -- 3323
				path = ____temp_123, -- 3324
				globs = ____params_globs_124, -- 3325
				maxEntries = ____math_max_121( -- 3326
					1, -- 3326
					____math_floor_120(__TS__Number(____params_maxEntries_119)) -- 3326
				) -- 3326
			}) -- 3326
			return ____awaiter_resolve(nil, result) -- 3326
		end -- 3326
		if action.tool == "delete_file" then -- 3326
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3331
			if __TS__StringTrim(targetFile) == "" then -- 3331
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3331
			end -- 3331
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3335
			if not result.success then -- 3335
				return ____awaiter_resolve(nil, result) -- 3335
			end -- 3335
			return ____awaiter_resolve(nil, { -- 3335
				success = true, -- 3343
				changed = true, -- 3344
				mode = "delete", -- 3345
				checkpointId = result.checkpointId, -- 3346
				checkpointSeq = result.checkpointSeq, -- 3347
				files = {{path = targetFile, op = "delete"}} -- 3348
			}) -- 3348
		end -- 3348
		if action.tool == "build" then -- 3348
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3352
			return ____awaiter_resolve(nil, result) -- 3352
		end -- 3352
		if action.tool == "spawn_sub_agent" then -- 3352
			if not shared.spawnSubAgent then -- 3352
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3352
			end -- 3352
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3352
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3352
			end -- 3352
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3365
				params.filesHint, -- 3366
				function(____, item) return type(item) == "string" end -- 3366
			) or nil -- 3366
			local result = __TS__Await(shared.spawnSubAgent({ -- 3368
				parentSessionId = shared.sessionId, -- 3369
				projectRoot = shared.workingDir, -- 3370
				title = type(params.title) == "string" and params.title or "Sub", -- 3371
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3372
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3373
				filesHint = filesHint -- 3374
			})) -- 3374
			if not result.success then -- 3374
				return ____awaiter_resolve(nil, result) -- 3374
			end -- 3374
			return ____awaiter_resolve(nil, { -- 3374
				success = true, -- 3380
				sessionId = result.sessionId, -- 3381
				taskId = result.taskId, -- 3382
				title = result.title, -- 3383
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3384
			}) -- 3384
		end -- 3384
		if action.tool == "list_sub_agents" then -- 3384
			if not shared.listSubAgents then -- 3384
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3384
			end -- 3384
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3384
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3384
			end -- 3384
			local result = __TS__Await(shared.listSubAgents({ -- 3394
				sessionId = shared.sessionId, -- 3395
				projectRoot = shared.workingDir, -- 3396
				status = type(params.status) == "string" and params.status or nil, -- 3397
				limit = type(params.limit) == "number" and params.limit or nil, -- 3398
				offset = type(params.offset) == "number" and params.offset or nil, -- 3399
				query = type(params.query) == "string" and params.query or nil -- 3400
			})) -- 3400
			return ____awaiter_resolve(nil, result) -- 3400
		end -- 3400
		if action.tool == "edit_file" then -- 3400
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3405
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3408
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3409
			if __TS__StringTrim(path) == "" then -- 3409
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3409
			end -- 3409
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3411
			return ____awaiter_resolve( -- 3411
				nil, -- 3411
				actionNode:exec({ -- 3412
					path = path, -- 3413
					oldStr = oldStr, -- 3414
					newStr = newStr, -- 3415
					taskId = shared.taskId, -- 3416
					workDir = shared.workingDir -- 3417
				}) -- 3417
			) -- 3417
		end -- 3417
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3417
	end) -- 3417
end -- 3273
local function sanitizeToolActionResultForHistory(action, result) -- 3423
	if action.tool == "read_file" then -- 3423
		return sanitizeReadResultForHistory(action.tool, result) -- 3425
	end -- 3425
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3425
		return sanitizeSearchResultForHistory(action.tool, result) -- 3428
	end -- 3428
	if action.tool == "glob_files" then -- 3428
		return sanitizeListFilesResultForHistory(result) -- 3431
	end -- 3431
	return result -- 3433
end -- 3423
local function canRunBatchActionInParallel(action) -- 3435
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 3435
end -- 3435
local BatchToolAction = __TS__Class() -- 3436
BatchToolAction.name = "BatchToolAction" -- 3436
__TS__ClassExtends(BatchToolAction, Node) -- 3436
function BatchToolAction.prototype.prep(self, shared) -- 3437
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3437
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3437
	end) -- 3437
end -- 3437
function BatchToolAction.prototype.exec(self, input) -- 3441
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3441
		local shared = input.shared -- 3442
		local allParallelSafe = #input.actions > 1 -- 3442
		do -- 3442
			local i = 0 -- 3442
			while i < #input.actions do -- 3442
				if not canRunBatchActionInParallel(input.actions[i + 1]) then -- 3442
					allParallelSafe = false -- 3442
					break -- 3442
				end -- 3442
				i = i + 1 -- 3442
			end -- 3442
		end -- 3442
		if not allParallelSafe then -- 3442
			do -- 3442
				local i = 0 -- 3443
				while i < #input.actions do -- 3443
					local action = input.actions[i + 1] -- 3444
					emitAgentStartEvent(shared, action) -- 3445
					local result = __TS__Await(executeToolAction(shared, action)) -- 3446
					action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3447
					action.result = sanitizeToolActionResultForHistory(action, result) -- 3448
					appendToolResultMessage(shared, action) -- 3449
					emitAgentFinishEvent(shared, action) -- 3450
					emitCheckpointEventForAction(shared, action) -- 3451
					persistHistoryState(shared) -- 3452
					if shared.stopToken.stopped then -- 3452
						break -- 3454
					end -- 3454
					i = i + 1 -- 3443
				end -- 3443
			end -- 3443
			return ____awaiter_resolve(nil, input.actions) -- 3443
		end -- 3442
		Log("Info", "[CodingAgent] batch read-only tools executing in parallel count=" .. tostring(#input.actions)) -- 3442
		do -- 3442
			local i = 0 -- 3443
			while i < #input.actions do -- 3443
				emitAgentStartEvent(shared, input.actions[i + 1]) -- 3445
				i = i + 1 -- 3443
			end -- 3443
		end -- 3443
		local results = __TS__Await(__TS__PromiseAll(__TS__ArrayMap(input.actions, function(____, action) -- 3446
			return executeToolAction(shared, action) -- 3446
		end))) -- 3446
		do -- 3446
			local i = 0 -- 3447
			while i < #input.actions do -- 3447
				local action = input.actions[i + 1] -- 3448
				local result = results[i + 1] -- 3449
				action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3450
				action.result = sanitizeToolActionResultForHistory(action, result) -- 3451
				appendToolResultMessage(shared, action) -- 3452
				emitAgentFinishEvent(shared, action) -- 3453
				emitCheckpointEventForAction(shared, action) -- 3454
				i = i + 1 -- 3447
			end -- 3447
		end -- 3447
		persistHistoryState(shared) -- 3456
		return ____awaiter_resolve(nil, input.actions) -- 3443
	end) -- 3443
end -- 3441
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3460
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3460
		shared.pendingToolActions = nil -- 3461
		persistHistoryState(shared) -- 3462
		__TS__Await(maybeCompressHistory(shared)) -- 3463
		persistHistoryState(shared) -- 3464
		return ____awaiter_resolve(nil, "main") -- 3464
	end) -- 3464
end -- 3460
local EndNode = __TS__Class() -- 3469
EndNode.name = "EndNode" -- 3469
__TS__ClassExtends(EndNode, Node) -- 3469
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3470
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3470
		return ____awaiter_resolve(nil, nil) -- 3470
	end) -- 3470
end -- 3470
local CodingAgentFlow = __TS__Class() -- 3475
CodingAgentFlow.name = "CodingAgentFlow" -- 3475
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3475
function CodingAgentFlow.prototype.____constructor(self, role) -- 3476
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3477
	local read = __TS__New(ReadFileAction, 1, 0) -- 3478
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3479
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3480
	local list = __TS__New(ListFilesAction, 1, 0) -- 3481
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3482
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3483
	local build = __TS__New(BuildAction, 1, 0) -- 3484
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3485
	local edit = __TS__New(EditFileAction, 1, 0) -- 3486
	local batch = __TS__New(BatchToolAction, 1, 0) -- 3487
	local done = __TS__New(EndNode, 1, 0) -- 3488
	main:on("batch_tools", batch) -- 3490
	main:on("grep_files", search) -- 3491
	main:on("search_dora_api", searchDora) -- 3492
	main:on("glob_files", list) -- 3493
	if role == "main" then -- 3493
		main:on("read_file", read) -- 3495
		main:on("delete_file", del) -- 3496
		main:on("build", build) -- 3497
		main:on("edit_file", edit) -- 3498
		main:on("list_sub_agents", listSub) -- 3499
		main:on("spawn_sub_agent", spawn) -- 3500
	else -- 3500
		main:on("read_file", read) -- 3502
		main:on("delete_file", del) -- 3503
		main:on("build", build) -- 3504
		main:on("edit_file", edit) -- 3505
	end -- 3505
	main:on("done", done) -- 3507
	search:on("main", main) -- 3509
	searchDora:on("main", main) -- 3510
	list:on("main", main) -- 3511
	listSub:on("main", main) -- 3512
	spawn:on("main", main) -- 3513
	batch:on("main", main) -- 3514
	read:on("main", main) -- 3515
	del:on("main", main) -- 3516
	build:on("main", main) -- 3517
	edit:on("main", main) -- 3518
	Flow.prototype.____constructor(self, main) -- 3520
end -- 3476
local function runCodingAgentAsync(options) -- 3542
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3542
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3542
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3542
		end -- 3542
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3546
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3547
		if not llmConfigRes.success then -- 3547
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3547
		end -- 3547
		local llmConfig = llmConfigRes.config -- 3553
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3554
		if not taskRes.success then -- 3554
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3554
		end -- 3554
		local compressor = __TS__New(MemoryCompressor, { -- 3561
			compressionThreshold = 0.8, -- 3562
			compressionTargetThreshold = 0.5, -- 3563
			maxCompressionRounds = 3, -- 3564
			projectDir = options.workDir, -- 3565
			llmConfig = llmConfig, -- 3566
			promptPack = options.promptPack, -- 3567
			scope = options.memoryScope -- 3568
		}) -- 3568
		local persistedSession = compressor:getStorage():readSessionState() -- 3570
		local promptPack = compressor:getPromptPack() -- 3571
		local shared = { -- 3573
			sessionId = options.sessionId, -- 3574
			taskId = taskRes.taskId, -- 3575
			role = options.role or "main", -- 3576
			maxSteps = math.max( -- 3577
				1, -- 3577
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 3577
			), -- 3577
			llmMaxTry = math.max( -- 3578
				1, -- 3578
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 3578
			), -- 3578
			step = 0, -- 3579
			done = false, -- 3580
			stopToken = options.stopToken or ({stopped = false}), -- 3581
			response = "", -- 3582
			userQuery = normalizedPrompt, -- 3583
			workingDir = options.workDir, -- 3584
			useChineseResponse = options.useChineseResponse == true, -- 3585
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3586
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 3589
			llmConfig = llmConfig, -- 3590
			onEvent = options.onEvent, -- 3591
			promptPack = promptPack, -- 3592
			history = {}, -- 3593
			messages = persistedSession.messages, -- 3594
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 3595
			carryMessageIndex = persistedSession.carryMessageIndex, -- 3596
			memory = {compressor = compressor}, -- 3598
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 3602
			spawnSubAgent = options.spawnSubAgent, -- 3607
			listSubAgents = options.listSubAgents -- 3608
		} -- 3608
		local ____try = __TS__AsyncAwaiter(function() -- 3608
			emitAgentEvent(shared, { -- 3612
				type = "task_started", -- 3613
				sessionId = shared.sessionId, -- 3614
				taskId = shared.taskId, -- 3615
				prompt = shared.userQuery, -- 3616
				workDir = shared.workingDir, -- 3617
				maxSteps = shared.maxSteps -- 3618
			}) -- 3618
			if shared.stopToken.stopped then -- 3618
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3621
				return ____awaiter_resolve( -- 3621
					nil, -- 3621
					emitAgentTaskFinishEvent( -- 3622
						shared, -- 3622
						false, -- 3622
						getCancelledReason(shared) -- 3622
					) -- 3622
				) -- 3622
			end -- 3622
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3624
			local promptCommand = getPromptCommand(shared.userQuery) -- 3625
			if promptCommand == "clear" then -- 3625
				return ____awaiter_resolve( -- 3625
					nil, -- 3625
					clearSessionHistory(shared) -- 3627
				) -- 3627
			end -- 3627
			if promptCommand == "compact" then -- 3627
				if shared.role == "sub" then -- 3627
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 3631
					return ____awaiter_resolve( -- 3631
						nil, -- 3631
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 3632
					) -- 3632
				end -- 3632
				return ____awaiter_resolve( -- 3632
					nil, -- 3632
					__TS__Await(compactAllHistory(shared)) -- 3640
				) -- 3640
			end -- 3640
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3642
			persistHistoryState(shared) -- 3646
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3647
			__TS__Await(flow:run(shared)) -- 3648
			if shared.stopToken.stopped then -- 3648
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3650
				return ____awaiter_resolve( -- 3650
					nil, -- 3650
					emitAgentTaskFinishEvent( -- 3651
						shared, -- 3651
						false, -- 3651
						getCancelledReason(shared) -- 3651
					) -- 3651
				) -- 3651
			end -- 3651
			if shared.error then -- 3651
				return ____awaiter_resolve( -- 3651
					nil, -- 3651
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3654
				) -- 3654
			end -- 3654
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3657
			return ____awaiter_resolve( -- 3657
				nil, -- 3657
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3658
			) -- 3658
		end) -- 3658
		__TS__Await(____try.catch( -- 3611
			____try, -- 3611
			function(____, e) -- 3611
				return ____awaiter_resolve( -- 3611
					nil, -- 3611
					finalizeAgentFailure( -- 3661
						shared, -- 3661
						tostring(e) -- 3661
					) -- 3661
				) -- 3661
			end -- 3661
		)) -- 3661
	end) -- 3661
end -- 3542
function ____exports.runCodingAgent(options, callback) -- 3665
	local ____self_126 = runCodingAgentAsync(options) -- 3665
	____self_126["then"]( -- 3665
		____self_126, -- 3665
		function(____, result) return callback(result) end -- 3666
	) -- 3666
end -- 3665
return ____exports -- 3665
