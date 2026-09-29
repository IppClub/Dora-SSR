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
local getEngineLogText, ENGINE_LOG_FILE, extensionLevels -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local App = ____Dora.App -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local ____Utils = require("Agent.Utils") -- 5
local Log = ____Utils.Log -- 5
function getEngineLogText() -- 478
	local folder = Path(Content.writablePath, ____exports.ENGINE_LOG_DOWNLOAD_DIR) -- 479
	if not Content:exist(folder) then -- 479
		Content:mkdir(folder) -- 481
	end -- 481
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 483
	if not App:saveLog(logPath) then -- 483
		return nil -- 485
	end -- 485
	return Content:load(logPath) -- 487
end -- 487
function ____exports.ensureSafeSearchGlobs(globs) -- 627
	local result = {} -- 628
	do -- 628
		local i = 0 -- 629
		while i < #globs do -- 629
			result[#result + 1] = globs[i + 1] -- 630
			i = i + 1 -- 629
		end -- 629
	end -- 629
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 632
	do -- 632
		local i = 0 -- 633
		while i < #requiredExcludes do -- 633
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 633
				result[#result + 1] = requiredExcludes[i + 1] -- 635
			end -- 635
			i = i + 1 -- 633
		end -- 633
	end -- 633
	return result -- 638
end -- 627
local function getDoraDocDefinitionRoot(docLanguage) -- 110
	local zhDir = Path( -- 111
		Content.assetPath, -- 111
		"Script", -- 111
		"Lib", -- 111
		"Dora", -- 111
		"zh-Hans" -- 111
	) -- 111
	local enDir = Path( -- 112
		Content.assetPath, -- 112
		"Script", -- 112
		"Lib", -- 112
		"Dora", -- 112
		"en" -- 112
	) -- 112
	return docLanguage == "zh" and zhDir or enDir -- 113
end -- 110
local function getDoraTutorialDocRoot(docLanguage) -- 116
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 117
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 118
	return docLanguage == "zh" and zhDir or enDir -- 119
end -- 116
local function getDoraDocDefinitionExtsByCodeLanguage(programmingLanguage) -- 122
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 122
		return {"ts"} -- 124
	end -- 124
	return {"tl"} -- 126
end -- 122
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 129
	repeat -- 129
		local ____switch7 = programmingLanguage -- 129
		local ____cond7 = ____switch7 == "teal" -- 129
		if ____cond7 then -- 129
			return "tl" -- 131
		end -- 131
		____cond7 = ____cond7 or ____switch7 == "tl" -- 131
		if ____cond7 then -- 131
			return "tl" -- 132
		end -- 132
		do -- 132
			return programmingLanguage -- 133
		end -- 133
	until true -- 133
end -- 129
function ____exports.getDoraDocSearchTarget(docType, docLanguage, programmingLanguage) -- 137
	if docType == "dora-tutorial" then -- 137
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 143
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 144
		return { -- 145
			root = Path(tutorialRoot, langDir), -- 146
			exts = {"md"}, -- 147
			globs = {"**/*.md"} -- 148
		} -- 148
	end -- 148
	local exts = getDoraDocDefinitionExtsByCodeLanguage(programmingLanguage) -- 151
	if docType == "love-api" or docType == "tic80-api" then -- 151
		local name = docType == "love-api" and "love" or "tic80" -- 153
		return { -- 154
			root = getDoraDocDefinitionRoot(docLanguage), -- 155
			exts = exts, -- 156
			globs = __TS__ArrayMap( -- 157
				exts, -- 157
				function(____, ext) return (name .. ".d.") .. ext end -- 157
			) -- 157
		} -- 157
	end -- 157
	return { -- 160
		root = getDoraDocDefinitionRoot(docLanguage), -- 161
		exts = exts, -- 162
		globs = __TS__ArrayFlatMap( -- 163
			exts, -- 163
			function(____, ext) return {"**/*." .. ext, "!**/love.d." .. ext, "!**/tic80.d." .. ext} end -- 163
		) -- 163
	} -- 163
end -- 137
function ____exports.getDoraDocResultBaseRoot(docType, docLanguage) -- 171
	if docType == "dora-tutorial" then -- 171
		return getDoraTutorialDocRoot(docLanguage) -- 173
	end -- 173
	return getDoraDocDefinitionRoot(docLanguage) -- 175
end -- 171
function ____exports.isDoraDocFileInScope(docType, file) -- 178
	local normalized = string.lower(table.concat( -- 179
		__TS__StringSplit(file, "\\"), -- 179
		"/" -- 179
	)) -- 179
	local segments = __TS__StringSplit(normalized, "/") -- 180
	local baseName = segments[#segments] or normalized -- 181
	if docType == "dora-tutorial" then -- 181
		return __TS__StringEndsWith(normalized, ".md") -- 182
	end -- 182
	if docType == "love-api" then -- 182
		return normalized == "love.d.ts" or normalized == "love.d.tl" -- 183
	end -- 183
	if docType == "tic80-api" then -- 183
		return normalized == "tic80.d.ts" or normalized == "tic80.d.tl" -- 184
	end -- 184
	return (__TS__StringEndsWith(normalized, ".ts") or __TS__StringEndsWith(normalized, ".tl")) and baseName ~= "love.d.ts" and baseName ~= "love.d.tl" and baseName ~= "tic80.d.ts" and baseName ~= "tic80.d.tl" -- 185
end -- 178
____exports.AGENT_DORA_DOC_PREFIX = "@dora-doc/" -- 192
____exports.ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 194
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 195
local ENGINE_LOG_VIRTUAL_FILE = "@dora_full_logs.txt" -- 196
local function isAbsolutePathLike(path) -- 198
	if Content:isAbsolutePath(path) then -- 198
		return true -- 199
	end -- 199
	if __TS__StringStartsWith(path, "/") or __TS__StringStartsWith(path, "\\") then -- 199
		return true -- 200
	end -- 200
	local drivePath = string.match(path, "^%a:[/\\]") -- 201
	return drivePath ~= nil -- 202
end -- 198
function ____exports.isValidWorkspacePath(path) -- 205
	if path == "" then -- 205
		return false -- 206
	end -- 206
	if isAbsolutePathLike(path) then -- 206
		return false -- 207
	end -- 207
	local parts = __TS__StringSplit( -- 208
		table.concat( -- 208
			__TS__StringSplit(path, "\\"), -- 208
			"/" -- 208
		), -- 208
		"/" -- 208
	) -- 208
	if __TS__ArrayIndexOf(parts, "..") >= 0 then -- 208
		return false -- 209
	end -- 209
	return true -- 210
end -- 205
function ____exports.isValidWorkDir(workDir) -- 213
	if workDir == "" then -- 213
		return false -- 214
	end -- 214
	if not Content:isAbsolutePath(workDir) then -- 214
		return false -- 215
	end -- 215
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 215
		return false -- 216
	end -- 216
	return true -- 217
end -- 213
local function isValidSearchPath(path) -- 220
	if path == "" then -- 220
		return true -- 221
	end -- 221
	if isAbsolutePathLike(path) then -- 221
		return false -- 222
	end -- 222
	local parts = __TS__StringSplit( -- 223
		table.concat( -- 223
			__TS__StringSplit(path, "\\"), -- 223
			"/" -- 223
		), -- 223
		"/" -- 223
	) -- 223
	if __TS__ArrayIndexOf(parts, "..") >= 0 then -- 223
		return false -- 224
	end -- 224
	return true -- 225
end -- 220
function ____exports.resolveWorkspaceFilePath(workDir, path) -- 228
	if not ____exports.isValidWorkDir(workDir) then -- 228
		return nil -- 229
	end -- 229
	if not ____exports.isValidWorkspacePath(path) then -- 229
		return nil -- 230
	end -- 230
	return Path(workDir, path) -- 231
end -- 228
function ____exports.resolveWorkspaceSearchPath(workDir, path) -- 234
	if not ____exports.isValidWorkDir(workDir) then -- 234
		return nil -- 235
	end -- 235
	if not isValidSearchPath(path) then -- 235
		return nil -- 236
	end -- 236
	return path == "" and workDir or Path(workDir, path) -- 237
end -- 234
function ____exports.toWorkspaceRelativePath(workDir, path) -- 240
	if path == "" then -- 240
		return path -- 241
	end -- 241
	if not Content:isAbsolutePath(path) then -- 241
		return path -- 242
	end -- 242
	return Path:getRelative(path, workDir) -- 243
end -- 240
local function toWorkspaceRelativeFileList(workDir, files) -- 246
	return __TS__ArrayMap( -- 247
		files, -- 247
		function(____, file) return ____exports.toWorkspaceRelativePath(workDir, file) end -- 247
	) -- 247
end -- 246
local function toWorkspaceRelativeSearchResults(workDir, results) -- 250
	local mapped = {} -- 251
	do -- 251
		local i = 0 -- 252
		while i < #results do -- 252
			local row = results[i + 1] -- 253
			local clone = __TS__ObjectAssign({}, row) -- 254
			clone.file = ____exports.toWorkspaceRelativePath(workDir, clone.file) -- 255
			mapped[#mapped + 1] = clone -- 256
			i = i + 1 -- 252
		end -- 252
	end -- 252
	return mapped -- 258
end -- 250
function ____exports.resolveWorkspaceDirectoryPath(workDir, path) -- 261
	local relative = __TS__StringTrim(path or "") -- 262
	if relative == "" then -- 262
		return {success = true, path = workDir, relative = "."} -- 264
	end -- 264
	if not ____exports.isValidWorkDir(workDir) or not ____exports.isValidWorkspacePath(relative) then -- 264
		return {success = false, message = "invalid cwd path"} -- 267
	end -- 267
	local resolved = Path(workDir, relative) -- 269
	if not Content:exist(resolved) then -- 269
		return {success = false, message = "cwd does not exist"} -- 271
	end -- 271
	if not Content:isdir(resolved) then -- 271
		return {success = false, message = "cwd is not a directory"} -- 274
	end -- 274
	return {success = true, path = resolved, relative = relative} -- 276
end -- 261
local AGENT_SKILL_PREFIX = "@agent-skill/" -- 279
function ____exports.toDocRelativePath(baseRoot, path, docType) -- 281
	if path == "" then -- 281
		return path -- 282
	end -- 282
	local relative = Content:isAbsolutePath(path) and Path:getRelative(path, baseRoot) or path -- 283
	return ((____exports.AGENT_DORA_DOC_PREFIX .. docType) .. "/") .. relative -- 284
end -- 281
local function resolveAgentDoraDocFilePath(path, docLanguage) -- 287
	if not docLanguage then -- 287
		return nil -- 288
	end -- 288
	local relative = path -- 289
	local docType = "dora-tutorial" -- 290
	if __TS__StringStartsWith(path, ____exports.AGENT_DORA_DOC_PREFIX) then -- 290
		local namespaced = __TS__StringSlice(path, #____exports.AGENT_DORA_DOC_PREFIX) -- 292
		if __TS__StringStartsWith(namespaced, "dora-api/") then -- 292
			docType = "dora-api" -- 294
			relative = string.sub(namespaced, 10) -- 295
		elseif __TS__StringStartsWith(namespaced, "love-api/") then -- 295
			docType = "love-api" -- 297
			relative = string.sub(namespaced, 10) -- 298
		elseif __TS__StringStartsWith(namespaced, "tic80-api/") then -- 298
			docType = "tic80-api" -- 300
			relative = string.sub(namespaced, 11) -- 301
		elseif __TS__StringStartsWith(namespaced, "dora-tutorial/") then -- 301
			docType = "dora-tutorial" -- 303
			relative = string.sub(namespaced, 15) -- 304
		elseif __TS__StringStartsWith(namespaced, "api/") then -- 304
			docType = "dora-api" -- 306
			relative = string.sub(namespaced, 5) -- 307
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 307
			docType = "dora-tutorial" -- 309
			relative = string.sub(namespaced, 10) -- 310
		else -- 310
			return nil -- 312
		end -- 312
	end -- 312
	if not ____exports.isValidWorkspacePath(relative) then -- 312
		return nil -- 315
	end -- 315
	if not ____exports.isDoraDocFileInScope(docType, relative) then -- 315
		return nil -- 316
	end -- 316
	local root = ____exports.getDoraDocResultBaseRoot(docType, docLanguage) -- 317
	local candidate = Path(root, relative) -- 318
	local checked = Path:getRelative(candidate, root) -- 319
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 319
		return nil -- 320
	end -- 320
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 320
		return candidate -- 322
	end -- 322
	return nil -- 324
end -- 287
local function resolveAgentSkillFilePath(workDir, path) -- 327
	if not __TS__StringStartsWith(path, AGENT_SKILL_PREFIX) then -- 327
		return nil -- 328
	end -- 328
	local namespaced = table.concat( -- 329
		__TS__StringSplit( -- 329
			__TS__StringSlice(path, #AGENT_SKILL_PREFIX), -- 329
			"\\" -- 329
		), -- 329
		"/" -- 329
	) -- 329
	local root = "" -- 330
	local relative = "" -- 331
	if __TS__StringStartsWith(namespaced, "builtin/") then -- 331
		root = Path(Content.assetPath, "Doc", "skills") -- 333
		relative = __TS__StringSlice(namespaced, #"builtin/") -- 334
	elseif __TS__StringStartsWith(namespaced, "user/") then -- 334
		root = Path(Content.writablePath, ".agent", "skills") -- 336
		relative = __TS__StringSlice(namespaced, #"user/") -- 337
	elseif __TS__StringStartsWith(namespaced, "project/") then -- 337
		root = Path(workDir, ".agent", "skills") -- 339
		relative = __TS__StringSlice(namespaced, #"project/") -- 340
	else -- 340
		return nil -- 342
	end -- 342
	if not ____exports.isValidWorkspacePath(relative) or relative == "." then -- 342
		return nil -- 344
	end -- 344
	local candidate = Path(root, relative) -- 345
	local checked = Path:getRelative(candidate, root) -- 346
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 346
		return nil -- 347
	end -- 347
	if not Content:exist(candidate) or Content:isdir(candidate) then -- 347
		return nil -- 348
	end -- 348
	return candidate -- 349
end -- 327
function ____exports.ensureDirPath(dir) -- 352
	if dir == "." or dir == "" then -- 352
		return true -- 353
	end -- 353
	if Content:exist(dir) then -- 353
		return Content:isdir(dir) -- 354
	end -- 354
	local parent = Path:getPath(dir) -- 355
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 355
		if not ____exports.ensureDirPath(parent) then -- 355
			return false -- 357
		end -- 357
	end -- 357
	return Content:mkdir(dir) -- 359
end -- 352
function ____exports.ensureDirForFile(path) -- 362
	local dir = Path:getPath(path) -- 363
	return ____exports.ensureDirPath(dir) -- 364
end -- 362
function ____exports.getFileState(path) -- 367
	local exists = Content:exist(path) -- 368
	if not exists then -- 368
		return {exists = false, content = "", bytes = 0} -- 370
	end -- 370
	if Content:isdir(path) then -- 370
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 377
	end -- 377
	local content = Content:load(path) -- 384
	if type(content) ~= "string" then -- 384
		return {exists = true, content = "", bytes = 0} -- 386
	end -- 386
	return {exists = true, content = content, bytes = #content} -- 392
end -- 367
function ____exports.inspectReadableFile(path) -- 399
	do -- 399
		local function ____catch(e) -- 399
			Log( -- 421
				"Warn", -- 421
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 421
			) -- 421
			return true, {success = true} -- 422
		end -- 422
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 422
			local size, isBinary = Content:getAttr(path) -- 401
			if size == nil then -- 401
				return true, {success = false, message = "failed to read file"} -- 403
			end -- 403
			if isBinary then -- 403
				return true, { -- 409
					success = false, -- 410
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 411
					size = type(size) == "number" and size or nil, -- 412
					isBinary = true -- 413
				} -- 413
			end -- 413
			return true, { -- 416
				success = true, -- 417
				size = type(size) == "number" and size or nil -- 418
			} -- 418
		end) -- 418
		if not ____try then -- 418
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 418
		end -- 418
		if ____hasReturned then -- 418
			return ____returnValue -- 400
		end -- 400
	end -- 400
end -- 399
local function isEngineLogFilePath(path) -- 426
	return path == ENGINE_LOG_VIRTUAL_FILE -- 427
end -- 426
local function readEngineLogFile(path) -- 430
	if not isEngineLogFilePath(path) then -- 430
		return nil -- 431
	end -- 431
	local content = getEngineLogText() -- 432
	if content == nil then -- 432
		return {success = false, message = "failed to read engine logs"} -- 434
	end -- 434
	return {success = true, content = content, size = #content} -- 436
end -- 430
local function readWorkspaceFile(workDir, path, docLanguage) -- 439
	local engineLog = readEngineLogFile(path) -- 440
	if engineLog then -- 440
		return engineLog -- 441
	end -- 441
	local fullPath = ____exports.resolveWorkspaceFilePath(workDir, path) -- 442
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 442
		local attr = ____exports.inspectReadableFile(fullPath) -- 444
		if not attr.success then -- 444
			return attr -- 445
		end -- 445
		return { -- 446
			success = true, -- 446
			content = Content:load(fullPath), -- 446
			size = attr.size -- 446
		} -- 446
	end -- 446
	local docPath = resolveAgentDoraDocFilePath(path, docLanguage) -- 448
	if docPath then -- 448
		local attr = ____exports.inspectReadableFile(docPath) -- 450
		if not attr.success then -- 450
			return attr -- 451
		end -- 451
		return { -- 452
			success = true, -- 452
			content = Content:load(docPath), -- 452
			size = attr.size -- 452
		} -- 452
	end -- 452
	local skillPath = resolveAgentSkillFilePath(workDir, path) -- 454
	if skillPath then -- 454
		local attr = ____exports.inspectReadableFile(skillPath) -- 456
		if not attr.success then -- 456
			return attr -- 457
		end -- 457
		return { -- 458
			success = true, -- 458
			content = Content:load(skillPath), -- 458
			size = attr.size -- 458
		} -- 458
	end -- 458
	if not fullPath then -- 458
		return {success = false, message = "invalid path or workDir"} -- 460
	end -- 460
	return {success = false, message = "file not found"} -- 461
end -- 439
function ____exports.readFileRaw(workDir, path, docLanguage) -- 464
	return readWorkspaceFile(workDir, path, docLanguage) -- 465
end -- 464
function ____exports.inspectWorkspaceTextTarget(workDir, path) -- 468
	local fullPath = ____exports.resolveWorkspaceFilePath(workDir, path) -- 469
	if not fullPath then -- 469
		return {success = false, message = "invalid path or workDir"} -- 470
	end -- 470
	if not Content:exist(fullPath) then -- 470
		return {success = true, exists = false, content = ""} -- 471
	end -- 471
	if Content:isdir(fullPath) then -- 471
		return {success = false, message = "target is a directory"} -- 472
	end -- 472
	local attr = ____exports.inspectReadableFile(fullPath) -- 473
	if not attr.success then -- 473
		return {success = false, message = attr.message} -- 474
	end -- 474
	return { -- 475
		success = true, -- 475
		exists = true, -- 475
		content = Content:load(fullPath) -- 475
	} -- 475
end -- 468
function ____exports.getLogs(req) -- 490
	local text = getEngineLogText() -- 491
	if text == nil then -- 491
		return {success = false, message = "failed to read engine logs"} -- 493
	end -- 493
	local tailLines = math.max( -- 495
		1, -- 495
		math.floor(req and req.tailLines or 200) -- 495
	) -- 495
	local allLines = __TS__StringSplit(text, "\n") -- 496
	local logs = __TS__ArraySlice( -- 497
		allLines, -- 497
		math.max(0, #allLines - tailLines) -- 497
	) -- 497
	return req and req.joinText and ({ -- 498
		success = true, -- 498
		logs = logs, -- 498
		text = table.concat(logs, "\n") -- 498
	}) or ({success = true, logs = logs}) -- 498
end -- 490
function ____exports.listFiles(req) -- 501
	local root = req.path or "" -- 507
	local searchRoot = ____exports.resolveWorkspaceSearchPath(req.workDir, root) -- 508
	if searchRoot == nil then -- 508
		return {success = false, message = "invalid path or workDir"} -- 510
	end -- 510
	do -- 510
		local function ____catch(e) -- 510
			return true, { -- 528
				success = false, -- 528
				message = tostring(e) -- 528
			} -- 528
		end -- 528
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 528
			local userGlobs = req.globs ~= nil and #req.globs > 0 and req.globs or ({"**"}) -- 513
			local globs = ____exports.ensureSafeSearchGlobs(userGlobs) -- 514
			local files = Content:glob(searchRoot, globs, req.preferSourceVariants == false and ({}) or extensionLevels) -- 515
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 516
			local totalEntries = #files -- 517
			local maxEntries = math.max( -- 518
				1, -- 518
				math.floor(req.maxEntries or 200) -- 518
			) -- 518
			local truncated = totalEntries > maxEntries -- 519
			return true, { -- 520
				success = true, -- 521
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 522
				totalEntries = totalEntries, -- 523
				truncated = truncated, -- 524
				maxEntries = maxEntries -- 525
			} -- 525
		end) -- 525
		if not ____try then -- 525
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 525
		end -- 525
		if ____hasReturned then -- 525
			return ____returnValue -- 512
		end -- 512
	end -- 512
end -- 501
local function formatReadSlice(content, startLine, endLine) -- 532
	local lines = __TS__StringSplit(content, "\n") -- 537
	local totalLines = #lines -- 538
	if totalLines == 0 then -- 538
		return { -- 540
			success = true, -- 541
			content = "", -- 542
			totalLines = 0, -- 543
			startLine = 1, -- 544
			endLine = 0, -- 545
			truncated = false -- 546
		} -- 546
	end -- 546
	local rawStart = math.floor(startLine) -- 549
	local rawEnd = math.floor(endLine) -- 550
	if rawStart == 0 then -- 550
		return {success = false, message = "startLine cannot be 0"} -- 552
	end -- 552
	if rawEnd == 0 then -- 552
		return {success = false, message = "endLine cannot be 0"} -- 555
	end -- 555
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 557
	if start > totalLines then -- 557
		return { -- 561
			success = false, -- 561
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 561
		} -- 561
	end -- 561
	local ____end = math.min( -- 563
		totalLines, -- 564
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 565
	) -- 565
	if ____end < start then -- 565
		return { -- 570
			success = false, -- 571
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 572
		} -- 572
	end -- 572
	local slice = {} -- 575
	do -- 575
		local i = start -- 576
		while i <= ____end do -- 576
			slice[#slice + 1] = lines[i] -- 577
			i = i + 1 -- 576
		end -- 576
	end -- 576
	local truncated = start > 1 or ____end < totalLines -- 579
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 580
	local body = table.concat(slice, "\n") -- 585
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 586
	return { -- 587
		success = true, -- 588
		content = output, -- 589
		totalLines = totalLines, -- 590
		startLine = start, -- 591
		endLine = ____end, -- 592
		truncated = truncated -- 593
	} -- 593
end -- 532
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 597
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 604
	if not fallback.success or fallback.content == nil then -- 604
		return fallback -- 605
	end -- 605
	local resolvedStartLine = startLine or 1 -- 606
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 607
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 608
end -- 597
____exports.codeExtensions = { -- 615
	".lua", -- 615
	".tl", -- 615
	".yue", -- 615
	".ts", -- 615
	".tsx", -- 615
	".xml", -- 615
	".md", -- 615
	".yarn", -- 615
	".wa", -- 615
	".mod" -- 615
} -- 615
extensionLevels = { -- 616
	vs = 2, -- 617
	bl = 2, -- 618
	ts = 1, -- 619
	tsx = 1, -- 620
	tl = 1, -- 621
	yue = 1, -- 622
	xml = 1, -- 623
	lua = 0 -- 624
} -- 624
function ____exports.splitSearchPatterns(pattern) -- 641
	local trimmed = __TS__StringTrim(pattern or "") -- 642
	if trimmed == "" then -- 642
		return {} -- 643
	end -- 643
	local out = {} -- 644
	local seen = __TS__New(Set) -- 645
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 646
		local p = __TS__StringTrim(tostring(p0)) -- 647
		if p ~= "" and not seen:has(p) then -- 647
			seen:add(p) -- 649
			out[#out + 1] = p -- 650
		end -- 650
	end -- 650
	return out -- 653
end -- 641
function ____exports.splitWhitespaceSearchPatterns(pattern) -- 656
	local out = {} -- 657
	local seen = __TS__New(Set) -- 658
	for p0 in string.gmatch(pattern, "(%S+)") do -- 659
		local p = __TS__StringTrim(tostring(p0)) -- 660
		local key = string.lower(p) -- 661
		if p ~= "" and not seen:has(key) then -- 661
			seen:add(key) -- 663
			out[#out + 1] = p -- 664
		end -- 664
	end -- 664
	return out -- 667
end -- 656
local function mergeSearchFileResultsUnique(resultsList) -- 670
	local merged = {} -- 671
	local seen = __TS__New(Set) -- 672
	do -- 672
		local i = 0 -- 673
		while i < #resultsList do -- 673
			local list = resultsList[i + 1] -- 674
			do -- 674
				local j = 0 -- 675
				while j < #list do -- 675
					do -- 675
						local row = list[j + 1] -- 676
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 677
						if seen:has(key) then -- 677
							goto __continue148 -- 678
						end -- 678
						seen:add(key) -- 679
						merged[#merged + 1] = list[j + 1] -- 680
					end -- 680
					::__continue148:: -- 680
					j = j + 1 -- 675
				end -- 675
			end -- 675
			i = i + 1 -- 673
		end -- 673
	end -- 673
	return merged -- 683
end -- 670
local function buildGroupedSearchResults(results) -- 686
	local order = {} -- 691
	local grouped = __TS__New(Map) -- 692
	do -- 692
		local i = 0 -- 697
		while i < #results do -- 697
			local row = results[i + 1] -- 698
			local file = row.file -- 699
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 700
			local bucket = grouped:get(key) -- 701
			if not bucket then -- 701
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 703
				grouped:set(key, bucket) -- 704
				order[#order + 1] = key -- 705
			end -- 705
			bucket.totalMatches = bucket.totalMatches + 1 -- 707
			local ____bucket_matches_4 = bucket.matches -- 707
			____bucket_matches_4[#____bucket_matches_4 + 1] = results[i + 1] -- 708
			i = i + 1 -- 697
		end -- 697
	end -- 697
	local out = {} -- 710
	do -- 710
		local i = 0 -- 715
		while i < #order do -- 715
			local bucket = grouped:get(order[i + 1]) -- 716
			if bucket then -- 716
				out[#out + 1] = bucket -- 717
			end -- 717
			i = i + 1 -- 715
		end -- 715
	end -- 715
	return out -- 719
end -- 686
function ____exports.searchFiles(req) -- 722
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 722
		local requestedPath = __TS__StringTrim(req.path or "") -- 736
		local isVirtualDoc = __TS__StringStartsWith(requestedPath, ____exports.AGENT_DORA_DOC_PREFIX) -- 737
		local ____isVirtualDoc_5 -- 738
		if isVirtualDoc then -- 738
			____isVirtualDoc_5 = resolveAgentDoraDocFilePath(requestedPath, req.docLanguage or "en") -- 739
		else -- 739
			____isVirtualDoc_5 = nil -- 740
		end -- 740
		local virtualDocPath = ____isVirtualDoc_5 -- 738
		if isVirtualDoc and virtualDocPath == nil then -- 738
			return ____awaiter_resolve(nil, {success = false, message = "virtual document not found or outside its documentation scope"}) -- 738
		end -- 738
		local resolvedPath = virtualDocPath or ____exports.resolveWorkspaceSearchPath(req.workDir, requestedPath) -- 744
		if resolvedPath == nil then -- 744
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 744
		end -- 744
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 748
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 749
		if searchRoot == "" then -- 749
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 749
		end -- 749
		if req.pattern == "" or __TS__StringTrim(req.pattern) == "" then -- 749
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 749
		end -- 749
		local patterns = ____exports.splitSearchPatterns(req.pattern) -- 756
		if #patterns == 0 then -- 756
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 756
		end -- 756
		return ____awaiter_resolve( -- 756
			nil, -- 756
			__TS__New( -- 760
				__TS__Promise, -- 760
				function(____, resolve) -- 760
					Director.systemScheduler:schedule(once(function() -- 761
						do -- 761
							local function ____catch(e) -- 761
								resolve( -- 805
									nil, -- 805
									{ -- 805
										success = false, -- 805
										message = tostring(e) -- 805
									} -- 805
								) -- 805
							end -- 805
							local ____try, ____hasReturned = pcall(function() -- 805
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ____exports.ensureSafeSearchGlobs(req.globs or ({"**"})) -- 763
								local allResults = {} -- 766
								do -- 766
									local i = 0 -- 767
									while i < #patterns do -- 767
										local ____Content_10 = Content -- 768
										local ____Content_searchFilesAsync_11 = Content.searchFilesAsync -- 768
										local ____patterns_index_9 = patterns[i + 1] -- 773
										local ____req_useRegex_6 = req.useRegex -- 774
										if ____req_useRegex_6 == nil then -- 774
											____req_useRegex_6 = false -- 774
										end -- 774
										local ____req_caseSensitive_7 = req.caseSensitive -- 775
										if ____req_caseSensitive_7 == nil then -- 775
											____req_caseSensitive_7 = false -- 775
										end -- 775
										local ____req_includeContent_8 = req.includeContent -- 776
										if ____req_includeContent_8 == nil then -- 776
											____req_includeContent_8 = true -- 776
										end -- 776
										allResults[#allResults + 1] = ____Content_searchFilesAsync_11( -- 768
											____Content_10, -- 768
											searchRoot, -- 769
											____exports.codeExtensions, -- 769
											extensionLevels, -- 771
											searchGlobs, -- 772
											____patterns_index_9, -- 773
											____req_useRegex_6, -- 774
											____req_caseSensitive_7, -- 775
											____req_includeContent_8, -- 776
											req.contentWindow or 120 -- 777
										) -- 777
										i = i + 1 -- 767
									end -- 767
								end -- 767
								local results = mergeSearchFileResultsUnique(allResults) -- 780
								local totalResults = #results -- 781
								local limit = math.max( -- 782
									1, -- 782
									math.floor(req.limit or 20) -- 782
								) -- 782
								local offset = math.max( -- 783
									0, -- 783
									math.floor(req.offset or 0) -- 783
								) -- 783
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 784
								local nextOffset = offset + #paged -- 785
								local hasMore = nextOffset < totalResults -- 786
								local truncated = offset > 0 or hasMore -- 787
								local relativeResults = virtualDocPath and __TS__ArrayMap( -- 788
									paged, -- 789
									function(____, row) return __TS__ObjectAssign({}, row, {file = requestedPath}) end -- 789
								) or toWorkspaceRelativeSearchResults(req.workDir, paged) -- 789
								local groupByFile = req.groupByFile == true -- 791
								resolve( -- 792
									nil, -- 792
									{ -- 792
										success = true, -- 793
										results = relativeResults, -- 794
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 795
										totalResults = totalResults, -- 796
										truncated = truncated, -- 797
										limit = limit, -- 798
										offset = offset, -- 799
										nextOffset = nextOffset, -- 800
										hasMore = hasMore, -- 801
										groupByFile = groupByFile -- 802
									} -- 802
								) -- 802
							end) -- 802
							if not ____try then -- 802
								____catch(____hasReturned) -- 802
							end -- 802
						end -- 802
					end)) -- 761
				end -- 760
			) -- 760
		) -- 760
	end) -- 760
end -- 722
return ____exports -- 722