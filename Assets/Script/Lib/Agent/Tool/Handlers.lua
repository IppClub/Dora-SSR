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
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
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
		local pattern = type(input.pattern) == "string" and __TS__StringTrim(input.pattern) or "" -- 71
		if pattern == "" then -- 71
			local ____Tools_listFiles_8 = Tools.listFiles -- 74
			local ____context_workingDir_5 = context.workingDir -- 75
			local ____temp_6 = input.path or "" -- 76
			local ____input_globs_7 = input.globs -- 77
			local ____math_max_4 = math.max -- 78
			local ____math_floor_3 = math.floor -- 78
			local ____input_maxEntries_2 = input.maxEntries -- 78
			if ____input_maxEntries_2 == nil then -- 78
				____input_maxEntries_2 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 78
			end -- 78
			local listed = ____Tools_listFiles_8({ -- 74
				workDir = ____context_workingDir_5, -- 75
				path = ____temp_6, -- 76
				globs = ____input_globs_7, -- 77
				maxEntries = ____math_max_4( -- 78
					1, -- 78
					____math_floor_3(__TS__Number(____input_maxEntries_2)) -- 78
				), -- 78
				preferSourceVariants = false -- 78
			}) -- 78
			return ____awaiter_resolve(nil, {output = listed}) -- 78
		end -- 78
		local ____Tools_searchFiles_24 = Tools.searchFiles -- 82
		local ____context_workingDir_15 = context.workingDir -- 83
		local ____temp_16 = input.path or "" -- 84
		local ____temp_17 = context.useChineseResponse and "zh" or "en" -- 85
		local ____pattern_18 = pattern -- 86
		local ____input_globs_19 = input.globs -- 87
		local ____input_useRegex_20 = input.useRegex -- 88
		local ____input_caseSensitive_21 = input.caseSensitive -- 89
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_22 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 91
		local ____math_max_11 = math.max -- 92
		local ____math_floor_10 = math.floor -- 92
		local ____input_limit_9 = input.limit -- 92
		if ____input_limit_9 == nil then -- 92
			____input_limit_9 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 92
		end -- 92
		local ____math_max_11_result_23 = ____math_max_11( -- 92
			1, -- 92
			____math_floor_10(__TS__Number(____input_limit_9)) -- 92
		) -- 92
		local ____math_max_14 = math.max -- 93
		local ____math_floor_13 = math.floor -- 93
		local ____input_offset_12 = input.offset -- 93
		if ____input_offset_12 == nil then -- 93
			____input_offset_12 = 0 -- 93
		end -- 93
		local output = __TS__Await(____Tools_searchFiles_24({ -- 82
			workDir = ____context_workingDir_15, -- 83
			path = ____temp_16, -- 84
			docLanguage = ____temp_17, -- 85
			pattern = ____pattern_18, -- 86
			globs = ____input_globs_19, -- 87
			useRegex = ____input_useRegex_20, -- 88
			caseSensitive = ____input_caseSensitive_21, -- 89
			includeContent = true, -- 90
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_22, -- 91
			limit = ____math_max_11_result_23, -- 92
			offset = ____math_max_14( -- 93
				0, -- 93
				____math_floor_13(__TS__Number(____input_offset_12)) -- 93
			), -- 93
			groupByFile = input.groupByFile == true -- 94
		})) -- 94
		return ____awaiter_resolve(nil, {output = output}) -- 94
	end) -- 94
end -- 70
local function searchDoraDoc(context, input) -- 99
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 99
		context.workflow.apiSearchesSinceBuild = (context.workflow.apiSearchesSinceBuild or 0) + 1 -- 100
		local ____Tools_searchDoraDoc_33 = Tools.searchDoraDoc -- 101
		local ____temp_29 = input.pattern or "" -- 102
		local ____temp_30 = input.docType or "dora-api" -- 103
		local ____temp_31 = context.useChineseResponse and "zh" or "en" -- 104
		local ____temp_32 = input.programmingLanguage or "ts" -- 105
		local ____math_min_28 = math.min -- 106
		local ____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27 = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax -- 106
		local ____math_max_26 = math.max -- 106
		local ____input_limit_25 = input.limit -- 106
		if ____input_limit_25 == nil then -- 106
			____input_limit_25 = 8 -- 106
		end -- 106
		local output = __TS__Await(____Tools_searchDoraDoc_33({ -- 101
			pattern = ____temp_29, -- 102
			docType = ____temp_30, -- 103
			docLanguage = ____temp_31, -- 104
			programmingLanguage = ____temp_32, -- 105
			limit = ____math_min_28( -- 106
				____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27, -- 106
				____math_max_26( -- 106
					1, -- 106
					__TS__Number(____input_limit_25) -- 106
				) -- 106
			), -- 106
			useRegex = input.useRegex, -- 107
			caseSensitive = false, -- 108
			includeContent = true, -- 109
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 110
		})) -- 110
		return ____awaiter_resolve(nil, {output = output}) -- 110
	end) -- 110
end -- 99
local function build(context, input) -- 115
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 115
		local paths = input.paths -- 116
		local results = {} -- 117
		local rawResults = {} -- 118
		local callFailureMessages = {} -- 119
		local succeeded = 0 -- 120
		do -- 120
			local i = 0 -- 121
			while i < #paths do -- 121
				local result -- 122
				local ____try = __TS__AsyncAwaiter(function() -- 122
					result = __TS__Await(Tools.build({ -- 124
						workDir = context.workingDir, -- 125
						path = paths[i + 1], -- 126
						isCancelled = function() return context.cancellation:isCancelled() end -- 127
					})) -- 127
				end) -- 127
				____try = ____try.catch( -- 127
					____try, -- 127
					function(____, err) -- 127
						return __TS__AsyncAwaiter(function() -- 127
							result = { -- 130
								success = false, -- 130
								failureKind = "tool", -- 130
								message = tostring(err) -- 130
							} -- 130
						end) -- 130
					end -- 130
				) -- 130
				__TS__Await(____try) -- 123
				if result.success then -- 123
					succeeded = succeeded + 1 -- 132
				elseif result.failureKind == "tool" then -- 132
					callFailureMessages[#callFailureMessages + 1] = result.message -- 133
				end -- 133
				rawResults[#rawResults + 1] = result -- 134
				results[#results + 1] = __TS__ObjectAssign({index = i, path = paths[i + 1]}, result) -- 135
				if context.cancellation:isCancelled() then -- 135
					break -- 136
				end -- 136
				i = i + 1 -- 121
			end -- 121
		end -- 121
		local output = { -- 138
			success = succeeded == #paths, -- 139
			partial = succeeded > 0 and succeeded < #paths, -- 140
			mode = "batch", -- 141
			requestedBuildCount = #paths, -- 142
			buildCount = #results, -- 143
			succeededBuildCount = succeeded, -- 144
			failedBuildCount = #results - succeeded, -- 145
			skippedBuildCount = #paths - #results, -- 146
			results = results -- 147
		} -- 147
		context.workflow.unbuiltEdits = false -- 151
		context.workflow.editsSinceBuild = 0 -- 152
		context.workflow.editedPathsSinceBuild = {} -- 153
		context.workflow.hasBuilt = true -- 154
		context.workflow.lastBuildSucceeded = output.success == true -- 155
		if output.success == true and context.workflow.freshProjectBuildPending == true then -- 155
			context.workflow.freshProjectBuildPending = false -- 157
		end -- 157
		context.workflow.apiSearchesSinceBuild = 0 -- 159
		context.workflow.buildRepairPending = false -- 160
		if output.success ~= true then -- 160
			do -- 160
				local r = 0 -- 162
				while r < #rawResults do -- 162
					local messages = rawResults[r + 1].messages -- 163
					do -- 163
						local i = 0 -- 164
						while i < (messages and #messages or 0) do -- 164
							if messages[i + 1].success == false and messages[i + 1].file ~= "" then -- 164
								context.workflow.buildRepairPending = true -- 166
								break -- 167
							end -- 167
							i = i + 1 -- 164
						end -- 164
					end -- 164
					r = r + 1 -- 162
				end -- 162
			end -- 162
		end -- 162
		if output.success == true and context.workflow.failedTestNeedsBuild == true and context.workflow.failedTestHasSourceEdit == true then -- 162
			context.workflow.failedTestNeedsBuild = false -- 173
			context.workflow.failedTestHasSourceEdit = false -- 174
		end -- 174
		if #callFailureMessages > 0 then -- 174
			error(table.concat(callFailureMessages, "; ")) -- 177
		end -- 177
		return ____awaiter_resolve(nil, {output = output}) -- 177
	end) -- 177
end -- 115
local function fetchUrl(context, input) -- 182
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 182
		local output = __TS__Await(Tools.fetchUrl({ -- 183
			workDir = context.workingDir, -- 184
			url = type(input.url) == "string" and input.url or "", -- 185
			target = type(input.target) == "string" and input.target or "", -- 186
			isCancelled = function() return context.cancellation:isCancelled() end, -- 187
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 188
		})) -- 188
		return ____awaiter_resolve(nil, {output = output}) -- 188
	end) -- 188
end -- 182
local function updateDeterministicTestState(context, output) -- 193
	local deterministicFailure = false -- 194
	local deterministicPass = false -- 195
	local outputLines = __TS__StringSplit(output, "\n") -- 196
	do -- 196
		local i = 0 -- 197
		while i < #outputLines and not deterministicFailure do -- 197
			local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 198
			if line == "passed" then -- 198
				deterministicPass = true -- 199
			end -- 199
			if line == "failed" then -- 199
				deterministicFailure = true -- 201
				break -- 202
			end -- 202
			local searchFrom = 0 -- 204
			while searchFrom < #line do -- 204
				local failedIndex = (string.find( -- 206
					line, -- 206
					"failed", -- 206
					math.max(searchFrom + 1, 1), -- 206
					true -- 206
				) or 0) - 1 -- 206
				if failedIndex < 0 then -- 206
					break -- 207
				end -- 207
				local after = failedIndex + #"failed" -- 208
				while after < #line do -- 208
					local ch = __TS__StringSlice(line, after, after + 1) -- 210
					if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 210
						break -- 211
					end -- 211
					after = after + 1 -- 212
				end -- 212
				local afterEnd = after -- 214
				while afterEnd < #line do -- 214
					local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 216
					if ch < "0" or ch > "9" then -- 216
						break -- 217
					end -- 217
					afterEnd = afterEnd + 1 -- 218
				end -- 218
				local count -- 220
				if afterEnd > after then -- 220
					count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 222
				else -- 222
					local before = failedIndex - 1 -- 224
					while before >= 0 do -- 224
						local ch = __TS__StringSlice(line, before, before + 1) -- 226
						if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 226
							break -- 227
						end -- 227
						before = before - 1 -- 228
					end -- 228
					local beforeEnd = before + 1 -- 230
					while before >= 0 do -- 230
						local ch = __TS__StringSlice(line, before, before + 1) -- 232
						if ch < "0" or ch > "9" then -- 232
							break -- 233
						end -- 233
						before = before - 1 -- 234
					end -- 234
					if beforeEnd > before + 1 then -- 234
						count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 236
					end -- 236
				end -- 236
				if count ~= nil and count > 0 then -- 236
					deterministicFailure = true -- 239
					break -- 240
				end -- 240
				searchFrom = failedIndex + #"failed" -- 242
			end -- 242
			i = i + 1 -- 197
		end -- 197
	end -- 197
	if deterministicFailure then -- 197
		context.workflow.failedTestNeedsBuild = true -- 246
		context.workflow.failedTestHasSourceEdit = false -- 247
	elseif deterministicPass then -- 247
		context.workflow.failedTestNeedsBuild = false -- 249
		context.workflow.failedTestHasSourceEdit = false -- 250
	end -- 250
end -- 193
local function executeCommand(context, input) -- 254
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 254
		local mode = type(input.mode) == "string" and input.mode or "" -- 255
		local output = __TS__Await(Tools.executeCommand({ -- 256
			workDir = context.workingDir, -- 257
			docLanguage = context.useChineseResponse and "zh" or "en", -- 258
			taskId = context.taskId, -- 259
			mode = mode, -- 260
			code = type(input.code) == "string" and input.code or nil, -- 261
			command = type(input.command) == "string" and input.command or nil, -- 262
			cwd = type(input.cwd) == "string" and input.cwd or nil, -- 263
			timeoutSeconds = type(input.timeoutSeconds) == "number" and input.timeoutSeconds or nil, -- 264
			isCancelled = function() return context.cancellation:isCancelled() end, -- 265
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 266
		})) -- 266
		if output.success and mode == "lua" then -- 266
			updateDeterministicTestState(context, output.output) -- 269
		end -- 269
		return ____awaiter_resolve(nil, {output = output}) -- 269
	end) -- 269
end -- 254
local function editFile(context, input) -- 291
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 291
		if input.delete == true then -- 291
			local targetFile = type(input.path) == "string" and input.path or "" -- 294
			if __TS__StringTrim(targetFile) == "" then -- 294
				return ____awaiter_resolve(nil, {output = {success = false, message = "delete requires path"}}) -- 294
			end -- 294
			local normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile) -- 296
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 297
			local result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {summary = "edit_file delete: " .. targetFile, toolName = "edit_file"}) -- 298
			if not result.success then -- 298
				return ____awaiter_resolve(nil, {output = result}) -- 298
			end -- 298
			if not isInternalDocumentEdit then -- 298
				context.workflow.unbuiltEdits = true -- 304
				context.workflow.lastBuildSucceeded = false -- 305
				if context.workflow.failedTestNeedsBuild == true then -- 305
					context.workflow.failedTestHasSourceEdit = true -- 306
				end -- 306
				local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 307
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 307
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 308
				end -- 308
				context.workflow.editedPathsSinceBuild = editedPaths -- 309
				context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 310
			end -- 310
			local ____result_checkpointed_37 = result.checkpointed -- 317
			local ____result_reversible_38 = result.reversible -- 318
			local ____result_binary_39 = result.binary -- 319
			local ____temp_40 = result.checkpointed and result.checkpointId or nil -- 320
			local ____temp_41 = result.checkpointed and result.checkpointSeq or nil -- 321
			local ____result_checkpointed_36 -- 322
			if result.checkpointed then -- 322
				____result_checkpointed_36 = nil -- 322
			else -- 322
				____result_checkpointed_36 = result.message -- 322
			end -- 322
			return ____awaiter_resolve(nil, {output = { -- 322
				success = true, -- 314
				changed = true, -- 315
				mode = "delete", -- 316
				checkpointed = ____result_checkpointed_37, -- 317
				reversible = ____result_reversible_38, -- 318
				binary = ____result_binary_39, -- 319
				checkpointId = ____temp_40, -- 320
				checkpointSeq = ____temp_41, -- 321
				message = ____result_checkpointed_36, -- 322
				files = {{path = targetFile, op = "delete"}} -- 323
			}}) -- 323
		end -- 323
		local operations = getAgentFileEditInputs(input) -- 327
		local isBatch = __TS__ArrayIsArray(input.edits) -- 328
		if #operations == 0 then -- 328
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing edit operations"}}) -- 328
		end -- 328
		local staged = {} -- 330
		local results = {} -- 331
		local successfulOperations = {} -- 332
		local function failOperation(index, path, code, message) -- 333
			results[#results + 1] = { -- 334
				index = index, -- 334
				path = path, -- 334
				success = false, -- 334
				code = code, -- 334
				message = message -- 334
			} -- 334
		end -- 333
		do -- 333
			local i = 0 -- 337
			while i < #operations do -- 337
				do -- 337
					local operation = operations[i + 1] -- 338
					local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 339
					if path == "" then -- 339
						failOperation(i, path, "INVALID_EDIT", "path is required") -- 341
						goto __continue70 -- 342
					end -- 342
					if operation.oldStr == operation.newStr then -- 342
						failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ") -- 345
						goto __continue70 -- 346
					end -- 346
					local stagedIndex = -1 -- 348
					do -- 348
						local j = 0 -- 349
						while j < #staged do -- 349
							if staged[j + 1].path == path then -- 349
								stagedIndex = j -- 351
								break -- 352
							end -- 352
							j = j + 1 -- 349
						end -- 349
					end -- 349
					if stagedIndex < 0 then -- 349
						local targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path) -- 356
						if not targetState.success then -- 356
							failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message) -- 358
							goto __continue70 -- 359
						end -- 359
						staged[#staged + 1] = { -- 361
							path = path, -- 362
							initialExists = targetState.exists, -- 363
							exists = targetState.exists, -- 364
							content = targetState.content, -- 365
							changed = false -- 366
						} -- 366
						stagedIndex = #staged - 1 -- 368
					end -- 368
					local target = staged[stagedIndex + 1] -- 370
					local guardDenial = getAgentFileEditPlanGuardDenial(context, operation) -- 371
					if guardDenial ~= nil then -- 371
						failOperation(i, path, guardDenial.code, guardDenial.message) -- 373
						goto __continue70 -- 374
					end -- 374
					local mode = "" -- 376
					if operation.oldStr == "" then -- 376
						if target.exists and AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr) then -- 376
							failOperation(i, path, "DUPLICATE_WHOLE_FILE", "rewrite rejected: the complete current file appears more than once in the replacement for " .. path) -- 379
							goto __continue70 -- 380
						end -- 380
						mode = target.exists and "overwrite" or "create" -- 382
						target.exists = true -- 383
						target.content = operation.newStr -- 384
					else -- 384
						if not target.exists then -- 384
							failOperation(i, path, "FILE_NOT_FOUND", ("read file failed: " .. path) .. " does not exist; use old_str=\"\" to create it earlier in the batch") -- 387
							goto __continue70 -- 388
						end -- 388
						local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content) -- 390
						local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr) -- 391
						local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr) -- 392
						local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 393
						if occurrences == 0 then -- 393
							local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 395
							if not indentTolerant.success then -- 395
								failOperation(i, path, "TEXT_NOT_FOUND", indentTolerant.message) -- 397
								goto __continue70 -- 398
							end -- 398
							target.content = indentTolerant.content -- 400
							mode = "replace_indent_tolerant" -- 401
						else -- 401
							if occurrences > 1 then -- 401
								failOperation( -- 404
									i, -- 404
									path, -- 404
									"AMBIGUOUS_MATCH", -- 404
									((("old_str appears " .. tostring(occurrences)) .. " times in ") .. path) .. ". Provide more context to identify one target." -- 404
								) -- 404
								goto __continue70 -- 405
							end -- 405
							target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 407
							mode = "replace" -- 408
						end -- 408
					end -- 408
					target.changed = true -- 411
					results[#results + 1] = {index = i, path = path, success = true, mode = mode} -- 412
					successfulOperations[#successfulOperations + 1] = operation -- 413
				end -- 413
				::__continue70:: -- 413
				i = i + 1 -- 337
			end -- 337
		end -- 337
		local changedTargets = __TS__ArrayFilter( -- 416
			staged, -- 416
			function(____, item) return item.changed end -- 416
		) -- 416
		if #changedTargets == 0 then -- 416
			local firstFailure = results[1] -- 418
			return ____awaiter_resolve(nil, {output = isBatch and ({ -- 418
				success = false, -- 421
				changed = false, -- 422
				mode = "batch", -- 423
				operationCount = #operations, -- 424
				succeededOperationCount = 0, -- 425
				failedOperationCount = #results, -- 426
				results = results, -- 427
				actualSaved = false -- 428
			}) or ({success = false, code = firstFailure and firstFailure.code, message = firstFailure and firstFailure.message or "edit failed", actualSaved = false})}) -- 428
		end -- 428
		local changes = __TS__ArrayMap( -- 438
			changedTargets, -- 438
			function(____, item) return {path = item.path, op = item.initialExists and "write" or "create", content = item.content} end -- 438
		) -- 438
		local applyRes = Tools.applyFileChanges( -- 443
			context.taskId, -- 443
			context.workingDir, -- 443
			changes, -- 443
			{ -- 443
				summary = isBatch and ((((("batch edit " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files via edit_file" or ((tostring(results[1].mode) .. " ") .. changedTargets[1].path) .. " via edit_file", -- 444
				toolName = "edit_file" -- 447
			} -- 447
		) -- 447
		if not applyRes.success then -- 447
			return ____awaiter_resolve( -- 447
				nil, -- 447
				{output = __TS__ObjectAssign({success = false, message = ((isBatch and "batch edit" or "write file") .. " failed: ") .. applyRes.message, actualSaved = false}, isBatch and ({results = results}) or ({}))} -- 450
			) -- 450
		end -- 450
		local files = __TS__ArrayMap( -- 453
			changes, -- 453
			function(____, change) return {path = change.path, op = change.op} end -- 453
		) -- 453
		local output -- 454
		if not isBatch then -- 454
			output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[1].path, { -- 456
				success = true, -- 457
				changed = true, -- 458
				mode = results[1].mode, -- 459
				checkpointId = applyRes.checkpointId, -- 460
				checkpointSeq = applyRes.checkpointSeq, -- 461
				files = files -- 462
			}) -- 462
		else -- 462
			local totalCharacters = 0 -- 465
			local actualSaved = true -- 466
			for ____, item in ipairs(changedTargets) do -- 467
				local current = Tools.readFileRaw(context.workingDir, item.path) -- 468
				if not current.success or current.content ~= item.content then -- 468
					actualSaved = false -- 469
				end -- 469
				if current.success then -- 469
					totalCharacters = totalCharacters + #current.content -- 470
				end -- 470
			end -- 470
			output = { -- 472
				success = true, -- 473
				changed = true, -- 474
				mode = "batch", -- 475
				operationCount = #operations, -- 476
				succeededOperationCount = #successfulOperations, -- 477
				failedOperationCount = #operations - #successfulOperations, -- 478
				partial = #successfulOperations < #operations, -- 479
				fileCount = #changedTargets, -- 480
				checkpointId = applyRes.checkpointId, -- 481
				checkpointSeq = applyRes.checkpointSeq, -- 482
				files = files, -- 483
				results = results, -- 484
				actualSaved = actualSaved, -- 485
				actualSavedCharacters = totalCharacters, -- 486
				currentFileExists = actualSaved, -- 487
				currentCharacters = totalCharacters, -- 488
				currentState = actualSaved and ((((("saved " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files" or "one or more batch file states could not be verified after commit" -- 489
			} -- 489
		end -- 489
		local authoredOperations = 0 -- 495
		local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 496
		for ____, operation in ipairs(successfulOperations) do -- 497
			do -- 497
				local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 498
				if AgentRuntimePolicy.isAgentInternalDocumentPath(path) then -- 498
					goto __continue98 -- 499
				end -- 499
				authoredOperations = authoredOperations + 1 -- 500
				if __TS__ArrayIndexOf(editedPaths, path) < 0 then -- 500
					editedPaths[#editedPaths + 1] = path -- 501
				end -- 501
			end -- 501
			::__continue98:: -- 501
		end -- 501
		if authoredOperations > 0 then -- 501
			context.workflow.unbuiltEdits = true -- 504
			context.workflow.lastBuildSucceeded = false -- 505
			if context.workflow.failedTestNeedsBuild == true then -- 505
				context.workflow.failedTestHasSourceEdit = true -- 506
			end -- 506
			context.workflow.editedPathsSinceBuild = editedPaths -- 507
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + authoredOperations -- 508
		end -- 508
		return ____awaiter_resolve(nil, {output = output}) -- 508
	end) -- 508
end -- 291
local function askUser(context, input) -- 513
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 513
		if context.services.publishQuestionnaire == nil then -- 513
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user is not available in this runtime"}}) -- 513
		end -- 513
		if context.sessionId == nil or context.sessionId <= 0 then -- 513
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user requires a session"}}) -- 513
		end -- 513
		local normalized = normalizeQuestionnaire(input) -- 520
		if not normalized.success then -- 520
			return ____awaiter_resolve(nil, {output = normalized}) -- 520
		end -- 520
		local result = __TS__Await(context.services:publishQuestionnaire({sessionId = context.sessionId, taskId = context.taskId, step = context.step, schema = normalized.schema})) -- 522
		if not result.success then -- 522
			return ____awaiter_resolve(nil, {output = result}) -- 522
		end -- 522
		context.workflow.waitingQuestionnaireId = result.questionnaireId -- 529
		return ____awaiter_resolve(nil, {output = {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}, control = {waitForUser = true, questionnaireId = result.questionnaireId}}) -- 529
	end) -- 529
end -- 513
local function spawnAgent(context, input) -- 536
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 536
		local prompt = type(input.prompt) == "string" and __TS__StringTrim(input.prompt) or "" -- 537
		if prompt == "" then -- 537
			if context.workflow.hasSpawnedSubAgentThisTask == true then -- 537
				return ____awaiter_resolve(nil, {output = {success = false, message = "Sub-agent results arrive asynchronously as handoffs; listing is rejected for the rest of this task after a successful spawn. Finish this turn instead."}}) -- 537
			end -- 537
			if context.services.listSubAgents == nil then -- 537
				return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent listing is not available in this runtime"}}) -- 537
			end -- 537
			if context.sessionId == nil or context.sessionId <= 0 then -- 537
				return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent listing requires a current session"}}) -- 537
			end -- 537
			local result = __TS__Await(context.services:listSubAgents({ -- 549
				sessionId = context.sessionId, -- 550
				projectRoot = context.workingDir, -- 551
				status = type(input.status) == "string" and input.status or nil, -- 552
				limit = type(input.limit) == "number" and input.limit or nil, -- 553
				offset = type(input.offset) == "number" and input.offset or nil, -- 554
				query = type(input.query) == "string" and input.query or nil -- 555
			})) -- 555
			return ____awaiter_resolve(nil, {output = result}) -- 555
		end -- 555
		if context.services.spawnSubAgent == nil then -- 555
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent dispatch is not available in this runtime"}}) -- 555
		end -- 555
		if context.sessionId == nil or context.sessionId <= 0 then -- 555
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent dispatch requires a parent session"}}) -- 555
		end -- 555
		local filesHint = __TS__ArrayIsArray(input.filesHint) and __TS__ArrayFilter( -- 566
			input.filesHint, -- 567
			function(____, item) return type(item) == "string" end -- 567
		) or nil -- 567
		local result = __TS__Await(context.services:spawnSubAgent({ -- 569
			parentSessionId = context.sessionId, -- 570
			projectRoot = context.workingDir, -- 571
			title = type(input.title) == "string" and input.title or "Sub", -- 572
			prompt = prompt, -- 573
			expectedOutput = type(input.expectedOutput) == "string" and input.expectedOutput or nil, -- 574
			filesHint = filesHint, -- 575
			disabledAgentTools = context.disabledAgentTools -- 576
		})) -- 576
		if not result.success then -- 576
			return ____awaiter_resolve(nil, {output = result}) -- 576
		end -- 576
		context.workflow.hasSpawnedSubAgentThisTask = true -- 579
		return ____awaiter_resolve(nil, {output = { -- 579
			success = true, -- 582
			sessionId = result.sessionId, -- 583
			taskId = result.taskId, -- 584
			title = result.title, -- 585
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not use the listing form in this task; results arrive as asynchronous handoffs." -- 586
		}, control = {spawnedSubAgent = true}}) -- 586
	end) -- 586
end -- 536
local function finish(_context, input) -- 592
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 592
		local message = type(input.message) == "string" and __TS__StringTrim(input.message) or "" -- 593
		return ____awaiter_resolve( -- 593
			nil, -- 593
			{ -- 594
				output = {success = true, message = message}, -- 595
				control = { -- 596
					concludeTask = true, -- 597
					finalMessage = message, -- 598
					completion = AgentUtils.normalizeAgentCompletionReport(input) -- 599
				} -- 599
			} -- 599
		) -- 599
	end) -- 599
end -- 592
local function analyzeImageHandler(context, input) -- 604
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 604
		local visionContext = context.visionTaskContext or "" -- 605
		if type(input.context) == "string" and __TS__StringTrim(input.context) ~= "" then -- 605
			visionContext = visionContext == "" and input.context or (visionContext .. "\n\n") .. input.context -- 607
		end -- 607
		return ____awaiter_resolve( -- 607
			nil, -- 607
			{output = __TS__Await(analyzeImage({ -- 609
				workingDir = context.workingDir, -- 610
				taskId = context.taskId, -- 611
				sessionId = context.sessionId, -- 612
				binding = context.visionBinding, -- 613
				paths = input.paths, -- 614
				question = input.question, -- 615
				criteria = input.criteria, -- 616
				context = visionContext, -- 617
				isCancelled = function() return context.cancellation:isCancelled() end -- 618
			}))} -- 618
		) -- 618
	end) -- 618
end -- 604
____exports.AGENT_TOOL_HANDLERS = { -- 622
	read_file = readFile, -- 623
	grep_files = grepFiles, -- 624
	search_dora_doc = searchDoraDoc, -- 625
	build = build, -- 626
	fetch_url = fetchUrl, -- 627
	execute_command = executeCommand, -- 628
	analyze_image = analyzeImageHandler, -- 629
	edit_file = editFile, -- 630
	ask_user = askUser, -- 631
	spawn_agent = spawnAgent, -- 632
	finish = finish -- 633
} -- 633
return ____exports -- 633