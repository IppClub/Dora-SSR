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
function ensureSafeSearchGlobs(globs) -- 775
	local result = {} -- 776
	do -- 776
		local i = 0 -- 777
		while i < #globs do -- 777
			result[#result + 1] = globs[i + 1] -- 778
			i = i + 1 -- 777
		end -- 777
	end -- 777
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 780
	do -- 780
		local i = 0 -- 781
		while i < #requiredExcludes do -- 781
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 781
				result[#result + 1] = requiredExcludes[i + 1] -- 783
			end -- 783
			i = i + 1 -- 781
		end -- 781
	end -- 781
	return result -- 786
end -- 786
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
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 516
	if HttpServer.wsConnectionCount == 0 then -- 516
		return true -- 518
	end -- 518
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 520
	if not payload then -- 520
		return false -- 522
	end -- 522
	emit("AppWS", "Send", payload) -- 524
	return true -- 525
end -- 516
local function runSingleNonTsBuild(file) -- 528
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 528
		return ____awaiter_resolve( -- 528
			nil, -- 528
			__TS__New( -- 529
				__TS__Promise, -- 529
				function(____, resolve) -- 529
					local ____require_result_1 = require("Script.Dev.WebServer") -- 530
					local buildAsync = ____require_result_1.buildAsync -- 530
					Director.systemScheduler:schedule(once(function() -- 531
						local result = buildAsync(file) -- 532
						resolve(nil, result) -- 533
					end)) -- 531
				end -- 529
			) -- 529
		) -- 529
	end) -- 529
end -- 528
function ____exports.runSingleTsTranspile(file, content) -- 538
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 538
		local done = false -- 539
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 540
		if HttpServer.wsConnectionCount == 0 then -- 540
			return ____awaiter_resolve(nil, result) -- 540
		end -- 540
		local listener = Node() -- 548
		listener:gslot( -- 549
			"AppWS", -- 549
			function(event) -- 549
				if event.type ~= "Receive" then -- 549
					return -- 550
				end -- 550
				local res = json.decode(event.msg) -- 551
				if not res or __TS__ArrayIsArray(res) or res.name ~= "TranspileTS" then -- 551
					return -- 552
				end -- 552
				if res.success then -- 552
					local luaFile = Path:replaceExt(file, "lua") -- 554
					if Content:save( -- 554
						luaFile, -- 555
						tostring(res.luaCode) -- 555
					) then -- 555
						result = {success = true, file = file} -- 556
					else -- 556
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 558
					end -- 558
				else -- 558
					result = { -- 561
						success = false, -- 561
						file = file, -- 561
						message = tostring(res.message) -- 561
					} -- 561
				end -- 561
				done = true -- 563
			end -- 549
		) -- 549
		local payload = encodeJSON({name = "TranspileTS", file = file, content = content}) -- 565
		if not payload then -- 565
			listener:removeFromParent() -- 571
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 571
		end -- 571
		__TS__Await(__TS__New( -- 574
			__TS__Promise, -- 574
			function(____, resolve) -- 574
				Director.systemScheduler:schedule(once(function() -- 575
					emit("AppWS", "Send", payload) -- 576
					wait(function() return done end) -- 577
					if not done then -- 577
						listener:removeFromParent() -- 579
					end -- 579
					resolve(nil) -- 581
				end)) -- 575
			end -- 574
		)) -- 574
		return ____awaiter_resolve(nil, result) -- 574
	end) -- 574
end -- 538
function ____exports.createTask(prompt) -- 587
	if prompt == nil then -- 587
		prompt = "" -- 587
	end -- 587
	local t = now() -- 588
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 589
	if affected <= 0 then -- 589
		return {success = false, message = "failed to create task"} -- 594
	end -- 594
	return { -- 596
		success = true, -- 596
		taskId = getLastInsertRowId() -- 596
	} -- 596
end -- 587
function ____exports.setTaskStatus(taskId, status) -- 599
	DB:exec( -- 600
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 600
		{ -- 600
			status, -- 600
			now(), -- 600
			taskId -- 600
		} -- 600
	) -- 600
	Log( -- 601
		"Info", -- 601
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 601
	) -- 601
end -- 599
function ____exports.listCheckpoints(taskId) -- 604
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 605
	if not rows then -- 605
		return {} -- 612
	end -- 612
	local items = {} -- 613
	do -- 613
		local i = 0 -- 614
		while i < #rows do -- 614
			local row = rows[i + 1] -- 615
			items[#items + 1] = { -- 616
				id = row[1], -- 617
				taskId = row[2], -- 618
				seq = row[3], -- 619
				status = toStr(row[4]), -- 620
				summary = toStr(row[5]), -- 621
				toolName = toStr(row[6]), -- 622
				createdAt = row[7] -- 623
			} -- 623
			i = i + 1 -- 614
		end -- 614
	end -- 614
	return items -- 626
end -- 604
local function readWorkspaceFile(workDir, path) -- 629
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 630
	if not fullPath then -- 630
		return {success = false, message = "invalid path or workDir"} -- 631
	end -- 631
	if not Content:exist(fullPath) or Content:isdir(fullPath) then -- 631
		return {success = false, message = "file not found"} -- 632
	end -- 632
	return { -- 633
		success = true, -- 633
		content = Content:load(fullPath) -- 633
	} -- 633
end -- 629
function ____exports.readFileRaw(workDir, path) -- 636
	local result = readWorkspaceFile(workDir, path) -- 637
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 637
		return { -- 639
			success = true, -- 639
			content = Content:load(path) -- 639
		} -- 639
	end -- 639
	return result -- 641
end -- 636
local function getEngineLogText() -- 644
	local folder = Path(Content.writablePath, ENGINE_LOG_SNAPSHOT_DIR) -- 645
	if not Content:exist(folder) then -- 645
		Content:mkdir(folder) -- 647
	end -- 647
	local logPath = Path(folder, ENGINE_LOG_SNAPSHOT_FILE) -- 649
	if not App:saveLog(logPath) then -- 649
		return nil -- 651
	end -- 651
	return Content:load(logPath) -- 653
end -- 644
function ____exports.getLogs(req) -- 656
	local text = getEngineLogText() -- 657
	if text == nil then -- 657
		return {success = false, message = "failed to read engine logs"} -- 659
	end -- 659
	local tailLines = math.max( -- 661
		1, -- 661
		math.floor(req and req.tailLines or 200) -- 661
	) -- 661
	local allLines = __TS__StringSplit(text, "\n") -- 662
	local logs = __TS__ArraySlice( -- 663
		allLines, -- 663
		math.max(0, #allLines - tailLines) -- 663
	) -- 663
	return req and req.joinText and ({ -- 664
		success = true, -- 664
		logs = logs, -- 664
		text = table.concat(logs, "\n") -- 664
	}) or ({success = true, logs = logs}) -- 664
end -- 656
function ____exports.listFiles(req) -- 667
	local root = req.path or "" -- 673
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 674
	if not searchRoot then -- 674
		return {success = false, message = "invalid path or workDir"} -- 676
	end -- 676
	do -- 676
		local function ____catch(e) -- 676
			return true, { -- 694
				success = false, -- 694
				message = tostring(e) -- 694
			} -- 694
		end -- 694
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 694
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 679
			local globs = ensureSafeSearchGlobs(userGlobs) -- 680
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 681
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 682
			local totalEntries = #files -- 683
			local maxEntries = math.max( -- 684
				1, -- 684
				math.floor(req.maxEntries or 200) -- 684
			) -- 684
			local truncated = totalEntries > maxEntries -- 685
			return true, { -- 686
				success = true, -- 687
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 688
				totalEntries = totalEntries, -- 689
				truncated = truncated, -- 690
				maxEntries = maxEntries -- 691
			} -- 691
		end) -- 691
		if not ____try then -- 691
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 691
		end -- 691
		if ____hasReturned then -- 691
			return ____returnValue -- 678
		end -- 678
	end -- 678
end -- 667
local function formatReadSlice(content, startLine, limit) -- 698
	local lines = __TS__StringSplit(content, "\n") -- 703
	local totalLines = #lines -- 704
	if totalLines == 0 then -- 704
		return { -- 706
			success = true, -- 707
			content = "", -- 708
			totalLines = 0, -- 709
			startLine = 1, -- 710
			endLine = 0, -- 711
			truncated = false -- 712
		} -- 712
	end -- 712
	local start = math.max( -- 715
		1, -- 715
		math.floor(startLine) -- 715
	) -- 715
	if start > totalLines then -- 715
		return { -- 717
			success = false, -- 717
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 717
		} -- 717
	end -- 717
	local boundedLimit = math.max( -- 719
		1, -- 719
		math.floor(limit) -- 719
	) -- 719
	local ____end = math.min(totalLines, start + boundedLimit - 1) -- 720
	local numbered = {} -- 721
	do -- 721
		local i = start -- 722
		while i <= ____end do -- 722
			numbered[#numbered + 1] = (tostring(i) .. "| ") .. lines[i] -- 723
			i = i + 1 -- 722
		end -- 722
	end -- 722
	local output = table.concat(numbered, "\n") -- 725
	local truncated = ____end < totalLines -- 726
	output = output .. (truncated and ((((((("\n\n(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use offset=") .. tostring(____end + 1)) .. " to continue.)" or ("\n\n(End of file - " .. tostring(totalLines)) .. " lines total)") -- 727
	return { -- 730
		success = true, -- 731
		content = output, -- 732
		totalLines = totalLines, -- 733
		startLine = start, -- 734
		endLine = ____end, -- 735
		truncated = truncated -- 736
	} -- 736
end -- 698
function ____exports.readFile(workDir, path, offset, limit) -- 740
	local fallback = ____exports.readFileRaw(workDir, path) -- 746
	if not fallback.success then -- 746
		return fallback -- 748
	end -- 748
	local start = math.max( -- 750
		1, -- 750
		math.floor(offset or 1) -- 750
	) -- 750
	local maxLines = math.max( -- 751
		1, -- 751
		math.floor(limit or 300) -- 751
	) -- 751
	return formatReadSlice(fallback.content, start, maxLines) -- 752
end -- 740
function ____exports.readFileRange(workDir, path, startLine, endLine) -- 755
	local fallback = ____exports.readFileRaw(workDir, path) -- 756
	if not fallback.success or fallback.content == nil then -- 756
		return fallback -- 757
	end -- 757
	local s = math.max( -- 758
		1, -- 758
		math.floor(startLine) -- 758
	) -- 758
	local e = math.max( -- 759
		s, -- 759
		math.floor(endLine) -- 759
	) -- 759
	return formatReadSlice(fallback.content, s, e - s + 1) -- 760
end -- 755
local codeExtensions = { -- 763
	".lua", -- 763
	".tl", -- 763
	".yue", -- 763
	".ts", -- 763
	".tsx", -- 763
	".xml", -- 763
	".md", -- 763
	".yarn", -- 763
	".wa", -- 763
	".mod" -- 763
} -- 763
extensionLevels = { -- 764
	vs = 2, -- 765
	bl = 2, -- 766
	ts = 1, -- 767
	tsx = 1, -- 768
	tl = 1, -- 769
	yue = 1, -- 770
	xml = 1, -- 771
	lua = 0 -- 772
} -- 772
local function splitSearchPatterns(pattern) -- 789
	local trimmed = __TS__StringTrim(pattern or "") -- 790
	if trimmed == "" then -- 790
		return {} -- 791
	end -- 791
	local out = {} -- 792
	local seen = __TS__New(Set) -- 793
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 794
		local p = __TS__StringTrim(tostring(p0)) -- 795
		if p ~= "" and not seen:has(p) then -- 795
			seen:add(p) -- 797
			out[#out + 1] = p -- 798
		end -- 798
	end -- 798
	return out -- 801
end -- 789
local function mergeSearchFileResultsUnique(resultsList) -- 804
	local merged = {} -- 805
	local seen = __TS__New(Set) -- 806
	do -- 806
		local i = 0 -- 807
		while i < #resultsList do -- 807
			local list = resultsList[i + 1] -- 808
			do -- 808
				local j = 0 -- 809
				while j < #list do -- 809
					do -- 809
						local row = list[j + 1] -- 810
						local ____temp_18 -- 811
						if type(row) == "table" then -- 811
							local ____tostring_8 = tostring -- 812
							local ____row_file_6 = row.file -- 812
							if ____row_file_6 == nil then -- 812
								____row_file_6 = row.path -- 812
							end -- 812
							local ____row_file_6_7 = ____row_file_6 -- 812
							if ____row_file_6_7 == nil then -- 812
								____row_file_6_7 = "" -- 812
							end -- 812
							local ____tostring_8_result_15 = ____tostring_8(____row_file_6_7) -- 812
							local ____tostring_10 = tostring -- 812
							local ____row_pos_9 = row.pos -- 812
							if ____row_pos_9 == nil then -- 812
								____row_pos_9 = "" -- 812
							end -- 812
							local ____tostring_10_result_16 = ____tostring_10(____row_pos_9) -- 812
							local ____tostring_12 = tostring -- 812
							local ____row_line_11 = row.line -- 812
							if ____row_line_11 == nil then -- 812
								____row_line_11 = "" -- 812
							end -- 812
							local ____tostring_12_result_17 = ____tostring_12(____row_line_11) -- 812
							local ____tostring_14 = tostring -- 812
							local ____row_column_13 = row.column -- 812
							if ____row_column_13 == nil then -- 812
								____row_column_13 = "" -- 812
							end -- 812
							____temp_18 = (((((____tostring_8_result_15 .. ":") .. ____tostring_10_result_16) .. ":") .. ____tostring_12_result_17) .. ":") .. ____tostring_14(____row_column_13) -- 812
						else -- 812
							____temp_18 = tostring(j) -- 813
						end -- 813
						local key = ____temp_18 -- 811
						if seen:has(key) then -- 811
							goto __continue157 -- 814
						end -- 814
						seen:add(key) -- 815
						merged[#merged + 1] = list[j + 1] -- 816
					end -- 816
					::__continue157:: -- 816
					j = j + 1 -- 809
				end -- 809
			end -- 809
			i = i + 1 -- 807
		end -- 807
	end -- 807
	return merged -- 819
end -- 804
local function buildGroupedSearchResults(results) -- 822
	local order = {} -- 827
	local grouped = __TS__New(Map) -- 828
	do -- 828
		local i = 0 -- 833
		while i < #results do -- 833
			local row = results[i + 1] -- 834
			local ____temp_22 -- 835
			if type(row) == "table" then -- 835
				local ____tostring_21 = tostring -- 836
				local ____row_file_19 = row.file -- 836
				if ____row_file_19 == nil then -- 836
					____row_file_19 = row.path -- 836
				end -- 836
				local ____row_file_19_20 = ____row_file_19 -- 836
				if ____row_file_19_20 == nil then -- 836
					____row_file_19_20 = "" -- 836
				end -- 836
				____temp_22 = ____tostring_21(____row_file_19_20) -- 836
			else -- 836
				____temp_22 = "" -- 837
			end -- 837
			local file = ____temp_22 -- 835
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 838
			local bucket = grouped:get(key) -- 839
			if not bucket then -- 839
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 841
				grouped:set(key, bucket) -- 842
				order[#order + 1] = key -- 843
			end -- 843
			bucket.totalMatches = bucket.totalMatches + 1 -- 845
			local ____bucket_matches_23 = bucket.matches -- 845
			____bucket_matches_23[#____bucket_matches_23 + 1] = results[i + 1] -- 846
			i = i + 1 -- 833
		end -- 833
	end -- 833
	local out = {} -- 848
	do -- 848
		local i = 0 -- 853
		while i < #order do -- 853
			local bucket = grouped:get(order[i + 1]) -- 854
			if bucket then -- 854
				out[#out + 1] = bucket -- 855
			end -- 855
			i = i + 1 -- 853
		end -- 853
	end -- 853
	return out -- 857
end -- 822
local function mergeDoraAPISearchHitsUnique(resultsList) -- 860
	local merged = {} -- 861
	local seen = __TS__New(Set) -- 862
	local index = 0 -- 863
	local advanced = true -- 864
	while advanced do -- 864
		advanced = false -- 866
		do -- 866
			local i = 0 -- 867
			while i < #resultsList do -- 867
				do -- 867
					local list = resultsList[i + 1] -- 868
					if index >= #list then -- 868
						goto __continue169 -- 869
					end -- 869
					advanced = true -- 870
					local row = list[index + 1] -- 871
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 872
					if seen:has(key) then -- 872
						goto __continue169 -- 873
					end -- 873
					seen:add(key) -- 874
					merged[#merged + 1] = row -- 875
				end -- 875
				::__continue169:: -- 875
				i = i + 1 -- 867
			end -- 867
		end -- 867
		index = index + 1 -- 877
	end -- 877
	return merged -- 879
end -- 860
function ____exports.searchFiles(req) -- 882
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 882
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 895
		if not resolvedPath then -- 895
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 895
		end -- 895
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 899
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 900
		if not searchRoot then -- 900
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 900
		end -- 900
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 900
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 900
		end -- 900
		local patterns = splitSearchPatterns(req.pattern) -- 907
		if #patterns == 0 then -- 907
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 907
		end -- 907
		return ____awaiter_resolve( -- 907
			nil, -- 907
			__TS__New( -- 911
				__TS__Promise, -- 911
				function(____, resolve) -- 911
					Director.systemScheduler:schedule(once(function() -- 912
						do -- 912
							local function ____catch(e) -- 912
								resolve( -- 954
									nil, -- 954
									{ -- 954
										success = false, -- 954
										message = tostring(e) -- 954
									} -- 954
								) -- 954
							end -- 954
							local ____try, ____hasReturned = pcall(function() -- 954
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 914
								local allResults = {} -- 917
								do -- 917
									local i = 0 -- 918
									while i < #patterns do -- 918
										local ____Content_28 = Content -- 919
										local ____Content_searchFilesAsync_29 = Content.searchFilesAsync -- 919
										local ____patterns_index_27 = patterns[i + 1] -- 924
										local ____req_useRegex_24 = req.useRegex -- 925
										if ____req_useRegex_24 == nil then -- 925
											____req_useRegex_24 = false -- 925
										end -- 925
										local ____req_caseSensitive_25 = req.caseSensitive -- 926
										if ____req_caseSensitive_25 == nil then -- 926
											____req_caseSensitive_25 = false -- 926
										end -- 926
										local ____req_includeContent_26 = req.includeContent -- 927
										if ____req_includeContent_26 == nil then -- 927
											____req_includeContent_26 = true -- 927
										end -- 927
										allResults[#allResults + 1] = ____Content_searchFilesAsync_29( -- 919
											____Content_28, -- 919
											searchRoot, -- 920
											codeExtensions, -- 921
											extensionLevels, -- 922
											searchGlobs, -- 923
											____patterns_index_27, -- 924
											____req_useRegex_24, -- 925
											____req_caseSensitive_25, -- 926
											____req_includeContent_26, -- 927
											req.contentWindow or 120 -- 928
										) -- 928
										i = i + 1 -- 918
									end -- 918
								end -- 918
								local results = mergeSearchFileResultsUnique(allResults) -- 931
								local totalResults = #results -- 932
								local limit = math.max( -- 933
									1, -- 933
									math.floor(req.limit or 20) -- 933
								) -- 933
								local offset = math.max( -- 934
									0, -- 934
									math.floor(req.offset or 0) -- 934
								) -- 934
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 935
								local nextOffset = offset + #paged -- 936
								local hasMore = nextOffset < totalResults -- 937
								local truncated = offset > 0 or hasMore -- 938
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 939
								local groupByFile = req.groupByFile == true -- 940
								resolve( -- 941
									nil, -- 941
									{ -- 941
										success = true, -- 942
										results = relativeResults, -- 943
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 944
										totalResults = totalResults, -- 945
										truncated = truncated, -- 946
										limit = limit, -- 947
										offset = offset, -- 948
										nextOffset = nextOffset, -- 949
										hasMore = hasMore, -- 950
										groupByFile = groupByFile -- 951
									} -- 951
								) -- 951
							end) -- 951
							if not ____try then -- 951
								____catch(____hasReturned) -- 951
							end -- 951
						end -- 951
					end)) -- 912
				end -- 911
			) -- 911
		) -- 911
	end) -- 911
end -- 882
function ____exports.searchDoraAPI(req) -- 960
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 960
		local pattern = __TS__StringTrim(req.pattern or "") -- 970
		if pattern == "" then -- 970
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 970
		end -- 970
		local patterns = splitSearchPatterns(pattern) -- 972
		if #patterns == 0 then -- 972
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 972
		end -- 972
		local docRoot = getDoraDocRoot(req.docLanguage) -- 974
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 974
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 974
		end -- 974
		local exts = getDoraDocExtsByCodeLanguage(req.programmingLanguage) -- 978
		local dotExts = __TS__ArrayMap( -- 979
			exts, -- 979
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 979
		) -- 979
		local globs = __TS__ArrayMap( -- 980
			exts, -- 980
			function(____, ext) return "**/*." .. ext end -- 980
		) -- 980
		local limit = math.max( -- 981
			1, -- 981
			math.floor(req.limit or 10) -- 981
		) -- 981
		return ____awaiter_resolve( -- 981
			nil, -- 981
			__TS__New( -- 983
				__TS__Promise, -- 983
				function(____, resolve) -- 983
					Director.systemScheduler:schedule(once(function() -- 984
						do -- 984
							local function ____catch(e) -- 984
								resolve( -- 1027
									nil, -- 1027
									{ -- 1027
										success = false, -- 1027
										message = tostring(e) -- 1027
									} -- 1027
								) -- 1027
							end -- 1027
							local ____try, ____hasReturned = pcall(function() -- 1027
								local allHits = {} -- 986
								do -- 986
									local p = 0 -- 987
									while p < #patterns do -- 987
										local ____Content_34 = Content -- 988
										local ____Content_searchFilesAsync_35 = Content.searchFilesAsync -- 988
										local ____array_33 = __TS__SparseArrayNew( -- 988
											docRoot, -- 989
											dotExts, -- 990
											{}, -- 991
											ensureSafeSearchGlobs(globs), -- 992
											patterns[p + 1] -- 993
										) -- 993
										local ____req_useRegex_30 = req.useRegex -- 994
										if ____req_useRegex_30 == nil then -- 994
											____req_useRegex_30 = false -- 994
										end -- 994
										__TS__SparseArrayPush(____array_33, ____req_useRegex_30) -- 994
										local ____req_caseSensitive_31 = req.caseSensitive -- 995
										if ____req_caseSensitive_31 == nil then -- 995
											____req_caseSensitive_31 = false -- 995
										end -- 995
										__TS__SparseArrayPush(____array_33, ____req_caseSensitive_31) -- 995
										local ____req_includeContent_32 = req.includeContent -- 996
										if ____req_includeContent_32 == nil then -- 996
											____req_includeContent_32 = true -- 996
										end -- 996
										__TS__SparseArrayPush(____array_33, ____req_includeContent_32, req.contentWindow or 140) -- 996
										local raw = ____Content_searchFilesAsync_35( -- 988
											____Content_34, -- 988
											__TS__SparseArraySpread(____array_33) -- 988
										) -- 988
										local hits = {} -- 999
										do -- 999
											local i = 0 -- 1000
											while i < #raw do -- 1000
												do -- 1000
													local row = raw[i + 1] -- 1001
													if type(row) ~= "table" then -- 1001
														goto __continue195 -- 1002
													end -- 1002
													local file = type(row.file) == "string" and toDocRelativePath(docRoot, row.file) or (type(row.path) == "string" and toDocRelativePath(docRoot, row.path) or "") -- 1003
													if file == "" then -- 1003
														goto __continue195 -- 1006
													end -- 1006
													hits[#hits + 1] = { -- 1007
														file = file, -- 1008
														line = type(row.line) == "number" and row.line or nil, -- 1009
														content = type(row.content) == "string" and row.content or nil -- 1010
													} -- 1010
												end -- 1010
												::__continue195:: -- 1010
												i = i + 1 -- 1000
											end -- 1000
										end -- 1000
										allHits[#allHits + 1] = __TS__ArraySlice(hits, 0, limit) -- 1013
										p = p + 1 -- 987
									end -- 987
								end -- 987
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1015
								resolve(nil, { -- 1016
									success = true, -- 1017
									docLanguage = req.docLanguage, -- 1018
									root = docRoot, -- 1019
									exts = exts, -- 1020
									results = hits, -- 1021
									totalResults = #hits, -- 1022
									truncated = false, -- 1023
									limit = limit -- 1024
								}) -- 1024
							end) -- 1024
							if not ____try then -- 1024
								____catch(____hasReturned) -- 1024
							end -- 1024
						end -- 1024
					end)) -- 984
				end -- 983
			) -- 983
		) -- 983
	end) -- 983
end -- 960
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1033
	if options == nil then -- 1033
		options = {} -- 1033
	end -- 1033
	if #changes == 0 then -- 1033
		return {success = false, message = "empty changes"} -- 1035
	end -- 1035
	if not isValidWorkDir(workDir) then -- 1035
		return {success = false, message = "invalid workDir"} -- 1038
	end -- 1038
	if not getTaskStatus(taskId) then -- 1038
		return {success = false, message = "task not found"} -- 1041
	end -- 1041
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1043
	local dup = rejectDuplicatePaths(expandedChanges) -- 1044
	if dup then -- 1044
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1046
	end -- 1046
	for ____, change in ipairs(expandedChanges) do -- 1049
		if not isValidWorkspacePath(change.path) then -- 1049
			return {success = false, message = "invalid path: " .. change.path} -- 1051
		end -- 1051
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1051
			return {success = false, message = "missing content for " .. change.path} -- 1054
		end -- 1054
	end -- 1054
	local headSeq = getTaskHeadSeq(taskId) -- 1058
	if headSeq == nil then -- 1058
		return {success = false, message = "task not found"} -- 1059
	end -- 1059
	local nextSeq = headSeq + 1 -- 1060
	local checkpointId = insertCheckpoint( -- 1061
		taskId, -- 1061
		nextSeq, -- 1061
		options.summary or "", -- 1061
		options.toolName or "", -- 1061
		"PREPARED" -- 1061
	) -- 1061
	if checkpointId <= 0 then -- 1061
		return {success = false, message = "failed to create checkpoint"} -- 1063
	end -- 1063
	do -- 1063
		local i = 0 -- 1066
		while i < #expandedChanges do -- 1066
			local change = expandedChanges[i + 1] -- 1067
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1068
			if not fullPath then -- 1068
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1070
				return {success = false, message = "invalid path: " .. change.path} -- 1071
			end -- 1071
			local before = getFileState(fullPath) -- 1073
			local afterExists = change.op ~= "delete" -- 1074
			local afterContent = afterExists and (change.content or "") or "" -- 1075
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1076
				checkpointId, -- 1080
				i + 1, -- 1081
				change.path, -- 1082
				change.op, -- 1083
				before.exists and 1 or 0, -- 1084
				before.content, -- 1085
				afterExists and 1 or 0, -- 1086
				afterContent, -- 1087
				before.bytes, -- 1088
				#afterContent -- 1089
			}) -- 1089
			if inserted <= 0 then -- 1089
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1093
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1094
			end -- 1094
			i = i + 1 -- 1066
		end -- 1066
	end -- 1066
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1098
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1099
		if not fullPath then -- 1099
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1101
			return {success = false, message = "invalid path: " .. entry.path} -- 1102
		end -- 1102
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1104
		if not ok then -- 1104
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1106
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1107
		end -- 1107
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1107
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1110
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1111
		end -- 1111
	end -- 1111
	DB:exec( -- 1115
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1115
		{ -- 1117
			"APPLIED", -- 1117
			now(), -- 1117
			checkpointId -- 1117
		} -- 1117
	) -- 1117
	DB:exec( -- 1119
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1119
		{ -- 1121
			nextSeq, -- 1121
			now(), -- 1121
			taskId -- 1121
		} -- 1121
	) -- 1121
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1123
end -- 1033
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1131
	if not isValidWorkDir(workDir) then -- 1131
		return {success = false, message = "invalid workDir"} -- 1132
	end -- 1132
	if checkpointId <= 0 then -- 1132
		return {success = false, message = "invalid checkpointId"} -- 1133
	end -- 1133
	local entries = getCheckpointEntries(checkpointId, true) -- 1134
	if #entries == 0 then -- 1134
		return {success = false, message = "checkpoint not found or empty"} -- 1136
	end -- 1136
	for ____, entry in ipairs(entries) do -- 1138
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1139
		if not fullPath then -- 1139
			return {success = false, message = "invalid path: " .. entry.path} -- 1141
		end -- 1141
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1143
		if not ok then -- 1143
			Log( -- 1145
				"Error", -- 1145
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1145
			) -- 1145
			Log( -- 1146
				"Info", -- 1146
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1146
			) -- 1146
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1147
		end -- 1147
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1147
			Log( -- 1150
				"Error", -- 1150
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1150
			) -- 1150
			Log( -- 1151
				"Info", -- 1151
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1151
			) -- 1151
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1152
		end -- 1152
	end -- 1152
	return {success = true, checkpointId = checkpointId} -- 1155
end -- 1131
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1158
	return getCheckpointEntries(checkpointId, false) -- 1159
end -- 1158
function ____exports.getCheckpointDiff(checkpointId) -- 1162
	if checkpointId <= 0 then -- 1162
		return {success = false, message = "invalid checkpointId"} -- 1164
	end -- 1164
	local entries = getCheckpointEntries(checkpointId, false) -- 1166
	if #entries == 0 then -- 1166
		return {success = false, message = "checkpoint not found or empty"} -- 1168
	end -- 1168
	return { -- 1170
		success = true, -- 1171
		files = __TS__ArrayMap( -- 1172
			entries, -- 1172
			function(____, entry) return { -- 1172
				path = entry.path, -- 1173
				op = entry.op, -- 1174
				beforeExists = entry.beforeExists, -- 1175
				afterExists = entry.afterExists, -- 1176
				beforeContent = entry.beforeContent, -- 1177
				afterContent = entry.afterContent -- 1178
			} end -- 1178
		) -- 1178
	} -- 1178
end -- 1162
function ____exports.build(req) -- 1183
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1183
		local targetRel = req.path or "" -- 1184
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1185
		if not target then -- 1185
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1185
		end -- 1185
		if not Content:exist(target) then -- 1185
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1185
		end -- 1185
		local messages = {} -- 1192
		if not Content:isdir(target) then -- 1192
			local kind = getSupportedBuildKind(target) -- 1194
			if not kind then -- 1194
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1194
			end -- 1194
			if kind == "ts" then -- 1194
				local content = Content:load(target) -- 1199
				if content == nil then -- 1199
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1199
				end -- 1199
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1199
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1199
				end -- 1199
				if not isDtsFile(target) then -- 1199
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1207
				end -- 1207
			else -- 1207
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1210
			end -- 1210
			Log( -- 1212
				"Info", -- 1212
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1212
			) -- 1212
			return ____awaiter_resolve( -- 1212
				nil, -- 1212
				{ -- 1213
					success = true, -- 1214
					messages = __TS__ArrayMap( -- 1215
						messages, -- 1215
						function(____, m) return m.success and __TS__ObjectAssign( -- 1215
							{}, -- 1216
							m, -- 1216
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1216
						) or __TS__ObjectAssign( -- 1216
							{}, -- 1217
							m, -- 1217
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1217
						) end -- 1217
					) -- 1217
				} -- 1217
			) -- 1217
		end -- 1217
		local listResult = ____exports.listFiles({workDir = req.workDir, path = target}) -- 1220
		local relFiles = listResult.success and listResult.files or ({}) -- 1225
		local tsFileData = {} -- 1226
		local buildQueue = {} -- 1227
		for ____, rel in ipairs(relFiles) do -- 1228
			do -- 1228
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1229
				local kind = getSupportedBuildKind(file) -- 1230
				if not kind then -- 1230
					goto __continue244 -- 1231
				end -- 1231
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1232
				if kind ~= "ts" then -- 1232
					goto __continue244 -- 1234
				end -- 1234
				local content = Content:load(file) -- 1236
				if content == nil then -- 1236
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1238
					goto __continue244 -- 1239
				end -- 1239
				tsFileData[file] = content -- 1241
				if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1241
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1243
					goto __continue244 -- 1244
				end -- 1244
			end -- 1244
			::__continue244:: -- 1244
		end -- 1244
		do -- 1244
			local i = 0 -- 1247
			while i < #buildQueue do -- 1247
				do -- 1247
					local ____buildQueue_index_36 = buildQueue[i + 1] -- 1248
					local file = ____buildQueue_index_36.file -- 1248
					local kind = ____buildQueue_index_36.kind -- 1248
					if kind == "ts" then -- 1248
						local content = tsFileData[file] -- 1250
						if content == nil or isDtsFile(file) then -- 1250
							goto __continue251 -- 1252
						end -- 1252
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1254
						goto __continue251 -- 1255
					end -- 1255
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1257
				end -- 1257
				::__continue251:: -- 1257
				i = i + 1 -- 1247
			end -- 1247
		end -- 1247
		Log( -- 1259
			"Info", -- 1259
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1259
		) -- 1259
		return ____awaiter_resolve( -- 1259
			nil, -- 1259
			{ -- 1260
				success = true, -- 1261
				messages = __TS__ArrayMap( -- 1262
					messages, -- 1262
					function(____, m) return m.success and __TS__ObjectAssign( -- 1262
						{}, -- 1263
						m, -- 1263
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1263
					) or __TS__ObjectAssign( -- 1263
						{}, -- 1264
						m, -- 1264
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1264
					) end -- 1264
				) -- 1264
			} -- 1264
		) -- 1264
	end) -- 1264
end -- 1183
return ____exports -- 1183