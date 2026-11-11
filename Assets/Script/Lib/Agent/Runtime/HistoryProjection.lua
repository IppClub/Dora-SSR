local ____lualib = require("lualib_bundle")
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local __TS__ArraySort = ____lualib.__TS__ArraySort
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__ArrayPush = ____lualib.__TS__ArrayPush
local ____exports = {}
local AgentUtils = require("Agent.Utils")
local AgentConfig = require("Agent.Config.Defaults")
--- Frontend lifecycle stays on the step; the model receives only the build outcome.
function ____exports.projectBuildResultForModel(result, execution)
	if execution ~= nil and execution.status ~= "DONE" or result.failureKind == "tool" or type(result.code) == "string" then
		return {message = "Build tool call failed: " .. (type(result.message) == "string" and result.message or "unknown failure")}
	end
	return result
end
local function isRecord(value)
	return type(value) == "table"
end
local function isArray(value)
	return __TS__ArrayIsArray(value)
end
function ____exports.toJson(value, emptyAsArray)
	local text, err = AgentUtils.safeJsonEncode(value, false, emptyAsArray)
	if text ~= nil then
		return text
	end
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }"
end
function ____exports.truncateText(text, maxLen)
	local nextPos = utf8.offset(text, maxLen + 1)
	if nextPos == nil then
		return text
	end
	return string.sub(text, 1, nextPos - 1) .. "..."
end
local function utf8TakeHead(text, maxChars)
	if maxChars <= 0 or text == "" then
		return ""
	end
	local nextPos = utf8.offset(text, maxChars + 1)
	if nextPos == nil then
		return text
	end
	return string.sub(text, 1, nextPos - 1)
end
local function utf8TakeTail(text, maxChars)
	if maxChars <= 0 or text == "" then
		return ""
	end
	local charLength = utf8.len(text)
	if charLength == nil or charLength <= maxChars then
		return text
	end
	local startPos = utf8.offset(
		text,
		math.max(1, charLength - maxChars + 1)
	)
	if startPos == nil then
		return text
	end
	return string.sub(text, startPos)
end
local function truncateHistoryText(text, maxChars, label)
	if maxChars <= 0 or text == "" then
		return ""
	end
	if #text <= maxChars then
		return text
	end
	local marker = ((("\n...[" .. label) .. " truncated; ") .. tostring(#text)) .. " chars total]...\n"
	local remaining = math.max(0, maxChars - #marker)
	local headChars = math.floor(remaining * 0.6)
	local tailChars = remaining - headChars
	return (utf8TakeHead(text, headChars) .. marker) .. utf8TakeTail(text, tailChars)
end
local function limitReadContentForHistory(content, startLine, endLine, totalLines, maxChars, maxLines, label)
	local sourceLineCount = endLine >= startLine and endLine - startLine + 1 or 0
	local contentLines = __TS__StringSplit(content, "\n")
	local availableSourceLines = math.min(sourceLineCount, #contentLines)
	if #content <= maxChars and availableSourceLines <= maxLines then
		return {content = content, truncated = false, retainedStartLine = startLine, retainedEndLine = endLine}
	end
	local contentBudget = math.max(0, maxChars - 240)
	local candidateLines = math.min(availableSourceLines, maxLines)
	local retainedLines = {}
	local retainedChars = 0
	do
		local i = 0
		while i < candidateLines do
			local line = contentLines[i + 1]
			local nextChars = retainedChars + #line + (#retainedLines > 0 and 1 or 0)
			if nextChars > contentBudget then
				break
			end
			retainedLines[#retainedLines + 1] = line
			retainedChars = nextChars
			i = i + 1
		end
	end
	local retainedEndLine = startLine + #retainedLines - 1
	local partialLine
	local retainedContent = table.concat(retainedLines, "\n")
	if #retainedLines == 0 and candidateLines > 0 then
		partialLine = startLine
		retainedEndLine = startLine - 1
		retainedContent = utf8TakeHead(contentLines[1], contentBudget)
	end
	local nextStartLine = retainedEndLine < endLine and retainedEndLine + 1 or nil
	local retainedRange = #retainedLines > 0 and (("complete lines " .. tostring(startLine)) .. "-") .. tostring(retainedEndLine) or (partialLine ~= nil and "a partial preview of overlong line " .. tostring(partialLine) or "no source lines")
	local continuation = nextStartLine ~= nil and (" Use read_file with startLine=" .. tostring(nextStartLine)) .. " and a narrower endLine to continue." or ""
	local marker = ((((((((((("[" .. label) .. " retained ") .. retainedRange) .. " of requested lines ") .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (") .. tostring(totalLines)) .. " lines total).") .. continuation) .. "]"
	return {
		content = retainedContent == "" and marker or (retainedContent .. "\n\n") .. marker,
		truncated = true,
		retainedStartLine = startLine,
		retainedEndLine = retainedEndLine,
		nextStartLine = nextStartLine,
		partialLine = partialLine
	}
end
local function summarizeEditTextParamForHistory(value, key)
	if type(value) ~= "string" then
		return nil
	end
	local text = value
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n")
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"}
end
local function sanitizeOneReadResultForHistory(result)
	if result.success ~= true or type(result.content) ~= "string" then
		return result
	end
	local clone = {}
	for key in pairs(result) do
		clone[key] = result[key]
	end
	local startLine = type(result.startLine) == "number" and result.startLine or 1
	local endLine = type(result.endLine) == "number" and result.endLine or startLine
	local totalLines = type(result.totalLines) == "number" and result.totalLines or endLine
	local limited = limitReadContentForHistory(
		result.content,
		startLine,
		endLine,
		totalLines,
		AgentConfig.AGENT_LIMITS.historyReadFileMaxChars,
		AgentConfig.AGENT_LIMITS.historyReadFileMaxLines,
		"read_file history"
	)
	clone.content = limited.content
	if limited.truncated then
		clone.historyContentTruncated = true
		clone.historyRetainedStartLine = limited.retainedStartLine
		clone.historyRetainedEndLine = limited.retainedEndLine
		if limited.nextStartLine ~= nil then
			clone.historyNextStartLine = limited.nextStartLine
		end
		if limited.partialLine ~= nil then
			clone.historyPartialLine = limited.partialLine
		end
	end
	return clone
end
function ____exports.sanitizeReadResultForHistory(tool, result)
	if tool ~= "read_file" then
		return result
	end
	if not __TS__ArrayIsArray(result.results) then
		return sanitizeOneReadResultForHistory(result)
	end
	local clone = {}
	for key in pairs(result) do
		clone[key] = result[key]
	end
	clone.results = __TS__ArrayMap(
		result.results,
		function(____, item) return isRecord(item) and not isArray(item) and sanitizeOneReadResultForHistory(item) or item end
	)
	return clone
end
local function sanitizeSearchMatchesForHistory(items, maxItems)
	local shown = math.min(#items, maxItems)
	local out = {}
	do
		local i = 0
		while i < shown do
			local row = items[i + 1]
			out[#out + 1] = {
				file = row.file,
				line = row.line,
				content = type(row.content) == "string" and ____exports.truncateText(row.content, 240) or row.content
			}
			i = i + 1
		end
	end
	return out
end
function ____exports.sanitizeSearchResultForHistory(tool, result)
	if result.success ~= true or not isArray(result.results) then
		return result
	end
	if tool ~= "grep_files" and tool ~= "search_dora_doc" then
		return result
	end
	local clone = {}
	for key in pairs(result) do
		clone[key] = result[key]
	end
	local maxItems = tool == "grep_files" and AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches or AgentConfig.AGENT_LIMITS.historySearchDoraApiMaxMatches
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems)
	if tool == "grep_files" and isArray(result.groupedResults) then
		local grouped = result.groupedResults
		local shown = math.min(#grouped, AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches)
		local sanitizedGroups = {}
		do
			local i = 0
			while i < shown do
				local row = grouped[i + 1]
				sanitizedGroups[#sanitizedGroups + 1] = {
					file = row.file,
					totalMatches = row.totalMatches,
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({})
				}
				i = i + 1
			end
		end
		clone.groupedResults = sanitizedGroups
	end
	return clone
end
function ____exports.sanitizeListFilesResultForHistory(result)
	if result.success ~= true or not isArray(result.files) then
		return result
	end
	local clone = {}
	for key in pairs(result) do
		clone[key] = result[key]
	end
	clone.files = __TS__ArraySlice(result.files, 0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries)
	return clone
end
function ____exports.sanitizeBuildResultForHistory(result)
	if not isArray(result.messages) then
		return result
	end
	local clone = {}
	for key in pairs(result) do
		clone[key] = result[key]
	end
	local messages = result.messages
	local ordered = __TS__ArraySort(
		__TS__ArraySlice(messages),
		function(____, a, b)
			local aFailed = a.success ~= true
			local bFailed = b.success ~= true
			if aFailed == bFailed then
				return 0
			end
			return aFailed and -1 or 1
		end
	)
	local shown = math.min(#ordered, AgentConfig.AGENT_LIMITS.historyBuildMaxMessages)
	local sanitized = {}
	do
		local i = 0
		while i < shown do
			local item = ordered[i + 1]
			local next = {}
			for key in pairs(item) do
				local value = item[key]
				next[key] = key == "message" and type(value) == "string" and ____exports.truncateText(value, AgentConfig.AGENT_LIMITS.historyBuildMessageMaxChars) or value
			end
			sanitized[#sanitized + 1] = next
			i = i + 1
		end
	end
	clone.messages = sanitized
	if #ordered > shown then
		clone.truncatedMessages = #ordered - shown
	end
	return clone
end
function ____exports.sanitizeActionParamsForHistory(tool, params)
	if tool ~= "edit_file" then
		return params
	end
	local clone = {}
	for key in pairs(params) do
		if key == "old_str" then
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str")
		elseif key == "new_str" then
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str")
		elseif key == "edits" and isArray(params[key]) then
			clone.edits = __TS__ArrayMap(
				params[key],
				function(____, item)
					if not isRecord(item) or isArray(item) then
						return {invalid = true}
					end
					return {
						path = item.path,
						old_str_stats = summarizeEditTextParamForHistory(item.old_str, "old_str"),
						new_str_stats = summarizeEditTextParamForHistory(item.new_str, "new_str")
					}
				end
			)
		else
			clone[key] = params[key]
		end
	end
	return clone
end
local function projectEditResultForLLM(result)
	if result.success ~= true then
		local failed = {}
		for key in pairs(result) do
			local value = result[key]
			failed[key] = type(value) == "string" and truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, key) or value
		end
		return failed
	end
	local projected = {}
	local scalarKeys = {
		"success",
		"changed",
		"mode",
		"checkpointId",
		"checkpointSeq",
		"checkpointed",
		"reversible",
		"binary",
		"actualSaved",
		"actualSavedCharacters",
		"currentFileExists",
		"currentCharacters",
		"currentState"
	}
	do
		local i = 0
		while i < #scalarKeys do
			local key = scalarKeys[i + 1]
			if result[key] ~= nil then
				projected[key] = result[key]
			end
			i = i + 1
		end
	end
	if isArray(result.files) then
		projected.files = result.files
	end
	if type(result.message) == "string" then
		projected.message = truncateHistoryText(result.message, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "message")
	end
	if type(result.guidance) == "string" then
		projected.guidance = truncateHistoryText(result.guidance, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "guidance")
	end
	if isArray(result.fileContext) then
		local summaries = {}
		do
			local i = 0
			while i < #result.fileContext do
				do
					local item = result.fileContext[i + 1]
					if not isRecord(item) or isArray(item) then
						goto __continue87
					end
					local summary = {}
					local keys = {
						"path",
						"op",
						"beforeExists",
						"afterExists",
						"beforeBytes",
						"afterBytes",
						"lineCount",
						"contentTruncated",
						"fileListTruncated"
					}
					do
						local j = 0
						while j < #keys do
							local key = keys[j + 1]
							if item[key] ~= nil then
								summary[key] = item[key]
							end
							j = j + 1
						end
					end
					summaries[#summaries + 1] = summary
				end
				::__continue87::
				i = i + 1
			end
		end
		if #summaries > 0 then
			projected.fileSummary = summaries
		end
	end
	if type(result.truncatedFileContextItems) == "number" then
		projected.truncatedFileContextItems = result.truncatedFileContextItems
	end
	projected.contextNote = "Full file content and diff are omitted from LLM history. Use read_file when exact current content is needed."
	return projected
end
local function projectOneBuildResultForLLM(result)
	if not isArray(result.messages) then
		return result
	end
	local projected = {}
	for key in pairs(result) do
		if key ~= "messages" then
			projected[key] = result[key]
		end
	end
	local maxMessages = AgentConfig.AGENT_LIMITS.llmHistoryBuildMaxMessages
	local shown = math.min(#result.messages, maxMessages)
	projected.messages = __TS__ArraySlice(result.messages, 0, shown)
	if #result.messages > shown then
		projected.llmHistoryTruncatedMessages = #result.messages - shown
	end
	return projected
end
local function projectBuildResultForLLM(result)
	if type(result.code) == "string" or result.failureKind == "tool" then
		return ____exports.projectBuildResultForModel(result)
	end
	if not isArray(result.results) then
		return projectOneBuildResultForLLM(result)
	end
	local projected = {}
	for key in pairs(result) do
		if key ~= "results" then
			projected[key] = result[key]
		end
	end
	projected.results = __TS__ArrayMap(
		result.results,
		function(____, item) return isRecord(item) and not isArray(item) and projectOneBuildResultForLLM(item) or item end
	)
	return projected
end
local function projectCommandResultForLLM(result)
	local projected = {}
	for key in pairs(result) do
		local value = result[key]
		if key == "output" and type(value) == "string" then
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command output")
		elseif key == "message" and type(value) == "string" then
			projected[key] = truncateHistoryText(value, AgentConfig.AGENT_LIMITS.llmHistoryCommandOutputMaxChars, "command message")
		else
			projected[key] = value
		end
	end
	return projected
end
local function sanitizeVisionActionParamsForCompression(params)
	local projected = {}
	if type(params.question) == "string" then
		projected.question = params.question
	end
	if type(params.criteria) == "string" then
		projected.criteria = params.criteria
	end
	if isArray(params.paths) then
		projected.imageCount = #params.paths
	end
	return projected
end
local function projectVisionResultForCompression(content)
	local decoded = AgentUtils.safeJsonDecode(content)
	if not isRecord(decoded) or isArray(decoded) then
		return truncateHistoryText(content, AgentConfig.AGENT_LIMITS.compressionVisionReportMaxChars, "vision result")
	end
	local projected = {}
	if decoded.success ~= nil then
		projected.success = decoded.success
	end
	if type(decoded.report) == "string" then
		projected.report = truncateHistoryText(decoded.report, AgentConfig.AGENT_LIMITS.compressionVisionReportMaxChars, "vision report")
	end
	if type(decoded.message) == "string" then
		projected.message = truncateHistoryText(decoded.message, AgentConfig.AGENT_LIMITS.llmHistoryEditResultMessageMaxChars, "vision message")
	end
	if decoded.cancelled ~= nil then
		projected.cancelled = decoded.cancelled
	end
	return ____exports.toJson(projected, false)
end
local function projectToolResultContentForLLM(tool, content)
	local decoded = AgentUtils.safeJsonDecode(content)
	if not isRecord(decoded) or isArray(decoded) then
		return truncateHistoryText(content, AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars, tool .. " result")
	end
	local projected = decoded
	if tool == "edit_file" then
		projected = projectEditResultForLLM(decoded)
	elseif tool == "build" then
		projected = projectBuildResultForLLM(decoded)
	elseif tool == "execute_command" then
		projected = projectCommandResultForLLM(decoded)
	end
	local encoded = ____exports.toJson(projected, false)
	if tool == "read_file" then
		return encoded
	end
	if #encoded <= AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars then
		return encoded
	end
	local fallback = {
		success = projected.success,
		llmHistoryTruncated = true,
		originalChars = #encoded,
		preview = truncateHistoryText(
			encoded,
			math.floor(AgentConfig.AGENT_LIMITS.llmHistoryToolResultMaxChars * 0.45),
			tool .. " result"
		)
	}
	return ____exports.toJson(fallback, false)
end
local TRIM_RECENT_ASSISTANT_TURNS = 2
local TRIM_STUB_HEAD_CHARS = 140
local TRIM_RESULT_KEEP_CHARS = 200
local function elidedStub(kind, original)
	return ____exports.toJson(
		{
			[kind] = tostring(#original) .. " chars elided from LLM history",
			head = utf8TakeHead(original, TRIM_STUB_HEAD_CHARS)
		},
		false
	)
end
local function lastReadIndexByPath(messages)
	local last = {}
	do
		local i = 0
		while i < #messages do
			do
				local message = messages[i + 1]
				if message.role ~= "tool" or message.name ~= "read_file" or type(message.content) ~= "string" then
					goto __continue133
				end
				local decoded = AgentUtils.safeJsonDecode(message.content)
				if not isRecord(decoded) or not isArray(decoded.results) then
					goto __continue133
				end
				do
					local j = 0
					while j < #decoded.results do
						local entry = decoded.results[j + 1]
						if isRecord(entry) and type(entry.path) == "string" then
							last[entry.path] = i
						end
						j = j + 1
					end
				end
			end
			::__continue133::
			i = i + 1
		end
	end
	return last
end
local function readPathsOf(content)
	local decoded = AgentUtils.safeJsonDecode(content)
	if not isRecord(decoded) or not isArray(decoded.results) then
		return {}
	end
	local paths = {}
	do
		local j = 0
		while j < #decoded.results do
			local entry = decoded.results[j + 1]
			if isRecord(entry) and type(entry.path) == "string" then
				paths[#paths + 1] = entry.path
			end
			j = j + 1
		end
	end
	return paths
end
local TRIM_TIGHT_PAYLOAD_FRACTION = 0.6
local function rawMessageChars(messages)
	local total = 0
	do
		local i = 0
		while i < #messages do
			local message = messages[i + 1]
			if type(message.content) == "string" then
				total = total + #message.content
			end
			if type(message.reasoning_content) == "string" then
				total = total + #message.reasoning_content
			end
			if message.tool_calls then
				do
					local j = 0
					while j < #message.tool_calls do
						local fn = message.tool_calls[j + 1]["function"]
						if fn ~= nil and type(fn.arguments) == "string" then
							total = total + #fn.arguments
						end
						j = j + 1
					end
				end
			end
			i = i + 1
		end
	end
	return total
end
function ____exports.projectMessagesForLLMContext(messages, charBudget)
	local tight = not (type(charBudget) == "number" and charBudget > 0) or rawMessageChars(messages) > charBudget * TRIM_TIGHT_PAYLOAD_FRACTION
	local lastReadByPath = lastReadIndexByPath(messages)
	local recentAssistant = {}
	local seenFromEnd = 0
	do
		local i = #messages - 1
		while i >= 0 do
			do
				if messages[i + 1].role ~= "assistant" then
					goto __continue155
				end
				seenFromEnd = seenFromEnd + 1
				if seenFromEnd <= TRIM_RECENT_ASSISTANT_TURNS then
					recentAssistant[i] = true
				end
			end
			::__continue155::
			i = i - 1
		end
	end
	local projected = {}
	do
		local i = 0
		while i < #messages do
			local message = messages[i + 1]
			local next = __TS__ObjectAssign({}, message)
			if message.role == "assistant" then
				if not message.tool_calls or #message.tool_calls == 0 then
					next.reasoning_content = nil
				elseif message.reasoning_content and recentAssistant[i] ~= true and tight then
					next.reasoning_content = nil
				end
				if tight and message.tool_calls and #message.tool_calls > 0 and recentAssistant[i] ~= true then
					next.tool_calls = __TS__ArrayMap(
						message.tool_calls,
						function(____, toolCall)
							local fn = toolCall["function"]
							if fn == nil then
								return toolCall
							end
							if fn.name ~= "edit_file" and fn.name ~= "write_file" then
								return toolCall
							end
							if type(fn.arguments) ~= "string" then
								return toolCall
							end
							if #fn.arguments <= TRIM_RESULT_KEEP_CHARS or (string.find(fn.arguments, "argsElided", nil, true) or 0) - 1 >= 0 then
								return toolCall
							end
							return __TS__ObjectAssign(
								{},
								toolCall,
								{["function"] = __TS__ObjectAssign(
									{},
									fn,
									{arguments = elidedStub("argsElided", fn.arguments)}
								)}
							)
						end
					)
				end
			end
			if message.role == "tool" and type(message.content) == "string" then
				local content = projectToolResultContentForLLM(message.name or "tool", message.content)
				if message.name == "read_file" and #content > TRIM_RESULT_KEEP_CHARS then
					local paths = readPathsOf(content)
					local anyFresh = false
					do
						local j = 0
						while j < #paths do
							if lastReadByPath[paths[j + 1]] == i then
								anyFresh = true
							end
							j = j + 1
						end
					end
					if #paths > 0 and not anyFresh then
						content = elidedStub("supersededRead", content)
					end
				end
				if (message.name == "write_file" or message.name == "edit_file") and #content > TRIM_RESULT_KEEP_CHARS then
					content = elidedStub("savedResultElided", content)
				end
				next.content = content
			end
			projected[#projected + 1] = next
			i = i + 1
		end
	end
	return projected
end
function ____exports.projectMessagesForCompression(messages)
	local projected = ____exports.projectMessagesForLLMContext(messages)
	local visionCallIds = {}
	do
		local i = 0
		while i < #projected do
			do
				local message = projected[i + 1]
				if message.role == "tool" and type(message.content) == "string" and (message.name == "analyze_image" or type(message.tool_call_id) == "string" and visionCallIds[message.tool_call_id] == true) then
					local ____opt_0 = messages[i + 1]
					local rawOriginalContent = ____opt_0 and ____opt_0.content
					local originalContent = type(rawOriginalContent) == "string" and rawOriginalContent or message.content
					projected[i + 1] = __TS__ObjectAssign(
						{},
						message,
						{content = projectVisionResultForCompression(originalContent)}
					)
					goto __continue178
				end
				if message.role ~= "assistant" or not message.tool_calls or #message.tool_calls == 0 then
					goto __continue178
				end
				local changed = false
				local toolCalls = __TS__ArrayMap(
					message.tool_calls,
					function(____, toolCall)
						local fn = toolCall["function"]
						if (fn and fn.name) == "analyze_image" and type(toolCall.id) == "string" and toolCall.id ~= "" then
							visionCallIds[toolCall.id] = true
						end
						if (fn and fn.name) ~= "edit_file" and (fn and fn.name) ~= "analyze_image" or type(fn.arguments) ~= "string" then
							return toolCall
						end
						local decoded = AgentUtils.safeJsonDecode(fn.arguments)
						if not isRecord(decoded) or isArray(decoded) then
							return toolCall
						end
						changed = true
						return __TS__ObjectAssign(
							{},
							toolCall,
							{["function"] = __TS__ObjectAssign(
								{},
								fn,
								{arguments = ____exports.toJson(
									fn.name == "analyze_image" and sanitizeVisionActionParamsForCompression(decoded) or ____exports.sanitizeActionParamsForHistory("edit_file", decoded),
									false
								)}
							)}
						)
					end
				)
				if changed then
					projected[i + 1] = __TS__ObjectAssign({}, message, {tool_calls = toolCalls})
				end
			end
			::__continue178::
			i = i + 1
		end
	end
	return projected
end
function ____exports.sanitizeMessagesForLLMInput(messages)
	local sanitized = {}
	local droppedAssistantToolCalls = 0
	local droppedToolResults = 0
	do
		local i = 0
		while i < #messages do
			do
				local message = messages[i + 1]
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then
					local requiredIds = {}
					do
						local j = 0
						while j < #message.tool_calls do
							local toolCall = message.tool_calls[j + 1]
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or ""
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then
								requiredIds[#requiredIds + 1] = id
							end
							j = j + 1
						end
					end
					if #requiredIds == 0 then
						sanitized[#sanitized + 1] = message
						goto __continue188
					end
					local matchedIds = {}
					local matchedTools = {}
					local j = i + 1
					while j < #messages do
						local toolMessage = messages[j + 1]
						if toolMessage.role ~= "tool" then
							break
						end
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or ""
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then
							matchedIds[toolCallId] = true
							matchedTools[#matchedTools + 1] = toolMessage
						else
							droppedToolResults = droppedToolResults + 1
						end
						j = j + 1
					end
					local complete = true
					do
						local j = 0
						while j < #requiredIds do
							if matchedIds[requiredIds[j + 1]] ~= true then
								complete = false
								break
							end
							j = j + 1
						end
					end
					if complete then
						__TS__ArrayPush(
							sanitized,
							message,
							table.unpack(matchedTools)
						)
					else
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1
						droppedToolResults = droppedToolResults + #matchedTools
					end
					i = j - 1
					goto __continue188
				end
				if message.role == "tool" then
					droppedToolResults = droppedToolResults + 1
					goto __continue188
				end
				sanitized[#sanitized + 1] = message
			end
			::__continue188::
			i = i + 1
		end
	end
	return sanitized
end
return ____exports
