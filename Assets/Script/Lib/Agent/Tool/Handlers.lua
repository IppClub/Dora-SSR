-- [ts]: Handlers.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local ____exports = {} -- 1
local AgentConfig = require("Agent.Config") -- 2
local ____Questionnaire = require("Agent.Questionnaire") -- 3
local normalizeQuestionnaire = ____Questionnaire.normalizeQuestionnaire -- 3
local AgentRuntimePolicy = require("Agent.Runtime.Policy") -- 4
local ____Guards = require("Agent.Tool.Guards") -- 5
local getAgentFileEditPlanGuardDenial = ____Guards.getAgentFileEditPlanGuardDenial -- 5
local ____Validation = require("Agent.Tool.Validation") -- 6
local getAgentFileEditInputs = ____Validation.getAgentFileEditInputs -- 6
local AgentUtils = require("Agent.Utils") -- 7
local Tools = require("Agent.Tools") -- 8
local function readOneFile(context, input) -- 11
	local ____input_startLine_0 = input.startLine -- 12
	if ____input_startLine_0 == nil then -- 12
		____input_startLine_0 = 1 -- 12
	end -- 12
	local startLine = __TS__Number(____input_startLine_0) -- 12
	local ____input_endLine_1 = input.endLine -- 13
	if ____input_endLine_1 == nil then -- 13
		____input_endLine_1 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 13
	end -- 13
	local endLine = __TS__Number(____input_endLine_1) -- 13
	local clippedAfterCompression = false -- 14
	if context.workflow.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 14
		endLine = startLine + 159 -- 21
		clippedAfterCompression = true -- 22
	end -- 22
	local path = type(input.path) == "string" and input.path or "" -- 24
	if __TS__StringTrim(path) == "" then -- 24
		return {success = false, message = "missing path"} -- 26
	end -- 26
	local output = Tools.readFile( -- 28
		context.workingDir, -- 29
		path, -- 30
		startLine, -- 31
		endLine, -- 32
		context.useChineseResponse and "zh" or "en" -- 33
	) -- 33
	if clippedAfterCompression and output.success == true then -- 33
		output.clipped = true -- 36
		output.message = context.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 37
	end -- 37
	return output -- 41
end -- 11
local function readFile(context, input) -- 44
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 44
		local reads = input.reads -- 45
		local results = {} -- 46
		local succeeded = 0 -- 47
		do -- 47
			local i = 0 -- 48
			while i < #reads do -- 48
				local item = reads[i + 1] -- 49
				local output = readOneFile(context, item) -- 50
				if output.success == true then -- 50
					succeeded = succeeded + 1 -- 51
				end -- 51
				results[#results + 1] = __TS__ObjectAssign({index = i, path = item.path}, output) -- 52
				i = i + 1 -- 48
			end -- 48
		end -- 48
		return ____awaiter_resolve(nil, {output = { -- 48
			success = succeeded == #results, -- 55
			partial = succeeded > 0 and succeeded < #results, -- 56
			mode = "batch", -- 57
			readCount = #results, -- 58
			succeededReadCount = succeeded, -- 59
			failedReadCount = #results - succeeded, -- 60
			results = results -- 61
		}}) -- 61
	end) -- 61
end -- 44
local function grepFiles(context, input) -- 65
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 65
		local ____Tools_searchFiles_17 = Tools.searchFiles -- 66
		local ____context_workingDir_8 = context.workingDir -- 67
		local ____temp_9 = input.path or "" -- 68
		local ____temp_10 = context.useChineseResponse and "zh" or "en" -- 69
		local ____temp_11 = input.pattern or "" -- 70
		local ____input_globs_12 = input.globs -- 71
		local ____input_useRegex_13 = input.useRegex -- 72
		local ____input_caseSensitive_14 = input.caseSensitive -- 73
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_15 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 75
		local ____math_max_4 = math.max -- 76
		local ____math_floor_3 = math.floor -- 76
		local ____input_limit_2 = input.limit -- 76
		if ____input_limit_2 == nil then -- 76
			____input_limit_2 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 76
		end -- 76
		local ____math_max_4_result_16 = ____math_max_4( -- 76
			1, -- 76
			____math_floor_3(__TS__Number(____input_limit_2)) -- 76
		) -- 76
		local ____math_max_7 = math.max -- 77
		local ____math_floor_6 = math.floor -- 77
		local ____input_offset_5 = input.offset -- 77
		if ____input_offset_5 == nil then -- 77
			____input_offset_5 = 0 -- 77
		end -- 77
		local output = __TS__Await(____Tools_searchFiles_17({ -- 66
			workDir = ____context_workingDir_8, -- 67
			path = ____temp_9, -- 68
			docLanguage = ____temp_10, -- 69
			pattern = ____temp_11, -- 70
			globs = ____input_globs_12, -- 71
			useRegex = ____input_useRegex_13, -- 72
			caseSensitive = ____input_caseSensitive_14, -- 73
			includeContent = true, -- 74
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_15, -- 75
			limit = ____math_max_4_result_16, -- 76
			offset = ____math_max_7( -- 77
				0, -- 77
				____math_floor_6(__TS__Number(____input_offset_5)) -- 77
			), -- 77
			groupByFile = input.groupByFile == true -- 78
		})) -- 78
		return ____awaiter_resolve(nil, {output = output}) -- 78
	end) -- 78
end -- 65
local function globFiles(context, input) -- 83
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 83
		local ____Tools_listFiles_24 = Tools.listFiles -- 84
		local ____context_workingDir_21 = context.workingDir -- 85
		local ____temp_22 = input.path or "" -- 86
		local ____input_globs_23 = input.globs -- 87
		local ____math_max_20 = math.max -- 88
		local ____math_floor_19 = math.floor -- 88
		local ____input_maxEntries_18 = input.maxEntries -- 88
		if ____input_maxEntries_18 == nil then -- 88
			____input_maxEntries_18 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 88
		end -- 88
		local output = ____Tools_listFiles_24({ -- 84
			workDir = ____context_workingDir_21, -- 85
			path = ____temp_22, -- 86
			globs = ____input_globs_23, -- 87
			maxEntries = ____math_max_20( -- 88
				1, -- 88
				____math_floor_19(__TS__Number(____input_maxEntries_18)) -- 88
			) -- 88
		}) -- 88
		return ____awaiter_resolve(nil, {output = output}) -- 88
	end) -- 88
end -- 83
local function searchDoraDoc(context, input) -- 93
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 93
		context.workflow.apiSearchesSinceBuild = (context.workflow.apiSearchesSinceBuild or 0) + 1 -- 94
		local ____Tools_searchDoraDoc_33 = Tools.searchDoraDoc -- 95
		local ____temp_29 = input.pattern or "" -- 96
		local ____temp_30 = input.docType or "dora-api" -- 97
		local ____temp_31 = context.useChineseResponse and "zh" or "en" -- 98
		local ____temp_32 = input.programmingLanguage or "ts" -- 99
		local ____math_min_28 = math.min -- 100
		local ____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27 = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax -- 100
		local ____math_max_26 = math.max -- 100
		local ____input_limit_25 = input.limit -- 100
		if ____input_limit_25 == nil then -- 100
			____input_limit_25 = 8 -- 100
		end -- 100
		local output = __TS__Await(____Tools_searchDoraDoc_33({ -- 95
			pattern = ____temp_29, -- 96
			docType = ____temp_30, -- 97
			docLanguage = ____temp_31, -- 98
			programmingLanguage = ____temp_32, -- 99
			limit = ____math_min_28( -- 100
				____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27, -- 100
				____math_max_26( -- 100
					1, -- 100
					__TS__Number(____input_limit_25) -- 100
				) -- 100
			), -- 100
			useRegex = input.useRegex, -- 101
			caseSensitive = false, -- 102
			includeContent = true, -- 103
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 104
		})) -- 104
		return ____awaiter_resolve(nil, {output = output}) -- 104
	end) -- 104
end -- 93
local function build(context, input) -- 109
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 109
		local paths = input.paths -- 110
		local results = {} -- 111
		local rawResults = {} -- 112
		local succeeded = 0 -- 113
		do -- 113
			local i = 0 -- 114
			while i < #paths do -- 114
				local result = __TS__Await(Tools.build({ -- 115
					workDir = context.workingDir, -- 116
					path = paths[i + 1], -- 117
					isCancelled = function() return context.cancellation:isCancelled() end -- 118
				})) -- 118
				local rawResult = result -- 120
				if result.success then -- 120
					succeeded = succeeded + 1 -- 121
				end -- 121
				rawResults[#rawResults + 1] = rawResult -- 122
				results[#results + 1] = __TS__ObjectAssign({index = i, path = paths[i + 1]}, rawResult) -- 123
				if context.cancellation:isCancelled() then -- 123
					break -- 124
				end -- 124
				i = i + 1 -- 114
			end -- 114
		end -- 114
		local output = { -- 126
			success = succeeded == #paths, -- 127
			partial = succeeded > 0 and succeeded < #paths, -- 128
			mode = "batch", -- 129
			requestedBuildCount = #paths, -- 130
			buildCount = #results, -- 131
			succeededBuildCount = succeeded, -- 132
			failedBuildCount = #results - succeeded, -- 133
			skippedBuildCount = #paths - #results, -- 134
			results = results -- 135
		} -- 135
		context.workflow.unbuiltEdits = false -- 137
		context.workflow.editsSinceBuild = 0 -- 138
		context.workflow.editedPathsSinceBuild = {} -- 139
		context.workflow.hasBuilt = true -- 140
		context.workflow.lastBuildSucceeded = output.success == true -- 141
		if output.success == true and context.workflow.freshProjectBuildPending == true then -- 141
			context.workflow.freshProjectBuildPending = false -- 143
		end -- 143
		context.workflow.apiSearchesSinceBuild = 0 -- 145
		context.workflow.buildRepairPending = false -- 146
		if output.success ~= true then -- 146
			do -- 146
				local r = 0 -- 148
				while r < #rawResults do -- 148
					local messages = rawResults[r + 1].messages -- 149
					do -- 149
						local i = 0 -- 150
						while i < (messages and #messages or 0) do -- 150
							if messages[i + 1].success == false and messages[i + 1].file ~= "" then -- 150
								context.workflow.buildRepairPending = true -- 152
								break -- 153
							end -- 153
							i = i + 1 -- 150
						end -- 150
					end -- 150
					r = r + 1 -- 148
				end -- 148
			end -- 148
		end -- 148
		if output.success == true and context.workflow.failedTestNeedsBuild == true and context.workflow.failedTestHasSourceEdit == true then -- 148
			context.workflow.failedTestNeedsBuild = false -- 159
			context.workflow.failedTestHasSourceEdit = false -- 160
		end -- 160
		return ____awaiter_resolve(nil, {output = output}) -- 160
	end) -- 160
end -- 109
local function fetchUrl(context, input) -- 165
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 165
		local output = __TS__Await(Tools.fetchUrl({ -- 166
			workDir = context.workingDir, -- 167
			url = type(input.url) == "string" and input.url or "", -- 168
			target = type(input.target) == "string" and input.target or "", -- 169
			isCancelled = function() return context.cancellation:isCancelled() end, -- 170
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 171
		})) -- 171
		return ____awaiter_resolve(nil, {output = output}) -- 171
	end) -- 171
end -- 165
local function updateDeterministicTestState(context, output) -- 176
	local deterministicFailure = false -- 177
	local deterministicPass = false -- 178
	local outputLines = __TS__StringSplit(output, "\n") -- 179
	do -- 179
		local i = 0 -- 180
		while i < #outputLines and not deterministicFailure do -- 180
			local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 181
			if line == "passed" then -- 181
				deterministicPass = true -- 182
			end -- 182
			if line == "failed" then -- 182
				deterministicFailure = true -- 184
				break -- 185
			end -- 185
			local searchFrom = 0 -- 187
			while searchFrom < #line do -- 187
				local failedIndex = (string.find( -- 189
					line, -- 189
					"failed", -- 189
					math.max(searchFrom + 1, 1), -- 189
					true -- 189
				) or 0) - 1 -- 189
				if failedIndex < 0 then -- 189
					break -- 190
				end -- 190
				local after = failedIndex + #"failed" -- 191
				while after < #line do -- 191
					local ch = __TS__StringSlice(line, after, after + 1) -- 193
					if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 193
						break -- 194
					end -- 194
					after = after + 1 -- 195
				end -- 195
				local afterEnd = after -- 197
				while afterEnd < #line do -- 197
					local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 199
					if ch < "0" or ch > "9" then -- 199
						break -- 200
					end -- 200
					afterEnd = afterEnd + 1 -- 201
				end -- 201
				local count -- 203
				if afterEnd > after then -- 203
					count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 205
				else -- 205
					local before = failedIndex - 1 -- 207
					while before >= 0 do -- 207
						local ch = __TS__StringSlice(line, before, before + 1) -- 209
						if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 209
							break -- 210
						end -- 210
						before = before - 1 -- 211
					end -- 211
					local beforeEnd = before + 1 -- 213
					while before >= 0 do -- 213
						local ch = __TS__StringSlice(line, before, before + 1) -- 215
						if ch < "0" or ch > "9" then -- 215
							break -- 216
						end -- 216
						before = before - 1 -- 217
					end -- 217
					if beforeEnd > before + 1 then -- 217
						count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 219
					end -- 219
				end -- 219
				if count ~= nil and count > 0 then -- 219
					deterministicFailure = true -- 222
					break -- 223
				end -- 223
				searchFrom = failedIndex + #"failed" -- 225
			end -- 225
			i = i + 1 -- 180
		end -- 180
	end -- 180
	if deterministicFailure then -- 180
		context.workflow.failedTestNeedsBuild = true -- 229
		context.workflow.failedTestHasSourceEdit = false -- 230
	elseif deterministicPass then -- 230
		context.workflow.failedTestNeedsBuild = false -- 232
		context.workflow.failedTestHasSourceEdit = false -- 233
	end -- 233
end -- 176
local function executeCommand(context, input) -- 237
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 237
		local mode = type(input.mode) == "string" and input.mode or "" -- 238
		local output = __TS__Await(Tools.executeCommand({ -- 239
			workDir = context.workingDir, -- 240
			mode = mode, -- 241
			code = type(input.code) == "string" and input.code or nil, -- 242
			command = type(input.command) == "string" and input.command or nil, -- 243
			cwd = type(input.cwd) == "string" and input.cwd or nil, -- 244
			timeoutSeconds = type(input.timeoutSeconds) == "number" and input.timeoutSeconds or nil, -- 245
			isCancelled = function() return context.cancellation:isCancelled() end, -- 246
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 247
		})) -- 247
		if output.success and mode == "lua" then -- 247
			updateDeterministicTestState(context, output.output) -- 250
		end -- 250
		return ____awaiter_resolve(nil, {output = output}) -- 250
	end) -- 250
end -- 237
local function editFile(context, input) -- 272
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 272
		local operations = getAgentFileEditInputs(input) -- 273
		local isBatch = __TS__ArrayIsArray(input.edits) -- 274
		if #operations == 0 then -- 274
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing edit operations"}}) -- 274
		end -- 274
		local staged = {} -- 276
		local results = {} -- 277
		local successfulOperations = {} -- 278
		local function failOperation(index, path, code, message) -- 279
			results[#results + 1] = { -- 280
				index = index, -- 280
				path = path, -- 280
				success = false, -- 280
				code = code, -- 280
				message = message -- 280
			} -- 280
		end -- 279
		do -- 279
			local i = 0 -- 283
			while i < #operations do -- 283
				do -- 283
					local operation = operations[i + 1] -- 284
					local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 285
					if path == "" then -- 285
						failOperation(i, path, "INVALID_EDIT", "path is required") -- 287
						goto __continue59 -- 288
					end -- 288
					if operation.oldStr == operation.newStr then -- 288
						failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ") -- 291
						goto __continue59 -- 292
					end -- 292
					local stagedIndex = -1 -- 294
					do -- 294
						local j = 0 -- 295
						while j < #staged do -- 295
							if staged[j + 1].path == path then -- 295
								stagedIndex = j -- 297
								break -- 298
							end -- 298
							j = j + 1 -- 295
						end -- 295
					end -- 295
					if stagedIndex < 0 then -- 295
						local targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path) -- 302
						if not targetState.success then -- 302
							failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message) -- 304
							goto __continue59 -- 305
						end -- 305
						staged[#staged + 1] = { -- 307
							path = path, -- 308
							initialExists = targetState.exists, -- 309
							exists = targetState.exists, -- 310
							content = targetState.content, -- 311
							changed = false -- 312
						} -- 312
						stagedIndex = #staged - 1 -- 314
					end -- 314
					local target = staged[stagedIndex + 1] -- 316
					local guardDenial = getAgentFileEditPlanGuardDenial(context, operation) -- 317
					if guardDenial ~= nil then -- 317
						failOperation(i, path, guardDenial.code, guardDenial.message) -- 319
						goto __continue59 -- 320
					end -- 320
					local mode = "" -- 322
					if operation.oldStr == "" then -- 322
						if target.exists and AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr) then -- 322
							failOperation(i, path, "DUPLICATE_WHOLE_FILE", "rewrite rejected: the complete current file appears more than once in the replacement for " .. path) -- 325
							goto __continue59 -- 326
						end -- 326
						mode = target.exists and "overwrite" or "create" -- 328
						target.exists = true -- 329
						target.content = operation.newStr -- 330
					else -- 330
						if not target.exists then -- 330
							failOperation(i, path, "FILE_NOT_FOUND", ("read file failed: " .. path) .. " does not exist; use old_str=\"\" to create it earlier in the batch") -- 333
							goto __continue59 -- 334
						end -- 334
						local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content) -- 336
						local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr) -- 337
						local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr) -- 338
						local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 339
						if occurrences == 0 then -- 339
							local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 341
							if not indentTolerant.success then -- 341
								failOperation(i, path, "TEXT_NOT_FOUND", indentTolerant.message) -- 343
								goto __continue59 -- 344
							end -- 344
							target.content = indentTolerant.content -- 346
							mode = "replace_indent_tolerant" -- 347
						else -- 347
							if occurrences > 1 then -- 347
								failOperation( -- 350
									i, -- 350
									path, -- 350
									"AMBIGUOUS_MATCH", -- 350
									((("old_str appears " .. tostring(occurrences)) .. " times in ") .. path) .. ". Provide more context to identify one target." -- 350
								) -- 350
								goto __continue59 -- 351
							end -- 351
							target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 353
							mode = "replace" -- 354
						end -- 354
					end -- 354
					target.changed = true -- 357
					results[#results + 1] = {index = i, path = path, success = true, mode = mode} -- 358
					successfulOperations[#successfulOperations + 1] = operation -- 359
				end -- 359
				::__continue59:: -- 359
				i = i + 1 -- 283
			end -- 283
		end -- 283
		local changedTargets = __TS__ArrayFilter( -- 362
			staged, -- 362
			function(____, item) return item.changed end -- 362
		) -- 362
		if #changedTargets == 0 then -- 362
			local firstFailure = results[1] -- 364
			return ____awaiter_resolve(nil, {output = isBatch and ({ -- 364
				success = false, -- 367
				changed = false, -- 368
				mode = "batch", -- 369
				operationCount = #operations, -- 370
				succeededOperationCount = 0, -- 371
				failedOperationCount = #results, -- 372
				results = results, -- 373
				actualSaved = false -- 374
			}) or ({success = false, code = firstFailure and firstFailure.code, message = firstFailure and firstFailure.message or "edit failed", actualSaved = false})}) -- 374
		end -- 374
		local changes = __TS__ArrayMap( -- 384
			changedTargets, -- 384
			function(____, item) return {path = item.path, op = item.initialExists and "write" or "create", content = item.content} end -- 384
		) -- 384
		local applyRes = Tools.applyFileChanges( -- 389
			context.taskId, -- 389
			context.workingDir, -- 389
			changes, -- 389
			{ -- 389
				summary = isBatch and ((((("batch edit " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files via edit_file" or ((tostring(results[1].mode) .. " ") .. changedTargets[1].path) .. " via edit_file", -- 390
				toolName = "edit_file" -- 393
			} -- 393
		) -- 393
		if not applyRes.success then -- 393
			return ____awaiter_resolve( -- 393
				nil, -- 393
				{output = __TS__ObjectAssign({success = false, message = ((isBatch and "batch edit" or "write file") .. " failed: ") .. applyRes.message, actualSaved = false}, isBatch and ({results = results}) or ({}))} -- 396
			) -- 396
		end -- 396
		local files = __TS__ArrayMap( -- 399
			changes, -- 399
			function(____, change) return {path = change.path, op = change.op} end -- 399
		) -- 399
		local output -- 400
		if not isBatch then -- 400
			output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[1].path, { -- 402
				success = true, -- 403
				changed = true, -- 404
				mode = results[1].mode, -- 405
				checkpointId = applyRes.checkpointId, -- 406
				checkpointSeq = applyRes.checkpointSeq, -- 407
				files = files -- 408
			}) -- 408
		else -- 408
			local totalCharacters = 0 -- 411
			local actualSaved = true -- 412
			for ____, item in ipairs(changedTargets) do -- 413
				local current = Tools.readFileRaw(context.workingDir, item.path) -- 414
				if not current.success or current.content ~= item.content then -- 414
					actualSaved = false -- 415
				end -- 415
				if current.success then -- 415
					totalCharacters = totalCharacters + #current.content -- 416
				end -- 416
			end -- 416
			output = { -- 418
				success = true, -- 419
				changed = true, -- 420
				mode = "batch", -- 421
				operationCount = #operations, -- 422
				succeededOperationCount = #successfulOperations, -- 423
				failedOperationCount = #operations - #successfulOperations, -- 424
				partial = #successfulOperations < #operations, -- 425
				fileCount = #changedTargets, -- 426
				checkpointId = applyRes.checkpointId, -- 427
				checkpointSeq = applyRes.checkpointSeq, -- 428
				files = files, -- 429
				results = results, -- 430
				actualSaved = actualSaved, -- 431
				actualSavedCharacters = totalCharacters, -- 432
				currentFileExists = actualSaved, -- 433
				currentCharacters = totalCharacters, -- 434
				currentState = actualSaved and ((((("saved " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files" or "one or more batch file states could not be verified after commit" -- 435
			} -- 435
		end -- 435
		local authoredOperations = 0 -- 441
		local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 442
		for ____, operation in ipairs(successfulOperations) do -- 443
			do -- 443
				local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 444
				if AgentRuntimePolicy.isAgentInternalDocumentPath(path) then -- 444
					goto __continue87 -- 445
				end -- 445
				authoredOperations = authoredOperations + 1 -- 446
				if __TS__ArrayIndexOf(editedPaths, path) < 0 then -- 446
					editedPaths[#editedPaths + 1] = path -- 447
				end -- 447
			end -- 447
			::__continue87:: -- 447
		end -- 447
		if authoredOperations > 0 then -- 447
			context.workflow.unbuiltEdits = true -- 450
			context.workflow.lastBuildSucceeded = false -- 451
			if context.workflow.failedTestNeedsBuild == true then -- 451
				context.workflow.failedTestHasSourceEdit = true -- 452
			end -- 452
			context.workflow.editedPathsSinceBuild = editedPaths -- 453
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + authoredOperations -- 454
		end -- 454
		return ____awaiter_resolve(nil, {output = output}) -- 454
	end) -- 454
end -- 272
local function deleteFile(context, input) -- 459
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 459
		local targetFile = type(input.target_file) == "string" and input.target_file or "" -- 460
		if __TS__StringTrim(targetFile) == "" then -- 460
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing target_file"}}) -- 460
		end -- 460
		local normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile) -- 462
		local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 463
		local result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 464
		if not result.success then -- 464
			return ____awaiter_resolve(nil, {output = result}) -- 464
		end -- 464
		if not isInternalDocumentEdit then -- 464
			context.workflow.unbuiltEdits = true -- 470
			context.workflow.lastBuildSucceeded = false -- 471
			if context.workflow.failedTestNeedsBuild == true then -- 471
				context.workflow.failedTestHasSourceEdit = true -- 472
			end -- 472
			local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 473
			if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 473
				editedPaths[#editedPaths + 1] = normalizedTargetFile -- 474
			end -- 474
			context.workflow.editedPathsSinceBuild = editedPaths -- 475
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 476
		end -- 476
		local ____result_checkpointed_41 = result.checkpointed -- 483
		local ____result_reversible_42 = result.reversible -- 484
		local ____result_binary_43 = result.binary -- 485
		local ____temp_44 = result.checkpointed and result.checkpointId or nil -- 486
		local ____temp_45 = result.checkpointed and result.checkpointSeq or nil -- 487
		local ____result_checkpointed_40 -- 488
		if result.checkpointed then -- 488
			____result_checkpointed_40 = nil -- 488
		else -- 488
			____result_checkpointed_40 = result.message -- 488
		end -- 488
		return ____awaiter_resolve(nil, {output = { -- 488
			success = true, -- 480
			changed = true, -- 481
			mode = "delete", -- 482
			checkpointed = ____result_checkpointed_41, -- 483
			reversible = ____result_reversible_42, -- 484
			binary = ____result_binary_43, -- 485
			checkpointId = ____temp_44, -- 486
			checkpointSeq = ____temp_45, -- 487
			message = ____result_checkpointed_40, -- 488
			files = {{path = targetFile, op = "delete"}} -- 489
		}}) -- 489
	end) -- 489
end -- 459
local function askUser(context, input) -- 494
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 494
		if context.services.publishQuestionnaire == nil then -- 494
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user is not available in this runtime"}}) -- 494
		end -- 494
		if context.sessionId == nil or context.sessionId <= 0 then -- 494
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user requires a session"}}) -- 494
		end -- 494
		local normalized = normalizeQuestionnaire(input) -- 501
		if not normalized.success then -- 501
			return ____awaiter_resolve(nil, {output = normalized}) -- 501
		end -- 501
		local result = __TS__Await(context.services:publishQuestionnaire({sessionId = context.sessionId, taskId = context.taskId, step = context.step, schema = normalized.schema})) -- 503
		if not result.success then -- 503
			return ____awaiter_resolve(nil, {output = result}) -- 503
		end -- 503
		context.workflow.waitingQuestionnaireId = result.questionnaireId -- 510
		return ____awaiter_resolve(nil, {output = {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}, control = {waitForUser = true, questionnaireId = result.questionnaireId}}) -- 510
	end) -- 510
end -- 494
local function spawnSubAgent(context, input) -- 517
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 517
		if context.services.spawnSubAgent == nil then -- 517
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent is not available in this runtime"}}) -- 517
		end -- 517
		if context.sessionId == nil or context.sessionId <= 0 then -- 517
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent requires a parent session"}}) -- 517
		end -- 517
		local filesHint = __TS__ArrayIsArray(input.filesHint) and __TS__ArrayFilter( -- 524
			input.filesHint, -- 525
			function(____, item) return type(item) == "string" end -- 525
		) or nil -- 525
		local result = __TS__Await(context.services:spawnSubAgent({ -- 527
			parentSessionId = context.sessionId, -- 528
			projectRoot = context.workingDir, -- 529
			title = type(input.title) == "string" and input.title or "Sub", -- 530
			prompt = type(input.prompt) == "string" and input.prompt or "", -- 531
			expectedOutput = type(input.expectedOutput) == "string" and input.expectedOutput or nil, -- 532
			filesHint = filesHint, -- 533
			disabledAgentTools = context.disabledAgentTools -- 534
		})) -- 534
		if not result.success then -- 534
			return ____awaiter_resolve(nil, {output = result}) -- 534
		end -- 534
		context.workflow.hasSpawnedSubAgentThisTask = true -- 537
		return ____awaiter_resolve(nil, {output = { -- 537
			success = true, -- 540
			sessionId = result.sessionId, -- 541
			taskId = result.taskId, -- 542
			title = result.title, -- 543
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 544
		}, control = {spawnedSubAgent = true}}) -- 544
	end) -- 544
end -- 517
local function listSubAgents(context, input) -- 550
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 550
		if context.services.listSubAgents == nil then -- 550
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents is not available in this runtime"}}) -- 550
		end -- 550
		if context.sessionId == nil or context.sessionId <= 0 then -- 550
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents requires a current session"}}) -- 550
		end -- 550
		local result = __TS__Await(context.services:listSubAgents({ -- 557
			sessionId = context.sessionId, -- 558
			projectRoot = context.workingDir, -- 559
			status = type(input.status) == "string" and input.status or nil, -- 560
			limit = type(input.limit) == "number" and input.limit or nil, -- 561
			offset = type(input.offset) == "number" and input.offset or nil, -- 562
			query = type(input.query) == "string" and input.query or nil -- 563
		})) -- 563
		return ____awaiter_resolve(nil, {output = result}) -- 563
	end) -- 563
end -- 550
local function finish(_context, input) -- 568
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 568
		local message = type(input.message) == "string" and __TS__StringTrim(input.message) or "" -- 569
		return ____awaiter_resolve( -- 569
			nil, -- 569
			{ -- 570
				output = {success = true, message = message}, -- 571
				control = { -- 572
					concludeTask = true, -- 573
					finalMessage = message, -- 574
					completion = AgentUtils.normalizeAgentCompletionReport(input) -- 575
				} -- 575
			} -- 575
		) -- 575
	end) -- 575
end -- 568
____exports.AGENT_TOOL_HANDLERS = { -- 580
	read_file = readFile, -- 581
	grep_files = grepFiles, -- 582
	glob_files = globFiles, -- 583
	search_dora_doc = searchDoraDoc, -- 584
	build = build, -- 585
	fetch_url = fetchUrl, -- 586
	execute_command = executeCommand, -- 587
	edit_file = editFile, -- 588
	delete_file = deleteFile, -- 589
	ask_user = askUser, -- 590
	spawn_sub_agent = spawnSubAgent, -- 591
	list_sub_agents = listSubAgents, -- 592
	finish = finish -- 593
} -- 593
return ____exports -- 593