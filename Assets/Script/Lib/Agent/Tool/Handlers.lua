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
local function fetchUrl(context, input) -- 191
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 191
		local output = __TS__Await(Tools.fetchUrl({ -- 192
			workDir = context.workingDir, -- 193
			url = type(input.url) == "string" and input.url or "", -- 194
			target = type(input.target) == "string" and input.target or "", -- 195
			isCancelled = function() return context.cancellation:isCancelled() end, -- 196
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 197
		})) -- 197
		return ____awaiter_resolve(nil, {output = output}) -- 197
	end) -- 197
end -- 191
local function updateDeterministicTestState(context, output) -- 202
	local deterministicFailure = false -- 203
	local deterministicPass = false -- 204
	local outputLines = __TS__StringSplit(output, "\n") -- 205
	do -- 205
		local i = 0 -- 206
		while i < #outputLines and not deterministicFailure do -- 206
			local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 207
			if line == "passed" then -- 207
				deterministicPass = true -- 208
			end -- 208
			if line == "failed" then -- 208
				deterministicFailure = true -- 210
				break -- 211
			end -- 211
			local searchFrom = 0 -- 213
			while searchFrom < #line do -- 213
				local failedIndex = (string.find( -- 215
					line, -- 215
					"failed", -- 215
					math.max(searchFrom + 1, 1), -- 215
					true -- 215
				) or 0) - 1 -- 215
				if failedIndex < 0 then -- 215
					break -- 216
				end -- 216
				local after = failedIndex + #"failed" -- 217
				while after < #line do -- 217
					local ch = __TS__StringSlice(line, after, after + 1) -- 219
					if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 219
						break -- 220
					end -- 220
					after = after + 1 -- 221
				end -- 221
				local afterEnd = after -- 223
				while afterEnd < #line do -- 223
					local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 225
					if ch < "0" or ch > "9" then -- 225
						break -- 226
					end -- 226
					afterEnd = afterEnd + 1 -- 227
				end -- 227
				local count -- 229
				if afterEnd > after then -- 229
					count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 231
				else -- 231
					local before = failedIndex - 1 -- 233
					while before >= 0 do -- 233
						local ch = __TS__StringSlice(line, before, before + 1) -- 235
						if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 235
							break -- 236
						end -- 236
						before = before - 1 -- 237
					end -- 237
					local beforeEnd = before + 1 -- 239
					while before >= 0 do -- 239
						local ch = __TS__StringSlice(line, before, before + 1) -- 241
						if ch < "0" or ch > "9" then -- 241
							break -- 242
						end -- 242
						before = before - 1 -- 243
					end -- 243
					if beforeEnd > before + 1 then -- 243
						count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 245
					end -- 245
				end -- 245
				if count ~= nil and count > 0 then -- 245
					deterministicFailure = true -- 248
					break -- 249
				end -- 249
				searchFrom = failedIndex + #"failed" -- 251
			end -- 251
			i = i + 1 -- 206
		end -- 206
	end -- 206
	if deterministicFailure then -- 206
		context.workflow.failedTestNeedsBuild = true -- 255
		context.workflow.failedTestHasSourceEdit = false -- 256
	elseif deterministicPass then -- 256
		context.workflow.failedTestNeedsBuild = false -- 258
		context.workflow.failedTestHasSourceEdit = false -- 259
	end -- 259
end -- 202
local function executeCommand(context, input) -- 263
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 263
		local mode = type(input.mode) == "string" and input.mode or "" -- 264
		local output = __TS__Await(Tools.executeCommand({ -- 265
			workDir = context.workingDir, -- 266
			docLanguage = context.useChineseResponse and "zh" or "en", -- 267
			taskId = context.taskId, -- 268
			mode = mode, -- 269
			code = type(input.code) == "string" and input.code or nil, -- 270
			command = type(input.command) == "string" and input.command or nil, -- 271
			cwd = type(input.cwd) == "string" and input.cwd or nil, -- 272
			timeoutSeconds = type(input.timeoutSeconds) == "number" and input.timeoutSeconds or nil, -- 273
			isCancelled = function() return context.cancellation:isCancelled() end, -- 274
			onProgress = function(____, progress) return context:emitProgress(__TS__ObjectAssign({success = false}, progress)) end -- 275
		})) -- 275
		local ____opt_39 = output.godotImports -- 275
		if ____opt_39 and __TS__ArraySome( -- 275
			output.godotImports, -- 277
			function(____, batch) return batch.importedCount > 0 end -- 277
		) then -- 277
			context.workflow.unbuiltEdits = true -- 278
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 279
		end -- 279
		if output.success and mode == "lua" then -- 279
			updateDeterministicTestState(context, output.output) -- 282
		end -- 282
		return ____awaiter_resolve(nil, {output = output}) -- 282
	end) -- 282
end -- 263
editFile = function(context, input) -- 304
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 304
		if input.delete == true then -- 304
			local targetFile = type(input.path) == "string" and input.path or "" -- 307
			if __TS__StringTrim(targetFile) == "" then -- 307
				return ____awaiter_resolve(nil, {output = {success = false, message = "delete requires path"}}) -- 307
			end -- 307
			local normalizedTargetFile = AgentRuntimePolicy.normalizeAgentPath(targetFile) -- 309
			local requiresBuild = AgentRuntimePolicy.requiresAgentBuildForPath(normalizedTargetFile) -- 310
			local result = Tools.deleteFile(context.taskId, context.workingDir, targetFile, {summary = "edit_file delete: " .. targetFile, toolName = "edit_file"}) -- 311
			if not result.success then -- 311
				return ____awaiter_resolve(nil, {output = result}) -- 311
			end -- 311
			if requiresBuild then -- 311
				context.workflow.unbuiltEdits = true -- 317
				context.workflow.lastBuildSucceeded = false -- 318
				if context.workflow.failedTestNeedsBuild == true then -- 318
					context.workflow.failedTestHasSourceEdit = true -- 319
				end -- 319
				local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 320
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 320
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 321
				end -- 321
				context.workflow.editedPathsSinceBuild = editedPaths -- 322
				context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + 1 -- 323
			end -- 323
			local ____result_checkpointed_42 = result.checkpointed -- 330
			local ____result_reversible_43 = result.reversible -- 331
			local ____result_binary_44 = result.binary -- 332
			local ____temp_45 = result.checkpointed and result.checkpointId or nil -- 333
			local ____temp_46 = result.checkpointed and result.checkpointSeq or nil -- 334
			local ____result_checkpointed_41 -- 335
			if result.checkpointed then -- 335
				____result_checkpointed_41 = nil -- 335
			else -- 335
				____result_checkpointed_41 = result.message -- 335
			end -- 335
			return ____awaiter_resolve(nil, {output = { -- 335
				success = true, -- 327
				changed = true, -- 328
				mode = "delete", -- 329
				checkpointed = ____result_checkpointed_42, -- 330
				reversible = ____result_reversible_43, -- 331
				binary = ____result_binary_44, -- 332
				checkpointId = ____temp_45, -- 333
				checkpointSeq = ____temp_46, -- 334
				message = ____result_checkpointed_41, -- 335
				files = {{path = targetFile, op = "delete"}} -- 336
			}}) -- 336
		end -- 336
		local operations = getAgentFileEditInputs(input) -- 340
		local isBatch = __TS__ArrayIsArray(input.edits) -- 341
		if #operations == 0 then -- 341
			return ____awaiter_resolve(nil, {output = {success = false, message = "missing edit operations"}}) -- 341
		end -- 341
		local staged = {} -- 343
		local results = {} -- 344
		local successfulOperations = {} -- 345
		local function failOperation(index, path, code, message) -- 346
			results[#results + 1] = { -- 347
				index = index, -- 347
				path = path, -- 347
				success = false, -- 347
				code = code, -- 347
				message = message -- 347
			} -- 347
		end -- 346
		do -- 346
			local i = 0 -- 350
			while i < #operations do -- 350
				do -- 350
					local operation = operations[i + 1] -- 351
					local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 352
					if path == "" then -- 352
						failOperation(i, path, "INVALID_EDIT", "path is required") -- 354
						goto __continue73 -- 355
					end -- 355
					if operation.oldStr == operation.newStr then -- 355
						failOperation(i, path, "INVALID_EDIT", "old_str and new_str must differ") -- 358
						goto __continue73 -- 359
					end -- 359
					local stagedIndex = -1 -- 361
					do -- 361
						local j = 0 -- 362
						while j < #staged do -- 362
							if staged[j + 1].path == path then -- 362
								stagedIndex = j -- 364
								break -- 365
							end -- 365
							j = j + 1 -- 362
						end -- 362
					end -- 362
					if stagedIndex < 0 then -- 362
						local targetState = Tools.inspectWorkspaceTextTarget(context.workingDir, path) -- 369
						if not targetState.success then -- 369
							failOperation(i, path, "INVALID_EDIT_TARGET", targetState.message) -- 371
							goto __continue73 -- 372
						end -- 372
						staged[#staged + 1] = { -- 374
							path = path, -- 375
							initialExists = targetState.exists, -- 376
							exists = targetState.exists, -- 377
							content = targetState.content, -- 378
							changed = false -- 379
						} -- 379
						stagedIndex = #staged - 1 -- 381
					end -- 381
					local target = staged[stagedIndex + 1] -- 383
					local guardDenial = getAgentFileEditPlanGuardDenial(context, operation) -- 384
					if guardDenial ~= nil then -- 384
						failOperation(i, path, guardDenial.code, guardDenial.message) -- 386
						goto __continue73 -- 387
					end -- 387
					local mode = "" -- 389
					if operation.oldStr == "" then -- 389
						if target.exists and AgentRuntimePolicy.containsWholeFileDuplicate(target.content, operation.newStr) then -- 389
							failOperation(i, path, "DUPLICATE_WHOLE_FILE", "rewrite rejected: the complete current file appears more than once in the replacement for " .. path) -- 392
							goto __continue73 -- 393
						end -- 393
						mode = target.exists and "overwrite" or "create" -- 395
						target.exists = true -- 396
						target.content = operation.newStr -- 397
					else -- 397
						if not target.exists then -- 397
							failOperation(i, path, "FILE_NOT_FOUND", ("read file failed: " .. path) .. " does not exist; use old_str=\"\" to create it earlier in the batch") -- 400
							goto __continue73 -- 401
						end -- 401
						local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(target.content) -- 403
						local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(operation.oldStr) -- 404
						local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(operation.newStr) -- 405
						local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 406
						if occurrences == 0 then -- 406
							local indentTolerant = AgentUtils.findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 408
							if not indentTolerant.success then -- 408
								failOperation(i, path, "TEXT_NOT_FOUND", indentTolerant.message) -- 410
								goto __continue73 -- 411
							end -- 411
							target.content = indentTolerant.content -- 413
							mode = "replace_indent_tolerant" -- 414
						else -- 414
							if occurrences > 1 then -- 414
								failOperation( -- 417
									i, -- 417
									path, -- 417
									"AMBIGUOUS_MATCH", -- 417
									((("old_str appears " .. tostring(occurrences)) .. " times in ") .. path) .. ". Provide more context to identify one target." -- 417
								) -- 417
								goto __continue73 -- 418
							end -- 418
							target.content = AgentUtils.replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 420
							mode = "replace" -- 421
						end -- 421
					end -- 421
					target.changed = true -- 424
					results[#results + 1] = {index = i, path = path, success = true, mode = mode} -- 425
					successfulOperations[#successfulOperations + 1] = operation -- 426
				end -- 426
				::__continue73:: -- 426
				i = i + 1 -- 350
			end -- 350
		end -- 350
		local changedTargets = __TS__ArrayFilter( -- 429
			staged, -- 429
			function(____, item) return item.changed end -- 429
		) -- 429
		if #changedTargets == 0 then -- 429
			local firstFailure = results[1] -- 431
			return ____awaiter_resolve(nil, {output = isBatch and ({ -- 431
				success = false, -- 434
				changed = false, -- 435
				mode = "batch", -- 436
				operationCount = #operations, -- 437
				succeededOperationCount = 0, -- 438
				failedOperationCount = #results, -- 439
				results = results, -- 440
				actualSaved = false -- 441
			}) or ({success = false, code = firstFailure and firstFailure.code, message = firstFailure and firstFailure.message or "edit failed", actualSaved = false})}) -- 441
		end -- 441
		local changes = __TS__ArrayMap( -- 451
			changedTargets, -- 451
			function(____, item) return {path = item.path, op = item.initialExists and "write" or "create", content = item.content} end -- 451
		) -- 451
		local applyRes = Tools.applyFileChanges( -- 456
			context.taskId, -- 456
			context.workingDir, -- 456
			changes, -- 456
			{ -- 456
				summary = isBatch and ((((("batch edit " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files via edit_file" or ((tostring(results[1].mode) .. " ") .. changedTargets[1].path) .. " via edit_file", -- 457
				toolName = "edit_file" -- 460
			} -- 460
		) -- 460
		if not applyRes.success then -- 460
			return ____awaiter_resolve( -- 460
				nil, -- 460
				{output = __TS__ObjectAssign({success = false, message = ((isBatch and "batch edit" or "write file") .. " failed: ") .. applyRes.message, actualSaved = false}, isBatch and ({results = results}) or ({}))} -- 463
			) -- 463
		end -- 463
		local files = __TS__ArrayMap( -- 466
			changes, -- 466
			function(____, change) return {path = change.path, op = change.op} end -- 466
		) -- 466
		local output -- 467
		if not isBatch then -- 467
			output = AgentRuntimePolicy.successfulEditResult(context.workingDir, changedTargets[1].path, { -- 469
				success = true, -- 470
				changed = true, -- 471
				mode = results[1].mode, -- 472
				checkpointId = applyRes.checkpointId, -- 473
				checkpointSeq = applyRes.checkpointSeq, -- 474
				files = files -- 475
			}) -- 475
		else -- 475
			local totalCharacters = 0 -- 478
			local actualSaved = true -- 479
			for ____, item in ipairs(changedTargets) do -- 480
				local current = Tools.readFileRaw(context.workingDir, item.path) -- 481
				if not current.success or current.content ~= item.content then -- 481
					actualSaved = false -- 482
				end -- 482
				if current.success then -- 482
					totalCharacters = totalCharacters + #current.content -- 483
				end -- 483
			end -- 483
			output = { -- 485
				success = true, -- 486
				changed = true, -- 487
				mode = "batch", -- 488
				operationCount = #operations, -- 489
				succeededOperationCount = #successfulOperations, -- 490
				failedOperationCount = #operations - #successfulOperations, -- 491
				partial = #successfulOperations < #operations, -- 492
				fileCount = #changedTargets, -- 493
				checkpointId = applyRes.checkpointId, -- 494
				checkpointSeq = applyRes.checkpointSeq, -- 495
				files = files, -- 496
				results = results, -- 497
				actualSaved = actualSaved, -- 498
				actualSavedCharacters = totalCharacters, -- 499
				currentFileExists = actualSaved, -- 500
				currentCharacters = totalCharacters, -- 501
				currentState = actualSaved and ((((("saved " .. tostring(#successfulOperations)) .. "/") .. tostring(#operations)) .. " operations across ") .. tostring(#changedTargets)) .. " files" or "one or more batch file states could not be verified after commit" -- 502
			} -- 502
		end -- 502
		local authoredOperations = 0 -- 508
		local editedPaths = context.workflow.editedPathsSinceBuild or ({}) -- 509
		for ____, operation in ipairs(successfulOperations) do -- 510
			do -- 510
				local path = AgentRuntimePolicy.normalizeAgentPath(operation.path) -- 511
				if not AgentRuntimePolicy.requiresAgentBuildForPath(path) then -- 511
					goto __continue101 -- 512
				end -- 512
				authoredOperations = authoredOperations + 1 -- 513
				if __TS__ArrayIndexOf(editedPaths, path) < 0 then -- 513
					editedPaths[#editedPaths + 1] = path -- 514
				end -- 514
			end -- 514
			::__continue101:: -- 514
		end -- 514
		if authoredOperations > 0 then -- 514
			context.workflow.unbuiltEdits = true -- 517
			context.workflow.lastBuildSucceeded = false -- 518
			if context.workflow.failedTestNeedsBuild == true then -- 518
				context.workflow.failedTestHasSourceEdit = true -- 519
			end -- 519
			context.workflow.editedPathsSinceBuild = editedPaths -- 520
			context.workflow.editsSinceBuild = (context.workflow.editsSinceBuild or 0) + authoredOperations -- 521
		end -- 521
		return ____awaiter_resolve(nil, {output = output}) -- 521
	end) -- 521
end -- 304
local function askUser(context, input) -- 526
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 526
		if context.services.publishQuestionnaire == nil then -- 526
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user is not available in this runtime"}}) -- 526
		end -- 526
		if context.sessionId == nil or context.sessionId <= 0 then -- 526
			return ____awaiter_resolve(nil, {output = {success = false, message = "ask_user requires a session"}}) -- 526
		end -- 526
		local normalized = normalizeQuestionnaire(input) -- 533
		if not normalized.success then -- 533
			return ____awaiter_resolve(nil, {output = normalized}) -- 533
		end -- 533
		local result = __TS__Await(context.services:publishQuestionnaire({sessionId = context.sessionId, taskId = context.taskId, step = context.step, schema = normalized.schema})) -- 535
		if not result.success then -- 535
			return ____awaiter_resolve(nil, {output = result}) -- 535
		end -- 535
		context.workflow.waitingQuestionnaireId = result.questionnaireId -- 542
		return ____awaiter_resolve(nil, {output = {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}, control = {waitForUser = true, questionnaireId = result.questionnaireId}}) -- 542
	end) -- 542
end -- 526
local function spawnAgent(context, input) -- 549
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 549
		local prompt = type(input.prompt) == "string" and __TS__StringTrim(input.prompt) or "" -- 550
		if prompt == "" then -- 550
			if context.workflow.hasSpawnedSubAgentThisTask == true then -- 550
				return ____awaiter_resolve(nil, {output = {success = false, message = "Sub-agent results arrive asynchronously as handoffs; listing is rejected for the rest of this task after a successful spawn. Finish this turn instead."}}) -- 550
			end -- 550
			if context.services.listSubAgents == nil then -- 550
				return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent listing is not available in this runtime"}}) -- 550
			end -- 550
			if context.sessionId == nil or context.sessionId <= 0 then -- 550
				return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent listing requires a current session"}}) -- 550
			end -- 550
			local result = __TS__Await(context.services:listSubAgents({ -- 562
				sessionId = context.sessionId, -- 563
				projectRoot = context.workingDir, -- 564
				status = type(input.status) == "string" and input.status or nil, -- 565
				limit = type(input.limit) == "number" and input.limit or nil, -- 566
				offset = type(input.offset) == "number" and input.offset or nil, -- 567
				query = type(input.query) == "string" and input.query or nil -- 568
			})) -- 568
			return ____awaiter_resolve(nil, {output = result}) -- 568
		end -- 568
		if context.services.spawnSubAgent == nil then -- 568
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent dispatch is not available in this runtime"}}) -- 568
		end -- 568
		if context.sessionId == nil or context.sessionId <= 0 then -- 568
			return ____awaiter_resolve(nil, {output = {success = false, message = "spawn_agent dispatch requires a parent session"}}) -- 568
		end -- 568
		local filesHint = __TS__ArrayIsArray(input.filesHint) and __TS__ArrayFilter( -- 579
			input.filesHint, -- 580
			function(____, item) return type(item) == "string" end -- 580
		) or nil -- 580
		local result = __TS__Await(context.services:spawnSubAgent({ -- 582
			parentSessionId = context.sessionId, -- 583
			projectRoot = context.workingDir, -- 584
			title = type(input.title) == "string" and input.title or "Sub", -- 585
			prompt = prompt, -- 586
			expectedOutput = type(input.expectedOutput) == "string" and input.expectedOutput or nil, -- 587
			filesHint = filesHint, -- 588
			disabledAgentTools = context.disabledAgentTools -- 589
		})) -- 589
		if not result.success then -- 589
			return ____awaiter_resolve(nil, {output = result}) -- 589
		end -- 589
		context.workflow.hasSpawnedSubAgentThisTask = true -- 592
		return ____awaiter_resolve(nil, {output = { -- 592
			success = true, -- 595
			sessionId = result.sessionId, -- 596
			taskId = result.taskId, -- 597
			title = result.title, -- 598
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not use the listing form in this task; results arrive as asynchronous handoffs." -- 599
		}, control = {spawnedSubAgent = true}}) -- 599
	end) -- 599
end -- 549
local function finish(_context, input) -- 605
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 605
		local message = type(input.message) == "string" and __TS__StringTrim(input.message) or "" -- 606
		return ____awaiter_resolve( -- 606
			nil, -- 606
			{ -- 607
				output = {success = true, message = message}, -- 608
				control = { -- 609
					concludeTask = true, -- 610
					finalMessage = message, -- 611
					completion = AgentUtils.normalizeAgentCompletionReport(input) -- 612
				} -- 612
			} -- 612
		) -- 612
	end) -- 612
end -- 605
local function analyzeImageHandler(context, input) -- 617
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 617
		local visionContext = context.visionTaskContext or "" -- 618
		if type(input.context) == "string" and __TS__StringTrim(input.context) ~= "" then -- 618
			visionContext = visionContext == "" and input.context or (visionContext .. "\n\n") .. input.context -- 620
		end -- 620
		return ____awaiter_resolve( -- 620
			nil, -- 620
			{output = __TS__Await(analyzeImage({ -- 622
				workingDir = context.workingDir, -- 623
				taskId = context.taskId, -- 624
				sessionId = context.sessionId, -- 625
				binding = context.visionBinding, -- 626
				paths = input.paths, -- 627
				question = input.question, -- 628
				criteria = input.criteria, -- 629
				context = visionContext, -- 630
				isCancelled = function() return context.cancellation:isCancelled() end -- 631
			}))} -- 631
		) -- 631
	end) -- 631
end -- 617
____exports.AGENT_TOOL_HANDLERS = { -- 635
	read_file = readFile, -- 636
	analyze_image = analyzeImageHandler, -- 637
	grep_files = grepFiles, -- 638
	search_dora_doc = searchDoraDoc, -- 639
	build = build, -- 640
	fetch_url = fetchUrl, -- 641
	execute_command = executeCommand, -- 642
	edit_file = editFile, -- 643
	write_file = writeFile, -- 644
	ask_user = askUser, -- 645
	spawn_agent = spawnAgent -- 646
} -- 646
return ____exports -- 646