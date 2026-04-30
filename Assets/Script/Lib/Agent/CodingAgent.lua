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
function getDecisionPath(params) -- 1790
	if type(params.path) == "string" then -- 1790
		return __TS__StringTrim(params.path) -- 1791
	end -- 1791
	if type(params.target_file) == "string" then -- 1791
		return __TS__StringTrim(params.target_file) -- 1792
	end -- 1792
	return "" -- 1793
end -- 1793
function clampIntegerParam(value, fallback, minValue, maxValue) -- 1796
	local num = __TS__Number(value) -- 1797
	if not __TS__NumberIsFinite(num) then -- 1797
		num = fallback -- 1798
	end -- 1798
	num = math.floor(num) -- 1799
	if num < minValue then -- 1799
		num = minValue -- 1800
	end -- 1800
	if maxValue ~= nil and num > maxValue then -- 1800
		num = maxValue -- 1801
	end -- 1801
	return num -- 1802
end -- 1802
function parseReadLineParam(value, fallback, paramName) -- 1805
	local num = __TS__Number(value) -- 1810
	if not __TS__NumberIsFinite(num) then -- 1810
		num = fallback -- 1811
	end -- 1811
	num = math.floor(num) -- 1812
	if num == 0 then -- 1812
		return {success = false, message = paramName .. " cannot be 0"} -- 1814
	end -- 1814
	return {success = true, value = num} -- 1816
end -- 1816
function validateDecision(tool, params) -- 1819
	if tool == "finish" then -- 1819
		local message = getFinishMessage(params) -- 1824
		if message == "" then -- 1824
			return {success = false, message = "finish requires params.message"} -- 1825
		end -- 1825
		params.message = message -- 1826
		return {success = true, params = params} -- 1827
	end -- 1827
	if tool == "read_file" then -- 1827
		local path = getDecisionPath(params) -- 1831
		if path == "" then -- 1831
			return {success = false, message = "read_file requires path"} -- 1832
		end -- 1832
		params.path = path -- 1833
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1834
		if not startLineRes.success then -- 1834
			return startLineRes -- 1835
		end -- 1835
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1836
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1837
		if not endLineRes.success then -- 1837
			return endLineRes -- 1838
		end -- 1838
		params.startLine = startLineRes.value -- 1839
		params.endLine = endLineRes.value -- 1840
		return {success = true, params = params} -- 1841
	end -- 1841
	if tool == "edit_file" then -- 1841
		local path = getDecisionPath(params) -- 1845
		if path == "" then -- 1845
			return {success = false, message = "edit_file requires path"} -- 1846
		end -- 1846
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1847
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1848
		params.path = path -- 1849
		params.old_str = oldStr -- 1850
		params.new_str = newStr -- 1851
		return {success = true, params = params} -- 1852
	end -- 1852
	if tool == "delete_file" then -- 1852
		local targetFile = getDecisionPath(params) -- 1856
		if targetFile == "" then -- 1856
			return {success = false, message = "delete_file requires target_file"} -- 1857
		end -- 1857
		params.target_file = targetFile -- 1858
		return {success = true, params = params} -- 1859
	end -- 1859
	if tool == "grep_files" then -- 1859
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1863
		if pattern == "" then -- 1863
			return {success = false, message = "grep_files requires pattern"} -- 1864
		end -- 1864
		params.pattern = pattern -- 1865
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1866
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1867
		return {success = true, params = params} -- 1868
	end -- 1868
	if tool == "search_dora_api" then -- 1868
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1872
		if pattern == "" then -- 1872
			return {success = false, message = "search_dora_api requires pattern"} -- 1873
		end -- 1873
		params.pattern = pattern -- 1874
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1875
		return {success = true, params = params} -- 1876
	end -- 1876
	if tool == "glob_files" then -- 1876
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1880
		return {success = true, params = params} -- 1881
	end -- 1881
	if tool == "build" then -- 1881
		local path = getDecisionPath(params) -- 1885
		if path ~= "" then -- 1885
			params.path = path -- 1887
		end -- 1887
		return {success = true, params = params} -- 1889
	end -- 1889
	if tool == "list_sub_agents" then -- 1889
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 1893
		if status ~= "" then -- 1893
			params.status = status -- 1895
		end -- 1895
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 1897
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1898
		if type(params.query) == "string" then -- 1898
			params.query = __TS__StringTrim(params.query) -- 1900
		end -- 1900
		return {success = true, params = params} -- 1902
	end -- 1902
	if tool == "spawn_sub_agent" then -- 1902
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 1906
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 1907
		if prompt == "" then -- 1907
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 1908
		end -- 1908
		if title == "" then -- 1908
			return {success = false, message = "spawn_sub_agent requires title"} -- 1909
		end -- 1909
		params.prompt = prompt -- 1910
		params.title = title -- 1911
		if type(params.expectedOutput) == "string" then -- 1911
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 1913
		end -- 1913
		if isArray(params.filesHint) then -- 1913
			params.filesHint = __TS__ArrayMap( -- 1916
				__TS__ArrayFilter( -- 1916
					params.filesHint, -- 1916
					function(____, item) return type(item) == "string" end -- 1917
				), -- 1917
				function(____, item) return sanitizeUTF8(item) end -- 1918
			) -- 1918
		end -- 1918
		return {success = true, params = params} -- 1920
	end -- 1920
	return {success = true, params = params} -- 1923
end -- 1923
function getAllowedToolsForRole(role) -- 1949
	return role == "main" and ({ -- 1950
		"read_file", -- 1951
		"edit_file", -- 1951
		"delete_file", -- 1951
		"grep_files", -- 1951
		"search_dora_api", -- 1951
		"glob_files", -- 1951
		"build", -- 1951
		"list_sub_agents", -- 1951
		"spawn_sub_agent", -- 1951
		"finish" -- 1951
	}) or ({ -- 1951
		"read_file", -- 1952
		"edit_file", -- 1952
		"delete_file", -- 1952
		"grep_files", -- 1952
		"search_dora_api", -- 1952
		"glob_files", -- 1952
		"build", -- 1952
		"finish" -- 1952
	}) -- 1952
end -- 1952
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2058
	if includeToolDefinitions == nil then -- 2058
		includeToolDefinitions = false -- 2058
	end -- 2058
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2059
	local sections = { -- 2062
		shared.promptPack.agentIdentityPrompt, -- 2063
		rolePrompt, -- 2064
		getReplyLanguageDirective(shared) -- 2065
	} -- 2065
	if shared.decisionMode == "tool_calling" then -- 2065
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2068
	end -- 2068
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2070
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2071
	if memoryContext ~= "" then -- 2071
		sections[#sections + 1] = memoryContext -- 2073
	end -- 2073
	if includeToolDefinitions then -- 2073
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2076
		if shared.decisionMode == "xml" then -- 2076
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2078
		end -- 2078
	end -- 2078
	local skillsSection = buildSkillsSection(shared) -- 2082
	if skillsSection ~= "" then -- 2082
		sections[#sections + 1] = skillsSection -- 2084
	end -- 2084
	return table.concat(sections, "\n\n") -- 2086
end -- 2086
function buildSkillsSection(shared) -- 2089
	local ____opt_42 = shared.skills -- 2089
	if not (____opt_42 and ____opt_42.loader) then -- 2089
		return "" -- 2091
	end -- 2091
	return shared.skills.loader:buildSkillsPromptSection() -- 2093
end -- 2093
function buildXmlDecisionInstruction(shared, feedback) -- 2205
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2206
end -- 2206
function executeToolAction(shared, action) -- 3332
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3332
		if shared.stopToken.stopped then -- 3332
			return ____awaiter_resolve( -- 3332
				nil, -- 3332
				{ -- 3334
					success = false, -- 3334
					message = getCancelledReason(shared) -- 3334
				} -- 3334
			) -- 3334
		end -- 3334
		local params = action.params -- 3336
		if action.tool == "read_file" then -- 3336
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3338
			if __TS__StringTrim(path) == "" then -- 3338
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3338
			end -- 3338
			local ____Tools_readFile_104 = Tools.readFile -- 3342
			local ____shared_workingDir_102 = shared.workingDir -- 3343
			local ____params_startLine_100 = params.startLine -- 3345
			if ____params_startLine_100 == nil then -- 3345
				____params_startLine_100 = 1 -- 3345
			end -- 3345
			local ____TS__Number_result_103 = __TS__Number(____params_startLine_100) -- 3345
			local ____params_endLine_101 = params.endLine -- 3346
			if ____params_endLine_101 == nil then -- 3346
				____params_endLine_101 = READ_FILE_DEFAULT_LIMIT -- 3346
			end -- 3346
			return ____awaiter_resolve( -- 3346
				nil, -- 3346
				____Tools_readFile_104( -- 3342
					____shared_workingDir_102, -- 3343
					path, -- 3344
					____TS__Number_result_103, -- 3345
					__TS__Number(____params_endLine_101), -- 3346
					shared.useChineseResponse and "zh" or "en" -- 3347
				) -- 3347
			) -- 3347
		end -- 3347
		if action.tool == "grep_files" then -- 3347
			local ____Tools_searchFiles_118 = Tools.searchFiles -- 3351
			local ____shared_workingDir_111 = shared.workingDir -- 3352
			local ____temp_112 = params.path or "" -- 3353
			local ____temp_113 = params.pattern or "" -- 3354
			local ____params_globs_114 = params.globs -- 3355
			local ____params_useRegex_115 = params.useRegex -- 3356
			local ____params_caseSensitive_116 = params.caseSensitive -- 3357
			local ____math_max_107 = math.max -- 3360
			local ____math_floor_106 = math.floor -- 3360
			local ____params_limit_105 = params.limit -- 3360
			if ____params_limit_105 == nil then -- 3360
				____params_limit_105 = SEARCH_FILES_LIMIT_DEFAULT -- 3360
			end -- 3360
			local ____math_max_107_result_117 = ____math_max_107( -- 3360
				1, -- 3360
				____math_floor_106(__TS__Number(____params_limit_105)) -- 3360
			) -- 3360
			local ____math_max_110 = math.max -- 3361
			local ____math_floor_109 = math.floor -- 3361
			local ____params_offset_108 = params.offset -- 3361
			if ____params_offset_108 == nil then -- 3361
				____params_offset_108 = 0 -- 3361
			end -- 3361
			local result = __TS__Await(____Tools_searchFiles_118({ -- 3351
				workDir = ____shared_workingDir_111, -- 3352
				path = ____temp_112, -- 3353
				pattern = ____temp_113, -- 3354
				globs = ____params_globs_114, -- 3355
				useRegex = ____params_useRegex_115, -- 3356
				caseSensitive = ____params_caseSensitive_116, -- 3357
				includeContent = true, -- 3358
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3359
				limit = ____math_max_107_result_117, -- 3360
				offset = ____math_max_110( -- 3361
					0, -- 3361
					____math_floor_109(__TS__Number(____params_offset_108)) -- 3361
				), -- 3361
				groupByFile = params.groupByFile == true -- 3362
			})) -- 3362
			return ____awaiter_resolve(nil, result) -- 3362
		end -- 3362
		if action.tool == "search_dora_api" then -- 3362
			local ____Tools_searchDoraAPI_126 = Tools.searchDoraAPI -- 3367
			local ____temp_122 = params.pattern or "" -- 3368
			local ____temp_123 = params.docSource or "api" -- 3369
			local ____temp_124 = shared.useChineseResponse and "zh" or "en" -- 3370
			local ____temp_125 = params.programmingLanguage or "ts" -- 3371
			local ____math_min_121 = math.min -- 3372
			local ____math_max_120 = math.max -- 3372
			local ____params_limit_119 = params.limit -- 3372
			if ____params_limit_119 == nil then -- 3372
				____params_limit_119 = 8 -- 3372
			end -- 3372
			local result = __TS__Await(____Tools_searchDoraAPI_126({ -- 3367
				pattern = ____temp_122, -- 3368
				docSource = ____temp_123, -- 3369
				docLanguage = ____temp_124, -- 3370
				programmingLanguage = ____temp_125, -- 3371
				limit = ____math_min_121( -- 3372
					SEARCH_DORA_API_LIMIT_MAX, -- 3372
					____math_max_120( -- 3372
						1, -- 3372
						__TS__Number(____params_limit_119) -- 3372
					) -- 3372
				), -- 3372
				useRegex = params.useRegex, -- 3373
				caseSensitive = false, -- 3374
				includeContent = true, -- 3375
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3376
			})) -- 3376
			return ____awaiter_resolve(nil, result) -- 3376
		end -- 3376
		if action.tool == "glob_files" then -- 3376
			local ____Tools_listFiles_133 = Tools.listFiles -- 3381
			local ____shared_workingDir_130 = shared.workingDir -- 3382
			local ____temp_131 = params.path or "" -- 3383
			local ____params_globs_132 = params.globs -- 3384
			local ____math_max_129 = math.max -- 3385
			local ____math_floor_128 = math.floor -- 3385
			local ____params_maxEntries_127 = params.maxEntries -- 3385
			if ____params_maxEntries_127 == nil then -- 3385
				____params_maxEntries_127 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3385
			end -- 3385
			local result = ____Tools_listFiles_133({ -- 3381
				workDir = ____shared_workingDir_130, -- 3382
				path = ____temp_131, -- 3383
				globs = ____params_globs_132, -- 3384
				maxEntries = ____math_max_129( -- 3385
					1, -- 3385
					____math_floor_128(__TS__Number(____params_maxEntries_127)) -- 3385
				) -- 3385
			}) -- 3385
			return ____awaiter_resolve(nil, result) -- 3385
		end -- 3385
		if action.tool == "delete_file" then -- 3385
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3390
			if __TS__StringTrim(targetFile) == "" then -- 3390
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3390
			end -- 3390
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3394
			if not result.success then -- 3394
				return ____awaiter_resolve(nil, result) -- 3394
			end -- 3394
			return ____awaiter_resolve(nil, { -- 3394
				success = true, -- 3402
				changed = true, -- 3403
				mode = "delete", -- 3404
				checkpointId = result.checkpointId, -- 3405
				checkpointSeq = result.checkpointSeq, -- 3406
				files = {{path = targetFile, op = "delete"}} -- 3407
			}) -- 3407
		end -- 3407
		if action.tool == "build" then -- 3407
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3411
			return ____awaiter_resolve(nil, result) -- 3411
		end -- 3411
		if action.tool == "spawn_sub_agent" then -- 3411
			if not shared.spawnSubAgent then -- 3411
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3411
			end -- 3411
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3411
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3411
			end -- 3411
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3424
				params.filesHint, -- 3425
				function(____, item) return type(item) == "string" end -- 3425
			) or nil -- 3425
			local result = __TS__Await(shared.spawnSubAgent({ -- 3427
				parentSessionId = shared.sessionId, -- 3428
				projectRoot = shared.workingDir, -- 3429
				title = type(params.title) == "string" and params.title or "Sub", -- 3430
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3431
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3432
				filesHint = filesHint -- 3433
			})) -- 3433
			if not result.success then -- 3433
				return ____awaiter_resolve(nil, result) -- 3433
			end -- 3433
			return ____awaiter_resolve(nil, { -- 3433
				success = true, -- 3439
				sessionId = result.sessionId, -- 3440
				taskId = result.taskId, -- 3441
				title = result.title, -- 3442
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3443
			}) -- 3443
		end -- 3443
		if action.tool == "list_sub_agents" then -- 3443
			if not shared.listSubAgents then -- 3443
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3443
			end -- 3443
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3443
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3443
			end -- 3443
			local result = __TS__Await(shared.listSubAgents({ -- 3453
				sessionId = shared.sessionId, -- 3454
				projectRoot = shared.workingDir, -- 3455
				status = type(params.status) == "string" and params.status or nil, -- 3456
				limit = type(params.limit) == "number" and params.limit or nil, -- 3457
				offset = type(params.offset) == "number" and params.offset or nil, -- 3458
				query = type(params.query) == "string" and params.query or nil -- 3459
			})) -- 3459
			return ____awaiter_resolve(nil, result) -- 3459
		end -- 3459
		if action.tool == "edit_file" then -- 3459
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3464
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3467
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3468
			if __TS__StringTrim(path) == "" then -- 3468
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3468
			end -- 3468
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3470
			return ____awaiter_resolve( -- 3470
				nil, -- 3470
				actionNode:exec({ -- 3471
					path = path, -- 3472
					oldStr = oldStr, -- 3473
					newStr = newStr, -- 3474
					taskId = shared.taskId, -- 3475
					workDir = shared.workingDir -- 3476
				}) -- 3476
			) -- 3476
		end -- 3476
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3476
	end) -- 3476
end -- 3476
function emitAgentTaskFinishEvent(shared, success, message) -- 3623
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3624
	emitAgentEvent(shared, { -- 3630
		type = "task_finished", -- 3631
		sessionId = shared.sessionId, -- 3632
		taskId = shared.taskId, -- 3633
		success = result.success, -- 3634
		message = result.message, -- 3635
		steps = result.steps -- 3636
	}) -- 3636
	return result -- 3638
end -- 3638
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
	if __TS__StringTrim(argsText) == "" then -- 1703
		return {} -- 1705
	end -- 1705
	local rawObj, err = safeJsonDecode(argsText) -- 1707
	if err ~= nil or rawObj == nil then -- 1707
		return { -- 1709
			success = false, -- 1710
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1711
			raw = argsText -- 1712
		} -- 1712
	end -- 1712
	local encodedRaw = safeJsonEncode(rawObj) -- 1715
	if encodedRaw == "null" or not isRecord(rawObj) or isArray(rawObj) then -- 1715
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1717
	end -- 1717
	return rawObj -- 1723
end -- 1703
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1726
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1734
	if isRecord(rawArgs) and rawArgs.success == false then -- 1734
		return rawArgs -- 1736
	end -- 1736
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1738
	if not decision.success then -- 1738
		return {success = false, message = decision.message, raw = argsText} -- 1740
	end -- 1740
	local validation = validateDecision(decision.tool, decision.params) -- 1746
	if not validation.success then -- 1746
		return {success = false, message = validation.message, raw = argsText} -- 1748
	end -- 1748
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1748
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1755
	end -- 1755
	decision.params = validation.params -- 1761
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1762
	decision.reason = reason -- 1763
	decision.reasoningContent = reasoningContent -- 1764
	return decision -- 1765
end -- 1726
local function createPreExecutableActionFromStream(shared, toolCall) -- 1768
	local ____opt_38 = toolCall["function"] -- 1768
	local functionName = ____opt_38 and ____opt_38.name -- 1769
	local ____opt_40 = toolCall["function"] -- 1769
	local argsText = ____opt_40 and ____opt_40.arguments or "" -- 1770
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 1771
	if not functionName or not toolCallId then -- 1771
		return nil -- 1772
	end -- 1772
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1773
	if isRecord(rawArgs) and rawArgs.success == false then -- 1773
		return nil -- 1774
	end -- 1774
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1775
	if not decision.success or not canPreExecuteTool(decision.tool) then -- 1775
		return nil -- 1776
	end -- 1776
	local validation = validateDecision(decision.tool, decision.params) -- 1777
	if not validation.success then -- 1777
		return nil -- 1778
	end -- 1778
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1778
		return nil -- 1779
	end -- 1779
	return { -- 1780
		step = shared.step + 1, -- 1781
		toolCallId = toolCallId, -- 1782
		tool = decision.tool, -- 1783
		reason = "", -- 1784
		params = validation.params, -- 1785
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1786
	} -- 1786
end -- 1768
local function createFunctionToolSchema(name, description, properties, required) -- 1926
	if required == nil then -- 1926
		required = {} -- 1930
	end -- 1930
	local parameters = {type = "object", properties = properties} -- 1932
	if #required > 0 then -- 1932
		parameters.required = required -- 1937
	end -- 1937
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1939
end -- 1926
local function buildDecisionToolSchema(shared) -- 1955
	local allowed = getAllowedToolsForRole(shared.role) -- 1956
	local tools = { -- 1957
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 1958
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 1968
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 1978
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 1986
			path = {type = "string", description = "Base directory or file path to search within."}, -- 1990
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 1991
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 1992
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 1993
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 1994
			limit = {type = "number", description = "Maximum number of results to return."}, -- 1995
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 1996
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 1997
		}, {"pattern"}), -- 1997
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 2001
		createFunctionToolSchema( -- 2010
			"search_dora_api", -- 2011
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 2011
			{ -- 2013
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 2014
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 2015
				programmingLanguage = {type = "string", enum = { -- 2016
					"ts", -- 2018
					"tsx", -- 2018
					"lua", -- 2018
					"yue", -- 2018
					"teal", -- 2018
					"tl", -- 2018
					"wa" -- 2018
				}, description = "Preferred language variant to search."}, -- 2018
				limit = { -- 2021
					type = "number", -- 2021
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 2021
				}, -- 2021
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 2022
			}, -- 2022
			{"pattern"} -- 2024
		), -- 2024
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 2026
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 2033
			"active_or_recent", -- 2037
			"running", -- 2037
			"done", -- 2037
			"failed", -- 2037
			"all" -- 2037
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 2037
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 2043
	} -- 2043
	return __TS__ArrayFilter( -- 2055
		tools, -- 2055
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 2055
	) -- 2055
end -- 1955
local function sanitizeMessagesForLLMInput(messages) -- 2096
	local sanitized = {} -- 2097
	local droppedAssistantToolCalls = 0 -- 2098
	local droppedToolResults = 0 -- 2099
	do -- 2099
		local i = 0 -- 2100
		while i < #messages do -- 2100
			do -- 2100
				local message = messages[i + 1] -- 2101
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2101
					local requiredIds = {} -- 2103
					do -- 2103
						local j = 0 -- 2104
						while j < #message.tool_calls do -- 2104
							local toolCall = message.tool_calls[j + 1] -- 2105
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2106
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2106
								requiredIds[#requiredIds + 1] = id -- 2108
							end -- 2108
							j = j + 1 -- 2104
						end -- 2104
					end -- 2104
					if #requiredIds == 0 then -- 2104
						sanitized[#sanitized + 1] = message -- 2112
						goto __continue326 -- 2113
					end -- 2113
					local matchedIds = {} -- 2115
					local matchedTools = {} -- 2116
					local j = i + 1 -- 2117
					while j < #messages do -- 2117
						local toolMessage = messages[j + 1] -- 2119
						if toolMessage.role ~= "tool" then -- 2119
							break -- 2120
						end -- 2120
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2121
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2121
							matchedIds[toolCallId] = true -- 2123
							matchedTools[#matchedTools + 1] = toolMessage -- 2124
						else -- 2124
							droppedToolResults = droppedToolResults + 1 -- 2126
						end -- 2126
						j = j + 1 -- 2128
					end -- 2128
					local complete = true -- 2130
					do -- 2130
						local j = 0 -- 2131
						while j < #requiredIds do -- 2131
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2131
								complete = false -- 2133
								break -- 2134
							end -- 2134
							j = j + 1 -- 2131
						end -- 2131
					end -- 2131
					if complete then -- 2131
						__TS__ArrayPush( -- 2138
							sanitized, -- 2138
							message, -- 2138
							table.unpack(matchedTools) -- 2138
						) -- 2138
					else -- 2138
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2140
						droppedToolResults = droppedToolResults + #matchedTools -- 2141
					end -- 2141
					i = j - 1 -- 2143
					goto __continue326 -- 2144
				end -- 2144
				if message.role == "tool" then -- 2144
					droppedToolResults = droppedToolResults + 1 -- 2147
					goto __continue326 -- 2148
				end -- 2148
				sanitized[#sanitized + 1] = message -- 2150
			end -- 2150
			::__continue326:: -- 2150
			i = i + 1 -- 2100
		end -- 2100
	end -- 2100
	return sanitized -- 2152
end -- 2096
local function getUnconsolidatedMessages(shared) -- 2155
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2156
end -- 2155
local function getFinalDecisionTurnPrompt(shared) -- 2159
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2160
end -- 2159
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2165
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2165
		return messages -- 2166
	end -- 2166
	local next = __TS__ArrayMap( -- 2167
		messages, -- 2167
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2167
	) -- 2167
	do -- 2167
		local i = #next - 1 -- 2168
		while i >= 0 do -- 2168
			do -- 2168
				local message = next[i + 1] -- 2169
				if message.role ~= "assistant" and message.role ~= "user" then -- 2169
					goto __continue348 -- 2170
				end -- 2170
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2171
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2172
				return next -- 2175
			end -- 2175
			::__continue348:: -- 2175
			i = i - 1 -- 2168
		end -- 2168
	end -- 2168
	next[#next + 1] = {role = "user", content = prompt} -- 2177
	return next -- 2178
end -- 2165
local function buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2181
	if attempt == nil then -- 2181
		attempt = 1 -- 2181
	end -- 2181
	local messages = { -- 2182
		{ -- 2183
			role = "system", -- 2183
			content = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 2183
		}, -- 2183
		table.unpack(getUnconsolidatedMessages(shared)) -- 2184
	} -- 2184
	if shared.step + 1 >= shared.maxSteps then -- 2184
		messages = appendPromptToLatestDecisionMessage( -- 2187
			messages, -- 2187
			getFinalDecisionTurnPrompt(shared) -- 2187
		) -- 2187
	end -- 2187
	if lastError and lastError ~= "" then -- 2187
		local retryHeader = shared.decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2190
		messages[#messages + 1] = { -- 2193
			role = "user", -- 2194
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2195
		} -- 2195
	end -- 2195
	return messages -- 2202
end -- 2181
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2209
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2216
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2217
	local repairPrompt = replacePromptVars( -- 2225
		shared.promptPack.xmlDecisionRepairPrompt, -- 2225
		{ -- 2225
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2226
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2227
			CANDIDATE_SECTION = candidateSection, -- 2228
			LAST_ERROR = lastError, -- 2229
			ATTEMPT = tostring(attempt) -- 2230
		} -- 2230
	) -- 2230
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2232
end -- 2209
local function tryParseAndValidateDecision(rawText) -- 2244
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2245
	if not parsed.success then -- 2245
		return {success = false, message = parsed.message, raw = rawText} -- 2247
	end -- 2247
	local decision = parseDecisionObject(parsed.obj) -- 2249
	if not decision.success then -- 2249
		return {success = false, message = decision.message, raw = rawText} -- 2251
	end -- 2251
	local validation = validateDecision(decision.tool, decision.params) -- 2253
	if not validation.success then -- 2253
		return {success = false, message = validation.message, raw = rawText} -- 2255
	end -- 2255
	decision.params = validation.params -- 2257
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2258
	return decision -- 2259
end -- 2244
local function normalizeLineEndings(text) -- 2262
	local res = string.gsub(text, "\r\n", "\n") -- 2263
	res = string.gsub(res, "\r", "\n") -- 2264
	return res -- 2265
end -- 2262
local function countOccurrences(text, searchStr) -- 2268
	if searchStr == "" then -- 2268
		return 0 -- 2269
	end -- 2269
	local count = 0 -- 2270
	local pos = 0 -- 2271
	while true do -- 2271
		local idx = (string.find( -- 2273
			text, -- 2273
			searchStr, -- 2273
			math.max(pos + 1, 1), -- 2273
			true -- 2273
		) or 0) - 1 -- 2273
		if idx < 0 then -- 2273
			break -- 2274
		end -- 2274
		count = count + 1 -- 2275
		pos = idx + #searchStr -- 2276
	end -- 2276
	return count -- 2278
end -- 2268
local function replaceFirst(text, oldStr, newStr) -- 2281
	if oldStr == "" then -- 2281
		return text -- 2282
	end -- 2282
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2283
	if idx < 0 then -- 2283
		return text -- 2284
	end -- 2284
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2285
end -- 2281
local function splitLines(text) -- 2288
	return __TS__StringSplit(text, "\n") -- 2289
end -- 2288
local function getLeadingWhitespace(text) -- 2292
	local i = 0 -- 2293
	while i < #text do -- 2293
		local ch = __TS__StringAccess(text, i) -- 2295
		if ch ~= " " and ch ~= "\t" then -- 2295
			break -- 2296
		end -- 2296
		i = i + 1 -- 2297
	end -- 2297
	return __TS__StringSubstring(text, 0, i) -- 2299
end -- 2292
local function getCommonIndentPrefix(lines) -- 2302
	local common -- 2303
	do -- 2303
		local i = 0 -- 2304
		while i < #lines do -- 2304
			do -- 2304
				local line = lines[i + 1] -- 2305
				if __TS__StringTrim(line) == "" then -- 2305
					goto __continue373 -- 2306
				end -- 2306
				local indent = getLeadingWhitespace(line) -- 2307
				if common == nil then -- 2307
					common = indent -- 2309
					goto __continue373 -- 2310
				end -- 2310
				local j = 0 -- 2312
				local maxLen = math.min(#common, #indent) -- 2313
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2313
					j = j + 1 -- 2315
				end -- 2315
				common = __TS__StringSubstring(common, 0, j) -- 2317
				if common == "" then -- 2317
					break -- 2318
				end -- 2318
			end -- 2318
			::__continue373:: -- 2318
			i = i + 1 -- 2304
		end -- 2304
	end -- 2304
	return common or "" -- 2320
end -- 2302
local function removeIndentPrefix(line, indent) -- 2323
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2323
		return __TS__StringSubstring(line, #indent) -- 2325
	end -- 2325
	local lineIndent = getLeadingWhitespace(line) -- 2327
	local j = 0 -- 2328
	local maxLen = math.min(#lineIndent, #indent) -- 2329
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2329
		j = j + 1 -- 2331
	end -- 2331
	return __TS__StringSubstring(line, j) -- 2333
end -- 2323
local function dedentLines(lines) -- 2336
	local indent = getCommonIndentPrefix(lines) -- 2337
	return { -- 2338
		indent = indent, -- 2339
		lines = __TS__ArrayMap( -- 2340
			lines, -- 2340
			function(____, line) return removeIndentPrefix(line, indent) end -- 2340
		) -- 2340
	} -- 2340
end -- 2336
local function joinLines(lines) -- 2344
	return table.concat(lines, "\n") -- 2345
end -- 2344
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2348
	local contentLines = splitLines(content) -- 2353
	local oldLines = splitLines(oldStr) -- 2354
	if #oldLines == 0 then -- 2354
		return {success = false, message = "old_str not found in file"} -- 2356
	end -- 2356
	local dedentedOld = dedentLines(oldLines) -- 2358
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2359
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2360
	local matches = {} -- 2361
	do -- 2361
		local start = 0 -- 2362
		while start <= #contentLines - #oldLines do -- 2362
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2363
			local dedentedCandidate = dedentLines(candidateLines) -- 2364
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2364
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2366
			end -- 2366
			start = start + 1 -- 2362
		end -- 2362
	end -- 2362
	if #matches == 0 then -- 2362
		return {success = false, message = "old_str not found in file"} -- 2374
	end -- 2374
	if #matches > 1 then -- 2374
		return { -- 2377
			success = false, -- 2378
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2379
		} -- 2379
	end -- 2379
	local match = matches[1] -- 2382
	local rebuiltNewLines = __TS__ArrayMap( -- 2383
		dedentedNew.lines, -- 2383
		function(____, line) return line == "" and "" or match.indent .. line end -- 2383
	) -- 2383
	local ____array_46 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2383
	__TS__SparseArrayPush( -- 2383
		____array_46, -- 2383
		table.unpack(rebuiltNewLines) -- 2386
	) -- 2386
	__TS__SparseArrayPush( -- 2386
		____array_46, -- 2386
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2387
	) -- 2387
	local nextLines = {__TS__SparseArraySpread(____array_46)} -- 2384
	return { -- 2389
		success = true, -- 2389
		content = joinLines(nextLines) -- 2389
	} -- 2389
end -- 2348
local MainDecisionAgent = __TS__Class() -- 2392
MainDecisionAgent.name = "MainDecisionAgent" -- 2392
__TS__ClassExtends(MainDecisionAgent, Node) -- 2392
function MainDecisionAgent.prototype.prep(self, shared) -- 2393
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2393
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2393
			return ____awaiter_resolve(nil, {shared = shared}) -- 2393
		end -- 2393
		__TS__Await(maybeCompressHistory(shared)) -- 2398
		return ____awaiter_resolve(nil, {shared = shared}) -- 2398
	end) -- 2398
end -- 2393
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2403
	if attempt == nil then -- 2403
		attempt = 1 -- 2406
	end -- 2406
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2406
		if shared.stopToken.stopped then -- 2406
			return ____awaiter_resolve( -- 2406
				nil, -- 2406
				{ -- 2410
					success = false, -- 2410
					message = getCancelledReason(shared) -- 2410
				} -- 2410
			) -- 2410
		end -- 2410
		Log( -- 2412
			"Info", -- 2412
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2412
		) -- 2412
		local tools = buildDecisionToolSchema(shared) -- 2413
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2414
		local stepId = shared.step + 1 -- 2415
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2416
		saveStepLLMDebugInput( -- 2420
			shared, -- 2420
			stepId, -- 2420
			"decision_tool_calling", -- 2420
			messages, -- 2420
			llmOptions -- 2420
		) -- 2420
		local lastStreamContent = "" -- 2421
		local lastStreamReasoning = "" -- 2422
		local preExecutedResults = __TS__New(Map) -- 2423
		shared.preExecutedResults = preExecutedResults -- 2424
		local res = __TS__Await(callLLMStreamAggregated( -- 2425
			messages, -- 2426
			llmOptions, -- 2427
			shared.stopToken, -- 2428
			shared.llmConfig, -- 2429
			function(response) -- 2430
				local ____opt_49 = response.choices -- 2430
				local ____opt_47 = ____opt_49 and ____opt_49[1] -- 2430
				local streamMessage = ____opt_47 and ____opt_47.message -- 2431
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2432
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2435
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2435
					return -- 2439
				end -- 2439
				lastStreamContent = nextContent -- 2441
				lastStreamReasoning = nextReasoning -- 2442
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2443
			end, -- 2430
			function(tc) -- 2445
				if shared.stopToken.stopped then -- 2445
					return -- 2446
				end -- 2446
				local action = createPreExecutableActionFromStream(shared, tc) -- 2447
				if not action or preExecutedResults:has(action.toolCallId) then -- 2447
					return -- 2448
				end -- 2448
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2449
				preExecutedResults:set( -- 2450
					action.toolCallId, -- 2450
					startPreExecutedToolAction(shared, action) -- 2450
				) -- 2450
			end -- 2445
		)) -- 2445
		if shared.stopToken.stopped then -- 2445
			clearPreExecutedResults(shared) -- 2454
			return ____awaiter_resolve( -- 2454
				nil, -- 2454
				{ -- 2455
					success = false, -- 2455
					message = getCancelledReason(shared) -- 2455
				} -- 2455
			) -- 2455
		end -- 2455
		if not res.success then -- 2455
			saveStepLLMDebugOutput( -- 2458
				shared, -- 2458
				stepId, -- 2458
				"decision_tool_calling", -- 2458
				res.raw or res.message, -- 2458
				{success = false} -- 2458
			) -- 2458
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2459
			clearPreExecutedResults(shared) -- 2460
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2460
		end -- 2460
		saveStepLLMDebugOutput( -- 2463
			shared, -- 2463
			stepId, -- 2463
			"decision_tool_calling", -- 2463
			encodeDebugJSON(res.response), -- 2463
			{success = true} -- 2463
		) -- 2463
		local choice = res.response.choices and res.response.choices[1] -- 2464
		local message = choice and choice.message -- 2465
		local toolCalls = message and message.tool_calls -- 2466
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2467
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2470
		Log( -- 2473
			"Info", -- 2473
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2473
		) -- 2473
		if not toolCalls or #toolCalls == 0 then -- 2473
			if messageContent and messageContent ~= "" then -- 2473
				Log( -- 2476
					"Info", -- 2476
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2476
				) -- 2476
				clearPreExecutedResults(shared) -- 2477
				return ____awaiter_resolve(nil, { -- 2477
					success = true, -- 2479
					tool = "finish", -- 2480
					params = {}, -- 2481
					reason = messageContent, -- 2482
					reasoningContent = reasoningContent, -- 2483
					directSummary = messageContent -- 2484
				}) -- 2484
			end -- 2484
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2487
			clearPreExecutedResults(shared) -- 2488
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = messageContent}) -- 2488
		end -- 2488
		local decisions = {} -- 2495
		do -- 2495
			local i = 0 -- 2496
			while i < #toolCalls do -- 2496
				local toolCall = toolCalls[i + 1] -- 2497
				local fn = toolCall and toolCall["function"] -- 2498
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2498
					Log( -- 2500
						"Error", -- 2500
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2500
					) -- 2500
					clearPreExecutedResults(shared) -- 2501
					return ____awaiter_resolve( -- 2501
						nil, -- 2501
						{ -- 2502
							success = false, -- 2503
							message = "missing function name for tool call " .. tostring(i + 1), -- 2504
							raw = messageContent -- 2505
						} -- 2505
					) -- 2505
				end -- 2505
				local functionName = fn.name -- 2508
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2509
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2510
				Log( -- 2513
					"Info", -- 2513
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2513
				) -- 2513
				local decision = parseAndValidateToolCallDecision( -- 2514
					shared, -- 2515
					functionName, -- 2516
					argsText, -- 2517
					toolCallId, -- 2518
					messageContent, -- 2519
					reasoningContent -- 2520
				) -- 2520
				if not decision.success then -- 2520
					Log( -- 2523
						"Error", -- 2523
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2523
					) -- 2523
					clearPreExecutedResults(shared) -- 2524
					return ____awaiter_resolve(nil, decision) -- 2524
				end -- 2524
				decisions[#decisions + 1] = decision -- 2527
				i = i + 1 -- 2496
			end -- 2496
		end -- 2496
		if #decisions == 1 then -- 2496
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2530
			return ____awaiter_resolve(nil, decisions[1]) -- 2530
		end -- 2530
		do -- 2530
			local i = 0 -- 2533
			while i < #decisions do -- 2533
				if decisions[i + 1].tool == "finish" then -- 2533
					clearPreExecutedResults(shared) -- 2535
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2535
				end -- 2535
				i = i + 1 -- 2533
			end -- 2533
		end -- 2533
		Log( -- 2543
			"Info", -- 2543
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2543
				__TS__ArrayMap( -- 2543
					decisions, -- 2543
					function(____, decision) return decision.tool end -- 2543
				), -- 2543
				"," -- 2543
			) -- 2543
		) -- 2543
		return ____awaiter_resolve(nil, { -- 2543
			success = true, -- 2545
			kind = "batch", -- 2546
			decisions = decisions, -- 2547
			content = messageContent, -- 2548
			reasoningContent = reasoningContent -- 2549
		}) -- 2549
	end) -- 2549
end -- 2403
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2553
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2553
		Log( -- 2558
			"Info", -- 2558
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2558
		) -- 2558
		local lastError = initialError -- 2559
		local candidateRaw = "" -- 2560
		do -- 2560
			local attempt = 0 -- 2561
			while attempt < shared.llmMaxTry do -- 2561
				do -- 2561
					Log( -- 2562
						"Info", -- 2562
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2562
					) -- 2562
					local messages = buildXmlRepairMessages( -- 2563
						shared, -- 2564
						originalRaw, -- 2565
						candidateRaw, -- 2566
						lastError, -- 2567
						attempt + 1 -- 2568
					) -- 2568
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2570
					if shared.stopToken.stopped then -- 2570
						return ____awaiter_resolve( -- 2570
							nil, -- 2570
							{ -- 2572
								success = false, -- 2572
								message = getCancelledReason(shared) -- 2572
							} -- 2572
						) -- 2572
					end -- 2572
					if not llmRes.success then -- 2572
						lastError = llmRes.message -- 2575
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2576
						goto __continue416 -- 2577
					end -- 2577
					candidateRaw = llmRes.text -- 2579
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2580
					if decision.success then -- 2580
						decision.reasoningContent = llmRes.reasoningContent -- 2582
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2583
						return ____awaiter_resolve(nil, decision) -- 2583
					end -- 2583
					lastError = decision.message -- 2586
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2587
				end -- 2587
				::__continue416:: -- 2587
				attempt = attempt + 1 -- 2561
			end -- 2561
		end -- 2561
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2589
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2589
	end) -- 2589
end -- 2553
function MainDecisionAgent.prototype.exec(self, input) -- 2597
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2597
		local shared = input.shared -- 2598
		if shared.stopToken.stopped then -- 2598
			return ____awaiter_resolve( -- 2598
				nil, -- 2598
				{ -- 2600
					success = false, -- 2600
					message = getCancelledReason(shared) -- 2600
				} -- 2600
			) -- 2600
		end -- 2600
		if shared.step >= shared.maxSteps then -- 2600
			Log( -- 2603
				"Warn", -- 2603
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2603
			) -- 2603
			return ____awaiter_resolve( -- 2603
				nil, -- 2603
				{ -- 2604
					success = false, -- 2604
					message = getMaxStepsReachedReason(shared) -- 2604
				} -- 2604
			) -- 2604
		end -- 2604
		if shared.decisionMode == "tool_calling" then -- 2604
			Log( -- 2608
				"Info", -- 2608
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2608
			) -- 2608
			local lastError = "tool calling validation failed" -- 2609
			local lastRaw = "" -- 2610
			do -- 2610
				local attempt = 0 -- 2611
				while attempt < shared.llmMaxTry do -- 2611
					Log( -- 2612
						"Info", -- 2612
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2612
					) -- 2612
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2613
					if shared.stopToken.stopped then -- 2613
						return ____awaiter_resolve( -- 2613
							nil, -- 2613
							{ -- 2620
								success = false, -- 2620
								message = getCancelledReason(shared) -- 2620
							} -- 2620
						) -- 2620
					end -- 2620
					if decision.success then -- 2620
						return ____awaiter_resolve(nil, decision) -- 2620
					end -- 2620
					lastError = decision.message -- 2625
					lastRaw = decision.raw or "" -- 2626
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2627
					attempt = attempt + 1 -- 2611
				end -- 2611
			end -- 2611
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2629
			return ____awaiter_resolve( -- 2629
				nil, -- 2629
				{ -- 2630
					success = false, -- 2630
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2630
				} -- 2630
			) -- 2630
		end -- 2630
		local lastError = "xml validation failed" -- 2633
		local lastRaw = "" -- 2634
		do -- 2634
			local attempt = 0 -- 2635
			while attempt < shared.llmMaxTry do -- 2635
				do -- 2635
					local messages = buildDecisionMessages(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw) -- 2636
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2644
					if shared.stopToken.stopped then -- 2644
						return ____awaiter_resolve( -- 2644
							nil, -- 2644
							{ -- 2646
								success = false, -- 2646
								message = getCancelledReason(shared) -- 2646
							} -- 2646
						) -- 2646
					end -- 2646
					if not llmRes.success then -- 2646
						lastError = llmRes.message -- 2649
						lastRaw = llmRes.text or "" -- 2650
						goto __continue429 -- 2651
					end -- 2651
					lastRaw = llmRes.text -- 2653
					local decision = tryParseAndValidateDecision(llmRes.text) -- 2654
					if decision.success then -- 2654
						decision.reasoningContent = llmRes.reasoningContent -- 2656
						if not isToolAllowedForRole(shared.role, decision.tool) then -- 2656
							lastError = (decision.tool .. " is not allowed for role ") .. shared.role -- 2658
							return ____awaiter_resolve( -- 2658
								nil, -- 2658
								self:repairDecisionXml(shared, llmRes.text, lastError) -- 2659
							) -- 2659
						end -- 2659
						return ____awaiter_resolve(nil, decision) -- 2659
					end -- 2659
					lastError = decision.message -- 2663
					return ____awaiter_resolve( -- 2663
						nil, -- 2663
						self:repairDecisionXml(shared, llmRes.text, lastError) -- 2664
					) -- 2664
				end -- 2664
				::__continue429:: -- 2664
				attempt = attempt + 1 -- 2635
			end -- 2635
		end -- 2635
		return ____awaiter_resolve( -- 2635
			nil, -- 2635
			{ -- 2666
				success = false, -- 2666
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2666
			} -- 2666
		) -- 2666
	end) -- 2666
end -- 2597
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2669
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2669
		local result = execRes -- 2670
		if not result.success then -- 2670
			if shared.stopToken.stopped then -- 2670
				shared.error = getCancelledReason(shared) -- 2673
				shared.done = true -- 2674
				return ____awaiter_resolve(nil, "done") -- 2674
			end -- 2674
			shared.error = result.message -- 2677
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2678
			shared.done = true -- 2679
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2680
			persistHistoryState(shared) -- 2684
			return ____awaiter_resolve(nil, "done") -- 2684
		end -- 2684
		if isDecisionBatchSuccess(result) then -- 2684
			local startStep = shared.step -- 2688
			local actions = {} -- 2689
			do -- 2689
				local i = 0 -- 2690
				while i < #result.decisions do -- 2690
					local decision = result.decisions[i + 1] -- 2691
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2692
					local step = startStep + i + 1 -- 2693
					local ____temp_55 -- 2694
					if i == 0 then -- 2694
						____temp_55 = decision.reason -- 2694
					else -- 2694
						____temp_55 = "" -- 2694
					end -- 2694
					local actionReason = ____temp_55 -- 2694
					local ____temp_56 -- 2695
					if i == 0 then -- 2695
						____temp_56 = decision.reasoningContent -- 2695
					else -- 2695
						____temp_56 = nil -- 2695
					end -- 2695
					local actionReasoningContent = ____temp_56 -- 2695
					emitAgentEvent(shared, { -- 2696
						type = "decision_made", -- 2697
						sessionId = shared.sessionId, -- 2698
						taskId = shared.taskId, -- 2699
						step = step, -- 2700
						tool = decision.tool, -- 2701
						reason = actionReason, -- 2702
						reasoningContent = actionReasoningContent, -- 2703
						params = decision.params -- 2704
					}) -- 2704
					local action = { -- 2706
						step = step, -- 2707
						toolCallId = toolCallId, -- 2708
						tool = decision.tool, -- 2709
						reason = actionReason or "", -- 2710
						reasoningContent = actionReasoningContent, -- 2711
						params = decision.params, -- 2712
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2713
					} -- 2713
					local ____shared_history_57 = shared.history -- 2713
					____shared_history_57[#____shared_history_57 + 1] = action -- 2715
					actions[#actions + 1] = action -- 2716
					i = i + 1 -- 2690
				end -- 2690
			end -- 2690
			shared.step = startStep + #actions -- 2718
			shared.pendingToolActions = actions -- 2719
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2720
			persistHistoryState(shared) -- 2726
			return ____awaiter_resolve(nil, "batch_tools") -- 2726
		end -- 2726
		if result.directSummary and result.directSummary ~= "" then -- 2726
			shared.response = result.directSummary -- 2730
			shared.done = true -- 2731
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2732
			persistHistoryState(shared) -- 2737
			return ____awaiter_resolve(nil, "done") -- 2737
		end -- 2737
		if result.tool == "finish" then -- 2737
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2741
			shared.response = finalMessage -- 2742
			shared.done = true -- 2743
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2744
			persistHistoryState(shared) -- 2749
			return ____awaiter_resolve(nil, "done") -- 2749
		end -- 2749
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2752
		shared.step = shared.step + 1 -- 2753
		local step = shared.step -- 2754
		emitAgentEvent(shared, { -- 2755
			type = "decision_made", -- 2756
			sessionId = shared.sessionId, -- 2757
			taskId = shared.taskId, -- 2758
			step = step, -- 2759
			tool = result.tool, -- 2760
			reason = result.reason, -- 2761
			reasoningContent = result.reasoningContent, -- 2762
			params = result.params -- 2763
		}) -- 2763
		local ____shared_history_58 = shared.history -- 2763
		____shared_history_58[#____shared_history_58 + 1] = { -- 2765
			step = step, -- 2766
			toolCallId = toolCallId, -- 2767
			tool = result.tool, -- 2768
			reason = result.reason or "", -- 2769
			reasoningContent = result.reasoningContent, -- 2770
			params = result.params, -- 2771
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2772
		} -- 2772
		local action = shared.history[#shared.history] -- 2774
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 2775
		if canPreExecuteTool(action.tool) then -- 2775
			shared.pendingToolActions = {action} -- 2777
			persistHistoryState(shared) -- 2778
			return ____awaiter_resolve(nil, "batch_tools") -- 2778
		end -- 2778
		clearPreExecutedResults(shared) -- 2781
		persistHistoryState(shared) -- 2782
		return ____awaiter_resolve(nil, result.tool) -- 2782
	end) -- 2782
end -- 2669
local ReadFileAction = __TS__Class() -- 2787
ReadFileAction.name = "ReadFileAction" -- 2787
__TS__ClassExtends(ReadFileAction, Node) -- 2787
function ReadFileAction.prototype.prep(self, shared) -- 2788
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2788
		local last = shared.history[#shared.history] -- 2789
		if not last then -- 2789
			error( -- 2790
				__TS__New(Error, "no history"), -- 2790
				0 -- 2790
			) -- 2790
		end -- 2790
		emitAgentStartEvent(shared, last) -- 2791
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2792
		if __TS__StringTrim(path) == "" then -- 2792
			error( -- 2795
				__TS__New(Error, "missing path"), -- 2795
				0 -- 2795
			) -- 2795
		end -- 2795
		local ____path_61 = path -- 2797
		local ____shared_workingDir_62 = shared.workingDir -- 2799
		local ____temp_63 = shared.useChineseResponse and "zh" or "en" -- 2800
		local ____last_params_startLine_59 = last.params.startLine -- 2801
		if ____last_params_startLine_59 == nil then -- 2801
			____last_params_startLine_59 = 1 -- 2801
		end -- 2801
		local ____TS__Number_result_64 = __TS__Number(____last_params_startLine_59) -- 2801
		local ____last_params_endLine_60 = last.params.endLine -- 2802
		if ____last_params_endLine_60 == nil then -- 2802
			____last_params_endLine_60 = READ_FILE_DEFAULT_LIMIT -- 2802
		end -- 2802
		return ____awaiter_resolve( -- 2802
			nil, -- 2802
			{ -- 2796
				path = ____path_61, -- 2797
				tool = "read_file", -- 2798
				workDir = ____shared_workingDir_62, -- 2799
				docLanguage = ____temp_63, -- 2800
				startLine = ____TS__Number_result_64, -- 2801
				endLine = __TS__Number(____last_params_endLine_60) -- 2802
			} -- 2802
		) -- 2802
	end) -- 2802
end -- 2788
function ReadFileAction.prototype.exec(self, input) -- 2806
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2806
		return ____awaiter_resolve( -- 2806
			nil, -- 2806
			Tools.readFile( -- 2807
				input.workDir, -- 2808
				input.path, -- 2809
				__TS__Number(input.startLine or 1), -- 2810
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2811
				input.docLanguage -- 2812
			) -- 2812
		) -- 2812
	end) -- 2812
end -- 2806
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2816
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2816
		local result = execRes -- 2817
		local last = shared.history[#shared.history] -- 2818
		if last ~= nil then -- 2818
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2820
			appendToolResultMessage(shared, last) -- 2821
			emitAgentFinishEvent(shared, last) -- 2822
		end -- 2822
		persistHistoryState(shared) -- 2824
		__TS__Await(maybeCompressHistory(shared)) -- 2825
		persistHistoryState(shared) -- 2826
		return ____awaiter_resolve(nil, "main") -- 2826
	end) -- 2826
end -- 2816
local SearchFilesAction = __TS__Class() -- 2831
SearchFilesAction.name = "SearchFilesAction" -- 2831
__TS__ClassExtends(SearchFilesAction, Node) -- 2831
function SearchFilesAction.prototype.prep(self, shared) -- 2832
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2832
		local last = shared.history[#shared.history] -- 2833
		if not last then -- 2833
			error( -- 2834
				__TS__New(Error, "no history"), -- 2834
				0 -- 2834
			) -- 2834
		end -- 2834
		emitAgentStartEvent(shared, last) -- 2835
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2835
	end) -- 2835
end -- 2832
function SearchFilesAction.prototype.exec(self, input) -- 2839
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2839
		local params = input.params -- 2840
		local ____Tools_searchFiles_78 = Tools.searchFiles -- 2841
		local ____input_workDir_71 = input.workDir -- 2842
		local ____temp_72 = params.path or "" -- 2843
		local ____temp_73 = params.pattern or "" -- 2844
		local ____params_globs_74 = params.globs -- 2845
		local ____params_useRegex_75 = params.useRegex -- 2846
		local ____params_caseSensitive_76 = params.caseSensitive -- 2847
		local ____math_max_67 = math.max -- 2850
		local ____math_floor_66 = math.floor -- 2850
		local ____params_limit_65 = params.limit -- 2850
		if ____params_limit_65 == nil then -- 2850
			____params_limit_65 = SEARCH_FILES_LIMIT_DEFAULT -- 2850
		end -- 2850
		local ____math_max_67_result_77 = ____math_max_67( -- 2850
			1, -- 2850
			____math_floor_66(__TS__Number(____params_limit_65)) -- 2850
		) -- 2850
		local ____math_max_70 = math.max -- 2851
		local ____math_floor_69 = math.floor -- 2851
		local ____params_offset_68 = params.offset -- 2851
		if ____params_offset_68 == nil then -- 2851
			____params_offset_68 = 0 -- 2851
		end -- 2851
		local result = __TS__Await(____Tools_searchFiles_78({ -- 2841
			workDir = ____input_workDir_71, -- 2842
			path = ____temp_72, -- 2843
			pattern = ____temp_73, -- 2844
			globs = ____params_globs_74, -- 2845
			useRegex = ____params_useRegex_75, -- 2846
			caseSensitive = ____params_caseSensitive_76, -- 2847
			includeContent = true, -- 2848
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2849
			limit = ____math_max_67_result_77, -- 2850
			offset = ____math_max_70( -- 2851
				0, -- 2851
				____math_floor_69(__TS__Number(____params_offset_68)) -- 2851
			), -- 2851
			groupByFile = params.groupByFile == true -- 2852
		})) -- 2852
		return ____awaiter_resolve(nil, result) -- 2852
	end) -- 2852
end -- 2839
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2857
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2857
		local last = shared.history[#shared.history] -- 2858
		if last ~= nil then -- 2858
			local result = execRes -- 2860
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2861
			appendToolResultMessage(shared, last) -- 2862
			emitAgentFinishEvent(shared, last) -- 2863
		end -- 2863
		persistHistoryState(shared) -- 2865
		__TS__Await(maybeCompressHistory(shared)) -- 2866
		persistHistoryState(shared) -- 2867
		return ____awaiter_resolve(nil, "main") -- 2867
	end) -- 2867
end -- 2857
local SearchDoraAPIAction = __TS__Class() -- 2872
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2872
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2872
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2873
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2873
		local last = shared.history[#shared.history] -- 2874
		if not last then -- 2874
			error( -- 2875
				__TS__New(Error, "no history"), -- 2875
				0 -- 2875
			) -- 2875
		end -- 2875
		emitAgentStartEvent(shared, last) -- 2876
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2876
	end) -- 2876
end -- 2873
function SearchDoraAPIAction.prototype.exec(self, input) -- 2880
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2880
		local params = input.params -- 2881
		local ____Tools_searchDoraAPI_86 = Tools.searchDoraAPI -- 2882
		local ____temp_82 = params.pattern or "" -- 2883
		local ____temp_83 = params.docSource or "api" -- 2884
		local ____temp_84 = input.useChineseResponse and "zh" or "en" -- 2885
		local ____temp_85 = params.programmingLanguage or "ts" -- 2886
		local ____math_min_81 = math.min -- 2887
		local ____math_max_80 = math.max -- 2887
		local ____params_limit_79 = params.limit -- 2887
		if ____params_limit_79 == nil then -- 2887
			____params_limit_79 = 8 -- 2887
		end -- 2887
		local result = __TS__Await(____Tools_searchDoraAPI_86({ -- 2882
			pattern = ____temp_82, -- 2883
			docSource = ____temp_83, -- 2884
			docLanguage = ____temp_84, -- 2885
			programmingLanguage = ____temp_85, -- 2886
			limit = ____math_min_81( -- 2887
				SEARCH_DORA_API_LIMIT_MAX, -- 2887
				____math_max_80( -- 2887
					1, -- 2887
					__TS__Number(____params_limit_79) -- 2887
				) -- 2887
			), -- 2887
			useRegex = params.useRegex, -- 2888
			caseSensitive = false, -- 2889
			includeContent = true, -- 2890
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2891
		})) -- 2891
		return ____awaiter_resolve(nil, result) -- 2891
	end) -- 2891
end -- 2880
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2896
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2896
		local last = shared.history[#shared.history] -- 2897
		if last ~= nil then -- 2897
			local result = execRes -- 2899
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2900
			appendToolResultMessage(shared, last) -- 2901
			emitAgentFinishEvent(shared, last) -- 2902
		end -- 2902
		persistHistoryState(shared) -- 2904
		__TS__Await(maybeCompressHistory(shared)) -- 2905
		persistHistoryState(shared) -- 2906
		return ____awaiter_resolve(nil, "main") -- 2906
	end) -- 2906
end -- 2896
local ListFilesAction = __TS__Class() -- 2911
ListFilesAction.name = "ListFilesAction" -- 2911
__TS__ClassExtends(ListFilesAction, Node) -- 2911
function ListFilesAction.prototype.prep(self, shared) -- 2912
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2912
		local last = shared.history[#shared.history] -- 2913
		if not last then -- 2913
			error( -- 2914
				__TS__New(Error, "no history"), -- 2914
				0 -- 2914
			) -- 2914
		end -- 2914
		emitAgentStartEvent(shared, last) -- 2915
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2915
	end) -- 2915
end -- 2912
function ListFilesAction.prototype.exec(self, input) -- 2919
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2919
		local params = input.params -- 2920
		local ____Tools_listFiles_93 = Tools.listFiles -- 2921
		local ____input_workDir_90 = input.workDir -- 2922
		local ____temp_91 = params.path or "" -- 2923
		local ____params_globs_92 = params.globs -- 2924
		local ____math_max_89 = math.max -- 2925
		local ____math_floor_88 = math.floor -- 2925
		local ____params_maxEntries_87 = params.maxEntries -- 2925
		if ____params_maxEntries_87 == nil then -- 2925
			____params_maxEntries_87 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2925
		end -- 2925
		local result = ____Tools_listFiles_93({ -- 2921
			workDir = ____input_workDir_90, -- 2922
			path = ____temp_91, -- 2923
			globs = ____params_globs_92, -- 2924
			maxEntries = ____math_max_89( -- 2925
				1, -- 2925
				____math_floor_88(__TS__Number(____params_maxEntries_87)) -- 2925
			) -- 2925
		}) -- 2925
		return ____awaiter_resolve(nil, result) -- 2925
	end) -- 2925
end -- 2919
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2930
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2930
		local last = shared.history[#shared.history] -- 2931
		if last ~= nil then -- 2931
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2933
			appendToolResultMessage(shared, last) -- 2934
			emitAgentFinishEvent(shared, last) -- 2935
		end -- 2935
		persistHistoryState(shared) -- 2937
		__TS__Await(maybeCompressHistory(shared)) -- 2938
		persistHistoryState(shared) -- 2939
		return ____awaiter_resolve(nil, "main") -- 2939
	end) -- 2939
end -- 2930
local DeleteFileAction = __TS__Class() -- 2944
DeleteFileAction.name = "DeleteFileAction" -- 2944
__TS__ClassExtends(DeleteFileAction, Node) -- 2944
function DeleteFileAction.prototype.prep(self, shared) -- 2945
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2945
		local last = shared.history[#shared.history] -- 2946
		if not last then -- 2946
			error( -- 2947
				__TS__New(Error, "no history"), -- 2947
				0 -- 2947
			) -- 2947
		end -- 2947
		emitAgentStartEvent(shared, last) -- 2948
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 2949
		if __TS__StringTrim(targetFile) == "" then -- 2949
			error( -- 2952
				__TS__New(Error, "missing target_file"), -- 2952
				0 -- 2952
			) -- 2952
		end -- 2952
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 2952
	end) -- 2952
end -- 2945
function DeleteFileAction.prototype.exec(self, input) -- 2956
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2956
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 2957
		if not result.success then -- 2957
			return ____awaiter_resolve(nil, result) -- 2957
		end -- 2957
		return ____awaiter_resolve(nil, { -- 2957
			success = true, -- 2965
			changed = true, -- 2966
			mode = "delete", -- 2967
			checkpointId = result.checkpointId, -- 2968
			checkpointSeq = result.checkpointSeq, -- 2969
			files = {{path = input.targetFile, op = "delete"}} -- 2970
		}) -- 2970
	end) -- 2970
end -- 2956
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2974
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2974
		local last = shared.history[#shared.history] -- 2975
		if last ~= nil then -- 2975
			last.result = execRes -- 2977
			appendToolResultMessage(shared, last) -- 2978
			emitAgentFinishEvent(shared, last) -- 2979
			local result = last.result -- 2980
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 2980
				emitAgentEvent(shared, { -- 2985
					type = "checkpoint_created", -- 2986
					sessionId = shared.sessionId, -- 2987
					taskId = shared.taskId, -- 2988
					step = last.step, -- 2989
					tool = "delete_file", -- 2990
					checkpointId = result.checkpointId, -- 2991
					checkpointSeq = result.checkpointSeq, -- 2992
					files = result.files -- 2993
				}) -- 2993
			end -- 2993
		end -- 2993
		persistHistoryState(shared) -- 2997
		__TS__Await(maybeCompressHistory(shared)) -- 2998
		persistHistoryState(shared) -- 2999
		return ____awaiter_resolve(nil, "main") -- 2999
	end) -- 2999
end -- 2974
local BuildAction = __TS__Class() -- 3004
BuildAction.name = "BuildAction" -- 3004
__TS__ClassExtends(BuildAction, Node) -- 3004
function BuildAction.prototype.prep(self, shared) -- 3005
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3005
		local last = shared.history[#shared.history] -- 3006
		if not last then -- 3006
			error( -- 3007
				__TS__New(Error, "no history"), -- 3007
				0 -- 3007
			) -- 3007
		end -- 3007
		emitAgentStartEvent(shared, last) -- 3008
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3008
	end) -- 3008
end -- 3005
function BuildAction.prototype.exec(self, input) -- 3012
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3012
		local params = input.params -- 3013
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3014
		return ____awaiter_resolve(nil, result) -- 3014
	end) -- 3014
end -- 3012
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3021
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3021
		local last = shared.history[#shared.history] -- 3022
		if last ~= nil then -- 3022
			last.result = execRes -- 3024
			appendToolResultMessage(shared, last) -- 3025
			emitAgentFinishEvent(shared, last) -- 3026
		end -- 3026
		persistHistoryState(shared) -- 3028
		__TS__Await(maybeCompressHistory(shared)) -- 3029
		persistHistoryState(shared) -- 3030
		return ____awaiter_resolve(nil, "main") -- 3030
	end) -- 3030
end -- 3021
local SpawnSubAgentAction = __TS__Class() -- 3035
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3035
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3035
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3036
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3036
		local last = shared.history[#shared.history] -- 3045
		if not last then -- 3045
			error( -- 3046
				__TS__New(Error, "no history"), -- 3046
				0 -- 3046
			) -- 3046
		end -- 3046
		emitAgentStartEvent(shared, last) -- 3047
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3048
			last.params.filesHint, -- 3049
			function(____, item) return type(item) == "string" end -- 3049
		) or nil -- 3049
		return ____awaiter_resolve( -- 3049
			nil, -- 3049
			{ -- 3051
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3052
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3053
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3054
				filesHint = filesHint, -- 3055
				sessionId = shared.sessionId, -- 3056
				projectRoot = shared.workingDir, -- 3057
				spawnSubAgent = shared.spawnSubAgent -- 3058
			} -- 3058
		) -- 3058
	end) -- 3058
end -- 3036
function SpawnSubAgentAction.prototype.exec(self, input) -- 3062
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3062
		if not input.spawnSubAgent then -- 3062
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3062
		end -- 3062
		if input.sessionId == nil or input.sessionId <= 0 then -- 3062
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3062
		end -- 3062
		local ____Log_99 = Log -- 3077
		local ____temp_96 = #input.title -- 3077
		local ____temp_97 = #input.prompt -- 3077
		local ____temp_98 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3077
		local ____opt_94 = input.filesHint -- 3077
		____Log_99( -- 3077
			"Info", -- 3077
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_96)) .. " prompt_len=") .. tostring(____temp_97)) .. " expected_len=") .. tostring(____temp_98)) .. " files_hint_count=") .. tostring(____opt_94 and #____opt_94 or 0) -- 3077
		) -- 3077
		local result = __TS__Await(input.spawnSubAgent({ -- 3078
			parentSessionId = input.sessionId, -- 3079
			projectRoot = input.projectRoot, -- 3080
			title = input.title, -- 3081
			prompt = input.prompt, -- 3082
			expectedOutput = input.expectedOutput, -- 3083
			filesHint = input.filesHint -- 3084
		})) -- 3084
		if not result.success then -- 3084
			return ____awaiter_resolve(nil, result) -- 3084
		end -- 3084
		return ____awaiter_resolve(nil, { -- 3084
			success = true, -- 3090
			sessionId = result.sessionId, -- 3091
			taskId = result.taskId, -- 3092
			title = result.title, -- 3093
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3094
		}) -- 3094
	end) -- 3094
end -- 3062
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3098
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3098
		local last = shared.history[#shared.history] -- 3099
		if last ~= nil then -- 3099
			last.result = execRes -- 3101
			appendToolResultMessage(shared, last) -- 3102
			emitAgentFinishEvent(shared, last) -- 3103
		end -- 3103
		persistHistoryState(shared) -- 3105
		__TS__Await(maybeCompressHistory(shared)) -- 3106
		persistHistoryState(shared) -- 3107
		return ____awaiter_resolve(nil, "main") -- 3107
	end) -- 3107
end -- 3098
local ListSubAgentsAction = __TS__Class() -- 3112
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3112
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3112
function ListSubAgentsAction.prototype.prep(self, shared) -- 3113
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3113
		local last = shared.history[#shared.history] -- 3122
		if not last then -- 3122
			error( -- 3123
				__TS__New(Error, "no history"), -- 3123
				0 -- 3123
			) -- 3123
		end -- 3123
		emitAgentStartEvent(shared, last) -- 3124
		return ____awaiter_resolve( -- 3124
			nil, -- 3124
			{ -- 3125
				sessionId = shared.sessionId, -- 3126
				projectRoot = shared.workingDir, -- 3127
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3128
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3129
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3130
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3131
				listSubAgents = shared.listSubAgents -- 3132
			} -- 3132
		) -- 3132
	end) -- 3132
end -- 3113
function ListSubAgentsAction.prototype.exec(self, input) -- 3136
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3136
		if not input.listSubAgents then -- 3136
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3136
		end -- 3136
		if input.sessionId == nil or input.sessionId <= 0 then -- 3136
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3136
		end -- 3136
		local result = __TS__Await(input.listSubAgents({ -- 3151
			sessionId = input.sessionId, -- 3152
			projectRoot = input.projectRoot, -- 3153
			status = input.status, -- 3154
			limit = input.limit, -- 3155
			offset = input.offset, -- 3156
			query = input.query -- 3157
		})) -- 3157
		return ____awaiter_resolve(nil, result) -- 3157
	end) -- 3157
end -- 3136
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3162
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3162
		local last = shared.history[#shared.history] -- 3163
		if last ~= nil then -- 3163
			last.result = execRes -- 3165
			appendToolResultMessage(shared, last) -- 3166
			emitAgentFinishEvent(shared, last) -- 3167
		end -- 3167
		persistHistoryState(shared) -- 3169
		__TS__Await(maybeCompressHistory(shared)) -- 3170
		persistHistoryState(shared) -- 3171
		return ____awaiter_resolve(nil, "main") -- 3171
	end) -- 3171
end -- 3162
EditFileAction = __TS__Class() -- 3176
EditFileAction.name = "EditFileAction" -- 3176
__TS__ClassExtends(EditFileAction, Node) -- 3176
function EditFileAction.prototype.prep(self, shared) -- 3177
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3177
		local last = shared.history[#shared.history] -- 3178
		if not last then -- 3178
			error( -- 3179
				__TS__New(Error, "no history"), -- 3179
				0 -- 3179
			) -- 3179
		end -- 3179
		emitAgentStartEvent(shared, last) -- 3180
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3181
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3184
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3185
		if __TS__StringTrim(path) == "" then -- 3185
			error( -- 3186
				__TS__New(Error, "missing path"), -- 3186
				0 -- 3186
			) -- 3186
		end -- 3186
		return ____awaiter_resolve(nil, { -- 3186
			path = path, -- 3187
			oldStr = oldStr, -- 3187
			newStr = newStr, -- 3187
			taskId = shared.taskId, -- 3187
			workDir = shared.workingDir -- 3187
		}) -- 3187
	end) -- 3187
end -- 3177
function EditFileAction.prototype.exec(self, input) -- 3190
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3190
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3191
		if not readRes.success then -- 3191
			if input.oldStr ~= "" then -- 3191
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3191
			end -- 3191
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3196
			if not createRes.success then -- 3196
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3196
			end -- 3196
			return ____awaiter_resolve(nil, { -- 3196
				success = true, -- 3204
				changed = true, -- 3205
				mode = "create", -- 3206
				checkpointId = createRes.checkpointId, -- 3207
				checkpointSeq = createRes.checkpointSeq, -- 3208
				files = {{path = input.path, op = "create"}} -- 3209
			}) -- 3209
		end -- 3209
		if input.oldStr == "" then -- 3209
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3213
			if not overwriteRes.success then -- 3213
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3213
			end -- 3213
			return ____awaiter_resolve(nil, { -- 3213
				success = true, -- 3221
				changed = true, -- 3222
				mode = "overwrite", -- 3223
				checkpointId = overwriteRes.checkpointId, -- 3224
				checkpointSeq = overwriteRes.checkpointSeq, -- 3225
				files = {{path = input.path, op = "write"}} -- 3226
			}) -- 3226
		end -- 3226
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3231
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3232
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3233
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3236
		if occurrences == 0 then -- 3236
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3238
			if not indentTolerant.success then -- 3238
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3238
			end -- 3238
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3242
			if not applyRes.success then -- 3242
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3242
			end -- 3242
			return ____awaiter_resolve(nil, { -- 3242
				success = true, -- 3250
				changed = true, -- 3251
				mode = "replace_indent_tolerant", -- 3252
				checkpointId = applyRes.checkpointId, -- 3253
				checkpointSeq = applyRes.checkpointSeq, -- 3254
				files = {{path = input.path, op = "write"}} -- 3255
			}) -- 3255
		end -- 3255
		if occurrences > 1 then -- 3255
			return ____awaiter_resolve( -- 3255
				nil, -- 3255
				{ -- 3259
					success = false, -- 3259
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3259
				} -- 3259
			) -- 3259
		end -- 3259
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3263
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3264
		if not applyRes.success then -- 3264
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3264
		end -- 3264
		return ____awaiter_resolve(nil, { -- 3264
			success = true, -- 3272
			changed = true, -- 3273
			mode = "replace", -- 3274
			checkpointId = applyRes.checkpointId, -- 3275
			checkpointSeq = applyRes.checkpointSeq, -- 3276
			files = {{path = input.path, op = "write"}} -- 3277
		}) -- 3277
	end) -- 3277
end -- 3190
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3281
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3281
		local last = shared.history[#shared.history] -- 3282
		if last ~= nil then -- 3282
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3284
			last.result = execRes -- 3285
			appendToolResultMessage(shared, last) -- 3286
			emitAgentFinishEvent(shared, last) -- 3287
			local result = last.result -- 3288
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3288
				emitAgentEvent(shared, { -- 3293
					type = "checkpoint_created", -- 3294
					sessionId = shared.sessionId, -- 3295
					taskId = shared.taskId, -- 3296
					step = last.step, -- 3297
					tool = last.tool, -- 3298
					checkpointId = result.checkpointId, -- 3299
					checkpointSeq = result.checkpointSeq, -- 3300
					files = result.files -- 3301
				}) -- 3301
			end -- 3301
		end -- 3301
		persistHistoryState(shared) -- 3305
		__TS__Await(maybeCompressHistory(shared)) -- 3306
		persistHistoryState(shared) -- 3307
		return ____awaiter_resolve(nil, "main") -- 3307
	end) -- 3307
end -- 3281
local function emitCheckpointEventForAction(shared, action) -- 3312
	local result = action.result -- 3313
	if not result then -- 3313
		return -- 3314
	end -- 3314
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3314
		emitAgentEvent(shared, { -- 3319
			type = "checkpoint_created", -- 3320
			sessionId = shared.sessionId, -- 3321
			taskId = shared.taskId, -- 3322
			step = action.step, -- 3323
			tool = action.tool, -- 3324
			checkpointId = result.checkpointId, -- 3325
			checkpointSeq = result.checkpointSeq, -- 3326
			files = result.files -- 3327
		}) -- 3327
	end -- 3327
end -- 3312
local function sanitizeToolActionResultForHistory(action, result) -- 3482
	if action.tool == "read_file" then -- 3482
		return sanitizeReadResultForHistory(action.tool, result) -- 3484
	end -- 3484
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3484
		return sanitizeSearchResultForHistory(action.tool, result) -- 3487
	end -- 3487
	if action.tool == "glob_files" then -- 3487
		return sanitizeListFilesResultForHistory(result) -- 3490
	end -- 3490
	return result -- 3492
end -- 3482
local function canRunBatchActionInParallel(self, action) -- 3495
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 3496
end -- 3495
local BatchToolAction = __TS__Class() -- 3503
BatchToolAction.name = "BatchToolAction" -- 3503
__TS__ClassExtends(BatchToolAction, Node) -- 3503
function BatchToolAction.prototype.prep(self, shared) -- 3504
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3504
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3504
	end) -- 3504
end -- 3504
function BatchToolAction.prototype.exec(self, input) -- 3508
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3508
		local shared = input.shared -- 3509
		local preExecuted = shared.preExecutedResults -- 3510
		local allParallelSafe = #input.actions > 1 and __TS__ArrayEvery(input.actions, canRunBatchActionInParallel) -- 3511
		if not allParallelSafe then -- 3511
			do -- 3511
				local i = 0 -- 3513
				while i < #input.actions do -- 3513
					local action = input.actions[i + 1] -- 3514
					emitAgentStartEvent(shared, action) -- 3515
					local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3516
					action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3517
					action.result = sanitizeToolActionResultForHistory(action, result) -- 3518
					appendToolResultMessage(shared, action) -- 3519
					emitAgentFinishEvent(shared, action) -- 3520
					emitCheckpointEventForAction(shared, action) -- 3521
					persistHistoryState(shared) -- 3522
					if shared.stopToken.stopped then -- 3522
						break -- 3524
					end -- 3524
					i = i + 1 -- 3513
				end -- 3513
			end -- 3513
			return ____awaiter_resolve(nil, input.actions) -- 3513
		end -- 3513
		local preExecCount = #__TS__ArrayFilter( -- 3530
			input.actions, -- 3530
			function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 3530
		) -- 3530
		Log( -- 3531
			"Info", -- 3531
			(("[CodingAgent] batch read-only tools executing in parallel count=" .. tostring(#input.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3531
		) -- 3531
		do -- 3531
			local i = 0 -- 3532
			while i < #input.actions do -- 3532
				emitAgentStartEvent(shared, input.actions[i + 1]) -- 3533
				i = i + 1 -- 3532
			end -- 3532
		end -- 3532
		__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3535
			input.actions, -- 3535
			function(____, action) -- 3535
				return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3535
					if shared.stopToken.stopped then -- 3535
						action.result = { -- 3537
							success = false, -- 3537
							message = getCancelledReason(shared) -- 3537
						} -- 3537
						return ____awaiter_resolve(nil, action) -- 3537
					end -- 3537
					local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3540
					action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3541
					action.result = sanitizeToolActionResultForHistory(action, result) -- 3542
					return ____awaiter_resolve(nil, action) -- 3542
				end) -- 3542
			end -- 3535
		))) -- 3535
		do -- 3535
			local i = 0 -- 3545
			while i < #input.actions do -- 3545
				local action = input.actions[i + 1] -- 3546
				if not action.result then -- 3546
					action.result = {success = false, message = "tool did not produce a result"} -- 3548
				end -- 3548
				appendToolResultMessage(shared, action) -- 3550
				emitAgentFinishEvent(shared, action) -- 3551
				emitCheckpointEventForAction(shared, action) -- 3552
				i = i + 1 -- 3545
			end -- 3545
		end -- 3545
		persistHistoryState(shared) -- 3554
		return ____awaiter_resolve(nil, input.actions) -- 3554
	end) -- 3554
end -- 3508
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3558
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3558
		shared.pendingToolActions = nil -- 3559
		shared.preExecutedResults = nil -- 3560
		persistHistoryState(shared) -- 3561
		__TS__Await(maybeCompressHistory(shared)) -- 3562
		persistHistoryState(shared) -- 3563
		return ____awaiter_resolve(nil, "main") -- 3563
	end) -- 3563
end -- 3558
local EndNode = __TS__Class() -- 3568
EndNode.name = "EndNode" -- 3568
__TS__ClassExtends(EndNode, Node) -- 3568
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3569
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3569
		return ____awaiter_resolve(nil, nil) -- 3569
	end) -- 3569
end -- 3569
local CodingAgentFlow = __TS__Class() -- 3574
CodingAgentFlow.name = "CodingAgentFlow" -- 3574
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3574
function CodingAgentFlow.prototype.____constructor(self, role) -- 3575
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3576
	local read = __TS__New(ReadFileAction, 1, 0) -- 3577
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3578
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3579
	local list = __TS__New(ListFilesAction, 1, 0) -- 3580
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3581
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3582
	local build = __TS__New(BuildAction, 1, 0) -- 3583
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3584
	local edit = __TS__New(EditFileAction, 1, 0) -- 3585
	local batch = __TS__New(BatchToolAction, 1, 0) -- 3586
	local done = __TS__New(EndNode, 1, 0) -- 3587
	main:on("batch_tools", batch) -- 3589
	main:on("grep_files", search) -- 3590
	main:on("search_dora_api", searchDora) -- 3591
	main:on("glob_files", list) -- 3592
	if role == "main" then -- 3592
		main:on("read_file", read) -- 3594
		main:on("delete_file", del) -- 3595
		main:on("build", build) -- 3596
		main:on("edit_file", edit) -- 3597
		main:on("list_sub_agents", listSub) -- 3598
		main:on("spawn_sub_agent", spawn) -- 3599
	else -- 3599
		main:on("read_file", read) -- 3601
		main:on("delete_file", del) -- 3602
		main:on("build", build) -- 3603
		main:on("edit_file", edit) -- 3604
	end -- 3604
	main:on("done", done) -- 3606
	search:on("main", main) -- 3608
	searchDora:on("main", main) -- 3609
	list:on("main", main) -- 3610
	listSub:on("main", main) -- 3611
	spawn:on("main", main) -- 3612
	batch:on("main", main) -- 3613
	read:on("main", main) -- 3614
	del:on("main", main) -- 3615
	build:on("main", main) -- 3616
	edit:on("main", main) -- 3617
	Flow.prototype.____constructor(self, main) -- 3619
end -- 3575
local function runCodingAgentAsync(options) -- 3641
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3641
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3641
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3641
		end -- 3641
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3645
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3646
		if not llmConfigRes.success then -- 3646
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3646
		end -- 3646
		local llmConfig = llmConfigRes.config -- 3652
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3653
		if not taskRes.success then -- 3653
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3653
		end -- 3653
		local compressor = __TS__New(MemoryCompressor, { -- 3660
			compressionThreshold = 0.8, -- 3661
			compressionTargetThreshold = 0.5, -- 3662
			maxCompressionRounds = 3, -- 3663
			projectDir = options.workDir, -- 3664
			llmConfig = llmConfig, -- 3665
			promptPack = options.promptPack, -- 3666
			scope = options.memoryScope -- 3667
		}) -- 3667
		local persistedSession = compressor:getStorage():readSessionState() -- 3669
		local promptPack = compressor:getPromptPack() -- 3670
		local shared = { -- 3672
			sessionId = options.sessionId, -- 3673
			taskId = taskRes.taskId, -- 3674
			role = options.role or "main", -- 3675
			maxSteps = math.max( -- 3676
				1, -- 3676
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 3676
			), -- 3676
			llmMaxTry = math.max( -- 3677
				1, -- 3677
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 3677
			), -- 3677
			step = 0, -- 3678
			done = false, -- 3679
			stopToken = options.stopToken or ({stopped = false}), -- 3680
			response = "", -- 3681
			userQuery = normalizedPrompt, -- 3682
			workingDir = options.workDir, -- 3683
			useChineseResponse = options.useChineseResponse == true, -- 3684
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3685
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 3688
			llmConfig = llmConfig, -- 3689
			onEvent = options.onEvent, -- 3690
			promptPack = promptPack, -- 3691
			history = {}, -- 3692
			messages = persistedSession.messages, -- 3693
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 3694
			carryMessageIndex = persistedSession.carryMessageIndex, -- 3695
			memory = {compressor = compressor}, -- 3697
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 3701
			spawnSubAgent = options.spawnSubAgent, -- 3706
			listSubAgents = options.listSubAgents -- 3707
		} -- 3707
		local ____try = __TS__AsyncAwaiter(function() -- 3707
			emitAgentEvent(shared, { -- 3711
				type = "task_started", -- 3712
				sessionId = shared.sessionId, -- 3713
				taskId = shared.taskId, -- 3714
				prompt = shared.userQuery, -- 3715
				workDir = shared.workingDir, -- 3716
				maxSteps = shared.maxSteps -- 3717
			}) -- 3717
			if shared.stopToken.stopped then -- 3717
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3720
				return ____awaiter_resolve( -- 3720
					nil, -- 3720
					emitAgentTaskFinishEvent( -- 3721
						shared, -- 3721
						false, -- 3721
						getCancelledReason(shared) -- 3721
					) -- 3721
				) -- 3721
			end -- 3721
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3723
			local promptCommand = getPromptCommand(shared.userQuery) -- 3724
			if promptCommand == "clear" then -- 3724
				return ____awaiter_resolve( -- 3724
					nil, -- 3724
					clearSessionHistory(shared) -- 3726
				) -- 3726
			end -- 3726
			if promptCommand == "compact" then -- 3726
				if shared.role == "sub" then -- 3726
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 3730
					return ____awaiter_resolve( -- 3730
						nil, -- 3730
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 3731
					) -- 3731
				end -- 3731
				return ____awaiter_resolve( -- 3731
					nil, -- 3731
					__TS__Await(compactAllHistory(shared)) -- 3739
				) -- 3739
			end -- 3739
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3741
			persistHistoryState(shared) -- 3745
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3746
			__TS__Await(flow:run(shared)) -- 3747
			if shared.stopToken.stopped then -- 3747
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3749
				return ____awaiter_resolve( -- 3749
					nil, -- 3749
					emitAgentTaskFinishEvent( -- 3750
						shared, -- 3750
						false, -- 3750
						getCancelledReason(shared) -- 3750
					) -- 3750
				) -- 3750
			end -- 3750
			if shared.error then -- 3750
				return ____awaiter_resolve( -- 3750
					nil, -- 3750
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3753
				) -- 3753
			end -- 3753
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3756
			return ____awaiter_resolve( -- 3756
				nil, -- 3756
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3757
			) -- 3757
		end) -- 3757
		__TS__Await(____try.catch( -- 3710
			____try, -- 3710
			function(____, e) -- 3710
				return ____awaiter_resolve( -- 3710
					nil, -- 3710
					finalizeAgentFailure( -- 3760
						shared, -- 3760
						tostring(e) -- 3760
					) -- 3760
				) -- 3760
			end -- 3760
		)) -- 3760
	end) -- 3760
end -- 3641
function ____exports.runCodingAgent(options, callback) -- 3764
	local ____self_136 = runCodingAgentAsync(options) -- 3764
	____self_136["then"]( -- 3764
		____self_136, -- 3764
		function(____, result) return callback(result) end -- 3765
	) -- 3765
end -- 3764
return ____exports -- 3764