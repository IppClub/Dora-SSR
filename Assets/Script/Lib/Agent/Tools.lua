-- [ts]: Tools.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local Set = ____lualib.Set -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
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
local DoraLog = ____Dora.Log -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local Node = ____Dora.Node -- 2
local emit = ____Dora.emit -- 2
local wait = ____Dora.wait -- 2
local json = ____Dora.json -- 2
local App = ____Dora.App -- 2
local HttpServer = ____Dora.HttpServer -- 2
function ensureSafeSearchGlobs(globs) -- 607
	local result = {} -- 608
	do -- 608
		local i = 0 -- 609
		while i < #globs do -- 609
			result[#result + 1] = globs[i + 1] -- 610
			i = i + 1 -- 609
		end -- 609
	end -- 609
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 612
	do -- 612
		local i = 0 -- 613
		while i < #requiredExcludes do -- 613
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 613
				result[#result + 1] = requiredExcludes[i + 1] -- 615
			end -- 615
			i = i + 1 -- 613
		end -- 613
	end -- 613
	return result -- 618
end -- 618
local logLevel = 3 -- 4
function ____exports.setLogLevel(level) -- 6
	logLevel = level -- 7
end -- 6
local function Log(____type, msg) -- 10
	if logLevel < 1 then -- 10
		return -- 11
	elseif logLevel < 2 and (____type == "Info" or ____type == "Warn") then -- 11
		return -- 12
	elseif logLevel < 3 and ____type == "Info" then -- 12
		return -- 13
	end -- 13
	DoraLog(____type, msg) -- 14
end -- 10
local TABLE_TASK = "AgentTask" -- 160
local TABLE_CP = "AgentCheckpoint" -- 161
local TABLE_ENTRY = "AgentCheckpointEntry" -- 162
local ENGINE_LOG_SNAPSHOT_DIR = ".agent" -- 163
local ENGINE_LOG_SNAPSHOT_FILE = "engine_logs_snapshot.txt" -- 164
local DORA_DOC_ZH_DIR = Path( -- 165
	Content.assetPath, -- 165
	"Script", -- 165
	"Lib", -- 165
	"Dora", -- 165
	"zh-Hans" -- 165
) -- 165
local DORA_DOC_EN_DIR = Path( -- 166
	Content.assetPath, -- 166
	"Script", -- 166
	"Lib", -- 166
	"Dora", -- 166
	"en" -- 166
) -- 166
local function now() -- 168
	return os.time() -- 168
end -- 168
local function toBool(v) -- 170
	return v ~= 0 and v ~= false and v ~= nil and v ~= nil -- 171
end -- 170
local function toStr(v) -- 174
	if v == false or v == nil or v == nil then -- 174
		return "" -- 175
	end -- 175
	return tostring(v) -- 176
end -- 174
local function isValidWorkspacePath(path) -- 179
	if not path or #path == 0 then -- 179
		return false -- 180
	end -- 180
	if Content:isAbsolutePath(path) then -- 180
		return false -- 181
	end -- 181
	if __TS__StringIncludes(path, "..") then -- 181
		return false -- 182
	end -- 182
	return true -- 183
end -- 179
local function isValidWorkDir(workDir) -- 186
	if not workDir or #workDir == 0 then -- 186
		return false -- 187
	end -- 187
	if not Content:isAbsolutePath(workDir) then -- 187
		return false -- 188
	end -- 188
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 188
		return false -- 189
	end -- 189
	return true -- 190
end -- 186
local function isValidSearchPath(path) -- 193
	if path == "" then -- 193
		return true -- 194
	end -- 194
	if not path or #path == 0 then -- 194
		return false -- 195
	end -- 195
	if __TS__StringIncludes(path, "..") then -- 195
		return false -- 196
	end -- 196
	return true -- 197
end -- 193
local function normalizePathSep(path) -- 200
	return table.concat( -- 201
		__TS__StringSplit(path, "\\"), -- 201
		"/" -- 201
	) -- 201
end -- 200
local function ensureTrailingSlash(path) -- 204
	local p = normalizePathSep(path) -- 205
	return __TS__StringEndsWith(p, "/") and p or p .. "/" -- 206
end -- 204
local function resolveWorkspaceFilePath(workDir, path) -- 209
	if not isValidWorkDir(workDir) then -- 209
		return nil -- 210
	end -- 210
	if not isValidWorkspacePath(path) then -- 210
		return nil -- 211
	end -- 211
	return Path(workDir, path) -- 212
end -- 209
local function resolveWorkspaceSearchPath(workDir, path) -- 215
	if not isValidWorkDir(workDir) then -- 215
		return nil -- 216
	end -- 216
	local root = path or "" -- 217
	if not isValidSearchPath(root) then -- 217
		return nil -- 218
	end -- 218
	return root == "" and workDir or Path(workDir, root) -- 219
end -- 215
local function toWorkspaceRelativePath(workDir, path) -- 222
	if not path or #path == 0 then -- 222
		return path -- 223
	end -- 223
	if not Content:isAbsolutePath(path) then -- 223
		return path -- 224
	end -- 224
	return Path:getRelative(path, workDir) -- 225
end -- 222
local function toWorkspaceRelativeFileList(workDir, files) -- 228
	return __TS__ArrayMap( -- 229
		files, -- 229
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 229
	) -- 229
end -- 228
local function toWorkspaceRelativeSearchResults(workDir, results) -- 232
	local mapped = {} -- 233
	do -- 233
		local i = 0 -- 234
		while i < #results do -- 234
			local row = results[i + 1] -- 235
			if type(row) == "table" then -- 235
				local clone = {} -- 237
				for k in pairs(row) do -- 238
					clone[k] = row[k] -- 239
				end -- 239
				if type(clone.file) == "string" then -- 239
					clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 242
				end -- 242
				if type(clone.path) == "string" then -- 242
					clone.path = toWorkspaceRelativePath(workDir, clone.path) -- 245
				end -- 245
				mapped[#mapped + 1] = clone -- 247
			else -- 247
				mapped[#mapped + 1] = results[i + 1] -- 249
			end -- 249
			i = i + 1 -- 234
		end -- 234
	end -- 234
	return mapped -- 252
end -- 232
local function getDoraDocRoot(docLanguage) -- 255
	return docLanguage == "zh" and DORA_DOC_ZH_DIR or DORA_DOC_EN_DIR -- 256
end -- 255
local function getDoraDocExtsByCodeLanguage(programmingLanguage) -- 259
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 259
		return {"ts"} -- 261
	end -- 261
	return {"tl"} -- 263
end -- 259
local function toDocRelativePath(docRoot, file) -- 266
	return Path:getRelative(file, docRoot) -- 267
end -- 266
local function ensureDirPath(dir) -- 270
	if not dir or dir == "." or dir == "" then -- 270
		return true -- 271
	end -- 271
	if Content:exist(dir) then -- 271
		return Content:isdir(dir) -- 272
	end -- 272
	local parent = Path:getPath(dir) -- 273
	if parent and parent ~= dir and parent ~= "." and parent ~= "" then -- 273
		if not ensureDirPath(parent) then -- 273
			return false -- 275
		end -- 275
	end -- 275
	return Content:mkdir(dir) -- 277
end -- 270
local function ensureDirForFile(path) -- 280
	local dir = Path:getPath(path) -- 281
	return ensureDirPath(dir) -- 282
end -- 280
local function getFileState(path) -- 285
	local exists = Content:exist(path) -- 286
	if not exists then -- 286
		return {exists = false, content = "", bytes = 0} -- 288
	end -- 288
	local content = Content:load(path) -- 294
	return {exists = true, content = content, bytes = #content} -- 295
end -- 285
local function queryOne(sql, args) -- 302
	local ____args_0 -- 303
	if args then -- 303
		____args_0 = DB:query(sql, args) -- 303
	else -- 303
		____args_0 = DB:query(sql) -- 303
	end -- 303
	local rows = ____args_0 -- 303
	if not rows or #rows == 0 then -- 303
		return nil -- 304
	end -- 304
	return rows[1] -- 305
end -- 302
do -- 302
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 310
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 318
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 329
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 330
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 343
end -- 343
local function isTsLikeFile(path) -- 346
	local ext = Path:getExt(path) -- 347
	return ext == "ts" or ext == "tsx" -- 348
end -- 346
local function isDtsFile(path) -- 351
	return Path:getExt(Path:getName(path)) == "d" -- 352
end -- 351
local function getTaskHeadSeq(taskId) -- 355
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 356
	if not row then -- 356
		return nil -- 357
	end -- 357
	return row[1] or 0 -- 358
end -- 355
local function getTaskStatus(taskId) -- 361
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 362
	if not row then -- 362
		return nil -- 363
	end -- 363
	return toStr(row[1]) -- 364
end -- 361
local function getLastInsertRowId() -- 367
	local row = queryOne("SELECT last_insert_rowid()") -- 368
	return row and (row[1] or 0) or 0 -- 369
end -- 367
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 372
	DB:exec( -- 373
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 373
		{ -- 375
			taskId, -- 375
			seq, -- 375
			status, -- 375
			summary, -- 375
			toolName, -- 375
			now() -- 375
		} -- 375
	) -- 375
	return getLastInsertRowId() -- 377
end -- 372
local function getCheckpointEntries(checkpointId, desc) -- 380
	if desc == nil then -- 380
		desc = false -- 380
	end -- 380
	local rows = DB:query((("SELECT id, ord, path, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 381
	if not rows then -- 381
		return {} -- 388
	end -- 388
	local result = {} -- 389
	do -- 389
		local i = 0 -- 390
		while i < #rows do -- 390
			local row = rows[i + 1] -- 391
			result[#result + 1] = { -- 392
				id = row[1], -- 393
				ord = row[2], -- 394
				path = toStr(row[3]), -- 395
				beforeExists = toBool(row[4]), -- 396
				beforeContent = toStr(row[5]), -- 397
				afterExists = toBool(row[6]), -- 398
				afterContent = toStr(row[7]) -- 399
			} -- 399
			i = i + 1 -- 390
		end -- 390
	end -- 390
	return result -- 402
end -- 380
local function rejectDuplicatePaths(changes) -- 405
	local seen = __TS__New(Set) -- 406
	for ____, change in ipairs(changes) do -- 407
		local key = change.path -- 408
		if seen:has(key) then -- 408
			return key -- 409
		end -- 409
		seen:add(key) -- 410
	end -- 410
	return nil -- 412
end -- 405
local function applySingleFile(path, exists, content) -- 415
	if exists then -- 415
		if not ensureDirForFile(path) then -- 415
			return false -- 417
		end -- 417
		return Content:save(path, content) -- 418
	end -- 418
	if Content:exist(path) then -- 418
		return Content:remove(path) -- 421
	end -- 421
	return true -- 423
end -- 415
local function encodeJSON(obj) -- 426
	local text = json.encode(obj) -- 427
	return text -- 428
end -- 426
function ____exports.runSingleTsTranspile(file, content, timeoutSec) -- 431
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 431
		local done = false -- 432
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 433
		if HttpServer.wsConnectionCount == 0 then -- 433
			return ____awaiter_resolve(nil, result) -- 433
		end -- 433
		local listener = Node() -- 441
		listener:gslot( -- 442
			"AppWS", -- 442
			function(event) -- 442
				if event.type ~= "Receive" then -- 442
					return -- 443
				end -- 443
				local res = json.decode(event.msg) -- 444
				if not res or __TS__ArrayIsArray(res) or res.name ~= "TranspileTS" then -- 444
					return -- 445
				end -- 445
				if res.success then -- 445
					local luaFile = Path:replaceExt(file, "lua") -- 447
					if Content:save( -- 447
						luaFile, -- 448
						tostring(res.luaCode) -- 448
					) then -- 448
						result = {success = true, file = file} -- 449
					else -- 449
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 451
					end -- 451
				else -- 451
					result = { -- 454
						success = false, -- 454
						file = file, -- 454
						message = tostring(res.message) -- 454
					} -- 454
				end -- 454
				done = true -- 456
			end -- 442
		) -- 442
		local payload = encodeJSON({name = "TranspileTS", file = file, content = content}) -- 458
		if not payload then -- 458
			listener:removeFromParent() -- 464
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 464
		end -- 464
		__TS__Await(__TS__New( -- 467
			__TS__Promise, -- 467
			function(____, resolve) -- 467
				listener:once(function() -- 468
					emit("AppWS", "Send", payload) -- 469
					local start = App.runningTime -- 470
					wait(function() return done or App.runningTime - start >= timeoutSec end) -- 471
					if not done then -- 471
						listener:removeFromParent() -- 473
					end -- 473
					resolve(nil) -- 475
				end) -- 468
			end -- 467
		)) -- 467
		return ____awaiter_resolve(nil, result) -- 467
	end) -- 467
end -- 431
function ____exports.createTask(prompt) -- 481
	if prompt == nil then -- 481
		prompt = "" -- 481
	end -- 481
	local t = now() -- 482
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 483
	if affected <= 0 then -- 483
		return {success = false, message = "failed to create task"} -- 488
	end -- 488
	return { -- 490
		success = true, -- 490
		taskId = getLastInsertRowId() -- 490
	} -- 490
end -- 481
function ____exports.setTaskStatus(taskId, status) -- 493
	DB:exec( -- 494
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 494
		{ -- 494
			status, -- 494
			now(), -- 494
			taskId -- 494
		} -- 494
	) -- 494
	Log( -- 495
		"Info", -- 495
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 495
	) -- 495
end -- 493
function ____exports.listCheckpoints(taskId) -- 498
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 499
	if not rows then -- 499
		return {} -- 506
	end -- 506
	local items = {} -- 507
	do -- 507
		local i = 0 -- 508
		while i < #rows do -- 508
			local row = rows[i + 1] -- 509
			items[#items + 1] = { -- 510
				id = row[1], -- 511
				taskId = row[2], -- 512
				seq = row[3], -- 513
				status = toStr(row[4]), -- 514
				summary = toStr(row[5]), -- 515
				toolName = toStr(row[6]), -- 516
				createdAt = row[7] -- 517
			} -- 517
			i = i + 1 -- 508
		end -- 508
	end -- 508
	return items -- 520
end -- 498
local function readWorkspaceFile(workDir, path) -- 523
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 524
	if not fullPath then -- 524
		return {success = false, message = "invalid path or workDir"} -- 525
	end -- 525
	if not Content:exist(fullPath) or Content:isdir(fullPath) then -- 525
		return {success = false, message = "file not found"} -- 526
	end -- 526
	return { -- 527
		success = true, -- 527
		content = Content:load(fullPath) -- 527
	} -- 527
end -- 523
function ____exports.readFile(workDir, path) -- 530
	local result = readWorkspaceFile(workDir, path) -- 531
	if not result.success and Content:exist(path) then -- 531
		return { -- 533
			success = true, -- 533
			content = Content:load(path) -- 533
		} -- 533
	end -- 533
	return result -- 535
end -- 530
local function getEngineLogText() -- 538
	local folder = Path(Content.writablePath, ENGINE_LOG_SNAPSHOT_DIR) -- 539
	if not Content:exist(folder) then -- 539
		Content:mkdir(folder) -- 541
	end -- 541
	local logPath = Path(folder, ENGINE_LOG_SNAPSHOT_FILE) -- 543
	if not App:saveLog(logPath) then -- 543
		return nil -- 545
	end -- 545
	return Content:load(logPath) -- 547
end -- 538
function ____exports.getLogs(req) -- 550
	local text = getEngineLogText() -- 551
	if text == nil or text == nil then -- 551
		return {success = false, message = "failed to read engine logs"} -- 553
	end -- 553
	local tailLines = math.max( -- 555
		1, -- 555
		math.floor(req and req.tailLines or 200) -- 555
	) -- 555
	local allLines = __TS__StringSplit(text, "\n") -- 556
	local logs = __TS__ArraySlice( -- 557
		allLines, -- 557
		math.max(0, #allLines - tailLines) -- 557
	) -- 557
	return req and req.joinText and ({ -- 558
		success = true, -- 558
		logs = logs, -- 558
		text = table.concat(logs, "\n") -- 558
	}) or ({success = true, logs = logs}) -- 558
end -- 550
function ____exports.listFiles(req) -- 561
	local root = req.path or "" -- 566
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 567
	if not searchRoot then -- 567
		return {success = false, message = "invalid path or workDir"} -- 569
	end -- 569
	do -- 569
		local function ____catch(e) -- 569
			return true, { -- 578
				success = false, -- 578
				message = tostring(e) -- 578
			} -- 578
		end -- 578
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 578
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 572
			local globs = ensureSafeSearchGlobs(userGlobs) -- 573
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 574
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 575
			return true, {success = true, files = files} -- 576
		end) -- 576
		if not ____try then -- 576
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 576
		end -- 576
		if ____hasReturned then -- 576
			return ____returnValue -- 571
		end -- 571
	end -- 571
end -- 561
function ____exports.readFileRange(workDir, path, startLine, endLine) -- 582
	local res = ____exports.readFile(workDir, path) -- 583
	if not res.success or res.content == nil then -- 583
		return res -- 584
	end -- 584
	local s = math.max( -- 585
		1, -- 585
		math.floor(startLine) -- 585
	) -- 585
	local e = math.max( -- 586
		s, -- 586
		math.floor(endLine) -- 586
	) -- 586
	local lines = __TS__StringSplit(res.content, "\n") -- 587
	local part = {} -- 588
	do -- 588
		local i = s -- 589
		while i <= e and i <= #lines do -- 589
			part[#part + 1] = lines[i] -- 590
			i = i + 1 -- 589
		end -- 589
	end -- 589
	return { -- 592
		success = true, -- 592
		content = table.concat(part, "\n") -- 592
	} -- 592
end -- 582
local codeExtensions = { -- 595
	".lua", -- 595
	".tl", -- 595
	".yue", -- 595
	".ts", -- 595
	".tsx", -- 595
	".xml", -- 595
	".md", -- 595
	".yarn", -- 595
	".wa", -- 595
	".mod" -- 595
} -- 595
extensionLevels = { -- 596
	vs = 2, -- 597
	bl = 2, -- 598
	ts = 1, -- 599
	tsx = 1, -- 600
	tl = 1, -- 601
	yue = 1, -- 602
	xml = 1, -- 603
	lua = 0 -- 604
} -- 604
local function splitSearchPatterns(pattern) -- 621
	local trimmed = __TS__StringTrim(pattern or "") -- 622
	if trimmed == "" then -- 622
		return {} -- 623
	end -- 623
	local out = {} -- 624
	for p0 in string.gmatch(trimmed, "%S+") do -- 625
		local p = __TS__StringTrim(tostring(p0)) -- 626
		if p ~= "" then -- 626
			out[#out + 1] = p -- 627
		end -- 627
	end -- 627
	return out -- 629
end -- 621
local function mergeSearchFileResultsUnique(resultsList) -- 632
	local merged = {} -- 633
	local seen = __TS__New(Set) -- 634
	do -- 634
		local i = 0 -- 635
		while i < #resultsList do -- 635
			local list = resultsList[i + 1] -- 636
			do -- 636
				local j = 0 -- 637
				while j < #list do -- 637
					do -- 637
						local row = list[j + 1] -- 638
						local ____temp_17 -- 639
						if type(row) == "table" then -- 639
							local ____tostring_7 = tostring -- 640
							local ____row_file_5 = row.file -- 640
							if ____row_file_5 == nil then -- 640
								____row_file_5 = row.path -- 640
							end -- 640
							local ____row_file_5_6 = ____row_file_5 -- 640
							if ____row_file_5_6 == nil then -- 640
								____row_file_5_6 = "" -- 640
							end -- 640
							local ____tostring_7_result_14 = ____tostring_7(____row_file_5_6) -- 640
							local ____tostring_9 = tostring -- 640
							local ____row_pos_8 = row.pos -- 640
							if ____row_pos_8 == nil then -- 640
								____row_pos_8 = "" -- 640
							end -- 640
							local ____tostring_9_result_15 = ____tostring_9(____row_pos_8) -- 640
							local ____tostring_11 = tostring -- 640
							local ____row_line_10 = row.line -- 640
							if ____row_line_10 == nil then -- 640
								____row_line_10 = "" -- 640
							end -- 640
							local ____tostring_11_result_16 = ____tostring_11(____row_line_10) -- 640
							local ____tostring_13 = tostring -- 640
							local ____row_column_12 = row.column -- 640
							if ____row_column_12 == nil then -- 640
								____row_column_12 = "" -- 640
							end -- 640
							____temp_17 = (((((____tostring_7_result_14 .. ":") .. ____tostring_9_result_15) .. ":") .. ____tostring_11_result_16) .. ":") .. ____tostring_13(____row_column_12) -- 640
						else -- 640
							____temp_17 = tostring(j) -- 641
						end -- 641
						local key = ____temp_17 -- 639
						if seen:has(key) then -- 639
							goto __continue134 -- 642
						end -- 642
						seen:add(key) -- 643
						merged[#merged + 1] = list[j + 1] -- 644
					end -- 644
					::__continue134:: -- 644
					j = j + 1 -- 637
				end -- 637
			end -- 637
			i = i + 1 -- 635
		end -- 635
	end -- 635
	return merged -- 647
end -- 632
local function mergeDoraAPISearchHitsUnique(resultsList, topK) -- 650
	local merged = {} -- 651
	local seen = __TS__New(Set) -- 652
	do -- 652
		local i = 0 -- 653
		while i < #resultsList and #merged < topK do -- 653
			local list = resultsList[i + 1] -- 654
			do -- 654
				local j = 0 -- 655
				while j < #list and #merged < topK do -- 655
					do -- 655
						local row = list[j + 1] -- 656
						local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 657
						if seen:has(key) then -- 657
							goto __continue140 -- 658
						end -- 658
						seen:add(key) -- 659
						merged[#merged + 1] = row -- 660
					end -- 660
					::__continue140:: -- 660
					j = j + 1 -- 655
				end -- 655
			end -- 655
			i = i + 1 -- 653
		end -- 653
	end -- 653
	return merged -- 663
end -- 650
function ____exports.searchFiles(req) -- 666
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 666
		local searchRoot = resolveWorkspaceSearchPath(req.workDir, req.path) -- 676
		if not searchRoot then -- 676
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 676
		end -- 676
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 676
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 676
		end -- 676
		local patterns = splitSearchPatterns(req.pattern) -- 683
		if #patterns == 0 then -- 683
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 683
		end -- 683
		return ____awaiter_resolve( -- 683
			nil, -- 683
			__TS__New( -- 687
				__TS__Promise, -- 687
				function(____, resolve) -- 687
					Director.systemScheduler:schedule(once(function() -- 688
						do -- 688
							local function ____catch(e) -- 688
								resolve( -- 707
									nil, -- 707
									{ -- 707
										success = false, -- 707
										message = tostring(e) -- 707
									} -- 707
								) -- 707
							end -- 707
							local ____try, ____hasReturned = pcall(function() -- 707
								local allResults = {} -- 690
								do -- 690
									local i = 0 -- 691
									while i < #patterns do -- 691
										local ____Content_23 = Content -- 692
										local ____Content_searchFilesAsync_24 = Content.searchFilesAsync -- 692
										local ____ensureSafeSearchGlobs_result_21 = ensureSafeSearchGlobs(req.globs or ({"**"})) -- 696
										local ____patterns_index_22 = patterns[i + 1] -- 697
										local ____req_useRegex_18 = req.useRegex -- 698
										if ____req_useRegex_18 == nil then -- 698
											____req_useRegex_18 = false -- 698
										end -- 698
										local ____req_caseSensitive_19 = req.caseSensitive -- 699
										if ____req_caseSensitive_19 == nil then -- 699
											____req_caseSensitive_19 = false -- 699
										end -- 699
										local ____req_includeContent_20 = req.includeContent -- 700
										if ____req_includeContent_20 == nil then -- 700
											____req_includeContent_20 = true -- 700
										end -- 700
										allResults[#allResults + 1] = ____Content_searchFilesAsync_24( -- 692
											____Content_23, -- 692
											searchRoot, -- 693
											codeExtensions, -- 694
											extensionLevels, -- 695
											____ensureSafeSearchGlobs_result_21, -- 696
											____patterns_index_22, -- 697
											____req_useRegex_18, -- 698
											____req_caseSensitive_19, -- 699
											____req_includeContent_20, -- 700
											req.contentWindow or 120 -- 701
										) -- 701
										i = i + 1 -- 691
									end -- 691
								end -- 691
								local results = mergeSearchFileResultsUnique(allResults) -- 704
								resolve( -- 705
									nil, -- 705
									{ -- 705
										success = true, -- 705
										results = toWorkspaceRelativeSearchResults(req.workDir, results) -- 705
									} -- 705
								) -- 705
							end) -- 705
							if not ____try then -- 705
								____catch(____hasReturned) -- 705
							end -- 705
						end -- 705
					end)) -- 688
				end -- 687
			) -- 687
		) -- 687
	end) -- 687
end -- 666
function ____exports.searchDoraAPI(req) -- 713
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 713
		local pattern = __TS__StringTrim(req.pattern or "") -- 723
		if pattern == "" then -- 723
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 723
		end -- 723
		local patterns = splitSearchPatterns(pattern) -- 725
		if #patterns == 0 then -- 725
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 725
		end -- 725
		local docRoot = getDoraDocRoot(req.docLanguage) -- 727
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 727
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 727
		end -- 727
		local exts = getDoraDocExtsByCodeLanguage(req.programmingLanguage) -- 731
		local dotExts = __TS__ArrayMap( -- 732
			exts, -- 732
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 732
		) -- 732
		local globs = __TS__ArrayMap( -- 733
			exts, -- 733
			function(____, ext) return "**/*." .. ext end -- 733
		) -- 733
		local topK = math.max( -- 734
			1, -- 734
			math.floor(req.topK or 10) -- 734
		) -- 734
		return ____awaiter_resolve( -- 734
			nil, -- 734
			__TS__New( -- 736
				__TS__Promise, -- 736
				function(____, resolve) -- 736
					Director.systemScheduler:schedule(once(function() -- 737
						do -- 737
							local function ____catch(e) -- 737
								resolve( -- 777
									nil, -- 777
									{ -- 777
										success = false, -- 777
										message = tostring(e) -- 777
									} -- 777
								) -- 777
							end -- 777
							local ____try, ____hasReturned = pcall(function() -- 777
								local allHits = {} -- 739
								do -- 739
									local p = 0 -- 740
									while p < #patterns do -- 740
										local ____Content_29 = Content -- 741
										local ____Content_searchFilesAsync_30 = Content.searchFilesAsync -- 741
										local ____array_28 = __TS__SparseArrayNew( -- 741
											docRoot, -- 742
											dotExts, -- 743
											{}, -- 744
											ensureSafeSearchGlobs(globs), -- 745
											patterns[p + 1] -- 746
										) -- 746
										local ____req_useRegex_25 = req.useRegex -- 747
										if ____req_useRegex_25 == nil then -- 747
											____req_useRegex_25 = false -- 747
										end -- 747
										__TS__SparseArrayPush(____array_28, ____req_useRegex_25) -- 747
										local ____req_caseSensitive_26 = req.caseSensitive -- 748
										if ____req_caseSensitive_26 == nil then -- 748
											____req_caseSensitive_26 = false -- 748
										end -- 748
										__TS__SparseArrayPush(____array_28, ____req_caseSensitive_26) -- 748
										local ____req_includeContent_27 = req.includeContent -- 749
										if ____req_includeContent_27 == nil then -- 749
											____req_includeContent_27 = true -- 749
										end -- 749
										__TS__SparseArrayPush(____array_28, ____req_includeContent_27, req.contentWindow or 140) -- 749
										local raw = ____Content_searchFilesAsync_30( -- 741
											____Content_29, -- 741
											__TS__SparseArraySpread(____array_28) -- 741
										) -- 741
										local hits = {} -- 752
										do -- 752
											local i = 0 -- 753
											while i < #raw do -- 753
												do -- 753
													local row = raw[i + 1] -- 754
													if type(row) ~= "table" then -- 754
														goto __continue164 -- 755
													end -- 755
													local file = type(row.file) == "string" and toDocRelativePath(docRoot, row.file) or (type(row.path) == "string" and toDocRelativePath(docRoot, row.path) or "") -- 756
													if file == "" then -- 756
														goto __continue164 -- 759
													end -- 759
													hits[#hits + 1] = { -- 760
														file = file, -- 761
														line = type(row.line) == "number" and row.line or nil, -- 762
														content = type(row.content) == "string" and row.content or nil -- 763
													} -- 763
												end -- 763
												::__continue164:: -- 763
												i = i + 1 -- 753
											end -- 753
										end -- 753
										allHits[#allHits + 1] = hits -- 766
										p = p + 1 -- 740
									end -- 740
								end -- 740
								local hits = mergeDoraAPISearchHitsUnique(allHits, topK) -- 768
								resolve(nil, { -- 769
									success = true, -- 770
									docLanguage = req.docLanguage, -- 771
									root = docRoot, -- 772
									exts = exts, -- 773
									results = hits -- 774
								}) -- 774
							end) -- 774
							if not ____try then -- 774
								____catch(____hasReturned) -- 774
							end -- 774
						end -- 774
					end)) -- 737
				end -- 736
			) -- 736
		) -- 736
	end) -- 736
end -- 713
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 783
	if options == nil then -- 783
		options = {} -- 783
	end -- 783
	if #changes == 0 then -- 783
		return {success = false, message = "empty changes"} -- 785
	end -- 785
	if not isValidWorkDir(workDir) then -- 785
		return {success = false, message = "invalid workDir"} -- 788
	end -- 788
	if not getTaskStatus(taskId) then -- 788
		return {success = false, message = "task not found"} -- 791
	end -- 791
	local dup = rejectDuplicatePaths(changes) -- 793
	if dup then -- 793
		return {success = false, message = "duplicate path in batch: " .. dup} -- 795
	end -- 795
	for ____, change in ipairs(changes) do -- 798
		if not isValidWorkspacePath(change.path) then -- 798
			return {success = false, message = "invalid path: " .. change.path} -- 800
		end -- 800
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 800
			return {success = false, message = "missing content for " .. change.path} -- 803
		end -- 803
	end -- 803
	local headSeq = getTaskHeadSeq(taskId) -- 807
	if headSeq == nil then -- 807
		return {success = false, message = "task not found"} -- 808
	end -- 808
	local nextSeq = headSeq + 1 -- 809
	local checkpointId = insertCheckpoint( -- 810
		taskId, -- 810
		nextSeq, -- 810
		options.summary or "", -- 810
		options.toolName or "", -- 810
		"PREPARED" -- 810
	) -- 810
	if checkpointId <= 0 then -- 810
		return {success = false, message = "failed to create checkpoint"} -- 812
	end -- 812
	do -- 812
		local i = 0 -- 815
		while i < #changes do -- 815
			local change = changes[i + 1] -- 816
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 817
			if not fullPath then -- 817
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 819
				return {success = false, message = "invalid path: " .. change.path} -- 820
			end -- 820
			local before = getFileState(fullPath) -- 822
			local afterExists = change.op ~= "delete" -- 823
			local afterContent = afterExists and (change.content or "") or "" -- 824
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 825
				checkpointId, -- 829
				i + 1, -- 830
				change.path, -- 831
				change.op, -- 832
				before.exists and 1 or 0, -- 833
				before.content, -- 834
				afterExists and 1 or 0, -- 835
				afterContent, -- 836
				before.bytes, -- 837
				#afterContent -- 838
			}) -- 838
			if inserted <= 0 then -- 838
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 842
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 843
			end -- 843
			i = i + 1 -- 815
		end -- 815
	end -- 815
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 847
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 848
		if not fullPath then -- 848
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 850
			return {success = false, message = "invalid path: " .. entry.path} -- 851
		end -- 851
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 853
		if not ok then -- 853
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 855
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 856
		end -- 856
	end -- 856
	DB:exec( -- 860
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 860
		{ -- 862
			"APPLIED", -- 862
			now(), -- 862
			checkpointId -- 862
		} -- 862
	) -- 862
	DB:exec( -- 864
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 864
		{ -- 866
			nextSeq, -- 866
			now(), -- 866
			taskId -- 866
		} -- 866
	) -- 866
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 868
end -- 783
function ____exports.rollbackToCheckpoint(taskId, workDir, targetSeq) -- 876
	if not isValidWorkDir(workDir) then -- 876
		return {success = false, message = "invalid workDir"} -- 877
	end -- 877
	local headSeq = getTaskHeadSeq(taskId) -- 878
	if headSeq == nil then -- 878
		return {success = false, message = "task not found"} -- 879
	end -- 879
	if targetSeq < 0 or targetSeq > headSeq then -- 879
		return {success = false, message = "invalid target seq"} -- 881
	end -- 881
	if targetSeq == headSeq then -- 881
		return {success = true, headSeq = headSeq} -- 884
	end -- 884
	local cps = DB:query(("SELECT id, seq FROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status = ? AND seq > ? AND seq <= ?\n\t\tORDER BY seq DESC", {taskId, "APPLIED", targetSeq, headSeq}) -- 887
	if not cps then -- 887
		return {success = false, message = "failed to query checkpoints"} -- 893
	end -- 893
	do -- 893
		local i = 0 -- 895
		while i < #cps do -- 895
			local cpId = cps[i + 1][1] -- 896
			local cpSeq = cps[i + 1][2] -- 897
			local entries = getCheckpointEntries(cpId, true) -- 898
			for ____, entry in ipairs(entries) do -- 899
				local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 900
				if not fullPath then -- 900
					return {success = false, message = "invalid path: " .. entry.path} -- 902
				end -- 902
				local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 904
				if not ok then -- 904
					Log( -- 906
						"Error", -- 906
						(("Agent rollback failed at checkpoint " .. tostring(cpSeq)) .. ", file ") .. entry.path -- 906
					) -- 906
					Log( -- 907
						"Info", -- 907
						(("[rollback] failed checkpoint=" .. tostring(cpSeq)) .. " file=") .. entry.path -- 907
					) -- 907
					return {success = false, message = "failed to rollback file: " .. entry.path} -- 908
				end -- 908
			end -- 908
			DB:exec( -- 911
				("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 911
				{ -- 913
					"REVERTED", -- 913
					now(), -- 913
					cpId -- 913
				} -- 913
			) -- 913
			i = i + 1 -- 895
		end -- 895
	end -- 895
	DB:exec( -- 917
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 917
		{ -- 919
			targetSeq, -- 919
			now(), -- 919
			taskId -- 919
		} -- 919
	) -- 919
	return {success = true, headSeq = targetSeq} -- 921
end -- 876
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 924
	return getCheckpointEntries(checkpointId, false) -- 925
end -- 924
function ____exports.runTsBuild(req) -- 928
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 928
		local targetRel = req.path or "" -- 929
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 930
		local timeoutSec = math.max( -- 931
			1, -- 931
			math.floor(req.timeoutSec or 20) -- 931
		) -- 931
		if not target then -- 931
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 931
		end -- 931
		if not Content:exist(target) then -- 931
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 931
		end -- 931
		local messages = {} -- 938
		if not Content:isdir(target) then -- 938
			if not isTsLikeFile(target) then -- 938
				return ____awaiter_resolve(nil, {success = false, message = "expecting a TypeScript file"}) -- 938
			end -- 938
			local content = Content:load(target) -- 943
			if content == nil or content == nil then -- 943
				return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 943
			end -- 943
			local updatePayload = encodeJSON({name = "UpdateTSCode", file = target, content = content}) -- 947
			if not updatePayload then -- 947
				return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateTSCode request"}) -- 947
			end -- 947
			emit("AppWS", "Send", updatePayload) -- 951
			if not isDtsFile(target) then -- 951
				messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, timeoutSec)) -- 953
			end -- 953
			Log( -- 955
				"Info", -- 955
				(("[ts_build] file=" .. target) .. " messages=") .. tostring(#messages) -- 955
			) -- 955
			return ____awaiter_resolve( -- 955
				nil, -- 955
				{ -- 956
					success = true, -- 957
					messages = __TS__ArrayMap( -- 958
						messages, -- 958
						function(____, m) return m.success and __TS__ObjectAssign( -- 958
							{}, -- 959
							m, -- 959
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 959
						) or __TS__ObjectAssign( -- 959
							{}, -- 960
							m, -- 960
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 960
						) end -- 960
					) -- 960
				} -- 960
			) -- 960
		end -- 960
		local relFiles = Content:getAllFiles(target) -- 964
		local fileData = {} -- 965
		for ____, rel in ipairs(relFiles) do -- 966
			do -- 966
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 967
				if not isTsLikeFile(file) then -- 967
					goto __continue209 -- 968
				end -- 968
				local content = Content:load(file) -- 969
				if content == nil or content == nil then -- 969
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 971
					goto __continue209 -- 972
				end -- 972
				fileData[file] = content -- 974
				local updatePayload = encodeJSON({name = "UpdateTSCode", file = file, content = content}) -- 975
				if not updatePayload then -- 975
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateTSCode request"} -- 977
					goto __continue209 -- 978
				end -- 978
				emit("AppWS", "Send", updatePayload) -- 980
			end -- 980
			::__continue209:: -- 980
		end -- 980
		for file in pairs(fileData) do -- 982
			do -- 982
				if isDtsFile(file) then -- 982
					goto __continue214 -- 983
				end -- 983
				messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, fileData[file], timeoutSec)) -- 984
			end -- 984
			::__continue214:: -- 984
		end -- 984
		Log( -- 986
			"Info", -- 986
			(("[ts_build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 986
		) -- 986
		return ____awaiter_resolve( -- 986
			nil, -- 986
			{ -- 987
				success = true, -- 988
				messages = __TS__ArrayMap( -- 989
					messages, -- 989
					function(____, m) return m.success and __TS__ObjectAssign( -- 989
						{}, -- 990
						m, -- 990
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 990
					) or __TS__ObjectAssign( -- 990
						{}, -- 991
						m, -- 991
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 991
					) end -- 991
				) -- 991
			} -- 991
		) -- 991
	end) -- 991
end -- 928
return ____exports -- 928