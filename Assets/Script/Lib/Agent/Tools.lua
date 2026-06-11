-- [ts]: Tools.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local Set = ____lualib.Set -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local Map = ____lualib.Map -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local getEngineLogText, ensureSafeSearchGlobs, ENGINE_LOG_DOWNLOAD_DIR, ENGINE_LOG_FILE, extensionLevels -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local Node = ____Dora.Node -- 2
local emit = ____Dora.emit -- 2
local wait = ____Dora.wait -- 2
local sleep = ____Dora.sleep -- 2
local App = ____Dora.App -- 2
local HttpServer = ____Dora.HttpServer -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
local safeJsonDecode = ____Utils.safeJsonDecode -- 3
local safeJsonEncode = ____Utils.safeJsonEncode -- 3
function getEngineLogText() -- 950
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 951
	if not Content:exist(folder) then -- 951
		Content:mkdir(folder) -- 953
	end -- 953
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 955
	if not App:saveLog(logPath) then -- 955
		return nil -- 957
	end -- 957
	return Content:load(logPath) -- 959
end -- 959
function ensureSafeSearchGlobs(globs) -- 1099
	local result = {} -- 1100
	do -- 1100
		local i = 0 -- 1101
		while i < #globs do -- 1101
			result[#result + 1] = globs[i + 1] -- 1102
			i = i + 1 -- 1101
		end -- 1101
	end -- 1101
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1104
	do -- 1104
		local i = 0 -- 1105
		while i < #requiredExcludes do -- 1105
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1105
				result[#result + 1] = requiredExcludes[i + 1] -- 1107
			end -- 1107
			i = i + 1 -- 1105
		end -- 1105
	end -- 1105
	return result -- 1110
end -- 1110
local TABLE_TASK = "AgentTask" -- 232
local TABLE_CP = "AgentCheckpoint" -- 233
local TABLE_ENTRY = "AgentCheckpointEntry" -- 234
ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 235
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 236
local BUILD_TS_TRANSPILE_PAUSE_SECONDS = 0.03 -- 237
local function now() -- 239
	return os.time() -- 239
end -- 239
local function toBool(v) -- 241
	return v ~= 0 and v ~= false and v ~= nil -- 242
end -- 241
local function toStr(v) -- 245
	if v == false or v == nil then -- 245
		return "" -- 246
	end -- 246
	return tostring(v) -- 247
end -- 245
local function isValidWorkspacePath(path) -- 250
	if not path or #path == 0 then -- 250
		return false -- 251
	end -- 251
	if Content:isAbsolutePath(path) then -- 251
		return false -- 252
	end -- 252
	if __TS__StringIncludes(path, "..") then -- 252
		return false -- 253
	end -- 253
	return true -- 254
end -- 250
local function isValidWorkDir(workDir) -- 257
	if not workDir or #workDir == 0 then -- 257
		return false -- 258
	end -- 258
	if not Content:isAbsolutePath(workDir) then -- 258
		return false -- 259
	end -- 259
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 259
		return false -- 260
	end -- 260
	return true -- 261
end -- 257
local function isValidSearchPath(path) -- 264
	if path == "" then -- 264
		return true -- 265
	end -- 265
	if Content:isAbsolutePath(path) then -- 265
		return false -- 266
	end -- 266
	if not path or #path == 0 then -- 266
		return false -- 267
	end -- 267
	if __TS__StringIncludes(path, "..") then -- 267
		return false -- 268
	end -- 268
	return true -- 269
end -- 264
local function resolveWorkspaceFilePath(workDir, path) -- 272
	if not isValidWorkDir(workDir) then -- 272
		return nil -- 273
	end -- 273
	if not isValidWorkspacePath(path) then -- 273
		return nil -- 274
	end -- 274
	return Path(workDir, path) -- 275
end -- 272
local function resolveWorkspaceSearchPath(workDir, path) -- 278
	if not isValidWorkDir(workDir) then -- 278
		return nil -- 279
	end -- 279
	if not isValidSearchPath(path) then -- 279
		return nil -- 280
	end -- 280
	return path == "" and workDir or Path(workDir, path) -- 281
end -- 278
local function toWorkspaceRelativePath(workDir, path) -- 284
	if not path or #path == 0 then -- 284
		return path -- 285
	end -- 285
	if not Content:isAbsolutePath(path) then -- 285
		return path -- 286
	end -- 286
	return Path:getRelative(path, workDir) -- 287
end -- 284
local function toWorkspaceRelativeFileList(workDir, files) -- 290
	return __TS__ArrayMap( -- 291
		files, -- 291
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 291
	) -- 291
end -- 290
local function toWorkspaceRelativeSearchResults(workDir, results) -- 294
	local mapped = {} -- 295
	do -- 295
		local i = 0 -- 296
		while i < #results do -- 296
			local row = results[i + 1] -- 297
			local clone = __TS__ObjectAssign({}, row) -- 298
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 299
			mapped[#mapped + 1] = clone -- 300
			i = i + 1 -- 296
		end -- 296
	end -- 296
	return mapped -- 302
end -- 294
local function getDoraAPIDocRoot(docLanguage) -- 305
	local zhDir = Path( -- 306
		Content.assetPath, -- 306
		"Script", -- 306
		"Lib", -- 306
		"Dora", -- 306
		"zh-Hans" -- 306
	) -- 306
	local enDir = Path( -- 307
		Content.assetPath, -- 307
		"Script", -- 307
		"Lib", -- 307
		"Dora", -- 307
		"en" -- 307
	) -- 307
	return docLanguage == "zh" and zhDir or enDir -- 308
end -- 305
local function getDoraTutorialDocRoot(docLanguage) -- 311
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 312
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 313
	return docLanguage == "zh" and zhDir or enDir -- 314
end -- 311
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 317
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 317
		return {"ts"} -- 319
	end -- 319
	return {"tl"} -- 321
end -- 317
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 324
	repeat -- 324
		local ____switch38 = programmingLanguage -- 324
		local ____cond38 = ____switch38 == "teal" -- 324
		if ____cond38 then -- 324
			return "tl" -- 326
		end -- 326
		____cond38 = ____cond38 or ____switch38 == "tl" -- 326
		if ____cond38 then -- 326
			return "tl" -- 327
		end -- 327
		do -- 327
			return programmingLanguage -- 328
		end -- 328
	until true -- 328
end -- 324
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 332
	if docSource == "tutorial" then -- 332
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 338
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 339
		return { -- 340
			root = Path(tutorialRoot, langDir), -- 341
			exts = {"md"}, -- 342
			globs = {"**/*.md"} -- 343
		} -- 343
	end -- 343
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 346
	return { -- 347
		root = getDoraAPIDocRoot(docLanguage), -- 348
		exts = exts, -- 349
		globs = __TS__ArrayMap( -- 350
			exts, -- 350
			function(____, ext) return "**/*." .. ext end -- 350
		) -- 350
	} -- 350
end -- 332
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 354
	if docSource == "tutorial" then -- 354
		return getDoraTutorialDocRoot(docLanguage) -- 356
	end -- 356
	return getDoraAPIDocRoot(docLanguage) -- 358
end -- 354
local function toDocRelativePath(baseRoot, path) -- 361
	if not path or #path == 0 then -- 361
		return path -- 362
	end -- 362
	if not Content:isAbsolutePath(path) then -- 362
		return path -- 363
	end -- 363
	return Path:getRelative(path, baseRoot) -- 364
end -- 361
local function resolveAgentTutorialDocFilePath(path, docLanguage) -- 367
	if not docLanguage then -- 367
		return nil -- 368
	end -- 368
	if not isValidWorkspacePath(path) then -- 368
		return nil -- 369
	end -- 369
	local candidate = Path( -- 370
		getDoraTutorialDocRoot(docLanguage), -- 370
		path -- 370
	) -- 370
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 370
		return candidate -- 372
	end -- 372
	return nil -- 374
end -- 367
local function ensureDirPath(dir) -- 377
	if not dir or dir == "." or dir == "" then -- 377
		return true -- 378
	end -- 378
	if Content:exist(dir) then -- 378
		return Content:isdir(dir) -- 379
	end -- 379
	local parent = Path:getPath(dir) -- 380
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 380
		if not ensureDirPath(parent) then -- 380
			return false -- 382
		end -- 382
	end -- 382
	return Content:mkdir(dir) -- 384
end -- 377
local function ensureDirForFile(path) -- 387
	local dir = Path:getPath(path) -- 388
	return ensureDirPath(dir) -- 389
end -- 387
local function getFileState(path) -- 392
	local exists = Content:exist(path) -- 393
	if not exists then -- 393
		return {exists = false, content = "", bytes = 0} -- 395
	end -- 395
	local content = Content:load(path) -- 401
	return {exists = true, content = content, bytes = #content} -- 402
end -- 392
local function inspectReadableFile(path) -- 409
	do -- 409
		local function ____catch(e) -- 409
			Log( -- 431
				"Warn", -- 431
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 431
			) -- 431
			return true, {success = true} -- 432
		end -- 432
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 432
			local size, isBinary = Content:getAttr(path) -- 411
			if size == nil then -- 411
				return true, {success = false, message = "failed to read file"} -- 413
			end -- 413
			if isBinary then -- 413
				return true, { -- 419
					success = false, -- 420
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 421
					size = type(size) == "number" and size or nil, -- 422
					isBinary = true -- 423
				} -- 423
			end -- 423
			return true, { -- 426
				success = true, -- 427
				size = type(size) == "number" and size or nil -- 428
			} -- 428
		end) -- 428
		if not ____try then -- 428
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 428
		end -- 428
		if ____hasReturned then -- 428
			return ____returnValue -- 410
		end -- 410
	end -- 410
end -- 409
local function isEngineLogFilePath(path) -- 436
	return path == ENGINE_LOG_FILE -- 437
end -- 436
local function readEngineLogFile(path) -- 440
	if not isEngineLogFilePath(path) then -- 440
		return nil -- 441
	end -- 441
	local content = getEngineLogText() -- 442
	if content == nil then -- 442
		return {success = false, message = "failed to read engine logs"} -- 444
	end -- 444
	return {success = true, content = content, size = #content} -- 446
end -- 440
local function queryOne(sql, args) -- 449
	local ____args_0 -- 450
	if args then -- 450
		____args_0 = DB:query(sql, args) -- 450
	else -- 450
		____args_0 = DB:query(sql) -- 450
	end -- 450
	local rows = ____args_0 -- 450
	if not rows or #rows == 0 then -- 450
		return nil -- 451
	end -- 451
	return rows[1] -- 452
end -- 449
do -- 449
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 457
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 465
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 476
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 477
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 490
end -- 490
local function isDtsFile(path) -- 493
	return Path:getExt(Path:getName(path)) == "d" -- 494
end -- 493
local function isTiledEditorContent(content) -- 497
	return __TS__StringStartsWith( -- 498
		__TS__StringTrim(content), -- 498
		"<?xml" -- 498
	) -- 498
end -- 497
local function getSupportedBuildKind(path) -- 503
	repeat -- 503
		local ____switch74 = Path:getExt(path) -- 503
		local ____cond74 = ____switch74 == "ts" or ____switch74 == "tsx" -- 503
		if ____cond74 then -- 503
			return "ts" -- 505
		end -- 505
		____cond74 = ____cond74 or ____switch74 == "xml" -- 505
		if ____cond74 then -- 505
			return "xml" -- 506
		end -- 506
		____cond74 = ____cond74 or ____switch74 == "tl" -- 506
		if ____cond74 then -- 506
			return "teal" -- 507
		end -- 507
		____cond74 = ____cond74 or ____switch74 == "lua" -- 507
		if ____cond74 then -- 507
			return "lua" -- 508
		end -- 508
		____cond74 = ____cond74 or ____switch74 == "yue" -- 508
		if ____cond74 then -- 508
			return "yue" -- 509
		end -- 509
		____cond74 = ____cond74 or ____switch74 == "yarn" -- 509
		if ____cond74 then -- 509
			return "yarn" -- 510
		end -- 510
		do -- 510
			return nil -- 511
		end -- 511
	until true -- 511
end -- 503
local function getTaskHeadSeq(taskId) -- 515
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 516
	if not row then -- 516
		return nil -- 517
	end -- 517
	return row[1] or 0 -- 518
end -- 515
local function getTaskStatus(taskId) -- 521
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 522
	if not row then -- 522
		return nil -- 523
	end -- 523
	return toStr(row[1]) -- 524
end -- 521
local function getLastInsertRowId() -- 527
	local row = queryOne("SELECT last_insert_rowid()") -- 528
	return row and (row[1] or 0) or 0 -- 529
end -- 527
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 532
	DB:exec( -- 533
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 533
		{ -- 535
			taskId, -- 535
			seq, -- 535
			status, -- 535
			summary, -- 535
			toolName, -- 535
			now() -- 535
		} -- 535
	) -- 535
	return getLastInsertRowId() -- 537
end -- 532
local function getCheckpointEntries(checkpointId, desc) -- 540
	if desc == nil then -- 540
		desc = false -- 540
	end -- 540
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 541
	if not rows then -- 541
		return {} -- 548
	end -- 548
	local result = {} -- 549
	do -- 549
		local i = 0 -- 550
		while i < #rows do -- 550
			local row = rows[i + 1] -- 551
			result[#result + 1] = { -- 552
				id = row[1], -- 553
				ord = row[2], -- 554
				path = toStr(row[3]), -- 555
				op = toStr(row[4]), -- 556
				beforeExists = toBool(row[5]), -- 557
				beforeContent = toStr(row[6]), -- 558
				afterExists = toBool(row[7]), -- 559
				afterContent = toStr(row[8]) -- 560
			} -- 560
			i = i + 1 -- 550
		end -- 550
	end -- 550
	return result -- 563
end -- 540
local function rejectDuplicatePaths(changes) -- 566
	local seen = __TS__New(Set) -- 567
	for ____, change in ipairs(changes) do -- 568
		local key = change.path -- 569
		if seen:has(key) then -- 569
			return key -- 570
		end -- 570
		seen:add(key) -- 571
	end -- 571
	return nil -- 573
end -- 566
local function getLinkedDeletePaths(workDir, path) -- 576
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 577
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 577
		return {} -- 578
	end -- 578
	local parent = Path:getPath(fullPath) -- 579
	local baseName = string.lower(Path:getName(fullPath)) -- 580
	local ext = Path:getExt(fullPath) -- 581
	local linked = {} -- 582
	for ____, file in ipairs(Content:getFiles(parent)) do -- 583
		do -- 583
			if string.lower(Path:getName(file)) ~= baseName then -- 583
				goto __continue91 -- 584
			end -- 584
			local siblingExt = Path:getExt(file) -- 585
			if siblingExt == "tl" and ext == "vs" then -- 585
				linked[#linked + 1] = toWorkspaceRelativePath( -- 587
					workDir, -- 587
					Path(parent, file) -- 587
				) -- 587
				goto __continue91 -- 588
			end -- 588
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 588
				linked[#linked + 1] = toWorkspaceRelativePath( -- 591
					workDir, -- 591
					Path(parent, file) -- 591
				) -- 591
			end -- 591
		end -- 591
		::__continue91:: -- 591
	end -- 591
	return linked -- 594
end -- 576
local function expandLinkedDeleteChanges(workDir, changes) -- 597
	local expanded = {} -- 598
	local seen = __TS__New(Set) -- 599
	do -- 599
		local i = 0 -- 600
		while i < #changes do -- 600
			do -- 600
				local change = changes[i + 1] -- 601
				if not seen:has(change.path) then -- 601
					seen:add(change.path) -- 603
					expanded[#expanded + 1] = change -- 604
				end -- 604
				if change.op ~= "delete" then -- 604
					goto __continue98 -- 606
				end -- 606
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 607
				do -- 607
					local j = 0 -- 608
					while j < #linkedPaths do -- 608
						do -- 608
							local linkedPath = linkedPaths[j + 1] -- 609
							if seen:has(linkedPath) then -- 609
								goto __continue102 -- 610
							end -- 610
							seen:add(linkedPath) -- 611
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 612
						end -- 612
						::__continue102:: -- 612
						j = j + 1 -- 608
					end -- 608
				end -- 608
			end -- 608
			::__continue98:: -- 608
			i = i + 1 -- 600
		end -- 600
	end -- 600
	return expanded -- 615
end -- 597
local function applySingleFile(path, exists, content) -- 618
	if exists then -- 618
		if not ensureDirForFile(path) then -- 618
			return false -- 620
		end -- 620
		return Content:save(path, content) -- 621
	end -- 621
	if Content:exist(path) then -- 621
		return Content:remove(path) -- 624
	end -- 624
	return true -- 626
end -- 618
local function encodeJSON(obj) -- 629
	local text = safeJsonEncode(obj) -- 630
	return text -- 631
end -- 629
local function pauseBetweenTsTranspiles() -- 634
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 634
		__TS__Await(__TS__New( -- 635
			__TS__Promise, -- 635
			function(____, resolve) -- 635
				Director.systemScheduler:schedule(once(function() -- 636
					sleep(BUILD_TS_TRANSPILE_PAUSE_SECONDS) -- 637
					resolve(nil) -- 638
				end)) -- 636
			end -- 635
		)) -- 635
	end) -- 635
end -- 634
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 643
	if HttpServer.wsConnectionCount == 0 then -- 643
		return true -- 645
	end -- 645
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 647
	if not payload then -- 647
		return false -- 649
	end -- 649
	emit("AppWS", "Send", payload) -- 651
	return true -- 652
end -- 643
local function runSingleNonTsBuild(file) -- 655
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 655
		return ____awaiter_resolve( -- 655
			nil, -- 655
			__TS__New( -- 656
				__TS__Promise, -- 656
				function(____, resolve) -- 656
					local moduleName = "Script.Dev.WebServer" -- 657
					local ____require_result_1 = require(moduleName) -- 658
					local buildAsync = ____require_result_1.buildAsync -- 658
					Director.systemScheduler:schedule(once(function() -- 659
						local result = buildAsync(file) -- 660
						resolve(nil, result) -- 661
					end)) -- 659
				end -- 656
			) -- 656
		) -- 656
	end) -- 656
end -- 655
local transpileRequestSeq = 0 -- 666
local tsTranspileQueueTail = __TS__Promise.resolve() -- 667
local tsTranspileQueuedCount = 0 -- 668
local function runWithTsTranspileLock(task) -- 670
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 670
		local previous = tsTranspileQueueTail -- 671
		local function release() -- 672
		end -- 672
		tsTranspileQueueTail = __TS__New( -- 673
			__TS__Promise, -- 673
			function(____, resolve) -- 673
				release = function() return resolve(nil) end -- 674
			end -- 673
		) -- 673
		tsTranspileQueuedCount = tsTranspileQueuedCount + 1 -- 676
		if tsTranspileQueuedCount > 1 then -- 676
			Log( -- 678
				"Info", -- 678
				"[build] waiting for TS transpile queue pending=" .. tostring(tsTranspileQueuedCount - 1) -- 678
			) -- 678
		end -- 678
		__TS__Await(previous) -- 680
		local ____hasReturned, ____returnValue -- 680
		local ____try = __TS__AsyncAwaiter(function() -- 680
			____hasReturned = true -- 682
			____returnValue = __TS__Await(task()) -- 682
			return -- 682
		end) -- 682
		____try = ____try.finally( -- 682
			____try, -- 682
			function() -- 682
				return __TS__AsyncAwaiter(function() -- 682
					tsTranspileQueuedCount = math.max(0, tsTranspileQueuedCount - 1) -- 684
					release() -- 685
				end) -- 685
			end -- 685
		) -- 685
		__TS__Await(____try) -- 681
		if ____hasReturned then -- 681
			return ____awaiter_resolve(nil, ____returnValue) -- 681
		end -- 681
	end) -- 681
end -- 670
local function runSingleTsTranspileUnlocked(file, content) -- 689
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 689
		local done = false -- 690
		transpileRequestSeq = transpileRequestSeq + 1 -- 691
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 692
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 693
		if HttpServer.wsConnectionCount == 0 then -- 693
			return ____awaiter_resolve(nil, result) -- 693
		end -- 693
		local listener = Node() -- 701
		listener:gslot( -- 702
			"AppWS", -- 702
			function(event) -- 702
				if event.type ~= "Receive" then -- 702
					return -- 703
				end -- 703
				local res = safeJsonDecode(event.msg) -- 704
				if not res or __TS__ArrayIsArray(res) then -- 704
					return -- 705
				end -- 705
				local payload = res -- 706
				if payload.name ~= "TranspileTS" then -- 706
					return -- 707
				end -- 707
				if payload.id ~= requestId then -- 707
					return -- 708
				end -- 708
				if tostring(payload.file) ~= file then -- 708
					return -- 709
				end -- 709
				if payload.success then -- 709
					local luaFile = Path:replaceExt(file, "lua") -- 711
					if Content:save( -- 711
						luaFile, -- 712
						tostring(payload.luaCode) -- 712
					) then -- 712
						result = {success = true, file = file} -- 713
					else -- 713
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 715
					end -- 715
				else -- 715
					result = { -- 718
						success = false, -- 718
						file = file, -- 718
						message = tostring(payload.message) -- 718
					} -- 718
				end -- 718
				done = true -- 720
			end -- 702
		) -- 702
		local payload = encodeJSON({name = "TranspileTS", id = requestId, file = file, content = content}) -- 722
		if not payload then -- 722
			listener:removeFromParent() -- 729
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 729
		end -- 729
		__TS__Await(__TS__New( -- 732
			__TS__Promise, -- 732
			function(____, resolve) -- 732
				Director.systemScheduler:schedule(once(function() -- 733
					emit("AppWS", "Send", payload) -- 734
					wait(function() return done end) -- 735
					if not done then -- 735
						listener:removeFromParent() -- 737
					end -- 737
					resolve(nil) -- 739
				end)) -- 733
			end -- 732
		)) -- 732
		return ____awaiter_resolve(nil, result) -- 732
	end) -- 732
end -- 689
function ____exports.runSingleTsTranspile(file, content) -- 745
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 745
		return ____awaiter_resolve( -- 745
			nil, -- 745
			runWithTsTranspileLock(function() return runSingleTsTranspileUnlocked(file, content) end) -- 746
		) -- 746
	end) -- 746
end -- 745
function ____exports.createTask(prompt) -- 749
	if prompt == nil then -- 749
		prompt = "" -- 749
	end -- 749
	local t = now() -- 750
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 751
	if affected <= 0 then -- 751
		return {success = false, message = "failed to create task"} -- 756
	end -- 756
	return { -- 758
		success = true, -- 758
		taskId = getLastInsertRowId() -- 758
	} -- 758
end -- 749
function ____exports.setTaskStatus(taskId, status) -- 761
	DB:exec( -- 762
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 762
		{ -- 762
			status, -- 762
			now(), -- 762
			taskId -- 762
		} -- 762
	) -- 762
	Log( -- 763
		"Info", -- 763
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 763
	) -- 763
end -- 761
function ____exports.listCheckpoints(taskId) -- 766
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 767
	if not rows then -- 767
		return {} -- 774
	end -- 774
	local items = {} -- 775
	do -- 775
		local i = 0 -- 776
		while i < #rows do -- 776
			local row = rows[i + 1] -- 777
			items[#items + 1] = { -- 778
				id = row[1], -- 779
				taskId = row[2], -- 780
				seq = row[3], -- 781
				status = toStr(row[4]), -- 782
				summary = toStr(row[5]), -- 783
				toolName = toStr(row[6]), -- 784
				createdAt = row[7] -- 785
			} -- 785
			i = i + 1 -- 776
		end -- 776
	end -- 776
	return items -- 788
end -- 766
local function listCheckpointIdsForTask(taskId, desc) -- 791
	if desc == nil then -- 791
		desc = false -- 791
	end -- 791
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 792
	if not rows then -- 792
		return {} -- 799
	end -- 799
	local items = {} -- 800
	do -- 800
		local i = 0 -- 801
		while i < #rows do -- 801
			local row = rows[i + 1] -- 802
			items[#items + 1] = {id = row[1], seq = row[2]} -- 803
			i = i + 1 -- 801
		end -- 801
	end -- 801
	return items -- 808
end -- 791
local function deriveFileOp(beforeExists, afterExists) -- 811
	if not beforeExists and afterExists then -- 811
		return "create" -- 812
	end -- 812
	if beforeExists and not afterExists then -- 812
		return "delete" -- 813
	end -- 813
	return "write" -- 814
end -- 811
function ____exports.summarizeTaskChangeSet(taskId) -- 817
	if not getTaskStatus(taskId) then -- 817
		return {success = false, message = "task not found"} -- 819
	end -- 819
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 821
	local filesByPath = {} -- 822
	local latestCheckpointId = nil -- 828
	local latestCheckpointSeq = nil -- 829
	do -- 829
		local i = 0 -- 830
		while i < #checkpoints do -- 830
			local checkpoint = checkpoints[i + 1] -- 831
			latestCheckpointId = checkpoint.id -- 832
			latestCheckpointSeq = checkpoint.seq -- 833
			local entries = getCheckpointEntries(checkpoint.id, false) -- 834
			do -- 834
				local j = 0 -- 835
				while j < #entries do -- 835
					local entry = entries[j + 1] -- 836
					local item = filesByPath[entry.path] -- 837
					if not item then -- 837
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 839
						filesByPath[entry.path] = item -- 845
					end -- 845
					item.afterExists = entry.afterExists -- 847
					local ____item_checkpointIds_2 = item.checkpointIds -- 847
					____item_checkpointIds_2[#____item_checkpointIds_2 + 1] = checkpoint.id -- 848
					j = j + 1 -- 835
				end -- 835
			end -- 835
			i = i + 1 -- 830
		end -- 830
	end -- 830
	local files = {} -- 851
	for ____, item in pairs(filesByPath) do -- 852
		files[#files + 1] = { -- 853
			path = item.path, -- 854
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 855
			checkpointCount = #item.checkpointIds, -- 856
			checkpointIds = item.checkpointIds -- 857
		} -- 857
	end -- 857
	__TS__ArraySort( -- 860
		files, -- 860
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 860
	) -- 860
	return { -- 861
		success = true, -- 862
		taskId = taskId, -- 863
		checkpointCount = #checkpoints, -- 864
		filesChanged = #files, -- 865
		files = files, -- 866
		latestCheckpointId = latestCheckpointId, -- 867
		latestCheckpointSeq = latestCheckpointSeq -- 868
	} -- 868
end -- 817
function ____exports.getTaskChangeSetDiff(taskId) -- 872
	if not getTaskStatus(taskId) then -- 872
		return {success = false, message = "task not found"} -- 874
	end -- 874
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 876
	if #checkpoints == 0 then -- 876
		return {success = false, message = "change set not found or empty"} -- 878
	end -- 878
	local filesByPath = {} -- 880
	do -- 880
		local i = 0 -- 887
		while i < #checkpoints do -- 887
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 888
			do -- 888
				local j = 0 -- 889
				while j < #entries do -- 889
					local entry = entries[j + 1] -- 890
					local item = filesByPath[entry.path] -- 891
					if not item then -- 891
						item = { -- 893
							path = entry.path, -- 894
							beforeExists = entry.beforeExists, -- 895
							beforeContent = entry.beforeContent, -- 896
							afterExists = entry.afterExists, -- 897
							afterContent = entry.afterContent -- 898
						} -- 898
						filesByPath[entry.path] = item -- 900
					end -- 900
					item.afterExists = entry.afterExists -- 902
					item.afterContent = entry.afterContent -- 903
					j = j + 1 -- 889
				end -- 889
			end -- 889
			i = i + 1 -- 887
		end -- 887
	end -- 887
	local files = {} -- 906
	for ____, item in pairs(filesByPath) do -- 907
		files[#files + 1] = { -- 908
			path = item.path, -- 909
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 910
			beforeExists = item.beforeExists, -- 911
			afterExists = item.afterExists, -- 912
			beforeContent = item.beforeContent, -- 913
			afterContent = item.afterContent -- 914
		} -- 914
	end -- 914
	__TS__ArraySort( -- 917
		files, -- 917
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 917
	) -- 917
	return {success = true, files = files} -- 918
end -- 872
local function readWorkspaceFile(workDir, path, docLanguage) -- 921
	local engineLog = readEngineLogFile(path) -- 922
	if engineLog then -- 922
		return engineLog -- 923
	end -- 923
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 924
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 924
		local attr = inspectReadableFile(fullPath) -- 926
		if not attr.success then -- 926
			return attr -- 927
		end -- 927
		return { -- 928
			success = true, -- 928
			content = Content:load(fullPath), -- 928
			size = attr.size -- 928
		} -- 928
	end -- 928
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 930
	if docPath then -- 930
		local attr = inspectReadableFile(docPath) -- 932
		if not attr.success then -- 932
			return attr -- 933
		end -- 933
		return { -- 934
			success = true, -- 934
			content = Content:load(docPath), -- 934
			size = attr.size -- 934
		} -- 934
	end -- 934
	if not fullPath then -- 934
		return {success = false, message = "invalid path or workDir"} -- 936
	end -- 936
	return {success = false, message = "file not found"} -- 937
end -- 921
function ____exports.readFileRaw(workDir, path, docLanguage) -- 940
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 941
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 941
		local attr = inspectReadableFile(path) -- 943
		if not attr.success then -- 943
			return attr -- 944
		end -- 944
		return { -- 945
			success = true, -- 945
			content = Content:load(path), -- 945
			size = attr.size -- 945
		} -- 945
	end -- 945
	return result -- 947
end -- 940
function ____exports.getLogs(req) -- 962
	local text = getEngineLogText() -- 963
	if text == nil then -- 963
		return {success = false, message = "failed to read engine logs"} -- 965
	end -- 965
	local tailLines = math.max( -- 967
		1, -- 967
		math.floor(req and req.tailLines or 200) -- 967
	) -- 967
	local allLines = __TS__StringSplit(text, "\n") -- 968
	local logs = __TS__ArraySlice( -- 969
		allLines, -- 969
		math.max(0, #allLines - tailLines) -- 969
	) -- 969
	return req and req.joinText and ({ -- 970
		success = true, -- 970
		logs = logs, -- 970
		text = table.concat(logs, "\n") -- 970
	}) or ({success = true, logs = logs}) -- 970
end -- 962
function ____exports.listFiles(req) -- 973
	local root = req.path or "" -- 979
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 980
	if not searchRoot then -- 980
		return {success = false, message = "invalid path or workDir"} -- 982
	end -- 982
	do -- 982
		local function ____catch(e) -- 982
			return true, { -- 1000
				success = false, -- 1000
				message = tostring(e) -- 1000
			} -- 1000
		end -- 1000
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1000
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 985
			local globs = ensureSafeSearchGlobs(userGlobs) -- 986
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 987
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 988
			local totalEntries = #files -- 989
			local maxEntries = math.max( -- 990
				1, -- 990
				math.floor(req.maxEntries or 200) -- 990
			) -- 990
			local truncated = totalEntries > maxEntries -- 991
			return true, { -- 992
				success = true, -- 993
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 994
				totalEntries = totalEntries, -- 995
				truncated = truncated, -- 996
				maxEntries = maxEntries -- 997
			} -- 997
		end) -- 997
		if not ____try then -- 997
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 997
		end -- 997
		if ____hasReturned then -- 997
			return ____returnValue -- 984
		end -- 984
	end -- 984
end -- 973
local function formatReadSlice(content, startLine, endLine) -- 1004
	local lines = __TS__StringSplit(content, "\n") -- 1009
	local totalLines = #lines -- 1010
	if totalLines == 0 then -- 1010
		return { -- 1012
			success = true, -- 1013
			content = "", -- 1014
			totalLines = 0, -- 1015
			startLine = 1, -- 1016
			endLine = 0, -- 1017
			truncated = false -- 1018
		} -- 1018
	end -- 1018
	local rawStart = math.floor(startLine) -- 1021
	local rawEnd = math.floor(endLine) -- 1022
	if rawStart == 0 then -- 1022
		return {success = false, message = "startLine cannot be 0"} -- 1024
	end -- 1024
	if rawEnd == 0 then -- 1024
		return {success = false, message = "endLine cannot be 0"} -- 1027
	end -- 1027
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1029
	if start > totalLines then -- 1029
		return { -- 1033
			success = false, -- 1033
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1033
		} -- 1033
	end -- 1033
	local ____end = math.min( -- 1035
		totalLines, -- 1036
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1037
	) -- 1037
	if ____end < start then -- 1037
		return { -- 1042
			success = false, -- 1043
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1044
		} -- 1044
	end -- 1044
	local slice = {} -- 1047
	do -- 1047
		local i = start -- 1048
		while i <= ____end do -- 1048
			slice[#slice + 1] = lines[i] -- 1049
			i = i + 1 -- 1048
		end -- 1048
	end -- 1048
	local truncated = start > 1 or ____end < totalLines -- 1051
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1052
	local body = table.concat(slice, "\n") -- 1057
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1058
	return { -- 1059
		success = true, -- 1060
		content = output, -- 1061
		totalLines = totalLines, -- 1062
		startLine = start, -- 1063
		endLine = ____end, -- 1064
		truncated = truncated -- 1065
	} -- 1065
end -- 1004
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1069
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1076
	if not fallback.success or fallback.content == nil then -- 1076
		return fallback -- 1077
	end -- 1077
	local resolvedStartLine = startLine or 1 -- 1078
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1079
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1080
end -- 1069
local codeExtensions = { -- 1087
	".lua", -- 1087
	".tl", -- 1087
	".yue", -- 1087
	".ts", -- 1087
	".tsx", -- 1087
	".xml", -- 1087
	".md", -- 1087
	".yarn", -- 1087
	".wa", -- 1087
	".mod" -- 1087
} -- 1087
extensionLevels = { -- 1088
	vs = 2, -- 1089
	bl = 2, -- 1090
	ts = 1, -- 1091
	tsx = 1, -- 1092
	tl = 1, -- 1093
	yue = 1, -- 1094
	xml = 1, -- 1095
	lua = 0 -- 1096
} -- 1096
local function splitSearchPatterns(pattern) -- 1113
	local trimmed = __TS__StringTrim(pattern or "") -- 1114
	if trimmed == "" then -- 1114
		return {} -- 1115
	end -- 1115
	local out = {} -- 1116
	local seen = __TS__New(Set) -- 1117
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1118
		local p = __TS__StringTrim(tostring(p0)) -- 1119
		if p ~= "" and not seen:has(p) then -- 1119
			seen:add(p) -- 1121
			out[#out + 1] = p -- 1122
		end -- 1122
	end -- 1122
	return out -- 1125
end -- 1113
local function mergeSearchFileResultsUnique(resultsList) -- 1128
	local merged = {} -- 1129
	local seen = __TS__New(Set) -- 1130
	do -- 1130
		local i = 0 -- 1131
		while i < #resultsList do -- 1131
			local list = resultsList[i + 1] -- 1132
			do -- 1132
				local j = 0 -- 1133
				while j < #list do -- 1133
					do -- 1133
						local row = list[j + 1] -- 1134
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1135
						if seen:has(key) then -- 1135
							goto __continue219 -- 1136
						end -- 1136
						seen:add(key) -- 1137
						merged[#merged + 1] = list[j + 1] -- 1138
					end -- 1138
					::__continue219:: -- 1138
					j = j + 1 -- 1133
				end -- 1133
			end -- 1133
			i = i + 1 -- 1131
		end -- 1131
	end -- 1131
	return merged -- 1141
end -- 1128
local function buildGroupedSearchResults(results) -- 1144
	local order = {} -- 1149
	local grouped = __TS__New(Map) -- 1150
	do -- 1150
		local i = 0 -- 1155
		while i < #results do -- 1155
			local row = results[i + 1] -- 1156
			local file = row.file -- 1157
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1158
			local bucket = grouped:get(key) -- 1159
			if not bucket then -- 1159
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1161
				grouped:set(key, bucket) -- 1162
				order[#order + 1] = key -- 1163
			end -- 1163
			bucket.totalMatches = bucket.totalMatches + 1 -- 1165
			local ____bucket_matches_7 = bucket.matches -- 1165
			____bucket_matches_7[#____bucket_matches_7 + 1] = results[i + 1] -- 1166
			i = i + 1 -- 1155
		end -- 1155
	end -- 1155
	local out = {} -- 1168
	do -- 1168
		local i = 0 -- 1173
		while i < #order do -- 1173
			local bucket = grouped:get(order[i + 1]) -- 1174
			if bucket then -- 1174
				out[#out + 1] = bucket -- 1175
			end -- 1175
			i = i + 1 -- 1173
		end -- 1173
	end -- 1173
	return out -- 1177
end -- 1144
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1180
	local merged = {} -- 1181
	local seen = __TS__New(Set) -- 1182
	local index = 0 -- 1183
	local advanced = true -- 1184
	while advanced do -- 1184
		advanced = false -- 1186
		do -- 1186
			local i = 0 -- 1187
			while i < #resultsList do -- 1187
				do -- 1187
					local list = resultsList[i + 1] -- 1188
					if index >= #list then -- 1188
						goto __continue231 -- 1189
					end -- 1189
					advanced = true -- 1190
					local row = list[index + 1] -- 1191
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1192
					if seen:has(key) then -- 1192
						goto __continue231 -- 1193
					end -- 1193
					seen:add(key) -- 1194
					merged[#merged + 1] = row -- 1195
				end -- 1195
				::__continue231:: -- 1195
				i = i + 1 -- 1187
			end -- 1187
		end -- 1187
		index = index + 1 -- 1197
	end -- 1197
	return merged -- 1199
end -- 1180
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1202
	if docSource ~= "api" then -- 1202
		return 100 -- 1203
	end -- 1203
	if programmingLanguage ~= "tsx" then -- 1203
		return 100 -- 1204
	end -- 1204
	repeat -- 1204
		local ____switch237 = string.lower(Path:getFilename(file)) -- 1204
		local ____cond237 = ____switch237 == "jsx.d.ts" -- 1204
		if ____cond237 then -- 1204
			return 0 -- 1206
		end -- 1206
		____cond237 = ____cond237 or ____switch237 == "dorax.d.ts" -- 1206
		if ____cond237 then -- 1206
			return 1 -- 1207
		end -- 1207
		____cond237 = ____cond237 or ____switch237 == "dora.d.ts" -- 1207
		if ____cond237 then -- 1207
			return 2 -- 1208
		end -- 1208
		do -- 1208
			return 100 -- 1209
		end -- 1209
	until true -- 1209
end -- 1202
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1213
	local sorted = __TS__ArraySlice(hits) -- 1218
	__TS__ArraySort( -- 1219
		sorted, -- 1219
		function(____, a, b) -- 1219
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1220
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1221
			if pa ~= pb then -- 1221
				return pa - pb -- 1222
			end -- 1222
			local fa = string.lower(a.file) -- 1223
			local fb = string.lower(b.file) -- 1224
			if fa ~= fb then -- 1224
				return fa < fb and -1 or 1 -- 1225
			end -- 1225
			return (a.line or 0) - (b.line or 0) -- 1226
		end -- 1219
	) -- 1219
	return sorted -- 1228
end -- 1213
function ____exports.searchFiles(req) -- 1231
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1231
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1244
		if not resolvedPath then -- 1244
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1244
		end -- 1244
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1248
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1249
		if not searchRoot then -- 1249
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1249
		end -- 1249
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1249
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1249
		end -- 1249
		local patterns = splitSearchPatterns(req.pattern) -- 1256
		if #patterns == 0 then -- 1256
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1256
		end -- 1256
		return ____awaiter_resolve( -- 1256
			nil, -- 1256
			__TS__New( -- 1260
				__TS__Promise, -- 1260
				function(____, resolve) -- 1260
					Director.systemScheduler:schedule(once(function() -- 1261
						do -- 1261
							local function ____catch(e) -- 1261
								resolve( -- 1303
									nil, -- 1303
									{ -- 1303
										success = false, -- 1303
										message = tostring(e) -- 1303
									} -- 1303
								) -- 1303
							end -- 1303
							local ____try, ____hasReturned = pcall(function() -- 1303
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1263
								local allResults = {} -- 1266
								do -- 1266
									local i = 0 -- 1267
									while i < #patterns do -- 1267
										local ____Content_12 = Content -- 1268
										local ____Content_searchFilesAsync_13 = Content.searchFilesAsync -- 1268
										local ____patterns_index_11 = patterns[i + 1] -- 1273
										local ____req_useRegex_8 = req.useRegex -- 1274
										if ____req_useRegex_8 == nil then -- 1274
											____req_useRegex_8 = false -- 1274
										end -- 1274
										local ____req_caseSensitive_9 = req.caseSensitive -- 1275
										if ____req_caseSensitive_9 == nil then -- 1275
											____req_caseSensitive_9 = false -- 1275
										end -- 1275
										local ____req_includeContent_10 = req.includeContent -- 1276
										if ____req_includeContent_10 == nil then -- 1276
											____req_includeContent_10 = true -- 1276
										end -- 1276
										allResults[#allResults + 1] = ____Content_searchFilesAsync_13( -- 1268
											____Content_12, -- 1268
											searchRoot, -- 1269
											codeExtensions, -- 1270
											extensionLevels, -- 1271
											searchGlobs, -- 1272
											____patterns_index_11, -- 1273
											____req_useRegex_8, -- 1274
											____req_caseSensitive_9, -- 1275
											____req_includeContent_10, -- 1276
											req.contentWindow or 120 -- 1277
										) -- 1277
										i = i + 1 -- 1267
									end -- 1267
								end -- 1267
								local results = mergeSearchFileResultsUnique(allResults) -- 1280
								local totalResults = #results -- 1281
								local limit = math.max( -- 1282
									1, -- 1282
									math.floor(req.limit or 20) -- 1282
								) -- 1282
								local offset = math.max( -- 1283
									0, -- 1283
									math.floor(req.offset or 0) -- 1283
								) -- 1283
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1284
								local nextOffset = offset + #paged -- 1285
								local hasMore = nextOffset < totalResults -- 1286
								local truncated = offset > 0 or hasMore -- 1287
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1288
								local groupByFile = req.groupByFile == true -- 1289
								resolve( -- 1290
									nil, -- 1290
									{ -- 1290
										success = true, -- 1291
										results = relativeResults, -- 1292
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1293
										totalResults = totalResults, -- 1294
										truncated = truncated, -- 1295
										limit = limit, -- 1296
										offset = offset, -- 1297
										nextOffset = nextOffset, -- 1298
										hasMore = hasMore, -- 1299
										groupByFile = groupByFile -- 1300
									} -- 1300
								) -- 1300
							end) -- 1300
							if not ____try then -- 1300
								____catch(____hasReturned) -- 1300
							end -- 1300
						end -- 1300
					end)) -- 1261
				end -- 1260
			) -- 1260
		) -- 1260
	end) -- 1260
end -- 1231
function ____exports.searchDoraAPI(req) -- 1309
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1309
		local pattern = __TS__StringTrim(req.pattern or "") -- 1320
		if pattern == "" then -- 1320
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1320
		end -- 1320
		local patterns = splitSearchPatterns(pattern) -- 1322
		if #patterns == 0 then -- 1322
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1322
		end -- 1322
		local docSource = req.docSource or "api" -- 1324
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1325
		local docRoot = target.root -- 1326
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1327
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1327
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1327
		end -- 1327
		local exts = target.exts -- 1331
		local dotExts = __TS__ArrayMap( -- 1332
			exts, -- 1332
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1332
		) -- 1332
		local globs = target.globs -- 1333
		local limit = math.max( -- 1334
			1, -- 1334
			math.floor(req.limit or 10) -- 1334
		) -- 1334
		return ____awaiter_resolve( -- 1334
			nil, -- 1334
			__TS__New( -- 1336
				__TS__Promise, -- 1336
				function(____, resolve) -- 1336
					Director.systemScheduler:schedule(once(function() -- 1337
						do -- 1337
							local function ____catch(e) -- 1337
								resolve( -- 1379
									nil, -- 1379
									{ -- 1379
										success = false, -- 1379
										message = tostring(e) -- 1379
									} -- 1379
								) -- 1379
							end -- 1379
							local ____try, ____hasReturned = pcall(function() -- 1379
								local allHits = {} -- 1339
								do -- 1339
									local p = 0 -- 1340
									while p < #patterns do -- 1340
										local ____Content_18 = Content -- 1341
										local ____Content_searchFilesAsync_19 = Content.searchFilesAsync -- 1341
										local ____array_17 = __TS__SparseArrayNew( -- 1341
											docRoot, -- 1342
											dotExts, -- 1343
											{}, -- 1344
											ensureSafeSearchGlobs(globs), -- 1345
											patterns[p + 1] -- 1346
										) -- 1346
										local ____req_useRegex_14 = req.useRegex -- 1347
										if ____req_useRegex_14 == nil then -- 1347
											____req_useRegex_14 = false -- 1347
										end -- 1347
										__TS__SparseArrayPush(____array_17, ____req_useRegex_14) -- 1347
										local ____req_caseSensitive_15 = req.caseSensitive -- 1348
										if ____req_caseSensitive_15 == nil then -- 1348
											____req_caseSensitive_15 = false -- 1348
										end -- 1348
										__TS__SparseArrayPush(____array_17, ____req_caseSensitive_15) -- 1348
										local ____req_includeContent_16 = req.includeContent -- 1349
										if ____req_includeContent_16 == nil then -- 1349
											____req_includeContent_16 = true -- 1349
										end -- 1349
										__TS__SparseArrayPush(____array_17, ____req_includeContent_16, req.contentWindow or 80) -- 1349
										local raw = ____Content_searchFilesAsync_19( -- 1341
											____Content_18, -- 1341
											__TS__SparseArraySpread(____array_17) -- 1341
										) -- 1341
										local hits = {} -- 1352
										do -- 1352
											local i = 0 -- 1353
											while i < #raw do -- 1353
												do -- 1353
													local row = raw[i + 1] -- 1354
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1355
													if file == "" then -- 1355
														goto __continue264 -- 1356
													end -- 1356
													hits[#hits + 1] = { -- 1357
														file = file, -- 1358
														line = type(row.line) == "number" and row.line or nil, -- 1359
														content = type(row.content) == "string" and row.content or nil -- 1360
													} -- 1360
												end -- 1360
												::__continue264:: -- 1360
												i = i + 1 -- 1353
											end -- 1353
										end -- 1353
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1363
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1363
											0, -- 1363
											limit -- 1363
										) -- 1363
										p = p + 1 -- 1340
									end -- 1340
								end -- 1340
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1365
								resolve(nil, { -- 1366
									success = true, -- 1367
									docSource = docSource, -- 1368
									docLanguage = req.docLanguage, -- 1369
									programmingLanguage = req.programmingLanguage, -- 1370
									exts = exts, -- 1371
									results = hits, -- 1372
									hint = "Use read_file directly with the file value from a search result to view the complete document. Do not add any prefixes.", -- 1373
									totalResults = #hits, -- 1374
									truncated = false, -- 1375
									limit = limit -- 1376
								}) -- 1376
							end) -- 1376
							if not ____try then -- 1376
								____catch(____hasReturned) -- 1376
							end -- 1376
						end -- 1376
					end)) -- 1337
				end -- 1336
			) -- 1336
		) -- 1336
	end) -- 1336
end -- 1309
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1385
	if options == nil then -- 1385
		options = {} -- 1385
	end -- 1385
	if #changes == 0 then -- 1385
		return {success = false, message = "empty changes"} -- 1387
	end -- 1387
	if not isValidWorkDir(workDir) then -- 1387
		return {success = false, message = "invalid workDir"} -- 1390
	end -- 1390
	if not getTaskStatus(taskId) then -- 1390
		return {success = false, message = "task not found"} -- 1393
	end -- 1393
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1395
	local dup = rejectDuplicatePaths(expandedChanges) -- 1396
	if dup then -- 1396
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1398
	end -- 1398
	for ____, change in ipairs(expandedChanges) do -- 1401
		if not isValidWorkspacePath(change.path) then -- 1401
			return {success = false, message = "invalid path: " .. change.path} -- 1403
		end -- 1403
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1403
			return {success = false, message = "missing content for " .. change.path} -- 1406
		end -- 1406
	end -- 1406
	local headSeq = getTaskHeadSeq(taskId) -- 1410
	if headSeq == nil then -- 1410
		return {success = false, message = "task not found"} -- 1411
	end -- 1411
	local nextSeq = headSeq + 1 -- 1412
	local checkpointId = insertCheckpoint( -- 1413
		taskId, -- 1413
		nextSeq, -- 1413
		options.summary or "", -- 1413
		options.toolName or "", -- 1413
		"PREPARED" -- 1413
	) -- 1413
	if checkpointId <= 0 then -- 1413
		return {success = false, message = "failed to create checkpoint"} -- 1415
	end -- 1415
	do -- 1415
		local i = 0 -- 1418
		while i < #expandedChanges do -- 1418
			local change = expandedChanges[i + 1] -- 1419
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1420
			if not fullPath then -- 1420
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1422
				return {success = false, message = "invalid path: " .. change.path} -- 1423
			end -- 1423
			local before = getFileState(fullPath) -- 1425
			local afterExists = change.op ~= "delete" -- 1426
			local afterContent = afterExists and (change.content or "") or "" -- 1427
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1428
				checkpointId, -- 1432
				i + 1, -- 1433
				change.path, -- 1434
				change.op, -- 1435
				before.exists and 1 or 0, -- 1436
				before.content, -- 1437
				afterExists and 1 or 0, -- 1438
				afterContent, -- 1439
				before.bytes, -- 1440
				#afterContent -- 1441
			}) -- 1441
			if inserted <= 0 then -- 1441
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1445
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1446
			end -- 1446
			i = i + 1 -- 1418
		end -- 1418
	end -- 1418
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1450
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1451
		if not fullPath then -- 1451
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1453
			return {success = false, message = "invalid path: " .. entry.path} -- 1454
		end -- 1454
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1456
		if not ok then -- 1456
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1458
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1459
		end -- 1459
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1459
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1462
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1463
		end -- 1463
	end -- 1463
	DB:exec( -- 1467
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1467
		{ -- 1469
			"APPLIED", -- 1469
			now(), -- 1469
			checkpointId -- 1469
		} -- 1469
	) -- 1469
	DB:exec( -- 1471
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1471
		{ -- 1473
			nextSeq, -- 1473
			now(), -- 1473
			taskId -- 1473
		} -- 1473
	) -- 1473
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1475
end -- 1385
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1483
	if not isValidWorkDir(workDir) then -- 1483
		return {success = false, message = "invalid workDir"} -- 1484
	end -- 1484
	if checkpointId <= 0 then -- 1484
		return {success = false, message = "invalid checkpointId"} -- 1485
	end -- 1485
	local entries = getCheckpointEntries(checkpointId, true) -- 1486
	if #entries == 0 then -- 1486
		return {success = false, message = "checkpoint not found or empty"} -- 1488
	end -- 1488
	for ____, entry in ipairs(entries) do -- 1490
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1491
		if not fullPath then -- 1491
			return {success = false, message = "invalid path: " .. entry.path} -- 1493
		end -- 1493
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1495
		if not ok then -- 1495
			Log( -- 1497
				"Error", -- 1497
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1497
			) -- 1497
			Log( -- 1498
				"Info", -- 1498
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1498
			) -- 1498
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1499
		end -- 1499
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1499
			Log( -- 1502
				"Error", -- 1502
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1502
			) -- 1502
			Log( -- 1503
				"Info", -- 1503
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1503
			) -- 1503
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1504
		end -- 1504
	end -- 1504
	DB:exec( -- 1507
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 1507
		{ -- 1507
			"REVERTED", -- 1507
			now(), -- 1507
			checkpointId -- 1507
		} -- 1507
	) -- 1507
	return {success = true, checkpointId = checkpointId} -- 1508
end -- 1483
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 1511
	if not isValidWorkDir(workDir) then -- 1511
		return {success = false, message = "invalid workDir"} -- 1512
	end -- 1512
	if not getTaskStatus(taskId) then -- 1512
		return {success = false, message = "task not found"} -- 1513
	end -- 1513
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 1514
	if #checkpoints == 0 then -- 1514
		return {success = false, message = "change set not found or empty"} -- 1516
	end -- 1516
	local lastCheckpointId = 0 -- 1518
	do -- 1518
		local i = 0 -- 1519
		while i < #checkpoints do -- 1519
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 1520
			if not result.success then -- 1520
				return {success = false, message = result.message} -- 1521
			end -- 1521
			lastCheckpointId = checkpoints[i + 1].id -- 1522
			i = i + 1 -- 1519
		end -- 1519
	end -- 1519
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 1524
end -- 1511
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1532
	return getCheckpointEntries(checkpointId, false) -- 1533
end -- 1532
function ____exports.getCheckpointDiff(checkpointId) -- 1536
	if checkpointId <= 0 then -- 1536
		return {success = false, message = "invalid checkpointId"} -- 1538
	end -- 1538
	local entries = getCheckpointEntries(checkpointId, false) -- 1540
	if #entries == 0 then -- 1540
		return {success = false, message = "checkpoint not found or empty"} -- 1542
	end -- 1542
	return { -- 1544
		success = true, -- 1545
		files = __TS__ArrayMap( -- 1546
			entries, -- 1546
			function(____, entry) return { -- 1546
				path = entry.path, -- 1547
				op = entry.op, -- 1548
				beforeExists = entry.beforeExists, -- 1549
				afterExists = entry.afterExists, -- 1550
				beforeContent = entry.beforeContent, -- 1551
				afterContent = entry.afterContent -- 1552
			} end -- 1552
		) -- 1552
	} -- 1552
end -- 1536
local function finalizeBuildResult(workDir, messages) -- 1557
	local normalized = __TS__ArrayMap( -- 1558
		messages, -- 1558
		function(____, m) return m.success and __TS__ObjectAssign( -- 1558
			{}, -- 1559
			m, -- 1559
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1559
		) or __TS__ObjectAssign( -- 1559
			{}, -- 1560
			m, -- 1560
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1560
		) end -- 1560
	) -- 1560
	local total = #normalized -- 1561
	local failed = 0 -- 1562
	do -- 1562
		local i = 0 -- 1563
		while i < #normalized do -- 1563
			if not normalized[i + 1].success then -- 1563
				failed = failed + 1 -- 1564
			end -- 1564
			i = i + 1 -- 1563
		end -- 1563
	end -- 1563
	local passed = total - failed -- 1566
	if failed > 0 then -- 1566
		return { -- 1568
			success = false, -- 1569
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 1570
			total = total, -- 1571
			passed = passed, -- 1572
			failed = failed, -- 1573
			messages = normalized -- 1574
		} -- 1574
	end -- 1574
	return { -- 1577
		success = true, -- 1578
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 1579
		total = total, -- 1580
		passed = passed, -- 1581
		failed = 0, -- 1582
		messages = normalized -- 1583
	} -- 1583
end -- 1557
function ____exports.build(req) -- 1587
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1587
		local targetRel = req.path or "" -- 1588
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1589
		if not target then -- 1589
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1589
		end -- 1589
		if not Content:exist(target) then -- 1589
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1589
		end -- 1589
		local messages = {} -- 1596
		if not Content:isdir(target) then -- 1596
			local kind = getSupportedBuildKind(target) -- 1598
			if not kind then -- 1598
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1598
			end -- 1598
			if kind == "ts" then -- 1598
				local content = Content:load(target) -- 1603
				if content == nil then -- 1603
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1603
				end -- 1603
				if isTiledEditorContent(content) then -- 1603
					Log("Info", "[build] skip tiled editor file=" .. target) -- 1608
					return ____awaiter_resolve( -- 1608
						nil, -- 1608
						finalizeBuildResult(req.workDir, messages) -- 1609
					) -- 1609
				end -- 1609
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1609
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1609
				end -- 1609
				if not isDtsFile(target) then -- 1609
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1615
				end -- 1615
			else -- 1615
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1618
			end -- 1618
			Log( -- 1620
				"Info", -- 1620
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1620
			) -- 1620
			return ____awaiter_resolve( -- 1620
				nil, -- 1620
				finalizeBuildResult(req.workDir, messages) -- 1621
			) -- 1621
		end -- 1621
		local listResult = ____exports.listFiles({ -- 1623
			workDir = req.workDir, -- 1624
			path = targetRel, -- 1625
			globs = __TS__ArrayMap( -- 1626
				codeExtensions, -- 1626
				function(____, e) return "**/*" .. e end -- 1626
			), -- 1626
			maxEntries = 10000 -- 1627
		}) -- 1627
		local relFiles = listResult.success and listResult.files or ({}) -- 1630
		local tsFileData = {} -- 1631
		local buildQueue = {} -- 1632
		for ____, rel in ipairs(relFiles) do -- 1633
			do -- 1633
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1634
				local kind = getSupportedBuildKind(file) -- 1635
				if not kind then -- 1635
					goto __continue326 -- 1636
				end -- 1636
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1637
				if kind ~= "ts" then -- 1637
					goto __continue326 -- 1639
				end -- 1639
				local content = Content:load(file) -- 1641
				if content == nil then -- 1641
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1643
					goto __continue326 -- 1644
				end -- 1644
				if isTiledEditorContent(content) then -- 1644
					Log("Info", "[build] skip tiled editor file=" .. file) -- 1647
					goto __continue326 -- 1648
				end -- 1648
				tsFileData[file] = content -- 1650
			end -- 1650
			::__continue326:: -- 1650
		end -- 1650
		do -- 1650
			local i = 0 -- 1652
			while i < #buildQueue do -- 1652
				do -- 1652
					local ____buildQueue_index_20 = buildQueue[i + 1] -- 1653
					local file = ____buildQueue_index_20.file -- 1653
					local kind = ____buildQueue_index_20.kind -- 1653
					if kind == "ts" then -- 1653
						local content = tsFileData[file] -- 1655
						if content == nil or isDtsFile(file) then -- 1655
							goto __continue333 -- 1657
						end -- 1657
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1657
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1660
							__TS__Await(pauseBetweenTsTranspiles()) -- 1661
							goto __continue333 -- 1662
						end -- 1662
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1664
						__TS__Await(pauseBetweenTsTranspiles()) -- 1665
						goto __continue333 -- 1666
					end -- 1666
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1668
				end -- 1668
				::__continue333:: -- 1668
				i = i + 1 -- 1652
			end -- 1652
		end -- 1652
		if #messages == 0 then -- 1652
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 1671
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 1671
		end -- 1671
		Log( -- 1674
			"Info", -- 1674
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1674
		) -- 1674
		return ____awaiter_resolve( -- 1674
			nil, -- 1674
			finalizeBuildResult(req.workDir, messages) -- 1675
		) -- 1675
	end) -- 1675
end -- 1587
return ____exports -- 1587