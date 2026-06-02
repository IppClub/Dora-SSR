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
function getEngineLogText() -- 905
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 906
	if not Content:exist(folder) then -- 906
		Content:mkdir(folder) -- 908
	end -- 908
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 910
	if not App:saveLog(logPath) then -- 910
		return nil -- 912
	end -- 912
	return Content:load(logPath) -- 914
end -- 914
function ensureSafeSearchGlobs(globs) -- 1054
	local result = {} -- 1055
	do -- 1055
		local i = 0 -- 1056
		while i < #globs do -- 1056
			result[#result + 1] = globs[i + 1] -- 1057
			i = i + 1 -- 1056
		end -- 1056
	end -- 1056
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1059
	do -- 1059
		local i = 0 -- 1060
		while i < #requiredExcludes do -- 1060
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1060
				result[#result + 1] = requiredExcludes[i + 1] -- 1062
			end -- 1062
			i = i + 1 -- 1060
		end -- 1060
	end -- 1060
	return result -- 1065
end -- 1065
local TABLE_TASK = "AgentTask" -- 232
local TABLE_CP = "AgentCheckpoint" -- 233
local TABLE_ENTRY = "AgentCheckpointEntry" -- 234
ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 235
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 236
local function now() -- 238
	return os.time() -- 238
end -- 238
local function toBool(v) -- 240
	return v ~= 0 and v ~= false and v ~= nil -- 241
end -- 240
local function toStr(v) -- 244
	if v == false or v == nil then -- 244
		return "" -- 245
	end -- 245
	return tostring(v) -- 246
end -- 244
local function isValidWorkspacePath(path) -- 249
	if not path or #path == 0 then -- 249
		return false -- 250
	end -- 250
	if Content:isAbsolutePath(path) then -- 250
		return false -- 251
	end -- 251
	if __TS__StringIncludes(path, "..") then -- 251
		return false -- 252
	end -- 252
	return true -- 253
end -- 249
local function isValidWorkDir(workDir) -- 256
	if not workDir or #workDir == 0 then -- 256
		return false -- 257
	end -- 257
	if not Content:isAbsolutePath(workDir) then -- 257
		return false -- 258
	end -- 258
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 258
		return false -- 259
	end -- 259
	return true -- 260
end -- 256
local function isValidSearchPath(path) -- 263
	if path == "" then -- 263
		return true -- 264
	end -- 264
	if Content:isAbsolutePath(path) then -- 264
		return false -- 265
	end -- 265
	if not path or #path == 0 then -- 265
		return false -- 266
	end -- 266
	if __TS__StringIncludes(path, "..") then -- 266
		return false -- 267
	end -- 267
	return true -- 268
end -- 263
local function resolveWorkspaceFilePath(workDir, path) -- 271
	if not isValidWorkDir(workDir) then -- 271
		return nil -- 272
	end -- 272
	if not isValidWorkspacePath(path) then -- 272
		return nil -- 273
	end -- 273
	return Path(workDir, path) -- 274
end -- 271
local function resolveWorkspaceSearchPath(workDir, path) -- 277
	if not isValidWorkDir(workDir) then -- 277
		return nil -- 278
	end -- 278
	if not isValidSearchPath(path) then -- 278
		return nil -- 279
	end -- 279
	return path == "" and workDir or Path(workDir, path) -- 280
end -- 277
local function toWorkspaceRelativePath(workDir, path) -- 283
	if not path or #path == 0 then -- 283
		return path -- 284
	end -- 284
	if not Content:isAbsolutePath(path) then -- 284
		return path -- 285
	end -- 285
	return Path:getRelative(path, workDir) -- 286
end -- 283
local function toWorkspaceRelativeFileList(workDir, files) -- 289
	return __TS__ArrayMap( -- 290
		files, -- 290
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 290
	) -- 290
end -- 289
local function toWorkspaceRelativeSearchResults(workDir, results) -- 293
	local mapped = {} -- 294
	do -- 294
		local i = 0 -- 295
		while i < #results do -- 295
			local row = results[i + 1] -- 296
			local clone = __TS__ObjectAssign({}, row) -- 297
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 298
			mapped[#mapped + 1] = clone -- 299
			i = i + 1 -- 295
		end -- 295
	end -- 295
	return mapped -- 301
end -- 293
local function getDoraAPIDocRoot(docLanguage) -- 304
	local zhDir = Path( -- 305
		Content.assetPath, -- 305
		"Script", -- 305
		"Lib", -- 305
		"Dora", -- 305
		"zh-Hans" -- 305
	) -- 305
	local enDir = Path( -- 306
		Content.assetPath, -- 306
		"Script", -- 306
		"Lib", -- 306
		"Dora", -- 306
		"en" -- 306
	) -- 306
	return docLanguage == "zh" and zhDir or enDir -- 307
end -- 304
local function getDoraTutorialDocRoot(docLanguage) -- 310
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 311
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 312
	return docLanguage == "zh" and zhDir or enDir -- 313
end -- 310
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 316
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 316
		return {"ts"} -- 318
	end -- 318
	return {"tl"} -- 320
end -- 316
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 323
	repeat -- 323
		local ____switch38 = programmingLanguage -- 323
		local ____cond38 = ____switch38 == "teal" -- 323
		if ____cond38 then -- 323
			return "tl" -- 325
		end -- 325
		____cond38 = ____cond38 or ____switch38 == "tl" -- 325
		if ____cond38 then -- 325
			return "tl" -- 326
		end -- 326
		do -- 326
			return programmingLanguage -- 327
		end -- 327
	until true -- 327
end -- 323
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 331
	if docSource == "tutorial" then -- 331
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 337
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 338
		return { -- 339
			root = Path(tutorialRoot, langDir), -- 340
			exts = {"md"}, -- 341
			globs = {"**/*.md"} -- 342
		} -- 342
	end -- 342
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 345
	return { -- 346
		root = getDoraAPIDocRoot(docLanguage), -- 347
		exts = exts, -- 348
		globs = __TS__ArrayMap( -- 349
			exts, -- 349
			function(____, ext) return "**/*." .. ext end -- 349
		) -- 349
	} -- 349
end -- 331
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 353
	if docSource == "tutorial" then -- 353
		return getDoraTutorialDocRoot(docLanguage) -- 355
	end -- 355
	return getDoraAPIDocRoot(docLanguage) -- 357
end -- 353
local function toDocRelativePath(baseRoot, path) -- 360
	if not path or #path == 0 then -- 360
		return path -- 361
	end -- 361
	if not Content:isAbsolutePath(path) then -- 361
		return path -- 362
	end -- 362
	return Path:getRelative(path, baseRoot) -- 363
end -- 360
local function resolveAgentTutorialDocFilePath(path, docLanguage) -- 366
	if not docLanguage then -- 366
		return nil -- 367
	end -- 367
	if not isValidWorkspacePath(path) then -- 367
		return nil -- 368
	end -- 368
	local candidate = Path( -- 369
		getDoraTutorialDocRoot(docLanguage), -- 369
		path -- 369
	) -- 369
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 369
		return candidate -- 371
	end -- 371
	return nil -- 373
end -- 366
local function ensureDirPath(dir) -- 376
	if not dir or dir == "." or dir == "" then -- 376
		return true -- 377
	end -- 377
	if Content:exist(dir) then -- 377
		return Content:isdir(dir) -- 378
	end -- 378
	local parent = Path:getPath(dir) -- 379
	if parent and parent ~= dir and parent ~= "." and parent ~= "" then -- 379
		if not ensureDirPath(parent) then -- 379
			return false -- 381
		end -- 381
	end -- 381
	return Content:mkdir(dir) -- 383
end -- 376
local function ensureDirForFile(path) -- 386
	local dir = Path:getPath(path) -- 387
	return ensureDirPath(dir) -- 388
end -- 386
local function getFileState(path) -- 391
	local exists = Content:exist(path) -- 392
	if not exists then -- 392
		return {exists = false, content = "", bytes = 0} -- 394
	end -- 394
	local content = Content:load(path) -- 400
	return {exists = true, content = content, bytes = #content} -- 401
end -- 391
local function inspectReadableFile(path) -- 408
	do -- 408
		local function ____catch(e) -- 408
			Log( -- 430
				"Warn", -- 430
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 430
			) -- 430
			return true, {success = true} -- 431
		end -- 431
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 431
			local size, isBinary = Content:getAttr(path) -- 410
			if size == nil then -- 410
				return true, {success = false, message = "failed to read file"} -- 412
			end -- 412
			if isBinary then -- 412
				return true, { -- 418
					success = false, -- 419
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 420
					size = type(size) == "number" and size or nil, -- 421
					isBinary = true -- 422
				} -- 422
			end -- 422
			return true, { -- 425
				success = true, -- 426
				size = type(size) == "number" and size or nil -- 427
			} -- 427
		end) -- 427
		if not ____try then -- 427
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 427
		end -- 427
		if ____hasReturned then -- 427
			return ____returnValue -- 409
		end -- 409
	end -- 409
end -- 408
local function isEngineLogFilePath(path) -- 435
	return path == ENGINE_LOG_FILE -- 436
end -- 435
local function readEngineLogFile(path) -- 439
	if not isEngineLogFilePath(path) then -- 439
		return nil -- 440
	end -- 440
	local content = getEngineLogText() -- 441
	if content == nil then -- 441
		return {success = false, message = "failed to read engine logs"} -- 443
	end -- 443
	return {success = true, content = content, size = #content} -- 445
end -- 439
local function queryOne(sql, args) -- 448
	local ____args_0 -- 449
	if args then -- 449
		____args_0 = DB:query(sql, args) -- 449
	else -- 449
		____args_0 = DB:query(sql) -- 449
	end -- 449
	local rows = ____args_0 -- 449
	if not rows or #rows == 0 then -- 449
		return nil -- 450
	end -- 450
	return rows[1] -- 451
end -- 448
do -- 448
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 456
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 464
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 475
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 476
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 489
end -- 489
local function isDtsFile(path) -- 492
	return Path:getExt(Path:getName(path)) == "d" -- 493
end -- 492
local function getSupportedBuildKind(path) -- 498
	repeat -- 498
		local ____switch73 = Path:getExt(path) -- 498
		local ____cond73 = ____switch73 == "ts" or ____switch73 == "tsx" -- 498
		if ____cond73 then -- 498
			return "ts" -- 500
		end -- 500
		____cond73 = ____cond73 or ____switch73 == "xml" -- 500
		if ____cond73 then -- 500
			return "xml" -- 501
		end -- 501
		____cond73 = ____cond73 or ____switch73 == "tl" -- 501
		if ____cond73 then -- 501
			return "teal" -- 502
		end -- 502
		____cond73 = ____cond73 or ____switch73 == "lua" -- 502
		if ____cond73 then -- 502
			return "lua" -- 503
		end -- 503
		____cond73 = ____cond73 or ____switch73 == "yue" -- 503
		if ____cond73 then -- 503
			return "yue" -- 504
		end -- 504
		____cond73 = ____cond73 or ____switch73 == "yarn" -- 504
		if ____cond73 then -- 504
			return "yarn" -- 505
		end -- 505
		do -- 505
			return nil -- 506
		end -- 506
	until true -- 506
end -- 498
local function getTaskHeadSeq(taskId) -- 510
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 511
	if not row then -- 511
		return nil -- 512
	end -- 512
	return row[1] or 0 -- 513
end -- 510
local function getTaskStatus(taskId) -- 516
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 517
	if not row then -- 517
		return nil -- 518
	end -- 518
	return toStr(row[1]) -- 519
end -- 516
local function getLastInsertRowId() -- 522
	local row = queryOne("SELECT last_insert_rowid()") -- 523
	return row and (row[1] or 0) or 0 -- 524
end -- 522
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 527
	DB:exec( -- 528
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 528
		{ -- 530
			taskId, -- 530
			seq, -- 530
			status, -- 530
			summary, -- 530
			toolName, -- 530
			now() -- 530
		} -- 530
	) -- 530
	return getLastInsertRowId() -- 532
end -- 527
local function getCheckpointEntries(checkpointId, desc) -- 535
	if desc == nil then -- 535
		desc = false -- 535
	end -- 535
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 536
	if not rows then -- 536
		return {} -- 543
	end -- 543
	local result = {} -- 544
	do -- 544
		local i = 0 -- 545
		while i < #rows do -- 545
			local row = rows[i + 1] -- 546
			result[#result + 1] = { -- 547
				id = row[1], -- 548
				ord = row[2], -- 549
				path = toStr(row[3]), -- 550
				op = toStr(row[4]), -- 551
				beforeExists = toBool(row[5]), -- 552
				beforeContent = toStr(row[6]), -- 553
				afterExists = toBool(row[7]), -- 554
				afterContent = toStr(row[8]) -- 555
			} -- 555
			i = i + 1 -- 545
		end -- 545
	end -- 545
	return result -- 558
end -- 535
local function rejectDuplicatePaths(changes) -- 561
	local seen = __TS__New(Set) -- 562
	for ____, change in ipairs(changes) do -- 563
		local key = change.path -- 564
		if seen:has(key) then -- 564
			return key -- 565
		end -- 565
		seen:add(key) -- 566
	end -- 566
	return nil -- 568
end -- 561
local function getLinkedDeletePaths(workDir, path) -- 571
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 572
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 572
		return {} -- 573
	end -- 573
	local parent = Path:getPath(fullPath) -- 574
	local baseName = string.lower(Path:getName(fullPath)) -- 575
	local ext = Path:getExt(fullPath) -- 576
	local linked = {} -- 577
	for ____, file in ipairs(Content:getFiles(parent)) do -- 578
		do -- 578
			if string.lower(Path:getName(file)) ~= baseName then -- 578
				goto __continue90 -- 579
			end -- 579
			local siblingExt = Path:getExt(file) -- 580
			if siblingExt == "tl" and ext == "vs" then -- 580
				linked[#linked + 1] = toWorkspaceRelativePath( -- 582
					workDir, -- 582
					Path(parent, file) -- 582
				) -- 582
				goto __continue90 -- 583
			end -- 583
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 583
				linked[#linked + 1] = toWorkspaceRelativePath( -- 586
					workDir, -- 586
					Path(parent, file) -- 586
				) -- 586
			end -- 586
		end -- 586
		::__continue90:: -- 586
	end -- 586
	return linked -- 589
end -- 571
local function expandLinkedDeleteChanges(workDir, changes) -- 592
	local expanded = {} -- 593
	local seen = __TS__New(Set) -- 594
	do -- 594
		local i = 0 -- 595
		while i < #changes do -- 595
			do -- 595
				local change = changes[i + 1] -- 596
				if not seen:has(change.path) then -- 596
					seen:add(change.path) -- 598
					expanded[#expanded + 1] = change -- 599
				end -- 599
				if change.op ~= "delete" then -- 599
					goto __continue97 -- 601
				end -- 601
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 602
				do -- 602
					local j = 0 -- 603
					while j < #linkedPaths do -- 603
						do -- 603
							local linkedPath = linkedPaths[j + 1] -- 604
							if seen:has(linkedPath) then -- 604
								goto __continue101 -- 605
							end -- 605
							seen:add(linkedPath) -- 606
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 607
						end -- 607
						::__continue101:: -- 607
						j = j + 1 -- 603
					end -- 603
				end -- 603
			end -- 603
			::__continue97:: -- 603
			i = i + 1 -- 595
		end -- 595
	end -- 595
	return expanded -- 610
end -- 592
local function applySingleFile(path, exists, content) -- 613
	if exists then -- 613
		if not ensureDirForFile(path) then -- 613
			return false -- 615
		end -- 615
		return Content:save(path, content) -- 616
	end -- 616
	if Content:exist(path) then -- 616
		return Content:remove(path) -- 619
	end -- 619
	return true -- 621
end -- 613
local function encodeJSON(obj) -- 624
	local text = safeJsonEncode(obj) -- 625
	return text -- 626
end -- 624
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 629
	if HttpServer.wsConnectionCount == 0 then -- 629
		return true -- 631
	end -- 631
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 633
	if not payload then -- 633
		return false -- 635
	end -- 635
	emit("AppWS", "Send", payload) -- 637
	return true -- 638
end -- 629
local function runSingleNonTsBuild(file) -- 641
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 641
		return ____awaiter_resolve( -- 641
			nil, -- 641
			__TS__New( -- 642
				__TS__Promise, -- 642
				function(____, resolve) -- 642
					local moduleName = "Script.Dev.WebServer" -- 643
					local ____require_result_1 = require(moduleName) -- 644
					local buildAsync = ____require_result_1.buildAsync -- 644
					Director.systemScheduler:schedule(once(function() -- 645
						local result = buildAsync(file) -- 646
						resolve(nil, result) -- 647
					end)) -- 645
				end -- 642
			) -- 642
		) -- 642
	end) -- 642
end -- 641
function ____exports.runSingleTsTranspile(file, content) -- 652
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 652
		local done = false -- 653
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 654
		if HttpServer.wsConnectionCount == 0 then -- 654
			return ____awaiter_resolve(nil, result) -- 654
		end -- 654
		local listener = Node() -- 662
		listener:gslot( -- 663
			"AppWS", -- 663
			function(event) -- 663
				if event.type ~= "Receive" then -- 663
					return -- 664
				end -- 664
				local res = safeJsonDecode(event.msg) -- 665
				if not res or __TS__ArrayIsArray(res) then -- 665
					return -- 666
				end -- 666
				local payload = res -- 667
				if payload.name ~= "TranspileTS" then -- 667
					return -- 668
				end -- 668
				if tostring(payload.file) ~= file then -- 668
					return -- 669
				end -- 669
				if payload.success then -- 669
					local luaFile = Path:replaceExt(file, "lua") -- 671
					if Content:save( -- 671
						luaFile, -- 672
						tostring(payload.luaCode) -- 672
					) then -- 672
						result = {success = true, file = file} -- 673
					else -- 673
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 675
					end -- 675
				else -- 675
					result = { -- 678
						success = false, -- 678
						file = file, -- 678
						message = tostring(payload.message) -- 678
					} -- 678
				end -- 678
				done = true -- 680
			end -- 663
		) -- 663
		local payload = encodeJSON({name = "TranspileTS", file = file, content = content}) -- 682
		if not payload then -- 682
			listener:removeFromParent() -- 688
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 688
		end -- 688
		__TS__Await(__TS__New( -- 691
			__TS__Promise, -- 691
			function(____, resolve) -- 691
				Director.systemScheduler:schedule(once(function() -- 692
					emit("AppWS", "Send", payload) -- 693
					wait(function() return done end) -- 694
					if not done then -- 694
						listener:removeFromParent() -- 696
					end -- 696
					resolve(nil) -- 698
				end)) -- 692
			end -- 691
		)) -- 691
		return ____awaiter_resolve(nil, result) -- 691
	end) -- 691
end -- 652
function ____exports.createTask(prompt) -- 704
	if prompt == nil then -- 704
		prompt = "" -- 704
	end -- 704
	local t = now() -- 705
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 706
	if affected <= 0 then -- 706
		return {success = false, message = "failed to create task"} -- 711
	end -- 711
	return { -- 713
		success = true, -- 713
		taskId = getLastInsertRowId() -- 713
	} -- 713
end -- 704
function ____exports.setTaskStatus(taskId, status) -- 716
	DB:exec( -- 717
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 717
		{ -- 717
			status, -- 717
			now(), -- 717
			taskId -- 717
		} -- 717
	) -- 717
	Log( -- 718
		"Info", -- 718
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 718
	) -- 718
end -- 716
function ____exports.listCheckpoints(taskId) -- 721
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 722
	if not rows then -- 722
		return {} -- 729
	end -- 729
	local items = {} -- 730
	do -- 730
		local i = 0 -- 731
		while i < #rows do -- 731
			local row = rows[i + 1] -- 732
			items[#items + 1] = { -- 733
				id = row[1], -- 734
				taskId = row[2], -- 735
				seq = row[3], -- 736
				status = toStr(row[4]), -- 737
				summary = toStr(row[5]), -- 738
				toolName = toStr(row[6]), -- 739
				createdAt = row[7] -- 740
			} -- 740
			i = i + 1 -- 731
		end -- 731
	end -- 731
	return items -- 743
end -- 721
local function listCheckpointIdsForTask(taskId, desc) -- 746
	if desc == nil then -- 746
		desc = false -- 746
	end -- 746
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 747
	if not rows then -- 747
		return {} -- 754
	end -- 754
	local items = {} -- 755
	do -- 755
		local i = 0 -- 756
		while i < #rows do -- 756
			local row = rows[i + 1] -- 757
			items[#items + 1] = {id = row[1], seq = row[2]} -- 758
			i = i + 1 -- 756
		end -- 756
	end -- 756
	return items -- 763
end -- 746
local function deriveFileOp(beforeExists, afterExists) -- 766
	if not beforeExists and afterExists then -- 766
		return "create" -- 767
	end -- 767
	if beforeExists and not afterExists then -- 767
		return "delete" -- 768
	end -- 768
	return "write" -- 769
end -- 766
function ____exports.summarizeTaskChangeSet(taskId) -- 772
	if not getTaskStatus(taskId) then -- 772
		return {success = false, message = "task not found"} -- 774
	end -- 774
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 776
	local filesByPath = {} -- 777
	local latestCheckpointId = nil -- 783
	local latestCheckpointSeq = nil -- 784
	do -- 784
		local i = 0 -- 785
		while i < #checkpoints do -- 785
			local checkpoint = checkpoints[i + 1] -- 786
			latestCheckpointId = checkpoint.id -- 787
			latestCheckpointSeq = checkpoint.seq -- 788
			local entries = getCheckpointEntries(checkpoint.id, false) -- 789
			do -- 789
				local j = 0 -- 790
				while j < #entries do -- 790
					local entry = entries[j + 1] -- 791
					local item = filesByPath[entry.path] -- 792
					if not item then -- 792
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 794
						filesByPath[entry.path] = item -- 800
					end -- 800
					item.afterExists = entry.afterExists -- 802
					local ____item_checkpointIds_2 = item.checkpointIds -- 802
					____item_checkpointIds_2[#____item_checkpointIds_2 + 1] = checkpoint.id -- 803
					j = j + 1 -- 790
				end -- 790
			end -- 790
			i = i + 1 -- 785
		end -- 785
	end -- 785
	local files = {} -- 806
	for ____, item in pairs(filesByPath) do -- 807
		files[#files + 1] = { -- 808
			path = item.path, -- 809
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 810
			checkpointCount = #item.checkpointIds, -- 811
			checkpointIds = item.checkpointIds -- 812
		} -- 812
	end -- 812
	__TS__ArraySort( -- 815
		files, -- 815
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 815
	) -- 815
	return { -- 816
		success = true, -- 817
		taskId = taskId, -- 818
		checkpointCount = #checkpoints, -- 819
		filesChanged = #files, -- 820
		files = files, -- 821
		latestCheckpointId = latestCheckpointId, -- 822
		latestCheckpointSeq = latestCheckpointSeq -- 823
	} -- 823
end -- 772
function ____exports.getTaskChangeSetDiff(taskId) -- 827
	if not getTaskStatus(taskId) then -- 827
		return {success = false, message = "task not found"} -- 829
	end -- 829
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 831
	if #checkpoints == 0 then -- 831
		return {success = false, message = "change set not found or empty"} -- 833
	end -- 833
	local filesByPath = {} -- 835
	do -- 835
		local i = 0 -- 842
		while i < #checkpoints do -- 842
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 843
			do -- 843
				local j = 0 -- 844
				while j < #entries do -- 844
					local entry = entries[j + 1] -- 845
					local item = filesByPath[entry.path] -- 846
					if not item then -- 846
						item = { -- 848
							path = entry.path, -- 849
							beforeExists = entry.beforeExists, -- 850
							beforeContent = entry.beforeContent, -- 851
							afterExists = entry.afterExists, -- 852
							afterContent = entry.afterContent -- 853
						} -- 853
						filesByPath[entry.path] = item -- 855
					end -- 855
					item.afterExists = entry.afterExists -- 857
					item.afterContent = entry.afterContent -- 858
					j = j + 1 -- 844
				end -- 844
			end -- 844
			i = i + 1 -- 842
		end -- 842
	end -- 842
	local files = {} -- 861
	for ____, item in pairs(filesByPath) do -- 862
		files[#files + 1] = { -- 863
			path = item.path, -- 864
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 865
			beforeExists = item.beforeExists, -- 866
			afterExists = item.afterExists, -- 867
			beforeContent = item.beforeContent, -- 868
			afterContent = item.afterContent -- 869
		} -- 869
	end -- 869
	__TS__ArraySort( -- 872
		files, -- 872
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 872
	) -- 872
	return {success = true, files = files} -- 873
end -- 827
local function readWorkspaceFile(workDir, path, docLanguage) -- 876
	local engineLog = readEngineLogFile(path) -- 877
	if engineLog then -- 877
		return engineLog -- 878
	end -- 878
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 879
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 879
		local attr = inspectReadableFile(fullPath) -- 881
		if not attr.success then -- 881
			return attr -- 882
		end -- 882
		return { -- 883
			success = true, -- 883
			content = Content:load(fullPath), -- 883
			size = attr.size -- 883
		} -- 883
	end -- 883
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 885
	if docPath then -- 885
		local attr = inspectReadableFile(docPath) -- 887
		if not attr.success then -- 887
			return attr -- 888
		end -- 888
		return { -- 889
			success = true, -- 889
			content = Content:load(docPath), -- 889
			size = attr.size -- 889
		} -- 889
	end -- 889
	if not fullPath then -- 889
		return {success = false, message = "invalid path or workDir"} -- 891
	end -- 891
	return {success = false, message = "file not found"} -- 892
end -- 876
function ____exports.readFileRaw(workDir, path, docLanguage) -- 895
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 896
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 896
		local attr = inspectReadableFile(path) -- 898
		if not attr.success then -- 898
			return attr -- 899
		end -- 899
		return { -- 900
			success = true, -- 900
			content = Content:load(path), -- 900
			size = attr.size -- 900
		} -- 900
	end -- 900
	return result -- 902
end -- 895
function ____exports.getLogs(req) -- 917
	local text = getEngineLogText() -- 918
	if text == nil then -- 918
		return {success = false, message = "failed to read engine logs"} -- 920
	end -- 920
	local tailLines = math.max( -- 922
		1, -- 922
		math.floor(req and req.tailLines or 200) -- 922
	) -- 922
	local allLines = __TS__StringSplit(text, "\n") -- 923
	local logs = __TS__ArraySlice( -- 924
		allLines, -- 924
		math.max(0, #allLines - tailLines) -- 924
	) -- 924
	return req and req.joinText and ({ -- 925
		success = true, -- 925
		logs = logs, -- 925
		text = table.concat(logs, "\n") -- 925
	}) or ({success = true, logs = logs}) -- 925
end -- 917
function ____exports.listFiles(req) -- 928
	local root = req.path or "" -- 934
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 935
	if not searchRoot then -- 935
		return {success = false, message = "invalid path or workDir"} -- 937
	end -- 937
	do -- 937
		local function ____catch(e) -- 937
			return true, { -- 955
				success = false, -- 955
				message = tostring(e) -- 955
			} -- 955
		end -- 955
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 955
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 940
			local globs = ensureSafeSearchGlobs(userGlobs) -- 941
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 942
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 943
			local totalEntries = #files -- 944
			local maxEntries = math.max( -- 945
				1, -- 945
				math.floor(req.maxEntries or 200) -- 945
			) -- 945
			local truncated = totalEntries > maxEntries -- 946
			return true, { -- 947
				success = true, -- 948
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 949
				totalEntries = totalEntries, -- 950
				truncated = truncated, -- 951
				maxEntries = maxEntries -- 952
			} -- 952
		end) -- 952
		if not ____try then -- 952
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 952
		end -- 952
		if ____hasReturned then -- 952
			return ____returnValue -- 939
		end -- 939
	end -- 939
end -- 928
local function formatReadSlice(content, startLine, endLine) -- 959
	local lines = __TS__StringSplit(content, "\n") -- 964
	local totalLines = #lines -- 965
	if totalLines == 0 then -- 965
		return { -- 967
			success = true, -- 968
			content = "", -- 969
			totalLines = 0, -- 970
			startLine = 1, -- 971
			endLine = 0, -- 972
			truncated = false -- 973
		} -- 973
	end -- 973
	local rawStart = math.floor(startLine) -- 976
	local rawEnd = math.floor(endLine) -- 977
	if rawStart == 0 then -- 977
		return {success = false, message = "startLine cannot be 0"} -- 979
	end -- 979
	if rawEnd == 0 then -- 979
		return {success = false, message = "endLine cannot be 0"} -- 982
	end -- 982
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 984
	if start > totalLines then -- 984
		return { -- 988
			success = false, -- 988
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 988
		} -- 988
	end -- 988
	local ____end = math.min( -- 990
		totalLines, -- 991
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 992
	) -- 992
	if ____end < start then -- 992
		return { -- 997
			success = false, -- 998
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 999
		} -- 999
	end -- 999
	local slice = {} -- 1002
	do -- 1002
		local i = start -- 1003
		while i <= ____end do -- 1003
			slice[#slice + 1] = lines[i] -- 1004
			i = i + 1 -- 1003
		end -- 1003
	end -- 1003
	local truncated = start > 1 or ____end < totalLines -- 1006
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1007
	local body = table.concat(slice, "\n") -- 1012
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1013
	return { -- 1014
		success = true, -- 1015
		content = output, -- 1016
		totalLines = totalLines, -- 1017
		startLine = start, -- 1018
		endLine = ____end, -- 1019
		truncated = truncated -- 1020
	} -- 1020
end -- 959
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1024
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1031
	if not fallback.success or fallback.content == nil then -- 1031
		return fallback -- 1032
	end -- 1032
	local resolvedStartLine = startLine or 1 -- 1033
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1034
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1035
end -- 1024
local codeExtensions = { -- 1042
	".lua", -- 1042
	".tl", -- 1042
	".yue", -- 1042
	".ts", -- 1042
	".tsx", -- 1042
	".xml", -- 1042
	".md", -- 1042
	".yarn", -- 1042
	".wa", -- 1042
	".mod" -- 1042
} -- 1042
extensionLevels = { -- 1043
	vs = 2, -- 1044
	bl = 2, -- 1045
	ts = 1, -- 1046
	tsx = 1, -- 1047
	tl = 1, -- 1048
	yue = 1, -- 1049
	xml = 1, -- 1050
	lua = 0 -- 1051
} -- 1051
local function splitSearchPatterns(pattern) -- 1068
	local trimmed = __TS__StringTrim(pattern or "") -- 1069
	if trimmed == "" then -- 1069
		return {} -- 1070
	end -- 1070
	local out = {} -- 1071
	local seen = __TS__New(Set) -- 1072
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1073
		local p = __TS__StringTrim(tostring(p0)) -- 1074
		if p ~= "" and not seen:has(p) then -- 1074
			seen:add(p) -- 1076
			out[#out + 1] = p -- 1077
		end -- 1077
	end -- 1077
	return out -- 1080
end -- 1068
local function mergeSearchFileResultsUnique(resultsList) -- 1083
	local merged = {} -- 1084
	local seen = __TS__New(Set) -- 1085
	do -- 1085
		local i = 0 -- 1086
		while i < #resultsList do -- 1086
			local list = resultsList[i + 1] -- 1087
			do -- 1087
				local j = 0 -- 1088
				while j < #list do -- 1088
					do -- 1088
						local row = list[j + 1] -- 1089
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1090
						if seen:has(key) then -- 1090
							goto __continue206 -- 1091
						end -- 1091
						seen:add(key) -- 1092
						merged[#merged + 1] = list[j + 1] -- 1093
					end -- 1093
					::__continue206:: -- 1093
					j = j + 1 -- 1088
				end -- 1088
			end -- 1088
			i = i + 1 -- 1086
		end -- 1086
	end -- 1086
	return merged -- 1096
end -- 1083
local function buildGroupedSearchResults(results) -- 1099
	local order = {} -- 1104
	local grouped = __TS__New(Map) -- 1105
	do -- 1105
		local i = 0 -- 1110
		while i < #results do -- 1110
			local row = results[i + 1] -- 1111
			local file = row.file -- 1112
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1113
			local bucket = grouped:get(key) -- 1114
			if not bucket then -- 1114
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1116
				grouped:set(key, bucket) -- 1117
				order[#order + 1] = key -- 1118
			end -- 1118
			bucket.totalMatches = bucket.totalMatches + 1 -- 1120
			local ____bucket_matches_7 = bucket.matches -- 1120
			____bucket_matches_7[#____bucket_matches_7 + 1] = results[i + 1] -- 1121
			i = i + 1 -- 1110
		end -- 1110
	end -- 1110
	local out = {} -- 1123
	do -- 1123
		local i = 0 -- 1128
		while i < #order do -- 1128
			local bucket = grouped:get(order[i + 1]) -- 1129
			if bucket then -- 1129
				out[#out + 1] = bucket -- 1130
			end -- 1130
			i = i + 1 -- 1128
		end -- 1128
	end -- 1128
	return out -- 1132
end -- 1099
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1135
	local merged = {} -- 1136
	local seen = __TS__New(Set) -- 1137
	local index = 0 -- 1138
	local advanced = true -- 1139
	while advanced do -- 1139
		advanced = false -- 1141
		do -- 1141
			local i = 0 -- 1142
			while i < #resultsList do -- 1142
				do -- 1142
					local list = resultsList[i + 1] -- 1143
					if index >= #list then -- 1143
						goto __continue218 -- 1144
					end -- 1144
					advanced = true -- 1145
					local row = list[index + 1] -- 1146
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1147
					if seen:has(key) then -- 1147
						goto __continue218 -- 1148
					end -- 1148
					seen:add(key) -- 1149
					merged[#merged + 1] = row -- 1150
				end -- 1150
				::__continue218:: -- 1150
				i = i + 1 -- 1142
			end -- 1142
		end -- 1142
		index = index + 1 -- 1152
	end -- 1152
	return merged -- 1154
end -- 1135
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1157
	if docSource ~= "api" then -- 1157
		return 100 -- 1158
	end -- 1158
	if programmingLanguage ~= "tsx" then -- 1158
		return 100 -- 1159
	end -- 1159
	repeat -- 1159
		local ____switch224 = string.lower(Path:getFilename(file)) -- 1159
		local ____cond224 = ____switch224 == "jsx.d.ts" -- 1159
		if ____cond224 then -- 1159
			return 0 -- 1161
		end -- 1161
		____cond224 = ____cond224 or ____switch224 == "dorax.d.ts" -- 1161
		if ____cond224 then -- 1161
			return 1 -- 1162
		end -- 1162
		____cond224 = ____cond224 or ____switch224 == "dora.d.ts" -- 1162
		if ____cond224 then -- 1162
			return 2 -- 1163
		end -- 1163
		do -- 1163
			return 100 -- 1164
		end -- 1164
	until true -- 1164
end -- 1157
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1168
	local sorted = __TS__ArraySlice(hits) -- 1173
	__TS__ArraySort( -- 1174
		sorted, -- 1174
		function(____, a, b) -- 1174
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1175
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1176
			if pa ~= pb then -- 1176
				return pa - pb -- 1177
			end -- 1177
			local fa = string.lower(a.file) -- 1178
			local fb = string.lower(b.file) -- 1179
			if fa ~= fb then -- 1179
				return fa < fb and -1 or 1 -- 1180
			end -- 1180
			return (a.line or 0) - (b.line or 0) -- 1181
		end -- 1174
	) -- 1174
	return sorted -- 1183
end -- 1168
function ____exports.searchFiles(req) -- 1186
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1186
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1199
		if not resolvedPath then -- 1199
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1199
		end -- 1199
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1203
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1204
		if not searchRoot then -- 1204
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1204
		end -- 1204
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1204
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1204
		end -- 1204
		local patterns = splitSearchPatterns(req.pattern) -- 1211
		if #patterns == 0 then -- 1211
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1211
		end -- 1211
		return ____awaiter_resolve( -- 1211
			nil, -- 1211
			__TS__New( -- 1215
				__TS__Promise, -- 1215
				function(____, resolve) -- 1215
					Director.systemScheduler:schedule(once(function() -- 1216
						do -- 1216
							local function ____catch(e) -- 1216
								resolve( -- 1258
									nil, -- 1258
									{ -- 1258
										success = false, -- 1258
										message = tostring(e) -- 1258
									} -- 1258
								) -- 1258
							end -- 1258
							local ____try, ____hasReturned = pcall(function() -- 1258
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1218
								local allResults = {} -- 1221
								do -- 1221
									local i = 0 -- 1222
									while i < #patterns do -- 1222
										local ____Content_12 = Content -- 1223
										local ____Content_searchFilesAsync_13 = Content.searchFilesAsync -- 1223
										local ____patterns_index_11 = patterns[i + 1] -- 1228
										local ____req_useRegex_8 = req.useRegex -- 1229
										if ____req_useRegex_8 == nil then -- 1229
											____req_useRegex_8 = false -- 1229
										end -- 1229
										local ____req_caseSensitive_9 = req.caseSensitive -- 1230
										if ____req_caseSensitive_9 == nil then -- 1230
											____req_caseSensitive_9 = false -- 1230
										end -- 1230
										local ____req_includeContent_10 = req.includeContent -- 1231
										if ____req_includeContent_10 == nil then -- 1231
											____req_includeContent_10 = true -- 1231
										end -- 1231
										allResults[#allResults + 1] = ____Content_searchFilesAsync_13( -- 1223
											____Content_12, -- 1223
											searchRoot, -- 1224
											codeExtensions, -- 1225
											extensionLevels, -- 1226
											searchGlobs, -- 1227
											____patterns_index_11, -- 1228
											____req_useRegex_8, -- 1229
											____req_caseSensitive_9, -- 1230
											____req_includeContent_10, -- 1231
											req.contentWindow or 120 -- 1232
										) -- 1232
										i = i + 1 -- 1222
									end -- 1222
								end -- 1222
								local results = mergeSearchFileResultsUnique(allResults) -- 1235
								local totalResults = #results -- 1236
								local limit = math.max( -- 1237
									1, -- 1237
									math.floor(req.limit or 20) -- 1237
								) -- 1237
								local offset = math.max( -- 1238
									0, -- 1238
									math.floor(req.offset or 0) -- 1238
								) -- 1238
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1239
								local nextOffset = offset + #paged -- 1240
								local hasMore = nextOffset < totalResults -- 1241
								local truncated = offset > 0 or hasMore -- 1242
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1243
								local groupByFile = req.groupByFile == true -- 1244
								resolve( -- 1245
									nil, -- 1245
									{ -- 1245
										success = true, -- 1246
										results = relativeResults, -- 1247
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1248
										totalResults = totalResults, -- 1249
										truncated = truncated, -- 1250
										limit = limit, -- 1251
										offset = offset, -- 1252
										nextOffset = nextOffset, -- 1253
										hasMore = hasMore, -- 1254
										groupByFile = groupByFile -- 1255
									} -- 1255
								) -- 1255
							end) -- 1255
							if not ____try then -- 1255
								____catch(____hasReturned) -- 1255
							end -- 1255
						end -- 1255
					end)) -- 1216
				end -- 1215
			) -- 1215
		) -- 1215
	end) -- 1215
end -- 1186
function ____exports.searchDoraAPI(req) -- 1264
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1264
		local pattern = __TS__StringTrim(req.pattern or "") -- 1275
		if pattern == "" then -- 1275
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1275
		end -- 1275
		local patterns = splitSearchPatterns(pattern) -- 1277
		if #patterns == 0 then -- 1277
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1277
		end -- 1277
		local docSource = req.docSource or "api" -- 1279
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1280
		local docRoot = target.root -- 1281
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1282
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1282
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1282
		end -- 1282
		local exts = target.exts -- 1286
		local dotExts = __TS__ArrayMap( -- 1287
			exts, -- 1287
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1287
		) -- 1287
		local globs = target.globs -- 1288
		local limit = math.max( -- 1289
			1, -- 1289
			math.floor(req.limit or 10) -- 1289
		) -- 1289
		return ____awaiter_resolve( -- 1289
			nil, -- 1289
			__TS__New( -- 1291
				__TS__Promise, -- 1291
				function(____, resolve) -- 1291
					Director.systemScheduler:schedule(once(function() -- 1292
						do -- 1292
							local function ____catch(e) -- 1292
								resolve( -- 1334
									nil, -- 1334
									{ -- 1334
										success = false, -- 1334
										message = tostring(e) -- 1334
									} -- 1334
								) -- 1334
							end -- 1334
							local ____try, ____hasReturned = pcall(function() -- 1334
								local allHits = {} -- 1294
								do -- 1294
									local p = 0 -- 1295
									while p < #patterns do -- 1295
										local ____Content_18 = Content -- 1296
										local ____Content_searchFilesAsync_19 = Content.searchFilesAsync -- 1296
										local ____array_17 = __TS__SparseArrayNew( -- 1296
											docRoot, -- 1297
											dotExts, -- 1298
											{}, -- 1299
											ensureSafeSearchGlobs(globs), -- 1300
											patterns[p + 1] -- 1301
										) -- 1301
										local ____req_useRegex_14 = req.useRegex -- 1302
										if ____req_useRegex_14 == nil then -- 1302
											____req_useRegex_14 = false -- 1302
										end -- 1302
										__TS__SparseArrayPush(____array_17, ____req_useRegex_14) -- 1302
										local ____req_caseSensitive_15 = req.caseSensitive -- 1303
										if ____req_caseSensitive_15 == nil then -- 1303
											____req_caseSensitive_15 = false -- 1303
										end -- 1303
										__TS__SparseArrayPush(____array_17, ____req_caseSensitive_15) -- 1303
										local ____req_includeContent_16 = req.includeContent -- 1304
										if ____req_includeContent_16 == nil then -- 1304
											____req_includeContent_16 = true -- 1304
										end -- 1304
										__TS__SparseArrayPush(____array_17, ____req_includeContent_16, req.contentWindow or 80) -- 1304
										local raw = ____Content_searchFilesAsync_19( -- 1296
											____Content_18, -- 1296
											__TS__SparseArraySpread(____array_17) -- 1296
										) -- 1296
										local hits = {} -- 1307
										do -- 1307
											local i = 0 -- 1308
											while i < #raw do -- 1308
												do -- 1308
													local row = raw[i + 1] -- 1309
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1310
													if file == "" then -- 1310
														goto __continue251 -- 1311
													end -- 1311
													hits[#hits + 1] = { -- 1312
														file = file, -- 1313
														line = type(row.line) == "number" and row.line or nil, -- 1314
														content = type(row.content) == "string" and row.content or nil -- 1315
													} -- 1315
												end -- 1315
												::__continue251:: -- 1315
												i = i + 1 -- 1308
											end -- 1308
										end -- 1308
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1318
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1318
											0, -- 1318
											limit -- 1318
										) -- 1318
										p = p + 1 -- 1295
									end -- 1295
								end -- 1295
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1320
								resolve(nil, { -- 1321
									success = true, -- 1322
									docSource = docSource, -- 1323
									docLanguage = req.docLanguage, -- 1324
									programmingLanguage = req.programmingLanguage, -- 1325
									exts = exts, -- 1326
									results = hits, -- 1327
									hint = "Use read_file directly with the file value from a search result to view the complete document. Do not add any prefixes.", -- 1328
									totalResults = #hits, -- 1329
									truncated = false, -- 1330
									limit = limit -- 1331
								}) -- 1331
							end) -- 1331
							if not ____try then -- 1331
								____catch(____hasReturned) -- 1331
							end -- 1331
						end -- 1331
					end)) -- 1292
				end -- 1291
			) -- 1291
		) -- 1291
	end) -- 1291
end -- 1264
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1340
	if options == nil then -- 1340
		options = {} -- 1340
	end -- 1340
	if #changes == 0 then -- 1340
		return {success = false, message = "empty changes"} -- 1342
	end -- 1342
	if not isValidWorkDir(workDir) then -- 1342
		return {success = false, message = "invalid workDir"} -- 1345
	end -- 1345
	if not getTaskStatus(taskId) then -- 1345
		return {success = false, message = "task not found"} -- 1348
	end -- 1348
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1350
	local dup = rejectDuplicatePaths(expandedChanges) -- 1351
	if dup then -- 1351
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1353
	end -- 1353
	for ____, change in ipairs(expandedChanges) do -- 1356
		if not isValidWorkspacePath(change.path) then -- 1356
			return {success = false, message = "invalid path: " .. change.path} -- 1358
		end -- 1358
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1358
			return {success = false, message = "missing content for " .. change.path} -- 1361
		end -- 1361
	end -- 1361
	local headSeq = getTaskHeadSeq(taskId) -- 1365
	if headSeq == nil then -- 1365
		return {success = false, message = "task not found"} -- 1366
	end -- 1366
	local nextSeq = headSeq + 1 -- 1367
	local checkpointId = insertCheckpoint( -- 1368
		taskId, -- 1368
		nextSeq, -- 1368
		options.summary or "", -- 1368
		options.toolName or "", -- 1368
		"PREPARED" -- 1368
	) -- 1368
	if checkpointId <= 0 then -- 1368
		return {success = false, message = "failed to create checkpoint"} -- 1370
	end -- 1370
	do -- 1370
		local i = 0 -- 1373
		while i < #expandedChanges do -- 1373
			local change = expandedChanges[i + 1] -- 1374
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1375
			if not fullPath then -- 1375
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1377
				return {success = false, message = "invalid path: " .. change.path} -- 1378
			end -- 1378
			local before = getFileState(fullPath) -- 1380
			local afterExists = change.op ~= "delete" -- 1381
			local afterContent = afterExists and (change.content or "") or "" -- 1382
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1383
				checkpointId, -- 1387
				i + 1, -- 1388
				change.path, -- 1389
				change.op, -- 1390
				before.exists and 1 or 0, -- 1391
				before.content, -- 1392
				afterExists and 1 or 0, -- 1393
				afterContent, -- 1394
				before.bytes, -- 1395
				#afterContent -- 1396
			}) -- 1396
			if inserted <= 0 then -- 1396
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1400
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1401
			end -- 1401
			i = i + 1 -- 1373
		end -- 1373
	end -- 1373
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1405
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1406
		if not fullPath then -- 1406
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1408
			return {success = false, message = "invalid path: " .. entry.path} -- 1409
		end -- 1409
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1411
		if not ok then -- 1411
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1413
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1414
		end -- 1414
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1414
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1417
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1418
		end -- 1418
	end -- 1418
	DB:exec( -- 1422
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1422
		{ -- 1424
			"APPLIED", -- 1424
			now(), -- 1424
			checkpointId -- 1424
		} -- 1424
	) -- 1424
	DB:exec( -- 1426
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1426
		{ -- 1428
			nextSeq, -- 1428
			now(), -- 1428
			taskId -- 1428
		} -- 1428
	) -- 1428
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1430
end -- 1340
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1438
	if not isValidWorkDir(workDir) then -- 1438
		return {success = false, message = "invalid workDir"} -- 1439
	end -- 1439
	if checkpointId <= 0 then -- 1439
		return {success = false, message = "invalid checkpointId"} -- 1440
	end -- 1440
	local entries = getCheckpointEntries(checkpointId, true) -- 1441
	if #entries == 0 then -- 1441
		return {success = false, message = "checkpoint not found or empty"} -- 1443
	end -- 1443
	for ____, entry in ipairs(entries) do -- 1445
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1446
		if not fullPath then -- 1446
			return {success = false, message = "invalid path: " .. entry.path} -- 1448
		end -- 1448
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1450
		if not ok then -- 1450
			Log( -- 1452
				"Error", -- 1452
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1452
			) -- 1452
			Log( -- 1453
				"Info", -- 1453
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1453
			) -- 1453
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1454
		end -- 1454
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1454
			Log( -- 1457
				"Error", -- 1457
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1457
			) -- 1457
			Log( -- 1458
				"Info", -- 1458
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1458
			) -- 1458
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1459
		end -- 1459
	end -- 1459
	DB:exec( -- 1462
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 1462
		{ -- 1462
			"REVERTED", -- 1462
			now(), -- 1462
			checkpointId -- 1462
		} -- 1462
	) -- 1462
	return {success = true, checkpointId = checkpointId} -- 1463
end -- 1438
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 1466
	if not isValidWorkDir(workDir) then -- 1466
		return {success = false, message = "invalid workDir"} -- 1467
	end -- 1467
	if not getTaskStatus(taskId) then -- 1467
		return {success = false, message = "task not found"} -- 1468
	end -- 1468
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 1469
	if #checkpoints == 0 then -- 1469
		return {success = false, message = "change set not found or empty"} -- 1471
	end -- 1471
	local lastCheckpointId = 0 -- 1473
	do -- 1473
		local i = 0 -- 1474
		while i < #checkpoints do -- 1474
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 1475
			if not result.success then -- 1475
				return {success = false, message = result.message} -- 1476
			end -- 1476
			lastCheckpointId = checkpoints[i + 1].id -- 1477
			i = i + 1 -- 1474
		end -- 1474
	end -- 1474
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 1479
end -- 1466
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1487
	return getCheckpointEntries(checkpointId, false) -- 1488
end -- 1487
function ____exports.getCheckpointDiff(checkpointId) -- 1491
	if checkpointId <= 0 then -- 1491
		return {success = false, message = "invalid checkpointId"} -- 1493
	end -- 1493
	local entries = getCheckpointEntries(checkpointId, false) -- 1495
	if #entries == 0 then -- 1495
		return {success = false, message = "checkpoint not found or empty"} -- 1497
	end -- 1497
	return { -- 1499
		success = true, -- 1500
		files = __TS__ArrayMap( -- 1501
			entries, -- 1501
			function(____, entry) return { -- 1501
				path = entry.path, -- 1502
				op = entry.op, -- 1503
				beforeExists = entry.beforeExists, -- 1504
				afterExists = entry.afterExists, -- 1505
				beforeContent = entry.beforeContent, -- 1506
				afterContent = entry.afterContent -- 1507
			} end -- 1507
		) -- 1507
	} -- 1507
end -- 1491
local function finalizeBuildResult(workDir, messages) -- 1512
	local normalized = __TS__ArrayMap( -- 1513
		messages, -- 1513
		function(____, m) return m.success and __TS__ObjectAssign( -- 1513
			{}, -- 1514
			m, -- 1514
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1514
		) or __TS__ObjectAssign( -- 1514
			{}, -- 1515
			m, -- 1515
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1515
		) end -- 1515
	) -- 1515
	local total = #normalized -- 1516
	local failed = 0 -- 1517
	do -- 1517
		local i = 0 -- 1518
		while i < #normalized do -- 1518
			if not normalized[i + 1].success then -- 1518
				failed = failed + 1 -- 1519
			end -- 1519
			i = i + 1 -- 1518
		end -- 1518
	end -- 1518
	local passed = total - failed -- 1521
	if failed > 0 then -- 1521
		return { -- 1523
			success = false, -- 1524
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 1525
			total = total, -- 1526
			passed = passed, -- 1527
			failed = failed, -- 1528
			messages = normalized -- 1529
		} -- 1529
	end -- 1529
	return { -- 1532
		success = true, -- 1533
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 1534
		total = total, -- 1535
		passed = passed, -- 1536
		failed = 0, -- 1537
		messages = normalized -- 1538
	} -- 1538
end -- 1512
function ____exports.build(req) -- 1542
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1542
		local targetRel = req.path or "" -- 1543
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1544
		if not target then -- 1544
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1544
		end -- 1544
		if not Content:exist(target) then -- 1544
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1544
		end -- 1544
		local messages = {} -- 1551
		if not Content:isdir(target) then -- 1551
			local kind = getSupportedBuildKind(target) -- 1553
			if not kind then -- 1553
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1553
			end -- 1553
			if kind == "ts" then -- 1553
				local content = Content:load(target) -- 1558
				if content == nil then -- 1558
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1558
				end -- 1558
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1558
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1558
				end -- 1558
				if not isDtsFile(target) then -- 1558
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1566
				end -- 1566
			else -- 1566
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1569
			end -- 1569
			Log( -- 1571
				"Info", -- 1571
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1571
			) -- 1571
			return ____awaiter_resolve( -- 1571
				nil, -- 1571
				finalizeBuildResult(req.workDir, messages) -- 1572
			) -- 1572
		end -- 1572
		local listResult = ____exports.listFiles({ -- 1574
			workDir = req.workDir, -- 1575
			path = targetRel, -- 1576
			globs = __TS__ArrayMap( -- 1577
				codeExtensions, -- 1577
				function(____, e) return "**/*" .. e end -- 1577
			), -- 1577
			maxEntries = 10000 -- 1578
		}) -- 1578
		local relFiles = listResult.success and listResult.files or ({}) -- 1581
		local tsFileData = {} -- 1582
		local buildQueue = {} -- 1583
		for ____, rel in ipairs(relFiles) do -- 1584
			do -- 1584
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1585
				local kind = getSupportedBuildKind(file) -- 1586
				if not kind then -- 1586
					goto __continue312 -- 1587
				end -- 1587
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1588
				if kind ~= "ts" then -- 1588
					goto __continue312 -- 1590
				end -- 1590
				local content = Content:load(file) -- 1592
				if content == nil then -- 1592
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1594
					goto __continue312 -- 1595
				end -- 1595
				tsFileData[file] = content -- 1597
				if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1597
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1599
					goto __continue312 -- 1600
				end -- 1600
			end -- 1600
			::__continue312:: -- 1600
		end -- 1600
		do -- 1600
			local i = 0 -- 1603
			while i < #buildQueue do -- 1603
				do -- 1603
					local ____buildQueue_index_20 = buildQueue[i + 1] -- 1604
					local file = ____buildQueue_index_20.file -- 1604
					local kind = ____buildQueue_index_20.kind -- 1604
					if kind == "ts" then -- 1604
						local content = tsFileData[file] -- 1606
						if content == nil or isDtsFile(file) then -- 1606
							goto __continue319 -- 1608
						end -- 1608
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1610
						goto __continue319 -- 1611
					end -- 1611
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1613
				end -- 1613
				::__continue319:: -- 1613
				i = i + 1 -- 1603
			end -- 1603
		end -- 1603
		if #messages == 0 then -- 1603
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 1616
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 1616
		end -- 1616
		Log( -- 1619
			"Info", -- 1619
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1619
		) -- 1619
		return ____awaiter_resolve( -- 1619
			nil, -- 1619
			finalizeBuildResult(req.workDir, messages) -- 1620
		) -- 1620
	end) -- 1620
end -- 1542
return ____exports -- 1542