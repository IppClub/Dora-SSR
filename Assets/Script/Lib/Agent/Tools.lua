-- [ts]: Tools.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local Set = ____lualib.Set -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local Map = ____lualib.Map -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
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
function ensureSafeSearchGlobs(globs) -- 819
	local result = {} -- 820
	do -- 820
		local i = 0 -- 821
		while i < #globs do -- 821
			result[#result + 1] = globs[i + 1] -- 822
			i = i + 1 -- 821
		end -- 821
	end -- 821
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 824
	do -- 824
		local i = 0 -- 825
		while i < #requiredExcludes do -- 825
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 825
				result[#result + 1] = requiredExcludes[i + 1] -- 827
			end -- 827
			i = i + 1 -- 825
		end -- 825
	end -- 825
	return result -- 830
end -- 830
local TABLE_TASK = "AgentTask" -- 191
local TABLE_CP = "AgentCheckpoint" -- 192
local TABLE_ENTRY = "AgentCheckpointEntry" -- 193
local ENGINE_LOG_SNAPSHOT_DIR = ".agent" -- 194
local ENGINE_LOG_SNAPSHOT_FILE = "engine_logs_snapshot.txt" -- 195
local function now() -- 197
	return os.time() -- 197
end -- 197
local function toBool(v) -- 199
	return v ~= 0 and v ~= false and v ~= nil -- 200
end -- 199
local function toStr(v) -- 203
	if v == false or v == nil then -- 203
		return "" -- 204
	end -- 204
	return tostring(v) -- 205
end -- 203
local function isValidWorkspacePath(path) -- 208
	if not path or #path == 0 then -- 208
		return false -- 209
	end -- 209
	if Content:isAbsolutePath(path) then -- 209
		return false -- 210
	end -- 210
	if __TS__StringIncludes(path, "..") then -- 210
		return false -- 211
	end -- 211
	return true -- 212
end -- 208
local function isValidWorkDir(workDir) -- 215
	if not workDir or #workDir == 0 then -- 215
		return false -- 216
	end -- 216
	if not Content:isAbsolutePath(workDir) then -- 216
		return false -- 217
	end -- 217
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 217
		return false -- 218
	end -- 218
	return true -- 219
end -- 215
local function isValidSearchPath(path) -- 222
	if path == "" then -- 222
		return true -- 223
	end -- 223
	if not path or #path == 0 then -- 223
		return false -- 224
	end -- 224
	if __TS__StringIncludes(path, "..") then -- 224
		return false -- 225
	end -- 225
	return true -- 226
end -- 222
local function resolveWorkspaceFilePath(workDir, path) -- 229
	if not isValidWorkDir(workDir) then -- 229
		return nil -- 230
	end -- 230
	if not isValidWorkspacePath(path) then -- 230
		return nil -- 231
	end -- 231
	return Path(workDir, path) -- 232
end -- 229
local function resolveWorkspaceSearchPath(workDir, path) -- 235
	if not isValidWorkDir(workDir) then -- 235
		return nil -- 236
	end -- 236
	local root = path or "" -- 237
	if not isValidSearchPath(root) then -- 237
		return nil -- 238
	end -- 238
	return root == "" and workDir or Path(workDir, root) -- 239
end -- 235
local function toWorkspaceRelativePath(workDir, path) -- 242
	if not path or #path == 0 then -- 242
		return path -- 243
	end -- 243
	if not Content:isAbsolutePath(path) then -- 243
		return path -- 244
	end -- 244
	return Path:getRelative(path, workDir) -- 245
end -- 242
local function toWorkspaceRelativeFileList(workDir, files) -- 248
	return __TS__ArrayMap( -- 249
		files, -- 249
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 249
	) -- 249
end -- 248
local function toWorkspaceRelativeSearchResults(workDir, results) -- 252
	local mapped = {} -- 253
	do -- 253
		local i = 0 -- 254
		while i < #results do -- 254
			local row = results[i + 1] -- 255
			if type(row) == "table" then -- 255
				local clone = {} -- 257
				for k in pairs(row) do -- 258
					clone[k] = row[k] -- 259
				end -- 259
				if type(clone.file) == "string" then -- 259
					clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 262
				end -- 262
				if type(clone.path) == "string" then -- 262
					clone.path = toWorkspaceRelativePath(workDir, clone.path) -- 265
				end -- 265
				mapped[#mapped + 1] = clone -- 267
			else -- 267
				mapped[#mapped + 1] = results[i + 1] -- 269
			end -- 269
			i = i + 1 -- 254
		end -- 254
	end -- 254
	return mapped -- 272
end -- 252
local function getDoraAPIDocRoot(docLanguage) -- 275
	local zhDir = Path( -- 276
		Content.assetPath, -- 276
		"Script", -- 276
		"Lib", -- 276
		"Dora", -- 276
		"zh-Hans" -- 276
	) -- 276
	local enDir = Path( -- 277
		Content.assetPath, -- 277
		"Script", -- 277
		"Lib", -- 277
		"Dora", -- 277
		"en" -- 277
	) -- 277
	return docLanguage == "zh" and zhDir or enDir -- 278
end -- 275
local function getDoraTutorialDocRoot(docLanguage) -- 281
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 282
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 283
	return docLanguage == "zh" and zhDir or enDir -- 284
end -- 281
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 287
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 287
		return {"ts"} -- 289
	end -- 289
	return {"tl"} -- 291
end -- 287
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 294
	repeat -- 294
		local ____switch43 = programmingLanguage -- 294
		local ____cond43 = ____switch43 == "teal" -- 294
		if ____cond43 then -- 294
			return "tl" -- 296
		end -- 296
		____cond43 = ____cond43 or ____switch43 == "tl" -- 296
		if ____cond43 then -- 296
			return "tl" -- 297
		end -- 297
		do -- 297
			return programmingLanguage -- 298
		end -- 298
	until true -- 298
end -- 294
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 302
	if docSource == "tutorial" then -- 302
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 308
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 309
		return { -- 310
			root = Path(tutorialRoot, langDir), -- 311
			exts = {"md"}, -- 312
			globs = {"**/*.md"} -- 313
		} -- 313
	end -- 313
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 316
	return { -- 317
		root = getDoraAPIDocRoot(docLanguage), -- 318
		exts = exts, -- 319
		globs = __TS__ArrayMap( -- 320
			exts, -- 320
			function(____, ext) return "**/*." .. ext end -- 320
		) -- 320
	} -- 320
end -- 302
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 324
	if docSource == "tutorial" then -- 324
		return getDoraTutorialDocRoot(docLanguage) -- 326
	end -- 326
	return getDoraAPIDocRoot(docLanguage) -- 328
end -- 324
local function toDocRelativePath(baseRoot, path) -- 331
	if not path or #path == 0 then -- 331
		return path -- 332
	end -- 332
	if not Content:isAbsolutePath(path) then -- 332
		return path -- 333
	end -- 333
	return Path:getRelative(path, baseRoot) -- 334
end -- 331
local function resolveAgentTutorialDocFilePath(path, docLanguage) -- 337
	if not docLanguage then -- 337
		return nil -- 338
	end -- 338
	if not isValidWorkspacePath(path) then -- 338
		return nil -- 339
	end -- 339
	local candidate = Path( -- 340
		getDoraTutorialDocRoot(docLanguage), -- 340
		path -- 340
	) -- 340
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 340
		return candidate -- 342
	end -- 342
	return nil -- 344
end -- 337
local function ensureDirPath(dir) -- 347
	if not dir or dir == "." or dir == "" then -- 347
		return true -- 348
	end -- 348
	if Content:exist(dir) then -- 348
		return Content:isdir(dir) -- 349
	end -- 349
	local parent = Path:getPath(dir) -- 350
	if parent and parent ~= dir and parent ~= "." and parent ~= "" then -- 350
		if not ensureDirPath(parent) then -- 350
			return false -- 352
		end -- 352
	end -- 352
	return Content:mkdir(dir) -- 354
end -- 347
local function ensureDirForFile(path) -- 357
	local dir = Path:getPath(path) -- 358
	return ensureDirPath(dir) -- 359
end -- 357
local function getFileState(path) -- 362
	local exists = Content:exist(path) -- 363
	if not exists then -- 363
		return {exists = false, content = "", bytes = 0} -- 365
	end -- 365
	local content = Content:load(path) -- 371
	return {exists = true, content = content, bytes = #content} -- 372
end -- 362
local function queryOne(sql, args) -- 379
	local ____args_0 -- 380
	if args then -- 380
		____args_0 = DB:query(sql, args) -- 380
	else -- 380
		____args_0 = DB:query(sql) -- 380
	end -- 380
	local rows = ____args_0 -- 380
	if not rows or #rows == 0 then -- 380
		return nil -- 381
	end -- 381
	return rows[1] -- 382
end -- 379
do -- 379
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 387
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 395
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 406
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 407
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 420
end -- 420
local function isDtsFile(path) -- 423
	return Path:getExt(Path:getName(path)) == "d" -- 424
end -- 423
local function getSupportedBuildKind(path) -- 429
	repeat -- 429
		local ____switch69 = Path:getExt(path) -- 429
		local ____cond69 = ____switch69 == "ts" or ____switch69 == "tsx" -- 429
		if ____cond69 then -- 429
			return "ts" -- 431
		end -- 431
		____cond69 = ____cond69 or ____switch69 == "xml" -- 431
		if ____cond69 then -- 431
			return "xml" -- 432
		end -- 432
		____cond69 = ____cond69 or ____switch69 == "tl" -- 432
		if ____cond69 then -- 432
			return "teal" -- 433
		end -- 433
		____cond69 = ____cond69 or ____switch69 == "lua" -- 433
		if ____cond69 then -- 433
			return "lua" -- 434
		end -- 434
		____cond69 = ____cond69 or ____switch69 == "yue" -- 434
		if ____cond69 then -- 434
			return "yue" -- 435
		end -- 435
		____cond69 = ____cond69 or ____switch69 == "yarn" -- 435
		if ____cond69 then -- 435
			return "yarn" -- 436
		end -- 436
		do -- 436
			return nil -- 437
		end -- 437
	until true -- 437
end -- 429
local function getTaskHeadSeq(taskId) -- 441
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 442
	if not row then -- 442
		return nil -- 443
	end -- 443
	return row[1] or 0 -- 444
end -- 441
local function getTaskStatus(taskId) -- 447
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 448
	if not row then -- 448
		return nil -- 449
	end -- 449
	return toStr(row[1]) -- 450
end -- 447
local function getLastInsertRowId() -- 453
	local row = queryOne("SELECT last_insert_rowid()") -- 454
	return row and (row[1] or 0) or 0 -- 455
end -- 453
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 458
	DB:exec( -- 459
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 459
		{ -- 461
			taskId, -- 461
			seq, -- 461
			status, -- 461
			summary, -- 461
			toolName, -- 461
			now() -- 461
		} -- 461
	) -- 461
	return getLastInsertRowId() -- 463
end -- 458
local function getCheckpointEntries(checkpointId, desc) -- 466
	if desc == nil then -- 466
		desc = false -- 466
	end -- 466
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 467
	if not rows then -- 467
		return {} -- 474
	end -- 474
	local result = {} -- 475
	do -- 475
		local i = 0 -- 476
		while i < #rows do -- 476
			local row = rows[i + 1] -- 477
			result[#result + 1] = { -- 478
				id = row[1], -- 479
				ord = row[2], -- 480
				path = toStr(row[3]), -- 481
				op = toStr(row[4]), -- 482
				beforeExists = toBool(row[5]), -- 483
				beforeContent = toStr(row[6]), -- 484
				afterExists = toBool(row[7]), -- 485
				afterContent = toStr(row[8]) -- 486
			} -- 486
			i = i + 1 -- 476
		end -- 476
	end -- 476
	return result -- 489
end -- 466
local function rejectDuplicatePaths(changes) -- 492
	local seen = __TS__New(Set) -- 493
	for ____, change in ipairs(changes) do -- 494
		local key = change.path -- 495
		if seen:has(key) then -- 495
			return key -- 496
		end -- 496
		seen:add(key) -- 497
	end -- 497
	return nil -- 499
end -- 492
local function getLinkedDeletePaths(workDir, path) -- 502
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 503
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 503
		return {} -- 504
	end -- 504
	local parent = Path:getPath(fullPath) -- 505
	local baseName = string.lower(Path:getName(fullPath)) -- 506
	local ext = Path:getExt(fullPath) -- 507
	local linked = {} -- 508
	for ____, file in ipairs(Content:getFiles(parent)) do -- 509
		do -- 509
			if string.lower(Path:getName(file)) ~= baseName then -- 509
				goto __continue86 -- 510
			end -- 510
			local siblingExt = Path:getExt(file) -- 511
			if siblingExt == "tl" and ext == "vs" then -- 511
				linked[#linked + 1] = toWorkspaceRelativePath( -- 513
					workDir, -- 513
					Path(parent, file) -- 513
				) -- 513
				goto __continue86 -- 514
			end -- 514
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 514
				linked[#linked + 1] = toWorkspaceRelativePath( -- 517
					workDir, -- 517
					Path(parent, file) -- 517
				) -- 517
			end -- 517
		end -- 517
		::__continue86:: -- 517
	end -- 517
	return linked -- 520
end -- 502
local function expandLinkedDeleteChanges(workDir, changes) -- 523
	local expanded = {} -- 524
	local seen = __TS__New(Set) -- 525
	do -- 525
		local i = 0 -- 526
		while i < #changes do -- 526
			do -- 526
				local change = changes[i + 1] -- 527
				if not seen:has(change.path) then -- 527
					seen:add(change.path) -- 529
					expanded[#expanded + 1] = change -- 530
				end -- 530
				if change.op ~= "delete" then -- 530
					goto __continue93 -- 532
				end -- 532
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 533
				do -- 533
					local j = 0 -- 534
					while j < #linkedPaths do -- 534
						do -- 534
							local linkedPath = linkedPaths[j + 1] -- 535
							if seen:has(linkedPath) then -- 535
								goto __continue97 -- 536
							end -- 536
							seen:add(linkedPath) -- 537
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 538
						end -- 538
						::__continue97:: -- 538
						j = j + 1 -- 534
					end -- 534
				end -- 534
			end -- 534
			::__continue93:: -- 534
			i = i + 1 -- 526
		end -- 526
	end -- 526
	return expanded -- 541
end -- 523
local function applySingleFile(path, exists, content) -- 544
	if exists then -- 544
		if not ensureDirForFile(path) then -- 544
			return false -- 546
		end -- 546
		return Content:save(path, content) -- 547
	end -- 547
	if Content:exist(path) then -- 547
		return Content:remove(path) -- 550
	end -- 550
	return true -- 552
end -- 544
local function encodeJSON(obj) -- 555
	local text = safeJsonEncode(obj) -- 556
	return text -- 557
end -- 555
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 560
	if HttpServer.wsConnectionCount == 0 then -- 560
		return true -- 562
	end -- 562
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 564
	if not payload then -- 564
		return false -- 566
	end -- 566
	emit("AppWS", "Send", payload) -- 568
	return true -- 569
end -- 560
local function runSingleNonTsBuild(file) -- 572
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 572
		return ____awaiter_resolve( -- 572
			nil, -- 572
			__TS__New( -- 573
				__TS__Promise, -- 573
				function(____, resolve) -- 573
					local ____require_result_1 = require("Script.Dev.WebServer") -- 574
					local buildAsync = ____require_result_1.buildAsync -- 574
					Director.systemScheduler:schedule(once(function() -- 575
						local result = buildAsync(file) -- 576
						resolve(nil, result) -- 577
					end)) -- 575
				end -- 573
			) -- 573
		) -- 573
	end) -- 573
end -- 572
function ____exports.runSingleTsTranspile(file, content) -- 582
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 582
		local done = false -- 583
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 584
		if HttpServer.wsConnectionCount == 0 then -- 584
			return ____awaiter_resolve(nil, result) -- 584
		end -- 584
		local listener = Node() -- 592
		listener:gslot( -- 593
			"AppWS", -- 593
			function(event) -- 593
				if event.type ~= "Receive" then -- 593
					return -- 594
				end -- 594
				local res = table.unpack( -- 595
					safeJsonDecode(event.msg), -- 595
					1, -- 595
					1 -- 595
				) -- 595
				if not res or __TS__ArrayIsArray(res) or type(res) ~= "table" then -- 595
					return -- 596
				end -- 596
				local payload = res -- 597
				if payload.name ~= "TranspileTS" then -- 597
					return -- 598
				end -- 598
				if payload.success then -- 598
					local luaFile = Path:replaceExt(file, "lua") -- 600
					if Content:save( -- 600
						luaFile, -- 601
						tostring(payload.luaCode) -- 601
					) then -- 601
						result = {success = true, file = file} -- 602
					else -- 602
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 604
					end -- 604
				else -- 604
					result = { -- 607
						success = false, -- 607
						file = file, -- 607
						message = tostring(payload.message) -- 607
					} -- 607
				end -- 607
				done = true -- 609
			end -- 593
		) -- 593
		local payload = encodeJSON({name = "TranspileTS", file = file, content = content}) -- 611
		if not payload then -- 611
			listener:removeFromParent() -- 617
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 617
		end -- 617
		__TS__Await(__TS__New( -- 620
			__TS__Promise, -- 620
			function(____, resolve) -- 620
				Director.systemScheduler:schedule(once(function() -- 621
					emit("AppWS", "Send", payload) -- 622
					wait(function() return done end) -- 623
					if not done then -- 623
						listener:removeFromParent() -- 625
					end -- 625
					resolve(nil) -- 627
				end)) -- 621
			end -- 620
		)) -- 620
		return ____awaiter_resolve(nil, result) -- 620
	end) -- 620
end -- 582
function ____exports.createTask(prompt) -- 633
	if prompt == nil then -- 633
		prompt = "" -- 633
	end -- 633
	local t = now() -- 634
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 635
	if affected <= 0 then -- 635
		return {success = false, message = "failed to create task"} -- 640
	end -- 640
	return { -- 642
		success = true, -- 642
		taskId = getLastInsertRowId() -- 642
	} -- 642
end -- 633
function ____exports.setTaskStatus(taskId, status) -- 645
	DB:exec( -- 646
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 646
		{ -- 646
			status, -- 646
			now(), -- 646
			taskId -- 646
		} -- 646
	) -- 646
	Log( -- 647
		"Info", -- 647
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 647
	) -- 647
end -- 645
function ____exports.listCheckpoints(taskId) -- 650
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 651
	if not rows then -- 651
		return {} -- 658
	end -- 658
	local items = {} -- 659
	do -- 659
		local i = 0 -- 660
		while i < #rows do -- 660
			local row = rows[i + 1] -- 661
			items[#items + 1] = { -- 662
				id = row[1], -- 663
				taskId = row[2], -- 664
				seq = row[3], -- 665
				status = toStr(row[4]), -- 666
				summary = toStr(row[5]), -- 667
				toolName = toStr(row[6]), -- 668
				createdAt = row[7] -- 669
			} -- 669
			i = i + 1 -- 660
		end -- 660
	end -- 660
	return items -- 672
end -- 650
local function readWorkspaceFile(workDir, path, docLanguage) -- 675
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 676
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 676
		return { -- 678
			success = true, -- 678
			content = Content:load(fullPath) -- 678
		} -- 678
	end -- 678
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 680
	if docPath then -- 680
		return { -- 682
			success = true, -- 682
			content = Content:load(docPath) -- 682
		} -- 682
	end -- 682
	if not fullPath then -- 682
		return {success = false, message = "invalid path or workDir"} -- 684
	end -- 684
	return {success = false, message = "file not found"} -- 685
end -- 675
function ____exports.readFileRaw(workDir, path, docLanguage) -- 688
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 689
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 689
		return { -- 691
			success = true, -- 691
			content = Content:load(path) -- 691
		} -- 691
	end -- 691
	return result -- 693
end -- 688
local function getEngineLogText() -- 696
	local folder = Path(Content.writablePath, ENGINE_LOG_SNAPSHOT_DIR) -- 697
	if not Content:exist(folder) then -- 697
		Content:mkdir(folder) -- 699
	end -- 699
	local logPath = Path(folder, ENGINE_LOG_SNAPSHOT_FILE) -- 701
	if not App:saveLog(logPath) then -- 701
		return nil -- 703
	end -- 703
	return Content:load(logPath) -- 705
end -- 696
function ____exports.getLogs(req) -- 708
	local text = getEngineLogText() -- 709
	if text == nil then -- 709
		return {success = false, message = "failed to read engine logs"} -- 711
	end -- 711
	local tailLines = math.max( -- 713
		1, -- 713
		math.floor(req and req.tailLines or 200) -- 713
	) -- 713
	local allLines = __TS__StringSplit(text, "\n") -- 714
	local logs = __TS__ArraySlice( -- 715
		allLines, -- 715
		math.max(0, #allLines - tailLines) -- 715
	) -- 715
	return req and req.joinText and ({ -- 716
		success = true, -- 716
		logs = logs, -- 716
		text = table.concat(logs, "\n") -- 716
	}) or ({success = true, logs = logs}) -- 716
end -- 708
function ____exports.listFiles(req) -- 719
	local root = req.path or "" -- 725
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 726
	if not searchRoot then -- 726
		return {success = false, message = "invalid path or workDir"} -- 728
	end -- 728
	do -- 728
		local function ____catch(e) -- 728
			return true, { -- 746
				success = false, -- 746
				message = tostring(e) -- 746
			} -- 746
		end -- 746
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 746
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 731
			local globs = ensureSafeSearchGlobs(userGlobs) -- 732
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 733
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 734
			local totalEntries = #files -- 735
			local maxEntries = math.max( -- 736
				1, -- 736
				math.floor(req.maxEntries or 200) -- 736
			) -- 736
			local truncated = totalEntries > maxEntries -- 737
			return true, { -- 738
				success = true, -- 739
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 740
				totalEntries = totalEntries, -- 741
				truncated = truncated, -- 742
				maxEntries = maxEntries -- 743
			} -- 743
		end) -- 743
		if not ____try then -- 743
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 743
		end -- 743
		if ____hasReturned then -- 743
			return ____returnValue -- 730
		end -- 730
	end -- 730
end -- 719
local function formatReadSlice(content, startLine, limit) -- 750
	local lines = __TS__StringSplit(content, "\n") -- 755
	local totalLines = #lines -- 756
	if totalLines == 0 then -- 756
		return { -- 758
			success = true, -- 759
			content = "", -- 760
			totalLines = 0, -- 761
			startLine = 1, -- 762
			endLine = 0, -- 763
			truncated = false -- 764
		} -- 764
	end -- 764
	local start = math.max( -- 767
		1, -- 767
		math.floor(startLine) -- 767
	) -- 767
	if start > totalLines then -- 767
		return { -- 769
			success = false, -- 769
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 769
		} -- 769
	end -- 769
	local boundedLimit = math.max( -- 771
		1, -- 771
		math.floor(limit) -- 771
	) -- 771
	local ____end = math.min(totalLines, start + boundedLimit - 1) -- 772
	local slice = {} -- 773
	do -- 773
		local i = start -- 774
		while i <= ____end do -- 774
			slice[#slice + 1] = lines[i] -- 775
			i = i + 1 -- 774
		end -- 774
	end -- 774
	local truncated = ____end < totalLines -- 777
	local hint = truncated and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use offset=") .. tostring(____end + 1)) .. " to continue.)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)" -- 778
	local body = table.concat(slice, "\n") -- 781
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 782
	return { -- 783
		success = true, -- 784
		content = output, -- 785
		totalLines = totalLines, -- 786
		startLine = start, -- 787
		endLine = ____end, -- 788
		truncated = truncated -- 789
	} -- 789
end -- 750
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 793
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 800
	if not fallback.success or fallback.content == nil then -- 800
		return fallback -- 801
	end -- 801
	local s = math.max( -- 802
		1, -- 802
		math.floor(startLine or 1) -- 802
	) -- 802
	local e = math.max( -- 803
		s, -- 803
		math.floor(endLine or 300) -- 803
	) -- 803
	return formatReadSlice(fallback.content, s, e - s + 1) -- 804
end -- 793
local codeExtensions = { -- 807
	".lua", -- 807
	".tl", -- 807
	".yue", -- 807
	".ts", -- 807
	".tsx", -- 807
	".xml", -- 807
	".md", -- 807
	".yarn", -- 807
	".wa", -- 807
	".mod" -- 807
} -- 807
extensionLevels = { -- 808
	vs = 2, -- 809
	bl = 2, -- 810
	ts = 1, -- 811
	tsx = 1, -- 812
	tl = 1, -- 813
	yue = 1, -- 814
	xml = 1, -- 815
	lua = 0 -- 816
} -- 816
local function splitSearchPatterns(pattern) -- 833
	local trimmed = __TS__StringTrim(pattern or "") -- 834
	if trimmed == "" then -- 834
		return {} -- 835
	end -- 835
	local out = {} -- 836
	local seen = __TS__New(Set) -- 837
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 838
		local p = __TS__StringTrim(tostring(p0)) -- 839
		if p ~= "" and not seen:has(p) then -- 839
			seen:add(p) -- 841
			out[#out + 1] = p -- 842
		end -- 842
	end -- 842
	return out -- 845
end -- 833
local function mergeSearchFileResultsUnique(resultsList) -- 848
	local merged = {} -- 849
	local seen = __TS__New(Set) -- 850
	do -- 850
		local i = 0 -- 851
		while i < #resultsList do -- 851
			local list = resultsList[i + 1] -- 852
			do -- 852
				local j = 0 -- 853
				while j < #list do -- 853
					do -- 853
						local row = list[j + 1] -- 854
						local ____temp_18 -- 855
						if type(row) == "table" then -- 855
							local ____tostring_8 = tostring -- 856
							local ____row_file_6 = row.file -- 856
							if ____row_file_6 == nil then -- 856
								____row_file_6 = row.path -- 856
							end -- 856
							local ____row_file_6_7 = ____row_file_6 -- 856
							if ____row_file_6_7 == nil then -- 856
								____row_file_6_7 = "" -- 856
							end -- 856
							local ____tostring_8_result_15 = ____tostring_8(____row_file_6_7) -- 856
							local ____tostring_10 = tostring -- 856
							local ____row_pos_9 = row.pos -- 856
							if ____row_pos_9 == nil then -- 856
								____row_pos_9 = "" -- 856
							end -- 856
							local ____tostring_10_result_16 = ____tostring_10(____row_pos_9) -- 856
							local ____tostring_12 = tostring -- 856
							local ____row_line_11 = row.line -- 856
							if ____row_line_11 == nil then -- 856
								____row_line_11 = "" -- 856
							end -- 856
							local ____tostring_12_result_17 = ____tostring_12(____row_line_11) -- 856
							local ____tostring_14 = tostring -- 856
							local ____row_column_13 = row.column -- 856
							if ____row_column_13 == nil then -- 856
								____row_column_13 = "" -- 856
							end -- 856
							____temp_18 = (((((____tostring_8_result_15 .. ":") .. ____tostring_10_result_16) .. ":") .. ____tostring_12_result_17) .. ":") .. ____tostring_14(____row_column_13) -- 856
						else -- 856
							____temp_18 = tostring(j) -- 857
						end -- 857
						local key = ____temp_18 -- 855
						if seen:has(key) then -- 855
							goto __continue168 -- 858
						end -- 858
						seen:add(key) -- 859
						merged[#merged + 1] = list[j + 1] -- 860
					end -- 860
					::__continue168:: -- 860
					j = j + 1 -- 853
				end -- 853
			end -- 853
			i = i + 1 -- 851
		end -- 851
	end -- 851
	return merged -- 863
end -- 848
local function buildGroupedSearchResults(results) -- 866
	local order = {} -- 871
	local grouped = __TS__New(Map) -- 872
	do -- 872
		local i = 0 -- 877
		while i < #results do -- 877
			local row = results[i + 1] -- 878
			local ____temp_22 -- 879
			if type(row) == "table" then -- 879
				local ____tostring_21 = tostring -- 880
				local ____row_file_19 = row.file -- 880
				if ____row_file_19 == nil then -- 880
					____row_file_19 = row.path -- 880
				end -- 880
				local ____row_file_19_20 = ____row_file_19 -- 880
				if ____row_file_19_20 == nil then -- 880
					____row_file_19_20 = "" -- 880
				end -- 880
				____temp_22 = ____tostring_21(____row_file_19_20) -- 880
			else -- 880
				____temp_22 = "" -- 881
			end -- 881
			local file = ____temp_22 -- 879
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 882
			local bucket = grouped:get(key) -- 883
			if not bucket then -- 883
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 885
				grouped:set(key, bucket) -- 886
				order[#order + 1] = key -- 887
			end -- 887
			bucket.totalMatches = bucket.totalMatches + 1 -- 889
			local ____bucket_matches_23 = bucket.matches -- 889
			____bucket_matches_23[#____bucket_matches_23 + 1] = results[i + 1] -- 890
			i = i + 1 -- 877
		end -- 877
	end -- 877
	local out = {} -- 892
	do -- 892
		local i = 0 -- 897
		while i < #order do -- 897
			local bucket = grouped:get(order[i + 1]) -- 898
			if bucket then -- 898
				out[#out + 1] = bucket -- 899
			end -- 899
			i = i + 1 -- 897
		end -- 897
	end -- 897
	return out -- 901
end -- 866
local function mergeDoraAPISearchHitsUnique(resultsList) -- 904
	local merged = {} -- 905
	local seen = __TS__New(Set) -- 906
	local index = 0 -- 907
	local advanced = true -- 908
	while advanced do -- 908
		advanced = false -- 910
		do -- 910
			local i = 0 -- 911
			while i < #resultsList do -- 911
				do -- 911
					local list = resultsList[i + 1] -- 912
					if index >= #list then -- 912
						goto __continue180 -- 913
					end -- 913
					advanced = true -- 914
					local row = list[index + 1] -- 915
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 916
					if seen:has(key) then -- 916
						goto __continue180 -- 917
					end -- 917
					seen:add(key) -- 918
					merged[#merged + 1] = row -- 919
				end -- 919
				::__continue180:: -- 919
				i = i + 1 -- 911
			end -- 911
		end -- 911
		index = index + 1 -- 921
	end -- 921
	return merged -- 923
end -- 904
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 926
	if docSource ~= "api" then -- 926
		return 100 -- 927
	end -- 927
	if programmingLanguage ~= "tsx" then -- 927
		return 100 -- 928
	end -- 928
	repeat -- 928
		local ____switch186 = string.lower(Path:getFilename(file)) -- 928
		local ____cond186 = ____switch186 == "jsx.d.ts" -- 928
		if ____cond186 then -- 928
			return 0 -- 930
		end -- 930
		____cond186 = ____cond186 or ____switch186 == "dorax.d.ts" -- 930
		if ____cond186 then -- 930
			return 1 -- 931
		end -- 931
		____cond186 = ____cond186 or ____switch186 == "dora.d.ts" -- 931
		if ____cond186 then -- 931
			return 2 -- 932
		end -- 932
		do -- 932
			return 100 -- 933
		end -- 933
	until true -- 933
end -- 926
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 937
	local sorted = __TS__ArraySlice(hits) -- 942
	__TS__ArraySort( -- 943
		sorted, -- 943
		function(____, a, b) -- 943
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 944
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 945
			if pa ~= pb then -- 945
				return pa - pb -- 946
			end -- 946
			local fa = string.lower(a.file) -- 947
			local fb = string.lower(b.file) -- 948
			if fa ~= fb then -- 948
				return fa < fb and -1 or 1 -- 949
			end -- 949
			return (a.line or 0) - (b.line or 0) -- 950
		end -- 943
	) -- 943
	return sorted -- 952
end -- 937
function ____exports.searchFiles(req) -- 955
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 955
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 968
		if not resolvedPath then -- 968
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 968
		end -- 968
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 972
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 973
		if not searchRoot then -- 973
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 973
		end -- 973
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 973
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 973
		end -- 973
		local patterns = splitSearchPatterns(req.pattern) -- 980
		if #patterns == 0 then -- 980
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 980
		end -- 980
		return ____awaiter_resolve( -- 980
			nil, -- 980
			__TS__New( -- 984
				__TS__Promise, -- 984
				function(____, resolve) -- 984
					Director.systemScheduler:schedule(once(function() -- 985
						do -- 985
							local function ____catch(e) -- 985
								resolve( -- 1027
									nil, -- 1027
									{ -- 1027
										success = false, -- 1027
										message = tostring(e) -- 1027
									} -- 1027
								) -- 1027
							end -- 1027
							local ____try, ____hasReturned = pcall(function() -- 1027
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 987
								local allResults = {} -- 990
								do -- 990
									local i = 0 -- 991
									while i < #patterns do -- 991
										local ____Content_28 = Content -- 992
										local ____Content_searchFilesAsync_29 = Content.searchFilesAsync -- 992
										local ____patterns_index_27 = patterns[i + 1] -- 997
										local ____req_useRegex_24 = req.useRegex -- 998
										if ____req_useRegex_24 == nil then -- 998
											____req_useRegex_24 = false -- 998
										end -- 998
										local ____req_caseSensitive_25 = req.caseSensitive -- 999
										if ____req_caseSensitive_25 == nil then -- 999
											____req_caseSensitive_25 = false -- 999
										end -- 999
										local ____req_includeContent_26 = req.includeContent -- 1000
										if ____req_includeContent_26 == nil then -- 1000
											____req_includeContent_26 = true -- 1000
										end -- 1000
										allResults[#allResults + 1] = ____Content_searchFilesAsync_29( -- 992
											____Content_28, -- 992
											searchRoot, -- 993
											codeExtensions, -- 994
											extensionLevels, -- 995
											searchGlobs, -- 996
											____patterns_index_27, -- 997
											____req_useRegex_24, -- 998
											____req_caseSensitive_25, -- 999
											____req_includeContent_26, -- 1000
											req.contentWindow or 120 -- 1001
										) -- 1001
										i = i + 1 -- 991
									end -- 991
								end -- 991
								local results = mergeSearchFileResultsUnique(allResults) -- 1004
								local totalResults = #results -- 1005
								local limit = math.max( -- 1006
									1, -- 1006
									math.floor(req.limit or 20) -- 1006
								) -- 1006
								local offset = math.max( -- 1007
									0, -- 1007
									math.floor(req.offset or 0) -- 1007
								) -- 1007
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1008
								local nextOffset = offset + #paged -- 1009
								local hasMore = nextOffset < totalResults -- 1010
								local truncated = offset > 0 or hasMore -- 1011
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1012
								local groupByFile = req.groupByFile == true -- 1013
								resolve( -- 1014
									nil, -- 1014
									{ -- 1014
										success = true, -- 1015
										results = relativeResults, -- 1016
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1017
										totalResults = totalResults, -- 1018
										truncated = truncated, -- 1019
										limit = limit, -- 1020
										offset = offset, -- 1021
										nextOffset = nextOffset, -- 1022
										hasMore = hasMore, -- 1023
										groupByFile = groupByFile -- 1024
									} -- 1024
								) -- 1024
							end) -- 1024
							if not ____try then -- 1024
								____catch(____hasReturned) -- 1024
							end -- 1024
						end -- 1024
					end)) -- 985
				end -- 984
			) -- 984
		) -- 984
	end) -- 984
end -- 955
function ____exports.searchDoraAPI(req) -- 1033
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1033
		local pattern = __TS__StringTrim(req.pattern or "") -- 1044
		if pattern == "" then -- 1044
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1044
		end -- 1044
		local patterns = splitSearchPatterns(pattern) -- 1046
		if #patterns == 0 then -- 1046
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1046
		end -- 1046
		local docSource = req.docSource or "api" -- 1048
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1049
		local docRoot = target.root -- 1050
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1051
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1051
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1051
		end -- 1051
		local exts = target.exts -- 1055
		local dotExts = __TS__ArrayMap( -- 1056
			exts, -- 1056
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1056
		) -- 1056
		local globs = target.globs -- 1057
		local limit = math.max( -- 1058
			1, -- 1058
			math.floor(req.limit or 10) -- 1058
		) -- 1058
		return ____awaiter_resolve( -- 1058
			nil, -- 1058
			__TS__New( -- 1060
				__TS__Promise, -- 1060
				function(____, resolve) -- 1060
					Director.systemScheduler:schedule(once(function() -- 1061
						do -- 1061
							local function ____catch(e) -- 1061
								resolve( -- 1106
									nil, -- 1106
									{ -- 1106
										success = false, -- 1106
										message = tostring(e) -- 1106
									} -- 1106
								) -- 1106
							end -- 1106
							local ____try, ____hasReturned = pcall(function() -- 1106
								local allHits = {} -- 1063
								do -- 1063
									local p = 0 -- 1064
									while p < #patterns do -- 1064
										local ____Content_34 = Content -- 1065
										local ____Content_searchFilesAsync_35 = Content.searchFilesAsync -- 1065
										local ____array_33 = __TS__SparseArrayNew( -- 1065
											docRoot, -- 1066
											dotExts, -- 1067
											{}, -- 1068
											ensureSafeSearchGlobs(globs), -- 1069
											patterns[p + 1] -- 1070
										) -- 1070
										local ____req_useRegex_30 = req.useRegex -- 1071
										if ____req_useRegex_30 == nil then -- 1071
											____req_useRegex_30 = false -- 1071
										end -- 1071
										__TS__SparseArrayPush(____array_33, ____req_useRegex_30) -- 1071
										local ____req_caseSensitive_31 = req.caseSensitive -- 1072
										if ____req_caseSensitive_31 == nil then -- 1072
											____req_caseSensitive_31 = false -- 1072
										end -- 1072
										__TS__SparseArrayPush(____array_33, ____req_caseSensitive_31) -- 1072
										local ____req_includeContent_32 = req.includeContent -- 1073
										if ____req_includeContent_32 == nil then -- 1073
											____req_includeContent_32 = true -- 1073
										end -- 1073
										__TS__SparseArrayPush(____array_33, ____req_includeContent_32, req.contentWindow or 80) -- 1073
										local raw = ____Content_searchFilesAsync_35( -- 1065
											____Content_34, -- 1065
											__TS__SparseArraySpread(____array_33) -- 1065
										) -- 1065
										local hits = {} -- 1076
										do -- 1076
											local i = 0 -- 1077
											while i < #raw do -- 1077
												do -- 1077
													local row = raw[i + 1] -- 1078
													if type(row) ~= "table" then -- 1078
														goto __continue213 -- 1079
													end -- 1079
													local file = type(row.file) == "string" and toDocRelativePath(resultBaseRoot, row.file) or (type(row.path) == "string" and toDocRelativePath(resultBaseRoot, row.path) or "") -- 1080
													if file == "" then -- 1080
														goto __continue213 -- 1083
													end -- 1083
													hits[#hits + 1] = { -- 1084
														file = file, -- 1085
														line = type(row.line) == "number" and row.line or nil, -- 1086
														content = type(row.content) == "string" and row.content or nil -- 1087
													} -- 1087
												end -- 1087
												::__continue213:: -- 1087
												i = i + 1 -- 1077
											end -- 1077
										end -- 1077
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1090
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1090
											0, -- 1090
											limit -- 1090
										) -- 1090
										p = p + 1 -- 1064
									end -- 1064
								end -- 1064
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1092
								resolve(nil, { -- 1093
									success = true, -- 1094
									docSource = docSource, -- 1095
									docLanguage = req.docLanguage, -- 1096
									programmingLanguage = req.programmingLanguage, -- 1097
									root = docRoot, -- 1098
									exts = exts, -- 1099
									results = hits, -- 1100
									totalResults = #hits, -- 1101
									truncated = false, -- 1102
									limit = limit -- 1103
								}) -- 1103
							end) -- 1103
							if not ____try then -- 1103
								____catch(____hasReturned) -- 1103
							end -- 1103
						end -- 1103
					end)) -- 1061
				end -- 1060
			) -- 1060
		) -- 1060
	end) -- 1060
end -- 1033
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1112
	if options == nil then -- 1112
		options = {} -- 1112
	end -- 1112
	if #changes == 0 then -- 1112
		return {success = false, message = "empty changes"} -- 1114
	end -- 1114
	if not isValidWorkDir(workDir) then -- 1114
		return {success = false, message = "invalid workDir"} -- 1117
	end -- 1117
	if not getTaskStatus(taskId) then -- 1117
		return {success = false, message = "task not found"} -- 1120
	end -- 1120
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1122
	local dup = rejectDuplicatePaths(expandedChanges) -- 1123
	if dup then -- 1123
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1125
	end -- 1125
	for ____, change in ipairs(expandedChanges) do -- 1128
		if not isValidWorkspacePath(change.path) then -- 1128
			return {success = false, message = "invalid path: " .. change.path} -- 1130
		end -- 1130
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1130
			return {success = false, message = "missing content for " .. change.path} -- 1133
		end -- 1133
	end -- 1133
	local headSeq = getTaskHeadSeq(taskId) -- 1137
	if headSeq == nil then -- 1137
		return {success = false, message = "task not found"} -- 1138
	end -- 1138
	local nextSeq = headSeq + 1 -- 1139
	local checkpointId = insertCheckpoint( -- 1140
		taskId, -- 1140
		nextSeq, -- 1140
		options.summary or "", -- 1140
		options.toolName or "", -- 1140
		"PREPARED" -- 1140
	) -- 1140
	if checkpointId <= 0 then -- 1140
		return {success = false, message = "failed to create checkpoint"} -- 1142
	end -- 1142
	do -- 1142
		local i = 0 -- 1145
		while i < #expandedChanges do -- 1145
			local change = expandedChanges[i + 1] -- 1146
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1147
			if not fullPath then -- 1147
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1149
				return {success = false, message = "invalid path: " .. change.path} -- 1150
			end -- 1150
			local before = getFileState(fullPath) -- 1152
			local afterExists = change.op ~= "delete" -- 1153
			local afterContent = afterExists and (change.content or "") or "" -- 1154
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1155
				checkpointId, -- 1159
				i + 1, -- 1160
				change.path, -- 1161
				change.op, -- 1162
				before.exists and 1 or 0, -- 1163
				before.content, -- 1164
				afterExists and 1 or 0, -- 1165
				afterContent, -- 1166
				before.bytes, -- 1167
				#afterContent -- 1168
			}) -- 1168
			if inserted <= 0 then -- 1168
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1172
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1173
			end -- 1173
			i = i + 1 -- 1145
		end -- 1145
	end -- 1145
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1177
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1178
		if not fullPath then -- 1178
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1180
			return {success = false, message = "invalid path: " .. entry.path} -- 1181
		end -- 1181
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1183
		if not ok then -- 1183
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1185
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1186
		end -- 1186
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1186
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1189
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1190
		end -- 1190
	end -- 1190
	DB:exec( -- 1194
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1194
		{ -- 1196
			"APPLIED", -- 1196
			now(), -- 1196
			checkpointId -- 1196
		} -- 1196
	) -- 1196
	DB:exec( -- 1198
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1198
		{ -- 1200
			nextSeq, -- 1200
			now(), -- 1200
			taskId -- 1200
		} -- 1200
	) -- 1200
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1202
end -- 1112
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1210
	if not isValidWorkDir(workDir) then -- 1210
		return {success = false, message = "invalid workDir"} -- 1211
	end -- 1211
	if checkpointId <= 0 then -- 1211
		return {success = false, message = "invalid checkpointId"} -- 1212
	end -- 1212
	local entries = getCheckpointEntries(checkpointId, true) -- 1213
	if #entries == 0 then -- 1213
		return {success = false, message = "checkpoint not found or empty"} -- 1215
	end -- 1215
	for ____, entry in ipairs(entries) do -- 1217
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1218
		if not fullPath then -- 1218
			return {success = false, message = "invalid path: " .. entry.path} -- 1220
		end -- 1220
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1222
		if not ok then -- 1222
			Log( -- 1224
				"Error", -- 1224
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1224
			) -- 1224
			Log( -- 1225
				"Info", -- 1225
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1225
			) -- 1225
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1226
		end -- 1226
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1226
			Log( -- 1229
				"Error", -- 1229
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1229
			) -- 1229
			Log( -- 1230
				"Info", -- 1230
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1230
			) -- 1230
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1231
		end -- 1231
	end -- 1231
	return {success = true, checkpointId = checkpointId} -- 1234
end -- 1210
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1237
	return getCheckpointEntries(checkpointId, false) -- 1238
end -- 1237
function ____exports.getCheckpointDiff(checkpointId) -- 1241
	if checkpointId <= 0 then -- 1241
		return {success = false, message = "invalid checkpointId"} -- 1243
	end -- 1243
	local entries = getCheckpointEntries(checkpointId, false) -- 1245
	if #entries == 0 then -- 1245
		return {success = false, message = "checkpoint not found or empty"} -- 1247
	end -- 1247
	return { -- 1249
		success = true, -- 1250
		files = __TS__ArrayMap( -- 1251
			entries, -- 1251
			function(____, entry) return { -- 1251
				path = entry.path, -- 1252
				op = entry.op, -- 1253
				beforeExists = entry.beforeExists, -- 1254
				afterExists = entry.afterExists, -- 1255
				beforeContent = entry.beforeContent, -- 1256
				afterContent = entry.afterContent -- 1257
			} end -- 1257
		) -- 1257
	} -- 1257
end -- 1241
function ____exports.build(req) -- 1262
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1262
		local targetRel = req.path or "" -- 1263
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1264
		if not target then -- 1264
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1264
		end -- 1264
		if not Content:exist(target) then -- 1264
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1264
		end -- 1264
		local messages = {} -- 1271
		if not Content:isdir(target) then -- 1271
			local kind = getSupportedBuildKind(target) -- 1273
			if not kind then -- 1273
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1273
			end -- 1273
			if kind == "ts" then -- 1273
				local content = Content:load(target) -- 1278
				if content == nil then -- 1278
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1278
				end -- 1278
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1278
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1278
				end -- 1278
				if not isDtsFile(target) then -- 1278
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1286
				end -- 1286
			else -- 1286
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1289
			end -- 1289
			Log( -- 1291
				"Info", -- 1291
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1291
			) -- 1291
			return ____awaiter_resolve( -- 1291
				nil, -- 1291
				{ -- 1292
					success = true, -- 1293
					messages = __TS__ArrayMap( -- 1294
						messages, -- 1294
						function(____, m) return m.success and __TS__ObjectAssign( -- 1294
							{}, -- 1295
							m, -- 1295
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1295
						) or __TS__ObjectAssign( -- 1295
							{}, -- 1296
							m, -- 1296
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1296
						) end -- 1296
					) -- 1296
				} -- 1296
			) -- 1296
		end -- 1296
		local listResult = ____exports.listFiles({ -- 1299
			workDir = req.workDir, -- 1300
			path = target, -- 1301
			globs = __TS__ArrayMap( -- 1302
				codeExtensions, -- 1302
				function(____, e) return "**/*" .. e end -- 1302
			), -- 1302
			maxEntries = 10000 -- 1303
		}) -- 1303
		local relFiles = listResult.success and listResult.files or ({}) -- 1306
		local tsFileData = {} -- 1307
		local buildQueue = {} -- 1308
		for ____, rel in ipairs(relFiles) do -- 1309
			do -- 1309
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1310
				local kind = getSupportedBuildKind(file) -- 1311
				if not kind then -- 1311
					goto __continue263 -- 1312
				end -- 1312
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1313
				if kind ~= "ts" then -- 1313
					goto __continue263 -- 1315
				end -- 1315
				local content = Content:load(file) -- 1317
				if content == nil then -- 1317
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1319
					goto __continue263 -- 1320
				end -- 1320
				tsFileData[file] = content -- 1322
				if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1322
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1324
					goto __continue263 -- 1325
				end -- 1325
			end -- 1325
			::__continue263:: -- 1325
		end -- 1325
		do -- 1325
			local i = 0 -- 1328
			while i < #buildQueue do -- 1328
				do -- 1328
					local ____buildQueue_index_36 = buildQueue[i + 1] -- 1329
					local file = ____buildQueue_index_36.file -- 1329
					local kind = ____buildQueue_index_36.kind -- 1329
					if kind == "ts" then -- 1329
						local content = tsFileData[file] -- 1331
						if content == nil or isDtsFile(file) then -- 1331
							goto __continue270 -- 1333
						end -- 1333
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1335
						goto __continue270 -- 1336
					end -- 1336
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1338
				end -- 1338
				::__continue270:: -- 1338
				i = i + 1 -- 1328
			end -- 1328
		end -- 1328
		Log( -- 1340
			"Info", -- 1340
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1340
		) -- 1340
		return ____awaiter_resolve( -- 1340
			nil, -- 1340
			{ -- 1341
				success = true, -- 1342
				messages = __TS__ArrayMap( -- 1343
					messages, -- 1343
					function(____, m) return m.success and __TS__ObjectAssign( -- 1343
						{}, -- 1344
						m, -- 1344
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1344
					) or __TS__ObjectAssign( -- 1344
						{}, -- 1345
						m, -- 1345
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1345
					) end -- 1345
				) -- 1345
			} -- 1345
		) -- 1345
	end) -- 1345
end -- 1262
return ____exports -- 1262