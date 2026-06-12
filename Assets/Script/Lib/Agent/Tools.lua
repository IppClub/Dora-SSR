-- [ts]: Tools.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Set = ____lualib.Set -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local Map = ____lualib.Map -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local getEngineLogText, ensureSafeSearchGlobs, ENGINE_LOG_DOWNLOAD_DIR, ENGINE_LOG_FILE, extensionLevels -- 1
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
local HttpClient = ____Dora.HttpClient -- 2
local Git = ____Dora.Git -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
local safeJsonDecode = ____Utils.safeJsonDecode -- 3
local safeJsonEncode = ____Utils.safeJsonEncode -- 3
function getEngineLogText() -- 1165
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 1166
	if not Content:exist(folder) then -- 1166
		Content:mkdir(folder) -- 1168
	end -- 1168
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 1170
	if not App:saveLog(logPath) then -- 1170
		return nil -- 1172
	end -- 1172
	return Content:load(logPath) -- 1174
end -- 1174
function ensureSafeSearchGlobs(globs) -- 1314
	local result = {} -- 1315
	do -- 1315
		local i = 0 -- 1316
		while i < #globs do -- 1316
			result[#result + 1] = globs[i + 1] -- 1317
			i = i + 1 -- 1316
		end -- 1316
	end -- 1316
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1319
	do -- 1319
		local i = 0 -- 1320
		while i < #requiredExcludes do -- 1320
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1320
				result[#result + 1] = requiredExcludes[i + 1] -- 1322
			end -- 1322
			i = i + 1 -- 1320
		end -- 1320
	end -- 1320
	return result -- 1325
end -- 1325
local TABLE_TASK = "AgentTask" -- 268
local TABLE_CP = "AgentCheckpoint" -- 269
local TABLE_ENTRY = "AgentCheckpointEntry" -- 270
ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 271
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 272
local AGENT_DOWNLOAD_TEMP_DIR = "agent" -- 273
local function now() -- 274
	return os.time() -- 274
end -- 274
local function toBool(v) -- 276
	return v ~= 0 and v ~= false and v ~= nil -- 277
end -- 276
local function toStr(v) -- 280
	if v == false or v == nil then -- 280
		return "" -- 281
	end -- 281
	return tostring(v) -- 282
end -- 280
local function isValidWorkspacePath(path) -- 285
	if not path or #path == 0 then -- 285
		return false -- 286
	end -- 286
	if Content:isAbsolutePath(path) then -- 286
		return false -- 287
	end -- 287
	if __TS__StringIncludes(path, "..") then -- 287
		return false -- 288
	end -- 288
	return true -- 289
end -- 285
local function isValidWorkDir(workDir) -- 292
	if not workDir or #workDir == 0 then -- 292
		return false -- 293
	end -- 293
	if not Content:isAbsolutePath(workDir) then -- 293
		return false -- 294
	end -- 294
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 294
		return false -- 295
	end -- 295
	return true -- 296
end -- 292
local function isValidSearchPath(path) -- 299
	if path == "" then -- 299
		return true -- 300
	end -- 300
	if Content:isAbsolutePath(path) then -- 300
		return false -- 301
	end -- 301
	if not path or #path == 0 then -- 301
		return false -- 302
	end -- 302
	if __TS__StringIncludes(path, "..") then -- 302
		return false -- 303
	end -- 303
	return true -- 304
end -- 299
local function resolveWorkspaceFilePath(workDir, path) -- 307
	if not isValidWorkDir(workDir) then -- 307
		return nil -- 308
	end -- 308
	if not isValidWorkspacePath(path) then -- 308
		return nil -- 309
	end -- 309
	return Path(workDir, path) -- 310
end -- 307
local function resolveWorkspaceSearchPath(workDir, path) -- 313
	if not isValidWorkDir(workDir) then -- 313
		return nil -- 314
	end -- 314
	if not isValidSearchPath(path) then -- 314
		return nil -- 315
	end -- 315
	return path == "" and workDir or Path(workDir, path) -- 316
end -- 313
local function toWorkspaceRelativePath(workDir, path) -- 319
	if not path or #path == 0 then -- 319
		return path -- 320
	end -- 320
	if not Content:isAbsolutePath(path) then -- 320
		return path -- 321
	end -- 321
	return Path:getRelative(path, workDir) -- 322
end -- 319
local function toWorkspaceRelativeFileList(workDir, files) -- 325
	return __TS__ArrayMap( -- 326
		files, -- 326
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 326
	) -- 326
end -- 325
local function toWorkspaceRelativeSearchResults(workDir, results) -- 329
	local mapped = {} -- 330
	do -- 330
		local i = 0 -- 331
		while i < #results do -- 331
			local row = results[i + 1] -- 332
			local clone = __TS__ObjectAssign({}, row) -- 333
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 334
			mapped[#mapped + 1] = clone -- 335
			i = i + 1 -- 331
		end -- 331
	end -- 331
	return mapped -- 337
end -- 329
local function getDoraAPIDocRoot(docLanguage) -- 340
	local zhDir = Path( -- 341
		Content.assetPath, -- 341
		"Script", -- 341
		"Lib", -- 341
		"Dora", -- 341
		"zh-Hans" -- 341
	) -- 341
	local enDir = Path( -- 342
		Content.assetPath, -- 342
		"Script", -- 342
		"Lib", -- 342
		"Dora", -- 342
		"en" -- 342
	) -- 342
	return docLanguage == "zh" and zhDir or enDir -- 343
end -- 340
local function getDoraTutorialDocRoot(docLanguage) -- 346
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 347
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 348
	return docLanguage == "zh" and zhDir or enDir -- 349
end -- 346
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 352
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 352
		return {"ts"} -- 354
	end -- 354
	return {"tl"} -- 356
end -- 352
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 359
	repeat -- 359
		local ____switch38 = programmingLanguage -- 359
		local ____cond38 = ____switch38 == "teal" -- 359
		if ____cond38 then -- 359
			return "tl" -- 361
		end -- 361
		____cond38 = ____cond38 or ____switch38 == "tl" -- 361
		if ____cond38 then -- 361
			return "tl" -- 362
		end -- 362
		do -- 362
			return programmingLanguage -- 363
		end -- 363
	until true -- 363
end -- 359
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 367
	if docSource == "tutorial" then -- 367
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 373
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 374
		return { -- 375
			root = Path(tutorialRoot, langDir), -- 376
			exts = {"md"}, -- 377
			globs = {"**/*.md"} -- 378
		} -- 378
	end -- 378
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 381
	return { -- 382
		root = getDoraAPIDocRoot(docLanguage), -- 383
		exts = exts, -- 384
		globs = __TS__ArrayMap( -- 385
			exts, -- 385
			function(____, ext) return "**/*." .. ext end -- 385
		) -- 385
	} -- 385
end -- 367
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 389
	if docSource == "tutorial" then -- 389
		return getDoraTutorialDocRoot(docLanguage) -- 391
	end -- 391
	return getDoraAPIDocRoot(docLanguage) -- 393
end -- 389
local function toDocRelativePath(baseRoot, path) -- 396
	if not path or #path == 0 then -- 396
		return path -- 397
	end -- 397
	if not Content:isAbsolutePath(path) then -- 397
		return path -- 398
	end -- 398
	return Path:getRelative(path, baseRoot) -- 399
end -- 396
local function resolveAgentTutorialDocFilePath(path, docLanguage) -- 402
	if not docLanguage then -- 402
		return nil -- 403
	end -- 403
	if not isValidWorkspacePath(path) then -- 403
		return nil -- 404
	end -- 404
	local candidate = Path( -- 405
		getDoraTutorialDocRoot(docLanguage), -- 405
		path -- 405
	) -- 405
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 405
		return candidate -- 407
	end -- 407
	return nil -- 409
end -- 402
local function ensureDirPath(dir) -- 412
	if not dir or dir == "." or dir == "" then -- 412
		return true -- 413
	end -- 413
	if Content:exist(dir) then -- 413
		return Content:isdir(dir) -- 414
	end -- 414
	local parent = Path:getPath(dir) -- 415
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 415
		if not ensureDirPath(parent) then -- 415
			return false -- 417
		end -- 417
	end -- 417
	return Content:mkdir(dir) -- 419
end -- 412
local function ensureDirForFile(path) -- 422
	local dir = Path:getPath(path) -- 423
	return ensureDirPath(dir) -- 424
end -- 422
local function isHttpUrl(url) -- 427
	local normalized = string.lower(__TS__StringTrim(url)) -- 428
	return __TS__StringStartsWith(normalized, "http://") or __TS__StringStartsWith(normalized, "https://") -- 429
end -- 427
local function createOperationId() -- 432
	local raw = (tostring(os.time()) .. "-") .. tostring(math.floor(math.random() * 1000000000)) -- 433
	local safe = string.gsub(raw, "[^%w%-_]", "-") -- 434
	return safe -- 435
end -- 432
local function getAgentDownloadTempRoot() -- 438
	return Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR, AGENT_DOWNLOAD_TEMP_DIR) -- 439
end -- 438
local function cleanupPath(path) -- 442
	if not path or path == "" or not Content:exist(path) then -- 442
		return nil -- 443
	end -- 443
	if Content:remove(path) then -- 443
		return nil -- 444
	end -- 444
	return "failed to remove temporary path: " .. path -- 445
end -- 442
local function quoteGitArg(value) -- 448
	if ({string.match(value, "^[%w%._%-%/]+$")}) ~= nil then -- 448
		return value -- 450
	end -- 450
	local escaped = string.gsub(value, "\\", "\\\\") -- 452
	escaped = string.gsub(escaped, "\"", "\\\"") -- 453
	return ("\"" .. escaped) .. "\"" -- 454
end -- 448
local function getGitHeadCommit(repoPath) -- 457
	local headPath = Path(repoPath, ".git", "HEAD") -- 458
	if not Content:exist(headPath) then -- 458
		return nil -- 459
	end -- 459
	local head = __TS__StringTrim(toStr(Content:load(headPath))) -- 460
	local ref = string.match(head, "^ref:%s*(.-)%s*$") -- 461
	if ref ~= nil and ref ~= "" then -- 461
		local refPath = Path(repoPath, ".git", ref) -- 463
		if Content:exist(refPath) then -- 463
			local commit = __TS__StringTrim(toStr(Content:load(refPath))) -- 465
			return commit ~= "" and commit or nil -- 466
		end -- 466
		return nil -- 468
	end -- 468
	return head ~= "" and head or nil -- 470
end -- 457
local function runGitAndWait(repoPath, command, onStatus, isCancelled, timeout) -- 473
	if timeout == nil then -- 473
		timeout = 600 -- 478
	end -- 478
	return __TS__New( -- 480
		__TS__Promise, -- 480
		function(____, resolve) -- 480
			local status -- 481
			local jobId = 0 -- 482
			local settled = false -- 483
			local canceled = false -- 484
			local function finish(result) -- 485
				if settled then -- 485
					return -- 486
				end -- 486
				settled = true -- 487
				resolve(nil, result) -- 488
			end -- 485
			local function finishFromStatus() -- 490
				local state = toStr(status and status.state) -- 491
				if state == "done" then -- 491
					finish({success = true, status = status}) -- 493
					return true -- 494
				end -- 494
				if state == "error" or state == "canceled" then -- 494
					local errorMessage = toStr(status and status.error) -- 497
					local statusMessage = toStr(status and status.message) -- 498
					finish({success = false, message = errorMessage ~= "" and errorMessage or (statusMessage ~= "" and statusMessage or (state == "canceled" and "git clone canceled" or "git clone failed")), status = status, interrupted = state == "canceled"}) -- 499
					return true -- 505
				end -- 505
				return false -- 507
			end -- 490
			jobId = Git:run( -- 509
				repoPath, -- 509
				command, -- 509
				function(nextStatus) -- 509
					status = nextStatus -- 510
					if onStatus then -- 510
						onStatus(status) -- 511
					end -- 511
					return finishFromStatus() -- 512
				end -- 509
			) -- 509
			if jobId == nil or jobId <= 0 then -- 509
				finish({success = false, message = "failed to start git clone"}) -- 515
				return -- 516
			end -- 516
			if not status then -- 516
				local kind = string.match(command, "^(%S+)") -- 519
				status = { -- 520
					id = jobId, -- 521
					state = "queued", -- 522
					kind = toStr(kind), -- 523
					repoPath = repoPath, -- 524
					progress = 0, -- 525
					message = "queued" -- 526
				} -- 526
			end -- 526
			if onStatus then -- 526
				onStatus(status) -- 529
			end -- 529
			local startedAt = os.time() -- 530
			local lastEmitAt = startedAt -- 531
			Director.systemScheduler:schedule(function() -- 532
				if settled then -- 532
					return true -- 533
				end -- 533
				if not canceled and isCancelled and isCancelled() then -- 533
					canceled = true -- 535
					Git:cancel(jobId) -- 536
					finish({success = false, message = "git clone canceled", status = status, interrupted = true}) -- 537
					return true -- 538
				end -- 538
				if finishFromStatus() then -- 538
					return true -- 540
				end -- 540
				local nowTime = os.time() -- 541
				if nowTime - startedAt >= timeout then -- 541
					Git:cancel(jobId) -- 543
					finish({success = false, message = "git clone timed out", status = status}) -- 544
					return true -- 545
				end -- 545
				if onStatus and status and nowTime > lastEmitAt then -- 545
					lastEmitAt = nowTime -- 548
					onStatus(status) -- 549
				end -- 549
				return false -- 551
			end) -- 532
		end -- 480
	) -- 480
end -- 473
local function downloadFile(req) -- 556
	return __TS__New( -- 563
		__TS__Promise, -- 563
		function(____, resolve) -- 563
			local requestId = 0 -- 564
			local settled = false -- 565
			local function finish(result) -- 566
				if settled then -- 566
					return -- 567
				end -- 567
				settled = true -- 568
				requestId = 0 -- 569
				resolve(nil, result) -- 570
			end -- 566
			Director.systemScheduler:schedule(function() -- 572
				if settled then -- 572
					return true -- 573
				end -- 573
				local ____this_7 -- 573
				____this_7 = req -- 574
				local ____opt_6 = ____this_7.isCancelled -- 574
				if (____opt_6 and ____opt_6(____this_7)) == true and requestId ~= 0 then -- 574
					HttpClient:cancel(requestId) -- 575
					finish({success = false, interrupted = true, message = "download canceled"}) -- 576
					return true -- 577
				end -- 577
				if requestId ~= 0 and not HttpClient:isRequestActive(requestId) then -- 577
					finish({success = false, message = "download request ended without a completion callback"}) -- 580
					return true -- 581
				end -- 581
				return false -- 583
			end) -- 572
			Director.systemScheduler:schedule(once(function() -- 585
				requestId = HttpClient:download( -- 586
					req.url, -- 586
					req.tempPath, -- 586
					req.timeout, -- 586
					function(interrupted, current, total) -- 586
						if interrupted then -- 586
							finish({success = false, interrupted = true, message = "download failed"}) -- 588
							return true -- 589
						end -- 589
						local ____this_9 -- 589
						____this_9 = req -- 591
						local ____opt_8 = ____this_9.isCancelled -- 591
						if (____opt_8 and ____opt_8(____this_9)) == true then -- 591
							finish({success = false, interrupted = true, message = "download canceled"}) -- 592
							return true -- 593
						end -- 593
						if current == total then -- 593
							finish({success = true}) -- 596
							return false -- 597
						end -- 597
						req:onProgress(current, total) -- 599
						return false -- 600
					end -- 586
				) -- 586
				if requestId == 0 then -- 586
					finish({success = false, message = "failed to schedule download request"}) -- 603
				else -- 603
					local ____this_11 -- 603
					____this_11 = req -- 604
					local ____opt_10 = ____this_11.isCancelled -- 604
					if (____opt_10 and ____opt_10(____this_11)) == true then -- 604
						HttpClient:cancel(requestId) -- 605
						finish({success = false, interrupted = true, message = "download canceled"}) -- 606
					end -- 606
				end -- 606
			end)) -- 585
		end -- 563
	) -- 563
end -- 556
local function getFileState(path) -- 612
	local exists = Content:exist(path) -- 613
	if not exists then -- 613
		return {exists = false, content = "", bytes = 0} -- 615
	end -- 615
	if Content:isdir(path) then -- 615
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 622
	end -- 622
	local content = Content:load(path) -- 629
	if type(content) ~= "string" then -- 629
		return {exists = true, content = "", bytes = 0} -- 631
	end -- 631
	return {exists = true, content = content, bytes = #content} -- 637
end -- 612
local function inspectReadableFile(path) -- 644
	do -- 644
		local function ____catch(e) -- 644
			Log( -- 666
				"Warn", -- 666
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 666
			) -- 666
			return true, {success = true} -- 667
		end -- 667
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 667
			local size, isBinary = Content:getAttr(path) -- 646
			if size == nil then -- 646
				return true, {success = false, message = "failed to read file"} -- 648
			end -- 648
			if isBinary then -- 648
				return true, { -- 654
					success = false, -- 655
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 656
					size = type(size) == "number" and size or nil, -- 657
					isBinary = true -- 658
				} -- 658
			end -- 658
			return true, { -- 661
				success = true, -- 662
				size = type(size) == "number" and size or nil -- 663
			} -- 663
		end) -- 663
		if not ____try then -- 663
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 663
		end -- 663
		if ____hasReturned then -- 663
			return ____returnValue -- 645
		end -- 645
	end -- 645
end -- 644
local function isEngineLogFilePath(path) -- 671
	return path == ENGINE_LOG_FILE -- 672
end -- 671
local function readEngineLogFile(path) -- 675
	if not isEngineLogFilePath(path) then -- 675
		return nil -- 676
	end -- 676
	local content = getEngineLogText() -- 677
	if content == nil then -- 677
		return {success = false, message = "failed to read engine logs"} -- 679
	end -- 679
	return {success = true, content = content, size = #content} -- 681
end -- 675
local function queryOne(sql, args) -- 684
	local ____args_12 -- 685
	if args then -- 685
		____args_12 = DB:query(sql, args) -- 685
	else -- 685
		____args_12 = DB:query(sql) -- 685
	end -- 685
	local rows = ____args_12 -- 685
	if not rows or #rows == 0 then -- 685
		return nil -- 686
	end -- 686
	return rows[1] -- 687
end -- 684
do -- 684
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 692
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 700
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 711
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 712
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 725
end -- 725
local function isDtsFile(path) -- 728
	return Path:getExt(Path:getName(path)) == "d" -- 729
end -- 728
local function isTiledEditorContent(content) -- 732
	return __TS__StringStartsWith( -- 733
		__TS__StringTrim(content), -- 733
		"<?xml" -- 733
	) -- 733
end -- 732
local function getSupportedBuildKind(path) -- 738
	repeat -- 738
		local ____switch121 = Path:getExt(path) -- 738
		local ____cond121 = ____switch121 == "ts" or ____switch121 == "tsx" -- 738
		if ____cond121 then -- 738
			return "ts" -- 740
		end -- 740
		____cond121 = ____cond121 or ____switch121 == "xml" -- 740
		if ____cond121 then -- 740
			return "xml" -- 741
		end -- 741
		____cond121 = ____cond121 or ____switch121 == "tl" -- 741
		if ____cond121 then -- 741
			return "teal" -- 742
		end -- 742
		____cond121 = ____cond121 or ____switch121 == "lua" -- 742
		if ____cond121 then -- 742
			return "lua" -- 743
		end -- 743
		____cond121 = ____cond121 or ____switch121 == "yue" -- 743
		if ____cond121 then -- 743
			return "yue" -- 744
		end -- 744
		____cond121 = ____cond121 or ____switch121 == "yarn" -- 744
		if ____cond121 then -- 744
			return "yarn" -- 745
		end -- 745
		do -- 745
			return nil -- 746
		end -- 746
	until true -- 746
end -- 738
local function getTaskHeadSeq(taskId) -- 750
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 751
	if not row then -- 751
		return nil -- 752
	end -- 752
	return row[1] or 0 -- 753
end -- 750
local function getTaskStatus(taskId) -- 756
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 757
	if not row then -- 757
		return nil -- 758
	end -- 758
	return toStr(row[1]) -- 759
end -- 756
local function getLastInsertRowId() -- 762
	local row = queryOne("SELECT last_insert_rowid()") -- 763
	return row and (row[1] or 0) or 0 -- 764
end -- 762
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 767
	DB:exec( -- 768
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 768
		{ -- 770
			taskId, -- 770
			seq, -- 770
			status, -- 770
			summary, -- 770
			toolName, -- 770
			now() -- 770
		} -- 770
	) -- 770
	return getLastInsertRowId() -- 772
end -- 767
local function getCheckpointEntries(checkpointId, desc) -- 775
	if desc == nil then -- 775
		desc = false -- 775
	end -- 775
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 776
	if not rows then -- 776
		return {} -- 783
	end -- 783
	local result = {} -- 784
	do -- 784
		local i = 0 -- 785
		while i < #rows do -- 785
			local row = rows[i + 1] -- 786
			result[#result + 1] = { -- 787
				id = row[1], -- 788
				ord = row[2], -- 789
				path = toStr(row[3]), -- 790
				op = toStr(row[4]), -- 791
				beforeExists = toBool(row[5]), -- 792
				beforeContent = toStr(row[6]), -- 793
				afterExists = toBool(row[7]), -- 794
				afterContent = toStr(row[8]) -- 795
			} -- 795
			i = i + 1 -- 785
		end -- 785
	end -- 785
	return result -- 798
end -- 775
local function rejectDuplicatePaths(changes) -- 801
	local seen = __TS__New(Set) -- 802
	for ____, change in ipairs(changes) do -- 803
		local key = change.path -- 804
		if seen:has(key) then -- 804
			return key -- 805
		end -- 805
		seen:add(key) -- 806
	end -- 806
	return nil -- 808
end -- 801
local function getLinkedDeletePaths(workDir, path) -- 811
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 812
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 812
		return {} -- 813
	end -- 813
	local parent = Path:getPath(fullPath) -- 814
	local baseName = string.lower(Path:getName(fullPath)) -- 815
	local ext = Path:getExt(fullPath) -- 816
	local linked = {} -- 817
	for ____, file in ipairs(Content:getFiles(parent)) do -- 818
		do -- 818
			if string.lower(Path:getName(file)) ~= baseName then -- 818
				goto __continue138 -- 819
			end -- 819
			local siblingExt = Path:getExt(file) -- 820
			if siblingExt == "tl" and ext == "vs" then -- 820
				linked[#linked + 1] = toWorkspaceRelativePath( -- 822
					workDir, -- 822
					Path(parent, file) -- 822
				) -- 822
				goto __continue138 -- 823
			end -- 823
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 823
				linked[#linked + 1] = toWorkspaceRelativePath( -- 826
					workDir, -- 826
					Path(parent, file) -- 826
				) -- 826
			end -- 826
		end -- 826
		::__continue138:: -- 826
	end -- 826
	return linked -- 829
end -- 811
local function expandLinkedDeleteChanges(workDir, changes) -- 832
	local expanded = {} -- 833
	local seen = __TS__New(Set) -- 834
	do -- 834
		local i = 0 -- 835
		while i < #changes do -- 835
			do -- 835
				local change = changes[i + 1] -- 836
				if not seen:has(change.path) then -- 836
					seen:add(change.path) -- 838
					expanded[#expanded + 1] = change -- 839
				end -- 839
				if change.op ~= "delete" then -- 839
					goto __continue145 -- 841
				end -- 841
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 842
				do -- 842
					local j = 0 -- 843
					while j < #linkedPaths do -- 843
						do -- 843
							local linkedPath = linkedPaths[j + 1] -- 844
							if seen:has(linkedPath) then -- 844
								goto __continue149 -- 845
							end -- 845
							seen:add(linkedPath) -- 846
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 847
						end -- 847
						::__continue149:: -- 847
						j = j + 1 -- 843
					end -- 843
				end -- 843
			end -- 843
			::__continue145:: -- 843
			i = i + 1 -- 835
		end -- 835
	end -- 835
	return expanded -- 850
end -- 832
local function applySingleFile(path, exists, content) -- 853
	if exists then -- 853
		if not ensureDirForFile(path) then -- 853
			return false -- 855
		end -- 855
		return Content:save(path, content) -- 856
	end -- 856
	if Content:exist(path) then -- 856
		return Content:remove(path) -- 859
	end -- 859
	return true -- 861
end -- 853
local function encodeJSON(obj) -- 864
	local text = safeJsonEncode(obj) -- 865
	return text -- 866
end -- 864
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 869
	if HttpServer.wsConnectionCount == 0 then -- 869
		return true -- 871
	end -- 871
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 873
	if not payload then -- 873
		return false -- 875
	end -- 875
	emit("AppWS", "Send", payload) -- 877
	return true -- 878
end -- 869
local function syncDownloadedFileToWebIDE(file) -- 881
	local content = "" -- 882
	do -- 882
		local function ____catch(e) -- 882
			Log( -- 890
				"Warn", -- 890
				(("[fetch_url] failed to inspect downloaded file for Web IDE update file=" .. file) .. ": ") .. tostring(e) -- 890
			) -- 890
		end -- 890
		local ____try, ____hasReturned = pcall(function() -- 890
			local ____, isBinary = Content:getAttr(file) -- 884
			if not isBinary then -- 884
				local loaded = Content:load(file) -- 886
				content = type(loaded) == "string" and loaded or "" -- 887
			end -- 887
		end) -- 887
		if not ____try then -- 887
			____catch(____hasReturned) -- 887
		end -- 887
	end -- 887
	return ____exports.sendWebIDEFileUpdate(file, true, content) -- 892
end -- 881
local function runSingleNonTsBuild(file) -- 895
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 895
		return ____awaiter_resolve( -- 895
			nil, -- 895
			__TS__New( -- 896
				__TS__Promise, -- 896
				function(____, resolve) -- 896
					local moduleName = "Script.Dev.WebServer" -- 897
					local ____require_result_13 = require(moduleName) -- 898
					local buildAsync = ____require_result_13.buildAsync -- 898
					Director.systemScheduler:schedule(once(function() -- 899
						local result = buildAsync(file) -- 900
						resolve(nil, result) -- 901
					end)) -- 899
				end -- 896
			) -- 896
		) -- 896
	end) -- 896
end -- 895
local transpileRequestSeq = 0 -- 906
function ____exports.runSingleTsTranspile(file, content) -- 908
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 908
		local done = false -- 909
		transpileRequestSeq = transpileRequestSeq + 1 -- 910
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 911
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 912
		if HttpServer.wsConnectionCount == 0 then -- 912
			return ____awaiter_resolve(nil, result) -- 912
		end -- 912
		local listener = Node() -- 920
		listener:gslot( -- 921
			"AppWS", -- 921
			function(event) -- 921
				if event.type ~= "Receive" then -- 921
					return -- 922
				end -- 922
				local res = safeJsonDecode(event.msg) -- 923
				if not res or __TS__ArrayIsArray(res) then -- 923
					return -- 924
				end -- 924
				local payload = res -- 925
				if payload.name ~= "TranspileTS" then -- 925
					return -- 926
				end -- 926
				if payload.id ~= requestId then -- 926
					return -- 927
				end -- 927
				if tostring(payload.file) ~= file then -- 927
					return -- 928
				end -- 928
				if payload.success then -- 928
					local luaFile = Path:replaceExt(file, "lua") -- 930
					if Content:save( -- 930
						luaFile, -- 931
						tostring(payload.luaCode) -- 931
					) then -- 931
						result = {success = true, file = file} -- 932
					else -- 932
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 934
					end -- 934
				else -- 934
					result = { -- 937
						success = false, -- 937
						file = file, -- 937
						message = tostring(payload.message) -- 937
					} -- 937
				end -- 937
				done = true -- 939
			end -- 921
		) -- 921
		local payload = encodeJSON({name = "TranspileTS", id = requestId, file = file, content = content}) -- 941
		if not payload then -- 941
			listener:removeFromParent() -- 948
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 948
		end -- 948
		__TS__Await(__TS__New( -- 951
			__TS__Promise, -- 951
			function(____, resolve) -- 951
				Director.systemScheduler:schedule(once(function() -- 952
					emit("AppWS", "Send", payload) -- 953
					wait(function() return done end) -- 954
					if not done then -- 954
						listener:removeFromParent() -- 956
					end -- 956
					resolve(nil) -- 958
				end)) -- 952
			end -- 951
		)) -- 951
		return ____awaiter_resolve(nil, result) -- 951
	end) -- 951
end -- 908
function ____exports.createTask(prompt) -- 964
	if prompt == nil then -- 964
		prompt = "" -- 964
	end -- 964
	local t = now() -- 965
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 966
	if affected <= 0 then -- 966
		return {success = false, message = "failed to create task"} -- 971
	end -- 971
	return { -- 973
		success = true, -- 973
		taskId = getLastInsertRowId() -- 973
	} -- 973
end -- 964
function ____exports.setTaskStatus(taskId, status) -- 976
	DB:exec( -- 977
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 977
		{ -- 977
			status, -- 977
			now(), -- 977
			taskId -- 977
		} -- 977
	) -- 977
	Log( -- 978
		"Info", -- 978
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 978
	) -- 978
end -- 976
function ____exports.listCheckpoints(taskId) -- 981
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 982
	if not rows then -- 982
		return {} -- 989
	end -- 989
	local items = {} -- 990
	do -- 990
		local i = 0 -- 991
		while i < #rows do -- 991
			local row = rows[i + 1] -- 992
			items[#items + 1] = { -- 993
				id = row[1], -- 994
				taskId = row[2], -- 995
				seq = row[3], -- 996
				status = toStr(row[4]), -- 997
				summary = toStr(row[5]), -- 998
				toolName = toStr(row[6]), -- 999
				createdAt = row[7] -- 1000
			} -- 1000
			i = i + 1 -- 991
		end -- 991
	end -- 991
	return items -- 1003
end -- 981
local function listCheckpointIdsForTask(taskId, desc) -- 1006
	if desc == nil then -- 1006
		desc = false -- 1006
	end -- 1006
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 1007
	if not rows then -- 1007
		return {} -- 1014
	end -- 1014
	local items = {} -- 1015
	do -- 1015
		local i = 0 -- 1016
		while i < #rows do -- 1016
			local row = rows[i + 1] -- 1017
			items[#items + 1] = {id = row[1], seq = row[2]} -- 1018
			i = i + 1 -- 1016
		end -- 1016
	end -- 1016
	return items -- 1023
end -- 1006
local function deriveFileOp(beforeExists, afterExists) -- 1026
	if not beforeExists and afterExists then -- 1026
		return "create" -- 1027
	end -- 1027
	if beforeExists and not afterExists then -- 1027
		return "delete" -- 1028
	end -- 1028
	return "write" -- 1029
end -- 1026
function ____exports.summarizeTaskChangeSet(taskId) -- 1032
	if not getTaskStatus(taskId) then -- 1032
		return {success = false, message = "task not found"} -- 1034
	end -- 1034
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1036
	local filesByPath = {} -- 1037
	local latestCheckpointId = nil -- 1043
	local latestCheckpointSeq = nil -- 1044
	do -- 1044
		local i = 0 -- 1045
		while i < #checkpoints do -- 1045
			local checkpoint = checkpoints[i + 1] -- 1046
			latestCheckpointId = checkpoint.id -- 1047
			latestCheckpointSeq = checkpoint.seq -- 1048
			local entries = getCheckpointEntries(checkpoint.id, false) -- 1049
			do -- 1049
				local j = 0 -- 1050
				while j < #entries do -- 1050
					local entry = entries[j + 1] -- 1051
					local item = filesByPath[entry.path] -- 1052
					if not item then -- 1052
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 1054
						filesByPath[entry.path] = item -- 1060
					end -- 1060
					item.afterExists = entry.afterExists -- 1062
					local ____item_checkpointIds_14 = item.checkpointIds -- 1062
					____item_checkpointIds_14[#____item_checkpointIds_14 + 1] = checkpoint.id -- 1063
					j = j + 1 -- 1050
				end -- 1050
			end -- 1050
			i = i + 1 -- 1045
		end -- 1045
	end -- 1045
	local files = {} -- 1066
	for ____, item in pairs(filesByPath) do -- 1067
		files[#files + 1] = { -- 1068
			path = item.path, -- 1069
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1070
			checkpointCount = #item.checkpointIds, -- 1071
			checkpointIds = item.checkpointIds -- 1072
		} -- 1072
	end -- 1072
	__TS__ArraySort( -- 1075
		files, -- 1075
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1075
	) -- 1075
	return { -- 1076
		success = true, -- 1077
		taskId = taskId, -- 1078
		checkpointCount = #checkpoints, -- 1079
		filesChanged = #files, -- 1080
		files = files, -- 1081
		latestCheckpointId = latestCheckpointId, -- 1082
		latestCheckpointSeq = latestCheckpointSeq -- 1083
	} -- 1083
end -- 1032
function ____exports.getTaskChangeSetDiff(taskId) -- 1087
	if not getTaskStatus(taskId) then -- 1087
		return {success = false, message = "task not found"} -- 1089
	end -- 1089
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1091
	if #checkpoints == 0 then -- 1091
		return {success = false, message = "change set not found or empty"} -- 1093
	end -- 1093
	local filesByPath = {} -- 1095
	do -- 1095
		local i = 0 -- 1102
		while i < #checkpoints do -- 1102
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 1103
			do -- 1103
				local j = 0 -- 1104
				while j < #entries do -- 1104
					local entry = entries[j + 1] -- 1105
					local item = filesByPath[entry.path] -- 1106
					if not item then -- 1106
						item = { -- 1108
							path = entry.path, -- 1109
							beforeExists = entry.beforeExists, -- 1110
							beforeContent = entry.beforeContent, -- 1111
							afterExists = entry.afterExists, -- 1112
							afterContent = entry.afterContent -- 1113
						} -- 1113
						filesByPath[entry.path] = item -- 1115
					end -- 1115
					item.afterExists = entry.afterExists -- 1117
					item.afterContent = entry.afterContent -- 1118
					j = j + 1 -- 1104
				end -- 1104
			end -- 1104
			i = i + 1 -- 1102
		end -- 1102
	end -- 1102
	local files = {} -- 1121
	for ____, item in pairs(filesByPath) do -- 1122
		files[#files + 1] = { -- 1123
			path = item.path, -- 1124
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1125
			beforeExists = item.beforeExists, -- 1126
			afterExists = item.afterExists, -- 1127
			beforeContent = item.beforeContent, -- 1128
			afterContent = item.afterContent -- 1129
		} -- 1129
	end -- 1129
	__TS__ArraySort( -- 1132
		files, -- 1132
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1132
	) -- 1132
	return {success = true, files = files} -- 1133
end -- 1087
local function readWorkspaceFile(workDir, path, docLanguage) -- 1136
	local engineLog = readEngineLogFile(path) -- 1137
	if engineLog then -- 1137
		return engineLog -- 1138
	end -- 1138
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1139
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 1139
		local attr = inspectReadableFile(fullPath) -- 1141
		if not attr.success then -- 1141
			return attr -- 1142
		end -- 1142
		return { -- 1143
			success = true, -- 1143
			content = Content:load(fullPath), -- 1143
			size = attr.size -- 1143
		} -- 1143
	end -- 1143
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 1145
	if docPath then -- 1145
		local attr = inspectReadableFile(docPath) -- 1147
		if not attr.success then -- 1147
			return attr -- 1148
		end -- 1148
		return { -- 1149
			success = true, -- 1149
			content = Content:load(docPath), -- 1149
			size = attr.size -- 1149
		} -- 1149
	end -- 1149
	if not fullPath then -- 1149
		return {success = false, message = "invalid path or workDir"} -- 1151
	end -- 1151
	return {success = false, message = "file not found"} -- 1152
end -- 1136
function ____exports.readFileRaw(workDir, path, docLanguage) -- 1155
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 1156
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 1156
		local attr = inspectReadableFile(path) -- 1158
		if not attr.success then -- 1158
			return attr -- 1159
		end -- 1159
		return { -- 1160
			success = true, -- 1160
			content = Content:load(path), -- 1160
			size = attr.size -- 1160
		} -- 1160
	end -- 1160
	return result -- 1162
end -- 1155
function ____exports.getLogs(req) -- 1177
	local text = getEngineLogText() -- 1178
	if text == nil then -- 1178
		return {success = false, message = "failed to read engine logs"} -- 1180
	end -- 1180
	local tailLines = math.max( -- 1182
		1, -- 1182
		math.floor(req and req.tailLines or 200) -- 1182
	) -- 1182
	local allLines = __TS__StringSplit(text, "\n") -- 1183
	local logs = __TS__ArraySlice( -- 1184
		allLines, -- 1184
		math.max(0, #allLines - tailLines) -- 1184
	) -- 1184
	return req and req.joinText and ({ -- 1185
		success = true, -- 1185
		logs = logs, -- 1185
		text = table.concat(logs, "\n") -- 1185
	}) or ({success = true, logs = logs}) -- 1185
end -- 1177
function ____exports.listFiles(req) -- 1188
	local root = req.path or "" -- 1194
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 1195
	if not searchRoot then -- 1195
		return {success = false, message = "invalid path or workDir"} -- 1197
	end -- 1197
	do -- 1197
		local function ____catch(e) -- 1197
			return true, { -- 1215
				success = false, -- 1215
				message = tostring(e) -- 1215
			} -- 1215
		end -- 1215
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1215
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 1200
			local globs = ensureSafeSearchGlobs(userGlobs) -- 1201
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 1202
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 1203
			local totalEntries = #files -- 1204
			local maxEntries = math.max( -- 1205
				1, -- 1205
				math.floor(req.maxEntries or 200) -- 1205
			) -- 1205
			local truncated = totalEntries > maxEntries -- 1206
			return true, { -- 1207
				success = true, -- 1208
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 1209
				totalEntries = totalEntries, -- 1210
				truncated = truncated, -- 1211
				maxEntries = maxEntries -- 1212
			} -- 1212
		end) -- 1212
		if not ____try then -- 1212
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1212
		end -- 1212
		if ____hasReturned then -- 1212
			return ____returnValue -- 1199
		end -- 1199
	end -- 1199
end -- 1188
local function formatReadSlice(content, startLine, endLine) -- 1219
	local lines = __TS__StringSplit(content, "\n") -- 1224
	local totalLines = #lines -- 1225
	if totalLines == 0 then -- 1225
		return { -- 1227
			success = true, -- 1228
			content = "", -- 1229
			totalLines = 0, -- 1230
			startLine = 1, -- 1231
			endLine = 0, -- 1232
			truncated = false -- 1233
		} -- 1233
	end -- 1233
	local rawStart = math.floor(startLine) -- 1236
	local rawEnd = math.floor(endLine) -- 1237
	if rawStart == 0 then -- 1237
		return {success = false, message = "startLine cannot be 0"} -- 1239
	end -- 1239
	if rawEnd == 0 then -- 1239
		return {success = false, message = "endLine cannot be 0"} -- 1242
	end -- 1242
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1244
	if start > totalLines then -- 1244
		return { -- 1248
			success = false, -- 1248
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1248
		} -- 1248
	end -- 1248
	local ____end = math.min( -- 1250
		totalLines, -- 1251
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1252
	) -- 1252
	if ____end < start then -- 1252
		return { -- 1257
			success = false, -- 1258
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1259
		} -- 1259
	end -- 1259
	local slice = {} -- 1262
	do -- 1262
		local i = start -- 1263
		while i <= ____end do -- 1263
			slice[#slice + 1] = lines[i] -- 1264
			i = i + 1 -- 1263
		end -- 1263
	end -- 1263
	local truncated = start > 1 or ____end < totalLines -- 1266
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1267
	local body = table.concat(slice, "\n") -- 1272
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1273
	return { -- 1274
		success = true, -- 1275
		content = output, -- 1276
		totalLines = totalLines, -- 1277
		startLine = start, -- 1278
		endLine = ____end, -- 1279
		truncated = truncated -- 1280
	} -- 1280
end -- 1219
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1284
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1291
	if not fallback.success or fallback.content == nil then -- 1291
		return fallback -- 1292
	end -- 1292
	local resolvedStartLine = startLine or 1 -- 1293
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1294
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1295
end -- 1284
local codeExtensions = { -- 1302
	".lua", -- 1302
	".tl", -- 1302
	".yue", -- 1302
	".ts", -- 1302
	".tsx", -- 1302
	".xml", -- 1302
	".md", -- 1302
	".yarn", -- 1302
	".wa", -- 1302
	".mod" -- 1302
} -- 1302
extensionLevels = { -- 1303
	vs = 2, -- 1304
	bl = 2, -- 1305
	ts = 1, -- 1306
	tsx = 1, -- 1307
	tl = 1, -- 1308
	yue = 1, -- 1309
	xml = 1, -- 1310
	lua = 0 -- 1311
} -- 1311
local function splitSearchPatterns(pattern) -- 1328
	local trimmed = __TS__StringTrim(pattern or "") -- 1329
	if trimmed == "" then -- 1329
		return {} -- 1330
	end -- 1330
	local out = {} -- 1331
	local seen = __TS__New(Set) -- 1332
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1333
		local p = __TS__StringTrim(tostring(p0)) -- 1334
		if p ~= "" and not seen:has(p) then -- 1334
			seen:add(p) -- 1336
			out[#out + 1] = p -- 1337
		end -- 1337
	end -- 1337
	return out -- 1340
end -- 1328
local function mergeSearchFileResultsUnique(resultsList) -- 1343
	local merged = {} -- 1344
	local seen = __TS__New(Set) -- 1345
	do -- 1345
		local i = 0 -- 1346
		while i < #resultsList do -- 1346
			local list = resultsList[i + 1] -- 1347
			do -- 1347
				local j = 0 -- 1348
				while j < #list do -- 1348
					do -- 1348
						local row = list[j + 1] -- 1349
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1350
						if seen:has(key) then -- 1350
							goto __continue259 -- 1351
						end -- 1351
						seen:add(key) -- 1352
						merged[#merged + 1] = list[j + 1] -- 1353
					end -- 1353
					::__continue259:: -- 1353
					j = j + 1 -- 1348
				end -- 1348
			end -- 1348
			i = i + 1 -- 1346
		end -- 1346
	end -- 1346
	return merged -- 1356
end -- 1343
local function buildGroupedSearchResults(results) -- 1359
	local order = {} -- 1364
	local grouped = __TS__New(Map) -- 1365
	do -- 1365
		local i = 0 -- 1370
		while i < #results do -- 1370
			local row = results[i + 1] -- 1371
			local file = row.file -- 1372
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1373
			local bucket = grouped:get(key) -- 1374
			if not bucket then -- 1374
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1376
				grouped:set(key, bucket) -- 1377
				order[#order + 1] = key -- 1378
			end -- 1378
			bucket.totalMatches = bucket.totalMatches + 1 -- 1380
			local ____bucket_matches_19 = bucket.matches -- 1380
			____bucket_matches_19[#____bucket_matches_19 + 1] = results[i + 1] -- 1381
			i = i + 1 -- 1370
		end -- 1370
	end -- 1370
	local out = {} -- 1383
	do -- 1383
		local i = 0 -- 1388
		while i < #order do -- 1388
			local bucket = grouped:get(order[i + 1]) -- 1389
			if bucket then -- 1389
				out[#out + 1] = bucket -- 1390
			end -- 1390
			i = i + 1 -- 1388
		end -- 1388
	end -- 1388
	return out -- 1392
end -- 1359
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1395
	local merged = {} -- 1396
	local seen = __TS__New(Set) -- 1397
	local index = 0 -- 1398
	local advanced = true -- 1399
	while advanced do -- 1399
		advanced = false -- 1401
		do -- 1401
			local i = 0 -- 1402
			while i < #resultsList do -- 1402
				do -- 1402
					local list = resultsList[i + 1] -- 1403
					if index >= #list then -- 1403
						goto __continue271 -- 1404
					end -- 1404
					advanced = true -- 1405
					local row = list[index + 1] -- 1406
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1407
					if seen:has(key) then -- 1407
						goto __continue271 -- 1408
					end -- 1408
					seen:add(key) -- 1409
					merged[#merged + 1] = row -- 1410
				end -- 1410
				::__continue271:: -- 1410
				i = i + 1 -- 1402
			end -- 1402
		end -- 1402
		index = index + 1 -- 1412
	end -- 1412
	return merged -- 1414
end -- 1395
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1417
	if docSource ~= "api" then -- 1417
		return 100 -- 1418
	end -- 1418
	if programmingLanguage ~= "tsx" then -- 1418
		return 100 -- 1419
	end -- 1419
	repeat -- 1419
		local ____switch277 = string.lower(Path:getFilename(file)) -- 1419
		local ____cond277 = ____switch277 == "jsx.d.ts" -- 1419
		if ____cond277 then -- 1419
			return 0 -- 1421
		end -- 1421
		____cond277 = ____cond277 or ____switch277 == "dorax.d.ts" -- 1421
		if ____cond277 then -- 1421
			return 1 -- 1422
		end -- 1422
		____cond277 = ____cond277 or ____switch277 == "dora.d.ts" -- 1422
		if ____cond277 then -- 1422
			return 2 -- 1423
		end -- 1423
		do -- 1423
			return 100 -- 1424
		end -- 1424
	until true -- 1424
end -- 1417
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1428
	local sorted = __TS__ArraySlice(hits) -- 1433
	__TS__ArraySort( -- 1434
		sorted, -- 1434
		function(____, a, b) -- 1434
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1435
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1436
			if pa ~= pb then -- 1436
				return pa - pb -- 1437
			end -- 1437
			local fa = string.lower(a.file) -- 1438
			local fb = string.lower(b.file) -- 1439
			if fa ~= fb then -- 1439
				return fa < fb and -1 or 1 -- 1440
			end -- 1440
			return (a.line or 0) - (b.line or 0) -- 1441
		end -- 1434
	) -- 1434
	return sorted -- 1443
end -- 1428
function ____exports.searchFiles(req) -- 1446
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1446
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1459
		if not resolvedPath then -- 1459
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1459
		end -- 1459
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1463
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1464
		if not searchRoot then -- 1464
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1464
		end -- 1464
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1464
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1464
		end -- 1464
		local patterns = splitSearchPatterns(req.pattern) -- 1471
		if #patterns == 0 then -- 1471
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1471
		end -- 1471
		return ____awaiter_resolve( -- 1471
			nil, -- 1471
			__TS__New( -- 1475
				__TS__Promise, -- 1475
				function(____, resolve) -- 1475
					Director.systemScheduler:schedule(once(function() -- 1476
						do -- 1476
							local function ____catch(e) -- 1476
								resolve( -- 1518
									nil, -- 1518
									{ -- 1518
										success = false, -- 1518
										message = tostring(e) -- 1518
									} -- 1518
								) -- 1518
							end -- 1518
							local ____try, ____hasReturned = pcall(function() -- 1518
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1478
								local allResults = {} -- 1481
								do -- 1481
									local i = 0 -- 1482
									while i < #patterns do -- 1482
										local ____Content_24 = Content -- 1483
										local ____Content_searchFilesAsync_25 = Content.searchFilesAsync -- 1483
										local ____patterns_index_23 = patterns[i + 1] -- 1488
										local ____req_useRegex_20 = req.useRegex -- 1489
										if ____req_useRegex_20 == nil then -- 1489
											____req_useRegex_20 = false -- 1489
										end -- 1489
										local ____req_caseSensitive_21 = req.caseSensitive -- 1490
										if ____req_caseSensitive_21 == nil then -- 1490
											____req_caseSensitive_21 = false -- 1490
										end -- 1490
										local ____req_includeContent_22 = req.includeContent -- 1491
										if ____req_includeContent_22 == nil then -- 1491
											____req_includeContent_22 = true -- 1491
										end -- 1491
										allResults[#allResults + 1] = ____Content_searchFilesAsync_25( -- 1483
											____Content_24, -- 1483
											searchRoot, -- 1484
											codeExtensions, -- 1485
											extensionLevels, -- 1486
											searchGlobs, -- 1487
											____patterns_index_23, -- 1488
											____req_useRegex_20, -- 1489
											____req_caseSensitive_21, -- 1490
											____req_includeContent_22, -- 1491
											req.contentWindow or 120 -- 1492
										) -- 1492
										i = i + 1 -- 1482
									end -- 1482
								end -- 1482
								local results = mergeSearchFileResultsUnique(allResults) -- 1495
								local totalResults = #results -- 1496
								local limit = math.max( -- 1497
									1, -- 1497
									math.floor(req.limit or 20) -- 1497
								) -- 1497
								local offset = math.max( -- 1498
									0, -- 1498
									math.floor(req.offset or 0) -- 1498
								) -- 1498
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1499
								local nextOffset = offset + #paged -- 1500
								local hasMore = nextOffset < totalResults -- 1501
								local truncated = offset > 0 or hasMore -- 1502
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1503
								local groupByFile = req.groupByFile == true -- 1504
								resolve( -- 1505
									nil, -- 1505
									{ -- 1505
										success = true, -- 1506
										results = relativeResults, -- 1507
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1508
										totalResults = totalResults, -- 1509
										truncated = truncated, -- 1510
										limit = limit, -- 1511
										offset = offset, -- 1512
										nextOffset = nextOffset, -- 1513
										hasMore = hasMore, -- 1514
										groupByFile = groupByFile -- 1515
									} -- 1515
								) -- 1515
							end) -- 1515
							if not ____try then -- 1515
								____catch(____hasReturned) -- 1515
							end -- 1515
						end -- 1515
					end)) -- 1476
				end -- 1475
			) -- 1475
		) -- 1475
	end) -- 1475
end -- 1446
function ____exports.searchDoraAPI(req) -- 1524
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1524
		local pattern = __TS__StringTrim(req.pattern or "") -- 1535
		if pattern == "" then -- 1535
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1535
		end -- 1535
		local patterns = splitSearchPatterns(pattern) -- 1537
		if #patterns == 0 then -- 1537
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1537
		end -- 1537
		local docSource = req.docSource or "api" -- 1539
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1540
		local docRoot = target.root -- 1541
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1542
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1542
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1542
		end -- 1542
		local exts = target.exts -- 1546
		local dotExts = __TS__ArrayMap( -- 1547
			exts, -- 1547
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1547
		) -- 1547
		local globs = target.globs -- 1548
		local limit = math.max( -- 1549
			1, -- 1549
			math.floor(req.limit or 10) -- 1549
		) -- 1549
		return ____awaiter_resolve( -- 1549
			nil, -- 1549
			__TS__New( -- 1551
				__TS__Promise, -- 1551
				function(____, resolve) -- 1551
					Director.systemScheduler:schedule(once(function() -- 1552
						do -- 1552
							local function ____catch(e) -- 1552
								resolve( -- 1594
									nil, -- 1594
									{ -- 1594
										success = false, -- 1594
										message = tostring(e) -- 1594
									} -- 1594
								) -- 1594
							end -- 1594
							local ____try, ____hasReturned = pcall(function() -- 1594
								local allHits = {} -- 1554
								do -- 1554
									local p = 0 -- 1555
									while p < #patterns do -- 1555
										local ____Content_30 = Content -- 1556
										local ____Content_searchFilesAsync_31 = Content.searchFilesAsync -- 1556
										local ____array_29 = __TS__SparseArrayNew( -- 1556
											docRoot, -- 1557
											dotExts, -- 1558
											{}, -- 1559
											ensureSafeSearchGlobs(globs), -- 1560
											patterns[p + 1] -- 1561
										) -- 1561
										local ____req_useRegex_26 = req.useRegex -- 1562
										if ____req_useRegex_26 == nil then -- 1562
											____req_useRegex_26 = false -- 1562
										end -- 1562
										__TS__SparseArrayPush(____array_29, ____req_useRegex_26) -- 1562
										local ____req_caseSensitive_27 = req.caseSensitive -- 1563
										if ____req_caseSensitive_27 == nil then -- 1563
											____req_caseSensitive_27 = false -- 1563
										end -- 1563
										__TS__SparseArrayPush(____array_29, ____req_caseSensitive_27) -- 1563
										local ____req_includeContent_28 = req.includeContent -- 1564
										if ____req_includeContent_28 == nil then -- 1564
											____req_includeContent_28 = true -- 1564
										end -- 1564
										__TS__SparseArrayPush(____array_29, ____req_includeContent_28, req.contentWindow or 80) -- 1564
										local raw = ____Content_searchFilesAsync_31( -- 1556
											____Content_30, -- 1556
											__TS__SparseArraySpread(____array_29) -- 1556
										) -- 1556
										local hits = {} -- 1567
										do -- 1567
											local i = 0 -- 1568
											while i < #raw do -- 1568
												do -- 1568
													local row = raw[i + 1] -- 1569
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1570
													if file == "" then -- 1570
														goto __continue304 -- 1571
													end -- 1571
													hits[#hits + 1] = { -- 1572
														file = file, -- 1573
														line = type(row.line) == "number" and row.line or nil, -- 1574
														content = type(row.content) == "string" and row.content or nil -- 1575
													} -- 1575
												end -- 1575
												::__continue304:: -- 1575
												i = i + 1 -- 1568
											end -- 1568
										end -- 1568
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1578
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1578
											0, -- 1578
											limit -- 1578
										) -- 1578
										p = p + 1 -- 1555
									end -- 1555
								end -- 1555
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1580
								resolve(nil, { -- 1581
									success = true, -- 1582
									docSource = docSource, -- 1583
									docLanguage = req.docLanguage, -- 1584
									programmingLanguage = req.programmingLanguage, -- 1585
									exts = exts, -- 1586
									results = hits, -- 1587
									hint = "Use read_file directly with the file value from a search result to view the complete document. Do not add any prefixes.", -- 1588
									totalResults = #hits, -- 1589
									truncated = false, -- 1590
									limit = limit -- 1591
								}) -- 1591
							end) -- 1591
							if not ____try then -- 1591
								____catch(____hasReturned) -- 1591
							end -- 1591
						end -- 1591
					end)) -- 1552
				end -- 1551
			) -- 1551
		) -- 1551
	end) -- 1551
end -- 1524
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1600
	if options == nil then -- 1600
		options = {} -- 1600
	end -- 1600
	if #changes == 0 then -- 1600
		return {success = false, message = "empty changes"} -- 1602
	end -- 1602
	if not isValidWorkDir(workDir) then -- 1602
		return {success = false, message = "invalid workDir"} -- 1605
	end -- 1605
	if not getTaskStatus(taskId) then -- 1605
		return {success = false, message = "task not found"} -- 1608
	end -- 1608
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1610
	local dup = rejectDuplicatePaths(expandedChanges) -- 1611
	if dup then -- 1611
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1613
	end -- 1613
	for ____, change in ipairs(expandedChanges) do -- 1616
		if not isValidWorkspacePath(change.path) then -- 1616
			return {success = false, message = "invalid path: " .. change.path} -- 1618
		end -- 1618
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1618
			return {success = false, message = "missing content for " .. change.path} -- 1621
		end -- 1621
	end -- 1621
	local headSeq = getTaskHeadSeq(taskId) -- 1625
	if headSeq == nil then -- 1625
		return {success = false, message = "task not found"} -- 1626
	end -- 1626
	local nextSeq = headSeq + 1 -- 1627
	local checkpointId = insertCheckpoint( -- 1628
		taskId, -- 1628
		nextSeq, -- 1628
		options.summary or "", -- 1628
		options.toolName or "", -- 1628
		"PREPARED" -- 1628
	) -- 1628
	if checkpointId <= 0 then -- 1628
		return {success = false, message = "failed to create checkpoint"} -- 1630
	end -- 1630
	do -- 1630
		local i = 0 -- 1633
		while i < #expandedChanges do -- 1633
			local change = expandedChanges[i + 1] -- 1634
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1635
			if not fullPath then -- 1635
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1637
				return {success = false, message = "invalid path: " .. change.path} -- 1638
			end -- 1638
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 1638
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1641
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 1642
			end -- 1642
			local before = getFileState(fullPath) -- 1644
			local afterExists = change.op ~= "delete" -- 1645
			local afterContent = afterExists and (change.content or "") or "" -- 1646
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1647
				checkpointId, -- 1651
				i + 1, -- 1652
				change.path, -- 1653
				change.op, -- 1654
				before.exists and 1 or 0, -- 1655
				before.content, -- 1656
				afterExists and 1 or 0, -- 1657
				afterContent, -- 1658
				before.bytes, -- 1659
				#afterContent -- 1660
			}) -- 1660
			if inserted <= 0 then -- 1660
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1664
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1665
			end -- 1665
			i = i + 1 -- 1633
		end -- 1633
	end -- 1633
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1669
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1670
		if not fullPath then -- 1670
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1672
			return {success = false, message = "invalid path: " .. entry.path} -- 1673
		end -- 1673
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1675
		if not ok then -- 1675
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1677
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1678
		end -- 1678
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1678
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1681
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1682
		end -- 1682
	end -- 1682
	DB:exec( -- 1686
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1686
		{ -- 1688
			"APPLIED", -- 1688
			now(), -- 1688
			checkpointId -- 1688
		} -- 1688
	) -- 1688
	DB:exec( -- 1690
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1690
		{ -- 1692
			nextSeq, -- 1692
			now(), -- 1692
			taskId -- 1692
		} -- 1692
	) -- 1692
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1694
end -- 1600
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1702
	if not isValidWorkDir(workDir) then -- 1702
		return {success = false, message = "invalid workDir"} -- 1703
	end -- 1703
	if checkpointId <= 0 then -- 1703
		return {success = false, message = "invalid checkpointId"} -- 1704
	end -- 1704
	local entries = getCheckpointEntries(checkpointId, true) -- 1705
	if #entries == 0 then -- 1705
		return {success = false, message = "checkpoint not found or empty"} -- 1707
	end -- 1707
	for ____, entry in ipairs(entries) do -- 1709
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1710
		if not fullPath then -- 1710
			return {success = false, message = "invalid path: " .. entry.path} -- 1712
		end -- 1712
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1714
		if not ok then -- 1714
			Log( -- 1716
				"Error", -- 1716
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1716
			) -- 1716
			Log( -- 1717
				"Info", -- 1717
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1717
			) -- 1717
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1718
		end -- 1718
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1718
			Log( -- 1721
				"Error", -- 1721
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1721
			) -- 1721
			Log( -- 1722
				"Info", -- 1722
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1722
			) -- 1722
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1723
		end -- 1723
	end -- 1723
	DB:exec( -- 1726
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 1726
		{ -- 1726
			"REVERTED", -- 1726
			now(), -- 1726
			checkpointId -- 1726
		} -- 1726
	) -- 1726
	return {success = true, checkpointId = checkpointId} -- 1727
end -- 1702
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 1730
	if not isValidWorkDir(workDir) then -- 1730
		return {success = false, message = "invalid workDir"} -- 1731
	end -- 1731
	if not getTaskStatus(taskId) then -- 1731
		return {success = false, message = "task not found"} -- 1732
	end -- 1732
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 1733
	if #checkpoints == 0 then -- 1733
		return {success = false, message = "change set not found or empty"} -- 1735
	end -- 1735
	local lastCheckpointId = 0 -- 1737
	do -- 1737
		local i = 0 -- 1738
		while i < #checkpoints do -- 1738
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 1739
			if not result.success then -- 1739
				return {success = false, message = result.message} -- 1740
			end -- 1740
			lastCheckpointId = checkpoints[i + 1].id -- 1741
			i = i + 1 -- 1738
		end -- 1738
	end -- 1738
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 1743
end -- 1730
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1751
	return getCheckpointEntries(checkpointId, false) -- 1752
end -- 1751
function ____exports.getCheckpointDiff(checkpointId) -- 1755
	if checkpointId <= 0 then -- 1755
		return {success = false, message = "invalid checkpointId"} -- 1757
	end -- 1757
	local entries = getCheckpointEntries(checkpointId, false) -- 1759
	if #entries == 0 then -- 1759
		return {success = false, message = "checkpoint not found or empty"} -- 1761
	end -- 1761
	return { -- 1763
		success = true, -- 1764
		files = __TS__ArrayMap( -- 1765
			entries, -- 1765
			function(____, entry) return { -- 1765
				path = entry.path, -- 1766
				op = entry.op, -- 1767
				beforeExists = entry.beforeExists, -- 1768
				afterExists = entry.afterExists, -- 1769
				beforeContent = entry.beforeContent, -- 1770
				afterContent = entry.afterContent -- 1771
			} end -- 1771
		) -- 1771
	} -- 1771
end -- 1755
local function finalizeBuildResult(workDir, messages) -- 1776
	local normalized = __TS__ArrayMap( -- 1777
		messages, -- 1777
		function(____, m) return m.success and __TS__ObjectAssign( -- 1777
			{}, -- 1778
			m, -- 1778
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1778
		) or __TS__ObjectAssign( -- 1778
			{}, -- 1779
			m, -- 1779
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1779
		) end -- 1779
	) -- 1779
	local total = #normalized -- 1780
	local failed = 0 -- 1781
	do -- 1781
		local i = 0 -- 1782
		while i < #normalized do -- 1782
			if not normalized[i + 1].success then -- 1782
				failed = failed + 1 -- 1783
			end -- 1783
			i = i + 1 -- 1782
		end -- 1782
	end -- 1782
	local passed = total - failed -- 1785
	if failed > 0 then -- 1785
		return { -- 1787
			success = false, -- 1788
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 1789
			total = total, -- 1790
			passed = passed, -- 1791
			failed = failed, -- 1792
			messages = normalized -- 1793
		} -- 1793
	end -- 1793
	return { -- 1796
		success = true, -- 1797
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 1798
		total = total, -- 1799
		passed = passed, -- 1800
		failed = 0, -- 1801
		messages = normalized -- 1802
	} -- 1802
end -- 1776
function ____exports.build(req) -- 1806
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1806
		local targetRel = req.path or "" -- 1807
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 1808
		if not target then -- 1808
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1808
		end -- 1808
		if not Content:exist(target) then -- 1808
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 1808
		end -- 1808
		local messages = {} -- 1815
		if not Content:isdir(target) then -- 1815
			local kind = getSupportedBuildKind(target) -- 1817
			if not kind then -- 1817
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 1817
			end -- 1817
			if kind == "ts" then -- 1817
				local content = Content:load(target) -- 1822
				if content == nil then -- 1822
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 1822
				end -- 1822
				if isTiledEditorContent(content) then -- 1822
					Log("Info", "[build] skip tiled editor file=" .. target) -- 1827
					return ____awaiter_resolve( -- 1827
						nil, -- 1827
						finalizeBuildResult(req.workDir, messages) -- 1828
					) -- 1828
				end -- 1828
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 1828
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 1828
				end -- 1828
				if not isDtsFile(target) then -- 1828
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 1834
				end -- 1834
			else -- 1834
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 1837
			end -- 1837
			Log( -- 1839
				"Info", -- 1839
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 1839
			) -- 1839
			return ____awaiter_resolve( -- 1839
				nil, -- 1839
				finalizeBuildResult(req.workDir, messages) -- 1840
			) -- 1840
		end -- 1840
		local listResult = ____exports.listFiles({ -- 1842
			workDir = req.workDir, -- 1843
			path = targetRel, -- 1844
			globs = __TS__ArrayMap( -- 1845
				codeExtensions, -- 1845
				function(____, e) return "**/*" .. e end -- 1845
			), -- 1845
			maxEntries = 10000 -- 1846
		}) -- 1846
		local relFiles = listResult.success and listResult.files or ({}) -- 1849
		local tsFileData = {} -- 1850
		local buildQueue = {} -- 1851
		for ____, rel in ipairs(relFiles) do -- 1852
			do -- 1852
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 1853
				local kind = getSupportedBuildKind(file) -- 1854
				if not kind then -- 1854
					goto __continue367 -- 1855
				end -- 1855
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 1856
				if kind ~= "ts" then -- 1856
					goto __continue367 -- 1858
				end -- 1858
				local content = Content:load(file) -- 1860
				if content == nil then -- 1860
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 1862
					goto __continue367 -- 1863
				end -- 1863
				if isTiledEditorContent(content) then -- 1863
					Log("Info", "[build] skip tiled editor file=" .. file) -- 1866
					goto __continue367 -- 1867
				end -- 1867
				tsFileData[file] = content -- 1869
			end -- 1869
			::__continue367:: -- 1869
		end -- 1869
		do -- 1869
			local i = 0 -- 1871
			while i < #buildQueue do -- 1871
				do -- 1871
					local ____buildQueue_index_32 = buildQueue[i + 1] -- 1872
					local file = ____buildQueue_index_32.file -- 1872
					local kind = ____buildQueue_index_32.kind -- 1872
					if kind == "ts" then -- 1872
						local content = tsFileData[file] -- 1874
						if content == nil or isDtsFile(file) then -- 1874
							goto __continue374 -- 1876
						end -- 1876
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 1876
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 1879
							goto __continue374 -- 1880
						end -- 1880
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 1882
						goto __continue374 -- 1883
					end -- 1883
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 1885
				end -- 1885
				::__continue374:: -- 1885
				i = i + 1 -- 1871
			end -- 1871
		end -- 1871
		if #messages == 0 then -- 1871
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 1888
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 1888
		end -- 1888
		Log( -- 1891
			"Info", -- 1891
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 1891
		) -- 1891
		return ____awaiter_resolve( -- 1891
			nil, -- 1891
			finalizeBuildResult(req.workDir, messages) -- 1892
		) -- 1892
	end) -- 1892
end -- 1806
function ____exports.fetchUrl(req) -- 1895
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1895
		local mode = req.mode -- 1904
		if mode ~= "download" and mode ~= "git_clone" then -- 1904
			return ____awaiter_resolve(nil, {success = false, state = "failed", message = "mode must be download or git_clone"}) -- 1904
		end -- 1904
		local url = __TS__StringTrim(req.url or "") -- 1908
		local targetRel = __TS__StringTrim(req.target or "") -- 1909
		if not isHttpUrl(url) then -- 1909
			return ____awaiter_resolve(nil, { -- 1909
				success = false, -- 1911
				state = "failed", -- 1911
				mode = mode, -- 1911
				target = targetRel, -- 1911
				message = "fetch_url only supports http:// and https:// URLs" -- 1911
			}) -- 1911
		end -- 1911
		if targetRel == "" then -- 1911
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 1911
		end -- 1911
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 1916
		if not target then -- 1916
			return ____awaiter_resolve(nil, { -- 1916
				success = false, -- 1918
				state = "failed", -- 1918
				mode = mode, -- 1918
				target = targetRel, -- 1918
				message = "invalid target path" -- 1918
			}) -- 1918
		end -- 1918
		if Content:exist(target) then -- 1918
			return ____awaiter_resolve(nil, { -- 1918
				success = false, -- 1921
				state = "failed", -- 1921
				mode = mode, -- 1921
				target = targetRel, -- 1921
				message = "target already exists" -- 1921
			}) -- 1921
		end -- 1921
		local operationId = createOperationId() -- 1923
		local tempRoot = getAgentDownloadTempRoot() -- 1924
		if not ensureDirPath(tempRoot) then -- 1924
			return ____awaiter_resolve(nil, { -- 1924
				success = false, -- 1926
				state = "failed", -- 1926
				mode = mode, -- 1926
				target = targetRel, -- 1926
				message = "failed to create agent download temp directory" -- 1926
			}) -- 1926
		end -- 1926
		local tempPath = Path(tempRoot, mode == "download" and operationId .. ".download" or operationId .. ".repo") -- 1928
		Content:remove(tempPath) -- 1929
		local function emitProgress(progress) -- 1930
			if not req.onProgress then -- 1930
				return -- 1931
			end -- 1931
			req:onProgress(__TS__ObjectAssign({ -- 1932
				state = "running", -- 1933
				mode = mode, -- 1934
				operationId = operationId, -- 1935
				target = targetRel, -- 1936
				tempPath = tempPath -- 1937
			}, progress)) -- 1937
		end -- 1930
		emitProgress({state = "pending", message = mode == "download" and "download pending" or "clone pending", stage = mode == "download" and "download" or "clone"}) -- 1941
		local function interrupted() -- 1946
			local ____this_34 -- 1946
			____this_34 = req -- 1946
			local ____opt_33 = ____this_34.isCancelled -- 1946
			return (____opt_33 and ____opt_33(____this_34)) == true -- 1946
		end -- 1946
		if mode == "download" then -- 1946
			if not ensureDirForFile(tempPath) then -- 1946
				return ____awaiter_resolve(nil, { -- 1946
					success = false, -- 1949
					state = "failed", -- 1949
					mode = mode, -- 1949
					target = targetRel, -- 1949
					message = "failed to create temporary file directory" -- 1949
				}) -- 1949
			end -- 1949
			local downloadRes = __TS__Await(downloadFile({ -- 1951
				url = url, -- 1952
				tempPath = tempPath, -- 1953
				timeout = 600, -- 1954
				isCancelled = interrupted, -- 1955
				onProgress = function(____, current, total) -- 1956
					local totalNumber = type(total) == "number" and total or 0 -- 1957
					emitProgress({ -- 1958
						stage = "download", -- 1959
						message = totalNumber > 0 and "downloading" or "downloading", -- 1960
						current = current, -- 1961
						total = total, -- 1962
						progress = totalNumber > 0 and current / totalNumber or nil -- 1963
					}) -- 1963
				end -- 1956
			})) -- 1956
			if not downloadRes.success then -- 1956
				local cleanupError = cleanupPath(tempPath) -- 1968
				return ____awaiter_resolve( -- 1968
					nil, -- 1968
					{ -- 1969
						success = false, -- 1970
						state = "failed", -- 1971
						mode = mode, -- 1972
						target = targetRel, -- 1973
						message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 1974
						interrupted = downloadRes.interrupted or interrupted(), -- 1975
						cleanupError = cleanupError -- 1976
					} -- 1976
				) -- 1976
			end -- 1976
			if not ensureDirForFile(target) then -- 1976
				local cleanupError = cleanupPath(tempPath) -- 1980
				return ____awaiter_resolve(nil, { -- 1980
					success = false, -- 1981
					state = "failed", -- 1981
					mode = mode, -- 1981
					target = targetRel, -- 1981
					message = "failed to create target directory", -- 1981
					cleanupError = cleanupError -- 1981
				}) -- 1981
			end -- 1981
			if not Content:move(tempPath, target) then -- 1981
				local cleanupError = cleanupPath(tempPath) -- 1984
				return ____awaiter_resolve(nil, { -- 1984
					success = false, -- 1985
					state = "failed", -- 1985
					mode = mode, -- 1985
					target = targetRel, -- 1985
					message = "failed to move downloaded file into target path", -- 1985
					cleanupError = cleanupError -- 1985
				}) -- 1985
			end -- 1985
			local bytesWritten -- 1987
			local ____try = __TS__AsyncAwaiter(function() -- 1987
				local size = Content:getAttr(target) -- 1989
				bytesWritten = type(size) == "number" and size or nil -- 1990
			end) -- 1990
			____try = ____try.catch( -- 1990
				____try, -- 1990
				function(____, _) -- 1990
					return __TS__AsyncAwaiter(function() -- 1990
						bytesWritten = nil -- 1992
					end) -- 1992
				end -- 1992
			) -- 1992
			__TS__Await(____try) -- 1988
			if not syncDownloadedFileToWebIDE(target) then -- 1988
				Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 1995
			end -- 1995
			return ____awaiter_resolve(nil, { -- 1995
				success = true, -- 1997
				state = "done", -- 1997
				mode = mode, -- 1997
				target = targetRel, -- 1997
				bytesWritten = bytesWritten -- 1997
			}) -- 1997
		end -- 1997
		local targetParent = Path:getPath(target) -- 1999
		if not ensureDirPath(targetParent) then -- 1999
			return ____awaiter_resolve(nil, { -- 1999
				success = false, -- 2001
				state = "failed", -- 2001
				mode = mode, -- 2001
				target = targetRel, -- 2001
				message = "failed to create target parent directory" -- 2001
			}) -- 2001
		end -- 2001
		local ref = __TS__StringTrim(req.ref or "") -- 2003
		local ____array_35 = __TS__SparseArrayNew( -- 2003
			"clone", -- 2005
			quoteGitArg(url), -- 2006
			quoteGitArg(Path:getFilename(tempPath)), -- 2007
			table.unpack(ref ~= "" and ({ -- 2008
				"-b", -- 2008
				quoteGitArg(ref) -- 2008
			}) or ({})) -- 2008
		) -- 2008
		__TS__SparseArrayPush(____array_35, "--depth", "1")
		local command = table.concat( -- 2004
			{__TS__SparseArraySpread(____array_35)}, -- 2004
			" " -- 2011
		) -- 2011
		local gitRes = __TS__Await(runGitAndWait( -- 2012
			tempRoot, -- 2013
			command, -- 2014
			function(status) -- 2015
				local progress = type(status.progress) == "number" and status.progress or nil -- 2016
				local kind = toStr(status.kind) -- 2017
				local message = toStr(status.message) -- 2018
				local state = toStr(status.state) -- 2019
				local jobId = type(status.id) == "number" and status.id or nil -- 2020
				emitProgress({ -- 2021
					stage = kind ~= "" and kind or "clone", -- 2022
					message = message ~= "" and message or (state ~= "" and state or "cloning"), -- 2023
					progress = progress, -- 2024
					jobId = jobId, -- 2025
					gitState = state ~= "" and state or nil, -- 2026
					gitKind = kind ~= "" and kind or nil -- 2027
				}) -- 2027
			end, -- 2015
			interrupted, -- 2030
			600 -- 2031
		)) -- 2031
		if not gitRes.success then -- 2031
			local cleanupError = cleanupPath(tempPath) -- 2034
			return ____awaiter_resolve( -- 2034
				nil, -- 2034
				{ -- 2035
					success = false, -- 2036
					state = "failed", -- 2037
					mode = mode, -- 2038
					target = targetRel, -- 2039
					message = gitRes.message or "git clone failed", -- 2040
					interrupted = gitRes.interrupted or interrupted(), -- 2041
					cleanupError = cleanupError -- 2042
				} -- 2042
			) -- 2042
		end -- 2042
		if not Content:move(tempPath, target) then -- 2042
			local cleanupError = cleanupPath(tempPath) -- 2046
			return ____awaiter_resolve(nil, { -- 2046
				success = false, -- 2047
				state = "failed", -- 2047
				mode = mode, -- 2047
				target = targetRel, -- 2047
				message = "failed to move cloned repository into target path", -- 2047
				cleanupError = cleanupError -- 2047
			}) -- 2047
		end -- 2047
		return ____awaiter_resolve( -- 2047
			nil, -- 2047
			{ -- 2049
				success = true, -- 2050
				state = "done", -- 2051
				mode = mode, -- 2052
				target = targetRel, -- 2053
				ref = ref ~= "" and ref or nil, -- 2054
				commit = getGitHeadCommit(target) -- 2055
			} -- 2055
		) -- 2055
	end) -- 2055
end -- 1895
return ____exports -- 1895