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
function normalizeEscapedGitQuotes(command) -- 559
	local result = "" -- 560
	do -- 560
		local i = 0 -- 561
		while i < #command do -- 561
			do -- 561
				local ch = __TS__StringCharAt(command, i) -- 562
				local next = __TS__StringCharAt(command, i + 1) -- 563
				if ch == "\\" and (next == "\"" or next == "'") then -- 563
					result = result .. next -- 565
					i = i + 1 -- 566
					goto __continue86 -- 567
				end -- 567
				result = result .. ch -- 569
			end -- 569
			::__continue86:: -- 569
			i = i + 1 -- 561
		end -- 561
	end -- 561
	return result -- 571
end -- 571
function getEngineLogText() -- 1402
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 1403
	if not Content:exist(folder) then -- 1403
		Content:mkdir(folder) -- 1405
	end -- 1405
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 1407
	if not App:saveLog(logPath) then -- 1407
		return nil -- 1409
	end -- 1409
	return Content:load(logPath) -- 1411
end -- 1411
function ensureSafeSearchGlobs(globs) -- 1551
	local result = {} -- 1552
	do -- 1552
		local i = 0 -- 1553
		while i < #globs do -- 1553
			result[#result + 1] = globs[i + 1] -- 1554
			i = i + 1 -- 1553
		end -- 1553
	end -- 1553
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1556
	do -- 1556
		local i = 0 -- 1557
		while i < #requiredExcludes do -- 1557
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1557
				result[#result + 1] = requiredExcludes[i + 1] -- 1559
			end -- 1559
			i = i + 1 -- 1557
		end -- 1557
	end -- 1557
	return result -- 1562
end -- 1562
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
	local plain = string.match(value, "^[%w%._%-%/]+$") -- 496
	if plain ~= nil then -- 496
		return value -- 498
	end -- 498
	local escaped = string.gsub(value, "\\", "\\\\") -- 500
	escaped = string.gsub(escaped, "\"", "\\\"") -- 501
	return ("\"" .. escaped) .. "\"" -- 502
end -- 495
local function shellSplit(command) -- 505
	local args = {} -- 506
	local current = "" -- 507
	local quote = "" -- 508
	local escaped = false -- 509
	do -- 509
		local i = 0 -- 510
		while i < #command do -- 510
			do -- 510
				local ch = __TS__StringCharAt(command, i) -- 511
				if escaped then -- 511
					current = current .. ch -- 513
					escaped = false -- 514
					goto __continue72 -- 515
				end -- 515
				if ch == "\\" then -- 515
					escaped = true -- 518
					goto __continue72 -- 519
				end -- 519
				if quote ~= "" then -- 519
					if ch == quote then -- 519
						quote = "" -- 523
					else -- 523
						current = current .. ch -- 525
					end -- 525
					goto __continue72 -- 527
				end -- 527
				if ch == "'" or ch == "\"" then -- 527
					quote = ch -- 530
					goto __continue72 -- 531
				end -- 531
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 531
					if current ~= "" then -- 531
						args[#args + 1] = current -- 535
						current = "" -- 536
					end -- 536
					goto __continue72 -- 538
				end -- 538
				current = current .. ch -- 540
			end -- 540
			::__continue72:: -- 540
			i = i + 1 -- 510
		end -- 510
	end -- 510
	if escaped then -- 510
		current = current .. "\\" -- 543
	end -- 543
	if current ~= "" then -- 543
		args[#args + 1] = current -- 546
	end -- 546
	return args -- 548
end -- 505
local function normalizeGitCommand(command) -- 551
	local trimmed = __TS__StringTrim(command) -- 552
	local normalized = string.lower(string.sub(trimmed, 1, 4)) == "git " and __TS__StringTrim(string.sub(trimmed, 5)) or trimmed -- 553
	return normalizeEscapedGitQuotes(normalized) -- 556
end -- 551
local function gitDefaultTargetFromUrl(url) -- 574
	local target = url -- 575
	local hashIndex = (string.find(target, "#", nil, true) or 0) - 1 -- 576
	if hashIndex >= 0 then -- 576
		target = __TS__StringSlice(target, 0, hashIndex) -- 577
	end -- 577
	local queryIndex = (string.find(target, "?", nil, true) or 0) - 1 -- 578
	if queryIndex >= 0 then -- 578
		target = __TS__StringSlice(target, 0, queryIndex) -- 579
	end -- 579
	target = string.gsub(target, "/+$", "") -- 580
	local name = string.match(target, "([^/]+)$") -- 581
	if name ~= nil and name ~= "" then -- 581
		target = name -- 582
	end -- 582
	if __TS__StringEndsWith( -- 582
		string.lower(target), -- 583
		".git" -- 583
	) then -- 583
		target = __TS__StringSlice(target, 0, #target - 4) -- 584
	end -- 584
	return target ~= "" and target or "repo" -- 586
end -- 574
local function parseGitCloneCommand(command) -- 589
	local args = shellSplit(normalizeGitCommand(command)) -- 599
	if #args == 0 or args[1] ~= "clone" then -- 599
		return nil -- 600
	end -- 600
	local url = "" -- 601
	local target = "" -- 602
	local ref -- 603
	local depth -- 604
	do -- 604
		local i = 1 -- 605
		while i < #args do -- 605
			do -- 605
				local arg = args[i + 1] -- 606
				if arg == "-b" or arg == "--branch" then
					i = i + 1 -- 608
					if i >= #args then -- 608
						return {success = false, message = arg .. " requires a value"} -- 609
					end -- 609
					ref = args[i + 1] -- 610
					goto __continue96 -- 611
				end -- 611
				if arg == "--depth" then
					i = i + 1 -- 614
					if i >= #args then -- 614
						return {success = false, message = "--depth requires a value"}
					end -- 615
					depth = args[i + 1] -- 616
					goto __continue96 -- 617
				end -- 617
				if __TS__StringStartsWith(arg, "--depth=") then
					depth = __TS__StringSlice(arg, #"--depth=")
					goto __continue96 -- 621
				end -- 621
				if __TS__StringStartsWith(arg, "-") then -- 621
					return {success = false, message = "unsupported clone option: " .. arg} -- 624
				end -- 624
				if url == "" then -- 624
					url = arg -- 627
					goto __continue96 -- 628
				end -- 628
				if target == "" then -- 628
					target = arg -- 631
					goto __continue96 -- 632
				end -- 632
				return {success = false, message = "unexpected clone argument: " .. arg} -- 634
			end -- 634
			::__continue96:: -- 634
			i = i + 1 -- 605
		end -- 605
	end -- 605
	if url == "" then -- 605
		return {success = false, message = "git clone requires a URL"} -- 636
	end -- 636
	if not isHttpUrl(url) then -- 636
		return {success = false, message = "git clone only supports http:// and https:// URLs"} -- 637
	end -- 637
	if target == "" then -- 637
		target = gitDefaultTargetFromUrl(url) -- 638
	end -- 638
	return { -- 639
		success = true, -- 640
		url = url, -- 641
		target = target, -- 642
		ref = ref, -- 643
		depth = depth ~= nil and depth ~= "" and depth or "1" -- 644
	} -- 644
end -- 589
local function getGitHeadCommit(repoPath) -- 648
	local headPath = Path(repoPath, ".git", "HEAD") -- 649
	if not Content:exist(headPath) then -- 649
		return nil -- 650
	end -- 650
	local head = __TS__StringTrim(toStr(Content:load(headPath))) -- 651
	local ref = string.match(head, "^ref:%s*(.-)%s*$") -- 652
	if ref ~= nil and ref ~= "" then -- 652
		local refPath = Path(repoPath, ".git", ref) -- 654
		if Content:exist(refPath) then -- 654
			local commit = __TS__StringTrim(toStr(Content:load(refPath))) -- 656
			return commit ~= "" and commit or nil -- 657
		end -- 657
		return nil -- 659
	end -- 659
	return head ~= "" and head or nil -- 661
end -- 648
local function runGitAndWait(repoPath, command, onStatus, isCancelled, timeout) -- 664
	if timeout == nil then -- 664
		timeout = 600 -- 669
	end -- 669
	return __TS__New( -- 671
		__TS__Promise, -- 671
		function(____, resolve) -- 671
			local status -- 672
			local jobId = 0 -- 673
			local settled = false -- 674
			local canceled = false -- 675
			local function finish(result) -- 676
				if settled then -- 676
					return -- 677
				end -- 677
				settled = true -- 678
				resolve(nil, result) -- 679
			end -- 676
			local function finishFromStatus() -- 681
				local state = toStr(status and status.state) -- 682
				if state == "done" then -- 682
					finish({success = true, status = status}) -- 684
					return true -- 685
				end -- 685
				if state == "error" or state == "canceled" then -- 685
					local errorMessage = toStr(status and status.error) -- 688
					local statusMessage = toStr(status and status.message) -- 689
					finish({success = false, message = errorMessage ~= "" and errorMessage or (statusMessage ~= "" and statusMessage or (state == "canceled" and "git command canceled" or "git command failed")), status = status, interrupted = state == "canceled"}) -- 690
					return true -- 696
				end -- 696
				return false -- 698
			end -- 681
			jobId = Git:run( -- 700
				repoPath, -- 700
				command, -- 700
				function(nextStatus) -- 700
					status = nextStatus -- 701
					if onStatus then -- 701
						onStatus(status) -- 702
					end -- 702
					return finishFromStatus() -- 703
				end, -- 700
				"" -- 704
			) -- 704
			if jobId == nil or jobId <= 0 then -- 704
				finish({success = false, message = "failed to start git command"}) -- 706
				return -- 707
			end -- 707
			if not status then -- 707
				local kind = string.match(command, "^(%S+)") -- 710
				status = { -- 711
					id = jobId, -- 712
					state = "queued", -- 713
					kind = toStr(kind), -- 714
					repoPath = repoPath, -- 715
					progress = 0, -- 716
					message = "queued" -- 717
				} -- 717
			end -- 717
			if onStatus then -- 717
				onStatus(status) -- 720
			end -- 720
			local startedAt = os.time() -- 721
			local lastEmitAt = startedAt -- 722
			Director.systemScheduler:schedule(function() -- 723
				if settled then -- 723
					return true -- 724
				end -- 724
				if not canceled and isCancelled and isCancelled() then -- 724
					canceled = true -- 726
					Git:cancel(jobId) -- 727
					finish({success = false, message = "git command canceled", status = status, interrupted = true}) -- 728
					return true -- 729
				end -- 729
				if finishFromStatus() then -- 729
					return true -- 731
				end -- 731
				local nowTime = os.time() -- 732
				if nowTime - startedAt >= timeout then -- 732
					Git:cancel(jobId) -- 734
					finish({success = false, message = "git command timed out", status = status}) -- 735
					return true -- 736
				end -- 736
				if onStatus and status and nowTime > lastEmitAt then -- 736
					lastEmitAt = nowTime -- 739
					onStatus(status) -- 740
				end -- 740
				return false -- 742
			end) -- 723
		end -- 671
	) -- 671
end -- 664
local function downloadFile(req) -- 747
	return __TS__New( -- 754
		__TS__Promise, -- 754
		function(____, resolve) -- 754
			local requestId = 0 -- 755
			local settled = false -- 756
			local bytesWritten = 0 -- 757
			local function finish(result) -- 758
				if settled then -- 758
					return -- 759
				end -- 759
				settled = true -- 760
				requestId = 0 -- 761
				resolve(nil, result) -- 762
			end -- 758
			Director.systemScheduler:schedule(function() -- 764
				if settled then -- 764
					return true -- 765
				end -- 765
				local ____this_7 -- 765
				____this_7 = req -- 766
				local ____opt_6 = ____this_7.isCancelled -- 766
				if (____opt_6 and ____opt_6(____this_7)) == true and requestId ~= 0 then -- 766
					HttpClient:cancel(requestId) -- 767
					finish({success = false, interrupted = true, message = "download canceled"}) -- 768
					return true -- 769
				end -- 769
				if requestId ~= 0 and not HttpClient:isRequestActive(requestId) then -- 769
					finish({success = false, message = "download request ended without a completion callback"}) -- 772
					return true -- 773
				end -- 773
				return false -- 775
			end) -- 764
			Director.systemScheduler:schedule(once(function() -- 777
				requestId = HttpClient:download( -- 778
					req.url, -- 778
					req.tempPath, -- 778
					req.timeout, -- 778
					function(interrupted, current, total) -- 778
						if type(current) == "number" and current > bytesWritten then -- 778
							bytesWritten = current -- 780
						end -- 780
						if interrupted then -- 780
							finish({success = false, interrupted = true, message = "download failed"}) -- 783
							return true -- 784
						end -- 784
						local ____this_9 -- 784
						____this_9 = req -- 786
						local ____opt_8 = ____this_9.isCancelled -- 786
						if (____opt_8 and ____opt_8(____this_9)) == true then -- 786
							finish({success = false, interrupted = true, message = "download canceled"}) -- 787
							return true -- 788
						end -- 788
						if current == total then -- 788
							finish({success = true, bytesWritten = bytesWritten}) -- 791
							return false -- 792
						end -- 792
						req:onProgress(current, total) -- 794
						return false -- 795
					end -- 778
				) -- 778
				if requestId == 0 then -- 778
					finish({success = false, message = "failed to schedule download request"}) -- 798
				else -- 798
					local ____this_11 -- 798
					____this_11 = req -- 799
					local ____opt_10 = ____this_11.isCancelled -- 799
					if (____opt_10 and ____opt_10(____this_11)) == true then -- 799
						HttpClient:cancel(requestId) -- 800
						finish({success = false, interrupted = true, message = "download canceled"}) -- 801
					end -- 801
				end -- 801
			end)) -- 777
		end -- 754
	) -- 754
end -- 747
local function getFileState(path) -- 807
	local exists = Content:exist(path) -- 808
	if not exists then -- 808
		return {exists = false, content = "", bytes = 0} -- 810
	end -- 810
	if Content:isdir(path) then -- 810
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 817
	end -- 817
	local content = Content:load(path) -- 824
	if type(content) ~= "string" then -- 824
		return {exists = true, content = "", bytes = 0} -- 826
	end -- 826
	return {exists = true, content = content, bytes = #content} -- 832
end -- 807
local function inspectReadableFile(path) -- 839
	do -- 839
		local function ____catch(e) -- 839
			Log( -- 861
				"Warn", -- 861
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 861
			) -- 861
			return true, {success = true} -- 862
		end -- 862
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 862
			local size, isBinary = Content:getAttr(path) -- 841
			if size == nil then -- 841
				return true, {success = false, message = "failed to read file"} -- 843
			end -- 843
			if isBinary then -- 843
				return true, { -- 849
					success = false, -- 850
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 851
					size = type(size) == "number" and size or nil, -- 852
					isBinary = true -- 853
				} -- 853
			end -- 853
			return true, { -- 856
				success = true, -- 857
				size = type(size) == "number" and size or nil -- 858
			} -- 858
		end) -- 858
		if not ____try then -- 858
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 858
		end -- 858
		if ____hasReturned then -- 858
			return ____returnValue -- 840
		end -- 840
	end -- 840
end -- 839
local function isEngineLogFilePath(path) -- 866
	return path == ENGINE_LOG_FILE -- 867
end -- 866
local function readEngineLogFile(path) -- 870
	if not isEngineLogFilePath(path) then -- 870
		return nil -- 871
	end -- 871
	local content = getEngineLogText() -- 872
	if content == nil then -- 872
		return {success = false, message = "failed to read engine logs"} -- 874
	end -- 874
	return {success = true, content = content, size = #content} -- 876
end -- 870
local function queryOne(sql, args) -- 879
	local ____args_12 -- 880
	if args then -- 880
		____args_12 = DB:query(sql, args) -- 880
	else -- 880
		____args_12 = DB:query(sql) -- 880
	end -- 880
	local rows = ____args_12 -- 880
	if not rows or #rows == 0 then -- 880
		return nil -- 881
	end -- 881
	return rows[1] -- 882
end -- 879
do -- 879
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 887
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 895
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 906
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 907
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 920
end -- 920
local function isDtsFile(path) -- 923
	return Path:getExt(Path:getName(path)) == "d" -- 924
end -- 923
local function isTiledEditorContent(content) -- 927
	return __TS__StringStartsWith( -- 928
		__TS__StringTrim(content), -- 928
		"<?xml" -- 928
	) -- 928
end -- 927
local function getSupportedBuildKind(path) -- 933
	repeat -- 933
		local ____switch165 = Path:getExt(path) -- 933
		local ____cond165 = ____switch165 == "ts" or ____switch165 == "tsx" -- 933
		if ____cond165 then -- 933
			return "ts" -- 935
		end -- 935
		____cond165 = ____cond165 or ____switch165 == "xml" -- 935
		if ____cond165 then -- 935
			return "xml" -- 936
		end -- 936
		____cond165 = ____cond165 or ____switch165 == "tl" -- 936
		if ____cond165 then -- 936
			return "teal" -- 937
		end -- 937
		____cond165 = ____cond165 or ____switch165 == "lua" -- 937
		if ____cond165 then -- 937
			return "lua" -- 938
		end -- 938
		____cond165 = ____cond165 or ____switch165 == "yue" -- 938
		if ____cond165 then -- 938
			return "yue" -- 939
		end -- 939
		____cond165 = ____cond165 or ____switch165 == "yarn" -- 939
		if ____cond165 then -- 939
			return "yarn" -- 940
		end -- 940
		do -- 940
			return nil -- 941
		end -- 941
	until true -- 941
end -- 933
local function getTaskHeadSeq(taskId) -- 945
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 946
	if not row then -- 946
		return nil -- 947
	end -- 947
	return row[1] or 0 -- 948
end -- 945
local function getTaskStatus(taskId) -- 951
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 952
	if not row then -- 952
		return nil -- 953
	end -- 953
	return toStr(row[1]) -- 954
end -- 951
local function getLastInsertRowId() -- 957
	local row = queryOne("SELECT last_insert_rowid()") -- 958
	return row and (row[1] or 0) or 0 -- 959
end -- 957
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 962
	DB:exec( -- 963
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 963
		{ -- 965
			taskId, -- 965
			seq, -- 965
			status, -- 965
			summary, -- 965
			toolName, -- 965
			now() -- 965
		} -- 965
	) -- 965
	return getLastInsertRowId() -- 967
end -- 962
local function getCheckpointEntries(checkpointId, desc) -- 970
	if desc == nil then -- 970
		desc = false -- 970
	end -- 970
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 971
	if not rows then -- 971
		return {} -- 978
	end -- 978
	local result = {} -- 979
	do -- 979
		local i = 0 -- 980
		while i < #rows do -- 980
			local row = rows[i + 1] -- 981
			result[#result + 1] = { -- 982
				id = row[1], -- 983
				ord = row[2], -- 984
				path = toStr(row[3]), -- 985
				op = toStr(row[4]), -- 986
				beforeExists = toBool(row[5]), -- 987
				beforeContent = toStr(row[6]), -- 988
				afterExists = toBool(row[7]), -- 989
				afterContent = toStr(row[8]) -- 990
			} -- 990
			i = i + 1 -- 980
		end -- 980
	end -- 980
	return result -- 993
end -- 970
local function rejectDuplicatePaths(changes) -- 996
	local seen = __TS__New(Set) -- 997
	for ____, change in ipairs(changes) do -- 998
		local key = change.path -- 999
		if seen:has(key) then -- 999
			return key -- 1000
		end -- 1000
		seen:add(key) -- 1001
	end -- 1001
	return nil -- 1003
end -- 996
local function getLinkedDeletePaths(workDir, path) -- 1006
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1007
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 1007
		return {} -- 1008
	end -- 1008
	local parent = Path:getPath(fullPath) -- 1009
	local baseName = string.lower(Path:getName(fullPath)) -- 1010
	local ext = Path:getExt(fullPath) -- 1011
	local linked = {} -- 1012
	for ____, file in ipairs(Content:getFiles(parent)) do -- 1013
		do -- 1013
			if string.lower(Path:getName(file)) ~= baseName then -- 1013
				goto __continue182 -- 1014
			end -- 1014
			local siblingExt = Path:getExt(file) -- 1015
			if siblingExt == "tl" and ext == "vs" then -- 1015
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1017
					workDir, -- 1017
					Path(parent, file) -- 1017
				) -- 1017
				goto __continue182 -- 1018
			end -- 1018
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 1018
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1021
					workDir, -- 1021
					Path(parent, file) -- 1021
				) -- 1021
			end -- 1021
		end -- 1021
		::__continue182:: -- 1021
	end -- 1021
	return linked -- 1024
end -- 1006
local function expandLinkedDeleteChanges(workDir, changes) -- 1027
	local expanded = {} -- 1028
	local seen = __TS__New(Set) -- 1029
	do -- 1029
		local i = 0 -- 1030
		while i < #changes do -- 1030
			do -- 1030
				local change = changes[i + 1] -- 1031
				if not seen:has(change.path) then -- 1031
					seen:add(change.path) -- 1033
					expanded[#expanded + 1] = change -- 1034
				end -- 1034
				if change.op ~= "delete" then -- 1034
					goto __continue189 -- 1036
				end -- 1036
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 1037
				do -- 1037
					local j = 0 -- 1038
					while j < #linkedPaths do -- 1038
						do -- 1038
							local linkedPath = linkedPaths[j + 1] -- 1039
							if seen:has(linkedPath) then -- 1039
								goto __continue193 -- 1040
							end -- 1040
							seen:add(linkedPath) -- 1041
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 1042
						end -- 1042
						::__continue193:: -- 1042
						j = j + 1 -- 1038
					end -- 1038
				end -- 1038
			end -- 1038
			::__continue189:: -- 1038
			i = i + 1 -- 1030
		end -- 1030
	end -- 1030
	return expanded -- 1045
end -- 1027
local function applySingleFile(path, exists, content) -- 1048
	if exists then -- 1048
		if not ensureDirForFile(path) then -- 1048
			return false -- 1050
		end -- 1050
		return Content:save(path, content) -- 1051
	end -- 1051
	if Content:exist(path) then -- 1051
		return Content:remove(path) -- 1054
	end -- 1054
	return true -- 1056
end -- 1048
local function encodeJSON(obj) -- 1059
	local text = safeJsonEncode(obj) -- 1060
	return text -- 1061
end -- 1059
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 1064
	if HttpServer.wsConnectionCount == 0 then -- 1064
		return true -- 1066
	end -- 1066
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 1068
	if not payload then -- 1068
		return false -- 1070
	end -- 1070
	emit("AppWS", "Send", payload) -- 1072
	return true -- 1073
end -- 1064
function ____exports.sendWebIDERefreshTree() -- 1076
	if HttpServer.wsConnectionCount == 0 then -- 1076
		return true -- 1078
	end -- 1078
	local payload = encodeJSON({name = "RefreshTree"}) -- 1080
	if not payload then -- 1080
		return false -- 1082
	end -- 1082
	emit("AppWS", "Send", payload) -- 1084
	return true -- 1085
end -- 1076
local function syncProjectFileToWebIDE(workDir, path) -- 1088
	local target = resolveWorkspaceFilePath(workDir, path) -- 1089
	if not target then -- 1089
		return false -- 1090
	end -- 1090
	if not Content:exist(target) then -- 1090
		return ____exports.sendWebIDEFileUpdate(target, false, "") -- 1092
	end -- 1092
	if Content:isdir(target) then -- 1092
		return ____exports.sendWebIDERefreshTree() -- 1095
	end -- 1095
	local content = "" -- 1097
	do -- 1097
		local function ____catch(e) -- 1097
			Log( -- 1105
				"Warn", -- 1105
				(("[Agent.Tools] failed to inspect file for Web IDE update file=" .. target) .. ": ") .. tostring(e) -- 1105
			) -- 1105
		end -- 1105
		local ____try, ____hasReturned = pcall(function() -- 1105
			local ____, isBinary = Content:getAttr(target) -- 1099
			if not isBinary then -- 1099
				local loaded = Content:load(target) -- 1101
				content = type(loaded) == "string" and loaded or "" -- 1102
			end -- 1102
		end) -- 1102
		if not ____try then -- 1102
			____catch(____hasReturned) -- 1102
		end -- 1102
	end -- 1102
	return ____exports.sendWebIDEFileUpdate(target, true, content) -- 1107
end -- 1088
local function refreshProjectTree(workDir, path) -- 1110
	local normalized = type(path) == "string" and __TS__StringTrim(path) or "" -- 1111
	if normalized == "" then -- 1111
		return ____exports.sendWebIDERefreshTree() -- 1113
	end -- 1113
	return syncProjectFileToWebIDE(workDir, normalized) -- 1115
end -- 1110
local function syncDownloadedFileToWebIDE(file) -- 1118
	local content = "" -- 1119
	do -- 1119
		local function ____catch(e) -- 1119
			Log( -- 1127
				"Warn", -- 1127
				(("[fetch_url] failed to inspect downloaded file for Web IDE update file=" .. file) .. ": ") .. tostring(e) -- 1127
			) -- 1127
		end -- 1127
		local ____try, ____hasReturned = pcall(function() -- 1127
			local ____, isBinary = Content:getAttr(file) -- 1121
			if not isBinary then -- 1121
				local loaded = Content:load(file) -- 1123
				content = type(loaded) == "string" and loaded or "" -- 1124
			end -- 1124
		end) -- 1124
		if not ____try then -- 1124
			____catch(____hasReturned) -- 1124
		end -- 1124
	end -- 1124
	return ____exports.sendWebIDEFileUpdate(file, true, content) -- 1129
end -- 1118
local function runSingleNonTsBuild(file) -- 1132
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1132
		return ____awaiter_resolve( -- 1132
			nil, -- 1132
			__TS__New( -- 1133
				__TS__Promise, -- 1133
				function(____, resolve) -- 1133
					local moduleName = "Script.Dev.WebServer" -- 1134
					local ____require_result_13 = require(moduleName) -- 1135
					local buildAsync = ____require_result_13.buildAsync -- 1135
					Director.systemScheduler:schedule(once(function() -- 1136
						local result = buildAsync(file) -- 1137
						resolve(nil, result) -- 1138
					end)) -- 1136
				end -- 1133
			) -- 1133
		) -- 1133
	end) -- 1133
end -- 1132
local transpileRequestSeq = 0 -- 1143
function ____exports.runSingleTsTranspile(file, content) -- 1145
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1145
		local done = false -- 1146
		transpileRequestSeq = transpileRequestSeq + 1 -- 1147
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 1148
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 1149
		if HttpServer.wsConnectionCount == 0 then -- 1149
			return ____awaiter_resolve(nil, result) -- 1149
		end -- 1149
		local listener = Node() -- 1157
		listener:gslot( -- 1158
			"AppWS", -- 1158
			function(event) -- 1158
				if event.type ~= "Receive" then -- 1158
					return -- 1159
				end -- 1159
				local res = safeJsonDecode(event.msg) -- 1160
				if not res or __TS__ArrayIsArray(res) then -- 1160
					return -- 1161
				end -- 1161
				local payload = res -- 1162
				if payload.name ~= "TranspileTS" then -- 1162
					return -- 1163
				end -- 1163
				if payload.id ~= requestId then -- 1163
					return -- 1164
				end -- 1164
				if tostring(payload.file) ~= file then -- 1164
					return -- 1165
				end -- 1165
				if payload.success then -- 1165
					local luaFile = Path:replaceExt(file, "lua") -- 1167
					if Content:save( -- 1167
						luaFile, -- 1168
						tostring(payload.luaCode) -- 1168
					) then -- 1168
						result = {success = true, file = file} -- 1169
					else -- 1169
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 1171
					end -- 1171
				else -- 1171
					result = { -- 1174
						success = false, -- 1174
						file = file, -- 1174
						message = tostring(payload.message) -- 1174
					} -- 1174
				end -- 1174
				done = true -- 1176
			end -- 1158
		) -- 1158
		local payload = encodeJSON({name = "TranspileTS", id = requestId, file = file, content = content}) -- 1178
		if not payload then -- 1178
			listener:removeFromParent() -- 1185
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 1185
		end -- 1185
		__TS__Await(__TS__New( -- 1188
			__TS__Promise, -- 1188
			function(____, resolve) -- 1188
				Director.systemScheduler:schedule(once(function() -- 1189
					emit("AppWS", "Send", payload) -- 1190
					wait(function() return done end) -- 1191
					if not done then -- 1191
						listener:removeFromParent() -- 1193
					end -- 1193
					resolve(nil) -- 1195
				end)) -- 1189
			end -- 1188
		)) -- 1188
		return ____awaiter_resolve(nil, result) -- 1188
	end) -- 1188
end -- 1145
function ____exports.createTask(prompt) -- 1201
	if prompt == nil then -- 1201
		prompt = "" -- 1201
	end -- 1201
	local t = now() -- 1202
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 1203
	if affected <= 0 then -- 1203
		return {success = false, message = "failed to create task"} -- 1208
	end -- 1208
	return { -- 1210
		success = true, -- 1210
		taskId = getLastInsertRowId() -- 1210
	} -- 1210
end -- 1201
function ____exports.setTaskStatus(taskId, status) -- 1213
	DB:exec( -- 1214
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 1214
		{ -- 1214
			status, -- 1214
			now(), -- 1214
			taskId -- 1214
		} -- 1214
	) -- 1214
	Log( -- 1215
		"Info", -- 1215
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 1215
	) -- 1215
end -- 1213
function ____exports.listCheckpoints(taskId) -- 1218
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 1219
	if not rows then -- 1219
		return {} -- 1226
	end -- 1226
	local items = {} -- 1227
	do -- 1227
		local i = 0 -- 1228
		while i < #rows do -- 1228
			local row = rows[i + 1] -- 1229
			items[#items + 1] = { -- 1230
				id = row[1], -- 1231
				taskId = row[2], -- 1232
				seq = row[3], -- 1233
				status = toStr(row[4]), -- 1234
				summary = toStr(row[5]), -- 1235
				toolName = toStr(row[6]), -- 1236
				createdAt = row[7] -- 1237
			} -- 1237
			i = i + 1 -- 1228
		end -- 1228
	end -- 1228
	return items -- 1240
end -- 1218
local function listCheckpointIdsForTask(taskId, desc) -- 1243
	if desc == nil then -- 1243
		desc = false -- 1243
	end -- 1243
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 1244
	if not rows then -- 1244
		return {} -- 1251
	end -- 1251
	local items = {} -- 1252
	do -- 1252
		local i = 0 -- 1253
		while i < #rows do -- 1253
			local row = rows[i + 1] -- 1254
			items[#items + 1] = {id = row[1], seq = row[2]} -- 1255
			i = i + 1 -- 1253
		end -- 1253
	end -- 1253
	return items -- 1260
end -- 1243
local function deriveFileOp(beforeExists, afterExists) -- 1263
	if not beforeExists and afterExists then -- 1263
		return "create" -- 1264
	end -- 1264
	if beforeExists and not afterExists then -- 1264
		return "delete" -- 1265
	end -- 1265
	return "write" -- 1266
end -- 1263
function ____exports.summarizeTaskChangeSet(taskId) -- 1269
	if not getTaskStatus(taskId) then -- 1269
		return {success = false, message = "task not found"} -- 1271
	end -- 1271
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1273
	local filesByPath = {} -- 1274
	local latestCheckpointId = nil -- 1280
	local latestCheckpointSeq = nil -- 1281
	do -- 1281
		local i = 0 -- 1282
		while i < #checkpoints do -- 1282
			local checkpoint = checkpoints[i + 1] -- 1283
			latestCheckpointId = checkpoint.id -- 1284
			latestCheckpointSeq = checkpoint.seq -- 1285
			local entries = getCheckpointEntries(checkpoint.id, false) -- 1286
			do -- 1286
				local j = 0 -- 1287
				while j < #entries do -- 1287
					local entry = entries[j + 1] -- 1288
					local item = filesByPath[entry.path] -- 1289
					if not item then -- 1289
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 1291
						filesByPath[entry.path] = item -- 1297
					end -- 1297
					item.afterExists = entry.afterExists -- 1299
					local ____item_checkpointIds_14 = item.checkpointIds -- 1299
					____item_checkpointIds_14[#____item_checkpointIds_14 + 1] = checkpoint.id -- 1300
					j = j + 1 -- 1287
				end -- 1287
			end -- 1287
			i = i + 1 -- 1282
		end -- 1282
	end -- 1282
	local files = {} -- 1303
	for ____, item in pairs(filesByPath) do -- 1304
		files[#files + 1] = { -- 1305
			path = item.path, -- 1306
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1307
			checkpointCount = #item.checkpointIds, -- 1308
			checkpointIds = item.checkpointIds -- 1309
		} -- 1309
	end -- 1309
	__TS__ArraySort( -- 1312
		files, -- 1312
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1312
	) -- 1312
	return { -- 1313
		success = true, -- 1314
		taskId = taskId, -- 1315
		checkpointCount = #checkpoints, -- 1316
		filesChanged = #files, -- 1317
		files = files, -- 1318
		latestCheckpointId = latestCheckpointId, -- 1319
		latestCheckpointSeq = latestCheckpointSeq -- 1320
	} -- 1320
end -- 1269
function ____exports.getTaskChangeSetDiff(taskId) -- 1324
	if not getTaskStatus(taskId) then -- 1324
		return {success = false, message = "task not found"} -- 1326
	end -- 1326
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1328
	if #checkpoints == 0 then -- 1328
		return {success = false, message = "change set not found or empty"} -- 1330
	end -- 1330
	local filesByPath = {} -- 1332
	do -- 1332
		local i = 0 -- 1339
		while i < #checkpoints do -- 1339
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 1340
			do -- 1340
				local j = 0 -- 1341
				while j < #entries do -- 1341
					local entry = entries[j + 1] -- 1342
					local item = filesByPath[entry.path] -- 1343
					if not item then -- 1343
						item = { -- 1345
							path = entry.path, -- 1346
							beforeExists = entry.beforeExists, -- 1347
							beforeContent = entry.beforeContent, -- 1348
							afterExists = entry.afterExists, -- 1349
							afterContent = entry.afterContent -- 1350
						} -- 1350
						filesByPath[entry.path] = item -- 1352
					end -- 1352
					item.afterExists = entry.afterExists -- 1354
					item.afterContent = entry.afterContent -- 1355
					j = j + 1 -- 1341
				end -- 1341
			end -- 1341
			i = i + 1 -- 1339
		end -- 1339
	end -- 1339
	local files = {} -- 1358
	for ____, item in pairs(filesByPath) do -- 1359
		files[#files + 1] = { -- 1360
			path = item.path, -- 1361
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1362
			beforeExists = item.beforeExists, -- 1363
			afterExists = item.afterExists, -- 1364
			beforeContent = item.beforeContent, -- 1365
			afterContent = item.afterContent -- 1366
		} -- 1366
	end -- 1366
	__TS__ArraySort( -- 1369
		files, -- 1369
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1369
	) -- 1369
	return {success = true, files = files} -- 1370
end -- 1324
local function readWorkspaceFile(workDir, path, docLanguage) -- 1373
	local engineLog = readEngineLogFile(path) -- 1374
	if engineLog then -- 1374
		return engineLog -- 1375
	end -- 1375
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1376
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 1376
		local attr = inspectReadableFile(fullPath) -- 1378
		if not attr.success then -- 1378
			return attr -- 1379
		end -- 1379
		return { -- 1380
			success = true, -- 1380
			content = Content:load(fullPath), -- 1380
			size = attr.size -- 1380
		} -- 1380
	end -- 1380
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 1382
	if docPath then -- 1382
		local attr = inspectReadableFile(docPath) -- 1384
		if not attr.success then -- 1384
			return attr -- 1385
		end -- 1385
		return { -- 1386
			success = true, -- 1386
			content = Content:load(docPath), -- 1386
			size = attr.size -- 1386
		} -- 1386
	end -- 1386
	if not fullPath then -- 1386
		return {success = false, message = "invalid path or workDir"} -- 1388
	end -- 1388
	return {success = false, message = "file not found"} -- 1389
end -- 1373
function ____exports.readFileRaw(workDir, path, docLanguage) -- 1392
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 1393
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 1393
		local attr = inspectReadableFile(path) -- 1395
		if not attr.success then -- 1395
			return attr -- 1396
		end -- 1396
		return { -- 1397
			success = true, -- 1397
			content = Content:load(path), -- 1397
			size = attr.size -- 1397
		} -- 1397
	end -- 1397
	return result -- 1399
end -- 1392
function ____exports.getLogs(req) -- 1414
	local text = getEngineLogText() -- 1415
	if text == nil then -- 1415
		return {success = false, message = "failed to read engine logs"} -- 1417
	end -- 1417
	local tailLines = math.max( -- 1419
		1, -- 1419
		math.floor(req and req.tailLines or 200) -- 1419
	) -- 1419
	local allLines = __TS__StringSplit(text, "\n") -- 1420
	local logs = __TS__ArraySlice( -- 1421
		allLines, -- 1421
		math.max(0, #allLines - tailLines) -- 1421
	) -- 1421
	return req and req.joinText and ({ -- 1422
		success = true, -- 1422
		logs = logs, -- 1422
		text = table.concat(logs, "\n") -- 1422
	}) or ({success = true, logs = logs}) -- 1422
end -- 1414
function ____exports.listFiles(req) -- 1425
	local root = req.path or "" -- 1431
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 1432
	if not searchRoot then -- 1432
		return {success = false, message = "invalid path or workDir"} -- 1434
	end -- 1434
	do -- 1434
		local function ____catch(e) -- 1434
			return true, { -- 1452
				success = false, -- 1452
				message = tostring(e) -- 1452
			} -- 1452
		end -- 1452
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1452
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 1437
			local globs = ensureSafeSearchGlobs(userGlobs) -- 1438
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 1439
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 1440
			local totalEntries = #files -- 1441
			local maxEntries = math.max( -- 1442
				1, -- 1442
				math.floor(req.maxEntries or 200) -- 1442
			) -- 1442
			local truncated = totalEntries > maxEntries -- 1443
			return true, { -- 1444
				success = true, -- 1445
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 1446
				totalEntries = totalEntries, -- 1447
				truncated = truncated, -- 1448
				maxEntries = maxEntries -- 1449
			} -- 1449
		end) -- 1449
		if not ____try then -- 1449
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1449
		end -- 1449
		if ____hasReturned then -- 1449
			return ____returnValue -- 1436
		end -- 1436
	end -- 1436
end -- 1425
local function formatReadSlice(content, startLine, endLine) -- 1456
	local lines = __TS__StringSplit(content, "\n") -- 1461
	local totalLines = #lines -- 1462
	if totalLines == 0 then -- 1462
		return { -- 1464
			success = true, -- 1465
			content = "", -- 1466
			totalLines = 0, -- 1467
			startLine = 1, -- 1468
			endLine = 0, -- 1469
			truncated = false -- 1470
		} -- 1470
	end -- 1470
	local rawStart = math.floor(startLine) -- 1473
	local rawEnd = math.floor(endLine) -- 1474
	if rawStart == 0 then -- 1474
		return {success = false, message = "startLine cannot be 0"} -- 1476
	end -- 1476
	if rawEnd == 0 then -- 1476
		return {success = false, message = "endLine cannot be 0"} -- 1479
	end -- 1479
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1481
	if start > totalLines then -- 1481
		return { -- 1485
			success = false, -- 1485
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1485
		} -- 1485
	end -- 1485
	local ____end = math.min( -- 1487
		totalLines, -- 1488
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1489
	) -- 1489
	if ____end < start then -- 1489
		return { -- 1494
			success = false, -- 1495
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1496
		} -- 1496
	end -- 1496
	local slice = {} -- 1499
	do -- 1499
		local i = start -- 1500
		while i <= ____end do -- 1500
			slice[#slice + 1] = lines[i] -- 1501
			i = i + 1 -- 1500
		end -- 1500
	end -- 1500
	local truncated = start > 1 or ____end < totalLines -- 1503
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1504
	local body = table.concat(slice, "\n") -- 1509
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1510
	return { -- 1511
		success = true, -- 1512
		content = output, -- 1513
		totalLines = totalLines, -- 1514
		startLine = start, -- 1515
		endLine = ____end, -- 1516
		truncated = truncated -- 1517
	} -- 1517
end -- 1456
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1521
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1528
	if not fallback.success or fallback.content == nil then -- 1528
		return fallback -- 1529
	end -- 1529
	local resolvedStartLine = startLine or 1 -- 1530
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1531
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1532
end -- 1521
local codeExtensions = { -- 1539
	".lua", -- 1539
	".tl", -- 1539
	".yue", -- 1539
	".ts", -- 1539
	".tsx", -- 1539
	".xml", -- 1539
	".md", -- 1539
	".yarn", -- 1539
	".wa", -- 1539
	".mod" -- 1539
} -- 1539
extensionLevels = { -- 1540
	vs = 2, -- 1541
	bl = 2, -- 1542
	ts = 1, -- 1543
	tsx = 1, -- 1544
	tl = 1, -- 1545
	yue = 1, -- 1546
	xml = 1, -- 1547
	lua = 0 -- 1548
} -- 1548
local function splitSearchPatterns(pattern) -- 1565
	local trimmed = __TS__StringTrim(pattern or "") -- 1566
	if trimmed == "" then -- 1566
		return {} -- 1567
	end -- 1567
	local out = {} -- 1568
	local seen = __TS__New(Set) -- 1569
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1570
		local p = __TS__StringTrim(tostring(p0)) -- 1571
		if p ~= "" and not seen:has(p) then -- 1571
			seen:add(p) -- 1573
			out[#out + 1] = p -- 1574
		end -- 1574
	end -- 1574
	return out -- 1577
end -- 1565
local function mergeSearchFileResultsUnique(resultsList) -- 1580
	local merged = {} -- 1581
	local seen = __TS__New(Set) -- 1582
	do -- 1582
		local i = 0 -- 1583
		while i < #resultsList do -- 1583
			local list = resultsList[i + 1] -- 1584
			do -- 1584
				local j = 0 -- 1585
				while j < #list do -- 1585
					do -- 1585
						local row = list[j + 1] -- 1586
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1587
						if seen:has(key) then -- 1587
							goto __continue315 -- 1588
						end -- 1588
						seen:add(key) -- 1589
						merged[#merged + 1] = list[j + 1] -- 1590
					end -- 1590
					::__continue315:: -- 1590
					j = j + 1 -- 1585
				end -- 1585
			end -- 1585
			i = i + 1 -- 1583
		end -- 1583
	end -- 1583
	return merged -- 1593
end -- 1580
local function buildGroupedSearchResults(results) -- 1596
	local order = {} -- 1601
	local grouped = __TS__New(Map) -- 1602
	do -- 1602
		local i = 0 -- 1607
		while i < #results do -- 1607
			local row = results[i + 1] -- 1608
			local file = row.file -- 1609
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1610
			local bucket = grouped:get(key) -- 1611
			if not bucket then -- 1611
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1613
				grouped:set(key, bucket) -- 1614
				order[#order + 1] = key -- 1615
			end -- 1615
			bucket.totalMatches = bucket.totalMatches + 1 -- 1617
			local ____bucket_matches_19 = bucket.matches -- 1617
			____bucket_matches_19[#____bucket_matches_19 + 1] = results[i + 1] -- 1618
			i = i + 1 -- 1607
		end -- 1607
	end -- 1607
	local out = {} -- 1620
	do -- 1620
		local i = 0 -- 1625
		while i < #order do -- 1625
			local bucket = grouped:get(order[i + 1]) -- 1626
			if bucket then -- 1626
				out[#out + 1] = bucket -- 1627
			end -- 1627
			i = i + 1 -- 1625
		end -- 1625
	end -- 1625
	return out -- 1629
end -- 1596
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1632
	local merged = {} -- 1633
	local seen = __TS__New(Set) -- 1634
	local index = 0 -- 1635
	local advanced = true -- 1636
	while advanced do -- 1636
		advanced = false -- 1638
		do -- 1638
			local i = 0 -- 1639
			while i < #resultsList do -- 1639
				do -- 1639
					local list = resultsList[i + 1] -- 1640
					if index >= #list then -- 1640
						goto __continue327 -- 1641
					end -- 1641
					advanced = true -- 1642
					local row = list[index + 1] -- 1643
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1644
					if seen:has(key) then -- 1644
						goto __continue327 -- 1645
					end -- 1645
					seen:add(key) -- 1646
					merged[#merged + 1] = row -- 1647
				end -- 1647
				::__continue327:: -- 1647
				i = i + 1 -- 1639
			end -- 1639
		end -- 1639
		index = index + 1 -- 1649
	end -- 1649
	return merged -- 1651
end -- 1632
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1654
	if docSource ~= "api" then -- 1654
		return 100 -- 1655
	end -- 1655
	if programmingLanguage ~= "tsx" then -- 1655
		return 100 -- 1656
	end -- 1656
	repeat -- 1656
		local ____switch333 = string.lower(Path:getFilename(file)) -- 1656
		local ____cond333 = ____switch333 == "jsx.d.ts" -- 1656
		if ____cond333 then -- 1656
			return 0 -- 1658
		end -- 1658
		____cond333 = ____cond333 or ____switch333 == "dorax.d.ts" -- 1658
		if ____cond333 then -- 1658
			return 1 -- 1659
		end -- 1659
		____cond333 = ____cond333 or ____switch333 == "dora.d.ts" -- 1659
		if ____cond333 then -- 1659
			return 2 -- 1660
		end -- 1660
		do -- 1660
			return 100 -- 1661
		end -- 1661
	until true -- 1661
end -- 1654
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1665
	local sorted = __TS__ArraySlice(hits) -- 1670
	__TS__ArraySort( -- 1671
		sorted, -- 1671
		function(____, a, b) -- 1671
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1672
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1673
			if pa ~= pb then -- 1673
				return pa - pb -- 1674
			end -- 1674
			local fa = string.lower(a.file) -- 1675
			local fb = string.lower(b.file) -- 1676
			if fa ~= fb then -- 1676
				return fa < fb and -1 or 1 -- 1677
			end -- 1677
			return (a.line or 0) - (b.line or 0) -- 1678
		end -- 1671
	) -- 1671
	return sorted -- 1680
end -- 1665
function ____exports.searchFiles(req) -- 1683
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1683
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1696
		if not resolvedPath then -- 1696
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1696
		end -- 1696
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1700
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1701
		if not searchRoot then -- 1701
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1701
		end -- 1701
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1701
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1701
		end -- 1701
		local patterns = splitSearchPatterns(req.pattern) -- 1708
		if #patterns == 0 then -- 1708
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1708
		end -- 1708
		return ____awaiter_resolve( -- 1708
			nil, -- 1708
			__TS__New( -- 1712
				__TS__Promise, -- 1712
				function(____, resolve) -- 1712
					Director.systemScheduler:schedule(once(function() -- 1713
						do -- 1713
							local function ____catch(e) -- 1713
								resolve( -- 1755
									nil, -- 1755
									{ -- 1755
										success = false, -- 1755
										message = tostring(e) -- 1755
									} -- 1755
								) -- 1755
							end -- 1755
							local ____try, ____hasReturned = pcall(function() -- 1755
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1715
								local allResults = {} -- 1718
								do -- 1718
									local i = 0 -- 1719
									while i < #patterns do -- 1719
										local ____Content_24 = Content -- 1720
										local ____Content_searchFilesAsync_25 = Content.searchFilesAsync -- 1720
										local ____patterns_index_23 = patterns[i + 1] -- 1725
										local ____req_useRegex_20 = req.useRegex -- 1726
										if ____req_useRegex_20 == nil then -- 1726
											____req_useRegex_20 = false -- 1726
										end -- 1726
										local ____req_caseSensitive_21 = req.caseSensitive -- 1727
										if ____req_caseSensitive_21 == nil then -- 1727
											____req_caseSensitive_21 = false -- 1727
										end -- 1727
										local ____req_includeContent_22 = req.includeContent -- 1728
										if ____req_includeContent_22 == nil then -- 1728
											____req_includeContent_22 = true -- 1728
										end -- 1728
										allResults[#allResults + 1] = ____Content_searchFilesAsync_25( -- 1720
											____Content_24, -- 1720
											searchRoot, -- 1721
											codeExtensions, -- 1722
											extensionLevels, -- 1723
											searchGlobs, -- 1724
											____patterns_index_23, -- 1725
											____req_useRegex_20, -- 1726
											____req_caseSensitive_21, -- 1727
											____req_includeContent_22, -- 1728
											req.contentWindow or 120 -- 1729
										) -- 1729
										i = i + 1 -- 1719
									end -- 1719
								end -- 1719
								local results = mergeSearchFileResultsUnique(allResults) -- 1732
								local totalResults = #results -- 1733
								local limit = math.max( -- 1734
									1, -- 1734
									math.floor(req.limit or 20) -- 1734
								) -- 1734
								local offset = math.max( -- 1735
									0, -- 1735
									math.floor(req.offset or 0) -- 1735
								) -- 1735
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1736
								local nextOffset = offset + #paged -- 1737
								local hasMore = nextOffset < totalResults -- 1738
								local truncated = offset > 0 or hasMore -- 1739
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1740
								local groupByFile = req.groupByFile == true -- 1741
								resolve( -- 1742
									nil, -- 1742
									{ -- 1742
										success = true, -- 1743
										results = relativeResults, -- 1744
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1745
										totalResults = totalResults, -- 1746
										truncated = truncated, -- 1747
										limit = limit, -- 1748
										offset = offset, -- 1749
										nextOffset = nextOffset, -- 1750
										hasMore = hasMore, -- 1751
										groupByFile = groupByFile -- 1752
									} -- 1752
								) -- 1752
							end) -- 1752
							if not ____try then -- 1752
								____catch(____hasReturned) -- 1752
							end -- 1752
						end -- 1752
					end)) -- 1713
				end -- 1712
			) -- 1712
		) -- 1712
	end) -- 1712
end -- 1683
function ____exports.searchDoraAPI(req) -- 1761
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1761
		local pattern = __TS__StringTrim(req.pattern or "") -- 1772
		if pattern == "" then -- 1772
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1772
		end -- 1772
		local patterns = splitSearchPatterns(pattern) -- 1774
		if #patterns == 0 then -- 1774
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1774
		end -- 1774
		local docSource = req.docSource or "api" -- 1776
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1777
		local docRoot = target.root -- 1778
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1779
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1779
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1779
		end -- 1779
		local exts = target.exts -- 1783
		local dotExts = __TS__ArrayMap( -- 1784
			exts, -- 1784
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1784
		) -- 1784
		local globs = target.globs -- 1785
		local limit = math.max( -- 1786
			1, -- 1786
			math.floor(req.limit or 10) -- 1786
		) -- 1786
		return ____awaiter_resolve( -- 1786
			nil, -- 1786
			__TS__New( -- 1788
				__TS__Promise, -- 1788
				function(____, resolve) -- 1788
					Director.systemScheduler:schedule(once(function() -- 1789
						do -- 1789
							local function ____catch(e) -- 1789
								resolve( -- 1831
									nil, -- 1831
									{ -- 1831
										success = false, -- 1831
										message = tostring(e) -- 1831
									} -- 1831
								) -- 1831
							end -- 1831
							local ____try, ____hasReturned = pcall(function() -- 1831
								local allHits = {} -- 1791
								do -- 1791
									local p = 0 -- 1792
									while p < #patterns do -- 1792
										local ____Content_30 = Content -- 1793
										local ____Content_searchFilesAsync_31 = Content.searchFilesAsync -- 1793
										local ____array_29 = __TS__SparseArrayNew( -- 1793
											docRoot, -- 1794
											dotExts, -- 1795
											{}, -- 1796
											ensureSafeSearchGlobs(globs), -- 1797
											patterns[p + 1] -- 1798
										) -- 1798
										local ____req_useRegex_26 = req.useRegex -- 1799
										if ____req_useRegex_26 == nil then -- 1799
											____req_useRegex_26 = false -- 1799
										end -- 1799
										__TS__SparseArrayPush(____array_29, ____req_useRegex_26) -- 1799
										local ____req_caseSensitive_27 = req.caseSensitive -- 1800
										if ____req_caseSensitive_27 == nil then -- 1800
											____req_caseSensitive_27 = false -- 1800
										end -- 1800
										__TS__SparseArrayPush(____array_29, ____req_caseSensitive_27) -- 1800
										local ____req_includeContent_28 = req.includeContent -- 1801
										if ____req_includeContent_28 == nil then -- 1801
											____req_includeContent_28 = true -- 1801
										end -- 1801
										__TS__SparseArrayPush(____array_29, ____req_includeContent_28, req.contentWindow or 80) -- 1801
										local raw = ____Content_searchFilesAsync_31( -- 1793
											____Content_30, -- 1793
											__TS__SparseArraySpread(____array_29) -- 1793
										) -- 1793
										local hits = {} -- 1804
										do -- 1804
											local i = 0 -- 1805
											while i < #raw do -- 1805
												do -- 1805
													local row = raw[i + 1] -- 1806
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1807
													if file == "" then -- 1807
														goto __continue360 -- 1808
													end -- 1808
													hits[#hits + 1] = { -- 1809
														file = file, -- 1810
														line = type(row.line) == "number" and row.line or nil, -- 1811
														content = type(row.content) == "string" and row.content or nil -- 1812
													} -- 1812
												end -- 1812
												::__continue360:: -- 1812
												i = i + 1 -- 1805
											end -- 1805
										end -- 1805
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1815
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1815
											0, -- 1815
											limit -- 1815
										) -- 1815
										p = p + 1 -- 1792
									end -- 1792
								end -- 1792
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1817
								resolve(nil, { -- 1818
									success = true, -- 1819
									docSource = docSource, -- 1820
									docLanguage = req.docLanguage, -- 1821
									programmingLanguage = req.programmingLanguage, -- 1822
									exts = exts, -- 1823
									results = hits, -- 1824
									hint = "Use read_file directly with the file value from a search result to view the complete document. Do not add any prefixes.", -- 1825
									totalResults = #hits, -- 1826
									truncated = false, -- 1827
									limit = limit -- 1828
								}) -- 1828
							end) -- 1828
							if not ____try then -- 1828
								____catch(____hasReturned) -- 1828
							end -- 1828
						end -- 1828
					end)) -- 1789
				end -- 1788
			) -- 1788
		) -- 1788
	end) -- 1788
end -- 1761
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1837
	if options == nil then -- 1837
		options = {} -- 1837
	end -- 1837
	if #changes == 0 then -- 1837
		return {success = false, message = "empty changes"} -- 1839
	end -- 1839
	if not isValidWorkDir(workDir) then -- 1839
		return {success = false, message = "invalid workDir"} -- 1842
	end -- 1842
	if not getTaskStatus(taskId) then -- 1842
		return {success = false, message = "task not found"} -- 1845
	end -- 1845
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1847
	local dup = rejectDuplicatePaths(expandedChanges) -- 1848
	if dup then -- 1848
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1850
	end -- 1850
	for ____, change in ipairs(expandedChanges) do -- 1853
		if not isValidWorkspacePath(change.path) then -- 1853
			return {success = false, message = "invalid path: " .. change.path} -- 1855
		end -- 1855
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1855
			return {success = false, message = "missing content for " .. change.path} -- 1858
		end -- 1858
	end -- 1858
	local headSeq = getTaskHeadSeq(taskId) -- 1862
	if headSeq == nil then -- 1862
		return {success = false, message = "task not found"} -- 1863
	end -- 1863
	local nextSeq = headSeq + 1 -- 1864
	local checkpointId = insertCheckpoint( -- 1865
		taskId, -- 1865
		nextSeq, -- 1865
		options.summary or "", -- 1865
		options.toolName or "", -- 1865
		"PREPARED" -- 1865
	) -- 1865
	if checkpointId <= 0 then -- 1865
		return {success = false, message = "failed to create checkpoint"} -- 1867
	end -- 1867
	do -- 1867
		local i = 0 -- 1870
		while i < #expandedChanges do -- 1870
			local change = expandedChanges[i + 1] -- 1871
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1872
			if not fullPath then -- 1872
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1874
				return {success = false, message = "invalid path: " .. change.path} -- 1875
			end -- 1875
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 1875
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1878
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 1879
			end -- 1879
			local before = getFileState(fullPath) -- 1881
			local afterExists = change.op ~= "delete" -- 1882
			local afterContent = afterExists and (change.content or "") or "" -- 1883
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1884
				checkpointId, -- 1888
				i + 1, -- 1889
				change.path, -- 1890
				change.op, -- 1891
				before.exists and 1 or 0, -- 1892
				before.content, -- 1893
				afterExists and 1 or 0, -- 1894
				afterContent, -- 1895
				before.bytes, -- 1896
				#afterContent -- 1897
			}) -- 1897
			if inserted <= 0 then -- 1897
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1901
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1902
			end -- 1902
			i = i + 1 -- 1870
		end -- 1870
	end -- 1870
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1906
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1907
		if not fullPath then -- 1907
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1909
			return {success = false, message = "invalid path: " .. entry.path} -- 1910
		end -- 1910
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1912
		if not ok then -- 1912
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1914
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1915
		end -- 1915
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1915
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1918
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1919
		end -- 1919
	end -- 1919
	DB:exec( -- 1923
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1923
		{ -- 1925
			"APPLIED", -- 1925
			now(), -- 1925
			checkpointId -- 1925
		} -- 1925
	) -- 1925
	DB:exec( -- 1927
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1927
		{ -- 1929
			nextSeq, -- 1929
			now(), -- 1929
			taskId -- 1929
		} -- 1929
	) -- 1929
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1931
end -- 1837
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1939
	if not isValidWorkDir(workDir) then -- 1939
		return {success = false, message = "invalid workDir"} -- 1940
	end -- 1940
	if checkpointId <= 0 then -- 1940
		return {success = false, message = "invalid checkpointId"} -- 1941
	end -- 1941
	local entries = getCheckpointEntries(checkpointId, true) -- 1942
	if #entries == 0 then -- 1942
		return {success = false, message = "checkpoint not found or empty"} -- 1944
	end -- 1944
	for ____, entry in ipairs(entries) do -- 1946
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1947
		if not fullPath then -- 1947
			return {success = false, message = "invalid path: " .. entry.path} -- 1949
		end -- 1949
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1951
		if not ok then -- 1951
			Log( -- 1953
				"Error", -- 1953
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1953
			) -- 1953
			Log( -- 1954
				"Info", -- 1954
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1954
			) -- 1954
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1955
		end -- 1955
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1955
			Log( -- 1958
				"Error", -- 1958
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1958
			) -- 1958
			Log( -- 1959
				"Info", -- 1959
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1959
			) -- 1959
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1960
		end -- 1960
	end -- 1960
	DB:exec( -- 1963
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 1963
		{ -- 1963
			"REVERTED", -- 1963
			now(), -- 1963
			checkpointId -- 1963
		} -- 1963
	) -- 1963
	return {success = true, checkpointId = checkpointId} -- 1964
end -- 1939
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 1967
	if not isValidWorkDir(workDir) then -- 1967
		return {success = false, message = "invalid workDir"} -- 1968
	end -- 1968
	if not getTaskStatus(taskId) then -- 1968
		return {success = false, message = "task not found"} -- 1969
	end -- 1969
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 1970
	if #checkpoints == 0 then -- 1970
		return {success = false, message = "change set not found or empty"} -- 1972
	end -- 1972
	local lastCheckpointId = 0 -- 1974
	do -- 1974
		local i = 0 -- 1975
		while i < #checkpoints do -- 1975
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 1976
			if not result.success then -- 1976
				return {success = false, message = result.message} -- 1977
			end -- 1977
			lastCheckpointId = checkpoints[i + 1].id -- 1978
			i = i + 1 -- 1975
		end -- 1975
	end -- 1975
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 1980
end -- 1967
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1988
	return getCheckpointEntries(checkpointId, false) -- 1989
end -- 1988
function ____exports.getCheckpointDiff(checkpointId) -- 1992
	if checkpointId <= 0 then -- 1992
		return {success = false, message = "invalid checkpointId"} -- 1994
	end -- 1994
	local entries = getCheckpointEntries(checkpointId, false) -- 1996
	if #entries == 0 then -- 1996
		return {success = false, message = "checkpoint not found or empty"} -- 1998
	end -- 1998
	return { -- 2000
		success = true, -- 2001
		files = __TS__ArrayMap( -- 2002
			entries, -- 2002
			function(____, entry) return { -- 2002
				path = entry.path, -- 2003
				op = entry.op, -- 2004
				beforeExists = entry.beforeExists, -- 2005
				afterExists = entry.afterExists, -- 2006
				beforeContent = entry.beforeContent, -- 2007
				afterContent = entry.afterContent -- 2008
			} end -- 2008
		) -- 2008
	} -- 2008
end -- 1992
local function finalizeBuildResult(workDir, messages) -- 2013
	local normalized = __TS__ArrayMap( -- 2014
		messages, -- 2014
		function(____, m) return m.success and __TS__ObjectAssign( -- 2014
			{}, -- 2015
			m, -- 2015
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2015
		) or __TS__ObjectAssign( -- 2015
			{}, -- 2016
			m, -- 2016
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2016
		) end -- 2016
	) -- 2016
	local total = #normalized -- 2017
	local failed = 0 -- 2018
	do -- 2018
		local i = 0 -- 2019
		while i < #normalized do -- 2019
			if not normalized[i + 1].success then -- 2019
				failed = failed + 1 -- 2020
			end -- 2020
			i = i + 1 -- 2019
		end -- 2019
	end -- 2019
	local passed = total - failed -- 2022
	if failed > 0 then -- 2022
		return { -- 2024
			success = false, -- 2025
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 2026
			total = total, -- 2027
			passed = passed, -- 2028
			failed = failed, -- 2029
			messages = normalized -- 2030
		} -- 2030
	end -- 2030
	return { -- 2033
		success = true, -- 2034
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 2035
		total = total, -- 2036
		passed = passed, -- 2037
		failed = 0, -- 2038
		messages = normalized -- 2039
	} -- 2039
end -- 2013
function ____exports.build(req) -- 2043
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2043
		local targetRel = req.path or "" -- 2044
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2045
		if not target then -- 2045
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2045
		end -- 2045
		if not Content:exist(target) then -- 2045
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2045
		end -- 2045
		local messages = {} -- 2052
		if not Content:isdir(target) then -- 2052
			local kind = getSupportedBuildKind(target) -- 2054
			if not kind then -- 2054
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2054
			end -- 2054
			if kind == "ts" then -- 2054
				local content = Content:load(target) -- 2059
				if content == nil then -- 2059
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2059
				end -- 2059
				if isTiledEditorContent(content) then -- 2059
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2064
					return ____awaiter_resolve( -- 2064
						nil, -- 2064
						finalizeBuildResult(req.workDir, messages) -- 2065
					) -- 2065
				end -- 2065
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2065
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2065
				end -- 2065
				if not isDtsFile(target) then -- 2065
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 2071
				end -- 2071
			else -- 2071
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2074
			end -- 2074
			Log( -- 2076
				"Info", -- 2076
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2076
			) -- 2076
			return ____awaiter_resolve( -- 2076
				nil, -- 2076
				finalizeBuildResult(req.workDir, messages) -- 2077
			) -- 2077
		end -- 2077
		local listResult = ____exports.listFiles({ -- 2079
			workDir = req.workDir, -- 2080
			path = targetRel, -- 2081
			globs = __TS__ArrayMap( -- 2082
				codeExtensions, -- 2082
				function(____, e) return "**/*" .. e end -- 2082
			), -- 2082
			maxEntries = 10000 -- 2083
		}) -- 2083
		local relFiles = listResult.success and listResult.files or ({}) -- 2086
		local tsFileData = {} -- 2087
		local buildQueue = {} -- 2088
		for ____, rel in ipairs(relFiles) do -- 2089
			do -- 2089
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2090
				local kind = getSupportedBuildKind(file) -- 2091
				if not kind then -- 2091
					goto __continue423 -- 2092
				end -- 2092
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2093
				if kind ~= "ts" then -- 2093
					goto __continue423 -- 2095
				end -- 2095
				local content = Content:load(file) -- 2097
				if content == nil then -- 2097
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2099
					goto __continue423 -- 2100
				end -- 2100
				if isTiledEditorContent(content) then -- 2100
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2103
					goto __continue423 -- 2104
				end -- 2104
				tsFileData[file] = content -- 2106
			end -- 2106
			::__continue423:: -- 2106
		end -- 2106
		do -- 2106
			local i = 0 -- 2108
			while i < #buildQueue do -- 2108
				do -- 2108
					local ____buildQueue_index_32 = buildQueue[i + 1] -- 2109
					local file = ____buildQueue_index_32.file -- 2109
					local kind = ____buildQueue_index_32.kind -- 2109
					if kind == "ts" then -- 2109
						local content = tsFileData[file] -- 2111
						if content == nil or isDtsFile(file) then -- 2111
							goto __continue430 -- 2113
						end -- 2113
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2113
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2116
							goto __continue430 -- 2117
						end -- 2117
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 2119
						goto __continue430 -- 2120
					end -- 2120
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2122
				end -- 2122
				::__continue430:: -- 2122
				i = i + 1 -- 2108
			end -- 2108
		end -- 2108
		if #messages == 0 then -- 2108
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2125
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2125
		end -- 2125
		Log( -- 2128
			"Info", -- 2128
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2128
		) -- 2128
		return ____awaiter_resolve( -- 2128
			nil, -- 2128
			finalizeBuildResult(req.workDir, messages) -- 2129
		) -- 2129
	end) -- 2129
end -- 2043
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2132
local function truncateCommandOutput(output) -- 2134
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2134
		return output -- 2135
	end -- 2135
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2136
end -- 2134
local function executeLuaCommand(req) -- 2139
	local code = __TS__StringTrim(req.code or "") -- 2140
	if code == "" then -- 2140
		return __TS__Promise.resolve({ -- 2142
			success = false, -- 2142
			mode = "lua", -- 2142
			output = "", -- 2142
			message = "missing code", -- 2142
			phase = "validate" -- 2142
		}) -- 2142
	end -- 2142
	local output = {} -- 2144
	local env = setmetatable( -- 2145
		{ -- 2145
			projectDir = req.workDir, -- 2146
			print = function(...) -- 2147
				local values = {...} -- 2147
				local parts = {} -- 2148
				do -- 2148
					local i = 0 -- 2149
					while i < #values do -- 2149
						parts[#parts + 1] = tostring(values[i + 1]) -- 2150
						i = i + 1 -- 2149
					end -- 2149
				end -- 2149
				output[#output + 1] = table.concat(parts, "\t") -- 2152
			end, -- 2147
			refreshTree = function(path) -- 2154
				if path == nil then -- 2154
					return refreshProjectTree(req.workDir) -- 2156
				end -- 2156
				if type(path) ~= "string" then -- 2156
					error("refreshTree expects a project-relative file path string or no argument") -- 2159
				end -- 2159
				return refreshProjectTree(req.workDir, path) -- 2161
			end -- 2154
		}, -- 2154
		{__index = Dora} -- 2163
	) -- 2163
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 2166
	if not fn then -- 2166
		return __TS__Promise.resolve({ -- 2168
			success = false, -- 2169
			mode = "lua", -- 2170
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2171
			message = toStr(compileErr), -- 2172
			phase = "compile" -- 2173
		}) -- 2173
	end -- 2173
	return __TS__New( -- 2176
		__TS__Promise, -- 2176
		function(____, resolve) -- 2176
			Director.systemScheduler:schedule(once(function() -- 2177
				local ok, runtimeErr = pcall(fn) -- 2178
				if not ok then -- 2178
					resolve( -- 2180
						nil, -- 2180
						{ -- 2180
							success = false, -- 2181
							mode = "lua", -- 2182
							output = truncateCommandOutput(table.concat(output, "\n")), -- 2183
							message = toStr(runtimeErr), -- 2184
							phase = "execute" -- 2185
						} -- 2185
					) -- 2185
					return -- 2187
				end -- 2187
				resolve( -- 2189
					nil, -- 2189
					{ -- 2189
						success = true, -- 2189
						mode = "lua", -- 2189
						output = truncateCommandOutput(table.concat(output, "\n")) -- 2189
					} -- 2189
				) -- 2189
			end)) -- 2177
		end -- 2176
	) -- 2176
end -- 2139
local function formatGitStatusOutput(status) -- 2194
	if not status then -- 2194
		return "" -- 2195
	end -- 2195
	local lines = {} -- 2196
	local state = toStr(status.state) -- 2197
	local kind = toStr(status.kind) -- 2198
	local message = toStr(status.message) -- 2199
	local errorMessage = toStr(status.error) -- 2200
	if kind ~= "" or state ~= "" then -- 2200
		lines[#lines + 1] = table.concat( -- 2202
			__TS__ArrayFilter( -- 2202
				{kind, state}, -- 2202
				function(____, item) return item ~= "" end -- 2202
			), -- 2202
			": " -- 2202
		) -- 2202
	end -- 2202
	if message ~= "" then -- 2202
		lines[#lines + 1] = message -- 2204
	end -- 2204
	if errorMessage ~= "" then -- 2204
		lines[#lines + 1] = errorMessage -- 2205
	end -- 2205
	local data = status.data -- 2206
	if data ~= nil then -- 2206
		local dataText = encodeJSON(data) -- 2208
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 2209
	end -- 2209
	return truncateCommandOutput(table.concat(lines, "\n")) -- 2211
end -- 2194
local function emitGitProgress(mode, operationId, onProgress, status) -- 2214
	if not onProgress then -- 2214
		return -- 2220
	end -- 2220
	local progress = type(status.progress) == "number" and status.progress or nil -- 2221
	local kind = toStr(status.kind) -- 2222
	local message = toStr(status.message) -- 2223
	local state = toStr(status.state) -- 2224
	local jobId = type(status.id) == "number" and status.id or nil -- 2225
	onProgress({ -- 2226
		state = "running", -- 2227
		mode = mode, -- 2228
		operationId = operationId, -- 2229
		stage = kind ~= "" and kind or "git", -- 2230
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 2231
		progress = progress, -- 2232
		jobId = jobId, -- 2233
		gitState = state ~= "" and state or nil, -- 2234
		gitKind = kind ~= "" and kind or nil -- 2235
	}) -- 2235
end -- 2214
local function cloneGitToTarget(req) -- 2239
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2239
		local parsed = parseGitCloneCommand(req.command) -- 2247
		if parsed == nil then -- 2247
			return ____awaiter_resolve(nil, nil) -- 2247
		end -- 2247
		if not parsed.success then -- 2247
			return ____awaiter_resolve(nil, { -- 2247
				success = false, -- 2250
				mode = "git", -- 2250
				output = "", -- 2250
				message = parsed.message, -- 2250
				phase = "validate" -- 2250
			}) -- 2250
		end -- 2250
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 2252
		if not target then -- 2252
			return ____awaiter_resolve(nil, { -- 2252
				success = false, -- 2254
				mode = "git", -- 2254
				output = "", -- 2254
				message = "invalid clone target path", -- 2254
				phase = "validate" -- 2254
			}) -- 2254
		end -- 2254
		if Content:exist(target) then -- 2254
			return ____awaiter_resolve(nil, { -- 2254
				success = false, -- 2257
				mode = "git", -- 2257
				output = "", -- 2257
				message = "target already exists", -- 2257
				phase = "validate" -- 2257
			}) -- 2257
		end -- 2257
		local targetParent = Path:getPath(target) -- 2259
		if not ensureDirPath(targetParent) then -- 2259
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 2259
		end -- 2259
		local tempRoot = getAgentDownloadTempRoot() -- 2263
		if not ensureDirPath(tempRoot) then -- 2263
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 2263
		end -- 2263
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 2267
		Content:remove(tempPath) -- 2268
		local depth = parsed.depth or "1" -- 2269
		local ____array_33 = __TS__SparseArrayNew( -- 2269
			"clone", -- 2271
			quoteGitArg(parsed.url), -- 2272
			quoteGitArg(Path:getFilename(tempPath)), -- 2273
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 2274
				"-b", -- 2274
				quoteGitArg(parsed.ref) -- 2274
			}) or ({})) -- 2274
		) -- 2274
		__TS__SparseArrayPush( -- 2274
			____array_33, -- 2274
			table.unpack(depth ~= "" and ({ -- 2275
				"--depth",
				quoteGitArg(depth) -- 2275
			}) or ({})) -- 2275
		) -- 2275
		local command = table.concat( -- 2270
			{__TS__SparseArraySpread(____array_33)}, -- 2270
			" " -- 2276
		) -- 2276
		local ____this_35 -- 2276
		____this_35 = req -- 2277
		local ____opt_34 = ____this_35.onProgress -- 2277
		if ____opt_34 ~= nil then -- 2277
			____opt_34(____this_35, { -- 2277
				state = "pending", -- 2278
				mode = "git", -- 2279
				operationId = req.operationId, -- 2280
				stage = "clone", -- 2281
				message = "clone pending", -- 2282
				progress = 0 -- 2283
			}) -- 2283
		end -- 2283
		local gitRes = __TS__Await(runGitAndWait( -- 2285
			tempRoot, -- 2286
			command, -- 2287
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2288
			function() -- 2289
				local ____this_37 -- 2289
				____this_37 = req -- 2289
				local ____opt_36 = ____this_37.isCancelled -- 2289
				return (____opt_36 and ____opt_36(____this_37)) == true -- 2289
			end, -- 2289
			req.timeoutSeconds -- 2290
		)) -- 2290
		if not gitRes.success then -- 2290
			local cleanupError = cleanupPath(tempPath) -- 2293
			local ____formatGitStatusOutput_result_41 = formatGitStatusOutput(gitRes.status) -- 2297
			local ____temp_42 = gitRes.message or "git clone failed" -- 2298
			local ____gitRes_interrupted_40 = gitRes.interrupted -- 2299
			if not ____gitRes_interrupted_40 then -- 2299
				local ____this_39 -- 2299
				____this_39 = req -- 2299
				local ____opt_38 = ____this_39.isCancelled -- 2299
				____gitRes_interrupted_40 = (____opt_38 and ____opt_38(____this_39)) == true -- 2299
			end -- 2299
			return ____awaiter_resolve(nil, { -- 2299
				success = false, -- 2295
				mode = "git", -- 2296
				output = ____formatGitStatusOutput_result_41, -- 2297
				message = ____temp_42, -- 2298
				interrupted = ____gitRes_interrupted_40, -- 2299
				cleanupError = cleanupError -- 2300
			}) -- 2300
		end -- 2300
		if not Content:move(tempPath, target) then -- 2300
			local cleanupError = cleanupPath(tempPath) -- 2304
			return ____awaiter_resolve( -- 2304
				nil, -- 2304
				{ -- 2305
					success = false, -- 2305
					mode = "git", -- 2305
					output = formatGitStatusOutput(gitRes.status), -- 2305
					message = "failed to move cloned repository into target path", -- 2305
					cleanupError = cleanupError -- 2305
				} -- 2305
			) -- 2305
		end -- 2305
		if not refreshProjectTree(req.workDir) then -- 2305
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 2308
		end -- 2308
		local commit = getGitHeadCommit(target) -- 2310
		local output = table.concat( -- 2311
			__TS__ArrayFilter( -- 2311
				{ -- 2311
					formatGitStatusOutput(gitRes.status), -- 2312
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 2312
					commit ~= nil and "commit " .. commit or "" -- 2314
				}, -- 2314
				function(____, item) return item ~= "" end -- 2315
			), -- 2315
			"\n" -- 2315
		) -- 2315
		return ____awaiter_resolve( -- 2315
			nil, -- 2315
			{ -- 2316
				success = true, -- 2316
				mode = "git", -- 2316
				output = truncateCommandOutput(output) -- 2316
			} -- 2316
		) -- 2316
	end) -- 2316
end -- 2239
local function loadGitProfile() -- 2319
	local rows -- 2320
	do -- 2320
		local function ____catch() -- 2320
			return true, nil -- 2324
		end -- 2324
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2324
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 2322
		end) -- 2322
		if not ____try then -- 2322
			____hasReturned, ____returnValue = ____catch() -- 2322
		end -- 2322
		if ____hasReturned then -- 2322
			return ____returnValue -- 2321
		end -- 2321
	end -- 2321
	if not rows or not rows[1] then -- 2321
		return nil -- 2326
	end -- 2326
	local name = toStr(rows[1][1]) -- 2327
	local email = toStr(rows[1][2]) -- 2328
	if name == "" and email == "" then -- 2328
		return nil -- 2329
	end -- 2329
	return {name = name, email = email} -- 2330
end -- 2319
local function applyGitProfileToCommit(command) -- 2333
	local args = shellSplit(command) -- 2334
	if args[1] ~= "commit" then -- 2334
		return command -- 2335
	end -- 2335
	local hasName = false -- 2336
	local hasEmail = false -- 2337
	for ____, arg in ipairs(args) do -- 2338
		if arg == "--author-name" then
			hasName = true -- 2339
		end -- 2339
		if arg == "--author-email" then
			hasEmail = true -- 2340
		end -- 2340
	end -- 2340
	if hasName and hasEmail then -- 2340
		return command -- 2342
	end -- 2342
	local profile = loadGitProfile() -- 2343
	if not profile then -- 2343
		return command -- 2344
	end -- 2344
	local additions = {} -- 2345
	if not hasName and profile.name ~= "" then -- 2345
		__TS__ArrayPush( -- 2347
			additions, -- 2347
			"--author-name",
			quoteGitArg(profile.name) -- 2347
		) -- 2347
	end -- 2347
	if not hasEmail and profile.email ~= "" then -- 2347
		__TS__ArrayPush( -- 2350
			additions, -- 2350
			"--author-email",
			quoteGitArg(profile.email) -- 2350
		) -- 2350
	end -- 2350
	if #additions == 0 then -- 2350
		return command -- 2352
	end -- 2352
	return (command .. " ") .. table.concat(additions, " ") -- 2353
end -- 2333
local function executeGitCommand(req) -- 2356
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2356
		local command = normalizeGitCommand(req.command or "") -- 2365
		if command == "" then -- 2365
			return ____awaiter_resolve(nil, { -- 2365
				success = false, -- 2367
				mode = "git", -- 2367
				output = "", -- 2367
				message = "missing command", -- 2367
				phase = "validate" -- 2367
			}) -- 2367
		end -- 2367
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 2369
			workDir = req.workDir, -- 2370
			command = command, -- 2371
			operationId = req.operationId, -- 2372
			timeoutSeconds = req.timeoutSeconds, -- 2373
			onProgress = req.onProgress, -- 2374
			isCancelled = req.isCancelled -- 2375
		})) -- 2375
		if cloneResult ~= nil then -- 2375
			return ____awaiter_resolve(nil, cloneResult) -- 2375
		end -- 2375
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 2378
		if not cwd.success then -- 2378
			return ____awaiter_resolve(nil, { -- 2378
				success = false, -- 2380
				mode = "git", -- 2380
				output = "", -- 2380
				cwd = req.cwd, -- 2380
				message = cwd.message, -- 2380
				phase = "validate" -- 2380
			}) -- 2380
		end -- 2380
		command = applyGitProfileToCommit(command) -- 2382
		local ____this_44 -- 2382
		____this_44 = req -- 2383
		local ____opt_43 = ____this_44.onProgress -- 2383
		if ____opt_43 ~= nil then -- 2383
			____opt_43(____this_44, { -- 2383
				state = "pending", -- 2384
				mode = "git", -- 2385
				operationId = req.operationId, -- 2386
				stage = "git", -- 2387
				message = "git command pending", -- 2388
				progress = 0 -- 2389
			}) -- 2389
		end -- 2389
		local gitRes = __TS__Await(runGitAndWait( -- 2391
			cwd.path, -- 2392
			command, -- 2393
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2394
			function() -- 2395
				local ____this_46 -- 2395
				____this_46 = req -- 2395
				local ____opt_45 = ____this_46.isCancelled -- 2395
				return (____opt_45 and ____opt_45(____this_46)) == true -- 2395
			end, -- 2395
			req.timeoutSeconds -- 2396
		)) -- 2396
		local output = formatGitStatusOutput(gitRes.status) -- 2398
		if not gitRes.success then -- 2398
			local ____output_50 = output -- 2403
			local ____cwd_relative_51 = cwd.relative -- 2404
			local ____temp_52 = gitRes.message or "git command failed" -- 2405
			local ____gitRes_interrupted_49 = gitRes.interrupted -- 2406
			if not ____gitRes_interrupted_49 then -- 2406
				local ____this_48 -- 2406
				____this_48 = req -- 2406
				local ____opt_47 = ____this_48.isCancelled -- 2406
				____gitRes_interrupted_49 = (____opt_47 and ____opt_47(____this_48)) == true -- 2406
			end -- 2406
			return ____awaiter_resolve(nil, { -- 2406
				success = false, -- 2401
				mode = "git", -- 2402
				output = ____output_50, -- 2403
				cwd = ____cwd_relative_51, -- 2404
				message = ____temp_52, -- 2405
				interrupted = ____gitRes_interrupted_49 -- 2406
			}) -- 2406
		end -- 2406
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 2406
	end) -- 2406
end -- 2356
function ____exports.executeCommand(req) -- 2412
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2412
		local mode = req.mode -- 2422
		if mode ~= "lua" and mode ~= "git" then -- 2422
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 2422
		end -- 2422
		if mode == "lua" then -- 2422
			return ____awaiter_resolve( -- 2422
				nil, -- 2422
				executeLuaCommand({workDir = req.workDir, code = req.code or ""}) -- 2427
			) -- 2427
		end -- 2427
		local operationId = createOperationId() -- 2429
		return ____awaiter_resolve( -- 2429
			nil, -- 2429
			executeGitCommand({ -- 2430
				workDir = req.workDir, -- 2431
				command = req.command or "", -- 2432
				cwd = req.cwd, -- 2433
				timeoutSeconds = math.max( -- 2434
					1, -- 2434
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 2434
				), -- 2434
				operationId = operationId, -- 2435
				onProgress = req.onProgress, -- 2436
				isCancelled = req.isCancelled -- 2437
			}) -- 2437
		) -- 2437
	end) -- 2437
end -- 2412
function ____exports.fetchUrl(req) -- 2441
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2441
		local mode = "download" -- 2448
		local url = __TS__StringTrim(req.url or "") -- 2449
		local targetRel = __TS__StringTrim(req.target or "") -- 2450
		if not isHttpUrl(url) then -- 2450
			return ____awaiter_resolve(nil, { -- 2450
				success = false, -- 2452
				state = "failed", -- 2452
				mode = mode, -- 2452
				target = targetRel, -- 2452
				message = "fetch_url only supports http:// and https:// URLs" -- 2452
			}) -- 2452
		end -- 2452
		if targetRel == "" then -- 2452
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 2452
		end -- 2452
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 2457
		if not target then -- 2457
			return ____awaiter_resolve(nil, { -- 2457
				success = false, -- 2459
				state = "failed", -- 2459
				mode = mode, -- 2459
				target = targetRel, -- 2459
				message = "invalid target path" -- 2459
			}) -- 2459
		end -- 2459
		if Content:exist(target) then -- 2459
			return ____awaiter_resolve(nil, { -- 2459
				success = false, -- 2462
				state = "failed", -- 2462
				mode = mode, -- 2462
				target = targetRel, -- 2462
				message = "target already exists" -- 2462
			}) -- 2462
		end -- 2462
		local operationId = createOperationId() -- 2464
		local tempRoot = getAgentDownloadTempRoot() -- 2465
		if not ensureDirPath(tempRoot) then -- 2465
			return ____awaiter_resolve(nil, { -- 2465
				success = false, -- 2467
				state = "failed", -- 2467
				mode = mode, -- 2467
				target = targetRel, -- 2467
				message = "failed to create agent download temp directory" -- 2467
			}) -- 2467
		end -- 2467
		local tempPath = Path(tempRoot, operationId .. ".download") -- 2469
		Content:remove(tempPath) -- 2470
		local function emitProgress(progress) -- 2471
			if not req.onProgress then -- 2471
				return -- 2472
			end -- 2472
			req:onProgress(__TS__ObjectAssign({ -- 2473
				state = "running", -- 2474
				mode = mode, -- 2475
				operationId = operationId, -- 2476
				target = targetRel, -- 2477
				tempPath = tempPath -- 2478
			}, progress)) -- 2478
		end -- 2471
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 2482
		local function interrupted() -- 2487
			local ____this_54 -- 2487
			____this_54 = req -- 2487
			local ____opt_53 = ____this_54.isCancelled -- 2487
			return (____opt_53 and ____opt_53(____this_54)) == true -- 2487
		end -- 2487
		if not ensureDirForFile(tempPath) then -- 2487
			return ____awaiter_resolve(nil, { -- 2487
				success = false, -- 2489
				state = "failed", -- 2489
				mode = mode, -- 2489
				target = targetRel, -- 2489
				message = "failed to create temporary file directory" -- 2489
			}) -- 2489
		end -- 2489
		local downloadRes = __TS__Await(downloadFile({ -- 2491
			url = url, -- 2492
			tempPath = tempPath, -- 2493
			timeout = 600, -- 2494
			isCancelled = interrupted, -- 2495
			onProgress = function(____, current, total) -- 2496
				local totalNumber = type(total) == "number" and total or 0 -- 2497
				emitProgress({ -- 2498
					stage = "download", -- 2499
					message = "downloading", -- 2500
					current = current, -- 2501
					total = total, -- 2502
					progress = totalNumber > 0 and current / totalNumber or nil -- 2503
				}) -- 2503
			end -- 2496
		})) -- 2496
		if not downloadRes.success then -- 2496
			local cleanupError = cleanupPath(tempPath) -- 2508
			return ____awaiter_resolve( -- 2508
				nil, -- 2508
				{ -- 2509
					success = false, -- 2510
					state = "failed", -- 2511
					mode = mode, -- 2512
					target = targetRel, -- 2513
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 2514
					interrupted = downloadRes.interrupted or interrupted(), -- 2515
					cleanupError = cleanupError -- 2516
				} -- 2516
			) -- 2516
		end -- 2516
		if not ensureDirForFile(target) then -- 2516
			local cleanupError = cleanupPath(tempPath) -- 2520
			return ____awaiter_resolve(nil, { -- 2520
				success = false, -- 2521
				state = "failed", -- 2521
				mode = mode, -- 2521
				target = targetRel, -- 2521
				message = "failed to create target directory", -- 2521
				cleanupError = cleanupError -- 2521
			}) -- 2521
		end -- 2521
		if not Content:move(tempPath, target) then -- 2521
			local cleanupError = cleanupPath(tempPath) -- 2524
			return ____awaiter_resolve(nil, { -- 2524
				success = false, -- 2525
				state = "failed", -- 2525
				mode = mode, -- 2525
				target = targetRel, -- 2525
				message = "failed to move downloaded file into target path", -- 2525
				cleanupError = cleanupError -- 2525
			}) -- 2525
		end -- 2525
		local bytesWritten = downloadRes.bytesWritten -- 2527
		local ____try = __TS__AsyncAwaiter(function() -- 2527
			local size = Content:getAttr(target) -- 2529
			if bytesWritten == nil or bytesWritten <= 0 then -- 2529
				bytesWritten = type(size) == "number" and size or nil -- 2531
			end -- 2531
		end) -- 2531
		____try = ____try.catch( -- 2531
			____try, -- 2531
			function(____, _) -- 2531
				return __TS__AsyncAwaiter(function() -- 2531
				end) -- 2531
			end -- 2531
		) -- 2531
		__TS__Await(____try) -- 2528
		if bytesWritten == nil or bytesWritten <= 0 then -- 2528
			local ____try = __TS__AsyncAwaiter(function() -- 2528
				local loaded = Content:load(target) -- 2538
				if type(loaded) == "string" then -- 2538
					bytesWritten = #loaded -- 2540
				end -- 2540
			end) -- 2540
			____try = ____try.catch( -- 2540
				____try, -- 2540
				function(____, _) -- 2540
					return __TS__AsyncAwaiter(function() -- 2540
					end) -- 2540
				end -- 2540
			) -- 2540
			__TS__Await(____try) -- 2537
		end -- 2537
		if not syncDownloadedFileToWebIDE(target) then -- 2537
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 2547
		end -- 2547
		return ____awaiter_resolve(nil, { -- 2547
			success = true, -- 2549
			state = "done", -- 2549
			mode = mode, -- 2549
			target = targetRel, -- 2549
			bytesWritten = bytesWritten -- 2549
		}) -- 2549
	end) -- 2549
end -- 2441
return ____exports -- 2441