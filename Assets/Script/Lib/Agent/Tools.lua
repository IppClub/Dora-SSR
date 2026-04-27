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
function ensureSafeSearchGlobs(globs) -- 993
	local result = {} -- 994
	do -- 994
		local i = 0 -- 995
		while i < #globs do -- 995
			result[#result + 1] = globs[i + 1] -- 996
			i = i + 1 -- 995
		end -- 995
	end -- 995
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 998
	do -- 998
		local i = 0 -- 999
		while i < #requiredExcludes do -- 999
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 999
				result[#result + 1] = requiredExcludes[i + 1] -- 1001
			end -- 1001
			i = i + 1 -- 999
		end -- 999
	end -- 999
	return result -- 1004
end -- 1004
local TABLE_TASK = "AgentTask" -- 220
local TABLE_CP = "AgentCheckpoint" -- 221
local TABLE_ENTRY = "AgentCheckpointEntry" -- 222
local ENGINE_LOG_SNAPSHOT_DIR = ".agent" -- 223
local ENGINE_LOG_SNAPSHOT_FILE = "engine_logs_snapshot.txt" -- 224
local function now() -- 226
	return os.time() -- 226
end -- 226
local function toBool(v) -- 228
	return v ~= 0 and v ~= false and v ~= nil -- 229
end -- 228
local function toStr(v) -- 232
	if v == false or v == nil then -- 232
		return "" -- 233
	end -- 233
	return tostring(v) -- 234
end -- 232
local function isValidWorkspacePath(path) -- 237
	if not path or #path == 0 then -- 237
		return false -- 238
	end -- 238
	if Content:isAbsolutePath(path) then -- 238
		return false -- 239
	end -- 239
	if __TS__StringIncludes(path, "..") then -- 239
		return false -- 240
	end -- 240
	return true -- 241
end -- 237
local function isValidWorkDir(workDir) -- 244
	if not workDir or #workDir == 0 then -- 244
		return false -- 245
	end -- 245
	if not Content:isAbsolutePath(workDir) then -- 245
		return false -- 246
	end -- 246
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 246
		return false -- 247
	end -- 247
	return true -- 248
end -- 244
local function isValidSearchPath(path) -- 251
	if path == "" then -- 251
		return true -- 252
	end -- 252
	if Content:isAbsolutePath(path) then -- 252
		return false -- 253
	end -- 253
	if not path or #path == 0 then -- 253
		return false -- 254
	end -- 254
	if __TS__StringIncludes(path, "..") then -- 254
		return false -- 255
	end -- 255
	return true -- 256
end -- 251
local function resolveWorkspaceFilePath(workDir, path) -- 259
	if not isValidWorkDir(workDir) then -- 259
		return nil -- 260
	end -- 260
	if not isValidWorkspacePath(path) then -- 260
		return nil -- 261
	end -- 261
	return Path(workDir, path) -- 262
end -- 259
local function resolveWorkspaceSearchPath(workDir, path) -- 265
	if not isValidWorkDir(workDir) then -- 265
		return nil -- 266
	end -- 266
	if not isValidSearchPath(path) then -- 266
		return nil -- 267
	end -- 267
	return path == "" and workDir or Path(workDir, path) -- 268
end -- 265
local function toWorkspaceRelativePath(workDir, path) -- 271
	if not path or #path == 0 then -- 271
		return path -- 272
	end -- 272
	if not Content:isAbsolutePath(path) then -- 272
		return path -- 273
	end -- 273
	return Path:getRelative(path, workDir) -- 274
end -- 271
local function toWorkspaceRelativeFileList(workDir, files) -- 277
	return __TS__ArrayMap( -- 278
		files, -- 278
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 278
	) -- 278
end -- 277
local function toWorkspaceRelativeSearchResults(workDir, results) -- 281
	local mapped = {} -- 282
	do -- 282
		local i = 0 -- 283
		while i < #results do -- 283
			local row = results[i + 1] -- 284
			local clone = __TS__ObjectAssign({}, row) -- 285
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 286
			mapped[#mapped + 1] = clone -- 287
			i = i + 1 -- 283
		end -- 283
	end -- 283
	return mapped -- 289
end -- 281
local function getDoraAPIDocRoot(docLanguage) -- 292
	local zhDir = Path( -- 293
		Content.assetPath, -- 293
		"Script", -- 293
		"Lib", -- 293
		"Dora", -- 293
		"zh-Hans" -- 293
	) -- 293
	local enDir = Path( -- 294
		Content.assetPath, -- 294
		"Script", -- 294
		"Lib", -- 294
		"Dora", -- 294
		"en" -- 294
	) -- 294
	return docLanguage == "zh" and zhDir or enDir -- 295
end -- 292
local function getDoraTutorialDocRoot(docLanguage) -- 298
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 299
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 300
	return docLanguage == "zh" and zhDir or enDir -- 301
end -- 298
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 304
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 304
		return {"ts"} -- 306
	end -- 306
	return {"tl"} -- 308
end -- 304
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 311
	repeat -- 311
		local ____switch38 = programmingLanguage -- 311
		local ____cond38 = ____switch38 == "teal" -- 311
		if ____cond38 then -- 311
			return "tl" -- 313
		end -- 313
		____cond38 = ____cond38 or ____switch38 == "tl" -- 313
		if ____cond38 then -- 313
			return "tl" -- 314
		end -- 314
		do -- 314
			return programmingLanguage -- 315
		end -- 315
	until true -- 315
end -- 311
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 319
	if docSource == "tutorial" then -- 319
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 325
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 326
		return { -- 327
			root = Path(tutorialRoot, langDir), -- 328
			exts = {"md"}, -- 329
			globs = {"**/*.md"} -- 330
		} -- 330
	end -- 330
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 333
	return { -- 334
		root = getDoraAPIDocRoot(docLanguage), -- 335
		exts = exts, -- 336
		globs = __TS__ArrayMap( -- 337
			exts, -- 337
			function(____, ext) return "**/*." .. ext end -- 337
		) -- 337
	} -- 337
end -- 319
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 341
	if docSource == "tutorial" then -- 341
		return getDoraTutorialDocRoot(docLanguage) -- 343
	end -- 343
	return getDoraAPIDocRoot(docLanguage) -- 345
end -- 341
local function toDocRelativePath(baseRoot, path) -- 348
	if not path or #path == 0 then -- 348
		return path -- 349
	end -- 349
	if not Content:isAbsolutePath(path) then -- 349
		return path -- 350
	end -- 350
	return Path:getRelative(path, baseRoot) -- 351
end -- 348
local function resolveAgentTutorialDocFilePath(path, docLanguage) -- 354
	if not docLanguage then -- 354
		return nil -- 355
	end -- 355
	if not isValidWorkspacePath(path) then -- 355
		return nil -- 356
	end -- 356
	local candidate = Path( -- 357
		getDoraTutorialDocRoot(docLanguage), -- 357
		path -- 357
	) -- 357
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 357
		return candidate -- 359
	end -- 359
	return nil -- 361
end -- 354
local function ensureDirPath(dir) -- 364
	if not dir or dir == "." or dir == "" then -- 364
		return true -- 365
	end -- 365
	if Content:exist(dir) then -- 365
		return Content:isdir(dir) -- 366
	end -- 366
	local parent = Path:getPath(dir) -- 367
	if parent and parent ~= dir and parent ~= "." and parent ~= "" then -- 367
		if not ensureDirPath(parent) then -- 367
			return false -- 369
		end -- 369
	end -- 369
	return Content:mkdir(dir) -- 371
end -- 364
local function ensureDirForFile(path) -- 374
	local dir = Path:getPath(path) -- 375
	return ensureDirPath(dir) -- 376
end -- 374
local function getFileState(path) -- 379
	local exists = Content:exist(path) -- 380
	if not exists then -- 380
		return {exists = false, content = "", bytes = 0} -- 382
	end -- 382
	local content = Content:load(path) -- 388
	return {exists = true, content = content, bytes = #content} -- 389
end -- 379
local function queryOne(sql, args) -- 396
	local ____args_0 -- 397
	if args then -- 397
		____args_0 = DB:query(sql, args) -- 397
	else -- 397
		____args_0 = DB:query(sql) -- 397
	end -- 397
	local rows = ____args_0 -- 397
	if not rows or #rows == 0 then -- 397
		return nil -- 398
	end -- 398
	return rows[1] -- 399
end -- 396
do -- 396
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 404
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 412
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 423
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 424
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 437
end -- 437
local function isDtsFile(path) -- 440
	return Path:getExt(Path:getName(path)) == "d" -- 441
end -- 440
local function getSupportedBuildKind(path) -- 446
	repeat -- 446
		local ____switch64 = Path:getExt(path) -- 446
		local ____cond64 = ____switch64 == "ts" or ____switch64 == "tsx" -- 446
		if ____cond64 then -- 446
			return "ts" -- 448
		end -- 448
		____cond64 = ____cond64 or ____switch64 == "xml" -- 448
		if ____cond64 then -- 448
			return "xml" -- 449
		end -- 449
		____cond64 = ____cond64 or ____switch64 == "tl" -- 449
		if ____cond64 then -- 449
			return "teal" -- 450
		end -- 450
		____cond64 = ____cond64 or ____switch64 == "lua" -- 450
		if ____cond64 then -- 450
			return "lua" -- 451
		end -- 451
		____cond64 = ____cond64 or ____switch64 == "yue" -- 451
		if ____cond64 then -- 451
			return "yue" -- 452
		end -- 452
		____cond64 = ____cond64 or ____switch64 == "yarn" -- 452
		if ____cond64 then -- 452
			return "yarn" -- 453
		end -- 453
		do -- 453
			return nil -- 454
		end -- 454
	until true -- 454
end -- 446
local function getTaskHeadSeq(taskId) -- 458
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 459
	if not row then -- 459
		return nil -- 460
	end -- 460
	return row[1] or 0 -- 461
end -- 458
local function getTaskStatus(taskId) -- 464
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 465
	if not row then -- 465
		return nil -- 466
	end -- 466
	return toStr(row[1]) -- 467
end -- 464
local function getLastInsertRowId() -- 470
	local row = queryOne("SELECT last_insert_rowid()") -- 471
	return row and (row[1] or 0) or 0 -- 472
end -- 470
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 475
	DB:exec( -- 476
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 476
		{ -- 478
			taskId, -- 478
			seq, -- 478
			status, -- 478
			summary, -- 478
			toolName, -- 478
			now() -- 478
		} -- 478
	) -- 478
	return getLastInsertRowId() -- 480
end -- 475
local function getCheckpointEntries(checkpointId, desc) -- 483
	if desc == nil then -- 483
		desc = false -- 483
	end -- 483
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 484
	if not rows then -- 484
		return {} -- 491
	end -- 491
	local result = {} -- 492
	do -- 492
		local i = 0 -- 493
		while i < #rows do -- 493
			local row = rows[i + 1] -- 494
			result[#result + 1] = { -- 495
				id = row[1], -- 496
				ord = row[2], -- 497
				path = toStr(row[3]), -- 498
				op = toStr(row[4]), -- 499
				beforeExists = toBool(row[5]), -- 500
				beforeContent = toStr(row[6]), -- 501
				afterExists = toBool(row[7]), -- 502
				afterContent = toStr(row[8]) -- 503
			} -- 503
			i = i + 1 -- 493
		end -- 493
	end -- 493
	return result -- 506
end -- 483
local function rejectDuplicatePaths(changes) -- 509
	local seen = __TS__New(Set) -- 510
	for ____, change in ipairs(changes) do -- 511
		local key = change.path -- 512
		if seen:has(key) then -- 512
			return key -- 513
		end -- 513
		seen:add(key) -- 514
	end -- 514
	return nil -- 516
end -- 509
local function getLinkedDeletePaths(workDir, path) -- 519
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 520
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 520
		return {} -- 521
	end -- 521
	local parent = Path:getPath(fullPath) -- 522
	local baseName = string.lower(Path:getName(fullPath)) -- 523
	local ext = Path:getExt(fullPath) -- 524
	local linked = {} -- 525
	for ____, file in ipairs(Content:getFiles(parent)) do -- 526
		do -- 526
			if string.lower(Path:getName(file)) ~= baseName then -- 526
				goto __continue81 -- 527
			end -- 527
			local siblingExt = Path:getExt(file) -- 528
			if siblingExt == "tl" and ext == "vs" then -- 528
				linked[#linked + 1] = toWorkspaceRelativePath( -- 530
					workDir, -- 530
					Path(parent, file) -- 530
				) -- 530
				goto __continue81 -- 531
			end -- 531
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 531
				linked[#linked + 1] = toWorkspaceRelativePath( -- 534
					workDir, -- 534
					Path(parent, file) -- 534
				) -- 534
			end -- 534
		end -- 534
		::__continue81:: -- 534
	end -- 534
	return linked -- 537
end -- 519
local function expandLinkedDeleteChanges(workDir, changes) -- 540
	local expanded = {} -- 541
	local seen = __TS__New(Set) -- 542
	do -- 542
		local i = 0 -- 543
		while i < #changes do -- 543
			do -- 543
				local change = changes[i + 1] -- 544
				if not seen:has(change.path) then -- 544
					seen:add(change.path) -- 546
					expanded[#expanded + 1] = change -- 547
				end -- 547
				if change.op ~= "delete" then -- 547
					goto __continue88 -- 549
				end -- 549
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 550
				do -- 550
					local j = 0 -- 551
					while j < #linkedPaths do -- 551
						do -- 551
							local linkedPath = linkedPaths[j + 1] -- 552
							if seen:has(linkedPath) then -- 552
								goto __continue92 -- 553
							end -- 553
							seen:add(linkedPath) -- 554
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 555
						end -- 555
						::__continue92:: -- 555
						j = j + 1 -- 551
					end -- 551
				end -- 551
			end -- 551
			::__continue88:: -- 551
			i = i + 1 -- 543
		end -- 543
	end -- 543
	return expanded -- 558
end -- 540
local function applySingleFile(path, exists, content) -- 561
	if exists then -- 561
		if not ensureDirForFile(path) then -- 561
			return false -- 563
		end -- 563
		return Content:save(path, content) -- 564
	end -- 564
	if Content:exist(path) then -- 564
		return Content:remove(path) -- 567
	end -- 567
	return true -- 569
end -- 561
local function encodeJSON(obj) -- 572
	local text = safeJsonEncode(obj) -- 573
	return text -- 574
end -- 572
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 577
	if HttpServer.wsConnectionCount == 0 then -- 577
		return true -- 579
	end -- 579
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 581
	if not payload then -- 581
		return false -- 583
	end -- 583
	emit("AppWS", "Send", payload) -- 585
	return true -- 586
end -- 577
local function runSingleNonTsBuild(file) -- 589
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 589
		return ____awaiter_resolve( -- 589
			nil, -- 589
			__TS__New( -- 590
				__TS__Promise, -- 590
				function(____, resolve) -- 590
					local ____require_result_1 = require("Script.Dev.WebServer") -- 591
					local buildAsync = ____require_result_1.buildAsync -- 591
					Director.systemScheduler:schedule(once(function() -- 592
						local result = buildAsync(file) -- 593
						resolve(nil, result) -- 594
					end)) -- 592
				end -- 590
			) -- 590
		) -- 590
	end) -- 590
end -- 589
function ____exports.runSingleTsTranspile(file, content) -- 599
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 599
		local done = false -- 600
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 601
		if HttpServer.wsConnectionCount == 0 then -- 601
			return ____awaiter_resolve(nil, result) -- 601
		end -- 601
		local listener = Node() -- 609
		listener:gslot( -- 610
			"AppWS", -- 610
			function(event) -- 610
				if event.type ~= "Receive" then -- 610
					return -- 611
				end -- 611
				local res = safeJsonDecode(event.msg) -- 612
				if not res or __TS__ArrayIsArray(res) then -- 612
					return -- 613
				end -- 613
				local payload = res -- 614
				if payload.name ~= "TranspileTS" then -- 614
					return -- 615
				end -- 615
				if tostring(payload.file) ~= file then -- 615
					return -- 616
				end -- 616
				if payload.success then -- 616
					local luaFile = Path:replaceExt(file, "lua") -- 618
					if Content:save( -- 618
						luaFile, -- 619
						tostring(payload.luaCode) -- 619
					) then -- 619
						result = {success = true, file = file} -- 620
					else -- 620
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 622
					end -- 622
				else -- 622
					result = { -- 625
						success = false, -- 625
						file = file, -- 625
						message = tostring(payload.message) -- 625
					} -- 625
				end -- 625
				done = true -- 627
			end -- 610
		) -- 610
		local payload = encodeJSON({name = "TranspileTS", file = file, content = content}) -- 629
		if not payload then -- 629
			listener:removeFromParent() -- 635
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 635
		end -- 635
		__TS__Await(__TS__New( -- 638
			__TS__Promise, -- 638
			function(____, resolve) -- 638
				Director.systemScheduler:schedule(once(function() -- 639
					emit("AppWS", "Send", payload) -- 640
					wait(function() return done end) -- 641
					if not done then -- 641
						listener:removeFromParent() -- 643
					end -- 643
					resolve(nil) -- 645
				end)) -- 639
			end -- 638
		)) -- 638
		return ____awaiter_resolve(nil, result) -- 638
	end) -- 638
end -- 599
function ____exports.createTask(prompt) -- 651
	if prompt == nil then -- 651
		prompt = "" -- 651
	end -- 651
	local t = now() -- 652
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 653
	if affected <= 0 then -- 653
		return {success = false, message = "failed to create task"} -- 658
	end -- 658
	return { -- 660
		success = true, -- 660
		taskId = getLastInsertRowId() -- 660
	} -- 660
end -- 651
function ____exports.setTaskStatus(taskId, status) -- 663
	DB:exec( -- 664
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 664
		{ -- 664
			status, -- 664
			now(), -- 664
			taskId -- 664
		} -- 664
	) -- 664
	Log( -- 665
		"Info", -- 665
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 665
	) -- 665
end -- 663
function ____exports.listCheckpoints(taskId) -- 668
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 669
	if not rows then -- 669
		return {} -- 676
	end -- 676
	local items = {} -- 677
	do -- 677
		local i = 0 -- 678
		while i < #rows do -- 678
			local row = rows[i + 1] -- 679
			items[#items + 1] = { -- 680
				id = row[1], -- 681
				taskId = row[2], -- 682
				seq = row[3], -- 683
				status = toStr(row[4]), -- 684
				summary = toStr(row[5]), -- 685
				toolName = toStr(row[6]), -- 686
				createdAt = row[7] -- 687
			} -- 687
			i = i + 1 -- 678
		end -- 678
	end -- 678
	return items -- 690
end -- 668
local function listCheckpointIdsForTask(taskId, desc) -- 693
	if desc == nil then -- 693
		desc = false -- 693
	end -- 693
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 694
	if not rows then -- 694
		return {} -- 701
	end -- 701
	local items = {} -- 702
	do -- 702
		local i = 0 -- 703
		while i < #rows do -- 703
			local row = rows[i + 1] -- 704
			items[#items + 1] = {id = row[1], seq = row[2]} -- 705
			i = i + 1 -- 703
		end -- 703
	end -- 703
	return items -- 710
end -- 693
local function deriveFileOp(beforeExists, afterExists) -- 713
	if not beforeExists and afterExists then -- 713
		return "create" -- 714
	end -- 714
	if beforeExists and not afterExists then -- 714
		return "delete" -- 715
	end -- 715
	return "write" -- 716
end -- 713
function ____exports.summarizeTaskChangeSet(taskId) -- 719
	if not getTaskStatus(taskId) then -- 719
		return {success = false, message = "task not found"} -- 721
	end -- 721
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 723
	local filesByPath = {} -- 724
	local latestCheckpointId = nil -- 730
	local latestCheckpointSeq = nil -- 731
	do -- 731
		local i = 0 -- 732
		while i < #checkpoints do -- 732
			local checkpoint = checkpoints[i + 1] -- 733
			latestCheckpointId = checkpoint.id -- 734
			latestCheckpointSeq = checkpoint.seq -- 735
			local entries = getCheckpointEntries(checkpoint.id, false) -- 736
			do -- 736
				local j = 0 -- 737
				while j < #entries do -- 737
					local entry = entries[j + 1] -- 738
					local item = filesByPath[entry.path] -- 739
					if not item then -- 739
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 741
						filesByPath[entry.path] = item -- 747
					end -- 747
					item.afterExists = entry.afterExists -- 749
					local ____item_checkpointIds_2 = item.checkpointIds -- 749
					____item_checkpointIds_2[#____item_checkpointIds_2 + 1] = checkpoint.id -- 750
					j = j + 1 -- 737
				end -- 737
			end -- 737
			i = i + 1 -- 732
		end -- 732
	end -- 732
	local files = {} -- 753
	for ____, item in pairs(filesByPath) do -- 754
		files[#files + 1] = { -- 755
			path = item.path, -- 756
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 757
			checkpointCount = #item.checkpointIds, -- 758
			checkpointIds = item.checkpointIds -- 759
		} -- 759
	end -- 759
	__TS__ArraySort( -- 762
		files, -- 762
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 762
	) -- 762
	return { -- 763
		success = true, -- 764
		taskId = taskId, -- 765
		checkpointCount = #checkpoints, -- 766
		filesChanged = #files, -- 767
		files = files, -- 768
		latestCheckpointId = latestCheckpointId, -- 769
		latestCheckpointSeq = latestCheckpointSeq -- 770
	} -- 770
end -- 719
function ____exports.getTaskChangeSetDiff(taskId) -- 774
	if not getTaskStatus(taskId) then -- 774
		return {success = false, message = "task not found"} -- 776
	end -- 776
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 778
	if #checkpoints == 0 then -- 778
		return {success = false, message = "change set not found or empty"} -- 780
	end -- 780
	local filesByPath = {} -- 782
	do -- 782
		local i = 0 -- 789
		while i < #checkpoints do -- 789
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 790
			do -- 790
				local j = 0 -- 791
				while j < #entries do -- 791
					local entry = entries[j + 1] -- 792
					local item = filesByPath[entry.path] -- 793
					if not item then -- 793
						item = { -- 795
							path = entry.path, -- 796
							beforeExists = entry.beforeExists, -- 797
							beforeContent = entry.beforeContent, -- 798
							afterExists = entry.afterExists, -- 799
							afterContent = entry.afterContent -- 800
						} -- 800
						filesByPath[entry.path] = item -- 802
					end -- 802
					item.afterExists = entry.afterExists -- 804
					item.afterContent = entry.afterContent -- 805
					j = j + 1 -- 791
				end -- 791
			end -- 791
			i = i + 1 -- 789
		end -- 789
	end -- 789
	local files = {} -- 808
	for ____, item in pairs(filesByPath) do -- 809
		files[#files + 1] = { -- 810
			path = item.path, -- 811
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 812
			beforeExists = item.beforeExists, -- 813
			afterExists = item.afterExists, -- 814
			beforeContent = item.beforeContent, -- 815
			afterContent = item.afterContent -- 816
		} -- 816
	end -- 816
	__TS__ArraySort( -- 819
		files, -- 819
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 819
	) -- 819
	return {success = true, files = files} -- 820
end -- 774
local function readWorkspaceFile(workDir, path, docLanguage) -- 823
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 824
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 824
		return { -- 826
			success = true, -- 826
			content = Content:load(fullPath) -- 826
		} -- 826
	end -- 826
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 828
	if docPath then -- 828
		return { -- 830
			success = true, -- 830
			content = Content:load(docPath) -- 830
		} -- 830
	end -- 830
	if not fullPath then -- 830
		return {success = false, message = "invalid path or workDir"} -- 832
	end -- 832
	return {success = false, message = "file not found"} -- 833
end -- 823
function ____exports.readFileRaw(workDir, path, docLanguage) -- 836
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 837
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 837
		return { -- 839
			success = true, -- 839
			content = Content:load(path) -- 839
		} -- 839
	end -- 839
	return result -- 841
end -- 836
local function getEngineLogText() -- 844
	local folder = Path(Content.writablePath, ENGINE_LOG_SNAPSHOT_DIR) -- 845
	if not Content:exist(folder) then -- 845
		Content:mkdir(folder) -- 847
	end -- 847
	local logPath = Path(folder, ENGINE_LOG_SNAPSHOT_FILE) -- 849
	if not App:saveLog(logPath) then -- 849
		return nil -- 851
	end -- 851
	return Content:load(logPath) -- 853
end -- 844
function ____exports.getLogs(req) -- 856
	local text = getEngineLogText() -- 857
	if text == nil then -- 857
		return {success = false, message = "failed to read engine logs"} -- 859
	end -- 859
	local tailLines = math.max( -- 861
		1, -- 861
		math.floor(req and req.tailLines or 200) -- 861
	) -- 861
	local allLines = __TS__StringSplit(text, "\n") -- 862
	local logs = __TS__ArraySlice( -- 863
		allLines, -- 863
		math.max(0, #allLines - tailLines) -- 863
	) -- 863
	return req and req.joinText and ({ -- 864
		success = true, -- 864
		logs = logs, -- 864
		text = table.concat(logs, "\n") -- 864
	}) or ({success = true, logs = logs}) -- 864
end -- 856
function ____exports.listFiles(req) -- 867
	local root = req.path or "" -- 873
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 874
	if not searchRoot then -- 874
		return {success = false, message = "invalid path or workDir"} -- 876
	end -- 876
	do -- 876
		local function ____catch(e) -- 876
			return true, { -- 894
				success = false, -- 894
				message = tostring(e) -- 894
			} -- 894
		end -- 894
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 894
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 879
			local globs = ensureSafeSearchGlobs(userGlobs) -- 880
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 881
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 882
			local totalEntries = #files -- 883
			local maxEntries = math.max( -- 884
				1, -- 884
				math.floor(req.maxEntries or 200) -- 884
			) -- 884
			local truncated = totalEntries > maxEntries -- 885
			return true, { -- 886
				success = true, -- 887
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 888
				totalEntries = totalEntries, -- 889
				truncated = truncated, -- 890
				maxEntries = maxEntries -- 891
			} -- 891
		end) -- 891
		if not ____try then -- 891
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 891
		end -- 891
		if ____hasReturned then -- 891
			return ____returnValue -- 878
		end -- 878
	end -- 878
end -- 867
local function formatReadSlice(content, startLine, endLine) -- 898
	local lines = __TS__StringSplit(content, "\n") -- 903
	local totalLines = #lines -- 904
	if totalLines == 0 then -- 904
		return { -- 906
			success = true, -- 907
			content = "", -- 908
			totalLines = 0, -- 909
			startLine = 1, -- 910
			endLine = 0, -- 911
			truncated = false -- 912
		} -- 912
	end -- 912
	local rawStart = math.floor(startLine) -- 915
	local rawEnd = math.floor(endLine) -- 916
	if rawStart == 0 then -- 916
		return {success = false, message = "startLine cannot be 0"} -- 918
	end -- 918
	if rawEnd == 0 then -- 918
		return {success = false, message = "endLine cannot be 0"} -- 921
	end -- 921
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 923
	if start > totalLines then -- 923
		return { -- 927
			success = false, -- 927
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 927
		} -- 927
	end -- 927
	local ____end = math.min( -- 929
		totalLines, -- 930
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 931
	) -- 931
	if ____end < start then -- 931
		return { -- 936
			success = false, -- 937
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 938
		} -- 938
	end -- 938
	local slice = {} -- 941
	do -- 941
		local i = start -- 942
		while i <= ____end do -- 942
			slice[#slice + 1] = lines[i] -- 943
			i = i + 1 -- 942
		end -- 942
	end -- 942
	local truncated = start > 1 or ____end < totalLines -- 945
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 946
	local body = table.concat(slice, "\n") -- 951
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 952
	return { -- 953
		success = true, -- 954
		content = output, -- 955
		totalLines = totalLines, -- 956
		startLine = start, -- 957
		endLine = ____end, -- 958
		truncated = truncated -- 959
	} -- 959
end -- 898
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 963
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 970
	if not fallback.success or fallback.content == nil then -- 970
		return fallback -- 971
	end -- 971
	local resolvedStartLine = startLine or 1 -- 972
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 973
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 974
end -- 963
local codeExtensions = { -- 981
	".lua", -- 981
	".tl", -- 981
	".yue", -- 981
	".ts", -- 981
	".tsx", -- 981
	".xml", -- 981
	".md", -- 981
	".yarn", -- 981
	".wa", -- 981
	".mod" -- 981
} -- 981
extensionLevels = { -- 982
	vs = 2, -- 983
	bl = 2, -- 984
	ts = 1, -- 985
	tsx = 1, -- 986
	tl = 1, -- 987
	yue = 1, -- 988
	xml = 1, -- 989
	lua = 0 -- 990
} -- 990
local function splitSearchPatterns(pattern) -- 1007
	local trimmed = __TS__StringTrim(pattern or "") -- 1008
	if trimmed == "" then -- 1008
		return {} -- 1009
	end -- 1009
	local out = {} -- 1010
	local seen = __TS__New(Set) -- 1011
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1012
		local p = __TS__StringTrim(tostring(p0)) -- 1013
		if p ~= "" and not seen:has(p) then -- 1013
			seen:add(p) -- 1015
			out[#out + 1] = p -- 1016
		end -- 1016
	end -- 1016
	return out -- 1019
end -- 1007
local function mergeSearchFileResultsUnique(resultsList) -- 1022
	local merged = {} -- 1023
	local seen = __TS__New(Set) -- 1024
	do -- 1024
		local i = 0 -- 1025
		while i < #resultsList do -- 1025
			local list = resultsList[i + 1] -- 1026
			do -- 1026
				local j = 0 -- 1027
				while j < #list do -- 1027
					do -- 1027
						local row = list[j + 1] -- 1028
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1029
						if seen:has(key) then -- 1029
							goto __continue193 -- 1030
						end -- 1030
						seen:add(key) -- 1031
						merged[#merged + 1] = list[j + 1] -- 1032
					end -- 1032
					::__continue193:: -- 1032
					j = j + 1 -- 1027
				end -- 1027
			end -- 1027
			i = i + 1 -- 1025
		end -- 1025
	end -- 1025
	return merged -- 1035
end -- 1022
local function buildGroupedSearchResults(results) -- 1038
	local order = {} -- 1043
	local grouped = __TS__New(Map) -- 1044
	do -- 1044
		local i = 0 -- 1049
		while i < #results do -- 1049
			local row = results[i + 1] -- 1050
			local file = row.file -- 1051
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1052
			local bucket = grouped:get(key) -- 1053
			if not bucket then -- 1053
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1055
				grouped:set(key, bucket) -- 1056
				order[#order + 1] = key -- 1057
			end -- 1057
			bucket.totalMatches = bucket.totalMatches + 1 -- 1059
			local ____bucket_matches_7 = bucket.matches -- 1059
			____bucket_matches_7[#____bucket_matches_7 + 1] = results[i + 1] -- 1060
			i = i + 1 -- 1049
		end -- 1049
	end -- 1049
	local out = {} -- 1062
	do -- 1062
		local i = 0 -- 1067
		while i < #order do -- 1067
			local bucket = grouped:get(order[i + 1]) -- 1068
			if bucket then -- 1068
				out[#out + 1] = bucket -- 1069
			end -- 1069
			i = i + 1 -- 1067
		end -- 1067
	end -- 1067
	return out -- 1071
end -- 1038
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1074
	local merged = {} -- 1075
	local seen = __TS__New(Set) -- 1076
	local index = 0 -- 1077
	local advanced = true -- 1078
	while advanced do -- 1078
		advanced = false -- 1080
		do -- 1080
			local i = 0 -- 1081
			while i < #resultsList do -- 1081
				do -- 1081
					local list = resultsList[i + 1] -- 1082
					if index >= #list then -- 1082
						goto __continue205 -- 1083
					end -- 1083
					advanced = true -- 1084
					local row = list[index + 1] -- 1085
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1086
					if seen:has(key) then -- 1086
						goto __continue205 -- 1087
					end -- 1087
					seen:add(key) -- 1088
					merged[#merged + 1] = row -- 1089
				end -- 1089
				::__continue205:: -- 1089
				i = i + 1 -- 1081
			end -- 1081
		end -- 1081
		index = index + 1 -- 1091
	end -- 1091
	return merged -- 1093
end -- 1074
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1096
	if docSource ~= "api" then -- 1096
		return 100 -- 1097
	end -- 1097
	if programmingLanguage ~= "tsx" then -- 1097
		return 100 -- 1098
	end -- 1098
	repeat -- 1098
		local ____switch211 = string.lower(Path:getFilename(file)) -- 1098
		local ____cond211 = ____switch211 == "jsx.d.ts" -- 1098
		if ____cond211 then -- 1098
			return 0 -- 1100
		end -- 1100
		____cond211 = ____cond211 or ____switch211 == "dorax.d.ts" -- 1100
		if ____cond211 then -- 1100
			return 1 -- 1101
		end -- 1101
		____cond211 = ____cond211 or ____switch211 == "dora.d.ts" -- 1101
		if ____cond211 then -- 1101
			return 2 -- 1102
		end -- 1102
		do -- 1102
			return 100 -- 1103
		end -- 1103
	until true -- 1103
end -- 1096
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1107
	local sorted = __TS__ArraySlice(hits) -- 1112
	__TS__ArraySort( -- 1113
		sorted, -- 1113
		function(____, a, b) -- 1113
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1114
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1115
			if pa ~= pb then -- 1115
				return pa - pb -- 1116
			end -- 1116
			local fa = string.lower(a.file) -- 1117
			local fb = string.lower(b.file) -- 1118
			if fa ~= fb then -- 1118
				return fa < fb and -1 or 1 -- 1119
			end -- 1119
			return (a.line or 0) - (b.line or 0) -- 1120
		end -- 1113
	) -- 1113
	return sorted -- 1122
end -- 1107
function ____exports.searchFiles(req) -- 1125
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1125
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1138
		if not resolvedPath then -- 1138
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1138
		end -- 1138
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1142
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1143
		if not searchRoot then -- 1143
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1143
		end -- 1143
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1143
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1143
		end -- 1143
		local patterns = splitSearchPatterns(req.pattern) -- 1150
		if #patterns == 0 then -- 1150
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1150
		end -- 1150
		return ____awaiter_resolve( -- 1150
			nil, -- 1150
			__TS__New( -- 1154
				__TS__Promise, -- 1154
				function(____, resolve) -- 1154
					Director.systemScheduler:schedule(once(function() -- 1155
						do -- 1155
							local function ____catch(e) -- 1155
								resolve( -- 1197
									nil, -- 1197
									{ -- 1197
										success = false, -- 1197
										message = tostring(e) -- 1197
									} -- 1197
								) -- 1197
							end -- 1197
							local ____try, ____hasReturned = pcall(function() -- 1197
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1157
								local allResults = {} -- 1160
								do -- 1160
									local i = 0 -- 1161
									while i < #patterns do -- 1161
										local ____Content_12 = Content -- 1162
										local ____Content_searchFilesAsync_13 = Content.searchFilesAsync -- 1162
										local ____patterns_index_11 = patterns[i + 1] -- 1167
										local ____req_useRegex_8 = req.useRegex -- 1168
										if ____req_useRegex_8 == nil then -- 1168
											____req_useRegex_8 = false -- 1168
										end -- 1168
										local ____req_caseSensitive_9 = req.caseSensitive -- 1169
										if ____req_caseSensitive_9 == nil then -- 1169
											____req_caseSensitive_9 = false -- 1169
										end -- 1169
										local ____req_includeContent_10 = req.includeContent -- 1170
										if ____req_includeContent_10 == nil then -- 1170
											____req_includeContent_10 = true -- 1170
										end -- 1170
										allResults[#allResults + 1] = ____Content_searchFilesAsync_13( -- 1162
											____Content_12, -- 1162
											searchRoot, -- 1163
											codeExtensions, -- 1164
											extensionLevels, -- 1165
											searchGlobs, -- 1166
											____patterns_index_11, -- 1167
											____req_useRegex_8, -- 1168
											____req_caseSensitive_9, -- 1169
											____req_includeContent_10, -- 1170
											req.contentWindow or 120 -- 1171
										) -- 1171
										i = i + 1 -- 1161
									end -- 1161
								end -- 1161
								local results = mergeSearchFileResultsUnique(allResults) -- 1174
								local totalResults = #results -- 1175
								local limit = math.max( -- 1176
									1, -- 1176
									math.floor(req.limit or 20) -- 1176
								) -- 1176
								local offset = math.max( -- 1177
									0, -- 1177
									math.floor(req.offset or 0) -- 1177
								) -- 1177
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1178
								local nextOffset = offset + #paged -- 1179
								local hasMore = nextOffset < totalResults -- 1180
								local truncated = offset > 0 or hasMore -- 1181
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1182
								local groupByFile = req.groupByFile == true -- 1183
								resolve( -- 1184
									nil, -- 1184
									{ -- 1184
										success = true, -- 1185
										results = relativeResults, -- 1186
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1187
										totalResults = totalResults, -- 1188
										truncated = truncated, -- 1189
										limit = limit, -- 1190
										offset = offset, -- 1191
										nextOffset = nextOffset, -- 1192
										hasMore = hasMore, -- 1193
										groupByFile = groupByFile -- 1194
									} -- 1194
								) -- 1194
							end) -- 1194
							if not ____try then -- 1194
								____catch(____hasReturned) -- 1194
							end -- 1194
						end -- 1194
					end)) -- 1155
				end -- 1154
			) -- 1154
		) -- 1154
	end) -- 1154
end -- 1125
function ____exports.searchDoraAPI(req) -- 1203
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1203
		local pattern = __TS__StringTrim(req.pattern or "") -- 1214
		if pattern == "" then -- 1214
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1214
		end -- 1214
		local patterns = splitSearchPatterns(pattern) -- 1216
		if #patterns == 0 then -- 1216
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1216
		end -- 1216
		local docSource = req.docSource or "api" -- 1218
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1219
		local docRoot = target.root -- 1220
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1221
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1221
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1221
		end -- 1221
		local exts = target.exts -- 1225
		local dotExts = __TS__ArrayMap( -- 1226
			exts, -- 1226
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1226
		) -- 1226
		local globs = target.globs -- 1227
		local limit = math.max( -- 1228
			1, -- 1228
			math.floor(req.limit or 10) -- 1228
		) -- 1228
		return ____awaiter_resolve( -- 1228
			nil, -- 1228
			__TS__New( -- 1230
				__TS__Promise, -- 1230
				function(____, resolve) -- 1230
					Director.systemScheduler:schedule(once(function() -- 1231
						do -- 1231
							local function ____catch(e) -- 1231
								resolve( -- 1272
									nil, -- 1272
									{ -- 1272
										success = false, -- 1272
										message = tostring(e) -- 1272
									} -- 1272
								) -- 1272
							end -- 1272
							local ____try, ____hasReturned = pcall(function() -- 1272
								local allHits = {} -- 1233
								do -- 1233
									local p = 0 -- 1234
									while p < #patterns do -- 1234
										local ____Content_18 = Content -- 1235
										local ____Content_searchFilesAsync_19 = Content.searchFilesAsync -- 1235
										local ____array_17 = __TS__SparseArrayNew( -- 1235
											docRoot, -- 1236
											dotExts, -- 1237
											{}, -- 1238
											ensureSafeSearchGlobs(globs), -- 1239
											patterns[p + 1] -- 1240
										) -- 1240
										local ____req_useRegex_14 = req.useRegex -- 1241
										if ____req_useRegex_14 == nil then -- 1241
											____req_useRegex_14 = false -- 1241
										end -- 1241
										__TS__SparseArrayPush(____array_17, ____req_useRegex_14) -- 1241
										local ____req_caseSensitive_15 = req.caseSensitive -- 1242
										if ____req_caseSensitive_15 == nil then -- 1242
											____req_caseSensitive_15 = false -- 1242
										end -- 1242
										__TS__SparseArrayPush(____array_17, ____req_caseSensitive_15) -- 1242
										local ____req_includeContent_16 = req.includeContent -- 1243
										if ____req_includeContent_16 == nil then -- 1243
											____req_includeContent_16 = true -- 1243
										end -- 1243
										__TS__SparseArrayPush(____array_17, ____req_includeContent_16, req.contentWindow or 80) -- 1243
										local raw = ____Content_searchFilesAsync_19( -- 1235
											____Content_18, -- 1235
											__TS__SparseArraySpread(____array_17) -- 1235
										) -- 1235
										local hits = {} -- 1246
										do -- 1246
											local i = 0 -- 1247
											while i < #raw do -- 1247
												do -- 1247
													local row = raw[i + 1] -- 1248
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1249
													if file == "" then -- 1249
														goto __continue238 -- 1250
													end -- 1250
													hits[#hits + 1] = { -- 1251
														file = file, -- 1252
														line = type(row.line) == "number" and row.line or nil, -- 1253
														content = type(row.content) == "string" and row.content or nil -- 1254
													} -- 1254
												end -- 1254
												::__continue238:: -- 1254
												i = i + 1 -- 1247
											end -- 1247
										end -- 1247
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1257
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1257
											0, -- 1257
											limit -- 1257
										) -- 1257
										p = p + 1 -- 1234
									end -- 1234
								end -- 1234
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1259
								resolve(nil, { -- 1260
									success = true, -- 1261
									docSource = docSource, -- 1262
									docLanguage = req.docLanguage, -- 1263
									programmingLanguage = req.programmingLanguage, -- 1264
									exts = exts, -- 1265
									results = hits, -- 1266
									totalResults = #hits, -- 1267
									truncated = false, -- 1268
									limit = limit -- 1269
								}) -- 1269
							end) -- 1269
							if not ____try then -- 1269
								____catch(____hasReturned) -- 1269
							end -- 1269
						end -- 1269
					end)) -- 1231
				end -- 1230
			) -- 1230
		) -- 1230
	end) -- 1230
end -- 1203
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1278
	if options == nil then -- 1278
		options = {} -- 1278
	end -- 1278
	if #changes == 0 then -- 1278
		return {success = false, message = "empty changes"} -- 1280
	end -- 1280
	if not isValidWorkDir(workDir) then -- 1280
		return {success = false, message = "invalid workDir"} -- 1283
	end -- 1283
	if not getTaskStatus(taskId) then -- 1283
		return {success = false, message = "task not found"} -- 1286
	end -- 1286
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1288
	local dup = rejectDuplicatePaths(expandedChanges) -- 1289
	if dup then -- 1289
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1291
	end -- 1291
	for ____, change in ipairs(expandedChanges) do -- 1294
		if not isValidWorkspacePath(change.path) then -- 1294
			return {success = false, message = "invalid path: " .. change.path} -- 1296
		end -- 1296
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1296
			return {success = false, message = "missing content for " .. change.path} -- 1299
		end -- 1299
	end -- 1299
	local headSeq = getTaskHeadSeq(taskId) -- 1303
	if headSeq == nil then -- 1303
		return {success = false, message = "task not found"} -- 1304
	end -- 1304
	local nextSeq = headSeq + 1 -- 1305
	local checkpointId = insertCheckpoint( -- 1306
		taskId, -- 1306
		nextSeq, -- 1306
		options.summary or "", -- 1306
		options.toolName or "", -- 1306
		"PREPARED" -- 1306
	) -- 1306
	if checkpointId <= 0 then -- 1306
		return {success = false, message = "failed to create checkpoint"} -- 1308
	end -- 1308
	do -- 1308
		local i = 0 -- 1311
		while i < #expandedChanges do -- 1311
			local change = expandedChanges[i + 1] -- 1312
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1313
			if not fullPath then -- 1313
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1315
				return {success = false, message = "invalid path: " .. change.path} -- 1316
			end -- 1316
			local before = getFileState(fullPath) -- 1318
			local afterExists = change.op ~= "delete" -- 1319
			local afterContent = afterExists and (change.content or "") or "" -- 1320
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1321
				checkpointId, -- 1325
				i + 1, -- 1326
				change.path, -- 1327
				change.op, -- 1328
				before.exists and 1 or 0, -- 1329
				before.content, -- 1330
				afterExists and 1 or 0, -- 1331
				afterContent, -- 1332
				before.bytes, -- 1333
				#afterContent -- 1334
			}) -- 1334
			if inserted <= 0 then -- 1334
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1338
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1339
			end -- 1339
			i = i + 1 -- 1311
		end -- 1311
	end -- 1311
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1343
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1344
		if not fullPath then -- 1344
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1346
			return {success = false, message = "invalid path: " .. entry.path} -- 1347
		end -- 1347
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1349
		if not ok then -- 1349
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1351
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1352
		end -- 1352
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1352
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1355
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1356
		end -- 1356
	end -- 1356
	DB:exec( -- 1360
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1360
		{ -- 1362
			"APPLIED", -- 1362
			now(), -- 1362
			checkpointId -- 1362
		} -- 1362
	) -- 1362
	DB:exec( -- 1364
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1364
		{ -- 1366
			nextSeq, -- 1366
			now(), -- 1366
			taskId -- 1366
		} -- 1366
	) -- 1366
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1368
end -- 1278
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1376
	if not isValidWorkDir(workDir) then -- 1376
		return {success = false, message = "invalid workDir"} -- 1377
	end -- 1377
	if checkpointId <= 0 then -- 1377
		return {success = false, message = "invalid checkpointId"} -- 1378
	end -- 1378
	local entries = getCheckpointEntries(checkpointId, true) -- 1379
	if #entries == 0 then -- 1379
		return {success = false, message = "checkpoint not found or empty"} -- 1381
	end -- 1381
	for ____, entry in ipairs(entries) do -- 1383
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1384
		if not fullPath then -- 1384
			return {success = false, message = "invalid path: " .. entry.path} -- 1386
		end -- 1386
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1388
		if not ok then -- 1388
			Log( -- 1390
				"Error", -- 1390
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1390
			) -- 1390
			Log( -- 1391
				"Info", -- 1391
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1391
			) -- 1391
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1392
		end -- 1392
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1392
			Log( -- 1395
				"Error", -- 1395
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1395
			) -- 1395
			Log( -- 1396
				"Info", -- 1396
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1396
			) -- 1396
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1397
		end -- 1397
	end -- 1397
	DB:exec( -- 1400
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 1400
		{ -- 1400
			"REVERTED", -- 1400
			now(), -- 1400
			checkpointId -- 1400
		} -- 1400
	) -- 1400
	return {success = true, checkpointId = checkpointId} -- 1401
end -- 1376
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 1404
	if not isValidWorkDir(workDir) then -- 1404
		return {success = false, message = "invalid workDir"} -- 1405
	end -- 1405
	if not getTaskStatus(taskId) then -- 1405
		return {success = false, message = "task not found"} -- 1406
	end -- 1406
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 1407
	if #checkpoints == 0 then -- 1407
		return {success = false, message = "change set not found or empty"} -- 1409
	end -- 1409
	local lastCheckpointId = 0 -- 1411
	do -- 1411
		local i = 0 -- 1412
		while i < #checkpoints do -- 1412
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 1413
			if not result.success then -- 1413
				return {success = false, message = result.message} -- 1414
			end -- 1414
			lastCheckpointId = checkpoints[i + 1].id -- 1415
			i = i + 1 -- 1412
		end -- 1412
	end -- 1412
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 1417
end -- 1404
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1425
	return getCheckpointEntries(checkpointId, false) -- 1426
end -- 1425
function ____exports.getCheckpointDiff(checkpointId) -- 1429
	if checkpointId <= 0 then -- 1429
		return {success = false, message = "invalid checkpointId"} -- 1431
	end -- 1431
	local entries = getCheckpointEntries(checkpointId, false) -- 1433
	if #entries == 0 then -- 1433
		return {success = false, message = "checkpoint not found or empty"} -- 1435
	end -- 1435
	return { -- 1437
		success = true, -- 1438
		files = __TS__ArrayMap( -- 1439
			entries, -- 1439
			function(____, entry) return { -- 1439
				path = entry.path, -- 1440
				op = entry.op, -- 1441
				beforeExists = entry.beforeExists, -- 1442
				afterExists = entry.afterExists, -- 1443
				beforeContent = entry.beforeContent, -- 1444
				afterContent = entry.afterContent -- 1445
			} end -- 1445
		) -- 1445
	} -- 1445
end -- 1429
function ____exports.build(req) -- 1450
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1450
		local targetRel = req.path or "" -- 1451
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1452
		if not target then -- 1452
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1452
		end -- 1452
		if not Content:exist(target) then -- 1452
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1452
		end -- 1452
		local messages = {} -- 1459
		if not Content:isdir(target) then -- 1459
			local kind = getSupportedBuildKind(target) -- 1461
			if not kind then -- 1461
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1461
			end -- 1461
			if kind == "ts" then -- 1461
				local content = Content:load(target) -- 1466
				if content == nil then -- 1466
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1466
				end -- 1466
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1466
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1466
				end -- 1466
				if not isDtsFile(target) then -- 1466
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1474
				end -- 1474
			else -- 1474
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1477
			end -- 1477
			Log( -- 1479
				"Info", -- 1479
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1479
			) -- 1479
			return ____awaiter_resolve( -- 1479
				nil, -- 1479
				{ -- 1480
					success = true, -- 1481
					messages = __TS__ArrayMap( -- 1482
						messages, -- 1482
						function(____, m) return m.success and __TS__ObjectAssign( -- 1482
							{}, -- 1483
							m, -- 1483
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1483
						) or __TS__ObjectAssign( -- 1483
							{}, -- 1484
							m, -- 1484
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1484
						) end -- 1484
					) -- 1484
				} -- 1484
			) -- 1484
		end -- 1484
		local listResult = ____exports.listFiles({ -- 1487
			workDir = req.workDir, -- 1488
			path = targetRel, -- 1489
			globs = __TS__ArrayMap( -- 1490
				codeExtensions, -- 1490
				function(____, e) return "**/*" .. e end -- 1490
			), -- 1490
			maxEntries = 10000 -- 1491
		}) -- 1491
		local relFiles = listResult.success and listResult.files or ({}) -- 1494
		local tsFileData = {} -- 1495
		local buildQueue = {} -- 1496
		for ____, rel in ipairs(relFiles) do -- 1497
			do -- 1497
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1498
				local kind = getSupportedBuildKind(file) -- 1499
				if not kind then -- 1499
					goto __continue294 -- 1500
				end -- 1500
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1501
				if kind ~= "ts" then -- 1501
					goto __continue294 -- 1503
				end -- 1503
				local content = Content:load(file) -- 1505
				if content == nil then -- 1505
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1507
					goto __continue294 -- 1508
				end -- 1508
				tsFileData[file] = content -- 1510
				if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1510
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1512
					goto __continue294 -- 1513
				end -- 1513
			end -- 1513
			::__continue294:: -- 1513
		end -- 1513
		do -- 1513
			local i = 0 -- 1516
			while i < #buildQueue do -- 1516
				do -- 1516
					local ____buildQueue_index_20 = buildQueue[i + 1] -- 1517
					local file = ____buildQueue_index_20.file -- 1517
					local kind = ____buildQueue_index_20.kind -- 1517
					if kind == "ts" then -- 1517
						local content = tsFileData[file] -- 1519
						if content == nil or isDtsFile(file) then -- 1519
							goto __continue301 -- 1521
						end -- 1521
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1523
						goto __continue301 -- 1524
					end -- 1524
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1526
				end -- 1526
				::__continue301:: -- 1526
				i = i + 1 -- 1516
			end -- 1516
		end -- 1516
		if #messages == 0 then -- 1516
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 1529
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 1529
		end -- 1529
		Log( -- 1532
			"Info", -- 1532
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1532
		) -- 1532
		return ____awaiter_resolve( -- 1532
			nil, -- 1532
			{ -- 1533
				success = true, -- 1534
				messages = __TS__ArrayMap( -- 1535
					messages, -- 1535
					function(____, m) return m.success and __TS__ObjectAssign( -- 1535
						{}, -- 1536
						m, -- 1536
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1536
					) or __TS__ObjectAssign( -- 1536
						{}, -- 1537
						m, -- 1537
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1537
					) end -- 1537
				) -- 1537
			} -- 1537
		) -- 1537
	end) -- 1537
end -- 1450
return ____exports -- 1450