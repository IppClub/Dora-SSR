-- [ts]: Tools.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
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
local normalizeEscapedGitQuotes, encodeJSON, getEngineLogText, ensureSafeSearchGlobs, ENGINE_LOG_DOWNLOAD_DIR, ENGINE_LOG_FILE, extensionLevels -- 1
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
local AgentConfig = require("Agent.AgentConfig") -- 4
local ____Utils = require("Agent.Utils") -- 5
local Log = ____Utils.Log -- 5
local safeJsonDecode = ____Utils.safeJsonDecode -- 5
local safeJsonEncode = ____Utils.safeJsonEncode -- 5
function normalizeEscapedGitQuotes(command) -- 681
	local result = "" -- 682
	do -- 682
		local i = 0 -- 683
		while i < #command do -- 683
			do -- 683
				local ch = __TS__StringCharAt(command, i) -- 684
				local next = __TS__StringCharAt(command, i + 1) -- 685
				if ch == "\\" and (next == "\"" or next == "'") then -- 685
					result = result .. next -- 687
					i = i + 1 -- 688
					goto __continue112 -- 689
				end -- 689
				result = result .. ch -- 691
			end -- 691
			::__continue112:: -- 691
			i = i + 1 -- 683
		end -- 683
	end -- 683
	return result -- 693
end -- 693
function encodeJSON(obj) -- 1215
	local text = safeJsonEncode(obj) -- 1216
	return text -- 1217
end -- 1217
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 1220
	if HttpServer.wsConnectionCount == 0 then -- 1220
		return true -- 1222
	end -- 1222
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 1224
	if not payload then -- 1224
		return false -- 1226
	end -- 1226
	emit("AppWS", "Send", payload) -- 1228
	return true -- 1229
end -- 1220
function getEngineLogText() -- 1558
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 1559
	if not Content:exist(folder) then -- 1559
		Content:mkdir(folder) -- 1561
	end -- 1561
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 1563
	if not App:saveLog(logPath) then -- 1563
		return nil -- 1565
	end -- 1565
	return Content:load(logPath) -- 1567
end -- 1567
function ensureSafeSearchGlobs(globs) -- 1707
	local result = {} -- 1708
	do -- 1708
		local i = 0 -- 1709
		while i < #globs do -- 1709
			result[#result + 1] = globs[i + 1] -- 1710
			i = i + 1 -- 1709
		end -- 1709
	end -- 1709
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1712
	do -- 1712
		local i = 0 -- 1713
		while i < #requiredExcludes do -- 1713
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1713
				result[#result + 1] = requiredExcludes[i + 1] -- 1715
			end -- 1715
			i = i + 1 -- 1713
		end -- 1713
	end -- 1713
	return result -- 1718
end -- 1718
local function recoverJsonStringProperty(text, key) -- 14
	local marker = ("\"" .. key) .. "\"" -- 15
	local markerIndex = (string.find(text, marker, nil, true) or 0) - 1 -- 16
	if markerIndex < 0 then -- 16
		return nil -- 17
	end -- 17
	local colonIndex = (string.find( -- 18
		text, -- 18
		":", -- 18
		math.max(markerIndex + #marker + 1, 1), -- 18
		true -- 18
	) or 0) - 1 -- 18
	if colonIndex < 0 then -- 18
		return nil -- 19
	end -- 19
	local quoteIndex = colonIndex + 1 -- 20
	while quoteIndex < #text do -- 20
		local code = __TS__StringCharCodeAt(text, quoteIndex) -- 22
		if code ~= 32 and code ~= 9 and code ~= 10 and code ~= 13 then -- 22
			break -- 23
		end -- 23
		quoteIndex = quoteIndex + 1 -- 24
	end -- 24
	if quoteIndex >= #text or __TS__StringCharCodeAt(text, quoteIndex) ~= 34 then -- 24
		return nil -- 26
	end -- 26
	local escaped = false -- 27
	do -- 27
		local i = quoteIndex + 1 -- 28
		while i < #text do -- 28
			do -- 28
				local code = __TS__StringCharCodeAt(text, i) -- 29
				if escaped then -- 29
					escaped = false -- 31
					goto __continue9 -- 32
				end -- 32
				if code == 92 then -- 32
					escaped = true -- 35
					goto __continue9 -- 36
				end -- 36
				if code == 34 then -- 36
					local decoded = safeJsonDecode(("{\"value\":" .. __TS__StringSlice(text, quoteIndex, i + 1)) .. "}") -- 39
					if decoded and type(decoded) == "table" and type(decoded.value) == "string" then -- 39
						return {value = decoded.value, complete = true} -- 41
					end -- 41
					return nil -- 43
				end -- 43
			end -- 43
			::__continue9:: -- 43
			i = i + 1 -- 28
		end -- 28
	end -- 28
	local fragment = __TS__StringSlice(text, quoteIndex) -- 46
	do -- 46
		local trim = 0 -- 47
		while trim <= 6 and trim <= #fragment - 1 do -- 47
			local decoded = safeJsonDecode(("{\"value\":" .. __TS__StringSlice(fragment, 0, #fragment - trim)) .. "\"}") -- 48
			if decoded and type(decoded) == "table" and type(decoded.value) == "string" then -- 48
				return {value = decoded.value, complete = false} -- 50
			end -- 50
			trim = trim + 1 -- 47
		end -- 47
	end -- 47
	return nil -- 53
end -- 14
--- Recover only a truncated whole-file overwrite. A truncated replacement with
-- non-empty old_str is unsafe and deliberately returns undefined.
function ____exports.planTruncatedEditRecovery(toolCalls) -- 60
	if not toolCalls or #toolCalls == 0 then -- 60
		return nil -- 63
	end -- 63
	do -- 63
		local i = #toolCalls - 1 -- 64
		while i >= 0 do -- 64
			do -- 64
				local ____opt_0 = toolCalls[i + 1] -- 64
				local fn = ____opt_0 and ____opt_0["function"] -- 65
				if not fn or fn.name ~= "edit_file" or type(fn.arguments) ~= "string" then -- 65
					goto __continue20 -- 66
				end -- 66
				local recovered = recoverJsonStringProperty(fn.arguments, "new_str") -- 67
				if not recovered or recovered.complete or #recovered.value == 0 then -- 67
					goto __continue20 -- 68
				end -- 68
				local target = recoverJsonStringProperty(fn.arguments, "path") or recoverJsonStringProperty(fn.arguments, "target_file") -- 69
				local oldStr = recoverJsonStringProperty(fn.arguments, "old_str") -- 71
				if not target or not target.complete or not oldStr or not oldStr.complete or oldStr.value ~= "" then -- 71
					goto __continue20 -- 72
				end -- 72
				return { -- 73
					target = target.value, -- 74
					receivedText = recovered.value, -- 75
					reason = ((("The response ended while overwriting " .. target.value) .. ". Write the ") .. tostring(#recovered.value)) .. " fully decoded characters directly to that file. This is the complete recoverable prefix; inspect the actual file next and decide whether it already suffices or needs a bounded continuation." -- 76
				} -- 76
			end -- 76
			::__continue20:: -- 76
			i = i - 1 -- 64
		end -- 64
	end -- 64
	return nil -- 79
end -- 60
local TABLE_TASK = "AgentTask" -- 401
local TABLE_CP = "AgentCheckpoint" -- 402
local TABLE_ENTRY = "AgentCheckpointEntry" -- 403
ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 404
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 405
local AGENT_DOWNLOAD_TEMP_DIR = "agent" -- 406
local function now() -- 407
	return os.time() -- 407
end -- 407
local function toBool(v) -- 409
	return v ~= 0 and v ~= false and v ~= nil -- 410
end -- 409
local function toStr(v) -- 413
	if v == false or v == nil then -- 413
		return "" -- 414
	end -- 414
	return tostring(v) -- 415
end -- 413
local function isValidWorkspacePath(path) -- 418
	if not path or #path == 0 then -- 418
		return false -- 419
	end -- 419
	if Content:isAbsolutePath(path) then -- 419
		return false -- 420
	end -- 420
	if __TS__StringIncludes(path, "..") then -- 420
		return false -- 421
	end -- 421
	return true -- 422
end -- 418
local function isValidWorkDir(workDir) -- 425
	if not workDir or #workDir == 0 then -- 425
		return false -- 426
	end -- 426
	if not Content:isAbsolutePath(workDir) then -- 426
		return false -- 427
	end -- 427
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 427
		return false -- 428
	end -- 428
	return true -- 429
end -- 425
local function isValidSearchPath(path) -- 432
	if path == "" then -- 432
		return true -- 433
	end -- 433
	if Content:isAbsolutePath(path) then -- 433
		return false -- 434
	end -- 434
	if not path or #path == 0 then -- 434
		return false -- 435
	end -- 435
	if __TS__StringIncludes(path, "..") then -- 435
		return false -- 436
	end -- 436
	return true -- 437
end -- 432
local function resolveWorkspaceFilePath(workDir, path) -- 440
	if not isValidWorkDir(workDir) then -- 440
		return nil -- 441
	end -- 441
	if not isValidWorkspacePath(path) then -- 441
		return nil -- 442
	end -- 442
	return Path(workDir, path) -- 443
end -- 440
local function resolveWorkspaceSearchPath(workDir, path) -- 446
	if not isValidWorkDir(workDir) then -- 446
		return nil -- 447
	end -- 447
	if not isValidSearchPath(path) then -- 447
		return nil -- 448
	end -- 448
	return path == "" and workDir or Path(workDir, path) -- 449
end -- 446
local function toWorkspaceRelativePath(workDir, path) -- 452
	if not path or #path == 0 then -- 452
		return path -- 453
	end -- 453
	if not Content:isAbsolutePath(path) then -- 453
		return path -- 454
	end -- 454
	return Path:getRelative(path, workDir) -- 455
end -- 452
local function toWorkspaceRelativeFileList(workDir, files) -- 458
	return __TS__ArrayMap( -- 459
		files, -- 459
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 459
	) -- 459
end -- 458
local function toWorkspaceRelativeSearchResults(workDir, results) -- 462
	local mapped = {} -- 463
	do -- 463
		local i = 0 -- 464
		while i < #results do -- 464
			local row = results[i + 1] -- 465
			local clone = __TS__ObjectAssign({}, row) -- 466
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 467
			mapped[#mapped + 1] = clone -- 468
			i = i + 1 -- 464
		end -- 464
	end -- 464
	return mapped -- 470
end -- 462
local function resolveWorkspaceDirectoryPath(workDir, path) -- 473
	local relative = __TS__StringTrim(path or "") -- 474
	if relative == "" then -- 474
		return {success = true, path = workDir, relative = "."} -- 476
	end -- 476
	if not isValidWorkDir(workDir) or not isValidWorkspacePath(relative) then -- 476
		return {success = false, message = "invalid cwd path"} -- 479
	end -- 479
	local resolved = Path(workDir, relative) -- 481
	if not Content:exist(resolved) then -- 481
		return {success = false, message = "cwd does not exist"} -- 483
	end -- 483
	if not Content:isdir(resolved) then -- 483
		return {success = false, message = "cwd is not a directory"} -- 486
	end -- 486
	return {success = true, path = resolved, relative = relative} -- 488
end -- 473
local function getDoraAPIDocRoot(docLanguage) -- 491
	local zhDir = Path( -- 492
		Content.assetPath, -- 492
		"Script", -- 492
		"Lib", -- 492
		"Dora", -- 492
		"zh-Hans" -- 492
	) -- 492
	local enDir = Path( -- 493
		Content.assetPath, -- 493
		"Script", -- 493
		"Lib", -- 493
		"Dora", -- 493
		"en" -- 493
	) -- 493
	return docLanguage == "zh" and zhDir or enDir -- 494
end -- 491
local function getDoraTutorialDocRoot(docLanguage) -- 497
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 498
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 499
	return docLanguage == "zh" and zhDir or enDir -- 500
end -- 497
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 503
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 503
		return {"ts"} -- 505
	end -- 505
	return {"tl"} -- 507
end -- 503
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 510
	repeat -- 510
		local ____switch65 = programmingLanguage -- 510
		local ____cond65 = ____switch65 == "teal" -- 510
		if ____cond65 then -- 510
			return "tl" -- 512
		end -- 512
		____cond65 = ____cond65 or ____switch65 == "tl" -- 512
		if ____cond65 then -- 512
			return "tl" -- 513
		end -- 513
		do -- 513
			return programmingLanguage -- 514
		end -- 514
	until true -- 514
end -- 510
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 518
	if docSource == "tutorial" then -- 518
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 524
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 525
		return { -- 526
			root = Path(tutorialRoot, langDir), -- 527
			exts = {"md"}, -- 528
			globs = {"**/*.md"} -- 529
		} -- 529
	end -- 529
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 532
	return { -- 533
		root = getDoraAPIDocRoot(docLanguage), -- 534
		exts = exts, -- 535
		globs = __TS__ArrayMap( -- 536
			exts, -- 536
			function(____, ext) return "**/*." .. ext end -- 536
		) -- 536
	} -- 536
end -- 518
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 540
	if docSource == "tutorial" then -- 540
		return getDoraTutorialDocRoot(docLanguage) -- 542
	end -- 542
	return getDoraAPIDocRoot(docLanguage) -- 544
end -- 540
local AGENT_DORA_DOC_PREFIX = "@dora-doc/" -- 547
local function toDocRelativePath(baseRoot, path, docSource) -- 549
	if not path or #path == 0 then -- 549
		return path -- 550
	end -- 550
	local relative = Content:isAbsolutePath(path) and Path:getRelative(path, baseRoot) or path -- 551
	return ((AGENT_DORA_DOC_PREFIX .. docSource) .. "/") .. relative -- 552
end -- 549
local function resolveAgentDoraDocFilePath(path, docLanguage) -- 555
	if not docLanguage then -- 555
		return nil -- 556
	end -- 556
	local relative = path -- 557
	local source = "tutorial" -- 558
	if __TS__StringStartsWith(path, AGENT_DORA_DOC_PREFIX) then -- 558
		local namespaced = __TS__StringSlice(path, #AGENT_DORA_DOC_PREFIX) -- 560
		if __TS__StringStartsWith(namespaced, "api/") then -- 560
			source = "api" -- 562
			relative = string.sub(namespaced, 5) -- 563
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 563
			relative = string.sub(namespaced, 10) -- 565
		else -- 565
			return nil -- 567
		end -- 567
	end -- 567
	if not isValidWorkspacePath(relative) then -- 567
		return nil -- 570
	end -- 570
	local candidate = Path( -- 571
		getDoraDocResultBaseRoot(source, docLanguage), -- 571
		relative -- 571
	) -- 571
	local root = getDoraDocResultBaseRoot(source, docLanguage) -- 572
	local checked = Path:getRelative(candidate, root) -- 573
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 573
		return nil -- 574
	end -- 574
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 574
		return candidate -- 576
	end -- 576
	return nil -- 578
end -- 555
local function ensureDirPath(dir) -- 581
	if not dir or dir == "." or dir == "" then -- 581
		return true -- 582
	end -- 582
	if Content:exist(dir) then -- 582
		return Content:isdir(dir) -- 583
	end -- 583
	local parent = Path:getPath(dir) -- 584
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 584
		if not ensureDirPath(parent) then -- 584
			return false -- 586
		end -- 586
	end -- 586
	return Content:mkdir(dir) -- 588
end -- 581
local function ensureDirForFile(path) -- 591
	local dir = Path:getPath(path) -- 592
	return ensureDirPath(dir) -- 593
end -- 591
local function isHttpUrl(url) -- 596
	local normalized = string.lower(__TS__StringTrim(url)) -- 597
	return __TS__StringStartsWith(normalized, "http://") or __TS__StringStartsWith(normalized, "https://") -- 598
end -- 596
local function createOperationId() -- 601
	local raw = (tostring(os.time()) .. "-") .. tostring(math.floor(math.random() * 1000000000)) -- 602
	local safe = string.gsub(raw, "[^%w%-_]", "-") -- 603
	return safe -- 604
end -- 601
local function getAgentDownloadTempRoot() -- 607
	return Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR, AGENT_DOWNLOAD_TEMP_DIR) -- 608
end -- 607
local function cleanupPath(path) -- 611
	if not path or path == "" or not Content:exist(path) then -- 611
		return nil -- 612
	end -- 612
	if Content:remove(path) then -- 612
		return nil -- 613
	end -- 613
	return "failed to remove temporary path: " .. path -- 614
end -- 611
local function quoteGitArg(value) -- 617
	local plain = string.match(value, "^[%w%._%-%/]+$") -- 618
	if plain ~= nil then -- 618
		return value -- 620
	end -- 620
	local escaped = string.gsub(value, "\\", "\\\\") -- 622
	escaped = string.gsub(escaped, "\"", "\\\"") -- 623
	return ("\"" .. escaped) .. "\"" -- 624
end -- 617
local function shellSplit(command) -- 627
	local args = {} -- 628
	local current = "" -- 629
	local quote = "" -- 630
	local escaped = false -- 631
	do -- 631
		local i = 0 -- 632
		while i < #command do -- 632
			do -- 632
				local ch = __TS__StringCharAt(command, i) -- 633
				if escaped then -- 633
					current = current .. ch -- 635
					escaped = false -- 636
					goto __continue98 -- 637
				end -- 637
				if ch == "\\" then -- 637
					escaped = true -- 640
					goto __continue98 -- 641
				end -- 641
				if quote ~= "" then -- 641
					if ch == quote then -- 641
						quote = "" -- 645
					else -- 645
						current = current .. ch -- 647
					end -- 647
					goto __continue98 -- 649
				end -- 649
				if ch == "'" or ch == "\"" then -- 649
					quote = ch -- 652
					goto __continue98 -- 653
				end -- 653
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 653
					if current ~= "" then -- 653
						args[#args + 1] = current -- 657
						current = "" -- 658
					end -- 658
					goto __continue98 -- 660
				end -- 660
				current = current .. ch -- 662
			end -- 662
			::__continue98:: -- 662
			i = i + 1 -- 632
		end -- 632
	end -- 632
	if escaped then -- 632
		current = current .. "\\" -- 665
	end -- 665
	if current ~= "" then -- 665
		args[#args + 1] = current -- 668
	end -- 668
	return args -- 670
end -- 627
local function normalizeGitCommand(command) -- 673
	local trimmed = __TS__StringTrim(command) -- 674
	local normalized = string.lower(string.sub(trimmed, 1, 4)) == "git " and __TS__StringTrim(string.sub(trimmed, 5)) or trimmed -- 675
	return normalizeEscapedGitQuotes(normalized) -- 678
end -- 673
local function gitDefaultTargetFromUrl(url) -- 696
	local target = url -- 697
	local hashIndex = (string.find(target, "#", nil, true) or 0) - 1 -- 698
	if hashIndex >= 0 then -- 698
		target = __TS__StringSlice(target, 0, hashIndex) -- 699
	end -- 699
	local queryIndex = (string.find(target, "?", nil, true) or 0) - 1 -- 700
	if queryIndex >= 0 then -- 700
		target = __TS__StringSlice(target, 0, queryIndex) -- 701
	end -- 701
	target = string.gsub(target, "/+$", "") -- 702
	local name = string.match(target, "([^/]+)$") -- 703
	if name ~= nil and name ~= "" then -- 703
		target = name -- 704
	end -- 704
	if __TS__StringEndsWith( -- 704
		string.lower(target), -- 705
		".git" -- 705
	) then -- 705
		target = __TS__StringSlice(target, 0, #target - 4) -- 706
	end -- 706
	return target ~= "" and target or "repo" -- 708
end -- 696
local function parseGitCloneCommand(command) -- 711
	local args = shellSplit(normalizeGitCommand(command)) -- 721
	if #args == 0 or args[1] ~= "clone" then -- 721
		return nil -- 722
	end -- 722
	local url = "" -- 723
	local target = "" -- 724
	local ref -- 725
	local depth -- 726
	do -- 726
		local i = 1 -- 727
		while i < #args do -- 727
			do -- 727
				local arg = args[i + 1] -- 728
				if arg == "-b" or arg == "--branch" then
					i = i + 1 -- 730
					if i >= #args then -- 730
						return {success = false, message = arg .. " requires a value"} -- 731
					end -- 731
					ref = args[i + 1] -- 732
					goto __continue122 -- 733
				end -- 733
				if arg == "--depth" then
					i = i + 1 -- 736
					if i >= #args then -- 736
						return {success = false, message = "--depth requires a value"}
					end -- 737
					depth = args[i + 1] -- 738
					goto __continue122 -- 739
				end -- 739
				if __TS__StringStartsWith(arg, "--depth=") then
					depth = __TS__StringSlice(arg, #"--depth=")
					goto __continue122 -- 743
				end -- 743
				if __TS__StringStartsWith(arg, "-") then -- 743
					return {success = false, message = "unsupported clone option: " .. arg} -- 746
				end -- 746
				if url == "" then -- 746
					url = arg -- 749
					goto __continue122 -- 750
				end -- 750
				if target == "" then -- 750
					target = arg -- 753
					goto __continue122 -- 754
				end -- 754
				return {success = false, message = "unexpected clone argument: " .. arg} -- 756
			end -- 756
			::__continue122:: -- 756
			i = i + 1 -- 727
		end -- 727
	end -- 727
	if url == "" then -- 727
		return {success = false, message = "git clone requires a URL"} -- 758
	end -- 758
	if not isHttpUrl(url) then -- 758
		return {success = false, message = "git clone only supports http:// and https:// URLs"} -- 759
	end -- 759
	if target == "" then -- 759
		target = gitDefaultTargetFromUrl(url) -- 760
	end -- 760
	return { -- 761
		success = true, -- 762
		url = url, -- 763
		target = target, -- 764
		ref = ref, -- 765
		depth = depth ~= nil and depth ~= "" and depth or "1" -- 766
	} -- 766
end -- 711
local function getGitHeadCommit(repoPath) -- 770
	local headPath = Path(repoPath, ".git", "HEAD") -- 771
	if not Content:exist(headPath) then -- 771
		return nil -- 772
	end -- 772
	local head = __TS__StringTrim(toStr(Content:load(headPath))) -- 773
	local ref = string.match(head, "^ref:%s*(.-)%s*$") -- 774
	if ref ~= nil and ref ~= "" then -- 774
		local refPath = Path(repoPath, ".git", ref) -- 776
		if Content:exist(refPath) then -- 776
			local commit = __TS__StringTrim(toStr(Content:load(refPath))) -- 778
			return commit ~= "" and commit or nil -- 779
		end -- 779
		return nil -- 781
	end -- 781
	return head ~= "" and head or nil -- 783
end -- 770
local function runGitAndWait(repoPath, command, onStatus, isCancelled, timeout) -- 786
	if timeout == nil then -- 786
		timeout = 600 -- 791
	end -- 791
	return __TS__New( -- 793
		__TS__Promise, -- 793
		function(____, resolve) -- 793
			local status -- 794
			local jobId = 0 -- 795
			local settled = false -- 796
			local canceled = false -- 797
			local function finish(result) -- 798
				if settled then -- 798
					return -- 799
				end -- 799
				settled = true -- 800
				resolve(nil, result) -- 801
			end -- 798
			local function finishFromStatus() -- 803
				local state = toStr(status and status.state) -- 804
				if state == "done" then -- 804
					finish({success = true, status = status}) -- 806
					return true -- 807
				end -- 807
				if state == "error" or state == "canceled" then -- 807
					local errorMessage = toStr(status and status.error) -- 810
					local statusMessage = toStr(status and status.message) -- 811
					finish({success = false, message = errorMessage ~= "" and errorMessage or (statusMessage ~= "" and statusMessage or (state == "canceled" and "git command canceled" or "git command failed")), status = status, interrupted = state == "canceled"}) -- 812
					return true -- 818
				end -- 818
				return false -- 820
			end -- 803
			jobId = Git:run( -- 822
				repoPath, -- 822
				command, -- 822
				function(nextStatus) -- 822
					status = nextStatus -- 823
					if onStatus then -- 823
						onStatus(status) -- 824
					end -- 824
					return finishFromStatus() -- 825
				end, -- 822
				"" -- 826
			) -- 826
			if jobId == nil or jobId <= 0 then -- 826
				finish({success = false, message = "failed to start git command"}) -- 828
				return -- 829
			end -- 829
			if not status then -- 829
				local kind = string.match(command, "^(%S+)") -- 832
				status = { -- 833
					id = jobId, -- 834
					state = "queued", -- 835
					kind = toStr(kind), -- 836
					repoPath = repoPath, -- 837
					progress = 0, -- 838
					message = "queued" -- 839
				} -- 839
			end -- 839
			if onStatus then -- 839
				onStatus(status) -- 842
			end -- 842
			local startedAt = os.time() -- 843
			local lastEmitAt = startedAt -- 844
			Director.systemScheduler:schedule(function() -- 845
				if settled then -- 845
					return true -- 846
				end -- 846
				if not canceled and isCancelled and isCancelled() then -- 846
					canceled = true -- 848
					Git:cancel(jobId) -- 849
					finish({success = false, message = "git command canceled", status = status, interrupted = true}) -- 850
					return true -- 851
				end -- 851
				if finishFromStatus() then -- 851
					return true -- 853
				end -- 853
				local nowTime = os.time() -- 854
				if nowTime - startedAt >= timeout then -- 854
					Git:cancel(jobId) -- 856
					finish({success = false, message = "git command timed out", status = status}) -- 857
					return true -- 858
				end -- 858
				if onStatus and status and nowTime > lastEmitAt then -- 858
					lastEmitAt = nowTime -- 861
					onStatus(status) -- 862
				end -- 862
				return false -- 864
			end) -- 845
		end -- 793
	) -- 793
end -- 786
local function downloadFile(req) -- 869
	return __TS__New( -- 876
		__TS__Promise, -- 876
		function(____, resolve) -- 876
			local requestId = 0 -- 877
			local settled = false -- 878
			local bytesWritten = 0 -- 879
			local function finish(result) -- 880
				if settled then -- 880
					return -- 881
				end -- 881
				settled = true -- 882
				requestId = 0 -- 883
				resolve(nil, result) -- 884
			end -- 880
			Director.systemScheduler:schedule(function() -- 886
				if settled then -- 886
					return true -- 887
				end -- 887
				local ____this_9 -- 887
				____this_9 = req -- 888
				local ____opt_8 = ____this_9.isCancelled -- 888
				if (____opt_8 and ____opt_8(____this_9)) == true and requestId ~= 0 then -- 888
					HttpClient:cancel(requestId) -- 889
					finish({success = false, interrupted = true, message = "download canceled"}) -- 890
					return true -- 891
				end -- 891
				if requestId ~= 0 and not HttpClient:isRequestActive(requestId) then -- 891
					finish({success = false, message = "download request ended without a completion callback"}) -- 894
					return true -- 895
				end -- 895
				return false -- 897
			end) -- 886
			Director.systemScheduler:schedule(once(function() -- 899
				requestId = HttpClient:download( -- 900
					req.url, -- 900
					req.tempPath, -- 900
					req.timeout, -- 900
					function(interrupted, current, total) -- 900
						if type(current) == "number" and current > bytesWritten then -- 900
							bytesWritten = current -- 902
						end -- 902
						if interrupted then -- 902
							finish({success = false, interrupted = true, message = "download failed"}) -- 905
							return true -- 906
						end -- 906
						local ____this_11 -- 906
						____this_11 = req -- 908
						local ____opt_10 = ____this_11.isCancelled -- 908
						if (____opt_10 and ____opt_10(____this_11)) == true then -- 908
							finish({success = false, interrupted = true, message = "download canceled"}) -- 909
							return true -- 910
						end -- 910
						if current == total then -- 910
							finish({success = true, bytesWritten = bytesWritten}) -- 913
							return false -- 914
						end -- 914
						req:onProgress(current, total) -- 916
						return false -- 917
					end -- 900
				) -- 900
				if requestId == 0 then -- 900
					finish({success = false, message = "failed to schedule download request"}) -- 920
				else -- 920
					local ____this_13 -- 920
					____this_13 = req -- 921
					local ____opt_12 = ____this_13.isCancelled -- 921
					if (____opt_12 and ____opt_12(____this_13)) == true then -- 921
						HttpClient:cancel(requestId) -- 922
						finish({success = false, interrupted = true, message = "download canceled"}) -- 923
					end -- 923
				end -- 923
			end)) -- 899
		end -- 876
	) -- 876
end -- 869
local function getFileState(path) -- 929
	local exists = Content:exist(path) -- 930
	if not exists then -- 930
		return {exists = false, content = "", bytes = 0} -- 932
	end -- 932
	if Content:isdir(path) then -- 932
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 939
	end -- 939
	local content = Content:load(path) -- 946
	if type(content) ~= "string" then -- 946
		return {exists = true, content = "", bytes = 0} -- 948
	end -- 948
	return {exists = true, content = content, bytes = #content} -- 954
end -- 929
local function inspectReadableFile(path) -- 961
	do -- 961
		local function ____catch(e) -- 961
			Log( -- 983
				"Warn", -- 983
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 983
			) -- 983
			return true, {success = true} -- 984
		end -- 984
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 984
			local size, isBinary = Content:getAttr(path) -- 963
			if size == nil then -- 963
				return true, {success = false, message = "failed to read file"} -- 965
			end -- 965
			if isBinary then -- 965
				return true, { -- 971
					success = false, -- 972
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 973
					size = type(size) == "number" and size or nil, -- 974
					isBinary = true -- 975
				} -- 975
			end -- 975
			return true, { -- 978
				success = true, -- 979
				size = type(size) == "number" and size or nil -- 980
			} -- 980
		end) -- 980
		if not ____try then -- 980
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 980
		end -- 980
		if ____hasReturned then -- 980
			return ____returnValue -- 962
		end -- 962
	end -- 962
end -- 961
local function isEngineLogFilePath(path) -- 988
	return path == ENGINE_LOG_FILE -- 989
end -- 988
local function readEngineLogFile(path) -- 992
	if not isEngineLogFilePath(path) then -- 992
		return nil -- 993
	end -- 993
	local content = getEngineLogText() -- 994
	if content == nil then -- 994
		return {success = false, message = "failed to read engine logs"} -- 996
	end -- 996
	return {success = true, content = content, size = #content} -- 998
end -- 992
local function queryOne(sql, args) -- 1001
	local ____args_14 -- 1002
	if args then -- 1002
		____args_14 = DB:query(sql, args) -- 1002
	else -- 1002
		____args_14 = DB:query(sql) -- 1002
	end -- 1002
	local rows = ____args_14 -- 1002
	if not rows or #rows == 0 then -- 1002
		return nil -- 1003
	end -- 1003
	return rows[1] -- 1004
end -- 1001
do -- 1001
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\twork_mode TEXT NOT NULL DEFAULT 'code',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1009
	local taskColumns = DB:query(("PRAGMA table_info(" .. TABLE_TASK) .. ")") or ({}) -- 1018
	local hasTaskWorkMode = false -- 1019
	do -- 1019
		local i = 0 -- 1020
		while i < #taskColumns do -- 1020
			if tostring(taskColumns[i + 1][2]) == "work_mode" then -- 1020
				hasTaskWorkMode = true -- 1022
				break -- 1023
			end -- 1023
			i = i + 1 -- 1020
		end -- 1020
	end -- 1020
	if not hasTaskWorkMode then -- 1020
		DB:exec(("ALTER TABLE " .. TABLE_TASK) .. " ADD COLUMN work_mode TEXT NOT NULL DEFAULT 'code';") -- 1027
	end -- 1027
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 1029
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 1040
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 1041
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 1054
end -- 1054
local function isDtsFile(path) -- 1057
	return Path:getExt(Path:getName(path)) == "d" -- 1058
end -- 1057
local function isTiledEditorContent(content) -- 1061
	return __TS__StringStartsWith( -- 1062
		__TS__StringTrim(content), -- 1062
		"<?xml" -- 1062
	) -- 1062
end -- 1061
local function getSupportedBuildKind(path) -- 1067
	repeat -- 1067
		local ____switch195 = Path:getExt(path) -- 1067
		local ____cond195 = ____switch195 == "ts" or ____switch195 == "tsx" -- 1067
		if ____cond195 then -- 1067
			return "ts" -- 1069
		end -- 1069
		____cond195 = ____cond195 or ____switch195 == "xml" -- 1069
		if ____cond195 then -- 1069
			return "xml" -- 1070
		end -- 1070
		____cond195 = ____cond195 or ____switch195 == "tl" -- 1070
		if ____cond195 then -- 1070
			return "teal" -- 1071
		end -- 1071
		____cond195 = ____cond195 or ____switch195 == "lua" -- 1071
		if ____cond195 then -- 1071
			return "lua" -- 1072
		end -- 1072
		____cond195 = ____cond195 or ____switch195 == "yue" -- 1072
		if ____cond195 then -- 1072
			return "yue" -- 1073
		end -- 1073
		____cond195 = ____cond195 or ____switch195 == "yarn" -- 1073
		if ____cond195 then -- 1073
			return "yarn" -- 1074
		end -- 1074
		do -- 1074
			return nil -- 1075
		end -- 1075
	until true -- 1075
end -- 1067
local function getTaskHeadSeq(taskId) -- 1079
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1080
	if not row then -- 1080
		return nil -- 1081
	end -- 1081
	return row[1] or 0 -- 1082
end -- 1079
local function getTaskStatus(taskId) -- 1085
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1086
	if not row then -- 1086
		return nil -- 1087
	end -- 1087
	return toStr(row[1]) -- 1088
end -- 1085
local function getLastInsertRowId() -- 1091
	local row = queryOne("SELECT last_insert_rowid()") -- 1092
	return row and (row[1] or 0) or 0 -- 1093
end -- 1091
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 1096
	DB:exec( -- 1097
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 1097
		{ -- 1099
			taskId, -- 1099
			seq, -- 1099
			status, -- 1099
			summary, -- 1099
			toolName, -- 1099
			now() -- 1099
		} -- 1099
	) -- 1099
	return getLastInsertRowId() -- 1101
end -- 1096
local function getCheckpointEntries(checkpointId, desc) -- 1104
	if desc == nil then -- 1104
		desc = false -- 1104
	end -- 1104
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 1105
	if not rows then -- 1105
		return {} -- 1112
	end -- 1112
	local result = {} -- 1113
	do -- 1113
		local i = 0 -- 1114
		while i < #rows do -- 1114
			local row = rows[i + 1] -- 1115
			result[#result + 1] = { -- 1116
				id = row[1], -- 1117
				ord = row[2], -- 1118
				path = toStr(row[3]), -- 1119
				op = toStr(row[4]), -- 1120
				beforeExists = toBool(row[5]), -- 1121
				beforeContent = toStr(row[6]), -- 1122
				afterExists = toBool(row[7]), -- 1123
				afterContent = toStr(row[8]) -- 1124
			} -- 1124
			i = i + 1 -- 1114
		end -- 1114
	end -- 1114
	return result -- 1127
end -- 1104
local function rejectDuplicatePaths(changes) -- 1130
	local seen = __TS__New(Set) -- 1131
	for ____, change in ipairs(changes) do -- 1132
		local key = change.path -- 1133
		if seen:has(key) then -- 1133
			return key -- 1134
		end -- 1134
		seen:add(key) -- 1135
	end -- 1135
	return nil -- 1137
end -- 1130
local function getLinkedDeletePaths(workDir, path) -- 1140
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1141
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 1141
		return {} -- 1142
	end -- 1142
	local parent = Path:getPath(fullPath) -- 1143
	local baseName = string.lower(Path:getName(fullPath)) -- 1144
	local ext = Path:getExt(fullPath) -- 1145
	local linked = {} -- 1146
	for ____, file in ipairs(Content:getFiles(parent)) do -- 1147
		do -- 1147
			if string.lower(Path:getName(file)) ~= baseName then -- 1147
				goto __continue212 -- 1148
			end -- 1148
			local siblingExt = Path:getExt(file) -- 1149
			if siblingExt == "tl" and ext == "vs" then -- 1149
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1151
					workDir, -- 1151
					Path(parent, file) -- 1151
				) -- 1151
				goto __continue212 -- 1152
			end -- 1152
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 1152
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1155
					workDir, -- 1155
					Path(parent, file) -- 1155
				) -- 1155
			end -- 1155
		end -- 1155
		::__continue212:: -- 1155
	end -- 1155
	return linked -- 1158
end -- 1140
local function expandLinkedDeleteChanges(workDir, changes) -- 1161
	local expanded = {} -- 1162
	local seen = __TS__New(Set) -- 1163
	do -- 1163
		local i = 0 -- 1164
		while i < #changes do -- 1164
			do -- 1164
				local change = changes[i + 1] -- 1165
				if not seen:has(change.path) then -- 1165
					seen:add(change.path) -- 1167
					expanded[#expanded + 1] = change -- 1168
				end -- 1168
				if change.op ~= "delete" then -- 1168
					goto __continue219 -- 1170
				end -- 1170
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 1171
				do -- 1171
					local j = 0 -- 1172
					while j < #linkedPaths do -- 1172
						do -- 1172
							local linkedPath = linkedPaths[j + 1] -- 1173
							if seen:has(linkedPath) then -- 1173
								goto __continue223 -- 1174
							end -- 1174
							seen:add(linkedPath) -- 1175
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 1176
						end -- 1176
						::__continue223:: -- 1176
						j = j + 1 -- 1172
					end -- 1172
				end -- 1172
			end -- 1172
			::__continue219:: -- 1172
			i = i + 1 -- 1164
		end -- 1164
	end -- 1164
	return expanded -- 1179
end -- 1161
local function applySingleFile(path, exists, content) -- 1182
	if exists then -- 1182
		if not ensureDirForFile(path) then -- 1182
			return false -- 1184
		end -- 1184
		return Content:save(path, content) -- 1185
	end -- 1185
	if Content:exist(path) then -- 1185
		return Content:remove(path) -- 1188
	end -- 1188
	return true -- 1190
end -- 1182
local function rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 1193
	local entries = getCheckpointEntries(checkpointId, true) -- 1198
	local remaining = appliedCount -- 1199
	local failures = {} -- 1200
	do -- 1200
		local i = 0 -- 1201
		while i < #entries and remaining > 0 do -- 1201
			do -- 1201
				local entry = entries[i + 1] -- 1202
				if entry.ord > appliedCount then -- 1202
					goto __continue231 -- 1203
				end -- 1203
				local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1204
				if not fullPath or not applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) then -- 1204
					failures[#failures + 1] = entry.path -- 1206
				else -- 1206
					____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) -- 1208
				end -- 1208
				remaining = remaining - 1 -- 1210
			end -- 1210
			::__continue231:: -- 1210
			i = i + 1 -- 1201
		end -- 1201
	end -- 1201
	return #failures > 0 and "rollback failed for: " .. table.concat(failures, ", ") or nil -- 1212
end -- 1193
function ____exports.sendWebIDERefreshTree() -- 1232
	if HttpServer.wsConnectionCount == 0 then -- 1232
		return true -- 1234
	end -- 1234
	local payload = encodeJSON({name = "RefreshTree"}) -- 1236
	if not payload then -- 1236
		return false -- 1238
	end -- 1238
	emit("AppWS", "Send", payload) -- 1240
	return true -- 1241
end -- 1232
local function syncProjectFileToWebIDE(workDir, path) -- 1244
	local target = resolveWorkspaceFilePath(workDir, path) -- 1245
	if not target then -- 1245
		return false -- 1246
	end -- 1246
	if not Content:exist(target) then -- 1246
		return ____exports.sendWebIDEFileUpdate(target, false, "") -- 1248
	end -- 1248
	if Content:isdir(target) then -- 1248
		return ____exports.sendWebIDERefreshTree() -- 1251
	end -- 1251
	local content = "" -- 1253
	do -- 1253
		local function ____catch(e) -- 1253
			Log( -- 1261
				"Warn", -- 1261
				(("[Agent.Tools] failed to inspect file for Web IDE update file=" .. target) .. ": ") .. tostring(e) -- 1261
			) -- 1261
		end -- 1261
		local ____try, ____hasReturned = pcall(function() -- 1261
			local ____, isBinary = Content:getAttr(target) -- 1255
			if not isBinary then -- 1255
				local loaded = Content:load(target) -- 1257
				content = type(loaded) == "string" and loaded or "" -- 1258
			end -- 1258
		end) -- 1258
		if not ____try then -- 1258
			____catch(____hasReturned) -- 1258
		end -- 1258
	end -- 1258
	return ____exports.sendWebIDEFileUpdate(target, true, content) -- 1263
end -- 1244
local function refreshProjectTree(workDir, path) -- 1266
	local normalized = type(path) == "string" and __TS__StringTrim(path) or "" -- 1267
	if normalized == "" then -- 1267
		return ____exports.sendWebIDERefreshTree() -- 1269
	end -- 1269
	return syncProjectFileToWebIDE(workDir, normalized) -- 1271
end -- 1266
local function syncDownloadedFileToWebIDE(file) -- 1274
	local content = "" -- 1275
	do -- 1275
		local function ____catch(e) -- 1275
			Log( -- 1283
				"Warn", -- 1283
				(("[fetch_url] failed to inspect downloaded file for Web IDE update file=" .. file) .. ": ") .. tostring(e) -- 1283
			) -- 1283
		end -- 1283
		local ____try, ____hasReturned = pcall(function() -- 1283
			local ____, isBinary = Content:getAttr(file) -- 1277
			if not isBinary then -- 1277
				local loaded = Content:load(file) -- 1279
				content = type(loaded) == "string" and loaded or "" -- 1280
			end -- 1280
		end) -- 1280
		if not ____try then -- 1280
			____catch(____hasReturned) -- 1280
		end -- 1280
	end -- 1280
	return ____exports.sendWebIDEFileUpdate(file, true, content) -- 1285
end -- 1274
local function runSingleNonTsBuild(file) -- 1288
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1288
		return ____awaiter_resolve( -- 1288
			nil, -- 1288
			__TS__New( -- 1289
				__TS__Promise, -- 1289
				function(____, resolve) -- 1289
					local moduleName = "Script.Dev.WebServer" -- 1290
					local ____require_result_15 = require(moduleName) -- 1291
					local buildAsync = ____require_result_15.buildAsync -- 1291
					Director.systemScheduler:schedule(once(function() -- 1292
						local result = buildAsync(file) -- 1293
						resolve(nil, result) -- 1294
					end)) -- 1292
				end -- 1289
			) -- 1289
		) -- 1289
	end) -- 1289
end -- 1288
local transpileRequestSeq = 0 -- 1299
function ____exports.runSingleTsTranspile(file, content, projectRoot) -- 1301
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1301
		local done = false -- 1302
		transpileRequestSeq = transpileRequestSeq + 1 -- 1303
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 1304
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 1305
		if HttpServer.wsConnectionCount == 0 then -- 1305
			return ____awaiter_resolve(nil, result) -- 1305
		end -- 1305
		local listener = Node() -- 1313
		listener:gslot( -- 1314
			"AppWS", -- 1314
			function(event) -- 1314
				if event.type ~= "Receive" then -- 1314
					return -- 1315
				end -- 1315
				local res = safeJsonDecode(event.msg) -- 1316
				if not res or __TS__ArrayIsArray(res) then -- 1316
					return -- 1317
				end -- 1317
				local payload = res -- 1318
				if payload.name ~= "TranspileTS" then -- 1318
					return -- 1319
				end -- 1319
				if payload.id ~= requestId then -- 1319
					return -- 1320
				end -- 1320
				if payload.success then -- 1320
					local luaFile = Path:replaceExt(file, "lua") -- 1322
					if Content:save( -- 1322
						luaFile, -- 1323
						tostring(payload.luaCode) -- 1323
					) then -- 1323
						result = {success = true, file = file} -- 1324
					else -- 1324
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 1326
					end -- 1326
				else -- 1326
					result = { -- 1329
						success = false, -- 1329
						file = file, -- 1329
						message = tostring(payload.message) -- 1329
					} -- 1329
				end -- 1329
				done = true -- 1331
			end -- 1314
		) -- 1314
		local payload = encodeJSON({ -- 1333
			name = "TranspileTS", -- 1334
			id = requestId, -- 1335
			file = file, -- 1336
			content = content, -- 1337
			projectRoot = projectRoot -- 1338
		}) -- 1338
		if not payload then -- 1338
			listener:removeFromParent() -- 1341
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 1341
		end -- 1341
		__TS__Await(__TS__New( -- 1344
			__TS__Promise, -- 1344
			function(____, resolve) -- 1344
				Director.systemScheduler:schedule(once(function() -- 1345
					emit("AppWS", "Send", payload) -- 1346
					wait(function() return done end) -- 1347
					if not done then -- 1347
						listener:removeFromParent() -- 1349
					end -- 1349
					resolve(nil) -- 1351
				end)) -- 1345
			end -- 1344
		)) -- 1344
		return ____awaiter_resolve(nil, result) -- 1344
	end) -- 1344
end -- 1301
function ____exports.createTask(prompt, workMode) -- 1357
	if prompt == nil then -- 1357
		prompt = "" -- 1357
	end -- 1357
	if workMode == nil then -- 1357
		workMode = "code" -- 1357
	end -- 1357
	local t = now() -- 1358
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, work_mode, created_at, updated_at) VALUES(?, ?, 0, ?, ?, ?)", { -- 1359
		"RUNNING", -- 1361
		prompt, -- 1361
		workMode, -- 1361
		t, -- 1361
		t -- 1361
	}) -- 1361
	if affected <= 0 then -- 1361
		return {success = false, message = "failed to create task"} -- 1364
	end -- 1364
	return { -- 1366
		success = true, -- 1366
		taskId = getLastInsertRowId() -- 1366
	} -- 1366
end -- 1357
function ____exports.setTaskStatus(taskId, status) -- 1369
	DB:exec( -- 1370
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 1370
		{ -- 1370
			status, -- 1370
			now(), -- 1370
			taskId -- 1370
		} -- 1370
	) -- 1370
	Log( -- 1371
		"Info", -- 1371
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 1371
	) -- 1371
end -- 1369
function ____exports.listCheckpoints(taskId) -- 1374
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 1375
	if not rows then -- 1375
		return {} -- 1382
	end -- 1382
	local items = {} -- 1383
	do -- 1383
		local i = 0 -- 1384
		while i < #rows do -- 1384
			local row = rows[i + 1] -- 1385
			items[#items + 1] = { -- 1386
				id = row[1], -- 1387
				taskId = row[2], -- 1388
				seq = row[3], -- 1389
				status = toStr(row[4]), -- 1390
				summary = toStr(row[5]), -- 1391
				toolName = toStr(row[6]), -- 1392
				createdAt = row[7] -- 1393
			} -- 1393
			i = i + 1 -- 1384
		end -- 1384
	end -- 1384
	return items -- 1396
end -- 1374
local function listCheckpointIdsForTask(taskId, desc) -- 1399
	if desc == nil then -- 1399
		desc = false -- 1399
	end -- 1399
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 1400
	if not rows then -- 1400
		return {} -- 1407
	end -- 1407
	local items = {} -- 1408
	do -- 1408
		local i = 0 -- 1409
		while i < #rows do -- 1409
			local row = rows[i + 1] -- 1410
			items[#items + 1] = {id = row[1], seq = row[2]} -- 1411
			i = i + 1 -- 1409
		end -- 1409
	end -- 1409
	return items -- 1416
end -- 1399
local function deriveFileOp(beforeExists, afterExists) -- 1419
	if not beforeExists and afterExists then -- 1419
		return "create" -- 1420
	end -- 1420
	if beforeExists and not afterExists then -- 1420
		return "delete" -- 1421
	end -- 1421
	return "write" -- 1422
end -- 1419
function ____exports.summarizeTaskChangeSet(taskId) -- 1425
	if not getTaskStatus(taskId) then -- 1425
		return {success = false, message = "task not found"} -- 1427
	end -- 1427
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1429
	local filesByPath = {} -- 1430
	local latestCheckpointId = nil -- 1436
	local latestCheckpointSeq = nil -- 1437
	do -- 1437
		local i = 0 -- 1438
		while i < #checkpoints do -- 1438
			local checkpoint = checkpoints[i + 1] -- 1439
			latestCheckpointId = checkpoint.id -- 1440
			latestCheckpointSeq = checkpoint.seq -- 1441
			local entries = getCheckpointEntries(checkpoint.id, false) -- 1442
			do -- 1442
				local j = 0 -- 1443
				while j < #entries do -- 1443
					local entry = entries[j + 1] -- 1444
					local item = filesByPath[entry.path] -- 1445
					if not item then -- 1445
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 1447
						filesByPath[entry.path] = item -- 1453
					end -- 1453
					item.afterExists = entry.afterExists -- 1455
					local ____item_checkpointIds_16 = item.checkpointIds -- 1455
					____item_checkpointIds_16[#____item_checkpointIds_16 + 1] = checkpoint.id -- 1456
					j = j + 1 -- 1443
				end -- 1443
			end -- 1443
			i = i + 1 -- 1438
		end -- 1438
	end -- 1438
	local files = {} -- 1459
	for ____, item in pairs(filesByPath) do -- 1460
		files[#files + 1] = { -- 1461
			path = item.path, -- 1462
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1463
			checkpointCount = #item.checkpointIds, -- 1464
			checkpointIds = item.checkpointIds -- 1465
		} -- 1465
	end -- 1465
	__TS__ArraySort( -- 1468
		files, -- 1468
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1468
	) -- 1468
	return { -- 1469
		success = true, -- 1470
		taskId = taskId, -- 1471
		checkpointCount = #checkpoints, -- 1472
		filesChanged = #files, -- 1473
		files = files, -- 1474
		latestCheckpointId = latestCheckpointId, -- 1475
		latestCheckpointSeq = latestCheckpointSeq -- 1476
	} -- 1476
end -- 1425
function ____exports.getTaskChangeSetDiff(taskId) -- 1480
	if not getTaskStatus(taskId) then -- 1480
		return {success = false, message = "task not found"} -- 1482
	end -- 1482
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1484
	if #checkpoints == 0 then -- 1484
		return {success = false, message = "change set not found or empty"} -- 1486
	end -- 1486
	local filesByPath = {} -- 1488
	do -- 1488
		local i = 0 -- 1495
		while i < #checkpoints do -- 1495
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 1496
			do -- 1496
				local j = 0 -- 1497
				while j < #entries do -- 1497
					local entry = entries[j + 1] -- 1498
					local item = filesByPath[entry.path] -- 1499
					if not item then -- 1499
						item = { -- 1501
							path = entry.path, -- 1502
							beforeExists = entry.beforeExists, -- 1503
							beforeContent = entry.beforeContent, -- 1504
							afterExists = entry.afterExists, -- 1505
							afterContent = entry.afterContent -- 1506
						} -- 1506
						filesByPath[entry.path] = item -- 1508
					end -- 1508
					item.afterExists = entry.afterExists -- 1510
					item.afterContent = entry.afterContent -- 1511
					j = j + 1 -- 1497
				end -- 1497
			end -- 1497
			i = i + 1 -- 1495
		end -- 1495
	end -- 1495
	local files = {} -- 1514
	for ____, item in pairs(filesByPath) do -- 1515
		files[#files + 1] = { -- 1516
			path = item.path, -- 1517
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1518
			beforeExists = item.beforeExists, -- 1519
			afterExists = item.afterExists, -- 1520
			beforeContent = item.beforeContent, -- 1521
			afterContent = item.afterContent -- 1522
		} -- 1522
	end -- 1522
	__TS__ArraySort( -- 1525
		files, -- 1525
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1525
	) -- 1525
	return {success = true, files = files} -- 1526
end -- 1480
local function readWorkspaceFile(workDir, path, docLanguage) -- 1529
	local engineLog = readEngineLogFile(path) -- 1530
	if engineLog then -- 1530
		return engineLog -- 1531
	end -- 1531
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1532
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 1532
		local attr = inspectReadableFile(fullPath) -- 1534
		if not attr.success then -- 1534
			return attr -- 1535
		end -- 1535
		return { -- 1536
			success = true, -- 1536
			content = Content:load(fullPath), -- 1536
			size = attr.size -- 1536
		} -- 1536
	end -- 1536
	local docPath = resolveAgentDoraDocFilePath(path, docLanguage) -- 1538
	if docPath then -- 1538
		local attr = inspectReadableFile(docPath) -- 1540
		if not attr.success then -- 1540
			return attr -- 1541
		end -- 1541
		return { -- 1542
			success = true, -- 1542
			content = Content:load(docPath), -- 1542
			size = attr.size -- 1542
		} -- 1542
	end -- 1542
	if not fullPath then -- 1542
		return {success = false, message = "invalid path or workDir"} -- 1544
	end -- 1544
	return {success = false, message = "file not found"} -- 1545
end -- 1529
function ____exports.readFileRaw(workDir, path, docLanguage) -- 1548
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 1549
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 1549
		local attr = inspectReadableFile(path) -- 1551
		if not attr.success then -- 1551
			return attr -- 1552
		end -- 1552
		return { -- 1553
			success = true, -- 1553
			content = Content:load(path), -- 1553
			size = attr.size -- 1553
		} -- 1553
	end -- 1553
	return result -- 1555
end -- 1548
function ____exports.getLogs(req) -- 1570
	local text = getEngineLogText() -- 1571
	if text == nil then -- 1571
		return {success = false, message = "failed to read engine logs"} -- 1573
	end -- 1573
	local tailLines = math.max( -- 1575
		1, -- 1575
		math.floor(req and req.tailLines or 200) -- 1575
	) -- 1575
	local allLines = __TS__StringSplit(text, "\n") -- 1576
	local logs = __TS__ArraySlice( -- 1577
		allLines, -- 1577
		math.max(0, #allLines - tailLines) -- 1577
	) -- 1577
	return req and req.joinText and ({ -- 1578
		success = true, -- 1578
		logs = logs, -- 1578
		text = table.concat(logs, "\n") -- 1578
	}) or ({success = true, logs = logs}) -- 1578
end -- 1570
function ____exports.listFiles(req) -- 1581
	local root = req.path or "" -- 1587
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 1588
	if not searchRoot then -- 1588
		return {success = false, message = "invalid path or workDir"} -- 1590
	end -- 1590
	do -- 1590
		local function ____catch(e) -- 1590
			return true, { -- 1608
				success = false, -- 1608
				message = tostring(e) -- 1608
			} -- 1608
		end -- 1608
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1608
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 1593
			local globs = ensureSafeSearchGlobs(userGlobs) -- 1594
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 1595
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 1596
			local totalEntries = #files -- 1597
			local maxEntries = math.max( -- 1598
				1, -- 1598
				math.floor(req.maxEntries or 200) -- 1598
			) -- 1598
			local truncated = totalEntries > maxEntries -- 1599
			return true, { -- 1600
				success = true, -- 1601
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 1602
				totalEntries = totalEntries, -- 1603
				truncated = truncated, -- 1604
				maxEntries = maxEntries -- 1605
			} -- 1605
		end) -- 1605
		if not ____try then -- 1605
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1605
		end -- 1605
		if ____hasReturned then -- 1605
			return ____returnValue -- 1592
		end -- 1592
	end -- 1592
end -- 1581
local function formatReadSlice(content, startLine, endLine) -- 1612
	local lines = __TS__StringSplit(content, "\n") -- 1617
	local totalLines = #lines -- 1618
	if totalLines == 0 then -- 1618
		return { -- 1620
			success = true, -- 1621
			content = "", -- 1622
			totalLines = 0, -- 1623
			startLine = 1, -- 1624
			endLine = 0, -- 1625
			truncated = false -- 1626
		} -- 1626
	end -- 1626
	local rawStart = math.floor(startLine) -- 1629
	local rawEnd = math.floor(endLine) -- 1630
	if rawStart == 0 then -- 1630
		return {success = false, message = "startLine cannot be 0"} -- 1632
	end -- 1632
	if rawEnd == 0 then -- 1632
		return {success = false, message = "endLine cannot be 0"} -- 1635
	end -- 1635
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1637
	if start > totalLines then -- 1637
		return { -- 1641
			success = false, -- 1641
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1641
		} -- 1641
	end -- 1641
	local ____end = math.min( -- 1643
		totalLines, -- 1644
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1645
	) -- 1645
	if ____end < start then -- 1645
		return { -- 1650
			success = false, -- 1651
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1652
		} -- 1652
	end -- 1652
	local slice = {} -- 1655
	do -- 1655
		local i = start -- 1656
		while i <= ____end do -- 1656
			slice[#slice + 1] = lines[i] -- 1657
			i = i + 1 -- 1656
		end -- 1656
	end -- 1656
	local truncated = start > 1 or ____end < totalLines -- 1659
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1660
	local body = table.concat(slice, "\n") -- 1665
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1666
	return { -- 1667
		success = true, -- 1668
		content = output, -- 1669
		totalLines = totalLines, -- 1670
		startLine = start, -- 1671
		endLine = ____end, -- 1672
		truncated = truncated -- 1673
	} -- 1673
end -- 1612
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1677
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1684
	if not fallback.success or fallback.content == nil then -- 1684
		return fallback -- 1685
	end -- 1685
	local resolvedStartLine = startLine or 1 -- 1686
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1687
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1688
end -- 1677
local codeExtensions = { -- 1695
	".lua", -- 1695
	".tl", -- 1695
	".yue", -- 1695
	".ts", -- 1695
	".tsx", -- 1695
	".xml", -- 1695
	".md", -- 1695
	".yarn", -- 1695
	".wa", -- 1695
	".mod" -- 1695
} -- 1695
extensionLevels = { -- 1696
	vs = 2, -- 1697
	bl = 2, -- 1698
	ts = 1, -- 1699
	tsx = 1, -- 1700
	tl = 1, -- 1701
	yue = 1, -- 1702
	xml = 1, -- 1703
	lua = 0 -- 1704
} -- 1704
local function splitSearchPatterns(pattern) -- 1721
	local trimmed = __TS__StringTrim(pattern or "") -- 1722
	if trimmed == "" then -- 1722
		return {} -- 1723
	end -- 1723
	local out = {} -- 1724
	local seen = __TS__New(Set) -- 1725
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1726
		local p = __TS__StringTrim(tostring(p0)) -- 1727
		if p ~= "" and not seen:has(p) then -- 1727
			seen:add(p) -- 1729
			out[#out + 1] = p -- 1730
		end -- 1730
	end -- 1730
	return out -- 1733
end -- 1721
local function splitWhitespaceSearchPatterns(pattern) -- 1736
	local out = {} -- 1737
	local seen = __TS__New(Set) -- 1738
	for p0 in string.gmatch(pattern, "(%S+)") do -- 1739
		local p = __TS__StringTrim(tostring(p0)) -- 1740
		local key = string.lower(p) -- 1741
		if p ~= "" and not seen:has(key) then -- 1741
			seen:add(key) -- 1743
			out[#out + 1] = p -- 1744
		end -- 1744
	end -- 1744
	return out -- 1747
end -- 1736
local function mergeSearchFileResultsUnique(resultsList) -- 1750
	local merged = {} -- 1751
	local seen = __TS__New(Set) -- 1752
	do -- 1752
		local i = 0 -- 1753
		while i < #resultsList do -- 1753
			local list = resultsList[i + 1] -- 1754
			do -- 1754
				local j = 0 -- 1755
				while j < #list do -- 1755
					do -- 1755
						local row = list[j + 1] -- 1756
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1757
						if seen:has(key) then -- 1757
							goto __continue353 -- 1758
						end -- 1758
						seen:add(key) -- 1759
						merged[#merged + 1] = list[j + 1] -- 1760
					end -- 1760
					::__continue353:: -- 1760
					j = j + 1 -- 1755
				end -- 1755
			end -- 1755
			i = i + 1 -- 1753
		end -- 1753
	end -- 1753
	return merged -- 1763
end -- 1750
local function buildGroupedSearchResults(results) -- 1766
	local order = {} -- 1771
	local grouped = __TS__New(Map) -- 1772
	do -- 1772
		local i = 0 -- 1777
		while i < #results do -- 1777
			local row = results[i + 1] -- 1778
			local file = row.file -- 1779
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1780
			local bucket = grouped:get(key) -- 1781
			if not bucket then -- 1781
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1783
				grouped:set(key, bucket) -- 1784
				order[#order + 1] = key -- 1785
			end -- 1785
			bucket.totalMatches = bucket.totalMatches + 1 -- 1787
			local ____bucket_matches_21 = bucket.matches -- 1787
			____bucket_matches_21[#____bucket_matches_21 + 1] = results[i + 1] -- 1788
			i = i + 1 -- 1777
		end -- 1777
	end -- 1777
	local out = {} -- 1790
	do -- 1790
		local i = 0 -- 1795
		while i < #order do -- 1795
			local bucket = grouped:get(order[i + 1]) -- 1796
			if bucket then -- 1796
				out[#out + 1] = bucket -- 1797
			end -- 1797
			i = i + 1 -- 1795
		end -- 1795
	end -- 1795
	return out -- 1799
end -- 1766
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1802
	local merged = {} -- 1803
	local seen = __TS__New(Set) -- 1804
	local index = 0 -- 1805
	local advanced = true -- 1806
	while advanced do -- 1806
		advanced = false -- 1808
		do -- 1808
			local i = 0 -- 1809
			while i < #resultsList do -- 1809
				do -- 1809
					local list = resultsList[i + 1] -- 1810
					if index >= #list then -- 1810
						goto __continue365 -- 1811
					end -- 1811
					advanced = true -- 1812
					local row = list[index + 1] -- 1813
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1814
					if seen:has(key) then -- 1814
						goto __continue365 -- 1815
					end -- 1815
					seen:add(key) -- 1816
					merged[#merged + 1] = row -- 1817
				end -- 1817
				::__continue365:: -- 1817
				i = i + 1 -- 1809
			end -- 1809
		end -- 1809
		index = index + 1 -- 1819
	end -- 1819
	return merged -- 1821
end -- 1802
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1824
	if docSource ~= "api" then -- 1824
		return 100 -- 1825
	end -- 1825
	if programmingLanguage ~= "tsx" then -- 1825
		return 100 -- 1826
	end -- 1826
	repeat -- 1826
		local ____switch371 = string.lower(Path:getFilename(file)) -- 1826
		local ____cond371 = ____switch371 == "jsx.d.ts" -- 1826
		if ____cond371 then -- 1826
			return 0 -- 1828
		end -- 1828
		____cond371 = ____cond371 or ____switch371 == "dorax.d.ts" -- 1828
		if ____cond371 then -- 1828
			return 1 -- 1829
		end -- 1829
		____cond371 = ____cond371 or ____switch371 == "dora.d.ts" -- 1829
		if ____cond371 then -- 1829
			return 2 -- 1830
		end -- 1830
		do -- 1830
			return 100 -- 1831
		end -- 1831
	until true -- 1831
end -- 1824
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1835
	local sorted = __TS__ArraySlice(hits) -- 1840
	__TS__ArraySort( -- 1841
		sorted, -- 1841
		function(____, a, b) -- 1841
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1842
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1843
			if pa ~= pb then -- 1843
				return pa - pb -- 1844
			end -- 1844
			local fa = string.lower(a.file) -- 1845
			local fb = string.lower(b.file) -- 1846
			if fa ~= fb then -- 1846
				return fa < fb and -1 or 1 -- 1847
			end -- 1847
			return (a.line or 0) - (b.line or 0) -- 1848
		end -- 1841
	) -- 1841
	return sorted -- 1850
end -- 1835
function ____exports.searchFiles(req) -- 1853
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1853
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1866
		if not resolvedPath then -- 1866
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1866
		end -- 1866
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1870
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1871
		if not searchRoot then -- 1871
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1871
		end -- 1871
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1871
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1871
		end -- 1871
		local patterns = splitSearchPatterns(req.pattern) -- 1878
		if #patterns == 0 then -- 1878
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1878
		end -- 1878
		return ____awaiter_resolve( -- 1878
			nil, -- 1878
			__TS__New( -- 1882
				__TS__Promise, -- 1882
				function(____, resolve) -- 1882
					Director.systemScheduler:schedule(once(function() -- 1883
						do -- 1883
							local function ____catch(e) -- 1883
								resolve( -- 1925
									nil, -- 1925
									{ -- 1925
										success = false, -- 1925
										message = tostring(e) -- 1925
									} -- 1925
								) -- 1925
							end -- 1925
							local ____try, ____hasReturned = pcall(function() -- 1925
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1885
								local allResults = {} -- 1888
								do -- 1888
									local i = 0 -- 1889
									while i < #patterns do -- 1889
										local ____Content_26 = Content -- 1890
										local ____Content_searchFilesAsync_27 = Content.searchFilesAsync -- 1890
										local ____patterns_index_25 = patterns[i + 1] -- 1895
										local ____req_useRegex_22 = req.useRegex -- 1896
										if ____req_useRegex_22 == nil then -- 1896
											____req_useRegex_22 = false -- 1896
										end -- 1896
										local ____req_caseSensitive_23 = req.caseSensitive -- 1897
										if ____req_caseSensitive_23 == nil then -- 1897
											____req_caseSensitive_23 = false -- 1897
										end -- 1897
										local ____req_includeContent_24 = req.includeContent -- 1898
										if ____req_includeContent_24 == nil then -- 1898
											____req_includeContent_24 = true -- 1898
										end -- 1898
										allResults[#allResults + 1] = ____Content_searchFilesAsync_27( -- 1890
											____Content_26, -- 1890
											searchRoot, -- 1891
											codeExtensions, -- 1892
											extensionLevels, -- 1893
											searchGlobs, -- 1894
											____patterns_index_25, -- 1895
											____req_useRegex_22, -- 1896
											____req_caseSensitive_23, -- 1897
											____req_includeContent_24, -- 1898
											req.contentWindow or 120 -- 1899
										) -- 1899
										i = i + 1 -- 1889
									end -- 1889
								end -- 1889
								local results = mergeSearchFileResultsUnique(allResults) -- 1902
								local totalResults = #results -- 1903
								local limit = math.max( -- 1904
									1, -- 1904
									math.floor(req.limit or 20) -- 1904
								) -- 1904
								local offset = math.max( -- 1905
									0, -- 1905
									math.floor(req.offset or 0) -- 1905
								) -- 1905
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1906
								local nextOffset = offset + #paged -- 1907
								local hasMore = nextOffset < totalResults -- 1908
								local truncated = offset > 0 or hasMore -- 1909
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1910
								local groupByFile = req.groupByFile == true -- 1911
								resolve( -- 1912
									nil, -- 1912
									{ -- 1912
										success = true, -- 1913
										results = relativeResults, -- 1914
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1915
										totalResults = totalResults, -- 1916
										truncated = truncated, -- 1917
										limit = limit, -- 1918
										offset = offset, -- 1919
										nextOffset = nextOffset, -- 1920
										hasMore = hasMore, -- 1921
										groupByFile = groupByFile -- 1922
									} -- 1922
								) -- 1922
							end) -- 1922
							if not ____try then -- 1922
								____catch(____hasReturned) -- 1922
							end -- 1922
						end -- 1922
					end)) -- 1883
				end -- 1882
			) -- 1882
		) -- 1882
	end) -- 1882
end -- 1853
function ____exports.searchDoraAPI(req) -- 1931
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1931
		local pattern = __TS__StringTrim(req.pattern or "") -- 1942
		if pattern == "" then -- 1942
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1942
		end -- 1942
		local patterns = splitSearchPatterns(pattern) -- 1944
		if #patterns == 0 then -- 1944
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1944
		end -- 1944
		local docSource = req.docSource or "api" -- 1946
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1947
		local docRoot = target.root -- 1948
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1949
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1949
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1949
		end -- 1949
		local exts = target.exts -- 1953
		local dotExts = __TS__ArrayMap( -- 1954
			exts, -- 1954
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1954
		) -- 1954
		local globs = target.globs -- 1955
		local limit = math.max( -- 1956
			1, -- 1956
			math.floor(req.limit or 10) -- 1956
		) -- 1956
		return ____awaiter_resolve( -- 1956
			nil, -- 1956
			__TS__New( -- 1958
				__TS__Promise, -- 1958
				function(____, resolve) -- 1958
					Director.systemScheduler:schedule(once(function() -- 1959
						do -- 1959
							local function ____catch(e) -- 1959
								resolve( -- 2039
									nil, -- 2039
									{ -- 2039
										success = false, -- 2039
										message = tostring(e) -- 2039
									} -- 2039
								) -- 2039
							end -- 2039
							local ____try, ____hasReturned = pcall(function() -- 2039
								local allHits = {} -- 1961
								do -- 1961
									local p = 0 -- 1962
									while p < #patterns do -- 1962
										local ____Content_32 = Content -- 1963
										local ____Content_searchFilesAsync_33 = Content.searchFilesAsync -- 1963
										local ____array_31 = __TS__SparseArrayNew( -- 1963
											docRoot, -- 1964
											dotExts, -- 1965
											{}, -- 1966
											ensureSafeSearchGlobs(globs), -- 1967
											patterns[p + 1] -- 1968
										) -- 1968
										local ____req_useRegex_28 = req.useRegex -- 1969
										if ____req_useRegex_28 == nil then -- 1969
											____req_useRegex_28 = false -- 1969
										end -- 1969
										__TS__SparseArrayPush(____array_31, ____req_useRegex_28) -- 1969
										local ____req_caseSensitive_29 = req.caseSensitive -- 1970
										if ____req_caseSensitive_29 == nil then -- 1970
											____req_caseSensitive_29 = false -- 1970
										end -- 1970
										__TS__SparseArrayPush(____array_31, ____req_caseSensitive_29) -- 1970
										local ____req_includeContent_30 = req.includeContent -- 1971
										if ____req_includeContent_30 == nil then -- 1971
											____req_includeContent_30 = true -- 1971
										end -- 1971
										__TS__SparseArrayPush(____array_31, ____req_includeContent_30, req.contentWindow or 80) -- 1971
										local raw = ____Content_searchFilesAsync_33( -- 1963
											____Content_32, -- 1963
											__TS__SparseArraySpread(____array_31) -- 1963
										) -- 1963
										local hits = {} -- 1974
										do -- 1974
											local i = 0 -- 1975
											while i < #raw do -- 1975
												do -- 1975
													local row = raw[i + 1] -- 1976
													local file = toDocRelativePath(resultBaseRoot, row.file, docSource) -- 1977
													if file == "" then -- 1977
														goto __continue398 -- 1978
													end -- 1978
													hits[#hits + 1] = { -- 1979
														file = file, -- 1980
														line = type(row.line) == "number" and row.line or nil, -- 1981
														content = type(row.content) == "string" and row.content or nil -- 1982
													} -- 1982
												end -- 1982
												::__continue398:: -- 1982
												i = i + 1 -- 1975
											end -- 1975
										end -- 1975
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1985
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1985
											0, -- 1985
											limit -- 1985
										) -- 1985
										p = p + 1 -- 1962
									end -- 1962
								end -- 1962
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1987
								local fallbackPatterns -- 1988
								if #hits == 0 and #patterns == 1 and req.useRegex ~= true and (string.find(pattern, "|", nil, true) or 0) - 1 < 0 then -- 1988
									local terms = splitWhitespaceSearchPatterns(pattern) -- 1993
									if #terms > 1 then -- 1993
										fallbackPatterns = terms -- 1995
										local fallbackHits = {} -- 1996
										do -- 1996
											local p = 0 -- 1997
											while p < #terms do -- 1997
												local ____Content_37 = Content -- 1998
												local ____Content_searchFilesAsync_38 = Content.searchFilesAsync -- 1998
												local ____array_36 = __TS__SparseArrayNew( -- 1998
													docRoot, -- 1999
													dotExts, -- 2000
													{}, -- 2001
													ensureSafeSearchGlobs(globs), -- 2002
													terms[p + 1], -- 2003
													false -- 2004
												) -- 2004
												local ____req_caseSensitive_34 = req.caseSensitive -- 2005
												if ____req_caseSensitive_34 == nil then -- 2005
													____req_caseSensitive_34 = false -- 2005
												end -- 2005
												__TS__SparseArrayPush(____array_36, ____req_caseSensitive_34) -- 2005
												local ____req_includeContent_35 = req.includeContent -- 2006
												if ____req_includeContent_35 == nil then -- 2006
													____req_includeContent_35 = true -- 2006
												end -- 2006
												__TS__SparseArrayPush(____array_36, ____req_includeContent_35, req.contentWindow or 80) -- 2006
												local raw = ____Content_searchFilesAsync_38( -- 1998
													____Content_37, -- 1998
													__TS__SparseArraySpread(____array_36) -- 1998
												) -- 1998
												local termHits = {} -- 2009
												do -- 2009
													local i = 0 -- 2010
													while i < #raw do -- 2010
														do -- 2010
															local row = raw[i + 1] -- 2011
															local file = toDocRelativePath(resultBaseRoot, row.file, docSource) -- 2012
															if file == "" then -- 2012
																goto __continue405 -- 2013
															end -- 2013
															termHits[#termHits + 1] = { -- 2014
																file = file, -- 2015
																line = type(row.line) == "number" and row.line or nil, -- 2016
																content = type(row.content) == "string" and row.content or nil -- 2017
															} -- 2017
														end -- 2017
														::__continue405:: -- 2017
														i = i + 1 -- 2010
													end -- 2010
												end -- 2010
												fallbackHits[#fallbackHits + 1] = __TS__ArraySlice( -- 2020
													sortDoraAPISearchHits(termHits, docSource, req.programmingLanguage), -- 2020
													0, -- 2020
													limit -- 2020
												) -- 2020
												p = p + 1 -- 1997
											end -- 1997
										end -- 1997
										hits = mergeDoraAPISearchHitsUnique(fallbackHits) -- 2022
									end -- 2022
								end -- 2022
								resolve(nil, { -- 2025
									success = true, -- 2026
									docSource = docSource, -- 2027
									docLanguage = req.docLanguage, -- 2028
									programmingLanguage = req.programmingLanguage, -- 2029
									exts = exts, -- 2030
									results = hits, -- 2031
									hint = "Use read_file directly with the namespaced file value from a search result to view the complete authoritative document.", -- 2032
									totalResults = #hits, -- 2033
									truncated = false, -- 2034
									limit = limit, -- 2035
									fallbackPatterns = fallbackPatterns -- 2036
								}) -- 2036
							end) -- 2036
							if not ____try then -- 2036
								____catch(____hasReturned) -- 2036
							end -- 2036
						end -- 2036
					end)) -- 1959
				end -- 1958
			) -- 1958
		) -- 1958
	end) -- 1958
end -- 1931
function ____exports.searchDoraAPIHttp(req, callback) -- 2045
	local ____self_39 = ____exports.searchDoraAPI(req) -- 2045
	____self_39["then"]( -- 2045
		____self_39, -- 2045
		function(____, result) return callback(result) end -- 2056
	) -- 2056
end -- 2045
function ____exports.readDoraDoc(req) -- 2059
	local requestedFile = table.concat( -- 2065
		__TS__StringSplit(req.file or "", "\\"), -- 2065
		"/" -- 2065
	) -- 2065
	local file = requestedFile -- 2066
	local namespacedSource = nil -- 2067
	if __TS__StringStartsWith(requestedFile, AGENT_DORA_DOC_PREFIX) then -- 2067
		local namespaced = __TS__StringSlice(requestedFile, #AGENT_DORA_DOC_PREFIX) -- 2069
		if __TS__StringStartsWith(namespaced, "api/") then -- 2069
			namespacedSource = "api" -- 2071
			file = string.sub(namespaced, 5) -- 2072
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 2072
			namespacedSource = "tutorial" -- 2074
			file = string.sub(namespaced, 10) -- 2075
		else -- 2075
			return {success = false, message = "invalid Dora doc namespace"} -- 2077
		end -- 2077
	end -- 2077
	if not isValidWorkspacePath(file) or file == "." then -- 2077
		return {success = false, message = "invalid file"} -- 2081
	end -- 2081
	local lowerFile = string.lower(file) -- 2083
	local isTutorialDoc = __TS__StringEndsWith(lowerFile, ".md") -- 2084
	local isAPIDoc = __TS__StringEndsWith(lowerFile, ".ts") or __TS__StringEndsWith(lowerFile, ".tl") -- 2085
	if not isTutorialDoc and not isAPIDoc then -- 2085
		return {success = false, message = "unsupported doc file type"} -- 2086
	end -- 2086
	local docSource = namespacedSource or (isTutorialDoc and "tutorial" or "api") -- 2087
	local root = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 2088
	local fullPath = Path(root, file) -- 2089
	local relative = Path:getRelative(fullPath, root) -- 2090
	if relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 2090
		return {success = false, message = "invalid file"} -- 2092
	end -- 2092
	local readResult = ____exports.readFile(root, file, req.startLine or 1, req.endLine or -1) -- 2094
	if not readResult.success then -- 2094
		return readResult -- 2095
	end -- 2095
	return { -- 2096
		success = true, -- 2097
		docLanguage = req.docLanguage, -- 2098
		file = file, -- 2099
		content = readResult.content, -- 2100
		startLine = readResult.startLine, -- 2101
		endLine = readResult.endLine -- 2102
	} -- 2102
end -- 2059
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 2106
	if options == nil then -- 2106
		options = {} -- 2106
	end -- 2106
	if #changes == 0 then -- 2106
		return {success = false, message = "empty changes"} -- 2108
	end -- 2108
	if not isValidWorkDir(workDir) then -- 2108
		return {success = false, message = "invalid workDir"} -- 2111
	end -- 2111
	if not getTaskStatus(taskId) then -- 2111
		return {success = false, message = "task not found"} -- 2114
	end -- 2114
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 2116
	local dup = rejectDuplicatePaths(expandedChanges) -- 2117
	if dup then -- 2117
		return {success = false, message = "duplicate path in batch: " .. dup} -- 2119
	end -- 2119
	for ____, change in ipairs(expandedChanges) do -- 2122
		if not isValidWorkspacePath(change.path) then -- 2122
			return {success = false, message = "invalid path: " .. change.path} -- 2124
		end -- 2124
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 2124
			return {success = false, message = "missing content for " .. change.path} -- 2127
		end -- 2127
	end -- 2127
	local headSeq = getTaskHeadSeq(taskId) -- 2131
	if headSeq == nil then -- 2131
		return {success = false, message = "task not found"} -- 2132
	end -- 2132
	local nextSeq = headSeq + 1 -- 2133
	local checkpointId = insertCheckpoint( -- 2134
		taskId, -- 2134
		nextSeq, -- 2134
		options.summary or "", -- 2134
		options.toolName or "", -- 2134
		"PREPARED" -- 2134
	) -- 2134
	if checkpointId <= 0 then -- 2134
		return {success = false, message = "failed to create checkpoint"} -- 2136
	end -- 2136
	do -- 2136
		local i = 0 -- 2139
		while i < #expandedChanges do -- 2139
			local change = expandedChanges[i + 1] -- 2140
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 2141
			if not fullPath then -- 2141
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2143
				return {success = false, message = "invalid path: " .. change.path} -- 2144
			end -- 2144
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 2144
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2147
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 2148
			end -- 2148
			local before = getFileState(fullPath) -- 2150
			local afterExists = change.op ~= "delete" -- 2151
			local afterContent = afterExists and (change.content or "") or "" -- 2152
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 2153
				checkpointId, -- 2157
				i + 1, -- 2158
				change.path, -- 2159
				change.op, -- 2160
				before.exists and 1 or 0, -- 2161
				before.content, -- 2162
				afterExists and 1 or 0, -- 2163
				afterContent, -- 2164
				before.bytes, -- 2165
				#afterContent -- 2166
			}) -- 2166
			if inserted <= 0 then -- 2166
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2170
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 2171
			end -- 2171
			i = i + 1 -- 2139
		end -- 2139
	end -- 2139
	local appliedCount = 0 -- 2175
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 2176
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2177
		if not fullPath then -- 2177
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2179
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2180
			return {success = false, message = ("invalid path: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2181
		end -- 2181
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 2183
		if not ok then -- 2183
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2185
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount + 1) -- 2186
			return {success = false, message = ("failed to apply file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2187
		end -- 2187
		appliedCount = appliedCount + 1 -- 2189
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 2189
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2191
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2192
			return {success = false, message = ("failed to sync file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; all applied files restored")} -- 2193
		end -- 2193
	end -- 2193
	DB:exec( -- 2197
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 2197
		{ -- 2199
			"APPLIED", -- 2199
			now(), -- 2199
			checkpointId -- 2199
		} -- 2199
	) -- 2199
	DB:exec( -- 2201
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 2201
		{ -- 2203
			nextSeq, -- 2203
			now(), -- 2203
			taskId -- 2203
		} -- 2203
	) -- 2203
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 2205
end -- 2106
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 2213
	if not isValidWorkDir(workDir) then -- 2213
		return {success = false, message = "invalid workDir"} -- 2214
	end -- 2214
	if checkpointId <= 0 then -- 2214
		return {success = false, message = "invalid checkpointId"} -- 2215
	end -- 2215
	local entries = getCheckpointEntries(checkpointId, true) -- 2216
	if #entries == 0 then -- 2216
		return {success = false, message = "checkpoint not found or empty"} -- 2218
	end -- 2218
	for ____, entry in ipairs(entries) do -- 2220
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2221
		if not fullPath then -- 2221
			return {success = false, message = "invalid path: " .. entry.path} -- 2223
		end -- 2223
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 2225
		if not ok then -- 2225
			Log( -- 2227
				"Error", -- 2227
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2227
			) -- 2227
			Log( -- 2228
				"Info", -- 2228
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2228
			) -- 2228
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 2229
		end -- 2229
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 2229
			Log( -- 2232
				"Error", -- 2232
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2232
			) -- 2232
			Log( -- 2233
				"Info", -- 2233
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2233
			) -- 2233
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 2234
		end -- 2234
	end -- 2234
	DB:exec( -- 2237
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 2237
		{ -- 2237
			"REVERTED", -- 2237
			now(), -- 2237
			checkpointId -- 2237
		} -- 2237
	) -- 2237
	return {success = true, checkpointId = checkpointId} -- 2238
end -- 2213
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 2241
	if not isValidWorkDir(workDir) then -- 2241
		return {success = false, message = "invalid workDir"} -- 2242
	end -- 2242
	if not getTaskStatus(taskId) then -- 2242
		return {success = false, message = "task not found"} -- 2243
	end -- 2243
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 2244
	if #checkpoints == 0 then -- 2244
		return {success = false, message = "change set not found or empty"} -- 2246
	end -- 2246
	local lastCheckpointId = 0 -- 2248
	do -- 2248
		local i = 0 -- 2249
		while i < #checkpoints do -- 2249
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 2250
			if not result.success then -- 2250
				return {success = false, message = result.message} -- 2251
			end -- 2251
			lastCheckpointId = checkpoints[i + 1].id -- 2252
			i = i + 1 -- 2249
		end -- 2249
	end -- 2249
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 2254
end -- 2241
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 2262
	return getCheckpointEntries(checkpointId, false) -- 2263
end -- 2262
function ____exports.getCheckpointDiff(checkpointId) -- 2266
	if checkpointId <= 0 then -- 2266
		return {success = false, message = "invalid checkpointId"} -- 2268
	end -- 2268
	local entries = getCheckpointEntries(checkpointId, false) -- 2270
	if #entries == 0 then -- 2270
		return {success = false, message = "checkpoint not found or empty"} -- 2272
	end -- 2272
	return { -- 2274
		success = true, -- 2275
		files = __TS__ArrayMap( -- 2276
			entries, -- 2276
			function(____, entry) return { -- 2276
				path = entry.path, -- 2277
				op = entry.op, -- 2278
				beforeExists = entry.beforeExists, -- 2279
				afterExists = entry.afterExists, -- 2280
				beforeContent = entry.beforeContent, -- 2281
				afterContent = entry.afterContent -- 2282
			} end -- 2282
		) -- 2282
	} -- 2282
end -- 2266
local function finalizeBuildResult(workDir, messages) -- 2287
	local normalized = __TS__ArrayMap( -- 2288
		messages, -- 2288
		function(____, m) return m.success and __TS__ObjectAssign( -- 2288
			{}, -- 2289
			m, -- 2289
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2289
		) or __TS__ObjectAssign( -- 2289
			{}, -- 2290
			m, -- 2290
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2290
		) end -- 2290
	) -- 2290
	local total = #normalized -- 2291
	local failed = 0 -- 2292
	do -- 2292
		local i = 0 -- 2293
		while i < #normalized do -- 2293
			if not normalized[i + 1].success then -- 2293
				failed = failed + 1 -- 2294
			end -- 2294
			i = i + 1 -- 2293
		end -- 2293
	end -- 2293
	local passed = total - failed -- 2296
	if failed > 0 then -- 2296
		return { -- 2298
			success = false, -- 2299
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 2300
			total = total, -- 2301
			passed = passed, -- 2302
			failed = failed, -- 2303
			messages = normalized -- 2304
		} -- 2304
	end -- 2304
	return { -- 2307
		success = true, -- 2308
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 2309
		total = total, -- 2310
		passed = passed, -- 2311
		failed = 0, -- 2312
		messages = normalized -- 2313
	} -- 2313
end -- 2287
function ____exports.build(req) -- 2317
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2317
		local targetRel = req.path or "" -- 2318
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2319
		if not target then -- 2319
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2319
		end -- 2319
		if not Content:exist(target) then -- 2319
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2319
		end -- 2319
		local messages = {} -- 2326
		if not Content:isdir(target) then -- 2326
			local kind = getSupportedBuildKind(target) -- 2328
			if not kind then -- 2328
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2328
			end -- 2328
			if kind == "ts" then -- 2328
				local content = Content:load(target) -- 2333
				if content == nil then -- 2333
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2333
				end -- 2333
				if isTiledEditorContent(content) then -- 2333
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2338
					return ____awaiter_resolve( -- 2338
						nil, -- 2338
						finalizeBuildResult(req.workDir, messages) -- 2339
					) -- 2339
				end -- 2339
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2339
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2339
				end -- 2339
				if not isDtsFile(target) then -- 2339
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir)) -- 2345
				end -- 2345
			else -- 2345
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2348
			end -- 2348
			Log( -- 2350
				"Info", -- 2350
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2350
			) -- 2350
			return ____awaiter_resolve( -- 2350
				nil, -- 2350
				finalizeBuildResult(req.workDir, messages) -- 2351
			) -- 2351
		end -- 2351
		local listResult = ____exports.listFiles({ -- 2353
			workDir = req.workDir, -- 2354
			path = targetRel, -- 2355
			globs = __TS__ArrayMap( -- 2356
				codeExtensions, -- 2356
				function(____, e) return "**/*" .. e end -- 2356
			), -- 2356
			maxEntries = 10000 -- 2357
		}) -- 2357
		local relFiles = listResult.success and listResult.files or ({}) -- 2360
		local tsFileData = {} -- 2361
		local buildQueue = {} -- 2362
		for ____, rel in ipairs(relFiles) do -- 2363
			do -- 2363
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2364
				local kind = getSupportedBuildKind(file) -- 2365
				if not kind then -- 2365
					goto __continue479 -- 2366
				end -- 2366
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2367
				if kind ~= "ts" then -- 2367
					goto __continue479 -- 2369
				end -- 2369
				local content = Content:load(file) -- 2371
				if content == nil then -- 2371
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2373
					goto __continue479 -- 2374
				end -- 2374
				if isTiledEditorContent(content) then -- 2374
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2377
					goto __continue479 -- 2378
				end -- 2378
				tsFileData[file] = content -- 2380
			end -- 2380
			::__continue479:: -- 2380
		end -- 2380
		do -- 2380
			local i = 0 -- 2382
			while i < #buildQueue do -- 2382
				do -- 2382
					local ____buildQueue_index_40 = buildQueue[i + 1] -- 2383
					local file = ____buildQueue_index_40.file -- 2383
					local kind = ____buildQueue_index_40.kind -- 2383
					if kind == "ts" then -- 2383
						local content = tsFileData[file] -- 2385
						if content == nil or isDtsFile(file) then -- 2385
							goto __continue486 -- 2387
						end -- 2387
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2387
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2390
							goto __continue486 -- 2391
						end -- 2391
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir)) -- 2393
						goto __continue486 -- 2394
					end -- 2394
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2396
				end -- 2396
				::__continue486:: -- 2396
				i = i + 1 -- 2382
			end -- 2382
		end -- 2382
		if #messages == 0 then -- 2382
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2399
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2399
		end -- 2399
		Log( -- 2402
			"Info", -- 2402
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2402
		) -- 2402
		return ____awaiter_resolve( -- 2402
			nil, -- 2402
			finalizeBuildResult(req.workDir, messages) -- 2403
		) -- 2403
	end) -- 2403
end -- 2317
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2406
local EXECUTE_COMMAND_ERROR_MAX = 4000 -- 2407
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 2408
local agentEntryRuntimeOwner = "" -- 2409
local function truncateCommandOutput(output) -- 2411
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2411
		return output -- 2412
	end -- 2412
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2413
end -- 2411
local function truncateCommandError(message) -- 2416
	if #message <= EXECUTE_COMMAND_ERROR_MAX then -- 2416
		return message -- 2417
	end -- 2417
	return __TS__StringSlice(message, 0, EXECUTE_COMMAND_ERROR_MAX) .. "\n... error message truncated ..." -- 2418
end -- 2416
local function executeLuaCommand(req) -- 2421
	local code = __TS__StringTrim(req.code or "") -- 2429
	if code == "" then -- 2429
		return __TS__Promise.resolve({ -- 2431
			success = false, -- 2431
			mode = "lua", -- 2431
			output = "", -- 2431
			message = "missing code", -- 2431
			phase = "validate" -- 2431
		}) -- 2431
	end -- 2431
	local output = {} -- 2433
	local entry = require("Script.Dev.Entry") -- 2434
	local ownsEntryRuntime = false -- 2435
	local entryObjectBaseline = 0 -- 2436
	local entryLuaRefBaseline = 0 -- 2437
	local function acquireEntryRuntime() -- 2438
		if agentEntryRuntimeOwner ~= "" and agentEntryRuntimeOwner ~= req.operationId then -- 2438
			error("Dora entry runtime is busy with another Agent command") -- 2440
		end -- 2440
		agentEntryRuntimeOwner = req.operationId -- 2442
		ownsEntryRuntime = true -- 2443
	end -- 2438
	local function stopOwnedEntry() -- 2445
		if not ownsEntryRuntime then -- 2445
			return nil -- 2446
		end -- 2446
		local cleanupError -- 2447
		do -- 2447
			local function ____catch(e) -- 2447
				cleanupError = "failed to stop Agent test entry: " .. tostring(e) -- 2451
			end -- 2451
			local ____try, ____hasReturned = pcall(function() -- 2451
				entry.stop() -- 2449
			end) -- 2449
			if not ____try then -- 2449
				____catch(____hasReturned) -- 2449
			end -- 2449
		end -- 2449
		ownsEntryRuntime = false -- 2453
		if agentEntryRuntimeOwner == req.operationId then -- 2453
			agentEntryRuntimeOwner = "" -- 2455
		end -- 2455
		return cleanupError -- 2457
	end -- 2445
	local function startEntryWatchdog() -- 2459
		entryObjectBaseline = Dora.Object.count -- 2460
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 2461
	end -- 2459
	local function checkEntryWatchdog() -- 2463
		if not ownsEntryRuntime then -- 2463
			return nil -- 2464
		end -- 2464
		local objectCount = Dora.Object.count -- 2465
		local luaRefCount = Dora.Object.luaRefCount -- 2466
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 2467
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 2468
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 2469
		if not exceededTotal then -- 2469
			return nil -- 2472
		end -- 2472
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 2473
	end -- 2463
	local function normalizeEntryFile(value) -- 2477
		if not value or type(value) ~= "table" then -- 2477
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 2479
		end -- 2479
		local descriptor = value -- 2481
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 2482
		if relativeFile == "" then -- 2482
			relativeFile = "init" -- 2483
		end -- 2483
		if not isValidWorkspacePath(relativeFile) then -- 2483
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 2485
		end -- 2485
		local fileName = Path(req.workDir, relativeFile) -- 2487
		local ext = Path:getExt(fileName) -- 2488
		if ext ~= "" then -- 2488
			fileName = Path:replaceExt(fileName, "") -- 2489
		end -- 2489
		local luaFile = Path:replaceExt(fileName, "lua") -- 2490
		if not Content:exist(luaFile) then -- 2490
			error("Agent test entry was not built: " .. luaFile) -- 2492
		end -- 2492
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 2494
		return { -- 2495
			fileName = fileName, -- 2496
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 2497
		} -- 2497
	end -- 2477
	local function capturePrint(...) -- 2500
		local values = {...} -- 2500
		local parts = {} -- 2501
		do -- 2501
			local i = 0 -- 2502
			while i < #values do -- 2502
				parts[#parts + 1] = tostring(values[i + 1]) -- 2503
				i = i + 1 -- 2502
			end -- 2502
		end -- 2502
		output[#output + 1] = table.concat(parts, "\t") -- 2505
	end -- 2500
	local env = setmetatable( -- 2507
		{ -- 2507
			projectDir = req.workDir, -- 2508
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 2509
				if type(moduleNameValue) ~= "string" then -- 2509
					error("requireProjectModule expects a project module name string") -- 2511
				end -- 2511
				local moduleName = __TS__StringTrim(moduleNameValue) -- 2513
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 2513
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 2515
				end -- 2515
				local reloadModules = {moduleName} -- 2517
				if reloadModulesValue ~= nil then -- 2517
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 2517
						error("requireProjectModule reloadModules must be an array of module names") -- 2520
					end -- 2520
					local items = reloadModulesValue -- 2522
					do -- 2522
						local i = 0 -- 2523
						while i < #items do -- 2523
							local item = items[i + 1] -- 2524
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 2524
								error("requireProjectModule reloadModules contains an invalid module name") -- 2526
							end -- 2526
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 2526
								reloadModules[#reloadModules + 1] = item -- 2528
							end -- 2528
							i = i + 1 -- 2523
						end -- 2523
					end -- 2523
				end -- 2523
				local luaPackage = _G.package -- 2531
				local previousPath = luaPackage.path -- 2535
				local previousSearchPaths = Content.searchPaths -- 2536
				local scopedSearchPaths = {req.workDir} -- 2537
				do -- 2537
					local i = 0 -- 2538
					while i < #previousSearchPaths do -- 2538
						local searchPath = previousSearchPaths[i + 1] -- 2539
						if searchPath ~= req.workDir then -- 2539
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 2540
						end -- 2540
						i = i + 1 -- 2538
					end -- 2538
				end -- 2538
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 2542
				Content.searchPaths = scopedSearchPaths -- 2543
				do -- 2543
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2543
						do -- 2543
							local i = 0 -- 2545
							while i < #reloadModules do -- 2545
								local reloadName = reloadModules[i + 1] -- 2546
								luaPackage.loaded[reloadName] = nil -- 2547
								luaPackage.loaded[table.concat( -- 2548
									__TS__StringSplit(reloadName, "/"), -- 2548
									"." -- 2548
								)] = nil -- 2548
								luaPackage.loaded[table.concat( -- 2549
									__TS__StringSplit(reloadName, "."), -- 2549
									"/" -- 2549
								)] = nil -- 2549
								i = i + 1 -- 2545
							end -- 2545
						end -- 2545
						return true, require(table.concat( -- 2551
							__TS__StringSplit(moduleName, "/"), -- 2551
							"." -- 2551
						)) -- 2551
					end) -- 2551
					do -- 2551
						Content.searchPaths = previousSearchPaths -- 2553
						luaPackage.path = previousPath -- 2554
					end -- 2554
					if not ____try then -- 2554
						error(____hasReturned, 0) -- 2554
					end -- 2554
					if ____try and ____hasReturned then -- 2554
						return ____returnValue -- 2544
					end -- 2544
				end -- 2544
			end, -- 2509
			print = capturePrint, -- 2557
			refreshTree = function(path) -- 2558
				if path == nil then -- 2558
					return refreshProjectTree(req.workDir) -- 2560
				end -- 2560
				if type(path) ~= "string" then -- 2560
					error("refreshTree expects a project-relative file path string or no argument") -- 2563
				end -- 2563
				return refreshProjectTree(req.workDir, path) -- 2565
			end, -- 2558
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 2567
			enterEntryAsync = function(value) -- 2568
				local normalized = normalizeEntryFile(value) -- 2569
				acquireEntryRuntime() -- 2570
				entry.allClear() -- 2571
				startEntryWatchdog() -- 2572
				local success, message = entry.enterEntryAsync({ -- 2573
					entryName = normalized.entryName, -- 2574
					fileName = normalized.fileName, -- 2575
					workDir = req.workDir, -- 2576
					projectRoot = req.workDir, -- 2577
					runKind = "agent_test" -- 2578
				}) -- 2578
				return success, message -- 2580
			end, -- 2568
			stopEntry = function() -- 2582
				if not ownsEntryRuntime then -- 2582
					return false -- 2583
				end -- 2583
				return entry.stop() -- 2584
			end -- 2582
		}, -- 2582
		{__index = Dora} -- 2586
	) -- 2586
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 2589
	if not fn then -- 2589
		return __TS__Promise.resolve({ -- 2591
			success = false, -- 2592
			mode = "lua", -- 2593
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2594
			message = truncateCommandError(toStr(compileErr)), -- 2595
			phase = "compile" -- 2596
		}) -- 2596
	end -- 2596
	return __TS__New( -- 2599
		__TS__Promise, -- 2599
		function(____, resolve) -- 2599
			local settled = false -- 2600
			local startedAt = App.runningTime -- 2601
			local onProgress = req.onProgress -- 2602
			local isCancelled = req.isCancelled -- 2603
			local function finish(result) -- 2604
				if settled then -- 2604
					return -- 2605
				end -- 2605
				settled = true -- 2606
				local cleanupError = stopOwnedEntry() -- 2607
				if not result.success and cleanupError ~= nil then -- 2607
					result.cleanupError = cleanupError -- 2609
				elseif result.success and cleanupError ~= nil then -- 2609
					resolve(nil, { -- 2611
						success = false, -- 2612
						mode = "lua", -- 2613
						output = result.output, -- 2614
						message = cleanupError, -- 2615
						phase = "execute", -- 2616
						cleanupError = cleanupError -- 2617
					}) -- 2617
					return -- 2619
				end -- 2619
				resolve(nil, result) -- 2621
			end -- 2604
			if onProgress then -- 2604
				onProgress(nil, { -- 2624
					state = "pending", -- 2625
					mode = "lua", -- 2626
					operationId = req.operationId, -- 2627
					stage = "lua", -- 2628
					message = "Lua command pending" -- 2629
				}) -- 2629
			end -- 2629
			Director.systemScheduler:schedule(function() -- 2632
				if settled then -- 2632
					return true -- 2633
				end -- 2633
				local watchdogMessage = checkEntryWatchdog() -- 2634
				if watchdogMessage ~= nil then -- 2634
					finish({ -- 2636
						success = false, -- 2637
						mode = "lua", -- 2638
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2639
						message = watchdogMessage, -- 2640
						phase = "execute", -- 2641
						interrupted = true -- 2642
					}) -- 2642
					return true -- 2644
				end -- 2644
				if isCancelled and isCancelled(nil) then -- 2644
					finish({ -- 2647
						success = false, -- 2648
						mode = "lua", -- 2649
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2650
						message = "Lua command canceled", -- 2651
						phase = "execute", -- 2652
						interrupted = true -- 2653
					}) -- 2653
					return true -- 2655
				end -- 2655
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 2655
					finish({ -- 2658
						success = false, -- 2659
						mode = "lua", -- 2660
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2661
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 2662
						phase = "timeout" -- 2663
					}) -- 2663
					return true -- 2665
				end -- 2665
				return false -- 2667
			end) -- 2632
			Director.systemScheduler:schedule(once(function() -- 2669
				if settled then -- 2669
					return -- 2670
				end -- 2670
				if onProgress then -- 2670
					onProgress(nil, { -- 2672
						state = "running", -- 2673
						mode = "lua", -- 2674
						operationId = req.operationId, -- 2675
						stage = "lua", -- 2676
						message = "Lua command running" -- 2677
					}) -- 2677
				end -- 2677
				local previousGlobalPrint = _G.print -- 2680
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 2681
				local frameTimedOut = false -- 2682
				local watchdogMessage -- 2682
				_G.print = capturePrint -- 2683
				debug.sethook( -- 2684
					function() -- 2684
						if watchdogMessage == nil then -- 2684
							watchdogMessage = checkEntryWatchdog() -- 2685
						end -- 2685
						if watchdogMessage ~= nil then -- 2685
							error(watchdogMessage) -- 2686
						end -- 2686
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 2686
							frameTimedOut = true -- 2688
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 2689
						end -- 2689
					end, -- 2684
					"", -- 2691
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 2691
				) -- 2691
				local ok, runtimeErr = pcall(fn) -- 2692
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 2692
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 2694
				else -- 2694
					debug.sethook() -- 2700
				end -- 2700
				_G.print = previousGlobalPrint -- 2702
				if not ok then -- 2702
					local ____truncateCommandOutput_result_42 = truncateCommandOutput(table.concat(output, "\n")) -- 2707
					local ____temp_43 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 2708
					local ____temp_44 = frameTimedOut and "timeout" or "execute" -- 2709
					local ____temp_41 -- 2710
					if watchdogMessage ~= nil or frameTimedOut then -- 2710
						____temp_41 = true -- 2710
					else -- 2710
						____temp_41 = nil -- 2710
					end -- 2710
					finish({ -- 2704
						success = false, -- 2705
						mode = "lua", -- 2706
						output = ____truncateCommandOutput_result_42, -- 2707
						message = ____temp_43, -- 2708
						phase = ____temp_44, -- 2709
						interrupted = ____temp_41 -- 2710
					}) -- 2710
					return -- 2712
				end -- 2712
				finish({ -- 2714
					success = true, -- 2714
					mode = "lua", -- 2714
					output = truncateCommandOutput(table.concat(output, "\n")) -- 2714
				}) -- 2714
			end)) -- 2669
		end -- 2599
	) -- 2599
end -- 2421
local function formatGitStatusOutput(status) -- 2719
	if not status then -- 2719
		return "" -- 2720
	end -- 2720
	local lines = {} -- 2721
	local state = toStr(status.state) -- 2722
	local kind = toStr(status.kind) -- 2723
	local message = toStr(status.message) -- 2724
	local errorMessage = toStr(status.error) -- 2725
	if kind ~= "" or state ~= "" then -- 2725
		lines[#lines + 1] = table.concat( -- 2727
			__TS__ArrayFilter( -- 2727
				{kind, state}, -- 2727
				function(____, item) return item ~= "" end -- 2727
			), -- 2727
			": " -- 2727
		) -- 2727
	end -- 2727
	if message ~= "" then -- 2727
		lines[#lines + 1] = message -- 2729
	end -- 2729
	if errorMessage ~= "" then -- 2729
		lines[#lines + 1] = errorMessage -- 2730
	end -- 2730
	local data = status.data -- 2731
	if data ~= nil then -- 2731
		local dataText = encodeJSON(data) -- 2733
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 2734
	end -- 2734
	return truncateCommandOutput(table.concat(lines, "\n")) -- 2736
end -- 2719
local function emitGitProgress(mode, operationId, onProgress, status) -- 2739
	if not onProgress then -- 2739
		return -- 2745
	end -- 2745
	local progress = type(status.progress) == "number" and status.progress or nil -- 2746
	local kind = toStr(status.kind) -- 2747
	local message = toStr(status.message) -- 2748
	local state = toStr(status.state) -- 2749
	local jobId = type(status.id) == "number" and status.id or nil -- 2750
	onProgress({ -- 2751
		state = "running", -- 2752
		mode = mode, -- 2753
		operationId = operationId, -- 2754
		stage = kind ~= "" and kind or "git", -- 2755
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 2756
		progress = progress, -- 2757
		jobId = jobId, -- 2758
		gitState = state ~= "" and state or nil, -- 2759
		gitKind = kind ~= "" and kind or nil -- 2760
	}) -- 2760
end -- 2739
local function cloneGitToTarget(req) -- 2764
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2764
		local parsed = parseGitCloneCommand(req.command) -- 2772
		if parsed == nil then -- 2772
			return ____awaiter_resolve(nil, nil) -- 2772
		end -- 2772
		if not parsed.success then -- 2772
			return ____awaiter_resolve(nil, { -- 2772
				success = false, -- 2775
				mode = "git", -- 2775
				output = "", -- 2775
				message = parsed.message, -- 2775
				phase = "validate" -- 2775
			}) -- 2775
		end -- 2775
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 2777
		if not target then -- 2777
			return ____awaiter_resolve(nil, { -- 2777
				success = false, -- 2779
				mode = "git", -- 2779
				output = "", -- 2779
				message = "invalid clone target path", -- 2779
				phase = "validate" -- 2779
			}) -- 2779
		end -- 2779
		if Content:exist(target) then -- 2779
			return ____awaiter_resolve(nil, { -- 2779
				success = false, -- 2782
				mode = "git", -- 2782
				output = "", -- 2782
				message = "target already exists", -- 2782
				phase = "validate" -- 2782
			}) -- 2782
		end -- 2782
		local targetParent = Path:getPath(target) -- 2784
		if not ensureDirPath(targetParent) then -- 2784
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 2784
		end -- 2784
		local tempRoot = getAgentDownloadTempRoot() -- 2788
		if not ensureDirPath(tempRoot) then -- 2788
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 2788
		end -- 2788
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 2792
		Content:remove(tempPath) -- 2793
		local depth = parsed.depth or "1" -- 2794
		local ____array_45 = __TS__SparseArrayNew( -- 2794
			"clone", -- 2796
			quoteGitArg(parsed.url), -- 2797
			quoteGitArg(Path:getFilename(tempPath)), -- 2798
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 2799
				"-b", -- 2799
				quoteGitArg(parsed.ref) -- 2799
			}) or ({})) -- 2799
		) -- 2799
		__TS__SparseArrayPush( -- 2799
			____array_45, -- 2799
			table.unpack(depth ~= "" and ({ -- 2800
				"--depth",
				quoteGitArg(depth) -- 2800
			}) or ({})) -- 2800
		) -- 2800
		local command = table.concat( -- 2795
			{__TS__SparseArraySpread(____array_45)}, -- 2795
			" " -- 2801
		) -- 2801
		local ____this_47 -- 2801
		____this_47 = req -- 2802
		local ____opt_46 = ____this_47.onProgress -- 2802
		if ____opt_46 ~= nil then -- 2802
			____opt_46(____this_47, { -- 2802
				state = "pending", -- 2803
				mode = "git", -- 2804
				operationId = req.operationId, -- 2805
				stage = "clone", -- 2806
				message = "clone pending", -- 2807
				progress = 0 -- 2808
			}) -- 2808
		end -- 2808
		local gitRes = __TS__Await(runGitAndWait( -- 2810
			tempRoot, -- 2811
			command, -- 2812
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2813
			function() -- 2814
				local ____this_49 -- 2814
				____this_49 = req -- 2814
				local ____opt_48 = ____this_49.isCancelled -- 2814
				return (____opt_48 and ____opt_48(____this_49)) == true -- 2814
			end, -- 2814
			req.timeoutSeconds -- 2815
		)) -- 2815
		if not gitRes.success then -- 2815
			local cleanupError = cleanupPath(tempPath) -- 2818
			local ____formatGitStatusOutput_result_53 = formatGitStatusOutput(gitRes.status) -- 2822
			local ____temp_54 = gitRes.message or "git clone failed" -- 2823
			local ____gitRes_interrupted_52 = gitRes.interrupted -- 2824
			if not ____gitRes_interrupted_52 then -- 2824
				local ____this_51 -- 2824
				____this_51 = req -- 2824
				local ____opt_50 = ____this_51.isCancelled -- 2824
				____gitRes_interrupted_52 = (____opt_50 and ____opt_50(____this_51)) == true -- 2824
			end -- 2824
			return ____awaiter_resolve(nil, { -- 2824
				success = false, -- 2820
				mode = "git", -- 2821
				output = ____formatGitStatusOutput_result_53, -- 2822
				message = ____temp_54, -- 2823
				interrupted = ____gitRes_interrupted_52, -- 2824
				cleanupError = cleanupError -- 2825
			}) -- 2825
		end -- 2825
		if not Content:move(tempPath, target) then -- 2825
			local cleanupError = cleanupPath(tempPath) -- 2829
			return ____awaiter_resolve( -- 2829
				nil, -- 2829
				{ -- 2830
					success = false, -- 2830
					mode = "git", -- 2830
					output = formatGitStatusOutput(gitRes.status), -- 2830
					message = "failed to move cloned repository into target path", -- 2830
					cleanupError = cleanupError -- 2830
				} -- 2830
			) -- 2830
		end -- 2830
		if not refreshProjectTree(req.workDir) then -- 2830
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 2833
		end -- 2833
		local commit = getGitHeadCommit(target) -- 2835
		local output = table.concat( -- 2836
			__TS__ArrayFilter( -- 2836
				{ -- 2836
					formatGitStatusOutput(gitRes.status), -- 2837
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 2837
					commit ~= nil and "commit " .. commit or "" -- 2839
				}, -- 2839
				function(____, item) return item ~= "" end -- 2840
			), -- 2840
			"\n" -- 2840
		) -- 2840
		return ____awaiter_resolve( -- 2840
			nil, -- 2840
			{ -- 2841
				success = true, -- 2841
				mode = "git", -- 2841
				output = truncateCommandOutput(output) -- 2841
			} -- 2841
		) -- 2841
	end) -- 2841
end -- 2764
local function loadGitProfile() -- 2844
	local rows -- 2845
	do -- 2845
		local function ____catch() -- 2845
			return true, nil -- 2849
		end -- 2849
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2849
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 2847
		end) -- 2847
		if not ____try then -- 2847
			____hasReturned, ____returnValue = ____catch() -- 2847
		end -- 2847
		if ____hasReturned then -- 2847
			return ____returnValue -- 2846
		end -- 2846
	end -- 2846
	if not rows or not rows[1] then -- 2846
		return nil -- 2851
	end -- 2851
	local name = toStr(rows[1][1]) -- 2852
	local email = toStr(rows[1][2]) -- 2853
	if name == "" and email == "" then -- 2853
		return nil -- 2854
	end -- 2854
	return {name = name, email = email} -- 2855
end -- 2844
local function applyGitProfileToCommit(command) -- 2858
	local args = shellSplit(command) -- 2859
	if args[1] ~= "commit" then -- 2859
		return command -- 2860
	end -- 2860
	local hasName = false -- 2861
	local hasEmail = false -- 2862
	for ____, arg in ipairs(args) do -- 2863
		if arg == "--author-name" then
			hasName = true -- 2864
		end -- 2864
		if arg == "--author-email" then
			hasEmail = true -- 2865
		end -- 2865
	end -- 2865
	if hasName and hasEmail then -- 2865
		return command -- 2867
	end -- 2867
	local profile = loadGitProfile() -- 2868
	if not profile then -- 2868
		return command -- 2869
	end -- 2869
	local additions = {} -- 2870
	if not hasName and profile.name ~= "" then -- 2870
		__TS__ArrayPush( -- 2872
			additions, -- 2872
			"--author-name",
			quoteGitArg(profile.name) -- 2872
		) -- 2872
	end -- 2872
	if not hasEmail and profile.email ~= "" then -- 2872
		__TS__ArrayPush( -- 2875
			additions, -- 2875
			"--author-email",
			quoteGitArg(profile.email) -- 2875
		) -- 2875
	end -- 2875
	if #additions == 0 then -- 2875
		return command -- 2877
	end -- 2877
	return (command .. " ") .. table.concat(additions, " ") -- 2878
end -- 2858
local function executeGitCommand(req) -- 2881
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2881
		local command = normalizeGitCommand(req.command or "") -- 2890
		if command == "" then -- 2890
			return ____awaiter_resolve(nil, { -- 2890
				success = false, -- 2892
				mode = "git", -- 2892
				output = "", -- 2892
				message = "missing command", -- 2892
				phase = "validate" -- 2892
			}) -- 2892
		end -- 2892
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 2894
			workDir = req.workDir, -- 2895
			command = command, -- 2896
			operationId = req.operationId, -- 2897
			timeoutSeconds = req.timeoutSeconds, -- 2898
			onProgress = req.onProgress, -- 2899
			isCancelled = req.isCancelled -- 2900
		})) -- 2900
		if cloneResult ~= nil then -- 2900
			return ____awaiter_resolve(nil, cloneResult) -- 2900
		end -- 2900
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 2903
		if not cwd.success then -- 2903
			return ____awaiter_resolve(nil, { -- 2903
				success = false, -- 2905
				mode = "git", -- 2905
				output = "", -- 2905
				cwd = req.cwd, -- 2905
				message = cwd.message, -- 2905
				phase = "validate" -- 2905
			}) -- 2905
		end -- 2905
		command = applyGitProfileToCommit(command) -- 2907
		local ____this_56 -- 2907
		____this_56 = req -- 2908
		local ____opt_55 = ____this_56.onProgress -- 2908
		if ____opt_55 ~= nil then -- 2908
			____opt_55(____this_56, { -- 2908
				state = "pending", -- 2909
				mode = "git", -- 2910
				operationId = req.operationId, -- 2911
				stage = "git", -- 2912
				message = "git command pending", -- 2913
				progress = 0 -- 2914
			}) -- 2914
		end -- 2914
		local gitRes = __TS__Await(runGitAndWait( -- 2916
			cwd.path, -- 2917
			command, -- 2918
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2919
			function() -- 2920
				local ____this_58 -- 2920
				____this_58 = req -- 2920
				local ____opt_57 = ____this_58.isCancelled -- 2920
				return (____opt_57 and ____opt_57(____this_58)) == true -- 2920
			end, -- 2920
			req.timeoutSeconds -- 2921
		)) -- 2921
		local output = formatGitStatusOutput(gitRes.status) -- 2923
		if not gitRes.success then -- 2923
			local ____output_62 = output -- 2928
			local ____cwd_relative_63 = cwd.relative -- 2929
			local ____temp_64 = gitRes.message or "git command failed" -- 2930
			local ____gitRes_interrupted_61 = gitRes.interrupted -- 2931
			if not ____gitRes_interrupted_61 then -- 2931
				local ____this_60 -- 2931
				____this_60 = req -- 2931
				local ____opt_59 = ____this_60.isCancelled -- 2931
				____gitRes_interrupted_61 = (____opt_59 and ____opt_59(____this_60)) == true -- 2931
			end -- 2931
			return ____awaiter_resolve(nil, { -- 2931
				success = false, -- 2926
				mode = "git", -- 2927
				output = ____output_62, -- 2928
				cwd = ____cwd_relative_63, -- 2929
				message = ____temp_64, -- 2930
				interrupted = ____gitRes_interrupted_61 -- 2931
			}) -- 2931
		end -- 2931
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 2931
	end) -- 2931
end -- 2881
function ____exports.executeCommand(req) -- 2937
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2937
		local mode = req.mode -- 2947
		if mode ~= "lua" and mode ~= "git" then -- 2947
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 2947
		end -- 2947
		if mode == "lua" then -- 2947
			return ____awaiter_resolve( -- 2947
				nil, -- 2947
				executeLuaCommand({ -- 2952
					workDir = req.workDir, -- 2953
					code = req.code or "", -- 2954
					timeoutSeconds = math.max( -- 2955
						1, -- 2955
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 2955
					), -- 2955
					operationId = createOperationId(), -- 2956
					onProgress = req.onProgress, -- 2957
					isCancelled = req.isCancelled -- 2958
				}) -- 2958
			) -- 2958
		end -- 2958
		local operationId = createOperationId() -- 2961
		return ____awaiter_resolve( -- 2961
			nil, -- 2961
			executeGitCommand({ -- 2962
				workDir = req.workDir, -- 2963
				command = req.command or "", -- 2964
				cwd = req.cwd, -- 2965
				timeoutSeconds = math.max( -- 2966
					1, -- 2966
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 2966
				), -- 2966
				operationId = operationId, -- 2967
				onProgress = req.onProgress, -- 2968
				isCancelled = req.isCancelled -- 2969
			}) -- 2969
		) -- 2969
	end) -- 2969
end -- 2937
function ____exports.fetchUrl(req) -- 2973
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2973
		local mode = "download" -- 2980
		local url = __TS__StringTrim(req.url or "") -- 2981
		local targetRel = __TS__StringTrim(req.target or "") -- 2982
		if not isHttpUrl(url) then -- 2982
			return ____awaiter_resolve(nil, { -- 2982
				success = false, -- 2984
				state = "failed", -- 2984
				mode = mode, -- 2984
				target = targetRel, -- 2984
				message = "fetch_url only supports http:// and https:// URLs" -- 2984
			}) -- 2984
		end -- 2984
		if targetRel == "" then -- 2984
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 2984
		end -- 2984
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 2989
		if not target then -- 2989
			return ____awaiter_resolve(nil, { -- 2989
				success = false, -- 2991
				state = "failed", -- 2991
				mode = mode, -- 2991
				target = targetRel, -- 2991
				message = "invalid target path" -- 2991
			}) -- 2991
		end -- 2991
		if Content:exist(target) then -- 2991
			return ____awaiter_resolve(nil, { -- 2991
				success = false, -- 2994
				state = "failed", -- 2994
				mode = mode, -- 2994
				target = targetRel, -- 2994
				message = "target already exists" -- 2994
			}) -- 2994
		end -- 2994
		local operationId = createOperationId() -- 2996
		local tempRoot = getAgentDownloadTempRoot() -- 2997
		if not ensureDirPath(tempRoot) then -- 2997
			return ____awaiter_resolve(nil, { -- 2997
				success = false, -- 2999
				state = "failed", -- 2999
				mode = mode, -- 2999
				target = targetRel, -- 2999
				message = "failed to create agent download temp directory" -- 2999
			}) -- 2999
		end -- 2999
		local tempPath = Path(tempRoot, operationId .. ".download") -- 3001
		Content:remove(tempPath) -- 3002
		local function emitProgress(progress) -- 3003
			if not req.onProgress then -- 3003
				return -- 3004
			end -- 3004
			req:onProgress(__TS__ObjectAssign({ -- 3005
				state = "running", -- 3006
				mode = mode, -- 3007
				operationId = operationId, -- 3008
				target = targetRel, -- 3009
				tempPath = tempPath -- 3010
			}, progress)) -- 3010
		end -- 3003
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 3014
		local function interrupted() -- 3019
			local ____this_66 -- 3019
			____this_66 = req -- 3019
			local ____opt_65 = ____this_66.isCancelled -- 3019
			return (____opt_65 and ____opt_65(____this_66)) == true -- 3019
		end -- 3019
		if not ensureDirForFile(tempPath) then -- 3019
			return ____awaiter_resolve(nil, { -- 3019
				success = false, -- 3021
				state = "failed", -- 3021
				mode = mode, -- 3021
				target = targetRel, -- 3021
				message = "failed to create temporary file directory" -- 3021
			}) -- 3021
		end -- 3021
		local downloadRes = __TS__Await(downloadFile({ -- 3023
			url = url, -- 3024
			tempPath = tempPath, -- 3025
			timeout = 600, -- 3026
			isCancelled = interrupted, -- 3027
			onProgress = function(____, current, total) -- 3028
				local totalNumber = type(total) == "number" and total or 0 -- 3029
				emitProgress({ -- 3030
					stage = "download", -- 3031
					message = "downloading", -- 3032
					current = current, -- 3033
					total = total, -- 3034
					progress = totalNumber > 0 and current / totalNumber or nil -- 3035
				}) -- 3035
			end -- 3028
		})) -- 3028
		if not downloadRes.success then -- 3028
			local cleanupError = cleanupPath(tempPath) -- 3040
			return ____awaiter_resolve( -- 3040
				nil, -- 3040
				{ -- 3041
					success = false, -- 3042
					state = "failed", -- 3043
					mode = mode, -- 3044
					target = targetRel, -- 3045
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 3046
					interrupted = downloadRes.interrupted or interrupted(), -- 3047
					cleanupError = cleanupError -- 3048
				} -- 3048
			) -- 3048
		end -- 3048
		if not ensureDirForFile(target) then -- 3048
			local cleanupError = cleanupPath(tempPath) -- 3052
			return ____awaiter_resolve(nil, { -- 3052
				success = false, -- 3053
				state = "failed", -- 3053
				mode = mode, -- 3053
				target = targetRel, -- 3053
				message = "failed to create target directory", -- 3053
				cleanupError = cleanupError -- 3053
			}) -- 3053
		end -- 3053
		if not Content:move(tempPath, target) then -- 3053
			local cleanupError = cleanupPath(tempPath) -- 3056
			return ____awaiter_resolve(nil, { -- 3056
				success = false, -- 3057
				state = "failed", -- 3057
				mode = mode, -- 3057
				target = targetRel, -- 3057
				message = "failed to move downloaded file into target path", -- 3057
				cleanupError = cleanupError -- 3057
			}) -- 3057
		end -- 3057
		local bytesWritten = downloadRes.bytesWritten -- 3059
		local ____try = __TS__AsyncAwaiter(function() -- 3059
			local size = Content:getAttr(target) -- 3061
			if bytesWritten == nil or bytesWritten <= 0 then -- 3061
				bytesWritten = type(size) == "number" and size or nil -- 3063
			end -- 3063
		end) -- 3063
		____try = ____try.catch( -- 3063
			____try, -- 3063
			function(____, _) -- 3063
				return __TS__AsyncAwaiter(function() -- 3063
				end) -- 3063
			end -- 3063
		) -- 3063
		__TS__Await(____try) -- 3060
		if bytesWritten == nil or bytesWritten <= 0 then -- 3060
			local ____try = __TS__AsyncAwaiter(function() -- 3060
				local loaded = Content:load(target) -- 3070
				if type(loaded) == "string" then -- 3070
					bytesWritten = #loaded -- 3072
				end -- 3072
			end) -- 3072
			____try = ____try.catch( -- 3072
				____try, -- 3072
				function(____, _) -- 3072
					return __TS__AsyncAwaiter(function() -- 3072
					end) -- 3072
				end -- 3072
			) -- 3072
			__TS__Await(____try) -- 3069
		end -- 3069
		if not syncDownloadedFileToWebIDE(target) then -- 3069
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 3079
		end -- 3079
		return ____awaiter_resolve(nil, { -- 3079
			success = true, -- 3081
			state = "done", -- 3081
			mode = mode, -- 3081
			target = targetRel, -- 3081
			bytesWritten = bytesWritten -- 3081
		}) -- 3081
	end) -- 3081
end -- 2973
return ____exports -- 2973