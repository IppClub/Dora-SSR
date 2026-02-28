-- [ts]: CodingAgent.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringReplace = ____lualib.__TS__StringReplace -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local CodingAgentFlow -- 1
local ____Dora = require("Dora") -- 2
local json = ____Dora.json -- 2
local sleep = ____Dora.sleep -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local Content = ____Dora.Content -- 2
local wait = ____Dora.wait -- 2
local emit = ____Dora.emit -- 2
local ____flow = require("Agent.flow") -- 3
local Flow = ____flow.Flow -- 3
local Node = ____flow.Node -- 3
local ____Utils = require("Agent.Utils") -- 4
local callLLM = ____Utils.callLLM -- 4
local Tools = require("Agent.Tools") -- 5
local yaml = require("yaml") -- 6
function ____exports.runCodingAgentAsync(options) -- 795
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 795
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 795
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 795
		end -- 795
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(options.prompt) -- 799
		if not taskRes.success then -- 799
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 799
		end -- 799
		local shared = { -- 806
			taskId = taskRes.taskId, -- 807
			maxSteps = math.max( -- 808
				1, -- 808
				math.floor(options.maxSteps or 10) -- 808
			), -- 808
			step = 0, -- 809
			done = false, -- 810
			cancelled = false, -- 811
			response = "", -- 812
			userQuery = options.prompt, -- 813
			workingDir = options.workDir, -- 814
			useChineseResponse = options.useChineseResponse == true, -- 815
			llmOptions = __TS__ObjectAssign({temperature = 0.2}, options.llmOptions or ({})), -- 816
			history = {} -- 820
		} -- 820
		local ____try = __TS__AsyncAwaiter(function() -- 820
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 824
			local flow = __TS__New(CodingAgentFlow) -- 825
			__TS__Await(flow:run(shared)) -- 826
			if shared.cancelled then -- 826
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 828
				return ____awaiter_resolve(nil, {success = false, taskId = shared.taskId, message = "cancelled", steps = shared.step}) -- 828
			end -- 828
			if shared.error then -- 828
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 832
				return ____awaiter_resolve(nil, {success = false, taskId = shared.taskId, message = shared.error, steps = shared.step}) -- 832
			end -- 832
			Tools.setTaskStatus(shared.taskId, "DONE") -- 835
			return ____awaiter_resolve(nil, {success = true, taskId = shared.taskId, message = shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed."), steps = shared.step}) -- 835
		end) -- 835
		__TS__Await(____try.catch( -- 823
			____try, -- 823
			function(____, e) -- 823
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 843
				return ____awaiter_resolve( -- 843
					nil, -- 843
					{ -- 844
						success = false, -- 844
						taskId = shared.taskId, -- 844
						message = tostring(e), -- 844
						steps = shared.step -- 844
					} -- 844
				) -- 844
			end -- 844
		)) -- 844
	end) -- 844
end -- 795
local function toJson(value) -- 71
	local text, err = json.encode(value) -- 72
	if text ~= nil then -- 72
		return text -- 73
	end -- 73
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 74
end -- 71
local function truncateText(text, maxLen) -- 77
	if #text <= maxLen then -- 77
		return text -- 78
	end -- 78
	local pos = utf8.offset(text, maxLen) -- 79
	return __TS__StringSlice(text, 0, pos) .. "..." -- 80
end -- 77
local function summarizeUnknown(value, maxLen) -- 83
	if maxLen == nil then -- 83
		maxLen = 320 -- 83
	end -- 83
	if value == nil then -- 83
		return "undefined" -- 84
	end -- 84
	if value == nil then -- 84
		return "null" -- 85
	end -- 85
	if type(value) == "string" then -- 85
		return __TS__StringReplace( -- 87
			truncateText(value, maxLen), -- 87
			"\n", -- 87
			"\\n" -- 87
		) -- 87
	end -- 87
	if type(value) == "number" or type(value) == "boolean" then -- 87
		return tostring(value) -- 90
	end -- 90
	return __TS__StringReplace( -- 92
		truncateText( -- 92
			toJson(value), -- 92
			maxLen -- 92
		), -- 92
		"\n", -- 92
		"\\n" -- 92
	) -- 92
end -- 83
local function getReplyLanguageDirective(shared) -- 95
	return shared.useChineseResponse and "Use Simplified Chinese for natural-language fields (reason/message/summary)." or "Use English for natural-language fields (reason/message/summary)." -- 96
end -- 95
local function isKnownToolName(name) -- 101
	return name == "read_file" or name == "read_file_range" or name == "edit_file" or name == "delete_file" or name == "search_files" or name == "search_dora_api" or name == "list_files" or name == "run_ts_build" or name == "finish" -- 102
end -- 101
local function formatHistorySummary(history) -- 113
	if #history == 0 then -- 113
		return "No previous actions." -- 115
	end -- 115
	local actions = history -- 117
	local lines = {} -- 118
	lines[#lines + 1] = "" -- 119
	do -- 119
		local i = 0 -- 120
		while i < #actions do -- 120
			local action = actions[i + 1] -- 121
			lines[#lines + 1] = ("Action " .. tostring(i + 1)) .. ":" -- 122
			lines[#lines + 1] = "- Tool: " .. action.tool -- 123
			lines[#lines + 1] = "- Reason: " .. action.reason -- 124
			if action.params and type(action.params) == "table" and ({next(action.params)}) ~= nil then -- 124
				lines[#lines + 1] = "- Parameters:" -- 126
				for key in pairs(action.params) do -- 127
					lines[#lines + 1] = (("  - " .. key) .. ": ") .. summarizeUnknown(action.params[key], 2000) -- 128
				end -- 128
			end -- 128
			if action.result and type(action.result) == "table" then -- 128
				local result = action.result -- 132
				local success = result.success == true -- 133
				lines[#lines + 1] = "- Result: " .. (success and "Success" or "Failed") -- 134
				if action.tool == "read_file" or action.tool == "read_file_range" then -- 134
					if success and type(result.content) == "string" then -- 134
						lines[#lines + 1] = "- Content: " .. result.content -- 137
					end -- 137
				elseif action.tool == "search_files" then -- 137
					if success and type(result.results) == "table" then -- 137
						local matches = result.results -- 141
						lines[#lines + 1] = "- Matches: " .. tostring(#matches) -- 142
						do -- 142
							local j = 0 -- 143
							while j < #matches do -- 143
								local m = matches[j + 1] -- 144
								local file = type(m.file) == "string" and m.file or "" -- 145
								local line = m.line ~= nil and tostring(m.line) or "" -- 146
								local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 147
								lines[#lines + 1] = ((((("  " .. tostring(j + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 148
								j = j + 1 -- 143
							end -- 143
						end -- 143
					end -- 143
				elseif action.tool == "search_dora_api" then -- 143
					if success and type(result.results) == "table" then -- 143
						local hits = result.results -- 153
						lines[#lines + 1] = "- Matches: " .. tostring(#hits) -- 154
						do -- 154
							local j = 0 -- 155
							while j < #hits do -- 155
								local m = hits[j + 1] -- 156
								local file = type(m.file) == "string" and m.file or "" -- 157
								local line = m.line ~= nil and tostring(m.line) or "" -- 158
								local content = type(m.content) == "string" and m.content or summarizeUnknown(m, 240) -- 159
								lines[#lines + 1] = ((((("  " .. tostring(j + 1)) .. ". ") .. file) .. (line ~= "" and ":" .. line or "")) .. ": ") .. content -- 160
								j = j + 1 -- 155
							end -- 155
						end -- 155
					end -- 155
				elseif action.tool == "edit_file" then -- 155
					if success then -- 155
						if result.mode ~= nil then -- 155
							lines[#lines + 1] = "- Mode: " .. tostring(result.mode) -- 166
						end -- 166
						if result.replaced ~= nil then -- 166
							lines[#lines + 1] = "- Replaced: " .. tostring(result.replaced) -- 169
						end -- 169
					end -- 169
				elseif action.tool == "list_files" then -- 169
					if success and type(result.files) == "table" then -- 169
						local files = result.files -- 174
						lines[#lines + 1] = "- Directory structure:" -- 175
						if #files > 0 then -- 175
							do -- 175
								local j = 0 -- 177
								while j < #files do -- 177
									lines[#lines + 1] = "  " .. files[j + 1] -- 178
									j = j + 1 -- 177
								end -- 177
							end -- 177
						else -- 177
							lines[#lines + 1] = "  (Empty or inaccessible directory)" -- 181
						end -- 181
					end -- 181
				else -- 181
					lines[#lines + 1] = "- Detail: " .. truncateText( -- 185
						toJson(result), -- 185
						4000 -- 185
					) -- 185
				end -- 185
			elseif action.result ~= nil then -- 185
				lines[#lines + 1] = "- Result: " .. summarizeUnknown(action.result, 3000) -- 188
			else -- 188
				lines[#lines + 1] = "- Result: pending" -- 190
			end -- 190
			if i < #actions - 1 then -- 190
				lines[#lines + 1] = "" -- 192
			end -- 192
			i = i + 1 -- 120
		end -- 120
	end -- 120
	return table.concat(lines, "\n") -- 194
end -- 113
local function extractYAMLFromText(text) -- 197
	local source = __TS__StringTrim(text) -- 198
	local yamlFencePos = (string.find(source, "```yaml", nil, true) or 0) - 1 -- 199
	if yamlFencePos >= 0 then -- 199
		local from = yamlFencePos + #"```yaml" -- 201
		local ____end = (string.find( -- 202
			source, -- 202
			"```", -- 202
			math.max(from + 1, 1), -- 202
			true -- 202
		) or 0) - 1 -- 202
		if ____end > from then -- 202
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 203
		end -- 203
	end -- 203
	local ymlFencePos = (string.find(source, "```yml", nil, true) or 0) - 1 -- 205
	if ymlFencePos >= 0 then -- 205
		local from = ymlFencePos + #"```yml" -- 207
		local ____end = (string.find( -- 208
			source, -- 208
			"```", -- 208
			math.max(from + 1, 1), -- 208
			true -- 208
		) or 0) - 1 -- 208
		if ____end > from then -- 208
			return __TS__StringTrim(__TS__StringSlice(source, from, ____end)) -- 209
		end -- 209
	end -- 209
	local fencePos = (string.find(source, "```", nil, true) or 0) - 1 -- 211
	if fencePos >= 0 then -- 211
		local firstLineEnd = (string.find( -- 213
			source, -- 213
			"\n", -- 213
			math.max(fencePos + 1, 1), -- 213
			true -- 213
		) or 0) - 1 -- 213
		local ____end = (string.find( -- 214
			source, -- 214
			"```", -- 214
			math.max((firstLineEnd >= 0 and firstLineEnd + 1 or fencePos + 3) + 1, 1), -- 214
			true -- 214
		) or 0) - 1 -- 214
		if firstLineEnd >= 0 and ____end > firstLineEnd then -- 214
			return __TS__StringTrim(__TS__StringSlice(source, firstLineEnd + 1, ____end)) -- 216
		end -- 216
	end -- 216
	return source -- 219
end -- 197
local function parseYAMLObjectFromText(text) -- 222
	local yamlText = extractYAMLFromText(text) -- 223
	local obj, err = yaml.parse(yamlText) -- 224
	if obj == nil or type(obj) ~= "table" then -- 224
		return { -- 226
			success = false, -- 226
			message = "invalid yaml: " .. tostring(err) -- 226
		} -- 226
	end -- 226
	return {success = true, obj = obj} -- 228
end -- 222
local function callLLMText(shared, messages) -- 231
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 231
		local text = "" -- 232
		local cancelledReason -- 233
		local done = false -- 234
		do -- 234
			local i = 0 -- 236
			while i < 5 do -- 236
				done = false -- 237
				cancelledReason = nil -- 238
				text = "" -- 239
				emit( -- 240
					"LLM_IN", -- 240
					table.concat( -- 240
						__TS__ArrayMap( -- 240
							messages, -- 240
							function(____, m, i) return (tostring(i) .. ": ") .. m.content end -- 240
						), -- 240
						"\n" -- 240
					) -- 240
				) -- 240
				callLLM( -- 241
					messages, -- 242
					shared.llmOptions, -- 243
					{ -- 244
						id = nil, -- 245
						onData = function(data) -- 246
							if shared.cancelled then -- 246
								return true -- 247
							end -- 247
							local choice = data.choices and data.choices[1] -- 248
							local delta = choice and choice.delta -- 249
							if delta and type(delta.content) == "string" then -- 249
								text = text .. delta.content -- 251
								emit("LLM_OUT", delta.content) -- 252
							end -- 252
							return false -- 254
						end, -- 246
						onCancel = function(reason) -- 256
							cancelledReason = reason -- 257
							done = true -- 258
						end, -- 256
						onDone = function() -- 260
							done = true -- 261
						end -- 260
					} -- 260
				) -- 260
				__TS__Await(__TS__New( -- 266
					__TS__Promise, -- 266
					function(____, resolve) -- 266
						Director.systemScheduler:schedule(once(function() -- 267
							wait(function() return done end) -- 268
							resolve(nil) -- 269
						end)) -- 267
					end -- 266
				)) -- 266
				if text == "" then -- 266
					cancelledReason = "empty LLM output" -- 274
				end -- 274
				if not cancelledReason then -- 274
					break -- 276
				end -- 276
				emit("LLM_ABORT") -- 277
				__TS__Await(__TS__New( -- 278
					__TS__Promise, -- 278
					function(____, resolve) -- 278
						Director.systemScheduler:schedule(once(function() -- 279
							sleep(2) -- 280
							resolve(nil) -- 281
						end)) -- 279
					end -- 278
				)) -- 278
				i = i + 1 -- 236
			end -- 236
		end -- 236
		emit("LLMStream", "\n") -- 285
		if cancelledReason then -- 285
			return ____awaiter_resolve(nil, {success = false, message = cancelledReason, text = text}) -- 285
		end -- 285
		return ____awaiter_resolve(nil, {success = true, text = text}) -- 285
	end) -- 285
end -- 231
local function parseDecisionObject(rawObj) -- 290
	if type(rawObj.tool) ~= "string" then -- 290
		return {success = false, message = "missing tool"} -- 291
	end -- 291
	local tool = rawObj.tool -- 292
	if not isKnownToolName(tool) then -- 292
		return {success = false, message = "unknown tool: " .. tool} -- 294
	end -- 294
	local reason = type(rawObj.reason) == "string" and rawObj.reason or "" -- 296
	local params = type(rawObj.params) == "table" and rawObj.params or ({}) -- 297
	return {success = true, tool = tool, reason = reason, params = params} -- 298
end -- 290
local function replaceAllAndCount(text, oldStr, newStr) -- 301
	if oldStr == "" then -- 301
		return {content = text, replaced = 0} -- 302
	end -- 302
	local count = 0 -- 303
	local from = 0 -- 304
	while true do -- 304
		local idx = (string.find( -- 306
			text, -- 306
			oldStr, -- 306
			math.max(from + 1, 1), -- 306
			true -- 306
		) or 0) - 1 -- 306
		if idx < 0 then -- 306
			break -- 307
		end -- 307
		count = count + 1 -- 308
		from = idx + #oldStr -- 309
	end -- 309
	if count == 0 then -- 309
		return {content = text, replaced = 0} -- 311
	end -- 311
	return { -- 312
		content = table.concat( -- 313
			__TS__StringSplit(text, oldStr), -- 313
			newStr or "," -- 313
		), -- 313
		replaced = count -- 314
	} -- 314
end -- 301
local MainDecisionAgent = __TS__Class() -- 318
MainDecisionAgent.name = "MainDecisionAgent" -- 318
__TS__ClassExtends(MainDecisionAgent, Node) -- 318
function MainDecisionAgent.prototype.prep(self, shared) -- 319
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 319
		return ____awaiter_resolve(nil, {userQuery = shared.userQuery, history = shared.history, shared = shared}) -- 319
	end) -- 319
end -- 319
function MainDecisionAgent.prototype.exec(self, input) -- 327
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 327
		local historyText = formatHistorySummary(input.history) -- 328
		local prompt = table.concat( -- 329
			{ -- 329
				"You are a coding assistant that helps modify and navigate code.", -- 330
				"Given the request and action history, decide which tool to use next.", -- 331
				"", -- 332
				"User request: " .. input.userQuery, -- 333
				"", -- 334
				"Here are the actions you performed:", -- 335
				historyText, -- 336
				"", -- 337
				"Available tools:", -- 338
				"1. read_file: Read content from a file", -- 339
				"   - Parameters: path (workspace-relative)", -- 340
				"1b. read_file_range: Read specific line range from a file", -- 341
				"   - Parameters: path, startLine, endLine", -- 342
				"", -- 343
				"2. edit_file: Make changes to a file", -- 344
				"   - Parameters: path, old_str, new_str", -- 345
				"   - Rules:", -- 346
				"     - old_str and new_str MUST be different", -- 347
				"     - old_str must match existing text exactly when it is non-empty", -- 348
				"     - If file doesn't exist, set old_str to empty string to create it with new_str", -- 349
				"", -- 350
				"3. delete_file: Remove a file", -- 351
				"   - Parameters: target_file", -- 352
				"", -- 353
				"4. search_files: Search patterns in workspace files", -- 354
				"   - Parameters: path, pattern, globs(optional), useRegex(optional), caseSensitive(optional)", -- 355
				"", -- 356
				"5. list_files: List files under a directory", -- 357
				"   - Parameters: path, globs(optional)", -- 358
				"", -- 359
				"6. search_dora_api: Search Dora SSR game engine API docs", -- 360
				"   - Parameters: pattern, programmingLanguage(ts/tsx/lua/yue/teal), topK(optional)", -- 361
				"", -- 362
				"7. run_ts_build: Run TS transpile/build checks", -- 363
				"   - Parameters: path(optional), timeoutSec(optional)", -- 364
				"", -- 365
				"8. finish: End and summarize", -- 366
				"   - Parameters: {}", -- 367
				"", -- 368
				"Respond with one YAML object:", -- 369
				"```yaml", -- 370
				"tool: \"edit_file\"", -- 371
				"reason: |-", -- 372
				"\tA readable multi-line explanation is allowed.", -- 373
				"\tKeep indentation consistent.", -- 374
				"params:", -- 375
				"\tpath: \"relative/path.ts\"", -- 376
				"\told_str: |-", -- 377
				"\t\tfunction oldName() {", -- 378
				"\t\t\tconsole.log(\"old\");", -- 379
				"\t\t}", -- 380
				"\tnew_str: |-", -- 381
				"\t\tfunction newName() {", -- 382
				"\t\t\tconsole.log(\"hello\");", -- 383
				"\t\t}", -- 384
				"```", -- 385
				"Strict YAML formatting rules:", -- 386
				"- Return YAML only, no prose before/after.", -- 387
				"- Use exactly one YAML object with keys: tool, reason, params.", -- 388
				"- Multi-line strings are allowed using block scalars (`|`, `|-`, `>`).", -- 389
				"- If using a block scalar, all content lines must be indented consistently with tabs.", -- 390
				"- For nested multi-line fields (for example params.new_str), indent the block content deeper than the key line using tabs.", -- 391
				"- Keep params shallow and valid for the selected tool.", -- 392
				"- Use tabs for all indentation, never spaces.", -- 393
				"If no more actions are needed, use tool: finish.", -- 394
				getReplyLanguageDirective(input.shared) -- 395
			}, -- 395
			"\n" -- 396
		) -- 396
		local shared = input.shared -- 398
		local lastError = "yaml validation failed" -- 399
		local lastRaw = "" -- 400
		do -- 400
			local attempt = 0 -- 401
			while attempt < 3 do -- 401
				do -- 401
					local feedback = attempt > 0 and ("\n\nPrevious response was invalid (" .. lastError) .. "). Return exactly one valid YAML object only and keep YAML indentation strictly consistent." or "" -- 402
					local messages = {{role = "user", content = prompt .. feedback}} -- 405
					local llmRes = __TS__Await(callLLMText(shared, messages)) -- 406
					if not llmRes.success then -- 406
						lastError = llmRes.message -- 408
						goto __continue82 -- 409
					end -- 409
					lastRaw = llmRes.text -- 411
					local parsed = parseYAMLObjectFromText(llmRes.text) -- 412
					if not parsed.success then -- 412
						lastError = parsed.message -- 414
						goto __continue82 -- 415
					end -- 415
					local decision = parseDecisionObject(parsed.obj) -- 417
					if not decision.success then -- 417
						lastError = decision.message -- 419
						goto __continue82 -- 420
					end -- 420
					return ____awaiter_resolve(nil, decision) -- 420
				end -- 420
				::__continue82:: -- 420
				attempt = attempt + 1 -- 401
			end -- 401
		end -- 401
		return ____awaiter_resolve( -- 401
			nil, -- 401
			{ -- 424
				success = false, -- 424
				message = (("cannot produce valid decision yaml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 424
			} -- 424
		) -- 424
	end) -- 424
end -- 327
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 427
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 427
		local result = execRes -- 428
		if not result.success then -- 428
			shared.error = result.message -- 430
			return ____awaiter_resolve(nil, "error") -- 430
		end -- 430
		shared.lastDecision = {tool = result.tool, reason = result.reason, params = result.params} -- 433
		local ____shared_history_0 = shared.history -- 433
		____shared_history_0[#____shared_history_0 + 1] = { -- 438
			step = shared.step + 1, -- 439
			tool = result.tool, -- 440
			reason = result.reason, -- 441
			params = result.params, -- 442
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 443
		} -- 443
		if result.tool == "finish" then -- 443
			return ____awaiter_resolve(nil, "finish") -- 443
		end -- 443
		return ____awaiter_resolve(nil, result.tool) -- 443
	end) -- 443
end -- 427
local ReadFileAction = __TS__Class() -- 450
ReadFileAction.name = "ReadFileAction" -- 450
__TS__ClassExtends(ReadFileAction, Node) -- 450
function ReadFileAction.prototype.prep(self, shared) -- 451
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 451
		local last = shared.history[#shared.history] -- 452
		if not last then -- 452
			error( -- 453
				__TS__New(Error, "no history"), -- 453
				0 -- 453
			) -- 453
		end -- 453
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 454
		if __TS__StringTrim(path) == "" then -- 454
			error( -- 457
				__TS__New(Error, "missing path"), -- 457
				0 -- 457
			) -- 457
		end -- 457
		if last.tool == "read_file_range" then -- 457
			local ____path_5 = path -- 460
			local ____last_tool_6 = last.tool -- 461
			local ____shared_workingDir_7 = shared.workingDir -- 462
			local ____last_params_startLine_1 = last.params.startLine -- 464
			if ____last_params_startLine_1 == nil then -- 464
				____last_params_startLine_1 = 1 -- 464
			end -- 464
			local ____TS__Number_result_4 = __TS__Number(____last_params_startLine_1) -- 464
			local ____last_params_endLine_2 = last.params.endLine -- 465
			if ____last_params_endLine_2 == nil then -- 465
				____last_params_endLine_2 = last.params.startLine -- 465
			end -- 465
			local ____last_params_endLine_2_3 = ____last_params_endLine_2 -- 465
			if ____last_params_endLine_2_3 == nil then -- 465
				____last_params_endLine_2_3 = 1 -- 465
			end -- 465
			return ____awaiter_resolve( -- 465
				nil, -- 465
				{ -- 459
					path = ____path_5, -- 460
					tool = ____last_tool_6, -- 461
					workDir = ____shared_workingDir_7, -- 462
					range = { -- 463
						startLine = ____TS__Number_result_4, -- 464
						endLine = __TS__Number(____last_params_endLine_2_3) -- 465
					} -- 465
				} -- 465
			) -- 465
		end -- 465
		return ____awaiter_resolve(nil, {path = path, tool = "read_file", workDir = shared.workingDir}) -- 465
	end) -- 465
end -- 451
function ReadFileAction.prototype.exec(self, input) -- 472
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 472
		if input.tool == "read_file_range" and input.range then -- 472
			return ____awaiter_resolve( -- 472
				nil, -- 472
				Tools.readFileRange(input.workDir, input.path, input.range.startLine, input.range.endLine) -- 474
			) -- 474
		end -- 474
		return ____awaiter_resolve( -- 474
			nil, -- 474
			Tools.readFile(input.workDir, input.path) -- 476
		) -- 476
	end) -- 476
end -- 472
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 479
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 479
		local result = execRes -- 480
		local last = shared.history[#shared.history] -- 481
		if last ~= nil then -- 481
			last.result = result -- 483
		end -- 483
		shared.step = shared.step + 1 -- 485
		return ____awaiter_resolve(nil, shared.step >= shared.maxSteps and "finish" or "main") -- 485
	end) -- 485
end -- 479
local SearchFilesAction = __TS__Class() -- 490
SearchFilesAction.name = "SearchFilesAction" -- 490
__TS__ClassExtends(SearchFilesAction, Node) -- 490
function SearchFilesAction.prototype.prep(self, shared) -- 491
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 491
		local last = shared.history[#shared.history] -- 492
		if not last then -- 492
			error( -- 493
				__TS__New(Error, "no history"), -- 493
				0 -- 493
			) -- 493
		end -- 493
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 493
	end) -- 493
end -- 491
function SearchFilesAction.prototype.exec(self, input) -- 497
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 497
		local params = input.params -- 498
		local ____Tools_searchFiles_16 = Tools.searchFiles -- 499
		local ____input_workDir_9 = input.workDir -- 500
		local ____temp_10 = params.path or "" -- 501
		local ____temp_11 = params.pattern or "" -- 502
		local ____params_globs_12 = params.globs -- 503
		local ____params_useRegex_13 = params.useRegex -- 504
		local ____params_caseSensitive_14 = params.caseSensitive -- 505
		local ____params_includeContent_15 = params.includeContent -- 506
		local ____params_contentWindow_8 = params.contentWindow -- 507
		if ____params_contentWindow_8 == nil then -- 507
			____params_contentWindow_8 = 120 -- 507
		end -- 507
		local result = __TS__Await(____Tools_searchFiles_16({ -- 499
			workDir = ____input_workDir_9, -- 500
			path = ____temp_10, -- 501
			pattern = ____temp_11, -- 502
			globs = ____params_globs_12, -- 503
			useRegex = ____params_useRegex_13, -- 504
			caseSensitive = ____params_caseSensitive_14, -- 505
			includeContent = ____params_includeContent_15, -- 506
			contentWindow = __TS__Number(____params_contentWindow_8) -- 507
		})) -- 507
		return ____awaiter_resolve(nil, result) -- 507
	end) -- 507
end -- 497
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 512
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 512
		local last = shared.history[#shared.history] -- 513
		if last ~= nil then -- 513
			last.result = execRes -- 514
		end -- 514
		shared.step = shared.step + 1 -- 515
		return ____awaiter_resolve(nil, shared.step >= shared.maxSteps and "finish" or "main") -- 515
	end) -- 515
end -- 512
local SearchDoraAPIAction = __TS__Class() -- 520
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 520
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 520
function SearchDoraAPIAction.prototype.prep(self, shared) -- 521
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 521
		local last = shared.history[#shared.history] -- 522
		if not last then -- 522
			error( -- 523
				__TS__New(Error, "no history"), -- 523
				0 -- 523
			) -- 523
		end -- 523
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 523
	end) -- 523
end -- 521
function SearchDoraAPIAction.prototype.exec(self, input) -- 527
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 527
		local params = input.params -- 528
		local ____Tools_searchDoraAPI_26 = Tools.searchDoraAPI -- 529
		local ____temp_19 = params.pattern or "" -- 530
		local ____temp_20 = input.useChineseResponse and "zh" or "en" -- 531
		local ____temp_21 = params.programmingLanguage or "ts" -- 532
		local ____params_topK_17 = params.topK -- 533
		if ____params_topK_17 == nil then -- 533
			____params_topK_17 = 8 -- 533
		end -- 533
		local ____TS__Number_result_22 = __TS__Number(____params_topK_17) -- 533
		local ____params_useRegex_23 = params.useRegex -- 534
		local ____params_caseSensitive_24 = params.caseSensitive -- 535
		local ____params_includeContent_25 = params.includeContent -- 536
		local ____params_contentWindow_18 = params.contentWindow -- 537
		if ____params_contentWindow_18 == nil then -- 537
			____params_contentWindow_18 = 140 -- 537
		end -- 537
		local result = __TS__Await(____Tools_searchDoraAPI_26({ -- 529
			pattern = ____temp_19, -- 530
			docLanguage = ____temp_20, -- 531
			programmingLanguage = ____temp_21, -- 532
			topK = ____TS__Number_result_22, -- 533
			useRegex = ____params_useRegex_23, -- 534
			caseSensitive = ____params_caseSensitive_24, -- 535
			includeContent = ____params_includeContent_25, -- 536
			contentWindow = __TS__Number(____params_contentWindow_18) -- 537
		})) -- 537
		return ____awaiter_resolve(nil, result) -- 537
	end) -- 537
end -- 527
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 542
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 542
		local last = shared.history[#shared.history] -- 543
		if last ~= nil then -- 543
			last.result = execRes -- 544
		end -- 544
		shared.step = shared.step + 1 -- 545
		return ____awaiter_resolve(nil, shared.step >= shared.maxSteps and "finish" or "main") -- 545
	end) -- 545
end -- 542
local ListFilesAction = __TS__Class() -- 550
ListFilesAction.name = "ListFilesAction" -- 550
__TS__ClassExtends(ListFilesAction, Node) -- 550
function ListFilesAction.prototype.prep(self, shared) -- 551
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 551
		local last = shared.history[#shared.history] -- 552
		if not last then -- 552
			error( -- 553
				__TS__New(Error, "no history"), -- 553
				0 -- 553
			) -- 553
		end -- 553
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 553
	end) -- 553
end -- 551
function ListFilesAction.prototype.exec(self, input) -- 557
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 557
		local params = input.params -- 558
		local result = Tools.listFiles({workDir = input.workDir, path = params.path or "", globs = params.globs}) -- 559
		return ____awaiter_resolve(nil, result) -- 559
	end) -- 559
end -- 557
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 567
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 567
		local last = shared.history[#shared.history] -- 568
		if last ~= nil then -- 568
			last.result = execRes -- 569
		end -- 569
		shared.step = shared.step + 1 -- 570
		return ____awaiter_resolve(nil, shared.step >= shared.maxSteps and "finish" or "main") -- 570
	end) -- 570
end -- 567
local DeleteFileAction = __TS__Class() -- 575
DeleteFileAction.name = "DeleteFileAction" -- 575
__TS__ClassExtends(DeleteFileAction, Node) -- 575
function DeleteFileAction.prototype.prep(self, shared) -- 576
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 576
		local last = shared.history[#shared.history] -- 577
		if not last then -- 577
			error( -- 578
				__TS__New(Error, "no history"), -- 578
				0 -- 578
			) -- 578
		end -- 578
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 579
		if __TS__StringTrim(targetFile) == "" then -- 579
			error( -- 582
				__TS__New(Error, "missing target_file"), -- 582
				0 -- 582
			) -- 582
		end -- 582
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 582
	end) -- 582
end -- 576
function DeleteFileAction.prototype.exec(self, input) -- 586
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 586
		return ____awaiter_resolve( -- 586
			nil, -- 586
			Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 587
		) -- 587
	end) -- 587
end -- 586
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 593
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 593
		local last = shared.history[#shared.history] -- 594
		if last ~= nil then -- 594
			last.result = execRes -- 595
		end -- 595
		shared.step = shared.step + 1 -- 596
		return ____awaiter_resolve(nil, shared.step >= shared.maxSteps and "finish" or "main") -- 596
	end) -- 596
end -- 593
local RunTsBuildAction = __TS__Class() -- 601
RunTsBuildAction.name = "RunTsBuildAction" -- 601
__TS__ClassExtends(RunTsBuildAction, Node) -- 601
function RunTsBuildAction.prototype.prep(self, shared) -- 602
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 602
		local last = shared.history[#shared.history] -- 603
		if not last then -- 603
			error( -- 604
				__TS__New(Error, "no history"), -- 604
				0 -- 604
			) -- 604
		end -- 604
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 604
	end) -- 604
end -- 602
function RunTsBuildAction.prototype.exec(self, input) -- 608
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 608
		local params = input.params -- 609
		local ____Tools_runTsBuild_30 = Tools.runTsBuild -- 610
		local ____input_workDir_28 = input.workDir -- 611
		local ____temp_29 = params.path or "" -- 612
		local ____params_timeoutSec_27 = params.timeoutSec -- 613
		if ____params_timeoutSec_27 == nil then -- 613
			____params_timeoutSec_27 = 20 -- 613
		end -- 613
		local result = __TS__Await(____Tools_runTsBuild_30({ -- 610
			workDir = ____input_workDir_28, -- 611
			path = ____temp_29, -- 612
			timeoutSec = __TS__Number(____params_timeoutSec_27) -- 613
		})) -- 613
		return ____awaiter_resolve(nil, result) -- 613
	end) -- 613
end -- 608
function RunTsBuildAction.prototype.post(self, shared, _prepRes, execRes) -- 618
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 618
		local last = shared.history[#shared.history] -- 619
		if last ~= nil then -- 619
			last.result = execRes -- 620
		end -- 620
		shared.step = shared.step + 1 -- 621
		return ____awaiter_resolve(nil, shared.step >= shared.maxSteps and "finish" or "main") -- 621
	end) -- 621
end -- 618
local EditFileAction = __TS__Class() -- 626
EditFileAction.name = "EditFileAction" -- 626
__TS__ClassExtends(EditFileAction, Node) -- 626
function EditFileAction.prototype.prep(self, shared) -- 627
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 627
		local last = shared.history[#shared.history] -- 628
		if not last then -- 628
			error( -- 629
				__TS__New(Error, "no history"), -- 629
				0 -- 629
			) -- 629
		end -- 629
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 630
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 633
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 634
		if __TS__StringTrim(path) == "" then -- 634
			error( -- 635
				__TS__New(Error, "missing path"), -- 635
				0 -- 635
			) -- 635
		end -- 635
		if oldStr == newStr then -- 635
			error( -- 636
				__TS__New(Error, "old_str and new_str must be different"), -- 636
				0 -- 636
			) -- 636
		end -- 636
		return ____awaiter_resolve(nil, { -- 636
			path = path, -- 637
			oldStr = oldStr, -- 637
			newStr = newStr, -- 637
			taskId = shared.taskId, -- 637
			workDir = shared.workingDir -- 637
		}) -- 637
	end) -- 637
end -- 627
function EditFileAction.prototype.exec(self, input) -- 640
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 640
		local readRes = Tools.readFile(input.workDir, input.path) -- 641
		if not readRes.success then -- 641
			if input.oldStr ~= "" then -- 641
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 641
			end -- 641
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 646
			if not createRes.success then -- 646
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 646
			end -- 646
			return ____awaiter_resolve(nil, { -- 646
				success = true, -- 654
				changed = true, -- 655
				mode = "create", -- 656
				replaced = 0, -- 657
				checkpointId = createRes.checkpointId, -- 658
				checkpointSeq = createRes.checkpointSeq -- 659
			}) -- 659
		end -- 659
		if input.oldStr == "" then -- 659
			return ____awaiter_resolve(nil, {success = false, message = "old_str must be non-empty when editing an existing file"}) -- 659
		end -- 659
		local replaceRes = replaceAllAndCount(readRes.content, input.oldStr, input.newStr) -- 666
		if replaceRes.replaced == 0 then -- 666
			return ____awaiter_resolve(nil, {success = false, message = "old_str not found in file"}) -- 666
		end -- 666
		if replaceRes.content == readRes.content then -- 666
			return ____awaiter_resolve(nil, {success = true, changed = false, mode = "no_change", replaced = replaceRes.replaced}) -- 666
		end -- 666
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = replaceRes.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 679
		if not applyRes.success then -- 679
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 679
		end -- 679
		return ____awaiter_resolve(nil, { -- 679
			success = true, -- 687
			changed = true, -- 688
			mode = "replace", -- 689
			replaced = replaceRes.replaced, -- 690
			checkpointId = applyRes.checkpointId, -- 691
			checkpointSeq = applyRes.checkpointSeq -- 692
		}) -- 692
	end) -- 692
end -- 640
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 696
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 696
		local last = shared.history[#shared.history] -- 697
		if last ~= nil then -- 697
			last.result = execRes -- 699
		end -- 699
		shared.step = shared.step + 1 -- 701
		return ____awaiter_resolve(nil, shared.step >= shared.maxSteps and "finish" or "main") -- 701
	end) -- 701
end -- 696
local FormatResponseNode = __TS__Class() -- 706
FormatResponseNode.name = "FormatResponseNode" -- 706
__TS__ClassExtends(FormatResponseNode, Node) -- 706
function FormatResponseNode.prototype.prep(self, shared) -- 707
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 707
		return ____awaiter_resolve(nil, {history = shared.history, shared = shared}) -- 707
	end) -- 707
end -- 707
function FormatResponseNode.prototype.exec(self, input) -- 711
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 711
		local history = input.history -- 712
		if #history == 0 then -- 712
			return ____awaiter_resolve(nil, "No actions were performed.") -- 712
		end -- 712
		local summary = formatHistorySummary(history) -- 716
		local prompt = table.concat( -- 717
			{ -- 717
				"You are a coding assistant. Summarize what you did for the user.", -- 718
				"", -- 719
				"Here are the actions you performed:", -- 720
				summary, -- 721
				"", -- 722
				"Generate a concise response that explains:", -- 723
				"1. What actions were taken", -- 724
				"2. What was found or modified", -- 725
				"3. Any next steps", -- 726
				"", -- 727
				"IMPORTANT:", -- 728
				"- Focus on outcomes, not tool names.", -- 729
				"- Speak directly to the user.", -- 730
				getReplyLanguageDirective(input.shared) -- 731
			}, -- 731
			"\n" -- 732
		) -- 732
		local res = __TS__Await(callLLMText(input.shared, {{role = "user", content = prompt}})) -- 733
		if not res.success then -- 733
			return ____awaiter_resolve(nil, input.shared.useChineseResponse and "执行完成，但生成总结失败：" .. res.message or "Completed, but failed to generate summary: " .. res.message) -- 733
		end -- 733
		return ____awaiter_resolve(nil, res.text) -- 733
	end) -- 733
end -- 711
function FormatResponseNode.prototype.post(self, shared, _prepRes, execRes) -- 742
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 742
		shared.response = execRes -- 743
		shared.done = true -- 744
		return ____awaiter_resolve(nil, nil) -- 744
	end) -- 744
end -- 742
CodingAgentFlow = __TS__Class() -- 749
CodingAgentFlow.name = "CodingAgentFlow" -- 749
__TS__ClassExtends(CodingAgentFlow, Flow) -- 749
function CodingAgentFlow.prototype.____constructor(self) -- 750
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 751
	local read = __TS__New(ReadFileAction, 1, 0) -- 752
	local search = __TS__New(SearchFilesAction, 1, 0) -- 753
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 754
	local list = __TS__New(ListFilesAction, 1, 0) -- 755
	local del = __TS__New(DeleteFileAction, 1, 0) -- 756
	local build = __TS__New(RunTsBuildAction, 1, 0) -- 757
	local edit = __TS__New(EditFileAction, 1, 0) -- 758
	local format = __TS__New(FormatResponseNode, 1, 0) -- 759
	main:on("read_file", read) -- 761
	main:on("read_file_range", read) -- 762
	main:on("search_files", search) -- 763
	main:on("search_dora_api", searchDora) -- 764
	main:on("list_files", list) -- 765
	main:on("delete_file", del) -- 766
	main:on("run_ts_build", build) -- 767
	main:on("edit_file", edit) -- 768
	main:on("finish", format) -- 769
	main:on("error", format) -- 770
	read:on("main", main) -- 772
	read:on("finish", format) -- 773
	search:on("main", main) -- 774
	search:on("finish", format) -- 775
	searchDora:on("main", main) -- 776
	searchDora:on("finish", format) -- 777
	list:on("main", main) -- 778
	list:on("finish", format) -- 779
	del:on("main", main) -- 780
	del:on("finish", format) -- 781
	build:on("main", main) -- 782
	build:on("finish", format) -- 783
	edit:on("main", main) -- 784
	edit:on("finish", format) -- 785
	Flow.prototype.____constructor(self, main) -- 787
end -- 750
function ____exports.runCodingAgent(options, callback) -- 791
	local ____self_31 = ____exports.runCodingAgentAsync(options) -- 791
	____self_31["then"]( -- 791
		____self_31, -- 791
		function(____, result) return callback(result) end -- 792
	) -- 792
end -- 791
function ____exports.cancelCodingAgent(shared) -- 848
	shared.cancelled = true -- 849
end -- 848
return ____exports -- 848