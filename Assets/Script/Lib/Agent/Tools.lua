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
function ensureSafeSearchGlobs(globs) -- 827
	local result = {} -- 828
	do -- 828
		local i = 0 -- 829
		while i < #globs do -- 829
			result[#result + 1] = globs[i + 1] -- 830
			i = i + 1 -- 829
		end -- 829
	end -- 829
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 832
	do -- 832
		local i = 0 -- 833
		while i < #requiredExcludes do -- 833
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 833
				result[#result + 1] = requiredExcludes[i + 1] -- 835
			end -- 835
			i = i + 1 -- 833
		end -- 833
	end -- 833
	return result -- 838
end -- 838
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
function ____exports.readFile(workDir, path, offset, limit, docLanguage) -- 791
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 798
	if not fallback.success then -- 798
		return fallback -- 800
	end -- 800
	local start = math.max( -- 802
		1, -- 802
		math.floor(offset or 1) -- 802
	) -- 802
	local maxLines = math.max( -- 803
		1, -- 803
		math.floor(limit or 300) -- 803
	) -- 803
	return formatReadSlice(fallback.content, start, maxLines) -- 804
end -- 791
function ____exports.readFileRange(workDir, path, startLine, endLine, docLanguage) -- 807
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 808
	if not fallback.success or fallback.content == nil then -- 808
		return fallback -- 809
	end -- 809
	local s = math.max( -- 810
		1, -- 810
		math.floor(startLine) -- 810
	) -- 810
	local e = math.max( -- 811
		s, -- 811
		math.floor(endLine) -- 811
	) -- 811
	return formatReadSlice(fallback.content, s, e - s + 1) -- 812
end -- 807
local codeExtensions = { -- 815
	".lua", -- 815
	".tl", -- 815
	".yue", -- 815
	".ts", -- 815
	".tsx", -- 815
	".xml", -- 815
	".md", -- 815
	".yarn", -- 815
	".wa", -- 815
	".mod" -- 815
} -- 815
extensionLevels = { -- 816
	vs = 2, -- 817
	bl = 2, -- 818
	ts = 1, -- 819
	tsx = 1, -- 820
	tl = 1, -- 821
	yue = 1, -- 822
	xml = 1, -- 823
	lua = 0 -- 824
} -- 824
local function splitSearchPatterns(pattern) -- 841
	local trimmed = __TS__StringTrim(pattern or "") -- 842
	if trimmed == "" then -- 842
		return {} -- 843
	end -- 843
	local out = {} -- 844
	local seen = __TS__New(Set) -- 845
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 846
		local p = __TS__StringTrim(tostring(p0)) -- 847
		if p ~= "" and not seen:has(p) then -- 847
			seen:add(p) -- 849
			out[#out + 1] = p -- 850
		end -- 850
	end -- 850
	return out -- 853
end -- 841
local function mergeSearchFileResultsUnique(resultsList) -- 856
	local merged = {} -- 857
	local seen = __TS__New(Set) -- 858
	do -- 858
		local i = 0 -- 859
		while i < #resultsList do -- 859
			local list = resultsList[i + 1] -- 860
			do -- 860
				local j = 0 -- 861
				while j < #list do -- 861
					do -- 861
						local row = list[j + 1] -- 862
						local ____temp_18 -- 863
						if type(row) == "table" then -- 863
							local ____tostring_8 = tostring -- 864
							local ____row_file_6 = row.file -- 864
							if ____row_file_6 == nil then -- 864
								____row_file_6 = row.path -- 864
							end -- 864
							local ____row_file_6_7 = ____row_file_6 -- 864
							if ____row_file_6_7 == nil then -- 864
								____row_file_6_7 = "" -- 864
							end -- 864
							local ____tostring_8_result_15 = ____tostring_8(____row_file_6_7) -- 864
							local ____tostring_10 = tostring -- 864
							local ____row_pos_9 = row.pos -- 864
							if ____row_pos_9 == nil then -- 864
								____row_pos_9 = "" -- 864
							end -- 864
							local ____tostring_10_result_16 = ____tostring_10(____row_pos_9) -- 864
							local ____tostring_12 = tostring -- 864
							local ____row_line_11 = row.line -- 864
							if ____row_line_11 == nil then -- 864
								____row_line_11 = "" -- 864
							end -- 864
							local ____tostring_12_result_17 = ____tostring_12(____row_line_11) -- 864
							local ____tostring_14 = tostring -- 864
							local ____row_column_13 = row.column -- 864
							if ____row_column_13 == nil then -- 864
								____row_column_13 = "" -- 864
							end -- 864
							____temp_18 = (((((____tostring_8_result_15 .. ":") .. ____tostring_10_result_16) .. ":") .. ____tostring_12_result_17) .. ":") .. ____tostring_14(____row_column_13) -- 864
						else -- 864
							____temp_18 = tostring(j) -- 865
						end -- 865
						local key = ____temp_18 -- 863
						if seen:has(key) then -- 863
							goto __continue169 -- 866
						end -- 866
						seen:add(key) -- 867
						merged[#merged + 1] = list[j + 1] -- 868
					end -- 868
					::__continue169:: -- 868
					j = j + 1 -- 861
				end -- 861
			end -- 861
			i = i + 1 -- 859
		end -- 859
	end -- 859
	return merged -- 871
end -- 856
local function buildGroupedSearchResults(results) -- 874
	local order = {} -- 879
	local grouped = __TS__New(Map) -- 880
	do -- 880
		local i = 0 -- 885
		while i < #results do -- 885
			local row = results[i + 1] -- 886
			local ____temp_22 -- 887
			if type(row) == "table" then -- 887
				local ____tostring_21 = tostring -- 888
				local ____row_file_19 = row.file -- 888
				if ____row_file_19 == nil then -- 888
					____row_file_19 = row.path -- 888
				end -- 888
				local ____row_file_19_20 = ____row_file_19 -- 888
				if ____row_file_19_20 == nil then -- 888
					____row_file_19_20 = "" -- 888
				end -- 888
				____temp_22 = ____tostring_21(____row_file_19_20) -- 888
			else -- 888
				____temp_22 = "" -- 889
			end -- 889
			local file = ____temp_22 -- 887
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 890
			local bucket = grouped:get(key) -- 891
			if not bucket then -- 891
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 893
				grouped:set(key, bucket) -- 894
				order[#order + 1] = key -- 895
			end -- 895
			bucket.totalMatches = bucket.totalMatches + 1 -- 897
			local ____bucket_matches_23 = bucket.matches -- 897
			____bucket_matches_23[#____bucket_matches_23 + 1] = results[i + 1] -- 898
			i = i + 1 -- 885
		end -- 885
	end -- 885
	local out = {} -- 900
	do -- 900
		local i = 0 -- 905
		while i < #order do -- 905
			local bucket = grouped:get(order[i + 1]) -- 906
			if bucket then -- 906
				out[#out + 1] = bucket -- 907
			end -- 907
			i = i + 1 -- 905
		end -- 905
	end -- 905
	return out -- 909
end -- 874
local function mergeDoraAPISearchHitsUnique(resultsList) -- 912
	local merged = {} -- 913
	local seen = __TS__New(Set) -- 914
	local index = 0 -- 915
	local advanced = true -- 916
	while advanced do -- 916
		advanced = false -- 918
		do -- 918
			local i = 0 -- 919
			while i < #resultsList do -- 919
				do -- 919
					local list = resultsList[i + 1] -- 920
					if index >= #list then -- 920
						goto __continue181 -- 921
					end -- 921
					advanced = true -- 922
					local row = list[index + 1] -- 923
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 924
					if seen:has(key) then -- 924
						goto __continue181 -- 925
					end -- 925
					seen:add(key) -- 926
					merged[#merged + 1] = row -- 927
				end -- 927
				::__continue181:: -- 927
				i = i + 1 -- 919
			end -- 919
		end -- 919
		index = index + 1 -- 929
	end -- 929
	return merged -- 931
end -- 912
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 934
	if docSource ~= "api" then -- 934
		return 100 -- 935
	end -- 935
	if programmingLanguage ~= "tsx" then -- 935
		return 100 -- 936
	end -- 936
	repeat -- 936
		local ____switch187 = string.lower(Path:getFilename(file)) -- 936
		local ____cond187 = ____switch187 == "jsx.d.ts" -- 936
		if ____cond187 then -- 936
			return 0 -- 938
		end -- 938
		____cond187 = ____cond187 or ____switch187 == "dorax.d.ts" -- 938
		if ____cond187 then -- 938
			return 1 -- 939
		end -- 939
		____cond187 = ____cond187 or ____switch187 == "dora.d.ts" -- 939
		if ____cond187 then -- 939
			return 2 -- 940
		end -- 940
		do -- 940
			return 100 -- 941
		end -- 941
	until true -- 941
end -- 934
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 945
	local sorted = __TS__ArraySlice(hits) -- 950
	__TS__ArraySort( -- 951
		sorted, -- 951
		function(____, a, b) -- 951
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 952
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 953
			if pa ~= pb then -- 953
				return pa - pb -- 954
			end -- 954
			local fa = string.lower(a.file) -- 955
			local fb = string.lower(b.file) -- 956
			if fa ~= fb then -- 956
				return fa < fb and -1 or 1 -- 957
			end -- 957
			return (a.line or 0) - (b.line or 0) -- 958
		end -- 951
	) -- 951
	return sorted -- 960
end -- 945
function ____exports.searchFiles(req) -- 963
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 963
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 976
		if not resolvedPath then -- 976
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 976
		end -- 976
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 980
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 981
		if not searchRoot then -- 981
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 981
		end -- 981
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 981
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 981
		end -- 981
		local patterns = splitSearchPatterns(req.pattern) -- 988
		if #patterns == 0 then -- 988
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 988
		end -- 988
		return ____awaiter_resolve( -- 988
			nil, -- 988
			__TS__New( -- 992
				__TS__Promise, -- 992
				function(____, resolve) -- 992
					Director.systemScheduler:schedule(once(function() -- 993
						do -- 993
							local function ____catch(e) -- 993
								resolve( -- 1035
									nil, -- 1035
									{ -- 1035
										success = false, -- 1035
										message = tostring(e) -- 1035
									} -- 1035
								) -- 1035
							end -- 1035
							local ____try, ____hasReturned = pcall(function() -- 1035
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 995
								local allResults = {} -- 998
								do -- 998
									local i = 0 -- 999
									while i < #patterns do -- 999
										local ____Content_28 = Content -- 1000
										local ____Content_searchFilesAsync_29 = Content.searchFilesAsync -- 1000
										local ____patterns_index_27 = patterns[i + 1] -- 1005
										local ____req_useRegex_24 = req.useRegex -- 1006
										if ____req_useRegex_24 == nil then -- 1006
											____req_useRegex_24 = false -- 1006
										end -- 1006
										local ____req_caseSensitive_25 = req.caseSensitive -- 1007
										if ____req_caseSensitive_25 == nil then -- 1007
											____req_caseSensitive_25 = false -- 1007
										end -- 1007
										local ____req_includeContent_26 = req.includeContent -- 1008
										if ____req_includeContent_26 == nil then -- 1008
											____req_includeContent_26 = true -- 1008
										end -- 1008
										allResults[#allResults + 1] = ____Content_searchFilesAsync_29( -- 1000
											____Content_28, -- 1000
											searchRoot, -- 1001
											codeExtensions, -- 1002
											extensionLevels, -- 1003
											searchGlobs, -- 1004
											____patterns_index_27, -- 1005
											____req_useRegex_24, -- 1006
											____req_caseSensitive_25, -- 1007
											____req_includeContent_26, -- 1008
											req.contentWindow or 120 -- 1009
										) -- 1009
										i = i + 1 -- 999
									end -- 999
								end -- 999
								local results = mergeSearchFileResultsUnique(allResults) -- 1012
								local totalResults = #results -- 1013
								local limit = math.max( -- 1014
									1, -- 1014
									math.floor(req.limit or 20) -- 1014
								) -- 1014
								local offset = math.max( -- 1015
									0, -- 1015
									math.floor(req.offset or 0) -- 1015
								) -- 1015
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1016
								local nextOffset = offset + #paged -- 1017
								local hasMore = nextOffset < totalResults -- 1018
								local truncated = offset > 0 or hasMore -- 1019
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1020
								local groupByFile = req.groupByFile == true -- 1021
								resolve( -- 1022
									nil, -- 1022
									{ -- 1022
										success = true, -- 1023
										results = relativeResults, -- 1024
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1025
										totalResults = totalResults, -- 1026
										truncated = truncated, -- 1027
										limit = limit, -- 1028
										offset = offset, -- 1029
										nextOffset = nextOffset, -- 1030
										hasMore = hasMore, -- 1031
										groupByFile = groupByFile -- 1032
									} -- 1032
								) -- 1032
							end) -- 1032
							if not ____try then -- 1032
								____catch(____hasReturned) -- 1032
							end -- 1032
						end -- 1032
					end)) -- 993
				end -- 992
			) -- 992
		) -- 992
	end) -- 992
end -- 963
function ____exports.searchDoraAPI(req) -- 1041
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1041
		local pattern = __TS__StringTrim(req.pattern or "") -- 1052
		if pattern == "" then -- 1052
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1052
		end -- 1052
		local patterns = splitSearchPatterns(pattern) -- 1054
		if #patterns == 0 then -- 1054
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1054
		end -- 1054
		local docSource = req.docSource or "api" -- 1056
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1057
		local docRoot = target.root -- 1058
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1059
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1059
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1059
		end -- 1059
		local exts = target.exts -- 1063
		local dotExts = __TS__ArrayMap( -- 1064
			exts, -- 1064
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1064
		) -- 1064
		local globs = target.globs -- 1065
		local limit = math.max( -- 1066
			1, -- 1066
			math.floor(req.limit or 10) -- 1066
		) -- 1066
		return ____awaiter_resolve( -- 1066
			nil, -- 1066
			__TS__New( -- 1068
				__TS__Promise, -- 1068
				function(____, resolve) -- 1068
					Director.systemScheduler:schedule(once(function() -- 1069
						do -- 1069
							local function ____catch(e) -- 1069
								resolve( -- 1114
									nil, -- 1114
									{ -- 1114
										success = false, -- 1114
										message = tostring(e) -- 1114
									} -- 1114
								) -- 1114
							end -- 1114
							local ____try, ____hasReturned = pcall(function() -- 1114
								local allHits = {} -- 1071
								do -- 1071
									local p = 0 -- 1072
									while p < #patterns do -- 1072
										local ____Content_34 = Content -- 1073
										local ____Content_searchFilesAsync_35 = Content.searchFilesAsync -- 1073
										local ____array_33 = __TS__SparseArrayNew( -- 1073
											docRoot, -- 1074
											dotExts, -- 1075
											{}, -- 1076
											ensureSafeSearchGlobs(globs), -- 1077
											patterns[p + 1] -- 1078
										) -- 1078
										local ____req_useRegex_30 = req.useRegex -- 1079
										if ____req_useRegex_30 == nil then -- 1079
											____req_useRegex_30 = false -- 1079
										end -- 1079
										__TS__SparseArrayPush(____array_33, ____req_useRegex_30) -- 1079
										local ____req_caseSensitive_31 = req.caseSensitive -- 1080
										if ____req_caseSensitive_31 == nil then -- 1080
											____req_caseSensitive_31 = false -- 1080
										end -- 1080
										__TS__SparseArrayPush(____array_33, ____req_caseSensitive_31) -- 1080
										local ____req_includeContent_32 = req.includeContent -- 1081
										if ____req_includeContent_32 == nil then -- 1081
											____req_includeContent_32 = true -- 1081
										end -- 1081
										__TS__SparseArrayPush(____array_33, ____req_includeContent_32, req.contentWindow or 80) -- 1081
										local raw = ____Content_searchFilesAsync_35( -- 1073
											____Content_34, -- 1073
											__TS__SparseArraySpread(____array_33) -- 1073
										) -- 1073
										local hits = {} -- 1084
										do -- 1084
											local i = 0 -- 1085
											while i < #raw do -- 1085
												do -- 1085
													local row = raw[i + 1] -- 1086
													if type(row) ~= "table" then -- 1086
														goto __continue214 -- 1087
													end -- 1087
													local file = type(row.file) == "string" and toDocRelativePath(resultBaseRoot, row.file) or (type(row.path) == "string" and toDocRelativePath(resultBaseRoot, row.path) or "") -- 1088
													if file == "" then -- 1088
														goto __continue214 -- 1091
													end -- 1091
													hits[#hits + 1] = { -- 1092
														file = file, -- 1093
														line = type(row.line) == "number" and row.line or nil, -- 1094
														content = type(row.content) == "string" and row.content or nil -- 1095
													} -- 1095
												end -- 1095
												::__continue214:: -- 1095
												i = i + 1 -- 1085
											end -- 1085
										end -- 1085
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1098
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1098
											0, -- 1098
											limit -- 1098
										) -- 1098
										p = p + 1 -- 1072
									end -- 1072
								end -- 1072
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1100
								resolve(nil, { -- 1101
									success = true, -- 1102
									docSource = docSource, -- 1103
									docLanguage = req.docLanguage, -- 1104
									programmingLanguage = req.programmingLanguage, -- 1105
									root = docRoot, -- 1106
									exts = exts, -- 1107
									results = hits, -- 1108
									totalResults = #hits, -- 1109
									truncated = false, -- 1110
									limit = limit -- 1111
								}) -- 1111
							end) -- 1111
							if not ____try then -- 1111
								____catch(____hasReturned) -- 1111
							end -- 1111
						end -- 1111
					end)) -- 1069
				end -- 1068
			) -- 1068
		) -- 1068
	end) -- 1068
end -- 1041
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1120
	if options == nil then -- 1120
		options = {} -- 1120
	end -- 1120
	if #changes == 0 then -- 1120
		return {success = false, message = "empty changes"} -- 1122
	end -- 1122
	if not isValidWorkDir(workDir) then -- 1122
		return {success = false, message = "invalid workDir"} -- 1125
	end -- 1125
	if not getTaskStatus(taskId) then -- 1125
		return {success = false, message = "task not found"} -- 1128
	end -- 1128
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1130
	local dup = rejectDuplicatePaths(expandedChanges) -- 1131
	if dup then -- 1131
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1133
	end -- 1133
	for ____, change in ipairs(expandedChanges) do -- 1136
		if not isValidWorkspacePath(change.path) then -- 1136
			return {success = false, message = "invalid path: " .. change.path} -- 1138
		end -- 1138
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1138
			return {success = false, message = "missing content for " .. change.path} -- 1141
		end -- 1141
	end -- 1141
	local headSeq = getTaskHeadSeq(taskId) -- 1145
	if headSeq == nil then -- 1145
		return {success = false, message = "task not found"} -- 1146
	end -- 1146
	local nextSeq = headSeq + 1 -- 1147
	local checkpointId = insertCheckpoint( -- 1148
		taskId, -- 1148
		nextSeq, -- 1148
		options.summary or "", -- 1148
		options.toolName or "", -- 1148
		"PREPARED" -- 1148
	) -- 1148
	if checkpointId <= 0 then -- 1148
		return {success = false, message = "failed to create checkpoint"} -- 1150
	end -- 1150
	do -- 1150
		local i = 0 -- 1153
		while i < #expandedChanges do -- 1153
			local change = expandedChanges[i + 1] -- 1154
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1155
			if not fullPath then -- 1155
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1157
				return {success = false, message = "invalid path: " .. change.path} -- 1158
			end -- 1158
			local before = getFileState(fullPath) -- 1160
			local afterExists = change.op ~= "delete" -- 1161
			local afterContent = afterExists and (change.content or "") or "" -- 1162
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1163
				checkpointId, -- 1167
				i + 1, -- 1168
				change.path, -- 1169
				change.op, -- 1170
				before.exists and 1 or 0, -- 1171
				before.content, -- 1172
				afterExists and 1 or 0, -- 1173
				afterContent, -- 1174
				before.bytes, -- 1175
				#afterContent -- 1176
			}) -- 1176
			if inserted <= 0 then -- 1176
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1180
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1181
			end -- 1181
			i = i + 1 -- 1153
		end -- 1153
	end -- 1153
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1185
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1186
		if not fullPath then -- 1186
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1188
			return {success = false, message = "invalid path: " .. entry.path} -- 1189
		end -- 1189
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1191
		if not ok then -- 1191
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1193
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1194
		end -- 1194
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1194
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1197
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1198
		end -- 1198
	end -- 1198
	DB:exec( -- 1202
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1202
		{ -- 1204
			"APPLIED", -- 1204
			now(), -- 1204
			checkpointId -- 1204
		} -- 1204
	) -- 1204
	DB:exec( -- 1206
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1206
		{ -- 1208
			nextSeq, -- 1208
			now(), -- 1208
			taskId -- 1208
		} -- 1208
	) -- 1208
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1210
end -- 1120
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1218
	if not isValidWorkDir(workDir) then -- 1218
		return {success = false, message = "invalid workDir"} -- 1219
	end -- 1219
	if checkpointId <= 0 then -- 1219
		return {success = false, message = "invalid checkpointId"} -- 1220
	end -- 1220
	local entries = getCheckpointEntries(checkpointId, true) -- 1221
	if #entries == 0 then -- 1221
		return {success = false, message = "checkpoint not found or empty"} -- 1223
	end -- 1223
	for ____, entry in ipairs(entries) do -- 1225
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1226
		if not fullPath then -- 1226
			return {success = false, message = "invalid path: " .. entry.path} -- 1228
		end -- 1228
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1230
		if not ok then -- 1230
			Log( -- 1232
				"Error", -- 1232
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1232
			) -- 1232
			Log( -- 1233
				"Info", -- 1233
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1233
			) -- 1233
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1234
		end -- 1234
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1234
			Log( -- 1237
				"Error", -- 1237
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1237
			) -- 1237
			Log( -- 1238
				"Info", -- 1238
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1238
			) -- 1238
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1239
		end -- 1239
	end -- 1239
	return {success = true, checkpointId = checkpointId} -- 1242
end -- 1218
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1245
	return getCheckpointEntries(checkpointId, false) -- 1246
end -- 1245
function ____exports.getCheckpointDiff(checkpointId) -- 1249
	if checkpointId <= 0 then -- 1249
		return {success = false, message = "invalid checkpointId"} -- 1251
	end -- 1251
	local entries = getCheckpointEntries(checkpointId, false) -- 1253
	if #entries == 0 then -- 1253
		return {success = false, message = "checkpoint not found or empty"} -- 1255
	end -- 1255
	return { -- 1257
		success = true, -- 1258
		files = __TS__ArrayMap( -- 1259
			entries, -- 1259
			function(____, entry) return { -- 1259
				path = entry.path, -- 1260
				op = entry.op, -- 1261
				beforeExists = entry.beforeExists, -- 1262
				afterExists = entry.afterExists, -- 1263
				beforeContent = entry.beforeContent, -- 1264
				afterContent = entry.afterContent -- 1265
			} end -- 1265
		) -- 1265
	} -- 1265
end -- 1249
function ____exports.build(req) -- 1270
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1270
		local targetRel = req.path or "" -- 1271
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1272
		if not target then -- 1272
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1272
		end -- 1272
		if not Content:exist(target) then -- 1272
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1272
		end -- 1272
		local messages = {} -- 1279
		if not Content:isdir(target) then -- 1279
			local kind = getSupportedBuildKind(target) -- 1281
			if not kind then -- 1281
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1281
			end -- 1281
			if kind == "ts" then -- 1281
				local content = Content:load(target) -- 1286
				if content == nil then -- 1286
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1286
				end -- 1286
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1286
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1286
				end -- 1286
				if not isDtsFile(target) then -- 1286
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1294
				end -- 1294
			else -- 1294
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1297
			end -- 1297
			Log( -- 1299
				"Info", -- 1299
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1299
			) -- 1299
			return ____awaiter_resolve( -- 1299
				nil, -- 1299
				{ -- 1300
					success = true, -- 1301
					messages = __TS__ArrayMap( -- 1302
						messages, -- 1302
						function(____, m) return m.success and __TS__ObjectAssign( -- 1302
							{}, -- 1303
							m, -- 1303
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1303
						) or __TS__ObjectAssign( -- 1303
							{}, -- 1304
							m, -- 1304
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1304
						) end -- 1304
					) -- 1304
				} -- 1304
			) -- 1304
		end -- 1304
		local listResult = ____exports.listFiles({ -- 1307
			workDir = req.workDir, -- 1308
			path = target, -- 1309
			globs = __TS__ArrayMap( -- 1310
				codeExtensions, -- 1310
				function(____, e) return "**/*" .. e end -- 1310
			), -- 1310
			maxEntries = 10000 -- 1311
		}) -- 1311
		local relFiles = listResult.success and listResult.files or ({}) -- 1314
		local tsFileData = {} -- 1315
		local buildQueue = {} -- 1316
		for ____, rel in ipairs(relFiles) do -- 1317
			do -- 1317
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1318
				local kind = getSupportedBuildKind(file) -- 1319
				if not kind then -- 1319
					goto __continue264 -- 1320
				end -- 1320
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1321
				if kind ~= "ts" then -- 1321
					goto __continue264 -- 1323
				end -- 1323
				local content = Content:load(file) -- 1325
				if content == nil then -- 1325
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1327
					goto __continue264 -- 1328
				end -- 1328
				tsFileData[file] = content -- 1330
				if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1330
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1332
					goto __continue264 -- 1333
				end -- 1333
			end -- 1333
			::__continue264:: -- 1333
		end -- 1333
		do -- 1333
			local i = 0 -- 1336
			while i < #buildQueue do -- 1336
				do -- 1336
					local ____buildQueue_index_36 = buildQueue[i + 1] -- 1337
					local file = ____buildQueue_index_36.file -- 1337
					local kind = ____buildQueue_index_36.kind -- 1337
					if kind == "ts" then -- 1337
						local content = tsFileData[file] -- 1339
						if content == nil or isDtsFile(file) then -- 1339
							goto __continue271 -- 1341
						end -- 1341
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1343
						goto __continue271 -- 1344
					end -- 1344
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1346
				end -- 1346
				::__continue271:: -- 1346
				i = i + 1 -- 1336
			end -- 1336
		end -- 1336
		Log( -- 1348
			"Info", -- 1348
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1348
		) -- 1348
		return ____awaiter_resolve( -- 1348
			nil, -- 1348
			{ -- 1349
				success = true, -- 1350
				messages = __TS__ArrayMap( -- 1351
					messages, -- 1351
					function(____, m) return m.success and __TS__ObjectAssign( -- 1351
						{}, -- 1352
						m, -- 1352
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1352
					) or __TS__ObjectAssign( -- 1352
						{}, -- 1353
						m, -- 1353
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1353
					) end -- 1353
				) -- 1353
			} -- 1353
		) -- 1353
	end) -- 1353
end -- 1270
return ____exports -- 1270