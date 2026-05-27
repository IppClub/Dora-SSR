-- [ts]: Tools.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
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
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local Map = ____lualib.Map -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
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
local App = ____Dora.App -- 2
local HttpServer = ____Dora.HttpServer -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
local safeJsonDecode = ____Utils.safeJsonDecode -- 3
local safeJsonEncode = ____Utils.safeJsonEncode -- 3
function getEngineLogText() -- 903
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 904
	if not Content:exist(folder) then -- 904
		Content:mkdir(folder) -- 906
	end -- 906
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 908
	if not App:saveLog(logPath) then -- 908
		return nil -- 910
	end -- 910
	return Content:load(logPath) -- 912
end -- 912
function ensureSafeSearchGlobs(globs) -- 1052
	local result = {} -- 1053
	do -- 1053
		local i = 0 -- 1054
		while i < #globs do -- 1054
			result[#result + 1] = globs[i + 1] -- 1055
			i = i + 1 -- 1054
		end -- 1054
	end -- 1054
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1057
	do -- 1057
		local i = 0 -- 1058
		while i < #requiredExcludes do -- 1058
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1058
				result[#result + 1] = requiredExcludes[i + 1] -- 1060
			end -- 1060
			i = i + 1 -- 1058
		end -- 1058
	end -- 1058
	return result -- 1063
end -- 1063
local TABLE_TASK = "AgentTask" -- 231
local TABLE_CP = "AgentCheckpoint" -- 232
local TABLE_ENTRY = "AgentCheckpointEntry" -- 233
ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 234
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 235
local function now() -- 237
	return os.time() -- 237
end -- 237
local function toBool(v) -- 239
	return v ~= 0 and v ~= false and v ~= nil -- 240
end -- 239
local function toStr(v) -- 243
	if v == false or v == nil then -- 243
		return "" -- 244
	end -- 244
	return tostring(v) -- 245
end -- 243
local function isValidWorkspacePath(path) -- 248
	if not path or #path == 0 then -- 248
		return false -- 249
	end -- 249
	if Content:isAbsolutePath(path) then -- 249
		return false -- 250
	end -- 250
	if __TS__StringIncludes(path, "..") then -- 250
		return false -- 251
	end -- 251
	return true -- 252
end -- 248
local function isValidWorkDir(workDir) -- 255
	if not workDir or #workDir == 0 then -- 255
		return false -- 256
	end -- 256
	if not Content:isAbsolutePath(workDir) then -- 256
		return false -- 257
	end -- 257
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 257
		return false -- 258
	end -- 258
	return true -- 259
end -- 255
local function isValidSearchPath(path) -- 262
	if path == "" then -- 262
		return true -- 263
	end -- 263
	if Content:isAbsolutePath(path) then -- 263
		return false -- 264
	end -- 264
	if not path or #path == 0 then -- 264
		return false -- 265
	end -- 265
	if __TS__StringIncludes(path, "..") then -- 265
		return false -- 266
	end -- 266
	return true -- 267
end -- 262
local function resolveWorkspaceFilePath(workDir, path) -- 270
	if not isValidWorkDir(workDir) then -- 270
		return nil -- 271
	end -- 271
	if not isValidWorkspacePath(path) then -- 271
		return nil -- 272
	end -- 272
	return Path(workDir, path) -- 273
end -- 270
local function resolveWorkspaceSearchPath(workDir, path) -- 276
	if not isValidWorkDir(workDir) then -- 276
		return nil -- 277
	end -- 277
	if not isValidSearchPath(path) then -- 277
		return nil -- 278
	end -- 278
	return path == "" and workDir or Path(workDir, path) -- 279
end -- 276
local function toWorkspaceRelativePath(workDir, path) -- 282
	if not path or #path == 0 then -- 282
		return path -- 283
	end -- 283
	if not Content:isAbsolutePath(path) then -- 283
		return path -- 284
	end -- 284
	return Path:getRelative(path, workDir) -- 285
end -- 282
local function toWorkspaceRelativeFileList(workDir, files) -- 288
	return __TS__ArrayMap( -- 289
		files, -- 289
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 289
	) -- 289
end -- 288
local function toWorkspaceRelativeSearchResults(workDir, results) -- 292
	local mapped = {} -- 293
	do -- 293
		local i = 0 -- 294
		while i < #results do -- 294
			local row = results[i + 1] -- 295
			local clone = __TS__ObjectAssign({}, row) -- 296
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 297
			mapped[#mapped + 1] = clone -- 298
			i = i + 1 -- 294
		end -- 294
	end -- 294
	return mapped -- 300
end -- 292
local function getDoraAPIDocRoot(docLanguage) -- 303
	local zhDir = Path( -- 304
		Content.assetPath, -- 304
		"Script", -- 304
		"Lib", -- 304
		"Dora", -- 304
		"zh-Hans" -- 304
	) -- 304
	local enDir = Path( -- 305
		Content.assetPath, -- 305
		"Script", -- 305
		"Lib", -- 305
		"Dora", -- 305
		"en" -- 305
	) -- 305
	return docLanguage == "zh" and zhDir or enDir -- 306
end -- 303
local function getDoraTutorialDocRoot(docLanguage) -- 309
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 310
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 311
	return docLanguage == "zh" and zhDir or enDir -- 312
end -- 309
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 315
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 315
		return {"ts"} -- 317
	end -- 317
	return {"tl"} -- 319
end -- 315
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 322
	repeat -- 322
		local ____switch38 = programmingLanguage -- 322
		local ____cond38 = ____switch38 == "teal" -- 322
		if ____cond38 then -- 322
			return "tl" -- 324
		end -- 324
		____cond38 = ____cond38 or ____switch38 == "tl" -- 324
		if ____cond38 then -- 324
			return "tl" -- 325
		end -- 325
		do -- 325
			return programmingLanguage -- 326
		end -- 326
	until true -- 326
end -- 322
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 330
	if docSource == "tutorial" then -- 330
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 336
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 337
		return { -- 338
			root = Path(tutorialRoot, langDir), -- 339
			exts = {"md"}, -- 340
			globs = {"**/*.md"} -- 341
		} -- 341
	end -- 341
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 344
	return { -- 345
		root = getDoraAPIDocRoot(docLanguage), -- 346
		exts = exts, -- 347
		globs = __TS__ArrayMap( -- 348
			exts, -- 348
			function(____, ext) return "**/*." .. ext end -- 348
		) -- 348
	} -- 348
end -- 330
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 352
	if docSource == "tutorial" then -- 352
		return getDoraTutorialDocRoot(docLanguage) -- 354
	end -- 354
	return getDoraAPIDocRoot(docLanguage) -- 356
end -- 352
local function toDocRelativePath(baseRoot, path) -- 359
	if not path or #path == 0 then -- 359
		return path -- 360
	end -- 360
	if not Content:isAbsolutePath(path) then -- 360
		return path -- 361
	end -- 361
	return Path:getRelative(path, baseRoot) -- 362
end -- 359
local function resolveAgentTutorialDocFilePath(path, docLanguage) -- 365
	if not docLanguage then -- 365
		return nil -- 366
	end -- 366
	if not isValidWorkspacePath(path) then -- 366
		return nil -- 367
	end -- 367
	local candidate = Path( -- 368
		getDoraTutorialDocRoot(docLanguage), -- 368
		path -- 368
	) -- 368
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 368
		return candidate -- 370
	end -- 370
	return nil -- 372
end -- 365
local function ensureDirPath(dir) -- 375
	if not dir or dir == "." or dir == "" then -- 375
		return true -- 376
	end -- 376
	if Content:exist(dir) then -- 376
		return Content:isdir(dir) -- 377
	end -- 377
	local parent = Path:getPath(dir) -- 378
	if parent and parent ~= dir and parent ~= "." and parent ~= "" then -- 378
		if not ensureDirPath(parent) then -- 378
			return false -- 380
		end -- 380
	end -- 380
	return Content:mkdir(dir) -- 382
end -- 375
local function ensureDirForFile(path) -- 385
	local dir = Path:getPath(path) -- 386
	return ensureDirPath(dir) -- 387
end -- 385
local function getFileState(path) -- 390
	local exists = Content:exist(path) -- 391
	if not exists then -- 391
		return {exists = false, content = "", bytes = 0} -- 393
	end -- 393
	local content = Content:load(path) -- 399
	return {exists = true, content = content, bytes = #content} -- 400
end -- 390
local function inspectReadableFile(path) -- 407
	do -- 407
		local function ____catch(e) -- 407
			Log( -- 429
				"Warn", -- 429
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 429
			) -- 429
			return true, {success = true} -- 430
		end -- 430
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 430
			local size, isBinary = Content:getAttr(path) -- 409
			if size == nil then -- 409
				return true, {success = false, message = "failed to read file"} -- 411
			end -- 411
			if isBinary then -- 411
				return true, { -- 417
					success = false, -- 418
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 419
					size = type(size) == "number" and size or nil, -- 420
					isBinary = true -- 421
				} -- 421
			end -- 421
			return true, { -- 424
				success = true, -- 425
				size = type(size) == "number" and size or nil -- 426
			} -- 426
		end) -- 426
		if not ____try then -- 426
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 426
		end -- 426
		if ____hasReturned then -- 426
			return ____returnValue -- 408
		end -- 408
	end -- 408
end -- 407
local function isEngineLogFilePath(path) -- 434
	return path == ENGINE_LOG_FILE -- 435
end -- 434
local function readEngineLogFile(path) -- 438
	if not isEngineLogFilePath(path) then -- 438
		return nil -- 439
	end -- 439
	local content = getEngineLogText() -- 440
	if content == nil then -- 440
		return {success = false, message = "failed to read engine logs"} -- 442
	end -- 442
	return {success = true, content = content, size = #content} -- 444
end -- 438
local function queryOne(sql, args) -- 447
	local ____args_0 -- 448
	if args then -- 448
		____args_0 = DB:query(sql, args) -- 448
	else -- 448
		____args_0 = DB:query(sql) -- 448
	end -- 448
	local rows = ____args_0 -- 448
	if not rows or #rows == 0 then -- 448
		return nil -- 449
	end -- 449
	return rows[1] -- 450
end -- 447
do -- 447
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 455
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 463
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 474
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 475
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 488
end -- 488
local function isDtsFile(path) -- 491
	return Path:getExt(Path:getName(path)) == "d" -- 492
end -- 491
local function getSupportedBuildKind(path) -- 497
	repeat -- 497
		local ____switch73 = Path:getExt(path) -- 497
		local ____cond73 = ____switch73 == "ts" or ____switch73 == "tsx" -- 497
		if ____cond73 then -- 497
			return "ts" -- 499
		end -- 499
		____cond73 = ____cond73 or ____switch73 == "xml" -- 499
		if ____cond73 then -- 499
			return "xml" -- 500
		end -- 500
		____cond73 = ____cond73 or ____switch73 == "tl" -- 500
		if ____cond73 then -- 500
			return "teal" -- 501
		end -- 501
		____cond73 = ____cond73 or ____switch73 == "lua" -- 501
		if ____cond73 then -- 501
			return "lua" -- 502
		end -- 502
		____cond73 = ____cond73 or ____switch73 == "yue" -- 502
		if ____cond73 then -- 502
			return "yue" -- 503
		end -- 503
		____cond73 = ____cond73 or ____switch73 == "yarn" -- 503
		if ____cond73 then -- 503
			return "yarn" -- 504
		end -- 504
		do -- 504
			return nil -- 505
		end -- 505
	until true -- 505
end -- 497
local function getTaskHeadSeq(taskId) -- 509
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 510
	if not row then -- 510
		return nil -- 511
	end -- 511
	return row[1] or 0 -- 512
end -- 509
local function getTaskStatus(taskId) -- 515
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 516
	if not row then -- 516
		return nil -- 517
	end -- 517
	return toStr(row[1]) -- 518
end -- 515
local function getLastInsertRowId() -- 521
	local row = queryOne("SELECT last_insert_rowid()") -- 522
	return row and (row[1] or 0) or 0 -- 523
end -- 521
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 526
	DB:exec( -- 527
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 527
		{ -- 529
			taskId, -- 529
			seq, -- 529
			status, -- 529
			summary, -- 529
			toolName, -- 529
			now() -- 529
		} -- 529
	) -- 529
	return getLastInsertRowId() -- 531
end -- 526
local function getCheckpointEntries(checkpointId, desc) -- 534
	if desc == nil then -- 534
		desc = false -- 534
	end -- 534
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 535
	if not rows then -- 535
		return {} -- 542
	end -- 542
	local result = {} -- 543
	do -- 543
		local i = 0 -- 544
		while i < #rows do -- 544
			local row = rows[i + 1] -- 545
			result[#result + 1] = { -- 546
				id = row[1], -- 547
				ord = row[2], -- 548
				path = toStr(row[3]), -- 549
				op = toStr(row[4]), -- 550
				beforeExists = toBool(row[5]), -- 551
				beforeContent = toStr(row[6]), -- 552
				afterExists = toBool(row[7]), -- 553
				afterContent = toStr(row[8]) -- 554
			} -- 554
			i = i + 1 -- 544
		end -- 544
	end -- 544
	return result -- 557
end -- 534
local function rejectDuplicatePaths(changes) -- 560
	local seen = __TS__New(Set) -- 561
	for ____, change in ipairs(changes) do -- 562
		local key = change.path -- 563
		if seen:has(key) then -- 563
			return key -- 564
		end -- 564
		seen:add(key) -- 565
	end -- 565
	return nil -- 567
end -- 560
local function getLinkedDeletePaths(workDir, path) -- 570
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 571
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 571
		return {} -- 572
	end -- 572
	local parent = Path:getPath(fullPath) -- 573
	local baseName = string.lower(Path:getName(fullPath)) -- 574
	local ext = Path:getExt(fullPath) -- 575
	local linked = {} -- 576
	for ____, file in ipairs(Content:getFiles(parent)) do -- 577
		do -- 577
			if string.lower(Path:getName(file)) ~= baseName then -- 577
				goto __continue90 -- 578
			end -- 578
			local siblingExt = Path:getExt(file) -- 579
			if siblingExt == "tl" and ext == "vs" then -- 579
				linked[#linked + 1] = toWorkspaceRelativePath( -- 581
					workDir, -- 581
					Path(parent, file) -- 581
				) -- 581
				goto __continue90 -- 582
			end -- 582
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 582
				linked[#linked + 1] = toWorkspaceRelativePath( -- 585
					workDir, -- 585
					Path(parent, file) -- 585
				) -- 585
			end -- 585
		end -- 585
		::__continue90:: -- 585
	end -- 585
	return linked -- 588
end -- 570
local function expandLinkedDeleteChanges(workDir, changes) -- 591
	local expanded = {} -- 592
	local seen = __TS__New(Set) -- 593
	do -- 593
		local i = 0 -- 594
		while i < #changes do -- 594
			do -- 594
				local change = changes[i + 1] -- 595
				if not seen:has(change.path) then -- 595
					seen:add(change.path) -- 597
					expanded[#expanded + 1] = change -- 598
				end -- 598
				if change.op ~= "delete" then -- 598
					goto __continue97 -- 600
				end -- 600
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 601
				do -- 601
					local j = 0 -- 602
					while j < #linkedPaths do -- 602
						do -- 602
							local linkedPath = linkedPaths[j + 1] -- 603
							if seen:has(linkedPath) then -- 603
								goto __continue101 -- 604
							end -- 604
							seen:add(linkedPath) -- 605
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 606
						end -- 606
						::__continue101:: -- 606
						j = j + 1 -- 602
					end -- 602
				end -- 602
			end -- 602
			::__continue97:: -- 602
			i = i + 1 -- 594
		end -- 594
	end -- 594
	return expanded -- 609
end -- 591
local function applySingleFile(path, exists, content) -- 612
	if exists then -- 612
		if not ensureDirForFile(path) then -- 612
			return false -- 614
		end -- 614
		return Content:save(path, content) -- 615
	end -- 615
	if Content:exist(path) then -- 615
		return Content:remove(path) -- 618
	end -- 618
	return true -- 620
end -- 612
local function encodeJSON(obj) -- 623
	local text = safeJsonEncode(obj) -- 624
	return text -- 625
end -- 623
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 628
	if HttpServer.wsConnectionCount == 0 then -- 628
		return true -- 630
	end -- 630
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 632
	if not payload then -- 632
		return false -- 634
	end -- 634
	emit("AppWS", "Send", payload) -- 636
	return true -- 637
end -- 628
local function runSingleNonTsBuild(file) -- 640
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 640
		return ____awaiter_resolve( -- 640
			nil, -- 640
			__TS__New( -- 641
				__TS__Promise, -- 641
				function(____, resolve) -- 641
					local ____require_result_1 = require("Script.Dev.WebServer") -- 642
					local buildAsync = ____require_result_1.buildAsync -- 642
					Director.systemScheduler:schedule(once(function() -- 643
						local result = buildAsync(file) -- 644
						resolve(nil, result) -- 645
					end)) -- 643
				end -- 641
			) -- 641
		) -- 641
	end) -- 641
end -- 640
function ____exports.runSingleTsTranspile(file, content) -- 650
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 650
		local done = false -- 651
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 652
		if HttpServer.wsConnectionCount == 0 then -- 652
			return ____awaiter_resolve(nil, result) -- 652
		end -- 652
		local listener = Node() -- 660
		listener:gslot( -- 661
			"AppWS", -- 661
			function(event) -- 661
				if event.type ~= "Receive" then -- 661
					return -- 662
				end -- 662
				local res = safeJsonDecode(event.msg) -- 663
				if not res or __TS__ArrayIsArray(res) then -- 663
					return -- 664
				end -- 664
				local payload = res -- 665
				if payload.name ~= "TranspileTS" then -- 665
					return -- 666
				end -- 666
				if tostring(payload.file) ~= file then -- 666
					return -- 667
				end -- 667
				if payload.success then -- 667
					local luaFile = Path:replaceExt(file, "lua") -- 669
					if Content:save( -- 669
						luaFile, -- 670
						tostring(payload.luaCode) -- 670
					) then -- 670
						result = {success = true, file = file} -- 671
					else -- 671
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 673
					end -- 673
				else -- 673
					result = { -- 676
						success = false, -- 676
						file = file, -- 676
						message = tostring(payload.message) -- 676
					} -- 676
				end -- 676
				done = true -- 678
			end -- 661
		) -- 661
		local payload = encodeJSON({name = "TranspileTS", file = file, content = content}) -- 680
		if not payload then -- 680
			listener:removeFromParent() -- 686
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 686
		end -- 686
		__TS__Await(__TS__New( -- 689
			__TS__Promise, -- 689
			function(____, resolve) -- 689
				Director.systemScheduler:schedule(once(function() -- 690
					emit("AppWS", "Send", payload) -- 691
					wait(function() return done end) -- 692
					if not done then -- 692
						listener:removeFromParent() -- 694
					end -- 694
					resolve(nil) -- 696
				end)) -- 690
			end -- 689
		)) -- 689
		return ____awaiter_resolve(nil, result) -- 689
	end) -- 689
end -- 650
function ____exports.createTask(prompt) -- 702
	if prompt == nil then -- 702
		prompt = "" -- 702
	end -- 702
	local t = now() -- 703
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 704
	if affected <= 0 then -- 704
		return {success = false, message = "failed to create task"} -- 709
	end -- 709
	return { -- 711
		success = true, -- 711
		taskId = getLastInsertRowId() -- 711
	} -- 711
end -- 702
function ____exports.setTaskStatus(taskId, status) -- 714
	DB:exec( -- 715
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 715
		{ -- 715
			status, -- 715
			now(), -- 715
			taskId -- 715
		} -- 715
	) -- 715
	Log( -- 716
		"Info", -- 716
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 716
	) -- 716
end -- 714
function ____exports.listCheckpoints(taskId) -- 719
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 720
	if not rows then -- 720
		return {} -- 727
	end -- 727
	local items = {} -- 728
	do -- 728
		local i = 0 -- 729
		while i < #rows do -- 729
			local row = rows[i + 1] -- 730
			items[#items + 1] = { -- 731
				id = row[1], -- 732
				taskId = row[2], -- 733
				seq = row[3], -- 734
				status = toStr(row[4]), -- 735
				summary = toStr(row[5]), -- 736
				toolName = toStr(row[6]), -- 737
				createdAt = row[7] -- 738
			} -- 738
			i = i + 1 -- 729
		end -- 729
	end -- 729
	return items -- 741
end -- 719
local function listCheckpointIdsForTask(taskId, desc) -- 744
	if desc == nil then -- 744
		desc = false -- 744
	end -- 744
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 745
	if not rows then -- 745
		return {} -- 752
	end -- 752
	local items = {} -- 753
	do -- 753
		local i = 0 -- 754
		while i < #rows do -- 754
			local row = rows[i + 1] -- 755
			items[#items + 1] = {id = row[1], seq = row[2]} -- 756
			i = i + 1 -- 754
		end -- 754
	end -- 754
	return items -- 761
end -- 744
local function deriveFileOp(beforeExists, afterExists) -- 764
	if not beforeExists and afterExists then -- 764
		return "create" -- 765
	end -- 765
	if beforeExists and not afterExists then -- 765
		return "delete" -- 766
	end -- 766
	return "write" -- 767
end -- 764
function ____exports.summarizeTaskChangeSet(taskId) -- 770
	if not getTaskStatus(taskId) then -- 770
		return {success = false, message = "task not found"} -- 772
	end -- 772
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 774
	local filesByPath = {} -- 775
	local latestCheckpointId = nil -- 781
	local latestCheckpointSeq = nil -- 782
	do -- 782
		local i = 0 -- 783
		while i < #checkpoints do -- 783
			local checkpoint = checkpoints[i + 1] -- 784
			latestCheckpointId = checkpoint.id -- 785
			latestCheckpointSeq = checkpoint.seq -- 786
			local entries = getCheckpointEntries(checkpoint.id, false) -- 787
			do -- 787
				local j = 0 -- 788
				while j < #entries do -- 788
					local entry = entries[j + 1] -- 789
					local item = filesByPath[entry.path] -- 790
					if not item then -- 790
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 792
						filesByPath[entry.path] = item -- 798
					end -- 798
					item.afterExists = entry.afterExists -- 800
					local ____item_checkpointIds_2 = item.checkpointIds -- 800
					____item_checkpointIds_2[#____item_checkpointIds_2 + 1] = checkpoint.id -- 801
					j = j + 1 -- 788
				end -- 788
			end -- 788
			i = i + 1 -- 783
		end -- 783
	end -- 783
	local files = {} -- 804
	for ____, item in pairs(filesByPath) do -- 805
		files[#files + 1] = { -- 806
			path = item.path, -- 807
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 808
			checkpointCount = #item.checkpointIds, -- 809
			checkpointIds = item.checkpointIds -- 810
		} -- 810
	end -- 810
	__TS__ArraySort( -- 813
		files, -- 813
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 813
	) -- 813
	return { -- 814
		success = true, -- 815
		taskId = taskId, -- 816
		checkpointCount = #checkpoints, -- 817
		filesChanged = #files, -- 818
		files = files, -- 819
		latestCheckpointId = latestCheckpointId, -- 820
		latestCheckpointSeq = latestCheckpointSeq -- 821
	} -- 821
end -- 770
function ____exports.getTaskChangeSetDiff(taskId) -- 825
	if not getTaskStatus(taskId) then -- 825
		return {success = false, message = "task not found"} -- 827
	end -- 827
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 829
	if #checkpoints == 0 then -- 829
		return {success = false, message = "change set not found or empty"} -- 831
	end -- 831
	local filesByPath = {} -- 833
	do -- 833
		local i = 0 -- 840
		while i < #checkpoints do -- 840
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 841
			do -- 841
				local j = 0 -- 842
				while j < #entries do -- 842
					local entry = entries[j + 1] -- 843
					local item = filesByPath[entry.path] -- 844
					if not item then -- 844
						item = { -- 846
							path = entry.path, -- 847
							beforeExists = entry.beforeExists, -- 848
							beforeContent = entry.beforeContent, -- 849
							afterExists = entry.afterExists, -- 850
							afterContent = entry.afterContent -- 851
						} -- 851
						filesByPath[entry.path] = item -- 853
					end -- 853
					item.afterExists = entry.afterExists -- 855
					item.afterContent = entry.afterContent -- 856
					j = j + 1 -- 842
				end -- 842
			end -- 842
			i = i + 1 -- 840
		end -- 840
	end -- 840
	local files = {} -- 859
	for ____, item in pairs(filesByPath) do -- 860
		files[#files + 1] = { -- 861
			path = item.path, -- 862
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 863
			beforeExists = item.beforeExists, -- 864
			afterExists = item.afterExists, -- 865
			beforeContent = item.beforeContent, -- 866
			afterContent = item.afterContent -- 867
		} -- 867
	end -- 867
	__TS__ArraySort( -- 870
		files, -- 870
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 870
	) -- 870
	return {success = true, files = files} -- 871
end -- 825
local function readWorkspaceFile(workDir, path, docLanguage) -- 874
	local engineLog = readEngineLogFile(path) -- 875
	if engineLog then -- 875
		return engineLog -- 876
	end -- 876
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 877
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 877
		local attr = inspectReadableFile(fullPath) -- 879
		if not attr.success then -- 879
			return attr -- 880
		end -- 880
		return { -- 881
			success = true, -- 881
			content = Content:load(fullPath), -- 881
			size = attr.size -- 881
		} -- 881
	end -- 881
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 883
	if docPath then -- 883
		local attr = inspectReadableFile(docPath) -- 885
		if not attr.success then -- 885
			return attr -- 886
		end -- 886
		return { -- 887
			success = true, -- 887
			content = Content:load(docPath), -- 887
			size = attr.size -- 887
		} -- 887
	end -- 887
	if not fullPath then -- 887
		return {success = false, message = "invalid path or workDir"} -- 889
	end -- 889
	return {success = false, message = "file not found"} -- 890
end -- 874
function ____exports.readFileRaw(workDir, path, docLanguage) -- 893
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 894
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 894
		local attr = inspectReadableFile(path) -- 896
		if not attr.success then -- 896
			return attr -- 897
		end -- 897
		return { -- 898
			success = true, -- 898
			content = Content:load(path), -- 898
			size = attr.size -- 898
		} -- 898
	end -- 898
	return result -- 900
end -- 893
function ____exports.getLogs(req) -- 915
	local text = getEngineLogText() -- 916
	if text == nil then -- 916
		return {success = false, message = "failed to read engine logs"} -- 918
	end -- 918
	local tailLines = math.max( -- 920
		1, -- 920
		math.floor(req and req.tailLines or 200) -- 920
	) -- 920
	local allLines = __TS__StringSplit(text, "\n") -- 921
	local logs = __TS__ArraySlice( -- 922
		allLines, -- 922
		math.max(0, #allLines - tailLines) -- 922
	) -- 922
	return req and req.joinText and ({ -- 923
		success = true, -- 923
		logs = logs, -- 923
		text = table.concat(logs, "\n") -- 923
	}) or ({success = true, logs = logs}) -- 923
end -- 915
function ____exports.listFiles(req) -- 926
	local root = req.path or "" -- 932
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 933
	if not searchRoot then -- 933
		return {success = false, message = "invalid path or workDir"} -- 935
	end -- 935
	do -- 935
		local function ____catch(e) -- 935
			return true, { -- 953
				success = false, -- 953
				message = tostring(e) -- 953
			} -- 953
		end -- 953
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 953
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 938
			local globs = ensureSafeSearchGlobs(userGlobs) -- 939
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 940
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 941
			local totalEntries = #files -- 942
			local maxEntries = math.max( -- 943
				1, -- 943
				math.floor(req.maxEntries or 200) -- 943
			) -- 943
			local truncated = totalEntries > maxEntries -- 944
			return true, { -- 945
				success = true, -- 946
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 947
				totalEntries = totalEntries, -- 948
				truncated = truncated, -- 949
				maxEntries = maxEntries -- 950
			} -- 950
		end) -- 950
		if not ____try then -- 950
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 950
		end -- 950
		if ____hasReturned then -- 950
			return ____returnValue -- 937
		end -- 937
	end -- 937
end -- 926
local function formatReadSlice(content, startLine, endLine) -- 957
	local lines = __TS__StringSplit(content, "\n") -- 962
	local totalLines = #lines -- 963
	if totalLines == 0 then -- 963
		return { -- 965
			success = true, -- 966
			content = "", -- 967
			totalLines = 0, -- 968
			startLine = 1, -- 969
			endLine = 0, -- 970
			truncated = false -- 971
		} -- 971
	end -- 971
	local rawStart = math.floor(startLine) -- 974
	local rawEnd = math.floor(endLine) -- 975
	if rawStart == 0 then -- 975
		return {success = false, message = "startLine cannot be 0"} -- 977
	end -- 977
	if rawEnd == 0 then -- 977
		return {success = false, message = "endLine cannot be 0"} -- 980
	end -- 980
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 982
	if start > totalLines then -- 982
		return { -- 986
			success = false, -- 986
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 986
		} -- 986
	end -- 986
	local ____end = math.min( -- 988
		totalLines, -- 989
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 990
	) -- 990
	if ____end < start then -- 990
		return { -- 995
			success = false, -- 996
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 997
		} -- 997
	end -- 997
	local slice = {} -- 1000
	do -- 1000
		local i = start -- 1001
		while i <= ____end do -- 1001
			slice[#slice + 1] = lines[i] -- 1002
			i = i + 1 -- 1001
		end -- 1001
	end -- 1001
	local truncated = start > 1 or ____end < totalLines -- 1004
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1005
	local body = table.concat(slice, "\n") -- 1010
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1011
	return { -- 1012
		success = true, -- 1013
		content = output, -- 1014
		totalLines = totalLines, -- 1015
		startLine = start, -- 1016
		endLine = ____end, -- 1017
		truncated = truncated -- 1018
	} -- 1018
end -- 957
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1022
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1029
	if not fallback.success or fallback.content == nil then -- 1029
		return fallback -- 1030
	end -- 1030
	local resolvedStartLine = startLine or 1 -- 1031
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1032
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1033
end -- 1022
local codeExtensions = { -- 1040
	".lua", -- 1040
	".tl", -- 1040
	".yue", -- 1040
	".ts", -- 1040
	".tsx", -- 1040
	".xml", -- 1040
	".md", -- 1040
	".yarn", -- 1040
	".wa", -- 1040
	".mod" -- 1040
} -- 1040
extensionLevels = { -- 1041
	vs = 2, -- 1042
	bl = 2, -- 1043
	ts = 1, -- 1044
	tsx = 1, -- 1045
	tl = 1, -- 1046
	yue = 1, -- 1047
	xml = 1, -- 1048
	lua = 0 -- 1049
} -- 1049
local function splitSearchPatterns(pattern) -- 1066
	local trimmed = __TS__StringTrim(pattern or "") -- 1067
	if trimmed == "" then -- 1067
		return {} -- 1068
	end -- 1068
	local out = {} -- 1069
	local seen = __TS__New(Set) -- 1070
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1071
		local p = __TS__StringTrim(tostring(p0)) -- 1072
		if p ~= "" and not seen:has(p) then -- 1072
			seen:add(p) -- 1074
			out[#out + 1] = p -- 1075
		end -- 1075
	end -- 1075
	return out -- 1078
end -- 1066
local function mergeSearchFileResultsUnique(resultsList) -- 1081
	local merged = {} -- 1082
	local seen = __TS__New(Set) -- 1083
	do -- 1083
		local i = 0 -- 1084
		while i < #resultsList do -- 1084
			local list = resultsList[i + 1] -- 1085
			do -- 1085
				local j = 0 -- 1086
				while j < #list do -- 1086
					do -- 1086
						local row = list[j + 1] -- 1087
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1088
						if seen:has(key) then -- 1088
							goto __continue206 -- 1089
						end -- 1089
						seen:add(key) -- 1090
						merged[#merged + 1] = list[j + 1] -- 1091
					end -- 1091
					::__continue206:: -- 1091
					j = j + 1 -- 1086
				end -- 1086
			end -- 1086
			i = i + 1 -- 1084
		end -- 1084
	end -- 1084
	return merged -- 1094
end -- 1081
local function buildGroupedSearchResults(results) -- 1097
	local order = {} -- 1102
	local grouped = __TS__New(Map) -- 1103
	do -- 1103
		local i = 0 -- 1108
		while i < #results do -- 1108
			local row = results[i + 1] -- 1109
			local file = row.file -- 1110
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1111
			local bucket = grouped:get(key) -- 1112
			if not bucket then -- 1112
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1114
				grouped:set(key, bucket) -- 1115
				order[#order + 1] = key -- 1116
			end -- 1116
			bucket.totalMatches = bucket.totalMatches + 1 -- 1118
			local ____bucket_matches_7 = bucket.matches -- 1118
			____bucket_matches_7[#____bucket_matches_7 + 1] = results[i + 1] -- 1119
			i = i + 1 -- 1108
		end -- 1108
	end -- 1108
	local out = {} -- 1121
	do -- 1121
		local i = 0 -- 1126
		while i < #order do -- 1126
			local bucket = grouped:get(order[i + 1]) -- 1127
			if bucket then -- 1127
				out[#out + 1] = bucket -- 1128
			end -- 1128
			i = i + 1 -- 1126
		end -- 1126
	end -- 1126
	return out -- 1130
end -- 1097
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1133
	local merged = {} -- 1134
	local seen = __TS__New(Set) -- 1135
	local index = 0 -- 1136
	local advanced = true -- 1137
	while advanced do -- 1137
		advanced = false -- 1139
		do -- 1139
			local i = 0 -- 1140
			while i < #resultsList do -- 1140
				do -- 1140
					local list = resultsList[i + 1] -- 1141
					if index >= #list then -- 1141
						goto __continue218 -- 1142
					end -- 1142
					advanced = true -- 1143
					local row = list[index + 1] -- 1144
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1145
					if seen:has(key) then -- 1145
						goto __continue218 -- 1146
					end -- 1146
					seen:add(key) -- 1147
					merged[#merged + 1] = row -- 1148
				end -- 1148
				::__continue218:: -- 1148
				i = i + 1 -- 1140
			end -- 1140
		end -- 1140
		index = index + 1 -- 1150
	end -- 1150
	return merged -- 1152
end -- 1133
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1155
	if docSource ~= "api" then -- 1155
		return 100 -- 1156
	end -- 1156
	if programmingLanguage ~= "tsx" then -- 1156
		return 100 -- 1157
	end -- 1157
	repeat -- 1157
		local ____switch224 = string.lower(Path:getFilename(file)) -- 1157
		local ____cond224 = ____switch224 == "jsx.d.ts" -- 1157
		if ____cond224 then -- 1157
			return 0 -- 1159
		end -- 1159
		____cond224 = ____cond224 or ____switch224 == "dorax.d.ts" -- 1159
		if ____cond224 then -- 1159
			return 1 -- 1160
		end -- 1160
		____cond224 = ____cond224 or ____switch224 == "dora.d.ts" -- 1160
		if ____cond224 then -- 1160
			return 2 -- 1161
		end -- 1161
		do -- 1161
			return 100 -- 1162
		end -- 1162
	until true -- 1162
end -- 1155
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1166
	local sorted = __TS__ArraySlice(hits) -- 1171
	__TS__ArraySort( -- 1172
		sorted, -- 1172
		function(____, a, b) -- 1172
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1173
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1174
			if pa ~= pb then -- 1174
				return pa - pb -- 1175
			end -- 1175
			local fa = string.lower(a.file) -- 1176
			local fb = string.lower(b.file) -- 1177
			if fa ~= fb then -- 1177
				return fa < fb and -1 or 1 -- 1178
			end -- 1178
			return (a.line or 0) - (b.line or 0) -- 1179
		end -- 1172
	) -- 1172
	return sorted -- 1181
end -- 1166
function ____exports.searchFiles(req) -- 1184
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1184
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1197
		if not resolvedPath then -- 1197
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1197
		end -- 1197
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1201
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1202
		if not searchRoot then -- 1202
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1202
		end -- 1202
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1202
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1202
		end -- 1202
		local patterns = splitSearchPatterns(req.pattern) -- 1209
		if #patterns == 0 then -- 1209
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1209
		end -- 1209
		return ____awaiter_resolve( -- 1209
			nil, -- 1209
			__TS__New( -- 1213
				__TS__Promise, -- 1213
				function(____, resolve) -- 1213
					Director.systemScheduler:schedule(once(function() -- 1214
						do -- 1214
							local function ____catch(e) -- 1214
								resolve( -- 1256
									nil, -- 1256
									{ -- 1256
										success = false, -- 1256
										message = tostring(e) -- 1256
									} -- 1256
								) -- 1256
							end -- 1256
							local ____try, ____hasReturned = pcall(function() -- 1256
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1216
								local allResults = {} -- 1219
								do -- 1219
									local i = 0 -- 1220
									while i < #patterns do -- 1220
										local ____Content_12 = Content -- 1221
										local ____Content_searchFilesAsync_13 = Content.searchFilesAsync -- 1221
										local ____patterns_index_11 = patterns[i + 1] -- 1226
										local ____req_useRegex_8 = req.useRegex -- 1227
										if ____req_useRegex_8 == nil then -- 1227
											____req_useRegex_8 = false -- 1227
										end -- 1227
										local ____req_caseSensitive_9 = req.caseSensitive -- 1228
										if ____req_caseSensitive_9 == nil then -- 1228
											____req_caseSensitive_9 = false -- 1228
										end -- 1228
										local ____req_includeContent_10 = req.includeContent -- 1229
										if ____req_includeContent_10 == nil then -- 1229
											____req_includeContent_10 = true -- 1229
										end -- 1229
										allResults[#allResults + 1] = ____Content_searchFilesAsync_13( -- 1221
											____Content_12, -- 1221
											searchRoot, -- 1222
											codeExtensions, -- 1223
											extensionLevels, -- 1224
											searchGlobs, -- 1225
											____patterns_index_11, -- 1226
											____req_useRegex_8, -- 1227
											____req_caseSensitive_9, -- 1228
											____req_includeContent_10, -- 1229
											req.contentWindow or 120 -- 1230
										) -- 1230
										i = i + 1 -- 1220
									end -- 1220
								end -- 1220
								local results = mergeSearchFileResultsUnique(allResults) -- 1233
								local totalResults = #results -- 1234
								local limit = math.max( -- 1235
									1, -- 1235
									math.floor(req.limit or 20) -- 1235
								) -- 1235
								local offset = math.max( -- 1236
									0, -- 1236
									math.floor(req.offset or 0) -- 1236
								) -- 1236
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1237
								local nextOffset = offset + #paged -- 1238
								local hasMore = nextOffset < totalResults -- 1239
								local truncated = offset > 0 or hasMore -- 1240
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1241
								local groupByFile = req.groupByFile == true -- 1242
								resolve( -- 1243
									nil, -- 1243
									{ -- 1243
										success = true, -- 1244
										results = relativeResults, -- 1245
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1246
										totalResults = totalResults, -- 1247
										truncated = truncated, -- 1248
										limit = limit, -- 1249
										offset = offset, -- 1250
										nextOffset = nextOffset, -- 1251
										hasMore = hasMore, -- 1252
										groupByFile = groupByFile -- 1253
									} -- 1253
								) -- 1253
							end) -- 1253
							if not ____try then -- 1253
								____catch(____hasReturned) -- 1253
							end -- 1253
						end -- 1253
					end)) -- 1214
				end -- 1213
			) -- 1213
		) -- 1213
	end) -- 1213
end -- 1184
function ____exports.searchDoraAPI(req) -- 1262
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1262
		local pattern = __TS__StringTrim(req.pattern or "") -- 1273
		if pattern == "" then -- 1273
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1273
		end -- 1273
		local patterns = splitSearchPatterns(pattern) -- 1275
		if #patterns == 0 then -- 1275
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1275
		end -- 1275
		local docSource = req.docSource or "api" -- 1277
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1278
		local docRoot = target.root -- 1279
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1280
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1280
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1280
		end -- 1280
		local exts = target.exts -- 1284
		local dotExts = __TS__ArrayMap( -- 1285
			exts, -- 1285
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1285
		) -- 1285
		local globs = target.globs -- 1286
		local limit = math.max( -- 1287
			1, -- 1287
			math.floor(req.limit or 10) -- 1287
		) -- 1287
		return ____awaiter_resolve( -- 1287
			nil, -- 1287
			__TS__New( -- 1289
				__TS__Promise, -- 1289
				function(____, resolve) -- 1289
					Director.systemScheduler:schedule(once(function() -- 1290
						do -- 1290
							local function ____catch(e) -- 1290
								resolve( -- 1331
									nil, -- 1331
									{ -- 1331
										success = false, -- 1331
										message = tostring(e) -- 1331
									} -- 1331
								) -- 1331
							end -- 1331
							local ____try, ____hasReturned = pcall(function() -- 1331
								local allHits = {} -- 1292
								do -- 1292
									local p = 0 -- 1293
									while p < #patterns do -- 1293
										local ____Content_18 = Content -- 1294
										local ____Content_searchFilesAsync_19 = Content.searchFilesAsync -- 1294
										local ____array_17 = __TS__SparseArrayNew( -- 1294
											docRoot, -- 1295
											dotExts, -- 1296
											{}, -- 1297
											ensureSafeSearchGlobs(globs), -- 1298
											patterns[p + 1] -- 1299
										) -- 1299
										local ____req_useRegex_14 = req.useRegex -- 1300
										if ____req_useRegex_14 == nil then -- 1300
											____req_useRegex_14 = false -- 1300
										end -- 1300
										__TS__SparseArrayPush(____array_17, ____req_useRegex_14) -- 1300
										local ____req_caseSensitive_15 = req.caseSensitive -- 1301
										if ____req_caseSensitive_15 == nil then -- 1301
											____req_caseSensitive_15 = false -- 1301
										end -- 1301
										__TS__SparseArrayPush(____array_17, ____req_caseSensitive_15) -- 1301
										local ____req_includeContent_16 = req.includeContent -- 1302
										if ____req_includeContent_16 == nil then -- 1302
											____req_includeContent_16 = true -- 1302
										end -- 1302
										__TS__SparseArrayPush(____array_17, ____req_includeContent_16, req.contentWindow or 80) -- 1302
										local raw = ____Content_searchFilesAsync_19( -- 1294
											____Content_18, -- 1294
											__TS__SparseArraySpread(____array_17) -- 1294
										) -- 1294
										local hits = {} -- 1305
										do -- 1305
											local i = 0 -- 1306
											while i < #raw do -- 1306
												do -- 1306
													local row = raw[i + 1] -- 1307
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1308
													if file == "" then -- 1308
														goto __continue251 -- 1309
													end -- 1309
													hits[#hits + 1] = { -- 1310
														file = file, -- 1311
														line = type(row.line) == "number" and row.line or nil, -- 1312
														content = type(row.content) == "string" and row.content or nil -- 1313
													} -- 1313
												end -- 1313
												::__continue251:: -- 1313
												i = i + 1 -- 1306
											end -- 1306
										end -- 1306
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1316
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1316
											0, -- 1316
											limit -- 1316
										) -- 1316
										p = p + 1 -- 1293
									end -- 1293
								end -- 1293
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1318
								resolve(nil, { -- 1319
									success = true, -- 1320
									docSource = docSource, -- 1321
									docLanguage = req.docLanguage, -- 1322
									programmingLanguage = req.programmingLanguage, -- 1323
									exts = exts, -- 1324
									results = hits, -- 1325
									totalResults = #hits, -- 1326
									truncated = false, -- 1327
									limit = limit -- 1328
								}) -- 1328
							end) -- 1328
							if not ____try then -- 1328
								____catch(____hasReturned) -- 1328
							end -- 1328
						end -- 1328
					end)) -- 1290
				end -- 1289
			) -- 1289
		) -- 1289
	end) -- 1289
end -- 1262
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1337
	if options == nil then -- 1337
		options = {} -- 1337
	end -- 1337
	if #changes == 0 then -- 1337
		return {success = false, message = "empty changes"} -- 1339
	end -- 1339
	if not isValidWorkDir(workDir) then -- 1339
		return {success = false, message = "invalid workDir"} -- 1342
	end -- 1342
	if not getTaskStatus(taskId) then -- 1342
		return {success = false, message = "task not found"} -- 1345
	end -- 1345
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1347
	local dup = rejectDuplicatePaths(expandedChanges) -- 1348
	if dup then -- 1348
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1350
	end -- 1350
	for ____, change in ipairs(expandedChanges) do -- 1353
		if not isValidWorkspacePath(change.path) then -- 1353
			return {success = false, message = "invalid path: " .. change.path} -- 1355
		end -- 1355
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1355
			return {success = false, message = "missing content for " .. change.path} -- 1358
		end -- 1358
	end -- 1358
	local headSeq = getTaskHeadSeq(taskId) -- 1362
	if headSeq == nil then -- 1362
		return {success = false, message = "task not found"} -- 1363
	end -- 1363
	local nextSeq = headSeq + 1 -- 1364
	local checkpointId = insertCheckpoint( -- 1365
		taskId, -- 1365
		nextSeq, -- 1365
		options.summary or "", -- 1365
		options.toolName or "", -- 1365
		"PREPARED" -- 1365
	) -- 1365
	if checkpointId <= 0 then -- 1365
		return {success = false, message = "failed to create checkpoint"} -- 1367
	end -- 1367
	do -- 1367
		local i = 0 -- 1370
		while i < #expandedChanges do -- 1370
			local change = expandedChanges[i + 1] -- 1371
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1372
			if not fullPath then -- 1372
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1374
				return {success = false, message = "invalid path: " .. change.path} -- 1375
			end -- 1375
			local before = getFileState(fullPath) -- 1377
			local afterExists = change.op ~= "delete" -- 1378
			local afterContent = afterExists and (change.content or "") or "" -- 1379
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1380
				checkpointId, -- 1384
				i + 1, -- 1385
				change.path, -- 1386
				change.op, -- 1387
				before.exists and 1 or 0, -- 1388
				before.content, -- 1389
				afterExists and 1 or 0, -- 1390
				afterContent, -- 1391
				before.bytes, -- 1392
				#afterContent -- 1393
			}) -- 1393
			if inserted <= 0 then -- 1393
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1397
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1398
			end -- 1398
			i = i + 1 -- 1370
		end -- 1370
	end -- 1370
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1402
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1403
		if not fullPath then -- 1403
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1405
			return {success = false, message = "invalid path: " .. entry.path} -- 1406
		end -- 1406
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1408
		if not ok then -- 1408
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1410
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1411
		end -- 1411
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1411
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1414
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1415
		end -- 1415
	end -- 1415
	DB:exec( -- 1419
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1419
		{ -- 1421
			"APPLIED", -- 1421
			now(), -- 1421
			checkpointId -- 1421
		} -- 1421
	) -- 1421
	DB:exec( -- 1423
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1423
		{ -- 1425
			nextSeq, -- 1425
			now(), -- 1425
			taskId -- 1425
		} -- 1425
	) -- 1425
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1427
end -- 1337
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1435
	if not isValidWorkDir(workDir) then -- 1435
		return {success = false, message = "invalid workDir"} -- 1436
	end -- 1436
	if checkpointId <= 0 then -- 1436
		return {success = false, message = "invalid checkpointId"} -- 1437
	end -- 1437
	local entries = getCheckpointEntries(checkpointId, true) -- 1438
	if #entries == 0 then -- 1438
		return {success = false, message = "checkpoint not found or empty"} -- 1440
	end -- 1440
	for ____, entry in ipairs(entries) do -- 1442
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1443
		if not fullPath then -- 1443
			return {success = false, message = "invalid path: " .. entry.path} -- 1445
		end -- 1445
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1447
		if not ok then -- 1447
			Log( -- 1449
				"Error", -- 1449
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1449
			) -- 1449
			Log( -- 1450
				"Info", -- 1450
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1450
			) -- 1450
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1451
		end -- 1451
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1451
			Log( -- 1454
				"Error", -- 1454
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1454
			) -- 1454
			Log( -- 1455
				"Info", -- 1455
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1455
			) -- 1455
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1456
		end -- 1456
	end -- 1456
	DB:exec( -- 1459
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 1459
		{ -- 1459
			"REVERTED", -- 1459
			now(), -- 1459
			checkpointId -- 1459
		} -- 1459
	) -- 1459
	return {success = true, checkpointId = checkpointId} -- 1460
end -- 1435
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 1463
	if not isValidWorkDir(workDir) then -- 1463
		return {success = false, message = "invalid workDir"} -- 1464
	end -- 1464
	if not getTaskStatus(taskId) then -- 1464
		return {success = false, message = "task not found"} -- 1465
	end -- 1465
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 1466
	if #checkpoints == 0 then -- 1466
		return {success = false, message = "change set not found or empty"} -- 1468
	end -- 1468
	local lastCheckpointId = 0 -- 1470
	do -- 1470
		local i = 0 -- 1471
		while i < #checkpoints do -- 1471
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 1472
			if not result.success then -- 1472
				return {success = false, message = result.message} -- 1473
			end -- 1473
			lastCheckpointId = checkpoints[i + 1].id -- 1474
			i = i + 1 -- 1471
		end -- 1471
	end -- 1471
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 1476
end -- 1463
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1484
	return getCheckpointEntries(checkpointId, false) -- 1485
end -- 1484
function ____exports.getCheckpointDiff(checkpointId) -- 1488
	if checkpointId <= 0 then -- 1488
		return {success = false, message = "invalid checkpointId"} -- 1490
	end -- 1490
	local entries = getCheckpointEntries(checkpointId, false) -- 1492
	if #entries == 0 then -- 1492
		return {success = false, message = "checkpoint not found or empty"} -- 1494
	end -- 1494
	return { -- 1496
		success = true, -- 1497
		files = __TS__ArrayMap( -- 1498
			entries, -- 1498
			function(____, entry) return { -- 1498
				path = entry.path, -- 1499
				op = entry.op, -- 1500
				beforeExists = entry.beforeExists, -- 1501
				afterExists = entry.afterExists, -- 1502
				beforeContent = entry.beforeContent, -- 1503
				afterContent = entry.afterContent -- 1504
			} end -- 1504
		) -- 1504
	} -- 1504
end -- 1488
local function finalizeBuildResult(workDir, messages) -- 1509
	local normalized = __TS__ArrayMap( -- 1510
		messages, -- 1510
		function(____, m) return m.success and __TS__ObjectAssign( -- 1510
			{}, -- 1511
			m, -- 1511
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1511
		) or __TS__ObjectAssign( -- 1511
			{}, -- 1512
			m, -- 1512
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1512
		) end -- 1512
	) -- 1512
	local total = #normalized -- 1513
	local failed = 0 -- 1514
	do -- 1514
		local i = 0 -- 1515
		while i < #normalized do -- 1515
			if not normalized[i + 1].success then -- 1515
				failed = failed + 1 -- 1516
			end -- 1516
			i = i + 1 -- 1515
		end -- 1515
	end -- 1515
	local passed = total - failed -- 1518
	if failed > 0 then -- 1518
		return { -- 1520
			success = false, -- 1521
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 1522
			total = total, -- 1523
			passed = passed, -- 1524
			failed = failed, -- 1525
			messages = normalized -- 1526
		} -- 1526
	end -- 1526
	return { -- 1529
		success = true, -- 1530
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 1531
		total = total, -- 1532
		passed = passed, -- 1533
		failed = 0, -- 1534
		messages = normalized -- 1535
	} -- 1535
end -- 1509
function ____exports.build(req) -- 1539
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1539
		local targetRel = req.path or "" -- 1540
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1541
		if not target then -- 1541
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1541
		end -- 1541
		if not Content:exist(target) then -- 1541
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1541
		end -- 1541
		local messages = {} -- 1548
		if not Content:isdir(target) then -- 1548
			local kind = getSupportedBuildKind(target) -- 1550
			if not kind then -- 1550
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1550
			end -- 1550
			if kind == "ts" then -- 1550
				local content = Content:load(target) -- 1555
				if content == nil then -- 1555
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1555
				end -- 1555
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1555
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1555
				end -- 1555
				if not isDtsFile(target) then -- 1555
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1563
				end -- 1563
			else -- 1563
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1566
			end -- 1566
			Log( -- 1568
				"Info", -- 1568
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1568
			) -- 1568
			return ____awaiter_resolve( -- 1568
				nil, -- 1568
				finalizeBuildResult(req.workDir, messages) -- 1569
			) -- 1569
		end -- 1569
		local listResult = ____exports.listFiles({ -- 1571
			workDir = req.workDir, -- 1572
			path = targetRel, -- 1573
			globs = __TS__ArrayMap( -- 1574
				codeExtensions, -- 1574
				function(____, e) return "**/*" .. e end -- 1574
			), -- 1574
			maxEntries = 10000 -- 1575
		}) -- 1575
		local relFiles = listResult.success and listResult.files or ({}) -- 1578
		local tsFileData = {} -- 1579
		local buildQueue = {} -- 1580
		for ____, rel in ipairs(relFiles) do -- 1581
			do -- 1581
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1582
				local kind = getSupportedBuildKind(file) -- 1583
				if not kind then -- 1583
					goto __continue312 -- 1584
				end -- 1584
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1585
				if kind ~= "ts" then -- 1585
					goto __continue312 -- 1587
				end -- 1587
				local content = Content:load(file) -- 1589
				if content == nil then -- 1589
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1591
					goto __continue312 -- 1592
				end -- 1592
				tsFileData[file] = content -- 1594
				if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1594
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1596
					goto __continue312 -- 1597
				end -- 1597
			end -- 1597
			::__continue312:: -- 1597
		end -- 1597
		do -- 1597
			local i = 0 -- 1600
			while i < #buildQueue do -- 1600
				do -- 1600
					local ____buildQueue_index_20 = buildQueue[i + 1] -- 1601
					local file = ____buildQueue_index_20.file -- 1601
					local kind = ____buildQueue_index_20.kind -- 1601
					if kind == "ts" then -- 1601
						local content = tsFileData[file] -- 1603
						if content == nil or isDtsFile(file) then -- 1603
							goto __continue319 -- 1605
						end -- 1605
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1607
						goto __continue319 -- 1608
					end -- 1608
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1610
				end -- 1610
				::__continue319:: -- 1610
				i = i + 1 -- 1600
			end -- 1600
		end -- 1600
		if #messages == 0 then -- 1600
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 1613
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 1613
		end -- 1613
		Log( -- 1616
			"Info", -- 1616
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1616
		) -- 1616
		return ____awaiter_resolve( -- 1616
			nil, -- 1616
			finalizeBuildResult(req.workDir, messages) -- 1617
		) -- 1617
	end) -- 1617
end -- 1539
return ____exports -- 1539