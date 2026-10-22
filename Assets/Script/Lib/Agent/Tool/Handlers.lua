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
		local ____temp_32 = input.programmingLanguage or "ts" -- 104
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
				elseif result.failureKind == "tool" then -- 131
					callFailureMessages[#callFailureMessages + 1] = result.message -- 132
				end -- 132
				rawResults[#rawResults + 1] = result -- 133
				results[#results + 1] = __TS__ObjectAssign({index = i, path = paths[i + 1]}, result) -- 134
				if context.cancellation:isCancelled() then -- 134
					break -- 135
				end -- 135
				i = i + 1 -- 120
			end -- 120
		end -- 120
		local output = { -- 137
			success = succeeded == #paths, -- 138
			partial = succeeded > 0 and succeeded < #paths, -- 139
			mode = "batch", -- 140
			requestedBuildCount = #paths, -- 141
			buildCount = #results, -- 142
			succeededBuildCount = succeeded, -- 143
			failedBuildCount = #results - succeeded, -- 144
			skippedBuildCount = #paths - #results, -- 145
			results = results -- 146
		} -- 146
		context.workflow.unbuiltEdits = false -- 150
		context.workflow.editsSinceBuild = 0 -- 151
		context.workflow.editedPathsSinceBuild = {} -- 152
		context.workflow.hasBuilt = true -- 153
		context.workflow.lastBuildSucceeded = output.success == true -- 154
		if output.success == true and context.workflow.freshProjectBuildPending == true then -- 154
			context.workflow.freshProjectBuildPending = false -- 156
		end -- 156
		context.workflow.apiSearchesSinceBuild = 0 -- 158
		context.workflow.buildRepairPending = false -- 159
		if output.success ~= true then -- 159
			do -- 159
				local r = 0 -- 161
				while r < #rawResults do -- 161
					local messages = rawResults[r + 1].messages -- 162
					do -- 162
						local i = 0 -- 163
						while i < (messages and #messages or 0) do -- 163
							if messages[i + 1].success == false and messages[i + 1].file ~= "" then -- 163
								context.workflow.buildRepairPending = true -- 165
								break -- 166
							end -- 166
							i = i + 1 -- 163
						end -- 163
					end -- 163
					r = r + 1 -- 161
				end -- 161
			end -- 161
		end -- 161
		if output.success == true and context.workflow.failedTestNeedsBuild == true and context.workflow.failedTestHasSourceEdit == true then -- 161
			context.workflow.failedTestNeedsBuild = false -- 172
			context.workflow.failedTestHasSourceEdit = false -- 173
		end -- 173
		if #callFailureMessages > 0 then -- 173
			error(table.concat(callFailureMessages, "; ")) -- 176
		end -- 176
		return ____awaiter_resolve(nil, {output = output}) -- 176
	end) -- 176
end -- 114
local function fetchUrl(context, input) -- 181
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 181
		local output = __TS__Await(Tools.fetchUrl({ -- 182
			workDir = context.workingDir, -- 183
			url = type(input.url) == "string" and input.url or "", -- 184
			target = type(input.target) == "string" and input.target or "", -- 185
			isCancelled = function() return context.cancellation:isCancelled() end, -- 186
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 187
		})) -- 187
		return ____awaiter_resolve(nil, {output = output}) -- 187
	end) -- 187
end -- 181
local function updateDeterministicTestState(context, output) -- 192
	local deterministicFailure = false -- 193
	local deterministicPass = false -- 194
	local outputLines = __TS__StringSplit(output, "\n") -- 195
	do -- 195
		local i = 0 -- 196
		while i < #outputLines and not deterministicFailure do -- 196
			local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 197
			if line == "passed" then -- 197
				deterministicPass = true -- 198
			end -- 198
			if line == "failed" then -- 198
				deterministicFailure = true -- 200
				break -- 201
			end -- 201
			local searchFrom = 0 -- 203
			while searchFrom < #line do -- 203
				local failedIndex = (string.find( -- 205
					line, -- 205
					"failed", -- 205
					math.max(searchFrom + 1, 1), -- 205
					true -- 205
				) or 0) - 1 -- 205
				if failedIndex < 0 then -- 205
					break -- 206
				end -- 206
				local after = failedIndex + #"failed" -- 207
				while after < #line do -- 207
					local ch = __TS__StringSlice(line, after, after + 1) -- 209
					if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 209
						break -- 210
					end -- 210
					after = after + 1 -- 211
				end -- 211
				local afterEnd = after -- 213
				while afterEnd < #line do -- 213
					local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 215
					if ch < "0" or ch > "9" then -- 215
						break -- 216
					end -- 216
					afterEnd = afterEnd + 1 -- 217
				end -- 217
				local count -- 219
				if afterEnd > after then -- 219
					count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 221
				else -- 221
					local before = failedIndex - 1 -- 223
					while before >= 0 do -- 223
						local ch = __TS__StringSlice(line, before, before + 1) -- 225
						if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 225
							break -- 226
						end -- 226
						before = before - 1 -- 227
					end -- 227
					local beforeEnd = before + 1 -- 229
					while before >= 0 do -- 229
						local ch = __TS__StringSlice(line, before, before + 1) -- 231
						if ch < "0" or ch > "9" then -- 231
							break -- 232
						end -- 232
						before = before - 1 -- 233
					end -- 233
					if beforeEnd > before + 1 then -- 233
						count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 235
					end -- 235
				end -- 235
				if count ~= nil and count > 0 then -- 235
					deterministicFailure = true -- 238
					break -- 239
				end -- 239
				searchFrom = failedIndex + #"failed" -- 241
			end -- 241
			i = i + 1 -- 196
		end -- 196
	end -- 196
	if deterministicFailure then -- 196
		context.workflow.failedTestNeedsBuild = true -- 245
		context.workflow.failedTestHasSourceEdit = false -- 246
	elseif deterministicPass then -- 246
		context.workflow.failedTestNeedsBuild = false -- 248
		context.workflow.failedTestHasSourceEdit = false -- 249
	end -- 249
end -- 192
local function executeCommand(context, input) -- 253
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 253
		local mode = type(input.mode) == "string" and input.mode or "" -- 254
		local output = __TS__Await(Tools.executeCommand({ -- 255
			workDir = context.workingDir, -- 256
			docLanguage = context.useChineseResponse and "zh" or "en", -- 257
			taskId = context.taskId, -- 258
			mode = mode, -- 259
			code = type(input.code) == "string" and input.code or nil, -- 260
			command = type(input.command) == "string" and input.command or nil, -- 261
			cwd = type(input.cwd) == "string" and input.cwd or nil, -- 262
			timeoutSeconds = type(input.timeoutSeconds) == "number" and input.timeoutSeconds or nil, -- 263
			isCancelled = function() return context.cancellation:isCancelled() end, -- 264
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 265
		})) -- 265
		if output.success and mode == "lua" then -- 265
			updateDeterministicTestState(context, output.output) -- 268
		end -- 268
		return ____awaiter_resolve(nil, {output = output}) -- 268
	end) -- 268
end -- 253
local function editFile(context, input) -- 290
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 290
		local operations = getAgentFileEditInputs(input) -- 291
		local isBatch = __TS__ArrayIsArray(input.edits) -- 292
		if #operations == 0 then -- 292
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing edit operations"}}) -- 292
		end -- 292
		local staged = {} -- 294
		local results = {} -- 295
		local successfulOperations = {} -- 296
		local function failOperation(index, path, code, message) -- 297
			results[#results + 1] = { -- 298
				index = index, -- 298
				path = path, -- 298
				success = false, -- 298
				code = code, -- 298
				message = message -- 298
			} -- 298
		end -- 297
		do -- 297
			local i = 0 -- 301
			while i < #operations do -- 301
				do -- 301
					local operation = operations[i + 1] -- 302
					local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 303
					if path == "" then -- 303
						failOperation(i, path, "INVALID_EDIT", "path is required") -- 305
						goto __continue64 -- 306
					end -- 306
					if operation.oldStr == operation.newStr then -- 306
						failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ") -- 309
						goto __continue64 -- 310
					end -- 310
					local stagedIndex = -1 -- 312
					do -- 312
						local j = 0 -- 313
						while j < #staged do -- 313
							if staged[j + 1].path == path then -- 313
								stagedIndex = j -- 315
								break -- 316
							end -- 316
							j = j + 1 -- 313
						end -- 313
					end -- 313
					if stagedIndex < 0 then -- 313
						local targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path) -- 320
						if not targetState.success then -- 320
							failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message) -- 322
							goto __continue64 -- 323
						end -- 323
						staged[#staged + 1] = { -- 325
							path = path, -- 326
							initialExists = targetState.exists, -- 327
							exists = targetState.exists, -- 328
							content = targetState.content, -- 329
							changed = false -- 330
						} -- 330
						stagedIndex = #staged - 1 -- 332
					end -- 332
					local target = staged[stagedIndex + 1] -- 334
					local guardDenial = getAgentFileEditPlanGuardDenial(context, operation) -- 335
					if guardDenial ~= nil then -- 335
						failOperation(i, path, guardDenial.code, guardDenial.message) -- 337
						goto __continue64 -- 338
					end -- 338
					local mode = "" -- 340
					if operation.oldStr == "" then -- 340
						if target.exists and AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr) then -- 340
							failOperation(i, path, "DUPLICATE_WHOLE_FILE", "rewrite rejected: the complete current file appears more than once in the replacement for " .. path) -- 343
							goto __continue64 -- 344
						end -- 344
						mode = target.exists and "overwrite" or "create" -- 346
						target.exists = true -- 347
						target.content = operation.newStr -- 348
					else -- 348
						if not target.exists then -- 348
							failOperation(i, path, "FILE_NOT_FOUND", ("read file failed: " .. path) .. " does not exist; use old_str=\"\" to create it earlier in the batch") -- 351
							goto __continue64 -- 352
						end -- 352
						local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content) -- 354
						local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr) -- 355
						local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr) -- 356
						local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 357
						if occurrences == 0 then -- 357
							local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 359
							if not indentTolerant.success then -- 359
								failOperation(i, path, "TEXT_NOT_FOUND", indentTolerant.message) -- 361
								goto __continue64 -- 362
							end -- 362
							target.content = indentTolerant.content -- 364
							mode = "replace_indent_tolerant" -- 365
						else -- 365
							if occurrences > 1 then -- 365
								failOperation( -- 368
									i, -- 368
									path, -- 368
									"AMBIGUOUS_MATCH", -- 368
									((("old_str appears " .. tostring(occurrences)) .. " times in ") .. path) .. ". Provide more context to identify one target." -- 368
								) -- 368
								goto __continue64 -- 369
							end -- 369
							target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 371
							mode = "replace" -- 372
						end -- 372
					end -- 372
					target.changed = true -- 375
					results[#results + 1] = {index = i, path = path, success = true, mode = mode} -- 376
					successfulOperations[#successfulOperations + 1] = operation -- 377
				end -- 377
				::__continue64:: -- 377
				i = i + 1 -- 301
			end -- 301
		end -- 301
		local changedTargets = __TS__ArrayFilter( -- 380
			staged, -- 380
			function(____, item) return item.changed end -- 380
		) -- 380
		if #changedTargets == 0 then -- 380
			local firstFailure = results[1] -- 382
			return ____awaiter_resolve(nil, {output = isBatch and ({ -- 382
				success = false, -- 385
				changed = false, -- 386
				mode = "batch", -- 387
				operationCount = #operations, -- 388
				succeededOperationCount = 0, -- 389
				failedOperationCount = #results, -- 390
				results = results, -- 391
				actualSaved = false -- 392
			}) or ({success = false, code = firstFailure and firstFailure.code, message = firstFailure and firstFailure.message or "edit failed", actualSaved = false})}) -- 392
		end -- 392
		local changes = __TS__ArrayMap( -- 402
			changedTargets, -- 402
			function(____, item) return {path = item.path, op = item.initialExists and "write" or "create", content = item.content} end -- 402
		) -- 402
		local applyRes = Tools.applyFileChanges( -- 407
			context.taskId, -- 407
			context.workingDir, -- 407
			changes, -- 407
			{ -- 407
				summary = isBatch and ((((("batch edit " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files via edit_file" or ((tostring(results[1].mode) .. " ") .. changedTargets[1].path) .. " via edit_file", -- 408
				toolName = "edit_file" -- 411
			} -- 411
		) -- 411
		if not applyRes.success then -- 411
			return ____awaiter_resolve( -- 411
				nil, -- 411
				{output = __TS__ObjectAssign({success = false, message = ((isBatch and "batch edit" or "write file") .. " failed: ") .. applyRes.message, actualSaved = false}, isBatch and ({results = results}) or ({}))} -- 414
			) -- 414
		end -- 414
		local files = __TS__ArrayMap( -- 417
			changes, -- 417
			function(____, change) return {path = change.path, op = change.op} end -- 417
		) -- 417
		local output -- 418
		if not isBatch then -- 418
			output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[1].path, { -- 420
				success = true, -- 421
				changed = true, -- 422
				mode = results[1].mode, -- 423
				checkpointId = applyRes.checkpointId, -- 424
				checkpointSeq = applyRes.checkpointSeq, -- 425
				files = files -- 426
			}) -- 426
		else -- 426
			local totalCharacters = 0 -- 429
			local actualSaved = true -- 430
			for ____, item in ipairs(changedTargets) do -- 431
				local current = Tools.readFileRaw(context.workingDir, item.path) -- 432
				if not current.success or current.content ~= item.content then -- 432
					actualSaved = false -- 433
				end -- 433
				if current.success then -- 433
					totalCharacters = totalCharacters + #current.content -- 434
				end -- 434
			end -- 434
			output = { -- 436
				success = true, -- 437
				changed = true, -- 438
				mode = "batch", -- 439
				operationCount = #operations, -- 440
				succeededOperationCount = #successfulOperations, -- 441
				failedOperationCount = #operations - #successfulOperations, -- 442
				partial = #successfulOperations < #operations, -- 443
				fileCount = #changedTargets, -- 444
				checkpointId = applyRes.checkpointId, -- 445
				checkpointSeq = applyRes.checkpointSeq, -- 446
				files = files, -- 447
				results = results, -- 448
				actualSaved = actualSaved, -- 449
				actualSavedCharacters = totalCharacters, -- 450
				currentFileExists = actualSaved, -- 451
				currentCharacters = totalCharacters, -- 452
				currentState = actualSaved and ((((("saved " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files" or "one or more batch file states could not be verified after commit" -- 453
			} -- 453
		end -- 453
		local authoredOperations = 0 -- 459
		local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 460
		for ____, operation in ipairs(successfulOperations) do -- 461
			do -- 461
				local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 462
				if AgentRuntimePolicy.isAgentInternalDocumentPath(path) then -- 462
					goto __continue92 -- 463
				end -- 463
				authoredOperations = authoredOperations + 1 -- 464
				if __TS__ArrayIndexOf(editedPaths, path) < 0 then -- 464
					editedPaths[#editedPaths + 1] = path -- 465
				end -- 465
			end -- 465
			::__continue92:: -- 465
		end -- 465
		if authoredOperations > 0 then -- 465
			context.workflow.unbuiltEdits = true -- 468
			context.workflow.lastBuildSucceeded = false -- 469
			if context.workflow.failedTestNeedsBuild == true then -- 469
				context.workflow.failedTestHasSourceEdit = true -- 470
			end -- 470
			context.workflow.editedPathsSinceBuild = editedPaths -- 471
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + authoredOperations -- 472
		end -- 472
		return ____awaiter_resolve(nil, {output = output}) -- 472
	end) -- 472
end -- 290
local function deleteFile(context, input) -- 477
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 477
		local targetFile = type(input.target_file) == "string" and input.target_file or "" -- 478
		if __TS__StringTrim(targetFile) == "" then -- 478
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing target_file"}}) -- 478
		end -- 478
		local normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile) -- 480
		local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 481
		local result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 482
		if not result.success then -- 482
			return ____awaiter_resolve(nil, {output = result}) -- 482
		end -- 482
		if not isInternalDocumentEdit then -- 482
			context.workflow.unbuiltEdits = true -- 488
			context.workflow.lastBuildSucceeded = false -- 489
			if context.workflow.failedTestNeedsBuild == true then -- 489
				context.workflow.failedTestHasSourceEdit = true -- 490
			end -- 490
			local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 491
			if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 491
				editedPaths[#editedPaths + 1] = normalizedTargetFile -- 492
			end -- 492
			context.workflow.editedPathsSinceBuild = editedPaths -- 493
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 494
		end -- 494
		local ____result_checkpointed_41 = result.checkpointed -- 501
		local ____result_reversible_42 = result.reversible -- 502
		local ____result_binary_43 = result.binary -- 503
		local ____temp_44 = result.checkpointed and result.checkpointId or nil -- 504
		local ____temp_45 = result.checkpointed and result.checkpointSeq or nil -- 505
		local ____result_checkpointed_40 -- 506
		if result.checkpointed then -- 506
			____result_checkpointed_40 = nil -- 506
		else -- 506
			____result_checkpointed_40 = result.message -- 506
		end -- 506
		return ____awaiter_resolve(nil, {output = { -- 506
			success = true, -- 498
			changed = true, -- 499
			mode = "delete", -- 500
			checkpointed = ____result_checkpointed_41, -- 501
			reversible = ____result_reversible_42, -- 502
			binary = ____result_binary_43, -- 503
			checkpointId = ____temp_44, -- 504
			checkpointSeq = ____temp_45, -- 505
			message = ____result_checkpointed_40, -- 506
			files = {{path = targetFile, op = "delete"}} -- 507
		}}) -- 507
	end) -- 507
end -- 477
local function askUser(context, input) -- 512
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 512
		if context.services.publishQuestionnaire == nil then -- 512
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user is not available in this runtime"}}) -- 512
		end -- 512
		if context.sessionId == nil or context.sessionId <= 0 then -- 512
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user requires a session"}}) -- 512
		end -- 512
		local normalized = normalizeQuestionnaire(input) -- 519
		if not normalized.success then -- 519
			return ____awaiter_resolve(nil, {output = normalized}) -- 519
		end -- 519
		local result = __TS__Await(context.services:publishQuestionnaire({sessionId = context.sessionId, taskId = context.taskId, step = context.step, schema = normalized.schema})) -- 521
		if not result.success then -- 521
			return ____awaiter_resolve(nil, {output = result}) -- 521
		end -- 521
		context.workflow.waitingQuestionnaireId = result.questionnaireId -- 528
		return ____awaiter_resolve(nil, {output = {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}, control = {waitForUser = true, questionnaireId = result.questionnaireId}}) -- 528
	end) -- 528
end -- 512
local function spawnSubAgent(context, input) -- 535
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 535
		if context.services.spawnSubAgent == nil then -- 535
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent is not available in this runtime"}}) -- 535
		end -- 535
		if context.sessionId == nil or context.sessionId <= 0 then -- 535
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent requires a parent session"}}) -- 535
		end -- 535
		local filesHint = __TS__ArrayIsArray(input.filesHint) and __TS__ArrayFilter( -- 542
			input.filesHint, -- 543
			function(____, item) return type(item) == "string" end -- 543
		) or nil -- 543
		local result = __TS__Await(context.services:spawnSubAgent({ -- 545
			parentSessionId = context.sessionId, -- 546
			projectRoot = context.workingDir, -- 547
			title = type(input.title) == "string" and input.title or "Sub", -- 548
			prompt = type(input.prompt) == "string" and input.prompt or "", -- 549
			expectedOutput = type(input.expectedOutput) == "string" and input.expectedOutput or nil, -- 550
			filesHint = filesHint, -- 551
			disabledAgentTools = context.disabledAgentTools -- 552
		})) -- 552
		if not result.success then -- 552
			return ____awaiter_resolve(nil, {output = result}) -- 552
		end -- 552
		context.workflow.hasSpawnedSubAgentThisTask = true -- 555
		return ____awaiter_resolve(nil, {output = { -- 555
			success = true, -- 558
			sessionId = result.sessionId, -- 559
			taskId = result.taskId, -- 560
			title = result.title, -- 561
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 562
		}, control = {spawnedSubAgent = true}}) -- 562
	end) -- 562
end -- 535
local function listSubAgents(context, input) -- 568
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 568
		if context.services.listSubAgents == nil then -- 568
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents is not available in this runtime"}}) -- 568
		end -- 568
		if context.sessionId == nil or context.sessionId <= 0 then -- 568
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents requires a current session"}}) -- 568
		end -- 568
		local result = __TS__Await(context.services:listSubAgents({ -- 575
			sessionId = context.sessionId, -- 576
			projectRoot = context.workingDir, -- 577
			status = type(input.status) == "string" and input.status or nil, -- 578
			limit = type(input.limit) == "number" and input.limit or nil, -- 579
			offset = type(input.offset) == "number" and input.offset or nil, -- 580
			query = type(input.query) == "string" and input.query or nil -- 581
		})) -- 581
		return ____awaiter_resolve(nil, {output = result}) -- 581
	end) -- 581
end -- 568
local function finish(_context, input) -- 586
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 586
		local message = type(input.message) == "string" and __TS__StringTrim(input.message) or "" -- 587
		return ____awaiter_resolve( -- 587
			nil, -- 587
			{ -- 588
				output = {success = true, message = message}, -- 589
				control = { -- 590
					concludeTask = true, -- 591
					finalMessage = message, -- 592
					completion = AgentUtils.normalizeAgentCompletionReport(input) -- 593
				} -- 593
			} -- 593
		) -- 593
	end) -- 593
end -- 586
local function analyzeImageHandler(context, input) -- 598
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 598
		local visionContext = context.visionTaskContext or "" -- 599
		if type(input.context) == "string" and __TS__StringTrim(input.context) ~= "" then -- 599
			visionContext = visionContext == "" and input.context or (visionContext .. "\n\n") .. input.context -- 601
		end -- 601
		return ____awaiter_resolve( -- 601
			nil, -- 601
			{output = __TS__Await(analyzeImage({ -- 603
				workingDir = context.workingDir, -- 604
				taskId = context.taskId, -- 605
				sessionId = context.sessionId, -- 606
				binding = context.visionBinding, -- 607
				paths = input.paths, -- 608
				question = input.question, -- 609
				criteria = input.criteria, -- 610
				context = visionContext, -- 611
				isCancelled = function() return context.cancellation:isCancelled() end -- 612
			}))} -- 612
		) -- 612
	end) -- 612
end -- 598
____exports.AGENT_TOOL_HANDLERS = { -- 616
	read_file = readFile, -- 617
	grep_files = grepFiles, -- 618
	glob_files = globFiles, -- 619
	search_dora_doc = searchDoraDoc, -- 620
	build = build, -- 621
	fetch_url = fetchUrl, -- 622
	execute_command = executeCommand, -- 623
	analyze_image = analyzeImageHandler, -- 624
	edit_file = editFile, -- 625
	delete_file = deleteFile, -- 626
	ask_user = askUser, -- 627
	spawn_sub_agent = spawnSubAgent, -- 628
	list_sub_agents = listSubAgents, -- 629
	finish = finish -- 630
} -- 630
return ____exports -- 630