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
function ensureSafeSearchGlobs(globs) -- 1001
	local result = {} -- 1002
	do -- 1002
		local i = 0 -- 1003
		while i < #globs do -- 1003
			result[#result + 1] = globs[i + 1] -- 1004
			i = i + 1 -- 1003
		end -- 1003
	end -- 1003
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1006
	do -- 1006
		local i = 0 -- 1007
		while i < #requiredExcludes do -- 1007
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1007
				result[#result + 1] = requiredExcludes[i + 1] -- 1009
			end -- 1009
			i = i + 1 -- 1007
		end -- 1007
	end -- 1007
	return result -- 1012
end -- 1012
local TABLE_TASK = "AgentTask" -- 228
local TABLE_CP = "AgentCheckpoint" -- 229
local TABLE_ENTRY = "AgentCheckpointEntry" -- 230
local ENGINE_LOG_SNAPSHOT_DIR = ".agent" -- 231
local ENGINE_LOG_SNAPSHOT_FILE = "engine_logs_snapshot.txt" -- 232
local function now() -- 234
	return os.time() -- 234
end -- 234
local function toBool(v) -- 236
	return v ~= 0 and v ~= false and v ~= nil -- 237
end -- 236
local function toStr(v) -- 240
	if v == false or v == nil then -- 240
		return "" -- 241
	end -- 241
	return tostring(v) -- 242
end -- 240
local function isValidWorkspacePath(path) -- 245
	if not path or #path == 0 then -- 245
		return false -- 246
	end -- 246
	if Content:isAbsolutePath(path) then -- 246
		return false -- 247
	end -- 247
	if __TS__StringIncludes(path, "..") then -- 247
		return false -- 248
	end -- 248
	return true -- 249
end -- 245
local function isValidWorkDir(workDir) -- 252
	if not workDir or #workDir == 0 then -- 252
		return false -- 253
	end -- 253
	if not Content:isAbsolutePath(workDir) then -- 253
		return false -- 254
	end -- 254
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 254
		return false -- 255
	end -- 255
	return true -- 256
end -- 252
local function isValidSearchPath(path) -- 259
	if path == "" then -- 259
		return true -- 260
	end -- 260
	if Content:isAbsolutePath(path) then -- 260
		return false -- 261
	end -- 261
	if not path or #path == 0 then -- 261
		return false -- 262
	end -- 262
	if __TS__StringIncludes(path, "..") then -- 262
		return false -- 263
	end -- 263
	return true -- 264
end -- 259
local function resolveWorkspaceFilePath(workDir, path) -- 267
	if not isValidWorkDir(workDir) then -- 267
		return nil -- 268
	end -- 268
	if not isValidWorkspacePath(path) then -- 268
		return nil -- 269
	end -- 269
	return Path(workDir, path) -- 270
end -- 267
local function resolveWorkspaceSearchPath(workDir, path) -- 273
	if not isValidWorkDir(workDir) then -- 273
		return nil -- 274
	end -- 274
	if not isValidSearchPath(path) then -- 274
		return nil -- 275
	end -- 275
	return path == "" and workDir or Path(workDir, path) -- 276
end -- 273
local function toWorkspaceRelativePath(workDir, path) -- 279
	if not path or #path == 0 then -- 279
		return path -- 280
	end -- 280
	if not Content:isAbsolutePath(path) then -- 280
		return path -- 281
	end -- 281
	return Path:getRelative(path, workDir) -- 282
end -- 279
local function toWorkspaceRelativeFileList(workDir, files) -- 285
	return __TS__ArrayMap( -- 286
		files, -- 286
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 286
	) -- 286
end -- 285
local function toWorkspaceRelativeSearchResults(workDir, results) -- 289
	local mapped = {} -- 290
	do -- 290
		local i = 0 -- 291
		while i < #results do -- 291
			local row = results[i + 1] -- 292
			local clone = __TS__ObjectAssign({}, row) -- 293
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 294
			mapped[#mapped + 1] = clone -- 295
			i = i + 1 -- 291
		end -- 291
	end -- 291
	return mapped -- 297
end -- 289
local function getDoraAPIDocRoot(docLanguage) -- 300
	local zhDir = Path( -- 301
		Content.assetPath, -- 301
		"Script", -- 301
		"Lib", -- 301
		"Dora", -- 301
		"zh-Hans" -- 301
	) -- 301
	local enDir = Path( -- 302
		Content.assetPath, -- 302
		"Script", -- 302
		"Lib", -- 302
		"Dora", -- 302
		"en" -- 302
	) -- 302
	return docLanguage == "zh" and zhDir or enDir -- 303
end -- 300
local function getDoraTutorialDocRoot(docLanguage) -- 306
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 307
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 308
	return docLanguage == "zh" and zhDir or enDir -- 309
end -- 306
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 312
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 312
		return {"ts"} -- 314
	end -- 314
	return {"tl"} -- 316
end -- 312
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 319
	repeat -- 319
		local ____switch38 = programmingLanguage -- 319
		local ____cond38 = ____switch38 == "teal" -- 319
		if ____cond38 then -- 319
			return "tl" -- 321
		end -- 321
		____cond38 = ____cond38 or ____switch38 == "tl" -- 321
		if ____cond38 then -- 321
			return "tl" -- 322
		end -- 322
		do -- 322
			return programmingLanguage -- 323
		end -- 323
	until true -- 323
end -- 319
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 327
	if docSource == "tutorial" then -- 327
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 333
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 334
		return { -- 335
			root = Path(tutorialRoot, langDir), -- 336
			exts = {"md"}, -- 337
			globs = {"**/*.md"} -- 338
		} -- 338
	end -- 338
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 341
	return { -- 342
		root = getDoraAPIDocRoot(docLanguage), -- 343
		exts = exts, -- 344
		globs = __TS__ArrayMap( -- 345
			exts, -- 345
			function(____, ext) return "**/*." .. ext end -- 345
		) -- 345
	} -- 345
end -- 327
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 349
	if docSource == "tutorial" then -- 349
		return getDoraTutorialDocRoot(docLanguage) -- 351
	end -- 351
	return getDoraAPIDocRoot(docLanguage) -- 353
end -- 349
local function toDocRelativePath(baseRoot, path) -- 356
	if not path or #path == 0 then -- 356
		return path -- 357
	end -- 357
	if not Content:isAbsolutePath(path) then -- 357
		return path -- 358
	end -- 358
	return Path:getRelative(path, baseRoot) -- 359
end -- 356
local function resolveAgentTutorialDocFilePath(path, docLanguage) -- 362
	if not docLanguage then -- 362
		return nil -- 363
	end -- 363
	if not isValidWorkspacePath(path) then -- 363
		return nil -- 364
	end -- 364
	local candidate = Path( -- 365
		getDoraTutorialDocRoot(docLanguage), -- 365
		path -- 365
	) -- 365
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 365
		return candidate -- 367
	end -- 367
	return nil -- 369
end -- 362
local function ensureDirPath(dir) -- 372
	if not dir or dir == "." or dir == "" then -- 372
		return true -- 373
	end -- 373
	if Content:exist(dir) then -- 373
		return Content:isdir(dir) -- 374
	end -- 374
	local parent = Path:getPath(dir) -- 375
	if parent and parent ~= dir and parent ~= "." and parent ~= "" then -- 375
		if not ensureDirPath(parent) then -- 375
			return false -- 377
		end -- 377
	end -- 377
	return Content:mkdir(dir) -- 379
end -- 372
local function ensureDirForFile(path) -- 382
	local dir = Path:getPath(path) -- 383
	return ensureDirPath(dir) -- 384
end -- 382
local function getFileState(path) -- 387
	local exists = Content:exist(path) -- 388
	if not exists then -- 388
		return {exists = false, content = "", bytes = 0} -- 390
	end -- 390
	local content = Content:load(path) -- 396
	return {exists = true, content = content, bytes = #content} -- 397
end -- 387
local function queryOne(sql, args) -- 404
	local ____args_0 -- 405
	if args then -- 405
		____args_0 = DB:query(sql, args) -- 405
	else -- 405
		____args_0 = DB:query(sql) -- 405
	end -- 405
	local rows = ____args_0 -- 405
	if not rows or #rows == 0 then -- 405
		return nil -- 406
	end -- 406
	return rows[1] -- 407
end -- 404
do -- 404
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 412
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 420
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 431
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 432
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 445
end -- 445
local function isDtsFile(path) -- 448
	return Path:getExt(Path:getName(path)) == "d" -- 449
end -- 448
local function getSupportedBuildKind(path) -- 454
	repeat -- 454
		local ____switch64 = Path:getExt(path) -- 454
		local ____cond64 = ____switch64 == "ts" or ____switch64 == "tsx" -- 454
		if ____cond64 then -- 454
			return "ts" -- 456
		end -- 456
		____cond64 = ____cond64 or ____switch64 == "xml" -- 456
		if ____cond64 then -- 456
			return "xml" -- 457
		end -- 457
		____cond64 = ____cond64 or ____switch64 == "tl" -- 457
		if ____cond64 then -- 457
			return "teal" -- 458
		end -- 458
		____cond64 = ____cond64 or ____switch64 == "lua" -- 458
		if ____cond64 then -- 458
			return "lua" -- 459
		end -- 459
		____cond64 = ____cond64 or ____switch64 == "yue" -- 459
		if ____cond64 then -- 459
			return "yue" -- 460
		end -- 460
		____cond64 = ____cond64 or ____switch64 == "yarn" -- 460
		if ____cond64 then -- 460
			return "yarn" -- 461
		end -- 461
		do -- 461
			return nil -- 462
		end -- 462
	until true -- 462
end -- 454
local function getTaskHeadSeq(taskId) -- 466
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 467
	if not row then -- 467
		return nil -- 468
	end -- 468
	return row[1] or 0 -- 469
end -- 466
local function getTaskStatus(taskId) -- 472
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 473
	if not row then -- 473
		return nil -- 474
	end -- 474
	return toStr(row[1]) -- 475
end -- 472
local function getLastInsertRowId() -- 478
	local row = queryOne("SELECT last_insert_rowid()") -- 479
	return row and (row[1] or 0) or 0 -- 480
end -- 478
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 483
	DB:exec( -- 484
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 484
		{ -- 486
			taskId, -- 486
			seq, -- 486
			status, -- 486
			summary, -- 486
			toolName, -- 486
			now() -- 486
		} -- 486
	) -- 486
	return getLastInsertRowId() -- 488
end -- 483
local function getCheckpointEntries(checkpointId, desc) -- 491
	if desc == nil then -- 491
		desc = false -- 491
	end -- 491
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 492
	if not rows then -- 492
		return {} -- 499
	end -- 499
	local result = {} -- 500
	do -- 500
		local i = 0 -- 501
		while i < #rows do -- 501
			local row = rows[i + 1] -- 502
			result[#result + 1] = { -- 503
				id = row[1], -- 504
				ord = row[2], -- 505
				path = toStr(row[3]), -- 506
				op = toStr(row[4]), -- 507
				beforeExists = toBool(row[5]), -- 508
				beforeContent = toStr(row[6]), -- 509
				afterExists = toBool(row[7]), -- 510
				afterContent = toStr(row[8]) -- 511
			} -- 511
			i = i + 1 -- 501
		end -- 501
	end -- 501
	return result -- 514
end -- 491
local function rejectDuplicatePaths(changes) -- 517
	local seen = __TS__New(Set) -- 518
	for ____, change in ipairs(changes) do -- 519
		local key = change.path -- 520
		if seen:has(key) then -- 520
			return key -- 521
		end -- 521
		seen:add(key) -- 522
	end -- 522
	return nil -- 524
end -- 517
local function getLinkedDeletePaths(workDir, path) -- 527
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 528
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 528
		return {} -- 529
	end -- 529
	local parent = Path:getPath(fullPath) -- 530
	local baseName = string.lower(Path:getName(fullPath)) -- 531
	local ext = Path:getExt(fullPath) -- 532
	local linked = {} -- 533
	for ____, file in ipairs(Content:getFiles(parent)) do -- 534
		do -- 534
			if string.lower(Path:getName(file)) ~= baseName then -- 534
				goto __continue81 -- 535
			end -- 535
			local siblingExt = Path:getExt(file) -- 536
			if siblingExt == "tl" and ext == "vs" then -- 536
				linked[#linked + 1] = toWorkspaceRelativePath( -- 538
					workDir, -- 538
					Path(parent, file) -- 538
				) -- 538
				goto __continue81 -- 539
			end -- 539
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 539
				linked[#linked + 1] = toWorkspaceRelativePath( -- 542
					workDir, -- 542
					Path(parent, file) -- 542
				) -- 542
			end -- 542
		end -- 542
		::__continue81:: -- 542
	end -- 542
	return linked -- 545
end -- 527
local function expandLinkedDeleteChanges(workDir, changes) -- 548
	local expanded = {} -- 549
	local seen = __TS__New(Set) -- 550
	do -- 550
		local i = 0 -- 551
		while i < #changes do -- 551
			do -- 551
				local change = changes[i + 1] -- 552
				if not seen:has(change.path) then -- 552
					seen:add(change.path) -- 554
					expanded[#expanded + 1] = change -- 555
				end -- 555
				if change.op ~= "delete" then -- 555
					goto __continue88 -- 557
				end -- 557
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 558
				do -- 558
					local j = 0 -- 559
					while j < #linkedPaths do -- 559
						do -- 559
							local linkedPath = linkedPaths[j + 1] -- 560
							if seen:has(linkedPath) then -- 560
								goto __continue92 -- 561
							end -- 561
							seen:add(linkedPath) -- 562
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 563
						end -- 563
						::__continue92:: -- 563
						j = j + 1 -- 559
					end -- 559
				end -- 559
			end -- 559
			::__continue88:: -- 559
			i = i + 1 -- 551
		end -- 551
	end -- 551
	return expanded -- 566
end -- 548
local function applySingleFile(path, exists, content) -- 569
	if exists then -- 569
		if not ensureDirForFile(path) then -- 569
			return false -- 571
		end -- 571
		return Content:save(path, content) -- 572
	end -- 572
	if Content:exist(path) then -- 572
		return Content:remove(path) -- 575
	end -- 575
	return true -- 577
end -- 569
local function encodeJSON(obj) -- 580
	local text = safeJsonEncode(obj) -- 581
	return text -- 582
end -- 580
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 585
	if HttpServer.wsConnectionCount == 0 then -- 585
		return true -- 587
	end -- 587
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 589
	if not payload then -- 589
		return false -- 591
	end -- 591
	emit("AppWS", "Send", payload) -- 593
	return true -- 594
end -- 585
local function runSingleNonTsBuild(file) -- 597
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 597
		return ____awaiter_resolve( -- 597
			nil, -- 597
			__TS__New( -- 598
				__TS__Promise, -- 598
				function(____, resolve) -- 598
					local ____require_result_1 = require("Script.Dev.WebServer") -- 599
					local buildAsync = ____require_result_1.buildAsync -- 599
					Director.systemScheduler:schedule(once(function() -- 600
						local result = buildAsync(file) -- 601
						resolve(nil, result) -- 602
					end)) -- 600
				end -- 598
			) -- 598
		) -- 598
	end) -- 598
end -- 597
function ____exports.runSingleTsTranspile(file, content) -- 607
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 607
		local done = false -- 608
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 609
		if HttpServer.wsConnectionCount == 0 then -- 609
			return ____awaiter_resolve(nil, result) -- 609
		end -- 609
		local listener = Node() -- 617
		listener:gslot( -- 618
			"AppWS", -- 618
			function(event) -- 618
				if event.type ~= "Receive" then -- 618
					return -- 619
				end -- 619
				local res = safeJsonDecode(event.msg) -- 620
				if not res or __TS__ArrayIsArray(res) then -- 620
					return -- 621
				end -- 621
				local payload = res -- 622
				if payload.name ~= "TranspileTS" then -- 622
					return -- 623
				end -- 623
				if tostring(payload.file) ~= file then -- 623
					return -- 624
				end -- 624
				if payload.success then -- 624
					local luaFile = Path:replaceExt(file, "lua") -- 626
					if Content:save( -- 626
						luaFile, -- 627
						tostring(payload.luaCode) -- 627
					) then -- 627
						result = {success = true, file = file} -- 628
					else -- 628
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 630
					end -- 630
				else -- 630
					result = { -- 633
						success = false, -- 633
						file = file, -- 633
						message = tostring(payload.message) -- 633
					} -- 633
				end -- 633
				done = true -- 635
			end -- 618
		) -- 618
		local payload = encodeJSON({name = "TranspileTS", file = file, content = content}) -- 637
		if not payload then -- 637
			listener:removeFromParent() -- 643
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 643
		end -- 643
		__TS__Await(__TS__New( -- 646
			__TS__Promise, -- 646
			function(____, resolve) -- 646
				Director.systemScheduler:schedule(once(function() -- 647
					emit("AppWS", "Send", payload) -- 648
					wait(function() return done end) -- 649
					if not done then -- 649
						listener:removeFromParent() -- 651
					end -- 651
					resolve(nil) -- 653
				end)) -- 647
			end -- 646
		)) -- 646
		return ____awaiter_resolve(nil, result) -- 646
	end) -- 646
end -- 607
function ____exports.createTask(prompt) -- 659
	if prompt == nil then -- 659
		prompt = "" -- 659
	end -- 659
	local t = now() -- 660
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 661
	if affected <= 0 then -- 661
		return {success = false, message = "failed to create task"} -- 666
	end -- 666
	return { -- 668
		success = true, -- 668
		taskId = getLastInsertRowId() -- 668
	} -- 668
end -- 659
function ____exports.setTaskStatus(taskId, status) -- 671
	DB:exec( -- 672
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 672
		{ -- 672
			status, -- 672
			now(), -- 672
			taskId -- 672
		} -- 672
	) -- 672
	Log( -- 673
		"Info", -- 673
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 673
	) -- 673
end -- 671
function ____exports.listCheckpoints(taskId) -- 676
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 677
	if not rows then -- 677
		return {} -- 684
	end -- 684
	local items = {} -- 685
	do -- 685
		local i = 0 -- 686
		while i < #rows do -- 686
			local row = rows[i + 1] -- 687
			items[#items + 1] = { -- 688
				id = row[1], -- 689
				taskId = row[2], -- 690
				seq = row[3], -- 691
				status = toStr(row[4]), -- 692
				summary = toStr(row[5]), -- 693
				toolName = toStr(row[6]), -- 694
				createdAt = row[7] -- 695
			} -- 695
			i = i + 1 -- 686
		end -- 686
	end -- 686
	return items -- 698
end -- 676
local function listCheckpointIdsForTask(taskId, desc) -- 701
	if desc == nil then -- 701
		desc = false -- 701
	end -- 701
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 702
	if not rows then -- 702
		return {} -- 709
	end -- 709
	local items = {} -- 710
	do -- 710
		local i = 0 -- 711
		while i < #rows do -- 711
			local row = rows[i + 1] -- 712
			items[#items + 1] = {id = row[1], seq = row[2]} -- 713
			i = i + 1 -- 711
		end -- 711
	end -- 711
	return items -- 718
end -- 701
local function deriveFileOp(beforeExists, afterExists) -- 721
	if not beforeExists and afterExists then -- 721
		return "create" -- 722
	end -- 722
	if beforeExists and not afterExists then -- 722
		return "delete" -- 723
	end -- 723
	return "write" -- 724
end -- 721
function ____exports.summarizeTaskChangeSet(taskId) -- 727
	if not getTaskStatus(taskId) then -- 727
		return {success = false, message = "task not found"} -- 729
	end -- 729
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 731
	local filesByPath = {} -- 732
	local latestCheckpointId = nil -- 738
	local latestCheckpointSeq = nil -- 739
	do -- 739
		local i = 0 -- 740
		while i < #checkpoints do -- 740
			local checkpoint = checkpoints[i + 1] -- 741
			latestCheckpointId = checkpoint.id -- 742
			latestCheckpointSeq = checkpoint.seq -- 743
			local entries = getCheckpointEntries(checkpoint.id, false) -- 744
			do -- 744
				local j = 0 -- 745
				while j < #entries do -- 745
					local entry = entries[j + 1] -- 746
					local item = filesByPath[entry.path] -- 747
					if not item then -- 747
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 749
						filesByPath[entry.path] = item -- 755
					end -- 755
					item.afterExists = entry.afterExists -- 757
					local ____item_checkpointIds_2 = item.checkpointIds -- 757
					____item_checkpointIds_2[#____item_checkpointIds_2 + 1] = checkpoint.id -- 758
					j = j + 1 -- 745
				end -- 745
			end -- 745
			i = i + 1 -- 740
		end -- 740
	end -- 740
	local files = {} -- 761
	for ____, item in pairs(filesByPath) do -- 762
		files[#files + 1] = { -- 763
			path = item.path, -- 764
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 765
			checkpointCount = #item.checkpointIds, -- 766
			checkpointIds = item.checkpointIds -- 767
		} -- 767
	end -- 767
	__TS__ArraySort( -- 770
		files, -- 770
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 770
	) -- 770
	return { -- 771
		success = true, -- 772
		taskId = taskId, -- 773
		checkpointCount = #checkpoints, -- 774
		filesChanged = #files, -- 775
		files = files, -- 776
		latestCheckpointId = latestCheckpointId, -- 777
		latestCheckpointSeq = latestCheckpointSeq -- 778
	} -- 778
end -- 727
function ____exports.getTaskChangeSetDiff(taskId) -- 782
	if not getTaskStatus(taskId) then -- 782
		return {success = false, message = "task not found"} -- 784
	end -- 784
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 786
	if #checkpoints == 0 then -- 786
		return {success = false, message = "change set not found or empty"} -- 788
	end -- 788
	local filesByPath = {} -- 790
	do -- 790
		local i = 0 -- 797
		while i < #checkpoints do -- 797
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 798
			do -- 798
				local j = 0 -- 799
				while j < #entries do -- 799
					local entry = entries[j + 1] -- 800
					local item = filesByPath[entry.path] -- 801
					if not item then -- 801
						item = { -- 803
							path = entry.path, -- 804
							beforeExists = entry.beforeExists, -- 805
							beforeContent = entry.beforeContent, -- 806
							afterExists = entry.afterExists, -- 807
							afterContent = entry.afterContent -- 808
						} -- 808
						filesByPath[entry.path] = item -- 810
					end -- 810
					item.afterExists = entry.afterExists -- 812
					item.afterContent = entry.afterContent -- 813
					j = j + 1 -- 799
				end -- 799
			end -- 799
			i = i + 1 -- 797
		end -- 797
	end -- 797
	local files = {} -- 816
	for ____, item in pairs(filesByPath) do -- 817
		files[#files + 1] = { -- 818
			path = item.path, -- 819
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 820
			beforeExists = item.beforeExists, -- 821
			afterExists = item.afterExists, -- 822
			beforeContent = item.beforeContent, -- 823
			afterContent = item.afterContent -- 824
		} -- 824
	end -- 824
	__TS__ArraySort( -- 827
		files, -- 827
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 827
	) -- 827
	return {success = true, files = files} -- 828
end -- 782
local function readWorkspaceFile(workDir, path, docLanguage) -- 831
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 832
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 832
		return { -- 834
			success = true, -- 834
			content = Content:load(fullPath) -- 834
		} -- 834
	end -- 834
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 836
	if docPath then -- 836
		return { -- 838
			success = true, -- 838
			content = Content:load(docPath) -- 838
		} -- 838
	end -- 838
	if not fullPath then -- 838
		return {success = false, message = "invalid path or workDir"} -- 840
	end -- 840
	return {success = false, message = "file not found"} -- 841
end -- 831
function ____exports.readFileRaw(workDir, path, docLanguage) -- 844
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 845
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 845
		return { -- 847
			success = true, -- 847
			content = Content:load(path) -- 847
		} -- 847
	end -- 847
	return result -- 849
end -- 844
local function getEngineLogText() -- 852
	local folder = Path(Content.writablePath, ENGINE_LOG_SNAPSHOT_DIR) -- 853
	if not Content:exist(folder) then -- 853
		Content:mkdir(folder) -- 855
	end -- 855
	local logPath = Path(folder, ENGINE_LOG_SNAPSHOT_FILE) -- 857
	if not App:saveLog(logPath) then -- 857
		return nil -- 859
	end -- 859
	return Content:load(logPath) -- 861
end -- 852
function ____exports.getLogs(req) -- 864
	local text = getEngineLogText() -- 865
	if text == nil then -- 865
		return {success = false, message = "failed to read engine logs"} -- 867
	end -- 867
	local tailLines = math.max( -- 869
		1, -- 869
		math.floor(req and req.tailLines or 200) -- 869
	) -- 869
	local allLines = __TS__StringSplit(text, "\n") -- 870
	local logs = __TS__ArraySlice( -- 871
		allLines, -- 871
		math.max(0, #allLines - tailLines) -- 871
	) -- 871
	return req and req.joinText and ({ -- 872
		success = true, -- 872
		logs = logs, -- 872
		text = table.concat(logs, "\n") -- 872
	}) or ({success = true, logs = logs}) -- 872
end -- 864
function ____exports.listFiles(req) -- 875
	local root = req.path or "" -- 881
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 882
	if not searchRoot then -- 882
		return {success = false, message = "invalid path or workDir"} -- 884
	end -- 884
	do -- 884
		local function ____catch(e) -- 884
			return true, { -- 902
				success = false, -- 902
				message = tostring(e) -- 902
			} -- 902
		end -- 902
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 902
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 887
			local globs = ensureSafeSearchGlobs(userGlobs) -- 888
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 889
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 890
			local totalEntries = #files -- 891
			local maxEntries = math.max( -- 892
				1, -- 892
				math.floor(req.maxEntries or 200) -- 892
			) -- 892
			local truncated = totalEntries > maxEntries -- 893
			return true, { -- 894
				success = true, -- 895
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 896
				totalEntries = totalEntries, -- 897
				truncated = truncated, -- 898
				maxEntries = maxEntries -- 899
			} -- 899
		end) -- 899
		if not ____try then -- 899
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 899
		end -- 899
		if ____hasReturned then -- 899
			return ____returnValue -- 886
		end -- 886
	end -- 886
end -- 875
local function formatReadSlice(content, startLine, endLine) -- 906
	local lines = __TS__StringSplit(content, "\n") -- 911
	local totalLines = #lines -- 912
	if totalLines == 0 then -- 912
		return { -- 914
			success = true, -- 915
			content = "", -- 916
			totalLines = 0, -- 917
			startLine = 1, -- 918
			endLine = 0, -- 919
			truncated = false -- 920
		} -- 920
	end -- 920
	local rawStart = math.floor(startLine) -- 923
	local rawEnd = math.floor(endLine) -- 924
	if rawStart == 0 then -- 924
		return {success = false, message = "startLine cannot be 0"} -- 926
	end -- 926
	if rawEnd == 0 then -- 926
		return {success = false, message = "endLine cannot be 0"} -- 929
	end -- 929
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 931
	if start > totalLines then -- 931
		return { -- 935
			success = false, -- 935
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 935
		} -- 935
	end -- 935
	local ____end = math.min( -- 937
		totalLines, -- 938
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 939
	) -- 939
	if ____end < start then -- 939
		return { -- 944
			success = false, -- 945
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 946
		} -- 946
	end -- 946
	local slice = {} -- 949
	do -- 949
		local i = start -- 950
		while i <= ____end do -- 950
			slice[#slice + 1] = lines[i] -- 951
			i = i + 1 -- 950
		end -- 950
	end -- 950
	local truncated = start > 1 or ____end < totalLines -- 953
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 954
	local body = table.concat(slice, "\n") -- 959
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 960
	return { -- 961
		success = true, -- 962
		content = output, -- 963
		totalLines = totalLines, -- 964
		startLine = start, -- 965
		endLine = ____end, -- 966
		truncated = truncated -- 967
	} -- 967
end -- 906
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 971
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 978
	if not fallback.success or fallback.content == nil then -- 978
		return fallback -- 979
	end -- 979
	local resolvedStartLine = startLine or 1 -- 980
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 981
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 982
end -- 971
local codeExtensions = { -- 989
	".lua", -- 989
	".tl", -- 989
	".yue", -- 989
	".ts", -- 989
	".tsx", -- 989
	".xml", -- 989
	".md", -- 989
	".yarn", -- 989
	".wa", -- 989
	".mod" -- 989
} -- 989
extensionLevels = { -- 990
	vs = 2, -- 991
	bl = 2, -- 992
	ts = 1, -- 993
	tsx = 1, -- 994
	tl = 1, -- 995
	yue = 1, -- 996
	xml = 1, -- 997
	lua = 0 -- 998
} -- 998
local function splitSearchPatterns(pattern) -- 1015
	local trimmed = __TS__StringTrim(pattern or "") -- 1016
	if trimmed == "" then -- 1016
		return {} -- 1017
	end -- 1017
	local out = {} -- 1018
	local seen = __TS__New(Set) -- 1019
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1020
		local p = __TS__StringTrim(tostring(p0)) -- 1021
		if p ~= "" and not seen:has(p) then -- 1021
			seen:add(p) -- 1023
			out[#out + 1] = p -- 1024
		end -- 1024
	end -- 1024
	return out -- 1027
end -- 1015
local function mergeSearchFileResultsUnique(resultsList) -- 1030
	local merged = {} -- 1031
	local seen = __TS__New(Set) -- 1032
	do -- 1032
		local i = 0 -- 1033
		while i < #resultsList do -- 1033
			local list = resultsList[i + 1] -- 1034
			do -- 1034
				local j = 0 -- 1035
				while j < #list do -- 1035
					do -- 1035
						local row = list[j + 1] -- 1036
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1037
						if seen:has(key) then -- 1037
							goto __continue193 -- 1038
						end -- 1038
						seen:add(key) -- 1039
						merged[#merged + 1] = list[j + 1] -- 1040
					end -- 1040
					::__continue193:: -- 1040
					j = j + 1 -- 1035
				end -- 1035
			end -- 1035
			i = i + 1 -- 1033
		end -- 1033
	end -- 1033
	return merged -- 1043
end -- 1030
local function buildGroupedSearchResults(results) -- 1046
	local order = {} -- 1051
	local grouped = __TS__New(Map) -- 1052
	do -- 1052
		local i = 0 -- 1057
		while i < #results do -- 1057
			local row = results[i + 1] -- 1058
			local file = row.file -- 1059
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1060
			local bucket = grouped:get(key) -- 1061
			if not bucket then -- 1061
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1063
				grouped:set(key, bucket) -- 1064
				order[#order + 1] = key -- 1065
			end -- 1065
			bucket.totalMatches = bucket.totalMatches + 1 -- 1067
			local ____bucket_matches_7 = bucket.matches -- 1067
			____bucket_matches_7[#____bucket_matches_7 + 1] = results[i + 1] -- 1068
			i = i + 1 -- 1057
		end -- 1057
	end -- 1057
	local out = {} -- 1070
	do -- 1070
		local i = 0 -- 1075
		while i < #order do -- 1075
			local bucket = grouped:get(order[i + 1]) -- 1076
			if bucket then -- 1076
				out[#out + 1] = bucket -- 1077
			end -- 1077
			i = i + 1 -- 1075
		end -- 1075
	end -- 1075
	return out -- 1079
end -- 1046
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1082
	local merged = {} -- 1083
	local seen = __TS__New(Set) -- 1084
	local index = 0 -- 1085
	local advanced = true -- 1086
	while advanced do -- 1086
		advanced = false -- 1088
		do -- 1088
			local i = 0 -- 1089
			while i < #resultsList do -- 1089
				do -- 1089
					local list = resultsList[i + 1] -- 1090
					if index >= #list then -- 1090
						goto __continue205 -- 1091
					end -- 1091
					advanced = true -- 1092
					local row = list[index + 1] -- 1093
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1094
					if seen:has(key) then -- 1094
						goto __continue205 -- 1095
					end -- 1095
					seen:add(key) -- 1096
					merged[#merged + 1] = row -- 1097
				end -- 1097
				::__continue205:: -- 1097
				i = i + 1 -- 1089
			end -- 1089
		end -- 1089
		index = index + 1 -- 1099
	end -- 1099
	return merged -- 1101
end -- 1082
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1104
	if docSource ~= "api" then -- 1104
		return 100 -- 1105
	end -- 1105
	if programmingLanguage ~= "tsx" then -- 1105
		return 100 -- 1106
	end -- 1106
	repeat -- 1106
		local ____switch211 = string.lower(Path:getFilename(file)) -- 1106
		local ____cond211 = ____switch211 == "jsx.d.ts" -- 1106
		if ____cond211 then -- 1106
			return 0 -- 1108
		end -- 1108
		____cond211 = ____cond211 or ____switch211 == "dorax.d.ts" -- 1108
		if ____cond211 then -- 1108
			return 1 -- 1109
		end -- 1109
		____cond211 = ____cond211 or ____switch211 == "dora.d.ts" -- 1109
		if ____cond211 then -- 1109
			return 2 -- 1110
		end -- 1110
		do -- 1110
			return 100 -- 1111
		end -- 1111
	until true -- 1111
end -- 1104
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1115
	local sorted = __TS__ArraySlice(hits) -- 1120
	__TS__ArraySort( -- 1121
		sorted, -- 1121
		function(____, a, b) -- 1121
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1122
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1123
			if pa ~= pb then -- 1123
				return pa - pb -- 1124
			end -- 1124
			local fa = string.lower(a.file) -- 1125
			local fb = string.lower(b.file) -- 1126
			if fa ~= fb then -- 1126
				return fa < fb and -1 or 1 -- 1127
			end -- 1127
			return (a.line or 0) - (b.line or 0) -- 1128
		end -- 1121
	) -- 1121
	return sorted -- 1130
end -- 1115
function ____exports.searchFiles(req) -- 1133
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1133
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1146
		if not resolvedPath then -- 1146
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1146
		end -- 1146
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1150
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1151
		if not searchRoot then -- 1151
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1151
		end -- 1151
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1151
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1151
		end -- 1151
		local patterns = splitSearchPatterns(req.pattern) -- 1158
		if #patterns == 0 then -- 1158
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1158
		end -- 1158
		return ____awaiter_resolve( -- 1158
			nil, -- 1158
			__TS__New( -- 1162
				__TS__Promise, -- 1162
				function(____, resolve) -- 1162
					Director.systemScheduler:schedule(once(function() -- 1163
						do -- 1163
							local function ____catch(e) -- 1163
								resolve( -- 1205
									nil, -- 1205
									{ -- 1205
										success = false, -- 1205
										message = tostring(e) -- 1205
									} -- 1205
								) -- 1205
							end -- 1205
							local ____try, ____hasReturned = pcall(function() -- 1205
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1165
								local allResults = {} -- 1168
								do -- 1168
									local i = 0 -- 1169
									while i < #patterns do -- 1169
										local ____Content_12 = Content -- 1170
										local ____Content_searchFilesAsync_13 = Content.searchFilesAsync -- 1170
										local ____patterns_index_11 = patterns[i + 1] -- 1175
										local ____req_useRegex_8 = req.useRegex -- 1176
										if ____req_useRegex_8 == nil then -- 1176
											____req_useRegex_8 = false -- 1176
										end -- 1176
										local ____req_caseSensitive_9 = req.caseSensitive -- 1177
										if ____req_caseSensitive_9 == nil then -- 1177
											____req_caseSensitive_9 = false -- 1177
										end -- 1177
										local ____req_includeContent_10 = req.includeContent -- 1178
										if ____req_includeContent_10 == nil then -- 1178
											____req_includeContent_10 = true -- 1178
										end -- 1178
										allResults[#allResults + 1] = ____Content_searchFilesAsync_13( -- 1170
											____Content_12, -- 1170
											searchRoot, -- 1171
											codeExtensions, -- 1172
											extensionLevels, -- 1173
											searchGlobs, -- 1174
											____patterns_index_11, -- 1175
											____req_useRegex_8, -- 1176
											____req_caseSensitive_9, -- 1177
											____req_includeContent_10, -- 1178
											req.contentWindow or 120 -- 1179
										) -- 1179
										i = i + 1 -- 1169
									end -- 1169
								end -- 1169
								local results = mergeSearchFileResultsUnique(allResults) -- 1182
								local totalResults = #results -- 1183
								local limit = math.max( -- 1184
									1, -- 1184
									math.floor(req.limit or 20) -- 1184
								) -- 1184
								local offset = math.max( -- 1185
									0, -- 1185
									math.floor(req.offset or 0) -- 1185
								) -- 1185
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1186
								local nextOffset = offset + #paged -- 1187
								local hasMore = nextOffset < totalResults -- 1188
								local truncated = offset > 0 or hasMore -- 1189
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1190
								local groupByFile = req.groupByFile == true -- 1191
								resolve( -- 1192
									nil, -- 1192
									{ -- 1192
										success = true, -- 1193
										results = relativeResults, -- 1194
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1195
										totalResults = totalResults, -- 1196
										truncated = truncated, -- 1197
										limit = limit, -- 1198
										offset = offset, -- 1199
										nextOffset = nextOffset, -- 1200
										hasMore = hasMore, -- 1201
										groupByFile = groupByFile -- 1202
									} -- 1202
								) -- 1202
							end) -- 1202
							if not ____try then -- 1202
								____catch(____hasReturned) -- 1202
							end -- 1202
						end -- 1202
					end)) -- 1163
				end -- 1162
			) -- 1162
		) -- 1162
	end) -- 1162
end -- 1133
function ____exports.searchDoraAPI(req) -- 1211
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1211
		local pattern = __TS__StringTrim(req.pattern or "") -- 1222
		if pattern == "" then -- 1222
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1222
		end -- 1222
		local patterns = splitSearchPatterns(pattern) -- 1224
		if #patterns == 0 then -- 1224
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1224
		end -- 1224
		local docSource = req.docSource or "api" -- 1226
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1227
		local docRoot = target.root -- 1228
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1229
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1229
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1229
		end -- 1229
		local exts = target.exts -- 1233
		local dotExts = __TS__ArrayMap( -- 1234
			exts, -- 1234
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1234
		) -- 1234
		local globs = target.globs -- 1235
		local limit = math.max( -- 1236
			1, -- 1236
			math.floor(req.limit or 10) -- 1236
		) -- 1236
		return ____awaiter_resolve( -- 1236
			nil, -- 1236
			__TS__New( -- 1238
				__TS__Promise, -- 1238
				function(____, resolve) -- 1238
					Director.systemScheduler:schedule(once(function() -- 1239
						do -- 1239
							local function ____catch(e) -- 1239
								resolve( -- 1280
									nil, -- 1280
									{ -- 1280
										success = false, -- 1280
										message = tostring(e) -- 1280
									} -- 1280
								) -- 1280
							end -- 1280
							local ____try, ____hasReturned = pcall(function() -- 1280
								local allHits = {} -- 1241
								do -- 1241
									local p = 0 -- 1242
									while p < #patterns do -- 1242
										local ____Content_18 = Content -- 1243
										local ____Content_searchFilesAsync_19 = Content.searchFilesAsync -- 1243
										local ____array_17 = __TS__SparseArrayNew( -- 1243
											docRoot, -- 1244
											dotExts, -- 1245
											{}, -- 1246
											ensureSafeSearchGlobs(globs), -- 1247
											patterns[p + 1] -- 1248
										) -- 1248
										local ____req_useRegex_14 = req.useRegex -- 1249
										if ____req_useRegex_14 == nil then -- 1249
											____req_useRegex_14 = false -- 1249
										end -- 1249
										__TS__SparseArrayPush(____array_17, ____req_useRegex_14) -- 1249
										local ____req_caseSensitive_15 = req.caseSensitive -- 1250
										if ____req_caseSensitive_15 == nil then -- 1250
											____req_caseSensitive_15 = false -- 1250
										end -- 1250
										__TS__SparseArrayPush(____array_17, ____req_caseSensitive_15) -- 1250
										local ____req_includeContent_16 = req.includeContent -- 1251
										if ____req_includeContent_16 == nil then -- 1251
											____req_includeContent_16 = true -- 1251
										end -- 1251
										__TS__SparseArrayPush(____array_17, ____req_includeContent_16, req.contentWindow or 80) -- 1251
										local raw = ____Content_searchFilesAsync_19( -- 1243
											____Content_18, -- 1243
											__TS__SparseArraySpread(____array_17) -- 1243
										) -- 1243
										local hits = {} -- 1254
										do -- 1254
											local i = 0 -- 1255
											while i < #raw do -- 1255
												do -- 1255
													local row = raw[i + 1] -- 1256
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1257
													if file == "" then -- 1257
														goto __continue238 -- 1258
													end -- 1258
													hits[#hits + 1] = { -- 1259
														file = file, -- 1260
														line = type(row.line) == "number" and row.line or nil, -- 1261
														content = type(row.content) == "string" and row.content or nil -- 1262
													} -- 1262
												end -- 1262
												::__continue238:: -- 1262
												i = i + 1 -- 1255
											end -- 1255
										end -- 1255
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1265
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1265
											0, -- 1265
											limit -- 1265
										) -- 1265
										p = p + 1 -- 1242
									end -- 1242
								end -- 1242
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1267
								resolve(nil, { -- 1268
									success = true, -- 1269
									docSource = docSource, -- 1270
									docLanguage = req.docLanguage, -- 1271
									programmingLanguage = req.programmingLanguage, -- 1272
									exts = exts, -- 1273
									results = hits, -- 1274
									totalResults = #hits, -- 1275
									truncated = false, -- 1276
									limit = limit -- 1277
								}) -- 1277
							end) -- 1277
							if not ____try then -- 1277
								____catch(____hasReturned) -- 1277
							end -- 1277
						end -- 1277
					end)) -- 1239
				end -- 1238
			) -- 1238
		) -- 1238
	end) -- 1238
end -- 1211
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1286
	if options == nil then -- 1286
		options = {} -- 1286
	end -- 1286
	if #changes == 0 then -- 1286
		return {success = false, message = "empty changes"} -- 1288
	end -- 1288
	if not isValidWorkDir(workDir) then -- 1288
		return {success = false, message = "invalid workDir"} -- 1291
	end -- 1291
	if not getTaskStatus(taskId) then -- 1291
		return {success = false, message = "task not found"} -- 1294
	end -- 1294
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1296
	local dup = rejectDuplicatePaths(expandedChanges) -- 1297
	if dup then -- 1297
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1299
	end -- 1299
	for ____, change in ipairs(expandedChanges) do -- 1302
		if not isValidWorkspacePath(change.path) then -- 1302
			return {success = false, message = "invalid path: " .. change.path} -- 1304
		end -- 1304
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1304
			return {success = false, message = "missing content for " .. change.path} -- 1307
		end -- 1307
	end -- 1307
	local headSeq = getTaskHeadSeq(taskId) -- 1311
	if headSeq == nil then -- 1311
		return {success = false, message = "task not found"} -- 1312
	end -- 1312
	local nextSeq = headSeq + 1 -- 1313
	local checkpointId = insertCheckpoint( -- 1314
		taskId, -- 1314
		nextSeq, -- 1314
		options.summary or "", -- 1314
		options.toolName or "", -- 1314
		"PREPARED" -- 1314
	) -- 1314
	if checkpointId <= 0 then -- 1314
		return {success = false, message = "failed to create checkpoint"} -- 1316
	end -- 1316
	do -- 1316
		local i = 0 -- 1319
		while i < #expandedChanges do -- 1319
			local change = expandedChanges[i + 1] -- 1320
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1321
			if not fullPath then -- 1321
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1323
				return {success = false, message = "invalid path: " .. change.path} -- 1324
			end -- 1324
			local before = getFileState(fullPath) -- 1326
			local afterExists = change.op ~= "delete" -- 1327
			local afterContent = afterExists and (change.content or "") or "" -- 1328
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1329
				checkpointId, -- 1333
				i + 1, -- 1334
				change.path, -- 1335
				change.op, -- 1336
				before.exists and 1 or 0, -- 1337
				before.content, -- 1338
				afterExists and 1 or 0, -- 1339
				afterContent, -- 1340
				before.bytes, -- 1341
				#afterContent -- 1342
			}) -- 1342
			if inserted <= 0 then -- 1342
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1346
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1347
			end -- 1347
			i = i + 1 -- 1319
		end -- 1319
	end -- 1319
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1351
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1352
		if not fullPath then -- 1352
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1354
			return {success = false, message = "invalid path: " .. entry.path} -- 1355
		end -- 1355
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1357
		if not ok then -- 1357
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1359
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1360
		end -- 1360
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1360
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1363
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1364
		end -- 1364
	end -- 1364
	DB:exec( -- 1368
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1368
		{ -- 1370
			"APPLIED", -- 1370
			now(), -- 1370
			checkpointId -- 1370
		} -- 1370
	) -- 1370
	DB:exec( -- 1372
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1372
		{ -- 1374
			nextSeq, -- 1374
			now(), -- 1374
			taskId -- 1374
		} -- 1374
	) -- 1374
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1376
end -- 1286
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1384
	if not isValidWorkDir(workDir) then -- 1384
		return {success = false, message = "invalid workDir"} -- 1385
	end -- 1385
	if checkpointId <= 0 then -- 1385
		return {success = false, message = "invalid checkpointId"} -- 1386
	end -- 1386
	local entries = getCheckpointEntries(checkpointId, true) -- 1387
	if #entries == 0 then -- 1387
		return {success = false, message = "checkpoint not found or empty"} -- 1389
	end -- 1389
	for ____, entry in ipairs(entries) do -- 1391
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1392
		if not fullPath then -- 1392
			return {success = false, message = "invalid path: " .. entry.path} -- 1394
		end -- 1394
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1396
		if not ok then -- 1396
			Log( -- 1398
				"Error", -- 1398
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1398
			) -- 1398
			Log( -- 1399
				"Info", -- 1399
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1399
			) -- 1399
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1400
		end -- 1400
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1400
			Log( -- 1403
				"Error", -- 1403
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1403
			) -- 1403
			Log( -- 1404
				"Info", -- 1404
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1404
			) -- 1404
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1405
		end -- 1405
	end -- 1405
	DB:exec( -- 1408
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 1408
		{ -- 1408
			"REVERTED", -- 1408
			now(), -- 1408
			checkpointId -- 1408
		} -- 1408
	) -- 1408
	return {success = true, checkpointId = checkpointId} -- 1409
end -- 1384
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 1412
	if not isValidWorkDir(workDir) then -- 1412
		return {success = false, message = "invalid workDir"} -- 1413
	end -- 1413
	if not getTaskStatus(taskId) then -- 1413
		return {success = false, message = "task not found"} -- 1414
	end -- 1414
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 1415
	if #checkpoints == 0 then -- 1415
		return {success = false, message = "change set not found or empty"} -- 1417
	end -- 1417
	local lastCheckpointId = 0 -- 1419
	do -- 1419
		local i = 0 -- 1420
		while i < #checkpoints do -- 1420
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 1421
			if not result.success then -- 1421
				return {success = false, message = result.message} -- 1422
			end -- 1422
			lastCheckpointId = checkpoints[i + 1].id -- 1423
			i = i + 1 -- 1420
		end -- 1420
	end -- 1420
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 1425
end -- 1412
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1433
	return getCheckpointEntries(checkpointId, false) -- 1434
end -- 1433
function ____exports.getCheckpointDiff(checkpointId) -- 1437
	if checkpointId <= 0 then -- 1437
		return {success = false, message = "invalid checkpointId"} -- 1439
	end -- 1439
	local entries = getCheckpointEntries(checkpointId, false) -- 1441
	if #entries == 0 then -- 1441
		return {success = false, message = "checkpoint not found or empty"} -- 1443
	end -- 1443
	return { -- 1445
		success = true, -- 1446
		files = __TS__ArrayMap( -- 1447
			entries, -- 1447
			function(____, entry) return { -- 1447
				path = entry.path, -- 1448
				op = entry.op, -- 1449
				beforeExists = entry.beforeExists, -- 1450
				afterExists = entry.afterExists, -- 1451
				beforeContent = entry.beforeContent, -- 1452
				afterContent = entry.afterContent -- 1453
			} end -- 1453
		) -- 1453
	} -- 1453
end -- 1437
local function finalizeBuildResult(workDir, messages) -- 1458
	local normalized = __TS__ArrayMap( -- 1459
		messages, -- 1459
		function(____, m) return m.success and __TS__ObjectAssign( -- 1459
			{}, -- 1460
			m, -- 1460
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1460
		) or __TS__ObjectAssign( -- 1460
			{}, -- 1461
			m, -- 1461
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1461
		) end -- 1461
	) -- 1461
	local total = #normalized -- 1462
	local failed = 0 -- 1463
	do -- 1463
		local i = 0 -- 1464
		while i < #normalized do -- 1464
			if not normalized[i + 1].success then -- 1464
				failed = failed + 1 -- 1465
			end -- 1465
			i = i + 1 -- 1464
		end -- 1464
	end -- 1464
	local passed = total - failed -- 1467
	if failed > 0 then -- 1467
		return { -- 1469
			success = false, -- 1470
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 1471
			total = total, -- 1472
			passed = passed, -- 1473
			failed = failed, -- 1474
			messages = normalized -- 1475
		} -- 1475
	end -- 1475
	return { -- 1478
		success = true, -- 1479
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 1480
		total = total, -- 1481
		passed = passed, -- 1482
		failed = 0, -- 1483
		messages = normalized -- 1484
	} -- 1484
end -- 1458
function ____exports.build(req) -- 1488
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1488
		local targetRel = req.path or "" -- 1489
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1490
		if not target then -- 1490
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1490
		end -- 1490
		if not Content:exist(target) then -- 1490
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1490
		end -- 1490
		local messages = {} -- 1497
		if not Content:isdir(target) then -- 1497
			local kind = getSupportedBuildKind(target) -- 1499
			if not kind then -- 1499
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1499
			end -- 1499
			if kind == "ts" then -- 1499
				local content = Content:load(target) -- 1504
				if content == nil then -- 1504
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1504
				end -- 1504
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1504
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1504
				end -- 1504
				if not isDtsFile(target) then -- 1504
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1512
				end -- 1512
			else -- 1512
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1515
			end -- 1515
			Log( -- 1517
				"Info", -- 1517
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1517
			) -- 1517
			return ____awaiter_resolve( -- 1517
				nil, -- 1517
				finalizeBuildResult(req.workDir, messages) -- 1518
			) -- 1518
		end -- 1518
		local listResult = ____exports.listFiles({ -- 1520
			workDir = req.workDir, -- 1521
			path = targetRel, -- 1522
			globs = __TS__ArrayMap( -- 1523
				codeExtensions, -- 1523
				function(____, e) return "**/*" .. e end -- 1523
			), -- 1523
			maxEntries = 10000 -- 1524
		}) -- 1524
		local relFiles = listResult.success and listResult.files or ({}) -- 1527
		local tsFileData = {} -- 1528
		local buildQueue = {} -- 1529
		for ____, rel in ipairs(relFiles) do -- 1530
			do -- 1530
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1531
				local kind = getSupportedBuildKind(file) -- 1532
				if not kind then -- 1532
					goto __continue299 -- 1533
				end -- 1533
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1534
				if kind ~= "ts" then -- 1534
					goto __continue299 -- 1536
				end -- 1536
				local content = Content:load(file) -- 1538
				if content == nil then -- 1538
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1540
					goto __continue299 -- 1541
				end -- 1541
				tsFileData[file] = content -- 1543
				if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1543
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1545
					goto __continue299 -- 1546
				end -- 1546
			end -- 1546
			::__continue299:: -- 1546
		end -- 1546
		do -- 1546
			local i = 0 -- 1549
			while i < #buildQueue do -- 1549
				do -- 1549
					local ____buildQueue_index_20 = buildQueue[i + 1] -- 1550
					local file = ____buildQueue_index_20.file -- 1550
					local kind = ____buildQueue_index_20.kind -- 1550
					if kind == "ts" then -- 1550
						local content = tsFileData[file] -- 1552
						if content == nil or isDtsFile(file) then -- 1552
							goto __continue306 -- 1554
						end -- 1554
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1556
						goto __continue306 -- 1557
					end -- 1557
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1559
				end -- 1559
				::__continue306:: -- 1559
				i = i + 1 -- 1549
			end -- 1549
		end -- 1549
		if #messages == 0 then -- 1549
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 1562
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 1562
		end -- 1562
		Log( -- 1565
			"Info", -- 1565
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1565
		) -- 1565
		return ____awaiter_resolve( -- 1565
			nil, -- 1565
			finalizeBuildResult(req.workDir, messages) -- 1566
		) -- 1566
	end) -- 1566
end -- 1488
return ____exports -- 1488