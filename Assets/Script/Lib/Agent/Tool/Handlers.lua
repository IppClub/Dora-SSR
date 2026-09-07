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
local AgentConfig = require("Agent.Config") -- 3
local ____Questionnaire = require("Agent.Questionnaire") -- 4
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
			) -- 92
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
		local succeeded = 0 -- 117
		do -- 117
			local i = 0 -- 118
			while i < #paths do -- 118
				local result = __TS__Await(Tools.build({ -- 119
					workDir = context.workingDir, -- 120
					path = paths[i + 1], -- 121
					isCancelled = function() return context.cancellation:isCancelled() end -- 122
				})) -- 122
				local rawResult = result -- 124
				if result.success then -- 124
					succeeded = succeeded + 1 -- 125
				end -- 125
				rawResults[#rawResults + 1] = rawResult -- 126
				results[#results + 1] = __TS__ObjectAssign({index = i, path = paths[i + 1]}, rawResult) -- 127
				if context.cancellation:isCancelled() then -- 127
					break -- 128
				end -- 128
				i = i + 1 -- 118
			end -- 118
		end -- 118
		local output = { -- 130
			success = succeeded == #paths, -- 131
			partial = succeeded > 0 and succeeded < #paths, -- 132
			mode = "batch", -- 133
			requestedBuildCount = #paths, -- 134
			buildCount = #results, -- 135
			succeededBuildCount = succeeded, -- 136
			failedBuildCount = #results - succeeded, -- 137
			skippedBuildCount = #paths - #results, -- 138
			results = results -- 139
		} -- 139
		context.workflow.unbuiltEdits = false -- 141
		context.workflow.editsSinceBuild = 0 -- 142
		context.workflow.editedPathsSinceBuild = {} -- 143
		context.workflow.hasBuilt = true -- 144
		context.workflow.lastBuildSucceeded = output.success == true -- 145
		if output.success == true and context.workflow.freshProjectBuildPending == true then -- 145
			context.workflow.freshProjectBuildPending = false -- 147
		end -- 147
		context.workflow.apiSearchesSinceBuild = 0 -- 149
		context.workflow.buildRepairPending = false -- 150
		if output.success ~= true then -- 150
			do -- 150
				local r = 0 -- 152
				while r < #rawResults do -- 152
					local messages = rawResults[r + 1].messages -- 153
					do -- 153
						local i = 0 -- 154
						while i < (messages and #messages or 0) do -- 154
							if messages[i + 1].success == false and messages[i + 1].file ~= "" then -- 154
								context.workflow.buildRepairPending = true -- 156
								break -- 157
							end -- 157
							i = i + 1 -- 154
						end -- 154
					end -- 154
					r = r + 1 -- 152
				end -- 152
			end -- 152
		end -- 152
		if output.success == true and context.workflow.failedTestNeedsBuild == true and context.workflow.failedTestHasSourceEdit == true then -- 152
			context.workflow.failedTestNeedsBuild = false -- 163
			context.workflow.failedTestHasSourceEdit = false -- 164
		end -- 164
		return ____awaiter_resolve(nil, {output = output}) -- 164
	end) -- 164
end -- 113
local function fetchUrl(context, input) -- 169
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 169
		local output = __TS__Await(Tools.fetchUrl({ -- 170
			workDir = context.workingDir, -- 171
			url = type(input.url) == "string" and input.url or "", -- 172
			target = type(input.target) == "string" and input.target or "", -- 173
			isCancelled = function() return context.cancellation:isCancelled() end, -- 174
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 175
		})) -- 175
		return ____awaiter_resolve(nil, {output = output}) -- 175
	end) -- 175
end -- 169
local function updateDeterministicTestState(context, output) -- 180
	local deterministicFailure = false -- 181
	local deterministicPass = false -- 182
	local outputLines = __TS__StringSplit(output, "\n") -- 183
	do -- 183
		local i = 0 -- 184
		while i < #outputLines and not deterministicFailure do -- 184
			local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 185
			if line == "passed" then -- 185
				deterministicPass = true -- 186
			end -- 186
			if line == "failed" then -- 186
				deterministicFailure = true -- 188
				break -- 189
			end -- 189
			local searchFrom = 0 -- 191
			while searchFrom < #line do -- 191
				local failedIndex = (string.find( -- 193
					line, -- 193
					"failed", -- 193
					math.max(searchFrom + 1, 1), -- 193
					true -- 193
				) or 0) - 1 -- 193
				if failedIndex < 0 then -- 193
					break -- 194
				end -- 194
				local after = failedIndex + #"failed" -- 195
				while after < #line do -- 195
					local ch = __TS__StringSlice(line, after, after + 1) -- 197
					if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 197
						break -- 198
					end -- 198
					after = after + 1 -- 199
				end -- 199
				local afterEnd = after -- 201
				while afterEnd < #line do -- 201
					local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 203
					if ch < "0" or ch > "9" then -- 203
						break -- 204
					end -- 204
					afterEnd = afterEnd + 1 -- 205
				end -- 205
				local count -- 207
				if afterEnd > after then -- 207
					count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 209
				else -- 209
					local before = failedIndex - 1 -- 211
					while before >= 0 do -- 211
						local ch = __TS__StringSlice(line, before, before + 1) -- 213
						if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 213
							break -- 214
						end -- 214
						before = before - 1 -- 215
					end -- 215
					local beforeEnd = before + 1 -- 217
					while before >= 0 do -- 217
						local ch = __TS__StringSlice(line, before, before + 1) -- 219
						if ch < "0" or ch > "9" then -- 219
							break -- 220
						end -- 220
						before = before - 1 -- 221
					end -- 221
					if beforeEnd > before + 1 then -- 221
						count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 223
					end -- 223
				end -- 223
				if count ~= nil and count > 0 then -- 223
					deterministicFailure = true -- 226
					break -- 227
				end -- 227
				searchFrom = failedIndex + #"failed" -- 229
			end -- 229
			i = i + 1 -- 184
		end -- 184
	end -- 184
	if deterministicFailure then -- 184
		context.workflow.failedTestNeedsBuild = true -- 233
		context.workflow.failedTestHasSourceEdit = false -- 234
	elseif deterministicPass then -- 234
		context.workflow.failedTestNeedsBuild = false -- 236
		context.workflow.failedTestHasSourceEdit = false -- 237
	end -- 237
end -- 180
local function executeCommand(context, input) -- 241
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 241
		local mode = type(input.mode) == "string" and input.mode or "" -- 242
		local output = __TS__Await(Tools.executeCommand({ -- 243
			workDir = context.workingDir, -- 244
			taskId = context.taskId, -- 245
			mode = mode, -- 246
			code = type(input.code) == "string" and input.code or nil, -- 247
			command = type(input.command) == "string" and input.command or nil, -- 248
			cwd = type(input.cwd) == "string" and input.cwd or nil, -- 249
			timeoutSeconds = type(input.timeoutSeconds) == "number" and input.timeoutSeconds or nil, -- 250
			isCancelled = function() return context.cancellation:isCancelled() end, -- 251
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 252
		})) -- 252
		if output.success and mode == "lua" then -- 252
			updateDeterministicTestState(context, output.output) -- 255
		end -- 255
		return ____awaiter_resolve(nil, {output = output}) -- 255
	end) -- 255
end -- 241
local function editFile(context, input) -- 277
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 277
		local operations = getAgentFileEditInputs(input) -- 278
		local isBatch = __TS__ArrayIsArray(input.edits) -- 279
		if #operations == 0 then -- 279
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing edit operations"}}) -- 279
		end -- 279
		local staged = {} -- 281
		local results = {} -- 282
		local successfulOperations = {} -- 283
		local function failOperation(index, path, code, message) -- 284
			results[#results + 1] = { -- 285
				index = index, -- 285
				path = path, -- 285
				success = false, -- 285
				code = code, -- 285
				message = message -- 285
			} -- 285
		end -- 284
		do -- 284
			local i = 0 -- 288
			while i < #operations do -- 288
				do -- 288
					local operation = operations[i + 1] -- 289
					local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 290
					if path == "" then -- 290
						failOperation(i, path, "INVALID_EDIT", "path is required") -- 292
						goto __continue60 -- 293
					end -- 293
					if operation.oldStr == operation.newStr then -- 293
						failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ") -- 296
						goto __continue60 -- 297
					end -- 297
					local stagedIndex = -1 -- 299
					do -- 299
						local j = 0 -- 300
						while j < #staged do -- 300
							if staged[j + 1].path == path then -- 300
								stagedIndex = j -- 302
								break -- 303
							end -- 303
							j = j + 1 -- 300
						end -- 300
					end -- 300
					if stagedIndex < 0 then -- 300
						local targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path) -- 307
						if not targetState.success then -- 307
							failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message) -- 309
							goto __continue60 -- 310
						end -- 310
						staged[#staged + 1] = { -- 312
							path = path, -- 313
							initialExists = targetState.exists, -- 314
							exists = targetState.exists, -- 315
							content = targetState.content, -- 316
							changed = false -- 317
						} -- 317
						stagedIndex = #staged - 1 -- 319
					end -- 319
					local target = staged[stagedIndex + 1] -- 321
					local guardDenial = getAgentFileEditPlanGuardDenial(context, operation) -- 322
					if guardDenial ~= nil then -- 322
						failOperation(i, path, guardDenial.code, guardDenial.message) -- 324
						goto __continue60 -- 325
					end -- 325
					local mode = "" -- 327
					if operation.oldStr == "" then -- 327
						if target.exists and AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr) then -- 327
							failOperation(i, path, "DUPLICATE_WHOLE_FILE", "rewrite rejected: the complete current file appears more than once in the replacement for " .. path) -- 330
							goto __continue60 -- 331
						end -- 331
						mode = target.exists and "overwrite" or "create" -- 333
						target.exists = true -- 334
						target.content = operation.newStr -- 335
					else -- 335
						if not target.exists then -- 335
							failOperation(i, path, "FILE_NOT_FOUND", ("read file failed: " .. path) .. " does not exist; use old_str=\"\" to create it earlier in the batch") -- 338
							goto __continue60 -- 339
						end -- 339
						local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content) -- 341
						local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr) -- 342
						local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr) -- 343
						local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 344
						if occurrences == 0 then -- 344
							local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 346
							if not indentTolerant.success then -- 346
								failOperation(i, path, "TEXT_NOT_FOUND", indentTolerant.message) -- 348
								goto __continue60 -- 349
							end -- 349
							target.content = indentTolerant.content -- 351
							mode = "replace_indent_tolerant" -- 352
						else -- 352
							if occurrences > 1 then -- 352
								failOperation( -- 355
									i, -- 355
									path, -- 355
									"AMBIGUOUS_MATCH", -- 355
									((("old_str appears " .. tostring(occurrences)) .. " times in ") .. path) .. ". Provide more context to identify one target." -- 355
								) -- 355
								goto __continue60 -- 356
							end -- 356
							target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 358
							mode = "replace" -- 359
						end -- 359
					end -- 359
					target.changed = true -- 362
					results[#results + 1] = {index = i, path = path, success = true, mode = mode} -- 363
					successfulOperations[#successfulOperations + 1] = operation -- 364
				end -- 364
				::__continue60:: -- 364
				i = i + 1 -- 288
			end -- 288
		end -- 288
		local changedTargets = __TS__ArrayFilter( -- 367
			staged, -- 367
			function(____, item) return item.changed end -- 367
		) -- 367
		if #changedTargets == 0 then -- 367
			local firstFailure = results[1] -- 369
			return ____awaiter_resolve(nil, {output = isBatch and ({ -- 369
				success = false, -- 372
				changed = false, -- 373
				mode = "batch", -- 374
				operationCount = #operations, -- 375
				succeededOperationCount = 0, -- 376
				failedOperationCount = #results, -- 377
				results = results, -- 378
				actualSaved = false -- 379
			}) or ({success = false, code = firstFailure and firstFailure.code, message = firstFailure and firstFailure.message or "edit failed", actualSaved = false})}) -- 379
		end -- 379
		local changes = __TS__ArrayMap( -- 389
			changedTargets, -- 389
			function(____, item) return {path = item.path, op = item.initialExists and "write" or "create", content = item.content} end -- 389
		) -- 389
		local applyRes = Tools.applyFileChanges( -- 394
			context.taskId, -- 394
			context.workingDir, -- 394
			changes, -- 394
			{ -- 394
				summary = isBatch and ((((("batch edit " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files via edit_file" or ((tostring(results[1].mode) .. " ") .. changedTargets[1].path) .. " via edit_file", -- 395
				toolName = "edit_file" -- 398
			} -- 398
		) -- 398
		if not applyRes.success then -- 398
			return ____awaiter_resolve( -- 398
				nil, -- 398
				{output = __TS__ObjectAssign({success = false, message = ((isBatch and "batch edit" or "write file") .. " failed: ") .. applyRes.message, actualSaved = false}, isBatch and ({results = results}) or ({}))} -- 401
			) -- 401
		end -- 401
		local files = __TS__ArrayMap( -- 404
			changes, -- 404
			function(____, change) return {path = change.path, op = change.op} end -- 404
		) -- 404
		local output -- 405
		if not isBatch then -- 405
			output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[1].path, { -- 407
				success = true, -- 408
				changed = true, -- 409
				mode = results[1].mode, -- 410
				checkpointId = applyRes.checkpointId, -- 411
				checkpointSeq = applyRes.checkpointSeq, -- 412
				files = files -- 413
			}) -- 413
		else -- 413
			local totalCharacters = 0 -- 416
			local actualSaved = true -- 417
			for ____, item in ipairs(changedTargets) do -- 418
				local current = Tools.readFileRaw(context.workingDir, item.path) -- 419
				if not current.success or current.content ~= item.content then -- 419
					actualSaved = false -- 420
				end -- 420
				if current.success then -- 420
					totalCharacters = totalCharacters + #current.content -- 421
				end -- 421
			end -- 421
			output = { -- 423
				success = true, -- 424
				changed = true, -- 425
				mode = "batch", -- 426
				operationCount = #operations, -- 427
				succeededOperationCount = #successfulOperations, -- 428
				failedOperationCount = #operations - #successfulOperations, -- 429
				partial = #successfulOperations < #operations, -- 430
				fileCount = #changedTargets, -- 431
				checkpointId = applyRes.checkpointId, -- 432
				checkpointSeq = applyRes.checkpointSeq, -- 433
				files = files, -- 434
				results = results, -- 435
				actualSaved = actualSaved, -- 436
				actualSavedCharacters = totalCharacters, -- 437
				currentFileExists = actualSaved, -- 438
				currentCharacters = totalCharacters, -- 439
				currentState = actualSaved and ((((("saved " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files" or "one or more batch file states could not be verified after commit" -- 440
			} -- 440
		end -- 440
		local authoredOperations = 0 -- 446
		local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 447
		for ____, operation in ipairs(successfulOperations) do -- 448
			do -- 448
				local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 449
				if AgentRuntimePolicy.isAgentInternalDocumentPath(path) then -- 449
					goto __continue88 -- 450
				end -- 450
				authoredOperations = authoredOperations + 1 -- 451
				if __TS__ArrayIndexOf(editedPaths, path) < 0 then -- 451
					editedPaths[#editedPaths + 1] = path -- 452
				end -- 452
			end -- 452
			::__continue88:: -- 452
		end -- 452
		if authoredOperations > 0 then -- 452
			context.workflow.unbuiltEdits = true -- 455
			context.workflow.lastBuildSucceeded = false -- 456
			if context.workflow.failedTestNeedsBuild == true then -- 456
				context.workflow.failedTestHasSourceEdit = true -- 457
			end -- 457
			context.workflow.editedPathsSinceBuild = editedPaths -- 458
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + authoredOperations -- 459
		end -- 459
		return ____awaiter_resolve(nil, {output = output}) -- 459
	end) -- 459
end -- 277
local function deleteFile(context, input) -- 464
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 464
		local targetFile = type(input.target_file) == "string" and input.target_file or "" -- 465
		if __TS__StringTrim(targetFile) == "" then -- 465
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing target_file"}}) -- 465
		end -- 465
		local normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile) -- 467
		local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 468
		local result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 469
		if not result.success then -- 469
			return ____awaiter_resolve(nil, {output = result}) -- 469
		end -- 469
		if not isInternalDocumentEdit then -- 469
			context.workflow.unbuiltEdits = true -- 475
			context.workflow.lastBuildSucceeded = false -- 476
			if context.workflow.failedTestNeedsBuild == true then -- 476
				context.workflow.failedTestHasSourceEdit = true -- 477
			end -- 477
			local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 478
			if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 478
				editedPaths[#editedPaths + 1] = normalizedTargetFile -- 479
			end -- 479
			context.workflow.editedPathsSinceBuild = editedPaths -- 480
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 481
		end -- 481
		local ____result_checkpointed_41 = result.checkpointed -- 488
		local ____result_reversible_42 = result.reversible -- 489
		local ____result_binary_43 = result.binary -- 490
		local ____temp_44 = result.checkpointed and result.checkpointId or nil -- 491
		local ____temp_45 = result.checkpointed and result.checkpointSeq or nil -- 492
		local ____result_checkpointed_40 -- 493
		if result.checkpointed then -- 493
			____result_checkpointed_40 = nil -- 493
		else -- 493
			____result_checkpointed_40 = result.message -- 493
		end -- 493
		return ____awaiter_resolve(nil, {output = { -- 493
			success = true, -- 485
			changed = true, -- 486
			mode = "delete", -- 487
			checkpointed = ____result_checkpointed_41, -- 488
			reversible = ____result_reversible_42, -- 489
			binary = ____result_binary_43, -- 490
			checkpointId = ____temp_44, -- 491
			checkpointSeq = ____temp_45, -- 492
			message = ____result_checkpointed_40, -- 493
			files = {{path = targetFile, op = "delete"}} -- 494
		}}) -- 494
	end) -- 494
end -- 464
local function askUser(context, input) -- 499
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 499
		if context.services.publishQuestionnaire == nil then -- 499
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user is not available in this runtime"}}) -- 499
		end -- 499
		if context.sessionId == nil or context.sessionId <= 0 then -- 499
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user requires a session"}}) -- 499
		end -- 499
		local normalized = normalizeQuestionnaire(input) -- 506
		if not normalized.success then -- 506
			return ____awaiter_resolve(nil, {output = normalized}) -- 506
		end -- 506
		local result = __TS__Await(context.services:publishQuestionnaire({sessionId = context.sessionId, taskId = context.taskId, step = context.step, schema = normalized.schema})) -- 508
		if not result.success then -- 508
			return ____awaiter_resolve(nil, {output = result}) -- 508
		end -- 508
		context.workflow.waitingQuestionnaireId = result.questionnaireId -- 515
		return ____awaiter_resolve(nil, {output = {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}, control = {waitForUser = true, questionnaireId = result.questionnaireId}}) -- 515
	end) -- 515
end -- 499
local function spawnSubAgent(context, input) -- 522
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 522
		if context.services.spawnSubAgent == nil then -- 522
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent is not available in this runtime"}}) -- 522
		end -- 522
		if context.sessionId == nil or context.sessionId <= 0 then -- 522
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent requires a parent session"}}) -- 522
		end -- 522
		local filesHint = __TS__ArrayIsArray(input.filesHint) and __TS__ArrayFilter( -- 529
			input.filesHint, -- 530
			function(____, item) return type(item) == "string" end -- 530
		) or nil -- 530
		local result = __TS__Await(context.services:spawnSubAgent({ -- 532
			parentSessionId = context.sessionId, -- 533
			projectRoot = context.workingDir, -- 534
			title = type(input.title) == "string" and input.title or "Sub", -- 535
			prompt = type(input.prompt) == "string" and input.prompt or "", -- 536
			expectedOutput = type(input.expectedOutput) == "string" and input.expectedOutput or nil, -- 537
			filesHint = filesHint, -- 538
			disabledAgentTools = context.disabledAgentTools -- 539
		})) -- 539
		if not result.success then -- 539
			return ____awaiter_resolve(nil, {output = result}) -- 539
		end -- 539
		context.workflow.hasSpawnedSubAgentThisTask = true -- 542
		return ____awaiter_resolve(nil, {output = { -- 542
			success = true, -- 545
			sessionId = result.sessionId, -- 546
			taskId = result.taskId, -- 547
			title = result.title, -- 548
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 549
		}, control = {spawnedSubAgent = true}}) -- 549
	end) -- 549
end -- 522
local function listSubAgents(context, input) -- 555
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 555
		if context.services.listSubAgents == nil then -- 555
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents is not available in this runtime"}}) -- 555
		end -- 555
		if context.sessionId == nil or context.sessionId <= 0 then -- 555
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents requires a current session"}}) -- 555
		end -- 555
		local result = __TS__Await(context.services:listSubAgents({ -- 562
			sessionId = context.sessionId, -- 563
			projectRoot = context.workingDir, -- 564
			status = type(input.status) == "string" and input.status or nil, -- 565
			limit = type(input.limit) == "number" and input.limit or nil, -- 566
			offset = type(input.offset) == "number" and input.offset or nil, -- 567
			query = type(input.query) == "string" and input.query or nil -- 568
		})) -- 568
		return ____awaiter_resolve(nil, {output = result}) -- 568
	end) -- 568
end -- 555
local function finish(_context, input) -- 573
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 573
		local message = type(input.message) == "string" and __TS__StringTrim(input.message) or "" -- 574
		return ____awaiter_resolve( -- 574
			nil, -- 574
			{ -- 575
				output = {success = true, message = message}, -- 576
				control = { -- 577
					concludeTask = true, -- 578
					finalMessage = message, -- 579
					completion = AgentUtils.normalizeAgentCompletionReport(input) -- 580
				} -- 580
			} -- 580
		) -- 580
	end) -- 580
end -- 573
local function analyzeImageHandler(context, input) -- 585
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 585
		local visionContext = context.visionTaskContext or "" -- 586
		if type(input.context) == "string" and __TS__StringTrim(input.context) ~= "" then -- 586
			visionContext = visionContext == "" and input.context or (visionContext .. "\n\n") .. input.context -- 588
		end -- 588
		return ____awaiter_resolve( -- 588
			nil, -- 588
			{output = __TS__Await(analyzeImage({ -- 590
				workingDir = context.workingDir, -- 591
				taskId = context.taskId, -- 592
				sessionId = context.sessionId, -- 593
				binding = context.visionBinding, -- 594
				paths = input.paths, -- 595
				question = input.question, -- 596
				criteria = input.criteria, -- 597
				context = visionContext, -- 598
				isCancelled = function() return context.cancellation:isCancelled() end -- 599
			}))} -- 599
		) -- 599
	end) -- 599
end -- 585
____exports.AGENT_TOOL_HANDLERS = { -- 603
	read_file = readFile, -- 604
	grep_files = grepFiles, -- 605
	glob_files = globFiles, -- 606
	search_dora_doc = searchDoraDoc, -- 607
	build = build, -- 608
	fetch_url = fetchUrl, -- 609
	execute_command = executeCommand, -- 610
	analyze_image = analyzeImageHandler, -- 611
	edit_file = editFile, -- 612
	delete_file = deleteFile, -- 613
	ask_user = askUser, -- 614
	spawn_sub_agent = spawnSubAgent, -- 615
	list_sub_agents = listSubAgents, -- 616
	finish = finish -- 617
} -- 617
return ____exports -- 617