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
function getEngineLogText() -- 1594
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 1595
	if not Content:exist(folder) then -- 1595
		Content:mkdir(folder) -- 1597
	end -- 1597
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 1599
	if not App:saveLog(logPath) then -- 1599
		return nil -- 1601
	end -- 1601
	return Content:load(logPath) -- 1603
end -- 1603
function ensureSafeSearchGlobs(globs) -- 1743
	local result = {} -- 1744
	do -- 1744
		local i = 0 -- 1745
		while i < #globs do -- 1745
			result[#result + 1] = globs[i + 1] -- 1746
			i = i + 1 -- 1745
		end -- 1745
	end -- 1745
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1748
	do -- 1748
		local i = 0 -- 1749
		while i < #requiredExcludes do -- 1749
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1749
				result[#result + 1] = requiredExcludes[i + 1] -- 1751
			end -- 1751
			i = i + 1 -- 1749
		end -- 1749
	end -- 1749
	return result -- 1754
end -- 1754
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
function ____exports.listCheckpointsForTasks(taskIds) -- 1374
	local normalizedTaskIds = {} -- 1375
	local seenTaskIds = {} -- 1376
	do -- 1376
		local i = 0 -- 1377
		while i < #taskIds do -- 1377
			do -- 1377
				local taskId = math.floor(taskIds[i + 1]) -- 1378
				if taskId <= 0 or seenTaskIds[taskId] then -- 1378
					goto __continue279 -- 1379
				end -- 1379
				seenTaskIds[taskId] = true -- 1380
				normalizedTaskIds[#normalizedTaskIds + 1] = taskId -- 1381
			end -- 1381
			::__continue279:: -- 1381
			i = i + 1 -- 1377
		end -- 1377
	end -- 1377
	if #normalizedTaskIds == 0 then -- 1377
		return {} -- 1383
	end -- 1383
	local placeholders = table.concat( -- 1384
		__TS__ArrayMap( -- 1384
			normalizedTaskIds, -- 1384
			function() return "?" end -- 1384
		), -- 1384
		", " -- 1384
	) -- 1384
	local rows = DB:query(((("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id IN (") .. placeholders) .. ")\n\t\tORDER BY task_id DESC, seq DESC", normalizedTaskIds) -- 1385
	if not rows then -- 1385
		return {} -- 1392
	end -- 1392
	local items = {} -- 1393
	do -- 1393
		local i = 0 -- 1394
		while i < #rows do -- 1394
			local row = rows[i + 1] -- 1395
			items[#items + 1] = { -- 1396
				id = row[1], -- 1397
				taskId = row[2], -- 1398
				seq = row[3], -- 1399
				status = toStr(row[4]), -- 1400
				summary = toStr(row[5]), -- 1401
				toolName = toStr(row[6]), -- 1402
				createdAt = row[7] -- 1403
			} -- 1403
			i = i + 1 -- 1394
		end -- 1394
	end -- 1394
	return items -- 1406
end -- 1374
function ____exports.listCheckpoints(taskId) -- 1409
	return ____exports.listCheckpointsForTasks({taskId}) -- 1410
end -- 1409
function ____exports.getCheckpoint(checkpointId) -- 1413
	if checkpointId <= 0 then -- 1413
		return nil -- 1414
	end -- 1414
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE id = ?\n\t\tLIMIT 1", {checkpointId}) -- 1415
	if not rows or #rows == 0 then -- 1415
		return nil -- 1422
	end -- 1422
	local row = rows[1] -- 1423
	return { -- 1424
		id = row[1], -- 1425
		taskId = row[2], -- 1426
		seq = row[3], -- 1427
		status = toStr(row[4]), -- 1428
		summary = toStr(row[5]), -- 1429
		toolName = toStr(row[6]), -- 1430
		createdAt = row[7] -- 1431
	} -- 1431
end -- 1413
local function listCheckpointIdsForTask(taskId, desc) -- 1435
	if desc == nil then -- 1435
		desc = false -- 1435
	end -- 1435
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 1436
	if not rows then -- 1436
		return {} -- 1443
	end -- 1443
	local items = {} -- 1444
	do -- 1444
		local i = 0 -- 1445
		while i < #rows do -- 1445
			local row = rows[i + 1] -- 1446
			items[#items + 1] = {id = row[1], seq = row[2]} -- 1447
			i = i + 1 -- 1445
		end -- 1445
	end -- 1445
	return items -- 1452
end -- 1435
local function deriveFileOp(beforeExists, afterExists) -- 1455
	if not beforeExists and afterExists then -- 1455
		return "create" -- 1456
	end -- 1456
	if beforeExists and not afterExists then -- 1456
		return "delete" -- 1457
	end -- 1457
	return "write" -- 1458
end -- 1455
function ____exports.summarizeTaskChangeSet(taskId) -- 1461
	if not getTaskStatus(taskId) then -- 1461
		return {success = false, message = "task not found"} -- 1463
	end -- 1463
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1465
	local filesByPath = {} -- 1466
	local latestCheckpointId = nil -- 1472
	local latestCheckpointSeq = nil -- 1473
	do -- 1473
		local i = 0 -- 1474
		while i < #checkpoints do -- 1474
			local checkpoint = checkpoints[i + 1] -- 1475
			latestCheckpointId = checkpoint.id -- 1476
			latestCheckpointSeq = checkpoint.seq -- 1477
			local entries = getCheckpointEntries(checkpoint.id, false) -- 1478
			do -- 1478
				local j = 0 -- 1479
				while j < #entries do -- 1479
					local entry = entries[j + 1] -- 1480
					local item = filesByPath[entry.path] -- 1481
					if not item then -- 1481
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 1483
						filesByPath[entry.path] = item -- 1489
					end -- 1489
					item.afterExists = entry.afterExists -- 1491
					local ____item_checkpointIds_16 = item.checkpointIds -- 1491
					____item_checkpointIds_16[#____item_checkpointIds_16 + 1] = checkpoint.id -- 1492
					j = j + 1 -- 1479
				end -- 1479
			end -- 1479
			i = i + 1 -- 1474
		end -- 1474
	end -- 1474
	local files = {} -- 1495
	for ____, item in pairs(filesByPath) do -- 1496
		files[#files + 1] = { -- 1497
			path = item.path, -- 1498
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1499
			checkpointCount = #item.checkpointIds, -- 1500
			checkpointIds = item.checkpointIds -- 1501
		} -- 1501
	end -- 1501
	__TS__ArraySort( -- 1504
		files, -- 1504
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1504
	) -- 1504
	return { -- 1505
		success = true, -- 1506
		taskId = taskId, -- 1507
		checkpointCount = #checkpoints, -- 1508
		filesChanged = #files, -- 1509
		files = files, -- 1510
		latestCheckpointId = latestCheckpointId, -- 1511
		latestCheckpointSeq = latestCheckpointSeq -- 1512
	} -- 1512
end -- 1461
function ____exports.getTaskChangeSetDiff(taskId) -- 1516
	if not getTaskStatus(taskId) then -- 1516
		return {success = false, message = "task not found"} -- 1518
	end -- 1518
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1520
	if #checkpoints == 0 then -- 1520
		return {success = false, message = "change set not found or empty"} -- 1522
	end -- 1522
	local filesByPath = {} -- 1524
	do -- 1524
		local i = 0 -- 1531
		while i < #checkpoints do -- 1531
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 1532
			do -- 1532
				local j = 0 -- 1533
				while j < #entries do -- 1533
					local entry = entries[j + 1] -- 1534
					local item = filesByPath[entry.path] -- 1535
					if not item then -- 1535
						item = { -- 1537
							path = entry.path, -- 1538
							beforeExists = entry.beforeExists, -- 1539
							beforeContent = entry.beforeContent, -- 1540
							afterExists = entry.afterExists, -- 1541
							afterContent = entry.afterContent -- 1542
						} -- 1542
						filesByPath[entry.path] = item -- 1544
					end -- 1544
					item.afterExists = entry.afterExists -- 1546
					item.afterContent = entry.afterContent -- 1547
					j = j + 1 -- 1533
				end -- 1533
			end -- 1533
			i = i + 1 -- 1531
		end -- 1531
	end -- 1531
	local files = {} -- 1550
	for ____, item in pairs(filesByPath) do -- 1551
		files[#files + 1] = { -- 1552
			path = item.path, -- 1553
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1554
			beforeExists = item.beforeExists, -- 1555
			afterExists = item.afterExists, -- 1556
			beforeContent = item.beforeContent, -- 1557
			afterContent = item.afterContent -- 1558
		} -- 1558
	end -- 1558
	__TS__ArraySort( -- 1561
		files, -- 1561
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1561
	) -- 1561
	return {success = true, files = files} -- 1562
end -- 1516
local function readWorkspaceFile(workDir, path, docLanguage) -- 1565
	local engineLog = readEngineLogFile(path) -- 1566
	if engineLog then -- 1566
		return engineLog -- 1567
	end -- 1567
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1568
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 1568
		local attr = inspectReadableFile(fullPath) -- 1570
		if not attr.success then -- 1570
			return attr -- 1571
		end -- 1571
		return { -- 1572
			success = true, -- 1572
			content = Content:load(fullPath), -- 1572
			size = attr.size -- 1572
		} -- 1572
	end -- 1572
	local docPath = resolveAgentDoraDocFilePath(path, docLanguage) -- 1574
	if docPath then -- 1574
		local attr = inspectReadableFile(docPath) -- 1576
		if not attr.success then -- 1576
			return attr -- 1577
		end -- 1577
		return { -- 1578
			success = true, -- 1578
			content = Content:load(docPath), -- 1578
			size = attr.size -- 1578
		} -- 1578
	end -- 1578
	if not fullPath then -- 1578
		return {success = false, message = "invalid path or workDir"} -- 1580
	end -- 1580
	return {success = false, message = "file not found"} -- 1581
end -- 1565
function ____exports.readFileRaw(workDir, path, docLanguage) -- 1584
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 1585
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 1585
		local attr = inspectReadableFile(path) -- 1587
		if not attr.success then -- 1587
			return attr -- 1588
		end -- 1588
		return { -- 1589
			success = true, -- 1589
			content = Content:load(path), -- 1589
			size = attr.size -- 1589
		} -- 1589
	end -- 1589
	return result -- 1591
end -- 1584
function ____exports.getLogs(req) -- 1606
	local text = getEngineLogText() -- 1607
	if text == nil then -- 1607
		return {success = false, message = "failed to read engine logs"} -- 1609
	end -- 1609
	local tailLines = math.max( -- 1611
		1, -- 1611
		math.floor(req and req.tailLines or 200) -- 1611
	) -- 1611
	local allLines = __TS__StringSplit(text, "\n") -- 1612
	local logs = __TS__ArraySlice( -- 1613
		allLines, -- 1613
		math.max(0, #allLines - tailLines) -- 1613
	) -- 1613
	return req and req.joinText and ({ -- 1614
		success = true, -- 1614
		logs = logs, -- 1614
		text = table.concat(logs, "\n") -- 1614
	}) or ({success = true, logs = logs}) -- 1614
end -- 1606
function ____exports.listFiles(req) -- 1617
	local root = req.path or "" -- 1623
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 1624
	if not searchRoot then -- 1624
		return {success = false, message = "invalid path or workDir"} -- 1626
	end -- 1626
	do -- 1626
		local function ____catch(e) -- 1626
			return true, { -- 1644
				success = false, -- 1644
				message = tostring(e) -- 1644
			} -- 1644
		end -- 1644
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1644
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 1629
			local globs = ensureSafeSearchGlobs(userGlobs) -- 1630
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 1631
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 1632
			local totalEntries = #files -- 1633
			local maxEntries = math.max( -- 1634
				1, -- 1634
				math.floor(req.maxEntries or 200) -- 1634
			) -- 1634
			local truncated = totalEntries > maxEntries -- 1635
			return true, { -- 1636
				success = true, -- 1637
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 1638
				totalEntries = totalEntries, -- 1639
				truncated = truncated, -- 1640
				maxEntries = maxEntries -- 1641
			} -- 1641
		end) -- 1641
		if not ____try then -- 1641
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1641
		end -- 1641
		if ____hasReturned then -- 1641
			return ____returnValue -- 1628
		end -- 1628
	end -- 1628
end -- 1617
local function formatReadSlice(content, startLine, endLine) -- 1648
	local lines = __TS__StringSplit(content, "\n") -- 1653
	local totalLines = #lines -- 1654
	if totalLines == 0 then -- 1654
		return { -- 1656
			success = true, -- 1657
			content = "", -- 1658
			totalLines = 0, -- 1659
			startLine = 1, -- 1660
			endLine = 0, -- 1661
			truncated = false -- 1662
		} -- 1662
	end -- 1662
	local rawStart = math.floor(startLine) -- 1665
	local rawEnd = math.floor(endLine) -- 1666
	if rawStart == 0 then -- 1666
		return {success = false, message = "startLine cannot be 0"} -- 1668
	end -- 1668
	if rawEnd == 0 then -- 1668
		return {success = false, message = "endLine cannot be 0"} -- 1671
	end -- 1671
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1673
	if start > totalLines then -- 1673
		return { -- 1677
			success = false, -- 1677
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1677
		} -- 1677
	end -- 1677
	local ____end = math.min( -- 1679
		totalLines, -- 1680
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1681
	) -- 1681
	if ____end < start then -- 1681
		return { -- 1686
			success = false, -- 1687
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1688
		} -- 1688
	end -- 1688
	local slice = {} -- 1691
	do -- 1691
		local i = start -- 1692
		while i <= ____end do -- 1692
			slice[#slice + 1] = lines[i] -- 1693
			i = i + 1 -- 1692
		end -- 1692
	end -- 1692
	local truncated = start > 1 or ____end < totalLines -- 1695
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1696
	local body = table.concat(slice, "\n") -- 1701
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1702
	return { -- 1703
		success = true, -- 1704
		content = output, -- 1705
		totalLines = totalLines, -- 1706
		startLine = start, -- 1707
		endLine = ____end, -- 1708
		truncated = truncated -- 1709
	} -- 1709
end -- 1648
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1713
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1720
	if not fallback.success or fallback.content == nil then -- 1720
		return fallback -- 1721
	end -- 1721
	local resolvedStartLine = startLine or 1 -- 1722
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1723
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1724
end -- 1713
local codeExtensions = { -- 1731
	".lua", -- 1731
	".tl", -- 1731
	".yue", -- 1731
	".ts", -- 1731
	".tsx", -- 1731
	".xml", -- 1731
	".md", -- 1731
	".yarn", -- 1731
	".wa", -- 1731
	".mod" -- 1731
} -- 1731
extensionLevels = { -- 1732
	vs = 2, -- 1733
	bl = 2, -- 1734
	ts = 1, -- 1735
	tsx = 1, -- 1736
	tl = 1, -- 1737
	yue = 1, -- 1738
	xml = 1, -- 1739
	lua = 0 -- 1740
} -- 1740
local function splitSearchPatterns(pattern) -- 1757
	local trimmed = __TS__StringTrim(pattern or "") -- 1758
	if trimmed == "" then -- 1758
		return {} -- 1759
	end -- 1759
	local out = {} -- 1760
	local seen = __TS__New(Set) -- 1761
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1762
		local p = __TS__StringTrim(tostring(p0)) -- 1763
		if p ~= "" and not seen:has(p) then -- 1763
			seen:add(p) -- 1765
			out[#out + 1] = p -- 1766
		end -- 1766
	end -- 1766
	return out -- 1769
end -- 1757
local function splitWhitespaceSearchPatterns(pattern) -- 1772
	local out = {} -- 1773
	local seen = __TS__New(Set) -- 1774
	for p0 in string.gmatch(pattern, "(%S+)") do -- 1775
		local p = __TS__StringTrim(tostring(p0)) -- 1776
		local key = string.lower(p) -- 1777
		if p ~= "" and not seen:has(key) then -- 1777
			seen:add(key) -- 1779
			out[#out + 1] = p -- 1780
		end -- 1780
	end -- 1780
	return out -- 1783
end -- 1772
local function mergeSearchFileResultsUnique(resultsList) -- 1786
	local merged = {} -- 1787
	local seen = __TS__New(Set) -- 1788
	do -- 1788
		local i = 0 -- 1789
		while i < #resultsList do -- 1789
			local list = resultsList[i + 1] -- 1790
			do -- 1790
				local j = 0 -- 1791
				while j < #list do -- 1791
					do -- 1791
						local row = list[j + 1] -- 1792
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1793
						if seen:has(key) then -- 1793
							goto __continue362 -- 1794
						end -- 1794
						seen:add(key) -- 1795
						merged[#merged + 1] = list[j + 1] -- 1796
					end -- 1796
					::__continue362:: -- 1796
					j = j + 1 -- 1791
				end -- 1791
			end -- 1791
			i = i + 1 -- 1789
		end -- 1789
	end -- 1789
	return merged -- 1799
end -- 1786
local function buildGroupedSearchResults(results) -- 1802
	local order = {} -- 1807
	local grouped = __TS__New(Map) -- 1808
	do -- 1808
		local i = 0 -- 1813
		while i < #results do -- 1813
			local row = results[i + 1] -- 1814
			local file = row.file -- 1815
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1816
			local bucket = grouped:get(key) -- 1817
			if not bucket then -- 1817
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1819
				grouped:set(key, bucket) -- 1820
				order[#order + 1] = key -- 1821
			end -- 1821
			bucket.totalMatches = bucket.totalMatches + 1 -- 1823
			local ____bucket_matches_21 = bucket.matches -- 1823
			____bucket_matches_21[#____bucket_matches_21 + 1] = results[i + 1] -- 1824
			i = i + 1 -- 1813
		end -- 1813
	end -- 1813
	local out = {} -- 1826
	do -- 1826
		local i = 0 -- 1831
		while i < #order do -- 1831
			local bucket = grouped:get(order[i + 1]) -- 1832
			if bucket then -- 1832
				out[#out + 1] = bucket -- 1833
			end -- 1833
			i = i + 1 -- 1831
		end -- 1831
	end -- 1831
	return out -- 1835
end -- 1802
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1838
	local merged = {} -- 1839
	local seen = __TS__New(Set) -- 1840
	local index = 0 -- 1841
	local advanced = true -- 1842
	while advanced do -- 1842
		advanced = false -- 1844
		do -- 1844
			local i = 0 -- 1845
			while i < #resultsList do -- 1845
				do -- 1845
					local list = resultsList[i + 1] -- 1846
					if index >= #list then -- 1846
						goto __continue374 -- 1847
					end -- 1847
					advanced = true -- 1848
					local row = list[index + 1] -- 1849
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1850
					if seen:has(key) then -- 1850
						goto __continue374 -- 1851
					end -- 1851
					seen:add(key) -- 1852
					merged[#merged + 1] = row -- 1853
				end -- 1853
				::__continue374:: -- 1853
				i = i + 1 -- 1845
			end -- 1845
		end -- 1845
		index = index + 1 -- 1855
	end -- 1855
	return merged -- 1857
end -- 1838
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1860
	if docSource ~= "api" then -- 1860
		return 100 -- 1861
	end -- 1861
	if programmingLanguage ~= "tsx" then -- 1861
		return 100 -- 1862
	end -- 1862
	repeat -- 1862
		local ____switch380 = string.lower(Path:getFilename(file)) -- 1862
		local ____cond380 = ____switch380 == "jsx.d.ts" -- 1862
		if ____cond380 then -- 1862
			return 0 -- 1864
		end -- 1864
		____cond380 = ____cond380 or ____switch380 == "dorax.d.ts" -- 1864
		if ____cond380 then -- 1864
			return 1 -- 1865
		end -- 1865
		____cond380 = ____cond380 or ____switch380 == "dora.d.ts" -- 1865
		if ____cond380 then -- 1865
			return 2 -- 1866
		end -- 1866
		do -- 1866
			return 100 -- 1867
		end -- 1867
	until true -- 1867
end -- 1860
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1871
	local sorted = __TS__ArraySlice(hits) -- 1876
	__TS__ArraySort( -- 1877
		sorted, -- 1877
		function(____, a, b) -- 1877
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1878
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1879
			if pa ~= pb then -- 1879
				return pa - pb -- 1880
			end -- 1880
			local fa = string.lower(a.file) -- 1881
			local fb = string.lower(b.file) -- 1882
			if fa ~= fb then -- 1882
				return fa < fb and -1 or 1 -- 1883
			end -- 1883
			return (a.line or 0) - (b.line or 0) -- 1884
		end -- 1877
	) -- 1877
	return sorted -- 1886
end -- 1871
function ____exports.searchFiles(req) -- 1889
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1889
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1902
		if not resolvedPath then -- 1902
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1902
		end -- 1902
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1906
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1907
		if not searchRoot then -- 1907
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1907
		end -- 1907
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1907
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1907
		end -- 1907
		local patterns = splitSearchPatterns(req.pattern) -- 1914
		if #patterns == 0 then -- 1914
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1914
		end -- 1914
		return ____awaiter_resolve( -- 1914
			nil, -- 1914
			__TS__New( -- 1918
				__TS__Promise, -- 1918
				function(____, resolve) -- 1918
					Director.systemScheduler:schedule(once(function() -- 1919
						do -- 1919
							local function ____catch(e) -- 1919
								resolve( -- 1961
									nil, -- 1961
									{ -- 1961
										success = false, -- 1961
										message = tostring(e) -- 1961
									} -- 1961
								) -- 1961
							end -- 1961
							local ____try, ____hasReturned = pcall(function() -- 1961
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1921
								local allResults = {} -- 1924
								do -- 1924
									local i = 0 -- 1925
									while i < #patterns do -- 1925
										local ____Content_26 = Content -- 1926
										local ____Content_searchFilesAsync_27 = Content.searchFilesAsync -- 1926
										local ____patterns_index_25 = patterns[i + 1] -- 1931
										local ____req_useRegex_22 = req.useRegex -- 1932
										if ____req_useRegex_22 == nil then -- 1932
											____req_useRegex_22 = false -- 1932
										end -- 1932
										local ____req_caseSensitive_23 = req.caseSensitive -- 1933
										if ____req_caseSensitive_23 == nil then -- 1933
											____req_caseSensitive_23 = false -- 1933
										end -- 1933
										local ____req_includeContent_24 = req.includeContent -- 1934
										if ____req_includeContent_24 == nil then -- 1934
											____req_includeContent_24 = true -- 1934
										end -- 1934
										allResults[#allResults + 1] = ____Content_searchFilesAsync_27( -- 1926
											____Content_26, -- 1926
											searchRoot, -- 1927
											codeExtensions, -- 1928
											extensionLevels, -- 1929
											searchGlobs, -- 1930
											____patterns_index_25, -- 1931
											____req_useRegex_22, -- 1932
											____req_caseSensitive_23, -- 1933
											____req_includeContent_24, -- 1934
											req.contentWindow or 120 -- 1935
										) -- 1935
										i = i + 1 -- 1925
									end -- 1925
								end -- 1925
								local results = mergeSearchFileResultsUnique(allResults) -- 1938
								local totalResults = #results -- 1939
								local limit = math.max( -- 1940
									1, -- 1940
									math.floor(req.limit or 20) -- 1940
								) -- 1940
								local offset = math.max( -- 1941
									0, -- 1941
									math.floor(req.offset or 0) -- 1941
								) -- 1941
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1942
								local nextOffset = offset + #paged -- 1943
								local hasMore = nextOffset < totalResults -- 1944
								local truncated = offset > 0 or hasMore -- 1945
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1946
								local groupByFile = req.groupByFile == true -- 1947
								resolve( -- 1948
									nil, -- 1948
									{ -- 1948
										success = true, -- 1949
										results = relativeResults, -- 1950
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1951
										totalResults = totalResults, -- 1952
										truncated = truncated, -- 1953
										limit = limit, -- 1954
										offset = offset, -- 1955
										nextOffset = nextOffset, -- 1956
										hasMore = hasMore, -- 1957
										groupByFile = groupByFile -- 1958
									} -- 1958
								) -- 1958
							end) -- 1958
							if not ____try then -- 1958
								____catch(____hasReturned) -- 1958
							end -- 1958
						end -- 1958
					end)) -- 1919
				end -- 1918
			) -- 1918
		) -- 1918
	end) -- 1918
end -- 1889
function ____exports.searchDoraAPI(req) -- 1967
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1967
		local pattern = __TS__StringTrim(req.pattern or "") -- 1978
		if pattern == "" then -- 1978
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1978
		end -- 1978
		local patterns = splitSearchPatterns(pattern) -- 1980
		if #patterns == 0 then -- 1980
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1980
		end -- 1980
		local docSource = req.docSource or "api" -- 1982
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1983
		local docRoot = target.root -- 1984
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1985
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1985
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1985
		end -- 1985
		local exts = target.exts -- 1989
		local dotExts = __TS__ArrayMap( -- 1990
			exts, -- 1990
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1990
		) -- 1990
		local globs = target.globs -- 1991
		local limit = math.max( -- 1992
			1, -- 1992
			math.floor(req.limit or 10) -- 1992
		) -- 1992
		return ____awaiter_resolve( -- 1992
			nil, -- 1992
			__TS__New( -- 1994
				__TS__Promise, -- 1994
				function(____, resolve) -- 1994
					Director.systemScheduler:schedule(once(function() -- 1995
						do -- 1995
							local function ____catch(e) -- 1995
								resolve( -- 2075
									nil, -- 2075
									{ -- 2075
										success = false, -- 2075
										message = tostring(e) -- 2075
									} -- 2075
								) -- 2075
							end -- 2075
							local ____try, ____hasReturned = pcall(function() -- 2075
								local allHits = {} -- 1997
								do -- 1997
									local p = 0 -- 1998
									while p < #patterns do -- 1998
										local ____Content_32 = Content -- 1999
										local ____Content_searchFilesAsync_33 = Content.searchFilesAsync -- 1999
										local ____array_31 = __TS__SparseArrayNew( -- 1999
											docRoot, -- 2000
											dotExts, -- 2001
											{}, -- 2002
											ensureSafeSearchGlobs(globs), -- 2003
											patterns[p + 1] -- 2004
										) -- 2004
										local ____req_useRegex_28 = req.useRegex -- 2005
										if ____req_useRegex_28 == nil then -- 2005
											____req_useRegex_28 = false -- 2005
										end -- 2005
										__TS__SparseArrayPush(____array_31, ____req_useRegex_28) -- 2005
										local ____req_caseSensitive_29 = req.caseSensitive -- 2006
										if ____req_caseSensitive_29 == nil then -- 2006
											____req_caseSensitive_29 = false -- 2006
										end -- 2006
										__TS__SparseArrayPush(____array_31, ____req_caseSensitive_29) -- 2006
										local ____req_includeContent_30 = req.includeContent -- 2007
										if ____req_includeContent_30 == nil then -- 2007
											____req_includeContent_30 = true -- 2007
										end -- 2007
										__TS__SparseArrayPush(____array_31, ____req_includeContent_30, req.contentWindow or 80) -- 2007
										local raw = ____Content_searchFilesAsync_33( -- 1999
											____Content_32, -- 1999
											__TS__SparseArraySpread(____array_31) -- 1999
										) -- 1999
										local hits = {} -- 2010
										do -- 2010
											local i = 0 -- 2011
											while i < #raw do -- 2011
												do -- 2011
													local row = raw[i + 1] -- 2012
													local file = toDocRelativePath(resultBaseRoot, row.file, docSource) -- 2013
													if file == "" then -- 2013
														goto __continue407 -- 2014
													end -- 2014
													hits[#hits + 1] = { -- 2015
														file = file, -- 2016
														line = type(row.line) == "number" and row.line or nil, -- 2017
														content = type(row.content) == "string" and row.content or nil -- 2018
													} -- 2018
												end -- 2018
												::__continue407:: -- 2018
												i = i + 1 -- 2011
											end -- 2011
										end -- 2011
										allHits[#allHits + 1] = __TS__ArraySlice( -- 2021
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 2021
											0, -- 2021
											limit -- 2021
										) -- 2021
										p = p + 1 -- 1998
									end -- 1998
								end -- 1998
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 2023
								local fallbackPatterns -- 2024
								if #hits == 0 and #patterns == 1 and req.useRegex ~= true and (string.find(pattern, "|", nil, true) or 0) - 1 < 0 then -- 2024
									local terms = splitWhitespaceSearchPatterns(pattern) -- 2029
									if #terms > 1 then -- 2029
										fallbackPatterns = terms -- 2031
										local fallbackHits = {} -- 2032
										do -- 2032
											local p = 0 -- 2033
											while p < #terms do -- 2033
												local ____Content_37 = Content -- 2034
												local ____Content_searchFilesAsync_38 = Content.searchFilesAsync -- 2034
												local ____array_36 = __TS__SparseArrayNew( -- 2034
													docRoot, -- 2035
													dotExts, -- 2036
													{}, -- 2037
													ensureSafeSearchGlobs(globs), -- 2038
													terms[p + 1], -- 2039
													false -- 2040
												) -- 2040
												local ____req_caseSensitive_34 = req.caseSensitive -- 2041
												if ____req_caseSensitive_34 == nil then -- 2041
													____req_caseSensitive_34 = false -- 2041
												end -- 2041
												__TS__SparseArrayPush(____array_36, ____req_caseSensitive_34) -- 2041
												local ____req_includeContent_35 = req.includeContent -- 2042
												if ____req_includeContent_35 == nil then -- 2042
													____req_includeContent_35 = true -- 2042
												end -- 2042
												__TS__SparseArrayPush(____array_36, ____req_includeContent_35, req.contentWindow or 80) -- 2042
												local raw = ____Content_searchFilesAsync_38( -- 2034
													____Content_37, -- 2034
													__TS__SparseArraySpread(____array_36) -- 2034
												) -- 2034
												local termHits = {} -- 2045
												do -- 2045
													local i = 0 -- 2046
													while i < #raw do -- 2046
														do -- 2046
															local row = raw[i + 1] -- 2047
															local file = toDocRelativePath(resultBaseRoot, row.file, docSource) -- 2048
															if file == "" then -- 2048
																goto __continue414 -- 2049
															end -- 2049
															termHits[#termHits + 1] = { -- 2050
																file = file, -- 2051
																line = type(row.line) == "number" and row.line or nil, -- 2052
																content = type(row.content) == "string" and row.content or nil -- 2053
															} -- 2053
														end -- 2053
														::__continue414:: -- 2053
														i = i + 1 -- 2046
													end -- 2046
												end -- 2046
												fallbackHits[#fallbackHits + 1] = __TS__ArraySlice( -- 2056
													sortDoraAPISearchHits(termHits, docSource, req.programmingLanguage), -- 2056
													0, -- 2056
													limit -- 2056
												) -- 2056
												p = p + 1 -- 2033
											end -- 2033
										end -- 2033
										hits = mergeDoraAPISearchHitsUnique(fallbackHits) -- 2058
									end -- 2058
								end -- 2058
								resolve(nil, { -- 2061
									success = true, -- 2062
									docSource = docSource, -- 2063
									docLanguage = req.docLanguage, -- 2064
									programmingLanguage = req.programmingLanguage, -- 2065
									exts = exts, -- 2066
									results = hits, -- 2067
									hint = "Use read_file directly with the namespaced file value from a search result to view the complete authoritative document.", -- 2068
									totalResults = #hits, -- 2069
									truncated = false, -- 2070
									limit = limit, -- 2071
									fallbackPatterns = fallbackPatterns -- 2072
								}) -- 2072
							end) -- 2072
							if not ____try then -- 2072
								____catch(____hasReturned) -- 2072
							end -- 2072
						end -- 2072
					end)) -- 1995
				end -- 1994
			) -- 1994
		) -- 1994
	end) -- 1994
end -- 1967
function ____exports.searchDoraAPIHttp(req, callback) -- 2081
	local ____self_39 = ____exports.searchDoraAPI(req) -- 2081
	____self_39["then"]( -- 2081
		____self_39, -- 2081
		function(____, result) return callback(result) end -- 2092
	) -- 2092
end -- 2081
function ____exports.readDoraDoc(req) -- 2095
	local requestedFile = table.concat( -- 2101
		__TS__StringSplit(req.file or "", "\\"), -- 2101
		"/" -- 2101
	) -- 2101
	local file = requestedFile -- 2102
	local namespacedSource = nil -- 2103
	if __TS__StringStartsWith(requestedFile, AGENT_DORA_DOC_PREFIX) then -- 2103
		local namespaced = __TS__StringSlice(requestedFile, #AGENT_DORA_DOC_PREFIX) -- 2105
		if __TS__StringStartsWith(namespaced, "api/") then -- 2105
			namespacedSource = "api" -- 2107
			file = string.sub(namespaced, 5) -- 2108
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 2108
			namespacedSource = "tutorial" -- 2110
			file = string.sub(namespaced, 10) -- 2111
		else -- 2111
			return {success = false, message = "invalid Dora doc namespace"} -- 2113
		end -- 2113
	end -- 2113
	if not isValidWorkspacePath(file) or file == "." then -- 2113
		return {success = false, message = "invalid file"} -- 2117
	end -- 2117
	local lowerFile = string.lower(file) -- 2119
	local isTutorialDoc = __TS__StringEndsWith(lowerFile, ".md") -- 2120
	local isAPIDoc = __TS__StringEndsWith(lowerFile, ".ts") or __TS__StringEndsWith(lowerFile, ".tl") -- 2121
	if not isTutorialDoc and not isAPIDoc then -- 2121
		return {success = false, message = "unsupported doc file type"} -- 2122
	end -- 2122
	local docSource = namespacedSource or (isTutorialDoc and "tutorial" or "api") -- 2123
	local root = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 2124
	local fullPath = Path(root, file) -- 2125
	local relative = Path:getRelative(fullPath, root) -- 2126
	if relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 2126
		return {success = false, message = "invalid file"} -- 2128
	end -- 2128
	local readResult = ____exports.readFile(root, file, req.startLine or 1, req.endLine or -1) -- 2130
	if not readResult.success then -- 2130
		return readResult -- 2131
	end -- 2131
	return { -- 2132
		success = true, -- 2133
		docLanguage = req.docLanguage, -- 2134
		file = file, -- 2135
		content = readResult.content, -- 2136
		startLine = readResult.startLine, -- 2137
		endLine = readResult.endLine -- 2138
	} -- 2138
end -- 2095
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 2142
	if options == nil then -- 2142
		options = {} -- 2142
	end -- 2142
	if #changes == 0 then -- 2142
		return {success = false, message = "empty changes"} -- 2144
	end -- 2144
	if not isValidWorkDir(workDir) then -- 2144
		return {success = false, message = "invalid workDir"} -- 2147
	end -- 2147
	if not getTaskStatus(taskId) then -- 2147
		return {success = false, message = "task not found"} -- 2150
	end -- 2150
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 2152
	local dup = rejectDuplicatePaths(expandedChanges) -- 2153
	if dup then -- 2153
		return {success = false, message = "duplicate path in batch: " .. dup} -- 2155
	end -- 2155
	for ____, change in ipairs(expandedChanges) do -- 2158
		if not isValidWorkspacePath(change.path) then -- 2158
			return {success = false, message = "invalid path: " .. change.path} -- 2160
		end -- 2160
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 2160
			return {success = false, message = "missing content for " .. change.path} -- 2163
		end -- 2163
	end -- 2163
	local headSeq = getTaskHeadSeq(taskId) -- 2167
	if headSeq == nil then -- 2167
		return {success = false, message = "task not found"} -- 2168
	end -- 2168
	local nextSeq = headSeq + 1 -- 2169
	local checkpointId = insertCheckpoint( -- 2170
		taskId, -- 2170
		nextSeq, -- 2170
		options.summary or "", -- 2170
		options.toolName or "", -- 2170
		"PREPARED" -- 2170
	) -- 2170
	if checkpointId <= 0 then -- 2170
		return {success = false, message = "failed to create checkpoint"} -- 2172
	end -- 2172
	do -- 2172
		local i = 0 -- 2175
		while i < #expandedChanges do -- 2175
			local change = expandedChanges[i + 1] -- 2176
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 2177
			if not fullPath then -- 2177
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2179
				return {success = false, message = "invalid path: " .. change.path} -- 2180
			end -- 2180
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 2180
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2183
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 2184
			end -- 2184
			local before = getFileState(fullPath) -- 2186
			local afterExists = change.op ~= "delete" -- 2187
			local afterContent = afterExists and (change.content or "") or "" -- 2188
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 2189
				checkpointId, -- 2193
				i + 1, -- 2194
				change.path, -- 2195
				change.op, -- 2196
				before.exists and 1 or 0, -- 2197
				before.content, -- 2198
				afterExists and 1 or 0, -- 2199
				afterContent, -- 2200
				before.bytes, -- 2201
				#afterContent -- 2202
			}) -- 2202
			if inserted <= 0 then -- 2202
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2206
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 2207
			end -- 2207
			i = i + 1 -- 2175
		end -- 2175
	end -- 2175
	local appliedCount = 0 -- 2211
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 2212
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2213
		if not fullPath then -- 2213
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2215
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2216
			return {success = false, message = ("invalid path: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2217
		end -- 2217
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 2219
		if not ok then -- 2219
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2221
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount + 1) -- 2222
			return {success = false, message = ("failed to apply file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2223
		end -- 2223
		appliedCount = appliedCount + 1 -- 2225
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 2225
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2227
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2228
			return {success = false, message = ("failed to sync file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; all applied files restored")} -- 2229
		end -- 2229
	end -- 2229
	DB:exec( -- 2233
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 2233
		{ -- 2235
			"APPLIED", -- 2235
			now(), -- 2235
			checkpointId -- 2235
		} -- 2235
	) -- 2235
	DB:exec( -- 2237
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 2237
		{ -- 2239
			nextSeq, -- 2239
			now(), -- 2239
			taskId -- 2239
		} -- 2239
	) -- 2239
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 2241
end -- 2142
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 2249
	if not isValidWorkDir(workDir) then -- 2249
		return {success = false, message = "invalid workDir"} -- 2250
	end -- 2250
	if checkpointId <= 0 then -- 2250
		return {success = false, message = "invalid checkpointId"} -- 2251
	end -- 2251
	local entries = getCheckpointEntries(checkpointId, true) -- 2252
	if #entries == 0 then -- 2252
		return {success = false, message = "checkpoint not found or empty"} -- 2254
	end -- 2254
	for ____, entry in ipairs(entries) do -- 2256
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2257
		if not fullPath then -- 2257
			return {success = false, message = "invalid path: " .. entry.path} -- 2259
		end -- 2259
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 2261
		if not ok then -- 2261
			Log( -- 2263
				"Error", -- 2263
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2263
			) -- 2263
			Log( -- 2264
				"Info", -- 2264
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2264
			) -- 2264
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 2265
		end -- 2265
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 2265
			Log( -- 2268
				"Error", -- 2268
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2268
			) -- 2268
			Log( -- 2269
				"Info", -- 2269
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2269
			) -- 2269
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 2270
		end -- 2270
	end -- 2270
	DB:exec( -- 2273
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 2273
		{ -- 2273
			"REVERTED", -- 2273
			now(), -- 2273
			checkpointId -- 2273
		} -- 2273
	) -- 2273
	return {success = true, checkpointId = checkpointId} -- 2274
end -- 2249
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 2277
	if not isValidWorkDir(workDir) then -- 2277
		return {success = false, message = "invalid workDir"} -- 2278
	end -- 2278
	if not getTaskStatus(taskId) then -- 2278
		return {success = false, message = "task not found"} -- 2279
	end -- 2279
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 2280
	if #checkpoints == 0 then -- 2280
		return {success = false, message = "change set not found or empty"} -- 2282
	end -- 2282
	local lastCheckpointId = 0 -- 2284
	do -- 2284
		local i = 0 -- 2285
		while i < #checkpoints do -- 2285
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 2286
			if not result.success then -- 2286
				return {success = false, message = result.message} -- 2287
			end -- 2287
			lastCheckpointId = checkpoints[i + 1].id -- 2288
			i = i + 1 -- 2285
		end -- 2285
	end -- 2285
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 2290
end -- 2277
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 2298
	return getCheckpointEntries(checkpointId, false) -- 2299
end -- 2298
function ____exports.getCheckpointDiff(checkpointId) -- 2302
	if checkpointId <= 0 then -- 2302
		return {success = false, message = "invalid checkpointId"} -- 2304
	end -- 2304
	local entries = getCheckpointEntries(checkpointId, false) -- 2306
	if #entries == 0 then -- 2306
		return {success = false, message = "checkpoint not found or empty"} -- 2308
	end -- 2308
	return { -- 2310
		success = true, -- 2311
		files = __TS__ArrayMap( -- 2312
			entries, -- 2312
			function(____, entry) return { -- 2312
				path = entry.path, -- 2313
				op = entry.op, -- 2314
				beforeExists = entry.beforeExists, -- 2315
				afterExists = entry.afterExists, -- 2316
				beforeContent = entry.beforeContent, -- 2317
				afterContent = entry.afterContent -- 2318
			} end -- 2318
		) -- 2318
	} -- 2318
end -- 2302
local function finalizeBuildResult(workDir, messages) -- 2323
	local normalized = __TS__ArrayMap( -- 2324
		messages, -- 2324
		function(____, m) return m.success and __TS__ObjectAssign( -- 2324
			{}, -- 2325
			m, -- 2325
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2325
		) or __TS__ObjectAssign( -- 2325
			{}, -- 2326
			m, -- 2326
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2326
		) end -- 2326
	) -- 2326
	local total = #normalized -- 2327
	local failed = 0 -- 2328
	do -- 2328
		local i = 0 -- 2329
		while i < #normalized do -- 2329
			if not normalized[i + 1].success then -- 2329
				failed = failed + 1 -- 2330
			end -- 2330
			i = i + 1 -- 2329
		end -- 2329
	end -- 2329
	local passed = total - failed -- 2332
	if failed > 0 then -- 2332
		return { -- 2334
			success = false, -- 2335
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 2336
			total = total, -- 2337
			passed = passed, -- 2338
			failed = failed, -- 2339
			messages = normalized -- 2340
		} -- 2340
	end -- 2340
	return { -- 2343
		success = true, -- 2344
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 2345
		total = total, -- 2346
		passed = passed, -- 2347
		failed = 0, -- 2348
		messages = normalized -- 2349
	} -- 2349
end -- 2323
function ____exports.build(req) -- 2353
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2353
		local targetRel = req.path or "" -- 2354
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2355
		if not target then -- 2355
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2355
		end -- 2355
		if not Content:exist(target) then -- 2355
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2355
		end -- 2355
		local messages = {} -- 2362
		if not Content:isdir(target) then -- 2362
			local kind = getSupportedBuildKind(target) -- 2364
			if not kind then -- 2364
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2364
			end -- 2364
			if kind == "ts" then -- 2364
				local content = Content:load(target) -- 2369
				if content == nil then -- 2369
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2369
				end -- 2369
				if isTiledEditorContent(content) then -- 2369
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2374
					return ____awaiter_resolve( -- 2374
						nil, -- 2374
						finalizeBuildResult(req.workDir, messages) -- 2375
					) -- 2375
				end -- 2375
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2375
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2375
				end -- 2375
				if not isDtsFile(target) then -- 2375
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir)) -- 2381
				end -- 2381
			else -- 2381
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2384
			end -- 2384
			Log( -- 2386
				"Info", -- 2386
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2386
			) -- 2386
			return ____awaiter_resolve( -- 2386
				nil, -- 2386
				finalizeBuildResult(req.workDir, messages) -- 2387
			) -- 2387
		end -- 2387
		local listResult = ____exports.listFiles({ -- 2389
			workDir = req.workDir, -- 2390
			path = targetRel, -- 2391
			globs = __TS__ArrayMap( -- 2392
				codeExtensions, -- 2392
				function(____, e) return "**/*" .. e end -- 2392
			), -- 2392
			maxEntries = 10000 -- 2393
		}) -- 2393
		local relFiles = listResult.success and listResult.files or ({}) -- 2396
		local tsFileData = {} -- 2397
		local buildQueue = {} -- 2398
		for ____, rel in ipairs(relFiles) do -- 2399
			do -- 2399
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2400
				local kind = getSupportedBuildKind(file) -- 2401
				if not kind then -- 2401
					goto __continue488 -- 2402
				end -- 2402
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2403
				if kind ~= "ts" then -- 2403
					goto __continue488 -- 2405
				end -- 2405
				local content = Content:load(file) -- 2407
				if content == nil then -- 2407
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2409
					goto __continue488 -- 2410
				end -- 2410
				if isTiledEditorContent(content) then -- 2410
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2413
					goto __continue488 -- 2414
				end -- 2414
				tsFileData[file] = content -- 2416
			end -- 2416
			::__continue488:: -- 2416
		end -- 2416
		do -- 2416
			local i = 0 -- 2418
			while i < #buildQueue do -- 2418
				do -- 2418
					local ____buildQueue_index_40 = buildQueue[i + 1] -- 2419
					local file = ____buildQueue_index_40.file -- 2419
					local kind = ____buildQueue_index_40.kind -- 2419
					if kind == "ts" then -- 2419
						local content = tsFileData[file] -- 2421
						if content == nil or isDtsFile(file) then -- 2421
							goto __continue495 -- 2423
						end -- 2423
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2423
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2426
							goto __continue495 -- 2427
						end -- 2427
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir)) -- 2429
						goto __continue495 -- 2430
					end -- 2430
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2432
				end -- 2432
				::__continue495:: -- 2432
				i = i + 1 -- 2418
			end -- 2418
		end -- 2418
		if #messages == 0 then -- 2418
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2435
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2435
		end -- 2435
		Log( -- 2438
			"Info", -- 2438
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2438
		) -- 2438
		return ____awaiter_resolve( -- 2438
			nil, -- 2438
			finalizeBuildResult(req.workDir, messages) -- 2439
		) -- 2439
	end) -- 2439
end -- 2353
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2442
local EXECUTE_COMMAND_ERROR_MAX = 4000 -- 2443
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 2444
local agentEntryRuntimeOwner = "" -- 2445
local function truncateCommandOutput(output) -- 2447
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2447
		return output -- 2448
	end -- 2448
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2449
end -- 2447
local function truncateCommandError(message) -- 2452
	if #message <= EXECUTE_COMMAND_ERROR_MAX then -- 2452
		return message -- 2453
	end -- 2453
	return __TS__StringSlice(message, 0, EXECUTE_COMMAND_ERROR_MAX) .. "\n... error message truncated ..." -- 2454
end -- 2452
local function executeLuaCommand(req) -- 2457
	local code = __TS__StringTrim(req.code or "") -- 2465
	if code == "" then -- 2465
		return __TS__Promise.resolve({ -- 2467
			success = false, -- 2467
			mode = "lua", -- 2467
			output = "", -- 2467
			message = "missing code", -- 2467
			phase = "validate" -- 2467
		}) -- 2467
	end -- 2467
	local output = {} -- 2469
	local entry = require("Script.Dev.Entry") -- 2470
	local ownsEntryRuntime = false -- 2471
	local entryObjectBaseline = 0 -- 2472
	local entryLuaRefBaseline = 0 -- 2473
	local function acquireEntryRuntime() -- 2474
		if agentEntryRuntimeOwner ~= "" and agentEntryRuntimeOwner ~= req.operationId then -- 2474
			error("Dora entry runtime is busy with another Agent command") -- 2476
		end -- 2476
		agentEntryRuntimeOwner = req.operationId -- 2478
		ownsEntryRuntime = true -- 2479
	end -- 2474
	local function stopOwnedEntry() -- 2481
		if not ownsEntryRuntime then -- 2481
			return nil -- 2482
		end -- 2482
		local cleanupError -- 2483
		do -- 2483
			local function ____catch(e) -- 2483
				cleanupError = "failed to stop Agent test entry: " .. tostring(e) -- 2487
			end -- 2487
			local ____try, ____hasReturned = pcall(function() -- 2487
				entry.stop() -- 2485
			end) -- 2485
			if not ____try then -- 2485
				____catch(____hasReturned) -- 2485
			end -- 2485
		end -- 2485
		ownsEntryRuntime = false -- 2489
		if agentEntryRuntimeOwner == req.operationId then -- 2489
			agentEntryRuntimeOwner = "" -- 2491
		end -- 2491
		return cleanupError -- 2493
	end -- 2481
	local function startEntryWatchdog() -- 2495
		entryObjectBaseline = Dora.Object.count -- 2496
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 2497
	end -- 2495
	local function checkEntryWatchdog() -- 2499
		if not ownsEntryRuntime then -- 2499
			return nil -- 2500
		end -- 2500
		local objectCount = Dora.Object.count -- 2501
		local luaRefCount = Dora.Object.luaRefCount -- 2502
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 2503
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 2504
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 2505
		if not exceededTotal then -- 2505
			return nil -- 2508
		end -- 2508
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 2509
	end -- 2499
	local function normalizeEntryFile(value) -- 2513
		if not value or type(value) ~= "table" then -- 2513
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 2515
		end -- 2515
		local descriptor = value -- 2517
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 2518
		if relativeFile == "" then -- 2518
			relativeFile = "init" -- 2519
		end -- 2519
		if not isValidWorkspacePath(relativeFile) then -- 2519
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 2521
		end -- 2521
		local fileName = Path(req.workDir, relativeFile) -- 2523
		local ext = Path:getExt(fileName) -- 2524
		if ext ~= "" then -- 2524
			fileName = Path:replaceExt(fileName, "") -- 2525
		end -- 2525
		local luaFile = Path:replaceExt(fileName, "lua") -- 2526
		if not Content:exist(luaFile) then -- 2526
			error("Agent test entry was not built: " .. luaFile) -- 2528
		end -- 2528
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 2530
		return { -- 2531
			fileName = fileName, -- 2532
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 2533
		} -- 2533
	end -- 2513
	local function capturePrint(...) -- 2536
		local values = {...} -- 2536
		local parts = {} -- 2537
		do -- 2537
			local i = 0 -- 2538
			while i < #values do -- 2538
				parts[#parts + 1] = tostring(values[i + 1]) -- 2539
				i = i + 1 -- 2538
			end -- 2538
		end -- 2538
		output[#output + 1] = table.concat(parts, "\t") -- 2541
	end -- 2536
	local env = setmetatable( -- 2543
		{ -- 2543
			projectDir = req.workDir, -- 2544
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 2545
				if type(moduleNameValue) ~= "string" then -- 2545
					error("requireProjectModule expects a project module name string") -- 2547
				end -- 2547
				local moduleName = __TS__StringTrim(moduleNameValue) -- 2549
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 2549
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 2551
				end -- 2551
				local reloadModules = {moduleName} -- 2553
				if reloadModulesValue ~= nil then -- 2553
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 2553
						error("requireProjectModule reloadModules must be an array of module names") -- 2556
					end -- 2556
					local items = reloadModulesValue -- 2558
					do -- 2558
						local i = 0 -- 2559
						while i < #items do -- 2559
							local item = items[i + 1] -- 2560
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 2560
								error("requireProjectModule reloadModules contains an invalid module name") -- 2562
							end -- 2562
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 2562
								reloadModules[#reloadModules + 1] = item -- 2564
							end -- 2564
							i = i + 1 -- 2559
						end -- 2559
					end -- 2559
				end -- 2559
				local luaPackage = _G.package -- 2567
				local previousPath = luaPackage.path -- 2571
				local previousSearchPaths = Content.searchPaths -- 2572
				local scopedSearchPaths = {req.workDir} -- 2573
				do -- 2573
					local i = 0 -- 2574
					while i < #previousSearchPaths do -- 2574
						local searchPath = previousSearchPaths[i + 1] -- 2575
						if searchPath ~= req.workDir then -- 2575
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 2576
						end -- 2576
						i = i + 1 -- 2574
					end -- 2574
				end -- 2574
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 2578
				Content.searchPaths = scopedSearchPaths -- 2579
				do -- 2579
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2579
						do -- 2579
							local i = 0 -- 2581
							while i < #reloadModules do -- 2581
								local reloadName = reloadModules[i + 1] -- 2582
								luaPackage.loaded[reloadName] = nil -- 2583
								luaPackage.loaded[table.concat( -- 2584
									__TS__StringSplit(reloadName, "/"), -- 2584
									"." -- 2584
								)] = nil -- 2584
								luaPackage.loaded[table.concat( -- 2585
									__TS__StringSplit(reloadName, "."), -- 2585
									"/" -- 2585
								)] = nil -- 2585
								i = i + 1 -- 2581
							end -- 2581
						end -- 2581
						return true, require(table.concat( -- 2587
							__TS__StringSplit(moduleName, "/"), -- 2587
							"." -- 2587
						)) -- 2587
					end) -- 2587
					do -- 2587
						Content.searchPaths = previousSearchPaths -- 2589
						luaPackage.path = previousPath -- 2590
					end -- 2590
					if not ____try then -- 2590
						error(____hasReturned, 0) -- 2590
					end -- 2590
					if ____try and ____hasReturned then -- 2590
						return ____returnValue -- 2580
					end -- 2580
				end -- 2580
			end, -- 2545
			print = capturePrint, -- 2593
			refreshTree = function(path) -- 2594
				if path == nil then -- 2594
					return refreshProjectTree(req.workDir) -- 2596
				end -- 2596
				if type(path) ~= "string" then -- 2596
					error("refreshTree expects a project-relative file path string or no argument") -- 2599
				end -- 2599
				return refreshProjectTree(req.workDir, path) -- 2601
			end, -- 2594
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 2603
			enterEntryAsync = function(value) -- 2604
				local normalized = normalizeEntryFile(value) -- 2605
				acquireEntryRuntime() -- 2606
				entry.allClear() -- 2607
				startEntryWatchdog() -- 2608
				local success, message = entry.enterEntryAsync({ -- 2609
					entryName = normalized.entryName, -- 2610
					fileName = normalized.fileName, -- 2611
					workDir = req.workDir, -- 2612
					projectRoot = req.workDir, -- 2613
					runKind = "agent_test" -- 2614
				}) -- 2614
				return success, message -- 2616
			end, -- 2604
			stopEntry = function() -- 2618
				if not ownsEntryRuntime then -- 2618
					return false -- 2619
				end -- 2619
				return entry.stop() -- 2620
			end -- 2618
		}, -- 2618
		{__index = Dora} -- 2622
	) -- 2622
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 2625
	if not fn then -- 2625
		return __TS__Promise.resolve({ -- 2627
			success = false, -- 2628
			mode = "lua", -- 2629
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2630
			message = truncateCommandError(toStr(compileErr)), -- 2631
			phase = "compile" -- 2632
		}) -- 2632
	end -- 2632
	return __TS__New( -- 2635
		__TS__Promise, -- 2635
		function(____, resolve) -- 2635
			local settled = false -- 2636
			local startedAt = App.runningTime -- 2637
			local onProgress = req.onProgress -- 2638
			local isCancelled = req.isCancelled -- 2639
			local function finish(result) -- 2640
				if settled then -- 2640
					return -- 2641
				end -- 2641
				settled = true -- 2642
				local cleanupError = stopOwnedEntry() -- 2643
				if not result.success and cleanupError ~= nil then -- 2643
					result.cleanupError = cleanupError -- 2645
				elseif result.success and cleanupError ~= nil then -- 2645
					resolve(nil, { -- 2647
						success = false, -- 2648
						mode = "lua", -- 2649
						output = result.output, -- 2650
						message = cleanupError, -- 2651
						phase = "execute", -- 2652
						cleanupError = cleanupError -- 2653
					}) -- 2653
					return -- 2655
				end -- 2655
				resolve(nil, result) -- 2657
			end -- 2640
			if onProgress then -- 2640
				onProgress(nil, { -- 2660
					state = "pending", -- 2661
					mode = "lua", -- 2662
					operationId = req.operationId, -- 2663
					stage = "lua", -- 2664
					message = "Lua command pending" -- 2665
				}) -- 2665
			end -- 2665
			Director.systemScheduler:schedule(function() -- 2668
				if settled then -- 2668
					return true -- 2669
				end -- 2669
				local watchdogMessage = checkEntryWatchdog() -- 2670
				if watchdogMessage ~= nil then -- 2670
					finish({ -- 2672
						success = false, -- 2673
						mode = "lua", -- 2674
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2675
						message = watchdogMessage, -- 2676
						phase = "execute", -- 2677
						interrupted = true -- 2678
					}) -- 2678
					return true -- 2680
				end -- 2680
				if isCancelled and isCancelled(nil) then -- 2680
					finish({ -- 2683
						success = false, -- 2684
						mode = "lua", -- 2685
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2686
						message = "Lua command canceled", -- 2687
						phase = "execute", -- 2688
						interrupted = true -- 2689
					}) -- 2689
					return true -- 2691
				end -- 2691
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 2691
					finish({ -- 2694
						success = false, -- 2695
						mode = "lua", -- 2696
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2697
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 2698
						phase = "timeout" -- 2699
					}) -- 2699
					return true -- 2701
				end -- 2701
				return false -- 2703
			end) -- 2668
			Director.systemScheduler:schedule(once(function() -- 2705
				if settled then -- 2705
					return -- 2706
				end -- 2706
				if onProgress then -- 2706
					onProgress(nil, { -- 2708
						state = "running", -- 2709
						mode = "lua", -- 2710
						operationId = req.operationId, -- 2711
						stage = "lua", -- 2712
						message = "Lua command running" -- 2713
					}) -- 2713
				end -- 2713
				local previousGlobalPrint = _G.print -- 2716
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 2717
				local frameTimedOut = false -- 2718
				local watchdogMessage -- 2718
				_G.print = capturePrint -- 2719
				debug.sethook( -- 2720
					function() -- 2720
						if watchdogMessage == nil then -- 2720
							watchdogMessage = checkEntryWatchdog() -- 2721
						end -- 2721
						if watchdogMessage ~= nil then -- 2721
							error(watchdogMessage) -- 2722
						end -- 2722
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 2722
							frameTimedOut = true -- 2724
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 2725
						end -- 2725
					end, -- 2720
					"", -- 2727
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 2727
				) -- 2727
				local ok, runtimeErr = pcall(fn) -- 2728
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 2728
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 2730
				else -- 2730
					debug.sethook() -- 2736
				end -- 2736
				_G.print = previousGlobalPrint -- 2738
				if not ok then -- 2738
					local ____truncateCommandOutput_result_42 = truncateCommandOutput(table.concat(output, "\n")) -- 2743
					local ____temp_43 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 2744
					local ____temp_44 = frameTimedOut and "timeout" or "execute" -- 2745
					local ____temp_41 -- 2746
					if watchdogMessage ~= nil or frameTimedOut then -- 2746
						____temp_41 = true -- 2746
					else -- 2746
						____temp_41 = nil -- 2746
					end -- 2746
					finish({ -- 2740
						success = false, -- 2741
						mode = "lua", -- 2742
						output = ____truncateCommandOutput_result_42, -- 2743
						message = ____temp_43, -- 2744
						phase = ____temp_44, -- 2745
						interrupted = ____temp_41 -- 2746
					}) -- 2746
					return -- 2748
				end -- 2748
				finish({ -- 2750
					success = true, -- 2750
					mode = "lua", -- 2750
					output = truncateCommandOutput(table.concat(output, "\n")) -- 2750
				}) -- 2750
			end)) -- 2705
		end -- 2635
	) -- 2635
end -- 2457
local function formatGitStatusOutput(status) -- 2755
	if not status then -- 2755
		return "" -- 2756
	end -- 2756
	local lines = {} -- 2757
	local state = toStr(status.state) -- 2758
	local kind = toStr(status.kind) -- 2759
	local message = toStr(status.message) -- 2760
	local errorMessage = toStr(status.error) -- 2761
	if kind ~= "" or state ~= "" then -- 2761
		lines[#lines + 1] = table.concat( -- 2763
			__TS__ArrayFilter( -- 2763
				{kind, state}, -- 2763
				function(____, item) return item ~= "" end -- 2763
			), -- 2763
			": " -- 2763
		) -- 2763
	end -- 2763
	if message ~= "" then -- 2763
		lines[#lines + 1] = message -- 2765
	end -- 2765
	if errorMessage ~= "" then -- 2765
		lines[#lines + 1] = errorMessage -- 2766
	end -- 2766
	local data = status.data -- 2767
	if data ~= nil then -- 2767
		local dataText = encodeJSON(data) -- 2769
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 2770
	end -- 2770
	return truncateCommandOutput(table.concat(lines, "\n")) -- 2772
end -- 2755
local function emitGitProgress(mode, operationId, onProgress, status) -- 2775
	if not onProgress then -- 2775
		return -- 2781
	end -- 2781
	local progress = type(status.progress) == "number" and status.progress or nil -- 2782
	local kind = toStr(status.kind) -- 2783
	local message = toStr(status.message) -- 2784
	local state = toStr(status.state) -- 2785
	local jobId = type(status.id) == "number" and status.id or nil -- 2786
	onProgress({ -- 2787
		state = "running", -- 2788
		mode = mode, -- 2789
		operationId = operationId, -- 2790
		stage = kind ~= "" and kind or "git", -- 2791
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 2792
		progress = progress, -- 2793
		jobId = jobId, -- 2794
		gitState = state ~= "" and state or nil, -- 2795
		gitKind = kind ~= "" and kind or nil -- 2796
	}) -- 2796
end -- 2775
local function cloneGitToTarget(req) -- 2800
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2800
		local parsed = parseGitCloneCommand(req.command) -- 2808
		if parsed == nil then -- 2808
			return ____awaiter_resolve(nil, nil) -- 2808
		end -- 2808
		if not parsed.success then -- 2808
			return ____awaiter_resolve(nil, { -- 2808
				success = false, -- 2811
				mode = "git", -- 2811
				output = "", -- 2811
				message = parsed.message, -- 2811
				phase = "validate" -- 2811
			}) -- 2811
		end -- 2811
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 2813
		if not target then -- 2813
			return ____awaiter_resolve(nil, { -- 2813
				success = false, -- 2815
				mode = "git", -- 2815
				output = "", -- 2815
				message = "invalid clone target path", -- 2815
				phase = "validate" -- 2815
			}) -- 2815
		end -- 2815
		if Content:exist(target) then -- 2815
			return ____awaiter_resolve(nil, { -- 2815
				success = false, -- 2818
				mode = "git", -- 2818
				output = "", -- 2818
				message = "target already exists", -- 2818
				phase = "validate" -- 2818
			}) -- 2818
		end -- 2818
		local targetParent = Path:getPath(target) -- 2820
		if not ensureDirPath(targetParent) then -- 2820
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 2820
		end -- 2820
		local tempRoot = getAgentDownloadTempRoot() -- 2824
		if not ensureDirPath(tempRoot) then -- 2824
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 2824
		end -- 2824
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 2828
		Content:remove(tempPath) -- 2829
		local depth = parsed.depth or "1" -- 2830
		local ____array_45 = __TS__SparseArrayNew( -- 2830
			"clone", -- 2832
			quoteGitArg(parsed.url), -- 2833
			quoteGitArg(Path:getFilename(tempPath)), -- 2834
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 2835
				"-b", -- 2835
				quoteGitArg(parsed.ref) -- 2835
			}) or ({})) -- 2835
		) -- 2835
		__TS__SparseArrayPush( -- 2835
			____array_45, -- 2835
			table.unpack(depth ~= "" and ({ -- 2836
				"--depth",
				quoteGitArg(depth) -- 2836
			}) or ({})) -- 2836
		) -- 2836
		local command = table.concat( -- 2831
			{__TS__SparseArraySpread(____array_45)}, -- 2831
			" " -- 2837
		) -- 2837
		local ____this_47 -- 2837
		____this_47 = req -- 2838
		local ____opt_46 = ____this_47.onProgress -- 2838
		if ____opt_46 ~= nil then -- 2838
			____opt_46(____this_47, { -- 2838
				state = "pending", -- 2839
				mode = "git", -- 2840
				operationId = req.operationId, -- 2841
				stage = "clone", -- 2842
				message = "clone pending", -- 2843
				progress = 0 -- 2844
			}) -- 2844
		end -- 2844
		local gitRes = __TS__Await(runGitAndWait( -- 2846
			tempRoot, -- 2847
			command, -- 2848
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2849
			function() -- 2850
				local ____this_49 -- 2850
				____this_49 = req -- 2850
				local ____opt_48 = ____this_49.isCancelled -- 2850
				return (____opt_48 and ____opt_48(____this_49)) == true -- 2850
			end, -- 2850
			req.timeoutSeconds -- 2851
		)) -- 2851
		if not gitRes.success then -- 2851
			local cleanupError = cleanupPath(tempPath) -- 2854
			local ____formatGitStatusOutput_result_53 = formatGitStatusOutput(gitRes.status) -- 2858
			local ____temp_54 = gitRes.message or "git clone failed" -- 2859
			local ____gitRes_interrupted_52 = gitRes.interrupted -- 2860
			if not ____gitRes_interrupted_52 then -- 2860
				local ____this_51 -- 2860
				____this_51 = req -- 2860
				local ____opt_50 = ____this_51.isCancelled -- 2860
				____gitRes_interrupted_52 = (____opt_50 and ____opt_50(____this_51)) == true -- 2860
			end -- 2860
			return ____awaiter_resolve(nil, { -- 2860
				success = false, -- 2856
				mode = "git", -- 2857
				output = ____formatGitStatusOutput_result_53, -- 2858
				message = ____temp_54, -- 2859
				interrupted = ____gitRes_interrupted_52, -- 2860
				cleanupError = cleanupError -- 2861
			}) -- 2861
		end -- 2861
		if not Content:move(tempPath, target) then -- 2861
			local cleanupError = cleanupPath(tempPath) -- 2865
			return ____awaiter_resolve( -- 2865
				nil, -- 2865
				{ -- 2866
					success = false, -- 2866
					mode = "git", -- 2866
					output = formatGitStatusOutput(gitRes.status), -- 2866
					message = "failed to move cloned repository into target path", -- 2866
					cleanupError = cleanupError -- 2866
				} -- 2866
			) -- 2866
		end -- 2866
		if not refreshProjectTree(req.workDir) then -- 2866
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 2869
		end -- 2869
		local commit = getGitHeadCommit(target) -- 2871
		local output = table.concat( -- 2872
			__TS__ArrayFilter( -- 2872
				{ -- 2872
					formatGitStatusOutput(gitRes.status), -- 2873
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 2873
					commit ~= nil and "commit " .. commit or "" -- 2875
				}, -- 2875
				function(____, item) return item ~= "" end -- 2876
			), -- 2876
			"\n" -- 2876
		) -- 2876
		return ____awaiter_resolve( -- 2876
			nil, -- 2876
			{ -- 2877
				success = true, -- 2877
				mode = "git", -- 2877
				output = truncateCommandOutput(output) -- 2877
			} -- 2877
		) -- 2877
	end) -- 2877
end -- 2800
local function loadGitProfile() -- 2880
	local rows -- 2881
	do -- 2881
		local function ____catch() -- 2881
			return true, nil -- 2885
		end -- 2885
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2885
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 2883
		end) -- 2883
		if not ____try then -- 2883
			____hasReturned, ____returnValue = ____catch() -- 2883
		end -- 2883
		if ____hasReturned then -- 2883
			return ____returnValue -- 2882
		end -- 2882
	end -- 2882
	if not rows or not rows[1] then -- 2882
		return nil -- 2887
	end -- 2887
	local name = toStr(rows[1][1]) -- 2888
	local email = toStr(rows[1][2]) -- 2889
	if name == "" and email == "" then -- 2889
		return nil -- 2890
	end -- 2890
	return {name = name, email = email} -- 2891
end -- 2880
local function applyGitProfileToCommit(command) -- 2894
	local args = shellSplit(command) -- 2895
	if args[1] ~= "commit" then -- 2895
		return command -- 2896
	end -- 2896
	local hasName = false -- 2897
	local hasEmail = false -- 2898
	for ____, arg in ipairs(args) do -- 2899
		if arg == "--author-name" then
			hasName = true -- 2900
		end -- 2900
		if arg == "--author-email" then
			hasEmail = true -- 2901
		end -- 2901
	end -- 2901
	if hasName and hasEmail then -- 2901
		return command -- 2903
	end -- 2903
	local profile = loadGitProfile() -- 2904
	if not profile then -- 2904
		return command -- 2905
	end -- 2905
	local additions = {} -- 2906
	if not hasName and profile.name ~= "" then -- 2906
		__TS__ArrayPush( -- 2908
			additions, -- 2908
			"--author-name",
			quoteGitArg(profile.name) -- 2908
		) -- 2908
	end -- 2908
	if not hasEmail and profile.email ~= "" then -- 2908
		__TS__ArrayPush( -- 2911
			additions, -- 2911
			"--author-email",
			quoteGitArg(profile.email) -- 2911
		) -- 2911
	end -- 2911
	if #additions == 0 then -- 2911
		return command -- 2913
	end -- 2913
	return (command .. " ") .. table.concat(additions, " ") -- 2914
end -- 2894
local function executeGitCommand(req) -- 2917
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2917
		local command = normalizeGitCommand(req.command or "") -- 2926
		if command == "" then -- 2926
			return ____awaiter_resolve(nil, { -- 2926
				success = false, -- 2928
				mode = "git", -- 2928
				output = "", -- 2928
				message = "missing command", -- 2928
				phase = "validate" -- 2928
			}) -- 2928
		end -- 2928
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 2930
			workDir = req.workDir, -- 2931
			command = command, -- 2932
			operationId = req.operationId, -- 2933
			timeoutSeconds = req.timeoutSeconds, -- 2934
			onProgress = req.onProgress, -- 2935
			isCancelled = req.isCancelled -- 2936
		})) -- 2936
		if cloneResult ~= nil then -- 2936
			return ____awaiter_resolve(nil, cloneResult) -- 2936
		end -- 2936
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 2939
		if not cwd.success then -- 2939
			return ____awaiter_resolve(nil, { -- 2939
				success = false, -- 2941
				mode = "git", -- 2941
				output = "", -- 2941
				cwd = req.cwd, -- 2941
				message = cwd.message, -- 2941
				phase = "validate" -- 2941
			}) -- 2941
		end -- 2941
		command = applyGitProfileToCommit(command) -- 2943
		local ____this_56 -- 2943
		____this_56 = req -- 2944
		local ____opt_55 = ____this_56.onProgress -- 2944
		if ____opt_55 ~= nil then -- 2944
			____opt_55(____this_56, { -- 2944
				state = "pending", -- 2945
				mode = "git", -- 2946
				operationId = req.operationId, -- 2947
				stage = "git", -- 2948
				message = "git command pending", -- 2949
				progress = 0 -- 2950
			}) -- 2950
		end -- 2950
		local gitRes = __TS__Await(runGitAndWait( -- 2952
			cwd.path, -- 2953
			command, -- 2954
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2955
			function() -- 2956
				local ____this_58 -- 2956
				____this_58 = req -- 2956
				local ____opt_57 = ____this_58.isCancelled -- 2956
				return (____opt_57 and ____opt_57(____this_58)) == true -- 2956
			end, -- 2956
			req.timeoutSeconds -- 2957
		)) -- 2957
		local output = formatGitStatusOutput(gitRes.status) -- 2959
		if not gitRes.success then -- 2959
			local ____output_62 = output -- 2964
			local ____cwd_relative_63 = cwd.relative -- 2965
			local ____temp_64 = gitRes.message or "git command failed" -- 2966
			local ____gitRes_interrupted_61 = gitRes.interrupted -- 2967
			if not ____gitRes_interrupted_61 then -- 2967
				local ____this_60 -- 2967
				____this_60 = req -- 2967
				local ____opt_59 = ____this_60.isCancelled -- 2967
				____gitRes_interrupted_61 = (____opt_59 and ____opt_59(____this_60)) == true -- 2967
			end -- 2967
			return ____awaiter_resolve(nil, { -- 2967
				success = false, -- 2962
				mode = "git", -- 2963
				output = ____output_62, -- 2964
				cwd = ____cwd_relative_63, -- 2965
				message = ____temp_64, -- 2966
				interrupted = ____gitRes_interrupted_61 -- 2967
			}) -- 2967
		end -- 2967
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 2967
	end) -- 2967
end -- 2917
function ____exports.executeCommand(req) -- 2973
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2973
		local mode = req.mode -- 2983
		if mode ~= "lua" and mode ~= "git" then -- 2983
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 2983
		end -- 2983
		if mode == "lua" then -- 2983
			return ____awaiter_resolve( -- 2983
				nil, -- 2983
				executeLuaCommand({ -- 2988
					workDir = req.workDir, -- 2989
					code = req.code or "", -- 2990
					timeoutSeconds = math.max( -- 2991
						1, -- 2991
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 2991
					), -- 2991
					operationId = createOperationId(), -- 2992
					onProgress = req.onProgress, -- 2993
					isCancelled = req.isCancelled -- 2994
				}) -- 2994
			) -- 2994
		end -- 2994
		local operationId = createOperationId() -- 2997
		return ____awaiter_resolve( -- 2997
			nil, -- 2997
			executeGitCommand({ -- 2998
				workDir = req.workDir, -- 2999
				command = req.command or "", -- 3000
				cwd = req.cwd, -- 3001
				timeoutSeconds = math.max( -- 3002
					1, -- 3002
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 3002
				), -- 3002
				operationId = operationId, -- 3003
				onProgress = req.onProgress, -- 3004
				isCancelled = req.isCancelled -- 3005
			}) -- 3005
		) -- 3005
	end) -- 3005
end -- 2973
function ____exports.fetchUrl(req) -- 3009
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3009
		local mode = "download" -- 3016
		local url = __TS__StringTrim(req.url or "") -- 3017
		local targetRel = __TS__StringTrim(req.target or "") -- 3018
		if not isHttpUrl(url) then -- 3018
			return ____awaiter_resolve(nil, { -- 3018
				success = false, -- 3020
				state = "failed", -- 3020
				mode = mode, -- 3020
				target = targetRel, -- 3020
				message = "fetch_url only supports http:// and https:// URLs" -- 3020
			}) -- 3020
		end -- 3020
		if targetRel == "" then -- 3020
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 3020
		end -- 3020
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 3025
		if not target then -- 3025
			return ____awaiter_resolve(nil, { -- 3025
				success = false, -- 3027
				state = "failed", -- 3027
				mode = mode, -- 3027
				target = targetRel, -- 3027
				message = "invalid target path" -- 3027
			}) -- 3027
		end -- 3027
		if Content:exist(target) then -- 3027
			return ____awaiter_resolve(nil, { -- 3027
				success = false, -- 3030
				state = "failed", -- 3030
				mode = mode, -- 3030
				target = targetRel, -- 3030
				message = "target already exists" -- 3030
			}) -- 3030
		end -- 3030
		local operationId = createOperationId() -- 3032
		local tempRoot = getAgentDownloadTempRoot() -- 3033
		if not ensureDirPath(tempRoot) then -- 3033
			return ____awaiter_resolve(nil, { -- 3033
				success = false, -- 3035
				state = "failed", -- 3035
				mode = mode, -- 3035
				target = targetRel, -- 3035
				message = "failed to create agent download temp directory" -- 3035
			}) -- 3035
		end -- 3035
		local tempPath = Path(tempRoot, operationId .. ".download") -- 3037
		Content:remove(tempPath) -- 3038
		local function emitProgress(progress) -- 3039
			if not req.onProgress then -- 3039
				return -- 3040
			end -- 3040
			req:onProgress(__TS__ObjectAssign({ -- 3041
				state = "running", -- 3042
				mode = mode, -- 3043
				operationId = operationId, -- 3044
				target = targetRel, -- 3045
				tempPath = tempPath -- 3046
			}, progress)) -- 3046
		end -- 3039
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 3050
		local function interrupted() -- 3055
			local ____this_66 -- 3055
			____this_66 = req -- 3055
			local ____opt_65 = ____this_66.isCancelled -- 3055
			return (____opt_65 and ____opt_65(____this_66)) == true -- 3055
		end -- 3055
		if not ensureDirForFile(tempPath) then -- 3055
			return ____awaiter_resolve(nil, { -- 3055
				success = false, -- 3057
				state = "failed", -- 3057
				mode = mode, -- 3057
				target = targetRel, -- 3057
				message = "failed to create temporary file directory" -- 3057
			}) -- 3057
		end -- 3057
		local downloadRes = __TS__Await(downloadFile({ -- 3059
			url = url, -- 3060
			tempPath = tempPath, -- 3061
			timeout = 600, -- 3062
			isCancelled = interrupted, -- 3063
			onProgress = function(____, current, total) -- 3064
				local totalNumber = type(total) == "number" and total or 0 -- 3065
				emitProgress({ -- 3066
					stage = "download", -- 3067
					message = "downloading", -- 3068
					current = current, -- 3069
					total = total, -- 3070
					progress = totalNumber > 0 and current / totalNumber or nil -- 3071
				}) -- 3071
			end -- 3064
		})) -- 3064
		if not downloadRes.success then -- 3064
			local cleanupError = cleanupPath(tempPath) -- 3076
			return ____awaiter_resolve( -- 3076
				nil, -- 3076
				{ -- 3077
					success = false, -- 3078
					state = "failed", -- 3079
					mode = mode, -- 3080
					target = targetRel, -- 3081
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 3082
					interrupted = downloadRes.interrupted or interrupted(), -- 3083
					cleanupError = cleanupError -- 3084
				} -- 3084
			) -- 3084
		end -- 3084
		if not ensureDirForFile(target) then -- 3084
			local cleanupError = cleanupPath(tempPath) -- 3088
			return ____awaiter_resolve(nil, { -- 3088
				success = false, -- 3089
				state = "failed", -- 3089
				mode = mode, -- 3089
				target = targetRel, -- 3089
				message = "failed to create target directory", -- 3089
				cleanupError = cleanupError -- 3089
			}) -- 3089
		end -- 3089
		if not Content:move(tempPath, target) then -- 3089
			local cleanupError = cleanupPath(tempPath) -- 3092
			return ____awaiter_resolve(nil, { -- 3092
				success = false, -- 3093
				state = "failed", -- 3093
				mode = mode, -- 3093
				target = targetRel, -- 3093
				message = "failed to move downloaded file into target path", -- 3093
				cleanupError = cleanupError -- 3093
			}) -- 3093
		end -- 3093
		local bytesWritten = downloadRes.bytesWritten -- 3095
		local ____try = __TS__AsyncAwaiter(function() -- 3095
			local size = Content:getAttr(target) -- 3097
			if bytesWritten == nil or bytesWritten <= 0 then -- 3097
				bytesWritten = type(size) == "number" and size or nil -- 3099
			end -- 3099
		end) -- 3099
		____try = ____try.catch( -- 3099
			____try, -- 3099
			function(____, _) -- 3099
				return __TS__AsyncAwaiter(function() -- 3099
				end) -- 3099
			end -- 3099
		) -- 3099
		__TS__Await(____try) -- 3096
		if bytesWritten == nil or bytesWritten <= 0 then -- 3096
			local ____try = __TS__AsyncAwaiter(function() -- 3096
				local loaded = Content:load(target) -- 3106
				if type(loaded) == "string" then -- 3106
					bytesWritten = #loaded -- 3108
				end -- 3108
			end) -- 3108
			____try = ____try.catch( -- 3108
				____try, -- 3108
				function(____, _) -- 3108
					return __TS__AsyncAwaiter(function() -- 3108
					end) -- 3108
				end -- 3108
			) -- 3108
			__TS__Await(____try) -- 3105
		end -- 3105
		if not syncDownloadedFileToWebIDE(target) then -- 3105
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 3115
		end -- 3115
		return ____awaiter_resolve(nil, { -- 3115
			success = true, -- 3117
			state = "done", -- 3117
			mode = mode, -- 3117
			target = targetRel, -- 3117
			bytesWritten = bytesWritten -- 3117
		}) -- 3117
	end) -- 3117
end -- 3009
return ____exports -- 3009