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
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
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
local isArray, stripWrappingQuotes, parseSimpleYAML, emitAgentEvent, getCancelledReason, truncateText, getReplyLanguageDirective, replacePromptVars, getDecisionToolDefinitions, getFinishMessage, persistHistoryState, getActiveConversationMessages, getActiveRealMessageCount, applyCompressedSessionState, getDecisionPath, clampIntegerParam, parseReadLineParam, validateDecision, getAllowedToolsForRole, buildAgentSystemPrompt, buildSkillsSection, buildXmlDecisionInstruction, executeToolAction, emitAgentTaskFinishEvent, READ_FILE_DEFAULT_LIMIT, SEARCH_DORA_API_LIMIT_MAX, SEARCH_FILES_LIMIT_DEFAULT, LIST_FILES_MAX_ENTRIES_DEFAULT, SEARCH_PREVIEW_CONTEXT, EditFileAction -- 1
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
function emitAgentEvent(shared, event) -- 727
	if shared.onEvent then -- 727
		do -- 727
			local function ____catch(____error) -- 727
				Log( -- 732
					"Error", -- 732
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 732
				) -- 732
			end -- 732
			local ____try, ____hasReturned = pcall(function() -- 732
				shared:onEvent(event) -- 730
			end) -- 730
			if not ____try then -- 730
				____catch(____hasReturned) -- 730
			end -- 730
		end -- 730
	end -- 730
end -- 730
function getCancelledReason(shared) -- 793
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 793
		return shared.stopToken.reason -- 794
	end -- 794
	return shared.useChineseResponse and "已取消" or "cancelled" -- 795
end -- 795
function truncateText(text, maxLen) -- 976
	if #text <= maxLen then -- 976
		return text -- 977
	end -- 977
	local nextPos = utf8.offset(text, maxLen + 1) -- 978
	if nextPos == nil then -- 978
		return text -- 979
	end -- 979
	return string.sub(text, 1, nextPos - 1) .. "..." -- 980
end -- 980
function getReplyLanguageDirective(shared) -- 990
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 991
end -- 991
function replacePromptVars(template, vars) -- 996
	local output = template -- 997
	for key in pairs(vars) do -- 998
		output = table.concat( -- 999
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 999
			vars[key] or "" or "," -- 999
		) -- 999
	end -- 999
	return output -- 1001
end -- 1001
function getDecisionToolDefinitions(shared) -- 1125
	local base = replacePromptVars( -- 1126
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1127
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1128
	) -- 1128
	local spawnTool = "\n\n9. list_sub_agents: Query sub-agent state under the current main session\n\t- Parameters: status(optional), limit(optional), offset(optional), query(optional)\n\t- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.\n\t- status defaults to active_or_recent and may also be running, done, failed, or all.\n\t- limit defaults to a small recent window. Use offset to page older items.\n\t- query filters by title, goal, or summary text.\n\t- Do not use this after a successful spawn_sub_agent in the same turn.\n\n10. spawn_sub_agent: Create and start a sub agent session for delegated implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n\t- For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.\n\t- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.\n\t- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.\n\t- filesHint is an optional list of likely files or directories." -- 1130
	local availability = shared and (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat( -- 1151
		getAllowedToolsForRole(shared.role), -- 1152
		", " -- 1152
	) or "" -- 1152
	local withRole = (base .. ((shared and shared.role) == "main" and spawnTool or "")) .. availability -- 1154
	if (shared and shared.decisionMode) ~= "xml" then -- 1154
		return withRole -- 1156
	end -- 1156
	return withRole .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1158
end -- 1158
function getFinishMessage(params, fallback) -- 1457
	if fallback == nil then -- 1457
		fallback = "" -- 1457
	end -- 1457
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1457
		return __TS__StringTrim(params.message) -- 1459
	end -- 1459
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1459
		return __TS__StringTrim(params.response) -- 1462
	end -- 1462
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1462
		return __TS__StringTrim(params.summary) -- 1465
	end -- 1465
	return __TS__StringTrim(fallback) -- 1467
end -- 1467
function persistHistoryState(shared) -- 1470
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1471
end -- 1471
function getActiveConversationMessages(shared) -- 1478
	local activeMessages = {} -- 1479
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1479
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1486
	end -- 1486
	do -- 1486
		local i = shared.lastConsolidatedIndex -- 1490
		while i < #shared.messages do -- 1490
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1491
			i = i + 1 -- 1490
		end -- 1490
	end -- 1490
	return activeMessages -- 1493
end -- 1493
function getActiveRealMessageCount(shared) -- 1496
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1497
end -- 1497
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1500
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1505
	local previousActiveStart = shared.lastConsolidatedIndex -- 1506
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1507
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1508
	if type(carryMessageIndex) == "number" then -- 1508
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1508
		else -- 1508
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1516
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1519
		end -- 1519
	else -- 1519
		shared.carryMessageIndex = nil -- 1524
	end -- 1524
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1524
		shared.carryMessageIndex = nil -- 1534
	end -- 1534
end -- 1534
function getDecisionPath(params) -- 1791
	if type(params.path) == "string" then -- 1791
		return __TS__StringTrim(params.path) -- 1792
	end -- 1792
	if type(params.target_file) == "string" then -- 1792
		return __TS__StringTrim(params.target_file) -- 1793
	end -- 1793
	return "" -- 1794
end -- 1794
function clampIntegerParam(value, fallback, minValue, maxValue) -- 1797
	local num = __TS__Number(value) -- 1798
	if not __TS__NumberIsFinite(num) then -- 1798
		num = fallback -- 1799
	end -- 1799
	num = math.floor(num) -- 1800
	if num < minValue then -- 1800
		num = minValue -- 1801
	end -- 1801
	if maxValue ~= nil and num > maxValue then -- 1801
		num = maxValue -- 1802
	end -- 1802
	return num -- 1803
end -- 1803
function parseReadLineParam(value, fallback, paramName) -- 1806
	local num = __TS__Number(value) -- 1811
	if not __TS__NumberIsFinite(num) then -- 1811
		num = fallback -- 1812
	end -- 1812
	num = math.floor(num) -- 1813
	if num == 0 then -- 1813
		return {success = false, message = paramName .. " cannot be 0"} -- 1815
	end -- 1815
	return {success = true, value = num} -- 1817
end -- 1817
function validateDecision(tool, params) -- 1820
	if tool == "finish" then -- 1820
		local message = getFinishMessage(params) -- 1825
		if message == "" then -- 1825
			return {success = false, message = "finish requires params.message"} -- 1826
		end -- 1826
		params.message = message -- 1827
		return {success = true, params = params} -- 1828
	end -- 1828
	if tool == "read_file" then -- 1828
		local path = getDecisionPath(params) -- 1832
		if path == "" then -- 1832
			return {success = false, message = "read_file requires path"} -- 1833
		end -- 1833
		params.path = path -- 1834
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1835
		if not startLineRes.success then -- 1835
			return startLineRes -- 1836
		end -- 1836
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1837
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1838
		if not endLineRes.success then -- 1838
			return endLineRes -- 1839
		end -- 1839
		params.startLine = startLineRes.value -- 1840
		params.endLine = endLineRes.value -- 1841
		return {success = true, params = params} -- 1842
	end -- 1842
	if tool == "edit_file" then -- 1842
		local path = getDecisionPath(params) -- 1846
		if path == "" then -- 1846
			return {success = false, message = "edit_file requires path"} -- 1847
		end -- 1847
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1848
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1849
		params.path = path -- 1850
		params.old_str = oldStr -- 1851
		params.new_str = newStr -- 1852
		return {success = true, params = params} -- 1853
	end -- 1853
	if tool == "delete_file" then -- 1853
		local targetFile = getDecisionPath(params) -- 1857
		if targetFile == "" then -- 1857
			return {success = false, message = "delete_file requires target_file"} -- 1858
		end -- 1858
		params.target_file = targetFile -- 1859
		return {success = true, params = params} -- 1860
	end -- 1860
	if tool == "grep_files" then -- 1860
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1864
		if pattern == "" then -- 1864
			return {success = false, message = "grep_files requires pattern"} -- 1865
		end -- 1865
		params.pattern = pattern -- 1866
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1867
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1868
		return {success = true, params = params} -- 1869
	end -- 1869
	if tool == "search_dora_api" then -- 1869
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1873
		if pattern == "" then -- 1873
			return {success = false, message = "search_dora_api requires pattern"} -- 1874
		end -- 1874
		params.pattern = pattern -- 1875
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1876
		return {success = true, params = params} -- 1877
	end -- 1877
	if tool == "glob_files" then -- 1877
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1881
		return {success = true, params = params} -- 1882
	end -- 1882
	if tool == "build" then -- 1882
		local path = getDecisionPath(params) -- 1886
		if path ~= "" then -- 1886
			params.path = path -- 1888
		end -- 1888
		return {success = true, params = params} -- 1890
	end -- 1890
	if tool == "list_sub_agents" then -- 1890
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 1894
		if status ~= "" then -- 1894
			params.status = status -- 1896
		end -- 1896
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 1898
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1899
		if type(params.query) == "string" then -- 1899
			params.query = __TS__StringTrim(params.query) -- 1901
		end -- 1901
		return {success = true, params = params} -- 1903
	end -- 1903
	if tool == "spawn_sub_agent" then -- 1903
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 1907
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 1908
		if prompt == "" then -- 1908
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 1909
		end -- 1909
		if title == "" then -- 1909
			return {success = false, message = "spawn_sub_agent requires title"} -- 1910
		end -- 1910
		params.prompt = prompt -- 1911
		params.title = title -- 1912
		if type(params.expectedOutput) == "string" then -- 1912
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 1914
		end -- 1914
		if isArray(params.filesHint) then -- 1914
			params.filesHint = __TS__ArrayMap( -- 1917
				__TS__ArrayFilter( -- 1917
					params.filesHint, -- 1917
					function(____, item) return type(item) == "string" end -- 1918
				), -- 1918
				function(____, item) return sanitizeUTF8(item) end -- 1919
			) -- 1919
		end -- 1919
		return {success = true, params = params} -- 1921
	end -- 1921
	return {success = true, params = params} -- 1924
end -- 1924
function getAllowedToolsForRole(role) -- 1950
	return role == "main" and ({ -- 1951
		"read_file", -- 1952
		"edit_file", -- 1952
		"delete_file", -- 1952
		"grep_files", -- 1952
		"search_dora_api", -- 1952
		"glob_files", -- 1952
		"build", -- 1952
		"list_sub_agents", -- 1952
		"spawn_sub_agent", -- 1952
		"finish" -- 1952
	}) or ({ -- 1952
		"read_file", -- 1953
		"edit_file", -- 1953
		"delete_file", -- 1953
		"grep_files", -- 1953
		"search_dora_api", -- 1953
		"glob_files", -- 1953
		"build", -- 1953
		"finish" -- 1953
	}) -- 1953
end -- 1953
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2059
	if includeToolDefinitions == nil then -- 2059
		includeToolDefinitions = false -- 2059
	end -- 2059
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2060
	local sections = { -- 2063
		shared.promptPack.agentIdentityPrompt, -- 2064
		rolePrompt, -- 2065
		getReplyLanguageDirective(shared) -- 2066
	} -- 2066
	if shared.decisionMode == "tool_calling" then -- 2066
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2069
	end -- 2069
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2071
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2072
	if memoryContext ~= "" then -- 2072
		sections[#sections + 1] = memoryContext -- 2074
	end -- 2074
	if includeToolDefinitions then -- 2074
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2077
		if shared.decisionMode == "xml" then -- 2077
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2079
		end -- 2079
	end -- 2079
	local skillsSection = buildSkillsSection(shared) -- 2083
	if skillsSection ~= "" then -- 2083
		sections[#sections + 1] = skillsSection -- 2085
	end -- 2085
	return table.concat(sections, "\n\n") -- 2087
end -- 2087
function buildSkillsSection(shared) -- 2090
	local ____opt_42 = shared.skills -- 2090
	if not (____opt_42 and ____opt_42.loader) then -- 2090
		return "" -- 2092
	end -- 2092
	return shared.skills.loader:buildSkillsPromptSection() -- 2094
end -- 2094
function buildXmlDecisionInstruction(shared, feedback) -- 2206
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2207
end -- 2207
function executeToolAction(shared, action) -- 3333
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3333
		if shared.stopToken.stopped then -- 3333
			return ____awaiter_resolve( -- 3333
				nil, -- 3333
				{ -- 3335
					success = false, -- 3335
					message = getCancelledReason(shared) -- 3335
				} -- 3335
			) -- 3335
		end -- 3335
		local params = action.params -- 3337
		if action.tool == "read_file" then -- 3337
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3339
			if __TS__StringTrim(path) == "" then -- 3339
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3339
			end -- 3339
			local ____Tools_readFile_104 = Tools.readFile -- 3343
			local ____shared_workingDir_102 = shared.workingDir -- 3344
			local ____params_startLine_100 = params.startLine -- 3346
			if ____params_startLine_100 == nil then -- 3346
				____params_startLine_100 = 1 -- 3346
			end -- 3346
			local ____TS__Number_result_103 = __TS__Number(____params_startLine_100) -- 3346
			local ____params_endLine_101 = params.endLine -- 3347
			if ____params_endLine_101 == nil then -- 3347
				____params_endLine_101 = READ_FILE_DEFAULT_LIMIT -- 3347
			end -- 3347
			return ____awaiter_resolve( -- 3347
				nil, -- 3347
				____Tools_readFile_104( -- 3343
					____shared_workingDir_102, -- 3344
					path, -- 3345
					____TS__Number_result_103, -- 3346
					__TS__Number(____params_endLine_101), -- 3347
					shared.useChineseResponse and "zh" or "en" -- 3348
				) -- 3348
			) -- 3348
		end -- 3348
		if action.tool == "grep_files" then -- 3348
			local ____Tools_searchFiles_118 = Tools.searchFiles -- 3352
			local ____shared_workingDir_111 = shared.workingDir -- 3353
			local ____temp_112 = params.path or "" -- 3354
			local ____temp_113 = params.pattern or "" -- 3355
			local ____params_globs_114 = params.globs -- 3356
			local ____params_useRegex_115 = params.useRegex -- 3357
			local ____params_caseSensitive_116 = params.caseSensitive -- 3358
			local ____math_max_107 = math.max -- 3361
			local ____math_floor_106 = math.floor -- 3361
			local ____params_limit_105 = params.limit -- 3361
			if ____params_limit_105 == nil then -- 3361
				____params_limit_105 = SEARCH_FILES_LIMIT_DEFAULT -- 3361
			end -- 3361
			local ____math_max_107_result_117 = ____math_max_107( -- 3361
				1, -- 3361
				____math_floor_106(__TS__Number(____params_limit_105)) -- 3361
			) -- 3361
			local ____math_max_110 = math.max -- 3362
			local ____math_floor_109 = math.floor -- 3362
			local ____params_offset_108 = params.offset -- 3362
			if ____params_offset_108 == nil then -- 3362
				____params_offset_108 = 0 -- 3362
			end -- 3362
			local result = __TS__Await(____Tools_searchFiles_118({ -- 3352
				workDir = ____shared_workingDir_111, -- 3353
				path = ____temp_112, -- 3354
				pattern = ____temp_113, -- 3355
				globs = ____params_globs_114, -- 3356
				useRegex = ____params_useRegex_115, -- 3357
				caseSensitive = ____params_caseSensitive_116, -- 3358
				includeContent = true, -- 3359
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3360
				limit = ____math_max_107_result_117, -- 3361
				offset = ____math_max_110( -- 3362
					0, -- 3362
					____math_floor_109(__TS__Number(____params_offset_108)) -- 3362
				), -- 3362
				groupByFile = params.groupByFile == true -- 3363
			})) -- 3363
			return ____awaiter_resolve(nil, result) -- 3363
		end -- 3363
		if action.tool == "search_dora_api" then -- 3363
			local ____Tools_searchDoraAPI_126 = Tools.searchDoraAPI -- 3368
			local ____temp_122 = params.pattern or "" -- 3369
			local ____temp_123 = params.docSource or "api" -- 3370
			local ____temp_124 = shared.useChineseResponse and "zh" or "en" -- 3371
			local ____temp_125 = params.programmingLanguage or "ts" -- 3372
			local ____math_min_121 = math.min -- 3373
			local ____math_max_120 = math.max -- 3373
			local ____params_limit_119 = params.limit -- 3373
			if ____params_limit_119 == nil then -- 3373
				____params_limit_119 = 8 -- 3373
			end -- 3373
			local result = __TS__Await(____Tools_searchDoraAPI_126({ -- 3368
				pattern = ____temp_122, -- 3369
				docSource = ____temp_123, -- 3370
				docLanguage = ____temp_124, -- 3371
				programmingLanguage = ____temp_125, -- 3372
				limit = ____math_min_121( -- 3373
					SEARCH_DORA_API_LIMIT_MAX, -- 3373
					____math_max_120( -- 3373
						1, -- 3373
						__TS__Number(____params_limit_119) -- 3373
					) -- 3373
				), -- 3373
				useRegex = params.useRegex, -- 3374
				caseSensitive = false, -- 3375
				includeContent = true, -- 3376
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3377
			})) -- 3377
			return ____awaiter_resolve(nil, result) -- 3377
		end -- 3377
		if action.tool == "glob_files" then -- 3377
			local ____Tools_listFiles_133 = Tools.listFiles -- 3382
			local ____shared_workingDir_130 = shared.workingDir -- 3383
			local ____temp_131 = params.path or "" -- 3384
			local ____params_globs_132 = params.globs -- 3385
			local ____math_max_129 = math.max -- 3386
			local ____math_floor_128 = math.floor -- 3386
			local ____params_maxEntries_127 = params.maxEntries -- 3386
			if ____params_maxEntries_127 == nil then -- 3386
				____params_maxEntries_127 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3386
			end -- 3386
			local result = ____Tools_listFiles_133({ -- 3382
				workDir = ____shared_workingDir_130, -- 3383
				path = ____temp_131, -- 3384
				globs = ____params_globs_132, -- 3385
				maxEntries = ____math_max_129( -- 3386
					1, -- 3386
					____math_floor_128(__TS__Number(____params_maxEntries_127)) -- 3386
				) -- 3386
			}) -- 3386
			return ____awaiter_resolve(nil, result) -- 3386
		end -- 3386
		if action.tool == "delete_file" then -- 3386
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3391
			if __TS__StringTrim(targetFile) == "" then -- 3391
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3391
			end -- 3391
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3395
			if not result.success then -- 3395
				return ____awaiter_resolve(nil, result) -- 3395
			end -- 3395
			return ____awaiter_resolve(nil, { -- 3395
				success = true, -- 3403
				changed = true, -- 3404
				mode = "delete", -- 3405
				checkpointId = result.checkpointId, -- 3406
				checkpointSeq = result.checkpointSeq, -- 3407
				files = {{path = targetFile, op = "delete"}} -- 3408
			}) -- 3408
		end -- 3408
		if action.tool == "build" then -- 3408
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3412
			return ____awaiter_resolve(nil, result) -- 3412
		end -- 3412
		if action.tool == "spawn_sub_agent" then -- 3412
			if not shared.spawnSubAgent then -- 3412
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3412
			end -- 3412
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3412
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3412
			end -- 3412
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3425
				params.filesHint, -- 3426
				function(____, item) return type(item) == "string" end -- 3426
			) or nil -- 3426
			local result = __TS__Await(shared.spawnSubAgent({ -- 3428
				parentSessionId = shared.sessionId, -- 3429
				projectRoot = shared.workingDir, -- 3430
				title = type(params.title) == "string" and params.title or "Sub", -- 3431
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3432
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3433
				filesHint = filesHint -- 3434
			})) -- 3434
			if not result.success then -- 3434
				return ____awaiter_resolve(nil, result) -- 3434
			end -- 3434
			return ____awaiter_resolve(nil, { -- 3434
				success = true, -- 3440
				sessionId = result.sessionId, -- 3441
				taskId = result.taskId, -- 3442
				title = result.title, -- 3443
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3444
			}) -- 3444
		end -- 3444
		if action.tool == "list_sub_agents" then -- 3444
			if not shared.listSubAgents then -- 3444
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3444
			end -- 3444
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3444
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3444
			end -- 3444
			local result = __TS__Await(shared.listSubAgents({ -- 3454
				sessionId = shared.sessionId, -- 3455
				projectRoot = shared.workingDir, -- 3456
				status = type(params.status) == "string" and params.status or nil, -- 3457
				limit = type(params.limit) == "number" and params.limit or nil, -- 3458
				offset = type(params.offset) == "number" and params.offset or nil, -- 3459
				query = type(params.query) == "string" and params.query or nil -- 3460
			})) -- 3460
			return ____awaiter_resolve(nil, result) -- 3460
		end -- 3460
		if action.tool == "edit_file" then -- 3460
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3465
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3468
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3469
			if __TS__StringTrim(path) == "" then -- 3469
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3469
			end -- 3469
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3471
			return ____awaiter_resolve( -- 3471
				nil, -- 3471
				actionNode:exec({ -- 3472
					path = path, -- 3473
					oldStr = oldStr, -- 3474
					newStr = newStr, -- 3475
					taskId = shared.taskId, -- 3476
					workDir = shared.workingDir -- 3477
				}) -- 3477
			) -- 3477
		end -- 3477
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3477
	end) -- 3477
end -- 3477
function emitAgentTaskFinishEvent(shared, success, message) -- 3624
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3625
	emitAgentEvent(shared, { -- 3631
		type = "task_finished", -- 3632
		sessionId = shared.sessionId, -- 3633
		taskId = shared.taskId, -- 3634
		success = result.success, -- 3635
		message = result.message, -- 3636
		steps = result.steps -- 3637
	}) -- 3637
	return result -- 3639
end -- 3639
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
SEARCH_PREVIEW_CONTEXT = 80 -- 651
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
local function emitAgentStartEvent(shared, action) -- 737
	emitAgentEvent(shared, { -- 738
		type = "tool_started", -- 739
		sessionId = shared.sessionId, -- 740
		taskId = shared.taskId, -- 741
		step = action.step, -- 742
		tool = action.tool -- 743
	}) -- 743
end -- 737
local function emitAgentFinishEvent(shared, action) -- 747
	emitAgentEvent(shared, { -- 748
		type = "tool_finished", -- 749
		sessionId = shared.sessionId, -- 750
		taskId = shared.taskId, -- 751
		step = action.step, -- 752
		tool = action.tool, -- 753
		result = action.result or ({}) -- 754
	}) -- 754
end -- 747
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 758
	emitAgentEvent(shared, { -- 759
		type = "assistant_message_updated", -- 760
		sessionId = shared.sessionId, -- 761
		taskId = shared.taskId, -- 762
		step = shared.step + 1, -- 763
		content = content, -- 764
		reasoningContent = reasoningContent -- 765
	}) -- 765
end -- 758
local function getMemoryCompressionStartReason(shared) -- 769
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 770
end -- 769
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 775
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 776
end -- 775
local function getMemoryCompressionFailureReason(shared, ____error) -- 781
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 782
end -- 781
local function summarizeHistoryEntryPreview(text, maxChars) -- 787
	if maxChars == nil then -- 787
		maxChars = 180 -- 787
	end -- 787
	local trimmed = __TS__StringTrim(text) -- 788
	if trimmed == "" then -- 788
		return "" -- 789
	end -- 789
	return truncateText(trimmed, maxChars) -- 790
end -- 787
local function getMaxStepsReachedReason(shared) -- 798
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 799
end -- 798
local function getFailureSummaryFallback(shared, ____error) -- 804
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 805
end -- 804
local function finalizeAgentFailure(shared, ____error) -- 810
	if shared.stopToken.stopped then -- 810
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 812
		return emitAgentTaskFinishEvent( -- 813
			shared, -- 813
			false, -- 813
			getCancelledReason(shared) -- 813
		) -- 813
	end -- 813
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 815
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 816
end -- 810
local function getPromptCommand(prompt) -- 819
	local trimmed = __TS__StringTrim(prompt) -- 820
	if trimmed == "/compact" then -- 820
		return "compact" -- 821
	end -- 821
	if trimmed == "/clear" then -- 821
		return "clear" -- 822
	end -- 822
	return nil -- 823
end -- 819
function ____exports.truncateAgentUserPrompt(prompt) -- 826
	if not prompt then -- 826
		return "" -- 827
	end -- 827
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 827
		return prompt -- 828
	end -- 828
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 829
	if offset == nil then -- 829
		return prompt -- 830
	end -- 830
	return string.sub(prompt, 1, offset - 1) -- 831
end -- 826
local function canWriteStepLLMDebug(shared, stepId) -- 834
	if stepId == nil then -- 834
		stepId = shared.step + 1 -- 834
	end -- 834
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 835
end -- 834
local function ensureDirRecursive(dir) -- 842
	if not dir then -- 842
		return false -- 843
	end -- 843
	if Content:exist(dir) then -- 843
		return Content:isdir(dir) -- 844
	end -- 844
	local parent = Path:getPath(dir) -- 845
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 845
		return false -- 847
	end -- 847
	return Content:mkdir(dir) -- 849
end -- 842
local function encodeDebugJSON(value) -- 852
	local text, err = safeJsonEncode(value) -- 853
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 854
end -- 852
local function getStepLLMDebugDir(shared) -- 857
	return Path( -- 858
		shared.workingDir, -- 859
		".agent", -- 860
		tostring(shared.sessionId), -- 861
		tostring(shared.taskId) -- 862
	) -- 862
end -- 857
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 866
	return Path( -- 867
		getStepLLMDebugDir(shared), -- 867
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 867
	) -- 867
end -- 866
local function getLatestStepLLMDebugSeq(shared, stepId) -- 870
	if not canWriteStepLLMDebug(shared, stepId) then -- 870
		return 0 -- 871
	end -- 871
	local dir = getStepLLMDebugDir(shared) -- 872
	if not Content:exist(dir) or not Content:isdir(dir) then -- 872
		return 0 -- 873
	end -- 873
	local latest = 0 -- 874
	for ____, file in ipairs(Content:getFiles(dir)) do -- 875
		do -- 875
			local name = Path:getFilename(file) -- 876
			local seqText = string.match( -- 877
				name, -- 877
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 877
			) -- 877
			if seqText ~= nil then -- 877
				latest = math.max( -- 879
					latest, -- 879
					tonumber(seqText) -- 879
				) -- 879
				goto __continue124 -- 880
			end -- 880
			local legacyMatch = string.match( -- 882
				name, -- 882
				("^" .. tostring(stepId)) .. "_in%.md$" -- 882
			) -- 882
			if legacyMatch ~= nil then -- 882
				latest = math.max(latest, 1) -- 884
			end -- 884
		end -- 884
		::__continue124:: -- 884
	end -- 884
	return latest -- 887
end -- 870
local function writeStepLLMDebugFile(path, content) -- 890
	if not Content:save(path, content) then -- 890
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 892
		return false -- 893
	end -- 893
	return true -- 895
end -- 890
local function createStepLLMDebugPair(shared, stepId, inContent) -- 898
	if not canWriteStepLLMDebug(shared, stepId) then -- 898
		return 0 -- 899
	end -- 899
	local dir = getStepLLMDebugDir(shared) -- 900
	if not ensureDirRecursive(dir) then -- 900
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 902
		return 0 -- 903
	end -- 903
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 905
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 906
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 907
	if not writeStepLLMDebugFile(inPath, inContent) then -- 907
		return 0 -- 909
	end -- 909
	writeStepLLMDebugFile(outPath, "") -- 911
	return seq -- 912
end -- 898
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 915
	if not canWriteStepLLMDebug(shared, stepId) then -- 915
		return -- 916
	end -- 916
	local dir = getStepLLMDebugDir(shared) -- 917
	if not ensureDirRecursive(dir) then -- 917
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 919
		return -- 920
	end -- 920
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 922
	if latestSeq <= 0 then -- 922
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 924
		writeStepLLMDebugFile(outPath, content) -- 925
		return -- 926
	end -- 926
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 928
	writeStepLLMDebugFile(outPath, content) -- 929
end -- 915
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 932
	if not canWriteStepLLMDebug(shared, stepId) then -- 932
		return -- 933
	end -- 933
	local sections = { -- 934
		"# LLM Input", -- 935
		"session_id: " .. tostring(shared.sessionId), -- 936
		"task_id: " .. tostring(shared.taskId), -- 937
		"step_id: " .. tostring(stepId), -- 938
		"phase: " .. phase, -- 939
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 940
		"## Options", -- 941
		"```json", -- 942
		encodeDebugJSON(options), -- 943
		"```" -- 944
	} -- 944
	do -- 944
		local i = 0 -- 946
		while i < #messages do -- 946
			local message = messages[i + 1] -- 947
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 948
			sections[#sections + 1] = encodeDebugJSON(message) -- 949
			i = i + 1 -- 946
		end -- 946
	end -- 946
	createStepLLMDebugPair( -- 951
		shared, -- 951
		stepId, -- 951
		table.concat(sections, "\n") -- 951
	) -- 951
end -- 932
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 954
	if not canWriteStepLLMDebug(shared, stepId) then -- 954
		return -- 955
	end -- 955
	local ____array_2 = __TS__SparseArrayNew( -- 955
		"# LLM Output", -- 957
		"session_id: " .. tostring(shared.sessionId), -- 958
		"task_id: " .. tostring(shared.taskId), -- 959
		"step_id: " .. tostring(stepId), -- 960
		"phase: " .. phase, -- 961
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 962
		table.unpack(meta and ({ -- 963
			"## Meta", -- 963
			"```json", -- 963
			encodeDebugJSON(meta), -- 963
			"```" -- 963
		}) or ({})) -- 963
	) -- 963
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 963
	local sections = {__TS__SparseArraySpread(____array_2)} -- 956
	updateLatestStepLLMDebugOutput( -- 967
		shared, -- 967
		stepId, -- 967
		table.concat(sections, "\n") -- 967
	) -- 967
end -- 954
local function toJson(value) -- 970
	local text, err = safeJsonEncode(value) -- 971
	if text ~= nil then -- 971
		return text -- 972
	end -- 972
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 973
end -- 970
local function utf8TakeHead(text, maxChars) -- 983
	if maxChars <= 0 or text == "" then -- 983
		return "" -- 984
	end -- 984
	local nextPos = utf8.offset(text, maxChars + 1) -- 985
	if nextPos == nil then -- 985
		return text -- 986
	end -- 986
	return string.sub(text, 1, nextPos - 1) -- 987
end -- 983
local function limitReadContentForHistory(content, tool) -- 1004
	local lines = __TS__StringSplit(content, "\n") -- 1005
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 1006
	local limitedByLines = overLineLimit and table.concat( -- 1007
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 1008
		"\n" -- 1008
	) or content -- 1008
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 1008
		return content -- 1011
	end -- 1011
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 1013
	local reasons = {} -- 1016
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 1016
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 1017
	end -- 1017
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 1017
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 1018
	end -- 1018
	local hint = "Narrow the requested line range." -- 1019
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 1020
end -- 1004
local function summarizeEditTextParamForHistory(value, key) -- 1023
	if type(value) ~= "string" then -- 1023
		return nil -- 1024
	end -- 1024
	local text = value -- 1025
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 1026
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 1027
end -- 1023
local function sanitizeReadResultForHistory(tool, result) -- 1035
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 1035
		return result -- 1037
	end -- 1037
	local clone = {} -- 1039
	for key in pairs(result) do -- 1040
		clone[key] = result[key] -- 1041
	end -- 1041
	clone.content = limitReadContentForHistory(result.content, tool) -- 1043
	return clone -- 1044
end -- 1035
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 1047
	local shown = math.min(#items, maxItems) -- 1051
	local out = {} -- 1052
	do -- 1052
		local i = 0 -- 1053
		while i < shown do -- 1053
			local row = items[i + 1] -- 1054
			out[#out + 1] = { -- 1055
				file = row.file, -- 1056
				line = row.line, -- 1057
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1058
			} -- 1058
			i = i + 1 -- 1053
		end -- 1053
	end -- 1053
	return out -- 1063
end -- 1047
local function sanitizeSearchResultForHistory(tool, result) -- 1066
	if result.success ~= true or not isArray(result.results) then -- 1066
		return result -- 1070
	end -- 1070
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1070
		return result -- 1071
	end -- 1071
	local clone = {} -- 1072
	for key in pairs(result) do -- 1073
		clone[key] = result[key] -- 1074
	end -- 1074
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 1076
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1077
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1077
		local grouped = result.groupedResults -- 1082
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 1083
		local sanitizedGroups = {} -- 1084
		do -- 1084
			local i = 0 -- 1085
			while i < shown do -- 1085
				local row = grouped[i + 1] -- 1086
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1087
					file = row.file, -- 1088
					totalMatches = row.totalMatches, -- 1089
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1090
				} -- 1090
				i = i + 1 -- 1085
			end -- 1085
		end -- 1085
		clone.groupedResults = sanitizedGroups -- 1095
	end -- 1095
	return clone -- 1097
end -- 1066
local function sanitizeListFilesResultForHistory(result) -- 1100
	if result.success ~= true or not isArray(result.files) then -- 1100
		return result -- 1101
	end -- 1101
	local clone = {} -- 1102
	for key in pairs(result) do -- 1103
		clone[key] = result[key] -- 1104
	end -- 1104
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1106
	return clone -- 1107
end -- 1100
local function sanitizeActionParamsForHistory(tool, params) -- 1110
	if tool ~= "edit_file" then -- 1110
		return params -- 1111
	end -- 1111
	local clone = {} -- 1112
	for key in pairs(params) do -- 1113
		if key == "old_str" then -- 1113
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1115
		elseif key == "new_str" then -- 1115
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1117
		else -- 1117
			clone[key] = params[key] -- 1119
		end -- 1119
	end -- 1119
	return clone -- 1122
end -- 1110
local function isToolAllowedForRole(role, tool) -- 1167
	return __TS__ArrayIndexOf( -- 1168
		getAllowedToolsForRole(role), -- 1168
		tool -- 1168
	) >= 0 -- 1168
end -- 1167
local PRE_EXEC_SAFE_TOOLS = { -- 1171
	"read_file", -- 1172
	"grep_files", -- 1173
	"search_dora_api", -- 1174
	"glob_files", -- 1175
	"list_sub_agents" -- 1176
} -- 1176
local function canPreExecuteTool(tool) -- 1179
	return __TS__ArrayIndexOf(PRE_EXEC_SAFE_TOOLS, tool) >= 0 -- 1180
end -- 1179
local function clearPreExecutedResults(shared) -- 1183
	shared.preExecutedResults = nil -- 1184
end -- 1183
local function startPreExecutedToolAction(shared, action) -- 1187
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1187
		local ____try = __TS__AsyncAwaiter(function() -- 1187
			return ____awaiter_resolve( -- 1187
				nil, -- 1187
				__TS__Await(executeToolAction(shared, action)) -- 1189
			) -- 1189
		end) -- 1189
		__TS__Await(____try.catch( -- 1188
			____try, -- 1188
			function(____, err) -- 1188
				local message = tostring(err) -- 1191
				Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1192
				return ____awaiter_resolve(nil, {success = false, message = message}) -- 1192
			end -- 1192
		)) -- 1192
	end) -- 1192
end -- 1187
local function executeToolActionWithPreExecution(shared, action) -- 1197
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1197
		local ____opt_9 = shared.preExecutedResults -- 1197
		local preResult = ____opt_9 and ____opt_9:get(action.toolCallId) -- 1198
		if preResult then -- 1198
			Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1200
			local ____opt_11 = shared.preExecutedResults -- 1200
			if ____opt_11 ~= nil then -- 1200
				____opt_11:delete(action.toolCallId) -- 1201
			end -- 1201
			return ____awaiter_resolve( -- 1201
				nil, -- 1201
				__TS__Await(preResult) -- 1202
			) -- 1202
		end -- 1202
		return ____awaiter_resolve( -- 1202
			nil, -- 1202
			executeToolAction(shared, action) -- 1204
		) -- 1204
	end) -- 1204
end -- 1197
local function maybeCompressHistory(shared) -- 1207
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1207
		local ____shared_13 = shared -- 1208
		local memory = ____shared_13.memory -- 1208
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1209
		local changed = false -- 1210
		do -- 1210
			local round = 0 -- 1211
			while round < maxRounds do -- 1211
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1212
				local activeMessages = getActiveConversationMessages(shared) -- 1213
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1217
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 1217
					if changed then -- 1217
						persistHistoryState(shared) -- 1226
					end -- 1226
					return ____awaiter_resolve(nil) -- 1226
				end -- 1226
				local compressionRound = round + 1 -- 1230
				shared.step = shared.step + 1 -- 1231
				local stepId = shared.step -- 1232
				local pendingMessages = #activeMessages -- 1233
				emitAgentEvent( -- 1234
					shared, -- 1234
					{ -- 1234
						type = "memory_compression_started", -- 1235
						sessionId = shared.sessionId, -- 1236
						taskId = shared.taskId, -- 1237
						step = stepId, -- 1238
						tool = "compress_memory", -- 1239
						reason = getMemoryCompressionStartReason(shared), -- 1240
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1241
					} -- 1241
				) -- 1241
				local result = __TS__Await(memory.compressor:compress( -- 1247
					activeMessages, -- 1248
					shared.llmOptions, -- 1249
					shared.llmMaxTry, -- 1250
					shared.decisionMode, -- 1251
					{ -- 1252
						onInput = function(____, phase, messages, options) -- 1253
							saveStepLLMDebugInput( -- 1254
								shared, -- 1254
								stepId, -- 1254
								phase, -- 1254
								messages, -- 1254
								options -- 1254
							) -- 1254
						end, -- 1253
						onOutput = function(____, phase, text, meta) -- 1256
							saveStepLLMDebugOutput( -- 1257
								shared, -- 1257
								stepId, -- 1257
								phase, -- 1257
								text, -- 1257
								meta -- 1257
							) -- 1257
						end -- 1256
					}, -- 1256
					"default", -- 1260
					systemPrompt, -- 1261
					toolDefinitions -- 1262
				)) -- 1262
				if not (result and result.success and result.compressedCount > 0) then -- 1262
					emitAgentEvent( -- 1265
						shared, -- 1265
						{ -- 1265
							type = "memory_compression_finished", -- 1266
							sessionId = shared.sessionId, -- 1267
							taskId = shared.taskId, -- 1268
							step = stepId, -- 1269
							tool = "compress_memory", -- 1270
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1271
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1275
						} -- 1275
					) -- 1275
					if changed then -- 1275
						persistHistoryState(shared) -- 1283
					end -- 1283
					return ____awaiter_resolve(nil) -- 1283
				end -- 1283
				local effectiveCompressedCount = math.max( -- 1287
					0, -- 1288
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1289
				) -- 1289
				if effectiveCompressedCount <= 0 then -- 1289
					if changed then -- 1289
						persistHistoryState(shared) -- 1293
					end -- 1293
					return ____awaiter_resolve(nil) -- 1293
				end -- 1293
				emitAgentEvent( -- 1297
					shared, -- 1297
					{ -- 1297
						type = "memory_compression_finished", -- 1298
						sessionId = shared.sessionId, -- 1299
						taskId = shared.taskId, -- 1300
						step = stepId, -- 1301
						tool = "compress_memory", -- 1302
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1303
						result = { -- 1304
							success = true, -- 1305
							round = compressionRound, -- 1306
							compressedCount = effectiveCompressedCount, -- 1307
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1308
						} -- 1308
					} -- 1308
				) -- 1308
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1311
				changed = true -- 1312
				Log( -- 1313
					"Info", -- 1313
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1313
				) -- 1313
				round = round + 1 -- 1211
			end -- 1211
		end -- 1211
		if changed then -- 1211
			persistHistoryState(shared) -- 1316
		end -- 1316
	end) -- 1316
end -- 1207
local function compactAllHistory(shared) -- 1320
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1320
		local ____shared_20 = shared -- 1321
		local memory = ____shared_20.memory -- 1321
		local rounds = 0 -- 1322
		local totalCompressed = 0 -- 1323
		while getActiveRealMessageCount(shared) > 0 do -- 1323
			if shared.stopToken.stopped then -- 1323
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1326
				return ____awaiter_resolve( -- 1326
					nil, -- 1326
					emitAgentTaskFinishEvent( -- 1327
						shared, -- 1327
						false, -- 1327
						getCancelledReason(shared) -- 1327
					) -- 1327
				) -- 1327
			end -- 1327
			rounds = rounds + 1 -- 1329
			shared.step = shared.step + 1 -- 1330
			local stepId = shared.step -- 1331
			local activeMessages = getActiveConversationMessages(shared) -- 1332
			local pendingMessages = #activeMessages -- 1333
			emitAgentEvent( -- 1334
				shared, -- 1334
				{ -- 1334
					type = "memory_compression_started", -- 1335
					sessionId = shared.sessionId, -- 1336
					taskId = shared.taskId, -- 1337
					step = stepId, -- 1338
					tool = "compress_memory", -- 1339
					reason = getMemoryCompressionStartReason(shared), -- 1340
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1341
				} -- 1341
			) -- 1341
			local result = __TS__Await(memory.compressor:compress( -- 1348
				activeMessages, -- 1349
				shared.llmOptions, -- 1350
				shared.llmMaxTry, -- 1351
				shared.decisionMode, -- 1352
				{ -- 1353
					onInput = function(____, phase, messages, options) -- 1354
						saveStepLLMDebugInput( -- 1355
							shared, -- 1355
							stepId, -- 1355
							phase, -- 1355
							messages, -- 1355
							options -- 1355
						) -- 1355
					end, -- 1354
					onOutput = function(____, phase, text, meta) -- 1357
						saveStepLLMDebugOutput( -- 1358
							shared, -- 1358
							stepId, -- 1358
							phase, -- 1358
							text, -- 1358
							meta -- 1358
						) -- 1358
					end -- 1357
				}, -- 1357
				"budget_max" -- 1361
			)) -- 1361
			if not (result and result.success and result.compressedCount > 0) then -- 1361
				emitAgentEvent( -- 1364
					shared, -- 1364
					{ -- 1364
						type = "memory_compression_finished", -- 1365
						sessionId = shared.sessionId, -- 1366
						taskId = shared.taskId, -- 1367
						step = stepId, -- 1368
						tool = "compress_memory", -- 1369
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1370
						result = { -- 1374
							success = false, -- 1375
							rounds = rounds, -- 1376
							error = result and result.error or "compression returned no changes", -- 1377
							compressedCount = result and result.compressedCount or 0, -- 1378
							fullCompaction = true -- 1379
						} -- 1379
					} -- 1379
				) -- 1379
				return ____awaiter_resolve( -- 1379
					nil, -- 1379
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1382
				) -- 1382
			end -- 1382
			local effectiveCompressedCount = math.max( -- 1387
				0, -- 1388
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1389
			) -- 1389
			if effectiveCompressedCount <= 0 then -- 1389
				return ____awaiter_resolve( -- 1389
					nil, -- 1389
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1392
				) -- 1392
			end -- 1392
			emitAgentEvent( -- 1399
				shared, -- 1399
				{ -- 1399
					type = "memory_compression_finished", -- 1400
					sessionId = shared.sessionId, -- 1401
					taskId = shared.taskId, -- 1402
					step = stepId, -- 1403
					tool = "compress_memory", -- 1404
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1405
					result = { -- 1406
						success = true, -- 1407
						round = rounds, -- 1408
						compressedCount = effectiveCompressedCount, -- 1409
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1410
						fullCompaction = true -- 1411
					} -- 1411
				} -- 1411
			) -- 1411
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1414
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1415
			persistHistoryState(shared) -- 1416
			Log( -- 1417
				"Info", -- 1417
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1417
			) -- 1417
		end -- 1417
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1419
		return ____awaiter_resolve( -- 1419
			nil, -- 1419
			emitAgentTaskFinishEvent( -- 1420
				shared, -- 1421
				true, -- 1422
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1423
			) -- 1423
		) -- 1423
	end) -- 1423
end -- 1320
local function clearSessionHistory(shared) -- 1429
	shared.messages = {} -- 1430
	shared.lastConsolidatedIndex = 0 -- 1431
	shared.carryMessageIndex = nil -- 1432
	persistHistoryState(shared) -- 1433
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1434
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1435
end -- 1429
local function isKnownToolName(name) -- 1444
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1445
end -- 1444
local function appendConversationMessage(shared, message) -- 1538
	local ____shared_messages_29 = shared.messages -- 1538
	____shared_messages_29[#____shared_messages_29 + 1] = __TS__ObjectAssign( -- 1539
		{}, -- 1539
		message, -- 1540
		{ -- 1539
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1541
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1542
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1543
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1544
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1545
		} -- 1545
	) -- 1545
end -- 1538
local function ensureToolCallId(toolCallId) -- 1549
	if toolCallId and toolCallId ~= "" then -- 1549
		return toolCallId -- 1550
	end -- 1550
	return createLocalToolCallId() -- 1551
end -- 1549
local function appendToolResultMessage(shared, action) -- 1554
	appendConversationMessage( -- 1555
		shared, -- 1555
		{ -- 1555
			role = "tool", -- 1556
			tool_call_id = action.toolCallId, -- 1557
			name = action.tool, -- 1558
			content = action.result and toJson(action.result) or "" -- 1559
		} -- 1559
	) -- 1559
end -- 1554
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1563
	appendConversationMessage( -- 1569
		shared, -- 1569
		{ -- 1569
			role = "assistant", -- 1570
			content = content or "", -- 1571
			reasoning_content = reasoningContent, -- 1572
			tool_calls = __TS__ArrayMap( -- 1573
				actions, -- 1573
				function(____, action) return { -- 1573
					id = action.toolCallId, -- 1574
					type = "function", -- 1575
					["function"] = { -- 1576
						name = action.tool, -- 1577
						arguments = toJson(action.params) -- 1578
					} -- 1578
				} end -- 1578
			) -- 1578
		} -- 1578
	) -- 1578
end -- 1563
local function parseXMLToolCallObjectFromText(text) -- 1584
	local children = parseXMLObjectFromText(text, "tool_call") -- 1585
	if not children.success then -- 1585
		return children -- 1586
	end -- 1586
	local rawObj = children.obj -- 1587
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1588
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1589
	if not params.success then -- 1589
		return {success = false, message = params.message} -- 1593
	end -- 1593
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1595
end -- 1584
local function llm(shared, messages, phase) -- 1615
	if phase == nil then -- 1615
		phase = "decision_xml" -- 1618
	end -- 1618
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1618
		local stepId = shared.step + 1 -- 1620
		saveStepLLMDebugInput( -- 1621
			shared, -- 1621
			stepId, -- 1621
			phase, -- 1621
			messages, -- 1621
			shared.llmOptions -- 1621
		) -- 1621
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1622
		if res.success then -- 1622
			local ____opt_32 = res.response.choices -- 1622
			local ____opt_30 = ____opt_32 and ____opt_32[1] -- 1622
			local message = ____opt_30 and ____opt_30.message -- 1624
			local text = message and message.content -- 1625
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1626
			if text then -- 1626
				saveStepLLMDebugOutput( -- 1630
					shared, -- 1630
					stepId, -- 1630
					phase, -- 1630
					text, -- 1630
					{success = true} -- 1630
				) -- 1630
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1630
			else -- 1630
				saveStepLLMDebugOutput( -- 1633
					shared, -- 1633
					stepId, -- 1633
					phase, -- 1633
					"empty LLM response", -- 1633
					{success = false} -- 1633
				) -- 1633
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1633
			end -- 1633
		else -- 1633
			saveStepLLMDebugOutput( -- 1637
				shared, -- 1637
				stepId, -- 1637
				phase, -- 1637
				res.raw or res.message, -- 1637
				{success = false} -- 1637
			) -- 1637
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1637
		end -- 1637
	end) -- 1637
end -- 1615
local function isDecisionBatchSuccess(result) -- 1661
	return result.kind == "batch" -- 1662
end -- 1661
local function parseDecisionObject(rawObj) -- 1665
	if type(rawObj.tool) ~= "string" then -- 1665
		return {success = false, message = "missing tool"} -- 1666
	end -- 1666
	local tool = rawObj.tool -- 1667
	if not isKnownToolName(tool) then -- 1667
		return {success = false, message = "unknown tool: " .. tool} -- 1669
	end -- 1669
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1671
	if tool ~= "finish" and (not reason or reason == "") then -- 1671
		return {success = false, message = tool .. " requires top-level reason"} -- 1675
	end -- 1675
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1677
	return {success = true, tool = tool, params = params, reason = reason} -- 1678
end -- 1665
local function parseDecisionToolCall(functionName, rawObj) -- 1686
	if not isKnownToolName(functionName) then -- 1686
		return {success = false, message = "unknown tool: " .. functionName} -- 1688
	end -- 1688
	if rawObj == nil or rawObj == nil then -- 1688
		return {success = true, tool = functionName, params = {}} -- 1691
	end -- 1691
	if not isRecord(rawObj) then -- 1691
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1694
	end -- 1694
	return {success = true, tool = functionName, params = rawObj} -- 1696
end -- 1686
local function parseToolCallArguments(functionName, argsText) -- 1703
	local trimmedArgs = __TS__StringTrim(argsText) -- 1704
	if trimmedArgs == "" then -- 1704
		return {} -- 1706
	end -- 1706
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 1708
	if err ~= nil or rawObj == nil then -- 1708
		return { -- 1710
			success = false, -- 1711
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1712
			raw = argsText -- 1713
		} -- 1713
	end -- 1713
	local encodedRaw = safeJsonEncode(rawObj) -- 1716
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 1716
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1718
	end -- 1718
	return rawObj -- 1724
end -- 1703
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1727
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1735
	if isRecord(rawArgs) and rawArgs.success == false then -- 1735
		return rawArgs -- 1737
	end -- 1737
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1739
	if not decision.success then -- 1739
		return {success = false, message = decision.message, raw = argsText} -- 1741
	end -- 1741
	local validation = validateDecision(decision.tool, decision.params) -- 1747
	if not validation.success then -- 1747
		return {success = false, message = validation.message, raw = argsText} -- 1749
	end -- 1749
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1749
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1756
	end -- 1756
	decision.params = validation.params -- 1762
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1763
	decision.reason = reason -- 1764
	decision.reasoningContent = reasoningContent -- 1765
	return decision -- 1766
end -- 1727
local function createPreExecutableActionFromStream(shared, toolCall) -- 1769
	local ____opt_38 = toolCall["function"] -- 1769
	local functionName = ____opt_38 and ____opt_38.name -- 1770
	local ____opt_40 = toolCall["function"] -- 1770
	local argsText = ____opt_40 and ____opt_40.arguments or "" -- 1771
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 1772
	if not functionName or not toolCallId then -- 1772
		return nil -- 1773
	end -- 1773
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1774
	if isRecord(rawArgs) and rawArgs.success == false then -- 1774
		return nil -- 1775
	end -- 1775
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1776
	if not decision.success or not canPreExecuteTool(decision.tool) then -- 1776
		return nil -- 1777
	end -- 1777
	local validation = validateDecision(decision.tool, decision.params) -- 1778
	if not validation.success then -- 1778
		return nil -- 1779
	end -- 1779
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1779
		return nil -- 1780
	end -- 1780
	return { -- 1781
		step = shared.step + 1, -- 1782
		toolCallId = toolCallId, -- 1783
		tool = decision.tool, -- 1784
		reason = "", -- 1785
		params = validation.params, -- 1786
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1787
	} -- 1787
end -- 1769
local function createFunctionToolSchema(name, description, properties, required) -- 1927
	if required == nil then -- 1927
		required = {} -- 1931
	end -- 1931
	local parameters = {type = "object", properties = properties} -- 1933
	if #required > 0 then -- 1933
		parameters.required = required -- 1938
	end -- 1938
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1940
end -- 1927
local function buildDecisionToolSchema(shared) -- 1956
	local allowed = getAllowedToolsForRole(shared.role) -- 1957
	local tools = { -- 1958
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 1959
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 1969
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1979
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1987
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1991
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1992
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1993
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1994
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1995
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1996
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1997
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1998
		}, {"pattern"}), -- 1998
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 2002
		createFunctionToolSchema( -- 2011
			"search_dora_api", -- 2012
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 2012
			{ -- 2014
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 2015
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 2016
				programmingLanguage = {type = "string", enum = { -- 2017
					"ts", -- 2019
					"tsx", -- 2019
					"lua", -- 2019
					"yue", -- 2019
					"teal", -- 2019
					"tl", -- 2019
					"wa" -- 2019
				}, description = "Preferred language variant to search."}, -- 2019
				limit = { -- 2022
					type = "number", -- 2022
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 2022
				}, -- 2022
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 2023
			}, -- 2023
			{"pattern"} -- 2025
		), -- 2025
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 2027
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 2034
			"active_or_recent", -- 2038
			"running", -- 2038
			"done", -- 2038
			"failed", -- 2038
			"all" -- 2038
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 2038
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 2044
	} -- 2044
	return __TS__ArrayFilter( -- 2056
		tools, -- 2056
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 2056
	) -- 2056
end -- 1956
local function sanitizeMessagesForLLMInput(messages) -- 2097
	local sanitized = {} -- 2098
	local droppedAssistantToolCalls = 0 -- 2099
	local droppedToolResults = 0 -- 2100
	do -- 2100
		local i = 0 -- 2101
		while i < #messages do -- 2101
			do -- 2101
				local message = messages[i + 1] -- 2102
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2102
					local requiredIds = {} -- 2104
					do -- 2104
						local j = 0 -- 2105
						while j < #message.tool_calls do -- 2105
							local toolCall = message.tool_calls[j + 1] -- 2106
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2107
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2107
								requiredIds[#requiredIds + 1] = id -- 2109
							end -- 2109
							j = j + 1 -- 2105
						end -- 2105
					end -- 2105
					if #requiredIds == 0 then -- 2105
						sanitized[#sanitized + 1] = message -- 2113
						goto __continue326 -- 2114
					end -- 2114
					local matchedIds = {} -- 2116
					local matchedTools = {} -- 2117
					local j = i + 1 -- 2118
					while j < #messages do -- 2118
						local toolMessage = messages[j + 1] -- 2120
						if toolMessage.role ~= "tool" then -- 2120
							break -- 2121
						end -- 2121
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2122
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2122
							matchedIds[toolCallId] = true -- 2124
							matchedTools[#matchedTools + 1] = toolMessage -- 2125
						else -- 2125
							droppedToolResults = droppedToolResults + 1 -- 2127
						end -- 2127
						j = j + 1 -- 2129
					end -- 2129
					local complete = true -- 2131
					do -- 2131
						local j = 0 -- 2132
						while j < #requiredIds do -- 2132
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2132
								complete = false -- 2134
								break -- 2135
							end -- 2135
							j = j + 1 -- 2132
						end -- 2132
					end -- 2132
					if complete then -- 2132
						__TS__ArrayPush( -- 2139
							sanitized, -- 2139
							message, -- 2139
							table.unpack(matchedTools) -- 2139
						) -- 2139
					else -- 2139
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2141
						droppedToolResults = droppedToolResults + #matchedTools -- 2142
					end -- 2142
					i = j - 1 -- 2144
					goto __continue326 -- 2145
				end -- 2145
				if message.role == "tool" then -- 2145
					droppedToolResults = droppedToolResults + 1 -- 2148
					goto __continue326 -- 2149
				end -- 2149
				sanitized[#sanitized + 1] = message -- 2151
			end -- 2151
			::__continue326:: -- 2151
			i = i + 1 -- 2101
		end -- 2101
	end -- 2101
	return sanitized -- 2153
end -- 2097
local function getUnconsolidatedMessages(shared) -- 2156
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2157
end -- 2156
local function getFinalDecisionTurnPrompt(shared) -- 2160
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2161
end -- 2160
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2166
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2166
		return messages -- 2167
	end -- 2167
	local next = __TS__ArrayMap( -- 2168
		messages, -- 2168
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2168
	) -- 2168
	do -- 2168
		local i = #next - 1 -- 2169
		while i >= 0 do -- 2169
			do -- 2169
				local message = next[i + 1] -- 2170
				if message.role ~= "assistant" and message.role ~= "user" then -- 2170
					goto __continue348 -- 2171
				end -- 2171
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2172
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2173
				return next -- 2176
			end -- 2176
			::__continue348:: -- 2176
			i = i - 1 -- 2169
		end -- 2169
	end -- 2169
	next[#next + 1] = {role = "user", content = prompt} -- 2178
	return next -- 2179
end -- 2166
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2182
	if attempt == nil then -- 2182
		attempt = 1 -- 2182
	end -- 2182
	local messages = { -- 2183
		{ -- 2184
			role = "system", -- 2184
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 2184
		}, -- 2184
		table.unpack(getUnconsolidatedMessages(shared)) -- 2185
	} -- 2185
	if shared.step + 1 >= shared.maxSteps then -- 2185
		messages = appendPromptToLatestDecisionMessage( -- 2188
			messages, -- 2188
			getFinalDecisionTurnPrompt(shared) -- 2188
		) -- 2188
	end -- 2188
	if lastError and lastError ~= "" then -- 2188
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2191
		messages[#messages + 1] = { -- 2194
			role = "user", -- 2195
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2196
		} -- 2196
	end -- 2196
	return messages -- 2203
end -- 2182
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2210
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2217
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2218
	local repairPrompt = replacePromptVars( -- 2226
		shared.promptPack.xmlDecisionRepairPrompt, -- 2226
		{ -- 2226
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2227
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2228
			CANDIDATE_SECTION = candidateSection, -- 2229
			LAST_ERROR = lastError, -- 2230
			ATTEMPT = tostring(attempt) -- 2231
		} -- 2231
	) -- 2231
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2233
end -- 2210
local function tryParseAndValidateDecision(rawText) -- 2245
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2246
	if not parsed.success then -- 2246
		return {success = false, message = parsed.message, raw = rawText} -- 2248
	end -- 2248
	local decision = parseDecisionObject(parsed.obj) -- 2250
	if not decision.success then -- 2250
		return {success = false, message = decision.message, raw = rawText} -- 2252
	end -- 2252
	local validation = validateDecision(decision.tool, decision.params) -- 2254
	if not validation.success then -- 2254
		return {success = false, message = validation.message, raw = rawText} -- 2256
	end -- 2256
	decision.params = validation.params -- 2258
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2259
	return decision -- 2260
end -- 2245
local function normalizeLineEndings(text) -- 2263
	local res = string.gsub(text, "\r\n", "\n") -- 2264
	res = string.gsub(res, "\r", "\n") -- 2265
	return res -- 2266
end -- 2263
local function countOccurrences(text, searchStr) -- 2269
	if searchStr == "" then -- 2269
		return 0 -- 2270
	end -- 2270
	local count = 0 -- 2271
	local pos = 0 -- 2272
	while true do -- 2272
		local idx = (string.find( -- 2274
			text, -- 2274
			searchStr, -- 2274
			math.max(pos + 1, 1), -- 2274
			true -- 2274
		) or 0) - 1 -- 2274
		if idx < 0 then -- 2274
			break -- 2275
		end -- 2275
		count = count + 1 -- 2276
		pos = idx + #searchStr -- 2277
	end -- 2277
	return count -- 2279
end -- 2269
local function replaceFirst(text, oldStr, newStr) -- 2282
	if oldStr == "" then -- 2282
		return text -- 2283
	end -- 2283
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2284
	if idx < 0 then -- 2284
		return text -- 2285
	end -- 2285
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2286
end -- 2282
local function splitLines(text) -- 2289
	return __TS__StringSplit(text, "\n") -- 2290
end -- 2289
local function getLeadingWhitespace(text) -- 2293
	local i = 0 -- 2294
	while i < #text do -- 2294
		local ch = __TS__StringAccess(text, i) -- 2296
		if ch ~= " " and ch ~= "\t" then -- 2296
			break -- 2297
		end -- 2297
		i = i + 1 -- 2298
	end -- 2298
	return __TS__StringSubstring(text, 0, i) -- 2300
end -- 2293
local function getCommonIndentPrefix(lines) -- 2303
	local common -- 2304
	do -- 2304
		local i = 0 -- 2305
		while i < #lines do -- 2305
			do -- 2305
				local line = lines[i + 1] -- 2306
				if __TS__StringTrim(line) == "" then -- 2306
					goto __continue373 -- 2307
				end -- 2307
				local indent = getLeadingWhitespace(line) -- 2308
				if common == nil then -- 2308
					common = indent -- 2310
					goto __continue373 -- 2311
				end -- 2311
				local j = 0 -- 2313
				local maxLen = math.min(#common, #indent) -- 2314
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2314
					j = j + 1 -- 2316
				end -- 2316
				common = __TS__StringSubstring(common, 0, j) -- 2318
				if common == "" then -- 2318
					break -- 2319
				end -- 2319
			end -- 2319
			::__continue373:: -- 2319
			i = i + 1 -- 2305
		end -- 2305
	end -- 2305
	return common or "" -- 2321
end -- 2303
local function removeIndentPrefix(line, indent) -- 2324
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2324
		return __TS__StringSubstring(line, #indent) -- 2326
	end -- 2326
	local lineIndent = getLeadingWhitespace(line) -- 2328
	local j = 0 -- 2329
	local maxLen = math.min(#lineIndent, #indent) -- 2330
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2330
		j = j + 1 -- 2332
	end -- 2332
	return __TS__StringSubstring(line, j) -- 2334
end -- 2324
local function dedentLines(lines) -- 2337
	local indent = getCommonIndentPrefix(lines) -- 2338
	return { -- 2339
		indent = indent, -- 2340
		lines = __TS__ArrayMap( -- 2341
			lines, -- 2341
			function(____, line) return removeIndentPrefix(line, indent) end -- 2341
		) -- 2341
	} -- 2341
end -- 2337
local function joinLines(lines) -- 2345
	return table.concat(lines, "\n") -- 2346
end -- 2345
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2349
	local contentLines = splitLines(content) -- 2354
	local oldLines = splitLines(oldStr) -- 2355
	if #oldLines == 0 then -- 2355
		return {success = false, message = "old_str not found in file"} -- 2357
	end -- 2357
	local dedentedOld = dedentLines(oldLines) -- 2359
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2360
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2361
	local matches = {} -- 2362
	do -- 2362
		local start = 0 -- 2363
		while start <= #contentLines - #oldLines do -- 2363
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2364
			local dedentedCandidate = dedentLines(candidateLines) -- 2365
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2365
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2367
			end -- 2367
			start = start + 1 -- 2363
		end -- 2363
	end -- 2363
	if #matches == 0 then -- 2363
		return {success = false, message = "old_str not found in file"} -- 2375
	end -- 2375
	if #matches > 1 then -- 2375
		return { -- 2378
			success = false, -- 2379
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2380
		} -- 2380
	end -- 2380
	local match = matches[1] -- 2383
	local rebuiltNewLines = __TS__ArrayMap( -- 2384
		dedentedNew.lines, -- 2384
		function(____, line) return line == "" and "" or match.indent .. line end -- 2384
	) -- 2384
	local ____array_46 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2384
	__TS__SparseArrayPush( -- 2384
		____array_46, -- 2384
		table.unpack(rebuiltNewLines) -- 2387
	) -- 2387
	__TS__SparseArrayPush( -- 2387
		____array_46, -- 2387
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2388
	) -- 2388
	local nextLines = {__TS__SparseArraySpread(____array_46)} -- 2385
	return { -- 2390
		success = true, -- 2390
		content = joinLines(nextLines) -- 2390
	} -- 2390
end -- 2349
local MainDecisionAgent = __TS__Class() -- 2393
MainDecisionAgent.name = "MainDecisionAgent" -- 2393
__TS__ClassExtends(MainDecisionAgent, Node) -- 2393
function MainDecisionAgent.prototype.prep(self, shared) -- 2394
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2394
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2394
			return ____awaiter_resolve(nil, {shared = shared}) -- 2394
		end -- 2394
		__TS__Await(maybeCompressHistory(shared)) -- 2399
		return ____awaiter_resolve(nil, {shared = shared}) -- 2399
	end) -- 2399
end -- 2394
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2404
	if attempt == nil then -- 2404
		attempt = 1 -- 2407
	end -- 2407
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2407
		if shared.stopToken.stopped then -- 2407
			return ____awaiter_resolve( -- 2407
				nil, -- 2407
				{ -- 2411
					success = false, -- 2411
					message = getCancelledReason(shared) -- 2411
				} -- 2411
			) -- 2411
		end -- 2411
		Log( -- 2413
			"Info", -- 2413
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2413
		) -- 2413
		local tools = buildDecisionToolSchema(shared) -- 2414
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2415
		local stepId = shared.step + 1 -- 2416
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2417
		saveStepLLMDebugInput( -- 2421
			shared, -- 2421
			stepId, -- 2421
			"decision_tool_calling", -- 2421
			messages, -- 2421
			llmOptions -- 2421
		) -- 2421
		local lastStreamContent = "" -- 2422
		local lastStreamReasoning = "" -- 2423
		local preExecutedResults = __TS__New(Map) -- 2424
		shared.preExecutedResults = preExecutedResults -- 2425
		local res = __TS__Await(callLLMStreamAggregated( -- 2426
			messages, -- 2427
			llmOptions, -- 2428
			shared.stopToken, -- 2429
			shared.llmConfig, -- 2430
			function(response) -- 2431
				local ____opt_49 = response.choices -- 2431
				local ____opt_47 = ____opt_49 and ____opt_49[1] -- 2431
				local streamMessage = ____opt_47 and ____opt_47.message -- 2432
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2433
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2436
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2436
					return -- 2440
				end -- 2440
				lastStreamContent = nextContent -- 2442
				lastStreamReasoning = nextReasoning -- 2443
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2444
			end, -- 2431
			function(tc) -- 2446
				if shared.stopToken.stopped then -- 2446
					return -- 2447
				end -- 2447
				local action = createPreExecutableActionFromStream(shared, tc) -- 2448
				if not action or preExecutedResults:has(action.toolCallId) then -- 2448
					return -- 2449
				end -- 2449
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2450
				preExecutedResults:set( -- 2451
					action.toolCallId, -- 2451
					startPreExecutedToolAction(shared, action) -- 2451
				) -- 2451
			end -- 2446
		)) -- 2446
		if shared.stopToken.stopped then -- 2446
			clearPreExecutedResults(shared) -- 2455
			return ____awaiter_resolve( -- 2455
				nil, -- 2455
				{ -- 2456
					success = false, -- 2456
					message = getCancelledReason(shared) -- 2456
				} -- 2456
			) -- 2456
		end -- 2456
		if not res.success then -- 2456
			saveStepLLMDebugOutput( -- 2459
				shared, -- 2459
				stepId, -- 2459
				"decision_tool_calling", -- 2459
				res.raw or res.message, -- 2459
				{success = false} -- 2459
			) -- 2459
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2460
			clearPreExecutedResults(shared) -- 2461
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2461
		end -- 2461
		saveStepLLMDebugOutput( -- 2464
			shared, -- 2464
			stepId, -- 2464
			"decision_tool_calling", -- 2464
			encodeDebugJSON(res.response), -- 2464
			{success = true} -- 2464
		) -- 2464
		local choice = res.response.choices and res.response.choices[1] -- 2465
		local message = choice and choice.message -- 2466
		local toolCalls = message and message.tool_calls -- 2467
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2468
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2471
		Log( -- 2474
			"Info", -- 2474
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2474
		) -- 2474
		if not toolCalls or #toolCalls == 0 then -- 2474
			if messageContent and messageContent ~= "" then -- 2474
				Log( -- 2477
					"Info", -- 2477
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2477
				) -- 2477
				clearPreExecutedResults(shared) -- 2478
				return ____awaiter_resolve(nil, { -- 2478
					success = true, -- 2480
					tool = "finish", -- 2481
					params = {}, -- 2482
					reason = messageContent, -- 2483
					reasoningContent = reasoningContent, -- 2484
					directSummary = messageContent -- 2485
				}) -- 2485
			end -- 2485
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2488
			clearPreExecutedResults(shared) -- 2489
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 2489
		end -- 2489
		local decisions = {} -- 2496
		do -- 2496
			local i = 0 -- 2497
			while i < #toolCalls do -- 2497
				local toolCall = toolCalls[i + 1] -- 2498
				local fn = toolCall and toolCall["function"] -- 2499
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2499
					Log( -- 2501
						"Error", -- 2501
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2501
					) -- 2501
					clearPreExecutedResults(shared) -- 2502
					return ____awaiter_resolve( -- 2502
						nil, -- 2502
						{ -- 2503
							success = false, -- 2504
							message = "missing function name for tool call " .. tostring(i + 1), -- 2505
							raw = messageContent -- 2506
						} -- 2506
					) -- 2506
				end -- 2506
				local functionName = fn.name -- 2509
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2510
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2511
				Log( -- 2514
					"Info", -- 2514
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2514
				) -- 2514
				local decision = parseAndValidateToolCallDecision( -- 2515
					shared, -- 2516
					functionName, -- 2517
					argsText, -- 2518
					toolCallId, -- 2519
					messageContent, -- 2520
					reasoningContent -- 2521
				) -- 2521
				if not decision.success then -- 2521
					Log( -- 2524
						"Error", -- 2524
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2524
					) -- 2524
					clearPreExecutedResults(shared) -- 2525
					return ____awaiter_resolve(nil, decision) -- 2525
				end -- 2525
				decisions[#decisions + 1] = decision -- 2528
				i = i + 1 -- 2497
			end -- 2497
		end -- 2497
		if #decisions == 1 then -- 2497
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2531
			return ____awaiter_resolve(nil, decisions[1]) -- 2531
		end -- 2531
		do -- 2531
			local i = 0 -- 2534
			while i < #decisions do -- 2534
				if decisions[i + 1].tool == "finish" then -- 2534
					clearPreExecutedResults(shared) -- 2536
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2536
				end -- 2536
				i = i + 1 -- 2534
			end -- 2534
		end -- 2534
		Log( -- 2544
			"Info", -- 2544
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2544
				__TS__ArrayMap( -- 2544
					decisions, -- 2544
					function(____, decision) return decision.tool end -- 2544
				), -- 2544
				"," -- 2544
			) -- 2544
		) -- 2544
		return ____awaiter_resolve(nil, { -- 2544
			success = true, -- 2546
			kind = "batch", -- 2547
			decisions = decisions, -- 2548
			content = messageContent, -- 2549
			reasoningContent = reasoningContent -- 2550
		}) -- 2550
	end) -- 2550
end -- 2404
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2554
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2554
		Log( -- 2559
			"Info", -- 2559
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2559
		) -- 2559
		local lastError = initialError -- 2560
		local candidateRaw = "" -- 2561
		do -- 2561
			local attempt = 0 -- 2562
			while attempt < shared.llmMaxTry do -- 2562
				do -- 2562
					Log( -- 2563
						"Info", -- 2563
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2563
					) -- 2563
					local messages = buildXmlRepairMessages( -- 2564
						shared, -- 2565
						originalRaw, -- 2566
						candidateRaw, -- 2567
						lastError, -- 2568
						attempt + 1 -- 2569
					) -- 2569
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2571
					if shared.stopToken.stopped then -- 2571
						return ____awaiter_resolve( -- 2571
							nil, -- 2571
							{ -- 2573
								success = false, -- 2573
								message = getCancelledReason(shared) -- 2573
							} -- 2573
						) -- 2573
					end -- 2573
					if not llmRes.success then -- 2573
						lastError = llmRes.message -- 2576
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2577
						goto __continue416 -- 2578
					end -- 2578
					candidateRaw = llmRes.text -- 2580
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2581
					if decision.success then -- 2581
						decision.reasoningContent = llmRes.reasoningContent -- 2583
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2584
						return ____awaiter_resolve(nil, decision) -- 2584
					end -- 2584
					lastError = decision.message -- 2587
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2588
				end -- 2588
				::__continue416:: -- 2588
				attempt = attempt + 1 -- 2562
			end -- 2562
		end -- 2562
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2590
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2590
	end) -- 2590
end -- 2554
function MainDecisionAgent.prototype.exec(self, input) -- 2598
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2598
		local shared = input.shared -- 2599
		if shared.stopToken.stopped then -- 2599
			return ____awaiter_resolve( -- 2599
				nil, -- 2599
				{ -- 2601
					success = false, -- 2601
					message = getCancelledReason(shared) -- 2601
				} -- 2601
			) -- 2601
		end -- 2601
		if shared.step >= shared.maxSteps then -- 2601
			Log( -- 2604
				"Warn", -- 2604
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2604
			) -- 2604
			return ____awaiter_resolve( -- 2604
				nil, -- 2604
				{ -- 2605
					success = false, -- 2605
					message = getMaxStepsReachedReason(shared) -- 2605
				} -- 2605
			) -- 2605
		end -- 2605
		if shared.decisionMode == "tool_calling" then -- 2605
			Log( -- 2609
				"Info", -- 2609
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2609
			) -- 2609
			local lastError = "tool calling validation failed" -- 2610
			local lastRaw = "" -- 2611
			do -- 2611
				local attempt = 0 -- 2612
				while attempt < shared.llmMaxTry do -- 2612
					Log( -- 2613
						"Info", -- 2613
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2613
					) -- 2613
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2614
					if shared.stopToken.stopped then -- 2614
						return ____awaiter_resolve( -- 2614
							nil, -- 2614
							{ -- 2621
								success = false, -- 2621
								message = getCancelledReason(shared) -- 2621
							} -- 2621
						) -- 2621
					end -- 2621
					if decision.success then -- 2621
						return ____awaiter_resolve(nil, decision) -- 2621
					end -- 2621
					lastError = decision.message -- 2626
					lastRaw = decision.raw or "" -- 2627
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2628
					attempt = attempt + 1 -- 2612
				end -- 2612
			end -- 2612
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2630
			return ____awaiter_resolve( -- 2630
				nil, -- 2630
				{ -- 2631
					success = false, -- 2631
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2631
				} -- 2631
			) -- 2631
		end -- 2631
		local lastError = "xml validation failed" -- 2634
		local lastRaw = "" -- 2635
		do -- 2635
			local attempt = 0 -- 2636
			while attempt < shared.llmMaxTry do -- 2636
				do -- 2636
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 2637
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2645
					if shared.stopToken.stopped then -- 2645
						return ____awaiter_resolve( -- 2645
							nil, -- 2645
							{ -- 2647
								success = false, -- 2647
								message = getCancelledReason(shared) -- 2647
							} -- 2647
						) -- 2647
					end -- 2647
					if not llmRes.success then -- 2647
						lastError = llmRes.message -- 2650
						lastRaw = llmRes.text or "" -- 2651
						goto __continue429 -- 2652
					end -- 2652
					lastRaw = llmRes.text -- 2654
					local decision = tryParseAndValidateDecision(llmRes.text) -- 2655
					if decision.success then -- 2655
						decision.reasoningContent = llmRes.reasoningContent -- 2657
						if not isToolAllowedForRole(shared.role, decision.tool) then -- 2657
							lastError = (decision.tool .. " is not allowed for role ") .. shared.role -- 2659
							return ____awaiter_resolve( -- 2659
								nil, -- 2659
								self:repairDecisionXml(shared, llmRes.text, lastError) -- 2660
							) -- 2660
						end -- 2660
						return ____awaiter_resolve(nil, decision) -- 2660
					end -- 2660
					lastError = decision.message -- 2664
					return ____awaiter_resolve( -- 2664
						nil, -- 2664
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 2665
					) -- 2665
				end -- 2665
				::__continue429:: -- 2665
				attempt = attempt + 1 -- 2636
			end -- 2636
		end -- 2636
		return ____awaiter_resolve( -- 2636
			nil, -- 2636
			{ -- 2667
				success = false, -- 2667
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2667
			} -- 2667
		) -- 2667
	end) -- 2667
end -- 2598
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2670
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2670
		local result = execRes -- 2671
		if not result.success then -- 2671
			if shared.stopToken.stopped then -- 2671
				shared.error = getCancelledReason(shared) -- 2674
				shared.done = true -- 2675
				return ____awaiter_resolve(nil, "done") -- 2675
			end -- 2675
			shared.error = result.message -- 2678
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2679
			shared.done = true -- 2680
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2681
			persistHistoryState(shared) -- 2685
			return ____awaiter_resolve(nil, "done") -- 2685
		end -- 2685
		if isDecisionBatchSuccess(result) then -- 2685
			local startStep = shared.step -- 2689
			local actions = {} -- 2690
			do -- 2690
				local i = 0 -- 2691
				while i < #result.decisions do -- 2691
					local decision = result.decisions[i + 1] -- 2692
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2693
					local step = startStep + i + 1 -- 2694
					local ____temp_55 -- 2695
					if i == 0 then -- 2695
						____temp_55 = decision.reason -- 2695
					else -- 2695
						____temp_55 = "" -- 2695
					end -- 2695
					local actionReason = ____temp_55 -- 2695
					local ____temp_56 -- 2696
					if i == 0 then -- 2696
						____temp_56 = decision.reasoningContent -- 2696
					else -- 2696
						____temp_56 = nil -- 2696
					end -- 2696
					local actionReasoningContent = ____temp_56 -- 2696
					emitAgentEvent(shared, { -- 2697
						type = "decision_made", -- 2698
						sessionId = shared.sessionId, -- 2699
						taskId = shared.taskId, -- 2700
						step = step, -- 2701
						tool = decision.tool, -- 2702
						reason = actionReason, -- 2703
						reasoningContent = actionReasoningContent, -- 2704
						params = decision.params -- 2705
					}) -- 2705
					local action = { -- 2707
						step = step, -- 2708
						toolCallId = toolCallId, -- 2709
						tool = decision.tool, -- 2710
						reason = actionReason or "", -- 2711
						reasoningContent = actionReasoningContent, -- 2712
						params = decision.params, -- 2713
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2714
					} -- 2714
					local ____shared_history_57 = shared.history -- 2714
					____shared_history_57[#____shared_history_57 + 1] = action -- 2716
					actions[#actions + 1] = action -- 2717
					i = i + 1 -- 2691
				end -- 2691
			end -- 2691
			shared.step = startStep + #actions -- 2719
			shared.pendingToolActions = actions -- 2720
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2721
			persistHistoryState(shared) -- 2727
			return ____awaiter_resolve(nil, "batch_tools") -- 2727
		end -- 2727
		if result.directSummary and result.directSummary ~= "" then -- 2727
			shared.response = result.directSummary -- 2731
			shared.done = true -- 2732
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2733
			persistHistoryState(shared) -- 2738
			return ____awaiter_resolve(nil, "done") -- 2738
		end -- 2738
		if result.tool == "finish" then -- 2738
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2742
			shared.response = finalMessage -- 2743
			shared.done = true -- 2744
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2745
			persistHistoryState(shared) -- 2750
			return ____awaiter_resolve(nil, "done") -- 2750
		end -- 2750
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2753
		shared.step = shared.step + 1 -- 2754
		local step = shared.step -- 2755
		emitAgentEvent(shared, { -- 2756
			type = "decision_made", -- 2757
			sessionId = shared.sessionId, -- 2758
			taskId = shared.taskId, -- 2759
			step = step, -- 2760
			tool = result.tool, -- 2761
			reason = result.reason, -- 2762
			reasoningContent = result.reasoningContent, -- 2763
			params = result.params -- 2764
		}) -- 2764
		local ____shared_history_58 = shared.history -- 2764
		____shared_history_58[#____shared_history_58 + 1] = { -- 2766
			step = step, -- 2767
			toolCallId = toolCallId, -- 2768
			tool = result.tool, -- 2769
			reason = result.reason or "", -- 2770
			reasoningContent = result.reasoningContent, -- 2771
			params = result.params, -- 2772
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2773
		} -- 2773
		local action = shared.history[#shared.history] -- 2775
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 2776
		if canPreExecuteTool(action.tool) then -- 2776
			shared.pendingToolActions = {action} -- 2778
			persistHistoryState(shared) -- 2779
			return ____awaiter_resolve(nil, "batch_tools") -- 2779
		end -- 2779
		clearPreExecutedResults(shared) -- 2782
		persistHistoryState(shared) -- 2783
		return ____awaiter_resolve(nil, result.tool) -- 2783
	end) -- 2783
end -- 2670
local ReadFileAction = __TS__Class() -- 2788
ReadFileAction.name = "ReadFileAction" -- 2788
__TS__ClassExtends(ReadFileAction, Node) -- 2788
function ReadFileAction.prototype.prep(self, shared) -- 2789
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2789
		local last = shared.history[#shared.history] -- 2790
		if not last then -- 2790
			error( -- 2791
				__TS__New(Error, "no history"), -- 2791
				0 -- 2791
			) -- 2791
		end -- 2791
		emitAgentStartEvent(shared, last) -- 2792
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2793
		if __TS__StringTrim(path) == "" then -- 2793
			error( -- 2796
				__TS__New(Error, "missing path"), -- 2796
				0 -- 2796
			) -- 2796
		end -- 2796
		local ____path_61 = path -- 2798
		local ____shared_workingDir_62 = shared.workingDir -- 2800
		local ____temp_63 = shared.useChineseResponse and "zh" or "en" -- 2801
		local ____last_params_startLine_59 = last.params.startLine -- 2802
		if ____last_params_startLine_59 == nil then -- 2802
			____last_params_startLine_59 = 1 -- 2802
		end -- 2802
		local ____TS__Number_result_64 = __TS__Number(____last_params_startLine_59) -- 2802
		local ____last_params_endLine_60 = last.params.endLine -- 2803
		if ____last_params_endLine_60 == nil then -- 2803
			____last_params_endLine_60 = READ_FILE_DEFAULT_LIMIT -- 2803
		end -- 2803
		return ____awaiter_resolve( -- 2803
			nil, -- 2803
			{ -- 2797
				path = ____path_61, -- 2798
				tool = "read_file", -- 2799
				workDir = ____shared_workingDir_62, -- 2800
				docLanguage = ____temp_63, -- 2801
				startLine = ____TS__Number_result_64, -- 2802
				endLine = __TS__Number(____last_params_endLine_60) -- 2803
			} -- 2803
		) -- 2803
	end) -- 2803
end -- 2789
function ReadFileAction.prototype.exec(self, input) -- 2807
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2807
		return ____awaiter_resolve( -- 2807
			nil, -- 2807
			Tools.readFile( -- 2808
				input.workDir, -- 2809
				input.path, -- 2810
				__TS__Number(input.startLine or 1), -- 2811
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2812
				input.docLanguage -- 2813
			) -- 2813
		) -- 2813
	end) -- 2813
end -- 2807
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2817
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2817
		local result = execRes -- 2818
		local last = shared.history[#shared.history] -- 2819
		if last ~= nil then -- 2819
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2821
			appendToolResultMessage(shared, last) -- 2822
			emitAgentFinishEvent(shared, last) -- 2823
		end -- 2823
		persistHistoryState(shared) -- 2825
		__TS__Await(maybeCompressHistory(shared)) -- 2826
		persistHistoryState(shared) -- 2827
		return ____awaiter_resolve(nil, "main") -- 2827
	end) -- 2827
end -- 2817
local SearchFilesAction = __TS__Class() -- 2832
SearchFilesAction.name = "SearchFilesAction" -- 2832
__TS__ClassExtends(SearchFilesAction, Node) -- 2832
function SearchFilesAction.prototype.prep(self, shared) -- 2833
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2833
		local last = shared.history[#shared.history] -- 2834
		if not last then -- 2834
			error( -- 2835
				__TS__New(Error, "no history"), -- 2835
				0 -- 2835
			) -- 2835
		end -- 2835
		emitAgentStartEvent(shared, last) -- 2836
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2836
	end) -- 2836
end -- 2833
function SearchFilesAction.prototype.exec(self, input) -- 2840
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2840
		local params = input.params -- 2841
		local ____Tools_searchFiles_78 = Tools.searchFiles -- 2842
		local ____input_workDir_71 = input.workDir -- 2843
		local ____temp_72 = params.path or "" -- 2844
		local ____temp_73 = params.pattern or "" -- 2845
		local ____params_globs_74 = params.globs -- 2846
		local ____params_useRegex_75 = params.useRegex -- 2847
		local ____params_caseSensitive_76 = params.caseSensitive -- 2848
		local ____math_max_67 = math.max -- 2851
		local ____math_floor_66 = math.floor -- 2851
		local ____params_limit_65 = params.limit -- 2851
		if ____params_limit_65 == nil then -- 2851
			____params_limit_65 = SEARCH_FILES_LIMIT_DEFAULT -- 2851
		end -- 2851
		local ____math_max_67_result_77 = ____math_max_67( -- 2851
			1, -- 2851
			____math_floor_66(__TS__Number(____params_limit_65)) -- 2851
		) -- 2851
		local ____math_max_70 = math.max -- 2852
		local ____math_floor_69 = math.floor -- 2852
		local ____params_offset_68 = params.offset -- 2852
		if ____params_offset_68 == nil then -- 2852
			____params_offset_68 = 0 -- 2852
		end -- 2852
		local result = __TS__Await(____Tools_searchFiles_78({ -- 2842
			workDir = ____input_workDir_71, -- 2843
			path = ____temp_72, -- 2844
			pattern = ____temp_73, -- 2845
			globs = ____params_globs_74, -- 2846
			useRegex = ____params_useRegex_75, -- 2847
			caseSensitive = ____params_caseSensitive_76, -- 2848
			includeContent = true, -- 2849
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2850
			limit = ____math_max_67_result_77, -- 2851
			offset = ____math_max_70( -- 2852
				0, -- 2852
				____math_floor_69(__TS__Number(____params_offset_68)) -- 2852
			), -- 2852
			groupByFile = params.groupByFile == true -- 2853
		})) -- 2853
		return ____awaiter_resolve(nil, result) -- 2853
	end) -- 2853
end -- 2840
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2858
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2858
		local last = shared.history[#shared.history] -- 2859
		if last ~= nil then -- 2859
			local result = execRes -- 2861
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2862
			appendToolResultMessage(shared, last) -- 2863
			emitAgentFinishEvent(shared, last) -- 2864
		end -- 2864
		persistHistoryState(shared) -- 2866
		__TS__Await(maybeCompressHistory(shared)) -- 2867
		persistHistoryState(shared) -- 2868
		return ____awaiter_resolve(nil, "main") -- 2868
	end) -- 2868
end -- 2858
local SearchDoraAPIAction = __TS__Class() -- 2873
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2873
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2873
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2874
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2874
		local last = shared.history[#shared.history] -- 2875
		if not last then -- 2875
			error( -- 2876
				__TS__New(Error, "no history"), -- 2876
				0 -- 2876
			) -- 2876
		end -- 2876
		emitAgentStartEvent(shared, last) -- 2877
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2877
	end) -- 2877
end -- 2874
function SearchDoraAPIAction.prototype.exec(self, input) -- 2881
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2881
		local params = input.params -- 2882
		local ____Tools_searchDoraAPI_86 = Tools.searchDoraAPI -- 2883
		local ____temp_82 = params.pattern or "" -- 2884
		local ____temp_83 = params.docSource or "api" -- 2885
		local ____temp_84 = input.useChineseResponse and "zh" or "en" -- 2886
		local ____temp_85 = params.programmingLanguage or "ts" -- 2887
		local ____math_min_81 = math.min -- 2888
		local ____math_max_80 = math.max -- 2888
		local ____params_limit_79 = params.limit -- 2888
		if ____params_limit_79 == nil then -- 2888
			____params_limit_79 = 8 -- 2888
		end -- 2888
		local result = __TS__Await(____Tools_searchDoraAPI_86({ -- 2883
			pattern = ____temp_82, -- 2884
			docSource = ____temp_83, -- 2885
			docLanguage = ____temp_84, -- 2886
			programmingLanguage = ____temp_85, -- 2887
			limit = ____math_min_81( -- 2888
				SEARCH_DORA_API_LIMIT_MAX, -- 2888
				____math_max_80( -- 2888
					1, -- 2888
					__TS__Number(____params_limit_79) -- 2888
				) -- 2888
			), -- 2888
			useRegex = params.useRegex, -- 2889
			caseSensitive = false, -- 2890
			includeContent = true, -- 2891
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2892
		})) -- 2892
		return ____awaiter_resolve(nil, result) -- 2892
	end) -- 2892
end -- 2881
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2897
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2897
		local last = shared.history[#shared.history] -- 2898
		if last ~= nil then -- 2898
			local result = execRes -- 2900
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2901
			appendToolResultMessage(shared, last) -- 2902
			emitAgentFinishEvent(shared, last) -- 2903
		end -- 2903
		persistHistoryState(shared) -- 2905
		__TS__Await(maybeCompressHistory(shared)) -- 2906
		persistHistoryState(shared) -- 2907
		return ____awaiter_resolve(nil, "main") -- 2907
	end) -- 2907
end -- 2897
local ListFilesAction = __TS__Class() -- 2912
ListFilesAction.name = "ListFilesAction" -- 2912
__TS__ClassExtends(ListFilesAction, Node) -- 2912
function ListFilesAction.prototype.prep(self, shared) -- 2913
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2913
		local last = shared.history[#shared.history] -- 2914
		if not last then -- 2914
			error( -- 2915
				__TS__New(Error, "no history"), -- 2915
				0 -- 2915
			) -- 2915
		end -- 2915
		emitAgentStartEvent(shared, last) -- 2916
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2916
	end) -- 2916
end -- 2913
function ListFilesAction.prototype.exec(self, input) -- 2920
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2920
		local params = input.params -- 2921
		local ____Tools_listFiles_93 = Tools.listFiles -- 2922
		local ____input_workDir_90 = input.workDir -- 2923
		local ____temp_91 = params.path or "" -- 2924
		local ____params_globs_92 = params.globs -- 2925
		local ____math_max_89 = math.max -- 2926
		local ____math_floor_88 = math.floor -- 2926
		local ____params_maxEntries_87 = params.maxEntries -- 2926
		if ____params_maxEntries_87 == nil then -- 2926
			____params_maxEntries_87 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2926
		end -- 2926
		local result = ____Tools_listFiles_93({ -- 2922
			workDir = ____input_workDir_90, -- 2923
			path = ____temp_91, -- 2924
			globs = ____params_globs_92, -- 2925
			maxEntries = ____math_max_89( -- 2926
				1, -- 2926
				____math_floor_88(__TS__Number(____params_maxEntries_87)) -- 2926
			) -- 2926
		}) -- 2926
		return ____awaiter_resolve(nil, result) -- 2926
	end) -- 2926
end -- 2920
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2931
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2931
		local last = shared.history[#shared.history] -- 2932
		if last ~= nil then -- 2932
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2934
			appendToolResultMessage(shared, last) -- 2935
			emitAgentFinishEvent(shared, last) -- 2936
		end -- 2936
		persistHistoryState(shared) -- 2938
		__TS__Await(maybeCompressHistory(shared)) -- 2939
		persistHistoryState(shared) -- 2940
		return ____awaiter_resolve(nil, "main") -- 2940
	end) -- 2940
end -- 2931
local DeleteFileAction = __TS__Class() -- 2945
DeleteFileAction.name = "DeleteFileAction" -- 2945
__TS__ClassExtends(DeleteFileAction, Node) -- 2945
function DeleteFileAction.prototype.prep(self, shared) -- 2946
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2946
		local last = shared.history[#shared.history] -- 2947
		if not last then -- 2947
			error( -- 2948
				__TS__New(Error, "no history"), -- 2948
				0 -- 2948
			) -- 2948
		end -- 2948
		emitAgentStartEvent(shared, last) -- 2949
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 2950
		if __TS__StringTrim(targetFile) == "" then -- 2950
			error( -- 2953
				__TS__New(Error, "missing target_file"), -- 2953
				0 -- 2953
			) -- 2953
		end -- 2953
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 2953
	end) -- 2953
end -- 2946
function DeleteFileAction.prototype.exec(self, input) -- 2957
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2957
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 2958
		if not result.success then -- 2958
			return ____awaiter_resolve(nil, result) -- 2958
		end -- 2958
		return ____awaiter_resolve(nil, { -- 2958
			success = true, -- 2966
			changed = true, -- 2967
			mode = "delete", -- 2968
			checkpointId = result.checkpointId, -- 2969
			checkpointSeq = result.checkpointSeq, -- 2970
			files = {{path = input.targetFile, op = "delete"}} -- 2971
		}) -- 2971
	end) -- 2971
end -- 2957
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2975
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2975
		local last = shared.history[#shared.history] -- 2976
		if last ~= nil then -- 2976
			last.result = execRes -- 2978
			appendToolResultMessage(shared, last) -- 2979
			emitAgentFinishEvent(shared, last) -- 2980
			local result = last.result -- 2981
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2981
				emitAgentEvent(shared, { -- 2986
					type = "checkpoint_created", -- 2987
					sessionId = shared.sessionId, -- 2988
					taskId = shared.taskId, -- 2989
					step = last.step, -- 2990
					tool = "delete_file", -- 2991
					checkpointId = result.checkpointId, -- 2992
					checkpointSeq = result.checkpointSeq, -- 2993
					files = result.files -- 2994
				}) -- 2994
			end -- 2994
		end -- 2994
		persistHistoryState(shared) -- 2998
		__TS__Await(maybeCompressHistory(shared)) -- 2999
		persistHistoryState(shared) -- 3000
		return ____awaiter_resolve(nil, "main") -- 3000
	end) -- 3000
end -- 2975
local BuildAction = __TS__Class() -- 3005
BuildAction.name = "BuildAction" -- 3005
__TS__ClassExtends(BuildAction, Node) -- 3005
function BuildAction.prototype.prep(self, shared) -- 3006
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3006
		local last = shared.history[#shared.history] -- 3007
		if not last then -- 3007
			error( -- 3008
				__TS__New(Error, "no history"), -- 3008
				0 -- 3008
			) -- 3008
		end -- 3008
		emitAgentStartEvent(shared, last) -- 3009
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3009
	end) -- 3009
end -- 3006
function BuildAction.prototype.exec(self, input) -- 3013
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3013
		local params = input.params -- 3014
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3015
		return ____awaiter_resolve(nil, result) -- 3015
	end) -- 3015
end -- 3013
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3022
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3022
		local last = shared.history[#shared.history] -- 3023
		if last ~= nil then -- 3023
			last.result = execRes -- 3025
			appendToolResultMessage(shared, last) -- 3026
			emitAgentFinishEvent(shared, last) -- 3027
		end -- 3027
		persistHistoryState(shared) -- 3029
		__TS__Await(maybeCompressHistory(shared)) -- 3030
		persistHistoryState(shared) -- 3031
		return ____awaiter_resolve(nil, "main") -- 3031
	end) -- 3031
end -- 3022
local SpawnSubAgentAction = __TS__Class() -- 3036
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3036
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3036
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3037
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3037
		local last = shared.history[#shared.history] -- 3046
		if not last then -- 3046
			error( -- 3047
				__TS__New(Error, "no history"), -- 3047
				0 -- 3047
			) -- 3047
		end -- 3047
		emitAgentStartEvent(shared, last) -- 3048
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3049
			last.params.filesHint, -- 3050
			function(____, item) return type(item) == "string" end -- 3050
		) or nil -- 3050
		return ____awaiter_resolve( -- 3050
			nil, -- 3050
			{ -- 3052
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3053
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3054
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3055
				filesHint = filesHint, -- 3056
				sessionId = shared.sessionId, -- 3057
				projectRoot = shared.workingDir, -- 3058
				spawnSubAgent = shared.spawnSubAgent -- 3059
			} -- 3059
		) -- 3059
	end) -- 3059
end -- 3037
function SpawnSubAgentAction.prototype.exec(self, input) -- 3063
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3063
		if not input.spawnSubAgent then -- 3063
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3063
		end -- 3063
		if input.sessionId == nil or input.sessionId <= 0 then -- 3063
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3063
		end -- 3063
		local ____Log_99 = Log -- 3078
		local ____temp_96 = #input.title -- 3078
		local ____temp_97 = #input.prompt -- 3078
		local ____temp_98 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3078
		local ____opt_94 = input.filesHint -- 3078
		____Log_99( -- 3078
			"Info", -- 3078
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_96)) .. " prompt_len=") .. tostring(____temp_97)) .. " expected_len=") .. tostring(____temp_98)) .. " files_hint_count=") .. tostring(____opt_94 and #____opt_94 or 0) -- 3078
		) -- 3078
		local result = __TS__Await(input.spawnSubAgent({ -- 3079
			parentSessionId = input.sessionId, -- 3080
			projectRoot = input.projectRoot, -- 3081
			title = input.title, -- 3082
			prompt = input.prompt, -- 3083
			expectedOutput = input.expectedOutput, -- 3084
			filesHint = input.filesHint -- 3085
		})) -- 3085
		if not result.success then -- 3085
			return ____awaiter_resolve(nil, result) -- 3085
		end -- 3085
		return ____awaiter_resolve(nil, { -- 3085
			success = true, -- 3091
			sessionId = result.sessionId, -- 3092
			taskId = result.taskId, -- 3093
			title = result.title, -- 3094
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3095
		}) -- 3095
	end) -- 3095
end -- 3063
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3099
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3099
		local last = shared.history[#shared.history] -- 3100
		if last ~= nil then -- 3100
			last.result = execRes -- 3102
			appendToolResultMessage(shared, last) -- 3103
			emitAgentFinishEvent(shared, last) -- 3104
		end -- 3104
		persistHistoryState(shared) -- 3106
		__TS__Await(maybeCompressHistory(shared)) -- 3107
		persistHistoryState(shared) -- 3108
		return ____awaiter_resolve(nil, "main") -- 3108
	end) -- 3108
end -- 3099
local ListSubAgentsAction = __TS__Class() -- 3113
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3113
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3113
function ListSubAgentsAction.prototype.prep(self, shared) -- 3114
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3114
		local last = shared.history[#shared.history] -- 3123
		if not last then -- 3123
			error( -- 3124
				__TS__New(Error, "no history"), -- 3124
				0 -- 3124
			) -- 3124
		end -- 3124
		emitAgentStartEvent(shared, last) -- 3125
		return ____awaiter_resolve( -- 3125
			nil, -- 3125
			{ -- 3126
				sessionId = shared.sessionId, -- 3127
				projectRoot = shared.workingDir, -- 3128
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3129
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3130
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3131
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3132
				listSubAgents = shared.listSubAgents -- 3133
			} -- 3133
		) -- 3133
	end) -- 3133
end -- 3114
function ListSubAgentsAction.prototype.exec(self, input) -- 3137
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3137
		if not input.listSubAgents then -- 3137
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3137
		end -- 3137
		if input.sessionId == nil or input.sessionId <= 0 then -- 3137
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3137
		end -- 3137
		local result = __TS__Await(input.listSubAgents({ -- 3152
			sessionId = input.sessionId, -- 3153
			projectRoot = input.projectRoot, -- 3154
			status = input.status, -- 3155
			limit = input.limit, -- 3156
			offset = input.offset, -- 3157
			query = input.query -- 3158
		})) -- 3158
		return ____awaiter_resolve(nil, result) -- 3158
	end) -- 3158
end -- 3137
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3163
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3163
		local last = shared.history[#shared.history] -- 3164
		if last ~= nil then -- 3164
			last.result = execRes -- 3166
			appendToolResultMessage(shared, last) -- 3167
			emitAgentFinishEvent(shared, last) -- 3168
		end -- 3168
		persistHistoryState(shared) -- 3170
		__TS__Await(maybeCompressHistory(shared)) -- 3171
		persistHistoryState(shared) -- 3172
		return ____awaiter_resolve(nil, "main") -- 3172
	end) -- 3172
end -- 3163
EditFileAction = __TS__Class() -- 3177
EditFileAction.name = "EditFileAction" -- 3177
__TS__ClassExtends(EditFileAction, Node) -- 3177
function EditFileAction.prototype.prep(self, shared) -- 3178
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3178
		local last = shared.history[#shared.history] -- 3179
		if not last then -- 3179
			error( -- 3180
				__TS__New(Error, "no history"), -- 3180
				0 -- 3180
			) -- 3180
		end -- 3180
		emitAgentStartEvent(shared, last) -- 3181
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3182
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3185
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3186
		if __TS__StringTrim(path) == "" then -- 3186
			error( -- 3187
				__TS__New(Error, "missing path"), -- 3187
				0 -- 3187
			) -- 3187
		end -- 3187
		return ____awaiter_resolve(nil, { -- 3187
			path = path, -- 3188
			oldStr = oldStr, -- 3188
			newStr = newStr, -- 3188
			taskId = shared.taskId, -- 3188
			workDir = shared.workingDir -- 3188
		}) -- 3188
	end) -- 3188
end -- 3178
function EditFileAction.prototype.exec(self, input) -- 3191
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3191
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3192
		if not readRes.success then -- 3192
			if input.oldStr ~= "" then -- 3192
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3192
			end -- 3192
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3197
			if not createRes.success then -- 3197
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3197
			end -- 3197
			return ____awaiter_resolve(nil, { -- 3197
				success = true, -- 3205
				changed = true, -- 3206
				mode = "create", -- 3207
				checkpointId = createRes.checkpointId, -- 3208
				checkpointSeq = createRes.checkpointSeq, -- 3209
				files = {{path = input.path, op = "create"}} -- 3210
			}) -- 3210
		end -- 3210
		if input.oldStr == "" then -- 3210
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3214
			if not overwriteRes.success then -- 3214
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3214
			end -- 3214
			return ____awaiter_resolve(nil, { -- 3214
				success = true, -- 3222
				changed = true, -- 3223
				mode = "overwrite", -- 3224
				checkpointId = overwriteRes.checkpointId, -- 3225
				checkpointSeq = overwriteRes.checkpointSeq, -- 3226
				files = {{path = input.path, op = "write"}} -- 3227
			}) -- 3227
		end -- 3227
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3232
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3233
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3234
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3237
		if occurrences == 0 then -- 3237
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3239
			if not indentTolerant.success then -- 3239
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3239
			end -- 3239
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3243
			if not applyRes.success then -- 3243
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3243
			end -- 3243
			return ____awaiter_resolve(nil, { -- 3243
				success = true, -- 3251
				changed = true, -- 3252
				mode = "replace_indent_tolerant", -- 3253
				checkpointId = applyRes.checkpointId, -- 3254
				checkpointSeq = applyRes.checkpointSeq, -- 3255
				files = {{path = input.path, op = "write"}} -- 3256
			}) -- 3256
		end -- 3256
		if occurrences > 1 then -- 3256
			return ____awaiter_resolve( -- 3256
				nil, -- 3256
				{ -- 3260
					success = false, -- 3260
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3260
				} -- 3260
			) -- 3260
		end -- 3260
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3264
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3265
		if not applyRes.success then -- 3265
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3265
		end -- 3265
		return ____awaiter_resolve(nil, { -- 3265
			success = true, -- 3273
			changed = true, -- 3274
			mode = "replace", -- 3275
			checkpointId = applyRes.checkpointId, -- 3276
			checkpointSeq = applyRes.checkpointSeq, -- 3277
			files = {{path = input.path, op = "write"}} -- 3278
		}) -- 3278
	end) -- 3278
end -- 3191
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3282
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3282
		local last = shared.history[#shared.history] -- 3283
		if last ~= nil then -- 3283
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3285
			last.result = execRes -- 3286
			appendToolResultMessage(shared, last) -- 3287
			emitAgentFinishEvent(shared, last) -- 3288
			local result = last.result -- 3289
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3289
				emitAgentEvent(shared, { -- 3294
					type = "checkpoint_created", -- 3295
					sessionId = shared.sessionId, -- 3296
					taskId = shared.taskId, -- 3297
					step = last.step, -- 3298
					tool = last.tool, -- 3299
					checkpointId = result.checkpointId, -- 3300
					checkpointSeq = result.checkpointSeq, -- 3301
					files = result.files -- 3302
				}) -- 3302
			end -- 3302
		end -- 3302
		persistHistoryState(shared) -- 3306
		__TS__Await(maybeCompressHistory(shared)) -- 3307
		persistHistoryState(shared) -- 3308
		return ____awaiter_resolve(nil, "main") -- 3308
	end) -- 3308
end -- 3282
local function emitCheckpointEventForAction(shared, action) -- 3313
	local result = action.result -- 3314
	if not result then -- 3314
		return -- 3315
	end -- 3315
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3315
		emitAgentEvent(shared, { -- 3320
			type = "checkpoint_created", -- 3321
			sessionId = shared.sessionId, -- 3322
			taskId = shared.taskId, -- 3323
			step = action.step, -- 3324
			tool = action.tool, -- 3325
			checkpointId = result.checkpointId, -- 3326
			checkpointSeq = result.checkpointSeq, -- 3327
			files = result.files -- 3328
		}) -- 3328
	end -- 3328
end -- 3313
local function sanitizeToolActionResultForHistory(action, result) -- 3483
	if action.tool == "read_file" then -- 3483
		return sanitizeReadResultForHistory(action.tool, result) -- 3485
	end -- 3485
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3485
		return sanitizeSearchResultForHistory(action.tool, result) -- 3488
	end -- 3488
	if action.tool == "glob_files" then -- 3488
		return sanitizeListFilesResultForHistory(result) -- 3491
	end -- 3491
	return result -- 3493
end -- 3483
local function canRunBatchActionInParallel(self, action) -- 3496
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 3497
end -- 3496
local BatchToolAction = __TS__Class() -- 3504
BatchToolAction.name = "BatchToolAction" -- 3504
__TS__ClassExtends(BatchToolAction, Node) -- 3504
function BatchToolAction.prototype.prep(self, shared) -- 3505
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3505
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3505
	end) -- 3505
end -- 3505
function BatchToolAction.prototype.exec(self, input) -- 3509
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3509
		local shared = input.shared -- 3510
		local preExecuted = shared.preExecutedResults -- 3511
		local allParallelSafe = #input.actions > 1 and __TS__ArrayEvery(input.actions, canRunBatchActionInParallel) -- 3512
		if not allParallelSafe then -- 3512
			do -- 3512
				local i = 0 -- 3514
				while i < #input.actions do -- 3514
					local action = input.actions[i + 1] -- 3515
					emitAgentStartEvent(shared, action) -- 3516
					local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3517
					action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3518
					action.result = sanitizeToolActionResultForHistory(action, result) -- 3519
					appendToolResultMessage(shared, action) -- 3520
					emitAgentFinishEvent(shared, action) -- 3521
					emitCheckpointEventForAction(shared, action) -- 3522
					persistHistoryState(shared) -- 3523
					if shared.stopToken.stopped then -- 3523
						break -- 3525
					end -- 3525
					i = i + 1 -- 3514
				end -- 3514
			end -- 3514
			return ____awaiter_resolve(nil, input.actions) -- 3514
		end -- 3514
		local preExecCount = #__TS__ArrayFilter( -- 3531
			input.actions, -- 3531
			function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 3531
		) -- 3531
		Log( -- 3532
			"Info", -- 3532
			(("[CodingAgent] batch read-only tools executing in parallel count=" .. tostring(#input.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3532
		) -- 3532
		do -- 3532
			local i = 0 -- 3533
			while i < #input.actions do -- 3533
				emitAgentStartEvent(shared, input.actions[i + 1]) -- 3534
				i = i + 1 -- 3533
			end -- 3533
		end -- 3533
		__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3536
			input.actions, -- 3536
			function(____, action) -- 3536
				return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3536
					if shared.stopToken.stopped then -- 3536
						action.result = { -- 3538
							success = false, -- 3538
							message = getCancelledReason(shared) -- 3538
						} -- 3538
						return ____awaiter_resolve(nil, action) -- 3538
					end -- 3538
					local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3541
					action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3542
					action.result = sanitizeToolActionResultForHistory(action, result) -- 3543
					return ____awaiter_resolve(nil, action) -- 3543
				end) -- 3543
			end -- 3536
		))) -- 3536
		do -- 3536
			local i = 0 -- 3546
			while i < #input.actions do -- 3546
				local action = input.actions[i + 1] -- 3547
				if not action.result then -- 3547
					action.result = {success = false, message = "tool did not produce a result"} -- 3549
				end -- 3549
				appendToolResultMessage(shared, action) -- 3551
				emitAgentFinishEvent(shared, action) -- 3552
				emitCheckpointEventForAction(shared, action) -- 3553
				i = i + 1 -- 3546
			end -- 3546
		end -- 3546
		persistHistoryState(shared) -- 3555
		return ____awaiter_resolve(nil, input.actions) -- 3555
	end) -- 3555
end -- 3509
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3559
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3559
		shared.pendingToolActions = nil -- 3560
		shared.preExecutedResults = nil -- 3561
		persistHistoryState(shared) -- 3562
		__TS__Await(maybeCompressHistory(shared)) -- 3563
		persistHistoryState(shared) -- 3564
		return ____awaiter_resolve(nil, "main") -- 3564
	end) -- 3564
end -- 3559
local EndNode = __TS__Class() -- 3569
EndNode.name = "EndNode" -- 3569
__TS__ClassExtends(EndNode, Node) -- 3569
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3570
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3570
		return ____awaiter_resolve(nil, nil) -- 3570
	end) -- 3570
end -- 3570
local CodingAgentFlow = __TS__Class() -- 3575
CodingAgentFlow.name = "CodingAgentFlow" -- 3575
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3575
function CodingAgentFlow.prototype.____constructor(self, role) -- 3576
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3577
	local read = __TS__New(ReadFileAction, 1, 0) -- 3578
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3579
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3580
	local list = __TS__New(ListFilesAction, 1, 0) -- 3581
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3582
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3583
	local build = __TS__New(BuildAction, 1, 0) -- 3584
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3585
	local edit = __TS__New(EditFileAction, 1, 0) -- 3586
	local batch = __TS__New(BatchToolAction, 1, 0) -- 3587
	local done = __TS__New(EndNode, 1, 0) -- 3588
	main:on("batch_tools", batch) -- 3590
	main:on("grep_files", search) -- 3591
	main:on("search_dora_api", searchDora) -- 3592
	main:on("glob_files", list) -- 3593
	if role == "main" then -- 3593
		main:on("read_file", read) -- 3595
		main:on("delete_file", del) -- 3596
		main:on("build", build) -- 3597
		main:on("edit_file", edit) -- 3598
		main:on("list_sub_agents", listSub) -- 3599
		main:on("spawn_sub_agent", spawn) -- 3600
	else -- 3600
		main:on("read_file", read) -- 3602
		main:on("delete_file", del) -- 3603
		main:on("build", build) -- 3604
		main:on("edit_file", edit) -- 3605
	end -- 3605
	main:on("done", done) -- 3607
	search:on("main", main) -- 3609
	searchDora:on("main", main) -- 3610
	list:on("main", main) -- 3611
	listSub:on("main", main) -- 3612
	spawn:on("main", main) -- 3613
	batch:on("main", main) -- 3614
	read:on("main", main) -- 3615
	del:on("main", main) -- 3616
	build:on("main", main) -- 3617
	edit:on("main", main) -- 3618
	Flow.prototype.____constructor(self, main) -- 3620
end -- 3576
local function runCodingAgentAsync(options) -- 3642
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3642
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3642
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3642
		end -- 3642
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3646
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3647
		if not llmConfigRes.success then -- 3647
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3647
		end -- 3647
		local llmConfig = llmConfigRes.config -- 3653
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3654
		if not taskRes.success then -- 3654
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3654
		end -- 3654
		local compressor = __TS__New(MemoryCompressor, { -- 3661
			compressionThreshold = 0.8, -- 3662
			compressionTargetThreshold = 0.5, -- 3663
			maxCompressionRounds = 3, -- 3664
			projectDir = options.workDir, -- 3665
			llmConfig = llmConfig, -- 3666
			promptPack = options.promptPack, -- 3667
			scope = options.memoryScope -- 3668
		}) -- 3668
		local persistedSession = compressor:getStorage():readSessionState() -- 3670
		local promptPack = compressor:getPromptPack() -- 3671
		local shared = { -- 3673
			sessionId = options.sessionId, -- 3674
			taskId = taskRes.taskId, -- 3675
			role = options.role or "main", -- 3676
			maxSteps = math.max( -- 3677
				1, -- 3677
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 3677
			), -- 3677
			llmMaxTry = math.max( -- 3678
				1, -- 3678
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 3678
			), -- 3678
			step = 0, -- 3679
			done = false, -- 3680
			stopToken = options.stopToken or ({stopped = false}), -- 3681
			response = "", -- 3682
			userQuery = normalizedPrompt, -- 3683
			workingDir = options.workDir, -- 3684
			useChineseResponse = options.useChineseResponse == true, -- 3685
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3686
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 3689
			llmConfig = llmConfig, -- 3690
			onEvent = options.onEvent, -- 3691
			promptPack = promptPack, -- 3692
			history = {}, -- 3693
			messages = persistedSession.messages, -- 3694
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 3695
			carryMessageIndex = persistedSession.carryMessageIndex, -- 3696
			memory = {compressor = compressor}, -- 3698
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 3702
			spawnSubAgent = options.spawnSubAgent, -- 3707
			listSubAgents = options.listSubAgents -- 3708
		} -- 3708
		local ____try = __TS__AsyncAwaiter(function() -- 3708
			emitAgentEvent(shared, { -- 3712
				type = "task_started", -- 3713
				sessionId = shared.sessionId, -- 3714
				taskId = shared.taskId, -- 3715
				prompt = shared.userQuery, -- 3716
				workDir = shared.workingDir, -- 3717
				maxSteps = shared.maxSteps -- 3718
			}) -- 3718
			if shared.stopToken.stopped then -- 3718
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3721
				return ____awaiter_resolve( -- 3721
					nil, -- 3721
					emitAgentTaskFinishEvent( -- 3722
						shared, -- 3722
						false, -- 3722
						getCancelledReason(shared) -- 3722
					) -- 3722
				) -- 3722
			end -- 3722
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3724
			local promptCommand = getPromptCommand(shared.userQuery) -- 3725
			if promptCommand == "clear" then -- 3725
				return ____awaiter_resolve( -- 3725
					nil, -- 3725
					clearSessionHistory(shared) -- 3727
				) -- 3727
			end -- 3727
			if promptCommand == "compact" then -- 3727
				if shared.role == "sub" then -- 3727
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 3731
					return ____awaiter_resolve( -- 3731
						nil, -- 3731
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 3732
					) -- 3732
				end -- 3732
				return ____awaiter_resolve( -- 3732
					nil, -- 3732
					__TS__Await(compactAllHistory(shared)) -- 3740
				) -- 3740
			end -- 3740
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3742
			persistHistoryState(shared) -- 3746
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3747
			__TS__Await(flow:run(shared)) -- 3748
			if shared.stopToken.stopped then -- 3748
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3750
				return ____awaiter_resolve( -- 3750
					nil, -- 3750
					emitAgentTaskFinishEvent( -- 3751
						shared, -- 3751
						false, -- 3751
						getCancelledReason(shared) -- 3751
					) -- 3751
				) -- 3751
			end -- 3751
			if shared.error then -- 3751
				return ____awaiter_resolve( -- 3751
					nil, -- 3751
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3754
				) -- 3754
			end -- 3754
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3757
			return ____awaiter_resolve( -- 3757
				nil, -- 3757
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3758
			) -- 3758
		end) -- 3758
		__TS__Await(____try.catch( -- 3711
			____try, -- 3711
			function(____, e) -- 3711
				return ____awaiter_resolve( -- 3711
					nil, -- 3711
					finalizeAgentFailure( -- 3761
						shared, -- 3761
						tostring(e) -- 3761
					) -- 3761
				) -- 3761
			end -- 3761
		)) -- 3761
	end) -- 3761
end -- 3642
function ____exports.runCodingAgent(options, callback) -- 3765
	local ____self_136 = runCodingAgentAsync(options) -- 3765
	____self_136["then"]( -- 3765
		____self_136, -- 3765
		function(____, result) return callback(result) end -- 3766
	) -- 3766
end -- 3765
return ____exports -- 3765