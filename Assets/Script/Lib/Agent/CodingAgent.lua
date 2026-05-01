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
function buildXmlDecisionInstruction(shared, feedback) -- 2211
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2212
end -- 2212
function executeToolAction(shared, action) -- 3393
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3393
		if shared.stopToken.stopped then -- 3393
			return ____awaiter_resolve( -- 3393
				nil, -- 3393
				{ -- 3395
					success = false, -- 3395
					message = getCancelledReason(shared) -- 3395
				} -- 3395
			) -- 3395
		end -- 3395
		local params = action.params -- 3397
		if action.tool == "read_file" then -- 3397
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3399
			if __TS__StringTrim(path) == "" then -- 3399
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3399
			end -- 3399
			local ____Tools_readFile_104 = Tools.readFile -- 3403
			local ____shared_workingDir_102 = shared.workingDir -- 3404
			local ____params_startLine_100 = params.startLine -- 3406
			if ____params_startLine_100 == nil then -- 3406
				____params_startLine_100 = 1 -- 3406
			end -- 3406
			local ____TS__Number_result_103 = __TS__Number(____params_startLine_100) -- 3406
			local ____params_endLine_101 = params.endLine -- 3407
			if ____params_endLine_101 == nil then -- 3407
				____params_endLine_101 = READ_FILE_DEFAULT_LIMIT -- 3407
			end -- 3407
			return ____awaiter_resolve( -- 3407
				nil, -- 3407
				____Tools_readFile_104( -- 3403
					____shared_workingDir_102, -- 3404
					path, -- 3405
					____TS__Number_result_103, -- 3406
					__TS__Number(____params_endLine_101), -- 3407
					shared.useChineseResponse and "zh" or "en" -- 3408
				) -- 3408
			) -- 3408
		end -- 3408
		if action.tool == "grep_files" then -- 3408
			local ____Tools_searchFiles_118 = Tools.searchFiles -- 3412
			local ____shared_workingDir_111 = shared.workingDir -- 3413
			local ____temp_112 = params.path or "" -- 3414
			local ____temp_113 = params.pattern or "" -- 3415
			local ____params_globs_114 = params.globs -- 3416
			local ____params_useRegex_115 = params.useRegex -- 3417
			local ____params_caseSensitive_116 = params.caseSensitive -- 3418
			local ____math_max_107 = math.max -- 3421
			local ____math_floor_106 = math.floor -- 3421
			local ____params_limit_105 = params.limit -- 3421
			if ____params_limit_105 == nil then -- 3421
				____params_limit_105 = SEARCH_FILES_LIMIT_DEFAULT -- 3421
			end -- 3421
			local ____math_max_107_result_117 = ____math_max_107( -- 3421
				1, -- 3421
				____math_floor_106(__TS__Number(____params_limit_105)) -- 3421
			) -- 3421
			local ____math_max_110 = math.max -- 3422
			local ____math_floor_109 = math.floor -- 3422
			local ____params_offset_108 = params.offset -- 3422
			if ____params_offset_108 == nil then -- 3422
				____params_offset_108 = 0 -- 3422
			end -- 3422
			local result = __TS__Await(____Tools_searchFiles_118({ -- 3412
				workDir = ____shared_workingDir_111, -- 3413
				path = ____temp_112, -- 3414
				pattern = ____temp_113, -- 3415
				globs = ____params_globs_114, -- 3416
				useRegex = ____params_useRegex_115, -- 3417
				caseSensitive = ____params_caseSensitive_116, -- 3418
				includeContent = true, -- 3419
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3420
				limit = ____math_max_107_result_117, -- 3421
				offset = ____math_max_110( -- 3422
					0, -- 3422
					____math_floor_109(__TS__Number(____params_offset_108)) -- 3422
				), -- 3422
				groupByFile = params.groupByFile == true -- 3423
			})) -- 3423
			return ____awaiter_resolve(nil, result) -- 3423
		end -- 3423
		if action.tool == "search_dora_api" then -- 3423
			local ____Tools_searchDoraAPI_126 = Tools.searchDoraAPI -- 3428
			local ____temp_122 = params.pattern or "" -- 3429
			local ____temp_123 = params.docSource or "api" -- 3430
			local ____temp_124 = shared.useChineseResponse and "zh" or "en" -- 3431
			local ____temp_125 = params.programmingLanguage or "ts" -- 3432
			local ____math_min_121 = math.min -- 3433
			local ____math_max_120 = math.max -- 3433
			local ____params_limit_119 = params.limit -- 3433
			if ____params_limit_119 == nil then -- 3433
				____params_limit_119 = 8 -- 3433
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
function emitAgentTaskFinishEvent(shared, success, message) -- 3659
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3660
	emitAgentEvent(shared, { -- 3666
		type = "task_finished", -- 3667
		sessionId = shared.sessionId, -- 3668
		taskId = shared.taskId, -- 3669
		success = result.success, -- 3670
		message = result.message, -- 3671
		steps = result.steps -- 3672
	}) -- 3672
	return result -- 3674
end -- 3674
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
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2181
	if attempt == nil then -- 2181
		attempt = 1 -- 2184
	end -- 2184
	if decisionMode == nil then -- 2184
		decisionMode = shared.decisionMode -- 2186
	end -- 2186
	local messages = { -- 2188
		{ -- 2189
			role = "system", -- 2189
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2189
		}, -- 2189
		table.unpack(getUnconsolidatedMessages(shared)) -- 2190
	} -- 2190
	if shared.step + 1 >= shared.maxSteps then -- 2190
		messages = appendPromptToLatestDecisionMessage( -- 2193
			messages, -- 2193
			getFinalDecisionTurnPrompt(shared) -- 2193
		) -- 2193
	end -- 2193
	if lastError and lastError ~= "" then -- 2193
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2196
		messages[#messages + 1] = { -- 2199
			role = "user", -- 2200
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2201
		} -- 2201
	end -- 2201
	return messages -- 2208
end -- 2181
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2215
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2222
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2223
	local repairPrompt = replacePromptVars( -- 2231
		shared.promptPack.xmlDecisionRepairPrompt, -- 2231
		{ -- 2231
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2232
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2233
			CANDIDATE_SECTION = candidateSection, -- 2234
			LAST_ERROR = lastError, -- 2235
			ATTEMPT = tostring(attempt) -- 2236
		} -- 2236
	) -- 2236
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2238
end -- 2215
local function tryParseAndValidateDecision(rawText) -- 2250
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2251
	if not parsed.success then -- 2251
		return {success = false, message = parsed.message, raw = rawText} -- 2253
	end -- 2253
	local decision = parseDecisionObject(parsed.obj) -- 2255
	if not decision.success then -- 2255
		return {success = false, message = decision.message, raw = rawText} -- 2257
	end -- 2257
	local validation = validateDecision(decision.tool, decision.params) -- 2259
	if not validation.success then -- 2259
		return {success = false, message = validation.message, raw = rawText} -- 2261
	end -- 2261
	decision.params = validation.params -- 2263
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2264
	return decision -- 2265
end -- 2250
local function normalizeLineEndings(text) -- 2268
	local res = string.gsub(text, "\r\n", "\n") -- 2269
	res = string.gsub(res, "\r", "\n") -- 2270
	return res -- 2271
end -- 2268
local function countOccurrences(text, searchStr) -- 2274
	if searchStr == "" then -- 2274
		return 0 -- 2275
	end -- 2275
	local count = 0 -- 2276
	local pos = 0 -- 2277
	while true do -- 2277
		local idx = (string.find( -- 2279
			text, -- 2279
			searchStr, -- 2279
			math.max(pos + 1, 1), -- 2279
			true -- 2279
		) or 0) - 1 -- 2279
		if idx < 0 then -- 2279
			break -- 2280
		end -- 2280
		count = count + 1 -- 2281
		pos = idx + #searchStr -- 2282
	end -- 2282
	return count -- 2284
end -- 2274
local function replaceFirst(text, oldStr, newStr) -- 2287
	if oldStr == "" then -- 2287
		return text -- 2288
	end -- 2288
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2289
	if idx < 0 then -- 2289
		return text -- 2290
	end -- 2290
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2291
end -- 2287
local function splitLines(text) -- 2294
	return __TS__StringSplit(text, "\n") -- 2295
end -- 2294
local function getLeadingWhitespace(text) -- 2298
	local i = 0 -- 2299
	while i < #text do -- 2299
		local ch = __TS__StringAccess(text, i) -- 2301
		if ch ~= " " and ch ~= "\t" then -- 2301
			break -- 2302
		end -- 2302
		i = i + 1 -- 2303
	end -- 2303
	return __TS__StringSubstring(text, 0, i) -- 2305
end -- 2298
local function getCommonIndentPrefix(lines) -- 2308
	local common -- 2309
	do -- 2309
		local i = 0 -- 2310
		while i < #lines do -- 2310
			do -- 2310
				local line = lines[i + 1] -- 2311
				if __TS__StringTrim(line) == "" then -- 2311
					goto __continue373 -- 2312
				end -- 2312
				local indent = getLeadingWhitespace(line) -- 2313
				if common == nil then -- 2313
					common = indent -- 2315
					goto __continue373 -- 2316
				end -- 2316
				local j = 0 -- 2318
				local maxLen = math.min(#common, #indent) -- 2319
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2319
					j = j + 1 -- 2321
				end -- 2321
				common = __TS__StringSubstring(common, 0, j) -- 2323
				if common == "" then -- 2323
					break -- 2324
				end -- 2324
			end -- 2324
			::__continue373:: -- 2324
			i = i + 1 -- 2310
		end -- 2310
	end -- 2310
	return common or "" -- 2326
end -- 2308
local function removeIndentPrefix(line, indent) -- 2329
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2329
		return __TS__StringSubstring(line, #indent) -- 2331
	end -- 2331
	local lineIndent = getLeadingWhitespace(line) -- 2333
	local j = 0 -- 2334
	local maxLen = math.min(#lineIndent, #indent) -- 2335
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2335
		j = j + 1 -- 2337
	end -- 2337
	return __TS__StringSubstring(line, j) -- 2339
end -- 2329
local function dedentLines(lines) -- 2342
	local indent = getCommonIndentPrefix(lines) -- 2343
	return { -- 2344
		indent = indent, -- 2345
		lines = __TS__ArrayMap( -- 2346
			lines, -- 2346
			function(____, line) return removeIndentPrefix(line, indent) end -- 2346
		) -- 2346
	} -- 2346
end -- 2342
local function joinLines(lines) -- 2350
	return table.concat(lines, "\n") -- 2351
end -- 2350
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2354
	local contentLines = splitLines(content) -- 2359
	local oldLines = splitLines(oldStr) -- 2360
	if #oldLines == 0 then -- 2360
		return {success = false, message = "old_str not found in file"} -- 2362
	end -- 2362
	local dedentedOld = dedentLines(oldLines) -- 2364
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2365
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2366
	local matches = {} -- 2367
	do -- 2367
		local start = 0 -- 2368
		while start <= #contentLines - #oldLines do -- 2368
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2369
			local dedentedCandidate = dedentLines(candidateLines) -- 2370
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2370
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2372
			end -- 2372
			start = start + 1 -- 2368
		end -- 2368
	end -- 2368
	if #matches == 0 then -- 2368
		return {success = false, message = "old_str not found in file"} -- 2380
	end -- 2380
	if #matches > 1 then -- 2380
		return { -- 2383
			success = false, -- 2384
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2385
		} -- 2385
	end -- 2385
	local match = matches[1] -- 2388
	local rebuiltNewLines = __TS__ArrayMap( -- 2389
		dedentedNew.lines, -- 2389
		function(____, line) return line == "" and "" or match.indent .. line end -- 2389
	) -- 2389
	local ____array_46 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2389
	__TS__SparseArrayPush( -- 2389
		____array_46, -- 2389
		table.unpack(rebuiltNewLines) -- 2392
	) -- 2392
	__TS__SparseArrayPush( -- 2392
		____array_46, -- 2392
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2393
	) -- 2393
	local nextLines = {__TS__SparseArraySpread(____array_46)} -- 2390
	return { -- 2395
		success = true, -- 2395
		content = joinLines(nextLines) -- 2395
	} -- 2395
end -- 2354
local MainDecisionAgent = __TS__Class() -- 2398
MainDecisionAgent.name = "MainDecisionAgent" -- 2398
__TS__ClassExtends(MainDecisionAgent, Node) -- 2398
function MainDecisionAgent.prototype.prep(self, shared) -- 2399
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2399
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2399
			return ____awaiter_resolve(nil, {shared = shared}) -- 2399
		end -- 2399
		__TS__Await(maybeCompressHistory(shared)) -- 2404
		return ____awaiter_resolve(nil, {shared = shared}) -- 2404
	end) -- 2404
end -- 2399
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2409
	if attempt == nil then -- 2409
		attempt = 1 -- 2412
	end -- 2412
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2412
		if shared.stopToken.stopped then -- 2412
			return ____awaiter_resolve( -- 2412
				nil, -- 2412
				{ -- 2416
					success = false, -- 2416
					message = getCancelledReason(shared) -- 2416
				} -- 2416
			) -- 2416
		end -- 2416
		Log( -- 2418
			"Info", -- 2418
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2418
		) -- 2418
		local tools = buildDecisionToolSchema(shared) -- 2419
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2420
		local stepId = shared.step + 1 -- 2421
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2422
		saveStepLLMDebugInput( -- 2426
			shared, -- 2426
			stepId, -- 2426
			"decision_tool_calling", -- 2426
			messages, -- 2426
			llmOptions -- 2426
		) -- 2426
		local lastStreamContent = "" -- 2427
		local lastStreamReasoning = "" -- 2428
		local preExecutedResults = __TS__New(Map) -- 2429
		shared.preExecutedResults = preExecutedResults -- 2430
		local res = __TS__Await(callLLMStreamAggregated( -- 2431
			messages, -- 2432
			llmOptions, -- 2433
			shared.stopToken, -- 2434
			shared.llmConfig, -- 2435
			function(response) -- 2436
				local ____opt_49 = response.choices -- 2436
				local ____opt_47 = ____opt_49 and ____opt_49[1] -- 2436
				local streamMessage = ____opt_47 and ____opt_47.message -- 2437
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2438
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2441
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2441
					return -- 2445
				end -- 2445
				lastStreamContent = nextContent -- 2447
				lastStreamReasoning = nextReasoning -- 2448
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2449
			end, -- 2436
			function(tc) -- 2451
				if shared.stopToken.stopped then -- 2451
					return -- 2452
				end -- 2452
				local action = createPreExecutableActionFromStream(shared, tc) -- 2453
				if not action or preExecutedResults:has(action.toolCallId) then -- 2453
					return -- 2454
				end -- 2454
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2455
				preExecutedResults:set( -- 2456
					action.toolCallId, -- 2456
					startPreExecutedToolAction(shared, action) -- 2456
				) -- 2456
			end -- 2451
		)) -- 2451
		if shared.stopToken.stopped then -- 2451
			clearPreExecutedResults(shared) -- 2460
			return ____awaiter_resolve( -- 2460
				nil, -- 2460
				{ -- 2461
					success = false, -- 2461
					message = getCancelledReason(shared) -- 2461
				} -- 2461
			) -- 2461
		end -- 2461
		if not res.success then -- 2461
			saveStepLLMDebugOutput( -- 2464
				shared, -- 2464
				stepId, -- 2464
				"decision_tool_calling", -- 2464
				res.raw or res.message, -- 2464
				{success = false} -- 2464
			) -- 2464
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2465
			clearPreExecutedResults(shared) -- 2466
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2466
		end -- 2466
		saveStepLLMDebugOutput( -- 2469
			shared, -- 2469
			stepId, -- 2469
			"decision_tool_calling", -- 2469
			encodeDebugJSON(res.response), -- 2469
			{success = true} -- 2469
		) -- 2469
		local choice = res.response.choices and res.response.choices[1] -- 2470
		local message = choice and choice.message -- 2471
		local toolCalls = message and message.tool_calls -- 2472
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2473
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2476
		Log( -- 2479
			"Info", -- 2479
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2479
		) -- 2479
		if not toolCalls or #toolCalls == 0 then -- 2479
			if messageContent and messageContent ~= "" then -- 2479
				Log( -- 2482
					"Info", -- 2482
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2482
				) -- 2482
				clearPreExecutedResults(shared) -- 2483
				return ____awaiter_resolve(nil, { -- 2483
					success = true, -- 2485
					tool = "finish", -- 2486
					params = {}, -- 2487
					reason = messageContent, -- 2488
					reasoningContent = reasoningContent, -- 2489
					directSummary = messageContent -- 2490
				}) -- 2490
			end -- 2490
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2493
			clearPreExecutedResults(shared) -- 2494
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2494
		end -- 2494
		local decisions = {} -- 2501
		do -- 2501
			local i = 0 -- 2502
			while i < #toolCalls do -- 2502
				local toolCall = toolCalls[i + 1] -- 2503
				local fn = toolCall and toolCall["function"] -- 2504
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2504
					Log( -- 2506
						"Error", -- 2506
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2506
					) -- 2506
					clearPreExecutedResults(shared) -- 2507
					return ____awaiter_resolve( -- 2507
						nil, -- 2507
						{ -- 2508
							success = false, -- 2509
							message = "missing function name for tool call " .. tostring(i + 1), -- 2510
							raw = messageContent -- 2511
						} -- 2511
					) -- 2511
				end -- 2511
				local functionName = fn.name -- 2514
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2515
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2516
				Log( -- 2519
					"Info", -- 2519
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2519
				) -- 2519
				local decision = parseAndValidateToolCallDecision( -- 2520
					shared, -- 2521
					functionName, -- 2522
					argsText, -- 2523
					toolCallId, -- 2524
					messageContent, -- 2525
					reasoningContent -- 2526
				) -- 2526
				if not decision.success then -- 2526
					Log( -- 2529
						"Error", -- 2529
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2529
					) -- 2529
					clearPreExecutedResults(shared) -- 2530
					return ____awaiter_resolve(nil, decision) -- 2530
				end -- 2530
				decisions[#decisions + 1] = decision -- 2533
				i = i + 1 -- 2502
			end -- 2502
		end -- 2502
		if #decisions == 1 then -- 2502
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2536
			return ____awaiter_resolve(nil, decisions[1]) -- 2536
		end -- 2536
		do -- 2536
			local i = 0 -- 2539
			while i < #decisions do -- 2539
				if decisions[i + 1].tool == "finish" then -- 2539
					clearPreExecutedResults(shared) -- 2541
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2541
				end -- 2541
				i = i + 1 -- 2539
			end -- 2539
		end -- 2539
		Log( -- 2549
			"Info", -- 2549
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2549
				__TS__ArrayMap( -- 2549
					decisions, -- 2549
					function(____, decision) return decision.tool end -- 2549
				), -- 2549
				"," -- 2549
			) -- 2549
		) -- 2549
		return ____awaiter_resolve(nil, { -- 2549
			success = true, -- 2551
			kind = "batch", -- 2552
			decisions = decisions, -- 2553
			content = messageContent, -- 2554
			reasoningContent = reasoningContent -- 2555
		}) -- 2555
	end) -- 2555
end -- 2409
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2559
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2559
		Log( -- 2564
			"Info", -- 2564
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2564
		) -- 2564
		local lastError = initialError -- 2565
		local candidateRaw = "" -- 2566
		do -- 2566
			local attempt = 0 -- 2567
			while attempt < shared.llmMaxTry do -- 2567
				do -- 2567
					Log( -- 2568
						"Info", -- 2568
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2568
					) -- 2568
					local messages = buildXmlRepairMessages( -- 2569
						shared, -- 2570
						originalRaw, -- 2571
						candidateRaw, -- 2572
						lastError, -- 2573
						attempt + 1 -- 2574
					) -- 2574
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2576
					if shared.stopToken.stopped then -- 2576
						return ____awaiter_resolve( -- 2576
							nil, -- 2576
							{ -- 2578
								success = false, -- 2578
								message = getCancelledReason(shared) -- 2578
							} -- 2578
						) -- 2578
					end -- 2578
					if not llmRes.success then -- 2578
						lastError = llmRes.message -- 2581
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2582
						goto __continue416 -- 2583
					end -- 2583
					candidateRaw = llmRes.text -- 2585
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2586
					if decision.success then -- 2586
						decision.reasoningContent = llmRes.reasoningContent -- 2588
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2589
						return ____awaiter_resolve(nil, decision) -- 2589
					end -- 2589
					lastError = decision.message -- 2592
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2593
				end -- 2593
				::__continue416:: -- 2593
				attempt = attempt + 1 -- 2567
			end -- 2567
		end -- 2567
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2595
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2595
	end) -- 2595
end -- 2559
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2603
	if attempt == nil then -- 2603
		attempt = 1 -- 2606
	end -- 2606
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2606
		local messages = buildDecisionMessages( -- 2609
			shared, -- 2610
			lastError, -- 2611
			attempt, -- 2612
			lastRaw, -- 2613
			"xml" -- 2614
		) -- 2614
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2616
		if shared.stopToken.stopped then -- 2616
			return ____awaiter_resolve( -- 2616
				nil, -- 2616
				{ -- 2618
					success = false, -- 2618
					message = getCancelledReason(shared) -- 2618
				} -- 2618
			) -- 2618
		end -- 2618
		if not llmRes.success then -- 2618
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2618
		end -- 2618
		local decision = tryParseAndValidateDecision(llmRes.text) -- 2627
		if decision.success then -- 2627
			decision.reasoningContent = llmRes.reasoningContent -- 2629
			if not isToolAllowedForRole(shared.role, decision.tool) then -- 2629
				return ____awaiter_resolve( -- 2629
					nil, -- 2629
					self:repairDecisionXml(shared, llmRes.text, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2631
				) -- 2631
			end -- 2631
			return ____awaiter_resolve(nil, decision) -- 2631
		end -- 2631
		return ____awaiter_resolve( -- 2631
			nil, -- 2631
			self:repairDecisionXml(shared, llmRes.text, decision.message) -- 2639
		) -- 2639
	end) -- 2639
end -- 2603
function MainDecisionAgent.prototype.exec(self, input) -- 2642
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2642
		local shared = input.shared -- 2643
		if shared.stopToken.stopped then -- 2643
			return ____awaiter_resolve( -- 2643
				nil, -- 2643
				{ -- 2645
					success = false, -- 2645
					message = getCancelledReason(shared) -- 2645
				} -- 2645
			) -- 2645
		end -- 2645
		if shared.step >= shared.maxSteps then -- 2645
			Log( -- 2648
				"Warn", -- 2648
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2648
			) -- 2648
			return ____awaiter_resolve( -- 2648
				nil, -- 2648
				{ -- 2649
					success = false, -- 2649
					message = getMaxStepsReachedReason(shared) -- 2649
				} -- 2649
			) -- 2649
		end -- 2649
		if shared.decisionMode == "tool_calling" then -- 2649
			Log( -- 2653
				"Info", -- 2653
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2653
			) -- 2653
			local lastError = "tool calling validation failed" -- 2654
			local lastRaw = "" -- 2655
			local shouldFallbackToXml = false -- 2656
			do -- 2656
				local attempt = 0 -- 2657
				while attempt < shared.llmMaxTry do -- 2657
					Log( -- 2658
						"Info", -- 2658
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2658
					) -- 2658
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2659
					if shared.stopToken.stopped then -- 2659
						return ____awaiter_resolve( -- 2659
							nil, -- 2659
							{ -- 2666
								success = false, -- 2666
								message = getCancelledReason(shared) -- 2666
							} -- 2666
						) -- 2666
					end -- 2666
					if decision.success then -- 2666
						return ____awaiter_resolve(nil, decision) -- 2666
					end -- 2666
					lastError = decision.message -- 2671
					lastRaw = decision.raw or "" -- 2672
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2673
					if lastError == "missing tool call" then -- 2673
						shouldFallbackToXml = true -- 2675
						break -- 2676
					end -- 2676
					attempt = attempt + 1 -- 2657
				end -- 2657
			end -- 2657
			if shouldFallbackToXml then -- 2657
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 2680
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 2681
				do -- 2681
					local attempt = 0 -- 2682
					while attempt < shared.llmMaxTry do -- 2682
						Log( -- 2683
							"Info", -- 2683
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 2683
						) -- 2683
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 2684
						if shared.stopToken.stopped then -- 2684
							return ____awaiter_resolve( -- 2684
								nil, -- 2684
								{ -- 2691
									success = false, -- 2691
									message = getCancelledReason(shared) -- 2691
								} -- 2691
							) -- 2691
						end -- 2691
						if decision.success then -- 2691
							return ____awaiter_resolve(nil, decision) -- 2691
						end -- 2691
						lastError = decision.message -- 2696
						lastRaw = decision.raw or "" -- 2697
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 2698
						attempt = attempt + 1 -- 2682
					end -- 2682
				end -- 2682
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 2700
				return ____awaiter_resolve( -- 2700
					nil, -- 2700
					{ -- 2701
						success = false, -- 2701
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2701
					} -- 2701
				) -- 2701
			end -- 2701
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2703
			return ____awaiter_resolve( -- 2703
				nil, -- 2703
				{ -- 2704
					success = false, -- 2704
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2704
				} -- 2704
			) -- 2704
		end -- 2704
		local lastError = "xml validation failed" -- 2707
		local lastRaw = "" -- 2708
		do -- 2708
			local attempt = 0 -- 2709
			while attempt < shared.llmMaxTry do -- 2709
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 2710
				if shared.stopToken.stopped then -- 2710
					return ____awaiter_resolve( -- 2710
						nil, -- 2710
						{ -- 2719
							success = false, -- 2719
							message = getCancelledReason(shared) -- 2719
						} -- 2719
					) -- 2719
				end -- 2719
				if decision.success then -- 2719
					return ____awaiter_resolve(nil, decision) -- 2719
				end -- 2719
				lastError = decision.message -- 2724
				lastRaw = decision.raw or "" -- 2725
				attempt = attempt + 1 -- 2709
			end -- 2709
		end -- 2709
		return ____awaiter_resolve( -- 2709
			nil, -- 2709
			{ -- 2727
				success = false, -- 2727
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2727
			} -- 2727
		) -- 2727
	end) -- 2727
end -- 2642
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2730
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2730
		local result = execRes -- 2731
		if not result.success then -- 2731
			if shared.stopToken.stopped then -- 2731
				shared.error = getCancelledReason(shared) -- 2734
				shared.done = true -- 2735
				return ____awaiter_resolve(nil, "done") -- 2735
			end -- 2735
			shared.error = result.message -- 2738
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2739
			shared.done = true -- 2740
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2741
			persistHistoryState(shared) -- 2745
			return ____awaiter_resolve(nil, "done") -- 2745
		end -- 2745
		if isDecisionBatchSuccess(result) then -- 2745
			local startStep = shared.step -- 2749
			local actions = {} -- 2750
			do -- 2750
				local i = 0 -- 2751
				while i < #result.decisions do -- 2751
					local decision = result.decisions[i + 1] -- 2752
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2753
					local step = startStep + i + 1 -- 2754
					local ____temp_55 -- 2755
					if i == 0 then -- 2755
						____temp_55 = decision.reason -- 2755
					else -- 2755
						____temp_55 = "" -- 2755
					end -- 2755
					local actionReason = ____temp_55 -- 2755
					local ____temp_56 -- 2756
					if i == 0 then -- 2756
						____temp_56 = decision.reasoningContent -- 2756
					else -- 2756
						____temp_56 = nil -- 2756
					end -- 2756
					local actionReasoningContent = ____temp_56 -- 2756
					emitAgentEvent(shared, { -- 2757
						type = "decision_made", -- 2758
						sessionId = shared.sessionId, -- 2759
						taskId = shared.taskId, -- 2760
						step = step, -- 2761
						tool = decision.tool, -- 2762
						reason = actionReason, -- 2763
						reasoningContent = actionReasoningContent, -- 2764
						params = decision.params -- 2765
					}) -- 2765
					local action = { -- 2767
						step = step, -- 2768
						toolCallId = toolCallId, -- 2769
						tool = decision.tool, -- 2770
						reason = actionReason or "", -- 2771
						reasoningContent = actionReasoningContent, -- 2772
						params = decision.params, -- 2773
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2774
					} -- 2774
					local ____shared_history_57 = shared.history -- 2774
					____shared_history_57[#____shared_history_57 + 1] = action -- 2776
					actions[#actions + 1] = action -- 2777
					i = i + 1 -- 2751
				end -- 2751
			end -- 2751
			shared.step = startStep + #actions -- 2779
			shared.pendingToolActions = actions -- 2780
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2781
			persistHistoryState(shared) -- 2787
			return ____awaiter_resolve(nil, "batch_tools") -- 2787
		end -- 2787
		if result.directSummary and result.directSummary ~= "" then -- 2787
			shared.response = result.directSummary -- 2791
			shared.done = true -- 2792
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2793
			persistHistoryState(shared) -- 2798
			return ____awaiter_resolve(nil, "done") -- 2798
		end -- 2798
		if result.tool == "finish" then -- 2798
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2802
			shared.response = finalMessage -- 2803
			shared.done = true -- 2804
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2805
			persistHistoryState(shared) -- 2810
			return ____awaiter_resolve(nil, "done") -- 2810
		end -- 2810
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2813
		shared.step = shared.step + 1 -- 2814
		local step = shared.step -- 2815
		emitAgentEvent(shared, { -- 2816
			type = "decision_made", -- 2817
			sessionId = shared.sessionId, -- 2818
			taskId = shared.taskId, -- 2819
			step = step, -- 2820
			tool = result.tool, -- 2821
			reason = result.reason, -- 2822
			reasoningContent = result.reasoningContent, -- 2823
			params = result.params -- 2824
		}) -- 2824
		local ____shared_history_58 = shared.history -- 2824
		____shared_history_58[#____shared_history_58 + 1] = { -- 2826
			step = step, -- 2827
			toolCallId = toolCallId, -- 2828
			tool = result.tool, -- 2829
			reason = result.reason or "", -- 2830
			reasoningContent = result.reasoningContent, -- 2831
			params = result.params, -- 2832
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2833
		} -- 2833
		local action = shared.history[#shared.history] -- 2835
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 2836
		if canPreExecuteTool(action.tool) then -- 2836
			shared.pendingToolActions = {action} -- 2838
			persistHistoryState(shared) -- 2839
			return ____awaiter_resolve(nil, "batch_tools") -- 2839
		end -- 2839
		clearPreExecutedResults(shared) -- 2842
		persistHistoryState(shared) -- 2843
		return ____awaiter_resolve(nil, result.tool) -- 2843
	end) -- 2843
end -- 2730
local ReadFileAction = __TS__Class() -- 2848
ReadFileAction.name = "ReadFileAction" -- 2848
__TS__ClassExtends(ReadFileAction, Node) -- 2848
function ReadFileAction.prototype.prep(self, shared) -- 2849
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2849
		local last = shared.history[#shared.history] -- 2850
		if not last then -- 2850
			error( -- 2851
				__TS__New(Error, "no history"), -- 2851
				0 -- 2851
			) -- 2851
		end -- 2851
		emitAgentStartEvent(shared, last) -- 2852
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2853
		if __TS__StringTrim(path) == "" then -- 2853
			error( -- 2856
				__TS__New(Error, "missing path"), -- 2856
				0 -- 2856
			) -- 2856
		end -- 2856
		local ____path_61 = path -- 2858
		local ____shared_workingDir_62 = shared.workingDir -- 2860
		local ____temp_63 = shared.useChineseResponse and "zh" or "en" -- 2861
		local ____last_params_startLine_59 = last.params.startLine -- 2862
		if ____last_params_startLine_59 == nil then -- 2862
			____last_params_startLine_59 = 1 -- 2862
		end -- 2862
		local ____TS__Number_result_64 = __TS__Number(____last_params_startLine_59) -- 2862
		local ____last_params_endLine_60 = last.params.endLine -- 2863
		if ____last_params_endLine_60 == nil then -- 2863
			____last_params_endLine_60 = READ_FILE_DEFAULT_LIMIT -- 2863
		end -- 2863
		return ____awaiter_resolve( -- 2863
			nil, -- 2863
			{ -- 2857
				path = ____path_61, -- 2858
				tool = "read_file", -- 2859
				workDir = ____shared_workingDir_62, -- 2860
				docLanguage = ____temp_63, -- 2861
				startLine = ____TS__Number_result_64, -- 2862
				endLine = __TS__Number(____last_params_endLine_60) -- 2863
			} -- 2863
		) -- 2863
	end) -- 2863
end -- 2849
function ReadFileAction.prototype.exec(self, input) -- 2867
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2867
		return ____awaiter_resolve( -- 2867
			nil, -- 2867
			Tools.readFile( -- 2868
				input.workDir, -- 2869
				input.path, -- 2870
				__TS__Number(input.startLine or 1), -- 2871
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2872
				input.docLanguage -- 2873
			) -- 2873
		) -- 2873
	end) -- 2873
end -- 2867
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2877
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2877
		local result = execRes -- 2878
		local last = shared.history[#shared.history] -- 2879
		if last ~= nil then -- 2879
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2881
			appendToolResultMessage(shared, last) -- 2882
			emitAgentFinishEvent(shared, last) -- 2883
		end -- 2883
		persistHistoryState(shared) -- 2885
		__TS__Await(maybeCompressHistory(shared)) -- 2886
		persistHistoryState(shared) -- 2887
		return ____awaiter_resolve(nil, "main") -- 2887
	end) -- 2887
end -- 2877
local SearchFilesAction = __TS__Class() -- 2892
SearchFilesAction.name = "SearchFilesAction" -- 2892
__TS__ClassExtends(SearchFilesAction, Node) -- 2892
function SearchFilesAction.prototype.prep(self, shared) -- 2893
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2893
		local last = shared.history[#shared.history] -- 2894
		if not last then -- 2894
			error( -- 2895
				__TS__New(Error, "no history"), -- 2895
				0 -- 2895
			) -- 2895
		end -- 2895
		emitAgentStartEvent(shared, last) -- 2896
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2896
	end) -- 2896
end -- 2893
function SearchFilesAction.prototype.exec(self, input) -- 2900
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2900
		local params = input.params -- 2901
		local ____Tools_searchFiles_78 = Tools.searchFiles -- 2902
		local ____input_workDir_71 = input.workDir -- 2903
		local ____temp_72 = params.path or "" -- 2904
		local ____temp_73 = params.pattern or "" -- 2905
		local ____params_globs_74 = params.globs -- 2906
		local ____params_useRegex_75 = params.useRegex -- 2907
		local ____params_caseSensitive_76 = params.caseSensitive -- 2908
		local ____math_max_67 = math.max -- 2911
		local ____math_floor_66 = math.floor -- 2911
		local ____params_limit_65 = params.limit -- 2911
		if ____params_limit_65 == nil then -- 2911
			____params_limit_65 = SEARCH_FILES_LIMIT_DEFAULT -- 2911
		end -- 2911
		local ____math_max_67_result_77 = ____math_max_67( -- 2911
			1, -- 2911
			____math_floor_66(__TS__Number(____params_limit_65)) -- 2911
		) -- 2911
		local ____math_max_70 = math.max -- 2912
		local ____math_floor_69 = math.floor -- 2912
		local ____params_offset_68 = params.offset -- 2912
		if ____params_offset_68 == nil then -- 2912
			____params_offset_68 = 0 -- 2912
		end -- 2912
		local result = __TS__Await(____Tools_searchFiles_78({ -- 2902
			workDir = ____input_workDir_71, -- 2903
			path = ____temp_72, -- 2904
			pattern = ____temp_73, -- 2905
			globs = ____params_globs_74, -- 2906
			useRegex = ____params_useRegex_75, -- 2907
			caseSensitive = ____params_caseSensitive_76, -- 2908
			includeContent = true, -- 2909
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2910
			limit = ____math_max_67_result_77, -- 2911
			offset = ____math_max_70( -- 2912
				0, -- 2912
				____math_floor_69(__TS__Number(____params_offset_68)) -- 2912
			), -- 2912
			groupByFile = params.groupByFile == true -- 2913
		})) -- 2913
		return ____awaiter_resolve(nil, result) -- 2913
	end) -- 2913
end -- 2900
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2918
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2918
		local last = shared.history[#shared.history] -- 2919
		if last ~= nil then -- 2919
			local result = execRes -- 2921
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2922
			appendToolResultMessage(shared, last) -- 2923
			emitAgentFinishEvent(shared, last) -- 2924
		end -- 2924
		persistHistoryState(shared) -- 2926
		__TS__Await(maybeCompressHistory(shared)) -- 2927
		persistHistoryState(shared) -- 2928
		return ____awaiter_resolve(nil, "main") -- 2928
	end) -- 2928
end -- 2918
local SearchDoraAPIAction = __TS__Class() -- 2933
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2933
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2933
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2934
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2934
		local last = shared.history[#shared.history] -- 2935
		if not last then -- 2935
			error( -- 2936
				__TS__New(Error, "no history"), -- 2936
				0 -- 2936
			) -- 2936
		end -- 2936
		emitAgentStartEvent(shared, last) -- 2937
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2937
	end) -- 2937
end -- 2934
function SearchDoraAPIAction.prototype.exec(self, input) -- 2941
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2941
		local params = input.params -- 2942
		local ____Tools_searchDoraAPI_86 = Tools.searchDoraAPI -- 2943
		local ____temp_82 = params.pattern or "" -- 2944
		local ____temp_83 = params.docSource or "api" -- 2945
		local ____temp_84 = input.useChineseResponse and "zh" or "en" -- 2946
		local ____temp_85 = params.programmingLanguage or "ts" -- 2947
		local ____math_min_81 = math.min -- 2948
		local ____math_max_80 = math.max -- 2948
		local ____params_limit_79 = params.limit -- 2948
		if ____params_limit_79 == nil then -- 2948
			____params_limit_79 = 8 -- 2948
		end -- 2948
		local result = __TS__Await(____Tools_searchDoraAPI_86({ -- 2943
			pattern = ____temp_82, -- 2944
			docSource = ____temp_83, -- 2945
			docLanguage = ____temp_84, -- 2946
			programmingLanguage = ____temp_85, -- 2947
			limit = ____math_min_81( -- 2948
				SEARCH_DORA_API_LIMIT_MAX, -- 2948
				____math_max_80( -- 2948
					1, -- 2948
					__TS__Number(____params_limit_79) -- 2948
				) -- 2948
			), -- 2948
			useRegex = params.useRegex, -- 2949
			caseSensitive = false, -- 2950
			includeContent = true, -- 2951
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2952
		})) -- 2952
		return ____awaiter_resolve(nil, result) -- 2952
	end) -- 2952
end -- 2941
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2957
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2957
		local last = shared.history[#shared.history] -- 2958
		if last ~= nil then -- 2958
			local result = execRes -- 2960
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2961
			appendToolResultMessage(shared, last) -- 2962
			emitAgentFinishEvent(shared, last) -- 2963
		end -- 2963
		persistHistoryState(shared) -- 2965
		__TS__Await(maybeCompressHistory(shared)) -- 2966
		persistHistoryState(shared) -- 2967
		return ____awaiter_resolve(nil, "main") -- 2967
	end) -- 2967
end -- 2957
local ListFilesAction = __TS__Class() -- 2972
ListFilesAction.name = "ListFilesAction" -- 2972
__TS__ClassExtends(ListFilesAction, Node) -- 2972
function ListFilesAction.prototype.prep(self, shared) -- 2973
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2973
		local last = shared.history[#shared.history] -- 2974
		if not last then -- 2974
			error( -- 2975
				__TS__New(Error, "no history"), -- 2975
				0 -- 2975
			) -- 2975
		end -- 2975
		emitAgentStartEvent(shared, last) -- 2976
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2976
	end) -- 2976
end -- 2973
function ListFilesAction.prototype.exec(self, input) -- 2980
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2980
		local params = input.params -- 2981
		local ____Tools_listFiles_93 = Tools.listFiles -- 2982
		local ____input_workDir_90 = input.workDir -- 2983
		local ____temp_91 = params.path or "" -- 2984
		local ____params_globs_92 = params.globs -- 2985
		local ____math_max_89 = math.max -- 2986
		local ____math_floor_88 = math.floor -- 2986
		local ____params_maxEntries_87 = params.maxEntries -- 2986
		if ____params_maxEntries_87 == nil then -- 2986
			____params_maxEntries_87 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 2986
		end -- 2986
		local result = ____Tools_listFiles_93({ -- 2982
			workDir = ____input_workDir_90, -- 2983
			path = ____temp_91, -- 2984
			globs = ____params_globs_92, -- 2985
			maxEntries = ____math_max_89( -- 2986
				1, -- 2986
				____math_floor_88(__TS__Number(____params_maxEntries_87)) -- 2986
			) -- 2986
		}) -- 2986
		return ____awaiter_resolve(nil, result) -- 2986
	end) -- 2986
end -- 2980
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2991
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2991
		local last = shared.history[#shared.history] -- 2992
		if last ~= nil then -- 2992
			last.result = sanitizeListFilesResultForHistory(execRes) -- 2994
			appendToolResultMessage(shared, last) -- 2995
			emitAgentFinishEvent(shared, last) -- 2996
		end -- 2996
		persistHistoryState(shared) -- 2998
		__TS__Await(maybeCompressHistory(shared)) -- 2999
		persistHistoryState(shared) -- 3000
		return ____awaiter_resolve(nil, "main") -- 3000
	end) -- 3000
end -- 2991
local DeleteFileAction = __TS__Class() -- 3005
DeleteFileAction.name = "DeleteFileAction" -- 3005
__TS__ClassExtends(DeleteFileAction, Node) -- 3005
function DeleteFileAction.prototype.prep(self, shared) -- 3006
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3006
		local last = shared.history[#shared.history] -- 3007
		if not last then -- 3007
			error( -- 3008
				__TS__New(Error, "no history"), -- 3008
				0 -- 3008
			) -- 3008
		end -- 3008
		emitAgentStartEvent(shared, last) -- 3009
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3010
		if __TS__StringTrim(targetFile) == "" then -- 3010
			error( -- 3013
				__TS__New(Error, "missing target_file"), -- 3013
				0 -- 3013
			) -- 3013
		end -- 3013
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3013
	end) -- 3013
end -- 3006
function DeleteFileAction.prototype.exec(self, input) -- 3017
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3017
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3018
		if not result.success then -- 3018
			return ____awaiter_resolve(nil, result) -- 3018
		end -- 3018
		return ____awaiter_resolve(nil, { -- 3018
			success = true, -- 3026
			changed = true, -- 3027
			mode = "delete", -- 3028
			checkpointId = result.checkpointId, -- 3029
			checkpointSeq = result.checkpointSeq, -- 3030
			files = {{path = input.targetFile, op = "delete"}} -- 3031
		}) -- 3031
	end) -- 3031
end -- 3017
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3035
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3035
		local last = shared.history[#shared.history] -- 3036
		if last ~= nil then -- 3036
			last.result = execRes -- 3038
			appendToolResultMessage(shared, last) -- 3039
			emitAgentFinishEvent(shared, last) -- 3040
			local result = last.result -- 3041
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3041
				emitAgentEvent(shared, { -- 3046
					type = "checkpoint_created", -- 3047
					sessionId = shared.sessionId, -- 3048
					taskId = shared.taskId, -- 3049
					step = last.step, -- 3050
					tool = "delete_file", -- 3051
					checkpointId = result.checkpointId, -- 3052
					checkpointSeq = result.checkpointSeq, -- 3053
					files = result.files -- 3054
				}) -- 3054
			end -- 3054
		end -- 3054
		persistHistoryState(shared) -- 3058
		__TS__Await(maybeCompressHistory(shared)) -- 3059
		persistHistoryState(shared) -- 3060
		return ____awaiter_resolve(nil, "main") -- 3060
	end) -- 3060
end -- 3035
local BuildAction = __TS__Class() -- 3065
BuildAction.name = "BuildAction" -- 3065
__TS__ClassExtends(BuildAction, Node) -- 3065
function BuildAction.prototype.prep(self, shared) -- 3066
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3066
		local last = shared.history[#shared.history] -- 3067
		if not last then -- 3067
			error( -- 3068
				__TS__New(Error, "no history"), -- 3068
				0 -- 3068
			) -- 3068
		end -- 3068
		emitAgentStartEvent(shared, last) -- 3069
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3069
	end) -- 3069
end -- 3066
function BuildAction.prototype.exec(self, input) -- 3073
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3073
		local params = input.params -- 3074
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3075
		return ____awaiter_resolve(nil, result) -- 3075
	end) -- 3075
end -- 3073
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3082
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3082
		local last = shared.history[#shared.history] -- 3083
		if last ~= nil then -- 3083
			last.result = execRes -- 3085
			appendToolResultMessage(shared, last) -- 3086
			emitAgentFinishEvent(shared, last) -- 3087
		end -- 3087
		persistHistoryState(shared) -- 3089
		__TS__Await(maybeCompressHistory(shared)) -- 3090
		persistHistoryState(shared) -- 3091
		return ____awaiter_resolve(nil, "main") -- 3091
	end) -- 3091
end -- 3082
local SpawnSubAgentAction = __TS__Class() -- 3096
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3096
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3096
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3097
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3097
		local last = shared.history[#shared.history] -- 3106
		if not last then -- 3106
			error( -- 3107
				__TS__New(Error, "no history"), -- 3107
				0 -- 3107
			) -- 3107
		end -- 3107
		emitAgentStartEvent(shared, last) -- 3108
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3109
			last.params.filesHint, -- 3110
			function(____, item) return type(item) == "string" end -- 3110
		) or nil -- 3110
		return ____awaiter_resolve( -- 3110
			nil, -- 3110
			{ -- 3112
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3113
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3114
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3115
				filesHint = filesHint, -- 3116
				sessionId = shared.sessionId, -- 3117
				projectRoot = shared.workingDir, -- 3118
				spawnSubAgent = shared.spawnSubAgent -- 3119
			} -- 3119
		) -- 3119
	end) -- 3119
end -- 3097
function SpawnSubAgentAction.prototype.exec(self, input) -- 3123
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3123
		if not input.spawnSubAgent then -- 3123
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3123
		end -- 3123
		if input.sessionId == nil or input.sessionId <= 0 then -- 3123
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3123
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
local function partitionToolCalls(actions) -- 3508
	local batches = {} -- 3509
	do -- 3509
		local i = 0 -- 3510
		while i < #actions do -- 3510
			local action = actions[i + 1] -- 3511
			local isSafe = canRunBatchActionInParallel(nil, action) -- 3512
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 3513
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 3513
				local ____lastBatch_actions_134 = lastBatch.actions -- 3513
				____lastBatch_actions_134[#____lastBatch_actions_134 + 1] = action -- 3515
			else -- 3515
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 3517
			end -- 3517
			i = i + 1 -- 3510
		end -- 3510
	end -- 3510
	return batches -- 3520
end -- 3508
local BatchToolAction = __TS__Class() -- 3523
BatchToolAction.name = "BatchToolAction" -- 3523
__TS__ClassExtends(BatchToolAction, Node) -- 3523
function BatchToolAction.prototype.prep(self, shared) -- 3524
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3524
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3524
	end) -- 3524
end -- 3524
function BatchToolAction.prototype.exec(self, input) -- 3528
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3528
		local shared = input.shared -- 3529
		local preExecuted = shared.preExecutedResults -- 3530
		local batches = partitionToolCalls(input.actions) -- 3531
		local parallelBatchCount = #__TS__ArrayFilter( -- 3532
			batches, -- 3532
			function(____, b) return b.isConcurrencySafe end -- 3532
		) -- 3532
		local serialBatchCount = #__TS__ArrayFilter( -- 3533
			batches, -- 3533
			function(____, b) return not b.isConcurrencySafe end -- 3533
		) -- 3533
		Log( -- 3534
			"Info", -- 3534
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 3534
		) -- 3534
		do -- 3534
			local batchIdx = 0 -- 3536
			while batchIdx < #batches do -- 3536
				do -- 3536
					local batch = batches[batchIdx + 1] -- 3537
					if shared.stopToken.stopped then -- 3537
						for ____, action in ipairs(batch.actions) do -- 3539
							if not action.result then -- 3539
								action.result = { -- 3541
									success = false, -- 3541
									message = getCancelledReason(shared) -- 3541
								} -- 3541
							end -- 3541
						end -- 3541
						goto __continue549 -- 3544
					end -- 3544
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 3544
						local preExecCount = #__TS__ArrayFilter( -- 3548
							batch.actions, -- 3548
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 3548
						) -- 3548
						Log( -- 3549
							"Info", -- 3549
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3549
						) -- 3549
						do -- 3549
							local i = 0 -- 3550
							while i < #batch.actions do -- 3550
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 3551
								i = i + 1 -- 3550
							end -- 3550
						end -- 3550
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3553
							batch.actions, -- 3553
							function(____, action) -- 3553
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3553
									if shared.stopToken.stopped then -- 3553
										action.result = { -- 3555
											success = false, -- 3555
											message = getCancelledReason(shared) -- 3555
										} -- 3555
										return ____awaiter_resolve(nil, action) -- 3555
									end -- 3555
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3558
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3559
									action.result = sanitizeToolActionResultForHistory(action, result) -- 3560
									return ____awaiter_resolve(nil, action) -- 3560
								end) -- 3560
							end -- 3553
						))) -- 3553
						do -- 3553
							local i = 0 -- 3563
							while i < #batch.actions do -- 3563
								local action = batch.actions[i + 1] -- 3564
								if not action.result then -- 3564
									action.result = {success = false, message = "tool did not produce a result"} -- 3566
								end -- 3566
								appendToolResultMessage(shared, action) -- 3568
								emitAgentFinishEvent(shared, action) -- 3569
								emitCheckpointEventForAction(shared, action) -- 3570
								i = i + 1 -- 3563
							end -- 3563
						end -- 3563
					else -- 3563
						Log( -- 3573
							"Info", -- 3573
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 3573
						) -- 3573
						do -- 3573
							local i = 0 -- 3574
							while i < #batch.actions do -- 3574
								local action = batch.actions[i + 1] -- 3575
								emitAgentStartEvent(shared, action) -- 3576
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3577
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3578
								action.result = sanitizeToolActionResultForHistory(action, result) -- 3579
								appendToolResultMessage(shared, action) -- 3580
								emitAgentFinishEvent(shared, action) -- 3581
								emitCheckpointEventForAction(shared, action) -- 3582
								persistHistoryState(shared) -- 3583
								if shared.stopToken.stopped then -- 3583
									break -- 3585
								end -- 3585
								i = i + 1 -- 3574
							end -- 3574
						end -- 3574
					end -- 3574
				end -- 3574
				::__continue549:: -- 3574
				batchIdx = batchIdx + 1 -- 3536
			end -- 3536
		end -- 3536
		persistHistoryState(shared) -- 3590
		return ____awaiter_resolve(nil, input.actions) -- 3590
	end) -- 3590
end -- 3528
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3594
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3594
		shared.pendingToolActions = nil -- 3595
		shared.preExecutedResults = nil -- 3596
		persistHistoryState(shared) -- 3597
		__TS__Await(maybeCompressHistory(shared)) -- 3598
		persistHistoryState(shared) -- 3599
		return ____awaiter_resolve(nil, "main") -- 3599
	end) -- 3599
end -- 3594
local EndNode = __TS__Class() -- 3604
EndNode.name = "EndNode" -- 3604
__TS__ClassExtends(EndNode, Node) -- 3604
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3605
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3605
		return ____awaiter_resolve(nil, nil) -- 3605
	end) -- 3605
end -- 3605
local CodingAgentFlow = __TS__Class() -- 3610
CodingAgentFlow.name = "CodingAgentFlow" -- 3610
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3610
function CodingAgentFlow.prototype.____constructor(self, role) -- 3611
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3612
	local read = __TS__New(ReadFileAction, 1, 0) -- 3613
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3614
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3615
	local list = __TS__New(ListFilesAction, 1, 0) -- 3616
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3617
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3618
	local build = __TS__New(BuildAction, 1, 0) -- 3619
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3620
	local edit = __TS__New(EditFileAction, 1, 0) -- 3621
	local batch = __TS__New(BatchToolAction, 1, 0) -- 3622
	local done = __TS__New(EndNode, 1, 0) -- 3623
	main:on("batch_tools", batch) -- 3625
	main:on("grep_files", search) -- 3626
	main:on("search_dora_api", searchDora) -- 3627
	main:on("glob_files", list) -- 3628
	if role == "main" then -- 3628
		main:on("read_file", read) -- 3630
		main:on("delete_file", del) -- 3631
		main:on("build", build) -- 3632
		main:on("edit_file", edit) -- 3633
		main:on("list_sub_agents", listSub) -- 3634
		main:on("spawn_sub_agent", spawn) -- 3635
	else -- 3635
		main:on("read_file", read) -- 3637
		main:on("delete_file", del) -- 3638
		main:on("build", build) -- 3639
		main:on("edit_file", edit) -- 3640
	end -- 3640
	main:on("done", done) -- 3642
	search:on("main", main) -- 3644
	searchDora:on("main", main) -- 3645
	list:on("main", main) -- 3646
	listSub:on("main", main) -- 3647
	spawn:on("main", main) -- 3648
	batch:on("main", main) -- 3649
	read:on("main", main) -- 3650
	del:on("main", main) -- 3651
	build:on("main", main) -- 3652
	edit:on("main", main) -- 3653
	Flow.prototype.____constructor(self, main) -- 3655
end -- 3611
local function runCodingAgentAsync(options) -- 3677
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3677
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3677
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3677
		end -- 3677
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3681
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3682
		if not llmConfigRes.success then -- 3682
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3682
		end -- 3682
		local llmConfig = llmConfigRes.config -- 3688
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3689
		if not taskRes.success then -- 3689
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3689
		end -- 3689
		local compressor = __TS__New(MemoryCompressor, { -- 3696
			compressionThreshold = 0.8, -- 3697
			compressionTargetThreshold = 0.5, -- 3698
			maxCompressionRounds = 3, -- 3699
			projectDir = options.workDir, -- 3700
			llmConfig = llmConfig, -- 3701
			promptPack = options.promptPack, -- 3702
			scope = options.memoryScope -- 3703
		}) -- 3703
		local persistedSession = compressor:getStorage():readSessionState() -- 3705
		local promptPack = compressor:getPromptPack() -- 3706
		local shared = { -- 3708
			sessionId = options.sessionId, -- 3709
			taskId = taskRes.taskId, -- 3710
			role = options.role or "main", -- 3711
			maxSteps = math.max( -- 3712
				1, -- 3712
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 3712
			), -- 3712
			llmMaxTry = math.max( -- 3713
				1, -- 3713
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 3713
			), -- 3713
			step = 0, -- 3714
			done = false, -- 3715
			stopToken = options.stopToken or ({stopped = false}), -- 3716
			response = "", -- 3717
			userQuery = normalizedPrompt, -- 3718
			workingDir = options.workDir, -- 3719
			useChineseResponse = options.useChineseResponse == true, -- 3720
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3721
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 3724
			llmConfig = llmConfig, -- 3725
			onEvent = options.onEvent, -- 3726
			promptPack = promptPack, -- 3727
			history = {}, -- 3728
			messages = persistedSession.messages, -- 3729
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 3730
			carryMessageIndex = persistedSession.carryMessageIndex, -- 3731
			memory = {compressor = compressor}, -- 3733
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 3737
			spawnSubAgent = options.spawnSubAgent, -- 3742
			listSubAgents = options.listSubAgents -- 3743
		} -- 3743
		local ____try = __TS__AsyncAwaiter(function() -- 3743
			emitAgentEvent(shared, { -- 3747
				type = "task_started", -- 3748
				sessionId = shared.sessionId, -- 3749
				taskId = shared.taskId, -- 3750
				prompt = shared.userQuery, -- 3751
				workDir = shared.workingDir, -- 3752
				maxSteps = shared.maxSteps -- 3753
			}) -- 3753
			if shared.stopToken.stopped then -- 3753
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3756
				return ____awaiter_resolve( -- 3756
					nil, -- 3756
					emitAgentTaskFinishEvent( -- 3757
						shared, -- 3757
						false, -- 3757
						getCancelledReason(shared) -- 3757
					) -- 3757
				) -- 3757
			end -- 3757
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3759
			local promptCommand = getPromptCommand(shared.userQuery) -- 3760
			if promptCommand == "clear" then -- 3760
				return ____awaiter_resolve( -- 3760
					nil, -- 3760
					clearSessionHistory(shared) -- 3762
				) -- 3762
			end -- 3762
			if promptCommand == "compact" then -- 3762
				if shared.role == "sub" then -- 3762
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 3766
					return ____awaiter_resolve( -- 3766
						nil, -- 3766
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 3767
					) -- 3767
				end -- 3767
				return ____awaiter_resolve( -- 3767
					nil, -- 3767
					__TS__Await(compactAllHistory(shared)) -- 3775
				) -- 3775
			end -- 3775
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3777
			persistHistoryState(shared) -- 3781
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3782
			__TS__Await(flow:run(shared)) -- 3783
			if shared.stopToken.stopped then -- 3783
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3785
				return ____awaiter_resolve( -- 3785
					nil, -- 3785
					emitAgentTaskFinishEvent( -- 3786
						shared, -- 3786
						false, -- 3786
						getCancelledReason(shared) -- 3786
					) -- 3786
				) -- 3786
			end -- 3786
			if shared.error then -- 3786
				return ____awaiter_resolve( -- 3786
					nil, -- 3786
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3789
				) -- 3789
			end -- 3789
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3792
			return ____awaiter_resolve( -- 3792
				nil, -- 3792
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3793
			) -- 3793
		end) -- 3793
		__TS__Await(____try.catch( -- 3746
			____try, -- 3746
			function(____, e) -- 3746
				return ____awaiter_resolve( -- 3746
					nil, -- 3746
					finalizeAgentFailure( -- 3796
						shared, -- 3796
						tostring(e) -- 3796
					) -- 3796
				) -- 3796
			end -- 3796
		)) -- 3796
	end) -- 3796
end -- 3677
function ____exports.runCodingAgent(options, callback) -- 3800
	local ____self_137 = runCodingAgentAsync(options) -- 3800
	____self_137["then"]( -- 3800
		____self_137, -- 3800
		function(____, result) return callback(result) end -- 3801
	) -- 3801
end -- 3800
return ____exports -- 3800
