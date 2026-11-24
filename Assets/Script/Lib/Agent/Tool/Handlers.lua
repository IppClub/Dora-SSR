-- [ts]: Handlers.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
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
			if line == "passed" or line == "overall: passed" then -- 196
				deterministicPass = true -- 197
			end -- 197
			if line == "failed" or line == "overall: failed" or __TS__StringStartsWith(line, "[selfcheck] fail ") then -- 197
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
	return deterministicFailure -- 250
end -- 191
local function executeCommand(context, input) -- 253
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 253
		local mode = type(input.mode) == "string" and input.mode or "" -- 254
		local output = __TS__Await(Tools.executeCommand({ -- 255
			workDir = context.workingDir, -- 256
			docLanguage = context.useChineseResponse and "zh" or "en", -- 257
			taskId = context.taskId, -- 258
			mode = mode, -- 259
			code = type(input.code) == "string" and input.code or nil, -- 260
			command = type(input.command) == "string" and input.command or nil, -- 261
			cwd = type(input.cwd) == "string" and input.cwd or nil, -- 262
			timeoutSeconds = type(input.timeoutSeconds) == "number" and input.timeoutSeconds or nil, -- 263
			isCancelled = function() return context.cancellation:isCancelled() end, -- 264
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 265
		})) -- 265
		local ____opt_39 = output.godotImports -- 265
		if ____opt_39 and __TS__ArraySome( -- 265
			output.godotImports, -- 267
			function(____, batch) return batch.importedCount > 0 end -- 267
		) then -- 267
			context.workflow.unbuiltEdits = true -- 268
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 269
		end -- 269
		if output.success and mode == "lua" and updateDeterministicTestState(context, output.output) then -- 269
			return ____awaiter_resolve( -- 269
				nil, -- 269
				{output = __TS__ObjectAssign({}, output, {success = false, code = "TEST_FAILED", message = "The Lua test reported a failure. See its output for details."})} -- 272
			) -- 272
		end -- 272
		return ____awaiter_resolve(nil, {output = output}) -- 272
	end) -- 272
end -- 253
editFile = function(context, input) -- 294
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 294
		if input.delete == true then -- 294
			local targetFile = type(input.path) == "string" and input.path or "" -- 297
			if __TS__StringTrim(targetFile) == "" then -- 297
				return ____awaiter_resolve(nil, {output = {success = false, message = "delete requires path"}}) -- 297
			end -- 297
			local normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile) -- 299
			local requiresBuild = AgentRuntimePolicy.requiresAgentBuildForPath(normalizedTargetFile) -- 300
			local result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {summary = "edit_file delete: " .. targetFile, toolName = "edit_file"}) -- 301
			if not result.success then -- 301
				return ____awaiter_resolve(nil, {output = result}) -- 301
			end -- 301
			if requiresBuild then -- 301
				context.workflow.unbuiltEdits = true -- 307
				context.workflow.lastBuildSucceeded = false -- 308
				if context.workflow.failedTestNeedsBuild == true then -- 308
					context.workflow.failedTestHasSourceEdit = true -- 309
				end -- 309
				local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 310
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 310
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 311
				end -- 311
				context.workflow.editedPathsSinceBuild = editedPaths -- 312
				context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 313
			end -- 313
			local ____result_checkpointed_42 = result.checkpointed -- 320
			local ____result_reversible_43 = result.reversible -- 321
			local ____result_binary_44 = result.binary -- 322
			local ____temp_45 = result.checkpointed and result.checkpointId or nil -- 323
			local ____temp_46 = result.checkpointed and result.checkpointSeq or nil -- 324
			local ____result_checkpointed_41 -- 325
			if result.checkpointed then -- 325
				____result_checkpointed_41 = nil -- 325
			else -- 325
				____result_checkpointed_41 = result.message -- 325
			end -- 325
			return ____awaiter_resolve(nil, {output = { -- 325
				success = true, -- 317
				changed = true, -- 318
				mode = "delete", -- 319
				checkpointed = ____result_checkpointed_42, -- 320
				reversible = ____result_reversible_43, -- 321
				binary = ____result_binary_44, -- 322
				checkpointId = ____temp_45, -- 323
				checkpointSeq = ____temp_46, -- 324
				message = ____result_checkpointed_41, -- 325
				files = {{path = targetFile, op = "delete"}} -- 326
			}}) -- 326
		end -- 326
		local operations = getAgentFileEditInputs(input) -- 330
		local isBatch = __TS__ArrayIsArray(input.edits) -- 331
		if #operations == 0 then -- 331
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing edit operations"}}) -- 331
		end -- 331
		local staged = {} -- 333
		local results = {} -- 334
		local successfulOperations = {} -- 335
		local function failOperation(index, path, code, message) -- 336
			results[#results + 1] = { -- 337
				index = index, -- 337
				path = path, -- 337
				success = false, -- 337
				code = code, -- 337
				message = message -- 337
			} -- 337
		end -- 336
		do -- 336
			local i = 0 -- 340
			while i < #operations do -- 340
				do -- 340
					local operation = operations[i + 1] -- 341
					local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 342
					if path == "" then -- 342
						failOperation(i, path, "INVALID_EDIT", "path is required") -- 344
						goto __continue70 -- 345
					end -- 345
					if operation.oldStr == operation.newStr then -- 345
						failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ") -- 348
						goto __continue70 -- 349
					end -- 349
					local stagedIndex = -1 -- 351
					do -- 351
						local j = 0 -- 352
						while j < #staged do -- 352
							if staged[j + 1].path == path then -- 352
								stagedIndex = j -- 354
								break -- 355
							end -- 355
							j = j + 1 -- 352
						end -- 352
					end -- 352
					if stagedIndex < 0 then -- 352
						local targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path) -- 359
						if not targetState.success then -- 359
							failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message) -- 361
							goto __continue70 -- 362
						end -- 362
						staged[#staged + 1] = { -- 364
							path = path, -- 365
							initialExists = targetState.exists, -- 366
							exists = targetState.exists, -- 367
							content = targetState.content, -- 368
							changed = false -- 369
						} -- 369
						stagedIndex = #staged - 1 -- 371
					end -- 371
					local target = staged[stagedIndex + 1] -- 373
					local guardDenial = getAgentFileEditPlanGuardDenial(context, operation) -- 374
					if guardDenial ~= nil then -- 374
						failOperation(i, path, guardDenial.code, guardDenial.message) -- 376
						goto __continue70 -- 377
					end -- 377
					local mode = "" -- 379
					if operation.oldStr == "" then -- 379
						if target.exists and AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr) then -- 379
							failOperation(i, path, "DUPLICATE_WHOLE_FILE", "rewrite rejected: the complete current file appears more than once in the replacement for " .. path) -- 382
							goto __continue70 -- 383
						end -- 383
						mode = target.exists and "overwrite" or "create" -- 385
						target.exists = true -- 386
						target.content = operation.newStr -- 387
					else -- 387
						if not target.exists then -- 387
							failOperation(i, path, "FILE_NOT_FOUND", ("read file failed: " .. path) .. " does not exist; use old_str=\"\" to create it earlier in the batch") -- 390
							goto __continue70 -- 391
						end -- 391
						local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content) -- 393
						local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr) -- 394
						local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr) -- 395
						local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 396
						if occurrences == 0 then -- 396
							local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 398
							if not indentTolerant.success then -- 398
								failOperation(i, path, "TEXT_NOT_FOUND", ((indentTolerant.message .. ". Read the current ") .. path) .. " around the target before retrying with exact text.") -- 400
								goto __continue70 -- 401
							end -- 401
							target.content = indentTolerant.content -- 403
							mode = "replace_indent_tolerant" -- 404
						else -- 404
							if occurrences > 1 then -- 404
								failOperation( -- 407
									i, -- 407
									path, -- 407
									"AMBIGUOUS_MATCH", -- 407
									((("old_str appears " .. tostring(occurrences)) .. " times in ") .. path) .. ". Provide more context to identify one target." -- 407
								) -- 407
								goto __continue70 -- 408
							end -- 408
							target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 410
							mode = "replace" -- 411
						end -- 411
					end -- 411
					target.changed = true -- 414
					results[#results + 1] = {index = i, path = path, success = true, mode = mode} -- 415
					successfulOperations[#successfulOperations + 1] = operation -- 416
				end -- 416
				::__continue70:: -- 416
				i = i + 1 -- 340
			end -- 340
		end -- 340
		local changedTargets = __TS__ArrayFilter( -- 419
			staged, -- 419
			function(____, item) return item.changed end -- 419
		) -- 419
		if #changedTargets == 0 then -- 419
			local firstFailure = results[1] -- 421
			return ____awaiter_resolve(nil, {output = isBatch and ({ -- 421
				success = false, -- 424
				changed = false, -- 425
				mode = "batch", -- 426
				operationCount = #operations, -- 427
				succeededOperationCount = 0, -- 428
				failedOperationCount = #results, -- 429
				results = results, -- 430
				actualSaved = false -- 431
			}) or ({success = false, code = firstFailure and firstFailure.code, message = firstFailure and firstFailure.message or "edit failed", actualSaved = false})}) -- 431
		end -- 431
		local changes = __TS__ArrayMap( -- 441
			changedTargets, -- 441
			function(____, item) return {path = item.path, op = item.initialExists and "write" or "create", content = item.content} end -- 441
		) -- 441
		local applyRes = Tools.applyFileChanges( -- 446
			context.taskId, -- 446
			context.workingDir, -- 446
			changes, -- 446
			{ -- 446
				summary = isBatch and ((((("batch edit " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files via edit_file" or ((tostring(results[1].mode) .. " ") .. changedTargets[1].path) .. " via edit_file", -- 447
				toolName = "edit_file" -- 450
			} -- 450
		) -- 450
		if not applyRes.success then -- 450
			return ____awaiter_resolve( -- 450
				nil, -- 450
				{output = __TS__ObjectAssign({success = false, message = ((isBatch and "batch edit" or "write file") .. " failed: ") .. applyRes.message, actualSaved = false}, isBatch and ({results = results}) or ({}))} -- 453
			) -- 453
		end -- 453
		local files = __TS__ArrayMap( -- 456
			changes, -- 456
			function(____, change) return {path = change.path, op = change.op} end -- 456
		) -- 456
		local output -- 457
		if not isBatch then -- 457
			output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[1].path, { -- 459
				success = true, -- 460
				changed = true, -- 461
				mode = results[1].mode, -- 462
				checkpointId = applyRes.checkpointId, -- 463
				checkpointSeq = applyRes.checkpointSeq, -- 464
				files = files -- 465
			}) -- 465
		else -- 465
			local totalCharacters = 0 -- 468
			local actualSaved = true -- 469
			for ____, item in ipairs(changedTargets) do -- 470
				local current = Tools.readFileRaw(context.workingDir, item.path) -- 471
				if not current.success or current.content ~= item.content then -- 471
					actualSaved = false -- 472
				end -- 472
				if current.success then -- 472
					totalCharacters = totalCharacters + #current.content -- 473
				end -- 473
			end -- 473
			output = { -- 475
				success = true, -- 476
				changed = true, -- 477
				mode = "batch", -- 478
				operationCount = #operations, -- 479
				succeededOperationCount = #successfulOperations, -- 480
				failedOperationCount = #operations - #successfulOperations, -- 481
				partial = #successfulOperations < #operations, -- 482
				fileCount = #changedTargets, -- 483
				checkpointId = applyRes.checkpointId, -- 484
				checkpointSeq = applyRes.checkpointSeq, -- 485
				files = files, -- 486
				results = results, -- 487
				actualSaved = actualSaved, -- 488
				actualSavedCharacters = totalCharacters, -- 489
				currentFileExists = actualSaved, -- 490
				currentCharacters = totalCharacters, -- 491
				currentState = actualSaved and ((((("saved " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files" or "one or more batch file states could not be verified after commit" -- 492
			} -- 492
		end -- 492
		local authoredOperations = 0 -- 498
		local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 499
		for ____, operation in ipairs(successfulOperations) do -- 500
			do -- 500
				local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 501
				if not AgentRuntimePolicy.requiresAgentBuildForPath(path) then -- 501
					goto __continue98 -- 502
				end -- 502
				authoredOperations = authoredOperations + 1 -- 503
				if __TS__ArrayIndexOf(editedPaths, path) < 0 then -- 503
					editedPaths[#editedPaths + 1] = path -- 504
				end -- 504
			end -- 504
			::__continue98:: -- 504
		end -- 504
		if authoredOperations > 0 then -- 504
			context.workflow.unbuiltEdits = true -- 507
			context.workflow.lastBuildSucceeded = false -- 508
			if context.workflow.failedTestNeedsBuild == true then -- 508
				context.workflow.failedTestHasSourceEdit = true -- 509
			end -- 509
			context.workflow.editedPathsSinceBuild = editedPaths -- 510
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + authoredOperations -- 511
		end -- 511
		return ____awaiter_resolve(nil, {output = output}) -- 511
	end) -- 511
end -- 294
local function askUser(context, input) -- 516
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 516
		if context.services.publishQuestionnaire == nil then -- 516
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user is not available in this runtime"}}) -- 516
		end -- 516
		if context.sessionId == nil or context.sessionId <= 0 then -- 516
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user requires a session"}}) -- 516
		end -- 516
		local normalized = normalizeQuestionnaire(input) -- 523
		if not normalized.success then -- 523
			return ____awaiter_resolve(nil, {output = normalized}) -- 523
		end -- 523
		local result = __TS__Await(context.services:publishQuestionnaire({sessionId = context.sessionId, taskId = context.taskId, step = context.step, schema = normalized.schema})) -- 525
		if not result.success then -- 525
			return ____awaiter_resolve(nil, {output = result}) -- 525
		end -- 525
		context.workflow.waitingQuestionnaireId = result.questionnaireId -- 532
		return ____awaiter_resolve(nil, {output = {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}, control = {waitForUser = true, questionnaireId = result.questionnaireId}}) -- 532
	end) -- 532
end -- 516
local function spawnAgent(context, input) -- 539
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 539
		local prompt = type(input.prompt) == "string" and __TS__StringTrim(input.prompt) or "" -- 540
		if prompt == "" then -- 540
			if context.workflow.hasSpawnedSubAgentThisTask == true then -- 540
				return ____awaiter_resolve(nil, {output = {success = false, message = "Sub-agent results arrive asynchronously as handoffs; listing is rejected for the rest of this task after a successful spawn. Finish this turn instead."}}) -- 540
			end -- 540
			if context.services.listSubAgents == nil then -- 540
				return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent listing is not available in this runtime"}}) -- 540
			end -- 540
			if context.sessionId == nil or context.sessionId <= 0 then -- 540
				return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent listing requires a current session"}}) -- 540
			end -- 540
			local result = __TS__Await(context.services:listSubAgents({ -- 552
				sessionId = context.sessionId, -- 553
				projectRoot = context.workingDir, -- 554
				status = type(input.status) == "string" and input.status or nil, -- 555
				limit = type(input.limit) == "number" and input.limit or nil, -- 556
				offset = type(input.offset) == "number" and input.offset or nil, -- 557
				query = type(input.query) == "string" and input.query or nil -- 558
			})) -- 558
			return ____awaiter_resolve(nil, {output = result}) -- 558
		end -- 558
		if context.services.spawnSubAgent == nil then -- 558
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent dispatch is not available in this runtime"}}) -- 558
		end -- 558
		if context.sessionId == nil or context.sessionId <= 0 then -- 558
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent dispatch requires a parent session"}}) -- 558
		end -- 558
		local filesHint = __TS__ArrayIsArray(input.filesHint) and __TS__ArrayFilter( -- 569
			input.filesHint, -- 570
			function(____, item) return type(item) == "string" end -- 570
		) or nil -- 570
		local result = __TS__Await(context.services:spawnSubAgent({ -- 572
			parentSessionId = context.sessionId, -- 573
			projectRoot = context.workingDir, -- 574
			title = type(input.title) == "string" and input.title or "Sub", -- 575
			prompt = prompt, -- 576
			expectedOutput = type(input.expectedOutput) == "string" and input.expectedOutput or nil, -- 577
			filesHint = filesHint, -- 578
			agentType = type(input.agentType) == "string" and input.agentType ~= "" and input.agentType or nil, -- 579
			disabledAgentTools = context.disabledAgentTools -- 580
		})) -- 580
		if not result.success then -- 580
			return ____awaiter_resolve(nil, {output = result}) -- 580
		end -- 580
		context.workflow.hasSpawnedSubAgentThisTask = true -- 583
		return ____awaiter_resolve(nil, {output = { -- 583
			success = true, -- 586
			sessionId = result.sessionId, -- 587
			taskId = result.taskId, -- 588
			title = result.title, -- 589
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not use the listing form in this task; results arrive as asynchronous handoffs." -- 590
		}, control = {spawnedSubAgent = true}}) -- 590
	end) -- 590
end -- 539
local function analyzeImageHandler(context, input) -- 596
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 596
		local visionContext = context.visionTaskContext or "" -- 597
		if type(input.context) == "string" and __TS__StringTrim(input.context) ~= "" then -- 597
			visionContext = visionContext == "" and input.context or (visionContext .. "\n\n") .. input.context -- 599
		end -- 599
		return ____awaiter_resolve( -- 599
			nil, -- 599
			{output = __TS__Await(analyzeImage({ -- 601
				workingDir = context.workingDir, -- 602
				taskId = context.taskId, -- 603
				sessionId = context.sessionId, -- 604
				binding = context.visionBinding, -- 605
				paths = input.paths, -- 606
				question = input.question, -- 607
				criteria = input.criteria, -- 608
				context = visionContext, -- 609
				isCancelled = function() return context.cancellation:isCancelled() end -- 610
			}))} -- 610
		) -- 610
	end) -- 610
end -- 596
____exports.AGENT_TOOL_HANDLERS = { -- 614
	read_file = readFile, -- 615
	analyze_image = analyzeImageHandler, -- 616
	grep_files = grepFiles, -- 617
	search_dora_doc = searchDoraDoc, -- 618
	build = build, -- 619
	execute_command = executeCommand, -- 620
	edit_file = editFile, -- 621
	write_file = writeFile, -- 622
	ask_user = askUser, -- 623
	spawn_agent = spawnAgent -- 624
} -- 624
return ____exports -- 624