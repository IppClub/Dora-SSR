-- [ts]: Handlers.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local ____VisionAnalysis = require("Agent.Tool.VisionAnalysis") -- 2
local analyzeImage = ____VisionAnalysis.analyzeImage -- 2
local AgentConfig = require("Agent.Config.Defaults") -- 3
local ____Questionnaire = require("Agent.Runtime.Questionnaire") -- 4
local normalizeQuestionnaire = ____Questionnaire.normalizeQuestionnaire -- 4
local AgentRuntimePolicy = require("Agent.Runtime.Policy") -- 5
local ____Guards = require("Agent.Tool.Guards") -- 6
local getAgentFileEditPlanGuardDenial = ____Guards.getAgentFileEditPlanGuardDenial -- 6
local ____Validation = require("Agent.Tool.Validation") -- 7
local getAgentFileEditInputs = ____Validation.getAgentFileEditInputs -- 7
local AgentUtils = require("Agent.Utils") -- 8
local Tools = require("Agent.Tools") -- 9
local function readOneFile(context, input) -- 12
	local ____input_startLine_0 = input.startLine -- 13
	if ____input_startLine_0 == nil then -- 13
		____input_startLine_0 = 1 -- 13
	end -- 13
	local startLine = __TS__Number(____input_startLine_0) -- 13
	local ____temp_1 -- 14
	if input.endLine == nil then -- 14
		____temp_1 = nil -- 14
	else -- 14
		____temp_1 = __TS__Number(input.endLine) -- 14
	end -- 14
	local endLine = ____temp_1 -- 14
	local effectiveEndLine = endLine or startLine + AgentConfig.AGENT_LIMITS.readFileDefaultLimit - 1 -- 15
	local clippedAfterCompression = false -- 16
	if context.workflow.resumeNarrowReadMode == true and startLine > 0 and effectiveEndLine >= startLine and effectiveEndLine - startLine + 1 > 160 then -- 16
		endLine = startLine + 159 -- 23
		clippedAfterCompression = true -- 24
	end -- 24
	local path = type(input.path) == "string" and input.path or "" -- 26
	if __TS__StringTrim(path) == "" then -- 26
		return {success = false, message = "missing path"} -- 28
	end -- 28
	local output = Tools.readFile( -- 30
		context.workingDir, -- 31
		path, -- 32
		startLine, -- 33
		endLine, -- 34
		context.useChineseResponse and "zh" or "en" -- 35
	) -- 35
	if clippedAfterCompression and endLine ~= nil and output.success == true then -- 35
		output.clipped = true -- 38
		output.message = context.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 39
	end -- 39
	return output -- 43
end -- 12
local function readFile(context, input) -- 46
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 46
		if __TS__ArrayIsArray(input.reads) then -- 46
			local reads = input.reads -- 48
			local results = {} -- 49
			local succeeded = 0 -- 50
			do -- 50
				local i = 0 -- 51
				while i < #reads do -- 51
					local item = reads[i + 1] -- 52
					local output = readOneFile(context, item) -- 53
					if output.success == true then -- 53
						succeeded = succeeded + 1 -- 54
					end -- 54
					results[#results + 1] = __TS__ObjectAssign({index = i, path = item.path}, output) -- 55
					i = i + 1 -- 51
				end -- 51
			end -- 51
			return ____awaiter_resolve(nil, {output = { -- 51
				success = succeeded == #results, -- 58
				partial = succeeded > 0 and succeeded < #results, -- 59
				mode = "batch", -- 60
				readCount = #results, -- 61
				succeededReadCount = succeeded, -- 62
				failedReadCount = #results - succeeded, -- 63
				results = results -- 64
			}}) -- 64
		end -- 64
		return ____awaiter_resolve( -- 64
			nil, -- 64
			{output = readOneFile(context, input)} -- 67
		) -- 67
	end) -- 67
end -- 46
local function grepFiles(context, input) -- 70
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 70
		local ____Tools_searchFiles_17 = Tools.searchFiles -- 71
		local ____context_workingDir_8 = context.workingDir -- 72
		local ____temp_9 = input.path or "" -- 73
		local ____temp_10 = context.useChineseResponse and "zh" or "en" -- 74
		local ____temp_11 = input.pattern or "" -- 75
		local ____input_globs_12 = input.globs -- 76
		local ____input_useRegex_13 = input.useRegex -- 77
		local ____input_caseSensitive_14 = input.caseSensitive -- 78
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_15 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 80
		local ____math_max_4 = math.max -- 81
		local ____math_floor_3 = math.floor -- 81
		local ____input_limit_2 = input.limit -- 81
		if ____input_limit_2 == nil then -- 81
			____input_limit_2 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 81
		end -- 81
		local ____math_max_4_result_16 = ____math_max_4( -- 81
			1, -- 81
			____math_floor_3(__TS__Number(____input_limit_2)) -- 81
		) -- 81
		local ____math_max_7 = math.max -- 82
		local ____math_floor_6 = math.floor -- 82
		local ____input_offset_5 = input.offset -- 82
		if ____input_offset_5 == nil then -- 82
			____input_offset_5 = 0 -- 82
		end -- 82
		local output = __TS__Await(____Tools_searchFiles_17({ -- 71
			workDir = ____context_workingDir_8, -- 72
			path = ____temp_9, -- 73
			docLanguage = ____temp_10, -- 74
			pattern = ____temp_11, -- 75
			globs = ____input_globs_12, -- 76
			useRegex = ____input_useRegex_13, -- 77
			caseSensitive = ____input_caseSensitive_14, -- 78
			includeContent = true, -- 79
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_15, -- 80
			limit = ____math_max_4_result_16, -- 81
			offset = ____math_max_7( -- 82
				0, -- 82
				____math_floor_6(__TS__Number(____input_offset_5)) -- 82
			), -- 82
			groupByFile = input.groupByFile == true -- 83
		})) -- 83
		return ____awaiter_resolve(nil, {output = output}) -- 83
	end) -- 83
end -- 70
local function globFiles(context, input) -- 88
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 88
		local ____Tools_listFiles_24 = Tools.listFiles -- 89
		local ____context_workingDir_21 = context.workingDir -- 90
		local ____temp_22 = input.path or "" -- 91
		local ____input_globs_23 = input.globs -- 92
		local ____math_max_20 = math.max -- 93
		local ____math_floor_19 = math.floor -- 93
		local ____input_maxEntries_18 = input.maxEntries -- 93
		if ____input_maxEntries_18 == nil then -- 93
			____input_maxEntries_18 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 93
		end -- 93
		local output = ____Tools_listFiles_24({ -- 89
			workDir = ____context_workingDir_21, -- 90
			path = ____temp_22, -- 91
			globs = ____input_globs_23, -- 92
			maxEntries = ____math_max_20( -- 93
				1, -- 93
				____math_floor_19(__TS__Number(____input_maxEntries_18)) -- 93
			), -- 93
			preferSourceVariants = false -- 93
		}) -- 93
		return ____awaiter_resolve(nil, {output = output}) -- 93
	end) -- 93
end -- 88
local function searchDoraDoc(context, input) -- 98
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 98
		context.workflow.apiSearchesSinceBuild = (context.workflow.apiSearchesSinceBuild or 0) + 1 -- 99
		local ____Tools_searchDoraDoc_33 = Tools.searchDoraDoc -- 100
		local ____temp_29 = input.pattern or "" -- 101
		local ____temp_30 = input.docType or "dora-api" -- 102
		local ____temp_31 = context.useChineseResponse and "zh" or "en" -- 103
		local ____temp_32 = input.programmingLanguage or (input.docType == "godot-api" and "gdscript" or "ts") -- 104
		local ____math_min_28 = math.min -- 105
		local ____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27 = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax -- 105
		local ____math_max_26 = math.max -- 105
		local ____input_limit_25 = input.limit -- 105
		if ____input_limit_25 == nil then -- 105
			____input_limit_25 = 8 -- 105
		end -- 105
		local output = __TS__Await(____Tools_searchDoraDoc_33({ -- 100
			pattern = ____temp_29, -- 101
			docType = ____temp_30, -- 102
			docLanguage = ____temp_31, -- 103
			programmingLanguage = ____temp_32, -- 104
			limit = ____math_min_28( -- 105
				____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27, -- 105
				____math_max_26( -- 105
					1, -- 105
					__TS__Number(____input_limit_25) -- 105
				) -- 105
			), -- 105
			useRegex = input.useRegex, -- 106
			caseSensitive = false, -- 107
			includeContent = true, -- 108
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 109
		})) -- 109
		return ____awaiter_resolve(nil, {output = output}) -- 109
	end) -- 109
end -- 98
local function build(context, input) -- 114
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 114
		local paths = input.paths -- 115
		local results = {} -- 116
		local rawResults = {} -- 117
		local callFailureMessages = {} -- 118
		local succeeded = 0 -- 119
		do -- 119
			local i = 0 -- 120
			while i < #paths do -- 120
				local result -- 121
				local ____try = __TS__AsyncAwaiter(function() -- 121
					result = __TS__Await(Tools.build({ -- 123
						workDir = context.workingDir, -- 124
						path = paths[i + 1], -- 125
						isCancelled = function() return context.cancellation:isCancelled() end -- 126
					})) -- 126
				end) -- 126
				____try = ____try.catch( -- 126
					____try, -- 126
					function(____, err) -- 126
						return __TS__AsyncAwaiter(function() -- 126
							result = { -- 129
								success = false, -- 129
								failureKind = "tool", -- 129
								message = tostring(err) -- 129
							} -- 129
						end) -- 129
					end -- 129
				) -- 129
				__TS__Await(____try) -- 122
				if result.success then -- 122
					succeeded = succeeded + 1 -- 131
				else -- 131
					local ____temp_36 = result.failureKind == "tool" -- 134
					if ____temp_36 then -- 134
						local ____opt_34 = result.messages -- 134
						____temp_36 = (____opt_34 and #____opt_34 or 0) == 0 -- 134
					end -- 134
					if ____temp_36 then -- 134
						callFailureMessages[#callFailureMessages + 1] = result.message -- 134
					end -- 134
				end -- 134
				rawResults[#rawResults + 1] = result -- 135
				results[#results + 1] = __TS__ObjectAssign({index = i, path = paths[i + 1]}, result) -- 136
				if context.cancellation:isCancelled() then -- 136
					break -- 137
				end -- 137
				i = i + 1 -- 120
			end -- 120
		end -- 120
		local output = { -- 139
			success = succeeded == #paths, -- 140
			partial = succeeded > 0 and succeeded < #paths, -- 141
			mode = "batch", -- 142
			requestedBuildCount = #paths, -- 143
			buildCount = #results, -- 144
			succeededBuildCount = succeeded, -- 145
			failedBuildCount = #results - succeeded, -- 146
			skippedBuildCount = #paths - #results, -- 147
			results = results -- 148
		} -- 148
		context.workflow.unbuiltEdits = false -- 152
		context.workflow.editsSinceBuild = 0 -- 153
		context.workflow.editedPathsSinceBuild = {} -- 154
		context.workflow.hasBuilt = true -- 155
		context.workflow.lastBuildSucceeded = output.success == true -- 156
		if output.success == true and context.workflow.freshProjectBuildPending == true then -- 156
			context.workflow.freshProjectBuildPending = false -- 158
		end -- 158
		context.workflow.apiSearchesSinceBuild = 0 -- 160
		context.workflow.buildRepairPending = false -- 161
		if output.success ~= true then -- 161
			do -- 161
				local r = 0 -- 163
				while r < #rawResults do -- 163
					local messages = rawResults[r + 1].messages -- 164
					do -- 164
						local i = 0 -- 165
						while i < (messages and #messages or 0) do -- 165
							if messages[i + 1].success == false and messages[i + 1].file ~= "" then -- 165
								context.workflow.buildRepairPending = true -- 167
								break -- 168
							end -- 168
							i = i + 1 -- 165
						end -- 165
					end -- 165
					r = r + 1 -- 163
				end -- 163
			end -- 163
		end -- 163
		if output.success == true and context.workflow.failedTestNeedsBuild == true and context.workflow.failedTestHasSourceEdit == true then -- 163
			context.workflow.failedTestNeedsBuild = false -- 174
			context.workflow.failedTestHasSourceEdit = false -- 175
		end -- 175
		if #callFailureMessages > 0 then -- 175
			error(table.concat(callFailureMessages, "; ")) -- 178
		end -- 178
		return ____awaiter_resolve(nil, {output = output}) -- 178
	end) -- 178
end -- 114
local function fetchUrl(context, input) -- 183
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 183
		local output = __TS__Await(Tools.fetchUrl({ -- 184
			workDir = context.workingDir, -- 185
			url = type(input.url) == "string" and input.url or "", -- 186
			target = type(input.target) == "string" and input.target or "", -- 187
			isCancelled = function() return context.cancellation:isCancelled() end, -- 188
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 189
		})) -- 189
		return ____awaiter_resolve(nil, {output = output}) -- 189
	end) -- 189
end -- 183
local function updateDeterministicTestState(context, output) -- 194
	local deterministicFailure = false -- 195
	local deterministicPass = false -- 196
	local outputLines = __TS__StringSplit(output, "\n") -- 197
	do -- 197
		local i = 0 -- 198
		while i < #outputLines and not deterministicFailure do -- 198
			local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 199
			if line == "passed" then -- 199
				deterministicPass = true -- 200
			end -- 200
			if line == "failed" then -- 200
				deterministicFailure = true -- 202
				break -- 203
			end -- 203
			local searchFrom = 0 -- 205
			while searchFrom < #line do -- 205
				local failedIndex = (string.find( -- 207
					line, -- 207
					"failed", -- 207
					math.max(searchFrom + 1, 1), -- 207
					true -- 207
				) or 0) - 1 -- 207
				if failedIndex < 0 then -- 207
					break -- 208
				end -- 208
				local after = failedIndex + #"failed" -- 209
				while after < #line do -- 209
					local ch = __TS__StringSlice(line, after, after + 1) -- 211
					if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 211
						break -- 212
					end -- 212
					after = after + 1 -- 213
				end -- 213
				local afterEnd = after -- 215
				while afterEnd < #line do -- 215
					local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 217
					if ch < "0" or ch > "9" then -- 217
						break -- 218
					end -- 218
					afterEnd = afterEnd + 1 -- 219
				end -- 219
				local count -- 221
				if afterEnd > after then -- 221
					count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 223
				else -- 223
					local before = failedIndex - 1 -- 225
					while before >= 0 do -- 225
						local ch = __TS__StringSlice(line, before, before + 1) -- 227
						if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 227
							break -- 228
						end -- 228
						before = before - 1 -- 229
					end -- 229
					local beforeEnd = before + 1 -- 231
					while before >= 0 do -- 231
						local ch = __TS__StringSlice(line, before, before + 1) -- 233
						if ch < "0" or ch > "9" then -- 233
							break -- 234
						end -- 234
						before = before - 1 -- 235
					end -- 235
					if beforeEnd > before + 1 then -- 235
						count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 237
					end -- 237
				end -- 237
				if count ~= nil and count > 0 then -- 237
					deterministicFailure = true -- 240
					break -- 241
				end -- 241
				searchFrom = failedIndex + #"failed" -- 243
			end -- 243
			i = i + 1 -- 198
		end -- 198
	end -- 198
	if deterministicFailure then -- 198
		context.workflow.failedTestNeedsBuild = true -- 247
		context.workflow.failedTestHasSourceEdit = false -- 248
	elseif deterministicPass then -- 248
		context.workflow.failedTestNeedsBuild = false -- 250
		context.workflow.failedTestHasSourceEdit = false -- 251
	end -- 251
end -- 194
local function executeCommand(context, input) -- 255
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 255
		local mode = type(input.mode) == "string" and input.mode or "" -- 256
		local output = __TS__Await(Tools.executeCommand({ -- 257
			workDir = context.workingDir, -- 258
			docLanguage = context.useChineseResponse and "zh" or "en", -- 259
			taskId = context.taskId, -- 260
			mode = mode, -- 261
			code = type(input.code) == "string" and input.code or nil, -- 262
			command = type(input.command) == "string" and input.command or nil, -- 263
			cwd = type(input.cwd) == "string" and input.cwd or nil, -- 264
			timeoutSeconds = type(input.timeoutSeconds) == "number" and input.timeoutSeconds or nil, -- 265
			isCancelled = function() return context.cancellation:isCancelled() end, -- 266
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 267
		})) -- 267
		if output.success and mode == "lua" then -- 267
			updateDeterministicTestState(context, output.output) -- 270
		end -- 270
		return ____awaiter_resolve(nil, {output = output}) -- 270
	end) -- 270
end -- 255
local function editFile(context, input) -- 292
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 292
		local operations = getAgentFileEditInputs(input) -- 293
		local isBatch = __TS__ArrayIsArray(input.edits) -- 294
		if #operations == 0 then -- 294
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing edit operations"}}) -- 294
		end -- 294
		local staged = {} -- 296
		local results = {} -- 297
		local successfulOperations = {} -- 298
		local function failOperation(index, path, code, message) -- 299
			results[#results + 1] = { -- 300
				index = index, -- 300
				path = path, -- 300
				success = false, -- 300
				code = code, -- 300
				message = message -- 300
			} -- 300
		end -- 299
		do -- 299
			local i = 0 -- 303
			while i < #operations do -- 303
				do -- 303
					local operation = operations[i + 1] -- 304
					local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 305
					if path == "" then -- 305
						failOperation(i, path, "INVALID_EDIT", "path is required") -- 307
						goto __continue64 -- 308
					end -- 308
					if operation.oldStr == operation.newStr then -- 308
						failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ") -- 311
						goto __continue64 -- 312
					end -- 312
					local stagedIndex = -1 -- 314
					do -- 314
						local j = 0 -- 315
						while j < #staged do -- 315
							if staged[j + 1].path == path then -- 315
								stagedIndex = j -- 317
								break -- 318
							end -- 318
							j = j + 1 -- 315
						end -- 315
					end -- 315
					if stagedIndex < 0 then -- 315
						local targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path) -- 322
						if not targetState.success then -- 322
							failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message) -- 324
							goto __continue64 -- 325
						end -- 325
						staged[#staged + 1] = { -- 327
							path = path, -- 328
							initialExists = targetState.exists, -- 329
							exists = targetState.exists, -- 330
							content = targetState.content, -- 331
							changed = false -- 332
						} -- 332
						stagedIndex = #staged - 1 -- 334
					end -- 334
					local target = staged[stagedIndex + 1] -- 336
					local guardDenial = getAgentFileEditPlanGuardDenial(context, operation) -- 337
					if guardDenial ~= nil then -- 337
						failOperation(i, path, guardDenial.code, guardDenial.message) -- 339
						goto __continue64 -- 340
					end -- 340
					local mode = "" -- 342
					if operation.oldStr == "" then -- 342
						if target.exists and AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr) then -- 342
							failOperation(i, path, "DUPLICATE_WHOLE_FILE", "rewrite rejected: the complete current file appears more than once in the replacement for " .. path) -- 345
							goto __continue64 -- 346
						end -- 346
						mode = target.exists and "overwrite" or "create" -- 348
						target.exists = true -- 349
						target.content = operation.newStr -- 350
					else -- 350
						if not target.exists then -- 350
							failOperation(i, path, "FILE_NOT_FOUND", ("read file failed: " .. path) .. " does not exist; use old_str=\"\" to create it earlier in the batch") -- 353
							goto __continue64 -- 354
						end -- 354
						local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content) -- 356
						local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr) -- 357
						local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr) -- 358
						local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 359
						if occurrences == 0 then -- 359
							local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 361
							if not indentTolerant.success then -- 361
								failOperation(i, path, "TEXT_NOT_FOUND", indentTolerant.message) -- 363
								goto __continue64 -- 364
							end -- 364
							target.content = indentTolerant.content -- 366
							mode = "replace_indent_tolerant" -- 367
						else -- 367
							if occurrences > 1 then -- 367
								failOperation( -- 370
									i, -- 370
									path, -- 370
									"AMBIGUOUS_MATCH", -- 370
									((("old_str appears " .. tostring(occurrences)) .. " times in ") .. path) .. ". Provide more context to identify one target." -- 370
								) -- 370
								goto __continue64 -- 371
							end -- 371
							target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 373
							mode = "replace" -- 374
						end -- 374
					end -- 374
					target.changed = true -- 377
					results[#results + 1] = {index = i, path = path, success = true, mode = mode} -- 378
					successfulOperations[#successfulOperations + 1] = operation -- 379
				end -- 379
				::__continue64:: -- 379
				i = i + 1 -- 303
			end -- 303
		end -- 303
		local changedTargets = __TS__ArrayFilter( -- 382
			staged, -- 382
			function(____, item) return item.changed end -- 382
		) -- 382
		if #changedTargets == 0 then -- 382
			local firstFailure = results[1] -- 384
			return ____awaiter_resolve(nil, {output = isBatch and ({ -- 384
				success = false, -- 387
				changed = false, -- 388
				mode = "batch", -- 389
				operationCount = #operations, -- 390
				succeededOperationCount = 0, -- 391
				failedOperationCount = #results, -- 392
				results = results, -- 393
				actualSaved = false -- 394
			}) or ({success = false, code = firstFailure and firstFailure.code, message = firstFailure and firstFailure.message or "edit failed", actualSaved = false})}) -- 394
		end -- 394
		local changes = __TS__ArrayMap( -- 404
			changedTargets, -- 404
			function(____, item) return {path = item.path, op = item.initialExists and "write" or "create", content = item.content} end -- 404
		) -- 404
		local applyRes = Tools.applyFileChanges( -- 409
			context.taskId, -- 409
			context.workingDir, -- 409
			changes, -- 409
			{ -- 409
				summary = isBatch and ((((("batch edit " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files via edit_file" or ((tostring(results[1].mode) .. " ") .. changedTargets[1].path) .. " via edit_file", -- 410
				toolName = "edit_file" -- 413
			} -- 413
		) -- 413
		if not applyRes.success then -- 413
			return ____awaiter_resolve( -- 413
				nil, -- 413
				{output = __TS__ObjectAssign({success = false, message = ((isBatch and "batch edit" or "write file") .. " failed: ") .. applyRes.message, actualSaved = false}, isBatch and ({results = results}) or ({}))} -- 416
			) -- 416
		end -- 416
		local files = __TS__ArrayMap( -- 419
			changes, -- 419
			function(____, change) return {path = change.path, op = change.op} end -- 419
		) -- 419
		local output -- 420
		if not isBatch then -- 420
			output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[1].path, { -- 422
				success = true, -- 423
				changed = true, -- 424
				mode = results[1].mode, -- 425
				checkpointId = applyRes.checkpointId, -- 426
				checkpointSeq = applyRes.checkpointSeq, -- 427
				files = files -- 428
			}) -- 428
		else -- 428
			local totalCharacters = 0 -- 431
			local actualSaved = true -- 432
			for ____, item in ipairs(changedTargets) do -- 433
				local current = Tools.readFileRaw(context.workingDir, item.path) -- 434
				if not current.success or current.content ~= item.content then -- 434
					actualSaved = false -- 435
				end -- 435
				if current.success then -- 435
					totalCharacters = totalCharacters + #current.content -- 436
				end -- 436
			end -- 436
			output = { -- 438
				success = true, -- 439
				changed = true, -- 440
				mode = "batch", -- 441
				operationCount = #operations, -- 442
				succeededOperationCount = #successfulOperations, -- 443
				failedOperationCount = #operations - #successfulOperations, -- 444
				partial = #successfulOperations < #operations, -- 445
				fileCount = #changedTargets, -- 446
				checkpointId = applyRes.checkpointId, -- 447
				checkpointSeq = applyRes.checkpointSeq, -- 448
				files = files, -- 449
				results = results, -- 450
				actualSaved = actualSaved, -- 451
				actualSavedCharacters = totalCharacters, -- 452
				currentFileExists = actualSaved, -- 453
				currentCharacters = totalCharacters, -- 454
				currentState = actualSaved and ((((("saved " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files" or "one or more batch file states could not be verified after commit" -- 455
			} -- 455
		end -- 455
		local authoredOperations = 0 -- 461
		local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 462
		for ____, operation in ipairs(successfulOperations) do -- 463
			do -- 463
				local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 464
				if AgentRuntimePolicy.isAgentInternalDocumentPath(path) then -- 464
					goto __continue92 -- 465
				end -- 465
				authoredOperations = authoredOperations + 1 -- 466
				if __TS__ArrayIndexOf(editedPaths, path) < 0 then -- 466
					editedPaths[#editedPaths + 1] = path -- 467
				end -- 467
			end -- 467
			::__continue92:: -- 467
		end -- 467
		if authoredOperations > 0 then -- 467
			context.workflow.unbuiltEdits = true -- 470
			context.workflow.lastBuildSucceeded = false -- 471
			if context.workflow.failedTestNeedsBuild == true then -- 471
				context.workflow.failedTestHasSourceEdit = true -- 472
			end -- 472
			context.workflow.editedPathsSinceBuild = editedPaths -- 473
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + authoredOperations -- 474
		end -- 474
		return ____awaiter_resolve(nil, {output = output}) -- 474
	end) -- 474
end -- 292
local function deleteFile(context, input) -- 479
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 479
		local targetFile = type(input.target_file) == "string" and input.target_file or "" -- 480
		if __TS__StringTrim(targetFile) == "" then -- 480
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing target_file"}}) -- 480
		end -- 480
		local normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile) -- 482
		local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 483
		local result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 484
		if not result.success then -- 484
			return ____awaiter_resolve(nil, {output = result}) -- 484
		end -- 484
		if not isInternalDocumentEdit then -- 484
			context.workflow.unbuiltEdits = true -- 490
			context.workflow.lastBuildSucceeded = false -- 491
			if context.workflow.failedTestNeedsBuild == true then -- 491
				context.workflow.failedTestHasSourceEdit = true -- 492
			end -- 492
			local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 493
			if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 493
				editedPaths[#editedPaths + 1] = normalizedTargetFile -- 494
			end -- 494
			context.workflow.editedPathsSinceBuild = editedPaths -- 495
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 496
		end -- 496
		local ____result_checkpointed_44 = result.checkpointed -- 503
		local ____result_reversible_45 = result.reversible -- 504
		local ____result_binary_46 = result.binary -- 505
		local ____temp_47 = result.checkpointed and result.checkpointId or nil -- 506
		local ____temp_48 = result.checkpointed and result.checkpointSeq or nil -- 507
		local ____result_checkpointed_43 -- 508
		if result.checkpointed then -- 508
			____result_checkpointed_43 = nil -- 508
		else -- 508
			____result_checkpointed_43 = result.message -- 508
		end -- 508
		return ____awaiter_resolve(nil, {output = { -- 508
			success = true, -- 500
			changed = true, -- 501
			mode = "delete", -- 502
			checkpointed = ____result_checkpointed_44, -- 503
			reversible = ____result_reversible_45, -- 504
			binary = ____result_binary_46, -- 505
			checkpointId = ____temp_47, -- 506
			checkpointSeq = ____temp_48, -- 507
			message = ____result_checkpointed_43, -- 508
			files = {{path = targetFile, op = "delete"}} -- 509
		}}) -- 509
	end) -- 509
end -- 479
local function askUser(context, input) -- 514
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 514
		if context.services.publishQuestionnaire == nil then -- 514
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user is not available in this runtime"}}) -- 514
		end -- 514
		if context.sessionId == nil or context.sessionId <= 0 then -- 514
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user requires a session"}}) -- 514
		end -- 514
		local normalized = normalizeQuestionnaire(input) -- 521
		if not normalized.success then -- 521
			return ____awaiter_resolve(nil, {output = normalized}) -- 521
		end -- 521
		local result = __TS__Await(context.services:publishQuestionnaire({sessionId = context.sessionId, taskId = context.taskId, step = context.step, schema = normalized.schema})) -- 523
		if not result.success then -- 523
			return ____awaiter_resolve(nil, {output = result}) -- 523
		end -- 523
		context.workflow.waitingQuestionnaireId = result.questionnaireId -- 530
		return ____awaiter_resolve(nil, {output = {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}, control = {waitForUser = true, questionnaireId = result.questionnaireId}}) -- 530
	end) -- 530
end -- 514
local function spawnSubAgent(context, input) -- 537
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 537
		if context.services.spawnSubAgent == nil then -- 537
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent is not available in this runtime"}}) -- 537
		end -- 537
		if context.sessionId == nil or context.sessionId <= 0 then -- 537
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent requires a parent session"}}) -- 537
		end -- 537
		local filesHint = __TS__ArrayIsArray(input.filesHint) and __TS__ArrayFilter( -- 544
			input.filesHint, -- 545
			function(____, item) return type(item) == "string" end -- 545
		) or nil -- 545
		local result = __TS__Await(context.services:spawnSubAgent({ -- 547
			parentSessionId = context.sessionId, -- 548
			projectRoot = context.workingDir, -- 549
			title = type(input.title) == "string" and input.title or "Sub", -- 550
			prompt = type(input.prompt) == "string" and input.prompt or "", -- 551
			expectedOutput = type(input.expectedOutput) == "string" and input.expectedOutput or nil, -- 552
			filesHint = filesHint, -- 553
			disabledAgentTools = context.disabledAgentTools -- 554
		})) -- 554
		if not result.success then -- 554
			return ____awaiter_resolve(nil, {output = result}) -- 554
		end -- 554
		context.workflow.hasSpawnedSubAgentThisTask = true -- 557
		return ____awaiter_resolve(nil, {output = { -- 557
			success = true, -- 560
			sessionId = result.sessionId, -- 561
			taskId = result.taskId, -- 562
			title = result.title, -- 563
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 564
		}, control = {spawnedSubAgent = true}}) -- 564
	end) -- 564
end -- 537
local function listSubAgents(context, input) -- 570
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 570
		if context.services.listSubAgents == nil then -- 570
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents is not available in this runtime"}}) -- 570
		end -- 570
		if context.sessionId == nil or context.sessionId <= 0 then -- 570
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents requires a current session"}}) -- 570
		end -- 570
		local result = __TS__Await(context.services:listSubAgents({ -- 577
			sessionId = context.sessionId, -- 578
			projectRoot = context.workingDir, -- 579
			status = type(input.status) == "string" and input.status or nil, -- 580
			limit = type(input.limit) == "number" and input.limit or nil, -- 581
			offset = type(input.offset) == "number" and input.offset or nil, -- 582
			query = type(input.query) == "string" and input.query or nil -- 583
		})) -- 583
		return ____awaiter_resolve(nil, {output = result}) -- 583
	end) -- 583
end -- 570
local function finish(_context, input) -- 588
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 588
		local message = type(input.message) == "string" and __TS__StringTrim(input.message) or "" -- 589
		return ____awaiter_resolve( -- 589
			nil, -- 589
			{ -- 590
				output = {success = true, message = message}, -- 591
				control = { -- 592
					concludeTask = true, -- 593
					finalMessage = message, -- 594
					completion = AgentUtils.normalizeAgentCompletionReport(input) -- 595
				} -- 595
			} -- 595
		) -- 595
	end) -- 595
end -- 588
local function analyzeImageHandler(context, input) -- 600
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 600
		local visionContext = context.visionTaskContext or "" -- 601
		if type(input.context) == "string" and __TS__StringTrim(input.context) ~= "" then -- 601
			visionContext = visionContext == "" and input.context or (visionContext .. "\n\n") .. input.context -- 603
		end -- 603
		return ____awaiter_resolve( -- 603
			nil, -- 603
			{output = __TS__Await(analyzeImage({ -- 605
				workingDir = context.workingDir, -- 606
				taskId = context.taskId, -- 607
				sessionId = context.sessionId, -- 608
				binding = context.visionBinding, -- 609
				paths = input.paths, -- 610
				question = input.question, -- 611
				criteria = input.criteria, -- 612
				context = visionContext, -- 613
				isCancelled = function() return context.cancellation:isCancelled() end -- 614
			}))} -- 614
		) -- 614
	end) -- 614
end -- 600
____exports.AGENT_TOOL_HANDLERS = { -- 618
	read_file = readFile, -- 619
	grep_files = grepFiles, -- 620
	glob_files = globFiles, -- 621
	search_dora_doc = searchDoraDoc, -- 622
	build = build, -- 623
	fetch_url = fetchUrl, -- 624
	execute_command = executeCommand, -- 625
	analyze_image = analyzeImageHandler, -- 626
	edit_file = editFile, -- 627
	delete_file = deleteFile, -- 628
	ask_user = askUser, -- 629
	spawn_sub_agent = spawnSubAgent, -- 630
	list_sub_agents = listSubAgents, -- 631
	finish = finish -- 632
} -- 632
return ____exports -- 632