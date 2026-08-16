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
		local requestedPath = __TS__StringTrim(req.path or "") -- 2115
		local isVirtualDoc = __TS__StringStartsWith(requestedPath, AGENT_DORA_DOC_PREFIX) -- 2116
		local ____isVirtualDoc_30 -- 2117
		if isVirtualDoc then -- 2117
			____isVirtualDoc_30 = resolveAgentDoraDocFilePath(requestedPath, req.docLanguage or "en") -- 2118
		else -- 2118
			____isVirtualDoc_30 = nil -- 2119
		end -- 2119
		local virtualDocPath = ____isVirtualDoc_30 -- 2117
		if isVirtualDoc and not virtualDocPath then -- 2117
			return ____awaiter_resolve(nil, {success = false, message = "virtual document not found or outside its documentation scope"}) -- 2117
		end -- 2117
		local resolvedPath = virtualDocPath or resolveWorkspaceSearchPath(req.workDir, requestedPath) -- 2123
		if not resolvedPath then -- 2123
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2123
		end -- 2123
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 2127
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 2128
		if not searchRoot then -- 2128
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2128
		end -- 2128
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 2128
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2128
		end -- 2128
		local patterns = splitSearchPatterns(req.pattern) -- 2135
		if #patterns == 0 then -- 2135
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2135
		end -- 2135
		return ____awaiter_resolve( -- 2135
			nil, -- 2135
			__TS__New( -- 2139
				__TS__Promise, -- 2139
				function(____, resolve) -- 2139
					Director.systemScheduler:schedule(once(function() -- 2140
						do -- 2140
							local function ____catch(e) -- 2140
								resolve( -- 2184
									nil, -- 2184
									{ -- 2184
										success = false, -- 2184
										message = tostring(e) -- 2184
									} -- 2184
								) -- 2184
							end -- 2184
							local ____try, ____hasReturned = pcall(function() -- 2184
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 2142
								local allResults = {} -- 2145
								do -- 2145
									local i = 0 -- 2146
									while i < #patterns do -- 2146
										local ____Content_35 = Content -- 2147
										local ____Content_searchFilesAsync_36 = Content.searchFilesAsync -- 2147
										local ____patterns_index_34 = patterns[i + 1] -- 2152
										local ____req_useRegex_31 = req.useRegex -- 2153
										if ____req_useRegex_31 == nil then -- 2153
											____req_useRegex_31 = false -- 2153
										end -- 2153
										local ____req_caseSensitive_32 = req.caseSensitive -- 2154
										if ____req_caseSensitive_32 == nil then -- 2154
											____req_caseSensitive_32 = false -- 2154
										end -- 2154
										local ____req_includeContent_33 = req.includeContent -- 2155
										if ____req_includeContent_33 == nil then -- 2155
											____req_includeContent_33 = true -- 2155
										end -- 2155
										allResults[#allResults + 1] = ____Content_searchFilesAsync_36( -- 2147
											____Content_35, -- 2147
											searchRoot, -- 2148
											codeExtensions, -- 2149
											extensionLevels, -- 2150
											searchGlobs, -- 2151
											____patterns_index_34, -- 2152
											____req_useRegex_31, -- 2153
											____req_caseSensitive_32, -- 2154
											____req_includeContent_33, -- 2155
											req.contentWindow or 120 -- 2156
										) -- 2156
										i = i + 1 -- 2146
									end -- 2146
								end -- 2146
								local results = mergeSearchFileResultsUnique(allResults) -- 2159
								local totalResults = #results -- 2160
								local limit = math.max( -- 2161
									1, -- 2161
									math.floor(req.limit or 20) -- 2161
								) -- 2161
								local offset = math.max( -- 2162
									0, -- 2162
									math.floor(req.offset or 0) -- 2162
								) -- 2162
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 2163
								local nextOffset = offset + #paged -- 2164
								local hasMore = nextOffset < totalResults -- 2165
								local truncated = offset > 0 or hasMore -- 2166
								local relativeResults = virtualDocPath and __TS__ArrayMap( -- 2167
									paged, -- 2168
									function(____, row) return __TS__ObjectAssign({}, row, {file = requestedPath}) end -- 2168
								) or toWorkspaceRelativeSearchResults(req.workDir, paged) -- 2168
								local groupByFile = req.groupByFile == true -- 2170
								resolve( -- 2171
									nil, -- 2171
									{ -- 2171
										success = true, -- 2172
										results = relativeResults, -- 2173
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 2174
										totalResults = totalResults, -- 2175
										truncated = truncated, -- 2176
										limit = limit, -- 2177
										offset = offset, -- 2178
										nextOffset = nextOffset, -- 2179
										hasMore = hasMore, -- 2180
										groupByFile = groupByFile -- 2181
									} -- 2181
								) -- 2181
							end) -- 2181
							if not ____try then -- 2181
								____catch(____hasReturned) -- 2181
							end -- 2181
						end -- 2181
					end)) -- 2140
				end -- 2139
			) -- 2139
		) -- 2139
	end) -- 2139
end -- 2101
function ____exports.searchDoraDoc(req) -- 2190
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2190
		local pattern = __TS__StringTrim(req.pattern or "") -- 2201
		if pattern == "" then -- 2201
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2201
		end -- 2201
		local patterns = splitSearchPatterns(pattern) -- 2203
		if #patterns == 0 then -- 2203
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 2203
		end -- 2203
		local docType = req.docType or "dora-api" -- 2205
		local target = getDoraDocSearchTarget(docType, req.docLanguage, req.programmingLanguage) -- 2206
		local docRoot = target.root -- 2207
		local resultBaseRoot = getDoraDocResultBaseRoot(docType, req.docLanguage) -- 2208
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 2208
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 2208
		end -- 2208
		local exts = target.exts -- 2212
		local dotExts = __TS__ArrayMap( -- 2213
			exts, -- 2213
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 2213
		) -- 2213
		local globs = target.globs -- 2214
		local limit = math.max( -- 2215
			1, -- 2215
			math.floor(req.limit or 10) -- 2215
		) -- 2215
		return ____awaiter_resolve( -- 2215
			nil, -- 2215
			__TS__New( -- 2217
				__TS__Promise, -- 2217
				function(____, resolve) -- 2217
					Director.systemScheduler:schedule(once(function() -- 2218
						do -- 2218
							local function ____catch(e) -- 2218
								resolve( -- 2298
									nil, -- 2298
									{ -- 2298
										success = false, -- 2298
										message = tostring(e) -- 2298
									} -- 2298
								) -- 2298
							end -- 2298
							local ____try, ____hasReturned = pcall(function() -- 2298
								local allHits = {} -- 2220
								do -- 2220
									local p = 0 -- 2221
									while p < #patterns do -- 2221
										local ____Content_41 = Content -- 2222
										local ____Content_searchFilesAsync_42 = Content.searchFilesAsync -- 2222
										local ____array_40 = __TS__SparseArrayNew( -- 2222
											docRoot, -- 2223
											dotExts, -- 2224
											{}, -- 2225
											ensureSafeSearchGlobs(globs), -- 2226
											patterns[p + 1] -- 2227
										) -- 2227
										local ____req_useRegex_37 = req.useRegex -- 2228
										if ____req_useRegex_37 == nil then -- 2228
											____req_useRegex_37 = false -- 2228
										end -- 2228
										__TS__SparseArrayPush(____array_40, ____req_useRegex_37) -- 2228
										local ____req_caseSensitive_38 = req.caseSensitive -- 2229
										if ____req_caseSensitive_38 == nil then -- 2229
											____req_caseSensitive_38 = false -- 2229
										end -- 2229
										__TS__SparseArrayPush(____array_40, ____req_caseSensitive_38) -- 2229
										local ____req_includeContent_39 = req.includeContent -- 2230
										if ____req_includeContent_39 == nil then -- 2230
											____req_includeContent_39 = true -- 2230
										end -- 2230
										__TS__SparseArrayPush(____array_40, ____req_includeContent_39, req.contentWindow or 80) -- 2230
										local raw = ____Content_searchFilesAsync_42( -- 2222
											____Content_41, -- 2222
											__TS__SparseArraySpread(____array_40) -- 2222
										) -- 2222
										local hits = {} -- 2233
										do -- 2233
											local i = 0 -- 2234
											while i < #raw do -- 2234
												do -- 2234
													local row = raw[i + 1] -- 2235
													local file = toDocRelativePath(resultBaseRoot, row.file, docType) -- 2236
													if file == "" then -- 2236
														goto __continue481 -- 2237
													end -- 2237
													hits[#hits + 1] = { -- 2238
														file = file, -- 2239
														line = type(row.line) == "number" and row.line or nil, -- 2240
														content = type(row.content) == "string" and row.content or nil -- 2241
													} -- 2241
												end -- 2241
												::__continue481:: -- 2241
												i = i + 1 -- 2234
											end -- 2234
										end -- 2234
										allHits[#allHits + 1] = __TS__ArraySlice( -- 2244
											sortDoraDocSearchHits(hits, docType, req.programmingLanguage), -- 2244
											0, -- 2244
											limit -- 2244
										) -- 2244
										p = p + 1 -- 2221
									end -- 2221
								end -- 2221
								local hits = mergeDoraDocSearchHitsUnique(allHits) -- 2246
								local fallbackPatterns -- 2247
								if #hits == 0 and #patterns == 1 and req.useRegex ~= true and (string.find(pattern, "|", nil, true) or 0) - 1 < 0 then -- 2247
									local terms = splitWhitespaceSearchPatterns(pattern) -- 2252
									if #terms > 1 then -- 2252
										fallbackPatterns = terms -- 2254
										local fallbackHits = {} -- 2255
										do -- 2255
											local p = 0 -- 2256
											while p < #terms do -- 2256
												local ____Content_46 = Content -- 2257
												local ____Content_searchFilesAsync_47 = Content.searchFilesAsync -- 2257
												local ____array_45 = __TS__SparseArrayNew( -- 2257
													docRoot, -- 2258
													dotExts, -- 2259
													{}, -- 2260
													ensureSafeSearchGlobs(globs), -- 2261
													terms[p + 1], -- 2262
													false -- 2263
												) -- 2263
												local ____req_caseSensitive_43 = req.caseSensitive -- 2264
												if ____req_caseSensitive_43 == nil then -- 2264
													____req_caseSensitive_43 = false -- 2264
												end -- 2264
												__TS__SparseArrayPush(____array_45, ____req_caseSensitive_43) -- 2264
												local ____req_includeContent_44 = req.includeContent -- 2265
												if ____req_includeContent_44 == nil then -- 2265
													____req_includeContent_44 = true -- 2265
												end -- 2265
												__TS__SparseArrayPush(____array_45, ____req_includeContent_44, req.contentWindow or 80) -- 2265
												local raw = ____Content_searchFilesAsync_47( -- 2257
													____Content_46, -- 2257
													__TS__SparseArraySpread(____array_45) -- 2257
												) -- 2257
												local termHits = {} -- 2268
												do -- 2268
													local i = 0 -- 2269
													while i < #raw do -- 2269
														do -- 2269
															local row = raw[i + 1] -- 2270
															local file = toDocRelativePath(resultBaseRoot, row.file, docType) -- 2271
															if file == "" then -- 2271
																goto __continue488 -- 2272
															end -- 2272
															termHits[#termHits + 1] = { -- 2273
																file = file, -- 2274
																line = type(row.line) == "number" and row.line or nil, -- 2275
																content = type(row.content) == "string" and row.content or nil -- 2276
															} -- 2276
														end -- 2276
														::__continue488:: -- 2276
														i = i + 1 -- 2269
													end -- 2269
												end -- 2269
												fallbackHits[#fallbackHits + 1] = __TS__ArraySlice( -- 2279
													sortDoraDocSearchHits(termHits, docType, req.programmingLanguage), -- 2279
													0, -- 2279
													limit -- 2279
												) -- 2279
												p = p + 1 -- 2256
											end -- 2256
										end -- 2256
										hits = mergeDoraDocSearchHitsUnique(fallbackHits) -- 2281
									end -- 2281
								end -- 2281
								resolve(nil, { -- 2284
									success = true, -- 2285
									docType = docType, -- 2286
									docLanguage = req.docLanguage, -- 2287
									programmingLanguage = req.programmingLanguage, -- 2288
									exts = exts, -- 2289
									results = hits, -- 2290
									hint = "Use read_file with a namespaced result to view it, or grep_files with that exact @dora-doc path to search within the document.", -- 2291
									totalResults = #hits, -- 2292
									truncated = false, -- 2293
									limit = limit, -- 2294
									fallbackPatterns = fallbackPatterns -- 2295
								}) -- 2295
							end) -- 2295
							if not ____try then -- 2295
								____catch(____hasReturned) -- 2295
							end -- 2295
						end -- 2295
					end)) -- 2218
				end -- 2217
			) -- 2217
		) -- 2217
	end) -- 2217
end -- 2190
function ____exports.searchDoraDocHttp(req, callback) -- 2304
	local ____self_48 = ____exports.searchDoraDoc(req) -- 2304
	____self_48["then"]( -- 2304
		____self_48, -- 2304
		function(____, result) return callback(result) end -- 2315
	) -- 2315
end -- 2304
function ____exports.readDoraDoc(req) -- 2318
	local requestedFile = table.concat( -- 2324
		__TS__StringSplit(req.file or "", "\\"), -- 2324
		"/" -- 2324
	) -- 2324
	local file = requestedFile -- 2325
	local namespacedType = nil -- 2326
	if __TS__StringStartsWith(requestedFile, AGENT_DORA_DOC_PREFIX) then -- 2326
		local namespaced = __TS__StringSlice(requestedFile, #AGENT_DORA_DOC_PREFIX) -- 2328
		if __TS__StringStartsWith(namespaced, "dora-api/") then -- 2328
			namespacedType = "dora-api" -- 2330
			file = string.sub(namespaced, 10) -- 2331
		elseif __TS__StringStartsWith(namespaced, "love-api/") then -- 2331
			namespacedType = "love-api" -- 2333
			file = string.sub(namespaced, 10) -- 2334
		elseif __TS__StringStartsWith(namespaced, "tic80-api/") then -- 2334
			namespacedType = "tic80-api" -- 2336
			file = string.sub(namespaced, 11) -- 2337
		elseif __TS__StringStartsWith(namespaced, "dora-tutorial/") then -- 2337
			namespacedType = "dora-tutorial" -- 2339
			file = string.sub(namespaced, 15) -- 2340
		elseif __TS__StringStartsWith(namespaced, "api/") then -- 2340
			namespacedType = "dora-api" -- 2342
			file = string.sub(namespaced, 5) -- 2343
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 2343
			namespacedType = "dora-tutorial" -- 2345
			file = string.sub(namespaced, 10) -- 2346
		else -- 2346
			return {success = false, message = "invalid Dora doc namespace"} -- 2348
		end -- 2348
	end -- 2348
	if not isValidWorkspacePath(file) or file == "." then -- 2348
		return {success = false, message = "invalid file"} -- 2352
	end -- 2352
	local lowerFile = string.lower(file) -- 2354
	local isTutorialDoc = __TS__StringEndsWith(lowerFile, ".md") -- 2355
	local isAPIDoc = __TS__StringEndsWith(lowerFile, ".ts") or __TS__StringEndsWith(lowerFile, ".tl") -- 2356
	if not isTutorialDoc and not isAPIDoc then -- 2356
		return {success = false, message = "unsupported doc file type"} -- 2357
	end -- 2357
	local docType = namespacedType or (isTutorialDoc and "dora-tutorial" or "dora-api") -- 2358
	if not isDoraDocFileInScope(docType, file) then -- 2358
		return {success = false, message = "document is outside the requested search type"} -- 2360
	end -- 2360
	local root = getDoraDocResultBaseRoot(docType, req.docLanguage) -- 2362
	local fullPath = Path(root, file) -- 2363
	local relative = Path:getRelative(fullPath, root) -- 2364
	if relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 2364
		return {success = false, message = "invalid file"} -- 2366
	end -- 2366
	local readResult = ____exports.readFile(root, file, req.startLine or 1, req.endLine or -1) -- 2368
	if not readResult.success then -- 2368
		return readResult -- 2369
	end -- 2369
	return { -- 2370
		success = true, -- 2371
		docLanguage = req.docLanguage, -- 2372
		file = file, -- 2373
		content = readResult.content, -- 2374
		startLine = readResult.startLine, -- 2375
		endLine = readResult.endLine -- 2376
	} -- 2376
end -- 2318
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 2380
	if options == nil then -- 2380
		options = {} -- 2380
	end -- 2380
	local storage = requireAgentStorage() -- 2381
	if not storage.success then -- 2381
		return storage -- 2382
	end -- 2382
	if #changes == 0 then -- 2382
		return {success = false, message = "empty changes"} -- 2384
	end -- 2384
	if not isValidWorkDir(workDir) then -- 2384
		return {success = false, message = "invalid workDir"} -- 2387
	end -- 2387
	if not getTaskStatus(taskId) then -- 2387
		return {success = false, message = "task not found"} -- 2390
	end -- 2390
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 2392
	local dup = rejectDuplicatePaths(expandedChanges) -- 2393
	if dup then -- 2393
		return {success = false, message = "duplicate path in batch: " .. dup} -- 2395
	end -- 2395
	for ____, change in ipairs(expandedChanges) do -- 2398
		if not isValidWorkspacePath(change.path) then -- 2398
			return {success = false, message = "invalid path: " .. change.path} -- 2400
		end -- 2400
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 2400
			return {success = false, message = "missing content for " .. change.path} -- 2403
		end -- 2403
	end -- 2403
	local headSeq = getTaskHeadSeq(taskId) -- 2407
	if headSeq == nil then -- 2407
		return {success = false, message = "task not found"} -- 2408
	end -- 2408
	local nextSeq = headSeq + 1 -- 2409
	local preparedEntries = {} -- 2411
	do -- 2411
		local i = 0 -- 2412
		while i < #expandedChanges do -- 2412
			local change = expandedChanges[i + 1] -- 2413
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 2414
			if not fullPath then -- 2414
				return {success = false, message = "invalid path: " .. change.path} -- 2416
			end -- 2416
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 2416
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 2419
			end -- 2419
			if Content:exist(fullPath) and not Content:isdir(fullPath) then -- 2419
				local ____, isBinary = Content:getAttr(fullPath) -- 2422
				if isBinary == true then -- 2422
					return {success = false, message = change.op == "delete" and "binary file deletion must use delete_file: " .. change.path or "binary files cannot be edited with text checkpoints: " .. change.path} -- 2424
				end -- 2424
			end -- 2424
			local before = getFileState(fullPath) -- 2432
			local afterExists = change.op ~= "delete" -- 2433
			local afterContent = afterExists and (change.content or "") or "" -- 2434
			preparedEntries[#preparedEntries + 1] = { -- 2435
				id = 0, -- 2436
				ord = i + 1, -- 2437
				path = change.path, -- 2438
				op = change.op, -- 2439
				beforeExists = before.exists, -- 2440
				beforeContent = before.content, -- 2441
				afterExists = afterExists, -- 2442
				afterContent = afterContent -- 2443
			} -- 2443
			i = i + 1 -- 2412
		end -- 2412
	end -- 2412
	local checkpointId = insertCheckpoint( -- 2447
		taskId, -- 2447
		nextSeq, -- 2447
		options.summary or "", -- 2447
		options.toolName or "", -- 2447
		"PREPARED" -- 2447
	) -- 2447
	if checkpointId <= 0 then -- 2447
		return {success = false, message = "failed to create checkpoint"} -- 2449
	end -- 2449
	local entryRows = {} -- 2451
	do -- 2451
		local i = 0 -- 2452
		while i < #preparedEntries do -- 2452
			local entry = preparedEntries[i + 1] -- 2453
			entryRows[#entryRows + 1] = { -- 2454
				checkpointId, -- 2455
				entry.ord, -- 2456
				entry.path, -- 2457
				entry.op, -- 2458
				entry.beforeExists and 1 or 0, -- 2459
				entry.beforeContent, -- 2460
				entry.afterExists and 1 or 0, -- 2461
				entry.afterContent, -- 2462
				#entry.beforeContent, -- 2463
				#entry.afterContent -- 2464
			} -- 2464
			i = i + 1 -- 2452
		end -- 2452
	end -- 2452
	local entryInsert = {("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_data, after_exists, after_data, bytes_before, bytes_after)\n\t\tVALUES(?, ?, ?, ?, ?, dora_compress_text(?), ?, dora_compress_text(?), ?, ?)", entryRows} -- 2467
	if not DB:transaction({entryInsert}) then -- 2467
		DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2473
		return {success = false, message = "failed to insert checkpoint entries"} -- 2474
	end -- 2474
	local appliedCount = 0 -- 2477
	for ____, entry in ipairs(preparedEntries) do -- 2478
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2479
		if not fullPath then -- 2479
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2481
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2482
			return {success = false, message = ("invalid path: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2483
		end -- 2483
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 2485
		if not ok then -- 2485
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2487
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount + 1) -- 2488
			return {success = false, message = ("failed to apply file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2489
		end -- 2489
		appliedCount = appliedCount + 1 -- 2491
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 2491
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2493
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2494
			return {success = false, message = ("failed to sync file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; all applied files restored")} -- 2495
		end -- 2495
	end -- 2495
	DB:exec( -- 2499
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 2499
		{ -- 2501
			"APPLIED", -- 2501
			now(), -- 2501
			checkpointId -- 2501
		} -- 2501
	) -- 2501
	DB:exec( -- 2503
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 2503
		{ -- 2505
			nextSeq, -- 2505
			now(), -- 2505
			taskId -- 2505
		} -- 2505
	) -- 2505
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 2507
end -- 2380
function ____exports.deleteFile(taskId, workDir, targetFile, options) -- 2515
	if options == nil then -- 2515
		options = {} -- 2515
	end -- 2515
	local storage = requireAgentStorage() -- 2516
	if not storage.success then -- 2516
		return storage -- 2517
	end -- 2517
	if not isValidWorkDir(workDir) then -- 2517
		return {success = false, message = "invalid workDir"} -- 2519
	end -- 2519
	if not getTaskStatus(taskId) then -- 2519
		return {success = false, message = "task not found"} -- 2522
	end -- 2522
	if not isValidWorkspacePath(targetFile) then -- 2522
		return {success = false, message = "invalid path: " .. targetFile} -- 2525
	end -- 2525
	local fullPath = resolveWorkspaceFilePath(workDir, targetFile) -- 2527
	if not fullPath then -- 2527
		return {success = false, message = "invalid path: " .. targetFile} -- 2529
	end -- 2529
	if Content:exist(fullPath) and Content:isdir(fullPath) then -- 2529
		return {success = false, message = "delete_file only supports files, not directories: " .. targetFile} -- 2532
	end -- 2532
	local isBinary = false -- 2535
	if Content:exist(fullPath) then -- 2535
		do -- 2535
			local function ____catch(e) -- 2535
				Log( -- 2541
					"Warn", -- 2541
					(("[Agent.Tools] Content.getAttr failed before deleting " .. fullPath) .. ": ") .. tostring(e) -- 2541
				) -- 2541
			end -- 2541
			local ____try, ____hasReturned = pcall(function() -- 2541
				local ____, detectedBinary = Content:getAttr(fullPath) -- 2538
				isBinary = detectedBinary == true -- 2539
			end) -- 2539
			if not ____try then -- 2539
				____catch(____hasReturned) -- 2539
			end -- 2539
		end -- 2539
	end -- 2539
	if not isBinary then -- 2539
		local result = ____exports.applyFileChanges(taskId, workDir, {{path = targetFile, op = "delete"}}, options) -- 2545
		if not result.success then -- 2545
			return result -- 2546
		end -- 2546
		return __TS__ObjectAssign({}, result, {checkpointed = true, reversible = true, binary = false}) -- 2547
	end -- 2547
	if not Content:remove(fullPath) then -- 2547
		return {success = false, message = "failed to delete binary file: " .. targetFile} -- 2556
	end -- 2556
	if not ____exports.sendWebIDEFileUpdate(fullPath, false, "") then -- 2556
		____exports.sendWebIDERefreshTree() -- 2559
	end -- 2559
	return { -- 2561
		success = true, -- 2562
		taskId = taskId, -- 2563
		checkpointed = false, -- 2564
		reversible = false, -- 2565
		binary = true, -- 2566
		message = "Binary file deleted directly without a checkpoint; this deletion cannot be rolled back." -- 2567
	} -- 2567
end -- 2515
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 2571
	if not isValidWorkDir(workDir) then -- 2571
		return {success = false, message = "invalid workDir"} -- 2572
	end -- 2572
	if checkpointId <= 0 then -- 2572
		return {success = false, message = "invalid checkpointId"} -- 2573
	end -- 2573
	local entries = getCheckpointEntries(checkpointId, true) -- 2574
	if #entries == 0 then -- 2574
		return {success = false, message = "checkpoint not found or empty"} -- 2576
	end -- 2576
	for ____, entry in ipairs(entries) do -- 2578
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2579
		if not fullPath then -- 2579
			return {success = false, message = "invalid path: " .. entry.path} -- 2581
		end -- 2581
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 2583
		if not ok then -- 2583
			Log( -- 2585
				"Error", -- 2585
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2585
			) -- 2585
			Log( -- 2586
				"Info", -- 2586
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2586
			) -- 2586
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 2587
		end -- 2587
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 2587
			Log( -- 2590
				"Error", -- 2590
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2590
			) -- 2590
			Log( -- 2591
				"Info", -- 2591
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2591
			) -- 2591
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 2592
		end -- 2592
	end -- 2592
	DB:exec( -- 2595
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 2595
		{ -- 2595
			"REVERTED", -- 2595
			now(), -- 2595
			checkpointId -- 2595
		} -- 2595
	) -- 2595
	return {success = true, checkpointId = checkpointId} -- 2596
end -- 2571
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 2599
	if not isValidWorkDir(workDir) then -- 2599
		return {success = false, message = "invalid workDir"} -- 2600
	end -- 2600
	if not getTaskStatus(taskId) then -- 2600
		return {success = false, message = "task not found"} -- 2601
	end -- 2601
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 2602
	if #checkpoints == 0 then -- 2602
		return {success = false, message = "change set not found or empty"} -- 2604
	end -- 2604
	local lastCheckpointId = 0 -- 2606
	do -- 2606
		local i = 0 -- 2607
		while i < #checkpoints do -- 2607
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 2608
			if not result.success then -- 2608
				return {success = false, message = result.message} -- 2609
			end -- 2609
			lastCheckpointId = checkpoints[i + 1].id -- 2610
			i = i + 1 -- 2607
		end -- 2607
	end -- 2607
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 2612
end -- 2599
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 2620
	return getCheckpointEntries(checkpointId, false) -- 2621
end -- 2620
function ____exports.getCheckpointDiff(checkpointId) -- 2624
	if checkpointId <= 0 then -- 2624
		return {success = false, message = "invalid checkpointId"} -- 2626
	end -- 2626
	local entries = getCheckpointEntries(checkpointId, false) -- 2628
	if #entries == 0 then -- 2628
		return {success = false, message = "checkpoint not found or empty"} -- 2630
	end -- 2630
	return { -- 2632
		success = true, -- 2633
		files = __TS__ArrayMap( -- 2634
			entries, -- 2634
			function(____, entry) return { -- 2634
				path = entry.path, -- 2635
				op = entry.op, -- 2636
				beforeExists = entry.beforeExists, -- 2637
				afterExists = entry.afterExists, -- 2638
				beforeContent = entry.beforeContent, -- 2639
				afterContent = entry.afterContent -- 2640
			} end -- 2640
		) -- 2640
	} -- 2640
end -- 2624
local function finalizeBuildResult(workDir, messages) -- 2645
	local normalized = __TS__ArrayMap( -- 2646
		messages, -- 2646
		function(____, m) return m.success and __TS__ObjectAssign( -- 2646
			{}, -- 2647
			m, -- 2647
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2647
		) or __TS__ObjectAssign( -- 2647
			{}, -- 2648
			m, -- 2648
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2648
		) end -- 2648
	) -- 2648
	local total = #normalized -- 2649
	local failed = 0 -- 2650
	do -- 2650
		local i = 0 -- 2651
		while i < #normalized do -- 2651
			if not normalized[i + 1].success then -- 2651
				failed = failed + 1 -- 2652
			end -- 2652
			i = i + 1 -- 2651
		end -- 2651
	end -- 2651
	local passed = total - failed -- 2654
	if failed > 0 then -- 2654
		local interrupted = __TS__ArraySome( -- 2656
			normalized, -- 2656
			function(____, message) return not message.success and message.interrupted == true end -- 2656
		) -- 2656
		return { -- 2657
			success = false, -- 2658
			message = interrupted and "Build canceled." or ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 2659
			total = total, -- 2660
			passed = passed, -- 2661
			failed = failed, -- 2662
			messages = normalized, -- 2663
			interrupted = interrupted or nil -- 2664
		} -- 2664
	end -- 2664
	return { -- 2667
		success = true, -- 2668
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 2669
		total = total, -- 2670
		passed = passed, -- 2671
		failed = 0, -- 2672
		messages = normalized -- 2673
	} -- 2673
end -- 2645
function ____exports.build(req) -- 2677
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2677
		local ____this_50 -- 2677
		____this_50 = req -- 2678
		local ____opt_49 = ____this_50.isCancelled -- 2678
		if (____opt_49 and ____opt_49(____this_50)) == true then -- 2678
			return ____awaiter_resolve(nil, {success = false, message = "Build canceled.", interrupted = true}) -- 2678
		end -- 2678
		local targetRel = req.path or "" -- 2681
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2682
		if not target then -- 2682
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2682
		end -- 2682
		if not Content:exist(target) then -- 2682
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2682
		end -- 2682
		local messages = {} -- 2689
		if not Content:isdir(target) then -- 2689
			local kind = getSupportedBuildKind(target) -- 2691
			if not kind then -- 2691
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2691
			end -- 2691
			if kind == "ts" then -- 2691
				local content = Content:load(target) -- 2696
				if content == nil then -- 2696
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2696
				end -- 2696
				if isTiledEditorContent(content) then -- 2696
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2701
					return ____awaiter_resolve( -- 2701
						nil, -- 2701
						finalizeBuildResult(req.workDir, messages) -- 2702
					) -- 2702
				end -- 2702
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2702
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2702
				end -- 2702
				if not isDtsFile(target) then -- 2702
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir, req.isCancelled)) -- 2708
				end -- 2708
			else -- 2708
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2711
			end -- 2711
			Log( -- 2713
				"Info", -- 2713
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2713
			) -- 2713
			return ____awaiter_resolve( -- 2713
				nil, -- 2713
				finalizeBuildResult(req.workDir, messages) -- 2714
			) -- 2714
		end -- 2714
		local listResult = ____exports.listFiles({ -- 2716
			workDir = req.workDir, -- 2717
			path = targetRel, -- 2718
			globs = __TS__ArrayMap( -- 2719
				codeExtensions, -- 2719
				function(____, e) return "**/*" .. e end -- 2719
			), -- 2719
			maxEntries = 10000 -- 2720
		}) -- 2720
		local relFiles = listResult.success and listResult.files or ({}) -- 2723
		local tsFileData = {} -- 2724
		local buildQueue = {} -- 2725
		for ____, rel in ipairs(relFiles) do -- 2726
			do -- 2726
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2727
				local kind = getSupportedBuildKind(file) -- 2728
				if not kind then -- 2728
					goto __continue588 -- 2729
				end -- 2729
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2730
				if kind ~= "ts" then -- 2730
					goto __continue588 -- 2732
				end -- 2732
				local content = Content:load(file) -- 2734
				if content == nil then -- 2734
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2736
					goto __continue588 -- 2737
				end -- 2737
				if isTiledEditorContent(content) then -- 2737
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2740
					goto __continue588 -- 2741
				end -- 2741
				tsFileData[file] = content -- 2743
			end -- 2743
			::__continue588:: -- 2743
		end -- 2743
		do -- 2743
			local i = 0 -- 2745
			while i < #buildQueue do -- 2745
				do -- 2745
					local ____this_52 -- 2745
					____this_52 = req -- 2746
					local ____opt_51 = ____this_52.isCancelled -- 2746
					if (____opt_51 and ____opt_51(____this_52)) == true then -- 2746
						return ____awaiter_resolve(nil, {success = false, message = "Build canceled.", messages = messages, interrupted = true}) -- 2746
					end -- 2746
					local ____buildQueue_index_53 = buildQueue[i + 1] -- 2749
					local file = ____buildQueue_index_53.file -- 2749
					local kind = ____buildQueue_index_53.kind -- 2749
					if kind == "ts" then -- 2749
						local content = tsFileData[file] -- 2751
						if content == nil or isDtsFile(file) then -- 2751
							goto __continue595 -- 2753
						end -- 2753
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2753
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2756
							goto __continue595 -- 2757
						end -- 2757
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir, req.isCancelled)) -- 2759
						goto __continue595 -- 2760
					end -- 2760
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2762
				end -- 2762
				::__continue595:: -- 2762
				i = i + 1 -- 2745
			end -- 2745
		end -- 2745
		if #messages == 0 then -- 2745
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2765
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2765
		end -- 2765
		Log( -- 2768
			"Info", -- 2768
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2768
		) -- 2768
		return ____awaiter_resolve( -- 2768
			nil, -- 2768
			finalizeBuildResult(req.workDir, messages) -- 2769
		) -- 2769
	end) -- 2769
end -- 2677
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2772
local EXECUTE_COMMAND_ERROR_MAX = 4000 -- 2773
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 2774
local agentEntryRuntimeOwner = "" -- 2775
local function truncateCommandOutput(output) -- 2777
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2777
		return output -- 2778
	end -- 2778
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2779
end -- 2777
local function truncateCommandError(message) -- 2782
	if #message <= EXECUTE_COMMAND_ERROR_MAX then -- 2782
		return message -- 2783
	end -- 2783
	return __TS__StringSlice(message, 0, EXECUTE_COMMAND_ERROR_MAX) .. "\n... error message truncated ..." -- 2784
end -- 2782
local function executeLuaCommand(req) -- 2787
	local code = __TS__StringTrim(req.code or "") -- 2795
	if code == "" then -- 2795
		return __TS__Promise.resolve({ -- 2797
			success = false, -- 2797
			mode = "lua", -- 2797
			output = "", -- 2797
			message = "missing code", -- 2797
			phase = "validate" -- 2797
		}) -- 2797
	end -- 2797
	local output = {} -- 2799
	local entry = require("Script.Dev.Entry") -- 2800
	local ownsEntryRuntime = false -- 2801
	local contentAccessed = false -- 2802
	local refreshTreeCalled = false -- 2803
	local entryObjectBaseline = 0 -- 2804
	local entryLuaRefBaseline = 0 -- 2805
	local function acquireEntryRuntime() -- 2806
		if agentEntryRuntimeOwner ~= "" and agentEntryRuntimeOwner ~= req.operationId then -- 2806
			error("Dora entry runtime is busy with another Agent command") -- 2808
		end -- 2808
		agentEntryRuntimeOwner = req.operationId -- 2810
		ownsEntryRuntime = true -- 2811
	end -- 2806
	local function stopOwnedEntry() -- 2813
		if not ownsEntryRuntime then -- 2813
			return nil -- 2814
		end -- 2814
		local cleanupError -- 2815
		do -- 2815
			local function ____catch(e) -- 2815
				cleanupError = "failed to stop Agent test entry: " .. tostring(e) -- 2819
			end -- 2819
			local ____try, ____hasReturned = pcall(function() -- 2819
				entry.stop() -- 2817
			end) -- 2817
			if not ____try then -- 2817
				____catch(____hasReturned) -- 2817
			end -- 2817
		end -- 2817
		ownsEntryRuntime = false -- 2821
		if agentEntryRuntimeOwner == req.operationId then -- 2821
			agentEntryRuntimeOwner = "" -- 2823
		end -- 2823
		return cleanupError -- 2825
	end -- 2813
	local function startEntryWatchdog() -- 2827
		entryObjectBaseline = Dora.Object.count -- 2828
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 2829
	end -- 2827
	local function checkEntryWatchdog() -- 2831
		if not ownsEntryRuntime then -- 2831
			return nil -- 2832
		end -- 2832
		local objectCount = Dora.Object.count -- 2833
		local luaRefCount = Dora.Object.luaRefCount -- 2834
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 2835
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 2836
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 2837
		if not exceededTotal then -- 2837
			return nil -- 2840
		end -- 2840
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 2841
	end -- 2831
	local function normalizeEntryFile(value) -- 2845
		if not value or type(value) ~= "table" then -- 2845
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 2847
		end -- 2847
		local descriptor = value -- 2849
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 2850
		if relativeFile == "" then -- 2850
			relativeFile = "init" -- 2851
		end -- 2851
		if not isValidWorkspacePath(relativeFile) then -- 2851
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 2853
		end -- 2853
		local fileName = Path(req.workDir, relativeFile) -- 2855
		local ext = Path:getExt(fileName) -- 2856
		if ext ~= "" then -- 2856
			fileName = Path:replaceExt(fileName, "") -- 2857
		end -- 2857
		local luaFile = Path:replaceExt(fileName, "lua") -- 2858
		if not Content:exist(luaFile) then -- 2858
			error("Agent test entry was not built: " .. luaFile) -- 2860
		end -- 2860
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 2862
		return { -- 2863
			fileName = fileName, -- 2864
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 2865
		} -- 2865
	end -- 2845
	local function capturePrint(...) -- 2868
		local values = {...} -- 2868
		local parts = {} -- 2869
		do -- 2869
			local i = 0 -- 2870
			while i < #values do -- 2870
				parts[#parts + 1] = tostring(values[i + 1]) -- 2871
				i = i + 1 -- 2870
			end -- 2870
		end -- 2870
		output[#output + 1] = table.concat(parts, "\t") -- 2873
	end -- 2868
	local function refreshTree(path) -- 2875
		refreshTreeCalled = true -- 2876
		if path == nil then -- 2876
			return refreshProjectTree(req.workDir) -- 2878
		end -- 2878
		if type(path) ~= "string" then -- 2878
			error("refreshTree expects a project-relative file path string or no argument") -- 2881
		end -- 2881
		return refreshProjectTree(req.workDir, path) -- 2883
	end -- 2875
	local function resolveLuaContentPath(first, second) -- 2885
		local value = type(second) == "string" and second or first -- 2886
		if type(value) ~= "string" then -- 2886
			error("Content path must be a project-relative string") -- 2888
		end -- 2888
		local fullPath = resolveWorkspaceFilePath(req.workDir, value) -- 2890
		if not fullPath then -- 2890
			error("Content path must stay inside projectDir") -- 2892
		end -- 2892
		return fullPath -- 2894
	end -- 2885
	local scopedContent = { -- 2896
		exist = function(first, second) return Content:exist(resolveLuaContentPath(first, second)) end, -- 2897
		isdir = function(first, second) return Content:isdir(resolveLuaContentPath(first, second)) end, -- 2898
		getAttr = function(first, second) return Content:getAttr(resolveLuaContentPath(first, second)) end, -- 2899
		load = function(first, second) -- 2900
			local fullPath = resolveLuaContentPath(first, second) -- 2901
			local inspected = inspectReadableFile(fullPath) -- 2902
			if not inspected.success then -- 2902
				error(inspected.message or "file is not readable") -- 2903
			end -- 2903
			return Content:load(fullPath) -- 2904
		end -- 2900
	} -- 2900
	local blockedDoraGlobals = {Content = true, DB = true, HttpClient = true, HttpServer = true} -- 2907
	local env = setmetatable( -- 2913
		{ -- 2913
			projectDir = req.workDir, -- 2914
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 2915
				if type(moduleNameValue) ~= "string" then -- 2915
					error("requireProjectModule expects a project module name string") -- 2917
				end -- 2917
				local moduleName = __TS__StringTrim(moduleNameValue) -- 2919
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 2919
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 2921
				end -- 2921
				local reloadModules = {moduleName} -- 2923
				if reloadModulesValue ~= nil then -- 2923
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 2923
						error("requireProjectModule reloadModules must be an array of module names") -- 2926
					end -- 2926
					local items = reloadModulesValue -- 2928
					do -- 2928
						local i = 0 -- 2929
						while i < #items do -- 2929
							local item = items[i + 1] -- 2930
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 2930
								error("requireProjectModule reloadModules contains an invalid module name") -- 2932
							end -- 2932
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 2932
								reloadModules[#reloadModules + 1] = item -- 2934
							end -- 2934
							i = i + 1 -- 2929
						end -- 2929
					end -- 2929
				end -- 2929
				local luaPackage = _G.package -- 2937
				local previousPath = luaPackage.path -- 2941
				local previousSearchPaths = Content.searchPaths -- 2942
				local scopedSearchPaths = {req.workDir} -- 2943
				do -- 2943
					local i = 0 -- 2944
					while i < #previousSearchPaths do -- 2944
						local searchPath = previousSearchPaths[i + 1] -- 2945
						if searchPath ~= req.workDir then -- 2945
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 2946
						end -- 2946
						i = i + 1 -- 2944
					end -- 2944
				end -- 2944
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 2948
				Content.searchPaths = scopedSearchPaths -- 2949
				do -- 2949
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2949
						do -- 2949
							local i = 0 -- 2951
							while i < #reloadModules do -- 2951
								local reloadName = reloadModules[i + 1] -- 2952
								luaPackage.loaded[reloadName] = nil -- 2953
								luaPackage.loaded[table.concat( -- 2954
									__TS__StringSplit(reloadName, "/"), -- 2954
									"." -- 2954
								)] = nil -- 2954
								luaPackage.loaded[table.concat( -- 2955
									__TS__StringSplit(reloadName, "."), -- 2955
									"/" -- 2955
								)] = nil -- 2955
								i = i + 1 -- 2951
							end -- 2951
						end -- 2951
						return true, require(table.concat( -- 2957
							__TS__StringSplit(moduleName, "/"), -- 2957
							"." -- 2957
						)) -- 2957
					end) -- 2957
					do -- 2957
						Content.searchPaths = previousSearchPaths -- 2959
						luaPackage.path = previousPath -- 2960
					end -- 2960
					if not ____try then -- 2960
						error(____hasReturned, 0) -- 2960
					end -- 2960
					if ____try and ____hasReturned then -- 2960
						return ____returnValue -- 2950
					end -- 2950
				end -- 2950
			end, -- 2915
			print = capturePrint, -- 2963
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 2964
			enterEntryAsync = function(value) -- 2965
				local normalized = normalizeEntryFile(value) -- 2966
				acquireEntryRuntime() -- 2967
				entry.allClear() -- 2968
				startEntryWatchdog() -- 2969
				local success, message = entry.enterEntryAsync({ -- 2970
					entryName = normalized.entryName, -- 2971
					fileName = normalized.fileName, -- 2972
					workDir = req.workDir, -- 2973
					projectRoot = req.workDir, -- 2974
					runKind = "agent_test" -- 2975
				}) -- 2975
				return success, message -- 2977
			end, -- 2965
			stopEntry = function() -- 2979
				if not ownsEntryRuntime then -- 2979
					return false -- 2980
				end -- 2980
				return entry.stop() -- 2981
			end, -- 2979
			reportProgress = function(value, callbackValue) -- 2983
				local ____callbackValue_54 = callbackValue -- 2984
				if ____callbackValue_54 == nil then -- 2984
					____callbackValue_54 = value -- 2984
				end -- 2984
				local actualValue = ____callbackValue_54 -- 2984
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 2984
					return -- 2985
				end -- 2985
				local progress = actualValue -- 2986
				local amount = type(progress.progress) == "number" and math.min( -- 2987
					1, -- 2988
					math.max(0, progress.progress) -- 2988
				) or nil -- 2988
				req:onProgress({ -- 2990
					state = "running", -- 2991
					mode = "lua", -- 2992
					operationId = req.operationId, -- 2993
					progress = amount, -- 2994
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 2995
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 2996
				}) -- 2996
			end -- 2983
		}, -- 2983
		{__index = function(_table, key) -- 2999
			if key == "Content" then -- 2999
				contentAccessed = true -- 3002
				return scopedContent -- 3003
			end -- 3003
			if key == "refreshTree" then -- 3003
				return refreshTree -- 3006
			end -- 3006
			local name = tostring(key) -- 3008
			if blockedDoraGlobals[name] then -- 3008
				return nil -- 3009
			end -- 3009
			return Dora[name] -- 3010
		end} -- 3000
	) -- 3000
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 3013
	if not fn then -- 3013
		return __TS__Promise.resolve({ -- 3015
			success = false, -- 3016
			mode = "lua", -- 3017
			output = truncateCommandOutput(table.concat(output, "\n")), -- 3018
			message = truncateCommandError(toStr(compileErr)), -- 3019
			phase = "compile" -- 3020
		}) -- 3020
	end -- 3020
	return __TS__New( -- 3023
		__TS__Promise, -- 3023
		function(____, resolve) -- 3023
			local settled = false -- 3024
			local commandRoutine -- 3025
			local startedAt = App.runningTime -- 3026
			local onProgress = req.onProgress -- 3027
			local isCancelled = req.isCancelled -- 3028
			local function finish(result) -- 3029
				if settled then -- 3029
					return -- 3030
				end -- 3030
				settled = true -- 3031
				local cleanupError -- 3032
				if not result.success and (result.interrupted == true or result.phase == "timeout") then -- 3032
					do -- 3032
						local function ____catch(e) -- 3032
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 3037
						end -- 3037
						local ____try, ____hasReturned = pcall(function() -- 3037
							entry.allClear() -- 3035
						end) -- 3035
						if not ____try then -- 3035
							____catch(____hasReturned) -- 3035
						end -- 3035
					end -- 3035
				end -- 3035
				local entryCleanupError = stopOwnedEntry() -- 3040
				if cleanupError == nil then -- 3040
					cleanupError = entryCleanupError -- 3041
				end -- 3041
				if contentAccessed and not refreshTreeCalled and not refreshProjectTree(req.workDir) then -- 3041
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 3043
				end -- 3043
				if not result.success and cleanupError ~= nil then -- 3043
					result.cleanupError = cleanupError -- 3046
				elseif result.success and cleanupError ~= nil then -- 3046
					resolve(nil, { -- 3048
						success = false, -- 3049
						mode = "lua", -- 3050
						output = result.output, -- 3051
						message = cleanupError, -- 3052
						phase = "execute", -- 3053
						cleanupError = cleanupError -- 3054
					}) -- 3054
					return -- 3056
				end -- 3056
				resolve(nil, result) -- 3058
			end -- 3029
			if onProgress then -- 3029
				onProgress(nil, { -- 3061
					state = "pending", -- 3062
					mode = "lua", -- 3063
					operationId = req.operationId, -- 3064
					stage = "lua", -- 3065
					message = "Lua command pending" -- 3066
				}) -- 3066
			end -- 3066
			commandRoutine = once(function() -- 3069
				if settled then -- 3069
					return -- 3070
				end -- 3070
				if onProgress then -- 3070
					onProgress(nil, { -- 3072
						state = "running", -- 3073
						mode = "lua", -- 3074
						operationId = req.operationId, -- 3075
						stage = "lua", -- 3076
						message = "Lua command running" -- 3077
					}) -- 3077
				end -- 3077
				local previousGlobalPrint = _G.print -- 3080
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 3081
				local frameTimedOut = false -- 3082
				local watchdogMessage -- 3082
				_G.print = capturePrint -- 3083
				debug.sethook( -- 3084
					function() -- 3084
						if watchdogMessage == nil then -- 3084
							watchdogMessage = checkEntryWatchdog() -- 3085
						end -- 3085
						if watchdogMessage ~= nil then -- 3085
							error(watchdogMessage) -- 3086
						end -- 3086
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 3086
							frameTimedOut = true -- 3088
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 3089
						end -- 3089
					end, -- 3084
					"", -- 3091
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 3091
				) -- 3091
				local ok, runtimeErr = pcall(fn) -- 3092
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 3092
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 3094
				else -- 3094
					debug.sethook() -- 3100
				end -- 3100
				_G.print = previousGlobalPrint -- 3102
				if not ok then -- 3102
					local ____truncateCommandOutput_result_56 = truncateCommandOutput(table.concat(output, "\n")) -- 3107
					local ____temp_57 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 3108
					local ____temp_58 = frameTimedOut and "timeout" or "execute" -- 3109
					local ____temp_55 -- 3110
					if watchdogMessage ~= nil or frameTimedOut then -- 3110
						____temp_55 = true -- 3110
					else -- 3110
						____temp_55 = nil -- 3110
					end -- 3110
					finish({ -- 3104
						success = false, -- 3105
						mode = "lua", -- 3106
						output = ____truncateCommandOutput_result_56, -- 3107
						message = ____temp_57, -- 3108
						phase = ____temp_58, -- 3109
						interrupted = ____temp_55 -- 3110
					}) -- 3110
					return -- 3112
				end -- 3112
				finish({ -- 3114
					success = true, -- 3114
					mode = "lua", -- 3114
					output = truncateCommandOutput(table.concat(output, "\n")) -- 3114
				}) -- 3114
			end) -- 3069
			Director.systemScheduler:schedule(function() -- 3116
				if settled then -- 3116
					return true -- 3117
				end -- 3117
				local watchdogMessage = checkEntryWatchdog() -- 3118
				if watchdogMessage ~= nil then -- 3118
					finish({ -- 3120
						success = false, -- 3121
						mode = "lua", -- 3122
						output = truncateCommandOutput(table.concat(output, "\n")), -- 3123
						message = watchdogMessage, -- 3124
						phase = "execute", -- 3125
						interrupted = true -- 3126
					}) -- 3126
					return true -- 3128
				end -- 3128
				if isCancelled and isCancelled(nil) then -- 3128
					finish({ -- 3131
						success = false, -- 3132
						mode = "lua", -- 3133
						output = truncateCommandOutput(table.concat(output, "\n")), -- 3134
						message = "Lua command canceled", -- 3135
						phase = "execute", -- 3136
						interrupted = true -- 3137
					}) -- 3137
					return true -- 3139
				end -- 3139
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 3139
					finish({ -- 3142
						success = false, -- 3143
						mode = "lua", -- 3144
						output = truncateCommandOutput(table.concat(output, "\n")), -- 3145
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 3146
						phase = "timeout" -- 3147
					}) -- 3147
					return true -- 3149
				end -- 3149
				if commandRoutine == nil then -- 3149
					finish({ -- 3152
						success = false, -- 3153
						mode = "lua", -- 3154
						output = truncateCommandOutput(table.concat(output, "\n")), -- 3155
						message = "Lua command coroutine is unavailable", -- 3156
						phase = "execute" -- 3157
					}) -- 3157
					return true -- 3159
				end -- 3159
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 3161
				if not resumeSuccess then -- 3161
					finish({ -- 3163
						success = false, -- 3164
						mode = "lua", -- 3165
						output = truncateCommandOutput(table.concat(output, "\n")), -- 3166
						message = truncateCommandError(toStr(resumeResult)), -- 3167
						phase = "execute" -- 3168
					}) -- 3168
					return true -- 3170
				end -- 3170
				return settled or resumeResult == true -- 3172
			end) -- 3116
		end -- 3023
	) -- 3023
end -- 2787
local function formatGitStatusOutput(status) -- 3177
	if not status then -- 3177
		return "" -- 3178
	end -- 3178
	local lines = {} -- 3179
	local state = toStr(status.state) -- 3180
	local kind = toStr(status.kind) -- 3181
	local message = toStr(status.message) -- 3182
	local errorMessage = toStr(status.error) -- 3183
	if kind ~= "" or state ~= "" then -- 3183
		lines[#lines + 1] = table.concat( -- 3185
			__TS__ArrayFilter( -- 3185
				{kind, state}, -- 3185
				function(____, item) return item ~= "" end -- 3185
			), -- 3185
			": " -- 3185
		) -- 3185
	end -- 3185
	if message ~= "" then -- 3185
		lines[#lines + 1] = message -- 3187
	end -- 3187
	if errorMessage ~= "" then -- 3187
		lines[#lines + 1] = errorMessage -- 3188
	end -- 3188
	local data = status.data -- 3189
	if data ~= nil then -- 3189
		local dataText = encodeJSON(data) -- 3191
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 3192
	end -- 3192
	return truncateCommandOutput(table.concat(lines, "\n")) -- 3194
end -- 3177
local function emitGitProgress(mode, operationId, onProgress, status) -- 3197
	if not onProgress then -- 3197
		return -- 3203
	end -- 3203
	local progress = type(status.progress) == "number" and status.progress or nil -- 3204
	local kind = toStr(status.kind) -- 3205
	local message = toStr(status.message) -- 3206
	local state = toStr(status.state) -- 3207
	local jobId = type(status.id) == "number" and status.id or nil -- 3208
	onProgress({ -- 3209
		state = "running", -- 3210
		mode = mode, -- 3211
		operationId = operationId, -- 3212
		stage = kind ~= "" and kind or "git", -- 3213
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 3214
		progress = progress, -- 3215
		jobId = jobId, -- 3216
		gitState = state ~= "" and state or nil, -- 3217
		gitKind = kind ~= "" and kind or nil -- 3218
	}) -- 3218
end -- 3197
local function cloneGitToTarget(req) -- 3222
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3222
		local parsed = parseGitCloneCommand(req.command) -- 3230
		if parsed == nil then -- 3230
			return ____awaiter_resolve(nil, nil) -- 3230
		end -- 3230
		if not parsed.success then -- 3230
			return ____awaiter_resolve(nil, { -- 3230
				success = false, -- 3233
				mode = "git", -- 3233
				output = "", -- 3233
				message = parsed.message, -- 3233
				phase = "validate" -- 3233
			}) -- 3233
		end -- 3233
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 3235
		if not target then -- 3235
			return ____awaiter_resolve(nil, { -- 3235
				success = false, -- 3237
				mode = "git", -- 3237
				output = "", -- 3237
				message = "invalid clone target path", -- 3237
				phase = "validate" -- 3237
			}) -- 3237
		end -- 3237
		if Content:exist(target) then -- 3237
			return ____awaiter_resolve(nil, { -- 3237
				success = false, -- 3240
				mode = "git", -- 3240
				output = "", -- 3240
				message = "target already exists", -- 3240
				phase = "validate" -- 3240
			}) -- 3240
		end -- 3240
		local targetParent = Path:getPath(target) -- 3242
		if not ensureDirPath(targetParent) then -- 3242
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 3242
		end -- 3242
		local tempRoot = getAgentDownloadTempRoot() -- 3246
		if not ensureDirPath(tempRoot) then -- 3246
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 3246
		end -- 3246
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 3250
		Content:remove(tempPath) -- 3251
		local depth = parsed.depth or "1" -- 3252
		local ____array_59 = __TS__SparseArrayNew( -- 3252
			"clone", -- 3254
			quoteGitArg(parsed.url), -- 3255
			quoteGitArg(Path:getFilename(tempPath)), -- 3256
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 3257
				"-b", -- 3257
				quoteGitArg(parsed.ref) -- 3257
			}) or ({})) -- 3257
		) -- 3257
		__TS__SparseArrayPush( -- 3257
			____array_59, -- 3257
			table.unpack(depth ~= "" and ({ -- 3258
				"--depth",
				quoteGitArg(depth) -- 3258
			}) or ({})) -- 3258
		) -- 3258
		local command = table.concat( -- 3253
			{__TS__SparseArraySpread(____array_59)}, -- 3253
			" " -- 3259
		) -- 3259
		local ____this_61 -- 3259
		____this_61 = req -- 3260
		local ____opt_60 = ____this_61.onProgress -- 3260
		if ____opt_60 ~= nil then -- 3260
			____opt_60(____this_61, { -- 3260
				state = "pending", -- 3261
				mode = "git", -- 3262
				operationId = req.operationId, -- 3263
				stage = "clone", -- 3264
				message = "clone pending", -- 3265
				progress = 0 -- 3266
			}) -- 3266
		end -- 3266
		local gitRes = __TS__Await(runGitAndWait( -- 3268
			tempRoot, -- 3269
			command, -- 3270
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 3271
			req.isCancelled, -- 3272
			req.timeoutSeconds -- 3273
		)) -- 3273
		if not gitRes.success then -- 3273
			local cleanupError = cleanupPath(tempPath) -- 3276
			local ____formatGitStatusOutput_result_65 = formatGitStatusOutput(gitRes.status) -- 3280
			local ____temp_66 = gitRes.message or "git clone failed" -- 3281
			local ____gitRes_interrupted_64 = gitRes.interrupted -- 3282
			if not ____gitRes_interrupted_64 then -- 3282
				local ____this_63 -- 3282
				____this_63 = req -- 3282
				local ____opt_62 = ____this_63.isCancelled -- 3282
				____gitRes_interrupted_64 = (____opt_62 and ____opt_62(____this_63)) == true -- 3282
			end -- 3282
			return ____awaiter_resolve(nil, { -- 3282
				success = false, -- 3278
				mode = "git", -- 3279
				output = ____formatGitStatusOutput_result_65, -- 3280
				message = ____temp_66, -- 3281
				interrupted = ____gitRes_interrupted_64, -- 3282
				cleanupError = cleanupError -- 3283
			}) -- 3283
		end -- 3283
		if not Content:move(tempPath, target) then -- 3283
			local cleanupError = cleanupPath(tempPath) -- 3287
			return ____awaiter_resolve( -- 3287
				nil, -- 3287
				{ -- 3288
					success = false, -- 3288
					mode = "git", -- 3288
					output = formatGitStatusOutput(gitRes.status), -- 3288
					message = "failed to move cloned repository into target path", -- 3288
					cleanupError = cleanupError -- 3288
				} -- 3288
			) -- 3288
		end -- 3288
		if not refreshProjectTree(req.workDir) then -- 3288
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 3291
		end -- 3291
		local commit = getGitHeadCommit(target) -- 3293
		local output = table.concat( -- 3294
			__TS__ArrayFilter( -- 3294
				{ -- 3294
					formatGitStatusOutput(gitRes.status), -- 3295
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 3295
					commit ~= nil and "commit " .. commit or "" -- 3297
				}, -- 3297
				function(____, item) return item ~= "" end -- 3298
			), -- 3298
			"\n" -- 3298
		) -- 3298
		return ____awaiter_resolve( -- 3298
			nil, -- 3298
			{ -- 3299
				success = true, -- 3299
				mode = "git", -- 3299
				output = truncateCommandOutput(output) -- 3299
			} -- 3299
		) -- 3299
	end) -- 3299
end -- 3222
local function loadGitProfile() -- 3302
	local rows -- 3303
	do -- 3303
		local function ____catch() -- 3303
			return true, nil -- 3307
		end -- 3307
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 3307
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 3305
		end) -- 3305
		if not ____try then -- 3305
			____hasReturned, ____returnValue = ____catch() -- 3305
		end -- 3305
		if ____hasReturned then -- 3305
			return ____returnValue -- 3304
		end -- 3304
	end -- 3304
	if not rows or not rows[1] then -- 3304
		return nil -- 3309
	end -- 3309
	local name = toStr(rows[1][1]) -- 3310
	local email = toStr(rows[1][2]) -- 3311
	if name == "" and email == "" then -- 3311
		return nil -- 3312
	end -- 3312
	return {name = name, email = email} -- 3313
end -- 3302
local function applyGitProfileToCommit(command) -- 3316
	local args = shellSplit(command) -- 3317
	if args[1] ~= "commit" then -- 3317
		return command -- 3318
	end -- 3318
	local hasName = false -- 3319
	local hasEmail = false -- 3320
	for ____, arg in ipairs(args) do -- 3321
		if arg == "--author-name" then
			hasName = true -- 3322
		end -- 3322
		if arg == "--author-email" then
			hasEmail = true -- 3323
		end -- 3323
	end -- 3323
	if hasName and hasEmail then -- 3323
		return command -- 3325
	end -- 3325
	local profile = loadGitProfile() -- 3326
	if not profile then -- 3326
		return command -- 3327
	end -- 3327
	local additions = {} -- 3328
	if not hasName and profile.name ~= "" then -- 3328
		__TS__ArrayPush( -- 3330
			additions, -- 3330
			"--author-name",
			quoteGitArg(profile.name) -- 3330
		) -- 3330
	end -- 3330
	if not hasEmail and profile.email ~= "" then -- 3330
		__TS__ArrayPush( -- 3333
			additions, -- 3333
			"--author-email",
			quoteGitArg(profile.email) -- 3333
		) -- 3333
	end -- 3333
	if #additions == 0 then -- 3333
		return command -- 3335
	end -- 3335
	return (command .. " ") .. table.concat(additions, " ") -- 3336
end -- 3316
local function executeGitCommand(req) -- 3339
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3339
		local command = normalizeGitCommand(req.command or "") -- 3348
		if command == "" then -- 3348
			return ____awaiter_resolve(nil, { -- 3348
				success = false, -- 3350
				mode = "git", -- 3350
				output = "", -- 3350
				message = "missing command", -- 3350
				phase = "validate" -- 3350
			}) -- 3350
		end -- 3350
		local commandArgs = shellSplit(command) -- 3352
		if #commandArgs == 0 or __TS__StringStartsWith(commandArgs[1], "-") then -- 3352
			return ____awaiter_resolve(nil, { -- 3352
				success = false, -- 3355
				mode = "git", -- 3356
				output = "", -- 3357
				message = "top-level Git options such as -C, --git-dir, and --work-tree are not supported; use the project-relative cwd parameter",
				phase = "validate" -- 3359
			}) -- 3359
		end -- 3359
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 3362
			workDir = req.workDir, -- 3363
			command = command, -- 3364
			operationId = req.operationId, -- 3365
			timeoutSeconds = req.timeoutSeconds, -- 3366
			onProgress = req.onProgress, -- 3367
			isCancelled = req.isCancelled -- 3368
		})) -- 3368
		if cloneResult ~= nil then -- 3368
			return ____awaiter_resolve(nil, cloneResult) -- 3368
		end -- 3368
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 3371
		if not cwd.success then -- 3371
			return ____awaiter_resolve(nil, { -- 3371
				success = false, -- 3373
				mode = "git", -- 3373
				output = "", -- 3373
				cwd = req.cwd, -- 3373
				message = cwd.message, -- 3373
				phase = "validate" -- 3373
			}) -- 3373
		end -- 3373
		command = applyGitProfileToCommit(command) -- 3375
		local ____this_68 -- 3375
		____this_68 = req -- 3376
		local ____opt_67 = ____this_68.onProgress -- 3376
		if ____opt_67 ~= nil then -- 3376
			____opt_67(____this_68, { -- 3376
				state = "pending", -- 3377
				mode = "git", -- 3378
				operationId = req.operationId, -- 3379
				stage = "git", -- 3380
				message = "git command pending", -- 3381
				progress = 0 -- 3382
			}) -- 3382
		end -- 3382
		local gitRes = __TS__Await(runGitAndWait( -- 3384
			cwd.path, -- 3385
			command, -- 3386
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 3387
			function() -- 3388
				local ____this_70 -- 3388
				____this_70 = req -- 3388
				local ____opt_69 = ____this_70.isCancelled -- 3388
				return (____opt_69 and ____opt_69(____this_70)) == true -- 3388
			end, -- 3388
			req.timeoutSeconds -- 3389
		)) -- 3389
		local output = formatGitStatusOutput(gitRes.status) -- 3391
		if not gitRes.success then -- 3391
			local ____output_74 = output -- 3396
			local ____cwd_relative_75 = cwd.relative -- 3397
			local ____temp_76 = gitRes.message or "git command failed" -- 3398
			local ____gitRes_interrupted_73 = gitRes.interrupted -- 3399
			if not ____gitRes_interrupted_73 then -- 3399
				local ____this_72 -- 3399
				____this_72 = req -- 3399
				local ____opt_71 = ____this_72.isCancelled -- 3399
				____gitRes_interrupted_73 = (____opt_71 and ____opt_71(____this_72)) == true -- 3399
			end -- 3399
			return ____awaiter_resolve(nil, { -- 3399
				success = false, -- 3394
				mode = "git", -- 3395
				output = ____output_74, -- 3396
				cwd = ____cwd_relative_75, -- 3397
				message = ____temp_76, -- 3398
				interrupted = ____gitRes_interrupted_73 -- 3399
			}) -- 3399
		end -- 3399
		if not refreshProjectTree(req.workDir) then -- 3399
			Log("Warn", (("[execute_command] failed to refresh Web IDE tree after Git command workDir=" .. req.workDir) .. " cwd=") .. cwd.relative) -- 3403
		end -- 3403
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 3403
	end) -- 3403
end -- 3339
function ____exports.executeCommand(req) -- 3408
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3408
		local mode = req.mode -- 3418
		if mode ~= "lua" and mode ~= "git" then -- 3418
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 3418
		end -- 3418
		if mode == "lua" then -- 3418
			return ____awaiter_resolve( -- 3418
				nil, -- 3418
				executeLuaCommand({ -- 3423
					workDir = req.workDir, -- 3424
					code = req.code or "", -- 3425
					timeoutSeconds = math.max( -- 3426
						1, -- 3426
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 3426
					), -- 3426
					operationId = createOperationId(), -- 3427
					onProgress = req.onProgress, -- 3428
					isCancelled = req.isCancelled -- 3429
				}) -- 3429
			) -- 3429
		end -- 3429
		local operationId = createOperationId() -- 3432
		return ____awaiter_resolve( -- 3432
			nil, -- 3432
			executeGitCommand({ -- 3433
				workDir = req.workDir, -- 3434
				command = req.command or "", -- 3435
				cwd = req.cwd, -- 3436
				timeoutSeconds = math.max( -- 3437
					1, -- 3437
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 3437
				), -- 3437
				operationId = operationId, -- 3438
				onProgress = req.onProgress, -- 3439
				isCancelled = req.isCancelled -- 3440
			}) -- 3440
		) -- 3440
	end) -- 3440
end -- 3408
function ____exports.fetchUrl(req) -- 3444
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3444
		local mode = "download" -- 3451
		local url = __TS__StringTrim(req.url or "") -- 3452
		local targetRel = __TS__StringTrim(req.target or "") -- 3453
		if not isHttpUrl(url) then -- 3453
			return ____awaiter_resolve(nil, { -- 3453
				success = false, -- 3455
				state = "failed", -- 3455
				mode = mode, -- 3455
				target = targetRel, -- 3455
				message = "fetch_url only supports http:// and https:// URLs" -- 3455
			}) -- 3455
		end -- 3455
		if not isSafePublicHttpUrl(url) then -- 3455
			return ____awaiter_resolve(nil, { -- 3455
				success = false, -- 3458
				state = "failed", -- 3458
				mode = mode, -- 3458
				target = targetRel, -- 3458
				message = "fetch_url rejects local, private, metadata, and literal-IP destinations" -- 3458
			}) -- 3458
		end -- 3458
		if targetRel == "" then -- 3458
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 3458
		end -- 3458
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 3463
		if not target then -- 3463
			return ____awaiter_resolve(nil, { -- 3463
				success = false, -- 3465
				state = "failed", -- 3465
				mode = mode, -- 3465
				target = targetRel, -- 3465
				message = "invalid target path" -- 3465
			}) -- 3465
		end -- 3465
		if Content:exist(target) then -- 3465
			return ____awaiter_resolve(nil, { -- 3465
				success = false, -- 3468
				state = "failed", -- 3468
				mode = mode, -- 3468
				target = targetRel, -- 3468
				message = "target already exists" -- 3468
			}) -- 3468
		end -- 3468
		local operationId = createOperationId() -- 3470
		local tempRoot = getAgentDownloadTempRoot() -- 3471
		if not ensureDirPath(tempRoot) then -- 3471
			return ____awaiter_resolve(nil, { -- 3471
				success = false, -- 3473
				state = "failed", -- 3473
				mode = mode, -- 3473
				target = targetRel, -- 3473
				message = "failed to create agent download temp directory" -- 3473
			}) -- 3473
		end -- 3473
		local tempPath = Path(tempRoot, operationId .. ".download") -- 3475
		Content:remove(tempPath) -- 3476
		local function emitProgress(progress) -- 3477
			if not req.onProgress then -- 3477
				return -- 3478
			end -- 3478
			req:onProgress(__TS__ObjectAssign({ -- 3479
				state = "running", -- 3480
				mode = mode, -- 3481
				operationId = operationId, -- 3482
				target = targetRel, -- 3483
				tempPath = tempPath -- 3484
			}, progress)) -- 3484
		end -- 3477
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 3488
		local function interrupted() -- 3493
			local ____this_78 -- 3493
			____this_78 = req -- 3493
			local ____opt_77 = ____this_78.isCancelled -- 3493
			return (____opt_77 and ____opt_77(____this_78)) == true -- 3493
		end -- 3493
		if not ensureDirForFile(tempPath) then -- 3493
			return ____awaiter_resolve(nil, { -- 3493
				success = false, -- 3495
				state = "failed", -- 3495
				mode = mode, -- 3495
				target = targetRel, -- 3495
				message = "failed to create temporary file directory" -- 3495
			}) -- 3495
		end -- 3495
		local downloadRes = __TS__Await(downloadFile({ -- 3497
			url = url, -- 3498
			tempPath = tempPath, -- 3499
			timeout = 600, -- 3500
			isCancelled = interrupted, -- 3501
			onProgress = function(____, current, total) -- 3502
				local totalNumber = type(total) == "number" and total or 0 -- 3503
				emitProgress({ -- 3504
					stage = "download", -- 3505
					message = "downloading", -- 3506
					current = current, -- 3507
					total = total, -- 3508
					progress = totalNumber > 0 and current / totalNumber or nil -- 3509
				}) -- 3509
			end -- 3502
		})) -- 3502
		if not downloadRes.success then -- 3502
			local cleanupError = cleanupPath(tempPath) -- 3514
			return ____awaiter_resolve( -- 3514
				nil, -- 3514
				{ -- 3515
					success = false, -- 3516
					state = "failed", -- 3517
					mode = mode, -- 3518
					target = targetRel, -- 3519
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 3520
					interrupted = downloadRes.interrupted or interrupted(), -- 3521
					cleanupError = cleanupError -- 3522
				} -- 3522
			) -- 3522
		end -- 3522
		if not ensureDirForFile(target) then -- 3522
			local cleanupError = cleanupPath(tempPath) -- 3526
			return ____awaiter_resolve(nil, { -- 3526
				success = false, -- 3527
				state = "failed", -- 3527
				mode = mode, -- 3527
				target = targetRel, -- 3527
				message = "failed to create target directory", -- 3527
				cleanupError = cleanupError -- 3527
			}) -- 3527
		end -- 3527
		if not Content:move(tempPath, target) then -- 3527
			local cleanupError = cleanupPath(tempPath) -- 3530
			return ____awaiter_resolve(nil, { -- 3530
				success = false, -- 3531
				state = "failed", -- 3531
				mode = mode, -- 3531
				target = targetRel, -- 3531
				message = "failed to move downloaded file into target path", -- 3531
				cleanupError = cleanupError -- 3531
			}) -- 3531
		end -- 3531
		local bytesWritten = downloadRes.bytesWritten -- 3533
		local ____try = __TS__AsyncAwaiter(function() -- 3533
			local size = Content:getAttr(target) -- 3535
			if bytesWritten == nil or bytesWritten <= 0 then -- 3535
				bytesWritten = type(size) == "number" and size or nil -- 3537
			end -- 3537
		end) -- 3537
		____try = ____try.catch( -- 3537
			____try, -- 3537
			function(____, _) -- 3537
				return __TS__AsyncAwaiter(function() -- 3537
				end) -- 3537
			end -- 3537
		) -- 3537
		__TS__Await(____try) -- 3534
		if bytesWritten == nil or bytesWritten <= 0 then -- 3534
			local ____try = __TS__AsyncAwaiter(function() -- 3534
				local loaded = Content:load(target) -- 3544
				if type(loaded) == "string" then -- 3544
					bytesWritten = #loaded -- 3546
				end -- 3546
			end) -- 3546
			____try = ____try.catch( -- 3546
				____try, -- 3546
				function(____, _) -- 3546
					return __TS__AsyncAwaiter(function() -- 3546
					end) -- 3546
				end -- 3546
			) -- 3546
			__TS__Await(____try) -- 3543
		end -- 3543
		if not syncDownloadedFileToWebIDE(target) then -- 3543
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 3553
		end -- 3553
		return ____awaiter_resolve(nil, { -- 3553
			success = true, -- 3555
			state = "done", -- 3555
			mode = mode, -- 3555
			target = targetRel, -- 3555
			bytesWritten = bytesWritten -- 3555
		}) -- 3555
	end) -- 3555
end -- 3444
return ____exports -- 3444