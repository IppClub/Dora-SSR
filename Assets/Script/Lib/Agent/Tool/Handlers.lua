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
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local editFile -- 1
local ____VisionAnalysis = require("Agent.Tool.VisionAnalysis") -- 1
local analyzeImage = ____VisionAnalysis.analyzeImage -- 1
local AgentConfig = require("Agent.Config.Defaults") -- 4
local ____Questionnaire = require("Agent.Runtime.Questionnaire") -- 5
local normalizeQuestionnaire = ____Questionnaire.normalizeQuestionnaire -- 5
local AgentRuntimePolicy = require("Agent.Runtime.Policy") -- 6
local ____Guards = require("Agent.Tool.Guards") -- 7
local getAgentFileEditPlanGuardDenial = ____Guards.getAgentFileEditPlanGuardDenial -- 7
local ____Validation = require("Agent.Tool.Validation") -- 8
local getAgentFileEditInputs = ____Validation.getAgentFileEditInputs -- 8
local AgentUtils = require("Agent.Utils") -- 9
local Tools = require("Agent.Tools") -- 10
local function readOneFile(context, input) -- 13
	local ____input_startLine_0 = input.startLine -- 14
	if ____input_startLine_0 == nil then -- 14
		____input_startLine_0 = 1 -- 14
	end -- 14
	local startLine = __TS__Number(____input_startLine_0) -- 14
	local ____temp_1 -- 15
	if input.endLine == nil then -- 15
		____temp_1 = nil -- 15
	else -- 15
		____temp_1 = __TS__Number(input.endLine) -- 15
	end -- 15
	local endLine = ____temp_1 -- 15
	local effectiveEndLine = endLine or startLine + AgentConfig.AGENT_LIMITS.readFileDefaultLimit - 1 -- 16
	local clippedAfterCompression = false -- 17
	if context.workflow.resumeNarrowReadMode == true and startLine > 0 and effectiveEndLine >= startLine and effectiveEndLine - startLine + 1 > 160 then -- 17
		endLine = startLine + 159 -- 24
		clippedAfterCompression = true -- 25
	end -- 25
	local path = type(input.path) == "string" and input.path or "" -- 27
	if __TS__StringTrim(path) == "" then -- 27
		return {success = false, message = "missing path"} -- 29
	end -- 29
	local output = Tools.readFile( -- 31
		context.workingDir, -- 32
		path, -- 33
		startLine, -- 34
		endLine, -- 35
		context.useChineseResponse and "zh" or "en" -- 36
	) -- 36
	if clippedAfterCompression and endLine ~= nil and output.success == true then -- 36
		output.clipped = true -- 39
		output.message = context.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 40
	end -- 40
	return output -- 44
end -- 13
local function readFile(context, input) -- 47
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 47
		if __TS__ArrayIsArray(input.reads) then -- 47
			local reads = input.reads -- 49
			local results = {} -- 50
			local succeeded = 0 -- 51
			do -- 51
				local i = 0 -- 52
				while i < #reads do -- 52
					local item = reads[i + 1] -- 53
					local output = readOneFile(context, item) -- 54
					if output.success == true then -- 54
						succeeded = succeeded + 1 -- 55
					end -- 55
					results[#results + 1] = __TS__ObjectAssign({index = i, path = item.path}, output) -- 56
					i = i + 1 -- 52
				end -- 52
			end -- 52
			return ____awaiter_resolve(nil, {output = { -- 52
				success = succeeded == #results, -- 59
				partial = succeeded > 0 and succeeded < #results, -- 60
				mode = "batch", -- 61
				readCount = #results, -- 62
				succeededReadCount = succeeded, -- 63
				failedReadCount = #results - succeeded, -- 64
				results = results -- 65
			}}) -- 65
		end -- 65
		return ____awaiter_resolve( -- 65
			nil, -- 65
			{output = readOneFile(context, input)} -- 68
		) -- 68
	end) -- 68
end -- 47
local function writeFile(context, input) -- 71
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 71
		return ____awaiter_resolve( -- 71
			nil, -- 71
			editFile(context, {path = input.path, old_str = "", new_str = input.new_str}) -- 74
		) -- 74
	end) -- 74
end -- 71
local function grepFiles(context, input) -- 77
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 77
		local pattern = type(input.pattern) == "string" and __TS__StringTrim(input.pattern) or "" -- 78
		if pattern == "" then -- 78
			local ____Tools_listFiles_8 = Tools.listFiles -- 81
			local ____context_workingDir_5 = context.workingDir -- 82
			local ____temp_6 = input.path or "" -- 83
			local ____input_globs_7 = input.globs -- 84
			local ____math_max_4 = math.max -- 85
			local ____math_floor_3 = math.floor -- 85
			local ____input_maxEntries_2 = input.maxEntries -- 85
			if ____input_maxEntries_2 == nil then -- 85
				____input_maxEntries_2 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 85
			end -- 85
			local listed = ____Tools_listFiles_8({ -- 81
				workDir = ____context_workingDir_5, -- 82
				path = ____temp_6, -- 83
				globs = ____input_globs_7, -- 84
				maxEntries = ____math_max_4( -- 85
					1, -- 85
					____math_floor_3(__TS__Number(____input_maxEntries_2)) -- 85
				), -- 85
				preferSourceVariants = false -- 85
			}) -- 85
			return ____awaiter_resolve(nil, {output = listed}) -- 85
		end -- 85
		local ____Tools_searchFiles_24 = Tools.searchFiles -- 89
		local ____context_workingDir_15 = context.workingDir -- 90
		local ____temp_16 = input.path or "" -- 91
		local ____temp_17 = context.useChineseResponse and "zh" or "en" -- 92
		local ____pattern_18 = pattern -- 93
		local ____input_globs_19 = input.globs -- 94
		local ____input_useRegex_20 = input.useRegex -- 95
		local ____input_caseSensitive_21 = input.caseSensitive -- 96
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_22 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 98
		local ____math_max_11 = math.max -- 99
		local ____math_floor_10 = math.floor -- 99
		local ____input_limit_9 = input.limit -- 99
		if ____input_limit_9 == nil then -- 99
			____input_limit_9 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 99
		end -- 99
		local ____math_max_11_result_23 = ____math_max_11( -- 99
			1, -- 99
			____math_floor_10(__TS__Number(____input_limit_9)) -- 99
		) -- 99
		local ____math_max_14 = math.max -- 100
		local ____math_floor_13 = math.floor -- 100
		local ____input_offset_12 = input.offset -- 100
		if ____input_offset_12 == nil then -- 100
			____input_offset_12 = 0 -- 100
		end -- 100
		local output = __TS__Await(____Tools_searchFiles_24({ -- 89
			workDir = ____context_workingDir_15, -- 90
			path = ____temp_16, -- 91
			docLanguage = ____temp_17, -- 92
			pattern = ____pattern_18, -- 93
			globs = ____input_globs_19, -- 94
			useRegex = ____input_useRegex_20, -- 95
			caseSensitive = ____input_caseSensitive_21, -- 96
			includeContent = true, -- 97
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_22, -- 98
			limit = ____math_max_11_result_23, -- 99
			offset = ____math_max_14( -- 100
				0, -- 100
				____math_floor_13(__TS__Number(____input_offset_12)) -- 100
			), -- 100
			groupByFile = input.groupByFile == true -- 101
		})) -- 101
		return ____awaiter_resolve(nil, {output = output}) -- 101
	end) -- 101
end -- 77
local function searchDoraDoc(context, input) -- 106
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 106
		context.workflow.apiSearchesSinceBuild = (context.workflow.apiSearchesSinceBuild or 0) + 1 -- 107
		local ____Tools_searchDoraDoc_33 = Tools.searchDoraDoc -- 108
		local ____temp_29 = input.pattern or "" -- 109
		local ____temp_30 = input.docType or "dora-api" -- 110
		local ____temp_31 = context.useChineseResponse and "zh" or "en" -- 111
		local ____temp_32 = input.programmingLanguage or (input.docType == "godot-api" and "gdscript" or "ts") -- 112
		local ____math_min_28 = math.min -- 113
		local ____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27 = AgentConfig.AGENT_LIMITS.searchDoraDocLimitMax -- 113
		local ____math_max_26 = math.max -- 113
		local ____input_limit_25 = input.limit -- 113
		if ____input_limit_25 == nil then -- 113
			____input_limit_25 = 8 -- 113
		end -- 113
		local output = __TS__Await(____Tools_searchDoraDoc_33({ -- 108
			pattern = ____temp_29, -- 109
			docType = ____temp_30, -- 110
			docLanguage = ____temp_31, -- 111
			programmingLanguage = ____temp_32, -- 112
			limit = ____math_min_28( -- 113
				____AgentConfig_AGENT_LIMITS_searchDoraDocLimitMax_27, -- 113
				____math_max_26( -- 113
					1, -- 113
					__TS__Number(____input_limit_25) -- 113
				) -- 113
			), -- 113
			useRegex = input.useRegex, -- 114
			caseSensitive = false, -- 115
			includeContent = true, -- 116
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 117
		})) -- 117
		return ____awaiter_resolve(nil, {output = output}) -- 117
	end) -- 117
end -- 106
local function build(context, input) -- 122
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 122
		local paths = input.paths -- 123
		local results = {} -- 124
		local rawResults = {} -- 125
		local callFailureMessages = {} -- 126
		local succeeded = 0 -- 127
		do -- 127
			local i = 0 -- 128
			while i < #paths do -- 128
				local result -- 129
				local ____try = __TS__AsyncAwaiter(function() -- 129
					result = __TS__Await(Tools.build({ -- 131
						workDir = context.workingDir, -- 132
						path = paths[i + 1], -- 133
						isCancelled = function() return context.cancellation:isCancelled() end -- 134
					})) -- 134
				end) -- 134
				____try = ____try.catch( -- 134
					____try, -- 134
					function(____, err) -- 134
						return __TS__AsyncAwaiter(function() -- 134
							result = { -- 137
								success = false, -- 137
								failureKind = "tool", -- 137
								message = tostring(err) -- 137
							} -- 137
						end) -- 137
					end -- 137
				) -- 137
				__TS__Await(____try) -- 130
				if result.success then -- 130
					succeeded = succeeded + 1 -- 139
				else -- 139
					local ____temp_36 = result.failureKind == "tool" -- 142
					if ____temp_36 then -- 142
						local ____opt_34 = result.messages -- 142
						____temp_36 = (____opt_34 and #____opt_34 or 0) == 0 -- 142
					end -- 142
					if ____temp_36 then -- 142
						callFailureMessages[#callFailureMessages + 1] = result.message -- 142
					end -- 142
				end -- 142
				rawResults[#rawResults + 1] = result -- 143
				results[#results + 1] = __TS__ObjectAssign({index = i, path = paths[i + 1]}, result) -- 144
				if context.cancellation:isCancelled() then -- 144
					break -- 145
				end -- 145
				i = i + 1 -- 128
			end -- 128
		end -- 128
		local output = { -- 147
			success = succeeded == #paths, -- 148
			partial = succeeded > 0 and succeeded < #paths, -- 149
			mode = "batch", -- 150
			requestedBuildCount = #paths, -- 151
			buildCount = #results, -- 152
			succeededBuildCount = succeeded, -- 153
			failedBuildCount = #results - succeeded, -- 154
			skippedBuildCount = #paths - #results, -- 155
			results = results -- 156
		} -- 156
		context.workflow.unbuiltEdits = false -- 160
		context.workflow.editsSinceBuild = 0 -- 161
		context.workflow.editedPathsSinceBuild = {} -- 162
		context.workflow.hasBuilt = true -- 163
		context.workflow.lastBuildSucceeded = output.success == true -- 164
		if output.success == true and context.workflow.freshProjectBuildPending == true then -- 164
			context.workflow.freshProjectBuildPending = false -- 166
		end -- 166
		context.workflow.apiSearchesSinceBuild = 0 -- 168
		context.workflow.buildRepairPending = false -- 169
		if output.success ~= true then -- 169
			do -- 169
				local r = 0 -- 171
				while r < #rawResults do -- 171
					local messages = rawResults[r + 1].messages -- 172
					do -- 172
						local i = 0 -- 173
						while i < (messages and #messages or 0) do -- 173
							if messages[i + 1].success == false and messages[i + 1].file ~= "" then -- 173
								context.workflow.buildRepairPending = true -- 175
								break -- 176
							end -- 176
							i = i + 1 -- 173
						end -- 173
					end -- 173
					r = r + 1 -- 171
				end -- 171
			end -- 171
		end -- 171
		if output.success == true and context.workflow.failedTestNeedsBuild == true and context.workflow.failedTestHasSourceEdit == true then -- 171
			context.workflow.failedTestNeedsBuild = false -- 182
			context.workflow.failedTestHasSourceEdit = false -- 183
		end -- 183
		if #callFailureMessages > 0 then -- 183
			error(table.concat(callFailureMessages, "; ")) -- 186
		end -- 186
		return ____awaiter_resolve(nil, {output = output}) -- 186
	end) -- 186
end -- 122
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
		local ____opt_39 = output.godotImports -- 264
		if ____opt_39 and __TS__ArraySome( -- 264
			output.godotImports, -- 266
			function(____, batch) return batch.importedCount > 0 end -- 266
		) then -- 266
			context.workflow.unbuiltEdits = true -- 267
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 268
		end -- 268
		if output.success and mode == "lua" then -- 268
			updateDeterministicTestState(context, output.output) -- 271
		end -- 271
		return ____awaiter_resolve(nil, {output = output}) -- 271
	end) -- 271
end -- 252
editFile = function(context, input) -- 293
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 293
		if input.delete == true then -- 293
			local targetFile = type(input.path) == "string" and input.path or "" -- 296
			if __TS__StringTrim(targetFile) == "" then -- 296
				return ____awaiter_resolve(nil, {output = {success = false, message = "delete requires path"}}) -- 296
			end -- 296
			local normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile) -- 298
			local requiresBuild = AgentRuntimePolicy.requiresAgentBuildForPath(normalizedTargetFile) -- 299
			local result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {summary = "edit_file delete: " .. targetFile, toolName = "edit_file"}) -- 300
			if not result.success then -- 300
				return ____awaiter_resolve(nil, {output = result}) -- 300
			end -- 300
			if requiresBuild then -- 300
				context.workflow.unbuiltEdits = true -- 306
				context.workflow.lastBuildSucceeded = false -- 307
				if context.workflow.failedTestNeedsBuild == true then -- 307
					context.workflow.failedTestHasSourceEdit = true -- 308
				end -- 308
				local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 309
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 309
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 310
				end -- 310
				context.workflow.editedPathsSinceBuild = editedPaths -- 311
				context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 312
			end -- 312
			local ____result_checkpointed_42 = result.checkpointed -- 319
			local ____result_reversible_43 = result.reversible -- 320
			local ____result_binary_44 = result.binary -- 321
			local ____temp_45 = result.checkpointed and result.checkpointId or nil -- 322
			local ____temp_46 = result.checkpointed and result.checkpointSeq or nil -- 323
			local ____result_checkpointed_41 -- 324
			if result.checkpointed then -- 324
				____result_checkpointed_41 = nil -- 324
			else -- 324
				____result_checkpointed_41 = result.message -- 324
			end -- 324
			return ____awaiter_resolve(nil, {output = { -- 324
				success = true, -- 316
				changed = true, -- 317
				mode = "delete", -- 318
				checkpointed = ____result_checkpointed_42, -- 319
				reversible = ____result_reversible_43, -- 320
				binary = ____result_binary_44, -- 321
				checkpointId = ____temp_45, -- 322
				checkpointSeq = ____temp_46, -- 323
				message = ____result_checkpointed_41, -- 324
				files = {{path = targetFile, op = "delete"}} -- 325
			}}) -- 325
		end -- 325
		local operations = getAgentFileEditInputs(input) -- 329
		local isBatch = __TS__ArrayIsArray(input.edits) -- 330
		if #operations == 0 then -- 330
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing edit operations"}}) -- 330
		end -- 330
		local staged = {} -- 332
		local results = {} -- 333
		local successfulOperations = {} -- 334
		local function failOperation(index, path, code, message) -- 335
			results[#results + 1] = { -- 336
				index = index, -- 336
				path = path, -- 336
				success = false, -- 336
				code = code, -- 336
				message = message -- 336
			} -- 336
		end -- 335
		do -- 335
			local i = 0 -- 339
			while i < #operations do -- 339
				do -- 339
					local operation = operations[i + 1] -- 340
					local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 341
					if path == "" then -- 341
						failOperation(i, path, "INVALID_EDIT", "path is required") -- 343
						goto __continue70 -- 344
					end -- 344
					if operation.oldStr == operation.newStr then -- 344
						failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ") -- 347
						goto __continue70 -- 348
					end -- 348
					local stagedIndex = -1 -- 350
					do -- 350
						local j = 0 -- 351
						while j < #staged do -- 351
							if staged[j + 1].path == path then -- 351
								stagedIndex = j -- 353
								break -- 354
							end -- 354
							j = j + 1 -- 351
						end -- 351
					end -- 351
					if stagedIndex < 0 then -- 351
						local targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path) -- 358
						if not targetState.success then -- 358
							failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message) -- 360
							goto __continue70 -- 361
						end -- 361
						staged[#staged + 1] = { -- 363
							path = path, -- 364
							initialExists = targetState.exists, -- 365
							exists = targetState.exists, -- 366
							content = targetState.content, -- 367
							changed = false -- 368
						} -- 368
						stagedIndex = #staged - 1 -- 370
					end -- 370
					local target = staged[stagedIndex + 1] -- 372
					local guardDenial = getAgentFileEditPlanGuardDenial(context, operation) -- 373
					if guardDenial ~= nil then -- 373
						failOperation(i, path, guardDenial.code, guardDenial.message) -- 375
						goto __continue70 -- 376
					end -- 376
					local mode = "" -- 378
					if operation.oldStr == "" then -- 378
						if target.exists and AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr) then -- 378
							failOperation(i, path, "DUPLICATE_WHOLE_FILE", "rewrite rejected: the complete current file appears more than once in the replacement for " .. path) -- 381
							goto __continue70 -- 382
						end -- 382
						mode = target.exists and "overwrite" or "create" -- 384
						target.exists = true -- 385
						target.content = operation.newStr -- 386
					else -- 386
						if not target.exists then -- 386
							failOperation(i, path, "FILE_NOT_FOUND", ("read file failed: " .. path) .. " does not exist; use old_str=\"\" to create it earlier in the batch") -- 389
							goto __continue70 -- 390
						end -- 390
						local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content) -- 392
						local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr) -- 393
						local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr) -- 394
						local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 395
						if occurrences == 0 then -- 395
							local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 397
							if not indentTolerant.success then -- 397
								failOperation(i, path, "TEXT_NOT_FOUND", indentTolerant.message) -- 399
								goto __continue70 -- 400
							end -- 400
							target.content = indentTolerant.content -- 402
							mode = "replace_indent_tolerant" -- 403
						else -- 403
							if occurrences > 1 then -- 403
								failOperation( -- 406
									i, -- 406
									path, -- 406
									"AMBIGUOUS_MATCH", -- 406
									((("old_str appears " .. tostring(occurrences)) .. " times in ") .. path) .. ". Provide more context to identify one target." -- 406
								) -- 406
								goto __continue70 -- 407
							end -- 407
							target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 409
							mode = "replace" -- 410
						end -- 410
					end -- 410
					target.changed = true -- 413
					results[#results + 1] = {index = i, path = path, success = true, mode = mode} -- 414
					successfulOperations[#successfulOperations + 1] = operation -- 415
				end -- 415
				::__continue70:: -- 415
				i = i + 1 -- 339
			end -- 339
		end -- 339
		local changedTargets = __TS__ArrayFilter( -- 418
			staged, -- 418
			function(____, item) return item.changed end -- 418
		) -- 418
		if #changedTargets == 0 then -- 418
			local firstFailure = results[1] -- 420
			return ____awaiter_resolve(nil, {output = isBatch and ({ -- 420
				success = false, -- 423
				changed = false, -- 424
				mode = "batch", -- 425
				operationCount = #operations, -- 426
				succeededOperationCount = 0, -- 427
				failedOperationCount = #results, -- 428
				results = results, -- 429
				actualSaved = false -- 430
			}) or ({success = false, code = firstFailure and firstFailure.code, message = firstFailure and firstFailure.message or "edit failed", actualSaved = false})}) -- 430
		end -- 430
		local changes = __TS__ArrayMap( -- 440
			changedTargets, -- 440
			function(____, item) return {path = item.path, op = item.initialExists and "write" or "create", content = item.content} end -- 440
		) -- 440
		local applyRes = Tools.applyFileChanges( -- 445
			context.taskId, -- 445
			context.workingDir, -- 445
			changes, -- 445
			{ -- 445
				summary = isBatch and ((((("batch edit " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files via edit_file" or ((tostring(results[1].mode) .. " ") .. changedTargets[1].path) .. " via edit_file", -- 446
				toolName = "edit_file" -- 449
			} -- 449
		) -- 449
		if not applyRes.success then -- 449
			return ____awaiter_resolve( -- 449
				nil, -- 449
				{output = __TS__ObjectAssign({success = false, message = ((isBatch and "batch edit" or "write file") .. " failed: ") .. applyRes.message, actualSaved = false}, isBatch and ({results = results}) or ({}))} -- 452
			) -- 452
		end -- 452
		local files = __TS__ArrayMap( -- 455
			changes, -- 455
			function(____, change) return {path = change.path, op = change.op} end -- 455
		) -- 455
		local output -- 456
		if not isBatch then -- 456
			output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[1].path, { -- 458
				success = true, -- 459
				changed = true, -- 460
				mode = results[1].mode, -- 461
				checkpointId = applyRes.checkpointId, -- 462
				checkpointSeq = applyRes.checkpointSeq, -- 463
				files = files -- 464
			}) -- 464
		else -- 464
			local totalCharacters = 0 -- 467
			local actualSaved = true -- 468
			for ____, item in ipairs(changedTargets) do -- 469
				local current = Tools.readFileRaw(context.workingDir, item.path) -- 470
				if not current.success or current.content ~= item.content then -- 470
					actualSaved = false -- 471
				end -- 471
				if current.success then -- 471
					totalCharacters = totalCharacters + #current.content -- 472
				end -- 472
			end -- 472
			output = { -- 474
				success = true, -- 475
				changed = true, -- 476
				mode = "batch", -- 477
				operationCount = #operations, -- 478
				succeededOperationCount = #successfulOperations, -- 479
				failedOperationCount = #operations - #successfulOperations, -- 480
				partial = #successfulOperations < #operations, -- 481
				fileCount = #changedTargets, -- 482
				checkpointId = applyRes.checkpointId, -- 483
				checkpointSeq = applyRes.checkpointSeq, -- 484
				files = files, -- 485
				results = results, -- 486
				actualSaved = actualSaved, -- 487
				actualSavedCharacters = totalCharacters, -- 488
				currentFileExists = actualSaved, -- 489
				currentCharacters = totalCharacters, -- 490
				currentState = actualSaved and ((((("saved " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files" or "one or more batch file states could not be verified after commit" -- 491
			} -- 491
		end -- 491
		local authoredOperations = 0 -- 497
		local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 498
		for ____, operation in ipairs(successfulOperations) do -- 499
			do -- 499
				local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 500
				if not AgentRuntimePolicy.requiresAgentBuildForPath(path) then -- 500
					goto __continue98 -- 501
				end -- 501
				authoredOperations = authoredOperations + 1 -- 502
				if __TS__ArrayIndexOf(editedPaths, path) < 0 then -- 502
					editedPaths[#editedPaths + 1] = path -- 503
				end -- 503
			end -- 503
			::__continue98:: -- 503
		end -- 503
		if authoredOperations > 0 then -- 503
			context.workflow.unbuiltEdits = true -- 506
			context.workflow.lastBuildSucceeded = false -- 507
			if context.workflow.failedTestNeedsBuild == true then -- 507
				context.workflow.failedTestHasSourceEdit = true -- 508
			end -- 508
			context.workflow.editedPathsSinceBuild = editedPaths -- 509
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + authoredOperations -- 510
		end -- 510
		return ____awaiter_resolve(nil, {output = output}) -- 510
	end) -- 510
end -- 293
local function askUser(context, input) -- 515
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 515
		if context.services.publishQuestionnaire == nil then -- 515
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user is not available in this runtime"}}) -- 515
		end -- 515
		if context.sessionId == nil or context.sessionId <= 0 then -- 515
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user requires a session"}}) -- 515
		end -- 515
		local normalized = normalizeQuestionnaire(input) -- 522
		if not normalized.success then -- 522
			return ____awaiter_resolve(nil, {output = normalized}) -- 522
		end -- 522
		local result = __TS__Await(context.services:publishQuestionnaire({sessionId = context.sessionId, taskId = context.taskId, step = context.step, schema = normalized.schema})) -- 524
		if not result.success then -- 524
			return ____awaiter_resolve(nil, {output = result}) -- 524
		end -- 524
		context.workflow.waitingQuestionnaireId = result.questionnaireId -- 531
		return ____awaiter_resolve(nil, {output = {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}, control = {waitForUser = true, questionnaireId = result.questionnaireId}}) -- 531
	end) -- 531
end -- 515
local function spawnAgent(context, input) -- 538
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 538
		local prompt = type(input.prompt) == "string" and __TS__StringTrim(input.prompt) or "" -- 539
		if prompt == "" then -- 539
			if context.workflow.hasSpawnedSubAgentThisTask == true then -- 539
				return ____awaiter_resolve(nil, {output = {success = false, message = "Sub-agent results arrive asynchronously as handoffs; listing is rejected for the rest of this task after a successful spawn. Finish this turn instead."}}) -- 539
			end -- 539
			if context.services.listSubAgents == nil then -- 539
				return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent listing is not available in this runtime"}}) -- 539
			end -- 539
			if context.sessionId == nil or context.sessionId <= 0 then -- 539
				return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent listing requires a current session"}}) -- 539
			end -- 539
			local result = __TS__Await(context.services:listSubAgents({ -- 551
				sessionId = context.sessionId, -- 552
				projectRoot = context.workingDir, -- 553
				status = type(input.status) == "string" and input.status or nil, -- 554
				limit = type(input.limit) == "number" and input.limit or nil, -- 555
				offset = type(input.offset) == "number" and input.offset or nil, -- 556
				query = type(input.query) == "string" and input.query or nil -- 557
			})) -- 557
			return ____awaiter_resolve(nil, {output = result}) -- 557
		end -- 557
		if context.services.spawnSubAgent == nil then -- 557
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent dispatch is not available in this runtime"}}) -- 557
		end -- 557
		if context.sessionId == nil or context.sessionId <= 0 then -- 557
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent dispatch requires a parent session"}}) -- 557
		end -- 557
		local filesHint = __TS__ArrayIsArray(input.filesHint) and __TS__ArrayFilter( -- 568
			input.filesHint, -- 569
			function(____, item) return type(item) == "string" end -- 569
		) or nil -- 569
		local result = __TS__Await(context.services:spawnSubAgent({ -- 571
			parentSessionId = context.sessionId, -- 572
			projectRoot = context.workingDir, -- 573
			title = type(input.title) == "string" and input.title or "Sub", -- 574
			prompt = prompt, -- 575
			expectedOutput = type(input.expectedOutput) == "string" and input.expectedOutput or nil, -- 576
			filesHint = filesHint, -- 577
			disabledAgentTools = context.disabledAgentTools -- 578
		})) -- 578
		if not result.success then -- 578
			return ____awaiter_resolve(nil, {output = result}) -- 578
		end -- 578
		context.workflow.hasSpawnedSubAgentThisTask = true -- 581
		return ____awaiter_resolve(nil, {output = { -- 581
			success = true, -- 584
			sessionId = result.sessionId, -- 585
			taskId = result.taskId, -- 586
			title = result.title, -- 587
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not use the listing form in this task; results arrive as asynchronous handoffs." -- 588
		}, control = {spawnedSubAgent = true}}) -- 588
	end) -- 588
end -- 538
local function analyzeImageHandler(context, input) -- 594
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 594
		local visionContext = context.visionTaskContext or "" -- 595
		if type(input.context) == "string" and __TS__StringTrim(input.context) ~= "" then -- 595
			visionContext = visionContext == "" and input.context or (visionContext .. "\n\n") .. input.context -- 597
		end -- 597
		return ____awaiter_resolve( -- 597
			nil, -- 597
			{output = __TS__Await(analyzeImage({ -- 599
				workingDir = context.workingDir, -- 600
				taskId = context.taskId, -- 601
				sessionId = context.sessionId, -- 602
				binding = context.visionBinding, -- 603
				paths = input.paths, -- 604
				question = input.question, -- 605
				criteria = input.criteria, -- 606
				context = visionContext, -- 607
				isCancelled = function() return context.cancellation:isCancelled() end -- 608
			}))} -- 608
		) -- 608
	end) -- 608
end -- 594
____exports.AGENT_TOOL_HANDLERS = { -- 612
	read_file = readFile, -- 613
	analyze_image = analyzeImageHandler, -- 614
	grep_files = grepFiles, -- 615
	search_dora_doc = searchDoraDoc, -- 616
	build = build, -- 617
	execute_command = executeCommand, -- 618
	edit_file = editFile, -- 619
	write_file = writeFile, -- 620
	ask_user = askUser, -- 621
	spawn_agent = spawnAgent -- 622
} -- 622
return ____exports -- 622