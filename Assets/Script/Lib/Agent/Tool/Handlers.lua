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
local editFile -- 1
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
local function writeFile(context, input) -- 70
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 70
		return ____awaiter_resolve( -- 70
			nil, -- 70
			editFile(context, {path = input.path, old_str = "", new_str = input.new_str}) -- 73
		) -- 73
	end) -- 73
end -- 70
local function grepFiles(context, input) -- 76
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 76
		local pattern = type(input.pattern) == "string" and __TS__StringTrim(input.pattern) or "" -- 77
		if pattern == "" then -- 77
			local ____Tools_listFiles_8 = Tools.listFiles -- 80
			local ____context_workingDir_5 = context.workingDir -- 81
			local ____temp_6 = input.path or "" -- 82
			local ____input_globs_7 = input.globs -- 83
			local ____math_max_4 = math.max -- 84
			local ____math_floor_3 = math.floor -- 84
			local ____input_maxEntries_2 = input.maxEntries -- 84
			if ____input_maxEntries_2 == nil then -- 84
				____input_maxEntries_2 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 84
			end -- 84
			local listed = ____Tools_listFiles_8({ -- 80
				workDir = ____context_workingDir_5, -- 81
				path = ____temp_6, -- 82
				globs = ____input_globs_7, -- 83
				maxEntries = ____math_max_4( -- 84
					1, -- 84
					____math_floor_3(__TS__Number(____input_maxEntries_2)) -- 84
				), -- 84
				preferSourceVariants = false -- 84
			}) -- 84
			return ____awaiter_resolve(nil, {output = listed}) -- 84
		end -- 84
		local ____Tools_searchFiles_24 = Tools.searchFiles -- 88
		local ____context_workingDir_15 = context.workingDir -- 89
		local ____temp_16 = input.path or "" -- 90
		local ____temp_17 = context.useChineseResponse and "zh" or "en" -- 91
		local ____pattern_18 = pattern -- 92
		local ____input_globs_19 = input.globs -- 93
		local ____input_useRegex_20 = input.useRegex -- 94
		local ____input_caseSensitive_21 = input.caseSensitive -- 95
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_22 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 97
		local ____math_max_11 = math.max -- 98
		local ____math_floor_10 = math.floor -- 98
		local ____input_limit_9 = input.limit -- 98
		if ____input_limit_9 == nil then -- 98
			____input_limit_9 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 98
		end -- 98
		local ____math_max_11_result_23 = ____math_max_11( -- 98
			1, -- 98
			____math_floor_10(__TS__Number(____input_limit_9)) -- 98
		) -- 98
		local ____math_max_14 = math.max -- 99
		local ____math_floor_13 = math.floor -- 99
		local ____input_offset_12 = input.offset -- 99
		if ____input_offset_12 == nil then -- 99
			____input_offset_12 = 0 -- 99
		end -- 99
		local output = __TS__Await(____Tools_searchFiles_24({ -- 88
			workDir = ____context_workingDir_15, -- 89
			path = ____temp_16, -- 90
			docLanguage = ____temp_17, -- 91
			pattern = ____pattern_18, -- 92
			globs = ____input_globs_19, -- 93
			useRegex = ____input_useRegex_20, -- 94
			caseSensitive = ____input_caseSensitive_21, -- 95
			includeContent = true, -- 96
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_22, -- 97
			limit = ____math_max_11_result_23, -- 98
			offset = ____math_max_14( -- 99
				0, -- 99
				____math_floor_13(__TS__Number(____input_offset_12)) -- 99
			), -- 99
			groupByFile = input.groupByFile == true -- 100
		})) -- 100
		return ____awaiter_resolve(nil, {output = output}) -- 100
	end) -- 100
end -- 76
local function searchDoraDoc(context, input) -- 105
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 105
		context.workflow.apiSearchesSinceBuild = (context.workflow.apiSearchesSinceBuild or 0) + 1 -- 106
		local ____Tools_searchDoraDoc_33 = Tools.searchDoraDoc -- 107
		local ____temp_29 = input.pattern or "" -- 108
		local ____temp_30 = input.docType or "dora-api" -- 109
		local ____temp_31 = context.useChineseResponse and "zh" or "en" -- 110
		local ____temp_32 = input.programmingLanguage or "ts" -- 111
		local ____math_min_28 = math.min -- 112
		local ____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27 = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax -- 112
		local ____math_max_26 = math.max -- 112
		local ____input_limit_25 = input.limit -- 112
		if ____input_limit_25 == nil then -- 112
			____input_limit_25 = 8 -- 112
		end -- 112
		local output = __TS__Await(____Tools_searchDoraDoc_33({ -- 107
			pattern = ____temp_29, -- 108
			docType = ____temp_30, -- 109
			docLanguage = ____temp_31, -- 110
			programmingLanguage = ____temp_32, -- 111
			limit = ____math_min_28( -- 112
				____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27, -- 112
				____math_max_26( -- 112
					1, -- 112
					__TS__Number(____input_limit_25) -- 112
				) -- 112
			), -- 112
			useRegex = input.useRegex, -- 113
			caseSensitive = false, -- 114
			includeContent = true, -- 115
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 116
		})) -- 116
		return ____awaiter_resolve(nil, {output = output}) -- 116
	end) -- 116
end -- 105
local function build(context, input) -- 121
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 121
		local paths = input.paths -- 122
		local results = {} -- 123
		local rawResults = {} -- 124
		local callFailureMessages = {} -- 125
		local succeeded = 0 -- 126
		do -- 126
			local i = 0 -- 127
			while i < #paths do -- 127
				local result -- 128
				local ____try = __TS__AsyncAwaiter(function() -- 128
					result = __TS__Await(Tools.build({ -- 130
						workDir = context.workingDir, -- 131
						path = paths[i + 1], -- 132
						isCancelled = function() return context.cancellation:isCancelled() end -- 133
					})) -- 133
				end) -- 133
				____try = ____try.catch( -- 133
					____try, -- 133
					function(____, err) -- 133
						return __TS__AsyncAwaiter(function() -- 133
							result = { -- 136
								success = false, -- 136
								failureKind = "tool", -- 136
								message = tostring(err) -- 136
							} -- 136
						end) -- 136
					end -- 136
				) -- 136
				__TS__Await(____try) -- 129
				if result.success then -- 129
					succeeded = succeeded + 1 -- 138
				elseif result.failureKind == "tool" then -- 138
					callFailureMessages[#callFailureMessages + 1] = result.message -- 139
				end -- 139
				rawResults[#rawResults + 1] = result -- 140
				results[#results + 1] = __TS__ObjectAssign({index = i, path = paths[i + 1]}, result) -- 141
				if context.cancellation:isCancelled() then -- 141
					break -- 142
				end -- 142
				i = i + 1 -- 127
			end -- 127
		end -- 127
		local output = { -- 144
			success = succeeded == #paths, -- 145
			partial = succeeded > 0 and succeeded < #paths, -- 146
			mode = "batch", -- 147
			requestedBuildCount = #paths, -- 148
			buildCount = #results, -- 149
			succeededBuildCount = succeeded, -- 150
			failedBuildCount = #results - succeeded, -- 151
			skippedBuildCount = #paths - #results, -- 152
			results = results -- 153
		} -- 153
		context.workflow.unbuiltEdits = false -- 157
		context.workflow.editsSinceBuild = 0 -- 158
		context.workflow.editedPathsSinceBuild = {} -- 159
		context.workflow.hasBuilt = true -- 160
		context.workflow.lastBuildSucceeded = output.success == true -- 161
		if output.success == true and context.workflow.freshProjectBuildPending == true then -- 161
			context.workflow.freshProjectBuildPending = false -- 163
		end -- 163
		context.workflow.apiSearchesSinceBuild = 0 -- 165
		context.workflow.buildRepairPending = false -- 166
		if output.success ~= true then -- 166
			do -- 166
				local r = 0 -- 168
				while r < #rawResults do -- 168
					local messages = rawResults[r + 1].messages -- 169
					do -- 169
						local i = 0 -- 170
						while i < (messages and #messages or 0) do -- 170
							if messages[i + 1].success == false and messages[i + 1].file ~= "" then -- 170
								context.workflow.buildRepairPending = true -- 172
								break -- 173
							end -- 173
							i = i + 1 -- 170
						end -- 170
					end -- 170
					r = r + 1 -- 168
				end -- 168
			end -- 168
		end -- 168
		if output.success == true and context.workflow.failedTestNeedsBuild == true and context.workflow.failedTestHasSourceEdit == true then -- 168
			context.workflow.failedTestNeedsBuild = false -- 179
			context.workflow.failedTestHasSourceEdit = false -- 180
		end -- 180
		if #callFailureMessages > 0 then -- 180
			error(table.concat(callFailureMessages, "; ")) -- 183
		end -- 183
		return ____awaiter_resolve(nil, {output = output}) -- 183
	end) -- 183
end -- 121
local function fetchUrl(context, input) -- 188
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 188
		local output = __TS__Await(Tools.fetchUrl({ -- 189
			workDir = context.workingDir, -- 190
			url = type(input.url) == "string" and input.url or "", -- 191
			target = type(input.target) == "string" and input.target or "", -- 192
			isCancelled = function() return context.cancellation:isCancelled() end, -- 193
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 194
		})) -- 194
		return ____awaiter_resolve(nil, {output = output}) -- 194
	end) -- 194
end -- 188
local function updateDeterministicTestState(context, output) -- 199
	local deterministicFailure = false -- 200
	local deterministicPass = false -- 201
	local outputLines = __TS__StringSplit(output, "\n") -- 202
	do -- 202
		local i = 0 -- 203
		while i < #outputLines and not deterministicFailure do -- 203
			local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 204
			if line == "passed" then -- 204
				deterministicPass = true -- 205
			end -- 205
			if line == "failed" then -- 205
				deterministicFailure = true -- 207
				break -- 208
			end -- 208
			local searchFrom = 0 -- 210
			while searchFrom < #line do -- 210
				local failedIndex = (string.find( -- 212
					line, -- 212
					"failed", -- 212
					math.max(searchFrom + 1, 1), -- 212
					true -- 212
				) or 0) - 1 -- 212
				if failedIndex < 0 then -- 212
					break -- 213
				end -- 213
				local after = failedIndex + #"failed" -- 214
				while after < #line do -- 214
					local ch = __TS__StringSlice(line, after, after + 1) -- 216
					if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 216
						break -- 217
					end -- 217
					after = after + 1 -- 218
				end -- 218
				local afterEnd = after -- 220
				while afterEnd < #line do -- 220
					local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 222
					if ch < "0" or ch > "9" then -- 222
						break -- 223
					end -- 223
					afterEnd = afterEnd + 1 -- 224
				end -- 224
				local count -- 226
				if afterEnd > after then -- 226
					count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 228
				else -- 228
					local before = failedIndex - 1 -- 230
					while before >= 0 do -- 230
						local ch = __TS__StringSlice(line, before, before + 1) -- 232
						if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 232
							break -- 233
						end -- 233
						before = before - 1 -- 234
					end -- 234
					local beforeEnd = before + 1 -- 236
					while before >= 0 do -- 236
						local ch = __TS__StringSlice(line, before, before + 1) -- 238
						if ch < "0" or ch > "9" then -- 238
							break -- 239
						end -- 239
						before = before - 1 -- 240
					end -- 240
					if beforeEnd > before + 1 then -- 240
						count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 242
					end -- 242
				end -- 242
				if count ~= nil and count > 0 then -- 242
					deterministicFailure = true -- 245
					break -- 246
				end -- 246
				searchFrom = failedIndex + #"failed" -- 248
			end -- 248
			i = i + 1 -- 203
		end -- 203
	end -- 203
	if deterministicFailure then -- 203
		context.workflow.failedTestNeedsBuild = true -- 252
		context.workflow.failedTestHasSourceEdit = false -- 253
	elseif deterministicPass then -- 253
		context.workflow.failedTestNeedsBuild = false -- 255
		context.workflow.failedTestHasSourceEdit = false -- 256
	end -- 256
end -- 199
local function executeCommand(context, input) -- 260
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 260
		local mode = type(input.mode) == "string" and input.mode or "" -- 261
		local output = __TS__Await(Tools.executeCommand({ -- 262
			workDir = context.workingDir, -- 263
			docLanguage = context.useChineseResponse and "zh" or "en", -- 264
			taskId = context.taskId, -- 265
			mode = mode, -- 266
			code = type(input.code) == "string" and input.code or nil, -- 267
			command = type(input.command) == "string" and input.command or nil, -- 268
			cwd = type(input.cwd) == "string" and input.cwd or nil, -- 269
			timeoutSeconds = type(input.timeoutSeconds) == "number" and input.timeoutSeconds or nil, -- 270
			isCancelled = function() return context.cancellation:isCancelled() end, -- 271
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 272
		})) -- 272
		if output.success and mode == "lua" then -- 272
			updateDeterministicTestState(context, output.output) -- 275
		end -- 275
		return ____awaiter_resolve(nil, {output = output}) -- 275
	end) -- 275
end -- 260
editFile = function(context, input) -- 297
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 297
		if input.delete == true then -- 297
			local targetFile = type(input.path) == "string" and input.path or "" -- 300
			if __TS__StringTrim(targetFile) == "" then -- 300
				return ____awaiter_resolve(nil, {output = {success = false, message = "delete requires path"}}) -- 300
			end -- 300
			local normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile) -- 302
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 303
			local result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {summary = "edit_file delete: " .. targetFile, toolName = "edit_file"}) -- 304
			if not result.success then -- 304
				return ____awaiter_resolve(nil, {output = result}) -- 304
			end -- 304
			if not isInternalDocumentEdit then -- 304
				context.workflow.unbuiltEdits = true -- 310
				context.workflow.lastBuildSucceeded = false -- 311
				if context.workflow.failedTestNeedsBuild == true then -- 311
					context.workflow.failedTestHasSourceEdit = true -- 312
				end -- 312
				local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 313
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 313
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 314
				end -- 314
				context.workflow.editedPathsSinceBuild = editedPaths -- 315
				context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 316
			end -- 316
			local ____result_checkpointed_37 = result.checkpointed -- 323
			local ____result_reversible_38 = result.reversible -- 324
			local ____result_binary_39 = result.binary -- 325
			local ____temp_40 = result.checkpointed and result.checkpointId or nil -- 326
			local ____temp_41 = result.checkpointed and result.checkpointSeq or nil -- 327
			local ____result_checkpointed_36 -- 328
			if result.checkpointed then -- 328
				____result_checkpointed_36 = nil -- 328
			else -- 328
				____result_checkpointed_36 = result.message -- 328
			end -- 328
			return ____awaiter_resolve(nil, {output = { -- 328
				success = true, -- 320
				changed = true, -- 321
				mode = "delete", -- 322
				checkpointed = ____result_checkpointed_37, -- 323
				reversible = ____result_reversible_38, -- 324
				binary = ____result_binary_39, -- 325
				checkpointId = ____temp_40, -- 326
				checkpointSeq = ____temp_41, -- 327
				message = ____result_checkpointed_36, -- 328
				files = {{path = targetFile, op = "delete"}} -- 329
			}}) -- 329
		end -- 329
		local operations = getAgentFileEditInputs(input) -- 333
		local isBatch = __TS__ArrayIsArray(input.edits) -- 334
		if #operations == 0 then -- 334
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing edit operations"}}) -- 334
		end -- 334
		local staged = {} -- 336
		local results = {} -- 337
		local successfulOperations = {} -- 338
		local function failOperation(index, path, code, message) -- 339
			results[#results + 1] = { -- 340
				index = index, -- 340
				path = path, -- 340
				success = false, -- 340
				code = code, -- 340
				message = message -- 340
			} -- 340
		end -- 339
		do -- 339
			local i = 0 -- 343
			while i < #operations do -- 343
				do -- 343
					local operation = operations[i + 1] -- 344
					local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 345
					if path == "" then -- 345
						failOperation(i, path, "INVALID_EDIT", "path is required") -- 347
						goto __continue71 -- 348
					end -- 348
					if operation.oldStr == operation.newStr then -- 348
						failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ") -- 351
						goto __continue71 -- 352
					end -- 352
					local stagedIndex = -1 -- 354
					do -- 354
						local j = 0 -- 355
						while j < #staged do -- 355
							if staged[j + 1].path == path then -- 355
								stagedIndex = j -- 357
								break -- 358
							end -- 358
							j = j + 1 -- 355
						end -- 355
					end -- 355
					if stagedIndex < 0 then -- 355
						local targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path) -- 362
						if not targetState.success then -- 362
							failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message) -- 364
							goto __continue71 -- 365
						end -- 365
						staged[#staged + 1] = { -- 367
							path = path, -- 368
							initialExists = targetState.exists, -- 369
							exists = targetState.exists, -- 370
							content = targetState.content, -- 371
							changed = false -- 372
						} -- 372
						stagedIndex = #staged - 1 -- 374
					end -- 374
					local target = staged[stagedIndex + 1] -- 376
					local guardDenial = getAgentFileEditPlanGuardDenial(context, operation) -- 377
					if guardDenial ~= nil then -- 377
						failOperation(i, path, guardDenial.code, guardDenial.message) -- 379
						goto __continue71 -- 380
					end -- 380
					local mode = "" -- 382
					if operation.oldStr == "" then -- 382
						if target.exists and AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr) then -- 382
							failOperation(i, path, "DUPLICATE_WHOLE_FILE", "rewrite rejected: the complete current file appears more than once in the replacement for " .. path) -- 385
							goto __continue71 -- 386
						end -- 386
						mode = target.exists and "overwrite" or "create" -- 388
						target.exists = true -- 389
						target.content = operation.newStr -- 390
					else -- 390
						if not target.exists then -- 390
							failOperation(i, path, "FILE_NOT_FOUND", ("read file failed: " .. path) .. " does not exist; use old_str=\"\" to create it earlier in the batch") -- 393
							goto __continue71 -- 394
						end -- 394
						local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content) -- 396
						local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr) -- 397
						local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr) -- 398
						local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 399
						if occurrences == 0 then -- 399
							local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 401
							if not indentTolerant.success then -- 401
								failOperation(i, path, "TEXT_NOT_FOUND", indentTolerant.message) -- 403
								goto __continue71 -- 404
							end -- 404
							target.content = indentTolerant.content -- 406
							mode = "replace_indent_tolerant" -- 407
						else -- 407
							if occurrences > 1 then -- 407
								failOperation( -- 410
									i, -- 410
									path, -- 410
									"AMBIGUOUS_MATCH", -- 410
									((("old_str appears " .. tostring(occurrences)) .. " times in ") .. path) .. ". Provide more context to identify one target." -- 410
								) -- 410
								goto __continue71 -- 411
							end -- 411
							target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 413
							mode = "replace" -- 414
						end -- 414
					end -- 414
					target.changed = true -- 417
					results[#results + 1] = {index = i, path = path, success = true, mode = mode} -- 418
					successfulOperations[#successfulOperations + 1] = operation -- 419
				end -- 419
				::__continue71:: -- 419
				i = i + 1 -- 343
			end -- 343
		end -- 343
		local changedTargets = __TS__ArrayFilter( -- 422
			staged, -- 422
			function(____, item) return item.changed end -- 422
		) -- 422
		if #changedTargets == 0 then -- 422
			local firstFailure = results[1] -- 424
			return ____awaiter_resolve(nil, {output = isBatch and ({ -- 424
				success = false, -- 427
				changed = false, -- 428
				mode = "batch", -- 429
				operationCount = #operations, -- 430
				succeededOperationCount = 0, -- 431
				failedOperationCount = #results, -- 432
				results = results, -- 433
				actualSaved = false -- 434
			}) or ({success = false, code = firstFailure and firstFailure.code, message = firstFailure and firstFailure.message or "edit failed", actualSaved = false})}) -- 434
		end -- 434
		local changes = __TS__ArrayMap( -- 444
			changedTargets, -- 444
			function(____, item) return {path = item.path, op = item.initialExists and "write" or "create", content = item.content} end -- 444
		) -- 444
		local applyRes = Tools.applyFileChanges( -- 449
			context.taskId, -- 449
			context.workingDir, -- 449
			changes, -- 449
			{ -- 449
				summary = isBatch and ((((("batch edit " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files via edit_file" or ((tostring(results[1].mode) .. " ") .. changedTargets[1].path) .. " via edit_file", -- 450
				toolName = "edit_file" -- 453
			} -- 453
		) -- 453
		if not applyRes.success then -- 453
			return ____awaiter_resolve( -- 453
				nil, -- 453
				{output = __TS__ObjectAssign({success = false, message = ((isBatch and "batch edit" or "write file") .. " failed: ") .. applyRes.message, actualSaved = false}, isBatch and ({results = results}) or ({}))} -- 456
			) -- 456
		end -- 456
		local files = __TS__ArrayMap( -- 459
			changes, -- 459
			function(____, change) return {path = change.path, op = change.op} end -- 459
		) -- 459
		local output -- 460
		if not isBatch then -- 460
			output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[1].path, { -- 462
				success = true, -- 463
				changed = true, -- 464
				mode = results[1].mode, -- 465
				checkpointId = applyRes.checkpointId, -- 466
				checkpointSeq = applyRes.checkpointSeq, -- 467
				files = files -- 468
			}) -- 468
		else -- 468
			local totalCharacters = 0 -- 471
			local actualSaved = true -- 472
			for ____, item in ipairs(changedTargets) do -- 473
				local current = Tools.readFileRaw(context.workingDir, item.path) -- 474
				if not current.success or current.content ~= item.content then -- 474
					actualSaved = false -- 475
				end -- 475
				if current.success then -- 475
					totalCharacters = totalCharacters + #current.content -- 476
				end -- 476
			end -- 476
			output = { -- 478
				success = true, -- 479
				changed = true, -- 480
				mode = "batch", -- 481
				operationCount = #operations, -- 482
				succeededOperationCount = #successfulOperations, -- 483
				failedOperationCount = #operations - #successfulOperations, -- 484
				partial = #successfulOperations < #operations, -- 485
				fileCount = #changedTargets, -- 486
				checkpointId = applyRes.checkpointId, -- 487
				checkpointSeq = applyRes.checkpointSeq, -- 488
				files = files, -- 489
				results = results, -- 490
				actualSaved = actualSaved, -- 491
				actualSavedCharacters = totalCharacters, -- 492
				currentFileExists = actualSaved, -- 493
				currentCharacters = totalCharacters, -- 494
				currentState = actualSaved and ((((("saved " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files" or "one or more batch file states could not be verified after commit" -- 495
			} -- 495
		end -- 495
		local authoredOperations = 0 -- 501
		local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 502
		for ____, operation in ipairs(successfulOperations) do -- 503
			do -- 503
				local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 504
				if AgentRuntimePolicy.isAgentInternalDocumentPath(path) then -- 504
					goto __continue99 -- 505
				end -- 505
				authoredOperations = authoredOperations + 1 -- 506
				if __TS__ArrayIndexOf(editedPaths, path) < 0 then -- 506
					editedPaths[#editedPaths + 1] = path -- 507
				end -- 507
			end -- 507
			::__continue99:: -- 507
		end -- 507
		if authoredOperations > 0 then -- 507
			context.workflow.unbuiltEdits = true -- 510
			context.workflow.lastBuildSucceeded = false -- 511
			if context.workflow.failedTestNeedsBuild == true then -- 511
				context.workflow.failedTestHasSourceEdit = true -- 512
			end -- 512
			context.workflow.editedPathsSinceBuild = editedPaths -- 513
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + authoredOperations -- 514
		end -- 514
		return ____awaiter_resolve(nil, {output = output}) -- 514
	end) -- 514
end -- 297
local function askUser(context, input) -- 519
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 519
		if context.services.publishQuestionnaire == nil then -- 519
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user is not available in this runtime"}}) -- 519
		end -- 519
		if context.sessionId == nil or context.sessionId <= 0 then -- 519
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user requires a session"}}) -- 519
		end -- 519
		local normalized = normalizeQuestionnaire(input) -- 526
		if not normalized.success then -- 526
			return ____awaiter_resolve(nil, {output = normalized}) -- 526
		end -- 526
		local result = __TS__Await(context.services:publishQuestionnaire({sessionId = context.sessionId, taskId = context.taskId, step = context.step, schema = normalized.schema})) -- 528
		if not result.success then -- 528
			return ____awaiter_resolve(nil, {output = result}) -- 528
		end -- 528
		context.workflow.waitingQuestionnaireId = result.questionnaireId -- 535
		return ____awaiter_resolve(nil, {output = {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}, control = {waitForUser = true, questionnaireId = result.questionnaireId}}) -- 535
	end) -- 535
end -- 519
local function spawnAgent(context, input) -- 542
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 542
		local prompt = type(input.prompt) == "string" and __TS__StringTrim(input.prompt) or "" -- 543
		if prompt == "" then -- 543
			if context.workflow.hasSpawnedSubAgentThisTask == true then -- 543
				return ____awaiter_resolve(nil, {output = {success = false, message = "Sub-agent results arrive asynchronously as handoffs; listing is rejected for the rest of this task after a successful spawn. Finish this turn instead."}}) -- 543
			end -- 543
			if context.services.listSubAgents == nil then -- 543
				return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent listing is not available in this runtime"}}) -- 543
			end -- 543
			if context.sessionId == nil or context.sessionId <= 0 then -- 543
				return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent listing requires a current session"}}) -- 543
			end -- 543
			local result = __TS__Await(context.services:listSubAgents({ -- 555
				sessionId = context.sessionId, -- 556
				projectRoot = context.workingDir, -- 557
				status = type(input.status) == "string" and input.status or nil, -- 558
				limit = type(input.limit) == "number" and input.limit or nil, -- 559
				offset = type(input.offset) == "number" and input.offset or nil, -- 560
				query = type(input.query) == "string" and input.query or nil -- 561
			})) -- 561
			return ____awaiter_resolve(nil, {output = result}) -- 561
		end -- 561
		if context.services.spawnSubAgent == nil then -- 561
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent dispatch is not available in this runtime"}}) -- 561
		end -- 561
		if context.sessionId == nil or context.sessionId <= 0 then -- 561
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent dispatch requires a parent session"}}) -- 561
		end -- 561
		local filesHint = __TS__ArrayIsArray(input.filesHint) and __TS__ArrayFilter( -- 572
			input.filesHint, -- 573
			function(____, item) return type(item) == "string" end -- 573
		) or nil -- 573
		local result = __TS__Await(context.services:spawnSubAgent({ -- 575
			parentSessionId = context.sessionId, -- 576
			projectRoot = context.workingDir, -- 577
			title = type(input.title) == "string" and input.title or "Sub", -- 578
			prompt = prompt, -- 579
			expectedOutput = type(input.expectedOutput) == "string" and input.expectedOutput or nil, -- 580
			filesHint = filesHint, -- 581
			disabledAgentTools = context.disabledAgentTools -- 582
		})) -- 582
		if not result.success then -- 582
			return ____awaiter_resolve(nil, {output = result}) -- 582
		end -- 582
		context.workflow.hasSpawnedSubAgentThisTask = true -- 585
		return ____awaiter_resolve(nil, {output = { -- 585
			success = true, -- 588
			sessionId = result.sessionId, -- 589
			taskId = result.taskId, -- 590
			title = result.title, -- 591
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not use the listing form in this task; results arrive as asynchronous handoffs." -- 592
		}, control = {spawnedSubAgent = true}}) -- 592
	end) -- 592
end -- 542
local function finish(_context, input) -- 598
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 598
		local message = type(input.message) == "string" and __TS__StringTrim(input.message) or "" -- 599
		return ____awaiter_resolve( -- 599
			nil, -- 599
			{ -- 600
				output = {success = true, message = message}, -- 601
				control = { -- 602
					concludeTask = true, -- 603
					finalMessage = message, -- 604
					completion = AgentUtils.normalizeAgentCompletionReport(input) -- 605
				} -- 605
			} -- 605
		) -- 605
	end) -- 605
end -- 598
local function analyzeImageHandler(context, input) -- 610
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 610
		local visionContext = context.visionTaskContext or "" -- 611
		if type(input.context) == "string" and __TS__StringTrim(input.context) ~= "" then -- 611
			visionContext = visionContext == "" and input.context or (visionContext .. "\n\n") .. input.context -- 613
		end -- 613
		return ____awaiter_resolve( -- 613
			nil, -- 613
			{output = __TS__Await(analyzeImage({ -- 615
				workingDir = context.workingDir, -- 616
				taskId = context.taskId, -- 617
				sessionId = context.sessionId, -- 618
				binding = context.visionBinding, -- 619
				paths = input.paths, -- 620
				question = input.question, -- 621
				criteria = input.criteria, -- 622
				context = visionContext, -- 623
				isCancelled = function() return context.cancellation:isCancelled() end -- 624
			}))} -- 624
		) -- 624
	end) -- 624
end -- 610
____exports.AGENT_TOOL_HANDLERS = { -- 628
	read_file = readFile, -- 629
	grep_files = grepFiles, -- 630
	search_dora_doc = searchDoraDoc, -- 631
	build = build, -- 632
	fetch_url = fetchUrl, -- 633
	execute_command = executeCommand, -- 634
	analyze_image = analyzeImageHandler, -- 635
	edit_file = editFile, -- 636
	write_file = writeFile, -- 637
	ask_user = askUser, -- 638
	spawn_agent = spawnAgent, -- 639
	finish = finish -- 640
} -- 640
return ____exports -- 640