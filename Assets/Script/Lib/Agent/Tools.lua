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
function ensureSafeSearchGlobs(globs) -- 833
	local result = {} -- 834
	do -- 834
		local i = 0 -- 835
		while i < #globs do -- 835
			result[#result + 1] = globs[i + 1] -- 836
			i = i + 1 -- 835
		end -- 835
	end -- 835
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 838
	do -- 838
		local i = 0 -- 839
		while i < #requiredExcludes do -- 839
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 839
				result[#result + 1] = requiredExcludes[i + 1] -- 841
			end -- 841
			i = i + 1 -- 839
		end -- 839
	end -- 839
	return result -- 844
end -- 844
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
	if Content:isAbsolutePath(path) then -- 222
		return false -- 223
	end -- 223
	if not path or #path == 0 then -- 223
		return false -- 224
	end -- 224
	if __TS__StringIncludes(path, "..") then -- 224
		return false -- 225
	end -- 225
	return true -- 226
end -- 221
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
	if not isValidSearchPath(path) then -- 236
		return nil -- 237
	end -- 237
	return path == "" and workDir or Path(workDir, path) -- 238
end -- 235
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
		local ____switch38 = programmingLanguage -- 281
		local ____cond38 = ____switch38 == "teal" -- 281
		if ____cond38 then -- 281
			return "tl" -- 283
		end -- 283
		____cond38 = ____cond38 or ____switch38 == "tl" -- 283
		if ____cond38 then -- 283
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
		local ____switch64 = Path:getExt(path) -- 416
		local ____cond64 = ____switch64 == "ts" or ____switch64 == "tsx" -- 416
		if ____cond64 then -- 416
			return "ts" -- 418
		end -- 418
		____cond64 = ____cond64 or ____switch64 == "xml" -- 418
		if ____cond64 then -- 418
			return "xml" -- 419
		end -- 419
		____cond64 = ____cond64 or ____switch64 == "tl" -- 419
		if ____cond64 then -- 419
			return "teal" -- 420
		end -- 420
		____cond64 = ____cond64 or ____switch64 == "lua" -- 420
		if ____cond64 then -- 420
			return "lua" -- 421
		end -- 421
		____cond64 = ____cond64 or ____switch64 == "yue" -- 421
		if ____cond64 then -- 421
			return "yue" -- 422
		end -- 422
		____cond64 = ____cond64 or ____switch64 == "yarn" -- 422
		if ____cond64 then -- 422
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
				goto __continue81 -- 497
			end -- 497
			local siblingExt = Path:getExt(file) -- 498
			if siblingExt == "tl" and ext == "vs" then -- 498
				linked[#linked + 1] = toWorkspaceRelativePath( -- 500
					workDir, -- 500
					Path(parent, file) -- 500
				) -- 500
				goto __continue81 -- 501
			end -- 501
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 501
				linked[#linked + 1] = toWorkspaceRelativePath( -- 504
					workDir, -- 504
					Path(parent, file) -- 504
				) -- 504
			end -- 504
		end -- 504
		::__continue81:: -- 504
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
					goto __continue88 -- 519
				end -- 519
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 520
				do -- 520
					local j = 0 -- 521
					while j < #linkedPaths do -- 521
						do -- 521
							local linkedPath = linkedPaths[j + 1] -- 522
							if seen:has(linkedPath) then -- 522
								goto __continue92 -- 523
							end -- 523
							seen:add(linkedPath) -- 524
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 525
						end -- 525
						::__continue92:: -- 525
						j = j + 1 -- 521
					end -- 521
				end -- 521
			end -- 521
			::__continue88:: -- 521
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
				if tostring(payload.file) ~= file then -- 585
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
			end -- 580
		) -- 580
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
end -- 569
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
local function formatReadSlice(content, startLine, endLine) -- 738
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
	local rawStart = math.floor(startLine) -- 755
	local rawEnd = math.floor(endLine) -- 756
	if rawStart == 0 then -- 756
		return {success = false, message = "startLine cannot be 0"} -- 758
	end -- 758
	if rawEnd == 0 then -- 758
		return {success = false, message = "endLine cannot be 0"} -- 761
	end -- 761
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 763
	if start > totalLines then -- 763
		return { -- 767
			success = false, -- 767
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 767
		} -- 767
	end -- 767
	local ____end = math.min( -- 769
		totalLines, -- 770
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 771
	) -- 771
	if ____end < start then -- 771
		return { -- 776
			success = false, -- 777
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 778
		} -- 778
	end -- 778
	local slice = {} -- 781
	do -- 781
		local i = start -- 782
		while i <= ____end do -- 782
			slice[#slice + 1] = lines[i] -- 783
			i = i + 1 -- 782
		end -- 782
	end -- 782
	local truncated = start > 1 or ____end < totalLines -- 785
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 786
	local body = table.concat(slice, "\n") -- 791
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 792
	return { -- 793
		success = true, -- 794
		content = output, -- 795
		totalLines = totalLines, -- 796
		startLine = start, -- 797
		endLine = ____end, -- 798
		truncated = truncated -- 799
	} -- 799
end -- 738
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 803
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 810
	if not fallback.success or fallback.content == nil then -- 810
		return fallback -- 811
	end -- 811
	local resolvedStartLine = startLine or 1 -- 812
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 813
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 814
end -- 803
local codeExtensions = { -- 821
	".lua", -- 821
	".tl", -- 821
	".yue", -- 821
	".ts", -- 821
	".tsx", -- 821
	".xml", -- 821
	".md", -- 821
	".yarn", -- 821
	".wa", -- 821
	".mod" -- 821
} -- 821
extensionLevels = { -- 822
	vs = 2, -- 823
	bl = 2, -- 824
	ts = 1, -- 825
	tsx = 1, -- 826
	tl = 1, -- 827
	yue = 1, -- 828
	xml = 1, -- 829
	lua = 0 -- 830
} -- 830
local function splitSearchPatterns(pattern) -- 847
	local trimmed = __TS__StringTrim(pattern or "") -- 848
	if trimmed == "" then -- 848
		return {} -- 849
	end -- 849
	local out = {} -- 850
	local seen = __TS__New(Set) -- 851
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 852
		local p = __TS__StringTrim(tostring(p0)) -- 853
		if p ~= "" and not seen:has(p) then -- 853
			seen:add(p) -- 855
			out[#out + 1] = p -- 856
		end -- 856
	end -- 856
	return out -- 859
end -- 847
local function mergeSearchFileResultsUnique(resultsList) -- 862
	local merged = {} -- 863
	local seen = __TS__New(Set) -- 864
	do -- 864
		local i = 0 -- 865
		while i < #resultsList do -- 865
			local list = resultsList[i + 1] -- 866
			do -- 866
				local j = 0 -- 867
				while j < #list do -- 867
					do -- 867
						local row = list[j + 1] -- 868
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 869
						if seen:has(key) then -- 869
							goto __continue167 -- 870
						end -- 870
						seen:add(key) -- 871
						merged[#merged + 1] = list[j + 1] -- 872
					end -- 872
					::__continue167:: -- 872
					j = j + 1 -- 867
				end -- 867
			end -- 867
			i = i + 1 -- 865
		end -- 865
	end -- 865
	return merged -- 875
end -- 862
local function buildGroupedSearchResults(results) -- 878
	local order = {} -- 883
	local grouped = __TS__New(Map) -- 884
	do -- 884
		local i = 0 -- 889
		while i < #results do -- 889
			local row = results[i + 1] -- 890
			local file = row.file -- 891
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 892
			local bucket = grouped:get(key) -- 893
			if not bucket then -- 893
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 895
				grouped:set(key, bucket) -- 896
				order[#order + 1] = key -- 897
			end -- 897
			bucket.totalMatches = bucket.totalMatches + 1 -- 899
			local ____bucket_matches_6 = bucket.matches -- 899
			____bucket_matches_6[#____bucket_matches_6 + 1] = results[i + 1] -- 900
			i = i + 1 -- 889
		end -- 889
	end -- 889
	local out = {} -- 902
	do -- 902
		local i = 0 -- 907
		while i < #order do -- 907
			local bucket = grouped:get(order[i + 1]) -- 908
			if bucket then -- 908
				out[#out + 1] = bucket -- 909
			end -- 909
			i = i + 1 -- 907
		end -- 907
	end -- 907
	return out -- 911
end -- 878
local function mergeDoraAPISearchHitsUnique(resultsList) -- 914
	local merged = {} -- 915
	local seen = __TS__New(Set) -- 916
	local index = 0 -- 917
	local advanced = true -- 918
	while advanced do -- 918
		advanced = false -- 920
		do -- 920
			local i = 0 -- 921
			while i < #resultsList do -- 921
				do -- 921
					local list = resultsList[i + 1] -- 922
					if index >= #list then -- 922
						goto __continue179 -- 923
					end -- 923
					advanced = true -- 924
					local row = list[index + 1] -- 925
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 926
					if seen:has(key) then -- 926
						goto __continue179 -- 927
					end -- 927
					seen:add(key) -- 928
					merged[#merged + 1] = row -- 929
				end -- 929
				::__continue179:: -- 929
				i = i + 1 -- 921
			end -- 921
		end -- 921
		index = index + 1 -- 931
	end -- 931
	return merged -- 933
end -- 914
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 936
	if docSource ~= "api" then -- 936
		return 100 -- 937
	end -- 937
	if programmingLanguage ~= "tsx" then -- 937
		return 100 -- 938
	end -- 938
	repeat -- 938
		local ____switch185 = string.lower(Path:getFilename(file)) -- 938
		local ____cond185 = ____switch185 == "jsx.d.ts" -- 938
		if ____cond185 then -- 938
			return 0 -- 940
		end -- 940
		____cond185 = ____cond185 or ____switch185 == "dorax.d.ts" -- 940
		if ____cond185 then -- 940
			return 1 -- 941
		end -- 941
		____cond185 = ____cond185 or ____switch185 == "dora.d.ts" -- 941
		if ____cond185 then -- 941
			return 2 -- 942
		end -- 942
		do -- 942
			return 100 -- 943
		end -- 943
	until true -- 943
end -- 936
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 947
	local sorted = __TS__ArraySlice(hits) -- 952
	__TS__ArraySort( -- 953
		sorted, -- 953
		function(____, a, b) -- 953
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 954
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 955
			if pa ~= pb then -- 955
				return pa - pb -- 956
			end -- 956
			local fa = string.lower(a.file) -- 957
			local fb = string.lower(b.file) -- 958
			if fa ~= fb then -- 958
				return fa < fb and -1 or 1 -- 959
			end -- 959
			return (a.line or 0) - (b.line or 0) -- 960
		end -- 953
	) -- 953
	return sorted -- 962
end -- 947
function ____exports.searchFiles(req) -- 965
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 965
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 978
		if not resolvedPath then -- 978
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 978
		end -- 978
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 982
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 983
		if not searchRoot then -- 983
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 983
		end -- 983
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 983
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 983
		end -- 983
		local patterns = splitSearchPatterns(req.pattern) -- 990
		if #patterns == 0 then -- 990
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 990
		end -- 990
		return ____awaiter_resolve( -- 990
			nil, -- 990
			__TS__New( -- 994
				__TS__Promise, -- 994
				function(____, resolve) -- 994
					Director.systemScheduler:schedule(once(function() -- 995
						do -- 995
							local function ____catch(e) -- 995
								resolve( -- 1037
									nil, -- 1037
									{ -- 1037
										success = false, -- 1037
										message = tostring(e) -- 1037
									} -- 1037
								) -- 1037
							end -- 1037
							local ____try, ____hasReturned = pcall(function() -- 1037
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 997
								local allResults = {} -- 1000
								do -- 1000
									local i = 0 -- 1001
									while i < #patterns do -- 1001
										local ____Content_11 = Content -- 1002
										local ____Content_searchFilesAsync_12 = Content.searchFilesAsync -- 1002
										local ____patterns_index_10 = patterns[i + 1] -- 1007
										local ____req_useRegex_7 = req.useRegex -- 1008
										if ____req_useRegex_7 == nil then -- 1008
											____req_useRegex_7 = false -- 1008
										end -- 1008
										local ____req_caseSensitive_8 = req.caseSensitive -- 1009
										if ____req_caseSensitive_8 == nil then -- 1009
											____req_caseSensitive_8 = false -- 1009
										end -- 1009
										local ____req_includeContent_9 = req.includeContent -- 1010
										if ____req_includeContent_9 == nil then -- 1010
											____req_includeContent_9 = true -- 1010
										end -- 1010
										allResults[#allResults + 1] = ____Content_searchFilesAsync_12( -- 1002
											____Content_11, -- 1002
											searchRoot, -- 1003
											codeExtensions, -- 1004
											extensionLevels, -- 1005
											searchGlobs, -- 1006
											____patterns_index_10, -- 1007
											____req_useRegex_7, -- 1008
											____req_caseSensitive_8, -- 1009
											____req_includeContent_9, -- 1010
											req.contentWindow or 120 -- 1011
										) -- 1011
										i = i + 1 -- 1001
									end -- 1001
								end -- 1001
								local results = mergeSearchFileResultsUnique(allResults) -- 1014
								local totalResults = #results -- 1015
								local limit = math.max( -- 1016
									1, -- 1016
									math.floor(req.limit or 20) -- 1016
								) -- 1016
								local offset = math.max( -- 1017
									0, -- 1017
									math.floor(req.offset or 0) -- 1017
								) -- 1017
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1018
								local nextOffset = offset + #paged -- 1019
								local hasMore = nextOffset < totalResults -- 1020
								local truncated = offset > 0 or hasMore -- 1021
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1022
								local groupByFile = req.groupByFile == true -- 1023
								resolve( -- 1024
									nil, -- 1024
									{ -- 1024
										success = true, -- 1025
										results = relativeResults, -- 1026
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1027
										totalResults = totalResults, -- 1028
										truncated = truncated, -- 1029
										limit = limit, -- 1030
										offset = offset, -- 1031
										nextOffset = nextOffset, -- 1032
										hasMore = hasMore, -- 1033
										groupByFile = groupByFile -- 1034
									} -- 1034
								) -- 1034
							end) -- 1034
							if not ____try then -- 1034
								____catch(____hasReturned) -- 1034
							end -- 1034
						end -- 1034
					end)) -- 995
				end -- 994
			) -- 994
		) -- 994
	end) -- 994
end -- 965
function ____exports.searchDoraAPI(req) -- 1043
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1043
		local pattern = __TS__StringTrim(req.pattern or "") -- 1054
		if pattern == "" then -- 1054
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1054
		end -- 1054
		local patterns = splitSearchPatterns(pattern) -- 1056
		if #patterns == 0 then -- 1056
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1056
		end -- 1056
		local docSource = req.docSource or "api" -- 1058
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1059
		local docRoot = target.root -- 1060
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1061
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1061
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1061
		end -- 1061
		local exts = target.exts -- 1065
		local dotExts = __TS__ArrayMap( -- 1066
			exts, -- 1066
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1066
		) -- 1066
		local globs = target.globs -- 1067
		local limit = math.max( -- 1068
			1, -- 1068
			math.floor(req.limit or 10) -- 1068
		) -- 1068
		return ____awaiter_resolve( -- 1068
			nil, -- 1068
			__TS__New( -- 1070
				__TS__Promise, -- 1070
				function(____, resolve) -- 1070
					Director.systemScheduler:schedule(once(function() -- 1071
						do -- 1071
							local function ____catch(e) -- 1071
								resolve( -- 1112
									nil, -- 1112
									{ -- 1112
										success = false, -- 1112
										message = tostring(e) -- 1112
									} -- 1112
								) -- 1112
							end -- 1112
							local ____try, ____hasReturned = pcall(function() -- 1112
								local allHits = {} -- 1073
								do -- 1073
									local p = 0 -- 1074
									while p < #patterns do -- 1074
										local ____Content_17 = Content -- 1075
										local ____Content_searchFilesAsync_18 = Content.searchFilesAsync -- 1075
										local ____array_16 = __TS__SparseArrayNew( -- 1075
											docRoot, -- 1076
											dotExts, -- 1077
											{}, -- 1078
											ensureSafeSearchGlobs(globs), -- 1079
											patterns[p + 1] -- 1080
										) -- 1080
										local ____req_useRegex_13 = req.useRegex -- 1081
										if ____req_useRegex_13 == nil then -- 1081
											____req_useRegex_13 = false -- 1081
										end -- 1081
										__TS__SparseArrayPush(____array_16, ____req_useRegex_13) -- 1081
										local ____req_caseSensitive_14 = req.caseSensitive -- 1082
										if ____req_caseSensitive_14 == nil then -- 1082
											____req_caseSensitive_14 = false -- 1082
										end -- 1082
										__TS__SparseArrayPush(____array_16, ____req_caseSensitive_14) -- 1082
										local ____req_includeContent_15 = req.includeContent -- 1083
										if ____req_includeContent_15 == nil then -- 1083
											____req_includeContent_15 = true -- 1083
										end -- 1083
										__TS__SparseArrayPush(____array_16, ____req_includeContent_15, req.contentWindow or 80) -- 1083
										local raw = ____Content_searchFilesAsync_18( -- 1075
											____Content_17, -- 1075
											__TS__SparseArraySpread(____array_16) -- 1075
										) -- 1075
										local hits = {} -- 1086
										do -- 1086
											local i = 0 -- 1087
											while i < #raw do -- 1087
												do -- 1087
													local row = raw[i + 1] -- 1088
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1089
													if file == "" then -- 1089
														goto __continue212 -- 1090
													end -- 1090
													hits[#hits + 1] = { -- 1091
														file = file, -- 1092
														line = type(row.line) == "number" and row.line or nil, -- 1093
														content = type(row.content) == "string" and row.content or nil -- 1094
													} -- 1094
												end -- 1094
												::__continue212:: -- 1094
												i = i + 1 -- 1087
											end -- 1087
										end -- 1087
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1097
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1097
											0, -- 1097
											limit -- 1097
										) -- 1097
										p = p + 1 -- 1074
									end -- 1074
								end -- 1074
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1099
								resolve(nil, { -- 1100
									success = true, -- 1101
									docSource = docSource, -- 1102
									docLanguage = req.docLanguage, -- 1103
									programmingLanguage = req.programmingLanguage, -- 1104
									exts = exts, -- 1105
									results = hits, -- 1106
									totalResults = #hits, -- 1107
									truncated = false, -- 1108
									limit = limit -- 1109
								}) -- 1109
							end) -- 1109
							if not ____try then -- 1109
								____catch(____hasReturned) -- 1109
							end -- 1109
						end -- 1109
					end)) -- 1071
				end -- 1070
			) -- 1070
		) -- 1070
	end) -- 1070
end -- 1043
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1118
	if options == nil then -- 1118
		options = {} -- 1118
	end -- 1118
	if #changes == 0 then -- 1118
		return {success = false, message = "empty changes"} -- 1120
	end -- 1120
	if not isValidWorkDir(workDir) then -- 1120
		return {success = false, message = "invalid workDir"} -- 1123
	end -- 1123
	if not getTaskStatus(taskId) then -- 1123
		return {success = false, message = "task not found"} -- 1126
	end -- 1126
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1128
	local dup = rejectDuplicatePaths(expandedChanges) -- 1129
	if dup then -- 1129
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1131
	end -- 1131
	for ____, change in ipairs(expandedChanges) do -- 1134
		if not isValidWorkspacePath(change.path) then -- 1134
			return {success = false, message = "invalid path: " .. change.path} -- 1136
		end -- 1136
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1136
			return {success = false, message = "missing content for " .. change.path} -- 1139
		end -- 1139
	end -- 1139
	local headSeq = getTaskHeadSeq(taskId) -- 1143
	if headSeq == nil then -- 1143
		return {success = false, message = "task not found"} -- 1144
	end -- 1144
	local nextSeq = headSeq + 1 -- 1145
	local checkpointId = insertCheckpoint( -- 1146
		taskId, -- 1146
		nextSeq, -- 1146
		options.summary or "", -- 1146
		options.toolName or "", -- 1146
		"PREPARED" -- 1146
	) -- 1146
	if checkpointId <= 0 then -- 1146
		return {success = false, message = "failed to create checkpoint"} -- 1148
	end -- 1148
	do -- 1148
		local i = 0 -- 1151
		while i < #expandedChanges do -- 1151
			local change = expandedChanges[i + 1] -- 1152
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1153
			if not fullPath then -- 1153
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1155
				return {success = false, message = "invalid path: " .. change.path} -- 1156
			end -- 1156
			local before = getFileState(fullPath) -- 1158
			local afterExists = change.op ~= "delete" -- 1159
			local afterContent = afterExists and (change.content or "") or "" -- 1160
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1161
				checkpointId, -- 1165
				i + 1, -- 1166
				change.path, -- 1167
				change.op, -- 1168
				before.exists and 1 or 0, -- 1169
				before.content, -- 1170
				afterExists and 1 or 0, -- 1171
				afterContent, -- 1172
				before.bytes, -- 1173
				#afterContent -- 1174
			}) -- 1174
			if inserted <= 0 then -- 1174
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1178
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1179
			end -- 1179
			i = i + 1 -- 1151
		end -- 1151
	end -- 1151
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1183
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1184
		if not fullPath then -- 1184
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1186
			return {success = false, message = "invalid path: " .. entry.path} -- 1187
		end -- 1187
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1189
		if not ok then -- 1189
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1191
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1192
		end -- 1192
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1192
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1195
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1196
		end -- 1196
	end -- 1196
	DB:exec( -- 1200
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1200
		{ -- 1202
			"APPLIED", -- 1202
			now(), -- 1202
			checkpointId -- 1202
		} -- 1202
	) -- 1202
	DB:exec( -- 1204
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1204
		{ -- 1206
			nextSeq, -- 1206
			now(), -- 1206
			taskId -- 1206
		} -- 1206
	) -- 1206
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1208
end -- 1118
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1216
	if not isValidWorkDir(workDir) then -- 1216
		return {success = false, message = "invalid workDir"} -- 1217
	end -- 1217
	if checkpointId <= 0 then -- 1217
		return {success = false, message = "invalid checkpointId"} -- 1218
	end -- 1218
	local entries = getCheckpointEntries(checkpointId, true) -- 1219
	if #entries == 0 then -- 1219
		return {success = false, message = "checkpoint not found or empty"} -- 1221
	end -- 1221
	for ____, entry in ipairs(entries) do -- 1223
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1224
		if not fullPath then -- 1224
			return {success = false, message = "invalid path: " .. entry.path} -- 1226
		end -- 1226
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1228
		if not ok then -- 1228
			Log( -- 1230
				"Error", -- 1230
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1230
			) -- 1230
			Log( -- 1231
				"Info", -- 1231
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1231
			) -- 1231
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1232
		end -- 1232
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1232
			Log( -- 1235
				"Error", -- 1235
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1235
			) -- 1235
			Log( -- 1236
				"Info", -- 1236
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1236
			) -- 1236
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1237
		end -- 1237
	end -- 1237
	return {success = true, checkpointId = checkpointId} -- 1240
end -- 1216
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1243
	return getCheckpointEntries(checkpointId, false) -- 1244
end -- 1243
function ____exports.getCheckpointDiff(checkpointId) -- 1247
	if checkpointId <= 0 then -- 1247
		return {success = false, message = "invalid checkpointId"} -- 1249
	end -- 1249
	local entries = getCheckpointEntries(checkpointId, false) -- 1251
	if #entries == 0 then -- 1251
		return {success = false, message = "checkpoint not found or empty"} -- 1253
	end -- 1253
	return { -- 1255
		success = true, -- 1256
		files = __TS__ArrayMap( -- 1257
			entries, -- 1257
			function(____, entry) return { -- 1257
				path = entry.path, -- 1258
				op = entry.op, -- 1259
				beforeExists = entry.beforeExists, -- 1260
				afterExists = entry.afterExists, -- 1261
				beforeContent = entry.beforeContent, -- 1262
				afterContent = entry.afterContent -- 1263
			} end -- 1263
		) -- 1263
	} -- 1263
end -- 1247
function ____exports.build(req) -- 1268
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1268
		local targetRel = req.path or "" -- 1269
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1270
		if not target then -- 1270
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1270
		end -- 1270
		if not Content:exist(target) then -- 1270
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1270
		end -- 1270
		local messages = {} -- 1277
		if not Content:isdir(target) then -- 1277
			local kind = getSupportedBuildKind(target) -- 1279
			if not kind then -- 1279
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1279
			end -- 1279
			if kind == "ts" then -- 1279
				local content = Content:load(target) -- 1284
				if content == nil then -- 1284
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1284
				end -- 1284
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1284
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1284
				end -- 1284
				if not isDtsFile(target) then -- 1284
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1292
				end -- 1292
			else -- 1292
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1295
			end -- 1295
			Log( -- 1297
				"Info", -- 1297
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1297
			) -- 1297
			return ____awaiter_resolve( -- 1297
				nil, -- 1297
				{ -- 1298
					success = true, -- 1299
					messages = __TS__ArrayMap( -- 1300
						messages, -- 1300
						function(____, m) return m.success and __TS__ObjectAssign( -- 1300
							{}, -- 1301
							m, -- 1301
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1301
						) or __TS__ObjectAssign( -- 1301
							{}, -- 1302
							m, -- 1302
							{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1302
						) end -- 1302
					) -- 1302
				} -- 1302
			) -- 1302
		end -- 1302
		local listResult = ____exports.listFiles({ -- 1305
			workDir = req.workDir, -- 1306
			path = targetRel, -- 1307
			globs = __TS__ArrayMap( -- 1308
				codeExtensions, -- 1308
				function(____, e) return "**/*" .. e end -- 1308
			), -- 1308
			maxEntries = 10000 -- 1309
		}) -- 1309
		local relFiles = listResult.success and listResult.files or ({}) -- 1312
		local tsFileData = {} -- 1313
		local buildQueue = {} -- 1314
		for ____, rel in ipairs(relFiles) do -- 1315
			do -- 1315
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1316
				local kind = getSupportedBuildKind(file) -- 1317
				if not kind then -- 1317
					goto __continue261 -- 1318
				end -- 1318
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1319
				if kind ~= "ts" then -- 1319
					goto __continue261 -- 1321
				end -- 1321
				local content = Content:load(file) -- 1323
				if content == nil then -- 1323
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1325
					goto __continue261 -- 1326
				end -- 1326
				tsFileData[file] = content -- 1328
				if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1328
					messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1330
					goto __continue261 -- 1331
				end -- 1331
			end -- 1331
			::__continue261:: -- 1331
		end -- 1331
		do -- 1331
			local i = 0 -- 1334
			while i < #buildQueue do -- 1334
				do -- 1334
					local ____buildQueue_index_19 = buildQueue[i + 1] -- 1335
					local file = ____buildQueue_index_19.file -- 1335
					local kind = ____buildQueue_index_19.kind -- 1335
					if kind == "ts" then -- 1335
						local content = tsFileData[file] -- 1337
						if content == nil or isDtsFile(file) then -- 1337
							goto __continue268 -- 1339
						end -- 1339
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1341
						goto __continue268 -- 1342
					end -- 1342
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1344
				end -- 1344
				::__continue268:: -- 1344
				i = i + 1 -- 1334
			end -- 1334
		end -- 1334
		if #messages == 0 then -- 1334
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 1347
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 1347
		end -- 1347
		Log( -- 1350
			"Info", -- 1350
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1350
		) -- 1350
		return ____awaiter_resolve( -- 1350
			nil, -- 1350
			{ -- 1351
				success = true, -- 1352
				messages = __TS__ArrayMap( -- 1353
					messages, -- 1353
					function(____, m) return m.success and __TS__ObjectAssign( -- 1353
						{}, -- 1354
						m, -- 1354
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1354
					) or __TS__ObjectAssign( -- 1354
						{}, -- 1355
						m, -- 1355
						{file = toWorkspaceRelativePath(req.workDir, m.file)} -- 1355
					) end -- 1355
				) -- 1355
			} -- 1355
		) -- 1355
	end) -- 1355
end -- 1268
return ____exports -- 1268