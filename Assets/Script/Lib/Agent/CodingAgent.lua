-- [ts]: CodingAgent.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringReplace = ____lualib.__TS__StringReplace -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local json = ____Dora.json -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local Content = ____Dora.Content -- 2
local wait = ____Dora.wait -- 2
local emit = ____Dora.emit -- 2
local ____flow = require("Agent.flow") -- 3
local Flow = ____flow.Flow -- 3
local Node = ____flow.Node -- 3
local ____Utils = require("Agent.Utils") -- 4
local callLLMStream = ____Utils.callLLMStream -- 4
local callLLM = ____Utils.callLLM -- 4
local Log = ____Utils.Log -- 4
local Tools = require("Agent.Tools") -- 5
local yaml = require("yaml") -- 6
local ____Memory = require("Agent.Memory") -- 7
local MemoryCompressor = ____Memory.MemoryCompressor -- 7
local HISTORY_READ_FILE_MAX_CHARS = 12000 -- 49
local HISTORY_READ_FILE_MAX_LINES = 300 -- 50
local function getCancelledReason(shared) -- 94
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 94
		return shared.stopToken.reason -- 95
	end -- 95
	return shared.useChineseResponse and "已取消" or "cancelled" -- 96
end -- 94
local function toJson(value) -- 99
	local text, err = json.encode(value) -- 100
	if text ~= nil then -- 100
		return text -- 101
	end -- 101
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 102
end -- 99
local function truncateText(text, maxLen) -- 105
	if #text <= maxLen then -- 105
		return text -- 106
	end -- 106
	local pos = utf8.offset(text, maxLen) -- 107
	return __TS__StringSlice(text, 0, pos) .. "..." -- 108
end -- 105
local function summarizeUnknown(value, maxLen) -- 111
	if maxLen == nil then -- 111
		maxLen = 320 -- 111
	end -- 111
	if value == nil then -- 111
		return "undefined" -- 112
	end -- 112
	if value == nil then -- 112
		return "null" -- 113
	end -- 113
	if type(value) == "string" then -- 113
		return __TS__StringReplace( -- 115
			truncateText(value, maxLen), -- 115
			"\n", -- 115
			"\\n" -- 115
		) -- 115
	end -- 115
	if type(value) == "number" or type(value) == "boolean" then -- 115
		return tostring(value) -- 118
	end -- 118
	return __TS__StringReplace( -- 120
		truncateText( -- 120
			toJson(value), -- 120
			maxLen -- 120
		), -- 120
		"\n", -- 120
		"\\n" -- 120
	) -- 120
end -- 111
local function getReplyLanguageDirective(shared) -- 123
	return shared.useChineseResponse and "Use Simplified Chinese for natural-language fields (reason/message/summary)." or "Use English for natural-language fields (reason/message/summary)." -- 124
end -- 123
local function limitReadContentForHistory(content, tool) -- 129
	local lines = __TS__StringSplit(content, "\n") -- 130
	local overLineLimit = #lines > HISTORY_READ_FILE_MAX_LINES -- 131
	local limitedByLines = overLineLimit and table.concat( -- 132
		__TS__ArraySlice(lines, 0, HISTORY_READ_FILE_MAX_LINES), -- 133
		"\n" -- 133
	) or content -- 133
	if #limitedByLines <= HISTORY_READ_FILE_MAX_CHARS and not overLineLimit then -- 133
		return content -- 136
	end -- 136
	local limited = #limitedByLines > HISTORY_READ_FILE_MAX_CHARS and __TS__StringSlice(limitedByLines, 0, HISTORY_READ_FILE_MAX_CHARS) or limitedByLines -- 138
	local reasons = {} -- 141
	if #content > HISTORY_READ_FILE_MAX_CHARS then -- 141
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 142
	end -- 142
	if #lines > HISTORY_READ_FILE_MAX_LINES then -- 142
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 143
	end -- 143
	local hint = tool == "read_file" and "Use read_file_range for the exact section you need." or "Narrow the requested line range." -- 144
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 147
end -- 129
local function summarizeEditTextParamForHistory(value, key) -- 150
	if type(value) ~= "string" then -- 150
		return nil -- 151
	end -- 151
	local text = value -- 152
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 153
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 154
end -- 150
local function sanitizeReadResultForHistory(tool, result) -- 162
	if tool ~= "read_file" and tool ~= "read_file_range" or result.success ~= true or type(result.content) ~= "string" then -- 162
		return result -- 164
	end -- 164
	local clone = {} -- 166
	for key in pairs(result) do -- 167
		clone[key] = result[key] -- 168
	end -- 168
	clone.content = limitReadContentForHistory(result.content, tool) -- 170
	return clone -- 171
end -- 162
local function sanitizeActionParamsForHistory(tool, params) -- 174
	if tool ~= "edit_file" then -- 174
		return params -- 175
	end -- 175
	local clone = {} -- 176
	for key in pairs(params) do -- 177
		if key == "old_str" then -- 177
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 179
		elseif key == "new_str" then -- 179
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 181
		else -- 181
			clone[key] = params[key] -- 183
		end -- 183
	end -- 183
	return clone -- 186
end -- 174
local function isKnownToolName(name) -- 189
	return name == "read_file" or name == "read_file_range" or name == "edit_file" or name == "delete_file" or name == "search_files" or name == "search_dora_api" or name == "list_files" or name == "run_ts_build" or name == "finish" -- 190
end -- 189
local function formatHistorySummary(history) -- 201
	if #history == 0 then -- 201
		return "No previous actions." -- 203
	end -- 203
	local actions = history -- 205
	local lines = {} -- 206
	lines[#lines + 1] = "" -- 207
	do -- 207
		local i = 0 -- 208
		while i < #actions do -- 208
			local action = actions[i + 1] -- 209
			lines[#lines + 1] = ("Action " .. tostring(i + 1)) .. ":" -- 210
			lines[#lines + 1] = "- Tool: " .. action.tool -- 211
			lines[#lines + 1] = "- Reason: " .. action.reason -- 212
			if action.params and type(action.params) == "table" and ({next(action.params)}) ~= nil then -- 212
				lines[#lines + 1] = "- Parameters:" -- 214
				for key in pairs(action.params) do -- 215
					lines[#lines + 1] = (("  - " .. key) .. ": ") .. summarizeUnknown(action.params[key], 2000) -- 216
				end -- 216
			end -- 216
			if action.result and type(action.result) == "table" then -- 216
				local result = action.result -- 220
				local success = result.success == true -- 221
				lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 222
				if action.tool == "read_file" or action.tool == "read_file_range" then -- 222
					if success and type(result.content) == "string" then -- 222
						lines[#lines + 1] = "- Content: " .. limitReadContentForHistory(result.content, action.tool) -- 225
					end -- 225
				elseif action.tool == "search_files" then -- 225
					if success and type(result.results) == "table" then -- 225
						local matches = result.results -- 229
						lines[#lines + 1] = "- Matches: " .. tostring(#matches) -- 230
						do -- 230
							local j = 0 -- 231
							while j < #matches do -- 231
								local m = matches[j + 1] -- 232
								local file = type(m.file) == "string" and m.file or "" -- 233
								local line = m.line ~= nil and tostring(m.line) or "" -- 234
								local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 235
								lines[#lines + 1] = ((((("  " .. tostring(j + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 236
								j = j + 1 -- 231
							end -- 231
						end -- 231
					end -- 231
				elseif action.tool == "search_dora_api" then -- 231
					if success and type(result.results) == "table" then -- 231
						local hits = result.results -- 241
						lines[#lines + 1] = "- Matches: " .. tostring(#hits) -- 242
						do -- 242
							local j = 0 -- 243
							while j < #hits do -- 243
								local m = hits[j + 1] -- 244
								local file = type(m.file) == "string" and m.file or "" -- 245
								local line = m.line ~= nil and tostring(m.line) or "" -- 246
								local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 247
								lines[#lines + 1] = ((((("  " .. tostring(j + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 248
								j = j + 1 -- 243
							end -- 243
						end -- 243
					end -- 243
				elseif action.tool == "edit_file" then -- 243
					if success then -- 243
						if result.mode ~= nil then -- 243
							lines[#lines + 1] = "- Mode: " .. tostring(result.mode) -- 254
						end -- 254
						if result.replaced ~= nil then -- 254
							lines[#lines + 1] = "- Replaced: " .. tostring(result.replaced) -- 257
						end -- 257
					end -- 257
				elseif action.tool == "list_files" then -- 257
					if success and type(result.files) == "table" then -- 257
						local files = result.files -- 262
						lines[#lines + 1] = "- Directory structure:" -- 263
						if #files > 0 then -- 263
							do -- 263
								local j = 0 -- 265
								while j < #files do -- 265
									lines[#lines + 1] = "  " .. files[j + 1] -- 266
									j = j + 1 -- 265
								end -- 265
							end -- 265
						else -- 265
							lines[#lines + 1] = "  (Empty or inaccessible directory)" -- 269
						end -- 269
					end -- 269
				else -- 269
					lines[#lines + 1] = "- Detail: " .. truncateText( -- 273
						toJson(result), -- 273
						4000 -- 273
					) -- 273
				end -- 273
			elseif action.result ~= nil then -- 273
				lines[#lines + 1] = "- Result: " .. summarizeUnknown(action.result, 3000) -- 276
			else -- 276
				lines[#lines + 1] = "- Result: pending" -- 278
			end -- 278
			if i < #actions - 1 then -- 278
				lines[#lines + 1] = "" -- 280
			end -- 280
			i = i + 1 -- 208
		end -- 208
	end -- 208
	return table.concat(lines, "\n") -- 282
end -- 201
local function extractYAMLFromText(text) -- 285
	local source = __TS__StringTrim(text) -- 286
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 287
	if yamlFencePos >= 0 then -- 287
		local from = yamlFencePos + #"```yaml" -- 289
		local ____end = (string.find( -- 290
			source, -- 290
			"```", -- 290
			math.max(from + 1, 1), -- 290
			true -- 290
		) or 0) - 1 -- 290
		if ____end > from then -- 290
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 291
		end -- 291
	end -- 291
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 293
	if ymlFencePos >= 0 then -- 293
		local from = ymlFencePos + #"```yml" -- 295
		local ____end = (string.find( -- 296
			source, -- 296
			"```", -- 296
			math.max(from + 1, 1), -- 296
			true -- 296
		) or 0) - 1 -- 296
		if ____end > from then -- 296
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 297
		end -- 297
	end -- 297
	local fencePos = (string.find(source, "```", nil, true) or 0) - 1 -- 299
	if fencePos >= 0 then -- 299
		local firstLineEnd = (string.find( -- 301
			source, -- 301
			"\n", -- 301
			math.max(fencePos + 1, 1), -- 301
			true -- 301
		) or 0) - 1 -- 301
		local ____end = (string.find( -- 302
			source, -- 302
			"```", -- 302
			math.max((firstLineEnd >= 0 and firstLineEnd + 1 or fencePos + 3) + 1, 1), -- 302
			true -- 302
		) or 0) - 1 -- 302
		if firstLineEnd >= 0 and ____end > firstLineEnd then -- 302
			return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, ____end)) -- 304
		end -- 304
	end -- 304
	return source -- 307
end -- 285
local function parseYAMLObjectFromText(text) -- 310
	local yamlText = extractYAMLFromText(text) -- 311
	local obj, err = yaml.parse(yamlText) -- 312
	if obj == nil or type(obj) ~= "table" then -- 312
		return { -- 314
			success = false, -- 314
			message = "invalid yaml: " .. tostring(err) -- 314
		} -- 314
	end -- 314
	return {success = true, obj = obj} -- 316
end -- 310
local function llm(shared, messages) -- 328
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 328
		local res = __TS__Await(callLLM(messages, shared.llmOptions, shared.stopToken)) -- 329
		if res.success then -- 329
			local ____opt_4 = res.response.choices -- 329
			local ____opt_2 = ____opt_4 and ____opt_4[1] -- 329
			local ____opt_0 = ____opt_2 and ____opt_2.message -- 329
			local text = ____opt_0 and ____opt_0.content -- 331
			if text then -- 331
				return ____awaiter_resolve(nil, {success = true, text = text}) -- 331
			else -- 331
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 331
			end -- 331
		else -- 331
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 331
		end -- 331
	end) -- 331
end -- 328
local function llmStream(shared, messages) -- 342
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 342
		local text = "" -- 343
		local cancelledReason -- 344
		local done = false -- 345
		if shared.stopToken.stopped then -- 345
			return ____awaiter_resolve( -- 345
				nil, -- 345
				{ -- 348
					success = false, -- 348
					message = getCancelledReason(shared), -- 348
					text = text -- 348
				} -- 348
			) -- 348
		end -- 348
		done = false -- 350
		cancelledReason = nil -- 351
		text = "" -- 352
		callLLMStream( -- 353
			messages, -- 354
			shared.llmOptions, -- 355
			{ -- 356
				id = nil, -- 357
				onData = function(data) -- 358
					if shared.stopToken.stopped then -- 358
						return true -- 359
					end -- 359
					local choice = data.choices and data.choices[1] -- 360
					local delta = choice and choice.delta -- 361
					if delta and type(delta.content) == "string" then -- 361
						local content = delta.content -- 363
						text = text .. content -- 364
						local res = json.encode({name = "LLMStream", content = content}) -- 365
						if res ~= nil then -- 365
							emit("AppWS", "Send", res) -- 367
						end -- 367
					end -- 367
					return false -- 370
				end, -- 358
				onCancel = function(reason) -- 372
					cancelledReason = reason -- 373
					done = true -- 374
				end, -- 372
				onDone = function() -- 376
					done = true -- 377
				end -- 376
			} -- 376
		) -- 376
		__TS__Await(__TS__New( -- 382
			__TS__Promise, -- 382
			function(____, resolve) -- 382
				Director.systemScheduler:schedule(once(function() -- 383
					wait(function() return done end) -- 384
					resolve(nil) -- 385
				end)) -- 383
			end -- 382
		)) -- 382
		if shared.stopToken.stopped then -- 382
			cancelledReason = getCancelledReason(shared) -- 389
		end -- 389
		if not cancelledReason and text == "" then -- 389
			cancelledReason = "empty LLM output" -- 393
		end -- 393
		if cancelledReason then -- 393
			return ____awaiter_resolve(nil, {success = false, message = cancelledReason, text = text}) -- 393
		end -- 393
		return ____awaiter_resolve(nil, {success = true, text = text}) -- 393
	end) -- 393
end -- 342
local function parseDecisionObject(rawObj) -- 400
	if type(rawObj.tool) ~= "string" then -- 400
		return {success = false, message = "missing tool"} -- 401
	end -- 401
	local tool = rawObj.tool -- 402
	if not isKnownToolName(tool) then -- 402
		return {success = false, message = "unknown tool: " .. tool} -- 404
	end -- 404
	local reason = type(rawObj.reason) == "string" and rawObj.reason or "" -- 406
	local params = type(rawObj.params) == "table" and rawObj.params or ({}) -- 407
	return {success = true, tool = tool, reason = reason, params = params} -- 408
end -- 400
local function buildDecisionToolSchema() -- 411
	return {{type = "function", ["function"] = {name = "next_step", description = "Choose the next coding action for the agent.", parameters = {type = "object", properties = {tool = {type = "string", enum = { -- 412
		"read_file", -- 423
		"read_file_range", -- 424
		"edit_file", -- 425
		"delete_file", -- 426
		"search_files", -- 427
		"search_dora_api", -- 428
		"list_files", -- 429
		"run_ts_build", -- 430
		"finish" -- 431
	}}, reason = {type = "string", description = "Explain why this is the next best action."}, params = {type = "object", description = "Shallow parameter object for the selected tool.", properties = { -- 431
		path = {type = "string"}, -- 442
		target_file = {type = "string"}, -- 443
		old_str = {type = "string"}, -- 444
		new_str = {type = "string"}, -- 445
		pattern = {type = "string"}, -- 446
		globs = {type = "array", items = {type = "string"}}, -- 447
		useRegex = {type = "boolean"}, -- 451
		caseSensitive = {type = "boolean"}, -- 452
		includeContent = {type = "boolean"}, -- 453
		contentWindow = {type = "number"}, -- 454
		programmingLanguage = {type = "string", enum = { -- 455
			"ts", -- 457
			"tsx", -- 457
			"lua", -- 457
			"yue", -- 457
			"teal" -- 457
		}}, -- 457
		topK = {type = "number"}, -- 459
		startLine = {type = "number"}, -- 460
		endLine = {type = "number"} -- 461
	}}}, required = {"tool", "reason", "params"}}}}} -- 461
end -- 411
local function buildDecisionPrompt(shared, userQuery, historyText, memoryContext) -- 471
	return (((((("You are a coding assistant that helps modify and navigate code.\nGiven the request and action history, decide which tool to use next.\n\n" .. memoryContext) .. "\n\nUser request: ") .. userQuery) .. "\n\nHere are the actions you performed:\n") .. historyText) .. "\n\nAvailable tools:\n1. read_file: Read content from a file\n\t- Parameters: path (workspace-relative)\n1b. read_file_range: Read specific line range from a file\n\t- Parameters: path, startLine, endLine\n\n2. edit_file: Make changes to a file\n\t- Parameters: path, old_str, new_str\n\t\t- Rules:\n\t\t\t- old_str and new_str MUST be different\n\t\t\t- old_str must match existing text exactly when it is non-empty\n\t\t\t- If file doesn't exist, set old_str to empty string to create it with new_str\n\n3. delete_file: Remove a file\n\t- Parameters: target_file\n\n4. search_files: Search patterns in workspace files\n\t- Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional)\n\n5. list_files: List files under a directory\n\t- Parameters: path, globs(optional)\n\n6. search_dora_api: Search Dora SSR game engine API docs\n\t- Parameters: pattern, programmingLanguage(ts/tsx/lua/yue/teal), topK(optional)\n\n7. run_ts_build: Run TS transpile/build checks\n\t- Parameters: path(optional)\n\n8. finish: End and summarize\n\t- Parameters: {}\n\nDecision rules:\n- Choose exactly one next action.\n- Keep params shallow and valid for the selected tool.\n- Prefer reading/searching before editing when information is missing.\n- Use finish only when no more actions are needed.\n") .. getReplyLanguageDirective(shared) -- 472
end -- 471
local function replaceAllAndCount(text, oldStr, newStr) -- 521
	if oldStr == "" then -- 521
		return {content = text, replaced = 0} -- 522
	end -- 522
	local count = 0 -- 523
	local from = 0 -- 524
	while true do -- 524
		local idx = (string.find( -- 526
			text, -- 526
			oldStr, -- 526
			math.max(from + 1, 1), -- 526
			true -- 526
		) or 0) - 1 -- 526
		if idx < 0 then -- 526
			break -- 527
		end -- 527
		count = count + 1 -- 528
		from = idx + #oldStr -- 529
	end -- 529
	if count == 0 then -- 529
		return {content = text, replaced = 0} -- 531
	end -- 531
	return { -- 532
		content = table.concat( -- 533
			__TS__StringSplit(text, oldStr), -- 533
			newStr or "," -- 533
		), -- 533
		replaced = count -- 534
	} -- 534
end -- 521
local MainDecisionAgent = __TS__Class() -- 538
MainDecisionAgent.name = "MainDecisionAgent" -- 538
__TS__ClassExtends(MainDecisionAgent, Node) -- 538
function MainDecisionAgent.prototype.prep(self, shared) -- 539
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 539
		local ____shared_6 = shared -- 540
		local userQuery = ____shared_6.userQuery -- 540
		local history = ____shared_6.history -- 540
		local memory = ____shared_6.memory -- 540
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 540
			return ____awaiter_resolve(nil, {userQuery = shared.userQuery, history = shared.history, shared = shared}) -- 540
		end -- 540
		if not memory.hasCompressedThisTask then -- 540
			local systemPrompt = self:getSystemPrompt() -- 552
			local toolDefs = self:getToolDefinitions() -- 553
			if memory.compressor:shouldCompress( -- 553
				userQuery, -- 556
				history, -- 557
				memory.lastConsolidatedIndex, -- 558
				systemPrompt, -- 559
				toolDefs, -- 560
				formatHistorySummary -- 561
			) then -- 561
				local result = __TS__Await(memory.compressor:compress( -- 564
					history, -- 565
					memory.lastConsolidatedIndex, -- 566
					shared.llmOptions, -- 567
					formatHistorySummary, -- 568
					shared.llmMaxTry, -- 569
					shared.decisionMode -- 570
				)) -- 570
				if result and result.success then -- 570
					memory.lastConsolidatedIndex = memory.lastConsolidatedIndex + result.compressedCount -- 574
					memory.hasCompressedThisTask = true -- 575
					Log( -- 577
						"Info", -- 578
						("[Memory] Compressed " .. tostring(result.compressedCount)) .. " history records" -- 578
					) -- 578
				end -- 578
			end -- 578
		end -- 578
		return ____awaiter_resolve(nil, {userQuery = shared.userQuery, history = shared.history, shared = shared}) -- 578
	end) -- 578
end -- 539
function MainDecisionAgent.prototype.getSystemPrompt(self) -- 592
	return "You are a coding assistant that helps modify and navigate code." -- 593
end -- 592
function MainDecisionAgent.prototype.getToolDefinitions(self) -- 596
	return "Available tools:\n1. read_file: Read content from a file\n1b. read_file_range: Read specific line range from a file\n2. edit_file: Make changes to a file\n3. delete_file: Remove a file\n4. search_files: Search patterns in workspace files\n5. list_files: List files under a directory\n6. search_dora_api: Search Dora SSR game engine API docs\n7. run_ts_build: Run TS transpile/build checks\n8. finish: End and summarize" -- 597
end -- 596
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, prompt, lastError) -- 609
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 609
		if shared.stopToken.stopped then -- 609
			return ____awaiter_resolve( -- 609
				nil, -- 609
				{ -- 615
					success = false, -- 615
					message = getCancelledReason(shared) -- 615
				} -- 615
			) -- 615
		end -- 615
		Log( -- 617
			"Info", -- 617
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 617
		) -- 617
		local tools = buildDecisionToolSchema() -- 618
		local messages = { -- 619
			{ -- 620
				role = "system", -- 621
				content = table.concat( -- 622
					{ -- 622
						"You are a coding assistant that must decide the next action by calling the next_step tool exactly once.", -- 623
						"Do not answer with plain text.", -- 624
						getReplyLanguageDirective(shared) -- 625
					}, -- 625
					"\n" -- 626
				) -- 626
			}, -- 626
			{role = "user", content = lastError and ((prompt .. "\n\nPrevious tool call was invalid (") .. lastError) .. "). Retry with one valid next_step tool call only." or prompt} -- 628
		} -- 628
		local res = __TS__Await(callLLM( -- 635
			messages, -- 635
			__TS__ObjectAssign({}, shared.llmOptions, {tools = tools, tool_choice = {type = "function", ["function"] = {name = "next_step"}}}), -- 635
			shared.stopToken -- 639
		)) -- 639
		if shared.stopToken.stopped then -- 639
			return ____awaiter_resolve( -- 639
				nil, -- 639
				{ -- 641
					success = false, -- 641
					message = getCancelledReason(shared) -- 641
				} -- 641
			) -- 641
		end -- 641
		if not res.success then -- 641
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 644
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 644
		end -- 644
		local choice = res.response.choices and res.response.choices[1] -- 647
		local message = choice and choice.message -- 648
		local toolCalls = message and message.tool_calls -- 649
		local toolCall = toolCalls and toolCalls[1] -- 650
		local fn = toolCall and toolCall["function"] -- 651
		local messageContent = message and type(message.content) == "string" and message.content or nil -- 652
		Log( -- 653
			"Info", -- 653
			(((("[CodingAgent] tool-calling response finish_reason=" .. (choice and choice.finish_reason and choice.finish_reason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0) -- 653
		) -- 653
		if not fn or fn.name ~= "next_step" then -- 653
			Log("Error", "[CodingAgent] missing next_step tool call") -- 655
			return ____awaiter_resolve(nil, {success = false, message = "missing next_step tool call", raw = messageContent}) -- 655
		end -- 655
		local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 662
		Log( -- 663
			"Info", -- 663
			(("[CodingAgent] tool-calling function=" .. fn.name) .. " args_len=") .. tostring(#argsText) -- 663
		) -- 663
		if __TS__StringTrim(argsText) == "" then -- 663
			Log("Error", "[CodingAgent] empty next_step tool arguments") -- 665
			return ____awaiter_resolve(nil, {success = false, message = "empty next_step tool arguments"}) -- 665
		end -- 665
		local rawObj, err = json.decode(argsText) -- 668
		if err ~= nil or rawObj == nil or type(rawObj) ~= "table" then -- 668
			Log( -- 670
				"Error", -- 670
				"[CodingAgent] invalid next_step tool arguments JSON: " .. tostring(err) -- 670
			) -- 670
			return ____awaiter_resolve( -- 670
				nil, -- 670
				{ -- 671
					success = false, -- 672
					message = "invalid next_step tool arguments: " .. tostring(err), -- 673
					raw = argsText -- 674
				} -- 674
			) -- 674
		end -- 674
		local decision = parseDecisionObject(rawObj) -- 677
		if not decision.success then -- 677
			Log("Error", "[CodingAgent] invalid next_step tool arguments schema: " .. decision.message) -- 679
			return ____awaiter_resolve(nil, {success = false, message = decision.message, raw = argsText}) -- 679
		end -- 679
		Log( -- 686
			"Info", -- 686
			(("[CodingAgent] tool-calling selected tool=" .. decision.tool) .. " reason_len=") .. tostring(#decision.reason) -- 686
		) -- 686
		return ____awaiter_resolve(nil, decision) -- 686
	end) -- 686
end -- 609
function MainDecisionAgent.prototype.exec(self, input) -- 690
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 690
		local shared = input.shared -- 691
		if shared.stopToken.stopped then -- 691
			return ____awaiter_resolve( -- 691
				nil, -- 691
				{ -- 693
					success = false, -- 693
					message = getCancelledReason(shared) -- 693
				} -- 693
			) -- 693
		end -- 693
		local memory = shared.memory -- 693
		local memoryContext = memory.compressor:getStorage():getMemoryContext() -- 698
		local uncompressedHistory = __TS__ArraySlice(input.history, memory.lastConsolidatedIndex) -- 703
		local historyText = formatHistorySummary(uncompressedHistory) -- 704
		local prompt = buildDecisionPrompt(input.shared, input.userQuery, historyText, memoryContext) -- 706
		if shared.decisionMode == "tool_calling" then -- 706
			Log( -- 709
				"Info", -- 709
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " history=") .. tostring(#uncompressedHistory) -- 709
			) -- 709
			local lastError = "tool calling validation failed" -- 710
			local lastRaw = "" -- 711
			do -- 711
				local attempt = 0 -- 712
				while attempt < shared.llmMaxTry do -- 712
					Log( -- 713
						"Info", -- 713
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 713
					) -- 713
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, prompt, attempt > 0 and lastError or nil)) -- 714
					if shared.stopToken.stopped then -- 714
						return ____awaiter_resolve( -- 714
							nil, -- 714
							{ -- 720
								success = false, -- 720
								message = getCancelledReason(shared) -- 720
							} -- 720
						) -- 720
					end -- 720
					if decision.success then -- 720
						return ____awaiter_resolve(nil, decision) -- 720
					end -- 720
					lastError = decision.message -- 725
					lastRaw = decision.raw or "" -- 726
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 727
					attempt = attempt + 1 -- 712
				end -- 712
			end -- 712
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 729
			return ____awaiter_resolve( -- 729
				nil, -- 729
				{ -- 730
					success = false, -- 730
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 730
				} -- 730
			) -- 730
		end -- 730
		local yamlPrompt = prompt .. "\n\nRespond with one YAML object:\n```yaml\n'tool: \"edit_file\"\nreason: |-\n\tA readable multi-line explanation is allowed.\n\tKeep indentation consistent.\nparams:\n\tpath: \"relative/path.ts\"\n\told_str: |-\n\t\tfunction oldName() {\n\t\t\tprint(\"old\");\n\t\t}\n\tnew_str: |-\n\t\tfunction newName() {\n\t\t\tprint(\"hello\");\n\t\t}\n```\nStrict YAML formatting rules:\n- Return YAML only, no prose before/after.\n- Use exactly one YAML object with keys: tool, reason, params.\n- Multi-line strings are allowed using block scalars (`|`, `|-`, `>`).\n- If using a block scalar, all content lines must be indented consistently with tabs.\n- For nested multi-line fields (for example params.new_str), indent the block content deeper than the key line using tabs.\n- Keep params shallow and valid for the selected tool.\n- Use tabs for all indentation, never spaces.\nIf no more actions are needed, use tool: finish." -- 733
		local lastError = "yaml validation failed" -- 762
		local lastRaw = "" -- 763
		do -- 763
			local attempt = 0 -- 764
			while attempt < shared.llmMaxTry do -- 764
				do -- 764
					local feedback = attempt > 0 and ("\n\nPrevious response was invalid (" .. lastError) .. "). Return exactly one valid YAML object only and keep YAML indentation strictly consistent." or "" -- 765
					local messages = {{role = "user", content = yamlPrompt .. feedback}} -- 768
					local llmRes = __TS__Await(llm(shared, messages)) -- 769
					if shared.stopToken.stopped then -- 769
						return ____awaiter_resolve( -- 769
							nil, -- 769
							{ -- 771
								success = false, -- 771
								message = getCancelledReason(shared) -- 771
							} -- 771
						) -- 771
					end -- 771
					if not llmRes.success then -- 771
						lastError = llmRes.message -- 774
						goto __continue125 -- 775
					end -- 775
					lastRaw = llmRes.text -- 777
					local parsed = parseYAMLObjectFromText(llmRes.text) -- 778
					if not parsed.success then -- 778
						lastError = parsed.message -- 780
						goto __continue125 -- 781
					end -- 781
					local decision = parseDecisionObject(parsed.obj) -- 783
					if not decision.success then -- 783
						lastError = decision.message -- 785
						goto __continue125 -- 786
					end -- 786
					return ____awaiter_resolve(nil, decision) -- 786
				end -- 786
				::__continue125:: -- 786
				attempt = attempt + 1 -- 764
			end -- 764
		end -- 764
		return ____awaiter_resolve( -- 764
			nil, -- 764
			{ -- 790
				success = false, -- 790
				message = (("cannot produce valid decision yaml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 790
			} -- 790
		) -- 790
	end) -- 790
end -- 690
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 793
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 793
		local result = execRes -- 794
		if not result.success then -- 794
			shared.error = result.message -- 796
			return ____awaiter_resolve(nil, "error") -- 796
		end -- 796
		shared.lastDecision = {tool = result.tool, reason = result.reason, params = result.params} -- 799
		local ____shared_history_7 = shared.history -- 799
		____shared_history_7[#____shared_history_7 + 1] = { -- 804
			step = shared.step + 1, -- 805
			tool = result.tool, -- 806
			reason = result.reason, -- 807
			params = result.params, -- 808
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 809
		} -- 809
		return ____awaiter_resolve(nil, result.tool) -- 809
	end) -- 809
end -- 793
local ReadFileAction = __TS__Class() -- 815
ReadFileAction.name = "ReadFileAction" -- 815
__TS__ClassExtends(ReadFileAction, Node) -- 815
function ReadFileAction.prototype.prep(self, shared) -- 816
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 816
		local last = shared.history[#shared.history] -- 817
		if not last then -- 817
			error( -- 818
				__TS__New(Error, "no history"), -- 818
				0 -- 818
			) -- 818
		end -- 818
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 819
		if __TS__StringTrim(path) == "" then -- 819
			error( -- 822
				__TS__New(Error, "missing path"), -- 822
				0 -- 822
			) -- 822
		end -- 822
		if last.tool == "read_file_range" then -- 822
			local ____path_12 = path -- 825
			local ____last_tool_13 = last.tool -- 826
			local ____shared_workingDir_14 = shared.workingDir -- 827
			local ____last_params_startLine_8 = last.params.startLine -- 829
			if ____last_params_startLine_8 == nil then -- 829
				____last_params_startLine_8 = 1 -- 829
			end -- 829
			local ____TS__Number_result_11 = __TS__Number(____last_params_startLine_8) -- 829
			local ____last_params_endLine_9 = last.params.endLine -- 830
			if ____last_params_endLine_9 == nil then -- 830
				____last_params_endLine_9 = last.params.startLine -- 830
			end -- 830
			local ____last_params_endLine_9_10 = ____last_params_endLine_9 -- 830
			if ____last_params_endLine_9_10 == nil then -- 830
				____last_params_endLine_9_10 = 1 -- 830
			end -- 830
			return ____awaiter_resolve( -- 830
				nil, -- 830
				{ -- 824
					path = ____path_12, -- 825
					tool = ____last_tool_13, -- 826
					workDir = ____shared_workingDir_14, -- 827
					range = { -- 828
						startLine = ____TS__Number_result_11, -- 829
						endLine = __TS__Number(____last_params_endLine_9_10) -- 830
					} -- 830
				} -- 830
			) -- 830
		end -- 830
		return ____awaiter_resolve(nil, {path = path, tool = "read_file", workDir = shared.workingDir}) -- 830
	end) -- 830
end -- 816
function ReadFileAction.prototype.exec(self, input) -- 837
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 837
		if input.tool == "read_file_range" and input.range then -- 837
			return ____awaiter_resolve( -- 837
				nil, -- 837
				Tools.readFileRange(input.workDir, input.path, input.range.startLine, input.range.endLine) -- 839
			) -- 839
		end -- 839
		return ____awaiter_resolve( -- 839
			nil, -- 839
			Tools.readFile(input.workDir, input.path) -- 841
		) -- 841
	end) -- 841
end -- 837
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 844
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 844
		local result = execRes -- 845
		local last = shared.history[#shared.history] -- 846
		if last ~= nil then -- 846
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 848
		end -- 848
		shared.step = shared.step + 1 -- 850
		return ____awaiter_resolve(nil, "main") -- 850
	end) -- 850
end -- 844
local SearchFilesAction = __TS__Class() -- 855
SearchFilesAction.name = "SearchFilesAction" -- 855
__TS__ClassExtends(SearchFilesAction, Node) -- 855
function SearchFilesAction.prototype.prep(self, shared) -- 856
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 856
		local last = shared.history[#shared.history] -- 857
		if not last then -- 857
			error( -- 858
				__TS__New(Error, "no history"), -- 858
				0 -- 858
			) -- 858
		end -- 858
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 858
	end) -- 858
end -- 856
function SearchFilesAction.prototype.exec(self, input) -- 862
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 862
		local params = input.params -- 863
		local ____Tools_searchFiles_23 = Tools.searchFiles -- 864
		local ____input_workDir_16 = input.workDir -- 865
		local ____temp_17 = params.path or "" -- 866
		local ____temp_18 = params.pattern or "" -- 867
		local ____params_globs_19 = params.globs -- 868
		local ____params_useRegex_20 = params.useRegex -- 869
		local ____params_caseSensitive_21 = params.caseSensitive -- 870
		local ____params_includeContent_22 = params.includeContent -- 871
		local ____params_contentWindow_15 = params.contentWindow -- 872
		if ____params_contentWindow_15 == nil then -- 872
			____params_contentWindow_15 = 120 -- 872
		end -- 872
		local result = __TS__Await(____Tools_searchFiles_23({ -- 864
			workDir = ____input_workDir_16, -- 865
			path = ____temp_17, -- 866
			pattern = ____temp_18, -- 867
			globs = ____params_globs_19, -- 868
			useRegex = ____params_useRegex_20, -- 869
			caseSensitive = ____params_caseSensitive_21, -- 870
			includeContent = ____params_includeContent_22, -- 871
			contentWindow = __TS__Number(____params_contentWindow_15) -- 872
		})) -- 872
		return ____awaiter_resolve(nil, result) -- 872
	end) -- 872
end -- 862
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 877
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 877
		local last = shared.history[#shared.history] -- 878
		if last ~= nil then -- 878
			last.result = execRes -- 879
		end -- 879
		shared.step = shared.step + 1 -- 880
		return ____awaiter_resolve(nil, "main") -- 880
	end) -- 880
end -- 877
local SearchDoraAPIAction = __TS__Class() -- 885
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 885
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 885
function SearchDoraAPIAction.prototype.prep(self, shared) -- 886
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 886
		local last = shared.history[#shared.history] -- 887
		if not last then -- 887
			error( -- 888
				__TS__New(Error, "no history"), -- 888
				0 -- 888
			) -- 888
		end -- 888
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 888
	end) -- 888
end -- 886
function SearchDoraAPIAction.prototype.exec(self, input) -- 892
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 892
		local params = input.params -- 893
		local ____Tools_searchDoraAPI_33 = Tools.searchDoraAPI -- 894
		local ____temp_26 = params.pattern or "" -- 895
		local ____temp_27 = input.useChineseResponse and "zh" or "en" -- 896
		local ____temp_28 = params.programmingLanguage or "ts" -- 897
		local ____params_topK_24 = params.topK -- 898
		if ____params_topK_24 == nil then -- 898
			____params_topK_24 = 8 -- 898
		end -- 898
		local ____TS__Number_result_29 = __TS__Number(____params_topK_24) -- 898
		local ____params_useRegex_30 = params.useRegex -- 899
		local ____params_caseSensitive_31 = params.caseSensitive -- 900
		local ____params_includeContent_32 = params.includeContent -- 901
		local ____params_contentWindow_25 = params.contentWindow -- 902
		if ____params_contentWindow_25 == nil then -- 902
			____params_contentWindow_25 = 140 -- 902
		end -- 902
		local result = __TS__Await(____Tools_searchDoraAPI_33({ -- 894
			pattern = ____temp_26, -- 895
			docLanguage = ____temp_27, -- 896
			programmingLanguage = ____temp_28, -- 897
			topK = ____TS__Number_result_29, -- 898
			useRegex = ____params_useRegex_30, -- 899
			caseSensitive = ____params_caseSensitive_31, -- 900
			includeContent = ____params_includeContent_32, -- 901
			contentWindow = __TS__Number(____params_contentWindow_25) -- 902
		})) -- 902
		return ____awaiter_resolve(nil, result) -- 902
	end) -- 902
end -- 892
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 907
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 907
		local last = shared.history[#shared.history] -- 908
		if last ~= nil then -- 908
			last.result = execRes -- 909
		end -- 909
		shared.step = shared.step + 1 -- 910
		return ____awaiter_resolve(nil, "main") -- 910
	end) -- 910
end -- 907
local ListFilesAction = __TS__Class() -- 915
ListFilesAction.name = "ListFilesAction" -- 915
__TS__ClassExtends(ListFilesAction, Node) -- 915
function ListFilesAction.prototype.prep(self, shared) -- 916
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 916
		local last = shared.history[#shared.history] -- 917
		if not last then -- 917
			error( -- 918
				__TS__New(Error, "no history"), -- 918
				0 -- 918
			) -- 918
		end -- 918
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 918
	end) -- 918
end -- 916
function ListFilesAction.prototype.exec(self, input) -- 922
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 922
		local params = input.params -- 923
		local result = Tools.listFiles({workDir = input.workDir, path = params.path or "", globs = params.globs}) -- 924
		return ____awaiter_resolve(nil, result) -- 924
	end) -- 924
end -- 922
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 932
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 932
		local last = shared.history[#shared.history] -- 933
		if last ~= nil then -- 933
			last.result = execRes -- 934
		end -- 934
		shared.step = shared.step + 1 -- 935
		return ____awaiter_resolve(nil, "main") -- 935
	end) -- 935
end -- 932
local DeleteFileAction = __TS__Class() -- 940
DeleteFileAction.name = "DeleteFileAction" -- 940
__TS__ClassExtends(DeleteFileAction, Node) -- 940
function DeleteFileAction.prototype.prep(self, shared) -- 941
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 941
		local last = shared.history[#shared.history] -- 942
		if not last then -- 942
			error( -- 943
				__TS__New(Error, "no history"), -- 943
				0 -- 943
			) -- 943
		end -- 943
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 944
		if __TS__StringTrim(targetFile) == "" then -- 944
			error( -- 947
				__TS__New(Error, "missing target_file"), -- 947
				0 -- 947
			) -- 947
		end -- 947
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 947
	end) -- 947
end -- 941
function DeleteFileAction.prototype.exec(self, input) -- 951
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 951
		return ____awaiter_resolve( -- 951
			nil, -- 951
			Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 952
		) -- 952
	end) -- 952
end -- 951
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 958
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 958
		local last = shared.history[#shared.history] -- 959
		if last ~= nil then -- 959
			last.result = execRes -- 960
		end -- 960
		shared.step = shared.step + 1 -- 961
		return ____awaiter_resolve(nil, "main") -- 961
	end) -- 961
end -- 958
local RunTsBuildAction = __TS__Class() -- 966
RunTsBuildAction.name = "RunTsBuildAction" -- 966
__TS__ClassExtends(RunTsBuildAction, Node) -- 966
function RunTsBuildAction.prototype.prep(self, shared) -- 967
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 967
		local last = shared.history[#shared.history] -- 968
		if not last then -- 968
			error( -- 969
				__TS__New(Error, "no history"), -- 969
				0 -- 969
			) -- 969
		end -- 969
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 969
	end) -- 969
end -- 967
function RunTsBuildAction.prototype.exec(self, input) -- 973
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 973
		local params = input.params -- 974
		local result = __TS__Await(Tools.runTsBuild({workDir = input.workDir, path = params.path or ""})) -- 975
		return ____awaiter_resolve(nil, result) -- 975
	end) -- 975
end -- 973
function RunTsBuildAction.prototype.post(self, shared, _prepRes, execRes) -- 982
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 982
		local last = shared.history[#shared.history] -- 983
		if last ~= nil then -- 983
			last.result = execRes -- 984
		end -- 984
		shared.step = shared.step + 1 -- 985
		return ____awaiter_resolve(nil, "main") -- 985
	end) -- 985
end -- 982
local EditFileAction = __TS__Class() -- 990
EditFileAction.name = "EditFileAction" -- 990
__TS__ClassExtends(EditFileAction, Node) -- 990
function EditFileAction.prototype.prep(self, shared) -- 991
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 991
		local last = shared.history[#shared.history] -- 992
		if not last then -- 992
			error( -- 993
				__TS__New(Error, "no history"), -- 993
				0 -- 993
			) -- 993
		end -- 993
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 994
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 997
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 998
		if __TS__StringTrim(path) == "" then -- 998
			error( -- 999
				__TS__New(Error, "missing path"), -- 999
				0 -- 999
			) -- 999
		end -- 999
		if oldStr == newStr then -- 999
			error( -- 1000
				__TS__New(Error, "old_str and new_str must be different"), -- 1000
				0 -- 1000
			) -- 1000
		end -- 1000
		return ____awaiter_resolve(nil, { -- 1000
			path = path, -- 1001
			oldStr = oldStr, -- 1001
			newStr = newStr, -- 1001
			taskId = shared.taskId, -- 1001
			workDir = shared.workingDir -- 1001
		}) -- 1001
	end) -- 1001
end -- 991
function EditFileAction.prototype.exec(self, input) -- 1004
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1004
		local readRes = Tools.readFile(input.workDir, input.path) -- 1005
		if not readRes.success then -- 1005
			if input.oldStr ~= "" then -- 1005
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 1005
			end -- 1005
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1010
			if not createRes.success then -- 1010
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 1010
			end -- 1010
			return ____awaiter_resolve(nil, { -- 1010
				success = true, -- 1018
				changed = true, -- 1019
				mode = "create", -- 1020
				replaced = 0, -- 1021
				checkpointId = createRes.checkpointId, -- 1022
				checkpointSeq = createRes.checkpointSeq -- 1023
			}) -- 1023
		end -- 1023
		if input.oldStr == "" then -- 1023
			return ____awaiter_resolve(nil, {success = false, message = "old_str must be non-empty when editing an existing file"}) -- 1023
		end -- 1023
		local replaceRes = replaceAllAndCount(readRes.content, input.oldStr, input.newStr) -- 1030
		if replaceRes.replaced == 0 then -- 1030
			return ____awaiter_resolve(nil, {success = false, message = "old_str not found in file"}) -- 1030
		end -- 1030
		if replaceRes.content == readRes.content then -- 1030
			return ____awaiter_resolve(nil, {success = true, changed = false, mode = "no_change", replaced = replaceRes.replaced}) -- 1030
		end -- 1030
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = replaceRes.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 1043
		if not applyRes.success then -- 1043
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 1043
		end -- 1043
		return ____awaiter_resolve(nil, { -- 1043
			success = true, -- 1051
			changed = true, -- 1052
			mode = "replace", -- 1053
			replaced = replaceRes.replaced, -- 1054
			checkpointId = applyRes.checkpointId, -- 1055
			checkpointSeq = applyRes.checkpointSeq -- 1056
		}) -- 1056
	end) -- 1056
end -- 1004
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 1060
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1060
		local last = shared.history[#shared.history] -- 1061
		if last ~= nil then -- 1061
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 1063
			last.result = execRes -- 1064
		end -- 1064
		shared.step = shared.step + 1 -- 1066
		return ____awaiter_resolve(nil, "main") -- 1066
	end) -- 1066
end -- 1060
local FormatResponseNode = __TS__Class() -- 1071
FormatResponseNode.name = "FormatResponseNode" -- 1071
__TS__ClassExtends(FormatResponseNode, Node) -- 1071
function FormatResponseNode.prototype.prep(self, shared) -- 1072
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1072
		return ____awaiter_resolve(nil, {history = shared.history, shared = shared}) -- 1072
	end) -- 1072
end -- 1072
function FormatResponseNode.prototype.exec(self, input) -- 1076
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1076
		if input.shared.stopToken.stopped then -- 1076
			return ____awaiter_resolve( -- 1076
				nil, -- 1076
				getCancelledReason(input.shared) -- 1078
			) -- 1078
		end -- 1078
		local history = input.history -- 1080
		if #history == 0 then -- 1080
			return ____awaiter_resolve(nil, "No actions were performed.") -- 1080
		end -- 1080
		local summary = formatHistorySummary(history) -- 1084
		local prompt = (("You are a coding assistant. Summarize what you did for the user.\n\nHere are the actions you performed:\n" .. summary) .. "\n\nGenerate a concise response that explains:\n1. What actions were taken\n2. What was found or modified\n3. Any next steps\n\nIMPORTANT:\n- Focus on outcomes, not tool names.\n- Speak directly to the user.\n") .. getReplyLanguageDirective(input.shared) -- 1085
		local res -- 1099
		do -- 1099
			local i = 0 -- 1100
			while i < input.shared.llmMaxTry do -- 1100
				res = __TS__Await(llmStream(input.shared, {{role = "user", content = prompt}})) -- 1101
				if res.success then -- 1101
					break -- 1102
				end -- 1102
				i = i + 1 -- 1100
			end -- 1100
		end -- 1100
		if not res then -- 1100
			return ____awaiter_resolve(nil, input.shared.useChineseResponse and "执行完成，但生成总结失败。" or "Completed, but failed to generate summary.") -- 1100
		end -- 1100
		if not res.success then -- 1100
			return ____awaiter_resolve(nil, input.shared.useChineseResponse and "执行完成，但生成总结失败：" .. res.message or "Completed, but failed to generate summary: " .. res.message) -- 1100
		end -- 1100
		return ____awaiter_resolve(nil, res.text) -- 1100
	end) -- 1100
end -- 1076
function FormatResponseNode.prototype.post(self, shared, _prepRes, execRes) -- 1115
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1115
		shared.response = execRes -- 1116
		shared.done = true -- 1117
		return ____awaiter_resolve(nil, nil) -- 1117
	end) -- 1117
end -- 1115
local CodingAgentFlow = __TS__Class() -- 1122
CodingAgentFlow.name = "CodingAgentFlow" -- 1122
__TS__ClassExtends(CodingAgentFlow, Flow) -- 1122
function CodingAgentFlow.prototype.____constructor(self) -- 1123
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 1124
	local read = __TS__New(ReadFileAction, 1, 0) -- 1125
	local search = __TS__New(SearchFilesAction, 1, 0) -- 1126
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 1127
	local list = __TS__New(ListFilesAction, 1, 0) -- 1128
	local del = __TS__New(DeleteFileAction, 1, 0) -- 1129
	local build = __TS__New(RunTsBuildAction, 1, 0) -- 1130
	local edit = __TS__New(EditFileAction, 1, 0) -- 1131
	local format = __TS__New(FormatResponseNode, 1, 0) -- 1132
	main:on("read_file", read) -- 1134
	main:on("read_file_range", read) -- 1135
	main:on("search_files", search) -- 1136
	main:on("search_dora_api", searchDora) -- 1137
	main:on("list_files", list) -- 1138
	main:on("delete_file", del) -- 1139
	main:on("run_ts_build", build) -- 1140
	main:on("edit_file", edit) -- 1141
	main:on("finish", format) -- 1142
	main:on("error", format) -- 1143
	read:on("main", main) -- 1145
	search:on("main", main) -- 1146
	searchDora:on("main", main) -- 1147
	list:on("main", main) -- 1148
	del:on("main", main) -- 1149
	build:on("main", main) -- 1150
	edit:on("main", main) -- 1151
	Flow.prototype.____constructor(self, main) -- 1153
end -- 1123
local function runCodingAgentAsync(options) -- 1157
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1157
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 1157
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 1157
		end -- 1157
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(options.prompt) -- 1161
		if not taskRes.success then -- 1161
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 1161
		end -- 1161
		local compressor = __TS__New(MemoryCompressor, {contextWindow = options.memoryContext or 32000, compressionThreshold = 0.8, projectDir = options.workDir}) -- 1169
		local shared = { -- 1175
			taskId = taskRes.taskId, -- 1176
			maxSteps = math.max( -- 1177
				1, -- 1177
				math.floor(options.maxSteps or 40) -- 1177
			), -- 1177
			llmMaxTry = math.max( -- 1178
				1, -- 1178
				math.floor(options.llmMaxTry or 3) -- 1178
			), -- 1178
			step = 0, -- 1179
			done = false, -- 1180
			stopToken = options.stopToken or ({stopped = false}), -- 1181
			response = "", -- 1182
			userQuery = options.prompt, -- 1183
			workingDir = options.workDir, -- 1184
			useChineseResponse = options.useChineseResponse == true, -- 1185
			decisionMode = options.decisionMode == "yaml" and "yaml" or "tool_calling", -- 1186
			llmOptions = __TS__ObjectAssign({temperature = 0.2}, options.llmOptions or ({})), -- 1187
			history = {}, -- 1191
			memory = {lastConsolidatedIndex = 0, compressor = compressor, hasCompressedThisTask = false} -- 1193
		} -- 1193
		local ____try = __TS__AsyncAwaiter(function() -- 1193
			if shared.stopToken.stopped then -- 1193
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1202
				return ____awaiter_resolve( -- 1202
					nil, -- 1202
					{ -- 1203
						success = false, -- 1203
						taskId = shared.taskId, -- 1203
						message = getCancelledReason(shared), -- 1203
						steps = shared.step -- 1203
					} -- 1203
				) -- 1203
			end -- 1203
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 1205
			local flow = __TS__New(CodingAgentFlow) -- 1206
			__TS__Await(flow:run(shared)) -- 1207
			if shared.stopToken.stopped then -- 1207
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1209
				return ____awaiter_resolve( -- 1209
					nil, -- 1209
					{ -- 1210
						success = false, -- 1210
						taskId = shared.taskId, -- 1210
						message = getCancelledReason(shared), -- 1210
						steps = shared.step -- 1210
					} -- 1210
				) -- 1210
			end -- 1210
			if shared.error then -- 1210
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1213
				return ____awaiter_resolve(nil, {success = false, taskId = shared.taskId, message = shared.error, steps = shared.step}) -- 1213
			end -- 1213
			Tools.setTaskStatus(shared.taskId, "DONE") -- 1216
			return ____awaiter_resolve(nil, {success = true, taskId = shared.taskId, message = shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed."), steps = shared.step}) -- 1216
		end) -- 1216
		__TS__Await(____try.catch( -- 1200
			____try, -- 1200
			function(____, e) -- 1200
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 1224
				return ____awaiter_resolve( -- 1224
					nil, -- 1224
					{ -- 1225
						success = false, -- 1225
						taskId = shared.taskId, -- 1225
						message = tostring(e), -- 1225
						steps = shared.step -- 1225
					} -- 1225
				) -- 1225
			end -- 1225
		)) -- 1225
	end) -- 1225
end -- 1157
function ____exports.runCodingAgent(options, callback) -- 1229
	local ____self_34 = runCodingAgentAsync(options) -- 1229
	____self_34["then"]( -- 1229
		____self_34, -- 1229
		function(____, result) return callback(result) end -- 1230
	) -- 1230
end -- 1229
return ____exports -- 1229