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
function getEngineLogText() -- 479
	local folder = Path(Content.writablePath, ____exports.ENGINE_LOG_DOWNLOAD_DIR) -- 480
	if not Content:exist(folder) then -- 480
		Content:mkdir(folder) -- 482
	end -- 482
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 484
	if not App:saveLog(logPath) then -- 484
		return nil -- 486
	end -- 486
	return Content:load(logPath) -- 488
end -- 488
function ____exports.ensureSafeSearchGlobs(globs) -- 628
	local result = {} -- 629
	do -- 629
		local i = 0 -- 630
		while i < #globs do -- 630
			result[#result + 1] = globs[i + 1] -- 631
			i = i + 1 -- 630
		end -- 630
	end -- 630
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 633
	do -- 633
		local i = 0 -- 634
		while i < #requiredExcludes do -- 634
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 634
				result[#result + 1] = requiredExcludes[i + 1] -- 636
			end -- 636
			i = i + 1 -- 634
		end -- 634
	end -- 634
	return result -- 639
end -- 628
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
	if not path or #path == 0 then -- 205
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
	if not workDir or #workDir == 0 then -- 213
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
	if not path or #path == 0 then -- 222
		return false -- 223
	end -- 223
	local parts = __TS__StringSplit( -- 224
		table.concat( -- 224
			__TS__StringSplit(path, "\\"), -- 224
			"/" -- 224
		), -- 224
		"/" -- 224
	) -- 224
	if __TS__ArrayIndexOf(parts, "..") >= 0 then -- 224
		return false -- 225
	end -- 225
	return true -- 226
end -- 220
function ____exports.resolveWorkspaceFilePath(workDir, path) -- 229
	if not ____exports.isValidWorkDir(workDir) then -- 229
		return nil -- 230
	end -- 230
	if not ____exports.isValidWorkspacePath(path) then -- 230
		return nil -- 231
	end -- 231
	return Path(workDir, path) -- 232
end -- 229
function ____exports.resolveWorkspaceSearchPath(workDir, path) -- 235
	if not ____exports.isValidWorkDir(workDir) then -- 235
		return nil -- 236
	end -- 236
	if not isValidSearchPath(path) then -- 236
		return nil -- 237
	end -- 237
	return path == "" and workDir or Path(workDir, path) -- 238
end -- 235
function ____exports.toWorkspaceRelativePath(workDir, path) -- 241
	if not path or #path == 0 then -- 241
		return path -- 242
	end -- 242
	if not Content:isAbsolutePath(path) then -- 242
		return path -- 243
	end -- 243
	return Path:getRelative(path, workDir) -- 244
end -- 241
local function toWorkspaceRelativeFileList(workDir, files) -- 247
	return __TS__ArrayMap( -- 248
		files, -- 248
		function(____, file) return ____exports.toWorkspaceRelativePath(workDir, file) end -- 248
	) -- 248
end -- 247
local function toWorkspaceRelativeSearchResults(workDir, results) -- 251
	local mapped = {} -- 252
	do -- 252
		local i = 0 -- 253
		while i < #results do -- 253
			local row = results[i + 1] -- 254
			local clone = __TS__ObjectAssign({}, row) -- 255
			clone.file = ____exports.toWorkspaceRelativePath(workDir, clone.file) -- 256
			mapped[#mapped + 1] = clone -- 257
			i = i + 1 -- 253
		end -- 253
	end -- 253
	return mapped -- 259
end -- 251
function ____exports.resolveWorkspaceDirectoryPath(workDir, path) -- 262
	local relative = __TS__StringTrim(path or "") -- 263
	if relative == "" then -- 263
		return {success = true, path = workDir, relative = "."} -- 265
	end -- 265
	if not ____exports.isValidWorkDir(workDir) or not ____exports.isValidWorkspacePath(relative) then -- 265
		return {success = false, message = "invalid cwd path"} -- 268
	end -- 268
	local resolved = Path(workDir, relative) -- 270
	if not Content:exist(resolved) then -- 270
		return {success = false, message = "cwd does not exist"} -- 272
	end -- 272
	if not Content:isdir(resolved) then -- 272
		return {success = false, message = "cwd is not a directory"} -- 275
	end -- 275
	return {success = true, path = resolved, relative = relative} -- 277
end -- 262
local AGENT_SKILL_PREFIX = "@agent-skill/" -- 280
function ____exports.toDocRelativePath(baseRoot, path, docType) -- 282
	if not path or #path == 0 then -- 282
		return path -- 283
	end -- 283
	local relative = Content:isAbsolutePath(path) and Path:getRelative(path, baseRoot) or path -- 284
	return ((____exports.AGENT_DORA_DOC_PREFIX .. docType) .. "/") .. relative -- 285
end -- 282
local function resolveAgentDoraDocFilePath(path, docLanguage) -- 288
	if not docLanguage then -- 288
		return nil -- 289
	end -- 289
	local relative = path -- 290
	local docType = "dora-tutorial" -- 291
	if __TS__StringStartsWith(path, ____exports.AGENT_DORA_DOC_PREFIX) then -- 291
		local namespaced = __TS__StringSlice(path, #____exports.AGENT_DORA_DOC_PREFIX) -- 293
		if __TS__StringStartsWith(namespaced, "dora-api/") then -- 293
			docType = "dora-api" -- 295
			relative = string.sub(namespaced, 10) -- 296
		elseif __TS__StringStartsWith(namespaced, "love-api/") then -- 296
			docType = "love-api" -- 298
			relative = string.sub(namespaced, 10) -- 299
		elseif __TS__StringStartsWith(namespaced, "tic80-api/") then -- 299
			docType = "tic80-api" -- 301
			relative = string.sub(namespaced, 11) -- 302
		elseif __TS__StringStartsWith(namespaced, "dora-tutorial/") then -- 302
			docType = "dora-tutorial" -- 304
			relative = string.sub(namespaced, 15) -- 305
		elseif __TS__StringStartsWith(namespaced, "api/") then -- 305
			docType = "dora-api" -- 307
			relative = string.sub(namespaced, 5) -- 308
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 308
			docType = "dora-tutorial" -- 310
			relative = string.sub(namespaced, 10) -- 311
		else -- 311
			return nil -- 313
		end -- 313
	end -- 313
	if not ____exports.isValidWorkspacePath(relative) then -- 313
		return nil -- 316
	end -- 316
	if not ____exports.isDoraDocFileInScope(docType, relative) then -- 316
		return nil -- 317
	end -- 317
	local root = ____exports.getDoraDocResultBaseRoot(docType, docLanguage) -- 318
	local candidate = Path(root, relative) -- 319
	local checked = Path:getRelative(candidate, root) -- 320
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 320
		return nil -- 321
	end -- 321
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 321
		return candidate -- 323
	end -- 323
	return nil -- 325
end -- 288
local function resolveAgentSkillFilePath(workDir, path) -- 328
	if not __TS__StringStartsWith(path, AGENT_SKILL_PREFIX) then -- 328
		return nil -- 329
	end -- 329
	local namespaced = table.concat( -- 330
		__TS__StringSplit( -- 330
			__TS__StringSlice(path, #AGENT_SKILL_PREFIX), -- 330
			"\\" -- 330
		), -- 330
		"/" -- 330
	) -- 330
	local root = "" -- 331
	local relative = "" -- 332
	if __TS__StringStartsWith(namespaced, "builtin/") then -- 332
		root = Path(Content.assetPath, "Doc", "skills") -- 334
		relative = __TS__StringSlice(namespaced, #"builtin/") -- 335
	elseif __TS__StringStartsWith(namespaced, "user/") then -- 335
		root = Path(Content.writablePath, ".agent", "skills") -- 337
		relative = __TS__StringSlice(namespaced, #"user/") -- 338
	elseif __TS__StringStartsWith(namespaced, "project/") then -- 338
		root = Path(workDir, ".agent", "skills") -- 340
		relative = __TS__StringSlice(namespaced, #"project/") -- 341
	else -- 341
		return nil -- 343
	end -- 343
	if not ____exports.isValidWorkspacePath(relative) or relative == "." then -- 343
		return nil -- 345
	end -- 345
	local candidate = Path(root, relative) -- 346
	local checked = Path:getRelative(candidate, root) -- 347
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 347
		return nil -- 348
	end -- 348
	if not Content:exist(candidate) or Content:isdir(candidate) then -- 348
		return nil -- 349
	end -- 349
	return candidate -- 350
end -- 328
function ____exports.ensureDirPath(dir) -- 353
	if not dir or dir == "." or dir == "" then -- 353
		return true -- 354
	end -- 354
	if Content:exist(dir) then -- 354
		return Content:isdir(dir) -- 355
	end -- 355
	local parent = Path:getPath(dir) -- 356
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 356
		if not ____exports.ensureDirPath(parent) then -- 356
			return false -- 358
		end -- 358
	end -- 358
	return Content:mkdir(dir) -- 360
end -- 353
function ____exports.ensureDirForFile(path) -- 363
	local dir = Path:getPath(path) -- 364
	return ____exports.ensureDirPath(dir) -- 365
end -- 363
function ____exports.getFileState(path) -- 368
	local exists = Content:exist(path) -- 369
	if not exists then -- 369
		return {exists = false, content = "", bytes = 0} -- 371
	end -- 371
	if Content:isdir(path) then -- 371
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 378
	end -- 378
	local content = Content:load(path) -- 385
	if type(content) ~= "string" then -- 385
		return {exists = true, content = "", bytes = 0} -- 387
	end -- 387
	return {exists = true, content = content, bytes = #content} -- 393
end -- 368
function ____exports.inspectReadableFile(path) -- 400
	do -- 400
		local function ____catch(e) -- 400
			Log( -- 422
				"Warn", -- 422
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 422
			) -- 422
			return true, {success = true} -- 423
		end -- 423
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 423
			local size, isBinary = Content:getAttr(path) -- 402
			if size == nil then -- 402
				return true, {success = false, message = "failed to read file"} -- 404
			end -- 404
			if isBinary then -- 404
				return true, { -- 410
					success = false, -- 411
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 412
					size = type(size) == "number" and size or nil, -- 413
					isBinary = true -- 414
				} -- 414
			end -- 414
			return true, { -- 417
				success = true, -- 418
				size = type(size) == "number" and size or nil -- 419
			} -- 419
		end) -- 419
		if not ____try then -- 419
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 419
		end -- 419
		if ____hasReturned then -- 419
			return ____returnValue -- 401
		end -- 401
	end -- 401
end -- 400
local function isEngineLogFilePath(path) -- 427
	return path == ENGINE_LOG_VIRTUAL_FILE -- 428
end -- 427
local function readEngineLogFile(path) -- 431
	if not isEngineLogFilePath(path) then -- 431
		return nil -- 432
	end -- 432
	local content = getEngineLogText() -- 433
	if content == nil then -- 433
		return {success = false, message = "failed to read engine logs"} -- 435
	end -- 435
	return {success = true, content = content, size = #content} -- 437
end -- 431
local function readWorkspaceFile(workDir, path, docLanguage) -- 440
	local engineLog = readEngineLogFile(path) -- 441
	if engineLog then -- 441
		return engineLog -- 442
	end -- 442
	local fullPath = ____exports.resolveWorkspaceFilePath(workDir, path) -- 443
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 443
		local attr = ____exports.inspectReadableFile(fullPath) -- 445
		if not attr.success then -- 445
			return attr -- 446
		end -- 446
		return { -- 447
			success = true, -- 447
			content = Content:load(fullPath), -- 447
			size = attr.size -- 447
		} -- 447
	end -- 447
	local docPath = resolveAgentDoraDocFilePath(path, docLanguage) -- 449
	if docPath then -- 449
		local attr = ____exports.inspectReadableFile(docPath) -- 451
		if not attr.success then -- 451
			return attr -- 452
		end -- 452
		return { -- 453
			success = true, -- 453
			content = Content:load(docPath), -- 453
			size = attr.size -- 453
		} -- 453
	end -- 453
	local skillPath = resolveAgentSkillFilePath(workDir, path) -- 455
	if skillPath then -- 455
		local attr = ____exports.inspectReadableFile(skillPath) -- 457
		if not attr.success then -- 457
			return attr -- 458
		end -- 458
		return { -- 459
			success = true, -- 459
			content = Content:load(skillPath), -- 459
			size = attr.size -- 459
		} -- 459
	end -- 459
	if not fullPath then -- 459
		return {success = false, message = "invalid path or workDir"} -- 461
	end -- 461
	return {success = false, message = "file not found"} -- 462
end -- 440
function ____exports.readFileRaw(workDir, path, docLanguage) -- 465
	return readWorkspaceFile(workDir, path, docLanguage) -- 466
end -- 465
function ____exports.inspectWorkspaceTextTarget(workDir, path) -- 469
	local fullPath = ____exports.resolveWorkspaceFilePath(workDir, path) -- 470
	if not fullPath then -- 470
		return {success = false, message = "invalid path or workDir"} -- 471
	end -- 471
	if not Content:exist(fullPath) then -- 471
		return {success = true, exists = false, content = ""} -- 472
	end -- 472
	if Content:isdir(fullPath) then -- 472
		return {success = false, message = "target is a directory"} -- 473
	end -- 473
	local attr = ____exports.inspectReadableFile(fullPath) -- 474
	if not attr.success then -- 474
		return {success = false, message = attr.message} -- 475
	end -- 475
	return { -- 476
		success = true, -- 476
		exists = true, -- 476
		content = Content:load(fullPath) -- 476
	} -- 476
end -- 469
function ____exports.getLogs(req) -- 491
	local text = getEngineLogText() -- 492
	if text == nil then -- 492
		return {success = false, message = "failed to read engine logs"} -- 494
	end -- 494
	local tailLines = math.max( -- 496
		1, -- 496
		math.floor(req and req.tailLines or 200) -- 496
	) -- 496
	local allLines = __TS__StringSplit(text, "\n") -- 497
	local logs = __TS__ArraySlice( -- 498
		allLines, -- 498
		math.max(0, #allLines - tailLines) -- 498
	) -- 498
	return req and req.joinText and ({ -- 499
		success = true, -- 499
		logs = logs, -- 499
		text = table.concat(logs, "\n") -- 499
	}) or ({success = true, logs = logs}) -- 499
end -- 491
function ____exports.listFiles(req) -- 502
	local root = req.path or "" -- 508
	local searchRoot = ____exports.resolveWorkspaceSearchPath(req.workDir, root) -- 509
	if not searchRoot then -- 509
		return {success = false, message = "invalid path or workDir"} -- 511
	end -- 511
	do -- 511
		local function ____catch(e) -- 511
			return true, { -- 529
				success = false, -- 529
				message = tostring(e) -- 529
			} -- 529
		end -- 529
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 529
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 514
			local globs = ____exports.ensureSafeSearchGlobs(userGlobs) -- 515
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 516
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 517
			local totalEntries = #files -- 518
			local maxEntries = math.max( -- 519
				1, -- 519
				math.floor(req.maxEntries or 200) -- 519
			) -- 519
			local truncated = totalEntries > maxEntries -- 520
			return true, { -- 521
				success = true, -- 522
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 523
				totalEntries = totalEntries, -- 524
				truncated = truncated, -- 525
				maxEntries = maxEntries -- 526
			} -- 526
		end) -- 526
		if not ____try then -- 526
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 526
		end -- 526
		if ____hasReturned then -- 526
			return ____returnValue -- 513
		end -- 513
	end -- 513
end -- 502
local function formatReadSlice(content, startLine, endLine) -- 533
	local lines = __TS__StringSplit(content, "\n") -- 538
	local totalLines = #lines -- 539
	if totalLines == 0 then -- 539
		return { -- 541
			success = true, -- 542
			content = "", -- 543
			totalLines = 0, -- 544
			startLine = 1, -- 545
			endLine = 0, -- 546
			truncated = false -- 547
		} -- 547
	end -- 547
	local rawStart = math.floor(startLine) -- 550
	local rawEnd = math.floor(endLine) -- 551
	if rawStart == 0 then -- 551
		return {success = false, message = "startLine cannot be 0"} -- 553
	end -- 553
	if rawEnd == 0 then -- 553
		return {success = false, message = "endLine cannot be 0"} -- 556
	end -- 556
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 558
	if start > totalLines then -- 558
		return { -- 562
			success = false, -- 562
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 562
		} -- 562
	end -- 562
	local ____end = math.min( -- 564
		totalLines, -- 565
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 566
	) -- 566
	if ____end < start then -- 566
		return { -- 571
			success = false, -- 572
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 573
		} -- 573
	end -- 573
	local slice = {} -- 576
	do -- 576
		local i = start -- 577
		while i <= ____end do -- 577
			slice[#slice + 1] = lines[i] -- 578
			i = i + 1 -- 577
		end -- 577
	end -- 577
	local truncated = start > 1 or ____end < totalLines -- 580
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 581
	local body = table.concat(slice, "\n") -- 586
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 587
	return { -- 588
		success = true, -- 589
		content = output, -- 590
		totalLines = totalLines, -- 591
		startLine = start, -- 592
		endLine = ____end, -- 593
		truncated = truncated -- 594
	} -- 594
end -- 533
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 598
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 605
	if not fallback.success or fallback.content == nil then -- 605
		return fallback -- 606
	end -- 606
	local resolvedStartLine = startLine or 1 -- 607
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 608
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 609
end -- 598
____exports.codeExtensions = { -- 616
	".lua", -- 616
	".tl", -- 616
	".yue", -- 616
	".ts", -- 616
	".tsx", -- 616
	".xml", -- 616
	".md", -- 616
	".yarn", -- 616
	".wa", -- 616
	".mod" -- 616
} -- 616
extensionLevels = { -- 617
	vs = 2, -- 618
	bl = 2, -- 619
	ts = 1, -- 620
	tsx = 1, -- 621
	tl = 1, -- 622
	yue = 1, -- 623
	xml = 1, -- 624
	lua = 0 -- 625
} -- 625
function ____exports.splitSearchPatterns(pattern) -- 642
	local trimmed = __TS__StringTrim(pattern or "") -- 643
	if trimmed == "" then -- 643
		return {} -- 644
	end -- 644
	local out = {} -- 645
	local seen = __TS__New(Set) -- 646
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 647
		local p = __TS__StringTrim(tostring(p0)) -- 648
		if p ~= "" and not seen:has(p) then -- 648
			seen:add(p) -- 650
			out[#out + 1] = p -- 651
		end -- 651
	end -- 651
	return out -- 654
end -- 642
function ____exports.splitWhitespaceSearchPatterns(pattern) -- 657
	local out = {} -- 658
	local seen = __TS__New(Set) -- 659
	for p0 in string.gmatch(pattern, "(%S+)") do -- 660
		local p = __TS__StringTrim(tostring(p0)) -- 661
		local key = string.lower(p) -- 662
		if p ~= "" and not seen:has(key) then -- 662
			seen:add(key) -- 664
			out[#out + 1] = p -- 665
		end -- 665
	end -- 665
	return out -- 668
end -- 657
local function mergeSearchFileResultsUnique(resultsList) -- 671
	local merged = {} -- 672
	local seen = __TS__New(Set) -- 673
	do -- 673
		local i = 0 -- 674
		while i < #resultsList do -- 674
			local list = resultsList[i + 1] -- 675
			do -- 675
				local j = 0 -- 676
				while j < #list do -- 676
					do -- 676
						local row = list[j + 1] -- 677
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 678
						if seen:has(key) then -- 678
							goto __continue149 -- 679
						end -- 679
						seen:add(key) -- 680
						merged[#merged + 1] = list[j + 1] -- 681
					end -- 681
					::__continue149:: -- 681
					j = j + 1 -- 676
				end -- 676
			end -- 676
			i = i + 1 -- 674
		end -- 674
	end -- 674
	return merged -- 684
end -- 671
local function buildGroupedSearchResults(results) -- 687
	local order = {} -- 692
	local grouped = __TS__New(Map) -- 693
	do -- 693
		local i = 0 -- 698
		while i < #results do -- 698
			local row = results[i + 1] -- 699
			local file = row.file -- 700
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 701
			local bucket = grouped:get(key) -- 702
			if not bucket then -- 702
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 704
				grouped:set(key, bucket) -- 705
				order[#order + 1] = key -- 706
			end -- 706
			bucket.totalMatches = bucket.totalMatches + 1 -- 708
			local ____bucket_matches_4 = bucket.matches -- 708
			____bucket_matches_4[#____bucket_matches_4 + 1] = results[i + 1] -- 709
			i = i + 1 -- 698
		end -- 698
	end -- 698
	local out = {} -- 711
	do -- 711
		local i = 0 -- 716
		while i < #order do -- 716
			local bucket = grouped:get(order[i + 1]) -- 717
			if bucket then -- 717
				out[#out + 1] = bucket -- 718
			end -- 718
			i = i + 1 -- 716
		end -- 716
	end -- 716
	return out -- 720
end -- 687
function ____exports.searchFiles(req) -- 723
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 723
		local requestedPath = __TS__StringTrim(req.path or "") -- 737
		local isVirtualDoc = __TS__StringStartsWith(requestedPath, ____exports.AGENT_DORA_DOC_PREFIX) -- 738
		local ____isVirtualDoc_5 -- 739
		if isVirtualDoc then -- 739
			____isVirtualDoc_5 = resolveAgentDoraDocFilePath(requestedPath, req.docLanguage or "en") -- 740
		else -- 740
			____isVirtualDoc_5 = nil -- 741
		end -- 741
		local virtualDocPath = ____isVirtualDoc_5 -- 739
		if isVirtualDoc and not virtualDocPath then -- 739
			return ____awaiter_resolve(nil, {success = false, message = "virtual document not found or outside its documentation scope"}) -- 739
		end -- 739
		local resolvedPath = virtualDocPath or ____exports.resolveWorkspaceSearchPath(req.workDir, requestedPath) -- 745
		if not resolvedPath then -- 745
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 745
		end -- 745
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 749
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 750
		if not searchRoot then -- 750
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 750
		end -- 750
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 750
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 750
		end -- 750
		local patterns = ____exports.splitSearchPatterns(req.pattern) -- 757
		if #patterns == 0 then -- 757
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 757
		end -- 757
		return ____awaiter_resolve( -- 757
			nil, -- 757
			__TS__New( -- 761
				__TS__Promise, -- 761
				function(____, resolve) -- 761
					Director.systemScheduler:schedule(once(function() -- 762
						do -- 762
							local function ____catch(e) -- 762
								resolve( -- 806
									nil, -- 806
									{ -- 806
										success = false, -- 806
										message = tostring(e) -- 806
									} -- 806
								) -- 806
							end -- 806
							local ____try, ____hasReturned = pcall(function() -- 806
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ____exports.ensureSafeSearchGlobs(req.globs or ({"**"})) -- 764
								local allResults = {} -- 767
								do -- 767
									local i = 0 -- 768
									while i < #patterns do -- 768
										local ____Content_10 = Content -- 769
										local ____Content_searchFilesAsync_11 = Content.searchFilesAsync -- 769
										local ____patterns_index_9 = patterns[i + 1] -- 774
										local ____req_useRegex_6 = req.useRegex -- 775
										if ____req_useRegex_6 == nil then -- 775
											____req_useRegex_6 = false -- 775
										end -- 775
										local ____req_caseSensitive_7 = req.caseSensitive -- 776
										if ____req_caseSensitive_7 == nil then -- 776
											____req_caseSensitive_7 = false -- 776
										end -- 776
										local ____req_includeContent_8 = req.includeContent -- 777
										if ____req_includeContent_8 == nil then -- 777
											____req_includeContent_8 = true -- 777
										end -- 777
										allResults[#allResults + 1] = ____Content_searchFilesAsync_11( -- 769
											____Content_10, -- 769
											searchRoot, -- 770
											____exports.codeExtensions, -- 770
											extensionLevels, -- 772
											searchGlobs, -- 773
											____patterns_index_9, -- 774
											____req_useRegex_6, -- 775
											____req_caseSensitive_7, -- 776
											____req_includeContent_8, -- 777
											req.contentWindow or 120 -- 778
										) -- 778
										i = i + 1 -- 768
									end -- 768
								end -- 768
								local results = mergeSearchFileResultsUnique(allResults) -- 781
								local totalResults = #results -- 782
								local limit = math.max( -- 783
									1, -- 783
									math.floor(req.limit or 20) -- 783
								) -- 783
								local offset = math.max( -- 784
									0, -- 784
									math.floor(req.offset or 0) -- 784
								) -- 784
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 785
								local nextOffset = offset + #paged -- 786
								local hasMore = nextOffset < totalResults -- 787
								local truncated = offset > 0 or hasMore -- 788
								local relativeResults = virtualDocPath and __TS__ArrayMap( -- 789
									paged, -- 790
									function(____, row) return __TS__ObjectAssign({}, row, {file = requestedPath}) end -- 790
								) or toWorkspaceRelativeSearchResults(req.workDir, paged) -- 790
								local groupByFile = req.groupByFile == true -- 792
								resolve( -- 793
									nil, -- 793
									{ -- 793
										success = true, -- 794
										results = relativeResults, -- 795
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 796
										totalResults = totalResults, -- 797
										truncated = truncated, -- 798
										limit = limit, -- 799
										offset = offset, -- 800
										nextOffset = nextOffset, -- 801
										hasMore = hasMore, -- 802
										groupByFile = groupByFile -- 803
									} -- 803
								) -- 803
							end) -- 803
							if not ____try then -- 803
								____catch(____hasReturned) -- 803
							end -- 803
						end -- 803
					end)) -- 762
				end -- 761
			) -- 761
		) -- 761
	end) -- 761
end -- 723
return ____exports -- 723