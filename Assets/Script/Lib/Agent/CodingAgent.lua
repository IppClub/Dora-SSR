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
local estimateTextTokens = ____Utils.estimateTextTokens -- 4
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
function emitAgentEvent(shared, event) -- 756
	if shared.onEvent then -- 756
		do -- 756
			local function ____catch(____error) -- 756
				Log( -- 761
					"Error", -- 761
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 761
				) -- 761
			end -- 761
			local ____try, ____hasReturned = pcall(function() -- 761
				shared:onEvent(event) -- 759
			end) -- 759
			if not ____try then -- 759
				____catch(____hasReturned) -- 759
			end -- 759
		end -- 759
	end -- 759
end -- 759
function getCancelledReason(shared) -- 890
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 890
		return shared.stopToken.reason -- 891
	end -- 891
	return shared.useChineseResponse and "已取消" or "cancelled" -- 892
end -- 892
function truncateText(text, maxLen) -- 1073
	if #text <= maxLen then -- 1073
		return text -- 1074
	end -- 1074
	local nextPos = utf8.offset(text, maxLen + 1) -- 1075
	if nextPos == nil then -- 1075
		return text -- 1076
	end -- 1076
	return string.sub(text, 1, nextPos - 1) .. "..." -- 1077
end -- 1077
function getReplyLanguageDirective(shared) -- 1087
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 1088
end -- 1088
function replacePromptVars(template, vars) -- 1093
	local output = template -- 1094
	for key in pairs(vars) do -- 1095
		output = table.concat( -- 1096
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 1096
			vars[key] or "" or "," -- 1096
		) -- 1096
	end -- 1096
	return output -- 1098
end -- 1098
function getDecisionToolDefinitions(shared) -- 1249
	local base = replacePromptVars( -- 1250
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1251
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1252
	) -- 1252
	local spawnTool = "\n\n9. list_sub_agents: Query sub-agent state under the current main session\n\t- Parameters: status(optional), limit(optional), offset(optional), query(optional)\n\t- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.\n\t- status defaults to active_or_recent and may also be running, done, failed, or all.\n\t- limit defaults to a small recent window. Use offset to page older items.\n\t- query filters by title, goal, or summary text.\n\t- Do not use this after a successful spawn_sub_agent in the same turn.\n\n10. spawn_sub_agent: Create and start a sub agent session for delegated implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n\t- For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.\n\t- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.\n\t- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.\n\t- filesHint is an optional list of likely files or directories." -- 1254
	local availability = shared and (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat( -- 1275
		getAllowedToolsForRole(shared.role), -- 1276
		", " -- 1276
	) or "" -- 1276
	local withRole = (base .. ((shared and shared.role) == "main" and spawnTool or "")) .. availability -- 1278
	if (shared and shared.decisionMode) ~= "xml" then -- 1278
		return withRole -- 1280
	end -- 1280
	return withRole .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1282
end -- 1282
function getFinishMessage(params, fallback) -- 1581
	if fallback == nil then -- 1581
		fallback = "" -- 1581
	end -- 1581
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1581
		return __TS__StringTrim(params.message) -- 1583
	end -- 1583
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1583
		return __TS__StringTrim(params.response) -- 1586
	end -- 1586
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1586
		return __TS__StringTrim(params.summary) -- 1589
	end -- 1589
	return __TS__StringTrim(fallback) -- 1591
end -- 1591
function persistHistoryState(shared) -- 1594
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1595
end -- 1595
function getActiveConversationMessages(shared) -- 1602
	local activeMessages = {} -- 1603
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1603
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1610
	end -- 1610
	do -- 1610
		local i = shared.lastConsolidatedIndex -- 1614
		while i < #shared.messages do -- 1614
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1615
			i = i + 1 -- 1614
		end -- 1614
	end -- 1614
	return activeMessages -- 1617
end -- 1617
function getActiveRealMessageCount(shared) -- 1620
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1621
end -- 1621
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1624
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1629
	local previousActiveStart = shared.lastConsolidatedIndex -- 1630
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1631
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1632
	if type(carryMessageIndex) == "number" then -- 1632
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1632
		else -- 1632
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1640
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1643
		end -- 1643
	else -- 1643
		shared.carryMessageIndex = nil -- 1648
	end -- 1648
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1648
		shared.carryMessageIndex = nil -- 1658
	end -- 1658
end -- 1658
function getDecisionPath(params) -- 1916
	if type(params.path) == "string" then -- 1916
		return __TS__StringTrim(params.path) -- 1917
	end -- 1917
	if type(params.target_file) == "string" then -- 1917
		return __TS__StringTrim(params.target_file) -- 1918
	end -- 1918
	return "" -- 1919
end -- 1919
function clampIntegerParam(value, fallback, minValue, maxValue) -- 1922
	local num = __TS__Number(value) -- 1923
	if not __TS__NumberIsFinite(num) then -- 1923
		num = fallback -- 1924
	end -- 1924
	num = math.floor(num) -- 1925
	if num < minValue then -- 1925
		num = minValue -- 1926
	end -- 1926
	if maxValue ~= nil and num > maxValue then -- 1926
		num = maxValue -- 1927
	end -- 1927
	return num -- 1928
end -- 1928
function parseReadLineParam(value, fallback, paramName) -- 1931
	local num = __TS__Number(value) -- 1936
	if not __TS__NumberIsFinite(num) then -- 1936
		num = fallback -- 1937
	end -- 1937
	num = math.floor(num) -- 1938
	if num == 0 then -- 1938
		return {success = false, message = paramName .. " cannot be 0"} -- 1940
	end -- 1940
	return {success = true, value = num} -- 1942
end -- 1942
function validateDecision(tool, params) -- 1945
	if tool == "finish" then -- 1945
		local message = getFinishMessage(params) -- 1950
		if message == "" then -- 1950
			return {success = false, message = "finish requires params.message"} -- 1951
		end -- 1951
		params.message = message -- 1952
		return {success = true, params = params} -- 1953
	end -- 1953
	if tool == "read_file" then -- 1953
		local path = getDecisionPath(params) -- 1957
		if path == "" then -- 1957
			return {success = false, message = "read_file requires path"} -- 1958
		end -- 1958
		params.path = path -- 1959
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1960
		if not startLineRes.success then -- 1960
			return startLineRes -- 1961
		end -- 1961
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1962
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1963
		if not endLineRes.success then -- 1963
			return endLineRes -- 1964
		end -- 1964
		params.startLine = startLineRes.value -- 1965
		params.endLine = endLineRes.value -- 1966
		return {success = true, params = params} -- 1967
	end -- 1967
	if tool == "edit_file" then -- 1967
		local path = getDecisionPath(params) -- 1971
		if path == "" then -- 1971
			return {success = false, message = "edit_file requires path"} -- 1972
		end -- 1972
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1973
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1974
		params.path = path -- 1975
		params.old_str = oldStr -- 1976
		params.new_str = newStr -- 1977
		return {success = true, params = params} -- 1978
	end -- 1978
	if tool == "delete_file" then -- 1978
		local targetFile = getDecisionPath(params) -- 1982
		if targetFile == "" then -- 1982
			return {success = false, message = "delete_file requires target_file"} -- 1983
		end -- 1983
		params.target_file = targetFile -- 1984
		return {success = true, params = params} -- 1985
	end -- 1985
	if tool == "grep_files" then -- 1985
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1989
		if pattern == "" then -- 1989
			return {success = false, message = "grep_files requires pattern"} -- 1990
		end -- 1990
		params.pattern = pattern -- 1991
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1992
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1993
		return {success = true, params = params} -- 1994
	end -- 1994
	if tool == "search_dora_api" then -- 1994
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1998
		if pattern == "" then -- 1998
			return {success = false, message = "search_dora_api requires pattern"} -- 1999
		end -- 1999
		params.pattern = pattern -- 2000
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 2001
		return {success = true, params = params} -- 2002
	end -- 2002
	if tool == "glob_files" then -- 2002
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 2006
		return {success = true, params = params} -- 2007
	end -- 2007
	if tool == "build" then -- 2007
		local path = getDecisionPath(params) -- 2011
		if path ~= "" then -- 2011
			params.path = path -- 2013
		end -- 2013
		return {success = true, params = params} -- 2015
	end -- 2015
	if tool == "list_sub_agents" then -- 2015
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2019
		if status ~= "" then -- 2019
			params.status = status -- 2021
		end -- 2021
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2023
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2024
		if type(params.query) == "string" then -- 2024
			params.query = __TS__StringTrim(params.query) -- 2026
		end -- 2026
		return {success = true, params = params} -- 2028
	end -- 2028
	if tool == "spawn_sub_agent" then -- 2028
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2032
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2033
		if prompt == "" then -- 2033
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2034
		end -- 2034
		if title == "" then -- 2034
			return {success = false, message = "spawn_sub_agent requires title"} -- 2035
		end -- 2035
		params.prompt = prompt -- 2036
		params.title = title -- 2037
		if type(params.expectedOutput) == "string" then -- 2037
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2039
		end -- 2039
		if isArray(params.filesHint) then -- 2039
			params.filesHint = __TS__ArrayMap( -- 2042
				__TS__ArrayFilter( -- 2042
					params.filesHint, -- 2042
					function(____, item) return type(item) == "string" end -- 2043
				), -- 2043
				function(____, item) return sanitizeUTF8(item) end -- 2044
			) -- 2044
		end -- 2044
		return {success = true, params = params} -- 2046
	end -- 2046
	return {success = true, params = params} -- 2049
end -- 2049
function getAllowedToolsForRole(role) -- 2075
	return role == "main" and ({ -- 2076
		"read_file", -- 2077
		"edit_file", -- 2077
		"delete_file", -- 2077
		"grep_files", -- 2077
		"search_dora_api", -- 2077
		"glob_files", -- 2077
		"build", -- 2077
		"list_sub_agents", -- 2077
		"spawn_sub_agent", -- 2077
		"finish" -- 2077
	}) or ({ -- 2077
		"read_file", -- 2078
		"edit_file", -- 2078
		"delete_file", -- 2078
		"grep_files", -- 2078
		"search_dora_api", -- 2078
		"glob_files", -- 2078
		"build", -- 2078
		"finish" -- 2078
	}) -- 2078
end -- 2078
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2184
	if includeToolDefinitions == nil then -- 2184
		includeToolDefinitions = false -- 2184
	end -- 2184
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2185
	local sections = { -- 2188
		shared.promptPack.agentIdentityPrompt, -- 2189
		rolePrompt, -- 2190
		getReplyLanguageDirective(shared) -- 2191
	} -- 2191
	if shared.decisionMode == "tool_calling" then -- 2191
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2194
	end -- 2194
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2196
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2197
	if memoryContext ~= "" then -- 2197
		sections[#sections + 1] = memoryContext -- 2199
	end -- 2199
	if includeToolDefinitions then -- 2199
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2202
		if shared.decisionMode == "xml" then -- 2202
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2204
		end -- 2204
	end -- 2204
	local skillsSection = buildSkillsSection(shared) -- 2208
	if skillsSection ~= "" then -- 2208
		sections[#sections + 1] = skillsSection -- 2210
	end -- 2210
	return table.concat(sections, "\n\n") -- 2212
end -- 2212
function buildSkillsSection(shared) -- 2215
	local ____opt_42 = shared.skills -- 2215
	if not (____opt_42 and ____opt_42.loader) then -- 2215
		return "" -- 2217
	end -- 2217
	return shared.skills.loader:buildSkillsPromptSection() -- 2219
end -- 2219
function buildXmlDecisionInstruction(shared, feedback) -- 2337
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2338
end -- 2338
function executeToolAction(shared, action) -- 3520
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3520
		if shared.stopToken.stopped then -- 3520
			return ____awaiter_resolve( -- 3520
				nil, -- 3520
				{ -- 3522
					success = false, -- 3522
					message = getCancelledReason(shared) -- 3522
				} -- 3522
			) -- 3522
		end -- 3522
		local params = action.params -- 3524
		if action.tool == "read_file" then -- 3524
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3526
			if __TS__StringTrim(path) == "" then -- 3526
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3526
			end -- 3526
			local ____Tools_readFile_104 = Tools.readFile -- 3530
			local ____shared_workingDir_102 = shared.workingDir -- 3531
			local ____params_startLine_100 = params.startLine -- 3533
			if ____params_startLine_100 == nil then -- 3533
				____params_startLine_100 = 1 -- 3533
			end -- 3533
			local ____TS__Number_result_103 = __TS__Number(____params_startLine_100) -- 3533
			local ____params_endLine_101 = params.endLine -- 3534
			if ____params_endLine_101 == nil then -- 3534
				____params_endLine_101 = READ_FILE_DEFAULT_LIMIT -- 3534
			end -- 3534
			return ____awaiter_resolve( -- 3534
				nil, -- 3534
				____Tools_readFile_104( -- 3530
					____shared_workingDir_102, -- 3531
					path, -- 3532
					____TS__Number_result_103, -- 3533
					__TS__Number(____params_endLine_101), -- 3534
					shared.useChineseResponse and "zh" or "en" -- 3535
				) -- 3535
			) -- 3535
		end -- 3535
		if action.tool == "grep_files" then -- 3535
			local ____Tools_searchFiles_118 = Tools.searchFiles -- 3539
			local ____shared_workingDir_111 = shared.workingDir -- 3540
			local ____temp_112 = params.path or "" -- 3541
			local ____temp_113 = params.pattern or "" -- 3542
			local ____params_globs_114 = params.globs -- 3543
			local ____params_useRegex_115 = params.useRegex -- 3544
			local ____params_caseSensitive_116 = params.caseSensitive -- 3545
			local ____math_max_107 = math.max -- 3548
			local ____math_floor_106 = math.floor -- 3548
			local ____params_limit_105 = params.limit -- 3548
			if ____params_limit_105 == nil then -- 3548
				____params_limit_105 = SEARCH_FILES_LIMIT_DEFAULT -- 3548
			end -- 3548
			local ____math_max_107_result_117 = ____math_max_107( -- 3548
				1, -- 3548
				____math_floor_106(__TS__Number(____params_limit_105)) -- 3548
			) -- 3548
			local ____math_max_110 = math.max -- 3549
			local ____math_floor_109 = math.floor -- 3549
			local ____params_offset_108 = params.offset -- 3549
			if ____params_offset_108 == nil then -- 3549
				____params_offset_108 = 0 -- 3549
			end -- 3549
			local result = __TS__Await(____Tools_searchFiles_118({ -- 3539
				workDir = ____shared_workingDir_111, -- 3540
				path = ____temp_112, -- 3541
				pattern = ____temp_113, -- 3542
				globs = ____params_globs_114, -- 3543
				useRegex = ____params_useRegex_115, -- 3544
				caseSensitive = ____params_caseSensitive_116, -- 3545
				includeContent = true, -- 3546
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3547
				limit = ____math_max_107_result_117, -- 3548
				offset = ____math_max_110( -- 3549
					0, -- 3549
					____math_floor_109(__TS__Number(____params_offset_108)) -- 3549
				), -- 3549
				groupByFile = params.groupByFile == true -- 3550
			})) -- 3550
			return ____awaiter_resolve(nil, result) -- 3550
		end -- 3550
		if action.tool == "search_dora_api" then -- 3550
			local ____Tools_searchDoraAPI_126 = Tools.searchDoraAPI -- 3555
			local ____temp_122 = params.pattern or "" -- 3556
			local ____temp_123 = params.docSource or "api" -- 3557
			local ____temp_124 = shared.useChineseResponse and "zh" or "en" -- 3558
			local ____temp_125 = params.programmingLanguage or "ts" -- 3559
			local ____math_min_121 = math.min -- 3560
			local ____math_max_120 = math.max -- 3560
			local ____params_limit_119 = params.limit -- 3560
			if ____params_limit_119 == nil then -- 3560
				____params_limit_119 = 8 -- 3560
			end -- 3560
			local result = __TS__Await(____Tools_searchDoraAPI_126({ -- 3555
				pattern = ____temp_122, -- 3556
				docSource = ____temp_123, -- 3557
				docLanguage = ____temp_124, -- 3558
				programmingLanguage = ____temp_125, -- 3559
				limit = ____math_min_121( -- 3560
					SEARCH_DORA_API_LIMIT_MAX, -- 3560
					____math_max_120( -- 3560
						1, -- 3560
						__TS__Number(____params_limit_119) -- 3560
					) -- 3560
				), -- 3560
				useRegex = params.useRegex, -- 3561
				caseSensitive = false, -- 3562
				includeContent = true, -- 3563
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3564
			})) -- 3564
			return ____awaiter_resolve(nil, result) -- 3564
		end -- 3564
		if action.tool == "glob_files" then -- 3564
			local ____Tools_listFiles_133 = Tools.listFiles -- 3569
			local ____shared_workingDir_130 = shared.workingDir -- 3570
			local ____temp_131 = params.path or "" -- 3571
			local ____params_globs_132 = params.globs -- 3572
			local ____math_max_129 = math.max -- 3573
			local ____math_floor_128 = math.floor -- 3573
			local ____params_maxEntries_127 = params.maxEntries -- 3573
			if ____params_maxEntries_127 == nil then -- 3573
				____params_maxEntries_127 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3573
			end -- 3573
			local result = ____Tools_listFiles_133({ -- 3569
				workDir = ____shared_workingDir_130, -- 3570
				path = ____temp_131, -- 3571
				globs = ____params_globs_132, -- 3572
				maxEntries = ____math_max_129( -- 3573
					1, -- 3573
					____math_floor_128(__TS__Number(____params_maxEntries_127)) -- 3573
				) -- 3573
			}) -- 3573
			return ____awaiter_resolve(nil, result) -- 3573
		end -- 3573
		if action.tool == "delete_file" then -- 3573
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3578
			if __TS__StringTrim(targetFile) == "" then -- 3578
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3578
			end -- 3578
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3582
			if not result.success then -- 3582
				return ____awaiter_resolve(nil, result) -- 3582
			end -- 3582
			return ____awaiter_resolve(nil, { -- 3582
				success = true, -- 3590
				changed = true, -- 3591
				mode = "delete", -- 3592
				checkpointId = result.checkpointId, -- 3593
				checkpointSeq = result.checkpointSeq, -- 3594
				files = {{path = targetFile, op = "delete"}} -- 3595
			}) -- 3595
		end -- 3595
		if action.tool == "build" then -- 3595
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3599
			return ____awaiter_resolve(nil, result) -- 3599
		end -- 3599
		if action.tool == "spawn_sub_agent" then -- 3599
			if not shared.spawnSubAgent then -- 3599
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3599
			end -- 3599
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3599
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3599
			end -- 3599
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3612
				params.filesHint, -- 3613
				function(____, item) return type(item) == "string" end -- 3613
			) or nil -- 3613
			local result = __TS__Await(shared.spawnSubAgent({ -- 3615
				parentSessionId = shared.sessionId, -- 3616
				projectRoot = shared.workingDir, -- 3617
				title = type(params.title) == "string" and params.title or "Sub", -- 3618
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3619
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3620
				filesHint = filesHint -- 3621
			})) -- 3621
			if not result.success then -- 3621
				return ____awaiter_resolve(nil, result) -- 3621
			end -- 3621
			return ____awaiter_resolve(nil, { -- 3621
				success = true, -- 3627
				sessionId = result.sessionId, -- 3628
				taskId = result.taskId, -- 3629
				title = result.title, -- 3630
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3631
			}) -- 3631
		end -- 3631
		if action.tool == "list_sub_agents" then -- 3631
			if not shared.listSubAgents then -- 3631
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3631
			end -- 3631
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3631
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3631
			end -- 3631
			local result = __TS__Await(shared.listSubAgents({ -- 3641
				sessionId = shared.sessionId, -- 3642
				projectRoot = shared.workingDir, -- 3643
				status = type(params.status) == "string" and params.status or nil, -- 3644
				limit = type(params.limit) == "number" and params.limit or nil, -- 3645
				offset = type(params.offset) == "number" and params.offset or nil, -- 3646
				query = type(params.query) == "string" and params.query or nil -- 3647
			})) -- 3647
			return ____awaiter_resolve(nil, result) -- 3647
		end -- 3647
		if action.tool == "edit_file" then -- 3647
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3652
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3655
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3656
			if __TS__StringTrim(path) == "" then -- 3656
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3656
			end -- 3656
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3658
			return ____awaiter_resolve( -- 3658
				nil, -- 3658
				actionNode:exec({ -- 3659
					path = path, -- 3660
					oldStr = oldStr, -- 3661
					newStr = newStr, -- 3662
					taskId = shared.taskId, -- 3663
					workDir = shared.workingDir -- 3664
				}) -- 3664
			) -- 3664
		end -- 3664
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3664
	end) -- 3664
end -- 3664
function emitAgentTaskFinishEvent(shared, success, message) -- 3850
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3851
	emitAgentEvent(shared, { -- 3857
		type = "task_finished", -- 3858
		sessionId = shared.sessionId, -- 3859
		taskId = shared.taskId, -- 3860
		success = result.success, -- 3861
		message = result.message, -- 3862
		steps = result.steps -- 3863
	}) -- 3863
	return result -- 3865
end -- 3865
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
local HISTORY_READ_FILE_MAX_CHARS = 12000 -- 669
local HISTORY_READ_FILE_MAX_LINES = 300 -- 670
READ_FILE_DEFAULT_LIMIT = 300 -- 671
local HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 672
local HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 673
local HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 674
local HISTORY_BUILD_MAX_MESSAGES = 50 -- 675
local HISTORY_BUILD_MESSAGE_MAX_CHARS = 1200 -- 676
SEARCH_DORA_API_LIMIT_MAX = 20 -- 677
SEARCH_FILES_LIMIT_DEFAULT = 20 -- 678
LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 679
SEARCH_PREVIEW_CONTEXT = 80 -- 680
local AGENT_DEFAULT_MAX_STEPS = 100 -- 681
local AGENT_DEFAULT_LLM_MAX_TRY = 5 -- 682
local AGENT_DEFAULT_LLM_TEMPERATURE = 0.1 -- 683
local AGENT_DEFAULT_LLM_MAX_TOKENS = 8192 -- 684
local function buildLLMOptions(llmConfig, overrides) -- 686
	local options = {temperature = llmConfig.temperature or AGENT_DEFAULT_LLM_TEMPERATURE, max_tokens = llmConfig.maxTokens or AGENT_DEFAULT_LLM_MAX_TOKENS} -- 687
	if llmConfig.reasoningEffort then -- 687
		options.reasoning_effort = llmConfig.reasoningEffort -- 692
	end -- 692
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 694
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 694
		__TS__Delete(merged, "reasoning_effort") -- 699
	else -- 699
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 701
	end -- 701
	return merged -- 703
end -- 686
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 766
	local messagesTokens = 0 -- 773
	do -- 773
		local i = 0 -- 774
		while i < #messages do -- 774
			local message = messages[i + 1] -- 775
			messagesTokens = messagesTokens + 8 -- 776
			messagesTokens = messagesTokens + estimateTextTokens(message.role or "") -- 777
			messagesTokens = messagesTokens + estimateTextTokens(message.content or "") -- 778
			messagesTokens = messagesTokens + estimateTextTokens(message.name or "") -- 779
			messagesTokens = messagesTokens + estimateTextTokens(message.tool_call_id or "") -- 780
			messagesTokens = messagesTokens + estimateTextTokens(message.reasoning_content or "") -- 781
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 782
			messagesTokens = messagesTokens + estimateTextTokens(toolCallsText or "") -- 783
			i = i + 1 -- 774
		end -- 774
	end -- 774
	local toolDefinitionsTokens = 0 -- 786
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 786
		local toolsText = safeJsonEncode(options.tools) -- 788
		toolDefinitionsTokens = toolsText and estimateTextTokens(toolsText) or 0 -- 789
	end -- 789
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 792
	__TS__Delete(optionsWithoutTools, "tools") -- 793
	local optionsText = safeJsonEncode(optionsWithoutTools) -- 794
	local optionsTokens = optionsText and estimateTextTokens(optionsText) or 0 -- 795
	local contextWindow = math.max(64000, shared.llmConfig.contextWindow) -- 796
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 797
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 802
		1024, -- 804
		math.floor(contextWindow * 0.2) -- 804
	) -- 804
	local structuralOverhead = math.max(256, #messages * 16) -- 805
	local usedTokens = messagesTokens + optionsTokens + structuralOverhead -- 807
	local maxTokens = contextWindow -- 808
	emitAgentEvent( -- 809
		shared, -- 809
		{ -- 809
			type = "metrics_updated", -- 810
			sessionId = shared.sessionId, -- 811
			taskId = shared.taskId, -- 812
			step = step, -- 813
			metrics = {context = { -- 814
				usedTokens = usedTokens, -- 816
				maxTokens = maxTokens, -- 817
				ratio = math.max( -- 818
					0, -- 818
					math.min(1, usedTokens / maxTokens) -- 818
				), -- 818
				messagesTokens = messagesTokens, -- 819
				optionsTokens = optionsTokens, -- 820
				toolDefinitionsTokens = toolDefinitionsTokens, -- 821
				reservedOutputTokens = reservedOutputTokens, -- 822
				structuralOverhead = structuralOverhead, -- 823
				contextWindow = contextWindow, -- 824
				source = "llm_input_estimate", -- 825
				updatedAt = os.time(), -- 826
				phase = phase, -- 827
				step = step -- 828
			}} -- 828
		} -- 828
	) -- 828
end -- 766
local function emitAgentStartEvent(shared, action) -- 834
	emitAgentEvent(shared, { -- 835
		type = "tool_started", -- 836
		sessionId = shared.sessionId, -- 837
		taskId = shared.taskId, -- 838
		step = action.step, -- 839
		tool = action.tool -- 840
	}) -- 840
end -- 834
local function emitAgentFinishEvent(shared, action) -- 844
	emitAgentEvent(shared, { -- 845
		type = "tool_finished", -- 846
		sessionId = shared.sessionId, -- 847
		taskId = shared.taskId, -- 848
		step = action.step, -- 849
		tool = action.tool, -- 850
		result = action.result or ({}) -- 851
	}) -- 851
end -- 844
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 855
	emitAgentEvent(shared, { -- 856
		type = "assistant_message_updated", -- 857
		sessionId = shared.sessionId, -- 858
		taskId = shared.taskId, -- 859
		step = shared.step + 1, -- 860
		content = content, -- 861
		reasoningContent = reasoningContent -- 862
	}) -- 862
end -- 855
local function getMemoryCompressionStartReason(shared) -- 866
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 867
end -- 866
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 872
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 873
end -- 872
local function getMemoryCompressionFailureReason(shared, ____error) -- 878
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 879
end -- 878
local function summarizeHistoryEntryPreview(text, maxChars) -- 884
	if maxChars == nil then -- 884
		maxChars = 180 -- 884
	end -- 884
	local trimmed = __TS__StringTrim(text) -- 885
	if trimmed == "" then -- 885
		return "" -- 886
	end -- 886
	return truncateText(trimmed, maxChars) -- 887
end -- 884
local function getMaxStepsReachedReason(shared) -- 895
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 896
end -- 895
local function getFailureSummaryFallback(shared, ____error) -- 901
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 902
end -- 901
local function finalizeAgentFailure(shared, ____error) -- 907
	if shared.stopToken.stopped then -- 907
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 909
		return emitAgentTaskFinishEvent( -- 910
			shared, -- 910
			false, -- 910
			getCancelledReason(shared) -- 910
		) -- 910
	end -- 910
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 912
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 913
end -- 907
local function getPromptCommand(prompt) -- 916
	local trimmed = __TS__StringTrim(prompt) -- 917
	if trimmed == "/compact" then -- 917
		return "compact" -- 918
	end -- 918
	if trimmed == "/clear" then -- 918
		return "clear" -- 919
	end -- 919
	return nil -- 920
end -- 916
function ____exports.truncateAgentUserPrompt(prompt) -- 923
	if not prompt then -- 923
		return "" -- 924
	end -- 924
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 924
		return prompt -- 925
	end -- 925
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 926
	if offset == nil then -- 926
		return prompt -- 927
	end -- 927
	return string.sub(prompt, 1, offset - 1) -- 928
end -- 923
local function canWriteStepLLMDebug(shared, stepId) -- 931
	if stepId == nil then -- 931
		stepId = shared.step + 1 -- 931
	end -- 931
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 932
end -- 931
local function ensureDirRecursive(dir) -- 939
	if not dir then -- 939
		return false -- 940
	end -- 940
	if Content:exist(dir) then -- 940
		return Content:isdir(dir) -- 941
	end -- 941
	local parent = Path:getPath(dir) -- 942
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 942
		return false -- 944
	end -- 944
	return Content:mkdir(dir) -- 946
end -- 939
local function encodeDebugJSON(value) -- 949
	local text, err = safeJsonEncode(value) -- 950
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 951
end -- 949
local function getStepLLMDebugDir(shared) -- 954
	return Path( -- 955
		shared.workingDir, -- 956
		".agent", -- 957
		tostring(shared.sessionId), -- 958
		tostring(shared.taskId) -- 959
	) -- 959
end -- 954
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 963
	return Path( -- 964
		getStepLLMDebugDir(shared), -- 964
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 964
	) -- 964
end -- 963
local function getLatestStepLLMDebugSeq(shared, stepId) -- 967
	if not canWriteStepLLMDebug(shared, stepId) then -- 967
		return 0 -- 968
	end -- 968
	local dir = getStepLLMDebugDir(shared) -- 969
	if not Content:exist(dir) or not Content:isdir(dir) then -- 969
		return 0 -- 970
	end -- 970
	local latest = 0 -- 971
	for ____, file in ipairs(Content:getFiles(dir)) do -- 972
		do -- 972
			local name = Path:getFilename(file) -- 973
			local seqText = string.match( -- 974
				name, -- 974
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 974
			) -- 974
			if seqText ~= nil then -- 974
				latest = math.max( -- 976
					latest, -- 976
					tonumber(seqText) -- 976
				) -- 976
				goto __continue128 -- 977
			end -- 977
			local legacyMatch = string.match( -- 979
				name, -- 979
				("^" .. tostring(stepId)) .. "_in%.md$" -- 979
			) -- 979
			if legacyMatch ~= nil then -- 979
				latest = math.max(latest, 1) -- 981
			end -- 981
		end -- 981
		::__continue128:: -- 981
	end -- 981
	return latest -- 984
end -- 967
local function writeStepLLMDebugFile(path, content) -- 987
	if not Content:save(path, content) then -- 987
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 989
		return false -- 990
	end -- 990
	return true -- 992
end -- 987
local function createStepLLMDebugPair(shared, stepId, inContent) -- 995
	if not canWriteStepLLMDebug(shared, stepId) then -- 995
		return 0 -- 996
	end -- 996
	local dir = getStepLLMDebugDir(shared) -- 997
	if not ensureDirRecursive(dir) then -- 997
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 999
		return 0 -- 1000
	end -- 1000
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 1002
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 1003
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 1004
	if not writeStepLLMDebugFile(inPath, inContent) then -- 1004
		return 0 -- 1006
	end -- 1006
	writeStepLLMDebugFile(outPath, "") -- 1008
	return seq -- 1009
end -- 995
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 1012
	if not canWriteStepLLMDebug(shared, stepId) then -- 1012
		return -- 1013
	end -- 1013
	local dir = getStepLLMDebugDir(shared) -- 1014
	if not ensureDirRecursive(dir) then -- 1014
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 1016
		return -- 1017
	end -- 1017
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 1019
	if latestSeq <= 0 then -- 1019
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 1021
		writeStepLLMDebugFile(outPath, content) -- 1022
		return -- 1023
	end -- 1023
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 1025
	writeStepLLMDebugFile(outPath, content) -- 1026
end -- 1012
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 1029
	if not canWriteStepLLMDebug(shared, stepId) then -- 1029
		return -- 1030
	end -- 1030
	local sections = { -- 1031
		"# LLM Input", -- 1032
		"session_id: " .. tostring(shared.sessionId), -- 1033
		"task_id: " .. tostring(shared.taskId), -- 1034
		"step_id: " .. tostring(stepId), -- 1035
		"phase: " .. phase, -- 1036
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1037
		"## Options", -- 1038
		"```json", -- 1039
		encodeDebugJSON(options), -- 1040
		"```" -- 1041
	} -- 1041
	do -- 1041
		local i = 0 -- 1043
		while i < #messages do -- 1043
			local message = messages[i + 1] -- 1044
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 1045
			sections[#sections + 1] = encodeDebugJSON(message) -- 1046
			i = i + 1 -- 1043
		end -- 1043
	end -- 1043
	createStepLLMDebugPair( -- 1048
		shared, -- 1048
		stepId, -- 1048
		table.concat(sections, "\n") -- 1048
	) -- 1048
end -- 1029
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 1051
	if not canWriteStepLLMDebug(shared, stepId) then -- 1051
		return -- 1052
	end -- 1052
	local ____array_2 = __TS__SparseArrayNew( -- 1052
		"# LLM Output", -- 1054
		"session_id: " .. tostring(shared.sessionId), -- 1055
		"task_id: " .. tostring(shared.taskId), -- 1056
		"step_id: " .. tostring(stepId), -- 1057
		"phase: " .. phase, -- 1058
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1059
		table.unpack(meta and ({ -- 1060
			"## Meta", -- 1060
			"```json", -- 1060
			encodeDebugJSON(meta), -- 1060
			"```" -- 1060
		}) or ({})) -- 1060
	) -- 1060
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 1060
	local sections = {__TS__SparseArraySpread(____array_2)} -- 1053
	updateLatestStepLLMDebugOutput( -- 1064
		shared, -- 1064
		stepId, -- 1064
		table.concat(sections, "\n") -- 1064
	) -- 1064
end -- 1051
local function toJson(value) -- 1067
	local text, err = safeJsonEncode(value) -- 1068
	if text ~= nil then -- 1068
		return text -- 1069
	end -- 1069
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 1070
end -- 1067
local function utf8TakeHead(text, maxChars) -- 1080
	if maxChars <= 0 or text == "" then -- 1080
		return "" -- 1081
	end -- 1081
	local nextPos = utf8.offset(text, maxChars + 1) -- 1082
	if nextPos == nil then -- 1082
		return text -- 1083
	end -- 1083
	return string.sub(text, 1, nextPos - 1) -- 1084
end -- 1080
local function limitReadContentForHistory(content, tool) -- 1101
	local lines = __TS__StringSplit(content, "\n") -- 1102
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 1103
	local limitedByLines = overLineLimit and table.concat( -- 1104
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 1105
		"\n" -- 1105
	) or content -- 1105
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 1105
		return content -- 1108
	end -- 1108
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 1110
	local reasons = {} -- 1113
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 1113
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 1114
	end -- 1114
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 1114
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 1115
	end -- 1115
	local hint = "Narrow the requested line range." -- 1116
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 1117
end -- 1101
local function summarizeEditTextParamForHistory(value, key) -- 1120
	if type(value) ~= "string" then -- 1120
		return nil -- 1121
	end -- 1121
	local text = value -- 1122
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 1123
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 1124
end -- 1120
local function sanitizeReadResultForHistory(tool, result) -- 1132
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 1132
		return result -- 1134
	end -- 1134
	local clone = {} -- 1136
	for key in pairs(result) do -- 1137
		clone[key] = result[key] -- 1138
	end -- 1138
	clone.content = limitReadContentForHistory(result.content, tool) -- 1140
	return clone -- 1141
end -- 1132
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 1144
	local shown = math.min(#items, maxItems) -- 1148
	local out = {} -- 1149
	do -- 1149
		local i = 0 -- 1150
		while i < shown do -- 1150
			local row = items[i + 1] -- 1151
			out[#out + 1] = { -- 1152
				file = row.file, -- 1153
				line = row.line, -- 1154
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1155
			} -- 1155
			i = i + 1 -- 1150
		end -- 1150
	end -- 1150
	return out -- 1160
end -- 1144
local function sanitizeSearchResultForHistory(tool, result) -- 1163
	if result.success ~= true or not isArray(result.results) then -- 1163
		return result -- 1167
	end -- 1167
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1167
		return result -- 1168
	end -- 1168
	local clone = {} -- 1169
	for key in pairs(result) do -- 1170
		clone[key] = result[key] -- 1171
	end -- 1171
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 1173
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1174
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1174
		local grouped = result.groupedResults -- 1179
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 1180
		local sanitizedGroups = {} -- 1181
		do -- 1181
			local i = 0 -- 1182
			while i < shown do -- 1182
				local row = grouped[i + 1] -- 1183
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1184
					file = row.file, -- 1185
					totalMatches = row.totalMatches, -- 1186
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1187
				} -- 1187
				i = i + 1 -- 1182
			end -- 1182
		end -- 1182
		clone.groupedResults = sanitizedGroups -- 1192
	end -- 1192
	return clone -- 1194
end -- 1163
local function sanitizeListFilesResultForHistory(result) -- 1197
	if result.success ~= true or not isArray(result.files) then -- 1197
		return result -- 1198
	end -- 1198
	local clone = {} -- 1199
	for key in pairs(result) do -- 1200
		clone[key] = result[key] -- 1201
	end -- 1201
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1203
	return clone -- 1204
end -- 1197
local function sanitizeBuildResultForHistory(result) -- 1207
	if not isArray(result.messages) then -- 1207
		return result -- 1208
	end -- 1208
	local clone = {} -- 1209
	for key in pairs(result) do -- 1210
		clone[key] = result[key] -- 1211
	end -- 1211
	local messages = result.messages -- 1213
	local shown = math.min(#messages, HISTORY_BUILD_MAX_MESSAGES) -- 1214
	local sanitized = {} -- 1215
	do -- 1215
		local i = 0 -- 1216
		while i < shown do -- 1216
			local item = messages[i + 1] -- 1217
			local next = {} -- 1218
			for key in pairs(item) do -- 1219
				local value = item[key] -- 1220
				next[key] = key == "message" and type(value) == "string" and truncateText(value, HISTORY_BUILD_MESSAGE_MAX_CHARS) or value -- 1221
			end -- 1221
			sanitized[#sanitized + 1] = next -- 1225
			i = i + 1 -- 1216
		end -- 1216
	end -- 1216
	clone.messages = sanitized -- 1227
	if #messages > shown then -- 1227
		clone.truncatedMessages = #messages - shown -- 1229
	end -- 1229
	return clone -- 1231
end -- 1207
local function sanitizeActionParamsForHistory(tool, params) -- 1234
	if tool ~= "edit_file" then -- 1234
		return params -- 1235
	end -- 1235
	local clone = {} -- 1236
	for key in pairs(params) do -- 1237
		if key == "old_str" then -- 1237
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1239
		elseif key == "new_str" then -- 1239
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1241
		else -- 1241
			clone[key] = params[key] -- 1243
		end -- 1243
	end -- 1243
	return clone -- 1246
end -- 1234
local function isToolAllowedForRole(role, tool) -- 1291
	return __TS__ArrayIndexOf( -- 1292
		getAllowedToolsForRole(role), -- 1292
		tool -- 1292
	) >= 0 -- 1292
end -- 1291
local PRE_EXEC_SAFE_TOOLS = { -- 1295
	"read_file", -- 1296
	"grep_files", -- 1297
	"search_dora_api", -- 1298
	"glob_files", -- 1299
	"list_sub_agents" -- 1300
} -- 1300
local function canPreExecuteTool(tool) -- 1303
	return __TS__ArrayIndexOf(PRE_EXEC_SAFE_TOOLS, tool) >= 0 -- 1304
end -- 1303
local function clearPreExecutedResults(shared) -- 1307
	shared.preExecutedResults = nil -- 1308
end -- 1307
local function startPreExecutedToolAction(shared, action) -- 1311
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1311
		local ____try = __TS__AsyncAwaiter(function() -- 1311
			return ____awaiter_resolve( -- 1311
				nil, -- 1311
				__TS__Await(executeToolAction(shared, action)) -- 1313
			) -- 1313
		end) -- 1313
		__TS__Await(____try.catch( -- 1312
			____try, -- 1312
			function(____, err) -- 1312
				local message = tostring(err) -- 1315
				Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1316
				return ____awaiter_resolve(nil, {success = false, message = message}) -- 1316
			end -- 1316
		)) -- 1316
	end) -- 1316
end -- 1311
local function executeToolActionWithPreExecution(shared, action) -- 1321
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1321
		local ____opt_9 = shared.preExecutedResults -- 1321
		local preResult = ____opt_9 and ____opt_9:get(action.toolCallId) -- 1322
		if preResult then -- 1322
			Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1324
			local ____opt_11 = shared.preExecutedResults -- 1324
			if ____opt_11 ~= nil then -- 1324
				____opt_11:delete(action.toolCallId) -- 1325
			end -- 1325
			return ____awaiter_resolve( -- 1325
				nil, -- 1325
				__TS__Await(preResult) -- 1326
			) -- 1326
		end -- 1326
		return ____awaiter_resolve( -- 1326
			nil, -- 1326
			executeToolAction(shared, action) -- 1328
		) -- 1328
	end) -- 1328
end -- 1321
local function maybeCompressHistory(shared) -- 1331
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1331
		local ____shared_13 = shared -- 1332
		local memory = ____shared_13.memory -- 1332
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1333
		local changed = false -- 1334
		do -- 1334
			local round = 0 -- 1335
			while round < maxRounds do -- 1335
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1336
				local activeMessages = getActiveConversationMessages(shared) -- 1337
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1341
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 1341
					if changed then -- 1341
						persistHistoryState(shared) -- 1350
					end -- 1350
					return ____awaiter_resolve(nil) -- 1350
				end -- 1350
				local compressionRound = round + 1 -- 1354
				shared.step = shared.step + 1 -- 1355
				local stepId = shared.step -- 1356
				local pendingMessages = #activeMessages -- 1357
				emitAgentEvent( -- 1358
					shared, -- 1358
					{ -- 1358
						type = "memory_compression_started", -- 1359
						sessionId = shared.sessionId, -- 1360
						taskId = shared.taskId, -- 1361
						step = stepId, -- 1362
						tool = "compress_memory", -- 1363
						reason = getMemoryCompressionStartReason(shared), -- 1364
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1365
					} -- 1365
				) -- 1365
				local result = __TS__Await(memory.compressor:compress( -- 1371
					activeMessages, -- 1372
					shared.llmOptions, -- 1373
					shared.llmMaxTry, -- 1374
					shared.decisionMode, -- 1375
					{ -- 1376
						onInput = function(____, phase, messages, options) -- 1377
							saveStepLLMDebugInput( -- 1378
								shared, -- 1378
								stepId, -- 1378
								phase, -- 1378
								messages, -- 1378
								options -- 1378
							) -- 1378
						end, -- 1377
						onOutput = function(____, phase, text, meta) -- 1380
							saveStepLLMDebugOutput( -- 1381
								shared, -- 1381
								stepId, -- 1381
								phase, -- 1381
								text, -- 1381
								meta -- 1381
							) -- 1381
						end -- 1380
					}, -- 1380
					"default", -- 1384
					systemPrompt, -- 1385
					toolDefinitions -- 1386
				)) -- 1386
				if not (result and result.success and result.compressedCount > 0) then -- 1386
					emitAgentEvent( -- 1389
						shared, -- 1389
						{ -- 1389
							type = "memory_compression_finished", -- 1390
							sessionId = shared.sessionId, -- 1391
							taskId = shared.taskId, -- 1392
							step = stepId, -- 1393
							tool = "compress_memory", -- 1394
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1395
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1399
						} -- 1399
					) -- 1399
					if changed then -- 1399
						persistHistoryState(shared) -- 1407
					end -- 1407
					return ____awaiter_resolve(nil) -- 1407
				end -- 1407
				local effectiveCompressedCount = math.max( -- 1411
					0, -- 1412
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1413
				) -- 1413
				if effectiveCompressedCount <= 0 then -- 1413
					if changed then -- 1413
						persistHistoryState(shared) -- 1417
					end -- 1417
					return ____awaiter_resolve(nil) -- 1417
				end -- 1417
				emitAgentEvent( -- 1421
					shared, -- 1421
					{ -- 1421
						type = "memory_compression_finished", -- 1422
						sessionId = shared.sessionId, -- 1423
						taskId = shared.taskId, -- 1424
						step = stepId, -- 1425
						tool = "compress_memory", -- 1426
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1427
						result = { -- 1428
							success = true, -- 1429
							round = compressionRound, -- 1430
							compressedCount = effectiveCompressedCount, -- 1431
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1432
						} -- 1432
					} -- 1432
				) -- 1432
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1435
				changed = true -- 1436
				Log( -- 1437
					"Info", -- 1437
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1437
				) -- 1437
				round = round + 1 -- 1335
			end -- 1335
		end -- 1335
		if changed then -- 1335
			persistHistoryState(shared) -- 1440
		end -- 1440
	end) -- 1440
end -- 1331
local function compactAllHistory(shared) -- 1444
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1444
		local ____shared_20 = shared -- 1445
		local memory = ____shared_20.memory -- 1445
		local rounds = 0 -- 1446
		local totalCompressed = 0 -- 1447
		while getActiveRealMessageCount(shared) > 0 do -- 1447
			if shared.stopToken.stopped then -- 1447
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1450
				return ____awaiter_resolve( -- 1450
					nil, -- 1450
					emitAgentTaskFinishEvent( -- 1451
						shared, -- 1451
						false, -- 1451
						getCancelledReason(shared) -- 1451
					) -- 1451
				) -- 1451
			end -- 1451
			rounds = rounds + 1 -- 1453
			shared.step = shared.step + 1 -- 1454
			local stepId = shared.step -- 1455
			local activeMessages = getActiveConversationMessages(shared) -- 1456
			local pendingMessages = #activeMessages -- 1457
			emitAgentEvent( -- 1458
				shared, -- 1458
				{ -- 1458
					type = "memory_compression_started", -- 1459
					sessionId = shared.sessionId, -- 1460
					taskId = shared.taskId, -- 1461
					step = stepId, -- 1462
					tool = "compress_memory", -- 1463
					reason = getMemoryCompressionStartReason(shared), -- 1464
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1465
				} -- 1465
			) -- 1465
			local result = __TS__Await(memory.compressor:compress( -- 1472
				activeMessages, -- 1473
				shared.llmOptions, -- 1474
				shared.llmMaxTry, -- 1475
				shared.decisionMode, -- 1476
				{ -- 1477
					onInput = function(____, phase, messages, options) -- 1478
						saveStepLLMDebugInput( -- 1479
							shared, -- 1479
							stepId, -- 1479
							phase, -- 1479
							messages, -- 1479
							options -- 1479
						) -- 1479
					end, -- 1478
					onOutput = function(____, phase, text, meta) -- 1481
						saveStepLLMDebugOutput( -- 1482
							shared, -- 1482
							stepId, -- 1482
							phase, -- 1482
							text, -- 1482
							meta -- 1482
						) -- 1482
					end -- 1481
				}, -- 1481
				"budget_max" -- 1485
			)) -- 1485
			if not (result and result.success and result.compressedCount > 0) then -- 1485
				emitAgentEvent( -- 1488
					shared, -- 1488
					{ -- 1488
						type = "memory_compression_finished", -- 1489
						sessionId = shared.sessionId, -- 1490
						taskId = shared.taskId, -- 1491
						step = stepId, -- 1492
						tool = "compress_memory", -- 1493
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1494
						result = { -- 1498
							success = false, -- 1499
							rounds = rounds, -- 1500
							error = result and result.error or "compression returned no changes", -- 1501
							compressedCount = result and result.compressedCount or 0, -- 1502
							fullCompaction = true -- 1503
						} -- 1503
					} -- 1503
				) -- 1503
				return ____awaiter_resolve( -- 1503
					nil, -- 1503
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1506
				) -- 1506
			end -- 1506
			local effectiveCompressedCount = math.max( -- 1511
				0, -- 1512
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1513
			) -- 1513
			if effectiveCompressedCount <= 0 then -- 1513
				return ____awaiter_resolve( -- 1513
					nil, -- 1513
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1516
				) -- 1516
			end -- 1516
			emitAgentEvent( -- 1523
				shared, -- 1523
				{ -- 1523
					type = "memory_compression_finished", -- 1524
					sessionId = shared.sessionId, -- 1525
					taskId = shared.taskId, -- 1526
					step = stepId, -- 1527
					tool = "compress_memory", -- 1528
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1529
					result = { -- 1530
						success = true, -- 1531
						round = rounds, -- 1532
						compressedCount = effectiveCompressedCount, -- 1533
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1534
						fullCompaction = true -- 1535
					} -- 1535
				} -- 1535
			) -- 1535
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1538
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1539
			persistHistoryState(shared) -- 1540
			Log( -- 1541
				"Info", -- 1541
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1541
			) -- 1541
		end -- 1541
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1543
		return ____awaiter_resolve( -- 1543
			nil, -- 1543
			emitAgentTaskFinishEvent( -- 1544
				shared, -- 1545
				true, -- 1546
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1547
			) -- 1547
		) -- 1547
	end) -- 1547
end -- 1444
local function clearSessionHistory(shared) -- 1553
	shared.messages = {} -- 1554
	shared.lastConsolidatedIndex = 0 -- 1555
	shared.carryMessageIndex = nil -- 1556
	persistHistoryState(shared) -- 1557
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1558
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1559
end -- 1553
local function isKnownToolName(name) -- 1568
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1569
end -- 1568
local function appendConversationMessage(shared, message) -- 1662
	local ____shared_messages_29 = shared.messages -- 1662
	____shared_messages_29[#____shared_messages_29 + 1] = __TS__ObjectAssign( -- 1663
		{}, -- 1663
		message, -- 1664
		{ -- 1663
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1665
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1666
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1667
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1668
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1669
		} -- 1669
	) -- 1669
end -- 1662
local function ensureToolCallId(toolCallId) -- 1673
	if toolCallId and toolCallId ~= "" then -- 1673
		return toolCallId -- 1674
	end -- 1674
	return createLocalToolCallId() -- 1675
end -- 1673
local function appendToolResultMessage(shared, action) -- 1678
	appendConversationMessage( -- 1679
		shared, -- 1679
		{ -- 1679
			role = "tool", -- 1680
			tool_call_id = action.toolCallId, -- 1681
			name = action.tool, -- 1682
			content = action.result and toJson(action.result) or "" -- 1683
		} -- 1683
	) -- 1683
end -- 1678
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1687
	appendConversationMessage( -- 1693
		shared, -- 1693
		{ -- 1693
			role = "assistant", -- 1694
			content = content or "", -- 1695
			reasoning_content = reasoningContent, -- 1696
			tool_calls = __TS__ArrayMap( -- 1697
				actions, -- 1697
				function(____, action) return { -- 1697
					id = action.toolCallId, -- 1698
					type = "function", -- 1699
					["function"] = { -- 1700
						name = action.tool, -- 1701
						arguments = toJson(action.params) -- 1702
					} -- 1702
				} end -- 1702
			) -- 1702
		} -- 1702
	) -- 1702
end -- 1687
local function parseXMLToolCallObjectFromText(text) -- 1708
	local children = parseXMLObjectFromText(text, "tool_call") -- 1709
	if not children.success then -- 1709
		return children -- 1710
	end -- 1710
	local rawObj = children.obj -- 1711
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1712
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1713
	if not params.success then -- 1713
		return {success = false, message = params.message} -- 1717
	end -- 1717
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1719
end -- 1708
local function llm(shared, messages, phase) -- 1739
	if phase == nil then -- 1739
		phase = "decision_xml" -- 1742
	end -- 1742
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1742
		local stepId = shared.step + 1 -- 1744
		emitLLMContextMetrics( -- 1745
			shared, -- 1745
			stepId, -- 1745
			phase, -- 1745
			messages, -- 1745
			shared.llmOptions -- 1745
		) -- 1745
		saveStepLLMDebugInput( -- 1746
			shared, -- 1746
			stepId, -- 1746
			phase, -- 1746
			messages, -- 1746
			shared.llmOptions -- 1746
		) -- 1746
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1747
		if res.success then -- 1747
			local ____opt_32 = res.response.choices -- 1747
			local ____opt_30 = ____opt_32 and ____opt_32[1] -- 1747
			local message = ____opt_30 and ____opt_30.message -- 1749
			local text = message and message.content -- 1750
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1751
			if text then -- 1751
				saveStepLLMDebugOutput( -- 1755
					shared, -- 1755
					stepId, -- 1755
					phase, -- 1755
					text, -- 1755
					{success = true} -- 1755
				) -- 1755
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1755
			else -- 1755
				saveStepLLMDebugOutput( -- 1758
					shared, -- 1758
					stepId, -- 1758
					phase, -- 1758
					"empty LLM response", -- 1758
					{success = false} -- 1758
				) -- 1758
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1758
			end -- 1758
		else -- 1758
			saveStepLLMDebugOutput( -- 1762
				shared, -- 1762
				stepId, -- 1762
				phase, -- 1762
				res.raw or res.message, -- 1762
				{success = false} -- 1762
			) -- 1762
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1762
		end -- 1762
	end) -- 1762
end -- 1739
local function isDecisionBatchSuccess(result) -- 1786
	return result.kind == "batch" -- 1787
end -- 1786
local function parseDecisionObject(rawObj) -- 1790
	if type(rawObj.tool) ~= "string" then -- 1790
		return {success = false, message = "missing tool"} -- 1791
	end -- 1791
	local tool = rawObj.tool -- 1792
	if not isKnownToolName(tool) then -- 1792
		return {success = false, message = "unknown tool: " .. tool} -- 1794
	end -- 1794
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1796
	if tool ~= "finish" and (not reason or reason == "") then -- 1796
		return {success = false, message = tool .. " requires top-level reason"} -- 1800
	end -- 1800
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1802
	return {success = true, tool = tool, params = params, reason = reason} -- 1803
end -- 1790
local function parseDecisionToolCall(functionName, rawObj) -- 1811
	if not isKnownToolName(functionName) then -- 1811
		return {success = false, message = "unknown tool: " .. functionName} -- 1813
	end -- 1813
	if rawObj == nil or rawObj == nil then -- 1813
		return {success = true, tool = functionName, params = {}} -- 1816
	end -- 1816
	if not isRecord(rawObj) then -- 1816
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1819
	end -- 1819
	return {success = true, tool = functionName, params = rawObj} -- 1821
end -- 1811
local function parseToolCallArguments(functionName, argsText) -- 1828
	local trimmedArgs = __TS__StringTrim(argsText) -- 1829
	if trimmedArgs == "" then -- 1829
		return {} -- 1831
	end -- 1831
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 1833
	if err ~= nil or rawObj == nil then -- 1833
		return { -- 1835
			success = false, -- 1836
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1837
			raw = argsText -- 1838
		} -- 1838
	end -- 1838
	local encodedRaw = safeJsonEncode(rawObj) -- 1841
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 1841
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1843
	end -- 1843
	return rawObj -- 1849
end -- 1828
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1852
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1860
	if isRecord(rawArgs) and rawArgs.success == false then -- 1860
		return rawArgs -- 1862
	end -- 1862
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1864
	if not decision.success then -- 1864
		return {success = false, message = decision.message, raw = argsText} -- 1866
	end -- 1866
	local validation = validateDecision(decision.tool, decision.params) -- 1872
	if not validation.success then -- 1872
		return {success = false, message = validation.message, raw = argsText} -- 1874
	end -- 1874
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1874
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1881
	end -- 1881
	decision.params = validation.params -- 1887
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1888
	decision.reason = reason -- 1889
	decision.reasoningContent = reasoningContent -- 1890
	return decision -- 1891
end -- 1852
local function createPreExecutableActionFromStream(shared, toolCall) -- 1894
	local ____opt_38 = toolCall["function"] -- 1894
	local functionName = ____opt_38 and ____opt_38.name -- 1895
	local ____opt_40 = toolCall["function"] -- 1895
	local argsText = ____opt_40 and ____opt_40.arguments or "" -- 1896
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 1897
	if not functionName or not toolCallId then -- 1897
		return nil -- 1898
	end -- 1898
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1899
	if isRecord(rawArgs) and rawArgs.success == false then -- 1899
		return nil -- 1900
	end -- 1900
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1901
	if not decision.success or not canPreExecuteTool(decision.tool) then -- 1901
		return nil -- 1902
	end -- 1902
	local validation = validateDecision(decision.tool, decision.params) -- 1903
	if not validation.success then -- 1903
		return nil -- 1904
	end -- 1904
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1904
		return nil -- 1905
	end -- 1905
	return { -- 1906
		step = shared.step + 1, -- 1907
		toolCallId = toolCallId, -- 1908
		tool = decision.tool, -- 1909
		reason = "", -- 1910
		params = validation.params, -- 1911
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1912
	} -- 1912
end -- 1894
local function createFunctionToolSchema(name, description, properties, required) -- 2052
	if required == nil then -- 2052
		required = {} -- 2056
	end -- 2056
	local parameters = {type = "object", properties = properties} -- 2058
	if #required > 0 then -- 2058
		parameters.required = required -- 2063
	end -- 2063
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 2065
end -- 2052
local function buildDecisionToolSchema(shared) -- 2081
	local allowed = getAllowedToolsForRole(shared.role) -- 2082
	local tools = { -- 2083
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 2084
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 2094
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 2104
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 2112
			path = {type = "string", description = "Base directory or file path to search within."}, -- 2116
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 2117
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 2118
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 2119
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 2120
			limit = {type = "number", description = "Maximum number of results to return."}, -- 2121
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 2122
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 2123
		}, {"pattern"}), -- 2123
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 2127
		createFunctionToolSchema( -- 2136
			"search_dora_api", -- 2137
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 2137
			{ -- 2139
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 2140
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 2141
				programmingLanguage = {type = "string", enum = { -- 2142
					"ts", -- 2144
					"tsx", -- 2144
					"lua", -- 2144
					"yue", -- 2144
					"teal", -- 2144
					"tl", -- 2144
					"wa" -- 2144
				}, description = "Preferred language variant to search."}, -- 2144
				limit = { -- 2147
					type = "number", -- 2147
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 2147
				}, -- 2147
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 2148
			}, -- 2148
			{"pattern"} -- 2150
		), -- 2150
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 2152
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 2159
			"active_or_recent", -- 2163
			"running", -- 2163
			"done", -- 2163
			"failed", -- 2163
			"all" -- 2163
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 2163
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 2169
	} -- 2169
	return __TS__ArrayFilter( -- 2181
		tools, -- 2181
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 2181
	) -- 2181
end -- 2081
local function sanitizeMessagesForLLMInput(messages) -- 2222
	local sanitized = {} -- 2223
	local droppedAssistantToolCalls = 0 -- 2224
	local droppedToolResults = 0 -- 2225
	do -- 2225
		local i = 0 -- 2226
		while i < #messages do -- 2226
			do -- 2226
				local message = messages[i + 1] -- 2227
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2227
					local requiredIds = {} -- 2229
					do -- 2229
						local j = 0 -- 2230
						while j < #message.tool_calls do -- 2230
							local toolCall = message.tool_calls[j + 1] -- 2231
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2232
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2232
								requiredIds[#requiredIds + 1] = id -- 2234
							end -- 2234
							j = j + 1 -- 2230
						end -- 2230
					end -- 2230
					if #requiredIds == 0 then -- 2230
						sanitized[#sanitized + 1] = message -- 2238
						goto __continue339 -- 2239
					end -- 2239
					local matchedIds = {} -- 2241
					local matchedTools = {} -- 2242
					local j = i + 1 -- 2243
					while j < #messages do -- 2243
						local toolMessage = messages[j + 1] -- 2245
						if toolMessage.role ~= "tool" then -- 2245
							break -- 2246
						end -- 2246
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2247
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2247
							matchedIds[toolCallId] = true -- 2249
							matchedTools[#matchedTools + 1] = toolMessage -- 2250
						else -- 2250
							droppedToolResults = droppedToolResults + 1 -- 2252
						end -- 2252
						j = j + 1 -- 2254
					end -- 2254
					local complete = true -- 2256
					do -- 2256
						local j = 0 -- 2257
						while j < #requiredIds do -- 2257
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2257
								complete = false -- 2259
								break -- 2260
							end -- 2260
							j = j + 1 -- 2257
						end -- 2257
					end -- 2257
					if complete then -- 2257
						__TS__ArrayPush( -- 2264
							sanitized, -- 2264
							message, -- 2264
							table.unpack(matchedTools) -- 2264
						) -- 2264
					else -- 2264
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2266
						droppedToolResults = droppedToolResults + #matchedTools -- 2267
					end -- 2267
					i = j - 1 -- 2269
					goto __continue339 -- 2270
				end -- 2270
				if message.role == "tool" then -- 2270
					droppedToolResults = droppedToolResults + 1 -- 2273
					goto __continue339 -- 2274
				end -- 2274
				sanitized[#sanitized + 1] = message -- 2276
			end -- 2276
			::__continue339:: -- 2276
			i = i + 1 -- 2226
		end -- 2226
	end -- 2226
	return sanitized -- 2278
end -- 2222
local function getUnconsolidatedMessages(shared) -- 2281
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2282
end -- 2281
local function getFinalDecisionTurnPrompt(shared) -- 2285
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2286
end -- 2285
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2291
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2291
		return messages -- 2292
	end -- 2292
	local next = __TS__ArrayMap( -- 2293
		messages, -- 2293
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2293
	) -- 2293
	do -- 2293
		local i = #next - 1 -- 2294
		while i >= 0 do -- 2294
			do -- 2294
				local message = next[i + 1] -- 2295
				if message.role ~= "assistant" and message.role ~= "user" then -- 2295
					goto __continue361 -- 2296
				end -- 2296
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2297
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2298
				return next -- 2301
			end -- 2301
			::__continue361:: -- 2301
			i = i - 1 -- 2294
		end -- 2294
	end -- 2294
	next[#next + 1] = {role = "user", content = prompt} -- 2303
	return next -- 2304
end -- 2291
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2307
	if attempt == nil then -- 2307
		attempt = 1 -- 2310
	end -- 2310
	if decisionMode == nil then -- 2310
		decisionMode = shared.decisionMode -- 2312
	end -- 2312
	local messages = { -- 2314
		{ -- 2315
			role = "system", -- 2315
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2315
		}, -- 2315
		table.unpack(getUnconsolidatedMessages(shared)) -- 2316
	} -- 2316
	if shared.step + 1 >= shared.maxSteps then -- 2316
		messages = appendPromptToLatestDecisionMessage( -- 2319
			messages, -- 2319
			getFinalDecisionTurnPrompt(shared) -- 2319
		) -- 2319
	end -- 2319
	if lastError and lastError ~= "" then -- 2319
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2322
		messages[#messages + 1] = { -- 2325
			role = "user", -- 2326
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2327
		} -- 2327
	end -- 2327
	return messages -- 2334
end -- 2307
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2341
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2348
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2349
	local repairPrompt = replacePromptVars( -- 2357
		shared.promptPack.xmlDecisionRepairPrompt, -- 2357
		{ -- 2357
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2358
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2359
			CANDIDATE_SECTION = candidateSection, -- 2360
			LAST_ERROR = lastError, -- 2361
			ATTEMPT = tostring(attempt) -- 2362
		} -- 2362
	) -- 2362
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2364
end -- 2341
local function tryParseAndValidateDecision(rawText) -- 2376
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2377
	if not parsed.success then -- 2377
		return {success = false, message = parsed.message, raw = rawText} -- 2379
	end -- 2379
	local decision = parseDecisionObject(parsed.obj) -- 2381
	if not decision.success then -- 2381
		return {success = false, message = decision.message, raw = rawText} -- 2383
	end -- 2383
	local validation = validateDecision(decision.tool, decision.params) -- 2385
	if not validation.success then -- 2385
		return {success = false, message = validation.message, raw = rawText} -- 2387
	end -- 2387
	decision.params = validation.params -- 2389
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2390
	return decision -- 2391
end -- 2376
local function normalizeLineEndings(text) -- 2394
	local res = string.gsub(text, "\r\n", "\n") -- 2395
	res = string.gsub(res, "\r", "\n") -- 2396
	return res -- 2397
end -- 2394
local function countOccurrences(text, searchStr) -- 2400
	if searchStr == "" then -- 2400
		return 0 -- 2401
	end -- 2401
	local count = 0 -- 2402
	local pos = 0 -- 2403
	while true do -- 2403
		local idx = (string.find( -- 2405
			text, -- 2405
			searchStr, -- 2405
			math.max(pos + 1, 1), -- 2405
			true -- 2405
		) or 0) - 1 -- 2405
		if idx < 0 then -- 2405
			break -- 2406
		end -- 2406
		count = count + 1 -- 2407
		pos = idx + #searchStr -- 2408
	end -- 2408
	return count -- 2410
end -- 2400
local function replaceFirst(text, oldStr, newStr) -- 2413
	if oldStr == "" then -- 2413
		return text -- 2414
	end -- 2414
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2415
	if idx < 0 then -- 2415
		return text -- 2416
	end -- 2416
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2417
end -- 2413
local function splitLines(text) -- 2420
	return __TS__StringSplit(text, "\n") -- 2421
end -- 2420
local function getLeadingWhitespace(text) -- 2424
	local i = 0 -- 2425
	while i < #text do -- 2425
		local ch = __TS__StringAccess(text, i) -- 2427
		if ch ~= " " and ch ~= "\t" then -- 2427
			break -- 2428
		end -- 2428
		i = i + 1 -- 2429
	end -- 2429
	return __TS__StringSubstring(text, 0, i) -- 2431
end -- 2424
local function getCommonIndentPrefix(lines) -- 2434
	local common -- 2435
	do -- 2435
		local i = 0 -- 2436
		while i < #lines do -- 2436
			do -- 2436
				local line = lines[i + 1] -- 2437
				if __TS__StringTrim(line) == "" then -- 2437
					goto __continue386 -- 2438
				end -- 2438
				local indent = getLeadingWhitespace(line) -- 2439
				if common == nil then -- 2439
					common = indent -- 2441
					goto __continue386 -- 2442
				end -- 2442
				local j = 0 -- 2444
				local maxLen = math.min(#common, #indent) -- 2445
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2445
					j = j + 1 -- 2447
				end -- 2447
				common = __TS__StringSubstring(common, 0, j) -- 2449
				if common == "" then -- 2449
					break -- 2450
				end -- 2450
			end -- 2450
			::__continue386:: -- 2450
			i = i + 1 -- 2436
		end -- 2436
	end -- 2436
	return common or "" -- 2452
end -- 2434
local function removeIndentPrefix(line, indent) -- 2455
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2455
		return __TS__StringSubstring(line, #indent) -- 2457
	end -- 2457
	local lineIndent = getLeadingWhitespace(line) -- 2459
	local j = 0 -- 2460
	local maxLen = math.min(#lineIndent, #indent) -- 2461
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2461
		j = j + 1 -- 2463
	end -- 2463
	return __TS__StringSubstring(line, j) -- 2465
end -- 2455
local function dedentLines(lines) -- 2468
	local indent = getCommonIndentPrefix(lines) -- 2469
	return { -- 2470
		indent = indent, -- 2471
		lines = __TS__ArrayMap( -- 2472
			lines, -- 2472
			function(____, line) return removeIndentPrefix(line, indent) end -- 2472
		) -- 2472
	} -- 2472
end -- 2468
local function joinLines(lines) -- 2476
	return table.concat(lines, "\n") -- 2477
end -- 2476
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2480
	local contentLines = splitLines(content) -- 2485
	local oldLines = splitLines(oldStr) -- 2486
	if #oldLines == 0 then -- 2486
		return {success = false, message = "old_str not found in file"} -- 2488
	end -- 2488
	local dedentedOld = dedentLines(oldLines) -- 2490
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2491
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2492
	local matches = {} -- 2493
	do -- 2493
		local start = 0 -- 2494
		while start <= #contentLines - #oldLines do -- 2494
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2495
			local dedentedCandidate = dedentLines(candidateLines) -- 2496
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2496
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2498
			end -- 2498
			start = start + 1 -- 2494
		end -- 2494
	end -- 2494
	if #matches == 0 then -- 2494
		return {success = false, message = "old_str not found in file"} -- 2506
	end -- 2506
	if #matches > 1 then -- 2506
		return { -- 2509
			success = false, -- 2510
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2511
		} -- 2511
	end -- 2511
	local match = matches[1] -- 2514
	local rebuiltNewLines = __TS__ArrayMap( -- 2515
		dedentedNew.lines, -- 2515
		function(____, line) return line == "" and "" or match.indent .. line end -- 2515
	) -- 2515
	local ____array_46 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2515
	__TS__SparseArrayPush( -- 2515
		____array_46, -- 2515
		table.unpack(rebuiltNewLines) -- 2518
	) -- 2518
	__TS__SparseArrayPush( -- 2518
		____array_46, -- 2518
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2519
	) -- 2519
	local nextLines = {__TS__SparseArraySpread(____array_46)} -- 2516
	return { -- 2521
		success = true, -- 2521
		content = joinLines(nextLines) -- 2521
	} -- 2521
end -- 2480
local MainDecisionAgent = __TS__Class() -- 2524
MainDecisionAgent.name = "MainDecisionAgent" -- 2524
__TS__ClassExtends(MainDecisionAgent, Node) -- 2524
function MainDecisionAgent.prototype.prep(self, shared) -- 2525
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2525
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2525
			return ____awaiter_resolve(nil, {shared = shared}) -- 2525
		end -- 2525
		__TS__Await(maybeCompressHistory(shared)) -- 2530
		return ____awaiter_resolve(nil, {shared = shared}) -- 2530
	end) -- 2530
end -- 2525
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2535
	if attempt == nil then -- 2535
		attempt = 1 -- 2538
	end -- 2538
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2538
		if shared.stopToken.stopped then -- 2538
			return ____awaiter_resolve( -- 2538
				nil, -- 2538
				{ -- 2542
					success = false, -- 2542
					message = getCancelledReason(shared) -- 2542
				} -- 2542
			) -- 2542
		end -- 2542
		Log( -- 2544
			"Info", -- 2544
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2544
		) -- 2544
		local tools = buildDecisionToolSchema(shared) -- 2545
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2546
		local stepId = shared.step + 1 -- 2547
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2548
		emitLLMContextMetrics( -- 2552
			shared, -- 2552
			stepId, -- 2552
			"decision_tool_calling", -- 2552
			messages, -- 2552
			llmOptions -- 2552
		) -- 2552
		saveStepLLMDebugInput( -- 2553
			shared, -- 2553
			stepId, -- 2553
			"decision_tool_calling", -- 2553
			messages, -- 2553
			llmOptions -- 2553
		) -- 2553
		local lastStreamContent = "" -- 2554
		local lastStreamReasoning = "" -- 2555
		local preExecutedResults = __TS__New(Map) -- 2556
		shared.preExecutedResults = preExecutedResults -- 2557
		local res = __TS__Await(callLLMStreamAggregated( -- 2558
			messages, -- 2559
			llmOptions, -- 2560
			shared.stopToken, -- 2561
			shared.llmConfig, -- 2562
			function(response) -- 2563
				local ____opt_49 = response.choices -- 2563
				local ____opt_47 = ____opt_49 and ____opt_49[1] -- 2563
				local streamMessage = ____opt_47 and ____opt_47.message -- 2564
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2565
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2568
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2568
					return -- 2572
				end -- 2572
				lastStreamContent = nextContent -- 2574
				lastStreamReasoning = nextReasoning -- 2575
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2576
			end, -- 2563
			function(tc) -- 2578
				if shared.stopToken.stopped then -- 2578
					return -- 2579
				end -- 2579
				local action = createPreExecutableActionFromStream(shared, tc) -- 2580
				if not action or preExecutedResults:has(action.toolCallId) then -- 2580
					return -- 2581
				end -- 2581
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2582
				preExecutedResults:set( -- 2583
					action.toolCallId, -- 2583
					startPreExecutedToolAction(shared, action) -- 2583
				) -- 2583
			end -- 2578
		)) -- 2578
		if shared.stopToken.stopped then -- 2578
			clearPreExecutedResults(shared) -- 2587
			return ____awaiter_resolve( -- 2587
				nil, -- 2587
				{ -- 2588
					success = false, -- 2588
					message = getCancelledReason(shared) -- 2588
				} -- 2588
			) -- 2588
		end -- 2588
		if not res.success then -- 2588
			saveStepLLMDebugOutput( -- 2591
				shared, -- 2591
				stepId, -- 2591
				"decision_tool_calling", -- 2591
				res.raw or res.message, -- 2591
				{success = false} -- 2591
			) -- 2591
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2592
			clearPreExecutedResults(shared) -- 2593
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2593
		end -- 2593
		saveStepLLMDebugOutput( -- 2596
			shared, -- 2596
			stepId, -- 2596
			"decision_tool_calling", -- 2596
			encodeDebugJSON(res.response), -- 2596
			{success = true} -- 2596
		) -- 2596
		local choice = res.response.choices and res.response.choices[1] -- 2597
		local message = choice and choice.message -- 2598
		local toolCalls = message and message.tool_calls -- 2599
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2600
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2603
		Log( -- 2606
			"Info", -- 2606
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2606
		) -- 2606
		if not toolCalls or #toolCalls == 0 then -- 2606
			if messageContent and messageContent ~= "" then -- 2606
				Log( -- 2609
					"Info", -- 2609
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2609
				) -- 2609
				clearPreExecutedResults(shared) -- 2610
				return ____awaiter_resolve(nil, { -- 2610
					success = true, -- 2612
					tool = "finish", -- 2613
					params = {}, -- 2614
					reason = messageContent, -- 2615
					reasoningContent = reasoningContent, -- 2616
					directSummary = messageContent -- 2617
				}) -- 2617
			end -- 2617
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2620
			clearPreExecutedResults(shared) -- 2621
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2621
		end -- 2621
		local decisions = {} -- 2628
		do -- 2628
			local i = 0 -- 2629
			while i < #toolCalls do -- 2629
				local toolCall = toolCalls[i + 1] -- 2630
				local fn = toolCall and toolCall["function"] -- 2631
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2631
					Log( -- 2633
						"Error", -- 2633
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2633
					) -- 2633
					clearPreExecutedResults(shared) -- 2634
					return ____awaiter_resolve( -- 2634
						nil, -- 2634
						{ -- 2635
							success = false, -- 2636
							message = "missing function name for tool call " .. tostring(i + 1), -- 2637
							raw = messageContent -- 2638
						} -- 2638
					) -- 2638
				end -- 2638
				local functionName = fn.name -- 2641
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2642
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2643
				Log( -- 2646
					"Info", -- 2646
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2646
				) -- 2646
				local decision = parseAndValidateToolCallDecision( -- 2647
					shared, -- 2648
					functionName, -- 2649
					argsText, -- 2650
					toolCallId, -- 2651
					messageContent, -- 2652
					reasoningContent -- 2653
				) -- 2653
				if not decision.success then -- 2653
					Log( -- 2656
						"Error", -- 2656
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2656
					) -- 2656
					clearPreExecutedResults(shared) -- 2657
					return ____awaiter_resolve(nil, decision) -- 2657
				end -- 2657
				decisions[#decisions + 1] = decision -- 2660
				i = i + 1 -- 2629
			end -- 2629
		end -- 2629
		if #decisions == 1 then -- 2629
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2663
			return ____awaiter_resolve(nil, decisions[1]) -- 2663
		end -- 2663
		do -- 2663
			local i = 0 -- 2666
			while i < #decisions do -- 2666
				if decisions[i + 1].tool == "finish" then -- 2666
					clearPreExecutedResults(shared) -- 2668
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2668
				end -- 2668
				i = i + 1 -- 2666
			end -- 2666
		end -- 2666
		Log( -- 2676
			"Info", -- 2676
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2676
				__TS__ArrayMap( -- 2676
					decisions, -- 2676
					function(____, decision) return decision.tool end -- 2676
				), -- 2676
				"," -- 2676
			) -- 2676
		) -- 2676
		return ____awaiter_resolve(nil, { -- 2676
			success = true, -- 2678
			kind = "batch", -- 2679
			decisions = decisions, -- 2680
			content = messageContent, -- 2681
			reasoningContent = reasoningContent -- 2682
		}) -- 2682
	end) -- 2682
end -- 2535
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2686
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2686
		Log( -- 2691
			"Info", -- 2691
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2691
		) -- 2691
		local lastError = initialError -- 2692
		local candidateRaw = "" -- 2693
		do -- 2693
			local attempt = 0 -- 2694
			while attempt < shared.llmMaxTry do -- 2694
				do -- 2694
					Log( -- 2695
						"Info", -- 2695
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2695
					) -- 2695
					local messages = buildXmlRepairMessages( -- 2696
						shared, -- 2697
						originalRaw, -- 2698
						candidateRaw, -- 2699
						lastError, -- 2700
						attempt + 1 -- 2701
					) -- 2701
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2703
					if shared.stopToken.stopped then -- 2703
						return ____awaiter_resolve( -- 2703
							nil, -- 2703
							{ -- 2705
								success = false, -- 2705
								message = getCancelledReason(shared) -- 2705
							} -- 2705
						) -- 2705
					end -- 2705
					if not llmRes.success then -- 2705
						lastError = llmRes.message -- 2708
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2709
						goto __continue429 -- 2710
					end -- 2710
					candidateRaw = llmRes.text -- 2712
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2713
					if decision.success then -- 2713
						decision.reasoningContent = llmRes.reasoningContent -- 2715
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2716
						return ____awaiter_resolve(nil, decision) -- 2716
					end -- 2716
					lastError = decision.message -- 2719
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2720
				end -- 2720
				::__continue429:: -- 2720
				attempt = attempt + 1 -- 2694
			end -- 2694
		end -- 2694
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2722
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2722
	end) -- 2722
end -- 2686
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2730
	if attempt == nil then -- 2730
		attempt = 1 -- 2733
	end -- 2733
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2733
		local messages = buildDecisionMessages( -- 2736
			shared, -- 2737
			lastError, -- 2738
			attempt, -- 2739
			lastRaw, -- 2740
			"xml" -- 2741
		) -- 2741
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2743
		if shared.stopToken.stopped then -- 2743
			return ____awaiter_resolve( -- 2743
				nil, -- 2743
				{ -- 2745
					success = false, -- 2745
					message = getCancelledReason(shared) -- 2745
				} -- 2745
			) -- 2745
		end -- 2745
		if not llmRes.success then -- 2745
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2745
		end -- 2745
		local decision = tryParseAndValidateDecision(llmRes.text) -- 2754
		if decision.success then -- 2754
			decision.reasoningContent = llmRes.reasoningContent -- 2756
			if not isToolAllowedForRole(shared.role, decision.tool) then -- 2756
				return ____awaiter_resolve( -- 2756
					nil, -- 2756
					self:repairDecisionXml(shared, llmRes.text, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2758
				) -- 2758
			end -- 2758
			return ____awaiter_resolve(nil, decision) -- 2758
		end -- 2758
		return ____awaiter_resolve( -- 2758
			nil, -- 2758
			self:repairDecisionXml(shared, llmRes.text, decision.message) -- 2766
		) -- 2766
	end) -- 2766
end -- 2730
function MainDecisionAgent.prototype.exec(self, input) -- 2769
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2769
		local shared = input.shared -- 2770
		if shared.stopToken.stopped then -- 2770
			return ____awaiter_resolve( -- 2770
				nil, -- 2770
				{ -- 2772
					success = false, -- 2772
					message = getCancelledReason(shared) -- 2772
				} -- 2772
			) -- 2772
		end -- 2772
		if shared.step >= shared.maxSteps then -- 2772
			Log( -- 2775
				"Warn", -- 2775
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2775
			) -- 2775
			return ____awaiter_resolve( -- 2775
				nil, -- 2775
				{ -- 2776
					success = false, -- 2776
					message = getMaxStepsReachedReason(shared) -- 2776
				} -- 2776
			) -- 2776
		end -- 2776
		if shared.decisionMode == "tool_calling" then -- 2776
			Log( -- 2780
				"Info", -- 2780
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2780
			) -- 2780
			local lastError = "tool calling validation failed" -- 2781
			local lastRaw = "" -- 2782
			local shouldFallbackToXml = false -- 2783
			do -- 2783
				local attempt = 0 -- 2784
				while attempt < shared.llmMaxTry do -- 2784
					Log( -- 2785
						"Info", -- 2785
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2785
					) -- 2785
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2786
					if shared.stopToken.stopped then -- 2786
						return ____awaiter_resolve( -- 2786
							nil, -- 2786
							{ -- 2793
								success = false, -- 2793
								message = getCancelledReason(shared) -- 2793
							} -- 2793
						) -- 2793
					end -- 2793
					if decision.success then -- 2793
						return ____awaiter_resolve(nil, decision) -- 2793
					end -- 2793
					lastError = decision.message -- 2798
					lastRaw = decision.raw or "" -- 2799
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2800
					if lastError == "missing tool call" then -- 2800
						shouldFallbackToXml = true -- 2802
						break -- 2803
					end -- 2803
					attempt = attempt + 1 -- 2784
				end -- 2784
			end -- 2784
			if shouldFallbackToXml then -- 2784
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 2807
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 2808
				do -- 2808
					local attempt = 0 -- 2809
					while attempt < shared.llmMaxTry do -- 2809
						Log( -- 2810
							"Info", -- 2810
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 2810
						) -- 2810
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 2811
						if shared.stopToken.stopped then -- 2811
							return ____awaiter_resolve( -- 2811
								nil, -- 2811
								{ -- 2818
									success = false, -- 2818
									message = getCancelledReason(shared) -- 2818
								} -- 2818
							) -- 2818
						end -- 2818
						if decision.success then -- 2818
							return ____awaiter_resolve(nil, decision) -- 2818
						end -- 2818
						lastError = decision.message -- 2823
						lastRaw = decision.raw or "" -- 2824
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 2825
						attempt = attempt + 1 -- 2809
					end -- 2809
				end -- 2809
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 2827
				return ____awaiter_resolve( -- 2827
					nil, -- 2827
					{ -- 2828
						success = false, -- 2828
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2828
					} -- 2828
				) -- 2828
			end -- 2828
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2830
			return ____awaiter_resolve( -- 2830
				nil, -- 2830
				{ -- 2831
					success = false, -- 2831
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2831
				} -- 2831
			) -- 2831
		end -- 2831
		local lastError = "xml validation failed" -- 2834
		local lastRaw = "" -- 2835
		do -- 2835
			local attempt = 0 -- 2836
			while attempt < shared.llmMaxTry do -- 2836
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 2837
				if shared.stopToken.stopped then -- 2837
					return ____awaiter_resolve( -- 2837
						nil, -- 2837
						{ -- 2846
							success = false, -- 2846
							message = getCancelledReason(shared) -- 2846
						} -- 2846
					) -- 2846
				end -- 2846
				if decision.success then -- 2846
					return ____awaiter_resolve(nil, decision) -- 2846
				end -- 2846
				lastError = decision.message -- 2851
				lastRaw = decision.raw or "" -- 2852
				attempt = attempt + 1 -- 2836
			end -- 2836
		end -- 2836
		return ____awaiter_resolve( -- 2836
			nil, -- 2836
			{ -- 2854
				success = false, -- 2854
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2854
			} -- 2854
		) -- 2854
	end) -- 2854
end -- 2769
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2857
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2857
		local result = execRes -- 2858
		if not result.success then -- 2858
			if shared.stopToken.stopped then -- 2858
				shared.error = getCancelledReason(shared) -- 2861
				shared.done = true -- 2862
				return ____awaiter_resolve(nil, "done") -- 2862
			end -- 2862
			shared.error = result.message -- 2865
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2866
			shared.done = true -- 2867
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2868
			persistHistoryState(shared) -- 2872
			return ____awaiter_resolve(nil, "done") -- 2872
		end -- 2872
		if isDecisionBatchSuccess(result) then -- 2872
			local startStep = shared.step -- 2876
			local actions = {} -- 2877
			do -- 2877
				local i = 0 -- 2878
				while i < #result.decisions do -- 2878
					local decision = result.decisions[i + 1] -- 2879
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2880
					local step = startStep + i + 1 -- 2881
					local ____temp_55 -- 2882
					if i == 0 then -- 2882
						____temp_55 = decision.reason -- 2882
					else -- 2882
						____temp_55 = "" -- 2882
					end -- 2882
					local actionReason = ____temp_55 -- 2882
					local ____temp_56 -- 2883
					if i == 0 then -- 2883
						____temp_56 = decision.reasoningContent -- 2883
					else -- 2883
						____temp_56 = nil -- 2883
					end -- 2883
					local actionReasoningContent = ____temp_56 -- 2883
					emitAgentEvent(shared, { -- 2884
						type = "decision_made", -- 2885
						sessionId = shared.sessionId, -- 2886
						taskId = shared.taskId, -- 2887
						step = step, -- 2888
						tool = decision.tool, -- 2889
						reason = actionReason, -- 2890
						reasoningContent = actionReasoningContent, -- 2891
						params = decision.params -- 2892
					}) -- 2892
					local action = { -- 2894
						step = step, -- 2895
						toolCallId = toolCallId, -- 2896
						tool = decision.tool, -- 2897
						reason = actionReason or "", -- 2898
						reasoningContent = actionReasoningContent, -- 2899
						params = decision.params, -- 2900
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2901
					} -- 2901
					local ____shared_history_57 = shared.history -- 2901
					____shared_history_57[#____shared_history_57 + 1] = action -- 2903
					actions[#actions + 1] = action -- 2904
					i = i + 1 -- 2878
				end -- 2878
			end -- 2878
			shared.step = startStep + #actions -- 2906
			shared.pendingToolActions = actions -- 2907
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2908
			persistHistoryState(shared) -- 2914
			return ____awaiter_resolve(nil, "batch_tools") -- 2914
		end -- 2914
		if result.directSummary and result.directSummary ~= "" then -- 2914
			shared.response = result.directSummary -- 2918
			shared.done = true -- 2919
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2920
			persistHistoryState(shared) -- 2925
			return ____awaiter_resolve(nil, "done") -- 2925
		end -- 2925
		if result.tool == "finish" then -- 2925
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2929
			shared.response = finalMessage -- 2930
			shared.done = true -- 2931
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2932
			persistHistoryState(shared) -- 2937
			return ____awaiter_resolve(nil, "done") -- 2937
		end -- 2937
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2940
		shared.step = shared.step + 1 -- 2941
		local step = shared.step -- 2942
		emitAgentEvent(shared, { -- 2943
			type = "decision_made", -- 2944
			sessionId = shared.sessionId, -- 2945
			taskId = shared.taskId, -- 2946
			step = step, -- 2947
			tool = result.tool, -- 2948
			reason = result.reason, -- 2949
			reasoningContent = result.reasoningContent, -- 2950
			params = result.params -- 2951
		}) -- 2951
		local ____shared_history_58 = shared.history -- 2951
		____shared_history_58[#____shared_history_58 + 1] = { -- 2953
			step = step, -- 2954
			toolCallId = toolCallId, -- 2955
			tool = result.tool, -- 2956
			reason = result.reason or "", -- 2957
			reasoningContent = result.reasoningContent, -- 2958
			params = result.params, -- 2959
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2960
		} -- 2960
		local action = shared.history[#shared.history] -- 2962
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 2963
		if canPreExecuteTool(action.tool) then -- 2963
			shared.pendingToolActions = {action} -- 2965
			persistHistoryState(shared) -- 2966
			return ____awaiter_resolve(nil, "batch_tools") -- 2966
		end -- 2966
		clearPreExecutedResults(shared) -- 2969
		persistHistoryState(shared) -- 2970
		return ____awaiter_resolve(nil, result.tool) -- 2970
	end) -- 2970
end -- 2857
local ReadFileAction = __TS__Class() -- 2975
ReadFileAction.name = "ReadFileAction" -- 2975
__TS__ClassExtends(ReadFileAction, Node) -- 2975
function ReadFileAction.prototype.prep(self, shared) -- 2976
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2976
		local last = shared.history[#shared.history] -- 2977
		if not last then -- 2977
			error( -- 2978
				__TS__New(Error, "no history"), -- 2978
				0 -- 2978
			) -- 2978
		end -- 2978
		emitAgentStartEvent(shared, last) -- 2979
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2980
		if __TS__StringTrim(path) == "" then -- 2980
			error( -- 2983
				__TS__New(Error, "missing path"), -- 2983
				0 -- 2983
			) -- 2983
		end -- 2983
		local ____path_61 = path -- 2985
		local ____shared_workingDir_62 = shared.workingDir -- 2987
		local ____temp_63 = shared.useChineseResponse and "zh" or "en" -- 2988
		local ____last_params_startLine_59 = last.params.startLine -- 2989
		if ____last_params_startLine_59 == nil then -- 2989
			____last_params_startLine_59 = 1 -- 2989
		end -- 2989
		local ____TS__Number_result_64 = __TS__Number(____last_params_startLine_59) -- 2989
		local ____last_params_endLine_60 = last.params.endLine -- 2990
		if ____last_params_endLine_60 == nil then -- 2990
			____last_params_endLine_60 = READ_FILE_DEFAULT_LIMIT -- 2990
		end -- 2990
		return ____awaiter_resolve( -- 2990
			nil, -- 2990
			{ -- 2984
				path = ____path_61, -- 2985
				tool = "read_file", -- 2986
				workDir = ____shared_workingDir_62, -- 2987
				docLanguage = ____temp_63, -- 2988
				startLine = ____TS__Number_result_64, -- 2989
				endLine = __TS__Number(____last_params_endLine_60) -- 2990
			} -- 2990
		) -- 2990
	end) -- 2990
end -- 2976
function ReadFileAction.prototype.exec(self, input) -- 2994
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2994
		return ____awaiter_resolve( -- 2994
			nil, -- 2994
			Tools.readFile( -- 2995
				input.workDir, -- 2996
				input.path, -- 2997
				__TS__Number(input.startLine or 1), -- 2998
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2999
				input.docLanguage -- 3000
			) -- 3000
		) -- 3000
	end) -- 3000
end -- 2994
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3004
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3004
		local result = execRes -- 3005
		local last = shared.history[#shared.history] -- 3006
		if last ~= nil then -- 3006
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3008
			appendToolResultMessage(shared, last) -- 3009
			emitAgentFinishEvent(shared, last) -- 3010
		end -- 3010
		persistHistoryState(shared) -- 3012
		__TS__Await(maybeCompressHistory(shared)) -- 3013
		persistHistoryState(shared) -- 3014
		return ____awaiter_resolve(nil, "main") -- 3014
	end) -- 3014
end -- 3004
local SearchFilesAction = __TS__Class() -- 3019
SearchFilesAction.name = "SearchFilesAction" -- 3019
__TS__ClassExtends(SearchFilesAction, Node) -- 3019
function SearchFilesAction.prototype.prep(self, shared) -- 3020
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3020
		local last = shared.history[#shared.history] -- 3021
		if not last then -- 3021
			error( -- 3022
				__TS__New(Error, "no history"), -- 3022
				0 -- 3022
			) -- 3022
		end -- 3022
		emitAgentStartEvent(shared, last) -- 3023
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3023
	end) -- 3023
end -- 3020
function SearchFilesAction.prototype.exec(self, input) -- 3027
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3027
		local params = input.params -- 3028
		local ____Tools_searchFiles_78 = Tools.searchFiles -- 3029
		local ____input_workDir_71 = input.workDir -- 3030
		local ____temp_72 = params.path or "" -- 3031
		local ____temp_73 = params.pattern or "" -- 3032
		local ____params_globs_74 = params.globs -- 3033
		local ____params_useRegex_75 = params.useRegex -- 3034
		local ____params_caseSensitive_76 = params.caseSensitive -- 3035
		local ____math_max_67 = math.max -- 3038
		local ____math_floor_66 = math.floor -- 3038
		local ____params_limit_65 = params.limit -- 3038
		if ____params_limit_65 == nil then -- 3038
			____params_limit_65 = SEARCH_FILES_LIMIT_DEFAULT -- 3038
		end -- 3038
		local ____math_max_67_result_77 = ____math_max_67( -- 3038
			1, -- 3038
			____math_floor_66(__TS__Number(____params_limit_65)) -- 3038
		) -- 3038
		local ____math_max_70 = math.max -- 3039
		local ____math_floor_69 = math.floor -- 3039
		local ____params_offset_68 = params.offset -- 3039
		if ____params_offset_68 == nil then -- 3039
			____params_offset_68 = 0 -- 3039
		end -- 3039
		local result = __TS__Await(____Tools_searchFiles_78({ -- 3029
			workDir = ____input_workDir_71, -- 3030
			path = ____temp_72, -- 3031
			pattern = ____temp_73, -- 3032
			globs = ____params_globs_74, -- 3033
			useRegex = ____params_useRegex_75, -- 3034
			caseSensitive = ____params_caseSensitive_76, -- 3035
			includeContent = true, -- 3036
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3037
			limit = ____math_max_67_result_77, -- 3038
			offset = ____math_max_70( -- 3039
				0, -- 3039
				____math_floor_69(__TS__Number(____params_offset_68)) -- 3039
			), -- 3039
			groupByFile = params.groupByFile == true -- 3040
		})) -- 3040
		return ____awaiter_resolve(nil, result) -- 3040
	end) -- 3040
end -- 3027
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3045
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3045
		local last = shared.history[#shared.history] -- 3046
		if last ~= nil then -- 3046
			local result = execRes -- 3048
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3049
			appendToolResultMessage(shared, last) -- 3050
			emitAgentFinishEvent(shared, last) -- 3051
		end -- 3051
		persistHistoryState(shared) -- 3053
		__TS__Await(maybeCompressHistory(shared)) -- 3054
		persistHistoryState(shared) -- 3055
		return ____awaiter_resolve(nil, "main") -- 3055
	end) -- 3055
end -- 3045
local SearchDoraAPIAction = __TS__Class() -- 3060
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3060
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3060
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3061
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3061
		local last = shared.history[#shared.history] -- 3062
		if not last then -- 3062
			error( -- 3063
				__TS__New(Error, "no history"), -- 3063
				0 -- 3063
			) -- 3063
		end -- 3063
		emitAgentStartEvent(shared, last) -- 3064
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3064
	end) -- 3064
end -- 3061
function SearchDoraAPIAction.prototype.exec(self, input) -- 3068
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3068
		local params = input.params -- 3069
		local ____Tools_searchDoraAPI_86 = Tools.searchDoraAPI -- 3070
		local ____temp_82 = params.pattern or "" -- 3071
		local ____temp_83 = params.docSource or "api" -- 3072
		local ____temp_84 = input.useChineseResponse and "zh" or "en" -- 3073
		local ____temp_85 = params.programmingLanguage or "ts" -- 3074
		local ____math_min_81 = math.min -- 3075
		local ____math_max_80 = math.max -- 3075
		local ____params_limit_79 = params.limit -- 3075
		if ____params_limit_79 == nil then -- 3075
			____params_limit_79 = 8 -- 3075
		end -- 3075
		local result = __TS__Await(____Tools_searchDoraAPI_86({ -- 3070
			pattern = ____temp_82, -- 3071
			docSource = ____temp_83, -- 3072
			docLanguage = ____temp_84, -- 3073
			programmingLanguage = ____temp_85, -- 3074
			limit = ____math_min_81( -- 3075
				SEARCH_DORA_API_LIMIT_MAX, -- 3075
				____math_max_80( -- 3075
					1, -- 3075
					__TS__Number(____params_limit_79) -- 3075
				) -- 3075
			), -- 3075
			useRegex = params.useRegex, -- 3076
			caseSensitive = false, -- 3077
			includeContent = true, -- 3078
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 3079
		})) -- 3079
		return ____awaiter_resolve(nil, result) -- 3079
	end) -- 3079
end -- 3068
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3084
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3084
		local last = shared.history[#shared.history] -- 3085
		if last ~= nil then -- 3085
			local result = execRes -- 3087
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3088
			appendToolResultMessage(shared, last) -- 3089
			emitAgentFinishEvent(shared, last) -- 3090
		end -- 3090
		persistHistoryState(shared) -- 3092
		__TS__Await(maybeCompressHistory(shared)) -- 3093
		persistHistoryState(shared) -- 3094
		return ____awaiter_resolve(nil, "main") -- 3094
	end) -- 3094
end -- 3084
local ListFilesAction = __TS__Class() -- 3099
ListFilesAction.name = "ListFilesAction" -- 3099
__TS__ClassExtends(ListFilesAction, Node) -- 3099
function ListFilesAction.prototype.prep(self, shared) -- 3100
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3100
		local last = shared.history[#shared.history] -- 3101
		if not last then -- 3101
			error( -- 3102
				__TS__New(Error, "no history"), -- 3102
				0 -- 3102
			) -- 3102
		end -- 3102
		emitAgentStartEvent(shared, last) -- 3103
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3103
	end) -- 3103
end -- 3100
function ListFilesAction.prototype.exec(self, input) -- 3107
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3107
		local params = input.params -- 3108
		local ____Tools_listFiles_93 = Tools.listFiles -- 3109
		local ____input_workDir_90 = input.workDir -- 3110
		local ____temp_91 = params.path or "" -- 3111
		local ____params_globs_92 = params.globs -- 3112
		local ____math_max_89 = math.max -- 3113
		local ____math_floor_88 = math.floor -- 3113
		local ____params_maxEntries_87 = params.maxEntries -- 3113
		if ____params_maxEntries_87 == nil then -- 3113
			____params_maxEntries_87 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3113
		end -- 3113
		local result = ____Tools_listFiles_93({ -- 3109
			workDir = ____input_workDir_90, -- 3110
			path = ____temp_91, -- 3111
			globs = ____params_globs_92, -- 3112
			maxEntries = ____math_max_89( -- 3113
				1, -- 3113
				____math_floor_88(__TS__Number(____params_maxEntries_87)) -- 3113
			) -- 3113
		}) -- 3113
		return ____awaiter_resolve(nil, result) -- 3113
	end) -- 3113
end -- 3107
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3118
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3118
		local last = shared.history[#shared.history] -- 3119
		if last ~= nil then -- 3119
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3121
			appendToolResultMessage(shared, last) -- 3122
			emitAgentFinishEvent(shared, last) -- 3123
		end -- 3123
		persistHistoryState(shared) -- 3125
		__TS__Await(maybeCompressHistory(shared)) -- 3126
		persistHistoryState(shared) -- 3127
		return ____awaiter_resolve(nil, "main") -- 3127
	end) -- 3127
end -- 3118
local DeleteFileAction = __TS__Class() -- 3132
DeleteFileAction.name = "DeleteFileAction" -- 3132
__TS__ClassExtends(DeleteFileAction, Node) -- 3132
function DeleteFileAction.prototype.prep(self, shared) -- 3133
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3133
		local last = shared.history[#shared.history] -- 3134
		if not last then -- 3134
			error( -- 3135
				__TS__New(Error, "no history"), -- 3135
				0 -- 3135
			) -- 3135
		end -- 3135
		emitAgentStartEvent(shared, last) -- 3136
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3137
		if __TS__StringTrim(targetFile) == "" then -- 3137
			error( -- 3140
				__TS__New(Error, "missing target_file"), -- 3140
				0 -- 3140
			) -- 3140
		end -- 3140
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3140
	end) -- 3140
end -- 3133
function DeleteFileAction.prototype.exec(self, input) -- 3144
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3144
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3145
		if not result.success then -- 3145
			return ____awaiter_resolve(nil, result) -- 3145
		end -- 3145
		return ____awaiter_resolve(nil, { -- 3145
			success = true, -- 3153
			changed = true, -- 3154
			mode = "delete", -- 3155
			checkpointId = result.checkpointId, -- 3156
			checkpointSeq = result.checkpointSeq, -- 3157
			files = {{path = input.targetFile, op = "delete"}} -- 3158
		}) -- 3158
	end) -- 3158
end -- 3144
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3162
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3162
		local last = shared.history[#shared.history] -- 3163
		if last ~= nil then -- 3163
			last.result = execRes -- 3165
			appendToolResultMessage(shared, last) -- 3166
			emitAgentFinishEvent(shared, last) -- 3167
			local result = last.result -- 3168
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3168
				emitAgentEvent(shared, { -- 3173
					type = "checkpoint_created", -- 3174
					sessionId = shared.sessionId, -- 3175
					taskId = shared.taskId, -- 3176
					step = last.step, -- 3177
					tool = "delete_file", -- 3178
					checkpointId = result.checkpointId, -- 3179
					checkpointSeq = result.checkpointSeq, -- 3180
					files = result.files -- 3181
				}) -- 3181
			end -- 3181
		end -- 3181
		persistHistoryState(shared) -- 3185
		__TS__Await(maybeCompressHistory(shared)) -- 3186
		persistHistoryState(shared) -- 3187
		return ____awaiter_resolve(nil, "main") -- 3187
	end) -- 3187
end -- 3162
local BuildAction = __TS__Class() -- 3192
BuildAction.name = "BuildAction" -- 3192
__TS__ClassExtends(BuildAction, Node) -- 3192
function BuildAction.prototype.prep(self, shared) -- 3193
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3193
		local last = shared.history[#shared.history] -- 3194
		if not last then -- 3194
			error( -- 3195
				__TS__New(Error, "no history"), -- 3195
				0 -- 3195
			) -- 3195
		end -- 3195
		emitAgentStartEvent(shared, last) -- 3196
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3196
	end) -- 3196
end -- 3193
function BuildAction.prototype.exec(self, input) -- 3200
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3200
		local params = input.params -- 3201
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3202
		return ____awaiter_resolve(nil, result) -- 3202
	end) -- 3202
end -- 3200
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3209
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3209
		local last = shared.history[#shared.history] -- 3210
		if last ~= nil then -- 3210
			last.result = sanitizeBuildResultForHistory(execRes) -- 3212
			appendToolResultMessage(shared, last) -- 3213
			emitAgentFinishEvent(shared, last) -- 3214
		end -- 3214
		persistHistoryState(shared) -- 3216
		__TS__Await(maybeCompressHistory(shared)) -- 3217
		persistHistoryState(shared) -- 3218
		return ____awaiter_resolve(nil, "main") -- 3218
	end) -- 3218
end -- 3209
local SpawnSubAgentAction = __TS__Class() -- 3223
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3223
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3223
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3224
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3224
		local last = shared.history[#shared.history] -- 3233
		if not last then -- 3233
			error( -- 3234
				__TS__New(Error, "no history"), -- 3234
				0 -- 3234
			) -- 3234
		end -- 3234
		emitAgentStartEvent(shared, last) -- 3235
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3236
			last.params.filesHint, -- 3237
			function(____, item) return type(item) == "string" end -- 3237
		) or nil -- 3237
		return ____awaiter_resolve( -- 3237
			nil, -- 3237
			{ -- 3239
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3240
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3241
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3242
				filesHint = filesHint, -- 3243
				sessionId = shared.sessionId, -- 3244
				projectRoot = shared.workingDir, -- 3245
				spawnSubAgent = shared.spawnSubAgent -- 3246
			} -- 3246
		) -- 3246
	end) -- 3246
end -- 3224
function SpawnSubAgentAction.prototype.exec(self, input) -- 3250
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3250
		if not input.spawnSubAgent then -- 3250
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3250
		end -- 3250
		if input.sessionId == nil or input.sessionId <= 0 then -- 3250
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3250
		end -- 3250
		local ____Log_99 = Log -- 3265
		local ____temp_96 = #input.title -- 3265
		local ____temp_97 = #input.prompt -- 3265
		local ____temp_98 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3265
		local ____opt_94 = input.filesHint -- 3265
		____Log_99( -- 3265
			"Info", -- 3265
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_96)) .. " prompt_len=") .. tostring(____temp_97)) .. " expected_len=") .. tostring(____temp_98)) .. " files_hint_count=") .. tostring(____opt_94 and #____opt_94 or 0) -- 3265
		) -- 3265
		local result = __TS__Await(input.spawnSubAgent({ -- 3266
			parentSessionId = input.sessionId, -- 3267
			projectRoot = input.projectRoot, -- 3268
			title = input.title, -- 3269
			prompt = input.prompt, -- 3270
			expectedOutput = input.expectedOutput, -- 3271
			filesHint = input.filesHint -- 3272
		})) -- 3272
		if not result.success then -- 3272
			return ____awaiter_resolve(nil, result) -- 3272
		end -- 3272
		return ____awaiter_resolve(nil, { -- 3272
			success = true, -- 3278
			sessionId = result.sessionId, -- 3279
			taskId = result.taskId, -- 3280
			title = result.title, -- 3281
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3282
		}) -- 3282
	end) -- 3282
end -- 3250
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3286
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3286
		local last = shared.history[#shared.history] -- 3287
		if last ~= nil then -- 3287
			last.result = execRes -- 3289
			appendToolResultMessage(shared, last) -- 3290
			emitAgentFinishEvent(shared, last) -- 3291
		end -- 3291
		persistHistoryState(shared) -- 3293
		__TS__Await(maybeCompressHistory(shared)) -- 3294
		persistHistoryState(shared) -- 3295
		return ____awaiter_resolve(nil, "main") -- 3295
	end) -- 3295
end -- 3286
local ListSubAgentsAction = __TS__Class() -- 3300
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3300
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3300
function ListSubAgentsAction.prototype.prep(self, shared) -- 3301
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3301
		local last = shared.history[#shared.history] -- 3310
		if not last then -- 3310
			error( -- 3311
				__TS__New(Error, "no history"), -- 3311
				0 -- 3311
			) -- 3311
		end -- 3311
		emitAgentStartEvent(shared, last) -- 3312
		return ____awaiter_resolve( -- 3312
			nil, -- 3312
			{ -- 3313
				sessionId = shared.sessionId, -- 3314
				projectRoot = shared.workingDir, -- 3315
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3316
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3317
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3318
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3319
				listSubAgents = shared.listSubAgents -- 3320
			} -- 3320
		) -- 3320
	end) -- 3320
end -- 3301
function ListSubAgentsAction.prototype.exec(self, input) -- 3324
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3324
		if not input.listSubAgents then -- 3324
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3324
		end -- 3324
		if input.sessionId == nil or input.sessionId <= 0 then -- 3324
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3324
		end -- 3324
		local result = __TS__Await(input.listSubAgents({ -- 3339
			sessionId = input.sessionId, -- 3340
			projectRoot = input.projectRoot, -- 3341
			status = input.status, -- 3342
			limit = input.limit, -- 3343
			offset = input.offset, -- 3344
			query = input.query -- 3345
		})) -- 3345
		return ____awaiter_resolve(nil, result) -- 3345
	end) -- 3345
end -- 3324
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3350
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3350
		local last = shared.history[#shared.history] -- 3351
		if last ~= nil then -- 3351
			last.result = execRes -- 3353
			appendToolResultMessage(shared, last) -- 3354
			emitAgentFinishEvent(shared, last) -- 3355
		end -- 3355
		persistHistoryState(shared) -- 3357
		__TS__Await(maybeCompressHistory(shared)) -- 3358
		persistHistoryState(shared) -- 3359
		return ____awaiter_resolve(nil, "main") -- 3359
	end) -- 3359
end -- 3350
EditFileAction = __TS__Class() -- 3364
EditFileAction.name = "EditFileAction" -- 3364
__TS__ClassExtends(EditFileAction, Node) -- 3364
function EditFileAction.prototype.prep(self, shared) -- 3365
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3365
		local last = shared.history[#shared.history] -- 3366
		if not last then -- 3366
			error( -- 3367
				__TS__New(Error, "no history"), -- 3367
				0 -- 3367
			) -- 3367
		end -- 3367
		emitAgentStartEvent(shared, last) -- 3368
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3369
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3372
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3373
		if __TS__StringTrim(path) == "" then -- 3373
			error( -- 3374
				__TS__New(Error, "missing path"), -- 3374
				0 -- 3374
			) -- 3374
		end -- 3374
		return ____awaiter_resolve(nil, { -- 3374
			path = path, -- 3375
			oldStr = oldStr, -- 3375
			newStr = newStr, -- 3375
			taskId = shared.taskId, -- 3375
			workDir = shared.workingDir -- 3375
		}) -- 3375
	end) -- 3375
end -- 3365
function EditFileAction.prototype.exec(self, input) -- 3378
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3378
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3379
		if not readRes.success then -- 3379
			if input.oldStr ~= "" then -- 3379
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3379
			end -- 3379
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3384
			if not createRes.success then -- 3384
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3384
			end -- 3384
			return ____awaiter_resolve(nil, { -- 3384
				success = true, -- 3392
				changed = true, -- 3393
				mode = "create", -- 3394
				checkpointId = createRes.checkpointId, -- 3395
				checkpointSeq = createRes.checkpointSeq, -- 3396
				files = {{path = input.path, op = "create"}} -- 3397
			}) -- 3397
		end -- 3397
		if input.oldStr == "" then -- 3397
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3401
			if not overwriteRes.success then -- 3401
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3401
			end -- 3401
			return ____awaiter_resolve(nil, { -- 3401
				success = true, -- 3409
				changed = true, -- 3410
				mode = "overwrite", -- 3411
				checkpointId = overwriteRes.checkpointId, -- 3412
				checkpointSeq = overwriteRes.checkpointSeq, -- 3413
				files = {{path = input.path, op = "write"}} -- 3414
			}) -- 3414
		end -- 3414
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3419
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3420
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3421
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3424
		if occurrences == 0 then -- 3424
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3426
			if not indentTolerant.success then -- 3426
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3426
			end -- 3426
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3430
			if not applyRes.success then -- 3430
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3430
			end -- 3430
			return ____awaiter_resolve(nil, { -- 3430
				success = true, -- 3438
				changed = true, -- 3439
				mode = "replace_indent_tolerant", -- 3440
				checkpointId = applyRes.checkpointId, -- 3441
				checkpointSeq = applyRes.checkpointSeq, -- 3442
				files = {{path = input.path, op = "write"}} -- 3443
			}) -- 3443
		end -- 3443
		if occurrences > 1 then -- 3443
			return ____awaiter_resolve( -- 3443
				nil, -- 3443
				{ -- 3447
					success = false, -- 3447
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3447
				} -- 3447
			) -- 3447
		end -- 3447
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3451
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3452
		if not applyRes.success then -- 3452
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3452
		end -- 3452
		return ____awaiter_resolve(nil, { -- 3452
			success = true, -- 3460
			changed = true, -- 3461
			mode = "replace", -- 3462
			checkpointId = applyRes.checkpointId, -- 3463
			checkpointSeq = applyRes.checkpointSeq, -- 3464
			files = {{path = input.path, op = "write"}} -- 3465
		}) -- 3465
	end) -- 3465
end -- 3378
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3469
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3469
		local last = shared.history[#shared.history] -- 3470
		if last ~= nil then -- 3470
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3472
			last.result = execRes -- 3473
			appendToolResultMessage(shared, last) -- 3474
			emitAgentFinishEvent(shared, last) -- 3475
			local result = last.result -- 3476
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3476
				emitAgentEvent(shared, { -- 3481
					type = "checkpoint_created", -- 3482
					sessionId = shared.sessionId, -- 3483
					taskId = shared.taskId, -- 3484
					step = last.step, -- 3485
					tool = last.tool, -- 3486
					checkpointId = result.checkpointId, -- 3487
					checkpointSeq = result.checkpointSeq, -- 3488
					files = result.files -- 3489
				}) -- 3489
			end -- 3489
		end -- 3489
		persistHistoryState(shared) -- 3493
		__TS__Await(maybeCompressHistory(shared)) -- 3494
		persistHistoryState(shared) -- 3495
		return ____awaiter_resolve(nil, "main") -- 3495
	end) -- 3495
end -- 3469
local function emitCheckpointEventForAction(shared, action) -- 3500
	local result = action.result -- 3501
	if not result then -- 3501
		return -- 3502
	end -- 3502
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3502
		emitAgentEvent(shared, { -- 3507
			type = "checkpoint_created", -- 3508
			sessionId = shared.sessionId, -- 3509
			taskId = shared.taskId, -- 3510
			step = action.step, -- 3511
			tool = action.tool, -- 3512
			checkpointId = result.checkpointId, -- 3513
			checkpointSeq = result.checkpointSeq, -- 3514
			files = result.files -- 3515
		}) -- 3515
	end -- 3515
end -- 3500
local function sanitizeToolActionResultForHistory(action, result) -- 3670
	if action.tool == "read_file" then -- 3670
		return sanitizeReadResultForHistory(action.tool, result) -- 3672
	end -- 3672
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3672
		return sanitizeSearchResultForHistory(action.tool, result) -- 3675
	end -- 3675
	if action.tool == "glob_files" then -- 3675
		return sanitizeListFilesResultForHistory(result) -- 3678
	end -- 3678
	if action.tool == "build" then -- 3678
		return sanitizeBuildResultForHistory(result) -- 3681
	end -- 3681
	return result -- 3683
end -- 3670
local function canRunBatchActionInParallel(self, action) -- 3686
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 3687
end -- 3686
local function partitionToolCalls(actions) -- 3699
	local batches = {} -- 3700
	do -- 3700
		local i = 0 -- 3701
		while i < #actions do -- 3701
			local action = actions[i + 1] -- 3702
			local isSafe = canRunBatchActionInParallel(nil, action) -- 3703
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 3704
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 3704
				local ____lastBatch_actions_134 = lastBatch.actions -- 3704
				____lastBatch_actions_134[#____lastBatch_actions_134 + 1] = action -- 3706
			else -- 3706
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 3708
			end -- 3708
			i = i + 1 -- 3701
		end -- 3701
	end -- 3701
	return batches -- 3711
end -- 3699
local BatchToolAction = __TS__Class() -- 3714
BatchToolAction.name = "BatchToolAction" -- 3714
__TS__ClassExtends(BatchToolAction, Node) -- 3714
function BatchToolAction.prototype.prep(self, shared) -- 3715
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3715
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3715
	end) -- 3715
end -- 3715
function BatchToolAction.prototype.exec(self, input) -- 3719
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3719
		local shared = input.shared -- 3720
		local preExecuted = shared.preExecutedResults -- 3721
		local batches = partitionToolCalls(input.actions) -- 3722
		local parallelBatchCount = #__TS__ArrayFilter( -- 3723
			batches, -- 3723
			function(____, b) return b.isConcurrencySafe end -- 3723
		) -- 3723
		local serialBatchCount = #__TS__ArrayFilter( -- 3724
			batches, -- 3724
			function(____, b) return not b.isConcurrencySafe end -- 3724
		) -- 3724
		Log( -- 3725
			"Info", -- 3725
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 3725
		) -- 3725
		do -- 3725
			local batchIdx = 0 -- 3727
			while batchIdx < #batches do -- 3727
				do -- 3727
					local batch = batches[batchIdx + 1] -- 3728
					if shared.stopToken.stopped then -- 3728
						for ____, action in ipairs(batch.actions) do -- 3730
							if not action.result then -- 3730
								action.result = { -- 3732
									success = false, -- 3732
									message = getCancelledReason(shared) -- 3732
								} -- 3732
							end -- 3732
						end -- 3732
						goto __continue572 -- 3735
					end -- 3735
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 3735
						local preExecCount = #__TS__ArrayFilter( -- 3739
							batch.actions, -- 3739
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 3739
						) -- 3739
						Log( -- 3740
							"Info", -- 3740
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3740
						) -- 3740
						do -- 3740
							local i = 0 -- 3741
							while i < #batch.actions do -- 3741
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 3742
								i = i + 1 -- 3741
							end -- 3741
						end -- 3741
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3744
							batch.actions, -- 3744
							function(____, action) -- 3744
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3744
									if shared.stopToken.stopped then -- 3744
										action.result = { -- 3746
											success = false, -- 3746
											message = getCancelledReason(shared) -- 3746
										} -- 3746
										return ____awaiter_resolve(nil, action) -- 3746
									end -- 3746
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3749
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3750
									action.result = sanitizeToolActionResultForHistory(action, result) -- 3751
									return ____awaiter_resolve(nil, action) -- 3751
								end) -- 3751
							end -- 3744
						))) -- 3744
						do -- 3744
							local i = 0 -- 3754
							while i < #batch.actions do -- 3754
								local action = batch.actions[i + 1] -- 3755
								if not action.result then -- 3755
									action.result = {success = false, message = "tool did not produce a result"} -- 3757
								end -- 3757
								appendToolResultMessage(shared, action) -- 3759
								emitAgentFinishEvent(shared, action) -- 3760
								emitCheckpointEventForAction(shared, action) -- 3761
								i = i + 1 -- 3754
							end -- 3754
						end -- 3754
					else -- 3754
						Log( -- 3764
							"Info", -- 3764
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 3764
						) -- 3764
						do -- 3764
							local i = 0 -- 3765
							while i < #batch.actions do -- 3765
								local action = batch.actions[i + 1] -- 3766
								emitAgentStartEvent(shared, action) -- 3767
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3768
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3769
								action.result = sanitizeToolActionResultForHistory(action, result) -- 3770
								appendToolResultMessage(shared, action) -- 3771
								emitAgentFinishEvent(shared, action) -- 3772
								emitCheckpointEventForAction(shared, action) -- 3773
								persistHistoryState(shared) -- 3774
								if shared.stopToken.stopped then -- 3774
									break -- 3776
								end -- 3776
								i = i + 1 -- 3765
							end -- 3765
						end -- 3765
					end -- 3765
				end -- 3765
				::__continue572:: -- 3765
				batchIdx = batchIdx + 1 -- 3727
			end -- 3727
		end -- 3727
		persistHistoryState(shared) -- 3781
		return ____awaiter_resolve(nil, input.actions) -- 3781
	end) -- 3781
end -- 3719
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3785
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3785
		shared.pendingToolActions = nil -- 3786
		shared.preExecutedResults = nil -- 3787
		persistHistoryState(shared) -- 3788
		__TS__Await(maybeCompressHistory(shared)) -- 3789
		persistHistoryState(shared) -- 3790
		return ____awaiter_resolve(nil, "main") -- 3790
	end) -- 3790
end -- 3785
local EndNode = __TS__Class() -- 3795
EndNode.name = "EndNode" -- 3795
__TS__ClassExtends(EndNode, Node) -- 3795
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3796
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3796
		return ____awaiter_resolve(nil, nil) -- 3796
	end) -- 3796
end -- 3796
local CodingAgentFlow = __TS__Class() -- 3801
CodingAgentFlow.name = "CodingAgentFlow" -- 3801
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3801
function CodingAgentFlow.prototype.____constructor(self, role) -- 3802
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3803
	local read = __TS__New(ReadFileAction, 1, 0) -- 3804
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3805
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3806
	local list = __TS__New(ListFilesAction, 1, 0) -- 3807
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3808
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3809
	local build = __TS__New(BuildAction, 1, 0) -- 3810
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3811
	local edit = __TS__New(EditFileAction, 1, 0) -- 3812
	local batch = __TS__New(BatchToolAction, 1, 0) -- 3813
	local done = __TS__New(EndNode, 1, 0) -- 3814
	main:on("batch_tools", batch) -- 3816
	main:on("grep_files", search) -- 3817
	main:on("search_dora_api", searchDora) -- 3818
	main:on("glob_files", list) -- 3819
	if role == "main" then -- 3819
		main:on("read_file", read) -- 3821
		main:on("delete_file", del) -- 3822
		main:on("build", build) -- 3823
		main:on("edit_file", edit) -- 3824
		main:on("list_sub_agents", listSub) -- 3825
		main:on("spawn_sub_agent", spawn) -- 3826
	else -- 3826
		main:on("read_file", read) -- 3828
		main:on("delete_file", del) -- 3829
		main:on("build", build) -- 3830
		main:on("edit_file", edit) -- 3831
	end -- 3831
	main:on("done", done) -- 3833
	search:on("main", main) -- 3835
	searchDora:on("main", main) -- 3836
	list:on("main", main) -- 3837
	listSub:on("main", main) -- 3838
	spawn:on("main", main) -- 3839
	batch:on("main", main) -- 3840
	read:on("main", main) -- 3841
	del:on("main", main) -- 3842
	build:on("main", main) -- 3843
	edit:on("main", main) -- 3844
	Flow.prototype.____constructor(self, main) -- 3846
end -- 3802
local function runCodingAgentAsync(options) -- 3868
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3868
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3868
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3868
		end -- 3868
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3872
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3873
		if not llmConfigRes.success then -- 3873
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3873
		end -- 3873
		local llmConfig = llmConfigRes.config -- 3879
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3880
		if not taskRes.success then -- 3880
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3880
		end -- 3880
		local compressor = __TS__New(MemoryCompressor, { -- 3887
			compressionThreshold = 0.8, -- 3888
			compressionTargetThreshold = 0.5, -- 3889
			maxCompressionRounds = 3, -- 3890
			projectDir = options.workDir, -- 3891
			llmConfig = llmConfig, -- 3892
			promptPack = options.promptPack, -- 3893
			scope = options.memoryScope -- 3894
		}) -- 3894
		local persistedSession = compressor:getStorage():readSessionState() -- 3896
		local promptPack = compressor:getPromptPack() -- 3897
		local shared = { -- 3899
			sessionId = options.sessionId, -- 3900
			taskId = taskRes.taskId, -- 3901
			role = options.role or "main", -- 3902
			maxSteps = math.max( -- 3903
				1, -- 3903
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 3903
			), -- 3903
			llmMaxTry = math.max( -- 3904
				1, -- 3904
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 3904
			), -- 3904
			step = 0, -- 3905
			done = false, -- 3906
			stopToken = options.stopToken or ({stopped = false}), -- 3907
			response = "", -- 3908
			userQuery = normalizedPrompt, -- 3909
			workingDir = options.workDir, -- 3910
			useChineseResponse = options.useChineseResponse == true, -- 3911
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3912
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 3915
			llmConfig = llmConfig, -- 3916
			onEvent = options.onEvent, -- 3917
			promptPack = promptPack, -- 3918
			history = {}, -- 3919
			messages = persistedSession.messages, -- 3920
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 3921
			carryMessageIndex = persistedSession.carryMessageIndex, -- 3922
			memory = {compressor = compressor}, -- 3924
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 3928
			spawnSubAgent = options.spawnSubAgent, -- 3933
			listSubAgents = options.listSubAgents -- 3934
		} -- 3934
		local ____try = __TS__AsyncAwaiter(function() -- 3934
			emitAgentEvent(shared, { -- 3938
				type = "task_started", -- 3939
				sessionId = shared.sessionId, -- 3940
				taskId = shared.taskId, -- 3941
				prompt = shared.userQuery, -- 3942
				workDir = shared.workingDir, -- 3943
				maxSteps = shared.maxSteps -- 3944
			}) -- 3944
			if shared.stopToken.stopped then -- 3944
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3947
				return ____awaiter_resolve( -- 3947
					nil, -- 3947
					emitAgentTaskFinishEvent( -- 3948
						shared, -- 3948
						false, -- 3948
						getCancelledReason(shared) -- 3948
					) -- 3948
				) -- 3948
			end -- 3948
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3950
			local promptCommand = getPromptCommand(shared.userQuery) -- 3951
			if promptCommand == "clear" then -- 3951
				return ____awaiter_resolve( -- 3951
					nil, -- 3951
					clearSessionHistory(shared) -- 3953
				) -- 3953
			end -- 3953
			if promptCommand == "compact" then -- 3953
				if shared.role == "sub" then -- 3953
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 3957
					return ____awaiter_resolve( -- 3957
						nil, -- 3957
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 3958
					) -- 3958
				end -- 3958
				return ____awaiter_resolve( -- 3958
					nil, -- 3958
					__TS__Await(compactAllHistory(shared)) -- 3966
				) -- 3966
			end -- 3966
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3968
			persistHistoryState(shared) -- 3972
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3973
			__TS__Await(flow:run(shared)) -- 3974
			if shared.stopToken.stopped then -- 3974
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3976
				return ____awaiter_resolve( -- 3976
					nil, -- 3976
					emitAgentTaskFinishEvent( -- 3977
						shared, -- 3977
						false, -- 3977
						getCancelledReason(shared) -- 3977
					) -- 3977
				) -- 3977
			end -- 3977
			if shared.error then -- 3977
				return ____awaiter_resolve( -- 3977
					nil, -- 3977
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3980
				) -- 3980
			end -- 3980
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3983
			return ____awaiter_resolve( -- 3983
				nil, -- 3983
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3984
			) -- 3984
		end) -- 3984
		__TS__Await(____try.catch( -- 3937
			____try, -- 3937
			function(____, e) -- 3937
				return ____awaiter_resolve( -- 3937
					nil, -- 3937
					finalizeAgentFailure( -- 3987
						shared, -- 3987
						tostring(e) -- 3987
					) -- 3987
				) -- 3987
			end -- 3987
		)) -- 3987
	end) -- 3987
end -- 3868
function ____exports.runCodingAgent(options, callback) -- 3991
	local ____self_137 = runCodingAgentAsync(options) -- 3991
	____self_137["then"]( -- 3991
		____self_137, -- 3991
		function(____, result) return callback(result) end -- 3992
	) -- 3992
end -- 3991
return ____exports -- 3991