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
local App = ____Dora.App -- 2
local HttpServer = ____Dora.HttpServer -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
local safeJsonDecode = ____Utils.safeJsonDecode -- 3
local safeJsonEncode = ____Utils.safeJsonEncode -- 3
function getEngineLogText() -- 914
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 915
	if not Content:exist(folder) then -- 915
		Content:mkdir(folder) -- 917
	end -- 917
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 919
	if not App:saveLog(logPath) then -- 919
		return nil -- 921
	end -- 921
	return Content:load(logPath) -- 923
end -- 923
function ensureSafeSearchGlobs(globs) -- 1063
	local result = {} -- 1064
	do -- 1064
		local i = 0 -- 1065
		while i < #globs do -- 1065
			result[#result + 1] = globs[i + 1] -- 1066
			i = i + 1 -- 1065
		end -- 1065
	end -- 1065
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1068
	do -- 1068
		local i = 0 -- 1069
		while i < #requiredExcludes do -- 1069
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1069
				result[#result + 1] = requiredExcludes[i + 1] -- 1071
			end -- 1071
			i = i + 1 -- 1069
		end -- 1069
	end -- 1069
	return result -- 1074
end -- 1074
local TABLE_TASK = "AgentTask" -- 232
local TABLE_CP = "AgentCheckpoint" -- 233
local TABLE_ENTRY = "AgentCheckpointEntry" -- 234
ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 235
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 236
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
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 378
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
local function isTiledEditorContent(content) -- 495
	return __TS__StringStartsWith( -- 496
		__TS__StringTrim(content), -- 496
		"<?xml" -- 496
	) -- 496
end -- 495
local function getSupportedBuildKind(path) -- 501
	repeat -- 501
		local ____switch74 = Path:getExt(path) -- 501
		local ____cond74 = ____switch74 == "ts" or ____switch74 == "tsx" -- 501
		if ____cond74 then -- 501
			return "ts" -- 503
		end -- 503
		____cond74 = ____cond74 or ____switch74 == "xml" -- 503
		if ____cond74 then -- 503
			return "xml" -- 504
		end -- 504
		____cond74 = ____cond74 or ____switch74 == "tl" -- 504
		if ____cond74 then -- 504
			return "teal" -- 505
		end -- 505
		____cond74 = ____cond74 or ____switch74 == "lua" -- 505
		if ____cond74 then -- 505
			return "lua" -- 506
		end -- 506
		____cond74 = ____cond74 or ____switch74 == "yue" -- 506
		if ____cond74 then -- 506
			return "yue" -- 507
		end -- 507
		____cond74 = ____cond74 or ____switch74 == "yarn" -- 507
		if ____cond74 then -- 507
			return "yarn" -- 508
		end -- 508
		do -- 508
			return nil -- 509
		end -- 509
	until true -- 509
end -- 501
local function getTaskHeadSeq(taskId) -- 513
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 514
	if not row then -- 514
		return nil -- 515
	end -- 515
	return row[1] or 0 -- 516
end -- 513
local function getTaskStatus(taskId) -- 519
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 520
	if not row then -- 520
		return nil -- 521
	end -- 521
	return toStr(row[1]) -- 522
end -- 519
local function getLastInsertRowId() -- 525
	local row = queryOne("SELECT last_insert_rowid()") -- 526
	return row and (row[1] or 0) or 0 -- 527
end -- 525
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 530
	DB:exec( -- 531
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 531
		{ -- 533
			taskId, -- 533
			seq, -- 533
			status, -- 533
			summary, -- 533
			toolName, -- 533
			now() -- 533
		} -- 533
	) -- 533
	return getLastInsertRowId() -- 535
end -- 530
local function getCheckpointEntries(checkpointId, desc) -- 538
	if desc == nil then -- 538
		desc = false -- 538
	end -- 538
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 539
	if not rows then -- 539
		return {} -- 546
	end -- 546
	local result = {} -- 547
	do -- 547
		local i = 0 -- 548
		while i < #rows do -- 548
			local row = rows[i + 1] -- 549
			result[#result + 1] = { -- 550
				id = row[1], -- 551
				ord = row[2], -- 552
				path = toStr(row[3]), -- 553
				op = toStr(row[4]), -- 554
				beforeExists = toBool(row[5]), -- 555
				beforeContent = toStr(row[6]), -- 556
				afterExists = toBool(row[7]), -- 557
				afterContent = toStr(row[8]) -- 558
			} -- 558
			i = i + 1 -- 548
		end -- 548
	end -- 548
	return result -- 561
end -- 538
local function rejectDuplicatePaths(changes) -- 564
	local seen = __TS__New(Set) -- 565
	for ____, change in ipairs(changes) do -- 566
		local key = change.path -- 567
		if seen:has(key) then -- 567
			return key -- 568
		end -- 568
		seen:add(key) -- 569
	end -- 569
	return nil -- 571
end -- 564
local function getLinkedDeletePaths(workDir, path) -- 574
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 575
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 575
		return {} -- 576
	end -- 576
	local parent = Path:getPath(fullPath) -- 577
	local baseName = string.lower(Path:getName(fullPath)) -- 578
	local ext = Path:getExt(fullPath) -- 579
	local linked = {} -- 580
	for ____, file in ipairs(Content:getFiles(parent)) do -- 581
		do -- 581
			if string.lower(Path:getName(file)) ~= baseName then -- 581
				goto __continue91 -- 582
			end -- 582
			local siblingExt = Path:getExt(file) -- 583
			if siblingExt == "tl" and ext == "vs" then -- 583
				linked[#linked + 1] = toWorkspaceRelativePath( -- 585
					workDir, -- 585
					Path(parent, file) -- 585
				) -- 585
				goto __continue91 -- 586
			end -- 586
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 586
				linked[#linked + 1] = toWorkspaceRelativePath( -- 589
					workDir, -- 589
					Path(parent, file) -- 589
				) -- 589
			end -- 589
		end -- 589
		::__continue91:: -- 589
	end -- 589
	return linked -- 592
end -- 574
local function expandLinkedDeleteChanges(workDir, changes) -- 595
	local expanded = {} -- 596
	local seen = __TS__New(Set) -- 597
	do -- 597
		local i = 0 -- 598
		while i < #changes do -- 598
			do -- 598
				local change = changes[i + 1] -- 599
				if not seen:has(change.path) then -- 599
					seen:add(change.path) -- 601
					expanded[#expanded + 1] = change -- 602
				end -- 602
				if change.op ~= "delete" then -- 602
					goto __continue98 -- 604
				end -- 604
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 605
				do -- 605
					local j = 0 -- 606
					while j < #linkedPaths do -- 606
						do -- 606
							local linkedPath = linkedPaths[j + 1] -- 607
							if seen:has(linkedPath) then -- 607
								goto __continue102 -- 608
							end -- 608
							seen:add(linkedPath) -- 609
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 610
						end -- 610
						::__continue102:: -- 610
						j = j + 1 -- 606
					end -- 606
				end -- 606
			end -- 606
			::__continue98:: -- 606
			i = i + 1 -- 598
		end -- 598
	end -- 598
	return expanded -- 613
end -- 595
local function applySingleFile(path, exists, content) -- 616
	if exists then -- 616
		if not ensureDirForFile(path) then -- 616
			return false -- 618
		end -- 618
		return Content:save(path, content) -- 619
	end -- 619
	if Content:exist(path) then -- 619
		return Content:remove(path) -- 622
	end -- 622
	return true -- 624
end -- 616
local function encodeJSON(obj) -- 627
	local text = safeJsonEncode(obj) -- 628
	return text -- 629
end -- 627
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 632
	if HttpServer.wsConnectionCount == 0 then -- 632
		return true -- 634
	end -- 634
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 636
	if not payload then -- 636
		return false -- 638
	end -- 638
	emit("AppWS", "Send", payload) -- 640
	return true -- 641
end -- 632
local function runSingleNonTsBuild(file) -- 644
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 644
		return ____awaiter_resolve( -- 644
			nil, -- 644
			__TS__New( -- 645
				__TS__Promise, -- 645
				function(____, resolve) -- 645
					local moduleName = "Script.Dev.WebServer" -- 646
					local ____require_result_1 = require(moduleName) -- 647
					local buildAsync = ____require_result_1.buildAsync -- 647
					Director.systemScheduler:schedule(once(function() -- 648
						local result = buildAsync(file) -- 649
						resolve(nil, result) -- 650
					end)) -- 648
				end -- 645
			) -- 645
		) -- 645
	end) -- 645
end -- 644
local transpileRequestSeq = 0 -- 655
function ____exports.runSingleTsTranspile(file, content) -- 657
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 657
		local done = false -- 658
		transpileRequestSeq = transpileRequestSeq + 1 -- 659
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 660
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 661
		if HttpServer.wsConnectionCount == 0 then -- 661
			return ____awaiter_resolve(nil, result) -- 661
		end -- 661
		local listener = Node() -- 669
		listener:gslot( -- 670
			"AppWS", -- 670
			function(event) -- 670
				if event.type ~= "Receive" then -- 670
					return -- 671
				end -- 671
				local res = safeJsonDecode(event.msg) -- 672
				if not res or __TS__ArrayIsArray(res) then -- 672
					return -- 673
				end -- 673
				local payload = res -- 674
				if payload.name ~= "TranspileTS" then -- 674
					return -- 675
				end -- 675
				if payload.id ~= requestId then -- 675
					return -- 676
				end -- 676
				if tostring(payload.file) ~= file then -- 676
					return -- 677
				end -- 677
				if payload.success then -- 677
					local luaFile = Path:replaceExt(file, "lua") -- 679
					if Content:save( -- 679
						luaFile, -- 680
						tostring(payload.luaCode) -- 680
					) then -- 680
						result = {success = true, file = file} -- 681
					else -- 681
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 683
					end -- 683
				else -- 683
					result = { -- 686
						success = false, -- 686
						file = file, -- 686
						message = tostring(payload.message) -- 686
					} -- 686
				end -- 686
				done = true -- 688
			end -- 670
		) -- 670
		local payload = encodeJSON({name = "TranspileTS", id = requestId, file = file, content = content}) -- 690
		if not payload then -- 690
			listener:removeFromParent() -- 697
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 697
		end -- 697
		__TS__Await(__TS__New( -- 700
			__TS__Promise, -- 700
			function(____, resolve) -- 700
				Director.systemScheduler:schedule(once(function() -- 701
					emit("AppWS", "Send", payload) -- 702
					wait(function() return done end) -- 703
					if not done then -- 703
						listener:removeFromParent() -- 705
					end -- 705
					resolve(nil) -- 707
				end)) -- 701
			end -- 700
		)) -- 700
		return ____awaiter_resolve(nil, result) -- 700
	end) -- 700
end -- 657
function ____exports.createTask(prompt) -- 713
	if prompt == nil then -- 713
		prompt = "" -- 713
	end -- 713
	local t = now() -- 714
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 715
	if affected <= 0 then -- 715
		return {success = false, message = "failed to create task"} -- 720
	end -- 720
	return { -- 722
		success = true, -- 722
		taskId = getLastInsertRowId() -- 722
	} -- 722
end -- 713
function ____exports.setTaskStatus(taskId, status) -- 725
	DB:exec( -- 726
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 726
		{ -- 726
			status, -- 726
			now(), -- 726
			taskId -- 726
		} -- 726
	) -- 726
	Log( -- 727
		"Info", -- 727
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 727
	) -- 727
end -- 725
function ____exports.listCheckpoints(taskId) -- 730
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 731
	if not rows then -- 731
		return {} -- 738
	end -- 738
	local items = {} -- 739
	do -- 739
		local i = 0 -- 740
		while i < #rows do -- 740
			local row = rows[i + 1] -- 741
			items[#items + 1] = { -- 742
				id = row[1], -- 743
				taskId = row[2], -- 744
				seq = row[3], -- 745
				status = toStr(row[4]), -- 746
				summary = toStr(row[5]), -- 747
				toolName = toStr(row[6]), -- 748
				createdAt = row[7] -- 749
			} -- 749
			i = i + 1 -- 740
		end -- 740
	end -- 740
	return items -- 752
end -- 730
local function listCheckpointIdsForTask(taskId, desc) -- 755
	if desc == nil then -- 755
		desc = false -- 755
	end -- 755
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 756
	if not rows then -- 756
		return {} -- 763
	end -- 763
	local items = {} -- 764
	do -- 764
		local i = 0 -- 765
		while i < #rows do -- 765
			local row = rows[i + 1] -- 766
			items[#items + 1] = {id = row[1], seq = row[2]} -- 767
			i = i + 1 -- 765
		end -- 765
	end -- 765
	return items -- 772
end -- 755
local function deriveFileOp(beforeExists, afterExists) -- 775
	if not beforeExists and afterExists then -- 775
		return "create" -- 776
	end -- 776
	if beforeExists and not afterExists then -- 776
		return "delete" -- 777
	end -- 777
	return "write" -- 778
end -- 775
function ____exports.summarizeTaskChangeSet(taskId) -- 781
	if not getTaskStatus(taskId) then -- 781
		return {success = false, message = "task not found"} -- 783
	end -- 783
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 785
	local filesByPath = {} -- 786
	local latestCheckpointId = nil -- 792
	local latestCheckpointSeq = nil -- 793
	do -- 793
		local i = 0 -- 794
		while i < #checkpoints do -- 794
			local checkpoint = checkpoints[i + 1] -- 795
			latestCheckpointId = checkpoint.id -- 796
			latestCheckpointSeq = checkpoint.seq -- 797
			local entries = getCheckpointEntries(checkpoint.id, false) -- 798
			do -- 798
				local j = 0 -- 799
				while j < #entries do -- 799
					local entry = entries[j + 1] -- 800
					local item = filesByPath[entry.path] -- 801
					if not item then -- 801
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 803
						filesByPath[entry.path] = item -- 809
					end -- 809
					item.afterExists = entry.afterExists -- 811
					local ____item_checkpointIds_2 = item.checkpointIds -- 811
					____item_checkpointIds_2[#____item_checkpointIds_2 + 1] = checkpoint.id -- 812
					j = j + 1 -- 799
				end -- 799
			end -- 799
			i = i + 1 -- 794
		end -- 794
	end -- 794
	local files = {} -- 815
	for ____, item in pairs(filesByPath) do -- 816
		files[#files + 1] = { -- 817
			path = item.path, -- 818
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 819
			checkpointCount = #item.checkpointIds, -- 820
			checkpointIds = item.checkpointIds -- 821
		} -- 821
	end -- 821
	__TS__ArraySort( -- 824
		files, -- 824
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 824
	) -- 824
	return { -- 825
		success = true, -- 826
		taskId = taskId, -- 827
		checkpointCount = #checkpoints, -- 828
		filesChanged = #files, -- 829
		files = files, -- 830
		latestCheckpointId = latestCheckpointId, -- 831
		latestCheckpointSeq = latestCheckpointSeq -- 832
	} -- 832
end -- 781
function ____exports.getTaskChangeSetDiff(taskId) -- 836
	if not getTaskStatus(taskId) then -- 836
		return {success = false, message = "task not found"} -- 838
	end -- 838
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 840
	if #checkpoints == 0 then -- 840
		return {success = false, message = "change set not found or empty"} -- 842
	end -- 842
	local filesByPath = {} -- 844
	do -- 844
		local i = 0 -- 851
		while i < #checkpoints do -- 851
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 852
			do -- 852
				local j = 0 -- 853
				while j < #entries do -- 853
					local entry = entries[j + 1] -- 854
					local item = filesByPath[entry.path] -- 855
					if not item then -- 855
						item = { -- 857
							path = entry.path, -- 858
							beforeExists = entry.beforeExists, -- 859
							beforeContent = entry.beforeContent, -- 860
							afterExists = entry.afterExists, -- 861
							afterContent = entry.afterContent -- 862
						} -- 862
						filesByPath[entry.path] = item -- 864
					end -- 864
					item.afterExists = entry.afterExists -- 866
					item.afterContent = entry.afterContent -- 867
					j = j + 1 -- 853
				end -- 853
			end -- 853
			i = i + 1 -- 851
		end -- 851
	end -- 851
	local files = {} -- 870
	for ____, item in pairs(filesByPath) do -- 871
		files[#files + 1] = { -- 872
			path = item.path, -- 873
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 874
			beforeExists = item.beforeExists, -- 875
			afterExists = item.afterExists, -- 876
			beforeContent = item.beforeContent, -- 877
			afterContent = item.afterContent -- 878
		} -- 878
	end -- 878
	__TS__ArraySort( -- 881
		files, -- 881
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 881
	) -- 881
	return {success = true, files = files} -- 882
end -- 836
local function readWorkspaceFile(workDir, path, docLanguage) -- 885
	local engineLog = readEngineLogFile(path) -- 886
	if engineLog then -- 886
		return engineLog -- 887
	end -- 887
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 888
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 888
		local attr = inspectReadableFile(fullPath) -- 890
		if not attr.success then -- 890
			return attr -- 891
		end -- 891
		return { -- 892
			success = true, -- 892
			content = Content:load(fullPath), -- 892
			size = attr.size -- 892
		} -- 892
	end -- 892
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 894
	if docPath then -- 894
		local attr = inspectReadableFile(docPath) -- 896
		if not attr.success then -- 896
			return attr -- 897
		end -- 897
		return { -- 898
			success = true, -- 898
			content = Content:load(docPath), -- 898
			size = attr.size -- 898
		} -- 898
	end -- 898
	if not fullPath then -- 898
		return {success = false, message = "invalid path or workDir"} -- 900
	end -- 900
	return {success = false, message = "file not found"} -- 901
end -- 885
function ____exports.readFileRaw(workDir, path, docLanguage) -- 904
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 905
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 905
		local attr = inspectReadableFile(path) -- 907
		if not attr.success then -- 907
			return attr -- 908
		end -- 908
		return { -- 909
			success = true, -- 909
			content = Content:load(path), -- 909
			size = attr.size -- 909
		} -- 909
	end -- 909
	return result -- 911
end -- 904
function ____exports.getLogs(req) -- 926
	local text = getEngineLogText() -- 927
	if text == nil then -- 927
		return {success = false, message = "failed to read engine logs"} -- 929
	end -- 929
	local tailLines = math.max( -- 931
		1, -- 931
		math.floor(req and req.tailLines or 200) -- 931
	) -- 931
	local allLines = __TS__StringSplit(text, "\n") -- 932
	local logs = __TS__ArraySlice( -- 933
		allLines, -- 933
		math.max(0, #allLines - tailLines) -- 933
	) -- 933
	return req and req.joinText and ({ -- 934
		success = true, -- 934
		logs = logs, -- 934
		text = table.concat(logs, "\n") -- 934
	}) or ({success = true, logs = logs}) -- 934
end -- 926
function ____exports.listFiles(req) -- 937
	local root = req.path or "" -- 943
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 944
	if not searchRoot then -- 944
		return {success = false, message = "invalid path or workDir"} -- 946
	end -- 946
	do -- 946
		local function ____catch(e) -- 946
			return true, { -- 964
				success = false, -- 964
				message = tostring(e) -- 964
			} -- 964
		end -- 964
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 964
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 949
			local globs = ensureSafeSearchGlobs(userGlobs) -- 950
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 951
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 952
			local totalEntries = #files -- 953
			local maxEntries = math.max( -- 954
				1, -- 954
				math.floor(req.maxEntries or 200) -- 954
			) -- 954
			local truncated = totalEntries > maxEntries -- 955
			return true, { -- 956
				success = true, -- 957
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 958
				totalEntries = totalEntries, -- 959
				truncated = truncated, -- 960
				maxEntries = maxEntries -- 961
			} -- 961
		end) -- 961
		if not ____try then -- 961
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 961
		end -- 961
		if ____hasReturned then -- 961
			return ____returnValue -- 948
		end -- 948
	end -- 948
end -- 937
local function formatReadSlice(content, startLine, endLine) -- 968
	local lines = __TS__StringSplit(content, "\n") -- 973
	local totalLines = #lines -- 974
	if totalLines == 0 then -- 974
		return { -- 976
			success = true, -- 977
			content = "", -- 978
			totalLines = 0, -- 979
			startLine = 1, -- 980
			endLine = 0, -- 981
			truncated = false -- 982
		} -- 982
	end -- 982
	local rawStart = math.floor(startLine) -- 985
	local rawEnd = math.floor(endLine) -- 986
	if rawStart == 0 then -- 986
		return {success = false, message = "startLine cannot be 0"} -- 988
	end -- 988
	if rawEnd == 0 then -- 988
		return {success = false, message = "endLine cannot be 0"} -- 991
	end -- 991
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 993
	if start > totalLines then -- 993
		return { -- 997
			success = false, -- 997
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 997
		} -- 997
	end -- 997
	local ____end = math.min( -- 999
		totalLines, -- 1000
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1001
	) -- 1001
	if ____end < start then -- 1001
		return { -- 1006
			success = false, -- 1007
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1008
		} -- 1008
	end -- 1008
	local slice = {} -- 1011
	do -- 1011
		local i = start -- 1012
		while i <= ____end do -- 1012
			slice[#slice + 1] = lines[i] -- 1013
			i = i + 1 -- 1012
		end -- 1012
	end -- 1012
	local truncated = start > 1 or ____end < totalLines -- 1015
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1016
	local body = table.concat(slice, "\n") -- 1021
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1022
	return { -- 1023
		success = true, -- 1024
		content = output, -- 1025
		totalLines = totalLines, -- 1026
		startLine = start, -- 1027
		endLine = ____end, -- 1028
		truncated = truncated -- 1029
	} -- 1029
end -- 968
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1033
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1040
	if not fallback.success or fallback.content == nil then -- 1040
		return fallback -- 1041
	end -- 1041
	local resolvedStartLine = startLine or 1 -- 1042
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1043
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1044
end -- 1033
local codeExtensions = { -- 1051
	".lua", -- 1051
	".tl", -- 1051
	".yue", -- 1051
	".ts", -- 1051
	".tsx", -- 1051
	".xml", -- 1051
	".md", -- 1051
	".yarn", -- 1051
	".wa", -- 1051
	".mod" -- 1051
} -- 1051
extensionLevels = { -- 1052
	vs = 2, -- 1053
	bl = 2, -- 1054
	ts = 1, -- 1055
	tsx = 1, -- 1056
	tl = 1, -- 1057
	yue = 1, -- 1058
	xml = 1, -- 1059
	lua = 0 -- 1060
} -- 1060
local function splitSearchPatterns(pattern) -- 1077
	local trimmed = __TS__StringTrim(pattern or "") -- 1078
	if trimmed == "" then -- 1078
		return {} -- 1079
	end -- 1079
	local out = {} -- 1080
	local seen = __TS__New(Set) -- 1081
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1082
		local p = __TS__StringTrim(tostring(p0)) -- 1083
		if p ~= "" and not seen:has(p) then -- 1083
			seen:add(p) -- 1085
			out[#out + 1] = p -- 1086
		end -- 1086
	end -- 1086
	return out -- 1089
end -- 1077
local function mergeSearchFileResultsUnique(resultsList) -- 1092
	local merged = {} -- 1093
	local seen = __TS__New(Set) -- 1094
	do -- 1094
		local i = 0 -- 1095
		while i < #resultsList do -- 1095
			local list = resultsList[i + 1] -- 1096
			do -- 1096
				local j = 0 -- 1097
				while j < #list do -- 1097
					do -- 1097
						local row = list[j + 1] -- 1098
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1099
						if seen:has(key) then -- 1099
							goto __continue208 -- 1100
						end -- 1100
						seen:add(key) -- 1101
						merged[#merged + 1] = list[j + 1] -- 1102
					end -- 1102
					::__continue208:: -- 1102
					j = j + 1 -- 1097
				end -- 1097
			end -- 1097
			i = i + 1 -- 1095
		end -- 1095
	end -- 1095
	return merged -- 1105
end -- 1092
local function buildGroupedSearchResults(results) -- 1108
	local order = {} -- 1113
	local grouped = __TS__New(Map) -- 1114
	do -- 1114
		local i = 0 -- 1119
		while i < #results do -- 1119
			local row = results[i + 1] -- 1120
			local file = row.file -- 1121
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1122
			local bucket = grouped:get(key) -- 1123
			if not bucket then -- 1123
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1125
				grouped:set(key, bucket) -- 1126
				order[#order + 1] = key -- 1127
			end -- 1127
			bucket.totalMatches = bucket.totalMatches + 1 -- 1129
			local ____bucket_matches_7 = bucket.matches -- 1129
			____bucket_matches_7[#____bucket_matches_7 + 1] = results[i + 1] -- 1130
			i = i + 1 -- 1119
		end -- 1119
	end -- 1119
	local out = {} -- 1132
	do -- 1132
		local i = 0 -- 1137
		while i < #order do -- 1137
			local bucket = grouped:get(order[i + 1]) -- 1138
			if bucket then -- 1138
				out[#out + 1] = bucket -- 1139
			end -- 1139
			i = i + 1 -- 1137
		end -- 1137
	end -- 1137
	return out -- 1141
end -- 1108
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1144
	local merged = {} -- 1145
	local seen = __TS__New(Set) -- 1146
	local index = 0 -- 1147
	local advanced = true -- 1148
	while advanced do -- 1148
		advanced = false -- 1150
		do -- 1150
			local i = 0 -- 1151
			while i < #resultsList do -- 1151
				do -- 1151
					local list = resultsList[i + 1] -- 1152
					if index >= #list then -- 1152
						goto __continue220 -- 1153
					end -- 1153
					advanced = true -- 1154
					local row = list[index + 1] -- 1155
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1156
					if seen:has(key) then -- 1156
						goto __continue220 -- 1157
					end -- 1157
					seen:add(key) -- 1158
					merged[#merged + 1] = row -- 1159
				end -- 1159
				::__continue220:: -- 1159
				i = i + 1 -- 1151
			end -- 1151
		end -- 1151
		index = index + 1 -- 1161
	end -- 1161
	return merged -- 1163
end -- 1144
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1166
	if docSource ~= "api" then -- 1166
		return 100 -- 1167
	end -- 1167
	if programmingLanguage ~= "tsx" then -- 1167
		return 100 -- 1168
	end -- 1168
	repeat -- 1168
		local ____switch226 = string.lower(Path:getFilename(file)) -- 1168
		local ____cond226 = ____switch226 == "jsx.d.ts" -- 1168
		if ____cond226 then -- 1168
			return 0 -- 1170
		end -- 1170
		____cond226 = ____cond226 or ____switch226 == "dorax.d.ts" -- 1170
		if ____cond226 then -- 1170
			return 1 -- 1171
		end -- 1171
		____cond226 = ____cond226 or ____switch226 == "dora.d.ts" -- 1171
		if ____cond226 then -- 1171
			return 2 -- 1172
		end -- 1172
		do -- 1172
			return 100 -- 1173
		end -- 1173
	until true -- 1173
end -- 1166
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1177
	local sorted = __TS__ArraySlice(hits) -- 1182
	__TS__ArraySort( -- 1183
		sorted, -- 1183
		function(____, a, b) -- 1183
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1184
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1185
			if pa ~= pb then -- 1185
				return pa - pb -- 1186
			end -- 1186
			local fa = string.lower(a.file) -- 1187
			local fb = string.lower(b.file) -- 1188
			if fa ~= fb then -- 1188
				return fa < fb and -1 or 1 -- 1189
			end -- 1189
			return (a.line or 0) - (b.line or 0) -- 1190
		end -- 1183
	) -- 1183
	return sorted -- 1192
end -- 1177
function ____exports.searchFiles(req) -- 1195
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1195
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1208
		if not resolvedPath then -- 1208
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1208
		end -- 1208
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1212
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1213
		if not searchRoot then -- 1213
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1213
		end -- 1213
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1213
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1213
		end -- 1213
		local patterns = splitSearchPatterns(req.pattern) -- 1220
		if #patterns == 0 then -- 1220
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1220
		end -- 1220
		return ____awaiter_resolve( -- 1220
			nil, -- 1220
			__TS__New( -- 1224
				__TS__Promise, -- 1224
				function(____, resolve) -- 1224
					Director.systemScheduler:schedule(once(function() -- 1225
						do -- 1225
							local function ____catch(e) -- 1225
								resolve( -- 1267
									nil, -- 1267
									{ -- 1267
										success = false, -- 1267
										message = tostring(e) -- 1267
									} -- 1267
								) -- 1267
							end -- 1267
							local ____try, ____hasReturned = pcall(function() -- 1267
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1227
								local allResults = {} -- 1230
								do -- 1230
									local i = 0 -- 1231
									while i < #patterns do -- 1231
										local ____Content_12 = Content -- 1232
										local ____Content_searchFilesAsync_13 = Content.searchFilesAsync -- 1232
										local ____patterns_index_11 = patterns[i + 1] -- 1237
										local ____req_useRegex_8 = req.useRegex -- 1238
										if ____req_useRegex_8 == nil then -- 1238
											____req_useRegex_8 = false -- 1238
										end -- 1238
										local ____req_caseSensitive_9 = req.caseSensitive -- 1239
										if ____req_caseSensitive_9 == nil then -- 1239
											____req_caseSensitive_9 = false -- 1239
										end -- 1239
										local ____req_includeContent_10 = req.includeContent -- 1240
										if ____req_includeContent_10 == nil then -- 1240
											____req_includeContent_10 = true -- 1240
										end -- 1240
										allResults[#allResults + 1] = ____Content_searchFilesAsync_13( -- 1232
											____Content_12, -- 1232
											searchRoot, -- 1233
											codeExtensions, -- 1234
											extensionLevels, -- 1235
											searchGlobs, -- 1236
											____patterns_index_11, -- 1237
											____req_useRegex_8, -- 1238
											____req_caseSensitive_9, -- 1239
											____req_includeContent_10, -- 1240
											req.contentWindow or 120 -- 1241
										) -- 1241
										i = i + 1 -- 1231
									end -- 1231
								end -- 1231
								local results = mergeSearchFileResultsUnique(allResults) -- 1244
								local totalResults = #results -- 1245
								local limit = math.max( -- 1246
									1, -- 1246
									math.floor(req.limit or 20) -- 1246
								) -- 1246
								local offset = math.max( -- 1247
									0, -- 1247
									math.floor(req.offset or 0) -- 1247
								) -- 1247
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1248
								local nextOffset = offset + #paged -- 1249
								local hasMore = nextOffset < totalResults -- 1250
								local truncated = offset > 0 or hasMore -- 1251
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1252
								local groupByFile = req.groupByFile == true -- 1253
								resolve( -- 1254
									nil, -- 1254
									{ -- 1254
										success = true, -- 1255
										results = relativeResults, -- 1256
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1257
										totalResults = totalResults, -- 1258
										truncated = truncated, -- 1259
										limit = limit, -- 1260
										offset = offset, -- 1261
										nextOffset = nextOffset, -- 1262
										hasMore = hasMore, -- 1263
										groupByFile = groupByFile -- 1264
									} -- 1264
								) -- 1264
							end) -- 1264
							if not ____try then -- 1264
								____catch(____hasReturned) -- 1264
							end -- 1264
						end -- 1264
					end)) -- 1225
				end -- 1224
			) -- 1224
		) -- 1224
	end) -- 1224
end -- 1195
function ____exports.searchDoraAPI(req) -- 1273
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1273
		local pattern = __TS__StringTrim(req.pattern or "") -- 1284
		if pattern == "" then -- 1284
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1284
		end -- 1284
		local patterns = splitSearchPatterns(pattern) -- 1286
		if #patterns == 0 then -- 1286
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1286
		end -- 1286
		local docSource = req.docSource or "api" -- 1288
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1289
		local docRoot = target.root -- 1290
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1291
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1291
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1291
		end -- 1291
		local exts = target.exts -- 1295
		local dotExts = __TS__ArrayMap( -- 1296
			exts, -- 1296
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1296
		) -- 1296
		local globs = target.globs -- 1297
		local limit = math.max( -- 1298
			1, -- 1298
			math.floor(req.limit or 10) -- 1298
		) -- 1298
		return ____awaiter_resolve( -- 1298
			nil, -- 1298
			__TS__New( -- 1300
				__TS__Promise, -- 1300
				function(____, resolve) -- 1300
					Director.systemScheduler:schedule(once(function() -- 1301
						do -- 1301
							local function ____catch(e) -- 1301
								resolve( -- 1343
									nil, -- 1343
									{ -- 1343
										success = false, -- 1343
										message = tostring(e) -- 1343
									} -- 1343
								) -- 1343
							end -- 1343
							local ____try, ____hasReturned = pcall(function() -- 1343
								local allHits = {} -- 1303
								do -- 1303
									local p = 0 -- 1304
									while p < #patterns do -- 1304
										local ____Content_18 = Content -- 1305
										local ____Content_searchFilesAsync_19 = Content.searchFilesAsync -- 1305
										local ____array_17 = __TS__SparseArrayNew( -- 1305
											docRoot, -- 1306
											dotExts, -- 1307
											{}, -- 1308
											ensureSafeSearchGlobs(globs), -- 1309
											patterns[p + 1] -- 1310
										) -- 1310
										local ____req_useRegex_14 = req.useRegex -- 1311
										if ____req_useRegex_14 == nil then -- 1311
											____req_useRegex_14 = false -- 1311
										end -- 1311
										__TS__SparseArrayPush(____array_17, ____req_useRegex_14) -- 1311
										local ____req_caseSensitive_15 = req.caseSensitive -- 1312
										if ____req_caseSensitive_15 == nil then -- 1312
											____req_caseSensitive_15 = false -- 1312
										end -- 1312
										__TS__SparseArrayPush(____array_17, ____req_caseSensitive_15) -- 1312
										local ____req_includeContent_16 = req.includeContent -- 1313
										if ____req_includeContent_16 == nil then -- 1313
											____req_includeContent_16 = true -- 1313
										end -- 1313
										__TS__SparseArrayPush(____array_17, ____req_includeContent_16, req.contentWindow or 80) -- 1313
										local raw = ____Content_searchFilesAsync_19( -- 1305
											____Content_18, -- 1305
											__TS__SparseArraySpread(____array_17) -- 1305
										) -- 1305
										local hits = {} -- 1316
										do -- 1316
											local i = 0 -- 1317
											while i < #raw do -- 1317
												do -- 1317
													local row = raw[i + 1] -- 1318
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1319
													if file == "" then -- 1319
														goto __continue253 -- 1320
													end -- 1320
													hits[#hits + 1] = { -- 1321
														file = file, -- 1322
														line = type(row.line) == "number" and row.line or nil, -- 1323
														content = type(row.content) == "string" and row.content or nil -- 1324
													} -- 1324
												end -- 1324
												::__continue253:: -- 1324
												i = i + 1 -- 1317
											end -- 1317
										end -- 1317
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1327
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1327
											0, -- 1327
											limit -- 1327
										) -- 1327
										p = p + 1 -- 1304
									end -- 1304
								end -- 1304
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1329
								resolve(nil, { -- 1330
									success = true, -- 1331
									docSource = docSource, -- 1332
									docLanguage = req.docLanguage, -- 1333
									programmingLanguage = req.programmingLanguage, -- 1334
									exts = exts, -- 1335
									results = hits, -- 1336
									hint = "Use read_file directly with the file value from a search result to view the complete document. Do not add any prefixes.", -- 1337
									totalResults = #hits, -- 1338
									truncated = false, -- 1339
									limit = limit -- 1340
								}) -- 1340
							end) -- 1340
							if not ____try then -- 1340
								____catch(____hasReturned) -- 1340
							end -- 1340
						end -- 1340
					end)) -- 1301
				end -- 1300
			) -- 1300
		) -- 1300
	end) -- 1300
end -- 1273
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1349
	if options == nil then -- 1349
		options = {} -- 1349
	end -- 1349
	if #changes == 0 then -- 1349
		return {success = false, message = "empty changes"} -- 1351
	end -- 1351
	if not isValidWorkDir(workDir) then -- 1351
		return {success = false, message = "invalid workDir"} -- 1354
	end -- 1354
	if not getTaskStatus(taskId) then -- 1354
		return {success = false, message = "task not found"} -- 1357
	end -- 1357
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1359
	local dup = rejectDuplicatePaths(expandedChanges) -- 1360
	if dup then -- 1360
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1362
	end -- 1362
	for ____, change in ipairs(expandedChanges) do -- 1365
		if not isValidWorkspacePath(change.path) then -- 1365
			return {success = false, message = "invalid path: " .. change.path} -- 1367
		end -- 1367
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1367
			return {success = false, message = "missing content for " .. change.path} -- 1370
		end -- 1370
	end -- 1370
	local headSeq = getTaskHeadSeq(taskId) -- 1374
	if headSeq == nil then -- 1374
		return {success = false, message = "task not found"} -- 1375
	end -- 1375
	local nextSeq = headSeq + 1 -- 1376
	local checkpointId = insertCheckpoint( -- 1377
		taskId, -- 1377
		nextSeq, -- 1377
		options.summary or "", -- 1377
		options.toolName or "", -- 1377
		"PREPARED" -- 1377
	) -- 1377
	if checkpointId <= 0 then -- 1377
		return {success = false, message = "failed to create checkpoint"} -- 1379
	end -- 1379
	do -- 1379
		local i = 0 -- 1382
		while i < #expandedChanges do -- 1382
			local change = expandedChanges[i + 1] -- 1383
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1384
			if not fullPath then -- 1384
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1386
				return {success = false, message = "invalid path: " .. change.path} -- 1387
			end -- 1387
			local before = getFileState(fullPath) -- 1389
			local afterExists = change.op ~= "delete" -- 1390
			local afterContent = afterExists and (change.content or "") or "" -- 1391
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1392
				checkpointId, -- 1396
				i + 1, -- 1397
				change.path, -- 1398
				change.op, -- 1399
				before.exists and 1 or 0, -- 1400
				before.content, -- 1401
				afterExists and 1 or 0, -- 1402
				afterContent, -- 1403
				before.bytes, -- 1404
				#afterContent -- 1405
			}) -- 1405
			if inserted <= 0 then -- 1405
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1409
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1410
			end -- 1410
			i = i + 1 -- 1382
		end -- 1382
	end -- 1382
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1414
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1415
		if not fullPath then -- 1415
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1417
			return {success = false, message = "invalid path: " .. entry.path} -- 1418
		end -- 1418
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1420
		if not ok then -- 1420
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1422
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1423
		end -- 1423
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1423
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1426
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1427
		end -- 1427
	end -- 1427
	DB:exec( -- 1431
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1431
		{ -- 1433
			"APPLIED", -- 1433
			now(), -- 1433
			checkpointId -- 1433
		} -- 1433
	) -- 1433
	DB:exec( -- 1435
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1435
		{ -- 1437
			nextSeq, -- 1437
			now(), -- 1437
			taskId -- 1437
		} -- 1437
	) -- 1437
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1439
end -- 1349
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1447
	if not isValidWorkDir(workDir) then -- 1447
		return {success = false, message = "invalid workDir"} -- 1448
	end -- 1448
	if checkpointId <= 0 then -- 1448
		return {success = false, message = "invalid checkpointId"} -- 1449
	end -- 1449
	local entries = getCheckpointEntries(checkpointId, true) -- 1450
	if #entries == 0 then -- 1450
		return {success = false, message = "checkpoint not found or empty"} -- 1452
	end -- 1452
	for ____, entry in ipairs(entries) do -- 1454
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1455
		if not fullPath then -- 1455
			return {success = false, message = "invalid path: " .. entry.path} -- 1457
		end -- 1457
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1459
		if not ok then -- 1459
			Log( -- 1461
				"Error", -- 1461
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1461
			) -- 1461
			Log( -- 1462
				"Info", -- 1462
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1462
			) -- 1462
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1463
		end -- 1463
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1463
			Log( -- 1466
				"Error", -- 1466
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1466
			) -- 1466
			Log( -- 1467
				"Info", -- 1467
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1467
			) -- 1467
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1468
		end -- 1468
	end -- 1468
	DB:exec( -- 1471
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 1471
		{ -- 1471
			"REVERTED", -- 1471
			now(), -- 1471
			checkpointId -- 1471
		} -- 1471
	) -- 1471
	return {success = true, checkpointId = checkpointId} -- 1472
end -- 1447
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 1475
	if not isValidWorkDir(workDir) then -- 1475
		return {success = false, message = "invalid workDir"} -- 1476
	end -- 1476
	if not getTaskStatus(taskId) then -- 1476
		return {success = false, message = "task not found"} -- 1477
	end -- 1477
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 1478
	if #checkpoints == 0 then -- 1478
		return {success = false, message = "change set not found or empty"} -- 1480
	end -- 1480
	local lastCheckpointId = 0 -- 1482
	do -- 1482
		local i = 0 -- 1483
		while i < #checkpoints do -- 1483
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 1484
			if not result.success then -- 1484
				return {success = false, message = result.message} -- 1485
			end -- 1485
			lastCheckpointId = checkpoints[i + 1].id -- 1486
			i = i + 1 -- 1483
		end -- 1483
	end -- 1483
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 1488
end -- 1475
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1496
	return getCheckpointEntries(checkpointId, false) -- 1497
end -- 1496
function ____exports.getCheckpointDiff(checkpointId) -- 1500
	if checkpointId <= 0 then -- 1500
		return {success = false, message = "invalid checkpointId"} -- 1502
	end -- 1502
	local entries = getCheckpointEntries(checkpointId, false) -- 1504
	if #entries == 0 then -- 1504
		return {success = false, message = "checkpoint not found or empty"} -- 1506
	end -- 1506
	return { -- 1508
		success = true, -- 1509
		files = __TS__ArrayMap( -- 1510
			entries, -- 1510
			function(____, entry) return { -- 1510
				path = entry.path, -- 1511
				op = entry.op, -- 1512
				beforeExists = entry.beforeExists, -- 1513
				afterExists = entry.afterExists, -- 1514
				beforeContent = entry.beforeContent, -- 1515
				afterContent = entry.afterContent -- 1516
			} end -- 1516
		) -- 1516
	} -- 1516
end -- 1500
local function finalizeBuildResult(workDir, messages) -- 1521
	local normalized = __TS__ArrayMap( -- 1522
		messages, -- 1522
		function(____, m) return m.success and __TS__ObjectAssign( -- 1522
			{}, -- 1523
			m, -- 1523
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1523
		) or __TS__ObjectAssign( -- 1523
			{}, -- 1524
			m, -- 1524
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1524
		) end -- 1524
	) -- 1524
	local total = #normalized -- 1525
	local failed = 0 -- 1526
	do -- 1526
		local i = 0 -- 1527
		while i < #normalized do -- 1527
			if not normalized[i + 1].success then -- 1527
				failed = failed + 1 -- 1528
			end -- 1528
			i = i + 1 -- 1527
		end -- 1527
	end -- 1527
	local passed = total - failed -- 1530
	if failed > 0 then -- 1530
		return { -- 1532
			success = false, -- 1533
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 1534
			total = total, -- 1535
			passed = passed, -- 1536
			failed = failed, -- 1537
			messages = normalized -- 1538
		} -- 1538
	end -- 1538
	return { -- 1541
		success = true, -- 1542
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 1543
		total = total, -- 1544
		passed = passed, -- 1545
		failed = 0, -- 1546
		messages = normalized -- 1547
	} -- 1547
end -- 1521
function ____exports.build(req) -- 1551
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1551
		local targetRel = req.path or "" -- 1552
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1553
		if not target then -- 1553
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1553
		end -- 1553
		if not Content:exist(target) then -- 1553
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1553
		end -- 1553
		local messages = {} -- 1560
		if not Content:isdir(target) then -- 1560
			local kind = getSupportedBuildKind(target) -- 1562
			if not kind then -- 1562
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1562
			end -- 1562
			if kind == "ts" then -- 1562
				local content = Content:load(target) -- 1567
				if content == nil then -- 1567
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1567
				end -- 1567
				if isTiledEditorContent(content) then -- 1567
					Log("Info", "[build] skip tiled editor file=" .. target) -- 1572
					return ____awaiter_resolve( -- 1572
						nil, -- 1572
						finalizeBuildResult(req.workDir, messages) -- 1573
					) -- 1573
				end -- 1573
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1573
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1573
				end -- 1573
				if not isDtsFile(target) then -- 1573
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1579
				end -- 1579
			else -- 1579
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1582
			end -- 1582
			Log( -- 1584
				"Info", -- 1584
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1584
			) -- 1584
			return ____awaiter_resolve( -- 1584
				nil, -- 1584
				finalizeBuildResult(req.workDir, messages) -- 1585
			) -- 1585
		end -- 1585
		local listResult = ____exports.listFiles({ -- 1587
			workDir = req.workDir, -- 1588
			path = targetRel, -- 1589
			globs = __TS__ArrayMap( -- 1590
				codeExtensions, -- 1590
				function(____, e) return "**/*" .. e end -- 1590
			), -- 1590
			maxEntries = 10000 -- 1591
		}) -- 1591
		local relFiles = listResult.success and listResult.files or ({}) -- 1594
		local tsFileData = {} -- 1595
		local buildQueue = {} -- 1596
		for ____, rel in ipairs(relFiles) do -- 1597
			do -- 1597
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1598
				local kind = getSupportedBuildKind(file) -- 1599
				if not kind then -- 1599
					goto __continue315 -- 1600
				end -- 1600
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1601
				if kind ~= "ts" then -- 1601
					goto __continue315 -- 1603
				end -- 1603
				local content = Content:load(file) -- 1605
				if content == nil then -- 1605
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1607
					goto __continue315 -- 1608
				end -- 1608
				if isTiledEditorContent(content) then -- 1608
					Log("Info", "[build] skip tiled editor file=" .. file) -- 1611
					goto __continue315 -- 1612
				end -- 1612
				tsFileData[file] = content -- 1614
			end -- 1614
			::__continue315:: -- 1614
		end -- 1614
		do -- 1614
			local i = 0 -- 1616
			while i < #buildQueue do -- 1616
				do -- 1616
					local ____buildQueue_index_20 = buildQueue[i + 1] -- 1617
					local file = ____buildQueue_index_20.file -- 1617
					local kind = ____buildQueue_index_20.kind -- 1617
					if kind == "ts" then -- 1617
						local content = tsFileData[file] -- 1619
						if content == nil or isDtsFile(file) then -- 1619
							goto __continue322 -- 1621
						end -- 1621
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1621
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1624
							goto __continue322 -- 1625
						end -- 1625
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1627
						goto __continue322 -- 1628
					end -- 1628
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1630
				end -- 1630
				::__continue322:: -- 1630
				i = i + 1 -- 1616
			end -- 1616
		end -- 1616
		if #messages == 0 then -- 1616
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 1633
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 1633
		end -- 1633
		Log( -- 1636
			"Info", -- 1636
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1636
		) -- 1636
		return ____awaiter_resolve( -- 1636
			nil, -- 1636
			finalizeBuildResult(req.workDir, messages) -- 1637
		) -- 1637
	end) -- 1637
end -- 1551
return ____exports -- 1551