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
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
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
		local ____opt_39 = output.godotImports -- 267
		if ____opt_39 and __TS__ArraySome( -- 267
			output.godotImports, -- 269
			function(____, batch) return batch.importedCount > 0 end -- 269
		) then -- 269
			context.workflow.unbuiltEdits = true -- 270
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 271
		end -- 271
		if output.success and mode == "lua" then -- 271
			updateDeterministicTestState(context, output.output) -- 274
		end -- 274
		return ____awaiter_resolve(nil, {output = output}) -- 274
	end) -- 274
end -- 255
local function editFile(context, input) -- 296
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 296
		local operations = getAgentFileEditInputs(input) -- 297
		local isBatch = __TS__ArrayIsArray(input.edits) -- 298
		if #operations == 0 then -- 298
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing edit operations"}}) -- 298
		end -- 298
		local staged = {} -- 300
		local results = {} -- 301
		local successfulOperations = {} -- 302
		local function failOperation(index, path, code, message) -- 303
			results[#results + 1] = { -- 304
				index = index, -- 304
				path = path, -- 304
				success = false, -- 304
				code = code, -- 304
				message = message -- 304
			} -- 304
		end -- 303
		do -- 303
			local i = 0 -- 307
			while i < #operations do -- 307
				do -- 307
					local operation = operations[i + 1] -- 308
					local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 309
					if path == "" then -- 309
						failOperation(i, path, "INVALID_EDIT", "path is required") -- 311
						goto __continue66 -- 312
					end -- 312
					if operation.oldStr == operation.newStr then -- 312
						failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ") -- 315
						goto __continue66 -- 316
					end -- 316
					local stagedIndex = -1 -- 318
					do -- 318
						local j = 0 -- 319
						while j < #staged do -- 319
							if staged[j + 1].path == path then -- 319
								stagedIndex = j -- 321
								break -- 322
							end -- 322
							j = j + 1 -- 319
						end -- 319
					end -- 319
					if stagedIndex < 0 then -- 319
						local targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path) -- 326
						if not targetState.success then -- 326
							failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message) -- 328
							goto __continue66 -- 329
						end -- 329
						staged[#staged + 1] = { -- 331
							path = path, -- 332
							initialExists = targetState.exists, -- 333
							exists = targetState.exists, -- 334
							content = targetState.content, -- 335
							changed = false -- 336
						} -- 336
						stagedIndex = #staged - 1 -- 338
					end -- 338
					local target = staged[stagedIndex + 1] -- 340
					local guardDenial = getAgentFileEditPlanGuardDenial(context, operation) -- 341
					if guardDenial ~= nil then -- 341
						failOperation(i, path, guardDenial.code, guardDenial.message) -- 343
						goto __continue66 -- 344
					end -- 344
					local mode = "" -- 346
					if operation.oldStr == "" then -- 346
						if target.exists and AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr) then -- 346
							failOperation(i, path, "DUPLICATE_WHOLE_FILE", "rewrite rejected: the complete current file appears more than once in the replacement for " .. path) -- 349
							goto __continue66 -- 350
						end -- 350
						mode = target.exists and "overwrite" or "create" -- 352
						target.exists = true -- 353
						target.content = operation.newStr -- 354
					else -- 354
						if not target.exists then -- 354
							failOperation(i, path, "FILE_NOT_FOUND", ("read file failed: " .. path) .. " does not exist; use old_str=\"\" to create it earlier in the batch") -- 357
							goto __continue66 -- 358
						end -- 358
						local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content) -- 360
						local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr) -- 361
						local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr) -- 362
						local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 363
						if occurrences == 0 then -- 363
							local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 365
							if not indentTolerant.success then -- 365
								failOperation(i, path, "TEXT_NOT_FOUND", indentTolerant.message) -- 367
								goto __continue66 -- 368
							end -- 368
							target.content = indentTolerant.content -- 370
							mode = "replace_indent_tolerant" -- 371
						else -- 371
							if occurrences > 1 then -- 371
								failOperation( -- 374
									i, -- 374
									path, -- 374
									"AMBIGUOUS_MATCH", -- 374
									((("old_str appears " .. tostring(occurrences)) .. " times in ") .. path) .. ". Provide more context to identify one target." -- 374
								) -- 374
								goto __continue66 -- 375
							end -- 375
							target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 377
							mode = "replace" -- 378
						end -- 378
					end -- 378
					target.changed = true -- 381
					results[#results + 1] = {index = i, path = path, success = true, mode = mode} -- 382
					successfulOperations[#successfulOperations + 1] = operation -- 383
				end -- 383
				::__continue66:: -- 383
				i = i + 1 -- 307
			end -- 307
		end -- 307
		local changedTargets = __TS__ArrayFilter( -- 386
			staged, -- 386
			function(____, item) return item.changed end -- 386
		) -- 386
		if #changedTargets == 0 then -- 386
			local firstFailure = results[1] -- 388
			return ____awaiter_resolve(nil, {output = isBatch and ({ -- 388
				success = false, -- 391
				changed = false, -- 392
				mode = "batch", -- 393
				operationCount = #operations, -- 394
				succeededOperationCount = 0, -- 395
				failedOperationCount = #results, -- 396
				results = results, -- 397
				actualSaved = false -- 398
			}) or ({success = false, code = firstFailure and firstFailure.code, message = firstFailure and firstFailure.message or "edit failed", actualSaved = false})}) -- 398
		end -- 398
		local changes = __TS__ArrayMap( -- 408
			changedTargets, -- 408
			function(____, item) return {path = item.path, op = item.initialExists and "write" or "create", content = item.content} end -- 408
		) -- 408
		local applyRes = Tools.applyFileChanges( -- 413
			context.taskId, -- 413
			context.workingDir, -- 413
			changes, -- 413
			{ -- 413
				summary = isBatch and ((((("batch edit " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files via edit_file" or ((tostring(results[1].mode) .. " ") .. changedTargets[1].path) .. " via edit_file", -- 414
				toolName = "edit_file" -- 417
			} -- 417
		) -- 417
		if not applyRes.success then -- 417
			return ____awaiter_resolve( -- 417
				nil, -- 417
				{output = __TS__ObjectAssign({success = false, message = ((isBatch and "batch edit" or "write file") .. " failed: ") .. applyRes.message, actualSaved = false}, isBatch and ({results = results}) or ({}))} -- 420
			) -- 420
		end -- 420
		local files = __TS__ArrayMap( -- 423
			changes, -- 423
			function(____, change) return {path = change.path, op = change.op} end -- 423
		) -- 423
		local output -- 424
		if not isBatch then -- 424
			output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[1].path, { -- 426
				success = true, -- 427
				changed = true, -- 428
				mode = results[1].mode, -- 429
				checkpointId = applyRes.checkpointId, -- 430
				checkpointSeq = applyRes.checkpointSeq, -- 431
				files = files -- 432
			}) -- 432
		else -- 432
			local totalCharacters = 0 -- 435
			local actualSaved = true -- 436
			for ____, item in ipairs(changedTargets) do -- 437
				local current = Tools.readFileRaw(context.workingDir, item.path) -- 438
				if not current.success or current.content ~= item.content then -- 438
					actualSaved = false -- 439
				end -- 439
				if current.success then -- 439
					totalCharacters = totalCharacters + #current.content -- 440
				end -- 440
			end -- 440
			output = { -- 442
				success = true, -- 443
				changed = true, -- 444
				mode = "batch", -- 445
				operationCount = #operations, -- 446
				succeededOperationCount = #successfulOperations, -- 447
				failedOperationCount = #operations - #successfulOperations, -- 448
				partial = #successfulOperations < #operations, -- 449
				fileCount = #changedTargets, -- 450
				checkpointId = applyRes.checkpointId, -- 451
				checkpointSeq = applyRes.checkpointSeq, -- 452
				files = files, -- 453
				results = results, -- 454
				actualSaved = actualSaved, -- 455
				actualSavedCharacters = totalCharacters, -- 456
				currentFileExists = actualSaved, -- 457
				currentCharacters = totalCharacters, -- 458
				currentState = actualSaved and ((((("saved " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files" or "one or more batch file states could not be verified after commit" -- 459
			} -- 459
		end -- 459
		local authoredOperations = 0 -- 465
		local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 466
		for ____, operation in ipairs(successfulOperations) do -- 467
			do -- 467
				local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 468
				if AgentRuntimePolicy.isAgentInternalDocumentPath(path) then -- 468
					goto __continue94 -- 469
				end -- 469
				authoredOperations = authoredOperations + 1 -- 470
				if __TS__ArrayIndexOf(editedPaths, path) < 0 then -- 470
					editedPaths[#editedPaths + 1] = path -- 471
				end -- 471
			end -- 471
			::__continue94:: -- 471
		end -- 471
		if authoredOperations > 0 then -- 471
			context.workflow.unbuiltEdits = true -- 474
			context.workflow.lastBuildSucceeded = false -- 475
			if context.workflow.failedTestNeedsBuild == true then -- 475
				context.workflow.failedTestHasSourceEdit = true -- 476
			end -- 476
			context.workflow.editedPathsSinceBuild = editedPaths -- 477
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + authoredOperations -- 478
		end -- 478
		return ____awaiter_resolve(nil, {output = output}) -- 478
	end) -- 478
end -- 296
local function deleteFile(context, input) -- 483
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 483
		local targetFile = type(input.target_file) == "string" and input.target_file or "" -- 484
		if __TS__StringTrim(targetFile) == "" then -- 484
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing target_file"}}) -- 484
		end -- 484
		local normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile) -- 486
		local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 487
		local result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 488
		if not result.success then -- 488
			return ____awaiter_resolve(nil, {output = result}) -- 488
		end -- 488
		if not isInternalDocumentEdit then -- 488
			context.workflow.unbuiltEdits = true -- 494
			context.workflow.lastBuildSucceeded = false -- 495
			if context.workflow.failedTestNeedsBuild == true then -- 495
				context.workflow.failedTestHasSourceEdit = true -- 496
			end -- 496
			local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 497
			if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 497
				editedPaths[#editedPaths + 1] = normalizedTargetFile -- 498
			end -- 498
			context.workflow.editedPathsSinceBuild = editedPaths -- 499
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 500
		end -- 500
		local ____result_checkpointed_46 = result.checkpointed -- 507
		local ____result_reversible_47 = result.reversible -- 508
		local ____result_binary_48 = result.binary -- 509
		local ____temp_49 = result.checkpointed and result.checkpointId or nil -- 510
		local ____temp_50 = result.checkpointed and result.checkpointSeq or nil -- 511
		local ____result_checkpointed_45 -- 512
		if result.checkpointed then -- 512
			____result_checkpointed_45 = nil -- 512
		else -- 512
			____result_checkpointed_45 = result.message -- 512
		end -- 512
		return ____awaiter_resolve(nil, {output = { -- 512
			success = true, -- 504
			changed = true, -- 505
			mode = "delete", -- 506
			checkpointed = ____result_checkpointed_46, -- 507
			reversible = ____result_reversible_47, -- 508
			binary = ____result_binary_48, -- 509
			checkpointId = ____temp_49, -- 510
			checkpointSeq = ____temp_50, -- 511
			message = ____result_checkpointed_45, -- 512
			files = {{path = targetFile, op = "delete"}} -- 513
		}}) -- 513
	end) -- 513
end -- 483
local function askUser(context, input) -- 518
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 518
		if context.services.publishQuestionnaire == nil then -- 518
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user is not available in this runtime"}}) -- 518
		end -- 518
		if context.sessionId == nil or context.sessionId <= 0 then -- 518
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user requires a session"}}) -- 518
		end -- 518
		local normalized = normalizeQuestionnaire(input) -- 525
		if not normalized.success then -- 525
			return ____awaiter_resolve(nil, {output = normalized}) -- 525
		end -- 525
		local result = __TS__Await(context.services:publishQuestionnaire({sessionId = context.sessionId, taskId = context.taskId, step = context.step, schema = normalized.schema})) -- 527
		if not result.success then -- 527
			return ____awaiter_resolve(nil, {output = result}) -- 527
		end -- 527
		context.workflow.waitingQuestionnaireId = result.questionnaireId -- 534
		return ____awaiter_resolve(nil, {output = {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}, control = {waitForUser = true, questionnaireId = result.questionnaireId}}) -- 534
	end) -- 534
end -- 518
local function spawnSubAgent(context, input) -- 541
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 541
		if context.services.spawnSubAgent == nil then -- 541
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent is not available in this runtime"}}) -- 541
		end -- 541
		if context.sessionId == nil or context.sessionId <= 0 then -- 541
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent requires a parent session"}}) -- 541
		end -- 541
		local filesHint = __TS__ArrayIsArray(input.filesHint) and __TS__ArrayFilter( -- 548
			input.filesHint, -- 549
			function(____, item) return type(item) == "string" end -- 549
		) or nil -- 549
		local result = __TS__Await(context.services:spawnSubAgent({ -- 551
			parentSessionId = context.sessionId, -- 552
			projectRoot = context.workingDir, -- 553
			title = type(input.title) == "string" and input.title or "Sub", -- 554
			prompt = type(input.prompt) == "string" and input.prompt or "", -- 555
			expectedOutput = type(input.expectedOutput) == "string" and input.expectedOutput or nil, -- 556
			filesHint = filesHint, -- 557
			disabledAgentTools = context.disabledAgentTools -- 558
		})) -- 558
		if not result.success then -- 558
			return ____awaiter_resolve(nil, {output = result}) -- 558
		end -- 558
		context.workflow.hasSpawnedSubAgentThisTask = true -- 561
		return ____awaiter_resolve(nil, {output = { -- 561
			success = true, -- 564
			sessionId = result.sessionId, -- 565
			taskId = result.taskId, -- 566
			title = result.title, -- 567
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 568
		}, control = {spawnedSubAgent = true}}) -- 568
	end) -- 568
end -- 541
local function listSubAgents(context, input) -- 574
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 574
		if context.services.listSubAgents == nil then -- 574
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents is not available in this runtime"}}) -- 574
		end -- 574
		if context.sessionId == nil or context.sessionId <= 0 then -- 574
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents requires a current session"}}) -- 574
		end -- 574
		local result = __TS__Await(context.services:listSubAgents({ -- 581
			sessionId = context.sessionId, -- 582
			projectRoot = context.workingDir, -- 583
			status = type(input.status) == "string" and input.status or nil, -- 584
			limit = type(input.limit) == "number" and input.limit or nil, -- 585
			offset = type(input.offset) == "number" and input.offset or nil, -- 586
			query = type(input.query) == "string" and input.query or nil -- 587
		})) -- 587
		return ____awaiter_resolve(nil, {output = result}) -- 587
	end) -- 587
end -- 574
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
	glob_files = globFiles, -- 625
	search_dora_doc = searchDoraDoc, -- 626
	build = build, -- 627
	fetch_url = fetchUrl, -- 628
	execute_command = executeCommand, -- 629
	analyze_image = analyzeImageHandler, -- 630
	edit_file = editFile, -- 631
	delete_file = deleteFile, -- 632
	ask_user = askUser, -- 633
	spawn_sub_agent = spawnSubAgent, -- 634
	list_sub_agents = listSubAgents, -- 635
	finish = finish -- 636
} -- 636
return ____exports -- 636