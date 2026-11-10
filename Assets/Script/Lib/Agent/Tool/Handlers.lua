-- [ts]: Handlers.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
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
local ____Dora = require("Dora") -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
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
	local lowered = string.lower(path) -- 30
	if __TS__StringEndsWith(lowered, ".png") or __TS__StringEndsWith(lowered, ".jpg") or __TS__StringEndsWith(lowered, ".jpeg") then -- 30
		local fullPath = Path(context.workingDir, path) -- 36
		if not Content:exist(fullPath) then -- 36
			return {success = false, message = "image not found: " .. path} -- 38
		end -- 38
		local data = Content:load(fullPath) -- 40
		if data == nil or data == "" then -- 40
			return {success = false, message = "failed to read image " .. path} -- 42
		end -- 42
		return { -- 44
			success = true, -- 45
			path = path, -- 46
			kind = "image", -- 47
			mime = __TS__StringEndsWith(lowered, ".png") and "image/png" or "image/jpeg", -- 48
			bytes = #data -- 49
		} -- 49
	end -- 49
	local output = Tools.readFile( -- 52
		context.workingDir, -- 53
		path, -- 54
		startLine, -- 55
		endLine, -- 56
		context.useChineseResponse and "zh" or "en" -- 57
	) -- 57
	if clippedAfterCompression and endLine ~= nil and output.success == true then -- 57
		output.clipped = true -- 60
		output.message = context.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 61
	end -- 61
	return output -- 65
end -- 12
local function readFile(context, input) -- 68
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 68
		if __TS__ArrayIsArray(input.reads) then -- 68
			local reads = input.reads -- 70
			local results = {} -- 71
			local succeeded = 0 -- 72
			do -- 72
				local i = 0 -- 73
				while i < #reads do -- 73
					local item = reads[i + 1] -- 74
					local output = readOneFile(context, item) -- 75
					if output.success == true then -- 75
						succeeded = succeeded + 1 -- 76
					end -- 76
					results[#results + 1] = __TS__ObjectAssign({index = i, path = item.path}, output) -- 77
					i = i + 1 -- 73
				end -- 73
			end -- 73
			return ____awaiter_resolve(nil, {output = { -- 73
				success = succeeded == #results, -- 80
				partial = succeeded > 0 and succeeded < #results, -- 81
				mode = "batch", -- 82
				readCount = #results, -- 83
				succeededReadCount = succeeded, -- 84
				failedReadCount = #results - succeeded, -- 85
				results = results -- 86
			}}) -- 86
		end -- 86
		return ____awaiter_resolve( -- 86
			nil, -- 86
			{output = readOneFile(context, input)} -- 89
		) -- 89
	end) -- 89
end -- 68
local function writeFile(context, input) -- 92
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 92
		return ____awaiter_resolve( -- 92
			nil, -- 92
			editFile(context, {path = input.path, old_str = "", new_str = input.new_str}) -- 95
		) -- 95
	end) -- 95
end -- 92
local function grepFiles(context, input) -- 98
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 98
		local pattern = type(input.pattern) == "string" and __TS__StringTrim(input.pattern) or "" -- 99
		if pattern == "" then -- 99
			local ____Tools_listFiles_8 = Tools.listFiles -- 102
			local ____context_workingDir_5 = context.workingDir -- 103
			local ____temp_6 = input.path or "" -- 104
			local ____input_globs_7 = input.globs -- 105
			local ____math_max_4 = math.max -- 106
			local ____math_floor_3 = math.floor -- 106
			local ____input_maxEntries_2 = input.maxEntries -- 106
			if ____input_maxEntries_2 == nil then -- 106
				____input_maxEntries_2 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 106
			end -- 106
			local listed = ____Tools_listFiles_8({ -- 102
				workDir = ____context_workingDir_5, -- 103
				path = ____temp_6, -- 104
				globs = ____input_globs_7, -- 105
				maxEntries = ____math_max_4( -- 106
					1, -- 106
					____math_floor_3(__TS__Number(____input_maxEntries_2)) -- 106
				), -- 106
				preferSourceVariants = false -- 106
			}) -- 106
			return ____awaiter_resolve(nil, {output = listed}) -- 106
		end -- 106
		local ____Tools_searchFiles_24 = Tools.searchFiles -- 110
		local ____context_workingDir_15 = context.workingDir -- 111
		local ____temp_16 = input.path or "" -- 112
		local ____temp_17 = context.useChineseResponse and "zh" or "en" -- 113
		local ____pattern_18 = pattern -- 114
		local ____input_globs_19 = input.globs -- 115
		local ____input_useRegex_20 = input.useRegex -- 116
		local ____input_caseSensitive_21 = input.caseSensitive -- 117
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_22 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 119
		local ____math_max_11 = math.max -- 120
		local ____math_floor_10 = math.floor -- 120
		local ____input_limit_9 = input.limit -- 120
		if ____input_limit_9 == nil then -- 120
			____input_limit_9 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 120
		end -- 120
		local ____math_max_11_result_23 = ____math_max_11( -- 120
			1, -- 120
			____math_floor_10(__TS__Number(____input_limit_9)) -- 120
		) -- 120
		local ____math_max_14 = math.max -- 121
		local ____math_floor_13 = math.floor -- 121
		local ____input_offset_12 = input.offset -- 121
		if ____input_offset_12 == nil then -- 121
			____input_offset_12 = 0 -- 121
		end -- 121
		local output = __TS__Await(____Tools_searchFiles_24({ -- 110
			workDir = ____context_workingDir_15, -- 111
			path = ____temp_16, -- 112
			docLanguage = ____temp_17, -- 113
			pattern = ____pattern_18, -- 114
			globs = ____input_globs_19, -- 115
			useRegex = ____input_useRegex_20, -- 116
			caseSensitive = ____input_caseSensitive_21, -- 117
			includeContent = true, -- 118
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_22, -- 119
			limit = ____math_max_11_result_23, -- 120
			offset = ____math_max_14( -- 121
				0, -- 121
				____math_floor_13(__TS__Number(____input_offset_12)) -- 121
			), -- 121
			groupByFile = input.groupByFile == true -- 122
		})) -- 122
		return ____awaiter_resolve(nil, {output = output}) -- 122
	end) -- 122
end -- 98
local function searchDoraDoc(context, input) -- 127
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 127
		context.workflow.apiSearchesSinceBuild = (context.workflow.apiSearchesSinceBuild or 0) + 1 -- 128
		local ____Tools_searchDoraDoc_33 = Tools.searchDoraDoc -- 129
		local ____temp_29 = input.pattern or "" -- 130
		local ____temp_30 = input.docType or "dora-api" -- 131
		local ____temp_31 = context.useChineseResponse and "zh" or "en" -- 132
		local ____temp_32 = input.programmingLanguage or "ts" -- 133
		local ____math_min_28 = math.min -- 134
		local ____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27 = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax -- 134
		local ____math_max_26 = math.max -- 134
		local ____input_limit_25 = input.limit -- 134
		if ____input_limit_25 == nil then -- 134
			____input_limit_25 = 8 -- 134
		end -- 134
		local output = __TS__Await(____Tools_searchDoraDoc_33({ -- 129
			pattern = ____temp_29, -- 130
			docType = ____temp_30, -- 131
			docLanguage = ____temp_31, -- 132
			programmingLanguage = ____temp_32, -- 133
			limit = ____math_min_28( -- 134
				____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27, -- 134
				____math_max_26( -- 134
					1, -- 134
					__TS__Number(____input_limit_25) -- 134
				) -- 134
			), -- 134
			useRegex = input.useRegex, -- 135
			caseSensitive = false, -- 136
			includeContent = true, -- 137
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 138
		})) -- 138
		return ____awaiter_resolve(nil, {output = output}) -- 138
	end) -- 138
end -- 127
local function build(context, input) -- 143
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 143
		local paths = input.paths -- 144
		local results = {} -- 145
		local rawResults = {} -- 146
		local callFailureMessages = {} -- 147
		local succeeded = 0 -- 148
		do -- 148
			local i = 0 -- 149
			while i < #paths do -- 149
				local result -- 150
				local ____try = __TS__AsyncAwaiter(function() -- 150
					result = __TS__Await(Tools.build({ -- 152
						workDir = context.workingDir, -- 153
						path = paths[i + 1], -- 154
						isCancelled = function() return context.cancellation:isCancelled() end -- 155
					})) -- 155
				end) -- 155
				____try = ____try.catch( -- 155
					____try, -- 155
					function(____, err) -- 155
						return __TS__AsyncAwaiter(function() -- 155
							result = { -- 158
								success = false, -- 158
								failureKind = "tool", -- 158
								message = tostring(err) -- 158
							} -- 158
						end) -- 158
					end -- 158
				) -- 158
				__TS__Await(____try) -- 151
				if result.success then -- 151
					succeeded = succeeded + 1 -- 160
				elseif result.failureKind == "tool" then -- 160
					callFailureMessages[#callFailureMessages + 1] = result.message -- 161
				end -- 161
				rawResults[#rawResults + 1] = result -- 162
				results[#results + 1] = __TS__ObjectAssign({index = i, path = paths[i + 1]}, result) -- 163
				if context.cancellation:isCancelled() then -- 163
					break -- 164
				end -- 164
				i = i + 1 -- 149
			end -- 149
		end -- 149
		local output = { -- 166
			success = succeeded == #paths, -- 167
			partial = succeeded > 0 and succeeded < #paths, -- 168
			mode = "batch", -- 169
			requestedBuildCount = #paths, -- 170
			buildCount = #results, -- 171
			succeededBuildCount = succeeded, -- 172
			failedBuildCount = #results - succeeded, -- 173
			skippedBuildCount = #paths - #results, -- 174
			results = results -- 175
		} -- 175
		context.workflow.unbuiltEdits = false -- 179
		context.workflow.editsSinceBuild = 0 -- 180
		context.workflow.editedPathsSinceBuild = {} -- 181
		context.workflow.hasBuilt = true -- 182
		context.workflow.lastBuildSucceeded = output.success == true -- 183
		if output.success == true and context.workflow.freshProjectBuildPending == true then -- 183
			context.workflow.freshProjectBuildPending = false -- 185
		end -- 185
		context.workflow.apiSearchesSinceBuild = 0 -- 187
		context.workflow.buildRepairPending = false -- 188
		if output.success ~= true then -- 188
			do -- 188
				local r = 0 -- 190
				while r < #rawResults do -- 190
					local messages = rawResults[r + 1].messages -- 191
					do -- 191
						local i = 0 -- 192
						while i < (messages and #messages or 0) do -- 192
							if messages[i + 1].success == false and messages[i + 1].file ~= "" then -- 192
								context.workflow.buildRepairPending = true -- 194
								break -- 195
							end -- 195
							i = i + 1 -- 192
						end -- 192
					end -- 192
					r = r + 1 -- 190
				end -- 190
			end -- 190
		end -- 190
		if output.success == true and context.workflow.failedTestNeedsBuild == true and context.workflow.failedTestHasSourceEdit == true then -- 190
			context.workflow.failedTestNeedsBuild = false -- 201
			context.workflow.failedTestHasSourceEdit = false -- 202
		end -- 202
		if #callFailureMessages > 0 then -- 202
			error(table.concat(callFailureMessages, "; ")) -- 205
		end -- 205
		return ____awaiter_resolve(nil, {output = output}) -- 205
	end) -- 205
end -- 143
local function fetchUrl(context, input) -- 210
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 210
		local output = __TS__Await(Tools.fetchUrl({ -- 211
			workDir = context.workingDir, -- 212
			url = type(input.url) == "string" and input.url or "", -- 213
			target = type(input.target) == "string" and input.target or "", -- 214
			isCancelled = function() return context.cancellation:isCancelled() end, -- 215
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 216
		})) -- 216
		return ____awaiter_resolve(nil, {output = output}) -- 216
	end) -- 216
end -- 210
local function updateDeterministicTestState(context, output) -- 221
	local deterministicFailure = false -- 222
	local deterministicPass = false -- 223
	local outputLines = __TS__StringSplit(output, "\n") -- 224
	do -- 224
		local i = 0 -- 225
		while i < #outputLines and not deterministicFailure do -- 225
			local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 226
			if line == "passed" then -- 226
				deterministicPass = true -- 227
			end -- 227
			if line == "failed" then -- 227
				deterministicFailure = true -- 229
				break -- 230
			end -- 230
			local searchFrom = 0 -- 232
			while searchFrom < #line do -- 232
				local failedIndex = (string.find( -- 234
					line, -- 234
					"failed", -- 234
					math.max(searchFrom + 1, 1), -- 234
					true -- 234
				) or 0) - 1 -- 234
				if failedIndex < 0 then -- 234
					break -- 235
				end -- 235
				local after = failedIndex + #"failed" -- 236
				while after < #line do -- 236
					local ch = __TS__StringSlice(line, after, after + 1) -- 238
					if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 238
						break -- 239
					end -- 239
					after = after + 1 -- 240
				end -- 240
				local afterEnd = after -- 242
				while afterEnd < #line do -- 242
					local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 244
					if ch < "0" or ch > "9" then -- 244
						break -- 245
					end -- 245
					afterEnd = afterEnd + 1 -- 246
				end -- 246
				local count -- 248
				if afterEnd > after then -- 248
					count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 250
				else -- 250
					local before = failedIndex - 1 -- 252
					while before >= 0 do -- 252
						local ch = __TS__StringSlice(line, before, before + 1) -- 254
						if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 254
							break -- 255
						end -- 255
						before = before - 1 -- 256
					end -- 256
					local beforeEnd = before + 1 -- 258
					while before >= 0 do -- 258
						local ch = __TS__StringSlice(line, before, before + 1) -- 260
						if ch < "0" or ch > "9" then -- 260
							break -- 261
						end -- 261
						before = before - 1 -- 262
					end -- 262
					if beforeEnd > before + 1 then -- 262
						count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 264
					end -- 264
				end -- 264
				if count ~= nil and count > 0 then -- 264
					deterministicFailure = true -- 267
					break -- 268
				end -- 268
				searchFrom = failedIndex + #"failed" -- 270
			end -- 270
			i = i + 1 -- 225
		end -- 225
	end -- 225
	if deterministicFailure then -- 225
		context.workflow.failedTestNeedsBuild = true -- 274
		context.workflow.failedTestHasSourceEdit = false -- 275
	elseif deterministicPass then -- 275
		context.workflow.failedTestNeedsBuild = false -- 277
		context.workflow.failedTestHasSourceEdit = false -- 278
	end -- 278
end -- 221
local function executeCommand(context, input) -- 282
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 282
		local mode = type(input.mode) == "string" and input.mode or "" -- 283
		local output = __TS__Await(Tools.executeCommand({ -- 284
			workDir = context.workingDir, -- 285
			docLanguage = context.useChineseResponse and "zh" or "en", -- 286
			taskId = context.taskId, -- 287
			mode = mode, -- 288
			code = type(input.code) == "string" and input.code or nil, -- 289
			command = type(input.command) == "string" and input.command or nil, -- 290
			cwd = type(input.cwd) == "string" and input.cwd or nil, -- 291
			timeoutSeconds = type(input.timeoutSeconds) == "number" and input.timeoutSeconds or nil, -- 292
			isCancelled = function() return context.cancellation:isCancelled() end, -- 293
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 294
		})) -- 294
		if output.success and mode == "lua" then -- 294
			updateDeterministicTestState(context, output.output) -- 297
		end -- 297
		return ____awaiter_resolve(nil, {output = output}) -- 297
	end) -- 297
end -- 282
editFile = function(context, input) -- 319
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 319
		if input.delete == true then -- 319
			local targetFile = type(input.path) == "string" and input.path or "" -- 322
			if __TS__StringTrim(targetFile) == "" then -- 322
				return ____awaiter_resolve(nil, {output = {success = false, message = "delete requires path"}}) -- 322
			end -- 322
			local normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile) -- 324
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 325
			local result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {summary = "edit_file delete: " .. targetFile, toolName = "edit_file"}) -- 326
			if not result.success then -- 326
				return ____awaiter_resolve(nil, {output = result}) -- 326
			end -- 326
			if not isInternalDocumentEdit then -- 326
				context.workflow.unbuiltEdits = true -- 332
				context.workflow.lastBuildSucceeded = false -- 333
				if context.workflow.failedTestNeedsBuild == true then -- 333
					context.workflow.failedTestHasSourceEdit = true -- 334
				end -- 334
				local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 335
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 335
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 336
				end -- 336
				context.workflow.editedPathsSinceBuild = editedPaths -- 337
				context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 338
			end -- 338
			local ____result_checkpointed_37 = result.checkpointed -- 345
			local ____result_reversible_38 = result.reversible -- 346
			local ____result_binary_39 = result.binary -- 347
			local ____temp_40 = result.checkpointed and result.checkpointId or nil -- 348
			local ____temp_41 = result.checkpointed and result.checkpointSeq or nil -- 349
			local ____result_checkpointed_36 -- 350
			if result.checkpointed then -- 350
				____result_checkpointed_36 = nil -- 350
			else -- 350
				____result_checkpointed_36 = result.message -- 350
			end -- 350
			return ____awaiter_resolve(nil, {output = { -- 350
				success = true, -- 342
				changed = true, -- 343
				mode = "delete", -- 344
				checkpointed = ____result_checkpointed_37, -- 345
				reversible = ____result_reversible_38, -- 346
				binary = ____result_binary_39, -- 347
				checkpointId = ____temp_40, -- 348
				checkpointSeq = ____temp_41, -- 349
				message = ____result_checkpointed_36, -- 350
				files = {{path = targetFile, op = "delete"}} -- 351
			}}) -- 351
		end -- 351
		local operations = getAgentFileEditInputs(input) -- 355
		local isBatch = __TS__ArrayIsArray(input.edits) -- 356
		if #operations == 0 then -- 356
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing edit operations"}}) -- 356
		end -- 356
		local staged = {} -- 358
		local results = {} -- 359
		local successfulOperations = {} -- 360
		local function failOperation(index, path, code, message) -- 361
			results[#results + 1] = { -- 362
				index = index, -- 362
				path = path, -- 362
				success = false, -- 362
				code = code, -- 362
				message = message -- 362
			} -- 362
		end -- 361
		do -- 361
			local i = 0 -- 365
			while i < #operations do -- 365
				do -- 365
					local operation = operations[i + 1] -- 366
					local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 367
					if path == "" then -- 367
						failOperation(i, path, "INVALID_EDIT", "path is required") -- 369
						goto __continue74 -- 370
					end -- 370
					if operation.oldStr == operation.newStr then -- 370
						failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ") -- 373
						goto __continue74 -- 374
					end -- 374
					local stagedIndex = -1 -- 376
					do -- 376
						local j = 0 -- 377
						while j < #staged do -- 377
							if staged[j + 1].path == path then -- 377
								stagedIndex = j -- 379
								break -- 380
							end -- 380
							j = j + 1 -- 377
						end -- 377
					end -- 377
					if stagedIndex < 0 then -- 377
						local targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path) -- 384
						if not targetState.success then -- 384
							failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message) -- 386
							goto __continue74 -- 387
						end -- 387
						staged[#staged + 1] = { -- 389
							path = path, -- 390
							initialExists = targetState.exists, -- 391
							exists = targetState.exists, -- 392
							content = targetState.content, -- 393
							changed = false -- 394
						} -- 394
						stagedIndex = #staged - 1 -- 396
					end -- 396
					local target = staged[stagedIndex + 1] -- 398
					local guardDenial = getAgentFileEditPlanGuardDenial(context, operation) -- 399
					if guardDenial ~= nil then -- 399
						failOperation(i, path, guardDenial.code, guardDenial.message) -- 401
						goto __continue74 -- 402
					end -- 402
					local mode = "" -- 404
					if operation.oldStr == "" then -- 404
						if target.exists and AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr) then -- 404
							failOperation(i, path, "DUPLICATE_WHOLE_FILE", "rewrite rejected: the complete current file appears more than once in the replacement for " .. path) -- 407
							goto __continue74 -- 408
						end -- 408
						mode = target.exists and "overwrite" or "create" -- 410
						target.exists = true -- 411
						target.content = operation.newStr -- 412
					else -- 412
						if not target.exists then -- 412
							failOperation(i, path, "FILE_NOT_FOUND", ("read file failed: " .. path) .. " does not exist; use old_str=\"\" to create it earlier in the batch") -- 415
							goto __continue74 -- 416
						end -- 416
						local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content) -- 418
						local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr) -- 419
						local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr) -- 420
						local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 421
						if occurrences == 0 then -- 421
							local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 423
							if not indentTolerant.success then -- 423
								failOperation(i, path, "TEXT_NOT_FOUND", indentTolerant.message) -- 425
								goto __continue74 -- 426
							end -- 426
							target.content = indentTolerant.content -- 428
							mode = "replace_indent_tolerant" -- 429
						else -- 429
							if occurrences > 1 then -- 429
								failOperation( -- 432
									i, -- 432
									path, -- 432
									"AMBIGUOUS_MATCH", -- 432
									((("old_str appears " .. tostring(occurrences)) .. " times in ") .. path) .. ". Provide more context to identify one target." -- 432
								) -- 432
								goto __continue74 -- 433
							end -- 433
							target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 435
							mode = "replace" -- 436
						end -- 436
					end -- 436
					target.changed = true -- 439
					results[#results + 1] = {index = i, path = path, success = true, mode = mode} -- 440
					successfulOperations[#successfulOperations + 1] = operation -- 441
				end -- 441
				::__continue74:: -- 441
				i = i + 1 -- 365
			end -- 365
		end -- 365
		local changedTargets = __TS__ArrayFilter( -- 444
			staged, -- 444
			function(____, item) return item.changed end -- 444
		) -- 444
		if #changedTargets == 0 then -- 444
			local firstFailure = results[1] -- 446
			return ____awaiter_resolve(nil, {output = isBatch and ({ -- 446
				success = false, -- 449
				changed = false, -- 450
				mode = "batch", -- 451
				operationCount = #operations, -- 452
				succeededOperationCount = 0, -- 453
				failedOperationCount = #results, -- 454
				results = results, -- 455
				actualSaved = false -- 456
			}) or ({success = false, code = firstFailure and firstFailure.code, message = firstFailure and firstFailure.message or "edit failed", actualSaved = false})}) -- 456
		end -- 456
		local changes = __TS__ArrayMap( -- 466
			changedTargets, -- 466
			function(____, item) return {path = item.path, op = item.initialExists and "write" or "create", content = item.content} end -- 466
		) -- 466
		local applyRes = Tools.applyFileChanges( -- 471
			context.taskId, -- 471
			context.workingDir, -- 471
			changes, -- 471
			{ -- 471
				summary = isBatch and ((((("batch edit " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files via edit_file" or ((tostring(results[1].mode) .. " ") .. changedTargets[1].path) .. " via edit_file", -- 472
				toolName = "edit_file" -- 475
			} -- 475
		) -- 475
		if not applyRes.success then -- 475
			return ____awaiter_resolve( -- 475
				nil, -- 475
				{output = __TS__ObjectAssign({success = false, message = ((isBatch and "batch edit" or "write file") .. " failed: ") .. applyRes.message, actualSaved = false}, isBatch and ({results = results}) or ({}))} -- 478
			) -- 478
		end -- 478
		local files = __TS__ArrayMap( -- 481
			changes, -- 481
			function(____, change) return {path = change.path, op = change.op} end -- 481
		) -- 481
		local output -- 482
		if not isBatch then -- 482
			output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[1].path, { -- 484
				success = true, -- 485
				changed = true, -- 486
				mode = results[1].mode, -- 487
				checkpointId = applyRes.checkpointId, -- 488
				checkpointSeq = applyRes.checkpointSeq, -- 489
				files = files -- 490
			}) -- 490
		else -- 490
			local totalCharacters = 0 -- 493
			local actualSaved = true -- 494
			for ____, item in ipairs(changedTargets) do -- 495
				local current = Tools.readFileRaw(context.workingDir, item.path) -- 496
				if not current.success or current.content ~= item.content then -- 496
					actualSaved = false -- 497
				end -- 497
				if current.success then -- 497
					totalCharacters = totalCharacters + #current.content -- 498
				end -- 498
			end -- 498
			output = { -- 500
				success = true, -- 501
				changed = true, -- 502
				mode = "batch", -- 503
				operationCount = #operations, -- 504
				succeededOperationCount = #successfulOperations, -- 505
				failedOperationCount = #operations - #successfulOperations, -- 506
				partial = #successfulOperations < #operations, -- 507
				fileCount = #changedTargets, -- 508
				checkpointId = applyRes.checkpointId, -- 509
				checkpointSeq = applyRes.checkpointSeq, -- 510
				files = files, -- 511
				results = results, -- 512
				actualSaved = actualSaved, -- 513
				actualSavedCharacters = totalCharacters, -- 514
				currentFileExists = actualSaved, -- 515
				currentCharacters = totalCharacters, -- 516
				currentState = actualSaved and ((((("saved " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files" or "one or more batch file states could not be verified after commit" -- 517
			} -- 517
		end -- 517
		local authoredOperations = 0 -- 523
		local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 524
		for ____, operation in ipairs(successfulOperations) do -- 525
			do -- 525
				local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 526
				if AgentRuntimePolicy.isAgentInternalDocumentPath(path) then -- 526
					goto __continue102 -- 527
				end -- 527
				authoredOperations = authoredOperations + 1 -- 528
				if __TS__ArrayIndexOf(editedPaths, path) < 0 then -- 528
					editedPaths[#editedPaths + 1] = path -- 529
				end -- 529
			end -- 529
			::__continue102:: -- 529
		end -- 529
		if authoredOperations > 0 then -- 529
			context.workflow.unbuiltEdits = true -- 532
			context.workflow.lastBuildSucceeded = false -- 533
			if context.workflow.failedTestNeedsBuild == true then -- 533
				context.workflow.failedTestHasSourceEdit = true -- 534
			end -- 534
			context.workflow.editedPathsSinceBuild = editedPaths -- 535
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + authoredOperations -- 536
		end -- 536
		return ____awaiter_resolve(nil, {output = output}) -- 536
	end) -- 536
end -- 319
local function askUser(context, input) -- 541
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 541
		if context.services.publishQuestionnaire == nil then -- 541
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user is not available in this runtime"}}) -- 541
		end -- 541
		if context.sessionId == nil or context.sessionId <= 0 then -- 541
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user requires a session"}}) -- 541
		end -- 541
		local normalized = normalizeQuestionnaire(input) -- 548
		if not normalized.success then -- 548
			return ____awaiter_resolve(nil, {output = normalized}) -- 548
		end -- 548
		local result = __TS__Await(context.services:publishQuestionnaire({sessionId = context.sessionId, taskId = context.taskId, step = context.step, schema = normalized.schema})) -- 550
		if not result.success then -- 550
			return ____awaiter_resolve(nil, {output = result}) -- 550
		end -- 550
		context.workflow.waitingQuestionnaireId = result.questionnaireId -- 557
		return ____awaiter_resolve(nil, {output = {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}, control = {waitForUser = true, questionnaireId = result.questionnaireId}}) -- 557
	end) -- 557
end -- 541
local function spawnAgent(context, input) -- 564
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 564
		local prompt = type(input.prompt) == "string" and __TS__StringTrim(input.prompt) or "" -- 565
		if prompt == "" then -- 565
			if context.workflow.hasSpawnedSubAgentThisTask == true then -- 565
				return ____awaiter_resolve(nil, {output = {success = false, message = "Sub-agent results arrive asynchronously as handoffs; listing is rejected for the rest of this task after a successful spawn. Finish this turn instead."}}) -- 565
			end -- 565
			if context.services.listSubAgents == nil then -- 565
				return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent listing is not available in this runtime"}}) -- 565
			end -- 565
			if context.sessionId == nil or context.sessionId <= 0 then -- 565
				return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent listing requires a current session"}}) -- 565
			end -- 565
			local result = __TS__Await(context.services:listSubAgents({ -- 577
				sessionId = context.sessionId, -- 578
				projectRoot = context.workingDir, -- 579
				status = type(input.status) == "string" and input.status or nil, -- 580
				limit = type(input.limit) == "number" and input.limit or nil, -- 581
				offset = type(input.offset) == "number" and input.offset or nil, -- 582
				query = type(input.query) == "string" and input.query or nil -- 583
			})) -- 583
			return ____awaiter_resolve(nil, {output = result}) -- 583
		end -- 583
		if context.services.spawnSubAgent == nil then -- 583
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent dispatch is not available in this runtime"}}) -- 583
		end -- 583
		if context.sessionId == nil or context.sessionId <= 0 then -- 583
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent dispatch requires a parent session"}}) -- 583
		end -- 583
		local filesHint = __TS__ArrayIsArray(input.filesHint) and __TS__ArrayFilter( -- 594
			input.filesHint, -- 595
			function(____, item) return type(item) == "string" end -- 595
		) or nil -- 595
		local result = __TS__Await(context.services:spawnSubAgent({ -- 597
			parentSessionId = context.sessionId, -- 598
			projectRoot = context.workingDir, -- 599
			title = type(input.title) == "string" and input.title or "Sub", -- 600
			prompt = prompt, -- 601
			expectedOutput = type(input.expectedOutput) == "string" and input.expectedOutput or nil, -- 602
			filesHint = filesHint, -- 603
			disabledAgentTools = context.disabledAgentTools -- 604
		})) -- 604
		if not result.success then -- 604
			return ____awaiter_resolve(nil, {output = result}) -- 604
		end -- 604
		context.workflow.hasSpawnedSubAgentThisTask = true -- 607
		return ____awaiter_resolve(nil, {output = { -- 607
			success = true, -- 610
			sessionId = result.sessionId, -- 611
			taskId = result.taskId, -- 612
			title = result.title, -- 613
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not use the listing form in this task; results arrive as asynchronous handoffs." -- 614
		}, control = {spawnedSubAgent = true}}) -- 614
	end) -- 614
end -- 564
local function finish(_context, input) -- 620
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 620
		local message = type(input.message) == "string" and __TS__StringTrim(input.message) or "" -- 621
		return ____awaiter_resolve( -- 621
			nil, -- 621
			{ -- 622
				output = {success = true, message = message}, -- 623
				control = { -- 624
					concludeTask = true, -- 625
					finalMessage = message, -- 626
					completion = AgentUtils.normalizeAgentCompletionReport(input) -- 627
				} -- 627
			} -- 627
		) -- 627
	end) -- 627
end -- 620
____exports.AGENT_TOOL_HANDLERS = { -- 632
	read_file = readFile, -- 633
	grep_files = grepFiles, -- 634
	search_dora_doc = searchDoraDoc, -- 635
	build = build, -- 636
	fetch_url = fetchUrl, -- 637
	execute_command = executeCommand, -- 638
	edit_file = editFile, -- 639
	write_file = writeFile, -- 640
	ask_user = askUser, -- 641
	spawn_agent = spawnAgent -- 642
} -- 642
return ____exports -- 642