-- [ts]: Tools.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local Set = ____lualib.Set -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local Map = ____lualib.Map -- 1
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
local json = ____Dora.json -- 2
local App = ____Dora.App -- 2
local HttpServer = ____Dora.HttpServer -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
function ensureSafeSearchGlobs(globs) -- 763
	local result = {} -- 764
	do -- 764
		local i = 0 -- 765
		while i < #globs do -- 765
			result[#result + 1] = globs[i + 1] -- 766
			i = i + 1 -- 765
		end -- 765
	end -- 765
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 768
	do -- 768
		local i = 0 -- 769
		while i < #requiredExcludes do -- 769
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 769
				result[#result + 1] = requiredExcludes[i + 1] -- 771
			end -- 771
			i = i + 1 -- 769
		end -- 769
	end -- 769
	return result -- 774
end -- 774
local TABLE_TASK = "AgentTask" -- 188
local TABLE_CP = "AgentCheckpoint" -- 189
local TABLE_ENTRY = "AgentCheckpointEntry" -- 190
local ENGINE_LOG_SNAPSHOT_DIR = ".agent" -- 191
local ENGINE_LOG_SNAPSHOT_FILE = "engine_logs_snapshot.txt" -- 192
local DORA_DOC_ZH_DIR = Path( -- 193
	Content.assetPath, -- 193
	"Script", -- 193
	"Lib", -- 193
	"Dora", -- 193
	"zh-Hans" -- 193
) -- 193
local DORA_DOC_EN_DIR = Path( -- 194
	Content.assetPath, -- 194
	"Script", -- 194
	"Lib", -- 194
	"Dora", -- 194
	"en" -- 194
) -- 194
local function now() -- 196
	return os.time() -- 196
end -- 196
local function toBool(v) -- 198
	return v ~= 0 and v ~= false and v ~= nil -- 199
end -- 198
local function toStr(v) -- 202
	if v == false or v == nil then -- 202
		return "" -- 203
	end -- 203
	return tostring(v) -- 204
end -- 202
local function isValidWorkspacePath(path) -- 207
	if not path or #path == 0 then -- 207
		return false -- 208
	end -- 208
	if Content:isAbsolutePath(path) then -- 208
		return false -- 209
	end -- 209
	if __TS__StringIncludes(path, "..") then -- 209
		return false -- 210
	end -- 210
	return true -- 211
end -- 207
local function isValidWorkDir(workDir) -- 214
	if not workDir or #workDir == 0 then -- 214
		return false -- 215
	end -- 215
	if not Content:isAbsolutePath(workDir) then -- 215
		return false -- 216
	end -- 216
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 216
		return false -- 217
	end -- 217
	return true -- 218
end -- 214
local function isValidSearchPath(path) -- 221
	if path == "" then -- 221
		return true -- 222
	end -- 222
	if not path or #path == 0 then -- 222
		return false -- 223
	end -- 223
	if __TS__StringIncludes(path, "..") then -- 223
		return false -- 224
	end -- 224
	return true -- 225
end -- 221
local function normalizePathSep(path) -- 228
	return table.concat( -- 229
		__TS__StringSplit(path, "\\"), -- 229
		"/" -- 229
	) -- 229
end -- 228
local function ensureTrailingSlash(path) -- 232
	local p = normalizePathSep(path) -- 233
	return __TS__StringEndsWith(p, "/") and p or p .. "/" -- 234
end -- 232
local function resolveWorkspaceFilePath(workDir, path) -- 237
	if not isValidWorkDir(workDir) then -- 237
		return nil -- 238
	end -- 238
	if not isValidWorkspacePath(path) then -- 238
		return nil -- 239
	end -- 239
	return Path(workDir, path) -- 240
end -- 237
local function resolveWorkspaceSearchPath(workDir, path) -- 243
	if not isValidWorkDir(workDir) then -- 243
		return nil -- 244
	end -- 244
	local root = path or "" -- 245
	if not isValidSearchPath(root) then -- 245
		return nil -- 246
	end -- 246
	return root == "" and workDir or Path(workDir, root) -- 247
end -- 243
local function toWorkspaceRelativePath(workDir, path) -- 250
	if not path or #path == 0 then -- 250
		return path -- 251
	end -- 251
	if not Content:isAbsolutePath(path) then -- 251
		return path -- 252
	end -- 252
	return Path:getRelative(path, workDir) -- 253
end -- 250
local function toWorkspaceRelativeFileList(workDir, files) -- 256
	return __TS__ArrayMap( -- 257
		files, -- 257
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 257
	) -- 257
end -- 256
local function toWorkspaceRelativeSearchResults(workDir, results) -- 260
	local mapped = {} -- 261
	do -- 261
		local i = 0 -- 262
		while i < #results do -- 262
			local row = results[i + 1] -- 263
			if type(row) == "table" then -- 263
				local clone = {} -- 265
				for k in pairs(row) do -- 266
					clone[k] = row[k] -- 267
				end -- 267
				if type(clone.file) == "string" then -- 267
					clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 270
				end -- 270
				if type(clone.path) == "string" then -- 270
					clone.path = toWorkspaceRelativePath(workDir, clone.path) -- 273
				end -- 273
				mapped[#mapped + 1] = clone -- 275
			else -- 275
				mapped[#mapped + 1] = results[i + 1] -- 277
			end -- 277
			i = i + 1 -- 262
		end -- 262
	end -- 262
	return mapped -- 280
end -- 260
local function getDoraDocRoot(docLanguage) -- 283
	return docLanguage == "zh" and DORA_DOC_ZH_DIR or DORA_DOC_EN_DIR -- 284
end -- 283
local function getDoraDocExtsByCodeLanguage(programmingLanguage) -- 287
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 287
		return {"ts"} -- 289
	end -- 289
	return {"tl"} -- 291
end -- 287
local function toDocRelativePath(docRoot, file) -- 294
	return Path:getRelative(file, docRoot) -- 295
end -- 294
local function ensureDirPath(dir) -- 298
	if not dir or dir == "." or dir == "" then -- 298
		return true -- 299
	end -- 299
	if Content:exist(dir) then -- 299
		return Content:isdir(dir) -- 300
	end -- 300
	local parent = Path:getPath(dir) -- 301
	if parent and parent ~= dir and parent ~= "." and parent ~= "" then -- 301
		if not ensureDirPath(parent) then -- 301
			return false -- 303
		end -- 303
	end -- 303
	return Content:mkdir(dir) -- 305
end -- 298
local function ensureDirForFile(path) -- 308
	local dir = Path:getPath(path) -- 309
	return ensureDirPath(dir) -- 310
end -- 308
local function getFileState(path) -- 313
	local exists = Content:exist(path) -- 314
	if not exists then -- 314
		return {exists = false, content = "", bytes = 0} -- 316
	end -- 316
	local content = Content:load(path) -- 322
	return {exists = true, content = content, bytes = #content} -- 323
end -- 313
local function queryOne(sql, args) -- 330
	local ____args_0 -- 331
	if args then -- 331
		____args_0 = DB:query(sql, args) -- 331
	else -- 331
		____args_0 = DB:query(sql) -- 331
	end -- 331
	local rows = ____args_0 -- 331
	if not rows or #rows == 0 then -- 331
		return nil -- 332
	end -- 332
	return rows[1] -- 333
end -- 330
do -- 330
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 338
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 346
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 357
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 358
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 371
end -- 371
local function isTsLikeFile(path) -- 374
	local ext = Path:getExt(path) -- 375
	return ext == "ts" or ext == "tsx" -- 376
end -- 374
local function isDtsFile(path) -- 379
	return Path:getExt(Path:getName(path)) == "d" -- 380
end -- 379
local function getSupportedBuildKind(path) -- 385
	repeat -- 385
		local ____switch58 = Path:getExt(path) -- 385
		local ____cond58 = ____switch58 == "ts" or ____switch58 == "tsx" -- 385
		if ____cond58 then -- 385
			return "ts" -- 387
		end -- 387
		____cond58 = ____cond58 or ____switch58 == "xml" -- 387
		if ____cond58 then -- 387
			return "xml" -- 388
		end -- 388
		____cond58 = ____cond58 or ____switch58 == "tl" -- 388
		if ____cond58 then -- 388
			return "teal" -- 389
		end -- 389
		____cond58 = ____cond58 or ____switch58 == "lua" -- 389
		if ____cond58 then -- 389
			return "lua" -- 390
		end -- 390
		____cond58 = ____cond58 or ____switch58 == "yue" -- 390
		if ____cond58 then -- 390
			return "yue" -- 391
		end -- 391
		____cond58 = ____cond58 or ____switch58 == "yarn" -- 391
		if ____cond58 then -- 391
			return "yarn" -- 392
		end -- 392
		do -- 392
			return nil -- 393
		end -- 393
	until true -- 393
end -- 385
local function getTaskHeadSeq(taskId) -- 397
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 398
	if not row then -- 398
		return nil -- 399
	end -- 399
	return row[1] or 0 -- 400
end -- 397
local function getTaskStatus(taskId) -- 403
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 404
	if not row then -- 404
		return nil -- 405
	end -- 405
	return toStr(row[1]) -- 406
end -- 403
local function getLastInsertRowId() -- 409
	local row = queryOne("SELECT last_insert_rowid()") -- 410
	return row and (row[1] or 0) or 0 -- 411
end -- 409
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 414
	DB:exec( -- 415
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 415
		{ -- 417
			taskId, -- 417
			seq, -- 417
			status, -- 417
			summary, -- 417
			toolName, -- 417
			now() -- 417
		} -- 417
	) -- 417
	return getLastInsertRowId() -- 419
end -- 414
local function getCheckpointEntries(checkpointId, desc) -- 422
	if desc == nil then -- 422
		desc = false -- 422
	end -- 422
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 423
	if not rows then -- 423
		return {} -- 430
	end -- 430
	local result = {} -- 431
	do -- 431
		local i = 0 -- 432
		while i < #rows do -- 432
			local row = rows[i + 1] -- 433
			result[#result + 1] = { -- 434
				id = row[1], -- 435
				ord = row[2], -- 436
				path = toStr(row[3]), -- 437
				op = toStr(row[4]), -- 438
				beforeExists = toBool(row[5]), -- 439
				beforeContent = toStr(row[6]), -- 440
				afterExists = toBool(row[7]), -- 441
				afterContent = toStr(row[8]) -- 442
			} -- 442
			i = i + 1 -- 432
		end -- 432
	end -- 432
	return result -- 445
end -- 422
local function rejectDuplicatePaths(changes) -- 448
	local seen = __TS__New(Set) -- 449
	for ____, change in ipairs(changes) do -- 450
		local key = change.path -- 451
		if seen:has(key) then -- 451
			return key -- 452
		end -- 452
		seen:add(key) -- 453
	end -- 453
	return nil -- 455
end -- 448
local function getLinkedDeletePaths(workDir, path) -- 458
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 459
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 459
		return {} -- 460
	end -- 460
	local parent = Path:getPath(fullPath) -- 461
	local baseName = string.lower(Path:getName(fullPath)) -- 462
	local ext = Path:getExt(fullPath) -- 463
	local linked = {} -- 464
	for ____, file in ipairs(Content:getFiles(parent)) do -- 465
		do -- 465
			if string.lower(Path:getName(file)) ~= baseName then -- 465
				goto __continue75 -- 466
			end -- 466
			local siblingExt = Path:getExt(file) -- 467
			if siblingExt == "tl" and ext == "vs" then -- 467
				linked[#linked + 1] = toWorkspaceRelativePath( -- 469
					workDir, -- 469
					Path(parent, file) -- 469
				) -- 469
				goto __continue75 -- 470
			end -- 470
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 470
				linked[#linked + 1] = toWorkspaceRelativePath( -- 473
					workDir, -- 473
					Path(parent, file) -- 473
				) -- 473
			end -- 473
		end -- 473
		::__continue75:: -- 473
	end -- 473
	return linked -- 476
end -- 458
local function expandLinkedDeleteChanges(workDir, changes) -- 479
	local expanded = {} -- 480
	local seen = __TS__New(Set) -- 481
	do -- 481
		local i = 0 -- 482
		while i < #changes do -- 482
			do -- 482
				local change = changes[i + 1] -- 483
				if not seen:has(change.path) then -- 483
					seen:add(change.path) -- 485
					expanded[#expanded + 1] = change -- 486
				end -- 486
				if change.op ~= "delete" then -- 486
					goto __continue82 -- 488
				end -- 488
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 489
				do -- 489
					local j = 0 -- 490
					while j < #linkedPaths do -- 490
						do -- 490
							local linkedPath = linkedPaths[j + 1] -- 491
							if seen:has(linkedPath) then -- 491
								goto __continue86 -- 492
							end -- 492
							seen:add(linkedPath) -- 493
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 494
						end -- 494
						::__continue86:: -- 494
						j = j + 1 -- 490
					end -- 490
				end -- 490
			end -- 490
			::__continue82:: -- 490
			i = i + 1 -- 482
		end -- 482
	end -- 482
	return expanded -- 497
end -- 479
local function applySingleFile(path, exists, content) -- 500
	if exists then -- 500
		if not ensureDirForFile(path) then -- 500
			return false -- 502
		end -- 502
		return Content:save(path, content) -- 503
	end -- 503
	if Content:exist(path) then -- 503
		return Content:remove(path) -- 506
	end -- 506
	return true -- 508
end -- 500
local function encodeJSON(obj) -- 511
	local text = json.encode(obj) -- 512
	return text -- 513
end -- 511
local function runSingleNonTsBuild(file) -- 516
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 516
		return ____awaiter_resolve( -- 516
			nil, -- 516
			__TS__New( -- 517
				__TS__Promise, -- 517
				function(____, resolve) -- 517
					local ____require_result_1 = require("Script.Dev.WebServer") -- 518
					local buildAsync = ____require_result_1.buildAsync -- 518
					Director.systemScheduler:schedule(once(function() -- 519
						local result = buildAsync(file) -- 520
						resolve(nil, result) -- 521
					end)) -- 519
				end -- 517
			) -- 517
		) -- 517
	end) -- 517
end -- 516
function ____exports.runSingleTsTranspile(file, content) -- 526
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 526
		local done = false -- 527
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 528
		if HttpServer.wsConnectionCount == 0 then -- 528
			return ____awaiter_resolve(nil, result) -- 528
		end -- 528
		local listener = Node() -- 536
		listener:gslot( -- 537
			"AppWS", -- 537
			function(event) -- 537
				if event.type ~= "Receive" then -- 537
					return -- 538
				end -- 538
				local res = json.decode(event.msg) -- 539
				if not res or __TS__ArrayIsArray(res) or res.name ~= "TranspileTS" then -- 539
					return -- 540
				end -- 540
				if res.success then -- 540
					local luaFile = Path:replaceExt(file, "lua") -- 542
					if Content:save( -- 542
						luaFile, -- 543
						tostring(res.luaCode) -- 543
					) then -- 543
						result = {success = true, file = file} -- 544
					else -- 544
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 546
					end -- 546
				else -- 546
					result = { -- 549
						success = false, -- 549
						file = file, -- 549
						message = tostring(res.message) -- 549
					} -- 549
				end -- 549
				done = true -- 551
			end -- 537
		) -- 537
		local payload = encodeJSON({name = "TranspileTS", file = file, content = content}) -- 553
		if not payload then -- 553
			listener:removeFromParent() -- 559
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 559
		end -- 559
		__TS__Await(__TS__New( -- 562
			__TS__Promise, -- 562
			function(____, resolve) -- 562
				Director.systemScheduler:schedule(once(function() -- 563
					emit("AppWS", "Send", payload) -- 564
					wait(function() return done end) -- 565
					if not done then -- 565
						listener:removeFromParent() -- 567
					end -- 567
					resolve(nil) -- 569
				end)) -- 563
			end -- 562
		)) -- 562
		return ____awaiter_resolve(nil, result) -- 562
	end) -- 562
end -- 526
function ____exports.createTask(prompt) -- 575
	if prompt == nil then -- 575
		prompt = "" -- 575
	end -- 575
	local t = now() -- 576
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 577
	if affected <= 0 then -- 577
		return {success = false, message = "failed to create task"} -- 582
	end -- 582
	return { -- 584
		success = true, -- 584
		taskId = getLastInsertRowId() -- 584
	} -- 584
end -- 575
function ____exports.setTaskStatus(taskId, status) -- 587
	DB:exec( -- 588
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 588
		{ -- 588
			status, -- 588
			now(), -- 588
			taskId -- 588
		} -- 588
	) -- 588
	Log( -- 589
		"Info", -- 589
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 589
	) -- 589
end -- 587
function ____exports.listCheckpoints(taskId) -- 592
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 593
	if not rows then -- 593
		return {} -- 600
	end -- 600
	local items = {} -- 601
	do -- 601
		local i = 0 -- 602
		while i < #rows do -- 602
			local row = rows[i + 1] -- 603
			items[#items + 1] = { -- 604
				id = row[1], -- 605
				taskId = row[2], -- 606
				seq = row[3], -- 607
				status = toStr(row[4]), -- 608
				summary = toStr(row[5]), -- 609
				toolName = toStr(row[6]), -- 610
				createdAt = row[7] -- 611
			} -- 611
			i = i + 1 -- 602
		end -- 602
	end -- 602
	return items -- 614
end -- 592
local function readWorkspaceFile(workDir, path) -- 617
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 618
	if not fullPath then -- 618
		return {success = false, message = "invalid path or workDir"} -- 619
	end -- 619
	if not Content:exist(fullPath) or Content:isdir(fullPath) then -- 619
		return {success = false, message = "file not found"} -- 620
	end -- 620
	return { -- 621
		success = true, -- 621
		content = Content:load(fullPath) -- 621
	} -- 621
end -- 617
function ____exports.readFileRaw(workDir, path) -- 624
	local result = readWorkspaceFile(workDir, path) -- 625
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 625
		return { -- 627
			success = true, -- 627
			content = Content:load(path) -- 627
		} -- 627
	end -- 627
	return result -- 629
end -- 624
local function getEngineLogText() -- 632
	local folder = Path(Content.writablePath, ENGINE_LOG_SNAPSHOT_DIR) -- 633
	if not Content:exist(folder) then -- 633
		Content:mkdir(folder) -- 635
	end -- 635
	local logPath = Path(folder, ENGINE_LOG_SNAPSHOT_FILE) -- 637
	if not App:saveLog(logPath) then -- 637
		return nil -- 639
	end -- 639
	return Content:load(logPath) -- 641
end -- 632
function ____exports.getLogs(req) -- 644
	local text = getEngineLogText() -- 645
	if text == nil then -- 645
		return {success = false, message = "failed to read engine logs"} -- 647
	end -- 647
	local tailLines = math.max( -- 649
		1, -- 649
		math.floor(req and req.tailLines or 200) -- 649
	) -- 649
	local allLines = __TS__StringSplit(text, "\n") -- 650
	local logs = __TS__ArraySlice( -- 651
		allLines, -- 651
		math.max(0, #allLines - tailLines) -- 651
	) -- 651
	return req and req.joinText and ({ -- 652
		success = true, -- 652
		logs = logs, -- 652
		text = table.concat(logs, "\n") -- 652
	}) or ({success = true, logs = logs}) -- 652
end -- 644
function ____exports.listFiles(req) -- 655
	local root = req.path or "" -- 661
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 662
	if not searchRoot then -- 662
		return {success = false, message = "invalid path or workDir"} -- 664
	end -- 664
	do -- 664
		local function ____catch(e) -- 664
			return true, { -- 682
				success = false, -- 682
				message = tostring(e) -- 682
			} -- 682
		end -- 682
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 682
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 667
			local globs = ensureSafeSearchGlobs(userGlobs) -- 668
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 669
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 670
			local totalEntries = #files -- 671
			local maxEntries = math.max( -- 672
				1, -- 672
				math.floor(req.maxEntries or 200) -- 672
			) -- 672
			local truncated = totalEntries > maxEntries -- 673
			return true, { -- 674
				success = true, -- 675
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 676
				totalEntries = totalEntries, -- 677
				truncated = truncated, -- 678
				maxEntries = maxEntries -- 679
			} -- 679
		end) -- 679
		if not ____try then -- 679
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 679
		end -- 679
		if ____hasReturned then -- 679
			return ____returnValue -- 666
		end -- 666
	end -- 666
end -- 655
local function formatReadSlice(content, startLine, limit) -- 686
	local lines = __TS__StringSplit(content, "\n") -- 691
	local totalLines = #lines -- 692
	if totalLines == 0 then -- 692
		return { -- 694
			success = true, -- 695
			content = "", -- 696
			totalLines = 0, -- 697
			startLine = 1, -- 698
			endLine = 0, -- 699
			truncated = false -- 700
		} -- 700
	end -- 700
	local start = math.max( -- 703
		1, -- 703
		math.floor(startLine) -- 703
	) -- 703
	if start > totalLines then -- 703
		return { -- 705
			success = false, -- 705
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 705
		} -- 705
	end -- 705
	local boundedLimit = math.max( -- 707
		1, -- 707
		math.floor(limit) -- 707
	) -- 707
	local ____end = math.min(totalLines, start + boundedLimit - 1) -- 708
	local numbered = {} -- 709
	do -- 709
		local i = start -- 710
		while i <= ____end do -- 710
			numbered[#numbered + 1] = (tostring(i) .. "| ") .. lines[i] -- 711
			i = i + 1 -- 710
		end -- 710
	end -- 710
	local output = table.concat(numbered, "\n") -- 713
	local truncated = ____end < totalLines -- 714
	output = output .. (truncated and ((((((("\n\n(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use offset=") .. tostring(____end + 1)) .. " to continue.)" or ("\n\n(End of file - " .. tostring(totalLines)) .. " lines total)") -- 715
	return { -- 718
		success = true, -- 719
		content = output, -- 720
		totalLines = totalLines, -- 721
		startLine = start, -- 722
		endLine = ____end, -- 723
		truncated = truncated -- 724
	} -- 724
end -- 686
function ____exports.readFile(workDir, path, offset, limit) -- 728
	local fallback = ____exports.readFileRaw(workDir, path) -- 734
	if not fallback.success then -- 734
		return fallback -- 736
	end -- 736
	local start = math.max( -- 738
		1, -- 738
		math.floor(offset or 1) -- 738
	) -- 738
	local maxLines = math.max( -- 739
		1, -- 739
		math.floor(limit or 300) -- 739
	) -- 739
	return formatReadSlice(fallback.content, start, maxLines) -- 740
end -- 728
function ____exports.readFileRange(workDir, path, startLine, endLine) -- 743
	local fallback = ____exports.readFileRaw(workDir, path) -- 744
	if not fallback.success or fallback.content == nil then -- 744
		return fallback -- 745
	end -- 745
	local s = math.max( -- 746
		1, -- 746
		math.floor(startLine) -- 746
	) -- 746
	local e = math.max( -- 747
		s, -- 747
		math.floor(endLine) -- 747
	) -- 747
	return formatReadSlice(fallback.content, s, e - s + 1) -- 748
end -- 743
local codeExtensions = { -- 751
	".lua", -- 751
	".tl", -- 751
	".yue", -- 751
	".ts", -- 751
	".tsx", -- 751
	".xml", -- 751
	".md", -- 751
	".yarn", -- 751
	".wa", -- 751
	".mod" -- 751
} -- 751
extensionLevels = { -- 752
	vs = 2, -- 753
	bl = 2, -- 754
	ts = 1, -- 755
	tsx = 1, -- 756
	tl = 1, -- 757
	yue = 1, -- 758
	xml = 1, -- 759
	lua = 0 -- 760
} -- 760
local function splitSearchPatterns(pattern) -- 777
	local trimmed = __TS__StringTrim(pattern or "") -- 778
	if trimmed == "" then -- 778
		return {} -- 779
	end -- 779
	local out = {} -- 780
	local seen = __TS__New(Set) -- 781
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 782
		local p = __TS__StringTrim(tostring(p0)) -- 783
		if p ~= "" and not seen:has(p) then -- 783
			seen:add(p) -- 785
			out[#out + 1] = p -- 786
		end -- 786
	end -- 786
	return out -- 789
end -- 777
local function mergeSearchFileResultsUnique(resultsList) -- 792
	local merged = {} -- 793
	local seen = __TS__New(Set) -- 794
	do -- 794
		local i = 0 -- 795
		while i < #resultsList do -- 795
			local list = resultsList[i + 1] -- 796
			do -- 796
				local j = 0 -- 797
				while j < #list do -- 797
					do -- 797
						local row = list[j + 1] -- 798
						local ____temp_18 -- 799
						if type(row) == "table" then -- 799
							local ____tostring_8 = tostring -- 800
							local ____row_file_6 = row.file -- 800
							if ____row_file_6 == nil then -- 800
								____row_file_6 = row.path -- 800
							end -- 800
							local ____row_file_6_7 = ____row_file_6 -- 800
							if ____row_file_6_7 == nil then -- 800
								____row_file_6_7 = "" -- 800
							end -- 800
							local ____tostring_8_result_15 = ____tostring_8(____row_file_6_7) -- 800
							local ____tostring_10 = tostring -- 800
							local ____row_pos_9 = row.pos -- 800
							if ____row_pos_9 == nil then -- 800
								____row_pos_9 = "" -- 800
							end -- 800
							local ____tostring_10_result_16 = ____tostring_10(____row_pos_9) -- 800
							local ____tostring_12 = tostring -- 800
							local ____row_line_11 = row.line -- 800
							if ____row_line_11 == nil then -- 800
								____row_line_11 = "" -- 800
							end -- 800
							local ____tostring_12_result_17 = ____tostring_12(____row_line_11) -- 800
							local ____tostring_14 = tostring -- 800
							local ____row_column_13 = row.column -- 800
							if ____row_column_13 == nil then -- 800
								____row_column_13 = "" -- 800
							end -- 800
							____temp_18 = (((((____tostring_8_result_15 .. ":") .. ____tostring_10_result_16) .. ":") .. ____tostring_12_result_17) .. ":") .. ____tostring_14(____row_column_13) -- 800
						else -- 800
							____temp_18 = tostring(j) -- 801
						end -- 801
						local key = ____temp_18 -- 799
						if seen:has(key) then -- 799
							goto __continue154 -- 802
						end -- 802
						seen:add(key) -- 803
						merged[#merged + 1] = list[j + 1] -- 804
					end -- 804
					::__continue154:: -- 804
					j = j + 1 -- 797
				end -- 797
			end -- 797
			i = i + 1 -- 795
		end -- 795
	end -- 795
	return merged -- 807
end -- 792
local function buildGroupedSearchResults(results) -- 810
	local order = {} -- 815
	local grouped = __TS__New(Map) -- 816
	do -- 816
		local i = 0 -- 821
		while i < #results do -- 821
			local row = results[i + 1] -- 822
			local ____temp_22 -- 823
			if type(row) == "table" then -- 823
				local ____tostring_21 = tostring -- 824
				local ____row_file_19 = row.file -- 824
				if ____row_file_19 == nil then -- 824
					____row_file_19 = row.path -- 824
				end -- 824
				local ____row_file_19_20 = ____row_file_19 -- 824
				if ____row_file_19_20 == nil then -- 824
					____row_file_19_20 = "" -- 824
				end -- 824
				____temp_22 = ____tostring_21(____row_file_19_20) -- 824
			else -- 824
				____temp_22 = "" -- 825
			end -- 825
			local file = ____temp_22 -- 823
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 826
			local bucket = grouped:get(key) -- 827
			if not bucket then -- 827
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 829
				grouped:set(key, bucket) -- 830
				order[#order + 1] = key -- 831
			end -- 831
			bucket.totalMatches = bucket.totalMatches + 1 -- 833
			local ____bucket_matches_23 = bucket.matches -- 833
			____bucket_matches_23[#____bucket_matches_23 + 1] = results[i + 1] -- 834
			i = i + 1 -- 821
		end -- 821
	end -- 821
	local out = {} -- 836
	do -- 836
		local i = 0 -- 841
		while i < #order do -- 841
			local bucket = grouped:get(order[i + 1]) -- 842
			if bucket then -- 842
				out[#out + 1] = bucket -- 843
			end -- 843
			i = i + 1 -- 841
		end -- 841
	end -- 841
	return out -- 845
end -- 810
local function mergeDoraAPISearchHitsUnique(resultsList) -- 848
	local merged = {} -- 849
	local seen = __TS__New(Set) -- 850
	local index = 0 -- 851
	local advanced = true -- 852
	while advanced do -- 852
		advanced = false -- 854
		do -- 854
			local i = 0 -- 855
			while i < #resultsList do -- 855
				do -- 855
					local list = resultsList[i + 1] -- 856
					if index >= #list then -- 856
						goto __continue166 -- 857
					end -- 857
					advanced = true -- 858
					local row = list[index + 1] -- 859
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 860
					if seen:has(key) then -- 860
						goto __continue166 -- 861
					end -- 861
					seen:add(key) -- 862
					merged[#merged + 1] = row -- 863
				end -- 863
				::__continue166:: -- 863
				i = i + 1 -- 855
			end -- 855
		end -- 855
		index = index + 1 -- 865
	end -- 865
	return merged -- 867
end -- 848
function ____exports.searchFiles(req) -- 870
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 870
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 883
		if not resolvedPath then -- 883
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 883
		end -- 883
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 887
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 888
		if not searchRoot then -- 888
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 888
		end -- 888
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 888
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 888
		end -- 888
		local patterns = splitSearchPatterns(req.pattern) -- 895
		if #patterns == 0 then -- 895
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 895
		end -- 895
		return ____awaiter_resolve( -- 895
			nil, -- 895
			__TS__New( -- 899
				__TS__Promise, -- 899
				function(____, resolve) -- 899
					Director.systemScheduler:schedule(once(function() -- 900
						do -- 900
							local function ____catch(e) -- 900
								resolve( -- 942
									nil, -- 942
									{ -- 942
										success = false, -- 942
										message = tostring(e) -- 942
									} -- 942
								) -- 942
							end -- 942
							local ____try, ____hasReturned = pcall(function() -- 942
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 902
								local allResults = {} -- 905
								do -- 905
									local i = 0 -- 906
									while i < #patterns do -- 906
										local ____Content_28 = Content -- 907
										local ____Content_searchFilesAsync_29 = Content.searchFilesAsync -- 907
										local ____patterns_index_27 = patterns[i + 1] -- 912
										local ____req_useRegex_24 = req.useRegex -- 913
										if ____req_useRegex_24 == nil then -- 913
											____req_useRegex_24 = false -- 913
										end -- 913
										local ____req_caseSensitive_25 = req.caseSensitive -- 914
										if ____req_caseSensitive_25 == nil then -- 914
											____req_caseSensitive_25 = false -- 914
										end -- 914
										local ____req_includeContent_26 = req.includeContent -- 915
										if ____req_includeContent_26 == nil then -- 915
											____req_includeContent_26 = true -- 915
										end -- 915
										allResults[#allResults + 1] = ____Content_searchFilesAsync_29( -- 907
											____Content_28, -- 907
											searchRoot, -- 908
											codeExtensions, -- 909
											extensionLevels, -- 910
											searchGlobs, -- 911
											____patterns_index_27, -- 912
											____req_useRegex_24, -- 913
											____req_caseSensitive_25, -- 914
											____req_includeContent_26, -- 915
											req.contentWindow or 120 -- 916
										) -- 916
										i = i + 1 -- 906
									end -- 906
								end -- 906
								local results = mergeSearchFileResultsUnique(allResults) -- 919
								local totalResults = #results -- 920
								local limit = math.max( -- 921
									1, -- 921
									math.floor(req.limit or 20) -- 921
								) -- 921
								local offset = math.max( -- 922
									0, -- 922
									math.floor(req.offset or 0) -- 922
								) -- 922
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 923
								local nextOffset = offset + #paged -- 924
								local hasMore = nextOffset < totalResults -- 925
								local truncated = offset > 0 or hasMore -- 926
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 927
								local groupByFile = req.groupByFile == true -- 928
								resolve( -- 929
									nil, -- 929
									{ -- 929
										success = true, -- 930
										results = relativeResults, -- 931
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 932
										totalResults = totalResults, -- 933
										truncated = truncated, -- 934
										limit = limit, -- 935
										offset = offset, -- 936
										nextOffset = nextOffset, -- 937
										hasMore = hasMore, -- 938
										groupByFile = groupByFile -- 939
									} -- 939
								) -- 939
							end) -- 939
							if not ____try then -- 939
								____catch(____hasReturned) -- 939
							end -- 939
						end -- 939
					end)) -- 900
				end -- 899
			) -- 899
		) -- 899
	end) -- 899
end -- 870
function ____exports.searchDoraAPI(req) -- 948
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 948
		local pattern = __TS__StringTrim(req.pattern or "") -- 958
		if pattern == "" then -- 958
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 958
		end -- 958
		local patterns = splitSearchPatterns(pattern) -- 960
		if #patterns == 0 then -- 960
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 960
		end -- 960
		local docRoot = getDoraDocRoot(req.docLanguage) -- 962
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 962
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 962
		end -- 962
		local exts = getDoraDocExtsByCodeLanguage(req.programmingLanguage) -- 966
		local dotExts = __TS__ArrayMap( -- 967
			exts, -- 967
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 967
		) -- 967
		local globs = __TS__ArrayMap( -- 968
			exts, -- 968
			function(____, ext) return "**/*." .. ext end -- 968
		) -- 968
		local limit = math.max( -- 969
			1, -- 969
			math.floor(req.limit or 10) -- 969
		) -- 969
		return ____awaiter_resolve( -- 969
			nil, -- 969
			__TS__New( -- 971
				__TS__Promise, -- 971
				function(____, resolve) -- 971
					Director.systemScheduler:schedule(once(function() -- 972
						do -- 972
							local function ____catch(e) -- 972
								resolve( -- 1015
									nil, -- 1015
									{ -- 1015
										success = false, -- 1015
										message = tostring(e) -- 1015
									} -- 1015
								) -- 1015
							end -- 1015
							local ____try, ____hasReturned = pcall(function() -- 1015
								local allHits = {} -- 974
								do -- 974
									local p = 0 -- 975
									while p < #patterns do -- 975
										local ____Content_34 = Content -- 976
										local ____Content_searchFilesAsync_35 = Content.searchFilesAsync -- 976
										local ____array_33 = __TS__SparseArrayNew( -- 976
											docRoot, -- 977
											dotExts, -- 978
											{}, -- 979
											ensureSafeSearchGlobs(globs), -- 980
											patterns[p + 1] -- 981
										) -- 981
										local ____req_useRegex_30 = req.useRegex -- 982
										if ____req_useRegex_30 == nil then -- 982
											____req_useRegex_30 = false -- 982
										end -- 982
										__TS__SparseArrayPush(____array_33, ____req_useRegex_30) -- 982
										local ____req_caseSensitive_31 = req.caseSensitive -- 983
										if ____req_caseSensitive_31 == nil then -- 983
											____req_caseSensitive_31 = false -- 983
										end -- 983
										__TS__SparseArrayPush(____array_33, ____req_caseSensitive_31) -- 983
										local ____req_includeContent_32 = req.includeContent -- 984
										if ____req_includeContent_32 == nil then -- 984
											____req_includeContent_32 = true -- 984
										end -- 984
										__TS__SparseArrayPush(____array_33, ____req_includeContent_32, req.contentWindow or 140) -- 984
										local raw = ____Content_searchFilesAsync_35( -- 976
											____Content_34, -- 976
											__TS__SparseArraySpread(____array_33) -- 976
										) -- 976
										local hits = {} -- 987
										do -- 987
											local i = 0 -- 988
											while i < #raw do -- 988
												do -- 988
													local row = raw[i + 1] -- 989
													if type(row) ~= "table" then -- 989
														goto __continue192 -- 990
													end -- 990
													local file = type(row.file) == "string" and toDocRelativePath(docRoot, row.file) or (type(row.path) == "string" and toDocRelativePath(docRoot, row.path) or "") -- 991
													if file == "" then -- 991
														goto __continue192 -- 994
													end -- 994
													hits[#hits + 1] = { -- 995
														file = file, -- 996
														line = type(row.line) == "number" and row.line or nil, -- 997
														content = type(row.content) == "string" and row.content or nil -- 998
													} -- 998
												end -- 998
												::__continue192:: -- 998
												i = i + 1 -- 988
											end -- 988
										end -- 988
										allHits[#allHits + 1] = __TS__ArraySlice(hits, 0, limit) -- 1001
										p = p + 1 -- 975
									end -- 975
								end -- 975
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1003
								resolve(nil, { -- 1004
									success = true, -- 1005
									docLanguage = req.docLanguage, -- 1006
									root = docRoot, -- 1007
									exts = exts, -- 1008
									results = hits, -- 1009
									totalResults = #hits, -- 1010
									truncated = false, -- 1011
									limit = limit -- 1012
								}) -- 1012
							end) -- 1012
							if not ____try then -- 1012
								____catch(____hasReturned) -- 1012
							end -- 1012
						end -- 1012
					end)) -- 972
				end -- 971
			) -- 971
		) -- 971
	end) -- 971
end -- 948
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1021
	if options == nil then -- 1021
		options = {} -- 1021
	end -- 1021
	if #changes == 0 then -- 1021
		return {success = false, message = "empty changes"} -- 1023
	end -- 1023
	if not isValidWorkDir(workDir) then -- 1023
		return {success = false, message = "invalid workDir"} -- 1026
	end -- 1026
	if not getTaskStatus(taskId) then -- 1026
		return {success = false, message = "task not found"} -- 1029
	end -- 1029
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1031
	local dup = rejectDuplicatePaths(expandedChanges) -- 1032
	if dup then -- 1032
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1034
	end -- 1034
	for ____, change in ipairs(expandedChanges) do -- 1037
		if not isValidWorkspacePath(change.path) then -- 1037
			return {success = false, message = "invalid path: " .. change.path} -- 1039
		end -- 1039
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1039
			return {success = false, message = "missing content for " .. change.path} -- 1042
		end -- 1042
	end -- 1042
	local headSeq = getTaskHeadSeq(taskId) -- 1046
	if headSeq == nil then -- 1046
		return {success = false, message = "task not found"} -- 1047
	end -- 1047
	local nextSeq = headSeq + 1 -- 1048
	local checkpointId = insertCheckpoint( -- 1049
		taskId, -- 1049
		nextSeq, -- 1049
		options.summary or "", -- 1049
		options.toolName or "", -- 1049
		"PREPARED" -- 1049
	) -- 1049
	if checkpointId <= 0 then -- 1049
		return {success = false, message = "failed to create checkpoint"} -- 1051
	end -- 1051
	do -- 1051
		local i = 0 -- 1054
		while i < #expandedChanges do -- 1054
			local change = expandedChanges[i + 1] -- 1055
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1056
			if not fullPath then -- 1056
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1058
				return {success = false, message = "invalid path: " .. change.path} -- 1059
			end -- 1059
			local before = getFileState(fullPath) -- 1061
			local afterExists = change.op ~= "delete" -- 1062
			local afterContent = afterExists and (change.content or "") or "" -- 1063
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1064
				checkpointId, -- 1068
				i + 1, -- 1069
				change.path, -- 1070
				change.op, -- 1071
				before.exists and 1 or 0, -- 1072
				before.content, -- 1073
				afterExists and 1 or 0, -- 1074
				afterContent, -- 1075
				before.bytes, -- 1076
				#afterContent -- 1077
			}) -- 1077
			if inserted <= 0 then -- 1077
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1081
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1082
			end -- 1082
			i = i + 1 -- 1054
		end -- 1054
	end -- 1054
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1086
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1087
		if not fullPath then -- 1087
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1089
			return {success = false, message = "invalid path: " .. entry.path} -- 1090
		end -- 1090
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1092
		if not ok then -- 1092
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1094
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1095
		end -- 1095
	end -- 1095
	DB:exec( -- 1099
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1099
		{ -- 1101
			"APPLIED", -- 1101
			now(), -- 1101
			checkpointId -- 1101
		} -- 1101
	) -- 1101
	DB:exec( -- 1103
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1103
		{ -- 1105
			nextSeq, -- 1105
			now(), -- 1105
			taskId -- 1105
		} -- 1105
	) -- 1105
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1107
end -- 1021
function ____exports.rollbackToCheckpoint(taskId, workDir, targetSeq) -- 1115
	if not isValidWorkDir(workDir) then -- 1115
		return {success = false, message = "invalid workDir"} -- 1116
	end -- 1116
	local headSeq = getTaskHeadSeq(taskId) -- 1117
	if headSeq == nil then -- 1117
		return {success = false, message = "task not found"} -- 1118
	end -- 1118
	if targetSeq < 0 or targetSeq > headSeq then -- 1118
		return {success = false, message = "invalid target seq"} -- 1120
	end -- 1120
	if targetSeq == headSeq then -- 1120
		return {success = true, headSeq = headSeq} -- 1123
	end -- 1123
	local cps = DB:query(("SELECT id, seq FROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status = ? AND seq > ? AND seq <= ?\n\t\tORDER BY seq DESC", {taskId, "APPLIED", targetSeq, headSeq}) -- 1126
	if not cps then -- 1126
		return {success = false, message = "failed to query checkpoints"} -- 1132
	end -- 1132
	do -- 1132
		local i = 0 -- 1134
		while i < #cps do -- 1134
			local cpId = cps[i + 1][1] -- 1135
			local cpSeq = cps[i + 1][2] -- 1136
			local entries = getCheckpointEntries(cpId, true) -- 1137
			for ____, entry in ipairs(entries) do -- 1138
				local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1139
				if not fullPath then -- 1139
					return {success = false, message = "invalid path: " .. entry.path} -- 1141
				end -- 1141
				local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1143
				if not ok then -- 1143
					Log( -- 1145
						"Error", -- 1145
						(("Agent rollback failed at checkpoint " .. tostring(cpSeq)) .. ", file ") .. entry.path -- 1145
					) -- 1145
					Log( -- 1146
						"Info", -- 1146
						(("[rollback] failed checkpoint=" .. tostring(cpSeq)) .. " file=") .. entry.path -- 1146
					) -- 1146
					return {success = false, message = "failed to rollback file: " .. entry.path} -- 1147
				end -- 1147
			end -- 1147
			DB:exec( -- 1150
				("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 1150
				{ -- 1152
					"REVERTED", -- 1152
					now(), -- 1152
					cpId -- 1152
				} -- 1152
			) -- 1152
			i = i + 1 -- 1134
		end -- 1134
	end -- 1134
	DB:exec( -- 1156
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1156
		{ -- 1158
			targetSeq, -- 1158
			now(), -- 1158
			taskId -- 1158
		} -- 1158
	) -- 1158
	return {success = true, headSeq = targetSeq} -- 1160
end -- 1115
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1163
	return getCheckpointEntries(checkpointId, false) -- 1164
end -- 1163
function ____exports.getCheckpointDiff(checkpointId) -- 1167
	if checkpointId <= 0 then -- 1167
		return {success = false, message = "invalid checkpointId"} -- 1169
	end -- 1169
	local entries = getCheckpointEntries(checkpointId, false) -- 1171
	if #entries == 0 then -- 1171
		return {success = false, message = "checkpoint not found or empty"} -- 1173
	end -- 1173
	return { -- 1175
		success = true, -- 1176
		files = __TS__ArrayMap( -- 1177
			entries, -- 1177
			function(____, entry) return { -- 1177
				path = entry.path, -- 1178
				op = entry.op, -- 1179
				beforeExists = entry.beforeExists, -- 1180
				afterExists = entry.afterExists, -- 1181
				beforeContent = entry.beforeContent, -- 1182
				afterContent = entry.afterContent -- 1183
			} end -- 1183
		) -- 1183
	} -- 1183
end -- 1167
function ____exports.build(req) -- 1188
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1188
		local targetRel = req.path or "" -- 1189
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1190
		if not target then -- 1190
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1190
		end -- 1190
		if not Content:exist(target) then -- 1190
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1190
		end -- 1190
		local messages = {} -- 1197
		if not Content:isdir(target) then -- 1197
			local kind = getSupportedBuildKind(target) -- 1199
			if not kind then -- 1199
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1199
			end -- 1199
			if kind == "ts" then -- 1199
				local content = Content:load(target) -- 1204
				if content == nil then -- 1204
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1204
				end -- 1204
				local updatePayload = encodeJSON({name = "UpdateTSCode", file = target, content = content}) -- 1208
				if not updatePayload then -- 1208
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateTSCode request"}) -- 1208
				end -- 1208
				emit("AppWS", "Send", updatePayload) -- 1212
				if not isDtsFile(target) then -- 1212
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1214
				end -- 1214
			else -- 1214
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1217
			end -- 1217
			Log( -- 1219
				"Info", -- 1219
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1219
			) -- 1219
			return ____awaiter_resolve( -- 1219
				nil, -- 1219
				{ -- 1220
					success = true, -- 1221
					messages = __TS__ArrayMap( -- 1222
						messages, -- 1222
						function(____, m) return m.success and __TS__ObjectAssign( -- 1222
							{}, -- 1223
							m, -- 1223
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1223
						) or __TS__ObjectAssign( -- 1223
							{}, -- 1224
							m, -- 1224
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1224
						) end -- 1224
					) -- 1224
				} -- 1224
			) -- 1224
		end -- 1224
		local listResult = ____exports.listFiles({workDir = req.workDir, path = target}) -- 1227
		local relFiles = listResult.success and listResult.files or ({}) -- 1232
		local tsFileData = {} -- 1233
		local buildQueue = {} -- 1234
		for ____, rel in ipairs(relFiles) do -- 1235
			do -- 1235
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1236
				local kind = getSupportedBuildKind(file) -- 1237
				if not kind then -- 1237
					goto __continue243 -- 1238
				end -- 1238
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1239
				if kind ~= "ts" then -- 1239
					goto __continue243 -- 1241
				end -- 1241
				local content = Content:load(file) -- 1243
				if content == nil then -- 1243
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1245
					goto __continue243 -- 1246
				end -- 1246
				tsFileData[file] = content -- 1248
				local updatePayload = encodeJSON({name = "UpdateTSCode", file = file, content = content}) -- 1249
				if not updatePayload then -- 1249
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateTSCode request"} -- 1251
					goto __continue243 -- 1252
				end -- 1252
				emit("AppWS", "Send", updatePayload) -- 1254
			end -- 1254
			::__continue243:: -- 1254
		end -- 1254
		do -- 1254
			local i = 0 -- 1256
			while i < #buildQueue do -- 1256
				do -- 1256
					local ____buildQueue_index_36 = buildQueue[i + 1] -- 1257
					local file = ____buildQueue_index_36.file -- 1257
					local kind = ____buildQueue_index_36.kind -- 1257
					if kind == "ts" then -- 1257
						local content = tsFileData[file] -- 1259
						if content == nil or isDtsFile(file) then -- 1259
							goto __continue250 -- 1261
						end -- 1261
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1263
						goto __continue250 -- 1264
					end -- 1264
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1266
				end -- 1266
				::__continue250:: -- 1266
				i = i + 1 -- 1256
			end -- 1256
		end -- 1256
		Log( -- 1268
			"Info", -- 1268
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1268
		) -- 1268
		return ____awaiter_resolve( -- 1268
			nil, -- 1268
			{ -- 1269
				success = true, -- 1270
				messages = __TS__ArrayMap( -- 1271
					messages, -- 1271
					function(____, m) return m.success and __TS__ObjectAssign( -- 1271
						{}, -- 1272
						m, -- 1272
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1272
					) or __TS__ObjectAssign( -- 1272
						{}, -- 1273
						m, -- 1273
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1273
					) end -- 1273
				) -- 1273
			} -- 1273
		) -- 1273
	end) -- 1273
end -- 1188
return ____exports -- 1188