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
local json = ____Dora.json -- 2
local App = ____Dora.App -- 2
local HttpServer = ____Dora.HttpServer -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
function ensureSafeSearchGlobs(globs) -- 817
	local result = {} -- 818
	do -- 818
		local i = 0 -- 819
		while i < #globs do -- 819
			result[#result + 1] = globs[i + 1] -- 820
			i = i + 1 -- 819
		end -- 819
	end -- 819
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 822
	do -- 822
		local i = 0 -- 823
		while i < #requiredExcludes do -- 823
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 823
				result[#result + 1] = requiredExcludes[i + 1] -- 825
			end -- 825
			i = i + 1 -- 823
		end -- 823
	end -- 823
	return result -- 828
end -- 828
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
	local text = json.encode(obj) -- 556
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
				local res = json.decode(event.msg) -- 595
				if not res or __TS__ArrayIsArray(res) or res.name ~= "TranspileTS" then -- 595
					return -- 596
				end -- 596
				if res.success then -- 596
					local luaFile = Path:replaceExt(file, "lua") -- 598
					if Content:save( -- 598
						luaFile, -- 599
						tostring(res.luaCode) -- 599
					) then -- 599
						result = {success = true, file = file} -- 600
					else -- 600
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 602
					end -- 602
				else -- 602
					result = { -- 605
						success = false, -- 605
						file = file, -- 605
						message = tostring(res.message) -- 605
					} -- 605
				end -- 605
				done = true -- 607
			end -- 593
		) -- 593
		local payload = encodeJSON({name = "TranspileTS", file = file, content = content}) -- 609
		if not payload then -- 609
			listener:removeFromParent() -- 615
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 615
		end -- 615
		__TS__Await(__TS__New( -- 618
			__TS__Promise, -- 618
			function(____, resolve) -- 618
				Director.systemScheduler:schedule(once(function() -- 619
					emit("AppWS", "Send", payload) -- 620
					wait(function() return done end) -- 621
					if not done then -- 621
						listener:removeFromParent() -- 623
					end -- 623
					resolve(nil) -- 625
				end)) -- 619
			end -- 618
		)) -- 618
		return ____awaiter_resolve(nil, result) -- 618
	end) -- 618
end -- 582
function ____exports.createTask(prompt) -- 631
	if prompt == nil then -- 631
		prompt = "" -- 631
	end -- 631
	local t = now() -- 632
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 633
	if affected <= 0 then -- 633
		return {success = false, message = "failed to create task"} -- 638
	end -- 638
	return { -- 640
		success = true, -- 640
		taskId = getLastInsertRowId() -- 640
	} -- 640
end -- 631
function ____exports.setTaskStatus(taskId, status) -- 643
	DB:exec( -- 644
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 644
		{ -- 644
			status, -- 644
			now(), -- 644
			taskId -- 644
		} -- 644
	) -- 644
	Log( -- 645
		"Info", -- 645
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 645
	) -- 645
end -- 643
function ____exports.listCheckpoints(taskId) -- 648
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 649
	if not rows then -- 649
		return {} -- 656
	end -- 656
	local items = {} -- 657
	do -- 657
		local i = 0 -- 658
		while i < #rows do -- 658
			local row = rows[i + 1] -- 659
			items[#items + 1] = { -- 660
				id = row[1], -- 661
				taskId = row[2], -- 662
				seq = row[3], -- 663
				status = toStr(row[4]), -- 664
				summary = toStr(row[5]), -- 665
				toolName = toStr(row[6]), -- 666
				createdAt = row[7] -- 667
			} -- 667
			i = i + 1 -- 658
		end -- 658
	end -- 658
	return items -- 670
end -- 648
local function readWorkspaceFile(workDir, path, docLanguage) -- 673
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 674
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 674
		return { -- 676
			success = true, -- 676
			content = Content:load(fullPath) -- 676
		} -- 676
	end -- 676
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 678
	if docPath then -- 678
		return { -- 680
			success = true, -- 680
			content = Content:load(docPath) -- 680
		} -- 680
	end -- 680
	if not fullPath then -- 680
		return {success = false, message = "invalid path or workDir"} -- 682
	end -- 682
	return {success = false, message = "file not found"} -- 683
end -- 673
function ____exports.readFileRaw(workDir, path, docLanguage) -- 686
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 687
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 687
		return { -- 689
			success = true, -- 689
			content = Content:load(path) -- 689
		} -- 689
	end -- 689
	return result -- 691
end -- 686
local function getEngineLogText() -- 694
	local folder = Path(Content.writablePath, ENGINE_LOG_SNAPSHOT_DIR) -- 695
	if not Content:exist(folder) then -- 695
		Content:mkdir(folder) -- 697
	end -- 697
	local logPath = Path(folder, ENGINE_LOG_SNAPSHOT_FILE) -- 699
	if not App:saveLog(logPath) then -- 699
		return nil -- 701
	end -- 701
	return Content:load(logPath) -- 703
end -- 694
function ____exports.getLogs(req) -- 706
	local text = getEngineLogText() -- 707
	if text == nil then -- 707
		return {success = false, message = "failed to read engine logs"} -- 709
	end -- 709
	local tailLines = math.max( -- 711
		1, -- 711
		math.floor(req and req.tailLines or 200) -- 711
	) -- 711
	local allLines = __TS__StringSplit(text, "\n") -- 712
	local logs = __TS__ArraySlice( -- 713
		allLines, -- 713
		math.max(0, #allLines - tailLines) -- 713
	) -- 713
	return req and req.joinText and ({ -- 714
		success = true, -- 714
		logs = logs, -- 714
		text = table.concat(logs, "\n") -- 714
	}) or ({success = true, logs = logs}) -- 714
end -- 706
function ____exports.listFiles(req) -- 717
	local root = req.path or "" -- 723
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 724
	if not searchRoot then -- 724
		return {success = false, message = "invalid path or workDir"} -- 726
	end -- 726
	do -- 726
		local function ____catch(e) -- 726
			return true, { -- 744
				success = false, -- 744
				message = tostring(e) -- 744
			} -- 744
		end -- 744
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 744
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 729
			local globs = ensureSafeSearchGlobs(userGlobs) -- 730
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 731
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 732
			local totalEntries = #files -- 733
			local maxEntries = math.max( -- 734
				1, -- 734
				math.floor(req.maxEntries or 200) -- 734
			) -- 734
			local truncated = totalEntries > maxEntries -- 735
			return true, { -- 736
				success = true, -- 737
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 738
				totalEntries = totalEntries, -- 739
				truncated = truncated, -- 740
				maxEntries = maxEntries -- 741
			} -- 741
		end) -- 741
		if not ____try then -- 741
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 741
		end -- 741
		if ____hasReturned then -- 741
			return ____returnValue -- 728
		end -- 728
	end -- 728
end -- 717
local function formatReadSlice(content, startLine, limit) -- 748
	local lines = __TS__StringSplit(content, "\n") -- 753
	local totalLines = #lines -- 754
	if totalLines == 0 then -- 754
		return { -- 756
			success = true, -- 757
			content = "", -- 758
			totalLines = 0, -- 759
			startLine = 1, -- 760
			endLine = 0, -- 761
			truncated = false -- 762
		} -- 762
	end -- 762
	local start = math.max( -- 765
		1, -- 765
		math.floor(startLine) -- 765
	) -- 765
	if start > totalLines then -- 765
		return { -- 767
			success = false, -- 767
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 767
		} -- 767
	end -- 767
	local boundedLimit = math.max( -- 769
		1, -- 769
		math.floor(limit) -- 769
	) -- 769
	local ____end = math.min(totalLines, start + boundedLimit - 1) -- 770
	local slice = {} -- 771
	do -- 771
		local i = start -- 772
		while i <= ____end do -- 772
			slice[#slice + 1] = lines[i] -- 773
			i = i + 1 -- 772
		end -- 772
	end -- 772
	local truncated = ____end < totalLines -- 775
	local hint = truncated and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use offset=") .. tostring(____end + 1)) .. " to continue.)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)" -- 776
	local body = table.concat(slice, "\n") -- 779
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 780
	return { -- 781
		success = true, -- 782
		content = output, -- 783
		totalLines = totalLines, -- 784
		startLine = start, -- 785
		endLine = ____end, -- 786
		truncated = truncated -- 787
	} -- 787
end -- 748
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 791
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 798
	if not fallback.success or fallback.content == nil then -- 798
		return fallback -- 799
	end -- 799
	local s = math.max( -- 800
		1, -- 800
		math.floor(startLine or 1) -- 800
	) -- 800
	local e = math.max( -- 801
		s, -- 801
		math.floor(endLine or 300) -- 801
	) -- 801
	return formatReadSlice(fallback.content, s, e - s + 1) -- 802
end -- 791
local codeExtensions = { -- 805
	".lua", -- 805
	".tl", -- 805
	".yue", -- 805
	".ts", -- 805
	".tsx", -- 805
	".xml", -- 805
	".md", -- 805
	".yarn", -- 805
	".wa", -- 805
	".mod" -- 805
} -- 805
extensionLevels = { -- 806
	vs = 2, -- 807
	bl = 2, -- 808
	ts = 1, -- 809
	tsx = 1, -- 810
	tl = 1, -- 811
	yue = 1, -- 812
	xml = 1, -- 813
	lua = 0 -- 814
} -- 814
local function splitSearchPatterns(pattern) -- 831
	local trimmed = __TS__StringTrim(pattern or "") -- 832
	if trimmed == "" then -- 832
		return {} -- 833
	end -- 833
	local out = {} -- 834
	local seen = __TS__New(Set) -- 835
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 836
		local p = __TS__StringTrim(tostring(p0)) -- 837
		if p ~= "" and not seen:has(p) then -- 837
			seen:add(p) -- 839
			out[#out + 1] = p -- 840
		end -- 840
	end -- 840
	return out -- 843
end -- 831
local function mergeSearchFileResultsUnique(resultsList) -- 846
	local merged = {} -- 847
	local seen = __TS__New(Set) -- 848
	do -- 848
		local i = 0 -- 849
		while i < #resultsList do -- 849
			local list = resultsList[i + 1] -- 850
			do -- 850
				local j = 0 -- 851
				while j < #list do -- 851
					do -- 851
						local row = list[j + 1] -- 852
						local ____temp_18 -- 853
						if type(row) == "table" then -- 853
							local ____tostring_8 = tostring -- 854
							local ____row_file_6 = row.file -- 854
							if ____row_file_6 == nil then -- 854
								____row_file_6 = row.path -- 854
							end -- 854
							local ____row_file_6_7 = ____row_file_6 -- 854
							if ____row_file_6_7 == nil then -- 854
								____row_file_6_7 = "" -- 854
							end -- 854
							local ____tostring_8_result_15 = ____tostring_8(____row_file_6_7) -- 854
							local ____tostring_10 = tostring -- 854
							local ____row_pos_9 = row.pos -- 854
							if ____row_pos_9 == nil then -- 854
								____row_pos_9 = "" -- 854
							end -- 854
							local ____tostring_10_result_16 = ____tostring_10(____row_pos_9) -- 854
							local ____tostring_12 = tostring -- 854
							local ____row_line_11 = row.line -- 854
							if ____row_line_11 == nil then -- 854
								____row_line_11 = "" -- 854
							end -- 854
							local ____tostring_12_result_17 = ____tostring_12(____row_line_11) -- 854
							local ____tostring_14 = tostring -- 854
							local ____row_column_13 = row.column -- 854
							if ____row_column_13 == nil then -- 854
								____row_column_13 = "" -- 854
							end -- 854
							____temp_18 = (((((____tostring_8_result_15 .. ":") .. ____tostring_10_result_16) .. ":") .. ____tostring_12_result_17) .. ":") .. ____tostring_14(____row_column_13) -- 854
						else -- 854
							____temp_18 = tostring(j) -- 855
						end -- 855
						local key = ____temp_18 -- 853
						if seen:has(key) then -- 853
							goto __continue167 -- 856
						end -- 856
						seen:add(key) -- 857
						merged[#merged + 1] = list[j + 1] -- 858
					end -- 858
					::__continue167:: -- 858
					j = j + 1 -- 851
				end -- 851
			end -- 851
			i = i + 1 -- 849
		end -- 849
	end -- 849
	return merged -- 861
end -- 846
local function buildGroupedSearchResults(results) -- 864
	local order = {} -- 869
	local grouped = __TS__New(Map) -- 870
	do -- 870
		local i = 0 -- 875
		while i < #results do -- 875
			local row = results[i + 1] -- 876
			local ____temp_22 -- 877
			if type(row) == "table" then -- 877
				local ____tostring_21 = tostring -- 878
				local ____row_file_19 = row.file -- 878
				if ____row_file_19 == nil then -- 878
					____row_file_19 = row.path -- 878
				end -- 878
				local ____row_file_19_20 = ____row_file_19 -- 878
				if ____row_file_19_20 == nil then -- 878
					____row_file_19_20 = "" -- 878
				end -- 878
				____temp_22 = ____tostring_21(____row_file_19_20) -- 878
			else -- 878
				____temp_22 = "" -- 879
			end -- 879
			local file = ____temp_22 -- 877
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 880
			local bucket = grouped:get(key) -- 881
			if not bucket then -- 881
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 883
				grouped:set(key, bucket) -- 884
				order[#order + 1] = key -- 885
			end -- 885
			bucket.totalMatches = bucket.totalMatches + 1 -- 887
			local ____bucket_matches_23 = bucket.matches -- 887
			____bucket_matches_23[#____bucket_matches_23 + 1] = results[i + 1] -- 888
			i = i + 1 -- 875
		end -- 875
	end -- 875
	local out = {} -- 890
	do -- 890
		local i = 0 -- 895
		while i < #order do -- 895
			local bucket = grouped:get(order[i + 1]) -- 896
			if bucket then -- 896
				out[#out + 1] = bucket -- 897
			end -- 897
			i = i + 1 -- 895
		end -- 895
	end -- 895
	return out -- 899
end -- 864
local function mergeDoraAPISearchHitsUnique(resultsList) -- 902
	local merged = {} -- 903
	local seen = __TS__New(Set) -- 904
	local index = 0 -- 905
	local advanced = true -- 906
	while advanced do -- 906
		advanced = false -- 908
		do -- 908
			local i = 0 -- 909
			while i < #resultsList do -- 909
				do -- 909
					local list = resultsList[i + 1] -- 910
					if index >= #list then -- 910
						goto __continue179 -- 911
					end -- 911
					advanced = true -- 912
					local row = list[index + 1] -- 913
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 914
					if seen:has(key) then -- 914
						goto __continue179 -- 915
					end -- 915
					seen:add(key) -- 916
					merged[#merged + 1] = row -- 917
				end -- 917
				::__continue179:: -- 917
				i = i + 1 -- 909
			end -- 909
		end -- 909
		index = index + 1 -- 919
	end -- 919
	return merged -- 921
end -- 902
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 924
	if docSource ~= "api" then -- 924
		return 100 -- 925
	end -- 925
	if programmingLanguage ~= "tsx" then -- 925
		return 100 -- 926
	end -- 926
	repeat -- 926
		local ____switch185 = string.lower(Path:getFilename(file)) -- 926
		local ____cond185 = ____switch185 == "jsx.d.ts" -- 926
		if ____cond185 then -- 926
			return 0 -- 928
		end -- 928
		____cond185 = ____cond185 or ____switch185 == "dorax.d.ts" -- 928
		if ____cond185 then -- 928
			return 1 -- 929
		end -- 929
		____cond185 = ____cond185 or ____switch185 == "dora.d.ts" -- 929
		if ____cond185 then -- 929
			return 2 -- 930
		end -- 930
		do -- 930
			return 100 -- 931
		end -- 931
	until true -- 931
end -- 924
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 935
	local sorted = __TS__ArraySlice(hits) -- 940
	__TS__ArraySort( -- 941
		sorted, -- 941
		function(____, a, b) -- 941
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 942
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 943
			if pa ~= pb then -- 943
				return pa - pb -- 944
			end -- 944
			local fa = string.lower(a.file) -- 945
			local fb = string.lower(b.file) -- 946
			if fa ~= fb then -- 946
				return fa < fb and -1 or 1 -- 947
			end -- 947
			return (a.line or 0) - (b.line or 0) -- 948
		end -- 941
	) -- 941
	return sorted -- 950
end -- 935
function ____exports.searchFiles(req) -- 953
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 953
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 966
		if not resolvedPath then -- 966
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 966
		end -- 966
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 970
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 971
		if not searchRoot then -- 971
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 971
		end -- 971
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 971
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 971
		end -- 971
		local patterns = splitSearchPatterns(req.pattern) -- 978
		if #patterns == 0 then -- 978
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 978
		end -- 978
		return ____awaiter_resolve( -- 978
			nil, -- 978
			__TS__New( -- 982
				__TS__Promise, -- 982
				function(____, resolve) -- 982
					Director.systemScheduler:schedule(once(function() -- 983
						do -- 983
							local function ____catch(e) -- 983
								resolve( -- 1025
									nil, -- 1025
									{ -- 1025
										success = false, -- 1025
										message = tostring(e) -- 1025
									} -- 1025
								) -- 1025
							end -- 1025
							local ____try, ____hasReturned = pcall(function() -- 1025
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 985
								local allResults = {} -- 988
								do -- 988
									local i = 0 -- 989
									while i < #patterns do -- 989
										local ____Content_28 = Content -- 990
										local ____Content_searchFilesAsync_29 = Content.searchFilesAsync -- 990
										local ____patterns_index_27 = patterns[i + 1] -- 995
										local ____req_useRegex_24 = req.useRegex -- 996
										if ____req_useRegex_24 == nil then -- 996
											____req_useRegex_24 = false -- 996
										end -- 996
										local ____req_caseSensitive_25 = req.caseSensitive -- 997
										if ____req_caseSensitive_25 == nil then -- 997
											____req_caseSensitive_25 = false -- 997
										end -- 997
										local ____req_includeContent_26 = req.includeContent -- 998
										if ____req_includeContent_26 == nil then -- 998
											____req_includeContent_26 = true -- 998
										end -- 998
										allResults[#allResults + 1] = ____Content_searchFilesAsync_29( -- 990
											____Content_28, -- 990
											searchRoot, -- 991
											codeExtensions, -- 992
											extensionLevels, -- 993
											searchGlobs, -- 994
											____patterns_index_27, -- 995
											____req_useRegex_24, -- 996
											____req_caseSensitive_25, -- 997
											____req_includeContent_26, -- 998
											req.contentWindow or 120 -- 999
										) -- 999
										i = i + 1 -- 989
									end -- 989
								end -- 989
								local results = mergeSearchFileResultsUnique(allResults) -- 1002
								local totalResults = #results -- 1003
								local limit = math.max( -- 1004
									1, -- 1004
									math.floor(req.limit or 20) -- 1004
								) -- 1004
								local offset = math.max( -- 1005
									0, -- 1005
									math.floor(req.offset or 0) -- 1005
								) -- 1005
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1006
								local nextOffset = offset + #paged -- 1007
								local hasMore = nextOffset < totalResults -- 1008
								local truncated = offset > 0 or hasMore -- 1009
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1010
								local groupByFile = req.groupByFile == true -- 1011
								resolve( -- 1012
									nil, -- 1012
									{ -- 1012
										success = true, -- 1013
										results = relativeResults, -- 1014
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1015
										totalResults = totalResults, -- 1016
										truncated = truncated, -- 1017
										limit = limit, -- 1018
										offset = offset, -- 1019
										nextOffset = nextOffset, -- 1020
										hasMore = hasMore, -- 1021
										groupByFile = groupByFile -- 1022
									} -- 1022
								) -- 1022
							end) -- 1022
							if not ____try then -- 1022
								____catch(____hasReturned) -- 1022
							end -- 1022
						end -- 1022
					end)) -- 983
				end -- 982
			) -- 982
		) -- 982
	end) -- 982
end -- 953
function ____exports.searchDoraAPI(req) -- 1031
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1031
		local pattern = __TS__StringTrim(req.pattern or "") -- 1042
		if pattern == "" then -- 1042
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1042
		end -- 1042
		local patterns = splitSearchPatterns(pattern) -- 1044
		if #patterns == 0 then -- 1044
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1044
		end -- 1044
		local docSource = req.docSource or "api" -- 1046
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1047
		local docRoot = target.root -- 1048
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1049
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1049
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1049
		end -- 1049
		local exts = target.exts -- 1053
		local dotExts = __TS__ArrayMap( -- 1054
			exts, -- 1054
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1054
		) -- 1054
		local globs = target.globs -- 1055
		local limit = math.max( -- 1056
			1, -- 1056
			math.floor(req.limit or 10) -- 1056
		) -- 1056
		return ____awaiter_resolve( -- 1056
			nil, -- 1056
			__TS__New( -- 1058
				__TS__Promise, -- 1058
				function(____, resolve) -- 1058
					Director.systemScheduler:schedule(once(function() -- 1059
						do -- 1059
							local function ____catch(e) -- 1059
								resolve( -- 1104
									nil, -- 1104
									{ -- 1104
										success = false, -- 1104
										message = tostring(e) -- 1104
									} -- 1104
								) -- 1104
							end -- 1104
							local ____try, ____hasReturned = pcall(function() -- 1104
								local allHits = {} -- 1061
								do -- 1061
									local p = 0 -- 1062
									while p < #patterns do -- 1062
										local ____Content_34 = Content -- 1063
										local ____Content_searchFilesAsync_35 = Content.searchFilesAsync -- 1063
										local ____array_33 = __TS__SparseArrayNew( -- 1063
											docRoot, -- 1064
											dotExts, -- 1065
											{}, -- 1066
											ensureSafeSearchGlobs(globs), -- 1067
											patterns[p + 1] -- 1068
										) -- 1068
										local ____req_useRegex_30 = req.useRegex -- 1069
										if ____req_useRegex_30 == nil then -- 1069
											____req_useRegex_30 = false -- 1069
										end -- 1069
										__TS__SparseArrayPush(____array_33, ____req_useRegex_30) -- 1069
										local ____req_caseSensitive_31 = req.caseSensitive -- 1070
										if ____req_caseSensitive_31 == nil then -- 1070
											____req_caseSensitive_31 = false -- 1070
										end -- 1070
										__TS__SparseArrayPush(____array_33, ____req_caseSensitive_31) -- 1070
										local ____req_includeContent_32 = req.includeContent -- 1071
										if ____req_includeContent_32 == nil then -- 1071
											____req_includeContent_32 = true -- 1071
										end -- 1071
										__TS__SparseArrayPush(____array_33, ____req_includeContent_32, req.contentWindow or 80) -- 1071
										local raw = ____Content_searchFilesAsync_35( -- 1063
											____Content_34, -- 1063
											__TS__SparseArraySpread(____array_33) -- 1063
										) -- 1063
										local hits = {} -- 1074
										do -- 1074
											local i = 0 -- 1075
											while i < #raw do -- 1075
												do -- 1075
													local row = raw[i + 1] -- 1076
													if type(row) ~= "table" then -- 1076
														goto __continue212 -- 1077
													end -- 1077
													local file = type(row.file) == "string" and toDocRelativePath(resultBaseRoot, row.file) or (type(row.path) == "string" and toDocRelativePath(resultBaseRoot, row.path) or "") -- 1078
													if file == "" then -- 1078
														goto __continue212 -- 1081
													end -- 1081
													hits[#hits + 1] = { -- 1082
														file = file, -- 1083
														line = type(row.line) == "number" and row.line or nil, -- 1084
														content = type(row.content) == "string" and row.content or nil -- 1085
													} -- 1085
												end -- 1085
												::__continue212:: -- 1085
												i = i + 1 -- 1075
											end -- 1075
										end -- 1075
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1088
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1088
											0, -- 1088
											limit -- 1088
										) -- 1088
										p = p + 1 -- 1062
									end -- 1062
								end -- 1062
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1090
								resolve(nil, { -- 1091
									success = true, -- 1092
									docSource = docSource, -- 1093
									docLanguage = req.docLanguage, -- 1094
									programmingLanguage = req.programmingLanguage, -- 1095
									root = docRoot, -- 1096
									exts = exts, -- 1097
									results = hits, -- 1098
									totalResults = #hits, -- 1099
									truncated = false, -- 1100
									limit = limit -- 1101
								}) -- 1101
							end) -- 1101
							if not ____try then -- 1101
								____catch(____hasReturned) -- 1101
							end -- 1101
						end -- 1101
					end)) -- 1059
				end -- 1058
			) -- 1058
		) -- 1058
	end) -- 1058
end -- 1031
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1110
	if options == nil then -- 1110
		options = {} -- 1110
	end -- 1110
	if #changes == 0 then -- 1110
		return {success = false, message = "empty changes"} -- 1112
	end -- 1112
	if not isValidWorkDir(workDir) then -- 1112
		return {success = false, message = "invalid workDir"} -- 1115
	end -- 1115
	if not getTaskStatus(taskId) then -- 1115
		return {success = false, message = "task not found"} -- 1118
	end -- 1118
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1120
	local dup = rejectDuplicatePaths(expandedChanges) -- 1121
	if dup then -- 1121
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1123
	end -- 1123
	for ____, change in ipairs(expandedChanges) do -- 1126
		if not isValidWorkspacePath(change.path) then -- 1126
			return {success = false, message = "invalid path: " .. change.path} -- 1128
		end -- 1128
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1128
			return {success = false, message = "missing content for " .. change.path} -- 1131
		end -- 1131
	end -- 1131
	local headSeq = getTaskHeadSeq(taskId) -- 1135
	if headSeq == nil then -- 1135
		return {success = false, message = "task not found"} -- 1136
	end -- 1136
	local nextSeq = headSeq + 1 -- 1137
	local checkpointId = insertCheckpoint( -- 1138
		taskId, -- 1138
		nextSeq, -- 1138
		options.summary or "", -- 1138
		options.toolName or "", -- 1138
		"PREPARED" -- 1138
	) -- 1138
	if checkpointId <= 0 then -- 1138
		return {success = false, message = "failed to create checkpoint"} -- 1140
	end -- 1140
	do -- 1140
		local i = 0 -- 1143
		while i < #expandedChanges do -- 1143
			local change = expandedChanges[i + 1] -- 1144
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1145
			if not fullPath then -- 1145
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1147
				return {success = false, message = "invalid path: " .. change.path} -- 1148
			end -- 1148
			local before = getFileState(fullPath) -- 1150
			local afterExists = change.op ~= "delete" -- 1151
			local afterContent = afterExists and (change.content or "") or "" -- 1152
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1153
				checkpointId, -- 1157
				i + 1, -- 1158
				change.path, -- 1159
				change.op, -- 1160
				before.exists and 1 or 0, -- 1161
				before.content, -- 1162
				afterExists and 1 or 0, -- 1163
				afterContent, -- 1164
				before.bytes, -- 1165
				#afterContent -- 1166
			}) -- 1166
			if inserted <= 0 then -- 1166
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1170
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1171
			end -- 1171
			i = i + 1 -- 1143
		end -- 1143
	end -- 1143
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1175
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1176
		if not fullPath then -- 1176
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1178
			return {success = false, message = "invalid path: " .. entry.path} -- 1179
		end -- 1179
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1181
		if not ok then -- 1181
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1183
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1184
		end -- 1184
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1184
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1187
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1188
		end -- 1188
	end -- 1188
	DB:exec( -- 1192
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1192
		{ -- 1194
			"APPLIED", -- 1194
			now(), -- 1194
			checkpointId -- 1194
		} -- 1194
	) -- 1194
	DB:exec( -- 1196
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1196
		{ -- 1198
			nextSeq, -- 1198
			now(), -- 1198
			taskId -- 1198
		} -- 1198
	) -- 1198
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1200
end -- 1110
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1208
	if not isValidWorkDir(workDir) then -- 1208
		return {success = false, message = "invalid workDir"} -- 1209
	end -- 1209
	if checkpointId <= 0 then -- 1209
		return {success = false, message = "invalid checkpointId"} -- 1210
	end -- 1210
	local entries = getCheckpointEntries(checkpointId, true) -- 1211
	if #entries == 0 then -- 1211
		return {success = false, message = "checkpoint not found or empty"} -- 1213
	end -- 1213
	for ____, entry in ipairs(entries) do -- 1215
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1216
		if not fullPath then -- 1216
			return {success = false, message = "invalid path: " .. entry.path} -- 1218
		end -- 1218
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1220
		if not ok then -- 1220
			Log( -- 1222
				"Error", -- 1222
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1222
			) -- 1222
			Log( -- 1223
				"Info", -- 1223
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1223
			) -- 1223
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1224
		end -- 1224
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1224
			Log( -- 1227
				"Error", -- 1227
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1227
			) -- 1227
			Log( -- 1228
				"Info", -- 1228
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1228
			) -- 1228
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1229
		end -- 1229
	end -- 1229
	return {success = true, checkpointId = checkpointId} -- 1232
end -- 1208
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1235
	return getCheckpointEntries(checkpointId, false) -- 1236
end -- 1235
function ____exports.getCheckpointDiff(checkpointId) -- 1239
	if checkpointId <= 0 then -- 1239
		return {success = false, message = "invalid checkpointId"} -- 1241
	end -- 1241
	local entries = getCheckpointEntries(checkpointId, false) -- 1243
	if #entries == 0 then -- 1243
		return {success = false, message = "checkpoint not found or empty"} -- 1245
	end -- 1245
	return { -- 1247
		success = true, -- 1248
		files = __TS__ArrayMap( -- 1249
			entries, -- 1249
			function(____, entry) return { -- 1249
				path = entry.path, -- 1250
				op = entry.op, -- 1251
				beforeExists = entry.beforeExists, -- 1252
				afterExists = entry.afterExists, -- 1253
				beforeContent = entry.beforeContent, -- 1254
				afterContent = entry.afterContent -- 1255
			} end -- 1255
		) -- 1255
	} -- 1255
end -- 1239
function ____exports.build(req) -- 1260
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1260
		local targetRel = req.path or "" -- 1261
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1262
		if not target then -- 1262
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1262
		end -- 1262
		if not Content:exist(target) then -- 1262
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1262
		end -- 1262
		local messages = {} -- 1269
		if not Content:isdir(target) then -- 1269
			local kind = getSupportedBuildKind(target) -- 1271
			if not kind then -- 1271
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1271
			end -- 1271
			if kind == "ts" then -- 1271
				local content = Content:load(target) -- 1276
				if content == nil then -- 1276
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1276
				end -- 1276
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1276
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1276
				end -- 1276
				if not isDtsFile(target) then -- 1276
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1284
				end -- 1284
			else -- 1284
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1287
			end -- 1287
			Log( -- 1289
				"Info", -- 1289
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1289
			) -- 1289
			return ____awaiter_resolve( -- 1289
				nil, -- 1289
				{ -- 1290
					success = true, -- 1291
					messages = __TS__ArrayMap( -- 1292
						messages, -- 1292
						function(____, m) return m.success and __TS__ObjectAssign( -- 1292
							{}, -- 1293
							m, -- 1293
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1293
						) or __TS__ObjectAssign( -- 1293
							{}, -- 1294
							m, -- 1294
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1294
						) end -- 1294
					) -- 1294
				} -- 1294
			) -- 1294
		end -- 1294
		local listResult = ____exports.listFiles({ -- 1297
			workDir = req.workDir, -- 1298
			path = target, -- 1299
			globs = __TS__ArrayMap( -- 1300
				codeExtensions, -- 1300
				function(____, e) return "**/*" .. e end -- 1300
			), -- 1300
			maxEntries = 10000 -- 1301
		}) -- 1301
		local relFiles = listResult.success and listResult.files or ({}) -- 1304
		local tsFileData = {} -- 1305
		local buildQueue = {} -- 1306
		for ____, rel in ipairs(relFiles) do -- 1307
			do -- 1307
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1308
				local kind = getSupportedBuildKind(file) -- 1309
				if not kind then -- 1309
					goto __continue262 -- 1310
				end -- 1310
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1311
				if kind ~= "ts" then -- 1311
					goto __continue262 -- 1313
				end -- 1313
				local content = Content:load(file) -- 1315
				if content == nil then -- 1315
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1317
					goto __continue262 -- 1318
				end -- 1318
				tsFileData[file] = content -- 1320
				if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1320
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1322
					goto __continue262 -- 1323
				end -- 1323
			end -- 1323
			::__continue262:: -- 1323
		end -- 1323
		do -- 1323
			local i = 0 -- 1326
			while i < #buildQueue do -- 1326
				do -- 1326
					local ____buildQueue_index_36 = buildQueue[i + 1] -- 1327
					local file = ____buildQueue_index_36.file -- 1327
					local kind = ____buildQueue_index_36.kind -- 1327
					if kind == "ts" then -- 1327
						local content = tsFileData[file] -- 1329
						if content == nil or isDtsFile(file) then -- 1329
							goto __continue269 -- 1331
						end -- 1331
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1333
						goto __continue269 -- 1334
					end -- 1334
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1336
				end -- 1336
				::__continue269:: -- 1336
				i = i + 1 -- 1326
			end -- 1326
		end -- 1326
		Log( -- 1338
			"Info", -- 1338
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1338
		) -- 1338
		return ____awaiter_resolve( -- 1338
			nil, -- 1338
			{ -- 1339
				success = true, -- 1340
				messages = __TS__ArrayMap( -- 1341
					messages, -- 1341
					function(____, m) return m.success and __TS__ObjectAssign( -- 1341
						{}, -- 1342
						m, -- 1342
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1342
					) or __TS__ObjectAssign( -- 1342
						{}, -- 1343
						m, -- 1343
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1343
					) end -- 1343
				) -- 1343
			} -- 1343
		) -- 1343
	end) -- 1343
end -- 1260
return ____exports -- 1260