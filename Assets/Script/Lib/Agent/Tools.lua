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
function ensureSafeSearchGlobs(globs) -- 826
	local result = {} -- 827
	do -- 827
		local i = 0 -- 828
		while i < #globs do -- 828
			result[#result + 1] = globs[i + 1] -- 829
			i = i + 1 -- 828
		end -- 828
	end -- 828
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 831
	do -- 831
		local i = 0 -- 832
		while i < #requiredExcludes do -- 832
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 832
				result[#result + 1] = requiredExcludes[i + 1] -- 834
			end -- 834
			i = i + 1 -- 832
		end -- 832
	end -- 832
	return result -- 837
end -- 837
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
	local numbered = {} -- 771
	do -- 771
		local i = start -- 772
		while i <= ____end do -- 772
			numbered[#numbered + 1] = (tostring(i) .. "| ") .. lines[i] -- 773
			i = i + 1 -- 772
		end -- 772
	end -- 772
	local output = table.concat(numbered, "\n") -- 775
	local truncated = ____end < totalLines -- 776
	output = output .. (truncated and ((((((("\n\n(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use offset=") .. tostring(____end + 1)) .. " to continue.)" or ("\n\n(End of file - " .. tostring(totalLines)) .. " lines total)") -- 777
	return { -- 780
		success = true, -- 781
		content = output, -- 782
		totalLines = totalLines, -- 783
		startLine = start, -- 784
		endLine = ____end, -- 785
		truncated = truncated -- 786
	} -- 786
end -- 748
function ____exports.readFile(workDir, path, offset, limit, docLanguage) -- 790
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 797
	if not fallback.success then -- 797
		return fallback -- 799
	end -- 799
	local start = math.max( -- 801
		1, -- 801
		math.floor(offset or 1) -- 801
	) -- 801
	local maxLines = math.max( -- 802
		1, -- 802
		math.floor(limit or 300) -- 802
	) -- 802
	return formatReadSlice(fallback.content, start, maxLines) -- 803
end -- 790
function ____exports.readFileRange(workDir, path, startLine, endLine, docLanguage) -- 806
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 807
	if not fallback.success or fallback.content == nil then -- 807
		return fallback -- 808
	end -- 808
	local s = math.max( -- 809
		1, -- 809
		math.floor(startLine) -- 809
	) -- 809
	local e = math.max( -- 810
		s, -- 810
		math.floor(endLine) -- 810
	) -- 810
	return formatReadSlice(fallback.content, s, e - s + 1) -- 811
end -- 806
local codeExtensions = { -- 814
	".lua", -- 814
	".tl", -- 814
	".yue", -- 814
	".ts", -- 814
	".tsx", -- 814
	".xml", -- 814
	".md", -- 814
	".yarn", -- 814
	".wa", -- 814
	".mod" -- 814
} -- 814
extensionLevels = { -- 815
	vs = 2, -- 816
	bl = 2, -- 817
	ts = 1, -- 818
	tsx = 1, -- 819
	tl = 1, -- 820
	yue = 1, -- 821
	xml = 1, -- 822
	lua = 0 -- 823
} -- 823
local function splitSearchPatterns(pattern) -- 840
	local trimmed = __TS__StringTrim(pattern or "") -- 841
	if trimmed == "" then -- 841
		return {} -- 842
	end -- 842
	local out = {} -- 843
	local seen = __TS__New(Set) -- 844
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 845
		local p = __TS__StringTrim(tostring(p0)) -- 846
		if p ~= "" and not seen:has(p) then -- 846
			seen:add(p) -- 848
			out[#out + 1] = p -- 849
		end -- 849
	end -- 849
	return out -- 852
end -- 840
local function mergeSearchFileResultsUnique(resultsList) -- 855
	local merged = {} -- 856
	local seen = __TS__New(Set) -- 857
	do -- 857
		local i = 0 -- 858
		while i < #resultsList do -- 858
			local list = resultsList[i + 1] -- 859
			do -- 859
				local j = 0 -- 860
				while j < #list do -- 860
					do -- 860
						local row = list[j + 1] -- 861
						local ____temp_18 -- 862
						if type(row) == "table" then -- 862
							local ____tostring_8 = tostring -- 863
							local ____row_file_6 = row.file -- 863
							if ____row_file_6 == nil then -- 863
								____row_file_6 = row.path -- 863
							end -- 863
							local ____row_file_6_7 = ____row_file_6 -- 863
							if ____row_file_6_7 == nil then -- 863
								____row_file_6_7 = "" -- 863
							end -- 863
							local ____tostring_8_result_15 = ____tostring_8(____row_file_6_7) -- 863
							local ____tostring_10 = tostring -- 863
							local ____row_pos_9 = row.pos -- 863
							if ____row_pos_9 == nil then -- 863
								____row_pos_9 = "" -- 863
							end -- 863
							local ____tostring_10_result_16 = ____tostring_10(____row_pos_9) -- 863
							local ____tostring_12 = tostring -- 863
							local ____row_line_11 = row.line -- 863
							if ____row_line_11 == nil then -- 863
								____row_line_11 = "" -- 863
							end -- 863
							local ____tostring_12_result_17 = ____tostring_12(____row_line_11) -- 863
							local ____tostring_14 = tostring -- 863
							local ____row_column_13 = row.column -- 863
							if ____row_column_13 == nil then -- 863
								____row_column_13 = "" -- 863
							end -- 863
							____temp_18 = (((((____tostring_8_result_15 .. ":") .. ____tostring_10_result_16) .. ":") .. ____tostring_12_result_17) .. ":") .. ____tostring_14(____row_column_13) -- 863
						else -- 863
							____temp_18 = tostring(j) -- 864
						end -- 864
						local key = ____temp_18 -- 862
						if seen:has(key) then -- 862
							goto __continue169 -- 865
						end -- 865
						seen:add(key) -- 866
						merged[#merged + 1] = list[j + 1] -- 867
					end -- 867
					::__continue169:: -- 867
					j = j + 1 -- 860
				end -- 860
			end -- 860
			i = i + 1 -- 858
		end -- 858
	end -- 858
	return merged -- 870
end -- 855
local function buildGroupedSearchResults(results) -- 873
	local order = {} -- 878
	local grouped = __TS__New(Map) -- 879
	do -- 879
		local i = 0 -- 884
		while i < #results do -- 884
			local row = results[i + 1] -- 885
			local ____temp_22 -- 886
			if type(row) == "table" then -- 886
				local ____tostring_21 = tostring -- 887
				local ____row_file_19 = row.file -- 887
				if ____row_file_19 == nil then -- 887
					____row_file_19 = row.path -- 887
				end -- 887
				local ____row_file_19_20 = ____row_file_19 -- 887
				if ____row_file_19_20 == nil then -- 887
					____row_file_19_20 = "" -- 887
				end -- 887
				____temp_22 = ____tostring_21(____row_file_19_20) -- 887
			else -- 887
				____temp_22 = "" -- 888
			end -- 888
			local file = ____temp_22 -- 886
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 889
			local bucket = grouped:get(key) -- 890
			if not bucket then -- 890
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 892
				grouped:set(key, bucket) -- 893
				order[#order + 1] = key -- 894
			end -- 894
			bucket.totalMatches = bucket.totalMatches + 1 -- 896
			local ____bucket_matches_23 = bucket.matches -- 896
			____bucket_matches_23[#____bucket_matches_23 + 1] = results[i + 1] -- 897
			i = i + 1 -- 884
		end -- 884
	end -- 884
	local out = {} -- 899
	do -- 899
		local i = 0 -- 904
		while i < #order do -- 904
			local bucket = grouped:get(order[i + 1]) -- 905
			if bucket then -- 905
				out[#out + 1] = bucket -- 906
			end -- 906
			i = i + 1 -- 904
		end -- 904
	end -- 904
	return out -- 908
end -- 873
local function mergeDoraAPISearchHitsUnique(resultsList) -- 911
	local merged = {} -- 912
	local seen = __TS__New(Set) -- 913
	local index = 0 -- 914
	local advanced = true -- 915
	while advanced do -- 915
		advanced = false -- 917
		do -- 917
			local i = 0 -- 918
			while i < #resultsList do -- 918
				do -- 918
					local list = resultsList[i + 1] -- 919
					if index >= #list then -- 919
						goto __continue181 -- 920
					end -- 920
					advanced = true -- 921
					local row = list[index + 1] -- 922
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 923
					if seen:has(key) then -- 923
						goto __continue181 -- 924
					end -- 924
					seen:add(key) -- 925
					merged[#merged + 1] = row -- 926
				end -- 926
				::__continue181:: -- 926
				i = i + 1 -- 918
			end -- 918
		end -- 918
		index = index + 1 -- 928
	end -- 928
	return merged -- 930
end -- 911
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 933
	if docSource ~= "api" then -- 933
		return 100 -- 934
	end -- 934
	if programmingLanguage ~= "tsx" then -- 934
		return 100 -- 935
	end -- 935
	repeat -- 935
		local ____switch187 = string.lower(Path:getFilename(file)) -- 935
		local ____cond187 = ____switch187 == "jsx.d.ts" -- 935
		if ____cond187 then -- 935
			return 0 -- 937
		end -- 937
		____cond187 = ____cond187 or ____switch187 == "dorax.d.ts" -- 937
		if ____cond187 then -- 937
			return 1 -- 938
		end -- 938
		____cond187 = ____cond187 or ____switch187 == "dora.d.ts" -- 938
		if ____cond187 then -- 938
			return 2 -- 939
		end -- 939
		do -- 939
			return 100 -- 940
		end -- 940
	until true -- 940
end -- 933
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 944
	local sorted = __TS__ArraySlice(hits) -- 949
	__TS__ArraySort( -- 950
		sorted, -- 950
		function(____, a, b) -- 950
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 951
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 952
			if pa ~= pb then -- 952
				return pa - pb -- 953
			end -- 953
			local fa = string.lower(a.file) -- 954
			local fb = string.lower(b.file) -- 955
			if fa ~= fb then -- 955
				return fa < fb and -1 or 1 -- 956
			end -- 956
			return (a.line or 0) - (b.line or 0) -- 957
		end -- 950
	) -- 950
	return sorted -- 959
end -- 944
function ____exports.searchFiles(req) -- 962
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 962
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 975
		if not resolvedPath then -- 975
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 975
		end -- 975
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 979
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 980
		if not searchRoot then -- 980
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 980
		end -- 980
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 980
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 980
		end -- 980
		local patterns = splitSearchPatterns(req.pattern) -- 987
		if #patterns == 0 then -- 987
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 987
		end -- 987
		return ____awaiter_resolve( -- 987
			nil, -- 987
			__TS__New( -- 991
				__TS__Promise, -- 991
				function(____, resolve) -- 991
					Director.systemScheduler:schedule(once(function() -- 992
						do -- 992
							local function ____catch(e) -- 992
								resolve( -- 1034
									nil, -- 1034
									{ -- 1034
										success = false, -- 1034
										message = tostring(e) -- 1034
									} -- 1034
								) -- 1034
							end -- 1034
							local ____try, ____hasReturned = pcall(function() -- 1034
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 994
								local allResults = {} -- 997
								do -- 997
									local i = 0 -- 998
									while i < #patterns do -- 998
										local ____Content_28 = Content -- 999
										local ____Content_searchFilesAsync_29 = Content.searchFilesAsync -- 999
										local ____patterns_index_27 = patterns[i + 1] -- 1004
										local ____req_useRegex_24 = req.useRegex -- 1005
										if ____req_useRegex_24 == nil then -- 1005
											____req_useRegex_24 = false -- 1005
										end -- 1005
										local ____req_caseSensitive_25 = req.caseSensitive -- 1006
										if ____req_caseSensitive_25 == nil then -- 1006
											____req_caseSensitive_25 = false -- 1006
										end -- 1006
										local ____req_includeContent_26 = req.includeContent -- 1007
										if ____req_includeContent_26 == nil then -- 1007
											____req_includeContent_26 = true -- 1007
										end -- 1007
										allResults[#allResults + 1] = ____Content_searchFilesAsync_29( -- 999
											____Content_28, -- 999
											searchRoot, -- 1000
											codeExtensions, -- 1001
											extensionLevels, -- 1002
											searchGlobs, -- 1003
											____patterns_index_27, -- 1004
											____req_useRegex_24, -- 1005
											____req_caseSensitive_25, -- 1006
											____req_includeContent_26, -- 1007
											req.contentWindow or 120 -- 1008
										) -- 1008
										i = i + 1 -- 998
									end -- 998
								end -- 998
								local results = mergeSearchFileResultsUnique(allResults) -- 1011
								local totalResults = #results -- 1012
								local limit = math.max( -- 1013
									1, -- 1013
									math.floor(req.limit or 20) -- 1013
								) -- 1013
								local offset = math.max( -- 1014
									0, -- 1014
									math.floor(req.offset or 0) -- 1014
								) -- 1014
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1015
								local nextOffset = offset + #paged -- 1016
								local hasMore = nextOffset < totalResults -- 1017
								local truncated = offset > 0 or hasMore -- 1018
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1019
								local groupByFile = req.groupByFile == true -- 1020
								resolve( -- 1021
									nil, -- 1021
									{ -- 1021
										success = true, -- 1022
										results = relativeResults, -- 1023
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1024
										totalResults = totalResults, -- 1025
										truncated = truncated, -- 1026
										limit = limit, -- 1027
										offset = offset, -- 1028
										nextOffset = nextOffset, -- 1029
										hasMore = hasMore, -- 1030
										groupByFile = groupByFile -- 1031
									} -- 1031
								) -- 1031
							end) -- 1031
							if not ____try then -- 1031
								____catch(____hasReturned) -- 1031
							end -- 1031
						end -- 1031
					end)) -- 992
				end -- 991
			) -- 991
		) -- 991
	end) -- 991
end -- 962
function ____exports.searchDoraAPI(req) -- 1040
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1040
		local pattern = __TS__StringTrim(req.pattern or "") -- 1051
		if pattern == "" then -- 1051
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1051
		end -- 1051
		local patterns = splitSearchPatterns(pattern) -- 1053
		if #patterns == 0 then -- 1053
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1053
		end -- 1053
		local docSource = req.docSource or "api" -- 1055
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1056
		local docRoot = target.root -- 1057
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1058
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1058
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1058
		end -- 1058
		local exts = target.exts -- 1062
		local dotExts = __TS__ArrayMap( -- 1063
			exts, -- 1063
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1063
		) -- 1063
		local globs = target.globs -- 1064
		local limit = math.max( -- 1065
			1, -- 1065
			math.floor(req.limit or 10) -- 1065
		) -- 1065
		return ____awaiter_resolve( -- 1065
			nil, -- 1065
			__TS__New( -- 1067
				__TS__Promise, -- 1067
				function(____, resolve) -- 1067
					Director.systemScheduler:schedule(once(function() -- 1068
						do -- 1068
							local function ____catch(e) -- 1068
								resolve( -- 1113
									nil, -- 1113
									{ -- 1113
										success = false, -- 1113
										message = tostring(e) -- 1113
									} -- 1113
								) -- 1113
							end -- 1113
							local ____try, ____hasReturned = pcall(function() -- 1113
								local allHits = {} -- 1070
								do -- 1070
									local p = 0 -- 1071
									while p < #patterns do -- 1071
										local ____Content_34 = Content -- 1072
										local ____Content_searchFilesAsync_35 = Content.searchFilesAsync -- 1072
										local ____array_33 = __TS__SparseArrayNew( -- 1072
											docRoot, -- 1073
											dotExts, -- 1074
											{}, -- 1075
											ensureSafeSearchGlobs(globs), -- 1076
											patterns[p + 1] -- 1077
										) -- 1077
										local ____req_useRegex_30 = req.useRegex -- 1078
										if ____req_useRegex_30 == nil then -- 1078
											____req_useRegex_30 = false -- 1078
										end -- 1078
										__TS__SparseArrayPush(____array_33, ____req_useRegex_30) -- 1078
										local ____req_caseSensitive_31 = req.caseSensitive -- 1079
										if ____req_caseSensitive_31 == nil then -- 1079
											____req_caseSensitive_31 = false -- 1079
										end -- 1079
										__TS__SparseArrayPush(____array_33, ____req_caseSensitive_31) -- 1079
										local ____req_includeContent_32 = req.includeContent -- 1080
										if ____req_includeContent_32 == nil then -- 1080
											____req_includeContent_32 = true -- 1080
										end -- 1080
										__TS__SparseArrayPush(____array_33, ____req_includeContent_32, req.contentWindow or 80) -- 1080
										local raw = ____Content_searchFilesAsync_35( -- 1072
											____Content_34, -- 1072
											__TS__SparseArraySpread(____array_33) -- 1072
										) -- 1072
										local hits = {} -- 1083
										do -- 1083
											local i = 0 -- 1084
											while i < #raw do -- 1084
												do -- 1084
													local row = raw[i + 1] -- 1085
													if type(row) ~= "table" then -- 1085
														goto __continue214 -- 1086
													end -- 1086
													local file = type(row.file) == "string" and toDocRelativePath(resultBaseRoot, row.file) or (type(row.path) == "string" and toDocRelativePath(resultBaseRoot, row.path) or "") -- 1087
													if file == "" then -- 1087
														goto __continue214 -- 1090
													end -- 1090
													hits[#hits + 1] = { -- 1091
														file = file, -- 1092
														line = type(row.line) == "number" and row.line or nil, -- 1093
														content = type(row.content) == "string" and row.content or nil -- 1094
													} -- 1094
												end -- 1094
												::__continue214:: -- 1094
												i = i + 1 -- 1084
											end -- 1084
										end -- 1084
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1097
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1097
											0, -- 1097
											limit -- 1097
										) -- 1097
										p = p + 1 -- 1071
									end -- 1071
								end -- 1071
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1099
								resolve(nil, { -- 1100
									success = true, -- 1101
									docSource = docSource, -- 1102
									docLanguage = req.docLanguage, -- 1103
									programmingLanguage = req.programmingLanguage, -- 1104
									root = docRoot, -- 1105
									exts = exts, -- 1106
									results = hits, -- 1107
									totalResults = #hits, -- 1108
									truncated = false, -- 1109
									limit = limit -- 1110
								}) -- 1110
							end) -- 1110
							if not ____try then -- 1110
								____catch(____hasReturned) -- 1110
							end -- 1110
						end -- 1110
					end)) -- 1068
				end -- 1067
			) -- 1067
		) -- 1067
	end) -- 1067
end -- 1040
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1119
	if options == nil then -- 1119
		options = {} -- 1119
	end -- 1119
	if #changes == 0 then -- 1119
		return {success = false, message = "empty changes"} -- 1121
	end -- 1121
	if not isValidWorkDir(workDir) then -- 1121
		return {success = false, message = "invalid workDir"} -- 1124
	end -- 1124
	if not getTaskStatus(taskId) then -- 1124
		return {success = false, message = "task not found"} -- 1127
	end -- 1127
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1129
	local dup = rejectDuplicatePaths(expandedChanges) -- 1130
	if dup then -- 1130
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1132
	end -- 1132
	for ____, change in ipairs(expandedChanges) do -- 1135
		if not isValidWorkspacePath(change.path) then -- 1135
			return {success = false, message = "invalid path: " .. change.path} -- 1137
		end -- 1137
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1137
			return {success = false, message = "missing content for " .. change.path} -- 1140
		end -- 1140
	end -- 1140
	local headSeq = getTaskHeadSeq(taskId) -- 1144
	if headSeq == nil then -- 1144
		return {success = false, message = "task not found"} -- 1145
	end -- 1145
	local nextSeq = headSeq + 1 -- 1146
	local checkpointId = insertCheckpoint( -- 1147
		taskId, -- 1147
		nextSeq, -- 1147
		options.summary or "", -- 1147
		options.toolName or "", -- 1147
		"PREPARED" -- 1147
	) -- 1147
	if checkpointId <= 0 then -- 1147
		return {success = false, message = "failed to create checkpoint"} -- 1149
	end -- 1149
	do -- 1149
		local i = 0 -- 1152
		while i < #expandedChanges do -- 1152
			local change = expandedChanges[i + 1] -- 1153
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1154
			if not fullPath then -- 1154
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1156
				return {success = false, message = "invalid path: " .. change.path} -- 1157
			end -- 1157
			local before = getFileState(fullPath) -- 1159
			local afterExists = change.op ~= "delete" -- 1160
			local afterContent = afterExists and (change.content or "") or "" -- 1161
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1162
				checkpointId, -- 1166
				i + 1, -- 1167
				change.path, -- 1168
				change.op, -- 1169
				before.exists and 1 or 0, -- 1170
				before.content, -- 1171
				afterExists and 1 or 0, -- 1172
				afterContent, -- 1173
				before.bytes, -- 1174
				#afterContent -- 1175
			}) -- 1175
			if inserted <= 0 then -- 1175
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1179
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1180
			end -- 1180
			i = i + 1 -- 1152
		end -- 1152
	end -- 1152
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1184
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1185
		if not fullPath then -- 1185
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1187
			return {success = false, message = "invalid path: " .. entry.path} -- 1188
		end -- 1188
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1190
		if not ok then -- 1190
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1192
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1193
		end -- 1193
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1193
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1196
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1197
		end -- 1197
	end -- 1197
	DB:exec( -- 1201
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1201
		{ -- 1203
			"APPLIED", -- 1203
			now(), -- 1203
			checkpointId -- 1203
		} -- 1203
	) -- 1203
	DB:exec( -- 1205
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1205
		{ -- 1207
			nextSeq, -- 1207
			now(), -- 1207
			taskId -- 1207
		} -- 1207
	) -- 1207
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1209
end -- 1119
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1217
	if not isValidWorkDir(workDir) then -- 1217
		return {success = false, message = "invalid workDir"} -- 1218
	end -- 1218
	if checkpointId <= 0 then -- 1218
		return {success = false, message = "invalid checkpointId"} -- 1219
	end -- 1219
	local entries = getCheckpointEntries(checkpointId, true) -- 1220
	if #entries == 0 then -- 1220
		return {success = false, message = "checkpoint not found or empty"} -- 1222
	end -- 1222
	for ____, entry in ipairs(entries) do -- 1224
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1225
		if not fullPath then -- 1225
			return {success = false, message = "invalid path: " .. entry.path} -- 1227
		end -- 1227
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1229
		if not ok then -- 1229
			Log( -- 1231
				"Error", -- 1231
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1231
			) -- 1231
			Log( -- 1232
				"Info", -- 1232
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1232
			) -- 1232
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1233
		end -- 1233
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1233
			Log( -- 1236
				"Error", -- 1236
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1236
			) -- 1236
			Log( -- 1237
				"Info", -- 1237
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1237
			) -- 1237
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1238
		end -- 1238
	end -- 1238
	return {success = true, checkpointId = checkpointId} -- 1241
end -- 1217
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1244
	return getCheckpointEntries(checkpointId, false) -- 1245
end -- 1244
function ____exports.getCheckpointDiff(checkpointId) -- 1248
	if checkpointId <= 0 then -- 1248
		return {success = false, message = "invalid checkpointId"} -- 1250
	end -- 1250
	local entries = getCheckpointEntries(checkpointId, false) -- 1252
	if #entries == 0 then -- 1252
		return {success = false, message = "checkpoint not found or empty"} -- 1254
	end -- 1254
	return { -- 1256
		success = true, -- 1257
		files = __TS__ArrayMap( -- 1258
			entries, -- 1258
			function(____, entry) return { -- 1258
				path = entry.path, -- 1259
				op = entry.op, -- 1260
				beforeExists = entry.beforeExists, -- 1261
				afterExists = entry.afterExists, -- 1262
				beforeContent = entry.beforeContent, -- 1263
				afterContent = entry.afterContent -- 1264
			} end -- 1264
		) -- 1264
	} -- 1264
end -- 1248
function ____exports.build(req) -- 1269
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1269
		local targetRel = req.path or "" -- 1270
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1271
		if not target then -- 1271
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1271
		end -- 1271
		if not Content:exist(target) then -- 1271
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1271
		end -- 1271
		local messages = {} -- 1278
		if not Content:isdir(target) then -- 1278
			local kind = getSupportedBuildKind(target) -- 1280
			if not kind then -- 1280
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1280
			end -- 1280
			if kind == "ts" then -- 1280
				local content = Content:load(target) -- 1285
				if content == nil then -- 1285
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1285
				end -- 1285
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1285
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1285
				end -- 1285
				if not isDtsFile(target) then -- 1285
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1293
				end -- 1293
			else -- 1293
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1296
			end -- 1296
			Log( -- 1298
				"Info", -- 1298
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1298
			) -- 1298
			return ____awaiter_resolve( -- 1298
				nil, -- 1298
				{ -- 1299
					success = true, -- 1300
					messages = __TS__ArrayMap( -- 1301
						messages, -- 1301
						function(____, m) return m.success and __TS__ObjectAssign( -- 1301
							{}, -- 1302
							m, -- 1302
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1302
						) or __TS__ObjectAssign( -- 1302
							{}, -- 1303
							m, -- 1303
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1303
						) end -- 1303
					) -- 1303
				} -- 1303
			) -- 1303
		end -- 1303
		local listResult = ____exports.listFiles({ -- 1306
			workDir = req.workDir, -- 1307
			path = target, -- 1308
			globs = __TS__ArrayMap( -- 1309
				codeExtensions, -- 1309
				function(____, e) return "**/*" .. e end -- 1309
			), -- 1309
			maxEntries = 10000 -- 1310
		}) -- 1310
		local relFiles = listResult.success and listResult.files or ({}) -- 1313
		local tsFileData = {} -- 1314
		local buildQueue = {} -- 1315
		for ____, rel in ipairs(relFiles) do -- 1316
			do -- 1316
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1317
				local kind = getSupportedBuildKind(file) -- 1318
				if not kind then -- 1318
					goto __continue264 -- 1319
				end -- 1319
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1320
				if kind ~= "ts" then -- 1320
					goto __continue264 -- 1322
				end -- 1322
				local content = Content:load(file) -- 1324
				if content == nil then -- 1324
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1326
					goto __continue264 -- 1327
				end -- 1327
				tsFileData[file] = content -- 1329
				if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1329
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1331
					goto __continue264 -- 1332
				end -- 1332
			end -- 1332
			::__continue264:: -- 1332
		end -- 1332
		do -- 1332
			local i = 0 -- 1335
			while i < #buildQueue do -- 1335
				do -- 1335
					local ____buildQueue_index_36 = buildQueue[i + 1] -- 1336
					local file = ____buildQueue_index_36.file -- 1336
					local kind = ____buildQueue_index_36.kind -- 1336
					if kind == "ts" then -- 1336
						local content = tsFileData[file] -- 1338
						if content == nil or isDtsFile(file) then -- 1338
							goto __continue271 -- 1340
						end -- 1340
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1342
						goto __continue271 -- 1343
					end -- 1343
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1345
				end -- 1345
				::__continue271:: -- 1345
				i = i + 1 -- 1335
			end -- 1335
		end -- 1335
		Log( -- 1347
			"Info", -- 1347
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1347
		) -- 1347
		return ____awaiter_resolve( -- 1347
			nil, -- 1347
			{ -- 1348
				success = true, -- 1349
				messages = __TS__ArrayMap( -- 1350
					messages, -- 1350
					function(____, m) return m.success and __TS__ObjectAssign( -- 1350
						{}, -- 1351
						m, -- 1351
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1351
					) or __TS__ObjectAssign( -- 1351
						{}, -- 1352
						m, -- 1352
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1352
					) end -- 1352
				) -- 1352
			} -- 1352
		) -- 1352
	end) -- 1352
end -- 1269
return ____exports -- 1269