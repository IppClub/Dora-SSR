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
function ensureSafeSearchGlobs(globs) -- 594
	local result = {} -- 595
	do -- 595
		local i = 0 -- 596
		while i < #globs do -- 596
			result[#result + 1] = globs[i + 1] -- 597
			i = i + 1 -- 596
		end -- 596
	end -- 596
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 599
	do -- 599
		local i = 0 -- 600
		while i < #requiredExcludes do -- 600
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 600
				result[#result + 1] = requiredExcludes[i + 1] -- 602
			end -- 602
			i = i + 1 -- 600
		end -- 600
	end -- 600
	return result -- 605
end -- 605
local TABLE_TASK = "AgentTask" -- 148
local TABLE_CP = "AgentCheckpoint" -- 149
local TABLE_ENTRY = "AgentCheckpointEntry" -- 150
local ENGINE_LOG_SNAPSHOT_DIR = ".agent" -- 151
local ENGINE_LOG_SNAPSHOT_FILE = "engine_logs_snapshot.txt" -- 152
local DORA_DOC_ZH_DIR = Path( -- 153
	Content.assetPath, -- 153
	"Script", -- 153
	"Lib", -- 153
	"Dora", -- 153
	"zh-Hans" -- 153
) -- 153
local DORA_DOC_EN_DIR = Path( -- 154
	Content.assetPath, -- 154
	"Script", -- 154
	"Lib", -- 154
	"Dora", -- 154
	"en" -- 154
) -- 154
local function now() -- 156
	return os.time() -- 156
end -- 156
local function toBool(v) -- 158
	return v ~= 0 and v ~= false and v ~= nil and v ~= nil -- 159
end -- 158
local function toStr(v) -- 162
	if v == false or v == nil or v == nil then -- 162
		return "" -- 163
	end -- 163
	return tostring(v) -- 164
end -- 162
local function isValidWorkspacePath(path) -- 167
	if not path or #path == 0 then -- 167
		return false -- 168
	end -- 168
	if Content:isAbsolutePath(path) then -- 168
		return false -- 169
	end -- 169
	if __TS__StringIncludes(path, "..") then -- 169
		return false -- 170
	end -- 170
	return true -- 171
end -- 167
local function isValidWorkDir(workDir) -- 174
	if not workDir or #workDir == 0 then -- 174
		return false -- 175
	end -- 175
	if not Content:isAbsolutePath(workDir) then -- 175
		return false -- 176
	end -- 176
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 176
		return false -- 177
	end -- 177
	return true -- 178
end -- 174
local function isValidSearchPath(path) -- 181
	if path == "" then -- 181
		return true -- 182
	end -- 182
	if not path or #path == 0 then -- 182
		return false -- 183
	end -- 183
	if __TS__StringIncludes(path, "..") then -- 183
		return false -- 184
	end -- 184
	return true -- 185
end -- 181
local function normalizePathSep(path) -- 188
	return table.concat( -- 189
		__TS__StringSplit(path, "\\"), -- 189
		"/" -- 189
	) -- 189
end -- 188
local function ensureTrailingSlash(path) -- 192
	local p = normalizePathSep(path) -- 193
	return __TS__StringEndsWith(p, "/") and p or p .. "/" -- 194
end -- 192
local function resolveWorkspaceFilePath(workDir, path) -- 197
	if not isValidWorkDir(workDir) then -- 197
		return nil -- 198
	end -- 198
	if not isValidWorkspacePath(path) then -- 198
		return nil -- 199
	end -- 199
	return Path(workDir, path) -- 200
end -- 197
local function resolveWorkspaceSearchPath(workDir, path) -- 203
	if not isValidWorkDir(workDir) then -- 203
		return nil -- 204
	end -- 204
	local root = path or "" -- 205
	if not isValidSearchPath(root) then -- 205
		return nil -- 206
	end -- 206
	return root == "" and workDir or Path(workDir, root) -- 207
end -- 203
local function toWorkspaceRelativePath(workDir, path) -- 210
	if not path or #path == 0 then -- 210
		return path -- 211
	end -- 211
	if not Content:isAbsolutePath(path) then -- 211
		return path -- 212
	end -- 212
	return Path:getRelative(path, workDir) -- 213
end -- 210
local function toWorkspaceRelativeFileList(workDir, files) -- 216
	return __TS__ArrayMap( -- 217
		files, -- 217
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 217
	) -- 217
end -- 216
local function toWorkspaceRelativeSearchResults(workDir, results) -- 220
	local mapped = {} -- 221
	do -- 221
		local i = 0 -- 222
		while i < #results do -- 222
			local row = results[i + 1] -- 223
			if type(row) == "table" then -- 223
				local clone = {} -- 225
				for k in pairs(row) do -- 226
					clone[k] = row[k] -- 227
				end -- 227
				if type(clone.file) == "string" then -- 227
					clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 230
				end -- 230
				if type(clone.path) == "string" then -- 230
					clone.path = toWorkspaceRelativePath(workDir, clone.path) -- 233
				end -- 233
				mapped[#mapped + 1] = clone -- 235
			else -- 235
				mapped[#mapped + 1] = results[i + 1] -- 237
			end -- 237
			i = i + 1 -- 222
		end -- 222
	end -- 222
	return mapped -- 240
end -- 220
local function getDoraDocRoot(docLanguage) -- 243
	return docLanguage == "zh" and DORA_DOC_ZH_DIR or DORA_DOC_EN_DIR -- 244
end -- 243
local function getDoraDocExtsByCodeLanguage(programmingLanguage) -- 247
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 247
		return {"ts"} -- 249
	end -- 249
	return {"tl"} -- 251
end -- 247
local function toDocRelativePath(docRoot, file) -- 254
	return Path:getRelative(file, docRoot) -- 255
end -- 254
local function ensureDirPath(dir) -- 258
	if not dir or dir == "." or dir == "" then -- 258
		return true -- 259
	end -- 259
	if Content:exist(dir) then -- 259
		return Content:isdir(dir) -- 260
	end -- 260
	local parent = Path:getPath(dir) -- 261
	if parent and parent ~= dir and parent ~= "." and parent ~= "" then -- 261
		if not ensureDirPath(parent) then -- 261
			return false -- 263
		end -- 263
	end -- 263
	return Content:mkdir(dir) -- 265
end -- 258
local function ensureDirForFile(path) -- 268
	local dir = Path:getPath(path) -- 269
	return ensureDirPath(dir) -- 270
end -- 268
local function getFileState(path) -- 273
	local exists = Content:exist(path) -- 274
	if not exists then -- 274
		return {exists = false, content = "", bytes = 0} -- 276
	end -- 276
	local content = Content:load(path) -- 282
	return {exists = true, content = content, bytes = #content} -- 283
end -- 273
local function queryOne(sql, args) -- 290
	local ____args_0 -- 291
	if args then -- 291
		____args_0 = DB:query(sql, args) -- 291
	else -- 291
		____args_0 = DB:query(sql) -- 291
	end -- 291
	local rows = ____args_0 -- 291
	if not rows or #rows == 0 then -- 291
		return nil -- 292
	end -- 292
	return rows[1] -- 293
end -- 290
do -- 290
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 298
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 306
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 317
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 318
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 331
end -- 331
local function isTsLikeFile(path) -- 334
	local ext = Path:getExt(path) -- 335
	return ext == "ts" or ext == "tsx" -- 336
end -- 334
local function isDtsFile(path) -- 339
	return Path:getExt(Path:getName(path)) == "d" -- 340
end -- 339
local function getTaskHeadSeq(taskId) -- 343
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 344
	if not row then -- 344
		return nil -- 345
	end -- 345
	return row[1] or 0 -- 346
end -- 343
local function getTaskStatus(taskId) -- 349
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 350
	if not row then -- 350
		return nil -- 351
	end -- 351
	return toStr(row[1]) -- 352
end -- 349
local function getLastInsertRowId() -- 355
	local row = queryOne("SELECT last_insert_rowid()") -- 356
	return row and (row[1] or 0) or 0 -- 357
end -- 355
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 360
	DB:exec( -- 361
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 361
		{ -- 363
			taskId, -- 363
			seq, -- 363
			status, -- 363
			summary, -- 363
			toolName, -- 363
			now() -- 363
		} -- 363
	) -- 363
	return getLastInsertRowId() -- 365
end -- 360
local function getCheckpointEntries(checkpointId, desc) -- 368
	if desc == nil then -- 368
		desc = false -- 368
	end -- 368
	local rows = DB:query((("SELECT id, ord, path, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 369
	if not rows then -- 369
		return {} -- 376
	end -- 376
	local result = {} -- 377
	do -- 377
		local i = 0 -- 378
		while i < #rows do -- 378
			local row = rows[i + 1] -- 379
			result[#result + 1] = { -- 380
				id = row[1], -- 381
				ord = row[2], -- 382
				path = toStr(row[3]), -- 383
				beforeExists = toBool(row[4]), -- 384
				beforeContent = toStr(row[5]), -- 385
				afterExists = toBool(row[6]), -- 386
				afterContent = toStr(row[7]) -- 387
			} -- 387
			i = i + 1 -- 378
		end -- 378
	end -- 378
	return result -- 390
end -- 368
local function rejectDuplicatePaths(changes) -- 393
	local seen = __TS__New(Set) -- 394
	for ____, change in ipairs(changes) do -- 395
		local key = change.path -- 396
		if seen:has(key) then -- 396
			return key -- 397
		end -- 397
		seen:add(key) -- 398
	end -- 398
	return nil -- 400
end -- 393
local function applySingleFile(path, exists, content) -- 403
	if exists then -- 403
		if not ensureDirForFile(path) then -- 403
			return false -- 405
		end -- 405
		return Content:save(path, content) -- 406
	end -- 406
	if Content:exist(path) then -- 406
		return Content:remove(path) -- 409
	end -- 409
	return true -- 411
end -- 403
local function encodeJSON(obj) -- 414
	local text = json.encode(obj) -- 415
	return text -- 416
end -- 414
function ____exports.runSingleTsTranspile(file, content) -- 419
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 419
		local done = false -- 420
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 421
		if HttpServer.wsConnectionCount == 0 then -- 421
			return ____awaiter_resolve(nil, result) -- 421
		end -- 421
		local listener = Node() -- 429
		listener:gslot( -- 430
			"AppWS", -- 430
			function(event) -- 430
				if event.type ~= "Receive" then -- 430
					return -- 431
				end -- 431
				local res = json.decode(event.msg) -- 432
				if not res or __TS__ArrayIsArray(res) or res.name ~= "TranspileTS" then -- 432
					return -- 433
				end -- 433
				if res.success then -- 433
					local luaFile = Path:replaceExt(file, "lua") -- 435
					if Content:save( -- 435
						luaFile, -- 436
						tostring(res.luaCode) -- 436
					) then -- 436
						result = {success = true, file = file} -- 437
					else -- 437
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 439
					end -- 439
				else -- 439
					result = { -- 442
						success = false, -- 442
						file = file, -- 442
						message = tostring(res.message) -- 442
					} -- 442
				end -- 442
				done = true -- 444
			end -- 430
		) -- 430
		local payload = encodeJSON({name = "TranspileTS", file = file, content = content}) -- 446
		if not payload then -- 446
			listener:removeFromParent() -- 452
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 452
		end -- 452
		__TS__Await(__TS__New( -- 455
			__TS__Promise, -- 455
			function(____, resolve) -- 455
				Director.systemScheduler:schedule(once(function() -- 456
					emit("AppWS", "Send", payload) -- 457
					wait(function() return done end) -- 458
					if not done then -- 458
						listener:removeFromParent() -- 460
					end -- 460
					resolve(nil) -- 462
				end)) -- 456
			end -- 455
		)) -- 455
		return ____awaiter_resolve(nil, result) -- 455
	end) -- 455
end -- 419
function ____exports.createTask(prompt) -- 468
	if prompt == nil then -- 468
		prompt = "" -- 468
	end -- 468
	local t = now() -- 469
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 470
	if affected <= 0 then -- 470
		return {success = false, message = "failed to create task"} -- 475
	end -- 475
	return { -- 477
		success = true, -- 477
		taskId = getLastInsertRowId() -- 477
	} -- 477
end -- 468
function ____exports.setTaskStatus(taskId, status) -- 480
	DB:exec( -- 481
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 481
		{ -- 481
			status, -- 481
			now(), -- 481
			taskId -- 481
		} -- 481
	) -- 481
	Log( -- 482
		"Info", -- 482
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 482
	) -- 482
end -- 480
function ____exports.listCheckpoints(taskId) -- 485
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 486
	if not rows then -- 486
		return {} -- 493
	end -- 493
	local items = {} -- 494
	do -- 494
		local i = 0 -- 495
		while i < #rows do -- 495
			local row = rows[i + 1] -- 496
			items[#items + 1] = { -- 497
				id = row[1], -- 498
				taskId = row[2], -- 499
				seq = row[3], -- 500
				status = toStr(row[4]), -- 501
				summary = toStr(row[5]), -- 502
				toolName = toStr(row[6]), -- 503
				createdAt = row[7] -- 504
			} -- 504
			i = i + 1 -- 495
		end -- 495
	end -- 495
	return items -- 507
end -- 485
local function readWorkspaceFile(workDir, path) -- 510
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 511
	if not fullPath then -- 511
		return {success = false, message = "invalid path or workDir"} -- 512
	end -- 512
	if not Content:exist(fullPath) or Content:isdir(fullPath) then -- 512
		return {success = false, message = "file not found"} -- 513
	end -- 513
	return { -- 514
		success = true, -- 514
		content = Content:load(fullPath) -- 514
	} -- 514
end -- 510
function ____exports.readFile(workDir, path) -- 517
	local result = readWorkspaceFile(workDir, path) -- 518
	if not result.success and Content:exist(path) then -- 518
		return { -- 520
			success = true, -- 520
			content = Content:load(path) -- 520
		} -- 520
	end -- 520
	return result -- 522
end -- 517
local function getEngineLogText() -- 525
	local folder = Path(Content.writablePath, ENGINE_LOG_SNAPSHOT_DIR) -- 526
	if not Content:exist(folder) then -- 526
		Content:mkdir(folder) -- 528
	end -- 528
	local logPath = Path(folder, ENGINE_LOG_SNAPSHOT_FILE) -- 530
	if not App:saveLog(logPath) then -- 530
		return nil -- 532
	end -- 532
	return Content:load(logPath) -- 534
end -- 525
function ____exports.getLogs(req) -- 537
	local text = getEngineLogText() -- 538
	if text == nil or text == nil then -- 538
		return {success = false, message = "failed to read engine logs"} -- 540
	end -- 540
	local tailLines = math.max( -- 542
		1, -- 542
		math.floor(req and req.tailLines or 200) -- 542
	) -- 542
	local allLines = __TS__StringSplit(text, "\n") -- 543
	local logs = __TS__ArraySlice( -- 544
		allLines, -- 544
		math.max(0, #allLines - tailLines) -- 544
	) -- 544
	return req and req.joinText and ({ -- 545
		success = true, -- 545
		logs = logs, -- 545
		text = table.concat(logs, "\n") -- 545
	}) or ({success = true, logs = logs}) -- 545
end -- 537
function ____exports.listFiles(req) -- 548
	local root = req.path or "" -- 553
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 554
	if not searchRoot then -- 554
		return {success = false, message = "invalid path or workDir"} -- 556
	end -- 556
	do -- 556
		local function ____catch(e) -- 556
			return true, { -- 565
				success = false, -- 565
				message = tostring(e) -- 565
			} -- 565
		end -- 565
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 565
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 559
			local globs = ensureSafeSearchGlobs(userGlobs) -- 560
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 561
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 562
			return true, {success = true, files = files} -- 563
		end) -- 563
		if not ____try then -- 563
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 563
		end -- 563
		if ____hasReturned then -- 563
			return ____returnValue -- 558
		end -- 558
	end -- 558
end -- 548
function ____exports.readFileRange(workDir, path, startLine, endLine) -- 569
	local res = ____exports.readFile(workDir, path) -- 570
	if not res.success or res.content == nil then -- 570
		return res -- 571
	end -- 571
	local s = math.max( -- 572
		1, -- 572
		math.floor(startLine) -- 572
	) -- 572
	local e = math.max( -- 573
		s, -- 573
		math.floor(endLine) -- 573
	) -- 573
	local lines = __TS__StringSplit(res.content, "\n") -- 574
	local part = {} -- 575
	do -- 575
		local i = s -- 576
		while i <= e and i <= #lines do -- 576
			part[#part + 1] = lines[i] -- 577
			i = i + 1 -- 576
		end -- 576
	end -- 576
	return { -- 579
		success = true, -- 579
		content = table.concat(part, "\n") -- 579
	} -- 579
end -- 569
local codeExtensions = { -- 582
	".lua", -- 582
	".tl", -- 582
	".yue", -- 582
	".ts", -- 582
	".tsx", -- 582
	".xml", -- 582
	".md", -- 582
	".yarn", -- 582
	".wa", -- 582
	".mod" -- 582
} -- 582
extensionLevels = { -- 583
	vs = 2, -- 584
	bl = 2, -- 585
	ts = 1, -- 586
	tsx = 1, -- 587
	tl = 1, -- 588
	yue = 1, -- 589
	xml = 1, -- 590
	lua = 0 -- 591
} -- 591
local function splitSearchPatterns(pattern) -- 608
	local trimmed = __TS__StringTrim(pattern or "") -- 609
	if trimmed == "" then -- 609
		return {} -- 610
	end -- 610
	local out = {} -- 611
	for p0 in string.gmatch(trimmed, "%S+") do -- 612
		local p = __TS__StringTrim(tostring(p0)) -- 613
		if p ~= "" then -- 613
			out[#out + 1] = p -- 614
		end -- 614
	end -- 614
	return out -- 616
end -- 608
local function mergeSearchFileResultsUnique(resultsList) -- 619
	local merged = {} -- 620
	local seen = __TS__New(Set) -- 621
	do -- 621
		local i = 0 -- 622
		while i < #resultsList do -- 622
			local list = resultsList[i + 1] -- 623
			do -- 623
				local j = 0 -- 624
				while j < #list do -- 624
					do -- 624
						local row = list[j + 1] -- 625
						local ____temp_17 -- 626
						if type(row) == "table" then -- 626
							local ____tostring_7 = tostring -- 627
							local ____row_file_5 = row.file -- 627
							if ____row_file_5 == nil then -- 627
								____row_file_5 = row.path -- 627
							end -- 627
							local ____row_file_5_6 = ____row_file_5 -- 627
							if ____row_file_5_6 == nil then -- 627
								____row_file_5_6 = "" -- 627
							end -- 627
							local ____tostring_7_result_14 = ____tostring_7(____row_file_5_6) -- 627
							local ____tostring_9 = tostring -- 627
							local ____row_pos_8 = row.pos -- 627
							if ____row_pos_8 == nil then -- 627
								____row_pos_8 = "" -- 627
							end -- 627
							local ____tostring_9_result_15 = ____tostring_9(____row_pos_8) -- 627
							local ____tostring_11 = tostring -- 627
							local ____row_line_10 = row.line -- 627
							if ____row_line_10 == nil then -- 627
								____row_line_10 = "" -- 627
							end -- 627
							local ____tostring_11_result_16 = ____tostring_11(____row_line_10) -- 627
							local ____tostring_13 = tostring -- 627
							local ____row_column_12 = row.column -- 627
							if ____row_column_12 == nil then -- 627
								____row_column_12 = "" -- 627
							end -- 627
							____temp_17 = (((((____tostring_7_result_14 .. ":") .. ____tostring_9_result_15) .. ":") .. ____tostring_11_result_16) .. ":") .. ____tostring_13(____row_column_12) -- 627
						else -- 627
							____temp_17 = tostring(j) -- 628
						end -- 628
						local key = ____temp_17 -- 626
						if seen:has(key) then -- 626
							goto __continue129 -- 629
						end -- 629
						seen:add(key) -- 630
						merged[#merged + 1] = list[j + 1] -- 631
					end -- 631
					::__continue129:: -- 631
					j = j + 1 -- 624
				end -- 624
			end -- 624
			i = i + 1 -- 622
		end -- 622
	end -- 622
	return merged -- 634
end -- 619
local function mergeDoraAPISearchHitsUnique(resultsList, topK) -- 637
	local merged = {} -- 638
	local seen = __TS__New(Set) -- 639
	do -- 639
		local i = 0 -- 640
		while i < #resultsList and #merged < topK do -- 640
			local list = resultsList[i + 1] -- 641
			do -- 641
				local j = 0 -- 642
				while j < #list and #merged < topK do -- 642
					do -- 642
						local row = list[j + 1] -- 643
						local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 644
						if seen:has(key) then -- 644
							goto __continue135 -- 645
						end -- 645
						seen:add(key) -- 646
						merged[#merged + 1] = row -- 647
					end -- 647
					::__continue135:: -- 647
					j = j + 1 -- 642
				end -- 642
			end -- 642
			i = i + 1 -- 640
		end -- 640
	end -- 640
	return merged -- 650
end -- 637
function ____exports.searchFiles(req) -- 653
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 653
		local searchRoot = resolveWorkspaceSearchPath(req.workDir, req.path) -- 663
		if not searchRoot then -- 663
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 663
		end -- 663
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 663
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 663
		end -- 663
		local patterns = splitSearchPatterns(req.pattern) -- 670
		if #patterns == 0 then -- 670
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 670
		end -- 670
		return ____awaiter_resolve( -- 670
			nil, -- 670
			__TS__New( -- 674
				__TS__Promise, -- 674
				function(____, resolve) -- 674
					Director.systemScheduler:schedule(once(function() -- 675
						do -- 675
							local function ____catch(e) -- 675
								resolve( -- 694
									nil, -- 694
									{ -- 694
										success = false, -- 694
										message = tostring(e) -- 694
									} -- 694
								) -- 694
							end -- 694
							local ____try, ____hasReturned = pcall(function() -- 694
								local allResults = {} -- 677
								do -- 677
									local i = 0 -- 678
									while i < #patterns do -- 678
										local ____Content_23 = Content -- 679
										local ____Content_searchFilesAsync_24 = Content.searchFilesAsync -- 679
										local ____ensureSafeSearchGlobs_result_21 = ensureSafeSearchGlobs(req.globs or ({"**"})) -- 683
										local ____patterns_index_22 = patterns[i + 1] -- 684
										local ____req_useRegex_18 = req.useRegex -- 685
										if ____req_useRegex_18 == nil then -- 685
											____req_useRegex_18 = false -- 685
										end -- 685
										local ____req_caseSensitive_19 = req.caseSensitive -- 686
										if ____req_caseSensitive_19 == nil then -- 686
											____req_caseSensitive_19 = false -- 686
										end -- 686
										local ____req_includeContent_20 = req.includeContent -- 687
										if ____req_includeContent_20 == nil then -- 687
											____req_includeContent_20 = true -- 687
										end -- 687
										allResults[#allResults + 1] = ____Content_searchFilesAsync_24( -- 679
											____Content_23, -- 679
											searchRoot, -- 680
											codeExtensions, -- 681
											extensionLevels, -- 682
											____ensureSafeSearchGlobs_result_21, -- 683
											____patterns_index_22, -- 684
											____req_useRegex_18, -- 685
											____req_caseSensitive_19, -- 686
											____req_includeContent_20, -- 687
											req.contentWindow or 120 -- 688
										) -- 688
										i = i + 1 -- 678
									end -- 678
								end -- 678
								local results = mergeSearchFileResultsUnique(allResults) -- 691
								resolve( -- 692
									nil, -- 692
									{ -- 692
										success = true, -- 692
										results = toWorkspaceRelativeSearchResults(req.workDir, results) -- 692
									} -- 692
								) -- 692
							end) -- 692
							if not ____try then -- 692
								____catch(____hasReturned) -- 692
							end -- 692
						end -- 692
					end)) -- 675
				end -- 674
			) -- 674
		) -- 674
	end) -- 674
end -- 653
function ____exports.searchDoraAPI(req) -- 700
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 700
		local pattern = __TS__StringTrim(req.pattern or "") -- 710
		if pattern == "" then -- 710
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 710
		end -- 710
		local patterns = splitSearchPatterns(pattern) -- 712
		if #patterns == 0 then -- 712
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 712
		end -- 712
		local docRoot = getDoraDocRoot(req.docLanguage) -- 714
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 714
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 714
		end -- 714
		local exts = getDoraDocExtsByCodeLanguage(req.programmingLanguage) -- 718
		local dotExts = __TS__ArrayMap( -- 719
			exts, -- 719
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 719
		) -- 719
		local globs = __TS__ArrayMap( -- 720
			exts, -- 720
			function(____, ext) return "**/*." .. ext end -- 720
		) -- 720
		local topK = math.max( -- 721
			1, -- 721
			math.floor(req.topK or 10) -- 721
		) -- 721
		return ____awaiter_resolve( -- 721
			nil, -- 721
			__TS__New( -- 723
				__TS__Promise, -- 723
				function(____, resolve) -- 723
					Director.systemScheduler:schedule(once(function() -- 724
						do -- 724
							local function ____catch(e) -- 724
								resolve( -- 764
									nil, -- 764
									{ -- 764
										success = false, -- 764
										message = tostring(e) -- 764
									} -- 764
								) -- 764
							end -- 764
							local ____try, ____hasReturned = pcall(function() -- 764
								local allHits = {} -- 726
								do -- 726
									local p = 0 -- 727
									while p < #patterns do -- 727
										local ____Content_29 = Content -- 728
										local ____Content_searchFilesAsync_30 = Content.searchFilesAsync -- 728
										local ____array_28 = __TS__SparseArrayNew( -- 728
											docRoot, -- 729
											dotExts, -- 730
											{}, -- 731
											ensureSafeSearchGlobs(globs), -- 732
											patterns[p + 1] -- 733
										) -- 733
										local ____req_useRegex_25 = req.useRegex -- 734
										if ____req_useRegex_25 == nil then -- 734
											____req_useRegex_25 = false -- 734
										end -- 734
										__TS__SparseArrayPush(____array_28, ____req_useRegex_25) -- 734
										local ____req_caseSensitive_26 = req.caseSensitive -- 735
										if ____req_caseSensitive_26 == nil then -- 735
											____req_caseSensitive_26 = false -- 735
										end -- 735
										__TS__SparseArrayPush(____array_28, ____req_caseSensitive_26) -- 735
										local ____req_includeContent_27 = req.includeContent -- 736
										if ____req_includeContent_27 == nil then -- 736
											____req_includeContent_27 = true -- 736
										end -- 736
										__TS__SparseArrayPush(____array_28, ____req_includeContent_27, req.contentWindow or 140) -- 736
										local raw = ____Content_searchFilesAsync_30( -- 728
											____Content_29, -- 728
											__TS__SparseArraySpread(____array_28) -- 728
										) -- 728
										local hits = {} -- 739
										do -- 739
											local i = 0 -- 740
											while i < #raw do -- 740
												do -- 740
													local row = raw[i + 1] -- 741
													if type(row) ~= "table" then -- 741
														goto __continue159 -- 742
													end -- 742
													local file = type(row.file) == "string" and toDocRelativePath(docRoot, row.file) or (type(row.path) == "string" and toDocRelativePath(docRoot, row.path) or "") -- 743
													if file == "" then -- 743
														goto __continue159 -- 746
													end -- 746
													hits[#hits + 1] = { -- 747
														file = file, -- 748
														line = type(row.line) == "number" and row.line or nil, -- 749
														content = type(row.content) == "string" and row.content or nil -- 750
													} -- 750
												end -- 750
												::__continue159:: -- 750
												i = i + 1 -- 740
											end -- 740
										end -- 740
										allHits[#allHits + 1] = hits -- 753
										p = p + 1 -- 727
									end -- 727
								end -- 727
								local hits = mergeDoraAPISearchHitsUnique(allHits, topK) -- 755
								resolve(nil, { -- 756
									success = true, -- 757
									docLanguage = req.docLanguage, -- 758
									root = docRoot, -- 759
									exts = exts, -- 760
									results = hits -- 761
								}) -- 761
							end) -- 761
							if not ____try then -- 761
								____catch(____hasReturned) -- 761
							end -- 761
						end -- 761
					end)) -- 724
				end -- 723
			) -- 723
		) -- 723
	end) -- 723
end -- 700
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 770
	if options == nil then -- 770
		options = {} -- 770
	end -- 770
	if #changes == 0 then -- 770
		return {success = false, message = "empty changes"} -- 772
	end -- 772
	if not isValidWorkDir(workDir) then -- 772
		return {success = false, message = "invalid workDir"} -- 775
	end -- 775
	if not getTaskStatus(taskId) then -- 775
		return {success = false, message = "task not found"} -- 778
	end -- 778
	local dup = rejectDuplicatePaths(changes) -- 780
	if dup then -- 780
		return {success = false, message = "duplicate path in batch: " .. dup} -- 782
	end -- 782
	for ____, change in ipairs(changes) do -- 785
		if not isValidWorkspacePath(change.path) then -- 785
			return {success = false, message = "invalid path: " .. change.path} -- 787
		end -- 787
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 787
			return {success = false, message = "missing content for " .. change.path} -- 790
		end -- 790
	end -- 790
	local headSeq = getTaskHeadSeq(taskId) -- 794
	if headSeq == nil then -- 794
		return {success = false, message = "task not found"} -- 795
	end -- 795
	local nextSeq = headSeq + 1 -- 796
	local checkpointId = insertCheckpoint( -- 797
		taskId, -- 797
		nextSeq, -- 797
		options.summary or "", -- 797
		options.toolName or "", -- 797
		"PREPARED" -- 797
	) -- 797
	if checkpointId <= 0 then -- 797
		return {success = false, message = "failed to create checkpoint"} -- 799
	end -- 799
	do -- 799
		local i = 0 -- 802
		while i < #changes do -- 802
			local change = changes[i + 1] -- 803
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 804
			if not fullPath then -- 804
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 806
				return {success = false, message = "invalid path: " .. change.path} -- 807
			end -- 807
			local before = getFileState(fullPath) -- 809
			local afterExists = change.op ~= "delete" -- 810
			local afterContent = afterExists and (change.content or "") or "" -- 811
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 812
				checkpointId, -- 816
				i + 1, -- 817
				change.path, -- 818
				change.op, -- 819
				before.exists and 1 or 0, -- 820
				before.content, -- 821
				afterExists and 1 or 0, -- 822
				afterContent, -- 823
				before.bytes, -- 824
				#afterContent -- 825
			}) -- 825
			if inserted <= 0 then -- 825
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 829
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 830
			end -- 830
			i = i + 1 -- 802
		end -- 802
	end -- 802
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 834
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 835
		if not fullPath then -- 835
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 837
			return {success = false, message = "invalid path: " .. entry.path} -- 838
		end -- 838
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 840
		if not ok then -- 840
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 842
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 843
		end -- 843
	end -- 843
	DB:exec( -- 847
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 847
		{ -- 849
			"APPLIED", -- 849
			now(), -- 849
			checkpointId -- 849
		} -- 849
	) -- 849
	DB:exec( -- 851
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 851
		{ -- 853
			nextSeq, -- 853
			now(), -- 853
			taskId -- 853
		} -- 853
	) -- 853
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 855
end -- 770
function ____exports.rollbackToCheckpoint(taskId, workDir, targetSeq) -- 863
	if not isValidWorkDir(workDir) then -- 863
		return {success = false, message = "invalid workDir"} -- 864
	end -- 864
	local headSeq = getTaskHeadSeq(taskId) -- 865
	if headSeq == nil then -- 865
		return {success = false, message = "task not found"} -- 866
	end -- 866
	if targetSeq < 0 or targetSeq > headSeq then -- 866
		return {success = false, message = "invalid target seq"} -- 868
	end -- 868
	if targetSeq == headSeq then -- 868
		return {success = true, headSeq = headSeq} -- 871
	end -- 871
	local cps = DB:query(("SELECT id, seq FROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status = ? AND seq > ? AND seq <= ?\n\t\tORDER BY seq DESC", {taskId, "APPLIED", targetSeq, headSeq}) -- 874
	if not cps then -- 874
		return {success = false, message = "failed to query checkpoints"} -- 880
	end -- 880
	do -- 880
		local i = 0 -- 882
		while i < #cps do -- 882
			local cpId = cps[i + 1][1] -- 883
			local cpSeq = cps[i + 1][2] -- 884
			local entries = getCheckpointEntries(cpId, true) -- 885
			for ____, entry in ipairs(entries) do -- 886
				local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 887
				if not fullPath then -- 887
					return {success = false, message = "invalid path: " .. entry.path} -- 889
				end -- 889
				local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 891
				if not ok then -- 891
					Log( -- 893
						"Error", -- 893
						(("Agent rollback failed at checkpoint " .. tostring(cpSeq)) .. ", file ") .. entry.path -- 893
					) -- 893
					Log( -- 894
						"Info", -- 894
						(("[rollback] failed checkpoint=" .. tostring(cpSeq)) .. " file=") .. entry.path -- 894
					) -- 894
					return {success = false, message = "failed to rollback file: " .. entry.path} -- 895
				end -- 895
			end -- 895
			DB:exec( -- 898
				("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 898
				{ -- 900
					"REVERTED", -- 900
					now(), -- 900
					cpId -- 900
				} -- 900
			) -- 900
			i = i + 1 -- 882
		end -- 882
	end -- 882
	DB:exec( -- 904
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 904
		{ -- 906
			targetSeq, -- 906
			now(), -- 906
			taskId -- 906
		} -- 906
	) -- 906
	return {success = true, headSeq = targetSeq} -- 908
end -- 863
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 911
	return getCheckpointEntries(checkpointId, false) -- 912
end -- 911
function ____exports.runTsBuild(req) -- 915
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 915
		local targetRel = req.path or "" -- 916
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 917
		if not target then -- 917
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 917
		end -- 917
		if not Content:exist(target) then -- 917
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 917
		end -- 917
		local messages = {} -- 924
		if not Content:isdir(target) then -- 924
			if not isTsLikeFile(target) then -- 924
				return ____awaiter_resolve(nil, {success = false, message = "expecting a TypeScript file"}) -- 924
			end -- 924
			local content = Content:load(target) -- 929
			if content == nil or content == nil then -- 929
				return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 929
			end -- 929
			local updatePayload = encodeJSON({name = "UpdateTSCode", file = target, content = content}) -- 933
			if not updatePayload then -- 933
				return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateTSCode request"}) -- 933
			end -- 933
			emit("AppWS", "Send", updatePayload) -- 937
			if not isDtsFile(target) then -- 937
				messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 939
			end -- 939
			Log( -- 941
				"Info", -- 941
				(("[ts_build] file=" .. target) .. " messages=") .. tostring(#messages) -- 941
			) -- 941
			return ____awaiter_resolve( -- 941
				nil, -- 941
				{ -- 942
					success = true, -- 943
					messages = __TS__ArrayMap( -- 944
						messages, -- 944
						function(____, m) return m.success and __TS__ObjectAssign( -- 944
							{}, -- 945
							m, -- 945
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 945
						) or __TS__ObjectAssign( -- 945
							{}, -- 946
							m, -- 946
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 946
						) end -- 946
					) -- 946
				} -- 946
			) -- 946
		end -- 946
		local relFiles = Content:getAllFiles(target) -- 950
		local fileData = {} -- 951
		for ____, rel in ipairs(relFiles) do -- 952
			do -- 952
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 953
				if not isTsLikeFile(file) then -- 953
					goto __continue204 -- 954
				end -- 954
				local content = Content:load(file) -- 955
				if content == nil or content == nil then -- 955
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 957
					goto __continue204 -- 958
				end -- 958
				fileData[file] = content -- 960
				local updatePayload = encodeJSON({name = "UpdateTSCode", file = file, content = content}) -- 961
				if not updatePayload then -- 961
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateTSCode request"} -- 963
					goto __continue204 -- 964
				end -- 964
				emit("AppWS", "Send", updatePayload) -- 966
			end -- 966
			::__continue204:: -- 966
		end -- 966
		for file in pairs(fileData) do -- 968
			do -- 968
				if isDtsFile(file) then -- 968
					goto __continue209 -- 969
				end -- 969
				messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, fileData[file])) -- 970
			end -- 970
			::__continue209:: -- 970
		end -- 970
		Log( -- 972
			"Info", -- 972
			(("[ts_build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 972
		) -- 972
		return ____awaiter_resolve( -- 972
			nil, -- 972
			{ -- 973
				success = true, -- 974
				messages = __TS__ArrayMap( -- 975
					messages, -- 975
					function(____, m) return m.success and __TS__ObjectAssign( -- 975
						{}, -- 976
						m, -- 976
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 976
					) or __TS__ObjectAssign( -- 976
						{}, -- 977
						m, -- 977
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 977
					) end -- 977
				) -- 977
			} -- 977
		) -- 977
	end) -- 977
end -- 915
return ____exports -- 915