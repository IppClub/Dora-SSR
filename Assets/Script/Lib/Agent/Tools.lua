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
function ensureSafeSearchGlobs(globs) -- 832
	local result = {} -- 833
	do -- 833
		local i = 0 -- 834
		while i < #globs do -- 834
			result[#result + 1] = globs[i + 1] -- 835
			i = i + 1 -- 834
		end -- 834
	end -- 834
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 837
	do -- 837
		local i = 0 -- 838
		while i < #requiredExcludes do -- 838
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 838
				result[#result + 1] = requiredExcludes[i + 1] -- 840
			end -- 840
			i = i + 1 -- 838
		end -- 838
	end -- 838
	return result -- 843
end -- 843
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
local function formatReadSlice(content, startLine, endLine) -- 737
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
	local rawStart = math.floor(startLine) -- 754
	local rawEnd = math.floor(endLine) -- 755
	if rawStart == 0 then -- 755
		return {success = false, message = "startLine cannot be 0"} -- 757
	end -- 757
	if rawEnd == 0 then -- 757
		return {success = false, message = "endLine cannot be 0"} -- 760
	end -- 760
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 762
	if start > totalLines then -- 762
		return { -- 766
			success = false, -- 766
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 766
		} -- 766
	end -- 766
	local ____end = math.min( -- 768
		totalLines, -- 769
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 770
	) -- 770
	if ____end < start then -- 770
		return { -- 775
			success = false, -- 776
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 777
		} -- 777
	end -- 777
	local slice = {} -- 780
	do -- 780
		local i = start -- 781
		while i <= ____end do -- 781
			slice[#slice + 1] = lines[i] -- 782
			i = i + 1 -- 781
		end -- 781
	end -- 781
	local truncated = start > 1 or ____end < totalLines -- 784
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 785
	local body = table.concat(slice, "\n") -- 790
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 791
	return { -- 792
		success = true, -- 793
		content = output, -- 794
		totalLines = totalLines, -- 795
		startLine = start, -- 796
		endLine = ____end, -- 797
		truncated = truncated -- 798
	} -- 798
end -- 737
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 802
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 809
	if not fallback.success or fallback.content == nil then -- 809
		return fallback -- 810
	end -- 810
	local resolvedStartLine = startLine or 1 -- 811
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 812
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 813
end -- 802
local codeExtensions = { -- 820
	".lua", -- 820
	".tl", -- 820
	".yue", -- 820
	".ts", -- 820
	".tsx", -- 820
	".xml", -- 820
	".md", -- 820
	".yarn", -- 820
	".wa", -- 820
	".mod" -- 820
} -- 820
extensionLevels = { -- 821
	vs = 2, -- 822
	bl = 2, -- 823
	ts = 1, -- 824
	tsx = 1, -- 825
	tl = 1, -- 826
	yue = 1, -- 827
	xml = 1, -- 828
	lua = 0 -- 829
} -- 829
local function splitSearchPatterns(pattern) -- 846
	local trimmed = __TS__StringTrim(pattern or "") -- 847
	if trimmed == "" then -- 847
		return {} -- 848
	end -- 848
	local out = {} -- 849
	local seen = __TS__New(Set) -- 850
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 851
		local p = __TS__StringTrim(tostring(p0)) -- 852
		if p ~= "" and not seen:has(p) then -- 852
			seen:add(p) -- 854
			out[#out + 1] = p -- 855
		end -- 855
	end -- 855
	return out -- 858
end -- 846
local function mergeSearchFileResultsUnique(resultsList) -- 861
	local merged = {} -- 862
	local seen = __TS__New(Set) -- 863
	do -- 863
		local i = 0 -- 864
		while i < #resultsList do -- 864
			local list = resultsList[i + 1] -- 865
			do -- 865
				local j = 0 -- 866
				while j < #list do -- 866
					do -- 866
						local row = list[j + 1] -- 867
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 868
						if seen:has(key) then -- 868
							goto __continue165 -- 869
						end -- 869
						seen:add(key) -- 870
						merged[#merged + 1] = list[j + 1] -- 871
					end -- 871
					::__continue165:: -- 871
					j = j + 1 -- 866
				end -- 866
			end -- 866
			i = i + 1 -- 864
		end -- 864
	end -- 864
	return merged -- 874
end -- 861
local function buildGroupedSearchResults(results) -- 877
	local order = {} -- 882
	local grouped = __TS__New(Map) -- 883
	do -- 883
		local i = 0 -- 888
		while i < #results do -- 888
			local row = results[i + 1] -- 889
			local file = row.file -- 890
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 891
			local bucket = grouped:get(key) -- 892
			if not bucket then -- 892
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 894
				grouped:set(key, bucket) -- 895
				order[#order + 1] = key -- 896
			end -- 896
			bucket.totalMatches = bucket.totalMatches + 1 -- 898
			local ____bucket_matches_6 = bucket.matches -- 898
			____bucket_matches_6[#____bucket_matches_6 + 1] = results[i + 1] -- 899
			i = i + 1 -- 888
		end -- 888
	end -- 888
	local out = {} -- 901
	do -- 901
		local i = 0 -- 906
		while i < #order do -- 906
			local bucket = grouped:get(order[i + 1]) -- 907
			if bucket then -- 907
				out[#out + 1] = bucket -- 908
			end -- 908
			i = i + 1 -- 906
		end -- 906
	end -- 906
	return out -- 910
end -- 877
local function mergeDoraAPISearchHitsUnique(resultsList) -- 913
	local merged = {} -- 914
	local seen = __TS__New(Set) -- 915
	local index = 0 -- 916
	local advanced = true -- 917
	while advanced do -- 917
		advanced = false -- 919
		do -- 919
			local i = 0 -- 920
			while i < #resultsList do -- 920
				do -- 920
					local list = resultsList[i + 1] -- 921
					if index >= #list then -- 921
						goto __continue177 -- 922
					end -- 922
					advanced = true -- 923
					local row = list[index + 1] -- 924
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 925
					if seen:has(key) then -- 925
						goto __continue177 -- 926
					end -- 926
					seen:add(key) -- 927
					merged[#merged + 1] = row -- 928
				end -- 928
				::__continue177:: -- 928
				i = i + 1 -- 920
			end -- 920
		end -- 920
		index = index + 1 -- 930
	end -- 930
	return merged -- 932
end -- 913
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 935
	if docSource ~= "api" then -- 935
		return 100 -- 936
	end -- 936
	if programmingLanguage ~= "tsx" then -- 936
		return 100 -- 937
	end -- 937
	repeat -- 937
		local ____switch183 = string.lower(Path:getFilename(file)) -- 937
		local ____cond183 = ____switch183 == "jsx.d.ts" -- 937
		if ____cond183 then -- 937
			return 0 -- 939
		end -- 939
		____cond183 = ____cond183 or ____switch183 == "dorax.d.ts" -- 939
		if ____cond183 then -- 939
			return 1 -- 940
		end -- 940
		____cond183 = ____cond183 or ____switch183 == "dora.d.ts" -- 940
		if ____cond183 then -- 940
			return 2 -- 941
		end -- 941
		do -- 941
			return 100 -- 942
		end -- 942
	until true -- 942
end -- 935
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 946
	local sorted = __TS__ArraySlice(hits) -- 951
	__TS__ArraySort( -- 952
		sorted, -- 952
		function(____, a, b) -- 952
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 953
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 954
			if pa ~= pb then -- 954
				return pa - pb -- 955
			end -- 955
			local fa = string.lower(a.file) -- 956
			local fb = string.lower(b.file) -- 957
			if fa ~= fb then -- 957
				return fa < fb and -1 or 1 -- 958
			end -- 958
			return (a.line or 0) - (b.line or 0) -- 959
		end -- 952
	) -- 952
	return sorted -- 961
end -- 946
function ____exports.searchFiles(req) -- 964
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 964
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 977
		if not resolvedPath then -- 977
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 977
		end -- 977
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 981
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 982
		if not searchRoot then -- 982
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 982
		end -- 982
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 982
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 982
		end -- 982
		local patterns = splitSearchPatterns(req.pattern) -- 989
		if #patterns == 0 then -- 989
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 989
		end -- 989
		return ____awaiter_resolve( -- 989
			nil, -- 989
			__TS__New( -- 993
				__TS__Promise, -- 993
				function(____, resolve) -- 993
					Director.systemScheduler:schedule(once(function() -- 994
						do -- 994
							local function ____catch(e) -- 994
								resolve( -- 1036
									nil, -- 1036
									{ -- 1036
										success = false, -- 1036
										message = tostring(e) -- 1036
									} -- 1036
								) -- 1036
							end -- 1036
							local ____try, ____hasReturned = pcall(function() -- 1036
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 996
								local allResults = {} -- 999
								do -- 999
									local i = 0 -- 1000
									while i < #patterns do -- 1000
										local ____Content_11 = Content -- 1001
										local ____Content_searchFilesAsync_12 = Content.searchFilesAsync -- 1001
										local ____patterns_index_10 = patterns[i + 1] -- 1006
										local ____req_useRegex_7 = req.useRegex -- 1007
										if ____req_useRegex_7 == nil then -- 1007
											____req_useRegex_7 = false -- 1007
										end -- 1007
										local ____req_caseSensitive_8 = req.caseSensitive -- 1008
										if ____req_caseSensitive_8 == nil then -- 1008
											____req_caseSensitive_8 = false -- 1008
										end -- 1008
										local ____req_includeContent_9 = req.includeContent -- 1009
										if ____req_includeContent_9 == nil then -- 1009
											____req_includeContent_9 = true -- 1009
										end -- 1009
										allResults[#allResults + 1] = ____Content_searchFilesAsync_12( -- 1001
											____Content_11, -- 1001
											searchRoot, -- 1002
											codeExtensions, -- 1003
											extensionLevels, -- 1004
											searchGlobs, -- 1005
											____patterns_index_10, -- 1006
											____req_useRegex_7, -- 1007
											____req_caseSensitive_8, -- 1008
											____req_includeContent_9, -- 1009
											req.contentWindow or 120 -- 1010
										) -- 1010
										i = i + 1 -- 1000
									end -- 1000
								end -- 1000
								local results = mergeSearchFileResultsUnique(allResults) -- 1013
								local totalResults = #results -- 1014
								local limit = math.max( -- 1015
									1, -- 1015
									math.floor(req.limit or 20) -- 1015
								) -- 1015
								local offset = math.max( -- 1016
									0, -- 1016
									math.floor(req.offset or 0) -- 1016
								) -- 1016
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1017
								local nextOffset = offset + #paged -- 1018
								local hasMore = nextOffset < totalResults -- 1019
								local truncated = offset > 0 or hasMore -- 1020
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1021
								local groupByFile = req.groupByFile == true -- 1022
								resolve( -- 1023
									nil, -- 1023
									{ -- 1023
										success = true, -- 1024
										results = relativeResults, -- 1025
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1026
										totalResults = totalResults, -- 1027
										truncated = truncated, -- 1028
										limit = limit, -- 1029
										offset = offset, -- 1030
										nextOffset = nextOffset, -- 1031
										hasMore = hasMore, -- 1032
										groupByFile = groupByFile -- 1033
									} -- 1033
								) -- 1033
							end) -- 1033
							if not ____try then -- 1033
								____catch(____hasReturned) -- 1033
							end -- 1033
						end -- 1033
					end)) -- 994
				end -- 993
			) -- 993
		) -- 993
	end) -- 993
end -- 964
function ____exports.searchDoraAPI(req) -- 1042
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1042
		local pattern = __TS__StringTrim(req.pattern or "") -- 1053
		if pattern == "" then -- 1053
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1053
		end -- 1053
		local patterns = splitSearchPatterns(pattern) -- 1055
		if #patterns == 0 then -- 1055
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1055
		end -- 1055
		local docSource = req.docSource or "api" -- 1057
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1058
		local docRoot = target.root -- 1059
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1060
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1060
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1060
		end -- 1060
		local exts = target.exts -- 1064
		local dotExts = __TS__ArrayMap( -- 1065
			exts, -- 1065
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1065
		) -- 1065
		local globs = target.globs -- 1066
		local limit = math.max( -- 1067
			1, -- 1067
			math.floor(req.limit or 10) -- 1067
		) -- 1067
		return ____awaiter_resolve( -- 1067
			nil, -- 1067
			__TS__New( -- 1069
				__TS__Promise, -- 1069
				function(____, resolve) -- 1069
					Director.systemScheduler:schedule(once(function() -- 1070
						do -- 1070
							local function ____catch(e) -- 1070
								resolve( -- 1111
									nil, -- 1111
									{ -- 1111
										success = false, -- 1111
										message = tostring(e) -- 1111
									} -- 1111
								) -- 1111
							end -- 1111
							local ____try, ____hasReturned = pcall(function() -- 1111
								local allHits = {} -- 1072
								do -- 1072
									local p = 0 -- 1073
									while p < #patterns do -- 1073
										local ____Content_17 = Content -- 1074
										local ____Content_searchFilesAsync_18 = Content.searchFilesAsync -- 1074
										local ____array_16 = __TS__SparseArrayNew( -- 1074
											docRoot, -- 1075
											dotExts, -- 1076
											{}, -- 1077
											ensureSafeSearchGlobs(globs), -- 1078
											patterns[p + 1] -- 1079
										) -- 1079
										local ____req_useRegex_13 = req.useRegex -- 1080
										if ____req_useRegex_13 == nil then -- 1080
											____req_useRegex_13 = false -- 1080
										end -- 1080
										__TS__SparseArrayPush(____array_16, ____req_useRegex_13) -- 1080
										local ____req_caseSensitive_14 = req.caseSensitive -- 1081
										if ____req_caseSensitive_14 == nil then -- 1081
											____req_caseSensitive_14 = false -- 1081
										end -- 1081
										__TS__SparseArrayPush(____array_16, ____req_caseSensitive_14) -- 1081
										local ____req_includeContent_15 = req.includeContent -- 1082
										if ____req_includeContent_15 == nil then -- 1082
											____req_includeContent_15 = true -- 1082
										end -- 1082
										__TS__SparseArrayPush(____array_16, ____req_includeContent_15, req.contentWindow or 80) -- 1082
										local raw = ____Content_searchFilesAsync_18( -- 1074
											____Content_17, -- 1074
											__TS__SparseArraySpread(____array_16) -- 1074
										) -- 1074
										local hits = {} -- 1085
										do -- 1085
											local i = 0 -- 1086
											while i < #raw do -- 1086
												do -- 1086
													local row = raw[i + 1] -- 1087
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1088
													if file == "" then -- 1088
														goto __continue210 -- 1089
													end -- 1089
													hits[#hits + 1] = { -- 1090
														file = file, -- 1091
														line = type(row.line) == "number" and row.line or nil, -- 1092
														content = type(row.content) == "string" and row.content or nil -- 1093
													} -- 1093
												end -- 1093
												::__continue210:: -- 1093
												i = i + 1 -- 1086
											end -- 1086
										end -- 1086
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1096
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1096
											0, -- 1096
											limit -- 1096
										) -- 1096
										p = p + 1 -- 1073
									end -- 1073
								end -- 1073
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1098
								resolve(nil, { -- 1099
									success = true, -- 1100
									docSource = docSource, -- 1101
									docLanguage = req.docLanguage, -- 1102
									programmingLanguage = req.programmingLanguage, -- 1103
									exts = exts, -- 1104
									results = hits, -- 1105
									totalResults = #hits, -- 1106
									truncated = false, -- 1107
									limit = limit -- 1108
								}) -- 1108
							end) -- 1108
							if not ____try then -- 1108
								____catch(____hasReturned) -- 1108
							end -- 1108
						end -- 1108
					end)) -- 1070
				end -- 1069
			) -- 1069
		) -- 1069
	end) -- 1069
end -- 1042
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1117
	if options == nil then -- 1117
		options = {} -- 1117
	end -- 1117
	if #changes == 0 then -- 1117
		return {success = false, message = "empty changes"} -- 1119
	end -- 1119
	if not isValidWorkDir(workDir) then -- 1119
		return {success = false, message = "invalid workDir"} -- 1122
	end -- 1122
	if not getTaskStatus(taskId) then -- 1122
		return {success = false, message = "task not found"} -- 1125
	end -- 1125
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1127
	local dup = rejectDuplicatePaths(expandedChanges) -- 1128
	if dup then -- 1128
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1130
	end -- 1130
	for ____, change in ipairs(expandedChanges) do -- 1133
		if not isValidWorkspacePath(change.path) then -- 1133
			return {success = false, message = "invalid path: " .. change.path} -- 1135
		end -- 1135
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1135
			return {success = false, message = "missing content for " .. change.path} -- 1138
		end -- 1138
	end -- 1138
	local headSeq = getTaskHeadSeq(taskId) -- 1142
	if headSeq == nil then -- 1142
		return {success = false, message = "task not found"} -- 1143
	end -- 1143
	local nextSeq = headSeq + 1 -- 1144
	local checkpointId = insertCheckpoint( -- 1145
		taskId, -- 1145
		nextSeq, -- 1145
		options.summary or "", -- 1145
		options.toolName or "", -- 1145
		"PREPARED" -- 1145
	) -- 1145
	if checkpointId <= 0 then -- 1145
		return {success = false, message = "failed to create checkpoint"} -- 1147
	end -- 1147
	do -- 1147
		local i = 0 -- 1150
		while i < #expandedChanges do -- 1150
			local change = expandedChanges[i + 1] -- 1151
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1152
			if not fullPath then -- 1152
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1154
				return {success = false, message = "invalid path: " .. change.path} -- 1155
			end -- 1155
			local before = getFileState(fullPath) -- 1157
			local afterExists = change.op ~= "delete" -- 1158
			local afterContent = afterExists and (change.content or "") or "" -- 1159
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1160
				checkpointId, -- 1164
				i + 1, -- 1165
				change.path, -- 1166
				change.op, -- 1167
				before.exists and 1 or 0, -- 1168
				before.content, -- 1169
				afterExists and 1 or 0, -- 1170
				afterContent, -- 1171
				before.bytes, -- 1172
				#afterContent -- 1173
			}) -- 1173
			if inserted <= 0 then -- 1173
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1177
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1178
			end -- 1178
			i = i + 1 -- 1150
		end -- 1150
	end -- 1150
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1182
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1183
		if not fullPath then -- 1183
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1185
			return {success = false, message = "invalid path: " .. entry.path} -- 1186
		end -- 1186
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1188
		if not ok then -- 1188
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1190
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1191
		end -- 1191
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1191
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1194
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1195
		end -- 1195
	end -- 1195
	DB:exec( -- 1199
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1199
		{ -- 1201
			"APPLIED", -- 1201
			now(), -- 1201
			checkpointId -- 1201
		} -- 1201
	) -- 1201
	DB:exec( -- 1203
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1203
		{ -- 1205
			nextSeq, -- 1205
			now(), -- 1205
			taskId -- 1205
		} -- 1205
	) -- 1205
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1207
end -- 1117
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1215
	if not isValidWorkDir(workDir) then -- 1215
		return {success = false, message = "invalid workDir"} -- 1216
	end -- 1216
	if checkpointId <= 0 then -- 1216
		return {success = false, message = "invalid checkpointId"} -- 1217
	end -- 1217
	local entries = getCheckpointEntries(checkpointId, true) -- 1218
	if #entries == 0 then -- 1218
		return {success = false, message = "checkpoint not found or empty"} -- 1220
	end -- 1220
	for ____, entry in ipairs(entries) do -- 1222
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1223
		if not fullPath then -- 1223
			return {success = false, message = "invalid path: " .. entry.path} -- 1225
		end -- 1225
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1227
		if not ok then -- 1227
			Log( -- 1229
				"Error", -- 1229
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1229
			) -- 1229
			Log( -- 1230
				"Info", -- 1230
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1230
			) -- 1230
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1231
		end -- 1231
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1231
			Log( -- 1234
				"Error", -- 1234
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1234
			) -- 1234
			Log( -- 1235
				"Info", -- 1235
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1235
			) -- 1235
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1236
		end -- 1236
	end -- 1236
	return {success = true, checkpointId = checkpointId} -- 1239
end -- 1215
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1242
	return getCheckpointEntries(checkpointId, false) -- 1243
end -- 1242
function ____exports.getCheckpointDiff(checkpointId) -- 1246
	if checkpointId <= 0 then -- 1246
		return {success = false, message = "invalid checkpointId"} -- 1248
	end -- 1248
	local entries = getCheckpointEntries(checkpointId, false) -- 1250
	if #entries == 0 then -- 1250
		return {success = false, message = "checkpoint not found or empty"} -- 1252
	end -- 1252
	return { -- 1254
		success = true, -- 1255
		files = __TS__ArrayMap( -- 1256
			entries, -- 1256
			function(____, entry) return { -- 1256
				path = entry.path, -- 1257
				op = entry.op, -- 1258
				beforeExists = entry.beforeExists, -- 1259
				afterExists = entry.afterExists, -- 1260
				beforeContent = entry.beforeContent, -- 1261
				afterContent = entry.afterContent -- 1262
			} end -- 1262
		) -- 1262
	} -- 1262
end -- 1246
function ____exports.build(req) -- 1267
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1267
		local targetRel = req.path or "" -- 1268
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1269
		if not target then -- 1269
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1269
		end -- 1269
		if not Content:exist(target) then -- 1269
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1269
		end -- 1269
		local messages = {} -- 1276
		if not Content:isdir(target) then -- 1276
			local kind = getSupportedBuildKind(target) -- 1278
			if not kind then -- 1278
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1278
			end -- 1278
			if kind == "ts" then -- 1278
				local content = Content:load(target) -- 1283
				if content == nil then -- 1283
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1283
				end -- 1283
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1283
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1283
				end -- 1283
				if not isDtsFile(target) then -- 1283
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1291
				end -- 1291
			else -- 1291
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1294
			end -- 1294
			Log( -- 1296
				"Info", -- 1296
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1296
			) -- 1296
			return ____awaiter_resolve( -- 1296
				nil, -- 1296
				{ -- 1297
					success = true, -- 1298
					messages = __TS__ArrayMap( -- 1299
						messages, -- 1299
						function(____, m) return m.success and __TS__ObjectAssign( -- 1299
							{}, -- 1300
							m, -- 1300
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1300
						) or __TS__ObjectAssign( -- 1300
							{}, -- 1301
							m, -- 1301
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1301
						) end -- 1301
					) -- 1301
				} -- 1301
			) -- 1301
		end -- 1301
		local listResult = ____exports.listFiles({ -- 1304
			workDir = req.workDir, -- 1305
			path = target, -- 1306
			globs = __TS__ArrayMap( -- 1307
				codeExtensions, -- 1307
				function(____, e) return "**/*" .. e end -- 1307
			), -- 1307
			maxEntries = 10000 -- 1308
		}) -- 1308
		local relFiles = listResult.success and listResult.files or ({}) -- 1311
		local tsFileData = {} -- 1312
		local buildQueue = {} -- 1313
		for ____, rel in ipairs(relFiles) do -- 1314
			do -- 1314
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1315
				local kind = getSupportedBuildKind(file) -- 1316
				if not kind then -- 1316
					goto __continue259 -- 1317
				end -- 1317
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1318
				if kind ~= "ts" then -- 1318
					goto __continue259 -- 1320
				end -- 1320
				local content = Content:load(file) -- 1322
				if content == nil then -- 1322
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1324
					goto __continue259 -- 1325
				end -- 1325
				tsFileData[file] = content -- 1327
				if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1327
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1329
					goto __continue259 -- 1330
				end -- 1330
			end -- 1330
			::__continue259:: -- 1330
		end -- 1330
		do -- 1330
			local i = 0 -- 1333
			while i < #buildQueue do -- 1333
				do -- 1333
					local ____buildQueue_index_19 = buildQueue[i + 1] -- 1334
					local file = ____buildQueue_index_19.file -- 1334
					local kind = ____buildQueue_index_19.kind -- 1334
					if kind == "ts" then -- 1334
						local content = tsFileData[file] -- 1336
						if content == nil or isDtsFile(file) then -- 1336
							goto __continue266 -- 1338
						end -- 1338
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1340
						goto __continue266 -- 1341
					end -- 1341
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1343
				end -- 1343
				::__continue266:: -- 1343
				i = i + 1 -- 1333
			end -- 1333
		end -- 1333
		Log( -- 1345
			"Info", -- 1345
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1345
		) -- 1345
		return ____awaiter_resolve( -- 1345
			nil, -- 1345
			{ -- 1346
				success = true, -- 1347
				messages = __TS__ArrayMap( -- 1348
					messages, -- 1348
					function(____, m) return m.success and __TS__ObjectAssign( -- 1348
						{}, -- 1349
						m, -- 1349
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1349
					) or __TS__ObjectAssign( -- 1349
						{}, -- 1350
						m, -- 1350
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1350
					) end -- 1350
				) -- 1350
			} -- 1350
		) -- 1350
	end) -- 1350
end -- 1267
return ____exports -- 1267