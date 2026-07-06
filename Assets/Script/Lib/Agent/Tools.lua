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
function ____exports.searchDoraAPIHttp(req, callback) -- 1836
	local ____self_32 = ____exports.searchDoraAPI(req) -- 1836
	____self_32["then"]( -- 1836
		____self_32, -- 1836
		function(____, result) return callback(result) end -- 1847
	) -- 1847
end -- 1836
function ____exports.readDoraDoc(req) -- 1850
	local docSource = req.docSource -- 1857
	local file = table.concat( -- 1858
		__TS__StringSplit(req.file or "", "\\"), -- 1858
		"/" -- 1858
	) -- 1858
	if not isValidWorkspacePath(file) or file == "." then -- 1858
		return {success = false, message = "invalid file"} -- 1860
	end -- 1860
	local root = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1862
	local fullPath = Path(root, file) -- 1863
	local relative = Path:getRelative(fullPath, root) -- 1864
	if relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 1864
		return {success = false, message = "invalid file"} -- 1866
	end -- 1866
	local ext = Path:getExt(fullPath) -- 1868
	if docSource == "api" then -- 1868
		if ext ~= "ts" and ext ~= "tl" then -- 1868
			return {success = false, message = "unsupported doc file type"} -- 1870
		end -- 1870
	elseif ext ~= "md" then -- 1870
		return {success = false, message = "unsupported doc file type"} -- 1872
	end -- 1872
	local readResult = ____exports.readFile(root, file, req.startLine or 1, req.endLine or -1) -- 1874
	if not readResult.success then -- 1874
		return readResult -- 1875
	end -- 1875
	return { -- 1876
		success = true, -- 1877
		docLanguage = req.docLanguage, -- 1878
		file = file, -- 1879
		content = readResult.content, -- 1880
		startLine = readResult.startLine, -- 1881
		endLine = readResult.endLine -- 1882
	} -- 1882
end -- 1850
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 1886
	if options == nil then -- 1886
		options = {} -- 1886
	end -- 1886
	if #changes == 0 then -- 1886
		return {success = false, message = "empty changes"} -- 1888
	end -- 1888
	if not isValidWorkDir(workDir) then -- 1888
		return {success = false, message = "invalid workDir"} -- 1891
	end -- 1891
	if not getTaskStatus(taskId) then -- 1891
		return {success = false, message = "task not found"} -- 1894
	end -- 1894
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 1896
	local dup = rejectDuplicatePaths(expandedChanges) -- 1897
	if dup then -- 1897
		return {success = false, message = "duplicate path in batch: " .. dup} -- 1899
	end -- 1899
	for ____, change in ipairs(expandedChanges) do -- 1902
		if not isValidWorkspacePath(change.path) then -- 1902
			return {success = false, message = "invalid path: " .. change.path} -- 1904
		end -- 1904
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 1904
			return {success = false, message = "missing content for " .. change.path} -- 1907
		end -- 1907
	end -- 1907
	local headSeq = getTaskHeadSeq(taskId) -- 1911
	if headSeq == nil then -- 1911
		return {success = false, message = "task not found"} -- 1912
	end -- 1912
	local nextSeq = headSeq + 1 -- 1913
	local checkpointId = insertCheckpoint( -- 1914
		taskId, -- 1914
		nextSeq, -- 1914
		options.summary or "", -- 1914
		options.toolName or "", -- 1914
		"PREPARED" -- 1914
	) -- 1914
	if checkpointId <= 0 then -- 1914
		return {success = false, message = "failed to create checkpoint"} -- 1916
	end -- 1916
	do -- 1916
		local i = 0 -- 1919
		while i < #expandedChanges do -- 1919
			local change = expandedChanges[i + 1] -- 1920
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 1921
			if not fullPath then -- 1921
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1923
				return {success = false, message = "invalid path: " .. change.path} -- 1924
			end -- 1924
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 1924
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1927
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 1928
			end -- 1928
			local before = getFileState(fullPath) -- 1930
			local afterExists = change.op ~= "delete" -- 1931
			local afterContent = afterExists and (change.content or "") or "" -- 1932
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1933
				checkpointId, -- 1937
				i + 1, -- 1938
				change.path, -- 1939
				change.op, -- 1940
				before.exists and 1 or 0, -- 1941
				before.content, -- 1942
				afterExists and 1 or 0, -- 1943
				afterContent, -- 1944
				before.bytes, -- 1945
				#afterContent -- 1946
			}) -- 1946
			if inserted <= 0 then -- 1946
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1950
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 1951
			end -- 1951
			i = i + 1 -- 1919
		end -- 1919
	end -- 1919
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 1955
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1956
		if not fullPath then -- 1956
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1958
			return {success = false, message = "invalid path: " .. entry.path} -- 1959
		end -- 1959
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 1961
		if not ok then -- 1961
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1963
			return {success = false, message = "failed to apply file change: " .. entry.path} -- 1964
		end -- 1964
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 1964
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 1967
			return {success = false, message = "failed to sync file change: " .. entry.path} -- 1968
		end -- 1968
	end -- 1968
	DB:exec( -- 1972
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 1972
		{ -- 1974
			"APPLIED", -- 1974
			now(), -- 1974
			checkpointId -- 1974
		} -- 1974
	) -- 1974
	DB:exec( -- 1976
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 1976
		{ -- 1978
			nextSeq, -- 1978
			now(), -- 1978
			taskId -- 1978
		} -- 1978
	) -- 1978
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 1980
end -- 1886
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 1988
	if not isValidWorkDir(workDir) then -- 1988
		return {success = false, message = "invalid workDir"} -- 1989
	end -- 1989
	if checkpointId <= 0 then -- 1989
		return {success = false, message = "invalid checkpointId"} -- 1990
	end -- 1990
	local entries = getCheckpointEntries(checkpointId, true) -- 1991
	if #entries == 0 then -- 1991
		return {success = false, message = "checkpoint not found or empty"} -- 1993
	end -- 1993
	for ____, entry in ipairs(entries) do -- 1995
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1996
		if not fullPath then -- 1996
			return {success = false, message = "invalid path: " .. entry.path} -- 1998
		end -- 1998
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 2000
		if not ok then -- 2000
			Log( -- 2002
				"Error", -- 2002
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2002
			) -- 2002
			Log( -- 2003
				"Info", -- 2003
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2003
			) -- 2003
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 2004
		end -- 2004
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 2004
			Log( -- 2007
				"Error", -- 2007
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2007
			) -- 2007
			Log( -- 2008
				"Info", -- 2008
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2008
			) -- 2008
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 2009
		end -- 2009
	end -- 2009
	DB:exec( -- 2012
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 2012
		{ -- 2012
			"REVERTED", -- 2012
			now(), -- 2012
			checkpointId -- 2012
		} -- 2012
	) -- 2012
	return {success = true, checkpointId = checkpointId} -- 2013
end -- 1988
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 2016
	if not isValidWorkDir(workDir) then -- 2016
		return {success = false, message = "invalid workDir"} -- 2017
	end -- 2017
	if not getTaskStatus(taskId) then -- 2017
		return {success = false, message = "task not found"} -- 2018
	end -- 2018
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 2019
	if #checkpoints == 0 then -- 2019
		return {success = false, message = "change set not found or empty"} -- 2021
	end -- 2021
	local lastCheckpointId = 0 -- 2023
	do -- 2023
		local i = 0 -- 2024
		while i < #checkpoints do -- 2024
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 2025
			if not result.success then -- 2025
				return {success = false, message = result.message} -- 2026
			end -- 2026
			lastCheckpointId = checkpoints[i + 1].id -- 2027
			i = i + 1 -- 2024
		end -- 2024
	end -- 2024
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 2029
end -- 2016
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 2037
	return getCheckpointEntries(checkpointId, false) -- 2038
end -- 2037
function ____exports.getCheckpointDiff(checkpointId) -- 2041
	if checkpointId <= 0 then -- 2041
		return {success = false, message = "invalid checkpointId"} -- 2043
	end -- 2043
	local entries = getCheckpointEntries(checkpointId, false) -- 2045
	if #entries == 0 then -- 2045
		return {success = false, message = "checkpoint not found or empty"} -- 2047
	end -- 2047
	return { -- 2049
		success = true, -- 2050
		files = __TS__ArrayMap( -- 2051
			entries, -- 2051
			function(____, entry) return { -- 2051
				path = entry.path, -- 2052
				op = entry.op, -- 2053
				beforeExists = entry.beforeExists, -- 2054
				afterExists = entry.afterExists, -- 2055
				beforeContent = entry.beforeContent, -- 2056
				afterContent = entry.afterContent -- 2057
			} end -- 2057
		) -- 2057
	} -- 2057
end -- 2041
local function finalizeBuildResult(workDir, messages) -- 2062
	local normalized = __TS__ArrayMap( -- 2063
		messages, -- 2063
		function(____, m) return m.success and __TS__ObjectAssign( -- 2063
			{}, -- 2064
			m, -- 2064
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2064
		) or __TS__ObjectAssign( -- 2064
			{}, -- 2065
			m, -- 2065
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2065
		) end -- 2065
	) -- 2065
	local total = #normalized -- 2066
	local failed = 0 -- 2067
	do -- 2067
		local i = 0 -- 2068
		while i < #normalized do -- 2068
			if not normalized[i + 1].success then -- 2068
				failed = failed + 1 -- 2069
			end -- 2069
			i = i + 1 -- 2068
		end -- 2068
	end -- 2068
	local passed = total - failed -- 2071
	if failed > 0 then -- 2071
		return { -- 2073
			success = false, -- 2074
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 2075
			total = total, -- 2076
			passed = passed, -- 2077
			failed = failed, -- 2078
			messages = normalized -- 2079
		} -- 2079
	end -- 2079
	return { -- 2082
		success = true, -- 2083
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 2084
		total = total, -- 2085
		passed = passed, -- 2086
		failed = 0, -- 2087
		messages = normalized -- 2088
	} -- 2088
end -- 2062
function ____exports.build(req) -- 2092
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2092
		local targetRel = req.path or "" -- 2093
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2094
		if not target then -- 2094
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2094
		end -- 2094
		if not Content:exist(target) then -- 2094
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2094
		end -- 2094
		local messages = {} -- 2101
		if not Content:isdir(target) then -- 2101
			local kind = getSupportedBuildKind(target) -- 2103
			if not kind then -- 2103
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2103
			end -- 2103
			if kind == "ts" then -- 2103
				local content = Content:load(target) -- 2108
				if content == nil then -- 2108
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2108
				end -- 2108
				if isTiledEditorContent(content) then -- 2108
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2113
					return ____awaiter_resolve( -- 2113
						nil, -- 2113
						finalizeBuildResult(req.workDir, messages) -- 2114
					) -- 2114
				end -- 2114
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2114
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2114
				end -- 2114
				if not isDtsFile(target) then -- 2114
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content)) -- 2120
				end -- 2120
			else -- 2120
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2123
			end -- 2123
			Log( -- 2125
				"Info", -- 2125
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2125
			) -- 2125
			return ____awaiter_resolve( -- 2125
				nil, -- 2125
				finalizeBuildResult(req.workDir, messages) -- 2126
			) -- 2126
		end -- 2126
		local listResult = ____exports.listFiles({ -- 2128
			workDir = req.workDir, -- 2129
			path = targetRel, -- 2130
			globs = __TS__ArrayMap( -- 2131
				codeExtensions, -- 2131
				function(____, e) return "**/*" .. e end -- 2131
			), -- 2131
			maxEntries = 10000 -- 2132
		}) -- 2132
		local relFiles = listResult.success and listResult.files or ({}) -- 2135
		local tsFileData = {} -- 2136
		local buildQueue = {} -- 2137
		for ____, rel in ipairs(relFiles) do -- 2138
			do -- 2138
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2139
				local kind = getSupportedBuildKind(file) -- 2140
				if not kind then -- 2140
					goto __continue431 -- 2141
				end -- 2141
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2142
				if kind ~= "ts" then -- 2142
					goto __continue431 -- 2144
				end -- 2144
				local content = Content:load(file) -- 2146
				if content == nil then -- 2146
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2148
					goto __continue431 -- 2149
				end -- 2149
				if isTiledEditorContent(content) then -- 2149
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2152
					goto __continue431 -- 2153
				end -- 2153
				tsFileData[file] = content -- 2155
			end -- 2155
			::__continue431:: -- 2155
		end -- 2155
		do -- 2155
			local i = 0 -- 2157
			while i < #buildQueue do -- 2157
				do -- 2157
					local ____buildQueue_index_33 = buildQueue[i + 1] -- 2158
					local file = ____buildQueue_index_33.file -- 2158
					local kind = ____buildQueue_index_33.kind -- 2158
					if kind == "ts" then -- 2158
						local content = tsFileData[file] -- 2160
						if content == nil or isDtsFile(file) then -- 2160
							goto __continue438 -- 2162
						end -- 2162
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2162
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2165
							goto __continue438 -- 2166
						end -- 2166
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content)) -- 2168
						goto __continue438 -- 2169
					end -- 2169
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2171
				end -- 2171
				::__continue438:: -- 2171
				i = i + 1 -- 2157
			end -- 2157
		end -- 2157
		if #messages == 0 then -- 2157
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2174
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2174
		end -- 2174
		Log( -- 2177
			"Info", -- 2177
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2177
		) -- 2177
		return ____awaiter_resolve( -- 2177
			nil, -- 2177
			finalizeBuildResult(req.workDir, messages) -- 2178
		) -- 2178
	end) -- 2178
end -- 2092
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2181
local function truncateCommandOutput(output) -- 2183
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2183
		return output -- 2184
	end -- 2184
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2185
end -- 2183
local function executeLuaCommand(req) -- 2188
	local code = __TS__StringTrim(req.code or "") -- 2189
	if code == "" then -- 2189
		return __TS__Promise.resolve({ -- 2191
			success = false, -- 2191
			mode = "lua", -- 2191
			output = "", -- 2191
			message = "missing code", -- 2191
			phase = "validate" -- 2191
		}) -- 2191
	end -- 2191
	local output = {} -- 2193
	local env = setmetatable( -- 2194
		{ -- 2194
			projectDir = req.workDir, -- 2195
			print = function(...) -- 2196
				local values = {...} -- 2196
				local parts = {} -- 2197
				do -- 2197
					local i = 0 -- 2198
					while i < #values do -- 2198
						parts[#parts + 1] = tostring(values[i + 1]) -- 2199
						i = i + 1 -- 2198
					end -- 2198
				end -- 2198
				output[#output + 1] = table.concat(parts, "\t") -- 2201
			end, -- 2196
			refreshTree = function(path) -- 2203
				if path == nil then -- 2203
					return refreshProjectTree(req.workDir) -- 2205
				end -- 2205
				if type(path) ~= "string" then -- 2205
					error("refreshTree expects a project-relative file path string or no argument") -- 2208
				end -- 2208
				return refreshProjectTree(req.workDir, path) -- 2210
			end -- 2203
		}, -- 2203
		{__index = Dora} -- 2212
	) -- 2212
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 2215
	if not fn then -- 2215
		return __TS__Promise.resolve({ -- 2217
			success = false, -- 2218
			mode = "lua", -- 2219
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2220
			message = toStr(compileErr), -- 2221
			phase = "compile" -- 2222
		}) -- 2222
	end -- 2222
	return __TS__New( -- 2225
		__TS__Promise, -- 2225
		function(____, resolve) -- 2225
			Director.systemScheduler:schedule(once(function() -- 2226
				local ok, runtimeErr = pcall(fn) -- 2227
				if not ok then -- 2227
					resolve( -- 2229
						nil, -- 2229
						{ -- 2229
							success = false, -- 2230
							mode = "lua", -- 2231
							output = truncateCommandOutput(table.concat(output, "\n")), -- 2232
							message = toStr(runtimeErr), -- 2233
							phase = "execute" -- 2234
						} -- 2234
					) -- 2234
					return -- 2236
				end -- 2236
				resolve( -- 2238
					nil, -- 2238
					{ -- 2238
						success = true, -- 2238
						mode = "lua", -- 2238
						output = truncateCommandOutput(table.concat(output, "\n")) -- 2238
					} -- 2238
				) -- 2238
			end)) -- 2226
		end -- 2225
	) -- 2225
end -- 2188
local function formatGitStatusOutput(status) -- 2243
	if not status then -- 2243
		return "" -- 2244
	end -- 2244
	local lines = {} -- 2245
	local state = toStr(status.state) -- 2246
	local kind = toStr(status.kind) -- 2247
	local message = toStr(status.message) -- 2248
	local errorMessage = toStr(status.error) -- 2249
	if kind ~= "" or state ~= "" then -- 2249
		lines[#lines + 1] = table.concat( -- 2251
			__TS__ArrayFilter( -- 2251
				{kind, state}, -- 2251
				function(____, item) return item ~= "" end -- 2251
			), -- 2251
			": " -- 2251
		) -- 2251
	end -- 2251
	if message ~= "" then -- 2251
		lines[#lines + 1] = message -- 2253
	end -- 2253
	if errorMessage ~= "" then -- 2253
		lines[#lines + 1] = errorMessage -- 2254
	end -- 2254
	local data = status.data -- 2255
	if data ~= nil then -- 2255
		local dataText = encodeJSON(data) -- 2257
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 2258
	end -- 2258
	return truncateCommandOutput(table.concat(lines, "\n")) -- 2260
end -- 2243
local function emitGitProgress(mode, operationId, onProgress, status) -- 2263
	if not onProgress then -- 2263
		return -- 2269
	end -- 2269
	local progress = type(status.progress) == "number" and status.progress or nil -- 2270
	local kind = toStr(status.kind) -- 2271
	local message = toStr(status.message) -- 2272
	local state = toStr(status.state) -- 2273
	local jobId = type(status.id) == "number" and status.id or nil -- 2274
	onProgress({ -- 2275
		state = "running", -- 2276
		mode = mode, -- 2277
		operationId = operationId, -- 2278
		stage = kind ~= "" and kind or "git", -- 2279
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 2280
		progress = progress, -- 2281
		jobId = jobId, -- 2282
		gitState = state ~= "" and state or nil, -- 2283
		gitKind = kind ~= "" and kind or nil -- 2284
	}) -- 2284
end -- 2263
local function cloneGitToTarget(req) -- 2288
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2288
		local parsed = parseGitCloneCommand(req.command) -- 2296
		if parsed == nil then -- 2296
			return ____awaiter_resolve(nil, nil) -- 2296
		end -- 2296
		if not parsed.success then -- 2296
			return ____awaiter_resolve(nil, { -- 2296
				success = false, -- 2299
				mode = "git", -- 2299
				output = "", -- 2299
				message = parsed.message, -- 2299
				phase = "validate" -- 2299
			}) -- 2299
		end -- 2299
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 2301
		if not target then -- 2301
			return ____awaiter_resolve(nil, { -- 2301
				success = false, -- 2303
				mode = "git", -- 2303
				output = "", -- 2303
				message = "invalid clone target path", -- 2303
				phase = "validate" -- 2303
			}) -- 2303
		end -- 2303
		if Content:exist(target) then -- 2303
			return ____awaiter_resolve(nil, { -- 2303
				success = false, -- 2306
				mode = "git", -- 2306
				output = "", -- 2306
				message = "target already exists", -- 2306
				phase = "validate" -- 2306
			}) -- 2306
		end -- 2306
		local targetParent = Path:getPath(target) -- 2308
		if not ensureDirPath(targetParent) then -- 2308
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 2308
		end -- 2308
		local tempRoot = getAgentDownloadTempRoot() -- 2312
		if not ensureDirPath(tempRoot) then -- 2312
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 2312
		end -- 2312
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 2316
		Content:remove(tempPath) -- 2317
		local depth = parsed.depth or "1" -- 2318
		local ____array_34 = __TS__SparseArrayNew( -- 2318
			"clone", -- 2320
			quoteGitArg(parsed.url), -- 2321
			quoteGitArg(Path:getFilename(tempPath)), -- 2322
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 2323
				"-b", -- 2323
				quoteGitArg(parsed.ref) -- 2323
			}) or ({})) -- 2323
		) -- 2323
		__TS__SparseArrayPush( -- 2323
			____array_34, -- 2323
			table.unpack(depth ~= "" and ({ -- 2324
				"--depth",
				quoteGitArg(depth) -- 2324
			}) or ({})) -- 2324
		) -- 2324
		local command = table.concat( -- 2319
			{__TS__SparseArraySpread(____array_34)}, -- 2319
			" " -- 2325
		) -- 2325
		local ____this_36 -- 2325
		____this_36 = req -- 2326
		local ____opt_35 = ____this_36.onProgress -- 2326
		if ____opt_35 ~= nil then -- 2326
			____opt_35(____this_36, { -- 2326
				state = "pending", -- 2327
				mode = "git", -- 2328
				operationId = req.operationId, -- 2329
				stage = "clone", -- 2330
				message = "clone pending", -- 2331
				progress = 0 -- 2332
			}) -- 2332
		end -- 2332
		local gitRes = __TS__Await(runGitAndWait( -- 2334
			tempRoot, -- 2335
			command, -- 2336
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2337
			function() -- 2338
				local ____this_38 -- 2338
				____this_38 = req -- 2338
				local ____opt_37 = ____this_38.isCancelled -- 2338
				return (____opt_37 and ____opt_37(____this_38)) == true -- 2338
			end, -- 2338
			req.timeoutSeconds -- 2339
		)) -- 2339
		if not gitRes.success then -- 2339
			local cleanupError = cleanupPath(tempPath) -- 2342
			local ____formatGitStatusOutput_result_42 = formatGitStatusOutput(gitRes.status) -- 2346
			local ____temp_43 = gitRes.message or "git clone failed" -- 2347
			local ____gitRes_interrupted_41 = gitRes.interrupted -- 2348
			if not ____gitRes_interrupted_41 then -- 2348
				local ____this_40 -- 2348
				____this_40 = req -- 2348
				local ____opt_39 = ____this_40.isCancelled -- 2348
				____gitRes_interrupted_41 = (____opt_39 and ____opt_39(____this_40)) == true -- 2348
			end -- 2348
			return ____awaiter_resolve(nil, { -- 2348
				success = false, -- 2344
				mode = "git", -- 2345
				output = ____formatGitStatusOutput_result_42, -- 2346
				message = ____temp_43, -- 2347
				interrupted = ____gitRes_interrupted_41, -- 2348
				cleanupError = cleanupError -- 2349
			}) -- 2349
		end -- 2349
		if not Content:move(tempPath, target) then -- 2349
			local cleanupError = cleanupPath(tempPath) -- 2353
			return ____awaiter_resolve( -- 2353
				nil, -- 2353
				{ -- 2354
					success = false, -- 2354
					mode = "git", -- 2354
					output = formatGitStatusOutput(gitRes.status), -- 2354
					message = "failed to move cloned repository into target path", -- 2354
					cleanupError = cleanupError -- 2354
				} -- 2354
			) -- 2354
		end -- 2354
		if not refreshProjectTree(req.workDir) then -- 2354
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 2357
		end -- 2357
		local commit = getGitHeadCommit(target) -- 2359
		local output = table.concat( -- 2360
			__TS__ArrayFilter( -- 2360
				{ -- 2360
					formatGitStatusOutput(gitRes.status), -- 2361
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 2361
					commit ~= nil and "commit " .. commit or "" -- 2363
				}, -- 2363
				function(____, item) return item ~= "" end -- 2364
			), -- 2364
			"\n" -- 2364
		) -- 2364
		return ____awaiter_resolve( -- 2364
			nil, -- 2364
			{ -- 2365
				success = true, -- 2365
				mode = "git", -- 2365
				output = truncateCommandOutput(output) -- 2365
			} -- 2365
		) -- 2365
	end) -- 2365
end -- 2288
local function loadGitProfile() -- 2368
	local rows -- 2369
	do -- 2369
		local function ____catch() -- 2369
			return true, nil -- 2373
		end -- 2373
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2373
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 2371
		end) -- 2371
		if not ____try then -- 2371
			____hasReturned, ____returnValue = ____catch() -- 2371
		end -- 2371
		if ____hasReturned then -- 2371
			return ____returnValue -- 2370
		end -- 2370
	end -- 2370
	if not rows or not rows[1] then -- 2370
		return nil -- 2375
	end -- 2375
	local name = toStr(rows[1][1]) -- 2376
	local email = toStr(rows[1][2]) -- 2377
	if name == "" and email == "" then -- 2377
		return nil -- 2378
	end -- 2378
	return {name = name, email = email} -- 2379
end -- 2368
local function applyGitProfileToCommit(command) -- 2382
	local args = shellSplit(command) -- 2383
	if args[1] ~= "commit" then -- 2383
		return command -- 2384
	end -- 2384
	local hasName = false -- 2385
	local hasEmail = false -- 2386
	for ____, arg in ipairs(args) do -- 2387
		if arg == "--author-name" then
			hasName = true -- 2388
		end -- 2388
		if arg == "--author-email" then
			hasEmail = true -- 2389
		end -- 2389
	end -- 2389
	if hasName and hasEmail then -- 2389
		return command -- 2391
	end -- 2391
	local profile = loadGitProfile() -- 2392
	if not profile then -- 2392
		return command -- 2393
	end -- 2393
	local additions = {} -- 2394
	if not hasName and profile.name ~= "" then -- 2394
		__TS__ArrayPush( -- 2396
			additions, -- 2396
			"--author-name",
			quoteGitArg(profile.name) -- 2396
		) -- 2396
	end -- 2396
	if not hasEmail and profile.email ~= "" then -- 2396
		__TS__ArrayPush( -- 2399
			additions, -- 2399
			"--author-email",
			quoteGitArg(profile.email) -- 2399
		) -- 2399
	end -- 2399
	if #additions == 0 then -- 2399
		return command -- 2401
	end -- 2401
	return (command .. " ") .. table.concat(additions, " ") -- 2402
end -- 2382
local function executeGitCommand(req) -- 2405
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2405
		local command = normalizeGitCommand(req.command or "") -- 2414
		if command == "" then -- 2414
			return ____awaiter_resolve(nil, { -- 2414
				success = false, -- 2416
				mode = "git", -- 2416
				output = "", -- 2416
				message = "missing command", -- 2416
				phase = "validate" -- 2416
			}) -- 2416
		end -- 2416
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 2418
			workDir = req.workDir, -- 2419
			command = command, -- 2420
			operationId = req.operationId, -- 2421
			timeoutSeconds = req.timeoutSeconds, -- 2422
			onProgress = req.onProgress, -- 2423
			isCancelled = req.isCancelled -- 2424
		})) -- 2424
		if cloneResult ~= nil then -- 2424
			return ____awaiter_resolve(nil, cloneResult) -- 2424
		end -- 2424
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 2427
		if not cwd.success then -- 2427
			return ____awaiter_resolve(nil, { -- 2427
				success = false, -- 2429
				mode = "git", -- 2429
				output = "", -- 2429
				cwd = req.cwd, -- 2429
				message = cwd.message, -- 2429
				phase = "validate" -- 2429
			}) -- 2429
		end -- 2429
		command = applyGitProfileToCommit(command) -- 2431
		local ____this_45 -- 2431
		____this_45 = req -- 2432
		local ____opt_44 = ____this_45.onProgress -- 2432
		if ____opt_44 ~= nil then -- 2432
			____opt_44(____this_45, { -- 2432
				state = "pending", -- 2433
				mode = "git", -- 2434
				operationId = req.operationId, -- 2435
				stage = "git", -- 2436
				message = "git command pending", -- 2437
				progress = 0 -- 2438
			}) -- 2438
		end -- 2438
		local gitRes = __TS__Await(runGitAndWait( -- 2440
			cwd.path, -- 2441
			command, -- 2442
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2443
			function() -- 2444
				local ____this_47 -- 2444
				____this_47 = req -- 2444
				local ____opt_46 = ____this_47.isCancelled -- 2444
				return (____opt_46 and ____opt_46(____this_47)) == true -- 2444
			end, -- 2444
			req.timeoutSeconds -- 2445
		)) -- 2445
		local output = formatGitStatusOutput(gitRes.status) -- 2447
		if not gitRes.success then -- 2447
			local ____output_51 = output -- 2452
			local ____cwd_relative_52 = cwd.relative -- 2453
			local ____temp_53 = gitRes.message or "git command failed" -- 2454
			local ____gitRes_interrupted_50 = gitRes.interrupted -- 2455
			if not ____gitRes_interrupted_50 then -- 2455
				local ____this_49 -- 2455
				____this_49 = req -- 2455
				local ____opt_48 = ____this_49.isCancelled -- 2455
				____gitRes_interrupted_50 = (____opt_48 and ____opt_48(____this_49)) == true -- 2455
			end -- 2455
			return ____awaiter_resolve(nil, { -- 2455
				success = false, -- 2450
				mode = "git", -- 2451
				output = ____output_51, -- 2452
				cwd = ____cwd_relative_52, -- 2453
				message = ____temp_53, -- 2454
				interrupted = ____gitRes_interrupted_50 -- 2455
			}) -- 2455
		end -- 2455
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 2455
	end) -- 2455
end -- 2405
function ____exports.executeCommand(req) -- 2461
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2461
		local mode = req.mode -- 2471
		if mode ~= "lua" and mode ~= "git" then -- 2471
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 2471
		end -- 2471
		if mode == "lua" then -- 2471
			return ____awaiter_resolve( -- 2471
				nil, -- 2471
				executeLuaCommand({workDir = req.workDir, code = req.code or ""}) -- 2476
			) -- 2476
		end -- 2476
		local operationId = createOperationId() -- 2478
		return ____awaiter_resolve( -- 2478
			nil, -- 2478
			executeGitCommand({ -- 2479
				workDir = req.workDir, -- 2480
				command = req.command or "", -- 2481
				cwd = req.cwd, -- 2482
				timeoutSeconds = math.max( -- 2483
					1, -- 2483
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 2483
				), -- 2483
				operationId = operationId, -- 2484
				onProgress = req.onProgress, -- 2485
				isCancelled = req.isCancelled -- 2486
			}) -- 2486
		) -- 2486
	end) -- 2486
end -- 2461
function ____exports.fetchUrl(req) -- 2490
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2490
		local mode = "download" -- 2497
		local url = __TS__StringTrim(req.url or "") -- 2498
		local targetRel = __TS__StringTrim(req.target or "") -- 2499
		if not isHttpUrl(url) then -- 2499
			return ____awaiter_resolve(nil, { -- 2499
				success = false, -- 2501
				state = "failed", -- 2501
				mode = mode, -- 2501
				target = targetRel, -- 2501
				message = "fetch_url only supports http:// and https:// URLs" -- 2501
			}) -- 2501
		end -- 2501
		if targetRel == "" then -- 2501
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 2501
		end -- 2501
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 2506
		if not target then -- 2506
			return ____awaiter_resolve(nil, { -- 2506
				success = false, -- 2508
				state = "failed", -- 2508
				mode = mode, -- 2508
				target = targetRel, -- 2508
				message = "invalid target path" -- 2508
			}) -- 2508
		end -- 2508
		if Content:exist(target) then -- 2508
			return ____awaiter_resolve(nil, { -- 2508
				success = false, -- 2511
				state = "failed", -- 2511
				mode = mode, -- 2511
				target = targetRel, -- 2511
				message = "target already exists" -- 2511
			}) -- 2511
		end -- 2511
		local operationId = createOperationId() -- 2513
		local tempRoot = getAgentDownloadTempRoot() -- 2514
		if not ensureDirPath(tempRoot) then -- 2514
			return ____awaiter_resolve(nil, { -- 2514
				success = false, -- 2516
				state = "failed", -- 2516
				mode = mode, -- 2516
				target = targetRel, -- 2516
				message = "failed to create agent download temp directory" -- 2516
			}) -- 2516
		end -- 2516
		local tempPath = Path(tempRoot, operationId .. ".download") -- 2518
		Content:remove(tempPath) -- 2519
		local function emitProgress(progress) -- 2520
			if not req.onProgress then -- 2520
				return -- 2521
			end -- 2521
			req:onProgress(__TS__ObjectAssign({ -- 2522
				state = "running", -- 2523
				mode = mode, -- 2524
				operationId = operationId, -- 2525
				target = targetRel, -- 2526
				tempPath = tempPath -- 2527
			}, progress)) -- 2527
		end -- 2520
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 2531
		local function interrupted() -- 2536
			local ____this_55 -- 2536
			____this_55 = req -- 2536
			local ____opt_54 = ____this_55.isCancelled -- 2536
			return (____opt_54 and ____opt_54(____this_55)) == true -- 2536
		end -- 2536
		if not ensureDirForFile(tempPath) then -- 2536
			return ____awaiter_resolve(nil, { -- 2536
				success = false, -- 2538
				state = "failed", -- 2538
				mode = mode, -- 2538
				target = targetRel, -- 2538
				message = "failed to create temporary file directory" -- 2538
			}) -- 2538
		end -- 2538
		local downloadRes = __TS__Await(downloadFile({ -- 2540
			url = url, -- 2541
			tempPath = tempPath, -- 2542
			timeout = 600, -- 2543
			isCancelled = interrupted, -- 2544
			onProgress = function(____, current, total) -- 2545
				local totalNumber = type(total) == "number" and total or 0 -- 2546
				emitProgress({ -- 2547
					stage = "download", -- 2548
					message = "downloading", -- 2549
					current = current, -- 2550
					total = total, -- 2551
					progress = totalNumber > 0 and current / totalNumber or nil -- 2552
				}) -- 2552
			end -- 2545
		})) -- 2545
		if not downloadRes.success then -- 2545
			local cleanupError = cleanupPath(tempPath) -- 2557
			return ____awaiter_resolve( -- 2557
				nil, -- 2557
				{ -- 2558
					success = false, -- 2559
					state = "failed", -- 2560
					mode = mode, -- 2561
					target = targetRel, -- 2562
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 2563
					interrupted = downloadRes.interrupted or interrupted(), -- 2564
					cleanupError = cleanupError -- 2565
				} -- 2565
			) -- 2565
		end -- 2565
		if not ensureDirForFile(target) then -- 2565
			local cleanupError = cleanupPath(tempPath) -- 2569
			return ____awaiter_resolve(nil, { -- 2569
				success = false, -- 2570
				state = "failed", -- 2570
				mode = mode, -- 2570
				target = targetRel, -- 2570
				message = "failed to create target directory", -- 2570
				cleanupError = cleanupError -- 2570
			}) -- 2570
		end -- 2570
		if not Content:move(tempPath, target) then -- 2570
			local cleanupError = cleanupPath(tempPath) -- 2573
			return ____awaiter_resolve(nil, { -- 2573
				success = false, -- 2574
				state = "failed", -- 2574
				mode = mode, -- 2574
				target = targetRel, -- 2574
				message = "failed to move downloaded file into target path", -- 2574
				cleanupError = cleanupError -- 2574
			}) -- 2574
		end -- 2574
		local bytesWritten = downloadRes.bytesWritten -- 2576
		local ____try = __TS__AsyncAwaiter(function() -- 2576
			local size = Content:getAttr(target) -- 2578
			if bytesWritten == nil or bytesWritten <= 0 then -- 2578
				bytesWritten = type(size) == "number" and size or nil -- 2580
			end -- 2580
		end) -- 2580
		____try = ____try.catch( -- 2580
			____try, -- 2580
			function(____, _) -- 2580
				return __TS__AsyncAwaiter(function() -- 2580
				end) -- 2580
			end -- 2580
		) -- 2580
		__TS__Await(____try) -- 2577
		if bytesWritten == nil or bytesWritten <= 0 then -- 2577
			local ____try = __TS__AsyncAwaiter(function() -- 2577
				local loaded = Content:load(target) -- 2587
				if type(loaded) == "string" then -- 2587
					bytesWritten = #loaded -- 2589
				end -- 2589
			end) -- 2589
			____try = ____try.catch( -- 2589
				____try, -- 2589
				function(____, _) -- 2589
					return __TS__AsyncAwaiter(function() -- 2589
					end) -- 2589
				end -- 2589
			) -- 2589
			__TS__Await(____try) -- 2586
		end -- 2586
		if not syncDownloadedFileToWebIDE(target) then -- 2586
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 2596
		end -- 2596
		return ____awaiter_resolve(nil, { -- 2596
			success = true, -- 2598
			state = "done", -- 2598
			mode = mode, -- 2598
			target = targetRel, -- 2598
			bytesWritten = bytesWritten -- 2598
		}) -- 2598
	end) -- 2598
end -- 2490
return ____exports -- 2490