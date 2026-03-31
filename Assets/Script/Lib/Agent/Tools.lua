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
function ensureSafeSearchGlobs(globs) -- 807
	local result = {} -- 808
	do -- 808
		local i = 0 -- 809
		while i < #globs do -- 809
			result[#result + 1] = globs[i + 1] -- 810
			i = i + 1 -- 809
		end -- 809
	end -- 809
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 812
	do -- 812
		local i = 0 -- 813
		while i < #requiredExcludes do -- 813
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 813
				result[#result + 1] = requiredExcludes[i + 1] -- 815
			end -- 815
			i = i + 1 -- 813
		end -- 813
	end -- 813
	return result -- 818
end -- 818
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
			local clone = __TS__ObjectAssign({}, row) -- 256
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 257
			mapped[#mapped + 1] = clone -- 258
			i = i + 1 -- 254
		end -- 254
	end -- 254
	return mapped -- 260
end -- 252
local function getDoraAPIDocRoot(docLanguage) -- 263
	local zhDir = Path( -- 264
		Content.assetPath, -- 264
		"Script", -- 264
		"Lib", -- 264
		"Dora", -- 264
		"zh-Hans" -- 264
	) -- 264
	local enDir = Path( -- 265
		Content.assetPath, -- 265
		"Script", -- 265
		"Lib", -- 265
		"Dora", -- 265
		"en" -- 265
	) -- 265
	return docLanguage == "zh" and zhDir or enDir -- 266
end -- 263
local function getDoraTutorialDocRoot(docLanguage) -- 269
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 270
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 271
	return docLanguage == "zh" and zhDir or enDir -- 272
end -- 269
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 275
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 275
		return {"ts"} -- 277
	end -- 277
	return {"tl"} -- 279
end -- 275
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 282
	repeat -- 282
		local ____switch37 = programmingLanguage -- 282
		local ____cond37 = ____switch37 == "teal" -- 282
		if ____cond37 then -- 282
			return "tl" -- 284
		end -- 284
		____cond37 = ____cond37 or ____switch37 == "tl" -- 284
		if ____cond37 then -- 284
			return "tl" -- 285
		end -- 285
		do -- 285
			return programmingLanguage -- 286
		end -- 286
	until true -- 286
end -- 282
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 290
	if docSource == "tutorial" then -- 290
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 296
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 297
		return { -- 298
			root = Path(tutorialRoot, langDir), -- 299
			exts = {"md"}, -- 300
			globs = {"**/*.md"} -- 301
		} -- 301
	end -- 301
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 304
	return { -- 305
		root = getDoraAPIDocRoot(docLanguage), -- 306
		exts = exts, -- 307
		globs = __TS__ArrayMap( -- 308
			exts, -- 308
			function(____, ext) return "**/*." .. ext end -- 308
		) -- 308
	} -- 308
end -- 290
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 312
	if docSource == "tutorial" then -- 312
		return getDoraTutorialDocRoot(docLanguage) -- 314
	end -- 314
	return getDoraAPIDocRoot(docLanguage) -- 316
end -- 312
local function toDocRelativePath(baseRoot, path) -- 319
	if not path or #path == 0 then -- 319
		return path -- 320
	end -- 320
	if not Content:isAbsolutePath(path) then -- 320
		return path -- 321
	end -- 321
	return Path:getRelative(path, baseRoot) -- 322
end -- 319
local function resolveAgentTutorialDocFilePath(path, docLanguage) -- 325
	if not docLanguage then -- 325
		return nil -- 326
	end -- 326
	if not isValidWorkspacePath(path) then -- 326
		return nil -- 327
	end -- 327
	local candidate = Path( -- 328
		getDoraTutorialDocRoot(docLanguage), -- 328
		path -- 328
	) -- 328
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 328
		return candidate -- 330
	end -- 330
	return nil -- 332
end -- 325
local function ensureDirPath(dir) -- 335
	if not dir or dir == "." or dir == "" then -- 335
		return true -- 336
	end -- 336
	if Content:exist(dir) then -- 336
		return Content:isdir(dir) -- 337
	end -- 337
	local parent = Path:getPath(dir) -- 338
	if parent and parent ~= dir and parent ~= "." and parent ~= "" then -- 338
		if not ensureDirPath(parent) then -- 338
			return false -- 340
		end -- 340
	end -- 340
	return Content:mkdir(dir) -- 342
end -- 335
local function ensureDirForFile(path) -- 345
	local dir = Path:getPath(path) -- 346
	return ensureDirPath(dir) -- 347
end -- 345
local function getFileState(path) -- 350
	local exists = Content:exist(path) -- 351
	if not exists then -- 351
		return {exists = false, content = "", bytes = 0} -- 353
	end -- 353
	local content = Content:load(path) -- 359
	return {exists = true, content = content, bytes = #content} -- 360
end -- 350
local function queryOne(sql, args) -- 367
	local ____args_0 -- 368
	if args then -- 368
		____args_0 = DB:query(sql, args) -- 368
	else -- 368
		____args_0 = DB:query(sql) -- 368
	end -- 368
	local rows = ____args_0 -- 368
	if not rows or #rows == 0 then -- 368
		return nil -- 369
	end -- 369
	return rows[1] -- 370
end -- 367
do -- 367
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 375
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 383
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 394
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 395
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 408
end -- 408
local function isDtsFile(path) -- 411
	return Path:getExt(Path:getName(path)) == "d" -- 412
end -- 411
local function getSupportedBuildKind(path) -- 417
	repeat -- 417
		local ____switch63 = Path:getExt(path) -- 417
		local ____cond63 = ____switch63 == "ts" or ____switch63 == "tsx" -- 417
		if ____cond63 then -- 417
			return "ts" -- 419
		end -- 419
		____cond63 = ____cond63 or ____switch63 == "xml" -- 419
		if ____cond63 then -- 419
			return "xml" -- 420
		end -- 420
		____cond63 = ____cond63 or ____switch63 == "tl" -- 420
		if ____cond63 then -- 420
			return "teal" -- 421
		end -- 421
		____cond63 = ____cond63 or ____switch63 == "lua" -- 421
		if ____cond63 then -- 421
			return "lua" -- 422
		end -- 422
		____cond63 = ____cond63 or ____switch63 == "yue" -- 422
		if ____cond63 then -- 422
			return "yue" -- 423
		end -- 423
		____cond63 = ____cond63 or ____switch63 == "yarn" -- 423
		if ____cond63 then -- 423
			return "yarn" -- 424
		end -- 424
		do -- 424
			return nil -- 425
		end -- 425
	until true -- 425
end -- 417
local function getTaskHeadSeq(taskId) -- 429
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 430
	if not row then -- 430
		return nil -- 431
	end -- 431
	return row[1] or 0 -- 432
end -- 429
local function getTaskStatus(taskId) -- 435
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 436
	if not row then -- 436
		return nil -- 437
	end -- 437
	return toStr(row[1]) -- 438
end -- 435
local function getLastInsertRowId() -- 441
	local row = queryOne("SELECT last_insert_rowid()") -- 442
	return row and (row[1] or 0) or 0 -- 443
end -- 441
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 446
	DB:exec( -- 447
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 447
		{ -- 449
			taskId, -- 449
			seq, -- 449
			status, -- 449
			summary, -- 449
			toolName, -- 449
			now() -- 449
		} -- 449
	) -- 449
	return getLastInsertRowId() -- 451
end -- 446
local function getCheckpointEntries(checkpointId, desc) -- 454
	if desc == nil then -- 454
		desc = false -- 454
	end -- 454
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 455
	if not rows then -- 455
		return {} -- 462
	end -- 462
	local result = {} -- 463
	do -- 463
		local i = 0 -- 464
		while i < #rows do -- 464
			local row = rows[i + 1] -- 465
			result[#result + 1] = { -- 466
				id = row[1], -- 467
				ord = row[2], -- 468
				path = toStr(row[3]), -- 469
				op = toStr(row[4]), -- 470
				beforeExists = toBool(row[5]), -- 471
				beforeContent = toStr(row[6]), -- 472
				afterExists = toBool(row[7]), -- 473
				afterContent = toStr(row[8]) -- 474
			} -- 474
			i = i + 1 -- 464
		end -- 464
	end -- 464
	return result -- 477
end -- 454
local function rejectDuplicatePaths(changes) -- 480
	local seen = __TS__New(Set) -- 481
	for ____, change in ipairs(changes) do -- 482
		local key = change.path -- 483
		if seen:has(key) then -- 483
			return key -- 484
		end -- 484
		seen:add(key) -- 485
	end -- 485
	return nil -- 487
end -- 480
local function getLinkedDeletePaths(workDir, path) -- 490
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 491
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 491
		return {} -- 492
	end -- 492
	local parent = Path:getPath(fullPath) -- 493
	local baseName = string.lower(Path:getName(fullPath)) -- 494
	local ext = Path:getExt(fullPath) -- 495
	local linked = {} -- 496
	for ____, file in ipairs(Content:getFiles(parent)) do -- 497
		do -- 497
			if string.lower(Path:getName(file)) ~= baseName then -- 497
				goto __continue80 -- 498
			end -- 498
			local siblingExt = Path:getExt(file) -- 499
			if siblingExt == "tl" and ext == "vs" then -- 499
				linked[#linked + 1] = toWorkspaceRelativePath( -- 501
					workDir, -- 501
					Path(parent, file) -- 501
				) -- 501
				goto __continue80 -- 502
			end -- 502
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 502
				linked[#linked + 1] = toWorkspaceRelativePath( -- 505
					workDir, -- 505
					Path(parent, file) -- 505
				) -- 505
			end -- 505
		end -- 505
		::__continue80:: -- 505
	end -- 505
	return linked -- 508
end -- 490
local function expandLinkedDeleteChanges(workDir, changes) -- 511
	local expanded = {} -- 512
	local seen = __TS__New(Set) -- 513
	do -- 513
		local i = 0 -- 514
		while i < #changes do -- 514
			do -- 514
				local change = changes[i + 1] -- 515
				if not seen:has(change.path) then -- 515
					seen:add(change.path) -- 517
					expanded[#expanded + 1] = change -- 518
				end -- 518
				if change.op ~= "delete" then -- 518
					goto __continue87 -- 520
				end -- 520
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 521
				do -- 521
					local j = 0 -- 522
					while j < #linkedPaths do -- 522
						do -- 522
							local linkedPath = linkedPaths[j + 1] -- 523
							if seen:has(linkedPath) then -- 523
								goto __continue91 -- 524
							end -- 524
							seen:add(linkedPath) -- 525
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 526
						end -- 526
						::__continue91:: -- 526
						j = j + 1 -- 522
					end -- 522
				end -- 522
			end -- 522
			::__continue87:: -- 522
			i = i + 1 -- 514
		end -- 514
	end -- 514
	return expanded -- 529
end -- 511
local function applySingleFile(path, exists, content) -- 532
	if exists then -- 532
		if not ensureDirForFile(path) then -- 532
			return false -- 534
		end -- 534
		return Content:save(path, content) -- 535
	end -- 535
	if Content:exist(path) then -- 535
		return Content:remove(path) -- 538
	end -- 538
	return true -- 540
end -- 532
local function encodeJSON(obj) -- 543
	local text = safeJsonEncode(obj) -- 544
	return text -- 545
end -- 543
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 548
	if HttpServer.wsConnectionCount == 0 then -- 548
		return true -- 550
	end -- 550
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 552
	if not payload then -- 552
		return false -- 554
	end -- 554
	emit("AppWS", "Send", payload) -- 556
	return true -- 557
end -- 548
local function runSingleNonTsBuild(file) -- 560
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 560
		return ____awaiter_resolve( -- 560
			nil, -- 560
			__TS__New( -- 561
				__TS__Promise, -- 561
				function(____, resolve) -- 561
					local ____require_result_1 = require("Script.Dev.WebServer") -- 562
					local buildAsync = ____require_result_1.buildAsync -- 562
					Director.systemScheduler:schedule(once(function() -- 563
						local result = buildAsync(file) -- 564
						resolve(nil, result) -- 565
					end)) -- 563
				end -- 561
			) -- 561
		) -- 561
	end) -- 561
end -- 560
function ____exports.runSingleTsTranspile(file, content) -- 570
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 570
		local done = false -- 571
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 572
		if HttpServer.wsConnectionCount == 0 then -- 572
			return ____awaiter_resolve(nil, result) -- 572
		end -- 572
		local listener = Node() -- 580
		listener:gslot( -- 581
			"AppWS", -- 581
			function(event) -- 581
				if event.type ~= "Receive" then -- 581
					return -- 582
				end -- 582
				local res = safeJsonDecode(event.msg) -- 583
				if not res or __TS__ArrayIsArray(res) then -- 583
					return -- 584
				end -- 584
				local payload = res -- 585
				if payload.name ~= "TranspileTS" then -- 585
					return -- 586
				end -- 586
				if payload.success then -- 586
					local luaFile = Path:replaceExt(file, "lua") -- 588
					if Content:save( -- 588
						luaFile, -- 589
						tostring(payload.luaCode) -- 589
					) then -- 589
						result = {success = true, file = file} -- 590
					else -- 590
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 592
					end -- 592
				else -- 592
					result = { -- 595
						success = false, -- 595
						file = file, -- 595
						message = tostring(payload.message) -- 595
					} -- 595
				end -- 595
				done = true -- 597
			end -- 581
		) -- 581
		local payload = encodeJSON({name = "TranspileTS", file = file, content = content}) -- 599
		if not payload then -- 599
			listener:removeFromParent() -- 605
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 605
		end -- 605
		__TS__Await(__TS__New( -- 608
			__TS__Promise, -- 608
			function(____, resolve) -- 608
				Director.systemScheduler:schedule(once(function() -- 609
					emit("AppWS", "Send", payload) -- 610
					wait(function() return done end) -- 611
					if not done then -- 611
						listener:removeFromParent() -- 613
					end -- 613
					resolve(nil) -- 615
				end)) -- 609
			end -- 608
		)) -- 608
		return ____awaiter_resolve(nil, result) -- 608
	end) -- 608
end -- 570
function ____exports.createTask(prompt) -- 621
	if prompt == nil then -- 621
		prompt = "" -- 621
	end -- 621
	local t = now() -- 622
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 623
	if affected <= 0 then -- 623
		return {success = false, message = "failed to create task"} -- 628
	end -- 628
	return { -- 630
		success = true, -- 630
		taskId = getLastInsertRowId() -- 630
	} -- 630
end -- 621
function ____exports.setTaskStatus(taskId, status) -- 633
	DB:exec( -- 634
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 634
		{ -- 634
			status, -- 634
			now(), -- 634
			taskId -- 634
		} -- 634
	) -- 634
	Log( -- 635
		"Info", -- 635
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 635
	) -- 635
end -- 633
function ____exports.listCheckpoints(taskId) -- 638
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 639
	if not rows then -- 639
		return {} -- 646
	end -- 646
	local items = {} -- 647
	do -- 647
		local i = 0 -- 648
		while i < #rows do -- 648
			local row = rows[i + 1] -- 649
			items[#items + 1] = { -- 650
				id = row[1], -- 651
				taskId = row[2], -- 652
				seq = row[3], -- 653
				status = toStr(row[4]), -- 654
				summary = toStr(row[5]), -- 655
				toolName = toStr(row[6]), -- 656
				createdAt = row[7] -- 657
			} -- 657
			i = i + 1 -- 648
		end -- 648
	end -- 648
	return items -- 660
end -- 638
local function readWorkspaceFile(workDir, path, docLanguage) -- 663
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 664
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 664
		return { -- 666
			success = true, -- 666
			content = Content:load(fullPath) -- 666
		} -- 666
	end -- 666
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 668
	if docPath then -- 668
		return { -- 670
			success = true, -- 670
			content = Content:load(docPath) -- 670
		} -- 670
	end -- 670
	if not fullPath then -- 670
		return {success = false, message = "invalid path or workDir"} -- 672
	end -- 672
	return {success = false, message = "file not found"} -- 673
end -- 663
function ____exports.readFileRaw(workDir, path, docLanguage) -- 676
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 677
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 677
		return { -- 679
			success = true, -- 679
			content = Content:load(path) -- 679
		} -- 679
	end -- 679
	return result -- 681
end -- 676
local function getEngineLogText() -- 684
	local folder = Path(Content.writablePath, ENGINE_LOG_SNAPSHOT_DIR) -- 685
	if not Content:exist(folder) then -- 685
		Content:mkdir(folder) -- 687
	end -- 687
	local logPath = Path(folder, ENGINE_LOG_SNAPSHOT_FILE) -- 689
	if not App:saveLog(logPath) then -- 689
		return nil -- 691
	end -- 691
	return Content:load(logPath) -- 693
end -- 684
function ____exports.getLogs(req) -- 696
	local text = getEngineLogText() -- 697
	if text == nil then -- 697
		return {success = false, message = "failed to read engine logs"} -- 699
	end -- 699
	local tailLines = math.max( -- 701
		1, -- 701
		math.floor(req and req.tailLines or 200) -- 701
	) -- 701
	local allLines = __TS__StringSplit(text, "\n") -- 702
	local logs = __TS__ArraySlice( -- 703
		allLines, -- 703
		math.max(0, #allLines - tailLines) -- 703
	) -- 703
	return req and req.joinText and ({ -- 704
		success = true, -- 704
		logs = logs, -- 704
		text = table.concat(logs, "\n") -- 704
	}) or ({success = true, logs = logs}) -- 704
end -- 696
function ____exports.listFiles(req) -- 707
	local root = req.path or "" -- 713
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 714
	if not searchRoot then -- 714
		return {success = false, message = "invalid path or workDir"} -- 716
	end -- 716
	do -- 716
		local function ____catch(e) -- 716
			return true, { -- 734
				success = false, -- 734
				message = tostring(e) -- 734
			} -- 734
		end -- 734
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 734
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 719
			local globs = ensureSafeSearchGlobs(userGlobs) -- 720
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 721
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 722
			local totalEntries = #files -- 723
			local maxEntries = math.max( -- 724
				1, -- 724
				math.floor(req.maxEntries or 200) -- 724
			) -- 724
			local truncated = totalEntries > maxEntries -- 725
			return true, { -- 726
				success = true, -- 727
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 728
				totalEntries = totalEntries, -- 729
				truncated = truncated, -- 730
				maxEntries = maxEntries -- 731
			} -- 731
		end) -- 731
		if not ____try then -- 731
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 731
		end -- 731
		if ____hasReturned then -- 731
			return ____returnValue -- 718
		end -- 718
	end -- 718
end -- 707
local function formatReadSlice(content, startLine, limit) -- 738
	local lines = __TS__StringSplit(content, "\n") -- 743
	local totalLines = #lines -- 744
	if totalLines == 0 then -- 744
		return { -- 746
			success = true, -- 747
			content = "", -- 748
			totalLines = 0, -- 749
			startLine = 1, -- 750
			endLine = 0, -- 751
			truncated = false -- 752
		} -- 752
	end -- 752
	local start = math.max( -- 755
		1, -- 755
		math.floor(startLine) -- 755
	) -- 755
	if start > totalLines then -- 755
		return { -- 757
			success = false, -- 757
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 757
		} -- 757
	end -- 757
	local boundedLimit = math.max( -- 759
		1, -- 759
		math.floor(limit) -- 759
	) -- 759
	local ____end = math.min(totalLines, start + boundedLimit - 1) -- 760
	local slice = {} -- 761
	do -- 761
		local i = start -- 762
		while i <= ____end do -- 762
			slice[#slice + 1] = lines[i] -- 763
			i = i + 1 -- 762
		end -- 762
	end -- 762
	local truncated = ____end < totalLines -- 765
	local hint = truncated and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use offset=") .. tostring(____end + 1)) .. " to continue.)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)" -- 766
	local body = table.concat(slice, "\n") -- 769
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 770
	return { -- 771
		success = true, -- 772
		content = output, -- 773
		totalLines = totalLines, -- 774
		startLine = start, -- 775
		endLine = ____end, -- 776
		truncated = truncated -- 777
	} -- 777
end -- 738
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 781
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 788
	if not fallback.success or fallback.content == nil then -- 788
		return fallback -- 789
	end -- 789
	local s = math.max( -- 790
		1, -- 790
		math.floor(startLine or 1) -- 790
	) -- 790
	local e = math.max( -- 791
		s, -- 791
		math.floor(endLine or 300) -- 791
	) -- 791
	return formatReadSlice(fallback.content, s, e - s + 1) -- 792
end -- 781
local codeExtensions = { -- 795
	".lua", -- 795
	".tl", -- 795
	".yue", -- 795
	".ts", -- 795
	".tsx", -- 795
	".xml", -- 795
	".md", -- 795
	".yarn", -- 795
	".wa", -- 795
	".mod" -- 795
} -- 795
extensionLevels = { -- 796
	vs = 2, -- 797
	bl = 2, -- 798
	ts = 1, -- 799
	tsx = 1, -- 800
	tl = 1, -- 801
	yue = 1, -- 802
	xml = 1, -- 803
	lua = 0 -- 804
} -- 804
local function splitSearchPatterns(pattern) -- 821
	local trimmed = __TS__StringTrim(pattern or "") -- 822
	if trimmed == "" then -- 822
		return {} -- 823
	end -- 823
	local out = {} -- 824
	local seen = __TS__New(Set) -- 825
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 826
		local p = __TS__StringTrim(tostring(p0)) -- 827
		if p ~= "" and not seen:has(p) then -- 827
			seen:add(p) -- 829
			out[#out + 1] = p -- 830
		end -- 830
	end -- 830
	return out -- 833
end -- 821
local function mergeSearchFileResultsUnique(resultsList) -- 836
	local merged = {} -- 837
	local seen = __TS__New(Set) -- 838
	do -- 838
		local i = 0 -- 839
		while i < #resultsList do -- 839
			local list = resultsList[i + 1] -- 840
			do -- 840
				local j = 0 -- 841
				while j < #list do -- 841
					do -- 841
						local row = list[j + 1] -- 842
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 843
						if seen:has(key) then -- 843
							goto __continue162 -- 844
						end -- 844
						seen:add(key) -- 845
						merged[#merged + 1] = list[j + 1] -- 846
					end -- 846
					::__continue162:: -- 846
					j = j + 1 -- 841
				end -- 841
			end -- 841
			i = i + 1 -- 839
		end -- 839
	end -- 839
	return merged -- 849
end -- 836
local function buildGroupedSearchResults(results) -- 852
	local order = {} -- 857
	local grouped = __TS__New(Map) -- 858
	do -- 858
		local i = 0 -- 863
		while i < #results do -- 863
			local row = results[i + 1] -- 864
			local file = row.file -- 865
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 866
			local bucket = grouped:get(key) -- 867
			if not bucket then -- 867
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 869
				grouped:set(key, bucket) -- 870
				order[#order + 1] = key -- 871
			end -- 871
			bucket.totalMatches = bucket.totalMatches + 1 -- 873
			local ____bucket_matches_6 = bucket.matches -- 873
			____bucket_matches_6[#____bucket_matches_6 + 1] = results[i + 1] -- 874
			i = i + 1 -- 863
		end -- 863
	end -- 863
	local out = {} -- 876
	do -- 876
		local i = 0 -- 881
		while i < #order do -- 881
			local bucket = grouped:get(order[i + 1]) -- 882
			if bucket then -- 882
				out[#out + 1] = bucket -- 883
			end -- 883
			i = i + 1 -- 881
		end -- 881
	end -- 881
	return out -- 885
end -- 852
local function mergeDoraAPISearchHitsUnique(resultsList) -- 888
	local merged = {} -- 889
	local seen = __TS__New(Set) -- 890
	local index = 0 -- 891
	local advanced = true -- 892
	while advanced do -- 892
		advanced = false -- 894
		do -- 894
			local i = 0 -- 895
			while i < #resultsList do -- 895
				do -- 895
					local list = resultsList[i + 1] -- 896
					if index >= #list then -- 896
						goto __continue174 -- 897
					end -- 897
					advanced = true -- 898
					local row = list[index + 1] -- 899
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 900
					if seen:has(key) then -- 900
						goto __continue174 -- 901
					end -- 901
					seen:add(key) -- 902
					merged[#merged + 1] = row -- 903
				end -- 903
				::__continue174:: -- 903
				i = i + 1 -- 895
			end -- 895
		end -- 895
		index = index + 1 -- 905
	end -- 905
	return merged -- 907
end -- 888
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 910
	if docSource ~= "api" then -- 910
		return 100 -- 911
	end -- 911
	if programmingLanguage ~= "tsx" then -- 911
		return 100 -- 912
	end -- 912
	repeat -- 912
		local ____switch180 = string.lower(Path:getFilename(file)) -- 912
		local ____cond180 = ____switch180 == "jsx.d.ts" -- 912
		if ____cond180 then -- 912
			return 0 -- 914
		end -- 914
		____cond180 = ____cond180 or ____switch180 == "dorax.d.ts" -- 914
		if ____cond180 then -- 914
			return 1 -- 915
		end -- 915
		____cond180 = ____cond180 or ____switch180 == "dora.d.ts" -- 915
		if ____cond180 then -- 915
			return 2 -- 916
		end -- 916
		do -- 916
			return 100 -- 917
		end -- 917
	until true -- 917
end -- 910
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 921
	local sorted = __TS__ArraySlice(hits) -- 926
	__TS__ArraySort( -- 927
		sorted, -- 927
		function(____, a, b) -- 927
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 928
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 929
			if pa ~= pb then -- 929
				return pa - pb -- 930
			end -- 930
			local fa = string.lower(a.file) -- 931
			local fb = string.lower(b.file) -- 932
			if fa ~= fb then -- 932
				return fa < fb and -1 or 1 -- 933
			end -- 933
			return (a.line or 0) - (b.line or 0) -- 934
		end -- 927
	) -- 927
	return sorted -- 936
end -- 921
function ____exports.searchFiles(req) -- 939
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 939
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 952
		if not resolvedPath then -- 952
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 952
		end -- 952
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 956
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 957
		if not searchRoot then -- 957
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 957
		end -- 957
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 957
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 957
		end -- 957
		local patterns = splitSearchPatterns(req.pattern) -- 964
		if #patterns == 0 then -- 964
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 964
		end -- 964
		return ____awaiter_resolve( -- 964
			nil, -- 964
			__TS__New( -- 968
				__TS__Promise, -- 968
				function(____, resolve) -- 968
					Director.systemScheduler:schedule(once(function() -- 969
						do -- 969
							local function ____catch(e) -- 969
								resolve( -- 1011
									nil, -- 1011
									{ -- 1011
										success = false, -- 1011
										message = tostring(e) -- 1011
									} -- 1011
								) -- 1011
							end -- 1011
							local ____try, ____hasReturned = pcall(function() -- 1011
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 971
								local allResults = {} -- 974
								do -- 974
									local i = 0 -- 975
									while i < #patterns do -- 975
										local ____Content_11 = Content -- 976
										local ____Content_searchFilesAsync_12 = Content.searchFilesAsync -- 976
										local ____patterns_index_10 = patterns[i + 1] -- 981
										local ____req_useRegex_7 = req.useRegex -- 982
										if ____req_useRegex_7 == nil then -- 982
											____req_useRegex_7 = false -- 982
										end -- 982
										local ____req_caseSensitive_8 = req.caseSensitive -- 983
										if ____req_caseSensitive_8 == nil then -- 983
											____req_caseSensitive_8 = false -- 983
										end -- 983
										local ____req_includeContent_9 = req.includeContent -- 984
										if ____req_includeContent_9 == nil then -- 984
											____req_includeContent_9 = true -- 984
										end -- 984
										allResults[#allResults + 1] = ____Content_searchFilesAsync_12( -- 976
											____Content_11, -- 976
											searchRoot, -- 977
											codeExtensions, -- 978
											extensionLevels, -- 979
											searchGlobs, -- 980
											____patterns_index_10, -- 981
											____req_useRegex_7, -- 982
											____req_caseSensitive_8, -- 983
											____req_includeContent_9, -- 984
											req.contentWindow or 120 -- 985
										) -- 985
										i = i + 1 -- 975
									end -- 975
								end -- 975
								local results = mergeSearchFileResultsUnique(allResults) -- 988
								local totalResults = #results -- 989
								local limit = math.max( -- 990
									1, -- 990
									math.floor(req.limit or 20) -- 990
								) -- 990
								local offset = math.max( -- 991
									0, -- 991
									math.floor(req.offset or 0) -- 991
								) -- 991
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 992
								local nextOffset = offset + #paged -- 993
								local hasMore = nextOffset < totalResults -- 994
								local truncated = offset > 0 or hasMore -- 995
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 996
								local groupByFile = req.groupByFile == true -- 997
								resolve( -- 998
									nil, -- 998
									{ -- 998
										success = true, -- 999
										results = relativeResults, -- 1000
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1001
										totalResults = totalResults, -- 1002
										truncated = truncated, -- 1003
										limit = limit, -- 1004
										offset = offset, -- 1005
										nextOffset = nextOffset, -- 1006
										hasMore = hasMore, -- 1007
										groupByFile = groupByFile -- 1008
									} -- 1008
								) -- 1008
							end) -- 1008
							if not ____try then -- 1008
								____catch(____hasReturned) -- 1008
							end -- 1008
						end -- 1008
					end)) -- 969
				end -- 968
			) -- 968
		) -- 968
	end) -- 968
end -- 939
function ____exports.searchDoraAPI(req) -- 1017
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1017
		local pattern = __TS__StringTrim(req.pattern or "") -- 1028
		if pattern == "" then -- 1028
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1028
		end -- 1028
		local patterns = splitSearchPatterns(pattern) -- 1030
		if #patterns == 0 then -- 1030
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1030
		end -- 1030
		local docSource = req.docSource or "api" -- 1032
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1033
		local docRoot = target.root -- 1034
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1035
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1035
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1035
		end -- 1035
		local exts = target.exts -- 1039
		local dotExts = __TS__ArrayMap( -- 1040
			exts, -- 1040
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1040
		) -- 1040
		local globs = target.globs -- 1041
		local limit = math.max( -- 1042
			1, -- 1042
			math.floor(req.limit or 10) -- 1042
		) -- 1042
		return ____awaiter_resolve( -- 1042
			nil, -- 1042
			__TS__New( -- 1044
				__TS__Promise, -- 1044
				function(____, resolve) -- 1044
					Director.systemScheduler:schedule(once(function() -- 1045
						do -- 1045
							local function ____catch(e) -- 1045
								resolve( -- 1087
									nil, -- 1087
									{ -- 1087
										success = false, -- 1087
										message = tostring(e) -- 1087
									} -- 1087
								) -- 1087
							end -- 1087
							local ____try, ____hasReturned = pcall(function() -- 1087
								local allHits = {} -- 1047
								do -- 1047
									local p = 0 -- 1048
									while p < #patterns do -- 1048
										local ____Content_17 = Content -- 1049
										local ____Content_searchFilesAsync_18 = Content.searchFilesAsync -- 1049
										local ____array_16 = __TS__SparseArrayNew( -- 1049
											docRoot, -- 1050
											dotExts, -- 1051
											{}, -- 1052
											ensureSafeSearchGlobs(globs), -- 1053
											patterns[p + 1] -- 1054
										) -- 1054
										local ____req_useRegex_13 = req.useRegex -- 1055
										if ____req_useRegex_13 == nil then -- 1055
											____req_useRegex_13 = false -- 1055
										end -- 1055
										__TS__SparseArrayPush(____array_16, ____req_useRegex_13) -- 1055
										local ____req_caseSensitive_14 = req.caseSensitive -- 1056
										if ____req_caseSensitive_14 == nil then -- 1056
											____req_caseSensitive_14 = false -- 1056
										end -- 1056
										__TS__SparseArrayPush(____array_16, ____req_caseSensitive_14) -- 1056
										local ____req_includeContent_15 = req.includeContent -- 1057
										if ____req_includeContent_15 == nil then -- 1057
											____req_includeContent_15 = true -- 1057
										end -- 1057
										__TS__SparseArrayPush(____array_16, ____req_includeContent_15, req.contentWindow or 80) -- 1057
										local raw = ____Content_searchFilesAsync_18( -- 1049
											____Content_17, -- 1049
											__TS__SparseArraySpread(____array_16) -- 1049
										) -- 1049
										local hits = {} -- 1060
										do -- 1060
											local i = 0 -- 1061
											while i < #raw do -- 1061
												do -- 1061
													local row = raw[i + 1] -- 1062
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1063
													if file == "" then -- 1063
														goto __continue207 -- 1064
													end -- 1064
													hits[#hits + 1] = { -- 1065
														file = file, -- 1066
														line = type(row.line) == "number" and row.line or nil, -- 1067
														content = type(row.content) == "string" and row.content or nil -- 1068
													} -- 1068
												end -- 1068
												::__continue207:: -- 1068
												i = i + 1 -- 1061
											end -- 1061
										end -- 1061
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1071
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1071
											0, -- 1071
											limit -- 1071
										) -- 1071
										p = p + 1 -- 1048
									end -- 1048
								end -- 1048
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1073
								resolve(nil, { -- 1074
									success = true, -- 1075
									docSource = docSource, -- 1076
									docLanguage = req.docLanguage, -- 1077
									programmingLanguage = req.programmingLanguage, -- 1078
									root = docRoot, -- 1079
									exts = exts, -- 1080
									results = hits, -- 1081
									totalResults = #hits, -- 1082
									truncated = false, -- 1083
									limit = limit -- 1084
								}) -- 1084
							end) -- 1084
							if not ____try then -- 1084
								____catch(____hasReturned) -- 1084
							end -- 1084
						end -- 1084
					end)) -- 1045
				end -- 1044
			) -- 1044
		) -- 1044
	end) -- 1044
end -- 1017
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1093
	if options == nil then -- 1093
		options = {} -- 1093
	end -- 1093
	if #changes == 0 then -- 1093
		return {success = false, message = "empty changes"} -- 1095
	end -- 1095
	if not isValidWorkDir(workDir) then -- 1095
		return {success = false, message = "invalid workDir"} -- 1098
	end -- 1098
	if not getTaskStatus(taskId) then -- 1098
		return {success = false, message = "task not found"} -- 1101
	end -- 1101
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1103
	local dup = rejectDuplicatePaths(expandedChanges) -- 1104
	if dup then -- 1104
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1106
	end -- 1106
	for ____, change in ipairs(expandedChanges) do -- 1109
		if not isValidWorkspacePath(change.path) then -- 1109
			return {success = false, message = "invalid path: " .. change.path} -- 1111
		end -- 1111
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1111
			return {success = false, message = "missing content for " .. change.path} -- 1114
		end -- 1114
	end -- 1114
	local headSeq = getTaskHeadSeq(taskId) -- 1118
	if headSeq == nil then -- 1118
		return {success = false, message = "task not found"} -- 1119
	end -- 1119
	local nextSeq = headSeq + 1 -- 1120
	local checkpointId = insertCheckpoint( -- 1121
		taskId, -- 1121
		nextSeq, -- 1121
		options.summary or "", -- 1121
		options.toolName or "", -- 1121
		"PREPARED" -- 1121
	) -- 1121
	if checkpointId <= 0 then -- 1121
		return {success = false, message = "failed to create checkpoint"} -- 1123
	end -- 1123
	do -- 1123
		local i = 0 -- 1126
		while i < #expandedChanges do -- 1126
			local change = expandedChanges[i + 1] -- 1127
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1128
			if not fullPath then -- 1128
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1130
				return {success = false, message = "invalid path: " .. change.path} -- 1131
			end -- 1131
			local before = getFileState(fullPath) -- 1133
			local afterExists = change.op ~= "delete" -- 1134
			local afterContent = afterExists and (change.content or "") or "" -- 1135
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1136
				checkpointId, -- 1140
				i + 1, -- 1141
				change.path, -- 1142
				change.op, -- 1143
				before.exists and 1 or 0, -- 1144
				before.content, -- 1145
				afterExists and 1 or 0, -- 1146
				afterContent, -- 1147
				before.bytes, -- 1148
				#afterContent -- 1149
			}) -- 1149
			if inserted <= 0 then -- 1149
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1153
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1154
			end -- 1154
			i = i + 1 -- 1126
		end -- 1126
	end -- 1126
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1158
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1159
		if not fullPath then -- 1159
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1161
			return {success = false, message = "invalid path: " .. entry.path} -- 1162
		end -- 1162
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1164
		if not ok then -- 1164
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1166
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1167
		end -- 1167
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1167
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1170
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1171
		end -- 1171
	end -- 1171
	DB:exec( -- 1175
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1175
		{ -- 1177
			"APPLIED", -- 1177
			now(), -- 1177
			checkpointId -- 1177
		} -- 1177
	) -- 1177
	DB:exec( -- 1179
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1179
		{ -- 1181
			nextSeq, -- 1181
			now(), -- 1181
			taskId -- 1181
		} -- 1181
	) -- 1181
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1183
end -- 1093
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1191
	if not isValidWorkDir(workDir) then -- 1191
		return {success = false, message = "invalid workDir"} -- 1192
	end -- 1192
	if checkpointId <= 0 then -- 1192
		return {success = false, message = "invalid checkpointId"} -- 1193
	end -- 1193
	local entries = getCheckpointEntries(checkpointId, true) -- 1194
	if #entries == 0 then -- 1194
		return {success = false, message = "checkpoint not found or empty"} -- 1196
	end -- 1196
	for ____, entry in ipairs(entries) do -- 1198
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1199
		if not fullPath then -- 1199
			return {success = false, message = "invalid path: " .. entry.path} -- 1201
		end -- 1201
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1203
		if not ok then -- 1203
			Log( -- 1205
				"Error", -- 1205
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1205
			) -- 1205
			Log( -- 1206
				"Info", -- 1206
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1206
			) -- 1206
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1207
		end -- 1207
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1207
			Log( -- 1210
				"Error", -- 1210
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1210
			) -- 1210
			Log( -- 1211
				"Info", -- 1211
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1211
			) -- 1211
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1212
		end -- 1212
	end -- 1212
	return {success = true, checkpointId = checkpointId} -- 1215
end -- 1191
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1218
	return getCheckpointEntries(checkpointId, false) -- 1219
end -- 1218
function ____exports.getCheckpointDiff(checkpointId) -- 1222
	if checkpointId <= 0 then -- 1222
		return {success = false, message = "invalid checkpointId"} -- 1224
	end -- 1224
	local entries = getCheckpointEntries(checkpointId, false) -- 1226
	if #entries == 0 then -- 1226
		return {success = false, message = "checkpoint not found or empty"} -- 1228
	end -- 1228
	return { -- 1230
		success = true, -- 1231
		files = __TS__ArrayMap( -- 1232
			entries, -- 1232
			function(____, entry) return { -- 1232
				path = entry.path, -- 1233
				op = entry.op, -- 1234
				beforeExists = entry.beforeExists, -- 1235
				afterExists = entry.afterExists, -- 1236
				beforeContent = entry.beforeContent, -- 1237
				afterContent = entry.afterContent -- 1238
			} end -- 1238
		) -- 1238
	} -- 1238
end -- 1222
function ____exports.build(req) -- 1243
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1243
		local targetRel = req.path or "" -- 1244
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1245
		if not target then -- 1245
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1245
		end -- 1245
		if not Content:exist(target) then -- 1245
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1245
		end -- 1245
		local messages = {} -- 1252
		if not Content:isdir(target) then -- 1252
			local kind = getSupportedBuildKind(target) -- 1254
			if not kind then -- 1254
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1254
			end -- 1254
			if kind == "ts" then -- 1254
				local content = Content:load(target) -- 1259
				if content == nil then -- 1259
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1259
				end -- 1259
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1259
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1259
				end -- 1259
				if not isDtsFile(target) then -- 1259
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1267
				end -- 1267
			else -- 1267
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1270
			end -- 1270
			Log( -- 1272
				"Info", -- 1272
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1272
			) -- 1272
			return ____awaiter_resolve( -- 1272
				nil, -- 1272
				{ -- 1273
					success = true, -- 1274
					messages = __TS__ArrayMap( -- 1275
						messages, -- 1275
						function(____, m) return m.success and __TS__ObjectAssign( -- 1275
							{}, -- 1276
							m, -- 1276
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1276
						) or __TS__ObjectAssign( -- 1276
							{}, -- 1277
							m, -- 1277
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1277
						) end -- 1277
					) -- 1277
				} -- 1277
			) -- 1277
		end -- 1277
		local listResult = ____exports.listFiles({ -- 1280
			workDir = req.workDir, -- 1281
			path = target, -- 1282
			globs = __TS__ArrayMap( -- 1283
				codeExtensions, -- 1283
				function(____, e) return "**/*" .. e end -- 1283
			), -- 1283
			maxEntries = 10000 -- 1284
		}) -- 1284
		local relFiles = listResult.success and listResult.files or ({}) -- 1287
		local tsFileData = {} -- 1288
		local buildQueue = {} -- 1289
		for ____, rel in ipairs(relFiles) do -- 1290
			do -- 1290
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1291
				local kind = getSupportedBuildKind(file) -- 1292
				if not kind then -- 1292
					goto __continue256 -- 1293
				end -- 1293
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1294
				if kind ~= "ts" then -- 1294
					goto __continue256 -- 1296
				end -- 1296
				local content = Content:load(file) -- 1298
				if content == nil then -- 1298
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1300
					goto __continue256 -- 1301
				end -- 1301
				tsFileData[file] = content -- 1303
				if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1303
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1305
					goto __continue256 -- 1306
				end -- 1306
			end -- 1306
			::__continue256:: -- 1306
		end -- 1306
		do -- 1306
			local i = 0 -- 1309
			while i < #buildQueue do -- 1309
				do -- 1309
					local ____buildQueue_index_19 = buildQueue[i + 1] -- 1310
					local file = ____buildQueue_index_19.file -- 1310
					local kind = ____buildQueue_index_19.kind -- 1310
					if kind == "ts" then -- 1310
						local content = tsFileData[file] -- 1312
						if content == nil or isDtsFile(file) then -- 1312
							goto __continue263 -- 1314
						end -- 1314
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1316
						goto __continue263 -- 1317
					end -- 1317
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1319
				end -- 1319
				::__continue263:: -- 1319
				i = i + 1 -- 1309
			end -- 1309
		end -- 1309
		Log( -- 1321
			"Info", -- 1321
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1321
		) -- 1321
		return ____awaiter_resolve( -- 1321
			nil, -- 1321
			{ -- 1322
				success = true, -- 1323
				messages = __TS__ArrayMap( -- 1324
					messages, -- 1324
					function(____, m) return m.success and __TS__ObjectAssign( -- 1324
						{}, -- 1325
						m, -- 1325
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1325
					) or __TS__ObjectAssign( -- 1325
						{}, -- 1326
						m, -- 1326
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1326
					) end -- 1326
				) -- 1326
			} -- 1326
		) -- 1326
	end) -- 1326
end -- 1243
return ____exports -- 1243