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
	local ____input_endLine_1 = input.endLine -- 14
	if ____input_endLine_1 == nil then -- 14
		____input_endLine_1 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 14
	end -- 14
	local endLine = __TS__Number(____input_endLine_1) -- 14
	local clippedAfterCompression = false -- 15
	if context.workflow.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 15
		endLine = startLine + 159 -- 22
		clippedAfterCompression = true -- 23
	end -- 23
	local path = type(input.path) == "string" and input.path or "" -- 25
	if __TS__StringTrim(path) == "" then -- 25
		return {success = false, message = "missing path"} -- 27
	end -- 27
	local output = Tools.readFile( -- 29
		context.workingDir, -- 30
		path, -- 31
		startLine, -- 32
		endLine, -- 33
		context.useChineseResponse and "zh" or "en" -- 34
	) -- 34
	if clippedAfterCompression and output.success == true then -- 34
		output.clipped = true -- 37
		output.message = context.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 38
	end -- 38
	return output -- 42
end -- 12
local function readFile(context, input) -- 45
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 45
		if __TS__ArrayIsArray(input.reads) then -- 45
			local reads = input.reads -- 47
			local results = {} -- 48
			local succeeded = 0 -- 49
			do -- 49
				local i = 0 -- 50
				while i < #reads do -- 50
					local item = reads[i + 1] -- 51
					local output = readOneFile(context, item) -- 52
					if output.success == true then -- 52
						succeeded = succeeded + 1 -- 53
					end -- 53
					results[#results + 1] = __TS__ObjectAssign({index = i, path = item.path}, output) -- 54
					i = i + 1 -- 50
				end -- 50
			end -- 50
			return ____awaiter_resolve(nil, {output = { -- 50
				success = succeeded == #results, -- 57
				partial = succeeded > 0 and succeeded < #results, -- 58
				mode = "batch", -- 59
				readCount = #results, -- 60
				succeededReadCount = succeeded, -- 61
				failedReadCount = #results - succeeded, -- 62
				results = results -- 63
			}}) -- 63
		end -- 63
		return ____awaiter_resolve( -- 63
			nil, -- 63
			{output = readOneFile(context, input)} -- 66
		) -- 66
	end) -- 66
end -- 45
local function grepFiles(context, input) -- 69
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 69
		local ____Tools_searchFiles_17 = Tools.searchFiles -- 70
		local ____context_workingDir_8 = context.workingDir -- 71
		local ____temp_9 = input.path or "" -- 72
		local ____temp_10 = context.useChineseResponse and "zh" or "en" -- 73
		local ____temp_11 = input.pattern or "" -- 74
		local ____input_globs_12 = input.globs -- 75
		local ____input_useRegex_13 = input.useRegex -- 76
		local ____input_caseSensitive_14 = input.caseSensitive -- 77
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_15 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 79
		local ____math_max_4 = math.max -- 80
		local ____math_floor_3 = math.floor -- 80
		local ____input_limit_2 = input.limit -- 80
		if ____input_limit_2 == nil then -- 80
			____input_limit_2 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 80
		end -- 80
		local ____math_max_4_result_16 = ____math_max_4( -- 80
			1, -- 80
			____math_floor_3(__TS__Number(____input_limit_2)) -- 80
		) -- 80
		local ____math_max_7 = math.max -- 81
		local ____math_floor_6 = math.floor -- 81
		local ____input_offset_5 = input.offset -- 81
		if ____input_offset_5 == nil then -- 81
			____input_offset_5 = 0 -- 81
		end -- 81
		local output = __TS__Await(____Tools_searchFiles_17({ -- 70
			workDir = ____context_workingDir_8, -- 71
			path = ____temp_9, -- 72
			docLanguage = ____temp_10, -- 73
			pattern = ____temp_11, -- 74
			globs = ____input_globs_12, -- 75
			useRegex = ____input_useRegex_13, -- 76
			caseSensitive = ____input_caseSensitive_14, -- 77
			includeContent = true, -- 78
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_15, -- 79
			limit = ____math_max_4_result_16, -- 80
			offset = ____math_max_7( -- 81
				0, -- 81
				____math_floor_6(__TS__Number(____input_offset_5)) -- 81
			), -- 81
			groupByFile = input.groupByFile == true -- 82
		})) -- 82
		return ____awaiter_resolve(nil, {output = output}) -- 82
	end) -- 82
end -- 69
local function globFiles(context, input) -- 87
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 87
		local ____Tools_listFiles_24 = Tools.listFiles -- 88
		local ____context_workingDir_21 = context.workingDir -- 89
		local ____temp_22 = input.path or "" -- 90
		local ____input_globs_23 = input.globs -- 91
		local ____math_max_20 = math.max -- 92
		local ____math_floor_19 = math.floor -- 92
		local ____input_maxEntries_18 = input.maxEntries -- 92
		if ____input_maxEntries_18 == nil then -- 92
			____input_maxEntries_18 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 92
		end -- 92
		local output = ____Tools_listFiles_24({ -- 88
			workDir = ____context_workingDir_21, -- 89
			path = ____temp_22, -- 90
			globs = ____input_globs_23, -- 91
			maxEntries = ____math_max_20( -- 92
				1, -- 92
				____math_floor_19(__TS__Number(____input_maxEntries_18)) -- 92
			), -- 92
			preferSourceVariants = false -- 92
		}) -- 92
		return ____awaiter_resolve(nil, {output = output}) -- 92
	end) -- 92
end -- 87
local function searchDoraDoc(context, input) -- 97
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 97
		context.workflow.apiSearchesSinceBuild = (context.workflow.apiSearchesSinceBuild or 0) + 1 -- 98
		local ____Tools_searchDoraDoc_33 = Tools.searchDoraDoc -- 99
		local ____temp_29 = input.pattern or "" -- 100
		local ____temp_30 = input.docType or "dora-api" -- 101
		local ____temp_31 = context.useChineseResponse and "zh" or "en" -- 102
		local ____temp_32 = input.programmingLanguage or "ts" -- 103
		local ____math_min_28 = math.min -- 104
		local ____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27 = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax -- 104
		local ____math_max_26 = math.max -- 104
		local ____input_limit_25 = input.limit -- 104
		if ____input_limit_25 == nil then -- 104
			____input_limit_25 = 8 -- 104
		end -- 104
		local output = __TS__Await(____Tools_searchDoraDoc_33({ -- 99
			pattern = ____temp_29, -- 100
			docType = ____temp_30, -- 101
			docLanguage = ____temp_31, -- 102
			programmingLanguage = ____temp_32, -- 103
			limit = ____math_min_28( -- 104
				____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27, -- 104
				____math_max_26( -- 104
					1, -- 104
					__TS__Number(____input_limit_25) -- 104
				) -- 104
			), -- 104
			useRegex = input.useRegex, -- 105
			caseSensitive = false, -- 106
			includeContent = true, -- 107
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 108
		})) -- 108
		return ____awaiter_resolve(nil, {output = output}) -- 108
	end) -- 108
end -- 97
local function build(context, input) -- 113
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 113
		local paths = input.paths -- 114
		local results = {} -- 115
		local rawResults = {} -- 116
		local callFailureMessages = {} -- 117
		local succeeded = 0 -- 118
		do -- 118
			local i = 0 -- 119
			while i < #paths do -- 119
				local result -- 120
				local ____try = __TS__AsyncAwaiter(function() -- 120
					result = __TS__Await(Tools.build({ -- 122
						workDir = context.workingDir, -- 123
						path = paths[i + 1], -- 124
						isCancelled = function() return context.cancellation:isCancelled() end -- 125
					})) -- 125
				end) -- 125
				____try = ____try.catch( -- 125
					____try, -- 125
					function(____, err) -- 125
						return __TS__AsyncAwaiter(function() -- 125
							result = { -- 128
								success = false, -- 128
								failureKind = "tool", -- 128
								message = tostring(err) -- 128
							} -- 128
						end) -- 128
					end -- 128
				) -- 128
				__TS__Await(____try) -- 121
				if result.success then -- 121
					succeeded = succeeded + 1 -- 130
				elseif result.failureKind == "tool" then -- 130
					callFailureMessages[#callFailureMessages + 1] = result.message -- 131
				end -- 131
				rawResults[#rawResults + 1] = result -- 132
				results[#results + 1] = __TS__ObjectAssign({index = i, path = paths[i + 1]}, result) -- 133
				if context.cancellation:isCancelled() then -- 133
					break -- 134
				end -- 134
				i = i + 1 -- 119
			end -- 119
		end -- 119
		local output = { -- 136
			success = succeeded == #paths, -- 137
			partial = succeeded > 0 and succeeded < #paths, -- 138
			mode = "batch", -- 139
			requestedBuildCount = #paths, -- 140
			buildCount = #results, -- 141
			succeededBuildCount = succeeded, -- 142
			failedBuildCount = #results - succeeded, -- 143
			skippedBuildCount = #paths - #results, -- 144
			results = results -- 145
		} -- 145
		context.workflow.unbuiltEdits = false -- 149
		context.workflow.editsSinceBuild = 0 -- 150
		context.workflow.editedPathsSinceBuild = {} -- 151
		context.workflow.hasBuilt = true -- 152
		context.workflow.lastBuildSucceeded = output.success == true -- 153
		if output.success == true and context.workflow.freshProjectBuildPending == true then -- 153
			context.workflow.freshProjectBuildPending = false -- 155
		end -- 155
		context.workflow.apiSearchesSinceBuild = 0 -- 157
		context.workflow.buildRepairPending = false -- 158
		if output.success ~= true then -- 158
			do -- 158
				local r = 0 -- 160
				while r < #rawResults do -- 160
					local messages = rawResults[r + 1].messages -- 161
					do -- 161
						local i = 0 -- 162
						while i < (messages and #messages or 0) do -- 162
							if messages[i + 1].success == false and messages[i + 1].file ~= "" then -- 162
								context.workflow.buildRepairPending = true -- 164
								break -- 165
							end -- 165
							i = i + 1 -- 162
						end -- 162
					end -- 162
					r = r + 1 -- 160
				end -- 160
			end -- 160
		end -- 160
		if output.success == true and context.workflow.failedTestNeedsBuild == true and context.workflow.failedTestHasSourceEdit == true then -- 160
			context.workflow.failedTestNeedsBuild = false -- 171
			context.workflow.failedTestHasSourceEdit = false -- 172
		end -- 172
		if #callFailureMessages > 0 then -- 172
			error(table.concat(callFailureMessages, "; ")) -- 175
		end -- 175
		return ____awaiter_resolve(nil, {output = output}) -- 175
	end) -- 175
end -- 113
local function fetchUrl(context, input) -- 180
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 180
		local output = __TS__Await(Tools.fetchUrl({ -- 181
			workDir = context.workingDir, -- 182
			url = type(input.url) == "string" and input.url or "", -- 183
			target = type(input.target) == "string" and input.target or "", -- 184
			isCancelled = function() return context.cancellation:isCancelled() end, -- 185
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 186
		})) -- 186
		return ____awaiter_resolve(nil, {output = output}) -- 186
	end) -- 186
end -- 180
local function updateDeterministicTestState(context, output) -- 191
	local deterministicFailure = false -- 192
	local deterministicPass = false -- 193
	local outputLines = __TS__StringSplit(output, "\n") -- 194
	do -- 194
		local i = 0 -- 195
		while i < #outputLines and not deterministicFailure do -- 195
			local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 196
			if line == "passed" then -- 196
				deterministicPass = true -- 197
			end -- 197
			if line == "failed" then -- 197
				deterministicFailure = true -- 199
				break -- 200
			end -- 200
			local searchFrom = 0 -- 202
			while searchFrom < #line do -- 202
				local failedIndex = (string.find( -- 204
					line, -- 204
					"failed", -- 204
					math.max(searchFrom + 1, 1), -- 204
					true -- 204
				) or 0) - 1 -- 204
				if failedIndex < 0 then -- 204
					break -- 205
				end -- 205
				local after = failedIndex + #"failed" -- 206
				while after < #line do -- 206
					local ch = __TS__StringSlice(line, after, after + 1) -- 208
					if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 208
						break -- 209
					end -- 209
					after = after + 1 -- 210
				end -- 210
				local afterEnd = after -- 212
				while afterEnd < #line do -- 212
					local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 214
					if ch < "0" or ch > "9" then -- 214
						break -- 215
					end -- 215
					afterEnd = afterEnd + 1 -- 216
				end -- 216
				local count -- 218
				if afterEnd > after then -- 218
					count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 220
				else -- 220
					local before = failedIndex - 1 -- 222
					while before >= 0 do -- 222
						local ch = __TS__StringSlice(line, before, before + 1) -- 224
						if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 224
							break -- 225
						end -- 225
						before = before - 1 -- 226
					end -- 226
					local beforeEnd = before + 1 -- 228
					while before >= 0 do -- 228
						local ch = __TS__StringSlice(line, before, before + 1) -- 230
						if ch < "0" or ch > "9" then -- 230
							break -- 231
						end -- 231
						before = before - 1 -- 232
					end -- 232
					if beforeEnd > before + 1 then -- 232
						count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 234
					end -- 234
				end -- 234
				if count ~= nil and count > 0 then -- 234
					deterministicFailure = true -- 237
					break -- 238
				end -- 238
				searchFrom = failedIndex + #"failed" -- 240
			end -- 240
			i = i + 1 -- 195
		end -- 195
	end -- 195
	if deterministicFailure then -- 195
		context.workflow.failedTestNeedsBuild = true -- 244
		context.workflow.failedTestHasSourceEdit = false -- 245
	elseif deterministicPass then -- 245
		context.workflow.failedTestNeedsBuild = false -- 247
		context.workflow.failedTestHasSourceEdit = false -- 248
	end -- 248
end -- 191
local function executeCommand(context, input) -- 252
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 252
		local mode = type(input.mode) == "string" and input.mode or "" -- 253
		local output = __TS__Await(Tools.executeCommand({ -- 254
			workDir = context.workingDir, -- 255
			docLanguage = context.useChineseResponse and "zh" or "en", -- 256
			taskId = context.taskId, -- 257
			mode = mode, -- 258
			code = type(input.code) == "string" and input.code or nil, -- 259
			command = type(input.command) == "string" and input.command or nil, -- 260
			cwd = type(input.cwd) == "string" and input.cwd or nil, -- 261
			timeoutSeconds = type(input.timeoutSeconds) == "number" and input.timeoutSeconds or nil, -- 262
			isCancelled = function() return context.cancellation:isCancelled() end, -- 263
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 264
		})) -- 264
		if output.success and mode == "lua" then -- 264
			updateDeterministicTestState(context, output.output) -- 267
		end -- 267
		return ____awaiter_resolve(nil, {output = output}) -- 267
	end) -- 267
end -- 252
local function editFile(context, input) -- 289
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 289
		local operations = getAgentFileEditInputs(input) -- 290
		local isBatch = __TS__ArrayIsArray(input.edits) -- 291
		if #operations == 0 then -- 291
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing edit operations"}}) -- 291
		end -- 291
		local staged = {} -- 293
		local results = {} -- 294
		local successfulOperations = {} -- 295
		local function failOperation(index, path, code, message) -- 296
			results[#results + 1] = { -- 297
				index = index, -- 297
				path = path, -- 297
				success = false, -- 297
				code = code, -- 297
				message = message -- 297
			} -- 297
		end -- 296
		do -- 296
			local i = 0 -- 300
			while i < #operations do -- 300
				do -- 300
					local operation = operations[i + 1] -- 301
					local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 302
					if path == "" then -- 302
						failOperation(i, path, "INVALID_EDIT", "path is required") -- 304
						goto __continue64 -- 305
					end -- 305
					if operation.oldStr == operation.newStr then -- 305
						failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ") -- 308
						goto __continue64 -- 309
					end -- 309
					local stagedIndex = -1 -- 311
					do -- 311
						local j = 0 -- 312
						while j < #staged do -- 312
							if staged[j + 1].path == path then -- 312
								stagedIndex = j -- 314
								break -- 315
							end -- 315
							j = j + 1 -- 312
						end -- 312
					end -- 312
					if stagedIndex < 0 then -- 312
						local targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path) -- 319
						if not targetState.success then -- 319
							failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message) -- 321
							goto __continue64 -- 322
						end -- 322
						staged[#staged + 1] = { -- 324
							path = path, -- 325
							initialExists = targetState.exists, -- 326
							exists = targetState.exists, -- 327
							content = targetState.content, -- 328
							changed = false -- 329
						} -- 329
						stagedIndex = #staged - 1 -- 331
					end -- 331
					local target = staged[stagedIndex + 1] -- 333
					local guardDenial = getAgentFileEditPlanGuardDenial(context, operation) -- 334
					if guardDenial ~= nil then -- 334
						failOperation(i, path, guardDenial.code, guardDenial.message) -- 336
						goto __continue64 -- 337
					end -- 337
					local mode = "" -- 339
					if operation.oldStr == "" then -- 339
						if target.exists and AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr) then -- 339
							failOperation(i, path, "DUPLICATE_WHOLE_FILE", "rewrite rejected: the complete current file appears more than once in the replacement for " .. path) -- 342
							goto __continue64 -- 343
						end -- 343
						mode = target.exists and "overwrite" or "create" -- 345
						target.exists = true -- 346
						target.content = operation.newStr -- 347
					else -- 347
						if not target.exists then -- 347
							failOperation(i, path, "FILE_NOT_FOUND", ("read file failed: " .. path) .. " does not exist; use old_str=\"\" to create it earlier in the batch") -- 350
							goto __continue64 -- 351
						end -- 351
						local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content) -- 353
						local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr) -- 354
						local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr) -- 355
						local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 356
						if occurrences == 0 then -- 356
							local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 358
							if not indentTolerant.success then -- 358
								failOperation(i, path, "TEXT_NOT_FOUND", indentTolerant.message) -- 360
								goto __continue64 -- 361
							end -- 361
							target.content = indentTolerant.content -- 363
							mode = "replace_indent_tolerant" -- 364
						else -- 364
							if occurrences > 1 then -- 364
								failOperation( -- 367
									i, -- 367
									path, -- 367
									"AMBIGUOUS_MATCH", -- 367
									((("old_str appears " .. tostring(occurrences)) .. " times in ") .. path) .. ". Provide more context to identify one target." -- 367
								) -- 367
								goto __continue64 -- 368
							end -- 368
							target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 370
							mode = "replace" -- 371
						end -- 371
					end -- 371
					target.changed = true -- 374
					results[#results + 1] = {index = i, path = path, success = true, mode = mode} -- 375
					successfulOperations[#successfulOperations + 1] = operation -- 376
				end -- 376
				::__continue64:: -- 376
				i = i + 1 -- 300
			end -- 300
		end -- 300
		local changedTargets = __TS__ArrayFilter( -- 379
			staged, -- 379
			function(____, item) return item.changed end -- 379
		) -- 379
		if #changedTargets == 0 then -- 379
			local firstFailure = results[1] -- 381
			return ____awaiter_resolve(nil, {output = isBatch and ({ -- 381
				success = false, -- 384
				changed = false, -- 385
				mode = "batch", -- 386
				operationCount = #operations, -- 387
				succeededOperationCount = 0, -- 388
				failedOperationCount = #results, -- 389
				results = results, -- 390
				actualSaved = false -- 391
			}) or ({success = false, code = firstFailure and firstFailure.code, message = firstFailure and firstFailure.message or "edit failed", actualSaved = false})}) -- 391
		end -- 391
		local changes = __TS__ArrayMap( -- 401
			changedTargets, -- 401
			function(____, item) return {path = item.path, op = item.initialExists and "write" or "create", content = item.content} end -- 401
		) -- 401
		local applyRes = Tools.applyFileChanges( -- 406
			context.taskId, -- 406
			context.workingDir, -- 406
			changes, -- 406
			{ -- 406
				summary = isBatch and ((((("batch edit " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files via edit_file" or ((tostring(results[1].mode) .. " ") .. changedTargets[1].path) .. " via edit_file", -- 407
				toolName = "edit_file" -- 410
			} -- 410
		) -- 410
		if not applyRes.success then -- 410
			return ____awaiter_resolve( -- 410
				nil, -- 410
				{output = __TS__ObjectAssign({success = false, message = ((isBatch and "batch edit" or "write file") .. " failed: ") .. applyRes.message, actualSaved = false}, isBatch and ({results = results}) or ({}))} -- 413
			) -- 413
		end -- 413
		local files = __TS__ArrayMap( -- 416
			changes, -- 416
			function(____, change) return {path = change.path, op = change.op} end -- 416
		) -- 416
		local output -- 417
		if not isBatch then -- 417
			output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[1].path, { -- 419
				success = true, -- 420
				changed = true, -- 421
				mode = results[1].mode, -- 422
				checkpointId = applyRes.checkpointId, -- 423
				checkpointSeq = applyRes.checkpointSeq, -- 424
				files = files -- 425
			}) -- 425
		else -- 425
			local totalCharacters = 0 -- 428
			local actualSaved = true -- 429
			for ____, item in ipairs(changedTargets) do -- 430
				local current = Tools.readFileRaw(context.workingDir, item.path) -- 431
				if not current.success or current.content ~= item.content then -- 431
					actualSaved = false -- 432
				end -- 432
				if current.success then -- 432
					totalCharacters = totalCharacters + #current.content -- 433
				end -- 433
			end -- 433
			output = { -- 435
				success = true, -- 436
				changed = true, -- 437
				mode = "batch", -- 438
				operationCount = #operations, -- 439
				succeededOperationCount = #successfulOperations, -- 440
				failedOperationCount = #operations - #successfulOperations, -- 441
				partial = #successfulOperations < #operations, -- 442
				fileCount = #changedTargets, -- 443
				checkpointId = applyRes.checkpointId, -- 444
				checkpointSeq = applyRes.checkpointSeq, -- 445
				files = files, -- 446
				results = results, -- 447
				actualSaved = actualSaved, -- 448
				actualSavedCharacters = totalCharacters, -- 449
				currentFileExists = actualSaved, -- 450
				currentCharacters = totalCharacters, -- 451
				currentState = actualSaved and ((((("saved " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files" or "one or more batch file states could not be verified after commit" -- 452
			} -- 452
		end -- 452
		local authoredOperations = 0 -- 458
		local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 459
		for ____, operation in ipairs(successfulOperations) do -- 460
			do -- 460
				local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 461
				if AgentRuntimePolicy.isAgentInternalDocumentPath(path) then -- 461
					goto __continue92 -- 462
				end -- 462
				authoredOperations = authoredOperations + 1 -- 463
				if __TS__ArrayIndexOf(editedPaths, path) < 0 then -- 463
					editedPaths[#editedPaths + 1] = path -- 464
				end -- 464
			end -- 464
			::__continue92:: -- 464
		end -- 464
		if authoredOperations > 0 then -- 464
			context.workflow.unbuiltEdits = true -- 467
			context.workflow.lastBuildSucceeded = false -- 468
			if context.workflow.failedTestNeedsBuild == true then -- 468
				context.workflow.failedTestHasSourceEdit = true -- 469
			end -- 469
			context.workflow.editedPathsSinceBuild = editedPaths -- 470
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + authoredOperations -- 471
		end -- 471
		return ____awaiter_resolve(nil, {output = output}) -- 471
	end) -- 471
end -- 289
local function deleteFile(context, input) -- 476
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 476
		local targetFile = type(input.target_file) == "string" and input.target_file or "" -- 477
		if __TS__StringTrim(targetFile) == "" then -- 477
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing target_file"}}) -- 477
		end -- 477
		local normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile) -- 479
		local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 480
		local result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 481
		if not result.success then -- 481
			return ____awaiter_resolve(nil, {output = result}) -- 481
		end -- 481
		if not isInternalDocumentEdit then -- 481
			context.workflow.unbuiltEdits = true -- 487
			context.workflow.lastBuildSucceeded = false -- 488
			if context.workflow.failedTestNeedsBuild == true then -- 488
				context.workflow.failedTestHasSourceEdit = true -- 489
			end -- 489
			local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 490
			if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 490
				editedPaths[#editedPaths + 1] = normalizedTargetFile -- 491
			end -- 491
			context.workflow.editedPathsSinceBuild = editedPaths -- 492
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 493
		end -- 493
		local ____result_checkpointed_41 = result.checkpointed -- 500
		local ____result_reversible_42 = result.reversible -- 501
		local ____result_binary_43 = result.binary -- 502
		local ____temp_44 = result.checkpointed and result.checkpointId or nil -- 503
		local ____temp_45 = result.checkpointed and result.checkpointSeq or nil -- 504
		local ____result_checkpointed_40 -- 505
		if result.checkpointed then -- 505
			____result_checkpointed_40 = nil -- 505
		else -- 505
			____result_checkpointed_40 = result.message -- 505
		end -- 505
		return ____awaiter_resolve(nil, {output = { -- 505
			success = true, -- 497
			changed = true, -- 498
			mode = "delete", -- 499
			checkpointed = ____result_checkpointed_41, -- 500
			reversible = ____result_reversible_42, -- 501
			binary = ____result_binary_43, -- 502
			checkpointId = ____temp_44, -- 503
			checkpointSeq = ____temp_45, -- 504
			message = ____result_checkpointed_40, -- 505
			files = {{path = targetFile, op = "delete"}} -- 506
		}}) -- 506
	end) -- 506
end -- 476
local function askUser(context, input) -- 511
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 511
		if context.services.publishQuestionnaire == nil then -- 511
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user is not available in this runtime"}}) -- 511
		end -- 511
		if context.sessionId == nil or context.sessionId <= 0 then -- 511
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user requires a session"}}) -- 511
		end -- 511
		local normalized = normalizeQuestionnaire(input) -- 518
		if not normalized.success then -- 518
			return ____awaiter_resolve(nil, {output = normalized}) -- 518
		end -- 518
		local result = __TS__Await(context.services:publishQuestionnaire({sessionId = context.sessionId, taskId = context.taskId, step = context.step, schema = normalized.schema})) -- 520
		if not result.success then -- 520
			return ____awaiter_resolve(nil, {output = result}) -- 520
		end -- 520
		context.workflow.waitingQuestionnaireId = result.questionnaireId -- 527
		return ____awaiter_resolve(nil, {output = {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}, control = {waitForUser = true, questionnaireId = result.questionnaireId}}) -- 527
	end) -- 527
end -- 511
local function spawnSubAgent(context, input) -- 534
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 534
		if context.services.spawnSubAgent == nil then -- 534
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent is not available in this runtime"}}) -- 534
		end -- 534
		if context.sessionId == nil or context.sessionId <= 0 then -- 534
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent requires a parent session"}}) -- 534
		end -- 534
		local filesHint = __TS__ArrayIsArray(input.filesHint) and __TS__ArrayFilter( -- 541
			input.filesHint, -- 542
			function(____, item) return type(item) == "string" end -- 542
		) or nil -- 542
		local result = __TS__Await(context.services:spawnSubAgent({ -- 544
			parentSessionId = context.sessionId, -- 545
			projectRoot = context.workingDir, -- 546
			title = type(input.title) == "string" and input.title or "Sub", -- 547
			prompt = type(input.prompt) == "string" and input.prompt or "", -- 548
			expectedOutput = type(input.expectedOutput) == "string" and input.expectedOutput or nil, -- 549
			filesHint = filesHint, -- 550
			disabledAgentTools = context.disabledAgentTools -- 551
		})) -- 551
		if not result.success then -- 551
			return ____awaiter_resolve(nil, {output = result}) -- 551
		end -- 551
		context.workflow.hasSpawnedSubAgentThisTask = true -- 554
		return ____awaiter_resolve(nil, {output = { -- 554
			success = true, -- 557
			sessionId = result.sessionId, -- 558
			taskId = result.taskId, -- 559
			title = result.title, -- 560
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 561
		}, control = {spawnedSubAgent = true}}) -- 561
	end) -- 561
end -- 534
local function listSubAgents(context, input) -- 567
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 567
		if context.services.listSubAgents == nil then -- 567
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents is not available in this runtime"}}) -- 567
		end -- 567
		if context.sessionId == nil or context.sessionId <= 0 then -- 567
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents requires a current session"}}) -- 567
		end -- 567
		local result = __TS__Await(context.services:listSubAgents({ -- 574
			sessionId = context.sessionId, -- 575
			projectRoot = context.workingDir, -- 576
			status = type(input.status) == "string" and input.status or nil, -- 577
			limit = type(input.limit) == "number" and input.limit or nil, -- 578
			offset = type(input.offset) == "number" and input.offset or nil, -- 579
			query = type(input.query) == "string" and input.query or nil -- 580
		})) -- 580
		return ____awaiter_resolve(nil, {output = result}) -- 580
	end) -- 580
end -- 567
local function finish(_context, input) -- 585
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 585
		local message = type(input.message) == "string" and __TS__StringTrim(input.message) or "" -- 586
		return ____awaiter_resolve( -- 586
			nil, -- 586
			{ -- 587
				output = {success = true, message = message}, -- 588
				control = { -- 589
					concludeTask = true, -- 590
					finalMessage = message, -- 591
					completion = AgentUtils.normalizeAgentCompletionReport(input) -- 592
				} -- 592
			} -- 592
		) -- 592
	end) -- 592
end -- 585
local function analyzeImageHandler(context, input) -- 597
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 597
		local visionContext = context.visionTaskContext or "" -- 598
		if type(input.context) == "string" and __TS__StringTrim(input.context) ~= "" then -- 598
			visionContext = visionContext == "" and input.context or (visionContext .. "\n\n") .. input.context -- 600
		end -- 600
		return ____awaiter_resolve( -- 600
			nil, -- 600
			{output = __TS__Await(analyzeImage({ -- 602
				workingDir = context.workingDir, -- 603
				taskId = context.taskId, -- 604
				sessionId = context.sessionId, -- 605
				binding = context.visionBinding, -- 606
				paths = input.paths, -- 607
				question = input.question, -- 608
				criteria = input.criteria, -- 609
				context = visionContext, -- 610
				isCancelled = function() return context.cancellation:isCancelled() end -- 611
			}))} -- 611
		) -- 611
	end) -- 611
end -- 597
____exports.AGENT_TOOL_HANDLERS = { -- 615
	read_file = readFile, -- 616
	grep_files = grepFiles, -- 617
	glob_files = globFiles, -- 618
	search_dora_doc = searchDoraDoc, -- 619
	build = build, -- 620
	fetch_url = fetchUrl, -- 621
	execute_command = executeCommand, -- 622
	analyze_image = analyzeImageHandler, -- 623
	edit_file = editFile, -- 624
	delete_file = deleteFile, -- 625
	ask_user = askUser, -- 626
	spawn_sub_agent = spawnSubAgent, -- 627
	list_sub_agents = listSubAgents, -- 628
	finish = finish -- 629
} -- 629
return ____exports -- 629