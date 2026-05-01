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
function emitAgentEvent(shared, event) -- 755
	if shared.onEvent then -- 755
		do -- 755
			local function ____catch(____error) -- 755
				Log( -- 760
					"Error", -- 760
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 760
				) -- 760
			end -- 760
			local ____try, ____hasReturned = pcall(function() -- 760
				shared:onEvent(event) -- 758
			end) -- 758
			if not ____try then -- 758
				____catch(____hasReturned) -- 758
			end -- 758
		end -- 758
	end -- 758
end -- 758
function getCancelledReason(shared) -- 878
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 878
		return shared.stopToken.reason -- 879
	end -- 879
	return shared.useChineseResponse and "已取消" or "cancelled" -- 880
end -- 880
function truncateText(text, maxLen) -- 1061
	if #text <= maxLen then -- 1061
		return text -- 1062
	end -- 1062
	local nextPos = utf8.offset(text, maxLen + 1) -- 1063
	if nextPos == nil then -- 1063
		return text -- 1064
	end -- 1064
	return string.sub(text, 1, nextPos - 1) .. "..." -- 1065
end -- 1065
function getReplyLanguageDirective(shared) -- 1075
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 1076
end -- 1076
function replacePromptVars(template, vars) -- 1081
	local output = template -- 1082
	for key in pairs(vars) do -- 1083
		output = table.concat( -- 1084
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 1084
			vars[key] or "" or "," -- 1084
		) -- 1084
	end -- 1084
	return output -- 1086
end -- 1086
function getDecisionToolDefinitions(shared) -- 1237
	local base = replacePromptVars( -- 1238
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1239
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1240
	) -- 1240
	local spawnTool = "\n\n9. list_sub_agents: Query sub-agent state under the current main session\n\t- Parameters: status(optional), limit(optional), offset(optional), query(optional)\n\t- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.\n\t- status defaults to active_or_recent and may also be running, done, failed, or all.\n\t- limit defaults to a small recent window. Use offset to page older items.\n\t- query filters by title, goal, or summary text.\n\t- Do not use this after a successful spawn_sub_agent in the same turn.\n\n10. spawn_sub_agent: Create and start a sub agent session for delegated implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n\t- For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.\n\t- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.\n\t- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.\n\t- filesHint is an optional list of likely files or directories." -- 1242
	local availability = shared and (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat( -- 1263
		getAllowedToolsForRole(shared.role), -- 1264
		", " -- 1264
	) or "" -- 1264
	local withRole = (base .. ((shared and shared.role) == "main" and spawnTool or "")) .. availability -- 1266
	if (shared and shared.decisionMode) ~= "xml" then -- 1266
		return withRole -- 1268
	end -- 1268
	return withRole .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1270
end -- 1270
function getFinishMessage(params, fallback) -- 1569
	if fallback == nil then -- 1569
		fallback = "" -- 1569
	end -- 1569
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1569
		return __TS__StringTrim(params.message) -- 1571
	end -- 1571
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1571
		return __TS__StringTrim(params.response) -- 1574
	end -- 1574
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1574
		return __TS__StringTrim(params.summary) -- 1577
	end -- 1577
	return __TS__StringTrim(fallback) -- 1579
end -- 1579
function persistHistoryState(shared) -- 1582
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1583
end -- 1583
function getActiveConversationMessages(shared) -- 1590
	local activeMessages = {} -- 1591
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1591
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1598
	end -- 1598
	do -- 1598
		local i = shared.lastConsolidatedIndex -- 1602
		while i < #shared.messages do -- 1602
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1603
			i = i + 1 -- 1602
		end -- 1602
	end -- 1602
	return activeMessages -- 1605
end -- 1605
function getActiveRealMessageCount(shared) -- 1608
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1609
end -- 1609
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1612
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1617
	local previousActiveStart = shared.lastConsolidatedIndex -- 1618
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1619
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1620
	if type(carryMessageIndex) == "number" then -- 1620
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1620
		else -- 1620
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1628
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1631
		end -- 1631
	else -- 1631
		shared.carryMessageIndex = nil -- 1636
	end -- 1636
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1636
		shared.carryMessageIndex = nil -- 1646
	end -- 1646
end -- 1646
function getDecisionPath(params) -- 1904
	if type(params.path) == "string" then -- 1904
		return __TS__StringTrim(params.path) -- 1905
	end -- 1905
	if type(params.target_file) == "string" then -- 1905
		return __TS__StringTrim(params.target_file) -- 1906
	end -- 1906
	return "" -- 1907
end -- 1907
function clampIntegerParam(value, fallback, minValue, maxValue) -- 1910
	local num = __TS__Number(value) -- 1911
	if not __TS__NumberIsFinite(num) then -- 1911
		num = fallback -- 1912
	end -- 1912
	num = math.floor(num) -- 1913
	if num < minValue then -- 1913
		num = minValue -- 1914
	end -- 1914
	if maxValue ~= nil and num > maxValue then -- 1914
		num = maxValue -- 1915
	end -- 1915
	return num -- 1916
end -- 1916
function parseReadLineParam(value, fallback, paramName) -- 1919
	local num = __TS__Number(value) -- 1924
	if not __TS__NumberIsFinite(num) then -- 1924
		num = fallback -- 1925
	end -- 1925
	num = math.floor(num) -- 1926
	if num == 0 then -- 1926
		return {success = false, message = paramName .. " cannot be 0"} -- 1928
	end -- 1928
	return {success = true, value = num} -- 1930
end -- 1930
function validateDecision(tool, params) -- 1933
	if tool == "finish" then -- 1933
		local message = getFinishMessage(params) -- 1938
		if message == "" then -- 1938
			return {success = false, message = "finish requires params.message"} -- 1939
		end -- 1939
		params.message = message -- 1940
		return {success = true, params = params} -- 1941
	end -- 1941
	if tool == "read_file" then -- 1941
		local path = getDecisionPath(params) -- 1945
		if path == "" then -- 1945
			return {success = false, message = "read_file requires path"} -- 1946
		end -- 1946
		params.path = path -- 1947
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1948
		if not startLineRes.success then -- 1948
			return startLineRes -- 1949
		end -- 1949
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1950
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1951
		if not endLineRes.success then -- 1951
			return endLineRes -- 1952
		end -- 1952
		params.startLine = startLineRes.value -- 1953
		params.endLine = endLineRes.value -- 1954
		return {success = true, params = params} -- 1955
	end -- 1955
	if tool == "edit_file" then -- 1955
		local path = getDecisionPath(params) -- 1959
		if path == "" then -- 1959
			return {success = false, message = "edit_file requires path"} -- 1960
		end -- 1960
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1961
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1962
		params.path = path -- 1963
		params.old_str = oldStr -- 1964
		params.new_str = newStr -- 1965
		return {success = true, params = params} -- 1966
	end -- 1966
	if tool == "delete_file" then -- 1966
		local targetFile = getDecisionPath(params) -- 1970
		if targetFile == "" then -- 1970
			return {success = false, message = "delete_file requires target_file"} -- 1971
		end -- 1971
		params.target_file = targetFile -- 1972
		return {success = true, params = params} -- 1973
	end -- 1973
	if tool == "grep_files" then -- 1973
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1977
		if pattern == "" then -- 1977
			return {success = false, message = "grep_files requires pattern"} -- 1978
		end -- 1978
		params.pattern = pattern -- 1979
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1980
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1981
		return {success = true, params = params} -- 1982
	end -- 1982
	if tool == "search_dora_api" then -- 1982
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1986
		if pattern == "" then -- 1986
			return {success = false, message = "search_dora_api requires pattern"} -- 1987
		end -- 1987
		params.pattern = pattern -- 1988
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1989
		return {success = true, params = params} -- 1990
	end -- 1990
	if tool == "glob_files" then -- 1990
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1994
		return {success = true, params = params} -- 1995
	end -- 1995
	if tool == "build" then -- 1995
		local path = getDecisionPath(params) -- 1999
		if path ~= "" then -- 1999
			params.path = path -- 2001
		end -- 2001
		return {success = true, params = params} -- 2003
	end -- 2003
	if tool == "list_sub_agents" then -- 2003
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2007
		if status ~= "" then -- 2007
			params.status = status -- 2009
		end -- 2009
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2011
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2012
		if type(params.query) == "string" then -- 2012
			params.query = __TS__StringTrim(params.query) -- 2014
		end -- 2014
		return {success = true, params = params} -- 2016
	end -- 2016
	if tool == "spawn_sub_agent" then -- 2016
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2020
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2021
		if prompt == "" then -- 2021
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2022
		end -- 2022
		if title == "" then -- 2022
			return {success = false, message = "spawn_sub_agent requires title"} -- 2023
		end -- 2023
		params.prompt = prompt -- 2024
		params.title = title -- 2025
		if type(params.expectedOutput) == "string" then -- 2025
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2027
		end -- 2027
		if isArray(params.filesHint) then -- 2027
			params.filesHint = __TS__ArrayMap( -- 2030
				__TS__ArrayFilter( -- 2030
					params.filesHint, -- 2030
					function(____, item) return type(item) == "string" end -- 2031
				), -- 2031
				function(____, item) return sanitizeUTF8(item) end -- 2032
			) -- 2032
		end -- 2032
		return {success = true, params = params} -- 2034
	end -- 2034
	return {success = true, params = params} -- 2037
end -- 2037
function getAllowedToolsForRole(role) -- 2063
	return role == "main" and ({ -- 2064
		"read_file", -- 2065
		"edit_file", -- 2065
		"delete_file", -- 2065
		"grep_files", -- 2065
		"search_dora_api", -- 2065
		"glob_files", -- 2065
		"build", -- 2065
		"list_sub_agents", -- 2065
		"spawn_sub_agent", -- 2065
		"finish" -- 2065
	}) or ({ -- 2065
		"read_file", -- 2066
		"edit_file", -- 2066
		"delete_file", -- 2066
		"grep_files", -- 2066
		"search_dora_api", -- 2066
		"glob_files", -- 2066
		"build", -- 2066
		"finish" -- 2066
	}) -- 2066
end -- 2066
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2172
	if includeToolDefinitions == nil then -- 2172
		includeToolDefinitions = false -- 2172
	end -- 2172
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2173
	local sections = { -- 2176
		shared.promptPack.agentIdentityPrompt, -- 2177
		rolePrompt, -- 2178
		getReplyLanguageDirective(shared) -- 2179
	} -- 2179
	if shared.decisionMode == "tool_calling" then -- 2179
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2182
	end -- 2182
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2184
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2185
	if memoryContext ~= "" then -- 2185
		sections[#sections + 1] = memoryContext -- 2187
	end -- 2187
	if includeToolDefinitions then -- 2187
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2190
		if shared.decisionMode == "xml" then -- 2190
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2192
		end -- 2192
	end -- 2192
	local skillsSection = buildSkillsSection(shared) -- 2196
	if skillsSection ~= "" then -- 2196
		sections[#sections + 1] = skillsSection -- 2198
	end -- 2198
	return table.concat(sections, "\n\n") -- 2200
end -- 2200
function buildSkillsSection(shared) -- 2203
	local ____opt_42 = shared.skills -- 2203
	if not (____opt_42 and ____opt_42.loader) then -- 2203
		return "" -- 2205
	end -- 2205
	return shared.skills.loader:buildSkillsPromptSection() -- 2207
end -- 2207
function buildXmlDecisionInstruction(shared, feedback) -- 2325
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2326
end -- 2326
function executeToolAction(shared, action) -- 3508
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3508
		if shared.stopToken.stopped then -- 3508
			return ____awaiter_resolve( -- 3508
				nil, -- 3508
				{ -- 3510
					success = false, -- 3510
					message = getCancelledReason(shared) -- 3510
				} -- 3510
			) -- 3510
		end -- 3510
		local params = action.params -- 3512
		if action.tool == "read_file" then -- 3512
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3514
			if __TS__StringTrim(path) == "" then -- 3514
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3514
			end -- 3514
			local ____Tools_readFile_104 = Tools.readFile -- 3518
			local ____shared_workingDir_102 = shared.workingDir -- 3519
			local ____params_startLine_100 = params.startLine -- 3521
			if ____params_startLine_100 == nil then -- 3521
				____params_startLine_100 = 1 -- 3521
			end -- 3521
			local ____TS__Number_result_103 = __TS__Number(____params_startLine_100) -- 3521
			local ____params_endLine_101 = params.endLine -- 3522
			if ____params_endLine_101 == nil then -- 3522
				____params_endLine_101 = READ_FILE_DEFAULT_LIMIT -- 3522
			end -- 3522
			return ____awaiter_resolve( -- 3522
				nil, -- 3522
				____Tools_readFile_104( -- 3518
					____shared_workingDir_102, -- 3519
					path, -- 3520
					____TS__Number_result_103, -- 3521
					__TS__Number(____params_endLine_101), -- 3522
					shared.useChineseResponse and "zh" or "en" -- 3523
				) -- 3523
			) -- 3523
		end -- 3523
		if action.tool == "grep_files" then -- 3523
			local ____Tools_searchFiles_118 = Tools.searchFiles -- 3527
			local ____shared_workingDir_111 = shared.workingDir -- 3528
			local ____temp_112 = params.path or "" -- 3529
			local ____temp_113 = params.pattern or "" -- 3530
			local ____params_globs_114 = params.globs -- 3531
			local ____params_useRegex_115 = params.useRegex -- 3532
			local ____params_caseSensitive_116 = params.caseSensitive -- 3533
			local ____math_max_107 = math.max -- 3536
			local ____math_floor_106 = math.floor -- 3536
			local ____params_limit_105 = params.limit -- 3536
			if ____params_limit_105 == nil then -- 3536
				____params_limit_105 = SEARCH_FILES_LIMIT_DEFAULT -- 3536
			end -- 3536
			local ____math_max_107_result_117 = ____math_max_107( -- 3536
				1, -- 3536
				____math_floor_106(__TS__Number(____params_limit_105)) -- 3536
			) -- 3536
			local ____math_max_110 = math.max -- 3537
			local ____math_floor_109 = math.floor -- 3537
			local ____params_offset_108 = params.offset -- 3537
			if ____params_offset_108 == nil then -- 3537
				____params_offset_108 = 0 -- 3537
			end -- 3537
			local result = __TS__Await(____Tools_searchFiles_118({ -- 3527
				workDir = ____shared_workingDir_111, -- 3528
				path = ____temp_112, -- 3529
				pattern = ____temp_113, -- 3530
				globs = ____params_globs_114, -- 3531
				useRegex = ____params_useRegex_115, -- 3532
				caseSensitive = ____params_caseSensitive_116, -- 3533
				includeContent = true, -- 3534
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3535
				limit = ____math_max_107_result_117, -- 3536
				offset = ____math_max_110( -- 3537
					0, -- 3537
					____math_floor_109(__TS__Number(____params_offset_108)) -- 3537
				), -- 3537
				groupByFile = params.groupByFile == true -- 3538
			})) -- 3538
			return ____awaiter_resolve(nil, result) -- 3538
		end -- 3538
		if action.tool == "search_dora_api" then -- 3538
			local ____Tools_searchDoraAPI_126 = Tools.searchDoraAPI -- 3543
			local ____temp_122 = params.pattern or "" -- 3544
			local ____temp_123 = params.docSource or "api" -- 3545
			local ____temp_124 = shared.useChineseResponse and "zh" or "en" -- 3546
			local ____temp_125 = params.programmingLanguage or "ts" -- 3547
			local ____math_min_121 = math.min -- 3548
			local ____math_max_120 = math.max -- 3548
			local ____params_limit_119 = params.limit -- 3548
			if ____params_limit_119 == nil then -- 3548
				____params_limit_119 = 8 -- 3548
			end -- 3548
			local result = __TS__Await(____Tools_searchDoraAPI_126({ -- 3543
				pattern = ____temp_122, -- 3544
				docSource = ____temp_123, -- 3545
				docLanguage = ____temp_124, -- 3546
				programmingLanguage = ____temp_125, -- 3547
				limit = ____math_min_121( -- 3548
					SEARCH_DORA_API_LIMIT_MAX, -- 3548
					____math_max_120( -- 3548
						1, -- 3548
						__TS__Number(____params_limit_119) -- 3548
					) -- 3548
				), -- 3548
				useRegex = params.useRegex, -- 3549
				caseSensitive = false, -- 3550
				includeContent = true, -- 3551
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3552
			})) -- 3552
			return ____awaiter_resolve(nil, result) -- 3552
		end -- 3552
		if action.tool == "glob_files" then -- 3552
			local ____Tools_listFiles_133 = Tools.listFiles -- 3557
			local ____shared_workingDir_130 = shared.workingDir -- 3558
			local ____temp_131 = params.path or "" -- 3559
			local ____params_globs_132 = params.globs -- 3560
			local ____math_max_129 = math.max -- 3561
			local ____math_floor_128 = math.floor -- 3561
			local ____params_maxEntries_127 = params.maxEntries -- 3561
			if ____params_maxEntries_127 == nil then -- 3561
				____params_maxEntries_127 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3561
			end -- 3561
			local result = ____Tools_listFiles_133({ -- 3557
				workDir = ____shared_workingDir_130, -- 3558
				path = ____temp_131, -- 3559
				globs = ____params_globs_132, -- 3560
				maxEntries = ____math_max_129( -- 3561
					1, -- 3561
					____math_floor_128(__TS__Number(____params_maxEntries_127)) -- 3561
				) -- 3561
			}) -- 3561
			return ____awaiter_resolve(nil, result) -- 3561
		end -- 3561
		if action.tool == "delete_file" then -- 3561
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3566
			if __TS__StringTrim(targetFile) == "" then -- 3566
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3566
			end -- 3566
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3570
			if not result.success then -- 3570
				return ____awaiter_resolve(nil, result) -- 3570
			end -- 3570
			return ____awaiter_resolve(nil, { -- 3570
				success = true, -- 3578
				changed = true, -- 3579
				mode = "delete", -- 3580
				checkpointId = result.checkpointId, -- 3581
				checkpointSeq = result.checkpointSeq, -- 3582
				files = {{path = targetFile, op = "delete"}} -- 3583
			}) -- 3583
		end -- 3583
		if action.tool == "build" then -- 3583
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3587
			return ____awaiter_resolve(nil, result) -- 3587
		end -- 3587
		if action.tool == "spawn_sub_agent" then -- 3587
			if not shared.spawnSubAgent then -- 3587
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3587
			end -- 3587
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3587
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3587
			end -- 3587
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3600
				params.filesHint, -- 3601
				function(____, item) return type(item) == "string" end -- 3601
			) or nil -- 3601
			local result = __TS__Await(shared.spawnSubAgent({ -- 3603
				parentSessionId = shared.sessionId, -- 3604
				projectRoot = shared.workingDir, -- 3605
				title = type(params.title) == "string" and params.title or "Sub", -- 3606
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3607
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3608
				filesHint = filesHint -- 3609
			})) -- 3609
			if not result.success then -- 3609
				return ____awaiter_resolve(nil, result) -- 3609
			end -- 3609
			return ____awaiter_resolve(nil, { -- 3609
				success = true, -- 3615
				sessionId = result.sessionId, -- 3616
				taskId = result.taskId, -- 3617
				title = result.title, -- 3618
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3619
			}) -- 3619
		end -- 3619
		if action.tool == "list_sub_agents" then -- 3619
			if not shared.listSubAgents then -- 3619
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3619
			end -- 3619
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3619
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3619
			end -- 3619
			local result = __TS__Await(shared.listSubAgents({ -- 3629
				sessionId = shared.sessionId, -- 3630
				projectRoot = shared.workingDir, -- 3631
				status = type(params.status) == "string" and params.status or nil, -- 3632
				limit = type(params.limit) == "number" and params.limit or nil, -- 3633
				offset = type(params.offset) == "number" and params.offset or nil, -- 3634
				query = type(params.query) == "string" and params.query or nil -- 3635
			})) -- 3635
			return ____awaiter_resolve(nil, result) -- 3635
		end -- 3635
		if action.tool == "edit_file" then -- 3635
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3640
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3643
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3644
			if __TS__StringTrim(path) == "" then -- 3644
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3644
			end -- 3644
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3646
			return ____awaiter_resolve( -- 3646
				nil, -- 3646
				actionNode:exec({ -- 3647
					path = path, -- 3648
					oldStr = oldStr, -- 3649
					newStr = newStr, -- 3650
					taskId = shared.taskId, -- 3651
					workDir = shared.workingDir -- 3652
				}) -- 3652
			) -- 3652
		end -- 3652
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3652
	end) -- 3652
end -- 3652
function emitAgentTaskFinishEvent(shared, success, message) -- 3838
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3839
	emitAgentEvent(shared, { -- 3845
		type = "task_finished", -- 3846
		sessionId = shared.sessionId, -- 3847
		taskId = shared.taskId, -- 3848
		success = result.success, -- 3849
		message = result.message, -- 3850
		steps = result.steps -- 3851
	}) -- 3851
	return result -- 3853
end -- 3853
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
local HISTORY_READ_FILE_MAX_CHARS = 12000 -- 668
local HISTORY_READ_FILE_MAX_LINES = 300 -- 669
READ_FILE_DEFAULT_LIMIT = 300 -- 670
local HISTORY_SEARCH_FILES_MAX_MATCHES = 20 -- 671
local HISTORY_SEARCH_DORA_API_MAX_MATCHES = 12 -- 672
local HISTORY_LIST_FILES_MAX_ENTRIES = 200 -- 673
local HISTORY_BUILD_MAX_MESSAGES = 50 -- 674
local HISTORY_BUILD_MESSAGE_MAX_CHARS = 1200 -- 675
SEARCH_DORA_API_LIMIT_MAX = 20 -- 676
SEARCH_FILES_LIMIT_DEFAULT = 20 -- 677
LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 678
SEARCH_PREVIEW_CONTEXT = 80 -- 679
local AGENT_DEFAULT_MAX_STEPS = 100 -- 680
local AGENT_DEFAULT_LLM_MAX_TRY = 5 -- 681
local AGENT_DEFAULT_LLM_TEMPERATURE = 0.1 -- 682
local AGENT_DEFAULT_LLM_MAX_TOKENS = 8192 -- 683
local function buildLLMOptions(llmConfig, overrides) -- 685
	local options = {temperature = llmConfig.temperature or AGENT_DEFAULT_LLM_TEMPERATURE, max_tokens = llmConfig.maxTokens or AGENT_DEFAULT_LLM_MAX_TOKENS} -- 686
	if llmConfig.reasoningEffort then -- 686
		options.reasoning_effort = llmConfig.reasoningEffort -- 691
	end -- 691
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 693
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 693
		__TS__Delete(merged, "reasoning_effort") -- 698
	else -- 698
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 700
	end -- 700
	return merged -- 702
end -- 685
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 765
	local messagesTokens = 0 -- 772
	do -- 772
		local i = 0 -- 773
		while i < #messages do -- 773
			local message = messages[i + 1] -- 774
			messagesTokens = messagesTokens + 8 -- 775
			messagesTokens = messagesTokens + estimateTextTokens(message.role or "") -- 776
			messagesTokens = messagesTokens + estimateTextTokens(message.content or "") -- 777
			messagesTokens = messagesTokens + estimateTextTokens(message.name or "") -- 778
			messagesTokens = messagesTokens + estimateTextTokens(message.tool_call_id or "") -- 779
			messagesTokens = messagesTokens + estimateTextTokens(message.reasoning_content or "") -- 780
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 781
			messagesTokens = messagesTokens + estimateTextTokens(toolCallsText or "") -- 782
			i = i + 1 -- 773
		end -- 773
	end -- 773
	local optionsText = safeJsonEncode(options) -- 784
	local optionsTokens = optionsText and estimateTextTokens(optionsText) or 0 -- 785
	local contextWindow = math.max(64000, shared.llmConfig.contextWindow) -- 786
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 787
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 792
		1024, -- 794
		math.floor(contextWindow * 0.2) -- 794
	) -- 794
	local structuralOverhead = math.max(256, #messages * 16) -- 795
	local usedTokens = messagesTokens + optionsTokens + structuralOverhead -- 796
	local maxTokens = math.max(512, contextWindow - reservedOutputTokens) -- 797
	emitAgentEvent( -- 798
		shared, -- 798
		{ -- 798
			type = "metrics_updated", -- 799
			sessionId = shared.sessionId, -- 800
			taskId = shared.taskId, -- 801
			step = step, -- 802
			metrics = {context = { -- 803
				usedTokens = usedTokens, -- 805
				maxTokens = maxTokens, -- 806
				ratio = math.max( -- 807
					0, -- 807
					math.min(1, usedTokens / maxTokens) -- 807
				), -- 807
				messagesTokens = messagesTokens, -- 808
				optionsTokens = optionsTokens, -- 809
				reservedOutputTokens = reservedOutputTokens, -- 810
				structuralOverhead = structuralOverhead, -- 811
				contextWindow = contextWindow, -- 812
				source = "llm_input_estimate", -- 813
				updatedAt = os.time(), -- 814
				phase = phase, -- 815
				step = step -- 816
			}} -- 816
		} -- 816
	) -- 816
end -- 765
local function emitAgentStartEvent(shared, action) -- 822
	emitAgentEvent(shared, { -- 823
		type = "tool_started", -- 824
		sessionId = shared.sessionId, -- 825
		taskId = shared.taskId, -- 826
		step = action.step, -- 827
		tool = action.tool -- 828
	}) -- 828
end -- 822
local function emitAgentFinishEvent(shared, action) -- 832
	emitAgentEvent(shared, { -- 833
		type = "tool_finished", -- 834
		sessionId = shared.sessionId, -- 835
		taskId = shared.taskId, -- 836
		step = action.step, -- 837
		tool = action.tool, -- 838
		result = action.result or ({}) -- 839
	}) -- 839
end -- 832
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 843
	emitAgentEvent(shared, { -- 844
		type = "assistant_message_updated", -- 845
		sessionId = shared.sessionId, -- 846
		taskId = shared.taskId, -- 847
		step = shared.step + 1, -- 848
		content = content, -- 849
		reasoningContent = reasoningContent -- 850
	}) -- 850
end -- 843
local function getMemoryCompressionStartReason(shared) -- 854
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 855
end -- 854
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 860
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 861
end -- 860
local function getMemoryCompressionFailureReason(shared, ____error) -- 866
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 867
end -- 866
local function summarizeHistoryEntryPreview(text, maxChars) -- 872
	if maxChars == nil then -- 872
		maxChars = 180 -- 872
	end -- 872
	local trimmed = __TS__StringTrim(text) -- 873
	if trimmed == "" then -- 873
		return "" -- 874
	end -- 874
	return truncateText(trimmed, maxChars) -- 875
end -- 872
local function getMaxStepsReachedReason(shared) -- 883
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 884
end -- 883
local function getFailureSummaryFallback(shared, ____error) -- 889
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 890
end -- 889
local function finalizeAgentFailure(shared, ____error) -- 895
	if shared.stopToken.stopped then -- 895
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 897
		return emitAgentTaskFinishEvent( -- 898
			shared, -- 898
			false, -- 898
			getCancelledReason(shared) -- 898
		) -- 898
	end -- 898
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 900
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 901
end -- 895
local function getPromptCommand(prompt) -- 904
	local trimmed = __TS__StringTrim(prompt) -- 905
	if trimmed == "/compact" then -- 905
		return "compact" -- 906
	end -- 906
	if trimmed == "/clear" then -- 906
		return "clear" -- 907
	end -- 907
	return nil -- 908
end -- 904
function ____exports.truncateAgentUserPrompt(prompt) -- 911
	if not prompt then -- 911
		return "" -- 912
	end -- 912
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 912
		return prompt -- 913
	end -- 913
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 914
	if offset == nil then -- 914
		return prompt -- 915
	end -- 915
	return string.sub(prompt, 1, offset - 1) -- 916
end -- 911
local function canWriteStepLLMDebug(shared, stepId) -- 919
	if stepId == nil then -- 919
		stepId = shared.step + 1 -- 919
	end -- 919
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 920
end -- 919
local function ensureDirRecursive(dir) -- 927
	if not dir then -- 927
		return false -- 928
	end -- 928
	if Content:exist(dir) then -- 928
		return Content:isdir(dir) -- 929
	end -- 929
	local parent = Path:getPath(dir) -- 930
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 930
		return false -- 932
	end -- 932
	return Content:mkdir(dir) -- 934
end -- 927
local function encodeDebugJSON(value) -- 937
	local text, err = safeJsonEncode(value) -- 938
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 939
end -- 937
local function getStepLLMDebugDir(shared) -- 942
	return Path( -- 943
		shared.workingDir, -- 944
		".agent", -- 945
		tostring(shared.sessionId), -- 946
		tostring(shared.taskId) -- 947
	) -- 947
end -- 942
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 951
	return Path( -- 952
		getStepLLMDebugDir(shared), -- 952
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 952
	) -- 952
end -- 951
local function getLatestStepLLMDebugSeq(shared, stepId) -- 955
	if not canWriteStepLLMDebug(shared, stepId) then -- 955
		return 0 -- 956
	end -- 956
	local dir = getStepLLMDebugDir(shared) -- 957
	if not Content:exist(dir) or not Content:isdir(dir) then -- 957
		return 0 -- 958
	end -- 958
	local latest = 0 -- 959
	for ____, file in ipairs(Content:getFiles(dir)) do -- 960
		do -- 960
			local name = Path:getFilename(file) -- 961
			local seqText = string.match( -- 962
				name, -- 962
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 962
			) -- 962
			if seqText ~= nil then -- 962
				latest = math.max( -- 964
					latest, -- 964
					tonumber(seqText) -- 964
				) -- 964
				goto __continue127 -- 965
			end -- 965
			local legacyMatch = string.match( -- 967
				name, -- 967
				("^" .. tostring(stepId)) .. "_in%.md$" -- 967
			) -- 967
			if legacyMatch ~= nil then -- 967
				latest = math.max(latest, 1) -- 969
			end -- 969
		end -- 969
		::__continue127:: -- 969
	end -- 969
	return latest -- 972
end -- 955
local function writeStepLLMDebugFile(path, content) -- 975
	if not Content:save(path, content) then -- 975
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 977
		return false -- 978
	end -- 978
	return true -- 980
end -- 975
local function createStepLLMDebugPair(shared, stepId, inContent) -- 983
	if not canWriteStepLLMDebug(shared, stepId) then -- 983
		return 0 -- 984
	end -- 984
	local dir = getStepLLMDebugDir(shared) -- 985
	if not ensureDirRecursive(dir) then -- 985
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 987
		return 0 -- 988
	end -- 988
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 990
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 991
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 992
	if not writeStepLLMDebugFile(inPath, inContent) then -- 992
		return 0 -- 994
	end -- 994
	writeStepLLMDebugFile(outPath, "") -- 996
	return seq -- 997
end -- 983
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 1000
	if not canWriteStepLLMDebug(shared, stepId) then -- 1000
		return -- 1001
	end -- 1001
	local dir = getStepLLMDebugDir(shared) -- 1002
	if not ensureDirRecursive(dir) then -- 1002
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 1004
		return -- 1005
	end -- 1005
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 1007
	if latestSeq <= 0 then -- 1007
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 1009
		writeStepLLMDebugFile(outPath, content) -- 1010
		return -- 1011
	end -- 1011
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 1013
	writeStepLLMDebugFile(outPath, content) -- 1014
end -- 1000
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 1017
	if not canWriteStepLLMDebug(shared, stepId) then -- 1017
		return -- 1018
	end -- 1018
	local sections = { -- 1019
		"# LLM Input", -- 1020
		"session_id: " .. tostring(shared.sessionId), -- 1021
		"task_id: " .. tostring(shared.taskId), -- 1022
		"step_id: " .. tostring(stepId), -- 1023
		"phase: " .. phase, -- 1024
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1025
		"## Options", -- 1026
		"```json", -- 1027
		encodeDebugJSON(options), -- 1028
		"```" -- 1029
	} -- 1029
	do -- 1029
		local i = 0 -- 1031
		while i < #messages do -- 1031
			local message = messages[i + 1] -- 1032
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 1033
			sections[#sections + 1] = encodeDebugJSON(message) -- 1034
			i = i + 1 -- 1031
		end -- 1031
	end -- 1031
	createStepLLMDebugPair( -- 1036
		shared, -- 1036
		stepId, -- 1036
		table.concat(sections, "\n") -- 1036
	) -- 1036
end -- 1017
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 1039
	if not canWriteStepLLMDebug(shared, stepId) then -- 1039
		return -- 1040
	end -- 1040
	local ____array_2 = __TS__SparseArrayNew( -- 1040
		"# LLM Output", -- 1042
		"session_id: " .. tostring(shared.sessionId), -- 1043
		"task_id: " .. tostring(shared.taskId), -- 1044
		"step_id: " .. tostring(stepId), -- 1045
		"phase: " .. phase, -- 1046
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 1047
		table.unpack(meta and ({ -- 1048
			"## Meta", -- 1048
			"```json", -- 1048
			encodeDebugJSON(meta), -- 1048
			"```" -- 1048
		}) or ({})) -- 1048
	) -- 1048
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 1048
	local sections = {__TS__SparseArraySpread(____array_2)} -- 1041
	updateLatestStepLLMDebugOutput( -- 1052
		shared, -- 1052
		stepId, -- 1052
		table.concat(sections, "\n") -- 1052
	) -- 1052
end -- 1039
local function toJson(value) -- 1055
	local text, err = safeJsonEncode(value) -- 1056
	if text ~= nil then -- 1056
		return text -- 1057
	end -- 1057
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 1058
end -- 1055
local function utf8TakeHead(text, maxChars) -- 1068
	if maxChars <= 0 or text == "" then -- 1068
		return "" -- 1069
	end -- 1069
	local nextPos = utf8.offset(text, maxChars + 1) -- 1070
	if nextPos == nil then -- 1070
		return text -- 1071
	end -- 1071
	return string.sub(text, 1, nextPos - 1) -- 1072
end -- 1068
local function limitReadContentForHistory(content, tool) -- 1089
	local lines = __TS__StringSplit(content, "\n") -- 1090
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 1091
	local limitedByLines = overLineLimit and table.concat( -- 1092
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 1093
		"\n" -- 1093
	) or content -- 1093
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 1093
		return content -- 1096
	end -- 1096
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 1098
	local reasons = {} -- 1101
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 1101
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 1102
	end -- 1102
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 1102
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 1103
	end -- 1103
	local hint = "Narrow the requested line range." -- 1104
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 1105
end -- 1089
local function summarizeEditTextParamForHistory(value, key) -- 1108
	if type(value) ~= "string" then -- 1108
		return nil -- 1109
	end -- 1109
	local text = value -- 1110
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 1111
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 1112
end -- 1108
local function sanitizeReadResultForHistory(tool, result) -- 1120
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 1120
		return result -- 1122
	end -- 1122
	local clone = {} -- 1124
	for key in pairs(result) do -- 1125
		clone[key] = result[key] -- 1126
	end -- 1126
	clone.content = limitReadContentForHistory(result.content, tool) -- 1128
	return clone -- 1129
end -- 1120
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 1132
	local shown = math.min(#items, maxItems) -- 1136
	local out = {} -- 1137
	do -- 1137
		local i = 0 -- 1138
		while i < shown do -- 1138
			local row = items[i + 1] -- 1139
			out[#out + 1] = { -- 1140
				file = row.file, -- 1141
				line = row.line, -- 1142
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1143
			} -- 1143
			i = i + 1 -- 1138
		end -- 1138
	end -- 1138
	return out -- 1148
end -- 1132
local function sanitizeSearchResultForHistory(tool, result) -- 1151
	if result.success ~= true or not isArray(result.results) then -- 1151
		return result -- 1155
	end -- 1155
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1155
		return result -- 1156
	end -- 1156
	local clone = {} -- 1157
	for key in pairs(result) do -- 1158
		clone[key] = result[key] -- 1159
	end -- 1159
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 1161
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1162
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1162
		local grouped = result.groupedResults -- 1167
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 1168
		local sanitizedGroups = {} -- 1169
		do -- 1169
			local i = 0 -- 1170
			while i < shown do -- 1170
				local row = grouped[i + 1] -- 1171
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1172
					file = row.file, -- 1173
					totalMatches = row.totalMatches, -- 1174
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1175
				} -- 1175
				i = i + 1 -- 1170
			end -- 1170
		end -- 1170
		clone.groupedResults = sanitizedGroups -- 1180
	end -- 1180
	return clone -- 1182
end -- 1151
local function sanitizeListFilesResultForHistory(result) -- 1185
	if result.success ~= true or not isArray(result.files) then -- 1185
		return result -- 1186
	end -- 1186
	local clone = {} -- 1187
	for key in pairs(result) do -- 1188
		clone[key] = result[key] -- 1189
	end -- 1189
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1191
	return clone -- 1192
end -- 1185
local function sanitizeBuildResultForHistory(result) -- 1195
	if not isArray(result.messages) then -- 1195
		return result -- 1196
	end -- 1196
	local clone = {} -- 1197
	for key in pairs(result) do -- 1198
		clone[key] = result[key] -- 1199
	end -- 1199
	local messages = result.messages -- 1201
	local shown = math.min(#messages, HISTORY_BUILD_MAX_MESSAGES) -- 1202
	local sanitized = {} -- 1203
	do -- 1203
		local i = 0 -- 1204
		while i < shown do -- 1204
			local item = messages[i + 1] -- 1205
			local next = {} -- 1206
			for key in pairs(item) do -- 1207
				local value = item[key] -- 1208
				next[key] = key == "message" and type(value) == "string" and truncateText(value, HISTORY_BUILD_MESSAGE_MAX_CHARS) or value -- 1209
			end -- 1209
			sanitized[#sanitized + 1] = next -- 1213
			i = i + 1 -- 1204
		end -- 1204
	end -- 1204
	clone.messages = sanitized -- 1215
	if #messages > shown then -- 1215
		clone.truncatedMessages = #messages - shown -- 1217
	end -- 1217
	return clone -- 1219
end -- 1195
local function sanitizeActionParamsForHistory(tool, params) -- 1222
	if tool ~= "edit_file" then -- 1222
		return params -- 1223
	end -- 1223
	local clone = {} -- 1224
	for key in pairs(params) do -- 1225
		if key == "old_str" then -- 1225
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1227
		elseif key == "new_str" then -- 1227
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1229
		else -- 1229
			clone[key] = params[key] -- 1231
		end -- 1231
	end -- 1231
	return clone -- 1234
end -- 1222
local function isToolAllowedForRole(role, tool) -- 1279
	return __TS__ArrayIndexOf( -- 1280
		getAllowedToolsForRole(role), -- 1280
		tool -- 1280
	) >= 0 -- 1280
end -- 1279
local PRE_EXEC_SAFE_TOOLS = { -- 1283
	"read_file", -- 1284
	"grep_files", -- 1285
	"search_dora_api", -- 1286
	"glob_files", -- 1287
	"list_sub_agents" -- 1288
} -- 1288
local function canPreExecuteTool(tool) -- 1291
	return __TS__ArrayIndexOf(PRE_EXEC_SAFE_TOOLS, tool) >= 0 -- 1292
end -- 1291
local function clearPreExecutedResults(shared) -- 1295
	shared.preExecutedResults = nil -- 1296
end -- 1295
local function startPreExecutedToolAction(shared, action) -- 1299
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1299
		local ____try = __TS__AsyncAwaiter(function() -- 1299
			return ____awaiter_resolve( -- 1299
				nil, -- 1299
				__TS__Await(executeToolAction(shared, action)) -- 1301
			) -- 1301
		end) -- 1301
		__TS__Await(____try.catch( -- 1300
			____try, -- 1300
			function(____, err) -- 1300
				local message = tostring(err) -- 1303
				Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1304
				return ____awaiter_resolve(nil, {success = false, message = message}) -- 1304
			end -- 1304
		)) -- 1304
	end) -- 1304
end -- 1299
local function executeToolActionWithPreExecution(shared, action) -- 1309
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1309
		local ____opt_9 = shared.preExecutedResults -- 1309
		local preResult = ____opt_9 and ____opt_9:get(action.toolCallId) -- 1310
		if preResult then -- 1310
			Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1312
			local ____opt_11 = shared.preExecutedResults -- 1312
			if ____opt_11 ~= nil then -- 1312
				____opt_11:delete(action.toolCallId) -- 1313
			end -- 1313
			return ____awaiter_resolve( -- 1313
				nil, -- 1313
				__TS__Await(preResult) -- 1314
			) -- 1314
		end -- 1314
		return ____awaiter_resolve( -- 1314
			nil, -- 1314
			executeToolAction(shared, action) -- 1316
		) -- 1316
	end) -- 1316
end -- 1309
local function maybeCompressHistory(shared) -- 1319
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1319
		local ____shared_13 = shared -- 1320
		local memory = ____shared_13.memory -- 1320
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1321
		local changed = false -- 1322
		do -- 1322
			local round = 0 -- 1323
			while round < maxRounds do -- 1323
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1324
				local activeMessages = getActiveConversationMessages(shared) -- 1325
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1329
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 1329
					if changed then -- 1329
						persistHistoryState(shared) -- 1338
					end -- 1338
					return ____awaiter_resolve(nil) -- 1338
				end -- 1338
				local compressionRound = round + 1 -- 1342
				shared.step = shared.step + 1 -- 1343
				local stepId = shared.step -- 1344
				local pendingMessages = #activeMessages -- 1345
				emitAgentEvent( -- 1346
					shared, -- 1346
					{ -- 1346
						type = "memory_compression_started", -- 1347
						sessionId = shared.sessionId, -- 1348
						taskId = shared.taskId, -- 1349
						step = stepId, -- 1350
						tool = "compress_memory", -- 1351
						reason = getMemoryCompressionStartReason(shared), -- 1352
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1353
					} -- 1353
				) -- 1353
				local result = __TS__Await(memory.compressor:compress( -- 1359
					activeMessages, -- 1360
					shared.llmOptions, -- 1361
					shared.llmMaxTry, -- 1362
					shared.decisionMode, -- 1363
					{ -- 1364
						onInput = function(____, phase, messages, options) -- 1365
							saveStepLLMDebugInput( -- 1366
								shared, -- 1366
								stepId, -- 1366
								phase, -- 1366
								messages, -- 1366
								options -- 1366
							) -- 1366
						end, -- 1365
						onOutput = function(____, phase, text, meta) -- 1368
							saveStepLLMDebugOutput( -- 1369
								shared, -- 1369
								stepId, -- 1369
								phase, -- 1369
								text, -- 1369
								meta -- 1369
							) -- 1369
						end -- 1368
					}, -- 1368
					"default", -- 1372
					systemPrompt, -- 1373
					toolDefinitions -- 1374
				)) -- 1374
				if not (result and result.success and result.compressedCount > 0) then -- 1374
					emitAgentEvent( -- 1377
						shared, -- 1377
						{ -- 1377
							type = "memory_compression_finished", -- 1378
							sessionId = shared.sessionId, -- 1379
							taskId = shared.taskId, -- 1380
							step = stepId, -- 1381
							tool = "compress_memory", -- 1382
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1383
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1387
						} -- 1387
					) -- 1387
					if changed then -- 1387
						persistHistoryState(shared) -- 1395
					end -- 1395
					return ____awaiter_resolve(nil) -- 1395
				end -- 1395
				local effectiveCompressedCount = math.max( -- 1399
					0, -- 1400
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1401
				) -- 1401
				if effectiveCompressedCount <= 0 then -- 1401
					if changed then -- 1401
						persistHistoryState(shared) -- 1405
					end -- 1405
					return ____awaiter_resolve(nil) -- 1405
				end -- 1405
				emitAgentEvent( -- 1409
					shared, -- 1409
					{ -- 1409
						type = "memory_compression_finished", -- 1410
						sessionId = shared.sessionId, -- 1411
						taskId = shared.taskId, -- 1412
						step = stepId, -- 1413
						tool = "compress_memory", -- 1414
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1415
						result = { -- 1416
							success = true, -- 1417
							round = compressionRound, -- 1418
							compressedCount = effectiveCompressedCount, -- 1419
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1420
						} -- 1420
					} -- 1420
				) -- 1420
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1423
				changed = true -- 1424
				Log( -- 1425
					"Info", -- 1425
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1425
				) -- 1425
				round = round + 1 -- 1323
			end -- 1323
		end -- 1323
		if changed then -- 1323
			persistHistoryState(shared) -- 1428
		end -- 1428
	end) -- 1428
end -- 1319
local function compactAllHistory(shared) -- 1432
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1432
		local ____shared_20 = shared -- 1433
		local memory = ____shared_20.memory -- 1433
		local rounds = 0 -- 1434
		local totalCompressed = 0 -- 1435
		while getActiveRealMessageCount(shared) > 0 do -- 1435
			if shared.stopToken.stopped then -- 1435
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1438
				return ____awaiter_resolve( -- 1438
					nil, -- 1438
					emitAgentTaskFinishEvent( -- 1439
						shared, -- 1439
						false, -- 1439
						getCancelledReason(shared) -- 1439
					) -- 1439
				) -- 1439
			end -- 1439
			rounds = rounds + 1 -- 1441
			shared.step = shared.step + 1 -- 1442
			local stepId = shared.step -- 1443
			local activeMessages = getActiveConversationMessages(shared) -- 1444
			local pendingMessages = #activeMessages -- 1445
			emitAgentEvent( -- 1446
				shared, -- 1446
				{ -- 1446
					type = "memory_compression_started", -- 1447
					sessionId = shared.sessionId, -- 1448
					taskId = shared.taskId, -- 1449
					step = stepId, -- 1450
					tool = "compress_memory", -- 1451
					reason = getMemoryCompressionStartReason(shared), -- 1452
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1453
				} -- 1453
			) -- 1453
			local result = __TS__Await(memory.compressor:compress( -- 1460
				activeMessages, -- 1461
				shared.llmOptions, -- 1462
				shared.llmMaxTry, -- 1463
				shared.decisionMode, -- 1464
				{ -- 1465
					onInput = function(____, phase, messages, options) -- 1466
						saveStepLLMDebugInput( -- 1467
							shared, -- 1467
							stepId, -- 1467
							phase, -- 1467
							messages, -- 1467
							options -- 1467
						) -- 1467
					end, -- 1466
					onOutput = function(____, phase, text, meta) -- 1469
						saveStepLLMDebugOutput( -- 1470
							shared, -- 1470
							stepId, -- 1470
							phase, -- 1470
							text, -- 1470
							meta -- 1470
						) -- 1470
					end -- 1469
				}, -- 1469
				"budget_max" -- 1473
			)) -- 1473
			if not (result and result.success and result.compressedCount > 0) then -- 1473
				emitAgentEvent( -- 1476
					shared, -- 1476
					{ -- 1476
						type = "memory_compression_finished", -- 1477
						sessionId = shared.sessionId, -- 1478
						taskId = shared.taskId, -- 1479
						step = stepId, -- 1480
						tool = "compress_memory", -- 1481
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1482
						result = { -- 1486
							success = false, -- 1487
							rounds = rounds, -- 1488
							error = result and result.error or "compression returned no changes", -- 1489
							compressedCount = result and result.compressedCount or 0, -- 1490
							fullCompaction = true -- 1491
						} -- 1491
					} -- 1491
				) -- 1491
				return ____awaiter_resolve( -- 1491
					nil, -- 1491
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1494
				) -- 1494
			end -- 1494
			local effectiveCompressedCount = math.max( -- 1499
				0, -- 1500
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1501
			) -- 1501
			if effectiveCompressedCount <= 0 then -- 1501
				return ____awaiter_resolve( -- 1501
					nil, -- 1501
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1504
				) -- 1504
			end -- 1504
			emitAgentEvent( -- 1511
				shared, -- 1511
				{ -- 1511
					type = "memory_compression_finished", -- 1512
					sessionId = shared.sessionId, -- 1513
					taskId = shared.taskId, -- 1514
					step = stepId, -- 1515
					tool = "compress_memory", -- 1516
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1517
					result = { -- 1518
						success = true, -- 1519
						round = rounds, -- 1520
						compressedCount = effectiveCompressedCount, -- 1521
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1522
						fullCompaction = true -- 1523
					} -- 1523
				} -- 1523
			) -- 1523
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1526
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1527
			persistHistoryState(shared) -- 1528
			Log( -- 1529
				"Info", -- 1529
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1529
			) -- 1529
		end -- 1529
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1531
		return ____awaiter_resolve( -- 1531
			nil, -- 1531
			emitAgentTaskFinishEvent( -- 1532
				shared, -- 1533
				true, -- 1534
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1535
			) -- 1535
		) -- 1535
	end) -- 1535
end -- 1432
local function clearSessionHistory(shared) -- 1541
	shared.messages = {} -- 1542
	shared.lastConsolidatedIndex = 0 -- 1543
	shared.carryMessageIndex = nil -- 1544
	persistHistoryState(shared) -- 1545
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1546
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1547
end -- 1541
local function isKnownToolName(name) -- 1556
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1557
end -- 1556
local function appendConversationMessage(shared, message) -- 1650
	local ____shared_messages_29 = shared.messages -- 1650
	____shared_messages_29[#____shared_messages_29 + 1] = __TS__ObjectAssign( -- 1651
		{}, -- 1651
		message, -- 1652
		{ -- 1651
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1653
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1654
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1655
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1656
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1657
		} -- 1657
	) -- 1657
end -- 1650
local function ensureToolCallId(toolCallId) -- 1661
	if toolCallId and toolCallId ~= "" then -- 1661
		return toolCallId -- 1662
	end -- 1662
	return createLocalToolCallId() -- 1663
end -- 1661
local function appendToolResultMessage(shared, action) -- 1666
	appendConversationMessage( -- 1667
		shared, -- 1667
		{ -- 1667
			role = "tool", -- 1668
			tool_call_id = action.toolCallId, -- 1669
			name = action.tool, -- 1670
			content = action.result and toJson(action.result) or "" -- 1671
		} -- 1671
	) -- 1671
end -- 1666
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1675
	appendConversationMessage( -- 1681
		shared, -- 1681
		{ -- 1681
			role = "assistant", -- 1682
			content = content or "", -- 1683
			reasoning_content = reasoningContent, -- 1684
			tool_calls = __TS__ArrayMap( -- 1685
				actions, -- 1685
				function(____, action) return { -- 1685
					id = action.toolCallId, -- 1686
					type = "function", -- 1687
					["function"] = { -- 1688
						name = action.tool, -- 1689
						arguments = toJson(action.params) -- 1690
					} -- 1690
				} end -- 1690
			) -- 1690
		} -- 1690
	) -- 1690
end -- 1675
local function parseXMLToolCallObjectFromText(text) -- 1696
	local children = parseXMLObjectFromText(text, "tool_call") -- 1697
	if not children.success then -- 1697
		return children -- 1698
	end -- 1698
	local rawObj = children.obj -- 1699
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1700
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1701
	if not params.success then -- 1701
		return {success = false, message = params.message} -- 1705
	end -- 1705
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1707
end -- 1696
local function llm(shared, messages, phase) -- 1727
	if phase == nil then -- 1727
		phase = "decision_xml" -- 1730
	end -- 1730
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1730
		local stepId = shared.step + 1 -- 1732
		emitLLMContextMetrics( -- 1733
			shared, -- 1733
			stepId, -- 1733
			phase, -- 1733
			messages, -- 1733
			shared.llmOptions -- 1733
		) -- 1733
		saveStepLLMDebugInput( -- 1734
			shared, -- 1734
			stepId, -- 1734
			phase, -- 1734
			messages, -- 1734
			shared.llmOptions -- 1734
		) -- 1734
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1735
		if res.success then -- 1735
			local ____opt_32 = res.response.choices -- 1735
			local ____opt_30 = ____opt_32 and ____opt_32[1] -- 1735
			local message = ____opt_30 and ____opt_30.message -- 1737
			local text = message and message.content -- 1738
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1739
			if text then -- 1739
				saveStepLLMDebugOutput( -- 1743
					shared, -- 1743
					stepId, -- 1743
					phase, -- 1743
					text, -- 1743
					{success = true} -- 1743
				) -- 1743
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1743
			else -- 1743
				saveStepLLMDebugOutput( -- 1746
					shared, -- 1746
					stepId, -- 1746
					phase, -- 1746
					"empty LLM response", -- 1746
					{success = false} -- 1746
				) -- 1746
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1746
			end -- 1746
		else -- 1746
			saveStepLLMDebugOutput( -- 1750
				shared, -- 1750
				stepId, -- 1750
				phase, -- 1750
				res.raw or res.message, -- 1750
				{success = false} -- 1750
			) -- 1750
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1750
		end -- 1750
	end) -- 1750
end -- 1727
local function isDecisionBatchSuccess(result) -- 1774
	return result.kind == "batch" -- 1775
end -- 1774
local function parseDecisionObject(rawObj) -- 1778
	if type(rawObj.tool) ~= "string" then -- 1778
		return {success = false, message = "missing tool"} -- 1779
	end -- 1779
	local tool = rawObj.tool -- 1780
	if not isKnownToolName(tool) then -- 1780
		return {success = false, message = "unknown tool: " .. tool} -- 1782
	end -- 1782
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1784
	if tool ~= "finish" and (not reason or reason == "") then -- 1784
		return {success = false, message = tool .. " requires top-level reason"} -- 1788
	end -- 1788
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1790
	return {success = true, tool = tool, params = params, reason = reason} -- 1791
end -- 1778
local function parseDecisionToolCall(functionName, rawObj) -- 1799
	if not isKnownToolName(functionName) then -- 1799
		return {success = false, message = "unknown tool: " .. functionName} -- 1801
	end -- 1801
	if rawObj == nil or rawObj == nil then -- 1801
		return {success = true, tool = functionName, params = {}} -- 1804
	end -- 1804
	if not isRecord(rawObj) then -- 1804
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1807
	end -- 1807
	return {success = true, tool = functionName, params = rawObj} -- 1809
end -- 1799
local function parseToolCallArguments(functionName, argsText) -- 1816
	local trimmedArgs = __TS__StringTrim(argsText) -- 1817
	if trimmedArgs == "" then -- 1817
		return {} -- 1819
	end -- 1819
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 1821
	if err ~= nil or rawObj == nil then -- 1821
		return { -- 1823
			success = false, -- 1824
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1825
			raw = argsText -- 1826
		} -- 1826
	end -- 1826
	local encodedRaw = safeJsonEncode(rawObj) -- 1829
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 1829
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1831
	end -- 1831
	return rawObj -- 1837
end -- 1816
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1840
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1848
	if isRecord(rawArgs) and rawArgs.success == false then -- 1848
		return rawArgs -- 1850
	end -- 1850
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1852
	if not decision.success then -- 1852
		return {success = false, message = decision.message, raw = argsText} -- 1854
	end -- 1854
	local validation = validateDecision(decision.tool, decision.params) -- 1860
	if not validation.success then -- 1860
		return {success = false, message = validation.message, raw = argsText} -- 1862
	end -- 1862
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1862
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1869
	end -- 1869
	decision.params = validation.params -- 1875
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1876
	decision.reason = reason -- 1877
	decision.reasoningContent = reasoningContent -- 1878
	return decision -- 1879
end -- 1840
local function createPreExecutableActionFromStream(shared, toolCall) -- 1882
	local ____opt_38 = toolCall["function"] -- 1882
	local functionName = ____opt_38 and ____opt_38.name -- 1883
	local ____opt_40 = toolCall["function"] -- 1883
	local argsText = ____opt_40 and ____opt_40.arguments or "" -- 1884
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 1885
	if not functionName or not toolCallId then -- 1885
		return nil -- 1886
	end -- 1886
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1887
	if isRecord(rawArgs) and rawArgs.success == false then -- 1887
		return nil -- 1888
	end -- 1888
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1889
	if not decision.success or not canPreExecuteTool(decision.tool) then -- 1889
		return nil -- 1890
	end -- 1890
	local validation = validateDecision(decision.tool, decision.params) -- 1891
	if not validation.success then -- 1891
		return nil -- 1892
	end -- 1892
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1892
		return nil -- 1893
	end -- 1893
	return { -- 1894
		step = shared.step + 1, -- 1895
		toolCallId = toolCallId, -- 1896
		tool = decision.tool, -- 1897
		reason = "", -- 1898
		params = validation.params, -- 1899
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1900
	} -- 1900
end -- 1882
local function createFunctionToolSchema(name, description, properties, required) -- 2040
	if required == nil then -- 2040
		required = {} -- 2044
	end -- 2044
	local parameters = {type = "object", properties = properties} -- 2046
	if #required > 0 then -- 2046
		parameters.required = required -- 2051
	end -- 2051
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 2053
end -- 2040
local function buildDecisionToolSchema(shared) -- 2069
	local allowed = getAllowedToolsForRole(shared.role) -- 2070
	local tools = { -- 2071
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 2072
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 2082
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 2092
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 2100
			path = {type = "string", description = "Base directory or file path to search within."}, -- 2104
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 2105
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 2106
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 2107
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 2108
			limit = {type = "number", description = "Maximum number of results to return."}, -- 2109
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 2110
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 2111
		}, {"pattern"}), -- 2111
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 2115
		createFunctionToolSchema( -- 2124
			"search_dora_api", -- 2125
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 2125
			{ -- 2127
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 2128
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 2129
				programmingLanguage = {type = "string", enum = { -- 2130
					"ts", -- 2132
					"tsx", -- 2132
					"lua", -- 2132
					"yue", -- 2132
					"teal", -- 2132
					"tl", -- 2132
					"wa" -- 2132
				}, description = "Preferred language variant to search."}, -- 2132
				limit = { -- 2135
					type = "number", -- 2135
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 2135
				}, -- 2135
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 2136
			}, -- 2136
			{"pattern"} -- 2138
		), -- 2138
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 2140
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 2147
			"active_or_recent", -- 2151
			"running", -- 2151
			"done", -- 2151
			"failed", -- 2151
			"all" -- 2151
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 2151
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 2157
	} -- 2157
	return __TS__ArrayFilter( -- 2169
		tools, -- 2169
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 2169
	) -- 2169
end -- 2069
local function sanitizeMessagesForLLMInput(messages) -- 2210
	local sanitized = {} -- 2211
	local droppedAssistantToolCalls = 0 -- 2212
	local droppedToolResults = 0 -- 2213
	do -- 2213
		local i = 0 -- 2214
		while i < #messages do -- 2214
			do -- 2214
				local message = messages[i + 1] -- 2215
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2215
					local requiredIds = {} -- 2217
					do -- 2217
						local j = 0 -- 2218
						while j < #message.tool_calls do -- 2218
							local toolCall = message.tool_calls[j + 1] -- 2219
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2220
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2220
								requiredIds[#requiredIds + 1] = id -- 2222
							end -- 2222
							j = j + 1 -- 2218
						end -- 2218
					end -- 2218
					if #requiredIds == 0 then -- 2218
						sanitized[#sanitized + 1] = message -- 2226
						goto __continue338 -- 2227
					end -- 2227
					local matchedIds = {} -- 2229
					local matchedTools = {} -- 2230
					local j = i + 1 -- 2231
					while j < #messages do -- 2231
						local toolMessage = messages[j + 1] -- 2233
						if toolMessage.role ~= "tool" then -- 2233
							break -- 2234
						end -- 2234
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2235
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2235
							matchedIds[toolCallId] = true -- 2237
							matchedTools[#matchedTools + 1] = toolMessage -- 2238
						else -- 2238
							droppedToolResults = droppedToolResults + 1 -- 2240
						end -- 2240
						j = j + 1 -- 2242
					end -- 2242
					local complete = true -- 2244
					do -- 2244
						local j = 0 -- 2245
						while j < #requiredIds do -- 2245
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2245
								complete = false -- 2247
								break -- 2248
							end -- 2248
							j = j + 1 -- 2245
						end -- 2245
					end -- 2245
					if complete then -- 2245
						__TS__ArrayPush( -- 2252
							sanitized, -- 2252
							message, -- 2252
							table.unpack(matchedTools) -- 2252
						) -- 2252
					else -- 2252
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2254
						droppedToolResults = droppedToolResults + #matchedTools -- 2255
					end -- 2255
					i = j - 1 -- 2257
					goto __continue338 -- 2258
				end -- 2258
				if message.role == "tool" then -- 2258
					droppedToolResults = droppedToolResults + 1 -- 2261
					goto __continue338 -- 2262
				end -- 2262
				sanitized[#sanitized + 1] = message -- 2264
			end -- 2264
			::__continue338:: -- 2264
			i = i + 1 -- 2214
		end -- 2214
	end -- 2214
	return sanitized -- 2266
end -- 2210
local function getUnconsolidatedMessages(shared) -- 2269
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2270
end -- 2269
local function getFinalDecisionTurnPrompt(shared) -- 2273
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2274
end -- 2273
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2279
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2279
		return messages -- 2280
	end -- 2280
	local next = __TS__ArrayMap( -- 2281
		messages, -- 2281
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2281
	) -- 2281
	do -- 2281
		local i = #next - 1 -- 2282
		while i >= 0 do -- 2282
			do -- 2282
				local message = next[i + 1] -- 2283
				if message.role ~= "assistant" and message.role ~= "user" then -- 2283
					goto __continue360 -- 2284
				end -- 2284
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2285
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2286
				return next -- 2289
			end -- 2289
			::__continue360:: -- 2289
			i = i - 1 -- 2282
		end -- 2282
	end -- 2282
	next[#next + 1] = {role = "user", content = prompt} -- 2291
	return next -- 2292
end -- 2279
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2295
	if attempt == nil then -- 2295
		attempt = 1 -- 2298
	end -- 2298
	if decisionMode == nil then -- 2298
		decisionMode = shared.decisionMode -- 2300
	end -- 2300
	local messages = { -- 2302
		{ -- 2303
			role = "system", -- 2303
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2303
		}, -- 2303
		table.unpack(getUnconsolidatedMessages(shared)) -- 2304
	} -- 2304
	if shared.step + 1 >= shared.maxSteps then -- 2304
		messages = appendPromptToLatestDecisionMessage( -- 2307
			messages, -- 2307
			getFinalDecisionTurnPrompt(shared) -- 2307
		) -- 2307
	end -- 2307
	if lastError and lastError ~= "" then -- 2307
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2310
		messages[#messages + 1] = { -- 2313
			role = "user", -- 2314
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2315
		} -- 2315
	end -- 2315
	return messages -- 2322
end -- 2295
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2329
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2336
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2337
	local repairPrompt = replacePromptVars( -- 2345
		shared.promptPack.xmlDecisionRepairPrompt, -- 2345
		{ -- 2345
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2346
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2347
			CANDIDATE_SECTION = candidateSection, -- 2348
			LAST_ERROR = lastError, -- 2349
			ATTEMPT = tostring(attempt) -- 2350
		} -- 2350
	) -- 2350
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2352
end -- 2329
local function tryParseAndValidateDecision(rawText) -- 2364
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2365
	if not parsed.success then -- 2365
		return {success = false, message = parsed.message, raw = rawText} -- 2367
	end -- 2367
	local decision = parseDecisionObject(parsed.obj) -- 2369
	if not decision.success then -- 2369
		return {success = false, message = decision.message, raw = rawText} -- 2371
	end -- 2371
	local validation = validateDecision(decision.tool, decision.params) -- 2373
	if not validation.success then -- 2373
		return {success = false, message = validation.message, raw = rawText} -- 2375
	end -- 2375
	decision.params = validation.params -- 2377
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2378
	return decision -- 2379
end -- 2364
local function normalizeLineEndings(text) -- 2382
	local res = string.gsub(text, "\r\n", "\n") -- 2383
	res = string.gsub(res, "\r", "\n") -- 2384
	return res -- 2385
end -- 2382
local function countOccurrences(text, searchStr) -- 2388
	if searchStr == "" then -- 2388
		return 0 -- 2389
	end -- 2389
	local count = 0 -- 2390
	local pos = 0 -- 2391
	while true do -- 2391
		local idx = (string.find( -- 2393
			text, -- 2393
			searchStr, -- 2393
			math.max(pos + 1, 1), -- 2393
			true -- 2393
		) or 0) - 1 -- 2393
		if idx < 0 then -- 2393
			break -- 2394
		end -- 2394
		count = count + 1 -- 2395
		pos = idx + #searchStr -- 2396
	end -- 2396
	return count -- 2398
end -- 2388
local function replaceFirst(text, oldStr, newStr) -- 2401
	if oldStr == "" then -- 2401
		return text -- 2402
	end -- 2402
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2403
	if idx < 0 then -- 2403
		return text -- 2404
	end -- 2404
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2405
end -- 2401
local function splitLines(text) -- 2408
	return __TS__StringSplit(text, "\n") -- 2409
end -- 2408
local function getLeadingWhitespace(text) -- 2412
	local i = 0 -- 2413
	while i < #text do -- 2413
		local ch = __TS__StringAccess(text, i) -- 2415
		if ch ~= " " and ch ~= "\t" then -- 2415
			break -- 2416
		end -- 2416
		i = i + 1 -- 2417
	end -- 2417
	return __TS__StringSubstring(text, 0, i) -- 2419
end -- 2412
local function getCommonIndentPrefix(lines) -- 2422
	local common -- 2423
	do -- 2423
		local i = 0 -- 2424
		while i < #lines do -- 2424
			do -- 2424
				local line = lines[i + 1] -- 2425
				if __TS__StringTrim(line) == "" then -- 2425
					goto __continue385 -- 2426
				end -- 2426
				local indent = getLeadingWhitespace(line) -- 2427
				if common == nil then -- 2427
					common = indent -- 2429
					goto __continue385 -- 2430
				end -- 2430
				local j = 0 -- 2432
				local maxLen = math.min(#common, #indent) -- 2433
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2433
					j = j + 1 -- 2435
				end -- 2435
				common = __TS__StringSubstring(common, 0, j) -- 2437
				if common == "" then -- 2437
					break -- 2438
				end -- 2438
			end -- 2438
			::__continue385:: -- 2438
			i = i + 1 -- 2424
		end -- 2424
	end -- 2424
	return common or "" -- 2440
end -- 2422
local function removeIndentPrefix(line, indent) -- 2443
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2443
		return __TS__StringSubstring(line, #indent) -- 2445
	end -- 2445
	local lineIndent = getLeadingWhitespace(line) -- 2447
	local j = 0 -- 2448
	local maxLen = math.min(#lineIndent, #indent) -- 2449
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2449
		j = j + 1 -- 2451
	end -- 2451
	return __TS__StringSubstring(line, j) -- 2453
end -- 2443
local function dedentLines(lines) -- 2456
	local indent = getCommonIndentPrefix(lines) -- 2457
	return { -- 2458
		indent = indent, -- 2459
		lines = __TS__ArrayMap( -- 2460
			lines, -- 2460
			function(____, line) return removeIndentPrefix(line, indent) end -- 2460
		) -- 2460
	} -- 2460
end -- 2456
local function joinLines(lines) -- 2464
	return table.concat(lines, "\n") -- 2465
end -- 2464
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2468
	local contentLines = splitLines(content) -- 2473
	local oldLines = splitLines(oldStr) -- 2474
	if #oldLines == 0 then -- 2474
		return {success = false, message = "old_str not found in file"} -- 2476
	end -- 2476
	local dedentedOld = dedentLines(oldLines) -- 2478
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2479
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2480
	local matches = {} -- 2481
	do -- 2481
		local start = 0 -- 2482
		while start <= #contentLines - #oldLines do -- 2482
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2483
			local dedentedCandidate = dedentLines(candidateLines) -- 2484
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2484
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2486
			end -- 2486
			start = start + 1 -- 2482
		end -- 2482
	end -- 2482
	if #matches == 0 then -- 2482
		return {success = false, message = "old_str not found in file"} -- 2494
	end -- 2494
	if #matches > 1 then -- 2494
		return { -- 2497
			success = false, -- 2498
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2499
		} -- 2499
	end -- 2499
	local match = matches[1] -- 2502
	local rebuiltNewLines = __TS__ArrayMap( -- 2503
		dedentedNew.lines, -- 2503
		function(____, line) return line == "" and "" or match.indent .. line end -- 2503
	) -- 2503
	local ____array_46 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2503
	__TS__SparseArrayPush( -- 2503
		____array_46, -- 2503
		table.unpack(rebuiltNewLines) -- 2506
	) -- 2506
	__TS__SparseArrayPush( -- 2506
		____array_46, -- 2506
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2507
	) -- 2507
	local nextLines = {__TS__SparseArraySpread(____array_46)} -- 2504
	return { -- 2509
		success = true, -- 2509
		content = joinLines(nextLines) -- 2509
	} -- 2509
end -- 2468
local MainDecisionAgent = __TS__Class() -- 2512
MainDecisionAgent.name = "MainDecisionAgent" -- 2512
__TS__ClassExtends(MainDecisionAgent, Node) -- 2512
function MainDecisionAgent.prototype.prep(self, shared) -- 2513
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2513
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2513
			return ____awaiter_resolve(nil, {shared = shared}) -- 2513
		end -- 2513
		__TS__Await(maybeCompressHistory(shared)) -- 2518
		return ____awaiter_resolve(nil, {shared = shared}) -- 2518
	end) -- 2518
end -- 2513
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2523
	if attempt == nil then -- 2523
		attempt = 1 -- 2526
	end -- 2526
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2526
		if shared.stopToken.stopped then -- 2526
			return ____awaiter_resolve( -- 2526
				nil, -- 2526
				{ -- 2530
					success = false, -- 2530
					message = getCancelledReason(shared) -- 2530
				} -- 2530
			) -- 2530
		end -- 2530
		Log( -- 2532
			"Info", -- 2532
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2532
		) -- 2532
		local tools = buildDecisionToolSchema(shared) -- 2533
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2534
		local stepId = shared.step + 1 -- 2535
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2536
		emitLLMContextMetrics( -- 2540
			shared, -- 2540
			stepId, -- 2540
			"decision_tool_calling", -- 2540
			messages, -- 2540
			llmOptions -- 2540
		) -- 2540
		saveStepLLMDebugInput( -- 2541
			shared, -- 2541
			stepId, -- 2541
			"decision_tool_calling", -- 2541
			messages, -- 2541
			llmOptions -- 2541
		) -- 2541
		local lastStreamContent = "" -- 2542
		local lastStreamReasoning = "" -- 2543
		local preExecutedResults = __TS__New(Map) -- 2544
		shared.preExecutedResults = preExecutedResults -- 2545
		local res = __TS__Await(callLLMStreamAggregated( -- 2546
			messages, -- 2547
			llmOptions, -- 2548
			shared.stopToken, -- 2549
			shared.llmConfig, -- 2550
			function(response) -- 2551
				local ____opt_49 = response.choices -- 2551
				local ____opt_47 = ____opt_49 and ____opt_49[1] -- 2551
				local streamMessage = ____opt_47 and ____opt_47.message -- 2552
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2553
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2556
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2556
					return -- 2560
				end -- 2560
				lastStreamContent = nextContent -- 2562
				lastStreamReasoning = nextReasoning -- 2563
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2564
			end, -- 2551
			function(tc) -- 2566
				if shared.stopToken.stopped then -- 2566
					return -- 2567
				end -- 2567
				local action = createPreExecutableActionFromStream(shared, tc) -- 2568
				if not action or preExecutedResults:has(action.toolCallId) then -- 2568
					return -- 2569
				end -- 2569
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2570
				preExecutedResults:set( -- 2571
					action.toolCallId, -- 2571
					startPreExecutedToolAction(shared, action) -- 2571
				) -- 2571
			end -- 2566
		)) -- 2566
		if shared.stopToken.stopped then -- 2566
			clearPreExecutedResults(shared) -- 2575
			return ____awaiter_resolve( -- 2575
				nil, -- 2575
				{ -- 2576
					success = false, -- 2576
					message = getCancelledReason(shared) -- 2576
				} -- 2576
			) -- 2576
		end -- 2576
		if not res.success then -- 2576
			saveStepLLMDebugOutput( -- 2579
				shared, -- 2579
				stepId, -- 2579
				"decision_tool_calling", -- 2579
				res.raw or res.message, -- 2579
				{success = false} -- 2579
			) -- 2579
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2580
			clearPreExecutedResults(shared) -- 2581
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2581
		end -- 2581
		saveStepLLMDebugOutput( -- 2584
			shared, -- 2584
			stepId, -- 2584
			"decision_tool_calling", -- 2584
			encodeDebugJSON(res.response), -- 2584
			{success = true} -- 2584
		) -- 2584
		local choice = res.response.choices and res.response.choices[1] -- 2585
		local message = choice and choice.message -- 2586
		local toolCalls = message and message.tool_calls -- 2587
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2588
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2591
		Log( -- 2594
			"Info", -- 2594
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2594
		) -- 2594
		if not toolCalls or #toolCalls == 0 then -- 2594
			if messageContent and messageContent ~= "" then -- 2594
				Log( -- 2597
					"Info", -- 2597
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2597
				) -- 2597
				clearPreExecutedResults(shared) -- 2598
				return ____awaiter_resolve(nil, { -- 2598
					success = true, -- 2600
					tool = "finish", -- 2601
					params = {}, -- 2602
					reason = messageContent, -- 2603
					reasoningContent = reasoningContent, -- 2604
					directSummary = messageContent -- 2605
				}) -- 2605
			end -- 2605
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2608
			clearPreExecutedResults(shared) -- 2609
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2609
		end -- 2609
		local decisions = {} -- 2616
		do -- 2616
			local i = 0 -- 2617
			while i < #toolCalls do -- 2617
				local toolCall = toolCalls[i + 1] -- 2618
				local fn = toolCall and toolCall["function"] -- 2619
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2619
					Log( -- 2621
						"Error", -- 2621
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2621
					) -- 2621
					clearPreExecutedResults(shared) -- 2622
					return ____awaiter_resolve( -- 2622
						nil, -- 2622
						{ -- 2623
							success = false, -- 2624
							message = "missing function name for tool call " .. tostring(i + 1), -- 2625
							raw = messageContent -- 2626
						} -- 2626
					) -- 2626
				end -- 2626
				local functionName = fn.name -- 2629
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2630
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2631
				Log( -- 2634
					"Info", -- 2634
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2634
				) -- 2634
				local decision = parseAndValidateToolCallDecision( -- 2635
					shared, -- 2636
					functionName, -- 2637
					argsText, -- 2638
					toolCallId, -- 2639
					messageContent, -- 2640
					reasoningContent -- 2641
				) -- 2641
				if not decision.success then -- 2641
					Log( -- 2644
						"Error", -- 2644
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2644
					) -- 2644
					clearPreExecutedResults(shared) -- 2645
					return ____awaiter_resolve(nil, decision) -- 2645
				end -- 2645
				decisions[#decisions + 1] = decision -- 2648
				i = i + 1 -- 2617
			end -- 2617
		end -- 2617
		if #decisions == 1 then -- 2617
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2651
			return ____awaiter_resolve(nil, decisions[1]) -- 2651
		end -- 2651
		do -- 2651
			local i = 0 -- 2654
			while i < #decisions do -- 2654
				if decisions[i + 1].tool == "finish" then -- 2654
					clearPreExecutedResults(shared) -- 2656
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2656
				end -- 2656
				i = i + 1 -- 2654
			end -- 2654
		end -- 2654
		Log( -- 2664
			"Info", -- 2664
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2664
				__TS__ArrayMap( -- 2664
					decisions, -- 2664
					function(____, decision) return decision.tool end -- 2664
				), -- 2664
				"," -- 2664
			) -- 2664
		) -- 2664
		return ____awaiter_resolve(nil, { -- 2664
			success = true, -- 2666
			kind = "batch", -- 2667
			decisions = decisions, -- 2668
			content = messageContent, -- 2669
			reasoningContent = reasoningContent -- 2670
		}) -- 2670
	end) -- 2670
end -- 2523
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2674
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2674
		Log( -- 2679
			"Info", -- 2679
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2679
		) -- 2679
		local lastError = initialError -- 2680
		local candidateRaw = "" -- 2681
		do -- 2681
			local attempt = 0 -- 2682
			while attempt < shared.llmMaxTry do -- 2682
				do -- 2682
					Log( -- 2683
						"Info", -- 2683
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2683
					) -- 2683
					local messages = buildXmlRepairMessages( -- 2684
						shared, -- 2685
						originalRaw, -- 2686
						candidateRaw, -- 2687
						lastError, -- 2688
						attempt + 1 -- 2689
					) -- 2689
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2691
					if shared.stopToken.stopped then -- 2691
						return ____awaiter_resolve( -- 2691
							nil, -- 2691
							{ -- 2693
								success = false, -- 2693
								message = getCancelledReason(shared) -- 2693
							} -- 2693
						) -- 2693
					end -- 2693
					if not llmRes.success then -- 2693
						lastError = llmRes.message -- 2696
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2697
						goto __continue428 -- 2698
					end -- 2698
					candidateRaw = llmRes.text -- 2700
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2701
					if decision.success then -- 2701
						decision.reasoningContent = llmRes.reasoningContent -- 2703
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2704
						return ____awaiter_resolve(nil, decision) -- 2704
					end -- 2704
					lastError = decision.message -- 2707
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2708
				end -- 2708
				::__continue428:: -- 2708
				attempt = attempt + 1 -- 2682
			end -- 2682
		end -- 2682
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2710
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2710
	end) -- 2710
end -- 2674
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2718
	if attempt == nil then -- 2718
		attempt = 1 -- 2721
	end -- 2721
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2721
		local messages = buildDecisionMessages( -- 2724
			shared, -- 2725
			lastError, -- 2726
			attempt, -- 2727
			lastRaw, -- 2728
			"xml" -- 2729
		) -- 2729
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2731
		if shared.stopToken.stopped then -- 2731
			return ____awaiter_resolve( -- 2731
				nil, -- 2731
				{ -- 2733
					success = false, -- 2733
					message = getCancelledReason(shared) -- 2733
				} -- 2733
			) -- 2733
		end -- 2733
		if not llmRes.success then -- 2733
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2733
		end -- 2733
		local decision = tryParseAndValidateDecision(llmRes.text) -- 2742
		if decision.success then -- 2742
			decision.reasoningContent = llmRes.reasoningContent -- 2744
			if not isToolAllowedForRole(shared.role, decision.tool) then -- 2744
				return ____awaiter_resolve( -- 2744
					nil, -- 2744
					self:repairDecisionXml(shared, llmRes.text, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2746
				) -- 2746
			end -- 2746
			return ____awaiter_resolve(nil, decision) -- 2746
		end -- 2746
		return ____awaiter_resolve( -- 2746
			nil, -- 2746
			self:repairDecisionXml(shared, llmRes.text, decision.message) -- 2754
		) -- 2754
	end) -- 2754
end -- 2718
function MainDecisionAgent.prototype.exec(self, input) -- 2757
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2757
		local shared = input.shared -- 2758
		if shared.stopToken.stopped then -- 2758
			return ____awaiter_resolve( -- 2758
				nil, -- 2758
				{ -- 2760
					success = false, -- 2760
					message = getCancelledReason(shared) -- 2760
				} -- 2760
			) -- 2760
		end -- 2760
		if shared.step >= shared.maxSteps then -- 2760
			Log( -- 2763
				"Warn", -- 2763
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2763
			) -- 2763
			return ____awaiter_resolve( -- 2763
				nil, -- 2763
				{ -- 2764
					success = false, -- 2764
					message = getMaxStepsReachedReason(shared) -- 2764
				} -- 2764
			) -- 2764
		end -- 2764
		if shared.decisionMode == "tool_calling" then -- 2764
			Log( -- 2768
				"Info", -- 2768
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2768
			) -- 2768
			local lastError = "tool calling validation failed" -- 2769
			local lastRaw = "" -- 2770
			local shouldFallbackToXml = false -- 2771
			do -- 2771
				local attempt = 0 -- 2772
				while attempt < shared.llmMaxTry do -- 2772
					Log( -- 2773
						"Info", -- 2773
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2773
					) -- 2773
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2774
					if shared.stopToken.stopped then -- 2774
						return ____awaiter_resolve( -- 2774
							nil, -- 2774
							{ -- 2781
								success = false, -- 2781
								message = getCancelledReason(shared) -- 2781
							} -- 2781
						) -- 2781
					end -- 2781
					if decision.success then -- 2781
						return ____awaiter_resolve(nil, decision) -- 2781
					end -- 2781
					lastError = decision.message -- 2786
					lastRaw = decision.raw or "" -- 2787
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2788
					if lastError == "missing tool call" then -- 2788
						shouldFallbackToXml = true -- 2790
						break -- 2791
					end -- 2791
					attempt = attempt + 1 -- 2772
				end -- 2772
			end -- 2772
			if shouldFallbackToXml then -- 2772
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 2795
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 2796
				do -- 2796
					local attempt = 0 -- 2797
					while attempt < shared.llmMaxTry do -- 2797
						Log( -- 2798
							"Info", -- 2798
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 2798
						) -- 2798
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 2799
						if shared.stopToken.stopped then -- 2799
							return ____awaiter_resolve( -- 2799
								nil, -- 2799
								{ -- 2806
									success = false, -- 2806
									message = getCancelledReason(shared) -- 2806
								} -- 2806
							) -- 2806
						end -- 2806
						if decision.success then -- 2806
							return ____awaiter_resolve(nil, decision) -- 2806
						end -- 2806
						lastError = decision.message -- 2811
						lastRaw = decision.raw or "" -- 2812
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 2813
						attempt = attempt + 1 -- 2797
					end -- 2797
				end -- 2797
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 2815
				return ____awaiter_resolve( -- 2815
					nil, -- 2815
					{ -- 2816
						success = false, -- 2816
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2816
					} -- 2816
				) -- 2816
			end -- 2816
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2818
			return ____awaiter_resolve( -- 2818
				nil, -- 2818
				{ -- 2819
					success = false, -- 2819
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2819
				} -- 2819
			) -- 2819
		end -- 2819
		local lastError = "xml validation failed" -- 2822
		local lastRaw = "" -- 2823
		do -- 2823
			local attempt = 0 -- 2824
			while attempt < shared.llmMaxTry do -- 2824
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 2825
				if shared.stopToken.stopped then -- 2825
					return ____awaiter_resolve( -- 2825
						nil, -- 2825
						{ -- 2834
							success = false, -- 2834
							message = getCancelledReason(shared) -- 2834
						} -- 2834
					) -- 2834
				end -- 2834
				if decision.success then -- 2834
					return ____awaiter_resolve(nil, decision) -- 2834
				end -- 2834
				lastError = decision.message -- 2839
				lastRaw = decision.raw or "" -- 2840
				attempt = attempt + 1 -- 2824
			end -- 2824
		end -- 2824
		return ____awaiter_resolve( -- 2824
			nil, -- 2824
			{ -- 2842
				success = false, -- 2842
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2842
			} -- 2842
		) -- 2842
	end) -- 2842
end -- 2757
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2845
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2845
		local result = execRes -- 2846
		if not result.success then -- 2846
			if shared.stopToken.stopped then -- 2846
				shared.error = getCancelledReason(shared) -- 2849
				shared.done = true -- 2850
				return ____awaiter_resolve(nil, "done") -- 2850
			end -- 2850
			shared.error = result.message -- 2853
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2854
			shared.done = true -- 2855
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2856
			persistHistoryState(shared) -- 2860
			return ____awaiter_resolve(nil, "done") -- 2860
		end -- 2860
		if isDecisionBatchSuccess(result) then -- 2860
			local startStep = shared.step -- 2864
			local actions = {} -- 2865
			do -- 2865
				local i = 0 -- 2866
				while i < #result.decisions do -- 2866
					local decision = result.decisions[i + 1] -- 2867
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2868
					local step = startStep + i + 1 -- 2869
					local ____temp_55 -- 2870
					if i == 0 then -- 2870
						____temp_55 = decision.reason -- 2870
					else -- 2870
						____temp_55 = "" -- 2870
					end -- 2870
					local actionReason = ____temp_55 -- 2870
					local ____temp_56 -- 2871
					if i == 0 then -- 2871
						____temp_56 = decision.reasoningContent -- 2871
					else -- 2871
						____temp_56 = nil -- 2871
					end -- 2871
					local actionReasoningContent = ____temp_56 -- 2871
					emitAgentEvent(shared, { -- 2872
						type = "decision_made", -- 2873
						sessionId = shared.sessionId, -- 2874
						taskId = shared.taskId, -- 2875
						step = step, -- 2876
						tool = decision.tool, -- 2877
						reason = actionReason, -- 2878
						reasoningContent = actionReasoningContent, -- 2879
						params = decision.params -- 2880
					}) -- 2880
					local action = { -- 2882
						step = step, -- 2883
						toolCallId = toolCallId, -- 2884
						tool = decision.tool, -- 2885
						reason = actionReason or "", -- 2886
						reasoningContent = actionReasoningContent, -- 2887
						params = decision.params, -- 2888
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2889
					} -- 2889
					local ____shared_history_57 = shared.history -- 2889
					____shared_history_57[#____shared_history_57 + 1] = action -- 2891
					actions[#actions + 1] = action -- 2892
					i = i + 1 -- 2866
				end -- 2866
			end -- 2866
			shared.step = startStep + #actions -- 2894
			shared.pendingToolActions = actions -- 2895
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2896
			persistHistoryState(shared) -- 2902
			return ____awaiter_resolve(nil, "batch_tools") -- 2902
		end -- 2902
		if result.directSummary and result.directSummary ~= "" then -- 2902
			shared.response = result.directSummary -- 2906
			shared.done = true -- 2907
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2908
			persistHistoryState(shared) -- 2913
			return ____awaiter_resolve(nil, "done") -- 2913
		end -- 2913
		if result.tool == "finish" then -- 2913
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2917
			shared.response = finalMessage -- 2918
			shared.done = true -- 2919
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2920
			persistHistoryState(shared) -- 2925
			return ____awaiter_resolve(nil, "done") -- 2925
		end -- 2925
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2928
		shared.step = shared.step + 1 -- 2929
		local step = shared.step -- 2930
		emitAgentEvent(shared, { -- 2931
			type = "decision_made", -- 2932
			sessionId = shared.sessionId, -- 2933
			taskId = shared.taskId, -- 2934
			step = step, -- 2935
			tool = result.tool, -- 2936
			reason = result.reason, -- 2937
			reasoningContent = result.reasoningContent, -- 2938
			params = result.params -- 2939
		}) -- 2939
		local ____shared_history_58 = shared.history -- 2939
		____shared_history_58[#____shared_history_58 + 1] = { -- 2941
			step = step, -- 2942
			toolCallId = toolCallId, -- 2943
			tool = result.tool, -- 2944
			reason = result.reason or "", -- 2945
			reasoningContent = result.reasoningContent, -- 2946
			params = result.params, -- 2947
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2948
		} -- 2948
		local action = shared.history[#shared.history] -- 2950
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 2951
		if canPreExecuteTool(action.tool) then -- 2951
			shared.pendingToolActions = {action} -- 2953
			persistHistoryState(shared) -- 2954
			return ____awaiter_resolve(nil, "batch_tools") -- 2954
		end -- 2954
		clearPreExecutedResults(shared) -- 2957
		persistHistoryState(shared) -- 2958
		return ____awaiter_resolve(nil, result.tool) -- 2958
	end) -- 2958
end -- 2845
local ReadFileAction = __TS__Class() -- 2963
ReadFileAction.name = "ReadFileAction" -- 2963
__TS__ClassExtends(ReadFileAction, Node) -- 2963
function ReadFileAction.prototype.prep(self, shared) -- 2964
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2964
		local last = shared.history[#shared.history] -- 2965
		if not last then -- 2965
			error( -- 2966
				__TS__New(Error, "no history"), -- 2966
				0 -- 2966
			) -- 2966
		end -- 2966
		emitAgentStartEvent(shared, last) -- 2967
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2968
		if __TS__StringTrim(path) == "" then -- 2968
			error( -- 2971
				__TS__New(Error, "missing path"), -- 2971
				0 -- 2971
			) -- 2971
		end -- 2971
		local ____path_61 = path -- 2973
		local ____shared_workingDir_62 = shared.workingDir -- 2975
		local ____temp_63 = shared.useChineseResponse and "zh" or "en" -- 2976
		local ____last_params_startLine_59 = last.params.startLine -- 2977
		if ____last_params_startLine_59 == nil then -- 2977
			____last_params_startLine_59 = 1 -- 2977
		end -- 2977
		local ____TS__Number_result_64 = __TS__Number(____last_params_startLine_59) -- 2977
		local ____last_params_endLine_60 = last.params.endLine -- 2978
		if ____last_params_endLine_60 == nil then -- 2978
			____last_params_endLine_60 = READ_FILE_DEFAULT_LIMIT -- 2978
		end -- 2978
		return ____awaiter_resolve( -- 2978
			nil, -- 2978
			{ -- 2972
				path = ____path_61, -- 2973
				tool = "read_file", -- 2974
				workDir = ____shared_workingDir_62, -- 2975
				docLanguage = ____temp_63, -- 2976
				startLine = ____TS__Number_result_64, -- 2977
				endLine = __TS__Number(____last_params_endLine_60) -- 2978
			} -- 2978
		) -- 2978
	end) -- 2978
end -- 2964
function ReadFileAction.prototype.exec(self, input) -- 2982
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2982
		return ____awaiter_resolve( -- 2982
			nil, -- 2982
			Tools.readFile( -- 2983
				input.workDir, -- 2984
				input.path, -- 2985
				__TS__Number(input.startLine or 1), -- 2986
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2987
				input.docLanguage -- 2988
			) -- 2988
		) -- 2988
	end) -- 2988
end -- 2982
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2992
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2992
		local result = execRes -- 2993
		local last = shared.history[#shared.history] -- 2994
		if last ~= nil then -- 2994
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2996
			appendToolResultMessage(shared, last) -- 2997
			emitAgentFinishEvent(shared, last) -- 2998
		end -- 2998
		persistHistoryState(shared) -- 3000
		__TS__Await(maybeCompressHistory(shared)) -- 3001
		persistHistoryState(shared) -- 3002
		return ____awaiter_resolve(nil, "main") -- 3002
	end) -- 3002
end -- 2992
local SearchFilesAction = __TS__Class() -- 3007
SearchFilesAction.name = "SearchFilesAction" -- 3007
__TS__ClassExtends(SearchFilesAction, Node) -- 3007
function SearchFilesAction.prototype.prep(self, shared) -- 3008
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3008
		local last = shared.history[#shared.history] -- 3009
		if not last then -- 3009
			error( -- 3010
				__TS__New(Error, "no history"), -- 3010
				0 -- 3010
			) -- 3010
		end -- 3010
		emitAgentStartEvent(shared, last) -- 3011
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3011
	end) -- 3011
end -- 3008
function SearchFilesAction.prototype.exec(self, input) -- 3015
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3015
		local params = input.params -- 3016
		local ____Tools_searchFiles_78 = Tools.searchFiles -- 3017
		local ____input_workDir_71 = input.workDir -- 3018
		local ____temp_72 = params.path or "" -- 3019
		local ____temp_73 = params.pattern or "" -- 3020
		local ____params_globs_74 = params.globs -- 3021
		local ____params_useRegex_75 = params.useRegex -- 3022
		local ____params_caseSensitive_76 = params.caseSensitive -- 3023
		local ____math_max_67 = math.max -- 3026
		local ____math_floor_66 = math.floor -- 3026
		local ____params_limit_65 = params.limit -- 3026
		if ____params_limit_65 == nil then -- 3026
			____params_limit_65 = SEARCH_FILES_LIMIT_DEFAULT -- 3026
		end -- 3026
		local ____math_max_67_result_77 = ____math_max_67( -- 3026
			1, -- 3026
			____math_floor_66(__TS__Number(____params_limit_65)) -- 3026
		) -- 3026
		local ____math_max_70 = math.max -- 3027
		local ____math_floor_69 = math.floor -- 3027
		local ____params_offset_68 = params.offset -- 3027
		if ____params_offset_68 == nil then -- 3027
			____params_offset_68 = 0 -- 3027
		end -- 3027
		local result = __TS__Await(____Tools_searchFiles_78({ -- 3017
			workDir = ____input_workDir_71, -- 3018
			path = ____temp_72, -- 3019
			pattern = ____temp_73, -- 3020
			globs = ____params_globs_74, -- 3021
			useRegex = ____params_useRegex_75, -- 3022
			caseSensitive = ____params_caseSensitive_76, -- 3023
			includeContent = true, -- 3024
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3025
			limit = ____math_max_67_result_77, -- 3026
			offset = ____math_max_70( -- 3027
				0, -- 3027
				____math_floor_69(__TS__Number(____params_offset_68)) -- 3027
			), -- 3027
			groupByFile = params.groupByFile == true -- 3028
		})) -- 3028
		return ____awaiter_resolve(nil, result) -- 3028
	end) -- 3028
end -- 3015
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3033
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3033
		local last = shared.history[#shared.history] -- 3034
		if last ~= nil then -- 3034
			local result = execRes -- 3036
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3037
			appendToolResultMessage(shared, last) -- 3038
			emitAgentFinishEvent(shared, last) -- 3039
		end -- 3039
		persistHistoryState(shared) -- 3041
		__TS__Await(maybeCompressHistory(shared)) -- 3042
		persistHistoryState(shared) -- 3043
		return ____awaiter_resolve(nil, "main") -- 3043
	end) -- 3043
end -- 3033
local SearchDoraAPIAction = __TS__Class() -- 3048
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3048
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3048
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3049
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3049
		local last = shared.history[#shared.history] -- 3050
		if not last then -- 3050
			error( -- 3051
				__TS__New(Error, "no history"), -- 3051
				0 -- 3051
			) -- 3051
		end -- 3051
		emitAgentStartEvent(shared, last) -- 3052
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3052
	end) -- 3052
end -- 3049
function SearchDoraAPIAction.prototype.exec(self, input) -- 3056
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3056
		local params = input.params -- 3057
		local ____Tools_searchDoraAPI_86 = Tools.searchDoraAPI -- 3058
		local ____temp_82 = params.pattern or "" -- 3059
		local ____temp_83 = params.docSource or "api" -- 3060
		local ____temp_84 = input.useChineseResponse and "zh" or "en" -- 3061
		local ____temp_85 = params.programmingLanguage or "ts" -- 3062
		local ____math_min_81 = math.min -- 3063
		local ____math_max_80 = math.max -- 3063
		local ____params_limit_79 = params.limit -- 3063
		if ____params_limit_79 == nil then -- 3063
			____params_limit_79 = 8 -- 3063
		end -- 3063
		local result = __TS__Await(____Tools_searchDoraAPI_86({ -- 3058
			pattern = ____temp_82, -- 3059
			docSource = ____temp_83, -- 3060
			docLanguage = ____temp_84, -- 3061
			programmingLanguage = ____temp_85, -- 3062
			limit = ____math_min_81( -- 3063
				SEARCH_DORA_API_LIMIT_MAX, -- 3063
				____math_max_80( -- 3063
					1, -- 3063
					__TS__Number(____params_limit_79) -- 3063
				) -- 3063
			), -- 3063
			useRegex = params.useRegex, -- 3064
			caseSensitive = false, -- 3065
			includeContent = true, -- 3066
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 3067
		})) -- 3067
		return ____awaiter_resolve(nil, result) -- 3067
	end) -- 3067
end -- 3056
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3072
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3072
		local last = shared.history[#shared.history] -- 3073
		if last ~= nil then -- 3073
			local result = execRes -- 3075
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3076
			appendToolResultMessage(shared, last) -- 3077
			emitAgentFinishEvent(shared, last) -- 3078
		end -- 3078
		persistHistoryState(shared) -- 3080
		__TS__Await(maybeCompressHistory(shared)) -- 3081
		persistHistoryState(shared) -- 3082
		return ____awaiter_resolve(nil, "main") -- 3082
	end) -- 3082
end -- 3072
local ListFilesAction = __TS__Class() -- 3087
ListFilesAction.name = "ListFilesAction" -- 3087
__TS__ClassExtends(ListFilesAction, Node) -- 3087
function ListFilesAction.prototype.prep(self, shared) -- 3088
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3088
		local last = shared.history[#shared.history] -- 3089
		if not last then -- 3089
			error( -- 3090
				__TS__New(Error, "no history"), -- 3090
				0 -- 3090
			) -- 3090
		end -- 3090
		emitAgentStartEvent(shared, last) -- 3091
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3091
	end) -- 3091
end -- 3088
function ListFilesAction.prototype.exec(self, input) -- 3095
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3095
		local params = input.params -- 3096
		local ____Tools_listFiles_93 = Tools.listFiles -- 3097
		local ____input_workDir_90 = input.workDir -- 3098
		local ____temp_91 = params.path or "" -- 3099
		local ____params_globs_92 = params.globs -- 3100
		local ____math_max_89 = math.max -- 3101
		local ____math_floor_88 = math.floor -- 3101
		local ____params_maxEntries_87 = params.maxEntries -- 3101
		if ____params_maxEntries_87 == nil then -- 3101
			____params_maxEntries_87 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3101
		end -- 3101
		local result = ____Tools_listFiles_93({ -- 3097
			workDir = ____input_workDir_90, -- 3098
			path = ____temp_91, -- 3099
			globs = ____params_globs_92, -- 3100
			maxEntries = ____math_max_89( -- 3101
				1, -- 3101
				____math_floor_88(__TS__Number(____params_maxEntries_87)) -- 3101
			) -- 3101
		}) -- 3101
		return ____awaiter_resolve(nil, result) -- 3101
	end) -- 3101
end -- 3095
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3106
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3106
		local last = shared.history[#shared.history] -- 3107
		if last ~= nil then -- 3107
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3109
			appendToolResultMessage(shared, last) -- 3110
			emitAgentFinishEvent(shared, last) -- 3111
		end -- 3111
		persistHistoryState(shared) -- 3113
		__TS__Await(maybeCompressHistory(shared)) -- 3114
		persistHistoryState(shared) -- 3115
		return ____awaiter_resolve(nil, "main") -- 3115
	end) -- 3115
end -- 3106
local DeleteFileAction = __TS__Class() -- 3120
DeleteFileAction.name = "DeleteFileAction" -- 3120
__TS__ClassExtends(DeleteFileAction, Node) -- 3120
function DeleteFileAction.prototype.prep(self, shared) -- 3121
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3121
		local last = shared.history[#shared.history] -- 3122
		if not last then -- 3122
			error( -- 3123
				__TS__New(Error, "no history"), -- 3123
				0 -- 3123
			) -- 3123
		end -- 3123
		emitAgentStartEvent(shared, last) -- 3124
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3125
		if __TS__StringTrim(targetFile) == "" then -- 3125
			error( -- 3128
				__TS__New(Error, "missing target_file"), -- 3128
				0 -- 3128
			) -- 3128
		end -- 3128
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3128
	end) -- 3128
end -- 3121
function DeleteFileAction.prototype.exec(self, input) -- 3132
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3132
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3133
		if not result.success then -- 3133
			return ____awaiter_resolve(nil, result) -- 3133
		end -- 3133
		return ____awaiter_resolve(nil, { -- 3133
			success = true, -- 3141
			changed = true, -- 3142
			mode = "delete", -- 3143
			checkpointId = result.checkpointId, -- 3144
			checkpointSeq = result.checkpointSeq, -- 3145
			files = {{path = input.targetFile, op = "delete"}} -- 3146
		}) -- 3146
	end) -- 3146
end -- 3132
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3150
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3150
		local last = shared.history[#shared.history] -- 3151
		if last ~= nil then -- 3151
			last.result = execRes -- 3153
			appendToolResultMessage(shared, last) -- 3154
			emitAgentFinishEvent(shared, last) -- 3155
			local result = last.result -- 3156
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3156
				emitAgentEvent(shared, { -- 3161
					type = "checkpoint_created", -- 3162
					sessionId = shared.sessionId, -- 3163
					taskId = shared.taskId, -- 3164
					step = last.step, -- 3165
					tool = "delete_file", -- 3166
					checkpointId = result.checkpointId, -- 3167
					checkpointSeq = result.checkpointSeq, -- 3168
					files = result.files -- 3169
				}) -- 3169
			end -- 3169
		end -- 3169
		persistHistoryState(shared) -- 3173
		__TS__Await(maybeCompressHistory(shared)) -- 3174
		persistHistoryState(shared) -- 3175
		return ____awaiter_resolve(nil, "main") -- 3175
	end) -- 3175
end -- 3150
local BuildAction = __TS__Class() -- 3180
BuildAction.name = "BuildAction" -- 3180
__TS__ClassExtends(BuildAction, Node) -- 3180
function BuildAction.prototype.prep(self, shared) -- 3181
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3181
		local last = shared.history[#shared.history] -- 3182
		if not last then -- 3182
			error( -- 3183
				__TS__New(Error, "no history"), -- 3183
				0 -- 3183
			) -- 3183
		end -- 3183
		emitAgentStartEvent(shared, last) -- 3184
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3184
	end) -- 3184
end -- 3181
function BuildAction.prototype.exec(self, input) -- 3188
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3188
		local params = input.params -- 3189
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3190
		return ____awaiter_resolve(nil, result) -- 3190
	end) -- 3190
end -- 3188
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3197
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3197
		local last = shared.history[#shared.history] -- 3198
		if last ~= nil then -- 3198
			last.result = sanitizeBuildResultForHistory(execRes) -- 3200
			appendToolResultMessage(shared, last) -- 3201
			emitAgentFinishEvent(shared, last) -- 3202
		end -- 3202
		persistHistoryState(shared) -- 3204
		__TS__Await(maybeCompressHistory(shared)) -- 3205
		persistHistoryState(shared) -- 3206
		return ____awaiter_resolve(nil, "main") -- 3206
	end) -- 3206
end -- 3197
local SpawnSubAgentAction = __TS__Class() -- 3211
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3211
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3211
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3212
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3212
		local last = shared.history[#shared.history] -- 3221
		if not last then -- 3221
			error( -- 3222
				__TS__New(Error, "no history"), -- 3222
				0 -- 3222
			) -- 3222
		end -- 3222
		emitAgentStartEvent(shared, last) -- 3223
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3224
			last.params.filesHint, -- 3225
			function(____, item) return type(item) == "string" end -- 3225
		) or nil -- 3225
		return ____awaiter_resolve( -- 3225
			nil, -- 3225
			{ -- 3227
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3228
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3229
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3230
				filesHint = filesHint, -- 3231
				sessionId = shared.sessionId, -- 3232
				projectRoot = shared.workingDir, -- 3233
				spawnSubAgent = shared.spawnSubAgent -- 3234
			} -- 3234
		) -- 3234
	end) -- 3234
end -- 3212
function SpawnSubAgentAction.prototype.exec(self, input) -- 3238
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3238
		if not input.spawnSubAgent then -- 3238
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3238
		end -- 3238
		if input.sessionId == nil or input.sessionId <= 0 then -- 3238
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3238
		end -- 3238
		local ____Log_99 = Log -- 3253
		local ____temp_96 = #input.title -- 3253
		local ____temp_97 = #input.prompt -- 3253
		local ____temp_98 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3253
		local ____opt_94 = input.filesHint -- 3253
		____Log_99( -- 3253
			"Info", -- 3253
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_96)) .. " prompt_len=") .. tostring(____temp_97)) .. " expected_len=") .. tostring(____temp_98)) .. " files_hint_count=") .. tostring(____opt_94 and #____opt_94 or 0) -- 3253
		) -- 3253
		local result = __TS__Await(input.spawnSubAgent({ -- 3254
			parentSessionId = input.sessionId, -- 3255
			projectRoot = input.projectRoot, -- 3256
			title = input.title, -- 3257
			prompt = input.prompt, -- 3258
			expectedOutput = input.expectedOutput, -- 3259
			filesHint = input.filesHint -- 3260
		})) -- 3260
		if not result.success then -- 3260
			return ____awaiter_resolve(nil, result) -- 3260
		end -- 3260
		return ____awaiter_resolve(nil, { -- 3260
			success = true, -- 3266
			sessionId = result.sessionId, -- 3267
			taskId = result.taskId, -- 3268
			title = result.title, -- 3269
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3270
		}) -- 3270
	end) -- 3270
end -- 3238
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3274
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3274
		local last = shared.history[#shared.history] -- 3275
		if last ~= nil then -- 3275
			last.result = execRes -- 3277
			appendToolResultMessage(shared, last) -- 3278
			emitAgentFinishEvent(shared, last) -- 3279
		end -- 3279
		persistHistoryState(shared) -- 3281
		__TS__Await(maybeCompressHistory(shared)) -- 3282
		persistHistoryState(shared) -- 3283
		return ____awaiter_resolve(nil, "main") -- 3283
	end) -- 3283
end -- 3274
local ListSubAgentsAction = __TS__Class() -- 3288
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3288
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3288
function ListSubAgentsAction.prototype.prep(self, shared) -- 3289
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3289
		local last = shared.history[#shared.history] -- 3298
		if not last then -- 3298
			error( -- 3299
				__TS__New(Error, "no history"), -- 3299
				0 -- 3299
			) -- 3299
		end -- 3299
		emitAgentStartEvent(shared, last) -- 3300
		return ____awaiter_resolve( -- 3300
			nil, -- 3300
			{ -- 3301
				sessionId = shared.sessionId, -- 3302
				projectRoot = shared.workingDir, -- 3303
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3304
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3305
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3306
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3307
				listSubAgents = shared.listSubAgents -- 3308
			} -- 3308
		) -- 3308
	end) -- 3308
end -- 3289
function ListSubAgentsAction.prototype.exec(self, input) -- 3312
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3312
		if not input.listSubAgents then -- 3312
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3312
		end -- 3312
		if input.sessionId == nil or input.sessionId <= 0 then -- 3312
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3312
		end -- 3312
		local result = __TS__Await(input.listSubAgents({ -- 3327
			sessionId = input.sessionId, -- 3328
			projectRoot = input.projectRoot, -- 3329
			status = input.status, -- 3330
			limit = input.limit, -- 3331
			offset = input.offset, -- 3332
			query = input.query -- 3333
		})) -- 3333
		return ____awaiter_resolve(nil, result) -- 3333
	end) -- 3333
end -- 3312
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3338
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3338
		local last = shared.history[#shared.history] -- 3339
		if last ~= nil then -- 3339
			last.result = execRes -- 3341
			appendToolResultMessage(shared, last) -- 3342
			emitAgentFinishEvent(shared, last) -- 3343
		end -- 3343
		persistHistoryState(shared) -- 3345
		__TS__Await(maybeCompressHistory(shared)) -- 3346
		persistHistoryState(shared) -- 3347
		return ____awaiter_resolve(nil, "main") -- 3347
	end) -- 3347
end -- 3338
EditFileAction = __TS__Class() -- 3352
EditFileAction.name = "EditFileAction" -- 3352
__TS__ClassExtends(EditFileAction, Node) -- 3352
function EditFileAction.prototype.prep(self, shared) -- 3353
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3353
		local last = shared.history[#shared.history] -- 3354
		if not last then -- 3354
			error( -- 3355
				__TS__New(Error, "no history"), -- 3355
				0 -- 3355
			) -- 3355
		end -- 3355
		emitAgentStartEvent(shared, last) -- 3356
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3357
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3360
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3361
		if __TS__StringTrim(path) == "" then -- 3361
			error( -- 3362
				__TS__New(Error, "missing path"), -- 3362
				0 -- 3362
			) -- 3362
		end -- 3362
		return ____awaiter_resolve(nil, { -- 3362
			path = path, -- 3363
			oldStr = oldStr, -- 3363
			newStr = newStr, -- 3363
			taskId = shared.taskId, -- 3363
			workDir = shared.workingDir -- 3363
		}) -- 3363
	end) -- 3363
end -- 3353
function EditFileAction.prototype.exec(self, input) -- 3366
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3366
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3367
		if not readRes.success then -- 3367
			if input.oldStr ~= "" then -- 3367
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3367
			end -- 3367
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3372
			if not createRes.success then -- 3372
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3372
			end -- 3372
			return ____awaiter_resolve(nil, { -- 3372
				success = true, -- 3380
				changed = true, -- 3381
				mode = "create", -- 3382
				checkpointId = createRes.checkpointId, -- 3383
				checkpointSeq = createRes.checkpointSeq, -- 3384
				files = {{path = input.path, op = "create"}} -- 3385
			}) -- 3385
		end -- 3385
		if input.oldStr == "" then -- 3385
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3389
			if not overwriteRes.success then -- 3389
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3389
			end -- 3389
			return ____awaiter_resolve(nil, { -- 3389
				success = true, -- 3397
				changed = true, -- 3398
				mode = "overwrite", -- 3399
				checkpointId = overwriteRes.checkpointId, -- 3400
				checkpointSeq = overwriteRes.checkpointSeq, -- 3401
				files = {{path = input.path, op = "write"}} -- 3402
			}) -- 3402
		end -- 3402
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3407
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3408
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3409
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3412
		if occurrences == 0 then -- 3412
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3414
			if not indentTolerant.success then -- 3414
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3414
			end -- 3414
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3418
			if not applyRes.success then -- 3418
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3418
			end -- 3418
			return ____awaiter_resolve(nil, { -- 3418
				success = true, -- 3426
				changed = true, -- 3427
				mode = "replace_indent_tolerant", -- 3428
				checkpointId = applyRes.checkpointId, -- 3429
				checkpointSeq = applyRes.checkpointSeq, -- 3430
				files = {{path = input.path, op = "write"}} -- 3431
			}) -- 3431
		end -- 3431
		if occurrences > 1 then -- 3431
			return ____awaiter_resolve( -- 3431
				nil, -- 3431
				{ -- 3435
					success = false, -- 3435
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3435
				} -- 3435
			) -- 3435
		end -- 3435
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3439
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3440
		if not applyRes.success then -- 3440
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3440
		end -- 3440
		return ____awaiter_resolve(nil, { -- 3440
			success = true, -- 3448
			changed = true, -- 3449
			mode = "replace", -- 3450
			checkpointId = applyRes.checkpointId, -- 3451
			checkpointSeq = applyRes.checkpointSeq, -- 3452
			files = {{path = input.path, op = "write"}} -- 3453
		}) -- 3453
	end) -- 3453
end -- 3366
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3457
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3457
		local last = shared.history[#shared.history] -- 3458
		if last ~= nil then -- 3458
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3460
			last.result = execRes -- 3461
			appendToolResultMessage(shared, last) -- 3462
			emitAgentFinishEvent(shared, last) -- 3463
			local result = last.result -- 3464
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3464
				emitAgentEvent(shared, { -- 3469
					type = "checkpoint_created", -- 3470
					sessionId = shared.sessionId, -- 3471
					taskId = shared.taskId, -- 3472
					step = last.step, -- 3473
					tool = last.tool, -- 3474
					checkpointId = result.checkpointId, -- 3475
					checkpointSeq = result.checkpointSeq, -- 3476
					files = result.files -- 3477
				}) -- 3477
			end -- 3477
		end -- 3477
		persistHistoryState(shared) -- 3481
		__TS__Await(maybeCompressHistory(shared)) -- 3482
		persistHistoryState(shared) -- 3483
		return ____awaiter_resolve(nil, "main") -- 3483
	end) -- 3483
end -- 3457
local function emitCheckpointEventForAction(shared, action) -- 3488
	local result = action.result -- 3489
	if not result then -- 3489
		return -- 3490
	end -- 3490
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3490
		emitAgentEvent(shared, { -- 3495
			type = "checkpoint_created", -- 3496
			sessionId = shared.sessionId, -- 3497
			taskId = shared.taskId, -- 3498
			step = action.step, -- 3499
			tool = action.tool, -- 3500
			checkpointId = result.checkpointId, -- 3501
			checkpointSeq = result.checkpointSeq, -- 3502
			files = result.files -- 3503
		}) -- 3503
	end -- 3503
end -- 3488
local function sanitizeToolActionResultForHistory(action, result) -- 3658
	if action.tool == "read_file" then -- 3658
		return sanitizeReadResultForHistory(action.tool, result) -- 3660
	end -- 3660
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3660
		return sanitizeSearchResultForHistory(action.tool, result) -- 3663
	end -- 3663
	if action.tool == "glob_files" then -- 3663
		return sanitizeListFilesResultForHistory(result) -- 3666
	end -- 3666
	if action.tool == "build" then -- 3666
		return sanitizeBuildResultForHistory(result) -- 3669
	end -- 3669
	return result -- 3671
end -- 3658
local function canRunBatchActionInParallel(self, action) -- 3674
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 3675
end -- 3674
local function partitionToolCalls(actions) -- 3687
	local batches = {} -- 3688
	do -- 3688
		local i = 0 -- 3689
		while i < #actions do -- 3689
			local action = actions[i + 1] -- 3690
			local isSafe = canRunBatchActionInParallel(nil, action) -- 3691
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 3692
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 3692
				local ____lastBatch_actions_134 = lastBatch.actions -- 3692
				____lastBatch_actions_134[#____lastBatch_actions_134 + 1] = action -- 3694
			else -- 3694
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 3696
			end -- 3696
			i = i + 1 -- 3689
		end -- 3689
	end -- 3689
	return batches -- 3699
end -- 3687
local BatchToolAction = __TS__Class() -- 3702
BatchToolAction.name = "BatchToolAction" -- 3702
__TS__ClassExtends(BatchToolAction, Node) -- 3702
function BatchToolAction.prototype.prep(self, shared) -- 3703
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3703
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3703
	end) -- 3703
end -- 3703
function BatchToolAction.prototype.exec(self, input) -- 3707
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3707
		local shared = input.shared -- 3708
		local preExecuted = shared.preExecutedResults -- 3709
		local batches = partitionToolCalls(input.actions) -- 3710
		local parallelBatchCount = #__TS__ArrayFilter( -- 3711
			batches, -- 3711
			function(____, b) return b.isConcurrencySafe end -- 3711
		) -- 3711
		local serialBatchCount = #__TS__ArrayFilter( -- 3712
			batches, -- 3712
			function(____, b) return not b.isConcurrencySafe end -- 3712
		) -- 3712
		Log( -- 3713
			"Info", -- 3713
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 3713
		) -- 3713
		do -- 3713
			local batchIdx = 0 -- 3715
			while batchIdx < #batches do -- 3715
				do -- 3715
					local batch = batches[batchIdx + 1] -- 3716
					if shared.stopToken.stopped then -- 3716
						for ____, action in ipairs(batch.actions) do -- 3718
							if not action.result then -- 3718
								action.result = { -- 3720
									success = false, -- 3720
									message = getCancelledReason(shared) -- 3720
								} -- 3720
							end -- 3720
						end -- 3720
						goto __continue571 -- 3723
					end -- 3723
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 3723
						local preExecCount = #__TS__ArrayFilter( -- 3727
							batch.actions, -- 3727
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 3727
						) -- 3727
						Log( -- 3728
							"Info", -- 3728
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3728
						) -- 3728
						do -- 3728
							local i = 0 -- 3729
							while i < #batch.actions do -- 3729
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 3730
								i = i + 1 -- 3729
							end -- 3729
						end -- 3729
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3732
							batch.actions, -- 3732
							function(____, action) -- 3732
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3732
									if shared.stopToken.stopped then -- 3732
										action.result = { -- 3734
											success = false, -- 3734
											message = getCancelledReason(shared) -- 3734
										} -- 3734
										return ____awaiter_resolve(nil, action) -- 3734
									end -- 3734
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3737
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3738
									action.result = sanitizeToolActionResultForHistory(action, result) -- 3739
									return ____awaiter_resolve(nil, action) -- 3739
								end) -- 3739
							end -- 3732
						))) -- 3732
						do -- 3732
							local i = 0 -- 3742
							while i < #batch.actions do -- 3742
								local action = batch.actions[i + 1] -- 3743
								if not action.result then -- 3743
									action.result = {success = false, message = "tool did not produce a result"} -- 3745
								end -- 3745
								appendToolResultMessage(shared, action) -- 3747
								emitAgentFinishEvent(shared, action) -- 3748
								emitCheckpointEventForAction(shared, action) -- 3749
								i = i + 1 -- 3742
							end -- 3742
						end -- 3742
					else -- 3742
						Log( -- 3752
							"Info", -- 3752
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 3752
						) -- 3752
						do -- 3752
							local i = 0 -- 3753
							while i < #batch.actions do -- 3753
								local action = batch.actions[i + 1] -- 3754
								emitAgentStartEvent(shared, action) -- 3755
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3756
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3757
								action.result = sanitizeToolActionResultForHistory(action, result) -- 3758
								appendToolResultMessage(shared, action) -- 3759
								emitAgentFinishEvent(shared, action) -- 3760
								emitCheckpointEventForAction(shared, action) -- 3761
								persistHistoryState(shared) -- 3762
								if shared.stopToken.stopped then -- 3762
									break -- 3764
								end -- 3764
								i = i + 1 -- 3753
							end -- 3753
						end -- 3753
					end -- 3753
				end -- 3753
				::__continue571:: -- 3753
				batchIdx = batchIdx + 1 -- 3715
			end -- 3715
		end -- 3715
		persistHistoryState(shared) -- 3769
		return ____awaiter_resolve(nil, input.actions) -- 3769
	end) -- 3769
end -- 3707
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3773
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3773
		shared.pendingToolActions = nil -- 3774
		shared.preExecutedResults = nil -- 3775
		persistHistoryState(shared) -- 3776
		__TS__Await(maybeCompressHistory(shared)) -- 3777
		persistHistoryState(shared) -- 3778
		return ____awaiter_resolve(nil, "main") -- 3778
	end) -- 3778
end -- 3773
local EndNode = __TS__Class() -- 3783
EndNode.name = "EndNode" -- 3783
__TS__ClassExtends(EndNode, Node) -- 3783
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3784
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3784
		return ____awaiter_resolve(nil, nil) -- 3784
	end) -- 3784
end -- 3784
local CodingAgentFlow = __TS__Class() -- 3789
CodingAgentFlow.name = "CodingAgentFlow" -- 3789
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3789
function CodingAgentFlow.prototype.____constructor(self, role) -- 3790
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3791
	local read = __TS__New(ReadFileAction, 1, 0) -- 3792
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3793
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3794
	local list = __TS__New(ListFilesAction, 1, 0) -- 3795
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3796
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3797
	local build = __TS__New(BuildAction, 1, 0) -- 3798
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3799
	local edit = __TS__New(EditFileAction, 1, 0) -- 3800
	local batch = __TS__New(BatchToolAction, 1, 0) -- 3801
	local done = __TS__New(EndNode, 1, 0) -- 3802
	main:on("batch_tools", batch) -- 3804
	main:on("grep_files", search) -- 3805
	main:on("search_dora_api", searchDora) -- 3806
	main:on("glob_files", list) -- 3807
	if role == "main" then -- 3807
		main:on("read_file", read) -- 3809
		main:on("delete_file", del) -- 3810
		main:on("build", build) -- 3811
		main:on("edit_file", edit) -- 3812
		main:on("list_sub_agents", listSub) -- 3813
		main:on("spawn_sub_agent", spawn) -- 3814
	else -- 3814
		main:on("read_file", read) -- 3816
		main:on("delete_file", del) -- 3817
		main:on("build", build) -- 3818
		main:on("edit_file", edit) -- 3819
	end -- 3819
	main:on("done", done) -- 3821
	search:on("main", main) -- 3823
	searchDora:on("main", main) -- 3824
	list:on("main", main) -- 3825
	listSub:on("main", main) -- 3826
	spawn:on("main", main) -- 3827
	batch:on("main", main) -- 3828
	read:on("main", main) -- 3829
	del:on("main", main) -- 3830
	build:on("main", main) -- 3831
	edit:on("main", main) -- 3832
	Flow.prototype.____constructor(self, main) -- 3834
end -- 3790
local function runCodingAgentAsync(options) -- 3856
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3856
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3856
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3856
		end -- 3856
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3860
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3861
		if not llmConfigRes.success then -- 3861
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3861
		end -- 3861
		local llmConfig = llmConfigRes.config -- 3867
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3868
		if not taskRes.success then -- 3868
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3868
		end -- 3868
		local compressor = __TS__New(MemoryCompressor, { -- 3875
			compressionThreshold = 0.8, -- 3876
			compressionTargetThreshold = 0.5, -- 3877
			maxCompressionRounds = 3, -- 3878
			projectDir = options.workDir, -- 3879
			llmConfig = llmConfig, -- 3880
			promptPack = options.promptPack, -- 3881
			scope = options.memoryScope -- 3882
		}) -- 3882
		local persistedSession = compressor:getStorage():readSessionState() -- 3884
		local promptPack = compressor:getPromptPack() -- 3885
		local shared = { -- 3887
			sessionId = options.sessionId, -- 3888
			taskId = taskRes.taskId, -- 3889
			role = options.role or "main", -- 3890
			maxSteps = math.max( -- 3891
				1, -- 3891
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 3891
			), -- 3891
			llmMaxTry = math.max( -- 3892
				1, -- 3892
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 3892
			), -- 3892
			step = 0, -- 3893
			done = false, -- 3894
			stopToken = options.stopToken or ({stopped = false}), -- 3895
			response = "", -- 3896
			userQuery = normalizedPrompt, -- 3897
			workingDir = options.workDir, -- 3898
			useChineseResponse = options.useChineseResponse == true, -- 3899
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3900
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 3903
			llmConfig = llmConfig, -- 3904
			onEvent = options.onEvent, -- 3905
			promptPack = promptPack, -- 3906
			history = {}, -- 3907
			messages = persistedSession.messages, -- 3908
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 3909
			carryMessageIndex = persistedSession.carryMessageIndex, -- 3910
			memory = {compressor = compressor}, -- 3912
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 3916
			spawnSubAgent = options.spawnSubAgent, -- 3921
			listSubAgents = options.listSubAgents -- 3922
		} -- 3922
		local ____try = __TS__AsyncAwaiter(function() -- 3922
			emitAgentEvent(shared, { -- 3926
				type = "task_started", -- 3927
				sessionId = shared.sessionId, -- 3928
				taskId = shared.taskId, -- 3929
				prompt = shared.userQuery, -- 3930
				workDir = shared.workingDir, -- 3931
				maxSteps = shared.maxSteps -- 3932
			}) -- 3932
			if shared.stopToken.stopped then -- 3932
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3935
				return ____awaiter_resolve( -- 3935
					nil, -- 3935
					emitAgentTaskFinishEvent( -- 3936
						shared, -- 3936
						false, -- 3936
						getCancelledReason(shared) -- 3936
					) -- 3936
				) -- 3936
			end -- 3936
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3938
			local promptCommand = getPromptCommand(shared.userQuery) -- 3939
			if promptCommand == "clear" then -- 3939
				return ____awaiter_resolve( -- 3939
					nil, -- 3939
					clearSessionHistory(shared) -- 3941
				) -- 3941
			end -- 3941
			if promptCommand == "compact" then -- 3941
				if shared.role == "sub" then -- 3941
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 3945
					return ____awaiter_resolve( -- 3945
						nil, -- 3945
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 3946
					) -- 3946
				end -- 3946
				return ____awaiter_resolve( -- 3946
					nil, -- 3946
					__TS__Await(compactAllHistory(shared)) -- 3954
				) -- 3954
			end -- 3954
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3956
			persistHistoryState(shared) -- 3960
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3961
			__TS__Await(flow:run(shared)) -- 3962
			if shared.stopToken.stopped then -- 3962
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3964
				return ____awaiter_resolve( -- 3964
					nil, -- 3964
					emitAgentTaskFinishEvent( -- 3965
						shared, -- 3965
						false, -- 3965
						getCancelledReason(shared) -- 3965
					) -- 3965
				) -- 3965
			end -- 3965
			if shared.error then -- 3965
				return ____awaiter_resolve( -- 3965
					nil, -- 3965
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3968
				) -- 3968
			end -- 3968
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3971
			return ____awaiter_resolve( -- 3971
				nil, -- 3971
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3972
			) -- 3972
		end) -- 3972
		__TS__Await(____try.catch( -- 3925
			____try, -- 3925
			function(____, e) -- 3925
				return ____awaiter_resolve( -- 3925
					nil, -- 3925
					finalizeAgentFailure( -- 3975
						shared, -- 3975
						tostring(e) -- 3975
					) -- 3975
				) -- 3975
			end -- 3975
		)) -- 3975
	end) -- 3975
end -- 3856
function ____exports.runCodingAgent(options, callback) -- 3979
	local ____self_137 = runCodingAgentAsync(options) -- 3979
	____self_137["then"]( -- 3979
		____self_137, -- 3979
		function(____, result) return callback(result) end -- 3980
	) -- 3980
end -- 3979
return ____exports -- 3979