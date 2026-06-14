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
function getEngineLogText() -- 1386
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 1387
	if not Content:exist(folder) then -- 1387
		Content:mkdir(folder) -- 1389
	end -- 1389
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 1391
	if not App:saveLog(logPath) then -- 1391
		return nil -- 1393
	end -- 1393
	return Content:load(logPath) -- 1395
end -- 1395
function ensureSafeSearchGlobs(globs) -- 1535
	local result = {} -- 1536
	do -- 1536
		local i = 0 -- 1537
		while i < #globs do -- 1537
			result[#result + 1] = globs[i + 1] -- 1538
			i = i + 1 -- 1537
		end -- 1537
	end -- 1537
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1540
	do -- 1540
		local i = 0 -- 1541
		while i < #requiredExcludes do -- 1541
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1541
				result[#result + 1] = requiredExcludes[i + 1] -- 1543
			end -- 1543
			i = i + 1 -- 1541
		end -- 1541
	end -- 1541
	return result -- 1546
end -- 1546
local TABLE_TASK = "AgentTask" -- 297
local TABLE_CP = "AgentCheckpoint" -- 298
local TABLE_ENTRY = "AgentCheckpointEntry" -- 299
ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 300
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 301
local AGENT_DOWNLOAD_TEMP_DIR = "agent" -- 302
local function now() -- 303
	return os.time() -- 303
end -- 303
local function toBool(v) -- 305
	return v ~= 0 and v ~= false and v ~= nil -- 306
end -- 305
local function toStr(v) -- 309
	if v == false or v == nil then -- 309
		return "" -- 310
	end -- 310
	return tostring(v) -- 311
end -- 309
local function isValidWorkspacePath(path) -- 314
	if not path or #path == 0 then -- 314
		return false -- 315
	end -- 315
	if Content:isAbsolutePath(path) then -- 315
		return false -- 316
	end -- 316
	if __TS__StringIncludes(path, "..") then -- 316
		return false -- 317
	end -- 317
	return true -- 318
end -- 314
local function isValidWorkDir(workDir) -- 321
	if not workDir or #workDir == 0 then -- 321
		return false -- 322
	end -- 322
	if not Content:isAbsolutePath(workDir) then -- 322
		return false -- 323
	end -- 323
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 323
		return false -- 324
	end -- 324
	return true -- 325
end -- 321
local function isValidSearchPath(path) -- 328
	if path == "" then -- 328
		return true -- 329
	end -- 329
	if Content:isAbsolutePath(path) then -- 329
		return false -- 330
	end -- 330
	if not path or #path == 0 then -- 330
		return false -- 331
	end -- 331
	if __TS__StringIncludes(path, "..") then -- 331
		return false -- 332
	end -- 332
	return true -- 333
end -- 328
local function resolveWorkspaceFilePath(workDir, path) -- 336
	if not isValidWorkDir(workDir) then -- 336
		return nil -- 337
	end -- 337
	if not isValidWorkspacePath(path) then -- 337
		return nil -- 338
	end -- 338
	return Path(workDir, path) -- 339
end -- 336
local function resolveWorkspaceSearchPath(workDir, path) -- 342
	if not isValidWorkDir(workDir) then -- 342
		return nil -- 343
	end -- 343
	if not isValidSearchPath(path) then -- 343
		return nil -- 344
	end -- 344
	return path == "" and workDir or Path(workDir, path) -- 345
end -- 342
local function toWorkspaceRelativePath(workDir, path) -- 348
	if not path or #path == 0 then -- 348
		return path -- 349
	end -- 349
	if not Content:isAbsolutePath(path) then -- 349
		return path -- 350
	end -- 350
	return Path:getRelative(path, workDir) -- 351
end -- 348
local function toWorkspaceRelativeFileList(workDir, files) -- 354
	return __TS__ArrayMap( -- 355
		files, -- 355
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 355
	) -- 355
end -- 354
local function toWorkspaceRelativeSearchResults(workDir, results) -- 358
	local mapped = {} -- 359
	do -- 359
		local i = 0 -- 360
		while i < #results do -- 360
			local row = results[i + 1] -- 361
			local clone = __TS__ObjectAssign({}, row) -- 362
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 363
			mapped[#mapped + 1] = clone -- 364
			i = i + 1 -- 360
		end -- 360
	end -- 360
	return mapped -- 366
end -- 358
local function resolveWorkspaceDirectoryPath(workDir, path) -- 369
	local relative = __TS__StringTrim(path or "") -- 370
	if relative == "" then -- 370
		return {success = true, path = workDir, relative = "."} -- 372
	end -- 372
	if not isValidWorkDir(workDir) or not isValidWorkspacePath(relative) then -- 372
		return {success = false, message = "invalid cwd path"} -- 375
	end -- 375
	local resolved = Path(workDir, relative) -- 377
	if not Content:exist(resolved) then -- 377
		return {success = false, message = "cwd does not exist"} -- 379
	end -- 379
	if not Content:isdir(resolved) then -- 379
		return {success = false, message = "cwd is not a directory"} -- 382
	end -- 382
	return {success = true, path = resolved, relative = relative} -- 384
end -- 369
local function getDoraAPIDocRoot(docLanguage) -- 387
	local zhDir = Path( -- 388
		Content.assetPath, -- 388
		"Script", -- 388
		"Lib", -- 388
		"Dora", -- 388
		"zh-Hans" -- 388
	) -- 388
	local enDir = Path( -- 389
		Content.assetPath, -- 389
		"Script", -- 389
		"Lib", -- 389
		"Dora", -- 389
		"en" -- 389
	) -- 389
	return docLanguage == "zh" and zhDir or enDir -- 390
end -- 387
local function getDoraTutorialDocRoot(docLanguage) -- 393
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 394
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 395
	return docLanguage == "zh" and zhDir or enDir -- 396
end -- 393
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 399
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 399
		return {"ts"} -- 401
	end -- 401
	return {"tl"} -- 403
end -- 399
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 406
	repeat -- 406
		local ____switch43 = programmingLanguage -- 406
		local ____cond43 = ____switch43 == "teal" -- 406
		if ____cond43 then -- 406
			return "tl" -- 408
		end -- 408
		____cond43 = ____cond43 or ____switch43 == "tl" -- 408
		if ____cond43 then -- 408
			return "tl" -- 409
		end -- 409
		do -- 409
			return programmingLanguage -- 410
		end -- 410
	until true -- 410
end -- 406
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 414
	if docSource == "tutorial" then -- 414
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 420
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 421
		return { -- 422
			root = Path(tutorialRoot, langDir), -- 423
			exts = {"md"}, -- 424
			globs = {"**/*.md"} -- 425
		} -- 425
	end -- 425
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 428
	return { -- 429
		root = getDoraAPIDocRoot(docLanguage), -- 430
		exts = exts, -- 431
		globs = __TS__ArrayMap( -- 432
			exts, -- 432
			function(____, ext) return "**/*." .. ext end -- 432
		) -- 432
	} -- 432
end -- 414
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 436
	if docSource == "tutorial" then -- 436
		return getDoraTutorialDocRoot(docLanguage) -- 438
	end -- 438
	return getDoraAPIDocRoot(docLanguage) -- 440
end -- 436
local function toDocRelativePath(baseRoot, path) -- 443
	if not path or #path == 0 then -- 443
		return path -- 444
	end -- 444
	if not Content:isAbsolutePath(path) then -- 444
		return path -- 445
	end -- 445
	return Path:getRelative(path, baseRoot) -- 446
end -- 443
local function resolveAgentTutorialDocFilePath(path, docLanguage) -- 449
	if not docLanguage then -- 449
		return nil -- 450
	end -- 450
	if not isValidWorkspacePath(path) then -- 450
		return nil -- 451
	end -- 451
	local candidate = Path( -- 452
		getDoraTutorialDocRoot(docLanguage), -- 452
		path -- 452
	) -- 452
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 452
		return candidate -- 454
	end -- 454
	return nil -- 456
end -- 449
local function ensureDirPath(dir) -- 459
	if not dir or dir == "." or dir == "" then -- 459
		return true -- 460
	end -- 460
	if Content:exist(dir) then -- 460
		return Content:isdir(dir) -- 461
	end -- 461
	local parent = Path:getPath(dir) -- 462
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 462
		if not ensureDirPath(parent) then -- 462
			return false -- 464
		end -- 464
	end -- 464
	return Content:mkdir(dir) -- 466
end -- 459
local function ensureDirForFile(path) -- 469
	local dir = Path:getPath(path) -- 470
	return ensureDirPath(dir) -- 471
end -- 469
local function isHttpUrl(url) -- 474
	local normalized = string.lower(__TS__StringTrim(url)) -- 475
	return __TS__StringStartsWith(normalized, "http://") or __TS__StringStartsWith(normalized, "https://") -- 476
end -- 474
local function createOperationId() -- 479
	local raw = (tostring(os.time()) .. "-") .. tostring(math.floor(math.random() * 1000000000)) -- 480
	local safe = string.gsub(raw, "[^%w%-_]", "-") -- 481
	return safe -- 482
end -- 479
local function getAgentDownloadTempRoot() -- 485
	return Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR, AGENT_DOWNLOAD_TEMP_DIR) -- 486
end -- 485
local function cleanupPath(path) -- 489
	if not path or path == "" or not Content:exist(path) then -- 489
		return nil -- 490
	end -- 490
	if Content:remove(path) then -- 490
		return nil -- 491
	end -- 491
	return "failed to remove temporary path: " .. path -- 492
end -- 489
local function quoteGitArg(value) -- 495
	if ({string.match(value, "^[%w%._%-%/]+$")}) ~= nil then -- 495
		return value -- 497
	end -- 497
	local escaped = string.gsub(value, "\\", "\\\\") -- 499
	escaped = string.gsub(escaped, "\"", "\\\"") -- 500
	return ("\"" .. escaped) .. "\"" -- 501
end -- 495
local function shellSplit(command) -- 504
	local args = {} -- 505
	local current = "" -- 506
	local quote = "" -- 507
	local escaped = false -- 508
	do -- 508
		local i = 0 -- 509
		while i < #command do -- 509
			do -- 509
				local ch = __TS__StringCharAt(command, i) -- 510
				if escaped then -- 510
					current = current .. ch -- 512
					escaped = false -- 513
					goto __continue72 -- 514
				end -- 514
				if ch == "\\" then -- 514
					escaped = true -- 517
					goto __continue72 -- 518
				end -- 518
				if quote ~= "" then -- 518
					if ch == quote then -- 518
						quote = "" -- 522
					else -- 522
						current = current .. ch -- 524
					end -- 524
					goto __continue72 -- 526
				end -- 526
				if ch == "'" or ch == "\"" then -- 526
					quote = ch -- 529
					goto __continue72 -- 530
				end -- 530
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 530
					if current ~= "" then -- 530
						args[#args + 1] = current -- 534
						current = "" -- 535
					end -- 535
					goto __continue72 -- 537
				end -- 537
				current = current .. ch -- 539
			end -- 539
			::__continue72:: -- 539
			i = i + 1 -- 509
		end -- 509
	end -- 509
	if escaped then -- 509
		current = current .. "\\" -- 542
	end -- 542
	if current ~= "" then -- 542
		args[#args + 1] = current -- 545
	end -- 545
	return args -- 547
end -- 504
local function normalizeGitCommand(command) -- 550
	local trimmed = __TS__StringTrim(command) -- 551
	if string.lower(string.sub(trimmed, 1, 4)) == "git " then -- 551
		return __TS__StringTrim(string.sub(trimmed, 5)) -- 553
	end -- 553
	return trimmed -- 555
end -- 550
local function gitDefaultTargetFromUrl(url) -- 558
	local target = url -- 559
	local hashIndex = (string.find(target, "#", nil, true) or 0) - 1 -- 560
	if hashIndex >= 0 then -- 560
		target = __TS__StringSlice(target, 0, hashIndex) -- 561
	end -- 561
	local queryIndex = (string.find(target, "?", nil, true) or 0) - 1 -- 562
	if queryIndex >= 0 then -- 562
		target = __TS__StringSlice(target, 0, queryIndex) -- 563
	end -- 563
	target = string.gsub(target, "/+$", "") -- 564
	local name = string.match(target, "([^/]+)$") -- 565
	if name ~= nil and name ~= "" then -- 565
		target = name -- 566
	end -- 566
	if __TS__StringEndsWith( -- 566
		string.lower(target), -- 567
		".git" -- 567
	) then -- 567
		target = __TS__StringSlice(target, 0, #target - 4) -- 568
	end -- 568
	return target ~= "" and target or "repo" -- 570
end -- 558
local function parseGitCloneCommand(command) -- 573
	local args = shellSplit(normalizeGitCommand(command)) -- 583
	if #args == 0 or args[1] ~= "clone" then -- 583
		return nil -- 584
	end -- 584
	local url = "" -- 585
	local target = "" -- 586
	local ref -- 587
	local depth -- 588
	do -- 588
		local i = 1 -- 589
		while i < #args do -- 589
			do -- 589
				local arg = args[i + 1] -- 590
				if arg == "-b" or arg == "--branch" then
					i = i + 1 -- 592
					if i >= #args then -- 592
						return {success = false, message = arg .. " requires a value"} -- 593
					end -- 593
					ref = args[i + 1] -- 594
					goto __continue93 -- 595
				end -- 595
				if arg == "--depth" then
					i = i + 1 -- 598
					if i >= #args then -- 598
						return {success = false, message = "--depth requires a value"}
					end -- 599
					depth = args[i + 1] -- 600
					goto __continue93 -- 601
				end -- 601
				if __TS__StringStartsWith(arg, "--depth=") then
					depth = __TS__StringSlice(arg, #"--depth=")
					goto __continue93 -- 605
				end -- 605
				if __TS__StringStartsWith(arg, "-") then -- 605
					return {success = false, message = "unsupported clone option: " .. arg} -- 608
				end -- 608
				if url == "" then -- 608
					url = arg -- 611
					goto __continue93 -- 612
				end -- 612
				if target == "" then -- 612
					target = arg -- 615
					goto __continue93 -- 616
				end -- 616
				return {success = false, message = "unexpected clone argument: " .. arg} -- 618
			end -- 618
			::__continue93:: -- 618
			i = i + 1 -- 589
		end -- 589
	end -- 589
	if url == "" then -- 589
		return {success = false, message = "git clone requires a URL"} -- 620
	end -- 620
	if not isHttpUrl(url) then -- 620
		return {success = false, message = "git clone only supports http:// and https:// URLs"} -- 621
	end -- 621
	if target == "" then -- 621
		target = gitDefaultTargetFromUrl(url) -- 622
	end -- 622
	return { -- 623
		success = true, -- 624
		url = url, -- 625
		target = target, -- 626
		ref = ref, -- 627
		depth = depth ~= nil and depth ~= "" and depth or "1" -- 628
	} -- 628
end -- 573
local function getGitHeadCommit(repoPath) -- 632
	local headPath = Path(repoPath, ".git", "HEAD") -- 633
	if not Content:exist(headPath) then -- 633
		return nil -- 634
	end -- 634
	local head = __TS__StringTrim(toStr(Content:load(headPath))) -- 635
	local ref = string.match(head, "^ref:%s*(.-)%s*$") -- 636
	if ref ~= nil and ref ~= "" then -- 636
		local refPath = Path(repoPath, ".git", ref) -- 638
		if Content:exist(refPath) then -- 638
			local commit = __TS__StringTrim(toStr(Content:load(refPath))) -- 640
			return commit ~= "" and commit or nil -- 641
		end -- 641
		return nil -- 643
	end -- 643
	return head ~= "" and head or nil -- 645
end -- 632
local function runGitAndWait(repoPath, command, onStatus, isCancelled, timeout) -- 648
	if timeout == nil then -- 648
		timeout = 600 -- 653
	end -- 653
	return __TS__New( -- 655
		__TS__Promise, -- 655
		function(____, resolve) -- 655
			local status -- 656
			local jobId = 0 -- 657
			local settled = false -- 658
			local canceled = false -- 659
			local function finish(result) -- 660
				if settled then -- 660
					return -- 661
				end -- 661
				settled = true -- 662
				resolve(nil, result) -- 663
			end -- 660
			local function finishFromStatus() -- 665
				local state = toStr(status and status.state) -- 666
				if state == "done" then -- 666
					finish({success = true, status = status}) -- 668
					return true -- 669
				end -- 669
				if state == "error" or state == "canceled" then -- 669
					local errorMessage = toStr(status and status.error) -- 672
					local statusMessage = toStr(status and status.message) -- 673
					finish({success = false, message = errorMessage ~= "" and errorMessage or (statusMessage ~= "" and statusMessage or (state == "canceled" and "git command canceled" or "git command failed")), status = status, interrupted = state == "canceled"}) -- 674
					return true -- 680
				end -- 680
				return false -- 682
			end -- 665
			jobId = Git:run( -- 684
				repoPath, -- 684
				command, -- 684
				function(nextStatus) -- 684
					status = nextStatus -- 685
					if onStatus then -- 685
						onStatus(status) -- 686
					end -- 686
					return finishFromStatus() -- 687
				end -- 684
			) -- 684
			if jobId == nil or jobId <= 0 then -- 684
				finish({success = false, message = "failed to start git command"}) -- 690
				return -- 691
			end -- 691
			if not status then -- 691
				local kind = string.match(command, "^(%S+)") -- 694
				status = { -- 695
					id = jobId, -- 696
					state = "queued", -- 697
					kind = toStr(kind), -- 698
					repoPath = repoPath, -- 699
					progress = 0, -- 700
					message = "queued" -- 701
				} -- 701
			end -- 701
			if onStatus then -- 701
				onStatus(status) -- 704
			end -- 704
			local startedAt = os.time() -- 705
			local lastEmitAt = startedAt -- 706
			Director.systemScheduler:schedule(function() -- 707
				if settled then -- 707
					return true -- 708
				end -- 708
				if not canceled and isCancelled and isCancelled() then -- 708
					canceled = true -- 710
					Git:cancel(jobId) -- 711
					finish({success = false, message = "git command canceled", status = status, interrupted = true}) -- 712
					return true -- 713
				end -- 713
				if finishFromStatus() then -- 713
					return true -- 715
				end -- 715
				local nowTime = os.time() -- 716
				if nowTime - startedAt >= timeout then -- 716
					Git:cancel(jobId) -- 718
					finish({success = false, message = "git command timed out", status = status}) -- 719
					return true -- 720
				end -- 720
				if onStatus and status and nowTime > lastEmitAt then -- 720
					lastEmitAt = nowTime -- 723
					onStatus(status) -- 724
				end -- 724
				return false -- 726
			end) -- 707
		end -- 655
	) -- 655
end -- 648
local function downloadFile(req) -- 731
	return __TS__New( -- 738
		__TS__Promise, -- 738
		function(____, resolve) -- 738
			local requestId = 0 -- 739
			local settled = false -- 740
			local bytesWritten = 0 -- 741
			local function finish(result) -- 742
				if settled then -- 742
					return -- 743
				end -- 743
				settled = true -- 744
				requestId = 0 -- 745
				resolve(nil, result) -- 746
			end -- 742
			Director.systemScheduler:schedule(function() -- 748
				if settled then -- 748
					return true -- 749
				end -- 749
				local ____this_7 -- 749
				____this_7 = req -- 750
				local ____opt_6 = ____this_7.isCancelled -- 750
				if (____opt_6 and ____opt_6(____this_7)) == true and requestId ~= 0 then -- 750
					HttpClient:cancel(requestId) -- 751
					finish({success = false, interrupted = true, message = "download canceled"}) -- 752
					return true -- 753
				end -- 753
				if requestId ~= 0 and not HttpClient:isRequestActive(requestId) then -- 753
					finish({success = false, message = "download request ended without a completion callback"}) -- 756
					return true -- 757
				end -- 757
				return false -- 759
			end) -- 748
			Director.systemScheduler:schedule(once(function() -- 761
				requestId = HttpClient:download( -- 762
					req.url, -- 762
					req.tempPath, -- 762
					req.timeout, -- 762
					function(interrupted, current, total) -- 762
						if type(current) == "number" and current > bytesWritten then -- 762
							bytesWritten = current -- 764
						end -- 764
						if interrupted then -- 764
							finish({success = false, interrupted = true, message = "download failed"}) -- 767
							return true -- 768
						end -- 768
						local ____this_9 -- 768
						____this_9 = req -- 770
						local ____opt_8 = ____this_9.isCancelled -- 770
						if (____opt_8 and ____opt_8(____this_9)) == true then -- 770
							finish({success = false, interrupted = true, message = "download canceled"}) -- 771
							return true -- 772
						end -- 772
						if current == total then -- 772
							finish({success = true, bytesWritten = bytesWritten}) -- 775
							return false -- 776
						end -- 776
						req:onProgress(current, total) -- 778
						return false -- 779
					end -- 762
				) -- 762
				if requestId == 0 then -- 762
					finish({success = false, message = "failed to schedule download request"}) -- 782
				else -- 782
					local ____this_11 -- 782
					____this_11 = req -- 783
					local ____opt_10 = ____this_11.isCancelled -- 783
					if (____opt_10 and ____opt_10(____this_11)) == true then -- 783
						HttpClient:cancel(requestId) -- 784
						finish({success = false, interrupted = true, message = "download canceled"}) -- 785
					end -- 785
				end -- 785
			end)) -- 761
		end -- 738
	) -- 738
end -- 731
local function getFileState(path) -- 791
	local exists = Content:exist(path) -- 792
	if not exists then -- 792
		return {exists = false, content = "", bytes = 0} -- 794
	end -- 794
	if Content:isdir(path) then -- 794
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 801
	end -- 801
	local content = Content:load(path) -- 808
	if type(content) ~= "string" then -- 808
		return {exists = true, content = "", bytes = 0} -- 810
	end -- 810
	return {exists = true, content = content, bytes = #content} -- 816
end -- 791
local function inspectReadableFile(path) -- 823
	do -- 823
		local function ____catch(e) -- 823
			Log( -- 845
				"Warn", -- 845
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 845
			) -- 845
			return true, {success = true} -- 846
		end -- 846
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 846
			local size, isBinary = Content:getAttr(path) -- 825
			if size == nil then -- 825
				return true, {success = false, message = "failed to read file"} -- 827
			end -- 827
			if isBinary then -- 827
				return true, { -- 833
					success = false, -- 834
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 835
					size = type(size) == "number" and size or nil, -- 836
					isBinary = true -- 837
				} -- 837
			end -- 837
			return true, { -- 840
				success = true, -- 841
				size = type(size) == "number" and size or nil -- 842
			} -- 842
		end) -- 842
		if not ____try then -- 842
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 842
		end -- 842
		if ____hasReturned then -- 842
			return ____returnValue -- 824
		end -- 824
	end -- 824
end -- 823
local function isEngineLogFilePath(path) -- 850
	return path == ENGINE_LOG_FILE -- 851
end -- 850
local function readEngineLogFile(path) -- 854
	if not isEngineLogFilePath(path) then -- 854
		return nil -- 855
	end -- 855
	local content = getEngineLogText() -- 856
	if content == nil then -- 856
		return {success = false, message = "failed to read engine logs"} -- 858
	end -- 858
	return {success = true, content = content, size = #content} -- 860
end -- 854
local function queryOne(sql, args) -- 863
	local ____args_12 -- 864
	if args then -- 864
		____args_12 = DB:query(sql, args) -- 864
	else -- 864
		____args_12 = DB:query(sql) -- 864
	end -- 864
	local rows = ____args_12 -- 864
	if not rows or #rows == 0 then -- 864
		return nil -- 865
	end -- 865
	return rows[1] -- 866
end -- 863
do -- 863
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 871
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 879
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 890
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 891
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 904
end -- 904
local function isDtsFile(path) -- 907
	return Path:getExt(Path:getName(path)) == "d" -- 908
end -- 907
local function isTiledEditorContent(content) -- 911
	return __TS__StringStartsWith( -- 912
		__TS__StringTrim(content), -- 912
		"<?xml" -- 912
	) -- 912
end -- 911
local function getSupportedBuildKind(path) -- 917
	repeat -- 917
		local ____switch162 = Path:getExt(path) -- 917
		local ____cond162 = ____switch162 == "ts" or ____switch162 == "tsx" -- 917
		if ____cond162 then -- 917
			return "ts" -- 919
		end -- 919
		____cond162 = ____cond162 or ____switch162 == "xml" -- 919
		if ____cond162 then -- 919
			return "xml" -- 920
		end -- 920
		____cond162 = ____cond162 or ____switch162 == "tl" -- 920
		if ____cond162 then -- 920
			return "teal" -- 921
		end -- 921
		____cond162 = ____cond162 or ____switch162 == "lua" -- 921
		if ____cond162 then -- 921
			return "lua" -- 922
		end -- 922
		____cond162 = ____cond162 or ____switch162 == "yue" -- 922
		if ____cond162 then -- 922
			return "yue" -- 923
		end -- 923
		____cond162 = ____cond162 or ____switch162 == "yarn" -- 923
		if ____cond162 then -- 923
			return "yarn" -- 924
		end -- 924
		do -- 924
			return nil -- 925
		end -- 925
	until true -- 925
end -- 917
local function getTaskHeadSeq(taskId) -- 929
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 930
	if not row then -- 930
		return nil -- 931
	end -- 931
	return row[1] or 0 -- 932
end -- 929
local function getTaskStatus(taskId) -- 935
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 936
	if not row then -- 936
		return nil -- 937
	end -- 937
	return toStr(row[1]) -- 938
end -- 935
local function getLastInsertRowId() -- 941
	local row = queryOne("SELECT last_insert_rowid()") -- 942
	return row and (row[1] or 0) or 0 -- 943
end -- 941
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 946
	DB:exec( -- 947
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 947
		{ -- 949
			taskId, -- 949
			seq, -- 949
			status, -- 949
			summary, -- 949
			toolName, -- 949
			now() -- 949
		} -- 949
	) -- 949
	return getLastInsertRowId() -- 951
end -- 946
local function getCheckpointEntries(checkpointId, desc) -- 954
	if desc == nil then -- 954
		desc = false -- 954
	end -- 954
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 955
	if not rows then -- 955
		return {} -- 962
	end -- 962
	local result = {} -- 963
	do -- 963
		local i = 0 -- 964
		while i < #rows do -- 964
			local row = rows[i + 1] -- 965
			result[#result + 1] = { -- 966
				id = row[1], -- 967
				ord = row[2], -- 968
				path = toStr(row[3]), -- 969
				op = toStr(row[4]), -- 970
				beforeExists = toBool(row[5]), -- 971
				beforeContent = toStr(row[6]), -- 972
				afterExists = toBool(row[7]), -- 973
				afterContent = toStr(row[8]) -- 974
			} -- 974
			i = i + 1 -- 964
		end -- 964
	end -- 964
	return result -- 977
end -- 954
local function rejectDuplicatePaths(changes) -- 980
	local seen = __TS__New(Set) -- 981
	for ____, change in ipairs(changes) do -- 982
		local key = change.path -- 983
		if seen:has(key) then -- 983
			return key -- 984
		end -- 984
		seen:add(key) -- 985
	end -- 985
	return nil -- 987
end -- 980
local function getLinkedDeletePaths(workDir, path) -- 990
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 991
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 991
		return {} -- 992
	end -- 992
	local parent = Path:getPath(fullPath) -- 993
	local baseName = string.lower(Path:getName(fullPath)) -- 994
	local ext = Path:getExt(fullPath) -- 995
	local linked = {} -- 996
	for ____, file in ipairs(Content:getFiles(parent)) do -- 997
		do -- 997
			if string.lower(Path:getName(file)) ~= baseName then -- 997
				goto __continue179 -- 998
			end -- 998
			local siblingExt = Path:getExt(file) -- 999
			if siblingExt == "tl" and ext == "vs" then -- 999
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1001
					workDir, -- 1001
					Path(parent, file) -- 1001
				) -- 1001
				goto __continue179 -- 1002
			end -- 1002
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 1002
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1005
					workDir, -- 1005
					Path(parent, file) -- 1005
				) -- 1005
			end -- 1005
		end -- 1005
		::__continue179:: -- 1005
	end -- 1005
	return linked -- 1008
end -- 990
local function expandLinkedDeleteChanges(workDir, changes) -- 1011
	local expanded = {} -- 1012
	local seen = __TS__New(Set) -- 1013
	do -- 1013
		local i = 0 -- 1014
		while i < #changes do -- 1014
			do -- 1014
				local change = changes[i + 1] -- 1015
				if not seen:has(change.path) then -- 1015
					seen:add(change.path) -- 1017
					expanded[#expanded + 1] = change -- 1018
				end -- 1018
				if change.op ~= "delete" then -- 1018
					goto __continue186 -- 1020
				end -- 1020
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 1021
				do -- 1021
					local j = 0 -- 1022
					while j < #linkedPaths do -- 1022
						do -- 1022
							local linkedPath = linkedPaths[j + 1] -- 1023
							if seen:has(linkedPath) then -- 1023
								goto __continue190 -- 1024
							end -- 1024
							seen:add(linkedPath) -- 1025
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 1026
						end -- 1026
						::__continue190:: -- 1026
						j = j + 1 -- 1022
					end -- 1022
				end -- 1022
			end -- 1022
			::__continue186:: -- 1022
			i = i + 1 -- 1014
		end -- 1014
	end -- 1014
	return expanded -- 1029
end -- 1011
local function applySingleFile(path, exists, content) -- 1032
	if exists then -- 1032
		if not ensureDirForFile(path) then -- 1032
			return false -- 1034
		end -- 1034
		return Content:save(path, content) -- 1035
	end -- 1035
	if Content:exist(path) then -- 1035
		return Content:remove(path) -- 1038
	end -- 1038
	return true -- 1040
end -- 1032
local function encodeJSON(obj) -- 1043
	local text = safeJsonEncode(obj) -- 1044
	return text -- 1045
end -- 1043
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 1048
	if HttpServer.wsConnectionCount == 0 then -- 1048
		return true -- 1050
	end -- 1050
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 1052
	if not payload then -- 1052
		return false -- 1054
	end -- 1054
	emit("AppWS", "Send", payload) -- 1056
	return true -- 1057
end -- 1048
function ____exports.sendWebIDERefreshTree() -- 1060
	if HttpServer.wsConnectionCount == 0 then -- 1060
		return true -- 1062
	end -- 1062
	local payload = encodeJSON({name = "RefreshTree"}) -- 1064
	if not payload then -- 1064
		return false -- 1066
	end -- 1066
	emit("AppWS", "Send", payload) -- 1068
	return true -- 1069
end -- 1060
local function syncProjectFileToWebIDE(workDir, path) -- 1072
	local target = resolveWorkspaceFilePath(workDir, path) -- 1073
	if not target then -- 1073
		return false -- 1074
	end -- 1074
	if not Content:exist(target) then -- 1074
		return ____exports.sendWebIDEFileUpdate(target, false, "") -- 1076
	end -- 1076
	if Content:isdir(target) then -- 1076
		return ____exports.sendWebIDERefreshTree() -- 1079
	end -- 1079
	local content = "" -- 1081
	do -- 1081
		local function ____catch(e) -- 1081
			Log( -- 1089
				"Warn", -- 1089
				(("[Agent.Tools] failed to inspect file for Web IDE update file=" .. target) .. ": ") .. tostring(e) -- 1089
			) -- 1089
		end -- 1089
		local ____try, ____hasReturned = pcall(function() -- 1089
			local ____, isBinary = Content:getAttr(target) -- 1083
			if not isBinary then -- 1083
				local loaded = Content:load(target) -- 1085
				content = type(loaded) == "string" and loaded or "" -- 1086
			end -- 1086
		end) -- 1086
		if not ____try then -- 1086
			____catch(____hasReturned) -- 1086
		end -- 1086
	end -- 1086
	return ____exports.sendWebIDEFileUpdate(target, true, content) -- 1091
end -- 1072
local function refreshProjectTree(workDir, path) -- 1094
	local normalized = type(path) == "string" and __TS__StringTrim(path) or "" -- 1095
	if normalized == "" then -- 1095
		return ____exports.sendWebIDERefreshTree() -- 1097
	end -- 1097
	return syncProjectFileToWebIDE(workDir, normalized) -- 1099
end -- 1094
local function syncDownloadedFileToWebIDE(file) -- 1102
	local content = "" -- 1103
	do -- 1103
		local function ____catch(e) -- 1103
			Log( -- 1111
				"Warn", -- 1111
				(("[fetch_url] failed to inspect downloaded file for Web IDE update file=" .. file) .. ": ") .. tostring(e) -- 1111
			) -- 1111
		end -- 1111
		local ____try, ____hasReturned = pcall(function() -- 1111
			local ____, isBinary = Content:getAttr(file) -- 1105
			if not isBinary then -- 1105
				local loaded = Content:load(file) -- 1107
				content = type(loaded) == "string" and loaded or "" -- 1108
			end -- 1108
		end) -- 1108
		if not ____try then -- 1108
			____catch(____hasReturned) -- 1108
		end -- 1108
	end -- 1108
	return ____exports.sendWebIDEFileUpdate(file, true, content) -- 1113
end -- 1102
local function runSingleNonTsBuild(file) -- 1116
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1116
		return ____awaiter_resolve( -- 1116
			nil, -- 1116
			__TS__New( -- 1117
				__TS__Promise, -- 1117
				function(____, resolve) -- 1117
					local moduleName = "Script.Dev.WebServer" -- 1118
					local ____require_result_13 = require(moduleName) -- 1119
					local buildAsync = ____require_result_13.buildAsync -- 1119
					Director.systemScheduler:schedule(once(function() -- 1120
						local result = buildAsync(file) -- 1121
						resolve(nil, result) -- 1122
					end)) -- 1120
				end -- 1117
			) -- 1117
		) -- 1117
	end) -- 1117
end -- 1116
local transpileRequestSeq = 0 -- 1127
function ____exports.runSingleTsTranspile(file, content) -- 1129
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1129
		local done = false -- 1130
		transpileRequestSeq = transpileRequestSeq + 1 -- 1131
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 1132
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 1133
		if HttpServer.wsConnectionCount == 0 then -- 1133
			return ____awaiter_resolve(nil, result) -- 1133
		end -- 1133
		local listener = Node() -- 1141
		listener:gslot( -- 1142
			"AppWS", -- 1142
			function(event) -- 1142
				if event.type ~= "Receive" then -- 1142
					return -- 1143
				end -- 1143
				local res = safeJsonDecode(event.msg) -- 1144
				if not res or __TS__ArrayIsArray(res) then -- 1144
					return -- 1145
				end -- 1145
				local payload = res -- 1146
				if payload.name ~= "TranspileTS" then -- 1146
					return -- 1147
				end -- 1147
				if payload.id ~= requestId then -- 1147
					return -- 1148
				end -- 1148
				if tostring(payload.file) ~= file then -- 1148
					return -- 1149
				end -- 1149
				if payload.success then -- 1149
					local luaFile = Path:replaceExt(file, "lua") -- 1151
					if Content:save( -- 1151
						luaFile, -- 1152
						tostring(payload.luaCode) -- 1152
					) then -- 1152
						result = {success = true, file = file} -- 1153
					else -- 1153
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 1155
					end -- 1155
				else -- 1155
					result = { -- 1158
						success = false, -- 1158
						file = file, -- 1158
						message = tostring(payload.message) -- 1158
					} -- 1158
				end -- 1158
				done = true -- 1160
			end -- 1142
		) -- 1142
		local payload = encodeJSON({name = "TranspileTS", id = requestId, file = file, content = content}) -- 1162
		if not payload then -- 1162
			listener:removeFromParent() -- 1169
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 1169
		end -- 1169
		__TS__Await(__TS__New( -- 1172
			__TS__Promise, -- 1172
			function(____, resolve) -- 1172
				Director.systemScheduler:schedule(once(function() -- 1173
					emit("AppWS", "Send", payload) -- 1174
					wait(function() return done end) -- 1175
					if not done then -- 1175
						listener:removeFromParent() -- 1177
					end -- 1177
					resolve(nil) -- 1179
				end)) -- 1173
			end -- 1172
		)) -- 1172
		return ____awaiter_resolve(nil, result) -- 1172
	end) -- 1172
end -- 1129
function ____exports.createTask(prompt) -- 1185
	if prompt == nil then -- 1185
		prompt = "" -- 1185
	end -- 1185
	local t = now() -- 1186
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 1187
	if affected <= 0 then -- 1187
		return {success = false, message = "failed to create task"} -- 1192
	end -- 1192
	return { -- 1194
		success = true, -- 1194
		taskId = getLastInsertRowId() -- 1194
	} -- 1194
end -- 1185
function ____exports.setTaskStatus(taskId, status) -- 1197
	DB:exec( -- 1198
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 1198
		{ -- 1198
			status, -- 1198
			now(), -- 1198
			taskId -- 1198
		} -- 1198
	) -- 1198
	Log( -- 1199
		"Info", -- 1199
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 1199
	) -- 1199
end -- 1197
function ____exports.listCheckpoints(taskId) -- 1202
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 1203
	if not rows then -- 1203
		return {} -- 1210
	end -- 1210
	local items = {} -- 1211
	do -- 1211
		local i = 0 -- 1212
		while i < #rows do -- 1212
			local row = rows[i + 1] -- 1213
			items[#items + 1] = { -- 1214
				id = row[1], -- 1215
				taskId = row[2], -- 1216
				seq = row[3], -- 1217
				status = toStr(row[4]), -- 1218
				summary = toStr(row[5]), -- 1219
				toolName = toStr(row[6]), -- 1220
				createdAt = row[7] -- 1221
			} -- 1221
			i = i + 1 -- 1212
		end -- 1212
	end -- 1212
	return items -- 1224
end -- 1202
local function listCheckpointIdsForTask(taskId, desc) -- 1227
	if desc == nil then -- 1227
		desc = false -- 1227
	end -- 1227
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 1228
	if not rows then -- 1228
		return {} -- 1235
	end -- 1235
	local items = {} -- 1236
	do -- 1236
		local i = 0 -- 1237
		while i < #rows do -- 1237
			local row = rows[i + 1] -- 1238
			items[#items + 1] = {id = row[1], seq = row[2]} -- 1239
			i = i + 1 -- 1237
		end -- 1237
	end -- 1237
	return items -- 1244
end -- 1227
local function deriveFileOp(beforeExists, afterExists) -- 1247
	if not beforeExists and afterExists then -- 1247
		return "create" -- 1248
	end -- 1248
	if beforeExists and not afterExists then -- 1248
		return "delete" -- 1249
	end -- 1249
	return "write" -- 1250
end -- 1247
function ____exports.summarizeTaskChangeSet(taskId) -- 1253
	if not getTaskStatus(taskId) then -- 1253
		return {success = false, message = "task not found"} -- 1255
	end -- 1255
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1257
	local filesByPath = {} -- 1258
	local latestCheckpointId = nil -- 1264
	local latestCheckpointSeq = nil -- 1265
	do -- 1265
		local i = 0 -- 1266
		while i < #checkpoints do -- 1266
			local checkpoint = checkpoints[i + 1] -- 1267
			latestCheckpointId = checkpoint.id -- 1268
			latestCheckpointSeq = checkpoint.seq -- 1269
			local entries = getCheckpointEntries(checkpoint.id, false) -- 1270
			do -- 1270
				local j = 0 -- 1271
				while j < #entries do -- 1271
					local entry = entries[j + 1] -- 1272
					local item = filesByPath[entry.path] -- 1273
					if not item then -- 1273
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 1275
						filesByPath[entry.path] = item -- 1281
					end -- 1281
					item.afterExists = entry.afterExists -- 1283
					local ____item_checkpointIds_14 = item.checkpointIds -- 1283
					____item_checkpointIds_14[#____item_checkpointIds_14 + 1] = checkpoint.id -- 1284
					j = j + 1 -- 1271
				end -- 1271
			end -- 1271
			i = i + 1 -- 1266
		end -- 1266
	end -- 1266
	local files = {} -- 1287
	for ____, item in pairs(filesByPath) do -- 1288
		files[#files + 1] = { -- 1289
			path = item.path, -- 1290
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1291
			checkpointCount = #item.checkpointIds, -- 1292
			checkpointIds = item.checkpointIds -- 1293
		} -- 1293
	end -- 1293
	__TS__ArraySort( -- 1296
		files, -- 1296
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1296
	) -- 1296
	return { -- 1297
		success = true, -- 1298
		taskId = taskId, -- 1299
		checkpointCount = #checkpoints, -- 1300
		filesChanged = #files, -- 1301
		files = files, -- 1302
		latestCheckpointId = latestCheckpointId, -- 1303
		latestCheckpointSeq = latestCheckpointSeq -- 1304
	} -- 1304
end -- 1253
function ____exports.getTaskChangeSetDiff(taskId) -- 1308
	if not getTaskStatus(taskId) then -- 1308
		return {success = false, message = "task not found"} -- 1310
	end -- 1310
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1312
	if #checkpoints == 0 then -- 1312
		return {success = false, message = "change set not found or empty"} -- 1314
	end -- 1314
	local filesByPath = {} -- 1316
	do -- 1316
		local i = 0 -- 1323
		while i < #checkpoints do -- 1323
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 1324
			do -- 1324
				local j = 0 -- 1325
				while j < #entries do -- 1325
					local entry = entries[j + 1] -- 1326
					local item = filesByPath[entry.path] -- 1327
					if not item then -- 1327
						item = { -- 1329
							path = entry.path, -- 1330
							beforeExists = entry.beforeExists, -- 1331
							beforeContent = entry.beforeContent, -- 1332
							afterExists = entry.afterExists, -- 1333
							afterContent = entry.afterContent -- 1334
						} -- 1334
						filesByPath[entry.path] = item -- 1336
					end -- 1336
					item.afterExists = entry.afterExists -- 1338
					item.afterContent = entry.afterContent -- 1339
					j = j + 1 -- 1325
				end -- 1325
			end -- 1325
			i = i + 1 -- 1323
		end -- 1323
	end -- 1323
	local files = {} -- 1342
	for ____, item in pairs(filesByPath) do -- 1343
		files[#files + 1] = { -- 1344
			path = item.path, -- 1345
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1346
			beforeExists = item.beforeExists, -- 1347
			afterExists = item.afterExists, -- 1348
			beforeContent = item.beforeContent, -- 1349
			afterContent = item.afterContent -- 1350
		} -- 1350
	end -- 1350
	__TS__ArraySort( -- 1353
		files, -- 1353
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1353
	) -- 1353
	return {success = true, files = files} -- 1354
end -- 1308
local function readWorkspaceFile(workDir, path, docLanguage) -- 1357
	local engineLog = readEngineLogFile(path) -- 1358
	if engineLog then -- 1358
		return engineLog -- 1359
	end -- 1359
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1360
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 1360
		local attr = inspectReadableFile(fullPath) -- 1362
		if not attr.success then -- 1362
			return attr -- 1363
		end -- 1363
		return { -- 1364
			success = true, -- 1364
			content = Content:load(fullPath), -- 1364
			size = attr.size -- 1364
		} -- 1364
	end -- 1364
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 1366
	if docPath then -- 1366
		local attr = inspectReadableFile(docPath) -- 1368
		if not attr.success then -- 1368
			return attr -- 1369
		end -- 1369
		return { -- 1370
			success = true, -- 1370
			content = Content:load(docPath), -- 1370
			size = attr.size -- 1370
		} -- 1370
	end -- 1370
	if not fullPath then -- 1370
		return {success = false, message = "invalid path or workDir"} -- 1372
	end -- 1372
	return {success = false, message = "file not found"} -- 1373
end -- 1357
function ____exports.readFileRaw(workDir, path, docLanguage) -- 1376
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 1377
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 1377
		local attr = inspectReadableFile(path) -- 1379
		if not attr.success then -- 1379
			return attr -- 1380
		end -- 1380
		return { -- 1381
			success = true, -- 1381
			content = Content:load(path), -- 1381
			size = attr.size -- 1381
		} -- 1381
	end -- 1381
	return result -- 1383
end -- 1376
function ____exports.getLogs(req) -- 1398
	local text = getEngineLogText() -- 1399
	if text == nil then -- 1399
		return {success = false, message = "failed to read engine logs"} -- 1401
	end -- 1401
	local tailLines = math.max( -- 1403
		1, -- 1403
		math.floor(req and req.tailLines or 200) -- 1403
	) -- 1403
	local allLines = __TS__StringSplit(text, "\n") -- 1404
	local logs = __TS__ArraySlice( -- 1405
		allLines, -- 1405
		math.max(0, #allLines - tailLines) -- 1405
	) -- 1405
	return req and req.joinText and ({ -- 1406
		success = true, -- 1406
		logs = logs, -- 1406
		text = table.concat(logs, "\n") -- 1406
	}) or ({success = true, logs = logs}) -- 1406
end -- 1398
function ____exports.listFiles(req) -- 1409
	local root = req.path or "" -- 1415
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 1416
	if not searchRoot then -- 1416
		return {success = false, message = "invalid path or workDir"} -- 1418
	end -- 1418
	do -- 1418
		local function ____catch(e) -- 1418
			return true, { -- 1436
				success = false, -- 1436
				message = tostring(e) -- 1436
			} -- 1436
		end -- 1436
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1436
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 1421
			local globs = ensureSafeSearchGlobs(userGlobs) -- 1422
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 1423
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 1424
			local totalEntries = #files -- 1425
			local maxEntries = math.max( -- 1426
				1, -- 1426
				math.floor(req.maxEntries or 200) -- 1426
			) -- 1426
			local truncated = totalEntries > maxEntries -- 1427
			return true, { -- 1428
				success = true, -- 1429
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 1430
				totalEntries = totalEntries, -- 1431
				truncated = truncated, -- 1432
				maxEntries = maxEntries -- 1433
			} -- 1433
		end) -- 1433
		if not ____try then -- 1433
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1433
		end -- 1433
		if ____hasReturned then -- 1433
			return ____returnValue -- 1420
		end -- 1420
	end -- 1420
end -- 1409
local function formatReadSlice(content, startLine, endLine) -- 1440
	local lines = __TS__StringSplit(content, "\n") -- 1445
	local totalLines = #lines -- 1446
	if totalLines == 0 then -- 1446
		return { -- 1448
			success = true, -- 1449
			content = "", -- 1450
			totalLines = 0, -- 1451
			startLine = 1, -- 1452
			endLine = 0, -- 1453
			truncated = false -- 1454
		} -- 1454
	end -- 1454
	local rawStart = math.floor(startLine) -- 1457
	local rawEnd = math.floor(endLine) -- 1458
	if rawStart == 0 then -- 1458
		return {success = false, message = "startLine cannot be 0"} -- 1460
	end -- 1460
	if rawEnd == 0 then -- 1460
		return {success = false, message = "endLine cannot be 0"} -- 1463
	end -- 1463
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1465
	if start > totalLines then -- 1465
		return { -- 1469
			success = false, -- 1469
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1469
		} -- 1469
	end -- 1469
	local ____end = math.min( -- 1471
		totalLines, -- 1472
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1473
	) -- 1473
	if ____end < start then -- 1473
		return { -- 1478
			success = false, -- 1479
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1480
		} -- 1480
	end -- 1480
	local slice = {} -- 1483
	do -- 1483
		local i = start -- 1484
		while i <= ____end do -- 1484
			slice[#slice + 1] = lines[i] -- 1485
			i = i + 1 -- 1484
		end -- 1484
	end -- 1484
	local truncated = start > 1 or ____end < totalLines -- 1487
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1488
	local body = table.concat(slice, "\n") -- 1493
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1494
	return { -- 1495
		success = true, -- 1496
		content = output, -- 1497
		totalLines = totalLines, -- 1498
		startLine = start, -- 1499
		endLine = ____end, -- 1500
		truncated = truncated -- 1501
	} -- 1501
end -- 1440
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1505
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1512
	if not fallback.success or fallback.content == nil then -- 1512
		return fallback -- 1513
	end -- 1513
	local resolvedStartLine = startLine or 1 -- 1514
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1515
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1516
end -- 1505
local codeExtensions = { -- 1523
	".lua", -- 1523
	".tl", -- 1523
	".yue", -- 1523
	".ts", -- 1523
	".tsx", -- 1523
	".xml", -- 1523
	".md", -- 1523
	".yarn", -- 1523
	".wa", -- 1523
	".mod" -- 1523
} -- 1523
extensionLevels = { -- 1524
	vs = 2, -- 1525
	bl = 2, -- 1526
	ts = 1, -- 1527
	tsx = 1, -- 1528
	tl = 1, -- 1529
	yue = 1, -- 1530
	xml = 1, -- 1531
	lua = 0 -- 1532
} -- 1532
local function splitSearchPatterns(pattern) -- 1549
	local trimmed = __TS__StringTrim(pattern or "") -- 1550
	if trimmed == "" then -- 1550
		return {} -- 1551
	end -- 1551
	local out = {} -- 1552
	local seen = __TS__New(Set) -- 1553
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1554
		local p = __TS__StringTrim(tostring(p0)) -- 1555
		if p ~= "" and not seen:has(p) then -- 1555
			seen:add(p) -- 1557
			out[#out + 1] = p -- 1558
		end -- 1558
	end -- 1558
	return out -- 1561
end -- 1549
local function mergeSearchFileResultsUnique(resultsList) -- 1564
	local merged = {} -- 1565
	local seen = __TS__New(Set) -- 1566
	do -- 1566
		local i = 0 -- 1567
		while i < #resultsList do -- 1567
			local list = resultsList[i + 1] -- 1568
			do -- 1568
				local j = 0 -- 1569
				while j < #list do -- 1569
					do -- 1569
						local row = list[j + 1] -- 1570
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1571
						if seen:has(key) then -- 1571
							goto __continue312 -- 1572
						end -- 1572
						seen:add(key) -- 1573
						merged[#merged + 1] = list[j + 1] -- 1574
					end -- 1574
					::__continue312:: -- 1574
					j = j + 1 -- 1569
				end -- 1569
			end -- 1569
			i = i + 1 -- 1567
		end -- 1567
	end -- 1567
	return merged -- 1577
end -- 1564
local function buildGroupedSearchResults(results) -- 1580
	local order = {} -- 1585
	local grouped = __TS__New(Map) -- 1586
	do -- 1586
		local i = 0 -- 1591
		while i < #results do -- 1591
			local row = results[i + 1] -- 1592
			local file = row.file -- 1593
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1594
			local bucket = grouped:get(key) -- 1595
			if not bucket then -- 1595
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1597
				grouped:set(key, bucket) -- 1598
				order[#order + 1] = key -- 1599
			end -- 1599
			bucket.totalMatches = bucket.totalMatches + 1 -- 1601
			local ____bucket_matches_19 = bucket.matches -- 1601
			____bucket_matches_19[#____bucket_matches_19 + 1] = results[i + 1] -- 1602
			i = i + 1 -- 1591
		end -- 1591
	end -- 1591
	local out = {} -- 1604
	do -- 1604
		local i = 0 -- 1609
		while i < #order do -- 1609
			local bucket = grouped:get(order[i + 1]) -- 1610
			if bucket then -- 1610
				out[#out + 1] = bucket -- 1611
			end -- 1611
			i = i + 1 -- 1609
		end -- 1609
	end -- 1609
	return out -- 1613
end -- 1580
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1616
	local merged = {} -- 1617
	local seen = __TS__New(Set) -- 1618
	local index = 0 -- 1619
	local advanced = true -- 1620
	while advanced do -- 1620
		advanced = false -- 1622
		do -- 1622
			local i = 0 -- 1623
			while i < #resultsList do -- 1623
				do -- 1623
					local list = resultsList[i + 1] -- 1624
					if index >= #list then -- 1624
						goto __continue324 -- 1625
					end -- 1625
					advanced = true -- 1626
					local row = list[index + 1] -- 1627
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1628
					if seen:has(key) then -- 1628
						goto __continue324 -- 1629
					end -- 1629
					seen:add(key) -- 1630
					merged[#merged + 1] = row -- 1631
				end -- 1631
				::__continue324:: -- 1631
				i = i + 1 -- 1623
			end -- 1623
		end -- 1623
		index = index + 1 -- 1633
	end -- 1633
	return merged -- 1635
end -- 1616
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1638
	if docSource ~= "api" then -- 1638
		return 100 -- 1639
	end -- 1639
	if programmingLanguage ~= "tsx" then -- 1639
		return 100 -- 1640
	end -- 1640
	repeat -- 1640
		local ____switch330 = string.lower(Path:getFilename(file)) -- 1640
		local ____cond330 = ____switch330 == "jsx.d.ts" -- 1640
		if ____cond330 then -- 1640
			return 0 -- 1642
		end -- 1642
		____cond330 = ____cond330 or ____switch330 == "dorax.d.ts" -- 1642
		if ____cond330 then -- 1642
			return 1 -- 1643
		end -- 1643
		____cond330 = ____cond330 or ____switch330 == "dora.d.ts" -- 1643
		if ____cond330 then -- 1643
			return 2 -- 1644
		end -- 1644
		do -- 1644
			return 100 -- 1645
		end -- 1645
	until true -- 1645
end -- 1638
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1649
	local sorted = __TS__ArraySlice(hits) -- 1654
	__TS__ArraySort( -- 1655
		sorted, -- 1655
		function(____, a, b) -- 1655
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1656
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1657
			if pa ~= pb then -- 1657
				return pa - pb -- 1658
			end -- 1658
			local fa = string.lower(a.file) -- 1659
			local fb = string.lower(b.file) -- 1660
			if fa ~= fb then -- 1660
				return fa < fb and -1 or 1 -- 1661
			end -- 1661
			return (a.line or 0) - (b.line or 0) -- 1662
		end -- 1655
	) -- 1655
	return sorted -- 1664
end -- 1649
function ____exports.searchFiles(req) -- 1667
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1667
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1680
		if not resolvedPath then -- 1680
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1680
		end -- 1680
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1684
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1685
		if not searchRoot then -- 1685
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1685
		end -- 1685
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1685
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1685
		end -- 1685
		local patterns = splitSearchPatterns(req.pattern) -- 1692
		if #patterns == 0 then -- 1692
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1692
		end -- 1692
		return ____awaiter_resolve( -- 1692
			nil, -- 1692
			__TS__New( -- 1696
				__TS__Promise, -- 1696
				function(____, resolve) -- 1696
					Director.systemScheduler:schedule(once(function() -- 1697
						do -- 1697
							local function ____catch(e) -- 1697
								resolve( -- 1739
									nil, -- 1739
									{ -- 1739
										success = false, -- 1739
										message = tostring(e) -- 1739
									} -- 1739
								) -- 1739
							end -- 1739
							local ____try, ____hasReturned = pcall(function() -- 1739
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1699
								local allResults = {} -- 1702
								do -- 1702
									local i = 0 -- 1703
									while i < #patterns do -- 1703
										local ____Content_24 = Content -- 1704
										local ____Content_searchFilesAsync_25 = Content.searchFilesAsync -- 1704
										local ____patterns_index_23 = patterns[i + 1] -- 1709
										local ____req_useRegex_20 = req.useRegex -- 1710
										if ____req_useRegex_20 == nil then -- 1710
											____req_useRegex_20 = false -- 1710
										end -- 1710
										local ____req_caseSensitive_21 = req.caseSensitive -- 1711
										if ____req_caseSensitive_21 == nil then -- 1711
											____req_caseSensitive_21 = false -- 1711
										end -- 1711
										local ____req_includeContent_22 = req.includeContent -- 1712
										if ____req_includeContent_22 == nil then -- 1712
											____req_includeContent_22 = true -- 1712
										end -- 1712
										allResults[#allResults + 1] = ____Content_searchFilesAsync_25( -- 1704
											____Content_24, -- 1704
											searchRoot, -- 1705
											codeExtensions, -- 1706
											extensionLevels, -- 1707
											searchGlobs, -- 1708
											____patterns_index_23, -- 1709
											____req_useRegex_20, -- 1710
											____req_caseSensitive_21, -- 1711
											____req_includeContent_22, -- 1712
											req.contentWindow or 120 -- 1713
										) -- 1713
										i = i + 1 -- 1703
									end -- 1703
								end -- 1703
								local results = mergeSearchFileResultsUnique(allResults) -- 1716
								local totalResults = #results -- 1717
								local limit = math.max( -- 1718
									1, -- 1718
									math.floor(req.limit or 20) -- 1718
								) -- 1718
								local offset = math.max( -- 1719
									0, -- 1719
									math.floor(req.offset or 0) -- 1719
								) -- 1719
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1720
								local nextOffset = offset + #paged -- 1721
								local hasMore = nextOffset < totalResults -- 1722
								local truncated = offset > 0 or hasMore -- 1723
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1724
								local groupByFile = req.groupByFile == true -- 1725
								resolve( -- 1726
									nil, -- 1726
									{ -- 1726
										success = true, -- 1727
										results = relativeResults, -- 1728
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1729
										totalResults = totalResults, -- 1730
										truncated = truncated, -- 1731
										limit = limit, -- 1732
										offset = offset, -- 1733
										nextOffset = nextOffset, -- 1734
										hasMore = hasMore, -- 1735
										groupByFile = groupByFile -- 1736
									} -- 1736
								) -- 1736
							end) -- 1736
							if not ____try then -- 1736
								____catch(____hasReturned) -- 1736
							end -- 1736
						end -- 1736
					end)) -- 1697
				end -- 1696
			) -- 1696
		) -- 1696
	end) -- 1696
end -- 1667
function ____exports.searchDoraAPI(req) -- 1745
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1745
		local pattern = __TS__StringTrim(req.pattern or "") -- 1756
		if pattern == "" then -- 1756
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1756
		end -- 1756
		local patterns = splitSearchPatterns(pattern) -- 1758
		if #patterns == 0 then -- 1758
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1758
		end -- 1758
		local docSource = req.docSource or "api" -- 1760
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1761
		local docRoot = target.root -- 1762
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1763
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1763
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1763
		end -- 1763
		local exts = target.exts -- 1767
		local dotExts = __TS__ArrayMap( -- 1768
			exts, -- 1768
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1768
		) -- 1768
		local globs = target.globs -- 1769
		local limit = math.max( -- 1770
			1, -- 1770
			math.floor(req.limit or 10) -- 1770
		) -- 1770
		return ____awaiter_resolve( -- 1770
			nil, -- 1770
			__TS__New( -- 1772
				__TS__Promise, -- 1772
				function(____, resolve) -- 1772
					Director.systemScheduler:schedule(once(function() -- 1773
						do -- 1773
							local function ____catch(e) -- 1773
								resolve( -- 1815
									nil, -- 1815
									{ -- 1815
										success = false, -- 1815
										message = tostring(e) -- 1815
									} -- 1815
								) -- 1815
							end -- 1815
							local ____try, ____hasReturned = pcall(function() -- 1815
								local allHits = {} -- 1775
								do -- 1775
									local p = 0 -- 1776
									while p < #patterns do -- 1776
										local ____Content_30 = Content -- 1777
										local ____Content_searchFilesAsync_31 = Content.searchFilesAsync -- 1777
										local ____array_29 = __TS__SparseArrayNew( -- 1777
											docRoot, -- 1778
											dotExts, -- 1779
											{}, -- 1780
											ensureSafeSearchGlobs(globs), -- 1781
											patterns[p + 1] -- 1782
										) -- 1782
										local ____req_useRegex_26 = req.useRegex -- 1783
										if ____req_useRegex_26 == nil then -- 1783
											____req_useRegex_26 = false -- 1783
										end -- 1783
										__TS__SparseArrayPush(____array_29, ____req_useRegex_26) -- 1783
										local ____req_caseSensitive_27 = req.caseSensitive -- 1784
										if ____req_caseSensitive_27 == nil then -- 1784
											____req_caseSensitive_27 = false -- 1784
										end -- 1784
										__TS__SparseArrayPush(____array_29, ____req_caseSensitive_27) -- 1784
										local ____req_includeContent_28 = req.includeContent -- 1785
										if ____req_includeContent_28 == nil then -- 1785
											____req_includeContent_28 = true -- 1785
										end -- 1785
										__TS__SparseArrayPush(____array_29, ____req_includeContent_28, req.contentWindow or 80) -- 1785
										local raw = ____Content_searchFilesAsync_31( -- 1777
											____Content_30, -- 1777
											__TS__SparseArraySpread(____array_29) -- 1777
										) -- 1777
										local hits = {} -- 1788
										do -- 1788
											local i = 0 -- 1789
											while i < #raw do -- 1789
												do -- 1789
													local row = raw[i + 1] -- 1790
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1791
													if file == "" then -- 1791
														goto __continue357 -- 1792
													end -- 1792
													hits[#hits + 1] = { -- 1793
														file = file, -- 1794
														line = type(row.line) == "number" and row.line or nil, -- 1795
														content = type(row.content) == "string" and row.content or nil -- 1796
													} -- 1796
												end -- 1796
												::__continue357:: -- 1796
												i = i + 1 -- 1789
											end -- 1789
										end -- 1789
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1799
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1799
											0, -- 1799
											limit -- 1799
										) -- 1799
										p = p + 1 -- 1776
									end -- 1776
								end -- 1776
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1801
								resolve(nil, { -- 1802
									success = true, -- 1803
									docSource = docSource, -- 1804
									docLanguage = req.docLanguage, -- 1805
									programmingLanguage = req.programmingLanguage, -- 1806
									exts = exts, -- 1807
									results = hits, -- 1808
									hint = "Use read_file directly with the file value from a search result to view the complete document. Do not add any prefixes.", -- 1809
									totalResults = #hits, -- 1810
									truncated = false, -- 1811
									limit = limit -- 1812
								}) -- 1812
							end) -- 1812
							if not ____try then -- 1812
								____catch(____hasReturned) -- 1812
							end -- 1812
						end -- 1812
					end)) -- 1773
				end -- 1772
			) -- 1772
		) -- 1772
	end) -- 1772
end -- 1745
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1821
	if options == nil then -- 1821
		options = {} -- 1821
	end -- 1821
	if #changes == 0 then -- 1821
		return {success = false, message = "empty changes"} -- 1823
	end -- 1823
	if not isValidWorkDir(workDir) then -- 1823
		return {success = false, message = "invalid workDir"} -- 1826
	end -- 1826
	if not getTaskStatus(taskId) then -- 1826
		return {success = false, message = "task not found"} -- 1829
	end -- 1829
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1831
	local dup = rejectDuplicatePaths(expandedChanges) -- 1832
	if dup then -- 1832
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1834
	end -- 1834
	for ____, change in ipairs(expandedChanges) do -- 1837
		if not isValidWorkspacePath(change.path) then -- 1837
			return {success = false, message = "invalid path: " .. change.path} -- 1839
		end -- 1839
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1839
			return {success = false, message = "missing content for " .. change.path} -- 1842
		end -- 1842
	end -- 1842
	local headSeq = getTaskHeadSeq(taskId) -- 1846
	if headSeq == nil then -- 1846
		return {success = false, message = "task not found"} -- 1847
	end -- 1847
	local nextSeq = headSeq + 1 -- 1848
	local checkpointId = insertCheckpoint( -- 1849
		taskId, -- 1849
		nextSeq, -- 1849
		options.summary or "", -- 1849
		options.toolName or "", -- 1849
		"PREPARED" -- 1849
	) -- 1849
	if checkpointId <= 0 then -- 1849
		return {success = false, message = "failed to create checkpoint"} -- 1851
	end -- 1851
	do -- 1851
		local i = 0 -- 1854
		while i < #expandedChanges do -- 1854
			local change = expandedChanges[i + 1] -- 1855
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1856
			if not fullPath then -- 1856
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1858
				return {success = false, message = "invalid path: " .. change.path} -- 1859
			end -- 1859
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 1859
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1862
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 1863
			end -- 1863
			local before = getFileState(fullPath) -- 1865
			local afterExists = change.op ~= "delete" -- 1866
			local afterContent = afterExists and (change.content or "") or "" -- 1867
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1868
				checkpointId, -- 1872
				i + 1, -- 1873
				change.path, -- 1874
				change.op, -- 1875
				before.exists and 1 or 0, -- 1876
				before.content, -- 1877
				afterExists and 1 or 0, -- 1878
				afterContent, -- 1879
				before.bytes, -- 1880
				#afterContent -- 1881
			}) -- 1881
			if inserted <= 0 then -- 1881
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1885
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1886
			end -- 1886
			i = i + 1 -- 1854
		end -- 1854
	end -- 1854
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1890
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1891
		if not fullPath then -- 1891
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1893
			return {success = false, message = "invalid path: " .. entry.path} -- 1894
		end -- 1894
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1896
		if not ok then -- 1896
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1898
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1899
		end -- 1899
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1899
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1902
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1903
		end -- 1903
	end -- 1903
	DB:exec( -- 1907
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1907
		{ -- 1909
			"APPLIED", -- 1909
			now(), -- 1909
			checkpointId -- 1909
		} -- 1909
	) -- 1909
	DB:exec( -- 1911
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1911
		{ -- 1913
			nextSeq, -- 1913
			now(), -- 1913
			taskId -- 1913
		} -- 1913
	) -- 1913
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1915
end -- 1821
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1923
	if not isValidWorkDir(workDir) then -- 1923
		return {success = false, message = "invalid workDir"} -- 1924
	end -- 1924
	if checkpointId <= 0 then -- 1924
		return {success = false, message = "invalid checkpointId"} -- 1925
	end -- 1925
	local entries = getCheckpointEntries(checkpointId, true) -- 1926
	if #entries == 0 then -- 1926
		return {success = false, message = "checkpoint not found or empty"} -- 1928
	end -- 1928
	for ____, entry in ipairs(entries) do -- 1930
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1931
		if not fullPath then -- 1931
			return {success = false, message = "invalid path: " .. entry.path} -- 1933
		end -- 1933
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1935
		if not ok then -- 1935
			Log( -- 1937
				"Error", -- 1937
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1937
			) -- 1937
			Log( -- 1938
				"Info", -- 1938
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1938
			) -- 1938
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1939
		end -- 1939
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1939
			Log( -- 1942
				"Error", -- 1942
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1942
			) -- 1942
			Log( -- 1943
				"Info", -- 1943
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1943
			) -- 1943
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1944
		end -- 1944
	end -- 1944
	DB:exec( -- 1947
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 1947
		{ -- 1947
			"REVERTED", -- 1947
			now(), -- 1947
			checkpointId -- 1947
		} -- 1947
	) -- 1947
	return {success = true, checkpointId = checkpointId} -- 1948
end -- 1923
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 1951
	if not isValidWorkDir(workDir) then -- 1951
		return {success = false, message = "invalid workDir"} -- 1952
	end -- 1952
	if not getTaskStatus(taskId) then -- 1952
		return {success = false, message = "task not found"} -- 1953
	end -- 1953
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 1954
	if #checkpoints == 0 then -- 1954
		return {success = false, message = "change set not found or empty"} -- 1956
	end -- 1956
	local lastCheckpointId = 0 -- 1958
	do -- 1958
		local i = 0 -- 1959
		while i < #checkpoints do -- 1959
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 1960
			if not result.success then -- 1960
				return {success = false, message = result.message} -- 1961
			end -- 1961
			lastCheckpointId = checkpoints[i + 1].id -- 1962
			i = i + 1 -- 1959
		end -- 1959
	end -- 1959
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 1964
end -- 1951
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1972
	return getCheckpointEntries(checkpointId, false) -- 1973
end -- 1972
function ____exports.getCheckpointDiff(checkpointId) -- 1976
	if checkpointId <= 0 then -- 1976
		return {success = false, message = "invalid checkpointId"} -- 1978
	end -- 1978
	local entries = getCheckpointEntries(checkpointId, false) -- 1980
	if #entries == 0 then -- 1980
		return {success = false, message = "checkpoint not found or empty"} -- 1982
	end -- 1982
	return { -- 1984
		success = true, -- 1985
		files = __TS__ArrayMap( -- 1986
			entries, -- 1986
			function(____, entry) return { -- 1986
				path = entry.path, -- 1987
				op = entry.op, -- 1988
				beforeExists = entry.beforeExists, -- 1989
				afterExists = entry.afterExists, -- 1990
				beforeContent = entry.beforeContent, -- 1991
				afterContent = entry.afterContent -- 1992
			} end -- 1992
		) -- 1992
	} -- 1992
end -- 1976
local function finalizeBuildResult(workDir, messages) -- 1997
	local normalized = __TS__ArrayMap( -- 1998
		messages, -- 1998
		function(____, m) return m.success and __TS__ObjectAssign( -- 1998
			{}, -- 1999
			m, -- 1999
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 1999
		) or __TS__ObjectAssign( -- 1999
			{}, -- 2000
			m, -- 2000
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2000
		) end -- 2000
	) -- 2000
	local total = #normalized -- 2001
	local failed = 0 -- 2002
	do -- 2002
		local i = 0 -- 2003
		while i < #normalized do -- 2003
			if not normalized[i + 1].success then -- 2003
				failed = failed + 1 -- 2004
			end -- 2004
			i = i + 1 -- 2003
		end -- 2003
	end -- 2003
	local passed = total - failed -- 2006
	if failed > 0 then -- 2006
		return { -- 2008
			success = false, -- 2009
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 2010
			total = total, -- 2011
			passed = passed, -- 2012
			failed = failed, -- 2013
			messages = normalized -- 2014
		} -- 2014
	end -- 2014
	return { -- 2017
		success = true, -- 2018
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 2019
		total = total, -- 2020
		passed = passed, -- 2021
		failed = 0, -- 2022
		messages = normalized -- 2023
	} -- 2023
end -- 1997
function ____exports.build(req) -- 2027
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2027
		local targetRel = req.path or "" -- 2028
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2029
		if not target then -- 2029
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2029
		end -- 2029
		if not Content:exist(target) then -- 2029
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2029
		end -- 2029
		local messages = {} -- 2036
		if not Content:isdir(target) then -- 2036
			local kind = getSupportedBuildKind(target) -- 2038
			if not kind then -- 2038
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2038
			end -- 2038
			if kind == "ts" then -- 2038
				local content = Content:load(target) -- 2043
				if content == nil then -- 2043
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2043
				end -- 2043
				if isTiledEditorContent(content) then -- 2043
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2048
					return ____awaiter_resolve( -- 2048
						nil, -- 2048
						finalizeBuildResult(req.workDir, messages) -- 2049
					) -- 2049
				end -- 2049
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2049
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2049
				end -- 2049
				if not isDtsFile(target) then -- 2049
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 2055
				end -- 2055
			else -- 2055
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2058
			end -- 2058
			Log( -- 2060
				"Info", -- 2060
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2060
			) -- 2060
			return ____awaiter_resolve( -- 2060
				nil, -- 2060
				finalizeBuildResult(req.workDir, messages) -- 2061
			) -- 2061
		end -- 2061
		local listResult = ____exports.listFiles({ -- 2063
			workDir = req.workDir, -- 2064
			path = targetRel, -- 2065
			globs = __TS__ArrayMap( -- 2066
				codeExtensions, -- 2066
				function(____, e) return "**/*" .. e end -- 2066
			), -- 2066
			maxEntries = 10000 -- 2067
		}) -- 2067
		local relFiles = listResult.success and listResult.files or ({}) -- 2070
		local tsFileData = {} -- 2071
		local buildQueue = {} -- 2072
		for ____, rel in ipairs(relFiles) do -- 2073
			do -- 2073
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2074
				local kind = getSupportedBuildKind(file) -- 2075
				if not kind then -- 2075
					goto __continue420 -- 2076
				end -- 2076
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2077
				if kind ~= "ts" then -- 2077
					goto __continue420 -- 2079
				end -- 2079
				local content = Content:load(file) -- 2081
				if content == nil then -- 2081
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2083
					goto __continue420 -- 2084
				end -- 2084
				if isTiledEditorContent(content) then -- 2084
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2087
					goto __continue420 -- 2088
				end -- 2088
				tsFileData[file] = content -- 2090
			end -- 2090
			::__continue420:: -- 2090
		end -- 2090
		do -- 2090
			local i = 0 -- 2092
			while i < #buildQueue do -- 2092
				do -- 2092
					local ____buildQueue_index_32 = buildQueue[i + 1] -- 2093
					local file = ____buildQueue_index_32.file -- 2093
					local kind = ____buildQueue_index_32.kind -- 2093
					if kind == "ts" then -- 2093
						local content = tsFileData[file] -- 2095
						if content == nil or isDtsFile(file) then -- 2095
							goto __continue427 -- 2097
						end -- 2097
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2097
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2100
							goto __continue427 -- 2101
						end -- 2101
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 2103
						goto __continue427 -- 2104
					end -- 2104
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2106
				end -- 2106
				::__continue427:: -- 2106
				i = i + 1 -- 2092
			end -- 2092
		end -- 2092
		if #messages == 0 then -- 2092
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2109
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2109
		end -- 2109
		Log( -- 2112
			"Info", -- 2112
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2112
		) -- 2112
		return ____awaiter_resolve( -- 2112
			nil, -- 2112
			finalizeBuildResult(req.workDir, messages) -- 2113
		) -- 2113
	end) -- 2113
end -- 2027
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2116
local function truncateCommandOutput(output) -- 2118
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2118
		return output -- 2119
	end -- 2119
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2120
end -- 2118
local function executeLuaCommand(req) -- 2123
	local code = __TS__StringTrim(req.code or "") -- 2124
	if code == "" then -- 2124
		return __TS__Promise.resolve({ -- 2126
			success = false, -- 2126
			mode = "lua", -- 2126
			output = "", -- 2126
			message = "missing code", -- 2126
			phase = "validate" -- 2126
		}) -- 2126
	end -- 2126
	local output = {} -- 2128
	local env = setmetatable( -- 2129
		{ -- 2129
			projectDir = req.workDir, -- 2130
			print = function(...) -- 2131
				local values = {...} -- 2131
				local parts = {} -- 2132
				do -- 2132
					local i = 0 -- 2133
					while i < #values do -- 2133
						parts[#parts + 1] = tostring(values[i + 1]) -- 2134
						i = i + 1 -- 2133
					end -- 2133
				end -- 2133
				output[#output + 1] = table.concat(parts, "\t") -- 2136
			end, -- 2131
			refreshTree = function(path) -- 2138
				if path == nil then -- 2138
					return refreshProjectTree(req.workDir) -- 2140
				end -- 2140
				if type(path) ~= "string" then -- 2140
					error("refreshTree expects a project-relative file path string or no argument") -- 2143
				end -- 2143
				return refreshProjectTree(req.workDir, path) -- 2145
			end -- 2138
		}, -- 2138
		{__index = Dora} -- 2147
	) -- 2147
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 2150
	if not fn then -- 2150
		return __TS__Promise.resolve({ -- 2152
			success = false, -- 2153
			mode = "lua", -- 2154
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2155
			message = toStr(compileErr), -- 2156
			phase = "compile" -- 2157
		}) -- 2157
	end -- 2157
	return __TS__New( -- 2160
		__TS__Promise, -- 2160
		function(____, resolve) -- 2160
			Director.systemScheduler:schedule(once(function() -- 2161
				local ok, runtimeErr = pcall(fn) -- 2162
				if not ok then -- 2162
					resolve( -- 2164
						nil, -- 2164
						{ -- 2164
							success = false, -- 2165
							mode = "lua", -- 2166
							output = truncateCommandOutput(table.concat(output, "\n")), -- 2167
							message = toStr(runtimeErr), -- 2168
							phase = "execute" -- 2169
						} -- 2169
					) -- 2169
					return -- 2171
				end -- 2171
				resolve( -- 2173
					nil, -- 2173
					{ -- 2173
						success = true, -- 2173
						mode = "lua", -- 2173
						output = truncateCommandOutput(table.concat(output, "\n")) -- 2173
					} -- 2173
				) -- 2173
			end)) -- 2161
		end -- 2160
	) -- 2160
end -- 2123
local function formatGitStatusOutput(status) -- 2178
	if not status then -- 2178
		return "" -- 2179
	end -- 2179
	local lines = {} -- 2180
	local state = toStr(status.state) -- 2181
	local kind = toStr(status.kind) -- 2182
	local message = toStr(status.message) -- 2183
	local errorMessage = toStr(status.error) -- 2184
	if kind ~= "" or state ~= "" then -- 2184
		lines[#lines + 1] = table.concat( -- 2186
			__TS__ArrayFilter( -- 2186
				{kind, state}, -- 2186
				function(____, item) return item ~= "" end -- 2186
			), -- 2186
			": " -- 2186
		) -- 2186
	end -- 2186
	if message ~= "" then -- 2186
		lines[#lines + 1] = message -- 2188
	end -- 2188
	if errorMessage ~= "" then -- 2188
		lines[#lines + 1] = errorMessage -- 2189
	end -- 2189
	local data = status.data -- 2190
	if data ~= nil then -- 2190
		local dataText = encodeJSON(data) -- 2192
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 2193
	end -- 2193
	return truncateCommandOutput(table.concat(lines, "\n")) -- 2195
end -- 2178
local function emitGitProgress(mode, operationId, onProgress, status) -- 2198
	if not onProgress then -- 2198
		return -- 2204
	end -- 2204
	local progress = type(status.progress) == "number" and status.progress or nil -- 2205
	local kind = toStr(status.kind) -- 2206
	local message = toStr(status.message) -- 2207
	local state = toStr(status.state) -- 2208
	local jobId = type(status.id) == "number" and status.id or nil -- 2209
	onProgress({ -- 2210
		state = "running", -- 2211
		mode = mode, -- 2212
		operationId = operationId, -- 2213
		stage = kind ~= "" and kind or "git", -- 2214
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 2215
		progress = progress, -- 2216
		jobId = jobId, -- 2217
		gitState = state ~= "" and state or nil, -- 2218
		gitKind = kind ~= "" and kind or nil -- 2219
	}) -- 2219
end -- 2198
local function cloneGitToTarget(req) -- 2223
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2223
		local parsed = parseGitCloneCommand(req.command) -- 2231
		if parsed == nil then -- 2231
			return ____awaiter_resolve(nil, nil) -- 2231
		end -- 2231
		if not parsed.success then -- 2231
			return ____awaiter_resolve(nil, { -- 2231
				success = false, -- 2234
				mode = "git", -- 2234
				output = "", -- 2234
				message = parsed.message, -- 2234
				phase = "validate" -- 2234
			}) -- 2234
		end -- 2234
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 2236
		if not target then -- 2236
			return ____awaiter_resolve(nil, { -- 2236
				success = false, -- 2238
				mode = "git", -- 2238
				output = "", -- 2238
				message = "invalid clone target path", -- 2238
				phase = "validate" -- 2238
			}) -- 2238
		end -- 2238
		if Content:exist(target) then -- 2238
			return ____awaiter_resolve(nil, { -- 2238
				success = false, -- 2241
				mode = "git", -- 2241
				output = "", -- 2241
				message = "target already exists", -- 2241
				phase = "validate" -- 2241
			}) -- 2241
		end -- 2241
		local targetParent = Path:getPath(target) -- 2243
		if not ensureDirPath(targetParent) then -- 2243
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 2243
		end -- 2243
		local tempRoot = getAgentDownloadTempRoot() -- 2247
		if not ensureDirPath(tempRoot) then -- 2247
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 2247
		end -- 2247
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 2251
		Content:remove(tempPath) -- 2252
		local depth = parsed.depth or "1" -- 2253
		local ____array_33 = __TS__SparseArrayNew( -- 2253
			"clone", -- 2255
			quoteGitArg(parsed.url), -- 2256
			quoteGitArg(Path:getFilename(tempPath)), -- 2257
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 2258
				"-b", -- 2258
				quoteGitArg(parsed.ref) -- 2258
			}) or ({})) -- 2258
		) -- 2258
		__TS__SparseArrayPush( -- 2258
			____array_33, -- 2258
			table.unpack(depth ~= "" and ({ -- 2259
				"--depth",
				quoteGitArg(depth) -- 2259
			}) or ({})) -- 2259
		) -- 2259
		local command = table.concat( -- 2254
			{__TS__SparseArraySpread(____array_33)}, -- 2254
			" " -- 2260
		) -- 2260
		local ____this_35 -- 2260
		____this_35 = req -- 2261
		local ____opt_34 = ____this_35.onProgress -- 2261
		if ____opt_34 ~= nil then -- 2261
			____opt_34(____this_35, { -- 2261
				state = "pending", -- 2262
				mode = "git", -- 2263
				operationId = req.operationId, -- 2264
				stage = "clone", -- 2265
				message = "clone pending", -- 2266
				progress = 0 -- 2267
			}) -- 2267
		end -- 2267
		local gitRes = __TS__Await(runGitAndWait( -- 2269
			tempRoot, -- 2270
			command, -- 2271
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2272
			function() -- 2273
				local ____this_37 -- 2273
				____this_37 = req -- 2273
				local ____opt_36 = ____this_37.isCancelled -- 2273
				return (____opt_36 and ____opt_36(____this_37)) == true -- 2273
			end, -- 2273
			req.timeoutSeconds -- 2274
		)) -- 2274
		if not gitRes.success then -- 2274
			local cleanupError = cleanupPath(tempPath) -- 2277
			local ____formatGitStatusOutput_result_41 = formatGitStatusOutput(gitRes.status) -- 2281
			local ____temp_42 = gitRes.message or "git clone failed" -- 2282
			local ____gitRes_interrupted_40 = gitRes.interrupted -- 2283
			if not ____gitRes_interrupted_40 then -- 2283
				local ____this_39 -- 2283
				____this_39 = req -- 2283
				local ____opt_38 = ____this_39.isCancelled -- 2283
				____gitRes_interrupted_40 = (____opt_38 and ____opt_38(____this_39)) == true -- 2283
			end -- 2283
			return ____awaiter_resolve(nil, { -- 2283
				success = false, -- 2279
				mode = "git", -- 2280
				output = ____formatGitStatusOutput_result_41, -- 2281
				message = ____temp_42, -- 2282
				interrupted = ____gitRes_interrupted_40, -- 2283
				cleanupError = cleanupError -- 2284
			}) -- 2284
		end -- 2284
		if not Content:move(tempPath, target) then -- 2284
			local cleanupError = cleanupPath(tempPath) -- 2288
			return ____awaiter_resolve( -- 2288
				nil, -- 2288
				{ -- 2289
					success = false, -- 2289
					mode = "git", -- 2289
					output = formatGitStatusOutput(gitRes.status), -- 2289
					message = "failed to move cloned repository into target path", -- 2289
					cleanupError = cleanupError -- 2289
				} -- 2289
			) -- 2289
		end -- 2289
		if not refreshProjectTree(req.workDir) then -- 2289
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 2292
		end -- 2292
		local commit = getGitHeadCommit(target) -- 2294
		local output = table.concat( -- 2295
			__TS__ArrayFilter( -- 2295
				{ -- 2295
					formatGitStatusOutput(gitRes.status), -- 2296
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 2296
					commit ~= nil and "commit " .. commit or "" -- 2298
				}, -- 2298
				function(____, item) return item ~= "" end -- 2299
			), -- 2299
			"\n" -- 2299
		) -- 2299
		return ____awaiter_resolve( -- 2299
			nil, -- 2299
			{ -- 2300
				success = true, -- 2300
				mode = "git", -- 2300
				output = truncateCommandOutput(output) -- 2300
			} -- 2300
		) -- 2300
	end) -- 2300
end -- 2223
local function executeGitCommand(req) -- 2303
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2303
		local command = normalizeGitCommand(req.command or "") -- 2312
		if command == "" then -- 2312
			return ____awaiter_resolve(nil, { -- 2312
				success = false, -- 2314
				mode = "git", -- 2314
				output = "", -- 2314
				message = "missing command", -- 2314
				phase = "validate" -- 2314
			}) -- 2314
		end -- 2314
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 2316
			workDir = req.workDir, -- 2317
			command = command, -- 2318
			operationId = req.operationId, -- 2319
			timeoutSeconds = req.timeoutSeconds, -- 2320
			onProgress = req.onProgress, -- 2321
			isCancelled = req.isCancelled -- 2322
		})) -- 2322
		if cloneResult ~= nil then -- 2322
			return ____awaiter_resolve(nil, cloneResult) -- 2322
		end -- 2322
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 2325
		if not cwd.success then -- 2325
			return ____awaiter_resolve(nil, { -- 2325
				success = false, -- 2327
				mode = "git", -- 2327
				output = "", -- 2327
				cwd = req.cwd, -- 2327
				message = cwd.message, -- 2327
				phase = "validate" -- 2327
			}) -- 2327
		end -- 2327
		local ____this_44 -- 2327
		____this_44 = req -- 2329
		local ____opt_43 = ____this_44.onProgress -- 2329
		if ____opt_43 ~= nil then -- 2329
			____opt_43(____this_44, { -- 2329
				state = "pending", -- 2330
				mode = "git", -- 2331
				operationId = req.operationId, -- 2332
				stage = "git", -- 2333
				message = "git command pending", -- 2334
				progress = 0 -- 2335
			}) -- 2335
		end -- 2335
		local gitRes = __TS__Await(runGitAndWait( -- 2337
			cwd.path, -- 2338
			command, -- 2339
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2340
			function() -- 2341
				local ____this_46 -- 2341
				____this_46 = req -- 2341
				local ____opt_45 = ____this_46.isCancelled -- 2341
				return (____opt_45 and ____opt_45(____this_46)) == true -- 2341
			end, -- 2341
			req.timeoutSeconds -- 2342
		)) -- 2342
		local output = formatGitStatusOutput(gitRes.status) -- 2344
		if not gitRes.success then -- 2344
			local ____output_50 = output -- 2349
			local ____cwd_relative_51 = cwd.relative -- 2350
			local ____temp_52 = gitRes.message or "git command failed" -- 2351
			local ____gitRes_interrupted_49 = gitRes.interrupted -- 2352
			if not ____gitRes_interrupted_49 then -- 2352
				local ____this_48 -- 2352
				____this_48 = req -- 2352
				local ____opt_47 = ____this_48.isCancelled -- 2352
				____gitRes_interrupted_49 = (____opt_47 and ____opt_47(____this_48)) == true -- 2352
			end -- 2352
			return ____awaiter_resolve(nil, { -- 2352
				success = false, -- 2347
				mode = "git", -- 2348
				output = ____output_50, -- 2349
				cwd = ____cwd_relative_51, -- 2350
				message = ____temp_52, -- 2351
				interrupted = ____gitRes_interrupted_49 -- 2352
			}) -- 2352
		end -- 2352
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 2352
	end) -- 2352
end -- 2303
function ____exports.executeCommand(req) -- 2358
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2358
		local mode = req.mode -- 2368
		if mode ~= "lua" and mode ~= "git" then -- 2368
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 2368
		end -- 2368
		if mode == "lua" then -- 2368
			return ____awaiter_resolve( -- 2368
				nil, -- 2368
				executeLuaCommand({workDir = req.workDir, code = req.code or ""}) -- 2373
			) -- 2373
		end -- 2373
		local operationId = createOperationId() -- 2375
		return ____awaiter_resolve( -- 2375
			nil, -- 2375
			executeGitCommand({ -- 2376
				workDir = req.workDir, -- 2377
				command = req.command or "", -- 2378
				cwd = req.cwd, -- 2379
				timeoutSeconds = math.max( -- 2380
					1, -- 2380
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 2380
				), -- 2380
				operationId = operationId, -- 2381
				onProgress = req.onProgress, -- 2382
				isCancelled = req.isCancelled -- 2383
			}) -- 2383
		) -- 2383
	end) -- 2383
end -- 2358
function ____exports.fetchUrl(req) -- 2387
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2387
		local mode = "download" -- 2394
		local url = __TS__StringTrim(req.url or "") -- 2395
		local targetRel = __TS__StringTrim(req.target or "") -- 2396
		if not isHttpUrl(url) then -- 2396
			return ____awaiter_resolve(nil, { -- 2396
				success = false, -- 2398
				state = "failed", -- 2398
				mode = mode, -- 2398
				target = targetRel, -- 2398
				message = "fetch_url only supports http:// and https:// URLs" -- 2398
			}) -- 2398
		end -- 2398
		if targetRel == "" then -- 2398
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 2398
		end -- 2398
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 2403
		if not target then -- 2403
			return ____awaiter_resolve(nil, { -- 2403
				success = false, -- 2405
				state = "failed", -- 2405
				mode = mode, -- 2405
				target = targetRel, -- 2405
				message = "invalid target path" -- 2405
			}) -- 2405
		end -- 2405
		if Content:exist(target) then -- 2405
			return ____awaiter_resolve(nil, { -- 2405
				success = false, -- 2408
				state = "failed", -- 2408
				mode = mode, -- 2408
				target = targetRel, -- 2408
				message = "target already exists" -- 2408
			}) -- 2408
		end -- 2408
		local operationId = createOperationId() -- 2410
		local tempRoot = getAgentDownloadTempRoot() -- 2411
		if not ensureDirPath(tempRoot) then -- 2411
			return ____awaiter_resolve(nil, { -- 2411
				success = false, -- 2413
				state = "failed", -- 2413
				mode = mode, -- 2413
				target = targetRel, -- 2413
				message = "failed to create agent download temp directory" -- 2413
			}) -- 2413
		end -- 2413
		local tempPath = Path(tempRoot, operationId .. ".download") -- 2415
		Content:remove(tempPath) -- 2416
		local function emitProgress(progress) -- 2417
			if not req.onProgress then -- 2417
				return -- 2418
			end -- 2418
			req:onProgress(__TS__ObjectAssign({ -- 2419
				state = "running", -- 2420
				mode = mode, -- 2421
				operationId = operationId, -- 2422
				target = targetRel, -- 2423
				tempPath = tempPath -- 2424
			}, progress)) -- 2424
		end -- 2417
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 2428
		local function interrupted() -- 2433
			local ____this_54 -- 2433
			____this_54 = req -- 2433
			local ____opt_53 = ____this_54.isCancelled -- 2433
			return (____opt_53 and ____opt_53(____this_54)) == true -- 2433
		end -- 2433
		if not ensureDirForFile(tempPath) then -- 2433
			return ____awaiter_resolve(nil, { -- 2433
				success = false, -- 2435
				state = "failed", -- 2435
				mode = mode, -- 2435
				target = targetRel, -- 2435
				message = "failed to create temporary file directory" -- 2435
			}) -- 2435
		end -- 2435
		local downloadRes = __TS__Await(downloadFile({ -- 2437
			url = url, -- 2438
			tempPath = tempPath, -- 2439
			timeout = 600, -- 2440
			isCancelled = interrupted, -- 2441
			onProgress = function(____, current, total) -- 2442
				local totalNumber = type(total) == "number" and total or 0 -- 2443
				emitProgress({ -- 2444
					stage = "download", -- 2445
					message = "downloading", -- 2446
					current = current, -- 2447
					total = total, -- 2448
					progress = totalNumber > 0 and current / totalNumber or nil -- 2449
				}) -- 2449
			end -- 2442
		})) -- 2442
		if not downloadRes.success then -- 2442
			local cleanupError = cleanupPath(tempPath) -- 2454
			return ____awaiter_resolve( -- 2454
				nil, -- 2454
				{ -- 2455
					success = false, -- 2456
					state = "failed", -- 2457
					mode = mode, -- 2458
					target = targetRel, -- 2459
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 2460
					interrupted = downloadRes.interrupted or interrupted(), -- 2461
					cleanupError = cleanupError -- 2462
				} -- 2462
			) -- 2462
		end -- 2462
		if not ensureDirForFile(target) then -- 2462
			local cleanupError = cleanupPath(tempPath) -- 2466
			return ____awaiter_resolve(nil, { -- 2466
				success = false, -- 2467
				state = "failed", -- 2467
				mode = mode, -- 2467
				target = targetRel, -- 2467
				message = "failed to create target directory", -- 2467
				cleanupError = cleanupError -- 2467
			}) -- 2467
		end -- 2467
		if not Content:move(tempPath, target) then -- 2467
			local cleanupError = cleanupPath(tempPath) -- 2470
			return ____awaiter_resolve(nil, { -- 2470
				success = false, -- 2471
				state = "failed", -- 2471
				mode = mode, -- 2471
				target = targetRel, -- 2471
				message = "failed to move downloaded file into target path", -- 2471
				cleanupError = cleanupError -- 2471
			}) -- 2471
		end -- 2471
		local bytesWritten = downloadRes.bytesWritten -- 2473
		local ____try = __TS__AsyncAwaiter(function() -- 2473
			local size = Content:getAttr(target) -- 2475
			if bytesWritten == nil or bytesWritten <= 0 then -- 2475
				bytesWritten = type(size) == "number" and size or nil -- 2477
			end -- 2477
		end) -- 2477
		____try = ____try.catch( -- 2477
			____try, -- 2477
			function(____, _) -- 2477
				return __TS__AsyncAwaiter(function() -- 2477
				end) -- 2477
			end -- 2477
		) -- 2477
		__TS__Await(____try) -- 2474
		if bytesWritten == nil or bytesWritten <= 0 then -- 2474
			local ____try = __TS__AsyncAwaiter(function() -- 2474
				local loaded = Content:load(target) -- 2484
				if type(loaded) == "string" then -- 2484
					bytesWritten = #loaded -- 2486
				end -- 2486
			end) -- 2486
			____try = ____try.catch( -- 2486
				____try, -- 2486
				function(____, _) -- 2486
					return __TS__AsyncAwaiter(function() -- 2486
					end) -- 2486
				end -- 2486
			) -- 2486
			__TS__Await(____try) -- 2483
		end -- 2483
		if not syncDownloadedFileToWebIDE(target) then -- 2483
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 2493
		end -- 2493
		return ____awaiter_resolve(nil, { -- 2493
			success = true, -- 2495
			state = "done", -- 2495
			mode = mode, -- 2495
			target = targetRel, -- 2495
			bytesWritten = bytesWritten -- 2495
		}) -- 2495
	end) -- 2495
end -- 2387
return ____exports -- 2387