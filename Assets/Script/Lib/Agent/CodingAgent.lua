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
function buildXmlDecisionInstruction(shared, feedback) -- 2212
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2213
end -- 2213
function executeToolAction(shared, action) -- 3394
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3394
		if shared.stopToken.stopped then -- 3394
			return ____awaiter_resolve( -- 3394
				nil, -- 3394
				{ -- 3396
					success = false, -- 3396
					message = getCancelledReason(shared) -- 3396
				} -- 3396
			) -- 3396
		end -- 3396
		local params = action.params -- 3398
		if action.tool == "read_file" then -- 3398
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3400
			if __TS__StringTrim(path) == "" then -- 3400
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3400
			end -- 3400
			local ____Tools_readFile_104 = Tools.readFile -- 3404
			local ____shared_workingDir_102 = shared.workingDir -- 3405
			local ____params_startLine_100 = params.startLine -- 3407
			if ____params_startLine_100 == nil then -- 3407
				____params_startLine_100 = 1 -- 3407
			end -- 3407
			local ____TS__Number_result_103 = __TS__Number(____params_startLine_100) -- 3407
			local ____params_endLine_101 = params.endLine -- 3408
			if ____params_endLine_101 == nil then -- 3408
				____params_endLine_101 = READ_FILE_DEFAULT_LIMIT -- 3408
			end -- 3408
			return ____awaiter_resolve( -- 3408
				nil, -- 3408
				____Tools_readFile_104( -- 3404
					____shared_workingDir_102, -- 3405
					path, -- 3406
					____TS__Number_result_103, -- 3407
					__TS__Number(____params_endLine_101), -- 3408
					shared.useChineseResponse and "zh" or "en" -- 3409
				) -- 3409
			) -- 3409
		end -- 3409
		if action.tool == "grep_files" then -- 3409
			local ____Tools_searchFiles_118 = Tools.searchFiles -- 3413
			local ____shared_workingDir_111 = shared.workingDir -- 3414
			local ____temp_112 = params.path or "" -- 3415
			local ____temp_113 = params.pattern or "" -- 3416
			local ____params_globs_114 = params.globs -- 3417
			local ____params_useRegex_115 = params.useRegex -- 3418
			local ____params_caseSensitive_116 = params.caseSensitive -- 3419
			local ____math_max_107 = math.max -- 3422
			local ____math_floor_106 = math.floor -- 3422
			local ____params_limit_105 = params.limit -- 3422
			if ____params_limit_105 == nil then -- 3422
				____params_limit_105 = SEARCH_FILES_LIMIT_DEFAULT -- 3422
			end -- 3422
			local ____math_max_107_result_117 = ____math_max_107( -- 3422
				1, -- 3422
				____math_floor_106(__TS__Number(____params_limit_105)) -- 3422
			) -- 3422
			local ____math_max_110 = math.max -- 3423
			local ____math_floor_109 = math.floor -- 3423
			local ____params_offset_108 = params.offset -- 3423
			if ____params_offset_108 == nil then -- 3423
				____params_offset_108 = 0 -- 3423
			end -- 3423
			local result = __TS__Await(____Tools_searchFiles_118({ -- 3413
				workDir = ____shared_workingDir_111, -- 3414
				path = ____temp_112, -- 3415
				pattern = ____temp_113, -- 3416
				globs = ____params_globs_114, -- 3417
				useRegex = ____params_useRegex_115, -- 3418
				caseSensitive = ____params_caseSensitive_116, -- 3419
				includeContent = true, -- 3420
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3421
				limit = ____math_max_107_result_117, -- 3422
				offset = ____math_max_110( -- 3423
					0, -- 3423
					____math_floor_109(__TS__Number(____params_offset_108)) -- 3423
				), -- 3423
				groupByFile = params.groupByFile == true -- 3424
			})) -- 3424
			return ____awaiter_resolve(nil, result) -- 3424
		end -- 3424
		if action.tool == "search_dora_api" then -- 3424
			local ____Tools_searchDoraAPI_126 = Tools.searchDoraAPI -- 3429
			local ____temp_122 = params.pattern or "" -- 3430
			local ____temp_123 = params.docSource or "api" -- 3431
			local ____temp_124 = shared.useChineseResponse and "zh" or "en" -- 3432
			local ____temp_125 = params.programmingLanguage or "ts" -- 3433
			local ____math_min_121 = math.min -- 3434
			local ____math_max_120 = math.max -- 3434
			local ____params_limit_119 = params.limit -- 3434
			if ____params_limit_119 == nil then -- 3434
				____params_limit_119 = 8 -- 3434
			end -- 3434
			local result = __TS__Await(____Tools_searchDoraAPI_126({ -- 3429
				pattern = ____temp_122, -- 3430
				docSource = ____temp_123, -- 3431
				docLanguage = ____temp_124, -- 3432
				programmingLanguage = ____temp_125, -- 3433
				limit = ____math_min_121( -- 3434
					SEARCH_DORA_API_LIMIT_MAX, -- 3434
					____math_max_120( -- 3434
						1, -- 3434
						__TS__Number(____params_limit_119) -- 3434
					) -- 3434
				), -- 3434
				useRegex = params.useRegex, -- 3435
				caseSensitive = false, -- 3436
				includeContent = true, -- 3437
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3438
			})) -- 3438
			return ____awaiter_resolve(nil, result) -- 3438
		end -- 3438
		if action.tool == "glob_files" then -- 3438
			local ____Tools_listFiles_133 = Tools.listFiles -- 3443
			local ____shared_workingDir_130 = shared.workingDir -- 3444
			local ____temp_131 = params.path or "" -- 3445
			local ____params_globs_132 = params.globs -- 3446
			local ____math_max_129 = math.max -- 3447
			local ____math_floor_128 = math.floor -- 3447
			local ____params_maxEntries_127 = params.maxEntries -- 3447
			if ____params_maxEntries_127 == nil then -- 3447
				____params_maxEntries_127 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3447
			end -- 3447
			local result = ____Tools_listFiles_133({ -- 3443
				workDir = ____shared_workingDir_130, -- 3444
				path = ____temp_131, -- 3445
				globs = ____params_globs_132, -- 3446
				maxEntries = ____math_max_129( -- 3447
					1, -- 3447
					____math_floor_128(__TS__Number(____params_maxEntries_127)) -- 3447
				) -- 3447
			}) -- 3447
			return ____awaiter_resolve(nil, result) -- 3447
		end -- 3447
		if action.tool == "delete_file" then -- 3447
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3452
			if __TS__StringTrim(targetFile) == "" then -- 3452
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3452
			end -- 3452
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3456
			if not result.success then -- 3456
				return ____awaiter_resolve(nil, result) -- 3456
			end -- 3456
			return ____awaiter_resolve(nil, { -- 3456
				success = true, -- 3464
				changed = true, -- 3465
				mode = "delete", -- 3466
				checkpointId = result.checkpointId, -- 3467
				checkpointSeq = result.checkpointSeq, -- 3468
				files = {{path = targetFile, op = "delete"}} -- 3469
			}) -- 3469
		end -- 3469
		if action.tool == "build" then -- 3469
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3473
			return ____awaiter_resolve(nil, result) -- 3473
		end -- 3473
		if action.tool == "spawn_sub_agent" then -- 3473
			if not shared.spawnSubAgent then -- 3473
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3473
			end -- 3473
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3473
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3473
			end -- 3473
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3486
				params.filesHint, -- 3487
				function(____, item) return type(item) == "string" end -- 3487
			) or nil -- 3487
			local result = __TS__Await(shared.spawnSubAgent({ -- 3489
				parentSessionId = shared.sessionId, -- 3490
				projectRoot = shared.workingDir, -- 3491
				title = type(params.title) == "string" and params.title or "Sub", -- 3492
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3493
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3494
				filesHint = filesHint -- 3495
			})) -- 3495
			if not result.success then -- 3495
				return ____awaiter_resolve(nil, result) -- 3495
			end -- 3495
			return ____awaiter_resolve(nil, { -- 3495
				success = true, -- 3501
				sessionId = result.sessionId, -- 3502
				taskId = result.taskId, -- 3503
				title = result.title, -- 3504
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3505
			}) -- 3505
		end -- 3505
		if action.tool == "list_sub_agents" then -- 3505
			if not shared.listSubAgents then -- 3505
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3505
			end -- 3505
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3505
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3505
			end -- 3505
			local result = __TS__Await(shared.listSubAgents({ -- 3515
				sessionId = shared.sessionId, -- 3516
				projectRoot = shared.workingDir, -- 3517
				status = type(params.status) == "string" and params.status or nil, -- 3518
				limit = type(params.limit) == "number" and params.limit or nil, -- 3519
				offset = type(params.offset) == "number" and params.offset or nil, -- 3520
				query = type(params.query) == "string" and params.query or nil -- 3521
			})) -- 3521
			return ____awaiter_resolve(nil, result) -- 3521
		end -- 3521
		if action.tool == "edit_file" then -- 3521
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3526
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3529
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3530
			if __TS__StringTrim(path) == "" then -- 3530
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3530
			end -- 3530
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3532
			return ____awaiter_resolve( -- 3532
				nil, -- 3532
				actionNode:exec({ -- 3533
					path = path, -- 3534
					oldStr = oldStr, -- 3535
					newStr = newStr, -- 3536
					taskId = shared.taskId, -- 3537
					workDir = shared.workingDir -- 3538
				}) -- 3538
			) -- 3538
		end -- 3538
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3538
	end) -- 3538
end -- 3538
function emitAgentTaskFinishEvent(shared, success, message) -- 3721
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3722
	emitAgentEvent(shared, { -- 3728
		type = "task_finished", -- 3729
		sessionId = shared.sessionId, -- 3730
		taskId = shared.taskId, -- 3731
		success = result.success, -- 3732
		message = result.message, -- 3733
		steps = result.steps -- 3734
	}) -- 3734
	return result -- 3736
end -- 3736
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
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2182
	if attempt == nil then -- 2182
		attempt = 1 -- 2185
	end -- 2185
	if decisionMode == nil then -- 2185
		decisionMode = shared.decisionMode -- 2187
	end -- 2187
	local messages = { -- 2189
		{ -- 2190
			role = "system", -- 2190
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2190
		}, -- 2190
		table.unpack(getUnconsolidatedMessages(shared)) -- 2191
	} -- 2191
	if shared.step + 1 >= shared.maxSteps then -- 2191
		messages = appendPromptToLatestDecisionMessage( -- 2194
			messages, -- 2194
			getFinalDecisionTurnPrompt(shared) -- 2194
		) -- 2194
	end -- 2194
	if lastError and lastError ~= "" then -- 2194
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2197
		messages[#messages + 1] = { -- 2200
			role = "user", -- 2201
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2202
		} -- 2202
	end -- 2202
	return messages -- 2209
end -- 2182
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2216
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2223
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2224
	local repairPrompt = replacePromptVars( -- 2232
		shared.promptPack.xmlDecisionRepairPrompt, -- 2232
		{ -- 2232
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2233
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2234
			CANDIDATE_SECTION = candidateSection, -- 2235
			LAST_ERROR = lastError, -- 2236
			ATTEMPT = tostring(attempt) -- 2237
		} -- 2237
	) -- 2237
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2239
end -- 2216
local function tryParseAndValidateDecision(rawText) -- 2251
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2252
	if not parsed.success then -- 2252
		return {success = false, message = parsed.message, raw = rawText} -- 2254
	end -- 2254
	local decision = parseDecisionObject(parsed.obj) -- 2256
	if not decision.success then -- 2256
		return {success = false, message = decision.message, raw = rawText} -- 2258
	end -- 2258
	local validation = validateDecision(decision.tool, decision.params) -- 2260
	if not validation.success then -- 2260
		return {success = false, message = validation.message, raw = rawText} -- 2262
	end -- 2262
	decision.params = validation.params -- 2264
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2265
	return decision -- 2266
end -- 2251
local function normalizeLineEndings(text) -- 2269
	local res = string.gsub(text, "\r\n", "\n") -- 2270
	res = string.gsub(res, "\r", "\n") -- 2271
	return res -- 2272
end -- 2269
local function countOccurrences(text, searchStr) -- 2275
	if searchStr == "" then -- 2275
		return 0 -- 2276
	end -- 2276
	local count = 0 -- 2277
	local pos = 0 -- 2278
	while true do -- 2278
		local idx = (string.find( -- 2280
			text, -- 2280
			searchStr, -- 2280
			math.max(pos + 1, 1), -- 2280
			true -- 2280
		) or 0) - 1 -- 2280
		if idx < 0 then -- 2280
			break -- 2281
		end -- 2281
		count = count + 1 -- 2282
		pos = idx + #searchStr -- 2283
	end -- 2283
	return count -- 2285
end -- 2275
local function replaceFirst(text, oldStr, newStr) -- 2288
	if oldStr == "" then -- 2288
		return text -- 2289
	end -- 2289
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2290
	if idx < 0 then -- 2290
		return text -- 2291
	end -- 2291
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2292
end -- 2288
local function splitLines(text) -- 2295
	return __TS__StringSplit(text, "\n") -- 2296
end -- 2295
local function getLeadingWhitespace(text) -- 2299
	local i = 0 -- 2300
	while i < #text do -- 2300
		local ch = __TS__StringAccess(text, i) -- 2302
		if ch ~= " " and ch ~= "\t" then -- 2302
			break -- 2303
		end -- 2303
		i = i + 1 -- 2304
	end -- 2304
	return __TS__StringSubstring(text, 0, i) -- 2306
end -- 2299
local function getCommonIndentPrefix(lines) -- 2309
	local common -- 2310
	do -- 2310
		local i = 0 -- 2311
		while i < #lines do -- 2311
			do -- 2311
				local line = lines[i + 1] -- 2312
				if __TS__StringTrim(line) == "" then -- 2312
					goto __continue373 -- 2313
				end -- 2313
				local indent = getLeadingWhitespace(line) -- 2314
				if common == nil then -- 2314
					common = indent -- 2316
					goto __continue373 -- 2317
				end -- 2317
				local j = 0 -- 2319
				local maxLen = math.min(#common, #indent) -- 2320
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2320
					j = j + 1 -- 2322
				end -- 2322
				common = __TS__StringSubstring(common, 0, j) -- 2324
				if common == "" then -- 2324
					break -- 2325
				end -- 2325
			end -- 2325
			::__continue373:: -- 2325
			i = i + 1 -- 2311
		end -- 2311
	end -- 2311
	return common or "" -- 2327
end -- 2309
local function removeIndentPrefix(line, indent) -- 2330
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2330
		return __TS__StringSubstring(line, #indent) -- 2332
	end -- 2332
	local lineIndent = getLeadingWhitespace(line) -- 2334
	local j = 0 -- 2335
	local maxLen = math.min(#lineIndent, #indent) -- 2336
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2336
		j = j + 1 -- 2338
	end -- 2338
	return __TS__StringSubstring(line, j) -- 2340
end -- 2330
local function dedentLines(lines) -- 2343
	local indent = getCommonIndentPrefix(lines) -- 2344
	return { -- 2345
		indent = indent, -- 2346
		lines = __TS__ArrayMap( -- 2347
			lines, -- 2347
			function(____, line) return removeIndentPrefix(line, indent) end -- 2347
		) -- 2347
	} -- 2347
end -- 2343
local function joinLines(lines) -- 2351
	return table.concat(lines, "\n") -- 2352
end -- 2351
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2355
	local contentLines = splitLines(content) -- 2360
	local oldLines = splitLines(oldStr) -- 2361
	if #oldLines == 0 then -- 2361
		return {success = false, message = "old_str not found in file"} -- 2363
	end -- 2363
	local dedentedOld = dedentLines(oldLines) -- 2365
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2366
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2367
	local matches = {} -- 2368
	do -- 2368
		local start = 0 -- 2369
		while start <= #contentLines - #oldLines do -- 2369
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2370
			local dedentedCandidate = dedentLines(candidateLines) -- 2371
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2371
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2373
			end -- 2373
			start = start + 1 -- 2369
		end -- 2369
	end -- 2369
	if #matches == 0 then -- 2369
		return {success = false, message = "old_str not found in file"} -- 2381
	end -- 2381
	if #matches > 1 then -- 2381
		return { -- 2384
			success = false, -- 2385
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2386
		} -- 2386
	end -- 2386
	local match = matches[1] -- 2389
	local rebuiltNewLines = __TS__ArrayMap( -- 2390
		dedentedNew.lines, -- 2390
		function(____, line) return line == "" and "" or match.indent .. line end -- 2390
	) -- 2390
	local ____array_46 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2390
	__TS__SparseArrayPush( -- 2390
		____array_46, -- 2390
		table.unpack(rebuiltNewLines) -- 2393
	) -- 2393
	__TS__SparseArrayPush( -- 2393
		____array_46, -- 2393
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2394
	) -- 2394
	local nextLines = {__TS__SparseArraySpread(____array_46)} -- 2391
	return { -- 2396
		success = true, -- 2396
		content = joinLines(nextLines) -- 2396
	} -- 2396
end -- 2355
local MainDecisionAgent = __TS__Class() -- 2399
MainDecisionAgent.name = "MainDecisionAgent" -- 2399
__TS__ClassExtends(MainDecisionAgent, Node) -- 2399
function MainDecisionAgent.prototype.prep(self, shared) -- 2400
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2400
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2400
			return ____awaiter_resolve(nil, {shared = shared}) -- 2400
		end -- 2400
		__TS__Await(maybeCompressHistory(shared)) -- 2405
		return ____awaiter_resolve(nil, {shared = shared}) -- 2405
	end) -- 2405
end -- 2400
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2410
	if attempt == nil then -- 2410
		attempt = 1 -- 2413
	end -- 2413
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2413
		if shared.stopToken.stopped then -- 2413
			return ____awaiter_resolve( -- 2413
				nil, -- 2413
				{ -- 2417
					success = false, -- 2417
					message = getCancelledReason(shared) -- 2417
				} -- 2417
			) -- 2417
		end -- 2417
		Log( -- 2419
			"Info", -- 2419
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2419
		) -- 2419
		local tools = buildDecisionToolSchema(shared) -- 2420
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2421
		local stepId = shared.step + 1 -- 2422
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2423
		saveStepLLMDebugInput( -- 2427
			shared, -- 2427
			stepId, -- 2427
			"decision_tool_calling", -- 2427
			messages, -- 2427
			llmOptions -- 2427
		) -- 2427
		local lastStreamContent = "" -- 2428
		local lastStreamReasoning = "" -- 2429
		local preExecutedResults = __TS__New(Map) -- 2430
		shared.preExecutedResults = preExecutedResults -- 2431
		local res = __TS__Await(callLLMStreamAggregated( -- 2432
			messages, -- 2433
			llmOptions, -- 2434
			shared.stopToken, -- 2435
			shared.llmConfig, -- 2436
			function(response) -- 2437
				local ____opt_49 = response.choices -- 2437
				local ____opt_47 = ____opt_49 and ____opt_49[1] -- 2437
				local streamMessage = ____opt_47 and ____opt_47.message -- 2438
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2439
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2442
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2442
					return -- 2446
				end -- 2446
				lastStreamContent = nextContent -- 2448
				lastStreamReasoning = nextReasoning -- 2449
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2450
			end, -- 2437
			function(tc) -- 2452
				if shared.stopToken.stopped then -- 2452
					return -- 2453
				end -- 2453
				local action = createPreExecutableActionFromStream(shared, tc) -- 2454
				if not action or preExecutedResults:has(action.toolCallId) then -- 2454
					return -- 2455
				end -- 2455
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2456
				preExecutedResults:set( -- 2457
					action.toolCallId, -- 2457
					startPreExecutedToolAction(shared, action) -- 2457
				) -- 2457
			end -- 2452
		)) -- 2452
		if shared.stopToken.stopped then -- 2452
			clearPreExecutedResults(shared) -- 2461
			return ____awaiter_resolve( -- 2461
				nil, -- 2461
				{ -- 2462
					success = false, -- 2462
					message = getCancelledReason(shared) -- 2462
				} -- 2462
			) -- 2462
		end -- 2462
		if not res.success then -- 2462
			saveStepLLMDebugOutput( -- 2465
				shared, -- 2465
				stepId, -- 2465
				"decision_tool_calling", -- 2465
				res.raw or res.message, -- 2465
				{success = false} -- 2465
			) -- 2465
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2466
			clearPreExecutedResults(shared) -- 2467
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2467
		end -- 2467
		saveStepLLMDebugOutput( -- 2470
			shared, -- 2470
			stepId, -- 2470
			"decision_tool_calling", -- 2470
			encodeDebugJSON(res.response), -- 2470
			{success = true} -- 2470
		) -- 2470
		local choice = res.response.choices and res.response.choices[1] -- 2471
		local message = choice and choice.message -- 2472
		local toolCalls = message and message.tool_calls -- 2473
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2474
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2477
		Log( -- 2480
			"Info", -- 2480
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2480
		) -- 2480
		if not toolCalls or #toolCalls == 0 then -- 2480
			if messageContent and messageContent ~= "" then -- 2480
				Log( -- 2483
					"Info", -- 2483
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2483
				) -- 2483
				clearPreExecutedResults(shared) -- 2484
				return ____awaiter_resolve(nil, { -- 2484
					success = true, -- 2486
					tool = "finish", -- 2487
					params = {}, -- 2488
					reason = messageContent, -- 2489
					reasoningContent = reasoningContent, -- 2490
					directSummary = messageContent -- 2491
				}) -- 2491
			end -- 2491
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2494
			clearPreExecutedResults(shared) -- 2495
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2495
		end -- 2495
		local decisions = {} -- 2502
		do -- 2502
			local i = 0 -- 2503
			while i < #toolCalls do -- 2503
				local toolCall = toolCalls[i + 1] -- 2504
				local fn = toolCall and toolCall["function"] -- 2505
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2505
					Log( -- 2507
						"Error", -- 2507
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2507
					) -- 2507
					clearPreExecutedResults(shared) -- 2508
					return ____awaiter_resolve( -- 2508
						nil, -- 2508
						{ -- 2509
							success = false, -- 2510
							message = "missing function name for tool call " .. tostring(i + 1), -- 2511
							raw = messageContent -- 2512
						} -- 2512
					) -- 2512
				end -- 2512
				local functionName = fn.name -- 2515
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2516
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2517
				Log( -- 2520
					"Info", -- 2520
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2520
				) -- 2520
				local decision = parseAndValidateToolCallDecision( -- 2521
					shared, -- 2522
					functionName, -- 2523
					argsText, -- 2524
					toolCallId, -- 2525
					messageContent, -- 2526
					reasoningContent -- 2527
				) -- 2527
				if not decision.success then -- 2527
					Log( -- 2530
						"Error", -- 2530
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2530
					) -- 2530
					clearPreExecutedResults(shared) -- 2531
					return ____awaiter_resolve(nil, decision) -- 2531
				end -- 2531
				decisions[#decisions + 1] = decision -- 2534
				i = i + 1 -- 2503
			end -- 2503
		end -- 2503
		if #decisions == 1 then -- 2503
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2537
			return ____awaiter_resolve(nil, decisions[1]) -- 2537
		end -- 2537
		do -- 2537
			local i = 0 -- 2540
			while i < #decisions do -- 2540
				if decisions[i + 1].tool == "finish" then -- 2540
					clearPreExecutedResults(shared) -- 2542
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2542
				end -- 2542
				i = i + 1 -- 2540
			end -- 2540
		end -- 2540
		Log( -- 2550
			"Info", -- 2550
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2550
				__TS__ArrayMap( -- 2550
					decisions, -- 2550
					function(____, decision) return decision.tool end -- 2550
				), -- 2550
				"," -- 2550
			) -- 2550
		) -- 2550
		return ____awaiter_resolve(nil, { -- 2550
			success = true, -- 2552
			kind = "batch", -- 2553
			decisions = decisions, -- 2554
			content = messageContent, -- 2555
			reasoningContent = reasoningContent -- 2556
		}) -- 2556
	end) -- 2556
end -- 2410
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2560
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2560
		Log( -- 2565
			"Info", -- 2565
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2565
		) -- 2565
		local lastError = initialError -- 2566
		local candidateRaw = "" -- 2567
		do -- 2567
			local attempt = 0 -- 2568
			while attempt < shared.llmMaxTry do -- 2568
				do -- 2568
					Log( -- 2569
						"Info", -- 2569
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2569
					) -- 2569
					local messages = buildXmlRepairMessages( -- 2570
						shared, -- 2571
						originalRaw, -- 2572
						candidateRaw, -- 2573
						lastError, -- 2574
						attempt + 1 -- 2575
					) -- 2575
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2577
					if shared.stopToken.stopped then -- 2577
						return ____awaiter_resolve( -- 2577
							nil, -- 2577
							{ -- 2579
								success = false, -- 2579
								message = getCancelledReason(shared) -- 2579
							} -- 2579
						) -- 2579
					end -- 2579
					if not llmRes.success then -- 2579
						lastError = llmRes.message -- 2582
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2583
						goto __continue416 -- 2584
					end -- 2584
					candidateRaw = llmRes.text -- 2586
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2587
					if decision.success then -- 2587
						decision.reasoningContent = llmRes.reasoningContent -- 2589
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2590
						return ____awaiter_resolve(nil, decision) -- 2590
					end -- 2590
					lastError = decision.message -- 2593
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2594
				end -- 2594
				::__continue416:: -- 2594
				attempt = attempt + 1 -- 2568
			end -- 2568
		end -- 2568
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2596
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2596
	end) -- 2596
end -- 2560
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2604
	if attempt == nil then -- 2604
		attempt = 1 -- 2607
	end -- 2607
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2607
		local messages = buildDecisionMessages( -- 2610
			shared, -- 2611
			lastError, -- 2612
			attempt, -- 2613
			lastRaw, -- 2614
			"xml" -- 2615
		) -- 2615
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2617
		if shared.stopToken.stopped then -- 2617
			return ____awaiter_resolve( -- 2617
				nil, -- 2617
				{ -- 2619
					success = false, -- 2619
					message = getCancelledReason(shared) -- 2619
				} -- 2619
			) -- 2619
		end -- 2619
		if not llmRes.success then -- 2619
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2619
		end -- 2619
		local decision = tryParseAndValidateDecision(llmRes.text) -- 2628
		if decision.success then -- 2628
			decision.reasoningContent = llmRes.reasoningContent -- 2630
			if not isToolAllowedForRole(shared.role, decision.tool) then -- 2630
				return ____awaiter_resolve( -- 2630
					nil, -- 2630
					self:repairDecisionXml(shared, llmRes.text, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2632
				) -- 2632
			end -- 2632
			return ____awaiter_resolve(nil, decision) -- 2632
		end -- 2632
		return ____awaiter_resolve( -- 2632
			nil, -- 2632
			self:repairDecisionXml(shared, llmRes.text, decision.message) -- 2640
		) -- 2640
	end) -- 2640
end -- 2604
function MainDecisionAgent.prototype.exec(self, input) -- 2643
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2643
		local shared = input.shared -- 2644
		if shared.stopToken.stopped then -- 2644
			return ____awaiter_resolve( -- 2644
				nil, -- 2644
				{ -- 2646
					success = false, -- 2646
					message = getCancelledReason(shared) -- 2646
				} -- 2646
			) -- 2646
		end -- 2646
		if shared.step >= shared.maxSteps then -- 2646
			Log( -- 2649
				"Warn", -- 2649
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2649
			) -- 2649
			return ____awaiter_resolve( -- 2649
				nil, -- 2649
				{ -- 2650
					success = false, -- 2650
					message = getMaxStepsReachedReason(shared) -- 2650
				} -- 2650
			) -- 2650
		end -- 2650
		if shared.decisionMode == "tool_calling" then -- 2650
			Log( -- 2654
				"Info", -- 2654
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2654
			) -- 2654
			local lastError = "tool calling validation failed" -- 2655
			local lastRaw = "" -- 2656
			local shouldFallbackToXml = false -- 2657
			do -- 2657
				local attempt = 0 -- 2658
				while attempt < shared.llmMaxTry do -- 2658
					Log( -- 2659
						"Info", -- 2659
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2659
					) -- 2659
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2660
					if shared.stopToken.stopped then -- 2660
						return ____awaiter_resolve( -- 2660
							nil, -- 2660
							{ -- 2667
								success = false, -- 2667
								message = getCancelledReason(shared) -- 2667
							} -- 2667
						) -- 2667
					end -- 2667
					if decision.success then -- 2667
						return ____awaiter_resolve(nil, decision) -- 2667
					end -- 2667
					lastError = decision.message -- 2672
					lastRaw = decision.raw or "" -- 2673
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2674
					if lastError == "missing tool call" then -- 2674
						shouldFallbackToXml = true -- 2676
						break -- 2677
					end -- 2677
					attempt = attempt + 1 -- 2658
				end -- 2658
			end -- 2658
			if shouldFallbackToXml then -- 2658
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 2681
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 2682
				do -- 2682
					local attempt = 0 -- 2683
					while attempt < shared.llmMaxTry do -- 2683
						Log( -- 2684
							"Info", -- 2684
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 2684
						) -- 2684
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 2685
						if shared.stopToken.stopped then -- 2685
							return ____awaiter_resolve( -- 2685
								nil, -- 2685
								{ -- 2692
									success = false, -- 2692
									message = getCancelledReason(shared) -- 2692
								} -- 2692
							) -- 2692
						end -- 2692
						if decision.success then -- 2692
							return ____awaiter_resolve(nil, decision) -- 2692
						end -- 2692
						lastError = decision.message -- 2697
						lastRaw = decision.raw or "" -- 2698
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 2699
						attempt = attempt + 1 -- 2683
					end -- 2683
				end -- 2683
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 2701
				return ____awaiter_resolve( -- 2701
					nil, -- 2701
					{ -- 2702
						success = false, -- 2702
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2702
					} -- 2702
				) -- 2702
			end -- 2702
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2704
			return ____awaiter_resolve( -- 2704
				nil, -- 2704
				{ -- 2705
					success = false, -- 2705
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2705
				} -- 2705
			) -- 2705
		end -- 2705
		local lastError = "xml validation failed" -- 2708
		local lastRaw = "" -- 2709
		do -- 2709
			local attempt = 0 -- 2710
			while attempt < shared.llmMaxTry do -- 2710
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 2711
				if shared.stopToken.stopped then -- 2711
					return ____awaiter_resolve( -- 2711
						nil, -- 2711
						{ -- 2720
							success = false, -- 2720
							message = getCancelledReason(shared) -- 2720
						} -- 2720
					) -- 2720
				end -- 2720
				if decision.success then -- 2720
					return ____awaiter_resolve(nil, decision) -- 2720
				end -- 2720
				lastError = decision.message -- 2725
				lastRaw = decision.raw or "" -- 2726
				attempt = attempt + 1 -- 2710
			end -- 2710
		end -- 2710
		return ____awaiter_resolve( -- 2710
			nil, -- 2710
			{ -- 2728
				success = false, -- 2728
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2728
			} -- 2728
		) -- 2728
	end) -- 2728
end -- 2643
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2731
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2731
		local result = execRes -- 2732
		if not result.success then -- 2732
			if shared.stopToken.stopped then -- 2732
				shared.error = getCancelledReason(shared) -- 2735
				shared.done = true -- 2736
				return ____awaiter_resolve(nil, "done") -- 2736
			end -- 2736
			shared.error = result.message -- 2739
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2740
			shared.done = true -- 2741
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2742
			persistHistoryState(shared) -- 2746
			return ____awaiter_resolve(nil, "done") -- 2746
		end -- 2746
		if isDecisionBatchSuccess(result) then -- 2746
			local startStep = shared.step -- 2750
			local actions = {} -- 2751
			do -- 2751
				local i = 0 -- 2752
				while i < #result.decisions do -- 2752
					local decision = result.decisions[i + 1] -- 2753
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2754
					local step = startStep + i + 1 -- 2755
					local ____temp_55 -- 2756
					if i == 0 then -- 2756
						____temp_55 = decision.reason -- 2756
					else -- 2756
						____temp_55 = "" -- 2756
					end -- 2756
					local actionReason = ____temp_55 -- 2756
					local ____temp_56 -- 2757
					if i == 0 then -- 2757
						____temp_56 = decision.reasoningContent -- 2757
					else -- 2757
						____temp_56 = nil -- 2757
					end -- 2757
					local actionReasoningContent = ____temp_56 -- 2757
					emitAgentEvent(shared, { -- 2758
						type = "decision_made", -- 2759
						sessionId = shared.sessionId, -- 2760
						taskId = shared.taskId, -- 2761
						step = step, -- 2762
						tool = decision.tool, -- 2763
						reason = actionReason, -- 2764
						reasoningContent = actionReasoningContent, -- 2765
						params = decision.params -- 2766
					}) -- 2766
					local action = { -- 2768
						step = step, -- 2769
						toolCallId = toolCallId, -- 2770
						tool = decision.tool, -- 2771
						reason = actionReason or "", -- 2772
						reasoningContent = actionReasoningContent, -- 2773
						params = decision.params, -- 2774
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2775
					} -- 2775
					local ____shared_history_57 = shared.history -- 2775
					____shared_history_57[#____shared_history_57 + 1] = action -- 2777
					actions[#actions + 1] = action -- 2778
					i = i + 1 -- 2752
				end -- 2752
			end -- 2752
			shared.step = startStep + #actions -- 2780
			shared.pendingToolActions = actions -- 2781
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2782
			persistHistoryState(shared) -- 2788
			return ____awaiter_resolve(nil, "batch_tools") -- 2788
		end -- 2788
		if result.directSummary and result.directSummary ~= "" then -- 2788
			shared.response = result.directSummary -- 2792
			shared.done = true -- 2793
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2794
			persistHistoryState(shared) -- 2799
			return ____awaiter_resolve(nil, "done") -- 2799
		end -- 2799
		if result.tool == "finish" then -- 2799
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2803
			shared.response = finalMessage -- 2804
			shared.done = true -- 2805
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2806
			persistHistoryState(shared) -- 2811
			return ____awaiter_resolve(nil, "done") -- 2811
		end -- 2811
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2814
		shared.step = shared.step + 1 -- 2815
		local step = shared.step -- 2816
		emitAgentEvent(shared, { -- 2817
			type = "decision_made", -- 2818
			sessionId = shared.sessionId, -- 2819
			taskId = shared.taskId, -- 2820
			step = step, -- 2821
			tool = result.tool, -- 2822
			reason = result.reason, -- 2823
			reasoningContent = result.reasoningContent, -- 2824
			params = result.params -- 2825
		}) -- 2825
		local ____shared_history_58 = shared.history -- 2825
		____shared_history_58[#____shared_history_58 + 1] = { -- 2827
			step = step, -- 2828
			toolCallId = toolCallId, -- 2829
			tool = result.tool, -- 2830
			reason = result.reason or "", -- 2831
			reasoningContent = result.reasoningContent, -- 2832
			params = result.params, -- 2833
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2834
		} -- 2834
		local action = shared.history[#shared.history] -- 2836
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 2837
		if canPreExecuteTool(action.tool) then -- 2837
			shared.pendingToolActions = {action} -- 2839
			persistHistoryState(shared) -- 2840
			return ____awaiter_resolve(nil, "batch_tools") -- 2840
		end -- 2840
		clearPreExecutedResults(shared) -- 2843
		persistHistoryState(shared) -- 2844
		return ____awaiter_resolve(nil, result.tool) -- 2844
	end) -- 2844
end -- 2731
local ReadFileAction = __TS__Class() -- 2849
ReadFileAction.name = "ReadFileAction" -- 2849
__TS__ClassExtends(ReadFileAction, Node) -- 2849
function ReadFileAction.prototype.prep(self, shared) -- 2850
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2850
		local last = shared.history[#shared.history] -- 2851
		if not last then -- 2851
			error( -- 2852
				__TS__New(Error, "no history"), -- 2852
				0 -- 2852
			) -- 2852
		end -- 2852
		emitAgentStartEvent(shared, last) -- 2853
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2854
		if __TS__StringTrim(path) == "" then -- 2854
			error( -- 2857
				__TS__New(Error, "missing path"), -- 2857
				0 -- 2857
			) -- 2857
		end -- 2857
		local ____path_61 = path -- 2859
		local ____shared_workingDir_62 = shared.workingDir -- 2861
		local ____temp_63 = shared.useChineseResponse and "zh" or "en" -- 2862
		local ____last_params_startLine_59 = last.params.startLine -- 2863
		if ____last_params_startLine_59 == nil then -- 2863
			____last_params_startLine_59 = 1 -- 2863
		end -- 2863
		local ____TS__Number_result_64 = __TS__Number(____last_params_startLine_59) -- 2863
		local ____last_params_endLine_60 = last.params.endLine -- 2864
		if ____last_params_endLine_60 == nil then -- 2864
			____last_params_endLine_60 = READ_FILE_DEFAULT_LIMIT -- 2864
		end -- 2864
		return ____awaiter_resolve( -- 2864
			nil, -- 2864
			{ -- 2858
				path = ____path_61, -- 2859
				tool = "read_file", -- 2860
				workDir = ____shared_workingDir_62, -- 2861
				docLanguage = ____temp_63, -- 2862
				startLine = ____TS__Number_result_64, -- 2863
				endLine = __TS__Number(____last_params_endLine_60) -- 2864
			} -- 2864
		) -- 2864
	end) -- 2864
end -- 2850
function ReadFileAction.prototype.exec(self, input) -- 2868
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2868
		return ____awaiter_resolve( -- 2868
			nil, -- 2868
			Tools.readFile( -- 2869
				input.workDir, -- 2870
				input.path, -- 2871
				__TS__Number(input.startLine or 1), -- 2872
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2873
				input.docLanguage -- 2874
			) -- 2874
		) -- 2874
	end) -- 2874
end -- 2868
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2878
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2878
		local result = execRes -- 2879
		local last = shared.history[#shared.history] -- 2880
		if last ~= nil then -- 2880
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2882
			appendToolResultMessage(shared, last) -- 2883
			emitAgentFinishEvent(shared, last) -- 2884
		end -- 2884
		persistHistoryState(shared) -- 2886
		__TS__Await(maybeCompressHistory(shared)) -- 2887
		persistHistoryState(shared) -- 2888
		return ____awaiter_resolve(nil, "main") -- 2888
	end) -- 2888
end -- 2878
local SearchFilesAction = __TS__Class() -- 2893
SearchFilesAction.name = "SearchFilesAction" -- 2893
__TS__ClassExtends(SearchFilesAction, Node) -- 2893
function SearchFilesAction.prototype.prep(self, shared) -- 2894
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2894
		local last = shared.history[#shared.history] -- 2895
		if not last then -- 2895
			error( -- 2896
				__TS__New(Error, "no history"), -- 2896
				0 -- 2896
			) -- 2896
		end -- 2896
		emitAgentStartEvent(shared, last) -- 2897
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2897
	end) -- 2897
end -- 2894
function SearchFilesAction.prototype.exec(self, input) -- 2901
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2901
		local params = input.params -- 2902
		local ____Tools_searchFiles_78 = Tools.searchFiles -- 2903
		local ____input_workDir_71 = input.workDir -- 2904
		local ____temp_72 = params.path or "" -- 2905
		local ____temp_73 = params.pattern or "" -- 2906
		local ____params_globs_74 = params.globs -- 2907
		local ____params_useRegex_75 = params.useRegex -- 2908
		local ____params_caseSensitive_76 = params.caseSensitive -- 2909
		local ____math_max_67 = math.max -- 2912
		local ____math_floor_66 = math.floor -- 2912
		local ____params_limit_65 = params.limit -- 2912
		if ____params_limit_65 == nil then -- 2912
			____params_limit_65 = SEARCH_FILES_LIMIT_DEFAULT -- 2912
		end -- 2912
		local ____math_max_67_result_77 = ____math_max_67( -- 2912
			1, -- 2912
			____math_floor_66(__TS__Number(____params_limit_65)) -- 2912
		) -- 2912
		local ____math_max_70 = math.max -- 2913
		local ____math_floor_69 = math.floor -- 2913
		local ____params_offset_68 = params.offset -- 2913
		if ____params_offset_68 == nil then -- 2913
			____params_offset_68 = 0 -- 2913
		end -- 2913
		local result = __TS__Await(____Tools_searchFiles_78({ -- 2903
			workDir = ____input_workDir_71, -- 2904
			path = ____temp_72, -- 2905
			pattern = ____temp_73, -- 2906
			globs = ____params_globs_74, -- 2907
			useRegex = ____params_useRegex_75, -- 2908
			caseSensitive = ____params_caseSensitive_76, -- 2909
			includeContent = true, -- 2910
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2911
			limit = ____math_max_67_result_77, -- 2912
			offset = ____math_max_70( -- 2913
				0, -- 2913
				____math_floor_69(__TS__Number(____params_offset_68)) -- 2913
			), -- 2913
			groupByFile = params.groupByFile == true -- 2914
		})) -- 2914
		return ____awaiter_resolve(nil, result) -- 2914
	end) -- 2914
end -- 2901
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2919
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2919
		local last = shared.history[#shared.history] -- 2920
		if last ~= nil then -- 2920
			local result = execRes -- 2922
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2923
			appendToolResultMessage(shared, last) -- 2924
			emitAgentFinishEvent(shared, last) -- 2925
		end -- 2925
		persistHistoryState(shared) -- 2927
		__TS__Await(maybeCompressHistory(shared)) -- 2928
		persistHistoryState(shared) -- 2929
		return ____awaiter_resolve(nil, "main") -- 2929
	end) -- 2929
end -- 2919
local SearchDoraAPIAction = __TS__Class() -- 2934
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2934
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2934
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2935
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2935
		local last = shared.history[#shared.history] -- 2936
		if not last then -- 2936
			error( -- 2937
				__TS__New(Error, "no history"), -- 2937
				0 -- 2937
			) -- 2937
		end -- 2937
		emitAgentStartEvent(shared, last) -- 2938
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2938
	end) -- 2938
end -- 2935
function SearchDoraAPIAction.prototype.exec(self, input) -- 2942
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2942
		local params = input.params -- 2943
		local ____Tools_searchDoraAPI_86 = Tools.searchDoraAPI -- 2944
		local ____temp_82 = params.pattern or "" -- 2945
		local ____temp_83 = params.docSource or "api" -- 2946
		local ____temp_84 = input.useChineseResponse and "zh" or "en" -- 2947
		local ____temp_85 = params.programmingLanguage or "ts" -- 2948
		local ____math_min_81 = math.min -- 2949
		local ____math_max_80 = math.max -- 2949
		local ____params_limit_79 = params.limit -- 2949
		if ____params_limit_79 == nil then -- 2949
			____params_limit_79 = 8 -- 2949
		end -- 2949
		local result = __TS__Await(____Tools_searchDoraAPI_86({ -- 2944
			pattern = ____temp_82, -- 2945
			docSource = ____temp_83, -- 2946
			docLanguage = ____temp_84, -- 2947
			programmingLanguage = ____temp_85, -- 2948
			limit = ____math_min_81( -- 2949
				SEARCH_DORA_API_LIMIT_MAX, -- 2949
				____math_max_80( -- 2949
					1, -- 2949
					__TS__Number(____params_limit_79) -- 2949
				) -- 2949
			), -- 2949
			useRegex = params.useRegex, -- 2950
			caseSensitive = false, -- 2951
			includeContent = true, -- 2952
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2953
		})) -- 2953
		return ____awaiter_resolve(nil, result) -- 2953
	end) -- 2953
end -- 2942
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2958
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2958
		local last = shared.history[#shared.history] -- 2959
		if last ~= nil then -- 2959
			local result = execRes -- 2961
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2962
			appendToolResultMessage(shared, last) -- 2963
			emitAgentFinishEvent(shared, last) -- 2964
		end -- 2964
		persistHistoryState(shared) -- 2966
		__TS__Await(maybeCompressHistory(shared)) -- 2967
		persistHistoryState(shared) -- 2968
		return ____awaiter_resolve(nil, "main") -- 2968
	end) -- 2968
end -- 2958
local ListFilesAction = __TS__Class() -- 2973
ListFilesAction.name = "ListFilesAction" -- 2973
__TS__ClassExtends(ListFilesAction, Node) -- 2973
function ListFilesAction.prototype.prep(self, shared) -- 2974
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2974
		local last = shared.history[#shared.history] -- 2975
		if not last then -- 2975
			error( -- 2976
				__TS__New(Error, "no history"), -- 2976
				0 -- 2976
			) -- 2976
		end -- 2976
		emitAgentStartEvent(shared, last) -- 2977
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2977
	end) -- 2977
end -- 2974
function ListFilesAction.prototype.exec(self, input) -- 2981
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2981
		local params = input.params -- 2982
		local ____Tools_listFiles_93 = Tools.listFiles -- 2983
		local ____input_workDir_90 = input.workDir -- 2984
		local ____temp_91 = params.path or "" -- 2985
		local ____params_globs_92 = params.globs -- 2986
		local ____math_max_89 = math.max -- 2987
		local ____math_floor_88 = math.floor -- 2987
		local ____params_maxEntries_87 = params.maxEntries -- 2987
		if ____params_maxEntries_87 == nil then -- 2987
			____params_maxEntries_87 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2987
		end -- 2987
		local result = ____Tools_listFiles_93({ -- 2983
			workDir = ____input_workDir_90, -- 2984
			path = ____temp_91, -- 2985
			globs = ____params_globs_92, -- 2986
			maxEntries = ____math_max_89( -- 2987
				1, -- 2987
				____math_floor_88(__TS__Number(____params_maxEntries_87)) -- 2987
			) -- 2987
		}) -- 2987
		return ____awaiter_resolve(nil, result) -- 2987
	end) -- 2987
end -- 2981
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2992
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2992
		local last = shared.history[#shared.history] -- 2993
		if last ~= nil then -- 2993
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2995
			appendToolResultMessage(shared, last) -- 2996
			emitAgentFinishEvent(shared, last) -- 2997
		end -- 2997
		persistHistoryState(shared) -- 2999
		__TS__Await(maybeCompressHistory(shared)) -- 3000
		persistHistoryState(shared) -- 3001
		return ____awaiter_resolve(nil, "main") -- 3001
	end) -- 3001
end -- 2992
local DeleteFileAction = __TS__Class() -- 3006
DeleteFileAction.name = "DeleteFileAction" -- 3006
__TS__ClassExtends(DeleteFileAction, Node) -- 3006
function DeleteFileAction.prototype.prep(self, shared) -- 3007
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3007
		local last = shared.history[#shared.history] -- 3008
		if not last then -- 3008
			error( -- 3009
				__TS__New(Error, "no history"), -- 3009
				0 -- 3009
			) -- 3009
		end -- 3009
		emitAgentStartEvent(shared, last) -- 3010
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3011
		if __TS__StringTrim(targetFile) == "" then -- 3011
			error( -- 3014
				__TS__New(Error, "missing target_file"), -- 3014
				0 -- 3014
			) -- 3014
		end -- 3014
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3014
	end) -- 3014
end -- 3007
function DeleteFileAction.prototype.exec(self, input) -- 3018
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3018
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3019
		if not result.success then -- 3019
			return ____awaiter_resolve(nil, result) -- 3019
		end -- 3019
		return ____awaiter_resolve(nil, { -- 3019
			success = true, -- 3027
			changed = true, -- 3028
			mode = "delete", -- 3029
			checkpointId = result.checkpointId, -- 3030
			checkpointSeq = result.checkpointSeq, -- 3031
			files = {{path = input.targetFile, op = "delete"}} -- 3032
		}) -- 3032
	end) -- 3032
end -- 3018
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3036
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3036
		local last = shared.history[#shared.history] -- 3037
		if last ~= nil then -- 3037
			last.result = execRes -- 3039
			appendToolResultMessage(shared, last) -- 3040
			emitAgentFinishEvent(shared, last) -- 3041
			local result = last.result -- 3042
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3042
				emitAgentEvent(shared, { -- 3047
					type = "checkpoint_created", -- 3048
					sessionId = shared.sessionId, -- 3049
					taskId = shared.taskId, -- 3050
					step = last.step, -- 3051
					tool = "delete_file", -- 3052
					checkpointId = result.checkpointId, -- 3053
					checkpointSeq = result.checkpointSeq, -- 3054
					files = result.files -- 3055
				}) -- 3055
			end -- 3055
		end -- 3055
		persistHistoryState(shared) -- 3059
		__TS__Await(maybeCompressHistory(shared)) -- 3060
		persistHistoryState(shared) -- 3061
		return ____awaiter_resolve(nil, "main") -- 3061
	end) -- 3061
end -- 3036
local BuildAction = __TS__Class() -- 3066
BuildAction.name = "BuildAction" -- 3066
__TS__ClassExtends(BuildAction, Node) -- 3066
function BuildAction.prototype.prep(self, shared) -- 3067
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3067
		local last = shared.history[#shared.history] -- 3068
		if not last then -- 3068
			error( -- 3069
				__TS__New(Error, "no history"), -- 3069
				0 -- 3069
			) -- 3069
		end -- 3069
		emitAgentStartEvent(shared, last) -- 3070
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3070
	end) -- 3070
end -- 3067
function BuildAction.prototype.exec(self, input) -- 3074
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3074
		local params = input.params -- 3075
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3076
		return ____awaiter_resolve(nil, result) -- 3076
	end) -- 3076
end -- 3074
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3083
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3083
		local last = shared.history[#shared.history] -- 3084
		if last ~= nil then -- 3084
			last.result = execRes -- 3086
			appendToolResultMessage(shared, last) -- 3087
			emitAgentFinishEvent(shared, last) -- 3088
		end -- 3088
		persistHistoryState(shared) -- 3090
		__TS__Await(maybeCompressHistory(shared)) -- 3091
		persistHistoryState(shared) -- 3092
		return ____awaiter_resolve(nil, "main") -- 3092
	end) -- 3092
end -- 3083
local SpawnSubAgentAction = __TS__Class() -- 3097
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3097
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3097
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3098
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3098
		local last = shared.history[#shared.history] -- 3107
		if not last then -- 3107
			error( -- 3108
				__TS__New(Error, "no history"), -- 3108
				0 -- 3108
			) -- 3108
		end -- 3108
		emitAgentStartEvent(shared, last) -- 3109
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3110
			last.params.filesHint, -- 3111
			function(____, item) return type(item) == "string" end -- 3111
		) or nil -- 3111
		return ____awaiter_resolve( -- 3111
			nil, -- 3111
			{ -- 3113
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3114
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3115
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3116
				filesHint = filesHint, -- 3117
				sessionId = shared.sessionId, -- 3118
				projectRoot = shared.workingDir, -- 3119
				spawnSubAgent = shared.spawnSubAgent -- 3120
			} -- 3120
		) -- 3120
	end) -- 3120
end -- 3098
function SpawnSubAgentAction.prototype.exec(self, input) -- 3124
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3124
		if not input.spawnSubAgent then -- 3124
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3124
		end -- 3124
		if input.sessionId == nil or input.sessionId <= 0 then -- 3124
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3124
		end -- 3124
		local ____Log_99 = Log -- 3139
		local ____temp_96 = #input.title -- 3139
		local ____temp_97 = #input.prompt -- 3139
		local ____temp_98 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3139
		local ____opt_94 = input.filesHint -- 3139
		____Log_99( -- 3139
			"Info", -- 3139
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_96)) .. " prompt_len=") .. tostring(____temp_97)) .. " expected_len=") .. tostring(____temp_98)) .. " files_hint_count=") .. tostring(____opt_94 and #____opt_94 or 0) -- 3139
		) -- 3139
		local result = __TS__Await(input.spawnSubAgent({ -- 3140
			parentSessionId = input.sessionId, -- 3141
			projectRoot = input.projectRoot, -- 3142
			title = input.title, -- 3143
			prompt = input.prompt, -- 3144
			expectedOutput = input.expectedOutput, -- 3145
			filesHint = input.filesHint -- 3146
		})) -- 3146
		if not result.success then -- 3146
			return ____awaiter_resolve(nil, result) -- 3146
		end -- 3146
		return ____awaiter_resolve(nil, { -- 3146
			success = true, -- 3152
			sessionId = result.sessionId, -- 3153
			taskId = result.taskId, -- 3154
			title = result.title, -- 3155
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3156
		}) -- 3156
	end) -- 3156
end -- 3124
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3160
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3160
		local last = shared.history[#shared.history] -- 3161
		if last ~= nil then -- 3161
			last.result = execRes -- 3163
			appendToolResultMessage(shared, last) -- 3164
			emitAgentFinishEvent(shared, last) -- 3165
		end -- 3165
		persistHistoryState(shared) -- 3167
		__TS__Await(maybeCompressHistory(shared)) -- 3168
		persistHistoryState(shared) -- 3169
		return ____awaiter_resolve(nil, "main") -- 3169
	end) -- 3169
end -- 3160
local ListSubAgentsAction = __TS__Class() -- 3174
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3174
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3174
function ListSubAgentsAction.prototype.prep(self, shared) -- 3175
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3175
		local last = shared.history[#shared.history] -- 3184
		if not last then -- 3184
			error( -- 3185
				__TS__New(Error, "no history"), -- 3185
				0 -- 3185
			) -- 3185
		end -- 3185
		emitAgentStartEvent(shared, last) -- 3186
		return ____awaiter_resolve( -- 3186
			nil, -- 3186
			{ -- 3187
				sessionId = shared.sessionId, -- 3188
				projectRoot = shared.workingDir, -- 3189
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3190
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3191
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3192
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3193
				listSubAgents = shared.listSubAgents -- 3194
			} -- 3194
		) -- 3194
	end) -- 3194
end -- 3175
function ListSubAgentsAction.prototype.exec(self, input) -- 3198
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3198
		if not input.listSubAgents then -- 3198
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3198
		end -- 3198
		if input.sessionId == nil or input.sessionId <= 0 then -- 3198
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3198
		end -- 3198
		local result = __TS__Await(input.listSubAgents({ -- 3213
			sessionId = input.sessionId, -- 3214
			projectRoot = input.projectRoot, -- 3215
			status = input.status, -- 3216
			limit = input.limit, -- 3217
			offset = input.offset, -- 3218
			query = input.query -- 3219
		})) -- 3219
		return ____awaiter_resolve(nil, result) -- 3219
	end) -- 3219
end -- 3198
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3224
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3224
		local last = shared.history[#shared.history] -- 3225
		if last ~= nil then -- 3225
			last.result = execRes -- 3227
			appendToolResultMessage(shared, last) -- 3228
			emitAgentFinishEvent(shared, last) -- 3229
		end -- 3229
		persistHistoryState(shared) -- 3231
		__TS__Await(maybeCompressHistory(shared)) -- 3232
		persistHistoryState(shared) -- 3233
		return ____awaiter_resolve(nil, "main") -- 3233
	end) -- 3233
end -- 3224
EditFileAction = __TS__Class() -- 3238
EditFileAction.name = "EditFileAction" -- 3238
__TS__ClassExtends(EditFileAction, Node) -- 3238
function EditFileAction.prototype.prep(self, shared) -- 3239
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3239
		local last = shared.history[#shared.history] -- 3240
		if not last then -- 3240
			error( -- 3241
				__TS__New(Error, "no history"), -- 3241
				0 -- 3241
			) -- 3241
		end -- 3241
		emitAgentStartEvent(shared, last) -- 3242
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3243
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3246
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3247
		if __TS__StringTrim(path) == "" then -- 3247
			error( -- 3248
				__TS__New(Error, "missing path"), -- 3248
				0 -- 3248
			) -- 3248
		end -- 3248
		return ____awaiter_resolve(nil, { -- 3248
			path = path, -- 3249
			oldStr = oldStr, -- 3249
			newStr = newStr, -- 3249
			taskId = shared.taskId, -- 3249
			workDir = shared.workingDir -- 3249
		}) -- 3249
	end) -- 3249
end -- 3239
function EditFileAction.prototype.exec(self, input) -- 3252
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3252
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3253
		if not readRes.success then -- 3253
			if input.oldStr ~= "" then -- 3253
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3253
			end -- 3253
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3258
			if not createRes.success then -- 3258
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3258
			end -- 3258
			return ____awaiter_resolve(nil, { -- 3258
				success = true, -- 3266
				changed = true, -- 3267
				mode = "create", -- 3268
				checkpointId = createRes.checkpointId, -- 3269
				checkpointSeq = createRes.checkpointSeq, -- 3270
				files = {{path = input.path, op = "create"}} -- 3271
			}) -- 3271
		end -- 3271
		if input.oldStr == "" then -- 3271
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3275
			if not overwriteRes.success then -- 3275
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3275
			end -- 3275
			return ____awaiter_resolve(nil, { -- 3275
				success = true, -- 3283
				changed = true, -- 3284
				mode = "overwrite", -- 3285
				checkpointId = overwriteRes.checkpointId, -- 3286
				checkpointSeq = overwriteRes.checkpointSeq, -- 3287
				files = {{path = input.path, op = "write"}} -- 3288
			}) -- 3288
		end -- 3288
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3293
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3294
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3295
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3298
		if occurrences == 0 then -- 3298
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3300
			if not indentTolerant.success then -- 3300
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3300
			end -- 3300
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3304
			if not applyRes.success then -- 3304
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3304
			end -- 3304
			return ____awaiter_resolve(nil, { -- 3304
				success = true, -- 3312
				changed = true, -- 3313
				mode = "replace_indent_tolerant", -- 3314
				checkpointId = applyRes.checkpointId, -- 3315
				checkpointSeq = applyRes.checkpointSeq, -- 3316
				files = {{path = input.path, op = "write"}} -- 3317
			}) -- 3317
		end -- 3317
		if occurrences > 1 then -- 3317
			return ____awaiter_resolve( -- 3317
				nil, -- 3317
				{ -- 3321
					success = false, -- 3321
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3321
				} -- 3321
			) -- 3321
		end -- 3321
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3325
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3326
		if not applyRes.success then -- 3326
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3326
		end -- 3326
		return ____awaiter_resolve(nil, { -- 3326
			success = true, -- 3334
			changed = true, -- 3335
			mode = "replace", -- 3336
			checkpointId = applyRes.checkpointId, -- 3337
			checkpointSeq = applyRes.checkpointSeq, -- 3338
			files = {{path = input.path, op = "write"}} -- 3339
		}) -- 3339
	end) -- 3339
end -- 3252
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3343
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3343
		local last = shared.history[#shared.history] -- 3344
		if last ~= nil then -- 3344
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3346
			last.result = execRes -- 3347
			appendToolResultMessage(shared, last) -- 3348
			emitAgentFinishEvent(shared, last) -- 3349
			local result = last.result -- 3350
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3350
				emitAgentEvent(shared, { -- 3355
					type = "checkpoint_created", -- 3356
					sessionId = shared.sessionId, -- 3357
					taskId = shared.taskId, -- 3358
					step = last.step, -- 3359
					tool = last.tool, -- 3360
					checkpointId = result.checkpointId, -- 3361
					checkpointSeq = result.checkpointSeq, -- 3362
					files = result.files -- 3363
				}) -- 3363
			end -- 3363
		end -- 3363
		persistHistoryState(shared) -- 3367
		__TS__Await(maybeCompressHistory(shared)) -- 3368
		persistHistoryState(shared) -- 3369
		return ____awaiter_resolve(nil, "main") -- 3369
	end) -- 3369
end -- 3343
local function emitCheckpointEventForAction(shared, action) -- 3374
	local result = action.result -- 3375
	if not result then -- 3375
		return -- 3376
	end -- 3376
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3376
		emitAgentEvent(shared, { -- 3381
			type = "checkpoint_created", -- 3382
			sessionId = shared.sessionId, -- 3383
			taskId = shared.taskId, -- 3384
			step = action.step, -- 3385
			tool = action.tool, -- 3386
			checkpointId = result.checkpointId, -- 3387
			checkpointSeq = result.checkpointSeq, -- 3388
			files = result.files -- 3389
		}) -- 3389
	end -- 3389
end -- 3374
local function sanitizeToolActionResultForHistory(action, result) -- 3544
	if action.tool == "read_file" then -- 3544
		return sanitizeReadResultForHistory(action.tool, result) -- 3546
	end -- 3546
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3546
		return sanitizeSearchResultForHistory(action.tool, result) -- 3549
	end -- 3549
	if action.tool == "glob_files" then -- 3549
		return sanitizeListFilesResultForHistory(result) -- 3552
	end -- 3552
	return result -- 3554
end -- 3544
local function canRunBatchActionInParallel(self, action) -- 3557
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 3558
end -- 3557
local function partitionToolCalls(actions) -- 3570
	local batches = {} -- 3571
	do -- 3571
		local i = 0 -- 3572
		while i < #actions do -- 3572
			local action = actions[i + 1] -- 3573
			local isSafe = canRunBatchActionInParallel(nil, action) -- 3574
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 3575
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 3575
				local ____lastBatch_actions_134 = lastBatch.actions -- 3575
				____lastBatch_actions_134[#____lastBatch_actions_134 + 1] = action -- 3577
			else -- 3577
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 3579
			end -- 3579
			i = i + 1 -- 3572
		end -- 3572
	end -- 3572
	return batches -- 3582
end -- 3570
local BatchToolAction = __TS__Class() -- 3585
BatchToolAction.name = "BatchToolAction" -- 3585
__TS__ClassExtends(BatchToolAction, Node) -- 3585
function BatchToolAction.prototype.prep(self, shared) -- 3586
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3586
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3586
	end) -- 3586
end -- 3586
function BatchToolAction.prototype.exec(self, input) -- 3590
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3590
		local shared = input.shared -- 3591
		local preExecuted = shared.preExecutedResults -- 3592
		local batches = partitionToolCalls(input.actions) -- 3593
		local parallelBatchCount = #__TS__ArrayFilter( -- 3594
			batches, -- 3594
			function(____, b) return b.isConcurrencySafe end -- 3594
		) -- 3594
		local serialBatchCount = #__TS__ArrayFilter( -- 3595
			batches, -- 3595
			function(____, b) return not b.isConcurrencySafe end -- 3595
		) -- 3595
		Log( -- 3596
			"Info", -- 3596
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 3596
		) -- 3596
		do -- 3596
			local batchIdx = 0 -- 3598
			while batchIdx < #batches do -- 3598
				do -- 3598
					local batch = batches[batchIdx + 1] -- 3599
					if shared.stopToken.stopped then -- 3599
						for ____, action in ipairs(batch.actions) do -- 3601
							if not action.result then -- 3601
								action.result = { -- 3603
									success = false, -- 3603
									message = getCancelledReason(shared) -- 3603
								} -- 3603
							end -- 3603
						end -- 3603
						goto __continue558 -- 3606
					end -- 3606
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 3606
						local preExecCount = #__TS__ArrayFilter( -- 3610
							batch.actions, -- 3610
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 3610
						) -- 3610
						Log( -- 3611
							"Info", -- 3611
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3611
						) -- 3611
						do -- 3611
							local i = 0 -- 3612
							while i < #batch.actions do -- 3612
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 3613
								i = i + 1 -- 3612
							end -- 3612
						end -- 3612
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3615
							batch.actions, -- 3615
							function(____, action) -- 3615
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3615
									if shared.stopToken.stopped then -- 3615
										action.result = { -- 3617
											success = false, -- 3617
											message = getCancelledReason(shared) -- 3617
										} -- 3617
										return ____awaiter_resolve(nil, action) -- 3617
									end -- 3617
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3620
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3621
									action.result = sanitizeToolActionResultForHistory(action, result) -- 3622
									return ____awaiter_resolve(nil, action) -- 3622
								end) -- 3622
							end -- 3615
						))) -- 3615
						do -- 3615
							local i = 0 -- 3625
							while i < #batch.actions do -- 3625
								local action = batch.actions[i + 1] -- 3626
								if not action.result then -- 3626
									action.result = {success = false, message = "tool did not produce a result"} -- 3628
								end -- 3628
								appendToolResultMessage(shared, action) -- 3630
								emitAgentFinishEvent(shared, action) -- 3631
								emitCheckpointEventForAction(shared, action) -- 3632
								i = i + 1 -- 3625
							end -- 3625
						end -- 3625
					else -- 3625
						Log( -- 3635
							"Info", -- 3635
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 3635
						) -- 3635
						do -- 3635
							local i = 0 -- 3636
							while i < #batch.actions do -- 3636
								local action = batch.actions[i + 1] -- 3637
								emitAgentStartEvent(shared, action) -- 3638
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3639
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3640
								action.result = sanitizeToolActionResultForHistory(action, result) -- 3641
								appendToolResultMessage(shared, action) -- 3642
								emitAgentFinishEvent(shared, action) -- 3643
								emitCheckpointEventForAction(shared, action) -- 3644
								persistHistoryState(shared) -- 3645
								if shared.stopToken.stopped then -- 3645
									break -- 3647
								end -- 3647
								i = i + 1 -- 3636
							end -- 3636
						end -- 3636
					end -- 3636
				end -- 3636
				::__continue558:: -- 3636
				batchIdx = batchIdx + 1 -- 3598
			end -- 3598
		end -- 3598
		persistHistoryState(shared) -- 3652
		return ____awaiter_resolve(nil, input.actions) -- 3652
	end) -- 3652
end -- 3590
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3656
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3656
		shared.pendingToolActions = nil -- 3657
		shared.preExecutedResults = nil -- 3658
		persistHistoryState(shared) -- 3659
		__TS__Await(maybeCompressHistory(shared)) -- 3660
		persistHistoryState(shared) -- 3661
		return ____awaiter_resolve(nil, "main") -- 3661
	end) -- 3661
end -- 3656
local EndNode = __TS__Class() -- 3666
EndNode.name = "EndNode" -- 3666
__TS__ClassExtends(EndNode, Node) -- 3666
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3667
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3667
		return ____awaiter_resolve(nil, nil) -- 3667
	end) -- 3667
end -- 3667
local CodingAgentFlow = __TS__Class() -- 3672
CodingAgentFlow.name = "CodingAgentFlow" -- 3672
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3672
function CodingAgentFlow.prototype.____constructor(self, role) -- 3673
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3674
	local read = __TS__New(ReadFileAction, 1, 0) -- 3675
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3676
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3677
	local list = __TS__New(ListFilesAction, 1, 0) -- 3678
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3679
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3680
	local build = __TS__New(BuildAction, 1, 0) -- 3681
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3682
	local edit = __TS__New(EditFileAction, 1, 0) -- 3683
	local batch = __TS__New(BatchToolAction, 1, 0) -- 3684
	local done = __TS__New(EndNode, 1, 0) -- 3685
	main:on("batch_tools", batch) -- 3687
	main:on("grep_files", search) -- 3688
	main:on("search_dora_api", searchDora) -- 3689
	main:on("glob_files", list) -- 3690
	if role == "main" then -- 3690
		main:on("read_file", read) -- 3692
		main:on("delete_file", del) -- 3693
		main:on("build", build) -- 3694
		main:on("edit_file", edit) -- 3695
		main:on("list_sub_agents", listSub) -- 3696
		main:on("spawn_sub_agent", spawn) -- 3697
	else -- 3697
		main:on("read_file", read) -- 3699
		main:on("delete_file", del) -- 3700
		main:on("build", build) -- 3701
		main:on("edit_file", edit) -- 3702
	end -- 3702
	main:on("done", done) -- 3704
	search:on("main", main) -- 3706
	searchDora:on("main", main) -- 3707
	list:on("main", main) -- 3708
	listSub:on("main", main) -- 3709
	spawn:on("main", main) -- 3710
	batch:on("main", main) -- 3711
	read:on("main", main) -- 3712
	del:on("main", main) -- 3713
	build:on("main", main) -- 3714
	edit:on("main", main) -- 3715
	Flow.prototype.____constructor(self, main) -- 3717
end -- 3673
local function runCodingAgentAsync(options) -- 3739
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3739
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3739
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3739
		end -- 3739
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3743
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3744
		if not llmConfigRes.success then -- 3744
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3744
		end -- 3744
		local llmConfig = llmConfigRes.config -- 3750
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3751
		if not taskRes.success then -- 3751
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3751
		end -- 3751
		local compressor = __TS__New(MemoryCompressor, { -- 3758
			compressionThreshold = 0.8, -- 3759
			compressionTargetThreshold = 0.5, -- 3760
			maxCompressionRounds = 3, -- 3761
			projectDir = options.workDir, -- 3762
			llmConfig = llmConfig, -- 3763
			promptPack = options.promptPack, -- 3764
			scope = options.memoryScope -- 3765
		}) -- 3765
		local persistedSession = compressor:getStorage():readSessionState() -- 3767
		local promptPack = compressor:getPromptPack() -- 3768
		local shared = { -- 3770
			sessionId = options.sessionId, -- 3771
			taskId = taskRes.taskId, -- 3772
			role = options.role or "main", -- 3773
			maxSteps = math.max( -- 3774
				1, -- 3774
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 3774
			), -- 3774
			llmMaxTry = math.max( -- 3775
				1, -- 3775
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 3775
			), -- 3775
			step = 0, -- 3776
			done = false, -- 3777
			stopToken = options.stopToken or ({stopped = false}), -- 3778
			response = "", -- 3779
			userQuery = normalizedPrompt, -- 3780
			workingDir = options.workDir, -- 3781
			useChineseResponse = options.useChineseResponse == true, -- 3782
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3783
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 3786
			llmConfig = llmConfig, -- 3787
			onEvent = options.onEvent, -- 3788
			promptPack = promptPack, -- 3789
			history = {}, -- 3790
			messages = persistedSession.messages, -- 3791
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 3792
			carryMessageIndex = persistedSession.carryMessageIndex, -- 3793
			memory = {compressor = compressor}, -- 3795
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 3799
			spawnSubAgent = options.spawnSubAgent, -- 3804
			listSubAgents = options.listSubAgents -- 3805
		} -- 3805
		local ____try = __TS__AsyncAwaiter(function() -- 3805
			emitAgentEvent(shared, { -- 3809
				type = "task_started", -- 3810
				sessionId = shared.sessionId, -- 3811
				taskId = shared.taskId, -- 3812
				prompt = shared.userQuery, -- 3813
				workDir = shared.workingDir, -- 3814
				maxSteps = shared.maxSteps -- 3815
			}) -- 3815
			if shared.stopToken.stopped then -- 3815
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3818
				return ____awaiter_resolve( -- 3818
					nil, -- 3818
					emitAgentTaskFinishEvent( -- 3819
						shared, -- 3819
						false, -- 3819
						getCancelledReason(shared) -- 3819
					) -- 3819
				) -- 3819
			end -- 3819
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3821
			local promptCommand = getPromptCommand(shared.userQuery) -- 3822
			if promptCommand == "clear" then -- 3822
				return ____awaiter_resolve( -- 3822
					nil, -- 3822
					clearSessionHistory(shared) -- 3824
				) -- 3824
			end -- 3824
			if promptCommand == "compact" then -- 3824
				if shared.role == "sub" then -- 3824
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 3828
					return ____awaiter_resolve( -- 3828
						nil, -- 3828
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 3829
					) -- 3829
				end -- 3829
				return ____awaiter_resolve( -- 3829
					nil, -- 3829
					__TS__Await(compactAllHistory(shared)) -- 3837
				) -- 3837
			end -- 3837
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3839
			persistHistoryState(shared) -- 3843
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3844
			__TS__Await(flow:run(shared)) -- 3845
			if shared.stopToken.stopped then -- 3845
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3847
				return ____awaiter_resolve( -- 3847
					nil, -- 3847
					emitAgentTaskFinishEvent( -- 3848
						shared, -- 3848
						false, -- 3848
						getCancelledReason(shared) -- 3848
					) -- 3848
				) -- 3848
			end -- 3848
			if shared.error then -- 3848
				return ____awaiter_resolve( -- 3848
					nil, -- 3848
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3851
				) -- 3851
			end -- 3851
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3854
			return ____awaiter_resolve( -- 3854
				nil, -- 3854
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3855
			) -- 3855
		end) -- 3855
		__TS__Await(____try.catch( -- 3808
			____try, -- 3808
			function(____, e) -- 3808
				return ____awaiter_resolve( -- 3808
					nil, -- 3808
					finalizeAgentFailure( -- 3858
						shared, -- 3858
						tostring(e) -- 3858
					) -- 3858
				) -- 3858
			end -- 3858
		)) -- 3858
	end) -- 3858
end -- 3739
function ____exports.runCodingAgent(options, callback) -- 3862
	local ____self_137 = runCodingAgentAsync(options) -- 3862
	____self_137["then"]( -- 3862
		____self_137, -- 3862
		function(____, result) return callback(result) end -- 3863
	) -- 3863
end -- 3862
return ____exports -- 3862