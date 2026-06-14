-- [ts]: Tools.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
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
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local ____exports = {} -- 1
local getEngineLogText, ensureSafeSearchGlobs, ENGINE_LOG_DOWNLOAD_DIR, ENGINE_LOG_FILE, extensionLevels -- 1
local Dora = require("Dora") -- 2
local ____Dora = require("Dora") -- 3
local Content = ____Dora.Content -- 3
local DB = ____Dora.DB -- 3
local Path = ____Dora.Path -- 3
local Director = ____Dora.Director -- 3
local once = ____Dora.once -- 3
local Node = ____Dora.Node -- 3
local emit = ____Dora.emit -- 3
local wait = ____Dora.wait -- 3
local App = ____Dora.App -- 3
local HttpServer = ____Dora.HttpServer -- 3
local HttpClient = ____Dora.HttpClient -- 3
local Git = ____Dora.Git -- 3
local ____Utils = require("Agent.Utils") -- 4
local Log = ____Utils.Log -- 4
local safeJsonDecode = ____Utils.safeJsonDecode -- 4
local safeJsonEncode = ____Utils.safeJsonEncode -- 4
function getEngineLogText() -- 1366
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 1367
	if not Content:exist(folder) then -- 1367
		Content:mkdir(folder) -- 1369
	end -- 1369
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 1371
	if not App:saveLog(logPath) then -- 1371
		return nil -- 1373
	end -- 1373
	return Content:load(logPath) -- 1375
end -- 1375
function ensureSafeSearchGlobs(globs) -- 1515
	local result = {} -- 1516
	do -- 1516
		local i = 0 -- 1517
		while i < #globs do -- 1517
			result[#result + 1] = globs[i + 1] -- 1518
			i = i + 1 -- 1517
		end -- 1517
	end -- 1517
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1520
	do -- 1520
		local i = 0 -- 1521
		while i < #requiredExcludes do -- 1521
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1521
				result[#result + 1] = requiredExcludes[i + 1] -- 1523
			end -- 1523
			i = i + 1 -- 1521
		end -- 1521
	end -- 1521
	return result -- 1526
end -- 1526
local TABLE_TASK = "AgentTask" -- 295
local TABLE_CP = "AgentCheckpoint" -- 296
local TABLE_ENTRY = "AgentCheckpointEntry" -- 297
ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 298
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 299
local AGENT_DOWNLOAD_TEMP_DIR = "agent" -- 300
local function now() -- 301
	return os.time() -- 301
end -- 301
local function toBool(v) -- 303
	return v ~= 0 and v ~= false and v ~= nil -- 304
end -- 303
local function toStr(v) -- 307
	if v == false or v == nil then -- 307
		return "" -- 308
	end -- 308
	return tostring(v) -- 309
end -- 307
local function isValidWorkspacePath(path) -- 312
	if not path or #path == 0 then -- 312
		return false -- 313
	end -- 313
	if Content:isAbsolutePath(path) then -- 313
		return false -- 314
	end -- 314
	if __TS__StringIncludes(path, "..") then -- 314
		return false -- 315
	end -- 315
	return true -- 316
end -- 312
local function isValidWorkDir(workDir) -- 319
	if not workDir or #workDir == 0 then -- 319
		return false -- 320
	end -- 320
	if not Content:isAbsolutePath(workDir) then -- 320
		return false -- 321
	end -- 321
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 321
		return false -- 322
	end -- 322
	return true -- 323
end -- 319
local function isValidSearchPath(path) -- 326
	if path == "" then -- 326
		return true -- 327
	end -- 327
	if Content:isAbsolutePath(path) then -- 327
		return false -- 328
	end -- 328
	if not path or #path == 0 then -- 328
		return false -- 329
	end -- 329
	if __TS__StringIncludes(path, "..") then -- 329
		return false -- 330
	end -- 330
	return true -- 331
end -- 326
local function resolveWorkspaceFilePath(workDir, path) -- 334
	if not isValidWorkDir(workDir) then -- 334
		return nil -- 335
	end -- 335
	if not isValidWorkspacePath(path) then -- 335
		return nil -- 336
	end -- 336
	return Path(workDir, path) -- 337
end -- 334
local function resolveWorkspaceSearchPath(workDir, path) -- 340
	if not isValidWorkDir(workDir) then -- 340
		return nil -- 341
	end -- 341
	if not isValidSearchPath(path) then -- 341
		return nil -- 342
	end -- 342
	return path == "" and workDir or Path(workDir, path) -- 343
end -- 340
local function toWorkspaceRelativePath(workDir, path) -- 346
	if not path or #path == 0 then -- 346
		return path -- 347
	end -- 347
	if not Content:isAbsolutePath(path) then -- 347
		return path -- 348
	end -- 348
	return Path:getRelative(path, workDir) -- 349
end -- 346
local function toWorkspaceRelativeFileList(workDir, files) -- 352
	return __TS__ArrayMap( -- 353
		files, -- 353
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 353
	) -- 353
end -- 352
local function toWorkspaceRelativeSearchResults(workDir, results) -- 356
	local mapped = {} -- 357
	do -- 357
		local i = 0 -- 358
		while i < #results do -- 358
			local row = results[i + 1] -- 359
			local clone = __TS__ObjectAssign({}, row) -- 360
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 361
			mapped[#mapped + 1] = clone -- 362
			i = i + 1 -- 358
		end -- 358
	end -- 358
	return mapped -- 364
end -- 356
local function getDoraAPIDocRoot(docLanguage) -- 367
	local zhDir = Path( -- 368
		Content.assetPath, -- 368
		"Script", -- 368
		"Lib", -- 368
		"Dora", -- 368
		"zh-Hans" -- 368
	) -- 368
	local enDir = Path( -- 369
		Content.assetPath, -- 369
		"Script", -- 369
		"Lib", -- 369
		"Dora", -- 369
		"en" -- 369
	) -- 369
	return docLanguage == "zh" and zhDir or enDir -- 370
end -- 367
local function getDoraTutorialDocRoot(docLanguage) -- 373
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 374
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 375
	return docLanguage == "zh" and zhDir or enDir -- 376
end -- 373
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 379
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 379
		return {"ts"} -- 381
	end -- 381
	return {"tl"} -- 383
end -- 379
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 386
	repeat -- 386
		local ____switch38 = programmingLanguage -- 386
		local ____cond38 = ____switch38 == "teal" -- 386
		if ____cond38 then -- 386
			return "tl" -- 388
		end -- 388
		____cond38 = ____cond38 or ____switch38 == "tl" -- 388
		if ____cond38 then -- 388
			return "tl" -- 389
		end -- 389
		do -- 389
			return programmingLanguage -- 390
		end -- 390
	until true -- 390
end -- 386
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 394
	if docSource == "tutorial" then -- 394
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 400
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 401
		return { -- 402
			root = Path(tutorialRoot, langDir), -- 403
			exts = {"md"}, -- 404
			globs = {"**/*.md"} -- 405
		} -- 405
	end -- 405
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 408
	return { -- 409
		root = getDoraAPIDocRoot(docLanguage), -- 410
		exts = exts, -- 411
		globs = __TS__ArrayMap( -- 412
			exts, -- 412
			function(____, ext) return "**/*." .. ext end -- 412
		) -- 412
	} -- 412
end -- 394
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 416
	if docSource == "tutorial" then -- 416
		return getDoraTutorialDocRoot(docLanguage) -- 418
	end -- 418
	return getDoraAPIDocRoot(docLanguage) -- 420
end -- 416
local function toDocRelativePath(baseRoot, path) -- 423
	if not path or #path == 0 then -- 423
		return path -- 424
	end -- 424
	if not Content:isAbsolutePath(path) then -- 424
		return path -- 425
	end -- 425
	return Path:getRelative(path, baseRoot) -- 426
end -- 423
local function resolveAgentTutorialDocFilePath(path, docLanguage) -- 429
	if not docLanguage then -- 429
		return nil -- 430
	end -- 430
	if not isValidWorkspacePath(path) then -- 430
		return nil -- 431
	end -- 431
	local candidate = Path( -- 432
		getDoraTutorialDocRoot(docLanguage), -- 432
		path -- 432
	) -- 432
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 432
		return candidate -- 434
	end -- 434
	return nil -- 436
end -- 429
local function ensureDirPath(dir) -- 439
	if not dir or dir == "." or dir == "" then -- 439
		return true -- 440
	end -- 440
	if Content:exist(dir) then -- 440
		return Content:isdir(dir) -- 441
	end -- 441
	local parent = Path:getPath(dir) -- 442
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 442
		if not ensureDirPath(parent) then -- 442
			return false -- 444
		end -- 444
	end -- 444
	return Content:mkdir(dir) -- 446
end -- 439
local function ensureDirForFile(path) -- 449
	local dir = Path:getPath(path) -- 450
	return ensureDirPath(dir) -- 451
end -- 449
local function isHttpUrl(url) -- 454
	local normalized = string.lower(__TS__StringTrim(url)) -- 455
	return __TS__StringStartsWith(normalized, "http://") or __TS__StringStartsWith(normalized, "https://") -- 456
end -- 454
local function createOperationId() -- 459
	local raw = (tostring(os.time()) .. "-") .. tostring(math.floor(math.random() * 1000000000)) -- 460
	local safe = string.gsub(raw, "[^%w%-_]", "-") -- 461
	return safe -- 462
end -- 459
local function getAgentDownloadTempRoot() -- 465
	return Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR, AGENT_DOWNLOAD_TEMP_DIR) -- 466
end -- 465
local function cleanupPath(path) -- 469
	if not path or path == "" or not Content:exist(path) then -- 469
		return nil -- 470
	end -- 470
	if Content:remove(path) then -- 470
		return nil -- 471
	end -- 471
	return "failed to remove temporary path: " .. path -- 472
end -- 469
local function quoteGitArg(value) -- 475
	if ({string.match(value, "^[%w%._%-%/]+$")}) ~= nil then -- 475
		return value -- 477
	end -- 477
	local escaped = string.gsub(value, "\\", "\\\\") -- 479
	escaped = string.gsub(escaped, "\"", "\\\"") -- 480
	return ("\"" .. escaped) .. "\"" -- 481
end -- 475
local function shellSplit(command) -- 484
	local args = {} -- 485
	local current = "" -- 486
	local quote = "" -- 487
	local escaped = false -- 488
	do -- 488
		local i = 0 -- 489
		while i < #command do -- 489
			do -- 489
				local ch = __TS__StringCharAt(command, i) -- 490
				if escaped then -- 490
					current = current .. ch -- 492
					escaped = false -- 493
					goto __continue67 -- 494
				end -- 494
				if ch == "\\" then -- 494
					escaped = true -- 497
					goto __continue67 -- 498
				end -- 498
				if quote ~= "" then -- 498
					if ch == quote then -- 498
						quote = "" -- 502
					else -- 502
						current = current .. ch -- 504
					end -- 504
					goto __continue67 -- 506
				end -- 506
				if ch == "'" or ch == "\"" then -- 506
					quote = ch -- 509
					goto __continue67 -- 510
				end -- 510
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 510
					if current ~= "" then -- 510
						args[#args + 1] = current -- 514
						current = "" -- 515
					end -- 515
					goto __continue67 -- 517
				end -- 517
				current = current .. ch -- 519
			end -- 519
			::__continue67:: -- 519
			i = i + 1 -- 489
		end -- 489
	end -- 489
	if escaped then -- 489
		current = current .. "\\" -- 522
	end -- 522
	if current ~= "" then -- 522
		args[#args + 1] = current -- 525
	end -- 525
	return args -- 527
end -- 484
local function normalizeGitCommand(command) -- 530
	local trimmed = __TS__StringTrim(command) -- 531
	if string.lower(string.sub(trimmed, 1, 4)) == "git " then -- 531
		return __TS__StringTrim(string.sub(trimmed, 5)) -- 533
	end -- 533
	return trimmed -- 535
end -- 530
local function gitDefaultTargetFromUrl(url) -- 538
	local target = url -- 539
	local hashIndex = (string.find(target, "#", nil, true) or 0) - 1 -- 540
	if hashIndex >= 0 then -- 540
		target = __TS__StringSlice(target, 0, hashIndex) -- 541
	end -- 541
	local queryIndex = (string.find(target, "?", nil, true) or 0) - 1 -- 542
	if queryIndex >= 0 then -- 542
		target = __TS__StringSlice(target, 0, queryIndex) -- 543
	end -- 543
	target = string.gsub(target, "/+$", "") -- 544
	local name = string.match(target, "([^/]+)$") -- 545
	if name ~= nil and name ~= "" then -- 545
		target = name -- 546
	end -- 546
	if __TS__StringEndsWith( -- 546
		string.lower(target), -- 547
		".git" -- 547
	) then -- 547
		target = __TS__StringSlice(target, 0, #target - 4) -- 548
	end -- 548
	return target ~= "" and target or "repo" -- 550
end -- 538
local function parseGitCloneCommand(command) -- 553
	local args = shellSplit(normalizeGitCommand(command)) -- 563
	if #args == 0 or args[1] ~= "clone" then -- 563
		return nil -- 564
	end -- 564
	local url = "" -- 565
	local target = "" -- 566
	local ref -- 567
	local depth -- 568
	do -- 568
		local i = 1 -- 569
		while i < #args do -- 569
			do -- 569
				local arg = args[i + 1] -- 570
				if arg == "-b" or arg == "--branch" then
					i = i + 1 -- 572
					if i >= #args then -- 572
						return {success = false, message = arg .. " requires a value"} -- 573
					end -- 573
					ref = args[i + 1] -- 574
					goto __continue88 -- 575
				end -- 575
				if arg == "--depth" then
					i = i + 1 -- 578
					if i >= #args then -- 578
						return {success = false, message = "--depth requires a value"}
					end -- 579
					depth = args[i + 1] -- 580
					goto __continue88 -- 581
				end -- 581
				if __TS__StringStartsWith(arg, "--depth=") then
					depth = __TS__StringSlice(arg, #"--depth=")
					goto __continue88 -- 585
				end -- 585
				if __TS__StringStartsWith(arg, "-") then -- 585
					return {success = false, message = "unsupported clone option: " .. arg} -- 588
				end -- 588
				if url == "" then -- 588
					url = arg -- 591
					goto __continue88 -- 592
				end -- 592
				if target == "" then -- 592
					target = arg -- 595
					goto __continue88 -- 596
				end -- 596
				return {success = false, message = "unexpected clone argument: " .. arg} -- 598
			end -- 598
			::__continue88:: -- 598
			i = i + 1 -- 569
		end -- 569
	end -- 569
	if url == "" then -- 569
		return {success = false, message = "git clone requires a URL"} -- 600
	end -- 600
	if not isHttpUrl(url) then -- 600
		return {success = false, message = "git clone only supports http:// and https:// URLs"} -- 601
	end -- 601
	if target == "" then -- 601
		target = gitDefaultTargetFromUrl(url) -- 602
	end -- 602
	return { -- 603
		success = true, -- 604
		url = url, -- 605
		target = target, -- 606
		ref = ref, -- 607
		depth = depth ~= nil and depth ~= "" and depth or "1" -- 608
	} -- 608
end -- 553
local function getGitHeadCommit(repoPath) -- 612
	local headPath = Path(repoPath, ".git", "HEAD") -- 613
	if not Content:exist(headPath) then -- 613
		return nil -- 614
	end -- 614
	local head = __TS__StringTrim(toStr(Content:load(headPath))) -- 615
	local ref = string.match(head, "^ref:%s*(.-)%s*$") -- 616
	if ref ~= nil and ref ~= "" then -- 616
		local refPath = Path(repoPath, ".git", ref) -- 618
		if Content:exist(refPath) then -- 618
			local commit = __TS__StringTrim(toStr(Content:load(refPath))) -- 620
			return commit ~= "" and commit or nil -- 621
		end -- 621
		return nil -- 623
	end -- 623
	return head ~= "" and head or nil -- 625
end -- 612
local function runGitAndWait(repoPath, command, onStatus, isCancelled, timeout) -- 628
	if timeout == nil then -- 628
		timeout = 600 -- 633
	end -- 633
	return __TS__New( -- 635
		__TS__Promise, -- 635
		function(____, resolve) -- 635
			local status -- 636
			local jobId = 0 -- 637
			local settled = false -- 638
			local canceled = false -- 639
			local function finish(result) -- 640
				if settled then -- 640
					return -- 641
				end -- 641
				settled = true -- 642
				resolve(nil, result) -- 643
			end -- 640
			local function finishFromStatus() -- 645
				local state = toStr(status and status.state) -- 646
				if state == "done" then -- 646
					finish({success = true, status = status}) -- 648
					return true -- 649
				end -- 649
				if state == "error" or state == "canceled" then -- 649
					local errorMessage = toStr(status and status.error) -- 652
					local statusMessage = toStr(status and status.message) -- 653
					finish({success = false, message = errorMessage ~= "" and errorMessage or (statusMessage ~= "" and statusMessage or (state == "canceled" and "git command canceled" or "git command failed")), status = status, interrupted = state == "canceled"}) -- 654
					return true -- 660
				end -- 660
				return false -- 662
			end -- 645
			jobId = Git:run( -- 664
				repoPath, -- 664
				command, -- 664
				function(nextStatus) -- 664
					status = nextStatus -- 665
					if onStatus then -- 665
						onStatus(status) -- 666
					end -- 666
					return finishFromStatus() -- 667
				end -- 664
			) -- 664
			if jobId == nil or jobId <= 0 then -- 664
				finish({success = false, message = "failed to start git command"}) -- 670
				return -- 671
			end -- 671
			if not status then -- 671
				local kind = string.match(command, "^(%S+)") -- 674
				status = { -- 675
					id = jobId, -- 676
					state = "queued", -- 677
					kind = toStr(kind), -- 678
					repoPath = repoPath, -- 679
					progress = 0, -- 680
					message = "queued" -- 681
				} -- 681
			end -- 681
			if onStatus then -- 681
				onStatus(status) -- 684
			end -- 684
			local startedAt = os.time() -- 685
			local lastEmitAt = startedAt -- 686
			Director.systemScheduler:schedule(function() -- 687
				if settled then -- 687
					return true -- 688
				end -- 688
				if not canceled and isCancelled and isCancelled() then -- 688
					canceled = true -- 690
					Git:cancel(jobId) -- 691
					finish({success = false, message = "git command canceled", status = status, interrupted = true}) -- 692
					return true -- 693
				end -- 693
				if finishFromStatus() then -- 693
					return true -- 695
				end -- 695
				local nowTime = os.time() -- 696
				if nowTime - startedAt >= timeout then -- 696
					Git:cancel(jobId) -- 698
					finish({success = false, message = "git command timed out", status = status}) -- 699
					return true -- 700
				end -- 700
				if onStatus and status and nowTime > lastEmitAt then -- 700
					lastEmitAt = nowTime -- 703
					onStatus(status) -- 704
				end -- 704
				return false -- 706
			end) -- 687
		end -- 635
	) -- 635
end -- 628
local function downloadFile(req) -- 711
	return __TS__New( -- 718
		__TS__Promise, -- 718
		function(____, resolve) -- 718
			local requestId = 0 -- 719
			local settled = false -- 720
			local bytesWritten = 0 -- 721
			local function finish(result) -- 722
				if settled then -- 722
					return -- 723
				end -- 723
				settled = true -- 724
				requestId = 0 -- 725
				resolve(nil, result) -- 726
			end -- 722
			Director.systemScheduler:schedule(function() -- 728
				if settled then -- 728
					return true -- 729
				end -- 729
				local ____this_7 -- 729
				____this_7 = req -- 730
				local ____opt_6 = ____this_7.isCancelled -- 730
				if (____opt_6 and ____opt_6(____this_7)) == true and requestId ~= 0 then -- 730
					HttpClient:cancel(requestId) -- 731
					finish({success = false, interrupted = true, message = "download canceled"}) -- 732
					return true -- 733
				end -- 733
				if requestId ~= 0 and not HttpClient:isRequestActive(requestId) then -- 733
					finish({success = false, message = "download request ended without a completion callback"}) -- 736
					return true -- 737
				end -- 737
				return false -- 739
			end) -- 728
			Director.systemScheduler:schedule(once(function() -- 741
				requestId = HttpClient:download( -- 742
					req.url, -- 742
					req.tempPath, -- 742
					req.timeout, -- 742
					function(interrupted, current, total) -- 742
						if type(current) == "number" and current > bytesWritten then -- 742
							bytesWritten = current -- 744
						end -- 744
						if interrupted then -- 744
							finish({success = false, interrupted = true, message = "download failed"}) -- 747
							return true -- 748
						end -- 748
						local ____this_9 -- 748
						____this_9 = req -- 750
						local ____opt_8 = ____this_9.isCancelled -- 750
						if (____opt_8 and ____opt_8(____this_9)) == true then -- 750
							finish({success = false, interrupted = true, message = "download canceled"}) -- 751
							return true -- 752
						end -- 752
						if current == total then -- 752
							finish({success = true, bytesWritten = bytesWritten}) -- 755
							return false -- 756
						end -- 756
						req:onProgress(current, total) -- 758
						return false -- 759
					end -- 742
				) -- 742
				if requestId == 0 then -- 742
					finish({success = false, message = "failed to schedule download request"}) -- 762
				else -- 762
					local ____this_11 -- 762
					____this_11 = req -- 763
					local ____opt_10 = ____this_11.isCancelled -- 763
					if (____opt_10 and ____opt_10(____this_11)) == true then -- 763
						HttpClient:cancel(requestId) -- 764
						finish({success = false, interrupted = true, message = "download canceled"}) -- 765
					end -- 765
				end -- 765
			end)) -- 741
		end -- 718
	) -- 718
end -- 711
local function getFileState(path) -- 771
	local exists = Content:exist(path) -- 772
	if not exists then -- 772
		return {exists = false, content = "", bytes = 0} -- 774
	end -- 774
	if Content:isdir(path) then -- 774
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 781
	end -- 781
	local content = Content:load(path) -- 788
	if type(content) ~= "string" then -- 788
		return {exists = true, content = "", bytes = 0} -- 790
	end -- 790
	return {exists = true, content = content, bytes = #content} -- 796
end -- 771
local function inspectReadableFile(path) -- 803
	do -- 803
		local function ____catch(e) -- 803
			Log( -- 825
				"Warn", -- 825
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 825
			) -- 825
			return true, {success = true} -- 826
		end -- 826
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 826
			local size, isBinary = Content:getAttr(path) -- 805
			if size == nil then -- 805
				return true, {success = false, message = "failed to read file"} -- 807
			end -- 807
			if isBinary then -- 807
				return true, { -- 813
					success = false, -- 814
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 815
					size = type(size) == "number" and size or nil, -- 816
					isBinary = true -- 817
				} -- 817
			end -- 817
			return true, { -- 820
				success = true, -- 821
				size = type(size) == "number" and size or nil -- 822
			} -- 822
		end) -- 822
		if not ____try then -- 822
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 822
		end -- 822
		if ____hasReturned then -- 822
			return ____returnValue -- 804
		end -- 804
	end -- 804
end -- 803
local function isEngineLogFilePath(path) -- 830
	return path == ENGINE_LOG_FILE -- 831
end -- 830
local function readEngineLogFile(path) -- 834
	if not isEngineLogFilePath(path) then -- 834
		return nil -- 835
	end -- 835
	local content = getEngineLogText() -- 836
	if content == nil then -- 836
		return {success = false, message = "failed to read engine logs"} -- 838
	end -- 838
	return {success = true, content = content, size = #content} -- 840
end -- 834
local function queryOne(sql, args) -- 843
	local ____args_12 -- 844
	if args then -- 844
		____args_12 = DB:query(sql, args) -- 844
	else -- 844
		____args_12 = DB:query(sql) -- 844
	end -- 844
	local rows = ____args_12 -- 844
	if not rows or #rows == 0 then -- 844
		return nil -- 845
	end -- 845
	return rows[1] -- 846
end -- 843
do -- 843
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 851
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 859
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 870
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 871
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 884
end -- 884
local function isDtsFile(path) -- 887
	return Path:getExt(Path:getName(path)) == "d" -- 888
end -- 887
local function isTiledEditorContent(content) -- 891
	return __TS__StringStartsWith( -- 892
		__TS__StringTrim(content), -- 892
		"<?xml" -- 892
	) -- 892
end -- 891
local function getSupportedBuildKind(path) -- 897
	repeat -- 897
		local ____switch157 = Path:getExt(path) -- 897
		local ____cond157 = ____switch157 == "ts" or ____switch157 == "tsx" -- 897
		if ____cond157 then -- 897
			return "ts" -- 899
		end -- 899
		____cond157 = ____cond157 or ____switch157 == "xml" -- 899
		if ____cond157 then -- 899
			return "xml" -- 900
		end -- 900
		____cond157 = ____cond157 or ____switch157 == "tl" -- 900
		if ____cond157 then -- 900
			return "teal" -- 901
		end -- 901
		____cond157 = ____cond157 or ____switch157 == "lua" -- 901
		if ____cond157 then -- 901
			return "lua" -- 902
		end -- 902
		____cond157 = ____cond157 or ____switch157 == "yue" -- 902
		if ____cond157 then -- 902
			return "yue" -- 903
		end -- 903
		____cond157 = ____cond157 or ____switch157 == "yarn" -- 903
		if ____cond157 then -- 903
			return "yarn" -- 904
		end -- 904
		do -- 904
			return nil -- 905
		end -- 905
	until true -- 905
end -- 897
local function getTaskHeadSeq(taskId) -- 909
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 910
	if not row then -- 910
		return nil -- 911
	end -- 911
	return row[1] or 0 -- 912
end -- 909
local function getTaskStatus(taskId) -- 915
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 916
	if not row then -- 916
		return nil -- 917
	end -- 917
	return toStr(row[1]) -- 918
end -- 915
local function getLastInsertRowId() -- 921
	local row = queryOne("SELECT last_insert_rowid()") -- 922
	return row and (row[1] or 0) or 0 -- 923
end -- 921
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 926
	DB:exec( -- 927
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 927
		{ -- 929
			taskId, -- 929
			seq, -- 929
			status, -- 929
			summary, -- 929
			toolName, -- 929
			now() -- 929
		} -- 929
	) -- 929
	return getLastInsertRowId() -- 931
end -- 926
local function getCheckpointEntries(checkpointId, desc) -- 934
	if desc == nil then -- 934
		desc = false -- 934
	end -- 934
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 935
	if not rows then -- 935
		return {} -- 942
	end -- 942
	local result = {} -- 943
	do -- 943
		local i = 0 -- 944
		while i < #rows do -- 944
			local row = rows[i + 1] -- 945
			result[#result + 1] = { -- 946
				id = row[1], -- 947
				ord = row[2], -- 948
				path = toStr(row[3]), -- 949
				op = toStr(row[4]), -- 950
				beforeExists = toBool(row[5]), -- 951
				beforeContent = toStr(row[6]), -- 952
				afterExists = toBool(row[7]), -- 953
				afterContent = toStr(row[8]) -- 954
			} -- 954
			i = i + 1 -- 944
		end -- 944
	end -- 944
	return result -- 957
end -- 934
local function rejectDuplicatePaths(changes) -- 960
	local seen = __TS__New(Set) -- 961
	for ____, change in ipairs(changes) do -- 962
		local key = change.path -- 963
		if seen:has(key) then -- 963
			return key -- 964
		end -- 964
		seen:add(key) -- 965
	end -- 965
	return nil -- 967
end -- 960
local function getLinkedDeletePaths(workDir, path) -- 970
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 971
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 971
		return {} -- 972
	end -- 972
	local parent = Path:getPath(fullPath) -- 973
	local baseName = string.lower(Path:getName(fullPath)) -- 974
	local ext = Path:getExt(fullPath) -- 975
	local linked = {} -- 976
	for ____, file in ipairs(Content:getFiles(parent)) do -- 977
		do -- 977
			if string.lower(Path:getName(file)) ~= baseName then -- 977
				goto __continue174 -- 978
			end -- 978
			local siblingExt = Path:getExt(file) -- 979
			if siblingExt == "tl" and ext == "vs" then -- 979
				linked[#linked + 1] = toWorkspaceRelativePath( -- 981
					workDir, -- 981
					Path(parent, file) -- 981
				) -- 981
				goto __continue174 -- 982
			end -- 982
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 982
				linked[#linked + 1] = toWorkspaceRelativePath( -- 985
					workDir, -- 985
					Path(parent, file) -- 985
				) -- 985
			end -- 985
		end -- 985
		::__continue174:: -- 985
	end -- 985
	return linked -- 988
end -- 970
local function expandLinkedDeleteChanges(workDir, changes) -- 991
	local expanded = {} -- 992
	local seen = __TS__New(Set) -- 993
	do -- 993
		local i = 0 -- 994
		while i < #changes do -- 994
			do -- 994
				local change = changes[i + 1] -- 995
				if not seen:has(change.path) then -- 995
					seen:add(change.path) -- 997
					expanded[#expanded + 1] = change -- 998
				end -- 998
				if change.op ~= "delete" then -- 998
					goto __continue181 -- 1000
				end -- 1000
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 1001
				do -- 1001
					local j = 0 -- 1002
					while j < #linkedPaths do -- 1002
						do -- 1002
							local linkedPath = linkedPaths[j + 1] -- 1003
							if seen:has(linkedPath) then -- 1003
								goto __continue185 -- 1004
							end -- 1004
							seen:add(linkedPath) -- 1005
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 1006
						end -- 1006
						::__continue185:: -- 1006
						j = j + 1 -- 1002
					end -- 1002
				end -- 1002
			end -- 1002
			::__continue181:: -- 1002
			i = i + 1 -- 994
		end -- 994
	end -- 994
	return expanded -- 1009
end -- 991
local function applySingleFile(path, exists, content) -- 1012
	if exists then -- 1012
		if not ensureDirForFile(path) then -- 1012
			return false -- 1014
		end -- 1014
		return Content:save(path, content) -- 1015
	end -- 1015
	if Content:exist(path) then -- 1015
		return Content:remove(path) -- 1018
	end -- 1018
	return true -- 1020
end -- 1012
local function encodeJSON(obj) -- 1023
	local text = safeJsonEncode(obj) -- 1024
	return text -- 1025
end -- 1023
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 1028
	if HttpServer.wsConnectionCount == 0 then -- 1028
		return true -- 1030
	end -- 1030
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 1032
	if not payload then -- 1032
		return false -- 1034
	end -- 1034
	emit("AppWS", "Send", payload) -- 1036
	return true -- 1037
end -- 1028
function ____exports.sendWebIDERefreshTree() -- 1040
	if HttpServer.wsConnectionCount == 0 then -- 1040
		return true -- 1042
	end -- 1042
	local payload = encodeJSON({name = "RefreshTree"}) -- 1044
	if not payload then -- 1044
		return false -- 1046
	end -- 1046
	emit("AppWS", "Send", payload) -- 1048
	return true -- 1049
end -- 1040
local function syncProjectFileToWebIDE(workDir, path) -- 1052
	local target = resolveWorkspaceFilePath(workDir, path) -- 1053
	if not target then -- 1053
		return false -- 1054
	end -- 1054
	if not Content:exist(target) then -- 1054
		return ____exports.sendWebIDEFileUpdate(target, false, "") -- 1056
	end -- 1056
	if Content:isdir(target) then -- 1056
		return ____exports.sendWebIDERefreshTree() -- 1059
	end -- 1059
	local content = "" -- 1061
	do -- 1061
		local function ____catch(e) -- 1061
			Log( -- 1069
				"Warn", -- 1069
				(("[Agent.Tools] failed to inspect file for Web IDE update file=" .. target) .. ": ") .. tostring(e) -- 1069
			) -- 1069
		end -- 1069
		local ____try, ____hasReturned = pcall(function() -- 1069
			local ____, isBinary = Content:getAttr(target) -- 1063
			if not isBinary then -- 1063
				local loaded = Content:load(target) -- 1065
				content = type(loaded) == "string" and loaded or "" -- 1066
			end -- 1066
		end) -- 1066
		if not ____try then -- 1066
			____catch(____hasReturned) -- 1066
		end -- 1066
	end -- 1066
	return ____exports.sendWebIDEFileUpdate(target, true, content) -- 1071
end -- 1052
local function refreshProjectTree(workDir, path) -- 1074
	local normalized = type(path) == "string" and __TS__StringTrim(path) or "" -- 1075
	if normalized == "" then -- 1075
		return ____exports.sendWebIDERefreshTree() -- 1077
	end -- 1077
	return syncProjectFileToWebIDE(workDir, normalized) -- 1079
end -- 1074
local function syncDownloadedFileToWebIDE(file) -- 1082
	local content = "" -- 1083
	do -- 1083
		local function ____catch(e) -- 1083
			Log( -- 1091
				"Warn", -- 1091
				(("[fetch_url] failed to inspect downloaded file for Web IDE update file=" .. file) .. ": ") .. tostring(e) -- 1091
			) -- 1091
		end -- 1091
		local ____try, ____hasReturned = pcall(function() -- 1091
			local ____, isBinary = Content:getAttr(file) -- 1085
			if not isBinary then -- 1085
				local loaded = Content:load(file) -- 1087
				content = type(loaded) == "string" and loaded or "" -- 1088
			end -- 1088
		end) -- 1088
		if not ____try then -- 1088
			____catch(____hasReturned) -- 1088
		end -- 1088
	end -- 1088
	return ____exports.sendWebIDEFileUpdate(file, true, content) -- 1093
end -- 1082
local function runSingleNonTsBuild(file) -- 1096
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1096
		return ____awaiter_resolve( -- 1096
			nil, -- 1096
			__TS__New( -- 1097
				__TS__Promise, -- 1097
				function(____, resolve) -- 1097
					local moduleName = "Script.Dev.WebServer" -- 1098
					local ____require_result_13 = require(moduleName) -- 1099
					local buildAsync = ____require_result_13.buildAsync -- 1099
					Director.systemScheduler:schedule(once(function() -- 1100
						local result = buildAsync(file) -- 1101
						resolve(nil, result) -- 1102
					end)) -- 1100
				end -- 1097
			) -- 1097
		) -- 1097
	end) -- 1097
end -- 1096
local transpileRequestSeq = 0 -- 1107
function ____exports.runSingleTsTranspile(file, content) -- 1109
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1109
		local done = false -- 1110
		transpileRequestSeq = transpileRequestSeq + 1 -- 1111
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 1112
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 1113
		if HttpServer.wsConnectionCount == 0 then -- 1113
			return ____awaiter_resolve(nil, result) -- 1113
		end -- 1113
		local listener = Node() -- 1121
		listener:gslot( -- 1122
			"AppWS", -- 1122
			function(event) -- 1122
				if event.type ~= "Receive" then -- 1122
					return -- 1123
				end -- 1123
				local res = safeJsonDecode(event.msg) -- 1124
				if not res or __TS__ArrayIsArray(res) then -- 1124
					return -- 1125
				end -- 1125
				local payload = res -- 1126
				if payload.name ~= "TranspileTS" then -- 1126
					return -- 1127
				end -- 1127
				if payload.id ~= requestId then -- 1127
					return -- 1128
				end -- 1128
				if tostring(payload.file) ~= file then -- 1128
					return -- 1129
				end -- 1129
				if payload.success then -- 1129
					local luaFile = Path:replaceExt(file, "lua") -- 1131
					if Content:save( -- 1131
						luaFile, -- 1132
						tostring(payload.luaCode) -- 1132
					) then -- 1132
						result = {success = true, file = file} -- 1133
					else -- 1133
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 1135
					end -- 1135
				else -- 1135
					result = { -- 1138
						success = false, -- 1138
						file = file, -- 1138
						message = tostring(payload.message) -- 1138
					} -- 1138
				end -- 1138
				done = true -- 1140
			end -- 1122
		) -- 1122
		local payload = encodeJSON({name = "TranspileTS", id = requestId, file = file, content = content}) -- 1142
		if not payload then -- 1142
			listener:removeFromParent() -- 1149
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 1149
		end -- 1149
		__TS__Await(__TS__New( -- 1152
			__TS__Promise, -- 1152
			function(____, resolve) -- 1152
				Director.systemScheduler:schedule(once(function() -- 1153
					emit("AppWS", "Send", payload) -- 1154
					wait(function() return done end) -- 1155
					if not done then -- 1155
						listener:removeFromParent() -- 1157
					end -- 1157
					resolve(nil) -- 1159
				end)) -- 1153
			end -- 1152
		)) -- 1152
		return ____awaiter_resolve(nil, result) -- 1152
	end) -- 1152
end -- 1109
function ____exports.createTask(prompt) -- 1165
	if prompt == nil then -- 1165
		prompt = "" -- 1165
	end -- 1165
	local t = now() -- 1166
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 1167
	if affected <= 0 then -- 1167
		return {success = false, message = "failed to create task"} -- 1172
	end -- 1172
	return { -- 1174
		success = true, -- 1174
		taskId = getLastInsertRowId() -- 1174
	} -- 1174
end -- 1165
function ____exports.setTaskStatus(taskId, status) -- 1177
	DB:exec( -- 1178
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 1178
		{ -- 1178
			status, -- 1178
			now(), -- 1178
			taskId -- 1178
		} -- 1178
	) -- 1178
	Log( -- 1179
		"Info", -- 1179
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 1179
	) -- 1179
end -- 1177
function ____exports.listCheckpoints(taskId) -- 1182
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 1183
	if not rows then -- 1183
		return {} -- 1190
	end -- 1190
	local items = {} -- 1191
	do -- 1191
		local i = 0 -- 1192
		while i < #rows do -- 1192
			local row = rows[i + 1] -- 1193
			items[#items + 1] = { -- 1194
				id = row[1], -- 1195
				taskId = row[2], -- 1196
				seq = row[3], -- 1197
				status = toStr(row[4]), -- 1198
				summary = toStr(row[5]), -- 1199
				toolName = toStr(row[6]), -- 1200
				createdAt = row[7] -- 1201
			} -- 1201
			i = i + 1 -- 1192
		end -- 1192
	end -- 1192
	return items -- 1204
end -- 1182
local function listCheckpointIdsForTask(taskId, desc) -- 1207
	if desc == nil then -- 1207
		desc = false -- 1207
	end -- 1207
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 1208
	if not rows then -- 1208
		return {} -- 1215
	end -- 1215
	local items = {} -- 1216
	do -- 1216
		local i = 0 -- 1217
		while i < #rows do -- 1217
			local row = rows[i + 1] -- 1218
			items[#items + 1] = {id = row[1], seq = row[2]} -- 1219
			i = i + 1 -- 1217
		end -- 1217
	end -- 1217
	return items -- 1224
end -- 1207
local function deriveFileOp(beforeExists, afterExists) -- 1227
	if not beforeExists and afterExists then -- 1227
		return "create" -- 1228
	end -- 1228
	if beforeExists and not afterExists then -- 1228
		return "delete" -- 1229
	end -- 1229
	return "write" -- 1230
end -- 1227
function ____exports.summarizeTaskChangeSet(taskId) -- 1233
	if not getTaskStatus(taskId) then -- 1233
		return {success = false, message = "task not found"} -- 1235
	end -- 1235
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1237
	local filesByPath = {} -- 1238
	local latestCheckpointId = nil -- 1244
	local latestCheckpointSeq = nil -- 1245
	do -- 1245
		local i = 0 -- 1246
		while i < #checkpoints do -- 1246
			local checkpoint = checkpoints[i + 1] -- 1247
			latestCheckpointId = checkpoint.id -- 1248
			latestCheckpointSeq = checkpoint.seq -- 1249
			local entries = getCheckpointEntries(checkpoint.id, false) -- 1250
			do -- 1250
				local j = 0 -- 1251
				while j < #entries do -- 1251
					local entry = entries[j + 1] -- 1252
					local item = filesByPath[entry.path] -- 1253
					if not item then -- 1253
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 1255
						filesByPath[entry.path] = item -- 1261
					end -- 1261
					item.afterExists = entry.afterExists -- 1263
					local ____item_checkpointIds_14 = item.checkpointIds -- 1263
					____item_checkpointIds_14[#____item_checkpointIds_14 + 1] = checkpoint.id -- 1264
					j = j + 1 -- 1251
				end -- 1251
			end -- 1251
			i = i + 1 -- 1246
		end -- 1246
	end -- 1246
	local files = {} -- 1267
	for ____, item in pairs(filesByPath) do -- 1268
		files[#files + 1] = { -- 1269
			path = item.path, -- 1270
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1271
			checkpointCount = #item.checkpointIds, -- 1272
			checkpointIds = item.checkpointIds -- 1273
		} -- 1273
	end -- 1273
	__TS__ArraySort( -- 1276
		files, -- 1276
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1276
	) -- 1276
	return { -- 1277
		success = true, -- 1278
		taskId = taskId, -- 1279
		checkpointCount = #checkpoints, -- 1280
		filesChanged = #files, -- 1281
		files = files, -- 1282
		latestCheckpointId = latestCheckpointId, -- 1283
		latestCheckpointSeq = latestCheckpointSeq -- 1284
	} -- 1284
end -- 1233
function ____exports.getTaskChangeSetDiff(taskId) -- 1288
	if not getTaskStatus(taskId) then -- 1288
		return {success = false, message = "task not found"} -- 1290
	end -- 1290
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1292
	if #checkpoints == 0 then -- 1292
		return {success = false, message = "change set not found or empty"} -- 1294
	end -- 1294
	local filesByPath = {} -- 1296
	do -- 1296
		local i = 0 -- 1303
		while i < #checkpoints do -- 1303
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 1304
			do -- 1304
				local j = 0 -- 1305
				while j < #entries do -- 1305
					local entry = entries[j + 1] -- 1306
					local item = filesByPath[entry.path] -- 1307
					if not item then -- 1307
						item = { -- 1309
							path = entry.path, -- 1310
							beforeExists = entry.beforeExists, -- 1311
							beforeContent = entry.beforeContent, -- 1312
							afterExists = entry.afterExists, -- 1313
							afterContent = entry.afterContent -- 1314
						} -- 1314
						filesByPath[entry.path] = item -- 1316
					end -- 1316
					item.afterExists = entry.afterExists -- 1318
					item.afterContent = entry.afterContent -- 1319
					j = j + 1 -- 1305
				end -- 1305
			end -- 1305
			i = i + 1 -- 1303
		end -- 1303
	end -- 1303
	local files = {} -- 1322
	for ____, item in pairs(filesByPath) do -- 1323
		files[#files + 1] = { -- 1324
			path = item.path, -- 1325
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1326
			beforeExists = item.beforeExists, -- 1327
			afterExists = item.afterExists, -- 1328
			beforeContent = item.beforeContent, -- 1329
			afterContent = item.afterContent -- 1330
		} -- 1330
	end -- 1330
	__TS__ArraySort( -- 1333
		files, -- 1333
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1333
	) -- 1333
	return {success = true, files = files} -- 1334
end -- 1288
local function readWorkspaceFile(workDir, path, docLanguage) -- 1337
	local engineLog = readEngineLogFile(path) -- 1338
	if engineLog then -- 1338
		return engineLog -- 1339
	end -- 1339
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1340
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 1340
		local attr = inspectReadableFile(fullPath) -- 1342
		if not attr.success then -- 1342
			return attr -- 1343
		end -- 1343
		return { -- 1344
			success = true, -- 1344
			content = Content:load(fullPath), -- 1344
			size = attr.size -- 1344
		} -- 1344
	end -- 1344
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 1346
	if docPath then -- 1346
		local attr = inspectReadableFile(docPath) -- 1348
		if not attr.success then -- 1348
			return attr -- 1349
		end -- 1349
		return { -- 1350
			success = true, -- 1350
			content = Content:load(docPath), -- 1350
			size = attr.size -- 1350
		} -- 1350
	end -- 1350
	if not fullPath then -- 1350
		return {success = false, message = "invalid path or workDir"} -- 1352
	end -- 1352
	return {success = false, message = "file not found"} -- 1353
end -- 1337
function ____exports.readFileRaw(workDir, path, docLanguage) -- 1356
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 1357
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 1357
		local attr = inspectReadableFile(path) -- 1359
		if not attr.success then -- 1359
			return attr -- 1360
		end -- 1360
		return { -- 1361
			success = true, -- 1361
			content = Content:load(path), -- 1361
			size = attr.size -- 1361
		} -- 1361
	end -- 1361
	return result -- 1363
end -- 1356
function ____exports.getLogs(req) -- 1378
	local text = getEngineLogText() -- 1379
	if text == nil then -- 1379
		return {success = false, message = "failed to read engine logs"} -- 1381
	end -- 1381
	local tailLines = math.max( -- 1383
		1, -- 1383
		math.floor(req and req.tailLines or 200) -- 1383
	) -- 1383
	local allLines = __TS__StringSplit(text, "\n") -- 1384
	local logs = __TS__ArraySlice( -- 1385
		allLines, -- 1385
		math.max(0, #allLines - tailLines) -- 1385
	) -- 1385
	return req and req.joinText and ({ -- 1386
		success = true, -- 1386
		logs = logs, -- 1386
		text = table.concat(logs, "\n") -- 1386
	}) or ({success = true, logs = logs}) -- 1386
end -- 1378
function ____exports.listFiles(req) -- 1389
	local root = req.path or "" -- 1395
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 1396
	if not searchRoot then -- 1396
		return {success = false, message = "invalid path or workDir"} -- 1398
	end -- 1398
	do -- 1398
		local function ____catch(e) -- 1398
			return true, { -- 1416
				success = false, -- 1416
				message = tostring(e) -- 1416
			} -- 1416
		end -- 1416
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1416
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 1401
			local globs = ensureSafeSearchGlobs(userGlobs) -- 1402
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 1403
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 1404
			local totalEntries = #files -- 1405
			local maxEntries = math.max( -- 1406
				1, -- 1406
				math.floor(req.maxEntries or 200) -- 1406
			) -- 1406
			local truncated = totalEntries > maxEntries -- 1407
			return true, { -- 1408
				success = true, -- 1409
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 1410
				totalEntries = totalEntries, -- 1411
				truncated = truncated, -- 1412
				maxEntries = maxEntries -- 1413
			} -- 1413
		end) -- 1413
		if not ____try then -- 1413
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1413
		end -- 1413
		if ____hasReturned then -- 1413
			return ____returnValue -- 1400
		end -- 1400
	end -- 1400
end -- 1389
local function formatReadSlice(content, startLine, endLine) -- 1420
	local lines = __TS__StringSplit(content, "\n") -- 1425
	local totalLines = #lines -- 1426
	if totalLines == 0 then -- 1426
		return { -- 1428
			success = true, -- 1429
			content = "", -- 1430
			totalLines = 0, -- 1431
			startLine = 1, -- 1432
			endLine = 0, -- 1433
			truncated = false -- 1434
		} -- 1434
	end -- 1434
	local rawStart = math.floor(startLine) -- 1437
	local rawEnd = math.floor(endLine) -- 1438
	if rawStart == 0 then -- 1438
		return {success = false, message = "startLine cannot be 0"} -- 1440
	end -- 1440
	if rawEnd == 0 then -- 1440
		return {success = false, message = "endLine cannot be 0"} -- 1443
	end -- 1443
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1445
	if start > totalLines then -- 1445
		return { -- 1449
			success = false, -- 1449
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1449
		} -- 1449
	end -- 1449
	local ____end = math.min( -- 1451
		totalLines, -- 1452
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1453
	) -- 1453
	if ____end < start then -- 1453
		return { -- 1458
			success = false, -- 1459
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1460
		} -- 1460
	end -- 1460
	local slice = {} -- 1463
	do -- 1463
		local i = start -- 1464
		while i <= ____end do -- 1464
			slice[#slice + 1] = lines[i] -- 1465
			i = i + 1 -- 1464
		end -- 1464
	end -- 1464
	local truncated = start > 1 or ____end < totalLines -- 1467
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1468
	local body = table.concat(slice, "\n") -- 1473
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1474
	return { -- 1475
		success = true, -- 1476
		content = output, -- 1477
		totalLines = totalLines, -- 1478
		startLine = start, -- 1479
		endLine = ____end, -- 1480
		truncated = truncated -- 1481
	} -- 1481
end -- 1420
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1485
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1492
	if not fallback.success or fallback.content == nil then -- 1492
		return fallback -- 1493
	end -- 1493
	local resolvedStartLine = startLine or 1 -- 1494
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1495
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1496
end -- 1485
local codeExtensions = { -- 1503
	".lua", -- 1503
	".tl", -- 1503
	".yue", -- 1503
	".ts", -- 1503
	".tsx", -- 1503
	".xml", -- 1503
	".md", -- 1503
	".yarn", -- 1503
	".wa", -- 1503
	".mod" -- 1503
} -- 1503
extensionLevels = { -- 1504
	vs = 2, -- 1505
	bl = 2, -- 1506
	ts = 1, -- 1507
	tsx = 1, -- 1508
	tl = 1, -- 1509
	yue = 1, -- 1510
	xml = 1, -- 1511
	lua = 0 -- 1512
} -- 1512
local function splitSearchPatterns(pattern) -- 1529
	local trimmed = __TS__StringTrim(pattern or "") -- 1530
	if trimmed == "" then -- 1530
		return {} -- 1531
	end -- 1531
	local out = {} -- 1532
	local seen = __TS__New(Set) -- 1533
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1534
		local p = __TS__StringTrim(tostring(p0)) -- 1535
		if p ~= "" and not seen:has(p) then -- 1535
			seen:add(p) -- 1537
			out[#out + 1] = p -- 1538
		end -- 1538
	end -- 1538
	return out -- 1541
end -- 1529
local function mergeSearchFileResultsUnique(resultsList) -- 1544
	local merged = {} -- 1545
	local seen = __TS__New(Set) -- 1546
	do -- 1546
		local i = 0 -- 1547
		while i < #resultsList do -- 1547
			local list = resultsList[i + 1] -- 1548
			do -- 1548
				local j = 0 -- 1549
				while j < #list do -- 1549
					do -- 1549
						local row = list[j + 1] -- 1550
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1551
						if seen:has(key) then -- 1551
							goto __continue307 -- 1552
						end -- 1552
						seen:add(key) -- 1553
						merged[#merged + 1] = list[j + 1] -- 1554
					end -- 1554
					::__continue307:: -- 1554
					j = j + 1 -- 1549
				end -- 1549
			end -- 1549
			i = i + 1 -- 1547
		end -- 1547
	end -- 1547
	return merged -- 1557
end -- 1544
local function buildGroupedSearchResults(results) -- 1560
	local order = {} -- 1565
	local grouped = __TS__New(Map) -- 1566
	do -- 1566
		local i = 0 -- 1571
		while i < #results do -- 1571
			local row = results[i + 1] -- 1572
			local file = row.file -- 1573
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1574
			local bucket = grouped:get(key) -- 1575
			if not bucket then -- 1575
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1577
				grouped:set(key, bucket) -- 1578
				order[#order + 1] = key -- 1579
			end -- 1579
			bucket.totalMatches = bucket.totalMatches + 1 -- 1581
			local ____bucket_matches_19 = bucket.matches -- 1581
			____bucket_matches_19[#____bucket_matches_19 + 1] = results[i + 1] -- 1582
			i = i + 1 -- 1571
		end -- 1571
	end -- 1571
	local out = {} -- 1584
	do -- 1584
		local i = 0 -- 1589
		while i < #order do -- 1589
			local bucket = grouped:get(order[i + 1]) -- 1590
			if bucket then -- 1590
				out[#out + 1] = bucket -- 1591
			end -- 1591
			i = i + 1 -- 1589
		end -- 1589
	end -- 1589
	return out -- 1593
end -- 1560
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1596
	local merged = {} -- 1597
	local seen = __TS__New(Set) -- 1598
	local index = 0 -- 1599
	local advanced = true -- 1600
	while advanced do -- 1600
		advanced = false -- 1602
		do -- 1602
			local i = 0 -- 1603
			while i < #resultsList do -- 1603
				do -- 1603
					local list = resultsList[i + 1] -- 1604
					if index >= #list then -- 1604
						goto __continue319 -- 1605
					end -- 1605
					advanced = true -- 1606
					local row = list[index + 1] -- 1607
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1608
					if seen:has(key) then -- 1608
						goto __continue319 -- 1609
					end -- 1609
					seen:add(key) -- 1610
					merged[#merged + 1] = row -- 1611
				end -- 1611
				::__continue319:: -- 1611
				i = i + 1 -- 1603
			end -- 1603
		end -- 1603
		index = index + 1 -- 1613
	end -- 1613
	return merged -- 1615
end -- 1596
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1618
	if docSource ~= "api" then -- 1618
		return 100 -- 1619
	end -- 1619
	if programmingLanguage ~= "tsx" then -- 1619
		return 100 -- 1620
	end -- 1620
	repeat -- 1620
		local ____switch325 = string.lower(Path:getFilename(file)) -- 1620
		local ____cond325 = ____switch325 == "jsx.d.ts" -- 1620
		if ____cond325 then -- 1620
			return 0 -- 1622
		end -- 1622
		____cond325 = ____cond325 or ____switch325 == "dorax.d.ts" -- 1622
		if ____cond325 then -- 1622
			return 1 -- 1623
		end -- 1623
		____cond325 = ____cond325 or ____switch325 == "dora.d.ts" -- 1623
		if ____cond325 then -- 1623
			return 2 -- 1624
		end -- 1624
		do -- 1624
			return 100 -- 1625
		end -- 1625
	until true -- 1625
end -- 1618
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1629
	local sorted = __TS__ArraySlice(hits) -- 1634
	__TS__ArraySort( -- 1635
		sorted, -- 1635
		function(____, a, b) -- 1635
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1636
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1637
			if pa ~= pb then -- 1637
				return pa - pb -- 1638
			end -- 1638
			local fa = string.lower(a.file) -- 1639
			local fb = string.lower(b.file) -- 1640
			if fa ~= fb then -- 1640
				return fa < fb and -1 or 1 -- 1641
			end -- 1641
			return (a.line or 0) - (b.line or 0) -- 1642
		end -- 1635
	) -- 1635
	return sorted -- 1644
end -- 1629
function ____exports.searchFiles(req) -- 1647
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1647
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1660
		if not resolvedPath then -- 1660
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1660
		end -- 1660
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1664
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1665
		if not searchRoot then -- 1665
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1665
		end -- 1665
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1665
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1665
		end -- 1665
		local patterns = splitSearchPatterns(req.pattern) -- 1672
		if #patterns == 0 then -- 1672
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1672
		end -- 1672
		return ____awaiter_resolve( -- 1672
			nil, -- 1672
			__TS__New( -- 1676
				__TS__Promise, -- 1676
				function(____, resolve) -- 1676
					Director.systemScheduler:schedule(once(function() -- 1677
						do -- 1677
							local function ____catch(e) -- 1677
								resolve( -- 1719
									nil, -- 1719
									{ -- 1719
										success = false, -- 1719
										message = tostring(e) -- 1719
									} -- 1719
								) -- 1719
							end -- 1719
							local ____try, ____hasReturned = pcall(function() -- 1719
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1679
								local allResults = {} -- 1682
								do -- 1682
									local i = 0 -- 1683
									while i < #patterns do -- 1683
										local ____Content_24 = Content -- 1684
										local ____Content_searchFilesAsync_25 = Content.searchFilesAsync -- 1684
										local ____patterns_index_23 = patterns[i + 1] -- 1689
										local ____req_useRegex_20 = req.useRegex -- 1690
										if ____req_useRegex_20 == nil then -- 1690
											____req_useRegex_20 = false -- 1690
										end -- 1690
										local ____req_caseSensitive_21 = req.caseSensitive -- 1691
										if ____req_caseSensitive_21 == nil then -- 1691
											____req_caseSensitive_21 = false -- 1691
										end -- 1691
										local ____req_includeContent_22 = req.includeContent -- 1692
										if ____req_includeContent_22 == nil then -- 1692
											____req_includeContent_22 = true -- 1692
										end -- 1692
										allResults[#allResults + 1] = ____Content_searchFilesAsync_25( -- 1684
											____Content_24, -- 1684
											searchRoot, -- 1685
											codeExtensions, -- 1686
											extensionLevels, -- 1687
											searchGlobs, -- 1688
											____patterns_index_23, -- 1689
											____req_useRegex_20, -- 1690
											____req_caseSensitive_21, -- 1691
											____req_includeContent_22, -- 1692
											req.contentWindow or 120 -- 1693
										) -- 1693
										i = i + 1 -- 1683
									end -- 1683
								end -- 1683
								local results = mergeSearchFileResultsUnique(allResults) -- 1696
								local totalResults = #results -- 1697
								local limit = math.max( -- 1698
									1, -- 1698
									math.floor(req.limit or 20) -- 1698
								) -- 1698
								local offset = math.max( -- 1699
									0, -- 1699
									math.floor(req.offset or 0) -- 1699
								) -- 1699
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1700
								local nextOffset = offset + #paged -- 1701
								local hasMore = nextOffset < totalResults -- 1702
								local truncated = offset > 0 or hasMore -- 1703
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1704
								local groupByFile = req.groupByFile == true -- 1705
								resolve( -- 1706
									nil, -- 1706
									{ -- 1706
										success = true, -- 1707
										results = relativeResults, -- 1708
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1709
										totalResults = totalResults, -- 1710
										truncated = truncated, -- 1711
										limit = limit, -- 1712
										offset = offset, -- 1713
										nextOffset = nextOffset, -- 1714
										hasMore = hasMore, -- 1715
										groupByFile = groupByFile -- 1716
									} -- 1716
								) -- 1716
							end) -- 1716
							if not ____try then -- 1716
								____catch(____hasReturned) -- 1716
							end -- 1716
						end -- 1716
					end)) -- 1677
				end -- 1676
			) -- 1676
		) -- 1676
	end) -- 1676
end -- 1647
function ____exports.searchDoraAPI(req) -- 1725
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1725
		local pattern = __TS__StringTrim(req.pattern or "") -- 1736
		if pattern == "" then -- 1736
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1736
		end -- 1736
		local patterns = splitSearchPatterns(pattern) -- 1738
		if #patterns == 0 then -- 1738
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1738
		end -- 1738
		local docSource = req.docSource or "api" -- 1740
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1741
		local docRoot = target.root -- 1742
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1743
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1743
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1743
		end -- 1743
		local exts = target.exts -- 1747
		local dotExts = __TS__ArrayMap( -- 1748
			exts, -- 1748
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1748
		) -- 1748
		local globs = target.globs -- 1749
		local limit = math.max( -- 1750
			1, -- 1750
			math.floor(req.limit or 10) -- 1750
		) -- 1750
		return ____awaiter_resolve( -- 1750
			nil, -- 1750
			__TS__New( -- 1752
				__TS__Promise, -- 1752
				function(____, resolve) -- 1752
					Director.systemScheduler:schedule(once(function() -- 1753
						do -- 1753
							local function ____catch(e) -- 1753
								resolve( -- 1795
									nil, -- 1795
									{ -- 1795
										success = false, -- 1795
										message = tostring(e) -- 1795
									} -- 1795
								) -- 1795
							end -- 1795
							local ____try, ____hasReturned = pcall(function() -- 1795
								local allHits = {} -- 1755
								do -- 1755
									local p = 0 -- 1756
									while p < #patterns do -- 1756
										local ____Content_30 = Content -- 1757
										local ____Content_searchFilesAsync_31 = Content.searchFilesAsync -- 1757
										local ____array_29 = __TS__SparseArrayNew( -- 1757
											docRoot, -- 1758
											dotExts, -- 1759
											{}, -- 1760
											ensureSafeSearchGlobs(globs), -- 1761
											patterns[p + 1] -- 1762
										) -- 1762
										local ____req_useRegex_26 = req.useRegex -- 1763
										if ____req_useRegex_26 == nil then -- 1763
											____req_useRegex_26 = false -- 1763
										end -- 1763
										__TS__SparseArrayPush(____array_29, ____req_useRegex_26) -- 1763
										local ____req_caseSensitive_27 = req.caseSensitive -- 1764
										if ____req_caseSensitive_27 == nil then -- 1764
											____req_caseSensitive_27 = false -- 1764
										end -- 1764
										__TS__SparseArrayPush(____array_29, ____req_caseSensitive_27) -- 1764
										local ____req_includeContent_28 = req.includeContent -- 1765
										if ____req_includeContent_28 == nil then -- 1765
											____req_includeContent_28 = true -- 1765
										end -- 1765
										__TS__SparseArrayPush(____array_29, ____req_includeContent_28, req.contentWindow or 80) -- 1765
										local raw = ____Content_searchFilesAsync_31( -- 1757
											____Content_30, -- 1757
											__TS__SparseArraySpread(____array_29) -- 1757
										) -- 1757
										local hits = {} -- 1768
										do -- 1768
											local i = 0 -- 1769
											while i < #raw do -- 1769
												do -- 1769
													local row = raw[i + 1] -- 1770
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1771
													if file == "" then -- 1771
														goto __continue352 -- 1772
													end -- 1772
													hits[#hits + 1] = { -- 1773
														file = file, -- 1774
														line = type(row.line) == "number" and row.line or nil, -- 1775
														content = type(row.content) == "string" and row.content or nil -- 1776
													} -- 1776
												end -- 1776
												::__continue352:: -- 1776
												i = i + 1 -- 1769
											end -- 1769
										end -- 1769
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1779
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1779
											0, -- 1779
											limit -- 1779
										) -- 1779
										p = p + 1 -- 1756
									end -- 1756
								end -- 1756
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1781
								resolve(nil, { -- 1782
									success = true, -- 1783
									docSource = docSource, -- 1784
									docLanguage = req.docLanguage, -- 1785
									programmingLanguage = req.programmingLanguage, -- 1786
									exts = exts, -- 1787
									results = hits, -- 1788
									hint = "Use read_file directly with the file value from a search result to view the complete document. Do not add any prefixes.", -- 1789
									totalResults = #hits, -- 1790
									truncated = false, -- 1791
									limit = limit -- 1792
								}) -- 1792
							end) -- 1792
							if not ____try then -- 1792
								____catch(____hasReturned) -- 1792
							end -- 1792
						end -- 1792
					end)) -- 1753
				end -- 1752
			) -- 1752
		) -- 1752
	end) -- 1752
end -- 1725
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1801
	if options == nil then -- 1801
		options = {} -- 1801
	end -- 1801
	if #changes == 0 then -- 1801
		return {success = false, message = "empty changes"} -- 1803
	end -- 1803
	if not isValidWorkDir(workDir) then -- 1803
		return {success = false, message = "invalid workDir"} -- 1806
	end -- 1806
	if not getTaskStatus(taskId) then -- 1806
		return {success = false, message = "task not found"} -- 1809
	end -- 1809
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1811
	local dup = rejectDuplicatePaths(expandedChanges) -- 1812
	if dup then -- 1812
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1814
	end -- 1814
	for ____, change in ipairs(expandedChanges) do -- 1817
		if not isValidWorkspacePath(change.path) then -- 1817
			return {success = false, message = "invalid path: " .. change.path} -- 1819
		end -- 1819
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1819
			return {success = false, message = "missing content for " .. change.path} -- 1822
		end -- 1822
	end -- 1822
	local headSeq = getTaskHeadSeq(taskId) -- 1826
	if headSeq == nil then -- 1826
		return {success = false, message = "task not found"} -- 1827
	end -- 1827
	local nextSeq = headSeq + 1 -- 1828
	local checkpointId = insertCheckpoint( -- 1829
		taskId, -- 1829
		nextSeq, -- 1829
		options.summary or "", -- 1829
		options.toolName or "", -- 1829
		"PREPARED" -- 1829
	) -- 1829
	if checkpointId <= 0 then -- 1829
		return {success = false, message = "failed to create checkpoint"} -- 1831
	end -- 1831
	do -- 1831
		local i = 0 -- 1834
		while i < #expandedChanges do -- 1834
			local change = expandedChanges[i + 1] -- 1835
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1836
			if not fullPath then -- 1836
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1838
				return {success = false, message = "invalid path: " .. change.path} -- 1839
			end -- 1839
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 1839
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1842
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 1843
			end -- 1843
			local before = getFileState(fullPath) -- 1845
			local afterExists = change.op ~= "delete" -- 1846
			local afterContent = afterExists and (change.content or "") or "" -- 1847
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1848
				checkpointId, -- 1852
				i + 1, -- 1853
				change.path, -- 1854
				change.op, -- 1855
				before.exists and 1 or 0, -- 1856
				before.content, -- 1857
				afterExists and 1 or 0, -- 1858
				afterContent, -- 1859
				before.bytes, -- 1860
				#afterContent -- 1861
			}) -- 1861
			if inserted <= 0 then -- 1861
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1865
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1866
			end -- 1866
			i = i + 1 -- 1834
		end -- 1834
	end -- 1834
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1870
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1871
		if not fullPath then -- 1871
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1873
			return {success = false, message = "invalid path: " .. entry.path} -- 1874
		end -- 1874
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1876
		if not ok then -- 1876
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1878
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1879
		end -- 1879
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1879
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1882
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1883
		end -- 1883
	end -- 1883
	DB:exec( -- 1887
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1887
		{ -- 1889
			"APPLIED", -- 1889
			now(), -- 1889
			checkpointId -- 1889
		} -- 1889
	) -- 1889
	DB:exec( -- 1891
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1891
		{ -- 1893
			nextSeq, -- 1893
			now(), -- 1893
			taskId -- 1893
		} -- 1893
	) -- 1893
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1895
end -- 1801
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1903
	if not isValidWorkDir(workDir) then -- 1903
		return {success = false, message = "invalid workDir"} -- 1904
	end -- 1904
	if checkpointId <= 0 then -- 1904
		return {success = false, message = "invalid checkpointId"} -- 1905
	end -- 1905
	local entries = getCheckpointEntries(checkpointId, true) -- 1906
	if #entries == 0 then -- 1906
		return {success = false, message = "checkpoint not found or empty"} -- 1908
	end -- 1908
	for ____, entry in ipairs(entries) do -- 1910
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1911
		if not fullPath then -- 1911
			return {success = false, message = "invalid path: " .. entry.path} -- 1913
		end -- 1913
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1915
		if not ok then -- 1915
			Log( -- 1917
				"Error", -- 1917
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1917
			) -- 1917
			Log( -- 1918
				"Info", -- 1918
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1918
			) -- 1918
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1919
		end -- 1919
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1919
			Log( -- 1922
				"Error", -- 1922
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1922
			) -- 1922
			Log( -- 1923
				"Info", -- 1923
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1923
			) -- 1923
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1924
		end -- 1924
	end -- 1924
	DB:exec( -- 1927
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 1927
		{ -- 1927
			"REVERTED", -- 1927
			now(), -- 1927
			checkpointId -- 1927
		} -- 1927
	) -- 1927
	return {success = true, checkpointId = checkpointId} -- 1928
end -- 1903
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 1931
	if not isValidWorkDir(workDir) then -- 1931
		return {success = false, message = "invalid workDir"} -- 1932
	end -- 1932
	if not getTaskStatus(taskId) then -- 1932
		return {success = false, message = "task not found"} -- 1933
	end -- 1933
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 1934
	if #checkpoints == 0 then -- 1934
		return {success = false, message = "change set not found or empty"} -- 1936
	end -- 1936
	local lastCheckpointId = 0 -- 1938
	do -- 1938
		local i = 0 -- 1939
		while i < #checkpoints do -- 1939
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 1940
			if not result.success then -- 1940
				return {success = false, message = result.message} -- 1941
			end -- 1941
			lastCheckpointId = checkpoints[i + 1].id -- 1942
			i = i + 1 -- 1939
		end -- 1939
	end -- 1939
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 1944
end -- 1931
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1952
	return getCheckpointEntries(checkpointId, false) -- 1953
end -- 1952
function ____exports.getCheckpointDiff(checkpointId) -- 1956
	if checkpointId <= 0 then -- 1956
		return {success = false, message = "invalid checkpointId"} -- 1958
	end -- 1958
	local entries = getCheckpointEntries(checkpointId, false) -- 1960
	if #entries == 0 then -- 1960
		return {success = false, message = "checkpoint not found or empty"} -- 1962
	end -- 1962
	return { -- 1964
		success = true, -- 1965
		files = __TS__ArrayMap( -- 1966
			entries, -- 1966
			function(____, entry) return { -- 1966
				path = entry.path, -- 1967
				op = entry.op, -- 1968
				beforeExists = entry.beforeExists, -- 1969
				afterExists = entry.afterExists, -- 1970
				beforeContent = entry.beforeContent, -- 1971
				afterContent = entry.afterContent -- 1972
			} end -- 1972
		) -- 1972
	} -- 1972
end -- 1956
local function finalizeBuildResult(workDir, messages) -- 1977
	local normalized = __TS__ArrayMap( -- 1978
		messages, -- 1978
		function(____, m) return m.success and __TS__ObjectAssign( -- 1978
			{}, -- 1979
			m, -- 1979
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1979
		) or __TS__ObjectAssign( -- 1979
			{}, -- 1980
			m, -- 1980
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1980
		) end -- 1980
	) -- 1980
	local total = #normalized -- 1981
	local failed = 0 -- 1982
	do -- 1982
		local i = 0 -- 1983
		while i < #normalized do -- 1983
			if not normalized[i + 1].success then -- 1983
				failed = failed + 1 -- 1984
			end -- 1984
			i = i + 1 -- 1983
		end -- 1983
	end -- 1983
	local passed = total - failed -- 1986
	if failed > 0 then -- 1986
		return { -- 1988
			success = false, -- 1989
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 1990
			total = total, -- 1991
			passed = passed, -- 1992
			failed = failed, -- 1993
			messages = normalized -- 1994
		} -- 1994
	end -- 1994
	return { -- 1997
		success = true, -- 1998
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 1999
		total = total, -- 2000
		passed = passed, -- 2001
		failed = 0, -- 2002
		messages = normalized -- 2003
	} -- 2003
end -- 1977
function ____exports.build(req) -- 2007
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2007
		local targetRel = req.path or "" -- 2008
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2009
		if not target then -- 2009
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2009
		end -- 2009
		if not Content:exist(target) then -- 2009
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2009
		end -- 2009
		local messages = {} -- 2016
		if not Content:isdir(target) then -- 2016
			local kind = getSupportedBuildKind(target) -- 2018
			if not kind then -- 2018
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2018
			end -- 2018
			if kind == "ts" then -- 2018
				local content = Content:load(target) -- 2023
				if content == nil then -- 2023
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2023
				end -- 2023
				if isTiledEditorContent(content) then -- 2023
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2028
					return ____awaiter_resolve( -- 2028
						nil, -- 2028
						finalizeBuildResult(req.workDir, messages) -- 2029
					) -- 2029
				end -- 2029
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2029
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2029
				end -- 2029
				if not isDtsFile(target) then -- 2029
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 2035
				end -- 2035
			else -- 2035
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2038
			end -- 2038
			Log( -- 2040
				"Info", -- 2040
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2040
			) -- 2040
			return ____awaiter_resolve( -- 2040
				nil, -- 2040
				finalizeBuildResult(req.workDir, messages) -- 2041
			) -- 2041
		end -- 2041
		local listResult = ____exports.listFiles({ -- 2043
			workDir = req.workDir, -- 2044
			path = targetRel, -- 2045
			globs = __TS__ArrayMap( -- 2046
				codeExtensions, -- 2046
				function(____, e) return "**/*" .. e end -- 2046
			), -- 2046
			maxEntries = 10000 -- 2047
		}) -- 2047
		local relFiles = listResult.success and listResult.files or ({}) -- 2050
		local tsFileData = {} -- 2051
		local buildQueue = {} -- 2052
		for ____, rel in ipairs(relFiles) do -- 2053
			do -- 2053
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2054
				local kind = getSupportedBuildKind(file) -- 2055
				if not kind then -- 2055
					goto __continue415 -- 2056
				end -- 2056
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2057
				if kind ~= "ts" then -- 2057
					goto __continue415 -- 2059
				end -- 2059
				local content = Content:load(file) -- 2061
				if content == nil then -- 2061
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2063
					goto __continue415 -- 2064
				end -- 2064
				if isTiledEditorContent(content) then -- 2064
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2067
					goto __continue415 -- 2068
				end -- 2068
				tsFileData[file] = content -- 2070
			end -- 2070
			::__continue415:: -- 2070
		end -- 2070
		do -- 2070
			local i = 0 -- 2072
			while i < #buildQueue do -- 2072
				do -- 2072
					local ____buildQueue_index_32 = buildQueue[i + 1] -- 2073
					local file = ____buildQueue_index_32.file -- 2073
					local kind = ____buildQueue_index_32.kind -- 2073
					if kind == "ts" then -- 2073
						local content = tsFileData[file] -- 2075
						if content == nil or isDtsFile(file) then -- 2075
							goto __continue422 -- 2077
						end -- 2077
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2077
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2080
							goto __continue422 -- 2081
						end -- 2081
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 2083
						goto __continue422 -- 2084
					end -- 2084
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2086
				end -- 2086
				::__continue422:: -- 2086
				i = i + 1 -- 2072
			end -- 2072
		end -- 2072
		if #messages == 0 then -- 2072
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2089
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2089
		end -- 2089
		Log( -- 2092
			"Info", -- 2092
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2092
		) -- 2092
		return ____awaiter_resolve( -- 2092
			nil, -- 2092
			finalizeBuildResult(req.workDir, messages) -- 2093
		) -- 2093
	end) -- 2093
end -- 2007
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2096
local function truncateCommandOutput(output) -- 2098
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2098
		return output -- 2099
	end -- 2099
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2100
end -- 2098
local function executeLuaCommand(req) -- 2103
	local code = __TS__StringTrim(req.code or "") -- 2104
	if code == "" then -- 2104
		return { -- 2106
			success = false, -- 2106
			mode = "lua", -- 2106
			output = "", -- 2106
			message = "missing code", -- 2106
			phase = "validate" -- 2106
		} -- 2106
	end -- 2106
	local output = {} -- 2108
	local env = setmetatable( -- 2109
		{ -- 2109
			projectDir = req.workDir, -- 2110
			print = function(...) -- 2111
				local values = {...} -- 2111
				local parts = {} -- 2112
				do -- 2112
					local i = 0 -- 2113
					while i < #values do -- 2113
						parts[#parts + 1] = tostring(values[i + 1]) -- 2114
						i = i + 1 -- 2113
					end -- 2113
				end -- 2113
				output[#output + 1] = table.concat(parts, "\t") -- 2116
			end, -- 2111
			refreshTree = function(path) -- 2118
				if path == nil then -- 2118
					return refreshProjectTree(req.workDir) -- 2120
				end -- 2120
				if type(path) ~= "string" then -- 2120
					error("refreshTree expects a project-relative file path string or no argument") -- 2123
				end -- 2123
				return refreshProjectTree(req.workDir, path) -- 2125
			end -- 2118
		}, -- 2118
		{__index = Dora} -- 2127
	) -- 2127
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 2130
	if not fn then -- 2130
		return { -- 2132
			success = false, -- 2133
			mode = "lua", -- 2134
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2135
			message = toStr(compileErr), -- 2136
			phase = "compile" -- 2137
		} -- 2137
	end -- 2137
	local ok, runtimeErr = pcall(fn) -- 2140
	if not ok then -- 2140
		return { -- 2142
			success = false, -- 2143
			mode = "lua", -- 2144
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2145
			message = toStr(runtimeErr), -- 2146
			phase = "execute" -- 2147
		} -- 2147
	end -- 2147
	return { -- 2150
		success = true, -- 2150
		mode = "lua", -- 2150
		output = truncateCommandOutput(table.concat(output, "\n")) -- 2150
	} -- 2150
end -- 2103
local function formatGitStatusOutput(status) -- 2153
	if not status then -- 2153
		return "" -- 2154
	end -- 2154
	local lines = {} -- 2155
	local state = toStr(status.state) -- 2156
	local kind = toStr(status.kind) -- 2157
	local message = toStr(status.message) -- 2158
	local errorMessage = toStr(status.error) -- 2159
	if kind ~= "" or state ~= "" then -- 2159
		lines[#lines + 1] = table.concat( -- 2161
			__TS__ArrayFilter( -- 2161
				{kind, state}, -- 2161
				function(____, item) return item ~= "" end -- 2161
			), -- 2161
			": " -- 2161
		) -- 2161
	end -- 2161
	if message ~= "" then -- 2161
		lines[#lines + 1] = message -- 2163
	end -- 2163
	if errorMessage ~= "" then -- 2163
		lines[#lines + 1] = errorMessage -- 2164
	end -- 2164
	local data = status.data -- 2165
	if data ~= nil then -- 2165
		local dataText = encodeJSON(data) -- 2167
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 2168
	end -- 2168
	return truncateCommandOutput(table.concat(lines, "\n")) -- 2170
end -- 2153
local function emitGitProgress(mode, operationId, onProgress, status) -- 2173
	if not onProgress then -- 2173
		return -- 2179
	end -- 2179
	local progress = type(status.progress) == "number" and status.progress or nil -- 2180
	local kind = toStr(status.kind) -- 2181
	local message = toStr(status.message) -- 2182
	local state = toStr(status.state) -- 2183
	local jobId = type(status.id) == "number" and status.id or nil -- 2184
	onProgress({ -- 2185
		state = "running", -- 2186
		mode = mode, -- 2187
		operationId = operationId, -- 2188
		stage = kind ~= "" and kind or "git", -- 2189
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 2190
		progress = progress, -- 2191
		jobId = jobId, -- 2192
		gitState = state ~= "" and state or nil, -- 2193
		gitKind = kind ~= "" and kind or nil -- 2194
	}) -- 2194
end -- 2173
local function cloneGitToTarget(req) -- 2198
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2198
		local parsed = parseGitCloneCommand(req.command) -- 2206
		if parsed == nil then -- 2206
			return ____awaiter_resolve(nil, nil) -- 2206
		end -- 2206
		if not parsed.success then -- 2206
			return ____awaiter_resolve(nil, { -- 2206
				success = false, -- 2209
				mode = "git", -- 2209
				output = "", -- 2209
				message = parsed.message, -- 2209
				phase = "validate" -- 2209
			}) -- 2209
		end -- 2209
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 2211
		if not target then -- 2211
			return ____awaiter_resolve(nil, { -- 2211
				success = false, -- 2213
				mode = "git", -- 2213
				output = "", -- 2213
				message = "invalid clone target path", -- 2213
				phase = "validate" -- 2213
			}) -- 2213
		end -- 2213
		if Content:exist(target) then -- 2213
			return ____awaiter_resolve(nil, { -- 2213
				success = false, -- 2216
				mode = "git", -- 2216
				output = "", -- 2216
				message = "target already exists", -- 2216
				phase = "validate" -- 2216
			}) -- 2216
		end -- 2216
		local targetParent = Path:getPath(target) -- 2218
		if not ensureDirPath(targetParent) then -- 2218
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 2218
		end -- 2218
		local tempRoot = getAgentDownloadTempRoot() -- 2222
		if not ensureDirPath(tempRoot) then -- 2222
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 2222
		end -- 2222
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 2226
		Content:remove(tempPath) -- 2227
		local depth = parsed.depth or "1" -- 2228
		local ____array_33 = __TS__SparseArrayNew( -- 2228
			"clone", -- 2230
			quoteGitArg(parsed.url), -- 2231
			quoteGitArg(Path:getFilename(tempPath)), -- 2232
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 2233
				"-b", -- 2233
				quoteGitArg(parsed.ref) -- 2233
			}) or ({})) -- 2233
		) -- 2233
		__TS__SparseArrayPush( -- 2233
			____array_33, -- 2233
			table.unpack(depth ~= "" and ({ -- 2234
				"--depth",
				quoteGitArg(depth) -- 2234
			}) or ({})) -- 2234
		) -- 2234
		local command = table.concat( -- 2229
			{__TS__SparseArraySpread(____array_33)}, -- 2229
			" " -- 2235
		) -- 2235
		local ____this_35 -- 2235
		____this_35 = req -- 2236
		local ____opt_34 = ____this_35.onProgress -- 2236
		if ____opt_34 ~= nil then -- 2236
			____opt_34(____this_35, { -- 2236
				state = "pending", -- 2237
				mode = "git", -- 2238
				operationId = req.operationId, -- 2239
				stage = "clone", -- 2240
				message = "clone pending", -- 2241
				progress = 0 -- 2242
			}) -- 2242
		end -- 2242
		local gitRes = __TS__Await(runGitAndWait( -- 2244
			tempRoot, -- 2245
			command, -- 2246
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2247
			function() -- 2248
				local ____this_37 -- 2248
				____this_37 = req -- 2248
				local ____opt_36 = ____this_37.isCancelled -- 2248
				return (____opt_36 and ____opt_36(____this_37)) == true -- 2248
			end, -- 2248
			req.timeoutSeconds -- 2249
		)) -- 2249
		if not gitRes.success then -- 2249
			local cleanupError = cleanupPath(tempPath) -- 2252
			local ____formatGitStatusOutput_result_41 = formatGitStatusOutput(gitRes.status) -- 2256
			local ____temp_42 = gitRes.message or "git clone failed" -- 2257
			local ____gitRes_interrupted_40 = gitRes.interrupted -- 2258
			if not ____gitRes_interrupted_40 then -- 2258
				local ____this_39 -- 2258
				____this_39 = req -- 2258
				local ____opt_38 = ____this_39.isCancelled -- 2258
				____gitRes_interrupted_40 = (____opt_38 and ____opt_38(____this_39)) == true -- 2258
			end -- 2258
			return ____awaiter_resolve(nil, { -- 2258
				success = false, -- 2254
				mode = "git", -- 2255
				output = ____formatGitStatusOutput_result_41, -- 2256
				message = ____temp_42, -- 2257
				interrupted = ____gitRes_interrupted_40, -- 2258
				cleanupError = cleanupError -- 2259
			}) -- 2259
		end -- 2259
		if not Content:move(tempPath, target) then -- 2259
			local cleanupError = cleanupPath(tempPath) -- 2263
			return ____awaiter_resolve( -- 2263
				nil, -- 2263
				{ -- 2264
					success = false, -- 2264
					mode = "git", -- 2264
					output = formatGitStatusOutput(gitRes.status), -- 2264
					message = "failed to move cloned repository into target path", -- 2264
					cleanupError = cleanupError -- 2264
				} -- 2264
			) -- 2264
		end -- 2264
		if not refreshProjectTree(req.workDir) then -- 2264
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 2267
		end -- 2267
		local commit = getGitHeadCommit(target) -- 2269
		local output = table.concat( -- 2270
			__TS__ArrayFilter( -- 2270
				{ -- 2270
					formatGitStatusOutput(gitRes.status), -- 2271
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 2271
					commit ~= nil and "commit " .. commit or "" -- 2273
				}, -- 2273
				function(____, item) return item ~= "" end -- 2274
			), -- 2274
			"\n" -- 2274
		) -- 2274
		return ____awaiter_resolve( -- 2274
			nil, -- 2274
			{ -- 2275
				success = true, -- 2275
				mode = "git", -- 2275
				output = truncateCommandOutput(output) -- 2275
			} -- 2275
		) -- 2275
	end) -- 2275
end -- 2198
local function executeGitCommand(req) -- 2278
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2278
		local command = normalizeGitCommand(req.command or "") -- 2286
		if command == "" then -- 2286
			return ____awaiter_resolve(nil, { -- 2286
				success = false, -- 2288
				mode = "git", -- 2288
				output = "", -- 2288
				message = "missing command", -- 2288
				phase = "validate" -- 2288
			}) -- 2288
		end -- 2288
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 2290
			workDir = req.workDir, -- 2291
			command = command, -- 2292
			operationId = req.operationId, -- 2293
			timeoutSeconds = req.timeoutSeconds, -- 2294
			onProgress = req.onProgress, -- 2295
			isCancelled = req.isCancelled -- 2296
		})) -- 2296
		if cloneResult ~= nil then -- 2296
			return ____awaiter_resolve(nil, cloneResult) -- 2296
		end -- 2296
		local ____this_44 -- 2296
		____this_44 = req -- 2299
		local ____opt_43 = ____this_44.onProgress -- 2299
		if ____opt_43 ~= nil then -- 2299
			____opt_43(____this_44, { -- 2299
				state = "pending", -- 2300
				mode = "git", -- 2301
				operationId = req.operationId, -- 2302
				stage = "git", -- 2303
				message = "git command pending", -- 2304
				progress = 0 -- 2305
			}) -- 2305
		end -- 2305
		local gitRes = __TS__Await(runGitAndWait( -- 2307
			req.workDir, -- 2308
			command, -- 2309
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2310
			function() -- 2311
				local ____this_46 -- 2311
				____this_46 = req -- 2311
				local ____opt_45 = ____this_46.isCancelled -- 2311
				return (____opt_45 and ____opt_45(____this_46)) == true -- 2311
			end, -- 2311
			req.timeoutSeconds -- 2312
		)) -- 2312
		local output = formatGitStatusOutput(gitRes.status) -- 2314
		if not gitRes.success then -- 2314
			local ____output_50 = output -- 2319
			local ____temp_51 = gitRes.message or "git command failed" -- 2320
			local ____gitRes_interrupted_49 = gitRes.interrupted -- 2321
			if not ____gitRes_interrupted_49 then -- 2321
				local ____this_48 -- 2321
				____this_48 = req -- 2321
				local ____opt_47 = ____this_48.isCancelled -- 2321
				____gitRes_interrupted_49 = (____opt_47 and ____opt_47(____this_48)) == true -- 2321
			end -- 2321
			return ____awaiter_resolve(nil, { -- 2321
				success = false, -- 2317
				mode = "git", -- 2318
				output = ____output_50, -- 2319
				message = ____temp_51, -- 2320
				interrupted = ____gitRes_interrupted_49 -- 2321
			}) -- 2321
		end -- 2321
		return ____awaiter_resolve(nil, {success = true, mode = "git", output = output}) -- 2321
	end) -- 2321
end -- 2278
function ____exports.executeCommand(req) -- 2327
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2327
		local mode = req.mode -- 2336
		if mode ~= "lua" and mode ~= "git" then -- 2336
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 2336
		end -- 2336
		if mode == "lua" then -- 2336
			return ____awaiter_resolve( -- 2336
				nil, -- 2336
				executeLuaCommand({workDir = req.workDir, code = req.code or ""}) -- 2341
			) -- 2341
		end -- 2341
		local operationId = createOperationId() -- 2343
		return ____awaiter_resolve( -- 2343
			nil, -- 2343
			executeGitCommand({ -- 2344
				workDir = req.workDir, -- 2345
				command = req.command or "", -- 2346
				timeoutSeconds = math.max( -- 2347
					1, -- 2347
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 2347
				), -- 2347
				operationId = operationId, -- 2348
				onProgress = req.onProgress, -- 2349
				isCancelled = req.isCancelled -- 2350
			}) -- 2350
		) -- 2350
	end) -- 2350
end -- 2327
function ____exports.fetchUrl(req) -- 2354
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2354
		local mode = "download" -- 2361
		local url = __TS__StringTrim(req.url or "") -- 2362
		local targetRel = __TS__StringTrim(req.target or "") -- 2363
		if not isHttpUrl(url) then -- 2363
			return ____awaiter_resolve(nil, { -- 2363
				success = false, -- 2365
				state = "failed", -- 2365
				mode = mode, -- 2365
				target = targetRel, -- 2365
				message = "fetch_url only supports http:// and https:// URLs" -- 2365
			}) -- 2365
		end -- 2365
		if targetRel == "" then -- 2365
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 2365
		end -- 2365
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 2370
		if not target then -- 2370
			return ____awaiter_resolve(nil, { -- 2370
				success = false, -- 2372
				state = "failed", -- 2372
				mode = mode, -- 2372
				target = targetRel, -- 2372
				message = "invalid target path" -- 2372
			}) -- 2372
		end -- 2372
		if Content:exist(target) then -- 2372
			return ____awaiter_resolve(nil, { -- 2372
				success = false, -- 2375
				state = "failed", -- 2375
				mode = mode, -- 2375
				target = targetRel, -- 2375
				message = "target already exists" -- 2375
			}) -- 2375
		end -- 2375
		local operationId = createOperationId() -- 2377
		local tempRoot = getAgentDownloadTempRoot() -- 2378
		if not ensureDirPath(tempRoot) then -- 2378
			return ____awaiter_resolve(nil, { -- 2378
				success = false, -- 2380
				state = "failed", -- 2380
				mode = mode, -- 2380
				target = targetRel, -- 2380
				message = "failed to create agent download temp directory" -- 2380
			}) -- 2380
		end -- 2380
		local tempPath = Path(tempRoot, operationId .. ".download") -- 2382
		Content:remove(tempPath) -- 2383
		local function emitProgress(progress) -- 2384
			if not req.onProgress then -- 2384
				return -- 2385
			end -- 2385
			req:onProgress(__TS__ObjectAssign({ -- 2386
				state = "running", -- 2387
				mode = mode, -- 2388
				operationId = operationId, -- 2389
				target = targetRel, -- 2390
				tempPath = tempPath -- 2391
			}, progress)) -- 2391
		end -- 2384
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 2395
		local function interrupted() -- 2400
			local ____this_53 -- 2400
			____this_53 = req -- 2400
			local ____opt_52 = ____this_53.isCancelled -- 2400
			return (____opt_52 and ____opt_52(____this_53)) == true -- 2400
		end -- 2400
		if not ensureDirForFile(tempPath) then -- 2400
			return ____awaiter_resolve(nil, { -- 2400
				success = false, -- 2402
				state = "failed", -- 2402
				mode = mode, -- 2402
				target = targetRel, -- 2402
				message = "failed to create temporary file directory" -- 2402
			}) -- 2402
		end -- 2402
		local downloadRes = __TS__Await(downloadFile({ -- 2404
			url = url, -- 2405
			tempPath = tempPath, -- 2406
			timeout = 600, -- 2407
			isCancelled = interrupted, -- 2408
			onProgress = function(____, current, total) -- 2409
				local totalNumber = type(total) == "number" and total or 0 -- 2410
				emitProgress({ -- 2411
					stage = "download", -- 2412
					message = "downloading", -- 2413
					current = current, -- 2414
					total = total, -- 2415
					progress = totalNumber > 0 and current / totalNumber or nil -- 2416
				}) -- 2416
			end -- 2409
		})) -- 2409
		if not downloadRes.success then -- 2409
			local cleanupError = cleanupPath(tempPath) -- 2421
			return ____awaiter_resolve( -- 2421
				nil, -- 2421
				{ -- 2422
					success = false, -- 2423
					state = "failed", -- 2424
					mode = mode, -- 2425
					target = targetRel, -- 2426
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 2427
					interrupted = downloadRes.interrupted or interrupted(), -- 2428
					cleanupError = cleanupError -- 2429
				} -- 2429
			) -- 2429
		end -- 2429
		if not ensureDirForFile(target) then -- 2429
			local cleanupError = cleanupPath(tempPath) -- 2433
			return ____awaiter_resolve(nil, { -- 2433
				success = false, -- 2434
				state = "failed", -- 2434
				mode = mode, -- 2434
				target = targetRel, -- 2434
				message = "failed to create target directory", -- 2434
				cleanupError = cleanupError -- 2434
			}) -- 2434
		end -- 2434
		if not Content:move(tempPath, target) then -- 2434
			local cleanupError = cleanupPath(tempPath) -- 2437
			return ____awaiter_resolve(nil, { -- 2437
				success = false, -- 2438
				state = "failed", -- 2438
				mode = mode, -- 2438
				target = targetRel, -- 2438
				message = "failed to move downloaded file into target path", -- 2438
				cleanupError = cleanupError -- 2438
			}) -- 2438
		end -- 2438
		local bytesWritten = downloadRes.bytesWritten -- 2440
		local ____try = __TS__AsyncAwaiter(function() -- 2440
			local size = Content:getAttr(target) -- 2442
			if bytesWritten == nil or bytesWritten <= 0 then -- 2442
				bytesWritten = type(size) == "number" and size or nil -- 2444
			end -- 2444
		end) -- 2444
		____try = ____try.catch( -- 2444
			____try, -- 2444
			function(____, _) -- 2444
				return __TS__AsyncAwaiter(function() -- 2444
				end) -- 2444
			end -- 2444
		) -- 2444
		__TS__Await(____try) -- 2441
		if bytesWritten == nil or bytesWritten <= 0 then -- 2441
			local ____try = __TS__AsyncAwaiter(function() -- 2441
				local loaded = Content:load(target) -- 2451
				if type(loaded) == "string" then -- 2451
					bytesWritten = #loaded -- 2453
				end -- 2453
			end) -- 2453
			____try = ____try.catch( -- 2453
				____try, -- 2453
				function(____, _) -- 2453
					return __TS__AsyncAwaiter(function() -- 2453
					end) -- 2453
				end -- 2453
			) -- 2453
			__TS__Await(____try) -- 2450
		end -- 2450
		if not syncDownloadedFileToWebIDE(target) then -- 2450
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 2460
		end -- 2460
		return ____awaiter_resolve(nil, { -- 2460
			success = true, -- 2462
			state = "done", -- 2462
			mode = mode, -- 2462
			target = targetRel, -- 2462
			bytesWritten = bytesWritten -- 2462
		}) -- 2462
	end) -- 2462
end -- 2354
return ____exports -- 2354