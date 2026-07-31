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
function normalizeEscapedGitQuotes(command) -- 715
	local result = "" -- 716
	do -- 716
		local i = 0 -- 717
		while i < #command do -- 717
			do -- 717
				local ch = __TS__StringCharAt(command, i) -- 718
				local next = __TS__StringCharAt(command, i + 1) -- 719
				if ch == "\\" and (next == "\"" or next == "'") then -- 719
					result = result .. next -- 721
					i = i + 1 -- 722
					goto __continue112 -- 723
				end -- 723
				result = result .. ch -- 725
			end -- 725
			::__continue112:: -- 725
			i = i + 1 -- 717
		end -- 717
	end -- 717
	return result -- 727
end -- 727
function encodeJSON(obj) -- 1228
	local text = safeJsonEncode(obj) -- 1229
	return text -- 1230
end -- 1230
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 1233
	if HttpServer.wsConnectionCount == 0 then -- 1233
		return true -- 1235
	end -- 1235
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 1237
	if not payload then -- 1237
		return false -- 1239
	end -- 1239
	emit("AppWS", "Send", payload) -- 1241
	return true -- 1242
end -- 1233
function getEngineLogText() -- 1624
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 1625
	if not Content:exist(folder) then -- 1625
		Content:mkdir(folder) -- 1627
	end -- 1627
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 1629
	if not App:saveLog(logPath) then -- 1629
		return nil -- 1631
	end -- 1631
	return Content:load(logPath) -- 1633
end -- 1633
function ensureSafeSearchGlobs(globs) -- 1773
	local result = {} -- 1774
	do -- 1774
		local i = 0 -- 1775
		while i < #globs do -- 1775
			result[#result + 1] = globs[i + 1] -- 1776
			i = i + 1 -- 1775
		end -- 1775
	end -- 1775
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1778
	do -- 1778
		local i = 0 -- 1779
		while i < #requiredExcludes do -- 1779
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1779
				result[#result + 1] = requiredExcludes[i + 1] -- 1781
			end -- 1781
			i = i + 1 -- 1779
		end -- 1779
	end -- 1779
	return result -- 1784
end -- 1784
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
ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 438
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 439
local AGENT_DOWNLOAD_TEMP_DIR = "agent" -- 440
local function now() -- 441
	return os.time() -- 441
end -- 441
local function toBool(v) -- 443
	return v ~= 0 and v ~= false and v ~= nil -- 444
end -- 443
local function toStr(v) -- 447
	if v == false or v == nil then -- 447
		return "" -- 448
	end -- 448
	return tostring(v) -- 449
end -- 447
local function isValidWorkspacePath(path) -- 452
	if not path or #path == 0 then -- 452
		return false -- 453
	end -- 453
	if Content:isAbsolutePath(path) then -- 453
		return false -- 454
	end -- 454
	if __TS__StringIncludes(path, "..") then -- 454
		return false -- 455
	end -- 455
	return true -- 456
end -- 452
local function isValidWorkDir(workDir) -- 459
	if not workDir or #workDir == 0 then -- 459
		return false -- 460
	end -- 460
	if not Content:isAbsolutePath(workDir) then -- 460
		return false -- 461
	end -- 461
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 461
		return false -- 462
	end -- 462
	return true -- 463
end -- 459
local function isValidSearchPath(path) -- 466
	if path == "" then -- 466
		return true -- 467
	end -- 467
	if Content:isAbsolutePath(path) then -- 467
		return false -- 468
	end -- 468
	if not path or #path == 0 then -- 468
		return false -- 469
	end -- 469
	if __TS__StringIncludes(path, "..") then -- 469
		return false -- 470
	end -- 470
	return true -- 471
end -- 466
local function resolveWorkspaceFilePath(workDir, path) -- 474
	if not isValidWorkDir(workDir) then -- 474
		return nil -- 475
	end -- 475
	if not isValidWorkspacePath(path) then -- 475
		return nil -- 476
	end -- 476
	return Path(workDir, path) -- 477
end -- 474
local function resolveWorkspaceSearchPath(workDir, path) -- 480
	if not isValidWorkDir(workDir) then -- 480
		return nil -- 481
	end -- 481
	if not isValidSearchPath(path) then -- 481
		return nil -- 482
	end -- 482
	return path == "" and workDir or Path(workDir, path) -- 483
end -- 480
local function toWorkspaceRelativePath(workDir, path) -- 486
	if not path or #path == 0 then -- 486
		return path -- 487
	end -- 487
	if not Content:isAbsolutePath(path) then -- 487
		return path -- 488
	end -- 488
	return Path:getRelative(path, workDir) -- 489
end -- 486
local function toWorkspaceRelativeFileList(workDir, files) -- 492
	return __TS__ArrayMap( -- 493
		files, -- 493
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 493
	) -- 493
end -- 492
local function toWorkspaceRelativeSearchResults(workDir, results) -- 496
	local mapped = {} -- 497
	do -- 497
		local i = 0 -- 498
		while i < #results do -- 498
			local row = results[i + 1] -- 499
			local clone = __TS__ObjectAssign({}, row) -- 500
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 501
			mapped[#mapped + 1] = clone -- 502
			i = i + 1 -- 498
		end -- 498
	end -- 498
	return mapped -- 504
end -- 496
local function resolveWorkspaceDirectoryPath(workDir, path) -- 507
	local relative = __TS__StringTrim(path or "") -- 508
	if relative == "" then -- 508
		return {success = true, path = workDir, relative = "."} -- 510
	end -- 510
	if not isValidWorkDir(workDir) or not isValidWorkspacePath(relative) then -- 510
		return {success = false, message = "invalid cwd path"} -- 513
	end -- 513
	local resolved = Path(workDir, relative) -- 515
	if not Content:exist(resolved) then -- 515
		return {success = false, message = "cwd does not exist"} -- 517
	end -- 517
	if not Content:isdir(resolved) then -- 517
		return {success = false, message = "cwd is not a directory"} -- 520
	end -- 520
	return {success = true, path = resolved, relative = relative} -- 522
end -- 507
local function getDoraAPIDocRoot(docLanguage) -- 525
	local zhDir = Path( -- 526
		Content.assetPath, -- 526
		"Script", -- 526
		"Lib", -- 526
		"Dora", -- 526
		"zh-Hans" -- 526
	) -- 526
	local enDir = Path( -- 527
		Content.assetPath, -- 527
		"Script", -- 527
		"Lib", -- 527
		"Dora", -- 527
		"en" -- 527
	) -- 527
	return docLanguage == "zh" and zhDir or enDir -- 528
end -- 525
local function getDoraTutorialDocRoot(docLanguage) -- 531
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 532
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 533
	return docLanguage == "zh" and zhDir or enDir -- 534
end -- 531
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 537
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 537
		return {"ts"} -- 539
	end -- 539
	return {"tl"} -- 541
end -- 537
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 544
	repeat -- 544
		local ____switch65 = programmingLanguage -- 544
		local ____cond65 = ____switch65 == "teal" -- 544
		if ____cond65 then -- 544
			return "tl" -- 546
		end -- 546
		____cond65 = ____cond65 or ____switch65 == "tl" -- 546
		if ____cond65 then -- 546
			return "tl" -- 547
		end -- 547
		do -- 547
			return programmingLanguage -- 548
		end -- 548
	until true -- 548
end -- 544
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 552
	if docSource == "tutorial" then -- 552
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 558
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 559
		return { -- 560
			root = Path(tutorialRoot, langDir), -- 561
			exts = {"md"}, -- 562
			globs = {"**/*.md"} -- 563
		} -- 563
	end -- 563
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 566
	return { -- 567
		root = getDoraAPIDocRoot(docLanguage), -- 568
		exts = exts, -- 569
		globs = __TS__ArrayMap( -- 570
			exts, -- 570
			function(____, ext) return "**/*." .. ext end -- 570
		) -- 570
	} -- 570
end -- 552
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 574
	if docSource == "tutorial" then -- 574
		return getDoraTutorialDocRoot(docLanguage) -- 576
	end -- 576
	return getDoraAPIDocRoot(docLanguage) -- 578
end -- 574
local AGENT_DORA_DOC_PREFIX = "@dora-doc/" -- 581
local function toDocRelativePath(baseRoot, path, docSource) -- 583
	if not path or #path == 0 then -- 583
		return path -- 584
	end -- 584
	local relative = Content:isAbsolutePath(path) and Path:getRelative(path, baseRoot) or path -- 585
	return ((AGENT_DORA_DOC_PREFIX .. docSource) .. "/") .. relative -- 586
end -- 583
local function resolveAgentDoraDocFilePath(path, docLanguage) -- 589
	if not docLanguage then -- 589
		return nil -- 590
	end -- 590
	local relative = path -- 591
	local source = "tutorial" -- 592
	if __TS__StringStartsWith(path, AGENT_DORA_DOC_PREFIX) then -- 592
		local namespaced = __TS__StringSlice(path, #AGENT_DORA_DOC_PREFIX) -- 594
		if __TS__StringStartsWith(namespaced, "api/") then -- 594
			source = "api" -- 596
			relative = string.sub(namespaced, 5) -- 597
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 597
			relative = string.sub(namespaced, 10) -- 599
		else -- 599
			return nil -- 601
		end -- 601
	end -- 601
	if not isValidWorkspacePath(relative) then -- 601
		return nil -- 604
	end -- 604
	local candidate = Path( -- 605
		getDoraDocResultBaseRoot(source, docLanguage), -- 605
		relative -- 605
	) -- 605
	local root = getDoraDocResultBaseRoot(source, docLanguage) -- 606
	local checked = Path:getRelative(candidate, root) -- 607
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 607
		return nil -- 608
	end -- 608
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 608
		return candidate -- 610
	end -- 610
	return nil -- 612
end -- 589
local function ensureDirPath(dir) -- 615
	if not dir or dir == "." or dir == "" then -- 615
		return true -- 616
	end -- 616
	if Content:exist(dir) then -- 616
		return Content:isdir(dir) -- 617
	end -- 617
	local parent = Path:getPath(dir) -- 618
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 618
		if not ensureDirPath(parent) then -- 618
			return false -- 620
		end -- 620
	end -- 620
	return Content:mkdir(dir) -- 622
end -- 615
local function ensureDirForFile(path) -- 625
	local dir = Path:getPath(path) -- 626
	return ensureDirPath(dir) -- 627
end -- 625
local function isHttpUrl(url) -- 630
	local normalized = string.lower(__TS__StringTrim(url)) -- 631
	return __TS__StringStartsWith(normalized, "http://") or __TS__StringStartsWith(normalized, "https://") -- 632
end -- 630
local function createOperationId() -- 635
	local raw = (tostring(os.time()) .. "-") .. tostring(math.floor(math.random() * 1000000000)) -- 636
	local safe = string.gsub(raw, "[^%w%-_]", "-") -- 637
	return safe -- 638
end -- 635
local function getAgentDownloadTempRoot() -- 641
	return Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR, AGENT_DOWNLOAD_TEMP_DIR) -- 642
end -- 641
local function cleanupPath(path) -- 645
	if not path or path == "" or not Content:exist(path) then -- 645
		return nil -- 646
	end -- 646
	if Content:remove(path) then -- 646
		return nil -- 647
	end -- 647
	return "failed to remove temporary path: " .. path -- 648
end -- 645
local function quoteGitArg(value) -- 651
	local plain = string.match(value, "^[%w%._%-%/]+$") -- 652
	if plain ~= nil then -- 652
		return value -- 654
	end -- 654
	local escaped = string.gsub(value, "\\", "\\\\") -- 656
	escaped = string.gsub(escaped, "\"", "\\\"") -- 657
	return ("\"" .. escaped) .. "\"" -- 658
end -- 651
local function shellSplit(command) -- 661
	local args = {} -- 662
	local current = "" -- 663
	local quote = "" -- 664
	local escaped = false -- 665
	do -- 665
		local i = 0 -- 666
		while i < #command do -- 666
			do -- 666
				local ch = __TS__StringCharAt(command, i) -- 667
				if escaped then -- 667
					current = current .. ch -- 669
					escaped = false -- 670
					goto __continue98 -- 671
				end -- 671
				if ch == "\\" then -- 671
					escaped = true -- 674
					goto __continue98 -- 675
				end -- 675
				if quote ~= "" then -- 675
					if ch == quote then -- 675
						quote = "" -- 679
					else -- 679
						current = current .. ch -- 681
					end -- 681
					goto __continue98 -- 683
				end -- 683
				if ch == "'" or ch == "\"" then -- 683
					quote = ch -- 686
					goto __continue98 -- 687
				end -- 687
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 687
					if current ~= "" then -- 687
						args[#args + 1] = current -- 691
						current = "" -- 692
					end -- 692
					goto __continue98 -- 694
				end -- 694
				current = current .. ch -- 696
			end -- 696
			::__continue98:: -- 696
			i = i + 1 -- 666
		end -- 666
	end -- 666
	if escaped then -- 666
		current = current .. "\\" -- 699
	end -- 699
	if current ~= "" then -- 699
		args[#args + 1] = current -- 702
	end -- 702
	return args -- 704
end -- 661
local function normalizeGitCommand(command) -- 707
	local trimmed = __TS__StringTrim(command) -- 708
	local normalized = string.lower(string.sub(trimmed, 1, 4)) == "git " and __TS__StringTrim(string.sub(trimmed, 5)) or trimmed -- 709
	return normalizeEscapedGitQuotes(normalized) -- 712
end -- 707
local function gitDefaultTargetFromUrl(url) -- 730
	local target = url -- 731
	local hashIndex = (string.find(target, "#", nil, true) or 0) - 1 -- 732
	if hashIndex >= 0 then -- 732
		target = __TS__StringSlice(target, 0, hashIndex) -- 733
	end -- 733
	local queryIndex = (string.find(target, "?", nil, true) or 0) - 1 -- 734
	if queryIndex >= 0 then -- 734
		target = __TS__StringSlice(target, 0, queryIndex) -- 735
	end -- 735
	target = string.gsub(target, "/+$", "") -- 736
	local name = string.match(target, "([^/]+)$") -- 737
	if name ~= nil and name ~= "" then -- 737
		target = name -- 738
	end -- 738
	if __TS__StringEndsWith( -- 738
		string.lower(target), -- 739
		".git" -- 739
	) then -- 739
		target = __TS__StringSlice(target, 0, #target - 4) -- 740
	end -- 740
	return target ~= "" and target or "repo" -- 742
end -- 730
local function parseGitCloneCommand(command) -- 745
	local args = shellSplit(normalizeGitCommand(command)) -- 755
	if #args == 0 or args[1] ~= "clone" then -- 755
		return nil -- 756
	end -- 756
	local url = "" -- 757
	local target = "" -- 758
	local ref -- 759
	local depth -- 760
	do -- 760
		local i = 1 -- 761
		while i < #args do -- 761
			do -- 761
				local arg = args[i + 1] -- 762
				if arg == "-b" or arg == "--branch" then
					i = i + 1 -- 764
					if i >= #args then -- 764
						return {success = false, message = arg .. " requires a value"} -- 765
					end -- 765
					ref = args[i + 1] -- 766
					goto __continue122 -- 767
				end -- 767
				if arg == "--depth" then
					i = i + 1 -- 770
					if i >= #args then -- 770
						return {success = false, message = "--depth requires a value"}
					end -- 771
					depth = args[i + 1] -- 772
					goto __continue122 -- 773
				end -- 773
				if __TS__StringStartsWith(arg, "--depth=") then
					depth = __TS__StringSlice(arg, #"--depth=")
					goto __continue122 -- 777
				end -- 777
				if __TS__StringStartsWith(arg, "-") then -- 777
					return {success = false, message = "unsupported clone option: " .. arg} -- 780
				end -- 780
				if url == "" then -- 780
					url = arg -- 783
					goto __continue122 -- 784
				end -- 784
				if target == "" then -- 784
					target = arg -- 787
					goto __continue122 -- 788
				end -- 788
				return {success = false, message = "unexpected clone argument: " .. arg} -- 790
			end -- 790
			::__continue122:: -- 790
			i = i + 1 -- 761
		end -- 761
	end -- 761
	if url == "" then -- 761
		return {success = false, message = "git clone requires a URL"} -- 792
	end -- 792
	if not isHttpUrl(url) then -- 792
		return {success = false, message = "git clone only supports http:// and https:// URLs"} -- 793
	end -- 793
	if target == "" then -- 793
		target = gitDefaultTargetFromUrl(url) -- 794
	end -- 794
	return { -- 795
		success = true, -- 796
		url = url, -- 797
		target = target, -- 798
		ref = ref, -- 799
		depth = depth ~= nil and depth ~= "" and depth or "1" -- 800
	} -- 800
end -- 745
local function getGitHeadCommit(repoPath) -- 804
	local headPath = Path(repoPath, ".git", "HEAD") -- 805
	if not Content:exist(headPath) then -- 805
		return nil -- 806
	end -- 806
	local head = __TS__StringTrim(toStr(Content:load(headPath))) -- 807
	local ref = string.match(head, "^ref:%s*(.-)%s*$") -- 808
	if ref ~= nil and ref ~= "" then -- 808
		local refPath = Path(repoPath, ".git", ref) -- 810
		if Content:exist(refPath) then -- 810
			local commit = __TS__StringTrim(toStr(Content:load(refPath))) -- 812
			return commit ~= "" and commit or nil -- 813
		end -- 813
		return nil -- 815
	end -- 815
	return head ~= "" and head or nil -- 817
end -- 804
local function runGitAndWait(repoPath, command, onStatus, isCancelled, timeout) -- 820
	if timeout == nil then -- 820
		timeout = 600 -- 825
	end -- 825
	return __TS__New( -- 827
		__TS__Promise, -- 827
		function(____, resolve) -- 827
			local status -- 828
			local jobId = 0 -- 829
			local settled = false -- 830
			local canceled = false -- 831
			local function finish(result) -- 832
				if settled then -- 832
					return -- 833
				end -- 833
				settled = true -- 834
				resolve(nil, result) -- 835
			end -- 832
			local function finishFromStatus() -- 837
				local state = toStr(status and status.state) -- 838
				if state == "done" then -- 838
					finish({success = true, status = status}) -- 840
					return true -- 841
				end -- 841
				if state == "error" or state == "canceled" then -- 841
					local errorMessage = toStr(status and status.error) -- 844
					local statusMessage = toStr(status and status.message) -- 845
					finish({success = false, message = errorMessage ~= "" and errorMessage or (statusMessage ~= "" and statusMessage or (state == "canceled" and "git command canceled" or "git command failed")), status = status, interrupted = state == "canceled"}) -- 846
					return true -- 852
				end -- 852
				return false -- 854
			end -- 837
			jobId = Git:run( -- 856
				repoPath, -- 856
				command, -- 856
				function(nextStatus) -- 856
					status = nextStatus -- 857
					if onStatus then -- 857
						onStatus(status) -- 858
					end -- 858
					return finishFromStatus() -- 859
				end, -- 856
				"" -- 860
			) -- 860
			if jobId == nil or jobId <= 0 then -- 860
				finish({success = false, message = "failed to start git command"}) -- 862
				return -- 863
			end -- 863
			if not status then -- 863
				local kind = string.match(command, "^(%S+)") -- 866
				status = { -- 867
					id = jobId, -- 868
					state = "queued", -- 869
					kind = toStr(kind), -- 870
					repoPath = repoPath, -- 871
					progress = 0, -- 872
					message = "queued" -- 873
				} -- 873
			end -- 873
			if onStatus then -- 873
				onStatus(status) -- 876
			end -- 876
			local startedAt = os.time() -- 877
			local lastEmitAt = startedAt -- 878
			Director.systemScheduler:schedule(function() -- 879
				if settled then -- 879
					return true -- 880
				end -- 880
				if not canceled and isCancelled and isCancelled() then -- 880
					canceled = true -- 882
					Git:cancel(jobId) -- 883
					finish({success = false, message = "git command canceled", status = status, interrupted = true}) -- 884
					return true -- 885
				end -- 885
				if finishFromStatus() then -- 885
					return true -- 887
				end -- 887
				local nowTime = os.time() -- 888
				if nowTime - startedAt >= timeout then -- 888
					Git:cancel(jobId) -- 890
					finish({success = false, message = "git command timed out", status = status}) -- 891
					return true -- 892
				end -- 892
				if onStatus and status and nowTime > lastEmitAt then -- 892
					lastEmitAt = nowTime -- 895
					onStatus(status) -- 896
				end -- 896
				return false -- 898
			end) -- 879
		end -- 827
	) -- 827
end -- 820
local function downloadFile(req) -- 903
	return __TS__New( -- 910
		__TS__Promise, -- 910
		function(____, resolve) -- 910
			local requestId = 0 -- 911
			local settled = false -- 912
			local bytesWritten = 0 -- 913
			local function finish(result) -- 914
				if settled then -- 914
					return -- 915
				end -- 915
				settled = true -- 916
				requestId = 0 -- 917
				resolve(nil, result) -- 918
			end -- 914
			Director.systemScheduler:schedule(function() -- 920
				if settled then -- 920
					return true -- 921
				end -- 921
				local ____this_9 -- 921
				____this_9 = req -- 922
				local ____opt_8 = ____this_9.isCancelled -- 922
				if (____opt_8 and ____opt_8(____this_9)) == true and requestId ~= 0 then -- 922
					HttpClient:cancel(requestId) -- 923
					finish({success = false, interrupted = true, message = "download canceled"}) -- 924
					return true -- 925
				end -- 925
				if requestId ~= 0 and not HttpClient:isRequestActive(requestId) then -- 925
					finish({success = false, message = "download request ended without a completion callback"}) -- 928
					return true -- 929
				end -- 929
				return false -- 931
			end) -- 920
			Director.systemScheduler:schedule(once(function() -- 933
				requestId = HttpClient:download( -- 934
					req.url, -- 934
					req.tempPath, -- 934
					req.timeout, -- 934
					function(interrupted, current, total) -- 934
						if type(current) == "number" and current > bytesWritten then -- 934
							bytesWritten = current -- 936
						end -- 936
						if interrupted then -- 936
							finish({success = false, interrupted = true, message = "download failed"}) -- 939
							return true -- 940
						end -- 940
						local ____this_11 -- 940
						____this_11 = req -- 942
						local ____opt_10 = ____this_11.isCancelled -- 942
						if (____opt_10 and ____opt_10(____this_11)) == true then -- 942
							finish({success = false, interrupted = true, message = "download canceled"}) -- 943
							return true -- 944
						end -- 944
						if current == total then -- 944
							finish({success = true, bytesWritten = bytesWritten}) -- 947
							return false -- 948
						end -- 948
						req:onProgress(current, total) -- 950
						return false -- 951
					end -- 934
				) -- 934
				if requestId == 0 then -- 934
					finish({success = false, message = "failed to schedule download request"}) -- 954
				else -- 954
					local ____this_13 -- 954
					____this_13 = req -- 955
					local ____opt_12 = ____this_13.isCancelled -- 955
					if (____opt_12 and ____opt_12(____this_13)) == true then -- 955
						HttpClient:cancel(requestId) -- 956
						finish({success = false, interrupted = true, message = "download canceled"}) -- 957
					end -- 957
				end -- 957
			end)) -- 933
		end -- 910
	) -- 910
end -- 903
local function getFileState(path) -- 963
	local exists = Content:exist(path) -- 964
	if not exists then -- 964
		return {exists = false, content = "", bytes = 0} -- 966
	end -- 966
	if Content:isdir(path) then -- 966
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 973
	end -- 973
	local content = Content:load(path) -- 980
	if type(content) ~= "string" then -- 980
		return {exists = true, content = "", bytes = 0} -- 982
	end -- 982
	return {exists = true, content = content, bytes = #content} -- 988
end -- 963
local function inspectReadableFile(path) -- 995
	do -- 995
		local function ____catch(e) -- 995
			Log( -- 1017
				"Warn", -- 1017
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 1017
			) -- 1017
			return true, {success = true} -- 1018
		end -- 1018
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1018
			local size, isBinary = Content:getAttr(path) -- 997
			if size == nil then -- 997
				return true, {success = false, message = "failed to read file"} -- 999
			end -- 999
			if isBinary then -- 999
				return true, { -- 1005
					success = false, -- 1006
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 1007
					size = type(size) == "number" and size or nil, -- 1008
					isBinary = true -- 1009
				} -- 1009
			end -- 1009
			return true, { -- 1012
				success = true, -- 1013
				size = type(size) == "number" and size or nil -- 1014
			} -- 1014
		end) -- 1014
		if not ____try then -- 1014
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1014
		end -- 1014
		if ____hasReturned then -- 1014
			return ____returnValue -- 996
		end -- 996
	end -- 996
end -- 995
local function isEngineLogFilePath(path) -- 1022
	return path == ENGINE_LOG_FILE -- 1023
end -- 1022
local function readEngineLogFile(path) -- 1026
	if not isEngineLogFilePath(path) then -- 1026
		return nil -- 1027
	end -- 1027
	local content = getEngineLogText() -- 1028
	if content == nil then -- 1028
		return {success = false, message = "failed to read engine logs"} -- 1030
	end -- 1030
	return {success = true, content = content, size = #content} -- 1032
end -- 1026
local function queryOne(sql, args) -- 1035
	local ____args_14 -- 1036
	if args then -- 1036
		____args_14 = DB:query(sql, args) -- 1036
	else -- 1036
		____args_14 = DB:query(sql) -- 1036
	end -- 1036
	local rows = ____args_14 -- 1036
	if not rows or #rows == 0 then -- 1036
		return nil -- 1037
	end -- 1037
	return rows[1] -- 1038
end -- 1035
local function isDtsFile(path) -- 1041
	return Path:getExt(Path:getName(path)) == "d" -- 1042
end -- 1041
local function isTiledEditorContent(content) -- 1045
	return __TS__StringStartsWith( -- 1046
		__TS__StringTrim(content), -- 1046
		"<?xml" -- 1046
	) -- 1046
end -- 1045
local function getSupportedBuildKind(path) -- 1051
	repeat -- 1051
		local ____switch190 = Path:getExt(path) -- 1051
		local ____cond190 = ____switch190 == "ts" or ____switch190 == "tsx" -- 1051
		if ____cond190 then -- 1051
			return "ts" -- 1053
		end -- 1053
		____cond190 = ____cond190 or ____switch190 == "xml" -- 1053
		if ____cond190 then -- 1053
			return "xml" -- 1054
		end -- 1054
		____cond190 = ____cond190 or ____switch190 == "tl" -- 1054
		if ____cond190 then -- 1054
			return "teal" -- 1055
		end -- 1055
		____cond190 = ____cond190 or ____switch190 == "lua" -- 1055
		if ____cond190 then -- 1055
			return "lua" -- 1056
		end -- 1056
		____cond190 = ____cond190 or ____switch190 == "yue" -- 1056
		if ____cond190 then -- 1056
			return "yue" -- 1057
		end -- 1057
		____cond190 = ____cond190 or ____switch190 == "yarn" -- 1057
		if ____cond190 then -- 1057
			return "yarn" -- 1058
		end -- 1058
		do -- 1058
			return nil -- 1059
		end -- 1059
	until true -- 1059
end -- 1051
local function getTaskHeadSeq(taskId) -- 1063
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1064
	if not row then -- 1064
		return nil -- 1065
	end -- 1065
	return row[1] or 0 -- 1066
end -- 1063
local function getTaskStatus(taskId) -- 1069
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1070
	if not row then -- 1070
		return nil -- 1071
	end -- 1071
	return toStr(row[1]) -- 1072
end -- 1069
local function getLastInsertRowId() -- 1075
	local row = queryOne("SELECT last_insert_rowid()") -- 1076
	return row and (row[1] or 0) or 0 -- 1077
end -- 1075
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 1080
	DB:exec( -- 1081
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 1081
		{ -- 1083
			taskId, -- 1083
			seq, -- 1083
			status, -- 1083
			summary, -- 1083
			toolName, -- 1083
			now() -- 1083
		} -- 1083
	) -- 1083
	return getLastInsertRowId() -- 1085
end -- 1080
local function getCheckpointEntries(checkpointId, desc) -- 1088
	if desc == nil then -- 1088
		desc = false -- 1088
	end -- 1088
	local rows = DB:query((("SELECT id, ord, path, op, before_exists,\n\t\t\tdora_decompress_text(before_data),\n\t\t\tafter_exists,\n\t\t\tdora_decompress_text(after_data)\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 1089
	if not rows then -- 1089
		return {} -- 1099
	end -- 1099
	local result = {} -- 1100
	do -- 1100
		local i = 0 -- 1101
		while i < #rows do -- 1101
			local row = rows[i + 1] -- 1102
			result[#result + 1] = { -- 1103
				id = row[1], -- 1104
				ord = row[2], -- 1105
				path = toStr(row[3]), -- 1106
				op = toStr(row[4]), -- 1107
				beforeExists = toBool(row[5]), -- 1108
				beforeContent = toStr(row[6]), -- 1109
				afterExists = toBool(row[7]), -- 1110
				afterContent = toStr(row[8]) -- 1111
			} -- 1111
			i = i + 1 -- 1101
		end -- 1101
	end -- 1101
	return result -- 1114
end -- 1088
local function getCheckpointEntryMetadata(checkpointId, desc) -- 1117
	if desc == nil then -- 1117
		desc = false -- 1117
	end -- 1117
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, after_exists, bytes_before, bytes_after\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 1118
	if not rows then -- 1118
		return {} -- 1125
	end -- 1125
	local result = {} -- 1126
	do -- 1126
		local i = 0 -- 1127
		while i < #rows do -- 1127
			local row = rows[i + 1] -- 1128
			result[#result + 1] = { -- 1129
				id = row[1], -- 1130
				ord = row[2], -- 1131
				path = toStr(row[3]), -- 1132
				op = toStr(row[4]), -- 1133
				beforeExists = toBool(row[5]), -- 1134
				afterExists = toBool(row[6]), -- 1135
				bytesBefore = row[7] or 0, -- 1136
				bytesAfter = row[8] or 0 -- 1137
			} -- 1137
			i = i + 1 -- 1127
		end -- 1127
	end -- 1127
	return result -- 1140
end -- 1117
local function rejectDuplicatePaths(changes) -- 1143
	local seen = __TS__New(Set) -- 1144
	for ____, change in ipairs(changes) do -- 1145
		local key = change.path -- 1146
		if seen:has(key) then -- 1146
			return key -- 1147
		end -- 1147
		seen:add(key) -- 1148
	end -- 1148
	return nil -- 1150
end -- 1143
local function getLinkedDeletePaths(workDir, path) -- 1153
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1154
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 1154
		return {} -- 1155
	end -- 1155
	local parent = Path:getPath(fullPath) -- 1156
	local baseName = string.lower(Path:getName(fullPath)) -- 1157
	local ext = Path:getExt(fullPath) -- 1158
	local linked = {} -- 1159
	for ____, file in ipairs(Content:getFiles(parent)) do -- 1160
		do -- 1160
			if string.lower(Path:getName(file)) ~= baseName then -- 1160
				goto __continue211 -- 1161
			end -- 1161
			local siblingExt = Path:getExt(file) -- 1162
			if siblingExt == "tl" and ext == "vs" then -- 1162
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1164
					workDir, -- 1164
					Path(parent, file) -- 1164
				) -- 1164
				goto __continue211 -- 1165
			end -- 1165
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 1165
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1168
					workDir, -- 1168
					Path(parent, file) -- 1168
				) -- 1168
			end -- 1168
		end -- 1168
		::__continue211:: -- 1168
	end -- 1168
	return linked -- 1171
end -- 1153
local function expandLinkedDeleteChanges(workDir, changes) -- 1174
	local expanded = {} -- 1175
	local seen = __TS__New(Set) -- 1176
	do -- 1176
		local i = 0 -- 1177
		while i < #changes do -- 1177
			do -- 1177
				local change = changes[i + 1] -- 1178
				if not seen:has(change.path) then -- 1178
					seen:add(change.path) -- 1180
					expanded[#expanded + 1] = change -- 1181
				end -- 1181
				if change.op ~= "delete" then -- 1181
					goto __continue218 -- 1183
				end -- 1183
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 1184
				do -- 1184
					local j = 0 -- 1185
					while j < #linkedPaths do -- 1185
						do -- 1185
							local linkedPath = linkedPaths[j + 1] -- 1186
							if seen:has(linkedPath) then -- 1186
								goto __continue222 -- 1187
							end -- 1187
							seen:add(linkedPath) -- 1188
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 1189
						end -- 1189
						::__continue222:: -- 1189
						j = j + 1 -- 1185
					end -- 1185
				end -- 1185
			end -- 1185
			::__continue218:: -- 1185
			i = i + 1 -- 1177
		end -- 1177
	end -- 1177
	return expanded -- 1192
end -- 1174
local function applySingleFile(path, exists, content) -- 1195
	if exists then -- 1195
		if not ensureDirForFile(path) then -- 1195
			return false -- 1197
		end -- 1197
		return Content:save(path, content) -- 1198
	end -- 1198
	if Content:exist(path) then -- 1198
		return Content:remove(path) -- 1201
	end -- 1201
	return true -- 1203
end -- 1195
local function rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 1206
	local entries = getCheckpointEntries(checkpointId, true) -- 1211
	local remaining = appliedCount -- 1212
	local failures = {} -- 1213
	do -- 1213
		local i = 0 -- 1214
		while i < #entries and remaining > 0 do -- 1214
			do -- 1214
				local entry = entries[i + 1] -- 1215
				if entry.ord > appliedCount then -- 1215
					goto __continue230 -- 1216
				end -- 1216
				local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1217
				if not fullPath or not applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) then -- 1217
					failures[#failures + 1] = entry.path -- 1219
				else -- 1219
					____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) -- 1221
				end -- 1221
				remaining = remaining - 1 -- 1223
			end -- 1223
			::__continue230:: -- 1223
			i = i + 1 -- 1214
		end -- 1214
	end -- 1214
	return #failures > 0 and "rollback failed for: " .. table.concat(failures, ", ") or nil -- 1225
end -- 1206
function ____exports.sendWebIDERefreshTree() -- 1245
	if HttpServer.wsConnectionCount == 0 then -- 1245
		return true -- 1247
	end -- 1247
	local payload = encodeJSON({name = "RefreshTree"}) -- 1249
	if not payload then -- 1249
		return false -- 1251
	end -- 1251
	emit("AppWS", "Send", payload) -- 1253
	return true -- 1254
end -- 1245
local function syncProjectFileToWebIDE(workDir, path) -- 1257
	local target = resolveWorkspaceFilePath(workDir, path) -- 1258
	if not target then -- 1258
		return false -- 1259
	end -- 1259
	if not Content:exist(target) then -- 1259
		return ____exports.sendWebIDEFileUpdate(target, false, "") -- 1261
	end -- 1261
	if Content:isdir(target) then -- 1261
		return ____exports.sendWebIDERefreshTree() -- 1264
	end -- 1264
	local content = "" -- 1266
	do -- 1266
		local function ____catch(e) -- 1266
			Log( -- 1274
				"Warn", -- 1274
				(("[Agent.Tools] failed to inspect file for Web IDE update file=" .. target) .. ": ") .. tostring(e) -- 1274
			) -- 1274
		end -- 1274
		local ____try, ____hasReturned = pcall(function() -- 1274
			local ____, isBinary = Content:getAttr(target) -- 1268
			if not isBinary then -- 1268
				local loaded = Content:load(target) -- 1270
				content = type(loaded) == "string" and loaded or "" -- 1271
			end -- 1271
		end) -- 1271
		if not ____try then -- 1271
			____catch(____hasReturned) -- 1271
		end -- 1271
	end -- 1271
	return ____exports.sendWebIDEFileUpdate(target, true, content) -- 1276
end -- 1257
local function refreshProjectTree(workDir, path) -- 1279
	local normalized = type(path) == "string" and __TS__StringTrim(path) or "" -- 1280
	if normalized == "" then -- 1280
		return ____exports.sendWebIDERefreshTree() -- 1282
	end -- 1282
	return syncProjectFileToWebIDE(workDir, normalized) -- 1284
end -- 1279
local function syncDownloadedFileToWebIDE(file) -- 1287
	local content = "" -- 1288
	do -- 1288
		local function ____catch(e) -- 1288
			Log( -- 1296
				"Warn", -- 1296
				(("[fetch_url] failed to inspect downloaded file for Web IDE update file=" .. file) .. ": ") .. tostring(e) -- 1296
			) -- 1296
		end -- 1296
		local ____try, ____hasReturned = pcall(function() -- 1296
			local ____, isBinary = Content:getAttr(file) -- 1290
			if not isBinary then -- 1290
				local loaded = Content:load(file) -- 1292
				content = type(loaded) == "string" and loaded or "" -- 1293
			end -- 1293
		end) -- 1293
		if not ____try then -- 1293
			____catch(____hasReturned) -- 1293
		end -- 1293
	end -- 1293
	return ____exports.sendWebIDEFileUpdate(file, true, content) -- 1298
end -- 1287
local function runSingleNonTsBuild(file) -- 1301
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1301
		return ____awaiter_resolve( -- 1301
			nil, -- 1301
			__TS__New( -- 1302
				__TS__Promise, -- 1302
				function(____, resolve) -- 1302
					local moduleName = "Script.Dev.WebServer" -- 1303
					local ____require_result_15 = require(moduleName) -- 1304
					local buildAsync = ____require_result_15.buildAsync -- 1304
					Director.systemScheduler:schedule(once(function() -- 1305
						local result = buildAsync(file) -- 1306
						resolve(nil, result) -- 1307
					end)) -- 1305
				end -- 1302
			) -- 1302
		) -- 1302
	end) -- 1302
end -- 1301
local transpileRequestSeq = 0 -- 1312
function ____exports.runSingleTsTranspile(file, content, projectRoot) -- 1314
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1314
		local done = false -- 1315
		transpileRequestSeq = transpileRequestSeq + 1 -- 1316
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 1317
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 1318
		if HttpServer.wsConnectionCount == 0 then -- 1318
			return ____awaiter_resolve(nil, result) -- 1318
		end -- 1318
		local listener = Node() -- 1326
		listener:gslot( -- 1327
			"AppWS", -- 1327
			function(event) -- 1327
				if event.type ~= "Receive" then -- 1327
					return -- 1328
				end -- 1328
				local res = safeJsonDecode(event.msg) -- 1329
				if not res or __TS__ArrayIsArray(res) then -- 1329
					return -- 1330
				end -- 1330
				local payload = res -- 1331
				if payload.name ~= "TranspileTS" then -- 1331
					return -- 1332
				end -- 1332
				if payload.id ~= requestId then -- 1332
					return -- 1333
				end -- 1333
				if payload.success then -- 1333
					local luaFile = Path:replaceExt(file, "lua") -- 1335
					if Content:save( -- 1335
						luaFile, -- 1336
						tostring(payload.luaCode) -- 1336
					) then -- 1336
						result = {success = true, file = file} -- 1337
					else -- 1337
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 1339
					end -- 1339
				else -- 1339
					result = { -- 1342
						success = false, -- 1342
						file = file, -- 1342
						message = tostring(payload.message) -- 1342
					} -- 1342
				end -- 1342
				done = true -- 1344
			end -- 1327
		) -- 1327
		local payload = encodeJSON({ -- 1346
			name = "TranspileTS", -- 1347
			id = requestId, -- 1348
			file = file, -- 1349
			content = content, -- 1350
			projectRoot = projectRoot -- 1351
		}) -- 1351
		if not payload then -- 1351
			listener:removeFromParent() -- 1354
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 1354
		end -- 1354
		__TS__Await(__TS__New( -- 1357
			__TS__Promise, -- 1357
			function(____, resolve) -- 1357
				Director.systemScheduler:schedule(once(function() -- 1358
					emit("AppWS", "Send", payload) -- 1359
					wait(function() return done end) -- 1360
					if not done then -- 1360
						listener:removeFromParent() -- 1362
					end -- 1362
					resolve(nil) -- 1364
				end)) -- 1358
			end -- 1357
		)) -- 1357
		return ____awaiter_resolve(nil, result) -- 1357
	end) -- 1357
end -- 1314
function ____exports.createTask(prompt, workMode) -- 1370
	if prompt == nil then -- 1370
		prompt = "" -- 1370
	end -- 1370
	if workMode == nil then -- 1370
		workMode = "code" -- 1370
	end -- 1370
	local storage = requireAgentStorage() -- 1371
	if not storage.success then -- 1371
		return storage -- 1372
	end -- 1372
	local t = now() -- 1373
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, work_mode, created_at, updated_at) VALUES(?, ?, 0, ?, ?, ?)", { -- 1374
		"RUNNING", -- 1376
		prompt, -- 1376
		workMode, -- 1376
		t, -- 1376
		t -- 1376
	}) -- 1376
	if affected <= 0 then -- 1376
		return {success = false, message = "failed to create task"} -- 1379
	end -- 1379
	return { -- 1381
		success = true, -- 1381
		taskId = getLastInsertRowId() -- 1381
	} -- 1381
end -- 1370
function ____exports.setTaskStatus(taskId, status) -- 1384
	DB:exec( -- 1385
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 1385
		{ -- 1385
			status, -- 1385
			now(), -- 1385
			taskId -- 1385
		} -- 1385
	) -- 1385
	Log( -- 1386
		"Info", -- 1386
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 1386
	) -- 1386
end -- 1384
function ____exports.listCheckpointsForTasks(taskIds) -- 1389
	local normalizedTaskIds = {} -- 1390
	local seenTaskIds = {} -- 1391
	do -- 1391
		local i = 0 -- 1392
		while i < #taskIds do -- 1392
			do -- 1392
				local taskId = math.floor(taskIds[i + 1]) -- 1393
				if taskId <= 0 or seenTaskIds[taskId] then -- 1393
					goto __continue279 -- 1394
				end -- 1394
				seenTaskIds[taskId] = true -- 1395
				normalizedTaskIds[#normalizedTaskIds + 1] = taskId -- 1396
			end -- 1396
			::__continue279:: -- 1396
			i = i + 1 -- 1392
		end -- 1392
	end -- 1392
	if #normalizedTaskIds == 0 then -- 1392
		return {} -- 1398
	end -- 1398
	local placeholders = table.concat( -- 1399
		__TS__ArrayMap( -- 1399
			normalizedTaskIds, -- 1399
			function() return "?" end -- 1399
		), -- 1399
		", " -- 1399
	) -- 1399
	local rows = DB:query(((("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id IN (") .. placeholders) .. ")\n\t\tORDER BY task_id DESC, seq DESC", normalizedTaskIds) -- 1400
	if not rows then -- 1400
		return {} -- 1407
	end -- 1407
	local items = {} -- 1408
	do -- 1408
		local i = 0 -- 1409
		while i < #rows do -- 1409
			local row = rows[i + 1] -- 1410
			items[#items + 1] = { -- 1411
				id = row[1], -- 1412
				taskId = row[2], -- 1413
				seq = row[3], -- 1414
				status = toStr(row[4]), -- 1415
				summary = toStr(row[5]), -- 1416
				toolName = toStr(row[6]), -- 1417
				createdAt = row[7] -- 1418
			} -- 1418
			i = i + 1 -- 1409
		end -- 1409
	end -- 1409
	return items -- 1421
end -- 1389
function ____exports.listCheckpoints(taskId) -- 1424
	return ____exports.listCheckpointsForTasks({taskId}) -- 1425
end -- 1424
function ____exports.getCheckpoint(checkpointId) -- 1428
	if checkpointId <= 0 then -- 1428
		return nil -- 1429
	end -- 1429
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE id = ?\n\t\tLIMIT 1", {checkpointId}) -- 1430
	if not rows or #rows == 0 then -- 1430
		return nil -- 1437
	end -- 1437
	local row = rows[1] -- 1438
	return { -- 1439
		id = row[1], -- 1440
		taskId = row[2], -- 1441
		seq = row[3], -- 1442
		status = toStr(row[4]), -- 1443
		summary = toStr(row[5]), -- 1444
		toolName = toStr(row[6]), -- 1445
		createdAt = row[7] -- 1446
	} -- 1446
end -- 1428
local function listCheckpointIdsForTask(taskId, desc) -- 1450
	if desc == nil then -- 1450
		desc = false -- 1450
	end -- 1450
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 1451
	if not rows then -- 1451
		return {} -- 1458
	end -- 1458
	local items = {} -- 1459
	do -- 1459
		local i = 0 -- 1460
		while i < #rows do -- 1460
			local row = rows[i + 1] -- 1461
			items[#items + 1] = {id = row[1], seq = row[2]} -- 1462
			i = i + 1 -- 1460
		end -- 1460
	end -- 1460
	return items -- 1467
end -- 1450
local function deriveFileOp(beforeExists, afterExists) -- 1470
	if not beforeExists and afterExists then -- 1470
		return "create" -- 1471
	end -- 1471
	if beforeExists and not afterExists then -- 1471
		return "delete" -- 1472
	end -- 1472
	return "write" -- 1473
end -- 1470
function ____exports.summarizeTaskChangeSet(taskId) -- 1476
	if not getTaskStatus(taskId) then -- 1476
		return {success = false, message = "task not found"} -- 1478
	end -- 1478
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1480
	local filesByPath = {} -- 1481
	local latestCheckpointId = nil -- 1487
	local latestCheckpointSeq = nil -- 1488
	do -- 1488
		local i = 0 -- 1489
		while i < #checkpoints do -- 1489
			local checkpoint = checkpoints[i + 1] -- 1490
			latestCheckpointId = checkpoint.id -- 1491
			latestCheckpointSeq = checkpoint.seq -- 1492
			local entries = getCheckpointEntryMetadata(checkpoint.id, false) -- 1493
			do -- 1493
				local j = 0 -- 1494
				while j < #entries do -- 1494
					local entry = entries[j + 1] -- 1495
					local item = filesByPath[entry.path] -- 1496
					if not item then -- 1496
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 1498
						filesByPath[entry.path] = item -- 1504
					end -- 1504
					item.afterExists = entry.afterExists -- 1506
					local ____item_checkpointIds_16 = item.checkpointIds -- 1506
					____item_checkpointIds_16[#____item_checkpointIds_16 + 1] = checkpoint.id -- 1507
					j = j + 1 -- 1494
				end -- 1494
			end -- 1494
			i = i + 1 -- 1489
		end -- 1489
	end -- 1489
	local files = {} -- 1510
	for ____, item in pairs(filesByPath) do -- 1511
		files[#files + 1] = { -- 1512
			path = item.path, -- 1513
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1514
			checkpointCount = #item.checkpointIds, -- 1515
			checkpointIds = item.checkpointIds -- 1516
		} -- 1516
	end -- 1516
	__TS__ArraySort( -- 1519
		files, -- 1519
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1519
	) -- 1519
	return { -- 1520
		success = true, -- 1521
		taskId = taskId, -- 1522
		checkpointCount = #checkpoints, -- 1523
		filesChanged = #files, -- 1524
		files = files, -- 1525
		latestCheckpointId = latestCheckpointId, -- 1526
		latestCheckpointSeq = latestCheckpointSeq -- 1527
	} -- 1527
end -- 1476
function ____exports.getTaskChangeSetDiff(taskId) -- 1531
	if not getTaskStatus(taskId) then -- 1531
		return {success = false, message = "task not found"} -- 1533
	end -- 1533
	local entryRows = DB:query(((("SELECT e.id, e.path, e.before_exists, e.after_exists\n\t\tFROM " .. TABLE_ENTRY) .. " e\n\t\tJOIN ") .. TABLE_CP) .. " c ON c.id = e.checkpoint_id\n\t\tWHERE c.task_id = ? AND c.status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY c.seq ASC, e.ord ASC", {taskId}) -- 1535
	if not entryRows or #entryRows == 0 then -- 1535
		return {success = false, message = "change set not found or empty"} -- 1544
	end -- 1544
	local filesByPath = {} -- 1546
	do -- 1546
		local i = 0 -- 1553
		while i < #entryRows do -- 1553
			local row = entryRows[i + 1] -- 1554
			local entryId = row[1] -- 1555
			local path = toStr(row[2]) -- 1556
			local item = filesByPath[path] -- 1557
			if not item then -- 1557
				item = { -- 1559
					path = path, -- 1560
					firstEntryId = entryId, -- 1561
					lastEntryId = entryId, -- 1562
					beforeExists = toBool(row[3]), -- 1563
					afterExists = toBool(row[4]) -- 1564
				} -- 1564
				filesByPath[path] = item -- 1566
			end -- 1566
			item.lastEntryId = entryId -- 1568
			item.afterExists = toBool(row[4]) -- 1569
			i = i + 1 -- 1553
		end -- 1553
	end -- 1553
	local files = {} -- 1571
	for ____, item in pairs(filesByPath) do -- 1572
		local contentRows = DB:query(((("SELECT\n\t\t\t\t(SELECT dora_decompress_text(before_data) FROM " .. TABLE_ENTRY) .. " WHERE id = ?),\n\t\t\t\t(SELECT dora_decompress_text(after_data) FROM ") .. TABLE_ENTRY) .. " WHERE id = ?)", {item.firstEntryId, item.lastEntryId}) -- 1573
		if not contentRows or #contentRows == 0 then -- 1573
			return {success = false, message = "failed to read checkpoint data for " .. item.path} -- 1580
		end -- 1580
		files[#files + 1] = { -- 1582
			path = item.path, -- 1583
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1584
			beforeExists = item.beforeExists, -- 1585
			afterExists = item.afterExists, -- 1586
			beforeContent = toStr(contentRows[1][1]), -- 1587
			afterContent = toStr(contentRows[1][2]) -- 1588
		} -- 1588
	end -- 1588
	__TS__ArraySort( -- 1591
		files, -- 1591
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1591
	) -- 1591
	return {success = true, files = files} -- 1592
end -- 1531
local function readWorkspaceFile(workDir, path, docLanguage) -- 1595
	local engineLog = readEngineLogFile(path) -- 1596
	if engineLog then -- 1596
		return engineLog -- 1597
	end -- 1597
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1598
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 1598
		local attr = inspectReadableFile(fullPath) -- 1600
		if not attr.success then -- 1600
			return attr -- 1601
		end -- 1601
		return { -- 1602
			success = true, -- 1602
			content = Content:load(fullPath), -- 1602
			size = attr.size -- 1602
		} -- 1602
	end -- 1602
	local docPath = resolveAgentDoraDocFilePath(path, docLanguage) -- 1604
	if docPath then -- 1604
		local attr = inspectReadableFile(docPath) -- 1606
		if not attr.success then -- 1606
			return attr -- 1607
		end -- 1607
		return { -- 1608
			success = true, -- 1608
			content = Content:load(docPath), -- 1608
			size = attr.size -- 1608
		} -- 1608
	end -- 1608
	if not fullPath then -- 1608
		return {success = false, message = "invalid path or workDir"} -- 1610
	end -- 1610
	return {success = false, message = "file not found"} -- 1611
end -- 1595
function ____exports.readFileRaw(workDir, path, docLanguage) -- 1614
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 1615
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 1615
		local attr = inspectReadableFile(path) -- 1617
		if not attr.success then -- 1617
			return attr -- 1618
		end -- 1618
		return { -- 1619
			success = true, -- 1619
			content = Content:load(path), -- 1619
			size = attr.size -- 1619
		} -- 1619
	end -- 1619
	return result -- 1621
end -- 1614
function ____exports.getLogs(req) -- 1636
	local text = getEngineLogText() -- 1637
	if text == nil then -- 1637
		return {success = false, message = "failed to read engine logs"} -- 1639
	end -- 1639
	local tailLines = math.max( -- 1641
		1, -- 1641
		math.floor(req and req.tailLines or 200) -- 1641
	) -- 1641
	local allLines = __TS__StringSplit(text, "\n") -- 1642
	local logs = __TS__ArraySlice( -- 1643
		allLines, -- 1643
		math.max(0, #allLines - tailLines) -- 1643
	) -- 1643
	return req and req.joinText and ({ -- 1644
		success = true, -- 1644
		logs = logs, -- 1644
		text = table.concat(logs, "\n") -- 1644
	}) or ({success = true, logs = logs}) -- 1644
end -- 1636
function ____exports.listFiles(req) -- 1647
	local root = req.path or "" -- 1653
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 1654
	if not searchRoot then -- 1654
		return {success = false, message = "invalid path or workDir"} -- 1656
	end -- 1656
	do -- 1656
		local function ____catch(e) -- 1656
			return true, { -- 1674
				success = false, -- 1674
				message = tostring(e) -- 1674
			} -- 1674
		end -- 1674
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1674
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 1659
			local globs = ensureSafeSearchGlobs(userGlobs) -- 1660
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 1661
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 1662
			local totalEntries = #files -- 1663
			local maxEntries = math.max( -- 1664
				1, -- 1664
				math.floor(req.maxEntries or 200) -- 1664
			) -- 1664
			local truncated = totalEntries > maxEntries -- 1665
			return true, { -- 1666
				success = true, -- 1667
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 1668
				totalEntries = totalEntries, -- 1669
				truncated = truncated, -- 1670
				maxEntries = maxEntries -- 1671
			} -- 1671
		end) -- 1671
		if not ____try then -- 1671
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1671
		end -- 1671
		if ____hasReturned then -- 1671
			return ____returnValue -- 1658
		end -- 1658
	end -- 1658
end -- 1647
local function formatReadSlice(content, startLine, endLine) -- 1678
	local lines = __TS__StringSplit(content, "\n") -- 1683
	local totalLines = #lines -- 1684
	if totalLines == 0 then -- 1684
		return { -- 1686
			success = true, -- 1687
			content = "", -- 1688
			totalLines = 0, -- 1689
			startLine = 1, -- 1690
			endLine = 0, -- 1691
			truncated = false -- 1692
		} -- 1692
	end -- 1692
	local rawStart = math.floor(startLine) -- 1695
	local rawEnd = math.floor(endLine) -- 1696
	if rawStart == 0 then -- 1696
		return {success = false, message = "startLine cannot be 0"} -- 1698
	end -- 1698
	if rawEnd == 0 then -- 1698
		return {success = false, message = "endLine cannot be 0"} -- 1701
	end -- 1701
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1703
	if start > totalLines then -- 1703
		return { -- 1707
			success = false, -- 1707
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1707
		} -- 1707
	end -- 1707
	local ____end = math.min( -- 1709
		totalLines, -- 1710
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1711
	) -- 1711
	if ____end < start then -- 1711
		return { -- 1716
			success = false, -- 1717
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1718
		} -- 1718
	end -- 1718
	local slice = {} -- 1721
	do -- 1721
		local i = start -- 1722
		while i <= ____end do -- 1722
			slice[#slice + 1] = lines[i] -- 1723
			i = i + 1 -- 1722
		end -- 1722
	end -- 1722
	local truncated = start > 1 or ____end < totalLines -- 1725
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1726
	local body = table.concat(slice, "\n") -- 1731
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1732
	return { -- 1733
		success = true, -- 1734
		content = output, -- 1735
		totalLines = totalLines, -- 1736
		startLine = start, -- 1737
		endLine = ____end, -- 1738
		truncated = truncated -- 1739
	} -- 1739
end -- 1678
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1743
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1750
	if not fallback.success or fallback.content == nil then -- 1750
		return fallback -- 1751
	end -- 1751
	local resolvedStartLine = startLine or 1 -- 1752
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1753
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1754
end -- 1743
local codeExtensions = { -- 1761
	".lua", -- 1761
	".tl", -- 1761
	".yue", -- 1761
	".ts", -- 1761
	".tsx", -- 1761
	".xml", -- 1761
	".md", -- 1761
	".yarn", -- 1761
	".wa", -- 1761
	".mod" -- 1761
} -- 1761
extensionLevels = { -- 1762
	vs = 2, -- 1763
	bl = 2, -- 1764
	ts = 1, -- 1765
	tsx = 1, -- 1766
	tl = 1, -- 1767
	yue = 1, -- 1768
	xml = 1, -- 1769
	lua = 0 -- 1770
} -- 1770
local function splitSearchPatterns(pattern) -- 1787
	local trimmed = __TS__StringTrim(pattern or "") -- 1788
	if trimmed == "" then -- 1788
		return {} -- 1789
	end -- 1789
	local out = {} -- 1790
	local seen = __TS__New(Set) -- 1791
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1792
		local p = __TS__StringTrim(tostring(p0)) -- 1793
		if p ~= "" and not seen:has(p) then -- 1793
			seen:add(p) -- 1795
			out[#out + 1] = p -- 1796
		end -- 1796
	end -- 1796
	return out -- 1799
end -- 1787
local function splitWhitespaceSearchPatterns(pattern) -- 1802
	local out = {} -- 1803
	local seen = __TS__New(Set) -- 1804
	for p0 in string.gmatch(pattern, "(%S+)") do -- 1805
		local p = __TS__StringTrim(tostring(p0)) -- 1806
		local key = string.lower(p) -- 1807
		if p ~= "" and not seen:has(key) then -- 1807
			seen:add(key) -- 1809
			out[#out + 1] = p -- 1810
		end -- 1810
	end -- 1810
	return out -- 1813
end -- 1802
local function mergeSearchFileResultsUnique(resultsList) -- 1816
	local merged = {} -- 1817
	local seen = __TS__New(Set) -- 1818
	do -- 1818
		local i = 0 -- 1819
		while i < #resultsList do -- 1819
			local list = resultsList[i + 1] -- 1820
			do -- 1820
				local j = 0 -- 1821
				while j < #list do -- 1821
					do -- 1821
						local row = list[j + 1] -- 1822
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1823
						if seen:has(key) then -- 1823
							goto __continue361 -- 1824
						end -- 1824
						seen:add(key) -- 1825
						merged[#merged + 1] = list[j + 1] -- 1826
					end -- 1826
					::__continue361:: -- 1826
					j = j + 1 -- 1821
				end -- 1821
			end -- 1821
			i = i + 1 -- 1819
		end -- 1819
	end -- 1819
	return merged -- 1829
end -- 1816
local function buildGroupedSearchResults(results) -- 1832
	local order = {} -- 1837
	local grouped = __TS__New(Map) -- 1838
	do -- 1838
		local i = 0 -- 1843
		while i < #results do -- 1843
			local row = results[i + 1] -- 1844
			local file = row.file -- 1845
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1846
			local bucket = grouped:get(key) -- 1847
			if not bucket then -- 1847
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1849
				grouped:set(key, bucket) -- 1850
				order[#order + 1] = key -- 1851
			end -- 1851
			bucket.totalMatches = bucket.totalMatches + 1 -- 1853
			local ____bucket_matches_21 = bucket.matches -- 1853
			____bucket_matches_21[#____bucket_matches_21 + 1] = results[i + 1] -- 1854
			i = i + 1 -- 1843
		end -- 1843
	end -- 1843
	local out = {} -- 1856
	do -- 1856
		local i = 0 -- 1861
		while i < #order do -- 1861
			local bucket = grouped:get(order[i + 1]) -- 1862
			if bucket then -- 1862
				out[#out + 1] = bucket -- 1863
			end -- 1863
			i = i + 1 -- 1861
		end -- 1861
	end -- 1861
	return out -- 1865
end -- 1832
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1868
	local merged = {} -- 1869
	local seen = __TS__New(Set) -- 1870
	local index = 0 -- 1871
	local advanced = true -- 1872
	while advanced do -- 1872
		advanced = false -- 1874
		do -- 1874
			local i = 0 -- 1875
			while i < #resultsList do -- 1875
				do -- 1875
					local list = resultsList[i + 1] -- 1876
					if index >= #list then -- 1876
						goto __continue373 -- 1877
					end -- 1877
					advanced = true -- 1878
					local row = list[index + 1] -- 1879
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1880
					if seen:has(key) then -- 1880
						goto __continue373 -- 1881
					end -- 1881
					seen:add(key) -- 1882
					merged[#merged + 1] = row -- 1883
				end -- 1883
				::__continue373:: -- 1883
				i = i + 1 -- 1875
			end -- 1875
		end -- 1875
		index = index + 1 -- 1885
	end -- 1885
	return merged -- 1887
end -- 1868
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1890
	if docSource ~= "api" then -- 1890
		return 100 -- 1891
	end -- 1891
	if programmingLanguage ~= "tsx" then -- 1891
		return 100 -- 1892
	end -- 1892
	repeat -- 1892
		local ____switch379 = string.lower(Path:getFilename(file)) -- 1892
		local ____cond379 = ____switch379 == "jsx.d.ts" -- 1892
		if ____cond379 then -- 1892
			return 0 -- 1894
		end -- 1894
		____cond379 = ____cond379 or ____switch379 == "dorax.d.ts" -- 1894
		if ____cond379 then -- 1894
			return 1 -- 1895
		end -- 1895
		____cond379 = ____cond379 or ____switch379 == "dora.d.ts" -- 1895
		if ____cond379 then -- 1895
			return 2 -- 1896
		end -- 1896
		do -- 1896
			return 100 -- 1897
		end -- 1897
	until true -- 1897
end -- 1890
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1901
	local sorted = __TS__ArraySlice(hits) -- 1906
	__TS__ArraySort( -- 1907
		sorted, -- 1907
		function(____, a, b) -- 1907
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1908
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1909
			if pa ~= pb then -- 1909
				return pa - pb -- 1910
			end -- 1910
			local fa = string.lower(a.file) -- 1911
			local fb = string.lower(b.file) -- 1912
			if fa ~= fb then -- 1912
				return fa < fb and -1 or 1 -- 1913
			end -- 1913
			return (a.line or 0) - (b.line or 0) -- 1914
		end -- 1907
	) -- 1907
	return sorted -- 1916
end -- 1901
function ____exports.searchFiles(req) -- 1919
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1919
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1932
		if not resolvedPath then -- 1932
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1932
		end -- 1932
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1936
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1937
		if not searchRoot then -- 1937
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1937
		end -- 1937
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1937
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1937
		end -- 1937
		local patterns = splitSearchPatterns(req.pattern) -- 1944
		if #patterns == 0 then -- 1944
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1944
		end -- 1944
		return ____awaiter_resolve( -- 1944
			nil, -- 1944
			__TS__New( -- 1948
				__TS__Promise, -- 1948
				function(____, resolve) -- 1948
					Director.systemScheduler:schedule(once(function() -- 1949
						do -- 1949
							local function ____catch(e) -- 1949
								resolve( -- 1991
									nil, -- 1991
									{ -- 1991
										success = false, -- 1991
										message = tostring(e) -- 1991
									} -- 1991
								) -- 1991
							end -- 1991
							local ____try, ____hasReturned = pcall(function() -- 1991
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1951
								local allResults = {} -- 1954
								do -- 1954
									local i = 0 -- 1955
									while i < #patterns do -- 1955
										local ____Content_26 = Content -- 1956
										local ____Content_searchFilesAsync_27 = Content.searchFilesAsync -- 1956
										local ____patterns_index_25 = patterns[i + 1] -- 1961
										local ____req_useRegex_22 = req.useRegex -- 1962
										if ____req_useRegex_22 == nil then -- 1962
											____req_useRegex_22 = false -- 1962
										end -- 1962
										local ____req_caseSensitive_23 = req.caseSensitive -- 1963
										if ____req_caseSensitive_23 == nil then -- 1963
											____req_caseSensitive_23 = false -- 1963
										end -- 1963
										local ____req_includeContent_24 = req.includeContent -- 1964
										if ____req_includeContent_24 == nil then -- 1964
											____req_includeContent_24 = true -- 1964
										end -- 1964
										allResults[#allResults + 1] = ____Content_searchFilesAsync_27( -- 1956
											____Content_26, -- 1956
											searchRoot, -- 1957
											codeExtensions, -- 1958
											extensionLevels, -- 1959
											searchGlobs, -- 1960
											____patterns_index_25, -- 1961
											____req_useRegex_22, -- 1962
											____req_caseSensitive_23, -- 1963
											____req_includeContent_24, -- 1964
											req.contentWindow or 120 -- 1965
										) -- 1965
										i = i + 1 -- 1955
									end -- 1955
								end -- 1955
								local results = mergeSearchFileResultsUnique(allResults) -- 1968
								local totalResults = #results -- 1969
								local limit = math.max( -- 1970
									1, -- 1970
									math.floor(req.limit or 20) -- 1970
								) -- 1970
								local offset = math.max( -- 1971
									0, -- 1971
									math.floor(req.offset or 0) -- 1971
								) -- 1971
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1972
								local nextOffset = offset + #paged -- 1973
								local hasMore = nextOffset < totalResults -- 1974
								local truncated = offset > 0 or hasMore -- 1975
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1976
								local groupByFile = req.groupByFile == true -- 1977
								resolve( -- 1978
									nil, -- 1978
									{ -- 1978
										success = true, -- 1979
										results = relativeResults, -- 1980
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1981
										totalResults = totalResults, -- 1982
										truncated = truncated, -- 1983
										limit = limit, -- 1984
										offset = offset, -- 1985
										nextOffset = nextOffset, -- 1986
										hasMore = hasMore, -- 1987
										groupByFile = groupByFile -- 1988
									} -- 1988
								) -- 1988
							end) -- 1988
							if not ____try then -- 1988
								____catch(____hasReturned) -- 1988
							end -- 1988
						end -- 1988
					end)) -- 1949
				end -- 1948
			) -- 1948
		) -- 1948
	end) -- 1948
end -- 1919
function ____exports.searchDoraAPI(req) -- 1997
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1997
		local pattern = __TS__StringTrim(req.pattern or "") -- 2008
		if pattern == "" then -- 2008
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2008
		end -- 2008
		local patterns = splitSearchPatterns(pattern) -- 2010
		if #patterns == 0 then -- 2010
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2010
		end -- 2010
		local docSource = req.docSource or "api" -- 2012
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 2013
		local docRoot = target.root -- 2014
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 2015
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 2015
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 2015
		end -- 2015
		local exts = target.exts -- 2019
		local dotExts = __TS__ArrayMap( -- 2020
			exts, -- 2020
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 2020
		) -- 2020
		local globs = target.globs -- 2021
		local limit = math.max( -- 2022
			1, -- 2022
			math.floor(req.limit or 10) -- 2022
		) -- 2022
		return ____awaiter_resolve( -- 2022
			nil, -- 2022
			__TS__New( -- 2024
				__TS__Promise, -- 2024
				function(____, resolve) -- 2024
					Director.systemScheduler:schedule(once(function() -- 2025
						do -- 2025
							local function ____catch(e) -- 2025
								resolve( -- 2105
									nil, -- 2105
									{ -- 2105
										success = false, -- 2105
										message = tostring(e) -- 2105
									} -- 2105
								) -- 2105
							end -- 2105
							local ____try, ____hasReturned = pcall(function() -- 2105
								local allHits = {} -- 2027
								do -- 2027
									local p = 0 -- 2028
									while p < #patterns do -- 2028
										local ____Content_32 = Content -- 2029
										local ____Content_searchFilesAsync_33 = Content.searchFilesAsync -- 2029
										local ____array_31 = __TS__SparseArrayNew( -- 2029
											docRoot, -- 2030
											dotExts, -- 2031
											{}, -- 2032
											ensureSafeSearchGlobs(globs), -- 2033
											patterns[p + 1] -- 2034
										) -- 2034
										local ____req_useRegex_28 = req.useRegex -- 2035
										if ____req_useRegex_28 == nil then -- 2035
											____req_useRegex_28 = false -- 2035
										end -- 2035
										__TS__SparseArrayPush(____array_31, ____req_useRegex_28) -- 2035
										local ____req_caseSensitive_29 = req.caseSensitive -- 2036
										if ____req_caseSensitive_29 == nil then -- 2036
											____req_caseSensitive_29 = false -- 2036
										end -- 2036
										__TS__SparseArrayPush(____array_31, ____req_caseSensitive_29) -- 2036
										local ____req_includeContent_30 = req.includeContent -- 2037
										if ____req_includeContent_30 == nil then -- 2037
											____req_includeContent_30 = true -- 2037
										end -- 2037
										__TS__SparseArrayPush(____array_31, ____req_includeContent_30, req.contentWindow or 80) -- 2037
										local raw = ____Content_searchFilesAsync_33( -- 2029
											____Content_32, -- 2029
											__TS__SparseArraySpread(____array_31) -- 2029
										) -- 2029
										local hits = {} -- 2040
										do -- 2040
											local i = 0 -- 2041
											while i < #raw do -- 2041
												do -- 2041
													local row = raw[i + 1] -- 2042
													local file = toDocRelativePath(resultBaseRoot, row.file, docSource) -- 2043
													if file == "" then -- 2043
														goto __continue406 -- 2044
													end -- 2044
													hits[#hits + 1] = { -- 2045
														file = file, -- 2046
														line = type(row.line) == "number" and row.line or nil, -- 2047
														content = type(row.content) == "string" and row.content or nil -- 2048
													} -- 2048
												end -- 2048
												::__continue406:: -- 2048
												i = i + 1 -- 2041
											end -- 2041
										end -- 2041
										allHits[#allHits + 1] = __TS__ArraySlice( -- 2051
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 2051
											0, -- 2051
											limit -- 2051
										) -- 2051
										p = p + 1 -- 2028
									end -- 2028
								end -- 2028
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 2053
								local fallbackPatterns -- 2054
								if #hits == 0 and #patterns == 1 and req.useRegex ~= true and (string.find(pattern, "|", nil, true) or 0) - 1 < 0 then -- 2054
									local terms = splitWhitespaceSearchPatterns(pattern) -- 2059
									if #terms > 1 then -- 2059
										fallbackPatterns = terms -- 2061
										local fallbackHits = {} -- 2062
										do -- 2062
											local p = 0 -- 2063
											while p < #terms do -- 2063
												local ____Content_37 = Content -- 2064
												local ____Content_searchFilesAsync_38 = Content.searchFilesAsync -- 2064
												local ____array_36 = __TS__SparseArrayNew( -- 2064
													docRoot, -- 2065
													dotExts, -- 2066
													{}, -- 2067
													ensureSafeSearchGlobs(globs), -- 2068
													terms[p + 1], -- 2069
													false -- 2070
												) -- 2070
												local ____req_caseSensitive_34 = req.caseSensitive -- 2071
												if ____req_caseSensitive_34 == nil then -- 2071
													____req_caseSensitive_34 = false -- 2071
												end -- 2071
												__TS__SparseArrayPush(____array_36, ____req_caseSensitive_34) -- 2071
												local ____req_includeContent_35 = req.includeContent -- 2072
												if ____req_includeContent_35 == nil then -- 2072
													____req_includeContent_35 = true -- 2072
												end -- 2072
												__TS__SparseArrayPush(____array_36, ____req_includeContent_35, req.contentWindow or 80) -- 2072
												local raw = ____Content_searchFilesAsync_38( -- 2064
													____Content_37, -- 2064
													__TS__SparseArraySpread(____array_36) -- 2064
												) -- 2064
												local termHits = {} -- 2075
												do -- 2075
													local i = 0 -- 2076
													while i < #raw do -- 2076
														do -- 2076
															local row = raw[i + 1] -- 2077
															local file = toDocRelativePath(resultBaseRoot, row.file, docSource) -- 2078
															if file == "" then -- 2078
																goto __continue413 -- 2079
															end -- 2079
															termHits[#termHits + 1] = { -- 2080
																file = file, -- 2081
																line = type(row.line) == "number" and row.line or nil, -- 2082
																content = type(row.content) == "string" and row.content or nil -- 2083
															} -- 2083
														end -- 2083
														::__continue413:: -- 2083
														i = i + 1 -- 2076
													end -- 2076
												end -- 2076
												fallbackHits[#fallbackHits + 1] = __TS__ArraySlice( -- 2086
													sortDoraAPISearchHits(termHits, docSource, req.programmingLanguage), -- 2086
													0, -- 2086
													limit -- 2086
												) -- 2086
												p = p + 1 -- 2063
											end -- 2063
										end -- 2063
										hits = mergeDoraAPISearchHitsUnique(fallbackHits) -- 2088
									end -- 2088
								end -- 2088
								resolve(nil, { -- 2091
									success = true, -- 2092
									docSource = docSource, -- 2093
									docLanguage = req.docLanguage, -- 2094
									programmingLanguage = req.programmingLanguage, -- 2095
									exts = exts, -- 2096
									results = hits, -- 2097
									hint = "Use read_file directly with the namespaced file value from a search result to view the complete authoritative document.", -- 2098
									totalResults = #hits, -- 2099
									truncated = false, -- 2100
									limit = limit, -- 2101
									fallbackPatterns = fallbackPatterns -- 2102
								}) -- 2102
							end) -- 2102
							if not ____try then -- 2102
								____catch(____hasReturned) -- 2102
							end -- 2102
						end -- 2102
					end)) -- 2025
				end -- 2024
			) -- 2024
		) -- 2024
	end) -- 2024
end -- 1997
function ____exports.searchDoraAPIHttp(req, callback) -- 2111
	local ____self_39 = ____exports.searchDoraAPI(req) -- 2111
	____self_39["then"]( -- 2111
		____self_39, -- 2111
		function(____, result) return callback(result) end -- 2122
	) -- 2122
end -- 2111
function ____exports.readDoraDoc(req) -- 2125
	local requestedFile = table.concat( -- 2131
		__TS__StringSplit(req.file or "", "\\"), -- 2131
		"/" -- 2131
	) -- 2131
	local file = requestedFile -- 2132
	local namespacedSource = nil -- 2133
	if __TS__StringStartsWith(requestedFile, AGENT_DORA_DOC_PREFIX) then -- 2133
		local namespaced = __TS__StringSlice(requestedFile, #AGENT_DORA_DOC_PREFIX) -- 2135
		if __TS__StringStartsWith(namespaced, "api/") then -- 2135
			namespacedSource = "api" -- 2137
			file = string.sub(namespaced, 5) -- 2138
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 2138
			namespacedSource = "tutorial" -- 2140
			file = string.sub(namespaced, 10) -- 2141
		else -- 2141
			return {success = false, message = "invalid Dora doc namespace"} -- 2143
		end -- 2143
	end -- 2143
	if not isValidWorkspacePath(file) or file == "." then -- 2143
		return {success = false, message = "invalid file"} -- 2147
	end -- 2147
	local lowerFile = string.lower(file) -- 2149
	local isTutorialDoc = __TS__StringEndsWith(lowerFile, ".md") -- 2150
	local isAPIDoc = __TS__StringEndsWith(lowerFile, ".ts") or __TS__StringEndsWith(lowerFile, ".tl") -- 2151
	if not isTutorialDoc and not isAPIDoc then -- 2151
		return {success = false, message = "unsupported doc file type"} -- 2152
	end -- 2152
	local docSource = namespacedSource or (isTutorialDoc and "tutorial" or "api") -- 2153
	local root = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 2154
	local fullPath = Path(root, file) -- 2155
	local relative = Path:getRelative(fullPath, root) -- 2156
	if relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 2156
		return {success = false, message = "invalid file"} -- 2158
	end -- 2158
	local readResult = ____exports.readFile(root, file, req.startLine or 1, req.endLine or -1) -- 2160
	if not readResult.success then -- 2160
		return readResult -- 2161
	end -- 2161
	return { -- 2162
		success = true, -- 2163
		docLanguage = req.docLanguage, -- 2164
		file = file, -- 2165
		content = readResult.content, -- 2166
		startLine = readResult.startLine, -- 2167
		endLine = readResult.endLine -- 2168
	} -- 2168
end -- 2125
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 2172
	if options == nil then -- 2172
		options = {} -- 2172
	end -- 2172
	local storage = requireAgentStorage() -- 2173
	if not storage.success then -- 2173
		return storage -- 2174
	end -- 2174
	if #changes == 0 then -- 2174
		return {success = false, message = "empty changes"} -- 2176
	end -- 2176
	if not isValidWorkDir(workDir) then -- 2176
		return {success = false, message = "invalid workDir"} -- 2179
	end -- 2179
	if not getTaskStatus(taskId) then -- 2179
		return {success = false, message = "task not found"} -- 2182
	end -- 2182
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 2184
	local dup = rejectDuplicatePaths(expandedChanges) -- 2185
	if dup then -- 2185
		return {success = false, message = "duplicate path in batch: " .. dup} -- 2187
	end -- 2187
	for ____, change in ipairs(expandedChanges) do -- 2190
		if not isValidWorkspacePath(change.path) then -- 2190
			return {success = false, message = "invalid path: " .. change.path} -- 2192
		end -- 2192
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 2192
			return {success = false, message = "missing content for " .. change.path} -- 2195
		end -- 2195
	end -- 2195
	local headSeq = getTaskHeadSeq(taskId) -- 2199
	if headSeq == nil then -- 2199
		return {success = false, message = "task not found"} -- 2200
	end -- 2200
	local nextSeq = headSeq + 1 -- 2201
	local preparedEntries = {} -- 2203
	do -- 2203
		local i = 0 -- 2204
		while i < #expandedChanges do -- 2204
			local change = expandedChanges[i + 1] -- 2205
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 2206
			if not fullPath then -- 2206
				return {success = false, message = "invalid path: " .. change.path} -- 2208
			end -- 2208
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 2208
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 2211
			end -- 2211
			local before = getFileState(fullPath) -- 2213
			local afterExists = change.op ~= "delete" -- 2214
			local afterContent = afterExists and (change.content or "") or "" -- 2215
			preparedEntries[#preparedEntries + 1] = { -- 2216
				id = 0, -- 2217
				ord = i + 1, -- 2218
				path = change.path, -- 2219
				op = change.op, -- 2220
				beforeExists = before.exists, -- 2221
				beforeContent = before.content, -- 2222
				afterExists = afterExists, -- 2223
				afterContent = afterContent -- 2224
			} -- 2224
			i = i + 1 -- 2204
		end -- 2204
	end -- 2204
	local checkpointId = insertCheckpoint( -- 2228
		taskId, -- 2228
		nextSeq, -- 2228
		options.summary or "", -- 2228
		options.toolName or "", -- 2228
		"PREPARED" -- 2228
	) -- 2228
	if checkpointId <= 0 then -- 2228
		return {success = false, message = "failed to create checkpoint"} -- 2230
	end -- 2230
	local entryRows = {} -- 2232
	do -- 2232
		local i = 0 -- 2233
		while i < #preparedEntries do -- 2233
			local entry = preparedEntries[i + 1] -- 2234
			entryRows[#entryRows + 1] = { -- 2235
				checkpointId, -- 2236
				entry.ord, -- 2237
				entry.path, -- 2238
				entry.op, -- 2239
				entry.beforeExists and 1 or 0, -- 2240
				entry.beforeContent, -- 2241
				entry.afterExists and 1 or 0, -- 2242
				entry.afterContent, -- 2243
				#entry.beforeContent, -- 2244
				#entry.afterContent -- 2245
			} -- 2245
			i = i + 1 -- 2233
		end -- 2233
	end -- 2233
	local entryInsert = {("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_data, after_exists, after_data, bytes_before, bytes_after)\n\t\tVALUES(?, ?, ?, ?, ?, dora_compress_text(?), ?, dora_compress_text(?), ?, ?)", entryRows} -- 2248
	if not DB:transaction({entryInsert}) then -- 2248
		DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2254
		return {success = false, message = "failed to insert checkpoint entries"} -- 2255
	end -- 2255
	local appliedCount = 0 -- 2258
	for ____, entry in ipairs(preparedEntries) do -- 2259
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2260
		if not fullPath then -- 2260
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2262
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2263
			return {success = false, message = ("invalid path: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2264
		end -- 2264
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 2266
		if not ok then -- 2266
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2268
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount + 1) -- 2269
			return {success = false, message = ("failed to apply file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2270
		end -- 2270
		appliedCount = appliedCount + 1 -- 2272
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 2272
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2274
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2275
			return {success = false, message = ("failed to sync file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; all applied files restored")} -- 2276
		end -- 2276
	end -- 2276
	DB:exec( -- 2280
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 2280
		{ -- 2282
			"APPLIED", -- 2282
			now(), -- 2282
			checkpointId -- 2282
		} -- 2282
	) -- 2282
	DB:exec( -- 2284
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 2284
		{ -- 2286
			nextSeq, -- 2286
			now(), -- 2286
			taskId -- 2286
		} -- 2286
	) -- 2286
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 2288
end -- 2172
function ____exports.deleteFile(taskId, workDir, targetFile, options) -- 2296
	if options == nil then -- 2296
		options = {} -- 2296
	end -- 2296
	local storage = requireAgentStorage() -- 2297
	if not storage.success then -- 2297
		return storage -- 2298
	end -- 2298
	if not isValidWorkDir(workDir) then -- 2298
		return {success = false, message = "invalid workDir"} -- 2300
	end -- 2300
	if not getTaskStatus(taskId) then -- 2300
		return {success = false, message = "task not found"} -- 2303
	end -- 2303
	if not isValidWorkspacePath(targetFile) then -- 2303
		return {success = false, message = "invalid path: " .. targetFile} -- 2306
	end -- 2306
	local fullPath = resolveWorkspaceFilePath(workDir, targetFile) -- 2308
	if not fullPath then -- 2308
		return {success = false, message = "invalid path: " .. targetFile} -- 2310
	end -- 2310
	if Content:exist(fullPath) and Content:isdir(fullPath) then -- 2310
		return {success = false, message = "delete_file only supports files, not directories: " .. targetFile} -- 2313
	end -- 2313
	local isBinary = false -- 2316
	if Content:exist(fullPath) then -- 2316
		do -- 2316
			local function ____catch(e) -- 2316
				Log( -- 2322
					"Warn", -- 2322
					(("[Agent.Tools] Content.getAttr failed before deleting " .. fullPath) .. ": ") .. tostring(e) -- 2322
				) -- 2322
			end -- 2322
			local ____try, ____hasReturned = pcall(function() -- 2322
				local ____, detectedBinary = Content:getAttr(fullPath) -- 2319
				isBinary = detectedBinary == true -- 2320
			end) -- 2320
			if not ____try then -- 2320
				____catch(____hasReturned) -- 2320
			end -- 2320
		end -- 2320
	end -- 2320
	if not isBinary then -- 2320
		local result = ____exports.applyFileChanges(taskId, workDir, {{path = targetFile, op = "delete"}}, options) -- 2326
		if not result.success then -- 2326
			return result -- 2327
		end -- 2327
		return __TS__ObjectAssign({}, result, {checkpointed = true, reversible = true, binary = false}) -- 2328
	end -- 2328
	if not Content:remove(fullPath) then -- 2328
		return {success = false, message = "failed to delete binary file: " .. targetFile} -- 2337
	end -- 2337
	if not ____exports.sendWebIDEFileUpdate(fullPath, false, "") then -- 2337
		____exports.sendWebIDERefreshTree() -- 2340
	end -- 2340
	return { -- 2342
		success = true, -- 2343
		taskId = taskId, -- 2344
		checkpointed = false, -- 2345
		reversible = false, -- 2346
		binary = true, -- 2347
		message = "Binary file deleted directly without a checkpoint; this deletion cannot be rolled back." -- 2348
	} -- 2348
end -- 2296
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 2352
	if not isValidWorkDir(workDir) then -- 2352
		return {success = false, message = "invalid workDir"} -- 2353
	end -- 2353
	if checkpointId <= 0 then -- 2353
		return {success = false, message = "invalid checkpointId"} -- 2354
	end -- 2354
	local entries = getCheckpointEntries(checkpointId, true) -- 2355
	if #entries == 0 then -- 2355
		return {success = false, message = "checkpoint not found or empty"} -- 2357
	end -- 2357
	for ____, entry in ipairs(entries) do -- 2359
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2360
		if not fullPath then -- 2360
			return {success = false, message = "invalid path: " .. entry.path} -- 2362
		end -- 2362
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 2364
		if not ok then -- 2364
			Log( -- 2366
				"Error", -- 2366
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2366
			) -- 2366
			Log( -- 2367
				"Info", -- 2367
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2367
			) -- 2367
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 2368
		end -- 2368
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 2368
			Log( -- 2371
				"Error", -- 2371
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2371
			) -- 2371
			Log( -- 2372
				"Info", -- 2372
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2372
			) -- 2372
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 2373
		end -- 2373
	end -- 2373
	DB:exec( -- 2376
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 2376
		{ -- 2376
			"REVERTED", -- 2376
			now(), -- 2376
			checkpointId -- 2376
		} -- 2376
	) -- 2376
	return {success = true, checkpointId = checkpointId} -- 2377
end -- 2352
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 2380
	if not isValidWorkDir(workDir) then -- 2380
		return {success = false, message = "invalid workDir"} -- 2381
	end -- 2381
	if not getTaskStatus(taskId) then -- 2381
		return {success = false, message = "task not found"} -- 2382
	end -- 2382
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 2383
	if #checkpoints == 0 then -- 2383
		return {success = false, message = "change set not found or empty"} -- 2385
	end -- 2385
	local lastCheckpointId = 0 -- 2387
	do -- 2387
		local i = 0 -- 2388
		while i < #checkpoints do -- 2388
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 2389
			if not result.success then -- 2389
				return {success = false, message = result.message} -- 2390
			end -- 2390
			lastCheckpointId = checkpoints[i + 1].id -- 2391
			i = i + 1 -- 2388
		end -- 2388
	end -- 2388
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 2393
end -- 2380
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 2401
	return getCheckpointEntries(checkpointId, false) -- 2402
end -- 2401
function ____exports.getCheckpointDiff(checkpointId) -- 2405
	if checkpointId <= 0 then -- 2405
		return {success = false, message = "invalid checkpointId"} -- 2407
	end -- 2407
	local entries = getCheckpointEntries(checkpointId, false) -- 2409
	if #entries == 0 then -- 2409
		return {success = false, message = "checkpoint not found or empty"} -- 2411
	end -- 2411
	return { -- 2413
		success = true, -- 2414
		files = __TS__ArrayMap( -- 2415
			entries, -- 2415
			function(____, entry) return { -- 2415
				path = entry.path, -- 2416
				op = entry.op, -- 2417
				beforeExists = entry.beforeExists, -- 2418
				afterExists = entry.afterExists, -- 2419
				beforeContent = entry.beforeContent, -- 2420
				afterContent = entry.afterContent -- 2421
			} end -- 2421
		) -- 2421
	} -- 2421
end -- 2405
local function finalizeBuildResult(workDir, messages) -- 2426
	local normalized = __TS__ArrayMap( -- 2427
		messages, -- 2427
		function(____, m) return m.success and __TS__ObjectAssign( -- 2427
			{}, -- 2428
			m, -- 2428
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2428
		) or __TS__ObjectAssign( -- 2428
			{}, -- 2429
			m, -- 2429
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2429
		) end -- 2429
	) -- 2429
	local total = #normalized -- 2430
	local failed = 0 -- 2431
	do -- 2431
		local i = 0 -- 2432
		while i < #normalized do -- 2432
			if not normalized[i + 1].success then -- 2432
				failed = failed + 1 -- 2433
			end -- 2433
			i = i + 1 -- 2432
		end -- 2432
	end -- 2432
	local passed = total - failed -- 2435
	if failed > 0 then -- 2435
		return { -- 2437
			success = false, -- 2438
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 2439
			total = total, -- 2440
			passed = passed, -- 2441
			failed = failed, -- 2442
			messages = normalized -- 2443
		} -- 2443
	end -- 2443
	return { -- 2446
		success = true, -- 2447
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 2448
		total = total, -- 2449
		passed = passed, -- 2450
		failed = 0, -- 2451
		messages = normalized -- 2452
	} -- 2452
end -- 2426
function ____exports.build(req) -- 2456
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2456
		local targetRel = req.path or "" -- 2457
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2458
		if not target then -- 2458
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2458
		end -- 2458
		if not Content:exist(target) then -- 2458
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2458
		end -- 2458
		local messages = {} -- 2465
		if not Content:isdir(target) then -- 2465
			local kind = getSupportedBuildKind(target) -- 2467
			if not kind then -- 2467
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2467
			end -- 2467
			if kind == "ts" then -- 2467
				local content = Content:load(target) -- 2472
				if content == nil then -- 2472
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2472
				end -- 2472
				if isTiledEditorContent(content) then -- 2472
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2477
					return ____awaiter_resolve( -- 2477
						nil, -- 2477
						finalizeBuildResult(req.workDir, messages) -- 2478
					) -- 2478
				end -- 2478
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2478
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2478
				end -- 2478
				if not isDtsFile(target) then -- 2478
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir)) -- 2484
				end -- 2484
			else -- 2484
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2487
			end -- 2487
			Log( -- 2489
				"Info", -- 2489
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2489
			) -- 2489
			return ____awaiter_resolve( -- 2489
				nil, -- 2489
				finalizeBuildResult(req.workDir, messages) -- 2490
			) -- 2490
		end -- 2490
		local listResult = ____exports.listFiles({ -- 2492
			workDir = req.workDir, -- 2493
			path = targetRel, -- 2494
			globs = __TS__ArrayMap( -- 2495
				codeExtensions, -- 2495
				function(____, e) return "**/*" .. e end -- 2495
			), -- 2495
			maxEntries = 10000 -- 2496
		}) -- 2496
		local relFiles = listResult.success and listResult.files or ({}) -- 2499
		local tsFileData = {} -- 2500
		local buildQueue = {} -- 2501
		for ____, rel in ipairs(relFiles) do -- 2502
			do -- 2502
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2503
				local kind = getSupportedBuildKind(file) -- 2504
				if not kind then -- 2504
					goto __continue504 -- 2505
				end -- 2505
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2506
				if kind ~= "ts" then -- 2506
					goto __continue504 -- 2508
				end -- 2508
				local content = Content:load(file) -- 2510
				if content == nil then -- 2510
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2512
					goto __continue504 -- 2513
				end -- 2513
				if isTiledEditorContent(content) then -- 2513
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2516
					goto __continue504 -- 2517
				end -- 2517
				tsFileData[file] = content -- 2519
			end -- 2519
			::__continue504:: -- 2519
		end -- 2519
		do -- 2519
			local i = 0 -- 2521
			while i < #buildQueue do -- 2521
				do -- 2521
					local ____buildQueue_index_40 = buildQueue[i + 1] -- 2522
					local file = ____buildQueue_index_40.file -- 2522
					local kind = ____buildQueue_index_40.kind -- 2522
					if kind == "ts" then -- 2522
						local content = tsFileData[file] -- 2524
						if content == nil or isDtsFile(file) then -- 2524
							goto __continue511 -- 2526
						end -- 2526
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2526
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2529
							goto __continue511 -- 2530
						end -- 2530
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir)) -- 2532
						goto __continue511 -- 2533
					end -- 2533
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2535
				end -- 2535
				::__continue511:: -- 2535
				i = i + 1 -- 2521
			end -- 2521
		end -- 2521
		if #messages == 0 then -- 2521
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2538
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2538
		end -- 2538
		Log( -- 2541
			"Info", -- 2541
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2541
		) -- 2541
		return ____awaiter_resolve( -- 2541
			nil, -- 2541
			finalizeBuildResult(req.workDir, messages) -- 2542
		) -- 2542
	end) -- 2542
end -- 2456
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2545
local EXECUTE_COMMAND_ERROR_MAX = 4000 -- 2546
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 2547
local agentEntryRuntimeOwner = "" -- 2548
local function truncateCommandOutput(output) -- 2550
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2550
		return output -- 2551
	end -- 2551
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2552
end -- 2550
local function truncateCommandError(message) -- 2555
	if #message <= EXECUTE_COMMAND_ERROR_MAX then -- 2555
		return message -- 2556
	end -- 2556
	return __TS__StringSlice(message, 0, EXECUTE_COMMAND_ERROR_MAX) .. "\n... error message truncated ..." -- 2557
end -- 2555
local function executeLuaCommand(req) -- 2560
	local code = __TS__StringTrim(req.code or "") -- 2568
	if code == "" then -- 2568
		return __TS__Promise.resolve({ -- 2570
			success = false, -- 2570
			mode = "lua", -- 2570
			output = "", -- 2570
			message = "missing code", -- 2570
			phase = "validate" -- 2570
		}) -- 2570
	end -- 2570
	local output = {} -- 2572
	local entry = require("Script.Dev.Entry") -- 2573
	local ownsEntryRuntime = false -- 2574
	local entryObjectBaseline = 0 -- 2575
	local entryLuaRefBaseline = 0 -- 2576
	local function acquireEntryRuntime() -- 2577
		if agentEntryRuntimeOwner ~= "" and agentEntryRuntimeOwner ~= req.operationId then -- 2577
			error("Dora entry runtime is busy with another Agent command") -- 2579
		end -- 2579
		agentEntryRuntimeOwner = req.operationId -- 2581
		ownsEntryRuntime = true -- 2582
	end -- 2577
	local function stopOwnedEntry() -- 2584
		if not ownsEntryRuntime then -- 2584
			return nil -- 2585
		end -- 2585
		local cleanupError -- 2586
		do -- 2586
			local function ____catch(e) -- 2586
				cleanupError = "failed to stop Agent test entry: " .. tostring(e) -- 2590
			end -- 2590
			local ____try, ____hasReturned = pcall(function() -- 2590
				entry.stop() -- 2588
			end) -- 2588
			if not ____try then -- 2588
				____catch(____hasReturned) -- 2588
			end -- 2588
		end -- 2588
		ownsEntryRuntime = false -- 2592
		if agentEntryRuntimeOwner == req.operationId then -- 2592
			agentEntryRuntimeOwner = "" -- 2594
		end -- 2594
		return cleanupError -- 2596
	end -- 2584
	local function startEntryWatchdog() -- 2598
		entryObjectBaseline = Dora.Object.count -- 2599
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 2600
	end -- 2598
	local function checkEntryWatchdog() -- 2602
		if not ownsEntryRuntime then -- 2602
			return nil -- 2603
		end -- 2603
		local objectCount = Dora.Object.count -- 2604
		local luaRefCount = Dora.Object.luaRefCount -- 2605
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 2606
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 2607
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 2608
		if not exceededTotal then -- 2608
			return nil -- 2611
		end -- 2611
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 2612
	end -- 2602
	local function normalizeEntryFile(value) -- 2616
		if not value or type(value) ~= "table" then -- 2616
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 2618
		end -- 2618
		local descriptor = value -- 2620
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 2621
		if relativeFile == "" then -- 2621
			relativeFile = "init" -- 2622
		end -- 2622
		if not isValidWorkspacePath(relativeFile) then -- 2622
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 2624
		end -- 2624
		local fileName = Path(req.workDir, relativeFile) -- 2626
		local ext = Path:getExt(fileName) -- 2627
		if ext ~= "" then -- 2627
			fileName = Path:replaceExt(fileName, "") -- 2628
		end -- 2628
		local luaFile = Path:replaceExt(fileName, "lua") -- 2629
		if not Content:exist(luaFile) then -- 2629
			error("Agent test entry was not built: " .. luaFile) -- 2631
		end -- 2631
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 2633
		return { -- 2634
			fileName = fileName, -- 2635
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 2636
		} -- 2636
	end -- 2616
	local function capturePrint(...) -- 2639
		local values = {...} -- 2639
		local parts = {} -- 2640
		do -- 2640
			local i = 0 -- 2641
			while i < #values do -- 2641
				parts[#parts + 1] = tostring(values[i + 1]) -- 2642
				i = i + 1 -- 2641
			end -- 2641
		end -- 2641
		output[#output + 1] = table.concat(parts, "\t") -- 2644
	end -- 2639
	local env = setmetatable( -- 2646
		{ -- 2646
			projectDir = req.workDir, -- 2647
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 2648
				if type(moduleNameValue) ~= "string" then -- 2648
					error("requireProjectModule expects a project module name string") -- 2650
				end -- 2650
				local moduleName = __TS__StringTrim(moduleNameValue) -- 2652
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 2652
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 2654
				end -- 2654
				local reloadModules = {moduleName} -- 2656
				if reloadModulesValue ~= nil then -- 2656
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 2656
						error("requireProjectModule reloadModules must be an array of module names") -- 2659
					end -- 2659
					local items = reloadModulesValue -- 2661
					do -- 2661
						local i = 0 -- 2662
						while i < #items do -- 2662
							local item = items[i + 1] -- 2663
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 2663
								error("requireProjectModule reloadModules contains an invalid module name") -- 2665
							end -- 2665
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 2665
								reloadModules[#reloadModules + 1] = item -- 2667
							end -- 2667
							i = i + 1 -- 2662
						end -- 2662
					end -- 2662
				end -- 2662
				local luaPackage = _G.package -- 2670
				local previousPath = luaPackage.path -- 2674
				local previousSearchPaths = Content.searchPaths -- 2675
				local scopedSearchPaths = {req.workDir} -- 2676
				do -- 2676
					local i = 0 -- 2677
					while i < #previousSearchPaths do -- 2677
						local searchPath = previousSearchPaths[i + 1] -- 2678
						if searchPath ~= req.workDir then -- 2678
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 2679
						end -- 2679
						i = i + 1 -- 2677
					end -- 2677
				end -- 2677
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 2681
				Content.searchPaths = scopedSearchPaths -- 2682
				do -- 2682
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2682
						do -- 2682
							local i = 0 -- 2684
							while i < #reloadModules do -- 2684
								local reloadName = reloadModules[i + 1] -- 2685
								luaPackage.loaded[reloadName] = nil -- 2686
								luaPackage.loaded[table.concat( -- 2687
									__TS__StringSplit(reloadName, "/"), -- 2687
									"." -- 2687
								)] = nil -- 2687
								luaPackage.loaded[table.concat( -- 2688
									__TS__StringSplit(reloadName, "."), -- 2688
									"/" -- 2688
								)] = nil -- 2688
								i = i + 1 -- 2684
							end -- 2684
						end -- 2684
						return true, require(table.concat( -- 2690
							__TS__StringSplit(moduleName, "/"), -- 2690
							"." -- 2690
						)) -- 2690
					end) -- 2690
					do -- 2690
						Content.searchPaths = previousSearchPaths -- 2692
						luaPackage.path = previousPath -- 2693
					end -- 2693
					if not ____try then -- 2693
						error(____hasReturned, 0) -- 2693
					end -- 2693
					if ____try and ____hasReturned then -- 2693
						return ____returnValue -- 2683
					end -- 2683
				end -- 2683
			end, -- 2648
			print = capturePrint, -- 2696
			refreshTree = function(path) -- 2697
				if path == nil then -- 2697
					return refreshProjectTree(req.workDir) -- 2699
				end -- 2699
				if type(path) ~= "string" then -- 2699
					error("refreshTree expects a project-relative file path string or no argument") -- 2702
				end -- 2702
				return refreshProjectTree(req.workDir, path) -- 2704
			end, -- 2697
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 2706
			enterEntryAsync = function(value) -- 2707
				local normalized = normalizeEntryFile(value) -- 2708
				acquireEntryRuntime() -- 2709
				entry.allClear() -- 2710
				startEntryWatchdog() -- 2711
				local success, message = entry.enterEntryAsync({ -- 2712
					entryName = normalized.entryName, -- 2713
					fileName = normalized.fileName, -- 2714
					workDir = req.workDir, -- 2715
					projectRoot = req.workDir, -- 2716
					runKind = "agent_test" -- 2717
				}) -- 2717
				return success, message -- 2719
			end, -- 2707
			stopEntry = function() -- 2721
				if not ownsEntryRuntime then -- 2721
					return false -- 2722
				end -- 2722
				return entry.stop() -- 2723
			end, -- 2721
			reportProgress = function(value, callbackValue) -- 2725
				local ____callbackValue_41 = callbackValue -- 2726
				if ____callbackValue_41 == nil then -- 2726
					____callbackValue_41 = value -- 2726
				end -- 2726
				local actualValue = ____callbackValue_41 -- 2726
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 2726
					return -- 2727
				end -- 2727
				local progress = actualValue -- 2728
				local amount = type(progress.progress) == "number" and math.min( -- 2729
					1, -- 2730
					math.max(0, progress.progress) -- 2730
				) or nil -- 2730
				req:onProgress({ -- 2732
					state = "running", -- 2733
					mode = "lua", -- 2734
					operationId = req.operationId, -- 2735
					progress = amount, -- 2736
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 2737
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 2738
				}) -- 2738
			end -- 2725
		}, -- 2725
		{__index = Dora} -- 2741
	) -- 2741
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 2744
	if not fn then -- 2744
		return __TS__Promise.resolve({ -- 2746
			success = false, -- 2747
			mode = "lua", -- 2748
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2749
			message = truncateCommandError(toStr(compileErr)), -- 2750
			phase = "compile" -- 2751
		}) -- 2751
	end -- 2751
	return __TS__New( -- 2754
		__TS__Promise, -- 2754
		function(____, resolve) -- 2754
			local settled = false -- 2755
			local commandRoutine -- 2756
			local startedAt = App.runningTime -- 2757
			local onProgress = req.onProgress -- 2758
			local isCancelled = req.isCancelled -- 2759
			local function finish(result) -- 2760
				if settled then -- 2760
					return -- 2761
				end -- 2761
				settled = true -- 2762
				local cleanupError -- 2763
				if not result.success and (result.interrupted == true or result.phase == "timeout") then -- 2763
					do -- 2763
						local function ____catch(e) -- 2763
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 2768
						end -- 2768
						local ____try, ____hasReturned = pcall(function() -- 2768
							entry.allClear() -- 2766
						end) -- 2766
						if not ____try then -- 2766
							____catch(____hasReturned) -- 2766
						end -- 2766
					end -- 2766
				end -- 2766
				local entryCleanupError = stopOwnedEntry() -- 2771
				if cleanupError == nil then -- 2771
					cleanupError = entryCleanupError -- 2772
				end -- 2772
				if not result.success and cleanupError ~= nil then -- 2772
					result.cleanupError = cleanupError -- 2774
				elseif result.success and cleanupError ~= nil then -- 2774
					resolve(nil, { -- 2776
						success = false, -- 2777
						mode = "lua", -- 2778
						output = result.output, -- 2779
						message = cleanupError, -- 2780
						phase = "execute", -- 2781
						cleanupError = cleanupError -- 2782
					}) -- 2782
					return -- 2784
				end -- 2784
				resolve(nil, result) -- 2786
			end -- 2760
			if onProgress then -- 2760
				onProgress(nil, { -- 2789
					state = "pending", -- 2790
					mode = "lua", -- 2791
					operationId = req.operationId, -- 2792
					stage = "lua", -- 2793
					message = "Lua command pending" -- 2794
				}) -- 2794
			end -- 2794
			commandRoutine = once(function() -- 2797
				if settled then -- 2797
					return -- 2798
				end -- 2798
				if onProgress then -- 2798
					onProgress(nil, { -- 2800
						state = "running", -- 2801
						mode = "lua", -- 2802
						operationId = req.operationId, -- 2803
						stage = "lua", -- 2804
						message = "Lua command running" -- 2805
					}) -- 2805
				end -- 2805
				local previousGlobalPrint = _G.print -- 2808
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 2809
				local frameTimedOut = false -- 2810
				local watchdogMessage -- 2810
				_G.print = capturePrint -- 2811
				debug.sethook( -- 2812
					function() -- 2812
						if watchdogMessage == nil then -- 2812
							watchdogMessage = checkEntryWatchdog() -- 2813
						end -- 2813
						if watchdogMessage ~= nil then -- 2813
							error(watchdogMessage) -- 2814
						end -- 2814
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 2814
							frameTimedOut = true -- 2816
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 2817
						end -- 2817
					end, -- 2812
					"", -- 2819
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 2819
				) -- 2819
				local ok, runtimeErr = pcall(fn) -- 2820
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 2820
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 2822
				else -- 2822
					debug.sethook() -- 2828
				end -- 2828
				_G.print = previousGlobalPrint -- 2830
				if not ok then -- 2830
					local ____truncateCommandOutput_result_43 = truncateCommandOutput(table.concat(output, "\n")) -- 2835
					local ____temp_44 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 2836
					local ____temp_45 = frameTimedOut and "timeout" or "execute" -- 2837
					local ____temp_42 -- 2838
					if watchdogMessage ~= nil or frameTimedOut then -- 2838
						____temp_42 = true -- 2838
					else -- 2838
						____temp_42 = nil -- 2838
					end -- 2838
					finish({ -- 2832
						success = false, -- 2833
						mode = "lua", -- 2834
						output = ____truncateCommandOutput_result_43, -- 2835
						message = ____temp_44, -- 2836
						phase = ____temp_45, -- 2837
						interrupted = ____temp_42 -- 2838
					}) -- 2838
					return -- 2840
				end -- 2840
				finish({ -- 2842
					success = true, -- 2842
					mode = "lua", -- 2842
					output = truncateCommandOutput(table.concat(output, "\n")) -- 2842
				}) -- 2842
			end) -- 2797
			Director.systemScheduler:schedule(function() -- 2844
				if settled then -- 2844
					return true -- 2845
				end -- 2845
				local watchdogMessage = checkEntryWatchdog() -- 2846
				if watchdogMessage ~= nil then -- 2846
					finish({ -- 2848
						success = false, -- 2849
						mode = "lua", -- 2850
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2851
						message = watchdogMessage, -- 2852
						phase = "execute", -- 2853
						interrupted = true -- 2854
					}) -- 2854
					return true -- 2856
				end -- 2856
				if isCancelled and isCancelled(nil) then -- 2856
					finish({ -- 2859
						success = false, -- 2860
						mode = "lua", -- 2861
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2862
						message = "Lua command canceled", -- 2863
						phase = "execute", -- 2864
						interrupted = true -- 2865
					}) -- 2865
					return true -- 2867
				end -- 2867
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 2867
					finish({ -- 2870
						success = false, -- 2871
						mode = "lua", -- 2872
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2873
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 2874
						phase = "timeout" -- 2875
					}) -- 2875
					return true -- 2877
				end -- 2877
				if commandRoutine == nil then -- 2877
					finish({ -- 2880
						success = false, -- 2881
						mode = "lua", -- 2882
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2883
						message = "Lua command coroutine is unavailable", -- 2884
						phase = "execute" -- 2885
					}) -- 2885
					return true -- 2887
				end -- 2887
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 2889
				if not resumeSuccess then -- 2889
					finish({ -- 2891
						success = false, -- 2892
						mode = "lua", -- 2893
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2894
						message = truncateCommandError(toStr(resumeResult)), -- 2895
						phase = "execute" -- 2896
					}) -- 2896
					return true -- 2898
				end -- 2898
				return settled or resumeResult == true -- 2900
			end) -- 2844
		end -- 2754
	) -- 2754
end -- 2560
local function formatGitStatusOutput(status) -- 2905
	if not status then -- 2905
		return "" -- 2906
	end -- 2906
	local lines = {} -- 2907
	local state = toStr(status.state) -- 2908
	local kind = toStr(status.kind) -- 2909
	local message = toStr(status.message) -- 2910
	local errorMessage = toStr(status.error) -- 2911
	if kind ~= "" or state ~= "" then -- 2911
		lines[#lines + 1] = table.concat( -- 2913
			__TS__ArrayFilter( -- 2913
				{kind, state}, -- 2913
				function(____, item) return item ~= "" end -- 2913
			), -- 2913
			": " -- 2913
		) -- 2913
	end -- 2913
	if message ~= "" then -- 2913
		lines[#lines + 1] = message -- 2915
	end -- 2915
	if errorMessage ~= "" then -- 2915
		lines[#lines + 1] = errorMessage -- 2916
	end -- 2916
	local data = status.data -- 2917
	if data ~= nil then -- 2917
		local dataText = encodeJSON(data) -- 2919
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 2920
	end -- 2920
	return truncateCommandOutput(table.concat(lines, "\n")) -- 2922
end -- 2905
local function emitGitProgress(mode, operationId, onProgress, status) -- 2925
	if not onProgress then -- 2925
		return -- 2931
	end -- 2931
	local progress = type(status.progress) == "number" and status.progress or nil -- 2932
	local kind = toStr(status.kind) -- 2933
	local message = toStr(status.message) -- 2934
	local state = toStr(status.state) -- 2935
	local jobId = type(status.id) == "number" and status.id or nil -- 2936
	onProgress({ -- 2937
		state = "running", -- 2938
		mode = mode, -- 2939
		operationId = operationId, -- 2940
		stage = kind ~= "" and kind or "git", -- 2941
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 2942
		progress = progress, -- 2943
		jobId = jobId, -- 2944
		gitState = state ~= "" and state or nil, -- 2945
		gitKind = kind ~= "" and kind or nil -- 2946
	}) -- 2946
end -- 2925
local function cloneGitToTarget(req) -- 2950
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2950
		local parsed = parseGitCloneCommand(req.command) -- 2958
		if parsed == nil then -- 2958
			return ____awaiter_resolve(nil, nil) -- 2958
		end -- 2958
		if not parsed.success then -- 2958
			return ____awaiter_resolve(nil, { -- 2958
				success = false, -- 2961
				mode = "git", -- 2961
				output = "", -- 2961
				message = parsed.message, -- 2961
				phase = "validate" -- 2961
			}) -- 2961
		end -- 2961
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 2963
		if not target then -- 2963
			return ____awaiter_resolve(nil, { -- 2963
				success = false, -- 2965
				mode = "git", -- 2965
				output = "", -- 2965
				message = "invalid clone target path", -- 2965
				phase = "validate" -- 2965
			}) -- 2965
		end -- 2965
		if Content:exist(target) then -- 2965
			return ____awaiter_resolve(nil, { -- 2965
				success = false, -- 2968
				mode = "git", -- 2968
				output = "", -- 2968
				message = "target already exists", -- 2968
				phase = "validate" -- 2968
			}) -- 2968
		end -- 2968
		local targetParent = Path:getPath(target) -- 2970
		if not ensureDirPath(targetParent) then -- 2970
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 2970
		end -- 2970
		local tempRoot = getAgentDownloadTempRoot() -- 2974
		if not ensureDirPath(tempRoot) then -- 2974
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 2974
		end -- 2974
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 2978
		Content:remove(tempPath) -- 2979
		local depth = parsed.depth or "1" -- 2980
		local ____array_46 = __TS__SparseArrayNew( -- 2980
			"clone", -- 2982
			quoteGitArg(parsed.url), -- 2983
			quoteGitArg(Path:getFilename(tempPath)), -- 2984
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 2985
				"-b", -- 2985
				quoteGitArg(parsed.ref) -- 2985
			}) or ({})) -- 2985
		) -- 2985
		__TS__SparseArrayPush( -- 2985
			____array_46, -- 2985
			table.unpack(depth ~= "" and ({ -- 2986
				"--depth",
				quoteGitArg(depth) -- 2986
			}) or ({})) -- 2986
		) -- 2986
		local command = table.concat( -- 2981
			{__TS__SparseArraySpread(____array_46)}, -- 2981
			" " -- 2987
		) -- 2987
		local ____this_48 -- 2987
		____this_48 = req -- 2988
		local ____opt_47 = ____this_48.onProgress -- 2988
		if ____opt_47 ~= nil then -- 2988
			____opt_47(____this_48, { -- 2988
				state = "pending", -- 2989
				mode = "git", -- 2990
				operationId = req.operationId, -- 2991
				stage = "clone", -- 2992
				message = "clone pending", -- 2993
				progress = 0 -- 2994
			}) -- 2994
		end -- 2994
		local gitRes = __TS__Await(runGitAndWait( -- 2996
			tempRoot, -- 2997
			command, -- 2998
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2999
			function() -- 3000
				local ____this_50 -- 3000
				____this_50 = req -- 3000
				local ____opt_49 = ____this_50.isCancelled -- 3000
				return (____opt_49 and ____opt_49(____this_50)) == true -- 3000
			end, -- 3000
			req.timeoutSeconds -- 3001
		)) -- 3001
		if not gitRes.success then -- 3001
			local cleanupError = cleanupPath(tempPath) -- 3004
			local ____formatGitStatusOutput_result_54 = formatGitStatusOutput(gitRes.status) -- 3008
			local ____temp_55 = gitRes.message or "git clone failed" -- 3009
			local ____gitRes_interrupted_53 = gitRes.interrupted -- 3010
			if not ____gitRes_interrupted_53 then -- 3010
				local ____this_52 -- 3010
				____this_52 = req -- 3010
				local ____opt_51 = ____this_52.isCancelled -- 3010
				____gitRes_interrupted_53 = (____opt_51 and ____opt_51(____this_52)) == true -- 3010
			end -- 3010
			return ____awaiter_resolve(nil, { -- 3010
				success = false, -- 3006
				mode = "git", -- 3007
				output = ____formatGitStatusOutput_result_54, -- 3008
				message = ____temp_55, -- 3009
				interrupted = ____gitRes_interrupted_53, -- 3010
				cleanupError = cleanupError -- 3011
			}) -- 3011
		end -- 3011
		if not Content:move(tempPath, target) then -- 3011
			local cleanupError = cleanupPath(tempPath) -- 3015
			return ____awaiter_resolve( -- 3015
				nil, -- 3015
				{ -- 3016
					success = false, -- 3016
					mode = "git", -- 3016
					output = formatGitStatusOutput(gitRes.status), -- 3016
					message = "failed to move cloned repository into target path", -- 3016
					cleanupError = cleanupError -- 3016
				} -- 3016
			) -- 3016
		end -- 3016
		if not refreshProjectTree(req.workDir) then -- 3016
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 3019
		end -- 3019
		local commit = getGitHeadCommit(target) -- 3021
		local output = table.concat( -- 3022
			__TS__ArrayFilter( -- 3022
				{ -- 3022
					formatGitStatusOutput(gitRes.status), -- 3023
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 3023
					commit ~= nil and "commit " .. commit or "" -- 3025
				}, -- 3025
				function(____, item) return item ~= "" end -- 3026
			), -- 3026
			"\n" -- 3026
		) -- 3026
		return ____awaiter_resolve( -- 3026
			nil, -- 3026
			{ -- 3027
				success = true, -- 3027
				mode = "git", -- 3027
				output = truncateCommandOutput(output) -- 3027
			} -- 3027
		) -- 3027
	end) -- 3027
end -- 2950
local function loadGitProfile() -- 3030
	local rows -- 3031
	do -- 3031
		local function ____catch() -- 3031
			return true, nil -- 3035
		end -- 3035
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 3035
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 3033
		end) -- 3033
		if not ____try then -- 3033
			____hasReturned, ____returnValue = ____catch() -- 3033
		end -- 3033
		if ____hasReturned then -- 3033
			return ____returnValue -- 3032
		end -- 3032
	end -- 3032
	if not rows or not rows[1] then -- 3032
		return nil -- 3037
	end -- 3037
	local name = toStr(rows[1][1]) -- 3038
	local email = toStr(rows[1][2]) -- 3039
	if name == "" and email == "" then -- 3039
		return nil -- 3040
	end -- 3040
	return {name = name, email = email} -- 3041
end -- 3030
local function applyGitProfileToCommit(command) -- 3044
	local args = shellSplit(command) -- 3045
	if args[1] ~= "commit" then -- 3045
		return command -- 3046
	end -- 3046
	local hasName = false -- 3047
	local hasEmail = false -- 3048
	for ____, arg in ipairs(args) do -- 3049
		if arg == "--author-name" then
			hasName = true -- 3050
		end -- 3050
		if arg == "--author-email" then
			hasEmail = true -- 3051
		end -- 3051
	end -- 3051
	if hasName and hasEmail then -- 3051
		return command -- 3053
	end -- 3053
	local profile = loadGitProfile() -- 3054
	if not profile then -- 3054
		return command -- 3055
	end -- 3055
	local additions = {} -- 3056
	if not hasName and profile.name ~= "" then -- 3056
		__TS__ArrayPush( -- 3058
			additions, -- 3058
			"--author-name",
			quoteGitArg(profile.name) -- 3058
		) -- 3058
	end -- 3058
	if not hasEmail and profile.email ~= "" then -- 3058
		__TS__ArrayPush( -- 3061
			additions, -- 3061
			"--author-email",
			quoteGitArg(profile.email) -- 3061
		) -- 3061
	end -- 3061
	if #additions == 0 then -- 3061
		return command -- 3063
	end -- 3063
	return (command .. " ") .. table.concat(additions, " ") -- 3064
end -- 3044
local function executeGitCommand(req) -- 3067
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3067
		local command = normalizeGitCommand(req.command or "") -- 3076
		if command == "" then -- 3076
			return ____awaiter_resolve(nil, { -- 3076
				success = false, -- 3078
				mode = "git", -- 3078
				output = "", -- 3078
				message = "missing command", -- 3078
				phase = "validate" -- 3078
			}) -- 3078
		end -- 3078
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 3080
			workDir = req.workDir, -- 3081
			command = command, -- 3082
			operationId = req.operationId, -- 3083
			timeoutSeconds = req.timeoutSeconds, -- 3084
			onProgress = req.onProgress, -- 3085
			isCancelled = req.isCancelled -- 3086
		})) -- 3086
		if cloneResult ~= nil then -- 3086
			return ____awaiter_resolve(nil, cloneResult) -- 3086
		end -- 3086
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 3089
		if not cwd.success then -- 3089
			return ____awaiter_resolve(nil, { -- 3089
				success = false, -- 3091
				mode = "git", -- 3091
				output = "", -- 3091
				cwd = req.cwd, -- 3091
				message = cwd.message, -- 3091
				phase = "validate" -- 3091
			}) -- 3091
		end -- 3091
		command = applyGitProfileToCommit(command) -- 3093
		local ____this_57 -- 3093
		____this_57 = req -- 3094
		local ____opt_56 = ____this_57.onProgress -- 3094
		if ____opt_56 ~= nil then -- 3094
			____opt_56(____this_57, { -- 3094
				state = "pending", -- 3095
				mode = "git", -- 3096
				operationId = req.operationId, -- 3097
				stage = "git", -- 3098
				message = "git command pending", -- 3099
				progress = 0 -- 3100
			}) -- 3100
		end -- 3100
		local gitRes = __TS__Await(runGitAndWait( -- 3102
			cwd.path, -- 3103
			command, -- 3104
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 3105
			function() -- 3106
				local ____this_59 -- 3106
				____this_59 = req -- 3106
				local ____opt_58 = ____this_59.isCancelled -- 3106
				return (____opt_58 and ____opt_58(____this_59)) == true -- 3106
			end, -- 3106
			req.timeoutSeconds -- 3107
		)) -- 3107
		local output = formatGitStatusOutput(gitRes.status) -- 3109
		if not gitRes.success then -- 3109
			local ____output_63 = output -- 3114
			local ____cwd_relative_64 = cwd.relative -- 3115
			local ____temp_65 = gitRes.message or "git command failed" -- 3116
			local ____gitRes_interrupted_62 = gitRes.interrupted -- 3117
			if not ____gitRes_interrupted_62 then -- 3117
				local ____this_61 -- 3117
				____this_61 = req -- 3117
				local ____opt_60 = ____this_61.isCancelled -- 3117
				____gitRes_interrupted_62 = (____opt_60 and ____opt_60(____this_61)) == true -- 3117
			end -- 3117
			return ____awaiter_resolve(nil, { -- 3117
				success = false, -- 3112
				mode = "git", -- 3113
				output = ____output_63, -- 3114
				cwd = ____cwd_relative_64, -- 3115
				message = ____temp_65, -- 3116
				interrupted = ____gitRes_interrupted_62 -- 3117
			}) -- 3117
		end -- 3117
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 3117
	end) -- 3117
end -- 3067
function ____exports.executeCommand(req) -- 3123
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3123
		local mode = req.mode -- 3133
		if mode ~= "lua" and mode ~= "git" then -- 3133
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 3133
		end -- 3133
		if mode == "lua" then -- 3133
			return ____awaiter_resolve( -- 3133
				nil, -- 3133
				executeLuaCommand({ -- 3138
					workDir = req.workDir, -- 3139
					code = req.code or "", -- 3140
					timeoutSeconds = math.max( -- 3141
						1, -- 3141
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 3141
					), -- 3141
					operationId = createOperationId(), -- 3142
					onProgress = req.onProgress, -- 3143
					isCancelled = req.isCancelled -- 3144
				}) -- 3144
			) -- 3144
		end -- 3144
		local operationId = createOperationId() -- 3147
		return ____awaiter_resolve( -- 3147
			nil, -- 3147
			executeGitCommand({ -- 3148
				workDir = req.workDir, -- 3149
				command = req.command or "", -- 3150
				cwd = req.cwd, -- 3151
				timeoutSeconds = math.max( -- 3152
					1, -- 3152
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 3152
				), -- 3152
				operationId = operationId, -- 3153
				onProgress = req.onProgress, -- 3154
				isCancelled = req.isCancelled -- 3155
			}) -- 3155
		) -- 3155
	end) -- 3155
end -- 3123
function ____exports.fetchUrl(req) -- 3159
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3159
		local mode = "download" -- 3166
		local url = __TS__StringTrim(req.url or "") -- 3167
		local targetRel = __TS__StringTrim(req.target or "") -- 3168
		if not isHttpUrl(url) then -- 3168
			return ____awaiter_resolve(nil, { -- 3168
				success = false, -- 3170
				state = "failed", -- 3170
				mode = mode, -- 3170
				target = targetRel, -- 3170
				message = "fetch_url only supports http:// and https:// URLs" -- 3170
			}) -- 3170
		end -- 3170
		if targetRel == "" then -- 3170
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 3170
		end -- 3170
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 3175
		if not target then -- 3175
			return ____awaiter_resolve(nil, { -- 3175
				success = false, -- 3177
				state = "failed", -- 3177
				mode = mode, -- 3177
				target = targetRel, -- 3177
				message = "invalid target path" -- 3177
			}) -- 3177
		end -- 3177
		if Content:exist(target) then -- 3177
			return ____awaiter_resolve(nil, { -- 3177
				success = false, -- 3180
				state = "failed", -- 3180
				mode = mode, -- 3180
				target = targetRel, -- 3180
				message = "target already exists" -- 3180
			}) -- 3180
		end -- 3180
		local operationId = createOperationId() -- 3182
		local tempRoot = getAgentDownloadTempRoot() -- 3183
		if not ensureDirPath(tempRoot) then -- 3183
			return ____awaiter_resolve(nil, { -- 3183
				success = false, -- 3185
				state = "failed", -- 3185
				mode = mode, -- 3185
				target = targetRel, -- 3185
				message = "failed to create agent download temp directory" -- 3185
			}) -- 3185
		end -- 3185
		local tempPath = Path(tempRoot, operationId .. ".download") -- 3187
		Content:remove(tempPath) -- 3188
		local function emitProgress(progress) -- 3189
			if not req.onProgress then -- 3189
				return -- 3190
			end -- 3190
			req:onProgress(__TS__ObjectAssign({ -- 3191
				state = "running", -- 3192
				mode = mode, -- 3193
				operationId = operationId, -- 3194
				target = targetRel, -- 3195
				tempPath = tempPath -- 3196
			}, progress)) -- 3196
		end -- 3189
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 3200
		local function interrupted() -- 3205
			local ____this_67 -- 3205
			____this_67 = req -- 3205
			local ____opt_66 = ____this_67.isCancelled -- 3205
			return (____opt_66 and ____opt_66(____this_67)) == true -- 3205
		end -- 3205
		if not ensureDirForFile(tempPath) then -- 3205
			return ____awaiter_resolve(nil, { -- 3205
				success = false, -- 3207
				state = "failed", -- 3207
				mode = mode, -- 3207
				target = targetRel, -- 3207
				message = "failed to create temporary file directory" -- 3207
			}) -- 3207
		end -- 3207
		local downloadRes = __TS__Await(downloadFile({ -- 3209
			url = url, -- 3210
			tempPath = tempPath, -- 3211
			timeout = 600, -- 3212
			isCancelled = interrupted, -- 3213
			onProgress = function(____, current, total) -- 3214
				local totalNumber = type(total) == "number" and total or 0 -- 3215
				emitProgress({ -- 3216
					stage = "download", -- 3217
					message = "downloading", -- 3218
					current = current, -- 3219
					total = total, -- 3220
					progress = totalNumber > 0 and current / totalNumber or nil -- 3221
				}) -- 3221
			end -- 3214
		})) -- 3214
		if not downloadRes.success then -- 3214
			local cleanupError = cleanupPath(tempPath) -- 3226
			return ____awaiter_resolve( -- 3226
				nil, -- 3226
				{ -- 3227
					success = false, -- 3228
					state = "failed", -- 3229
					mode = mode, -- 3230
					target = targetRel, -- 3231
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 3232
					interrupted = downloadRes.interrupted or interrupted(), -- 3233
					cleanupError = cleanupError -- 3234
				} -- 3234
			) -- 3234
		end -- 3234
		if not ensureDirForFile(target) then -- 3234
			local cleanupError = cleanupPath(tempPath) -- 3238
			return ____awaiter_resolve(nil, { -- 3238
				success = false, -- 3239
				state = "failed", -- 3239
				mode = mode, -- 3239
				target = targetRel, -- 3239
				message = "failed to create target directory", -- 3239
				cleanupError = cleanupError -- 3239
			}) -- 3239
		end -- 3239
		if not Content:move(tempPath, target) then -- 3239
			local cleanupError = cleanupPath(tempPath) -- 3242
			return ____awaiter_resolve(nil, { -- 3242
				success = false, -- 3243
				state = "failed", -- 3243
				mode = mode, -- 3243
				target = targetRel, -- 3243
				message = "failed to move downloaded file into target path", -- 3243
				cleanupError = cleanupError -- 3243
			}) -- 3243
		end -- 3243
		local bytesWritten = downloadRes.bytesWritten -- 3245
		local ____try = __TS__AsyncAwaiter(function() -- 3245
			local size = Content:getAttr(target) -- 3247
			if bytesWritten == nil or bytesWritten <= 0 then -- 3247
				bytesWritten = type(size) == "number" and size or nil -- 3249
			end -- 3249
		end) -- 3249
		____try = ____try.catch( -- 3249
			____try, -- 3249
			function(____, _) -- 3249
				return __TS__AsyncAwaiter(function() -- 3249
				end) -- 3249
			end -- 3249
		) -- 3249
		__TS__Await(____try) -- 3246
		if bytesWritten == nil or bytesWritten <= 0 then -- 3246
			local ____try = __TS__AsyncAwaiter(function() -- 3246
				local loaded = Content:load(target) -- 3256
				if type(loaded) == "string" then -- 3256
					bytesWritten = #loaded -- 3258
				end -- 3258
			end) -- 3258
			____try = ____try.catch( -- 3258
				____try, -- 3258
				function(____, _) -- 3258
					return __TS__AsyncAwaiter(function() -- 3258
					end) -- 3258
				end -- 3258
			) -- 3258
			__TS__Await(____try) -- 3255
		end -- 3255
		if not syncDownloadedFileToWebIDE(target) then -- 3255
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 3265
		end -- 3265
		return ____awaiter_resolve(nil, { -- 3265
			success = true, -- 3267
			state = "done", -- 3267
			mode = mode, -- 3267
			target = targetRel, -- 3267
			bytesWritten = bytesWritten -- 3267
		}) -- 3267
	end) -- 3267
end -- 3159
return ____exports -- 3159