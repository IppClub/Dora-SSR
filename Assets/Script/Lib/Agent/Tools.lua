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
local ensureSafeSearchGlobs, extensionLevels -- 1
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
function ensureSafeSearchGlobs(globs) -- 1037
	local result = {} -- 1038
	do -- 1038
		local i = 0 -- 1039
		while i < #globs do -- 1039
			result[#result + 1] = globs[i + 1] -- 1040
			i = i + 1 -- 1039
		end -- 1039
	end -- 1039
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1042
	do -- 1042
		local i = 0 -- 1043
		while i < #requiredExcludes do -- 1043
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1043
				result[#result + 1] = requiredExcludes[i + 1] -- 1045
			end -- 1045
			i = i + 1 -- 1043
		end -- 1043
	end -- 1043
	return result -- 1048
end -- 1048
local TABLE_TASK = "AgentTask" -- 231
local TABLE_CP = "AgentCheckpoint" -- 232
local TABLE_ENTRY = "AgentCheckpointEntry" -- 233
local ENGINE_LOG_SNAPSHOT_DIR = ".agent" -- 234
local ENGINE_LOG_SNAPSHOT_FILE = "engine_logs_snapshot.txt" -- 235
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
local function queryOne(sql, args) -- 434
	local ____args_0 -- 435
	if args then -- 435
		____args_0 = DB:query(sql, args) -- 435
	else -- 435
		____args_0 = DB:query(sql) -- 435
	end -- 435
	local rows = ____args_0 -- 435
	if not rows or #rows == 0 then -- 435
		return nil -- 436
	end -- 436
	return rows[1] -- 437
end -- 434
do -- 434
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 442
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 450
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 461
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 462
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 475
end -- 475
local function isDtsFile(path) -- 478
	return Path:getExt(Path:getName(path)) == "d" -- 479
end -- 478
local function getSupportedBuildKind(path) -- 484
	repeat -- 484
		local ____switch69 = Path:getExt(path) -- 484
		local ____cond69 = ____switch69 == "ts" or ____switch69 == "tsx" -- 484
		if ____cond69 then -- 484
			return "ts" -- 486
		end -- 486
		____cond69 = ____cond69 or ____switch69 == "xml" -- 486
		if ____cond69 then -- 486
			return "xml" -- 487
		end -- 487
		____cond69 = ____cond69 or ____switch69 == "tl" -- 487
		if ____cond69 then -- 487
			return "teal" -- 488
		end -- 488
		____cond69 = ____cond69 or ____switch69 == "lua" -- 488
		if ____cond69 then -- 488
			return "lua" -- 489
		end -- 489
		____cond69 = ____cond69 or ____switch69 == "yue" -- 489
		if ____cond69 then -- 489
			return "yue" -- 490
		end -- 490
		____cond69 = ____cond69 or ____switch69 == "yarn" -- 490
		if ____cond69 then -- 490
			return "yarn" -- 491
		end -- 491
		do -- 491
			return nil -- 492
		end -- 492
	until true -- 492
end -- 484
local function getTaskHeadSeq(taskId) -- 496
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 497
	if not row then -- 497
		return nil -- 498
	end -- 498
	return row[1] or 0 -- 499
end -- 496
local function getTaskStatus(taskId) -- 502
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 503
	if not row then -- 503
		return nil -- 504
	end -- 504
	return toStr(row[1]) -- 505
end -- 502
local function getLastInsertRowId() -- 508
	local row = queryOne("SELECT last_insert_rowid()") -- 509
	return row and (row[1] or 0) or 0 -- 510
end -- 508
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 513
	DB:exec( -- 514
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 514
		{ -- 516
			taskId, -- 516
			seq, -- 516
			status, -- 516
			summary, -- 516
			toolName, -- 516
			now() -- 516
		} -- 516
	) -- 516
	return getLastInsertRowId() -- 518
end -- 513
local function getCheckpointEntries(checkpointId, desc) -- 521
	if desc == nil then -- 521
		desc = false -- 521
	end -- 521
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 522
	if not rows then -- 522
		return {} -- 529
	end -- 529
	local result = {} -- 530
	do -- 530
		local i = 0 -- 531
		while i < #rows do -- 531
			local row = rows[i + 1] -- 532
			result[#result + 1] = { -- 533
				id = row[1], -- 534
				ord = row[2], -- 535
				path = toStr(row[3]), -- 536
				op = toStr(row[4]), -- 537
				beforeExists = toBool(row[5]), -- 538
				beforeContent = toStr(row[6]), -- 539
				afterExists = toBool(row[7]), -- 540
				afterContent = toStr(row[8]) -- 541
			} -- 541
			i = i + 1 -- 531
		end -- 531
	end -- 531
	return result -- 544
end -- 521
local function rejectDuplicatePaths(changes) -- 547
	local seen = __TS__New(Set) -- 548
	for ____, change in ipairs(changes) do -- 549
		local key = change.path -- 550
		if seen:has(key) then -- 550
			return key -- 551
		end -- 551
		seen:add(key) -- 552
	end -- 552
	return nil -- 554
end -- 547
local function getLinkedDeletePaths(workDir, path) -- 557
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 558
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 558
		return {} -- 559
	end -- 559
	local parent = Path:getPath(fullPath) -- 560
	local baseName = string.lower(Path:getName(fullPath)) -- 561
	local ext = Path:getExt(fullPath) -- 562
	local linked = {} -- 563
	for ____, file in ipairs(Content:getFiles(parent)) do -- 564
		do -- 564
			if string.lower(Path:getName(file)) ~= baseName then -- 564
				goto __continue86 -- 565
			end -- 565
			local siblingExt = Path:getExt(file) -- 566
			if siblingExt == "tl" and ext == "vs" then -- 566
				linked[#linked + 1] = toWorkspaceRelativePath( -- 568
					workDir, -- 568
					Path(parent, file) -- 568
				) -- 568
				goto __continue86 -- 569
			end -- 569
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 569
				linked[#linked + 1] = toWorkspaceRelativePath( -- 572
					workDir, -- 572
					Path(parent, file) -- 572
				) -- 572
			end -- 572
		end -- 572
		::__continue86:: -- 572
	end -- 572
	return linked -- 575
end -- 557
local function expandLinkedDeleteChanges(workDir, changes) -- 578
	local expanded = {} -- 579
	local seen = __TS__New(Set) -- 580
	do -- 580
		local i = 0 -- 581
		while i < #changes do -- 581
			do -- 581
				local change = changes[i + 1] -- 582
				if not seen:has(change.path) then -- 582
					seen:add(change.path) -- 584
					expanded[#expanded + 1] = change -- 585
				end -- 585
				if change.op ~= "delete" then -- 585
					goto __continue93 -- 587
				end -- 587
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 588
				do -- 588
					local j = 0 -- 589
					while j < #linkedPaths do -- 589
						do -- 589
							local linkedPath = linkedPaths[j + 1] -- 590
							if seen:has(linkedPath) then -- 590
								goto __continue97 -- 591
							end -- 591
							seen:add(linkedPath) -- 592
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 593
						end -- 593
						::__continue97:: -- 593
						j = j + 1 -- 589
					end -- 589
				end -- 589
			end -- 589
			::__continue93:: -- 589
			i = i + 1 -- 581
		end -- 581
	end -- 581
	return expanded -- 596
end -- 578
local function applySingleFile(path, exists, content) -- 599
	if exists then -- 599
		if not ensureDirForFile(path) then -- 599
			return false -- 601
		end -- 601
		return Content:save(path, content) -- 602
	end -- 602
	if Content:exist(path) then -- 602
		return Content:remove(path) -- 605
	end -- 605
	return true -- 607
end -- 599
local function encodeJSON(obj) -- 610
	local text = safeJsonEncode(obj) -- 611
	return text -- 612
end -- 610
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 615
	if HttpServer.wsConnectionCount == 0 then -- 615
		return true -- 617
	end -- 617
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 619
	if not payload then -- 619
		return false -- 621
	end -- 621
	emit("AppWS", "Send", payload) -- 623
	return true -- 624
end -- 615
local function runSingleNonTsBuild(file) -- 627
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 627
		return ____awaiter_resolve( -- 627
			nil, -- 627
			__TS__New( -- 628
				__TS__Promise, -- 628
				function(____, resolve) -- 628
					local ____require_result_1 = require("Script.Dev.WebServer") -- 629
					local buildAsync = ____require_result_1.buildAsync -- 629
					Director.systemScheduler:schedule(once(function() -- 630
						local result = buildAsync(file) -- 631
						resolve(nil, result) -- 632
					end)) -- 630
				end -- 628
			) -- 628
		) -- 628
	end) -- 628
end -- 627
function ____exports.runSingleTsTranspile(file, content) -- 637
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 637
		local done = false -- 638
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 639
		if HttpServer.wsConnectionCount == 0 then -- 639
			return ____awaiter_resolve(nil, result) -- 639
		end -- 639
		local listener = Node() -- 647
		listener:gslot( -- 648
			"AppWS", -- 648
			function(event) -- 648
				if event.type ~= "Receive" then -- 648
					return -- 649
				end -- 649
				local res = safeJsonDecode(event.msg) -- 650
				if not res or __TS__ArrayIsArray(res) then -- 650
					return -- 651
				end -- 651
				local payload = res -- 652
				if payload.name ~= "TranspileTS" then -- 652
					return -- 653
				end -- 653
				if tostring(payload.file) ~= file then -- 653
					return -- 654
				end -- 654
				if payload.success then -- 654
					local luaFile = Path:replaceExt(file, "lua") -- 656
					if Content:save( -- 656
						luaFile, -- 657
						tostring(payload.luaCode) -- 657
					) then -- 657
						result = {success = true, file = file} -- 658
					else -- 658
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 660
					end -- 660
				else -- 660
					result = { -- 663
						success = false, -- 663
						file = file, -- 663
						message = tostring(payload.message) -- 663
					} -- 663
				end -- 663
				done = true -- 665
			end -- 648
		) -- 648
		local payload = encodeJSON({name = "TranspileTS", file = file, content = content}) -- 667
		if not payload then -- 667
			listener:removeFromParent() -- 673
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 673
		end -- 673
		__TS__Await(__TS__New( -- 676
			__TS__Promise, -- 676
			function(____, resolve) -- 676
				Director.systemScheduler:schedule(once(function() -- 677
					emit("AppWS", "Send", payload) -- 678
					wait(function() return done end) -- 679
					if not done then -- 679
						listener:removeFromParent() -- 681
					end -- 681
					resolve(nil) -- 683
				end)) -- 677
			end -- 676
		)) -- 676
		return ____awaiter_resolve(nil, result) -- 676
	end) -- 676
end -- 637
function ____exports.createTask(prompt) -- 689
	if prompt == nil then -- 689
		prompt = "" -- 689
	end -- 689
	local t = now() -- 690
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 691
	if affected <= 0 then -- 691
		return {success = false, message = "failed to create task"} -- 696
	end -- 696
	return { -- 698
		success = true, -- 698
		taskId = getLastInsertRowId() -- 698
	} -- 698
end -- 689
function ____exports.setTaskStatus(taskId, status) -- 701
	DB:exec( -- 702
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 702
		{ -- 702
			status, -- 702
			now(), -- 702
			taskId -- 702
		} -- 702
	) -- 702
	Log( -- 703
		"Info", -- 703
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 703
	) -- 703
end -- 701
function ____exports.listCheckpoints(taskId) -- 706
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 707
	if not rows then -- 707
		return {} -- 714
	end -- 714
	local items = {} -- 715
	do -- 715
		local i = 0 -- 716
		while i < #rows do -- 716
			local row = rows[i + 1] -- 717
			items[#items + 1] = { -- 718
				id = row[1], -- 719
				taskId = row[2], -- 720
				seq = row[3], -- 721
				status = toStr(row[4]), -- 722
				summary = toStr(row[5]), -- 723
				toolName = toStr(row[6]), -- 724
				createdAt = row[7] -- 725
			} -- 725
			i = i + 1 -- 716
		end -- 716
	end -- 716
	return items -- 728
end -- 706
local function listCheckpointIdsForTask(taskId, desc) -- 731
	if desc == nil then -- 731
		desc = false -- 731
	end -- 731
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 732
	if not rows then -- 732
		return {} -- 739
	end -- 739
	local items = {} -- 740
	do -- 740
		local i = 0 -- 741
		while i < #rows do -- 741
			local row = rows[i + 1] -- 742
			items[#items + 1] = {id = row[1], seq = row[2]} -- 743
			i = i + 1 -- 741
		end -- 741
	end -- 741
	return items -- 748
end -- 731
local function deriveFileOp(beforeExists, afterExists) -- 751
	if not beforeExists and afterExists then -- 751
		return "create" -- 752
	end -- 752
	if beforeExists and not afterExists then -- 752
		return "delete" -- 753
	end -- 753
	return "write" -- 754
end -- 751
function ____exports.summarizeTaskChangeSet(taskId) -- 757
	if not getTaskStatus(taskId) then -- 757
		return {success = false, message = "task not found"} -- 759
	end -- 759
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 761
	local filesByPath = {} -- 762
	local latestCheckpointId = nil -- 768
	local latestCheckpointSeq = nil -- 769
	do -- 769
		local i = 0 -- 770
		while i < #checkpoints do -- 770
			local checkpoint = checkpoints[i + 1] -- 771
			latestCheckpointId = checkpoint.id -- 772
			latestCheckpointSeq = checkpoint.seq -- 773
			local entries = getCheckpointEntries(checkpoint.id, false) -- 774
			do -- 774
				local j = 0 -- 775
				while j < #entries do -- 775
					local entry = entries[j + 1] -- 776
					local item = filesByPath[entry.path] -- 777
					if not item then -- 777
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 779
						filesByPath[entry.path] = item -- 785
					end -- 785
					item.afterExists = entry.afterExists -- 787
					local ____item_checkpointIds_2 = item.checkpointIds -- 787
					____item_checkpointIds_2[#____item_checkpointIds_2 + 1] = checkpoint.id -- 788
					j = j + 1 -- 775
				end -- 775
			end -- 775
			i = i + 1 -- 770
		end -- 770
	end -- 770
	local files = {} -- 791
	for ____, item in pairs(filesByPath) do -- 792
		files[#files + 1] = { -- 793
			path = item.path, -- 794
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 795
			checkpointCount = #item.checkpointIds, -- 796
			checkpointIds = item.checkpointIds -- 797
		} -- 797
	end -- 797
	__TS__ArraySort( -- 800
		files, -- 800
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 800
	) -- 800
	return { -- 801
		success = true, -- 802
		taskId = taskId, -- 803
		checkpointCount = #checkpoints, -- 804
		filesChanged = #files, -- 805
		files = files, -- 806
		latestCheckpointId = latestCheckpointId, -- 807
		latestCheckpointSeq = latestCheckpointSeq -- 808
	} -- 808
end -- 757
function ____exports.getTaskChangeSetDiff(taskId) -- 812
	if not getTaskStatus(taskId) then -- 812
		return {success = false, message = "task not found"} -- 814
	end -- 814
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 816
	if #checkpoints == 0 then -- 816
		return {success = false, message = "change set not found or empty"} -- 818
	end -- 818
	local filesByPath = {} -- 820
	do -- 820
		local i = 0 -- 827
		while i < #checkpoints do -- 827
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 828
			do -- 828
				local j = 0 -- 829
				while j < #entries do -- 829
					local entry = entries[j + 1] -- 830
					local item = filesByPath[entry.path] -- 831
					if not item then -- 831
						item = { -- 833
							path = entry.path, -- 834
							beforeExists = entry.beforeExists, -- 835
							beforeContent = entry.beforeContent, -- 836
							afterExists = entry.afterExists, -- 837
							afterContent = entry.afterContent -- 838
						} -- 838
						filesByPath[entry.path] = item -- 840
					end -- 840
					item.afterExists = entry.afterExists -- 842
					item.afterContent = entry.afterContent -- 843
					j = j + 1 -- 829
				end -- 829
			end -- 829
			i = i + 1 -- 827
		end -- 827
	end -- 827
	local files = {} -- 846
	for ____, item in pairs(filesByPath) do -- 847
		files[#files + 1] = { -- 848
			path = item.path, -- 849
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 850
			beforeExists = item.beforeExists, -- 851
			afterExists = item.afterExists, -- 852
			beforeContent = item.beforeContent, -- 853
			afterContent = item.afterContent -- 854
		} -- 854
	end -- 854
	__TS__ArraySort( -- 857
		files, -- 857
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 857
	) -- 857
	return {success = true, files = files} -- 858
end -- 812
local function readWorkspaceFile(workDir, path, docLanguage) -- 861
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 862
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 862
		local attr = inspectReadableFile(fullPath) -- 864
		if not attr.success then -- 864
			return attr -- 865
		end -- 865
		return { -- 866
			success = true, -- 866
			content = Content:load(fullPath), -- 866
			size = attr.size -- 866
		} -- 866
	end -- 866
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 868
	if docPath then -- 868
		local attr = inspectReadableFile(docPath) -- 870
		if not attr.success then -- 870
			return attr -- 871
		end -- 871
		return { -- 872
			success = true, -- 872
			content = Content:load(docPath), -- 872
			size = attr.size -- 872
		} -- 872
	end -- 872
	if not fullPath then -- 872
		return {success = false, message = "invalid path or workDir"} -- 874
	end -- 874
	return {success = false, message = "file not found"} -- 875
end -- 861
function ____exports.readFileRaw(workDir, path, docLanguage) -- 878
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 879
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 879
		local attr = inspectReadableFile(path) -- 881
		if not attr.success then -- 881
			return attr -- 882
		end -- 882
		return { -- 883
			success = true, -- 883
			content = Content:load(path), -- 883
			size = attr.size -- 883
		} -- 883
	end -- 883
	return result -- 885
end -- 878
local function getEngineLogText() -- 888
	local folder = Path(Content.writablePath, ENGINE_LOG_SNAPSHOT_DIR) -- 889
	if not Content:exist(folder) then -- 889
		Content:mkdir(folder) -- 891
	end -- 891
	local logPath = Path(folder, ENGINE_LOG_SNAPSHOT_FILE) -- 893
	if not App:saveLog(logPath) then -- 893
		return nil -- 895
	end -- 895
	return Content:load(logPath) -- 897
end -- 888
function ____exports.getLogs(req) -- 900
	local text = getEngineLogText() -- 901
	if text == nil then -- 901
		return {success = false, message = "failed to read engine logs"} -- 903
	end -- 903
	local tailLines = math.max( -- 905
		1, -- 905
		math.floor(req and req.tailLines or 200) -- 905
	) -- 905
	local allLines = __TS__StringSplit(text, "\n") -- 906
	local logs = __TS__ArraySlice( -- 907
		allLines, -- 907
		math.max(0, #allLines - tailLines) -- 907
	) -- 907
	return req and req.joinText and ({ -- 908
		success = true, -- 908
		logs = logs, -- 908
		text = table.concat(logs, "\n") -- 908
	}) or ({success = true, logs = logs}) -- 908
end -- 900
function ____exports.listFiles(req) -- 911
	local root = req.path or "" -- 917
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 918
	if not searchRoot then -- 918
		return {success = false, message = "invalid path or workDir"} -- 920
	end -- 920
	do -- 920
		local function ____catch(e) -- 920
			return true, { -- 938
				success = false, -- 938
				message = tostring(e) -- 938
			} -- 938
		end -- 938
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 938
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 923
			local globs = ensureSafeSearchGlobs(userGlobs) -- 924
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 925
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 926
			local totalEntries = #files -- 927
			local maxEntries = math.max( -- 928
				1, -- 928
				math.floor(req.maxEntries or 200) -- 928
			) -- 928
			local truncated = totalEntries > maxEntries -- 929
			return true, { -- 930
				success = true, -- 931
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 932
				totalEntries = totalEntries, -- 933
				truncated = truncated, -- 934
				maxEntries = maxEntries -- 935
			} -- 935
		end) -- 935
		if not ____try then -- 935
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 935
		end -- 935
		if ____hasReturned then -- 935
			return ____returnValue -- 922
		end -- 922
	end -- 922
end -- 911
local function formatReadSlice(content, startLine, endLine) -- 942
	local lines = __TS__StringSplit(content, "\n") -- 947
	local totalLines = #lines -- 948
	if totalLines == 0 then -- 948
		return { -- 950
			success = true, -- 951
			content = "", -- 952
			totalLines = 0, -- 953
			startLine = 1, -- 954
			endLine = 0, -- 955
			truncated = false -- 956
		} -- 956
	end -- 956
	local rawStart = math.floor(startLine) -- 959
	local rawEnd = math.floor(endLine) -- 960
	if rawStart == 0 then -- 960
		return {success = false, message = "startLine cannot be 0"} -- 962
	end -- 962
	if rawEnd == 0 then -- 962
		return {success = false, message = "endLine cannot be 0"} -- 965
	end -- 965
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 967
	if start > totalLines then -- 967
		return { -- 971
			success = false, -- 971
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 971
		} -- 971
	end -- 971
	local ____end = math.min( -- 973
		totalLines, -- 974
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 975
	) -- 975
	if ____end < start then -- 975
		return { -- 980
			success = false, -- 981
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 982
		} -- 982
	end -- 982
	local slice = {} -- 985
	do -- 985
		local i = start -- 986
		while i <= ____end do -- 986
			slice[#slice + 1] = lines[i] -- 987
			i = i + 1 -- 986
		end -- 986
	end -- 986
	local truncated = start > 1 or ____end < totalLines -- 989
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 990
	local body = table.concat(slice, "\n") -- 995
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 996
	return { -- 997
		success = true, -- 998
		content = output, -- 999
		totalLines = totalLines, -- 1000
		startLine = start, -- 1001
		endLine = ____end, -- 1002
		truncated = truncated -- 1003
	} -- 1003
end -- 942
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1007
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1014
	if not fallback.success or fallback.content == nil then -- 1014
		return fallback -- 1015
	end -- 1015
	local resolvedStartLine = startLine or 1 -- 1016
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1017
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1018
end -- 1007
local codeExtensions = { -- 1025
	".lua", -- 1025
	".tl", -- 1025
	".yue", -- 1025
	".ts", -- 1025
	".tsx", -- 1025
	".xml", -- 1025
	".md", -- 1025
	".yarn", -- 1025
	".wa", -- 1025
	".mod" -- 1025
} -- 1025
extensionLevels = { -- 1026
	vs = 2, -- 1027
	bl = 2, -- 1028
	ts = 1, -- 1029
	tsx = 1, -- 1030
	tl = 1, -- 1031
	yue = 1, -- 1032
	xml = 1, -- 1033
	lua = 0 -- 1034
} -- 1034
local function splitSearchPatterns(pattern) -- 1051
	local trimmed = __TS__StringTrim(pattern or "") -- 1052
	if trimmed == "" then -- 1052
		return {} -- 1053
	end -- 1053
	local out = {} -- 1054
	local seen = __TS__New(Set) -- 1055
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1056
		local p = __TS__StringTrim(tostring(p0)) -- 1057
		if p ~= "" and not seen:has(p) then -- 1057
			seen:add(p) -- 1059
			out[#out + 1] = p -- 1060
		end -- 1060
	end -- 1060
	return out -- 1063
end -- 1051
local function mergeSearchFileResultsUnique(resultsList) -- 1066
	local merged = {} -- 1067
	local seen = __TS__New(Set) -- 1068
	do -- 1068
		local i = 0 -- 1069
		while i < #resultsList do -- 1069
			local list = resultsList[i + 1] -- 1070
			do -- 1070
				local j = 0 -- 1071
				while j < #list do -- 1071
					do -- 1071
						local row = list[j + 1] -- 1072
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1073
						if seen:has(key) then -- 1073
							goto __continue201 -- 1074
						end -- 1074
						seen:add(key) -- 1075
						merged[#merged + 1] = list[j + 1] -- 1076
					end -- 1076
					::__continue201:: -- 1076
					j = j + 1 -- 1071
				end -- 1071
			end -- 1071
			i = i + 1 -- 1069
		end -- 1069
	end -- 1069
	return merged -- 1079
end -- 1066
local function buildGroupedSearchResults(results) -- 1082
	local order = {} -- 1087
	local grouped = __TS__New(Map) -- 1088
	do -- 1088
		local i = 0 -- 1093
		while i < #results do -- 1093
			local row = results[i + 1] -- 1094
			local file = row.file -- 1095
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1096
			local bucket = grouped:get(key) -- 1097
			if not bucket then -- 1097
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1099
				grouped:set(key, bucket) -- 1100
				order[#order + 1] = key -- 1101
			end -- 1101
			bucket.totalMatches = bucket.totalMatches + 1 -- 1103
			local ____bucket_matches_7 = bucket.matches -- 1103
			____bucket_matches_7[#____bucket_matches_7 + 1] = results[i + 1] -- 1104
			i = i + 1 -- 1093
		end -- 1093
	end -- 1093
	local out = {} -- 1106
	do -- 1106
		local i = 0 -- 1111
		while i < #order do -- 1111
			local bucket = grouped:get(order[i + 1]) -- 1112
			if bucket then -- 1112
				out[#out + 1] = bucket -- 1113
			end -- 1113
			i = i + 1 -- 1111
		end -- 1111
	end -- 1111
	return out -- 1115
end -- 1082
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1118
	local merged = {} -- 1119
	local seen = __TS__New(Set) -- 1120
	local index = 0 -- 1121
	local advanced = true -- 1122
	while advanced do -- 1122
		advanced = false -- 1124
		do -- 1124
			local i = 0 -- 1125
			while i < #resultsList do -- 1125
				do -- 1125
					local list = resultsList[i + 1] -- 1126
					if index >= #list then -- 1126
						goto __continue213 -- 1127
					end -- 1127
					advanced = true -- 1128
					local row = list[index + 1] -- 1129
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1130
					if seen:has(key) then -- 1130
						goto __continue213 -- 1131
					end -- 1131
					seen:add(key) -- 1132
					merged[#merged + 1] = row -- 1133
				end -- 1133
				::__continue213:: -- 1133
				i = i + 1 -- 1125
			end -- 1125
		end -- 1125
		index = index + 1 -- 1135
	end -- 1135
	return merged -- 1137
end -- 1118
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1140
	if docSource ~= "api" then -- 1140
		return 100 -- 1141
	end -- 1141
	if programmingLanguage ~= "tsx" then -- 1141
		return 100 -- 1142
	end -- 1142
	repeat -- 1142
		local ____switch219 = string.lower(Path:getFilename(file)) -- 1142
		local ____cond219 = ____switch219 == "jsx.d.ts" -- 1142
		if ____cond219 then -- 1142
			return 0 -- 1144
		end -- 1144
		____cond219 = ____cond219 or ____switch219 == "dorax.d.ts" -- 1144
		if ____cond219 then -- 1144
			return 1 -- 1145
		end -- 1145
		____cond219 = ____cond219 or ____switch219 == "dora.d.ts" -- 1145
		if ____cond219 then -- 1145
			return 2 -- 1146
		end -- 1146
		do -- 1146
			return 100 -- 1147
		end -- 1147
	until true -- 1147
end -- 1140
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1151
	local sorted = __TS__ArraySlice(hits) -- 1156
	__TS__ArraySort( -- 1157
		sorted, -- 1157
		function(____, a, b) -- 1157
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1158
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1159
			if pa ~= pb then -- 1159
				return pa - pb -- 1160
			end -- 1160
			local fa = string.lower(a.file) -- 1161
			local fb = string.lower(b.file) -- 1162
			if fa ~= fb then -- 1162
				return fa < fb and -1 or 1 -- 1163
			end -- 1163
			return (a.line or 0) - (b.line or 0) -- 1164
		end -- 1157
	) -- 1157
	return sorted -- 1166
end -- 1151
function ____exports.searchFiles(req) -- 1169
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1169
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1182
		if not resolvedPath then -- 1182
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1182
		end -- 1182
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1186
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1187
		if not searchRoot then -- 1187
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1187
		end -- 1187
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1187
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1187
		end -- 1187
		local patterns = splitSearchPatterns(req.pattern) -- 1194
		if #patterns == 0 then -- 1194
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1194
		end -- 1194
		return ____awaiter_resolve( -- 1194
			nil, -- 1194
			__TS__New( -- 1198
				__TS__Promise, -- 1198
				function(____, resolve) -- 1198
					Director.systemScheduler:schedule(once(function() -- 1199
						do -- 1199
							local function ____catch(e) -- 1199
								resolve( -- 1241
									nil, -- 1241
									{ -- 1241
										success = false, -- 1241
										message = tostring(e) -- 1241
									} -- 1241
								) -- 1241
							end -- 1241
							local ____try, ____hasReturned = pcall(function() -- 1241
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1201
								local allResults = {} -- 1204
								do -- 1204
									local i = 0 -- 1205
									while i < #patterns do -- 1205
										local ____Content_12 = Content -- 1206
										local ____Content_searchFilesAsync_13 = Content.searchFilesAsync -- 1206
										local ____patterns_index_11 = patterns[i + 1] -- 1211
										local ____req_useRegex_8 = req.useRegex -- 1212
										if ____req_useRegex_8 == nil then -- 1212
											____req_useRegex_8 = false -- 1212
										end -- 1212
										local ____req_caseSensitive_9 = req.caseSensitive -- 1213
										if ____req_caseSensitive_9 == nil then -- 1213
											____req_caseSensitive_9 = false -- 1213
										end -- 1213
										local ____req_includeContent_10 = req.includeContent -- 1214
										if ____req_includeContent_10 == nil then -- 1214
											____req_includeContent_10 = true -- 1214
										end -- 1214
										allResults[#allResults + 1] = ____Content_searchFilesAsync_13( -- 1206
											____Content_12, -- 1206
											searchRoot, -- 1207
											codeExtensions, -- 1208
											extensionLevels, -- 1209
											searchGlobs, -- 1210
											____patterns_index_11, -- 1211
											____req_useRegex_8, -- 1212
											____req_caseSensitive_9, -- 1213
											____req_includeContent_10, -- 1214
											req.contentWindow or 120 -- 1215
										) -- 1215
										i = i + 1 -- 1205
									end -- 1205
								end -- 1205
								local results = mergeSearchFileResultsUnique(allResults) -- 1218
								local totalResults = #results -- 1219
								local limit = math.max( -- 1220
									1, -- 1220
									math.floor(req.limit or 20) -- 1220
								) -- 1220
								local offset = math.max( -- 1221
									0, -- 1221
									math.floor(req.offset or 0) -- 1221
								) -- 1221
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1222
								local nextOffset = offset + #paged -- 1223
								local hasMore = nextOffset < totalResults -- 1224
								local truncated = offset > 0 or hasMore -- 1225
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1226
								local groupByFile = req.groupByFile == true -- 1227
								resolve( -- 1228
									nil, -- 1228
									{ -- 1228
										success = true, -- 1229
										results = relativeResults, -- 1230
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1231
										totalResults = totalResults, -- 1232
										truncated = truncated, -- 1233
										limit = limit, -- 1234
										offset = offset, -- 1235
										nextOffset = nextOffset, -- 1236
										hasMore = hasMore, -- 1237
										groupByFile = groupByFile -- 1238
									} -- 1238
								) -- 1238
							end) -- 1238
							if not ____try then -- 1238
								____catch(____hasReturned) -- 1238
							end -- 1238
						end -- 1238
					end)) -- 1199
				end -- 1198
			) -- 1198
		) -- 1198
	end) -- 1198
end -- 1169
function ____exports.searchDoraAPI(req) -- 1247
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1247
		local pattern = __TS__StringTrim(req.pattern or "") -- 1258
		if pattern == "" then -- 1258
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1258
		end -- 1258
		local patterns = splitSearchPatterns(pattern) -- 1260
		if #patterns == 0 then -- 1260
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1260
		end -- 1260
		local docSource = req.docSource or "api" -- 1262
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1263
		local docRoot = target.root -- 1264
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1265
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1265
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1265
		end -- 1265
		local exts = target.exts -- 1269
		local dotExts = __TS__ArrayMap( -- 1270
			exts, -- 1270
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1270
		) -- 1270
		local globs = target.globs -- 1271
		local limit = math.max( -- 1272
			1, -- 1272
			math.floor(req.limit or 10) -- 1272
		) -- 1272
		return ____awaiter_resolve( -- 1272
			nil, -- 1272
			__TS__New( -- 1274
				__TS__Promise, -- 1274
				function(____, resolve) -- 1274
					Director.systemScheduler:schedule(once(function() -- 1275
						do -- 1275
							local function ____catch(e) -- 1275
								resolve( -- 1316
									nil, -- 1316
									{ -- 1316
										success = false, -- 1316
										message = tostring(e) -- 1316
									} -- 1316
								) -- 1316
							end -- 1316
							local ____try, ____hasReturned = pcall(function() -- 1316
								local allHits = {} -- 1277
								do -- 1277
									local p = 0 -- 1278
									while p < #patterns do -- 1278
										local ____Content_18 = Content -- 1279
										local ____Content_searchFilesAsync_19 = Content.searchFilesAsync -- 1279
										local ____array_17 = __TS__SparseArrayNew( -- 1279
											docRoot, -- 1280
											dotExts, -- 1281
											{}, -- 1282
											ensureSafeSearchGlobs(globs), -- 1283
											patterns[p + 1] -- 1284
										) -- 1284
										local ____req_useRegex_14 = req.useRegex -- 1285
										if ____req_useRegex_14 == nil then -- 1285
											____req_useRegex_14 = false -- 1285
										end -- 1285
										__TS__SparseArrayPush(____array_17, ____req_useRegex_14) -- 1285
										local ____req_caseSensitive_15 = req.caseSensitive -- 1286
										if ____req_caseSensitive_15 == nil then -- 1286
											____req_caseSensitive_15 = false -- 1286
										end -- 1286
										__TS__SparseArrayPush(____array_17, ____req_caseSensitive_15) -- 1286
										local ____req_includeContent_16 = req.includeContent -- 1287
										if ____req_includeContent_16 == nil then -- 1287
											____req_includeContent_16 = true -- 1287
										end -- 1287
										__TS__SparseArrayPush(____array_17, ____req_includeContent_16, req.contentWindow or 80) -- 1287
										local raw = ____Content_searchFilesAsync_19( -- 1279
											____Content_18, -- 1279
											__TS__SparseArraySpread(____array_17) -- 1279
										) -- 1279
										local hits = {} -- 1290
										do -- 1290
											local i = 0 -- 1291
											while i < #raw do -- 1291
												do -- 1291
													local row = raw[i + 1] -- 1292
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1293
													if file == "" then -- 1293
														goto __continue246 -- 1294
													end -- 1294
													hits[#hits + 1] = { -- 1295
														file = file, -- 1296
														line = type(row.line) == "number" and row.line or nil, -- 1297
														content = type(row.content) == "string" and row.content or nil -- 1298
													} -- 1298
												end -- 1298
												::__continue246:: -- 1298
												i = i + 1 -- 1291
											end -- 1291
										end -- 1291
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1301
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1301
											0, -- 1301
											limit -- 1301
										) -- 1301
										p = p + 1 -- 1278
									end -- 1278
								end -- 1278
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1303
								resolve(nil, { -- 1304
									success = true, -- 1305
									docSource = docSource, -- 1306
									docLanguage = req.docLanguage, -- 1307
									programmingLanguage = req.programmingLanguage, -- 1308
									exts = exts, -- 1309
									results = hits, -- 1310
									totalResults = #hits, -- 1311
									truncated = false, -- 1312
									limit = limit -- 1313
								}) -- 1313
							end) -- 1313
							if not ____try then -- 1313
								____catch(____hasReturned) -- 1313
							end -- 1313
						end -- 1313
					end)) -- 1275
				end -- 1274
			) -- 1274
		) -- 1274
	end) -- 1274
end -- 1247
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1322
	if options == nil then -- 1322
		options = {} -- 1322
	end -- 1322
	if #changes == 0 then -- 1322
		return {success = false, message = "empty changes"} -- 1324
	end -- 1324
	if not isValidWorkDir(workDir) then -- 1324
		return {success = false, message = "invalid workDir"} -- 1327
	end -- 1327
	if not getTaskStatus(taskId) then -- 1327
		return {success = false, message = "task not found"} -- 1330
	end -- 1330
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1332
	local dup = rejectDuplicatePaths(expandedChanges) -- 1333
	if dup then -- 1333
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1335
	end -- 1335
	for ____, change in ipairs(expandedChanges) do -- 1338
		if not isValidWorkspacePath(change.path) then -- 1338
			return {success = false, message = "invalid path: " .. change.path} -- 1340
		end -- 1340
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1340
			return {success = false, message = "missing content for " .. change.path} -- 1343
		end -- 1343
	end -- 1343
	local headSeq = getTaskHeadSeq(taskId) -- 1347
	if headSeq == nil then -- 1347
		return {success = false, message = "task not found"} -- 1348
	end -- 1348
	local nextSeq = headSeq + 1 -- 1349
	local checkpointId = insertCheckpoint( -- 1350
		taskId, -- 1350
		nextSeq, -- 1350
		options.summary or "", -- 1350
		options.toolName or "", -- 1350
		"PREPARED" -- 1350
	) -- 1350
	if checkpointId <= 0 then -- 1350
		return {success = false, message = "failed to create checkpoint"} -- 1352
	end -- 1352
	do -- 1352
		local i = 0 -- 1355
		while i < #expandedChanges do -- 1355
			local change = expandedChanges[i + 1] -- 1356
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1357
			if not fullPath then -- 1357
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1359
				return {success = false, message = "invalid path: " .. change.path} -- 1360
			end -- 1360
			local before = getFileState(fullPath) -- 1362
			local afterExists = change.op ~= "delete" -- 1363
			local afterContent = afterExists and (change.content or "") or "" -- 1364
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1365
				checkpointId, -- 1369
				i + 1, -- 1370
				change.path, -- 1371
				change.op, -- 1372
				before.exists and 1 or 0, -- 1373
				before.content, -- 1374
				afterExists and 1 or 0, -- 1375
				afterContent, -- 1376
				before.bytes, -- 1377
				#afterContent -- 1378
			}) -- 1378
			if inserted <= 0 then -- 1378
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1382
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1383
			end -- 1383
			i = i + 1 -- 1355
		end -- 1355
	end -- 1355
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1387
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1388
		if not fullPath then -- 1388
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1390
			return {success = false, message = "invalid path: " .. entry.path} -- 1391
		end -- 1391
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1393
		if not ok then -- 1393
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1395
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1396
		end -- 1396
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1396
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1399
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1400
		end -- 1400
	end -- 1400
	DB:exec( -- 1404
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1404
		{ -- 1406
			"APPLIED", -- 1406
			now(), -- 1406
			checkpointId -- 1406
		} -- 1406
	) -- 1406
	DB:exec( -- 1408
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1408
		{ -- 1410
			nextSeq, -- 1410
			now(), -- 1410
			taskId -- 1410
		} -- 1410
	) -- 1410
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1412
end -- 1322
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1420
	if not isValidWorkDir(workDir) then -- 1420
		return {success = false, message = "invalid workDir"} -- 1421
	end -- 1421
	if checkpointId <= 0 then -- 1421
		return {success = false, message = "invalid checkpointId"} -- 1422
	end -- 1422
	local entries = getCheckpointEntries(checkpointId, true) -- 1423
	if #entries == 0 then -- 1423
		return {success = false, message = "checkpoint not found or empty"} -- 1425
	end -- 1425
	for ____, entry in ipairs(entries) do -- 1427
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1428
		if not fullPath then -- 1428
			return {success = false, message = "invalid path: " .. entry.path} -- 1430
		end -- 1430
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1432
		if not ok then -- 1432
			Log( -- 1434
				"Error", -- 1434
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1434
			) -- 1434
			Log( -- 1435
				"Info", -- 1435
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1435
			) -- 1435
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1436
		end -- 1436
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1436
			Log( -- 1439
				"Error", -- 1439
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1439
			) -- 1439
			Log( -- 1440
				"Info", -- 1440
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1440
			) -- 1440
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1441
		end -- 1441
	end -- 1441
	DB:exec( -- 1444
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 1444
		{ -- 1444
			"REVERTED", -- 1444
			now(), -- 1444
			checkpointId -- 1444
		} -- 1444
	) -- 1444
	return {success = true, checkpointId = checkpointId} -- 1445
end -- 1420
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 1448
	if not isValidWorkDir(workDir) then -- 1448
		return {success = false, message = "invalid workDir"} -- 1449
	end -- 1449
	if not getTaskStatus(taskId) then -- 1449
		return {success = false, message = "task not found"} -- 1450
	end -- 1450
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 1451
	if #checkpoints == 0 then -- 1451
		return {success = false, message = "change set not found or empty"} -- 1453
	end -- 1453
	local lastCheckpointId = 0 -- 1455
	do -- 1455
		local i = 0 -- 1456
		while i < #checkpoints do -- 1456
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 1457
			if not result.success then -- 1457
				return {success = false, message = result.message} -- 1458
			end -- 1458
			lastCheckpointId = checkpoints[i + 1].id -- 1459
			i = i + 1 -- 1456
		end -- 1456
	end -- 1456
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 1461
end -- 1448
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1469
	return getCheckpointEntries(checkpointId, false) -- 1470
end -- 1469
function ____exports.getCheckpointDiff(checkpointId) -- 1473
	if checkpointId <= 0 then -- 1473
		return {success = false, message = "invalid checkpointId"} -- 1475
	end -- 1475
	local entries = getCheckpointEntries(checkpointId, false) -- 1477
	if #entries == 0 then -- 1477
		return {success = false, message = "checkpoint not found or empty"} -- 1479
	end -- 1479
	return { -- 1481
		success = true, -- 1482
		files = __TS__ArrayMap( -- 1483
			entries, -- 1483
			function(____, entry) return { -- 1483
				path = entry.path, -- 1484
				op = entry.op, -- 1485
				beforeExists = entry.beforeExists, -- 1486
				afterExists = entry.afterExists, -- 1487
				beforeContent = entry.beforeContent, -- 1488
				afterContent = entry.afterContent -- 1489
			} end -- 1489
		) -- 1489
	} -- 1489
end -- 1473
local function finalizeBuildResult(workDir, messages) -- 1494
	local normalized = __TS__ArrayMap( -- 1495
		messages, -- 1495
		function(____, m) return m.success and __TS__ObjectAssign( -- 1495
			{}, -- 1496
			m, -- 1496
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1496
		) or __TS__ObjectAssign( -- 1496
			{}, -- 1497
			m, -- 1497
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1497
		) end -- 1497
	) -- 1497
	local total = #normalized -- 1498
	local failed = 0 -- 1499
	do -- 1499
		local i = 0 -- 1500
		while i < #normalized do -- 1500
			if not normalized[i + 1].success then -- 1500
				failed = failed + 1 -- 1501
			end -- 1501
			i = i + 1 -- 1500
		end -- 1500
	end -- 1500
	local passed = total - failed -- 1503
	if failed > 0 then -- 1503
		return { -- 1505
			success = false, -- 1506
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 1507
			total = total, -- 1508
			passed = passed, -- 1509
			failed = failed, -- 1510
			messages = normalized -- 1511
		} -- 1511
	end -- 1511
	return { -- 1514
		success = true, -- 1515
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 1516
		total = total, -- 1517
		passed = passed, -- 1518
		failed = 0, -- 1519
		messages = normalized -- 1520
	} -- 1520
end -- 1494
function ____exports.build(req) -- 1524
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1524
		local targetRel = req.path or "" -- 1525
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1526
		if not target then -- 1526
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1526
		end -- 1526
		if not Content:exist(target) then -- 1526
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1526
		end -- 1526
		local messages = {} -- 1533
		if not Content:isdir(target) then -- 1533
			local kind = getSupportedBuildKind(target) -- 1535
			if not kind then -- 1535
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1535
			end -- 1535
			if kind == "ts" then -- 1535
				local content = Content:load(target) -- 1540
				if content == nil then -- 1540
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1540
				end -- 1540
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1540
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1540
				end -- 1540
				if not isDtsFile(target) then -- 1540
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1548
				end -- 1548
			else -- 1548
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1551
			end -- 1551
			Log( -- 1553
				"Info", -- 1553
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1553
			) -- 1553
			return ____awaiter_resolve( -- 1553
				nil, -- 1553
				finalizeBuildResult(req.workDir, messages) -- 1554
			) -- 1554
		end -- 1554
		local listResult = ____exports.listFiles({ -- 1556
			workDir = req.workDir, -- 1557
			path = targetRel, -- 1558
			globs = __TS__ArrayMap( -- 1559
				codeExtensions, -- 1559
				function(____, e) return "**/*" .. e end -- 1559
			), -- 1559
			maxEntries = 10000 -- 1560
		}) -- 1560
		local relFiles = listResult.success and listResult.files or ({}) -- 1563
		local tsFileData = {} -- 1564
		local buildQueue = {} -- 1565
		for ____, rel in ipairs(relFiles) do -- 1566
			do -- 1566
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1567
				local kind = getSupportedBuildKind(file) -- 1568
				if not kind then -- 1568
					goto __continue307 -- 1569
				end -- 1569
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1570
				if kind ~= "ts" then -- 1570
					goto __continue307 -- 1572
				end -- 1572
				local content = Content:load(file) -- 1574
				if content == nil then -- 1574
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1576
					goto __continue307 -- 1577
				end -- 1577
				tsFileData[file] = content -- 1579
				if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1579
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1581
					goto __continue307 -- 1582
				end -- 1582
			end -- 1582
			::__continue307:: -- 1582
		end -- 1582
		do -- 1582
			local i = 0 -- 1585
			while i < #buildQueue do -- 1585
				do -- 1585
					local ____buildQueue_index_20 = buildQueue[i + 1] -- 1586
					local file = ____buildQueue_index_20.file -- 1586
					local kind = ____buildQueue_index_20.kind -- 1586
					if kind == "ts" then -- 1586
						local content = tsFileData[file] -- 1588
						if content == nil or isDtsFile(file) then -- 1588
							goto __continue314 -- 1590
						end -- 1590
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1592
						goto __continue314 -- 1593
					end -- 1593
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1595
				end -- 1595
				::__continue314:: -- 1595
				i = i + 1 -- 1585
			end -- 1585
		end -- 1585
		if #messages == 0 then -- 1585
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 1598
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 1598
		end -- 1598
		Log( -- 1601
			"Info", -- 1601
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1601
		) -- 1601
		return ____awaiter_resolve( -- 1601
			nil, -- 1601
			finalizeBuildResult(req.workDir, messages) -- 1602
		) -- 1602
	end) -- 1602
end -- 1524
return ____exports -- 1524