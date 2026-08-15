-- [ts]: Tools.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayFlatMap = ____lualib.__TS__ArrayFlatMap -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Set = ____lualib.Set -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local Map = ____lualib.Map -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local ____exports = {} -- 1
local encodeJSON, getEngineLogText, ensureSafeSearchGlobs, ENGINE_LOG_DOWNLOAD_DIR, ENGINE_LOG_FILE, extensionLevels -- 1
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
local ____socket = require("socket") -- 14
local dns = ____socket.dns -- 14
function encodeJSON(obj) -- 1368
	local text = safeJsonEncode(obj) -- 1369
	return text -- 1370
end -- 1370
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 1373
	if HttpServer.wsConnectionCount == 0 then -- 1373
		return true -- 1375
	end -- 1375
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 1377
	if not payload then -- 1377
		return false -- 1379
	end -- 1379
	emit("AppWS", "Send", payload) -- 1381
	return true -- 1382
end -- 1373
function getEngineLogText() -- 1806
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 1807
	if not Content:exist(folder) then -- 1807
		Content:mkdir(folder) -- 1809
	end -- 1809
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 1811
	if not App:saveLog(logPath) then -- 1811
		return nil -- 1813
	end -- 1813
	return Content:load(logPath) -- 1815
end -- 1815
function ensureSafeSearchGlobs(globs) -- 1955
	local result = {} -- 1956
	do -- 1956
		local i = 0 -- 1957
		while i < #globs do -- 1957
			result[#result + 1] = globs[i + 1] -- 1958
			i = i + 1 -- 1957
		end -- 1957
	end -- 1957
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1960
	do -- 1960
		local i = 0 -- 1961
		while i < #requiredExcludes do -- 1961
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1961
				result[#result + 1] = requiredExcludes[i + 1] -- 1963
			end -- 1963
			i = i + 1 -- 1961
		end -- 1961
	end -- 1961
	return result -- 1966
end -- 1966
local function recoverJsonStringProperty(text, key) -- 22
	local marker = ("\"" .. key) .. "\"" -- 23
	local markerIndex = (string.find(text, marker, nil, true) or 0) - 1 -- 24
	if markerIndex < 0 then -- 24
		return nil -- 25
	end -- 25
	local colonIndex = (string.find( -- 26
		text, -- 26
		":", -- 26
		math.max(markerIndex + #marker + 1, 1), -- 26
		true -- 26
	) or 0) - 1 -- 26
	if colonIndex < 0 then -- 26
		return nil -- 27
	end -- 27
	local quoteIndex = colonIndex + 1 -- 28
	while quoteIndex < #text do -- 28
		local code = __TS__StringCharCodeAt(text, quoteIndex) -- 30
		if code ~= 32 and code ~= 9 and code ~= 10 and code ~= 13 then -- 30
			break -- 31
		end -- 31
		quoteIndex = quoteIndex + 1 -- 32
	end -- 32
	if quoteIndex >= #text or __TS__StringCharCodeAt(text, quoteIndex) ~= 34 then -- 32
		return nil -- 34
	end -- 34
	local escaped = false -- 35
	do -- 35
		local i = quoteIndex + 1 -- 36
		while i < #text do -- 36
			do -- 36
				local code = __TS__StringCharCodeAt(text, i) -- 37
				if escaped then -- 37
					escaped = false -- 39
					goto __continue9 -- 40
				end -- 40
				if code == 92 then -- 40
					escaped = true -- 43
					goto __continue9 -- 44
				end -- 44
				if code == 34 then -- 44
					local decoded = safeJsonDecode(("{\"value\":" .. __TS__StringSlice(text, quoteIndex, i + 1)) .. "}") -- 47
					if decoded and type(decoded) == "table" and type(decoded.value) == "string" then -- 47
						return {value = decoded.value, complete = true} -- 49
					end -- 49
					return nil -- 51
				end -- 51
			end -- 51
			::__continue9:: -- 51
			i = i + 1 -- 36
		end -- 36
	end -- 36
	local fragment = __TS__StringSlice(text, quoteIndex) -- 54
	do -- 54
		local trim = 0 -- 55
		while trim <= 6 and trim <= #fragment - 1 do -- 55
			local decoded = safeJsonDecode(("{\"value\":" .. __TS__StringSlice(fragment, 0, #fragment - trim)) .. "\"}") -- 56
			if decoded and type(decoded) == "table" and type(decoded.value) == "string" then -- 56
				return {value = decoded.value, complete = false} -- 58
			end -- 58
			trim = trim + 1 -- 55
		end -- 55
	end -- 55
	return nil -- 61
end -- 22
--- Recover only a truncated whole-file overwrite. A truncated replacement with
-- non-empty old_str is unsafe and deliberately returns undefined.
function ____exports.planTruncatedEditRecovery(toolCalls) -- 68
	if not toolCalls or #toolCalls == 0 then -- 68
		return nil -- 71
	end -- 71
	do -- 71
		local i = #toolCalls - 1 -- 72
		while i >= 0 do -- 72
			do -- 72
				local ____opt_0 = toolCalls[i + 1] -- 72
				local fn = ____opt_0 and ____opt_0["function"] -- 73
				if not fn or fn.name ~= "edit_file" or type(fn.arguments) ~= "string" then -- 73
					goto __continue20 -- 74
				end -- 74
				local recovered = recoverJsonStringProperty(fn.arguments, "new_str") -- 75
				if not recovered or recovered.complete or #recovered.value == 0 then -- 75
					goto __continue20 -- 76
				end -- 76
				local target = recoverJsonStringProperty(fn.arguments, "path") or recoverJsonStringProperty(fn.arguments, "target_file") -- 77
				local oldStr = recoverJsonStringProperty(fn.arguments, "old_str") -- 79
				if not target or not target.complete or not oldStr or not oldStr.complete or oldStr.value ~= "" then -- 79
					goto __continue20 -- 80
				end -- 80
				return { -- 81
					target = target.value, -- 82
					receivedText = recovered.value, -- 83
					reason = ((("The response ended while overwriting " .. target.value) .. ". Write the ") .. tostring(#recovered.value)) .. " fully decoded characters directly to that file. This is the complete recoverable prefix; inspect the actual file next and decide whether it already suffices or needs a bounded continuation." -- 84
				} -- 84
			end -- 84
			::__continue20:: -- 84
			i = i - 1 -- 72
		end -- 72
	end -- 72
	return nil -- 87
end -- 68
ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 441
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 442
local ENGINE_LOG_VIRTUAL_FILE = "@dora_full_logs.txt" -- 443
local AGENT_DOWNLOAD_TEMP_DIR = "agent" -- 444
local function now() -- 445
	return os.time() -- 445
end -- 445
local function toBool(v) -- 447
	return v ~= 0 and v ~= false and v ~= nil -- 448
end -- 447
local function toStr(v) -- 451
	if v == false or v == nil then -- 451
		return "" -- 452
	end -- 452
	return tostring(v) -- 453
end -- 451
local function isAbsolutePathLike(path) -- 456
	if Content:isAbsolutePath(path) then -- 456
		return true -- 457
	end -- 457
	if __TS__StringStartsWith(path, "/") or __TS__StringStartsWith(path, "\\") then -- 457
		return true -- 458
	end -- 458
	local drivePath = string.match(path, "^%a:[/\\]") -- 459
	return drivePath ~= nil -- 460
end -- 456
local function isValidWorkspacePath(path) -- 463
	if not path or #path == 0 then -- 463
		return false -- 464
	end -- 464
	if isAbsolutePathLike(path) then -- 464
		return false -- 465
	end -- 465
	local parts = __TS__StringSplit( -- 466
		table.concat( -- 466
			__TS__StringSplit(path, "\\"), -- 466
			"/" -- 466
		), -- 466
		"/" -- 466
	) -- 466
	if __TS__ArrayIndexOf(parts, "..") >= 0 then -- 466
		return false -- 467
	end -- 467
	return true -- 468
end -- 463
local function isValidWorkDir(workDir) -- 471
	if not workDir or #workDir == 0 then -- 471
		return false -- 472
	end -- 472
	if not Content:isAbsolutePath(workDir) then -- 472
		return false -- 473
	end -- 473
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 473
		return false -- 474
	end -- 474
	return true -- 475
end -- 471
local function isValidSearchPath(path) -- 478
	if path == "" then -- 478
		return true -- 479
	end -- 479
	if isAbsolutePathLike(path) then -- 479
		return false -- 480
	end -- 480
	if not path or #path == 0 then -- 480
		return false -- 481
	end -- 481
	local parts = __TS__StringSplit( -- 482
		table.concat( -- 482
			__TS__StringSplit(path, "\\"), -- 482
			"/" -- 482
		), -- 482
		"/" -- 482
	) -- 482
	if __TS__ArrayIndexOf(parts, "..") >= 0 then -- 482
		return false -- 483
	end -- 483
	return true -- 484
end -- 478
local function resolveWorkspaceFilePath(workDir, path) -- 487
	if not isValidWorkDir(workDir) then -- 487
		return nil -- 488
	end -- 488
	if not isValidWorkspacePath(path) then -- 488
		return nil -- 489
	end -- 489
	return Path(workDir, path) -- 490
end -- 487
local function resolveWorkspaceSearchPath(workDir, path) -- 493
	if not isValidWorkDir(workDir) then -- 493
		return nil -- 494
	end -- 494
	if not isValidSearchPath(path) then -- 494
		return nil -- 495
	end -- 495
	return path == "" and workDir or Path(workDir, path) -- 496
end -- 493
local function toWorkspaceRelativePath(workDir, path) -- 499
	if not path or #path == 0 then -- 499
		return path -- 500
	end -- 500
	if not Content:isAbsolutePath(path) then -- 500
		return path -- 501
	end -- 501
	return Path:getRelative(path, workDir) -- 502
end -- 499
local function toWorkspaceRelativeFileList(workDir, files) -- 505
	return __TS__ArrayMap( -- 506
		files, -- 506
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 506
	) -- 506
end -- 505
local function toWorkspaceRelativeSearchResults(workDir, results) -- 509
	local mapped = {} -- 510
	do -- 510
		local i = 0 -- 511
		while i < #results do -- 511
			local row = results[i + 1] -- 512
			local clone = __TS__ObjectAssign({}, row) -- 513
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 514
			mapped[#mapped + 1] = clone -- 515
			i = i + 1 -- 511
		end -- 511
	end -- 511
	return mapped -- 517
end -- 509
local function resolveWorkspaceDirectoryPath(workDir, path) -- 520
	local relative = __TS__StringTrim(path or "") -- 521
	if relative == "" then -- 521
		return {success = true, path = workDir, relative = "."} -- 523
	end -- 523
	if not isValidWorkDir(workDir) or not isValidWorkspacePath(relative) then -- 523
		return {success = false, message = "invalid cwd path"} -- 526
	end -- 526
	local resolved = Path(workDir, relative) -- 528
	if not Content:exist(resolved) then -- 528
		return {success = false, message = "cwd does not exist"} -- 530
	end -- 530
	if not Content:isdir(resolved) then -- 530
		return {success = false, message = "cwd is not a directory"} -- 533
	end -- 533
	return {success = true, path = resolved, relative = relative} -- 535
end -- 520
local function getDoraDocDefinitionRoot(docLanguage) -- 538
	local zhDir = Path( -- 539
		Content.assetPath, -- 539
		"Script", -- 539
		"Lib", -- 539
		"Dora", -- 539
		"zh-Hans" -- 539
	) -- 539
	local enDir = Path( -- 540
		Content.assetPath, -- 540
		"Script", -- 540
		"Lib", -- 540
		"Dora", -- 540
		"en" -- 540
	) -- 540
	return docLanguage == "zh" and zhDir or enDir -- 541
end -- 538
local function getDoraTutorialDocRoot(docLanguage) -- 544
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 545
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 546
	return docLanguage == "zh" and zhDir or enDir -- 547
end -- 544
local function getDoraDocDefinitionExtsByCodeLanguage(programmingLanguage) -- 550
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 550
		return {"ts"} -- 552
	end -- 552
	return {"tl"} -- 554
end -- 550
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 557
	repeat -- 557
		local ____switch68 = programmingLanguage -- 557
		local ____cond68 = ____switch68 == "teal" -- 557
		if ____cond68 then -- 557
			return "tl" -- 559
		end -- 559
		____cond68 = ____cond68 or ____switch68 == "tl" -- 559
		if ____cond68 then -- 559
			return "tl" -- 560
		end -- 560
		do -- 560
			return programmingLanguage -- 561
		end -- 561
	until true -- 561
end -- 557
local function getDoraDocSearchTarget(docType, docLanguage, programmingLanguage) -- 565
	if docType == "dora-tutorial" then -- 565
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 571
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 572
		return { -- 573
			root = Path(tutorialRoot, langDir), -- 574
			exts = {"md"}, -- 575
			globs = {"**/*.md"} -- 576
		} -- 576
	end -- 576
	local exts = getDoraDocDefinitionExtsByCodeLanguage(programmingLanguage) -- 579
	if docType == "love-api" or docType == "tic80-api" then -- 579
		local name = docType == "love-api" and "love" or "tic80" -- 581
		return { -- 582
			root = getDoraDocDefinitionRoot(docLanguage), -- 583
			exts = exts, -- 584
			globs = __TS__ArrayMap( -- 585
				exts, -- 585
				function(____, ext) return (name .. ".d.") .. ext end -- 585
			) -- 585
		} -- 585
	end -- 585
	return { -- 588
		root = getDoraDocDefinitionRoot(docLanguage), -- 589
		exts = exts, -- 590
		globs = __TS__ArrayFlatMap( -- 591
			exts, -- 591
			function(____, ext) return {"**/*." .. ext, "!**/love.d." .. ext, "!**/tic80.d." .. ext} end -- 591
		) -- 591
	} -- 591
end -- 565
local function getDoraDocResultBaseRoot(docType, docLanguage) -- 599
	if docType == "dora-tutorial" then -- 599
		return getDoraTutorialDocRoot(docLanguage) -- 601
	end -- 601
	return getDoraDocDefinitionRoot(docLanguage) -- 603
end -- 599
local function isDoraDocFileInScope(docType, file) -- 606
	local normalized = string.lower(table.concat( -- 607
		__TS__StringSplit(file, "\\"), -- 607
		"/" -- 607
	)) -- 607
	local segments = __TS__StringSplit(normalized, "/") -- 608
	local baseName = segments[#segments] or normalized -- 609
	if docType == "dora-tutorial" then -- 609
		return __TS__StringEndsWith(normalized, ".md") -- 610
	end -- 610
	if docType == "love-api" then -- 610
		return normalized == "love.d.ts" or normalized == "love.d.tl" -- 611
	end -- 611
	if docType == "tic80-api" then -- 611
		return normalized == "tic80.d.ts" or normalized == "tic80.d.tl" -- 612
	end -- 612
	return (__TS__StringEndsWith(normalized, ".ts") or __TS__StringEndsWith(normalized, ".tl")) and baseName ~= "love.d.ts" and baseName ~= "love.d.tl" and baseName ~= "tic80.d.ts" and baseName ~= "tic80.d.tl" -- 613
end -- 606
local AGENT_DORA_DOC_PREFIX = "@dora-doc/" -- 620
local AGENT_SKILL_PREFIX = "@agent-skill/" -- 621
local function toDocRelativePath(baseRoot, path, docType) -- 623
	if not path or #path == 0 then -- 623
		return path -- 624
	end -- 624
	local relative = Content:isAbsolutePath(path) and Path:getRelative(path, baseRoot) or path -- 625
	return ((AGENT_DORA_DOC_PREFIX .. docType) .. "/") .. relative -- 626
end -- 623
local function resolveAgentDoraDocFilePath(path, docLanguage) -- 629
	if not docLanguage then -- 629
		return nil -- 630
	end -- 630
	local relative = path -- 631
	local docType = "dora-tutorial" -- 632
	if __TS__StringStartsWith(path, AGENT_DORA_DOC_PREFIX) then -- 632
		local namespaced = __TS__StringSlice(path, #AGENT_DORA_DOC_PREFIX) -- 634
		if __TS__StringStartsWith(namespaced, "dora-api/") then -- 634
			docType = "dora-api" -- 636
			relative = string.sub(namespaced, 10) -- 637
		elseif __TS__StringStartsWith(namespaced, "love-api/") then -- 637
			docType = "love-api" -- 639
			relative = string.sub(namespaced, 10) -- 640
		elseif __TS__StringStartsWith(namespaced, "tic80-api/") then -- 640
			docType = "tic80-api" -- 642
			relative = string.sub(namespaced, 11) -- 643
		elseif __TS__StringStartsWith(namespaced, "dora-tutorial/") then -- 643
			docType = "dora-tutorial" -- 645
			relative = string.sub(namespaced, 15) -- 646
		elseif __TS__StringStartsWith(namespaced, "api/") then -- 646
			docType = "dora-api" -- 648
			relative = string.sub(namespaced, 5) -- 649
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 649
			docType = "dora-tutorial" -- 651
			relative = string.sub(namespaced, 10) -- 652
		else -- 652
			return nil -- 654
		end -- 654
	end -- 654
	if not isValidWorkspacePath(relative) then -- 654
		return nil -- 657
	end -- 657
	if not isDoraDocFileInScope(docType, relative) then -- 657
		return nil -- 658
	end -- 658
	local root = getDoraDocResultBaseRoot(docType, docLanguage) -- 659
	local candidate = Path(root, relative) -- 660
	local checked = Path:getRelative(candidate, root) -- 661
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 661
		return nil -- 662
	end -- 662
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 662
		return candidate -- 664
	end -- 664
	return nil -- 666
end -- 629
local function resolveAgentSkillFilePath(workDir, path) -- 669
	if not __TS__StringStartsWith(path, AGENT_SKILL_PREFIX) then -- 669
		return nil -- 670
	end -- 670
	local namespaced = table.concat( -- 671
		__TS__StringSplit( -- 671
			__TS__StringSlice(path, #AGENT_SKILL_PREFIX), -- 671
			"\\" -- 671
		), -- 671
		"/" -- 671
	) -- 671
	local root = "" -- 672
	local relative = "" -- 673
	if __TS__StringStartsWith(namespaced, "builtin/") then -- 673
		root = Path(Content.assetPath, "Doc", "skills") -- 675
		relative = __TS__StringSlice(namespaced, #"builtin/") -- 676
	elseif __TS__StringStartsWith(namespaced, "user/") then -- 676
		root = Path(Content.writablePath, ".agent", "skills") -- 678
		relative = __TS__StringSlice(namespaced, #"user/") -- 679
	elseif __TS__StringStartsWith(namespaced, "project/") then -- 679
		root = Path(workDir, ".agent", "skills") -- 681
		relative = __TS__StringSlice(namespaced, #"project/") -- 682
	else -- 682
		return nil -- 684
	end -- 684
	if not isValidWorkspacePath(relative) or relative == "." then -- 684
		return nil -- 686
	end -- 686
	local candidate = Path(root, relative) -- 687
	local checked = Path:getRelative(candidate, root) -- 688
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 688
		return nil -- 689
	end -- 689
	if not Content:exist(candidate) or Content:isdir(candidate) then -- 689
		return nil -- 690
	end -- 690
	return candidate -- 691
end -- 669
local function ensureDirPath(dir) -- 694
	if not dir or dir == "." or dir == "" then -- 694
		return true -- 695
	end -- 695
	if Content:exist(dir) then -- 695
		return Content:isdir(dir) -- 696
	end -- 696
	local parent = Path:getPath(dir) -- 697
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 697
		if not ensureDirPath(parent) then -- 697
			return false -- 699
		end -- 699
	end -- 699
	return Content:mkdir(dir) -- 701
end -- 694
local function ensureDirForFile(path) -- 704
	local dir = Path:getPath(path) -- 705
	return ensureDirPath(dir) -- 706
end -- 704
local function isHttpUrl(url) -- 709
	local normalized = string.lower(__TS__StringTrim(url)) -- 710
	return __TS__StringStartsWith(normalized, "http://") or __TS__StringStartsWith(normalized, "https://") -- 711
end -- 709
local function getHttpUrlHost(url) -- 714
	local schemeEnd = (string.find(url, "://", nil, true) or 0) - 1 -- 715
	if schemeEnd < 0 then -- 715
		return nil -- 716
	end -- 716
	local authority = __TS__StringSlice(url, schemeEnd + 3) -- 717
	for ____, separator in ipairs({"/", "?", "#"}) do -- 718
		local index = (string.find(authority, separator, nil, true) or 0) - 1 -- 719
		if index >= 0 then -- 719
			authority = __TS__StringSlice(authority, 0, index) -- 720
		end -- 720
	end -- 720
	local at = -1 -- 722
	do -- 722
		local i = 0 -- 723
		while i < #authority do -- 723
			if __TS__StringCharAt(authority, i) == "@" then -- 723
				at = i -- 724
			end -- 724
			i = i + 1 -- 723
		end -- 723
	end -- 723
	if at >= 0 then -- 723
		authority = __TS__StringSlice(authority, at + 1) -- 726
	end -- 726
	if __TS__StringStartsWith(authority, "[") then -- 726
		local ____end = (string.find(authority, "]", nil, true) or 0) - 1 -- 728
		return ____end > 1 and string.lower(__TS__StringSlice(authority, 1, ____end)) or nil -- 729
	end -- 729
	local colon = -1 -- 731
	do -- 731
		local i = 0 -- 732
		while i < #authority do -- 732
			if __TS__StringCharAt(authority, i) == ":" then -- 732
				colon = i -- 733
			end -- 733
			i = i + 1 -- 732
		end -- 732
	end -- 732
	if colon >= 0 then -- 732
		authority = __TS__StringSlice(authority, 0, colon) -- 735
	end -- 735
	return authority ~= "" and string.lower(authority) or nil -- 736
end -- 714
local function isPrivateNetworkAddress(address) -- 739
	local normalized = string.lower(address) -- 740
	if __TS__StringIncludes(normalized, ":") then -- 740
		if normalized == "::" or normalized == "::1" then -- 740
			return true -- 742
		end -- 742
		if __TS__StringStartsWith(normalized, "fc") or __TS__StringStartsWith(normalized, "fd") then -- 742
			return true -- 743
		end -- 743
		if __TS__StringStartsWith(normalized, "fe8") or __TS__StringStartsWith(normalized, "fe9") or __TS__StringStartsWith(normalized, "fea") or __TS__StringStartsWith(normalized, "feb") then -- 743
			return true -- 744
		end -- 744
		local mappedPrefix = "::ffff:" -- 745
		if __TS__StringStartsWith(normalized, mappedPrefix) then -- 745
			return isPrivateNetworkAddress(__TS__StringSlice(normalized, #mappedPrefix)) -- 746
		end -- 746
		return false -- 747
	end -- 747
	local parts = __TS__StringSplit(normalized, ".") -- 749
	if #parts ~= 4 then -- 749
		return true -- 750
	end -- 750
	local octets = {} -- 751
	for ____, part in ipairs(parts) do -- 752
		local value = __TS__Number(part) -- 753
		if part == "" or value < 0 or value > 255 or math.floor(value) ~= value then -- 753
			return true -- 754
		end -- 754
		octets[#octets + 1] = value -- 755
	end -- 755
	local first = octets[1] -- 757
	local second = octets[2] -- 758
	if first == 0 or first == 10 or first == 127 then -- 758
		return true -- 759
	end -- 759
	if first == 100 and second >= 64 and second <= 127 then -- 759
		return true -- 760
	end -- 760
	if first == 169 and second == 254 then -- 760
		return true -- 761
	end -- 761
	if first == 172 and second >= 16 and second <= 31 then -- 761
		return true -- 762
	end -- 762
	if first == 192 and (second == 0 or second == 168) then -- 762
		return true -- 763
	end -- 763
	if first == 198 and (second == 18 or second == 19) then -- 763
		return true -- 764
	end -- 764
	if first >= 224 then -- 764
		return true -- 765
	end -- 765
	return false -- 766
end -- 739
local function isSafePublicHttpUrl(url) -- 769
	if not isHttpUrl(url) then -- 769
		return false -- 770
	end -- 770
	local host = getHttpUrlHost(url) -- 771
	if not host then -- 771
		return false -- 772
	end -- 772
	if host == "localhost" or __TS__StringEndsWith(host, ".localhost") or __TS__StringEndsWith(host, ".local") then -- 772
		return false -- 773
	end -- 773
	if host == "metadata.google.internal" or __TS__StringEndsWith(host, ".internal") then -- 773
		return false -- 774
	end -- 774
	if __TS__StringIncludes(host, ":") then -- 774
		return false -- 775
	end -- 775
	local numericHost = string.match(host, "^[%d%.]+$") -- 776
	if numericHost ~= nil then -- 776
		return false -- 777
	end -- 777
	local ipv4 = __TS__StringSplit(host, ".") -- 778
	if #ipv4 == 4 and __TS__ArrayEvery( -- 778
		ipv4, -- 779
		function(____, part) return part ~= "" and __TS__Number(part) >= 0 and __TS__Number(part) <= 255 end -- 779
	) then -- 779
		return false -- 780
	end -- 780
	local addresses = dns.getaddrinfo(host) -- 782
	if not addresses or #addresses == 0 then -- 782
		return false -- 783
	end -- 783
	for ____, address in ipairs(addresses) do -- 784
		if isPrivateNetworkAddress(address.addr) then -- 784
			return false -- 785
		end -- 785
	end -- 785
	return true -- 787
end -- 769
local function createOperationId() -- 790
	local raw = (tostring(os.time()) .. "-") .. tostring(math.floor(math.random() * 1000000000)) -- 791
	local safe = string.gsub(raw, "[^%w%-_]", "-") -- 792
	return safe -- 793
end -- 790
local function getAgentDownloadTempRoot() -- 796
	return Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR, AGENT_DOWNLOAD_TEMP_DIR) -- 797
end -- 796
local function cleanupPath(path) -- 800
	if not path or path == "" or not Content:exist(path) then -- 800
		return nil -- 801
	end -- 801
	if Content:remove(path) then -- 801
		return nil -- 802
	end -- 802
	return "failed to remove temporary path: " .. path -- 803
end -- 800
local function quoteGitArg(value) -- 806
	local plain = string.match(value, "^[%w%._%-%/]+$") -- 807
	if plain ~= nil then -- 807
		return value -- 809
	end -- 809
	local escaped = string.gsub(value, "\\", "\\\\") -- 811
	escaped = string.gsub(escaped, "\"", "\\\"") -- 812
	return ("\"" .. escaped) .. "\"" -- 813
end -- 806
local function shellSplit(command) -- 816
	local args = {} -- 817
	local current = "" -- 818
	local quote = "" -- 819
	local escaped = false -- 820
	do -- 820
		local i = 0 -- 821
		while i < #command do -- 821
			do -- 821
				local ch = __TS__StringCharAt(command, i) -- 822
				if escaped then -- 822
					current = current .. ch -- 824
					escaped = false -- 825
					goto __continue165 -- 826
				end -- 826
				if ch == "\\" then -- 826
					escaped = true -- 829
					goto __continue165 -- 830
				end -- 830
				if quote ~= "" then -- 830
					if ch == quote then -- 830
						quote = "" -- 834
					else -- 834
						current = current .. ch -- 836
					end -- 836
					goto __continue165 -- 838
				end -- 838
				if ch == "'" or ch == "\"" then -- 838
					quote = ch -- 841
					goto __continue165 -- 842
				end -- 842
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 842
					if current ~= "" then -- 842
						args[#args + 1] = current -- 846
						current = "" -- 847
					end -- 847
					goto __continue165 -- 849
				end -- 849
				current = current .. ch -- 851
			end -- 851
			::__continue165:: -- 851
			i = i + 1 -- 821
		end -- 821
	end -- 821
	if escaped then -- 821
		current = current .. "\\" -- 854
	end -- 854
	if current ~= "" then -- 854
		args[#args + 1] = current -- 857
	end -- 857
	return args -- 859
end -- 816
local function normalizeGitCommand(command) -- 862
	local trimmed = __TS__StringTrim(command) -- 863
	return string.lower(string.sub(trimmed, 1, 4)) == "git " and __TS__StringTrim(string.sub(trimmed, 5)) or trimmed -- 864
end -- 862
local function gitDefaultTargetFromUrl(url) -- 869
	local target = url -- 870
	local hashIndex = (string.find(target, "#", nil, true) or 0) - 1 -- 871
	if hashIndex >= 0 then -- 871
		target = __TS__StringSlice(target, 0, hashIndex) -- 872
	end -- 872
	local queryIndex = (string.find(target, "?", nil, true) or 0) - 1 -- 873
	if queryIndex >= 0 then -- 873
		target = __TS__StringSlice(target, 0, queryIndex) -- 874
	end -- 874
	target = string.gsub(target, "/+$", "") -- 875
	local name = string.match(target, "([^/]+)$") -- 876
	if name ~= nil and name ~= "" then -- 876
		target = name -- 877
	end -- 877
	if __TS__StringEndsWith( -- 877
		string.lower(target), -- 878
		".git" -- 878
	) then -- 878
		target = __TS__StringSlice(target, 0, #target - 4) -- 879
	end -- 879
	return target ~= "" and target or "repo" -- 881
end -- 869
local function parseGitCloneCommand(command) -- 884
	local args = shellSplit(normalizeGitCommand(command)) -- 894
	if #args == 0 or args[1] ~= "clone" then -- 894
		return nil -- 895
	end -- 895
	local url = "" -- 896
	local target = "" -- 897
	local ref -- 898
	local depth -- 899
	do -- 899
		local i = 1 -- 900
		while i < #args do -- 900
			do -- 900
				local arg = args[i + 1] -- 901
				if arg == "-b" or arg == "--branch" then
					i = i + 1 -- 903
					if i >= #args then -- 903
						return {success = false, message = arg .. " requires a value"} -- 904
					end -- 904
					ref = args[i + 1] -- 905
					goto __continue185 -- 906
				end -- 906
				if arg == "--depth" then
					i = i + 1 -- 909
					if i >= #args then -- 909
						return {success = false, message = "--depth requires a value"}
					end -- 910
					depth = args[i + 1] -- 911
					goto __continue185 -- 912
				end -- 912
				if __TS__StringStartsWith(arg, "--depth=") then
					depth = __TS__StringSlice(arg, #"--depth=")
					goto __continue185 -- 916
				end -- 916
				if __TS__StringStartsWith(arg, "-") then -- 916
					return {success = false, message = "unsupported clone option: " .. arg} -- 919
				end -- 919
				if url == "" then -- 919
					url = arg -- 922
					goto __continue185 -- 923
				end -- 923
				if target == "" then -- 923
					target = arg -- 926
					goto __continue185 -- 927
				end -- 927
				return {success = false, message = "unexpected clone argument: " .. arg} -- 929
			end -- 929
			::__continue185:: -- 929
			i = i + 1 -- 900
		end -- 900
	end -- 900
	if url == "" then -- 900
		return {success = false, message = "git clone requires a URL"} -- 931
	end -- 931
	if not isHttpUrl(url) then -- 931
		return {success = false, message = "git clone only supports http:// and https:// URLs"} -- 932
	end -- 932
	if not isSafePublicHttpUrl(url) then -- 932
		return {success = false, message = "git clone rejects local, private, metadata, and literal-IP destinations"} -- 933
	end -- 933
	if target == "" then -- 933
		target = gitDefaultTargetFromUrl(url) -- 934
	end -- 934
	return { -- 935
		success = true, -- 936
		url = url, -- 937
		target = target, -- 938
		ref = ref, -- 939
		depth = depth ~= nil and depth ~= "" and depth or "1" -- 940
	} -- 940
end -- 884
local function getGitHeadCommit(repoPath) -- 944
	local headPath = Path(repoPath, ".git", "HEAD") -- 945
	if not Content:exist(headPath) then -- 945
		return nil -- 946
	end -- 946
	local head = __TS__StringTrim(toStr(Content:load(headPath))) -- 947
	local ref = string.match(head, "^ref:%s*(.-)%s*$") -- 948
	if ref ~= nil and ref ~= "" then -- 948
		local refPath = Path(repoPath, ".git", ref) -- 950
		if Content:exist(refPath) then -- 950
			local commit = __TS__StringTrim(toStr(Content:load(refPath))) -- 952
			return commit ~= "" and commit or nil -- 953
		end -- 953
		return nil -- 955
	end -- 955
	return head ~= "" and head or nil -- 957
end -- 944
local function runGitAndWait(repoPath, command, onStatus, isCancelled, timeout) -- 960
	if timeout == nil then -- 960
		timeout = 600 -- 965
	end -- 965
	return __TS__New( -- 967
		__TS__Promise, -- 967
		function(____, resolve) -- 967
			local status -- 968
			local jobId = 0 -- 969
			local settled = false -- 970
			local canceled = false -- 971
			local function finish(result) -- 972
				if settled then -- 972
					return -- 973
				end -- 973
				settled = true -- 974
				resolve(nil, result) -- 975
			end -- 972
			local function finishFromStatus() -- 977
				local state = toStr(status and status.state) -- 978
				if state == "done" then -- 978
					finish({success = true, status = status}) -- 980
					return true -- 981
				end -- 981
				if state == "error" or state == "canceled" then -- 981
					local errorMessage = toStr(status and status.error) -- 984
					local statusMessage = toStr(status and status.message) -- 985
					finish({success = false, message = errorMessage ~= "" and errorMessage or (statusMessage ~= "" and statusMessage or (state == "canceled" and "git command canceled" or "git command failed")), status = status, interrupted = state == "canceled"}) -- 986
					return true -- 992
				end -- 992
				return false -- 994
			end -- 977
			jobId = Git:run( -- 996
				repoPath, -- 996
				command, -- 996
				function(nextStatus) -- 996
					status = nextStatus -- 997
					if onStatus then -- 997
						onStatus(status) -- 998
					end -- 998
					return finishFromStatus() -- 999
				end, -- 996
				"" -- 1000
			) -- 1000
			if jobId == nil or jobId <= 0 then -- 1000
				finish({success = false, message = "failed to start git command"}) -- 1002
				return -- 1003
			end -- 1003
			if not status then -- 1003
				local kind = string.match(command, "^(%S+)") -- 1006
				status = { -- 1007
					id = jobId, -- 1008
					state = "queued", -- 1009
					kind = toStr(kind), -- 1010
					repoPath = repoPath, -- 1011
					progress = 0, -- 1012
					message = "queued" -- 1013
				} -- 1013
			end -- 1013
			if onStatus then -- 1013
				onStatus(status) -- 1016
			end -- 1016
			local startedAt = os.time() -- 1017
			local lastEmitAt = startedAt -- 1018
			Director.systemScheduler:schedule(function() -- 1019
				if settled then -- 1019
					return true -- 1020
				end -- 1020
				if not canceled and isCancelled and isCancelled() then -- 1020
					canceled = true -- 1022
					Git:cancel(jobId) -- 1023
					finish({success = false, message = "git command canceled", status = status, interrupted = true}) -- 1024
					return true -- 1025
				end -- 1025
				if finishFromStatus() then -- 1025
					return true -- 1027
				end -- 1027
				local nowTime = os.time() -- 1028
				if nowTime - startedAt >= timeout then -- 1028
					Git:cancel(jobId) -- 1030
					finish({success = false, message = "git command timed out", status = status}) -- 1031
					return true -- 1032
				end -- 1032
				if onStatus and status and nowTime > lastEmitAt then -- 1032
					lastEmitAt = nowTime -- 1035
					onStatus(status) -- 1036
				end -- 1036
				return false -- 1038
			end) -- 1019
		end -- 967
	) -- 967
end -- 960
local function downloadFile(req) -- 1043
	return __TS__New( -- 1050
		__TS__Promise, -- 1050
		function(____, resolve) -- 1050
			local requestId = 0 -- 1051
			local settled = false -- 1052
			local bytesWritten = 0 -- 1053
			local function finish(result) -- 1054
				if settled then -- 1054
					return -- 1055
				end -- 1055
				settled = true -- 1056
				requestId = 0 -- 1057
				resolve(nil, result) -- 1058
			end -- 1054
			Director.systemScheduler:schedule(function() -- 1060
				if settled then -- 1060
					return true -- 1061
				end -- 1061
				local ____this_9 -- 1061
				____this_9 = req -- 1062
				local ____opt_8 = ____this_9.isCancelled -- 1062
				if (____opt_8 and ____opt_8(____this_9)) == true and requestId ~= 0 then -- 1062
					HttpClient:cancel(requestId) -- 1063
					finish({success = false, interrupted = true, message = "download canceled"}) -- 1064
					return true -- 1065
				end -- 1065
				if requestId ~= 0 and not HttpClient:isRequestActive(requestId) then -- 1065
					finish({success = false, message = "download request ended without a completion callback"}) -- 1068
					return true -- 1069
				end -- 1069
				return false -- 1071
			end) -- 1060
			Director.systemScheduler:schedule(once(function() -- 1073
				requestId = HttpClient:download( -- 1074
					req.url, -- 1074
					req.tempPath, -- 1074
					req.timeout, -- 1074
					function(interrupted, current, total) -- 1074
						if type(current) == "number" and current > bytesWritten then -- 1074
							bytesWritten = current -- 1076
						end -- 1076
						if interrupted then -- 1076
							finish({success = false, interrupted = true, message = "download failed"}) -- 1079
							return true -- 1080
						end -- 1080
						local ____this_11 -- 1080
						____this_11 = req -- 1082
						local ____opt_10 = ____this_11.isCancelled -- 1082
						if (____opt_10 and ____opt_10(____this_11)) == true then -- 1082
							finish({success = false, interrupted = true, message = "download canceled"}) -- 1083
							return true -- 1084
						end -- 1084
						if current == total then -- 1084
							finish({success = true, bytesWritten = bytesWritten}) -- 1087
							return false -- 1088
						end -- 1088
						req:onProgress(current, total) -- 1090
						return false -- 1091
					end -- 1074
				) -- 1074
				if requestId == 0 then -- 1074
					finish({success = false, message = "failed to schedule download request"}) -- 1094
				else -- 1094
					local ____this_13 -- 1094
					____this_13 = req -- 1095
					local ____opt_12 = ____this_13.isCancelled -- 1095
					if (____opt_12 and ____opt_12(____this_13)) == true then -- 1095
						HttpClient:cancel(requestId) -- 1096
						finish({success = false, interrupted = true, message = "download canceled"}) -- 1097
					end -- 1097
				end -- 1097
			end)) -- 1073
		end -- 1050
	) -- 1050
end -- 1043
local function getFileState(path) -- 1103
	local exists = Content:exist(path) -- 1104
	if not exists then -- 1104
		return {exists = false, content = "", bytes = 0} -- 1106
	end -- 1106
	if Content:isdir(path) then -- 1106
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 1113
	end -- 1113
	local content = Content:load(path) -- 1120
	if type(content) ~= "string" then -- 1120
		return {exists = true, content = "", bytes = 0} -- 1122
	end -- 1122
	return {exists = true, content = content, bytes = #content} -- 1128
end -- 1103
local function inspectReadableFile(path) -- 1135
	do -- 1135
		local function ____catch(e) -- 1135
			Log( -- 1157
				"Warn", -- 1157
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 1157
			) -- 1157
			return true, {success = true} -- 1158
		end -- 1158
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1158
			local size, isBinary = Content:getAttr(path) -- 1137
			if size == nil then -- 1137
				return true, {success = false, message = "failed to read file"} -- 1139
			end -- 1139
			if isBinary then -- 1139
				return true, { -- 1145
					success = false, -- 1146
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 1147
					size = type(size) == "number" and size or nil, -- 1148
					isBinary = true -- 1149
				} -- 1149
			end -- 1149
			return true, { -- 1152
				success = true, -- 1153
				size = type(size) == "number" and size or nil -- 1154
			} -- 1154
		end) -- 1154
		if not ____try then -- 1154
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1154
		end -- 1154
		if ____hasReturned then -- 1154
			return ____returnValue -- 1136
		end -- 1136
	end -- 1136
end -- 1135
local function isEngineLogFilePath(path) -- 1162
	return path == ENGINE_LOG_VIRTUAL_FILE -- 1163
end -- 1162
local function readEngineLogFile(path) -- 1166
	if not isEngineLogFilePath(path) then -- 1166
		return nil -- 1167
	end -- 1167
	local content = getEngineLogText() -- 1168
	if content == nil then -- 1168
		return {success = false, message = "failed to read engine logs"} -- 1170
	end -- 1170
	return {success = true, content = content, size = #content} -- 1172
end -- 1166
local function queryOne(sql, args) -- 1175
	local ____args_14 -- 1176
	if args then -- 1176
		____args_14 = DB:query(sql, args) -- 1176
	else -- 1176
		____args_14 = DB:query(sql) -- 1176
	end -- 1176
	local rows = ____args_14 -- 1176
	if not rows or #rows == 0 then -- 1176
		return nil -- 1177
	end -- 1177
	return rows[1] -- 1178
end -- 1175
local function isDtsFile(path) -- 1181
	return Path:getExt(Path:getName(path)) == "d" -- 1182
end -- 1181
local function isTiledEditorContent(content) -- 1185
	return __TS__StringStartsWith( -- 1186
		__TS__StringTrim(content), -- 1186
		"<?xml" -- 1186
	) -- 1186
end -- 1185
local function getSupportedBuildKind(path) -- 1191
	repeat -- 1191
		local ____switch254 = Path:getExt(path) -- 1191
		local ____cond254 = ____switch254 == "ts" or ____switch254 == "tsx" -- 1191
		if ____cond254 then -- 1191
			return "ts" -- 1193
		end -- 1193
		____cond254 = ____cond254 or ____switch254 == "xml" -- 1193
		if ____cond254 then -- 1193
			return "xml" -- 1194
		end -- 1194
		____cond254 = ____cond254 or ____switch254 == "tl" -- 1194
		if ____cond254 then -- 1194
			return "teal" -- 1195
		end -- 1195
		____cond254 = ____cond254 or ____switch254 == "lua" -- 1195
		if ____cond254 then -- 1195
			return "lua" -- 1196
		end -- 1196
		____cond254 = ____cond254 or ____switch254 == "yue" -- 1196
		if ____cond254 then -- 1196
			return "yue" -- 1197
		end -- 1197
		____cond254 = ____cond254 or ____switch254 == "yarn" -- 1197
		if ____cond254 then -- 1197
			return "yarn" -- 1198
		end -- 1198
		do -- 1198
			return nil -- 1199
		end -- 1199
	until true -- 1199
end -- 1191
local function getTaskHeadSeq(taskId) -- 1203
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1204
	if not row then -- 1204
		return nil -- 1205
	end -- 1205
	return row[1] or 0 -- 1206
end -- 1203
local function getTaskStatus(taskId) -- 1209
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1210
	if not row then -- 1210
		return nil -- 1211
	end -- 1211
	return toStr(row[1]) -- 1212
end -- 1209
local function getLastInsertRowId() -- 1215
	local row = queryOne("SELECT last_insert_rowid()") -- 1216
	return row and (row[1] or 0) or 0 -- 1217
end -- 1215
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 1220
	DB:exec( -- 1221
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 1221
		{ -- 1223
			taskId, -- 1223
			seq, -- 1223
			status, -- 1223
			summary, -- 1223
			toolName, -- 1223
			now() -- 1223
		} -- 1223
	) -- 1223
	return getLastInsertRowId() -- 1225
end -- 1220
local function getCheckpointEntries(checkpointId, desc) -- 1228
	if desc == nil then -- 1228
		desc = false -- 1228
	end -- 1228
	local rows = DB:query((("SELECT id, ord, path, op, before_exists,\n\t\t\tdora_decompress_text(before_data),\n\t\t\tafter_exists,\n\t\t\tdora_decompress_text(after_data)\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 1229
	if not rows then -- 1229
		return {} -- 1239
	end -- 1239
	local result = {} -- 1240
	do -- 1240
		local i = 0 -- 1241
		while i < #rows do -- 1241
			local row = rows[i + 1] -- 1242
			result[#result + 1] = { -- 1243
				id = row[1], -- 1244
				ord = row[2], -- 1245
				path = toStr(row[3]), -- 1246
				op = toStr(row[4]), -- 1247
				beforeExists = toBool(row[5]), -- 1248
				beforeContent = toStr(row[6]), -- 1249
				afterExists = toBool(row[7]), -- 1250
				afterContent = toStr(row[8]) -- 1251
			} -- 1251
			i = i + 1 -- 1241
		end -- 1241
	end -- 1241
	return result -- 1254
end -- 1228
local function getCheckpointEntryMetadata(checkpointId, desc) -- 1257
	if desc == nil then -- 1257
		desc = false -- 1257
	end -- 1257
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, after_exists, bytes_before, bytes_after\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 1258
	if not rows then -- 1258
		return {} -- 1265
	end -- 1265
	local result = {} -- 1266
	do -- 1266
		local i = 0 -- 1267
		while i < #rows do -- 1267
			local row = rows[i + 1] -- 1268
			result[#result + 1] = { -- 1269
				id = row[1], -- 1270
				ord = row[2], -- 1271
				path = toStr(row[3]), -- 1272
				op = toStr(row[4]), -- 1273
				beforeExists = toBool(row[5]), -- 1274
				afterExists = toBool(row[6]), -- 1275
				bytesBefore = row[7] or 0, -- 1276
				bytesAfter = row[8] or 0 -- 1277
			} -- 1277
			i = i + 1 -- 1267
		end -- 1267
	end -- 1267
	return result -- 1280
end -- 1257
local function rejectDuplicatePaths(changes) -- 1283
	local seen = __TS__New(Set) -- 1284
	for ____, change in ipairs(changes) do -- 1285
		local key = change.path -- 1286
		if seen:has(key) then -- 1286
			return key -- 1287
		end -- 1287
		seen:add(key) -- 1288
	end -- 1288
	return nil -- 1290
end -- 1283
local function getLinkedDeletePaths(workDir, path) -- 1293
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1294
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 1294
		return {} -- 1295
	end -- 1295
	local parent = Path:getPath(fullPath) -- 1296
	local baseName = string.lower(Path:getName(fullPath)) -- 1297
	local ext = Path:getExt(fullPath) -- 1298
	local linked = {} -- 1299
	for ____, file in ipairs(Content:getFiles(parent)) do -- 1300
		do -- 1300
			if string.lower(Path:getName(file)) ~= baseName then -- 1300
				goto __continue275 -- 1301
			end -- 1301
			local siblingExt = Path:getExt(file) -- 1302
			if siblingExt == "tl" and ext == "vs" then -- 1302
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1304
					workDir, -- 1304
					Path(parent, file) -- 1304
				) -- 1304
				goto __continue275 -- 1305
			end -- 1305
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 1305
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1308
					workDir, -- 1308
					Path(parent, file) -- 1308
				) -- 1308
			end -- 1308
		end -- 1308
		::__continue275:: -- 1308
	end -- 1308
	return linked -- 1311
end -- 1293
local function expandLinkedDeleteChanges(workDir, changes) -- 1314
	local expanded = {} -- 1315
	local seen = __TS__New(Set) -- 1316
	do -- 1316
		local i = 0 -- 1317
		while i < #changes do -- 1317
			do -- 1317
				local change = changes[i + 1] -- 1318
				if not seen:has(change.path) then -- 1318
					seen:add(change.path) -- 1320
					expanded[#expanded + 1] = change -- 1321
				end -- 1321
				if change.op ~= "delete" then -- 1321
					goto __continue282 -- 1323
				end -- 1323
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 1324
				do -- 1324
					local j = 0 -- 1325
					while j < #linkedPaths do -- 1325
						do -- 1325
							local linkedPath = linkedPaths[j + 1] -- 1326
							if seen:has(linkedPath) then -- 1326
								goto __continue286 -- 1327
							end -- 1327
							seen:add(linkedPath) -- 1328
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 1329
						end -- 1329
						::__continue286:: -- 1329
						j = j + 1 -- 1325
					end -- 1325
				end -- 1325
			end -- 1325
			::__continue282:: -- 1325
			i = i + 1 -- 1317
		end -- 1317
	end -- 1317
	return expanded -- 1332
end -- 1314
local function applySingleFile(path, exists, content) -- 1335
	if exists then -- 1335
		if not ensureDirForFile(path) then -- 1335
			return false -- 1337
		end -- 1337
		return Content:save(path, content) -- 1338
	end -- 1338
	if Content:exist(path) then -- 1338
		return Content:remove(path) -- 1341
	end -- 1341
	return true -- 1343
end -- 1335
local function rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 1346
	local entries = getCheckpointEntries(checkpointId, true) -- 1351
	local remaining = appliedCount -- 1352
	local failures = {} -- 1353
	do -- 1353
		local i = 0 -- 1354
		while i < #entries and remaining > 0 do -- 1354
			do -- 1354
				local entry = entries[i + 1] -- 1355
				if entry.ord > appliedCount then -- 1355
					goto __continue294 -- 1356
				end -- 1356
				local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1357
				if not fullPath or not applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) then -- 1357
					failures[#failures + 1] = entry.path -- 1359
				else -- 1359
					____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) -- 1361
				end -- 1361
				remaining = remaining - 1 -- 1363
			end -- 1363
			::__continue294:: -- 1363
			i = i + 1 -- 1354
		end -- 1354
	end -- 1354
	return #failures > 0 and "rollback failed for: " .. table.concat(failures, ", ") or nil -- 1365
end -- 1346
function ____exports.sendWebIDERefreshTree() -- 1385
	if HttpServer.wsConnectionCount == 0 then -- 1385
		return true -- 1387
	end -- 1387
	local payload = encodeJSON({name = "RefreshTree"}) -- 1389
	if not payload then -- 1389
		return false -- 1391
	end -- 1391
	emit("AppWS", "Send", payload) -- 1393
	return true -- 1394
end -- 1385
local function syncProjectFileToWebIDE(workDir, path) -- 1397
	local target = resolveWorkspaceFilePath(workDir, path) -- 1398
	if not target then -- 1398
		return false -- 1399
	end -- 1399
	if not Content:exist(target) then -- 1399
		return ____exports.sendWebIDEFileUpdate(target, false, "") -- 1401
	end -- 1401
	if Content:isdir(target) then -- 1401
		return ____exports.sendWebIDERefreshTree() -- 1404
	end -- 1404
	local content = "" -- 1406
	do -- 1406
		local function ____catch(e) -- 1406
			Log( -- 1414
				"Warn", -- 1414
				(("[Agent.Tools] failed to inspect file for Web IDE update file=" .. target) .. ": ") .. tostring(e) -- 1414
			) -- 1414
		end -- 1414
		local ____try, ____hasReturned = pcall(function() -- 1414
			local ____, isBinary = Content:getAttr(target) -- 1408
			if not isBinary then -- 1408
				local loaded = Content:load(target) -- 1410
				content = type(loaded) == "string" and loaded or "" -- 1411
			end -- 1411
		end) -- 1411
		if not ____try then -- 1411
			____catch(____hasReturned) -- 1411
		end -- 1411
	end -- 1411
	return ____exports.sendWebIDEFileUpdate(target, true, content) -- 1416
end -- 1397
local function refreshProjectTree(workDir, path) -- 1419
	local normalized = type(path) == "string" and __TS__StringTrim(path) or "" -- 1420
	if normalized == "" then -- 1420
		return ____exports.sendWebIDERefreshTree() -- 1422
	end -- 1422
	return syncProjectFileToWebIDE(workDir, normalized) -- 1424
end -- 1419
local function syncDownloadedFileToWebIDE(file) -- 1427
	local content = "" -- 1428
	do -- 1428
		local function ____catch(e) -- 1428
			Log( -- 1436
				"Warn", -- 1436
				(("[fetch_url] failed to inspect downloaded file for Web IDE update file=" .. file) .. ": ") .. tostring(e) -- 1436
			) -- 1436
		end -- 1436
		local ____try, ____hasReturned = pcall(function() -- 1436
			local ____, isBinary = Content:getAttr(file) -- 1430
			if not isBinary then -- 1430
				local loaded = Content:load(file) -- 1432
				content = type(loaded) == "string" and loaded or "" -- 1433
			end -- 1433
		end) -- 1433
		if not ____try then -- 1433
			____catch(____hasReturned) -- 1433
		end -- 1433
	end -- 1433
	return ____exports.sendWebIDEFileUpdate(file, true, content) -- 1438
end -- 1427
local function runSingleNonTsBuild(file) -- 1441
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1441
		return ____awaiter_resolve( -- 1441
			nil, -- 1441
			__TS__New( -- 1442
				__TS__Promise, -- 1442
				function(____, resolve) -- 1442
					local moduleName = "Script.Dev.WebServer" -- 1443
					local ____require_result_15 = require(moduleName) -- 1444
					local buildAsync = ____require_result_15.buildAsync -- 1444
					Director.systemScheduler:schedule(once(function() -- 1445
						local result = buildAsync(file) -- 1446
						resolve(nil, result) -- 1447
					end)) -- 1445
				end -- 1442
			) -- 1442
		) -- 1442
	end) -- 1442
end -- 1441
local transpileRequestSeq = 0 -- 1452
local TRANSPILE_READY_TIMEOUT_SECONDS = 5 -- 1453
local TRANSPILE_BUILD_TIMEOUT_SECONDS = 30 -- 1454
function ____exports.runSingleTsTranspile(file, content, projectRoot, isCancelled) -- 1456
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1456
		local done = false -- 1462
		local ready = false -- 1463
		transpileRequestSeq = transpileRequestSeq + 1 -- 1464
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 1465
		local result = {success = false, file = file, message = "Web IDE not connected"} -- 1466
		if HttpServer.wsConnectionCount == 0 then -- 1466
			return ____awaiter_resolve(nil, result) -- 1466
		end -- 1466
		local listener = Node() -- 1474
		listener:gslot( -- 1475
			"AppWS", -- 1475
			function(event) -- 1475
				if event.type ~= "Receive" then -- 1475
					return -- 1476
				end -- 1476
				local res = safeJsonDecode(event.msg) -- 1477
				if not res or __TS__ArrayIsArray(res) then -- 1477
					return -- 1478
				end -- 1478
				local payload = res -- 1479
				if payload.id ~= requestId then -- 1479
					return -- 1480
				end -- 1480
				if payload.name == "TranspileTSProbe" then -- 1480
					ready = true -- 1482
					return -- 1483
				end -- 1483
				if payload.name ~= "TranspileTS" then -- 1483
					return -- 1485
				end -- 1485
				if payload.success then -- 1485
					local luaFile = Path:replaceExt(file, "lua") -- 1487
					if Content:save( -- 1487
						luaFile, -- 1488
						tostring(payload.luaCode) -- 1488
					) then -- 1488
						result = {success = true, file = file} -- 1489
					else -- 1489
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 1491
					end -- 1491
				else -- 1491
					result = { -- 1494
						success = false, -- 1494
						file = file, -- 1494
						message = tostring(payload.message) -- 1494
					} -- 1494
				end -- 1494
				done = true -- 1496
			end -- 1475
		) -- 1475
		local probePayload = encodeJSON({name = "TranspileTSProbe", id = requestId}) -- 1498
		local buildPayload = encodeJSON({ -- 1499
			name = "TranspileTS", -- 1500
			id = requestId, -- 1501
			file = file, -- 1502
			content = content, -- 1503
			projectRoot = projectRoot -- 1504
		}) -- 1504
		if not probePayload or not buildPayload then -- 1504
			listener:removeFromParent() -- 1507
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 1507
		end -- 1507
		__TS__Await(__TS__New( -- 1510
			__TS__Promise, -- 1510
			function(____, resolve) -- 1510
				Director.systemScheduler:schedule(once(function() -- 1511
					emit("AppWS", "Send", probePayload) -- 1512
					local readyDeadline = App.runningTime + TRANSPILE_READY_TIMEOUT_SECONDS -- 1513
					wait(function() return ready or HttpServer.wsConnectionCount == 0 or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) == true end) -- 1514
					if not ready then -- 1514
						listener:removeFromParent() -- 1519
						if (isCancelled and isCancelled()) == true then -- 1519
							result = {success = false, file = file, message = "build canceled", interrupted = true} -- 1521
						elseif HttpServer.wsConnectionCount == 0 then -- 1521
							result = {success = false, file = file, message = "Web IDE disconnected"} -- 1523
						else -- 1523
							result = {success = false, file = file, message = "TypeScript transpiler is not ready"} -- 1525
						end -- 1525
						resolve(nil) -- 1527
						return -- 1528
					end -- 1528
					emit("AppWS", "Send", buildPayload) -- 1530
					local buildDeadline = App.runningTime + TRANSPILE_BUILD_TIMEOUT_SECONDS -- 1531
					wait(function() return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= buildDeadline or (isCancelled and isCancelled()) == true end) -- 1532
					if not done then -- 1532
						listener:removeFromParent() -- 1537
						if (isCancelled and isCancelled()) == true then -- 1537
							result = {success = false, file = file, message = "build canceled", interrupted = true} -- 1539
						elseif HttpServer.wsConnectionCount == 0 then -- 1539
							result = {success = false, file = file, message = "Web IDE disconnected"} -- 1541
						else -- 1541
							result = {success = false, file = file, message = "TypeScript transpile timed out"} -- 1543
						end -- 1543
					end -- 1543
					resolve(nil) -- 1546
				end)) -- 1511
			end -- 1510
		)) -- 1510
		return ____awaiter_resolve(nil, result) -- 1510
	end) -- 1510
end -- 1456
function ____exports.createTask(prompt, workMode) -- 1552
	if prompt == nil then -- 1552
		prompt = "" -- 1552
	end -- 1552
	if workMode == nil then -- 1552
		workMode = "code" -- 1552
	end -- 1552
	local storage = requireAgentStorage() -- 1553
	if not storage.success then -- 1553
		return storage -- 1554
	end -- 1554
	local t = now() -- 1555
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, work_mode, created_at, updated_at) VALUES(?, ?, 0, ?, ?, ?)", { -- 1556
		"RUNNING", -- 1558
		prompt, -- 1558
		workMode, -- 1558
		t, -- 1558
		t -- 1558
	}) -- 1558
	if affected <= 0 then -- 1558
		return {success = false, message = "failed to create task"} -- 1561
	end -- 1561
	return { -- 1563
		success = true, -- 1563
		taskId = getLastInsertRowId() -- 1563
	} -- 1563
end -- 1552
function ____exports.setTaskStatus(taskId, status) -- 1566
	DB:exec( -- 1567
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 1567
		{ -- 1567
			status, -- 1567
			now(), -- 1567
			taskId -- 1567
		} -- 1567
	) -- 1567
	Log( -- 1568
		"Info", -- 1568
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 1568
	) -- 1568
end -- 1566
function ____exports.listCheckpointsForTasks(taskIds) -- 1571
	local normalizedTaskIds = {} -- 1572
	local seenTaskIds = {} -- 1573
	do -- 1573
		local i = 0 -- 1574
		while i < #taskIds do -- 1574
			do -- 1574
				local taskId = math.floor(taskIds[i + 1]) -- 1575
				if taskId <= 0 or seenTaskIds[taskId] then -- 1575
					goto __continue352 -- 1576
				end -- 1576
				seenTaskIds[taskId] = true -- 1577
				normalizedTaskIds[#normalizedTaskIds + 1] = taskId -- 1578
			end -- 1578
			::__continue352:: -- 1578
			i = i + 1 -- 1574
		end -- 1574
	end -- 1574
	if #normalizedTaskIds == 0 then -- 1574
		return {} -- 1580
	end -- 1580
	local placeholders = table.concat( -- 1581
		__TS__ArrayMap( -- 1581
			normalizedTaskIds, -- 1581
			function() return "?" end -- 1581
		), -- 1581
		", " -- 1581
	) -- 1581
	local rows = DB:query(((("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id IN (") .. placeholders) .. ")\n\t\tORDER BY task_id DESC, seq DESC", normalizedTaskIds) -- 1582
	if not rows then -- 1582
		return {} -- 1589
	end -- 1589
	local items = {} -- 1590
	do -- 1590
		local i = 0 -- 1591
		while i < #rows do -- 1591
			local row = rows[i + 1] -- 1592
			items[#items + 1] = { -- 1593
				id = row[1], -- 1594
				taskId = row[2], -- 1595
				seq = row[3], -- 1596
				status = toStr(row[4]), -- 1597
				summary = toStr(row[5]), -- 1598
				toolName = toStr(row[6]), -- 1599
				createdAt = row[7] -- 1600
			} -- 1600
			i = i + 1 -- 1591
		end -- 1591
	end -- 1591
	return items -- 1603
end -- 1571
function ____exports.listCheckpoints(taskId) -- 1606
	return ____exports.listCheckpointsForTasks({taskId}) -- 1607
end -- 1606
function ____exports.getCheckpoint(checkpointId) -- 1610
	if checkpointId <= 0 then -- 1610
		return nil -- 1611
	end -- 1611
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE id = ?\n\t\tLIMIT 1", {checkpointId}) -- 1612
	if not rows or #rows == 0 then -- 1612
		return nil -- 1619
	end -- 1619
	local row = rows[1] -- 1620
	return { -- 1621
		id = row[1], -- 1622
		taskId = row[2], -- 1623
		seq = row[3], -- 1624
		status = toStr(row[4]), -- 1625
		summary = toStr(row[5]), -- 1626
		toolName = toStr(row[6]), -- 1627
		createdAt = row[7] -- 1628
	} -- 1628
end -- 1610
local function listCheckpointIdsForTask(taskId, desc) -- 1632
	if desc == nil then -- 1632
		desc = false -- 1632
	end -- 1632
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 1633
	if not rows then -- 1633
		return {} -- 1640
	end -- 1640
	local items = {} -- 1641
	do -- 1641
		local i = 0 -- 1642
		while i < #rows do -- 1642
			local row = rows[i + 1] -- 1643
			items[#items + 1] = {id = row[1], seq = row[2]} -- 1644
			i = i + 1 -- 1642
		end -- 1642
	end -- 1642
	return items -- 1649
end -- 1632
local function deriveFileOp(beforeExists, afterExists) -- 1652
	if not beforeExists and afterExists then -- 1652
		return "create" -- 1653
	end -- 1653
	if beforeExists and not afterExists then -- 1653
		return "delete" -- 1654
	end -- 1654
	return "write" -- 1655
end -- 1652
function ____exports.summarizeTaskChangeSet(taskId) -- 1658
	if not getTaskStatus(taskId) then -- 1658
		return {success = false, message = "task not found"} -- 1660
	end -- 1660
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1662
	local filesByPath = {} -- 1663
	local latestCheckpointId = nil -- 1669
	local latestCheckpointSeq = nil -- 1670
	do -- 1670
		local i = 0 -- 1671
		while i < #checkpoints do -- 1671
			local checkpoint = checkpoints[i + 1] -- 1672
			latestCheckpointId = checkpoint.id -- 1673
			latestCheckpointSeq = checkpoint.seq -- 1674
			local entries = getCheckpointEntryMetadata(checkpoint.id, false) -- 1675
			do -- 1675
				local j = 0 -- 1676
				while j < #entries do -- 1676
					local entry = entries[j + 1] -- 1677
					local item = filesByPath[entry.path] -- 1678
					if not item then -- 1678
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 1680
						filesByPath[entry.path] = item -- 1686
					end -- 1686
					item.afterExists = entry.afterExists -- 1688
					local ____item_checkpointIds_24 = item.checkpointIds -- 1688
					____item_checkpointIds_24[#____item_checkpointIds_24 + 1] = checkpoint.id -- 1689
					j = j + 1 -- 1676
				end -- 1676
			end -- 1676
			i = i + 1 -- 1671
		end -- 1671
	end -- 1671
	local files = {} -- 1692
	for ____, item in pairs(filesByPath) do -- 1693
		files[#files + 1] = { -- 1694
			path = item.path, -- 1695
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1696
			checkpointCount = #item.checkpointIds, -- 1697
			checkpointIds = item.checkpointIds -- 1698
		} -- 1698
	end -- 1698
	__TS__ArraySort( -- 1701
		files, -- 1701
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1701
	) -- 1701
	return { -- 1702
		success = true, -- 1703
		taskId = taskId, -- 1704
		checkpointCount = #checkpoints, -- 1705
		filesChanged = #files, -- 1706
		files = files, -- 1707
		latestCheckpointId = latestCheckpointId, -- 1708
		latestCheckpointSeq = latestCheckpointSeq -- 1709
	} -- 1709
end -- 1658
function ____exports.getTaskChangeSetDiff(taskId) -- 1713
	if not getTaskStatus(taskId) then -- 1713
		return {success = false, message = "task not found"} -- 1715
	end -- 1715
	local entryRows = DB:query(((("SELECT e.id, e.path, e.before_exists, e.after_exists\n\t\tFROM " .. TABLE_ENTRY) .. " e\n\t\tJOIN ") .. TABLE_CP) .. " c ON c.id = e.checkpoint_id\n\t\tWHERE c.task_id = ? AND c.status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY c.seq ASC, e.ord ASC", {taskId}) -- 1717
	if not entryRows or #entryRows == 0 then -- 1717
		return {success = false, message = "change set not found or empty"} -- 1726
	end -- 1726
	local filesByPath = {} -- 1728
	do -- 1728
		local i = 0 -- 1735
		while i < #entryRows do -- 1735
			local row = entryRows[i + 1] -- 1736
			local entryId = row[1] -- 1737
			local path = toStr(row[2]) -- 1738
			local item = filesByPath[path] -- 1739
			if not item then -- 1739
				item = { -- 1741
					path = path, -- 1742
					firstEntryId = entryId, -- 1743
					lastEntryId = entryId, -- 1744
					beforeExists = toBool(row[3]), -- 1745
					afterExists = toBool(row[4]) -- 1746
				} -- 1746
				filesByPath[path] = item -- 1748
			end -- 1748
			item.lastEntryId = entryId -- 1750
			item.afterExists = toBool(row[4]) -- 1751
			i = i + 1 -- 1735
		end -- 1735
	end -- 1735
	local files = {} -- 1753
	for ____, item in pairs(filesByPath) do -- 1754
		local contentRows = DB:query(((("SELECT\n\t\t\t\t(SELECT dora_decompress_text(before_data) FROM " .. TABLE_ENTRY) .. " WHERE id = ?),\n\t\t\t\t(SELECT dora_decompress_text(after_data) FROM ") .. TABLE_ENTRY) .. " WHERE id = ?)", {item.firstEntryId, item.lastEntryId}) -- 1755
		if not contentRows or #contentRows == 0 then -- 1755
			return {success = false, message = "failed to read checkpoint data for " .. item.path} -- 1762
		end -- 1762
		files[#files + 1] = { -- 1764
			path = item.path, -- 1765
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1766
			beforeExists = item.beforeExists, -- 1767
			afterExists = item.afterExists, -- 1768
			beforeContent = toStr(contentRows[1][1]), -- 1769
			afterContent = toStr(contentRows[1][2]) -- 1770
		} -- 1770
	end -- 1770
	__TS__ArraySort( -- 1773
		files, -- 1773
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1773
	) -- 1773
	return {success = true, files = files} -- 1774
end -- 1713
local function readWorkspaceFile(workDir, path, docLanguage) -- 1777
	local engineLog = readEngineLogFile(path) -- 1778
	if engineLog then -- 1778
		return engineLog -- 1779
	end -- 1779
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1780
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 1780
		local attr = inspectReadableFile(fullPath) -- 1782
		if not attr.success then -- 1782
			return attr -- 1783
		end -- 1783
		return { -- 1784
			success = true, -- 1784
			content = Content:load(fullPath), -- 1784
			size = attr.size -- 1784
		} -- 1784
	end -- 1784
	local docPath = resolveAgentDoraDocFilePath(path, docLanguage) -- 1786
	if docPath then -- 1786
		local attr = inspectReadableFile(docPath) -- 1788
		if not attr.success then -- 1788
			return attr -- 1789
		end -- 1789
		return { -- 1790
			success = true, -- 1790
			content = Content:load(docPath), -- 1790
			size = attr.size -- 1790
		} -- 1790
	end -- 1790
	local skillPath = resolveAgentSkillFilePath(workDir, path) -- 1792
	if skillPath then -- 1792
		local attr = inspectReadableFile(skillPath) -- 1794
		if not attr.success then -- 1794
			return attr -- 1795
		end -- 1795
		return { -- 1796
			success = true, -- 1796
			content = Content:load(skillPath), -- 1796
			size = attr.size -- 1796
		} -- 1796
	end -- 1796
	if not fullPath then -- 1796
		return {success = false, message = "invalid path or workDir"} -- 1798
	end -- 1798
	return {success = false, message = "file not found"} -- 1799
end -- 1777
function ____exports.readFileRaw(workDir, path, docLanguage) -- 1802
	return readWorkspaceFile(workDir, path, docLanguage) -- 1803
end -- 1802
function ____exports.getLogs(req) -- 1818
	local text = getEngineLogText() -- 1819
	if text == nil then -- 1819
		return {success = false, message = "failed to read engine logs"} -- 1821
	end -- 1821
	local tailLines = math.max( -- 1823
		1, -- 1823
		math.floor(req and req.tailLines or 200) -- 1823
	) -- 1823
	local allLines = __TS__StringSplit(text, "\n") -- 1824
	local logs = __TS__ArraySlice( -- 1825
		allLines, -- 1825
		math.max(0, #allLines - tailLines) -- 1825
	) -- 1825
	return req and req.joinText and ({ -- 1826
		success = true, -- 1826
		logs = logs, -- 1826
		text = table.concat(logs, "\n") -- 1826
	}) or ({success = true, logs = logs}) -- 1826
end -- 1818
function ____exports.listFiles(req) -- 1829
	local root = req.path or "" -- 1835
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 1836
	if not searchRoot then -- 1836
		return {success = false, message = "invalid path or workDir"} -- 1838
	end -- 1838
	do -- 1838
		local function ____catch(e) -- 1838
			return true, { -- 1856
				success = false, -- 1856
				message = tostring(e) -- 1856
			} -- 1856
		end -- 1856
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1856
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 1841
			local globs = ensureSafeSearchGlobs(userGlobs) -- 1842
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 1843
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 1844
			local totalEntries = #files -- 1845
			local maxEntries = math.max( -- 1846
				1, -- 1846
				math.floor(req.maxEntries or 200) -- 1846
			) -- 1846
			local truncated = totalEntries > maxEntries -- 1847
			return true, { -- 1848
				success = true, -- 1849
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 1850
				totalEntries = totalEntries, -- 1851
				truncated = truncated, -- 1852
				maxEntries = maxEntries -- 1853
			} -- 1853
		end) -- 1853
		if not ____try then -- 1853
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1853
		end -- 1853
		if ____hasReturned then -- 1853
			return ____returnValue -- 1840
		end -- 1840
	end -- 1840
end -- 1829
local function formatReadSlice(content, startLine, endLine) -- 1860
	local lines = __TS__StringSplit(content, "\n") -- 1865
	local totalLines = #lines -- 1866
	if totalLines == 0 then -- 1866
		return { -- 1868
			success = true, -- 1869
			content = "", -- 1870
			totalLines = 0, -- 1871
			startLine = 1, -- 1872
			endLine = 0, -- 1873
			truncated = false -- 1874
		} -- 1874
	end -- 1874
	local rawStart = math.floor(startLine) -- 1877
	local rawEnd = math.floor(endLine) -- 1878
	if rawStart == 0 then -- 1878
		return {success = false, message = "startLine cannot be 0"} -- 1880
	end -- 1880
	if rawEnd == 0 then -- 1880
		return {success = false, message = "endLine cannot be 0"} -- 1883
	end -- 1883
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1885
	if start > totalLines then -- 1885
		return { -- 1889
			success = false, -- 1889
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1889
		} -- 1889
	end -- 1889
	local ____end = math.min( -- 1891
		totalLines, -- 1892
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1893
	) -- 1893
	if ____end < start then -- 1893
		return { -- 1898
			success = false, -- 1899
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1900
		} -- 1900
	end -- 1900
	local slice = {} -- 1903
	do -- 1903
		local i = start -- 1904
		while i <= ____end do -- 1904
			slice[#slice + 1] = lines[i] -- 1905
			i = i + 1 -- 1904
		end -- 1904
	end -- 1904
	local truncated = start > 1 or ____end < totalLines -- 1907
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1908
	local body = table.concat(slice, "\n") -- 1913
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1914
	return { -- 1915
		success = true, -- 1916
		content = output, -- 1917
		totalLines = totalLines, -- 1918
		startLine = start, -- 1919
		endLine = ____end, -- 1920
		truncated = truncated -- 1921
	} -- 1921
end -- 1860
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1925
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1932
	if not fallback.success or fallback.content == nil then -- 1932
		return fallback -- 1933
	end -- 1933
	local resolvedStartLine = startLine or 1 -- 1934
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1935
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1936
end -- 1925
local codeExtensions = { -- 1943
	".lua", -- 1943
	".tl", -- 1943
	".yue", -- 1943
	".ts", -- 1943
	".tsx", -- 1943
	".xml", -- 1943
	".md", -- 1943
	".yarn", -- 1943
	".wa", -- 1943
	".mod" -- 1943
} -- 1943
extensionLevels = { -- 1944
	vs = 2, -- 1945
	bl = 2, -- 1946
	ts = 1, -- 1947
	tsx = 1, -- 1948
	tl = 1, -- 1949
	yue = 1, -- 1950
	xml = 1, -- 1951
	lua = 0 -- 1952
} -- 1952
local function splitSearchPatterns(pattern) -- 1969
	local trimmed = __TS__StringTrim(pattern or "") -- 1970
	if trimmed == "" then -- 1970
		return {} -- 1971
	end -- 1971
	local out = {} -- 1972
	local seen = __TS__New(Set) -- 1973
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1974
		local p = __TS__StringTrim(tostring(p0)) -- 1975
		if p ~= "" and not seen:has(p) then -- 1975
			seen:add(p) -- 1977
			out[#out + 1] = p -- 1978
		end -- 1978
	end -- 1978
	return out -- 1981
end -- 1969
local function splitWhitespaceSearchPatterns(pattern) -- 1984
	local out = {} -- 1985
	local seen = __TS__New(Set) -- 1986
	for p0 in string.gmatch(pattern, "(%S+)") do -- 1987
		local p = __TS__StringTrim(tostring(p0)) -- 1988
		local key = string.lower(p) -- 1989
		if p ~= "" and not seen:has(key) then -- 1989
			seen:add(key) -- 1991
			out[#out + 1] = p -- 1992
		end -- 1992
	end -- 1992
	return out -- 1995
end -- 1984
local function mergeSearchFileResultsUnique(resultsList) -- 1998
	local merged = {} -- 1999
	local seen = __TS__New(Set) -- 2000
	do -- 2000
		local i = 0 -- 2001
		while i < #resultsList do -- 2001
			local list = resultsList[i + 1] -- 2002
			do -- 2002
				local j = 0 -- 2003
				while j < #list do -- 2003
					do -- 2003
						local row = list[j + 1] -- 2004
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 2005
						if seen:has(key) then -- 2005
							goto __continue434 -- 2006
						end -- 2006
						seen:add(key) -- 2007
						merged[#merged + 1] = list[j + 1] -- 2008
					end -- 2008
					::__continue434:: -- 2008
					j = j + 1 -- 2003
				end -- 2003
			end -- 2003
			i = i + 1 -- 2001
		end -- 2001
	end -- 2001
	return merged -- 2011
end -- 1998
local function buildGroupedSearchResults(results) -- 2014
	local order = {} -- 2019
	local grouped = __TS__New(Map) -- 2020
	do -- 2020
		local i = 0 -- 2025
		while i < #results do -- 2025
			local row = results[i + 1] -- 2026
			local file = row.file -- 2027
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 2028
			local bucket = grouped:get(key) -- 2029
			if not bucket then -- 2029
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 2031
				grouped:set(key, bucket) -- 2032
				order[#order + 1] = key -- 2033
			end -- 2033
			bucket.totalMatches = bucket.totalMatches + 1 -- 2035
			local ____bucket_matches_29 = bucket.matches -- 2035
			____bucket_matches_29[#____bucket_matches_29 + 1] = results[i + 1] -- 2036
			i = i + 1 -- 2025
		end -- 2025
	end -- 2025
	local out = {} -- 2038
	do -- 2038
		local i = 0 -- 2043
		while i < #order do -- 2043
			local bucket = grouped:get(order[i + 1]) -- 2044
			if bucket then -- 2044
				out[#out + 1] = bucket -- 2045
			end -- 2045
			i = i + 1 -- 2043
		end -- 2043
	end -- 2043
	return out -- 2047
end -- 2014
local function mergeDoraDocSearchHitsUnique(resultsList) -- 2050
	local merged = {} -- 2051
	local seen = __TS__New(Set) -- 2052
	local index = 0 -- 2053
	local advanced = true -- 2054
	while advanced do -- 2054
		advanced = false -- 2056
		do -- 2056
			local i = 0 -- 2057
			while i < #resultsList do -- 2057
				do -- 2057
					local list = resultsList[i + 1] -- 2058
					if index >= #list then -- 2058
						goto __continue446 -- 2059
					end -- 2059
					advanced = true -- 2060
					local row = list[index + 1] -- 2061
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 2062
					if seen:has(key) then -- 2062
						goto __continue446 -- 2063
					end -- 2063
					seen:add(key) -- 2064
					merged[#merged + 1] = row -- 2065
				end -- 2065
				::__continue446:: -- 2065
				i = i + 1 -- 2057
			end -- 2057
		end -- 2057
		index = index + 1 -- 2067
	end -- 2067
	return merged -- 2069
end -- 2050
local function getDoraDocFilePriority(file, docType, programmingLanguage) -- 2072
	if docType ~= "dora-api" then -- 2072
		return 100 -- 2073
	end -- 2073
	if programmingLanguage ~= "tsx" then -- 2073
		return 100 -- 2074
	end -- 2074
	repeat -- 2074
		local ____switch452 = string.lower(Path:getFilename(file)) -- 2074
		local ____cond452 = ____switch452 == "jsx.d.ts" -- 2074
		if ____cond452 then -- 2074
			return 0 -- 2076
		end -- 2076
		____cond452 = ____cond452 or ____switch452 == "dorax.d.ts" -- 2076
		if ____cond452 then -- 2076
			return 1 -- 2077
		end -- 2077
		____cond452 = ____cond452 or ____switch452 == "dora.d.ts" -- 2077
		if ____cond452 then -- 2077
			return 2 -- 2078
		end -- 2078
		do -- 2078
			return 100 -- 2079
		end -- 2079
	until true -- 2079
end -- 2072
local function sortDoraDocSearchHits(hits, docType, programmingLanguage) -- 2083
	local sorted = __TS__ArraySlice(hits) -- 2088
	__TS__ArraySort( -- 2089
		sorted, -- 2089
		function(____, a, b) -- 2089
			local pa = getDoraDocFilePriority(a.file, docType, programmingLanguage) -- 2090
			local pb = getDoraDocFilePriority(b.file, docType, programmingLanguage) -- 2091
			if pa ~= pb then -- 2091
				return pa - pb -- 2092
			end -- 2092
			local fa = string.lower(a.file) -- 2093
			local fb = string.lower(b.file) -- 2094
			if fa ~= fb then -- 2094
				return fa < fb and -1 or 1 -- 2095
			end -- 2095
			return (a.line or 0) - (b.line or 0) -- 2096
		end -- 2089
	) -- 2089
	return sorted -- 2098
end -- 2083
function ____exports.searchFiles(req) -- 2101
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2101
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 2114
		if not resolvedPath then -- 2114
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2114
		end -- 2114
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 2118
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 2119
		if not searchRoot then -- 2119
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2119
		end -- 2119
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 2119
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2119
		end -- 2119
		local patterns = splitSearchPatterns(req.pattern) -- 2126
		if #patterns == 0 then -- 2126
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2126
		end -- 2126
		return ____awaiter_resolve( -- 2126
			nil, -- 2126
			__TS__New( -- 2130
				__TS__Promise, -- 2130
				function(____, resolve) -- 2130
					Director.systemScheduler:schedule(once(function() -- 2131
						do -- 2131
							local function ____catch(e) -- 2131
								resolve( -- 2173
									nil, -- 2173
									{ -- 2173
										success = false, -- 2173
										message = tostring(e) -- 2173
									} -- 2173
								) -- 2173
							end -- 2173
							local ____try, ____hasReturned = pcall(function() -- 2173
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 2133
								local allResults = {} -- 2136
								do -- 2136
									local i = 0 -- 2137
									while i < #patterns do -- 2137
										local ____Content_34 = Content -- 2138
										local ____Content_searchFilesAsync_35 = Content.searchFilesAsync -- 2138
										local ____patterns_index_33 = patterns[i + 1] -- 2143
										local ____req_useRegex_30 = req.useRegex -- 2144
										if ____req_useRegex_30 == nil then -- 2144
											____req_useRegex_30 = false -- 2144
										end -- 2144
										local ____req_caseSensitive_31 = req.caseSensitive -- 2145
										if ____req_caseSensitive_31 == nil then -- 2145
											____req_caseSensitive_31 = false -- 2145
										end -- 2145
										local ____req_includeContent_32 = req.includeContent -- 2146
										if ____req_includeContent_32 == nil then -- 2146
											____req_includeContent_32 = true -- 2146
										end -- 2146
										allResults[#allResults + 1] = ____Content_searchFilesAsync_35( -- 2138
											____Content_34, -- 2138
											searchRoot, -- 2139
											codeExtensions, -- 2140
											extensionLevels, -- 2141
											searchGlobs, -- 2142
											____patterns_index_33, -- 2143
											____req_useRegex_30, -- 2144
											____req_caseSensitive_31, -- 2145
											____req_includeContent_32, -- 2146
											req.contentWindow or 120 -- 2147
										) -- 2147
										i = i + 1 -- 2137
									end -- 2137
								end -- 2137
								local results = mergeSearchFileResultsUnique(allResults) -- 2150
								local totalResults = #results -- 2151
								local limit = math.max( -- 2152
									1, -- 2152
									math.floor(req.limit or 20) -- 2152
								) -- 2152
								local offset = math.max( -- 2153
									0, -- 2153
									math.floor(req.offset or 0) -- 2153
								) -- 2153
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 2154
								local nextOffset = offset + #paged -- 2155
								local hasMore = nextOffset < totalResults -- 2156
								local truncated = offset > 0 or hasMore -- 2157
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 2158
								local groupByFile = req.groupByFile == true -- 2159
								resolve( -- 2160
									nil, -- 2160
									{ -- 2160
										success = true, -- 2161
										results = relativeResults, -- 2162
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 2163
										totalResults = totalResults, -- 2164
										truncated = truncated, -- 2165
										limit = limit, -- 2166
										offset = offset, -- 2167
										nextOffset = nextOffset, -- 2168
										hasMore = hasMore, -- 2169
										groupByFile = groupByFile -- 2170
									} -- 2170
								) -- 2170
							end) -- 2170
							if not ____try then -- 2170
								____catch(____hasReturned) -- 2170
							end -- 2170
						end -- 2170
					end)) -- 2131
				end -- 2130
			) -- 2130
		) -- 2130
	end) -- 2130
end -- 2101
function ____exports.searchDoraDoc(req) -- 2179
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2179
		local pattern = __TS__StringTrim(req.pattern or "") -- 2190
		if pattern == "" then -- 2190
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2190
		end -- 2190
		local patterns = splitSearchPatterns(pattern) -- 2192
		if #patterns == 0 then -- 2192
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2192
		end -- 2192
		local docType = req.docType or "dora-api" -- 2194
		local target = getDoraDocSearchTarget(docType, req.docLanguage, req.programmingLanguage) -- 2195
		local docRoot = target.root -- 2196
		local resultBaseRoot = getDoraDocResultBaseRoot(docType, req.docLanguage) -- 2197
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 2197
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 2197
		end -- 2197
		local exts = target.exts -- 2201
		local dotExts = __TS__ArrayMap( -- 2202
			exts, -- 2202
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 2202
		) -- 2202
		local globs = target.globs -- 2203
		local limit = math.max( -- 2204
			1, -- 2204
			math.floor(req.limit or 10) -- 2204
		) -- 2204
		return ____awaiter_resolve( -- 2204
			nil, -- 2204
			__TS__New( -- 2206
				__TS__Promise, -- 2206
				function(____, resolve) -- 2206
					Director.systemScheduler:schedule(once(function() -- 2207
						do -- 2207
							local function ____catch(e) -- 2207
								resolve( -- 2287
									nil, -- 2287
									{ -- 2287
										success = false, -- 2287
										message = tostring(e) -- 2287
									} -- 2287
								) -- 2287
							end -- 2287
							local ____try, ____hasReturned = pcall(function() -- 2287
								local allHits = {} -- 2209
								do -- 2209
									local p = 0 -- 2210
									while p < #patterns do -- 2210
										local ____Content_40 = Content -- 2211
										local ____Content_searchFilesAsync_41 = Content.searchFilesAsync -- 2211
										local ____array_39 = __TS__SparseArrayNew( -- 2211
											docRoot, -- 2212
											dotExts, -- 2213
											{}, -- 2214
											ensureSafeSearchGlobs(globs), -- 2215
											patterns[p + 1] -- 2216
										) -- 2216
										local ____req_useRegex_36 = req.useRegex -- 2217
										if ____req_useRegex_36 == nil then -- 2217
											____req_useRegex_36 = false -- 2217
										end -- 2217
										__TS__SparseArrayPush(____array_39, ____req_useRegex_36) -- 2217
										local ____req_caseSensitive_37 = req.caseSensitive -- 2218
										if ____req_caseSensitive_37 == nil then -- 2218
											____req_caseSensitive_37 = false -- 2218
										end -- 2218
										__TS__SparseArrayPush(____array_39, ____req_caseSensitive_37) -- 2218
										local ____req_includeContent_38 = req.includeContent -- 2219
										if ____req_includeContent_38 == nil then -- 2219
											____req_includeContent_38 = true -- 2219
										end -- 2219
										__TS__SparseArrayPush(____array_39, ____req_includeContent_38, req.contentWindow or 80) -- 2219
										local raw = ____Content_searchFilesAsync_41( -- 2211
											____Content_40, -- 2211
											__TS__SparseArraySpread(____array_39) -- 2211
										) -- 2211
										local hits = {} -- 2222
										do -- 2222
											local i = 0 -- 2223
											while i < #raw do -- 2223
												do -- 2223
													local row = raw[i + 1] -- 2224
													local file = toDocRelativePath(resultBaseRoot, row.file, docType) -- 2225
													if file == "" then -- 2225
														goto __continue479 -- 2226
													end -- 2226
													hits[#hits + 1] = { -- 2227
														file = file, -- 2228
														line = type(row.line) == "number" and row.line or nil, -- 2229
														content = type(row.content) == "string" and row.content or nil -- 2230
													} -- 2230
												end -- 2230
												::__continue479:: -- 2230
												i = i + 1 -- 2223
											end -- 2223
										end -- 2223
										allHits[#allHits + 1] = __TS__ArraySlice( -- 2233
											sortDoraDocSearchHits(hits, docType, req.programmingLanguage), -- 2233
											0, -- 2233
											limit -- 2233
										) -- 2233
										p = p + 1 -- 2210
									end -- 2210
								end -- 2210
								local hits = mergeDoraDocSearchHitsUnique(allHits) -- 2235
								local fallbackPatterns -- 2236
								if #hits == 0 and #patterns == 1 and req.useRegex ~= true and (string.find(pattern, "|", nil, true) or 0) - 1 < 0 then -- 2236
									local terms = splitWhitespaceSearchPatterns(pattern) -- 2241
									if #terms > 1 then -- 2241
										fallbackPatterns = terms -- 2243
										local fallbackHits = {} -- 2244
										do -- 2244
											local p = 0 -- 2245
											while p < #terms do -- 2245
												local ____Content_45 = Content -- 2246
												local ____Content_searchFilesAsync_46 = Content.searchFilesAsync -- 2246
												local ____array_44 = __TS__SparseArrayNew( -- 2246
													docRoot, -- 2247
													dotExts, -- 2248
													{}, -- 2249
													ensureSafeSearchGlobs(globs), -- 2250
													terms[p + 1], -- 2251
													false -- 2252
												) -- 2252
												local ____req_caseSensitive_42 = req.caseSensitive -- 2253
												if ____req_caseSensitive_42 == nil then -- 2253
													____req_caseSensitive_42 = false -- 2253
												end -- 2253
												__TS__SparseArrayPush(____array_44, ____req_caseSensitive_42) -- 2253
												local ____req_includeContent_43 = req.includeContent -- 2254
												if ____req_includeContent_43 == nil then -- 2254
													____req_includeContent_43 = true -- 2254
												end -- 2254
												__TS__SparseArrayPush(____array_44, ____req_includeContent_43, req.contentWindow or 80) -- 2254
												local raw = ____Content_searchFilesAsync_46( -- 2246
													____Content_45, -- 2246
													__TS__SparseArraySpread(____array_44) -- 2246
												) -- 2246
												local termHits = {} -- 2257
												do -- 2257
													local i = 0 -- 2258
													while i < #raw do -- 2258
														do -- 2258
															local row = raw[i + 1] -- 2259
															local file = toDocRelativePath(resultBaseRoot, row.file, docType) -- 2260
															if file == "" then -- 2260
																goto __continue486 -- 2261
															end -- 2261
															termHits[#termHits + 1] = { -- 2262
																file = file, -- 2263
																line = type(row.line) == "number" and row.line or nil, -- 2264
																content = type(row.content) == "string" and row.content or nil -- 2265
															} -- 2265
														end -- 2265
														::__continue486:: -- 2265
														i = i + 1 -- 2258
													end -- 2258
												end -- 2258
												fallbackHits[#fallbackHits + 1] = __TS__ArraySlice( -- 2268
													sortDoraDocSearchHits(termHits, docType, req.programmingLanguage), -- 2268
													0, -- 2268
													limit -- 2268
												) -- 2268
												p = p + 1 -- 2245
											end -- 2245
										end -- 2245
										hits = mergeDoraDocSearchHitsUnique(fallbackHits) -- 2270
									end -- 2270
								end -- 2270
								resolve(nil, { -- 2273
									success = true, -- 2274
									docType = docType, -- 2275
									docLanguage = req.docLanguage, -- 2276
									programmingLanguage = req.programmingLanguage, -- 2277
									exts = exts, -- 2278
									results = hits, -- 2279
									hint = "Use read_file directly with the namespaced file value from a search result to view the complete authoritative document.", -- 2280
									totalResults = #hits, -- 2281
									truncated = false, -- 2282
									limit = limit, -- 2283
									fallbackPatterns = fallbackPatterns -- 2284
								}) -- 2284
							end) -- 2284
							if not ____try then -- 2284
								____catch(____hasReturned) -- 2284
							end -- 2284
						end -- 2284
					end)) -- 2207
				end -- 2206
			) -- 2206
		) -- 2206
	end) -- 2206
end -- 2179
function ____exports.searchDoraDocHttp(req, callback) -- 2293
	local ____self_47 = ____exports.searchDoraDoc(req) -- 2293
	____self_47["then"]( -- 2293
		____self_47, -- 2293
		function(____, result) return callback(result) end -- 2304
	) -- 2304
end -- 2293
function ____exports.readDoraDoc(req) -- 2307
	local requestedFile = table.concat( -- 2313
		__TS__StringSplit(req.file or "", "\\"), -- 2313
		"/" -- 2313
	) -- 2313
	local file = requestedFile -- 2314
	local namespacedType = nil -- 2315
	if __TS__StringStartsWith(requestedFile, AGENT_DORA_DOC_PREFIX) then -- 2315
		local namespaced = __TS__StringSlice(requestedFile, #AGENT_DORA_DOC_PREFIX) -- 2317
		if __TS__StringStartsWith(namespaced, "dora-api/") then -- 2317
			namespacedType = "dora-api" -- 2319
			file = string.sub(namespaced, 10) -- 2320
		elseif __TS__StringStartsWith(namespaced, "love-api/") then -- 2320
			namespacedType = "love-api" -- 2322
			file = string.sub(namespaced, 10) -- 2323
		elseif __TS__StringStartsWith(namespaced, "tic80-api/") then -- 2323
			namespacedType = "tic80-api" -- 2325
			file = string.sub(namespaced, 11) -- 2326
		elseif __TS__StringStartsWith(namespaced, "dora-tutorial/") then -- 2326
			namespacedType = "dora-tutorial" -- 2328
			file = string.sub(namespaced, 15) -- 2329
		elseif __TS__StringStartsWith(namespaced, "api/") then -- 2329
			namespacedType = "dora-api" -- 2331
			file = string.sub(namespaced, 5) -- 2332
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 2332
			namespacedType = "dora-tutorial" -- 2334
			file = string.sub(namespaced, 10) -- 2335
		else -- 2335
			return {success = false, message = "invalid Dora doc namespace"} -- 2337
		end -- 2337
	end -- 2337
	if not isValidWorkspacePath(file) or file == "." then -- 2337
		return {success = false, message = "invalid file"} -- 2341
	end -- 2341
	local lowerFile = string.lower(file) -- 2343
	local isTutorialDoc = __TS__StringEndsWith(lowerFile, ".md") -- 2344
	local isAPIDoc = __TS__StringEndsWith(lowerFile, ".ts") or __TS__StringEndsWith(lowerFile, ".tl") -- 2345
	if not isTutorialDoc and not isAPIDoc then -- 2345
		return {success = false, message = "unsupported doc file type"} -- 2346
	end -- 2346
	local docType = namespacedType or (isTutorialDoc and "dora-tutorial" or "dora-api") -- 2347
	if not isDoraDocFileInScope(docType, file) then -- 2347
		return {success = false, message = "document is outside the requested search type"} -- 2349
	end -- 2349
	local root = getDoraDocResultBaseRoot(docType, req.docLanguage) -- 2351
	local fullPath = Path(root, file) -- 2352
	local relative = Path:getRelative(fullPath, root) -- 2353
	if relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 2353
		return {success = false, message = "invalid file"} -- 2355
	end -- 2355
	local readResult = ____exports.readFile(root, file, req.startLine or 1, req.endLine or -1) -- 2357
	if not readResult.success then -- 2357
		return readResult -- 2358
	end -- 2358
	return { -- 2359
		success = true, -- 2360
		docLanguage = req.docLanguage, -- 2361
		file = file, -- 2362
		content = readResult.content, -- 2363
		startLine = readResult.startLine, -- 2364
		endLine = readResult.endLine -- 2365
	} -- 2365
end -- 2307
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 2369
	if options == nil then -- 2369
		options = {} -- 2369
	end -- 2369
	local storage = requireAgentStorage() -- 2370
	if not storage.success then -- 2370
		return storage -- 2371
	end -- 2371
	if #changes == 0 then -- 2371
		return {success = false, message = "empty changes"} -- 2373
	end -- 2373
	if not isValidWorkDir(workDir) then -- 2373
		return {success = false, message = "invalid workDir"} -- 2376
	end -- 2376
	if not getTaskStatus(taskId) then -- 2376
		return {success = false, message = "task not found"} -- 2379
	end -- 2379
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 2381
	local dup = rejectDuplicatePaths(expandedChanges) -- 2382
	if dup then -- 2382
		return {success = false, message = "duplicate path in batch: " .. dup} -- 2384
	end -- 2384
	for ____, change in ipairs(expandedChanges) do -- 2387
		if not isValidWorkspacePath(change.path) then -- 2387
			return {success = false, message = "invalid path: " .. change.path} -- 2389
		end -- 2389
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 2389
			return {success = false, message = "missing content for " .. change.path} -- 2392
		end -- 2392
	end -- 2392
	local headSeq = getTaskHeadSeq(taskId) -- 2396
	if headSeq == nil then -- 2396
		return {success = false, message = "task not found"} -- 2397
	end -- 2397
	local nextSeq = headSeq + 1 -- 2398
	local preparedEntries = {} -- 2400
	do -- 2400
		local i = 0 -- 2401
		while i < #expandedChanges do -- 2401
			local change = expandedChanges[i + 1] -- 2402
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 2403
			if not fullPath then -- 2403
				return {success = false, message = "invalid path: " .. change.path} -- 2405
			end -- 2405
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 2405
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 2408
			end -- 2408
			if Content:exist(fullPath) and not Content:isdir(fullPath) then -- 2408
				local ____, isBinary = Content:getAttr(fullPath) -- 2411
				if isBinary == true then -- 2411
					return {success = false, message = change.op == "delete" and "binary file deletion must use delete_file: " .. change.path or "binary files cannot be edited with text checkpoints: " .. change.path} -- 2413
				end -- 2413
			end -- 2413
			local before = getFileState(fullPath) -- 2421
			local afterExists = change.op ~= "delete" -- 2422
			local afterContent = afterExists and (change.content or "") or "" -- 2423
			preparedEntries[#preparedEntries + 1] = { -- 2424
				id = 0, -- 2425
				ord = i + 1, -- 2426
				path = change.path, -- 2427
				op = change.op, -- 2428
				beforeExists = before.exists, -- 2429
				beforeContent = before.content, -- 2430
				afterExists = afterExists, -- 2431
				afterContent = afterContent -- 2432
			} -- 2432
			i = i + 1 -- 2401
		end -- 2401
	end -- 2401
	local checkpointId = insertCheckpoint( -- 2436
		taskId, -- 2436
		nextSeq, -- 2436
		options.summary or "", -- 2436
		options.toolName or "", -- 2436
		"PREPARED" -- 2436
	) -- 2436
	if checkpointId <= 0 then -- 2436
		return {success = false, message = "failed to create checkpoint"} -- 2438
	end -- 2438
	local entryRows = {} -- 2440
	do -- 2440
		local i = 0 -- 2441
		while i < #preparedEntries do -- 2441
			local entry = preparedEntries[i + 1] -- 2442
			entryRows[#entryRows + 1] = { -- 2443
				checkpointId, -- 2444
				entry.ord, -- 2445
				entry.path, -- 2446
				entry.op, -- 2447
				entry.beforeExists and 1 or 0, -- 2448
				entry.beforeContent, -- 2449
				entry.afterExists and 1 or 0, -- 2450
				entry.afterContent, -- 2451
				#entry.beforeContent, -- 2452
				#entry.afterContent -- 2453
			} -- 2453
			i = i + 1 -- 2441
		end -- 2441
	end -- 2441
	local entryInsert = {("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_data, after_exists, after_data, bytes_before, bytes_after)\n\t\tVALUES(?, ?, ?, ?, ?, dora_compress_text(?), ?, dora_compress_text(?), ?, ?)", entryRows} -- 2456
	if not DB:transaction({entryInsert}) then -- 2456
		DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2462
		return {success = false, message = "failed to insert checkpoint entries"} -- 2463
	end -- 2463
	local appliedCount = 0 -- 2466
	for ____, entry in ipairs(preparedEntries) do -- 2467
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2468
		if not fullPath then -- 2468
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2470
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2471
			return {success = false, message = ("invalid path: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2472
		end -- 2472
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 2474
		if not ok then -- 2474
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2476
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount + 1) -- 2477
			return {success = false, message = ("failed to apply file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2478
		end -- 2478
		appliedCount = appliedCount + 1 -- 2480
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 2480
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2482
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2483
			return {success = false, message = ("failed to sync file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; all applied files restored")} -- 2484
		end -- 2484
	end -- 2484
	DB:exec( -- 2488
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 2488
		{ -- 2490
			"APPLIED", -- 2490
			now(), -- 2490
			checkpointId -- 2490
		} -- 2490
	) -- 2490
	DB:exec( -- 2492
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 2492
		{ -- 2494
			nextSeq, -- 2494
			now(), -- 2494
			taskId -- 2494
		} -- 2494
	) -- 2494
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 2496
end -- 2369
function ____exports.deleteFile(taskId, workDir, targetFile, options) -- 2504
	if options == nil then -- 2504
		options = {} -- 2504
	end -- 2504
	local storage = requireAgentStorage() -- 2505
	if not storage.success then -- 2505
		return storage -- 2506
	end -- 2506
	if not isValidWorkDir(workDir) then -- 2506
		return {success = false, message = "invalid workDir"} -- 2508
	end -- 2508
	if not getTaskStatus(taskId) then -- 2508
		return {success = false, message = "task not found"} -- 2511
	end -- 2511
	if not isValidWorkspacePath(targetFile) then -- 2511
		return {success = false, message = "invalid path: " .. targetFile} -- 2514
	end -- 2514
	local fullPath = resolveWorkspaceFilePath(workDir, targetFile) -- 2516
	if not fullPath then -- 2516
		return {success = false, message = "invalid path: " .. targetFile} -- 2518
	end -- 2518
	if Content:exist(fullPath) and Content:isdir(fullPath) then -- 2518
		return {success = false, message = "delete_file only supports files, not directories: " .. targetFile} -- 2521
	end -- 2521
	local isBinary = false -- 2524
	if Content:exist(fullPath) then -- 2524
		do -- 2524
			local function ____catch(e) -- 2524
				Log( -- 2530
					"Warn", -- 2530
					(("[Agent.Tools] Content.getAttr failed before deleting " .. fullPath) .. ": ") .. tostring(e) -- 2530
				) -- 2530
			end -- 2530
			local ____try, ____hasReturned = pcall(function() -- 2530
				local ____, detectedBinary = Content:getAttr(fullPath) -- 2527
				isBinary = detectedBinary == true -- 2528
			end) -- 2528
			if not ____try then -- 2528
				____catch(____hasReturned) -- 2528
			end -- 2528
		end -- 2528
	end -- 2528
	if not isBinary then -- 2528
		local result = ____exports.applyFileChanges(taskId, workDir, {{path = targetFile, op = "delete"}}, options) -- 2534
		if not result.success then -- 2534
			return result -- 2535
		end -- 2535
		return __TS__ObjectAssign({}, result, {checkpointed = true, reversible = true, binary = false}) -- 2536
	end -- 2536
	if not Content:remove(fullPath) then -- 2536
		return {success = false, message = "failed to delete binary file: " .. targetFile} -- 2545
	end -- 2545
	if not ____exports.sendWebIDEFileUpdate(fullPath, false, "") then -- 2545
		____exports.sendWebIDERefreshTree() -- 2548
	end -- 2548
	return { -- 2550
		success = true, -- 2551
		taskId = taskId, -- 2552
		checkpointed = false, -- 2553
		reversible = false, -- 2554
		binary = true, -- 2555
		message = "Binary file deleted directly without a checkpoint; this deletion cannot be rolled back." -- 2556
	} -- 2556
end -- 2504
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 2560
	if not isValidWorkDir(workDir) then -- 2560
		return {success = false, message = "invalid workDir"} -- 2561
	end -- 2561
	if checkpointId <= 0 then -- 2561
		return {success = false, message = "invalid checkpointId"} -- 2562
	end -- 2562
	local entries = getCheckpointEntries(checkpointId, true) -- 2563
	if #entries == 0 then -- 2563
		return {success = false, message = "checkpoint not found or empty"} -- 2565
	end -- 2565
	for ____, entry in ipairs(entries) do -- 2567
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2568
		if not fullPath then -- 2568
			return {success = false, message = "invalid path: " .. entry.path} -- 2570
		end -- 2570
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 2572
		if not ok then -- 2572
			Log( -- 2574
				"Error", -- 2574
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2574
			) -- 2574
			Log( -- 2575
				"Info", -- 2575
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2575
			) -- 2575
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 2576
		end -- 2576
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 2576
			Log( -- 2579
				"Error", -- 2579
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2579
			) -- 2579
			Log( -- 2580
				"Info", -- 2580
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2580
			) -- 2580
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 2581
		end -- 2581
	end -- 2581
	DB:exec( -- 2584
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 2584
		{ -- 2584
			"REVERTED", -- 2584
			now(), -- 2584
			checkpointId -- 2584
		} -- 2584
	) -- 2584
	return {success = true, checkpointId = checkpointId} -- 2585
end -- 2560
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 2588
	if not isValidWorkDir(workDir) then -- 2588
		return {success = false, message = "invalid workDir"} -- 2589
	end -- 2589
	if not getTaskStatus(taskId) then -- 2589
		return {success = false, message = "task not found"} -- 2590
	end -- 2590
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 2591
	if #checkpoints == 0 then -- 2591
		return {success = false, message = "change set not found or empty"} -- 2593
	end -- 2593
	local lastCheckpointId = 0 -- 2595
	do -- 2595
		local i = 0 -- 2596
		while i < #checkpoints do -- 2596
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 2597
			if not result.success then -- 2597
				return {success = false, message = result.message} -- 2598
			end -- 2598
			lastCheckpointId = checkpoints[i + 1].id -- 2599
			i = i + 1 -- 2596
		end -- 2596
	end -- 2596
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 2601
end -- 2588
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 2609
	return getCheckpointEntries(checkpointId, false) -- 2610
end -- 2609
function ____exports.getCheckpointDiff(checkpointId) -- 2613
	if checkpointId <= 0 then -- 2613
		return {success = false, message = "invalid checkpointId"} -- 2615
	end -- 2615
	local entries = getCheckpointEntries(checkpointId, false) -- 2617
	if #entries == 0 then -- 2617
		return {success = false, message = "checkpoint not found or empty"} -- 2619
	end -- 2619
	return { -- 2621
		success = true, -- 2622
		files = __TS__ArrayMap( -- 2623
			entries, -- 2623
			function(____, entry) return { -- 2623
				path = entry.path, -- 2624
				op = entry.op, -- 2625
				beforeExists = entry.beforeExists, -- 2626
				afterExists = entry.afterExists, -- 2627
				beforeContent = entry.beforeContent, -- 2628
				afterContent = entry.afterContent -- 2629
			} end -- 2629
		) -- 2629
	} -- 2629
end -- 2613
local function finalizeBuildResult(workDir, messages) -- 2634
	local normalized = __TS__ArrayMap( -- 2635
		messages, -- 2635
		function(____, m) return m.success and __TS__ObjectAssign( -- 2635
			{}, -- 2636
			m, -- 2636
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2636
		) or __TS__ObjectAssign( -- 2636
			{}, -- 2637
			m, -- 2637
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2637
		) end -- 2637
	) -- 2637
	local total = #normalized -- 2638
	local failed = 0 -- 2639
	do -- 2639
		local i = 0 -- 2640
		while i < #normalized do -- 2640
			if not normalized[i + 1].success then -- 2640
				failed = failed + 1 -- 2641
			end -- 2641
			i = i + 1 -- 2640
		end -- 2640
	end -- 2640
	local passed = total - failed -- 2643
	if failed > 0 then -- 2643
		local interrupted = __TS__ArraySome( -- 2645
			normalized, -- 2645
			function(____, message) return not message.success and message.interrupted == true end -- 2645
		) -- 2645
		return { -- 2646
			success = false, -- 2647
			message = interrupted and "Build canceled." or ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 2648
			total = total, -- 2649
			passed = passed, -- 2650
			failed = failed, -- 2651
			messages = normalized, -- 2652
			interrupted = interrupted or nil -- 2653
		} -- 2653
	end -- 2653
	return { -- 2656
		success = true, -- 2657
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 2658
		total = total, -- 2659
		passed = passed, -- 2660
		failed = 0, -- 2661
		messages = normalized -- 2662
	} -- 2662
end -- 2634
function ____exports.build(req) -- 2666
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2666
		local ____this_49 -- 2666
		____this_49 = req -- 2667
		local ____opt_48 = ____this_49.isCancelled -- 2667
		if (____opt_48 and ____opt_48(____this_49)) == true then -- 2667
			return ____awaiter_resolve(nil, {success = false, message = "Build canceled.", interrupted = true}) -- 2667
		end -- 2667
		local targetRel = req.path or "" -- 2670
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2671
		if not target then -- 2671
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2671
		end -- 2671
		if not Content:exist(target) then -- 2671
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2671
		end -- 2671
		local messages = {} -- 2678
		if not Content:isdir(target) then -- 2678
			local kind = getSupportedBuildKind(target) -- 2680
			if not kind then -- 2680
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2680
			end -- 2680
			if kind == "ts" then -- 2680
				local content = Content:load(target) -- 2685
				if content == nil then -- 2685
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2685
				end -- 2685
				if isTiledEditorContent(content) then -- 2685
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2690
					return ____awaiter_resolve( -- 2690
						nil, -- 2690
						finalizeBuildResult(req.workDir, messages) -- 2691
					) -- 2691
				end -- 2691
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2691
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2691
				end -- 2691
				if not isDtsFile(target) then -- 2691
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir, req.isCancelled)) -- 2697
				end -- 2697
			else -- 2697
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2700
			end -- 2700
			Log( -- 2702
				"Info", -- 2702
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2702
			) -- 2702
			return ____awaiter_resolve( -- 2702
				nil, -- 2702
				finalizeBuildResult(req.workDir, messages) -- 2703
			) -- 2703
		end -- 2703
		local listResult = ____exports.listFiles({ -- 2705
			workDir = req.workDir, -- 2706
			path = targetRel, -- 2707
			globs = __TS__ArrayMap( -- 2708
				codeExtensions, -- 2708
				function(____, e) return "**/*" .. e end -- 2708
			), -- 2708
			maxEntries = 10000 -- 2709
		}) -- 2709
		local relFiles = listResult.success and listResult.files or ({}) -- 2712
		local tsFileData = {} -- 2713
		local buildQueue = {} -- 2714
		for ____, rel in ipairs(relFiles) do -- 2715
			do -- 2715
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2716
				local kind = getSupportedBuildKind(file) -- 2717
				if not kind then -- 2717
					goto __continue586 -- 2718
				end -- 2718
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2719
				if kind ~= "ts" then -- 2719
					goto __continue586 -- 2721
				end -- 2721
				local content = Content:load(file) -- 2723
				if content == nil then -- 2723
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2725
					goto __continue586 -- 2726
				end -- 2726
				if isTiledEditorContent(content) then -- 2726
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2729
					goto __continue586 -- 2730
				end -- 2730
				tsFileData[file] = content -- 2732
			end -- 2732
			::__continue586:: -- 2732
		end -- 2732
		do -- 2732
			local i = 0 -- 2734
			while i < #buildQueue do -- 2734
				do -- 2734
					local ____this_51 -- 2734
					____this_51 = req -- 2735
					local ____opt_50 = ____this_51.isCancelled -- 2735
					if (____opt_50 and ____opt_50(____this_51)) == true then -- 2735
						return ____awaiter_resolve(nil, {success = false, message = "Build canceled.", messages = messages, interrupted = true}) -- 2735
					end -- 2735
					local ____buildQueue_index_52 = buildQueue[i + 1] -- 2738
					local file = ____buildQueue_index_52.file -- 2738
					local kind = ____buildQueue_index_52.kind -- 2738
					if kind == "ts" then -- 2738
						local content = tsFileData[file] -- 2740
						if content == nil or isDtsFile(file) then -- 2740
							goto __continue593 -- 2742
						end -- 2742
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2742
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2745
							goto __continue593 -- 2746
						end -- 2746
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir, req.isCancelled)) -- 2748
						goto __continue593 -- 2749
					end -- 2749
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2751
				end -- 2751
				::__continue593:: -- 2751
				i = i + 1 -- 2734
			end -- 2734
		end -- 2734
		if #messages == 0 then -- 2734
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2754
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2754
		end -- 2754
		Log( -- 2757
			"Info", -- 2757
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2757
		) -- 2757
		return ____awaiter_resolve( -- 2757
			nil, -- 2757
			finalizeBuildResult(req.workDir, messages) -- 2758
		) -- 2758
	end) -- 2758
end -- 2666
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2761
local EXECUTE_COMMAND_ERROR_MAX = 4000 -- 2762
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 2763
local agentEntryRuntimeOwner = "" -- 2764
local function truncateCommandOutput(output) -- 2766
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2766
		return output -- 2767
	end -- 2767
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2768
end -- 2766
local function truncateCommandError(message) -- 2771
	if #message <= EXECUTE_COMMAND_ERROR_MAX then -- 2771
		return message -- 2772
	end -- 2772
	return __TS__StringSlice(message, 0, EXECUTE_COMMAND_ERROR_MAX) .. "\n... error message truncated ..." -- 2773
end -- 2771
local function executeLuaCommand(req) -- 2776
	local code = __TS__StringTrim(req.code or "") -- 2784
	if code == "" then -- 2784
		return __TS__Promise.resolve({ -- 2786
			success = false, -- 2786
			mode = "lua", -- 2786
			output = "", -- 2786
			message = "missing code", -- 2786
			phase = "validate" -- 2786
		}) -- 2786
	end -- 2786
	local output = {} -- 2788
	local entry = require("Script.Dev.Entry") -- 2789
	local ownsEntryRuntime = false -- 2790
	local contentAccessed = false -- 2791
	local refreshTreeCalled = false -- 2792
	local entryObjectBaseline = 0 -- 2793
	local entryLuaRefBaseline = 0 -- 2794
	local function acquireEntryRuntime() -- 2795
		if agentEntryRuntimeOwner ~= "" and agentEntryRuntimeOwner ~= req.operationId then -- 2795
			error("Dora entry runtime is busy with another Agent command") -- 2797
		end -- 2797
		agentEntryRuntimeOwner = req.operationId -- 2799
		ownsEntryRuntime = true -- 2800
	end -- 2795
	local function stopOwnedEntry() -- 2802
		if not ownsEntryRuntime then -- 2802
			return nil -- 2803
		end -- 2803
		local cleanupError -- 2804
		do -- 2804
			local function ____catch(e) -- 2804
				cleanupError = "failed to stop Agent test entry: " .. tostring(e) -- 2808
			end -- 2808
			local ____try, ____hasReturned = pcall(function() -- 2808
				entry.stop() -- 2806
			end) -- 2806
			if not ____try then -- 2806
				____catch(____hasReturned) -- 2806
			end -- 2806
		end -- 2806
		ownsEntryRuntime = false -- 2810
		if agentEntryRuntimeOwner == req.operationId then -- 2810
			agentEntryRuntimeOwner = "" -- 2812
		end -- 2812
		return cleanupError -- 2814
	end -- 2802
	local function startEntryWatchdog() -- 2816
		entryObjectBaseline = Dora.Object.count -- 2817
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 2818
	end -- 2816
	local function checkEntryWatchdog() -- 2820
		if not ownsEntryRuntime then -- 2820
			return nil -- 2821
		end -- 2821
		local objectCount = Dora.Object.count -- 2822
		local luaRefCount = Dora.Object.luaRefCount -- 2823
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 2824
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 2825
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 2826
		if not exceededTotal then -- 2826
			return nil -- 2829
		end -- 2829
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 2830
	end -- 2820
	local function normalizeEntryFile(value) -- 2834
		if not value or type(value) ~= "table" then -- 2834
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 2836
		end -- 2836
		local descriptor = value -- 2838
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 2839
		if relativeFile == "" then -- 2839
			relativeFile = "init" -- 2840
		end -- 2840
		if not isValidWorkspacePath(relativeFile) then -- 2840
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 2842
		end -- 2842
		local fileName = Path(req.workDir, relativeFile) -- 2844
		local ext = Path:getExt(fileName) -- 2845
		if ext ~= "" then -- 2845
			fileName = Path:replaceExt(fileName, "") -- 2846
		end -- 2846
		local luaFile = Path:replaceExt(fileName, "lua") -- 2847
		if not Content:exist(luaFile) then -- 2847
			error("Agent test entry was not built: " .. luaFile) -- 2849
		end -- 2849
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 2851
		return { -- 2852
			fileName = fileName, -- 2853
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 2854
		} -- 2854
	end -- 2834
	local function capturePrint(...) -- 2857
		local values = {...} -- 2857
		local parts = {} -- 2858
		do -- 2858
			local i = 0 -- 2859
			while i < #values do -- 2859
				parts[#parts + 1] = tostring(values[i + 1]) -- 2860
				i = i + 1 -- 2859
			end -- 2859
		end -- 2859
		output[#output + 1] = table.concat(parts, "\t") -- 2862
	end -- 2857
	local function refreshTree(path) -- 2864
		refreshTreeCalled = true -- 2865
		if path == nil then -- 2865
			return refreshProjectTree(req.workDir) -- 2867
		end -- 2867
		if type(path) ~= "string" then -- 2867
			error("refreshTree expects a project-relative file path string or no argument") -- 2870
		end -- 2870
		return refreshProjectTree(req.workDir, path) -- 2872
	end -- 2864
	local function resolveLuaContentPath(first, second) -- 2874
		local value = type(second) == "string" and second or first -- 2875
		if type(value) ~= "string" then -- 2875
			error("Content path must be a project-relative string") -- 2877
		end -- 2877
		local fullPath = resolveWorkspaceFilePath(req.workDir, value) -- 2879
		if not fullPath then -- 2879
			error("Content path must stay inside projectDir") -- 2881
		end -- 2881
		return fullPath -- 2883
	end -- 2874
	local scopedContent = { -- 2885
		exist = function(first, second) return Content:exist(resolveLuaContentPath(first, second)) end, -- 2886
		isdir = function(first, second) return Content:isdir(resolveLuaContentPath(first, second)) end, -- 2887
		getAttr = function(first, second) return Content:getAttr(resolveLuaContentPath(first, second)) end, -- 2888
		load = function(first, second) -- 2889
			local fullPath = resolveLuaContentPath(first, second) -- 2890
			local inspected = inspectReadableFile(fullPath) -- 2891
			if not inspected.success then -- 2891
				error(inspected.message or "file is not readable") -- 2892
			end -- 2892
			return Content:load(fullPath) -- 2893
		end -- 2889
	} -- 2889
	local blockedDoraGlobals = {Content = true, DB = true, HttpClient = true, HttpServer = true} -- 2896
	local env = setmetatable( -- 2902
		{ -- 2902
			projectDir = req.workDir, -- 2903
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 2904
				if type(moduleNameValue) ~= "string" then -- 2904
					error("requireProjectModule expects a project module name string") -- 2906
				end -- 2906
				local moduleName = __TS__StringTrim(moduleNameValue) -- 2908
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 2908
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 2910
				end -- 2910
				local reloadModules = {moduleName} -- 2912
				if reloadModulesValue ~= nil then -- 2912
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 2912
						error("requireProjectModule reloadModules must be an array of module names") -- 2915
					end -- 2915
					local items = reloadModulesValue -- 2917
					do -- 2917
						local i = 0 -- 2918
						while i < #items do -- 2918
							local item = items[i + 1] -- 2919
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 2919
								error("requireProjectModule reloadModules contains an invalid module name") -- 2921
							end -- 2921
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 2921
								reloadModules[#reloadModules + 1] = item -- 2923
							end -- 2923
							i = i + 1 -- 2918
						end -- 2918
					end -- 2918
				end -- 2918
				local luaPackage = _G.package -- 2926
				local previousPath = luaPackage.path -- 2930
				local previousSearchPaths = Content.searchPaths -- 2931
				local scopedSearchPaths = {req.workDir} -- 2932
				do -- 2932
					local i = 0 -- 2933
					while i < #previousSearchPaths do -- 2933
						local searchPath = previousSearchPaths[i + 1] -- 2934
						if searchPath ~= req.workDir then -- 2934
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 2935
						end -- 2935
						i = i + 1 -- 2933
					end -- 2933
				end -- 2933
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 2937
				Content.searchPaths = scopedSearchPaths -- 2938
				do -- 2938
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2938
						do -- 2938
							local i = 0 -- 2940
							while i < #reloadModules do -- 2940
								local reloadName = reloadModules[i + 1] -- 2941
								luaPackage.loaded[reloadName] = nil -- 2942
								luaPackage.loaded[table.concat( -- 2943
									__TS__StringSplit(reloadName, "/"), -- 2943
									"." -- 2943
								)] = nil -- 2943
								luaPackage.loaded[table.concat( -- 2944
									__TS__StringSplit(reloadName, "."), -- 2944
									"/" -- 2944
								)] = nil -- 2944
								i = i + 1 -- 2940
							end -- 2940
						end -- 2940
						return true, require(table.concat( -- 2946
							__TS__StringSplit(moduleName, "/"), -- 2946
							"." -- 2946
						)) -- 2946
					end) -- 2946
					do -- 2946
						Content.searchPaths = previousSearchPaths -- 2948
						luaPackage.path = previousPath -- 2949
					end -- 2949
					if not ____try then -- 2949
						error(____hasReturned, 0) -- 2949
					end -- 2949
					if ____try and ____hasReturned then -- 2949
						return ____returnValue -- 2939
					end -- 2939
				end -- 2939
			end, -- 2904
			print = capturePrint, -- 2952
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 2953
			enterEntryAsync = function(value) -- 2954
				local normalized = normalizeEntryFile(value) -- 2955
				acquireEntryRuntime() -- 2956
				entry.allClear() -- 2957
				startEntryWatchdog() -- 2958
				local success, message = entry.enterEntryAsync({ -- 2959
					entryName = normalized.entryName, -- 2960
					fileName = normalized.fileName, -- 2961
					workDir = req.workDir, -- 2962
					projectRoot = req.workDir, -- 2963
					runKind = "agent_test" -- 2964
				}) -- 2964
				return success, message -- 2966
			end, -- 2954
			stopEntry = function() -- 2968
				if not ownsEntryRuntime then -- 2968
					return false -- 2969
				end -- 2969
				return entry.stop() -- 2970
			end, -- 2968
			reportProgress = function(value, callbackValue) -- 2972
				local ____callbackValue_53 = callbackValue -- 2973
				if ____callbackValue_53 == nil then -- 2973
					____callbackValue_53 = value -- 2973
				end -- 2973
				local actualValue = ____callbackValue_53 -- 2973
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 2973
					return -- 2974
				end -- 2974
				local progress = actualValue -- 2975
				local amount = type(progress.progress) == "number" and math.min( -- 2976
					1, -- 2977
					math.max(0, progress.progress) -- 2977
				) or nil -- 2977
				req:onProgress({ -- 2979
					state = "running", -- 2980
					mode = "lua", -- 2981
					operationId = req.operationId, -- 2982
					progress = amount, -- 2983
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 2984
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 2985
				}) -- 2985
			end -- 2972
		}, -- 2972
		{__index = function(_table, key) -- 2988
			if key == "Content" then -- 2988
				contentAccessed = true -- 2991
				return scopedContent -- 2992
			end -- 2992
			if key == "refreshTree" then -- 2992
				return refreshTree -- 2995
			end -- 2995
			local name = tostring(key) -- 2997
			if blockedDoraGlobals[name] then -- 2997
				return nil -- 2998
			end -- 2998
			return Dora[name] -- 2999
		end} -- 2989
	) -- 2989
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 3002
	if not fn then -- 3002
		return __TS__Promise.resolve({ -- 3004
			success = false, -- 3005
			mode = "lua", -- 3006
			output = truncateCommandOutput(table.concat(output, "\n")), -- 3007
			message = truncateCommandError(toStr(compileErr)), -- 3008
			phase = "compile" -- 3009
		}) -- 3009
	end -- 3009
	return __TS__New( -- 3012
		__TS__Promise, -- 3012
		function(____, resolve) -- 3012
			local settled = false -- 3013
			local commandRoutine -- 3014
			local startedAt = App.runningTime -- 3015
			local onProgress = req.onProgress -- 3016
			local isCancelled = req.isCancelled -- 3017
			local function finish(result) -- 3018
				if settled then -- 3018
					return -- 3019
				end -- 3019
				settled = true -- 3020
				local cleanupError -- 3021
				if not result.success and (result.interrupted == true or result.phase == "timeout") then -- 3021
					do -- 3021
						local function ____catch(e) -- 3021
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 3026
						end -- 3026
						local ____try, ____hasReturned = pcall(function() -- 3026
							entry.allClear() -- 3024
						end) -- 3024
						if not ____try then -- 3024
							____catch(____hasReturned) -- 3024
						end -- 3024
					end -- 3024
				end -- 3024
				local entryCleanupError = stopOwnedEntry() -- 3029
				if cleanupError == nil then -- 3029
					cleanupError = entryCleanupError -- 3030
				end -- 3030
				if contentAccessed and not refreshTreeCalled and not refreshProjectTree(req.workDir) then -- 3030
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 3032
				end -- 3032
				if not result.success and cleanupError ~= nil then -- 3032
					result.cleanupError = cleanupError -- 3035
				elseif result.success and cleanupError ~= nil then -- 3035
					resolve(nil, { -- 3037
						success = false, -- 3038
						mode = "lua", -- 3039
						output = result.output, -- 3040
						message = cleanupError, -- 3041
						phase = "execute", -- 3042
						cleanupError = cleanupError -- 3043
					}) -- 3043
					return -- 3045
				end -- 3045
				resolve(nil, result) -- 3047
			end -- 3018
			if onProgress then -- 3018
				onProgress(nil, { -- 3050
					state = "pending", -- 3051
					mode = "lua", -- 3052
					operationId = req.operationId, -- 3053
					stage = "lua", -- 3054
					message = "Lua command pending" -- 3055
				}) -- 3055
			end -- 3055
			commandRoutine = once(function() -- 3058
				if settled then -- 3058
					return -- 3059
				end -- 3059
				if onProgress then -- 3059
					onProgress(nil, { -- 3061
						state = "running", -- 3062
						mode = "lua", -- 3063
						operationId = req.operationId, -- 3064
						stage = "lua", -- 3065
						message = "Lua command running" -- 3066
					}) -- 3066
				end -- 3066
				local previousGlobalPrint = _G.print -- 3069
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 3070
				local frameTimedOut = false -- 3071
				local watchdogMessage -- 3071
				_G.print = capturePrint -- 3072
				debug.sethook( -- 3073
					function() -- 3073
						if watchdogMessage == nil then -- 3073
							watchdogMessage = checkEntryWatchdog() -- 3074
						end -- 3074
						if watchdogMessage ~= nil then -- 3074
							error(watchdogMessage) -- 3075
						end -- 3075
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 3075
							frameTimedOut = true -- 3077
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 3078
						end -- 3078
					end, -- 3073
					"", -- 3080
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 3080
				) -- 3080
				local ok, runtimeErr = pcall(fn) -- 3081
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 3081
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 3083
				else -- 3083
					debug.sethook() -- 3089
				end -- 3089
				_G.print = previousGlobalPrint -- 3091
				if not ok then -- 3091
					local ____truncateCommandOutput_result_55 = truncateCommandOutput(table.concat(output, "\n")) -- 3096
					local ____temp_56 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 3097
					local ____temp_57 = frameTimedOut and "timeout" or "execute" -- 3098
					local ____temp_54 -- 3099
					if watchdogMessage ~= nil or frameTimedOut then -- 3099
						____temp_54 = true -- 3099
					else -- 3099
						____temp_54 = nil -- 3099
					end -- 3099
					finish({ -- 3093
						success = false, -- 3094
						mode = "lua", -- 3095
						output = ____truncateCommandOutput_result_55, -- 3096
						message = ____temp_56, -- 3097
						phase = ____temp_57, -- 3098
						interrupted = ____temp_54 -- 3099
					}) -- 3099
					return -- 3101
				end -- 3101
				finish({ -- 3103
					success = true, -- 3103
					mode = "lua", -- 3103
					output = truncateCommandOutput(table.concat(output, "\n")) -- 3103
				}) -- 3103
			end) -- 3058
			Director.systemScheduler:schedule(function() -- 3105
				if settled then -- 3105
					return true -- 3106
				end -- 3106
				local watchdogMessage = checkEntryWatchdog() -- 3107
				if watchdogMessage ~= nil then -- 3107
					finish({ -- 3109
						success = false, -- 3110
						mode = "lua", -- 3111
						output = truncateCommandOutput(table.concat(output, "\n")), -- 3112
						message = watchdogMessage, -- 3113
						phase = "execute", -- 3114
						interrupted = true -- 3115
					}) -- 3115
					return true -- 3117
				end -- 3117
				if isCancelled and isCancelled(nil) then -- 3117
					finish({ -- 3120
						success = false, -- 3121
						mode = "lua", -- 3122
						output = truncateCommandOutput(table.concat(output, "\n")), -- 3123
						message = "Lua command canceled", -- 3124
						phase = "execute", -- 3125
						interrupted = true -- 3126
					}) -- 3126
					return true -- 3128
				end -- 3128
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 3128
					finish({ -- 3131
						success = false, -- 3132
						mode = "lua", -- 3133
						output = truncateCommandOutput(table.concat(output, "\n")), -- 3134
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 3135
						phase = "timeout" -- 3136
					}) -- 3136
					return true -- 3138
				end -- 3138
				if commandRoutine == nil then -- 3138
					finish({ -- 3141
						success = false, -- 3142
						mode = "lua", -- 3143
						output = truncateCommandOutput(table.concat(output, "\n")), -- 3144
						message = "Lua command coroutine is unavailable", -- 3145
						phase = "execute" -- 3146
					}) -- 3146
					return true -- 3148
				end -- 3148
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 3150
				if not resumeSuccess then -- 3150
					finish({ -- 3152
						success = false, -- 3153
						mode = "lua", -- 3154
						output = truncateCommandOutput(table.concat(output, "\n")), -- 3155
						message = truncateCommandError(toStr(resumeResult)), -- 3156
						phase = "execute" -- 3157
					}) -- 3157
					return true -- 3159
				end -- 3159
				return settled or resumeResult == true -- 3161
			end) -- 3105
		end -- 3012
	) -- 3012
end -- 2776
local function formatGitStatusOutput(status) -- 3166
	if not status then -- 3166
		return "" -- 3167
	end -- 3167
	local lines = {} -- 3168
	local state = toStr(status.state) -- 3169
	local kind = toStr(status.kind) -- 3170
	local message = toStr(status.message) -- 3171
	local errorMessage = toStr(status.error) -- 3172
	if kind ~= "" or state ~= "" then -- 3172
		lines[#lines + 1] = table.concat( -- 3174
			__TS__ArrayFilter( -- 3174
				{kind, state}, -- 3174
				function(____, item) return item ~= "" end -- 3174
			), -- 3174
			": " -- 3174
		) -- 3174
	end -- 3174
	if message ~= "" then -- 3174
		lines[#lines + 1] = message -- 3176
	end -- 3176
	if errorMessage ~= "" then -- 3176
		lines[#lines + 1] = errorMessage -- 3177
	end -- 3177
	local data = status.data -- 3178
	if data ~= nil then -- 3178
		local dataText = encodeJSON(data) -- 3180
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 3181
	end -- 3181
	return truncateCommandOutput(table.concat(lines, "\n")) -- 3183
end -- 3166
local function emitGitProgress(mode, operationId, onProgress, status) -- 3186
	if not onProgress then -- 3186
		return -- 3192
	end -- 3192
	local progress = type(status.progress) == "number" and status.progress or nil -- 3193
	local kind = toStr(status.kind) -- 3194
	local message = toStr(status.message) -- 3195
	local state = toStr(status.state) -- 3196
	local jobId = type(status.id) == "number" and status.id or nil -- 3197
	onProgress({ -- 3198
		state = "running", -- 3199
		mode = mode, -- 3200
		operationId = operationId, -- 3201
		stage = kind ~= "" and kind or "git", -- 3202
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 3203
		progress = progress, -- 3204
		jobId = jobId, -- 3205
		gitState = state ~= "" and state or nil, -- 3206
		gitKind = kind ~= "" and kind or nil -- 3207
	}) -- 3207
end -- 3186
local function cloneGitToTarget(req) -- 3211
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3211
		local parsed = parseGitCloneCommand(req.command) -- 3219
		if parsed == nil then -- 3219
			return ____awaiter_resolve(nil, nil) -- 3219
		end -- 3219
		if not parsed.success then -- 3219
			return ____awaiter_resolve(nil, { -- 3219
				success = false, -- 3222
				mode = "git", -- 3222
				output = "", -- 3222
				message = parsed.message, -- 3222
				phase = "validate" -- 3222
			}) -- 3222
		end -- 3222
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 3224
		if not target then -- 3224
			return ____awaiter_resolve(nil, { -- 3224
				success = false, -- 3226
				mode = "git", -- 3226
				output = "", -- 3226
				message = "invalid clone target path", -- 3226
				phase = "validate" -- 3226
			}) -- 3226
		end -- 3226
		if Content:exist(target) then -- 3226
			return ____awaiter_resolve(nil, { -- 3226
				success = false, -- 3229
				mode = "git", -- 3229
				output = "", -- 3229
				message = "target already exists", -- 3229
				phase = "validate" -- 3229
			}) -- 3229
		end -- 3229
		local targetParent = Path:getPath(target) -- 3231
		if not ensureDirPath(targetParent) then -- 3231
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 3231
		end -- 3231
		local tempRoot = getAgentDownloadTempRoot() -- 3235
		if not ensureDirPath(tempRoot) then -- 3235
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 3235
		end -- 3235
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 3239
		Content:remove(tempPath) -- 3240
		local depth = parsed.depth or "1" -- 3241
		local ____array_58 = __TS__SparseArrayNew( -- 3241
			"clone", -- 3243
			quoteGitArg(parsed.url), -- 3244
			quoteGitArg(Path:getFilename(tempPath)), -- 3245
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 3246
				"-b", -- 3246
				quoteGitArg(parsed.ref) -- 3246
			}) or ({})) -- 3246
		) -- 3246
		__TS__SparseArrayPush( -- 3246
			____array_58, -- 3246
			table.unpack(depth ~= "" and ({ -- 3247
				"--depth",
				quoteGitArg(depth) -- 3247
			}) or ({})) -- 3247
		) -- 3247
		local command = table.concat( -- 3242
			{__TS__SparseArraySpread(____array_58)}, -- 3242
			" " -- 3248
		) -- 3248
		local ____this_60 -- 3248
		____this_60 = req -- 3249
		local ____opt_59 = ____this_60.onProgress -- 3249
		if ____opt_59 ~= nil then -- 3249
			____opt_59(____this_60, { -- 3249
				state = "pending", -- 3250
				mode = "git", -- 3251
				operationId = req.operationId, -- 3252
				stage = "clone", -- 3253
				message = "clone pending", -- 3254
				progress = 0 -- 3255
			}) -- 3255
		end -- 3255
		local gitRes = __TS__Await(runGitAndWait( -- 3257
			tempRoot, -- 3258
			command, -- 3259
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 3260
			req.isCancelled, -- 3261
			req.timeoutSeconds -- 3262
		)) -- 3262
		if not gitRes.success then -- 3262
			local cleanupError = cleanupPath(tempPath) -- 3265
			local ____formatGitStatusOutput_result_64 = formatGitStatusOutput(gitRes.status) -- 3269
			local ____temp_65 = gitRes.message or "git clone failed" -- 3270
			local ____gitRes_interrupted_63 = gitRes.interrupted -- 3271
			if not ____gitRes_interrupted_63 then -- 3271
				local ____this_62 -- 3271
				____this_62 = req -- 3271
				local ____opt_61 = ____this_62.isCancelled -- 3271
				____gitRes_interrupted_63 = (____opt_61 and ____opt_61(____this_62)) == true -- 3271
			end -- 3271
			return ____awaiter_resolve(nil, { -- 3271
				success = false, -- 3267
				mode = "git", -- 3268
				output = ____formatGitStatusOutput_result_64, -- 3269
				message = ____temp_65, -- 3270
				interrupted = ____gitRes_interrupted_63, -- 3271
				cleanupError = cleanupError -- 3272
			}) -- 3272
		end -- 3272
		if not Content:move(tempPath, target) then -- 3272
			local cleanupError = cleanupPath(tempPath) -- 3276
			return ____awaiter_resolve( -- 3276
				nil, -- 3276
				{ -- 3277
					success = false, -- 3277
					mode = "git", -- 3277
					output = formatGitStatusOutput(gitRes.status), -- 3277
					message = "failed to move cloned repository into target path", -- 3277
					cleanupError = cleanupError -- 3277
				} -- 3277
			) -- 3277
		end -- 3277
		if not refreshProjectTree(req.workDir) then -- 3277
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 3280
		end -- 3280
		local commit = getGitHeadCommit(target) -- 3282
		local output = table.concat( -- 3283
			__TS__ArrayFilter( -- 3283
				{ -- 3283
					formatGitStatusOutput(gitRes.status), -- 3284
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 3284
					commit ~= nil and "commit " .. commit or "" -- 3286
				}, -- 3286
				function(____, item) return item ~= "" end -- 3287
			), -- 3287
			"\n" -- 3287
		) -- 3287
		return ____awaiter_resolve( -- 3287
			nil, -- 3287
			{ -- 3288
				success = true, -- 3288
				mode = "git", -- 3288
				output = truncateCommandOutput(output) -- 3288
			} -- 3288
		) -- 3288
	end) -- 3288
end -- 3211
local function loadGitProfile() -- 3291
	local rows -- 3292
	do -- 3292
		local function ____catch() -- 3292
			return true, nil -- 3296
		end -- 3296
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 3296
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 3294
		end) -- 3294
		if not ____try then -- 3294
			____hasReturned, ____returnValue = ____catch() -- 3294
		end -- 3294
		if ____hasReturned then -- 3294
			return ____returnValue -- 3293
		end -- 3293
	end -- 3293
	if not rows or not rows[1] then -- 3293
		return nil -- 3298
	end -- 3298
	local name = toStr(rows[1][1]) -- 3299
	local email = toStr(rows[1][2]) -- 3300
	if name == "" and email == "" then -- 3300
		return nil -- 3301
	end -- 3301
	return {name = name, email = email} -- 3302
end -- 3291
local function applyGitProfileToCommit(command) -- 3305
	local args = shellSplit(command) -- 3306
	if args[1] ~= "commit" then -- 3306
		return command -- 3307
	end -- 3307
	local hasName = false -- 3308
	local hasEmail = false -- 3309
	for ____, arg in ipairs(args) do -- 3310
		if arg == "--author-name" then
			hasName = true -- 3311
		end -- 3311
		if arg == "--author-email" then
			hasEmail = true -- 3312
		end -- 3312
	end -- 3312
	if hasName and hasEmail then -- 3312
		return command -- 3314
	end -- 3314
	local profile = loadGitProfile() -- 3315
	if not profile then -- 3315
		return command -- 3316
	end -- 3316
	local additions = {} -- 3317
	if not hasName and profile.name ~= "" then -- 3317
		__TS__ArrayPush( -- 3319
			additions, -- 3319
			"--author-name",
			quoteGitArg(profile.name) -- 3319
		) -- 3319
	end -- 3319
	if not hasEmail and profile.email ~= "" then -- 3319
		__TS__ArrayPush( -- 3322
			additions, -- 3322
			"--author-email",
			quoteGitArg(profile.email) -- 3322
		) -- 3322
	end -- 3322
	if #additions == 0 then -- 3322
		return command -- 3324
	end -- 3324
	return (command .. " ") .. table.concat(additions, " ") -- 3325
end -- 3305
local function executeGitCommand(req) -- 3328
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3328
		local command = normalizeGitCommand(req.command or "") -- 3337
		if command == "" then -- 3337
			return ____awaiter_resolve(nil, { -- 3337
				success = false, -- 3339
				mode = "git", -- 3339
				output = "", -- 3339
				message = "missing command", -- 3339
				phase = "validate" -- 3339
			}) -- 3339
		end -- 3339
		local commandArgs = shellSplit(command) -- 3341
		if #commandArgs == 0 or __TS__StringStartsWith(commandArgs[1], "-") then -- 3341
			return ____awaiter_resolve(nil, { -- 3341
				success = false, -- 3344
				mode = "git", -- 3345
				output = "", -- 3346
				message = "top-level Git options such as -C, --git-dir, and --work-tree are not supported; use the project-relative cwd parameter",
				phase = "validate" -- 3348
			}) -- 3348
		end -- 3348
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 3351
			workDir = req.workDir, -- 3352
			command = command, -- 3353
			operationId = req.operationId, -- 3354
			timeoutSeconds = req.timeoutSeconds, -- 3355
			onProgress = req.onProgress, -- 3356
			isCancelled = req.isCancelled -- 3357
		})) -- 3357
		if cloneResult ~= nil then -- 3357
			return ____awaiter_resolve(nil, cloneResult) -- 3357
		end -- 3357
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 3360
		if not cwd.success then -- 3360
			return ____awaiter_resolve(nil, { -- 3360
				success = false, -- 3362
				mode = "git", -- 3362
				output = "", -- 3362
				cwd = req.cwd, -- 3362
				message = cwd.message, -- 3362
				phase = "validate" -- 3362
			}) -- 3362
		end -- 3362
		command = applyGitProfileToCommit(command) -- 3364
		local ____this_67 -- 3364
		____this_67 = req -- 3365
		local ____opt_66 = ____this_67.onProgress -- 3365
		if ____opt_66 ~= nil then -- 3365
			____opt_66(____this_67, { -- 3365
				state = "pending", -- 3366
				mode = "git", -- 3367
				operationId = req.operationId, -- 3368
				stage = "git", -- 3369
				message = "git command pending", -- 3370
				progress = 0 -- 3371
			}) -- 3371
		end -- 3371
		local gitRes = __TS__Await(runGitAndWait( -- 3373
			cwd.path, -- 3374
			command, -- 3375
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 3376
			function() -- 3377
				local ____this_69 -- 3377
				____this_69 = req -- 3377
				local ____opt_68 = ____this_69.isCancelled -- 3377
				return (____opt_68 and ____opt_68(____this_69)) == true -- 3377
			end, -- 3377
			req.timeoutSeconds -- 3378
		)) -- 3378
		local output = formatGitStatusOutput(gitRes.status) -- 3380
		if not gitRes.success then -- 3380
			local ____output_73 = output -- 3385
			local ____cwd_relative_74 = cwd.relative -- 3386
			local ____temp_75 = gitRes.message or "git command failed" -- 3387
			local ____gitRes_interrupted_72 = gitRes.interrupted -- 3388
			if not ____gitRes_interrupted_72 then -- 3388
				local ____this_71 -- 3388
				____this_71 = req -- 3388
				local ____opt_70 = ____this_71.isCancelled -- 3388
				____gitRes_interrupted_72 = (____opt_70 and ____opt_70(____this_71)) == true -- 3388
			end -- 3388
			return ____awaiter_resolve(nil, { -- 3388
				success = false, -- 3383
				mode = "git", -- 3384
				output = ____output_73, -- 3385
				cwd = ____cwd_relative_74, -- 3386
				message = ____temp_75, -- 3387
				interrupted = ____gitRes_interrupted_72 -- 3388
			}) -- 3388
		end -- 3388
		if not refreshProjectTree(req.workDir) then -- 3388
			Log("Warn", (("[execute_command] failed to refresh Web IDE tree after Git command workDir=" .. req.workDir) .. " cwd=") .. cwd.relative) -- 3392
		end -- 3392
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 3392
	end) -- 3392
end -- 3328
function ____exports.executeCommand(req) -- 3397
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3397
		local mode = req.mode -- 3407
		if mode ~= "lua" and mode ~= "git" then -- 3407
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 3407
		end -- 3407
		if mode == "lua" then -- 3407
			return ____awaiter_resolve( -- 3407
				nil, -- 3407
				executeLuaCommand({ -- 3412
					workDir = req.workDir, -- 3413
					code = req.code or "", -- 3414
					timeoutSeconds = math.max( -- 3415
						1, -- 3415
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 3415
					), -- 3415
					operationId = createOperationId(), -- 3416
					onProgress = req.onProgress, -- 3417
					isCancelled = req.isCancelled -- 3418
				}) -- 3418
			) -- 3418
		end -- 3418
		local operationId = createOperationId() -- 3421
		return ____awaiter_resolve( -- 3421
			nil, -- 3421
			executeGitCommand({ -- 3422
				workDir = req.workDir, -- 3423
				command = req.command or "", -- 3424
				cwd = req.cwd, -- 3425
				timeoutSeconds = math.max( -- 3426
					1, -- 3426
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 3426
				), -- 3426
				operationId = operationId, -- 3427
				onProgress = req.onProgress, -- 3428
				isCancelled = req.isCancelled -- 3429
			}) -- 3429
		) -- 3429
	end) -- 3429
end -- 3397
function ____exports.fetchUrl(req) -- 3433
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3433
		local mode = "download" -- 3440
		local url = __TS__StringTrim(req.url or "") -- 3441
		local targetRel = __TS__StringTrim(req.target or "") -- 3442
		if not isHttpUrl(url) then -- 3442
			return ____awaiter_resolve(nil, { -- 3442
				success = false, -- 3444
				state = "failed", -- 3444
				mode = mode, -- 3444
				target = targetRel, -- 3444
				message = "fetch_url only supports http:// and https:// URLs" -- 3444
			}) -- 3444
		end -- 3444
		if not isSafePublicHttpUrl(url) then -- 3444
			return ____awaiter_resolve(nil, { -- 3444
				success = false, -- 3447
				state = "failed", -- 3447
				mode = mode, -- 3447
				target = targetRel, -- 3447
				message = "fetch_url rejects local, private, metadata, and literal-IP destinations" -- 3447
			}) -- 3447
		end -- 3447
		if targetRel == "" then -- 3447
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 3447
		end -- 3447
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 3452
		if not target then -- 3452
			return ____awaiter_resolve(nil, { -- 3452
				success = false, -- 3454
				state = "failed", -- 3454
				mode = mode, -- 3454
				target = targetRel, -- 3454
				message = "invalid target path" -- 3454
			}) -- 3454
		end -- 3454
		if Content:exist(target) then -- 3454
			return ____awaiter_resolve(nil, { -- 3454
				success = false, -- 3457
				state = "failed", -- 3457
				mode = mode, -- 3457
				target = targetRel, -- 3457
				message = "target already exists" -- 3457
			}) -- 3457
		end -- 3457
		local operationId = createOperationId() -- 3459
		local tempRoot = getAgentDownloadTempRoot() -- 3460
		if not ensureDirPath(tempRoot) then -- 3460
			return ____awaiter_resolve(nil, { -- 3460
				success = false, -- 3462
				state = "failed", -- 3462
				mode = mode, -- 3462
				target = targetRel, -- 3462
				message = "failed to create agent download temp directory" -- 3462
			}) -- 3462
		end -- 3462
		local tempPath = Path(tempRoot, operationId .. ".download") -- 3464
		Content:remove(tempPath) -- 3465
		local function emitProgress(progress) -- 3466
			if not req.onProgress then -- 3466
				return -- 3467
			end -- 3467
			req:onProgress(__TS__ObjectAssign({ -- 3468
				state = "running", -- 3469
				mode = mode, -- 3470
				operationId = operationId, -- 3471
				target = targetRel, -- 3472
				tempPath = tempPath -- 3473
			}, progress)) -- 3473
		end -- 3466
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 3477
		local function interrupted() -- 3482
			local ____this_77 -- 3482
			____this_77 = req -- 3482
			local ____opt_76 = ____this_77.isCancelled -- 3482
			return (____opt_76 and ____opt_76(____this_77)) == true -- 3482
		end -- 3482
		if not ensureDirForFile(tempPath) then -- 3482
			return ____awaiter_resolve(nil, { -- 3482
				success = false, -- 3484
				state = "failed", -- 3484
				mode = mode, -- 3484
				target = targetRel, -- 3484
				message = "failed to create temporary file directory" -- 3484
			}) -- 3484
		end -- 3484
		local downloadRes = __TS__Await(downloadFile({ -- 3486
			url = url, -- 3487
			tempPath = tempPath, -- 3488
			timeout = 600, -- 3489
			isCancelled = interrupted, -- 3490
			onProgress = function(____, current, total) -- 3491
				local totalNumber = type(total) == "number" and total or 0 -- 3492
				emitProgress({ -- 3493
					stage = "download", -- 3494
					message = "downloading", -- 3495
					current = current, -- 3496
					total = total, -- 3497
					progress = totalNumber > 0 and current / totalNumber or nil -- 3498
				}) -- 3498
			end -- 3491
		})) -- 3491
		if not downloadRes.success then -- 3491
			local cleanupError = cleanupPath(tempPath) -- 3503
			return ____awaiter_resolve( -- 3503
				nil, -- 3503
				{ -- 3504
					success = false, -- 3505
					state = "failed", -- 3506
					mode = mode, -- 3507
					target = targetRel, -- 3508
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 3509
					interrupted = downloadRes.interrupted or interrupted(), -- 3510
					cleanupError = cleanupError -- 3511
				} -- 3511
			) -- 3511
		end -- 3511
		if not ensureDirForFile(target) then -- 3511
			local cleanupError = cleanupPath(tempPath) -- 3515
			return ____awaiter_resolve(nil, { -- 3515
				success = false, -- 3516
				state = "failed", -- 3516
				mode = mode, -- 3516
				target = targetRel, -- 3516
				message = "failed to create target directory", -- 3516
				cleanupError = cleanupError -- 3516
			}) -- 3516
		end -- 3516
		if not Content:move(tempPath, target) then -- 3516
			local cleanupError = cleanupPath(tempPath) -- 3519
			return ____awaiter_resolve(nil, { -- 3519
				success = false, -- 3520
				state = "failed", -- 3520
				mode = mode, -- 3520
				target = targetRel, -- 3520
				message = "failed to move downloaded file into target path", -- 3520
				cleanupError = cleanupError -- 3520
			}) -- 3520
		end -- 3520
		local bytesWritten = downloadRes.bytesWritten -- 3522
		local ____try = __TS__AsyncAwaiter(function() -- 3522
			local size = Content:getAttr(target) -- 3524
			if bytesWritten == nil or bytesWritten <= 0 then -- 3524
				bytesWritten = type(size) == "number" and size or nil -- 3526
			end -- 3526
		end) -- 3526
		____try = ____try.catch( -- 3526
			____try, -- 3526
			function(____, _) -- 3526
				return __TS__AsyncAwaiter(function() -- 3526
				end) -- 3526
			end -- 3526
		) -- 3526
		__TS__Await(____try) -- 3523
		if bytesWritten == nil or bytesWritten <= 0 then -- 3523
			local ____try = __TS__AsyncAwaiter(function() -- 3523
				local loaded = Content:load(target) -- 3533
				if type(loaded) == "string" then -- 3533
					bytesWritten = #loaded -- 3535
				end -- 3535
			end) -- 3535
			____try = ____try.catch( -- 3535
				____try, -- 3535
				function(____, _) -- 3535
					return __TS__AsyncAwaiter(function() -- 3535
					end) -- 3535
				end -- 3535
			) -- 3535
			__TS__Await(____try) -- 3532
		end -- 3532
		if not syncDownloadedFileToWebIDE(target) then -- 3532
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 3542
		end -- 3542
		return ____awaiter_resolve(nil, { -- 3542
			success = true, -- 3544
			state = "done", -- 3544
			mode = mode, -- 3544
			target = targetRel, -- 3544
			bytesWritten = bytesWritten -- 3544
		}) -- 3544
	end) -- 3544
end -- 3433
return ____exports -- 3433