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
function emitAgentEvent(shared, event) -- 729
	if shared.onEvent then -- 729
		do -- 729
			local function ____catch(____error) -- 729
				Log( -- 734
					"Error", -- 734
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 734
				) -- 734
			end -- 734
			local ____try, ____hasReturned = pcall(function() -- 734
				shared:onEvent(event) -- 732
			end) -- 732
			if not ____try then -- 732
				____catch(____hasReturned) -- 732
			end -- 732
		end -- 732
	end -- 732
end -- 732
function getCancelledReason(shared) -- 795
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 795
		return shared.stopToken.reason -- 796
	end -- 796
	return shared.useChineseResponse and "已取消" or "cancelled" -- 797
end -- 797
function truncateText(text, maxLen) -- 978
	if #text <= maxLen then -- 978
		return text -- 979
	end -- 979
	local nextPos = utf8.offset(text, maxLen + 1) -- 980
	if nextPos == nil then -- 980
		return text -- 981
	end -- 981
	return string.sub(text, 1, nextPos - 1) .. "..." -- 982
end -- 982
function getReplyLanguageDirective(shared) -- 992
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 993
end -- 993
function replacePromptVars(template, vars) -- 998
	local output = template -- 999
	for key in pairs(vars) do -- 1000
		output = table.concat( -- 1001
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 1001
			vars[key] or "" or "," -- 1001
		) -- 1001
	end -- 1001
	return output -- 1003
end -- 1003
function getDecisionToolDefinitions(shared) -- 1154
	local base = replacePromptVars( -- 1155
		shared and shared.promptPack.toolDefinitionsDetailed or "", -- 1156
		{SEARCH_DORA_API_LIMIT_MAX = tostring(SEARCH_DORA_API_LIMIT_MAX)} -- 1157
	) -- 1157
	local spawnTool = "\n\n9. list_sub_agents: Query sub-agent state under the current main session\n\t- Parameters: status(optional), limit(optional), offset(optional), query(optional)\n\t- Use this only when you do not already know the current sub-agent status and need to inspect running delegated work or recent completed results before deciding whether to dispatch more sub agents or read a result file.\n\t- status defaults to active_or_recent and may also be running, done, failed, or all.\n\t- limit defaults to a small recent window. Use offset to page older items.\n\t- query filters by title, goal, or summary text.\n\t- Do not use this after a successful spawn_sub_agent in the same turn.\n\n10. spawn_sub_agent: Create and start a sub agent session for delegated implementation work\n\t- Parameters: title, prompt, expectedOutput(optional), filesHint(optional)\n\t- Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks.\n\t- For small focused edits, use edit_file/delete_file/build directly in the current main-agent run.\n\t- The spawned sub agent can use read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, build, and finish.\n\t- title should be short and specific.\n\t- prompt should be self-contained and actionable, and should clearly describe the concrete work to execute, constraints, desired output, and any relevant files.\n\t- If spawn succeeds, immediately finish the current turn and state that the work has been delegated.\n\t- Do not call list_sub_agents or any other tool after a successful spawn_sub_agent in the same turn.\n\t- Treat the actual implementation result as an asynchronous handoff that will be handled in later conversation turns.\n\t- filesHint is an optional list of likely files or directories." -- 1159
	local availability = shared and (("\n\nTool availability for this runtime:\n- role: " .. shared.role) .. "\n- allowed tools: ") .. table.concat( -- 1180
		getAllowedToolsForRole(shared.role), -- 1181
		", " -- 1181
	) or "" -- 1181
	local withRole = (base .. ((shared and shared.role) == "main" and spawnTool or "")) .. availability -- 1183
	if (shared and shared.decisionMode) ~= "xml" then -- 1183
		return withRole -- 1185
	end -- 1185
	return withRole .. "\n\nXML mode object fields:\n- Use a single root tag: <tool_call>.\n- For read_file, edit_file, delete_file, grep_files, search_dora_api, glob_files, and build, include <tool>, <reason>, and <params>.\n- For finish, do not include <reason>. Use only <tool> and <params><message>...</message></params>.\n- Inside <params>, use one child tag per parameter and preserve each tag content as raw text." -- 1187
end -- 1187
function getFinishMessage(params, fallback) -- 1486
	if fallback == nil then -- 1486
		fallback = "" -- 1486
	end -- 1486
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1486
		return __TS__StringTrim(params.message) -- 1488
	end -- 1488
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1488
		return __TS__StringTrim(params.response) -- 1491
	end -- 1491
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1491
		return __TS__StringTrim(params.summary) -- 1494
	end -- 1494
	return __TS__StringTrim(fallback) -- 1496
end -- 1496
function persistHistoryState(shared) -- 1499
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1500
end -- 1500
function getActiveConversationMessages(shared) -- 1507
	local activeMessages = {} -- 1508
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1508
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1515
	end -- 1515
	do -- 1515
		local i = shared.lastConsolidatedIndex -- 1519
		while i < #shared.messages do -- 1519
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1520
			i = i + 1 -- 1519
		end -- 1519
	end -- 1519
	return activeMessages -- 1522
end -- 1522
function getActiveRealMessageCount(shared) -- 1525
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1526
end -- 1526
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex) -- 1529
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1534
	local previousActiveStart = shared.lastConsolidatedIndex -- 1535
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1536
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1537
	if type(carryMessageIndex) == "number" then -- 1537
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1537
		else -- 1537
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1545
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1548
		end -- 1548
	else -- 1548
		shared.carryMessageIndex = nil -- 1553
	end -- 1553
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1553
		shared.carryMessageIndex = nil -- 1563
	end -- 1563
end -- 1563
function getDecisionPath(params) -- 1820
	if type(params.path) == "string" then -- 1820
		return __TS__StringTrim(params.path) -- 1821
	end -- 1821
	if type(params.target_file) == "string" then -- 1821
		return __TS__StringTrim(params.target_file) -- 1822
	end -- 1822
	return "" -- 1823
end -- 1823
function clampIntegerParam(value, fallback, minValue, maxValue) -- 1826
	local num = __TS__Number(value) -- 1827
	if not __TS__NumberIsFinite(num) then -- 1827
		num = fallback -- 1828
	end -- 1828
	num = math.floor(num) -- 1829
	if num < minValue then -- 1829
		num = minValue -- 1830
	end -- 1830
	if maxValue ~= nil and num > maxValue then -- 1830
		num = maxValue -- 1831
	end -- 1831
	return num -- 1832
end -- 1832
function parseReadLineParam(value, fallback, paramName) -- 1835
	local num = __TS__Number(value) -- 1840
	if not __TS__NumberIsFinite(num) then -- 1840
		num = fallback -- 1841
	end -- 1841
	num = math.floor(num) -- 1842
	if num == 0 then -- 1842
		return {success = false, message = paramName .. " cannot be 0"} -- 1844
	end -- 1844
	return {success = true, value = num} -- 1846
end -- 1846
function validateDecision(tool, params) -- 1849
	if tool == "finish" then -- 1849
		local message = getFinishMessage(params) -- 1854
		if message == "" then -- 1854
			return {success = false, message = "finish requires params.message"} -- 1855
		end -- 1855
		params.message = message -- 1856
		return {success = true, params = params} -- 1857
	end -- 1857
	if tool == "read_file" then -- 1857
		local path = getDecisionPath(params) -- 1861
		if path == "" then -- 1861
			return {success = false, message = "read_file requires path"} -- 1862
		end -- 1862
		params.path = path -- 1863
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 1864
		if not startLineRes.success then -- 1864
			return startLineRes -- 1865
		end -- 1865
		local endLineDefault = startLineRes.value < 0 and -1 or READ_FILE_DEFAULT_LIMIT -- 1866
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 1867
		if not endLineRes.success then -- 1867
			return endLineRes -- 1868
		end -- 1868
		params.startLine = startLineRes.value -- 1869
		params.endLine = endLineRes.value -- 1870
		return {success = true, params = params} -- 1871
	end -- 1871
	if tool == "edit_file" then -- 1871
		local path = getDecisionPath(params) -- 1875
		if path == "" then -- 1875
			return {success = false, message = "edit_file requires path"} -- 1876
		end -- 1876
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 1877
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 1878
		params.path = path -- 1879
		params.old_str = oldStr -- 1880
		params.new_str = newStr -- 1881
		return {success = true, params = params} -- 1882
	end -- 1882
	if tool == "delete_file" then -- 1882
		local targetFile = getDecisionPath(params) -- 1886
		if targetFile == "" then -- 1886
			return {success = false, message = "delete_file requires target_file"} -- 1887
		end -- 1887
		params.target_file = targetFile -- 1888
		return {success = true, params = params} -- 1889
	end -- 1889
	if tool == "grep_files" then -- 1889
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1893
		if pattern == "" then -- 1893
			return {success = false, message = "grep_files requires pattern"} -- 1894
		end -- 1894
		params.pattern = pattern -- 1895
		params.limit = clampIntegerParam(params.limit, SEARCH_FILES_LIMIT_DEFAULT, 1) -- 1896
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1897
		return {success = true, params = params} -- 1898
	end -- 1898
	if tool == "search_dora_api" then -- 1898
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 1902
		if pattern == "" then -- 1902
			return {success = false, message = "search_dora_api requires pattern"} -- 1903
		end -- 1903
		params.pattern = pattern -- 1904
		params.limit = clampIntegerParam(params.limit, 8, 1, SEARCH_DORA_API_LIMIT_MAX) -- 1905
		return {success = true, params = params} -- 1906
	end -- 1906
	if tool == "glob_files" then -- 1906
		params.maxEntries = clampIntegerParam(params.maxEntries, LIST_FILES_MAX_ENTRIES_DEFAULT, 1) -- 1910
		return {success = true, params = params} -- 1911
	end -- 1911
	if tool == "build" then -- 1911
		local path = getDecisionPath(params) -- 1915
		if path ~= "" then -- 1915
			params.path = path -- 1917
		end -- 1917
		return {success = true, params = params} -- 1919
	end -- 1919
	if tool == "list_sub_agents" then -- 1919
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 1923
		if status ~= "" then -- 1923
			params.status = status -- 1925
		end -- 1925
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 1927
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 1928
		if type(params.query) == "string" then -- 1928
			params.query = __TS__StringTrim(params.query) -- 1930
		end -- 1930
		return {success = true, params = params} -- 1932
	end -- 1932
	if tool == "spawn_sub_agent" then -- 1932
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 1936
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 1937
		if prompt == "" then -- 1937
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 1938
		end -- 1938
		if title == "" then -- 1938
			return {success = false, message = "spawn_sub_agent requires title"} -- 1939
		end -- 1939
		params.prompt = prompt -- 1940
		params.title = title -- 1941
		if type(params.expectedOutput) == "string" then -- 1941
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 1943
		end -- 1943
		if isArray(params.filesHint) then -- 1943
			params.filesHint = __TS__ArrayMap( -- 1946
				__TS__ArrayFilter( -- 1946
					params.filesHint, -- 1946
					function(____, item) return type(item) == "string" end -- 1947
				), -- 1947
				function(____, item) return sanitizeUTF8(item) end -- 1948
			) -- 1948
		end -- 1948
		return {success = true, params = params} -- 1950
	end -- 1950
	return {success = true, params = params} -- 1953
end -- 1953
function getAllowedToolsForRole(role) -- 1979
	return role == "main" and ({ -- 1980
		"read_file", -- 1981
		"edit_file", -- 1981
		"delete_file", -- 1981
		"grep_files", -- 1981
		"search_dora_api", -- 1981
		"glob_files", -- 1981
		"build", -- 1981
		"list_sub_agents", -- 1981
		"spawn_sub_agent", -- 1981
		"finish" -- 1981
	}) or ({ -- 1981
		"read_file", -- 1982
		"edit_file", -- 1982
		"delete_file", -- 1982
		"grep_files", -- 1982
		"search_dora_api", -- 1982
		"glob_files", -- 1982
		"build", -- 1982
		"finish" -- 1982
	}) -- 1982
end -- 1982
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2088
	if includeToolDefinitions == nil then -- 2088
		includeToolDefinitions = false -- 2088
	end -- 2088
	local rolePrompt = shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt -- 2089
	local sections = { -- 2092
		shared.promptPack.agentIdentityPrompt, -- 2093
		rolePrompt, -- 2094
		getReplyLanguageDirective(shared) -- 2095
	} -- 2095
	if shared.decisionMode == "tool_calling" then -- 2095
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2098
	end -- 2098
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2100
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2101
	if memoryContext ~= "" then -- 2101
		sections[#sections + 1] = memoryContext -- 2103
	end -- 2103
	if includeToolDefinitions then -- 2103
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2106
		if shared.decisionMode == "xml" then -- 2106
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2108
		end -- 2108
	end -- 2108
	local skillsSection = buildSkillsSection(shared) -- 2112
	if skillsSection ~= "" then -- 2112
		sections[#sections + 1] = skillsSection -- 2114
	end -- 2114
	return table.concat(sections, "\n\n") -- 2116
end -- 2116
function buildSkillsSection(shared) -- 2119
	local ____opt_42 = shared.skills -- 2119
	if not (____opt_42 and ____opt_42.loader) then -- 2119
		return "" -- 2121
	end -- 2121
	return shared.skills.loader:buildSkillsPromptSection() -- 2123
end -- 2123
function buildXmlDecisionInstruction(shared, feedback) -- 2241
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2242
end -- 2242
function executeToolAction(shared, action) -- 3423
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3423
		if shared.stopToken.stopped then -- 3423
			return ____awaiter_resolve( -- 3423
				nil, -- 3423
				{ -- 3425
					success = false, -- 3425
					message = getCancelledReason(shared) -- 3425
				} -- 3425
			) -- 3425
		end -- 3425
		local params = action.params -- 3427
		if action.tool == "read_file" then -- 3427
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3429
			if __TS__StringTrim(path) == "" then -- 3429
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3429
			end -- 3429
			local ____Tools_readFile_104 = Tools.readFile -- 3433
			local ____shared_workingDir_102 = shared.workingDir -- 3434
			local ____params_startLine_100 = params.startLine -- 3436
			if ____params_startLine_100 == nil then -- 3436
				____params_startLine_100 = 1 -- 3436
			end -- 3436
			local ____TS__Number_result_103 = __TS__Number(____params_startLine_100) -- 3436
			local ____params_endLine_101 = params.endLine -- 3437
			if ____params_endLine_101 == nil then -- 3437
				____params_endLine_101 = READ_FILE_DEFAULT_LIMIT -- 3437
			end -- 3437
			return ____awaiter_resolve( -- 3437
				nil, -- 3437
				____Tools_readFile_104( -- 3433
					____shared_workingDir_102, -- 3434
					path, -- 3435
					____TS__Number_result_103, -- 3436
					__TS__Number(____params_endLine_101), -- 3437
					shared.useChineseResponse and "zh" or "en" -- 3438
				) -- 3438
			) -- 3438
		end -- 3438
		if action.tool == "grep_files" then -- 3438
			local ____Tools_searchFiles_118 = Tools.searchFiles -- 3442
			local ____shared_workingDir_111 = shared.workingDir -- 3443
			local ____temp_112 = params.path or "" -- 3444
			local ____temp_113 = params.pattern or "" -- 3445
			local ____params_globs_114 = params.globs -- 3446
			local ____params_useRegex_115 = params.useRegex -- 3447
			local ____params_caseSensitive_116 = params.caseSensitive -- 3448
			local ____math_max_107 = math.max -- 3451
			local ____math_floor_106 = math.floor -- 3451
			local ____params_limit_105 = params.limit -- 3451
			if ____params_limit_105 == nil then -- 3451
				____params_limit_105 = SEARCH_FILES_LIMIT_DEFAULT -- 3451
			end -- 3451
			local ____math_max_107_result_117 = ____math_max_107( -- 3451
				1, -- 3451
				____math_floor_106(__TS__Number(____params_limit_105)) -- 3451
			) -- 3451
			local ____math_max_110 = math.max -- 3452
			local ____math_floor_109 = math.floor -- 3452
			local ____params_offset_108 = params.offset -- 3452
			if ____params_offset_108 == nil then -- 3452
				____params_offset_108 = 0 -- 3452
			end -- 3452
			local result = __TS__Await(____Tools_searchFiles_118({ -- 3442
				workDir = ____shared_workingDir_111, -- 3443
				path = ____temp_112, -- 3444
				pattern = ____temp_113, -- 3445
				globs = ____params_globs_114, -- 3446
				useRegex = ____params_useRegex_115, -- 3447
				caseSensitive = ____params_caseSensitive_116, -- 3448
				includeContent = true, -- 3449
				contentWindow = SEARCH_PREVIEW_CONTEXT, -- 3450
				limit = ____math_max_107_result_117, -- 3451
				offset = ____math_max_110( -- 3452
					0, -- 3452
					____math_floor_109(__TS__Number(____params_offset_108)) -- 3452
				), -- 3452
				groupByFile = params.groupByFile == true -- 3453
			})) -- 3453
			return ____awaiter_resolve(nil, result) -- 3453
		end -- 3453
		if action.tool == "search_dora_api" then -- 3453
			local ____Tools_searchDoraAPI_126 = Tools.searchDoraAPI -- 3458
			local ____temp_122 = params.pattern or "" -- 3459
			local ____temp_123 = params.docSource or "api" -- 3460
			local ____temp_124 = shared.useChineseResponse and "zh" or "en" -- 3461
			local ____temp_125 = params.programmingLanguage or "ts" -- 3462
			local ____math_min_121 = math.min -- 3463
			local ____math_max_120 = math.max -- 3463
			local ____params_limit_119 = params.limit -- 3463
			if ____params_limit_119 == nil then -- 3463
				____params_limit_119 = 8 -- 3463
			end -- 3463
			local result = __TS__Await(____Tools_searchDoraAPI_126({ -- 3458
				pattern = ____temp_122, -- 3459
				docSource = ____temp_123, -- 3460
				docLanguage = ____temp_124, -- 3461
				programmingLanguage = ____temp_125, -- 3462
				limit = ____math_min_121( -- 3463
					SEARCH_DORA_API_LIMIT_MAX, -- 3463
					____math_max_120( -- 3463
						1, -- 3463
						__TS__Number(____params_limit_119) -- 3463
					) -- 3463
				), -- 3463
				useRegex = params.useRegex, -- 3464
				caseSensitive = false, -- 3465
				includeContent = true, -- 3466
				contentWindow = SEARCH_PREVIEW_CONTEXT -- 3467
			})) -- 3467
			return ____awaiter_resolve(nil, result) -- 3467
		end -- 3467
		if action.tool == "glob_files" then -- 3467
			local ____Tools_listFiles_133 = Tools.listFiles -- 3472
			local ____shared_workingDir_130 = shared.workingDir -- 3473
			local ____temp_131 = params.path or "" -- 3474
			local ____params_globs_132 = params.globs -- 3475
			local ____math_max_129 = math.max -- 3476
			local ____math_floor_128 = math.floor -- 3476
			local ____params_maxEntries_127 = params.maxEntries -- 3476
			if ____params_maxEntries_127 == nil then -- 3476
				____params_maxEntries_127 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3476
			end -- 3476
			local result = ____Tools_listFiles_133({ -- 3472
				workDir = ____shared_workingDir_130, -- 3473
				path = ____temp_131, -- 3474
				globs = ____params_globs_132, -- 3475
				maxEntries = ____math_max_129( -- 3476
					1, -- 3476
					____math_floor_128(__TS__Number(____params_maxEntries_127)) -- 3476
				) -- 3476
			}) -- 3476
			return ____awaiter_resolve(nil, result) -- 3476
		end -- 3476
		if action.tool == "delete_file" then -- 3476
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 3481
			if __TS__StringTrim(targetFile) == "" then -- 3481
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 3481
			end -- 3481
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 3485
			if not result.success then -- 3485
				return ____awaiter_resolve(nil, result) -- 3485
			end -- 3485
			return ____awaiter_resolve(nil, { -- 3485
				success = true, -- 3493
				changed = true, -- 3494
				mode = "delete", -- 3495
				checkpointId = result.checkpointId, -- 3496
				checkpointSeq = result.checkpointSeq, -- 3497
				files = {{path = targetFile, op = "delete"}} -- 3498
			}) -- 3498
		end -- 3498
		if action.tool == "build" then -- 3498
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = params.path or ""})) -- 3502
			return ____awaiter_resolve(nil, result) -- 3502
		end -- 3502
		if action.tool == "spawn_sub_agent" then -- 3502
			if not shared.spawnSubAgent then -- 3502
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3502
			end -- 3502
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3502
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3502
			end -- 3502
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 3515
				params.filesHint, -- 3516
				function(____, item) return type(item) == "string" end -- 3516
			) or nil -- 3516
			local result = __TS__Await(shared.spawnSubAgent({ -- 3518
				parentSessionId = shared.sessionId, -- 3519
				projectRoot = shared.workingDir, -- 3520
				title = type(params.title) == "string" and params.title or "Sub", -- 3521
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 3522
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 3523
				filesHint = filesHint -- 3524
			})) -- 3524
			if not result.success then -- 3524
				return ____awaiter_resolve(nil, result) -- 3524
			end -- 3524
			return ____awaiter_resolve(nil, { -- 3524
				success = true, -- 3530
				sessionId = result.sessionId, -- 3531
				taskId = result.taskId, -- 3532
				title = result.title, -- 3533
				hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3534
			}) -- 3534
		end -- 3534
		if action.tool == "list_sub_agents" then -- 3534
			if not shared.listSubAgents then -- 3534
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3534
			end -- 3534
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 3534
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3534
			end -- 3534
			local result = __TS__Await(shared.listSubAgents({ -- 3544
				sessionId = shared.sessionId, -- 3545
				projectRoot = shared.workingDir, -- 3546
				status = type(params.status) == "string" and params.status or nil, -- 3547
				limit = type(params.limit) == "number" and params.limit or nil, -- 3548
				offset = type(params.offset) == "number" and params.offset or nil, -- 3549
				query = type(params.query) == "string" and params.query or nil -- 3550
			})) -- 3550
			return ____awaiter_resolve(nil, result) -- 3550
		end -- 3550
		if action.tool == "edit_file" then -- 3550
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 3555
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 3558
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 3559
			if __TS__StringTrim(path) == "" then -- 3559
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3559
			end -- 3559
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 3561
			return ____awaiter_resolve( -- 3561
				nil, -- 3561
				actionNode:exec({ -- 3562
					path = path, -- 3563
					oldStr = oldStr, -- 3564
					newStr = newStr, -- 3565
					taskId = shared.taskId, -- 3566
					workDir = shared.workingDir -- 3567
				}) -- 3567
			) -- 3567
		end -- 3567
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 3567
	end) -- 3567
end -- 3567
function emitAgentTaskFinishEvent(shared, success, message) -- 3753
	local result = {success = success, taskId = shared.taskId, message = message, steps = shared.step} -- 3754
	emitAgentEvent(shared, { -- 3760
		type = "task_finished", -- 3761
		sessionId = shared.sessionId, -- 3762
		taskId = shared.taskId, -- 3763
		success = result.success, -- 3764
		message = result.message, -- 3765
		steps = result.steps -- 3766
	}) -- 3766
	return result -- 3768
end -- 3768
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
local HISTORY_BUILD_MAX_MESSAGES = 50 -- 648
local HISTORY_BUILD_MESSAGE_MAX_CHARS = 1200 -- 649
SEARCH_DORA_API_LIMIT_MAX = 20 -- 650
SEARCH_FILES_LIMIT_DEFAULT = 20 -- 651
LIST_FILES_MAX_ENTRIES_DEFAULT = 200 -- 652
SEARCH_PREVIEW_CONTEXT = 80 -- 653
local AGENT_DEFAULT_MAX_STEPS = 100 -- 654
local AGENT_DEFAULT_LLM_MAX_TRY = 5 -- 655
local AGENT_DEFAULT_LLM_TEMPERATURE = 0.1 -- 656
local AGENT_DEFAULT_LLM_MAX_TOKENS = 8192 -- 657
local function buildLLMOptions(llmConfig, overrides) -- 659
	local options = {temperature = llmConfig.temperature or AGENT_DEFAULT_LLM_TEMPERATURE, max_tokens = llmConfig.maxTokens or AGENT_DEFAULT_LLM_MAX_TOKENS} -- 660
	if llmConfig.reasoningEffort then -- 660
		options.reasoning_effort = llmConfig.reasoningEffort -- 665
	end -- 665
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 667
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 667
		__TS__Delete(merged, "reasoning_effort") -- 672
	else -- 672
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 674
	end -- 674
	return merged -- 676
end -- 659
local function emitAgentStartEvent(shared, action) -- 739
	emitAgentEvent(shared, { -- 740
		type = "tool_started", -- 741
		sessionId = shared.sessionId, -- 742
		taskId = shared.taskId, -- 743
		step = action.step, -- 744
		tool = action.tool -- 745
	}) -- 745
end -- 739
local function emitAgentFinishEvent(shared, action) -- 749
	emitAgentEvent(shared, { -- 750
		type = "tool_finished", -- 751
		sessionId = shared.sessionId, -- 752
		taskId = shared.taskId, -- 753
		step = action.step, -- 754
		tool = action.tool, -- 755
		result = action.result or ({}) -- 756
	}) -- 756
end -- 749
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 760
	emitAgentEvent(shared, { -- 761
		type = "assistant_message_updated", -- 762
		sessionId = shared.sessionId, -- 763
		taskId = shared.taskId, -- 764
		step = shared.step + 1, -- 765
		content = content, -- 766
		reasoningContent = reasoningContent -- 767
	}) -- 767
end -- 760
local function getMemoryCompressionStartReason(shared) -- 771
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 772
end -- 771
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 777
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 778
end -- 777
local function getMemoryCompressionFailureReason(shared, ____error) -- 783
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 784
end -- 783
local function summarizeHistoryEntryPreview(text, maxChars) -- 789
	if maxChars == nil then -- 789
		maxChars = 180 -- 789
	end -- 789
	local trimmed = __TS__StringTrim(text) -- 790
	if trimmed == "" then -- 790
		return "" -- 791
	end -- 791
	return truncateText(trimmed, maxChars) -- 792
end -- 789
local function getMaxStepsReachedReason(shared) -- 800
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 801
end -- 800
local function getFailureSummaryFallback(shared, ____error) -- 806
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 807
end -- 806
local function finalizeAgentFailure(shared, ____error) -- 812
	if shared.stopToken.stopped then -- 812
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 814
		return emitAgentTaskFinishEvent( -- 815
			shared, -- 815
			false, -- 815
			getCancelledReason(shared) -- 815
		) -- 815
	end -- 815
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 817
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 818
end -- 812
local function getPromptCommand(prompt) -- 821
	local trimmed = __TS__StringTrim(prompt) -- 822
	if trimmed == "/compact" then -- 822
		return "compact" -- 823
	end -- 823
	if trimmed == "/clear" then -- 823
		return "clear" -- 824
	end -- 824
	return nil -- 825
end -- 821
function ____exports.truncateAgentUserPrompt(prompt) -- 828
	if not prompt then -- 828
		return "" -- 829
	end -- 829
	if #prompt <= ____exports.AGENT_USER_PROMPT_MAX_CHARS then -- 829
		return prompt -- 830
	end -- 830
	local offset = utf8.offset(prompt, ____exports.AGENT_USER_PROMPT_MAX_CHARS + 1) -- 831
	if offset == nil then -- 831
		return prompt -- 832
	end -- 832
	return string.sub(prompt, 1, offset - 1) -- 833
end -- 828
local function canWriteStepLLMDebug(shared, stepId) -- 836
	if stepId == nil then -- 836
		stepId = shared.step + 1 -- 836
	end -- 836
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 837
end -- 836
local function ensureDirRecursive(dir) -- 844
	if not dir then -- 844
		return false -- 845
	end -- 845
	if Content:exist(dir) then -- 845
		return Content:isdir(dir) -- 846
	end -- 846
	local parent = Path:getPath(dir) -- 847
	if parent and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 847
		return false -- 849
	end -- 849
	return Content:mkdir(dir) -- 851
end -- 844
local function encodeDebugJSON(value) -- 854
	local text, err = safeJsonEncode(value) -- 855
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 856
end -- 854
local function getStepLLMDebugDir(shared) -- 859
	return Path( -- 860
		shared.workingDir, -- 861
		".agent", -- 862
		tostring(shared.sessionId), -- 863
		tostring(shared.taskId) -- 864
	) -- 864
end -- 859
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 868
	return Path( -- 869
		getStepLLMDebugDir(shared), -- 869
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 869
	) -- 869
end -- 868
local function getLatestStepLLMDebugSeq(shared, stepId) -- 872
	if not canWriteStepLLMDebug(shared, stepId) then -- 872
		return 0 -- 873
	end -- 873
	local dir = getStepLLMDebugDir(shared) -- 874
	if not Content:exist(dir) or not Content:isdir(dir) then -- 874
		return 0 -- 875
	end -- 875
	local latest = 0 -- 876
	for ____, file in ipairs(Content:getFiles(dir)) do -- 877
		do -- 877
			local name = Path:getFilename(file) -- 878
			local seqText = string.match( -- 879
				name, -- 879
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 879
			) -- 879
			if seqText ~= nil then -- 879
				latest = math.max( -- 881
					latest, -- 881
					tonumber(seqText) -- 881
				) -- 881
				goto __continue124 -- 882
			end -- 882
			local legacyMatch = string.match( -- 884
				name, -- 884
				("^" .. tostring(stepId)) .. "_in%.md$" -- 884
			) -- 884
			if legacyMatch ~= nil then -- 884
				latest = math.max(latest, 1) -- 886
			end -- 886
		end -- 886
		::__continue124:: -- 886
	end -- 886
	return latest -- 889
end -- 872
local function writeStepLLMDebugFile(path, content) -- 892
	if not Content:save(path, content) then -- 892
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 894
		return false -- 895
	end -- 895
	return true -- 897
end -- 892
local function createStepLLMDebugPair(shared, stepId, inContent) -- 900
	if not canWriteStepLLMDebug(shared, stepId) then -- 900
		return 0 -- 901
	end -- 901
	local dir = getStepLLMDebugDir(shared) -- 902
	if not ensureDirRecursive(dir) then -- 902
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 904
		return 0 -- 905
	end -- 905
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 907
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 908
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 909
	if not writeStepLLMDebugFile(inPath, inContent) then -- 909
		return 0 -- 911
	end -- 911
	writeStepLLMDebugFile(outPath, "") -- 913
	return seq -- 914
end -- 900
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 917
	if not canWriteStepLLMDebug(shared, stepId) then -- 917
		return -- 918
	end -- 918
	local dir = getStepLLMDebugDir(shared) -- 919
	if not ensureDirRecursive(dir) then -- 919
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 921
		return -- 922
	end -- 922
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 924
	if latestSeq <= 0 then -- 924
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 926
		writeStepLLMDebugFile(outPath, content) -- 927
		return -- 928
	end -- 928
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 930
	writeStepLLMDebugFile(outPath, content) -- 931
end -- 917
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 934
	if not canWriteStepLLMDebug(shared, stepId) then -- 934
		return -- 935
	end -- 935
	local sections = { -- 936
		"# LLM Input", -- 937
		"session_id: " .. tostring(shared.sessionId), -- 938
		"task_id: " .. tostring(shared.taskId), -- 939
		"step_id: " .. tostring(stepId), -- 940
		"phase: " .. phase, -- 941
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 942
		"## Options", -- 943
		"```json", -- 944
		encodeDebugJSON(options), -- 945
		"```" -- 946
	} -- 946
	do -- 946
		local i = 0 -- 948
		while i < #messages do -- 948
			local message = messages[i + 1] -- 949
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 950
			sections[#sections + 1] = encodeDebugJSON(message) -- 951
			i = i + 1 -- 948
		end -- 948
	end -- 948
	createStepLLMDebugPair( -- 953
		shared, -- 953
		stepId, -- 953
		table.concat(sections, "\n") -- 953
	) -- 953
end -- 934
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 956
	if not canWriteStepLLMDebug(shared, stepId) then -- 956
		return -- 957
	end -- 957
	local ____array_2 = __TS__SparseArrayNew( -- 957
		"# LLM Output", -- 959
		"session_id: " .. tostring(shared.sessionId), -- 960
		"task_id: " .. tostring(shared.taskId), -- 961
		"step_id: " .. tostring(stepId), -- 962
		"phase: " .. phase, -- 963
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 964
		table.unpack(meta and ({ -- 965
			"## Meta", -- 965
			"```json", -- 965
			encodeDebugJSON(meta), -- 965
			"```" -- 965
		}) or ({})) -- 965
	) -- 965
	__TS__SparseArrayPush(____array_2, "## Content", text) -- 965
	local sections = {__TS__SparseArraySpread(____array_2)} -- 958
	updateLatestStepLLMDebugOutput( -- 969
		shared, -- 969
		stepId, -- 969
		table.concat(sections, "\n") -- 969
	) -- 969
end -- 956
local function toJson(value) -- 972
	local text, err = safeJsonEncode(value) -- 973
	if text ~= nil then -- 973
		return text -- 974
	end -- 974
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 975
end -- 972
local function utf8TakeHead(text, maxChars) -- 985
	if maxChars <= 0 or text == "" then -- 985
		return "" -- 986
	end -- 986
	local nextPos = utf8.offset(text, maxChars + 1) -- 987
	if nextPos == nil then -- 987
		return text -- 988
	end -- 988
	return string.sub(text, 1, nextPos - 1) -- 989
end -- 985
local function limitReadContentForHistory(content, tool) -- 1006
	local lines = __TS__StringSplit(content, "\n") -- 1007
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 1008
	local limitedByLines = overLineLimit and table.concat( -- 1009
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 1010
		"\n" -- 1010
	) or content -- 1010
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 1010
		return content -- 1013
	end -- 1013
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and utf8TakeHead(limitedByLines, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 1015
	local reasons = {} -- 1018
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 1018
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 1019
	end -- 1019
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 1019
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 1020
	end -- 1020
	local hint = "Narrow the requested line range." -- 1021
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 1022
end -- 1006
local function summarizeEditTextParamForHistory(value, key) -- 1025
	if type(value) ~= "string" then -- 1025
		return nil -- 1026
	end -- 1026
	local text = value -- 1027
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 1028
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 1029
end -- 1025
local function sanitizeReadResultForHistory(tool, result) -- 1037
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 1037
		return result -- 1039
	end -- 1039
	local clone = {} -- 1041
	for key in pairs(result) do -- 1042
		clone[key] = result[key] -- 1043
	end -- 1043
	clone.content = limitReadContentForHistory(result.content, tool) -- 1045
	return clone -- 1046
end -- 1037
local function sanitizeSearchMatchesForHistory(items, maxItems) -- 1049
	local shown = math.min(#items, maxItems) -- 1053
	local out = {} -- 1054
	do -- 1054
		local i = 0 -- 1055
		while i < shown do -- 1055
			local row = items[i + 1] -- 1056
			out[#out + 1] = { -- 1057
				file = row.file, -- 1058
				line = row.line, -- 1059
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 1060
			} -- 1060
			i = i + 1 -- 1055
		end -- 1055
	end -- 1055
	return out -- 1065
end -- 1049
local function sanitizeSearchResultForHistory(tool, result) -- 1068
	if result.success ~= true or not isArray(result.results) then -- 1068
		return result -- 1072
	end -- 1072
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 1072
		return result -- 1073
	end -- 1073
	local clone = {} -- 1074
	for key in pairs(result) do -- 1075
		clone[key] = result[key] -- 1076
	end -- 1076
	local maxItems = tool == "grep_files" and HISTORY_SEARCH_FILES_MAX_MATCHES or HISTORY_SEARCH_DORA_API_MAX_MATCHES -- 1078
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 1079
	if tool == "grep_files" and isArray(result.groupedResults) then -- 1079
		local grouped = result.groupedResults -- 1084
		local shown = math.min(#grouped, HISTORY_SEARCH_FILES_MAX_MATCHES) -- 1085
		local sanitizedGroups = {} -- 1086
		do -- 1086
			local i = 0 -- 1087
			while i < shown do -- 1087
				local row = grouped[i + 1] -- 1088
				sanitizedGroups[#sanitizedGroups + 1] = { -- 1089
					file = row.file, -- 1090
					totalMatches = row.totalMatches, -- 1091
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 1092
				} -- 1092
				i = i + 1 -- 1087
			end -- 1087
		end -- 1087
		clone.groupedResults = sanitizedGroups -- 1097
	end -- 1097
	return clone -- 1099
end -- 1068
local function sanitizeListFilesResultForHistory(result) -- 1102
	if result.success ~= true or not isArray(result.files) then -- 1102
		return result -- 1103
	end -- 1103
	local clone = {} -- 1104
	for key in pairs(result) do -- 1105
		clone[key] = result[key] -- 1106
	end -- 1106
	clone.files = __TS__ArraySlice(result.files, 0, HISTORY_LIST_FILES_MAX_ENTRIES) -- 1108
	return clone -- 1109
end -- 1102
local function sanitizeBuildResultForHistory(result) -- 1112
	if not isArray(result.messages) then -- 1112
		return result -- 1113
	end -- 1113
	local clone = {} -- 1114
	for key in pairs(result) do -- 1115
		clone[key] = result[key] -- 1116
	end -- 1116
	local messages = result.messages -- 1118
	local shown = math.min(#messages, HISTORY_BUILD_MAX_MESSAGES) -- 1119
	local sanitized = {} -- 1120
	do -- 1120
		local i = 0 -- 1121
		while i < shown do -- 1121
			local item = messages[i + 1] -- 1122
			local next = {} -- 1123
			for key in pairs(item) do -- 1124
				local value = item[key] -- 1125
				next[key] = key == "message" and type(value) == "string" and truncateText(value, HISTORY_BUILD_MESSAGE_MAX_CHARS) or value -- 1126
			end -- 1126
			sanitized[#sanitized + 1] = next -- 1130
			i = i + 1 -- 1121
		end -- 1121
	end -- 1121
	clone.messages = sanitized -- 1132
	if #messages > shown then -- 1132
		clone.truncatedMessages = #messages - shown -- 1134
	end -- 1134
	return clone -- 1136
end -- 1112
local function sanitizeActionParamsForHistory(tool, params) -- 1139
	if tool ~= "edit_file" then -- 1139
		return params -- 1140
	end -- 1140
	local clone = {} -- 1141
	for key in pairs(params) do -- 1142
		if key == "old_str" then -- 1142
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1144
		elseif key == "new_str" then -- 1144
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1146
		else -- 1146
			clone[key] = params[key] -- 1148
		end -- 1148
	end -- 1148
	return clone -- 1151
end -- 1139
local function isToolAllowedForRole(role, tool) -- 1196
	return __TS__ArrayIndexOf( -- 1197
		getAllowedToolsForRole(role), -- 1197
		tool -- 1197
	) >= 0 -- 1197
end -- 1196
local PRE_EXEC_SAFE_TOOLS = { -- 1200
	"read_file", -- 1201
	"grep_files", -- 1202
	"search_dora_api", -- 1203
	"glob_files", -- 1204
	"list_sub_agents" -- 1205
} -- 1205
local function canPreExecuteTool(tool) -- 1208
	return __TS__ArrayIndexOf(PRE_EXEC_SAFE_TOOLS, tool) >= 0 -- 1209
end -- 1208
local function clearPreExecutedResults(shared) -- 1212
	shared.preExecutedResults = nil -- 1213
end -- 1212
local function startPreExecutedToolAction(shared, action) -- 1216
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1216
		local ____try = __TS__AsyncAwaiter(function() -- 1216
			return ____awaiter_resolve( -- 1216
				nil, -- 1216
				__TS__Await(executeToolAction(shared, action)) -- 1218
			) -- 1218
		end) -- 1218
		__TS__Await(____try.catch( -- 1217
			____try, -- 1217
			function(____, err) -- 1217
				local message = tostring(err) -- 1220
				Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1221
				return ____awaiter_resolve(nil, {success = false, message = message}) -- 1221
			end -- 1221
		)) -- 1221
	end) -- 1221
end -- 1216
local function executeToolActionWithPreExecution(shared, action) -- 1226
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1226
		local ____opt_9 = shared.preExecutedResults -- 1226
		local preResult = ____opt_9 and ____opt_9:get(action.toolCallId) -- 1227
		if preResult then -- 1227
			Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1229
			local ____opt_11 = shared.preExecutedResults -- 1229
			if ____opt_11 ~= nil then -- 1229
				____opt_11:delete(action.toolCallId) -- 1230
			end -- 1230
			return ____awaiter_resolve( -- 1230
				nil, -- 1230
				__TS__Await(preResult) -- 1231
			) -- 1231
		end -- 1231
		return ____awaiter_resolve( -- 1231
			nil, -- 1231
			executeToolAction(shared, action) -- 1233
		) -- 1233
	end) -- 1233
end -- 1226
local function maybeCompressHistory(shared) -- 1236
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1236
		local ____shared_13 = shared -- 1237
		local memory = ____shared_13.memory -- 1237
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1238
		local changed = false -- 1239
		do -- 1239
			local round = 0 -- 1240
			while round < maxRounds do -- 1240
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1241
				local activeMessages = getActiveConversationMessages(shared) -- 1242
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolDefinitions(shared) or "" -- 1246
				if not memory.compressor:shouldCompress(activeMessages, systemPrompt, toolDefinitions) then -- 1246
					if changed then -- 1246
						persistHistoryState(shared) -- 1255
					end -- 1255
					return ____awaiter_resolve(nil) -- 1255
				end -- 1255
				local compressionRound = round + 1 -- 1259
				shared.step = shared.step + 1 -- 1260
				local stepId = shared.step -- 1261
				local pendingMessages = #activeMessages -- 1262
				emitAgentEvent( -- 1263
					shared, -- 1263
					{ -- 1263
						type = "memory_compression_started", -- 1264
						sessionId = shared.sessionId, -- 1265
						taskId = shared.taskId, -- 1266
						step = stepId, -- 1267
						tool = "compress_memory", -- 1268
						reason = getMemoryCompressionStartReason(shared), -- 1269
						params = {round = compressionRound, maxRounds = maxRounds, pendingMessages = pendingMessages} -- 1270
					} -- 1270
				) -- 1270
				local result = __TS__Await(memory.compressor:compress( -- 1276
					activeMessages, -- 1277
					shared.llmOptions, -- 1278
					shared.llmMaxTry, -- 1279
					shared.decisionMode, -- 1280
					{ -- 1281
						onInput = function(____, phase, messages, options) -- 1282
							saveStepLLMDebugInput( -- 1283
								shared, -- 1283
								stepId, -- 1283
								phase, -- 1283
								messages, -- 1283
								options -- 1283
							) -- 1283
						end, -- 1282
						onOutput = function(____, phase, text, meta) -- 1285
							saveStepLLMDebugOutput( -- 1286
								shared, -- 1286
								stepId, -- 1286
								phase, -- 1286
								text, -- 1286
								meta -- 1286
							) -- 1286
						end -- 1285
					}, -- 1285
					"default", -- 1289
					systemPrompt, -- 1290
					toolDefinitions -- 1291
				)) -- 1291
				if not (result and result.success and result.compressedCount > 0) then -- 1291
					emitAgentEvent( -- 1294
						shared, -- 1294
						{ -- 1294
							type = "memory_compression_finished", -- 1295
							sessionId = shared.sessionId, -- 1296
							taskId = shared.taskId, -- 1297
							step = stepId, -- 1298
							tool = "compress_memory", -- 1299
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1300
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1304
						} -- 1304
					) -- 1304
					if changed then -- 1304
						persistHistoryState(shared) -- 1312
					end -- 1312
					return ____awaiter_resolve(nil) -- 1312
				end -- 1312
				local effectiveCompressedCount = math.max( -- 1316
					0, -- 1317
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1318
				) -- 1318
				if effectiveCompressedCount <= 0 then -- 1318
					if changed then -- 1318
						persistHistoryState(shared) -- 1322
					end -- 1322
					return ____awaiter_resolve(nil) -- 1322
				end -- 1322
				emitAgentEvent( -- 1326
					shared, -- 1326
					{ -- 1326
						type = "memory_compression_finished", -- 1327
						sessionId = shared.sessionId, -- 1328
						taskId = shared.taskId, -- 1329
						step = stepId, -- 1330
						tool = "compress_memory", -- 1331
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1332
						result = { -- 1333
							success = true, -- 1334
							round = compressionRound, -- 1335
							compressedCount = effectiveCompressedCount, -- 1336
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1337
						} -- 1337
					} -- 1337
				) -- 1337
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1340
				changed = true -- 1341
				Log( -- 1342
					"Info", -- 1342
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1342
				) -- 1342
				round = round + 1 -- 1240
			end -- 1240
		end -- 1240
		if changed then -- 1240
			persistHistoryState(shared) -- 1345
		end -- 1345
	end) -- 1345
end -- 1236
local function compactAllHistory(shared) -- 1349
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1349
		local ____shared_20 = shared -- 1350
		local memory = ____shared_20.memory -- 1350
		local rounds = 0 -- 1351
		local totalCompressed = 0 -- 1352
		while getActiveRealMessageCount(shared) > 0 do -- 1352
			if shared.stopToken.stopped then -- 1352
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1355
				return ____awaiter_resolve( -- 1355
					nil, -- 1355
					emitAgentTaskFinishEvent( -- 1356
						shared, -- 1356
						false, -- 1356
						getCancelledReason(shared) -- 1356
					) -- 1356
				) -- 1356
			end -- 1356
			rounds = rounds + 1 -- 1358
			shared.step = shared.step + 1 -- 1359
			local stepId = shared.step -- 1360
			local activeMessages = getActiveConversationMessages(shared) -- 1361
			local pendingMessages = #activeMessages -- 1362
			emitAgentEvent( -- 1363
				shared, -- 1363
				{ -- 1363
					type = "memory_compression_started", -- 1364
					sessionId = shared.sessionId, -- 1365
					taskId = shared.taskId, -- 1366
					step = stepId, -- 1367
					tool = "compress_memory", -- 1368
					reason = getMemoryCompressionStartReason(shared), -- 1369
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1370
				} -- 1370
			) -- 1370
			local result = __TS__Await(memory.compressor:compress( -- 1377
				activeMessages, -- 1378
				shared.llmOptions, -- 1379
				shared.llmMaxTry, -- 1380
				shared.decisionMode, -- 1381
				{ -- 1382
					onInput = function(____, phase, messages, options) -- 1383
						saveStepLLMDebugInput( -- 1384
							shared, -- 1384
							stepId, -- 1384
							phase, -- 1384
							messages, -- 1384
							options -- 1384
						) -- 1384
					end, -- 1383
					onOutput = function(____, phase, text, meta) -- 1386
						saveStepLLMDebugOutput( -- 1387
							shared, -- 1387
							stepId, -- 1387
							phase, -- 1387
							text, -- 1387
							meta -- 1387
						) -- 1387
					end -- 1386
				}, -- 1386
				"budget_max" -- 1390
			)) -- 1390
			if not (result and result.success and result.compressedCount > 0) then -- 1390
				emitAgentEvent( -- 1393
					shared, -- 1393
					{ -- 1393
						type = "memory_compression_finished", -- 1394
						sessionId = shared.sessionId, -- 1395
						taskId = shared.taskId, -- 1396
						step = stepId, -- 1397
						tool = "compress_memory", -- 1398
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1399
						result = { -- 1403
							success = false, -- 1404
							rounds = rounds, -- 1405
							error = result and result.error or "compression returned no changes", -- 1406
							compressedCount = result and result.compressedCount or 0, -- 1407
							fullCompaction = true -- 1408
						} -- 1408
					} -- 1408
				) -- 1408
				return ____awaiter_resolve( -- 1408
					nil, -- 1408
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1411
				) -- 1411
			end -- 1411
			local effectiveCompressedCount = math.max( -- 1416
				0, -- 1417
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1418
			) -- 1418
			if effectiveCompressedCount <= 0 then -- 1418
				return ____awaiter_resolve( -- 1418
					nil, -- 1418
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1421
				) -- 1421
			end -- 1421
			emitAgentEvent( -- 1428
				shared, -- 1428
				{ -- 1428
					type = "memory_compression_finished", -- 1429
					sessionId = shared.sessionId, -- 1430
					taskId = shared.taskId, -- 1431
					step = stepId, -- 1432
					tool = "compress_memory", -- 1433
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1434
					result = { -- 1435
						success = true, -- 1436
						round = rounds, -- 1437
						compressedCount = effectiveCompressedCount, -- 1438
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1439
						fullCompaction = true -- 1440
					} -- 1440
				} -- 1440
			) -- 1440
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex) -- 1443
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1444
			persistHistoryState(shared) -- 1445
			Log( -- 1446
				"Info", -- 1446
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1446
			) -- 1446
		end -- 1446
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1448
		return ____awaiter_resolve( -- 1448
			nil, -- 1448
			emitAgentTaskFinishEvent( -- 1449
				shared, -- 1450
				true, -- 1451
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1452
			) -- 1452
		) -- 1452
	end) -- 1452
end -- 1349
local function clearSessionHistory(shared) -- 1458
	shared.messages = {} -- 1459
	shared.lastConsolidatedIndex = 0 -- 1460
	shared.carryMessageIndex = nil -- 1461
	persistHistoryState(shared) -- 1462
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1463
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1464
end -- 1458
local function isKnownToolName(name) -- 1473
	return name == "read_file" or name == "edit_file" or name == "delete_file" or name == "grep_files" or name == "search_dora_api" or name == "glob_files" or name == "build" or name == "list_sub_agents" or name == "spawn_sub_agent" or name == "finish" -- 1474
end -- 1473
local function appendConversationMessage(shared, message) -- 1567
	local ____shared_messages_29 = shared.messages -- 1567
	____shared_messages_29[#____shared_messages_29 + 1] = __TS__ObjectAssign( -- 1568
		{}, -- 1568
		message, -- 1569
		{ -- 1568
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1570
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1571
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1572
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1573
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1574
		} -- 1574
	) -- 1574
end -- 1567
local function ensureToolCallId(toolCallId) -- 1578
	if toolCallId and toolCallId ~= "" then -- 1578
		return toolCallId -- 1579
	end -- 1579
	return createLocalToolCallId() -- 1580
end -- 1578
local function appendToolResultMessage(shared, action) -- 1583
	appendConversationMessage( -- 1584
		shared, -- 1584
		{ -- 1584
			role = "tool", -- 1585
			tool_call_id = action.toolCallId, -- 1586
			name = action.tool, -- 1587
			content = action.result and toJson(action.result) or "" -- 1588
		} -- 1588
	) -- 1588
end -- 1583
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1592
	appendConversationMessage( -- 1598
		shared, -- 1598
		{ -- 1598
			role = "assistant", -- 1599
			content = content or "", -- 1600
			reasoning_content = reasoningContent, -- 1601
			tool_calls = __TS__ArrayMap( -- 1602
				actions, -- 1602
				function(____, action) return { -- 1602
					id = action.toolCallId, -- 1603
					type = "function", -- 1604
					["function"] = { -- 1605
						name = action.tool, -- 1606
						arguments = toJson(action.params) -- 1607
					} -- 1607
				} end -- 1607
			) -- 1607
		} -- 1607
	) -- 1607
end -- 1592
local function parseXMLToolCallObjectFromText(text) -- 1613
	local children = parseXMLObjectFromText(text, "tool_call") -- 1614
	if not children.success then -- 1614
		return children -- 1615
	end -- 1615
	local rawObj = children.obj -- 1616
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1617
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1618
	if not params.success then -- 1618
		return {success = false, message = params.message} -- 1622
	end -- 1622
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1624
end -- 1613
local function llm(shared, messages, phase) -- 1644
	if phase == nil then -- 1644
		phase = "decision_xml" -- 1647
	end -- 1647
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1647
		local stepId = shared.step + 1 -- 1649
		saveStepLLMDebugInput( -- 1650
			shared, -- 1650
			stepId, -- 1650
			phase, -- 1650
			messages, -- 1650
			shared.llmOptions -- 1650
		) -- 1650
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken, shared.llmConfig)) -- 1651
		if res.success then -- 1651
			local ____opt_32 = res.response.choices -- 1651
			local ____opt_30 = ____opt_32 and ____opt_32[1] -- 1651
			local message = ____opt_30 and ____opt_30.message -- 1653
			local text = message and message.content -- 1654
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1655
			if text then -- 1655
				saveStepLLMDebugOutput( -- 1659
					shared, -- 1659
					stepId, -- 1659
					phase, -- 1659
					text, -- 1659
					{success = true} -- 1659
				) -- 1659
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1659
			else -- 1659
				saveStepLLMDebugOutput( -- 1662
					shared, -- 1662
					stepId, -- 1662
					phase, -- 1662
					"empty LLM response", -- 1662
					{success = false} -- 1662
				) -- 1662
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1662
			end -- 1662
		else -- 1662
			saveStepLLMDebugOutput( -- 1666
				shared, -- 1666
				stepId, -- 1666
				phase, -- 1666
				res.raw or res.message, -- 1666
				{success = false} -- 1666
			) -- 1666
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1666
		end -- 1666
	end) -- 1666
end -- 1644
local function isDecisionBatchSuccess(result) -- 1690
	return result.kind == "batch" -- 1691
end -- 1690
local function parseDecisionObject(rawObj) -- 1694
	if type(rawObj.tool) ~= "string" then -- 1694
		return {success = false, message = "missing tool"} -- 1695
	end -- 1695
	local tool = rawObj.tool -- 1696
	if not isKnownToolName(tool) then -- 1696
		return {success = false, message = "unknown tool: " .. tool} -- 1698
	end -- 1698
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 1700
	if tool ~= "finish" and (not reason or reason == "") then -- 1700
		return {success = false, message = tool .. " requires top-level reason"} -- 1704
	end -- 1704
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 1706
	return {success = true, tool = tool, params = params, reason = reason} -- 1707
end -- 1694
local function parseDecisionToolCall(functionName, rawObj) -- 1715
	if not isKnownToolName(functionName) then -- 1715
		return {success = false, message = "unknown tool: " .. functionName} -- 1717
	end -- 1717
	if rawObj == nil or rawObj == nil then -- 1717
		return {success = true, tool = functionName, params = {}} -- 1720
	end -- 1720
	if not isRecord(rawObj) then -- 1720
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 1723
	end -- 1723
	return {success = true, tool = functionName, params = rawObj} -- 1725
end -- 1715
local function parseToolCallArguments(functionName, argsText) -- 1732
	local trimmedArgs = __TS__StringTrim(argsText) -- 1733
	if trimmedArgs == "" then -- 1733
		return {} -- 1735
	end -- 1735
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 1737
	if err ~= nil or rawObj == nil then -- 1737
		return { -- 1739
			success = false, -- 1740
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 1741
			raw = argsText -- 1742
		} -- 1742
	end -- 1742
	local encodedRaw = safeJsonEncode(rawObj) -- 1745
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 1745
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 1747
	end -- 1747
	return rawObj -- 1753
end -- 1732
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 1756
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1764
	if isRecord(rawArgs) and rawArgs.success == false then -- 1764
		return rawArgs -- 1766
	end -- 1766
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1768
	if not decision.success then -- 1768
		return {success = false, message = decision.message, raw = argsText} -- 1770
	end -- 1770
	local validation = validateDecision(decision.tool, decision.params) -- 1776
	if not validation.success then -- 1776
		return {success = false, message = validation.message, raw = argsText} -- 1778
	end -- 1778
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1778
		return {success = false, message = (decision.tool .. " is not allowed for role ") .. shared.role, raw = argsText} -- 1785
	end -- 1785
	decision.params = validation.params -- 1791
	decision.toolCallId = ensureToolCallId(toolCallId) -- 1792
	decision.reason = reason -- 1793
	decision.reasoningContent = reasoningContent -- 1794
	return decision -- 1795
end -- 1756
local function createPreExecutableActionFromStream(shared, toolCall) -- 1798
	local ____opt_38 = toolCall["function"] -- 1798
	local functionName = ____opt_38 and ____opt_38.name -- 1799
	local ____opt_40 = toolCall["function"] -- 1799
	local argsText = ____opt_40 and ____opt_40.arguments or "" -- 1800
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 1801
	if not functionName or not toolCallId then -- 1801
		return nil -- 1802
	end -- 1802
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 1803
	if isRecord(rawArgs) and rawArgs.success == false then -- 1803
		return nil -- 1804
	end -- 1804
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 1805
	if not decision.success or not canPreExecuteTool(decision.tool) then -- 1805
		return nil -- 1806
	end -- 1806
	local validation = validateDecision(decision.tool, decision.params) -- 1807
	if not validation.success then -- 1807
		return nil -- 1808
	end -- 1808
	if not isToolAllowedForRole(shared.role, decision.tool) then -- 1808
		return nil -- 1809
	end -- 1809
	return { -- 1810
		step = shared.step + 1, -- 1811
		toolCallId = toolCallId, -- 1812
		tool = decision.tool, -- 1813
		reason = "", -- 1814
		params = validation.params, -- 1815
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1816
	} -- 1816
end -- 1798
local function createFunctionToolSchema(name, description, properties, required) -- 1956
	if required == nil then -- 1956
		required = {} -- 1960
	end -- 1960
	local parameters = {type = "object", properties = properties} -- 1962
	if #required > 0 then -- 1962
		parameters.required = required -- 1967
	end -- 1967
	return {type = "function", ["function"] = {name = name, description = description, parameters = parameters}} -- 1969
end -- 1956
local function buildDecisionToolSchema(shared) -- 1985
	local allowed = getAllowedToolsForRole(shared.role) -- 1986
	local tools = { -- 1987
		createFunctionToolSchema("read_file", "Read a specific line range from a file. Positive line numbers are 1-based. Negative line numbers count from the end, where -1 is the last line. startLine defaults to 1. If endLine is omitted, it defaults to 300 when startLine is positive, or -1 when startLine is negative.", {path = {type = "string", description = "Workspace-relative file path to read."}, startLine = {type = "number", description = "Starting line number. Positive values are 1-based; negative values count from the end. Defaults to 1. 0 is invalid."}, endLine = {type = "number", description = "Ending line number. Positive values are 1-based; negative values count from the end. If omitted, defaults to 300 for positive startLine, or -1 for negative startLine. 0 is invalid."}}, {"path"}), -- 1988
		createFunctionToolSchema("edit_file", "Make changes to a file. Parameters: path, old_str, new_str. old_str and new_str must be different. old_str must match existing text exactly when it is non-empty. If old_str is empty, create the file when it does not exist, or clear and rewrite the whole file with new_str when it already exists.", {path = {type = "string", description = "Workspace-relative file path to edit."}, old_str = {type = "string", description = "Existing text to replace. If empty, edit_file rewrites the whole file, or creates it when missing."}, new_str = {type = "string", description = "Replacement text or the full file content when rewriting or creating."}}, {"path", "old_str", "new_str"}), -- 1998
		createFunctionToolSchema("delete_file", "Remove a file. Parameters: target_file.", {target_file = {type = "string", description = "Workspace-relative file path to delete."}}, {"target_file"}), -- 2008
		createFunctionToolSchema("grep_files", "Search text patterns inside files. Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional), limit(optional), offset(optional), groupByFile(optional). path may point to either a directory or a single file. This is content search, not filename search. globs only restrict which files are searched. Search results are intentionally capped, so refine the pattern or read a specific file next.", { -- 2016
			path = {type = "string", description = "Base directory or file path to search within."}, -- 2020
			pattern = {type = "string", description = "Content pattern to search for. Use | to express OR alternatives."}, -- 2021
			globs = {type = "array", items = {type = "string"}, description = "Optional file glob filters."}, -- 2022
			useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."}, -- 2023
			caseSensitive = {type = "boolean", description = "Set true for case-sensitive matching."}, -- 2024
			limit = {type = "number", description = "Maximum number of results to return."}, -- 2025
			offset = {type = "number", description = "Offset for paginating later result pages."}, -- 2026
			groupByFile = {type = "boolean", description = "Set true to rank candidate files before drilling into one file."} -- 2027
		}, {"pattern"}), -- 2027
		createFunctionToolSchema("glob_files", "Enumerate files under a directory. Parameters: path, globs(optional), maxEntries(optional). Use this to discover files by path, extension, or glob pattern. Directory listings are intentionally capped, so narrow the path before expanding further.", {path = {type = "string", description = "Base directory to enumerate. Defaults to the workspace root when omitted."}, globs = {type = "array", items = {type = "string"}, description = "Optional glob filters for returned paths."}, maxEntries = {type = "number", description = "Maximum number of entries to return."}}), -- 2031
		createFunctionToolSchema( -- 2040
			"search_dora_api", -- 2041
			("Search Dora SSR game engine docs and tutorials. Parameters: pattern, docSource(api/tutorial, optional), programmingLanguage(ts/tsx/lua/yue/teal/tl/wa), limit(optional). docSource defaults to api. Use | to express OR alternatives. limit must be <= " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. ".", -- 2041
			{ -- 2043
				pattern = {type = "string", description = "Query string to search for. Use | to express OR alternatives."}, -- 2044
				docSource = {type = "string", enum = {"api", "tutorial"}, description = "Search API docs or tutorials."}, -- 2045
				programmingLanguage = {type = "string", enum = { -- 2046
					"ts", -- 2048
					"tsx", -- 2048
					"lua", -- 2048
					"yue", -- 2048
					"teal", -- 2048
					"tl", -- 2048
					"wa" -- 2048
				}, description = "Preferred language variant to search."}, -- 2048
				limit = { -- 2051
					type = "number", -- 2051
					description = ("Maximum number of matches to return, up to " .. tostring(SEARCH_DORA_API_LIMIT_MAX)) .. "." -- 2051
				}, -- 2051
				useRegex = {type = "boolean", description = "Set true when pattern is a regular expression."} -- 2052
			}, -- 2052
			{"pattern"} -- 2054
		), -- 2054
		createFunctionToolSchema("build", "Do compiling and static checks for ts/tsx, teal, lua, yue, yarn. Parameters: path(optional). Read the result and then decide whether another action is needed.", {path = {type = "string", description = "Optional workspace-relative file or directory to build."}}), -- 2056
		createFunctionToolSchema("list_sub_agents", "Query current sub-agent state under the current main session, including running items and a small recent window of completed results. Use this only when you do not already know the current sub-agent state and need to decide whether to dispatch more sub agents or read a result file.", {status = {type = "string", enum = { -- 2063
			"active_or_recent", -- 2067
			"running", -- 2067
			"done", -- 2067
			"failed", -- 2067
			"all" -- 2067
		}, description = "Optional status filter. Defaults to active_or_recent."}, limit = {type = "number", description = "Maximum number of items to return. Defaults to 5."}, offset = {type = "number", description = "Offset for paging older items."}, query = {type = "string", description = "Optional text filter matched against title, goal, or summary."}}), -- 2067
		createFunctionToolSchema("spawn_sub_agent", "Create and start a sub agent session to execute delegated work. Use this for large multi-file work, parallel exploration, long-running verification, or isolated execution tasks; for small focused edits, use edit_file/delete_file/build directly. If dispatch succeeds, you may immediately finish the current turn without waiting for completion; the sub agent result arrives asynchronously and should be handled in a later conversation turn.", {title = {type = "string", description = "Short tab title for the sub agent."}, prompt = {type = "string", description = "Detailed, self-contained task prompt sent to the sub agent. Describe the concrete work to execute, constraints, expected output, and relevant files when known."}, expectedOutput = {type = "string", description = "Optional expected result summary."}, filesHint = {type = "array", items = {type = "string"}, description = "Optional likely files or directories involved."}}, {"title", "prompt"}) -- 2073
	} -- 2073
	return __TS__ArrayFilter( -- 2085
		tools, -- 2085
		function(____, tool) return __TS__ArrayIndexOf(allowed, tool["function"].name) >= 0 end -- 2085
	) -- 2085
end -- 1985
local function sanitizeMessagesForLLMInput(messages) -- 2126
	local sanitized = {} -- 2127
	local droppedAssistantToolCalls = 0 -- 2128
	local droppedToolResults = 0 -- 2129
	do -- 2129
		local i = 0 -- 2130
		while i < #messages do -- 2130
			do -- 2130
				local message = messages[i + 1] -- 2131
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2131
					local requiredIds = {} -- 2133
					do -- 2133
						local j = 0 -- 2134
						while j < #message.tool_calls do -- 2134
							local toolCall = message.tool_calls[j + 1] -- 2135
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2136
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2136
								requiredIds[#requiredIds + 1] = id -- 2138
							end -- 2138
							j = j + 1 -- 2134
						end -- 2134
					end -- 2134
					if #requiredIds == 0 then -- 2134
						sanitized[#sanitized + 1] = message -- 2142
						goto __continue335 -- 2143
					end -- 2143
					local matchedIds = {} -- 2145
					local matchedTools = {} -- 2146
					local j = i + 1 -- 2147
					while j < #messages do -- 2147
						local toolMessage = messages[j + 1] -- 2149
						if toolMessage.role ~= "tool" then -- 2149
							break -- 2150
						end -- 2150
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2151
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2151
							matchedIds[toolCallId] = true -- 2153
							matchedTools[#matchedTools + 1] = toolMessage -- 2154
						else -- 2154
							droppedToolResults = droppedToolResults + 1 -- 2156
						end -- 2156
						j = j + 1 -- 2158
					end -- 2158
					local complete = true -- 2160
					do -- 2160
						local j = 0 -- 2161
						while j < #requiredIds do -- 2161
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2161
								complete = false -- 2163
								break -- 2164
							end -- 2164
							j = j + 1 -- 2161
						end -- 2161
					end -- 2161
					if complete then -- 2161
						__TS__ArrayPush( -- 2168
							sanitized, -- 2168
							message, -- 2168
							table.unpack(matchedTools) -- 2168
						) -- 2168
					else -- 2168
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2170
						droppedToolResults = droppedToolResults + #matchedTools -- 2171
					end -- 2171
					i = j - 1 -- 2173
					goto __continue335 -- 2174
				end -- 2174
				if message.role == "tool" then -- 2174
					droppedToolResults = droppedToolResults + 1 -- 2177
					goto __continue335 -- 2178
				end -- 2178
				sanitized[#sanitized + 1] = message -- 2180
			end -- 2180
			::__continue335:: -- 2180
			i = i + 1 -- 2130
		end -- 2130
	end -- 2130
	return sanitized -- 2182
end -- 2126
local function getUnconsolidatedMessages(shared) -- 2185
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2186
end -- 2185
local function getFinalDecisionTurnPrompt(shared) -- 2189
	return shared.useChineseResponse and "当前已达到最大的处理轮次，请在本次处理中直接进行工作总结，不要再继续规划后续轮次。" or "You have reached the maximum processing round. In this turn, provide a direct work summary instead of planning further rounds." -- 2190
end -- 2189
local function appendPromptToLatestDecisionMessage(messages, prompt) -- 2195
	if #messages == 0 or __TS__StringTrim(prompt) == "" then -- 2195
		return messages -- 2196
	end -- 2196
	local next = __TS__ArrayMap( -- 2197
		messages, -- 2197
		function(____, message) return __TS__ObjectAssign({}, message) end -- 2197
	) -- 2197
	do -- 2197
		local i = #next - 1 -- 2198
		while i >= 0 do -- 2198
			do -- 2198
				local message = next[i + 1] -- 2199
				if message.role ~= "assistant" and message.role ~= "user" then -- 2199
					goto __continue357 -- 2200
				end -- 2200
				local content = type(message.content) == "string" and __TS__StringTrim(message.content) or "" -- 2201
				message.content = content ~= "" and (content .. "\n\n") .. prompt or prompt -- 2202
				return next -- 2205
			end -- 2205
			::__continue357:: -- 2205
			i = i - 1 -- 2198
		end -- 2198
	end -- 2198
	next[#next + 1] = {role = "user", content = prompt} -- 2207
	return next -- 2208
end -- 2195
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2211
	if attempt == nil then -- 2211
		attempt = 1 -- 2214
	end -- 2214
	if decisionMode == nil then -- 2214
		decisionMode = shared.decisionMode -- 2216
	end -- 2216
	local messages = { -- 2218
		{ -- 2219
			role = "system", -- 2219
			content = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2219
		}, -- 2219
		table.unpack(getUnconsolidatedMessages(shared)) -- 2220
	} -- 2220
	if shared.step + 1 >= shared.maxSteps then -- 2220
		messages = appendPromptToLatestDecisionMessage( -- 2223
			messages, -- 2223
			getFinalDecisionTurnPrompt(shared) -- 2223
		) -- 2223
	end -- 2223
	if lastError and lastError ~= "" then -- 2223
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2226
		messages[#messages + 1] = { -- 2229
			role = "user", -- 2230
			content = (((retryHeader .. "\n\nRetry attempt: ") .. tostring(attempt)) .. ".\nThe next reply must differ from the previously rejected output.\n") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2231
		} -- 2231
	end -- 2231
	return messages -- 2238
end -- 2211
local function buildXmlRepairMessages(shared, originalRaw, candidateRaw, lastError, attempt) -- 2245
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2252
	local candidateSection = hasCandidate and ("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n" or "" -- 2253
	local repairPrompt = replacePromptVars( -- 2261
		shared.promptPack.xmlDecisionRepairPrompt, -- 2261
		{ -- 2261
			TOOL_DEFINITIONS = getDecisionToolDefinitions(shared), -- 2262
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2263
			CANDIDATE_SECTION = candidateSection, -- 2264
			LAST_ERROR = lastError, -- 2265
			ATTEMPT = tostring(attempt) -- 2266
		} -- 2266
	) -- 2266
	return {{role = "system", content = shared.promptPack.xmlDecisionSystemRepairPrompt}, {role = "user", content = repairPrompt}} -- 2268
end -- 2245
local function tryParseAndValidateDecision(rawText) -- 2280
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2281
	if not parsed.success then -- 2281
		return {success = false, message = parsed.message, raw = rawText} -- 2283
	end -- 2283
	local decision = parseDecisionObject(parsed.obj) -- 2285
	if not decision.success then -- 2285
		return {success = false, message = decision.message, raw = rawText} -- 2287
	end -- 2287
	local validation = validateDecision(decision.tool, decision.params) -- 2289
	if not validation.success then -- 2289
		return {success = false, message = validation.message, raw = rawText} -- 2291
	end -- 2291
	decision.params = validation.params -- 2293
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2294
	return decision -- 2295
end -- 2280
local function normalizeLineEndings(text) -- 2298
	local res = string.gsub(text, "\r\n", "\n") -- 2299
	res = string.gsub(res, "\r", "\n") -- 2300
	return res -- 2301
end -- 2298
local function countOccurrences(text, searchStr) -- 2304
	if searchStr == "" then -- 2304
		return 0 -- 2305
	end -- 2305
	local count = 0 -- 2306
	local pos = 0 -- 2307
	while true do -- 2307
		local idx = (string.find( -- 2309
			text, -- 2309
			searchStr, -- 2309
			math.max(pos + 1, 1), -- 2309
			true -- 2309
		) or 0) - 1 -- 2309
		if idx < 0 then -- 2309
			break -- 2310
		end -- 2310
		count = count + 1 -- 2311
		pos = idx + #searchStr -- 2312
	end -- 2312
	return count -- 2314
end -- 2304
local function replaceFirst(text, oldStr, newStr) -- 2317
	if oldStr == "" then -- 2317
		return text -- 2318
	end -- 2318
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2319
	if idx < 0 then -- 2319
		return text -- 2320
	end -- 2320
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2321
end -- 2317
local function splitLines(text) -- 2324
	return __TS__StringSplit(text, "\n") -- 2325
end -- 2324
local function getLeadingWhitespace(text) -- 2328
	local i = 0 -- 2329
	while i < #text do -- 2329
		local ch = __TS__StringAccess(text, i) -- 2331
		if ch ~= " " and ch ~= "\t" then -- 2331
			break -- 2332
		end -- 2332
		i = i + 1 -- 2333
	end -- 2333
	return __TS__StringSubstring(text, 0, i) -- 2335
end -- 2328
local function getCommonIndentPrefix(lines) -- 2338
	local common -- 2339
	do -- 2339
		local i = 0 -- 2340
		while i < #lines do -- 2340
			do -- 2340
				local line = lines[i + 1] -- 2341
				if __TS__StringTrim(line) == "" then -- 2341
					goto __continue382 -- 2342
				end -- 2342
				local indent = getLeadingWhitespace(line) -- 2343
				if common == nil then -- 2343
					common = indent -- 2345
					goto __continue382 -- 2346
				end -- 2346
				local j = 0 -- 2348
				local maxLen = math.min(#common, #indent) -- 2349
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2349
					j = j + 1 -- 2351
				end -- 2351
				common = __TS__StringSubstring(common, 0, j) -- 2353
				if common == "" then -- 2353
					break -- 2354
				end -- 2354
			end -- 2354
			::__continue382:: -- 2354
			i = i + 1 -- 2340
		end -- 2340
	end -- 2340
	return common or "" -- 2356
end -- 2338
local function removeIndentPrefix(line, indent) -- 2359
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2359
		return __TS__StringSubstring(line, #indent) -- 2361
	end -- 2361
	local lineIndent = getLeadingWhitespace(line) -- 2363
	local j = 0 -- 2364
	local maxLen = math.min(#lineIndent, #indent) -- 2365
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2365
		j = j + 1 -- 2367
	end -- 2367
	return __TS__StringSubstring(line, j) -- 2369
end -- 2359
local function dedentLines(lines) -- 2372
	local indent = getCommonIndentPrefix(lines) -- 2373
	return { -- 2374
		indent = indent, -- 2375
		lines = __TS__ArrayMap( -- 2376
			lines, -- 2376
			function(____, line) return removeIndentPrefix(line, indent) end -- 2376
		) -- 2376
	} -- 2376
end -- 2372
local function joinLines(lines) -- 2380
	return table.concat(lines, "\n") -- 2381
end -- 2380
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2384
	local contentLines = splitLines(content) -- 2389
	local oldLines = splitLines(oldStr) -- 2390
	if #oldLines == 0 then -- 2390
		return {success = false, message = "old_str not found in file"} -- 2392
	end -- 2392
	local dedentedOld = dedentLines(oldLines) -- 2394
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2395
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2396
	local matches = {} -- 2397
	do -- 2397
		local start = 0 -- 2398
		while start <= #contentLines - #oldLines do -- 2398
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2399
			local dedentedCandidate = dedentLines(candidateLines) -- 2400
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2400
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2402
			end -- 2402
			start = start + 1 -- 2398
		end -- 2398
	end -- 2398
	if #matches == 0 then -- 2398
		return {success = false, message = "old_str not found in file"} -- 2410
	end -- 2410
	if #matches > 1 then -- 2410
		return { -- 2413
			success = false, -- 2414
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2415
		} -- 2415
	end -- 2415
	local match = matches[1] -- 2418
	local rebuiltNewLines = __TS__ArrayMap( -- 2419
		dedentedNew.lines, -- 2419
		function(____, line) return line == "" and "" or match.indent .. line end -- 2419
	) -- 2419
	local ____array_46 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2419
	__TS__SparseArrayPush( -- 2419
		____array_46, -- 2419
		table.unpack(rebuiltNewLines) -- 2422
	) -- 2422
	__TS__SparseArrayPush( -- 2422
		____array_46, -- 2422
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2423
	) -- 2423
	local nextLines = {__TS__SparseArraySpread(____array_46)} -- 2420
	return { -- 2425
		success = true, -- 2425
		content = joinLines(nextLines) -- 2425
	} -- 2425
end -- 2384
local MainDecisionAgent = __TS__Class() -- 2428
MainDecisionAgent.name = "MainDecisionAgent" -- 2428
__TS__ClassExtends(MainDecisionAgent, Node) -- 2428
function MainDecisionAgent.prototype.prep(self, shared) -- 2429
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2429
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2429
			return ____awaiter_resolve(nil, {shared = shared}) -- 2429
		end -- 2429
		__TS__Await(maybeCompressHistory(shared)) -- 2434
		return ____awaiter_resolve(nil, {shared = shared}) -- 2434
	end) -- 2434
end -- 2429
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2439
	if attempt == nil then -- 2439
		attempt = 1 -- 2442
	end -- 2442
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2442
		if shared.stopToken.stopped then -- 2442
			return ____awaiter_resolve( -- 2442
				nil, -- 2442
				{ -- 2446
					success = false, -- 2446
					message = getCancelledReason(shared) -- 2446
				} -- 2446
			) -- 2446
		end -- 2446
		Log( -- 2448
			"Info", -- 2448
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2448
		) -- 2448
		local tools = buildDecisionToolSchema(shared) -- 2449
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2450
		local stepId = shared.step + 1 -- 2451
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, {tools = tools}) -- 2452
		saveStepLLMDebugInput( -- 2456
			shared, -- 2456
			stepId, -- 2456
			"decision_tool_calling", -- 2456
			messages, -- 2456
			llmOptions -- 2456
		) -- 2456
		local lastStreamContent = "" -- 2457
		local lastStreamReasoning = "" -- 2458
		local preExecutedResults = __TS__New(Map) -- 2459
		shared.preExecutedResults = preExecutedResults -- 2460
		local res = __TS__Await(callLLMStreamAggregated( -- 2461
			messages, -- 2462
			llmOptions, -- 2463
			shared.stopToken, -- 2464
			shared.llmConfig, -- 2465
			function(response) -- 2466
				local ____opt_49 = response.choices -- 2466
				local ____opt_47 = ____opt_49 and ____opt_49[1] -- 2466
				local streamMessage = ____opt_47 and ____opt_47.message -- 2467
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2468
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2471
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2471
					return -- 2475
				end -- 2475
				lastStreamContent = nextContent -- 2477
				lastStreamReasoning = nextReasoning -- 2478
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2479
			end, -- 2466
			function(tc) -- 2481
				if shared.stopToken.stopped then -- 2481
					return -- 2482
				end -- 2482
				local action = createPreExecutableActionFromStream(shared, tc) -- 2483
				if not action or preExecutedResults:has(action.toolCallId) then -- 2483
					return -- 2484
				end -- 2484
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2485
				preExecutedResults:set( -- 2486
					action.toolCallId, -- 2486
					startPreExecutedToolAction(shared, action) -- 2486
				) -- 2486
			end -- 2481
		)) -- 2481
		if shared.stopToken.stopped then -- 2481
			clearPreExecutedResults(shared) -- 2490
			return ____awaiter_resolve( -- 2490
				nil, -- 2490
				{ -- 2491
					success = false, -- 2491
					message = getCancelledReason(shared) -- 2491
				} -- 2491
			) -- 2491
		end -- 2491
		if not res.success then -- 2491
			saveStepLLMDebugOutput( -- 2494
				shared, -- 2494
				stepId, -- 2494
				"decision_tool_calling", -- 2494
				res.raw or res.message, -- 2494
				{success = false} -- 2494
			) -- 2494
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2495
			clearPreExecutedResults(shared) -- 2496
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2496
		end -- 2496
		saveStepLLMDebugOutput( -- 2499
			shared, -- 2499
			stepId, -- 2499
			"decision_tool_calling", -- 2499
			encodeDebugJSON(res.response), -- 2499
			{success = true} -- 2499
		) -- 2499
		local choice = res.response.choices and res.response.choices[1] -- 2500
		local message = choice and choice.message -- 2501
		local toolCalls = message and message.tool_calls -- 2502
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2503
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2506
		Log( -- 2509
			"Info", -- 2509
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2509
		) -- 2509
		if not toolCalls or #toolCalls == 0 then -- 2509
			if messageContent and messageContent ~= "" then -- 2509
				Log( -- 2512
					"Info", -- 2512
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 2512
				) -- 2512
				clearPreExecutedResults(shared) -- 2513
				return ____awaiter_resolve(nil, { -- 2513
					success = true, -- 2515
					tool = "finish", -- 2516
					params = {}, -- 2517
					reason = messageContent, -- 2518
					reasoningContent = reasoningContent, -- 2519
					directSummary = messageContent -- 2520
				}) -- 2520
			end -- 2520
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 2523
			clearPreExecutedResults(shared) -- 2524
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 2524
		end -- 2524
		local decisions = {} -- 2531
		do -- 2531
			local i = 0 -- 2532
			while i < #toolCalls do -- 2532
				local toolCall = toolCalls[i + 1] -- 2533
				local fn = toolCall and toolCall["function"] -- 2534
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 2534
					Log( -- 2536
						"Error", -- 2536
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 2536
					) -- 2536
					clearPreExecutedResults(shared) -- 2537
					return ____awaiter_resolve( -- 2537
						nil, -- 2537
						{ -- 2538
							success = false, -- 2539
							message = "missing function name for tool call " .. tostring(i + 1), -- 2540
							raw = messageContent -- 2541
						} -- 2541
					) -- 2541
				end -- 2541
				local functionName = fn.name -- 2544
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 2545
				local toolCallId = toolCall and type(toolCall.id) == "string" and toolCall.id or nil -- 2546
				Log( -- 2549
					"Info", -- 2549
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 2549
				) -- 2549
				local decision = parseAndValidateToolCallDecision( -- 2550
					shared, -- 2551
					functionName, -- 2552
					argsText, -- 2553
					toolCallId, -- 2554
					messageContent, -- 2555
					reasoningContent -- 2556
				) -- 2556
				if not decision.success then -- 2556
					Log( -- 2559
						"Error", -- 2559
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 2559
					) -- 2559
					clearPreExecutedResults(shared) -- 2560
					return ____awaiter_resolve(nil, decision) -- 2560
				end -- 2560
				decisions[#decisions + 1] = decision -- 2563
				i = i + 1 -- 2532
			end -- 2532
		end -- 2532
		if #decisions == 1 then -- 2532
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 2566
			return ____awaiter_resolve(nil, decisions[1]) -- 2566
		end -- 2566
		do -- 2566
			local i = 0 -- 2569
			while i < #decisions do -- 2569
				if decisions[i + 1].tool == "finish" then -- 2569
					clearPreExecutedResults(shared) -- 2571
					return ____awaiter_resolve(nil, {success = false, message = "finish cannot be mixed with other tool calls", raw = messageContent}) -- 2571
				end -- 2571
				i = i + 1 -- 2569
			end -- 2569
		end -- 2569
		Log( -- 2579
			"Info", -- 2579
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 2579
				__TS__ArrayMap( -- 2579
					decisions, -- 2579
					function(____, decision) return decision.tool end -- 2579
				), -- 2579
				"," -- 2579
			) -- 2579
		) -- 2579
		return ____awaiter_resolve(nil, { -- 2579
			success = true, -- 2581
			kind = "batch", -- 2582
			decisions = decisions, -- 2583
			content = messageContent, -- 2584
			reasoningContent = reasoningContent -- 2585
		}) -- 2585
	end) -- 2585
end -- 2439
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, initialError) -- 2589
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2589
		Log( -- 2594
			"Info", -- 2594
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 2594
		) -- 2594
		local lastError = initialError -- 2595
		local candidateRaw = "" -- 2596
		do -- 2596
			local attempt = 0 -- 2597
			while attempt < shared.llmMaxTry do -- 2597
				do -- 2597
					Log( -- 2598
						"Info", -- 2598
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 2598
					) -- 2598
					local messages = buildXmlRepairMessages( -- 2599
						shared, -- 2600
						originalRaw, -- 2601
						candidateRaw, -- 2602
						lastError, -- 2603
						attempt + 1 -- 2604
					) -- 2604
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 2606
					if shared.stopToken.stopped then -- 2606
						return ____awaiter_resolve( -- 2606
							nil, -- 2606
							{ -- 2608
								success = false, -- 2608
								message = getCancelledReason(shared) -- 2608
							} -- 2608
						) -- 2608
					end -- 2608
					if not llmRes.success then -- 2608
						lastError = llmRes.message -- 2611
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 2612
						goto __continue425 -- 2613
					end -- 2613
					candidateRaw = llmRes.text -- 2615
					local decision = tryParseAndValidateDecision(candidateRaw) -- 2616
					if decision.success then -- 2616
						decision.reasoningContent = llmRes.reasoningContent -- 2618
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 2619
						return ____awaiter_resolve(nil, decision) -- 2619
					end -- 2619
					lastError = decision.message -- 2622
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 2623
				end -- 2623
				::__continue425:: -- 2623
				attempt = attempt + 1 -- 2597
			end -- 2597
		end -- 2597
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 2625
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 2625
	end) -- 2625
end -- 2589
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 2633
	if attempt == nil then -- 2633
		attempt = 1 -- 2636
	end -- 2636
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2636
		local messages = buildDecisionMessages( -- 2639
			shared, -- 2640
			lastError, -- 2641
			attempt, -- 2642
			lastRaw, -- 2643
			"xml" -- 2644
		) -- 2644
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 2646
		if shared.stopToken.stopped then -- 2646
			return ____awaiter_resolve( -- 2646
				nil, -- 2646
				{ -- 2648
					success = false, -- 2648
					message = getCancelledReason(shared) -- 2648
				} -- 2648
			) -- 2648
		end -- 2648
		if not llmRes.success then -- 2648
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 2648
		end -- 2648
		local decision = tryParseAndValidateDecision(llmRes.text) -- 2657
		if decision.success then -- 2657
			decision.reasoningContent = llmRes.reasoningContent -- 2659
			if not isToolAllowedForRole(shared.role, decision.tool) then -- 2659
				return ____awaiter_resolve( -- 2659
					nil, -- 2659
					self:repairDecisionXml(shared, llmRes.text, (decision.tool .. " is not allowed for role ") .. shared.role) -- 2661
				) -- 2661
			end -- 2661
			return ____awaiter_resolve(nil, decision) -- 2661
		end -- 2661
		return ____awaiter_resolve( -- 2661
			nil, -- 2661
			self:repairDecisionXml(shared, llmRes.text, decision.message) -- 2669
		) -- 2669
	end) -- 2669
end -- 2633
function MainDecisionAgent.prototype.exec(self, input) -- 2672
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2672
		local shared = input.shared -- 2673
		if shared.stopToken.stopped then -- 2673
			return ____awaiter_resolve( -- 2673
				nil, -- 2673
				{ -- 2675
					success = false, -- 2675
					message = getCancelledReason(shared) -- 2675
				} -- 2675
			) -- 2675
		end -- 2675
		if shared.step >= shared.maxSteps then -- 2675
			Log( -- 2678
				"Warn", -- 2678
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 2678
			) -- 2678
			return ____awaiter_resolve( -- 2678
				nil, -- 2678
				{ -- 2679
					success = false, -- 2679
					message = getMaxStepsReachedReason(shared) -- 2679
				} -- 2679
			) -- 2679
		end -- 2679
		if shared.decisionMode == "tool_calling" then -- 2679
			Log( -- 2683
				"Info", -- 2683
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 2683
			) -- 2683
			local lastError = "tool calling validation failed" -- 2684
			local lastRaw = "" -- 2685
			local shouldFallbackToXml = false -- 2686
			do -- 2686
				local attempt = 0 -- 2687
				while attempt < shared.llmMaxTry do -- 2687
					Log( -- 2688
						"Info", -- 2688
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 2688
					) -- 2688
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 2689
					if shared.stopToken.stopped then -- 2689
						return ____awaiter_resolve( -- 2689
							nil, -- 2689
							{ -- 2696
								success = false, -- 2696
								message = getCancelledReason(shared) -- 2696
							} -- 2696
						) -- 2696
					end -- 2696
					if decision.success then -- 2696
						return ____awaiter_resolve(nil, decision) -- 2696
					end -- 2696
					lastError = decision.message -- 2701
					lastRaw = decision.raw or "" -- 2702
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 2703
					if lastError == "missing tool call" then -- 2703
						shouldFallbackToXml = true -- 2705
						break -- 2706
					end -- 2706
					attempt = attempt + 1 -- 2687
				end -- 2687
			end -- 2687
			if shouldFallbackToXml then -- 2687
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 2710
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 2711
				do -- 2711
					local attempt = 0 -- 2712
					while attempt < shared.llmMaxTry do -- 2712
						Log( -- 2713
							"Info", -- 2713
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 2713
						) -- 2713
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 2714
						if shared.stopToken.stopped then -- 2714
							return ____awaiter_resolve( -- 2714
								nil, -- 2714
								{ -- 2721
									success = false, -- 2721
									message = getCancelledReason(shared) -- 2721
								} -- 2721
							) -- 2721
						end -- 2721
						if decision.success then -- 2721
							return ____awaiter_resolve(nil, decision) -- 2721
						end -- 2721
						lastError = decision.message -- 2726
						lastRaw = decision.raw or "" -- 2727
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 2728
						attempt = attempt + 1 -- 2712
					end -- 2712
				end -- 2712
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 2730
				return ____awaiter_resolve( -- 2730
					nil, -- 2730
					{ -- 2731
						success = false, -- 2731
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2731
					} -- 2731
				) -- 2731
			end -- 2731
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 2733
			return ____awaiter_resolve( -- 2733
				nil, -- 2733
				{ -- 2734
					success = false, -- 2734
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2734
				} -- 2734
			) -- 2734
		end -- 2734
		local lastError = "xml validation failed" -- 2737
		local lastRaw = "" -- 2738
		do -- 2738
			local attempt = 0 -- 2739
			while attempt < shared.llmMaxTry do -- 2739
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 2740
				if shared.stopToken.stopped then -- 2740
					return ____awaiter_resolve( -- 2740
						nil, -- 2740
						{ -- 2749
							success = false, -- 2749
							message = getCancelledReason(shared) -- 2749
						} -- 2749
					) -- 2749
				end -- 2749
				if decision.success then -- 2749
					return ____awaiter_resolve(nil, decision) -- 2749
				end -- 2749
				lastError = decision.message -- 2754
				lastRaw = decision.raw or "" -- 2755
				attempt = attempt + 1 -- 2739
			end -- 2739
		end -- 2739
		return ____awaiter_resolve( -- 2739
			nil, -- 2739
			{ -- 2757
				success = false, -- 2757
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 2757
			} -- 2757
		) -- 2757
	end) -- 2757
end -- 2672
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 2760
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2760
		local result = execRes -- 2761
		if not result.success then -- 2761
			if shared.stopToken.stopped then -- 2761
				shared.error = getCancelledReason(shared) -- 2764
				shared.done = true -- 2765
				return ____awaiter_resolve(nil, "done") -- 2765
			end -- 2765
			shared.error = result.message -- 2768
			shared.response = getFailureSummaryFallback(shared, result.message) -- 2769
			shared.done = true -- 2770
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 2771
			persistHistoryState(shared) -- 2775
			return ____awaiter_resolve(nil, "done") -- 2775
		end -- 2775
		if isDecisionBatchSuccess(result) then -- 2775
			local startStep = shared.step -- 2779
			local actions = {} -- 2780
			do -- 2780
				local i = 0 -- 2781
				while i < #result.decisions do -- 2781
					local decision = result.decisions[i + 1] -- 2782
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 2783
					local step = startStep + i + 1 -- 2784
					local ____temp_55 -- 2785
					if i == 0 then -- 2785
						____temp_55 = decision.reason -- 2785
					else -- 2785
						____temp_55 = "" -- 2785
					end -- 2785
					local actionReason = ____temp_55 -- 2785
					local ____temp_56 -- 2786
					if i == 0 then -- 2786
						____temp_56 = decision.reasoningContent -- 2786
					else -- 2786
						____temp_56 = nil -- 2786
					end -- 2786
					local actionReasoningContent = ____temp_56 -- 2786
					emitAgentEvent(shared, { -- 2787
						type = "decision_made", -- 2788
						sessionId = shared.sessionId, -- 2789
						taskId = shared.taskId, -- 2790
						step = step, -- 2791
						tool = decision.tool, -- 2792
						reason = actionReason, -- 2793
						reasoningContent = actionReasoningContent, -- 2794
						params = decision.params -- 2795
					}) -- 2795
					local action = { -- 2797
						step = step, -- 2798
						toolCallId = toolCallId, -- 2799
						tool = decision.tool, -- 2800
						reason = actionReason or "", -- 2801
						reasoningContent = actionReasoningContent, -- 2802
						params = decision.params, -- 2803
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2804
					} -- 2804
					local ____shared_history_57 = shared.history -- 2804
					____shared_history_57[#____shared_history_57 + 1] = action -- 2806
					actions[#actions + 1] = action -- 2807
					i = i + 1 -- 2781
				end -- 2781
			end -- 2781
			shared.step = startStep + #actions -- 2809
			shared.pendingToolActions = actions -- 2810
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 2811
			persistHistoryState(shared) -- 2817
			return ____awaiter_resolve(nil, "batch_tools") -- 2817
		end -- 2817
		if result.directSummary and result.directSummary ~= "" then -- 2817
			shared.response = result.directSummary -- 2821
			shared.done = true -- 2822
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 2823
			persistHistoryState(shared) -- 2828
			return ____awaiter_resolve(nil, "done") -- 2828
		end -- 2828
		if result.tool == "finish" then -- 2828
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 2832
			shared.response = finalMessage -- 2833
			shared.done = true -- 2834
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 2835
			persistHistoryState(shared) -- 2840
			return ____awaiter_resolve(nil, "done") -- 2840
		end -- 2840
		local toolCallId = ensureToolCallId(result.toolCallId) -- 2843
		shared.step = shared.step + 1 -- 2844
		local step = shared.step -- 2845
		emitAgentEvent(shared, { -- 2846
			type = "decision_made", -- 2847
			sessionId = shared.sessionId, -- 2848
			taskId = shared.taskId, -- 2849
			step = step, -- 2850
			tool = result.tool, -- 2851
			reason = result.reason, -- 2852
			reasoningContent = result.reasoningContent, -- 2853
			params = result.params -- 2854
		}) -- 2854
		local ____shared_history_58 = shared.history -- 2854
		____shared_history_58[#____shared_history_58 + 1] = { -- 2856
			step = step, -- 2857
			toolCallId = toolCallId, -- 2858
			tool = result.tool, -- 2859
			reason = result.reason or "", -- 2860
			reasoningContent = result.reasoningContent, -- 2861
			params = result.params, -- 2862
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2863
		} -- 2863
		local action = shared.history[#shared.history] -- 2865
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 2866
		if canPreExecuteTool(action.tool) then -- 2866
			shared.pendingToolActions = {action} -- 2868
			persistHistoryState(shared) -- 2869
			return ____awaiter_resolve(nil, "batch_tools") -- 2869
		end -- 2869
		clearPreExecutedResults(shared) -- 2872
		persistHistoryState(shared) -- 2873
		return ____awaiter_resolve(nil, result.tool) -- 2873
	end) -- 2873
end -- 2760
local ReadFileAction = __TS__Class() -- 2878
ReadFileAction.name = "ReadFileAction" -- 2878
__TS__ClassExtends(ReadFileAction, Node) -- 2878
function ReadFileAction.prototype.prep(self, shared) -- 2879
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2879
		local last = shared.history[#shared.history] -- 2880
		if not last then -- 2880
			error( -- 2881
				__TS__New(Error, "no history"), -- 2881
				0 -- 2881
			) -- 2881
		end -- 2881
		emitAgentStartEvent(shared, last) -- 2882
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 2883
		if __TS__StringTrim(path) == "" then -- 2883
			error( -- 2886
				__TS__New(Error, "missing path"), -- 2886
				0 -- 2886
			) -- 2886
		end -- 2886
		local ____path_61 = path -- 2888
		local ____shared_workingDir_62 = shared.workingDir -- 2890
		local ____temp_63 = shared.useChineseResponse and "zh" or "en" -- 2891
		local ____last_params_startLine_59 = last.params.startLine -- 2892
		if ____last_params_startLine_59 == nil then -- 2892
			____last_params_startLine_59 = 1 -- 2892
		end -- 2892
		local ____TS__Number_result_64 = __TS__Number(____last_params_startLine_59) -- 2892
		local ____last_params_endLine_60 = last.params.endLine -- 2893
		if ____last_params_endLine_60 == nil then -- 2893
			____last_params_endLine_60 = READ_FILE_DEFAULT_LIMIT -- 2893
		end -- 2893
		return ____awaiter_resolve( -- 2893
			nil, -- 2893
			{ -- 2887
				path = ____path_61, -- 2888
				tool = "read_file", -- 2889
				workDir = ____shared_workingDir_62, -- 2890
				docLanguage = ____temp_63, -- 2891
				startLine = ____TS__Number_result_64, -- 2892
				endLine = __TS__Number(____last_params_endLine_60) -- 2893
			} -- 2893
		) -- 2893
	end) -- 2893
end -- 2879
function ReadFileAction.prototype.exec(self, input) -- 2897
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2897
		return ____awaiter_resolve( -- 2897
			nil, -- 2897
			Tools.readFile( -- 2898
				input.workDir, -- 2899
				input.path, -- 2900
				__TS__Number(input.startLine or 1), -- 2901
				__TS__Number(input.endLine or READ_FILE_DEFAULT_LIMIT), -- 2902
				input.docLanguage -- 2903
			) -- 2903
		) -- 2903
	end) -- 2903
end -- 2897
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 2907
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2907
		local result = execRes -- 2908
		local last = shared.history[#shared.history] -- 2909
		if last ~= nil then -- 2909
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 2911
			appendToolResultMessage(shared, last) -- 2912
			emitAgentFinishEvent(shared, last) -- 2913
		end -- 2913
		persistHistoryState(shared) -- 2915
		__TS__Await(maybeCompressHistory(shared)) -- 2916
		persistHistoryState(shared) -- 2917
		return ____awaiter_resolve(nil, "main") -- 2917
	end) -- 2917
end -- 2907
local SearchFilesAction = __TS__Class() -- 2922
SearchFilesAction.name = "SearchFilesAction" -- 2922
__TS__ClassExtends(SearchFilesAction, Node) -- 2922
function SearchFilesAction.prototype.prep(self, shared) -- 2923
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2923
		local last = shared.history[#shared.history] -- 2924
		if not last then -- 2924
			error( -- 2925
				__TS__New(Error, "no history"), -- 2925
				0 -- 2925
			) -- 2925
		end -- 2925
		emitAgentStartEvent(shared, last) -- 2926
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 2926
	end) -- 2926
end -- 2923
function SearchFilesAction.prototype.exec(self, input) -- 2930
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2930
		local params = input.params -- 2931
		local ____Tools_searchFiles_78 = Tools.searchFiles -- 2932
		local ____input_workDir_71 = input.workDir -- 2933
		local ____temp_72 = params.path or "" -- 2934
		local ____temp_73 = params.pattern or "" -- 2935
		local ____params_globs_74 = params.globs -- 2936
		local ____params_useRegex_75 = params.useRegex -- 2937
		local ____params_caseSensitive_76 = params.caseSensitive -- 2938
		local ____math_max_67 = math.max -- 2941
		local ____math_floor_66 = math.floor -- 2941
		local ____params_limit_65 = params.limit -- 2941
		if ____params_limit_65 == nil then -- 2941
			____params_limit_65 = SEARCH_FILES_LIMIT_DEFAULT -- 2941
		end -- 2941
		local ____math_max_67_result_77 = ____math_max_67( -- 2941
			1, -- 2941
			____math_floor_66(__TS__Number(____params_limit_65)) -- 2941
		) -- 2941
		local ____math_max_70 = math.max -- 2942
		local ____math_floor_69 = math.floor -- 2942
		local ____params_offset_68 = params.offset -- 2942
		if ____params_offset_68 == nil then -- 2942
			____params_offset_68 = 0 -- 2942
		end -- 2942
		local result = __TS__Await(____Tools_searchFiles_78({ -- 2932
			workDir = ____input_workDir_71, -- 2933
			path = ____temp_72, -- 2934
			pattern = ____temp_73, -- 2935
			globs = ____params_globs_74, -- 2936
			useRegex = ____params_useRegex_75, -- 2937
			caseSensitive = ____params_caseSensitive_76, -- 2938
			includeContent = true, -- 2939
			contentWindow = SEARCH_PREVIEW_CONTEXT, -- 2940
			limit = ____math_max_67_result_77, -- 2941
			offset = ____math_max_70( -- 2942
				0, -- 2942
				____math_floor_69(__TS__Number(____params_offset_68)) -- 2942
			), -- 2942
			groupByFile = params.groupByFile == true -- 2943
		})) -- 2943
		return ____awaiter_resolve(nil, result) -- 2943
	end) -- 2943
end -- 2930
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 2948
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2948
		local last = shared.history[#shared.history] -- 2949
		if last ~= nil then -- 2949
			local result = execRes -- 2951
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2952
			appendToolResultMessage(shared, last) -- 2953
			emitAgentFinishEvent(shared, last) -- 2954
		end -- 2954
		persistHistoryState(shared) -- 2956
		__TS__Await(maybeCompressHistory(shared)) -- 2957
		persistHistoryState(shared) -- 2958
		return ____awaiter_resolve(nil, "main") -- 2958
	end) -- 2958
end -- 2948
local SearchDoraAPIAction = __TS__Class() -- 2963
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 2963
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 2963
function SearchDoraAPIAction.prototype.prep(self, shared) -- 2964
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2964
		local last = shared.history[#shared.history] -- 2965
		if not last then -- 2965
			error( -- 2966
				__TS__New(Error, "no history"), -- 2966
				0 -- 2966
			) -- 2966
		end -- 2966
		emitAgentStartEvent(shared, last) -- 2967
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 2967
	end) -- 2967
end -- 2964
function SearchDoraAPIAction.prototype.exec(self, input) -- 2971
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2971
		local params = input.params -- 2972
		local ____Tools_searchDoraAPI_86 = Tools.searchDoraAPI -- 2973
		local ____temp_82 = params.pattern or "" -- 2974
		local ____temp_83 = params.docSource or "api" -- 2975
		local ____temp_84 = input.useChineseResponse and "zh" or "en" -- 2976
		local ____temp_85 = params.programmingLanguage or "ts" -- 2977
		local ____math_min_81 = math.min -- 2978
		local ____math_max_80 = math.max -- 2978
		local ____params_limit_79 = params.limit -- 2978
		if ____params_limit_79 == nil then -- 2978
			____params_limit_79 = 8 -- 2978
		end -- 2978
		local result = __TS__Await(____Tools_searchDoraAPI_86({ -- 2973
			pattern = ____temp_82, -- 2974
			docSource = ____temp_83, -- 2975
			docLanguage = ____temp_84, -- 2976
			programmingLanguage = ____temp_85, -- 2977
			limit = ____math_min_81( -- 2978
				SEARCH_DORA_API_LIMIT_MAX, -- 2978
				____math_max_80( -- 2978
					1, -- 2978
					__TS__Number(____params_limit_79) -- 2978
				) -- 2978
			), -- 2978
			useRegex = params.useRegex, -- 2979
			caseSensitive = false, -- 2980
			includeContent = true, -- 2981
			contentWindow = SEARCH_PREVIEW_CONTEXT -- 2982
		})) -- 2982
		return ____awaiter_resolve(nil, result) -- 2982
	end) -- 2982
end -- 2971
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 2987
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2987
		local last = shared.history[#shared.history] -- 2988
		if last ~= nil then -- 2988
			local result = execRes -- 2990
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 2991
			appendToolResultMessage(shared, last) -- 2992
			emitAgentFinishEvent(shared, last) -- 2993
		end -- 2993
		persistHistoryState(shared) -- 2995
		__TS__Await(maybeCompressHistory(shared)) -- 2996
		persistHistoryState(shared) -- 2997
		return ____awaiter_resolve(nil, "main") -- 2997
	end) -- 2997
end -- 2987
local ListFilesAction = __TS__Class() -- 3002
ListFilesAction.name = "ListFilesAction" -- 3002
__TS__ClassExtends(ListFilesAction, Node) -- 3002
function ListFilesAction.prototype.prep(self, shared) -- 3003
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3003
		local last = shared.history[#shared.history] -- 3004
		if not last then -- 3004
			error( -- 3005
				__TS__New(Error, "no history"), -- 3005
				0 -- 3005
			) -- 3005
		end -- 3005
		emitAgentStartEvent(shared, last) -- 3006
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3006
	end) -- 3006
end -- 3003
function ListFilesAction.prototype.exec(self, input) -- 3010
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3010
		local params = input.params -- 3011
		local ____Tools_listFiles_93 = Tools.listFiles -- 3012
		local ____input_workDir_90 = input.workDir -- 3013
		local ____temp_91 = params.path or "" -- 3014
		local ____params_globs_92 = params.globs -- 3015
		local ____math_max_89 = math.max -- 3016
		local ____math_floor_88 = math.floor -- 3016
		local ____params_maxEntries_87 = params.maxEntries -- 3016
		if ____params_maxEntries_87 == nil then -- 3016
			____params_maxEntries_87 = LIST_FILES_MAX_ENTRIES_DEFAULT -- 3016
		end -- 3016
		local result = ____Tools_listFiles_93({ -- 3012
			workDir = ____input_workDir_90, -- 3013
			path = ____temp_91, -- 3014
			globs = ____params_globs_92, -- 3015
			maxEntries = ____math_max_89( -- 3016
				1, -- 3016
				____math_floor_88(__TS__Number(____params_maxEntries_87)) -- 3016
			) -- 3016
		}) -- 3016
		return ____awaiter_resolve(nil, result) -- 3016
	end) -- 3016
end -- 3010
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3021
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3021
		local last = shared.history[#shared.history] -- 3022
		if last ~= nil then -- 3022
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3024
			appendToolResultMessage(shared, last) -- 3025
			emitAgentFinishEvent(shared, last) -- 3026
		end -- 3026
		persistHistoryState(shared) -- 3028
		__TS__Await(maybeCompressHistory(shared)) -- 3029
		persistHistoryState(shared) -- 3030
		return ____awaiter_resolve(nil, "main") -- 3030
	end) -- 3030
end -- 3021
local DeleteFileAction = __TS__Class() -- 3035
DeleteFileAction.name = "DeleteFileAction" -- 3035
__TS__ClassExtends(DeleteFileAction, Node) -- 3035
function DeleteFileAction.prototype.prep(self, shared) -- 3036
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3036
		local last = shared.history[#shared.history] -- 3037
		if not last then -- 3037
			error( -- 3038
				__TS__New(Error, "no history"), -- 3038
				0 -- 3038
			) -- 3038
		end -- 3038
		emitAgentStartEvent(shared, last) -- 3039
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3040
		if __TS__StringTrim(targetFile) == "" then -- 3040
			error( -- 3043
				__TS__New(Error, "missing target_file"), -- 3043
				0 -- 3043
			) -- 3043
		end -- 3043
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3043
	end) -- 3043
end -- 3036
function DeleteFileAction.prototype.exec(self, input) -- 3047
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3047
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3048
		if not result.success then -- 3048
			return ____awaiter_resolve(nil, result) -- 3048
		end -- 3048
		return ____awaiter_resolve(nil, { -- 3048
			success = true, -- 3056
			changed = true, -- 3057
			mode = "delete", -- 3058
			checkpointId = result.checkpointId, -- 3059
			checkpointSeq = result.checkpointSeq, -- 3060
			files = {{path = input.targetFile, op = "delete"}} -- 3061
		}) -- 3061
	end) -- 3061
end -- 3047
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3065
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3065
		local last = shared.history[#shared.history] -- 3066
		if last ~= nil then -- 3066
			last.result = execRes -- 3068
			appendToolResultMessage(shared, last) -- 3069
			emitAgentFinishEvent(shared, last) -- 3070
			local result = last.result -- 3071
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3071
				emitAgentEvent(shared, { -- 3076
					type = "checkpoint_created", -- 3077
					sessionId = shared.sessionId, -- 3078
					taskId = shared.taskId, -- 3079
					step = last.step, -- 3080
					tool = "delete_file", -- 3081
					checkpointId = result.checkpointId, -- 3082
					checkpointSeq = result.checkpointSeq, -- 3083
					files = result.files -- 3084
				}) -- 3084
			end -- 3084
		end -- 3084
		persistHistoryState(shared) -- 3088
		__TS__Await(maybeCompressHistory(shared)) -- 3089
		persistHistoryState(shared) -- 3090
		return ____awaiter_resolve(nil, "main") -- 3090
	end) -- 3090
end -- 3065
local BuildAction = __TS__Class() -- 3095
BuildAction.name = "BuildAction" -- 3095
__TS__ClassExtends(BuildAction, Node) -- 3095
function BuildAction.prototype.prep(self, shared) -- 3096
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3096
		local last = shared.history[#shared.history] -- 3097
		if not last then -- 3097
			error( -- 3098
				__TS__New(Error, "no history"), -- 3098
				0 -- 3098
			) -- 3098
		end -- 3098
		emitAgentStartEvent(shared, last) -- 3099
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3099
	end) -- 3099
end -- 3096
function BuildAction.prototype.exec(self, input) -- 3103
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3103
		local params = input.params -- 3104
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3105
		return ____awaiter_resolve(nil, result) -- 3105
	end) -- 3105
end -- 3103
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3112
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3112
		local last = shared.history[#shared.history] -- 3113
		if last ~= nil then -- 3113
			last.result = sanitizeBuildResultForHistory(execRes) -- 3115
			appendToolResultMessage(shared, last) -- 3116
			emitAgentFinishEvent(shared, last) -- 3117
		end -- 3117
		persistHistoryState(shared) -- 3119
		__TS__Await(maybeCompressHistory(shared)) -- 3120
		persistHistoryState(shared) -- 3121
		return ____awaiter_resolve(nil, "main") -- 3121
	end) -- 3121
end -- 3112
local SpawnSubAgentAction = __TS__Class() -- 3126
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3126
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3126
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3127
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3127
		local last = shared.history[#shared.history] -- 3136
		if not last then -- 3136
			error( -- 3137
				__TS__New(Error, "no history"), -- 3137
				0 -- 3137
			) -- 3137
		end -- 3137
		emitAgentStartEvent(shared, last) -- 3138
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3139
			last.params.filesHint, -- 3140
			function(____, item) return type(item) == "string" end -- 3140
		) or nil -- 3140
		return ____awaiter_resolve( -- 3140
			nil, -- 3140
			{ -- 3142
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3143
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3144
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3145
				filesHint = filesHint, -- 3146
				sessionId = shared.sessionId, -- 3147
				projectRoot = shared.workingDir, -- 3148
				spawnSubAgent = shared.spawnSubAgent -- 3149
			} -- 3149
		) -- 3149
	end) -- 3149
end -- 3127
function SpawnSubAgentAction.prototype.exec(self, input) -- 3153
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3153
		if not input.spawnSubAgent then -- 3153
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3153
		end -- 3153
		if input.sessionId == nil or input.sessionId <= 0 then -- 3153
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3153
		end -- 3153
		local ____Log_99 = Log -- 3168
		local ____temp_96 = #input.title -- 3168
		local ____temp_97 = #input.prompt -- 3168
		local ____temp_98 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3168
		local ____opt_94 = input.filesHint -- 3168
		____Log_99( -- 3168
			"Info", -- 3168
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_96)) .. " prompt_len=") .. tostring(____temp_97)) .. " expected_len=") .. tostring(____temp_98)) .. " files_hint_count=") .. tostring(____opt_94 and #____opt_94 or 0) -- 3168
		) -- 3168
		local result = __TS__Await(input.spawnSubAgent({ -- 3169
			parentSessionId = input.sessionId, -- 3170
			projectRoot = input.projectRoot, -- 3171
			title = input.title, -- 3172
			prompt = input.prompt, -- 3173
			expectedOutput = input.expectedOutput, -- 3174
			filesHint = input.filesHint -- 3175
		})) -- 3175
		if not result.success then -- 3175
			return ____awaiter_resolve(nil, result) -- 3175
		end -- 3175
		return ____awaiter_resolve(nil, { -- 3175
			success = true, -- 3181
			sessionId = result.sessionId, -- 3182
			taskId = result.taskId, -- 3183
			title = result.title, -- 3184
			hint = "If the necessary sub-agents have already been dispatched, end this turn directly and do not immediately check their results." -- 3185
		}) -- 3185
	end) -- 3185
end -- 3153
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3189
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3189
		local last = shared.history[#shared.history] -- 3190
		if last ~= nil then -- 3190
			last.result = execRes -- 3192
			appendToolResultMessage(shared, last) -- 3193
			emitAgentFinishEvent(shared, last) -- 3194
		end -- 3194
		persistHistoryState(shared) -- 3196
		__TS__Await(maybeCompressHistory(shared)) -- 3197
		persistHistoryState(shared) -- 3198
		return ____awaiter_resolve(nil, "main") -- 3198
	end) -- 3198
end -- 3189
local ListSubAgentsAction = __TS__Class() -- 3203
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3203
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3203
function ListSubAgentsAction.prototype.prep(self, shared) -- 3204
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3204
		local last = shared.history[#shared.history] -- 3213
		if not last then -- 3213
			error( -- 3214
				__TS__New(Error, "no history"), -- 3214
				0 -- 3214
			) -- 3214
		end -- 3214
		emitAgentStartEvent(shared, last) -- 3215
		return ____awaiter_resolve( -- 3215
			nil, -- 3215
			{ -- 3216
				sessionId = shared.sessionId, -- 3217
				projectRoot = shared.workingDir, -- 3218
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3219
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3220
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3221
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3222
				listSubAgents = shared.listSubAgents -- 3223
			} -- 3223
		) -- 3223
	end) -- 3223
end -- 3204
function ListSubAgentsAction.prototype.exec(self, input) -- 3227
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3227
		if not input.listSubAgents then -- 3227
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3227
		end -- 3227
		if input.sessionId == nil or input.sessionId <= 0 then -- 3227
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3227
		end -- 3227
		local result = __TS__Await(input.listSubAgents({ -- 3242
			sessionId = input.sessionId, -- 3243
			projectRoot = input.projectRoot, -- 3244
			status = input.status, -- 3245
			limit = input.limit, -- 3246
			offset = input.offset, -- 3247
			query = input.query -- 3248
		})) -- 3248
		return ____awaiter_resolve(nil, result) -- 3248
	end) -- 3248
end -- 3227
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3253
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3253
		local last = shared.history[#shared.history] -- 3254
		if last ~= nil then -- 3254
			last.result = execRes -- 3256
			appendToolResultMessage(shared, last) -- 3257
			emitAgentFinishEvent(shared, last) -- 3258
		end -- 3258
		persistHistoryState(shared) -- 3260
		__TS__Await(maybeCompressHistory(shared)) -- 3261
		persistHistoryState(shared) -- 3262
		return ____awaiter_resolve(nil, "main") -- 3262
	end) -- 3262
end -- 3253
EditFileAction = __TS__Class() -- 3267
EditFileAction.name = "EditFileAction" -- 3267
__TS__ClassExtends(EditFileAction, Node) -- 3267
function EditFileAction.prototype.prep(self, shared) -- 3268
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3268
		local last = shared.history[#shared.history] -- 3269
		if not last then -- 3269
			error( -- 3270
				__TS__New(Error, "no history"), -- 3270
				0 -- 3270
			) -- 3270
		end -- 3270
		emitAgentStartEvent(shared, last) -- 3271
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3272
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3275
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3276
		if __TS__StringTrim(path) == "" then -- 3276
			error( -- 3277
				__TS__New(Error, "missing path"), -- 3277
				0 -- 3277
			) -- 3277
		end -- 3277
		return ____awaiter_resolve(nil, { -- 3277
			path = path, -- 3278
			oldStr = oldStr, -- 3278
			newStr = newStr, -- 3278
			taskId = shared.taskId, -- 3278
			workDir = shared.workingDir -- 3278
		}) -- 3278
	end) -- 3278
end -- 3268
function EditFileAction.prototype.exec(self, input) -- 3281
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3281
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3282
		if not readRes.success then -- 3282
			if input.oldStr ~= "" then -- 3282
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3282
			end -- 3282
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3287
			if not createRes.success then -- 3287
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3287
			end -- 3287
			return ____awaiter_resolve(nil, { -- 3287
				success = true, -- 3295
				changed = true, -- 3296
				mode = "create", -- 3297
				checkpointId = createRes.checkpointId, -- 3298
				checkpointSeq = createRes.checkpointSeq, -- 3299
				files = {{path = input.path, op = "create"}} -- 3300
			}) -- 3300
		end -- 3300
		if input.oldStr == "" then -- 3300
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3304
			if not overwriteRes.success then -- 3304
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3304
			end -- 3304
			return ____awaiter_resolve(nil, { -- 3304
				success = true, -- 3312
				changed = true, -- 3313
				mode = "overwrite", -- 3314
				checkpointId = overwriteRes.checkpointId, -- 3315
				checkpointSeq = overwriteRes.checkpointSeq, -- 3316
				files = {{path = input.path, op = "write"}} -- 3317
			}) -- 3317
		end -- 3317
		local normalizedContent = normalizeLineEndings(readRes.content) -- 3322
		local normalizedOldStr = normalizeLineEndings(input.oldStr) -- 3323
		local normalizedNewStr = normalizeLineEndings(input.newStr) -- 3324
		local occurrences = countOccurrences(normalizedContent, normalizedOldStr) -- 3327
		if occurrences == 0 then -- 3327
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3329
			if not indentTolerant.success then -- 3329
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3329
			end -- 3329
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3333
			if not applyRes.success then -- 3333
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3333
			end -- 3333
			return ____awaiter_resolve(nil, { -- 3333
				success = true, -- 3341
				changed = true, -- 3342
				mode = "replace_indent_tolerant", -- 3343
				checkpointId = applyRes.checkpointId, -- 3344
				checkpointSeq = applyRes.checkpointSeq, -- 3345
				files = {{path = input.path, op = "write"}} -- 3346
			}) -- 3346
		end -- 3346
		if occurrences > 1 then -- 3346
			return ____awaiter_resolve( -- 3346
				nil, -- 3346
				{ -- 3350
					success = false, -- 3350
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3350
				} -- 3350
			) -- 3350
		end -- 3350
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3354
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3355
		if not applyRes.success then -- 3355
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3355
		end -- 3355
		return ____awaiter_resolve(nil, { -- 3355
			success = true, -- 3363
			changed = true, -- 3364
			mode = "replace", -- 3365
			checkpointId = applyRes.checkpointId, -- 3366
			checkpointSeq = applyRes.checkpointSeq, -- 3367
			files = {{path = input.path, op = "write"}} -- 3368
		}) -- 3368
	end) -- 3368
end -- 3281
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3372
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3372
		local last = shared.history[#shared.history] -- 3373
		if last ~= nil then -- 3373
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3375
			last.result = execRes -- 3376
			appendToolResultMessage(shared, last) -- 3377
			emitAgentFinishEvent(shared, last) -- 3378
			local result = last.result -- 3379
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3379
				emitAgentEvent(shared, { -- 3384
					type = "checkpoint_created", -- 3385
					sessionId = shared.sessionId, -- 3386
					taskId = shared.taskId, -- 3387
					step = last.step, -- 3388
					tool = last.tool, -- 3389
					checkpointId = result.checkpointId, -- 3390
					checkpointSeq = result.checkpointSeq, -- 3391
					files = result.files -- 3392
				}) -- 3392
			end -- 3392
		end -- 3392
		persistHistoryState(shared) -- 3396
		__TS__Await(maybeCompressHistory(shared)) -- 3397
		persistHistoryState(shared) -- 3398
		return ____awaiter_resolve(nil, "main") -- 3398
	end) -- 3398
end -- 3372
local function emitCheckpointEventForAction(shared, action) -- 3403
	local result = action.result -- 3404
	if not result then -- 3404
		return -- 3405
	end -- 3405
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3405
		emitAgentEvent(shared, { -- 3410
			type = "checkpoint_created", -- 3411
			sessionId = shared.sessionId, -- 3412
			taskId = shared.taskId, -- 3413
			step = action.step, -- 3414
			tool = action.tool, -- 3415
			checkpointId = result.checkpointId, -- 3416
			checkpointSeq = result.checkpointSeq, -- 3417
			files = result.files -- 3418
		}) -- 3418
	end -- 3418
end -- 3403
local function sanitizeToolActionResultForHistory(action, result) -- 3573
	if action.tool == "read_file" then -- 3573
		return sanitizeReadResultForHistory(action.tool, result) -- 3575
	end -- 3575
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 3575
		return sanitizeSearchResultForHistory(action.tool, result) -- 3578
	end -- 3578
	if action.tool == "glob_files" then -- 3578
		return sanitizeListFilesResultForHistory(result) -- 3581
	end -- 3581
	if action.tool == "build" then -- 3581
		return sanitizeBuildResultForHistory(result) -- 3584
	end -- 3584
	return result -- 3586
end -- 3573
local function canRunBatchActionInParallel(self, action) -- 3589
	return action.tool == "read_file" or action.tool == "grep_files" or action.tool == "search_dora_api" or action.tool == "glob_files" or action.tool == "list_sub_agents" -- 3590
end -- 3589
local function partitionToolCalls(actions) -- 3602
	local batches = {} -- 3603
	do -- 3603
		local i = 0 -- 3604
		while i < #actions do -- 3604
			local action = actions[i + 1] -- 3605
			local isSafe = canRunBatchActionInParallel(nil, action) -- 3606
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 3607
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 3607
				local ____lastBatch_actions_134 = lastBatch.actions -- 3607
				____lastBatch_actions_134[#____lastBatch_actions_134 + 1] = action -- 3609
			else -- 3609
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 3611
			end -- 3611
			i = i + 1 -- 3604
		end -- 3604
	end -- 3604
	return batches -- 3614
end -- 3602
local BatchToolAction = __TS__Class() -- 3617
BatchToolAction.name = "BatchToolAction" -- 3617
__TS__ClassExtends(BatchToolAction, Node) -- 3617
function BatchToolAction.prototype.prep(self, shared) -- 3618
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3618
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 3618
	end) -- 3618
end -- 3618
function BatchToolAction.prototype.exec(self, input) -- 3622
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3622
		local shared = input.shared -- 3623
		local preExecuted = shared.preExecutedResults -- 3624
		local batches = partitionToolCalls(input.actions) -- 3625
		local parallelBatchCount = #__TS__ArrayFilter( -- 3626
			batches, -- 3626
			function(____, b) return b.isConcurrencySafe end -- 3626
		) -- 3626
		local serialBatchCount = #__TS__ArrayFilter( -- 3627
			batches, -- 3627
			function(____, b) return not b.isConcurrencySafe end -- 3627
		) -- 3627
		Log( -- 3628
			"Info", -- 3628
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 3628
		) -- 3628
		do -- 3628
			local batchIdx = 0 -- 3630
			while batchIdx < #batches do -- 3630
				do -- 3630
					local batch = batches[batchIdx + 1] -- 3631
					if shared.stopToken.stopped then -- 3631
						for ____, action in ipairs(batch.actions) do -- 3633
							if not action.result then -- 3633
								action.result = { -- 3635
									success = false, -- 3635
									message = getCancelledReason(shared) -- 3635
								} -- 3635
							end -- 3635
						end -- 3635
						goto __continue568 -- 3638
					end -- 3638
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 3638
						local preExecCount = #__TS__ArrayFilter( -- 3642
							batch.actions, -- 3642
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 3642
						) -- 3642
						Log( -- 3643
							"Info", -- 3643
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 3643
						) -- 3643
						do -- 3643
							local i = 0 -- 3644
							while i < #batch.actions do -- 3644
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 3645
								i = i + 1 -- 3644
							end -- 3644
						end -- 3644
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 3647
							batch.actions, -- 3647
							function(____, action) -- 3647
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3647
									if shared.stopToken.stopped then -- 3647
										action.result = { -- 3649
											success = false, -- 3649
											message = getCancelledReason(shared) -- 3649
										} -- 3649
										return ____awaiter_resolve(nil, action) -- 3649
									end -- 3649
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3652
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3653
									action.result = sanitizeToolActionResultForHistory(action, result) -- 3654
									return ____awaiter_resolve(nil, action) -- 3654
								end) -- 3654
							end -- 3647
						))) -- 3647
						do -- 3647
							local i = 0 -- 3657
							while i < #batch.actions do -- 3657
								local action = batch.actions[i + 1] -- 3658
								if not action.result then -- 3658
									action.result = {success = false, message = "tool did not produce a result"} -- 3660
								end -- 3660
								appendToolResultMessage(shared, action) -- 3662
								emitAgentFinishEvent(shared, action) -- 3663
								emitCheckpointEventForAction(shared, action) -- 3664
								i = i + 1 -- 3657
							end -- 3657
						end -- 3657
					else -- 3657
						Log( -- 3667
							"Info", -- 3667
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 3667
						) -- 3667
						do -- 3667
							local i = 0 -- 3668
							while i < #batch.actions do -- 3668
								local action = batch.actions[i + 1] -- 3669
								emitAgentStartEvent(shared, action) -- 3670
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 3671
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 3672
								action.result = sanitizeToolActionResultForHistory(action, result) -- 3673
								appendToolResultMessage(shared, action) -- 3674
								emitAgentFinishEvent(shared, action) -- 3675
								emitCheckpointEventForAction(shared, action) -- 3676
								persistHistoryState(shared) -- 3677
								if shared.stopToken.stopped then -- 3677
									break -- 3679
								end -- 3679
								i = i + 1 -- 3668
							end -- 3668
						end -- 3668
					end -- 3668
				end -- 3668
				::__continue568:: -- 3668
				batchIdx = batchIdx + 1 -- 3630
			end -- 3630
		end -- 3630
		persistHistoryState(shared) -- 3684
		return ____awaiter_resolve(nil, input.actions) -- 3684
	end) -- 3684
end -- 3622
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 3688
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3688
		shared.pendingToolActions = nil -- 3689
		shared.preExecutedResults = nil -- 3690
		persistHistoryState(shared) -- 3691
		__TS__Await(maybeCompressHistory(shared)) -- 3692
		persistHistoryState(shared) -- 3693
		return ____awaiter_resolve(nil, "main") -- 3693
	end) -- 3693
end -- 3688
local EndNode = __TS__Class() -- 3698
EndNode.name = "EndNode" -- 3698
__TS__ClassExtends(EndNode, Node) -- 3698
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 3699
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3699
		return ____awaiter_resolve(nil, nil) -- 3699
	end) -- 3699
end -- 3699
local CodingAgentFlow = __TS__Class() -- 3704
CodingAgentFlow.name = "CodingAgentFlow" -- 3704
__TS__ClassExtends(CodingAgentFlow, Flow) -- 3704
function CodingAgentFlow.prototype.____constructor(self, role) -- 3705
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 3706
	local read = __TS__New(ReadFileAction, 1, 0) -- 3707
	local search = __TS__New(SearchFilesAction, 1, 0) -- 3708
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 3709
	local list = __TS__New(ListFilesAction, 1, 0) -- 3710
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 3711
	local del = __TS__New(DeleteFileAction, 1, 0) -- 3712
	local build = __TS__New(BuildAction, 1, 0) -- 3713
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 3714
	local edit = __TS__New(EditFileAction, 1, 0) -- 3715
	local batch = __TS__New(BatchToolAction, 1, 0) -- 3716
	local done = __TS__New(EndNode, 1, 0) -- 3717
	main:on("batch_tools", batch) -- 3719
	main:on("grep_files", search) -- 3720
	main:on("search_dora_api", searchDora) -- 3721
	main:on("glob_files", list) -- 3722
	if role == "main" then -- 3722
		main:on("read_file", read) -- 3724
		main:on("delete_file", del) -- 3725
		main:on("build", build) -- 3726
		main:on("edit_file", edit) -- 3727
		main:on("list_sub_agents", listSub) -- 3728
		main:on("spawn_sub_agent", spawn) -- 3729
	else -- 3729
		main:on("read_file", read) -- 3731
		main:on("delete_file", del) -- 3732
		main:on("build", build) -- 3733
		main:on("edit_file", edit) -- 3734
	end -- 3734
	main:on("done", done) -- 3736
	search:on("main", main) -- 3738
	searchDora:on("main", main) -- 3739
	list:on("main", main) -- 3740
	listSub:on("main", main) -- 3741
	spawn:on("main", main) -- 3742
	batch:on("main", main) -- 3743
	read:on("main", main) -- 3744
	del:on("main", main) -- 3745
	build:on("main", main) -- 3746
	edit:on("main", main) -- 3747
	Flow.prototype.____constructor(self, main) -- 3749
end -- 3705
local function runCodingAgentAsync(options) -- 3771
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3771
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 3771
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 3771
		end -- 3771
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 3775
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 3776
		if not llmConfigRes.success then -- 3776
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 3776
		end -- 3776
		local llmConfig = llmConfigRes.config -- 3782
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt) -- 3783
		if not taskRes.success then -- 3783
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 3783
		end -- 3783
		local compressor = __TS__New(MemoryCompressor, { -- 3790
			compressionThreshold = 0.8, -- 3791
			compressionTargetThreshold = 0.5, -- 3792
			maxCompressionRounds = 3, -- 3793
			projectDir = options.workDir, -- 3794
			llmConfig = llmConfig, -- 3795
			promptPack = options.promptPack, -- 3796
			scope = options.memoryScope -- 3797
		}) -- 3797
		local persistedSession = compressor:getStorage():readSessionState() -- 3799
		local promptPack = compressor:getPromptPack() -- 3800
		local shared = { -- 3802
			sessionId = options.sessionId, -- 3803
			taskId = taskRes.taskId, -- 3804
			role = options.role or "main", -- 3805
			maxSteps = math.max( -- 3806
				1, -- 3806
				math.floor(options.maxSteps or AGENT_DEFAULT_MAX_STEPS) -- 3806
			), -- 3806
			llmMaxTry = math.max( -- 3807
				1, -- 3807
				math.floor(options.llmMaxTry or AGENT_DEFAULT_LLM_MAX_TRY) -- 3807
			), -- 3807
			step = 0, -- 3808
			done = false, -- 3809
			stopToken = options.stopToken or ({stopped = false}), -- 3810
			response = "", -- 3811
			userQuery = normalizedPrompt, -- 3812
			workingDir = options.workDir, -- 3813
			useChineseResponse = options.useChineseResponse == true, -- 3814
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 3815
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 3818
			llmConfig = llmConfig, -- 3819
			onEvent = options.onEvent, -- 3820
			promptPack = promptPack, -- 3821
			history = {}, -- 3822
			messages = persistedSession.messages, -- 3823
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 3824
			carryMessageIndex = persistedSession.carryMessageIndex, -- 3825
			memory = {compressor = compressor}, -- 3827
			skills = {loader = createSkillsLoader({projectDir = options.workDir})}, -- 3831
			spawnSubAgent = options.spawnSubAgent, -- 3836
			listSubAgents = options.listSubAgents -- 3837
		} -- 3837
		local ____try = __TS__AsyncAwaiter(function() -- 3837
			emitAgentEvent(shared, { -- 3841
				type = "task_started", -- 3842
				sessionId = shared.sessionId, -- 3843
				taskId = shared.taskId, -- 3844
				prompt = shared.userQuery, -- 3845
				workDir = shared.workingDir, -- 3846
				maxSteps = shared.maxSteps -- 3847
			}) -- 3847
			if shared.stopToken.stopped then -- 3847
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3850
				return ____awaiter_resolve( -- 3850
					nil, -- 3850
					emitAgentTaskFinishEvent( -- 3851
						shared, -- 3851
						false, -- 3851
						getCancelledReason(shared) -- 3851
					) -- 3851
				) -- 3851
			end -- 3851
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 3853
			local promptCommand = getPromptCommand(shared.userQuery) -- 3854
			if promptCommand == "clear" then -- 3854
				return ____awaiter_resolve( -- 3854
					nil, -- 3854
					clearSessionHistory(shared) -- 3856
				) -- 3856
			end -- 3856
			if promptCommand == "compact" then -- 3856
				if shared.role == "sub" then -- 3856
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 3860
					return ____awaiter_resolve( -- 3860
						nil, -- 3860
						emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 3861
					) -- 3861
				end -- 3861
				return ____awaiter_resolve( -- 3861
					nil, -- 3861
					__TS__Await(compactAllHistory(shared)) -- 3869
				) -- 3869
			end -- 3869
			appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 3871
			persistHistoryState(shared) -- 3875
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 3876
			__TS__Await(flow:run(shared)) -- 3877
			if shared.stopToken.stopped then -- 3877
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 3879
				return ____awaiter_resolve( -- 3879
					nil, -- 3879
					emitAgentTaskFinishEvent( -- 3880
						shared, -- 3880
						false, -- 3880
						getCancelledReason(shared) -- 3880
					) -- 3880
				) -- 3880
			end -- 3880
			if shared.error then -- 3880
				return ____awaiter_resolve( -- 3880
					nil, -- 3880
					finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 3883
				) -- 3883
			end -- 3883
			Tools.setTaskStatus(shared.taskId, "DONE") -- 3886
			return ____awaiter_resolve( -- 3886
				nil, -- 3886
				emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 3887
			) -- 3887
		end) -- 3887
		__TS__Await(____try.catch( -- 3840
			____try, -- 3840
			function(____, e) -- 3840
				return ____awaiter_resolve( -- 3840
					nil, -- 3840
					finalizeAgentFailure( -- 3890
						shared, -- 3890
						tostring(e) -- 3890
					) -- 3890
				) -- 3890
			end -- 3890
		)) -- 3890
	end) -- 3890
end -- 3771
function ____exports.runCodingAgent(options, callback) -- 3894
	local ____self_137 = runCodingAgentAsync(options) -- 3894
	____self_137["then"]( -- 3894
		____self_137, -- 3894
		function(____, result) return callback(result) end -- 3895
	) -- 3895
end -- 3894
return ____exports -- 3894