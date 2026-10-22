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
local isEngineLogFilePath, getEngineLogText, ENGINE_LOG_FILE, ENGINE_LOG_VIRTUAL_FILE, extensionLevels -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local App = ____Dora.App -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local AgentConfig = require("Agent.Config.Defaults") -- 4
local ____Utils = require("Agent.Utils") -- 5
local Log = ____Utils.Log -- 5
function isEngineLogFilePath(path) -- 443
	return path == ENGINE_LOG_VIRTUAL_FILE -- 444
end -- 444
function getEngineLogText() -- 495
	local folder = Path(Content.writablePath, ____exports.ENGINE_LOG_DOWNLOAD_DIR) -- 496
	if not Content:exist(folder) then -- 496
		Content:mkdir(folder) -- 498
	end -- 498
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 500
	if not App:saveLog(logPath) then -- 500
		return nil -- 502
	end -- 502
	return Content:load(logPath) -- 504
end -- 504
function ____exports.ensureSafeSearchGlobs(globs) -- 645
	local result = {} -- 646
	do -- 646
		local i = 0 -- 647
		while i < #globs do -- 647
			result[#result + 1] = globs[i + 1] -- 648
			i = i + 1 -- 647
		end -- 647
	end -- 647
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 650
	do -- 650
		local i = 0 -- 651
		while i < #requiredExcludes do -- 651
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 651
				result[#result + 1] = requiredExcludes[i + 1] -- 653
			end -- 653
			i = i + 1 -- 651
		end -- 651
	end -- 651
	return result -- 656
end -- 645
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
ENGINE_LOG_VIRTUAL_FILE = "@dora_full_logs.txt" -- 196
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
function ____exports.resolveAgentContentVirtualPath(workDir, path, docLanguage) -- 353
	if docLanguage == nil then -- 353
		docLanguage = "en" -- 353
	end -- 353
	if __TS__StringStartsWith(path, ____exports.AGENT_DORA_DOC_PREFIX) then -- 353
		return resolveAgentDoraDocFilePath(path, docLanguage) -- 355
	end -- 355
	if __TS__StringStartsWith(path, AGENT_SKILL_PREFIX) then -- 355
		return resolveAgentSkillFilePath(workDir, path) -- 357
	end -- 357
	if isEngineLogFilePath(path) then -- 357
		if getEngineLogText() == nil then -- 357
			return nil -- 359
		end -- 359
		return Path(Content.writablePath, ____exports.ENGINE_LOG_DOWNLOAD_DIR, ENGINE_LOG_FILE) -- 360
	end -- 360
	return nil -- 362
end -- 353
function ____exports.isAgentContentVirtualPath(path) -- 365
	return __TS__StringStartsWith(path, ____exports.AGENT_DORA_DOC_PREFIX) or __TS__StringStartsWith(path, AGENT_SKILL_PREFIX) or isEngineLogFilePath(path) -- 366
end -- 365
function ____exports.ensureDirPath(dir) -- 369
	if dir == "." or dir == "" then -- 369
		return true -- 370
	end -- 370
	if Content:exist(dir) then -- 370
		return Content:isdir(dir) -- 371
	end -- 371
	local parent = Path:getPath(dir) -- 372
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 372
		if not ____exports.ensureDirPath(parent) then -- 372
			return false -- 374
		end -- 374
	end -- 374
	return Content:mkdir(dir) -- 376
end -- 369
function ____exports.ensureDirForFile(path) -- 379
	local dir = Path:getPath(path) -- 380
	return ____exports.ensureDirPath(dir) -- 381
end -- 379
function ____exports.getFileState(path) -- 384
	local exists = Content:exist(path) -- 385
	if not exists then -- 385
		return {exists = false, content = "", bytes = 0} -- 387
	end -- 387
	if Content:isdir(path) then -- 387
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 394
	end -- 394
	local content = Content:load(path) -- 401
	if type(content) ~= "string" then -- 401
		return {exists = true, content = "", bytes = 0} -- 403
	end -- 403
	return {exists = true, content = content, bytes = #content} -- 409
end -- 384
function ____exports.inspectReadableFile(path) -- 416
	do -- 416
		local function ____catch(e) -- 416
			Log( -- 438
				"Warn", -- 438
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 438
			) -- 438
			return true, {success = true} -- 439
		end -- 439
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 439
			local size, isBinary = Content:getAttr(path) -- 418
			if size == nil then -- 418
				return true, {success = false, message = "failed to read file"} -- 420
			end -- 420
			if isBinary then -- 420
				return true, { -- 426
					success = false, -- 427
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 428
					size = type(size) == "number" and size or nil, -- 429
					isBinary = true -- 430
				} -- 430
			end -- 430
			return true, { -- 433
				success = true, -- 434
				size = type(size) == "number" and size or nil -- 435
			} -- 435
		end) -- 435
		if not ____try then -- 435
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 435
		end -- 435
		if ____hasReturned then -- 435
			return ____returnValue -- 417
		end -- 417
	end -- 417
end -- 416
local function readEngineLogFile(path) -- 447
	if not isEngineLogFilePath(path) then -- 447
		return nil -- 448
	end -- 448
	local content = getEngineLogText() -- 449
	if content == nil then -- 449
		return {success = false, message = "failed to read engine logs"} -- 451
	end -- 451
	return {success = true, content = content, size = #content} -- 453
end -- 447
local function readWorkspaceFile(workDir, path, docLanguage) -- 456
	local engineLog = readEngineLogFile(path) -- 457
	if engineLog then -- 457
		return engineLog -- 458
	end -- 458
	local fullPath = ____exports.resolveWorkspaceFilePath(workDir, path) -- 459
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 459
		local attr = ____exports.inspectReadableFile(fullPath) -- 461
		if not attr.success then -- 461
			return attr -- 462
		end -- 462
		return { -- 463
			success = true, -- 463
			content = Content:load(fullPath), -- 463
			size = attr.size -- 463
		} -- 463
	end -- 463
	local docPath = resolveAgentDoraDocFilePath(path, docLanguage) -- 465
	if docPath then -- 465
		local attr = ____exports.inspectReadableFile(docPath) -- 467
		if not attr.success then -- 467
			return attr -- 468
		end -- 468
		return { -- 469
			success = true, -- 469
			content = Content:load(docPath), -- 469
			size = attr.size -- 469
		} -- 469
	end -- 469
	local skillPath = resolveAgentSkillFilePath(workDir, path) -- 471
	if skillPath then -- 471
		local attr = ____exports.inspectReadableFile(skillPath) -- 473
		if not attr.success then -- 473
			return attr -- 474
		end -- 474
		return { -- 475
			success = true, -- 475
			content = Content:load(skillPath), -- 475
			size = attr.size -- 475
		} -- 475
	end -- 475
	if not fullPath then -- 475
		return {success = false, message = "invalid path or workDir"} -- 477
	end -- 477
	return {success = false, message = "file not found"} -- 478
end -- 456
function ____exports.readFileRaw(workDir, path, docLanguage) -- 481
	return readWorkspaceFile(workDir, path, docLanguage) -- 482
end -- 481
function ____exports.inspectWorkspaceTextTarget(workDir, path) -- 485
	local fullPath = ____exports.resolveWorkspaceFilePath(workDir, path) -- 486
	if not fullPath then -- 486
		return {success = false, message = "invalid path or workDir"} -- 487
	end -- 487
	if not Content:exist(fullPath) then -- 487
		return {success = true, exists = false, content = ""} -- 488
	end -- 488
	if Content:isdir(fullPath) then -- 488
		return {success = false, message = "target is a directory"} -- 489
	end -- 489
	local attr = ____exports.inspectReadableFile(fullPath) -- 490
	if not attr.success then -- 490
		return {success = false, message = attr.message} -- 491
	end -- 491
	return { -- 492
		success = true, -- 492
		exists = true, -- 492
		content = Content:load(fullPath) -- 492
	} -- 492
end -- 485
function ____exports.getLogs(req) -- 507
	local text = getEngineLogText() -- 508
	if text == nil then -- 508
		return {success = false, message = "failed to read engine logs"} -- 510
	end -- 510
	local tailLines = math.max( -- 512
		1, -- 512
		math.floor(req and req.tailLines or 200) -- 512
	) -- 512
	local allLines = __TS__StringSplit(text, "\n") -- 513
	local logs = __TS__ArraySlice( -- 514
		allLines, -- 514
		math.max(0, #allLines - tailLines) -- 514
	) -- 514
	return req and req.joinText and ({ -- 515
		success = true, -- 515
		logs = logs, -- 515
		text = table.concat(logs, "\n") -- 515
	}) or ({success = true, logs = logs}) -- 515
end -- 507
function ____exports.listFiles(req) -- 518
	local root = req.path or "" -- 524
	local searchRoot = ____exports.resolveWorkspaceSearchPath(req.workDir, root) -- 525
	if searchRoot == nil then -- 525
		return {success = false, message = "invalid path or workDir"} -- 527
	end -- 527
	do -- 527
		local function ____catch(e) -- 527
			return true, { -- 545
				success = false, -- 545
				message = tostring(e) -- 545
			} -- 545
		end -- 545
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 545
			local userGlobs = req.globs ~= nil and #req.globs > 0 and req.globs or ({"**"}) -- 530
			local globs = ____exports.ensureSafeSearchGlobs(userGlobs) -- 531
			local files = Content:glob(searchRoot, globs, req.preferSourceVariants == false and ({}) or extensionLevels) -- 532
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 533
			local totalEntries = #files -- 534
			local maxEntries = math.max( -- 535
				1, -- 535
				math.floor(req.maxEntries or 200) -- 535
			) -- 535
			local truncated = totalEntries > maxEntries -- 536
			return true, { -- 537
				success = true, -- 538
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 539
				totalEntries = totalEntries, -- 540
				truncated = truncated, -- 541
				maxEntries = maxEntries -- 542
			} -- 542
		end) -- 542
		if not ____try then -- 542
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 542
		end -- 542
		if ____hasReturned then -- 542
			return ____returnValue -- 529
		end -- 529
	end -- 529
end -- 518
local function formatReadSlice(content, startLine, endLine) -- 549
	local lines = __TS__StringSplit(content, "\n") -- 554
	local totalLines = #lines -- 555
	if totalLines == 0 then -- 555
		return { -- 557
			success = true, -- 558
			content = "", -- 559
			totalLines = 0, -- 560
			startLine = 1, -- 561
			endLine = 0, -- 562
			truncated = false -- 563
		} -- 563
	end -- 563
	local rawStart = math.floor(startLine) -- 566
	local ____temp_4 -- 567
	if endLine == nil then -- 567
		____temp_4 = nil -- 567
	else -- 567
		____temp_4 = math.floor(endLine) -- 567
	end -- 567
	local rawEnd = ____temp_4 -- 567
	if rawStart == 0 then -- 567
		return {success = false, message = "startLine cannot be 0"} -- 569
	end -- 569
	if rawEnd == 0 then -- 569
		return {success = false, message = "endLine cannot be 0"} -- 572
	end -- 572
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 574
	if start > totalLines then -- 574
		return { -- 578
			success = false, -- 578
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 578
		} -- 578
	end -- 578
	local ____end = math.min( -- 580
		totalLines, -- 581
		rawEnd == nil and start + AgentConfig.AGENT_LIMITS.readFileDefaultLimit - 1 or (rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1)) -- 582
	) -- 582
	if ____end < start then -- 582
		return { -- 589
			success = false, -- 590
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 591
		} -- 591
	end -- 591
	local slice = {} -- 594
	do -- 594
		local i = start -- 595
		while i <= ____end do -- 595
			slice[#slice + 1] = lines[i] -- 596
			i = i + 1 -- 595
		end -- 595
	end -- 595
	local truncated = start > 1 or ____end < totalLines -- 598
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 599
	local body = table.concat(slice, "\n") -- 604
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 605
	return { -- 606
		success = true, -- 607
		content = output, -- 608
		totalLines = totalLines, -- 609
		startLine = start, -- 610
		endLine = ____end, -- 611
		truncated = truncated -- 612
	} -- 612
end -- 549
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 616
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 623
	if not fallback.success or fallback.content == nil then -- 623
		return fallback -- 624
	end -- 624
	local resolvedStartLine = startLine or 1 -- 625
	return formatReadSlice(fallback.content, resolvedStartLine, endLine) -- 626
end -- 616
____exports.codeExtensions = { -- 633
	".lua", -- 633
	".tl", -- 633
	".yue", -- 633
	".ts", -- 633
	".tsx", -- 633
	".xml", -- 633
	".md", -- 633
	".yarn", -- 633
	".wa", -- 633
	".mod" -- 633
} -- 633
extensionLevels = { -- 634
	vs = 2, -- 635
	bl = 2, -- 636
	ts = 1, -- 637
	tsx = 1, -- 638
	tl = 1, -- 639
	yue = 1, -- 640
	xml = 1, -- 641
	lua = 0 -- 642
} -- 642
function ____exports.splitSearchPatterns(pattern) -- 659
	local trimmed = __TS__StringTrim(pattern or "") -- 660
	if trimmed == "" then -- 660
		return {} -- 661
	end -- 661
	local out = {} -- 662
	local seen = __TS__New(Set) -- 663
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 664
		local p = __TS__StringTrim(tostring(p0)) -- 665
		if p ~= "" and not seen:has(p) then -- 665
			seen:add(p) -- 667
			out[#out + 1] = p -- 668
		end -- 668
	end -- 668
	return out -- 671
end -- 659
function ____exports.splitWhitespaceSearchPatterns(pattern) -- 674
	local out = {} -- 675
	local seen = __TS__New(Set) -- 676
	for p0 in string.gmatch(pattern, "(%S+)") do -- 677
		local p = __TS__StringTrim(tostring(p0)) -- 678
		local key = string.lower(p) -- 679
		if p ~= "" and not seen:has(key) then -- 679
			seen:add(key) -- 681
			out[#out + 1] = p -- 682
		end -- 682
	end -- 682
	return out -- 685
end -- 674
local function mergeSearchFileResultsUnique(resultsList) -- 688
	local merged = {} -- 689
	local seen = __TS__New(Set) -- 690
	do -- 690
		local i = 0 -- 691
		while i < #resultsList do -- 691
			local list = resultsList[i + 1] -- 692
			do -- 692
				local j = 0 -- 693
				while j < #list do -- 693
					do -- 693
						local row = list[j + 1] -- 694
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 695
						if seen:has(key) then -- 695
							goto __continue154 -- 696
						end -- 696
						seen:add(key) -- 697
						merged[#merged + 1] = list[j + 1] -- 698
					end -- 698
					::__continue154:: -- 698
					j = j + 1 -- 693
				end -- 693
			end -- 693
			i = i + 1 -- 691
		end -- 691
	end -- 691
	return merged -- 701
end -- 688
local function buildGroupedSearchResults(results) -- 704
	local order = {} -- 709
	local grouped = __TS__New(Map) -- 710
	do -- 710
		local i = 0 -- 715
		while i < #results do -- 715
			local row = results[i + 1] -- 716
			local file = row.file -- 717
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 718
			local bucket = grouped:get(key) -- 719
			if not bucket then -- 719
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 721
				grouped:set(key, bucket) -- 722
				order[#order + 1] = key -- 723
			end -- 723
			bucket.totalMatches = bucket.totalMatches + 1 -- 725
			local ____bucket_matches_5 = bucket.matches -- 725
			____bucket_matches_5[#____bucket_matches_5 + 1] = results[i + 1] -- 726
			i = i + 1 -- 715
		end -- 715
	end -- 715
	local out = {} -- 728
	do -- 728
		local i = 0 -- 733
		while i < #order do -- 733
			local bucket = grouped:get(order[i + 1]) -- 734
			if bucket then -- 734
				out[#out + 1] = bucket -- 735
			end -- 735
			i = i + 1 -- 733
		end -- 733
	end -- 733
	return out -- 737
end -- 704
function ____exports.searchFiles(req) -- 740
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 740
		local requestedPath = __TS__StringTrim(req.path or "") -- 754
		local isVirtualDoc = __TS__StringStartsWith(requestedPath, ____exports.AGENT_DORA_DOC_PREFIX) -- 755
		local ____isVirtualDoc_6 -- 756
		if isVirtualDoc then -- 756
			____isVirtualDoc_6 = resolveAgentDoraDocFilePath(requestedPath, req.docLanguage or "en") -- 757
		else -- 757
			____isVirtualDoc_6 = nil -- 758
		end -- 758
		local virtualDocPath = ____isVirtualDoc_6 -- 756
		if isVirtualDoc and virtualDocPath == nil then -- 756
			return ____awaiter_resolve(nil, {success = false, message = "virtual document not found or outside its documentation scope"}) -- 756
		end -- 756
		local resolvedPath = virtualDocPath or ____exports.resolveWorkspaceSearchPath(req.workDir, requestedPath) -- 762
		if resolvedPath == nil then -- 762
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 762
		end -- 762
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 766
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 767
		if searchRoot == "" then -- 767
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 767
		end -- 767
		if req.pattern == "" or __TS__StringTrim(req.pattern) == "" then -- 767
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 767
		end -- 767
		local patterns = ____exports.splitSearchPatterns(req.pattern) -- 774
		if #patterns == 0 then -- 774
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 774
		end -- 774
		return ____awaiter_resolve( -- 774
			nil, -- 774
			__TS__New( -- 778
				__TS__Promise, -- 778
				function(____, resolve) -- 778
					Director.systemScheduler:schedule(once(function() -- 779
						do -- 779
							local function ____catch(e) -- 779
								resolve( -- 823
									nil, -- 823
									{ -- 823
										success = false, -- 823
										message = tostring(e) -- 823
									} -- 823
								) -- 823
							end -- 823
							local ____try, ____hasReturned = pcall(function() -- 823
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ____exports.ensureSafeSearchGlobs(req.globs or ({"**"})) -- 781
								local allResults = {} -- 784
								do -- 784
									local i = 0 -- 785
									while i < #patterns do -- 785
										local ____Content_11 = Content -- 786
										local ____Content_searchFilesAsync_12 = Content.searchFilesAsync -- 786
										local ____patterns_index_10 = patterns[i + 1] -- 791
										local ____req_useRegex_7 = req.useRegex -- 792
										if ____req_useRegex_7 == nil then -- 792
											____req_useRegex_7 = false -- 792
										end -- 792
										local ____req_caseSensitive_8 = req.caseSensitive -- 793
										if ____req_caseSensitive_8 == nil then -- 793
											____req_caseSensitive_8 = false -- 793
										end -- 793
										local ____req_includeContent_9 = req.includeContent -- 794
										if ____req_includeContent_9 == nil then -- 794
											____req_includeContent_9 = true -- 794
										end -- 794
										allResults[#allResults + 1] = ____Content_searchFilesAsync_12( -- 786
											____Content_11, -- 786
											searchRoot, -- 787
											____exports.codeExtensions, -- 787
											extensionLevels, -- 789
											searchGlobs, -- 790
											____patterns_index_10, -- 791
											____req_useRegex_7, -- 792
											____req_caseSensitive_8, -- 793
											____req_includeContent_9, -- 794
											req.contentWindow or 120 -- 795
										) -- 795
										i = i + 1 -- 785
									end -- 785
								end -- 785
								local results = mergeSearchFileResultsUnique(allResults) -- 798
								local totalResults = #results -- 799
								local limit = math.max( -- 800
									1, -- 800
									math.floor(req.limit or 20) -- 800
								) -- 800
								local offset = math.max( -- 801
									0, -- 801
									math.floor(req.offset or 0) -- 801
								) -- 801
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 802
								local nextOffset = offset + #paged -- 803
								local hasMore = nextOffset < totalResults -- 804
								local truncated = offset > 0 or hasMore -- 805
								local relativeResults = virtualDocPath and __TS__ArrayMap( -- 806
									paged, -- 807
									function(____, row) return __TS__ObjectAssign({}, row, {file = requestedPath}) end -- 807
								) or toWorkspaceRelativeSearchResults(req.workDir, paged) -- 807
								local groupByFile = req.groupByFile == true -- 809
								resolve( -- 810
									nil, -- 810
									{ -- 810
										success = true, -- 811
										results = relativeResults, -- 812
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 813
										totalResults = totalResults, -- 814
										truncated = truncated, -- 815
										limit = limit, -- 816
										offset = offset, -- 817
										nextOffset = nextOffset, -- 818
										hasMore = hasMore, -- 819
										groupByFile = groupByFile -- 820
									} -- 820
								) -- 820
							end) -- 820
							if not ____try then -- 820
								____catch(____hasReturned) -- 820
							end -- 820
						end -- 820
					end)) -- 779
				end -- 778
			) -- 778
		) -- 778
	end) -- 778
end -- 740
return ____exports -- 740