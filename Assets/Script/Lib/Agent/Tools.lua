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
			end -- 2721
		}, -- 2721
		{__index = Dora} -- 2725
	) -- 2725
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 2728
	if not fn then -- 2728
		return __TS__Promise.resolve({ -- 2730
			success = false, -- 2731
			mode = "lua", -- 2732
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2733
			message = truncateCommandError(toStr(compileErr)), -- 2734
			phase = "compile" -- 2735
		}) -- 2735
	end -- 2735
	return __TS__New( -- 2738
		__TS__Promise, -- 2738
		function(____, resolve) -- 2738
			local settled = false -- 2739
			local startedAt = App.runningTime -- 2740
			local onProgress = req.onProgress -- 2741
			local isCancelled = req.isCancelled -- 2742
			local function finish(result) -- 2743
				if settled then -- 2743
					return -- 2744
				end -- 2744
				settled = true -- 2745
				local cleanupError = stopOwnedEntry() -- 2746
				if not result.success and cleanupError ~= nil then -- 2746
					result.cleanupError = cleanupError -- 2748
				elseif result.success and cleanupError ~= nil then -- 2748
					resolve(nil, { -- 2750
						success = false, -- 2751
						mode = "lua", -- 2752
						output = result.output, -- 2753
						message = cleanupError, -- 2754
						phase = "execute", -- 2755
						cleanupError = cleanupError -- 2756
					}) -- 2756
					return -- 2758
				end -- 2758
				resolve(nil, result) -- 2760
			end -- 2743
			if onProgress then -- 2743
				onProgress(nil, { -- 2763
					state = "pending", -- 2764
					mode = "lua", -- 2765
					operationId = req.operationId, -- 2766
					stage = "lua", -- 2767
					message = "Lua command pending" -- 2768
				}) -- 2768
			end -- 2768
			Director.systemScheduler:schedule(function() -- 2771
				if settled then -- 2771
					return true -- 2772
				end -- 2772
				local watchdogMessage = checkEntryWatchdog() -- 2773
				if watchdogMessage ~= nil then -- 2773
					finish({ -- 2775
						success = false, -- 2776
						mode = "lua", -- 2777
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2778
						message = watchdogMessage, -- 2779
						phase = "execute", -- 2780
						interrupted = true -- 2781
					}) -- 2781
					return true -- 2783
				end -- 2783
				if isCancelled and isCancelled(nil) then -- 2783
					finish({ -- 2786
						success = false, -- 2787
						mode = "lua", -- 2788
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2789
						message = "Lua command canceled", -- 2790
						phase = "execute", -- 2791
						interrupted = true -- 2792
					}) -- 2792
					return true -- 2794
				end -- 2794
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 2794
					finish({ -- 2797
						success = false, -- 2798
						mode = "lua", -- 2799
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2800
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 2801
						phase = "timeout" -- 2802
					}) -- 2802
					return true -- 2804
				end -- 2804
				return false -- 2806
			end) -- 2771
			Director.systemScheduler:schedule(once(function() -- 2808
				if settled then -- 2808
					return -- 2809
				end -- 2809
				if onProgress then -- 2809
					onProgress(nil, { -- 2811
						state = "running", -- 2812
						mode = "lua", -- 2813
						operationId = req.operationId, -- 2814
						stage = "lua", -- 2815
						message = "Lua command running" -- 2816
					}) -- 2816
				end -- 2816
				local previousGlobalPrint = _G.print -- 2819
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 2820
				local frameTimedOut = false -- 2821
				local watchdogMessage -- 2821
				_G.print = capturePrint -- 2822
				debug.sethook( -- 2823
					function() -- 2823
						if watchdogMessage == nil then -- 2823
							watchdogMessage = checkEntryWatchdog() -- 2824
						end -- 2824
						if watchdogMessage ~= nil then -- 2824
							error(watchdogMessage) -- 2825
						end -- 2825
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 2825
							frameTimedOut = true -- 2827
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 2828
						end -- 2828
					end, -- 2823
					"", -- 2830
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 2830
				) -- 2830
				local ok, runtimeErr = pcall(fn) -- 2831
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 2831
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 2833
				else -- 2833
					debug.sethook() -- 2839
				end -- 2839
				_G.print = previousGlobalPrint -- 2841
				if not ok then -- 2841
					local ____truncateCommandOutput_result_42 = truncateCommandOutput(table.concat(output, "\n")) -- 2846
					local ____temp_43 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 2847
					local ____temp_44 = frameTimedOut and "timeout" or "execute" -- 2848
					local ____temp_41 -- 2849
					if watchdogMessage ~= nil or frameTimedOut then -- 2849
						____temp_41 = true -- 2849
					else -- 2849
						____temp_41 = nil -- 2849
					end -- 2849
					finish({ -- 2843
						success = false, -- 2844
						mode = "lua", -- 2845
						output = ____truncateCommandOutput_result_42, -- 2846
						message = ____temp_43, -- 2847
						phase = ____temp_44, -- 2848
						interrupted = ____temp_41 -- 2849
					}) -- 2849
					return -- 2851
				end -- 2851
				finish({ -- 2853
					success = true, -- 2853
					mode = "lua", -- 2853
					output = truncateCommandOutput(table.concat(output, "\n")) -- 2853
				}) -- 2853
			end)) -- 2808
		end -- 2738
	) -- 2738
end -- 2560
local function formatGitStatusOutput(status) -- 2858
	if not status then -- 2858
		return "" -- 2859
	end -- 2859
	local lines = {} -- 2860
	local state = toStr(status.state) -- 2861
	local kind = toStr(status.kind) -- 2862
	local message = toStr(status.message) -- 2863
	local errorMessage = toStr(status.error) -- 2864
	if kind ~= "" or state ~= "" then -- 2864
		lines[#lines + 1] = table.concat( -- 2866
			__TS__ArrayFilter( -- 2866
				{kind, state}, -- 2866
				function(____, item) return item ~= "" end -- 2866
			), -- 2866
			": " -- 2866
		) -- 2866
	end -- 2866
	if message ~= "" then -- 2866
		lines[#lines + 1] = message -- 2868
	end -- 2868
	if errorMessage ~= "" then -- 2868
		lines[#lines + 1] = errorMessage -- 2869
	end -- 2869
	local data = status.data -- 2870
	if data ~= nil then -- 2870
		local dataText = encodeJSON(data) -- 2872
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 2873
	end -- 2873
	return truncateCommandOutput(table.concat(lines, "\n")) -- 2875
end -- 2858
local function emitGitProgress(mode, operationId, onProgress, status) -- 2878
	if not onProgress then -- 2878
		return -- 2884
	end -- 2884
	local progress = type(status.progress) == "number" and status.progress or nil -- 2885
	local kind = toStr(status.kind) -- 2886
	local message = toStr(status.message) -- 2887
	local state = toStr(status.state) -- 2888
	local jobId = type(status.id) == "number" and status.id or nil -- 2889
	onProgress({ -- 2890
		state = "running", -- 2891
		mode = mode, -- 2892
		operationId = operationId, -- 2893
		stage = kind ~= "" and kind or "git", -- 2894
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 2895
		progress = progress, -- 2896
		jobId = jobId, -- 2897
		gitState = state ~= "" and state or nil, -- 2898
		gitKind = kind ~= "" and kind or nil -- 2899
	}) -- 2899
end -- 2878
local function cloneGitToTarget(req) -- 2903
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2903
		local parsed = parseGitCloneCommand(req.command) -- 2911
		if parsed == nil then -- 2911
			return ____awaiter_resolve(nil, nil) -- 2911
		end -- 2911
		if not parsed.success then -- 2911
			return ____awaiter_resolve(nil, { -- 2911
				success = false, -- 2914
				mode = "git", -- 2914
				output = "", -- 2914
				message = parsed.message, -- 2914
				phase = "validate" -- 2914
			}) -- 2914
		end -- 2914
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 2916
		if not target then -- 2916
			return ____awaiter_resolve(nil, { -- 2916
				success = false, -- 2918
				mode = "git", -- 2918
				output = "", -- 2918
				message = "invalid clone target path", -- 2918
				phase = "validate" -- 2918
			}) -- 2918
		end -- 2918
		if Content:exist(target) then -- 2918
			return ____awaiter_resolve(nil, { -- 2918
				success = false, -- 2921
				mode = "git", -- 2921
				output = "", -- 2921
				message = "target already exists", -- 2921
				phase = "validate" -- 2921
			}) -- 2921
		end -- 2921
		local targetParent = Path:getPath(target) -- 2923
		if not ensureDirPath(targetParent) then -- 2923
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 2923
		end -- 2923
		local tempRoot = getAgentDownloadTempRoot() -- 2927
		if not ensureDirPath(tempRoot) then -- 2927
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 2927
		end -- 2927
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 2931
		Content:remove(tempPath) -- 2932
		local depth = parsed.depth or "1" -- 2933
		local ____array_45 = __TS__SparseArrayNew( -- 2933
			"clone", -- 2935
			quoteGitArg(parsed.url), -- 2936
			quoteGitArg(Path:getFilename(tempPath)), -- 2937
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 2938
				"-b", -- 2938
				quoteGitArg(parsed.ref) -- 2938
			}) or ({})) -- 2938
		) -- 2938
		__TS__SparseArrayPush( -- 2938
			____array_45, -- 2938
			table.unpack(depth ~= "" and ({ -- 2939
				"--depth",
				quoteGitArg(depth) -- 2939
			}) or ({})) -- 2939
		) -- 2939
		local command = table.concat( -- 2934
			{__TS__SparseArraySpread(____array_45)}, -- 2934
			" " -- 2940
		) -- 2940
		local ____this_47 -- 2940
		____this_47 = req -- 2941
		local ____opt_46 = ____this_47.onProgress -- 2941
		if ____opt_46 ~= nil then -- 2941
			____opt_46(____this_47, { -- 2941
				state = "pending", -- 2942
				mode = "git", -- 2943
				operationId = req.operationId, -- 2944
				stage = "clone", -- 2945
				message = "clone pending", -- 2946
				progress = 0 -- 2947
			}) -- 2947
		end -- 2947
		local gitRes = __TS__Await(runGitAndWait( -- 2949
			tempRoot, -- 2950
			command, -- 2951
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2952
			function() -- 2953
				local ____this_49 -- 2953
				____this_49 = req -- 2953
				local ____opt_48 = ____this_49.isCancelled -- 2953
				return (____opt_48 and ____opt_48(____this_49)) == true -- 2953
			end, -- 2953
			req.timeoutSeconds -- 2954
		)) -- 2954
		if not gitRes.success then -- 2954
			local cleanupError = cleanupPath(tempPath) -- 2957
			local ____formatGitStatusOutput_result_53 = formatGitStatusOutput(gitRes.status) -- 2961
			local ____temp_54 = gitRes.message or "git clone failed" -- 2962
			local ____gitRes_interrupted_52 = gitRes.interrupted -- 2963
			if not ____gitRes_interrupted_52 then -- 2963
				local ____this_51 -- 2963
				____this_51 = req -- 2963
				local ____opt_50 = ____this_51.isCancelled -- 2963
				____gitRes_interrupted_52 = (____opt_50 and ____opt_50(____this_51)) == true -- 2963
			end -- 2963
			return ____awaiter_resolve(nil, { -- 2963
				success = false, -- 2959
				mode = "git", -- 2960
				output = ____formatGitStatusOutput_result_53, -- 2961
				message = ____temp_54, -- 2962
				interrupted = ____gitRes_interrupted_52, -- 2963
				cleanupError = cleanupError -- 2964
			}) -- 2964
		end -- 2964
		if not Content:move(tempPath, target) then -- 2964
			local cleanupError = cleanupPath(tempPath) -- 2968
			return ____awaiter_resolve( -- 2968
				nil, -- 2968
				{ -- 2969
					success = false, -- 2969
					mode = "git", -- 2969
					output = formatGitStatusOutput(gitRes.status), -- 2969
					message = "failed to move cloned repository into target path", -- 2969
					cleanupError = cleanupError -- 2969
				} -- 2969
			) -- 2969
		end -- 2969
		if not refreshProjectTree(req.workDir) then -- 2969
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 2972
		end -- 2972
		local commit = getGitHeadCommit(target) -- 2974
		local output = table.concat( -- 2975
			__TS__ArrayFilter( -- 2975
				{ -- 2975
					formatGitStatusOutput(gitRes.status), -- 2976
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 2976
					commit ~= nil and "commit " .. commit or "" -- 2978
				}, -- 2978
				function(____, item) return item ~= "" end -- 2979
			), -- 2979
			"\n" -- 2979
		) -- 2979
		return ____awaiter_resolve( -- 2979
			nil, -- 2979
			{ -- 2980
				success = true, -- 2980
				mode = "git", -- 2980
				output = truncateCommandOutput(output) -- 2980
			} -- 2980
		) -- 2980
	end) -- 2980
end -- 2903
local function loadGitProfile() -- 2983
	local rows -- 2984
	do -- 2984
		local function ____catch() -- 2984
			return true, nil -- 2988
		end -- 2988
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2988
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 2986
		end) -- 2986
		if not ____try then -- 2986
			____hasReturned, ____returnValue = ____catch() -- 2986
		end -- 2986
		if ____hasReturned then -- 2986
			return ____returnValue -- 2985
		end -- 2985
	end -- 2985
	if not rows or not rows[1] then -- 2985
		return nil -- 2990
	end -- 2990
	local name = toStr(rows[1][1]) -- 2991
	local email = toStr(rows[1][2]) -- 2992
	if name == "" and email == "" then -- 2992
		return nil -- 2993
	end -- 2993
	return {name = name, email = email} -- 2994
end -- 2983
local function applyGitProfileToCommit(command) -- 2997
	local args = shellSplit(command) -- 2998
	if args[1] ~= "commit" then -- 2998
		return command -- 2999
	end -- 2999
	local hasName = false -- 3000
	local hasEmail = false -- 3001
	for ____, arg in ipairs(args) do -- 3002
		if arg == "--author-name" then
			hasName = true -- 3003
		end -- 3003
		if arg == "--author-email" then
			hasEmail = true -- 3004
		end -- 3004
	end -- 3004
	if hasName and hasEmail then -- 3004
		return command -- 3006
	end -- 3006
	local profile = loadGitProfile() -- 3007
	if not profile then -- 3007
		return command -- 3008
	end -- 3008
	local additions = {} -- 3009
	if not hasName and profile.name ~= "" then -- 3009
		__TS__ArrayPush( -- 3011
			additions, -- 3011
			"--author-name",
			quoteGitArg(profile.name) -- 3011
		) -- 3011
	end -- 3011
	if not hasEmail and profile.email ~= "" then -- 3011
		__TS__ArrayPush( -- 3014
			additions, -- 3014
			"--author-email",
			quoteGitArg(profile.email) -- 3014
		) -- 3014
	end -- 3014
	if #additions == 0 then -- 3014
		return command -- 3016
	end -- 3016
	return (command .. " ") .. table.concat(additions, " ") -- 3017
end -- 2997
local function executeGitCommand(req) -- 3020
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3020
		local command = normalizeGitCommand(req.command or "") -- 3029
		if command == "" then -- 3029
			return ____awaiter_resolve(nil, { -- 3029
				success = false, -- 3031
				mode = "git", -- 3031
				output = "", -- 3031
				message = "missing command", -- 3031
				phase = "validate" -- 3031
			}) -- 3031
		end -- 3031
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 3033
			workDir = req.workDir, -- 3034
			command = command, -- 3035
			operationId = req.operationId, -- 3036
			timeoutSeconds = req.timeoutSeconds, -- 3037
			onProgress = req.onProgress, -- 3038
			isCancelled = req.isCancelled -- 3039
		})) -- 3039
		if cloneResult ~= nil then -- 3039
			return ____awaiter_resolve(nil, cloneResult) -- 3039
		end -- 3039
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 3042
		if not cwd.success then -- 3042
			return ____awaiter_resolve(nil, { -- 3042
				success = false, -- 3044
				mode = "git", -- 3044
				output = "", -- 3044
				cwd = req.cwd, -- 3044
				message = cwd.message, -- 3044
				phase = "validate" -- 3044
			}) -- 3044
		end -- 3044
		command = applyGitProfileToCommit(command) -- 3046
		local ____this_56 -- 3046
		____this_56 = req -- 3047
		local ____opt_55 = ____this_56.onProgress -- 3047
		if ____opt_55 ~= nil then -- 3047
			____opt_55(____this_56, { -- 3047
				state = "pending", -- 3048
				mode = "git", -- 3049
				operationId = req.operationId, -- 3050
				stage = "git", -- 3051
				message = "git command pending", -- 3052
				progress = 0 -- 3053
			}) -- 3053
		end -- 3053
		local gitRes = __TS__Await(runGitAndWait( -- 3055
			cwd.path, -- 3056
			command, -- 3057
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 3058
			function() -- 3059
				local ____this_58 -- 3059
				____this_58 = req -- 3059
				local ____opt_57 = ____this_58.isCancelled -- 3059
				return (____opt_57 and ____opt_57(____this_58)) == true -- 3059
			end, -- 3059
			req.timeoutSeconds -- 3060
		)) -- 3060
		local output = formatGitStatusOutput(gitRes.status) -- 3062
		if not gitRes.success then -- 3062
			local ____output_62 = output -- 3067
			local ____cwd_relative_63 = cwd.relative -- 3068
			local ____temp_64 = gitRes.message or "git command failed" -- 3069
			local ____gitRes_interrupted_61 = gitRes.interrupted -- 3070
			if not ____gitRes_interrupted_61 then -- 3070
				local ____this_60 -- 3070
				____this_60 = req -- 3070
				local ____opt_59 = ____this_60.isCancelled -- 3070
				____gitRes_interrupted_61 = (____opt_59 and ____opt_59(____this_60)) == true -- 3070
			end -- 3070
			return ____awaiter_resolve(nil, { -- 3070
				success = false, -- 3065
				mode = "git", -- 3066
				output = ____output_62, -- 3067
				cwd = ____cwd_relative_63, -- 3068
				message = ____temp_64, -- 3069
				interrupted = ____gitRes_interrupted_61 -- 3070
			}) -- 3070
		end -- 3070
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 3070
	end) -- 3070
end -- 3020
function ____exports.executeCommand(req) -- 3076
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3076
		local mode = req.mode -- 3086
		if mode ~= "lua" and mode ~= "git" then -- 3086
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 3086
		end -- 3086
		if mode == "lua" then -- 3086
			return ____awaiter_resolve( -- 3086
				nil, -- 3086
				executeLuaCommand({ -- 3091
					workDir = req.workDir, -- 3092
					code = req.code or "", -- 3093
					timeoutSeconds = math.max( -- 3094
						1, -- 3094
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 3094
					), -- 3094
					operationId = createOperationId(), -- 3095
					onProgress = req.onProgress, -- 3096
					isCancelled = req.isCancelled -- 3097
				}) -- 3097
			) -- 3097
		end -- 3097
		local operationId = createOperationId() -- 3100
		return ____awaiter_resolve( -- 3100
			nil, -- 3100
			executeGitCommand({ -- 3101
				workDir = req.workDir, -- 3102
				command = req.command or "", -- 3103
				cwd = req.cwd, -- 3104
				timeoutSeconds = math.max( -- 3105
					1, -- 3105
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 3105
				), -- 3105
				operationId = operationId, -- 3106
				onProgress = req.onProgress, -- 3107
				isCancelled = req.isCancelled -- 3108
			}) -- 3108
		) -- 3108
	end) -- 3108
end -- 3076
function ____exports.fetchUrl(req) -- 3112
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3112
		local mode = "download" -- 3119
		local url = __TS__StringTrim(req.url or "") -- 3120
		local targetRel = __TS__StringTrim(req.target or "") -- 3121
		if not isHttpUrl(url) then -- 3121
			return ____awaiter_resolve(nil, { -- 3121
				success = false, -- 3123
				state = "failed", -- 3123
				mode = mode, -- 3123
				target = targetRel, -- 3123
				message = "fetch_url only supports http:// and https:// URLs" -- 3123
			}) -- 3123
		end -- 3123
		if targetRel == "" then -- 3123
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 3123
		end -- 3123
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 3128
		if not target then -- 3128
			return ____awaiter_resolve(nil, { -- 3128
				success = false, -- 3130
				state = "failed", -- 3130
				mode = mode, -- 3130
				target = targetRel, -- 3130
				message = "invalid target path" -- 3130
			}) -- 3130
		end -- 3130
		if Content:exist(target) then -- 3130
			return ____awaiter_resolve(nil, { -- 3130
				success = false, -- 3133
				state = "failed", -- 3133
				mode = mode, -- 3133
				target = targetRel, -- 3133
				message = "target already exists" -- 3133
			}) -- 3133
		end -- 3133
		local operationId = createOperationId() -- 3135
		local tempRoot = getAgentDownloadTempRoot() -- 3136
		if not ensureDirPath(tempRoot) then -- 3136
			return ____awaiter_resolve(nil, { -- 3136
				success = false, -- 3138
				state = "failed", -- 3138
				mode = mode, -- 3138
				target = targetRel, -- 3138
				message = "failed to create agent download temp directory" -- 3138
			}) -- 3138
		end -- 3138
		local tempPath = Path(tempRoot, operationId .. ".download") -- 3140
		Content:remove(tempPath) -- 3141
		local function emitProgress(progress) -- 3142
			if not req.onProgress then -- 3142
				return -- 3143
			end -- 3143
			req:onProgress(__TS__ObjectAssign({ -- 3144
				state = "running", -- 3145
				mode = mode, -- 3146
				operationId = operationId, -- 3147
				target = targetRel, -- 3148
				tempPath = tempPath -- 3149
			}, progress)) -- 3149
		end -- 3142
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 3153
		local function interrupted() -- 3158
			local ____this_66 -- 3158
			____this_66 = req -- 3158
			local ____opt_65 = ____this_66.isCancelled -- 3158
			return (____opt_65 and ____opt_65(____this_66)) == true -- 3158
		end -- 3158
		if not ensureDirForFile(tempPath) then -- 3158
			return ____awaiter_resolve(nil, { -- 3158
				success = false, -- 3160
				state = "failed", -- 3160
				mode = mode, -- 3160
				target = targetRel, -- 3160
				message = "failed to create temporary file directory" -- 3160
			}) -- 3160
		end -- 3160
		local downloadRes = __TS__Await(downloadFile({ -- 3162
			url = url, -- 3163
			tempPath = tempPath, -- 3164
			timeout = 600, -- 3165
			isCancelled = interrupted, -- 3166
			onProgress = function(____, current, total) -- 3167
				local totalNumber = type(total) == "number" and total or 0 -- 3168
				emitProgress({ -- 3169
					stage = "download", -- 3170
					message = "downloading", -- 3171
					current = current, -- 3172
					total = total, -- 3173
					progress = totalNumber > 0 and current / totalNumber or nil -- 3174
				}) -- 3174
			end -- 3167
		})) -- 3167
		if not downloadRes.success then -- 3167
			local cleanupError = cleanupPath(tempPath) -- 3179
			return ____awaiter_resolve( -- 3179
				nil, -- 3179
				{ -- 3180
					success = false, -- 3181
					state = "failed", -- 3182
					mode = mode, -- 3183
					target = targetRel, -- 3184
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 3185
					interrupted = downloadRes.interrupted or interrupted(), -- 3186
					cleanupError = cleanupError -- 3187
				} -- 3187
			) -- 3187
		end -- 3187
		if not ensureDirForFile(target) then -- 3187
			local cleanupError = cleanupPath(tempPath) -- 3191
			return ____awaiter_resolve(nil, { -- 3191
				success = false, -- 3192
				state = "failed", -- 3192
				mode = mode, -- 3192
				target = targetRel, -- 3192
				message = "failed to create target directory", -- 3192
				cleanupError = cleanupError -- 3192
			}) -- 3192
		end -- 3192
		if not Content:move(tempPath, target) then -- 3192
			local cleanupError = cleanupPath(tempPath) -- 3195
			return ____awaiter_resolve(nil, { -- 3195
				success = false, -- 3196
				state = "failed", -- 3196
				mode = mode, -- 3196
				target = targetRel, -- 3196
				message = "failed to move downloaded file into target path", -- 3196
				cleanupError = cleanupError -- 3196
			}) -- 3196
		end -- 3196
		local bytesWritten = downloadRes.bytesWritten -- 3198
		local ____try = __TS__AsyncAwaiter(function() -- 3198
			local size = Content:getAttr(target) -- 3200
			if bytesWritten == nil or bytesWritten <= 0 then -- 3200
				bytesWritten = type(size) == "number" and size or nil -- 3202
			end -- 3202
		end) -- 3202
		____try = ____try.catch( -- 3202
			____try, -- 3202
			function(____, _) -- 3202
				return __TS__AsyncAwaiter(function() -- 3202
				end) -- 3202
			end -- 3202
		) -- 3202
		__TS__Await(____try) -- 3199
		if bytesWritten == nil or bytesWritten <= 0 then -- 3199
			local ____try = __TS__AsyncAwaiter(function() -- 3199
				local loaded = Content:load(target) -- 3209
				if type(loaded) == "string" then -- 3209
					bytesWritten = #loaded -- 3211
				end -- 3211
			end) -- 3211
			____try = ____try.catch( -- 3211
				____try, -- 3211
				function(____, _) -- 3211
					return __TS__AsyncAwaiter(function() -- 3211
					end) -- 3211
				end -- 3211
			) -- 3211
			__TS__Await(____try) -- 3208
		end -- 3208
		if not syncDownloadedFileToWebIDE(target) then -- 3208
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 3218
		end -- 3218
		return ____awaiter_resolve(nil, { -- 3218
			success = true, -- 3220
			state = "done", -- 3220
			mode = mode, -- 3220
			target = targetRel, -- 3220
			bytesWritten = bytesWritten -- 3220
		}) -- 3220
	end) -- 3220
end -- 3112
local SFX_SAMPLE_RATE = 44100 -- 3256
local SFX_MAX_SAMPLES = SFX_SAMPLE_RATE * 3 -- 3257
local SFX_OVERSAMPLING = 8 -- 3258
local SFX_NOISE_SIZE = 32 -- 3259
local SFX_PHASER_SIZE = 1024 -- 3260
local SFX_WAV_PACK_CHUNK = 1024 -- 3261
--- Park-Miller LCG. Math.random is not acceptable here: the same seed must
-- always reproduce the same sound, and ordinary double arithmetic keeps the
-- multiplication exact (state * 16807 stays below 2^53).
local function createSfxRng(seed) -- 3272
	local state = math.floor(math.abs(seed)) % 2147483647 -- 3273
	if state <= 0 then -- 3273
		state = 1 -- 3274
	end -- 3274
	return {next = function() -- 3275
		state = state * 16807 % 2147483647 -- 3277
		return (state - 1) / 2147483646 -- 3278
	end} -- 3276
end -- 3272
local function resetSfxrParams() -- 3309
	return { -- 3310
		waveType = 0, -- 3311
		startFreq = 0.3, -- 3312
		minFreq = 0, -- 3313
		slide = 0, -- 3314
		deltaSlide = 0, -- 3315
		duty = 0, -- 3316
		dutySweep = 0, -- 3317
		vibDepth = 0, -- 3318
		vibSpeed = 0, -- 3319
		attack = 0, -- 3320
		sustain = 0.3, -- 3321
		decay = 0.4, -- 3322
		punch = 0, -- 3323
		changeAmount = 0, -- 3324
		changeSpeed = 0, -- 3325
		phaserOffset = 0, -- 3326
		phaserSweep = 0, -- 3327
		lpCutoff = 1, -- 3328
		lpCutoffSweep = 0, -- 3329
		lpResonance = 0, -- 3330
		hpCutoff = 0, -- 3331
		hpCutoffSweep = 0, -- 3332
		repeatSpeed = 0 -- 3333
	} -- 3333
end -- 3309
--- Preset generators ported from the classic sfxr/as3sfxr randomizers.
-- Parameter names map: changeAmount = arp_mod, changeSpeed = arp_speed.
local function generateSfxrPreset(kind, rng) -- 3341
	local function rnd() -- 3342
		return rng:next() -- 3342
	end -- 3342
	local function frnd(range) -- 3343
		return rnd() * range -- 3343
	end -- 3343
	local p = resetSfxrParams() -- 3344
	repeat -- 3344
		local ____switch663 = kind -- 3344
		local ____cond663 = ____switch663 == "pickup" -- 3344
		if ____cond663 then -- 3344
			do -- 3344
				p.waveType = math.floor(rnd() * 3) -- 3347
				p.startFreq = 0.4 + frnd(0.5) -- 3348
				p.attack = 0 -- 3349
				p.sustain = frnd(0.1) -- 3350
				p.decay = 0.1 + frnd(0.4) -- 3351
				p.punch = 0.3 + frnd(0.3) -- 3352
				if rnd() < 0.5 then -- 3352
					p.changeSpeed = 0.5 + frnd(0.2) -- 3354
					p.changeAmount = 0.2 + frnd(0.4) -- 3355
				end -- 3355
				break -- 3357
			end -- 3357
		end -- 3357
		____cond663 = ____cond663 or ____switch663 == "laser" -- 3357
		if ____cond663 then -- 3357
			do -- 3357
				p.waveType = math.floor(rnd() * 3) -- 3360
				if p.waveType == 2 and rnd() < 0.5 then -- 3360
					p.waveType = math.floor(rnd() * 2) -- 3361
				end -- 3361
				p.startFreq = 0.5 + frnd(0.5) -- 3362
				p.minFreq = p.startFreq - 0.2 - frnd(0.6) -- 3363
				if p.minFreq < 0.2 then -- 3363
					p.minFreq = 0.2 -- 3364
				end -- 3364
				p.slide = -0.15 - frnd(0.2) -- 3365
				if rnd() < 0.33 then -- 3365
					p.startFreq = 0.3 + frnd(0.6) -- 3367
					p.minFreq = frnd(0.1) -- 3368
					p.slide = -0.35 - frnd(0.3) -- 3369
				end -- 3369
				if rnd() < 0.5 then -- 3369
					p.duty = frnd(0.5) -- 3372
					p.dutySweep = frnd(0.2) -- 3373
				else -- 3373
					p.duty = 0.4 + frnd(0.5) -- 3375
					p.dutySweep = -frnd(0.7) -- 3376
				end -- 3376
				p.attack = 0 -- 3378
				p.sustain = 0.1 + frnd(0.2) -- 3379
				p.decay = frnd(0.4) -- 3380
				if rnd() < 0.5 then -- 3380
					p.punch = frnd(0.3) -- 3381
				end -- 3381
				if rnd() < 0.33 then -- 3381
					p.phaserOffset = frnd(0.2) -- 3383
					p.phaserSweep = -frnd(0.2) -- 3384
				end -- 3384
				if rnd() < 0.5 then -- 3384
					p.hpCutoff = frnd(0.3) -- 3386
				end -- 3386
				break -- 3387
			end -- 3387
		end -- 3387
		____cond663 = ____cond663 or ____switch663 == "explosion" -- 3387
		if ____cond663 then -- 3387
			do -- 3387
				p.waveType = 3 -- 3390
				p.startFreq = 0.1 + frnd(0.4) -- 3391
				p.slide = -0.1 + frnd(0.4) -- 3392
				p.attack = 0 -- 3393
				p.sustain = 0.1 + frnd(0.2) -- 3394
				p.decay = frnd(0.5) -- 3395
				if rnd() < 0.5 then -- 3395
					p.phaserOffset = -0.3 + frnd(0.9) -- 3397
					p.phaserSweep = -frnd(0.3) -- 3398
				end -- 3398
				if rnd() < 0.33 then -- 3398
					p.startFreq = 0.2 + frnd(0.7) -- 3401
					p.slide = -0.2 - frnd(0.2) -- 3402
				end -- 3402
				if rnd() < 0.5 then -- 3402
					p.punch = 0.2 + frnd(0.6) -- 3404
				end -- 3404
				break -- 3405
			end -- 3405
		end -- 3405
		____cond663 = ____cond663 or ____switch663 == "powerup" -- 3405
		if ____cond663 then -- 3405
			do -- 3405
				p.waveType = rnd() < 0.5 and 0 or 1 -- 3408
				p.startFreq = 0.2 + frnd(0.3) -- 3409
				p.slide = 0.1 + frnd(0.2) -- 3410
				p.changeAmount = 0.2 + frnd(0.4) -- 3411
				p.changeSpeed = 0.6 + frnd(0.3) -- 3412
				p.attack = 0 -- 3413
				p.sustain = 0.2 + frnd(0.3) -- 3414
				p.decay = frnd(0.2) -- 3415
				p.punch = 0.2 + frnd(0.4) -- 3416
				break -- 3417
			end -- 3417
		end -- 3417
		____cond663 = ____cond663 or ____switch663 == "hit" -- 3417
		if ____cond663 then -- 3417
			do -- 3417
				p.waveType = math.floor(rnd() * 3) -- 3420
				if p.waveType == 2 then -- 3420
					p.waveType = 3 -- 3421
				end -- 3421
				p.startFreq = 0.2 + frnd(0.6) -- 3422
				p.slide = -0.3 - frnd(0.4) -- 3423
				p.attack = 0 -- 3424
				p.sustain = frnd(0.1) -- 3425
				p.decay = 0.1 + frnd(0.2) -- 3426
				if rnd() < 0.5 then -- 3426
					p.hpCutoff = frnd(0.3) -- 3427
				end -- 3427
				break -- 3428
			end -- 3428
		end -- 3428
		____cond663 = ____cond663 or ____switch663 == "jump" -- 3428
		if ____cond663 then -- 3428
			do -- 3428
				p.waveType = 0 -- 3431
				p.startFreq = 0.3 + frnd(0.3) -- 3432
				p.slide = 0.1 + frnd(0.2) -- 3433
				p.attack = 0 -- 3434
				p.sustain = 0.1 + frnd(0.3) -- 3435
				p.decay = 0.1 + frnd(0.2) -- 3436
				if rnd() < 0.5 then -- 3436
					p.duty = frnd(0.6) -- 3438
					p.dutySweep = frnd(0.2) -- 3439
				end -- 3439
				break -- 3441
			end -- 3441
		end -- 3441
		____cond663 = ____cond663 or ____switch663 == "click" -- 3441
		if ____cond663 then -- 3441
			do -- 3441
				p.waveType = math.floor(rnd() * 2) -- 3444
				p.startFreq = 0.2 + frnd(0.4) -- 3445
				p.attack = 0 -- 3446
				p.sustain = 0.05 + frnd(0.05) -- 3447
				p.decay = 0.05 + frnd(0.15) -- 3448
				p.hpCutoff = 0.1 -- 3449
				break -- 3450
			end -- 3450
		end -- 3450
		do -- 3450
			do -- 3450
				local families = { -- 3453
					"jump", -- 3453
					"explosion", -- 3453
					"hit", -- 3453
					"pickup", -- 3453
					"laser", -- 3453
					"powerup", -- 3453
					"click" -- 3453
				} -- 3453
				return generateSfxrPreset( -- 3454
					families[math.floor(rnd() * #families) + 1], -- 3454
					rng -- 3454
				) -- 3454
			end -- 3454
		end -- 3454
	until true -- 3454
	return p -- 3457
end -- 3341
--- Synthesize float samples in [-1, 1] from sfxr parameters. Port of the
-- classic sfxr sample generator: frequency slide, arpeggio, vibrato, square
-- duty sweep, ADSR envelope with punch, one-pole low/high pass filters, and a
-- phaser tap. Length is bounded by the envelope plus SFX_MAX_SAMPLES.
local function synthSfxr(p, masterVolume, rng) -- 3466
	local samples = {} -- 3467
	local startPeriod = 100 / (p.startFreq * p.startFreq + 0.001) -- 3468
	local fperiod = startPeriod -- 3469
	local period = math.floor(fperiod) -- 3470
	local fmaxperiod = 100 / (p.minFreq * p.minFreq + 0.001) -- 3471
	local startSlide = 1 - p.slide ^ 3 * 0.01 -- 3472
	local fslide = startSlide -- 3473
	local fdslide = -p.deltaSlide ^ 3 * 0.000001 -- 3474
	local squareDuty = 0.5 - p.duty * 0.5 -- 3475
	local squareSlide = -p.dutySweep * 0.00005 -- 3476
	local arpMod = p.changeAmount >= 0 and 1 - p.changeAmount ^ 2 * 0.9 or 1 + p.changeAmount ^ 2 * 10 -- 3477
	local arpTime = 0 -- 3480
	local arpLimit = math.floor((1 - p.changeSpeed) ^ 2 * 20000) + 32 -- 3481
	if p.changeSpeed >= 1 then -- 3481
		arpLimit = 0 -- 3482
	end -- 3482
	local envStage = 0 -- 3483
	local envTime = 0 -- 3484
	local envLength = { -- 3485
		math.max( -- 3486
			1, -- 3486
			math.floor(p.attack * p.attack * 100000) -- 3486
		), -- 3486
		math.max( -- 3487
			1, -- 3487
			math.floor(p.sustain * p.sustain * 100000) -- 3487
		), -- 3487
		math.max( -- 3488
			1, -- 3488
			math.floor(p.decay * p.decay * 100000) -- 3488
		) -- 3488
	} -- 3488
	local phaserBuffer = {} -- 3490
	do -- 3490
		local i = 0 -- 3491
		while i < SFX_PHASER_SIZE do -- 3491
			phaserBuffer[#phaserBuffer + 1] = 0 -- 3491
			i = i + 1 -- 3491
		end -- 3491
	end -- 3491
	local fphase = p.phaserOffset ^ 2 * 1020 -- 3492
	if p.phaserOffset < 0 then -- 3492
		fphase = -fphase -- 3493
	end -- 3493
	local fdsweep = p.phaserSweep ^ 2 * (p.phaserSweep < 0 and -1 or 1) -- 3494
	local iphase = math.floor(math.abs(fphase)) -- 3495
	if iphase > SFX_PHASER_SIZE - 1 then -- 3495
		iphase = SFX_PHASER_SIZE - 1 -- 3496
	end -- 3496
	local ipp = 0 -- 3497
	local phaserOn = p.phaserOffset ~= 0 or p.phaserSweep ~= 0 -- 3498
	local noiseBuffer = {} -- 3499
	do -- 3499
		local i = 0 -- 3500
		while i < SFX_NOISE_SIZE do -- 3500
			noiseBuffer[#noiseBuffer + 1] = rng:next() * 2 - 1 -- 3500
			i = i + 1 -- 3500
		end -- 3500
	end -- 3500
	local fltp = 0 -- 3501
	local fltdp = 0 -- 3502
	local fltw = p.lpCutoff ^ 3 * 0.1 -- 3503
	local fltwD = 1 + p.lpCutoffSweep * 0.0001 -- 3504
	local fltdmp = 5 / (1 + p.lpResonance ^ 2 * 20) * (0.01 + fltw) -- 3505
	local fltphp = 0 -- 3506
	local flthp = p.hpCutoff ^ 2 * 0.1 -- 3507
	local flthpD = 1 + p.hpCutoffSweep * 0.0003 -- 3508
	local vibPhase = 0 -- 3509
	local vibSpeed = p.vibSpeed ^ 2 * 0.01 -- 3510
	local vibAmp = p.vibDepth * 0.5 -- 3511
	local repeatTime = 0 -- 3512
	local repeatLimit = p.repeatSpeed > 0 and math.floor((1 - p.repeatSpeed) ^ 2 * 20000) + 32 or 0 -- 3513
	local phase = 0 -- 3516
	local finished = false -- 3517
	while not finished and #samples < SFX_MAX_SAMPLES do -- 3517
		repeatTime = repeatTime + 1 -- 3519
		if repeatLimit > 0 and repeatTime >= repeatLimit then -- 3519
			repeatTime = 0 -- 3521
			fperiod = startPeriod -- 3522
			fslide = startSlide -- 3523
		end -- 3523
		arpTime = arpTime + 1 -- 3525
		if arpLimit > 0 and arpTime >= arpLimit then -- 3525
			arpLimit = 0 -- 3527
			fperiod = fperiod * arpMod -- 3528
		end -- 3528
		fslide = fslide + fdslide -- 3530
		fperiod = fperiod * fslide -- 3531
		if fperiod > fmaxperiod then -- 3531
			fperiod = fmaxperiod -- 3533
			if p.minFreq > 0 then -- 3533
				finished = true -- 3534
			end -- 3534
		end -- 3534
		local rfperiod = fperiod -- 3536
		if vibAmp > 0 then -- 3536
			vibPhase = vibPhase + vibSpeed -- 3538
			rfperiod = fperiod * (1 + math.sin(vibPhase) * vibAmp) -- 3539
		end -- 3539
		period = math.floor(rfperiod) -- 3541
		if period < SFX_OVERSAMPLING then -- 3541
			period = SFX_OVERSAMPLING -- 3542
		end -- 3542
		squareDuty = squareDuty + squareSlide -- 3543
		if squareDuty < 0 then -- 3543
			squareDuty = 0 -- 3544
		end -- 3544
		if squareDuty > 0.5 then -- 3544
			squareDuty = 0.5 -- 3545
		end -- 3545
		envTime = envTime + 1 -- 3546
		if envStage == 0 and envTime >= envLength[1] then -- 3546
			envStage = 1 -- 3548
			envTime = 0 -- 3549
		elseif envStage == 1 and envTime >= envLength[2] then -- 3549
			envStage = 2 -- 3551
			envTime = 0 -- 3552
		elseif envStage == 2 and envTime >= envLength[3] then -- 3552
			finished = true -- 3554
		end -- 3554
		local envVol = 0 -- 3556
		if envStage == 0 then -- 3556
			envVol = envTime / envLength[1] -- 3557
		elseif envStage == 1 then -- 3557
			envVol = 1 + (1 - envTime / envLength[2]) * 2 * p.punch -- 3558
		else -- 3558
			envVol = 1 - envTime / envLength[3] -- 3559
		end -- 3559
		fphase = fphase + fdsweep -- 3560
		iphase = math.floor(math.abs(fphase)) -- 3561
		if iphase > SFX_PHASER_SIZE - 1 then -- 3561
			iphase = SFX_PHASER_SIZE - 1 -- 3562
		end -- 3562
		flthp = flthp * flthpD -- 3563
		if flthp < 0 then -- 3563
			flthp = 0 -- 3564
		end -- 3564
		if flthp > 0.1 then -- 3564
			flthp = 0.1 -- 3565
		end -- 3565
		local sample = 0 -- 3566
		do -- 3566
			local subSampleIndex = 0 -- 3567
			while subSampleIndex < SFX_OVERSAMPLING do -- 3567
				phase = phase + 1 -- 3568
				if phase >= period then -- 3568
					phase = phase % period -- 3570
					if p.waveType == 3 then -- 3570
						do -- 3570
							local i = 0 -- 3572
							while i < SFX_NOISE_SIZE do -- 3572
								noiseBuffer[i + 1] = rng:next() * 2 - 1 -- 3572
								i = i + 1 -- 3572
							end -- 3572
						end -- 3572
					end -- 3572
				end -- 3572
				local cyclePos = phase / period -- 3575
				local subSample = 0 -- 3576
				if p.waveType == 0 then -- 3576
					subSample = cyclePos < squareDuty and 0.5 or -0.5 -- 3577
				elseif p.waveType == 1 then -- 3577
					subSample = 1 - cyclePos * 2 -- 3578
				elseif p.waveType == 2 then -- 3578
					subSample = math.sin(cyclePos * 2 * math.pi) -- 3579
				else -- 3579
					subSample = noiseBuffer[math.floor(cyclePos * SFX_NOISE_SIZE) + 1] -- 3580
				end -- 3580
				local prevFltp = fltp -- 3581
				fltw = fltw * fltwD -- 3582
				if fltw < 0 then -- 3582
					fltw = 0 -- 3583
				end -- 3583
				if fltw > 0.1 then -- 3583
					fltw = 0.1 -- 3584
				end -- 3584
				if p.lpCutoff >= 1 then -- 3584
					fltp = subSample -- 3586
					fltdp = 0 -- 3587
				else -- 3587
					fltdp = fltdp + (subSample - fltp) * fltw -- 3589
					fltdp = fltdp - fltdp * fltdmp -- 3590
					fltp = fltp + fltdp -- 3591
				end -- 3591
				fltphp = fltphp + (fltp - prevFltp) -- 3593
				fltphp = fltphp - fltphp * flthp -- 3594
				subSample = fltphp -- 3595
				if phaserOn then -- 3595
					phaserBuffer[ipp + 1] = subSample -- 3597
					subSample = subSample + phaserBuffer[(ipp - iphase + SFX_PHASER_SIZE) % SFX_PHASER_SIZE + 1] -- 3598
					ipp = (ipp + 1) % SFX_PHASER_SIZE -- 3599
				end -- 3599
				sample = sample + subSample * envVol -- 3601
				subSampleIndex = subSampleIndex + 1 -- 3567
			end -- 3567
		end -- 3567
		sample = sample / SFX_OVERSAMPLING -- 3603
		if sample > 1 then -- 3603
			sample = 1 -- 3604
		end -- 3604
		if sample < -1 then -- 3604
			sample = -1 -- 3605
		end -- 3605
		samples[#samples + 1] = sample * masterVolume -- 3606
	end -- 3606
	return samples -- 3608
end -- 3466
local function encodePcmWav(samples, sampleRate, rightSamples) -- 3611
	local channels = rightSamples and 2 or 1 -- 3612
	local dataSize = #samples * channels * 2 -- 3613
	local parts = {} -- 3614
	parts[#parts + 1] = string.pack("<c4I4c4", "RIFF", 36 + dataSize, "WAVE") -- 3615
	parts[#parts + 1] = string.pack( -- 3616
		"<c4I4I2I2I4I4I2I2", -- 3616
		"fmt ", -- 3616
		16, -- 3616
		1, -- 3616
		channels, -- 3616
		sampleRate, -- 3616
		sampleRate * channels * 2, -- 3616
		channels * 2, -- 3616
		16 -- 3616
	) -- 3616
	parts[#parts + 1] = string.pack("<c4I4", "data", dataSize) -- 3617
	do -- 3617
		local start = 0 -- 3618
		while start < #samples do -- 3618
			local ____end = math.min(start + SFX_WAV_PACK_CHUNK, #samples) -- 3619
			local fmt = "<" -- 3620
			local values = {} -- 3621
			do -- 3621
				local i = start -- 3622
				while i < ____end do -- 3622
					fmt = fmt .. "i2" -- 3623
					local left = samples[i + 1] -- 3624
					local leftRaw = left >= 0 and math.floor(left * 32767 + 0.5) or math.ceil(left * 32768 - 0.5) -- 3625
					values[#values + 1] = math.max( -- 3626
						-32768, -- 3626
						math.min(32767, leftRaw) -- 3626
					) -- 3626
					if rightSamples then -- 3626
						fmt = fmt .. "i2" -- 3628
						local right = rightSamples[i + 1] -- 3629
						local rightRaw = right >= 0 and math.floor(right * 32767 + 0.5) or math.ceil(right * 32768 - 0.5) -- 3630
						values[#values + 1] = math.max( -- 3631
							-32768, -- 3631
							math.min(32767, rightRaw) -- 3631
						) -- 3631
					end -- 3631
					i = i + 1 -- 3622
				end -- 3622
			end -- 3622
			parts[#parts + 1] = string.pack( -- 3634
				fmt, -- 3634
				table.unpack(values) -- 3634
			) -- 3634
			start = start + SFX_WAV_PACK_CHUNK -- 3618
		end -- 3618
	end -- 3618
	return table.concat(parts, "") -- 3636
end -- 3611
local sfxAutoSeedStep = 0 -- 3639
function ____exports.generateSfx(req) -- 3641
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3641
		local relPath = __TS__StringTrim(req.path or "") -- 3650
		if relPath == "" then -- 3650
			return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 3650
		end -- 3650
		if not __TS__StringEndsWith( -- 3650
			string.lower(relPath), -- 3654
			".wav" -- 3654
		) then -- 3654
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "generate_sfx writes WAV files; path must end in .wav"}) -- 3654
		end -- 3654
		local kind = string.lower(__TS__StringTrim(req.type or "")) -- 3657
		local validKinds = { -- 3658
			"jump", -- 3658
			"explosion", -- 3658
			"hit", -- 3658
			"pickup", -- 3658
			"laser", -- 3658
			"powerup", -- 3658
			"click", -- 3658
			"random" -- 3658
		} -- 3658
		if __TS__ArrayIndexOf(validKinds, kind) < 0 then -- 3658
			return ____awaiter_resolve( -- 3658
				nil, -- 3658
				{ -- 3660
					success = false, -- 3660
					path = relPath, -- 3660
					message = (("unknown type '" .. req.type) .. "'; expected one of: ") .. table.concat(validKinds, ", ") -- 3660
				} -- 3660
			) -- 3660
		end -- 3660
		local target = resolveWorkspaceFilePath(req.workDir, relPath) -- 3662
		if not target then -- 3662
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "invalid path"}) -- 3662
		end -- 3662
		if Content:exist(target) and Content:isdir(target) then -- 3662
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "target path is a directory"}) -- 3662
		end -- 3662
		local ____this_68 -- 3662
		____this_68 = req -- 3669
		local ____opt_67 = ____this_68.isCancelled -- 3669
		if (____opt_67 and ____opt_67(____this_68)) == true then -- 3669
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "canceled", interrupted = true}) -- 3669
		end -- 3669
		sfxAutoSeedStep = sfxAutoSeedStep + 1 -- 3672
		local seed = 0 -- 3673
		if type(req.seed) == "number" and req.seed == req.seed and math.abs(req.seed) < 2147483647 then -- 3673
			seed = math.floor(req.seed) -- 3675
		else -- 3675
			seed = os.time() % 1000000000 + sfxAutoSeedStep * 7919 -- 3677
		end -- 3677
		local volume = 0.8 -- 3679
		if type(req.volume) == "number" and req.volume == req.volume then -- 3679
			volume = math.min( -- 3681
				1, -- 3681
				math.max(0, req.volume) -- 3681
			) -- 3681
		end -- 3681
		local operationId = createOperationId() -- 3683
		local rng = createSfxRng(seed) -- 3684
		local presetKind = kind -- 3685
		if presetKind == "random" then -- 3685
			local families = { -- 3687
				"jump", -- 3687
				"explosion", -- 3687
				"hit", -- 3687
				"pickup", -- 3687
				"laser", -- 3687
				"powerup", -- 3687
				"click" -- 3687
			} -- 3687
			presetKind = families[math.floor(rng:next() * #families) + 1] -- 3688
		end -- 3688
		local ____this_70 -- 3688
		____this_70 = req -- 3690
		local ____opt_69 = ____this_70.onProgress -- 3690
		if ____opt_69 ~= nil then -- 3690
			____opt_69(____this_70, { -- 3690
				state = "running", -- 3691
				operationId = operationId, -- 3692
				path = relPath, -- 3693
				stage = "synth", -- 3694
				message = "synthesizing " .. presetKind -- 3695
			}) -- 3695
		end -- 3695
		local params = generateSfxrPreset(presetKind, rng) -- 3697
		local samples = synthSfxr(params, volume, rng) -- 3698
		if #samples == 0 then -- 3698
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "synthesis produced no samples"}) -- 3698
		end -- 3698
		local ____this_72 -- 3698
		____this_72 = req -- 3702
		local ____opt_71 = ____this_72.isCancelled -- 3702
		if (____opt_71 and ____opt_71(____this_72)) == true then -- 3702
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "canceled", interrupted = true}) -- 3702
		end -- 3702
		local ____this_74 -- 3702
		____this_74 = req -- 3705
		local ____opt_73 = ____this_74.onProgress -- 3705
		if ____opt_73 ~= nil then -- 3705
			____opt_73(____this_74, { -- 3705
				state = "running", -- 3706
				operationId = operationId, -- 3707
				path = relPath, -- 3708
				stage = "write", -- 3709
				message = "writing WAV" -- 3710
			}) -- 3710
		end -- 3710
		local wav = encodePcmWav(samples, SFX_SAMPLE_RATE) -- 3712
		if not ensureDirForFile(target) then -- 3712
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "failed to create target directory"}) -- 3712
		end -- 3712
		if not Content:save(target, wav) then -- 3712
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "failed to write WAV file"}) -- 3712
		end -- 3712
		if not syncDownloadedFileToWebIDE(target) then -- 3712
			Log("Warn", "[generate_sfx] failed to sync file update target=" .. target) -- 3720
		end -- 3720
		local durationSeconds = math.floor(#samples / SFX_SAMPLE_RATE * 100 + 0.5) / 100 -- 3722
		Log( -- 3723
			"Info", -- 3723
			(((((((("[generate_sfx] type=" .. presetKind) .. " seed=") .. tostring(seed)) .. " path=") .. relPath) .. " bytes=") .. tostring(#wav)) .. " samples=") .. tostring(#samples) -- 3723
		) -- 3723
		return ____awaiter_resolve( -- 3723
			nil, -- 3723
			{ -- 3724
				success = true, -- 3725
				path = relPath, -- 3726
				bytesWritten = #wav, -- 3727
				durationSeconds = durationSeconds, -- 3728
				sampleRate = SFX_SAMPLE_RATE, -- 3729
				seed = seed, -- 3730
				description = ((((((((((((("Saved a " .. presetKind) .. " sound effect to ") .. relPath) .. " (") .. tostring(#wav)) .. " bytes, ") .. tostring(durationSeconds)) .. "s, mono 16-bit ") .. tostring(SFX_SAMPLE_RATE)) .. " Hz, seed ") .. tostring(seed)) .. "). Play it with Audio.play(\"") .. relPath) .. "\") or an audio-source node; regenerate with a new seed or reproduce it with the same seed." -- 3731
			} -- 3731
		) -- 3731
	end) -- 3731
end -- 3641
local MUSIC_SAMPLE_RATE = 44100 -- 3855
local MUSIC_STEPS_PER_BAR = 16 -- 3856
local MUSIC_MIN_SECONDS = 4 -- 3857
local MUSIC_MAX_SECONDS = 32 -- 3858
local MUSIC_NOISE_SIZE = 2048 -- 3859
local MUSIC_RENDER_CHUNK = 8192 -- 3860
local MUSIC_KEY_NAMES = { -- 3861
	"C", -- 3861
	"C#", -- 3861
	"D", -- 3861
	"D#", -- 3861
	"E", -- 3861
	"F", -- 3861
	"F#", -- 3861
	"G", -- 3861
	"G#", -- 3861
	"A", -- 3861
	"A#", -- 3861
	"B" -- 3861
} -- 3861
local MUSIC_VALID_MODES = { -- 3862
	"major", -- 3862
	"minor", -- 3862
	"pentatonic", -- 3862
	"harmonic_minor", -- 3862
	"dorian", -- 3862
	"phrygian", -- 3862
	"chromatic" -- 3862
} -- 3862
local MUSIC_VALID_INSTRUMENTS = { -- 3863
	"square", -- 3863
	"pulse", -- 3863
	"saw", -- 3863
	"triangle", -- 3863
	"sine", -- 3863
	"organ", -- 3863
	"bell", -- 3863
	"pluck", -- 3863
	"fm", -- 3863
	"pad", -- 3863
	"sub", -- 3863
	"guitar", -- 3863
	"strings" -- 3863
} -- 3863
local function clamp01(value) -- 3865
	return math.min( -- 3866
		1, -- 3866
		math.max(0, value) -- 3866
	) -- 3866
end -- 3865
local function getMusicStyleConfig(style) -- 3869
	repeat -- 3869
		local ____switch754 = style -- 3869
		local ____cond754 = ____switch754 == "adventure" -- 3869
		if ____cond754 then -- 3869
			return { -- 3871
				bpm = 124, -- 3872
				mode = "major", -- 3872
				progression = {0, 3, 4, 0}, -- 3872
				melodyStepSpan = 2, -- 3872
				melodyDensity = 0.82, -- 3873
				leadInstrument = "strings", -- 3873
				bassInstrument = "triangle", -- 3873
				harmonyInstrument = "organ", -- 3873
				melodyMix = 0.28, -- 3874
				bassMix = 0.24, -- 3874
				harmonyMix = 0.15, -- 3874
				drumMix = 0.22, -- 3874
				hatStride = 2, -- 3874
				reverb = 0.16, -- 3875
				delay = 0.1, -- 3875
				chorus = 0.18, -- 3875
				distortion = 0.04 -- 3875
			} -- 3875
		end -- 3875
		____cond754 = ____cond754 or ____switch754 == "calm" -- 3875
		if ____cond754 then -- 3875
			return { -- 3877
				bpm = 84, -- 3878
				mode = "pentatonic", -- 3878
				progression = {0, 4, 3, 4}, -- 3878
				melodyStepSpan = 4, -- 3878
				melodyDensity = 0.72, -- 3879
				leadInstrument = "bell", -- 3879
				bassInstrument = "sub", -- 3879
				harmonyInstrument = "pad", -- 3879
				melodyMix = 0.3, -- 3880
				bassMix = 0.2, -- 3880
				harmonyMix = 0.18, -- 3880
				drumMix = 0.1, -- 3880
				hatStride = 4, -- 3880
				reverb = 0.34, -- 3881
				delay = 0.16, -- 3881
				chorus = 0.28, -- 3881
				distortion = 0 -- 3881
			} -- 3881
		end -- 3881
		____cond754 = ____cond754 or ____switch754 == "tense" -- 3881
		if ____cond754 then -- 3881
			return { -- 3883
				bpm = 152, -- 3884
				mode = "minor", -- 3884
				progression = {0, 5, 6, 4}, -- 3884
				melodyStepSpan = 2, -- 3884
				melodyDensity = 0.88, -- 3885
				leadInstrument = "saw", -- 3885
				bassInstrument = "saw", -- 3885
				harmonyInstrument = "pulse", -- 3885
				melodyMix = 0.24, -- 3886
				bassMix = 0.29, -- 3886
				harmonyMix = 0.15, -- 3886
				drumMix = 0.26, -- 3886
				hatStride = 1, -- 3886
				reverb = 0.1, -- 3887
				delay = 0.08, -- 3887
				chorus = 0.1, -- 3887
				distortion = 0.2 -- 3887
			} -- 3887
		end -- 3887
		____cond754 = ____cond754 or ____switch754 == "victory" -- 3887
		if ____cond754 then -- 3887
			return { -- 3889
				bpm = 148, -- 3890
				mode = "major", -- 3890
				progression = {0, 3, 4, 0}, -- 3890
				melodyStepSpan = 2, -- 3890
				melodyDensity = 0.92, -- 3891
				leadInstrument = "square", -- 3891
				bassInstrument = "triangle", -- 3891
				harmonyInstrument = "organ", -- 3891
				melodyMix = 0.31, -- 3892
				bassMix = 0.22, -- 3892
				harmonyMix = 0.18, -- 3892
				drumMix = 0.24, -- 3892
				hatStride = 2, -- 3892
				reverb = 0.22, -- 3893
				delay = 0.12, -- 3893
				chorus = 0.16, -- 3893
				distortion = 0.04 -- 3893
			} -- 3893
		end -- 3893
		do -- 3893
			return { -- 3895
				bpm = 138, -- 3896
				mode = "major", -- 3896
				progression = {0, 4, 5, 3}, -- 3896
				melodyStepSpan = 2, -- 3896
				melodyDensity = 0.86, -- 3897
				leadInstrument = "square", -- 3897
				bassInstrument = "saw", -- 3897
				harmonyInstrument = "pulse", -- 3897
				melodyMix = 0.28, -- 3898
				bassMix = 0.25, -- 3898
				harmonyMix = 0.16, -- 3898
				drumMix = 0.22, -- 3898
				hatStride = 2, -- 3898
				reverb = 0.1, -- 3899
				delay = 0.08, -- 3899
				chorus = 0.12, -- 3899
				distortion = 0.06 -- 3899
			} -- 3899
		end -- 3899
	until true -- 3899
end -- 3869
local function musicScale(mode) -- 3904
	if mode == "minor" then -- 3904
		return { -- 3905
			0, -- 3905
			2, -- 3905
			3, -- 3905
			5, -- 3905
			7, -- 3905
			8, -- 3905
			10 -- 3905
		} -- 3905
	end -- 3905
	if mode == "pentatonic" then -- 3905
		return { -- 3906
			0, -- 3906
			2, -- 3906
			4, -- 3906
			7, -- 3906
			9 -- 3906
		} -- 3906
	end -- 3906
	if mode == "harmonic_minor" then -- 3906
		return { -- 3907
			0, -- 3907
			2, -- 3907
			3, -- 3907
			5, -- 3907
			7, -- 3907
			8, -- 3907
			11 -- 3907
		} -- 3907
	end -- 3907
	if mode == "dorian" then -- 3907
		return { -- 3908
			0, -- 3908
			2, -- 3908
			3, -- 3908
			5, -- 3908
			7, -- 3908
			9, -- 3908
			10 -- 3908
		} -- 3908
	end -- 3908
	if mode == "phrygian" then -- 3908
		return { -- 3909
			0, -- 3909
			1, -- 3909
			3, -- 3909
			5, -- 3909
			7, -- 3909
			8, -- 3909
			10 -- 3909
		} -- 3909
	end -- 3909
	if mode == "chromatic" then -- 3909
		return { -- 3910
			0, -- 3910
			1, -- 3910
			2, -- 3910
			3, -- 3910
			4, -- 3910
			5, -- 3910
			6, -- 3910
			7, -- 3910
			8, -- 3910
			9, -- 3910
			10, -- 3910
			11 -- 3910
		} -- 3910
	end -- 3910
	return { -- 3911
		0, -- 3911
		2, -- 3911
		4, -- 3911
		5, -- 3911
		7, -- 3911
		9, -- 3911
		11 -- 3911
	} -- 3911
end -- 3904
local function musicScaleNote(root, scale, degree) -- 3914
	local octave = math.floor(degree / #scale) -- 3915
	local index = degree % #scale -- 3916
	return root + octave * 12 + scale[index + 1] -- 3917
end -- 3914
local function parseRomanDegree(token) -- 3920
	local normalized = __TS__StringTrim(token) -- 3921
	while __TS__StringStartsWith(normalized, "b") or __TS__StringStartsWith(normalized, "#") do -- 3921
		normalized = string.sub(normalized, 2) -- 3922
	end -- 3922
	normalized = string.upper(normalized) -- 3923
	if normalized == "I" then -- 3923
		return 0 -- 3924
	end -- 3924
	if normalized == "II" then -- 3924
		return 1 -- 3925
	end -- 3925
	if normalized == "III" then -- 3925
		return 2 -- 3926
	end -- 3926
	if normalized == "IV" then -- 3926
		return 3 -- 3927
	end -- 3927
	if normalized == "V" then -- 3927
		return 4 -- 3928
	end -- 3928
	if normalized == "VI" then -- 3928
		return 5 -- 3929
	end -- 3929
	if normalized == "VII" then -- 3929
		return 6 -- 3930
	end -- 3930
	return nil -- 3931
end -- 3920
local function parseMusicProgression(text, fallback) -- 3934
	local normalized = __TS__StringTrim(text or "") -- 3935
	if normalized == "" then -- 3935
		return { -- 3936
			degrees = __TS__ArraySlice(fallback), -- 3936
			text = table.concat( -- 3936
				__TS__ArrayMap( -- 3936
					fallback, -- 3936
					function(____, value) return tostring(value) end -- 3936
				), -- 3936
				"," -- 3936
			) -- 3936
		} -- 3936
	end -- 3936
	local tokens = __TS__StringSplit(normalized, ",") -- 3937
	local degrees = {} -- 3938
	do -- 3938
		local i = 0 -- 3939
		while i < #tokens do -- 3939
			local degree = parseRomanDegree(tokens[i + 1]) -- 3940
			if degree == nil then -- 3940
				return { -- 3941
					degrees = __TS__ArraySlice(fallback), -- 3941
					text = table.concat( -- 3941
						__TS__ArrayMap( -- 3941
							fallback, -- 3941
							function(____, value) return tostring(value) end -- 3941
						), -- 3941
						"," -- 3941
					) -- 3941
				} -- 3941
			end -- 3941
			degrees[#degrees + 1] = degree -- 3942
			i = i + 1 -- 3939
		end -- 3939
	end -- 3939
	return #degrees > 0 and ({degrees = degrees, text = normalized}) or ({ -- 3944
		degrees = __TS__ArraySlice(fallback), -- 3944
		text = table.concat( -- 3944
			__TS__ArrayMap( -- 3944
				fallback, -- 3944
				function(____, value) return tostring(value) end -- 3944
			), -- 3944
			"," -- 3944
		) -- 3944
	}) -- 3944
end -- 3934
local function parseMusicStructure(text) -- 3947
	local tokens = __TS__StringSplit(text or "A,A,B,A", ",") -- 3948
	local result = {} -- 3949
	do -- 3949
		local i = 0 -- 3950
		while i < #tokens and #result < 8 do -- 3950
			local label = string.upper(__TS__StringTrim(tokens[i + 1])) -- 3951
			if label ~= "" then -- 3951
				result[#result + 1] = string.sub(label, 1, 8) -- 3952
			end -- 3952
			i = i + 1 -- 3950
		end -- 3950
	end -- 3950
	return #result > 0 and result or ({"A"}) -- 3954
end -- 3947
local function resolveMusicInstrument(value, fallback) -- 3957
	local normalized = string.lower(__TS__StringTrim(value or "auto")) -- 3958
	return __TS__ArrayIndexOf(MUSIC_VALID_INSTRUMENTS, normalized) >= 0 and normalized or fallback -- 3959
end -- 3957
local function fillMusicNote(notes, ages, start, span, note) -- 3962
	local ____end = math.min(start + span, #notes) -- 3963
	do -- 3963
		local i = start -- 3964
		while i < ____end do -- 3964
			notes[i + 1] = note -- 3965
			ages[i + 1] = i - start -- 3966
			i = i + 1 -- 3964
		end -- 3964
	end -- 3964
end -- 3962
local function sectionSeed(seed, label, barInSection, variation) -- 3970
	local hash = 0 -- 3971
	do -- 3971
		local i = 0 -- 3972
		while i < #label do -- 3972
			hash = (hash * 31 + __TS__StringCharCodeAt(label, i)) % 2147483647 -- 3972
			i = i + 1 -- 3972
		end -- 3972
	end -- 3972
	return seed + hash * 131 + barInSection * 104729 + math.floor(variation * 10000) * 8191 -- 3973
end -- 3970
local function createMusicArrangement(options, bars, seedOffset) -- 3976
	if seedOffset == nil then -- 3976
		seedOffset = 0 -- 3976
	end -- 3976
	local totalSteps = bars * MUSIC_STEPS_PER_BAR -- 3977
	local melodyNotes = {} -- 3978
	local melodyAges = {} -- 3979
	local bassNotes = {} -- 3980
	local bassAges = {} -- 3981
	local arpNotes = {} -- 3982
	local chordRoots = {} -- 3983
	local rootNote = 48 + options.rootPitchClass -- 3984
	do -- 3984
		local i = 0 -- 3985
		while i < totalSteps do -- 3985
			melodyNotes[#melodyNotes + 1] = -1 -- 3986
			melodyAges[#melodyAges + 1] = 0 -- 3986
			bassNotes[#bassNotes + 1] = -1 -- 3986
			bassAges[#bassAges + 1] = 0 -- 3986
			arpNotes[#arpNotes + 1] = -1 -- 3987
			chordRoots[#chordRoots + 1] = rootNote -- 3987
			i = i + 1 -- 3985
		end -- 3985
	end -- 3985
	local scale = musicScale(options.mode) -- 3989
	local styleConfig = getMusicStyleConfig(options.style) -- 3990
	local chordToneChoices = {0, 2, 4, 7} -- 3991
	local melodySpan = options.rhythmComplexity > 0.72 and 1 or styleConfig.melodyStepSpan -- 3992
	local density = clamp01(styleConfig.melodyDensity * (0.55 + options.melodyComplexity * 0.65)) -- 3993
	do -- 3993
		local bar = 0 -- 3994
		while bar < bars do -- 3994
			local sectionIndex = math.floor(bar / options.barsPerSection) % #options.structure -- 3995
			local sectionLabel = options.structure[sectionIndex + 1] -- 3996
			local barInSection = bar % options.barsPerSection -- 3997
			local localRng = createSfxRng(sectionSeed(options.seed + seedOffset, sectionLabel, barInSection, options.variation)) -- 3998
			local sectionOffset = math.max( -- 3999
				0, -- 3999
				(string.byte(sectionLabel, 1) or 0 / 0) - 65 -- 3999
			) -- 3999
			local progressionIndex = (barInSection + sectionOffset) % #options.progression -- 4000
			local chordDegree = options.progression[progressionIndex + 1] -- 4001
			local chordRoot = musicScaleNote(rootNote, scale, chordDegree) -- 4002
			local barStart = bar * MUSIC_STEPS_PER_BAR -- 4003
			do -- 4003
				local localStep = 0 -- 4004
				while localStep < MUSIC_STEPS_PER_BAR do -- 4004
					local step = barStart + localStep -- 4005
					chordRoots[step + 1] = chordRoot -- 4006
					if options.intensity > 0.25 or localStep % 2 == 0 then -- 4006
						local arpTone = ({0, 2, 4, 2})[localStep % 4 + 1] -- 4008
						arpNotes[step + 1] = musicScaleNote(rootNote + 12, scale, chordDegree + arpTone) -- 4009
					end -- 4009
					localStep = localStep + 1 -- 4004
				end -- 4004
			end -- 4004
			do -- 4004
				local localStep = 0 -- 4012
				while localStep < MUSIC_STEPS_PER_BAR do -- 4012
					local step = barStart + localStep -- 4013
					local movingBass = options.intensity > 0.58 and localStep == 12 -- 4014
					local bassDegree = chordDegree + (movingBass and 4 or 0) -- 4015
					fillMusicNote( -- 4016
						bassNotes, -- 4016
						bassAges, -- 4016
						step, -- 4016
						4, -- 4016
						musicScaleNote(rootNote - 12, scale, bassDegree) -- 4016
					) -- 4016
					localStep = localStep + 4 -- 4012
				end -- 4012
			end -- 4012
			do -- 4012
				local localStep = 0 -- 4018
				while localStep < MUSIC_STEPS_PER_BAR do -- 4018
					do -- 4018
						if localRng:next() > density then -- 4018
							goto __continue802 -- 4019
						end -- 4019
						local step = barStart + localStep -- 4020
						local choice = chordToneChoices[math.floor(localRng:next() * #chordToneChoices) + 1] -- 4021
						if options.melodyComplexity > 0.65 and localRng:next() < options.melodyComplexity * 0.35 then -- 4021
							choice = choice + 1 -- 4022
						end -- 4022
						local note = musicScaleNote(rootNote + 12, scale, chordDegree + choice) -- 4023
						if localRng:next() < options.melodyComplexity * 0.3 then -- 4023
							note = note + 12 -- 4024
						end -- 4024
						if options.variation > 0 and sectionLabel ~= "A" and localRng:next() < options.variation * 0.5 then -- 4024
							note = note + scale[2] -- 4025
						end -- 4025
						fillMusicNote( -- 4026
							melodyNotes, -- 4026
							melodyAges, -- 4026
							step, -- 4026
							melodySpan, -- 4026
							note -- 4026
						) -- 4026
					end -- 4026
					::__continue802:: -- 4026
					localStep = localStep + melodySpan -- 4018
				end -- 4018
			end -- 4018
			bar = bar + 1 -- 3994
		end -- 3994
	end -- 3994
	return { -- 4029
		melodyNotes = melodyNotes, -- 4029
		melodyAges = melodyAges, -- 4029
		bassNotes = bassNotes, -- 4029
		bassAges = bassAges, -- 4029
		arpNotes = arpNotes, -- 4029
		chordRoots = chordRoots -- 4029
	} -- 4029
end -- 3976
local function musicFrequency(note) -- 4032
	return 440 * 2 ^ ((note - 69) / 12) -- 4033
end -- 4032
local function musicWave(phase, instrument) -- 4036
	if instrument == "square" then -- 4036
		return phase < 0.5 and 0.7 or -0.7 -- 4037
	end -- 4037
	if instrument == "pulse" then -- 4037
		return phase < 0.25 and 0.75 or -0.45 -- 4038
	end -- 4038
	if instrument == "saw" then -- 4038
		return 1 - phase * 2 -- 4039
	end -- 4039
	if instrument == "triangle" or instrument == "pluck" then -- 4039
		return phase < 0.5 and phase * 4 - 1 or 3 - phase * 4 -- 4040
	end -- 4040
	if instrument == "organ" then -- 4040
		return math.sin(phase * 2 * math.pi) * 0.72 + math.sin(phase * 6 * math.pi) * 0.28 -- 4041
	end -- 4041
	if instrument == "bell" then -- 4041
		return math.sin(phase * 2 * math.pi) * 0.68 + math.sin(phase * 8 * math.pi) * 0.32 -- 4042
	end -- 4042
	if instrument == "fm" then -- 4042
		return math.sin(phase * 2 * math.pi + math.sin(phase * 6 * math.pi) * 2.2) -- 4043
	end -- 4043
	if instrument == "pad" then -- 4043
		return math.sin(phase * 2 * math.pi) * 0.65 + (phase < 0.5 and phase * 4 - 1 or 3 - phase * 4) * 0.35 -- 4044
	end -- 4044
	if instrument == "sub" then -- 4044
		return math.sin(phase * 2 * math.pi) * 0.85 + math.sin(phase * 4 * math.pi) * 0.15 -- 4045
	end -- 4045
	if instrument == "guitar" then -- 4045
		return (phase < 0.5 and phase * 4 - 1 or 3 - phase * 4) * 0.72 + math.sin(phase * 6 * math.pi) * 0.28 -- 4046
	end -- 4046
	if instrument == "strings" then -- 4046
		return (1 - phase * 2) * 0.55 + math.sin(phase * 2 * math.pi) * 0.45 -- 4047
	end -- 4047
	return math.sin(phase * 2 * math.pi) -- 4048
end -- 4036
local function musicEnvelope(time, length, attack, release, instrument) -- 4051
	if time < 0 or time >= length then -- 4051
		return 0 -- 4052
	end -- 4052
	local value = 1 -- 4053
	if time < attack then -- 4053
		value = time / attack -- 4054
	end -- 4054
	local remaining = length - time -- 4055
	if remaining < release then -- 4055
		value = value * (remaining / release) -- 4056
	end -- 4056
	if instrument == "pluck" or instrument == "bell" or instrument == "guitar" then -- 4056
		value = value * (1 / (1 + time * (instrument == "bell" and 3.5 or 8))) -- 4057
	end -- 4057
	return clamp01(value) -- 4058
end -- 4051
local function createStereoSamples(stereo) -- 4061
	return stereo and ({left = {}, right = {}}) or ({left = {}}) -- 4062
end -- 4061
local function pushStereo(samples, left, right) -- 4065
	if samples.right then -- 4065
		local ____samples_left_75 = samples.left -- 4065
		____samples_left_75[#____samples_left_75 + 1] = left -- 4067
		local ____samples_right_76 = samples.right -- 4067
		____samples_right_76[#____samples_right_76 + 1] = right -- 4068
	else -- 4068
		local ____samples_left_77 = samples.left -- 4068
		____samples_left_77[#____samples_left_77 + 1] = (left + right) * 0.5 -- 4070
	end -- 4070
end -- 4065
local function yieldMusicFrame() -- 4074
	return __TS__New( -- 4075
		__TS__Promise, -- 4075
		function(____, resolve) -- 4075
			Director.systemScheduler:schedule(once(function() return resolve(nil) end)) -- 4076
		end -- 4075
	) -- 4075
end -- 4074
local function synthMusic(options, arrangement, bars, renderKind, captureStems, onProgress, isCancelled) -- 4080
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4080
		local stepSeconds = 60 / options.bpm / 4 -- 4089
		local durationSeconds = bars * MUSIC_STEPS_PER_BAR * stepSeconds -- 4090
		local totalSamples = math.floor(durationSeconds * MUSIC_SAMPLE_RATE) -- 4091
		local mix = createStereoSamples(options.stereo) -- 4092
		local stems = captureStems and ({ -- 4093
			melody = createStereoSamples(options.stereo), -- 4094
			bass = createStereoSamples(options.stereo), -- 4094
			harmony = createStereoSamples(options.stereo), -- 4095
			drums = createStereoSamples(options.stereo) -- 4095
		}) or nil -- 4095
		local noiseRng = createSfxRng(options.seed + bars * 65537 + (renderKind == "loop" and 1 or 17)) -- 4097
		local noise = {} -- 4098
		do -- 4098
			local i = 0 -- 4099
			while i < MUSIC_NOISE_SIZE do -- 4099
				noise[#noise + 1] = noiseRng:next() * 2 - 1 -- 4099
				i = i + 1 -- 4099
			end -- 4099
		end -- 4099
		local melodyPhase = 0 -- 4100
		local bassPhase = 0 -- 4100
		local arpPhase = 0 -- 4100
		local padPhase = 0 -- 4100
		local filteredLeft = 0 -- 4101
		local filteredRight = 0 -- 4101
		local peak = 0 -- 4102
		local clippingSamples = 0 -- 4102
		local fadeSamples = math.max( -- 4103
			1, -- 4103
			math.floor(MUSIC_SAMPLE_RATE * 0.008) -- 4103
		) -- 4103
		local delayFrames = math.max( -- 4104
			1, -- 4104
			math.floor(MUSIC_SAMPLE_RATE * 60 / options.bpm * 0.5) -- 4104
		) -- 4104
		local reverbFrames = math.max( -- 4105
			1, -- 4105
			math.floor(MUSIC_SAMPLE_RATE * 0.073) -- 4105
		) -- 4105
		local delayLeft = {} -- 4106
		local delayRight = {} -- 4106
		local reverbLeft = {} -- 4106
		local reverbRight = {} -- 4106
		do -- 4106
			local i = 0 -- 4107
			while i < delayFrames do -- 4107
				delayLeft[#delayLeft + 1] = 0 -- 4107
				delayRight[#delayRight + 1] = 0 -- 4107
				i = i + 1 -- 4107
			end -- 4107
		end -- 4107
		do -- 4107
			local i = 0 -- 4108
			while i < reverbFrames do -- 4108
				reverbLeft[#reverbLeft + 1] = 0 -- 4108
				reverbRight[#reverbRight + 1] = 0 -- 4108
				i = i + 1 -- 4108
			end -- 4108
		end -- 4108
		do -- 4108
			local sampleIndex = 0 -- 4109
			while sampleIndex < totalSamples do -- 4109
				if sampleIndex % MUSIC_RENDER_CHUNK == 0 then -- 4109
					if (isCancelled and isCancelled()) == true then -- 4109
						return ____awaiter_resolve(nil, nil) -- 4109
					end -- 4109
					if onProgress ~= nil then -- 4109
						onProgress(math.floor(sampleIndex / totalSamples * 100)) -- 4112
					end -- 4112
					if sampleIndex > 0 then -- 4112
						__TS__Await(yieldMusicFrame()) -- 4113
					end -- 4113
				end -- 4113
				local time = sampleIndex / MUSIC_SAMPLE_RATE -- 4115
				local stepFloat = time / stepSeconds -- 4116
				local stepIndex = math.min( -- 4117
					#arrangement.melodyNotes - 1, -- 4117
					math.floor(stepFloat) -- 4117
				) -- 4117
				local stepTime = (stepFloat - stepIndex) * stepSeconds -- 4118
				local melody = 0 -- 4119
				local bass = 0 -- 4119
				local harmony = 0 -- 4119
				local drums = 0 -- 4119
				local melodyNote = arrangement.melodyNotes[stepIndex + 1] -- 4120
				if melodyNote >= 0 then -- 4120
					melodyPhase = (melodyPhase + musicFrequency(melodyNote) / MUSIC_SAMPLE_RATE) % 1 -- 4122
					local noteTime = arrangement.melodyAges[stepIndex + 1] * stepSeconds + stepTime -- 4123
					local span = options.rhythmComplexity > 0.72 and 1 or getMusicStyleConfig(options.style).melodyStepSpan -- 4124
					local noteLength = span * stepSeconds * (0.72 + options.rhythmComplexity * 0.22) -- 4125
					local env = musicEnvelope( -- 4126
						noteTime, -- 4126
						noteLength, -- 4126
						0.004, -- 4126
						math.min(0.05, noteLength * 0.3), -- 4126
						options.leadInstrument -- 4126
					) -- 4126
					melody = musicWave(melodyPhase, options.leadInstrument) * env * getMusicStyleConfig(options.style).melodyMix -- 4127
				end -- 4127
				local bassNote = arrangement.bassNotes[stepIndex + 1] -- 4129
				if bassNote >= 0 then -- 4129
					bassPhase = (bassPhase + musicFrequency(bassNote) / MUSIC_SAMPLE_RATE) % 1 -- 4131
					local noteTime = arrangement.bassAges[stepIndex + 1] * stepSeconds + stepTime -- 4132
					local env = musicEnvelope( -- 4133
						noteTime, -- 4133
						stepSeconds * 3.75, -- 4133
						0.008, -- 4133
						0.08, -- 4133
						options.bassInstrument -- 4133
					) -- 4133
					bass = musicWave(bassPhase, options.bassInstrument) * env * getMusicStyleConfig(options.style).bassMix -- 4134
				end -- 4134
				local arpNote = arrangement.arpNotes[stepIndex + 1] -- 4136
				if arpNote >= 0 then -- 4136
					arpPhase = (arpPhase + musicFrequency(arpNote) / MUSIC_SAMPLE_RATE) % 1 -- 4138
					local arpEnv = musicEnvelope( -- 4139
						stepTime, -- 4139
						stepSeconds * 0.72, -- 4139
						0.003, -- 4139
						math.min(0.035, stepSeconds * 0.25), -- 4139
						options.harmonyInstrument -- 4139
					) -- 4139
					harmony = harmony + musicWave(arpPhase, options.harmonyInstrument) * arpEnv * getMusicStyleConfig(options.style).harmonyMix -- 4140
				end -- 4140
				local padNote = arrangement.chordRoots[stepIndex + 1] + 12 -- 4142
				padPhase = (padPhase + musicFrequency(padNote) / MUSIC_SAMPLE_RATE) % 1 -- 4143
				harmony = harmony + musicWave(padPhase, options.harmonyInstrument) * (options.style == "calm" and 0.1 or 0.035) -- 4144
				local localStep = stepIndex % MUSIC_STEPS_PER_BAR -- 4145
				local noiseSample = noise[sampleIndex % MUSIC_NOISE_SIZE + 1] -- 4146
				local previousNoise = noise[(sampleIndex + MUSIC_NOISE_SIZE - 1) % MUSIC_NOISE_SIZE + 1] -- 4147
				local drumConfig = getMusicStyleConfig(options.style) -- 4148
				local ____temp_82 -- 4149
				if options.intensity > 0.78 then -- 4149
					____temp_82 = localStep % 4 == 0 -- 4149
				else -- 4149
					____temp_82 = localStep == 0 or localStep == 8 -- 4149
				end -- 4149
				local kickOn = ____temp_82 -- 4149
				local kickDecay = 0 -- 4150
				if kickOn then -- 4150
					local kickLength = math.min(stepSeconds, 0.16) -- 4152
					if stepTime < kickLength then -- 4152
						kickDecay = 1 - stepTime / kickLength -- 4154
						drums = drums + math.sin(2 * math.pi * (58 + 82 * kickDecay) * stepTime) * kickDecay * kickDecay * drumConfig.drumMix -- 4155
					end -- 4155
				end -- 4155
				if localStep == 4 or localStep == 12 then -- 4155
					local snareLength = math.min(stepSeconds, 0.13) -- 4159
					if stepTime < snareLength then -- 4159
						local decay = 1 - stepTime / snareLength -- 4161
						drums = drums + (noiseSample * 0.78 + math.sin(2 * math.pi * 180 * stepTime) * 0.22) * decay * drumConfig.drumMix * 0.68 -- 4162
						if options.intensity > 0.62 then -- 4162
							local clapPhase = stepTime * 38 % 1 -- 4164
							drums = drums + noiseSample * (clapPhase < 0.22 and 1 or 0) * decay * drumConfig.drumMix * 0.24 -- 4165
						end -- 4165
					end -- 4165
				end -- 4165
				local hatStride = options.rhythmComplexity > 0.7 and 1 or drumConfig.hatStride -- 4169
				if localStep % hatStride == 0 then -- 4169
					local hatLength = math.min(stepSeconds, 0.045) -- 4171
					if stepTime < hatLength then -- 4171
						drums = drums + (noiseSample - previousNoise) * (1 - stepTime / hatLength) * drumConfig.drumMix * 0.18 -- 4172
					end -- 4172
				end -- 4172
				if localStep == 14 and options.intensity > 0.48 then -- 4172
					local openHatLength = math.min(stepSeconds, 0.12) -- 4175
					if stepTime < openHatLength then -- 4175
						drums = drums + (noiseSample - previousNoise) * (1 - stepTime / openHatLength) * drumConfig.drumMix * 0.15 -- 4176
					end -- 4176
				end -- 4176
				if localStep % 4 == 2 and options.intensity > 0.82 then -- 4176
					local rideLength = math.min(stepSeconds, 0.08) -- 4179
					if stepTime < rideLength then -- 4179
						drums = drums + math.sin(2 * math.pi * 1800 * stepTime) * (1 - stepTime / rideLength) * drumConfig.drumMix * 0.09 -- 4180
					end -- 4180
				end -- 4180
				if localStep >= 13 and options.rhythmComplexity > 0.68 then -- 4180
					local tomLength = math.min(stepSeconds, 0.1) -- 4183
					if stepTime < tomLength then -- 4183
						local tomDecay = 1 - stepTime / tomLength -- 4185
						local tomFrequency = 150 - (localStep - 13) * 24 -- 4186
						drums = drums + math.sin(2 * math.pi * tomFrequency * stepTime) * tomDecay * drumConfig.drumMix * 0.26 -- 4187
					end -- 4187
				end -- 4187
				local sectionStep = stepIndex % (options.barsPerSection * MUSIC_STEPS_PER_BAR) -- 4190
				local sectionTime = sectionStep * stepSeconds + stepTime -- 4191
				if sectionTime < 0.32 and options.intensity > 0.72 then -- 4191
					drums = drums + (noiseSample - previousNoise * 0.5) * (1 - sectionTime / 0.32) * drumConfig.drumMix * 0.16 -- 4193
				end -- 4193
				local duck = 1 - kickDecay * options.intensity * 0.24 -- 4195
				melody = melody * (duck * (0.72 + options.intensity * 0.42)) -- 4196
				bass = bass * (0.65 + options.intensity * 0.55) -- 4197
				harmony = harmony * (duck * (0.5 + options.intensity * 0.62)) -- 4198
				drums = drums * (0.32 + options.intensity * 0.85) -- 4199
				local chorusPan = math.sin(time * 2 * math.pi * 0.35) * options.chorus * 0.18 -- 4200
				local melodyLeft = melody * (0.82 - chorusPan) -- 4201
				local melodyRight = melody * (1.18 + chorusPan) -- 4201
				local bassLeft = bass -- 4202
				local bassRight = bass -- 4202
				local harmonyLeft = harmony * (1.18 + chorusPan) -- 4203
				local harmonyRight = harmony * (0.82 - chorusPan) -- 4203
				local drumsLeft = drums * 1.02 -- 4204
				local drumsRight = drums * 0.98 -- 4204
				local left = melodyLeft + bassLeft + harmonyLeft + drumsLeft -- 4205
				local right = melodyRight + bassRight + harmonyRight + drumsRight -- 4206
				local delayPos = sampleIndex % delayFrames -- 4207
				local reverbPos = sampleIndex % reverbFrames -- 4208
				local delayedL = delayLeft[delayPos + 1] -- 4209
				local delayedR = delayRight[delayPos + 1] -- 4209
				local reverbedL = reverbLeft[reverbPos + 1] -- 4210
				local reverbedR = reverbRight[reverbPos + 1] -- 4210
				delayLeft[delayPos + 1] = left + delayedR * 0.34 -- 4211
				delayRight[delayPos + 1] = right + delayedL * 0.34 -- 4212
				reverbLeft[reverbPos + 1] = left + reverbedR * 0.42 -- 4213
				reverbRight[reverbPos + 1] = right + reverbedL * 0.42 -- 4214
				left = left + (delayedL * options.delay + reverbedL * options.reverb * 0.45) -- 4215
				right = right + (delayedR * options.delay + reverbedR * options.reverb * 0.45) -- 4216
				if options.lowPass > 0 then -- 4216
					local filterRate = 1 - options.lowPass * 0.94 -- 4218
					filteredLeft = filteredLeft + (left - filteredLeft) * filterRate -- 4219
					filteredRight = filteredRight + (right - filteredRight) * filterRate -- 4220
					left = filteredLeft -- 4221
					right = filteredRight -- 4222
				else -- 4222
					filteredLeft = left -- 4224
					filteredRight = right -- 4225
				end -- 4225
				local drive = 1 + options.distortion * 5 -- 4227
				left = left * drive / (1 + math.abs(left) * drive * 0.58) -- 4228
				right = right * drive / (1 + math.abs(right) * drive * 0.58) -- 4229
				if options.bitCrush > 0 then -- 4229
					local bits = math.max( -- 4231
						4, -- 4231
						16 - math.floor(options.bitCrush * 12) -- 4231
					) -- 4231
					local levels = 2 ^ (bits - 1) -- 4232
					left = math.floor(left * levels + 0.5) / levels -- 4233
					right = math.floor(right * levels + 0.5) / levels -- 4234
				end -- 4234
				local edgeFade = 1 -- 4236
				if sampleIndex < fadeSamples then -- 4236
					edgeFade = sampleIndex / fadeSamples -- 4237
				end -- 4237
				if sampleIndex >= totalSamples - fadeSamples then -- 4237
					edgeFade = (totalSamples - 1 - sampleIndex) / fadeSamples -- 4238
				end -- 4238
				left = left * (options.volume * edgeFade * 0.72) -- 4239
				right = right * (options.volume * edgeFade * 0.72) -- 4240
				peak = math.max( -- 4241
					peak, -- 4241
					math.abs(left), -- 4241
					math.abs(right) -- 4241
				) -- 4241
				if math.abs(left) > 1 or math.abs(right) > 1 then -- 4241
					clippingSamples = clippingSamples + 1 -- 4242
				end -- 4242
				left = math.max( -- 4243
					-1, -- 4243
					math.min(1, left) -- 4243
				) -- 4243
				right = math.max( -- 4244
					-1, -- 4244
					math.min(1, right) -- 4244
				) -- 4244
				pushStereo(mix, left, right) -- 4245
				if stems then -- 4245
					local stemGain = options.volume * edgeFade * 0.72 -- 4247
					pushStereo(stems.melody, melodyLeft * stemGain, melodyRight * stemGain) -- 4248
					pushStereo(stems.bass, bassLeft * stemGain, bassRight * stemGain) -- 4249
					pushStereo(stems.harmony, harmonyLeft * stemGain, harmonyRight * stemGain) -- 4250
					pushStereo(stems.drums, drumsLeft * stemGain, drumsRight * stemGain) -- 4251
				end -- 4251
				sampleIndex = sampleIndex + 1 -- 4109
			end -- 4109
		end -- 4109
		if onProgress ~= nil then -- 4109
			onProgress(100) -- 4254
		end -- 4254
		return ____awaiter_resolve(nil, {mix = mix, peak = peak, clippingSamples = clippingSamples, stems = stems}) -- 4254
	end) -- 4254
end -- 4080
local function encodeMusicMidi(arrangement, options) -- 4258
	local events = {} -- 4260
	local stepTicks = 120 -- 4261
	local function addNote(tick, duration, channel, note, velocity) -- 4262
		events[#events + 1] = { -- 4263
			tick = tick, -- 4263
			order = 1, -- 4263
			data = string.char(144 + channel, note, velocity) -- 4263
		} -- 4263
		events[#events + 1] = { -- 4264
			tick = tick + duration, -- 4264
			order = 0, -- 4264
			data = string.char(128 + channel, note, 0) -- 4264
		} -- 4264
	end -- 4262
	local function addSustainedVoice(notes, ages, channel, velocity) -- 4266
		do -- 4266
			local step = 0 -- 4267
			while step < #notes do -- 4267
				do -- 4267
					if notes[step + 1] < 0 or ages[step + 1] ~= 0 then -- 4267
						goto __continue872 -- 4268
					end -- 4268
					local span = 1 -- 4269
					while step + span < #notes and notes[step + span + 1] == notes[step + 1] and ages[step + span + 1] == span do -- 4269
						span = span + 1 -- 4270
					end -- 4270
					addNote( -- 4271
						step * stepTicks, -- 4271
						span * stepTicks, -- 4271
						channel, -- 4271
						notes[step + 1], -- 4271
						velocity -- 4271
					) -- 4271
				end -- 4271
				::__continue872:: -- 4271
				step = step + 1 -- 4267
			end -- 4267
		end -- 4267
	end -- 4266
	addSustainedVoice(arrangement.melodyNotes, arrangement.melodyAges, 0, 92) -- 4274
	addSustainedVoice(arrangement.bassNotes, arrangement.bassAges, 1, 84) -- 4275
	do -- 4275
		local step = 0 -- 4276
		while step < #arrangement.arpNotes do -- 4276
			if arrangement.arpNotes[step + 1] >= 0 then -- 4276
				addNote( -- 4277
					step * stepTicks, -- 4277
					math.floor(stepTicks * 0.72), -- 4277
					2, -- 4277
					arrangement.arpNotes[step + 1], -- 4277
					66 -- 4277
				) -- 4277
			end -- 4277
			local localStep = step % MUSIC_STEPS_PER_BAR -- 4278
			if localStep == 0 or localStep == 8 then -- 4278
				addNote( -- 4279
					step * stepTicks, -- 4279
					60, -- 4279
					9, -- 4279
					36, -- 4279
					100 -- 4279
				) -- 4279
			end -- 4279
			if localStep == 4 or localStep == 12 then -- 4279
				addNote( -- 4281
					step * stepTicks, -- 4281
					60, -- 4281
					9, -- 4281
					38, -- 4281
					86 -- 4281
				) -- 4281
				if options.intensity > 0.62 then -- 4281
					addNote( -- 4282
						step * stepTicks, -- 4282
						45, -- 4282
						9, -- 4282
						39, -- 4282
						62 -- 4282
					) -- 4282
				end -- 4282
			end -- 4282
			if localStep % 2 == 0 then -- 4282
				addNote( -- 4284
					step * stepTicks, -- 4284
					30, -- 4284
					9, -- 4284
					42, -- 4284
					54 -- 4284
				) -- 4284
			end -- 4284
			if localStep == 14 and options.intensity > 0.48 then -- 4284
				addNote( -- 4285
					step * stepTicks, -- 4285
					90, -- 4285
					9, -- 4285
					46, -- 4285
					60 -- 4285
				) -- 4285
			end -- 4285
			if localStep % 4 == 2 and options.intensity > 0.82 then -- 4285
				addNote( -- 4286
					step * stepTicks, -- 4286
					60, -- 4286
					9, -- 4286
					51, -- 4286
					48 -- 4286
				) -- 4286
			end -- 4286
			if localStep >= 13 and options.rhythmComplexity > 0.68 then -- 4286
				addNote( -- 4287
					step * stepTicks, -- 4287
					70, -- 4287
					9, -- 4287
					45 - (localStep - 13) * 2, -- 4287
					70 -- 4287
				) -- 4287
			end -- 4287
			if step % (options.barsPerSection * MUSIC_STEPS_PER_BAR) == 0 and options.intensity > 0.72 then -- 4287
				addNote( -- 4288
					step * stepTicks, -- 4288
					120, -- 4288
					9, -- 4288
					49, -- 4288
					72 -- 4288
				) -- 4288
			end -- 4288
			step = step + 1 -- 4276
		end -- 4276
	end -- 4276
	__TS__ArraySort( -- 4290
		events, -- 4290
		function(____, a, b) return a.tick == b.tick and a.order - b.order or a.tick - b.tick end -- 4290
	) -- 4290
	local function variableLength(value) -- 4291
		local bytes = {value % 128} -- 4292
		local rest = math.floor(value / 128) -- 4293
		while rest > 0 do -- 4293
			bytes[#bytes + 1] = rest % 128 + 128 -- 4295
			rest = math.floor(rest / 128) -- 4296
		end -- 4296
		local result = "" -- 4298
		do -- 4298
			local i = #bytes - 1 -- 4299
			while i >= 0 do -- 4299
				result = result .. string.char(bytes[i + 1]) -- 4299
				i = i - 1 -- 4299
			end -- 4299
		end -- 4299
		return result -- 4300
	end -- 4291
	local tempo = math.floor(60000000 / options.bpm) -- 4302
	local parts = {string.char( -- 4303
		0, -- 4303
		255, -- 4303
		81, -- 4303
		3, -- 4303
		math.floor(tempo / 65536) % 256, -- 4303
		math.floor(tempo / 256) % 256, -- 4303
		tempo % 256 -- 4303
	)} -- 4303
	parts[#parts + 1] = string.char( -- 4304
		0, -- 4304
		255, -- 4304
		88, -- 4304
		4, -- 4304
		4, -- 4304
		2, -- 4304
		24, -- 4304
		8 -- 4304
	) -- 4304
	local lastTick = 0 -- 4305
	do -- 4305
		local i = 0 -- 4306
		while i < #events do -- 4306
			parts[#parts + 1] = variableLength(events[i + 1].tick - lastTick) .. events[i + 1].data -- 4307
			lastTick = events[i + 1].tick -- 4308
			i = i + 1 -- 4306
		end -- 4306
	end -- 4306
	parts[#parts + 1] = string.char(0, 255, 47, 0) -- 4310
	local track = table.concat(parts, "") -- 4311
	return (string.pack( -- 4312
		">c4I4I2I2I2", -- 4312
		"MThd", -- 4312
		6, -- 4312
		0, -- 4312
		1, -- 4312
		480 -- 4312
	) .. string.pack(">c4I4", "MTrk", #track)) .. track -- 4312
end -- 4258
local function musicSiblingPath(path, suffix, extension) -- 4315
	if extension == nil then -- 4315
		extension = ".wav" -- 4315
	end -- 4315
	return (__TS__StringSlice(path, 0, #path - 4) .. suffix) .. extension -- 4316
end -- 4315
local function saveGeneratedAsset(target, data, operationId) -- 4319
	if not ensureDirForFile(target) then -- 4319
		return false -- 4320
	end -- 4320
	local temp = ((target .. ".") .. operationId) .. ".tmp" -- 4321
	local backup = ((target .. ".") .. operationId) .. ".bak" -- 4322
	Content:remove(temp) -- 4323
	Content:remove(backup) -- 4324
	if not Content:save(temp, data) then -- 4324
		return false -- 4325
	end -- 4325
	local hadTarget = Content:exist(target) -- 4326
	if hadTarget and not Content:move(target, backup) then -- 4326
		Content:remove(temp) -- 4328
		return false -- 4329
	end -- 4329
	if not Content:move(temp, target) then -- 4329
		Content:remove(temp) -- 4332
		if hadTarget then -- 4332
			Content:move(backup, target) -- 4333
		end -- 4333
		return false -- 4334
	end -- 4334
	Content:remove(backup) -- 4336
	return true -- 4337
end -- 4319
local function musicFingerprint(options) -- 4340
	local raw = table.concat( -- 4341
		{ -- 4341
			options.style, -- 4342
			tostring(options.seed), -- 4342
			tostring(options.bpm), -- 4342
			tostring(options.bars), -- 4342
			tostring(options.volume), -- 4342
			tostring(options.intensity), -- 4343
			options.key, -- 4343
			options.mode, -- 4343
			options.progressionText, -- 4343
			table.concat(options.structure, ","), -- 4343
			tostring(options.barsPerSection), -- 4344
			tostring(options.melodyComplexity), -- 4344
			tostring(options.rhythmComplexity), -- 4344
			tostring(options.variation), -- 4344
			options.leadInstrument, -- 4345
			options.bassInstrument, -- 4345
			options.harmonyInstrument, -- 4345
			tostring(options.stereo), -- 4345
			tostring(options.reverb), -- 4346
			tostring(options.delay), -- 4346
			tostring(options.chorus), -- 4346
			tostring(options.distortion), -- 4346
			tostring(options.bitCrush), -- 4346
			tostring(options.lowPass), -- 4347
			tostring(options.stems), -- 4347
			tostring(options.introBars), -- 4347
			tostring(options.outroBars), -- 4347
			options.stinger, -- 4347
			tostring(options.exportMidi) -- 4347
		}, -- 4347
		"|" -- 4348
	) -- 4348
	local hash = 2166136261 -- 4349
	do -- 4349
		local i = 0 -- 4350
		while i < #raw do -- 4350
			hash = (hash * 16777619 + __TS__StringCharCodeAt(raw, i)) % 2147483647 -- 4350
			i = i + 1 -- 4350
		end -- 4350
	end -- 4350
	return "music-v1-" .. tostring(math.floor(hash)) -- 4351
end -- 4340
local function musicProjectObject(path, options, files, bytesWritten, durationSeconds, peak, clippingSamples, sourceProject) -- 4354
	return { -- 4364
		version = 1, -- 4365
		generator = "Dora.CodingAgent.generate_music", -- 4365
		fingerprint = musicFingerprint(options), -- 4365
		path = path, -- 4366
		files = files, -- 4366
		bytesWritten = bytesWritten, -- 4366
		durationSeconds = durationSeconds, -- 4366
		peak = peak, -- 4366
		clippingSamples = clippingSamples, -- 4366
		sourceProject = sourceProject, -- 4366
		params = { -- 4367
			style = options.style, -- 4368
			seed = options.seed, -- 4368
			duration = options.duration, -- 4368
			bpm = options.bpm, -- 4368
			volume = options.volume, -- 4368
			intensity = options.intensity, -- 4369
			key = options.key, -- 4369
			mode = options.mode, -- 4369
			progression = options.progressionText, -- 4369
			structure = table.concat(options.structure, ","), -- 4370
			barsPerSection = options.barsPerSection, -- 4370
			melodyComplexity = options.melodyComplexity, -- 4371
			rhythmComplexity = options.rhythmComplexity, -- 4371
			variation = options.variation, -- 4371
			leadInstrument = options.leadInstrument, -- 4372
			bassInstrument = options.bassInstrument, -- 4372
			harmonyInstrument = options.harmonyInstrument, -- 4372
			stereo = options.stereo, -- 4373
			reverb = options.reverb, -- 4373
			delay = options.delay, -- 4373
			chorus = options.chorus, -- 4373
			distortion = options.distortion, -- 4374
			bitCrush = options.bitCrush, -- 4374
			lowPass = options.lowPass, -- 4374
			stems = options.stems, -- 4374
			introBars = options.introBars, -- 4375
			outroBars = options.outroBars, -- 4375
			stinger = options.stinger, -- 4375
			exportMidi = options.exportMidi -- 4375
		} -- 4375
	} -- 4375
end -- 4354
local function readCachedMusicResult(workDir, path, options) -- 4380
	local projectPath = musicSiblingPath(path, "", ".music.json") -- 4381
	local target = resolveWorkspaceFilePath(workDir, path) -- 4382
	local projectFull = resolveWorkspaceFilePath(workDir, projectPath) -- 4383
	if not target or not projectFull or not Content:exist(target) or not Content:exist(projectFull) then -- 4383
		return nil -- 4384
	end -- 4384
	local projectText = Content:load(projectFull) -- 4385
	if type(projectText) ~= "string" then -- 4385
		return nil -- 4386
	end -- 4386
	local decoded = safeJsonDecode(projectText) -- 4387
	if not decoded or type(decoded) ~= "table" then -- 4387
		return nil -- 4388
	end -- 4388
	local record = decoded -- 4389
	if record.fingerprint ~= musicFingerprint(options) or not __TS__ArrayIsArray(record.files) then -- 4389
		return nil -- 4390
	end -- 4390
	local files = {} -- 4391
	do -- 4391
		local i = 0 -- 4392
		while i < #record.files do -- 4392
			if type(record.files[i + 1]) ~= "string" then -- 4392
				return nil -- 4393
			end -- 4393
			local relative = record.files[i + 1] -- 4394
			local full = resolveWorkspaceFilePath(workDir, relative) -- 4395
			if not full or not Content:exist(full) then -- 4395
				return nil -- 4396
			end -- 4396
			files[#files + 1] = relative -- 4397
			i = i + 1 -- 4392
		end -- 4392
	end -- 4392
	if __TS__ArrayIndexOf(files, projectPath) < 0 then -- 4392
		files[#files + 1] = projectPath -- 4399
	end -- 4399
	local durationSeconds = type(record.durationSeconds) == "number" and record.durationSeconds or options.duration -- 4400
	local bytesWritten = type(record.bytesWritten) == "number" and record.bytesWritten or 0 -- 4401
	local midiPath = options.exportMidi and musicSiblingPath(path, "", ".mid") or nil -- 4402
	return { -- 4403
		success = true, -- 4404
		path = path, -- 4404
		files = files, -- 4404
		projectPath = projectPath, -- 4404
		midiPath = midiPath, -- 4404
		bytesWritten = bytesWritten, -- 4404
		durationSeconds = durationSeconds, -- 4404
		sampleRate = MUSIC_SAMPLE_RATE, -- 4405
		channels = options.stereo and 2 or 1, -- 4405
		seed = options.seed, -- 4405
		style = options.style, -- 4406
		bpm = options.bpm, -- 4406
		bars = options.bars, -- 4406
		key = options.key, -- 4406
		mode = options.mode, -- 4406
		description = ((("Reused cached deterministic music assets for " .. path) .. " (") .. musicFingerprint(options)) .. ")." -- 4407
	} -- 4407
end -- 4380
local musicAutoSeedStep = 0 -- 4411
function ____exports.generateMusic(req) -- 4413
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4413
		local relPath = __TS__StringTrim(req.path or "") -- 4422
		if relPath == "" then -- 4422
			return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4422
		end -- 4422
		if not __TS__StringEndsWith( -- 4422
			string.lower(relPath), -- 4424
			".wav" -- 4424
		) then -- 4424
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "generate_music writes WAV files; path must end in .wav"}) -- 4424
		end -- 4424
		local requestedStyle = string.lower(__TS__StringTrim(req.style or "")) -- 4425
		local validStyles = { -- 4426
			"chiptune", -- 4426
			"adventure", -- 4426
			"calm", -- 4426
			"tense", -- 4426
			"victory", -- 4426
			"random" -- 4426
		} -- 4426
		if __TS__ArrayIndexOf(validStyles, requestedStyle) < 0 then -- 4426
			return ____awaiter_resolve( -- 4426
				nil, -- 4426
				{ -- 4427
					success = false, -- 4427
					path = relPath, -- 4427
					message = (("unknown style '" .. req.style) .. "'; expected one of: ") .. table.concat(validStyles, ", ") -- 4427
				} -- 4427
			) -- 4427
		end -- 4427
		local target = resolveWorkspaceFilePath(req.workDir, relPath) -- 4428
		if not target then -- 4428
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "invalid path"}) -- 4428
		end -- 4428
		if Content:exist(target) and Content:isdir(target) then -- 4428
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "target path is a directory"}) -- 4428
		end -- 4428
		local ____this_86 -- 4428
		____this_86 = req -- 4431
		local ____opt_85 = ____this_86.isCancelled -- 4431
		if (____opt_85 and ____opt_85(____this_86)) == true then -- 4431
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "canceled", interrupted = true}) -- 4431
		end -- 4431
		musicAutoSeedStep = musicAutoSeedStep + 1 -- 4432
		local seed = type(req.seed) == "number" and req.seed == req.seed and math.abs(req.seed) < 2147483647 and math.floor(req.seed) or os.time() % 1000000000 + musicAutoSeedStep * 104729 -- 4433
		local styleRng = createSfxRng(seed) -- 4435
		local style = requestedStyle -- 4436
		if style == "random" then -- 4436
			local styles = { -- 4438
				"chiptune", -- 4438
				"adventure", -- 4438
				"calm", -- 4438
				"tense", -- 4438
				"victory" -- 4438
			} -- 4438
			style = styles[math.floor(styleRng:next() * #styles) + 1] -- 4439
		end -- 4439
		local styleConfig = getMusicStyleConfig(style) -- 4441
		local bpm = type(req.bpm) == "number" and req.bpm == req.bpm and math.floor(math.min( -- 4442
			200, -- 4442
			math.max(60, req.bpm) -- 4442
		)) or styleConfig.bpm -- 4442
		local requestedDuration = type(req.duration) == "number" and req.duration == req.duration and req.duration or 16 -- 4443
		requestedDuration = math.min( -- 4444
			MUSIC_MAX_SECONDS, -- 4444
			math.max(MUSIC_MIN_SECONDS, requestedDuration) -- 4444
		) -- 4444
		local barSeconds = 240 / bpm -- 4445
		local minBars = math.max( -- 4446
			1, -- 4446
			math.ceil(MUSIC_MIN_SECONDS / barSeconds) -- 4446
		) -- 4446
		local maxBars = math.max( -- 4447
			minBars, -- 4447
			math.floor(MUSIC_MAX_SECONDS / barSeconds) -- 4447
		) -- 4447
		local bars = math.min( -- 4448
			maxBars, -- 4448
			math.max( -- 4448
				minBars, -- 4448
				math.floor(requestedDuration / barSeconds + 0.5) -- 4448
			) -- 4448
		) -- 4448
		local duration = bars * barSeconds -- 4449
		local requestedKey = string.upper(__TS__StringTrim(req.key or "random")) -- 4450
		local rootPitchClass = __TS__ArrayIndexOf(MUSIC_KEY_NAMES, requestedKey) -- 4451
		if rootPitchClass < 0 then -- 4451
			rootPitchClass = math.floor(styleRng:next() * #MUSIC_KEY_NAMES) -- 4452
		end -- 4452
		local requestedMode = string.lower(__TS__StringTrim(req.mode or "auto")) -- 4453
		local mode = __TS__ArrayIndexOf(MUSIC_VALID_MODES, requestedMode) >= 0 and requestedMode or styleConfig.mode -- 4454
		local parsedProgression = parseMusicProgression(req.progression, styleConfig.progression) -- 4455
		local options = { -- 4456
			style = style, -- 4457
			seed = seed, -- 4457
			bpm = bpm, -- 4457
			bars = bars, -- 4457
			duration = duration, -- 4457
			volume = type(req.volume) == "number" and req.volume == req.volume and clamp01(req.volume) or 0.65, -- 4458
			intensity = type(req.intensity) == "number" and req.intensity == req.intensity and clamp01(req.intensity) or 0.6, -- 4459
			rootPitchClass = rootPitchClass, -- 4460
			key = MUSIC_KEY_NAMES[rootPitchClass + 1], -- 4460
			mode = mode, -- 4460
			progression = parsedProgression.degrees, -- 4461
			progressionText = parsedProgression.text, -- 4461
			structure = parseMusicStructure(req.structure), -- 4462
			barsPerSection = type(req.barsPerSection) == "number" and math.floor(math.min( -- 4463
				8, -- 4463
				math.max(1, req.barsPerSection) -- 4463
			)) or 2, -- 4463
			melodyComplexity = type(req.melodyComplexity) == "number" and clamp01(req.melodyComplexity) or 0.55, -- 4464
			rhythmComplexity = type(req.rhythmComplexity) == "number" and clamp01(req.rhythmComplexity) or 0.45, -- 4465
			variation = type(req.variation) == "number" and clamp01(req.variation) or 0.25, -- 4466
			leadInstrument = resolveMusicInstrument(req.leadInstrument, styleConfig.leadInstrument), -- 4467
			bassInstrument = resolveMusicInstrument(req.bassInstrument, styleConfig.bassInstrument), -- 4468
			harmonyInstrument = resolveMusicInstrument(req.harmonyInstrument, styleConfig.harmonyInstrument), -- 4469
			stereo = req.stereo ~= false, -- 4470
			reverb = type(req.reverb) == "number" and clamp01(req.reverb) or styleConfig.reverb, -- 4471
			delay = type(req.delay) == "number" and clamp01(req.delay) or styleConfig.delay, -- 4472
			chorus = type(req.chorus) == "number" and clamp01(req.chorus) or styleConfig.chorus, -- 4473
			distortion = type(req.distortion) == "number" and clamp01(req.distortion) or styleConfig.distortion, -- 4474
			bitCrush = type(req.bitCrush) == "number" and clamp01(req.bitCrush) or 0, -- 4475
			lowPass = type(req.lowPass) == "number" and clamp01(req.lowPass) or 0, -- 4476
			stems = req.stems == true, -- 4477
			introBars = type(req.introBars) == "number" and math.floor(math.min( -- 4478
				8, -- 4478
				math.max(0, req.introBars) -- 4478
			)) or 0, -- 4478
			outroBars = type(req.outroBars) == "number" and math.floor(math.min( -- 4479
				8, -- 4479
				math.max(0, req.outroBars) -- 4479
			)) or 0, -- 4479
			stinger = __TS__ArrayIndexOf( -- 4480
				{"victory", "failure", "both"}, -- 4480
				string.lower(req.stinger or "none") -- 4480
			) >= 0 and string.lower(req.stinger or "none") or "none", -- 4480
			exportMidi = req.exportMidi == true -- 4481
		} -- 4481
		local cached = readCachedMusicResult(req.workDir, relPath, options) -- 4483
		if cached then -- 4483
			local ____this_88 -- 4483
			____this_88 = req -- 4485
			local ____opt_87 = ____this_88.onProgress -- 4485
			if ____opt_87 ~= nil then -- 4485
				____opt_87(____this_88, { -- 4485
					state = "running", -- 4485
					operationId = "cache", -- 4485
					path = relPath, -- 4485
					stage = "cache", -- 4485
					percent = 100, -- 4485
					message = "reusing matching deterministic music assets" -- 4485
				}) -- 4485
			end -- 4485
			return ____awaiter_resolve(nil, cached) -- 4485
		end -- 4485
		local operationId = createOperationId() -- 4488
		local files = {} -- 4489
		local bytesWritten = 0 -- 4490
		local function saveAudio(relative, render) -- 4491
			local full = resolveWorkspaceFilePath(req.workDir, relative) -- 4492
			if not full then -- 4492
				return false -- 4493
			end -- 4493
			local wav = encodePcmWav(render.mix.left, MUSIC_SAMPLE_RATE, render.mix.right) -- 4494
			if not saveGeneratedAsset(full, wav, operationId) then -- 4494
				return false -- 4495
			end -- 4495
			files[#files + 1] = relative -- 4496
			bytesWritten = bytesWritten + #wav -- 4496
			syncDownloadedFileToWebIDE(full) -- 4496
			return true -- 4497
		end -- 4491
		local ____this_90 -- 4491
		____this_90 = req -- 4499
		local ____opt_89 = ____this_90.onProgress -- 4499
		if ____opt_89 ~= nil then -- 4499
			____opt_89( -- 4499
				____this_90, -- 4499
				{ -- 4499
					state = "running", -- 4499
					operationId = operationId, -- 4499
					path = relPath, -- 4499
					stage = "compose", -- 4499
					percent = 0, -- 4499
					message = ((((((("composing " .. style) .. " in ") .. options.key) .. " ") .. mode) .. " at ") .. tostring(bpm)) .. " BPM" -- 4499
				} -- 4499
			) -- 4499
		end -- 4499
		local arrangement = createMusicArrangement(options, bars) -- 4500
		local render = __TS__Await(synthMusic( -- 4501
			options, -- 4501
			arrangement, -- 4501
			bars, -- 4501
			"loop", -- 4501
			options.stems, -- 4501
			function(percent) -- 4501
				local ____this_92 -- 4501
				____this_92 = req -- 4501
				local ____opt_91 = ____this_92.onProgress -- 4501
				return ____opt_91 and ____opt_91( -- 4501
					____this_92, -- 4501
					{ -- 4501
						state = "running", -- 4502
						operationId = operationId, -- 4502
						path = relPath, -- 4502
						stage = "synth", -- 4502
						percent = percent, -- 4502
						message = ("synthesizing loop (" .. tostring(percent)) .. "%)" -- 4502
					} -- 4502
				) -- 4502
			end, -- 4501
			req.isCancelled -- 4503
		)) -- 4503
		if not render then -- 4503
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "canceled", interrupted = true}) -- 4503
		end -- 4503
		local ____this_94 -- 4503
		____this_94 = req -- 4505
		local ____opt_93 = ____this_94.onProgress -- 4505
		if ____opt_93 ~= nil then -- 4505
			____opt_93(____this_94, { -- 4505
				state = "running", -- 4505
				operationId = operationId, -- 4505
				path = relPath, -- 4505
				stage = "write", -- 4505
				percent = 100, -- 4505
				message = "writing music assets" -- 4505
			}) -- 4505
		end -- 4505
		if not saveAudio(relPath, render) then -- 4505
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "failed to write music WAV"}) -- 4505
		end -- 4505
		if render.stems then -- 4505
			local stemNames = {"melody", "bass", "harmony", "drums"} -- 4508
			do -- 4508
				local i = 0 -- 4509
				while i < #stemNames do -- 4509
					local name = stemNames[i + 1] -- 4510
					local relative = musicSiblingPath(relPath, "_" .. name) -- 4511
					local full = resolveWorkspaceFilePath(req.workDir, relative) -- 4512
					if not full then -- 4512
						return ____awaiter_resolve(nil, {success = false, path = relPath, message = "invalid stem path: " .. relative}) -- 4512
					end -- 4512
					local wav = encodePcmWav(render.stems[name].left, MUSIC_SAMPLE_RATE, render.stems[name].right) -- 4514
					if not saveGeneratedAsset(full, wav, operationId) then -- 4514
						return ____awaiter_resolve(nil, {success = false, path = relPath, message = ("failed to write " .. name) .. " stem"}) -- 4514
					end -- 4514
					files[#files + 1] = relative -- 4516
					bytesWritten = bytesWritten + #wav -- 4516
					syncDownloadedFileToWebIDE(full) -- 4516
					__TS__Await(yieldMusicFrame()) -- 4517
					i = i + 1 -- 4509
				end -- 4509
			end -- 4509
		end -- 4509
		local segmentSpecs = {} -- 4520
		if options.introBars > 0 then -- 4520
			segmentSpecs[#segmentSpecs + 1] = {suffix = "_intro", bars = options.introBars, kind = "intro", seedOffset = 3001} -- 4521
		end -- 4521
		if options.outroBars > 0 then -- 4521
			segmentSpecs[#segmentSpecs + 1] = {suffix = "_outro", bars = options.outroBars, kind = "outro", seedOffset = 6007} -- 4522
		end -- 4522
		if options.stinger == "victory" or options.stinger == "both" then -- 4522
			segmentSpecs[#segmentSpecs + 1] = { -- 4523
				suffix = "_victory", -- 4523
				bars = 1, -- 4523
				kind = "stinger", -- 4523
				style = "victory", -- 4523
				seedOffset = 9001 -- 4523
			} -- 4523
		end -- 4523
		if options.stinger == "failure" or options.stinger == "both" then -- 4523
			segmentSpecs[#segmentSpecs + 1] = { -- 4524
				suffix = "_failure", -- 4524
				bars = 1, -- 4524
				kind = "stinger", -- 4524
				style = "tense", -- 4524
				seedOffset = 12007 -- 4524
			} -- 4524
		end -- 4524
		do -- 4524
			local i = 0 -- 4525
			while i < #segmentSpecs do -- 4525
				local spec = segmentSpecs[i + 1] -- 4526
				local segmentStyle = spec.style or options.style -- 4527
				local segmentConfig = getMusicStyleConfig(segmentStyle) -- 4528
				local segmentOptions = __TS__ObjectAssign({}, options, { -- 4529
					style = segmentStyle, -- 4531
					seed = options.seed + spec.seedOffset, -- 4532
					mode = spec.style and segmentConfig.mode or options.mode, -- 4533
					progression = spec.style and segmentConfig.progression or options.progression, -- 4534
					leadInstrument = spec.style and segmentConfig.leadInstrument or options.leadInstrument, -- 4535
					bassInstrument = spec.style and segmentConfig.bassInstrument or options.bassInstrument, -- 4536
					harmonyInstrument = spec.style and segmentConfig.harmonyInstrument or options.harmonyInstrument, -- 4537
					intensity = spec.style and 0.9 or options.intensity, -- 4538
					stems = false -- 4539
				}) -- 4539
				local segmentArrangement = createMusicArrangement(segmentOptions, spec.bars, spec.seedOffset) -- 4541
				local segment = __TS__Await(synthMusic( -- 4542
					segmentOptions, -- 4542
					segmentArrangement, -- 4542
					spec.bars, -- 4542
					spec.kind, -- 4542
					false, -- 4542
					nil, -- 4542
					req.isCancelled -- 4542
				)) -- 4542
				if not segment then -- 4542
					return ____awaiter_resolve(nil, {success = false, path = relPath, message = "canceled", interrupted = true}) -- 4542
				end -- 4542
				if not saveAudio( -- 4542
					musicSiblingPath(relPath, spec.suffix), -- 4544
					segment -- 4544
				) then -- 4544
					return ____awaiter_resolve(nil, {success = false, path = relPath, message = ("failed to write " .. spec.suffix) .. " segment"}) -- 4544
				end -- 4544
				i = i + 1 -- 4525
			end -- 4525
		end -- 4525
		local midiPath -- 4546
		if options.exportMidi then -- 4546
			midiPath = musicSiblingPath(relPath, "", ".mid") -- 4548
			local midiFull = resolveWorkspaceFilePath(req.workDir, midiPath) -- 4549
			local midi = encodeMusicMidi(arrangement, options) -- 4550
			if not midiFull or not saveGeneratedAsset(midiFull, midi, operationId) then -- 4550
				return ____awaiter_resolve(nil, {success = false, path = relPath, message = "failed to write MIDI file"}) -- 4550
			end -- 4550
			files[#files + 1] = midiPath -- 4552
			bytesWritten = bytesWritten + #midi -- 4552
			syncDownloadedFileToWebIDE(midiFull) -- 4552
		end -- 4552
		local actualDuration = math.floor(#render.mix.left / MUSIC_SAMPLE_RATE * 100 + 0.5) / 100 -- 4554
		local projectPath = musicSiblingPath(relPath, "", ".music.json") -- 4555
		local projectFull = resolveWorkspaceFilePath(req.workDir, projectPath) -- 4556
		local projectText = safeJsonEncode( -- 4557
			musicProjectObject( -- 4557
				relPath, -- 4558
				options, -- 4558
				__TS__ArraySlice(files), -- 4558
				bytesWritten, -- 4558
				actualDuration, -- 4558
				render.peak, -- 4558
				render.clippingSamples, -- 4558
				req.sourceProject -- 4558
			), -- 4558
			true, -- 4559
			false -- 4559
		) -- 4559
		if not projectFull or not projectText or not saveGeneratedAsset(projectFull, projectText, operationId) then -- 4559
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "failed to write music project file"}) -- 4559
		end -- 4559
		files[#files + 1] = projectPath -- 4561
		bytesWritten = bytesWritten + #projectText -- 4561
		syncDownloadedFileToWebIDE(projectFull) -- 4561
		if render.clippingSamples > 0 then -- 4561
			Log( -- 4562
				"Warn", -- 4562
				(("[generate_music] limiter caught " .. tostring(render.clippingSamples)) .. " clipping sample(s), pre-limit peak=") .. tostring(render.peak) -- 4562
			) -- 4562
		end -- 4562
		Log( -- 4563
			"Info", -- 4563
			(((((((((((((("[generate_music] style=" .. style) .. " seed=") .. tostring(seed)) .. " bpm=") .. tostring(bpm)) .. " bars=") .. tostring(bars)) .. " key=") .. options.key) .. " ") .. mode) .. " files=") .. tostring(#files)) .. " bytes=") .. tostring(bytesWritten) -- 4563
		) -- 4563
		return ____awaiter_resolve( -- 4563
			nil, -- 4563
			{ -- 4564
				success = true, -- 4565
				path = relPath, -- 4565
				files = files, -- 4565
				projectPath = projectPath, -- 4565
				midiPath = midiPath, -- 4565
				bytesWritten = bytesWritten, -- 4565
				durationSeconds = actualDuration, -- 4565
				sampleRate = MUSIC_SAMPLE_RATE, -- 4566
				channels = options.stereo and 2 or 1, -- 4566
				seed = seed, -- 4566
				style = style, -- 4566
				bpm = bpm, -- 4566
				bars = bars, -- 4566
				key = options.key, -- 4567
				mode = mode, -- 4567
				description = ((((((((((((((((("Saved " .. tostring(bars)) .. " bars of ") .. style) .. " background music in ") .. options.key) .. " ") .. mode) .. " at ") .. tostring(bpm)) .. " BPM to ") .. relPath) .. ", plus ") .. tostring(#files - 1)) .. " companion asset(s). Stream the loop with Audio.playStream(\"") .. relPath) .. "\", true); use ") .. projectPath) .. " to create compatible variations." -- 4568
			} -- 4568
		) -- 4568
	end) -- 4568
end -- 4413
function ____exports.generateMusicVariation(req) -- 4572
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4572
		local projectRel = __TS__StringTrim(req.project or "") -- 4576
		if not __TS__StringEndsWith( -- 4576
			string.lower(projectRel), -- 4577
			".music.json" -- 4577
		) then -- 4577
			return ____awaiter_resolve(nil, {success = false, path = req.path, message = "project must end in .music.json"}) -- 4577
		end -- 4577
		local projectFull = resolveWorkspaceFilePath(req.workDir, projectRel) -- 4578
		if not projectFull or not Content:exist(projectFull) or Content:isdir(projectFull) then -- 4578
			return ____awaiter_resolve(nil, {success = false, path = req.path, message = "music project file not found"}) -- 4578
		end -- 4578
		local text = Content:load(projectFull) -- 4580
		if type(text) ~= "string" then -- 4580
			return ____awaiter_resolve(nil, {success = false, path = req.path, message = "failed to read music project file"}) -- 4580
		end -- 4580
		local decoded, decodeError = safeJsonDecode(text) -- 4582
		if not decoded or type(decoded) ~= "table" then -- 4582
			return ____awaiter_resolve( -- 4582
				nil, -- 4582
				{ -- 4583
					success = false, -- 4583
					path = req.path, -- 4583
					message = "invalid music project: " .. tostring(decodeError) -- 4583
				} -- 4583
			) -- 4583
		end -- 4583
		local params = decoded.params -- 4584
		if not params or type(params) ~= "table" then -- 4584
			return ____awaiter_resolve(nil, {success = false, path = req.path, message = "music project is missing params"}) -- 4584
		end -- 4584
		local p = params -- 4586
		local function numberValue(name) -- 4587
			return type(p[name]) == "number" and p[name] or nil -- 4587
		end -- 4587
		local function stringValue(name) -- 4588
			return type(p[name]) == "string" and p[name] or nil -- 4588
		end -- 4588
		local function boolValue(name) -- 4589
			local ____temp_95 -- 4589
			if type(p[name]) == "boolean" then -- 4589
				____temp_95 = p[name] -- 4589
			else -- 4589
				____temp_95 = nil -- 4589
			end -- 4589
			return ____temp_95 -- 4589
		end -- 4589
		local oldSeed = numberValue("seed") or 1 -- 4590
		return ____awaiter_resolve( -- 4590
			nil, -- 4590
			____exports.generateMusic({ -- 4591
				workDir = req.workDir, -- 4592
				path = req.path, -- 4592
				style = req.style or stringValue("style") or "chiptune", -- 4592
				seed = req.seed or oldSeed + 7919, -- 4593
				duration = numberValue("duration"), -- 4593
				bpm = numberValue("bpm"), -- 4593
				volume = numberValue("volume"), -- 4593
				intensity = req.intensity or numberValue("intensity"), -- 4594
				key = stringValue("key"), -- 4594
				mode = stringValue("mode"), -- 4594
				progression = stringValue("progression"), -- 4595
				structure = stringValue("structure"), -- 4595
				barsPerSection = numberValue("barsPerSection"), -- 4595
				melodyComplexity = numberValue("melodyComplexity"), -- 4596
				rhythmComplexity = numberValue("rhythmComplexity"), -- 4596
				variation = req.variation or numberValue("variation"), -- 4597
				leadInstrument = stringValue("leadInstrument"), -- 4597
				bassInstrument = stringValue("bassInstrument"), -- 4598
				harmonyInstrument = stringValue("harmonyInstrument"), -- 4598
				stereo = boolValue("stereo"), -- 4598
				reverb = numberValue("reverb"), -- 4599
				delay = numberValue("delay"), -- 4599
				chorus = numberValue("chorus"), -- 4599
				distortion = numberValue("distortion"), -- 4599
				bitCrush = numberValue("bitCrush"), -- 4600
				lowPass = numberValue("lowPass"), -- 4600
				stems = boolValue("stems"), -- 4600
				introBars = numberValue("introBars"), -- 4600
				outroBars = numberValue("outroBars"), -- 4600
				stinger = stringValue("stinger"), -- 4601
				exportMidi = boolValue("exportMidi"), -- 4601
				sourceProject = projectRel, -- 4601
				onProgress = req.onProgress, -- 4602
				isCancelled = req.isCancelled -- 4602
			}) -- 4602
		) -- 4602
	end) -- 4602
end -- 4572
return ____exports -- 4572