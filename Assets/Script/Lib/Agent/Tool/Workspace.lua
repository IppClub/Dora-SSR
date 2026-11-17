-- [ts]: Workspace.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFlatMap = ____lualib.__TS__ArrayFlatMap -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local Set = ____lualib.Set -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Map = ____lualib.Map -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local getDoraDocDefinitionRoot, getDoraTutorialDocRoot, isEngineLogFilePath, getEngineLogText, ENGINE_LOG_FILE, ENGINE_LOG_VIRTUAL_FILE, extensionLevels -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local App = ____Dora.App -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local AgentConfig = require("Agent.Config.Defaults") -- 4
local ____Utils = require("Agent.Utils") -- 5
local Log = ____Utils.Log -- 5
local ____BinaryMetadata = require("Agent.Tool.BinaryMetadata") -- 6
local readBinaryResourceMetadata = ____BinaryMetadata.readBinaryResourceMetadata -- 6
function getDoraDocDefinitionRoot(docLanguage) -- 114
	local zhDir = Path( -- 115
		Content.assetPath, -- 115
		"Script", -- 115
		"Lib", -- 115
		"Dora", -- 115
		"zh-Hans" -- 115
	) -- 115
	local enDir = Path( -- 116
		Content.assetPath, -- 116
		"Script", -- 116
		"Lib", -- 116
		"Dora", -- 116
		"en" -- 116
	) -- 116
	return docLanguage == "zh" and zhDir or enDir -- 117
end -- 117
function getDoraTutorialDocRoot(docLanguage) -- 120
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 121
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 122
	return docLanguage == "zh" and zhDir or enDir -- 123
end -- 123
function ____exports.getDoraDocResultBaseRoot(docType, docLanguage) -- 176
	if docType == "godot-api" then -- 176
		return Path(Content.assetPath, "Doc", "godot-api") -- 177
	end -- 177
	if docType == "dora-tutorial" then -- 177
		return getDoraTutorialDocRoot(docLanguage) -- 179
	end -- 179
	return getDoraDocDefinitionRoot(docLanguage) -- 181
end -- 176
function isEngineLogFilePath(path) -- 453
	return path == ENGINE_LOG_VIRTUAL_FILE -- 454
end -- 454
function getEngineLogText() -- 510
	local folder = Path(Content.writablePath, ____exports.ENGINE_LOG_DOWNLOAD_DIR) -- 511
	if not Content:exist(folder) then -- 511
		Content:mkdir(folder) -- 513
	end -- 513
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 515
	if not App:saveLog(logPath) then -- 515
		return nil -- 517
	end -- 517
	return Content:load(logPath) -- 519
end -- 519
function ____exports.ensureSafeSearchGlobs(globs) -- 660
	local result = {} -- 661
	do -- 661
		local i = 0 -- 662
		while i < #globs do -- 662
			result[#result + 1] = globs[i + 1] -- 663
			i = i + 1 -- 662
		end -- 662
	end -- 662
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 665
	do -- 665
		local i = 0 -- 666
		while i < #requiredExcludes do -- 666
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 666
				result[#result + 1] = requiredExcludes[i + 1] -- 668
			end -- 668
			i = i + 1 -- 666
		end -- 666
	end -- 666
	return result -- 671
end -- 660
local function getDoraDocDefinitionExtsByCodeLanguage(programmingLanguage) -- 126
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 126
		return {"ts"} -- 128
	end -- 128
	return {"tl"} -- 130
end -- 126
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 133
	repeat -- 133
		local ____switch7 = programmingLanguage -- 133
		local ____cond7 = ____switch7 == "teal" -- 133
		if ____cond7 then -- 133
			return "tl" -- 135
		end -- 135
		____cond7 = ____cond7 or ____switch7 == "tl" -- 135
		if ____cond7 then -- 135
			return "tl" -- 136
		end -- 136
		do -- 136
			return programmingLanguage -- 137
		end -- 137
	until true -- 137
end -- 133
function ____exports.getDoraDocSearchTarget(docType, docLanguage, programmingLanguage) -- 141
	if docType == "godot-api" then -- 141
		return { -- 146
			root = ____exports.getDoraDocResultBaseRoot(docType, docLanguage), -- 146
			exts = {"md"}, -- 146
			globs = {"**/*.md"} -- 146
		} -- 146
	end -- 146
	if docType == "dora-tutorial" then -- 146
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 148
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 149
		return { -- 150
			root = Path(tutorialRoot, langDir), -- 151
			exts = {"md"}, -- 152
			globs = {"**/*.md"} -- 153
		} -- 153
	end -- 153
	local exts = getDoraDocDefinitionExtsByCodeLanguage(programmingLanguage) -- 156
	if docType == "love-api" or docType == "tic80-api" then -- 156
		local name = docType == "love-api" and "love" or "tic80" -- 158
		return { -- 159
			root = getDoraDocDefinitionRoot(docLanguage), -- 160
			exts = exts, -- 161
			globs = __TS__ArrayMap( -- 162
				exts, -- 162
				function(____, ext) return (name .. ".d.") .. ext end -- 162
			) -- 162
		} -- 162
	end -- 162
	return { -- 165
		root = getDoraDocDefinitionRoot(docLanguage), -- 166
		exts = exts, -- 167
		globs = __TS__ArrayFlatMap( -- 168
			exts, -- 168
			function(____, ext) return {"**/*." .. ext, "!**/love.d." .. ext, "!**/tic80.d." .. ext} end -- 168
		) -- 168
	} -- 168
end -- 141
function ____exports.isDoraDocFileInScope(docType, file) -- 184
	local normalized = string.lower(table.concat( -- 185
		__TS__StringSplit(file, "\\"), -- 185
		"/" -- 185
	)) -- 185
	local segments = __TS__StringSplit(normalized, "/") -- 186
	local baseName = segments[#segments] or normalized -- 187
	if docType == "godot-api" then -- 187
		return normalized == "readme.md" or #segments == 2 and segments[1] == "classes" and __TS__StringEndsWith(normalized, ".md") -- 188
	end -- 188
	if docType == "dora-tutorial" then -- 188
		return __TS__StringEndsWith(normalized, ".md") -- 189
	end -- 189
	if docType == "love-api" then -- 189
		return normalized == "love.d.ts" or normalized == "love.d.tl" -- 190
	end -- 190
	if docType == "tic80-api" then -- 190
		return normalized == "tic80.d.ts" or normalized == "tic80.d.tl" -- 191
	end -- 191
	return (__TS__StringEndsWith(normalized, ".ts") or __TS__StringEndsWith(normalized, ".tl")) and baseName ~= "love.d.ts" and baseName ~= "love.d.tl" and baseName ~= "tic80.d.ts" and baseName ~= "tic80.d.tl" -- 192
end -- 184
____exports.AGENT_DORA_DOC_PREFIX = "@dora-doc/" -- 199
____exports.ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 201
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 202
ENGINE_LOG_VIRTUAL_FILE = "@dora_full_logs.txt" -- 203
local function isAbsolutePathLike(path) -- 205
	if Content:isAbsolutePath(path) then -- 205
		return true -- 206
	end -- 206
	if __TS__StringStartsWith(path, "/") or __TS__StringStartsWith(path, "\\") then -- 206
		return true -- 207
	end -- 207
	local drivePath = string.match(path, "^%a:[/\\]") -- 208
	return drivePath ~= nil -- 209
end -- 205
function ____exports.isValidWorkspacePath(path) -- 212
	if path == "" then -- 212
		return false -- 213
	end -- 213
	if isAbsolutePathLike(path) then -- 213
		return false -- 214
	end -- 214
	local parts = __TS__StringSplit( -- 215
		table.concat( -- 215
			__TS__StringSplit(path, "\\"), -- 215
			"/" -- 215
		), -- 215
		"/" -- 215
	) -- 215
	if __TS__ArrayIndexOf(parts, "..") >= 0 then -- 215
		return false -- 216
	end -- 216
	return true -- 217
end -- 212
function ____exports.isValidWorkDir(workDir) -- 220
	if workDir == "" then -- 220
		return false -- 221
	end -- 221
	if not Content:isAbsolutePath(workDir) then -- 221
		return false -- 222
	end -- 222
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 222
		return false -- 223
	end -- 223
	return true -- 224
end -- 220
local function isValidSearchPath(path) -- 227
	if path == "" then -- 227
		return true -- 228
	end -- 228
	if isAbsolutePathLike(path) then -- 228
		return false -- 229
	end -- 229
	local parts = __TS__StringSplit( -- 230
		table.concat( -- 230
			__TS__StringSplit(path, "\\"), -- 230
			"/" -- 230
		), -- 230
		"/" -- 230
	) -- 230
	if __TS__ArrayIndexOf(parts, "..") >= 0 then -- 230
		return false -- 231
	end -- 231
	return true -- 232
end -- 227
function ____exports.resolveWorkspaceFilePath(workDir, path) -- 235
	if not ____exports.isValidWorkDir(workDir) then -- 235
		return nil -- 236
	end -- 236
	if not ____exports.isValidWorkspacePath(path) then -- 236
		return nil -- 237
	end -- 237
	return Path(workDir, path) -- 238
end -- 235
function ____exports.resolveWorkspaceSearchPath(workDir, path) -- 241
	if not ____exports.isValidWorkDir(workDir) then -- 241
		return nil -- 242
	end -- 242
	if not isValidSearchPath(path) then -- 242
		return nil -- 243
	end -- 243
	return path == "" and workDir or Path(workDir, path) -- 244
end -- 241
function ____exports.toWorkspaceRelativePath(workDir, path) -- 247
	if path == "" then -- 247
		return path -- 248
	end -- 248
	if not Content:isAbsolutePath(path) then -- 248
		return path -- 249
	end -- 249
	return Path:getRelative(path, workDir) -- 250
end -- 247
local function toWorkspaceRelativeFileList(workDir, files) -- 253
	return __TS__ArrayMap( -- 254
		files, -- 254
		function(____, file) return ____exports.toWorkspaceRelativePath(workDir, file) end -- 254
	) -- 254
end -- 253
local function toWorkspaceRelativeSearchResults(workDir, results) -- 257
	local mapped = {} -- 258
	do -- 258
		local i = 0 -- 259
		while i < #results do -- 259
			local row = results[i + 1] -- 260
			local clone = __TS__ObjectAssign({}, row) -- 261
			clone.file = ____exports.toWorkspaceRelativePath(workDir, clone.file) -- 262
			mapped[#mapped + 1] = clone -- 263
			i = i + 1 -- 259
		end -- 259
	end -- 259
	return mapped -- 265
end -- 257
function ____exports.resolveWorkspaceDirectoryPath(workDir, path) -- 268
	local relative = __TS__StringTrim(path or "") -- 269
	if relative == "" then -- 269
		return {success = true, path = workDir, relative = "."} -- 271
	end -- 271
	if not ____exports.isValidWorkDir(workDir) or not ____exports.isValidWorkspacePath(relative) then -- 271
		return {success = false, message = "invalid cwd path"} -- 274
	end -- 274
	local resolved = Path(workDir, relative) -- 276
	if not Content:exist(resolved) then -- 276
		return {success = false, message = "cwd does not exist"} -- 278
	end -- 278
	if not Content:isdir(resolved) then -- 278
		return {success = false, message = "cwd is not a directory"} -- 281
	end -- 281
	return {success = true, path = resolved, relative = relative} -- 283
end -- 268
local AGENT_SKILL_PREFIX = "@agent-skill/" -- 286
function ____exports.toDocRelativePath(baseRoot, path, docType) -- 288
	if path == "" then -- 288
		return path -- 289
	end -- 289
	local relative = Content:isAbsolutePath(path) and Path:getRelative(path, baseRoot) or path -- 290
	return ((____exports.AGENT_DORA_DOC_PREFIX .. docType) .. "/") .. relative -- 291
end -- 288
local function resolveAgentDoraDocFilePath(path, docLanguage) -- 294
	if not docLanguage then -- 294
		return nil -- 295
	end -- 295
	local relative = path -- 296
	local docType = "dora-tutorial" -- 297
	if __TS__StringStartsWith(path, ____exports.AGENT_DORA_DOC_PREFIX) then -- 297
		local namespaced = __TS__StringSlice(path, #____exports.AGENT_DORA_DOC_PREFIX) -- 299
		if __TS__StringStartsWith(namespaced, "dora-api/") then -- 299
			docType = "dora-api" -- 301
			relative = string.sub(namespaced, 10) -- 302
		elseif __TS__StringStartsWith(namespaced, "godot-api/") then -- 302
			docType = "godot-api" -- 304
			relative = string.sub(namespaced, 11) -- 305
		elseif __TS__StringStartsWith(namespaced, "love-api/") then -- 305
			docType = "love-api" -- 307
			relative = string.sub(namespaced, 10) -- 308
		elseif __TS__StringStartsWith(namespaced, "tic80-api/") then -- 308
			docType = "tic80-api" -- 310
			relative = string.sub(namespaced, 11) -- 311
		elseif __TS__StringStartsWith(namespaced, "dora-tutorial/") then -- 311
			docType = "dora-tutorial" -- 313
			relative = string.sub(namespaced, 15) -- 314
		elseif __TS__StringStartsWith(namespaced, "api/") then -- 314
			docType = "dora-api" -- 316
			relative = string.sub(namespaced, 5) -- 317
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 317
			docType = "dora-tutorial" -- 319
			relative = string.sub(namespaced, 10) -- 320
		else -- 320
			return nil -- 322
		end -- 322
	end -- 322
	if not ____exports.isValidWorkspacePath(relative) then -- 322
		return nil -- 325
	end -- 325
	if not ____exports.isDoraDocFileInScope(docType, relative) then -- 325
		return nil -- 326
	end -- 326
	local root = ____exports.getDoraDocResultBaseRoot(docType, docLanguage) -- 327
	local candidate = Path(root, relative) -- 328
	local checked = Path:getRelative(candidate, root) -- 329
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 329
		return nil -- 330
	end -- 330
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 330
		return candidate -- 332
	end -- 332
	return nil -- 334
end -- 294
local function resolveAgentSkillFilePath(workDir, path) -- 337
	if not __TS__StringStartsWith(path, AGENT_SKILL_PREFIX) then -- 337
		return nil -- 338
	end -- 338
	local namespaced = table.concat( -- 339
		__TS__StringSplit( -- 339
			__TS__StringSlice(path, #AGENT_SKILL_PREFIX), -- 339
			"\\" -- 339
		), -- 339
		"/" -- 339
	) -- 339
	local root = "" -- 340
	local relative = "" -- 341
	if __TS__StringStartsWith(namespaced, "builtin/") then -- 341
		root = Path(Content.assetPath, "Doc", "skills") -- 343
		relative = __TS__StringSlice(namespaced, #"builtin/") -- 344
	elseif __TS__StringStartsWith(namespaced, "user/") then -- 344
		root = Path(Content.writablePath, ".agent", "skills") -- 346
		relative = __TS__StringSlice(namespaced, #"user/") -- 347
	elseif __TS__StringStartsWith(namespaced, "project/") then -- 347
		root = Path(workDir, ".agent", "skills") -- 349
		relative = __TS__StringSlice(namespaced, #"project/") -- 350
	else -- 350
		return nil -- 352
	end -- 352
	if not ____exports.isValidWorkspacePath(relative) or relative == "." then -- 352
		return nil -- 354
	end -- 354
	local candidate = Path(root, relative) -- 355
	local checked = Path:getRelative(candidate, root) -- 356
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 356
		return nil -- 357
	end -- 357
	if not Content:exist(candidate) or Content:isdir(candidate) then -- 357
		return nil -- 358
	end -- 358
	return candidate -- 359
end -- 337
function ____exports.resolveAgentContentVirtualPath(workDir, path, docLanguage) -- 363
	if docLanguage == nil then -- 363
		docLanguage = "en" -- 363
	end -- 363
	if __TS__StringStartsWith(path, ____exports.AGENT_DORA_DOC_PREFIX) then -- 363
		return resolveAgentDoraDocFilePath(path, docLanguage) -- 365
	end -- 365
	if __TS__StringStartsWith(path, AGENT_SKILL_PREFIX) then -- 365
		return resolveAgentSkillFilePath(workDir, path) -- 367
	end -- 367
	if isEngineLogFilePath(path) then -- 367
		if getEngineLogText() == nil then -- 367
			return nil -- 369
		end -- 369
		return Path(Content.writablePath, ____exports.ENGINE_LOG_DOWNLOAD_DIR, ENGINE_LOG_FILE) -- 370
	end -- 370
	return nil -- 372
end -- 363
function ____exports.isAgentContentVirtualPath(path) -- 375
	return __TS__StringStartsWith(path, ____exports.AGENT_DORA_DOC_PREFIX) or __TS__StringStartsWith(path, AGENT_SKILL_PREFIX) or isEngineLogFilePath(path) -- 376
end -- 375
function ____exports.ensureDirPath(dir) -- 379
	if dir == "." or dir == "" then -- 379
		return true -- 380
	end -- 380
	if Content:exist(dir) then -- 380
		return Content:isdir(dir) -- 381
	end -- 381
	local parent = Path:getPath(dir) -- 382
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 382
		if not ____exports.ensureDirPath(parent) then -- 382
			return false -- 384
		end -- 384
	end -- 384
	return Content:mkdir(dir) -- 386
end -- 379
function ____exports.ensureDirForFile(path) -- 389
	local dir = Path:getPath(path) -- 390
	return ____exports.ensureDirPath(dir) -- 391
end -- 389
function ____exports.getFileState(path) -- 394
	local exists = Content:exist(path) -- 395
	if not exists then -- 395
		return {exists = false, content = "", bytes = 0} -- 397
	end -- 397
	if Content:isdir(path) then -- 397
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 404
	end -- 404
	local content = Content:load(path) -- 411
	if type(content) ~= "string" then -- 411
		return {exists = true, content = "", bytes = 0} -- 413
	end -- 413
	return {exists = true, content = content, bytes = #content} -- 419
end -- 394
function ____exports.inspectReadableFile(path) -- 426
	do -- 426
		local function ____catch(e) -- 426
			Log( -- 448
				"Warn", -- 448
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 448
			) -- 448
			return true, {success = true} -- 449
		end -- 449
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 449
			local size, isBinary = Content:getAttr(path) -- 428
			if size == nil then -- 428
				return true, {success = false, message = "failed to read file"} -- 430
			end -- 430
			if isBinary then -- 430
				return true, { -- 436
					success = false, -- 437
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 438
					size = type(size) == "number" and size or nil, -- 439
					isBinary = true -- 440
				} -- 440
			end -- 440
			return true, { -- 443
				success = true, -- 444
				size = type(size) == "number" and size or nil -- 445
			} -- 445
		end) -- 445
		if not ____try then -- 445
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 445
		end -- 445
		if ____hasReturned then -- 445
			return ____returnValue -- 427
		end -- 427
	end -- 427
end -- 426
local function readEngineLogFile(path) -- 457
	if not isEngineLogFilePath(path) then -- 457
		return nil -- 458
	end -- 458
	local content = getEngineLogText() -- 459
	if content == nil then -- 459
		return {success = false, message = "failed to read engine logs"} -- 461
	end -- 461
	return {success = true, content = content, size = #content} -- 463
end -- 457
local function readTextOrBinaryMetadata(fullPath) -- 466
	local attr = ____exports.inspectReadableFile(fullPath) -- 467
	if not attr.success then -- 467
		if attr.isBinary and attr.size ~= nil then -- 467
			return __TS__ObjectAssign( -- 470
				{}, -- 470
				attr, -- 470
				readBinaryResourceMetadata(fullPath, attr.size) -- 470
			) -- 470
		end -- 470
		return attr -- 472
	end -- 472
	return { -- 474
		success = true, -- 474
		content = Content:load(fullPath), -- 474
		size = attr.size -- 474
	} -- 474
end -- 466
local function readWorkspaceFile(workDir, path, docLanguage) -- 477
	local engineLog = readEngineLogFile(path) -- 478
	if engineLog then -- 478
		return engineLog -- 479
	end -- 479
	local fullPath = ____exports.resolveWorkspaceFilePath(workDir, path) -- 480
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 480
		return readTextOrBinaryMetadata(fullPath) -- 482
	end -- 482
	local docPath = resolveAgentDoraDocFilePath(path, docLanguage) -- 484
	if docPath then -- 484
		return readTextOrBinaryMetadata(docPath) -- 486
	end -- 486
	local skillPath = resolveAgentSkillFilePath(workDir, path) -- 488
	if skillPath then -- 488
		return readTextOrBinaryMetadata(skillPath) -- 490
	end -- 490
	if not fullPath then -- 490
		return {success = false, message = "invalid path or workDir"} -- 492
	end -- 492
	return {success = false, message = "file not found"} -- 493
end -- 477
function ____exports.readFileRaw(workDir, path, docLanguage) -- 496
	return readWorkspaceFile(workDir, path, docLanguage) -- 497
end -- 496
function ____exports.inspectWorkspaceTextTarget(workDir, path) -- 500
	local fullPath = ____exports.resolveWorkspaceFilePath(workDir, path) -- 501
	if not fullPath then -- 501
		return {success = false, message = "invalid path or workDir"} -- 502
	end -- 502
	if not Content:exist(fullPath) then -- 502
		return {success = true, exists = false, content = ""} -- 503
	end -- 503
	if Content:isdir(fullPath) then -- 503
		return {success = false, message = "target is a directory"} -- 504
	end -- 504
	local attr = ____exports.inspectReadableFile(fullPath) -- 505
	if not attr.success then -- 505
		return {success = false, message = attr.message} -- 506
	end -- 506
	return { -- 507
		success = true, -- 507
		exists = true, -- 507
		content = Content:load(fullPath) -- 507
	} -- 507
end -- 500
function ____exports.getLogs(req) -- 522
	local text = getEngineLogText() -- 523
	if text == nil then -- 523
		return {success = false, message = "failed to read engine logs"} -- 525
	end -- 525
	local tailLines = math.max( -- 527
		1, -- 527
		math.floor(req and req.tailLines or 200) -- 527
	) -- 527
	local allLines = __TS__StringSplit(text, "\n") -- 528
	local logs = __TS__ArraySlice( -- 529
		allLines, -- 529
		math.max(0, #allLines - tailLines) -- 529
	) -- 529
	return req and req.joinText and ({ -- 530
		success = true, -- 530
		logs = logs, -- 530
		text = table.concat(logs, "\n") -- 530
	}) or ({success = true, logs = logs}) -- 530
end -- 522
function ____exports.listFiles(req) -- 533
	local root = req.path or "" -- 539
	local searchRoot = ____exports.resolveWorkspaceSearchPath(req.workDir, root) -- 540
	if searchRoot == nil then -- 540
		return {success = false, message = "invalid path or workDir"} -- 542
	end -- 542
	do -- 542
		local function ____catch(e) -- 542
			return true, { -- 560
				success = false, -- 560
				message = tostring(e) -- 560
			} -- 560
		end -- 560
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 560
			local userGlobs = req.globs ~= nil and #req.globs > 0 and req.globs or ({"**"}) -- 545
			local globs = ____exports.ensureSafeSearchGlobs(userGlobs) -- 546
			local files = Content:glob(searchRoot, globs, req.preferSourceVariants == false and ({}) or extensionLevels) -- 547
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 548
			local totalEntries = #files -- 549
			local maxEntries = math.max( -- 550
				1, -- 550
				math.floor(req.maxEntries or 200) -- 550
			) -- 550
			local truncated = totalEntries > maxEntries -- 551
			return true, { -- 552
				success = true, -- 553
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 554
				totalEntries = totalEntries, -- 555
				truncated = truncated, -- 556
				maxEntries = maxEntries -- 557
			} -- 557
		end) -- 557
		if not ____try then -- 557
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 557
		end -- 557
		if ____hasReturned then -- 557
			return ____returnValue -- 544
		end -- 544
	end -- 544
end -- 533
local function formatReadSlice(content, startLine, endLine) -- 564
	local lines = __TS__StringSplit(content, "\n") -- 569
	local totalLines = #lines -- 570
	if totalLines == 0 then -- 570
		return { -- 572
			success = true, -- 573
			content = "", -- 574
			totalLines = 0, -- 575
			startLine = 1, -- 576
			endLine = 0, -- 577
			truncated = false -- 578
		} -- 578
	end -- 578
	local rawStart = math.floor(startLine) -- 581
	local ____temp_4 -- 582
	if endLine == nil then -- 582
		____temp_4 = nil -- 582
	else -- 582
		____temp_4 = math.floor(endLine) -- 582
	end -- 582
	local rawEnd = ____temp_4 -- 582
	if rawStart == 0 then -- 582
		return {success = false, message = "startLine cannot be 0"} -- 584
	end -- 584
	if rawEnd == 0 then -- 584
		return {success = false, message = "endLine cannot be 0"} -- 587
	end -- 587
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 589
	if start > totalLines then -- 589
		return { -- 593
			success = false, -- 593
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 593
		} -- 593
	end -- 593
	local ____end = math.min( -- 595
		totalLines, -- 596
		rawEnd == nil and start + AgentConfig.AGENT_LIMITS.readFileDefaultLimit - 1 or (rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1)) -- 597
	) -- 597
	if ____end < start then -- 597
		return { -- 604
			success = false, -- 605
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 606
		} -- 606
	end -- 606
	local slice = {} -- 609
	do -- 609
		local i = start -- 610
		while i <= ____end do -- 610
			slice[#slice + 1] = lines[i] -- 611
			i = i + 1 -- 610
		end -- 610
	end -- 610
	local truncated = start > 1 or ____end < totalLines -- 613
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 614
	local body = table.concat(slice, "\n") -- 619
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 620
	return { -- 621
		success = true, -- 622
		content = output, -- 623
		totalLines = totalLines, -- 624
		startLine = start, -- 625
		endLine = ____end, -- 626
		truncated = truncated -- 627
	} -- 627
end -- 564
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 631
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 638
	if not fallback.success or fallback.content == nil then -- 638
		return fallback -- 639
	end -- 639
	local resolvedStartLine = startLine or 1 -- 640
	return formatReadSlice(fallback.content, resolvedStartLine, endLine) -- 641
end -- 631
____exports.codeExtensions = { -- 648
	".lua", -- 648
	".tl", -- 648
	".yue", -- 648
	".ts", -- 648
	".tsx", -- 648
	".xml", -- 648
	".md", -- 648
	".yarn", -- 648
	".wa", -- 648
	".mod", -- 648
	".gd", -- 648
	".tscn", -- 648
	".tres", -- 648
	".gdshader", -- 648
	".gdshaderinc", -- 648
	".godot" -- 648
} -- 648
extensionLevels = { -- 649
	vs = 2, -- 650
	bl = 2, -- 651
	ts = 1, -- 652
	tsx = 1, -- 653
	tl = 1, -- 654
	yue = 1, -- 655
	xml = 1, -- 656
	lua = 0 -- 657
} -- 657
function ____exports.splitSearchPatterns(pattern) -- 674
	local trimmed = __TS__StringTrim(pattern or "") -- 675
	if trimmed == "" then -- 675
		return {} -- 676
	end -- 676
	local out = {} -- 677
	local seen = __TS__New(Set) -- 678
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 679
		local p = __TS__StringTrim(tostring(p0)) -- 680
		if p ~= "" and not seen:has(p) then -- 680
			seen:add(p) -- 682
			out[#out + 1] = p -- 683
		end -- 683
	end -- 683
	return out -- 686
end -- 674
function ____exports.splitWhitespaceSearchPatterns(pattern) -- 689
	local out = {} -- 690
	local seen = __TS__New(Set) -- 691
	for p0 in string.gmatch(pattern, "(%S+)") do -- 692
		local p = __TS__StringTrim(tostring(p0)) -- 693
		local key = string.lower(p) -- 694
		if p ~= "" and not seen:has(key) then -- 694
			seen:add(key) -- 696
			out[#out + 1] = p -- 697
		end -- 697
	end -- 697
	return out -- 700
end -- 689
local function mergeSearchFileResultsUnique(resultsList) -- 703
	local merged = {} -- 704
	local seen = __TS__New(Set) -- 705
	do -- 705
		local i = 0 -- 706
		while i < #resultsList do -- 706
			local list = resultsList[i + 1] -- 707
			do -- 707
				local j = 0 -- 708
				while j < #list do -- 708
					do -- 708
						local row = list[j + 1] -- 709
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 710
						if seen:has(key) then -- 710
							goto __continue158 -- 711
						end -- 711
						seen:add(key) -- 712
						merged[#merged + 1] = list[j + 1] -- 713
					end -- 713
					::__continue158:: -- 713
					j = j + 1 -- 708
				end -- 708
			end -- 708
			i = i + 1 -- 706
		end -- 706
	end -- 706
	return merged -- 716
end -- 703
local function buildGroupedSearchResults(results) -- 719
	local order = {} -- 724
	local grouped = __TS__New(Map) -- 725
	do -- 725
		local i = 0 -- 730
		while i < #results do -- 730
			local row = results[i + 1] -- 731
			local file = row.file -- 732
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 733
			local bucket = grouped:get(key) -- 734
			if not bucket then -- 734
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 736
				grouped:set(key, bucket) -- 737
				order[#order + 1] = key -- 738
			end -- 738
			bucket.totalMatches = bucket.totalMatches + 1 -- 740
			local ____bucket_matches_5 = bucket.matches -- 740
			____bucket_matches_5[#____bucket_matches_5 + 1] = results[i + 1] -- 741
			i = i + 1 -- 730
		end -- 730
	end -- 730
	local out = {} -- 743
	do -- 743
		local i = 0 -- 748
		while i < #order do -- 748
			local bucket = grouped:get(order[i + 1]) -- 749
			if bucket then -- 749
				out[#out + 1] = bucket -- 750
			end -- 750
			i = i + 1 -- 748
		end -- 748
	end -- 748
	return out -- 752
end -- 719
function ____exports.searchFiles(req) -- 755
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 755
		local requestedPath = __TS__StringTrim(req.path or "") -- 769
		local isVirtualDoc = __TS__StringStartsWith(requestedPath, ____exports.AGENT_DORA_DOC_PREFIX) -- 770
		local ____isVirtualDoc_6 -- 771
		if isVirtualDoc then -- 771
			____isVirtualDoc_6 = resolveAgentDoraDocFilePath(requestedPath, req.docLanguage or "en") -- 772
		else -- 772
			____isVirtualDoc_6 = nil -- 773
		end -- 773
		local virtualDocPath = ____isVirtualDoc_6 -- 771
		if isVirtualDoc and virtualDocPath == nil then -- 771
			return ____awaiter_resolve(nil, {success = false, message = "virtual document not found or outside its documentation scope"}) -- 771
		end -- 771
		local resolvedPath = virtualDocPath or ____exports.resolveWorkspaceSearchPath(req.workDir, requestedPath) -- 777
		if resolvedPath == nil then -- 777
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 777
		end -- 777
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 781
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 782
		if searchRoot == "" then -- 782
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 782
		end -- 782
		if req.pattern == "" or __TS__StringTrim(req.pattern) == "" then -- 782
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 782
		end -- 782
		local patterns = ____exports.splitSearchPatterns(req.pattern) -- 789
		if #patterns == 0 then -- 789
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 789
		end -- 789
		return ____awaiter_resolve( -- 789
			nil, -- 789
			__TS__New( -- 793
				__TS__Promise, -- 793
				function(____, resolve) -- 793
					Director.systemScheduler:schedule(once(function() -- 794
						do -- 794
							local function ____catch(e) -- 794
								resolve( -- 838
									nil, -- 838
									{ -- 838
										success = false, -- 838
										message = tostring(e) -- 838
									} -- 838
								) -- 838
							end -- 838
							local ____try, ____hasReturned = pcall(function() -- 838
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ____exports.ensureSafeSearchGlobs(req.globs or ({"**"})) -- 796
								local allResults = {} -- 799
								do -- 799
									local i = 0 -- 800
									while i < #patterns do -- 800
										local ____Content_11 = Content -- 801
										local ____Content_searchFilesAsync_12 = Content.searchFilesAsync -- 801
										local ____patterns_index_10 = patterns[i + 1] -- 806
										local ____req_useRegex_7 = req.useRegex -- 807
										if ____req_useRegex_7 == nil then -- 807
											____req_useRegex_7 = false -- 807
										end -- 807
										local ____req_caseSensitive_8 = req.caseSensitive -- 808
										if ____req_caseSensitive_8 == nil then -- 808
											____req_caseSensitive_8 = false -- 808
										end -- 808
										local ____req_includeContent_9 = req.includeContent -- 809
										if ____req_includeContent_9 == nil then -- 809
											____req_includeContent_9 = true -- 809
										end -- 809
										allResults[#allResults + 1] = ____Content_searchFilesAsync_12( -- 801
											____Content_11, -- 801
											searchRoot, -- 802
											____exports.codeExtensions, -- 802
											extensionLevels, -- 804
											searchGlobs, -- 805
											____patterns_index_10, -- 806
											____req_useRegex_7, -- 807
											____req_caseSensitive_8, -- 808
											____req_includeContent_9, -- 809
											req.contentWindow or 120 -- 810
										) -- 810
										i = i + 1 -- 800
									end -- 800
								end -- 800
								local results = mergeSearchFileResultsUnique(allResults) -- 813
								local totalResults = #results -- 814
								local limit = math.max( -- 815
									1, -- 815
									math.floor(req.limit or 20) -- 815
								) -- 815
								local offset = math.max( -- 816
									0, -- 816
									math.floor(req.offset or 0) -- 816
								) -- 816
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 817
								local nextOffset = offset + #paged -- 818
								local hasMore = nextOffset < totalResults -- 819
								local truncated = offset > 0 or hasMore -- 820
								local relativeResults = virtualDocPath and __TS__ArrayMap( -- 821
									paged, -- 822
									function(____, row) return __TS__ObjectAssign({}, row, {file = requestedPath}) end -- 822
								) or toWorkspaceRelativeSearchResults(req.workDir, paged) -- 822
								local groupByFile = req.groupByFile == true -- 824
								resolve( -- 825
									nil, -- 825
									{ -- 825
										success = true, -- 826
										results = relativeResults, -- 827
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 828
										totalResults = totalResults, -- 829
										truncated = truncated, -- 830
										limit = limit, -- 831
										offset = offset, -- 832
										nextOffset = nextOffset, -- 833
										hasMore = hasMore, -- 834
										groupByFile = groupByFile -- 835
									} -- 835
								) -- 835
							end) -- 835
							if not ____try then -- 835
								____catch(____hasReturned) -- 835
							end -- 835
						end -- 835
					end)) -- 794
				end -- 793
			) -- 793
		) -- 793
	end) -- 793
end -- 755
return ____exports -- 755