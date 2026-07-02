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
function getEngineLogText() -- 1401
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 1402
	if not Content:exist(folder) then -- 1402
		Content:mkdir(folder) -- 1404
	end -- 1404
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 1406
	if not App:saveLog(logPath) then -- 1406
		return nil -- 1408
	end -- 1408
	return Content:load(logPath) -- 1410
end -- 1410
function ensureSafeSearchGlobs(globs) -- 1550
	local result = {} -- 1551
	do -- 1551
		local i = 0 -- 1552
		while i < #globs do -- 1552
			result[#result + 1] = globs[i + 1] -- 1553
			i = i + 1 -- 1552
		end -- 1552
	end -- 1552
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1555
	do -- 1555
		local i = 0 -- 1556
		while i < #requiredExcludes do -- 1556
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1556
				result[#result + 1] = requiredExcludes[i + 1] -- 1558
			end -- 1558
			i = i + 1 -- 1556
		end -- 1556
	end -- 1556
	return result -- 1561
end -- 1561
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
				if payload.success then -- 1164
					local luaFile = Path:replaceExt(file, "lua") -- 1166
					if Content:save( -- 1166
						luaFile, -- 1167
						tostring(payload.luaCode) -- 1167
					) then -- 1167
						result = {success = true, file = file} -- 1168
					else -- 1168
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 1170
					end -- 1170
				else -- 1170
					result = { -- 1173
						success = false, -- 1173
						file = file, -- 1173
						message = tostring(payload.message) -- 1173
					} -- 1173
				end -- 1173
				done = true -- 1175
			end -- 1158
		) -- 1158
		local payload = encodeJSON({name = "TranspileTS", id = requestId, file = file, content = content}) -- 1177
		if not payload then -- 1177
			listener:removeFromParent() -- 1184
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 1184
		end -- 1184
		__TS__Await(__TS__New( -- 1187
			__TS__Promise, -- 1187
			function(____, resolve) -- 1187
				Director.systemScheduler:schedule(once(function() -- 1188
					emit("AppWS", "Send", payload) -- 1189
					wait(function() return done end) -- 1190
					if not done then -- 1190
						listener:removeFromParent() -- 1192
					end -- 1192
					resolve(nil) -- 1194
				end)) -- 1188
			end -- 1187
		)) -- 1187
		return ____awaiter_resolve(nil, result) -- 1187
	end) -- 1187
end -- 1145
function ____exports.createTask(prompt) -- 1200
	if prompt == nil then -- 1200
		prompt = "" -- 1200
	end -- 1200
	local t = now() -- 1201
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 1202
	if affected <= 0 then -- 1202
		return {success = false, message = "failed to create task"} -- 1207
	end -- 1207
	return { -- 1209
		success = true, -- 1209
		taskId = getLastInsertRowId() -- 1209
	} -- 1209
end -- 1200
function ____exports.setTaskStatus(taskId, status) -- 1212
	DB:exec( -- 1213
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 1213
		{ -- 1213
			status, -- 1213
			now(), -- 1213
			taskId -- 1213
		} -- 1213
	) -- 1213
	Log( -- 1214
		"Info", -- 1214
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 1214
	) -- 1214
end -- 1212
function ____exports.listCheckpoints(taskId) -- 1217
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 1218
	if not rows then -- 1218
		return {} -- 1225
	end -- 1225
	local items = {} -- 1226
	do -- 1226
		local i = 0 -- 1227
		while i < #rows do -- 1227
			local row = rows[i + 1] -- 1228
			items[#items + 1] = { -- 1229
				id = row[1], -- 1230
				taskId = row[2], -- 1231
				seq = row[3], -- 1232
				status = toStr(row[4]), -- 1233
				summary = toStr(row[5]), -- 1234
				toolName = toStr(row[6]), -- 1235
				createdAt = row[7] -- 1236
			} -- 1236
			i = i + 1 -- 1227
		end -- 1227
	end -- 1227
	return items -- 1239
end -- 1217
local function listCheckpointIdsForTask(taskId, desc) -- 1242
	if desc == nil then -- 1242
		desc = false -- 1242
	end -- 1242
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 1243
	if not rows then -- 1243
		return {} -- 1250
	end -- 1250
	local items = {} -- 1251
	do -- 1251
		local i = 0 -- 1252
		while i < #rows do -- 1252
			local row = rows[i + 1] -- 1253
			items[#items + 1] = {id = row[1], seq = row[2]} -- 1254
			i = i + 1 -- 1252
		end -- 1252
	end -- 1252
	return items -- 1259
end -- 1242
local function deriveFileOp(beforeExists, afterExists) -- 1262
	if not beforeExists and afterExists then -- 1262
		return "create" -- 1263
	end -- 1263
	if beforeExists and not afterExists then -- 1263
		return "delete" -- 1264
	end -- 1264
	return "write" -- 1265
end -- 1262
function ____exports.summarizeTaskChangeSet(taskId) -- 1268
	if not getTaskStatus(taskId) then -- 1268
		return {success = false, message = "task not found"} -- 1270
	end -- 1270
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1272
	local filesByPath = {} -- 1273
	local latestCheckpointId = nil -- 1279
	local latestCheckpointSeq = nil -- 1280
	do -- 1280
		local i = 0 -- 1281
		while i < #checkpoints do -- 1281
			local checkpoint = checkpoints[i + 1] -- 1282
			latestCheckpointId = checkpoint.id -- 1283
			latestCheckpointSeq = checkpoint.seq -- 1284
			local entries = getCheckpointEntries(checkpoint.id, false) -- 1285
			do -- 1285
				local j = 0 -- 1286
				while j < #entries do -- 1286
					local entry = entries[j + 1] -- 1287
					local item = filesByPath[entry.path] -- 1288
					if not item then -- 1288
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 1290
						filesByPath[entry.path] = item -- 1296
					end -- 1296
					item.afterExists = entry.afterExists -- 1298
					local ____item_checkpointIds_14 = item.checkpointIds -- 1298
					____item_checkpointIds_14[#____item_checkpointIds_14 + 1] = checkpoint.id -- 1299
					j = j + 1 -- 1286
				end -- 1286
			end -- 1286
			i = i + 1 -- 1281
		end -- 1281
	end -- 1281
	local files = {} -- 1302
	for ____, item in pairs(filesByPath) do -- 1303
		files[#files + 1] = { -- 1304
			path = item.path, -- 1305
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1306
			checkpointCount = #item.checkpointIds, -- 1307
			checkpointIds = item.checkpointIds -- 1308
		} -- 1308
	end -- 1308
	__TS__ArraySort( -- 1311
		files, -- 1311
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1311
	) -- 1311
	return { -- 1312
		success = true, -- 1313
		taskId = taskId, -- 1314
		checkpointCount = #checkpoints, -- 1315
		filesChanged = #files, -- 1316
		files = files, -- 1317
		latestCheckpointId = latestCheckpointId, -- 1318
		latestCheckpointSeq = latestCheckpointSeq -- 1319
	} -- 1319
end -- 1268
function ____exports.getTaskChangeSetDiff(taskId) -- 1323
	if not getTaskStatus(taskId) then -- 1323
		return {success = false, message = "task not found"} -- 1325
	end -- 1325
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1327
	if #checkpoints == 0 then -- 1327
		return {success = false, message = "change set not found or empty"} -- 1329
	end -- 1329
	local filesByPath = {} -- 1331
	do -- 1331
		local i = 0 -- 1338
		while i < #checkpoints do -- 1338
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 1339
			do -- 1339
				local j = 0 -- 1340
				while j < #entries do -- 1340
					local entry = entries[j + 1] -- 1341
					local item = filesByPath[entry.path] -- 1342
					if not item then -- 1342
						item = { -- 1344
							path = entry.path, -- 1345
							beforeExists = entry.beforeExists, -- 1346
							beforeContent = entry.beforeContent, -- 1347
							afterExists = entry.afterExists, -- 1348
							afterContent = entry.afterContent -- 1349
						} -- 1349
						filesByPath[entry.path] = item -- 1351
					end -- 1351
					item.afterExists = entry.afterExists -- 1353
					item.afterContent = entry.afterContent -- 1354
					j = j + 1 -- 1340
				end -- 1340
			end -- 1340
			i = i + 1 -- 1338
		end -- 1338
	end -- 1338
	local files = {} -- 1357
	for ____, item in pairs(filesByPath) do -- 1358
		files[#files + 1] = { -- 1359
			path = item.path, -- 1360
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1361
			beforeExists = item.beforeExists, -- 1362
			afterExists = item.afterExists, -- 1363
			beforeContent = item.beforeContent, -- 1364
			afterContent = item.afterContent -- 1365
		} -- 1365
	end -- 1365
	__TS__ArraySort( -- 1368
		files, -- 1368
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1368
	) -- 1368
	return {success = true, files = files} -- 1369
end -- 1323
local function readWorkspaceFile(workDir, path, docLanguage) -- 1372
	local engineLog = readEngineLogFile(path) -- 1373
	if engineLog then -- 1373
		return engineLog -- 1374
	end -- 1374
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1375
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 1375
		local attr = inspectReadableFile(fullPath) -- 1377
		if not attr.success then -- 1377
			return attr -- 1378
		end -- 1378
		return { -- 1379
			success = true, -- 1379
			content = Content:load(fullPath), -- 1379
			size = attr.size -- 1379
		} -- 1379
	end -- 1379
	local docPath = resolveAgentTutorialDocFilePath(path, docLanguage) -- 1381
	if docPath then -- 1381
		local attr = inspectReadableFile(docPath) -- 1383
		if not attr.success then -- 1383
			return attr -- 1384
		end -- 1384
		return { -- 1385
			success = true, -- 1385
			content = Content:load(docPath), -- 1385
			size = attr.size -- 1385
		} -- 1385
	end -- 1385
	if not fullPath then -- 1385
		return {success = false, message = "invalid path or workDir"} -- 1387
	end -- 1387
	return {success = false, message = "file not found"} -- 1388
end -- 1372
function ____exports.readFileRaw(workDir, path, docLanguage) -- 1391
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 1392
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 1392
		local attr = inspectReadableFile(path) -- 1394
		if not attr.success then -- 1394
			return attr -- 1395
		end -- 1395
		return { -- 1396
			success = true, -- 1396
			content = Content:load(path), -- 1396
			size = attr.size -- 1396
		} -- 1396
	end -- 1396
	return result -- 1398
end -- 1391
function ____exports.getLogs(req) -- 1413
	local text = getEngineLogText() -- 1414
	if text == nil then -- 1414
		return {success = false, message = "failed to read engine logs"} -- 1416
	end -- 1416
	local tailLines = math.max( -- 1418
		1, -- 1418
		math.floor(req and req.tailLines or 200) -- 1418
	) -- 1418
	local allLines = __TS__StringSplit(text, "\n") -- 1419
	local logs = __TS__ArraySlice( -- 1420
		allLines, -- 1420
		math.max(0, #allLines - tailLines) -- 1420
	) -- 1420
	return req and req.joinText and ({ -- 1421
		success = true, -- 1421
		logs = logs, -- 1421
		text = table.concat(logs, "\n") -- 1421
	}) or ({success = true, logs = logs}) -- 1421
end -- 1413
function ____exports.listFiles(req) -- 1424
	local root = req.path or "" -- 1430
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 1431
	if not searchRoot then -- 1431
		return {success = false, message = "invalid path or workDir"} -- 1433
	end -- 1433
	do -- 1433
		local function ____catch(e) -- 1433
			return true, { -- 1451
				success = false, -- 1451
				message = tostring(e) -- 1451
			} -- 1451
		end -- 1451
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1451
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 1436
			local globs = ensureSafeSearchGlobs(userGlobs) -- 1437
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 1438
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 1439
			local totalEntries = #files -- 1440
			local maxEntries = math.max( -- 1441
				1, -- 1441
				math.floor(req.maxEntries or 200) -- 1441
			) -- 1441
			local truncated = totalEntries > maxEntries -- 1442
			return true, { -- 1443
				success = true, -- 1444
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 1445
				totalEntries = totalEntries, -- 1446
				truncated = truncated, -- 1447
				maxEntries = maxEntries -- 1448
			} -- 1448
		end) -- 1448
		if not ____try then -- 1448
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1448
		end -- 1448
		if ____hasReturned then -- 1448
			return ____returnValue -- 1435
		end -- 1435
	end -- 1435
end -- 1424
local function formatReadSlice(content, startLine, endLine) -- 1455
	local lines = __TS__StringSplit(content, "\n") -- 1460
	local totalLines = #lines -- 1461
	if totalLines == 0 then -- 1461
		return { -- 1463
			success = true, -- 1464
			content = "", -- 1465
			totalLines = 0, -- 1466
			startLine = 1, -- 1467
			endLine = 0, -- 1468
			truncated = false -- 1469
		} -- 1469
	end -- 1469
	local rawStart = math.floor(startLine) -- 1472
	local rawEnd = math.floor(endLine) -- 1473
	if rawStart == 0 then -- 1473
		return {success = false, message = "startLine cannot be 0"} -- 1475
	end -- 1475
	if rawEnd == 0 then -- 1475
		return {success = false, message = "endLine cannot be 0"} -- 1478
	end -- 1478
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1480
	if start > totalLines then -- 1480
		return { -- 1484
			success = false, -- 1484
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1484
		} -- 1484
	end -- 1484
	local ____end = math.min( -- 1486
		totalLines, -- 1487
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1488
	) -- 1488
	if ____end < start then -- 1488
		return { -- 1493
			success = false, -- 1494
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1495
		} -- 1495
	end -- 1495
	local slice = {} -- 1498
	do -- 1498
		local i = start -- 1499
		while i <= ____end do -- 1499
			slice[#slice + 1] = lines[i] -- 1500
			i = i + 1 -- 1499
		end -- 1499
	end -- 1499
	local truncated = start > 1 or ____end < totalLines -- 1502
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1503
	local body = table.concat(slice, "\n") -- 1508
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1509
	return { -- 1510
		success = true, -- 1511
		content = output, -- 1512
		totalLines = totalLines, -- 1513
		startLine = start, -- 1514
		endLine = ____end, -- 1515
		truncated = truncated -- 1516
	} -- 1516
end -- 1455
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1520
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1527
	if not fallback.success or fallback.content == nil then -- 1527
		return fallback -- 1528
	end -- 1528
	local resolvedStartLine = startLine or 1 -- 1529
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1530
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1531
end -- 1520
local codeExtensions = { -- 1538
	".lua", -- 1538
	".tl", -- 1538
	".yue", -- 1538
	".ts", -- 1538
	".tsx", -- 1538
	".xml", -- 1538
	".md", -- 1538
	".yarn", -- 1538
	".wa", -- 1538
	".mod" -- 1538
} -- 1538
extensionLevels = { -- 1539
	vs = 2, -- 1540
	bl = 2, -- 1541
	ts = 1, -- 1542
	tsx = 1, -- 1543
	tl = 1, -- 1544
	yue = 1, -- 1545
	xml = 1, -- 1546
	lua = 0 -- 1547
} -- 1547
local function splitSearchPatterns(pattern) -- 1564
	local trimmed = __TS__StringTrim(pattern or "") -- 1565
	if trimmed == "" then -- 1565
		return {} -- 1566
	end -- 1566
	local out = {} -- 1567
	local seen = __TS__New(Set) -- 1568
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1569
		local p = __TS__StringTrim(tostring(p0)) -- 1570
		if p ~= "" and not seen:has(p) then -- 1570
			seen:add(p) -- 1572
			out[#out + 1] = p -- 1573
		end -- 1573
	end -- 1573
	return out -- 1576
end -- 1564
local function mergeSearchFileResultsUnique(resultsList) -- 1579
	local merged = {} -- 1580
	local seen = __TS__New(Set) -- 1581
	do -- 1581
		local i = 0 -- 1582
		while i < #resultsList do -- 1582
			local list = resultsList[i + 1] -- 1583
			do -- 1583
				local j = 0 -- 1584
				while j < #list do -- 1584
					do -- 1584
						local row = list[j + 1] -- 1585
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1586
						if seen:has(key) then -- 1586
							goto __continue314 -- 1587
						end -- 1587
						seen:add(key) -- 1588
						merged[#merged + 1] = list[j + 1] -- 1589
					end -- 1589
					::__continue314:: -- 1589
					j = j + 1 -- 1584
				end -- 1584
			end -- 1584
			i = i + 1 -- 1582
		end -- 1582
	end -- 1582
	return merged -- 1592
end -- 1579
local function buildGroupedSearchResults(results) -- 1595
	local order = {} -- 1600
	local grouped = __TS__New(Map) -- 1601
	do -- 1601
		local i = 0 -- 1606
		while i < #results do -- 1606
			local row = results[i + 1] -- 1607
			local file = row.file -- 1608
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1609
			local bucket = grouped:get(key) -- 1610
			if not bucket then -- 1610
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1612
				grouped:set(key, bucket) -- 1613
				order[#order + 1] = key -- 1614
			end -- 1614
			bucket.totalMatches = bucket.totalMatches + 1 -- 1616
			local ____bucket_matches_19 = bucket.matches -- 1616
			____bucket_matches_19[#____bucket_matches_19 + 1] = results[i + 1] -- 1617
			i = i + 1 -- 1606
		end -- 1606
	end -- 1606
	local out = {} -- 1619
	do -- 1619
		local i = 0 -- 1624
		while i < #order do -- 1624
			local bucket = grouped:get(order[i + 1]) -- 1625
			if bucket then -- 1625
				out[#out + 1] = bucket -- 1626
			end -- 1626
			i = i + 1 -- 1624
		end -- 1624
	end -- 1624
	return out -- 1628
end -- 1595
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1631
	local merged = {} -- 1632
	local seen = __TS__New(Set) -- 1633
	local index = 0 -- 1634
	local advanced = true -- 1635
	while advanced do -- 1635
		advanced = false -- 1637
		do -- 1637
			local i = 0 -- 1638
			while i < #resultsList do -- 1638
				do -- 1638
					local list = resultsList[i + 1] -- 1639
					if index >= #list then -- 1639
						goto __continue326 -- 1640
					end -- 1640
					advanced = true -- 1641
					local row = list[index + 1] -- 1642
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1643
					if seen:has(key) then -- 1643
						goto __continue326 -- 1644
					end -- 1644
					seen:add(key) -- 1645
					merged[#merged + 1] = row -- 1646
				end -- 1646
				::__continue326:: -- 1646
				i = i + 1 -- 1638
			end -- 1638
		end -- 1638
		index = index + 1 -- 1648
	end -- 1648
	return merged -- 1650
end -- 1631
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1653
	if docSource ~= "api" then -- 1653
		return 100 -- 1654
	end -- 1654
	if programmingLanguage ~= "tsx" then -- 1654
		return 100 -- 1655
	end -- 1655
	repeat -- 1655
		local ____switch332 = string.lower(Path:getFilename(file)) -- 1655
		local ____cond332 = ____switch332 == "jsx.d.ts" -- 1655
		if ____cond332 then -- 1655
			return 0 -- 1657
		end -- 1657
		____cond332 = ____cond332 or ____switch332 == "dorax.d.ts" -- 1657
		if ____cond332 then -- 1657
			return 1 -- 1658
		end -- 1658
		____cond332 = ____cond332 or ____switch332 == "dora.d.ts" -- 1658
		if ____cond332 then -- 1658
			return 2 -- 1659
		end -- 1659
		do -- 1659
			return 100 -- 1660
		end -- 1660
	until true -- 1660
end -- 1653
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1664
	local sorted = __TS__ArraySlice(hits) -- 1669
	__TS__ArraySort( -- 1670
		sorted, -- 1670
		function(____, a, b) -- 1670
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1671
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1672
			if pa ~= pb then -- 1672
				return pa - pb -- 1673
			end -- 1673
			local fa = string.lower(a.file) -- 1674
			local fb = string.lower(b.file) -- 1675
			if fa ~= fb then -- 1675
				return fa < fb and -1 or 1 -- 1676
			end -- 1676
			return (a.line or 0) - (b.line or 0) -- 1677
		end -- 1670
	) -- 1670
	return sorted -- 1679
end -- 1664
function ____exports.searchFiles(req) -- 1682
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1682
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1695
		if not resolvedPath then -- 1695
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1695
		end -- 1695
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1699
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1700
		if not searchRoot then -- 1700
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1700
		end -- 1700
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1700
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1700
		end -- 1700
		local patterns = splitSearchPatterns(req.pattern) -- 1707
		if #patterns == 0 then -- 1707
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1707
		end -- 1707
		return ____awaiter_resolve( -- 1707
			nil, -- 1707
			__TS__New( -- 1711
				__TS__Promise, -- 1711
				function(____, resolve) -- 1711
					Director.systemScheduler:schedule(once(function() -- 1712
						do -- 1712
							local function ____catch(e) -- 1712
								resolve( -- 1754
									nil, -- 1754
									{ -- 1754
										success = false, -- 1754
										message = tostring(e) -- 1754
									} -- 1754
								) -- 1754
							end -- 1754
							local ____try, ____hasReturned = pcall(function() -- 1754
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1714
								local allResults = {} -- 1717
								do -- 1717
									local i = 0 -- 1718
									while i < #patterns do -- 1718
										local ____Content_24 = Content -- 1719
										local ____Content_searchFilesAsync_25 = Content.searchFilesAsync -- 1719
										local ____patterns_index_23 = patterns[i + 1] -- 1724
										local ____req_useRegex_20 = req.useRegex -- 1725
										if ____req_useRegex_20 == nil then -- 1725
											____req_useRegex_20 = false -- 1725
										end -- 1725
										local ____req_caseSensitive_21 = req.caseSensitive -- 1726
										if ____req_caseSensitive_21 == nil then -- 1726
											____req_caseSensitive_21 = false -- 1726
										end -- 1726
										local ____req_includeContent_22 = req.includeContent -- 1727
										if ____req_includeContent_22 == nil then -- 1727
											____req_includeContent_22 = true -- 1727
										end -- 1727
										allResults[#allResults + 1] = ____Content_searchFilesAsync_25( -- 1719
											____Content_24, -- 1719
											searchRoot, -- 1720
											codeExtensions, -- 1721
											extensionLevels, -- 1722
											searchGlobs, -- 1723
											____patterns_index_23, -- 1724
											____req_useRegex_20, -- 1725
											____req_caseSensitive_21, -- 1726
											____req_includeContent_22, -- 1727
											req.contentWindow or 120 -- 1728
										) -- 1728
										i = i + 1 -- 1718
									end -- 1718
								end -- 1718
								local results = mergeSearchFileResultsUnique(allResults) -- 1731
								local totalResults = #results -- 1732
								local limit = math.max( -- 1733
									1, -- 1733
									math.floor(req.limit or 20) -- 1733
								) -- 1733
								local offset = math.max( -- 1734
									0, -- 1734
									math.floor(req.offset or 0) -- 1734
								) -- 1734
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1735
								local nextOffset = offset + #paged -- 1736
								local hasMore = nextOffset < totalResults -- 1737
								local truncated = offset > 0 or hasMore -- 1738
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1739
								local groupByFile = req.groupByFile == true -- 1740
								resolve( -- 1741
									nil, -- 1741
									{ -- 1741
										success = true, -- 1742
										results = relativeResults, -- 1743
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1744
										totalResults = totalResults, -- 1745
										truncated = truncated, -- 1746
										limit = limit, -- 1747
										offset = offset, -- 1748
										nextOffset = nextOffset, -- 1749
										hasMore = hasMore, -- 1750
										groupByFile = groupByFile -- 1751
									} -- 1751
								) -- 1751
							end) -- 1751
							if not ____try then -- 1751
								____catch(____hasReturned) -- 1751
							end -- 1751
						end -- 1751
					end)) -- 1712
				end -- 1711
			) -- 1711
		) -- 1711
	end) -- 1711
end -- 1682
function ____exports.searchDoraAPI(req) -- 1760
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1760
		local pattern = __TS__StringTrim(req.pattern or "") -- 1771
		if pattern == "" then -- 1771
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1771
		end -- 1771
		local patterns = splitSearchPatterns(pattern) -- 1773
		if #patterns == 0 then -- 1773
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1773
		end -- 1773
		local docSource = req.docSource or "api" -- 1775
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1776
		local docRoot = target.root -- 1777
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1778
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1778
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1778
		end -- 1778
		local exts = target.exts -- 1782
		local dotExts = __TS__ArrayMap( -- 1783
			exts, -- 1783
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1783
		) -- 1783
		local globs = target.globs -- 1784
		local limit = math.max( -- 1785
			1, -- 1785
			math.floor(req.limit or 10) -- 1785
		) -- 1785
		return ____awaiter_resolve( -- 1785
			nil, -- 1785
			__TS__New( -- 1787
				__TS__Promise, -- 1787
				function(____, resolve) -- 1787
					Director.systemScheduler:schedule(once(function() -- 1788
						do -- 1788
							local function ____catch(e) -- 1788
								resolve( -- 1830
									nil, -- 1830
									{ -- 1830
										success = false, -- 1830
										message = tostring(e) -- 1830
									} -- 1830
								) -- 1830
							end -- 1830
							local ____try, ____hasReturned = pcall(function() -- 1830
								local allHits = {} -- 1790
								do -- 1790
									local p = 0 -- 1791
									while p < #patterns do -- 1791
										local ____Content_30 = Content -- 1792
										local ____Content_searchFilesAsync_31 = Content.searchFilesAsync -- 1792
										local ____array_29 = __TS__SparseArrayNew( -- 1792
											docRoot, -- 1793
											dotExts, -- 1794
											{}, -- 1795
											ensureSafeSearchGlobs(globs), -- 1796
											patterns[p + 1] -- 1797
										) -- 1797
										local ____req_useRegex_26 = req.useRegex -- 1798
										if ____req_useRegex_26 == nil then -- 1798
											____req_useRegex_26 = false -- 1798
										end -- 1798
										__TS__SparseArrayPush(____array_29, ____req_useRegex_26) -- 1798
										local ____req_caseSensitive_27 = req.caseSensitive -- 1799
										if ____req_caseSensitive_27 == nil then -- 1799
											____req_caseSensitive_27 = false -- 1799
										end -- 1799
										__TS__SparseArrayPush(____array_29, ____req_caseSensitive_27) -- 1799
										local ____req_includeContent_28 = req.includeContent -- 1800
										if ____req_includeContent_28 == nil then -- 1800
											____req_includeContent_28 = true -- 1800
										end -- 1800
										__TS__SparseArrayPush(____array_29, ____req_includeContent_28, req.contentWindow or 80) -- 1800
										local raw = ____Content_searchFilesAsync_31( -- 1792
											____Content_30, -- 1792
											__TS__SparseArraySpread(____array_29) -- 1792
										) -- 1792
										local hits = {} -- 1803
										do -- 1803
											local i = 0 -- 1804
											while i < #raw do -- 1804
												do -- 1804
													local row = raw[i + 1] -- 1805
													local file = toDocRelativePath(resultBaseRoot, row.file) -- 1806
													if file == "" then -- 1806
														goto __continue359 -- 1807
													end -- 1807
													hits[#hits + 1] = { -- 1808
														file = file, -- 1809
														line = type(row.line) == "number" and row.line or nil, -- 1810
														content = type(row.content) == "string" and row.content or nil -- 1811
													} -- 1811
												end -- 1811
												::__continue359:: -- 1811
												i = i + 1 -- 1804
											end -- 1804
										end -- 1804
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1814
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1814
											0, -- 1814
											limit -- 1814
										) -- 1814
										p = p + 1 -- 1791
									end -- 1791
								end -- 1791
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1816
								resolve(nil, { -- 1817
									success = true, -- 1818
									docSource = docSource, -- 1819
									docLanguage = req.docLanguage, -- 1820
									programmingLanguage = req.programmingLanguage, -- 1821
									exts = exts, -- 1822
									results = hits, -- 1823
									hint = "Use read_file directly with the file value from a search result to view the complete document. Do not add any prefixes.", -- 1824
									totalResults = #hits, -- 1825
									truncated = false, -- 1826
									limit = limit -- 1827
								}) -- 1827
							end) -- 1827
							if not ____try then -- 1827
								____catch(____hasReturned) -- 1827
							end -- 1827
						end -- 1827
					end)) -- 1788
				end -- 1787
			) -- 1787
		) -- 1787
	end) -- 1787
end -- 1760
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1836
	if options == nil then -- 1836
		options = {} -- 1836
	end -- 1836
	if #changes == 0 then -- 1836
		return {success = false, message = "empty changes"} -- 1838
	end -- 1838
	if not isValidWorkDir(workDir) then -- 1838
		return {success = false, message = "invalid workDir"} -- 1841
	end -- 1841
	if not getTaskStatus(taskId) then -- 1841
		return {success = false, message = "task not found"} -- 1844
	end -- 1844
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1846
	local dup = rejectDuplicatePaths(expandedChanges) -- 1847
	if dup then -- 1847
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1849
	end -- 1849
	for ____, change in ipairs(expandedChanges) do -- 1852
		if not isValidWorkspacePath(change.path) then -- 1852
			return {success = false, message = "invalid path: " .. change.path} -- 1854
		end -- 1854
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1854
			return {success = false, message = "missing content for " .. change.path} -- 1857
		end -- 1857
	end -- 1857
	local headSeq = getTaskHeadSeq(taskId) -- 1861
	if headSeq == nil then -- 1861
		return {success = false, message = "task not found"} -- 1862
	end -- 1862
	local nextSeq = headSeq + 1 -- 1863
	local checkpointId = insertCheckpoint( -- 1864
		taskId, -- 1864
		nextSeq, -- 1864
		options.summary or "", -- 1864
		options.toolName or "", -- 1864
		"PREPARED" -- 1864
	) -- 1864
	if checkpointId <= 0 then -- 1864
		return {success = false, message = "failed to create checkpoint"} -- 1866
	end -- 1866
	do -- 1866
		local i = 0 -- 1869
		while i < #expandedChanges do -- 1869
			local change = expandedChanges[i + 1] -- 1870
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1871
			if not fullPath then -- 1871
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1873
				return {success = false, message = "invalid path: " .. change.path} -- 1874
			end -- 1874
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 1874
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1877
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 1878
			end -- 1878
			local before = getFileState(fullPath) -- 1880
			local afterExists = change.op ~= "delete" -- 1881
			local afterContent = afterExists and (change.content or "") or "" -- 1882
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1883
				checkpointId, -- 1887
				i + 1, -- 1888
				change.path, -- 1889
				change.op, -- 1890
				before.exists and 1 or 0, -- 1891
				before.content, -- 1892
				afterExists and 1 or 0, -- 1893
				afterContent, -- 1894
				before.bytes, -- 1895
				#afterContent -- 1896
			}) -- 1896
			if inserted <= 0 then -- 1896
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1900
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1901
			end -- 1901
			i = i + 1 -- 1869
		end -- 1869
	end -- 1869
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1905
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1906
		if not fullPath then -- 1906
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1908
			return {success = false, message = "invalid path: " .. entry.path} -- 1909
		end -- 1909
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1911
		if not ok then -- 1911
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1913
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1914
		end -- 1914
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1914
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1917
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1918
		end -- 1918
	end -- 1918
	DB:exec( -- 1922
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1922
		{ -- 1924
			"APPLIED", -- 1924
			now(), -- 1924
			checkpointId -- 1924
		} -- 1924
	) -- 1924
	DB:exec( -- 1926
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1926
		{ -- 1928
			nextSeq, -- 1928
			now(), -- 1928
			taskId -- 1928
		} -- 1928
	) -- 1928
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1930
end -- 1836
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1938
	if not isValidWorkDir(workDir) then -- 1938
		return {success = false, message = "invalid workDir"} -- 1939
	end -- 1939
	if checkpointId <= 0 then -- 1939
		return {success = false, message = "invalid checkpointId"} -- 1940
	end -- 1940
	local entries = getCheckpointEntries(checkpointId, true) -- 1941
	if #entries == 0 then -- 1941
		return {success = false, message = "checkpoint not found or empty"} -- 1943
	end -- 1943
	for ____, entry in ipairs(entries) do -- 1945
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1946
		if not fullPath then -- 1946
			return {success = false, message = "invalid path: " .. entry.path} -- 1948
		end -- 1948
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 1950
		if not ok then -- 1950
			Log( -- 1952
				"Error", -- 1952
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1952
			) -- 1952
			Log( -- 1953
				"Info", -- 1953
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1953
			) -- 1953
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 1954
		end -- 1954
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 1954
			Log( -- 1957
				"Error", -- 1957
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 1957
			) -- 1957
			Log( -- 1958
				"Info", -- 1958
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 1958
			) -- 1958
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 1959
		end -- 1959
	end -- 1959
	DB:exec( -- 1962
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 1962
		{ -- 1962
			"REVERTED", -- 1962
			now(), -- 1962
			checkpointId -- 1962
		} -- 1962
	) -- 1962
	return {success = true, checkpointId = checkpointId} -- 1963
end -- 1938
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 1966
	if not isValidWorkDir(workDir) then -- 1966
		return {success = false, message = "invalid workDir"} -- 1967
	end -- 1967
	if not getTaskStatus(taskId) then -- 1967
		return {success = false, message = "task not found"} -- 1968
	end -- 1968
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 1969
	if #checkpoints == 0 then -- 1969
		return {success = false, message = "change set not found or empty"} -- 1971
	end -- 1971
	local lastCheckpointId = 0 -- 1973
	do -- 1973
		local i = 0 -- 1974
		while i < #checkpoints do -- 1974
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 1975
			if not result.success then -- 1975
				return {success = false, message = result.message} -- 1976
			end -- 1976
			lastCheckpointId = checkpoints[i + 1].id -- 1977
			i = i + 1 -- 1974
		end -- 1974
	end -- 1974
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 1979
end -- 1966
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 1987
	return getCheckpointEntries(checkpointId, false) -- 1988
end -- 1987
function ____exports.getCheckpointDiff(checkpointId) -- 1991
	if checkpointId <= 0 then -- 1991
		return {success = false, message = "invalid checkpointId"} -- 1993
	end -- 1993
	local entries = getCheckpointEntries(checkpointId, false) -- 1995
	if #entries == 0 then -- 1995
		return {success = false, message = "checkpoint not found or empty"} -- 1997
	end -- 1997
	return { -- 1999
		success = true, -- 2000
		files = __TS__ArrayMap( -- 2001
			entries, -- 2001
			function(____, entry) return { -- 2001
				path = entry.path, -- 2002
				op = entry.op, -- 2003
				beforeExists = entry.beforeExists, -- 2004
				afterExists = entry.afterExists, -- 2005
				beforeContent = entry.beforeContent, -- 2006
				afterContent = entry.afterContent -- 2007
			} end -- 2007
		) -- 2007
	} -- 2007
end -- 1991
local function finalizeBuildResult(workDir, messages) -- 2012
	local normalized = __TS__ArrayMap( -- 2013
		messages, -- 2013
		function(____, m) return m.success and __TS__ObjectAssign( -- 2013
			{}, -- 2014
			m, -- 2014
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2014
		) or __TS__ObjectAssign( -- 2014
			{}, -- 2015
			m, -- 2015
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2015
		) end -- 2015
	) -- 2015
	local total = #normalized -- 2016
	local failed = 0 -- 2017
	do -- 2017
		local i = 0 -- 2018
		while i < #normalized do -- 2018
			if not normalized[i + 1].success then -- 2018
				failed = failed + 1 -- 2019
			end -- 2019
			i = i + 1 -- 2018
		end -- 2018
	end -- 2018
	local passed = total - failed -- 2021
	if failed > 0 then -- 2021
		return { -- 2023
			success = false, -- 2024
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 2025
			total = total, -- 2026
			passed = passed, -- 2027
			failed = failed, -- 2028
			messages = normalized -- 2029
		} -- 2029
	end -- 2029
	return { -- 2032
		success = true, -- 2033
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 2034
		total = total, -- 2035
		passed = passed, -- 2036
		failed = 0, -- 2037
		messages = normalized -- 2038
	} -- 2038
end -- 2012
function ____exports.build(req) -- 2042
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2042
		local targetRel = req.path or "" -- 2043
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2044
		if not target then -- 2044
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2044
		end -- 2044
		if not Content:exist(target) then -- 2044
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2044
		end -- 2044
		local messages = {} -- 2051
		if not Content:isdir(target) then -- 2051
			local kind = getSupportedBuildKind(target) -- 2053
			if not kind then -- 2053
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2053
			end -- 2053
			if kind == "ts" then -- 2053
				local content = Content:load(target) -- 2058
				if content == nil then -- 2058
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2058
				end -- 2058
				if isTiledEditorContent(content) then -- 2058
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2063
					return ____awaiter_resolve( -- 2063
						nil, -- 2063
						finalizeBuildResult(req.workDir, messages) -- 2064
					) -- 2064
				end -- 2064
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2064
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2064
				end -- 2064
				if not isDtsFile(target) then -- 2064
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 2070
				end -- 2070
			else -- 2070
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2073
			end -- 2073
			Log( -- 2075
				"Info", -- 2075
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2075
			) -- 2075
			return ____awaiter_resolve( -- 2075
				nil, -- 2075
				finalizeBuildResult(req.workDir, messages) -- 2076
			) -- 2076
		end -- 2076
		local listResult = ____exports.listFiles({ -- 2078
			workDir = req.workDir, -- 2079
			path = targetRel, -- 2080
			globs = __TS__ArrayMap( -- 2081
				codeExtensions, -- 2081
				function(____, e) return "**/*" .. e end -- 2081
			), -- 2081
			maxEntries = 10000 -- 2082
		}) -- 2082
		local relFiles = listResult.success and listResult.files or ({}) -- 2085
		local tsFileData = {} -- 2086
		local buildQueue = {} -- 2087
		for ____, rel in ipairs(relFiles) do -- 2088
			do -- 2088
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2089
				local kind = getSupportedBuildKind(file) -- 2090
				if not kind then -- 2090
					goto __continue422 -- 2091
				end -- 2091
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2092
				if kind ~= "ts" then -- 2092
					goto __continue422 -- 2094
				end -- 2094
				local content = Content:load(file) -- 2096
				if content == nil then -- 2096
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2098
					goto __continue422 -- 2099
				end -- 2099
				if isTiledEditorContent(content) then -- 2099
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2102
					goto __continue422 -- 2103
				end -- 2103
				tsFileData[file] = content -- 2105
			end -- 2105
			::__continue422:: -- 2105
		end -- 2105
		do -- 2105
			local i = 0 -- 2107
			while i < #buildQueue do -- 2107
				do -- 2107
					local ____buildQueue_index_32 = buildQueue[i + 1] -- 2108
					local file = ____buildQueue_index_32.file -- 2108
					local kind = ____buildQueue_index_32.kind -- 2108
					if kind == "ts" then -- 2108
						local content = tsFileData[file] -- 2110
						if content == nil or isDtsFile(file) then -- 2110
							goto __continue429 -- 2112
						end -- 2112
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2112
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2115
							goto __continue429 -- 2116
						end -- 2116
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 2118
						goto __continue429 -- 2119
					end -- 2119
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2121
				end -- 2121
				::__continue429:: -- 2121
				i = i + 1 -- 2107
			end -- 2107
		end -- 2107
		if #messages == 0 then -- 2107
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2124
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2124
		end -- 2124
		Log( -- 2127
			"Info", -- 2127
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2127
		) -- 2127
		return ____awaiter_resolve( -- 2127
			nil, -- 2127
			finalizeBuildResult(req.workDir, messages) -- 2128
		) -- 2128
	end) -- 2128
end -- 2042
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2131
local function truncateCommandOutput(output) -- 2133
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2133
		return output -- 2134
	end -- 2134
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2135
end -- 2133
local function executeLuaCommand(req) -- 2138
	local code = __TS__StringTrim(req.code or "") -- 2139
	if code == "" then -- 2139
		return __TS__Promise.resolve({ -- 2141
			success = false, -- 2141
			mode = "lua", -- 2141
			output = "", -- 2141
			message = "missing code", -- 2141
			phase = "validate" -- 2141
		}) -- 2141
	end -- 2141
	local output = {} -- 2143
	local env = setmetatable( -- 2144
		{ -- 2144
			projectDir = req.workDir, -- 2145
			print = function(...) -- 2146
				local values = {...} -- 2146
				local parts = {} -- 2147
				do -- 2147
					local i = 0 -- 2148
					while i < #values do -- 2148
						parts[#parts + 1] = tostring(values[i + 1]) -- 2149
						i = i + 1 -- 2148
					end -- 2148
				end -- 2148
				output[#output + 1] = table.concat(parts, "\t") -- 2151
			end, -- 2146
			refreshTree = function(path) -- 2153
				if path == nil then -- 2153
					return refreshProjectTree(req.workDir) -- 2155
				end -- 2155
				if type(path) ~= "string" then -- 2155
					error("refreshTree expects a project-relative file path string or no argument") -- 2158
				end -- 2158
				return refreshProjectTree(req.workDir, path) -- 2160
			end -- 2153
		}, -- 2153
		{__index = Dora} -- 2162
	) -- 2162
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 2165
	if not fn then -- 2165
		return __TS__Promise.resolve({ -- 2167
			success = false, -- 2168
			mode = "lua", -- 2169
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2170
			message = toStr(compileErr), -- 2171
			phase = "compile" -- 2172
		}) -- 2172
	end -- 2172
	return __TS__New( -- 2175
		__TS__Promise, -- 2175
		function(____, resolve) -- 2175
			Director.systemScheduler:schedule(once(function() -- 2176
				local ok, runtimeErr = pcall(fn) -- 2177
				if not ok then -- 2177
					resolve( -- 2179
						nil, -- 2179
						{ -- 2179
							success = false, -- 2180
							mode = "lua", -- 2181
							output = truncateCommandOutput(table.concat(output, "\n")), -- 2182
							message = toStr(runtimeErr), -- 2183
							phase = "execute" -- 2184
						} -- 2184
					) -- 2184
					return -- 2186
				end -- 2186
				resolve( -- 2188
					nil, -- 2188
					{ -- 2188
						success = true, -- 2188
						mode = "lua", -- 2188
						output = truncateCommandOutput(table.concat(output, "\n")) -- 2188
					} -- 2188
				) -- 2188
			end)) -- 2176
		end -- 2175
	) -- 2175
end -- 2138
local function formatGitStatusOutput(status) -- 2193
	if not status then -- 2193
		return "" -- 2194
	end -- 2194
	local lines = {} -- 2195
	local state = toStr(status.state) -- 2196
	local kind = toStr(status.kind) -- 2197
	local message = toStr(status.message) -- 2198
	local errorMessage = toStr(status.error) -- 2199
	if kind ~= "" or state ~= "" then -- 2199
		lines[#lines + 1] = table.concat( -- 2201
			__TS__ArrayFilter( -- 2201
				{kind, state}, -- 2201
				function(____, item) return item ~= "" end -- 2201
			), -- 2201
			": " -- 2201
		) -- 2201
	end -- 2201
	if message ~= "" then -- 2201
		lines[#lines + 1] = message -- 2203
	end -- 2203
	if errorMessage ~= "" then -- 2203
		lines[#lines + 1] = errorMessage -- 2204
	end -- 2204
	local data = status.data -- 2205
	if data ~= nil then -- 2205
		local dataText = encodeJSON(data) -- 2207
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 2208
	end -- 2208
	return truncateCommandOutput(table.concat(lines, "\n")) -- 2210
end -- 2193
local function emitGitProgress(mode, operationId, onProgress, status) -- 2213
	if not onProgress then -- 2213
		return -- 2219
	end -- 2219
	local progress = type(status.progress) == "number" and status.progress or nil -- 2220
	local kind = toStr(status.kind) -- 2221
	local message = toStr(status.message) -- 2222
	local state = toStr(status.state) -- 2223
	local jobId = type(status.id) == "number" and status.id or nil -- 2224
	onProgress({ -- 2225
		state = "running", -- 2226
		mode = mode, -- 2227
		operationId = operationId, -- 2228
		stage = kind ~= "" and kind or "git", -- 2229
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 2230
		progress = progress, -- 2231
		jobId = jobId, -- 2232
		gitState = state ~= "" and state or nil, -- 2233
		gitKind = kind ~= "" and kind or nil -- 2234
	}) -- 2234
end -- 2213
local function cloneGitToTarget(req) -- 2238
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2238
		local parsed = parseGitCloneCommand(req.command) -- 2246
		if parsed == nil then -- 2246
			return ____awaiter_resolve(nil, nil) -- 2246
		end -- 2246
		if not parsed.success then -- 2246
			return ____awaiter_resolve(nil, { -- 2246
				success = false, -- 2249
				mode = "git", -- 2249
				output = "", -- 2249
				message = parsed.message, -- 2249
				phase = "validate" -- 2249
			}) -- 2249
		end -- 2249
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 2251
		if not target then -- 2251
			return ____awaiter_resolve(nil, { -- 2251
				success = false, -- 2253
				mode = "git", -- 2253
				output = "", -- 2253
				message = "invalid clone target path", -- 2253
				phase = "validate" -- 2253
			}) -- 2253
		end -- 2253
		if Content:exist(target) then -- 2253
			return ____awaiter_resolve(nil, { -- 2253
				success = false, -- 2256
				mode = "git", -- 2256
				output = "", -- 2256
				message = "target already exists", -- 2256
				phase = "validate" -- 2256
			}) -- 2256
		end -- 2256
		local targetParent = Path:getPath(target) -- 2258
		if not ensureDirPath(targetParent) then -- 2258
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 2258
		end -- 2258
		local tempRoot = getAgentDownloadTempRoot() -- 2262
		if not ensureDirPath(tempRoot) then -- 2262
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 2262
		end -- 2262
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 2266
		Content:remove(tempPath) -- 2267
		local depth = parsed.depth or "1" -- 2268
		local ____array_33 = __TS__SparseArrayNew( -- 2268
			"clone", -- 2270
			quoteGitArg(parsed.url), -- 2271
			quoteGitArg(Path:getFilename(tempPath)), -- 2272
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 2273
				"-b", -- 2273
				quoteGitArg(parsed.ref) -- 2273
			}) or ({})) -- 2273
		) -- 2273
		__TS__SparseArrayPush( -- 2273
			____array_33, -- 2273
			table.unpack(depth ~= "" and ({ -- 2274
				"--depth",
				quoteGitArg(depth) -- 2274
			}) or ({})) -- 2274
		) -- 2274
		local command = table.concat( -- 2269
			{__TS__SparseArraySpread(____array_33)}, -- 2269
			" " -- 2275
		) -- 2275
		local ____this_35 -- 2275
		____this_35 = req -- 2276
		local ____opt_34 = ____this_35.onProgress -- 2276
		if ____opt_34 ~= nil then -- 2276
			____opt_34(____this_35, { -- 2276
				state = "pending", -- 2277
				mode = "git", -- 2278
				operationId = req.operationId, -- 2279
				stage = "clone", -- 2280
				message = "clone pending", -- 2281
				progress = 0 -- 2282
			}) -- 2282
		end -- 2282
		local gitRes = __TS__Await(runGitAndWait( -- 2284
			tempRoot, -- 2285
			command, -- 2286
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2287
			function() -- 2288
				local ____this_37 -- 2288
				____this_37 = req -- 2288
				local ____opt_36 = ____this_37.isCancelled -- 2288
				return (____opt_36 and ____opt_36(____this_37)) == true -- 2288
			end, -- 2288
			req.timeoutSeconds -- 2289
		)) -- 2289
		if not gitRes.success then -- 2289
			local cleanupError = cleanupPath(tempPath) -- 2292
			local ____formatGitStatusOutput_result_41 = formatGitStatusOutput(gitRes.status) -- 2296
			local ____temp_42 = gitRes.message or "git clone failed" -- 2297
			local ____gitRes_interrupted_40 = gitRes.interrupted -- 2298
			if not ____gitRes_interrupted_40 then -- 2298
				local ____this_39 -- 2298
				____this_39 = req -- 2298
				local ____opt_38 = ____this_39.isCancelled -- 2298
				____gitRes_interrupted_40 = (____opt_38 and ____opt_38(____this_39)) == true -- 2298
			end -- 2298
			return ____awaiter_resolve(nil, { -- 2298
				success = false, -- 2294
				mode = "git", -- 2295
				output = ____formatGitStatusOutput_result_41, -- 2296
				message = ____temp_42, -- 2297
				interrupted = ____gitRes_interrupted_40, -- 2298
				cleanupError = cleanupError -- 2299
			}) -- 2299
		end -- 2299
		if not Content:move(tempPath, target) then -- 2299
			local cleanupError = cleanupPath(tempPath) -- 2303
			return ____awaiter_resolve( -- 2303
				nil, -- 2303
				{ -- 2304
					success = false, -- 2304
					mode = "git", -- 2304
					output = formatGitStatusOutput(gitRes.status), -- 2304
					message = "failed to move cloned repository into target path", -- 2304
					cleanupError = cleanupError -- 2304
				} -- 2304
			) -- 2304
		end -- 2304
		if not refreshProjectTree(req.workDir) then -- 2304
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 2307
		end -- 2307
		local commit = getGitHeadCommit(target) -- 2309
		local output = table.concat( -- 2310
			__TS__ArrayFilter( -- 2310
				{ -- 2310
					formatGitStatusOutput(gitRes.status), -- 2311
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 2311
					commit ~= nil and "commit " .. commit or "" -- 2313
				}, -- 2313
				function(____, item) return item ~= "" end -- 2314
			), -- 2314
			"\n" -- 2314
		) -- 2314
		return ____awaiter_resolve( -- 2314
			nil, -- 2314
			{ -- 2315
				success = true, -- 2315
				mode = "git", -- 2315
				output = truncateCommandOutput(output) -- 2315
			} -- 2315
		) -- 2315
	end) -- 2315
end -- 2238
local function loadGitProfile() -- 2318
	local rows -- 2319
	do -- 2319
		local function ____catch() -- 2319
			return true, nil -- 2323
		end -- 2323
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2323
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 2321
		end) -- 2321
		if not ____try then -- 2321
			____hasReturned, ____returnValue = ____catch() -- 2321
		end -- 2321
		if ____hasReturned then -- 2321
			return ____returnValue -- 2320
		end -- 2320
	end -- 2320
	if not rows or not rows[1] then -- 2320
		return nil -- 2325
	end -- 2325
	local name = toStr(rows[1][1]) -- 2326
	local email = toStr(rows[1][2]) -- 2327
	if name == "" and email == "" then -- 2327
		return nil -- 2328
	end -- 2328
	return {name = name, email = email} -- 2329
end -- 2318
local function applyGitProfileToCommit(command) -- 2332
	local args = shellSplit(command) -- 2333
	if args[1] ~= "commit" then -- 2333
		return command -- 2334
	end -- 2334
	local hasName = false -- 2335
	local hasEmail = false -- 2336
	for ____, arg in ipairs(args) do -- 2337
		if arg == "--author-name" then
			hasName = true -- 2338
		end -- 2338
		if arg == "--author-email" then
			hasEmail = true -- 2339
		end -- 2339
	end -- 2339
	if hasName and hasEmail then -- 2339
		return command -- 2341
	end -- 2341
	local profile = loadGitProfile() -- 2342
	if not profile then -- 2342
		return command -- 2343
	end -- 2343
	local additions = {} -- 2344
	if not hasName and profile.name ~= "" then -- 2344
		__TS__ArrayPush( -- 2346
			additions, -- 2346
			"--author-name",
			quoteGitArg(profile.name) -- 2346
		) -- 2346
	end -- 2346
	if not hasEmail and profile.email ~= "" then -- 2346
		__TS__ArrayPush( -- 2349
			additions, -- 2349
			"--author-email",
			quoteGitArg(profile.email) -- 2349
		) -- 2349
	end -- 2349
	if #additions == 0 then -- 2349
		return command -- 2351
	end -- 2351
	return (command .. " ") .. table.concat(additions, " ") -- 2352
end -- 2332
local function executeGitCommand(req) -- 2355
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2355
		local command = normalizeGitCommand(req.command or "") -- 2364
		if command == "" then -- 2364
			return ____awaiter_resolve(nil, { -- 2364
				success = false, -- 2366
				mode = "git", -- 2366
				output = "", -- 2366
				message = "missing command", -- 2366
				phase = "validate" -- 2366
			}) -- 2366
		end -- 2366
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 2368
			workDir = req.workDir, -- 2369
			command = command, -- 2370
			operationId = req.operationId, -- 2371
			timeoutSeconds = req.timeoutSeconds, -- 2372
			onProgress = req.onProgress, -- 2373
			isCancelled = req.isCancelled -- 2374
		})) -- 2374
		if cloneResult ~= nil then -- 2374
			return ____awaiter_resolve(nil, cloneResult) -- 2374
		end -- 2374
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 2377
		if not cwd.success then -- 2377
			return ____awaiter_resolve(nil, { -- 2377
				success = false, -- 2379
				mode = "git", -- 2379
				output = "", -- 2379
				cwd = req.cwd, -- 2379
				message = cwd.message, -- 2379
				phase = "validate" -- 2379
			}) -- 2379
		end -- 2379
		command = applyGitProfileToCommit(command) -- 2381
		local ____this_44 -- 2381
		____this_44 = req -- 2382
		local ____opt_43 = ____this_44.onProgress -- 2382
		if ____opt_43 ~= nil then -- 2382
			____opt_43(____this_44, { -- 2382
				state = "pending", -- 2383
				mode = "git", -- 2384
				operationId = req.operationId, -- 2385
				stage = "git", -- 2386
				message = "git command pending", -- 2387
				progress = 0 -- 2388
			}) -- 2388
		end -- 2388
		local gitRes = __TS__Await(runGitAndWait( -- 2390
			cwd.path, -- 2391
			command, -- 2392
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2393
			function() -- 2394
				local ____this_46 -- 2394
				____this_46 = req -- 2394
				local ____opt_45 = ____this_46.isCancelled -- 2394
				return (____opt_45 and ____opt_45(____this_46)) == true -- 2394
			end, -- 2394
			req.timeoutSeconds -- 2395
		)) -- 2395
		local output = formatGitStatusOutput(gitRes.status) -- 2397
		if not gitRes.success then -- 2397
			local ____output_50 = output -- 2402
			local ____cwd_relative_51 = cwd.relative -- 2403
			local ____temp_52 = gitRes.message or "git command failed" -- 2404
			local ____gitRes_interrupted_49 = gitRes.interrupted -- 2405
			if not ____gitRes_interrupted_49 then -- 2405
				local ____this_48 -- 2405
				____this_48 = req -- 2405
				local ____opt_47 = ____this_48.isCancelled -- 2405
				____gitRes_interrupted_49 = (____opt_47 and ____opt_47(____this_48)) == true -- 2405
			end -- 2405
			return ____awaiter_resolve(nil, { -- 2405
				success = false, -- 2400
				mode = "git", -- 2401
				output = ____output_50, -- 2402
				cwd = ____cwd_relative_51, -- 2403
				message = ____temp_52, -- 2404
				interrupted = ____gitRes_interrupted_49 -- 2405
			}) -- 2405
		end -- 2405
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 2405
	end) -- 2405
end -- 2355
function ____exports.executeCommand(req) -- 2411
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2411
		local mode = req.mode -- 2421
		if mode ~= "lua" and mode ~= "git" then -- 2421
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 2421
		end -- 2421
		if mode == "lua" then -- 2421
			return ____awaiter_resolve( -- 2421
				nil, -- 2421
				executeLuaCommand({workDir = req.workDir, code = req.code or ""}) -- 2426
			) -- 2426
		end -- 2426
		local operationId = createOperationId() -- 2428
		return ____awaiter_resolve( -- 2428
			nil, -- 2428
			executeGitCommand({ -- 2429
				workDir = req.workDir, -- 2430
				command = req.command or "", -- 2431
				cwd = req.cwd, -- 2432
				timeoutSeconds = math.max( -- 2433
					1, -- 2433
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 2433
				), -- 2433
				operationId = operationId, -- 2434
				onProgress = req.onProgress, -- 2435
				isCancelled = req.isCancelled -- 2436
			}) -- 2436
		) -- 2436
	end) -- 2436
end -- 2411
function ____exports.fetchUrl(req) -- 2440
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2440
		local mode = "download" -- 2447
		local url = __TS__StringTrim(req.url or "") -- 2448
		local targetRel = __TS__StringTrim(req.target or "") -- 2449
		if not isHttpUrl(url) then -- 2449
			return ____awaiter_resolve(nil, { -- 2449
				success = false, -- 2451
				state = "failed", -- 2451
				mode = mode, -- 2451
				target = targetRel, -- 2451
				message = "fetch_url only supports http:// and https:// URLs" -- 2451
			}) -- 2451
		end -- 2451
		if targetRel == "" then -- 2451
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 2451
		end -- 2451
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 2456
		if not target then -- 2456
			return ____awaiter_resolve(nil, { -- 2456
				success = false, -- 2458
				state = "failed", -- 2458
				mode = mode, -- 2458
				target = targetRel, -- 2458
				message = "invalid target path" -- 2458
			}) -- 2458
		end -- 2458
		if Content:exist(target) then -- 2458
			return ____awaiter_resolve(nil, { -- 2458
				success = false, -- 2461
				state = "failed", -- 2461
				mode = mode, -- 2461
				target = targetRel, -- 2461
				message = "target already exists" -- 2461
			}) -- 2461
		end -- 2461
		local operationId = createOperationId() -- 2463
		local tempRoot = getAgentDownloadTempRoot() -- 2464
		if not ensureDirPath(tempRoot) then -- 2464
			return ____awaiter_resolve(nil, { -- 2464
				success = false, -- 2466
				state = "failed", -- 2466
				mode = mode, -- 2466
				target = targetRel, -- 2466
				message = "failed to create agent download temp directory" -- 2466
			}) -- 2466
		end -- 2466
		local tempPath = Path(tempRoot, operationId .. ".download") -- 2468
		Content:remove(tempPath) -- 2469
		local function emitProgress(progress) -- 2470
			if not req.onProgress then -- 2470
				return -- 2471
			end -- 2471
			req:onProgress(__TS__ObjectAssign({ -- 2472
				state = "running", -- 2473
				mode = mode, -- 2474
				operationId = operationId, -- 2475
				target = targetRel, -- 2476
				tempPath = tempPath -- 2477
			}, progress)) -- 2477
		end -- 2470
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 2481
		local function interrupted() -- 2486
			local ____this_54 -- 2486
			____this_54 = req -- 2486
			local ____opt_53 = ____this_54.isCancelled -- 2486
			return (____opt_53 and ____opt_53(____this_54)) == true -- 2486
		end -- 2486
		if not ensureDirForFile(tempPath) then -- 2486
			return ____awaiter_resolve(nil, { -- 2486
				success = false, -- 2488
				state = "failed", -- 2488
				mode = mode, -- 2488
				target = targetRel, -- 2488
				message = "failed to create temporary file directory" -- 2488
			}) -- 2488
		end -- 2488
		local downloadRes = __TS__Await(downloadFile({ -- 2490
			url = url, -- 2491
			tempPath = tempPath, -- 2492
			timeout = 600, -- 2493
			isCancelled = interrupted, -- 2494
			onProgress = function(____, current, total) -- 2495
				local totalNumber = type(total) == "number" and total or 0 -- 2496
				emitProgress({ -- 2497
					stage = "download", -- 2498
					message = "downloading", -- 2499
					current = current, -- 2500
					total = total, -- 2501
					progress = totalNumber > 0 and current / totalNumber or nil -- 2502
				}) -- 2502
			end -- 2495
		})) -- 2495
		if not downloadRes.success then -- 2495
			local cleanupError = cleanupPath(tempPath) -- 2507
			return ____awaiter_resolve( -- 2507
				nil, -- 2507
				{ -- 2508
					success = false, -- 2509
					state = "failed", -- 2510
					mode = mode, -- 2511
					target = targetRel, -- 2512
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 2513
					interrupted = downloadRes.interrupted or interrupted(), -- 2514
					cleanupError = cleanupError -- 2515
				} -- 2515
			) -- 2515
		end -- 2515
		if not ensureDirForFile(target) then -- 2515
			local cleanupError = cleanupPath(tempPath) -- 2519
			return ____awaiter_resolve(nil, { -- 2519
				success = false, -- 2520
				state = "failed", -- 2520
				mode = mode, -- 2520
				target = targetRel, -- 2520
				message = "failed to create target directory", -- 2520
				cleanupError = cleanupError -- 2520
			}) -- 2520
		end -- 2520
		if not Content:move(tempPath, target) then -- 2520
			local cleanupError = cleanupPath(tempPath) -- 2523
			return ____awaiter_resolve(nil, { -- 2523
				success = false, -- 2524
				state = "failed", -- 2524
				mode = mode, -- 2524
				target = targetRel, -- 2524
				message = "failed to move downloaded file into target path", -- 2524
				cleanupError = cleanupError -- 2524
			}) -- 2524
		end -- 2524
		local bytesWritten = downloadRes.bytesWritten -- 2526
		local ____try = __TS__AsyncAwaiter(function() -- 2526
			local size = Content:getAttr(target) -- 2528
			if bytesWritten == nil or bytesWritten <= 0 then -- 2528
				bytesWritten = type(size) == "number" and size or nil -- 2530
			end -- 2530
		end) -- 2530
		____try = ____try.catch( -- 2530
			____try, -- 2530
			function(____, _) -- 2530
				return __TS__AsyncAwaiter(function() -- 2530
				end) -- 2530
			end -- 2530
		) -- 2530
		__TS__Await(____try) -- 2527
		if bytesWritten == nil or bytesWritten <= 0 then -- 2527
			local ____try = __TS__AsyncAwaiter(function() -- 2527
				local loaded = Content:load(target) -- 2537
				if type(loaded) == "string" then -- 2537
					bytesWritten = #loaded -- 2539
				end -- 2539
			end) -- 2539
			____try = ____try.catch( -- 2539
				____try, -- 2539
				function(____, _) -- 2539
					return __TS__AsyncAwaiter(function() -- 2539
					end) -- 2539
				end -- 2539
			) -- 2539
			__TS__Await(____try) -- 2536
		end -- 2536
		if not syncDownloadedFileToWebIDE(target) then -- 2536
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 2546
		end -- 2546
		return ____awaiter_resolve(nil, { -- 2546
			success = true, -- 2548
			state = "done", -- 2548
			mode = mode, -- 2548
			target = targetRel, -- 2548
			bytesWritten = bytesWritten -- 2548
		}) -- 2548
	end) -- 2548
end -- 2440
return ____exports -- 2440