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
		if __TS__ArrayIsArray(input.reads) then -- 44
			local reads = input.reads -- 46
			local results = {} -- 47
			local succeeded = 0 -- 48
			do -- 48
				local i = 0 -- 49
				while i < #reads do -- 49
					local item = reads[i + 1] -- 50
					local output = readOneFile(context, item) -- 51
					if output.success == true then -- 51
						succeeded = succeeded + 1 -- 52
					end -- 52
					results[#results + 1] = __TS__ObjectAssign({index = i, path = item.path}, output) -- 53
					i = i + 1 -- 49
				end -- 49
			end -- 49
			return ____awaiter_resolve(nil, {output = { -- 49
				success = succeeded == #results, -- 56
				partial = succeeded > 0 and succeeded < #results, -- 57
				mode = "batch", -- 58
				readCount = #results, -- 59
				succeededReadCount = succeeded, -- 60
				failedReadCount = #results - succeeded, -- 61
				results = results -- 62
			}}) -- 62
		end -- 62
		return ____awaiter_resolve( -- 62
			nil, -- 62
			{output = readOneFile(context, input)} -- 65
		) -- 65
	end) -- 65
end -- 44
local function grepFiles(context, input) -- 68
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 68
		local ____Tools_searchFiles_17 = Tools.searchFiles -- 69
		local ____context_workingDir_8 = context.workingDir -- 70
		local ____temp_9 = input.path or "" -- 71
		local ____temp_10 = context.useChineseResponse and "zh" or "en" -- 72
		local ____temp_11 = input.pattern or "" -- 73
		local ____input_globs_12 = input.globs -- 74
		local ____input_useRegex_13 = input.useRegex -- 75
		local ____input_caseSensitive_14 = input.caseSensitive -- 76
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_15 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 78
		local ____math_max_4 = math.max -- 79
		local ____math_floor_3 = math.floor -- 79
		local ____input_limit_2 = input.limit -- 79
		if ____input_limit_2 == nil then -- 79
			____input_limit_2 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 79
		end -- 79
		local ____math_max_4_result_16 = ____math_max_4( -- 79
			1, -- 79
			____math_floor_3(__TS__Number(____input_limit_2)) -- 79
		) -- 79
		local ____math_max_7 = math.max -- 80
		local ____math_floor_6 = math.floor -- 80
		local ____input_offset_5 = input.offset -- 80
		if ____input_offset_5 == nil then -- 80
			____input_offset_5 = 0 -- 80
		end -- 80
		local output = __TS__Await(____Tools_searchFiles_17({ -- 69
			workDir = ____context_workingDir_8, -- 70
			path = ____temp_9, -- 71
			docLanguage = ____temp_10, -- 72
			pattern = ____temp_11, -- 73
			globs = ____input_globs_12, -- 74
			useRegex = ____input_useRegex_13, -- 75
			caseSensitive = ____input_caseSensitive_14, -- 76
			includeContent = true, -- 77
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_15, -- 78
			limit = ____math_max_4_result_16, -- 79
			offset = ____math_max_7( -- 80
				0, -- 80
				____math_floor_6(__TS__Number(____input_offset_5)) -- 80
			), -- 80
			groupByFile = input.groupByFile == true -- 81
		})) -- 81
		return ____awaiter_resolve(nil, {output = output}) -- 81
	end) -- 81
end -- 68
local function globFiles(context, input) -- 86
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 86
		local ____Tools_listFiles_24 = Tools.listFiles -- 87
		local ____context_workingDir_21 = context.workingDir -- 88
		local ____temp_22 = input.path or "" -- 89
		local ____input_globs_23 = input.globs -- 90
		local ____math_max_20 = math.max -- 91
		local ____math_floor_19 = math.floor -- 91
		local ____input_maxEntries_18 = input.maxEntries -- 91
		if ____input_maxEntries_18 == nil then -- 91
			____input_maxEntries_18 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 91
		end -- 91
		local output = ____Tools_listFiles_24({ -- 87
			workDir = ____context_workingDir_21, -- 88
			path = ____temp_22, -- 89
			globs = ____input_globs_23, -- 90
			maxEntries = ____math_max_20( -- 91
				1, -- 91
				____math_floor_19(__TS__Number(____input_maxEntries_18)) -- 91
			) -- 91
		}) -- 91
		return ____awaiter_resolve(nil, {output = output}) -- 91
	end) -- 91
end -- 86
local function searchDoraDoc(context, input) -- 96
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 96
		context.workflow.apiSearchesSinceBuild = (context.workflow.apiSearchesSinceBuild or 0) + 1 -- 97
		local ____Tools_searchDoraDoc_33 = Tools.searchDoraDoc -- 98
		local ____temp_29 = input.pattern or "" -- 99
		local ____temp_30 = input.docType or "dora-api" -- 100
		local ____temp_31 = context.useChineseResponse and "zh" or "en" -- 101
		local ____temp_32 = input.programmingLanguage or "ts" -- 102
		local ____math_min_28 = math.min -- 103
		local ____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27 = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax -- 103
		local ____math_max_26 = math.max -- 103
		local ____input_limit_25 = input.limit -- 103
		if ____input_limit_25 == nil then -- 103
			____input_limit_25 = 8 -- 103
		end -- 103
		local output = __TS__Await(____Tools_searchDoraDoc_33({ -- 98
			pattern = ____temp_29, -- 99
			docType = ____temp_30, -- 100
			docLanguage = ____temp_31, -- 101
			programmingLanguage = ____temp_32, -- 102
			limit = ____math_min_28( -- 103
				____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27, -- 103
				____math_max_26( -- 103
					1, -- 103
					__TS__Number(____input_limit_25) -- 103
				) -- 103
			), -- 103
			useRegex = input.useRegex, -- 104
			caseSensitive = false, -- 105
			includeContent = true, -- 106
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 107
		})) -- 107
		return ____awaiter_resolve(nil, {output = output}) -- 107
	end) -- 107
end -- 96
local function build(context, input) -- 112
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 112
		local paths = input.paths -- 113
		local results = {} -- 114
		local rawResults = {} -- 115
		local succeeded = 0 -- 116
		do -- 116
			local i = 0 -- 117
			while i < #paths do -- 117
				local result = __TS__Await(Tools.build({ -- 118
					workDir = context.workingDir, -- 119
					path = paths[i + 1], -- 120
					isCancelled = function() return context.cancellation:isCancelled() end -- 121
				})) -- 121
				local rawResult = result -- 123
				if result.success then -- 123
					succeeded = succeeded + 1 -- 124
				end -- 124
				rawResults[#rawResults + 1] = rawResult -- 125
				results[#results + 1] = __TS__ObjectAssign({index = i, path = paths[i + 1]}, rawResult) -- 126
				if context.cancellation:isCancelled() then -- 126
					break -- 127
				end -- 127
				i = i + 1 -- 117
			end -- 117
		end -- 117
		local output = { -- 129
			success = succeeded == #paths, -- 130
			partial = succeeded > 0 and succeeded < #paths, -- 131
			mode = "batch", -- 132
			requestedBuildCount = #paths, -- 133
			buildCount = #results, -- 134
			succeededBuildCount = succeeded, -- 135
			failedBuildCount = #results - succeeded, -- 136
			skippedBuildCount = #paths - #results, -- 137
			results = results -- 138
		} -- 138
		context.workflow.unbuiltEdits = false -- 140
		context.workflow.editsSinceBuild = 0 -- 141
		context.workflow.editedPathsSinceBuild = {} -- 142
		context.workflow.hasBuilt = true -- 143
		context.workflow.lastBuildSucceeded = output.success == true -- 144
		if output.success == true and context.workflow.freshProjectBuildPending == true then -- 144
			context.workflow.freshProjectBuildPending = false -- 146
		end -- 146
		context.workflow.apiSearchesSinceBuild = 0 -- 148
		context.workflow.buildRepairPending = false -- 149
		if output.success ~= true then -- 149
			do -- 149
				local r = 0 -- 151
				while r < #rawResults do -- 151
					local messages = rawResults[r + 1].messages -- 152
					do -- 152
						local i = 0 -- 153
						while i < (messages and #messages or 0) do -- 153
							if messages[i + 1].success == false and messages[i + 1].file ~= "" then -- 153
								context.workflow.buildRepairPending = true -- 155
								break -- 156
							end -- 156
							i = i + 1 -- 153
						end -- 153
					end -- 153
					r = r + 1 -- 151
				end -- 151
			end -- 151
		end -- 151
		if output.success == true and context.workflow.failedTestNeedsBuild == true and context.workflow.failedTestHasSourceEdit == true then -- 151
			context.workflow.failedTestNeedsBuild = false -- 162
			context.workflow.failedTestHasSourceEdit = false -- 163
		end -- 163
		return ____awaiter_resolve(nil, {output = output}) -- 163
	end) -- 163
end -- 112
local function fetchUrl(context, input) -- 168
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 168
		local output = __TS__Await(Tools.fetchUrl({ -- 169
			workDir = context.workingDir, -- 170
			url = type(input.url) == "string" and input.url or "", -- 171
			target = type(input.target) == "string" and input.target or "", -- 172
			isCancelled = function() return context.cancellation:isCancelled() end, -- 173
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 174
		})) -- 174
		return ____awaiter_resolve(nil, {output = output}) -- 174
	end) -- 174
end -- 168
local function updateDeterministicTestState(context, output) -- 179
	local deterministicFailure = false -- 180
	local deterministicPass = false -- 181
	local outputLines = __TS__StringSplit(output, "\n") -- 182
	do -- 182
		local i = 0 -- 183
		while i < #outputLines and not deterministicFailure do -- 183
			local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 184
			if line == "passed" then -- 184
				deterministicPass = true -- 185
			end -- 185
			if line == "failed" then -- 185
				deterministicFailure = true -- 187
				break -- 188
			end -- 188
			local searchFrom = 0 -- 190
			while searchFrom < #line do -- 190
				local failedIndex = (string.find( -- 192
					line, -- 192
					"failed", -- 192
					math.max(searchFrom + 1, 1), -- 192
					true -- 192
				) or 0) - 1 -- 192
				if failedIndex < 0 then -- 192
					break -- 193
				end -- 193
				local after = failedIndex + #"failed" -- 194
				while after < #line do -- 194
					local ch = __TS__StringSlice(line, after, after + 1) -- 196
					if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 196
						break -- 197
					end -- 197
					after = after + 1 -- 198
				end -- 198
				local afterEnd = after -- 200
				while afterEnd < #line do -- 200
					local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 202
					if ch < "0" or ch > "9" then -- 202
						break -- 203
					end -- 203
					afterEnd = afterEnd + 1 -- 204
				end -- 204
				local count -- 206
				if afterEnd > after then -- 206
					count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 208
				else -- 208
					local before = failedIndex - 1 -- 210
					while before >= 0 do -- 210
						local ch = __TS__StringSlice(line, before, before + 1) -- 212
						if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 212
							break -- 213
						end -- 213
						before = before - 1 -- 214
					end -- 214
					local beforeEnd = before + 1 -- 216
					while before >= 0 do -- 216
						local ch = __TS__StringSlice(line, before, before + 1) -- 218
						if ch < "0" or ch > "9" then -- 218
							break -- 219
						end -- 219
						before = before - 1 -- 220
					end -- 220
					if beforeEnd > before + 1 then -- 220
						count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 222
					end -- 222
				end -- 222
				if count ~= nil and count > 0 then -- 222
					deterministicFailure = true -- 225
					break -- 226
				end -- 226
				searchFrom = failedIndex + #"failed" -- 228
			end -- 228
			i = i + 1 -- 183
		end -- 183
	end -- 183
	if deterministicFailure then -- 183
		context.workflow.failedTestNeedsBuild = true -- 232
		context.workflow.failedTestHasSourceEdit = false -- 233
	elseif deterministicPass then -- 233
		context.workflow.failedTestNeedsBuild = false -- 235
		context.workflow.failedTestHasSourceEdit = false -- 236
	end -- 236
end -- 179
local function executeCommand(context, input) -- 240
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 240
		local mode = type(input.mode) == "string" and input.mode or "" -- 241
		local output = __TS__Await(Tools.executeCommand({ -- 242
			workDir = context.workingDir, -- 243
			mode = mode, -- 244
			code = type(input.code) == "string" and input.code or nil, -- 245
			command = type(input.command) == "string" and input.command or nil, -- 246
			cwd = type(input.cwd) == "string" and input.cwd or nil, -- 247
			timeoutSeconds = type(input.timeoutSeconds) == "number" and input.timeoutSeconds or nil, -- 248
			isCancelled = function() return context.cancellation:isCancelled() end, -- 249
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 250
		})) -- 250
		if output.success and mode == "lua" then -- 250
			updateDeterministicTestState(context, output.output) -- 253
		end -- 253
		return ____awaiter_resolve(nil, {output = output}) -- 253
	end) -- 253
end -- 240
local function editFile(context, input) -- 275
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 275
		local operations = getAgentFileEditInputs(input) -- 276
		local isBatch = __TS__ArrayIsArray(input.edits) -- 277
		if #operations == 0 then -- 277
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing edit operations"}}) -- 277
		end -- 277
		local staged = {} -- 279
		local results = {} -- 280
		local successfulOperations = {} -- 281
		local function failOperation(index, path, code, message) -- 282
			results[#results + 1] = { -- 283
				index = index, -- 283
				path = path, -- 283
				success = false, -- 283
				code = code, -- 283
				message = message -- 283
			} -- 283
		end -- 282
		do -- 282
			local i = 0 -- 286
			while i < #operations do -- 286
				do -- 286
					local operation = operations[i + 1] -- 287
					local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 288
					if path == "" then -- 288
						failOperation(i, path, "INVALID_EDIT", "path is required") -- 290
						goto __continue60 -- 291
					end -- 291
					if operation.oldStr == operation.newStr then -- 291
						failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ") -- 294
						goto __continue60 -- 295
					end -- 295
					local stagedIndex = -1 -- 297
					do -- 297
						local j = 0 -- 298
						while j < #staged do -- 298
							if staged[j + 1].path == path then -- 298
								stagedIndex = j -- 300
								break -- 301
							end -- 301
							j = j + 1 -- 298
						end -- 298
					end -- 298
					if stagedIndex < 0 then -- 298
						local targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path) -- 305
						if not targetState.success then -- 305
							failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message) -- 307
							goto __continue60 -- 308
						end -- 308
						staged[#staged + 1] = { -- 310
							path = path, -- 311
							initialExists = targetState.exists, -- 312
							exists = targetState.exists, -- 313
							content = targetState.content, -- 314
							changed = false -- 315
						} -- 315
						stagedIndex = #staged - 1 -- 317
					end -- 317
					local target = staged[stagedIndex + 1] -- 319
					local guardDenial = getAgentFileEditPlanGuardDenial(context, operation) -- 320
					if guardDenial ~= nil then -- 320
						failOperation(i, path, guardDenial.code, guardDenial.message) -- 322
						goto __continue60 -- 323
					end -- 323
					local mode = "" -- 325
					if operation.oldStr == "" then -- 325
						if target.exists and AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr) then -- 325
							failOperation(i, path, "DUPLICATE_WHOLE_FILE", "rewrite rejected: the complete current file appears more than once in the replacement for " .. path) -- 328
							goto __continue60 -- 329
						end -- 329
						mode = target.exists and "overwrite" or "create" -- 331
						target.exists = true -- 332
						target.content = operation.newStr -- 333
					else -- 333
						if not target.exists then -- 333
							failOperation(i, path, "FILE_NOT_FOUND", ("read file failed: " .. path) .. " does not exist; use old_str=\"\" to create it earlier in the batch") -- 336
							goto __continue60 -- 337
						end -- 337
						local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content) -- 339
						local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr) -- 340
						local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr) -- 341
						local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 342
						if occurrences == 0 then -- 342
							local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 344
							if not indentTolerant.success then -- 344
								failOperation(i, path, "TEXT_NOT_FOUND", indentTolerant.message) -- 346
								goto __continue60 -- 347
							end -- 347
							target.content = indentTolerant.content -- 349
							mode = "replace_indent_tolerant" -- 350
						else -- 350
							if occurrences > 1 then -- 350
								failOperation( -- 353
									i, -- 353
									path, -- 353
									"AMBIGUOUS_MATCH", -- 353
									((("old_str appears " .. tostring(occurrences)) .. " times in ") .. path) .. ". Provide more context to identify one target." -- 353
								) -- 353
								goto __continue60 -- 354
							end -- 354
							target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 356
							mode = "replace" -- 357
						end -- 357
					end -- 357
					target.changed = true -- 360
					results[#results + 1] = {index = i, path = path, success = true, mode = mode} -- 361
					successfulOperations[#successfulOperations + 1] = operation -- 362
				end -- 362
				::__continue60:: -- 362
				i = i + 1 -- 286
			end -- 286
		end -- 286
		local changedTargets = __TS__ArrayFilter( -- 365
			staged, -- 365
			function(____, item) return item.changed end -- 365
		) -- 365
		if #changedTargets == 0 then -- 365
			local firstFailure = results[1] -- 367
			return ____awaiter_resolve(nil, {output = isBatch and ({ -- 367
				success = false, -- 370
				changed = false, -- 371
				mode = "batch", -- 372
				operationCount = #operations, -- 373
				succeededOperationCount = 0, -- 374
				failedOperationCount = #results, -- 375
				results = results, -- 376
				actualSaved = false -- 377
			}) or ({success = false, code = firstFailure and firstFailure.code, message = firstFailure and firstFailure.message or "edit failed", actualSaved = false})}) -- 377
		end -- 377
		local changes = __TS__ArrayMap( -- 387
			changedTargets, -- 387
			function(____, item) return {path = item.path, op = item.initialExists and "write" or "create", content = item.content} end -- 387
		) -- 387
		local applyRes = Tools.applyFileChanges( -- 392
			context.taskId, -- 392
			context.workingDir, -- 392
			changes, -- 392
			{ -- 392
				summary = isBatch and ((((("batch edit " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files via edit_file" or ((tostring(results[1].mode) .. " ") .. changedTargets[1].path) .. " via edit_file", -- 393
				toolName = "edit_file" -- 396
			} -- 396
		) -- 396
		if not applyRes.success then -- 396
			return ____awaiter_resolve( -- 396
				nil, -- 396
				{output = __TS__ObjectAssign({success = false, message = ((isBatch and "batch edit" or "write file") .. " failed: ") .. applyRes.message, actualSaved = false}, isBatch and ({results = results}) or ({}))} -- 399
			) -- 399
		end -- 399
		local files = __TS__ArrayMap( -- 402
			changes, -- 402
			function(____, change) return {path = change.path, op = change.op} end -- 402
		) -- 402
		local output -- 403
		if not isBatch then -- 403
			output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[1].path, { -- 405
				success = true, -- 406
				changed = true, -- 407
				mode = results[1].mode, -- 408
				checkpointId = applyRes.checkpointId, -- 409
				checkpointSeq = applyRes.checkpointSeq, -- 410
				files = files -- 411
			}) -- 411
		else -- 411
			local totalCharacters = 0 -- 414
			local actualSaved = true -- 415
			for ____, item in ipairs(changedTargets) do -- 416
				local current = Tools.readFileRaw(context.workingDir, item.path) -- 417
				if not current.success or current.content ~= item.content then -- 417
					actualSaved = false -- 418
				end -- 418
				if current.success then -- 418
					totalCharacters = totalCharacters + #current.content -- 419
				end -- 419
			end -- 419
			output = { -- 421
				success = true, -- 422
				changed = true, -- 423
				mode = "batch", -- 424
				operationCount = #operations, -- 425
				succeededOperationCount = #successfulOperations, -- 426
				failedOperationCount = #operations - #successfulOperations, -- 427
				partial = #successfulOperations < #operations, -- 428
				fileCount = #changedTargets, -- 429
				checkpointId = applyRes.checkpointId, -- 430
				checkpointSeq = applyRes.checkpointSeq, -- 431
				files = files, -- 432
				results = results, -- 433
				actualSaved = actualSaved, -- 434
				actualSavedCharacters = totalCharacters, -- 435
				currentFileExists = actualSaved, -- 436
				currentCharacters = totalCharacters, -- 437
				currentState = actualSaved and ((((("saved " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files" or "one or more batch file states could not be verified after commit" -- 438
			} -- 438
		end -- 438
		local authoredOperations = 0 -- 444
		local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 445
		for ____, operation in ipairs(successfulOperations) do -- 446
			do -- 446
				local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 447
				if AgentRuntimePolicy.isAgentInternalDocumentPath(path) then -- 447
					goto __continue88 -- 448
				end -- 448
				authoredOperations = authoredOperations + 1 -- 449
				if __TS__ArrayIndexOf(editedPaths, path) < 0 then -- 449
					editedPaths[#editedPaths + 1] = path -- 450
				end -- 450
			end -- 450
			::__continue88:: -- 450
		end -- 450
		if authoredOperations > 0 then -- 450
			context.workflow.unbuiltEdits = true -- 453
			context.workflow.lastBuildSucceeded = false -- 454
			if context.workflow.failedTestNeedsBuild == true then -- 454
				context.workflow.failedTestHasSourceEdit = true -- 455
			end -- 455
			context.workflow.editedPathsSinceBuild = editedPaths -- 456
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + authoredOperations -- 457
		end -- 457
		return ____awaiter_resolve(nil, {output = output}) -- 457
	end) -- 457
end -- 275
local function deleteFile(context, input) -- 462
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 462
		local targetFile = type(input.target_file) == "string" and input.target_file or "" -- 463
		if __TS__StringTrim(targetFile) == "" then -- 463
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing target_file"}}) -- 463
		end -- 463
		local normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile) -- 465
		local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 466
		local result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 467
		if not result.success then -- 467
			return ____awaiter_resolve(nil, {output = result}) -- 467
		end -- 467
		if not isInternalDocumentEdit then -- 467
			context.workflow.unbuiltEdits = true -- 473
			context.workflow.lastBuildSucceeded = false -- 474
			if context.workflow.failedTestNeedsBuild == true then -- 474
				context.workflow.failedTestHasSourceEdit = true -- 475
			end -- 475
			local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 476
			if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 476
				editedPaths[#editedPaths + 1] = normalizedTargetFile -- 477
			end -- 477
			context.workflow.editedPathsSinceBuild = editedPaths -- 478
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 479
		end -- 479
		local ____result_checkpointed_41 = result.checkpointed -- 486
		local ____result_reversible_42 = result.reversible -- 487
		local ____result_binary_43 = result.binary -- 488
		local ____temp_44 = result.checkpointed and result.checkpointId or nil -- 489
		local ____temp_45 = result.checkpointed and result.checkpointSeq or nil -- 490
		local ____result_checkpointed_40 -- 491
		if result.checkpointed then -- 491
			____result_checkpointed_40 = nil -- 491
		else -- 491
			____result_checkpointed_40 = result.message -- 491
		end -- 491
		return ____awaiter_resolve(nil, {output = { -- 491
			success = true, -- 483
			changed = true, -- 484
			mode = "delete", -- 485
			checkpointed = ____result_checkpointed_41, -- 486
			reversible = ____result_reversible_42, -- 487
			binary = ____result_binary_43, -- 488
			checkpointId = ____temp_44, -- 489
			checkpointSeq = ____temp_45, -- 490
			message = ____result_checkpointed_40, -- 491
			files = {{path = targetFile, op = "delete"}} -- 492
		}}) -- 492
	end) -- 492
end -- 462
local function askUser(context, input) -- 497
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 497
		if context.services.publishQuestionnaire == nil then -- 497
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user is not available in this runtime"}}) -- 497
		end -- 497
		if context.sessionId == nil or context.sessionId <= 0 then -- 497
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user requires a session"}}) -- 497
		end -- 497
		local normalized = normalizeQuestionnaire(input) -- 504
		if not normalized.success then -- 504
			return ____awaiter_resolve(nil, {output = normalized}) -- 504
		end -- 504
		local result = __TS__Await(context.services:publishQuestionnaire({sessionId = context.sessionId, taskId = context.taskId, step = context.step, schema = normalized.schema})) -- 506
		if not result.success then -- 506
			return ____awaiter_resolve(nil, {output = result}) -- 506
		end -- 506
		context.workflow.waitingQuestionnaireId = result.questionnaireId -- 513
		return ____awaiter_resolve(nil, {output = {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}, control = {waitForUser = true, questionnaireId = result.questionnaireId}}) -- 513
	end) -- 513
end -- 497
local function spawnSubAgent(context, input) -- 520
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 520
		if context.services.spawnSubAgent == nil then -- 520
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent is not available in this runtime"}}) -- 520
		end -- 520
		if context.sessionId == nil or context.sessionId <= 0 then -- 520
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_sub_agent requires a parent session"}}) -- 520
		end -- 520
		local filesHint = __TS__ArrayIsArray(input.filesHint) and __TS__ArrayFilter( -- 527
			input.filesHint, -- 528
			function(____, item) return type(item) == "string" end -- 528
		) or nil -- 528
		local result = __TS__Await(context.services:spawnSubAgent({ -- 530
			parentSessionId = context.sessionId, -- 531
			projectRoot = context.workingDir, -- 532
			title = type(input.title) == "string" and input.title or "Sub", -- 533
			prompt = type(input.prompt) == "string" and input.prompt or "", -- 534
			expectedOutput = type(input.expectedOutput) == "string" and input.expectedOutput or nil, -- 535
			filesHint = filesHint, -- 536
			disabledAgentTools = context.disabledAgentTools -- 537
		})) -- 537
		if not result.success then -- 537
			return ____awaiter_resolve(nil, {output = result}) -- 537
		end -- 537
		context.workflow.hasSpawnedSubAgentThisTask = true -- 540
		return ____awaiter_resolve(nil, {output = { -- 540
			success = true, -- 543
			sessionId = result.sessionId, -- 544
			taskId = result.taskId, -- 545
			title = result.title, -- 546
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 547
		}, control = {spawnedSubAgent = true}}) -- 547
	end) -- 547
end -- 520
local function listSubAgents(context, input) -- 553
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 553
		if context.services.listSubAgents == nil then -- 553
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents is not available in this runtime"}}) -- 553
		end -- 553
		if context.sessionId == nil or context.sessionId <= 0 then -- 553
			return ____awaiter_resolve(nil, {output = {success = false, message = "list_sub_agents requires a current session"}}) -- 553
		end -- 553
		local result = __TS__Await(context.services:listSubAgents({ -- 560
			sessionId = context.sessionId, -- 561
			projectRoot = context.workingDir, -- 562
			status = type(input.status) == "string" and input.status or nil, -- 563
			limit = type(input.limit) == "number" and input.limit or nil, -- 564
			offset = type(input.offset) == "number" and input.offset or nil, -- 565
			query = type(input.query) == "string" and input.query or nil -- 566
		})) -- 566
		return ____awaiter_resolve(nil, {output = result}) -- 566
	end) -- 566
end -- 553
local function finish(_context, input) -- 571
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 571
		local message = type(input.message) == "string" and __TS__StringTrim(input.message) or "" -- 572
		return ____awaiter_resolve( -- 572
			nil, -- 572
			{ -- 573
				output = {success = true, message = message}, -- 574
				control = { -- 575
					concludeTask = true, -- 576
					finalMessage = message, -- 577
					completion = AgentUtils.normalizeAgentCompletionReport(input) -- 578
				} -- 578
			} -- 578
		) -- 578
	end) -- 578
end -- 571
____exports.AGENT_TOOL_HANDLERS = { -- 583
	read_file = readFile, -- 584
	grep_files = grepFiles, -- 585
	glob_files = globFiles, -- 586
	search_dora_doc = searchDoraDoc, -- 587
	build = build, -- 588
	fetch_url = fetchUrl, -- 589
	execute_command = executeCommand, -- 590
	edit_file = editFile, -- 591
	delete_file = deleteFile, -- 592
	ask_user = askUser, -- 593
	spawn_sub_agent = spawnSubAgent, -- 594
	list_sub_agents = listSubAgents, -- 595
	finish = finish -- 596
} -- 596
return ____exports -- 596