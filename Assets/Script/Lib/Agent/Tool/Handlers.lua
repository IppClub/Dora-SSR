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
			docLanguage = context.useChineseResponse and "zh" or "en", -- 245
			taskId = context.taskId, -- 246
			mode = mode, -- 247
			code = type(input.code) == "string" and input.code or nil, -- 248
			command = type(input.command) == "string" and input.command or nil, -- 249
			cwd = type(input.cwd) == "string" and input.cwd or nil, -- 250
			timeoutSeconds = type(input.timeoutSeconds) == "number" and input.timeoutSeconds or nil, -- 251
			isCancelled = function() return context.cancellation:isCancelled() end, -- 252
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 253
		})) -- 253
		if output.success and mode == "lua" then -- 253
			updateDeterministicTestState(context, output.output) -- 256
		end -- 256
		return ____awaiter_resolve(nil, {output = output}) -- 256
	end) -- 256
end -- 241
local function editFile(context, input) -- 278
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 278
		local operations = getAgentFileEditInputs(input) -- 279
		local isBatch = __TS__ArrayIsArray(input.edits) -- 280
		if #operations == 0 then -- 280
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing edit operations"}}) -- 280
		end -- 280
		local staged = {} -- 282
		local results = {} -- 283
		local successfulOperations = {} -- 284
		local function failOperation(index, path, code, message) -- 285
			results[#results + 1] = { -- 286
				index = index, -- 286
				path = path, -- 286
				success = false, -- 286
				code = code, -- 286
				message = message -- 286
			} -- 286
		end -- 285
		do -- 285
			local i = 0 -- 289
			while i < #operations do -- 289
				do -- 289
					local operation = operations[i + 1] -- 290
					local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 291
					if path == "" then -- 291
						failOperation(i, path, "INVALID_EDIT", "path is required") -- 293
						goto __continue60 -- 294
					end -- 294
					if operation.oldStr == operation.newStr then -- 294
						failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ") -- 297
						goto __continue60 -- 298
					end -- 298
					local stagedIndex = -1 -- 300
					do -- 300
						local j = 0 -- 301
						while j < #staged do -- 301
							if staged[j + 1].path == path then -- 301
								stagedIndex = j -- 303
								break -- 304
							end -- 304
							j = j + 1 -- 301
						end -- 301
					end -- 301
					if stagedIndex < 0 then -- 301
						local targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path) -- 308
						if not targetState.success then -- 308
							failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message) -- 310
							goto __continue60 -- 311
						end -- 311
						staged[#staged + 1] = { -- 313
							path = path, -- 314
							initialExists = targetState.exists, -- 315
							exists = targetState.exists, -- 316
							content = targetState.content, -- 317
							changed = false -- 318
						} -- 318
						stagedIndex = #staged - 1 -- 320
					end -- 320
					local target = staged[stagedIndex + 1] -- 322
					local guardDenial = getAgentFileEditPlanGuardDenial(context, operation) -- 323
					if guardDenial ~= nil then -- 323
						failOperation(i, path, guardDenial.code, guardDenial.message) -- 325
						goto __continue60 -- 326
					end -- 326
					local mode = "" -- 328
					if operation.oldStr == "" then -- 328
						if target.exists and AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr) then -- 328
							failOperation(i, path, "DUPLICATE_WHOLE_FILE", "rewrite rejected: the complete current file appears more than once in the replacement for " .. path) -- 331
							goto __continue60 -- 332
						end -- 332
						mode = target.exists and "overwrite" or "create" -- 334
						target.exists = true -- 335
						target.content = operation.newStr -- 336
					else -- 336
						if not target.exists then -- 336
							failOperation(i, path, "FILE_NOT_FOUND", ("read file failed: " .. path) .. " does not exist; use old_str=\"\" to create it earlier in the batch") -- 339
							goto __continue60 -- 340
						end -- 340
						local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content) -- 342
						local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr) -- 343
						local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr) -- 344
						local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 345
						if occurrences == 0 then -- 345
							local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 347
							if not indentTolerant.success then -- 347
								failOperation(i, path, "TEXT_NOT_FOUND", indentTolerant.message) -- 349
								goto __continue60 -- 350
							end -- 350
							target.content = indentTolerant.content -- 352
							mode = "replace_indent_tolerant" -- 353
						else -- 353
							if occurrences > 1 then -- 353
								failOperation( -- 356
									i, -- 356
									path, -- 356
									"AMBIGUOUS_MATCH", -- 356
									((("old_str appears " .. tostring(occurrences)) .. " times in ") .. path) .. ". Provide more context to identify one target." -- 356
								) -- 356
								goto __continue60 -- 357
							end -- 357
							target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 359
							mode = "replace" -- 360
						end -- 360
					end -- 360
					target.changed = true -- 363
					results[#results + 1] = {index = i, path = path, success = true, mode = mode} -- 364
					successfulOperations[#successfulOperations + 1] = operation -- 365
				end -- 365
				::__continue60:: -- 365
				i = i + 1 -- 289
			end -- 289
		end -- 289
		local changedTargets = __TS__ArrayFilter( -- 368
			staged, -- 368
			function(____, item) return item.changed end -- 368
		) -- 368
		if #changedTargets == 0 then -- 368
			local firstFailure = results[1] -- 370
			return ____awaiter_resolve(nil, {output = isBatch and ({ -- 370
				success = false, -- 373
				changed = false, -- 374
				mode = "batch", -- 375
				operationCount = #operations, -- 376
				succeededOperationCount = 0, -- 377
				failedOperationCount = #results, -- 378
				results = results, -- 379
				actualSaved = false -- 380
			}) or ({success = false, code = firstFailure and firstFailure.code, message = firstFailure and firstFailure.message or "edit failed", actualSaved = false})}) -- 380
		end -- 380
		local changes = __TS__ArrayMap( -- 390
			changedTargets, -- 390
			function(____, item) return {path = item.path, op = item.initialExists and "write" or "create", content = item.content} end -- 390
		) -- 390
		local applyRes = Tools.applyFileChanges( -- 395
			context.taskId, -- 395
			context.workingDir, -- 395
			changes, -- 395
			{ -- 395
				summary = isBatch and ((((("batch edit " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files via edit_file" or ((tostring(results[1].mode) .. " ") .. changedTargets[1].path) .. " via edit_file", -- 396
				toolName = "edit_file" -- 399
			} -- 399
		) -- 399
		if not applyRes.success then -- 399
			return ____awaiter_resolve( -- 399
				nil, -- 399
				{output = __TS__ObjectAssign({success = false, message = ((isBatch and "batch edit" or "write file") .. " failed: ") .. applyRes.message, actualSaved = false}, isBatch and ({results = results}) or ({}))} -- 402
			) -- 402
		end -- 402
		local files = __TS__ArrayMap( -- 405
			changes, -- 405
			function(____, change) return {path = change.path, op = change.op} end -- 405
		) -- 405
		local output -- 406
		if not isBatch then -- 406
			output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[1].path, { -- 408
				success = true, -- 409
				changed = true, -- 410
				mode = results[1].mode, -- 411
				checkpointId = applyRes.checkpointId, -- 412
				checkpointSeq = applyRes.checkpointSeq, -- 413
				files = files -- 414
			}) -- 414
		else -- 414
			local totalCharacters = 0 -- 417
			local actualSaved = true -- 418
			for ____, item in ipairs(changedTargets) do -- 419
				local current = Tools.readFileRaw(context.workingDir, item.path) -- 420
				if not current.success or current.content ~= item.content then -- 420
					actualSaved = false -- 421
				end -- 421
				if current.success then -- 421
					totalCharacters = totalCharacters + #current.content -- 422
				end -- 422
			end -- 422
			output = { -- 424
				success = true, -- 425
				changed = true, -- 426
				mode = "batch", -- 427
				operationCount = #operations, -- 428
				succeededOperationCount = #successfulOperations, -- 429
				failedOperationCount = #operations - #successfulOperations, -- 430
				partial = #successfulOperations < #operations, -- 431
				fileCount = #changedTargets, -- 432
				checkpointId = applyRes.checkpointId, -- 433
				checkpointSeq = applyRes.checkpointSeq, -- 434
				files = files, -- 435
				results = results, -- 436
				actualSaved = actualSaved, -- 437
				actualSavedCharacters = totalCharacters, -- 438
				currentFileExists = actualSaved, -- 439
				currentCharacters = totalCharacters, -- 440
				currentState = actualSaved and ((((("saved " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files" or "one or more batch file states could not be verified after commit" -- 441
			} -- 441
		end -- 441
		local authoredOperations = 0 -- 447
		local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 448
		for ____, operation in ipairs(successfulOperations) do -- 449
			do -- 449
				local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 450
				if AgentRuntimePolicy.isAgentInternalDocumentPath(path) then -- 450
					goto __continue88 -- 451
				end -- 451
				authoredOperations = authoredOperations + 1 -- 452
				if __TS__ArrayIndexOf(editedPaths, path) < 0 then -- 452
					editedPaths[#editedPaths + 1] = path -- 453
				end -- 453
			end -- 453
			::__continue88:: -- 453
		end -- 453
		if authoredOperations > 0 then -- 453
			context.workflow.unbuiltEdits = true -- 456
			context.workflow.lastBuildSucceeded = false -- 457
			if context.workflow.failedTestNeedsBuild == true then -- 457
				context.workflow.failedTestHasSourceEdit = true -- 458
			end -- 458
			context.workflow.editedPathsSinceBuild = editedPaths -- 459
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + authoredOperations -- 460
		end -- 460
		return ____awaiter_resolve(nil, {output = output}) -- 460
	end) -- 460
end -- 278
local function deleteFile(context, input) -- 465
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 465
		local targetFile = type(input.target_file) == "string" and input.target_file or "" -- 466
		if __TS__StringTrim(targetFile) == "" then -- 466
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing target_file"}}) -- 466
		end -- 466
		local normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile) -- 468
		local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 469
		local result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 470
		if not result.success then -- 470
			return ____awaiter_resolve(nil, {output = result}) -- 470
		end -- 470
		if not isInternalDocumentEdit then -- 470
			context.workflow.unbuiltEdits = true -- 476
			context.workflow.lastBuildSucceeded = false -- 477
			if context.workflow.failedTestNeedsBuild == true then -- 477
				context.workflow.failedTestHasSourceEdit = true -- 478
			end -- 478
			local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 479
			if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 479
				editedPaths[#editedPaths + 1] = normalizedTargetFile -- 480
			end -- 480
			context.workflow.editedPathsSinceBuild = editedPaths -- 481
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 482
		end -- 482
		local ____result_checkpointed_41 = result.checkpointed -- 489
		local ____result_reversible_42 = result.reversible -- 490
		local ____result_binary_43 = result.binary -- 491
		local ____temp_44 = result.checkpointed and result.checkpointId or nil -- 492
		local ____temp_45 = result.checkpointed and result.checkpointSeq or nil -- 493
		local ____result_checkpointed_40 -- 494
		if result.checkpointed then -- 494
			____result_checkpointed_40 = nil -- 494
		else -- 494
			____result_checkpointed_40 = result.message -- 494
		end -- 494
		return ____awaiter_resolve(nil, {output = { -- 494
			success = true, -- 486
			changed = true, -- 487
			mode = "delete", -- 488
			checkpointed = ____result_checkpointed_41, -- 489
			reversible = ____result_reversible_42, -- 490
			binary = ____result_binary_43, -- 491
			checkpointId = ____temp_44, -- 492
			checkpointSeq = ____temp_45, -- 493
			message = ____result_checkpointed_40, -- 494
			files = {{path = targetFile, op = "delete"}} -- 495
		}}) -- 495
	end) -- 495
end -- 465
local function askUser(context, input) -- 500
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 500
		if context.services.publishQuestionnaire == nil then -- 500
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user is not available in this runtime"}}) -- 500
		end -- 500
		if context.sessionId == nil or context.sessionId <= 0 then -- 500
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user requires a session"}}) -- 500
		end -- 500
		local normalized = normalizeQuestionnaire(input) -- 507
		if not normalized.success then -- 507
			return ____awaiter_resolve(nil, {output = normalized}) -- 507
		end -- 507
		local result = __TS__Await(context.services:publishQuestionnaire({sessionId = context.sessionId, taskId = context.taskId, step = context.step, schema = normalized.schema})) -- 509
		if not result.success then -- 509
			return ____awaiter_resolve(nil, {output = result}) -- 509
		end -- 509
		context.workflow.waitingQuestionnaireId = result.questionnaireId -- 516
		return ____awaiter_resolve(nil, {output = {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}, control = {waitForUser = true, questionnaireId = result.questionnaireId}}) -- 516
	end) -- 516
end -- 500
local function spawnSubAgent(context, input) -- 523
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 523
		if context.services.spawnSubAgent == nil then -- 523
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent is not available in this runtime"}}) -- 523
		end -- 523
		if context.sessionId == nil or context.sessionId <= 0 then -- 523
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent requires a parent session"}}) -- 523
		end -- 523
		local filesHint = __TS__ArrayIsArray(input.filesHint) and __TS__ArrayFilter( -- 530
			input.filesHint, -- 531
			function(____, item) return type(item) == "string" end -- 531
		) or nil -- 531
		local result = __TS__Await(context.services:spawnSubAgent({ -- 533
			parentSessionId = context.sessionId, -- 534
			projectRoot = context.workingDir, -- 535
			title = type(input.title) == "string" and input.title or "Sub", -- 536
			prompt = type(input.prompt) == "string" and input.prompt or "", -- 537
			expectedOutput = type(input.expectedOutput) == "string" and input.expectedOutput or nil, -- 538
			filesHint = filesHint, -- 539
			disabledAgentTools = context.disabledAgentTools -- 540
		})) -- 540
		if not result.success then -- 540
			return ____awaiter_resolve(nil, {output = result}) -- 540
		end -- 540
		context.workflow.hasSpawnedSubAgentThisTask = true -- 543
		return ____awaiter_resolve(nil, {output = { -- 543
			success = true, -- 546
			sessionId = result.sessionId, -- 547
			taskId = result.taskId, -- 548
			title = result.title, -- 549
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 550
		}, control = {spawnedSubAgent = true}}) -- 550
	end) -- 550
end -- 523
local function listSubAgents(context, input) -- 556
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 556
		if context.services.listSubAgents == nil then -- 556
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents is not available in this runtime"}}) -- 556
		end -- 556
		if context.sessionId == nil or context.sessionId <= 0 then -- 556
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents requires a current session"}}) -- 556
		end -- 556
		local result = __TS__Await(context.services:listSubAgents({ -- 563
			sessionId = context.sessionId, -- 564
			projectRoot = context.workingDir, -- 565
			status = type(input.status) == "string" and input.status or nil, -- 566
			limit = type(input.limit) == "number" and input.limit or nil, -- 567
			offset = type(input.offset) == "number" and input.offset or nil, -- 568
			query = type(input.query) == "string" and input.query or nil -- 569
		})) -- 569
		return ____awaiter_resolve(nil, {output = result}) -- 569
	end) -- 569
end -- 556
local function finish(_context, input) -- 574
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 574
		local message = type(input.message) == "string" and __TS__StringTrim(input.message) or "" -- 575
		return ____awaiter_resolve( -- 575
			nil, -- 575
			{ -- 576
				output = {success = true, message = message}, -- 577
				control = { -- 578
					concludeTask = true, -- 579
					finalMessage = message, -- 580
					completion = AgentUtils.normalizeAgentCompletionReport(input) -- 581
				} -- 581
			} -- 581
		) -- 581
	end) -- 581
end -- 574
local function analyzeImageHandler(context, input) -- 586
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 586
		local visionContext = context.visionTaskContext or "" -- 587
		if type(input.context) == "string" and __TS__StringTrim(input.context) ~= "" then -- 587
			visionContext = visionContext == "" and input.context or (visionContext .. "\n\n") .. input.context -- 589
		end -- 589
		return ____awaiter_resolve( -- 589
			nil, -- 589
			{output = __TS__Await(analyzeImage({ -- 591
				workingDir = context.workingDir, -- 592
				taskId = context.taskId, -- 593
				sessionId = context.sessionId, -- 594
				binding = context.visionBinding, -- 595
				paths = input.paths, -- 596
				question = input.question, -- 597
				criteria = input.criteria, -- 598
				context = visionContext, -- 599
				isCancelled = function() return context.cancellation:isCancelled() end -- 600
			}))} -- 600
		) -- 600
	end) -- 600
end -- 586
____exports.AGENT_TOOL_HANDLERS = { -- 604
	read_file = readFile, -- 605
	grep_files = grepFiles, -- 606
	glob_files = globFiles, -- 607
	search_dora_doc = searchDoraDoc, -- 608
	build = build, -- 609
	fetch_url = fetchUrl, -- 610
	execute_command = executeCommand, -- 611
	analyze_image = analyzeImageHandler, -- 612
	edit_file = editFile, -- 613
	delete_file = deleteFile, -- 614
	ask_user = askUser, -- 615
	spawn_sub_agent = spawnSubAgent, -- 616
	list_sub_agents = listSubAgents, -- 617
	finish = finish -- 618
} -- 618
return ____exports -- 618