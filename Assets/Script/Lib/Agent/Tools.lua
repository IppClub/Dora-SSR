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
function ensureSafeSearchGlobs(globs) -- 806
	local result = {} -- 807
	do -- 807
		local i = 0 -- 808
		while i < #globs do -- 808
			result[#result + 1] = globs[i + 1] -- 809
			i = i + 1 -- 808
		end -- 808
	end -- 808
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 811
	do -- 811
		local i = 0 -- 812
		while i < #requiredExcludes do -- 812
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 812
				result[#result + 1] = requiredExcludes[i + 1] -- 814
			end -- 814
			i = i + 1 -- 812
		end -- 812
	end -- 812
	return result -- 817
end -- 817
local TABLE_TASK = "AgentTask" -- 190
local TABLE_CP = "AgentCheckpoint" -- 191
local TABLE_ENTRY = "AgentCheckpointEntry" -- 192
local ENGINE_LOG_SNAPSHOT_DIR = ".agent" -- 193
local ENGINE_LOG_SNAPSHOT_FILE = "engine_logs_snapshot.txt" -- 194
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
local function resolveWorkspaceFilePath(workDir, path) -- 228
	if not isValidWorkDir(workDir) then -- 228
		return nil -- 229
	end -- 229
	if not isValidWorkspacePath(path) then -- 229
		return nil -- 230
	end -- 230
	return Path(workDir, path) -- 231
end -- 228
local function resolveWorkspaceSearchPath(workDir, path) -- 234
	if not isValidWorkDir(workDir) then -- 234
		return nil -- 235
	end -- 235
	local root = path or "" -- 236
	if not isValidSearchPath(root) then -- 236
		return nil -- 237
	end -- 237
	return root == "" and workDir or Path(workDir, root) -- 238
end -- 234
local function toWorkspaceRelativePath(workDir, path) -- 241
	if not path or #path == 0 then -- 241
		return path -- 242
	end -- 242
	if not Content:isAbsolutePath(path) then -- 242
		return path -- 243
	end -- 243
	return Path:getRelative(path, workDir) -- 244
end -- 241
local function toWorkspaceRelativeFileList(workDir, files) -- 247
	return __TS__ArrayMap( -- 248
		files, -- 248
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 248
	) -- 248
end -- 247
local function toWorkspaceRelativeSearchResults(workDir, results) -- 251
	local mapped = {} -- 252
	do -- 252
		local i = 0 -- 253
		while i < #results do -- 253
			local row = results[i + 1] -- 254
			local clone = __TS__ObjectAssign({}, row) -- 255
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 256
			mapped[#mapped + 1] = clone -- 257
			i = i + 1 -- 253
		end -- 253
	end -- 253
	return mapped -- 259
end -- 251
local function getDoraAPIDocRoot(docLanguage) -- 262
	local zhDir = Path( -- 263
		Content.assetPath, -- 263
		"Script", -- 263
		"Lib", -- 263
		"Dora", -- 263
		"zh-Hans" -- 263
	) -- 263
	local enDir = Path( -- 264
		Content.assetPath, -- 264
		"Script", -- 264
		"Lib", -- 264
		"Dora", -- 264
		"en" -- 264
	) -- 264
	return docLanguage == "zh" and zhDir or enDir -- 265
end -- 262
local function getDoraTutorialDocRoot(docLanguage) -- 268
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 269
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 270
	return docLanguage == "zh" and zhDir or enDir -- 271
end -- 268
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 274
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 274
		return {"ts"} -- 276
	end -- 276
	return {"tl"} -- 278
end -- 274
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 281
	repeat -- 281
		local ____switch37 = programmingLanguage -- 281
		local ____cond37 = ____switch37 == "teal" -- 281
		if ____cond37 then -- 281
			return "tl" -- 283
		end -- 283
		____cond37 = ____cond37 or ____switch37 == "tl" -- 283
		if ____cond37 then -- 283
			return "tl" -- 284
		end -- 284
		do -- 284
			return programmingLanguage -- 285
		end -- 285
	until true -- 285
end -- 281
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 289
	if docSource == "tutorial" then -- 289
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 295
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 296
		return { -- 297
			root = Path(tutorialRoot, langDir), -- 298
			exts = {"md"}, -- 299
			globs = {"**/*.md"} -- 300
		} -- 300
	end -- 300
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 303
	return { -- 304
		root = getDoraAPIDocRoot(docLanguage), -- 305
		exts = exts, -- 306
		globs = __TS__ArrayMap( -- 307
			exts, -- 307
			function(____, ext) return "**/*." .. ext end -- 307
		) -- 307
	} -- 307
end -- 289
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 311
	if docSource == "tutorial" then -- 311
		return getDoraTutorialDocRoot(docLanguage) -- 313
	end -- 313
	return getDoraAPIDocRoot(docLanguage) -- 315
end -- 311
local function toDocRelativePath(baseRoot, path) -- 318
	if not path or #path == 0 then -- 318
		return path -- 319
	end -- 319
	if not Content:isAbsolutePath(path) then -- 319
		return path -- 320
	end -- 320
	return Path:getRelative(path, baseRoot) -- 321
end -- 318
local function resolveAgentTutorialDocFilePath(path, docLanguage) -- 324
	if not docLanguage then -- 324
		return nil -- 325
	end -- 325
	if not isValidWorkspacePath(path) then -- 325
		return nil -- 326
	end -- 326
	local candidate = Path( -- 327
		getDoraTutorialDocRoot(docLanguage), -- 327
		path -- 327
	) -- 327
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 327
		return candidate -- 329
	end -- 329
	return nil -- 331
end -- 324
local function ensureDirPath(dir) -- 334
	if not dir or dir == "." or dir == "" then -- 334
		return true -- 335
	end -- 335
	if Content:exist(dir) then -- 335
		return Content:isdir(dir) -- 336
	end -- 336
	local parent = Path:getPath(dir) -- 337
	if parent and parent ~= dir and parent ~= "." and parent ~= "" then -- 337
		if not ensureDirPath(parent) then -- 337
			return false -- 339
		end -- 339
	end -- 339
	return Content:mkdir(dir) -- 341
end -- 334
local function ensureDirForFile(path) -- 344
	local dir = Path:getPath(path) -- 345
	return ensureDirPath(dir) -- 346
end -- 344
local function getFileState(path) -- 349
	local exists = Content:exist(path) -- 350
	if not exists then -- 350
		return {exists = false, content = "", bytes = 0} -- 352
	end -- 352
	local content = Content:load(path) -- 358
	return {exists = true, content = content, bytes = #content} -- 359
end -- 349
local function queryOne(sql, args) -- 366
	local ____args_0 -- 367
	if args then -- 367
		____args_0 = DB:query(sql, args) -- 367
	else -- 367
		____args_0 = DB:query(sql) -- 367
	end -- 367
	local rows = ____args_0 -- 367
	if not rows or #rows == 0 then -- 367
		return nil -- 368
	end -- 368
	return rows[1] -- 369
end -- 366
do -- 366
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 374
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 382
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 393
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 394
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 407
end -- 407
local function isDtsFile(path) -- 410
	return Path:getExt(Path:getName(path)) == "d" -- 411
end -- 410
local function getSupportedBuildKind(path) -- 416
	repeat -- 416
		local ____switch63 = Path:getExt(path) -- 416
		local ____cond63 = ____switch63 == "ts" or ____switch63 == "tsx" -- 416
		if ____cond63 then -- 416
			return "ts" -- 418
		end -- 418
		____cond63 = ____cond63 or ____switch63 == "xml" -- 418
		if ____cond63 then -- 418
			return "xml" -- 419
		end -- 419
		____cond63 = ____cond63 or ____switch63 == "tl" -- 419
		if ____cond63 then -- 419
			return "teal" -- 420
		end -- 420
		____cond63 = ____cond63 or ____switch63 == "lua" -- 420
		if ____cond63 then -- 420
			return "lua" -- 421
		end -- 421
		____cond63 = ____cond63 or ____switch63 == "yue" -- 421
		if ____cond63 then -- 421
			return "yue" -- 422
		end -- 422
		____cond63 = ____cond63 or ____switch63 == "yarn" -- 422
		if ____cond63 then -- 422
			return "yarn" -- 423
		end -- 423
		do -- 423
			return nil -- 424
		end -- 424
	until true -- 424
end -- 416
local function getTaskHeadSeq(taskId) -- 428
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 429
	if not row then -- 429
		return nil -- 430
	end -- 430
	return row[1] or 0 -- 431
end -- 428
local function getTaskStatus(taskId) -- 434
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 435
	if not row then -- 435
		return nil -- 436
	end -- 436
	return toStr(row[1]) -- 437
end -- 434
local function getLastInsertRowId() -- 440
	local row = queryOne("SELECT last_insert_rowid()") -- 441
	return row and (row[1] or 0) or 0 -- 442
end -- 440
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 445
	DB:exec( -- 446
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 446
		{ -- 448
			taskId, -- 448
			seq, -- 448
			status, -- 448
			summary, -- 448
			toolName, -- 448
			now() -- 448
		} -- 448
	) -- 448
	return getLastInsertRowId() -- 450
end -- 445
local function getCheckpointEntries(checkpointId, desc) -- 453
	if desc == nil then -- 453
		desc = false -- 453
	end -- 453
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 454
	if not rows then -- 454
		return {} -- 461
	end -- 461
	local result = {} -- 462
	do -- 462
		local i = 0 -- 463
		while i < #rows do -- 463
			local row = rows[i + 1] -- 464
			result[#result + 1] = { -- 465
				id = row[1], -- 466
				ord = row[2], -- 467
				path = toStr(row[3]), -- 468
				op = toStr(row[4]), -- 469
				beforeExists = toBool(row[5]), -- 470
				beforeContent = toStr(row[6]), -- 471
				afterExists = toBool(row[7]), -- 472
				afterContent = toStr(row[8]) -- 473
			} -- 473
			i = i + 1 -- 463
		end -- 463
	end -- 463
	return result -- 476
end -- 453
local function rejectDuplicatePaths(changes) -- 479
	local seen = __TS__New(Set) -- 480
	for ____, change in ipairs(changes) do -- 481
		local key = change.path -- 482
		if seen:has(key) then -- 482
			return key -- 483
		end -- 483
		seen:add(key) -- 484
	end -- 484
	return nil -- 486
end -- 479
local function getLinkedDeletePaths(workDir, path) -- 489
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 490
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 490
		return {} -- 491
	end -- 491
	local parent = Path:getPath(fullPath) -- 492
	local baseName = string.lower(Path:getName(fullPath)) -- 493
	local ext = Path:getExt(fullPath) -- 494
	local linked = {} -- 495
	for ____, file in ipairs(Content:getFiles(parent)) do -- 496
		do -- 496
			if string.lower(Path:getName(file)) ~= baseName then -- 496
				goto __continue80 -- 497
			end -- 497
			local siblingExt = Path:getExt(file) -- 498
			if siblingExt == "tl" and ext == "vs" then -- 498
				linked[#linked + 1] = toWorkspaceRelativePath( -- 500
					workDir, -- 500
					Path(parent, file) -- 500
				) -- 500
				goto __continue80 -- 501
			end -- 501
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 501
				linked[#linked + 1] = toWorkspaceRelativePath( -- 504
					workDir, -- 504
					Path(parent, file) -- 504
				) -- 504
			end -- 504
		end -- 504
		::__continue80:: -- 504
	end -- 504
	return linked -- 507
end -- 489
local function expandLinkedDeleteChanges(workDir, changes) -- 510
	local expanded = {} -- 511
	local seen = __TS__New(Set) -- 512
	do -- 512
		local i = 0 -- 513
		while i < #changes do -- 513
			do -- 513
				local change = changes[i + 1] -- 514
				if not seen:has(change.path) then -- 514
					seen:add(change.path) -- 516
					expanded[#expanded + 1] = change -- 517
				end -- 517
				if change.op ~= "delete" then -- 517
					goto __continue87 -- 519
				end -- 519
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 520
				do -- 520
					local j = 0 -- 521
					while j < #linkedPaths do -- 521
						do -- 521
							local linkedPath = linkedPaths[j + 1] -- 522
							if seen:has(linkedPath) then -- 522
								goto __continue91 -- 523
							end -- 523
							seen:add(linkedPath) -- 524
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 525
						end -- 525
						::__continue91:: -- 525
						j = j + 1 -- 521
					end -- 521
				end -- 521
			end -- 521
			::__continue87:: -- 521
			i = i + 1 -- 513
		end -- 513
	end -- 513
	return expanded -- 528
end -- 510
local function applySingleFile(path, exists, content) -- 531
	if exists then -- 531
		if not ensureDirForFile(path) then -- 531
			return false -- 533
		end -- 533
		return Content:save(path, content) -- 534
	end -- 534
	if Content:exist(path) then -- 534
		return Content:remove(path) -- 537
	end -- 537
	return true -- 539
end -- 531
local function encodeJSON(obj) -- 542
	local text = safeJsonEncode(obj) -- 543
	return text -- 544
end -- 542
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 547
	if HttpServer.wsConnectionCount == 0 then -- 547
		return true -- 549
	end -- 549
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 551
	if not payload then -- 551
		return false -- 553
	end -- 553
	emit("AppWS", "Send", payload) -- 555
	return true -- 556
end -- 547
local function runSingleNonTsBuild(file) -- 559
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 559
		return ____awaiter_resolve( -- 559
			nil, -- 559
			__TS__New( -- 560
				__TS__Promise, -- 560
				function(____, resolve) -- 560
					local ____require_result_1 = require("Script.Dev.WebServer") -- 561
					local buildAsync = ____require_result_1.buildAsync -- 561
					Director.systemScheduler:schedule(once(function() -- 562
						local result = buildAsync(file) -- 563
						resolve(nil, result) -- 564
					end)) -- 562
				end -- 560
			) -- 560
		) -- 560
	end) -- 560
end -- 559
function ____exports.runSingleTsTranspile(file, content) -- 569
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 569
		local done = false -- 570
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 571
		if HttpServer.wsConnectionCount == 0 then -- 571
			return ____awaiter_resolve(nil, result) -- 571
		end -- 571
		local listener = Node() -- 579
		listener:gslot( -- 580
			"AppWS", -- 580
			function(event) -- 580
				if event.type ~= "Receive" then -- 580
					return -- 581
				end -- 581
				local res = safeJsonDecode(event.msg) -- 582
				if not res or __TS__ArrayIsArray(res) then -- 582
					return -- 583
				end -- 583
				local payload = res -- 584
				if payload.name ~= "TranspileTS" then -- 584
					return -- 585
				end -- 585
				if payload.success then -- 585
					local luaFile = Path:replaceExt(file, "lua") -- 587
					if Content:save( -- 587
						luaFile, -- 588
						tostring(payload.luaCode) -- 588
					) then -- 588
						result = {success = true, file = file} -- 589
					else -- 589
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 591
					end -- 591
				else -- 591
					result = { -- 594
						success = false, -- 594
						file = file, -- 594
						message = tostring(payload.message) -- 594
					} -- 594
				end -- 594
				done = true -- 596
			end -- 580
		) -- 580
		local payload = encodeJSON({name = "TranspileTS", file = file, content = content}) -- 598
		if not payload then -- 598
			listener:removeFromParent() -- 604
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 604
		end -- 604
		__TS__Await(__TS__New( -- 607
			__TS__Promise, -- 607
			function(____, resolve) -- 607
				Director.systemScheduler:schedule(once(function() -- 608
					emit("AppWS", "Send", payload) -- 609
					wait(function() return done end) -- 610
					if not done then -- 610
						listener:removeFromParent() -- 612
					end -- 612
					resolve(nil) -- 614
				end)) -- 608
			end -- 607
		)) -- 607
		return ____awaiter_resolve(nil, result) -- 607
	end) -- 607
end -- 569
function ____exports.createTask(prompt) -- 620
	if prompt == nil then -- 620
		prompt = "" -- 620
	end -- 620
	local t = now() -- 621
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 622
	if affected <= 0 then -- 622
		return {success = false, message = "failed to create task"} -- 627
	end -- 627
	return { -- 629
		success = true, -- 629
		taskId = getLastInsertRowId() -- 629
	} -- 629
end -- 620
function ____exports.setTaskStatus(taskId, status) -- 632
	DB:exec( -- 633
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 633
		{ -- 633
			status, -- 633
			now(), -- 633
			taskId -- 633
		} -- 633
	) -- 633
	Log( -- 634
		"Info", -- 634
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 634
	) -- 634
end -- 632
function ____exports.listCheckpoints(taskId) -- 637
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 638
	if not rows then -- 638
		return {} -- 645
	end -- 645
	local items = {} -- 646
	do -- 646
		local i = 0 -- 647
		while i < #rows do -- 647
			local row = rows[i + 1] -- 648
			items[#items + 1] = { -- 649
				id = row[1], -- 650
				taskId = row[2], -- 651
				seq = row[3], -- 652
				status = toStr(row[4]), -- 653
				summary = toStr(row[5]), -- 654
				toolName = toStr(row[6]), -- 655
				createdAt = row[7] -- 656
			} -- 656
			i = i + 1 -- 647
		end -- 647
	end -- 647
	return items -- 659
end -- 637
local function readWorkspaceFile(workDir, path, docLanguage) -- 662
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 663
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 663
		return { -- 665
			success = true, -- 665
			content = Content:load(fullPath) -- 665
		} -- 665
	end -- 665
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 667
	if docPath then -- 667
		return { -- 669
			success = true, -- 669
			content = Content:load(docPath) -- 669
		} -- 669
	end -- 669
	if not fullPath then -- 669
		return {success = false, message = "invalid path or workDir"} -- 671
	end -- 671
	return {success = false, message = "file not found"} -- 672
end -- 662
function ____exports.readFileRaw(workDir, path, docLanguage) -- 675
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 676
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 676
		return { -- 678
			success = true, -- 678
			content = Content:load(path) -- 678
		} -- 678
	end -- 678
	return result -- 680
end -- 675
local function getEngineLogText() -- 683
	local folder = Path(Content.writablePath, ENGINE_LOG_SNAPSHOT_DIR) -- 684
	if not Content:exist(folder) then -- 684
		Content:mkdir(folder) -- 686
	end -- 686
	local logPath = Path(folder, ENGINE_LOG_SNAPSHOT_FILE) -- 688
	if not App:saveLog(logPath) then -- 688
		return nil -- 690
	end -- 690
	return Content:load(logPath) -- 692
end -- 683
function ____exports.getLogs(req) -- 695
	local text = getEngineLogText() -- 696
	if text == nil then -- 696
		return {success = false, message = "failed to read engine logs"} -- 698
	end -- 698
	local tailLines = math.max( -- 700
		1, -- 700
		math.floor(req and req.tailLines or 200) -- 700
	) -- 700
	local allLines = __TS__StringSplit(text, "\n") -- 701
	local logs = __TS__ArraySlice( -- 702
		allLines, -- 702
		math.max(0, #allLines - tailLines) -- 702
	) -- 702
	return req and req.joinText and ({ -- 703
		success = true, -- 703
		logs = logs, -- 703
		text = table.concat(logs, "\n") -- 703
	}) or ({success = true, logs = logs}) -- 703
end -- 695
function ____exports.listFiles(req) -- 706
	local root = req.path or "" -- 712
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 713
	if not searchRoot then -- 713
		return {success = false, message = "invalid path or workDir"} -- 715
	end -- 715
	do -- 715
		local function ____catch(e) -- 715
			return true, { -- 733
				success = false, -- 733
				message = tostring(e) -- 733
			} -- 733
		end -- 733
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 733
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 718
			local globs = ensureSafeSearchGlobs(userGlobs) -- 719
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 720
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 721
			local totalEntries = #files -- 722
			local maxEntries = math.max( -- 723
				1, -- 723
				math.floor(req.maxEntries or 200) -- 723
			) -- 723
			local truncated = totalEntries > maxEntries -- 724
			return true, { -- 725
				success = true, -- 726
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 727
				totalEntries = totalEntries, -- 728
				truncated = truncated, -- 729
				maxEntries = maxEntries -- 730
			} -- 730
		end) -- 730
		if not ____try then -- 730
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 730
		end -- 730
		if ____hasReturned then -- 730
			return ____returnValue -- 717
		end -- 717
	end -- 717
end -- 706
local function formatReadSlice(content, startLine, limit) -- 737
	local lines = __TS__StringSplit(content, "\n") -- 742
	local totalLines = #lines -- 743
	if totalLines == 0 then -- 743
		return { -- 745
			success = true, -- 746
			content = "", -- 747
			totalLines = 0, -- 748
			startLine = 1, -- 749
			endLine = 0, -- 750
			truncated = false -- 751
		} -- 751
	end -- 751
	local start = math.max( -- 754
		1, -- 754
		math.floor(startLine) -- 754
	) -- 754
	if start > totalLines then -- 754
		return { -- 756
			success = false, -- 756
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 756
		} -- 756
	end -- 756
	local boundedLimit = math.max( -- 758
		1, -- 758
		math.floor(limit) -- 758
	) -- 758
	local ____end = math.min(totalLines, start + boundedLimit - 1) -- 759
	local slice = {} -- 760
	do -- 760
		local i = start -- 761
		while i <= ____end do -- 761
			slice[#slice + 1] = lines[i] -- 762
			i = i + 1 -- 761
		end -- 761
	end -- 761
	local truncated = ____end < totalLines -- 764
	local hint = truncated and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use offset=") .. tostring(____end + 1)) .. " to continue.)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)" -- 765
	local body = table.concat(slice, "\n") -- 768
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 769
	return { -- 770
		success = true, -- 771
		content = output, -- 772
		totalLines = totalLines, -- 773
		startLine = start, -- 774
		endLine = ____end, -- 775
		truncated = truncated -- 776
	} -- 776
end -- 737
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 780
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 787
	if not fallback.success or fallback.content == nil then -- 787
		return fallback -- 788
	end -- 788
	local s = math.max( -- 789
		1, -- 789
		math.floor(startLine or 1) -- 789
	) -- 789
	local e = math.max( -- 790
		s, -- 790
		math.floor(endLine or 300) -- 790
	) -- 790
	return formatReadSlice(fallback.content, s, e - s + 1) -- 791
end -- 780
local codeExtensions = { -- 794
	".lua", -- 794
	".tl", -- 794
	".yue", -- 794
	".ts", -- 794
	".tsx", -- 794
	".xml", -- 794
	".md", -- 794
	".yarn", -- 794
	".wa", -- 794
	".mod" -- 794
} -- 794
extensionLevels = { -- 795
	vs = 2, -- 796
	bl = 2, -- 797
	ts = 1, -- 798
	tsx = 1, -- 799
	tl = 1, -- 800
	yue = 1, -- 801
	xml = 1, -- 802
	lua = 0 -- 803
} -- 803
local function splitSearchPatterns(pattern) -- 820
	local trimmed = __TS__StringTrim(pattern or "") -- 821
	if trimmed == "" then -- 821
		return {} -- 822
	end -- 822
	local out = {} -- 823
	local seen = __TS__New(Set) -- 824
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 825
		local p = __TS__StringTrim(tostring(p0)) -- 826
		if p ~= "" and not seen:has(p) then -- 826
			seen:add(p) -- 828
			out[#out + 1] = p -- 829
		end -- 829
	end -- 829
	return out -- 832
end -- 820
local function mergeSearchFileResultsUnique(resultsList) -- 835
	local merged = {} -- 836
	local seen = __TS__New(Set) -- 837
	do -- 837
		local i = 0 -- 838
		while i < #resultsList do -- 838
			local list = resultsList[i + 1] -- 839
			do -- 839
				local j = 0 -- 840
				while j < #list do -- 840
					do -- 840
						local row = list[j + 1] -- 841
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 842
						if seen:has(key) then -- 842
							goto __continue162 -- 843
						end -- 843
						seen:add(key) -- 844
						merged[#merged + 1] = list[j + 1] -- 845
					end -- 845
					::__continue162:: -- 845
					j = j + 1 -- 840
				end -- 840
			end -- 840
			i = i + 1 -- 838
		end -- 838
	end -- 838
	return merged -- 848
end -- 835
local function buildGroupedSearchResults(results) -- 851
	local order = {} -- 856
	local grouped = __TS__New(Map) -- 857
	do -- 857
		local i = 0 -- 862
		while i < #results do -- 862
			local row = results[i + 1] -- 863
			local file = row.file -- 864
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 865
			local bucket = grouped:get(key) -- 866
			if not bucket then -- 866
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 868
				grouped:set(key, bucket) -- 869
				order[#order + 1] = key -- 870
			end -- 870
			bucket.totalMatches = bucket.totalMatches + 1 -- 872
			local ____bucket_matches_6 = bucket.matches -- 872
			____bucket_matches_6[#____bucket_matches_6 + 1] = results[i + 1] -- 873
			i = i + 1 -- 862
		end -- 862
	end -- 862
	local out = {} -- 875
	do -- 875
		local i = 0 -- 880
		while i < #order do -- 880
			local bucket = grouped:get(order[i + 1]) -- 881
			if bucket then -- 881
				out[#out + 1] = bucket -- 882
			end -- 882
			i = i + 1 -- 880
		end -- 880
	end -- 880
	return out -- 884
end -- 851
local function mergeDoraAPISearchHitsUnique(resultsList) -- 887
	local merged = {} -- 888
	local seen = __TS__New(Set) -- 889
	local index = 0 -- 890
	local advanced = true -- 891
	while advanced do -- 891
		advanced = false -- 893
		do -- 893
			local i = 0 -- 894
			while i < #resultsList do -- 894
				do -- 894
					local list = resultsList[i + 1] -- 895
					if index >= #list then -- 895
						goto __continue174 -- 896
					end -- 896
					advanced = true -- 897
					local row = list[index + 1] -- 898
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 899
					if seen:has(key) then -- 899
						goto __continue174 -- 900
					end -- 900
					seen:add(key) -- 901
					merged[#merged + 1] = row -- 902
				end -- 902
				::__continue174:: -- 902
				i = i + 1 -- 894
			end -- 894
		end -- 894
		index = index + 1 -- 904
	end -- 904
	return merged -- 906
end -- 887
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 909
	if docSource ~= "api" then -- 909
		return 100 -- 910
	end -- 910
	if programmingLanguage ~= "tsx" then -- 910
		return 100 -- 911
	end -- 911
	repeat -- 911
		local ____switch180 = string.lower(Path:getFilename(file)) -- 911
		local ____cond180 = ____switch180 == "jsx.d.ts" -- 911
		if ____cond180 then -- 911
			return 0 -- 913
		end -- 913
		____cond180 = ____cond180 or ____switch180 == "dorax.d.ts" -- 913
		if ____cond180 then -- 913
			return 1 -- 914
		end -- 914
		____cond180 = ____cond180 or ____switch180 == "dora.d.ts" -- 914
		if ____cond180 then -- 914
			return 2 -- 915
		end -- 915
		do -- 915
			return 100 -- 916
		end -- 916
	until true -- 916
end -- 909
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 920
	local sorted = __TS__ArraySlice(hits) -- 925
	__TS__ArraySort( -- 926
		sorted, -- 926
		function(____, a, b) -- 926
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 927
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 928
			if pa ~= pb then -- 928
				return pa - pb -- 929
			end -- 929
			local fa = string.lower(a.file) -- 930
			local fb = string.lower(b.file) -- 931
			if fa ~= fb then -- 931
				return fa < fb and -1 or 1 -- 932
			end -- 932
			return (a.line or 0) - (b.line or 0) -- 933
		end -- 926
	) -- 926
	return sorted -- 935
end -- 920
function ____exports.searchFiles(req) -- 938
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 938
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 951
		if not resolvedPath then -- 951
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 951
		end -- 951
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 955
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 956
		if not searchRoot then -- 956
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 956
		end -- 956
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 956
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 956
		end -- 956
		local patterns = splitSearchPatterns(req.pattern) -- 963
		if #patterns == 0 then -- 963
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 963
		end -- 963
		return ____awaiter_resolve( -- 963
			nil, -- 963
			__TS__New( -- 967
				__TS__Promise, -- 967
				function(____, resolve) -- 967
					Director.systemScheduler:schedule(once(function() -- 968
						do -- 968
							local function ____catch(e) -- 968
								resolve( -- 1010
									nil, -- 1010
									{ -- 1010
										success = false, -- 1010
										message = tostring(e) -- 1010
									} -- 1010
								) -- 1010
							end -- 1010
							local ____try, ____hasReturned = pcall(function() -- 1010
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 970
								local allResults = {} -- 973
								do -- 973
									local i = 0 -- 974
									while i < #patterns do -- 974
										local ____Content_11 = Content -- 975
										local ____Content_searchFilesAsync_12 = Content.searchFilesAsync -- 975
										local ____patterns_index_10 = patterns[i + 1] -- 980
										local ____req_useRegex_7 = req.useRegex -- 981
										if ____req_useRegex_7 == nil then -- 981
											____req_useRegex_7 = false -- 981
										end -- 981
										local ____req_caseSensitive_8 = req.caseSensitive -- 982
										if ____req_caseSensitive_8 == nil then -- 982
											____req_caseSensitive_8 = false -- 982
										end -- 982
										local ____req_includeContent_9 = req.includeContent -- 983
										if ____req_includeContent_9 == nil then -- 983
											____req_includeContent_9 = true -- 983
										end -- 983
										allResults[#allResults + 1] = ____Content_searchFilesAsync_12( -- 975
											____Content_11, -- 975
											searchRoot, -- 976
											codeExtensions, -- 977
											extensionLevels, -- 978
											searchGlobs, -- 979
											____patterns_index_10, -- 980
											____req_useRegex_7, -- 981
											____req_caseSensitive_8, -- 982
											____req_includeContent_9, -- 983
											req.contentWindow or 120 -- 984
										) -- 984
										i = i + 1 -- 974
									end -- 974
								end -- 974
								local results = mergeSearchFileResultsUnique(allResults) -- 987
								local totalResults = #results -- 988
								local limit = math.max( -- 989
									1, -- 989
									math.floor(req.limit or 20) -- 989
								) -- 989
								local offset = math.max( -- 990
									0, -- 990
									math.floor(req.offset or 0) -- 990
								) -- 990
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 991
								local nextOffset = offset + #paged -- 992
								local hasMore = nextOffset < totalResults -- 993
								local truncated = offset > 0 or hasMore -- 994
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 995
								local groupByFile = req.groupByFile == true -- 996
								resolve( -- 997
									nil, -- 997
									{ -- 997
										success = true, -- 998
										results = relativeResults, -- 999
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1000
										totalResults = totalResults, -- 1001
										truncated = truncated, -- 1002
										limit = limit, -- 1003
										offset = offset, -- 1004
										nextOffset = nextOffset, -- 1005
										hasMore = hasMore, -- 1006
										groupByFile = groupByFile -- 1007
									} -- 1007
								) -- 1007
							end) -- 1007
							if not ____try then -- 1007
								____catch(____hasReturned) -- 1007
							end -- 1007
						end -- 1007
					end)) -- 968
				end -- 967
			) -- 967
		) -- 967
	end) -- 967
end -- 938
function ____exports.searchDoraAPI(req) -- 1016
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1016
		local pattern = __TS__StringTrim(req.pattern or "") -- 1027
		if pattern == "" then -- 1027
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1027
		end -- 1027
		local patterns = splitSearchPatterns(pattern) -- 1029
		if #patterns == 0 then -- 1029
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1029
		end -- 1029
		local docSource = req.docSource or "api" -- 1031
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1032
		local docRoot = target.root -- 1033
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1034
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1034
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1034
		end -- 1034
		local exts = target.exts -- 1038
		local dotExts = __TS__ArrayMap( -- 1039
			exts, -- 1039
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1039
		) -- 1039
		local globs = target.globs -- 1040
		local limit = math.max( -- 1041
			1, -- 1041
			math.floor(req.limit or 10) -- 1041
		) -- 1041
		return ____awaiter_resolve( -- 1041
			nil, -- 1041
			__TS__New( -- 1043
				__TS__Promise, -- 1043
				function(____, resolve) -- 1043
					Director.systemScheduler:schedule(once(function() -- 1044
						do -- 1044
							local function ____catch(e) -- 1044
								resolve( -- 1085
									nil, -- 1085
									{ -- 1085
										success = false, -- 1085
										message = tostring(e) -- 1085
									} -- 1085
								) -- 1085
							end -- 1085
							local ____try, ____hasReturned = pcall(function() -- 1085
								local allHits = {} -- 1046
								do -- 1046
									local p = 0 -- 1047
									while p < #patterns do -- 1047
										local ____Content_17 = Content -- 1048
										local ____Content_searchFilesAsync_18 = Content.searchFilesAsync -- 1048
										local ____array_16 = __TS__SparseArrayNew( -- 1048
											docRoot, -- 1049
											dotExts, -- 1050
											{}, -- 1051
											ensureSafeSearchGlobs(globs), -- 1052
											patterns[p + 1] -- 1053
										) -- 1053
										local ____req_useRegex_13 = req.useRegex -- 1054
										if ____req_useRegex_13 == nil then -- 1054
											____req_useRegex_13 = false -- 1054
										end -- 1054
										__TS__SparseArrayPush(____array_16, ____req_useRegex_13) -- 1054
										local ____req_caseSensitive_14 = req.caseSensitive -- 1055
										if ____req_caseSensitive_14 == nil then -- 1055
											____req_caseSensitive_14 = false -- 1055
										end -- 1055
										__TS__SparseArrayPush(____array_16, ____req_caseSensitive_14) -- 1055
										local ____req_includeContent_15 = req.includeContent -- 1056
										if ____req_includeContent_15 == nil then -- 1056
											____req_includeContent_15 = true -- 1056
										end -- 1056
										__TS__SparseArrayPush(____array_16, ____req_includeContent_15, req.contentWindow or 80) -- 1056
										local raw = ____Content_searchFilesAsync_18( -- 1048
											____Content_17, -- 1048
											__TS__SparseArraySpread(____array_16) -- 1048
										) -- 1048
										local hits = {} -- 1059
										do -- 1059
											local i = 0 -- 1060
											while i < #raw do -- 1060
												do -- 1060
													local row = raw[i + 1] -- 1061
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1062
													if file == "" then -- 1062
														goto __continue207 -- 1063
													end -- 1063
													hits[#hits + 1] = { -- 1064
														file = file, -- 1065
														line = type(row.line) == "number" and row.line or nil, -- 1066
														content = type(row.content) == "string" and row.content or nil -- 1067
													} -- 1067
												end -- 1067
												::__continue207:: -- 1067
												i = i + 1 -- 1060
											end -- 1060
										end -- 1060
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1070
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1070
											0, -- 1070
											limit -- 1070
										) -- 1070
										p = p + 1 -- 1047
									end -- 1047
								end -- 1047
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1072
								resolve(nil, { -- 1073
									success = true, -- 1074
									docSource = docSource, -- 1075
									docLanguage = req.docLanguage, -- 1076
									programmingLanguage = req.programmingLanguage, -- 1077
									exts = exts, -- 1078
									results = hits, -- 1079
									totalResults = #hits, -- 1080
									truncated = false, -- 1081
									limit = limit -- 1082
								}) -- 1082
							end) -- 1082
							if not ____try then -- 1082
								____catch(____hasReturned) -- 1082
							end -- 1082
						end -- 1082
					end)) -- 1044
				end -- 1043
			) -- 1043
		) -- 1043
	end) -- 1043
end -- 1016
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1091
	if options == nil then -- 1091
		options = {} -- 1091
	end -- 1091
	if #changes == 0 then -- 1091
		return {success = false, message = "empty changes"} -- 1093
	end -- 1093
	if not isValidWorkDir(workDir) then -- 1093
		return {success = false, message = "invalid workDir"} -- 1096
	end -- 1096
	if not getTaskStatus(taskId) then -- 1096
		return {success = false, message = "task not found"} -- 1099
	end -- 1099
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1101
	local dup = rejectDuplicatePaths(expandedChanges) -- 1102
	if dup then -- 1102
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1104
	end -- 1104
	for ____, change in ipairs(expandedChanges) do -- 1107
		if not isValidWorkspacePath(change.path) then -- 1107
			return {success = false, message = "invalid path: " .. change.path} -- 1109
		end -- 1109
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1109
			return {success = false, message = "missing content for " .. change.path} -- 1112
		end -- 1112
	end -- 1112
	local headSeq = getTaskHeadSeq(taskId) -- 1116
	if headSeq == nil then -- 1116
		return {success = false, message = "task not found"} -- 1117
	end -- 1117
	local nextSeq = headSeq + 1 -- 1118
	local checkpointId = insertCheckpoint( -- 1119
		taskId, -- 1119
		nextSeq, -- 1119
		options.summary or "", -- 1119
		options.toolName or "", -- 1119
		"PREPARED" -- 1119
	) -- 1119
	if checkpointId <= 0 then -- 1119
		return {success = false, message = "failed to create checkpoint"} -- 1121
	end -- 1121
	do -- 1121
		local i = 0 -- 1124
		while i < #expandedChanges do -- 1124
			local change = expandedChanges[i + 1] -- 1125
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1126
			if not fullPath then -- 1126
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1128
				return {success = false, message = "invalid path: " .. change.path} -- 1129
			end -- 1129
			local before = getFileState(fullPath) -- 1131
			local afterExists = change.op ~= "delete" -- 1132
			local afterContent = afterExists and (change.content or "") or "" -- 1133
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1134
				checkpointId, -- 1138
				i + 1, -- 1139
				change.path, -- 1140
				change.op, -- 1141
				before.exists and 1 or 0, -- 1142
				before.content, -- 1143
				afterExists and 1 or 0, -- 1144
				afterContent, -- 1145
				before.bytes, -- 1146
				#afterContent -- 1147
			}) -- 1147
			if inserted <= 0 then -- 1147
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1151
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1152
			end -- 1152
			i = i + 1 -- 1124
		end -- 1124
	end -- 1124
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1156
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1157
		if not fullPath then -- 1157
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1159
			return {success = false, message = "invalid path: " .. entry.path} -- 1160
		end -- 1160
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1162
		if not ok then -- 1162
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1164
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1165
		end -- 1165
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1165
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1168
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1169
		end -- 1169
	end -- 1169
	DB:exec( -- 1173
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1173
		{ -- 1175
			"APPLIED", -- 1175
			now(), -- 1175
			checkpointId -- 1175
		} -- 1175
	) -- 1175
	DB:exec( -- 1177
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1177
		{ -- 1179
			nextSeq, -- 1179
			now(), -- 1179
			taskId -- 1179
		} -- 1179
	) -- 1179
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1181
end -- 1091
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1189
	if not isValidWorkDir(workDir) then -- 1189
		return {success = false, message = "invalid workDir"} -- 1190
	end -- 1190
	if checkpointId <= 0 then -- 1190
		return {success = false, message = "invalid checkpointId"} -- 1191
	end -- 1191
	local entries = getCheckpointEntries(checkpointId, true) -- 1192
	if #entries == 0 then -- 1192
		return {success = false, message = "checkpoint not found or empty"} -- 1194
	end -- 1194
	for ____, entry in ipairs(entries) do -- 1196
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1197
		if not fullPath then -- 1197
			return {success = false, message = "invalid path: " .. entry.path} -- 1199
		end -- 1199
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1201
		if not ok then -- 1201
			Log( -- 1203
				"Error", -- 1203
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1203
			) -- 1203
			Log( -- 1204
				"Info", -- 1204
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1204
			) -- 1204
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1205
		end -- 1205
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1205
			Log( -- 1208
				"Error", -- 1208
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1208
			) -- 1208
			Log( -- 1209
				"Info", -- 1209
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1209
			) -- 1209
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1210
		end -- 1210
	end -- 1210
	return {success = true, checkpointId = checkpointId} -- 1213
end -- 1189
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1216
	return getCheckpointEntries(checkpointId, false) -- 1217
end -- 1216
function ____exports.getCheckpointDiff(checkpointId) -- 1220
	if checkpointId <= 0 then -- 1220
		return {success = false, message = "invalid checkpointId"} -- 1222
	end -- 1222
	local entries = getCheckpointEntries(checkpointId, false) -- 1224
	if #entries == 0 then -- 1224
		return {success = false, message = "checkpoint not found or empty"} -- 1226
	end -- 1226
	return { -- 1228
		success = true, -- 1229
		files = __TS__ArrayMap( -- 1230
			entries, -- 1230
			function(____, entry) return { -- 1230
				path = entry.path, -- 1231
				op = entry.op, -- 1232
				beforeExists = entry.beforeExists, -- 1233
				afterExists = entry.afterExists, -- 1234
				beforeContent = entry.beforeContent, -- 1235
				afterContent = entry.afterContent -- 1236
			} end -- 1236
		) -- 1236
	} -- 1236
end -- 1220
function ____exports.build(req) -- 1241
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1241
		local targetRel = req.path or "" -- 1242
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1243
		if not target then -- 1243
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1243
		end -- 1243
		if not Content:exist(target) then -- 1243
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1243
		end -- 1243
		local messages = {} -- 1250
		if not Content:isdir(target) then -- 1250
			local kind = getSupportedBuildKind(target) -- 1252
			if not kind then -- 1252
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1252
			end -- 1252
			if kind == "ts" then -- 1252
				local content = Content:load(target) -- 1257
				if content == nil then -- 1257
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1257
				end -- 1257
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1257
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1257
				end -- 1257
				if not isDtsFile(target) then -- 1257
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1265
				end -- 1265
			else -- 1265
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1268
			end -- 1268
			Log( -- 1270
				"Info", -- 1270
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1270
			) -- 1270
			return ____awaiter_resolve( -- 1270
				nil, -- 1270
				{ -- 1271
					success = true, -- 1272
					messages = __TS__ArrayMap( -- 1273
						messages, -- 1273
						function(____, m) return m.success and __TS__ObjectAssign( -- 1273
							{}, -- 1274
							m, -- 1274
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1274
						) or __TS__ObjectAssign( -- 1274
							{}, -- 1275
							m, -- 1275
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1275
						) end -- 1275
					) -- 1275
				} -- 1275
			) -- 1275
		end -- 1275
		local listResult = ____exports.listFiles({ -- 1278
			workDir = req.workDir, -- 1279
			path = target, -- 1280
			globs = __TS__ArrayMap( -- 1281
				codeExtensions, -- 1281
				function(____, e) return "**/*" .. e end -- 1281
			), -- 1281
			maxEntries = 10000 -- 1282
		}) -- 1282
		local relFiles = listResult.success and listResult.files or ({}) -- 1285
		local tsFileData = {} -- 1286
		local buildQueue = {} -- 1287
		for ____, rel in ipairs(relFiles) do -- 1288
			do -- 1288
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1289
				local kind = getSupportedBuildKind(file) -- 1290
				if not kind then -- 1290
					goto __continue256 -- 1291
				end -- 1291
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1292
				if kind ~= "ts" then -- 1292
					goto __continue256 -- 1294
				end -- 1294
				local content = Content:load(file) -- 1296
				if content == nil then -- 1296
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1298
					goto __continue256 -- 1299
				end -- 1299
				tsFileData[file] = content -- 1301
				if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1301
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1303
					goto __continue256 -- 1304
				end -- 1304
			end -- 1304
			::__continue256:: -- 1304
		end -- 1304
		do -- 1304
			local i = 0 -- 1307
			while i < #buildQueue do -- 1307
				do -- 1307
					local ____buildQueue_index_19 = buildQueue[i + 1] -- 1308
					local file = ____buildQueue_index_19.file -- 1308
					local kind = ____buildQueue_index_19.kind -- 1308
					if kind == "ts" then -- 1308
						local content = tsFileData[file] -- 1310
						if content == nil or isDtsFile(file) then -- 1310
							goto __continue263 -- 1312
						end -- 1312
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1314
						goto __continue263 -- 1315
					end -- 1315
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1317
				end -- 1317
				::__continue263:: -- 1317
				i = i + 1 -- 1307
			end -- 1307
		end -- 1307
		Log( -- 1319
			"Info", -- 1319
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1319
		) -- 1319
		return ____awaiter_resolve( -- 1319
			nil, -- 1319
			{ -- 1320
				success = true, -- 1321
				messages = __TS__ArrayMap( -- 1322
					messages, -- 1322
					function(____, m) return m.success and __TS__ObjectAssign( -- 1322
						{}, -- 1323
						m, -- 1323
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1323
					) or __TS__ObjectAssign( -- 1323
						{}, -- 1324
						m, -- 1324
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1324
					) end -- 1324
				) -- 1324
			} -- 1324
		) -- 1324
	end) -- 1324
end -- 1241
return ____exports -- 1241