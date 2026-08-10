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
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
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
function normalizeEscapedGitQuotes(command) -- 758
	local result = "" -- 759
	do -- 759
		local i = 0 -- 760
		while i < #command do -- 760
			do -- 760
				local ch = __TS__StringCharAt(command, i) -- 761
				local next = __TS__StringCharAt(command, i + 1) -- 762
				if ch == "\\" and (next == "\"" or next == "'") then -- 762
					result = result .. next -- 764
					i = i + 1 -- 765
					goto __continue123 -- 766
				end -- 766
				result = result .. ch -- 768
			end -- 768
			::__continue123:: -- 768
			i = i + 1 -- 760
		end -- 760
	end -- 760
	return result -- 770
end -- 770
function encodeJSON(obj) -- 1271
	local text = safeJsonEncode(obj) -- 1272
	return text -- 1273
end -- 1273
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 1276
	if HttpServer.wsConnectionCount == 0 then -- 1276
		return true -- 1278
	end -- 1278
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 1280
	if not payload then -- 1280
		return false -- 1282
	end -- 1282
	emit("AppWS", "Send", payload) -- 1284
	return true -- 1285
end -- 1276
function getEngineLogText() -- 1709
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 1710
	if not Content:exist(folder) then -- 1710
		Content:mkdir(folder) -- 1712
	end -- 1712
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 1714
	if not App:saveLog(logPath) then -- 1714
		return nil -- 1716
	end -- 1716
	return Content:load(logPath) -- 1718
end -- 1718
function ensureSafeSearchGlobs(globs) -- 1858
	local result = {} -- 1859
	do -- 1859
		local i = 0 -- 1860
		while i < #globs do -- 1860
			result[#result + 1] = globs[i + 1] -- 1861
			i = i + 1 -- 1860
		end -- 1860
	end -- 1860
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1863
	do -- 1863
		local i = 0 -- 1864
		while i < #requiredExcludes do -- 1864
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1864
				result[#result + 1] = requiredExcludes[i + 1] -- 1866
			end -- 1866
			i = i + 1 -- 1864
		end -- 1864
	end -- 1864
	return result -- 1869
end -- 1869
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
ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 440
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 441
local ENGINE_LOG_VIRTUAL_FILE = "@dora_full_logs.txt" -- 442
local AGENT_DOWNLOAD_TEMP_DIR = "agent" -- 443
local function now() -- 444
	return os.time() -- 444
end -- 444
local function toBool(v) -- 446
	return v ~= 0 and v ~= false and v ~= nil -- 447
end -- 446
local function toStr(v) -- 450
	if v == false or v == nil then -- 450
		return "" -- 451
	end -- 451
	return tostring(v) -- 452
end -- 450
local function isValidWorkspacePath(path) -- 455
	if not path or #path == 0 then -- 455
		return false -- 456
	end -- 456
	if Content:isAbsolutePath(path) then -- 456
		return false -- 457
	end -- 457
	if __TS__StringIncludes(path, "..") then -- 457
		return false -- 458
	end -- 458
	return true -- 459
end -- 455
local function isValidWorkDir(workDir) -- 462
	if not workDir or #workDir == 0 then -- 462
		return false -- 463
	end -- 463
	if not Content:isAbsolutePath(workDir) then -- 463
		return false -- 464
	end -- 464
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 464
		return false -- 465
	end -- 465
	return true -- 466
end -- 462
local function isValidSearchPath(path) -- 469
	if path == "" then -- 469
		return true -- 470
	end -- 470
	if Content:isAbsolutePath(path) then -- 470
		return false -- 471
	end -- 471
	if not path or #path == 0 then -- 471
		return false -- 472
	end -- 472
	if __TS__StringIncludes(path, "..") then -- 472
		return false -- 473
	end -- 473
	return true -- 474
end -- 469
local function resolveWorkspaceFilePath(workDir, path) -- 477
	if not isValidWorkDir(workDir) then -- 477
		return nil -- 478
	end -- 478
	if not isValidWorkspacePath(path) then -- 478
		return nil -- 479
	end -- 479
	return Path(workDir, path) -- 480
end -- 477
local function resolveWorkspaceSearchPath(workDir, path) -- 483
	if not isValidWorkDir(workDir) then -- 483
		return nil -- 484
	end -- 484
	if not isValidSearchPath(path) then -- 484
		return nil -- 485
	end -- 485
	return path == "" and workDir or Path(workDir, path) -- 486
end -- 483
local function toWorkspaceRelativePath(workDir, path) -- 489
	if not path or #path == 0 then -- 489
		return path -- 490
	end -- 490
	if not Content:isAbsolutePath(path) then -- 490
		return path -- 491
	end -- 491
	return Path:getRelative(path, workDir) -- 492
end -- 489
local function toWorkspaceRelativeFileList(workDir, files) -- 495
	return __TS__ArrayMap( -- 496
		files, -- 496
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 496
	) -- 496
end -- 495
local function toWorkspaceRelativeSearchResults(workDir, results) -- 499
	local mapped = {} -- 500
	do -- 500
		local i = 0 -- 501
		while i < #results do -- 501
			local row = results[i + 1] -- 502
			local clone = __TS__ObjectAssign({}, row) -- 503
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 504
			mapped[#mapped + 1] = clone -- 505
			i = i + 1 -- 501
		end -- 501
	end -- 501
	return mapped -- 507
end -- 499
local function resolveWorkspaceDirectoryPath(workDir, path) -- 510
	local relative = __TS__StringTrim(path or "") -- 511
	if relative == "" then -- 511
		return {success = true, path = workDir, relative = "."} -- 513
	end -- 513
	if not isValidWorkDir(workDir) or not isValidWorkspacePath(relative) then -- 513
		return {success = false, message = "invalid cwd path"} -- 516
	end -- 516
	local resolved = Path(workDir, relative) -- 518
	if not Content:exist(resolved) then -- 518
		return {success = false, message = "cwd does not exist"} -- 520
	end -- 520
	if not Content:isdir(resolved) then -- 520
		return {success = false, message = "cwd is not a directory"} -- 523
	end -- 523
	return {success = true, path = resolved, relative = relative} -- 525
end -- 510
local function getDoraDocDefinitionRoot(docLanguage) -- 528
	local zhDir = Path( -- 529
		Content.assetPath, -- 529
		"Script", -- 529
		"Lib", -- 529
		"Dora", -- 529
		"zh-Hans" -- 529
	) -- 529
	local enDir = Path( -- 530
		Content.assetPath, -- 530
		"Script", -- 530
		"Lib", -- 530
		"Dora", -- 530
		"en" -- 530
	) -- 530
	return docLanguage == "zh" and zhDir or enDir -- 531
end -- 528
local function getDoraTutorialDocRoot(docLanguage) -- 534
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 535
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 536
	return docLanguage == "zh" and zhDir or enDir -- 537
end -- 534
local function getDoraDocDefinitionExtsByCodeLanguage(programmingLanguage) -- 540
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 540
		return {"ts"} -- 542
	end -- 542
	return {"tl"} -- 544
end -- 540
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 547
	repeat -- 547
		local ____switch65 = programmingLanguage -- 547
		local ____cond65 = ____switch65 == "teal" -- 547
		if ____cond65 then -- 547
			return "tl" -- 549
		end -- 549
		____cond65 = ____cond65 or ____switch65 == "tl" -- 549
		if ____cond65 then -- 549
			return "tl" -- 550
		end -- 550
		do -- 550
			return programmingLanguage -- 551
		end -- 551
	until true -- 551
end -- 547
local function getDoraDocSearchTarget(docType, docLanguage, programmingLanguage) -- 555
	if docType == "dora-tutorial" then -- 555
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 561
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 562
		return { -- 563
			root = Path(tutorialRoot, langDir), -- 564
			exts = {"md"}, -- 565
			globs = {"**/*.md"} -- 566
		} -- 566
	end -- 566
	local exts = getDoraDocDefinitionExtsByCodeLanguage(programmingLanguage) -- 569
	if docType == "love-api" or docType == "tic80-api" then -- 569
		local name = docType == "love-api" and "love" or "tic80" -- 571
		return { -- 572
			root = getDoraDocDefinitionRoot(docLanguage), -- 573
			exts = exts, -- 574
			globs = __TS__ArrayMap( -- 575
				exts, -- 575
				function(____, ext) return (name .. ".d.") .. ext end -- 575
			) -- 575
		} -- 575
	end -- 575
	return { -- 578
		root = getDoraDocDefinitionRoot(docLanguage), -- 579
		exts = exts, -- 580
		globs = __TS__ArrayFlatMap( -- 581
			exts, -- 581
			function(____, ext) return {"**/*." .. ext, "!**/love.d." .. ext, "!**/tic80.d." .. ext} end -- 581
		) -- 581
	} -- 581
end -- 555
local function getDoraDocResultBaseRoot(docType, docLanguage) -- 589
	if docType == "dora-tutorial" then -- 589
		return getDoraTutorialDocRoot(docLanguage) -- 591
	end -- 591
	return getDoraDocDefinitionRoot(docLanguage) -- 593
end -- 589
local function isDoraDocFileInScope(docType, file) -- 596
	local normalized = string.lower(table.concat( -- 597
		__TS__StringSplit(file, "\\"), -- 597
		"/" -- 597
	)) -- 597
	local segments = __TS__StringSplit(normalized, "/") -- 598
	local baseName = segments[#segments] or normalized -- 599
	if docType == "dora-tutorial" then -- 599
		return __TS__StringEndsWith(normalized, ".md") -- 600
	end -- 600
	if docType == "love-api" then -- 600
		return normalized == "love.d.ts" or normalized == "love.d.tl" -- 601
	end -- 601
	if docType == "tic80-api" then -- 601
		return normalized == "tic80.d.ts" or normalized == "tic80.d.tl" -- 602
	end -- 602
	return (__TS__StringEndsWith(normalized, ".ts") or __TS__StringEndsWith(normalized, ".tl")) and baseName ~= "love.d.ts" and baseName ~= "love.d.tl" and baseName ~= "tic80.d.ts" and baseName ~= "tic80.d.tl" -- 603
end -- 596
local AGENT_DORA_DOC_PREFIX = "@dora-doc/" -- 610
local function toDocRelativePath(baseRoot, path, docType) -- 612
	if not path or #path == 0 then -- 612
		return path -- 613
	end -- 613
	local relative = Content:isAbsolutePath(path) and Path:getRelative(path, baseRoot) or path -- 614
	return ((AGENT_DORA_DOC_PREFIX .. docType) .. "/") .. relative -- 615
end -- 612
local function resolveAgentDoraDocFilePath(path, docLanguage) -- 618
	if not docLanguage then -- 618
		return nil -- 619
	end -- 619
	local relative = path -- 620
	local docType = "dora-tutorial" -- 621
	if __TS__StringStartsWith(path, AGENT_DORA_DOC_PREFIX) then -- 621
		local namespaced = __TS__StringSlice(path, #AGENT_DORA_DOC_PREFIX) -- 623
		if __TS__StringStartsWith(namespaced, "dora-api/") then -- 623
			docType = "dora-api" -- 625
			relative = string.sub(namespaced, 10) -- 626
		elseif __TS__StringStartsWith(namespaced, "love-api/") then -- 626
			docType = "love-api" -- 628
			relative = string.sub(namespaced, 10) -- 629
		elseif __TS__StringStartsWith(namespaced, "tic80-api/") then -- 629
			docType = "tic80-api" -- 631
			relative = string.sub(namespaced, 11) -- 632
		elseif __TS__StringStartsWith(namespaced, "dora-tutorial/") then -- 632
			docType = "dora-tutorial" -- 634
			relative = string.sub(namespaced, 15) -- 635
		elseif __TS__StringStartsWith(namespaced, "api/") then -- 635
			docType = "dora-api" -- 637
			relative = string.sub(namespaced, 5) -- 638
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 638
			docType = "dora-tutorial" -- 640
			relative = string.sub(namespaced, 10) -- 641
		else -- 641
			return nil -- 643
		end -- 643
	end -- 643
	if not isValidWorkspacePath(relative) then -- 643
		return nil -- 646
	end -- 646
	if not isDoraDocFileInScope(docType, relative) then -- 646
		return nil -- 647
	end -- 647
	local root = getDoraDocResultBaseRoot(docType, docLanguage) -- 648
	local candidate = Path(root, relative) -- 649
	local checked = Path:getRelative(candidate, root) -- 650
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 650
		return nil -- 651
	end -- 651
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 651
		return candidate -- 653
	end -- 653
	return nil -- 655
end -- 618
local function ensureDirPath(dir) -- 658
	if not dir or dir == "." or dir == "" then -- 658
		return true -- 659
	end -- 659
	if Content:exist(dir) then -- 659
		return Content:isdir(dir) -- 660
	end -- 660
	local parent = Path:getPath(dir) -- 661
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 661
		if not ensureDirPath(parent) then -- 661
			return false -- 663
		end -- 663
	end -- 663
	return Content:mkdir(dir) -- 665
end -- 658
local function ensureDirForFile(path) -- 668
	local dir = Path:getPath(path) -- 669
	return ensureDirPath(dir) -- 670
end -- 668
local function isHttpUrl(url) -- 673
	local normalized = string.lower(__TS__StringTrim(url)) -- 674
	return __TS__StringStartsWith(normalized, "http://") or __TS__StringStartsWith(normalized, "https://") -- 675
end -- 673
local function createOperationId() -- 678
	local raw = (tostring(os.time()) .. "-") .. tostring(math.floor(math.random() * 1000000000)) -- 679
	local safe = string.gsub(raw, "[^%w%-_]", "-") -- 680
	return safe -- 681
end -- 678
local function getAgentDownloadTempRoot() -- 684
	return Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR, AGENT_DOWNLOAD_TEMP_DIR) -- 685
end -- 684
local function cleanupPath(path) -- 688
	if not path or path == "" or not Content:exist(path) then -- 688
		return nil -- 689
	end -- 689
	if Content:remove(path) then -- 689
		return nil -- 690
	end -- 690
	return "failed to remove temporary path: " .. path -- 691
end -- 688
local function quoteGitArg(value) -- 694
	local plain = string.match(value, "^[%w%._%-%/]+$") -- 695
	if plain ~= nil then -- 695
		return value -- 697
	end -- 697
	local escaped = string.gsub(value, "\\", "\\\\") -- 699
	escaped = string.gsub(escaped, "\"", "\\\"") -- 700
	return ("\"" .. escaped) .. "\"" -- 701
end -- 694
local function shellSplit(command) -- 704
	local args = {} -- 705
	local current = "" -- 706
	local quote = "" -- 707
	local escaped = false -- 708
	do -- 708
		local i = 0 -- 709
		while i < #command do -- 709
			do -- 709
				local ch = __TS__StringCharAt(command, i) -- 710
				if escaped then -- 710
					current = current .. ch -- 712
					escaped = false -- 713
					goto __continue109 -- 714
				end -- 714
				if ch == "\\" then -- 714
					escaped = true -- 717
					goto __continue109 -- 718
				end -- 718
				if quote ~= "" then -- 718
					if ch == quote then -- 718
						quote = "" -- 722
					else -- 722
						current = current .. ch -- 724
					end -- 724
					goto __continue109 -- 726
				end -- 726
				if ch == "'" or ch == "\"" then -- 726
					quote = ch -- 729
					goto __continue109 -- 730
				end -- 730
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 730
					if current ~= "" then -- 730
						args[#args + 1] = current -- 734
						current = "" -- 735
					end -- 735
					goto __continue109 -- 737
				end -- 737
				current = current .. ch -- 739
			end -- 739
			::__continue109:: -- 739
			i = i + 1 -- 709
		end -- 709
	end -- 709
	if escaped then -- 709
		current = current .. "\\" -- 742
	end -- 742
	if current ~= "" then -- 742
		args[#args + 1] = current -- 745
	end -- 745
	return args -- 747
end -- 704
local function normalizeGitCommand(command) -- 750
	local trimmed = __TS__StringTrim(command) -- 751
	local normalized = string.lower(string.sub(trimmed, 1, 4)) == "git " and __TS__StringTrim(string.sub(trimmed, 5)) or trimmed -- 752
	return normalizeEscapedGitQuotes(normalized) -- 755
end -- 750
local function gitDefaultTargetFromUrl(url) -- 773
	local target = url -- 774
	local hashIndex = (string.find(target, "#", nil, true) or 0) - 1 -- 775
	if hashIndex >= 0 then -- 775
		target = __TS__StringSlice(target, 0, hashIndex) -- 776
	end -- 776
	local queryIndex = (string.find(target, "?", nil, true) or 0) - 1 -- 777
	if queryIndex >= 0 then -- 777
		target = __TS__StringSlice(target, 0, queryIndex) -- 778
	end -- 778
	target = string.gsub(target, "/+$", "") -- 779
	local name = string.match(target, "([^/]+)$") -- 780
	if name ~= nil and name ~= "" then -- 780
		target = name -- 781
	end -- 781
	if __TS__StringEndsWith( -- 781
		string.lower(target), -- 782
		".git" -- 782
	) then -- 782
		target = __TS__StringSlice(target, 0, #target - 4) -- 783
	end -- 783
	return target ~= "" and target or "repo" -- 785
end -- 773
local function parseGitCloneCommand(command) -- 788
	local args = shellSplit(normalizeGitCommand(command)) -- 798
	if #args == 0 or args[1] ~= "clone" then -- 798
		return nil -- 799
	end -- 799
	local url = "" -- 800
	local target = "" -- 801
	local ref -- 802
	local depth -- 803
	do -- 803
		local i = 1 -- 804
		while i < #args do -- 804
			do -- 804
				local arg = args[i + 1] -- 805
				if arg == "-b" or arg == "--branch" then
					i = i + 1 -- 807
					if i >= #args then -- 807
						return {success = false, message = arg .. " requires a value"} -- 808
					end -- 808
					ref = args[i + 1] -- 809
					goto __continue133 -- 810
				end -- 810
				if arg == "--depth" then
					i = i + 1 -- 813
					if i >= #args then -- 813
						return {success = false, message = "--depth requires a value"}
					end -- 814
					depth = args[i + 1] -- 815
					goto __continue133 -- 816
				end -- 816
				if __TS__StringStartsWith(arg, "--depth=") then
					depth = __TS__StringSlice(arg, #"--depth=")
					goto __continue133 -- 820
				end -- 820
				if __TS__StringStartsWith(arg, "-") then -- 820
					return {success = false, message = "unsupported clone option: " .. arg} -- 823
				end -- 823
				if url == "" then -- 823
					url = arg -- 826
					goto __continue133 -- 827
				end -- 827
				if target == "" then -- 827
					target = arg -- 830
					goto __continue133 -- 831
				end -- 831
				return {success = false, message = "unexpected clone argument: " .. arg} -- 833
			end -- 833
			::__continue133:: -- 833
			i = i + 1 -- 804
		end -- 804
	end -- 804
	if url == "" then -- 804
		return {success = false, message = "git clone requires a URL"} -- 835
	end -- 835
	if not isHttpUrl(url) then -- 835
		return {success = false, message = "git clone only supports http:// and https:// URLs"} -- 836
	end -- 836
	if target == "" then -- 836
		target = gitDefaultTargetFromUrl(url) -- 837
	end -- 837
	return { -- 838
		success = true, -- 839
		url = url, -- 840
		target = target, -- 841
		ref = ref, -- 842
		depth = depth ~= nil and depth ~= "" and depth or "1" -- 843
	} -- 843
end -- 788
local function getGitHeadCommit(repoPath) -- 847
	local headPath = Path(repoPath, ".git", "HEAD") -- 848
	if not Content:exist(headPath) then -- 848
		return nil -- 849
	end -- 849
	local head = __TS__StringTrim(toStr(Content:load(headPath))) -- 850
	local ref = string.match(head, "^ref:%s*(.-)%s*$") -- 851
	if ref ~= nil and ref ~= "" then -- 851
		local refPath = Path(repoPath, ".git", ref) -- 853
		if Content:exist(refPath) then -- 853
			local commit = __TS__StringTrim(toStr(Content:load(refPath))) -- 855
			return commit ~= "" and commit or nil -- 856
		end -- 856
		return nil -- 858
	end -- 858
	return head ~= "" and head or nil -- 860
end -- 847
local function runGitAndWait(repoPath, command, onStatus, isCancelled, timeout) -- 863
	if timeout == nil then -- 863
		timeout = 600 -- 868
	end -- 868
	return __TS__New( -- 870
		__TS__Promise, -- 870
		function(____, resolve) -- 870
			local status -- 871
			local jobId = 0 -- 872
			local settled = false -- 873
			local canceled = false -- 874
			local function finish(result) -- 875
				if settled then -- 875
					return -- 876
				end -- 876
				settled = true -- 877
				resolve(nil, result) -- 878
			end -- 875
			local function finishFromStatus() -- 880
				local state = toStr(status and status.state) -- 881
				if state == "done" then -- 881
					finish({success = true, status = status}) -- 883
					return true -- 884
				end -- 884
				if state == "error" or state == "canceled" then -- 884
					local errorMessage = toStr(status and status.error) -- 887
					local statusMessage = toStr(status and status.message) -- 888
					finish({success = false, message = errorMessage ~= "" and errorMessage or (statusMessage ~= "" and statusMessage or (state == "canceled" and "git command canceled" or "git command failed")), status = status, interrupted = state == "canceled"}) -- 889
					return true -- 895
				end -- 895
				return false -- 897
			end -- 880
			jobId = Git:run( -- 899
				repoPath, -- 899
				command, -- 899
				function(nextStatus) -- 899
					status = nextStatus -- 900
					if onStatus then -- 900
						onStatus(status) -- 901
					end -- 901
					return finishFromStatus() -- 902
				end, -- 899
				"" -- 903
			) -- 903
			if jobId == nil or jobId <= 0 then -- 903
				finish({success = false, message = "failed to start git command"}) -- 905
				return -- 906
			end -- 906
			if not status then -- 906
				local kind = string.match(command, "^(%S+)") -- 909
				status = { -- 910
					id = jobId, -- 911
					state = "queued", -- 912
					kind = toStr(kind), -- 913
					repoPath = repoPath, -- 914
					progress = 0, -- 915
					message = "queued" -- 916
				} -- 916
			end -- 916
			if onStatus then -- 916
				onStatus(status) -- 919
			end -- 919
			local startedAt = os.time() -- 920
			local lastEmitAt = startedAt -- 921
			Director.systemScheduler:schedule(function() -- 922
				if settled then -- 922
					return true -- 923
				end -- 923
				if not canceled and isCancelled and isCancelled() then -- 923
					canceled = true -- 925
					Git:cancel(jobId) -- 926
					finish({success = false, message = "git command canceled", status = status, interrupted = true}) -- 927
					return true -- 928
				end -- 928
				if finishFromStatus() then -- 928
					return true -- 930
				end -- 930
				local nowTime = os.time() -- 931
				if nowTime - startedAt >= timeout then -- 931
					Git:cancel(jobId) -- 933
					finish({success = false, message = "git command timed out", status = status}) -- 934
					return true -- 935
				end -- 935
				if onStatus and status and nowTime > lastEmitAt then -- 935
					lastEmitAt = nowTime -- 938
					onStatus(status) -- 939
				end -- 939
				return false -- 941
			end) -- 922
		end -- 870
	) -- 870
end -- 863
local function downloadFile(req) -- 946
	return __TS__New( -- 953
		__TS__Promise, -- 953
		function(____, resolve) -- 953
			local requestId = 0 -- 954
			local settled = false -- 955
			local bytesWritten = 0 -- 956
			local function finish(result) -- 957
				if settled then -- 957
					return -- 958
				end -- 958
				settled = true -- 959
				requestId = 0 -- 960
				resolve(nil, result) -- 961
			end -- 957
			Director.systemScheduler:schedule(function() -- 963
				if settled then -- 963
					return true -- 964
				end -- 964
				local ____this_9 -- 964
				____this_9 = req -- 965
				local ____opt_8 = ____this_9.isCancelled -- 965
				if (____opt_8 and ____opt_8(____this_9)) == true and requestId ~= 0 then -- 965
					HttpClient:cancel(requestId) -- 966
					finish({success = false, interrupted = true, message = "download canceled"}) -- 967
					return true -- 968
				end -- 968
				if requestId ~= 0 and not HttpClient:isRequestActive(requestId) then -- 968
					finish({success = false, message = "download request ended without a completion callback"}) -- 971
					return true -- 972
				end -- 972
				return false -- 974
			end) -- 963
			Director.systemScheduler:schedule(once(function() -- 976
				requestId = HttpClient:download( -- 977
					req.url, -- 977
					req.tempPath, -- 977
					req.timeout, -- 977
					function(interrupted, current, total) -- 977
						if type(current) == "number" and current > bytesWritten then -- 977
							bytesWritten = current -- 979
						end -- 979
						if interrupted then -- 979
							finish({success = false, interrupted = true, message = "download failed"}) -- 982
							return true -- 983
						end -- 983
						local ____this_11 -- 983
						____this_11 = req -- 985
						local ____opt_10 = ____this_11.isCancelled -- 985
						if (____opt_10 and ____opt_10(____this_11)) == true then -- 985
							finish({success = false, interrupted = true, message = "download canceled"}) -- 986
							return true -- 987
						end -- 987
						if current == total then -- 987
							finish({success = true, bytesWritten = bytesWritten}) -- 990
							return false -- 991
						end -- 991
						req:onProgress(current, total) -- 993
						return false -- 994
					end -- 977
				) -- 977
				if requestId == 0 then -- 977
					finish({success = false, message = "failed to schedule download request"}) -- 997
				else -- 997
					local ____this_13 -- 997
					____this_13 = req -- 998
					local ____opt_12 = ____this_13.isCancelled -- 998
					if (____opt_12 and ____opt_12(____this_13)) == true then -- 998
						HttpClient:cancel(requestId) -- 999
						finish({success = false, interrupted = true, message = "download canceled"}) -- 1000
					end -- 1000
				end -- 1000
			end)) -- 976
		end -- 953
	) -- 953
end -- 946
local function getFileState(path) -- 1006
	local exists = Content:exist(path) -- 1007
	if not exists then -- 1007
		return {exists = false, content = "", bytes = 0} -- 1009
	end -- 1009
	if Content:isdir(path) then -- 1009
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 1016
	end -- 1016
	local content = Content:load(path) -- 1023
	if type(content) ~= "string" then -- 1023
		return {exists = true, content = "", bytes = 0} -- 1025
	end -- 1025
	return {exists = true, content = content, bytes = #content} -- 1031
end -- 1006
local function inspectReadableFile(path) -- 1038
	do -- 1038
		local function ____catch(e) -- 1038
			Log( -- 1060
				"Warn", -- 1060
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 1060
			) -- 1060
			return true, {success = true} -- 1061
		end -- 1061
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1061
			local size, isBinary = Content:getAttr(path) -- 1040
			if size == nil then -- 1040
				return true, {success = false, message = "failed to read file"} -- 1042
			end -- 1042
			if isBinary then -- 1042
				return true, { -- 1048
					success = false, -- 1049
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 1050
					size = type(size) == "number" and size or nil, -- 1051
					isBinary = true -- 1052
				} -- 1052
			end -- 1052
			return true, { -- 1055
				success = true, -- 1056
				size = type(size) == "number" and size or nil -- 1057
			} -- 1057
		end) -- 1057
		if not ____try then -- 1057
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1057
		end -- 1057
		if ____hasReturned then -- 1057
			return ____returnValue -- 1039
		end -- 1039
	end -- 1039
end -- 1038
local function isEngineLogFilePath(path) -- 1065
	return path == ENGINE_LOG_VIRTUAL_FILE -- 1066
end -- 1065
local function readEngineLogFile(path) -- 1069
	if not isEngineLogFilePath(path) then -- 1069
		return nil -- 1070
	end -- 1070
	local content = getEngineLogText() -- 1071
	if content == nil then -- 1071
		return {success = false, message = "failed to read engine logs"} -- 1073
	end -- 1073
	return {success = true, content = content, size = #content} -- 1075
end -- 1069
local function queryOne(sql, args) -- 1078
	local ____args_14 -- 1079
	if args then -- 1079
		____args_14 = DB:query(sql, args) -- 1079
	else -- 1079
		____args_14 = DB:query(sql) -- 1079
	end -- 1079
	local rows = ____args_14 -- 1079
	if not rows or #rows == 0 then -- 1079
		return nil -- 1080
	end -- 1080
	return rows[1] -- 1081
end -- 1078
local function isDtsFile(path) -- 1084
	return Path:getExt(Path:getName(path)) == "d" -- 1085
end -- 1084
local function isTiledEditorContent(content) -- 1088
	return __TS__StringStartsWith( -- 1089
		__TS__StringTrim(content), -- 1089
		"<?xml" -- 1089
	) -- 1089
end -- 1088
local function getSupportedBuildKind(path) -- 1094
	repeat -- 1094
		local ____switch201 = Path:getExt(path) -- 1094
		local ____cond201 = ____switch201 == "ts" or ____switch201 == "tsx" -- 1094
		if ____cond201 then -- 1094
			return "ts" -- 1096
		end -- 1096
		____cond201 = ____cond201 or ____switch201 == "xml" -- 1096
		if ____cond201 then -- 1096
			return "xml" -- 1097
		end -- 1097
		____cond201 = ____cond201 or ____switch201 == "tl" -- 1097
		if ____cond201 then -- 1097
			return "teal" -- 1098
		end -- 1098
		____cond201 = ____cond201 or ____switch201 == "lua" -- 1098
		if ____cond201 then -- 1098
			return "lua" -- 1099
		end -- 1099
		____cond201 = ____cond201 or ____switch201 == "yue" -- 1099
		if ____cond201 then -- 1099
			return "yue" -- 1100
		end -- 1100
		____cond201 = ____cond201 or ____switch201 == "yarn" -- 1100
		if ____cond201 then -- 1100
			return "yarn" -- 1101
		end -- 1101
		do -- 1101
			return nil -- 1102
		end -- 1102
	until true -- 1102
end -- 1094
local function getTaskHeadSeq(taskId) -- 1106
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1107
	if not row then -- 1107
		return nil -- 1108
	end -- 1108
	return row[1] or 0 -- 1109
end -- 1106
local function getTaskStatus(taskId) -- 1112
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1113
	if not row then -- 1113
		return nil -- 1114
	end -- 1114
	return toStr(row[1]) -- 1115
end -- 1112
local function getLastInsertRowId() -- 1118
	local row = queryOne("SELECT last_insert_rowid()") -- 1119
	return row and (row[1] or 0) or 0 -- 1120
end -- 1118
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 1123
	DB:exec( -- 1124
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 1124
		{ -- 1126
			taskId, -- 1126
			seq, -- 1126
			status, -- 1126
			summary, -- 1126
			toolName, -- 1126
			now() -- 1126
		} -- 1126
	) -- 1126
	return getLastInsertRowId() -- 1128
end -- 1123
local function getCheckpointEntries(checkpointId, desc) -- 1131
	if desc == nil then -- 1131
		desc = false -- 1131
	end -- 1131
	local rows = DB:query((("SELECT id, ord, path, op, before_exists,\n\t\t\tdora_decompress_text(before_data),\n\t\t\tafter_exists,\n\t\t\tdora_decompress_text(after_data)\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 1132
	if not rows then -- 1132
		return {} -- 1142
	end -- 1142
	local result = {} -- 1143
	do -- 1143
		local i = 0 -- 1144
		while i < #rows do -- 1144
			local row = rows[i + 1] -- 1145
			result[#result + 1] = { -- 1146
				id = row[1], -- 1147
				ord = row[2], -- 1148
				path = toStr(row[3]), -- 1149
				op = toStr(row[4]), -- 1150
				beforeExists = toBool(row[5]), -- 1151
				beforeContent = toStr(row[6]), -- 1152
				afterExists = toBool(row[7]), -- 1153
				afterContent = toStr(row[8]) -- 1154
			} -- 1154
			i = i + 1 -- 1144
		end -- 1144
	end -- 1144
	return result -- 1157
end -- 1131
local function getCheckpointEntryMetadata(checkpointId, desc) -- 1160
	if desc == nil then -- 1160
		desc = false -- 1160
	end -- 1160
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, after_exists, bytes_before, bytes_after\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 1161
	if not rows then -- 1161
		return {} -- 1168
	end -- 1168
	local result = {} -- 1169
	do -- 1169
		local i = 0 -- 1170
		while i < #rows do -- 1170
			local row = rows[i + 1] -- 1171
			result[#result + 1] = { -- 1172
				id = row[1], -- 1173
				ord = row[2], -- 1174
				path = toStr(row[3]), -- 1175
				op = toStr(row[4]), -- 1176
				beforeExists = toBool(row[5]), -- 1177
				afterExists = toBool(row[6]), -- 1178
				bytesBefore = row[7] or 0, -- 1179
				bytesAfter = row[8] or 0 -- 1180
			} -- 1180
			i = i + 1 -- 1170
		end -- 1170
	end -- 1170
	return result -- 1183
end -- 1160
local function rejectDuplicatePaths(changes) -- 1186
	local seen = __TS__New(Set) -- 1187
	for ____, change in ipairs(changes) do -- 1188
		local key = change.path -- 1189
		if seen:has(key) then -- 1189
			return key -- 1190
		end -- 1190
		seen:add(key) -- 1191
	end -- 1191
	return nil -- 1193
end -- 1186
local function getLinkedDeletePaths(workDir, path) -- 1196
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1197
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 1197
		return {} -- 1198
	end -- 1198
	local parent = Path:getPath(fullPath) -- 1199
	local baseName = string.lower(Path:getName(fullPath)) -- 1200
	local ext = Path:getExt(fullPath) -- 1201
	local linked = {} -- 1202
	for ____, file in ipairs(Content:getFiles(parent)) do -- 1203
		do -- 1203
			if string.lower(Path:getName(file)) ~= baseName then -- 1203
				goto __continue222 -- 1204
			end -- 1204
			local siblingExt = Path:getExt(file) -- 1205
			if siblingExt == "tl" and ext == "vs" then -- 1205
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1207
					workDir, -- 1207
					Path(parent, file) -- 1207
				) -- 1207
				goto __continue222 -- 1208
			end -- 1208
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 1208
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1211
					workDir, -- 1211
					Path(parent, file) -- 1211
				) -- 1211
			end -- 1211
		end -- 1211
		::__continue222:: -- 1211
	end -- 1211
	return linked -- 1214
end -- 1196
local function expandLinkedDeleteChanges(workDir, changes) -- 1217
	local expanded = {} -- 1218
	local seen = __TS__New(Set) -- 1219
	do -- 1219
		local i = 0 -- 1220
		while i < #changes do -- 1220
			do -- 1220
				local change = changes[i + 1] -- 1221
				if not seen:has(change.path) then -- 1221
					seen:add(change.path) -- 1223
					expanded[#expanded + 1] = change -- 1224
				end -- 1224
				if change.op ~= "delete" then -- 1224
					goto __continue229 -- 1226
				end -- 1226
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 1227
				do -- 1227
					local j = 0 -- 1228
					while j < #linkedPaths do -- 1228
						do -- 1228
							local linkedPath = linkedPaths[j + 1] -- 1229
							if seen:has(linkedPath) then -- 1229
								goto __continue233 -- 1230
							end -- 1230
							seen:add(linkedPath) -- 1231
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 1232
						end -- 1232
						::__continue233:: -- 1232
						j = j + 1 -- 1228
					end -- 1228
				end -- 1228
			end -- 1228
			::__continue229:: -- 1228
			i = i + 1 -- 1220
		end -- 1220
	end -- 1220
	return expanded -- 1235
end -- 1217
local function applySingleFile(path, exists, content) -- 1238
	if exists then -- 1238
		if not ensureDirForFile(path) then -- 1238
			return false -- 1240
		end -- 1240
		return Content:save(path, content) -- 1241
	end -- 1241
	if Content:exist(path) then -- 1241
		return Content:remove(path) -- 1244
	end -- 1244
	return true -- 1246
end -- 1238
local function rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 1249
	local entries = getCheckpointEntries(checkpointId, true) -- 1254
	local remaining = appliedCount -- 1255
	local failures = {} -- 1256
	do -- 1256
		local i = 0 -- 1257
		while i < #entries and remaining > 0 do -- 1257
			do -- 1257
				local entry = entries[i + 1] -- 1258
				if entry.ord > appliedCount then -- 1258
					goto __continue241 -- 1259
				end -- 1259
				local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1260
				if not fullPath or not applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) then -- 1260
					failures[#failures + 1] = entry.path -- 1262
				else -- 1262
					____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) -- 1264
				end -- 1264
				remaining = remaining - 1 -- 1266
			end -- 1266
			::__continue241:: -- 1266
			i = i + 1 -- 1257
		end -- 1257
	end -- 1257
	return #failures > 0 and "rollback failed for: " .. table.concat(failures, ", ") or nil -- 1268
end -- 1249
function ____exports.sendWebIDERefreshTree() -- 1288
	if HttpServer.wsConnectionCount == 0 then -- 1288
		return true -- 1290
	end -- 1290
	local payload = encodeJSON({name = "RefreshTree"}) -- 1292
	if not payload then -- 1292
		return false -- 1294
	end -- 1294
	emit("AppWS", "Send", payload) -- 1296
	return true -- 1297
end -- 1288
local function syncProjectFileToWebIDE(workDir, path) -- 1300
	local target = resolveWorkspaceFilePath(workDir, path) -- 1301
	if not target then -- 1301
		return false -- 1302
	end -- 1302
	if not Content:exist(target) then -- 1302
		return ____exports.sendWebIDEFileUpdate(target, false, "") -- 1304
	end -- 1304
	if Content:isdir(target) then -- 1304
		return ____exports.sendWebIDERefreshTree() -- 1307
	end -- 1307
	local content = "" -- 1309
	do -- 1309
		local function ____catch(e) -- 1309
			Log( -- 1317
				"Warn", -- 1317
				(("[Agent.Tools] failed to inspect file for Web IDE update file=" .. target) .. ": ") .. tostring(e) -- 1317
			) -- 1317
		end -- 1317
		local ____try, ____hasReturned = pcall(function() -- 1317
			local ____, isBinary = Content:getAttr(target) -- 1311
			if not isBinary then -- 1311
				local loaded = Content:load(target) -- 1313
				content = type(loaded) == "string" and loaded or "" -- 1314
			end -- 1314
		end) -- 1314
		if not ____try then -- 1314
			____catch(____hasReturned) -- 1314
		end -- 1314
	end -- 1314
	return ____exports.sendWebIDEFileUpdate(target, true, content) -- 1319
end -- 1300
local function refreshProjectTree(workDir, path) -- 1322
	local normalized = type(path) == "string" and __TS__StringTrim(path) or "" -- 1323
	if normalized == "" then -- 1323
		return ____exports.sendWebIDERefreshTree() -- 1325
	end -- 1325
	return syncProjectFileToWebIDE(workDir, normalized) -- 1327
end -- 1322
local function syncDownloadedFileToWebIDE(file) -- 1330
	local content = "" -- 1331
	do -- 1331
		local function ____catch(e) -- 1331
			Log( -- 1339
				"Warn", -- 1339
				(("[fetch_url] failed to inspect downloaded file for Web IDE update file=" .. file) .. ": ") .. tostring(e) -- 1339
			) -- 1339
		end -- 1339
		local ____try, ____hasReturned = pcall(function() -- 1339
			local ____, isBinary = Content:getAttr(file) -- 1333
			if not isBinary then -- 1333
				local loaded = Content:load(file) -- 1335
				content = type(loaded) == "string" and loaded or "" -- 1336
			end -- 1336
		end) -- 1336
		if not ____try then -- 1336
			____catch(____hasReturned) -- 1336
		end -- 1336
	end -- 1336
	return ____exports.sendWebIDEFileUpdate(file, true, content) -- 1341
end -- 1330
local function runSingleNonTsBuild(file) -- 1344
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1344
		return ____awaiter_resolve( -- 1344
			nil, -- 1344
			__TS__New( -- 1345
				__TS__Promise, -- 1345
				function(____, resolve) -- 1345
					local moduleName = "Script.Dev.WebServer" -- 1346
					local ____require_result_15 = require(moduleName) -- 1347
					local buildAsync = ____require_result_15.buildAsync -- 1347
					Director.systemScheduler:schedule(once(function() -- 1348
						local result = buildAsync(file) -- 1349
						resolve(nil, result) -- 1350
					end)) -- 1348
				end -- 1345
			) -- 1345
		) -- 1345
	end) -- 1345
end -- 1344
local transpileRequestSeq = 0 -- 1355
local TRANSPILE_READY_TIMEOUT_SECONDS = 5 -- 1356
local TRANSPILE_BUILD_TIMEOUT_SECONDS = 30 -- 1357
function ____exports.runSingleTsTranspile(file, content, projectRoot, isCancelled) -- 1359
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1359
		local done = false -- 1365
		local ready = false -- 1366
		transpileRequestSeq = transpileRequestSeq + 1 -- 1367
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 1368
		local result = {success = false, file = file, message = "Web IDE not connected"} -- 1369
		if HttpServer.wsConnectionCount == 0 then -- 1369
			return ____awaiter_resolve(nil, result) -- 1369
		end -- 1369
		local listener = Node() -- 1377
		listener:gslot( -- 1378
			"AppWS", -- 1378
			function(event) -- 1378
				if event.type ~= "Receive" then -- 1378
					return -- 1379
				end -- 1379
				local res = safeJsonDecode(event.msg) -- 1380
				if not res or __TS__ArrayIsArray(res) then -- 1380
					return -- 1381
				end -- 1381
				local payload = res -- 1382
				if payload.id ~= requestId then -- 1382
					return -- 1383
				end -- 1383
				if payload.name == "TranspileTSProbe" then -- 1383
					ready = true -- 1385
					return -- 1386
				end -- 1386
				if payload.name ~= "TranspileTS" then -- 1386
					return -- 1388
				end -- 1388
				if payload.success then -- 1388
					local luaFile = Path:replaceExt(file, "lua") -- 1390
					if Content:save( -- 1390
						luaFile, -- 1391
						tostring(payload.luaCode) -- 1391
					) then -- 1391
						result = {success = true, file = file} -- 1392
					else -- 1392
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 1394
					end -- 1394
				else -- 1394
					result = { -- 1397
						success = false, -- 1397
						file = file, -- 1397
						message = tostring(payload.message) -- 1397
					} -- 1397
				end -- 1397
				done = true -- 1399
			end -- 1378
		) -- 1378
		local probePayload = encodeJSON({name = "TranspileTSProbe", id = requestId}) -- 1401
		local buildPayload = encodeJSON({ -- 1402
			name = "TranspileTS", -- 1403
			id = requestId, -- 1404
			file = file, -- 1405
			content = content, -- 1406
			projectRoot = projectRoot -- 1407
		}) -- 1407
		if not probePayload or not buildPayload then -- 1407
			listener:removeFromParent() -- 1410
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 1410
		end -- 1410
		__TS__Await(__TS__New( -- 1413
			__TS__Promise, -- 1413
			function(____, resolve) -- 1413
				Director.systemScheduler:schedule(once(function() -- 1414
					emit("AppWS", "Send", probePayload) -- 1415
					local readyDeadline = App.runningTime + TRANSPILE_READY_TIMEOUT_SECONDS -- 1416
					wait(function() return ready or HttpServer.wsConnectionCount == 0 or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) == true end) -- 1417
					if not ready then -- 1417
						listener:removeFromParent() -- 1422
						if (isCancelled and isCancelled()) == true then -- 1422
							result = {success = false, file = file, message = "build canceled", interrupted = true} -- 1424
						elseif HttpServer.wsConnectionCount == 0 then -- 1424
							result = {success = false, file = file, message = "Web IDE disconnected"} -- 1426
						else -- 1426
							result = {success = false, file = file, message = "TypeScript transpiler is not ready"} -- 1428
						end -- 1428
						resolve(nil) -- 1430
						return -- 1431
					end -- 1431
					emit("AppWS", "Send", buildPayload) -- 1433
					local buildDeadline = App.runningTime + TRANSPILE_BUILD_TIMEOUT_SECONDS -- 1434
					wait(function() return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= buildDeadline or (isCancelled and isCancelled()) == true end) -- 1435
					if not done then -- 1435
						listener:removeFromParent() -- 1440
						if (isCancelled and isCancelled()) == true then -- 1440
							result = {success = false, file = file, message = "build canceled", interrupted = true} -- 1442
						elseif HttpServer.wsConnectionCount == 0 then -- 1442
							result = {success = false, file = file, message = "Web IDE disconnected"} -- 1444
						else -- 1444
							result = {success = false, file = file, message = "TypeScript transpile timed out"} -- 1446
						end -- 1446
					end -- 1446
					resolve(nil) -- 1449
				end)) -- 1414
			end -- 1413
		)) -- 1413
		return ____awaiter_resolve(nil, result) -- 1413
	end) -- 1413
end -- 1359
function ____exports.createTask(prompt, workMode) -- 1455
	if prompt == nil then -- 1455
		prompt = "" -- 1455
	end -- 1455
	if workMode == nil then -- 1455
		workMode = "code" -- 1455
	end -- 1455
	local storage = requireAgentStorage() -- 1456
	if not storage.success then -- 1456
		return storage -- 1457
	end -- 1457
	local t = now() -- 1458
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, work_mode, created_at, updated_at) VALUES(?, ?, 0, ?, ?, ?)", { -- 1459
		"RUNNING", -- 1461
		prompt, -- 1461
		workMode, -- 1461
		t, -- 1461
		t -- 1461
	}) -- 1461
	if affected <= 0 then -- 1461
		return {success = false, message = "failed to create task"} -- 1464
	end -- 1464
	return { -- 1466
		success = true, -- 1466
		taskId = getLastInsertRowId() -- 1466
	} -- 1466
end -- 1455
function ____exports.setTaskStatus(taskId, status) -- 1469
	DB:exec( -- 1470
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 1470
		{ -- 1470
			status, -- 1470
			now(), -- 1470
			taskId -- 1470
		} -- 1470
	) -- 1470
	Log( -- 1471
		"Info", -- 1471
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 1471
	) -- 1471
end -- 1469
function ____exports.listCheckpointsForTasks(taskIds) -- 1474
	local normalizedTaskIds = {} -- 1475
	local seenTaskIds = {} -- 1476
	do -- 1476
		local i = 0 -- 1477
		while i < #taskIds do -- 1477
			do -- 1477
				local taskId = math.floor(taskIds[i + 1]) -- 1478
				if taskId <= 0 or seenTaskIds[taskId] then -- 1478
					goto __continue299 -- 1479
				end -- 1479
				seenTaskIds[taskId] = true -- 1480
				normalizedTaskIds[#normalizedTaskIds + 1] = taskId -- 1481
			end -- 1481
			::__continue299:: -- 1481
			i = i + 1 -- 1477
		end -- 1477
	end -- 1477
	if #normalizedTaskIds == 0 then -- 1477
		return {} -- 1483
	end -- 1483
	local placeholders = table.concat( -- 1484
		__TS__ArrayMap( -- 1484
			normalizedTaskIds, -- 1484
			function() return "?" end -- 1484
		), -- 1484
		", " -- 1484
	) -- 1484
	local rows = DB:query(((("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id IN (") .. placeholders) .. ")\n\t\tORDER BY task_id DESC, seq DESC", normalizedTaskIds) -- 1485
	if not rows then -- 1485
		return {} -- 1492
	end -- 1492
	local items = {} -- 1493
	do -- 1493
		local i = 0 -- 1494
		while i < #rows do -- 1494
			local row = rows[i + 1] -- 1495
			items[#items + 1] = { -- 1496
				id = row[1], -- 1497
				taskId = row[2], -- 1498
				seq = row[3], -- 1499
				status = toStr(row[4]), -- 1500
				summary = toStr(row[5]), -- 1501
				toolName = toStr(row[6]), -- 1502
				createdAt = row[7] -- 1503
			} -- 1503
			i = i + 1 -- 1494
		end -- 1494
	end -- 1494
	return items -- 1506
end -- 1474
function ____exports.listCheckpoints(taskId) -- 1509
	return ____exports.listCheckpointsForTasks({taskId}) -- 1510
end -- 1509
function ____exports.getCheckpoint(checkpointId) -- 1513
	if checkpointId <= 0 then -- 1513
		return nil -- 1514
	end -- 1514
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE id = ?\n\t\tLIMIT 1", {checkpointId}) -- 1515
	if not rows or #rows == 0 then -- 1515
		return nil -- 1522
	end -- 1522
	local row = rows[1] -- 1523
	return { -- 1524
		id = row[1], -- 1525
		taskId = row[2], -- 1526
		seq = row[3], -- 1527
		status = toStr(row[4]), -- 1528
		summary = toStr(row[5]), -- 1529
		toolName = toStr(row[6]), -- 1530
		createdAt = row[7] -- 1531
	} -- 1531
end -- 1513
local function listCheckpointIdsForTask(taskId, desc) -- 1535
	if desc == nil then -- 1535
		desc = false -- 1535
	end -- 1535
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 1536
	if not rows then -- 1536
		return {} -- 1543
	end -- 1543
	local items = {} -- 1544
	do -- 1544
		local i = 0 -- 1545
		while i < #rows do -- 1545
			local row = rows[i + 1] -- 1546
			items[#items + 1] = {id = row[1], seq = row[2]} -- 1547
			i = i + 1 -- 1545
		end -- 1545
	end -- 1545
	return items -- 1552
end -- 1535
local function deriveFileOp(beforeExists, afterExists) -- 1555
	if not beforeExists and afterExists then -- 1555
		return "create" -- 1556
	end -- 1556
	if beforeExists and not afterExists then -- 1556
		return "delete" -- 1557
	end -- 1557
	return "write" -- 1558
end -- 1555
function ____exports.summarizeTaskChangeSet(taskId) -- 1561
	if not getTaskStatus(taskId) then -- 1561
		return {success = false, message = "task not found"} -- 1563
	end -- 1563
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1565
	local filesByPath = {} -- 1566
	local latestCheckpointId = nil -- 1572
	local latestCheckpointSeq = nil -- 1573
	do -- 1573
		local i = 0 -- 1574
		while i < #checkpoints do -- 1574
			local checkpoint = checkpoints[i + 1] -- 1575
			latestCheckpointId = checkpoint.id -- 1576
			latestCheckpointSeq = checkpoint.seq -- 1577
			local entries = getCheckpointEntryMetadata(checkpoint.id, false) -- 1578
			do -- 1578
				local j = 0 -- 1579
				while j < #entries do -- 1579
					local entry = entries[j + 1] -- 1580
					local item = filesByPath[entry.path] -- 1581
					if not item then -- 1581
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 1583
						filesByPath[entry.path] = item -- 1589
					end -- 1589
					item.afterExists = entry.afterExists -- 1591
					local ____item_checkpointIds_24 = item.checkpointIds -- 1591
					____item_checkpointIds_24[#____item_checkpointIds_24 + 1] = checkpoint.id -- 1592
					j = j + 1 -- 1579
				end -- 1579
			end -- 1579
			i = i + 1 -- 1574
		end -- 1574
	end -- 1574
	local files = {} -- 1595
	for ____, item in pairs(filesByPath) do -- 1596
		files[#files + 1] = { -- 1597
			path = item.path, -- 1598
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1599
			checkpointCount = #item.checkpointIds, -- 1600
			checkpointIds = item.checkpointIds -- 1601
		} -- 1601
	end -- 1601
	__TS__ArraySort( -- 1604
		files, -- 1604
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1604
	) -- 1604
	return { -- 1605
		success = true, -- 1606
		taskId = taskId, -- 1607
		checkpointCount = #checkpoints, -- 1608
		filesChanged = #files, -- 1609
		files = files, -- 1610
		latestCheckpointId = latestCheckpointId, -- 1611
		latestCheckpointSeq = latestCheckpointSeq -- 1612
	} -- 1612
end -- 1561
function ____exports.getTaskChangeSetDiff(taskId) -- 1616
	if not getTaskStatus(taskId) then -- 1616
		return {success = false, message = "task not found"} -- 1618
	end -- 1618
	local entryRows = DB:query(((("SELECT e.id, e.path, e.before_exists, e.after_exists\n\t\tFROM " .. TABLE_ENTRY) .. " e\n\t\tJOIN ") .. TABLE_CP) .. " c ON c.id = e.checkpoint_id\n\t\tWHERE c.task_id = ? AND c.status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY c.seq ASC, e.ord ASC", {taskId}) -- 1620
	if not entryRows or #entryRows == 0 then -- 1620
		return {success = false, message = "change set not found or empty"} -- 1629
	end -- 1629
	local filesByPath = {} -- 1631
	do -- 1631
		local i = 0 -- 1638
		while i < #entryRows do -- 1638
			local row = entryRows[i + 1] -- 1639
			local entryId = row[1] -- 1640
			local path = toStr(row[2]) -- 1641
			local item = filesByPath[path] -- 1642
			if not item then -- 1642
				item = { -- 1644
					path = path, -- 1645
					firstEntryId = entryId, -- 1646
					lastEntryId = entryId, -- 1647
					beforeExists = toBool(row[3]), -- 1648
					afterExists = toBool(row[4]) -- 1649
				} -- 1649
				filesByPath[path] = item -- 1651
			end -- 1651
			item.lastEntryId = entryId -- 1653
			item.afterExists = toBool(row[4]) -- 1654
			i = i + 1 -- 1638
		end -- 1638
	end -- 1638
	local files = {} -- 1656
	for ____, item in pairs(filesByPath) do -- 1657
		local contentRows = DB:query(((("SELECT\n\t\t\t\t(SELECT dora_decompress_text(before_data) FROM " .. TABLE_ENTRY) .. " WHERE id = ?),\n\t\t\t\t(SELECT dora_decompress_text(after_data) FROM ") .. TABLE_ENTRY) .. " WHERE id = ?)", {item.firstEntryId, item.lastEntryId}) -- 1658
		if not contentRows or #contentRows == 0 then -- 1658
			return {success = false, message = "failed to read checkpoint data for " .. item.path} -- 1665
		end -- 1665
		files[#files + 1] = { -- 1667
			path = item.path, -- 1668
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1669
			beforeExists = item.beforeExists, -- 1670
			afterExists = item.afterExists, -- 1671
			beforeContent = toStr(contentRows[1][1]), -- 1672
			afterContent = toStr(contentRows[1][2]) -- 1673
		} -- 1673
	end -- 1673
	__TS__ArraySort( -- 1676
		files, -- 1676
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1676
	) -- 1676
	return {success = true, files = files} -- 1677
end -- 1616
local function readWorkspaceFile(workDir, path, docLanguage) -- 1680
	local engineLog = readEngineLogFile(path) -- 1681
	if engineLog then -- 1681
		return engineLog -- 1682
	end -- 1682
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1683
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 1683
		local attr = inspectReadableFile(fullPath) -- 1685
		if not attr.success then -- 1685
			return attr -- 1686
		end -- 1686
		return { -- 1687
			success = true, -- 1687
			content = Content:load(fullPath), -- 1687
			size = attr.size -- 1687
		} -- 1687
	end -- 1687
	local docPath = resolveAgentDoraDocFilePath(path, docLanguage) -- 1689
	if docPath then -- 1689
		local attr = inspectReadableFile(docPath) -- 1691
		if not attr.success then -- 1691
			return attr -- 1692
		end -- 1692
		return { -- 1693
			success = true, -- 1693
			content = Content:load(docPath), -- 1693
			size = attr.size -- 1693
		} -- 1693
	end -- 1693
	if not fullPath then -- 1693
		return {success = false, message = "invalid path or workDir"} -- 1695
	end -- 1695
	return {success = false, message = "file not found"} -- 1696
end -- 1680
function ____exports.readFileRaw(workDir, path, docLanguage) -- 1699
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 1700
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 1700
		local attr = inspectReadableFile(path) -- 1702
		if not attr.success then -- 1702
			return attr -- 1703
		end -- 1703
		return { -- 1704
			success = true, -- 1704
			content = Content:load(path), -- 1704
			size = attr.size -- 1704
		} -- 1704
	end -- 1704
	return result -- 1706
end -- 1699
function ____exports.getLogs(req) -- 1721
	local text = getEngineLogText() -- 1722
	if text == nil then -- 1722
		return {success = false, message = "failed to read engine logs"} -- 1724
	end -- 1724
	local tailLines = math.max( -- 1726
		1, -- 1726
		math.floor(req and req.tailLines or 200) -- 1726
	) -- 1726
	local allLines = __TS__StringSplit(text, "\n") -- 1727
	local logs = __TS__ArraySlice( -- 1728
		allLines, -- 1728
		math.max(0, #allLines - tailLines) -- 1728
	) -- 1728
	return req and req.joinText and ({ -- 1729
		success = true, -- 1729
		logs = logs, -- 1729
		text = table.concat(logs, "\n") -- 1729
	}) or ({success = true, logs = logs}) -- 1729
end -- 1721
function ____exports.listFiles(req) -- 1732
	local root = req.path or "" -- 1738
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 1739
	if not searchRoot then -- 1739
		return {success = false, message = "invalid path or workDir"} -- 1741
	end -- 1741
	do -- 1741
		local function ____catch(e) -- 1741
			return true, { -- 1759
				success = false, -- 1759
				message = tostring(e) -- 1759
			} -- 1759
		end -- 1759
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1759
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 1744
			local globs = ensureSafeSearchGlobs(userGlobs) -- 1745
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 1746
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 1747
			local totalEntries = #files -- 1748
			local maxEntries = math.max( -- 1749
				1, -- 1749
				math.floor(req.maxEntries or 200) -- 1749
			) -- 1749
			local truncated = totalEntries > maxEntries -- 1750
			return true, { -- 1751
				success = true, -- 1752
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 1753
				totalEntries = totalEntries, -- 1754
				truncated = truncated, -- 1755
				maxEntries = maxEntries -- 1756
			} -- 1756
		end) -- 1756
		if not ____try then -- 1756
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1756
		end -- 1756
		if ____hasReturned then -- 1756
			return ____returnValue -- 1743
		end -- 1743
	end -- 1743
end -- 1732
local function formatReadSlice(content, startLine, endLine) -- 1763
	local lines = __TS__StringSplit(content, "\n") -- 1768
	local totalLines = #lines -- 1769
	if totalLines == 0 then -- 1769
		return { -- 1771
			success = true, -- 1772
			content = "", -- 1773
			totalLines = 0, -- 1774
			startLine = 1, -- 1775
			endLine = 0, -- 1776
			truncated = false -- 1777
		} -- 1777
	end -- 1777
	local rawStart = math.floor(startLine) -- 1780
	local rawEnd = math.floor(endLine) -- 1781
	if rawStart == 0 then -- 1781
		return {success = false, message = "startLine cannot be 0"} -- 1783
	end -- 1783
	if rawEnd == 0 then -- 1783
		return {success = false, message = "endLine cannot be 0"} -- 1786
	end -- 1786
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1788
	if start > totalLines then -- 1788
		return { -- 1792
			success = false, -- 1792
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1792
		} -- 1792
	end -- 1792
	local ____end = math.min( -- 1794
		totalLines, -- 1795
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1796
	) -- 1796
	if ____end < start then -- 1796
		return { -- 1801
			success = false, -- 1802
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1803
		} -- 1803
	end -- 1803
	local slice = {} -- 1806
	do -- 1806
		local i = start -- 1807
		while i <= ____end do -- 1807
			slice[#slice + 1] = lines[i] -- 1808
			i = i + 1 -- 1807
		end -- 1807
	end -- 1807
	local truncated = start > 1 or ____end < totalLines -- 1810
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1811
	local body = table.concat(slice, "\n") -- 1816
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1817
	return { -- 1818
		success = true, -- 1819
		content = output, -- 1820
		totalLines = totalLines, -- 1821
		startLine = start, -- 1822
		endLine = ____end, -- 1823
		truncated = truncated -- 1824
	} -- 1824
end -- 1763
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1828
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1835
	if not fallback.success or fallback.content == nil then -- 1835
		return fallback -- 1836
	end -- 1836
	local resolvedStartLine = startLine or 1 -- 1837
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1838
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1839
end -- 1828
local codeExtensions = { -- 1846
	".lua", -- 1846
	".tl", -- 1846
	".yue", -- 1846
	".ts", -- 1846
	".tsx", -- 1846
	".xml", -- 1846
	".md", -- 1846
	".yarn", -- 1846
	".wa", -- 1846
	".mod" -- 1846
} -- 1846
extensionLevels = { -- 1847
	vs = 2, -- 1848
	bl = 2, -- 1849
	ts = 1, -- 1850
	tsx = 1, -- 1851
	tl = 1, -- 1852
	yue = 1, -- 1853
	xml = 1, -- 1854
	lua = 0 -- 1855
} -- 1855
local function splitSearchPatterns(pattern) -- 1872
	local trimmed = __TS__StringTrim(pattern or "") -- 1873
	if trimmed == "" then -- 1873
		return {} -- 1874
	end -- 1874
	local out = {} -- 1875
	local seen = __TS__New(Set) -- 1876
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1877
		local p = __TS__StringTrim(tostring(p0)) -- 1878
		if p ~= "" and not seen:has(p) then -- 1878
			seen:add(p) -- 1880
			out[#out + 1] = p -- 1881
		end -- 1881
	end -- 1881
	return out -- 1884
end -- 1872
local function splitWhitespaceSearchPatterns(pattern) -- 1887
	local out = {} -- 1888
	local seen = __TS__New(Set) -- 1889
	for p0 in string.gmatch(pattern, "(%S+)") do -- 1890
		local p = __TS__StringTrim(tostring(p0)) -- 1891
		local key = string.lower(p) -- 1892
		if p ~= "" and not seen:has(key) then -- 1892
			seen:add(key) -- 1894
			out[#out + 1] = p -- 1895
		end -- 1895
	end -- 1895
	return out -- 1898
end -- 1887
local function mergeSearchFileResultsUnique(resultsList) -- 1901
	local merged = {} -- 1902
	local seen = __TS__New(Set) -- 1903
	do -- 1903
		local i = 0 -- 1904
		while i < #resultsList do -- 1904
			local list = resultsList[i + 1] -- 1905
			do -- 1905
				local j = 0 -- 1906
				while j < #list do -- 1906
					do -- 1906
						local row = list[j + 1] -- 1907
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1908
						if seen:has(key) then -- 1908
							goto __continue381 -- 1909
						end -- 1909
						seen:add(key) -- 1910
						merged[#merged + 1] = list[j + 1] -- 1911
					end -- 1911
					::__continue381:: -- 1911
					j = j + 1 -- 1906
				end -- 1906
			end -- 1906
			i = i + 1 -- 1904
		end -- 1904
	end -- 1904
	return merged -- 1914
end -- 1901
local function buildGroupedSearchResults(results) -- 1917
	local order = {} -- 1922
	local grouped = __TS__New(Map) -- 1923
	do -- 1923
		local i = 0 -- 1928
		while i < #results do -- 1928
			local row = results[i + 1] -- 1929
			local file = row.file -- 1930
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1931
			local bucket = grouped:get(key) -- 1932
			if not bucket then -- 1932
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1934
				grouped:set(key, bucket) -- 1935
				order[#order + 1] = key -- 1936
			end -- 1936
			bucket.totalMatches = bucket.totalMatches + 1 -- 1938
			local ____bucket_matches_29 = bucket.matches -- 1938
			____bucket_matches_29[#____bucket_matches_29 + 1] = results[i + 1] -- 1939
			i = i + 1 -- 1928
		end -- 1928
	end -- 1928
	local out = {} -- 1941
	do -- 1941
		local i = 0 -- 1946
		while i < #order do -- 1946
			local bucket = grouped:get(order[i + 1]) -- 1947
			if bucket then -- 1947
				out[#out + 1] = bucket -- 1948
			end -- 1948
			i = i + 1 -- 1946
		end -- 1946
	end -- 1946
	return out -- 1950
end -- 1917
local function mergeDoraDocSearchHitsUnique(resultsList) -- 1953
	local merged = {} -- 1954
	local seen = __TS__New(Set) -- 1955
	local index = 0 -- 1956
	local advanced = true -- 1957
	while advanced do -- 1957
		advanced = false -- 1959
		do -- 1959
			local i = 0 -- 1960
			while i < #resultsList do -- 1960
				do -- 1960
					local list = resultsList[i + 1] -- 1961
					if index >= #list then -- 1961
						goto __continue393 -- 1962
					end -- 1962
					advanced = true -- 1963
					local row = list[index + 1] -- 1964
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1965
					if seen:has(key) then -- 1965
						goto __continue393 -- 1966
					end -- 1966
					seen:add(key) -- 1967
					merged[#merged + 1] = row -- 1968
				end -- 1968
				::__continue393:: -- 1968
				i = i + 1 -- 1960
			end -- 1960
		end -- 1960
		index = index + 1 -- 1970
	end -- 1970
	return merged -- 1972
end -- 1953
local function getDoraDocFilePriority(file, docType, programmingLanguage) -- 1975
	if docType ~= "dora-api" then -- 1975
		return 100 -- 1976
	end -- 1976
	if programmingLanguage ~= "tsx" then -- 1976
		return 100 -- 1977
	end -- 1977
	repeat -- 1977
		local ____switch399 = string.lower(Path:getFilename(file)) -- 1977
		local ____cond399 = ____switch399 == "jsx.d.ts" -- 1977
		if ____cond399 then -- 1977
			return 0 -- 1979
		end -- 1979
		____cond399 = ____cond399 or ____switch399 == "dorax.d.ts" -- 1979
		if ____cond399 then -- 1979
			return 1 -- 1980
		end -- 1980
		____cond399 = ____cond399 or ____switch399 == "dora.d.ts" -- 1980
		if ____cond399 then -- 1980
			return 2 -- 1981
		end -- 1981
		do -- 1981
			return 100 -- 1982
		end -- 1982
	until true -- 1982
end -- 1975
local function sortDoraDocSearchHits(hits, docType, programmingLanguage) -- 1986
	local sorted = __TS__ArraySlice(hits) -- 1991
	__TS__ArraySort( -- 1992
		sorted, -- 1992
		function(____, a, b) -- 1992
			local pa = getDoraDocFilePriority(a.file, docType, programmingLanguage) -- 1993
			local pb = getDoraDocFilePriority(b.file, docType, programmingLanguage) -- 1994
			if pa ~= pb then -- 1994
				return pa - pb -- 1995
			end -- 1995
			local fa = string.lower(a.file) -- 1996
			local fb = string.lower(b.file) -- 1997
			if fa ~= fb then -- 1997
				return fa < fb and -1 or 1 -- 1998
			end -- 1998
			return (a.line or 0) - (b.line or 0) -- 1999
		end -- 1992
	) -- 1992
	return sorted -- 2001
end -- 1986
function ____exports.searchFiles(req) -- 2004
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2004
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 2017
		if not resolvedPath then -- 2017
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2017
		end -- 2017
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 2021
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 2022
		if not searchRoot then -- 2022
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2022
		end -- 2022
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 2022
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2022
		end -- 2022
		local patterns = splitSearchPatterns(req.pattern) -- 2029
		if #patterns == 0 then -- 2029
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2029
		end -- 2029
		return ____awaiter_resolve( -- 2029
			nil, -- 2029
			__TS__New( -- 2033
				__TS__Promise, -- 2033
				function(____, resolve) -- 2033
					Director.systemScheduler:schedule(once(function() -- 2034
						do -- 2034
							local function ____catch(e) -- 2034
								resolve( -- 2076
									nil, -- 2076
									{ -- 2076
										success = false, -- 2076
										message = tostring(e) -- 2076
									} -- 2076
								) -- 2076
							end -- 2076
							local ____try, ____hasReturned = pcall(function() -- 2076
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 2036
								local allResults = {} -- 2039
								do -- 2039
									local i = 0 -- 2040
									while i < #patterns do -- 2040
										local ____Content_34 = Content -- 2041
										local ____Content_searchFilesAsync_35 = Content.searchFilesAsync -- 2041
										local ____patterns_index_33 = patterns[i + 1] -- 2046
										local ____req_useRegex_30 = req.useRegex -- 2047
										if ____req_useRegex_30 == nil then -- 2047
											____req_useRegex_30 = false -- 2047
										end -- 2047
										local ____req_caseSensitive_31 = req.caseSensitive -- 2048
										if ____req_caseSensitive_31 == nil then -- 2048
											____req_caseSensitive_31 = false -- 2048
										end -- 2048
										local ____req_includeContent_32 = req.includeContent -- 2049
										if ____req_includeContent_32 == nil then -- 2049
											____req_includeContent_32 = true -- 2049
										end -- 2049
										allResults[#allResults + 1] = ____Content_searchFilesAsync_35( -- 2041
											____Content_34, -- 2041
											searchRoot, -- 2042
											codeExtensions, -- 2043
											extensionLevels, -- 2044
											searchGlobs, -- 2045
											____patterns_index_33, -- 2046
											____req_useRegex_30, -- 2047
											____req_caseSensitive_31, -- 2048
											____req_includeContent_32, -- 2049
											req.contentWindow or 120 -- 2050
										) -- 2050
										i = i + 1 -- 2040
									end -- 2040
								end -- 2040
								local results = mergeSearchFileResultsUnique(allResults) -- 2053
								local totalResults = #results -- 2054
								local limit = math.max( -- 2055
									1, -- 2055
									math.floor(req.limit or 20) -- 2055
								) -- 2055
								local offset = math.max( -- 2056
									0, -- 2056
									math.floor(req.offset or 0) -- 2056
								) -- 2056
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 2057
								local nextOffset = offset + #paged -- 2058
								local hasMore = nextOffset < totalResults -- 2059
								local truncated = offset > 0 or hasMore -- 2060
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 2061
								local groupByFile = req.groupByFile == true -- 2062
								resolve( -- 2063
									nil, -- 2063
									{ -- 2063
										success = true, -- 2064
										results = relativeResults, -- 2065
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 2066
										totalResults = totalResults, -- 2067
										truncated = truncated, -- 2068
										limit = limit, -- 2069
										offset = offset, -- 2070
										nextOffset = nextOffset, -- 2071
										hasMore = hasMore, -- 2072
										groupByFile = groupByFile -- 2073
									} -- 2073
								) -- 2073
							end) -- 2073
							if not ____try then -- 2073
								____catch(____hasReturned) -- 2073
							end -- 2073
						end -- 2073
					end)) -- 2034
				end -- 2033
			) -- 2033
		) -- 2033
	end) -- 2033
end -- 2004
function ____exports.searchDoraDoc(req) -- 2082
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2082
		local pattern = __TS__StringTrim(req.pattern or "") -- 2093
		if pattern == "" then -- 2093
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2093
		end -- 2093
		local patterns = splitSearchPatterns(pattern) -- 2095
		if #patterns == 0 then -- 2095
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2095
		end -- 2095
		local docType = req.docType or "dora-api" -- 2097
		local target = getDoraDocSearchTarget(docType, req.docLanguage, req.programmingLanguage) -- 2098
		local docRoot = target.root -- 2099
		local resultBaseRoot = getDoraDocResultBaseRoot(docType, req.docLanguage) -- 2100
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 2100
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 2100
		end -- 2100
		local exts = target.exts -- 2104
		local dotExts = __TS__ArrayMap( -- 2105
			exts, -- 2105
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 2105
		) -- 2105
		local globs = target.globs -- 2106
		local limit = math.max( -- 2107
			1, -- 2107
			math.floor(req.limit or 10) -- 2107
		) -- 2107
		return ____awaiter_resolve( -- 2107
			nil, -- 2107
			__TS__New( -- 2109
				__TS__Promise, -- 2109
				function(____, resolve) -- 2109
					Director.systemScheduler:schedule(once(function() -- 2110
						do -- 2110
							local function ____catch(e) -- 2110
								resolve( -- 2190
									nil, -- 2190
									{ -- 2190
										success = false, -- 2190
										message = tostring(e) -- 2190
									} -- 2190
								) -- 2190
							end -- 2190
							local ____try, ____hasReturned = pcall(function() -- 2190
								local allHits = {} -- 2112
								do -- 2112
									local p = 0 -- 2113
									while p < #patterns do -- 2113
										local ____Content_40 = Content -- 2114
										local ____Content_searchFilesAsync_41 = Content.searchFilesAsync -- 2114
										local ____array_39 = __TS__SparseArrayNew( -- 2114
											docRoot, -- 2115
											dotExts, -- 2116
											{}, -- 2117
											ensureSafeSearchGlobs(globs), -- 2118
											patterns[p + 1] -- 2119
										) -- 2119
										local ____req_useRegex_36 = req.useRegex -- 2120
										if ____req_useRegex_36 == nil then -- 2120
											____req_useRegex_36 = false -- 2120
										end -- 2120
										__TS__SparseArrayPush(____array_39, ____req_useRegex_36) -- 2120
										local ____req_caseSensitive_37 = req.caseSensitive -- 2121
										if ____req_caseSensitive_37 == nil then -- 2121
											____req_caseSensitive_37 = false -- 2121
										end -- 2121
										__TS__SparseArrayPush(____array_39, ____req_caseSensitive_37) -- 2121
										local ____req_includeContent_38 = req.includeContent -- 2122
										if ____req_includeContent_38 == nil then -- 2122
											____req_includeContent_38 = true -- 2122
										end -- 2122
										__TS__SparseArrayPush(____array_39, ____req_includeContent_38, req.contentWindow or 80) -- 2122
										local raw = ____Content_searchFilesAsync_41( -- 2114
											____Content_40, -- 2114
											__TS__SparseArraySpread(____array_39) -- 2114
										) -- 2114
										local hits = {} -- 2125
										do -- 2125
											local i = 0 -- 2126
											while i < #raw do -- 2126
												do -- 2126
													local row = raw[i + 1] -- 2127
													local file = toDocRelativePath(resultBaseRoot, row.file, docType) -- 2128
													if file == "" then -- 2128
														goto __continue426 -- 2129
													end -- 2129
													hits[#hits + 1] = { -- 2130
														file = file, -- 2131
														line = type(row.line) == "number" and row.line or nil, -- 2132
														content = type(row.content) == "string" and row.content or nil -- 2133
													} -- 2133
												end -- 2133
												::__continue426:: -- 2133
												i = i + 1 -- 2126
											end -- 2126
										end -- 2126
										allHits[#allHits + 1] = __TS__ArraySlice( -- 2136
											sortDoraDocSearchHits(hits, docType, req.programmingLanguage), -- 2136
											0, -- 2136
											limit -- 2136
										) -- 2136
										p = p + 1 -- 2113
									end -- 2113
								end -- 2113
								local hits = mergeDoraDocSearchHitsUnique(allHits) -- 2138
								local fallbackPatterns -- 2139
								if #hits == 0 and #patterns == 1 and req.useRegex ~= true and (string.find(pattern, "|", nil, true) or 0) - 1 < 0 then -- 2139
									local terms = splitWhitespaceSearchPatterns(pattern) -- 2144
									if #terms > 1 then -- 2144
										fallbackPatterns = terms -- 2146
										local fallbackHits = {} -- 2147
										do -- 2147
											local p = 0 -- 2148
											while p < #terms do -- 2148
												local ____Content_45 = Content -- 2149
												local ____Content_searchFilesAsync_46 = Content.searchFilesAsync -- 2149
												local ____array_44 = __TS__SparseArrayNew( -- 2149
													docRoot, -- 2150
													dotExts, -- 2151
													{}, -- 2152
													ensureSafeSearchGlobs(globs), -- 2153
													terms[p + 1], -- 2154
													false -- 2155
												) -- 2155
												local ____req_caseSensitive_42 = req.caseSensitive -- 2156
												if ____req_caseSensitive_42 == nil then -- 2156
													____req_caseSensitive_42 = false -- 2156
												end -- 2156
												__TS__SparseArrayPush(____array_44, ____req_caseSensitive_42) -- 2156
												local ____req_includeContent_43 = req.includeContent -- 2157
												if ____req_includeContent_43 == nil then -- 2157
													____req_includeContent_43 = true -- 2157
												end -- 2157
												__TS__SparseArrayPush(____array_44, ____req_includeContent_43, req.contentWindow or 80) -- 2157
												local raw = ____Content_searchFilesAsync_46( -- 2149
													____Content_45, -- 2149
													__TS__SparseArraySpread(____array_44) -- 2149
												) -- 2149
												local termHits = {} -- 2160
												do -- 2160
													local i = 0 -- 2161
													while i < #raw do -- 2161
														do -- 2161
															local row = raw[i + 1] -- 2162
															local file = toDocRelativePath(resultBaseRoot, row.file, docType) -- 2163
															if file == "" then -- 2163
																goto __continue433 -- 2164
															end -- 2164
															termHits[#termHits + 1] = { -- 2165
																file = file, -- 2166
																line = type(row.line) == "number" and row.line or nil, -- 2167
																content = type(row.content) == "string" and row.content or nil -- 2168
															} -- 2168
														end -- 2168
														::__continue433:: -- 2168
														i = i + 1 -- 2161
													end -- 2161
												end -- 2161
												fallbackHits[#fallbackHits + 1] = __TS__ArraySlice( -- 2171
													sortDoraDocSearchHits(termHits, docType, req.programmingLanguage), -- 2171
													0, -- 2171
													limit -- 2171
												) -- 2171
												p = p + 1 -- 2148
											end -- 2148
										end -- 2148
										hits = mergeDoraDocSearchHitsUnique(fallbackHits) -- 2173
									end -- 2173
								end -- 2173
								resolve(nil, { -- 2176
									success = true, -- 2177
									docType = docType, -- 2178
									docLanguage = req.docLanguage, -- 2179
									programmingLanguage = req.programmingLanguage, -- 2180
									exts = exts, -- 2181
									results = hits, -- 2182
									hint = "Use read_file directly with the namespaced file value from a search result to view the complete authoritative document.", -- 2183
									totalResults = #hits, -- 2184
									truncated = false, -- 2185
									limit = limit, -- 2186
									fallbackPatterns = fallbackPatterns -- 2187
								}) -- 2187
							end) -- 2187
							if not ____try then -- 2187
								____catch(____hasReturned) -- 2187
							end -- 2187
						end -- 2187
					end)) -- 2110
				end -- 2109
			) -- 2109
		) -- 2109
	end) -- 2109
end -- 2082
function ____exports.searchDoraDocHttp(req, callback) -- 2196
	local ____self_47 = ____exports.searchDoraDoc(req) -- 2196
	____self_47["then"]( -- 2196
		____self_47, -- 2196
		function(____, result) return callback(result) end -- 2207
	) -- 2207
end -- 2196
function ____exports.readDoraDoc(req) -- 2210
	local requestedFile = table.concat( -- 2216
		__TS__StringSplit(req.file or "", "\\"), -- 2216
		"/" -- 2216
	) -- 2216
	local file = requestedFile -- 2217
	local namespacedType = nil -- 2218
	if __TS__StringStartsWith(requestedFile, AGENT_DORA_DOC_PREFIX) then -- 2218
		local namespaced = __TS__StringSlice(requestedFile, #AGENT_DORA_DOC_PREFIX) -- 2220
		if __TS__StringStartsWith(namespaced, "dora-api/") then -- 2220
			namespacedType = "dora-api" -- 2222
			file = string.sub(namespaced, 10) -- 2223
		elseif __TS__StringStartsWith(namespaced, "love-api/") then -- 2223
			namespacedType = "love-api" -- 2225
			file = string.sub(namespaced, 10) -- 2226
		elseif __TS__StringStartsWith(namespaced, "tic80-api/") then -- 2226
			namespacedType = "tic80-api" -- 2228
			file = string.sub(namespaced, 11) -- 2229
		elseif __TS__StringStartsWith(namespaced, "dora-tutorial/") then -- 2229
			namespacedType = "dora-tutorial" -- 2231
			file = string.sub(namespaced, 15) -- 2232
		elseif __TS__StringStartsWith(namespaced, "api/") then -- 2232
			namespacedType = "dora-api" -- 2234
			file = string.sub(namespaced, 5) -- 2235
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 2235
			namespacedType = "dora-tutorial" -- 2237
			file = string.sub(namespaced, 10) -- 2238
		else -- 2238
			return {success = false, message = "invalid Dora doc namespace"} -- 2240
		end -- 2240
	end -- 2240
	if not isValidWorkspacePath(file) or file == "." then -- 2240
		return {success = false, message = "invalid file"} -- 2244
	end -- 2244
	local lowerFile = string.lower(file) -- 2246
	local isTutorialDoc = __TS__StringEndsWith(lowerFile, ".md") -- 2247
	local isAPIDoc = __TS__StringEndsWith(lowerFile, ".ts") or __TS__StringEndsWith(lowerFile, ".tl") -- 2248
	if not isTutorialDoc and not isAPIDoc then -- 2248
		return {success = false, message = "unsupported doc file type"} -- 2249
	end -- 2249
	local docType = namespacedType or (isTutorialDoc and "dora-tutorial" or "dora-api") -- 2250
	if not isDoraDocFileInScope(docType, file) then -- 2250
		return {success = false, message = "document is outside the requested search type"} -- 2252
	end -- 2252
	local root = getDoraDocResultBaseRoot(docType, req.docLanguage) -- 2254
	local fullPath = Path(root, file) -- 2255
	local relative = Path:getRelative(fullPath, root) -- 2256
	if relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 2256
		return {success = false, message = "invalid file"} -- 2258
	end -- 2258
	local readResult = ____exports.readFile(root, file, req.startLine or 1, req.endLine or -1) -- 2260
	if not readResult.success then -- 2260
		return readResult -- 2261
	end -- 2261
	return { -- 2262
		success = true, -- 2263
		docLanguage = req.docLanguage, -- 2264
		file = file, -- 2265
		content = readResult.content, -- 2266
		startLine = readResult.startLine, -- 2267
		endLine = readResult.endLine -- 2268
	} -- 2268
end -- 2210
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 2272
	if options == nil then -- 2272
		options = {} -- 2272
	end -- 2272
	local storage = requireAgentStorage() -- 2273
	if not storage.success then -- 2273
		return storage -- 2274
	end -- 2274
	if #changes == 0 then -- 2274
		return {success = false, message = "empty changes"} -- 2276
	end -- 2276
	if not isValidWorkDir(workDir) then -- 2276
		return {success = false, message = "invalid workDir"} -- 2279
	end -- 2279
	if not getTaskStatus(taskId) then -- 2279
		return {success = false, message = "task not found"} -- 2282
	end -- 2282
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 2284
	local dup = rejectDuplicatePaths(expandedChanges) -- 2285
	if dup then -- 2285
		return {success = false, message = "duplicate path in batch: " .. dup} -- 2287
	end -- 2287
	for ____, change in ipairs(expandedChanges) do -- 2290
		if not isValidWorkspacePath(change.path) then -- 2290
			return {success = false, message = "invalid path: " .. change.path} -- 2292
		end -- 2292
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 2292
			return {success = false, message = "missing content for " .. change.path} -- 2295
		end -- 2295
	end -- 2295
	local headSeq = getTaskHeadSeq(taskId) -- 2299
	if headSeq == nil then -- 2299
		return {success = false, message = "task not found"} -- 2300
	end -- 2300
	local nextSeq = headSeq + 1 -- 2301
	local preparedEntries = {} -- 2303
	do -- 2303
		local i = 0 -- 2304
		while i < #expandedChanges do -- 2304
			local change = expandedChanges[i + 1] -- 2305
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 2306
			if not fullPath then -- 2306
				return {success = false, message = "invalid path: " .. change.path} -- 2308
			end -- 2308
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 2308
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 2311
			end -- 2311
			local before = getFileState(fullPath) -- 2313
			local afterExists = change.op ~= "delete" -- 2314
			local afterContent = afterExists and (change.content or "") or "" -- 2315
			preparedEntries[#preparedEntries + 1] = { -- 2316
				id = 0, -- 2317
				ord = i + 1, -- 2318
				path = change.path, -- 2319
				op = change.op, -- 2320
				beforeExists = before.exists, -- 2321
				beforeContent = before.content, -- 2322
				afterExists = afterExists, -- 2323
				afterContent = afterContent -- 2324
			} -- 2324
			i = i + 1 -- 2304
		end -- 2304
	end -- 2304
	local checkpointId = insertCheckpoint( -- 2328
		taskId, -- 2328
		nextSeq, -- 2328
		options.summary or "", -- 2328
		options.toolName or "", -- 2328
		"PREPARED" -- 2328
	) -- 2328
	if checkpointId <= 0 then -- 2328
		return {success = false, message = "failed to create checkpoint"} -- 2330
	end -- 2330
	local entryRows = {} -- 2332
	do -- 2332
		local i = 0 -- 2333
		while i < #preparedEntries do -- 2333
			local entry = preparedEntries[i + 1] -- 2334
			entryRows[#entryRows + 1] = { -- 2335
				checkpointId, -- 2336
				entry.ord, -- 2337
				entry.path, -- 2338
				entry.op, -- 2339
				entry.beforeExists and 1 or 0, -- 2340
				entry.beforeContent, -- 2341
				entry.afterExists and 1 or 0, -- 2342
				entry.afterContent, -- 2343
				#entry.beforeContent, -- 2344
				#entry.afterContent -- 2345
			} -- 2345
			i = i + 1 -- 2333
		end -- 2333
	end -- 2333
	local entryInsert = {("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_data, after_exists, after_data, bytes_before, bytes_after)\n\t\tVALUES(?, ?, ?, ?, ?, dora_compress_text(?), ?, dora_compress_text(?), ?, ?)", entryRows} -- 2348
	if not DB:transaction({entryInsert}) then -- 2348
		DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2354
		return {success = false, message = "failed to insert checkpoint entries"} -- 2355
	end -- 2355
	local appliedCount = 0 -- 2358
	for ____, entry in ipairs(preparedEntries) do -- 2359
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2360
		if not fullPath then -- 2360
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2362
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2363
			return {success = false, message = ("invalid path: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2364
		end -- 2364
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 2366
		if not ok then -- 2366
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2368
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount + 1) -- 2369
			return {success = false, message = ("failed to apply file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2370
		end -- 2370
		appliedCount = appliedCount + 1 -- 2372
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 2372
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2374
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2375
			return {success = false, message = ("failed to sync file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; all applied files restored")} -- 2376
		end -- 2376
	end -- 2376
	DB:exec( -- 2380
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 2380
		{ -- 2382
			"APPLIED", -- 2382
			now(), -- 2382
			checkpointId -- 2382
		} -- 2382
	) -- 2382
	DB:exec( -- 2384
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 2384
		{ -- 2386
			nextSeq, -- 2386
			now(), -- 2386
			taskId -- 2386
		} -- 2386
	) -- 2386
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 2388
end -- 2272
function ____exports.deleteFile(taskId, workDir, targetFile, options) -- 2396
	if options == nil then -- 2396
		options = {} -- 2396
	end -- 2396
	local storage = requireAgentStorage() -- 2397
	if not storage.success then -- 2397
		return storage -- 2398
	end -- 2398
	if not isValidWorkDir(workDir) then -- 2398
		return {success = false, message = "invalid workDir"} -- 2400
	end -- 2400
	if not getTaskStatus(taskId) then -- 2400
		return {success = false, message = "task not found"} -- 2403
	end -- 2403
	if not isValidWorkspacePath(targetFile) then -- 2403
		return {success = false, message = "invalid path: " .. targetFile} -- 2406
	end -- 2406
	local fullPath = resolveWorkspaceFilePath(workDir, targetFile) -- 2408
	if not fullPath then -- 2408
		return {success = false, message = "invalid path: " .. targetFile} -- 2410
	end -- 2410
	if Content:exist(fullPath) and Content:isdir(fullPath) then -- 2410
		return {success = false, message = "delete_file only supports files, not directories: " .. targetFile} -- 2413
	end -- 2413
	local isBinary = false -- 2416
	if Content:exist(fullPath) then -- 2416
		do -- 2416
			local function ____catch(e) -- 2416
				Log( -- 2422
					"Warn", -- 2422
					(("[Agent.Tools] Content.getAttr failed before deleting " .. fullPath) .. ": ") .. tostring(e) -- 2422
				) -- 2422
			end -- 2422
			local ____try, ____hasReturned = pcall(function() -- 2422
				local ____, detectedBinary = Content:getAttr(fullPath) -- 2419
				isBinary = detectedBinary == true -- 2420
			end) -- 2420
			if not ____try then -- 2420
				____catch(____hasReturned) -- 2420
			end -- 2420
		end -- 2420
	end -- 2420
	if not isBinary then -- 2420
		local result = ____exports.applyFileChanges(taskId, workDir, {{path = targetFile, op = "delete"}}, options) -- 2426
		if not result.success then -- 2426
			return result -- 2427
		end -- 2427
		return __TS__ObjectAssign({}, result, {checkpointed = true, reversible = true, binary = false}) -- 2428
	end -- 2428
	if not Content:remove(fullPath) then -- 2428
		return {success = false, message = "failed to delete binary file: " .. targetFile} -- 2437
	end -- 2437
	if not ____exports.sendWebIDEFileUpdate(fullPath, false, "") then -- 2437
		____exports.sendWebIDERefreshTree() -- 2440
	end -- 2440
	return { -- 2442
		success = true, -- 2443
		taskId = taskId, -- 2444
		checkpointed = false, -- 2445
		reversible = false, -- 2446
		binary = true, -- 2447
		message = "Binary file deleted directly without a checkpoint; this deletion cannot be rolled back." -- 2448
	} -- 2448
end -- 2396
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 2452
	if not isValidWorkDir(workDir) then -- 2452
		return {success = false, message = "invalid workDir"} -- 2453
	end -- 2453
	if checkpointId <= 0 then -- 2453
		return {success = false, message = "invalid checkpointId"} -- 2454
	end -- 2454
	local entries = getCheckpointEntries(checkpointId, true) -- 2455
	if #entries == 0 then -- 2455
		return {success = false, message = "checkpoint not found or empty"} -- 2457
	end -- 2457
	for ____, entry in ipairs(entries) do -- 2459
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2460
		if not fullPath then -- 2460
			return {success = false, message = "invalid path: " .. entry.path} -- 2462
		end -- 2462
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 2464
		if not ok then -- 2464
			Log( -- 2466
				"Error", -- 2466
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2466
			) -- 2466
			Log( -- 2467
				"Info", -- 2467
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2467
			) -- 2467
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 2468
		end -- 2468
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 2468
			Log( -- 2471
				"Error", -- 2471
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2471
			) -- 2471
			Log( -- 2472
				"Info", -- 2472
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2472
			) -- 2472
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 2473
		end -- 2473
	end -- 2473
	DB:exec( -- 2476
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 2476
		{ -- 2476
			"REVERTED", -- 2476
			now(), -- 2476
			checkpointId -- 2476
		} -- 2476
	) -- 2476
	return {success = true, checkpointId = checkpointId} -- 2477
end -- 2452
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 2480
	if not isValidWorkDir(workDir) then -- 2480
		return {success = false, message = "invalid workDir"} -- 2481
	end -- 2481
	if not getTaskStatus(taskId) then -- 2481
		return {success = false, message = "task not found"} -- 2482
	end -- 2482
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 2483
	if #checkpoints == 0 then -- 2483
		return {success = false, message = "change set not found or empty"} -- 2485
	end -- 2485
	local lastCheckpointId = 0 -- 2487
	do -- 2487
		local i = 0 -- 2488
		while i < #checkpoints do -- 2488
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 2489
			if not result.success then -- 2489
				return {success = false, message = result.message} -- 2490
			end -- 2490
			lastCheckpointId = checkpoints[i + 1].id -- 2491
			i = i + 1 -- 2488
		end -- 2488
	end -- 2488
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 2493
end -- 2480
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 2501
	return getCheckpointEntries(checkpointId, false) -- 2502
end -- 2501
function ____exports.getCheckpointDiff(checkpointId) -- 2505
	if checkpointId <= 0 then -- 2505
		return {success = false, message = "invalid checkpointId"} -- 2507
	end -- 2507
	local entries = getCheckpointEntries(checkpointId, false) -- 2509
	if #entries == 0 then -- 2509
		return {success = false, message = "checkpoint not found or empty"} -- 2511
	end -- 2511
	return { -- 2513
		success = true, -- 2514
		files = __TS__ArrayMap( -- 2515
			entries, -- 2515
			function(____, entry) return { -- 2515
				path = entry.path, -- 2516
				op = entry.op, -- 2517
				beforeExists = entry.beforeExists, -- 2518
				afterExists = entry.afterExists, -- 2519
				beforeContent = entry.beforeContent, -- 2520
				afterContent = entry.afterContent -- 2521
			} end -- 2521
		) -- 2521
	} -- 2521
end -- 2505
local function finalizeBuildResult(workDir, messages) -- 2526
	local normalized = __TS__ArrayMap( -- 2527
		messages, -- 2527
		function(____, m) return m.success and __TS__ObjectAssign( -- 2527
			{}, -- 2528
			m, -- 2528
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2528
		) or __TS__ObjectAssign( -- 2528
			{}, -- 2529
			m, -- 2529
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2529
		) end -- 2529
	) -- 2529
	local total = #normalized -- 2530
	local failed = 0 -- 2531
	do -- 2531
		local i = 0 -- 2532
		while i < #normalized do -- 2532
			if not normalized[i + 1].success then -- 2532
				failed = failed + 1 -- 2533
			end -- 2533
			i = i + 1 -- 2532
		end -- 2532
	end -- 2532
	local passed = total - failed -- 2535
	if failed > 0 then -- 2535
		local interrupted = __TS__ArraySome( -- 2537
			normalized, -- 2537
			function(____, message) return not message.success and message.interrupted == true end -- 2537
		) -- 2537
		return { -- 2538
			success = false, -- 2539
			message = interrupted and "Build canceled." or ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 2540
			total = total, -- 2541
			passed = passed, -- 2542
			failed = failed, -- 2543
			messages = normalized, -- 2544
			interrupted = interrupted or nil -- 2545
		} -- 2545
	end -- 2545
	return { -- 2548
		success = true, -- 2549
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 2550
		total = total, -- 2551
		passed = passed, -- 2552
		failed = 0, -- 2553
		messages = normalized -- 2554
	} -- 2554
end -- 2526
function ____exports.build(req) -- 2558
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2558
		local ____this_49 -- 2558
		____this_49 = req -- 2559
		local ____opt_48 = ____this_49.isCancelled -- 2559
		if (____opt_48 and ____opt_48(____this_49)) == true then -- 2559
			return ____awaiter_resolve(nil, {success = false, message = "Build canceled.", interrupted = true}) -- 2559
		end -- 2559
		local targetRel = req.path or "" -- 2562
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2563
		if not target then -- 2563
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2563
		end -- 2563
		if not Content:exist(target) then -- 2563
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2563
		end -- 2563
		local messages = {} -- 2570
		if not Content:isdir(target) then -- 2570
			local kind = getSupportedBuildKind(target) -- 2572
			if not kind then -- 2572
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2572
			end -- 2572
			if kind == "ts" then -- 2572
				local content = Content:load(target) -- 2577
				if content == nil then -- 2577
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2577
				end -- 2577
				if isTiledEditorContent(content) then -- 2577
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2582
					return ____awaiter_resolve( -- 2582
						nil, -- 2582
						finalizeBuildResult(req.workDir, messages) -- 2583
					) -- 2583
				end -- 2583
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2583
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2583
				end -- 2583
				if not isDtsFile(target) then -- 2583
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir, req.isCancelled)) -- 2589
				end -- 2589
			else -- 2589
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2592
			end -- 2592
			Log( -- 2594
				"Info", -- 2594
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2594
			) -- 2594
			return ____awaiter_resolve( -- 2594
				nil, -- 2594
				finalizeBuildResult(req.workDir, messages) -- 2595
			) -- 2595
		end -- 2595
		local listResult = ____exports.listFiles({ -- 2597
			workDir = req.workDir, -- 2598
			path = targetRel, -- 2599
			globs = __TS__ArrayMap( -- 2600
				codeExtensions, -- 2600
				function(____, e) return "**/*" .. e end -- 2600
			), -- 2600
			maxEntries = 10000 -- 2601
		}) -- 2601
		local relFiles = listResult.success and listResult.files or ({}) -- 2604
		local tsFileData = {} -- 2605
		local buildQueue = {} -- 2606
		for ____, rel in ipairs(relFiles) do -- 2607
			do -- 2607
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2608
				local kind = getSupportedBuildKind(file) -- 2609
				if not kind then -- 2609
					goto __continue531 -- 2610
				end -- 2610
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2611
				if kind ~= "ts" then -- 2611
					goto __continue531 -- 2613
				end -- 2613
				local content = Content:load(file) -- 2615
				if content == nil then -- 2615
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2617
					goto __continue531 -- 2618
				end -- 2618
				if isTiledEditorContent(content) then -- 2618
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2621
					goto __continue531 -- 2622
				end -- 2622
				tsFileData[file] = content -- 2624
			end -- 2624
			::__continue531:: -- 2624
		end -- 2624
		do -- 2624
			local i = 0 -- 2626
			while i < #buildQueue do -- 2626
				do -- 2626
					local ____this_51 -- 2626
					____this_51 = req -- 2627
					local ____opt_50 = ____this_51.isCancelled -- 2627
					if (____opt_50 and ____opt_50(____this_51)) == true then -- 2627
						return ____awaiter_resolve(nil, {success = false, message = "Build canceled.", messages = messages, interrupted = true}) -- 2627
					end -- 2627
					local ____buildQueue_index_52 = buildQueue[i + 1] -- 2630
					local file = ____buildQueue_index_52.file -- 2630
					local kind = ____buildQueue_index_52.kind -- 2630
					if kind == "ts" then -- 2630
						local content = tsFileData[file] -- 2632
						if content == nil or isDtsFile(file) then -- 2632
							goto __continue538 -- 2634
						end -- 2634
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2634
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2637
							goto __continue538 -- 2638
						end -- 2638
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir, req.isCancelled)) -- 2640
						goto __continue538 -- 2641
					end -- 2641
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2643
				end -- 2643
				::__continue538:: -- 2643
				i = i + 1 -- 2626
			end -- 2626
		end -- 2626
		if #messages == 0 then -- 2626
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2646
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2646
		end -- 2646
		Log( -- 2649
			"Info", -- 2649
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2649
		) -- 2649
		return ____awaiter_resolve( -- 2649
			nil, -- 2649
			finalizeBuildResult(req.workDir, messages) -- 2650
		) -- 2650
	end) -- 2650
end -- 2558
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2653
local EXECUTE_COMMAND_ERROR_MAX = 4000 -- 2654
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 2655
local agentEntryRuntimeOwner = "" -- 2656
local function truncateCommandOutput(output) -- 2658
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2658
		return output -- 2659
	end -- 2659
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2660
end -- 2658
local function truncateCommandError(message) -- 2663
	if #message <= EXECUTE_COMMAND_ERROR_MAX then -- 2663
		return message -- 2664
	end -- 2664
	return __TS__StringSlice(message, 0, EXECUTE_COMMAND_ERROR_MAX) .. "\n... error message truncated ..." -- 2665
end -- 2663
local function executeLuaCommand(req) -- 2668
	local code = __TS__StringTrim(req.code or "") -- 2676
	if code == "" then -- 2676
		return __TS__Promise.resolve({ -- 2678
			success = false, -- 2678
			mode = "lua", -- 2678
			output = "", -- 2678
			message = "missing code", -- 2678
			phase = "validate" -- 2678
		}) -- 2678
	end -- 2678
	local output = {} -- 2680
	local entry = require("Script.Dev.Entry") -- 2681
	local ownsEntryRuntime = false -- 2682
	local contentAccessed = false -- 2683
	local refreshTreeCalled = false -- 2684
	local entryObjectBaseline = 0 -- 2685
	local entryLuaRefBaseline = 0 -- 2686
	local function acquireEntryRuntime() -- 2687
		if agentEntryRuntimeOwner ~= "" and agentEntryRuntimeOwner ~= req.operationId then -- 2687
			error("Dora entry runtime is busy with another Agent command") -- 2689
		end -- 2689
		agentEntryRuntimeOwner = req.operationId -- 2691
		ownsEntryRuntime = true -- 2692
	end -- 2687
	local function stopOwnedEntry() -- 2694
		if not ownsEntryRuntime then -- 2694
			return nil -- 2695
		end -- 2695
		local cleanupError -- 2696
		do -- 2696
			local function ____catch(e) -- 2696
				cleanupError = "failed to stop Agent test entry: " .. tostring(e) -- 2700
			end -- 2700
			local ____try, ____hasReturned = pcall(function() -- 2700
				entry.stop() -- 2698
			end) -- 2698
			if not ____try then -- 2698
				____catch(____hasReturned) -- 2698
			end -- 2698
		end -- 2698
		ownsEntryRuntime = false -- 2702
		if agentEntryRuntimeOwner == req.operationId then -- 2702
			agentEntryRuntimeOwner = "" -- 2704
		end -- 2704
		return cleanupError -- 2706
	end -- 2694
	local function startEntryWatchdog() -- 2708
		entryObjectBaseline = Dora.Object.count -- 2709
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 2710
	end -- 2708
	local function checkEntryWatchdog() -- 2712
		if not ownsEntryRuntime then -- 2712
			return nil -- 2713
		end -- 2713
		local objectCount = Dora.Object.count -- 2714
		local luaRefCount = Dora.Object.luaRefCount -- 2715
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 2716
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 2717
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 2718
		if not exceededTotal then -- 2718
			return nil -- 2721
		end -- 2721
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 2722
	end -- 2712
	local function normalizeEntryFile(value) -- 2726
		if not value or type(value) ~= "table" then -- 2726
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 2728
		end -- 2728
		local descriptor = value -- 2730
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 2731
		if relativeFile == "" then -- 2731
			relativeFile = "init" -- 2732
		end -- 2732
		if not isValidWorkspacePath(relativeFile) then -- 2732
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 2734
		end -- 2734
		local fileName = Path(req.workDir, relativeFile) -- 2736
		local ext = Path:getExt(fileName) -- 2737
		if ext ~= "" then -- 2737
			fileName = Path:replaceExt(fileName, "") -- 2738
		end -- 2738
		local luaFile = Path:replaceExt(fileName, "lua") -- 2739
		if not Content:exist(luaFile) then -- 2739
			error("Agent test entry was not built: " .. luaFile) -- 2741
		end -- 2741
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 2743
		return { -- 2744
			fileName = fileName, -- 2745
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 2746
		} -- 2746
	end -- 2726
	local function capturePrint(...) -- 2749
		local values = {...} -- 2749
		local parts = {} -- 2750
		do -- 2750
			local i = 0 -- 2751
			while i < #values do -- 2751
				parts[#parts + 1] = tostring(values[i + 1]) -- 2752
				i = i + 1 -- 2751
			end -- 2751
		end -- 2751
		output[#output + 1] = table.concat(parts, "\t") -- 2754
	end -- 2749
	local function refreshTree(path) -- 2756
		refreshTreeCalled = true -- 2757
		if path == nil then -- 2757
			return refreshProjectTree(req.workDir) -- 2759
		end -- 2759
		if type(path) ~= "string" then -- 2759
			error("refreshTree expects a project-relative file path string or no argument") -- 2762
		end -- 2762
		return refreshProjectTree(req.workDir, path) -- 2764
	end -- 2756
	local env = setmetatable( -- 2766
		{ -- 2766
			projectDir = req.workDir, -- 2767
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 2768
				if type(moduleNameValue) ~= "string" then -- 2768
					error("requireProjectModule expects a project module name string") -- 2770
				end -- 2770
				local moduleName = __TS__StringTrim(moduleNameValue) -- 2772
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 2772
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 2774
				end -- 2774
				local reloadModules = {moduleName} -- 2776
				if reloadModulesValue ~= nil then -- 2776
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 2776
						error("requireProjectModule reloadModules must be an array of module names") -- 2779
					end -- 2779
					local items = reloadModulesValue -- 2781
					do -- 2781
						local i = 0 -- 2782
						while i < #items do -- 2782
							local item = items[i + 1] -- 2783
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 2783
								error("requireProjectModule reloadModules contains an invalid module name") -- 2785
							end -- 2785
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 2785
								reloadModules[#reloadModules + 1] = item -- 2787
							end -- 2787
							i = i + 1 -- 2782
						end -- 2782
					end -- 2782
				end -- 2782
				local luaPackage = _G.package -- 2790
				local previousPath = luaPackage.path -- 2794
				local previousSearchPaths = Content.searchPaths -- 2795
				local scopedSearchPaths = {req.workDir} -- 2796
				do -- 2796
					local i = 0 -- 2797
					while i < #previousSearchPaths do -- 2797
						local searchPath = previousSearchPaths[i + 1] -- 2798
						if searchPath ~= req.workDir then -- 2798
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 2799
						end -- 2799
						i = i + 1 -- 2797
					end -- 2797
				end -- 2797
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 2801
				Content.searchPaths = scopedSearchPaths -- 2802
				do -- 2802
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2802
						do -- 2802
							local i = 0 -- 2804
							while i < #reloadModules do -- 2804
								local reloadName = reloadModules[i + 1] -- 2805
								luaPackage.loaded[reloadName] = nil -- 2806
								luaPackage.loaded[table.concat( -- 2807
									__TS__StringSplit(reloadName, "/"), -- 2807
									"." -- 2807
								)] = nil -- 2807
								luaPackage.loaded[table.concat( -- 2808
									__TS__StringSplit(reloadName, "."), -- 2808
									"/" -- 2808
								)] = nil -- 2808
								i = i + 1 -- 2804
							end -- 2804
						end -- 2804
						return true, require(table.concat( -- 2810
							__TS__StringSplit(moduleName, "/"), -- 2810
							"." -- 2810
						)) -- 2810
					end) -- 2810
					do -- 2810
						Content.searchPaths = previousSearchPaths -- 2812
						luaPackage.path = previousPath -- 2813
					end -- 2813
					if not ____try then -- 2813
						error(____hasReturned, 0) -- 2813
					end -- 2813
					if ____try and ____hasReturned then -- 2813
						return ____returnValue -- 2803
					end -- 2803
				end -- 2803
			end, -- 2768
			print = capturePrint, -- 2816
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 2817
			enterEntryAsync = function(value) -- 2818
				local normalized = normalizeEntryFile(value) -- 2819
				acquireEntryRuntime() -- 2820
				entry.allClear() -- 2821
				startEntryWatchdog() -- 2822
				local success, message = entry.enterEntryAsync({ -- 2823
					entryName = normalized.entryName, -- 2824
					fileName = normalized.fileName, -- 2825
					workDir = req.workDir, -- 2826
					projectRoot = req.workDir, -- 2827
					runKind = "agent_test" -- 2828
				}) -- 2828
				return success, message -- 2830
			end, -- 2818
			stopEntry = function() -- 2832
				if not ownsEntryRuntime then -- 2832
					return false -- 2833
				end -- 2833
				return entry.stop() -- 2834
			end, -- 2832
			reportProgress = function(value, callbackValue) -- 2836
				local ____callbackValue_53 = callbackValue -- 2837
				if ____callbackValue_53 == nil then -- 2837
					____callbackValue_53 = value -- 2837
				end -- 2837
				local actualValue = ____callbackValue_53 -- 2837
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 2837
					return -- 2838
				end -- 2838
				local progress = actualValue -- 2839
				local amount = type(progress.progress) == "number" and math.min( -- 2840
					1, -- 2841
					math.max(0, progress.progress) -- 2841
				) or nil -- 2841
				req:onProgress({ -- 2843
					state = "running", -- 2844
					mode = "lua", -- 2845
					operationId = req.operationId, -- 2846
					progress = amount, -- 2847
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 2848
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 2849
				}) -- 2849
			end -- 2836
		}, -- 2836
		{__index = function(_table, key) -- 2852
			if key == "Content" then -- 2852
				contentAccessed = true -- 2855
				return Content -- 2856
			end -- 2856
			if key == "refreshTree" then -- 2856
				return refreshTree -- 2859
			end -- 2859
			return Dora[tostring(key)] -- 2861
		end} -- 2853
	) -- 2853
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 2864
	if not fn then -- 2864
		return __TS__Promise.resolve({ -- 2866
			success = false, -- 2867
			mode = "lua", -- 2868
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2869
			message = truncateCommandError(toStr(compileErr)), -- 2870
			phase = "compile" -- 2871
		}) -- 2871
	end -- 2871
	return __TS__New( -- 2874
		__TS__Promise, -- 2874
		function(____, resolve) -- 2874
			local settled = false -- 2875
			local commandRoutine -- 2876
			local startedAt = App.runningTime -- 2877
			local onProgress = req.onProgress -- 2878
			local isCancelled = req.isCancelled -- 2879
			local function finish(result) -- 2880
				if settled then -- 2880
					return -- 2881
				end -- 2881
				settled = true -- 2882
				local cleanupError -- 2883
				if not result.success and (result.interrupted == true or result.phase == "timeout") then -- 2883
					do -- 2883
						local function ____catch(e) -- 2883
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 2888
						end -- 2888
						local ____try, ____hasReturned = pcall(function() -- 2888
							entry.allClear() -- 2886
						end) -- 2886
						if not ____try then -- 2886
							____catch(____hasReturned) -- 2886
						end -- 2886
					end -- 2886
				end -- 2886
				local entryCleanupError = stopOwnedEntry() -- 2891
				if cleanupError == nil then -- 2891
					cleanupError = entryCleanupError -- 2892
				end -- 2892
				if contentAccessed and not refreshTreeCalled and not refreshProjectTree(req.workDir) then -- 2892
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 2894
				end -- 2894
				if not result.success and cleanupError ~= nil then -- 2894
					result.cleanupError = cleanupError -- 2897
				elseif result.success and cleanupError ~= nil then -- 2897
					resolve(nil, { -- 2899
						success = false, -- 2900
						mode = "lua", -- 2901
						output = result.output, -- 2902
						message = cleanupError, -- 2903
						phase = "execute", -- 2904
						cleanupError = cleanupError -- 2905
					}) -- 2905
					return -- 2907
				end -- 2907
				resolve(nil, result) -- 2909
			end -- 2880
			if onProgress then -- 2880
				onProgress(nil, { -- 2912
					state = "pending", -- 2913
					mode = "lua", -- 2914
					operationId = req.operationId, -- 2915
					stage = "lua", -- 2916
					message = "Lua command pending" -- 2917
				}) -- 2917
			end -- 2917
			commandRoutine = once(function() -- 2920
				if settled then -- 2920
					return -- 2921
				end -- 2921
				if onProgress then -- 2921
					onProgress(nil, { -- 2923
						state = "running", -- 2924
						mode = "lua", -- 2925
						operationId = req.operationId, -- 2926
						stage = "lua", -- 2927
						message = "Lua command running" -- 2928
					}) -- 2928
				end -- 2928
				local previousGlobalPrint = _G.print -- 2931
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 2932
				local frameTimedOut = false -- 2933
				local watchdogMessage -- 2933
				_G.print = capturePrint -- 2934
				debug.sethook( -- 2935
					function() -- 2935
						if watchdogMessage == nil then -- 2935
							watchdogMessage = checkEntryWatchdog() -- 2936
						end -- 2936
						if watchdogMessage ~= nil then -- 2936
							error(watchdogMessage) -- 2937
						end -- 2937
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 2937
							frameTimedOut = true -- 2939
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 2940
						end -- 2940
					end, -- 2935
					"", -- 2942
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 2942
				) -- 2942
				local ok, runtimeErr = pcall(fn) -- 2943
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 2943
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 2945
				else -- 2945
					debug.sethook() -- 2951
				end -- 2951
				_G.print = previousGlobalPrint -- 2953
				if not ok then -- 2953
					local ____truncateCommandOutput_result_55 = truncateCommandOutput(table.concat(output, "\n")) -- 2958
					local ____temp_56 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 2959
					local ____temp_57 = frameTimedOut and "timeout" or "execute" -- 2960
					local ____temp_54 -- 2961
					if watchdogMessage ~= nil or frameTimedOut then -- 2961
						____temp_54 = true -- 2961
					else -- 2961
						____temp_54 = nil -- 2961
					end -- 2961
					finish({ -- 2955
						success = false, -- 2956
						mode = "lua", -- 2957
						output = ____truncateCommandOutput_result_55, -- 2958
						message = ____temp_56, -- 2959
						phase = ____temp_57, -- 2960
						interrupted = ____temp_54 -- 2961
					}) -- 2961
					return -- 2963
				end -- 2963
				finish({ -- 2965
					success = true, -- 2965
					mode = "lua", -- 2965
					output = truncateCommandOutput(table.concat(output, "\n")) -- 2965
				}) -- 2965
			end) -- 2920
			Director.systemScheduler:schedule(function() -- 2967
				if settled then -- 2967
					return true -- 2968
				end -- 2968
				local watchdogMessage = checkEntryWatchdog() -- 2969
				if watchdogMessage ~= nil then -- 2969
					finish({ -- 2971
						success = false, -- 2972
						mode = "lua", -- 2973
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2974
						message = watchdogMessage, -- 2975
						phase = "execute", -- 2976
						interrupted = true -- 2977
					}) -- 2977
					return true -- 2979
				end -- 2979
				if isCancelled and isCancelled(nil) then -- 2979
					finish({ -- 2982
						success = false, -- 2983
						mode = "lua", -- 2984
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2985
						message = "Lua command canceled", -- 2986
						phase = "execute", -- 2987
						interrupted = true -- 2988
					}) -- 2988
					return true -- 2990
				end -- 2990
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 2990
					finish({ -- 2993
						success = false, -- 2994
						mode = "lua", -- 2995
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2996
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 2997
						phase = "timeout" -- 2998
					}) -- 2998
					return true -- 3000
				end -- 3000
				if commandRoutine == nil then -- 3000
					finish({ -- 3003
						success = false, -- 3004
						mode = "lua", -- 3005
						output = truncateCommandOutput(table.concat(output, "\n")), -- 3006
						message = "Lua command coroutine is unavailable", -- 3007
						phase = "execute" -- 3008
					}) -- 3008
					return true -- 3010
				end -- 3010
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 3012
				if not resumeSuccess then -- 3012
					finish({ -- 3014
						success = false, -- 3015
						mode = "lua", -- 3016
						output = truncateCommandOutput(table.concat(output, "\n")), -- 3017
						message = truncateCommandError(toStr(resumeResult)), -- 3018
						phase = "execute" -- 3019
					}) -- 3019
					return true -- 3021
				end -- 3021
				return settled or resumeResult == true -- 3023
			end) -- 2967
		end -- 2874
	) -- 2874
end -- 2668
local function formatGitStatusOutput(status) -- 3028
	if not status then -- 3028
		return "" -- 3029
	end -- 3029
	local lines = {} -- 3030
	local state = toStr(status.state) -- 3031
	local kind = toStr(status.kind) -- 3032
	local message = toStr(status.message) -- 3033
	local errorMessage = toStr(status.error) -- 3034
	if kind ~= "" or state ~= "" then -- 3034
		lines[#lines + 1] = table.concat( -- 3036
			__TS__ArrayFilter( -- 3036
				{kind, state}, -- 3036
				function(____, item) return item ~= "" end -- 3036
			), -- 3036
			": " -- 3036
		) -- 3036
	end -- 3036
	if message ~= "" then -- 3036
		lines[#lines + 1] = message -- 3038
	end -- 3038
	if errorMessage ~= "" then -- 3038
		lines[#lines + 1] = errorMessage -- 3039
	end -- 3039
	local data = status.data -- 3040
	if data ~= nil then -- 3040
		local dataText = encodeJSON(data) -- 3042
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 3043
	end -- 3043
	return truncateCommandOutput(table.concat(lines, "\n")) -- 3045
end -- 3028
local function emitGitProgress(mode, operationId, onProgress, status) -- 3048
	if not onProgress then -- 3048
		return -- 3054
	end -- 3054
	local progress = type(status.progress) == "number" and status.progress or nil -- 3055
	local kind = toStr(status.kind) -- 3056
	local message = toStr(status.message) -- 3057
	local state = toStr(status.state) -- 3058
	local jobId = type(status.id) == "number" and status.id or nil -- 3059
	onProgress({ -- 3060
		state = "running", -- 3061
		mode = mode, -- 3062
		operationId = operationId, -- 3063
		stage = kind ~= "" and kind or "git", -- 3064
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 3065
		progress = progress, -- 3066
		jobId = jobId, -- 3067
		gitState = state ~= "" and state or nil, -- 3068
		gitKind = kind ~= "" and kind or nil -- 3069
	}) -- 3069
end -- 3048
local function cloneGitToTarget(req) -- 3073
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3073
		local parsed = parseGitCloneCommand(req.command) -- 3081
		if parsed == nil then -- 3081
			return ____awaiter_resolve(nil, nil) -- 3081
		end -- 3081
		if not parsed.success then -- 3081
			return ____awaiter_resolve(nil, { -- 3081
				success = false, -- 3084
				mode = "git", -- 3084
				output = "", -- 3084
				message = parsed.message, -- 3084
				phase = "validate" -- 3084
			}) -- 3084
		end -- 3084
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 3086
		if not target then -- 3086
			return ____awaiter_resolve(nil, { -- 3086
				success = false, -- 3088
				mode = "git", -- 3088
				output = "", -- 3088
				message = "invalid clone target path", -- 3088
				phase = "validate" -- 3088
			}) -- 3088
		end -- 3088
		if Content:exist(target) then -- 3088
			return ____awaiter_resolve(nil, { -- 3088
				success = false, -- 3091
				mode = "git", -- 3091
				output = "", -- 3091
				message = "target already exists", -- 3091
				phase = "validate" -- 3091
			}) -- 3091
		end -- 3091
		local targetParent = Path:getPath(target) -- 3093
		if not ensureDirPath(targetParent) then -- 3093
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 3093
		end -- 3093
		local tempRoot = getAgentDownloadTempRoot() -- 3097
		if not ensureDirPath(tempRoot) then -- 3097
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 3097
		end -- 3097
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 3101
		Content:remove(tempPath) -- 3102
		local depth = parsed.depth or "1" -- 3103
		local ____array_58 = __TS__SparseArrayNew( -- 3103
			"clone", -- 3105
			quoteGitArg(parsed.url), -- 3106
			quoteGitArg(Path:getFilename(tempPath)), -- 3107
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 3108
				"-b", -- 3108
				quoteGitArg(parsed.ref) -- 3108
			}) or ({})) -- 3108
		) -- 3108
		__TS__SparseArrayPush( -- 3108
			____array_58, -- 3108
			table.unpack(depth ~= "" and ({ -- 3109
				"--depth",
				quoteGitArg(depth) -- 3109
			}) or ({})) -- 3109
		) -- 3109
		local command = table.concat( -- 3104
			{__TS__SparseArraySpread(____array_58)}, -- 3104
			" " -- 3110
		) -- 3110
		local ____this_60 -- 3110
		____this_60 = req -- 3111
		local ____opt_59 = ____this_60.onProgress -- 3111
		if ____opt_59 ~= nil then -- 3111
			____opt_59(____this_60, { -- 3111
				state = "pending", -- 3112
				mode = "git", -- 3113
				operationId = req.operationId, -- 3114
				stage = "clone", -- 3115
				message = "clone pending", -- 3116
				progress = 0 -- 3117
			}) -- 3117
		end -- 3117
		local gitRes = __TS__Await(runGitAndWait( -- 3119
			tempRoot, -- 3120
			command, -- 3121
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 3122
			function() -- 3123
				local ____this_62 -- 3123
				____this_62 = req -- 3123
				local ____opt_61 = ____this_62.isCancelled -- 3123
				return (____opt_61 and ____opt_61(____this_62)) == true -- 3123
			end, -- 3123
			req.timeoutSeconds -- 3124
		)) -- 3124
		if not gitRes.success then -- 3124
			local cleanupError = cleanupPath(tempPath) -- 3127
			local ____formatGitStatusOutput_result_66 = formatGitStatusOutput(gitRes.status) -- 3131
			local ____temp_67 = gitRes.message or "git clone failed" -- 3132
			local ____gitRes_interrupted_65 = gitRes.interrupted -- 3133
			if not ____gitRes_interrupted_65 then -- 3133
				local ____this_64 -- 3133
				____this_64 = req -- 3133
				local ____opt_63 = ____this_64.isCancelled -- 3133
				____gitRes_interrupted_65 = (____opt_63 and ____opt_63(____this_64)) == true -- 3133
			end -- 3133
			return ____awaiter_resolve(nil, { -- 3133
				success = false, -- 3129
				mode = "git", -- 3130
				output = ____formatGitStatusOutput_result_66, -- 3131
				message = ____temp_67, -- 3132
				interrupted = ____gitRes_interrupted_65, -- 3133
				cleanupError = cleanupError -- 3134
			}) -- 3134
		end -- 3134
		if not Content:move(tempPath, target) then -- 3134
			local cleanupError = cleanupPath(tempPath) -- 3138
			return ____awaiter_resolve( -- 3138
				nil, -- 3138
				{ -- 3139
					success = false, -- 3139
					mode = "git", -- 3139
					output = formatGitStatusOutput(gitRes.status), -- 3139
					message = "failed to move cloned repository into target path", -- 3139
					cleanupError = cleanupError -- 3139
				} -- 3139
			) -- 3139
		end -- 3139
		if not refreshProjectTree(req.workDir) then -- 3139
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 3142
		end -- 3142
		local commit = getGitHeadCommit(target) -- 3144
		local output = table.concat( -- 3145
			__TS__ArrayFilter( -- 3145
				{ -- 3145
					formatGitStatusOutput(gitRes.status), -- 3146
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 3146
					commit ~= nil and "commit " .. commit or "" -- 3148
				}, -- 3148
				function(____, item) return item ~= "" end -- 3149
			), -- 3149
			"\n" -- 3149
		) -- 3149
		return ____awaiter_resolve( -- 3149
			nil, -- 3149
			{ -- 3150
				success = true, -- 3150
				mode = "git", -- 3150
				output = truncateCommandOutput(output) -- 3150
			} -- 3150
		) -- 3150
	end) -- 3150
end -- 3073
local function loadGitProfile() -- 3153
	local rows -- 3154
	do -- 3154
		local function ____catch() -- 3154
			return true, nil -- 3158
		end -- 3158
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 3158
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 3156
		end) -- 3156
		if not ____try then -- 3156
			____hasReturned, ____returnValue = ____catch() -- 3156
		end -- 3156
		if ____hasReturned then -- 3156
			return ____returnValue -- 3155
		end -- 3155
	end -- 3155
	if not rows or not rows[1] then -- 3155
		return nil -- 3160
	end -- 3160
	local name = toStr(rows[1][1]) -- 3161
	local email = toStr(rows[1][2]) -- 3162
	if name == "" and email == "" then -- 3162
		return nil -- 3163
	end -- 3163
	return {name = name, email = email} -- 3164
end -- 3153
local function applyGitProfileToCommit(command) -- 3167
	local args = shellSplit(command) -- 3168
	if args[1] ~= "commit" then -- 3168
		return command -- 3169
	end -- 3169
	local hasName = false -- 3170
	local hasEmail = false -- 3171
	for ____, arg in ipairs(args) do -- 3172
		if arg == "--author-name" then
			hasName = true -- 3173
		end -- 3173
		if arg == "--author-email" then
			hasEmail = true -- 3174
		end -- 3174
	end -- 3174
	if hasName and hasEmail then -- 3174
		return command -- 3176
	end -- 3176
	local profile = loadGitProfile() -- 3177
	if not profile then -- 3177
		return command -- 3178
	end -- 3178
	local additions = {} -- 3179
	if not hasName and profile.name ~= "" then -- 3179
		__TS__ArrayPush( -- 3181
			additions, -- 3181
			"--author-name",
			quoteGitArg(profile.name) -- 3181
		) -- 3181
	end -- 3181
	if not hasEmail and profile.email ~= "" then -- 3181
		__TS__ArrayPush( -- 3184
			additions, -- 3184
			"--author-email",
			quoteGitArg(profile.email) -- 3184
		) -- 3184
	end -- 3184
	if #additions == 0 then -- 3184
		return command -- 3186
	end -- 3186
	return (command .. " ") .. table.concat(additions, " ") -- 3187
end -- 3167
local function executeGitCommand(req) -- 3190
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3190
		local command = normalizeGitCommand(req.command or "") -- 3199
		if command == "" then -- 3199
			return ____awaiter_resolve(nil, { -- 3199
				success = false, -- 3201
				mode = "git", -- 3201
				output = "", -- 3201
				message = "missing command", -- 3201
				phase = "validate" -- 3201
			}) -- 3201
		end -- 3201
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 3203
			workDir = req.workDir, -- 3204
			command = command, -- 3205
			operationId = req.operationId, -- 3206
			timeoutSeconds = req.timeoutSeconds, -- 3207
			onProgress = req.onProgress, -- 3208
			isCancelled = req.isCancelled -- 3209
		})) -- 3209
		if cloneResult ~= nil then -- 3209
			return ____awaiter_resolve(nil, cloneResult) -- 3209
		end -- 3209
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 3212
		if not cwd.success then -- 3212
			return ____awaiter_resolve(nil, { -- 3212
				success = false, -- 3214
				mode = "git", -- 3214
				output = "", -- 3214
				cwd = req.cwd, -- 3214
				message = cwd.message, -- 3214
				phase = "validate" -- 3214
			}) -- 3214
		end -- 3214
		command = applyGitProfileToCommit(command) -- 3216
		local ____this_69 -- 3216
		____this_69 = req -- 3217
		local ____opt_68 = ____this_69.onProgress -- 3217
		if ____opt_68 ~= nil then -- 3217
			____opt_68(____this_69, { -- 3217
				state = "pending", -- 3218
				mode = "git", -- 3219
				operationId = req.operationId, -- 3220
				stage = "git", -- 3221
				message = "git command pending", -- 3222
				progress = 0 -- 3223
			}) -- 3223
		end -- 3223
		local gitRes = __TS__Await(runGitAndWait( -- 3225
			cwd.path, -- 3226
			command, -- 3227
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 3228
			function() -- 3229
				local ____this_71 -- 3229
				____this_71 = req -- 3229
				local ____opt_70 = ____this_71.isCancelled -- 3229
				return (____opt_70 and ____opt_70(____this_71)) == true -- 3229
			end, -- 3229
			req.timeoutSeconds -- 3230
		)) -- 3230
		local output = formatGitStatusOutput(gitRes.status) -- 3232
		if not gitRes.success then -- 3232
			local ____output_75 = output -- 3237
			local ____cwd_relative_76 = cwd.relative -- 3238
			local ____temp_77 = gitRes.message or "git command failed" -- 3239
			local ____gitRes_interrupted_74 = gitRes.interrupted -- 3240
			if not ____gitRes_interrupted_74 then -- 3240
				local ____this_73 -- 3240
				____this_73 = req -- 3240
				local ____opt_72 = ____this_73.isCancelled -- 3240
				____gitRes_interrupted_74 = (____opt_72 and ____opt_72(____this_73)) == true -- 3240
			end -- 3240
			return ____awaiter_resolve(nil, { -- 3240
				success = false, -- 3235
				mode = "git", -- 3236
				output = ____output_75, -- 3237
				cwd = ____cwd_relative_76, -- 3238
				message = ____temp_77, -- 3239
				interrupted = ____gitRes_interrupted_74 -- 3240
			}) -- 3240
		end -- 3240
		if not refreshProjectTree(req.workDir) then -- 3240
			Log("Warn", (("[execute_command] failed to refresh Web IDE tree after Git command workDir=" .. req.workDir) .. " cwd=") .. cwd.relative) -- 3244
		end -- 3244
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 3244
	end) -- 3244
end -- 3190
function ____exports.executeCommand(req) -- 3249
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3249
		local mode = req.mode -- 3259
		if mode ~= "lua" and mode ~= "git" then -- 3259
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 3259
		end -- 3259
		if mode == "lua" then -- 3259
			return ____awaiter_resolve( -- 3259
				nil, -- 3259
				executeLuaCommand({ -- 3264
					workDir = req.workDir, -- 3265
					code = req.code or "", -- 3266
					timeoutSeconds = math.max( -- 3267
						1, -- 3267
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 3267
					), -- 3267
					operationId = createOperationId(), -- 3268
					onProgress = req.onProgress, -- 3269
					isCancelled = req.isCancelled -- 3270
				}) -- 3270
			) -- 3270
		end -- 3270
		local operationId = createOperationId() -- 3273
		return ____awaiter_resolve( -- 3273
			nil, -- 3273
			executeGitCommand({ -- 3274
				workDir = req.workDir, -- 3275
				command = req.command or "", -- 3276
				cwd = req.cwd, -- 3277
				timeoutSeconds = math.max( -- 3278
					1, -- 3278
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 3278
				), -- 3278
				operationId = operationId, -- 3279
				onProgress = req.onProgress, -- 3280
				isCancelled = req.isCancelled -- 3281
			}) -- 3281
		) -- 3281
	end) -- 3281
end -- 3249
function ____exports.fetchUrl(req) -- 3285
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3285
		local mode = "download" -- 3292
		local url = __TS__StringTrim(req.url or "") -- 3293
		local targetRel = __TS__StringTrim(req.target or "") -- 3294
		if not isHttpUrl(url) then -- 3294
			return ____awaiter_resolve(nil, { -- 3294
				success = false, -- 3296
				state = "failed", -- 3296
				mode = mode, -- 3296
				target = targetRel, -- 3296
				message = "fetch_url only supports http:// and https:// URLs" -- 3296
			}) -- 3296
		end -- 3296
		if targetRel == "" then -- 3296
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 3296
		end -- 3296
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 3301
		if not target then -- 3301
			return ____awaiter_resolve(nil, { -- 3301
				success = false, -- 3303
				state = "failed", -- 3303
				mode = mode, -- 3303
				target = targetRel, -- 3303
				message = "invalid target path" -- 3303
			}) -- 3303
		end -- 3303
		if Content:exist(target) then -- 3303
			return ____awaiter_resolve(nil, { -- 3303
				success = false, -- 3306
				state = "failed", -- 3306
				mode = mode, -- 3306
				target = targetRel, -- 3306
				message = "target already exists" -- 3306
			}) -- 3306
		end -- 3306
		local operationId = createOperationId() -- 3308
		local tempRoot = getAgentDownloadTempRoot() -- 3309
		if not ensureDirPath(tempRoot) then -- 3309
			return ____awaiter_resolve(nil, { -- 3309
				success = false, -- 3311
				state = "failed", -- 3311
				mode = mode, -- 3311
				target = targetRel, -- 3311
				message = "failed to create agent download temp directory" -- 3311
			}) -- 3311
		end -- 3311
		local tempPath = Path(tempRoot, operationId .. ".download") -- 3313
		Content:remove(tempPath) -- 3314
		local function emitProgress(progress) -- 3315
			if not req.onProgress then -- 3315
				return -- 3316
			end -- 3316
			req:onProgress(__TS__ObjectAssign({ -- 3317
				state = "running", -- 3318
				mode = mode, -- 3319
				operationId = operationId, -- 3320
				target = targetRel, -- 3321
				tempPath = tempPath -- 3322
			}, progress)) -- 3322
		end -- 3315
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 3326
		local function interrupted() -- 3331
			local ____this_79 -- 3331
			____this_79 = req -- 3331
			local ____opt_78 = ____this_79.isCancelled -- 3331
			return (____opt_78 and ____opt_78(____this_79)) == true -- 3331
		end -- 3331
		if not ensureDirForFile(tempPath) then -- 3331
			return ____awaiter_resolve(nil, { -- 3331
				success = false, -- 3333
				state = "failed", -- 3333
				mode = mode, -- 3333
				target = targetRel, -- 3333
				message = "failed to create temporary file directory" -- 3333
			}) -- 3333
		end -- 3333
		local downloadRes = __TS__Await(downloadFile({ -- 3335
			url = url, -- 3336
			tempPath = tempPath, -- 3337
			timeout = 600, -- 3338
			isCancelled = interrupted, -- 3339
			onProgress = function(____, current, total) -- 3340
				local totalNumber = type(total) == "number" and total or 0 -- 3341
				emitProgress({ -- 3342
					stage = "download", -- 3343
					message = "downloading", -- 3344
					current = current, -- 3345
					total = total, -- 3346
					progress = totalNumber > 0 and current / totalNumber or nil -- 3347
				}) -- 3347
			end -- 3340
		})) -- 3340
		if not downloadRes.success then -- 3340
			local cleanupError = cleanupPath(tempPath) -- 3352
			return ____awaiter_resolve( -- 3352
				nil, -- 3352
				{ -- 3353
					success = false, -- 3354
					state = "failed", -- 3355
					mode = mode, -- 3356
					target = targetRel, -- 3357
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 3358
					interrupted = downloadRes.interrupted or interrupted(), -- 3359
					cleanupError = cleanupError -- 3360
				} -- 3360
			) -- 3360
		end -- 3360
		if not ensureDirForFile(target) then -- 3360
			local cleanupError = cleanupPath(tempPath) -- 3364
			return ____awaiter_resolve(nil, { -- 3364
				success = false, -- 3365
				state = "failed", -- 3365
				mode = mode, -- 3365
				target = targetRel, -- 3365
				message = "failed to create target directory", -- 3365
				cleanupError = cleanupError -- 3365
			}) -- 3365
		end -- 3365
		if not Content:move(tempPath, target) then -- 3365
			local cleanupError = cleanupPath(tempPath) -- 3368
			return ____awaiter_resolve(nil, { -- 3368
				success = false, -- 3369
				state = "failed", -- 3369
				mode = mode, -- 3369
				target = targetRel, -- 3369
				message = "failed to move downloaded file into target path", -- 3369
				cleanupError = cleanupError -- 3369
			}) -- 3369
		end -- 3369
		local bytesWritten = downloadRes.bytesWritten -- 3371
		local ____try = __TS__AsyncAwaiter(function() -- 3371
			local size = Content:getAttr(target) -- 3373
			if bytesWritten == nil or bytesWritten <= 0 then -- 3373
				bytesWritten = type(size) == "number" and size or nil -- 3375
			end -- 3375
		end) -- 3375
		____try = ____try.catch( -- 3375
			____try, -- 3375
			function(____, _) -- 3375
				return __TS__AsyncAwaiter(function() -- 3375
				end) -- 3375
			end -- 3375
		) -- 3375
		__TS__Await(____try) -- 3372
		if bytesWritten == nil or bytesWritten <= 0 then -- 3372
			local ____try = __TS__AsyncAwaiter(function() -- 3372
				local loaded = Content:load(target) -- 3382
				if type(loaded) == "string" then -- 3382
					bytesWritten = #loaded -- 3384
				end -- 3384
			end) -- 3384
			____try = ____try.catch( -- 3384
				____try, -- 3384
				function(____, _) -- 3384
					return __TS__AsyncAwaiter(function() -- 3384
					end) -- 3384
				end -- 3384
			) -- 3384
			__TS__Await(____try) -- 3381
		end -- 3381
		if not syncDownloadedFileToWebIDE(target) then -- 3381
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 3391
		end -- 3391
		return ____awaiter_resolve(nil, { -- 3391
			success = true, -- 3393
			state = "done", -- 3393
			mode = mode, -- 3393
			target = targetRel, -- 3393
			bytesWritten = bytesWritten -- 3393
		}) -- 3393
	end) -- 3393
end -- 3285
return ____exports -- 3285