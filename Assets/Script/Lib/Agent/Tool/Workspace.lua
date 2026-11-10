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
function getDoraDocDefinitionRoot(docLanguage) -- 111
	local zhDir = Path( -- 112
		Content.assetPath, -- 112
		"Script", -- 112
		"Lib", -- 112
		"Dora", -- 112
		"zh-Hans" -- 112
	) -- 112
	local enDir = Path( -- 113
		Content.assetPath, -- 113
		"Script", -- 113
		"Lib", -- 113
		"Dora", -- 113
		"en" -- 113
	) -- 113
	return docLanguage == "zh" and zhDir or enDir -- 114
end -- 114
function getDoraTutorialDocRoot(docLanguage) -- 117
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 118
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 119
	return docLanguage == "zh" and zhDir or enDir -- 120
end -- 120
function ____exports.getDoraDocResultBaseRoot(docType, docLanguage) -- 173
	if docType == "godot-api" then -- 173
		return Path(Content.assetPath, "Doc", "godot-api") -- 174
	end -- 174
	if docType == "dora-tutorial" then -- 174
		return getDoraTutorialDocRoot(docLanguage) -- 176
	end -- 176
	return getDoraDocDefinitionRoot(docLanguage) -- 178
end -- 173
function isEngineLogFilePath(path) -- 450
	return path == ENGINE_LOG_VIRTUAL_FILE -- 451
end -- 451
function getEngineLogText() -- 502
	local folder = Path(Content.writablePath, ____exports.ENGINE_LOG_DOWNLOAD_DIR) -- 503
	if not Content:exist(folder) then -- 503
		Content:mkdir(folder) -- 505
	end -- 505
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 507
	if not App:saveLog(logPath) then -- 507
		return nil -- 509
	end -- 509
	return Content:load(logPath) -- 511
end -- 511
function ____exports.ensureSafeSearchGlobs(globs) -- 652
	local result = {} -- 653
	do -- 653
		local i = 0 -- 654
		while i < #globs do -- 654
			result[#result + 1] = globs[i + 1] -- 655
			i = i + 1 -- 654
		end -- 654
	end -- 654
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 657
	do -- 657
		local i = 0 -- 658
		while i < #requiredExcludes do -- 658
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 658
				result[#result + 1] = requiredExcludes[i + 1] -- 660
			end -- 660
			i = i + 1 -- 658
		end -- 658
	end -- 658
	return result -- 663
end -- 652
local function getDoraDocDefinitionExtsByCodeLanguage(programmingLanguage) -- 123
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 123
		return {"ts"} -- 125
	end -- 125
	return {"tl"} -- 127
end -- 123
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 130
	repeat -- 130
		local ____switch7 = programmingLanguage -- 130
		local ____cond7 = ____switch7 == "teal" -- 130
		if ____cond7 then -- 130
			return "tl" -- 132
		end -- 132
		____cond7 = ____cond7 or ____switch7 == "tl" -- 132
		if ____cond7 then -- 132
			return "tl" -- 133
		end -- 133
		do -- 133
			return programmingLanguage -- 134
		end -- 134
	until true -- 134
end -- 130
function ____exports.getDoraDocSearchTarget(docType, docLanguage, programmingLanguage) -- 138
	if docType == "godot-api" then -- 138
		return { -- 143
			root = ____exports.getDoraDocResultBaseRoot(docType, docLanguage), -- 143
			exts = {"md"}, -- 143
			globs = {"**/*.md"} -- 143
		} -- 143
	end -- 143
	if docType == "dora-tutorial" then -- 143
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 145
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 146
		return { -- 147
			root = Path(tutorialRoot, langDir), -- 148
			exts = {"md"}, -- 149
			globs = {"**/*.md"} -- 150
		} -- 150
	end -- 150
	local exts = getDoraDocDefinitionExtsByCodeLanguage(programmingLanguage) -- 153
	if docType == "love-api" or docType == "tic80-api" then -- 153
		local name = docType == "love-api" and "love" or "tic80" -- 155
		return { -- 156
			root = getDoraDocDefinitionRoot(docLanguage), -- 157
			exts = exts, -- 158
			globs = __TS__ArrayMap( -- 159
				exts, -- 159
				function(____, ext) return (name .. ".d.") .. ext end -- 159
			) -- 159
		} -- 159
	end -- 159
	return { -- 162
		root = getDoraDocDefinitionRoot(docLanguage), -- 163
		exts = exts, -- 164
		globs = __TS__ArrayFlatMap( -- 165
			exts, -- 165
			function(____, ext) return {"**/*." .. ext, "!**/love.d." .. ext, "!**/tic80.d." .. ext} end -- 165
		) -- 165
	} -- 165
end -- 138
function ____exports.isDoraDocFileInScope(docType, file) -- 181
	local normalized = string.lower(table.concat( -- 182
		__TS__StringSplit(file, "\\"), -- 182
		"/" -- 182
	)) -- 182
	local segments = __TS__StringSplit(normalized, "/") -- 183
	local baseName = segments[#segments] or normalized -- 184
	if docType == "godot-api" then -- 184
		return normalized == "readme.md" or #segments == 2 and segments[1] == "classes" and __TS__StringEndsWith(normalized, ".md") -- 185
	end -- 185
	if docType == "dora-tutorial" then -- 185
		return __TS__StringEndsWith(normalized, ".md") -- 186
	end -- 186
	if docType == "love-api" then -- 186
		return normalized == "love.d.ts" or normalized == "love.d.tl" -- 187
	end -- 187
	if docType == "tic80-api" then -- 187
		return normalized == "tic80.d.ts" or normalized == "tic80.d.tl" -- 188
	end -- 188
	return (__TS__StringEndsWith(normalized, ".ts") or __TS__StringEndsWith(normalized, ".tl")) and baseName ~= "love.d.ts" and baseName ~= "love.d.tl" and baseName ~= "tic80.d.ts" and baseName ~= "tic80.d.tl" -- 189
end -- 181
____exports.AGENT_DORA_DOC_PREFIX = "@dora-doc/" -- 196
____exports.ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 198
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 199
ENGINE_LOG_VIRTUAL_FILE = "@dora_full_logs.txt" -- 200
local function isAbsolutePathLike(path) -- 202
	if Content:isAbsolutePath(path) then -- 202
		return true -- 203
	end -- 203
	if __TS__StringStartsWith(path, "/") or __TS__StringStartsWith(path, "\\") then -- 203
		return true -- 204
	end -- 204
	local drivePath = string.match(path, "^%a:[/\\]") -- 205
	return drivePath ~= nil -- 206
end -- 202
function ____exports.isValidWorkspacePath(path) -- 209
	if path == "" then -- 209
		return false -- 210
	end -- 210
	if isAbsolutePathLike(path) then -- 210
		return false -- 211
	end -- 211
	local parts = __TS__StringSplit( -- 212
		table.concat( -- 212
			__TS__StringSplit(path, "\\"), -- 212
			"/" -- 212
		), -- 212
		"/" -- 212
	) -- 212
	if __TS__ArrayIndexOf(parts, "..") >= 0 then -- 212
		return false -- 213
	end -- 213
	return true -- 214
end -- 209
function ____exports.isValidWorkDir(workDir) -- 217
	if workDir == "" then -- 217
		return false -- 218
	end -- 218
	if not Content:isAbsolutePath(workDir) then -- 218
		return false -- 219
	end -- 219
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 219
		return false -- 220
	end -- 220
	return true -- 221
end -- 217
local function isValidSearchPath(path) -- 224
	if path == "" then -- 224
		return true -- 225
	end -- 225
	if isAbsolutePathLike(path) then -- 225
		return false -- 226
	end -- 226
	local parts = __TS__StringSplit( -- 227
		table.concat( -- 227
			__TS__StringSplit(path, "\\"), -- 227
			"/" -- 227
		), -- 227
		"/" -- 227
	) -- 227
	if __TS__ArrayIndexOf(parts, "..") >= 0 then -- 227
		return false -- 228
	end -- 228
	return true -- 229
end -- 224
function ____exports.resolveWorkspaceFilePath(workDir, path) -- 232
	if not ____exports.isValidWorkDir(workDir) then -- 232
		return nil -- 233
	end -- 233
	if not ____exports.isValidWorkspacePath(path) then -- 233
		return nil -- 234
	end -- 234
	return Path(workDir, path) -- 235
end -- 232
function ____exports.resolveWorkspaceSearchPath(workDir, path) -- 238
	if not ____exports.isValidWorkDir(workDir) then -- 238
		return nil -- 239
	end -- 239
	if not isValidSearchPath(path) then -- 239
		return nil -- 240
	end -- 240
	return path == "" and workDir or Path(workDir, path) -- 241
end -- 238
function ____exports.toWorkspaceRelativePath(workDir, path) -- 244
	if path == "" then -- 244
		return path -- 245
	end -- 245
	if not Content:isAbsolutePath(path) then -- 245
		return path -- 246
	end -- 246
	return Path:getRelative(path, workDir) -- 247
end -- 244
local function toWorkspaceRelativeFileList(workDir, files) -- 250
	return __TS__ArrayMap( -- 251
		files, -- 251
		function(____, file) return ____exports.toWorkspaceRelativePath(workDir, file) end -- 251
	) -- 251
end -- 250
local function toWorkspaceRelativeSearchResults(workDir, results) -- 254
	local mapped = {} -- 255
	do -- 255
		local i = 0 -- 256
		while i < #results do -- 256
			local row = results[i + 1] -- 257
			local clone = __TS__ObjectAssign({}, row) -- 258
			clone.file = ____exports.toWorkspaceRelativePath(workDir, clone.file) -- 259
			mapped[#mapped + 1] = clone -- 260
			i = i + 1 -- 256
		end -- 256
	end -- 256
	return mapped -- 262
end -- 254
function ____exports.resolveWorkspaceDirectoryPath(workDir, path) -- 265
	local relative = __TS__StringTrim(path or "") -- 266
	if relative == "" then -- 266
		return {success = true, path = workDir, relative = "."} -- 268
	end -- 268
	if not ____exports.isValidWorkDir(workDir) or not ____exports.isValidWorkspacePath(relative) then -- 268
		return {success = false, message = "invalid cwd path"} -- 271
	end -- 271
	local resolved = Path(workDir, relative) -- 273
	if not Content:exist(resolved) then -- 273
		return {success = false, message = "cwd does not exist"} -- 275
	end -- 275
	if not Content:isdir(resolved) then -- 275
		return {success = false, message = "cwd is not a directory"} -- 278
	end -- 278
	return {success = true, path = resolved, relative = relative} -- 280
end -- 265
local AGENT_SKILL_PREFIX = "@agent-skill/" -- 283
function ____exports.toDocRelativePath(baseRoot, path, docType) -- 285
	if path == "" then -- 285
		return path -- 286
	end -- 286
	local relative = Content:isAbsolutePath(path) and Path:getRelative(path, baseRoot) or path -- 287
	return ((____exports.AGENT_DORA_DOC_PREFIX .. docType) .. "/") .. relative -- 288
end -- 285
local function resolveAgentDoraDocFilePath(path, docLanguage) -- 291
	if not docLanguage then -- 291
		return nil -- 292
	end -- 292
	local relative = path -- 293
	local docType = "dora-tutorial" -- 294
	if __TS__StringStartsWith(path, ____exports.AGENT_DORA_DOC_PREFIX) then -- 294
		local namespaced = __TS__StringSlice(path, #____exports.AGENT_DORA_DOC_PREFIX) -- 296
		if __TS__StringStartsWith(namespaced, "dora-api/") then -- 296
			docType = "dora-api" -- 298
			relative = string.sub(namespaced, 10) -- 299
		elseif __TS__StringStartsWith(namespaced, "godot-api/") then -- 299
			docType = "godot-api" -- 301
			relative = string.sub(namespaced, 11) -- 302
		elseif __TS__StringStartsWith(namespaced, "love-api/") then -- 302
			docType = "love-api" -- 304
			relative = string.sub(namespaced, 10) -- 305
		elseif __TS__StringStartsWith(namespaced, "tic80-api/") then -- 305
			docType = "tic80-api" -- 307
			relative = string.sub(namespaced, 11) -- 308
		elseif __TS__StringStartsWith(namespaced, "dora-tutorial/") then -- 308
			docType = "dora-tutorial" -- 310
			relative = string.sub(namespaced, 15) -- 311
		elseif __TS__StringStartsWith(namespaced, "api/") then -- 311
			docType = "dora-api" -- 313
			relative = string.sub(namespaced, 5) -- 314
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 314
			docType = "dora-tutorial" -- 316
			relative = string.sub(namespaced, 10) -- 317
		else -- 317
			return nil -- 319
		end -- 319
	end -- 319
	if not ____exports.isValidWorkspacePath(relative) then -- 319
		return nil -- 322
	end -- 322
	if not ____exports.isDoraDocFileInScope(docType, relative) then -- 322
		return nil -- 323
	end -- 323
	local root = ____exports.getDoraDocResultBaseRoot(docType, docLanguage) -- 324
	local candidate = Path(root, relative) -- 325
	local checked = Path:getRelative(candidate, root) -- 326
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 326
		return nil -- 327
	end -- 327
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 327
		return candidate -- 329
	end -- 329
	return nil -- 331
end -- 291
local function resolveAgentSkillFilePath(workDir, path) -- 334
	if not __TS__StringStartsWith(path, AGENT_SKILL_PREFIX) then -- 334
		return nil -- 335
	end -- 335
	local namespaced = table.concat( -- 336
		__TS__StringSplit( -- 336
			__TS__StringSlice(path, #AGENT_SKILL_PREFIX), -- 336
			"\\" -- 336
		), -- 336
		"/" -- 336
	) -- 336
	local root = "" -- 337
	local relative = "" -- 338
	if __TS__StringStartsWith(namespaced, "builtin/") then -- 338
		root = Path(Content.assetPath, "Doc", "skills") -- 340
		relative = __TS__StringSlice(namespaced, #"builtin/") -- 341
	elseif __TS__StringStartsWith(namespaced, "user/") then -- 341
		root = Path(Content.writablePath, ".agent", "skills") -- 343
		relative = __TS__StringSlice(namespaced, #"user/") -- 344
	elseif __TS__StringStartsWith(namespaced, "project/") then -- 344
		root = Path(workDir, ".agent", "skills") -- 346
		relative = __TS__StringSlice(namespaced, #"project/") -- 347
	else -- 347
		return nil -- 349
	end -- 349
	if not ____exports.isValidWorkspacePath(relative) or relative == "." then -- 349
		return nil -- 351
	end -- 351
	local candidate = Path(root, relative) -- 352
	local checked = Path:getRelative(candidate, root) -- 353
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 353
		return nil -- 354
	end -- 354
	if not Content:exist(candidate) or Content:isdir(candidate) then -- 354
		return nil -- 355
	end -- 355
	return candidate -- 356
end -- 334
function ____exports.resolveAgentContentVirtualPath(workDir, path, docLanguage) -- 360
	if docLanguage == nil then -- 360
		docLanguage = "en" -- 360
	end -- 360
	if __TS__StringStartsWith(path, ____exports.AGENT_DORA_DOC_PREFIX) then -- 360
		return resolveAgentDoraDocFilePath(path, docLanguage) -- 362
	end -- 362
	if __TS__StringStartsWith(path, AGENT_SKILL_PREFIX) then -- 362
		return resolveAgentSkillFilePath(workDir, path) -- 364
	end -- 364
	if isEngineLogFilePath(path) then -- 364
		if getEngineLogText() == nil then -- 364
			return nil -- 366
		end -- 366
		return Path(Content.writablePath, ____exports.ENGINE_LOG_DOWNLOAD_DIR, ENGINE_LOG_FILE) -- 367
	end -- 367
	return nil -- 369
end -- 360
function ____exports.isAgentContentVirtualPath(path) -- 372
	return __TS__StringStartsWith(path, ____exports.AGENT_DORA_DOC_PREFIX) or __TS__StringStartsWith(path, AGENT_SKILL_PREFIX) or isEngineLogFilePath(path) -- 373
end -- 372
function ____exports.ensureDirPath(dir) -- 376
	if dir == "." or dir == "" then -- 376
		return true -- 377
	end -- 377
	if Content:exist(dir) then -- 377
		return Content:isdir(dir) -- 378
	end -- 378
	local parent = Path:getPath(dir) -- 379
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 379
		if not ____exports.ensureDirPath(parent) then -- 379
			return false -- 381
		end -- 381
	end -- 381
	return Content:mkdir(dir) -- 383
end -- 376
function ____exports.ensureDirForFile(path) -- 386
	local dir = Path:getPath(path) -- 387
	return ____exports.ensureDirPath(dir) -- 388
end -- 386
function ____exports.getFileState(path) -- 391
	local exists = Content:exist(path) -- 392
	if not exists then -- 392
		return {exists = false, content = "", bytes = 0} -- 394
	end -- 394
	if Content:isdir(path) then -- 394
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 401
	end -- 401
	local content = Content:load(path) -- 408
	if type(content) ~= "string" then -- 408
		return {exists = true, content = "", bytes = 0} -- 410
	end -- 410
	return {exists = true, content = content, bytes = #content} -- 416
end -- 391
function ____exports.inspectReadableFile(path) -- 423
	do -- 423
		local function ____catch(e) -- 423
			Log( -- 445
				"Warn", -- 445
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 445
			) -- 445
			return true, {success = true} -- 446
		end -- 446
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 446
			local size, isBinary = Content:getAttr(path) -- 425
			if size == nil then -- 425
				return true, {success = false, message = "failed to read file"} -- 427
			end -- 427
			if isBinary then -- 427
				return true, { -- 433
					success = false, -- 434
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 435
					size = type(size) == "number" and size or nil, -- 436
					isBinary = true -- 437
				} -- 437
			end -- 437
			return true, { -- 440
				success = true, -- 441
				size = type(size) == "number" and size or nil -- 442
			} -- 442
		end) -- 442
		if not ____try then -- 442
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 442
		end -- 442
		if ____hasReturned then -- 442
			return ____returnValue -- 424
		end -- 424
	end -- 424
end -- 423
local function readEngineLogFile(path) -- 454
	if not isEngineLogFilePath(path) then -- 454
		return nil -- 455
	end -- 455
	local content = getEngineLogText() -- 456
	if content == nil then -- 456
		return {success = false, message = "failed to read engine logs"} -- 458
	end -- 458
	return {success = true, content = content, size = #content} -- 460
end -- 454
local function readWorkspaceFile(workDir, path, docLanguage) -- 463
	local engineLog = readEngineLogFile(path) -- 464
	if engineLog then -- 464
		return engineLog -- 465
	end -- 465
	local fullPath = ____exports.resolveWorkspaceFilePath(workDir, path) -- 466
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 466
		local attr = ____exports.inspectReadableFile(fullPath) -- 468
		if not attr.success then -- 468
			return attr -- 469
		end -- 469
		return { -- 470
			success = true, -- 470
			content = Content:load(fullPath), -- 470
			size = attr.size -- 470
		} -- 470
	end -- 470
	local docPath = resolveAgentDoraDocFilePath(path, docLanguage) -- 472
	if docPath then -- 472
		local attr = ____exports.inspectReadableFile(docPath) -- 474
		if not attr.success then -- 474
			return attr -- 475
		end -- 475
		return { -- 476
			success = true, -- 476
			content = Content:load(docPath), -- 476
			size = attr.size -- 476
		} -- 476
	end -- 476
	local skillPath = resolveAgentSkillFilePath(workDir, path) -- 478
	if skillPath then -- 478
		local attr = ____exports.inspectReadableFile(skillPath) -- 480
		if not attr.success then -- 480
			return attr -- 481
		end -- 481
		return { -- 482
			success = true, -- 482
			content = Content:load(skillPath), -- 482
			size = attr.size -- 482
		} -- 482
	end -- 482
	if not fullPath then -- 482
		return {success = false, message = "invalid path or workDir"} -- 484
	end -- 484
	return {success = false, message = "file not found"} -- 485
end -- 463
function ____exports.readFileRaw(workDir, path, docLanguage) -- 488
	return readWorkspaceFile(workDir, path, docLanguage) -- 489
end -- 488
function ____exports.inspectWorkspaceTextTarget(workDir, path) -- 492
	local fullPath = ____exports.resolveWorkspaceFilePath(workDir, path) -- 493
	if not fullPath then -- 493
		return {success = false, message = "invalid path or workDir"} -- 494
	end -- 494
	if not Content:exist(fullPath) then -- 494
		return {success = true, exists = false, content = ""} -- 495
	end -- 495
	if Content:isdir(fullPath) then -- 495
		return {success = false, message = "target is a directory"} -- 496
	end -- 496
	local attr = ____exports.inspectReadableFile(fullPath) -- 497
	if not attr.success then -- 497
		return {success = false, message = attr.message} -- 498
	end -- 498
	return { -- 499
		success = true, -- 499
		exists = true, -- 499
		content = Content:load(fullPath) -- 499
	} -- 499
end -- 492
function ____exports.getLogs(req) -- 514
	local text = getEngineLogText() -- 515
	if text == nil then -- 515
		return {success = false, message = "failed to read engine logs"} -- 517
	end -- 517
	local tailLines = math.max( -- 519
		1, -- 519
		math.floor(req and req.tailLines or 200) -- 519
	) -- 519
	local allLines = __TS__StringSplit(text, "\n") -- 520
	local logs = __TS__ArraySlice( -- 521
		allLines, -- 521
		math.max(0, #allLines - tailLines) -- 521
	) -- 521
	return req and req.joinText and ({ -- 522
		success = true, -- 522
		logs = logs, -- 522
		text = table.concat(logs, "\n") -- 522
	}) or ({success = true, logs = logs}) -- 522
end -- 514
function ____exports.listFiles(req) -- 525
	local root = req.path or "" -- 531
	local searchRoot = ____exports.resolveWorkspaceSearchPath(req.workDir, root) -- 532
	if searchRoot == nil then -- 532
		return {success = false, message = "invalid path or workDir"} -- 534
	end -- 534
	do -- 534
		local function ____catch(e) -- 534
			return true, { -- 552
				success = false, -- 552
				message = tostring(e) -- 552
			} -- 552
		end -- 552
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 552
			local userGlobs = req.globs ~= nil and #req.globs > 0 and req.globs or ({"**"}) -- 537
			local globs = ____exports.ensureSafeSearchGlobs(userGlobs) -- 538
			local files = Content:glob(searchRoot, globs, req.preferSourceVariants == false and ({}) or extensionLevels) -- 539
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 540
			local totalEntries = #files -- 541
			local maxEntries = math.max( -- 542
				1, -- 542
				math.floor(req.maxEntries or 200) -- 542
			) -- 542
			local truncated = totalEntries > maxEntries -- 543
			return true, { -- 544
				success = true, -- 545
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 546
				totalEntries = totalEntries, -- 547
				truncated = truncated, -- 548
				maxEntries = maxEntries -- 549
			} -- 549
		end) -- 549
		if not ____try then -- 549
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 549
		end -- 549
		if ____hasReturned then -- 549
			return ____returnValue -- 536
		end -- 536
	end -- 536
end -- 525
local function formatReadSlice(content, startLine, endLine) -- 556
	local lines = __TS__StringSplit(content, "\n") -- 561
	local totalLines = #lines -- 562
	if totalLines == 0 then -- 562
		return { -- 564
			success = true, -- 565
			content = "", -- 566
			totalLines = 0, -- 567
			startLine = 1, -- 568
			endLine = 0, -- 569
			truncated = false -- 570
		} -- 570
	end -- 570
	local rawStart = math.floor(startLine) -- 573
	local ____temp_4 -- 574
	if endLine == nil then -- 574
		____temp_4 = nil -- 574
	else -- 574
		____temp_4 = math.floor(endLine) -- 574
	end -- 574
	local rawEnd = ____temp_4 -- 574
	if rawStart == 0 then -- 574
		return {success = false, message = "startLine cannot be 0"} -- 576
	end -- 576
	if rawEnd == 0 then -- 576
		return {success = false, message = "endLine cannot be 0"} -- 579
	end -- 579
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 581
	if start > totalLines then -- 581
		return { -- 585
			success = false, -- 585
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 585
		} -- 585
	end -- 585
	local ____end = math.min( -- 587
		totalLines, -- 588
		rawEnd == nil and start + AgentConfig.AGENT_LIMITS.readFileDefaultLimit - 1 or (rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1)) -- 589
	) -- 589
	if ____end < start then -- 589
		return { -- 596
			success = false, -- 597
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 598
		} -- 598
	end -- 598
	local slice = {} -- 601
	do -- 601
		local i = start -- 602
		while i <= ____end do -- 602
			slice[#slice + 1] = lines[i] -- 603
			i = i + 1 -- 602
		end -- 602
	end -- 602
	local truncated = start > 1 or ____end < totalLines -- 605
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 606
	local body = table.concat(slice, "\n") -- 611
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 612
	return { -- 613
		success = true, -- 614
		content = output, -- 615
		totalLines = totalLines, -- 616
		startLine = start, -- 617
		endLine = ____end, -- 618
		truncated = truncated -- 619
	} -- 619
end -- 556
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 623
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 630
	if not fallback.success or fallback.content == nil then -- 630
		return fallback -- 631
	end -- 631
	local resolvedStartLine = startLine or 1 -- 632
	return formatReadSlice(fallback.content, resolvedStartLine, endLine) -- 633
end -- 623
____exports.codeExtensions = { -- 640
	".lua", -- 640
	".tl", -- 640
	".yue", -- 640
	".ts", -- 640
	".tsx", -- 640
	".xml", -- 640
	".md", -- 640
	".yarn", -- 640
	".wa", -- 640
	".mod", -- 640
	".gd", -- 640
	".tscn", -- 640
	".tres", -- 640
	".gdshader", -- 640
	".gdshaderinc", -- 640
	".godot" -- 640
} -- 640
extensionLevels = { -- 641
	vs = 2, -- 642
	bl = 2, -- 643
	ts = 1, -- 644
	tsx = 1, -- 645
	tl = 1, -- 646
	yue = 1, -- 647
	xml = 1, -- 648
	lua = 0 -- 649
} -- 649
function ____exports.splitSearchPatterns(pattern) -- 666
	local trimmed = __TS__StringTrim(pattern or "") -- 667
	if trimmed == "" then -- 667
		return {} -- 668
	end -- 668
	local out = {} -- 669
	local seen = __TS__New(Set) -- 670
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 671
		local p = __TS__StringTrim(tostring(p0)) -- 672
		if p ~= "" and not seen:has(p) then -- 672
			seen:add(p) -- 674
			out[#out + 1] = p -- 675
		end -- 675
	end -- 675
	return out -- 678
end -- 666
function ____exports.splitWhitespaceSearchPatterns(pattern) -- 681
	local out = {} -- 682
	local seen = __TS__New(Set) -- 683
	for p0 in string.gmatch(pattern, "(%S+)") do -- 684
		local p = __TS__StringTrim(tostring(p0)) -- 685
		local key = string.lower(p) -- 686
		if p ~= "" and not seen:has(key) then -- 686
			seen:add(key) -- 688
			out[#out + 1] = p -- 689
		end -- 689
	end -- 689
	return out -- 692
end -- 681
local function mergeSearchFileResultsUnique(resultsList) -- 695
	local merged = {} -- 696
	local seen = __TS__New(Set) -- 697
	do -- 697
		local i = 0 -- 698
		while i < #resultsList do -- 698
			local list = resultsList[i + 1] -- 699
			do -- 699
				local j = 0 -- 700
				while j < #list do -- 700
					do -- 700
						local row = list[j + 1] -- 701
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 702
						if seen:has(key) then -- 702
							goto __continue158 -- 703
						end -- 703
						seen:add(key) -- 704
						merged[#merged + 1] = list[j + 1] -- 705
					end -- 705
					::__continue158:: -- 705
					j = j + 1 -- 700
				end -- 700
			end -- 700
			i = i + 1 -- 698
		end -- 698
	end -- 698
	return merged -- 708
end -- 695
local function buildGroupedSearchResults(results) -- 711
	local order = {} -- 716
	local grouped = __TS__New(Map) -- 717
	do -- 717
		local i = 0 -- 722
		while i < #results do -- 722
			local row = results[i + 1] -- 723
			local file = row.file -- 724
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 725
			local bucket = grouped:get(key) -- 726
			if not bucket then -- 726
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 728
				grouped:set(key, bucket) -- 729
				order[#order + 1] = key -- 730
			end -- 730
			bucket.totalMatches = bucket.totalMatches + 1 -- 732
			local ____bucket_matches_5 = bucket.matches -- 732
			____bucket_matches_5[#____bucket_matches_5 + 1] = results[i + 1] -- 733
			i = i + 1 -- 722
		end -- 722
	end -- 722
	local out = {} -- 735
	do -- 735
		local i = 0 -- 740
		while i < #order do -- 740
			local bucket = grouped:get(order[i + 1]) -- 741
			if bucket then -- 741
				out[#out + 1] = bucket -- 742
			end -- 742
			i = i + 1 -- 740
		end -- 740
	end -- 740
	return out -- 744
end -- 711
function ____exports.searchFiles(req) -- 747
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 747
		local requestedPath = __TS__StringTrim(req.path or "") -- 761
		local isVirtualDoc = __TS__StringStartsWith(requestedPath, ____exports.AGENT_DORA_DOC_PREFIX) -- 762
		local ____isVirtualDoc_6 -- 763
		if isVirtualDoc then -- 763
			____isVirtualDoc_6 = resolveAgentDoraDocFilePath(requestedPath, req.docLanguage or "en") -- 764
		else -- 764
			____isVirtualDoc_6 = nil -- 765
		end -- 765
		local virtualDocPath = ____isVirtualDoc_6 -- 763
		if isVirtualDoc and virtualDocPath == nil then -- 763
			return ____awaiter_resolve(nil, {success = false, message = "virtual document not found or outside its documentation scope"}) -- 763
		end -- 763
		local resolvedPath = virtualDocPath or ____exports.resolveWorkspaceSearchPath(req.workDir, requestedPath) -- 769
		if resolvedPath == nil then -- 769
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 769
		end -- 769
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 773
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 774
		if searchRoot == "" then -- 774
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 774
		end -- 774
		if req.pattern == "" or __TS__StringTrim(req.pattern) == "" then -- 774
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 774
		end -- 774
		local patterns = ____exports.splitSearchPatterns(req.pattern) -- 781
		if #patterns == 0 then -- 781
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 781
		end -- 781
		return ____awaiter_resolve( -- 781
			nil, -- 781
			__TS__New( -- 785
				__TS__Promise, -- 785
				function(____, resolve) -- 785
					Director.systemScheduler:schedule(once(function() -- 786
						do -- 786
							local function ____catch(e) -- 786
								resolve( -- 830
									nil, -- 830
									{ -- 830
										success = false, -- 830
										message = tostring(e) -- 830
									} -- 830
								) -- 830
							end -- 830
							local ____try, ____hasReturned = pcall(function() -- 830
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ____exports.ensureSafeSearchGlobs(req.globs or ({"**"})) -- 788
								local allResults = {} -- 791
								do -- 791
									local i = 0 -- 792
									while i < #patterns do -- 792
										local ____Content_11 = Content -- 793
										local ____Content_searchFilesAsync_12 = Content.searchFilesAsync -- 793
										local ____patterns_index_10 = patterns[i + 1] -- 798
										local ____req_useRegex_7 = req.useRegex -- 799
										if ____req_useRegex_7 == nil then -- 799
											____req_useRegex_7 = false -- 799
										end -- 799
										local ____req_caseSensitive_8 = req.caseSensitive -- 800
										if ____req_caseSensitive_8 == nil then -- 800
											____req_caseSensitive_8 = false -- 800
										end -- 800
										local ____req_includeContent_9 = req.includeContent -- 801
										if ____req_includeContent_9 == nil then -- 801
											____req_includeContent_9 = true -- 801
										end -- 801
										allResults[#allResults + 1] = ____Content_searchFilesAsync_12( -- 793
											____Content_11, -- 793
											searchRoot, -- 794
											____exports.codeExtensions, -- 794
											extensionLevels, -- 796
											searchGlobs, -- 797
											____patterns_index_10, -- 798
											____req_useRegex_7, -- 799
											____req_caseSensitive_8, -- 800
											____req_includeContent_9, -- 801
											req.contentWindow or 120 -- 802
										) -- 802
										i = i + 1 -- 792
									end -- 792
								end -- 792
								local results = mergeSearchFileResultsUnique(allResults) -- 805
								local totalResults = #results -- 806
								local limit = math.max( -- 807
									1, -- 807
									math.floor(req.limit or 20) -- 807
								) -- 807
								local offset = math.max( -- 808
									0, -- 808
									math.floor(req.offset or 0) -- 808
								) -- 808
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 809
								local nextOffset = offset + #paged -- 810
								local hasMore = nextOffset < totalResults -- 811
								local truncated = offset > 0 or hasMore -- 812
								local relativeResults = virtualDocPath and __TS__ArrayMap( -- 813
									paged, -- 814
									function(____, row) return __TS__ObjectAssign({}, row, {file = requestedPath}) end -- 814
								) or toWorkspaceRelativeSearchResults(req.workDir, paged) -- 814
								local groupByFile = req.groupByFile == true -- 816
								resolve( -- 817
									nil, -- 817
									{ -- 817
										success = true, -- 818
										results = relativeResults, -- 819
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 820
										totalResults = totalResults, -- 821
										truncated = truncated, -- 822
										limit = limit, -- 823
										offset = offset, -- 824
										nextOffset = nextOffset, -- 825
										hasMore = hasMore, -- 826
										groupByFile = groupByFile -- 827
									} -- 827
								) -- 827
							end) -- 827
							if not ____try then -- 827
								____catch(____hasReturned) -- 827
							end -- 827
						end -- 827
					end)) -- 786
				end -- 785
			) -- 785
		) -- 785
	end) -- 785
end -- 747
return ____exports -- 747