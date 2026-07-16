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
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local ____exports = {} -- 1
local normalizeEscapedGitQuotes, getEngineLogText, ensureSafeSearchGlobs, ENGINE_LOG_DOWNLOAD_DIR, ENGINE_LOG_FILE, extensionLevels -- 1
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
function normalizeEscapedGitQuotes(command) -- 586
	local result = "" -- 587
	do -- 587
		local i = 0 -- 588
		while i < #command do -- 588
			do -- 588
				local ch = __TS__StringCharAt(command, i) -- 589
				local next = __TS__StringCharAt(command, i + 1) -- 590
				if ch == "\\" and (next == "\"" or next == "'") then -- 590
					result = result .. next -- 592
					i = i + 1 -- 593
					goto __continue86 -- 594
				end -- 594
				result = result .. ch -- 596
			end -- 596
			::__continue86:: -- 596
			i = i + 1 -- 588
		end -- 588
	end -- 588
	return result -- 598
end -- 598
function getEngineLogText() -- 1428
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 1429
	if not Content:exist(folder) then -- 1429
		Content:mkdir(folder) -- 1431
	end -- 1431
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 1433
	if not App:saveLog(logPath) then -- 1433
		return nil -- 1435
	end -- 1435
	return Content:load(logPath) -- 1437
end -- 1437
function ensureSafeSearchGlobs(globs) -- 1577
	local result = {} -- 1578
	do -- 1578
		local i = 0 -- 1579
		while i < #globs do -- 1579
			result[#result + 1] = globs[i + 1] -- 1580
			i = i + 1 -- 1579
		end -- 1579
	end -- 1579
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1582
	do -- 1582
		local i = 0 -- 1583
		while i < #requiredExcludes do -- 1583
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1583
				result[#result + 1] = requiredExcludes[i + 1] -- 1585
			end -- 1585
			i = i + 1 -- 1583
		end -- 1583
	end -- 1583
	return result -- 1588
end -- 1588
local TABLE_TASK = "AgentTask" -- 324
local TABLE_CP = "AgentCheckpoint" -- 325
local TABLE_ENTRY = "AgentCheckpointEntry" -- 326
ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 327
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 328
local AGENT_DOWNLOAD_TEMP_DIR = "agent" -- 329
local function now() -- 330
	return os.time() -- 330
end -- 330
local function toBool(v) -- 332
	return v ~= 0 and v ~= false and v ~= nil -- 333
end -- 332
local function toStr(v) -- 336
	if v == false or v == nil then -- 336
		return "" -- 337
	end -- 337
	return tostring(v) -- 338
end -- 336
local function isValidWorkspacePath(path) -- 341
	if not path or #path == 0 then -- 341
		return false -- 342
	end -- 342
	if Content:isAbsolutePath(path) then -- 342
		return false -- 343
	end -- 343
	if __TS__StringIncludes(path, "..") then -- 343
		return false -- 344
	end -- 344
	return true -- 345
end -- 341
local function isValidWorkDir(workDir) -- 348
	if not workDir or #workDir == 0 then -- 348
		return false -- 349
	end -- 349
	if not Content:isAbsolutePath(workDir) then -- 349
		return false -- 350
	end -- 350
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 350
		return false -- 351
	end -- 351
	return true -- 352
end -- 348
local function isValidSearchPath(path) -- 355
	if path == "" then -- 355
		return true -- 356
	end -- 356
	if Content:isAbsolutePath(path) then -- 356
		return false -- 357
	end -- 357
	if not path or #path == 0 then -- 357
		return false -- 358
	end -- 358
	if __TS__StringIncludes(path, "..") then -- 358
		return false -- 359
	end -- 359
	return true -- 360
end -- 355
local function resolveWorkspaceFilePath(workDir, path) -- 363
	if not isValidWorkDir(workDir) then -- 363
		return nil -- 364
	end -- 364
	if not isValidWorkspacePath(path) then -- 364
		return nil -- 365
	end -- 365
	return Path(workDir, path) -- 366
end -- 363
local function resolveWorkspaceSearchPath(workDir, path) -- 369
	if not isValidWorkDir(workDir) then -- 369
		return nil -- 370
	end -- 370
	if not isValidSearchPath(path) then -- 370
		return nil -- 371
	end -- 371
	return path == "" and workDir or Path(workDir, path) -- 372
end -- 369
local function toWorkspaceRelativePath(workDir, path) -- 375
	if not path or #path == 0 then -- 375
		return path -- 376
	end -- 376
	if not Content:isAbsolutePath(path) then -- 376
		return path -- 377
	end -- 377
	return Path:getRelative(path, workDir) -- 378
end -- 375
local function toWorkspaceRelativeFileList(workDir, files) -- 381
	return __TS__ArrayMap( -- 382
		files, -- 382
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 382
	) -- 382
end -- 381
local function toWorkspaceRelativeSearchResults(workDir, results) -- 385
	local mapped = {} -- 386
	do -- 386
		local i = 0 -- 387
		while i < #results do -- 387
			local row = results[i + 1] -- 388
			local clone = __TS__ObjectAssign({}, row) -- 389
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 390
			mapped[#mapped + 1] = clone -- 391
			i = i + 1 -- 387
		end -- 387
	end -- 387
	return mapped -- 393
end -- 385
local function resolveWorkspaceDirectoryPath(workDir, path) -- 396
	local relative = __TS__StringTrim(path or "") -- 397
	if relative == "" then -- 397
		return {success = true, path = workDir, relative = "."} -- 399
	end -- 399
	if not isValidWorkDir(workDir) or not isValidWorkspacePath(relative) then -- 399
		return {success = false, message = "invalid cwd path"} -- 402
	end -- 402
	local resolved = Path(workDir, relative) -- 404
	if not Content:exist(resolved) then -- 404
		return {success = false, message = "cwd does not exist"} -- 406
	end -- 406
	if not Content:isdir(resolved) then -- 406
		return {success = false, message = "cwd is not a directory"} -- 409
	end -- 409
	return {success = true, path = resolved, relative = relative} -- 411
end -- 396
local function getDoraAPIDocRoot(docLanguage) -- 414
	local zhDir = Path( -- 415
		Content.assetPath, -- 415
		"Script", -- 415
		"Lib", -- 415
		"Dora", -- 415
		"zh-Hans" -- 415
	) -- 415
	local enDir = Path( -- 416
		Content.assetPath, -- 416
		"Script", -- 416
		"Lib", -- 416
		"Dora", -- 416
		"en" -- 416
	) -- 416
	return docLanguage == "zh" and zhDir or enDir -- 417
end -- 414
local function getDoraTutorialDocRoot(docLanguage) -- 420
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 421
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 422
	return docLanguage == "zh" and zhDir or enDir -- 423
end -- 420
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 426
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 426
		return {"ts"} -- 428
	end -- 428
	return {"tl"} -- 430
end -- 426
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 433
	repeat -- 433
		local ____switch43 = programmingLanguage -- 433
		local ____cond43 = ____switch43 == "teal" -- 433
		if ____cond43 then -- 433
			return "tl" -- 435
		end -- 435
		____cond43 = ____cond43 or ____switch43 == "tl" -- 435
		if ____cond43 then -- 435
			return "tl" -- 436
		end -- 436
		do -- 436
			return programmingLanguage -- 437
		end -- 437
	until true -- 437
end -- 433
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 441
	if docSource == "tutorial" then -- 441
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 447
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 448
		return { -- 449
			root = Path(tutorialRoot, langDir), -- 450
			exts = {"md"}, -- 451
			globs = {"**/*.md"} -- 452
		} -- 452
	end -- 452
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 455
	return { -- 456
		root = getDoraAPIDocRoot(docLanguage), -- 457
		exts = exts, -- 458
		globs = __TS__ArrayMap( -- 459
			exts, -- 459
			function(____, ext) return "**/*." .. ext end -- 459
		) -- 459
	} -- 459
end -- 441
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 463
	if docSource == "tutorial" then -- 463
		return getDoraTutorialDocRoot(docLanguage) -- 465
	end -- 465
	return getDoraAPIDocRoot(docLanguage) -- 467
end -- 463
local function toDocRelativePath(baseRoot, path) -- 470
	if not path or #path == 0 then -- 470
		return path -- 471
	end -- 471
	if not Content:isAbsolutePath(path) then -- 471
		return path -- 472
	end -- 472
	return Path:getRelative(path, baseRoot) -- 473
end -- 470
local function resolveAgentTutorialDocFilePath(path, docLanguage) -- 476
	if not docLanguage then -- 476
		return nil -- 477
	end -- 477
	if not isValidWorkspacePath(path) then -- 477
		return nil -- 478
	end -- 478
	local candidate = Path( -- 479
		getDoraTutorialDocRoot(docLanguage), -- 479
		path -- 479
	) -- 479
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 479
		return candidate -- 481
	end -- 481
	return nil -- 483
end -- 476
local function ensureDirPath(dir) -- 486
	if not dir or dir == "." or dir == "" then -- 486
		return true -- 487
	end -- 487
	if Content:exist(dir) then -- 487
		return Content:isdir(dir) -- 488
	end -- 488
	local parent = Path:getPath(dir) -- 489
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 489
		if not ensureDirPath(parent) then -- 489
			return false -- 491
		end -- 491
	end -- 491
	return Content:mkdir(dir) -- 493
end -- 486
local function ensureDirForFile(path) -- 496
	local dir = Path:getPath(path) -- 497
	return ensureDirPath(dir) -- 498
end -- 496
local function isHttpUrl(url) -- 501
	local normalized = string.lower(__TS__StringTrim(url)) -- 502
	return __TS__StringStartsWith(normalized, "http://") or __TS__StringStartsWith(normalized, "https://") -- 503
end -- 501
local function createOperationId() -- 506
	local raw = (tostring(os.time()) .. "-") .. tostring(math.floor(math.random() * 1000000000)) -- 507
	local safe = string.gsub(raw, "[^%w%-_]", "-") -- 508
	return safe -- 509
end -- 506
local function getAgentDownloadTempRoot() -- 512
	return Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR, AGENT_DOWNLOAD_TEMP_DIR) -- 513
end -- 512
local function cleanupPath(path) -- 516
	if not path or path == "" or not Content:exist(path) then -- 516
		return nil -- 517
	end -- 517
	if Content:remove(path) then -- 517
		return nil -- 518
	end -- 518
	return "failed to remove temporary path: " .. path -- 519
end -- 516
local function quoteGitArg(value) -- 522
	local plain = string.match(value, "^[%w%._%-%/]+$") -- 523
	if plain ~= nil then -- 523
		return value -- 525
	end -- 525
	local escaped = string.gsub(value, "\\", "\\\\") -- 527
	escaped = string.gsub(escaped, "\"", "\\\"") -- 528
	return ("\"" .. escaped) .. "\"" -- 529
end -- 522
local function shellSplit(command) -- 532
	local args = {} -- 533
	local current = "" -- 534
	local quote = "" -- 535
	local escaped = false -- 536
	do -- 536
		local i = 0 -- 537
		while i < #command do -- 537
			do -- 537
				local ch = __TS__StringCharAt(command, i) -- 538
				if escaped then -- 538
					current = current .. ch -- 540
					escaped = false -- 541
					goto __continue72 -- 542
				end -- 542
				if ch == "\\" then -- 542
					escaped = true -- 545
					goto __continue72 -- 546
				end -- 546
				if quote ~= "" then -- 546
					if ch == quote then -- 546
						quote = "" -- 550
					else -- 550
						current = current .. ch -- 552
					end -- 552
					goto __continue72 -- 554
				end -- 554
				if ch == "'" or ch == "\"" then -- 554
					quote = ch -- 557
					goto __continue72 -- 558
				end -- 558
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 558
					if current ~= "" then -- 558
						args[#args + 1] = current -- 562
						current = "" -- 563
					end -- 563
					goto __continue72 -- 565
				end -- 565
				current = current .. ch -- 567
			end -- 567
			::__continue72:: -- 567
			i = i + 1 -- 537
		end -- 537
	end -- 537
	if escaped then -- 537
		current = current .. "\\" -- 570
	end -- 570
	if current ~= "" then -- 570
		args[#args + 1] = current -- 573
	end -- 573
	return args -- 575
end -- 532
local function normalizeGitCommand(command) -- 578
	local trimmed = __TS__StringTrim(command) -- 579
	local normalized = string.lower(string.sub(trimmed, 1, 4)) == "git " and __TS__StringTrim(string.sub(trimmed, 5)) or trimmed -- 580
	return normalizeEscapedGitQuotes(normalized) -- 583
end -- 578
local function gitDefaultTargetFromUrl(url) -- 601
	local target = url -- 602
	local hashIndex = (string.find(target, "#", nil, true) or 0) - 1 -- 603
	if hashIndex >= 0 then -- 603
		target = __TS__StringSlice(target, 0, hashIndex) -- 604
	end -- 604
	local queryIndex = (string.find(target, "?", nil, true) or 0) - 1 -- 605
	if queryIndex >= 0 then -- 605
		target = __TS__StringSlice(target, 0, queryIndex) -- 606
	end -- 606
	target = string.gsub(target, "/+$", "") -- 607
	local name = string.match(target, "([^/]+)$") -- 608
	if name ~= nil and name ~= "" then -- 608
		target = name -- 609
	end -- 609
	if __TS__StringEndsWith( -- 609
		string.lower(target), -- 610
		".git" -- 610
	) then -- 610
		target = __TS__StringSlice(target, 0, #target - 4) -- 611
	end -- 611
	return target ~= "" and target or "repo" -- 613
end -- 601
local function parseGitCloneCommand(command) -- 616
	local args = shellSplit(normalizeGitCommand(command)) -- 626
	if #args == 0 or args[1] ~= "clone" then -- 626
		return nil -- 627
	end -- 627
	local url = "" -- 628
	local target = "" -- 629
	local ref -- 630
	local depth -- 631
	do -- 631
		local i = 1 -- 632
		while i < #args do -- 632
			do -- 632
				local arg = args[i + 1] -- 633
				if arg == "-b" or arg == "--branch" then
					i = i + 1 -- 635
					if i >= #args then -- 635
						return {success = false, message = arg .. " requires a value"} -- 636
					end -- 636
					ref = args[i + 1] -- 637
					goto __continue96 -- 638
				end -- 638
				if arg == "--depth" then
					i = i + 1 -- 641
					if i >= #args then -- 641
						return {success = false, message = "--depth requires a value"}
					end -- 642
					depth = args[i + 1] -- 643
					goto __continue96 -- 644
				end -- 644
				if __TS__StringStartsWith(arg, "--depth=") then
					depth = __TS__StringSlice(arg, #"--depth=")
					goto __continue96 -- 648
				end -- 648
				if __TS__StringStartsWith(arg, "-") then -- 648
					return {success = false, message = "unsupported clone option: " .. arg} -- 651
				end -- 651
				if url == "" then -- 651
					url = arg -- 654
					goto __continue96 -- 655
				end -- 655
				if target == "" then -- 655
					target = arg -- 658
					goto __continue96 -- 659
				end -- 659
				return {success = false, message = "unexpected clone argument: " .. arg} -- 661
			end -- 661
			::__continue96:: -- 661
			i = i + 1 -- 632
		end -- 632
	end -- 632
	if url == "" then -- 632
		return {success = false, message = "git clone requires a URL"} -- 663
	end -- 663
	if not isHttpUrl(url) then -- 663
		return {success = false, message = "git clone only supports http:// and https:// URLs"} -- 664
	end -- 664
	if target == "" then -- 664
		target = gitDefaultTargetFromUrl(url) -- 665
	end -- 665
	return { -- 666
		success = true, -- 667
		url = url, -- 668
		target = target, -- 669
		ref = ref, -- 670
		depth = depth ~= nil and depth ~= "" and depth or "1" -- 671
	} -- 671
end -- 616
local function getGitHeadCommit(repoPath) -- 675
	local headPath = Path(repoPath, ".git", "HEAD") -- 676
	if not Content:exist(headPath) then -- 676
		return nil -- 677
	end -- 677
	local head = __TS__StringTrim(toStr(Content:load(headPath))) -- 678
	local ref = string.match(head, "^ref:%s*(.-)%s*$") -- 679
	if ref ~= nil and ref ~= "" then -- 679
		local refPath = Path(repoPath, ".git", ref) -- 681
		if Content:exist(refPath) then -- 681
			local commit = __TS__StringTrim(toStr(Content:load(refPath))) -- 683
			return commit ~= "" and commit or nil -- 684
		end -- 684
		return nil -- 686
	end -- 686
	return head ~= "" and head or nil -- 688
end -- 675
local function runGitAndWait(repoPath, command, onStatus, isCancelled, timeout) -- 691
	if timeout == nil then -- 691
		timeout = 600 -- 696
	end -- 696
	return __TS__New( -- 698
		__TS__Promise, -- 698
		function(____, resolve) -- 698
			local status -- 699
			local jobId = 0 -- 700
			local settled = false -- 701
			local canceled = false -- 702
			local function finish(result) -- 703
				if settled then -- 703
					return -- 704
				end -- 704
				settled = true -- 705
				resolve(nil, result) -- 706
			end -- 703
			local function finishFromStatus() -- 708
				local state = toStr(status and status.state) -- 709
				if state == "done" then -- 709
					finish({success = true, status = status}) -- 711
					return true -- 712
				end -- 712
				if state == "error" or state == "canceled" then -- 712
					local errorMessage = toStr(status and status.error) -- 715
					local statusMessage = toStr(status and status.message) -- 716
					finish({success = false, message = errorMessage ~= "" and errorMessage or (statusMessage ~= "" and statusMessage or (state == "canceled" and "git command canceled" or "git command failed")), status = status, interrupted = state == "canceled"}) -- 717
					return true -- 723
				end -- 723
				return false -- 725
			end -- 708
			jobId = Git:run( -- 727
				repoPath, -- 727
				command, -- 727
				function(nextStatus) -- 727
					status = nextStatus -- 728
					if onStatus then -- 728
						onStatus(status) -- 729
					end -- 729
					return finishFromStatus() -- 730
				end, -- 727
				"" -- 731
			) -- 731
			if jobId == nil or jobId <= 0 then -- 731
				finish({success = false, message = "failed to start git command"}) -- 733
				return -- 734
			end -- 734
			if not status then -- 734
				local kind = string.match(command, "^(%S+)") -- 737
				status = { -- 738
					id = jobId, -- 739
					state = "queued", -- 740
					kind = toStr(kind), -- 741
					repoPath = repoPath, -- 742
					progress = 0, -- 743
					message = "queued" -- 744
				} -- 744
			end -- 744
			if onStatus then -- 744
				onStatus(status) -- 747
			end -- 747
			local startedAt = os.time() -- 748
			local lastEmitAt = startedAt -- 749
			Director.systemScheduler:schedule(function() -- 750
				if settled then -- 750
					return true -- 751
				end -- 751
				if not canceled and isCancelled and isCancelled() then -- 751
					canceled = true -- 753
					Git:cancel(jobId) -- 754
					finish({success = false, message = "git command canceled", status = status, interrupted = true}) -- 755
					return true -- 756
				end -- 756
				if finishFromStatus() then -- 756
					return true -- 758
				end -- 758
				local nowTime = os.time() -- 759
				if nowTime - startedAt >= timeout then -- 759
					Git:cancel(jobId) -- 761
					finish({success = false, message = "git command timed out", status = status}) -- 762
					return true -- 763
				end -- 763
				if onStatus and status and nowTime > lastEmitAt then -- 763
					lastEmitAt = nowTime -- 766
					onStatus(status) -- 767
				end -- 767
				return false -- 769
			end) -- 750
		end -- 698
	) -- 698
end -- 691
local function downloadFile(req) -- 774
	return __TS__New( -- 781
		__TS__Promise, -- 781
		function(____, resolve) -- 781
			local requestId = 0 -- 782
			local settled = false -- 783
			local bytesWritten = 0 -- 784
			local function finish(result) -- 785
				if settled then -- 785
					return -- 786
				end -- 786
				settled = true -- 787
				requestId = 0 -- 788
				resolve(nil, result) -- 789
			end -- 785
			Director.systemScheduler:schedule(function() -- 791
				if settled then -- 791
					return true -- 792
				end -- 792
				local ____this_7 -- 792
				____this_7 = req -- 793
				local ____opt_6 = ____this_7.isCancelled -- 793
				if (____opt_6 and ____opt_6(____this_7)) == true and requestId ~= 0 then -- 793
					HttpClient:cancel(requestId) -- 794
					finish({success = false, interrupted = true, message = "download canceled"}) -- 795
					return true -- 796
				end -- 796
				if requestId ~= 0 and not HttpClient:isRequestActive(requestId) then -- 796
					finish({success = false, message = "download request ended without a completion callback"}) -- 799
					return true -- 800
				end -- 800
				return false -- 802
			end) -- 791
			Director.systemScheduler:schedule(once(function() -- 804
				requestId = HttpClient:download( -- 805
					req.url, -- 805
					req.tempPath, -- 805
					req.timeout, -- 805
					function(interrupted, current, total) -- 805
						if type(current) == "number" and current > bytesWritten then -- 805
							bytesWritten = current -- 807
						end -- 807
						if interrupted then -- 807
							finish({success = false, interrupted = true, message = "download failed"}) -- 810
							return true -- 811
						end -- 811
						local ____this_9 -- 811
						____this_9 = req -- 813
						local ____opt_8 = ____this_9.isCancelled -- 813
						if (____opt_8 and ____opt_8(____this_9)) == true then -- 813
							finish({success = false, interrupted = true, message = "download canceled"}) -- 814
							return true -- 815
						end -- 815
						if current == total then -- 815
							finish({success = true, bytesWritten = bytesWritten}) -- 818
							return false -- 819
						end -- 819
						req:onProgress(current, total) -- 821
						return false -- 822
					end -- 805
				) -- 805
				if requestId == 0 then -- 805
					finish({success = false, message = "failed to schedule download request"}) -- 825
				else -- 825
					local ____this_11 -- 825
					____this_11 = req -- 826
					local ____opt_10 = ____this_11.isCancelled -- 826
					if (____opt_10 and ____opt_10(____this_11)) == true then -- 826
						HttpClient:cancel(requestId) -- 827
						finish({success = false, interrupted = true, message = "download canceled"}) -- 828
					end -- 828
				end -- 828
			end)) -- 804
		end -- 781
	) -- 781
end -- 774
local function getFileState(path) -- 834
	local exists = Content:exist(path) -- 835
	if not exists then -- 835
		return {exists = false, content = "", bytes = 0} -- 837
	end -- 837
	if Content:isdir(path) then -- 837
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 844
	end -- 844
	local content = Content:load(path) -- 851
	if type(content) ~= "string" then -- 851
		return {exists = true, content = "", bytes = 0} -- 853
	end -- 853
	return {exists = true, content = content, bytes = #content} -- 859
end -- 834
local function inspectReadableFile(path) -- 866
	do -- 866
		local function ____catch(e) -- 866
			Log( -- 888
				"Warn", -- 888
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 888
			) -- 888
			return true, {success = true} -- 889
		end -- 889
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 889
			local size, isBinary = Content:getAttr(path) -- 868
			if size == nil then -- 868
				return true, {success = false, message = "failed to read file"} -- 870
			end -- 870
			if isBinary then -- 870
				return true, { -- 876
					success = false, -- 877
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 878
					size = type(size) == "number" and size or nil, -- 879
					isBinary = true -- 880
				} -- 880
			end -- 880
			return true, { -- 883
				success = true, -- 884
				size = type(size) == "number" and size or nil -- 885
			} -- 885
		end) -- 885
		if not ____try then -- 885
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 885
		end -- 885
		if ____hasReturned then -- 885
			return ____returnValue -- 867
		end -- 867
	end -- 867
end -- 866
local function isEngineLogFilePath(path) -- 893
	return path == ENGINE_LOG_FILE -- 894
end -- 893
local function readEngineLogFile(path) -- 897
	if not isEngineLogFilePath(path) then -- 897
		return nil -- 898
	end -- 898
	local content = getEngineLogText() -- 899
	if content == nil then -- 899
		return {success = false, message = "failed to read engine logs"} -- 901
	end -- 901
	return {success = true, content = content, size = #content} -- 903
end -- 897
local function queryOne(sql, args) -- 906
	local ____args_12 -- 907
	if args then -- 907
		____args_12 = DB:query(sql, args) -- 907
	else -- 907
		____args_12 = DB:query(sql) -- 907
	end -- 907
	local rows = ____args_12 -- 907
	if not rows or #rows == 0 then -- 907
		return nil -- 908
	end -- 908
	return rows[1] -- 909
end -- 906
do -- 906
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 914
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 922
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 933
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 934
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 947
end -- 947
local function isDtsFile(path) -- 950
	return Path:getExt(Path:getName(path)) == "d" -- 951
end -- 950
local function isTiledEditorContent(content) -- 954
	return __TS__StringStartsWith( -- 955
		__TS__StringTrim(content), -- 955
		"<?xml" -- 955
	) -- 955
end -- 954
local function getSupportedBuildKind(path) -- 960
	repeat -- 960
		local ____switch165 = Path:getExt(path) -- 960
		local ____cond165 = ____switch165 == "ts" or ____switch165 == "tsx" -- 960
		if ____cond165 then -- 960
			return "ts" -- 962
		end -- 962
		____cond165 = ____cond165 or ____switch165 == "xml" -- 962
		if ____cond165 then -- 962
			return "xml" -- 963
		end -- 963
		____cond165 = ____cond165 or ____switch165 == "tl" -- 963
		if ____cond165 then -- 963
			return "teal" -- 964
		end -- 964
		____cond165 = ____cond165 or ____switch165 == "lua" -- 964
		if ____cond165 then -- 964
			return "lua" -- 965
		end -- 965
		____cond165 = ____cond165 or ____switch165 == "yue" -- 965
		if ____cond165 then -- 965
			return "yue" -- 966
		end -- 966
		____cond165 = ____cond165 or ____switch165 == "yarn" -- 966
		if ____cond165 then -- 966
			return "yarn" -- 967
		end -- 967
		do -- 967
			return nil -- 968
		end -- 968
	until true -- 968
end -- 960
local function getTaskHeadSeq(taskId) -- 972
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 973
	if not row then -- 973
		return nil -- 974
	end -- 974
	return row[1] or 0 -- 975
end -- 972
local function getTaskStatus(taskId) -- 978
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 979
	if not row then -- 979
		return nil -- 980
	end -- 980
	return toStr(row[1]) -- 981
end -- 978
local function getLastInsertRowId() -- 984
	local row = queryOne("SELECT last_insert_rowid()") -- 985
	return row and (row[1] or 0) or 0 -- 986
end -- 984
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 989
	DB:exec( -- 990
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 990
		{ -- 992
			taskId, -- 992
			seq, -- 992
			status, -- 992
			summary, -- 992
			toolName, -- 992
			now() -- 992
		} -- 992
	) -- 992
	return getLastInsertRowId() -- 994
end -- 989
local function getCheckpointEntries(checkpointId, desc) -- 997
	if desc == nil then -- 997
		desc = false -- 997
	end -- 997
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 998
	if not rows then -- 998
		return {} -- 1005
	end -- 1005
	local result = {} -- 1006
	do -- 1006
		local i = 0 -- 1007
		while i < #rows do -- 1007
			local row = rows[i + 1] -- 1008
			result[#result + 1] = { -- 1009
				id = row[1], -- 1010
				ord = row[2], -- 1011
				path = toStr(row[3]), -- 1012
				op = toStr(row[4]), -- 1013
				beforeExists = toBool(row[5]), -- 1014
				beforeContent = toStr(row[6]), -- 1015
				afterExists = toBool(row[7]), -- 1016
				afterContent = toStr(row[8]) -- 1017
			} -- 1017
			i = i + 1 -- 1007
		end -- 1007
	end -- 1007
	return result -- 1020
end -- 997
local function rejectDuplicatePaths(changes) -- 1023
	local seen = __TS__New(Set) -- 1024
	for ____, change in ipairs(changes) do -- 1025
		local key = change.path -- 1026
		if seen:has(key) then -- 1026
			return key -- 1027
		end -- 1027
		seen:add(key) -- 1028
	end -- 1028
	return nil -- 1030
end -- 1023
local function getLinkedDeletePaths(workDir, path) -- 1033
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1034
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 1034
		return {} -- 1035
	end -- 1035
	local parent = Path:getPath(fullPath) -- 1036
	local baseName = string.lower(Path:getName(fullPath)) -- 1037
	local ext = Path:getExt(fullPath) -- 1038
	local linked = {} -- 1039
	for ____, file in ipairs(Content:getFiles(parent)) do -- 1040
		do -- 1040
			if string.lower(Path:getName(file)) ~= baseName then -- 1040
				goto __continue182 -- 1041
			end -- 1041
			local siblingExt = Path:getExt(file) -- 1042
			if siblingExt == "tl" and ext == "vs" then -- 1042
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1044
					workDir, -- 1044
					Path(parent, file) -- 1044
				) -- 1044
				goto __continue182 -- 1045
			end -- 1045
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 1045
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1048
					workDir, -- 1048
					Path(parent, file) -- 1048
				) -- 1048
			end -- 1048
		end -- 1048
		::__continue182:: -- 1048
	end -- 1048
	return linked -- 1051
end -- 1033
local function expandLinkedDeleteChanges(workDir, changes) -- 1054
	local expanded = {} -- 1055
	local seen = __TS__New(Set) -- 1056
	do -- 1056
		local i = 0 -- 1057
		while i < #changes do -- 1057
			do -- 1057
				local change = changes[i + 1] -- 1058
				if not seen:has(change.path) then -- 1058
					seen:add(change.path) -- 1060
					expanded[#expanded + 1] = change -- 1061
				end -- 1061
				if change.op ~= "delete" then -- 1061
					goto __continue189 -- 1063
				end -- 1063
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 1064
				do -- 1064
					local j = 0 -- 1065
					while j < #linkedPaths do -- 1065
						do -- 1065
							local linkedPath = linkedPaths[j + 1] -- 1066
							if seen:has(linkedPath) then -- 1066
								goto __continue193 -- 1067
							end -- 1067
							seen:add(linkedPath) -- 1068
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 1069
						end -- 1069
						::__continue193:: -- 1069
						j = j + 1 -- 1065
					end -- 1065
				end -- 1065
			end -- 1065
			::__continue189:: -- 1065
			i = i + 1 -- 1057
		end -- 1057
	end -- 1057
	return expanded -- 1072
end -- 1054
local function applySingleFile(path, exists, content) -- 1075
	if exists then -- 1075
		if not ensureDirForFile(path) then -- 1075
			return false -- 1077
		end -- 1077
		return Content:save(path, content) -- 1078
	end -- 1078
	if Content:exist(path) then -- 1078
		return Content:remove(path) -- 1081
	end -- 1081
	return true -- 1083
end -- 1075
local function encodeJSON(obj) -- 1086
	local text = safeJsonEncode(obj) -- 1087
	return text -- 1088
end -- 1086
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 1091
	if HttpServer.wsConnectionCount == 0 then -- 1091
		return true -- 1093
	end -- 1093
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 1095
	if not payload then -- 1095
		return false -- 1097
	end -- 1097
	emit("AppWS", "Send", payload) -- 1099
	return true -- 1100
end -- 1091
function ____exports.sendWebIDERefreshTree() -- 1103
	if HttpServer.wsConnectionCount == 0 then -- 1103
		return true -- 1105
	end -- 1105
	local payload = encodeJSON({name = "RefreshTree"}) -- 1107
	if not payload then -- 1107
		return false -- 1109
	end -- 1109
	emit("AppWS", "Send", payload) -- 1111
	return true -- 1112
end -- 1103
local function syncProjectFileToWebIDE(workDir, path) -- 1115
	local target = resolveWorkspaceFilePath(workDir, path) -- 1116
	if not target then -- 1116
		return false -- 1117
	end -- 1117
	if not Content:exist(target) then -- 1117
		return ____exports.sendWebIDEFileUpdate(target, false, "") -- 1119
	end -- 1119
	if Content:isdir(target) then -- 1119
		return ____exports.sendWebIDERefreshTree() -- 1122
	end -- 1122
	local content = "" -- 1124
	do -- 1124
		local function ____catch(e) -- 1124
			Log( -- 1132
				"Warn", -- 1132
				(("[Agent.Tools] failed to inspect file for Web IDE update file=" .. target) .. ": ") .. tostring(e) -- 1132
			) -- 1132
		end -- 1132
		local ____try, ____hasReturned = pcall(function() -- 1132
			local ____, isBinary = Content:getAttr(target) -- 1126
			if not isBinary then -- 1126
				local loaded = Content:load(target) -- 1128
				content = type(loaded) == "string" and loaded or "" -- 1129
			end -- 1129
		end) -- 1129
		if not ____try then -- 1129
			____catch(____hasReturned) -- 1129
		end -- 1129
	end -- 1129
	return ____exports.sendWebIDEFileUpdate(target, true, content) -- 1134
end -- 1115
local function refreshProjectTree(workDir, path) -- 1137
	local normalized = type(path) == "string" and __TS__StringTrim(path) or "" -- 1138
	if normalized == "" then -- 1138
		return ____exports.sendWebIDERefreshTree() -- 1140
	end -- 1140
	return syncProjectFileToWebIDE(workDir, normalized) -- 1142
end -- 1137
local function syncDownloadedFileToWebIDE(file) -- 1145
	local content = "" -- 1146
	do -- 1146
		local function ____catch(e) -- 1146
			Log( -- 1154
				"Warn", -- 1154
				(("[fetch_url] failed to inspect downloaded file for Web IDE update file=" .. file) .. ": ") .. tostring(e) -- 1154
			) -- 1154
		end -- 1154
		local ____try, ____hasReturned = pcall(function() -- 1154
			local ____, isBinary = Content:getAttr(file) -- 1148
			if not isBinary then -- 1148
				local loaded = Content:load(file) -- 1150
				content = type(loaded) == "string" and loaded or "" -- 1151
			end -- 1151
		end) -- 1151
		if not ____try then -- 1151
			____catch(____hasReturned) -- 1151
		end -- 1151
	end -- 1151
	return ____exports.sendWebIDEFileUpdate(file, true, content) -- 1156
end -- 1145
local function runSingleNonTsBuild(file) -- 1159
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1159
		return ____awaiter_resolve( -- 1159
			nil, -- 1159
			__TS__New( -- 1160
				__TS__Promise, -- 1160
				function(____, resolve) -- 1160
					local moduleName = "Script.Dev.WebServer" -- 1161
					local ____require_result_13 = require(moduleName) -- 1162
					local buildAsync = ____require_result_13.buildAsync -- 1162
					Director.systemScheduler:schedule(once(function() -- 1163
						local result = buildAsync(file) -- 1164
						resolve(nil, result) -- 1165
					end)) -- 1163
				end -- 1160
			) -- 1160
		) -- 1160
	end) -- 1160
end -- 1159
local transpileRequestSeq = 0 -- 1170
function ____exports.runSingleTsTranspile(file, content) -- 1172
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1172
		local done = false -- 1173
		transpileRequestSeq = transpileRequestSeq + 1 -- 1174
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 1175
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 1176
		if HttpServer.wsConnectionCount == 0 then -- 1176
			return ____awaiter_resolve(nil, result) -- 1176
		end -- 1176
		local listener = Node() -- 1184
		listener:gslot( -- 1185
			"AppWS", -- 1185
			function(event) -- 1185
				if event.type ~= "Receive" then -- 1185
					return -- 1186
				end -- 1186
				local res = safeJsonDecode(event.msg) -- 1187
				if not res or __TS__ArrayIsArray(res) then -- 1187
					return -- 1188
				end -- 1188
				local payload = res -- 1189
				if payload.name ~= "TranspileTS" then -- 1189
					return -- 1190
				end -- 1190
				if payload.id ~= requestId then -- 1190
					return -- 1191
				end -- 1191
				if payload.success then -- 1191
					local luaFile = Path:replaceExt(file, "lua") -- 1193
					if Content:save( -- 1193
						luaFile, -- 1194
						tostring(payload.luaCode) -- 1194
					) then -- 1194
						result = {success = true, file = file} -- 1195
					else -- 1195
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 1197
					end -- 1197
				else -- 1197
					result = { -- 1200
						success = false, -- 1200
						file = file, -- 1200
						message = tostring(payload.message) -- 1200
					} -- 1200
				end -- 1200
				done = true -- 1202
			end -- 1185
		) -- 1185
		local payload = encodeJSON({name = "TranspileTS", id = requestId, file = file, content = content}) -- 1204
		if not payload then -- 1204
			listener:removeFromParent() -- 1211
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 1211
		end -- 1211
		__TS__Await(__TS__New( -- 1214
			__TS__Promise, -- 1214
			function(____, resolve) -- 1214
				Director.systemScheduler:schedule(once(function() -- 1215
					emit("AppWS", "Send", payload) -- 1216
					wait(function() return done end) -- 1217
					if not done then -- 1217
						listener:removeFromParent() -- 1219
					end -- 1219
					resolve(nil) -- 1221
				end)) -- 1215
			end -- 1214
		)) -- 1214
		return ____awaiter_resolve(nil, result) -- 1214
	end) -- 1214
end -- 1172
function ____exports.createTask(prompt) -- 1227
	if prompt == nil then -- 1227
		prompt = "" -- 1227
	end -- 1227
	local t = now() -- 1228
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 1229
	if affected <= 0 then -- 1229
		return {success = false, message = "failed to create task"} -- 1234
	end -- 1234
	return { -- 1236
		success = true, -- 1236
		taskId = getLastInsertRowId() -- 1236
	} -- 1236
end -- 1227
function ____exports.setTaskStatus(taskId, status) -- 1239
	DB:exec( -- 1240
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 1240
		{ -- 1240
			status, -- 1240
			now(), -- 1240
			taskId -- 1240
		} -- 1240
	) -- 1240
	Log( -- 1241
		"Info", -- 1241
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 1241
	) -- 1241
end -- 1239
function ____exports.listCheckpoints(taskId) -- 1244
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 1245
	if not rows then -- 1245
		return {} -- 1252
	end -- 1252
	local items = {} -- 1253
	do -- 1253
		local i = 0 -- 1254
		while i < #rows do -- 1254
			local row = rows[i + 1] -- 1255
			items[#items + 1] = { -- 1256
				id = row[1], -- 1257
				taskId = row[2], -- 1258
				seq = row[3], -- 1259
				status = toStr(row[4]), -- 1260
				summary = toStr(row[5]), -- 1261
				toolName = toStr(row[6]), -- 1262
				createdAt = row[7] -- 1263
			} -- 1263
			i = i + 1 -- 1254
		end -- 1254
	end -- 1254
	return items -- 1266
end -- 1244
local function listCheckpointIdsForTask(taskId, desc) -- 1269
	if desc == nil then -- 1269
		desc = false -- 1269
	end -- 1269
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 1270
	if not rows then -- 1270
		return {} -- 1277
	end -- 1277
	local items = {} -- 1278
	do -- 1278
		local i = 0 -- 1279
		while i < #rows do -- 1279
			local row = rows[i + 1] -- 1280
			items[#items + 1] = {id = row[1], seq = row[2]} -- 1281
			i = i + 1 -- 1279
		end -- 1279
	end -- 1279
	return items -- 1286
end -- 1269
local function deriveFileOp(beforeExists, afterExists) -- 1289
	if not beforeExists and afterExists then -- 1289
		return "create" -- 1290
	end -- 1290
	if beforeExists and not afterExists then -- 1290
		return "delete" -- 1291
	end -- 1291
	return "write" -- 1292
end -- 1289
function ____exports.summarizeTaskChangeSet(taskId) -- 1295
	if not getTaskStatus(taskId) then -- 1295
		return {success = false, message = "task not found"} -- 1297
	end -- 1297
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1299
	local filesByPath = {} -- 1300
	local latestCheckpointId = nil -- 1306
	local latestCheckpointSeq = nil -- 1307
	do -- 1307
		local i = 0 -- 1308
		while i < #checkpoints do -- 1308
			local checkpoint = checkpoints[i + 1] -- 1309
			latestCheckpointId = checkpoint.id -- 1310
			latestCheckpointSeq = checkpoint.seq -- 1311
			local entries = getCheckpointEntries(checkpoint.id, false) -- 1312
			do -- 1312
				local j = 0 -- 1313
				while j < #entries do -- 1313
					local entry = entries[j + 1] -- 1314
					local item = filesByPath[entry.path] -- 1315
					if not item then -- 1315
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 1317
						filesByPath[entry.path] = item -- 1323
					end -- 1323
					item.afterExists = entry.afterExists -- 1325
					local ____item_checkpointIds_14 = item.checkpointIds -- 1325
					____item_checkpointIds_14[#____item_checkpointIds_14 + 1] = checkpoint.id -- 1326
					j = j + 1 -- 1313
				end -- 1313
			end -- 1313
			i = i + 1 -- 1308
		end -- 1308
	end -- 1308
	local files = {} -- 1329
	for ____, item in pairs(filesByPath) do -- 1330
		files[#files + 1] = { -- 1331
			path = item.path, -- 1332
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1333
			checkpointCount = #item.checkpointIds, -- 1334
			checkpointIds = item.checkpointIds -- 1335
		} -- 1335
	end -- 1335
	__TS__ArraySort( -- 1338
		files, -- 1338
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1338
	) -- 1338
	return { -- 1339
		success = true, -- 1340
		taskId = taskId, -- 1341
		checkpointCount = #checkpoints, -- 1342
		filesChanged = #files, -- 1343
		files = files, -- 1344
		latestCheckpointId = latestCheckpointId, -- 1345
		latestCheckpointSeq = latestCheckpointSeq -- 1346
	} -- 1346
end -- 1295
function ____exports.getTaskChangeSetDiff(taskId) -- 1350
	if not getTaskStatus(taskId) then -- 1350
		return {success = false, message = "task not found"} -- 1352
	end -- 1352
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1354
	if #checkpoints == 0 then -- 1354
		return {success = false, message = "change set not found or empty"} -- 1356
	end -- 1356
	local filesByPath = {} -- 1358
	do -- 1358
		local i = 0 -- 1365
		while i < #checkpoints do -- 1365
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 1366
			do -- 1366
				local j = 0 -- 1367
				while j < #entries do -- 1367
					local entry = entries[j + 1] -- 1368
					local item = filesByPath[entry.path] -- 1369
					if not item then -- 1369
						item = { -- 1371
							path = entry.path, -- 1372
							beforeExists = entry.beforeExists, -- 1373
							beforeContent = entry.beforeContent, -- 1374
							afterExists = entry.afterExists, -- 1375
							afterContent = entry.afterContent -- 1376
						} -- 1376
						filesByPath[entry.path] = item -- 1378
					end -- 1378
					item.afterExists = entry.afterExists -- 1380
					item.afterContent = entry.afterContent -- 1381
					j = j + 1 -- 1367
				end -- 1367
			end -- 1367
			i = i + 1 -- 1365
		end -- 1365
	end -- 1365
	local files = {} -- 1384
	for ____, item in pairs(filesByPath) do -- 1385
		files[#files + 1] = { -- 1386
			path = item.path, -- 1387
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1388
			beforeExists = item.beforeExists, -- 1389
			afterExists = item.afterExists, -- 1390
			beforeContent = item.beforeContent, -- 1391
			afterContent = item.afterContent -- 1392
		} -- 1392
	end -- 1392
	__TS__ArraySort( -- 1395
		files, -- 1395
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1395
	) -- 1395
	return {success = true, files = files} -- 1396
end -- 1350
local function readWorkspaceFile(workDir, path, docLanguage) -- 1399
	local engineLog = readEngineLogFile(path) -- 1400
	if engineLog then -- 1400
		return engineLog -- 1401
	end -- 1401
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1402
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 1402
		local attr = inspectReadableFile(fullPath) -- 1404
		if not attr.success then -- 1404
			return attr -- 1405
		end -- 1405
		return { -- 1406
			success = true, -- 1406
			content = Content:load(fullPath), -- 1406
			size = attr.size -- 1406
		} -- 1406
	end -- 1406
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 1408
	if docPath then -- 1408
		local attr = inspectReadableFile(docPath) -- 1410
		if not attr.success then -- 1410
			return attr -- 1411
		end -- 1411
		return { -- 1412
			success = true, -- 1412
			content = Content:load(docPath), -- 1412
			size = attr.size -- 1412
		} -- 1412
	end -- 1412
	if not fullPath then -- 1412
		return {success = false, message = "invalid path or workDir"} -- 1414
	end -- 1414
	return {success = false, message = "file not found"} -- 1415
end -- 1399
function ____exports.readFileRaw(workDir, path, docLanguage) -- 1418
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 1419
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 1419
		local attr = inspectReadableFile(path) -- 1421
		if not attr.success then -- 1421
			return attr -- 1422
		end -- 1422
		return { -- 1423
			success = true, -- 1423
			content = Content:load(path), -- 1423
			size = attr.size -- 1423
		} -- 1423
	end -- 1423
	return result -- 1425
end -- 1418
function ____exports.getLogs(req) -- 1440
	local text = getEngineLogText() -- 1441
	if text == nil then -- 1441
		return {success = false, message = "failed to read engine logs"} -- 1443
	end -- 1443
	local tailLines = math.max( -- 1445
		1, -- 1445
		math.floor(req and req.tailLines or 200) -- 1445
	) -- 1445
	local allLines = __TS__StringSplit(text, "\n") -- 1446
	local logs = __TS__ArraySlice( -- 1447
		allLines, -- 1447
		math.max(0, #allLines - tailLines) -- 1447
	) -- 1447
	return req and req.joinText and ({ -- 1448
		success = true, -- 1448
		logs = logs, -- 1448
		text = table.concat(logs, "\n") -- 1448
	}) or ({success = true, logs = logs}) -- 1448
end -- 1440
function ____exports.listFiles(req) -- 1451
	local root = req.path or "" -- 1457
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 1458
	if not searchRoot then -- 1458
		return {success = false, message = "invalid path or workDir"} -- 1460
	end -- 1460
	do -- 1460
		local function ____catch(e) -- 1460
			return true, { -- 1478
				success = false, -- 1478
				message = tostring(e) -- 1478
			} -- 1478
		end -- 1478
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1478
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 1463
			local globs = ensureSafeSearchGlobs(userGlobs) -- 1464
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 1465
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 1466
			local totalEntries = #files -- 1467
			local maxEntries = math.max( -- 1468
				1, -- 1468
				math.floor(req.maxEntries or 200) -- 1468
			) -- 1468
			local truncated = totalEntries > maxEntries -- 1469
			return true, { -- 1470
				success = true, -- 1471
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 1472
				totalEntries = totalEntries, -- 1473
				truncated = truncated, -- 1474
				maxEntries = maxEntries -- 1475
			} -- 1475
		end) -- 1475
		if not ____try then -- 1475
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1475
		end -- 1475
		if ____hasReturned then -- 1475
			return ____returnValue -- 1462
		end -- 1462
	end -- 1462
end -- 1451
local function formatReadSlice(content, startLine, endLine) -- 1482
	local lines = __TS__StringSplit(content, "\n") -- 1487
	local totalLines = #lines -- 1488
	if totalLines == 0 then -- 1488
		return { -- 1490
			success = true, -- 1491
			content = "", -- 1492
			totalLines = 0, -- 1493
			startLine = 1, -- 1494
			endLine = 0, -- 1495
			truncated = false -- 1496
		} -- 1496
	end -- 1496
	local rawStart = math.floor(startLine) -- 1499
	local rawEnd = math.floor(endLine) -- 1500
	if rawStart == 0 then -- 1500
		return {success = false, message = "startLine cannot be 0"} -- 1502
	end -- 1502
	if rawEnd == 0 then -- 1502
		return {success = false, message = "endLine cannot be 0"} -- 1505
	end -- 1505
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1507
	if start > totalLines then -- 1507
		return { -- 1511
			success = false, -- 1511
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1511
		} -- 1511
	end -- 1511
	local ____end = math.min( -- 1513
		totalLines, -- 1514
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1515
	) -- 1515
	if ____end < start then -- 1515
		return { -- 1520
			success = false, -- 1521
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1522
		} -- 1522
	end -- 1522
	local slice = {} -- 1525
	do -- 1525
		local i = start -- 1526
		while i <= ____end do -- 1526
			slice[#slice + 1] = lines[i] -- 1527
			i = i + 1 -- 1526
		end -- 1526
	end -- 1526
	local truncated = start > 1 or ____end < totalLines -- 1529
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1530
	local body = table.concat(slice, "\n") -- 1535
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1536
	return { -- 1537
		success = true, -- 1538
		content = output, -- 1539
		totalLines = totalLines, -- 1540
		startLine = start, -- 1541
		endLine = ____end, -- 1542
		truncated = truncated -- 1543
	} -- 1543
end -- 1482
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1547
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1554
	if not fallback.success or fallback.content == nil then -- 1554
		return fallback -- 1555
	end -- 1555
	local resolvedStartLine = startLine or 1 -- 1556
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1557
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1558
end -- 1547
local codeExtensions = { -- 1565
	".lua", -- 1565
	".tl", -- 1565
	".yue", -- 1565
	".ts", -- 1565
	".tsx", -- 1565
	".xml", -- 1565
	".md", -- 1565
	".yarn", -- 1565
	".wa", -- 1565
	".mod" -- 1565
} -- 1565
extensionLevels = { -- 1566
	vs = 2, -- 1567
	bl = 2, -- 1568
	ts = 1, -- 1569
	tsx = 1, -- 1570
	tl = 1, -- 1571
	yue = 1, -- 1572
	xml = 1, -- 1573
	lua = 0 -- 1574
} -- 1574
local function splitSearchPatterns(pattern) -- 1591
	local trimmed = __TS__StringTrim(pattern or "") -- 1592
	if trimmed == "" then -- 1592
		return {} -- 1593
	end -- 1593
	local out = {} -- 1594
	local seen = __TS__New(Set) -- 1595
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1596
		local p = __TS__StringTrim(tostring(p0)) -- 1597
		if p ~= "" and not seen:has(p) then -- 1597
			seen:add(p) -- 1599
			out[#out + 1] = p -- 1600
		end -- 1600
	end -- 1600
	return out -- 1603
end -- 1591
local function splitWhitespaceSearchPatterns(pattern) -- 1606
	local out = {} -- 1607
	local seen = __TS__New(Set) -- 1608
	for p0 in string.gmatch(pattern, "(%S+)") do -- 1609
		local p = __TS__StringTrim(tostring(p0)) -- 1610
		local key = string.lower(p) -- 1611
		if p ~= "" and not seen:has(key) then -- 1611
			seen:add(key) -- 1613
			out[#out + 1] = p -- 1614
		end -- 1614
	end -- 1614
	return out -- 1617
end -- 1606
local function mergeSearchFileResultsUnique(resultsList) -- 1620
	local merged = {} -- 1621
	local seen = __TS__New(Set) -- 1622
	do -- 1622
		local i = 0 -- 1623
		while i < #resultsList do -- 1623
			local list = resultsList[i + 1] -- 1624
			do -- 1624
				local j = 0 -- 1625
				while j < #list do -- 1625
					do -- 1625
						local row = list[j + 1] -- 1626
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1627
						if seen:has(key) then -- 1627
							goto __continue317 -- 1628
						end -- 1628
						seen:add(key) -- 1629
						merged[#merged + 1] = list[j + 1] -- 1630
					end -- 1630
					::__continue317:: -- 1630
					j = j + 1 -- 1625
				end -- 1625
			end -- 1625
			i = i + 1 -- 1623
		end -- 1623
	end -- 1623
	return merged -- 1633
end -- 1620
local function buildGroupedSearchResults(results) -- 1636
	local order = {} -- 1641
	local grouped = __TS__New(Map) -- 1642
	do -- 1642
		local i = 0 -- 1647
		while i < #results do -- 1647
			local row = results[i + 1] -- 1648
			local file = row.file -- 1649
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1650
			local bucket = grouped:get(key) -- 1651
			if not bucket then -- 1651
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1653
				grouped:set(key, bucket) -- 1654
				order[#order + 1] = key -- 1655
			end -- 1655
			bucket.totalMatches = bucket.totalMatches + 1 -- 1657
			local ____bucket_matches_19 = bucket.matches -- 1657
			____bucket_matches_19[#____bucket_matches_19 + 1] = results[i + 1] -- 1658
			i = i + 1 -- 1647
		end -- 1647
	end -- 1647
	local out = {} -- 1660
	do -- 1660
		local i = 0 -- 1665
		while i < #order do -- 1665
			local bucket = grouped:get(order[i + 1]) -- 1666
			if bucket then -- 1666
				out[#out + 1] = bucket -- 1667
			end -- 1667
			i = i + 1 -- 1665
		end -- 1665
	end -- 1665
	return out -- 1669
end -- 1636
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1672
	local merged = {} -- 1673
	local seen = __TS__New(Set) -- 1674
	local index = 0 -- 1675
	local advanced = true -- 1676
	while advanced do -- 1676
		advanced = false -- 1678
		do -- 1678
			local i = 0 -- 1679
			while i < #resultsList do -- 1679
				do -- 1679
					local list = resultsList[i + 1] -- 1680
					if index >= #list then -- 1680
						goto __continue329 -- 1681
					end -- 1681
					advanced = true -- 1682
					local row = list[index + 1] -- 1683
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1684
					if seen:has(key) then -- 1684
						goto __continue329 -- 1685
					end -- 1685
					seen:add(key) -- 1686
					merged[#merged + 1] = row -- 1687
				end -- 1687
				::__continue329:: -- 1687
				i = i + 1 -- 1679
			end -- 1679
		end -- 1679
		index = index + 1 -- 1689
	end -- 1689
	return merged -- 1691
end -- 1672
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1694
	if docSource ~= "api" then -- 1694
		return 100 -- 1695
	end -- 1695
	if programmingLanguage ~= "tsx" then -- 1695
		return 100 -- 1696
	end -- 1696
	repeat -- 1696
		local ____switch335 = string.lower(Path:getFilename(file)) -- 1696
		local ____cond335 = ____switch335 == "jsx.d.ts" -- 1696
		if ____cond335 then -- 1696
			return 0 -- 1698
		end -- 1698
		____cond335 = ____cond335 or ____switch335 == "dorax.d.ts" -- 1698
		if ____cond335 then -- 1698
			return 1 -- 1699
		end -- 1699
		____cond335 = ____cond335 or ____switch335 == "dora.d.ts" -- 1699
		if ____cond335 then -- 1699
			return 2 -- 1700
		end -- 1700
		do -- 1700
			return 100 -- 1701
		end -- 1701
	until true -- 1701
end -- 1694
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1705
	local sorted = __TS__ArraySlice(hits) -- 1710
	__TS__ArraySort( -- 1711
		sorted, -- 1711
		function(____, a, b) -- 1711
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1712
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1713
			if pa ~= pb then -- 1713
				return pa - pb -- 1714
			end -- 1714
			local fa = string.lower(a.file) -- 1715
			local fb = string.lower(b.file) -- 1716
			if fa ~= fb then -- 1716
				return fa < fb and -1 or 1 -- 1717
			end -- 1717
			return (a.line or 0) - (b.line or 0) -- 1718
		end -- 1711
	) -- 1711
	return sorted -- 1720
end -- 1705
function ____exports.searchFiles(req) -- 1723
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1723
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1736
		if not resolvedPath then -- 1736
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1736
		end -- 1736
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1740
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1741
		if not searchRoot then -- 1741
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1741
		end -- 1741
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1741
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1741
		end -- 1741
		local patterns = splitSearchPatterns(req.pattern) -- 1748
		if #patterns == 0 then -- 1748
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1748
		end -- 1748
		return ____awaiter_resolve( -- 1748
			nil, -- 1748
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
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1755
								local allResults = {} -- 1758
								do -- 1758
									local i = 0 -- 1759
									while i < #patterns do -- 1759
										local ____Content_24 = Content -- 1760
										local ____Content_searchFilesAsync_25 = Content.searchFilesAsync -- 1760
										local ____patterns_index_23 = patterns[i + 1] -- 1765
										local ____req_useRegex_20 = req.useRegex -- 1766
										if ____req_useRegex_20 == nil then -- 1766
											____req_useRegex_20 = false -- 1766
										end -- 1766
										local ____req_caseSensitive_21 = req.caseSensitive -- 1767
										if ____req_caseSensitive_21 == nil then -- 1767
											____req_caseSensitive_21 = false -- 1767
										end -- 1767
										local ____req_includeContent_22 = req.includeContent -- 1768
										if ____req_includeContent_22 == nil then -- 1768
											____req_includeContent_22 = true -- 1768
										end -- 1768
										allResults[#allResults + 1] = ____Content_searchFilesAsync_25( -- 1760
											____Content_24, -- 1760
											searchRoot, -- 1761
											codeExtensions, -- 1762
											extensionLevels, -- 1763
											searchGlobs, -- 1764
											____patterns_index_23, -- 1765
											____req_useRegex_20, -- 1766
											____req_caseSensitive_21, -- 1767
											____req_includeContent_22, -- 1768
											req.contentWindow or 120 -- 1769
										) -- 1769
										i = i + 1 -- 1759
									end -- 1759
								end -- 1759
								local results = mergeSearchFileResultsUnique(allResults) -- 1772
								local totalResults = #results -- 1773
								local limit = math.max( -- 1774
									1, -- 1774
									math.floor(req.limit or 20) -- 1774
								) -- 1774
								local offset = math.max( -- 1775
									0, -- 1775
									math.floor(req.offset or 0) -- 1775
								) -- 1775
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1776
								local nextOffset = offset + #paged -- 1777
								local hasMore = nextOffset < totalResults -- 1778
								local truncated = offset > 0 or hasMore -- 1779
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1780
								local groupByFile = req.groupByFile == true -- 1781
								resolve( -- 1782
									nil, -- 1782
									{ -- 1782
										success = true, -- 1783
										results = relativeResults, -- 1784
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1785
										totalResults = totalResults, -- 1786
										truncated = truncated, -- 1787
										limit = limit, -- 1788
										offset = offset, -- 1789
										nextOffset = nextOffset, -- 1790
										hasMore = hasMore, -- 1791
										groupByFile = groupByFile -- 1792
									} -- 1792
								) -- 1792
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
end -- 1723
function ____exports.searchDoraAPI(req) -- 1801
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1801
		local pattern = __TS__StringTrim(req.pattern or "") -- 1812
		if pattern == "" then -- 1812
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1812
		end -- 1812
		local patterns = splitSearchPatterns(pattern) -- 1814
		if #patterns == 0 then -- 1814
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1814
		end -- 1814
		local docSource = req.docSource or "api" -- 1816
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1817
		local docRoot = target.root -- 1818
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1819
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1819
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1819
		end -- 1819
		local exts = target.exts -- 1823
		local dotExts = __TS__ArrayMap( -- 1824
			exts, -- 1824
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1824
		) -- 1824
		local globs = target.globs -- 1825
		local limit = math.max( -- 1826
			1, -- 1826
			math.floor(req.limit or 10) -- 1826
		) -- 1826
		return ____awaiter_resolve( -- 1826
			nil, -- 1826
			__TS__New( -- 1828
				__TS__Promise, -- 1828
				function(____, resolve) -- 1828
					Director.systemScheduler:schedule(once(function() -- 1829
						do -- 1829
							local function ____catch(e) -- 1829
								resolve( -- 1909
									nil, -- 1909
									{ -- 1909
										success = false, -- 1909
										message = tostring(e) -- 1909
									} -- 1909
								) -- 1909
							end -- 1909
							local ____try, ____hasReturned = pcall(function() -- 1909
								local allHits = {} -- 1831
								do -- 1831
									local p = 0 -- 1832
									while p < #patterns do -- 1832
										local ____Content_30 = Content -- 1833
										local ____Content_searchFilesAsync_31 = Content.searchFilesAsync -- 1833
										local ____array_29 = __TS__SparseArrayNew( -- 1833
											docRoot, -- 1834
											dotExts, -- 1835
											{}, -- 1836
											ensureSafeSearchGlobs(globs), -- 1837
											patterns[p + 1] -- 1838
										) -- 1838
										local ____req_useRegex_26 = req.useRegex -- 1839
										if ____req_useRegex_26 == nil then -- 1839
											____req_useRegex_26 = false -- 1839
										end -- 1839
										__TS__SparseArrayPush(____array_29, ____req_useRegex_26) -- 1839
										local ____req_caseSensitive_27 = req.caseSensitive -- 1840
										if ____req_caseSensitive_27 == nil then -- 1840
											____req_caseSensitive_27 = false -- 1840
										end -- 1840
										__TS__SparseArrayPush(____array_29, ____req_caseSensitive_27) -- 1840
										local ____req_includeContent_28 = req.includeContent -- 1841
										if ____req_includeContent_28 == nil then -- 1841
											____req_includeContent_28 = true -- 1841
										end -- 1841
										__TS__SparseArrayPush(____array_29, ____req_includeContent_28, req.contentWindow or 80) -- 1841
										local raw = ____Content_searchFilesAsync_31( -- 1833
											____Content_30, -- 1833
											__TS__SparseArraySpread(____array_29) -- 1833
										) -- 1833
										local hits = {} -- 1844
										do -- 1844
											local i = 0 -- 1845
											while i < #raw do -- 1845
												do -- 1845
													local row = raw[i + 1] -- 1846
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1847
													if file == "" then -- 1847
														goto __continue362 -- 1848
													end -- 1848
													hits[#hits + 1] = { -- 1849
														file = file, -- 1850
														line = type(row.line) == "number" and row.line or nil, -- 1851
														content = type(row.content) == "string" and row.content or nil -- 1852
													} -- 1852
												end -- 1852
												::__continue362:: -- 1852
												i = i + 1 -- 1845
											end -- 1845
										end -- 1845
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1855
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1855
											0, -- 1855
											limit -- 1855
										) -- 1855
										p = p + 1 -- 1832
									end -- 1832
								end -- 1832
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1857
								local fallbackPatterns -- 1858
								if #hits == 0 and #patterns == 1 and req.useRegex ~= true and (string.find(pattern, "|", nil, true) or 0) - 1 < 0 then -- 1858
									local terms = splitWhitespaceSearchPatterns(pattern) -- 1863
									if #terms > 1 then -- 1863
										fallbackPatterns = terms -- 1865
										local fallbackHits = {} -- 1866
										do -- 1866
											local p = 0 -- 1867
											while p < #terms do -- 1867
												local ____Content_35 = Content -- 1868
												local ____Content_searchFilesAsync_36 = Content.searchFilesAsync -- 1868
												local ____array_34 = __TS__SparseArrayNew( -- 1868
													docRoot, -- 1869
													dotExts, -- 1870
													{}, -- 1871
													ensureSafeSearchGlobs(globs), -- 1872
													terms[p + 1], -- 1873
													false -- 1874
												) -- 1874
												local ____req_caseSensitive_32 = req.caseSensitive -- 1875
												if ____req_caseSensitive_32 == nil then -- 1875
													____req_caseSensitive_32 = false -- 1875
												end -- 1875
												__TS__SparseArrayPush(____array_34, ____req_caseSensitive_32) -- 1875
												local ____req_includeContent_33 = req.includeContent -- 1876
												if ____req_includeContent_33 == nil then -- 1876
													____req_includeContent_33 = true -- 1876
												end -- 1876
												__TS__SparseArrayPush(____array_34, ____req_includeContent_33, req.contentWindow or 80) -- 1876
												local raw = ____Content_searchFilesAsync_36( -- 1868
													____Content_35, -- 1868
													__TS__SparseArraySpread(____array_34) -- 1868
												) -- 1868
												local termHits = {} -- 1879
												do -- 1879
													local i = 0 -- 1880
													while i < #raw do -- 1880
														do -- 1880
															local row = raw[i + 1] -- 1881
															local file = toDocRelativePath(resultBaseRoot, row.file) -- 1882
															if file == "" then -- 1882
																goto __continue369 -- 1883
															end -- 1883
															termHits[#termHits + 1] = { -- 1884
																file = file, -- 1885
																line = type(row.line) == "number" and row.line or nil, -- 1886
																content = type(row.content) == "string" and row.content or nil -- 1887
															} -- 1887
														end -- 1887
														::__continue369:: -- 1887
														i = i + 1 -- 1880
													end -- 1880
												end -- 1880
												fallbackHits[#fallbackHits + 1] = __TS__ArraySlice( -- 1890
													sortDoraAPISearchHits(termHits, docSource, req.programmingLanguage), -- 1890
													0, -- 1890
													limit -- 1890
												) -- 1890
												p = p + 1 -- 1867
											end -- 1867
										end -- 1867
										hits = mergeDoraAPISearchHitsUnique(fallbackHits) -- 1892
									end -- 1892
								end -- 1892
								resolve(nil, { -- 1895
									success = true, -- 1896
									docSource = docSource, -- 1897
									docLanguage = req.docLanguage, -- 1898
									programmingLanguage = req.programmingLanguage, -- 1899
									exts = exts, -- 1900
									results = hits, -- 1901
									hint = "Use read_file directly with the file value from a search result to view the complete document. Do not add any prefixes.", -- 1902
									totalResults = #hits, -- 1903
									truncated = false, -- 1904
									limit = limit, -- 1905
									fallbackPatterns = fallbackPatterns -- 1906
								}) -- 1906
							end) -- 1906
							if not ____try then -- 1906
								____catch(____hasReturned) -- 1906
							end -- 1906
						end -- 1906
					end)) -- 1829
				end -- 1828
			) -- 1828
		) -- 1828
	end) -- 1828
end -- 1801
function ____exports.searchDoraAPIHttp(req, callback) -- 1915
	local ____self_37 = ____exports.searchDoraAPI(req) -- 1915
	____self_37["then"]( -- 1915
		____self_37, -- 1915
		function(____, result) return callback(result) end -- 1926
	) -- 1926
end -- 1915
function ____exports.readDoraDoc(req) -- 1929
	local file = table.concat( -- 1935
		__TS__StringSplit(req.file or "", "\\"), -- 1935
		"/" -- 1935
	) -- 1935
	if not isValidWorkspacePath(file) or file == "." then -- 1935
		return {success = false, message = "invalid file"} -- 1937
	end -- 1937
	local lowerFile = string.lower(file) -- 1939
	local isTutorialDoc = __TS__StringEndsWith(lowerFile, ".md") -- 1940
	local isAPIDoc = __TS__StringEndsWith(lowerFile, ".ts") or __TS__StringEndsWith(lowerFile, ".tl") -- 1941
	if not isTutorialDoc and not isAPIDoc then -- 1941
		return {success = false, message = "unsupported doc file type"} -- 1942
	end -- 1942
	local docSource = isTutorialDoc and "tutorial" or "api" -- 1943
	local root = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1944
	local fullPath = Path(root, file) -- 1945
	local relative = Path:getRelative(fullPath, root) -- 1946
	if relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 1946
		return {success = false, message = "invalid file"} -- 1948
	end -- 1948
	local readResult = ____exports.readFile(root, file, req.startLine or 1, req.endLine or -1) -- 1950
	if not readResult.success then -- 1950
		return readResult -- 1951
	end -- 1951
	return { -- 1952
		success = true, -- 1953
		docLanguage = req.docLanguage, -- 1954
		file = file, -- 1955
		content = readResult.content, -- 1956
		startLine = readResult.startLine, -- 1957
		endLine = readResult.endLine -- 1958
	} -- 1958
end -- 1929
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1962
	if options == nil then -- 1962
		options = {} -- 1962
	end -- 1962
	if #changes == 0 then -- 1962
		return {success = false, message = "empty changes"} -- 1964
	end -- 1964
	if not isValidWorkDir(workDir) then -- 1964
		return {success = false, message = "invalid workDir"} -- 1967
	end -- 1967
	if not getTaskStatus(taskId) then -- 1967
		return {success = false, message = "task not found"} -- 1970
	end -- 1970
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1972
	local dup = rejectDuplicatePaths(expandedChanges) -- 1973
	if dup then -- 1973
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1975
	end -- 1975
	for ____, change in ipairs(expandedChanges) do -- 1978
		if not isValidWorkspacePath(change.path) then -- 1978
			return {success = false, message = "invalid path: " .. change.path} -- 1980
		end -- 1980
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1980
			return {success = false, message = "missing content for " .. change.path} -- 1983
		end -- 1983
	end -- 1983
	local headSeq = getTaskHeadSeq(taskId) -- 1987
	if headSeq == nil then -- 1987
		return {success = false, message = "task not found"} -- 1988
	end -- 1988
	local nextSeq = headSeq + 1 -- 1989
	local checkpointId = insertCheckpoint( -- 1990
		taskId, -- 1990
		nextSeq, -- 1990
		options.summary or "", -- 1990
		options.toolName or "", -- 1990
		"PREPARED" -- 1990
	) -- 1990
	if checkpointId <= 0 then -- 1990
		return {success = false, message = "failed to create checkpoint"} -- 1992
	end -- 1992
	do -- 1992
		local i = 0 -- 1995
		while i < #expandedChanges do -- 1995
			local change = expandedChanges[i + 1] -- 1996
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1997
			if not fullPath then -- 1997
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1999
				return {success = false, message = "invalid path: " .. change.path} -- 2000
			end -- 2000
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 2000
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2003
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 2004
			end -- 2004
			local before = getFileState(fullPath) -- 2006
			local afterExists = change.op ~= "delete" -- 2007
			local afterContent = afterExists and (change.content or "") or "" -- 2008
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 2009
				checkpointId, -- 2013
				i + 1, -- 2014
				change.path, -- 2015
				change.op, -- 2016
				before.exists and 1 or 0, -- 2017
				before.content, -- 2018
				afterExists and 1 or 0, -- 2019
				afterContent, -- 2020
				before.bytes, -- 2021
				#afterContent -- 2022
			}) -- 2022
			if inserted <= 0 then -- 2022
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2026
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 2027
			end -- 2027
			i = i + 1 -- 1995
		end -- 1995
	end -- 1995
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 2031
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2032
		if not fullPath then -- 2032
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2034
			return {success = false, message = "invalid path: " .. entry.path} -- 2035
		end -- 2035
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 2037
		if not ok then -- 2037
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2039
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 2040
		end -- 2040
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 2040
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2043
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 2044
		end -- 2044
	end -- 2044
	DB:exec( -- 2048
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 2048
		{ -- 2050
			"APPLIED", -- 2050
			now(), -- 2050
			checkpointId -- 2050
		} -- 2050
	) -- 2050
	DB:exec( -- 2052
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 2052
		{ -- 2054
			nextSeq, -- 2054
			now(), -- 2054
			taskId -- 2054
		} -- 2054
	) -- 2054
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 2056
end -- 1962
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 2064
	if not isValidWorkDir(workDir) then -- 2064
		return {success = false, message = "invalid workDir"} -- 2065
	end -- 2065
	if checkpointId <= 0 then -- 2065
		return {success = false, message = "invalid checkpointId"} -- 2066
	end -- 2066
	local entries = getCheckpointEntries(checkpointId, true) -- 2067
	if #entries == 0 then -- 2067
		return {success = false, message = "checkpoint not found or empty"} -- 2069
	end -- 2069
	for ____, entry in ipairs(entries) do -- 2071
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2072
		if not fullPath then -- 2072
			return {success = false, message = "invalid path: " .. entry.path} -- 2074
		end -- 2074
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 2076
		if not ok then -- 2076
			Log( -- 2078
				"Error", -- 2078
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2078
			) -- 2078
			Log( -- 2079
				"Info", -- 2079
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2079
			) -- 2079
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 2080
		end -- 2080
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 2080
			Log( -- 2083
				"Error", -- 2083
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2083
			) -- 2083
			Log( -- 2084
				"Info", -- 2084
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2084
			) -- 2084
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 2085
		end -- 2085
	end -- 2085
	DB:exec( -- 2088
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 2088
		{ -- 2088
			"REVERTED", -- 2088
			now(), -- 2088
			checkpointId -- 2088
		} -- 2088
	) -- 2088
	return {success = true, checkpointId = checkpointId} -- 2089
end -- 2064
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 2092
	if not isValidWorkDir(workDir) then -- 2092
		return {success = false, message = "invalid workDir"} -- 2093
	end -- 2093
	if not getTaskStatus(taskId) then -- 2093
		return {success = false, message = "task not found"} -- 2094
	end -- 2094
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 2095
	if #checkpoints == 0 then -- 2095
		return {success = false, message = "change set not found or empty"} -- 2097
	end -- 2097
	local lastCheckpointId = 0 -- 2099
	do -- 2099
		local i = 0 -- 2100
		while i < #checkpoints do -- 2100
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 2101
			if not result.success then -- 2101
				return {success = false, message = result.message} -- 2102
			end -- 2102
			lastCheckpointId = checkpoints[i + 1].id -- 2103
			i = i + 1 -- 2100
		end -- 2100
	end -- 2100
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 2105
end -- 2092
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 2113
	return getCheckpointEntries(checkpointId, false) -- 2114
end -- 2113
function ____exports.getCheckpointDiff(checkpointId) -- 2117
	if checkpointId <= 0 then -- 2117
		return {success = false, message = "invalid checkpointId"} -- 2119
	end -- 2119
	local entries = getCheckpointEntries(checkpointId, false) -- 2121
	if #entries == 0 then -- 2121
		return {success = false, message = "checkpoint not found or empty"} -- 2123
	end -- 2123
	return { -- 2125
		success = true, -- 2126
		files = __TS__ArrayMap( -- 2127
			entries, -- 2127
			function(____, entry) return { -- 2127
				path = entry.path, -- 2128
				op = entry.op, -- 2129
				beforeExists = entry.beforeExists, -- 2130
				afterExists = entry.afterExists, -- 2131
				beforeContent = entry.beforeContent, -- 2132
				afterContent = entry.afterContent -- 2133
			} end -- 2133
		) -- 2133
	} -- 2133
end -- 2117
local function finalizeBuildResult(workDir, messages) -- 2138
	local normalized = __TS__ArrayMap( -- 2139
		messages, -- 2139
		function(____, m) return m.success and __TS__ObjectAssign( -- 2139
			{}, -- 2140
			m, -- 2140
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2140
		) or __TS__ObjectAssign( -- 2140
			{}, -- 2141
			m, -- 2141
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2141
		) end -- 2141
	) -- 2141
	local total = #normalized -- 2142
	local failed = 0 -- 2143
	do -- 2143
		local i = 0 -- 2144
		while i < #normalized do -- 2144
			if not normalized[i + 1].success then -- 2144
				failed = failed + 1 -- 2145
			end -- 2145
			i = i + 1 -- 2144
		end -- 2144
	end -- 2144
	local passed = total - failed -- 2147
	if failed > 0 then -- 2147
		return { -- 2149
			success = false, -- 2150
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 2151
			total = total, -- 2152
			passed = passed, -- 2153
			failed = failed, -- 2154
			messages = normalized -- 2155
		} -- 2155
	end -- 2155
	return { -- 2158
		success = true, -- 2159
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 2160
		total = total, -- 2161
		passed = passed, -- 2162
		failed = 0, -- 2163
		messages = normalized -- 2164
	} -- 2164
end -- 2138
function ____exports.build(req) -- 2168
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2168
		local targetRel = req.path or "" -- 2169
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2170
		if not target then -- 2170
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2170
		end -- 2170
		if not Content:exist(target) then -- 2170
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2170
		end -- 2170
		local messages = {} -- 2177
		if not Content:isdir(target) then -- 2177
			local kind = getSupportedBuildKind(target) -- 2179
			if not kind then -- 2179
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2179
			end -- 2179
			if kind == "ts" then -- 2179
				local content = Content:load(target) -- 2184
				if content == nil then -- 2184
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2184
				end -- 2184
				if isTiledEditorContent(content) then -- 2184
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2189
					return ____awaiter_resolve( -- 2189
						nil, -- 2189
						finalizeBuildResult(req.workDir, messages) -- 2190
					) -- 2190
				end -- 2190
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2190
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2190
				end -- 2190
				if not isDtsFile(target) then -- 2190
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 2196
				end -- 2196
			else -- 2196
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2199
			end -- 2199
			Log( -- 2201
				"Info", -- 2201
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2201
			) -- 2201
			return ____awaiter_resolve( -- 2201
				nil, -- 2201
				finalizeBuildResult(req.workDir, messages) -- 2202
			) -- 2202
		end -- 2202
		local listResult = ____exports.listFiles({ -- 2204
			workDir = req.workDir, -- 2205
			path = targetRel, -- 2206
			globs = __TS__ArrayMap( -- 2207
				codeExtensions, -- 2207
				function(____, e) return "**/*" .. e end -- 2207
			), -- 2207
			maxEntries = 10000 -- 2208
		}) -- 2208
		local relFiles = listResult.success and listResult.files or ({}) -- 2211
		local tsFileData = {} -- 2212
		local buildQueue = {} -- 2213
		for ____, rel in ipairs(relFiles) do -- 2214
			do -- 2214
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2215
				local kind = getSupportedBuildKind(file) -- 2216
				if not kind then -- 2216
					goto __continue439 -- 2217
				end -- 2217
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2218
				if kind ~= "ts" then -- 2218
					goto __continue439 -- 2220
				end -- 2220
				local content = Content:load(file) -- 2222
				if content == nil then -- 2222
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2224
					goto __continue439 -- 2225
				end -- 2225
				if isTiledEditorContent(content) then -- 2225
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2228
					goto __continue439 -- 2229
				end -- 2229
				tsFileData[file] = content -- 2231
			end -- 2231
			::__continue439:: -- 2231
		end -- 2231
		do -- 2231
			local i = 0 -- 2233
			while i < #buildQueue do -- 2233
				do -- 2233
					local ____buildQueue_index_38 = buildQueue[i + 1] -- 2234
					local file = ____buildQueue_index_38.file -- 2234
					local kind = ____buildQueue_index_38.kind -- 2234
					if kind == "ts" then -- 2234
						local content = tsFileData[file] -- 2236
						if content == nil or isDtsFile(file) then -- 2236
							goto __continue446 -- 2238
						end -- 2238
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2238
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2241
							goto __continue446 -- 2242
						end -- 2242
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 2244
						goto __continue446 -- 2245
					end -- 2245
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2247
				end -- 2247
				::__continue446:: -- 2247
				i = i + 1 -- 2233
			end -- 2233
		end -- 2233
		if #messages == 0 then -- 2233
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2250
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2250
		end -- 2250
		Log( -- 2253
			"Info", -- 2253
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2253
		) -- 2253
		return ____awaiter_resolve( -- 2253
			nil, -- 2253
			finalizeBuildResult(req.workDir, messages) -- 2254
		) -- 2254
	end) -- 2254
end -- 2168
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2257
local EXECUTE_COMMAND_ERROR_MAX = 4000 -- 2258
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 2259
local agentEntryRuntimeOwner = "" -- 2260
local function truncateCommandOutput(output) -- 2262
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2262
		return output -- 2263
	end -- 2263
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2264
end -- 2262
local function truncateCommandError(message) -- 2267
	if #message <= EXECUTE_COMMAND_ERROR_MAX then -- 2267
		return message -- 2268
	end -- 2268
	return __TS__StringSlice(message, 0, EXECUTE_COMMAND_ERROR_MAX) .. "\n... error message truncated ..." -- 2269
end -- 2267
local function executeLuaCommand(req) -- 2272
	local code = __TS__StringTrim(req.code or "") -- 2280
	if code == "" then -- 2280
		return __TS__Promise.resolve({ -- 2282
			success = false, -- 2282
			mode = "lua", -- 2282
			output = "", -- 2282
			message = "missing code", -- 2282
			phase = "validate" -- 2282
		}) -- 2282
	end -- 2282
	local output = {} -- 2284
	local entry = require("Script.Dev.Entry") -- 2285
	local ownsEntryRuntime = false -- 2286
	local function acquireEntryRuntime() -- 2287
		if agentEntryRuntimeOwner ~= "" and agentEntryRuntimeOwner ~= req.operationId then -- 2287
			error("Dora entry runtime is busy with another Agent command") -- 2289
		end -- 2289
		agentEntryRuntimeOwner = req.operationId -- 2291
		ownsEntryRuntime = true -- 2292
	end -- 2287
	local function stopOwnedEntry() -- 2294
		if not ownsEntryRuntime then -- 2294
			return nil -- 2295
		end -- 2295
		local cleanupError -- 2296
		do -- 2296
			local function ____catch(e) -- 2296
				cleanupError = "failed to stop Agent test entry: " .. tostring(e) -- 2300
			end -- 2300
			local ____try, ____hasReturned = pcall(function() -- 2300
				entry.stop() -- 2298
			end) -- 2298
			if not ____try then -- 2298
				____catch(____hasReturned) -- 2298
			end -- 2298
		end -- 2298
		ownsEntryRuntime = false -- 2302
		if agentEntryRuntimeOwner == req.operationId then -- 2302
			agentEntryRuntimeOwner = "" -- 2304
		end -- 2304
		return cleanupError -- 2306
	end -- 2294
	local function normalizeEntryFile(value) -- 2308
		if not value or type(value) ~= "table" then -- 2308
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 2310
		end -- 2310
		local descriptor = value -- 2312
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 2313
		if relativeFile == "" then -- 2313
			relativeFile = "init" -- 2314
		end -- 2314
		if not isValidWorkspacePath(relativeFile) then -- 2314
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 2316
		end -- 2316
		local fileName = Path(req.workDir, relativeFile) -- 2318
		local ext = Path:getExt(fileName) -- 2319
		if ext ~= "" then -- 2319
			fileName = Path:replaceExt(fileName, "") -- 2320
		end -- 2320
		local luaFile = Path:replaceExt(fileName, "lua") -- 2321
		if not Content:exist(luaFile) then -- 2321
			error("Agent test entry was not built: " .. luaFile) -- 2323
		end -- 2323
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 2325
		return { -- 2326
			fileName = fileName, -- 2327
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 2328
		} -- 2328
	end -- 2308
	local function capturePrint(...) -- 2331
		local values = {...} -- 2331
		local parts = {} -- 2332
		do -- 2332
			local i = 0 -- 2333
			while i < #values do -- 2333
				parts[#parts + 1] = tostring(values[i + 1]) -- 2334
				i = i + 1 -- 2333
			end -- 2333
		end -- 2333
		output[#output + 1] = table.concat(parts, "\t") -- 2336
	end -- 2331
	local env = setmetatable( -- 2338
		{ -- 2338
			projectDir = req.workDir, -- 2339
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 2340
				if type(moduleNameValue) ~= "string" then -- 2340
					error("requireProjectModule expects a project module name string") -- 2342
				end -- 2342
				local moduleName = __TS__StringTrim(moduleNameValue) -- 2344
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 2344
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 2346
				end -- 2346
				local reloadModules = {moduleName} -- 2348
				if reloadModulesValue ~= nil then -- 2348
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 2348
						error("requireProjectModule reloadModules must be an array of module names") -- 2351
					end -- 2351
					local items = reloadModulesValue -- 2353
					do -- 2353
						local i = 0 -- 2354
						while i < #items do -- 2354
							local item = items[i + 1] -- 2355
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 2355
								error("requireProjectModule reloadModules contains an invalid module name") -- 2357
							end -- 2357
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 2357
								reloadModules[#reloadModules + 1] = item -- 2359
							end -- 2359
							i = i + 1 -- 2354
						end -- 2354
					end -- 2354
				end -- 2354
				local luaPackage = _G.package -- 2362
				local previousPath = luaPackage.path -- 2366
				local previousSearchPaths = Content.searchPaths -- 2367
				local scopedSearchPaths = {req.workDir} -- 2368
				do -- 2368
					local i = 0 -- 2369
					while i < #previousSearchPaths do -- 2369
						local searchPath = previousSearchPaths[i + 1] -- 2370
						if searchPath ~= req.workDir then -- 2370
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 2371
						end -- 2371
						i = i + 1 -- 2369
					end -- 2369
				end -- 2369
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 2373
				Content.searchPaths = scopedSearchPaths -- 2374
				do -- 2374
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2374
						do -- 2374
							local i = 0 -- 2376
							while i < #reloadModules do -- 2376
								local reloadName = reloadModules[i + 1] -- 2377
								luaPackage.loaded[reloadName] = nil -- 2378
								luaPackage.loaded[table.concat( -- 2379
									__TS__StringSplit(reloadName, "/"), -- 2379
									"." -- 2379
								)] = nil -- 2379
								luaPackage.loaded[table.concat( -- 2380
									__TS__StringSplit(reloadName, "."), -- 2380
									"/" -- 2380
								)] = nil -- 2380
								i = i + 1 -- 2376
							end -- 2376
						end -- 2376
						return true, require(table.concat( -- 2382
							__TS__StringSplit(moduleName, "/"), -- 2382
							"." -- 2382
						)) -- 2382
					end) -- 2382
					do -- 2382
						Content.searchPaths = previousSearchPaths -- 2384
						luaPackage.path = previousPath -- 2385
					end -- 2385
					if not ____try then -- 2385
						error(____hasReturned, 0) -- 2385
					end -- 2385
					if ____try and ____hasReturned then -- 2385
						return ____returnValue -- 2375
					end -- 2375
				end -- 2375
			end, -- 2340
			print = capturePrint, -- 2388
			refreshTree = function(path) -- 2389
				if path == nil then -- 2389
					return refreshProjectTree(req.workDir) -- 2391
				end -- 2391
				if type(path) ~= "string" then -- 2391
					error("refreshTree expects a project-relative file path string or no argument") -- 2394
				end -- 2394
				return refreshProjectTree(req.workDir, path) -- 2396
			end, -- 2389
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 2398
			enterEntryAsync = function(value) -- 2399
				local normalized = normalizeEntryFile(value) -- 2400
				acquireEntryRuntime() -- 2401
				entry.allClear() -- 2402
				local success, message = entry.enterEntryAsync({ -- 2403
					entryName = normalized.entryName, -- 2404
					fileName = normalized.fileName, -- 2405
					workDir = req.workDir, -- 2406
					projectRoot = req.workDir, -- 2407
					runKind = "agent_test" -- 2408
				}) -- 2408
				return success, message -- 2410
			end, -- 2399
			stopEntry = function() -- 2412
				if not ownsEntryRuntime then -- 2412
					return false -- 2413
				end -- 2413
				return entry.stop() -- 2414
			end -- 2412
		}, -- 2412
		{__index = Dora} -- 2416
	) -- 2416
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 2419
	if not fn then -- 2419
		return __TS__Promise.resolve({ -- 2421
			success = false, -- 2422
			mode = "lua", -- 2423
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2424
			message = truncateCommandError(toStr(compileErr)), -- 2425
			phase = "compile" -- 2426
		}) -- 2426
	end -- 2426
	return __TS__New( -- 2429
		__TS__Promise, -- 2429
		function(____, resolve) -- 2429
			local settled = false -- 2430
			local startedAt = App.runningTime -- 2431
			local onProgress = req.onProgress -- 2432
			local isCancelled = req.isCancelled -- 2433
			local function finish(result) -- 2434
				if settled then -- 2434
					return -- 2435
				end -- 2435
				settled = true -- 2436
				local cleanupError = stopOwnedEntry() -- 2437
				if not result.success and cleanupError ~= nil then -- 2437
					result.cleanupError = cleanupError -- 2439
				elseif result.success and cleanupError ~= nil then -- 2439
					resolve(nil, { -- 2441
						success = false, -- 2442
						mode = "lua", -- 2443
						output = result.output, -- 2444
						message = cleanupError, -- 2445
						phase = "execute", -- 2446
						cleanupError = cleanupError -- 2447
					}) -- 2447
					return -- 2449
				end -- 2449
				resolve(nil, result) -- 2451
			end -- 2434
			if onProgress then -- 2434
				onProgress(nil, { -- 2454
					state = "pending", -- 2455
					mode = "lua", -- 2456
					operationId = req.operationId, -- 2457
					stage = "lua", -- 2458
					message = "Lua command pending" -- 2459
				}) -- 2459
			end -- 2459
			Director.systemScheduler:schedule(function() -- 2462
				if settled then -- 2462
					return true -- 2463
				end -- 2463
				if isCancelled and isCancelled(nil) then -- 2463
					finish({ -- 2465
						success = false, -- 2466
						mode = "lua", -- 2467
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2468
						message = "Lua command canceled", -- 2469
						phase = "execute", -- 2470
						interrupted = true -- 2471
					}) -- 2471
					return true -- 2473
				end -- 2473
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 2473
					finish({ -- 2476
						success = false, -- 2477
						mode = "lua", -- 2478
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2479
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 2480
						phase = "timeout" -- 2481
					}) -- 2481
					return true -- 2483
				end -- 2483
				return false -- 2485
			end) -- 2462
			Director.systemScheduler:schedule(once(function() -- 2487
				if settled then -- 2487
					return -- 2488
				end -- 2488
				if onProgress then -- 2488
					onProgress(nil, { -- 2490
						state = "running", -- 2491
						mode = "lua", -- 2492
						operationId = req.operationId, -- 2493
						stage = "lua", -- 2494
						message = "Lua command running" -- 2495
					}) -- 2495
				end -- 2495
				local previousGlobalPrint = _G.print -- 2498
				_G.print = capturePrint -- 2499
				local ok, runtimeErr = pcall(fn) -- 2500
				_G.print = previousGlobalPrint -- 2501
				if not ok then -- 2501
					finish({ -- 2503
						success = false, -- 2504
						mode = "lua", -- 2505
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2506
						message = truncateCommandError(toStr(runtimeErr)), -- 2507
						phase = "execute" -- 2508
					}) -- 2508
					return -- 2510
				end -- 2510
				finish({ -- 2512
					success = true, -- 2512
					mode = "lua", -- 2512
					output = truncateCommandOutput(table.concat(output, "\n")) -- 2512
				}) -- 2512
			end)) -- 2487
		end -- 2429
	) -- 2429
end -- 2272
local function formatGitStatusOutput(status) -- 2517
	if not status then -- 2517
		return "" -- 2518
	end -- 2518
	local lines = {} -- 2519
	local state = toStr(status.state) -- 2520
	local kind = toStr(status.kind) -- 2521
	local message = toStr(status.message) -- 2522
	local errorMessage = toStr(status.error) -- 2523
	if kind ~= "" or state ~= "" then -- 2523
		lines[#lines + 1] = table.concat( -- 2525
			__TS__ArrayFilter( -- 2525
				{kind, state}, -- 2525
				function(____, item) return item ~= "" end -- 2525
			), -- 2525
			": " -- 2525
		) -- 2525
	end -- 2525
	if message ~= "" then -- 2525
		lines[#lines + 1] = message -- 2527
	end -- 2527
	if errorMessage ~= "" then -- 2527
		lines[#lines + 1] = errorMessage -- 2528
	end -- 2528
	local data = status.data -- 2529
	if data ~= nil then -- 2529
		local dataText = encodeJSON(data) -- 2531
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 2532
	end -- 2532
	return truncateCommandOutput(table.concat(lines, "\n")) -- 2534
end -- 2517
local function emitGitProgress(mode, operationId, onProgress, status) -- 2537
	if not onProgress then -- 2537
		return -- 2543
	end -- 2543
	local progress = type(status.progress) == "number" and status.progress or nil -- 2544
	local kind = toStr(status.kind) -- 2545
	local message = toStr(status.message) -- 2546
	local state = toStr(status.state) -- 2547
	local jobId = type(status.id) == "number" and status.id or nil -- 2548
	onProgress({ -- 2549
		state = "running", -- 2550
		mode = mode, -- 2551
		operationId = operationId, -- 2552
		stage = kind ~= "" and kind or "git", -- 2553
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 2554
		progress = progress, -- 2555
		jobId = jobId, -- 2556
		gitState = state ~= "" and state or nil, -- 2557
		gitKind = kind ~= "" and kind or nil -- 2558
	}) -- 2558
end -- 2537
local function cloneGitToTarget(req) -- 2562
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2562
		local parsed = parseGitCloneCommand(req.command) -- 2570
		if parsed == nil then -- 2570
			return ____awaiter_resolve(nil, nil) -- 2570
		end -- 2570
		if not parsed.success then -- 2570
			return ____awaiter_resolve(nil, { -- 2570
				success = false, -- 2573
				mode = "git", -- 2573
				output = "", -- 2573
				message = parsed.message, -- 2573
				phase = "validate" -- 2573
			}) -- 2573
		end -- 2573
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 2575
		if not target then -- 2575
			return ____awaiter_resolve(nil, { -- 2575
				success = false, -- 2577
				mode = "git", -- 2577
				output = "", -- 2577
				message = "invalid clone target path", -- 2577
				phase = "validate" -- 2577
			}) -- 2577
		end -- 2577
		if Content:exist(target) then -- 2577
			return ____awaiter_resolve(nil, { -- 2577
				success = false, -- 2580
				mode = "git", -- 2580
				output = "", -- 2580
				message = "target already exists", -- 2580
				phase = "validate" -- 2580
			}) -- 2580
		end -- 2580
		local targetParent = Path:getPath(target) -- 2582
		if not ensureDirPath(targetParent) then -- 2582
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 2582
		end -- 2582
		local tempRoot = getAgentDownloadTempRoot() -- 2586
		if not ensureDirPath(tempRoot) then -- 2586
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 2586
		end -- 2586
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 2590
		Content:remove(tempPath) -- 2591
		local depth = parsed.depth or "1" -- 2592
		local ____array_39 = __TS__SparseArrayNew( -- 2592
			"clone", -- 2594
			quoteGitArg(parsed.url), -- 2595
			quoteGitArg(Path:getFilename(tempPath)), -- 2596
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 2597
				"-b", -- 2597
				quoteGitArg(parsed.ref) -- 2597
			}) or ({})) -- 2597
		) -- 2597
		__TS__SparseArrayPush( -- 2597
			____array_39, -- 2597
			table.unpack(depth ~= "" and ({ -- 2598
				"--depth",
				quoteGitArg(depth) -- 2598
			}) or ({})) -- 2598
		) -- 2598
		local command = table.concat( -- 2593
			{__TS__SparseArraySpread(____array_39)}, -- 2593
			" " -- 2599
		) -- 2599
		local ____this_41 -- 2599
		____this_41 = req -- 2600
		local ____opt_40 = ____this_41.onProgress -- 2600
		if ____opt_40 ~= nil then -- 2600
			____opt_40(____this_41, { -- 2600
				state = "pending", -- 2601
				mode = "git", -- 2602
				operationId = req.operationId, -- 2603
				stage = "clone", -- 2604
				message = "clone pending", -- 2605
				progress = 0 -- 2606
			}) -- 2606
		end -- 2606
		local gitRes = __TS__Await(runGitAndWait( -- 2608
			tempRoot, -- 2609
			command, -- 2610
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2611
			function() -- 2612
				local ____this_43 -- 2612
				____this_43 = req -- 2612
				local ____opt_42 = ____this_43.isCancelled -- 2612
				return (____opt_42 and ____opt_42(____this_43)) == true -- 2612
			end, -- 2612
			req.timeoutSeconds -- 2613
		)) -- 2613
		if not gitRes.success then -- 2613
			local cleanupError = cleanupPath(tempPath) -- 2616
			local ____formatGitStatusOutput_result_47 = formatGitStatusOutput(gitRes.status) -- 2620
			local ____temp_48 = gitRes.message or "git clone failed" -- 2621
			local ____gitRes_interrupted_46 = gitRes.interrupted -- 2622
			if not ____gitRes_interrupted_46 then -- 2622
				local ____this_45 -- 2622
				____this_45 = req -- 2622
				local ____opt_44 = ____this_45.isCancelled -- 2622
				____gitRes_interrupted_46 = (____opt_44 and ____opt_44(____this_45)) == true -- 2622
			end -- 2622
			return ____awaiter_resolve(nil, { -- 2622
				success = false, -- 2618
				mode = "git", -- 2619
				output = ____formatGitStatusOutput_result_47, -- 2620
				message = ____temp_48, -- 2621
				interrupted = ____gitRes_interrupted_46, -- 2622
				cleanupError = cleanupError -- 2623
			}) -- 2623
		end -- 2623
		if not Content:move(tempPath, target) then -- 2623
			local cleanupError = cleanupPath(tempPath) -- 2627
			return ____awaiter_resolve( -- 2627
				nil, -- 2627
				{ -- 2628
					success = false, -- 2628
					mode = "git", -- 2628
					output = formatGitStatusOutput(gitRes.status), -- 2628
					message = "failed to move cloned repository into target path", -- 2628
					cleanupError = cleanupError -- 2628
				} -- 2628
			) -- 2628
		end -- 2628
		if not refreshProjectTree(req.workDir) then -- 2628
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 2631
		end -- 2631
		local commit = getGitHeadCommit(target) -- 2633
		local output = table.concat( -- 2634
			__TS__ArrayFilter( -- 2634
				{ -- 2634
					formatGitStatusOutput(gitRes.status), -- 2635
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 2635
					commit ~= nil and "commit " .. commit or "" -- 2637
				}, -- 2637
				function(____, item) return item ~= "" end -- 2638
			), -- 2638
			"\n" -- 2638
		) -- 2638
		return ____awaiter_resolve( -- 2638
			nil, -- 2638
			{ -- 2639
				success = true, -- 2639
				mode = "git", -- 2639
				output = truncateCommandOutput(output) -- 2639
			} -- 2639
		) -- 2639
	end) -- 2639
end -- 2562
local function loadGitProfile() -- 2642
	local rows -- 2643
	do -- 2643
		local function ____catch() -- 2643
			return true, nil -- 2647
		end -- 2647
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2647
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 2645
		end) -- 2645
		if not ____try then -- 2645
			____hasReturned, ____returnValue = ____catch() -- 2645
		end -- 2645
		if ____hasReturned then -- 2645
			return ____returnValue -- 2644
		end -- 2644
	end -- 2644
	if not rows or not rows[1] then -- 2644
		return nil -- 2649
	end -- 2649
	local name = toStr(rows[1][1]) -- 2650
	local email = toStr(rows[1][2]) -- 2651
	if name == "" and email == "" then -- 2651
		return nil -- 2652
	end -- 2652
	return {name = name, email = email} -- 2653
end -- 2642
local function applyGitProfileToCommit(command) -- 2656
	local args = shellSplit(command) -- 2657
	if args[1] ~= "commit" then -- 2657
		return command -- 2658
	end -- 2658
	local hasName = false -- 2659
	local hasEmail = false -- 2660
	for ____, arg in ipairs(args) do -- 2661
		if arg == "--author-name" then
			hasName = true -- 2662
		end -- 2662
		if arg == "--author-email" then
			hasEmail = true -- 2663
		end -- 2663
	end -- 2663
	if hasName and hasEmail then -- 2663
		return command -- 2665
	end -- 2665
	local profile = loadGitProfile() -- 2666
	if not profile then -- 2666
		return command -- 2667
	end -- 2667
	local additions = {} -- 2668
	if not hasName and profile.name ~= "" then -- 2668
		__TS__ArrayPush( -- 2670
			additions, -- 2670
			"--author-name",
			quoteGitArg(profile.name) -- 2670
		) -- 2670
	end -- 2670
	if not hasEmail and profile.email ~= "" then -- 2670
		__TS__ArrayPush( -- 2673
			additions, -- 2673
			"--author-email",
			quoteGitArg(profile.email) -- 2673
		) -- 2673
	end -- 2673
	if #additions == 0 then -- 2673
		return command -- 2675
	end -- 2675
	return (command .. " ") .. table.concat(additions, " ") -- 2676
end -- 2656
local function executeGitCommand(req) -- 2679
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2679
		local command = normalizeGitCommand(req.command or "") -- 2688
		if command == "" then -- 2688
			return ____awaiter_resolve(nil, { -- 2688
				success = false, -- 2690
				mode = "git", -- 2690
				output = "", -- 2690
				message = "missing command", -- 2690
				phase = "validate" -- 2690
			}) -- 2690
		end -- 2690
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 2692
			workDir = req.workDir, -- 2693
			command = command, -- 2694
			operationId = req.operationId, -- 2695
			timeoutSeconds = req.timeoutSeconds, -- 2696
			onProgress = req.onProgress, -- 2697
			isCancelled = req.isCancelled -- 2698
		})) -- 2698
		if cloneResult ~= nil then -- 2698
			return ____awaiter_resolve(nil, cloneResult) -- 2698
		end -- 2698
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 2701
		if not cwd.success then -- 2701
			return ____awaiter_resolve(nil, { -- 2701
				success = false, -- 2703
				mode = "git", -- 2703
				output = "", -- 2703
				cwd = req.cwd, -- 2703
				message = cwd.message, -- 2703
				phase = "validate" -- 2703
			}) -- 2703
		end -- 2703
		command = applyGitProfileToCommit(command) -- 2705
		local ____this_50 -- 2705
		____this_50 = req -- 2706
		local ____opt_49 = ____this_50.onProgress -- 2706
		if ____opt_49 ~= nil then -- 2706
			____opt_49(____this_50, { -- 2706
				state = "pending", -- 2707
				mode = "git", -- 2708
				operationId = req.operationId, -- 2709
				stage = "git", -- 2710
				message = "git command pending", -- 2711
				progress = 0 -- 2712
			}) -- 2712
		end -- 2712
		local gitRes = __TS__Await(runGitAndWait( -- 2714
			cwd.path, -- 2715
			command, -- 2716
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2717
			function() -- 2718
				local ____this_52 -- 2718
				____this_52 = req -- 2718
				local ____opt_51 = ____this_52.isCancelled -- 2718
				return (____opt_51 and ____opt_51(____this_52)) == true -- 2718
			end, -- 2718
			req.timeoutSeconds -- 2719
		)) -- 2719
		local output = formatGitStatusOutput(gitRes.status) -- 2721
		if not gitRes.success then -- 2721
			local ____output_56 = output -- 2726
			local ____cwd_relative_57 = cwd.relative -- 2727
			local ____temp_58 = gitRes.message or "git command failed" -- 2728
			local ____gitRes_interrupted_55 = gitRes.interrupted -- 2729
			if not ____gitRes_interrupted_55 then -- 2729
				local ____this_54 -- 2729
				____this_54 = req -- 2729
				local ____opt_53 = ____this_54.isCancelled -- 2729
				____gitRes_interrupted_55 = (____opt_53 and ____opt_53(____this_54)) == true -- 2729
			end -- 2729
			return ____awaiter_resolve(nil, { -- 2729
				success = false, -- 2724
				mode = "git", -- 2725
				output = ____output_56, -- 2726
				cwd = ____cwd_relative_57, -- 2727
				message = ____temp_58, -- 2728
				interrupted = ____gitRes_interrupted_55 -- 2729
			}) -- 2729
		end -- 2729
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 2729
	end) -- 2729
end -- 2679
function ____exports.executeCommand(req) -- 2735
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2735
		local mode = req.mode -- 2745
		if mode ~= "lua" and mode ~= "git" then -- 2745
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 2745
		end -- 2745
		if mode == "lua" then -- 2745
			return ____awaiter_resolve( -- 2745
				nil, -- 2745
				executeLuaCommand({ -- 2750
					workDir = req.workDir, -- 2751
					code = req.code or "", -- 2752
					timeoutSeconds = math.max( -- 2753
						1, -- 2753
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 2753
					), -- 2753
					operationId = createOperationId(), -- 2754
					onProgress = req.onProgress, -- 2755
					isCancelled = req.isCancelled -- 2756
				}) -- 2756
			) -- 2756
		end -- 2756
		local operationId = createOperationId() -- 2759
		return ____awaiter_resolve( -- 2759
			nil, -- 2759
			executeGitCommand({ -- 2760
				workDir = req.workDir, -- 2761
				command = req.command or "", -- 2762
				cwd = req.cwd, -- 2763
				timeoutSeconds = math.max( -- 2764
					1, -- 2764
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 2764
				), -- 2764
				operationId = operationId, -- 2765
				onProgress = req.onProgress, -- 2766
				isCancelled = req.isCancelled -- 2767
			}) -- 2767
		) -- 2767
	end) -- 2767
end -- 2735
function ____exports.fetchUrl(req) -- 2771
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2771
		local mode = "download" -- 2778
		local url = __TS__StringTrim(req.url or "") -- 2779
		local targetRel = __TS__StringTrim(req.target or "") -- 2780
		if not isHttpUrl(url) then -- 2780
			return ____awaiter_resolve(nil, { -- 2780
				success = false, -- 2782
				state = "failed", -- 2782
				mode = mode, -- 2782
				target = targetRel, -- 2782
				message = "fetch_url only supports http:// and https:// URLs" -- 2782
			}) -- 2782
		end -- 2782
		if targetRel == "" then -- 2782
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 2782
		end -- 2782
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 2787
		if not target then -- 2787
			return ____awaiter_resolve(nil, { -- 2787
				success = false, -- 2789
				state = "failed", -- 2789
				mode = mode, -- 2789
				target = targetRel, -- 2789
				message = "invalid target path" -- 2789
			}) -- 2789
		end -- 2789
		if Content:exist(target) then -- 2789
			return ____awaiter_resolve(nil, { -- 2789
				success = false, -- 2792
				state = "failed", -- 2792
				mode = mode, -- 2792
				target = targetRel, -- 2792
				message = "target already exists" -- 2792
			}) -- 2792
		end -- 2792
		local operationId = createOperationId() -- 2794
		local tempRoot = getAgentDownloadTempRoot() -- 2795
		if not ensureDirPath(tempRoot) then -- 2795
			return ____awaiter_resolve(nil, { -- 2795
				success = false, -- 2797
				state = "failed", -- 2797
				mode = mode, -- 2797
				target = targetRel, -- 2797
				message = "failed to create agent download temp directory" -- 2797
			}) -- 2797
		end -- 2797
		local tempPath = Path(tempRoot, operationId .. ".download") -- 2799
		Content:remove(tempPath) -- 2800
		local function emitProgress(progress) -- 2801
			if not req.onProgress then -- 2801
				return -- 2802
			end -- 2802
			req:onProgress(__TS__ObjectAssign({ -- 2803
				state = "running", -- 2804
				mode = mode, -- 2805
				operationId = operationId, -- 2806
				target = targetRel, -- 2807
				tempPath = tempPath -- 2808
			}, progress)) -- 2808
		end -- 2801
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 2812
		local function interrupted() -- 2817
			local ____this_60 -- 2817
			____this_60 = req -- 2817
			local ____opt_59 = ____this_60.isCancelled -- 2817
			return (____opt_59 and ____opt_59(____this_60)) == true -- 2817
		end -- 2817
		if not ensureDirForFile(tempPath) then -- 2817
			return ____awaiter_resolve(nil, { -- 2817
				success = false, -- 2819
				state = "failed", -- 2819
				mode = mode, -- 2819
				target = targetRel, -- 2819
				message = "failed to create temporary file directory" -- 2819
			}) -- 2819
		end -- 2819
		local downloadRes = __TS__Await(downloadFile({ -- 2821
			url = url, -- 2822
			tempPath = tempPath, -- 2823
			timeout = 600, -- 2824
			isCancelled = interrupted, -- 2825
			onProgress = function(____, current, total) -- 2826
				local totalNumber = type(total) == "number" and total or 0 -- 2827
				emitProgress({ -- 2828
					stage = "download", -- 2829
					message = "downloading", -- 2830
					current = current, -- 2831
					total = total, -- 2832
					progress = totalNumber > 0 and current / totalNumber or nil -- 2833
				}) -- 2833
			end -- 2826
		})) -- 2826
		if not downloadRes.success then -- 2826
			local cleanupError = cleanupPath(tempPath) -- 2838
			return ____awaiter_resolve( -- 2838
				nil, -- 2838
				{ -- 2839
					success = false, -- 2840
					state = "failed", -- 2841
					mode = mode, -- 2842
					target = targetRel, -- 2843
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 2844
					interrupted = downloadRes.interrupted or interrupted(), -- 2845
					cleanupError = cleanupError -- 2846
				} -- 2846
			) -- 2846
		end -- 2846
		if not ensureDirForFile(target) then -- 2846
			local cleanupError = cleanupPath(tempPath) -- 2850
			return ____awaiter_resolve(nil, { -- 2850
				success = false, -- 2851
				state = "failed", -- 2851
				mode = mode, -- 2851
				target = targetRel, -- 2851
				message = "failed to create target directory", -- 2851
				cleanupError = cleanupError -- 2851
			}) -- 2851
		end -- 2851
		if not Content:move(tempPath, target) then -- 2851
			local cleanupError = cleanupPath(tempPath) -- 2854
			return ____awaiter_resolve(nil, { -- 2854
				success = false, -- 2855
				state = "failed", -- 2855
				mode = mode, -- 2855
				target = targetRel, -- 2855
				message = "failed to move downloaded file into target path", -- 2855
				cleanupError = cleanupError -- 2855
			}) -- 2855
		end -- 2855
		local bytesWritten = downloadRes.bytesWritten -- 2857
		local ____try = __TS__AsyncAwaiter(function() -- 2857
			local size = Content:getAttr(target) -- 2859
			if bytesWritten == nil or bytesWritten <= 0 then -- 2859
				bytesWritten = type(size) == "number" and size or nil -- 2861
			end -- 2861
		end) -- 2861
		____try = ____try.catch( -- 2861
			____try, -- 2861
			function(____, _) -- 2861
				return __TS__AsyncAwaiter(function() -- 2861
				end) -- 2861
			end -- 2861
		) -- 2861
		__TS__Await(____try) -- 2858
		if bytesWritten == nil or bytesWritten <= 0 then -- 2858
			local ____try = __TS__AsyncAwaiter(function() -- 2858
				local loaded = Content:load(target) -- 2868
				if type(loaded) == "string" then -- 2868
					bytesWritten = #loaded -- 2870
				end -- 2870
			end) -- 2870
			____try = ____try.catch( -- 2870
				____try, -- 2870
				function(____, _) -- 2870
					return __TS__AsyncAwaiter(function() -- 2870
					end) -- 2870
				end -- 2870
			) -- 2870
			__TS__Await(____try) -- 2867
		end -- 2867
		if not syncDownloadedFileToWebIDE(target) then -- 2867
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 2877
		end -- 2877
		return ____awaiter_resolve(nil, { -- 2877
			success = true, -- 2879
			state = "done", -- 2879
			mode = mode, -- 2879
			target = targetRel, -- 2879
			bytesWritten = bytesWritten -- 2879
		}) -- 2879
	end) -- 2879
end -- 2771
return ____exports -- 2771