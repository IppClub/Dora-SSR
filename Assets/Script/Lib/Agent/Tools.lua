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
local AgentConfig = require("Agent.AgentConfig") -- 5
local ____AgentStorage = require("Agent.AgentStorage") -- 6
local TABLE_TASK = ____AgentStorage.TABLE_TASK -- 7
local TABLE_CP = ____AgentStorage.TABLE_CHECKPOINT -- 8
local TABLE_ENTRY = ____AgentStorage.TABLE_CHECKPOINT_ENTRY -- 9
local requireAgentStorage = ____AgentStorage.requireAgentStorage -- 10
local ____Utils = require("Agent.Utils") -- 12
local Log = ____Utils.Log -- 12
local safeJsonDecode = ____Utils.safeJsonDecode -- 12
local safeJsonEncode = ____Utils.safeJsonEncode -- 12
function normalizeEscapedGitQuotes(command) -- 695
	local result = "" -- 696
	do -- 696
		local i = 0 -- 697
		while i < #command do -- 697
			do -- 697
				local ch = __TS__StringCharAt(command, i) -- 698
				local next = __TS__StringCharAt(command, i + 1) -- 699
				if ch == "\\" and (next == "\"" or next == "'") then -- 699
					result = result .. next -- 701
					i = i + 1 -- 702
					goto __continue112 -- 703
				end -- 703
				result = result .. ch -- 705
			end -- 705
			::__continue112:: -- 705
			i = i + 1 -- 697
		end -- 697
	end -- 697
	return result -- 707
end -- 707
function encodeJSON(obj) -- 1208
	local text = safeJsonEncode(obj) -- 1209
	return text -- 1210
end -- 1210
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 1213
	if HttpServer.wsConnectionCount == 0 then -- 1213
		return true -- 1215
	end -- 1215
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 1217
	if not payload then -- 1217
		return false -- 1219
	end -- 1219
	emit("AppWS", "Send", payload) -- 1221
	return true -- 1222
end -- 1213
function getEngineLogText() -- 1604
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 1605
	if not Content:exist(folder) then -- 1605
		Content:mkdir(folder) -- 1607
	end -- 1607
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 1609
	if not App:saveLog(logPath) then -- 1609
		return nil -- 1611
	end -- 1611
	return Content:load(logPath) -- 1613
end -- 1613
function ensureSafeSearchGlobs(globs) -- 1753
	local result = {} -- 1754
	do -- 1754
		local i = 0 -- 1755
		while i < #globs do -- 1755
			result[#result + 1] = globs[i + 1] -- 1756
			i = i + 1 -- 1755
		end -- 1755
	end -- 1755
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1758
	do -- 1758
		local i = 0 -- 1759
		while i < #requiredExcludes do -- 1759
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1759
				result[#result + 1] = requiredExcludes[i + 1] -- 1761
			end -- 1761
			i = i + 1 -- 1759
		end -- 1759
	end -- 1759
	return result -- 1764
end -- 1764
local function recoverJsonStringProperty(text, key) -- 21
	local marker = ("\"" .. key) .. "\"" -- 22
	local markerIndex = (string.find(text, marker, nil, true) or 0) - 1 -- 23
	if markerIndex < 0 then -- 23
		return nil -- 24
	end -- 24
	local colonIndex = (string.find( -- 25
		text, -- 25
		":", -- 25
		math.max(markerIndex + #marker + 1, 1), -- 25
		true -- 25
	) or 0) - 1 -- 25
	if colonIndex < 0 then -- 25
		return nil -- 26
	end -- 26
	local quoteIndex = colonIndex + 1 -- 27
	while quoteIndex < #text do -- 27
		local code = __TS__StringCharCodeAt(text, quoteIndex) -- 29
		if code ~= 32 and code ~= 9 and code ~= 10 and code ~= 13 then -- 29
			break -- 30
		end -- 30
		quoteIndex = quoteIndex + 1 -- 31
	end -- 31
	if quoteIndex >= #text or __TS__StringCharCodeAt(text, quoteIndex) ~= 34 then -- 31
		return nil -- 33
	end -- 33
	local escaped = false -- 34
	do -- 34
		local i = quoteIndex + 1 -- 35
		while i < #text do -- 35
			do -- 35
				local code = __TS__StringCharCodeAt(text, i) -- 36
				if escaped then -- 36
					escaped = false -- 38
					goto __continue9 -- 39
				end -- 39
				if code == 92 then -- 39
					escaped = true -- 42
					goto __continue9 -- 43
				end -- 43
				if code == 34 then -- 43
					local decoded = safeJsonDecode(("{\"value\":" .. __TS__StringSlice(text, quoteIndex, i + 1)) .. "}") -- 46
					if decoded and type(decoded) == "table" and type(decoded.value) == "string" then -- 46
						return {value = decoded.value, complete = true} -- 48
					end -- 48
					return nil -- 50
				end -- 50
			end -- 50
			::__continue9:: -- 50
			i = i + 1 -- 35
		end -- 35
	end -- 35
	local fragment = __TS__StringSlice(text, quoteIndex) -- 53
	do -- 53
		local trim = 0 -- 54
		while trim <= 6 and trim <= #fragment - 1 do -- 54
			local decoded = safeJsonDecode(("{\"value\":" .. __TS__StringSlice(fragment, 0, #fragment - trim)) .. "\"}") -- 55
			if decoded and type(decoded) == "table" and type(decoded.value) == "string" then -- 55
				return {value = decoded.value, complete = false} -- 57
			end -- 57
			trim = trim + 1 -- 54
		end -- 54
	end -- 54
	return nil -- 60
end -- 21
--- Recover only a truncated whole-file overwrite. A truncated replacement with
-- non-empty old_str is unsafe and deliberately returns undefined.
function ____exports.planTruncatedEditRecovery(toolCalls) -- 67
	if not toolCalls or #toolCalls == 0 then -- 67
		return nil -- 70
	end -- 70
	do -- 70
		local i = #toolCalls - 1 -- 71
		while i >= 0 do -- 71
			do -- 71
				local ____opt_0 = toolCalls[i + 1] -- 71
				local fn = ____opt_0 and ____opt_0["function"] -- 72
				if not fn or fn.name ~= "edit_file" or type(fn.arguments) ~= "string" then -- 72
					goto __continue20 -- 73
				end -- 73
				local recovered = recoverJsonStringProperty(fn.arguments, "new_str") -- 74
				if not recovered or recovered.complete or #recovered.value == 0 then -- 74
					goto __continue20 -- 75
				end -- 75
				local target = recoverJsonStringProperty(fn.arguments, "path") or recoverJsonStringProperty(fn.arguments, "target_file") -- 76
				local oldStr = recoverJsonStringProperty(fn.arguments, "old_str") -- 78
				if not target or not target.complete or not oldStr or not oldStr.complete or oldStr.value ~= "" then -- 78
					goto __continue20 -- 79
				end -- 79
				return { -- 80
					target = target.value, -- 81
					receivedText = recovered.value, -- 82
					reason = ((("The response ended while overwriting " .. target.value) .. ". Write the ") .. tostring(#recovered.value)) .. " fully decoded characters directly to that file. This is the complete recoverable prefix; inspect the actual file next and decide whether it already suffices or needs a bounded continuation." -- 83
				} -- 83
			end -- 83
			::__continue20:: -- 83
			i = i - 1 -- 71
		end -- 71
	end -- 71
	return nil -- 86
end -- 67
ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 418
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 419
local AGENT_DOWNLOAD_TEMP_DIR = "agent" -- 420
local function now() -- 421
	return os.time() -- 421
end -- 421
local function toBool(v) -- 423
	return v ~= 0 and v ~= false and v ~= nil -- 424
end -- 423
local function toStr(v) -- 427
	if v == false or v == nil then -- 427
		return "" -- 428
	end -- 428
	return tostring(v) -- 429
end -- 427
local function isValidWorkspacePath(path) -- 432
	if not path or #path == 0 then -- 432
		return false -- 433
	end -- 433
	if Content:isAbsolutePath(path) then -- 433
		return false -- 434
	end -- 434
	if __TS__StringIncludes(path, "..") then -- 434
		return false -- 435
	end -- 435
	return true -- 436
end -- 432
local function isValidWorkDir(workDir) -- 439
	if not workDir or #workDir == 0 then -- 439
		return false -- 440
	end -- 440
	if not Content:isAbsolutePath(workDir) then -- 440
		return false -- 441
	end -- 441
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 441
		return false -- 442
	end -- 442
	return true -- 443
end -- 439
local function isValidSearchPath(path) -- 446
	if path == "" then -- 446
		return true -- 447
	end -- 447
	if Content:isAbsolutePath(path) then -- 447
		return false -- 448
	end -- 448
	if not path or #path == 0 then -- 448
		return false -- 449
	end -- 449
	if __TS__StringIncludes(path, "..") then -- 449
		return false -- 450
	end -- 450
	return true -- 451
end -- 446
local function resolveWorkspaceFilePath(workDir, path) -- 454
	if not isValidWorkDir(workDir) then -- 454
		return nil -- 455
	end -- 455
	if not isValidWorkspacePath(path) then -- 455
		return nil -- 456
	end -- 456
	return Path(workDir, path) -- 457
end -- 454
local function resolveWorkspaceSearchPath(workDir, path) -- 460
	if not isValidWorkDir(workDir) then -- 460
		return nil -- 461
	end -- 461
	if not isValidSearchPath(path) then -- 461
		return nil -- 462
	end -- 462
	return path == "" and workDir or Path(workDir, path) -- 463
end -- 460
local function toWorkspaceRelativePath(workDir, path) -- 466
	if not path or #path == 0 then -- 466
		return path -- 467
	end -- 467
	if not Content:isAbsolutePath(path) then -- 467
		return path -- 468
	end -- 468
	return Path:getRelative(path, workDir) -- 469
end -- 466
local function toWorkspaceRelativeFileList(workDir, files) -- 472
	return __TS__ArrayMap( -- 473
		files, -- 473
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 473
	) -- 473
end -- 472
local function toWorkspaceRelativeSearchResults(workDir, results) -- 476
	local mapped = {} -- 477
	do -- 477
		local i = 0 -- 478
		while i < #results do -- 478
			local row = results[i + 1] -- 479
			local clone = __TS__ObjectAssign({}, row) -- 480
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 481
			mapped[#mapped + 1] = clone -- 482
			i = i + 1 -- 478
		end -- 478
	end -- 478
	return mapped -- 484
end -- 476
local function resolveWorkspaceDirectoryPath(workDir, path) -- 487
	local relative = __TS__StringTrim(path or "") -- 488
	if relative == "" then -- 488
		return {success = true, path = workDir, relative = "."} -- 490
	end -- 490
	if not isValidWorkDir(workDir) or not isValidWorkspacePath(relative) then -- 490
		return {success = false, message = "invalid cwd path"} -- 493
	end -- 493
	local resolved = Path(workDir, relative) -- 495
	if not Content:exist(resolved) then -- 495
		return {success = false, message = "cwd does not exist"} -- 497
	end -- 497
	if not Content:isdir(resolved) then -- 497
		return {success = false, message = "cwd is not a directory"} -- 500
	end -- 500
	return {success = true, path = resolved, relative = relative} -- 502
end -- 487
local function getDoraAPIDocRoot(docLanguage) -- 505
	local zhDir = Path( -- 506
		Content.assetPath, -- 506
		"Script", -- 506
		"Lib", -- 506
		"Dora", -- 506
		"zh-Hans" -- 506
	) -- 506
	local enDir = Path( -- 507
		Content.assetPath, -- 507
		"Script", -- 507
		"Lib", -- 507
		"Dora", -- 507
		"en" -- 507
	) -- 507
	return docLanguage == "zh" and zhDir or enDir -- 508
end -- 505
local function getDoraTutorialDocRoot(docLanguage) -- 511
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 512
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 513
	return docLanguage == "zh" and zhDir or enDir -- 514
end -- 511
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 517
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 517
		return {"ts"} -- 519
	end -- 519
	return {"tl"} -- 521
end -- 517
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 524
	repeat -- 524
		local ____switch65 = programmingLanguage -- 524
		local ____cond65 = ____switch65 == "teal" -- 524
		if ____cond65 then -- 524
			return "tl" -- 526
		end -- 526
		____cond65 = ____cond65 or ____switch65 == "tl" -- 526
		if ____cond65 then -- 526
			return "tl" -- 527
		end -- 527
		do -- 527
			return programmingLanguage -- 528
		end -- 528
	until true -- 528
end -- 524
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 532
	if docSource == "tutorial" then -- 532
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 538
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 539
		return { -- 540
			root = Path(tutorialRoot, langDir), -- 541
			exts = {"md"}, -- 542
			globs = {"**/*.md"} -- 543
		} -- 543
	end -- 543
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 546
	return { -- 547
		root = getDoraAPIDocRoot(docLanguage), -- 548
		exts = exts, -- 549
		globs = __TS__ArrayMap( -- 550
			exts, -- 550
			function(____, ext) return "**/*." .. ext end -- 550
		) -- 550
	} -- 550
end -- 532
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 554
	if docSource == "tutorial" then -- 554
		return getDoraTutorialDocRoot(docLanguage) -- 556
	end -- 556
	return getDoraAPIDocRoot(docLanguage) -- 558
end -- 554
local AGENT_DORA_DOC_PREFIX = "@dora-doc/" -- 561
local function toDocRelativePath(baseRoot, path, docSource) -- 563
	if not path or #path == 0 then -- 563
		return path -- 564
	end -- 564
	local relative = Content:isAbsolutePath(path) and Path:getRelative(path, baseRoot) or path -- 565
	return ((AGENT_DORA_DOC_PREFIX .. docSource) .. "/") .. relative -- 566
end -- 563
local function resolveAgentDoraDocFilePath(path, docLanguage) -- 569
	if not docLanguage then -- 569
		return nil -- 570
	end -- 570
	local relative = path -- 571
	local source = "tutorial" -- 572
	if __TS__StringStartsWith(path, AGENT_DORA_DOC_PREFIX) then -- 572
		local namespaced = __TS__StringSlice(path, #AGENT_DORA_DOC_PREFIX) -- 574
		if __TS__StringStartsWith(namespaced, "api/") then -- 574
			source = "api" -- 576
			relative = string.sub(namespaced, 5) -- 577
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 577
			relative = string.sub(namespaced, 10) -- 579
		else -- 579
			return nil -- 581
		end -- 581
	end -- 581
	if not isValidWorkspacePath(relative) then -- 581
		return nil -- 584
	end -- 584
	local candidate = Path( -- 585
		getDoraDocResultBaseRoot(source, docLanguage), -- 585
		relative -- 585
	) -- 585
	local root = getDoraDocResultBaseRoot(source, docLanguage) -- 586
	local checked = Path:getRelative(candidate, root) -- 587
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 587
		return nil -- 588
	end -- 588
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 588
		return candidate -- 590
	end -- 590
	return nil -- 592
end -- 569
local function ensureDirPath(dir) -- 595
	if not dir or dir == "." or dir == "" then -- 595
		return true -- 596
	end -- 596
	if Content:exist(dir) then -- 596
		return Content:isdir(dir) -- 597
	end -- 597
	local parent = Path:getPath(dir) -- 598
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 598
		if not ensureDirPath(parent) then -- 598
			return false -- 600
		end -- 600
	end -- 600
	return Content:mkdir(dir) -- 602
end -- 595
local function ensureDirForFile(path) -- 605
	local dir = Path:getPath(path) -- 606
	return ensureDirPath(dir) -- 607
end -- 605
local function isHttpUrl(url) -- 610
	local normalized = string.lower(__TS__StringTrim(url)) -- 611
	return __TS__StringStartsWith(normalized, "http://") or __TS__StringStartsWith(normalized, "https://") -- 612
end -- 610
local function createOperationId() -- 615
	local raw = (tostring(os.time()) .. "-") .. tostring(math.floor(math.random() * 1000000000)) -- 616
	local safe = string.gsub(raw, "[^%w%-_]", "-") -- 617
	return safe -- 618
end -- 615
local function getAgentDownloadTempRoot() -- 621
	return Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR, AGENT_DOWNLOAD_TEMP_DIR) -- 622
end -- 621
local function cleanupPath(path) -- 625
	if not path or path == "" or not Content:exist(path) then -- 625
		return nil -- 626
	end -- 626
	if Content:remove(path) then -- 626
		return nil -- 627
	end -- 627
	return "failed to remove temporary path: " .. path -- 628
end -- 625
local function quoteGitArg(value) -- 631
	local plain = string.match(value, "^[%w%._%-%/]+$") -- 632
	if plain ~= nil then -- 632
		return value -- 634
	end -- 634
	local escaped = string.gsub(value, "\\", "\\\\") -- 636
	escaped = string.gsub(escaped, "\"", "\\\"") -- 637
	return ("\"" .. escaped) .. "\"" -- 638
end -- 631
local function shellSplit(command) -- 641
	local args = {} -- 642
	local current = "" -- 643
	local quote = "" -- 644
	local escaped = false -- 645
	do -- 645
		local i = 0 -- 646
		while i < #command do -- 646
			do -- 646
				local ch = __TS__StringCharAt(command, i) -- 647
				if escaped then -- 647
					current = current .. ch -- 649
					escaped = false -- 650
					goto __continue98 -- 651
				end -- 651
				if ch == "\\" then -- 651
					escaped = true -- 654
					goto __continue98 -- 655
				end -- 655
				if quote ~= "" then -- 655
					if ch == quote then -- 655
						quote = "" -- 659
					else -- 659
						current = current .. ch -- 661
					end -- 661
					goto __continue98 -- 663
				end -- 663
				if ch == "'" or ch == "\"" then -- 663
					quote = ch -- 666
					goto __continue98 -- 667
				end -- 667
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 667
					if current ~= "" then -- 667
						args[#args + 1] = current -- 671
						current = "" -- 672
					end -- 672
					goto __continue98 -- 674
				end -- 674
				current = current .. ch -- 676
			end -- 676
			::__continue98:: -- 676
			i = i + 1 -- 646
		end -- 646
	end -- 646
	if escaped then -- 646
		current = current .. "\\" -- 679
	end -- 679
	if current ~= "" then -- 679
		args[#args + 1] = current -- 682
	end -- 682
	return args -- 684
end -- 641
local function normalizeGitCommand(command) -- 687
	local trimmed = __TS__StringTrim(command) -- 688
	local normalized = string.lower(string.sub(trimmed, 1, 4)) == "git " and __TS__StringTrim(string.sub(trimmed, 5)) or trimmed -- 689
	return normalizeEscapedGitQuotes(normalized) -- 692
end -- 687
local function gitDefaultTargetFromUrl(url) -- 710
	local target = url -- 711
	local hashIndex = (string.find(target, "#", nil, true) or 0) - 1 -- 712
	if hashIndex >= 0 then -- 712
		target = __TS__StringSlice(target, 0, hashIndex) -- 713
	end -- 713
	local queryIndex = (string.find(target, "?", nil, true) or 0) - 1 -- 714
	if queryIndex >= 0 then -- 714
		target = __TS__StringSlice(target, 0, queryIndex) -- 715
	end -- 715
	target = string.gsub(target, "/+$", "") -- 716
	local name = string.match(target, "([^/]+)$") -- 717
	if name ~= nil and name ~= "" then -- 717
		target = name -- 718
	end -- 718
	if __TS__StringEndsWith( -- 718
		string.lower(target), -- 719
		".git" -- 719
	) then -- 719
		target = __TS__StringSlice(target, 0, #target - 4) -- 720
	end -- 720
	return target ~= "" and target or "repo" -- 722
end -- 710
local function parseGitCloneCommand(command) -- 725
	local args = shellSplit(normalizeGitCommand(command)) -- 735
	if #args == 0 or args[1] ~= "clone" then -- 735
		return nil -- 736
	end -- 736
	local url = "" -- 737
	local target = "" -- 738
	local ref -- 739
	local depth -- 740
	do -- 740
		local i = 1 -- 741
		while i < #args do -- 741
			do -- 741
				local arg = args[i + 1] -- 742
				if arg == "-b" or arg == "--branch" then
					i = i + 1 -- 744
					if i >= #args then -- 744
						return {success = false, message = arg .. " requires a value"} -- 745
					end -- 745
					ref = args[i + 1] -- 746
					goto __continue122 -- 747
				end -- 747
				if arg == "--depth" then
					i = i + 1 -- 750
					if i >= #args then -- 750
						return {success = false, message = "--depth requires a value"}
					end -- 751
					depth = args[i + 1] -- 752
					goto __continue122 -- 753
				end -- 753
				if __TS__StringStartsWith(arg, "--depth=") then
					depth = __TS__StringSlice(arg, #"--depth=")
					goto __continue122 -- 757
				end -- 757
				if __TS__StringStartsWith(arg, "-") then -- 757
					return {success = false, message = "unsupported clone option: " .. arg} -- 760
				end -- 760
				if url == "" then -- 760
					url = arg -- 763
					goto __continue122 -- 764
				end -- 764
				if target == "" then -- 764
					target = arg -- 767
					goto __continue122 -- 768
				end -- 768
				return {success = false, message = "unexpected clone argument: " .. arg} -- 770
			end -- 770
			::__continue122:: -- 770
			i = i + 1 -- 741
		end -- 741
	end -- 741
	if url == "" then -- 741
		return {success = false, message = "git clone requires a URL"} -- 772
	end -- 772
	if not isHttpUrl(url) then -- 772
		return {success = false, message = "git clone only supports http:// and https:// URLs"} -- 773
	end -- 773
	if target == "" then -- 773
		target = gitDefaultTargetFromUrl(url) -- 774
	end -- 774
	return { -- 775
		success = true, -- 776
		url = url, -- 777
		target = target, -- 778
		ref = ref, -- 779
		depth = depth ~= nil and depth ~= "" and depth or "1" -- 780
	} -- 780
end -- 725
local function getGitHeadCommit(repoPath) -- 784
	local headPath = Path(repoPath, ".git", "HEAD") -- 785
	if not Content:exist(headPath) then -- 785
		return nil -- 786
	end -- 786
	local head = __TS__StringTrim(toStr(Content:load(headPath))) -- 787
	local ref = string.match(head, "^ref:%s*(.-)%s*$") -- 788
	if ref ~= nil and ref ~= "" then -- 788
		local refPath = Path(repoPath, ".git", ref) -- 790
		if Content:exist(refPath) then -- 790
			local commit = __TS__StringTrim(toStr(Content:load(refPath))) -- 792
			return commit ~= "" and commit or nil -- 793
		end -- 793
		return nil -- 795
	end -- 795
	return head ~= "" and head or nil -- 797
end -- 784
local function runGitAndWait(repoPath, command, onStatus, isCancelled, timeout) -- 800
	if timeout == nil then -- 800
		timeout = 600 -- 805
	end -- 805
	return __TS__New( -- 807
		__TS__Promise, -- 807
		function(____, resolve) -- 807
			local status -- 808
			local jobId = 0 -- 809
			local settled = false -- 810
			local canceled = false -- 811
			local function finish(result) -- 812
				if settled then -- 812
					return -- 813
				end -- 813
				settled = true -- 814
				resolve(nil, result) -- 815
			end -- 812
			local function finishFromStatus() -- 817
				local state = toStr(status and status.state) -- 818
				if state == "done" then -- 818
					finish({success = true, status = status}) -- 820
					return true -- 821
				end -- 821
				if state == "error" or state == "canceled" then -- 821
					local errorMessage = toStr(status and status.error) -- 824
					local statusMessage = toStr(status and status.message) -- 825
					finish({success = false, message = errorMessage ~= "" and errorMessage or (statusMessage ~= "" and statusMessage or (state == "canceled" and "git command canceled" or "git command failed")), status = status, interrupted = state == "canceled"}) -- 826
					return true -- 832
				end -- 832
				return false -- 834
			end -- 817
			jobId = Git:run( -- 836
				repoPath, -- 836
				command, -- 836
				function(nextStatus) -- 836
					status = nextStatus -- 837
					if onStatus then -- 837
						onStatus(status) -- 838
					end -- 838
					return finishFromStatus() -- 839
				end, -- 836
				"" -- 840
			) -- 840
			if jobId == nil or jobId <= 0 then -- 840
				finish({success = false, message = "failed to start git command"}) -- 842
				return -- 843
			end -- 843
			if not status then -- 843
				local kind = string.match(command, "^(%S+)") -- 846
				status = { -- 847
					id = jobId, -- 848
					state = "queued", -- 849
					kind = toStr(kind), -- 850
					repoPath = repoPath, -- 851
					progress = 0, -- 852
					message = "queued" -- 853
				} -- 853
			end -- 853
			if onStatus then -- 853
				onStatus(status) -- 856
			end -- 856
			local startedAt = os.time() -- 857
			local lastEmitAt = startedAt -- 858
			Director.systemScheduler:schedule(function() -- 859
				if settled then -- 859
					return true -- 860
				end -- 860
				if not canceled and isCancelled and isCancelled() then -- 860
					canceled = true -- 862
					Git:cancel(jobId) -- 863
					finish({success = false, message = "git command canceled", status = status, interrupted = true}) -- 864
					return true -- 865
				end -- 865
				if finishFromStatus() then -- 865
					return true -- 867
				end -- 867
				local nowTime = os.time() -- 868
				if nowTime - startedAt >= timeout then -- 868
					Git:cancel(jobId) -- 870
					finish({success = false, message = "git command timed out", status = status}) -- 871
					return true -- 872
				end -- 872
				if onStatus and status and nowTime > lastEmitAt then -- 872
					lastEmitAt = nowTime -- 875
					onStatus(status) -- 876
				end -- 876
				return false -- 878
			end) -- 859
		end -- 807
	) -- 807
end -- 800
local function downloadFile(req) -- 883
	return __TS__New( -- 890
		__TS__Promise, -- 890
		function(____, resolve) -- 890
			local requestId = 0 -- 891
			local settled = false -- 892
			local bytesWritten = 0 -- 893
			local function finish(result) -- 894
				if settled then -- 894
					return -- 895
				end -- 895
				settled = true -- 896
				requestId = 0 -- 897
				resolve(nil, result) -- 898
			end -- 894
			Director.systemScheduler:schedule(function() -- 900
				if settled then -- 900
					return true -- 901
				end -- 901
				local ____this_9 -- 901
				____this_9 = req -- 902
				local ____opt_8 = ____this_9.isCancelled -- 902
				if (____opt_8 and ____opt_8(____this_9)) == true and requestId ~= 0 then -- 902
					HttpClient:cancel(requestId) -- 903
					finish({success = false, interrupted = true, message = "download canceled"}) -- 904
					return true -- 905
				end -- 905
				if requestId ~= 0 and not HttpClient:isRequestActive(requestId) then -- 905
					finish({success = false, message = "download request ended without a completion callback"}) -- 908
					return true -- 909
				end -- 909
				return false -- 911
			end) -- 900
			Director.systemScheduler:schedule(once(function() -- 913
				requestId = HttpClient:download( -- 914
					req.url, -- 914
					req.tempPath, -- 914
					req.timeout, -- 914
					function(interrupted, current, total) -- 914
						if type(current) == "number" and current > bytesWritten then -- 914
							bytesWritten = current -- 916
						end -- 916
						if interrupted then -- 916
							finish({success = false, interrupted = true, message = "download failed"}) -- 919
							return true -- 920
						end -- 920
						local ____this_11 -- 920
						____this_11 = req -- 922
						local ____opt_10 = ____this_11.isCancelled -- 922
						if (____opt_10 and ____opt_10(____this_11)) == true then -- 922
							finish({success = false, interrupted = true, message = "download canceled"}) -- 923
							return true -- 924
						end -- 924
						if current == total then -- 924
							finish({success = true, bytesWritten = bytesWritten}) -- 927
							return false -- 928
						end -- 928
						req:onProgress(current, total) -- 930
						return false -- 931
					end -- 914
				) -- 914
				if requestId == 0 then -- 914
					finish({success = false, message = "failed to schedule download request"}) -- 934
				else -- 934
					local ____this_13 -- 934
					____this_13 = req -- 935
					local ____opt_12 = ____this_13.isCancelled -- 935
					if (____opt_12 and ____opt_12(____this_13)) == true then -- 935
						HttpClient:cancel(requestId) -- 936
						finish({success = false, interrupted = true, message = "download canceled"}) -- 937
					end -- 937
				end -- 937
			end)) -- 913
		end -- 890
	) -- 890
end -- 883
local function getFileState(path) -- 943
	local exists = Content:exist(path) -- 944
	if not exists then -- 944
		return {exists = false, content = "", bytes = 0} -- 946
	end -- 946
	if Content:isdir(path) then -- 946
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 953
	end -- 953
	local content = Content:load(path) -- 960
	if type(content) ~= "string" then -- 960
		return {exists = true, content = "", bytes = 0} -- 962
	end -- 962
	return {exists = true, content = content, bytes = #content} -- 968
end -- 943
local function inspectReadableFile(path) -- 975
	do -- 975
		local function ____catch(e) -- 975
			Log( -- 997
				"Warn", -- 997
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 997
			) -- 997
			return true, {success = true} -- 998
		end -- 998
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 998
			local size, isBinary = Content:getAttr(path) -- 977
			if size == nil then -- 977
				return true, {success = false, message = "failed to read file"} -- 979
			end -- 979
			if isBinary then -- 979
				return true, { -- 985
					success = false, -- 986
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 987
					size = type(size) == "number" and size or nil, -- 988
					isBinary = true -- 989
				} -- 989
			end -- 989
			return true, { -- 992
				success = true, -- 993
				size = type(size) == "number" and size or nil -- 994
			} -- 994
		end) -- 994
		if not ____try then -- 994
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 994
		end -- 994
		if ____hasReturned then -- 994
			return ____returnValue -- 976
		end -- 976
	end -- 976
end -- 975
local function isEngineLogFilePath(path) -- 1002
	return path == ENGINE_LOG_FILE -- 1003
end -- 1002
local function readEngineLogFile(path) -- 1006
	if not isEngineLogFilePath(path) then -- 1006
		return nil -- 1007
	end -- 1007
	local content = getEngineLogText() -- 1008
	if content == nil then -- 1008
		return {success = false, message = "failed to read engine logs"} -- 1010
	end -- 1010
	return {success = true, content = content, size = #content} -- 1012
end -- 1006
local function queryOne(sql, args) -- 1015
	local ____args_14 -- 1016
	if args then -- 1016
		____args_14 = DB:query(sql, args) -- 1016
	else -- 1016
		____args_14 = DB:query(sql) -- 1016
	end -- 1016
	local rows = ____args_14 -- 1016
	if not rows or #rows == 0 then -- 1016
		return nil -- 1017
	end -- 1017
	return rows[1] -- 1018
end -- 1015
local function isDtsFile(path) -- 1021
	return Path:getExt(Path:getName(path)) == "d" -- 1022
end -- 1021
local function isTiledEditorContent(content) -- 1025
	return __TS__StringStartsWith( -- 1026
		__TS__StringTrim(content), -- 1026
		"<?xml" -- 1026
	) -- 1026
end -- 1025
local function getSupportedBuildKind(path) -- 1031
	repeat -- 1031
		local ____switch190 = Path:getExt(path) -- 1031
		local ____cond190 = ____switch190 == "ts" or ____switch190 == "tsx" -- 1031
		if ____cond190 then -- 1031
			return "ts" -- 1033
		end -- 1033
		____cond190 = ____cond190 or ____switch190 == "xml" -- 1033
		if ____cond190 then -- 1033
			return "xml" -- 1034
		end -- 1034
		____cond190 = ____cond190 or ____switch190 == "tl" -- 1034
		if ____cond190 then -- 1034
			return "teal" -- 1035
		end -- 1035
		____cond190 = ____cond190 or ____switch190 == "lua" -- 1035
		if ____cond190 then -- 1035
			return "lua" -- 1036
		end -- 1036
		____cond190 = ____cond190 or ____switch190 == "yue" -- 1036
		if ____cond190 then -- 1036
			return "yue" -- 1037
		end -- 1037
		____cond190 = ____cond190 or ____switch190 == "yarn" -- 1037
		if ____cond190 then -- 1037
			return "yarn" -- 1038
		end -- 1038
		do -- 1038
			return nil -- 1039
		end -- 1039
	until true -- 1039
end -- 1031
local function getTaskHeadSeq(taskId) -- 1043
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1044
	if not row then -- 1044
		return nil -- 1045
	end -- 1045
	return row[1] or 0 -- 1046
end -- 1043
local function getTaskStatus(taskId) -- 1049
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1050
	if not row then -- 1050
		return nil -- 1051
	end -- 1051
	return toStr(row[1]) -- 1052
end -- 1049
local function getLastInsertRowId() -- 1055
	local row = queryOne("SELECT last_insert_rowid()") -- 1056
	return row and (row[1] or 0) or 0 -- 1057
end -- 1055
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 1060
	DB:exec( -- 1061
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 1061
		{ -- 1063
			taskId, -- 1063
			seq, -- 1063
			status, -- 1063
			summary, -- 1063
			toolName, -- 1063
			now() -- 1063
		} -- 1063
	) -- 1063
	return getLastInsertRowId() -- 1065
end -- 1060
local function getCheckpointEntries(checkpointId, desc) -- 1068
	if desc == nil then -- 1068
		desc = false -- 1068
	end -- 1068
	local rows = DB:query((("SELECT id, ord, path, op, before_exists,\n\t\t\tdora_decompress_text(before_data),\n\t\t\tafter_exists,\n\t\t\tdora_decompress_text(after_data)\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 1069
	if not rows then -- 1069
		return {} -- 1079
	end -- 1079
	local result = {} -- 1080
	do -- 1080
		local i = 0 -- 1081
		while i < #rows do -- 1081
			local row = rows[i + 1] -- 1082
			result[#result + 1] = { -- 1083
				id = row[1], -- 1084
				ord = row[2], -- 1085
				path = toStr(row[3]), -- 1086
				op = toStr(row[4]), -- 1087
				beforeExists = toBool(row[5]), -- 1088
				beforeContent = toStr(row[6]), -- 1089
				afterExists = toBool(row[7]), -- 1090
				afterContent = toStr(row[8]) -- 1091
			} -- 1091
			i = i + 1 -- 1081
		end -- 1081
	end -- 1081
	return result -- 1094
end -- 1068
local function getCheckpointEntryMetadata(checkpointId, desc) -- 1097
	if desc == nil then -- 1097
		desc = false -- 1097
	end -- 1097
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, after_exists, bytes_before, bytes_after\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 1098
	if not rows then -- 1098
		return {} -- 1105
	end -- 1105
	local result = {} -- 1106
	do -- 1106
		local i = 0 -- 1107
		while i < #rows do -- 1107
			local row = rows[i + 1] -- 1108
			result[#result + 1] = { -- 1109
				id = row[1], -- 1110
				ord = row[2], -- 1111
				path = toStr(row[3]), -- 1112
				op = toStr(row[4]), -- 1113
				beforeExists = toBool(row[5]), -- 1114
				afterExists = toBool(row[6]), -- 1115
				bytesBefore = row[7] or 0, -- 1116
				bytesAfter = row[8] or 0 -- 1117
			} -- 1117
			i = i + 1 -- 1107
		end -- 1107
	end -- 1107
	return result -- 1120
end -- 1097
local function rejectDuplicatePaths(changes) -- 1123
	local seen = __TS__New(Set) -- 1124
	for ____, change in ipairs(changes) do -- 1125
		local key = change.path -- 1126
		if seen:has(key) then -- 1126
			return key -- 1127
		end -- 1127
		seen:add(key) -- 1128
	end -- 1128
	return nil -- 1130
end -- 1123
local function getLinkedDeletePaths(workDir, path) -- 1133
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1134
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 1134
		return {} -- 1135
	end -- 1135
	local parent = Path:getPath(fullPath) -- 1136
	local baseName = string.lower(Path:getName(fullPath)) -- 1137
	local ext = Path:getExt(fullPath) -- 1138
	local linked = {} -- 1139
	for ____, file in ipairs(Content:getFiles(parent)) do -- 1140
		do -- 1140
			if string.lower(Path:getName(file)) ~= baseName then -- 1140
				goto __continue211 -- 1141
			end -- 1141
			local siblingExt = Path:getExt(file) -- 1142
			if siblingExt == "tl" and ext == "vs" then -- 1142
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1144
					workDir, -- 1144
					Path(parent, file) -- 1144
				) -- 1144
				goto __continue211 -- 1145
			end -- 1145
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 1145
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1148
					workDir, -- 1148
					Path(parent, file) -- 1148
				) -- 1148
			end -- 1148
		end -- 1148
		::__continue211:: -- 1148
	end -- 1148
	return linked -- 1151
end -- 1133
local function expandLinkedDeleteChanges(workDir, changes) -- 1154
	local expanded = {} -- 1155
	local seen = __TS__New(Set) -- 1156
	do -- 1156
		local i = 0 -- 1157
		while i < #changes do -- 1157
			do -- 1157
				local change = changes[i + 1] -- 1158
				if not seen:has(change.path) then -- 1158
					seen:add(change.path) -- 1160
					expanded[#expanded + 1] = change -- 1161
				end -- 1161
				if change.op ~= "delete" then -- 1161
					goto __continue218 -- 1163
				end -- 1163
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 1164
				do -- 1164
					local j = 0 -- 1165
					while j < #linkedPaths do -- 1165
						do -- 1165
							local linkedPath = linkedPaths[j + 1] -- 1166
							if seen:has(linkedPath) then -- 1166
								goto __continue222 -- 1167
							end -- 1167
							seen:add(linkedPath) -- 1168
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 1169
						end -- 1169
						::__continue222:: -- 1169
						j = j + 1 -- 1165
					end -- 1165
				end -- 1165
			end -- 1165
			::__continue218:: -- 1165
			i = i + 1 -- 1157
		end -- 1157
	end -- 1157
	return expanded -- 1172
end -- 1154
local function applySingleFile(path, exists, content) -- 1175
	if exists then -- 1175
		if not ensureDirForFile(path) then -- 1175
			return false -- 1177
		end -- 1177
		return Content:save(path, content) -- 1178
	end -- 1178
	if Content:exist(path) then -- 1178
		return Content:remove(path) -- 1181
	end -- 1181
	return true -- 1183
end -- 1175
local function rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 1186
	local entries = getCheckpointEntries(checkpointId, true) -- 1191
	local remaining = appliedCount -- 1192
	local failures = {} -- 1193
	do -- 1193
		local i = 0 -- 1194
		while i < #entries and remaining > 0 do -- 1194
			do -- 1194
				local entry = entries[i + 1] -- 1195
				if entry.ord > appliedCount then -- 1195
					goto __continue230 -- 1196
				end -- 1196
				local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1197
				if not fullPath or not applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) then -- 1197
					failures[#failures + 1] = entry.path -- 1199
				else -- 1199
					____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) -- 1201
				end -- 1201
				remaining = remaining - 1 -- 1203
			end -- 1203
			::__continue230:: -- 1203
			i = i + 1 -- 1194
		end -- 1194
	end -- 1194
	return #failures > 0 and "rollback failed for: " .. table.concat(failures, ", ") or nil -- 1205
end -- 1186
function ____exports.sendWebIDERefreshTree() -- 1225
	if HttpServer.wsConnectionCount == 0 then -- 1225
		return true -- 1227
	end -- 1227
	local payload = encodeJSON({name = "RefreshTree"}) -- 1229
	if not payload then -- 1229
		return false -- 1231
	end -- 1231
	emit("AppWS", "Send", payload) -- 1233
	return true -- 1234
end -- 1225
local function syncProjectFileToWebIDE(workDir, path) -- 1237
	local target = resolveWorkspaceFilePath(workDir, path) -- 1238
	if not target then -- 1238
		return false -- 1239
	end -- 1239
	if not Content:exist(target) then -- 1239
		return ____exports.sendWebIDEFileUpdate(target, false, "") -- 1241
	end -- 1241
	if Content:isdir(target) then -- 1241
		return ____exports.sendWebIDERefreshTree() -- 1244
	end -- 1244
	local content = "" -- 1246
	do -- 1246
		local function ____catch(e) -- 1246
			Log( -- 1254
				"Warn", -- 1254
				(("[Agent.Tools] failed to inspect file for Web IDE update file=" .. target) .. ": ") .. tostring(e) -- 1254
			) -- 1254
		end -- 1254
		local ____try, ____hasReturned = pcall(function() -- 1254
			local ____, isBinary = Content:getAttr(target) -- 1248
			if not isBinary then -- 1248
				local loaded = Content:load(target) -- 1250
				content = type(loaded) == "string" and loaded or "" -- 1251
			end -- 1251
		end) -- 1251
		if not ____try then -- 1251
			____catch(____hasReturned) -- 1251
		end -- 1251
	end -- 1251
	return ____exports.sendWebIDEFileUpdate(target, true, content) -- 1256
end -- 1237
local function refreshProjectTree(workDir, path) -- 1259
	local normalized = type(path) == "string" and __TS__StringTrim(path) or "" -- 1260
	if normalized == "" then -- 1260
		return ____exports.sendWebIDERefreshTree() -- 1262
	end -- 1262
	return syncProjectFileToWebIDE(workDir, normalized) -- 1264
end -- 1259
local function syncDownloadedFileToWebIDE(file) -- 1267
	local content = "" -- 1268
	do -- 1268
		local function ____catch(e) -- 1268
			Log( -- 1276
				"Warn", -- 1276
				(("[fetch_url] failed to inspect downloaded file for Web IDE update file=" .. file) .. ": ") .. tostring(e) -- 1276
			) -- 1276
		end -- 1276
		local ____try, ____hasReturned = pcall(function() -- 1276
			local ____, isBinary = Content:getAttr(file) -- 1270
			if not isBinary then -- 1270
				local loaded = Content:load(file) -- 1272
				content = type(loaded) == "string" and loaded or "" -- 1273
			end -- 1273
		end) -- 1273
		if not ____try then -- 1273
			____catch(____hasReturned) -- 1273
		end -- 1273
	end -- 1273
	return ____exports.sendWebIDEFileUpdate(file, true, content) -- 1278
end -- 1267
local function runSingleNonTsBuild(file) -- 1281
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1281
		return ____awaiter_resolve( -- 1281
			nil, -- 1281
			__TS__New( -- 1282
				__TS__Promise, -- 1282
				function(____, resolve) -- 1282
					local moduleName = "Script.Dev.WebServer" -- 1283
					local ____require_result_15 = require(moduleName) -- 1284
					local buildAsync = ____require_result_15.buildAsync -- 1284
					Director.systemScheduler:schedule(once(function() -- 1285
						local result = buildAsync(file) -- 1286
						resolve(nil, result) -- 1287
					end)) -- 1285
				end -- 1282
			) -- 1282
		) -- 1282
	end) -- 1282
end -- 1281
local transpileRequestSeq = 0 -- 1292
function ____exports.runSingleTsTranspile(file, content, projectRoot) -- 1294
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1294
		local done = false -- 1295
		transpileRequestSeq = transpileRequestSeq + 1 -- 1296
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 1297
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 1298
		if HttpServer.wsConnectionCount == 0 then -- 1298
			return ____awaiter_resolve(nil, result) -- 1298
		end -- 1298
		local listener = Node() -- 1306
		listener:gslot( -- 1307
			"AppWS", -- 1307
			function(event) -- 1307
				if event.type ~= "Receive" then -- 1307
					return -- 1308
				end -- 1308
				local res = safeJsonDecode(event.msg) -- 1309
				if not res or __TS__ArrayIsArray(res) then -- 1309
					return -- 1310
				end -- 1310
				local payload = res -- 1311
				if payload.name ~= "TranspileTS" then -- 1311
					return -- 1312
				end -- 1312
				if payload.id ~= requestId then -- 1312
					return -- 1313
				end -- 1313
				if payload.success then -- 1313
					local luaFile = Path:replaceExt(file, "lua") -- 1315
					if Content:save( -- 1315
						luaFile, -- 1316
						tostring(payload.luaCode) -- 1316
					) then -- 1316
						result = {success = true, file = file} -- 1317
					else -- 1317
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 1319
					end -- 1319
				else -- 1319
					result = { -- 1322
						success = false, -- 1322
						file = file, -- 1322
						message = tostring(payload.message) -- 1322
					} -- 1322
				end -- 1322
				done = true -- 1324
			end -- 1307
		) -- 1307
		local payload = encodeJSON({ -- 1326
			name = "TranspileTS", -- 1327
			id = requestId, -- 1328
			file = file, -- 1329
			content = content, -- 1330
			projectRoot = projectRoot -- 1331
		}) -- 1331
		if not payload then -- 1331
			listener:removeFromParent() -- 1334
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 1334
		end -- 1334
		__TS__Await(__TS__New( -- 1337
			__TS__Promise, -- 1337
			function(____, resolve) -- 1337
				Director.systemScheduler:schedule(once(function() -- 1338
					emit("AppWS", "Send", payload) -- 1339
					wait(function() return done end) -- 1340
					if not done then -- 1340
						listener:removeFromParent() -- 1342
					end -- 1342
					resolve(nil) -- 1344
				end)) -- 1338
			end -- 1337
		)) -- 1337
		return ____awaiter_resolve(nil, result) -- 1337
	end) -- 1337
end -- 1294
function ____exports.createTask(prompt, workMode) -- 1350
	if prompt == nil then -- 1350
		prompt = "" -- 1350
	end -- 1350
	if workMode == nil then -- 1350
		workMode = "code" -- 1350
	end -- 1350
	local storage = requireAgentStorage() -- 1351
	if not storage.success then -- 1351
		return storage -- 1352
	end -- 1352
	local t = now() -- 1353
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, work_mode, created_at, updated_at) VALUES(?, ?, 0, ?, ?, ?)", { -- 1354
		"RUNNING", -- 1356
		prompt, -- 1356
		workMode, -- 1356
		t, -- 1356
		t -- 1356
	}) -- 1356
	if affected <= 0 then -- 1356
		return {success = false, message = "failed to create task"} -- 1359
	end -- 1359
	return { -- 1361
		success = true, -- 1361
		taskId = getLastInsertRowId() -- 1361
	} -- 1361
end -- 1350
function ____exports.setTaskStatus(taskId, status) -- 1364
	DB:exec( -- 1365
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 1365
		{ -- 1365
			status, -- 1365
			now(), -- 1365
			taskId -- 1365
		} -- 1365
	) -- 1365
	Log( -- 1366
		"Info", -- 1366
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 1366
	) -- 1366
end -- 1364
function ____exports.listCheckpointsForTasks(taskIds) -- 1369
	local normalizedTaskIds = {} -- 1370
	local seenTaskIds = {} -- 1371
	do -- 1371
		local i = 0 -- 1372
		while i < #taskIds do -- 1372
			do -- 1372
				local taskId = math.floor(taskIds[i + 1]) -- 1373
				if taskId <= 0 or seenTaskIds[taskId] then -- 1373
					goto __continue279 -- 1374
				end -- 1374
				seenTaskIds[taskId] = true -- 1375
				normalizedTaskIds[#normalizedTaskIds + 1] = taskId -- 1376
			end -- 1376
			::__continue279:: -- 1376
			i = i + 1 -- 1372
		end -- 1372
	end -- 1372
	if #normalizedTaskIds == 0 then -- 1372
		return {} -- 1378
	end -- 1378
	local placeholders = table.concat( -- 1379
		__TS__ArrayMap( -- 1379
			normalizedTaskIds, -- 1379
			function() return "?" end -- 1379
		), -- 1379
		", " -- 1379
	) -- 1379
	local rows = DB:query(((("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id IN (") .. placeholders) .. ")\n\t\tORDER BY task_id DESC, seq DESC", normalizedTaskIds) -- 1380
	if not rows then -- 1380
		return {} -- 1387
	end -- 1387
	local items = {} -- 1388
	do -- 1388
		local i = 0 -- 1389
		while i < #rows do -- 1389
			local row = rows[i + 1] -- 1390
			items[#items + 1] = { -- 1391
				id = row[1], -- 1392
				taskId = row[2], -- 1393
				seq = row[3], -- 1394
				status = toStr(row[4]), -- 1395
				summary = toStr(row[5]), -- 1396
				toolName = toStr(row[6]), -- 1397
				createdAt = row[7] -- 1398
			} -- 1398
			i = i + 1 -- 1389
		end -- 1389
	end -- 1389
	return items -- 1401
end -- 1369
function ____exports.listCheckpoints(taskId) -- 1404
	return ____exports.listCheckpointsForTasks({taskId}) -- 1405
end -- 1404
function ____exports.getCheckpoint(checkpointId) -- 1408
	if checkpointId <= 0 then -- 1408
		return nil -- 1409
	end -- 1409
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE id = ?\n\t\tLIMIT 1", {checkpointId}) -- 1410
	if not rows or #rows == 0 then -- 1410
		return nil -- 1417
	end -- 1417
	local row = rows[1] -- 1418
	return { -- 1419
		id = row[1], -- 1420
		taskId = row[2], -- 1421
		seq = row[3], -- 1422
		status = toStr(row[4]), -- 1423
		summary = toStr(row[5]), -- 1424
		toolName = toStr(row[6]), -- 1425
		createdAt = row[7] -- 1426
	} -- 1426
end -- 1408
local function listCheckpointIdsForTask(taskId, desc) -- 1430
	if desc == nil then -- 1430
		desc = false -- 1430
	end -- 1430
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 1431
	if not rows then -- 1431
		return {} -- 1438
	end -- 1438
	local items = {} -- 1439
	do -- 1439
		local i = 0 -- 1440
		while i < #rows do -- 1440
			local row = rows[i + 1] -- 1441
			items[#items + 1] = {id = row[1], seq = row[2]} -- 1442
			i = i + 1 -- 1440
		end -- 1440
	end -- 1440
	return items -- 1447
end -- 1430
local function deriveFileOp(beforeExists, afterExists) -- 1450
	if not beforeExists and afterExists then -- 1450
		return "create" -- 1451
	end -- 1451
	if beforeExists and not afterExists then -- 1451
		return "delete" -- 1452
	end -- 1452
	return "write" -- 1453
end -- 1450
function ____exports.summarizeTaskChangeSet(taskId) -- 1456
	if not getTaskStatus(taskId) then -- 1456
		return {success = false, message = "task not found"} -- 1458
	end -- 1458
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1460
	local filesByPath = {} -- 1461
	local latestCheckpointId = nil -- 1467
	local latestCheckpointSeq = nil -- 1468
	do -- 1468
		local i = 0 -- 1469
		while i < #checkpoints do -- 1469
			local checkpoint = checkpoints[i + 1] -- 1470
			latestCheckpointId = checkpoint.id -- 1471
			latestCheckpointSeq = checkpoint.seq -- 1472
			local entries = getCheckpointEntryMetadata(checkpoint.id, false) -- 1473
			do -- 1473
				local j = 0 -- 1474
				while j < #entries do -- 1474
					local entry = entries[j + 1] -- 1475
					local item = filesByPath[entry.path] -- 1476
					if not item then -- 1476
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 1478
						filesByPath[entry.path] = item -- 1484
					end -- 1484
					item.afterExists = entry.afterExists -- 1486
					local ____item_checkpointIds_16 = item.checkpointIds -- 1486
					____item_checkpointIds_16[#____item_checkpointIds_16 + 1] = checkpoint.id -- 1487
					j = j + 1 -- 1474
				end -- 1474
			end -- 1474
			i = i + 1 -- 1469
		end -- 1469
	end -- 1469
	local files = {} -- 1490
	for ____, item in pairs(filesByPath) do -- 1491
		files[#files + 1] = { -- 1492
			path = item.path, -- 1493
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1494
			checkpointCount = #item.checkpointIds, -- 1495
			checkpointIds = item.checkpointIds -- 1496
		} -- 1496
	end -- 1496
	__TS__ArraySort( -- 1499
		files, -- 1499
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1499
	) -- 1499
	return { -- 1500
		success = true, -- 1501
		taskId = taskId, -- 1502
		checkpointCount = #checkpoints, -- 1503
		filesChanged = #files, -- 1504
		files = files, -- 1505
		latestCheckpointId = latestCheckpointId, -- 1506
		latestCheckpointSeq = latestCheckpointSeq -- 1507
	} -- 1507
end -- 1456
function ____exports.getTaskChangeSetDiff(taskId) -- 1511
	if not getTaskStatus(taskId) then -- 1511
		return {success = false, message = "task not found"} -- 1513
	end -- 1513
	local entryRows = DB:query(((("SELECT e.id, e.path, e.before_exists, e.after_exists\n\t\tFROM " .. TABLE_ENTRY) .. " e\n\t\tJOIN ") .. TABLE_CP) .. " c ON c.id = e.checkpoint_id\n\t\tWHERE c.task_id = ? AND c.status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY c.seq ASC, e.ord ASC", {taskId}) -- 1515
	if not entryRows or #entryRows == 0 then -- 1515
		return {success = false, message = "change set not found or empty"} -- 1524
	end -- 1524
	local filesByPath = {} -- 1526
	do -- 1526
		local i = 0 -- 1533
		while i < #entryRows do -- 1533
			local row = entryRows[i + 1] -- 1534
			local entryId = row[1] -- 1535
			local path = toStr(row[2]) -- 1536
			local item = filesByPath[path] -- 1537
			if not item then -- 1537
				item = { -- 1539
					path = path, -- 1540
					firstEntryId = entryId, -- 1541
					lastEntryId = entryId, -- 1542
					beforeExists = toBool(row[3]), -- 1543
					afterExists = toBool(row[4]) -- 1544
				} -- 1544
				filesByPath[path] = item -- 1546
			end -- 1546
			item.lastEntryId = entryId -- 1548
			item.afterExists = toBool(row[4]) -- 1549
			i = i + 1 -- 1533
		end -- 1533
	end -- 1533
	local files = {} -- 1551
	for ____, item in pairs(filesByPath) do -- 1552
		local contentRows = DB:query(((("SELECT\n\t\t\t\t(SELECT dora_decompress_text(before_data) FROM " .. TABLE_ENTRY) .. " WHERE id = ?),\n\t\t\t\t(SELECT dora_decompress_text(after_data) FROM ") .. TABLE_ENTRY) .. " WHERE id = ?)", {item.firstEntryId, item.lastEntryId}) -- 1553
		if not contentRows or #contentRows == 0 then -- 1553
			return {success = false, message = "failed to read checkpoint data for " .. item.path} -- 1560
		end -- 1560
		files[#files + 1] = { -- 1562
			path = item.path, -- 1563
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1564
			beforeExists = item.beforeExists, -- 1565
			afterExists = item.afterExists, -- 1566
			beforeContent = toStr(contentRows[1][1]), -- 1567
			afterContent = toStr(contentRows[1][2]) -- 1568
		} -- 1568
	end -- 1568
	__TS__ArraySort( -- 1571
		files, -- 1571
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1571
	) -- 1571
	return {success = true, files = files} -- 1572
end -- 1511
local function readWorkspaceFile(workDir, path, docLanguage) -- 1575
	local engineLog = readEngineLogFile(path) -- 1576
	if engineLog then -- 1576
		return engineLog -- 1577
	end -- 1577
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1578
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 1578
		local attr = inspectReadableFile(fullPath) -- 1580
		if not attr.success then -- 1580
			return attr -- 1581
		end -- 1581
		return { -- 1582
			success = true, -- 1582
			content = Content:load(fullPath), -- 1582
			size = attr.size -- 1582
		} -- 1582
	end -- 1582
	local docPath = resolveAgentDoraDocFilePath(path, docLanguage) -- 1584
	if docPath then -- 1584
		local attr = inspectReadableFile(docPath) -- 1586
		if not attr.success then -- 1586
			return attr -- 1587
		end -- 1587
		return { -- 1588
			success = true, -- 1588
			content = Content:load(docPath), -- 1588
			size = attr.size -- 1588
		} -- 1588
	end -- 1588
	if not fullPath then -- 1588
		return {success = false, message = "invalid path or workDir"} -- 1590
	end -- 1590
	return {success = false, message = "file not found"} -- 1591
end -- 1575
function ____exports.readFileRaw(workDir, path, docLanguage) -- 1594
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 1595
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 1595
		local attr = inspectReadableFile(path) -- 1597
		if not attr.success then -- 1597
			return attr -- 1598
		end -- 1598
		return { -- 1599
			success = true, -- 1599
			content = Content:load(path), -- 1599
			size = attr.size -- 1599
		} -- 1599
	end -- 1599
	return result -- 1601
end -- 1594
function ____exports.getLogs(req) -- 1616
	local text = getEngineLogText() -- 1617
	if text == nil then -- 1617
		return {success = false, message = "failed to read engine logs"} -- 1619
	end -- 1619
	local tailLines = math.max( -- 1621
		1, -- 1621
		math.floor(req and req.tailLines or 200) -- 1621
	) -- 1621
	local allLines = __TS__StringSplit(text, "\n") -- 1622
	local logs = __TS__ArraySlice( -- 1623
		allLines, -- 1623
		math.max(0, #allLines - tailLines) -- 1623
	) -- 1623
	return req and req.joinText and ({ -- 1624
		success = true, -- 1624
		logs = logs, -- 1624
		text = table.concat(logs, "\n") -- 1624
	}) or ({success = true, logs = logs}) -- 1624
end -- 1616
function ____exports.listFiles(req) -- 1627
	local root = req.path or "" -- 1633
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 1634
	if not searchRoot then -- 1634
		return {success = false, message = "invalid path or workDir"} -- 1636
	end -- 1636
	do -- 1636
		local function ____catch(e) -- 1636
			return true, { -- 1654
				success = false, -- 1654
				message = tostring(e) -- 1654
			} -- 1654
		end -- 1654
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1654
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 1639
			local globs = ensureSafeSearchGlobs(userGlobs) -- 1640
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 1641
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 1642
			local totalEntries = #files -- 1643
			local maxEntries = math.max( -- 1644
				1, -- 1644
				math.floor(req.maxEntries or 200) -- 1644
			) -- 1644
			local truncated = totalEntries > maxEntries -- 1645
			return true, { -- 1646
				success = true, -- 1647
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 1648
				totalEntries = totalEntries, -- 1649
				truncated = truncated, -- 1650
				maxEntries = maxEntries -- 1651
			} -- 1651
		end) -- 1651
		if not ____try then -- 1651
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1651
		end -- 1651
		if ____hasReturned then -- 1651
			return ____returnValue -- 1638
		end -- 1638
	end -- 1638
end -- 1627
local function formatReadSlice(content, startLine, endLine) -- 1658
	local lines = __TS__StringSplit(content, "\n") -- 1663
	local totalLines = #lines -- 1664
	if totalLines == 0 then -- 1664
		return { -- 1666
			success = true, -- 1667
			content = "", -- 1668
			totalLines = 0, -- 1669
			startLine = 1, -- 1670
			endLine = 0, -- 1671
			truncated = false -- 1672
		} -- 1672
	end -- 1672
	local rawStart = math.floor(startLine) -- 1675
	local rawEnd = math.floor(endLine) -- 1676
	if rawStart == 0 then -- 1676
		return {success = false, message = "startLine cannot be 0"} -- 1678
	end -- 1678
	if rawEnd == 0 then -- 1678
		return {success = false, message = "endLine cannot be 0"} -- 1681
	end -- 1681
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1683
	if start > totalLines then -- 1683
		return { -- 1687
			success = false, -- 1687
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1687
		} -- 1687
	end -- 1687
	local ____end = math.min( -- 1689
		totalLines, -- 1690
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1691
	) -- 1691
	if ____end < start then -- 1691
		return { -- 1696
			success = false, -- 1697
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1698
		} -- 1698
	end -- 1698
	local slice = {} -- 1701
	do -- 1701
		local i = start -- 1702
		while i <= ____end do -- 1702
			slice[#slice + 1] = lines[i] -- 1703
			i = i + 1 -- 1702
		end -- 1702
	end -- 1702
	local truncated = start > 1 or ____end < totalLines -- 1705
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1706
	local body = table.concat(slice, "\n") -- 1711
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1712
	return { -- 1713
		success = true, -- 1714
		content = output, -- 1715
		totalLines = totalLines, -- 1716
		startLine = start, -- 1717
		endLine = ____end, -- 1718
		truncated = truncated -- 1719
	} -- 1719
end -- 1658
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1723
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1730
	if not fallback.success or fallback.content == nil then -- 1730
		return fallback -- 1731
	end -- 1731
	local resolvedStartLine = startLine or 1 -- 1732
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1733
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1734
end -- 1723
local codeExtensions = { -- 1741
	".lua", -- 1741
	".tl", -- 1741
	".yue", -- 1741
	".ts", -- 1741
	".tsx", -- 1741
	".xml", -- 1741
	".md", -- 1741
	".yarn", -- 1741
	".wa", -- 1741
	".mod" -- 1741
} -- 1741
extensionLevels = { -- 1742
	vs = 2, -- 1743
	bl = 2, -- 1744
	ts = 1, -- 1745
	tsx = 1, -- 1746
	tl = 1, -- 1747
	yue = 1, -- 1748
	xml = 1, -- 1749
	lua = 0 -- 1750
} -- 1750
local function splitSearchPatterns(pattern) -- 1767
	local trimmed = __TS__StringTrim(pattern or "") -- 1768
	if trimmed == "" then -- 1768
		return {} -- 1769
	end -- 1769
	local out = {} -- 1770
	local seen = __TS__New(Set) -- 1771
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1772
		local p = __TS__StringTrim(tostring(p0)) -- 1773
		if p ~= "" and not seen:has(p) then -- 1773
			seen:add(p) -- 1775
			out[#out + 1] = p -- 1776
		end -- 1776
	end -- 1776
	return out -- 1779
end -- 1767
local function splitWhitespaceSearchPatterns(pattern) -- 1782
	local out = {} -- 1783
	local seen = __TS__New(Set) -- 1784
	for p0 in string.gmatch(pattern, "(%S+)") do -- 1785
		local p = __TS__StringTrim(tostring(p0)) -- 1786
		local key = string.lower(p) -- 1787
		if p ~= "" and not seen:has(key) then -- 1787
			seen:add(key) -- 1789
			out[#out + 1] = p -- 1790
		end -- 1790
	end -- 1790
	return out -- 1793
end -- 1782
local function mergeSearchFileResultsUnique(resultsList) -- 1796
	local merged = {} -- 1797
	local seen = __TS__New(Set) -- 1798
	do -- 1798
		local i = 0 -- 1799
		while i < #resultsList do -- 1799
			local list = resultsList[i + 1] -- 1800
			do -- 1800
				local j = 0 -- 1801
				while j < #list do -- 1801
					do -- 1801
						local row = list[j + 1] -- 1802
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1803
						if seen:has(key) then -- 1803
							goto __continue361 -- 1804
						end -- 1804
						seen:add(key) -- 1805
						merged[#merged + 1] = list[j + 1] -- 1806
					end -- 1806
					::__continue361:: -- 1806
					j = j + 1 -- 1801
				end -- 1801
			end -- 1801
			i = i + 1 -- 1799
		end -- 1799
	end -- 1799
	return merged -- 1809
end -- 1796
local function buildGroupedSearchResults(results) -- 1812
	local order = {} -- 1817
	local grouped = __TS__New(Map) -- 1818
	do -- 1818
		local i = 0 -- 1823
		while i < #results do -- 1823
			local row = results[i + 1] -- 1824
			local file = row.file -- 1825
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1826
			local bucket = grouped:get(key) -- 1827
			if not bucket then -- 1827
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1829
				grouped:set(key, bucket) -- 1830
				order[#order + 1] = key -- 1831
			end -- 1831
			bucket.totalMatches = bucket.totalMatches + 1 -- 1833
			local ____bucket_matches_21 = bucket.matches -- 1833
			____bucket_matches_21[#____bucket_matches_21 + 1] = results[i + 1] -- 1834
			i = i + 1 -- 1823
		end -- 1823
	end -- 1823
	local out = {} -- 1836
	do -- 1836
		local i = 0 -- 1841
		while i < #order do -- 1841
			local bucket = grouped:get(order[i + 1]) -- 1842
			if bucket then -- 1842
				out[#out + 1] = bucket -- 1843
			end -- 1843
			i = i + 1 -- 1841
		end -- 1841
	end -- 1841
	return out -- 1845
end -- 1812
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1848
	local merged = {} -- 1849
	local seen = __TS__New(Set) -- 1850
	local index = 0 -- 1851
	local advanced = true -- 1852
	while advanced do -- 1852
		advanced = false -- 1854
		do -- 1854
			local i = 0 -- 1855
			while i < #resultsList do -- 1855
				do -- 1855
					local list = resultsList[i + 1] -- 1856
					if index >= #list then -- 1856
						goto __continue373 -- 1857
					end -- 1857
					advanced = true -- 1858
					local row = list[index + 1] -- 1859
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1860
					if seen:has(key) then -- 1860
						goto __continue373 -- 1861
					end -- 1861
					seen:add(key) -- 1862
					merged[#merged + 1] = row -- 1863
				end -- 1863
				::__continue373:: -- 1863
				i = i + 1 -- 1855
			end -- 1855
		end -- 1855
		index = index + 1 -- 1865
	end -- 1865
	return merged -- 1867
end -- 1848
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1870
	if docSource ~= "api" then -- 1870
		return 100 -- 1871
	end -- 1871
	if programmingLanguage ~= "tsx" then -- 1871
		return 100 -- 1872
	end -- 1872
	repeat -- 1872
		local ____switch379 = string.lower(Path:getFilename(file)) -- 1872
		local ____cond379 = ____switch379 == "jsx.d.ts" -- 1872
		if ____cond379 then -- 1872
			return 0 -- 1874
		end -- 1874
		____cond379 = ____cond379 or ____switch379 == "dorax.d.ts" -- 1874
		if ____cond379 then -- 1874
			return 1 -- 1875
		end -- 1875
		____cond379 = ____cond379 or ____switch379 == "dora.d.ts" -- 1875
		if ____cond379 then -- 1875
			return 2 -- 1876
		end -- 1876
		do -- 1876
			return 100 -- 1877
		end -- 1877
	until true -- 1877
end -- 1870
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1881
	local sorted = __TS__ArraySlice(hits) -- 1886
	__TS__ArraySort( -- 1887
		sorted, -- 1887
		function(____, a, b) -- 1887
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1888
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1889
			if pa ~= pb then -- 1889
				return pa - pb -- 1890
			end -- 1890
			local fa = string.lower(a.file) -- 1891
			local fb = string.lower(b.file) -- 1892
			if fa ~= fb then -- 1892
				return fa < fb and -1 or 1 -- 1893
			end -- 1893
			return (a.line or 0) - (b.line or 0) -- 1894
		end -- 1887
	) -- 1887
	return sorted -- 1896
end -- 1881
function ____exports.searchFiles(req) -- 1899
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1899
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1912
		if not resolvedPath then -- 1912
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1912
		end -- 1912
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1916
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1917
		if not searchRoot then -- 1917
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1917
		end -- 1917
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1917
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1917
		end -- 1917
		local patterns = splitSearchPatterns(req.pattern) -- 1924
		if #patterns == 0 then -- 1924
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1924
		end -- 1924
		return ____awaiter_resolve( -- 1924
			nil, -- 1924
			__TS__New( -- 1928
				__TS__Promise, -- 1928
				function(____, resolve) -- 1928
					Director.systemScheduler:schedule(once(function() -- 1929
						do -- 1929
							local function ____catch(e) -- 1929
								resolve( -- 1971
									nil, -- 1971
									{ -- 1971
										success = false, -- 1971
										message = tostring(e) -- 1971
									} -- 1971
								) -- 1971
							end -- 1971
							local ____try, ____hasReturned = pcall(function() -- 1971
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1931
								local allResults = {} -- 1934
								do -- 1934
									local i = 0 -- 1935
									while i < #patterns do -- 1935
										local ____Content_26 = Content -- 1936
										local ____Content_searchFilesAsync_27 = Content.searchFilesAsync -- 1936
										local ____patterns_index_25 = patterns[i + 1] -- 1941
										local ____req_useRegex_22 = req.useRegex -- 1942
										if ____req_useRegex_22 == nil then -- 1942
											____req_useRegex_22 = false -- 1942
										end -- 1942
										local ____req_caseSensitive_23 = req.caseSensitive -- 1943
										if ____req_caseSensitive_23 == nil then -- 1943
											____req_caseSensitive_23 = false -- 1943
										end -- 1943
										local ____req_includeContent_24 = req.includeContent -- 1944
										if ____req_includeContent_24 == nil then -- 1944
											____req_includeContent_24 = true -- 1944
										end -- 1944
										allResults[#allResults + 1] = ____Content_searchFilesAsync_27( -- 1936
											____Content_26, -- 1936
											searchRoot, -- 1937
											codeExtensions, -- 1938
											extensionLevels, -- 1939
											searchGlobs, -- 1940
											____patterns_index_25, -- 1941
											____req_useRegex_22, -- 1942
											____req_caseSensitive_23, -- 1943
											____req_includeContent_24, -- 1944
											req.contentWindow or 120 -- 1945
										) -- 1945
										i = i + 1 -- 1935
									end -- 1935
								end -- 1935
								local results = mergeSearchFileResultsUnique(allResults) -- 1948
								local totalResults = #results -- 1949
								local limit = math.max( -- 1950
									1, -- 1950
									math.floor(req.limit or 20) -- 1950
								) -- 1950
								local offset = math.max( -- 1951
									0, -- 1951
									math.floor(req.offset or 0) -- 1951
								) -- 1951
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1952
								local nextOffset = offset + #paged -- 1953
								local hasMore = nextOffset < totalResults -- 1954
								local truncated = offset > 0 or hasMore -- 1955
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1956
								local groupByFile = req.groupByFile == true -- 1957
								resolve( -- 1958
									nil, -- 1958
									{ -- 1958
										success = true, -- 1959
										results = relativeResults, -- 1960
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1961
										totalResults = totalResults, -- 1962
										truncated = truncated, -- 1963
										limit = limit, -- 1964
										offset = offset, -- 1965
										nextOffset = nextOffset, -- 1966
										hasMore = hasMore, -- 1967
										groupByFile = groupByFile -- 1968
									} -- 1968
								) -- 1968
							end) -- 1968
							if not ____try then -- 1968
								____catch(____hasReturned) -- 1968
							end -- 1968
						end -- 1968
					end)) -- 1929
				end -- 1928
			) -- 1928
		) -- 1928
	end) -- 1928
end -- 1899
function ____exports.searchDoraAPI(req) -- 1977
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1977
		local pattern = __TS__StringTrim(req.pattern or "") -- 1988
		if pattern == "" then -- 1988
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1988
		end -- 1988
		local patterns = splitSearchPatterns(pattern) -- 1990
		if #patterns == 0 then -- 1990
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1990
		end -- 1990
		local docSource = req.docSource or "api" -- 1992
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1993
		local docRoot = target.root -- 1994
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1995
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1995
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1995
		end -- 1995
		local exts = target.exts -- 1999
		local dotExts = __TS__ArrayMap( -- 2000
			exts, -- 2000
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 2000
		) -- 2000
		local globs = target.globs -- 2001
		local limit = math.max( -- 2002
			1, -- 2002
			math.floor(req.limit or 10) -- 2002
		) -- 2002
		return ____awaiter_resolve( -- 2002
			nil, -- 2002
			__TS__New( -- 2004
				__TS__Promise, -- 2004
				function(____, resolve) -- 2004
					Director.systemScheduler:schedule(once(function() -- 2005
						do -- 2005
							local function ____catch(e) -- 2005
								resolve( -- 2085
									nil, -- 2085
									{ -- 2085
										success = false, -- 2085
										message = tostring(e) -- 2085
									} -- 2085
								) -- 2085
							end -- 2085
							local ____try, ____hasReturned = pcall(function() -- 2085
								local allHits = {} -- 2007
								do -- 2007
									local p = 0 -- 2008
									while p < #patterns do -- 2008
										local ____Content_32 = Content -- 2009
										local ____Content_searchFilesAsync_33 = Content.searchFilesAsync -- 2009
										local ____array_31 = __TS__SparseArrayNew( -- 2009
											docRoot, -- 2010
											dotExts, -- 2011
											{}, -- 2012
											ensureSafeSearchGlobs(globs), -- 2013
											patterns[p + 1] -- 2014
										) -- 2014
										local ____req_useRegex_28 = req.useRegex -- 2015
										if ____req_useRegex_28 == nil then -- 2015
											____req_useRegex_28 = false -- 2015
										end -- 2015
										__TS__SparseArrayPush(____array_31, ____req_useRegex_28) -- 2015
										local ____req_caseSensitive_29 = req.caseSensitive -- 2016
										if ____req_caseSensitive_29 == nil then -- 2016
											____req_caseSensitive_29 = false -- 2016
										end -- 2016
										__TS__SparseArrayPush(____array_31, ____req_caseSensitive_29) -- 2016
										local ____req_includeContent_30 = req.includeContent -- 2017
										if ____req_includeContent_30 == nil then -- 2017
											____req_includeContent_30 = true -- 2017
										end -- 2017
										__TS__SparseArrayPush(____array_31, ____req_includeContent_30, req.contentWindow or 80) -- 2017
										local raw = ____Content_searchFilesAsync_33( -- 2009
											____Content_32, -- 2009
											__TS__SparseArraySpread(____array_31) -- 2009
										) -- 2009
										local hits = {} -- 2020
										do -- 2020
											local i = 0 -- 2021
											while i < #raw do -- 2021
												do -- 2021
													local row = raw[i + 1] -- 2022
													local file = toDocRelativePath(resultBaseRoot, row.file, docSource) -- 2023
													if file == "" then -- 2023
														goto __continue406 -- 2024
													end -- 2024
													hits[#hits + 1] = { -- 2025
														file = file, -- 2026
														line = type(row.line) == "number" and row.line or nil, -- 2027
														content = type(row.content) == "string" and row.content or nil -- 2028
													} -- 2028
												end -- 2028
												::__continue406:: -- 2028
												i = i + 1 -- 2021
											end -- 2021
										end -- 2021
										allHits[#allHits + 1] = __TS__ArraySlice( -- 2031
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 2031
											0, -- 2031
											limit -- 2031
										) -- 2031
										p = p + 1 -- 2008
									end -- 2008
								end -- 2008
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 2033
								local fallbackPatterns -- 2034
								if #hits == 0 and #patterns == 1 and req.useRegex ~= true and (string.find(pattern, "|", nil, true) or 0) - 1 < 0 then -- 2034
									local terms = splitWhitespaceSearchPatterns(pattern) -- 2039
									if #terms > 1 then -- 2039
										fallbackPatterns = terms -- 2041
										local fallbackHits = {} -- 2042
										do -- 2042
											local p = 0 -- 2043
											while p < #terms do -- 2043
												local ____Content_37 = Content -- 2044
												local ____Content_searchFilesAsync_38 = Content.searchFilesAsync -- 2044
												local ____array_36 = __TS__SparseArrayNew( -- 2044
													docRoot, -- 2045
													dotExts, -- 2046
													{}, -- 2047
													ensureSafeSearchGlobs(globs), -- 2048
													terms[p + 1], -- 2049
													false -- 2050
												) -- 2050
												local ____req_caseSensitive_34 = req.caseSensitive -- 2051
												if ____req_caseSensitive_34 == nil then -- 2051
													____req_caseSensitive_34 = false -- 2051
												end -- 2051
												__TS__SparseArrayPush(____array_36, ____req_caseSensitive_34) -- 2051
												local ____req_includeContent_35 = req.includeContent -- 2052
												if ____req_includeContent_35 == nil then -- 2052
													____req_includeContent_35 = true -- 2052
												end -- 2052
												__TS__SparseArrayPush(____array_36, ____req_includeContent_35, req.contentWindow or 80) -- 2052
												local raw = ____Content_searchFilesAsync_38( -- 2044
													____Content_37, -- 2044
													__TS__SparseArraySpread(____array_36) -- 2044
												) -- 2044
												local termHits = {} -- 2055
												do -- 2055
													local i = 0 -- 2056
													while i < #raw do -- 2056
														do -- 2056
															local row = raw[i + 1] -- 2057
															local file = toDocRelativePath(resultBaseRoot, row.file, docSource) -- 2058
															if file == "" then -- 2058
																goto __continue413 -- 2059
															end -- 2059
															termHits[#termHits + 1] = { -- 2060
																file = file, -- 2061
																line = type(row.line) == "number" and row.line or nil, -- 2062
																content = type(row.content) == "string" and row.content or nil -- 2063
															} -- 2063
														end -- 2063
														::__continue413:: -- 2063
														i = i + 1 -- 2056
													end -- 2056
												end -- 2056
												fallbackHits[#fallbackHits + 1] = __TS__ArraySlice( -- 2066
													sortDoraAPISearchHits(termHits, docSource, req.programmingLanguage), -- 2066
													0, -- 2066
													limit -- 2066
												) -- 2066
												p = p + 1 -- 2043
											end -- 2043
										end -- 2043
										hits = mergeDoraAPISearchHitsUnique(fallbackHits) -- 2068
									end -- 2068
								end -- 2068
								resolve(nil, { -- 2071
									success = true, -- 2072
									docSource = docSource, -- 2073
									docLanguage = req.docLanguage, -- 2074
									programmingLanguage = req.programmingLanguage, -- 2075
									exts = exts, -- 2076
									results = hits, -- 2077
									hint = "Use read_file directly with the namespaced file value from a search result to view the complete authoritative document.", -- 2078
									totalResults = #hits, -- 2079
									truncated = false, -- 2080
									limit = limit, -- 2081
									fallbackPatterns = fallbackPatterns -- 2082
								}) -- 2082
							end) -- 2082
							if not ____try then -- 2082
								____catch(____hasReturned) -- 2082
							end -- 2082
						end -- 2082
					end)) -- 2005
				end -- 2004
			) -- 2004
		) -- 2004
	end) -- 2004
end -- 1977
function ____exports.searchDoraAPIHttp(req, callback) -- 2091
	local ____self_39 = ____exports.searchDoraAPI(req) -- 2091
	____self_39["then"]( -- 2091
		____self_39, -- 2091
		function(____, result) return callback(result) end -- 2102
	) -- 2102
end -- 2091
function ____exports.readDoraDoc(req) -- 2105
	local requestedFile = table.concat( -- 2111
		__TS__StringSplit(req.file or "", "\\"), -- 2111
		"/" -- 2111
	) -- 2111
	local file = requestedFile -- 2112
	local namespacedSource = nil -- 2113
	if __TS__StringStartsWith(requestedFile, AGENT_DORA_DOC_PREFIX) then -- 2113
		local namespaced = __TS__StringSlice(requestedFile, #AGENT_DORA_DOC_PREFIX) -- 2115
		if __TS__StringStartsWith(namespaced, "api/") then -- 2115
			namespacedSource = "api" -- 2117
			file = string.sub(namespaced, 5) -- 2118
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 2118
			namespacedSource = "tutorial" -- 2120
			file = string.sub(namespaced, 10) -- 2121
		else -- 2121
			return {success = false, message = "invalid Dora doc namespace"} -- 2123
		end -- 2123
	end -- 2123
	if not isValidWorkspacePath(file) or file == "." then -- 2123
		return {success = false, message = "invalid file"} -- 2127
	end -- 2127
	local lowerFile = string.lower(file) -- 2129
	local isTutorialDoc = __TS__StringEndsWith(lowerFile, ".md") -- 2130
	local isAPIDoc = __TS__StringEndsWith(lowerFile, ".ts") or __TS__StringEndsWith(lowerFile, ".tl") -- 2131
	if not isTutorialDoc and not isAPIDoc then -- 2131
		return {success = false, message = "unsupported doc file type"} -- 2132
	end -- 2132
	local docSource = namespacedSource or (isTutorialDoc and "tutorial" or "api") -- 2133
	local root = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 2134
	local fullPath = Path(root, file) -- 2135
	local relative = Path:getRelative(fullPath, root) -- 2136
	if relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 2136
		return {success = false, message = "invalid file"} -- 2138
	end -- 2138
	local readResult = ____exports.readFile(root, file, req.startLine or 1, req.endLine or -1) -- 2140
	if not readResult.success then -- 2140
		return readResult -- 2141
	end -- 2141
	return { -- 2142
		success = true, -- 2143
		docLanguage = req.docLanguage, -- 2144
		file = file, -- 2145
		content = readResult.content, -- 2146
		startLine = readResult.startLine, -- 2147
		endLine = readResult.endLine -- 2148
	} -- 2148
end -- 2105
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 2152
	if options == nil then -- 2152
		options = {} -- 2152
	end -- 2152
	local storage = requireAgentStorage() -- 2153
	if not storage.success then -- 2153
		return storage -- 2154
	end -- 2154
	if #changes == 0 then -- 2154
		return {success = false, message = "empty changes"} -- 2156
	end -- 2156
	if not isValidWorkDir(workDir) then -- 2156
		return {success = false, message = "invalid workDir"} -- 2159
	end -- 2159
	if not getTaskStatus(taskId) then -- 2159
		return {success = false, message = "task not found"} -- 2162
	end -- 2162
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 2164
	local dup = rejectDuplicatePaths(expandedChanges) -- 2165
	if dup then -- 2165
		return {success = false, message = "duplicate path in batch: " .. dup} -- 2167
	end -- 2167
	for ____, change in ipairs(expandedChanges) do -- 2170
		if not isValidWorkspacePath(change.path) then -- 2170
			return {success = false, message = "invalid path: " .. change.path} -- 2172
		end -- 2172
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 2172
			return {success = false, message = "missing content for " .. change.path} -- 2175
		end -- 2175
	end -- 2175
	local headSeq = getTaskHeadSeq(taskId) -- 2179
	if headSeq == nil then -- 2179
		return {success = false, message = "task not found"} -- 2180
	end -- 2180
	local nextSeq = headSeq + 1 -- 2181
	local preparedEntries = {} -- 2183
	do -- 2183
		local i = 0 -- 2184
		while i < #expandedChanges do -- 2184
			local change = expandedChanges[i + 1] -- 2185
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 2186
			if not fullPath then -- 2186
				return {success = false, message = "invalid path: " .. change.path} -- 2188
			end -- 2188
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 2188
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 2191
			end -- 2191
			local before = getFileState(fullPath) -- 2193
			local afterExists = change.op ~= "delete" -- 2194
			local afterContent = afterExists and (change.content or "") or "" -- 2195
			preparedEntries[#preparedEntries + 1] = { -- 2196
				id = 0, -- 2197
				ord = i + 1, -- 2198
				path = change.path, -- 2199
				op = change.op, -- 2200
				beforeExists = before.exists, -- 2201
				beforeContent = before.content, -- 2202
				afterExists = afterExists, -- 2203
				afterContent = afterContent -- 2204
			} -- 2204
			i = i + 1 -- 2184
		end -- 2184
	end -- 2184
	local checkpointId = insertCheckpoint( -- 2208
		taskId, -- 2208
		nextSeq, -- 2208
		options.summary or "", -- 2208
		options.toolName or "", -- 2208
		"PREPARED" -- 2208
	) -- 2208
	if checkpointId <= 0 then -- 2208
		return {success = false, message = "failed to create checkpoint"} -- 2210
	end -- 2210
	local entryRows = {} -- 2212
	do -- 2212
		local i = 0 -- 2213
		while i < #preparedEntries do -- 2213
			local entry = preparedEntries[i + 1] -- 2214
			entryRows[#entryRows + 1] = { -- 2215
				checkpointId, -- 2216
				entry.ord, -- 2217
				entry.path, -- 2218
				entry.op, -- 2219
				entry.beforeExists and 1 or 0, -- 2220
				entry.beforeContent, -- 2221
				entry.afterExists and 1 or 0, -- 2222
				entry.afterContent, -- 2223
				#entry.beforeContent, -- 2224
				#entry.afterContent -- 2225
			} -- 2225
			i = i + 1 -- 2213
		end -- 2213
	end -- 2213
	local entryInsert = {("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_data, after_exists, after_data, bytes_before, bytes_after)\n\t\tVALUES(?, ?, ?, ?, ?, dora_compress_text(?), ?, dora_compress_text(?), ?, ?)", entryRows} -- 2228
	if not DB:transaction({entryInsert}) then -- 2228
		DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2234
		return {success = false, message = "failed to insert checkpoint entries"} -- 2235
	end -- 2235
	local appliedCount = 0 -- 2238
	for ____, entry in ipairs(preparedEntries) do -- 2239
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2240
		if not fullPath then -- 2240
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2242
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2243
			return {success = false, message = ("invalid path: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2244
		end -- 2244
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 2246
		if not ok then -- 2246
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2248
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount + 1) -- 2249
			return {success = false, message = ("failed to apply file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2250
		end -- 2250
		appliedCount = appliedCount + 1 -- 2252
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 2252
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2254
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2255
			return {success = false, message = ("failed to sync file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; all applied files restored")} -- 2256
		end -- 2256
	end -- 2256
	DB:exec( -- 2260
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 2260
		{ -- 2262
			"APPLIED", -- 2262
			now(), -- 2262
			checkpointId -- 2262
		} -- 2262
	) -- 2262
	DB:exec( -- 2264
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 2264
		{ -- 2266
			nextSeq, -- 2266
			now(), -- 2266
			taskId -- 2266
		} -- 2266
	) -- 2266
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 2268
end -- 2152
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 2276
	if not isValidWorkDir(workDir) then -- 2276
		return {success = false, message = "invalid workDir"} -- 2277
	end -- 2277
	if checkpointId <= 0 then -- 2277
		return {success = false, message = "invalid checkpointId"} -- 2278
	end -- 2278
	local entries = getCheckpointEntries(checkpointId, true) -- 2279
	if #entries == 0 then -- 2279
		return {success = false, message = "checkpoint not found or empty"} -- 2281
	end -- 2281
	for ____, entry in ipairs(entries) do -- 2283
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2284
		if not fullPath then -- 2284
			return {success = false, message = "invalid path: " .. entry.path} -- 2286
		end -- 2286
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 2288
		if not ok then -- 2288
			Log( -- 2290
				"Error", -- 2290
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2290
			) -- 2290
			Log( -- 2291
				"Info", -- 2291
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2291
			) -- 2291
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 2292
		end -- 2292
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 2292
			Log( -- 2295
				"Error", -- 2295
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2295
			) -- 2295
			Log( -- 2296
				"Info", -- 2296
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2296
			) -- 2296
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 2297
		end -- 2297
	end -- 2297
	DB:exec( -- 2300
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 2300
		{ -- 2300
			"REVERTED", -- 2300
			now(), -- 2300
			checkpointId -- 2300
		} -- 2300
	) -- 2300
	return {success = true, checkpointId = checkpointId} -- 2301
end -- 2276
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 2304
	if not isValidWorkDir(workDir) then -- 2304
		return {success = false, message = "invalid workDir"} -- 2305
	end -- 2305
	if not getTaskStatus(taskId) then -- 2305
		return {success = false, message = "task not found"} -- 2306
	end -- 2306
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 2307
	if #checkpoints == 0 then -- 2307
		return {success = false, message = "change set not found or empty"} -- 2309
	end -- 2309
	local lastCheckpointId = 0 -- 2311
	do -- 2311
		local i = 0 -- 2312
		while i < #checkpoints do -- 2312
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 2313
			if not result.success then -- 2313
				return {success = false, message = result.message} -- 2314
			end -- 2314
			lastCheckpointId = checkpoints[i + 1].id -- 2315
			i = i + 1 -- 2312
		end -- 2312
	end -- 2312
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 2317
end -- 2304
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 2325
	return getCheckpointEntries(checkpointId, false) -- 2326
end -- 2325
function ____exports.getCheckpointDiff(checkpointId) -- 2329
	if checkpointId <= 0 then -- 2329
		return {success = false, message = "invalid checkpointId"} -- 2331
	end -- 2331
	local entries = getCheckpointEntries(checkpointId, false) -- 2333
	if #entries == 0 then -- 2333
		return {success = false, message = "checkpoint not found or empty"} -- 2335
	end -- 2335
	return { -- 2337
		success = true, -- 2338
		files = __TS__ArrayMap( -- 2339
			entries, -- 2339
			function(____, entry) return { -- 2339
				path = entry.path, -- 2340
				op = entry.op, -- 2341
				beforeExists = entry.beforeExists, -- 2342
				afterExists = entry.afterExists, -- 2343
				beforeContent = entry.beforeContent, -- 2344
				afterContent = entry.afterContent -- 2345
			} end -- 2345
		) -- 2345
	} -- 2345
end -- 2329
local function finalizeBuildResult(workDir, messages) -- 2350
	local normalized = __TS__ArrayMap( -- 2351
		messages, -- 2351
		function(____, m) return m.success and __TS__ObjectAssign( -- 2351
			{}, -- 2352
			m, -- 2352
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2352
		) or __TS__ObjectAssign( -- 2352
			{}, -- 2353
			m, -- 2353
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2353
		) end -- 2353
	) -- 2353
	local total = #normalized -- 2354
	local failed = 0 -- 2355
	do -- 2355
		local i = 0 -- 2356
		while i < #normalized do -- 2356
			if not normalized[i + 1].success then -- 2356
				failed = failed + 1 -- 2357
			end -- 2357
			i = i + 1 -- 2356
		end -- 2356
	end -- 2356
	local passed = total - failed -- 2359
	if failed > 0 then -- 2359
		return { -- 2361
			success = false, -- 2362
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 2363
			total = total, -- 2364
			passed = passed, -- 2365
			failed = failed, -- 2366
			messages = normalized -- 2367
		} -- 2367
	end -- 2367
	return { -- 2370
		success = true, -- 2371
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 2372
		total = total, -- 2373
		passed = passed, -- 2374
		failed = 0, -- 2375
		messages = normalized -- 2376
	} -- 2376
end -- 2350
function ____exports.build(req) -- 2380
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2380
		local targetRel = req.path or "" -- 2381
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2382
		if not target then -- 2382
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2382
		end -- 2382
		if not Content:exist(target) then -- 2382
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2382
		end -- 2382
		local messages = {} -- 2389
		if not Content:isdir(target) then -- 2389
			local kind = getSupportedBuildKind(target) -- 2391
			if not kind then -- 2391
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2391
			end -- 2391
			if kind == "ts" then -- 2391
				local content = Content:load(target) -- 2396
				if content == nil then -- 2396
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2396
				end -- 2396
				if isTiledEditorContent(content) then -- 2396
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2401
					return ____awaiter_resolve( -- 2401
						nil, -- 2401
						finalizeBuildResult(req.workDir, messages) -- 2402
					) -- 2402
				end -- 2402
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2402
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2402
				end -- 2402
				if not isDtsFile(target) then -- 2402
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir)) -- 2408
				end -- 2408
			else -- 2408
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2411
			end -- 2411
			Log( -- 2413
				"Info", -- 2413
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2413
			) -- 2413
			return ____awaiter_resolve( -- 2413
				nil, -- 2413
				finalizeBuildResult(req.workDir, messages) -- 2414
			) -- 2414
		end -- 2414
		local listResult = ____exports.listFiles({ -- 2416
			workDir = req.workDir, -- 2417
			path = targetRel, -- 2418
			globs = __TS__ArrayMap( -- 2419
				codeExtensions, -- 2419
				function(____, e) return "**/*" .. e end -- 2419
			), -- 2419
			maxEntries = 10000 -- 2420
		}) -- 2420
		local relFiles = listResult.success and listResult.files or ({}) -- 2423
		local tsFileData = {} -- 2424
		local buildQueue = {} -- 2425
		for ____, rel in ipairs(relFiles) do -- 2426
			do -- 2426
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2427
				local kind = getSupportedBuildKind(file) -- 2428
				if not kind then -- 2428
					goto __continue490 -- 2429
				end -- 2429
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2430
				if kind ~= "ts" then -- 2430
					goto __continue490 -- 2432
				end -- 2432
				local content = Content:load(file) -- 2434
				if content == nil then -- 2434
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2436
					goto __continue490 -- 2437
				end -- 2437
				if isTiledEditorContent(content) then -- 2437
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2440
					goto __continue490 -- 2441
				end -- 2441
				tsFileData[file] = content -- 2443
			end -- 2443
			::__continue490:: -- 2443
		end -- 2443
		do -- 2443
			local i = 0 -- 2445
			while i < #buildQueue do -- 2445
				do -- 2445
					local ____buildQueue_index_40 = buildQueue[i + 1] -- 2446
					local file = ____buildQueue_index_40.file -- 2446
					local kind = ____buildQueue_index_40.kind -- 2446
					if kind == "ts" then -- 2446
						local content = tsFileData[file] -- 2448
						if content == nil or isDtsFile(file) then -- 2448
							goto __continue497 -- 2450
						end -- 2450
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2450
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2453
							goto __continue497 -- 2454
						end -- 2454
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir)) -- 2456
						goto __continue497 -- 2457
					end -- 2457
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2459
				end -- 2459
				::__continue497:: -- 2459
				i = i + 1 -- 2445
			end -- 2445
		end -- 2445
		if #messages == 0 then -- 2445
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2462
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2462
		end -- 2462
		Log( -- 2465
			"Info", -- 2465
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2465
		) -- 2465
		return ____awaiter_resolve( -- 2465
			nil, -- 2465
			finalizeBuildResult(req.workDir, messages) -- 2466
		) -- 2466
	end) -- 2466
end -- 2380
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2469
local EXECUTE_COMMAND_ERROR_MAX = 4000 -- 2470
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 2471
local agentEntryRuntimeOwner = "" -- 2472
local function truncateCommandOutput(output) -- 2474
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2474
		return output -- 2475
	end -- 2475
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2476
end -- 2474
local function truncateCommandError(message) -- 2479
	if #message <= EXECUTE_COMMAND_ERROR_MAX then -- 2479
		return message -- 2480
	end -- 2480
	return __TS__StringSlice(message, 0, EXECUTE_COMMAND_ERROR_MAX) .. "\n... error message truncated ..." -- 2481
end -- 2479
local function executeLuaCommand(req) -- 2484
	local code = __TS__StringTrim(req.code or "") -- 2492
	if code == "" then -- 2492
		return __TS__Promise.resolve({ -- 2494
			success = false, -- 2494
			mode = "lua", -- 2494
			output = "", -- 2494
			message = "missing code", -- 2494
			phase = "validate" -- 2494
		}) -- 2494
	end -- 2494
	local output = {} -- 2496
	local entry = require("Script.Dev.Entry") -- 2497
	local ownsEntryRuntime = false -- 2498
	local entryObjectBaseline = 0 -- 2499
	local entryLuaRefBaseline = 0 -- 2500
	local function acquireEntryRuntime() -- 2501
		if agentEntryRuntimeOwner ~= "" and agentEntryRuntimeOwner ~= req.operationId then -- 2501
			error("Dora entry runtime is busy with another Agent command") -- 2503
		end -- 2503
		agentEntryRuntimeOwner = req.operationId -- 2505
		ownsEntryRuntime = true -- 2506
	end -- 2501
	local function stopOwnedEntry() -- 2508
		if not ownsEntryRuntime then -- 2508
			return nil -- 2509
		end -- 2509
		local cleanupError -- 2510
		do -- 2510
			local function ____catch(e) -- 2510
				cleanupError = "failed to stop Agent test entry: " .. tostring(e) -- 2514
			end -- 2514
			local ____try, ____hasReturned = pcall(function() -- 2514
				entry.stop() -- 2512
			end) -- 2512
			if not ____try then -- 2512
				____catch(____hasReturned) -- 2512
			end -- 2512
		end -- 2512
		ownsEntryRuntime = false -- 2516
		if agentEntryRuntimeOwner == req.operationId then -- 2516
			agentEntryRuntimeOwner = "" -- 2518
		end -- 2518
		return cleanupError -- 2520
	end -- 2508
	local function startEntryWatchdog() -- 2522
		entryObjectBaseline = Dora.Object.count -- 2523
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 2524
	end -- 2522
	local function checkEntryWatchdog() -- 2526
		if not ownsEntryRuntime then -- 2526
			return nil -- 2527
		end -- 2527
		local objectCount = Dora.Object.count -- 2528
		local luaRefCount = Dora.Object.luaRefCount -- 2529
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 2530
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 2531
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 2532
		if not exceededTotal then -- 2532
			return nil -- 2535
		end -- 2535
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 2536
	end -- 2526
	local function normalizeEntryFile(value) -- 2540
		if not value or type(value) ~= "table" then -- 2540
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 2542
		end -- 2542
		local descriptor = value -- 2544
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 2545
		if relativeFile == "" then -- 2545
			relativeFile = "init" -- 2546
		end -- 2546
		if not isValidWorkspacePath(relativeFile) then -- 2546
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 2548
		end -- 2548
		local fileName = Path(req.workDir, relativeFile) -- 2550
		local ext = Path:getExt(fileName) -- 2551
		if ext ~= "" then -- 2551
			fileName = Path:replaceExt(fileName, "") -- 2552
		end -- 2552
		local luaFile = Path:replaceExt(fileName, "lua") -- 2553
		if not Content:exist(luaFile) then -- 2553
			error("Agent test entry was not built: " .. luaFile) -- 2555
		end -- 2555
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 2557
		return { -- 2558
			fileName = fileName, -- 2559
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 2560
		} -- 2560
	end -- 2540
	local function capturePrint(...) -- 2563
		local values = {...} -- 2563
		local parts = {} -- 2564
		do -- 2564
			local i = 0 -- 2565
			while i < #values do -- 2565
				parts[#parts + 1] = tostring(values[i + 1]) -- 2566
				i = i + 1 -- 2565
			end -- 2565
		end -- 2565
		output[#output + 1] = table.concat(parts, "\t") -- 2568
	end -- 2563
	local env = setmetatable( -- 2570
		{ -- 2570
			projectDir = req.workDir, -- 2571
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 2572
				if type(moduleNameValue) ~= "string" then -- 2572
					error("requireProjectModule expects a project module name string") -- 2574
				end -- 2574
				local moduleName = __TS__StringTrim(moduleNameValue) -- 2576
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 2576
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 2578
				end -- 2578
				local reloadModules = {moduleName} -- 2580
				if reloadModulesValue ~= nil then -- 2580
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 2580
						error("requireProjectModule reloadModules must be an array of module names") -- 2583
					end -- 2583
					local items = reloadModulesValue -- 2585
					do -- 2585
						local i = 0 -- 2586
						while i < #items do -- 2586
							local item = items[i + 1] -- 2587
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 2587
								error("requireProjectModule reloadModules contains an invalid module name") -- 2589
							end -- 2589
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 2589
								reloadModules[#reloadModules + 1] = item -- 2591
							end -- 2591
							i = i + 1 -- 2586
						end -- 2586
					end -- 2586
				end -- 2586
				local luaPackage = _G.package -- 2594
				local previousPath = luaPackage.path -- 2598
				local previousSearchPaths = Content.searchPaths -- 2599
				local scopedSearchPaths = {req.workDir} -- 2600
				do -- 2600
					local i = 0 -- 2601
					while i < #previousSearchPaths do -- 2601
						local searchPath = previousSearchPaths[i + 1] -- 2602
						if searchPath ~= req.workDir then -- 2602
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 2603
						end -- 2603
						i = i + 1 -- 2601
					end -- 2601
				end -- 2601
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 2605
				Content.searchPaths = scopedSearchPaths -- 2606
				do -- 2606
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2606
						do -- 2606
							local i = 0 -- 2608
							while i < #reloadModules do -- 2608
								local reloadName = reloadModules[i + 1] -- 2609
								luaPackage.loaded[reloadName] = nil -- 2610
								luaPackage.loaded[table.concat( -- 2611
									__TS__StringSplit(reloadName, "/"), -- 2611
									"." -- 2611
								)] = nil -- 2611
								luaPackage.loaded[table.concat( -- 2612
									__TS__StringSplit(reloadName, "."), -- 2612
									"/" -- 2612
								)] = nil -- 2612
								i = i + 1 -- 2608
							end -- 2608
						end -- 2608
						return true, require(table.concat( -- 2614
							__TS__StringSplit(moduleName, "/"), -- 2614
							"." -- 2614
						)) -- 2614
					end) -- 2614
					do -- 2614
						Content.searchPaths = previousSearchPaths -- 2616
						luaPackage.path = previousPath -- 2617
					end -- 2617
					if not ____try then -- 2617
						error(____hasReturned, 0) -- 2617
					end -- 2617
					if ____try and ____hasReturned then -- 2617
						return ____returnValue -- 2607
					end -- 2607
				end -- 2607
			end, -- 2572
			print = capturePrint, -- 2620
			refreshTree = function(path) -- 2621
				if path == nil then -- 2621
					return refreshProjectTree(req.workDir) -- 2623
				end -- 2623
				if type(path) ~= "string" then -- 2623
					error("refreshTree expects a project-relative file path string or no argument") -- 2626
				end -- 2626
				return refreshProjectTree(req.workDir, path) -- 2628
			end, -- 2621
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 2630
			enterEntryAsync = function(value) -- 2631
				local normalized = normalizeEntryFile(value) -- 2632
				acquireEntryRuntime() -- 2633
				entry.allClear() -- 2634
				startEntryWatchdog() -- 2635
				local success, message = entry.enterEntryAsync({ -- 2636
					entryName = normalized.entryName, -- 2637
					fileName = normalized.fileName, -- 2638
					workDir = req.workDir, -- 2639
					projectRoot = req.workDir, -- 2640
					runKind = "agent_test" -- 2641
				}) -- 2641
				return success, message -- 2643
			end, -- 2631
			stopEntry = function() -- 2645
				if not ownsEntryRuntime then -- 2645
					return false -- 2646
				end -- 2646
				return entry.stop() -- 2647
			end -- 2645
		}, -- 2645
		{__index = Dora} -- 2649
	) -- 2649
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 2652
	if not fn then -- 2652
		return __TS__Promise.resolve({ -- 2654
			success = false, -- 2655
			mode = "lua", -- 2656
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2657
			message = truncateCommandError(toStr(compileErr)), -- 2658
			phase = "compile" -- 2659
		}) -- 2659
	end -- 2659
	return __TS__New( -- 2662
		__TS__Promise, -- 2662
		function(____, resolve) -- 2662
			local settled = false -- 2663
			local startedAt = App.runningTime -- 2664
			local onProgress = req.onProgress -- 2665
			local isCancelled = req.isCancelled -- 2666
			local function finish(result) -- 2667
				if settled then -- 2667
					return -- 2668
				end -- 2668
				settled = true -- 2669
				local cleanupError = stopOwnedEntry() -- 2670
				if not result.success and cleanupError ~= nil then -- 2670
					result.cleanupError = cleanupError -- 2672
				elseif result.success and cleanupError ~= nil then -- 2672
					resolve(nil, { -- 2674
						success = false, -- 2675
						mode = "lua", -- 2676
						output = result.output, -- 2677
						message = cleanupError, -- 2678
						phase = "execute", -- 2679
						cleanupError = cleanupError -- 2680
					}) -- 2680
					return -- 2682
				end -- 2682
				resolve(nil, result) -- 2684
			end -- 2667
			if onProgress then -- 2667
				onProgress(nil, { -- 2687
					state = "pending", -- 2688
					mode = "lua", -- 2689
					operationId = req.operationId, -- 2690
					stage = "lua", -- 2691
					message = "Lua command pending" -- 2692
				}) -- 2692
			end -- 2692
			Director.systemScheduler:schedule(function() -- 2695
				if settled then -- 2695
					return true -- 2696
				end -- 2696
				local watchdogMessage = checkEntryWatchdog() -- 2697
				if watchdogMessage ~= nil then -- 2697
					finish({ -- 2699
						success = false, -- 2700
						mode = "lua", -- 2701
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2702
						message = watchdogMessage, -- 2703
						phase = "execute", -- 2704
						interrupted = true -- 2705
					}) -- 2705
					return true -- 2707
				end -- 2707
				if isCancelled and isCancelled(nil) then -- 2707
					finish({ -- 2710
						success = false, -- 2711
						mode = "lua", -- 2712
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2713
						message = "Lua command canceled", -- 2714
						phase = "execute", -- 2715
						interrupted = true -- 2716
					}) -- 2716
					return true -- 2718
				end -- 2718
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 2718
					finish({ -- 2721
						success = false, -- 2722
						mode = "lua", -- 2723
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2724
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 2725
						phase = "timeout" -- 2726
					}) -- 2726
					return true -- 2728
				end -- 2728
				return false -- 2730
			end) -- 2695
			Director.systemScheduler:schedule(once(function() -- 2732
				if settled then -- 2732
					return -- 2733
				end -- 2733
				if onProgress then -- 2733
					onProgress(nil, { -- 2735
						state = "running", -- 2736
						mode = "lua", -- 2737
						operationId = req.operationId, -- 2738
						stage = "lua", -- 2739
						message = "Lua command running" -- 2740
					}) -- 2740
				end -- 2740
				local previousGlobalPrint = _G.print -- 2743
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 2744
				local frameTimedOut = false -- 2745
				local watchdogMessage -- 2745
				_G.print = capturePrint -- 2746
				debug.sethook( -- 2747
					function() -- 2747
						if watchdogMessage == nil then -- 2747
							watchdogMessage = checkEntryWatchdog() -- 2748
						end -- 2748
						if watchdogMessage ~= nil then -- 2748
							error(watchdogMessage) -- 2749
						end -- 2749
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 2749
							frameTimedOut = true -- 2751
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 2752
						end -- 2752
					end, -- 2747
					"", -- 2754
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 2754
				) -- 2754
				local ok, runtimeErr = pcall(fn) -- 2755
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 2755
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 2757
				else -- 2757
					debug.sethook() -- 2763
				end -- 2763
				_G.print = previousGlobalPrint -- 2765
				if not ok then -- 2765
					local ____truncateCommandOutput_result_42 = truncateCommandOutput(table.concat(output, "\n")) -- 2770
					local ____temp_43 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 2771
					local ____temp_44 = frameTimedOut and "timeout" or "execute" -- 2772
					local ____temp_41 -- 2773
					if watchdogMessage ~= nil or frameTimedOut then -- 2773
						____temp_41 = true -- 2773
					else -- 2773
						____temp_41 = nil -- 2773
					end -- 2773
					finish({ -- 2767
						success = false, -- 2768
						mode = "lua", -- 2769
						output = ____truncateCommandOutput_result_42, -- 2770
						message = ____temp_43, -- 2771
						phase = ____temp_44, -- 2772
						interrupted = ____temp_41 -- 2773
					}) -- 2773
					return -- 2775
				end -- 2775
				finish({ -- 2777
					success = true, -- 2777
					mode = "lua", -- 2777
					output = truncateCommandOutput(table.concat(output, "\n")) -- 2777
				}) -- 2777
			end)) -- 2732
		end -- 2662
	) -- 2662
end -- 2484
local function formatGitStatusOutput(status) -- 2782
	if not status then -- 2782
		return "" -- 2783
	end -- 2783
	local lines = {} -- 2784
	local state = toStr(status.state) -- 2785
	local kind = toStr(status.kind) -- 2786
	local message = toStr(status.message) -- 2787
	local errorMessage = toStr(status.error) -- 2788
	if kind ~= "" or state ~= "" then -- 2788
		lines[#lines + 1] = table.concat( -- 2790
			__TS__ArrayFilter( -- 2790
				{kind, state}, -- 2790
				function(____, item) return item ~= "" end -- 2790
			), -- 2790
			": " -- 2790
		) -- 2790
	end -- 2790
	if message ~= "" then -- 2790
		lines[#lines + 1] = message -- 2792
	end -- 2792
	if errorMessage ~= "" then -- 2792
		lines[#lines + 1] = errorMessage -- 2793
	end -- 2793
	local data = status.data -- 2794
	if data ~= nil then -- 2794
		local dataText = encodeJSON(data) -- 2796
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 2797
	end -- 2797
	return truncateCommandOutput(table.concat(lines, "\n")) -- 2799
end -- 2782
local function emitGitProgress(mode, operationId, onProgress, status) -- 2802
	if not onProgress then -- 2802
		return -- 2808
	end -- 2808
	local progress = type(status.progress) == "number" and status.progress or nil -- 2809
	local kind = toStr(status.kind) -- 2810
	local message = toStr(status.message) -- 2811
	local state = toStr(status.state) -- 2812
	local jobId = type(status.id) == "number" and status.id or nil -- 2813
	onProgress({ -- 2814
		state = "running", -- 2815
		mode = mode, -- 2816
		operationId = operationId, -- 2817
		stage = kind ~= "" and kind or "git", -- 2818
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 2819
		progress = progress, -- 2820
		jobId = jobId, -- 2821
		gitState = state ~= "" and state or nil, -- 2822
		gitKind = kind ~= "" and kind or nil -- 2823
	}) -- 2823
end -- 2802
local function cloneGitToTarget(req) -- 2827
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2827
		local parsed = parseGitCloneCommand(req.command) -- 2835
		if parsed == nil then -- 2835
			return ____awaiter_resolve(nil, nil) -- 2835
		end -- 2835
		if not parsed.success then -- 2835
			return ____awaiter_resolve(nil, { -- 2835
				success = false, -- 2838
				mode = "git", -- 2838
				output = "", -- 2838
				message = parsed.message, -- 2838
				phase = "validate" -- 2838
			}) -- 2838
		end -- 2838
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 2840
		if not target then -- 2840
			return ____awaiter_resolve(nil, { -- 2840
				success = false, -- 2842
				mode = "git", -- 2842
				output = "", -- 2842
				message = "invalid clone target path", -- 2842
				phase = "validate" -- 2842
			}) -- 2842
		end -- 2842
		if Content:exist(target) then -- 2842
			return ____awaiter_resolve(nil, { -- 2842
				success = false, -- 2845
				mode = "git", -- 2845
				output = "", -- 2845
				message = "target already exists", -- 2845
				phase = "validate" -- 2845
			}) -- 2845
		end -- 2845
		local targetParent = Path:getPath(target) -- 2847
		if not ensureDirPath(targetParent) then -- 2847
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 2847
		end -- 2847
		local tempRoot = getAgentDownloadTempRoot() -- 2851
		if not ensureDirPath(tempRoot) then -- 2851
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 2851
		end -- 2851
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 2855
		Content:remove(tempPath) -- 2856
		local depth = parsed.depth or "1" -- 2857
		local ____array_45 = __TS__SparseArrayNew( -- 2857
			"clone", -- 2859
			quoteGitArg(parsed.url), -- 2860
			quoteGitArg(Path:getFilename(tempPath)), -- 2861
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 2862
				"-b", -- 2862
				quoteGitArg(parsed.ref) -- 2862
			}) or ({})) -- 2862
		) -- 2862
		__TS__SparseArrayPush( -- 2862
			____array_45, -- 2862
			table.unpack(depth ~= "" and ({ -- 2863
				"--depth",
				quoteGitArg(depth) -- 2863
			}) or ({})) -- 2863
		) -- 2863
		local command = table.concat( -- 2858
			{__TS__SparseArraySpread(____array_45)}, -- 2858
			" " -- 2864
		) -- 2864
		local ____this_47 -- 2864
		____this_47 = req -- 2865
		local ____opt_46 = ____this_47.onProgress -- 2865
		if ____opt_46 ~= nil then -- 2865
			____opt_46(____this_47, { -- 2865
				state = "pending", -- 2866
				mode = "git", -- 2867
				operationId = req.operationId, -- 2868
				stage = "clone", -- 2869
				message = "clone pending", -- 2870
				progress = 0 -- 2871
			}) -- 2871
		end -- 2871
		local gitRes = __TS__Await(runGitAndWait( -- 2873
			tempRoot, -- 2874
			command, -- 2875
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2876
			function() -- 2877
				local ____this_49 -- 2877
				____this_49 = req -- 2877
				local ____opt_48 = ____this_49.isCancelled -- 2877
				return (____opt_48 and ____opt_48(____this_49)) == true -- 2877
			end, -- 2877
			req.timeoutSeconds -- 2878
		)) -- 2878
		if not gitRes.success then -- 2878
			local cleanupError = cleanupPath(tempPath) -- 2881
			local ____formatGitStatusOutput_result_53 = formatGitStatusOutput(gitRes.status) -- 2885
			local ____temp_54 = gitRes.message or "git clone failed" -- 2886
			local ____gitRes_interrupted_52 = gitRes.interrupted -- 2887
			if not ____gitRes_interrupted_52 then -- 2887
				local ____this_51 -- 2887
				____this_51 = req -- 2887
				local ____opt_50 = ____this_51.isCancelled -- 2887
				____gitRes_interrupted_52 = (____opt_50 and ____opt_50(____this_51)) == true -- 2887
			end -- 2887
			return ____awaiter_resolve(nil, { -- 2887
				success = false, -- 2883
				mode = "git", -- 2884
				output = ____formatGitStatusOutput_result_53, -- 2885
				message = ____temp_54, -- 2886
				interrupted = ____gitRes_interrupted_52, -- 2887
				cleanupError = cleanupError -- 2888
			}) -- 2888
		end -- 2888
		if not Content:move(tempPath, target) then -- 2888
			local cleanupError = cleanupPath(tempPath) -- 2892
			return ____awaiter_resolve( -- 2892
				nil, -- 2892
				{ -- 2893
					success = false, -- 2893
					mode = "git", -- 2893
					output = formatGitStatusOutput(gitRes.status), -- 2893
					message = "failed to move cloned repository into target path", -- 2893
					cleanupError = cleanupError -- 2893
				} -- 2893
			) -- 2893
		end -- 2893
		if not refreshProjectTree(req.workDir) then -- 2893
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 2896
		end -- 2896
		local commit = getGitHeadCommit(target) -- 2898
		local output = table.concat( -- 2899
			__TS__ArrayFilter( -- 2899
				{ -- 2899
					formatGitStatusOutput(gitRes.status), -- 2900
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 2900
					commit ~= nil and "commit " .. commit or "" -- 2902
				}, -- 2902
				function(____, item) return item ~= "" end -- 2903
			), -- 2903
			"\n" -- 2903
		) -- 2903
		return ____awaiter_resolve( -- 2903
			nil, -- 2903
			{ -- 2904
				success = true, -- 2904
				mode = "git", -- 2904
				output = truncateCommandOutput(output) -- 2904
			} -- 2904
		) -- 2904
	end) -- 2904
end -- 2827
local function loadGitProfile() -- 2907
	local rows -- 2908
	do -- 2908
		local function ____catch() -- 2908
			return true, nil -- 2912
		end -- 2912
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2912
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 2910
		end) -- 2910
		if not ____try then -- 2910
			____hasReturned, ____returnValue = ____catch() -- 2910
		end -- 2910
		if ____hasReturned then -- 2910
			return ____returnValue -- 2909
		end -- 2909
	end -- 2909
	if not rows or not rows[1] then -- 2909
		return nil -- 2914
	end -- 2914
	local name = toStr(rows[1][1]) -- 2915
	local email = toStr(rows[1][2]) -- 2916
	if name == "" and email == "" then -- 2916
		return nil -- 2917
	end -- 2917
	return {name = name, email = email} -- 2918
end -- 2907
local function applyGitProfileToCommit(command) -- 2921
	local args = shellSplit(command) -- 2922
	if args[1] ~= "commit" then -- 2922
		return command -- 2923
	end -- 2923
	local hasName = false -- 2924
	local hasEmail = false -- 2925
	for ____, arg in ipairs(args) do -- 2926
		if arg == "--author-name" then
			hasName = true -- 2927
		end -- 2927
		if arg == "--author-email" then
			hasEmail = true -- 2928
		end -- 2928
	end -- 2928
	if hasName and hasEmail then -- 2928
		return command -- 2930
	end -- 2930
	local profile = loadGitProfile() -- 2931
	if not profile then -- 2931
		return command -- 2932
	end -- 2932
	local additions = {} -- 2933
	if not hasName and profile.name ~= "" then -- 2933
		__TS__ArrayPush( -- 2935
			additions, -- 2935
			"--author-name",
			quoteGitArg(profile.name) -- 2935
		) -- 2935
	end -- 2935
	if not hasEmail and profile.email ~= "" then -- 2935
		__TS__ArrayPush( -- 2938
			additions, -- 2938
			"--author-email",
			quoteGitArg(profile.email) -- 2938
		) -- 2938
	end -- 2938
	if #additions == 0 then -- 2938
		return command -- 2940
	end -- 2940
	return (command .. " ") .. table.concat(additions, " ") -- 2941
end -- 2921
local function executeGitCommand(req) -- 2944
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2944
		local command = normalizeGitCommand(req.command or "") -- 2953
		if command == "" then -- 2953
			return ____awaiter_resolve(nil, { -- 2953
				success = false, -- 2955
				mode = "git", -- 2955
				output = "", -- 2955
				message = "missing command", -- 2955
				phase = "validate" -- 2955
			}) -- 2955
		end -- 2955
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 2957
			workDir = req.workDir, -- 2958
			command = command, -- 2959
			operationId = req.operationId, -- 2960
			timeoutSeconds = req.timeoutSeconds, -- 2961
			onProgress = req.onProgress, -- 2962
			isCancelled = req.isCancelled -- 2963
		})) -- 2963
		if cloneResult ~= nil then -- 2963
			return ____awaiter_resolve(nil, cloneResult) -- 2963
		end -- 2963
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 2966
		if not cwd.success then -- 2966
			return ____awaiter_resolve(nil, { -- 2966
				success = false, -- 2968
				mode = "git", -- 2968
				output = "", -- 2968
				cwd = req.cwd, -- 2968
				message = cwd.message, -- 2968
				phase = "validate" -- 2968
			}) -- 2968
		end -- 2968
		command = applyGitProfileToCommit(command) -- 2970
		local ____this_56 -- 2970
		____this_56 = req -- 2971
		local ____opt_55 = ____this_56.onProgress -- 2971
		if ____opt_55 ~= nil then -- 2971
			____opt_55(____this_56, { -- 2971
				state = "pending", -- 2972
				mode = "git", -- 2973
				operationId = req.operationId, -- 2974
				stage = "git", -- 2975
				message = "git command pending", -- 2976
				progress = 0 -- 2977
			}) -- 2977
		end -- 2977
		local gitRes = __TS__Await(runGitAndWait( -- 2979
			cwd.path, -- 2980
			command, -- 2981
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2982
			function() -- 2983
				local ____this_58 -- 2983
				____this_58 = req -- 2983
				local ____opt_57 = ____this_58.isCancelled -- 2983
				return (____opt_57 and ____opt_57(____this_58)) == true -- 2983
			end, -- 2983
			req.timeoutSeconds -- 2984
		)) -- 2984
		local output = formatGitStatusOutput(gitRes.status) -- 2986
		if not gitRes.success then -- 2986
			local ____output_62 = output -- 2991
			local ____cwd_relative_63 = cwd.relative -- 2992
			local ____temp_64 = gitRes.message or "git command failed" -- 2993
			local ____gitRes_interrupted_61 = gitRes.interrupted -- 2994
			if not ____gitRes_interrupted_61 then -- 2994
				local ____this_60 -- 2994
				____this_60 = req -- 2994
				local ____opt_59 = ____this_60.isCancelled -- 2994
				____gitRes_interrupted_61 = (____opt_59 and ____opt_59(____this_60)) == true -- 2994
			end -- 2994
			return ____awaiter_resolve(nil, { -- 2994
				success = false, -- 2989
				mode = "git", -- 2990
				output = ____output_62, -- 2991
				cwd = ____cwd_relative_63, -- 2992
				message = ____temp_64, -- 2993
				interrupted = ____gitRes_interrupted_61 -- 2994
			}) -- 2994
		end -- 2994
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 2994
	end) -- 2994
end -- 2944
function ____exports.executeCommand(req) -- 3000
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3000
		local mode = req.mode -- 3010
		if mode ~= "lua" and mode ~= "git" then -- 3010
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 3010
		end -- 3010
		if mode == "lua" then -- 3010
			return ____awaiter_resolve( -- 3010
				nil, -- 3010
				executeLuaCommand({ -- 3015
					workDir = req.workDir, -- 3016
					code = req.code or "", -- 3017
					timeoutSeconds = math.max( -- 3018
						1, -- 3018
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 3018
					), -- 3018
					operationId = createOperationId(), -- 3019
					onProgress = req.onProgress, -- 3020
					isCancelled = req.isCancelled -- 3021
				}) -- 3021
			) -- 3021
		end -- 3021
		local operationId = createOperationId() -- 3024
		return ____awaiter_resolve( -- 3024
			nil, -- 3024
			executeGitCommand({ -- 3025
				workDir = req.workDir, -- 3026
				command = req.command or "", -- 3027
				cwd = req.cwd, -- 3028
				timeoutSeconds = math.max( -- 3029
					1, -- 3029
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 3029
				), -- 3029
				operationId = operationId, -- 3030
				onProgress = req.onProgress, -- 3031
				isCancelled = req.isCancelled -- 3032
			}) -- 3032
		) -- 3032
	end) -- 3032
end -- 3000
function ____exports.fetchUrl(req) -- 3036
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3036
		local mode = "download" -- 3043
		local url = __TS__StringTrim(req.url or "") -- 3044
		local targetRel = __TS__StringTrim(req.target or "") -- 3045
		if not isHttpUrl(url) then -- 3045
			return ____awaiter_resolve(nil, { -- 3045
				success = false, -- 3047
				state = "failed", -- 3047
				mode = mode, -- 3047
				target = targetRel, -- 3047
				message = "fetch_url only supports http:// and https:// URLs" -- 3047
			}) -- 3047
		end -- 3047
		if targetRel == "" then -- 3047
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 3047
		end -- 3047
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 3052
		if not target then -- 3052
			return ____awaiter_resolve(nil, { -- 3052
				success = false, -- 3054
				state = "failed", -- 3054
				mode = mode, -- 3054
				target = targetRel, -- 3054
				message = "invalid target path" -- 3054
			}) -- 3054
		end -- 3054
		if Content:exist(target) then -- 3054
			return ____awaiter_resolve(nil, { -- 3054
				success = false, -- 3057
				state = "failed", -- 3057
				mode = mode, -- 3057
				target = targetRel, -- 3057
				message = "target already exists" -- 3057
			}) -- 3057
		end -- 3057
		local operationId = createOperationId() -- 3059
		local tempRoot = getAgentDownloadTempRoot() -- 3060
		if not ensureDirPath(tempRoot) then -- 3060
			return ____awaiter_resolve(nil, { -- 3060
				success = false, -- 3062
				state = "failed", -- 3062
				mode = mode, -- 3062
				target = targetRel, -- 3062
				message = "failed to create agent download temp directory" -- 3062
			}) -- 3062
		end -- 3062
		local tempPath = Path(tempRoot, operationId .. ".download") -- 3064
		Content:remove(tempPath) -- 3065
		local function emitProgress(progress) -- 3066
			if not req.onProgress then -- 3066
				return -- 3067
			end -- 3067
			req:onProgress(__TS__ObjectAssign({ -- 3068
				state = "running", -- 3069
				mode = mode, -- 3070
				operationId = operationId, -- 3071
				target = targetRel, -- 3072
				tempPath = tempPath -- 3073
			}, progress)) -- 3073
		end -- 3066
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 3077
		local function interrupted() -- 3082
			local ____this_66 -- 3082
			____this_66 = req -- 3082
			local ____opt_65 = ____this_66.isCancelled -- 3082
			return (____opt_65 and ____opt_65(____this_66)) == true -- 3082
		end -- 3082
		if not ensureDirForFile(tempPath) then -- 3082
			return ____awaiter_resolve(nil, { -- 3082
				success = false, -- 3084
				state = "failed", -- 3084
				mode = mode, -- 3084
				target = targetRel, -- 3084
				message = "failed to create temporary file directory" -- 3084
			}) -- 3084
		end -- 3084
		local downloadRes = __TS__Await(downloadFile({ -- 3086
			url = url, -- 3087
			tempPath = tempPath, -- 3088
			timeout = 600, -- 3089
			isCancelled = interrupted, -- 3090
			onProgress = function(____, current, total) -- 3091
				local totalNumber = type(total) == "number" and total or 0 -- 3092
				emitProgress({ -- 3093
					stage = "download", -- 3094
					message = "downloading", -- 3095
					current = current, -- 3096
					total = total, -- 3097
					progress = totalNumber > 0 and current / totalNumber or nil -- 3098
				}) -- 3098
			end -- 3091
		})) -- 3091
		if not downloadRes.success then -- 3091
			local cleanupError = cleanupPath(tempPath) -- 3103
			return ____awaiter_resolve( -- 3103
				nil, -- 3103
				{ -- 3104
					success = false, -- 3105
					state = "failed", -- 3106
					mode = mode, -- 3107
					target = targetRel, -- 3108
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 3109
					interrupted = downloadRes.interrupted or interrupted(), -- 3110
					cleanupError = cleanupError -- 3111
				} -- 3111
			) -- 3111
		end -- 3111
		if not ensureDirForFile(target) then -- 3111
			local cleanupError = cleanupPath(tempPath) -- 3115
			return ____awaiter_resolve(nil, { -- 3115
				success = false, -- 3116
				state = "failed", -- 3116
				mode = mode, -- 3116
				target = targetRel, -- 3116
				message = "failed to create target directory", -- 3116
				cleanupError = cleanupError -- 3116
			}) -- 3116
		end -- 3116
		if not Content:move(tempPath, target) then -- 3116
			local cleanupError = cleanupPath(tempPath) -- 3119
			return ____awaiter_resolve(nil, { -- 3119
				success = false, -- 3120
				state = "failed", -- 3120
				mode = mode, -- 3120
				target = targetRel, -- 3120
				message = "failed to move downloaded file into target path", -- 3120
				cleanupError = cleanupError -- 3120
			}) -- 3120
		end -- 3120
		local bytesWritten = downloadRes.bytesWritten -- 3122
		local ____try = __TS__AsyncAwaiter(function() -- 3122
			local size = Content:getAttr(target) -- 3124
			if bytesWritten == nil or bytesWritten <= 0 then -- 3124
				bytesWritten = type(size) == "number" and size or nil -- 3126
			end -- 3126
		end) -- 3126
		____try = ____try.catch( -- 3126
			____try, -- 3126
			function(____, _) -- 3126
				return __TS__AsyncAwaiter(function() -- 3126
				end) -- 3126
			end -- 3126
		) -- 3126
		__TS__Await(____try) -- 3123
		if bytesWritten == nil or bytesWritten <= 0 then -- 3123
			local ____try = __TS__AsyncAwaiter(function() -- 3123
				local loaded = Content:load(target) -- 3133
				if type(loaded) == "string" then -- 3133
					bytesWritten = #loaded -- 3135
				end -- 3135
			end) -- 3135
			____try = ____try.catch( -- 3135
				____try, -- 3135
				function(____, _) -- 3135
					return __TS__AsyncAwaiter(function() -- 3135
					end) -- 3135
				end -- 3135
			) -- 3135
			__TS__Await(____try) -- 3132
		end -- 3132
		if not syncDownloadedFileToWebIDE(target) then -- 3132
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 3142
		end -- 3142
		return ____awaiter_resolve(nil, { -- 3142
			success = true, -- 3144
			state = "done", -- 3144
			mode = mode, -- 3144
			target = targetRel, -- 3144
			bytesWritten = bytesWritten -- 3144
		}) -- 3144
	end) -- 3144
end -- 3036
return ____exports -- 3036