-- [ts]: Tools.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayFlatMap = ____lualib.__TS__ArrayFlatMap -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Set = ____lualib.Set -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
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
function normalizeEscapedGitQuotes(command) -- 755
	local result = "" -- 756
	do -- 756
		local i = 0 -- 757
		while i < #command do -- 757
			do -- 757
				local ch = __TS__StringCharAt(command, i) -- 758
				local next = __TS__StringCharAt(command, i + 1) -- 759
				if ch == "\\" and (next == "\"" or next == "'") then -- 759
					result = result .. next -- 761
					i = i + 1 -- 762
					goto __continue123 -- 763
				end -- 763
				result = result .. ch -- 765
			end -- 765
			::__continue123:: -- 765
			i = i + 1 -- 757
		end -- 757
	end -- 757
	return result -- 767
end -- 767
function encodeJSON(obj) -- 1268
	local text = safeJsonEncode(obj) -- 1269
	return text -- 1270
end -- 1270
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 1273
	if HttpServer.wsConnectionCount == 0 then -- 1273
		return true -- 1275
	end -- 1275
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 1277
	if not payload then -- 1277
		return false -- 1279
	end -- 1279
	emit("AppWS", "Send", payload) -- 1281
	return true -- 1282
end -- 1273
function getEngineLogText() -- 1664
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 1665
	if not Content:exist(folder) then -- 1665
		Content:mkdir(folder) -- 1667
	end -- 1667
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 1669
	if not App:saveLog(logPath) then -- 1669
		return nil -- 1671
	end -- 1671
	return Content:load(logPath) -- 1673
end -- 1673
function ensureSafeSearchGlobs(globs) -- 1813
	local result = {} -- 1814
	do -- 1814
		local i = 0 -- 1815
		while i < #globs do -- 1815
			result[#result + 1] = globs[i + 1] -- 1816
			i = i + 1 -- 1815
		end -- 1815
	end -- 1815
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1818
	do -- 1818
		local i = 0 -- 1819
		while i < #requiredExcludes do -- 1819
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1819
				result[#result + 1] = requiredExcludes[i + 1] -- 1821
			end -- 1821
			i = i + 1 -- 1819
		end -- 1819
	end -- 1819
	return result -- 1824
end -- 1824
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
local function getDoraDocDefinitionRoot(docLanguage) -- 525
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
local function getDoraDocDefinitionExtsByCodeLanguage(programmingLanguage) -- 537
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
local function getDoraDocSearchTarget(docType, docLanguage, programmingLanguage) -- 552
	if docType == "dora-tutorial" then -- 552
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 558
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 559
		return { -- 560
			root = Path(tutorialRoot, langDir), -- 561
			exts = {"md"}, -- 562
			globs = {"**/*.md"} -- 563
		} -- 563
	end -- 563
	local exts = getDoraDocDefinitionExtsByCodeLanguage(programmingLanguage) -- 566
	if docType == "love-api" or docType == "tic80-api" then -- 566
		local name = docType == "love-api" and "love" or "tic80" -- 568
		return { -- 569
			root = getDoraDocDefinitionRoot(docLanguage), -- 570
			exts = exts, -- 571
			globs = __TS__ArrayMap( -- 572
				exts, -- 572
				function(____, ext) return (name .. ".d.") .. ext end -- 572
			) -- 572
		} -- 572
	end -- 572
	return { -- 575
		root = getDoraDocDefinitionRoot(docLanguage), -- 576
		exts = exts, -- 577
		globs = __TS__ArrayFlatMap( -- 578
			exts, -- 578
			function(____, ext) return {"**/*." .. ext, "!**/love.d." .. ext, "!**/tic80.d." .. ext} end -- 578
		) -- 578
	} -- 578
end -- 552
local function getDoraDocResultBaseRoot(docType, docLanguage) -- 586
	if docType == "dora-tutorial" then -- 586
		return getDoraTutorialDocRoot(docLanguage) -- 588
	end -- 588
	return getDoraDocDefinitionRoot(docLanguage) -- 590
end -- 586
local function isDoraDocFileInScope(docType, file) -- 593
	local normalized = string.lower(table.concat( -- 594
		__TS__StringSplit(file, "\\"), -- 594
		"/" -- 594
	)) -- 594
	local segments = __TS__StringSplit(normalized, "/") -- 595
	local baseName = segments[#segments] or normalized -- 596
	if docType == "dora-tutorial" then -- 596
		return __TS__StringEndsWith(normalized, ".md") -- 597
	end -- 597
	if docType == "love-api" then -- 597
		return normalized == "love.d.ts" or normalized == "love.d.tl" -- 598
	end -- 598
	if docType == "tic80-api" then -- 598
		return normalized == "tic80.d.ts" or normalized == "tic80.d.tl" -- 599
	end -- 599
	return (__TS__StringEndsWith(normalized, ".ts") or __TS__StringEndsWith(normalized, ".tl")) and baseName ~= "love.d.ts" and baseName ~= "love.d.tl" and baseName ~= "tic80.d.ts" and baseName ~= "tic80.d.tl" -- 600
end -- 593
local AGENT_DORA_DOC_PREFIX = "@dora-doc/" -- 607
local function toDocRelativePath(baseRoot, path, docType) -- 609
	if not path or #path == 0 then -- 609
		return path -- 610
	end -- 610
	local relative = Content:isAbsolutePath(path) and Path:getRelative(path, baseRoot) or path -- 611
	return ((AGENT_DORA_DOC_PREFIX .. docType) .. "/") .. relative -- 612
end -- 609
local function resolveAgentDoraDocFilePath(path, docLanguage) -- 615
	if not docLanguage then -- 615
		return nil -- 616
	end -- 616
	local relative = path -- 617
	local docType = "dora-tutorial" -- 618
	if __TS__StringStartsWith(path, AGENT_DORA_DOC_PREFIX) then -- 618
		local namespaced = __TS__StringSlice(path, #AGENT_DORA_DOC_PREFIX) -- 620
		if __TS__StringStartsWith(namespaced, "dora-api/") then -- 620
			docType = "dora-api" -- 622
			relative = string.sub(namespaced, 10) -- 623
		elseif __TS__StringStartsWith(namespaced, "love-api/") then -- 623
			docType = "love-api" -- 625
			relative = string.sub(namespaced, 10) -- 626
		elseif __TS__StringStartsWith(namespaced, "tic80-api/") then -- 626
			docType = "tic80-api" -- 628
			relative = string.sub(namespaced, 11) -- 629
		elseif __TS__StringStartsWith(namespaced, "dora-tutorial/") then -- 629
			docType = "dora-tutorial" -- 631
			relative = string.sub(namespaced, 15) -- 632
		elseif __TS__StringStartsWith(namespaced, "api/") then -- 632
			docType = "dora-api" -- 634
			relative = string.sub(namespaced, 5) -- 635
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 635
			docType = "dora-tutorial" -- 637
			relative = string.sub(namespaced, 10) -- 638
		else -- 638
			return nil -- 640
		end -- 640
	end -- 640
	if not isValidWorkspacePath(relative) then -- 640
		return nil -- 643
	end -- 643
	if not isDoraDocFileInScope(docType, relative) then -- 643
		return nil -- 644
	end -- 644
	local root = getDoraDocResultBaseRoot(docType, docLanguage) -- 645
	local candidate = Path(root, relative) -- 646
	local checked = Path:getRelative(candidate, root) -- 647
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 647
		return nil -- 648
	end -- 648
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 648
		return candidate -- 650
	end -- 650
	return nil -- 652
end -- 615
local function ensureDirPath(dir) -- 655
	if not dir or dir == "." or dir == "" then -- 655
		return true -- 656
	end -- 656
	if Content:exist(dir) then -- 656
		return Content:isdir(dir) -- 657
	end -- 657
	local parent = Path:getPath(dir) -- 658
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 658
		if not ensureDirPath(parent) then -- 658
			return false -- 660
		end -- 660
	end -- 660
	return Content:mkdir(dir) -- 662
end -- 655
local function ensureDirForFile(path) -- 665
	local dir = Path:getPath(path) -- 666
	return ensureDirPath(dir) -- 667
end -- 665
local function isHttpUrl(url) -- 670
	local normalized = string.lower(__TS__StringTrim(url)) -- 671
	return __TS__StringStartsWith(normalized, "http://") or __TS__StringStartsWith(normalized, "https://") -- 672
end -- 670
local function createOperationId() -- 675
	local raw = (tostring(os.time()) .. "-") .. tostring(math.floor(math.random() * 1000000000)) -- 676
	local safe = string.gsub(raw, "[^%w%-_]", "-") -- 677
	return safe -- 678
end -- 675
local function getAgentDownloadTempRoot() -- 681
	return Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR, AGENT_DOWNLOAD_TEMP_DIR) -- 682
end -- 681
local function cleanupPath(path) -- 685
	if not path or path == "" or not Content:exist(path) then -- 685
		return nil -- 686
	end -- 686
	if Content:remove(path) then -- 686
		return nil -- 687
	end -- 687
	return "failed to remove temporary path: " .. path -- 688
end -- 685
local function quoteGitArg(value) -- 691
	local plain = string.match(value, "^[%w%._%-%/]+$") -- 692
	if plain ~= nil then -- 692
		return value -- 694
	end -- 694
	local escaped = string.gsub(value, "\\", "\\\\") -- 696
	escaped = string.gsub(escaped, "\"", "\\\"") -- 697
	return ("\"" .. escaped) .. "\"" -- 698
end -- 691
local function shellSplit(command) -- 701
	local args = {} -- 702
	local current = "" -- 703
	local quote = "" -- 704
	local escaped = false -- 705
	do -- 705
		local i = 0 -- 706
		while i < #command do -- 706
			do -- 706
				local ch = __TS__StringCharAt(command, i) -- 707
				if escaped then -- 707
					current = current .. ch -- 709
					escaped = false -- 710
					goto __continue109 -- 711
				end -- 711
				if ch == "\\" then -- 711
					escaped = true -- 714
					goto __continue109 -- 715
				end -- 715
				if quote ~= "" then -- 715
					if ch == quote then -- 715
						quote = "" -- 719
					else -- 719
						current = current .. ch -- 721
					end -- 721
					goto __continue109 -- 723
				end -- 723
				if ch == "'" or ch == "\"" then -- 723
					quote = ch -- 726
					goto __continue109 -- 727
				end -- 727
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 727
					if current ~= "" then -- 727
						args[#args + 1] = current -- 731
						current = "" -- 732
					end -- 732
					goto __continue109 -- 734
				end -- 734
				current = current .. ch -- 736
			end -- 736
			::__continue109:: -- 736
			i = i + 1 -- 706
		end -- 706
	end -- 706
	if escaped then -- 706
		current = current .. "\\" -- 739
	end -- 739
	if current ~= "" then -- 739
		args[#args + 1] = current -- 742
	end -- 742
	return args -- 744
end -- 701
local function normalizeGitCommand(command) -- 747
	local trimmed = __TS__StringTrim(command) -- 748
	local normalized = string.lower(string.sub(trimmed, 1, 4)) == "git " and __TS__StringTrim(string.sub(trimmed, 5)) or trimmed -- 749
	return normalizeEscapedGitQuotes(normalized) -- 752
end -- 747
local function gitDefaultTargetFromUrl(url) -- 770
	local target = url -- 771
	local hashIndex = (string.find(target, "#", nil, true) or 0) - 1 -- 772
	if hashIndex >= 0 then -- 772
		target = __TS__StringSlice(target, 0, hashIndex) -- 773
	end -- 773
	local queryIndex = (string.find(target, "?", nil, true) or 0) - 1 -- 774
	if queryIndex >= 0 then -- 774
		target = __TS__StringSlice(target, 0, queryIndex) -- 775
	end -- 775
	target = string.gsub(target, "/+$", "") -- 776
	local name = string.match(target, "([^/]+)$") -- 777
	if name ~= nil and name ~= "" then -- 777
		target = name -- 778
	end -- 778
	if __TS__StringEndsWith( -- 778
		string.lower(target), -- 779
		".git" -- 779
	) then -- 779
		target = __TS__StringSlice(target, 0, #target - 4) -- 780
	end -- 780
	return target ~= "" and target or "repo" -- 782
end -- 770
local function parseGitCloneCommand(command) -- 785
	local args = shellSplit(normalizeGitCommand(command)) -- 795
	if #args == 0 or args[1] ~= "clone" then -- 795
		return nil -- 796
	end -- 796
	local url = "" -- 797
	local target = "" -- 798
	local ref -- 799
	local depth -- 800
	do -- 800
		local i = 1 -- 801
		while i < #args do -- 801
			do -- 801
				local arg = args[i + 1] -- 802
				if arg == "-b" or arg == "--branch" then
					i = i + 1 -- 804
					if i >= #args then -- 804
						return {success = false, message = arg .. " requires a value"} -- 805
					end -- 805
					ref = args[i + 1] -- 806
					goto __continue133 -- 807
				end -- 807
				if arg == "--depth" then
					i = i + 1 -- 810
					if i >= #args then -- 810
						return {success = false, message = "--depth requires a value"}
					end -- 811
					depth = args[i + 1] -- 812
					goto __continue133 -- 813
				end -- 813
				if __TS__StringStartsWith(arg, "--depth=") then
					depth = __TS__StringSlice(arg, #"--depth=")
					goto __continue133 -- 817
				end -- 817
				if __TS__StringStartsWith(arg, "-") then -- 817
					return {success = false, message = "unsupported clone option: " .. arg} -- 820
				end -- 820
				if url == "" then -- 820
					url = arg -- 823
					goto __continue133 -- 824
				end -- 824
				if target == "" then -- 824
					target = arg -- 827
					goto __continue133 -- 828
				end -- 828
				return {success = false, message = "unexpected clone argument: " .. arg} -- 830
			end -- 830
			::__continue133:: -- 830
			i = i + 1 -- 801
		end -- 801
	end -- 801
	if url == "" then -- 801
		return {success = false, message = "git clone requires a URL"} -- 832
	end -- 832
	if not isHttpUrl(url) then -- 832
		return {success = false, message = "git clone only supports http:// and https:// URLs"} -- 833
	end -- 833
	if target == "" then -- 833
		target = gitDefaultTargetFromUrl(url) -- 834
	end -- 834
	return { -- 835
		success = true, -- 836
		url = url, -- 837
		target = target, -- 838
		ref = ref, -- 839
		depth = depth ~= nil and depth ~= "" and depth or "1" -- 840
	} -- 840
end -- 785
local function getGitHeadCommit(repoPath) -- 844
	local headPath = Path(repoPath, ".git", "HEAD") -- 845
	if not Content:exist(headPath) then -- 845
		return nil -- 846
	end -- 846
	local head = __TS__StringTrim(toStr(Content:load(headPath))) -- 847
	local ref = string.match(head, "^ref:%s*(.-)%s*$") -- 848
	if ref ~= nil and ref ~= "" then -- 848
		local refPath = Path(repoPath, ".git", ref) -- 850
		if Content:exist(refPath) then -- 850
			local commit = __TS__StringTrim(toStr(Content:load(refPath))) -- 852
			return commit ~= "" and commit or nil -- 853
		end -- 853
		return nil -- 855
	end -- 855
	return head ~= "" and head or nil -- 857
end -- 844
local function runGitAndWait(repoPath, command, onStatus, isCancelled, timeout) -- 860
	if timeout == nil then -- 860
		timeout = 600 -- 865
	end -- 865
	return __TS__New( -- 867
		__TS__Promise, -- 867
		function(____, resolve) -- 867
			local status -- 868
			local jobId = 0 -- 869
			local settled = false -- 870
			local canceled = false -- 871
			local function finish(result) -- 872
				if settled then -- 872
					return -- 873
				end -- 873
				settled = true -- 874
				resolve(nil, result) -- 875
			end -- 872
			local function finishFromStatus() -- 877
				local state = toStr(status and status.state) -- 878
				if state == "done" then -- 878
					finish({success = true, status = status}) -- 880
					return true -- 881
				end -- 881
				if state == "error" or state == "canceled" then -- 881
					local errorMessage = toStr(status and status.error) -- 884
					local statusMessage = toStr(status and status.message) -- 885
					finish({success = false, message = errorMessage ~= "" and errorMessage or (statusMessage ~= "" and statusMessage or (state == "canceled" and "git command canceled" or "git command failed")), status = status, interrupted = state == "canceled"}) -- 886
					return true -- 892
				end -- 892
				return false -- 894
			end -- 877
			jobId = Git:run( -- 896
				repoPath, -- 896
				command, -- 896
				function(nextStatus) -- 896
					status = nextStatus -- 897
					if onStatus then -- 897
						onStatus(status) -- 898
					end -- 898
					return finishFromStatus() -- 899
				end, -- 896
				"" -- 900
			) -- 900
			if jobId == nil or jobId <= 0 then -- 900
				finish({success = false, message = "failed to start git command"}) -- 902
				return -- 903
			end -- 903
			if not status then -- 903
				local kind = string.match(command, "^(%S+)") -- 906
				status = { -- 907
					id = jobId, -- 908
					state = "queued", -- 909
					kind = toStr(kind), -- 910
					repoPath = repoPath, -- 911
					progress = 0, -- 912
					message = "queued" -- 913
				} -- 913
			end -- 913
			if onStatus then -- 913
				onStatus(status) -- 916
			end -- 916
			local startedAt = os.time() -- 917
			local lastEmitAt = startedAt -- 918
			Director.systemScheduler:schedule(function() -- 919
				if settled then -- 919
					return true -- 920
				end -- 920
				if not canceled and isCancelled and isCancelled() then -- 920
					canceled = true -- 922
					Git:cancel(jobId) -- 923
					finish({success = false, message = "git command canceled", status = status, interrupted = true}) -- 924
					return true -- 925
				end -- 925
				if finishFromStatus() then -- 925
					return true -- 927
				end -- 927
				local nowTime = os.time() -- 928
				if nowTime - startedAt >= timeout then -- 928
					Git:cancel(jobId) -- 930
					finish({success = false, message = "git command timed out", status = status}) -- 931
					return true -- 932
				end -- 932
				if onStatus and status and nowTime > lastEmitAt then -- 932
					lastEmitAt = nowTime -- 935
					onStatus(status) -- 936
				end -- 936
				return false -- 938
			end) -- 919
		end -- 867
	) -- 867
end -- 860
local function downloadFile(req) -- 943
	return __TS__New( -- 950
		__TS__Promise, -- 950
		function(____, resolve) -- 950
			local requestId = 0 -- 951
			local settled = false -- 952
			local bytesWritten = 0 -- 953
			local function finish(result) -- 954
				if settled then -- 954
					return -- 955
				end -- 955
				settled = true -- 956
				requestId = 0 -- 957
				resolve(nil, result) -- 958
			end -- 954
			Director.systemScheduler:schedule(function() -- 960
				if settled then -- 960
					return true -- 961
				end -- 961
				local ____this_9 -- 961
				____this_9 = req -- 962
				local ____opt_8 = ____this_9.isCancelled -- 962
				if (____opt_8 and ____opt_8(____this_9)) == true and requestId ~= 0 then -- 962
					HttpClient:cancel(requestId) -- 963
					finish({success = false, interrupted = true, message = "download canceled"}) -- 964
					return true -- 965
				end -- 965
				if requestId ~= 0 and not HttpClient:isRequestActive(requestId) then -- 965
					finish({success = false, message = "download request ended without a completion callback"}) -- 968
					return true -- 969
				end -- 969
				return false -- 971
			end) -- 960
			Director.systemScheduler:schedule(once(function() -- 973
				requestId = HttpClient:download( -- 974
					req.url, -- 974
					req.tempPath, -- 974
					req.timeout, -- 974
					function(interrupted, current, total) -- 974
						if type(current) == "number" and current > bytesWritten then -- 974
							bytesWritten = current -- 976
						end -- 976
						if interrupted then -- 976
							finish({success = false, interrupted = true, message = "download failed"}) -- 979
							return true -- 980
						end -- 980
						local ____this_11 -- 980
						____this_11 = req -- 982
						local ____opt_10 = ____this_11.isCancelled -- 982
						if (____opt_10 and ____opt_10(____this_11)) == true then -- 982
							finish({success = false, interrupted = true, message = "download canceled"}) -- 983
							return true -- 984
						end -- 984
						if current == total then -- 984
							finish({success = true, bytesWritten = bytesWritten}) -- 987
							return false -- 988
						end -- 988
						req:onProgress(current, total) -- 990
						return false -- 991
					end -- 974
				) -- 974
				if requestId == 0 then -- 974
					finish({success = false, message = "failed to schedule download request"}) -- 994
				else -- 994
					local ____this_13 -- 994
					____this_13 = req -- 995
					local ____opt_12 = ____this_13.isCancelled -- 995
					if (____opt_12 and ____opt_12(____this_13)) == true then -- 995
						HttpClient:cancel(requestId) -- 996
						finish({success = false, interrupted = true, message = "download canceled"}) -- 997
					end -- 997
				end -- 997
			end)) -- 973
		end -- 950
	) -- 950
end -- 943
local function getFileState(path) -- 1003
	local exists = Content:exist(path) -- 1004
	if not exists then -- 1004
		return {exists = false, content = "", bytes = 0} -- 1006
	end -- 1006
	if Content:isdir(path) then -- 1006
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 1013
	end -- 1013
	local content = Content:load(path) -- 1020
	if type(content) ~= "string" then -- 1020
		return {exists = true, content = "", bytes = 0} -- 1022
	end -- 1022
	return {exists = true, content = content, bytes = #content} -- 1028
end -- 1003
local function inspectReadableFile(path) -- 1035
	do -- 1035
		local function ____catch(e) -- 1035
			Log( -- 1057
				"Warn", -- 1057
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 1057
			) -- 1057
			return true, {success = true} -- 1058
		end -- 1058
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1058
			local size, isBinary = Content:getAttr(path) -- 1037
			if size == nil then -- 1037
				return true, {success = false, message = "failed to read file"} -- 1039
			end -- 1039
			if isBinary then -- 1039
				return true, { -- 1045
					success = false, -- 1046
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 1047
					size = type(size) == "number" and size or nil, -- 1048
					isBinary = true -- 1049
				} -- 1049
			end -- 1049
			return true, { -- 1052
				success = true, -- 1053
				size = type(size) == "number" and size or nil -- 1054
			} -- 1054
		end) -- 1054
		if not ____try then -- 1054
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1054
		end -- 1054
		if ____hasReturned then -- 1054
			return ____returnValue -- 1036
		end -- 1036
	end -- 1036
end -- 1035
local function isEngineLogFilePath(path) -- 1062
	return path == ENGINE_LOG_FILE -- 1063
end -- 1062
local function readEngineLogFile(path) -- 1066
	if not isEngineLogFilePath(path) then -- 1066
		return nil -- 1067
	end -- 1067
	local content = getEngineLogText() -- 1068
	if content == nil then -- 1068
		return {success = false, message = "failed to read engine logs"} -- 1070
	end -- 1070
	return {success = true, content = content, size = #content} -- 1072
end -- 1066
local function queryOne(sql, args) -- 1075
	local ____args_14 -- 1076
	if args then -- 1076
		____args_14 = DB:query(sql, args) -- 1076
	else -- 1076
		____args_14 = DB:query(sql) -- 1076
	end -- 1076
	local rows = ____args_14 -- 1076
	if not rows or #rows == 0 then -- 1076
		return nil -- 1077
	end -- 1077
	return rows[1] -- 1078
end -- 1075
local function isDtsFile(path) -- 1081
	return Path:getExt(Path:getName(path)) == "d" -- 1082
end -- 1081
local function isTiledEditorContent(content) -- 1085
	return __TS__StringStartsWith( -- 1086
		__TS__StringTrim(content), -- 1086
		"<?xml" -- 1086
	) -- 1086
end -- 1085
local function getSupportedBuildKind(path) -- 1091
	repeat -- 1091
		local ____switch201 = Path:getExt(path) -- 1091
		local ____cond201 = ____switch201 == "ts" or ____switch201 == "tsx" -- 1091
		if ____cond201 then -- 1091
			return "ts" -- 1093
		end -- 1093
		____cond201 = ____cond201 or ____switch201 == "xml" -- 1093
		if ____cond201 then -- 1093
			return "xml" -- 1094
		end -- 1094
		____cond201 = ____cond201 or ____switch201 == "tl" -- 1094
		if ____cond201 then -- 1094
			return "teal" -- 1095
		end -- 1095
		____cond201 = ____cond201 or ____switch201 == "lua" -- 1095
		if ____cond201 then -- 1095
			return "lua" -- 1096
		end -- 1096
		____cond201 = ____cond201 or ____switch201 == "yue" -- 1096
		if ____cond201 then -- 1096
			return "yue" -- 1097
		end -- 1097
		____cond201 = ____cond201 or ____switch201 == "yarn" -- 1097
		if ____cond201 then -- 1097
			return "yarn" -- 1098
		end -- 1098
		do -- 1098
			return nil -- 1099
		end -- 1099
	until true -- 1099
end -- 1091
local function getTaskHeadSeq(taskId) -- 1103
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1104
	if not row then -- 1104
		return nil -- 1105
	end -- 1105
	return row[1] or 0 -- 1106
end -- 1103
local function getTaskStatus(taskId) -- 1109
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1110
	if not row then -- 1110
		return nil -- 1111
	end -- 1111
	return toStr(row[1]) -- 1112
end -- 1109
local function getLastInsertRowId() -- 1115
	local row = queryOne("SELECT last_insert_rowid()") -- 1116
	return row and (row[1] or 0) or 0 -- 1117
end -- 1115
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 1120
	DB:exec( -- 1121
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 1121
		{ -- 1123
			taskId, -- 1123
			seq, -- 1123
			status, -- 1123
			summary, -- 1123
			toolName, -- 1123
			now() -- 1123
		} -- 1123
	) -- 1123
	return getLastInsertRowId() -- 1125
end -- 1120
local function getCheckpointEntries(checkpointId, desc) -- 1128
	if desc == nil then -- 1128
		desc = false -- 1128
	end -- 1128
	local rows = DB:query((("SELECT id, ord, path, op, before_exists,\n\t\t\tdora_decompress_text(before_data),\n\t\t\tafter_exists,\n\t\t\tdora_decompress_text(after_data)\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 1129
	if not rows then -- 1129
		return {} -- 1139
	end -- 1139
	local result = {} -- 1140
	do -- 1140
		local i = 0 -- 1141
		while i < #rows do -- 1141
			local row = rows[i + 1] -- 1142
			result[#result + 1] = { -- 1143
				id = row[1], -- 1144
				ord = row[2], -- 1145
				path = toStr(row[3]), -- 1146
				op = toStr(row[4]), -- 1147
				beforeExists = toBool(row[5]), -- 1148
				beforeContent = toStr(row[6]), -- 1149
				afterExists = toBool(row[7]), -- 1150
				afterContent = toStr(row[8]) -- 1151
			} -- 1151
			i = i + 1 -- 1141
		end -- 1141
	end -- 1141
	return result -- 1154
end -- 1128
local function getCheckpointEntryMetadata(checkpointId, desc) -- 1157
	if desc == nil then -- 1157
		desc = false -- 1157
	end -- 1157
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, after_exists, bytes_before, bytes_after\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 1158
	if not rows then -- 1158
		return {} -- 1165
	end -- 1165
	local result = {} -- 1166
	do -- 1166
		local i = 0 -- 1167
		while i < #rows do -- 1167
			local row = rows[i + 1] -- 1168
			result[#result + 1] = { -- 1169
				id = row[1], -- 1170
				ord = row[2], -- 1171
				path = toStr(row[3]), -- 1172
				op = toStr(row[4]), -- 1173
				beforeExists = toBool(row[5]), -- 1174
				afterExists = toBool(row[6]), -- 1175
				bytesBefore = row[7] or 0, -- 1176
				bytesAfter = row[8] or 0 -- 1177
			} -- 1177
			i = i + 1 -- 1167
		end -- 1167
	end -- 1167
	return result -- 1180
end -- 1157
local function rejectDuplicatePaths(changes) -- 1183
	local seen = __TS__New(Set) -- 1184
	for ____, change in ipairs(changes) do -- 1185
		local key = change.path -- 1186
		if seen:has(key) then -- 1186
			return key -- 1187
		end -- 1187
		seen:add(key) -- 1188
	end -- 1188
	return nil -- 1190
end -- 1183
local function getLinkedDeletePaths(workDir, path) -- 1193
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1194
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 1194
		return {} -- 1195
	end -- 1195
	local parent = Path:getPath(fullPath) -- 1196
	local baseName = string.lower(Path:getName(fullPath)) -- 1197
	local ext = Path:getExt(fullPath) -- 1198
	local linked = {} -- 1199
	for ____, file in ipairs(Content:getFiles(parent)) do -- 1200
		do -- 1200
			if string.lower(Path:getName(file)) ~= baseName then -- 1200
				goto __continue222 -- 1201
			end -- 1201
			local siblingExt = Path:getExt(file) -- 1202
			if siblingExt == "tl" and ext == "vs" then -- 1202
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1204
					workDir, -- 1204
					Path(parent, file) -- 1204
				) -- 1204
				goto __continue222 -- 1205
			end -- 1205
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 1205
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1208
					workDir, -- 1208
					Path(parent, file) -- 1208
				) -- 1208
			end -- 1208
		end -- 1208
		::__continue222:: -- 1208
	end -- 1208
	return linked -- 1211
end -- 1193
local function expandLinkedDeleteChanges(workDir, changes) -- 1214
	local expanded = {} -- 1215
	local seen = __TS__New(Set) -- 1216
	do -- 1216
		local i = 0 -- 1217
		while i < #changes do -- 1217
			do -- 1217
				local change = changes[i + 1] -- 1218
				if not seen:has(change.path) then -- 1218
					seen:add(change.path) -- 1220
					expanded[#expanded + 1] = change -- 1221
				end -- 1221
				if change.op ~= "delete" then -- 1221
					goto __continue229 -- 1223
				end -- 1223
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 1224
				do -- 1224
					local j = 0 -- 1225
					while j < #linkedPaths do -- 1225
						do -- 1225
							local linkedPath = linkedPaths[j + 1] -- 1226
							if seen:has(linkedPath) then -- 1226
								goto __continue233 -- 1227
							end -- 1227
							seen:add(linkedPath) -- 1228
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 1229
						end -- 1229
						::__continue233:: -- 1229
						j = j + 1 -- 1225
					end -- 1225
				end -- 1225
			end -- 1225
			::__continue229:: -- 1225
			i = i + 1 -- 1217
		end -- 1217
	end -- 1217
	return expanded -- 1232
end -- 1214
local function applySingleFile(path, exists, content) -- 1235
	if exists then -- 1235
		if not ensureDirForFile(path) then -- 1235
			return false -- 1237
		end -- 1237
		return Content:save(path, content) -- 1238
	end -- 1238
	if Content:exist(path) then -- 1238
		return Content:remove(path) -- 1241
	end -- 1241
	return true -- 1243
end -- 1235
local function rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 1246
	local entries = getCheckpointEntries(checkpointId, true) -- 1251
	local remaining = appliedCount -- 1252
	local failures = {} -- 1253
	do -- 1253
		local i = 0 -- 1254
		while i < #entries and remaining > 0 do -- 1254
			do -- 1254
				local entry = entries[i + 1] -- 1255
				if entry.ord > appliedCount then -- 1255
					goto __continue241 -- 1256
				end -- 1256
				local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1257
				if not fullPath or not applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) then -- 1257
					failures[#failures + 1] = entry.path -- 1259
				else -- 1259
					____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) -- 1261
				end -- 1261
				remaining = remaining - 1 -- 1263
			end -- 1263
			::__continue241:: -- 1263
			i = i + 1 -- 1254
		end -- 1254
	end -- 1254
	return #failures > 0 and "rollback failed for: " .. table.concat(failures, ", ") or nil -- 1265
end -- 1246
function ____exports.sendWebIDERefreshTree() -- 1285
	if HttpServer.wsConnectionCount == 0 then -- 1285
		return true -- 1287
	end -- 1287
	local payload = encodeJSON({name = "RefreshTree"}) -- 1289
	if not payload then -- 1289
		return false -- 1291
	end -- 1291
	emit("AppWS", "Send", payload) -- 1293
	return true -- 1294
end -- 1285
local function syncProjectFileToWebIDE(workDir, path) -- 1297
	local target = resolveWorkspaceFilePath(workDir, path) -- 1298
	if not target then -- 1298
		return false -- 1299
	end -- 1299
	if not Content:exist(target) then -- 1299
		return ____exports.sendWebIDEFileUpdate(target, false, "") -- 1301
	end -- 1301
	if Content:isdir(target) then -- 1301
		return ____exports.sendWebIDERefreshTree() -- 1304
	end -- 1304
	local content = "" -- 1306
	do -- 1306
		local function ____catch(e) -- 1306
			Log( -- 1314
				"Warn", -- 1314
				(("[Agent.Tools] failed to inspect file for Web IDE update file=" .. target) .. ": ") .. tostring(e) -- 1314
			) -- 1314
		end -- 1314
		local ____try, ____hasReturned = pcall(function() -- 1314
			local ____, isBinary = Content:getAttr(target) -- 1308
			if not isBinary then -- 1308
				local loaded = Content:load(target) -- 1310
				content = type(loaded) == "string" and loaded or "" -- 1311
			end -- 1311
		end) -- 1311
		if not ____try then -- 1311
			____catch(____hasReturned) -- 1311
		end -- 1311
	end -- 1311
	return ____exports.sendWebIDEFileUpdate(target, true, content) -- 1316
end -- 1297
local function refreshProjectTree(workDir, path) -- 1319
	local normalized = type(path) == "string" and __TS__StringTrim(path) or "" -- 1320
	if normalized == "" then -- 1320
		return ____exports.sendWebIDERefreshTree() -- 1322
	end -- 1322
	return syncProjectFileToWebIDE(workDir, normalized) -- 1324
end -- 1319
local function syncDownloadedFileToWebIDE(file) -- 1327
	local content = "" -- 1328
	do -- 1328
		local function ____catch(e) -- 1328
			Log( -- 1336
				"Warn", -- 1336
				(("[fetch_url] failed to inspect downloaded file for Web IDE update file=" .. file) .. ": ") .. tostring(e) -- 1336
			) -- 1336
		end -- 1336
		local ____try, ____hasReturned = pcall(function() -- 1336
			local ____, isBinary = Content:getAttr(file) -- 1330
			if not isBinary then -- 1330
				local loaded = Content:load(file) -- 1332
				content = type(loaded) == "string" and loaded or "" -- 1333
			end -- 1333
		end) -- 1333
		if not ____try then -- 1333
			____catch(____hasReturned) -- 1333
		end -- 1333
	end -- 1333
	return ____exports.sendWebIDEFileUpdate(file, true, content) -- 1338
end -- 1327
local function runSingleNonTsBuild(file) -- 1341
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1341
		return ____awaiter_resolve( -- 1341
			nil, -- 1341
			__TS__New( -- 1342
				__TS__Promise, -- 1342
				function(____, resolve) -- 1342
					local moduleName = "Script.Dev.WebServer" -- 1343
					local ____require_result_15 = require(moduleName) -- 1344
					local buildAsync = ____require_result_15.buildAsync -- 1344
					Director.systemScheduler:schedule(once(function() -- 1345
						local result = buildAsync(file) -- 1346
						resolve(nil, result) -- 1347
					end)) -- 1345
				end -- 1342
			) -- 1342
		) -- 1342
	end) -- 1342
end -- 1341
local transpileRequestSeq = 0 -- 1352
function ____exports.runSingleTsTranspile(file, content, projectRoot) -- 1354
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1354
		local done = false -- 1355
		transpileRequestSeq = transpileRequestSeq + 1 -- 1356
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 1357
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 1358
		if HttpServer.wsConnectionCount == 0 then -- 1358
			return ____awaiter_resolve(nil, result) -- 1358
		end -- 1358
		local listener = Node() -- 1366
		listener:gslot( -- 1367
			"AppWS", -- 1367
			function(event) -- 1367
				if event.type ~= "Receive" then -- 1367
					return -- 1368
				end -- 1368
				local res = safeJsonDecode(event.msg) -- 1369
				if not res or __TS__ArrayIsArray(res) then -- 1369
					return -- 1370
				end -- 1370
				local payload = res -- 1371
				if payload.name ~= "TranspileTS" then -- 1371
					return -- 1372
				end -- 1372
				if payload.id ~= requestId then -- 1372
					return -- 1373
				end -- 1373
				if payload.success then -- 1373
					local luaFile = Path:replaceExt(file, "lua") -- 1375
					if Content:save( -- 1375
						luaFile, -- 1376
						tostring(payload.luaCode) -- 1376
					) then -- 1376
						result = {success = true, file = file} -- 1377
					else -- 1377
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 1379
					end -- 1379
				else -- 1379
					result = { -- 1382
						success = false, -- 1382
						file = file, -- 1382
						message = tostring(payload.message) -- 1382
					} -- 1382
				end -- 1382
				done = true -- 1384
			end -- 1367
		) -- 1367
		local payload = encodeJSON({ -- 1386
			name = "TranspileTS", -- 1387
			id = requestId, -- 1388
			file = file, -- 1389
			content = content, -- 1390
			projectRoot = projectRoot -- 1391
		}) -- 1391
		if not payload then -- 1391
			listener:removeFromParent() -- 1394
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 1394
		end -- 1394
		__TS__Await(__TS__New( -- 1397
			__TS__Promise, -- 1397
			function(____, resolve) -- 1397
				Director.systemScheduler:schedule(once(function() -- 1398
					emit("AppWS", "Send", payload) -- 1399
					wait(function() return done end) -- 1400
					if not done then -- 1400
						listener:removeFromParent() -- 1402
					end -- 1402
					resolve(nil) -- 1404
				end)) -- 1398
			end -- 1397
		)) -- 1397
		return ____awaiter_resolve(nil, result) -- 1397
	end) -- 1397
end -- 1354
function ____exports.createTask(prompt, workMode) -- 1410
	if prompt == nil then -- 1410
		prompt = "" -- 1410
	end -- 1410
	if workMode == nil then -- 1410
		workMode = "code" -- 1410
	end -- 1410
	local storage = requireAgentStorage() -- 1411
	if not storage.success then -- 1411
		return storage -- 1412
	end -- 1412
	local t = now() -- 1413
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, work_mode, created_at, updated_at) VALUES(?, ?, 0, ?, ?, ?)", { -- 1414
		"RUNNING", -- 1416
		prompt, -- 1416
		workMode, -- 1416
		t, -- 1416
		t -- 1416
	}) -- 1416
	if affected <= 0 then -- 1416
		return {success = false, message = "failed to create task"} -- 1419
	end -- 1419
	return { -- 1421
		success = true, -- 1421
		taskId = getLastInsertRowId() -- 1421
	} -- 1421
end -- 1410
function ____exports.setTaskStatus(taskId, status) -- 1424
	DB:exec( -- 1425
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 1425
		{ -- 1425
			status, -- 1425
			now(), -- 1425
			taskId -- 1425
		} -- 1425
	) -- 1425
	Log( -- 1426
		"Info", -- 1426
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 1426
	) -- 1426
end -- 1424
function ____exports.listCheckpointsForTasks(taskIds) -- 1429
	local normalizedTaskIds = {} -- 1430
	local seenTaskIds = {} -- 1431
	do -- 1431
		local i = 0 -- 1432
		while i < #taskIds do -- 1432
			do -- 1432
				local taskId = math.floor(taskIds[i + 1]) -- 1433
				if taskId <= 0 or seenTaskIds[taskId] then -- 1433
					goto __continue290 -- 1434
				end -- 1434
				seenTaskIds[taskId] = true -- 1435
				normalizedTaskIds[#normalizedTaskIds + 1] = taskId -- 1436
			end -- 1436
			::__continue290:: -- 1436
			i = i + 1 -- 1432
		end -- 1432
	end -- 1432
	if #normalizedTaskIds == 0 then -- 1432
		return {} -- 1438
	end -- 1438
	local placeholders = table.concat( -- 1439
		__TS__ArrayMap( -- 1439
			normalizedTaskIds, -- 1439
			function() return "?" end -- 1439
		), -- 1439
		", " -- 1439
	) -- 1439
	local rows = DB:query(((("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id IN (") .. placeholders) .. ")\n\t\tORDER BY task_id DESC, seq DESC", normalizedTaskIds) -- 1440
	if not rows then -- 1440
		return {} -- 1447
	end -- 1447
	local items = {} -- 1448
	do -- 1448
		local i = 0 -- 1449
		while i < #rows do -- 1449
			local row = rows[i + 1] -- 1450
			items[#items + 1] = { -- 1451
				id = row[1], -- 1452
				taskId = row[2], -- 1453
				seq = row[3], -- 1454
				status = toStr(row[4]), -- 1455
				summary = toStr(row[5]), -- 1456
				toolName = toStr(row[6]), -- 1457
				createdAt = row[7] -- 1458
			} -- 1458
			i = i + 1 -- 1449
		end -- 1449
	end -- 1449
	return items -- 1461
end -- 1429
function ____exports.listCheckpoints(taskId) -- 1464
	return ____exports.listCheckpointsForTasks({taskId}) -- 1465
end -- 1464
function ____exports.getCheckpoint(checkpointId) -- 1468
	if checkpointId <= 0 then -- 1468
		return nil -- 1469
	end -- 1469
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE id = ?\n\t\tLIMIT 1", {checkpointId}) -- 1470
	if not rows or #rows == 0 then -- 1470
		return nil -- 1477
	end -- 1477
	local row = rows[1] -- 1478
	return { -- 1479
		id = row[1], -- 1480
		taskId = row[2], -- 1481
		seq = row[3], -- 1482
		status = toStr(row[4]), -- 1483
		summary = toStr(row[5]), -- 1484
		toolName = toStr(row[6]), -- 1485
		createdAt = row[7] -- 1486
	} -- 1486
end -- 1468
local function listCheckpointIdsForTask(taskId, desc) -- 1490
	if desc == nil then -- 1490
		desc = false -- 1490
	end -- 1490
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 1491
	if not rows then -- 1491
		return {} -- 1498
	end -- 1498
	local items = {} -- 1499
	do -- 1499
		local i = 0 -- 1500
		while i < #rows do -- 1500
			local row = rows[i + 1] -- 1501
			items[#items + 1] = {id = row[1], seq = row[2]} -- 1502
			i = i + 1 -- 1500
		end -- 1500
	end -- 1500
	return items -- 1507
end -- 1490
local function deriveFileOp(beforeExists, afterExists) -- 1510
	if not beforeExists and afterExists then -- 1510
		return "create" -- 1511
	end -- 1511
	if beforeExists and not afterExists then -- 1511
		return "delete" -- 1512
	end -- 1512
	return "write" -- 1513
end -- 1510
function ____exports.summarizeTaskChangeSet(taskId) -- 1516
	if not getTaskStatus(taskId) then -- 1516
		return {success = false, message = "task not found"} -- 1518
	end -- 1518
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1520
	local filesByPath = {} -- 1521
	local latestCheckpointId = nil -- 1527
	local latestCheckpointSeq = nil -- 1528
	do -- 1528
		local i = 0 -- 1529
		while i < #checkpoints do -- 1529
			local checkpoint = checkpoints[i + 1] -- 1530
			latestCheckpointId = checkpoint.id -- 1531
			latestCheckpointSeq = checkpoint.seq -- 1532
			local entries = getCheckpointEntryMetadata(checkpoint.id, false) -- 1533
			do -- 1533
				local j = 0 -- 1534
				while j < #entries do -- 1534
					local entry = entries[j + 1] -- 1535
					local item = filesByPath[entry.path] -- 1536
					if not item then -- 1536
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 1538
						filesByPath[entry.path] = item -- 1544
					end -- 1544
					item.afterExists = entry.afterExists -- 1546
					local ____item_checkpointIds_16 = item.checkpointIds -- 1546
					____item_checkpointIds_16[#____item_checkpointIds_16 + 1] = checkpoint.id -- 1547
					j = j + 1 -- 1534
				end -- 1534
			end -- 1534
			i = i + 1 -- 1529
		end -- 1529
	end -- 1529
	local files = {} -- 1550
	for ____, item in pairs(filesByPath) do -- 1551
		files[#files + 1] = { -- 1552
			path = item.path, -- 1553
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1554
			checkpointCount = #item.checkpointIds, -- 1555
			checkpointIds = item.checkpointIds -- 1556
		} -- 1556
	end -- 1556
	__TS__ArraySort( -- 1559
		files, -- 1559
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1559
	) -- 1559
	return { -- 1560
		success = true, -- 1561
		taskId = taskId, -- 1562
		checkpointCount = #checkpoints, -- 1563
		filesChanged = #files, -- 1564
		files = files, -- 1565
		latestCheckpointId = latestCheckpointId, -- 1566
		latestCheckpointSeq = latestCheckpointSeq -- 1567
	} -- 1567
end -- 1516
function ____exports.getTaskChangeSetDiff(taskId) -- 1571
	if not getTaskStatus(taskId) then -- 1571
		return {success = false, message = "task not found"} -- 1573
	end -- 1573
	local entryRows = DB:query(((("SELECT e.id, e.path, e.before_exists, e.after_exists\n\t\tFROM " .. TABLE_ENTRY) .. " e\n\t\tJOIN ") .. TABLE_CP) .. " c ON c.id = e.checkpoint_id\n\t\tWHERE c.task_id = ? AND c.status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY c.seq ASC, e.ord ASC", {taskId}) -- 1575
	if not entryRows or #entryRows == 0 then -- 1575
		return {success = false, message = "change set not found or empty"} -- 1584
	end -- 1584
	local filesByPath = {} -- 1586
	do -- 1586
		local i = 0 -- 1593
		while i < #entryRows do -- 1593
			local row = entryRows[i + 1] -- 1594
			local entryId = row[1] -- 1595
			local path = toStr(row[2]) -- 1596
			local item = filesByPath[path] -- 1597
			if not item then -- 1597
				item = { -- 1599
					path = path, -- 1600
					firstEntryId = entryId, -- 1601
					lastEntryId = entryId, -- 1602
					beforeExists = toBool(row[3]), -- 1603
					afterExists = toBool(row[4]) -- 1604
				} -- 1604
				filesByPath[path] = item -- 1606
			end -- 1606
			item.lastEntryId = entryId -- 1608
			item.afterExists = toBool(row[4]) -- 1609
			i = i + 1 -- 1593
		end -- 1593
	end -- 1593
	local files = {} -- 1611
	for ____, item in pairs(filesByPath) do -- 1612
		local contentRows = DB:query(((("SELECT\n\t\t\t\t(SELECT dora_decompress_text(before_data) FROM " .. TABLE_ENTRY) .. " WHERE id = ?),\n\t\t\t\t(SELECT dora_decompress_text(after_data) FROM ") .. TABLE_ENTRY) .. " WHERE id = ?)", {item.firstEntryId, item.lastEntryId}) -- 1613
		if not contentRows or #contentRows == 0 then -- 1613
			return {success = false, message = "failed to read checkpoint data for " .. item.path} -- 1620
		end -- 1620
		files[#files + 1] = { -- 1622
			path = item.path, -- 1623
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1624
			beforeExists = item.beforeExists, -- 1625
			afterExists = item.afterExists, -- 1626
			beforeContent = toStr(contentRows[1][1]), -- 1627
			afterContent = toStr(contentRows[1][2]) -- 1628
		} -- 1628
	end -- 1628
	__TS__ArraySort( -- 1631
		files, -- 1631
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1631
	) -- 1631
	return {success = true, files = files} -- 1632
end -- 1571
local function readWorkspaceFile(workDir, path, docLanguage) -- 1635
	local engineLog = readEngineLogFile(path) -- 1636
	if engineLog then -- 1636
		return engineLog -- 1637
	end -- 1637
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1638
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 1638
		local attr = inspectReadableFile(fullPath) -- 1640
		if not attr.success then -- 1640
			return attr -- 1641
		end -- 1641
		return { -- 1642
			success = true, -- 1642
			content = Content:load(fullPath), -- 1642
			size = attr.size -- 1642
		} -- 1642
	end -- 1642
	local docPath = resolveAgentDoraDocFilePath(path, docLanguage) -- 1644
	if docPath then -- 1644
		local attr = inspectReadableFile(docPath) -- 1646
		if not attr.success then -- 1646
			return attr -- 1647
		end -- 1647
		return { -- 1648
			success = true, -- 1648
			content = Content:load(docPath), -- 1648
			size = attr.size -- 1648
		} -- 1648
	end -- 1648
	if not fullPath then -- 1648
		return {success = false, message = "invalid path or workDir"} -- 1650
	end -- 1650
	return {success = false, message = "file not found"} -- 1651
end -- 1635
function ____exports.readFileRaw(workDir, path, docLanguage) -- 1654
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 1655
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 1655
		local attr = inspectReadableFile(path) -- 1657
		if not attr.success then -- 1657
			return attr -- 1658
		end -- 1658
		return { -- 1659
			success = true, -- 1659
			content = Content:load(path), -- 1659
			size = attr.size -- 1659
		} -- 1659
	end -- 1659
	return result -- 1661
end -- 1654
function ____exports.getLogs(req) -- 1676
	local text = getEngineLogText() -- 1677
	if text == nil then -- 1677
		return {success = false, message = "failed to read engine logs"} -- 1679
	end -- 1679
	local tailLines = math.max( -- 1681
		1, -- 1681
		math.floor(req and req.tailLines or 200) -- 1681
	) -- 1681
	local allLines = __TS__StringSplit(text, "\n") -- 1682
	local logs = __TS__ArraySlice( -- 1683
		allLines, -- 1683
		math.max(0, #allLines - tailLines) -- 1683
	) -- 1683
	return req and req.joinText and ({ -- 1684
		success = true, -- 1684
		logs = logs, -- 1684
		text = table.concat(logs, "\n") -- 1684
	}) or ({success = true, logs = logs}) -- 1684
end -- 1676
function ____exports.listFiles(req) -- 1687
	local root = req.path or "" -- 1693
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 1694
	if not searchRoot then -- 1694
		return {success = false, message = "invalid path or workDir"} -- 1696
	end -- 1696
	do -- 1696
		local function ____catch(e) -- 1696
			return true, { -- 1714
				success = false, -- 1714
				message = tostring(e) -- 1714
			} -- 1714
		end -- 1714
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1714
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 1699
			local globs = ensureSafeSearchGlobs(userGlobs) -- 1700
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 1701
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 1702
			local totalEntries = #files -- 1703
			local maxEntries = math.max( -- 1704
				1, -- 1704
				math.floor(req.maxEntries or 200) -- 1704
			) -- 1704
			local truncated = totalEntries > maxEntries -- 1705
			return true, { -- 1706
				success = true, -- 1707
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 1708
				totalEntries = totalEntries, -- 1709
				truncated = truncated, -- 1710
				maxEntries = maxEntries -- 1711
			} -- 1711
		end) -- 1711
		if not ____try then -- 1711
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1711
		end -- 1711
		if ____hasReturned then -- 1711
			return ____returnValue -- 1698
		end -- 1698
	end -- 1698
end -- 1687
local function formatReadSlice(content, startLine, endLine) -- 1718
	local lines = __TS__StringSplit(content, "\n") -- 1723
	local totalLines = #lines -- 1724
	if totalLines == 0 then -- 1724
		return { -- 1726
			success = true, -- 1727
			content = "", -- 1728
			totalLines = 0, -- 1729
			startLine = 1, -- 1730
			endLine = 0, -- 1731
			truncated = false -- 1732
		} -- 1732
	end -- 1732
	local rawStart = math.floor(startLine) -- 1735
	local rawEnd = math.floor(endLine) -- 1736
	if rawStart == 0 then -- 1736
		return {success = false, message = "startLine cannot be 0"} -- 1738
	end -- 1738
	if rawEnd == 0 then -- 1738
		return {success = false, message = "endLine cannot be 0"} -- 1741
	end -- 1741
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1743
	if start > totalLines then -- 1743
		return { -- 1747
			success = false, -- 1747
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1747
		} -- 1747
	end -- 1747
	local ____end = math.min( -- 1749
		totalLines, -- 1750
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1751
	) -- 1751
	if ____end < start then -- 1751
		return { -- 1756
			success = false, -- 1757
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1758
		} -- 1758
	end -- 1758
	local slice = {} -- 1761
	do -- 1761
		local i = start -- 1762
		while i <= ____end do -- 1762
			slice[#slice + 1] = lines[i] -- 1763
			i = i + 1 -- 1762
		end -- 1762
	end -- 1762
	local truncated = start > 1 or ____end < totalLines -- 1765
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1766
	local body = table.concat(slice, "\n") -- 1771
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1772
	return { -- 1773
		success = true, -- 1774
		content = output, -- 1775
		totalLines = totalLines, -- 1776
		startLine = start, -- 1777
		endLine = ____end, -- 1778
		truncated = truncated -- 1779
	} -- 1779
end -- 1718
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1783
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1790
	if not fallback.success or fallback.content == nil then -- 1790
		return fallback -- 1791
	end -- 1791
	local resolvedStartLine = startLine or 1 -- 1792
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1793
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1794
end -- 1783
local codeExtensions = { -- 1801
	".lua", -- 1801
	".tl", -- 1801
	".yue", -- 1801
	".ts", -- 1801
	".tsx", -- 1801
	".xml", -- 1801
	".md", -- 1801
	".yarn", -- 1801
	".wa", -- 1801
	".mod" -- 1801
} -- 1801
extensionLevels = { -- 1802
	vs = 2, -- 1803
	bl = 2, -- 1804
	ts = 1, -- 1805
	tsx = 1, -- 1806
	tl = 1, -- 1807
	yue = 1, -- 1808
	xml = 1, -- 1809
	lua = 0 -- 1810
} -- 1810
local function splitSearchPatterns(pattern) -- 1827
	local trimmed = __TS__StringTrim(pattern or "") -- 1828
	if trimmed == "" then -- 1828
		return {} -- 1829
	end -- 1829
	local out = {} -- 1830
	local seen = __TS__New(Set) -- 1831
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1832
		local p = __TS__StringTrim(tostring(p0)) -- 1833
		if p ~= "" and not seen:has(p) then -- 1833
			seen:add(p) -- 1835
			out[#out + 1] = p -- 1836
		end -- 1836
	end -- 1836
	return out -- 1839
end -- 1827
local function splitWhitespaceSearchPatterns(pattern) -- 1842
	local out = {} -- 1843
	local seen = __TS__New(Set) -- 1844
	for p0 in string.gmatch(pattern, "(%S+)") do -- 1845
		local p = __TS__StringTrim(tostring(p0)) -- 1846
		local key = string.lower(p) -- 1847
		if p ~= "" and not seen:has(key) then -- 1847
			seen:add(key) -- 1849
			out[#out + 1] = p -- 1850
		end -- 1850
	end -- 1850
	return out -- 1853
end -- 1842
local function mergeSearchFileResultsUnique(resultsList) -- 1856
	local merged = {} -- 1857
	local seen = __TS__New(Set) -- 1858
	do -- 1858
		local i = 0 -- 1859
		while i < #resultsList do -- 1859
			local list = resultsList[i + 1] -- 1860
			do -- 1860
				local j = 0 -- 1861
				while j < #list do -- 1861
					do -- 1861
						local row = list[j + 1] -- 1862
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1863
						if seen:has(key) then -- 1863
							goto __continue372 -- 1864
						end -- 1864
						seen:add(key) -- 1865
						merged[#merged + 1] = list[j + 1] -- 1866
					end -- 1866
					::__continue372:: -- 1866
					j = j + 1 -- 1861
				end -- 1861
			end -- 1861
			i = i + 1 -- 1859
		end -- 1859
	end -- 1859
	return merged -- 1869
end -- 1856
local function buildGroupedSearchResults(results) -- 1872
	local order = {} -- 1877
	local grouped = __TS__New(Map) -- 1878
	do -- 1878
		local i = 0 -- 1883
		while i < #results do -- 1883
			local row = results[i + 1] -- 1884
			local file = row.file -- 1885
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1886
			local bucket = grouped:get(key) -- 1887
			if not bucket then -- 1887
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1889
				grouped:set(key, bucket) -- 1890
				order[#order + 1] = key -- 1891
			end -- 1891
			bucket.totalMatches = bucket.totalMatches + 1 -- 1893
			local ____bucket_matches_21 = bucket.matches -- 1893
			____bucket_matches_21[#____bucket_matches_21 + 1] = results[i + 1] -- 1894
			i = i + 1 -- 1883
		end -- 1883
	end -- 1883
	local out = {} -- 1896
	do -- 1896
		local i = 0 -- 1901
		while i < #order do -- 1901
			local bucket = grouped:get(order[i + 1]) -- 1902
			if bucket then -- 1902
				out[#out + 1] = bucket -- 1903
			end -- 1903
			i = i + 1 -- 1901
		end -- 1901
	end -- 1901
	return out -- 1905
end -- 1872
local function mergeDoraDocSearchHitsUnique(resultsList) -- 1908
	local merged = {} -- 1909
	local seen = __TS__New(Set) -- 1910
	local index = 0 -- 1911
	local advanced = true -- 1912
	while advanced do -- 1912
		advanced = false -- 1914
		do -- 1914
			local i = 0 -- 1915
			while i < #resultsList do -- 1915
				do -- 1915
					local list = resultsList[i + 1] -- 1916
					if index >= #list then -- 1916
						goto __continue384 -- 1917
					end -- 1917
					advanced = true -- 1918
					local row = list[index + 1] -- 1919
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1920
					if seen:has(key) then -- 1920
						goto __continue384 -- 1921
					end -- 1921
					seen:add(key) -- 1922
					merged[#merged + 1] = row -- 1923
				end -- 1923
				::__continue384:: -- 1923
				i = i + 1 -- 1915
			end -- 1915
		end -- 1915
		index = index + 1 -- 1925
	end -- 1925
	return merged -- 1927
end -- 1908
local function getDoraDocFilePriority(file, docType, programmingLanguage) -- 1930
	if docType ~= "dora-api" then -- 1930
		return 100 -- 1931
	end -- 1931
	if programmingLanguage ~= "tsx" then -- 1931
		return 100 -- 1932
	end -- 1932
	repeat -- 1932
		local ____switch390 = string.lower(Path:getFilename(file)) -- 1932
		local ____cond390 = ____switch390 == "jsx.d.ts" -- 1932
		if ____cond390 then -- 1932
			return 0 -- 1934
		end -- 1934
		____cond390 = ____cond390 or ____switch390 == "dorax.d.ts" -- 1934
		if ____cond390 then -- 1934
			return 1 -- 1935
		end -- 1935
		____cond390 = ____cond390 or ____switch390 == "dora.d.ts" -- 1935
		if ____cond390 then -- 1935
			return 2 -- 1936
		end -- 1936
		do -- 1936
			return 100 -- 1937
		end -- 1937
	until true -- 1937
end -- 1930
local function sortDoraDocSearchHits(hits, docType, programmingLanguage) -- 1941
	local sorted = __TS__ArraySlice(hits) -- 1946
	__TS__ArraySort( -- 1947
		sorted, -- 1947
		function(____, a, b) -- 1947
			local pa = getDoraDocFilePriority(a.file, docType, programmingLanguage) -- 1948
			local pb = getDoraDocFilePriority(b.file, docType, programmingLanguage) -- 1949
			if pa ~= pb then -- 1949
				return pa - pb -- 1950
			end -- 1950
			local fa = string.lower(a.file) -- 1951
			local fb = string.lower(b.file) -- 1952
			if fa ~= fb then -- 1952
				return fa < fb and -1 or 1 -- 1953
			end -- 1953
			return (a.line or 0) - (b.line or 0) -- 1954
		end -- 1947
	) -- 1947
	return sorted -- 1956
end -- 1941
function ____exports.searchFiles(req) -- 1959
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1959
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1972
		if not resolvedPath then -- 1972
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1972
		end -- 1972
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1976
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1977
		if not searchRoot then -- 1977
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1977
		end -- 1977
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1977
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1977
		end -- 1977
		local patterns = splitSearchPatterns(req.pattern) -- 1984
		if #patterns == 0 then -- 1984
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1984
		end -- 1984
		return ____awaiter_resolve( -- 1984
			nil, -- 1984
			__TS__New( -- 1988
				__TS__Promise, -- 1988
				function(____, resolve) -- 1988
					Director.systemScheduler:schedule(once(function() -- 1989
						do -- 1989
							local function ____catch(e) -- 1989
								resolve( -- 2031
									nil, -- 2031
									{ -- 2031
										success = false, -- 2031
										message = tostring(e) -- 2031
									} -- 2031
								) -- 2031
							end -- 2031
							local ____try, ____hasReturned = pcall(function() -- 2031
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1991
								local allResults = {} -- 1994
								do -- 1994
									local i = 0 -- 1995
									while i < #patterns do -- 1995
										local ____Content_26 = Content -- 1996
										local ____Content_searchFilesAsync_27 = Content.searchFilesAsync -- 1996
										local ____patterns_index_25 = patterns[i + 1] -- 2001
										local ____req_useRegex_22 = req.useRegex -- 2002
										if ____req_useRegex_22 == nil then -- 2002
											____req_useRegex_22 = false -- 2002
										end -- 2002
										local ____req_caseSensitive_23 = req.caseSensitive -- 2003
										if ____req_caseSensitive_23 == nil then -- 2003
											____req_caseSensitive_23 = false -- 2003
										end -- 2003
										local ____req_includeContent_24 = req.includeContent -- 2004
										if ____req_includeContent_24 == nil then -- 2004
											____req_includeContent_24 = true -- 2004
										end -- 2004
										allResults[#allResults + 1] = ____Content_searchFilesAsync_27( -- 1996
											____Content_26, -- 1996
											searchRoot, -- 1997
											codeExtensions, -- 1998
											extensionLevels, -- 1999
											searchGlobs, -- 2000
											____patterns_index_25, -- 2001
											____req_useRegex_22, -- 2002
											____req_caseSensitive_23, -- 2003
											____req_includeContent_24, -- 2004
											req.contentWindow or 120 -- 2005
										) -- 2005
										i = i + 1 -- 1995
									end -- 1995
								end -- 1995
								local results = mergeSearchFileResultsUnique(allResults) -- 2008
								local totalResults = #results -- 2009
								local limit = math.max( -- 2010
									1, -- 2010
									math.floor(req.limit or 20) -- 2010
								) -- 2010
								local offset = math.max( -- 2011
									0, -- 2011
									math.floor(req.offset or 0) -- 2011
								) -- 2011
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 2012
								local nextOffset = offset + #paged -- 2013
								local hasMore = nextOffset < totalResults -- 2014
								local truncated = offset > 0 or hasMore -- 2015
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 2016
								local groupByFile = req.groupByFile == true -- 2017
								resolve( -- 2018
									nil, -- 2018
									{ -- 2018
										success = true, -- 2019
										results = relativeResults, -- 2020
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 2021
										totalResults = totalResults, -- 2022
										truncated = truncated, -- 2023
										limit = limit, -- 2024
										offset = offset, -- 2025
										nextOffset = nextOffset, -- 2026
										hasMore = hasMore, -- 2027
										groupByFile = groupByFile -- 2028
									} -- 2028
								) -- 2028
							end) -- 2028
							if not ____try then -- 2028
								____catch(____hasReturned) -- 2028
							end -- 2028
						end -- 2028
					end)) -- 1989
				end -- 1988
			) -- 1988
		) -- 1988
	end) -- 1988
end -- 1959
function ____exports.searchDoraDoc(req) -- 2037
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2037
		local pattern = __TS__StringTrim(req.pattern or "") -- 2048
		if pattern == "" then -- 2048
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2048
		end -- 2048
		local patterns = splitSearchPatterns(pattern) -- 2050
		if #patterns == 0 then -- 2050
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2050
		end -- 2050
		local docType = req.docType or "dora-api" -- 2052
		local target = getDoraDocSearchTarget(docType, req.docLanguage, req.programmingLanguage) -- 2053
		local docRoot = target.root -- 2054
		local resultBaseRoot = getDoraDocResultBaseRoot(docType, req.docLanguage) -- 2055
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 2055
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 2055
		end -- 2055
		local exts = target.exts -- 2059
		local dotExts = __TS__ArrayMap( -- 2060
			exts, -- 2060
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 2060
		) -- 2060
		local globs = target.globs -- 2061
		local limit = math.max( -- 2062
			1, -- 2062
			math.floor(req.limit or 10) -- 2062
		) -- 2062
		return ____awaiter_resolve( -- 2062
			nil, -- 2062
			__TS__New( -- 2064
				__TS__Promise, -- 2064
				function(____, resolve) -- 2064
					Director.systemScheduler:schedule(once(function() -- 2065
						do -- 2065
							local function ____catch(e) -- 2065
								resolve( -- 2145
									nil, -- 2145
									{ -- 2145
										success = false, -- 2145
										message = tostring(e) -- 2145
									} -- 2145
								) -- 2145
							end -- 2145
							local ____try, ____hasReturned = pcall(function() -- 2145
								local allHits = {} -- 2067
								do -- 2067
									local p = 0 -- 2068
									while p < #patterns do -- 2068
										local ____Content_32 = Content -- 2069
										local ____Content_searchFilesAsync_33 = Content.searchFilesAsync -- 2069
										local ____array_31 = __TS__SparseArrayNew( -- 2069
											docRoot, -- 2070
											dotExts, -- 2071
											{}, -- 2072
											ensureSafeSearchGlobs(globs), -- 2073
											patterns[p + 1] -- 2074
										) -- 2074
										local ____req_useRegex_28 = req.useRegex -- 2075
										if ____req_useRegex_28 == nil then -- 2075
											____req_useRegex_28 = false -- 2075
										end -- 2075
										__TS__SparseArrayPush(____array_31, ____req_useRegex_28) -- 2075
										local ____req_caseSensitive_29 = req.caseSensitive -- 2076
										if ____req_caseSensitive_29 == nil then -- 2076
											____req_caseSensitive_29 = false -- 2076
										end -- 2076
										__TS__SparseArrayPush(____array_31, ____req_caseSensitive_29) -- 2076
										local ____req_includeContent_30 = req.includeContent -- 2077
										if ____req_includeContent_30 == nil then -- 2077
											____req_includeContent_30 = true -- 2077
										end -- 2077
										__TS__SparseArrayPush(____array_31, ____req_includeContent_30, req.contentWindow or 80) -- 2077
										local raw = ____Content_searchFilesAsync_33( -- 2069
											____Content_32, -- 2069
											__TS__SparseArraySpread(____array_31) -- 2069
										) -- 2069
										local hits = {} -- 2080
										do -- 2080
											local i = 0 -- 2081
											while i < #raw do -- 2081
												do -- 2081
													local row = raw[i + 1] -- 2082
													local file = toDocRelativePath(resultBaseRoot, row.file, docType) -- 2083
													if file == "" then -- 2083
														goto __continue417 -- 2084
													end -- 2084
													hits[#hits + 1] = { -- 2085
														file = file, -- 2086
														line = type(row.line) == "number" and row.line or nil, -- 2087
														content = type(row.content) == "string" and row.content or nil -- 2088
													} -- 2088
												end -- 2088
												::__continue417:: -- 2088
												i = i + 1 -- 2081
											end -- 2081
										end -- 2081
										allHits[#allHits + 1] = __TS__ArraySlice( -- 2091
											sortDoraDocSearchHits(hits, docType, req.programmingLanguage), -- 2091
											0, -- 2091
											limit -- 2091
										) -- 2091
										p = p + 1 -- 2068
									end -- 2068
								end -- 2068
								local hits = mergeDoraDocSearchHitsUnique(allHits) -- 2093
								local fallbackPatterns -- 2094
								if #hits == 0 and #patterns == 1 and req.useRegex ~= true and (string.find(pattern, "|", nil, true) or 0) - 1 < 0 then -- 2094
									local terms = splitWhitespaceSearchPatterns(pattern) -- 2099
									if #terms > 1 then -- 2099
										fallbackPatterns = terms -- 2101
										local fallbackHits = {} -- 2102
										do -- 2102
											local p = 0 -- 2103
											while p < #terms do -- 2103
												local ____Content_37 = Content -- 2104
												local ____Content_searchFilesAsync_38 = Content.searchFilesAsync -- 2104
												local ____array_36 = __TS__SparseArrayNew( -- 2104
													docRoot, -- 2105
													dotExts, -- 2106
													{}, -- 2107
													ensureSafeSearchGlobs(globs), -- 2108
													terms[p + 1], -- 2109
													false -- 2110
												) -- 2110
												local ____req_caseSensitive_34 = req.caseSensitive -- 2111
												if ____req_caseSensitive_34 == nil then -- 2111
													____req_caseSensitive_34 = false -- 2111
												end -- 2111
												__TS__SparseArrayPush(____array_36, ____req_caseSensitive_34) -- 2111
												local ____req_includeContent_35 = req.includeContent -- 2112
												if ____req_includeContent_35 == nil then -- 2112
													____req_includeContent_35 = true -- 2112
												end -- 2112
												__TS__SparseArrayPush(____array_36, ____req_includeContent_35, req.contentWindow or 80) -- 2112
												local raw = ____Content_searchFilesAsync_38( -- 2104
													____Content_37, -- 2104
													__TS__SparseArraySpread(____array_36) -- 2104
												) -- 2104
												local termHits = {} -- 2115
												do -- 2115
													local i = 0 -- 2116
													while i < #raw do -- 2116
														do -- 2116
															local row = raw[i + 1] -- 2117
															local file = toDocRelativePath(resultBaseRoot, row.file, docType) -- 2118
															if file == "" then -- 2118
																goto __continue424 -- 2119
															end -- 2119
															termHits[#termHits + 1] = { -- 2120
																file = file, -- 2121
																line = type(row.line) == "number" and row.line or nil, -- 2122
																content = type(row.content) == "string" and row.content or nil -- 2123
															} -- 2123
														end -- 2123
														::__continue424:: -- 2123
														i = i + 1 -- 2116
													end -- 2116
												end -- 2116
												fallbackHits[#fallbackHits + 1] = __TS__ArraySlice( -- 2126
													sortDoraDocSearchHits(termHits, docType, req.programmingLanguage), -- 2126
													0, -- 2126
													limit -- 2126
												) -- 2126
												p = p + 1 -- 2103
											end -- 2103
										end -- 2103
										hits = mergeDoraDocSearchHitsUnique(fallbackHits) -- 2128
									end -- 2128
								end -- 2128
								resolve(nil, { -- 2131
									success = true, -- 2132
									docType = docType, -- 2133
									docLanguage = req.docLanguage, -- 2134
									programmingLanguage = req.programmingLanguage, -- 2135
									exts = exts, -- 2136
									results = hits, -- 2137
									hint = "Use read_file directly with the namespaced file value from a search result to view the complete authoritative document.", -- 2138
									totalResults = #hits, -- 2139
									truncated = false, -- 2140
									limit = limit, -- 2141
									fallbackPatterns = fallbackPatterns -- 2142
								}) -- 2142
							end) -- 2142
							if not ____try then -- 2142
								____catch(____hasReturned) -- 2142
							end -- 2142
						end -- 2142
					end)) -- 2065
				end -- 2064
			) -- 2064
		) -- 2064
	end) -- 2064
end -- 2037
function ____exports.searchDoraDocHttp(req, callback) -- 2151
	local ____self_39 = ____exports.searchDoraDoc(req) -- 2151
	____self_39["then"]( -- 2151
		____self_39, -- 2151
		function(____, result) return callback(result) end -- 2162
	) -- 2162
end -- 2151
function ____exports.readDoraDoc(req) -- 2165
	local requestedFile = table.concat( -- 2171
		__TS__StringSplit(req.file or "", "\\"), -- 2171
		"/" -- 2171
	) -- 2171
	local file = requestedFile -- 2172
	local namespacedType = nil -- 2173
	if __TS__StringStartsWith(requestedFile, AGENT_DORA_DOC_PREFIX) then -- 2173
		local namespaced = __TS__StringSlice(requestedFile, #AGENT_DORA_DOC_PREFIX) -- 2175
		if __TS__StringStartsWith(namespaced, "dora-api/") then -- 2175
			namespacedType = "dora-api" -- 2177
			file = string.sub(namespaced, 10) -- 2178
		elseif __TS__StringStartsWith(namespaced, "love-api/") then -- 2178
			namespacedType = "love-api" -- 2180
			file = string.sub(namespaced, 10) -- 2181
		elseif __TS__StringStartsWith(namespaced, "tic80-api/") then -- 2181
			namespacedType = "tic80-api" -- 2183
			file = string.sub(namespaced, 11) -- 2184
		elseif __TS__StringStartsWith(namespaced, "dora-tutorial/") then -- 2184
			namespacedType = "dora-tutorial" -- 2186
			file = string.sub(namespaced, 15) -- 2187
		elseif __TS__StringStartsWith(namespaced, "api/") then -- 2187
			namespacedType = "dora-api" -- 2189
			file = string.sub(namespaced, 5) -- 2190
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 2190
			namespacedType = "dora-tutorial" -- 2192
			file = string.sub(namespaced, 10) -- 2193
		else -- 2193
			return {success = false, message = "invalid Dora doc namespace"} -- 2195
		end -- 2195
	end -- 2195
	if not isValidWorkspacePath(file) or file == "." then -- 2195
		return {success = false, message = "invalid file"} -- 2199
	end -- 2199
	local lowerFile = string.lower(file) -- 2201
	local isTutorialDoc = __TS__StringEndsWith(lowerFile, ".md") -- 2202
	local isAPIDoc = __TS__StringEndsWith(lowerFile, ".ts") or __TS__StringEndsWith(lowerFile, ".tl") -- 2203
	if not isTutorialDoc and not isAPIDoc then -- 2203
		return {success = false, message = "unsupported doc file type"} -- 2204
	end -- 2204
	local docType = namespacedType or (isTutorialDoc and "dora-tutorial" or "dora-api") -- 2205
	if not isDoraDocFileInScope(docType, file) then -- 2205
		return {success = false, message = "document is outside the requested search type"} -- 2207
	end -- 2207
	local root = getDoraDocResultBaseRoot(docType, req.docLanguage) -- 2209
	local fullPath = Path(root, file) -- 2210
	local relative = Path:getRelative(fullPath, root) -- 2211
	if relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 2211
		return {success = false, message = "invalid file"} -- 2213
	end -- 2213
	local readResult = ____exports.readFile(root, file, req.startLine or 1, req.endLine or -1) -- 2215
	if not readResult.success then -- 2215
		return readResult -- 2216
	end -- 2216
	return { -- 2217
		success = true, -- 2218
		docLanguage = req.docLanguage, -- 2219
		file = file, -- 2220
		content = readResult.content, -- 2221
		startLine = readResult.startLine, -- 2222
		endLine = readResult.endLine -- 2223
	} -- 2223
end -- 2165
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 2227
	if options == nil then -- 2227
		options = {} -- 2227
	end -- 2227
	local storage = requireAgentStorage() -- 2228
	if not storage.success then -- 2228
		return storage -- 2229
	end -- 2229
	if #changes == 0 then -- 2229
		return {success = false, message = "empty changes"} -- 2231
	end -- 2231
	if not isValidWorkDir(workDir) then -- 2231
		return {success = false, message = "invalid workDir"} -- 2234
	end -- 2234
	if not getTaskStatus(taskId) then -- 2234
		return {success = false, message = "task not found"} -- 2237
	end -- 2237
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 2239
	local dup = rejectDuplicatePaths(expandedChanges) -- 2240
	if dup then -- 2240
		return {success = false, message = "duplicate path in batch: " .. dup} -- 2242
	end -- 2242
	for ____, change in ipairs(expandedChanges) do -- 2245
		if not isValidWorkspacePath(change.path) then -- 2245
			return {success = false, message = "invalid path: " .. change.path} -- 2247
		end -- 2247
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 2247
			return {success = false, message = "missing content for " .. change.path} -- 2250
		end -- 2250
	end -- 2250
	local headSeq = getTaskHeadSeq(taskId) -- 2254
	if headSeq == nil then -- 2254
		return {success = false, message = "task not found"} -- 2255
	end -- 2255
	local nextSeq = headSeq + 1 -- 2256
	local preparedEntries = {} -- 2258
	do -- 2258
		local i = 0 -- 2259
		while i < #expandedChanges do -- 2259
			local change = expandedChanges[i + 1] -- 2260
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 2261
			if not fullPath then -- 2261
				return {success = false, message = "invalid path: " .. change.path} -- 2263
			end -- 2263
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 2263
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 2266
			end -- 2266
			local before = getFileState(fullPath) -- 2268
			local afterExists = change.op ~= "delete" -- 2269
			local afterContent = afterExists and (change.content or "") or "" -- 2270
			preparedEntries[#preparedEntries + 1] = { -- 2271
				id = 0, -- 2272
				ord = i + 1, -- 2273
				path = change.path, -- 2274
				op = change.op, -- 2275
				beforeExists = before.exists, -- 2276
				beforeContent = before.content, -- 2277
				afterExists = afterExists, -- 2278
				afterContent = afterContent -- 2279
			} -- 2279
			i = i + 1 -- 2259
		end -- 2259
	end -- 2259
	local checkpointId = insertCheckpoint( -- 2283
		taskId, -- 2283
		nextSeq, -- 2283
		options.summary or "", -- 2283
		options.toolName or "", -- 2283
		"PREPARED" -- 2283
	) -- 2283
	if checkpointId <= 0 then -- 2283
		return {success = false, message = "failed to create checkpoint"} -- 2285
	end -- 2285
	local entryRows = {} -- 2287
	do -- 2287
		local i = 0 -- 2288
		while i < #preparedEntries do -- 2288
			local entry = preparedEntries[i + 1] -- 2289
			entryRows[#entryRows + 1] = { -- 2290
				checkpointId, -- 2291
				entry.ord, -- 2292
				entry.path, -- 2293
				entry.op, -- 2294
				entry.beforeExists and 1 or 0, -- 2295
				entry.beforeContent, -- 2296
				entry.afterExists and 1 or 0, -- 2297
				entry.afterContent, -- 2298
				#entry.beforeContent, -- 2299
				#entry.afterContent -- 2300
			} -- 2300
			i = i + 1 -- 2288
		end -- 2288
	end -- 2288
	local entryInsert = {("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_data, after_exists, after_data, bytes_before, bytes_after)\n\t\tVALUES(?, ?, ?, ?, ?, dora_compress_text(?), ?, dora_compress_text(?), ?, ?)", entryRows} -- 2303
	if not DB:transaction({entryInsert}) then -- 2303
		DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2309
		return {success = false, message = "failed to insert checkpoint entries"} -- 2310
	end -- 2310
	local appliedCount = 0 -- 2313
	for ____, entry in ipairs(preparedEntries) do -- 2314
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2315
		if not fullPath then -- 2315
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2317
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2318
			return {success = false, message = ("invalid path: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2319
		end -- 2319
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 2321
		if not ok then -- 2321
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2323
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount + 1) -- 2324
			return {success = false, message = ("failed to apply file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2325
		end -- 2325
		appliedCount = appliedCount + 1 -- 2327
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 2327
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2329
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2330
			return {success = false, message = ("failed to sync file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; all applied files restored")} -- 2331
		end -- 2331
	end -- 2331
	DB:exec( -- 2335
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 2335
		{ -- 2337
			"APPLIED", -- 2337
			now(), -- 2337
			checkpointId -- 2337
		} -- 2337
	) -- 2337
	DB:exec( -- 2339
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 2339
		{ -- 2341
			nextSeq, -- 2341
			now(), -- 2341
			taskId -- 2341
		} -- 2341
	) -- 2341
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 2343
end -- 2227
function ____exports.deleteFile(taskId, workDir, targetFile, options) -- 2351
	if options == nil then -- 2351
		options = {} -- 2351
	end -- 2351
	local storage = requireAgentStorage() -- 2352
	if not storage.success then -- 2352
		return storage -- 2353
	end -- 2353
	if not isValidWorkDir(workDir) then -- 2353
		return {success = false, message = "invalid workDir"} -- 2355
	end -- 2355
	if not getTaskStatus(taskId) then -- 2355
		return {success = false, message = "task not found"} -- 2358
	end -- 2358
	if not isValidWorkspacePath(targetFile) then -- 2358
		return {success = false, message = "invalid path: " .. targetFile} -- 2361
	end -- 2361
	local fullPath = resolveWorkspaceFilePath(workDir, targetFile) -- 2363
	if not fullPath then -- 2363
		return {success = false, message = "invalid path: " .. targetFile} -- 2365
	end -- 2365
	if Content:exist(fullPath) and Content:isdir(fullPath) then -- 2365
		return {success = false, message = "delete_file only supports files, not directories: " .. targetFile} -- 2368
	end -- 2368
	local isBinary = false -- 2371
	if Content:exist(fullPath) then -- 2371
		do -- 2371
			local function ____catch(e) -- 2371
				Log( -- 2377
					"Warn", -- 2377
					(("[Agent.Tools] Content.getAttr failed before deleting " .. fullPath) .. ": ") .. tostring(e) -- 2377
				) -- 2377
			end -- 2377
			local ____try, ____hasReturned = pcall(function() -- 2377
				local ____, detectedBinary = Content:getAttr(fullPath) -- 2374
				isBinary = detectedBinary == true -- 2375
			end) -- 2375
			if not ____try then -- 2375
				____catch(____hasReturned) -- 2375
			end -- 2375
		end -- 2375
	end -- 2375
	if not isBinary then -- 2375
		local result = ____exports.applyFileChanges(taskId, workDir, {{path = targetFile, op = "delete"}}, options) -- 2381
		if not result.success then -- 2381
			return result -- 2382
		end -- 2382
		return __TS__ObjectAssign({}, result, {checkpointed = true, reversible = true, binary = false}) -- 2383
	end -- 2383
	if not Content:remove(fullPath) then -- 2383
		return {success = false, message = "failed to delete binary file: " .. targetFile} -- 2392
	end -- 2392
	if not ____exports.sendWebIDEFileUpdate(fullPath, false, "") then -- 2392
		____exports.sendWebIDERefreshTree() -- 2395
	end -- 2395
	return { -- 2397
		success = true, -- 2398
		taskId = taskId, -- 2399
		checkpointed = false, -- 2400
		reversible = false, -- 2401
		binary = true, -- 2402
		message = "Binary file deleted directly without a checkpoint; this deletion cannot be rolled back." -- 2403
	} -- 2403
end -- 2351
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 2407
	if not isValidWorkDir(workDir) then -- 2407
		return {success = false, message = "invalid workDir"} -- 2408
	end -- 2408
	if checkpointId <= 0 then -- 2408
		return {success = false, message = "invalid checkpointId"} -- 2409
	end -- 2409
	local entries = getCheckpointEntries(checkpointId, true) -- 2410
	if #entries == 0 then -- 2410
		return {success = false, message = "checkpoint not found or empty"} -- 2412
	end -- 2412
	for ____, entry in ipairs(entries) do -- 2414
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2415
		if not fullPath then -- 2415
			return {success = false, message = "invalid path: " .. entry.path} -- 2417
		end -- 2417
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 2419
		if not ok then -- 2419
			Log( -- 2421
				"Error", -- 2421
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2421
			) -- 2421
			Log( -- 2422
				"Info", -- 2422
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2422
			) -- 2422
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 2423
		end -- 2423
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 2423
			Log( -- 2426
				"Error", -- 2426
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2426
			) -- 2426
			Log( -- 2427
				"Info", -- 2427
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2427
			) -- 2427
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 2428
		end -- 2428
	end -- 2428
	DB:exec( -- 2431
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 2431
		{ -- 2431
			"REVERTED", -- 2431
			now(), -- 2431
			checkpointId -- 2431
		} -- 2431
	) -- 2431
	return {success = true, checkpointId = checkpointId} -- 2432
end -- 2407
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 2435
	if not isValidWorkDir(workDir) then -- 2435
		return {success = false, message = "invalid workDir"} -- 2436
	end -- 2436
	if not getTaskStatus(taskId) then -- 2436
		return {success = false, message = "task not found"} -- 2437
	end -- 2437
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 2438
	if #checkpoints == 0 then -- 2438
		return {success = false, message = "change set not found or empty"} -- 2440
	end -- 2440
	local lastCheckpointId = 0 -- 2442
	do -- 2442
		local i = 0 -- 2443
		while i < #checkpoints do -- 2443
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 2444
			if not result.success then -- 2444
				return {success = false, message = result.message} -- 2445
			end -- 2445
			lastCheckpointId = checkpoints[i + 1].id -- 2446
			i = i + 1 -- 2443
		end -- 2443
	end -- 2443
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 2448
end -- 2435
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 2456
	return getCheckpointEntries(checkpointId, false) -- 2457
end -- 2456
function ____exports.getCheckpointDiff(checkpointId) -- 2460
	if checkpointId <= 0 then -- 2460
		return {success = false, message = "invalid checkpointId"} -- 2462
	end -- 2462
	local entries = getCheckpointEntries(checkpointId, false) -- 2464
	if #entries == 0 then -- 2464
		return {success = false, message = "checkpoint not found or empty"} -- 2466
	end -- 2466
	return { -- 2468
		success = true, -- 2469
		files = __TS__ArrayMap( -- 2470
			entries, -- 2470
			function(____, entry) return { -- 2470
				path = entry.path, -- 2471
				op = entry.op, -- 2472
				beforeExists = entry.beforeExists, -- 2473
				afterExists = entry.afterExists, -- 2474
				beforeContent = entry.beforeContent, -- 2475
				afterContent = entry.afterContent -- 2476
			} end -- 2476
		) -- 2476
	} -- 2476
end -- 2460
local function finalizeBuildResult(workDir, messages) -- 2481
	local normalized = __TS__ArrayMap( -- 2482
		messages, -- 2482
		function(____, m) return m.success and __TS__ObjectAssign( -- 2482
			{}, -- 2483
			m, -- 2483
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2483
		) or __TS__ObjectAssign( -- 2483
			{}, -- 2484
			m, -- 2484
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2484
		) end -- 2484
	) -- 2484
	local total = #normalized -- 2485
	local failed = 0 -- 2486
	do -- 2486
		local i = 0 -- 2487
		while i < #normalized do -- 2487
			if not normalized[i + 1].success then -- 2487
				failed = failed + 1 -- 2488
			end -- 2488
			i = i + 1 -- 2487
		end -- 2487
	end -- 2487
	local passed = total - failed -- 2490
	if failed > 0 then -- 2490
		return { -- 2492
			success = false, -- 2493
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 2494
			total = total, -- 2495
			passed = passed, -- 2496
			failed = failed, -- 2497
			messages = normalized -- 2498
		} -- 2498
	end -- 2498
	return { -- 2501
		success = true, -- 2502
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 2503
		total = total, -- 2504
		passed = passed, -- 2505
		failed = 0, -- 2506
		messages = normalized -- 2507
	} -- 2507
end -- 2481
function ____exports.build(req) -- 2511
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2511
		local targetRel = req.path or "" -- 2512
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2513
		if not target then -- 2513
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2513
		end -- 2513
		if not Content:exist(target) then -- 2513
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2513
		end -- 2513
		local messages = {} -- 2520
		if not Content:isdir(target) then -- 2520
			local kind = getSupportedBuildKind(target) -- 2522
			if not kind then -- 2522
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2522
			end -- 2522
			if kind == "ts" then -- 2522
				local content = Content:load(target) -- 2527
				if content == nil then -- 2527
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2527
				end -- 2527
				if isTiledEditorContent(content) then -- 2527
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2532
					return ____awaiter_resolve( -- 2532
						nil, -- 2532
						finalizeBuildResult(req.workDir, messages) -- 2533
					) -- 2533
				end -- 2533
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2533
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2533
				end -- 2533
				if not isDtsFile(target) then -- 2533
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir)) -- 2539
				end -- 2539
			else -- 2539
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2542
			end -- 2542
			Log( -- 2544
				"Info", -- 2544
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2544
			) -- 2544
			return ____awaiter_resolve( -- 2544
				nil, -- 2544
				finalizeBuildResult(req.workDir, messages) -- 2545
			) -- 2545
		end -- 2545
		local listResult = ____exports.listFiles({ -- 2547
			workDir = req.workDir, -- 2548
			path = targetRel, -- 2549
			globs = __TS__ArrayMap( -- 2550
				codeExtensions, -- 2550
				function(____, e) return "**/*" .. e end -- 2550
			), -- 2550
			maxEntries = 10000 -- 2551
		}) -- 2551
		local relFiles = listResult.success and listResult.files or ({}) -- 2554
		local tsFileData = {} -- 2555
		local buildQueue = {} -- 2556
		for ____, rel in ipairs(relFiles) do -- 2557
			do -- 2557
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2558
				local kind = getSupportedBuildKind(file) -- 2559
				if not kind then -- 2559
					goto __continue520 -- 2560
				end -- 2560
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2561
				if kind ~= "ts" then -- 2561
					goto __continue520 -- 2563
				end -- 2563
				local content = Content:load(file) -- 2565
				if content == nil then -- 2565
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2567
					goto __continue520 -- 2568
				end -- 2568
				if isTiledEditorContent(content) then -- 2568
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2571
					goto __continue520 -- 2572
				end -- 2572
				tsFileData[file] = content -- 2574
			end -- 2574
			::__continue520:: -- 2574
		end -- 2574
		do -- 2574
			local i = 0 -- 2576
			while i < #buildQueue do -- 2576
				do -- 2576
					local ____buildQueue_index_40 = buildQueue[i + 1] -- 2577
					local file = ____buildQueue_index_40.file -- 2577
					local kind = ____buildQueue_index_40.kind -- 2577
					if kind == "ts" then -- 2577
						local content = tsFileData[file] -- 2579
						if content == nil or isDtsFile(file) then -- 2579
							goto __continue527 -- 2581
						end -- 2581
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2581
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2584
							goto __continue527 -- 2585
						end -- 2585
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir)) -- 2587
						goto __continue527 -- 2588
					end -- 2588
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2590
				end -- 2590
				::__continue527:: -- 2590
				i = i + 1 -- 2576
			end -- 2576
		end -- 2576
		if #messages == 0 then -- 2576
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2593
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2593
		end -- 2593
		Log( -- 2596
			"Info", -- 2596
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2596
		) -- 2596
		return ____awaiter_resolve( -- 2596
			nil, -- 2596
			finalizeBuildResult(req.workDir, messages) -- 2597
		) -- 2597
	end) -- 2597
end -- 2511
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2600
local EXECUTE_COMMAND_ERROR_MAX = 4000 -- 2601
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 2602
local agentEntryRuntimeOwner = "" -- 2603
local function truncateCommandOutput(output) -- 2605
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2605
		return output -- 2606
	end -- 2606
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2607
end -- 2605
local function truncateCommandError(message) -- 2610
	if #message <= EXECUTE_COMMAND_ERROR_MAX then -- 2610
		return message -- 2611
	end -- 2611
	return __TS__StringSlice(message, 0, EXECUTE_COMMAND_ERROR_MAX) .. "\n... error message truncated ..." -- 2612
end -- 2610
local function executeLuaCommand(req) -- 2615
	local code = __TS__StringTrim(req.code or "") -- 2623
	if code == "" then -- 2623
		return __TS__Promise.resolve({ -- 2625
			success = false, -- 2625
			mode = "lua", -- 2625
			output = "", -- 2625
			message = "missing code", -- 2625
			phase = "validate" -- 2625
		}) -- 2625
	end -- 2625
	local output = {} -- 2627
	local entry = require("Script.Dev.Entry") -- 2628
	local ownsEntryRuntime = false -- 2629
	local contentAccessed = false -- 2630
	local refreshTreeCalled = false -- 2631
	local entryObjectBaseline = 0 -- 2632
	local entryLuaRefBaseline = 0 -- 2633
	local function acquireEntryRuntime() -- 2634
		if agentEntryRuntimeOwner ~= "" and agentEntryRuntimeOwner ~= req.operationId then -- 2634
			error("Dora entry runtime is busy with another Agent command") -- 2636
		end -- 2636
		agentEntryRuntimeOwner = req.operationId -- 2638
		ownsEntryRuntime = true -- 2639
	end -- 2634
	local function stopOwnedEntry() -- 2641
		if not ownsEntryRuntime then -- 2641
			return nil -- 2642
		end -- 2642
		local cleanupError -- 2643
		do -- 2643
			local function ____catch(e) -- 2643
				cleanupError = "failed to stop Agent test entry: " .. tostring(e) -- 2647
			end -- 2647
			local ____try, ____hasReturned = pcall(function() -- 2647
				entry.stop() -- 2645
			end) -- 2645
			if not ____try then -- 2645
				____catch(____hasReturned) -- 2645
			end -- 2645
		end -- 2645
		ownsEntryRuntime = false -- 2649
		if agentEntryRuntimeOwner == req.operationId then -- 2649
			agentEntryRuntimeOwner = "" -- 2651
		end -- 2651
		return cleanupError -- 2653
	end -- 2641
	local function startEntryWatchdog() -- 2655
		entryObjectBaseline = Dora.Object.count -- 2656
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 2657
	end -- 2655
	local function checkEntryWatchdog() -- 2659
		if not ownsEntryRuntime then -- 2659
			return nil -- 2660
		end -- 2660
		local objectCount = Dora.Object.count -- 2661
		local luaRefCount = Dora.Object.luaRefCount -- 2662
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 2663
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 2664
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 2665
		if not exceededTotal then -- 2665
			return nil -- 2668
		end -- 2668
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 2669
	end -- 2659
	local function normalizeEntryFile(value) -- 2673
		if not value or type(value) ~= "table" then -- 2673
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 2675
		end -- 2675
		local descriptor = value -- 2677
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 2678
		if relativeFile == "" then -- 2678
			relativeFile = "init" -- 2679
		end -- 2679
		if not isValidWorkspacePath(relativeFile) then -- 2679
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 2681
		end -- 2681
		local fileName = Path(req.workDir, relativeFile) -- 2683
		local ext = Path:getExt(fileName) -- 2684
		if ext ~= "" then -- 2684
			fileName = Path:replaceExt(fileName, "") -- 2685
		end -- 2685
		local luaFile = Path:replaceExt(fileName, "lua") -- 2686
		if not Content:exist(luaFile) then -- 2686
			error("Agent test entry was not built: " .. luaFile) -- 2688
		end -- 2688
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 2690
		return { -- 2691
			fileName = fileName, -- 2692
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 2693
		} -- 2693
	end -- 2673
	local function capturePrint(...) -- 2696
		local values = {...} -- 2696
		local parts = {} -- 2697
		do -- 2697
			local i = 0 -- 2698
			while i < #values do -- 2698
				parts[#parts + 1] = tostring(values[i + 1]) -- 2699
				i = i + 1 -- 2698
			end -- 2698
		end -- 2698
		output[#output + 1] = table.concat(parts, "\t") -- 2701
	end -- 2696
	local function refreshTree(path) -- 2703
		refreshTreeCalled = true -- 2704
		if path == nil then -- 2704
			return refreshProjectTree(req.workDir) -- 2706
		end -- 2706
		if type(path) ~= "string" then -- 2706
			error("refreshTree expects a project-relative file path string or no argument") -- 2709
		end -- 2709
		return refreshProjectTree(req.workDir, path) -- 2711
	end -- 2703
	local env = setmetatable( -- 2713
		{ -- 2713
			projectDir = req.workDir, -- 2714
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 2715
				if type(moduleNameValue) ~= "string" then -- 2715
					error("requireProjectModule expects a project module name string") -- 2717
				end -- 2717
				local moduleName = __TS__StringTrim(moduleNameValue) -- 2719
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 2719
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 2721
				end -- 2721
				local reloadModules = {moduleName} -- 2723
				if reloadModulesValue ~= nil then -- 2723
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 2723
						error("requireProjectModule reloadModules must be an array of module names") -- 2726
					end -- 2726
					local items = reloadModulesValue -- 2728
					do -- 2728
						local i = 0 -- 2729
						while i < #items do -- 2729
							local item = items[i + 1] -- 2730
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 2730
								error("requireProjectModule reloadModules contains an invalid module name") -- 2732
							end -- 2732
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 2732
								reloadModules[#reloadModules + 1] = item -- 2734
							end -- 2734
							i = i + 1 -- 2729
						end -- 2729
					end -- 2729
				end -- 2729
				local luaPackage = _G.package -- 2737
				local previousPath = luaPackage.path -- 2741
				local previousSearchPaths = Content.searchPaths -- 2742
				local scopedSearchPaths = {req.workDir} -- 2743
				do -- 2743
					local i = 0 -- 2744
					while i < #previousSearchPaths do -- 2744
						local searchPath = previousSearchPaths[i + 1] -- 2745
						if searchPath ~= req.workDir then -- 2745
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 2746
						end -- 2746
						i = i + 1 -- 2744
					end -- 2744
				end -- 2744
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 2748
				Content.searchPaths = scopedSearchPaths -- 2749
				do -- 2749
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2749
						do -- 2749
							local i = 0 -- 2751
							while i < #reloadModules do -- 2751
								local reloadName = reloadModules[i + 1] -- 2752
								luaPackage.loaded[reloadName] = nil -- 2753
								luaPackage.loaded[table.concat( -- 2754
									__TS__StringSplit(reloadName, "/"), -- 2754
									"." -- 2754
								)] = nil -- 2754
								luaPackage.loaded[table.concat( -- 2755
									__TS__StringSplit(reloadName, "."), -- 2755
									"/" -- 2755
								)] = nil -- 2755
								i = i + 1 -- 2751
							end -- 2751
						end -- 2751
						return true, require(table.concat( -- 2757
							__TS__StringSplit(moduleName, "/"), -- 2757
							"." -- 2757
						)) -- 2757
					end) -- 2757
					do -- 2757
						Content.searchPaths = previousSearchPaths -- 2759
						luaPackage.path = previousPath -- 2760
					end -- 2760
					if not ____try then -- 2760
						error(____hasReturned, 0) -- 2760
					end -- 2760
					if ____try and ____hasReturned then -- 2760
						return ____returnValue -- 2750
					end -- 2750
				end -- 2750
			end, -- 2715
			print = capturePrint, -- 2763
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 2764
			enterEntryAsync = function(value) -- 2765
				local normalized = normalizeEntryFile(value) -- 2766
				acquireEntryRuntime() -- 2767
				entry.allClear() -- 2768
				startEntryWatchdog() -- 2769
				local success, message = entry.enterEntryAsync({ -- 2770
					entryName = normalized.entryName, -- 2771
					fileName = normalized.fileName, -- 2772
					workDir = req.workDir, -- 2773
					projectRoot = req.workDir, -- 2774
					runKind = "agent_test" -- 2775
				}) -- 2775
				return success, message -- 2777
			end, -- 2765
			stopEntry = function() -- 2779
				if not ownsEntryRuntime then -- 2779
					return false -- 2780
				end -- 2780
				return entry.stop() -- 2781
			end, -- 2779
			reportProgress = function(value, callbackValue) -- 2783
				local ____callbackValue_41 = callbackValue -- 2784
				if ____callbackValue_41 == nil then -- 2784
					____callbackValue_41 = value -- 2784
				end -- 2784
				local actualValue = ____callbackValue_41 -- 2784
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 2784
					return -- 2785
				end -- 2785
				local progress = actualValue -- 2786
				local amount = type(progress.progress) == "number" and math.min( -- 2787
					1, -- 2788
					math.max(0, progress.progress) -- 2788
				) or nil -- 2788
				req:onProgress({ -- 2790
					state = "running", -- 2791
					mode = "lua", -- 2792
					operationId = req.operationId, -- 2793
					progress = amount, -- 2794
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 2795
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 2796
				}) -- 2796
			end -- 2783
		}, -- 2783
		{__index = function(_table, key) -- 2799
			if key == "Content" then -- 2799
				contentAccessed = true -- 2802
				return Content -- 2803
			end -- 2803
			if key == "refreshTree" then -- 2803
				return refreshTree -- 2806
			end -- 2806
			return Dora[tostring(key)] -- 2808
		end} -- 2800
	) -- 2800
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 2811
	if not fn then -- 2811
		return __TS__Promise.resolve({ -- 2813
			success = false, -- 2814
			mode = "lua", -- 2815
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2816
			message = truncateCommandError(toStr(compileErr)), -- 2817
			phase = "compile" -- 2818
		}) -- 2818
	end -- 2818
	return __TS__New( -- 2821
		__TS__Promise, -- 2821
		function(____, resolve) -- 2821
			local settled = false -- 2822
			local commandRoutine -- 2823
			local startedAt = App.runningTime -- 2824
			local onProgress = req.onProgress -- 2825
			local isCancelled = req.isCancelled -- 2826
			local function finish(result) -- 2827
				if settled then -- 2827
					return -- 2828
				end -- 2828
				settled = true -- 2829
				local cleanupError -- 2830
				if not result.success and (result.interrupted == true or result.phase == "timeout") then -- 2830
					do -- 2830
						local function ____catch(e) -- 2830
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 2835
						end -- 2835
						local ____try, ____hasReturned = pcall(function() -- 2835
							entry.allClear() -- 2833
						end) -- 2833
						if not ____try then -- 2833
							____catch(____hasReturned) -- 2833
						end -- 2833
					end -- 2833
				end -- 2833
				local entryCleanupError = stopOwnedEntry() -- 2838
				if cleanupError == nil then -- 2838
					cleanupError = entryCleanupError -- 2839
				end -- 2839
				if contentAccessed and not refreshTreeCalled and not refreshProjectTree(req.workDir) then -- 2839
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 2841
				end -- 2841
				if not result.success and cleanupError ~= nil then -- 2841
					result.cleanupError = cleanupError -- 2844
				elseif result.success and cleanupError ~= nil then -- 2844
					resolve(nil, { -- 2846
						success = false, -- 2847
						mode = "lua", -- 2848
						output = result.output, -- 2849
						message = cleanupError, -- 2850
						phase = "execute", -- 2851
						cleanupError = cleanupError -- 2852
					}) -- 2852
					return -- 2854
				end -- 2854
				resolve(nil, result) -- 2856
			end -- 2827
			if onProgress then -- 2827
				onProgress(nil, { -- 2859
					state = "pending", -- 2860
					mode = "lua", -- 2861
					operationId = req.operationId, -- 2862
					stage = "lua", -- 2863
					message = "Lua command pending" -- 2864
				}) -- 2864
			end -- 2864
			commandRoutine = once(function() -- 2867
				if settled then -- 2867
					return -- 2868
				end -- 2868
				if onProgress then -- 2868
					onProgress(nil, { -- 2870
						state = "running", -- 2871
						mode = "lua", -- 2872
						operationId = req.operationId, -- 2873
						stage = "lua", -- 2874
						message = "Lua command running" -- 2875
					}) -- 2875
				end -- 2875
				local previousGlobalPrint = _G.print -- 2878
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 2879
				local frameTimedOut = false -- 2880
				local watchdogMessage -- 2880
				_G.print = capturePrint -- 2881
				debug.sethook( -- 2882
					function() -- 2882
						if watchdogMessage == nil then -- 2882
							watchdogMessage = checkEntryWatchdog() -- 2883
						end -- 2883
						if watchdogMessage ~= nil then -- 2883
							error(watchdogMessage) -- 2884
						end -- 2884
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 2884
							frameTimedOut = true -- 2886
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 2887
						end -- 2887
					end, -- 2882
					"", -- 2889
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 2889
				) -- 2889
				local ok, runtimeErr = pcall(fn) -- 2890
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 2890
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 2892
				else -- 2892
					debug.sethook() -- 2898
				end -- 2898
				_G.print = previousGlobalPrint -- 2900
				if not ok then -- 2900
					local ____truncateCommandOutput_result_43 = truncateCommandOutput(table.concat(output, "\n")) -- 2905
					local ____temp_44 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 2906
					local ____temp_45 = frameTimedOut and "timeout" or "execute" -- 2907
					local ____temp_42 -- 2908
					if watchdogMessage ~= nil or frameTimedOut then -- 2908
						____temp_42 = true -- 2908
					else -- 2908
						____temp_42 = nil -- 2908
					end -- 2908
					finish({ -- 2902
						success = false, -- 2903
						mode = "lua", -- 2904
						output = ____truncateCommandOutput_result_43, -- 2905
						message = ____temp_44, -- 2906
						phase = ____temp_45, -- 2907
						interrupted = ____temp_42 -- 2908
					}) -- 2908
					return -- 2910
				end -- 2910
				finish({ -- 2912
					success = true, -- 2912
					mode = "lua", -- 2912
					output = truncateCommandOutput(table.concat(output, "\n")) -- 2912
				}) -- 2912
			end) -- 2867
			Director.systemScheduler:schedule(function() -- 2914
				if settled then -- 2914
					return true -- 2915
				end -- 2915
				local watchdogMessage = checkEntryWatchdog() -- 2916
				if watchdogMessage ~= nil then -- 2916
					finish({ -- 2918
						success = false, -- 2919
						mode = "lua", -- 2920
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2921
						message = watchdogMessage, -- 2922
						phase = "execute", -- 2923
						interrupted = true -- 2924
					}) -- 2924
					return true -- 2926
				end -- 2926
				if isCancelled and isCancelled(nil) then -- 2926
					finish({ -- 2929
						success = false, -- 2930
						mode = "lua", -- 2931
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2932
						message = "Lua command canceled", -- 2933
						phase = "execute", -- 2934
						interrupted = true -- 2935
					}) -- 2935
					return true -- 2937
				end -- 2937
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 2937
					finish({ -- 2940
						success = false, -- 2941
						mode = "lua", -- 2942
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2943
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 2944
						phase = "timeout" -- 2945
					}) -- 2945
					return true -- 2947
				end -- 2947
				if commandRoutine == nil then -- 2947
					finish({ -- 2950
						success = false, -- 2951
						mode = "lua", -- 2952
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2953
						message = "Lua command coroutine is unavailable", -- 2954
						phase = "execute" -- 2955
					}) -- 2955
					return true -- 2957
				end -- 2957
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 2959
				if not resumeSuccess then -- 2959
					finish({ -- 2961
						success = false, -- 2962
						mode = "lua", -- 2963
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2964
						message = truncateCommandError(toStr(resumeResult)), -- 2965
						phase = "execute" -- 2966
					}) -- 2966
					return true -- 2968
				end -- 2968
				return settled or resumeResult == true -- 2970
			end) -- 2914
		end -- 2821
	) -- 2821
end -- 2615
local function formatGitStatusOutput(status) -- 2975
	if not status then -- 2975
		return "" -- 2976
	end -- 2976
	local lines = {} -- 2977
	local state = toStr(status.state) -- 2978
	local kind = toStr(status.kind) -- 2979
	local message = toStr(status.message) -- 2980
	local errorMessage = toStr(status.error) -- 2981
	if kind ~= "" or state ~= "" then -- 2981
		lines[#lines + 1] = table.concat( -- 2983
			__TS__ArrayFilter( -- 2983
				{kind, state}, -- 2983
				function(____, item) return item ~= "" end -- 2983
			), -- 2983
			": " -- 2983
		) -- 2983
	end -- 2983
	if message ~= "" then -- 2983
		lines[#lines + 1] = message -- 2985
	end -- 2985
	if errorMessage ~= "" then -- 2985
		lines[#lines + 1] = errorMessage -- 2986
	end -- 2986
	local data = status.data -- 2987
	if data ~= nil then -- 2987
		local dataText = encodeJSON(data) -- 2989
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 2990
	end -- 2990
	return truncateCommandOutput(table.concat(lines, "\n")) -- 2992
end -- 2975
local function emitGitProgress(mode, operationId, onProgress, status) -- 2995
	if not onProgress then -- 2995
		return -- 3001
	end -- 3001
	local progress = type(status.progress) == "number" and status.progress or nil -- 3002
	local kind = toStr(status.kind) -- 3003
	local message = toStr(status.message) -- 3004
	local state = toStr(status.state) -- 3005
	local jobId = type(status.id) == "number" and status.id or nil -- 3006
	onProgress({ -- 3007
		state = "running", -- 3008
		mode = mode, -- 3009
		operationId = operationId, -- 3010
		stage = kind ~= "" and kind or "git", -- 3011
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 3012
		progress = progress, -- 3013
		jobId = jobId, -- 3014
		gitState = state ~= "" and state or nil, -- 3015
		gitKind = kind ~= "" and kind or nil -- 3016
	}) -- 3016
end -- 2995
local function cloneGitToTarget(req) -- 3020
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3020
		local parsed = parseGitCloneCommand(req.command) -- 3028
		if parsed == nil then -- 3028
			return ____awaiter_resolve(nil, nil) -- 3028
		end -- 3028
		if not parsed.success then -- 3028
			return ____awaiter_resolve(nil, { -- 3028
				success = false, -- 3031
				mode = "git", -- 3031
				output = "", -- 3031
				message = parsed.message, -- 3031
				phase = "validate" -- 3031
			}) -- 3031
		end -- 3031
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 3033
		if not target then -- 3033
			return ____awaiter_resolve(nil, { -- 3033
				success = false, -- 3035
				mode = "git", -- 3035
				output = "", -- 3035
				message = "invalid clone target path", -- 3035
				phase = "validate" -- 3035
			}) -- 3035
		end -- 3035
		if Content:exist(target) then -- 3035
			return ____awaiter_resolve(nil, { -- 3035
				success = false, -- 3038
				mode = "git", -- 3038
				output = "", -- 3038
				message = "target already exists", -- 3038
				phase = "validate" -- 3038
			}) -- 3038
		end -- 3038
		local targetParent = Path:getPath(target) -- 3040
		if not ensureDirPath(targetParent) then -- 3040
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 3040
		end -- 3040
		local tempRoot = getAgentDownloadTempRoot() -- 3044
		if not ensureDirPath(tempRoot) then -- 3044
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 3044
		end -- 3044
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 3048
		Content:remove(tempPath) -- 3049
		local depth = parsed.depth or "1" -- 3050
		local ____array_46 = __TS__SparseArrayNew( -- 3050
			"clone", -- 3052
			quoteGitArg(parsed.url), -- 3053
			quoteGitArg(Path:getFilename(tempPath)), -- 3054
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 3055
				"-b", -- 3055
				quoteGitArg(parsed.ref) -- 3055
			}) or ({})) -- 3055
		) -- 3055
		__TS__SparseArrayPush( -- 3055
			____array_46, -- 3055
			table.unpack(depth ~= "" and ({ -- 3056
				"--depth",
				quoteGitArg(depth) -- 3056
			}) or ({})) -- 3056
		) -- 3056
		local command = table.concat( -- 3051
			{__TS__SparseArraySpread(____array_46)}, -- 3051
			" " -- 3057
		) -- 3057
		local ____this_48 -- 3057
		____this_48 = req -- 3058
		local ____opt_47 = ____this_48.onProgress -- 3058
		if ____opt_47 ~= nil then -- 3058
			____opt_47(____this_48, { -- 3058
				state = "pending", -- 3059
				mode = "git", -- 3060
				operationId = req.operationId, -- 3061
				stage = "clone", -- 3062
				message = "clone pending", -- 3063
				progress = 0 -- 3064
			}) -- 3064
		end -- 3064
		local gitRes = __TS__Await(runGitAndWait( -- 3066
			tempRoot, -- 3067
			command, -- 3068
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 3069
			function() -- 3070
				local ____this_50 -- 3070
				____this_50 = req -- 3070
				local ____opt_49 = ____this_50.isCancelled -- 3070
				return (____opt_49 and ____opt_49(____this_50)) == true -- 3070
			end, -- 3070
			req.timeoutSeconds -- 3071
		)) -- 3071
		if not gitRes.success then -- 3071
			local cleanupError = cleanupPath(tempPath) -- 3074
			local ____formatGitStatusOutput_result_54 = formatGitStatusOutput(gitRes.status) -- 3078
			local ____temp_55 = gitRes.message or "git clone failed" -- 3079
			local ____gitRes_interrupted_53 = gitRes.interrupted -- 3080
			if not ____gitRes_interrupted_53 then -- 3080
				local ____this_52 -- 3080
				____this_52 = req -- 3080
				local ____opt_51 = ____this_52.isCancelled -- 3080
				____gitRes_interrupted_53 = (____opt_51 and ____opt_51(____this_52)) == true -- 3080
			end -- 3080
			return ____awaiter_resolve(nil, { -- 3080
				success = false, -- 3076
				mode = "git", -- 3077
				output = ____formatGitStatusOutput_result_54, -- 3078
				message = ____temp_55, -- 3079
				interrupted = ____gitRes_interrupted_53, -- 3080
				cleanupError = cleanupError -- 3081
			}) -- 3081
		end -- 3081
		if not Content:move(tempPath, target) then -- 3081
			local cleanupError = cleanupPath(tempPath) -- 3085
			return ____awaiter_resolve( -- 3085
				nil, -- 3085
				{ -- 3086
					success = false, -- 3086
					mode = "git", -- 3086
					output = formatGitStatusOutput(gitRes.status), -- 3086
					message = "failed to move cloned repository into target path", -- 3086
					cleanupError = cleanupError -- 3086
				} -- 3086
			) -- 3086
		end -- 3086
		if not refreshProjectTree(req.workDir) then -- 3086
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 3089
		end -- 3089
		local commit = getGitHeadCommit(target) -- 3091
		local output = table.concat( -- 3092
			__TS__ArrayFilter( -- 3092
				{ -- 3092
					formatGitStatusOutput(gitRes.status), -- 3093
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 3093
					commit ~= nil and "commit " .. commit or "" -- 3095
				}, -- 3095
				function(____, item) return item ~= "" end -- 3096
			), -- 3096
			"\n" -- 3096
		) -- 3096
		return ____awaiter_resolve( -- 3096
			nil, -- 3096
			{ -- 3097
				success = true, -- 3097
				mode = "git", -- 3097
				output = truncateCommandOutput(output) -- 3097
			} -- 3097
		) -- 3097
	end) -- 3097
end -- 3020
local function loadGitProfile() -- 3100
	local rows -- 3101
	do -- 3101
		local function ____catch() -- 3101
			return true, nil -- 3105
		end -- 3105
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 3105
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 3103
		end) -- 3103
		if not ____try then -- 3103
			____hasReturned, ____returnValue = ____catch() -- 3103
		end -- 3103
		if ____hasReturned then -- 3103
			return ____returnValue -- 3102
		end -- 3102
	end -- 3102
	if not rows or not rows[1] then -- 3102
		return nil -- 3107
	end -- 3107
	local name = toStr(rows[1][1]) -- 3108
	local email = toStr(rows[1][2]) -- 3109
	if name == "" and email == "" then -- 3109
		return nil -- 3110
	end -- 3110
	return {name = name, email = email} -- 3111
end -- 3100
local function applyGitProfileToCommit(command) -- 3114
	local args = shellSplit(command) -- 3115
	if args[1] ~= "commit" then -- 3115
		return command -- 3116
	end -- 3116
	local hasName = false -- 3117
	local hasEmail = false -- 3118
	for ____, arg in ipairs(args) do -- 3119
		if arg == "--author-name" then
			hasName = true -- 3120
		end -- 3120
		if arg == "--author-email" then
			hasEmail = true -- 3121
		end -- 3121
	end -- 3121
	if hasName and hasEmail then -- 3121
		return command -- 3123
	end -- 3123
	local profile = loadGitProfile() -- 3124
	if not profile then -- 3124
		return command -- 3125
	end -- 3125
	local additions = {} -- 3126
	if not hasName and profile.name ~= "" then -- 3126
		__TS__ArrayPush( -- 3128
			additions, -- 3128
			"--author-name",
			quoteGitArg(profile.name) -- 3128
		) -- 3128
	end -- 3128
	if not hasEmail and profile.email ~= "" then -- 3128
		__TS__ArrayPush( -- 3131
			additions, -- 3131
			"--author-email",
			quoteGitArg(profile.email) -- 3131
		) -- 3131
	end -- 3131
	if #additions == 0 then -- 3131
		return command -- 3133
	end -- 3133
	return (command .. " ") .. table.concat(additions, " ") -- 3134
end -- 3114
local function executeGitCommand(req) -- 3137
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3137
		local command = normalizeGitCommand(req.command or "") -- 3146
		if command == "" then -- 3146
			return ____awaiter_resolve(nil, { -- 3146
				success = false, -- 3148
				mode = "git", -- 3148
				output = "", -- 3148
				message = "missing command", -- 3148
				phase = "validate" -- 3148
			}) -- 3148
		end -- 3148
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 3150
			workDir = req.workDir, -- 3151
			command = command, -- 3152
			operationId = req.operationId, -- 3153
			timeoutSeconds = req.timeoutSeconds, -- 3154
			onProgress = req.onProgress, -- 3155
			isCancelled = req.isCancelled -- 3156
		})) -- 3156
		if cloneResult ~= nil then -- 3156
			return ____awaiter_resolve(nil, cloneResult) -- 3156
		end -- 3156
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 3159
		if not cwd.success then -- 3159
			return ____awaiter_resolve(nil, { -- 3159
				success = false, -- 3161
				mode = "git", -- 3161
				output = "", -- 3161
				cwd = req.cwd, -- 3161
				message = cwd.message, -- 3161
				phase = "validate" -- 3161
			}) -- 3161
		end -- 3161
		command = applyGitProfileToCommit(command) -- 3163
		local ____this_57 -- 3163
		____this_57 = req -- 3164
		local ____opt_56 = ____this_57.onProgress -- 3164
		if ____opt_56 ~= nil then -- 3164
			____opt_56(____this_57, { -- 3164
				state = "pending", -- 3165
				mode = "git", -- 3166
				operationId = req.operationId, -- 3167
				stage = "git", -- 3168
				message = "git command pending", -- 3169
				progress = 0 -- 3170
			}) -- 3170
		end -- 3170
		local gitRes = __TS__Await(runGitAndWait( -- 3172
			cwd.path, -- 3173
			command, -- 3174
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 3175
			function() -- 3176
				local ____this_59 -- 3176
				____this_59 = req -- 3176
				local ____opt_58 = ____this_59.isCancelled -- 3176
				return (____opt_58 and ____opt_58(____this_59)) == true -- 3176
			end, -- 3176
			req.timeoutSeconds -- 3177
		)) -- 3177
		local output = formatGitStatusOutput(gitRes.status) -- 3179
		if not gitRes.success then -- 3179
			local ____output_63 = output -- 3184
			local ____cwd_relative_64 = cwd.relative -- 3185
			local ____temp_65 = gitRes.message or "git command failed" -- 3186
			local ____gitRes_interrupted_62 = gitRes.interrupted -- 3187
			if not ____gitRes_interrupted_62 then -- 3187
				local ____this_61 -- 3187
				____this_61 = req -- 3187
				local ____opt_60 = ____this_61.isCancelled -- 3187
				____gitRes_interrupted_62 = (____opt_60 and ____opt_60(____this_61)) == true -- 3187
			end -- 3187
			return ____awaiter_resolve(nil, { -- 3187
				success = false, -- 3182
				mode = "git", -- 3183
				output = ____output_63, -- 3184
				cwd = ____cwd_relative_64, -- 3185
				message = ____temp_65, -- 3186
				interrupted = ____gitRes_interrupted_62 -- 3187
			}) -- 3187
		end -- 3187
		if not refreshProjectTree(req.workDir) then -- 3187
			Log("Warn", (("[execute_command] failed to refresh Web IDE tree after Git command workDir=" .. req.workDir) .. " cwd=") .. cwd.relative) -- 3191
		end -- 3191
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 3191
	end) -- 3191
end -- 3137
function ____exports.executeCommand(req) -- 3196
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3196
		local mode = req.mode -- 3206
		if mode ~= "lua" and mode ~= "git" then -- 3206
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 3206
		end -- 3206
		if mode == "lua" then -- 3206
			return ____awaiter_resolve( -- 3206
				nil, -- 3206
				executeLuaCommand({ -- 3211
					workDir = req.workDir, -- 3212
					code = req.code or "", -- 3213
					timeoutSeconds = math.max( -- 3214
						1, -- 3214
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 3214
					), -- 3214
					operationId = createOperationId(), -- 3215
					onProgress = req.onProgress, -- 3216
					isCancelled = req.isCancelled -- 3217
				}) -- 3217
			) -- 3217
		end -- 3217
		local operationId = createOperationId() -- 3220
		return ____awaiter_resolve( -- 3220
			nil, -- 3220
			executeGitCommand({ -- 3221
				workDir = req.workDir, -- 3222
				command = req.command or "", -- 3223
				cwd = req.cwd, -- 3224
				timeoutSeconds = math.max( -- 3225
					1, -- 3225
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 3225
				), -- 3225
				operationId = operationId, -- 3226
				onProgress = req.onProgress, -- 3227
				isCancelled = req.isCancelled -- 3228
			}) -- 3228
		) -- 3228
	end) -- 3228
end -- 3196
function ____exports.fetchUrl(req) -- 3232
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3232
		local mode = "download" -- 3239
		local url = __TS__StringTrim(req.url or "") -- 3240
		local targetRel = __TS__StringTrim(req.target or "") -- 3241
		if not isHttpUrl(url) then -- 3241
			return ____awaiter_resolve(nil, { -- 3241
				success = false, -- 3243
				state = "failed", -- 3243
				mode = mode, -- 3243
				target = targetRel, -- 3243
				message = "fetch_url only supports http:// and https:// URLs" -- 3243
			}) -- 3243
		end -- 3243
		if targetRel == "" then -- 3243
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 3243
		end -- 3243
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 3248
		if not target then -- 3248
			return ____awaiter_resolve(nil, { -- 3248
				success = false, -- 3250
				state = "failed", -- 3250
				mode = mode, -- 3250
				target = targetRel, -- 3250
				message = "invalid target path" -- 3250
			}) -- 3250
		end -- 3250
		if Content:exist(target) then -- 3250
			return ____awaiter_resolve(nil, { -- 3250
				success = false, -- 3253
				state = "failed", -- 3253
				mode = mode, -- 3253
				target = targetRel, -- 3253
				message = "target already exists" -- 3253
			}) -- 3253
		end -- 3253
		local operationId = createOperationId() -- 3255
		local tempRoot = getAgentDownloadTempRoot() -- 3256
		if not ensureDirPath(tempRoot) then -- 3256
			return ____awaiter_resolve(nil, { -- 3256
				success = false, -- 3258
				state = "failed", -- 3258
				mode = mode, -- 3258
				target = targetRel, -- 3258
				message = "failed to create agent download temp directory" -- 3258
			}) -- 3258
		end -- 3258
		local tempPath = Path(tempRoot, operationId .. ".download") -- 3260
		Content:remove(tempPath) -- 3261
		local function emitProgress(progress) -- 3262
			if not req.onProgress then -- 3262
				return -- 3263
			end -- 3263
			req:onProgress(__TS__ObjectAssign({ -- 3264
				state = "running", -- 3265
				mode = mode, -- 3266
				operationId = operationId, -- 3267
				target = targetRel, -- 3268
				tempPath = tempPath -- 3269
			}, progress)) -- 3269
		end -- 3262
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 3273
		local function interrupted() -- 3278
			local ____this_67 -- 3278
			____this_67 = req -- 3278
			local ____opt_66 = ____this_67.isCancelled -- 3278
			return (____opt_66 and ____opt_66(____this_67)) == true -- 3278
		end -- 3278
		if not ensureDirForFile(tempPath) then -- 3278
			return ____awaiter_resolve(nil, { -- 3278
				success = false, -- 3280
				state = "failed", -- 3280
				mode = mode, -- 3280
				target = targetRel, -- 3280
				message = "failed to create temporary file directory" -- 3280
			}) -- 3280
		end -- 3280
		local downloadRes = __TS__Await(downloadFile({ -- 3282
			url = url, -- 3283
			tempPath = tempPath, -- 3284
			timeout = 600, -- 3285
			isCancelled = interrupted, -- 3286
			onProgress = function(____, current, total) -- 3287
				local totalNumber = type(total) == "number" and total or 0 -- 3288
				emitProgress({ -- 3289
					stage = "download", -- 3290
					message = "downloading", -- 3291
					current = current, -- 3292
					total = total, -- 3293
					progress = totalNumber > 0 and current / totalNumber or nil -- 3294
				}) -- 3294
			end -- 3287
		})) -- 3287
		if not downloadRes.success then -- 3287
			local cleanupError = cleanupPath(tempPath) -- 3299
			return ____awaiter_resolve( -- 3299
				nil, -- 3299
				{ -- 3300
					success = false, -- 3301
					state = "failed", -- 3302
					mode = mode, -- 3303
					target = targetRel, -- 3304
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 3305
					interrupted = downloadRes.interrupted or interrupted(), -- 3306
					cleanupError = cleanupError -- 3307
				} -- 3307
			) -- 3307
		end -- 3307
		if not ensureDirForFile(target) then -- 3307
			local cleanupError = cleanupPath(tempPath) -- 3311
			return ____awaiter_resolve(nil, { -- 3311
				success = false, -- 3312
				state = "failed", -- 3312
				mode = mode, -- 3312
				target = targetRel, -- 3312
				message = "failed to create target directory", -- 3312
				cleanupError = cleanupError -- 3312
			}) -- 3312
		end -- 3312
		if not Content:move(tempPath, target) then -- 3312
			local cleanupError = cleanupPath(tempPath) -- 3315
			return ____awaiter_resolve(nil, { -- 3315
				success = false, -- 3316
				state = "failed", -- 3316
				mode = mode, -- 3316
				target = targetRel, -- 3316
				message = "failed to move downloaded file into target path", -- 3316
				cleanupError = cleanupError -- 3316
			}) -- 3316
		end -- 3316
		local bytesWritten = downloadRes.bytesWritten -- 3318
		local ____try = __TS__AsyncAwaiter(function() -- 3318
			local size = Content:getAttr(target) -- 3320
			if bytesWritten == nil or bytesWritten <= 0 then -- 3320
				bytesWritten = type(size) == "number" and size or nil -- 3322
			end -- 3322
		end) -- 3322
		____try = ____try.catch( -- 3322
			____try, -- 3322
			function(____, _) -- 3322
				return __TS__AsyncAwaiter(function() -- 3322
				end) -- 3322
			end -- 3322
		) -- 3322
		__TS__Await(____try) -- 3319
		if bytesWritten == nil or bytesWritten <= 0 then -- 3319
			local ____try = __TS__AsyncAwaiter(function() -- 3319
				local loaded = Content:load(target) -- 3329
				if type(loaded) == "string" then -- 3329
					bytesWritten = #loaded -- 3331
				end -- 3331
			end) -- 3331
			____try = ____try.catch( -- 3331
				____try, -- 3331
				function(____, _) -- 3331
					return __TS__AsyncAwaiter(function() -- 3331
					end) -- 3331
				end -- 3331
			) -- 3331
			__TS__Await(____try) -- 3328
		end -- 3328
		if not syncDownloadedFileToWebIDE(target) then -- 3328
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 3338
		end -- 3338
		return ____awaiter_resolve(nil, { -- 3338
			success = true, -- 3340
			state = "done", -- 3340
			mode = mode, -- 3340
			target = targetRel, -- 3340
			bytesWritten = bytesWritten -- 3340
		}) -- 3340
	end) -- 3340
end -- 3232
return ____exports -- 3232