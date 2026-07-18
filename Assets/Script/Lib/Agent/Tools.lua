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
local ____Utils = require("Agent.Utils") -- 4
local Log = ____Utils.Log -- 4
local safeJsonDecode = ____Utils.safeJsonDecode -- 4
local safeJsonEncode = ____Utils.safeJsonEncode -- 4
function normalizeEscapedGitQuotes(command) -- 679
	local result = "" -- 680
	do -- 680
		local i = 0 -- 681
		while i < #command do -- 681
			do -- 681
				local ch = __TS__StringCharAt(command, i) -- 682
				local next = __TS__StringCharAt(command, i + 1) -- 683
				if ch == "\\" and (next == "\"" or next == "'") then -- 683
					result = result .. next -- 685
					i = i + 1 -- 686
					goto __continue112 -- 687
				end -- 687
				result = result .. ch -- 689
			end -- 689
			::__continue112:: -- 689
			i = i + 1 -- 681
		end -- 681
	end -- 681
	return result -- 691
end -- 691
function encodeJSON(obj) -- 1201
	local text = safeJsonEncode(obj) -- 1202
	return text -- 1203
end -- 1203
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 1206
	if HttpServer.wsConnectionCount == 0 then -- 1206
		return true -- 1208
	end -- 1208
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 1210
	if not payload then -- 1210
		return false -- 1212
	end -- 1212
	emit("AppWS", "Send", payload) -- 1214
	return true -- 1215
end -- 1206
function getEngineLogText() -- 1544
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 1545
	if not Content:exist(folder) then -- 1545
		Content:mkdir(folder) -- 1547
	end -- 1547
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 1549
	if not App:saveLog(logPath) then -- 1549
		return nil -- 1551
	end -- 1551
	return Content:load(logPath) -- 1553
end -- 1553
function ensureSafeSearchGlobs(globs) -- 1693
	local result = {} -- 1694
	do -- 1694
		local i = 0 -- 1695
		while i < #globs do -- 1695
			result[#result + 1] = globs[i + 1] -- 1696
			i = i + 1 -- 1695
		end -- 1695
	end -- 1695
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1698
	do -- 1698
		local i = 0 -- 1699
		while i < #requiredExcludes do -- 1699
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1699
				result[#result + 1] = requiredExcludes[i + 1] -- 1701
			end -- 1701
			i = i + 1 -- 1699
		end -- 1699
	end -- 1699
	return result -- 1704
end -- 1704
local function recoverJsonStringProperty(text, key) -- 13
	local marker = ("\"" .. key) .. "\"" -- 14
	local markerIndex = (string.find(text, marker, nil, true) or 0) - 1 -- 15
	if markerIndex < 0 then -- 15
		return nil -- 16
	end -- 16
	local colonIndex = (string.find( -- 17
		text, -- 17
		":", -- 17
		math.max(markerIndex + #marker + 1, 1), -- 17
		true -- 17
	) or 0) - 1 -- 17
	if colonIndex < 0 then -- 17
		return nil -- 18
	end -- 18
	local quoteIndex = colonIndex + 1 -- 19
	while quoteIndex < #text do -- 19
		local code = __TS__StringCharCodeAt(text, quoteIndex) -- 21
		if code ~= 32 and code ~= 9 and code ~= 10 and code ~= 13 then -- 21
			break -- 22
		end -- 22
		quoteIndex = quoteIndex + 1 -- 23
	end -- 23
	if quoteIndex >= #text or __TS__StringCharCodeAt(text, quoteIndex) ~= 34 then -- 23
		return nil -- 25
	end -- 25
	local escaped = false -- 26
	do -- 26
		local i = quoteIndex + 1 -- 27
		while i < #text do -- 27
			do -- 27
				local code = __TS__StringCharCodeAt(text, i) -- 28
				if escaped then -- 28
					escaped = false -- 30
					goto __continue9 -- 31
				end -- 31
				if code == 92 then -- 31
					escaped = true -- 34
					goto __continue9 -- 35
				end -- 35
				if code == 34 then -- 35
					local decoded = safeJsonDecode(("{\"value\":" .. __TS__StringSlice(text, quoteIndex, i + 1)) .. "}") -- 38
					if decoded and type(decoded) == "table" and type(decoded.value) == "string" then -- 38
						return {value = decoded.value, complete = true} -- 40
					end -- 40
					return nil -- 42
				end -- 42
			end -- 42
			::__continue9:: -- 42
			i = i + 1 -- 27
		end -- 27
	end -- 27
	local fragment = __TS__StringSlice(text, quoteIndex) -- 45
	do -- 45
		local trim = 0 -- 46
		while trim <= 6 and trim <= #fragment - 1 do -- 46
			local decoded = safeJsonDecode(("{\"value\":" .. __TS__StringSlice(fragment, 0, #fragment - trim)) .. "\"}") -- 47
			if decoded and type(decoded) == "table" and type(decoded.value) == "string" then -- 47
				return {value = decoded.value, complete = false} -- 49
			end -- 49
			trim = trim + 1 -- 46
		end -- 46
	end -- 46
	return nil -- 52
end -- 13
--- Recover only a truncated whole-file overwrite. A truncated replacement with
-- non-empty old_str is unsafe and deliberately returns undefined.
function ____exports.planTruncatedEditRecovery(toolCalls) -- 59
	if not toolCalls or #toolCalls == 0 then -- 59
		return nil -- 62
	end -- 62
	do -- 62
		local i = #toolCalls - 1 -- 63
		while i >= 0 do -- 63
			do -- 63
				local ____opt_0 = toolCalls[i + 1] -- 63
				local fn = ____opt_0 and ____opt_0["function"] -- 64
				if not fn or fn.name ~= "edit_file" or type(fn.arguments) ~= "string" then -- 64
					goto __continue20 -- 65
				end -- 65
				local recovered = recoverJsonStringProperty(fn.arguments, "new_str") -- 66
				if not recovered or recovered.complete or #recovered.value == 0 then -- 66
					goto __continue20 -- 67
				end -- 67
				local target = recoverJsonStringProperty(fn.arguments, "path") or recoverJsonStringProperty(fn.arguments, "target_file") -- 68
				local oldStr = recoverJsonStringProperty(fn.arguments, "old_str") -- 70
				if not target or not target.complete or not oldStr or not oldStr.complete or oldStr.value ~= "" then -- 70
					goto __continue20 -- 71
				end -- 71
				return { -- 72
					target = target.value, -- 73
					receivedText = recovered.value, -- 74
					reason = ((("The response ended while overwriting " .. target.value) .. ". Write the ") .. tostring(#recovered.value)) .. " fully decoded characters directly to that file. This is the complete recoverable prefix; inspect the actual file next and decide whether it already suffices or needs a bounded continuation." -- 75
				} -- 75
			end -- 75
			::__continue20:: -- 75
			i = i - 1 -- 63
		end -- 63
	end -- 63
	return nil -- 78
end -- 59
local TABLE_TASK = "AgentTask" -- 399
local TABLE_CP = "AgentCheckpoint" -- 400
local TABLE_ENTRY = "AgentCheckpointEntry" -- 401
ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 402
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 403
local AGENT_DOWNLOAD_TEMP_DIR = "agent" -- 404
local function now() -- 405
	return os.time() -- 405
end -- 405
local function toBool(v) -- 407
	return v ~= 0 and v ~= false and v ~= nil -- 408
end -- 407
local function toStr(v) -- 411
	if v == false or v == nil then -- 411
		return "" -- 412
	end -- 412
	return tostring(v) -- 413
end -- 411
local function isValidWorkspacePath(path) -- 416
	if not path or #path == 0 then -- 416
		return false -- 417
	end -- 417
	if Content:isAbsolutePath(path) then -- 417
		return false -- 418
	end -- 418
	if __TS__StringIncludes(path, "..") then -- 418
		return false -- 419
	end -- 419
	return true -- 420
end -- 416
local function isValidWorkDir(workDir) -- 423
	if not workDir or #workDir == 0 then -- 423
		return false -- 424
	end -- 424
	if not Content:isAbsolutePath(workDir) then -- 424
		return false -- 425
	end -- 425
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 425
		return false -- 426
	end -- 426
	return true -- 427
end -- 423
local function isValidSearchPath(path) -- 430
	if path == "" then -- 430
		return true -- 431
	end -- 431
	if Content:isAbsolutePath(path) then -- 431
		return false -- 432
	end -- 432
	if not path or #path == 0 then -- 432
		return false -- 433
	end -- 433
	if __TS__StringIncludes(path, "..") then -- 433
		return false -- 434
	end -- 434
	return true -- 435
end -- 430
local function resolveWorkspaceFilePath(workDir, path) -- 438
	if not isValidWorkDir(workDir) then -- 438
		return nil -- 439
	end -- 439
	if not isValidWorkspacePath(path) then -- 439
		return nil -- 440
	end -- 440
	return Path(workDir, path) -- 441
end -- 438
local function resolveWorkspaceSearchPath(workDir, path) -- 444
	if not isValidWorkDir(workDir) then -- 444
		return nil -- 445
	end -- 445
	if not isValidSearchPath(path) then -- 445
		return nil -- 446
	end -- 446
	return path == "" and workDir or Path(workDir, path) -- 447
end -- 444
local function toWorkspaceRelativePath(workDir, path) -- 450
	if not path or #path == 0 then -- 450
		return path -- 451
	end -- 451
	if not Content:isAbsolutePath(path) then -- 451
		return path -- 452
	end -- 452
	return Path:getRelative(path, workDir) -- 453
end -- 450
local function toWorkspaceRelativeFileList(workDir, files) -- 456
	return __TS__ArrayMap( -- 457
		files, -- 457
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 457
	) -- 457
end -- 456
local function toWorkspaceRelativeSearchResults(workDir, results) -- 460
	local mapped = {} -- 461
	do -- 461
		local i = 0 -- 462
		while i < #results do -- 462
			local row = results[i + 1] -- 463
			local clone = __TS__ObjectAssign({}, row) -- 464
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 465
			mapped[#mapped + 1] = clone -- 466
			i = i + 1 -- 462
		end -- 462
	end -- 462
	return mapped -- 468
end -- 460
local function resolveWorkspaceDirectoryPath(workDir, path) -- 471
	local relative = __TS__StringTrim(path or "") -- 472
	if relative == "" then -- 472
		return {success = true, path = workDir, relative = "."} -- 474
	end -- 474
	if not isValidWorkDir(workDir) or not isValidWorkspacePath(relative) then -- 474
		return {success = false, message = "invalid cwd path"} -- 477
	end -- 477
	local resolved = Path(workDir, relative) -- 479
	if not Content:exist(resolved) then -- 479
		return {success = false, message = "cwd does not exist"} -- 481
	end -- 481
	if not Content:isdir(resolved) then -- 481
		return {success = false, message = "cwd is not a directory"} -- 484
	end -- 484
	return {success = true, path = resolved, relative = relative} -- 486
end -- 471
local function getDoraAPIDocRoot(docLanguage) -- 489
	local zhDir = Path( -- 490
		Content.assetPath, -- 490
		"Script", -- 490
		"Lib", -- 490
		"Dora", -- 490
		"zh-Hans" -- 490
	) -- 490
	local enDir = Path( -- 491
		Content.assetPath, -- 491
		"Script", -- 491
		"Lib", -- 491
		"Dora", -- 491
		"en" -- 491
	) -- 491
	return docLanguage == "zh" and zhDir or enDir -- 492
end -- 489
local function getDoraTutorialDocRoot(docLanguage) -- 495
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 496
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 497
	return docLanguage == "zh" and zhDir or enDir -- 498
end -- 495
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 501
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 501
		return {"ts"} -- 503
	end -- 503
	return {"tl"} -- 505
end -- 501
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 508
	repeat -- 508
		local ____switch65 = programmingLanguage -- 508
		local ____cond65 = ____switch65 == "teal" -- 508
		if ____cond65 then -- 508
			return "tl" -- 510
		end -- 510
		____cond65 = ____cond65 or ____switch65 == "tl" -- 510
		if ____cond65 then -- 510
			return "tl" -- 511
		end -- 511
		do -- 511
			return programmingLanguage -- 512
		end -- 512
	until true -- 512
end -- 508
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 516
	if docSource == "tutorial" then -- 516
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 522
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 523
		return { -- 524
			root = Path(tutorialRoot, langDir), -- 525
			exts = {"md"}, -- 526
			globs = {"**/*.md"} -- 527
		} -- 527
	end -- 527
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 530
	return { -- 531
		root = getDoraAPIDocRoot(docLanguage), -- 532
		exts = exts, -- 533
		globs = __TS__ArrayMap( -- 534
			exts, -- 534
			function(____, ext) return "**/*." .. ext end -- 534
		) -- 534
	} -- 534
end -- 516
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 538
	if docSource == "tutorial" then -- 538
		return getDoraTutorialDocRoot(docLanguage) -- 540
	end -- 540
	return getDoraAPIDocRoot(docLanguage) -- 542
end -- 538
local AGENT_DORA_DOC_PREFIX = "@dora-doc/" -- 545
local function toDocRelativePath(baseRoot, path, docSource) -- 547
	if not path or #path == 0 then -- 547
		return path -- 548
	end -- 548
	local relative = Content:isAbsolutePath(path) and Path:getRelative(path, baseRoot) or path -- 549
	return ((AGENT_DORA_DOC_PREFIX .. docSource) .. "/") .. relative -- 550
end -- 547
local function resolveAgentDoraDocFilePath(path, docLanguage) -- 553
	if not docLanguage then -- 553
		return nil -- 554
	end -- 554
	local relative = path -- 555
	local source = "tutorial" -- 556
	if __TS__StringStartsWith(path, AGENT_DORA_DOC_PREFIX) then -- 556
		local namespaced = __TS__StringSlice(path, #AGENT_DORA_DOC_PREFIX) -- 558
		if __TS__StringStartsWith(namespaced, "api/") then -- 558
			source = "api" -- 560
			relative = string.sub(namespaced, 5) -- 561
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 561
			relative = string.sub(namespaced, 10) -- 563
		else -- 563
			return nil -- 565
		end -- 565
	end -- 565
	if not isValidWorkspacePath(relative) then -- 565
		return nil -- 568
	end -- 568
	local candidate = Path( -- 569
		getDoraDocResultBaseRoot(source, docLanguage), -- 569
		relative -- 569
	) -- 569
	local root = getDoraDocResultBaseRoot(source, docLanguage) -- 570
	local checked = Path:getRelative(candidate, root) -- 571
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 571
		return nil -- 572
	end -- 572
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 572
		return candidate -- 574
	end -- 574
	return nil -- 576
end -- 553
local function ensureDirPath(dir) -- 579
	if not dir or dir == "." or dir == "" then -- 579
		return true -- 580
	end -- 580
	if Content:exist(dir) then -- 580
		return Content:isdir(dir) -- 581
	end -- 581
	local parent = Path:getPath(dir) -- 582
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 582
		if not ensureDirPath(parent) then -- 582
			return false -- 584
		end -- 584
	end -- 584
	return Content:mkdir(dir) -- 586
end -- 579
local function ensureDirForFile(path) -- 589
	local dir = Path:getPath(path) -- 590
	return ensureDirPath(dir) -- 591
end -- 589
local function isHttpUrl(url) -- 594
	local normalized = string.lower(__TS__StringTrim(url)) -- 595
	return __TS__StringStartsWith(normalized, "http://") or __TS__StringStartsWith(normalized, "https://") -- 596
end -- 594
local function createOperationId() -- 599
	local raw = (tostring(os.time()) .. "-") .. tostring(math.floor(math.random() * 1000000000)) -- 600
	local safe = string.gsub(raw, "[^%w%-_]", "-") -- 601
	return safe -- 602
end -- 599
local function getAgentDownloadTempRoot() -- 605
	return Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR, AGENT_DOWNLOAD_TEMP_DIR) -- 606
end -- 605
local function cleanupPath(path) -- 609
	if not path or path == "" or not Content:exist(path) then -- 609
		return nil -- 610
	end -- 610
	if Content:remove(path) then -- 610
		return nil -- 611
	end -- 611
	return "failed to remove temporary path: " .. path -- 612
end -- 609
local function quoteGitArg(value) -- 615
	local plain = string.match(value, "^[%w%._%-%/]+$") -- 616
	if plain ~= nil then -- 616
		return value -- 618
	end -- 618
	local escaped = string.gsub(value, "\\", "\\\\") -- 620
	escaped = string.gsub(escaped, "\"", "\\\"") -- 621
	return ("\"" .. escaped) .. "\"" -- 622
end -- 615
local function shellSplit(command) -- 625
	local args = {} -- 626
	local current = "" -- 627
	local quote = "" -- 628
	local escaped = false -- 629
	do -- 629
		local i = 0 -- 630
		while i < #command do -- 630
			do -- 630
				local ch = __TS__StringCharAt(command, i) -- 631
				if escaped then -- 631
					current = current .. ch -- 633
					escaped = false -- 634
					goto __continue98 -- 635
				end -- 635
				if ch == "\\" then -- 635
					escaped = true -- 638
					goto __continue98 -- 639
				end -- 639
				if quote ~= "" then -- 639
					if ch == quote then -- 639
						quote = "" -- 643
					else -- 643
						current = current .. ch -- 645
					end -- 645
					goto __continue98 -- 647
				end -- 647
				if ch == "'" or ch == "\"" then -- 647
					quote = ch -- 650
					goto __continue98 -- 651
				end -- 651
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 651
					if current ~= "" then -- 651
						args[#args + 1] = current -- 655
						current = "" -- 656
					end -- 656
					goto __continue98 -- 658
				end -- 658
				current = current .. ch -- 660
			end -- 660
			::__continue98:: -- 660
			i = i + 1 -- 630
		end -- 630
	end -- 630
	if escaped then -- 630
		current = current .. "\\" -- 663
	end -- 663
	if current ~= "" then -- 663
		args[#args + 1] = current -- 666
	end -- 666
	return args -- 668
end -- 625
local function normalizeGitCommand(command) -- 671
	local trimmed = __TS__StringTrim(command) -- 672
	local normalized = string.lower(string.sub(trimmed, 1, 4)) == "git " and __TS__StringTrim(string.sub(trimmed, 5)) or trimmed -- 673
	return normalizeEscapedGitQuotes(normalized) -- 676
end -- 671
local function gitDefaultTargetFromUrl(url) -- 694
	local target = url -- 695
	local hashIndex = (string.find(target, "#", nil, true) or 0) - 1 -- 696
	if hashIndex >= 0 then -- 696
		target = __TS__StringSlice(target, 0, hashIndex) -- 697
	end -- 697
	local queryIndex = (string.find(target, "?", nil, true) or 0) - 1 -- 698
	if queryIndex >= 0 then -- 698
		target = __TS__StringSlice(target, 0, queryIndex) -- 699
	end -- 699
	target = string.gsub(target, "/+$", "") -- 700
	local name = string.match(target, "([^/]+)$") -- 701
	if name ~= nil and name ~= "" then -- 701
		target = name -- 702
	end -- 702
	if __TS__StringEndsWith( -- 702
		string.lower(target), -- 703
		".git" -- 703
	) then -- 703
		target = __TS__StringSlice(target, 0, #target - 4) -- 704
	end -- 704
	return target ~= "" and target or "repo" -- 706
end -- 694
local function parseGitCloneCommand(command) -- 709
	local args = shellSplit(normalizeGitCommand(command)) -- 719
	if #args == 0 or args[1] ~= "clone" then -- 719
		return nil -- 720
	end -- 720
	local url = "" -- 721
	local target = "" -- 722
	local ref -- 723
	local depth -- 724
	do -- 724
		local i = 1 -- 725
		while i < #args do -- 725
			do -- 725
				local arg = args[i + 1] -- 726
				if arg == "-b" or arg == "--branch" then
					i = i + 1 -- 728
					if i >= #args then -- 728
						return {success = false, message = arg .. " requires a value"} -- 729
					end -- 729
					ref = args[i + 1] -- 730
					goto __continue122 -- 731
				end -- 731
				if arg == "--depth" then
					i = i + 1 -- 734
					if i >= #args then -- 734
						return {success = false, message = "--depth requires a value"}
					end -- 735
					depth = args[i + 1] -- 736
					goto __continue122 -- 737
				end -- 737
				if __TS__StringStartsWith(arg, "--depth=") then
					depth = __TS__StringSlice(arg, #"--depth=")
					goto __continue122 -- 741
				end -- 741
				if __TS__StringStartsWith(arg, "-") then -- 741
					return {success = false, message = "unsupported clone option: " .. arg} -- 744
				end -- 744
				if url == "" then -- 744
					url = arg -- 747
					goto __continue122 -- 748
				end -- 748
				if target == "" then -- 748
					target = arg -- 751
					goto __continue122 -- 752
				end -- 752
				return {success = false, message = "unexpected clone argument: " .. arg} -- 754
			end -- 754
			::__continue122:: -- 754
			i = i + 1 -- 725
		end -- 725
	end -- 725
	if url == "" then -- 725
		return {success = false, message = "git clone requires a URL"} -- 756
	end -- 756
	if not isHttpUrl(url) then -- 756
		return {success = false, message = "git clone only supports http:// and https:// URLs"} -- 757
	end -- 757
	if target == "" then -- 757
		target = gitDefaultTargetFromUrl(url) -- 758
	end -- 758
	return { -- 759
		success = true, -- 760
		url = url, -- 761
		target = target, -- 762
		ref = ref, -- 763
		depth = depth ~= nil and depth ~= "" and depth or "1" -- 764
	} -- 764
end -- 709
local function getGitHeadCommit(repoPath) -- 768
	local headPath = Path(repoPath, ".git", "HEAD") -- 769
	if not Content:exist(headPath) then -- 769
		return nil -- 770
	end -- 770
	local head = __TS__StringTrim(toStr(Content:load(headPath))) -- 771
	local ref = string.match(head, "^ref:%s*(.-)%s*$") -- 772
	if ref ~= nil and ref ~= "" then -- 772
		local refPath = Path(repoPath, ".git", ref) -- 774
		if Content:exist(refPath) then -- 774
			local commit = __TS__StringTrim(toStr(Content:load(refPath))) -- 776
			return commit ~= "" and commit or nil -- 777
		end -- 777
		return nil -- 779
	end -- 779
	return head ~= "" and head or nil -- 781
end -- 768
local function runGitAndWait(repoPath, command, onStatus, isCancelled, timeout) -- 784
	if timeout == nil then -- 784
		timeout = 600 -- 789
	end -- 789
	return __TS__New( -- 791
		__TS__Promise, -- 791
		function(____, resolve) -- 791
			local status -- 792
			local jobId = 0 -- 793
			local settled = false -- 794
			local canceled = false -- 795
			local function finish(result) -- 796
				if settled then -- 796
					return -- 797
				end -- 797
				settled = true -- 798
				resolve(nil, result) -- 799
			end -- 796
			local function finishFromStatus() -- 801
				local state = toStr(status and status.state) -- 802
				if state == "done" then -- 802
					finish({success = true, status = status}) -- 804
					return true -- 805
				end -- 805
				if state == "error" or state == "canceled" then -- 805
					local errorMessage = toStr(status and status.error) -- 808
					local statusMessage = toStr(status and status.message) -- 809
					finish({success = false, message = errorMessage ~= "" and errorMessage or (statusMessage ~= "" and statusMessage or (state == "canceled" and "git command canceled" or "git command failed")), status = status, interrupted = state == "canceled"}) -- 810
					return true -- 816
				end -- 816
				return false -- 818
			end -- 801
			jobId = Git:run( -- 820
				repoPath, -- 820
				command, -- 820
				function(nextStatus) -- 820
					status = nextStatus -- 821
					if onStatus then -- 821
						onStatus(status) -- 822
					end -- 822
					return finishFromStatus() -- 823
				end, -- 820
				"" -- 824
			) -- 824
			if jobId == nil or jobId <= 0 then -- 824
				finish({success = false, message = "failed to start git command"}) -- 826
				return -- 827
			end -- 827
			if not status then -- 827
				local kind = string.match(command, "^(%S+)") -- 830
				status = { -- 831
					id = jobId, -- 832
					state = "queued", -- 833
					kind = toStr(kind), -- 834
					repoPath = repoPath, -- 835
					progress = 0, -- 836
					message = "queued" -- 837
				} -- 837
			end -- 837
			if onStatus then -- 837
				onStatus(status) -- 840
			end -- 840
			local startedAt = os.time() -- 841
			local lastEmitAt = startedAt -- 842
			Director.systemScheduler:schedule(function() -- 843
				if settled then -- 843
					return true -- 844
				end -- 844
				if not canceled and isCancelled and isCancelled() then -- 844
					canceled = true -- 846
					Git:cancel(jobId) -- 847
					finish({success = false, message = "git command canceled", status = status, interrupted = true}) -- 848
					return true -- 849
				end -- 849
				if finishFromStatus() then -- 849
					return true -- 851
				end -- 851
				local nowTime = os.time() -- 852
				if nowTime - startedAt >= timeout then -- 852
					Git:cancel(jobId) -- 854
					finish({success = false, message = "git command timed out", status = status}) -- 855
					return true -- 856
				end -- 856
				if onStatus and status and nowTime > lastEmitAt then -- 856
					lastEmitAt = nowTime -- 859
					onStatus(status) -- 860
				end -- 860
				return false -- 862
			end) -- 843
		end -- 791
	) -- 791
end -- 784
local function downloadFile(req) -- 867
	return __TS__New( -- 874
		__TS__Promise, -- 874
		function(____, resolve) -- 874
			local requestId = 0 -- 875
			local settled = false -- 876
			local bytesWritten = 0 -- 877
			local function finish(result) -- 878
				if settled then -- 878
					return -- 879
				end -- 879
				settled = true -- 880
				requestId = 0 -- 881
				resolve(nil, result) -- 882
			end -- 878
			Director.systemScheduler:schedule(function() -- 884
				if settled then -- 884
					return true -- 885
				end -- 885
				local ____this_9 -- 885
				____this_9 = req -- 886
				local ____opt_8 = ____this_9.isCancelled -- 886
				if (____opt_8 and ____opt_8(____this_9)) == true and requestId ~= 0 then -- 886
					HttpClient:cancel(requestId) -- 887
					finish({success = false, interrupted = true, message = "download canceled"}) -- 888
					return true -- 889
				end -- 889
				if requestId ~= 0 and not HttpClient:isRequestActive(requestId) then -- 889
					finish({success = false, message = "download request ended without a completion callback"}) -- 892
					return true -- 893
				end -- 893
				return false -- 895
			end) -- 884
			Director.systemScheduler:schedule(once(function() -- 897
				requestId = HttpClient:download( -- 898
					req.url, -- 898
					req.tempPath, -- 898
					req.timeout, -- 898
					function(interrupted, current, total) -- 898
						if type(current) == "number" and current > bytesWritten then -- 898
							bytesWritten = current -- 900
						end -- 900
						if interrupted then -- 900
							finish({success = false, interrupted = true, message = "download failed"}) -- 903
							return true -- 904
						end -- 904
						local ____this_11 -- 904
						____this_11 = req -- 906
						local ____opt_10 = ____this_11.isCancelled -- 906
						if (____opt_10 and ____opt_10(____this_11)) == true then -- 906
							finish({success = false, interrupted = true, message = "download canceled"}) -- 907
							return true -- 908
						end -- 908
						if current == total then -- 908
							finish({success = true, bytesWritten = bytesWritten}) -- 911
							return false -- 912
						end -- 912
						req:onProgress(current, total) -- 914
						return false -- 915
					end -- 898
				) -- 898
				if requestId == 0 then -- 898
					finish({success = false, message = "failed to schedule download request"}) -- 918
				else -- 918
					local ____this_13 -- 918
					____this_13 = req -- 919
					local ____opt_12 = ____this_13.isCancelled -- 919
					if (____opt_12 and ____opt_12(____this_13)) == true then -- 919
						HttpClient:cancel(requestId) -- 920
						finish({success = false, interrupted = true, message = "download canceled"}) -- 921
					end -- 921
				end -- 921
			end)) -- 897
		end -- 874
	) -- 874
end -- 867
local function getFileState(path) -- 927
	local exists = Content:exist(path) -- 928
	if not exists then -- 928
		return {exists = false, content = "", bytes = 0} -- 930
	end -- 930
	if Content:isdir(path) then -- 930
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 937
	end -- 937
	local content = Content:load(path) -- 944
	if type(content) ~= "string" then -- 944
		return {exists = true, content = "", bytes = 0} -- 946
	end -- 946
	return {exists = true, content = content, bytes = #content} -- 952
end -- 927
local function inspectReadableFile(path) -- 959
	do -- 959
		local function ____catch(e) -- 959
			Log( -- 981
				"Warn", -- 981
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 981
			) -- 981
			return true, {success = true} -- 982
		end -- 982
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 982
			local size, isBinary = Content:getAttr(path) -- 961
			if size == nil then -- 961
				return true, {success = false, message = "failed to read file"} -- 963
			end -- 963
			if isBinary then -- 963
				return true, { -- 969
					success = false, -- 970
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 971
					size = type(size) == "number" and size or nil, -- 972
					isBinary = true -- 973
				} -- 973
			end -- 973
			return true, { -- 976
				success = true, -- 977
				size = type(size) == "number" and size or nil -- 978
			} -- 978
		end) -- 978
		if not ____try then -- 978
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 978
		end -- 978
		if ____hasReturned then -- 978
			return ____returnValue -- 960
		end -- 960
	end -- 960
end -- 959
local function isEngineLogFilePath(path) -- 986
	return path == ENGINE_LOG_FILE -- 987
end -- 986
local function readEngineLogFile(path) -- 990
	if not isEngineLogFilePath(path) then -- 990
		return nil -- 991
	end -- 991
	local content = getEngineLogText() -- 992
	if content == nil then -- 992
		return {success = false, message = "failed to read engine logs"} -- 994
	end -- 994
	return {success = true, content = content, size = #content} -- 996
end -- 990
local function queryOne(sql, args) -- 999
	local ____args_14 -- 1000
	if args then -- 1000
		____args_14 = DB:query(sql, args) -- 1000
	else -- 1000
		____args_14 = DB:query(sql) -- 1000
	end -- 1000
	local rows = ____args_14 -- 1000
	if not rows or #rows == 0 then -- 1000
		return nil -- 1001
	end -- 1001
	return rows[1] -- 1002
end -- 999
do -- 999
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1007
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 1015
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 1026
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 1027
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 1040
end -- 1040
local function isDtsFile(path) -- 1043
	return Path:getExt(Path:getName(path)) == "d" -- 1044
end -- 1043
local function isTiledEditorContent(content) -- 1047
	return __TS__StringStartsWith( -- 1048
		__TS__StringTrim(content), -- 1048
		"<?xml" -- 1048
	) -- 1048
end -- 1047
local function getSupportedBuildKind(path) -- 1053
	repeat -- 1053
		local ____switch191 = Path:getExt(path) -- 1053
		local ____cond191 = ____switch191 == "ts" or ____switch191 == "tsx" -- 1053
		if ____cond191 then -- 1053
			return "ts" -- 1055
		end -- 1055
		____cond191 = ____cond191 or ____switch191 == "xml" -- 1055
		if ____cond191 then -- 1055
			return "xml" -- 1056
		end -- 1056
		____cond191 = ____cond191 or ____switch191 == "tl" -- 1056
		if ____cond191 then -- 1056
			return "teal" -- 1057
		end -- 1057
		____cond191 = ____cond191 or ____switch191 == "lua" -- 1057
		if ____cond191 then -- 1057
			return "lua" -- 1058
		end -- 1058
		____cond191 = ____cond191 or ____switch191 == "yue" -- 1058
		if ____cond191 then -- 1058
			return "yue" -- 1059
		end -- 1059
		____cond191 = ____cond191 or ____switch191 == "yarn" -- 1059
		if ____cond191 then -- 1059
			return "yarn" -- 1060
		end -- 1060
		do -- 1060
			return nil -- 1061
		end -- 1061
	until true -- 1061
end -- 1053
local function getTaskHeadSeq(taskId) -- 1065
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1066
	if not row then -- 1066
		return nil -- 1067
	end -- 1067
	return row[1] or 0 -- 1068
end -- 1065
local function getTaskStatus(taskId) -- 1071
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1072
	if not row then -- 1072
		return nil -- 1073
	end -- 1073
	return toStr(row[1]) -- 1074
end -- 1071
local function getLastInsertRowId() -- 1077
	local row = queryOne("SELECT last_insert_rowid()") -- 1078
	return row and (row[1] or 0) or 0 -- 1079
end -- 1077
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 1082
	DB:exec( -- 1083
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 1083
		{ -- 1085
			taskId, -- 1085
			seq, -- 1085
			status, -- 1085
			summary, -- 1085
			toolName, -- 1085
			now() -- 1085
		} -- 1085
	) -- 1085
	return getLastInsertRowId() -- 1087
end -- 1082
local function getCheckpointEntries(checkpointId, desc) -- 1090
	if desc == nil then -- 1090
		desc = false -- 1090
	end -- 1090
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 1091
	if not rows then -- 1091
		return {} -- 1098
	end -- 1098
	local result = {} -- 1099
	do -- 1099
		local i = 0 -- 1100
		while i < #rows do -- 1100
			local row = rows[i + 1] -- 1101
			result[#result + 1] = { -- 1102
				id = row[1], -- 1103
				ord = row[2], -- 1104
				path = toStr(row[3]), -- 1105
				op = toStr(row[4]), -- 1106
				beforeExists = toBool(row[5]), -- 1107
				beforeContent = toStr(row[6]), -- 1108
				afterExists = toBool(row[7]), -- 1109
				afterContent = toStr(row[8]) -- 1110
			} -- 1110
			i = i + 1 -- 1100
		end -- 1100
	end -- 1100
	return result -- 1113
end -- 1090
local function rejectDuplicatePaths(changes) -- 1116
	local seen = __TS__New(Set) -- 1117
	for ____, change in ipairs(changes) do -- 1118
		local key = change.path -- 1119
		if seen:has(key) then -- 1119
			return key -- 1120
		end -- 1120
		seen:add(key) -- 1121
	end -- 1121
	return nil -- 1123
end -- 1116
local function getLinkedDeletePaths(workDir, path) -- 1126
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1127
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 1127
		return {} -- 1128
	end -- 1128
	local parent = Path:getPath(fullPath) -- 1129
	local baseName = string.lower(Path:getName(fullPath)) -- 1130
	local ext = Path:getExt(fullPath) -- 1131
	local linked = {} -- 1132
	for ____, file in ipairs(Content:getFiles(parent)) do -- 1133
		do -- 1133
			if string.lower(Path:getName(file)) ~= baseName then -- 1133
				goto __continue208 -- 1134
			end -- 1134
			local siblingExt = Path:getExt(file) -- 1135
			if siblingExt == "tl" and ext == "vs" then -- 1135
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1137
					workDir, -- 1137
					Path(parent, file) -- 1137
				) -- 1137
				goto __continue208 -- 1138
			end -- 1138
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 1138
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1141
					workDir, -- 1141
					Path(parent, file) -- 1141
				) -- 1141
			end -- 1141
		end -- 1141
		::__continue208:: -- 1141
	end -- 1141
	return linked -- 1144
end -- 1126
local function expandLinkedDeleteChanges(workDir, changes) -- 1147
	local expanded = {} -- 1148
	local seen = __TS__New(Set) -- 1149
	do -- 1149
		local i = 0 -- 1150
		while i < #changes do -- 1150
			do -- 1150
				local change = changes[i + 1] -- 1151
				if not seen:has(change.path) then -- 1151
					seen:add(change.path) -- 1153
					expanded[#expanded + 1] = change -- 1154
				end -- 1154
				if change.op ~= "delete" then -- 1154
					goto __continue215 -- 1156
				end -- 1156
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 1157
				do -- 1157
					local j = 0 -- 1158
					while j < #linkedPaths do -- 1158
						do -- 1158
							local linkedPath = linkedPaths[j + 1] -- 1159
							if seen:has(linkedPath) then -- 1159
								goto __continue219 -- 1160
							end -- 1160
							seen:add(linkedPath) -- 1161
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 1162
						end -- 1162
						::__continue219:: -- 1162
						j = j + 1 -- 1158
					end -- 1158
				end -- 1158
			end -- 1158
			::__continue215:: -- 1158
			i = i + 1 -- 1150
		end -- 1150
	end -- 1150
	return expanded -- 1165
end -- 1147
local function applySingleFile(path, exists, content) -- 1168
	if exists then -- 1168
		if not ensureDirForFile(path) then -- 1168
			return false -- 1170
		end -- 1170
		return Content:save(path, content) -- 1171
	end -- 1171
	if Content:exist(path) then -- 1171
		return Content:remove(path) -- 1174
	end -- 1174
	return true -- 1176
end -- 1168
local function rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 1179
	local entries = getCheckpointEntries(checkpointId, true) -- 1184
	local remaining = appliedCount -- 1185
	local failures = {} -- 1186
	do -- 1186
		local i = 0 -- 1187
		while i < #entries and remaining > 0 do -- 1187
			do -- 1187
				local entry = entries[i + 1] -- 1188
				if entry.ord > appliedCount then -- 1188
					goto __continue227 -- 1189
				end -- 1189
				local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1190
				if not fullPath or not applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) then -- 1190
					failures[#failures + 1] = entry.path -- 1192
				else -- 1192
					____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) -- 1194
				end -- 1194
				remaining = remaining - 1 -- 1196
			end -- 1196
			::__continue227:: -- 1196
			i = i + 1 -- 1187
		end -- 1187
	end -- 1187
	return #failures > 0 and "rollback failed for: " .. table.concat(failures, ", ") or nil -- 1198
end -- 1179
function ____exports.sendWebIDERefreshTree() -- 1218
	if HttpServer.wsConnectionCount == 0 then -- 1218
		return true -- 1220
	end -- 1220
	local payload = encodeJSON({name = "RefreshTree"}) -- 1222
	if not payload then -- 1222
		return false -- 1224
	end -- 1224
	emit("AppWS", "Send", payload) -- 1226
	return true -- 1227
end -- 1218
local function syncProjectFileToWebIDE(workDir, path) -- 1230
	local target = resolveWorkspaceFilePath(workDir, path) -- 1231
	if not target then -- 1231
		return false -- 1232
	end -- 1232
	if not Content:exist(target) then -- 1232
		return ____exports.sendWebIDEFileUpdate(target, false, "") -- 1234
	end -- 1234
	if Content:isdir(target) then -- 1234
		return ____exports.sendWebIDERefreshTree() -- 1237
	end -- 1237
	local content = "" -- 1239
	do -- 1239
		local function ____catch(e) -- 1239
			Log( -- 1247
				"Warn", -- 1247
				(("[Agent.Tools] failed to inspect file for Web IDE update file=" .. target) .. ": ") .. tostring(e) -- 1247
			) -- 1247
		end -- 1247
		local ____try, ____hasReturned = pcall(function() -- 1247
			local ____, isBinary = Content:getAttr(target) -- 1241
			if not isBinary then -- 1241
				local loaded = Content:load(target) -- 1243
				content = type(loaded) == "string" and loaded or "" -- 1244
			end -- 1244
		end) -- 1244
		if not ____try then -- 1244
			____catch(____hasReturned) -- 1244
		end -- 1244
	end -- 1244
	return ____exports.sendWebIDEFileUpdate(target, true, content) -- 1249
end -- 1230
local function refreshProjectTree(workDir, path) -- 1252
	local normalized = type(path) == "string" and __TS__StringTrim(path) or "" -- 1253
	if normalized == "" then -- 1253
		return ____exports.sendWebIDERefreshTree() -- 1255
	end -- 1255
	return syncProjectFileToWebIDE(workDir, normalized) -- 1257
end -- 1252
local function syncDownloadedFileToWebIDE(file) -- 1260
	local content = "" -- 1261
	do -- 1261
		local function ____catch(e) -- 1261
			Log( -- 1269
				"Warn", -- 1269
				(("[fetch_url] failed to inspect downloaded file for Web IDE update file=" .. file) .. ": ") .. tostring(e) -- 1269
			) -- 1269
		end -- 1269
		local ____try, ____hasReturned = pcall(function() -- 1269
			local ____, isBinary = Content:getAttr(file) -- 1263
			if not isBinary then -- 1263
				local loaded = Content:load(file) -- 1265
				content = type(loaded) == "string" and loaded or "" -- 1266
			end -- 1266
		end) -- 1266
		if not ____try then -- 1266
			____catch(____hasReturned) -- 1266
		end -- 1266
	end -- 1266
	return ____exports.sendWebIDEFileUpdate(file, true, content) -- 1271
end -- 1260
local function runSingleNonTsBuild(file) -- 1274
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1274
		return ____awaiter_resolve( -- 1274
			nil, -- 1274
			__TS__New( -- 1275
				__TS__Promise, -- 1275
				function(____, resolve) -- 1275
					local moduleName = "Script.Dev.WebServer" -- 1276
					local ____require_result_15 = require(moduleName) -- 1277
					local buildAsync = ____require_result_15.buildAsync -- 1277
					Director.systemScheduler:schedule(once(function() -- 1278
						local result = buildAsync(file) -- 1279
						resolve(nil, result) -- 1280
					end)) -- 1278
				end -- 1275
			) -- 1275
		) -- 1275
	end) -- 1275
end -- 1274
local transpileRequestSeq = 0 -- 1285
function ____exports.runSingleTsTranspile(file, content, projectRoot) -- 1287
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1287
		local done = false -- 1288
		transpileRequestSeq = transpileRequestSeq + 1 -- 1289
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 1290
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 1291
		if HttpServer.wsConnectionCount == 0 then -- 1291
			return ____awaiter_resolve(nil, result) -- 1291
		end -- 1291
		local listener = Node() -- 1299
		listener:gslot( -- 1300
			"AppWS", -- 1300
			function(event) -- 1300
				if event.type ~= "Receive" then -- 1300
					return -- 1301
				end -- 1301
				local res = safeJsonDecode(event.msg) -- 1302
				if not res or __TS__ArrayIsArray(res) then -- 1302
					return -- 1303
				end -- 1303
				local payload = res -- 1304
				if payload.name ~= "TranspileTS" then -- 1304
					return -- 1305
				end -- 1305
				if payload.id ~= requestId then -- 1305
					return -- 1306
				end -- 1306
				if payload.success then -- 1306
					local luaFile = Path:replaceExt(file, "lua") -- 1308
					if Content:save( -- 1308
						luaFile, -- 1309
						tostring(payload.luaCode) -- 1309
					) then -- 1309
						result = {success = true, file = file} -- 1310
					else -- 1310
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 1312
					end -- 1312
				else -- 1312
					result = { -- 1315
						success = false, -- 1315
						file = file, -- 1315
						message = tostring(payload.message) -- 1315
					} -- 1315
				end -- 1315
				done = true -- 1317
			end -- 1300
		) -- 1300
		local payload = encodeJSON({ -- 1319
			name = "TranspileTS", -- 1320
			id = requestId, -- 1321
			file = file, -- 1322
			content = content, -- 1323
			projectRoot = projectRoot -- 1324
		}) -- 1324
		if not payload then -- 1324
			listener:removeFromParent() -- 1327
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 1327
		end -- 1327
		__TS__Await(__TS__New( -- 1330
			__TS__Promise, -- 1330
			function(____, resolve) -- 1330
				Director.systemScheduler:schedule(once(function() -- 1331
					emit("AppWS", "Send", payload) -- 1332
					wait(function() return done end) -- 1333
					if not done then -- 1333
						listener:removeFromParent() -- 1335
					end -- 1335
					resolve(nil) -- 1337
				end)) -- 1331
			end -- 1330
		)) -- 1330
		return ____awaiter_resolve(nil, result) -- 1330
	end) -- 1330
end -- 1287
function ____exports.createTask(prompt) -- 1343
	if prompt == nil then -- 1343
		prompt = "" -- 1343
	end -- 1343
	local t = now() -- 1344
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, created_at, updated_at) VALUES(?, ?, 0, ?, ?)", {"RUNNING", prompt, t, t}) -- 1345
	if affected <= 0 then -- 1345
		return {success = false, message = "failed to create task"} -- 1350
	end -- 1350
	return { -- 1352
		success = true, -- 1352
		taskId = getLastInsertRowId() -- 1352
	} -- 1352
end -- 1343
function ____exports.setTaskStatus(taskId, status) -- 1355
	DB:exec( -- 1356
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 1356
		{ -- 1356
			status, -- 1356
			now(), -- 1356
			taskId -- 1356
		} -- 1356
	) -- 1356
	Log( -- 1357
		"Info", -- 1357
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 1357
	) -- 1357
end -- 1355
function ____exports.listCheckpoints(taskId) -- 1360
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 1361
	if not rows then -- 1361
		return {} -- 1368
	end -- 1368
	local items = {} -- 1369
	do -- 1369
		local i = 0 -- 1370
		while i < #rows do -- 1370
			local row = rows[i + 1] -- 1371
			items[#items + 1] = { -- 1372
				id = row[1], -- 1373
				taskId = row[2], -- 1374
				seq = row[3], -- 1375
				status = toStr(row[4]), -- 1376
				summary = toStr(row[5]), -- 1377
				toolName = toStr(row[6]), -- 1378
				createdAt = row[7] -- 1379
			} -- 1379
			i = i + 1 -- 1370
		end -- 1370
	end -- 1370
	return items -- 1382
end -- 1360
local function listCheckpointIdsForTask(taskId, desc) -- 1385
	if desc == nil then -- 1385
		desc = false -- 1385
	end -- 1385
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 1386
	if not rows then -- 1386
		return {} -- 1393
	end -- 1393
	local items = {} -- 1394
	do -- 1394
		local i = 0 -- 1395
		while i < #rows do -- 1395
			local row = rows[i + 1] -- 1396
			items[#items + 1] = {id = row[1], seq = row[2]} -- 1397
			i = i + 1 -- 1395
		end -- 1395
	end -- 1395
	return items -- 1402
end -- 1385
local function deriveFileOp(beforeExists, afterExists) -- 1405
	if not beforeExists and afterExists then -- 1405
		return "create" -- 1406
	end -- 1406
	if beforeExists and not afterExists then -- 1406
		return "delete" -- 1407
	end -- 1407
	return "write" -- 1408
end -- 1405
function ____exports.summarizeTaskChangeSet(taskId) -- 1411
	if not getTaskStatus(taskId) then -- 1411
		return {success = false, message = "task not found"} -- 1413
	end -- 1413
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1415
	local filesByPath = {} -- 1416
	local latestCheckpointId = nil -- 1422
	local latestCheckpointSeq = nil -- 1423
	do -- 1423
		local i = 0 -- 1424
		while i < #checkpoints do -- 1424
			local checkpoint = checkpoints[i + 1] -- 1425
			latestCheckpointId = checkpoint.id -- 1426
			latestCheckpointSeq = checkpoint.seq -- 1427
			local entries = getCheckpointEntries(checkpoint.id, false) -- 1428
			do -- 1428
				local j = 0 -- 1429
				while j < #entries do -- 1429
					local entry = entries[j + 1] -- 1430
					local item = filesByPath[entry.path] -- 1431
					if not item then -- 1431
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 1433
						filesByPath[entry.path] = item -- 1439
					end -- 1439
					item.afterExists = entry.afterExists -- 1441
					local ____item_checkpointIds_16 = item.checkpointIds -- 1441
					____item_checkpointIds_16[#____item_checkpointIds_16 + 1] = checkpoint.id -- 1442
					j = j + 1 -- 1429
				end -- 1429
			end -- 1429
			i = i + 1 -- 1424
		end -- 1424
	end -- 1424
	local files = {} -- 1445
	for ____, item in pairs(filesByPath) do -- 1446
		files[#files + 1] = { -- 1447
			path = item.path, -- 1448
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1449
			checkpointCount = #item.checkpointIds, -- 1450
			checkpointIds = item.checkpointIds -- 1451
		} -- 1451
	end -- 1451
	__TS__ArraySort( -- 1454
		files, -- 1454
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1454
	) -- 1454
	return { -- 1455
		success = true, -- 1456
		taskId = taskId, -- 1457
		checkpointCount = #checkpoints, -- 1458
		filesChanged = #files, -- 1459
		files = files, -- 1460
		latestCheckpointId = latestCheckpointId, -- 1461
		latestCheckpointSeq = latestCheckpointSeq -- 1462
	} -- 1462
end -- 1411
function ____exports.getTaskChangeSetDiff(taskId) -- 1466
	if not getTaskStatus(taskId) then -- 1466
		return {success = false, message = "task not found"} -- 1468
	end -- 1468
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1470
	if #checkpoints == 0 then -- 1470
		return {success = false, message = "change set not found or empty"} -- 1472
	end -- 1472
	local filesByPath = {} -- 1474
	do -- 1474
		local i = 0 -- 1481
		while i < #checkpoints do -- 1481
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 1482
			do -- 1482
				local j = 0 -- 1483
				while j < #entries do -- 1483
					local entry = entries[j + 1] -- 1484
					local item = filesByPath[entry.path] -- 1485
					if not item then -- 1485
						item = { -- 1487
							path = entry.path, -- 1488
							beforeExists = entry.beforeExists, -- 1489
							beforeContent = entry.beforeContent, -- 1490
							afterExists = entry.afterExists, -- 1491
							afterContent = entry.afterContent -- 1492
						} -- 1492
						filesByPath[entry.path] = item -- 1494
					end -- 1494
					item.afterExists = entry.afterExists -- 1496
					item.afterContent = entry.afterContent -- 1497
					j = j + 1 -- 1483
				end -- 1483
			end -- 1483
			i = i + 1 -- 1481
		end -- 1481
	end -- 1481
	local files = {} -- 1500
	for ____, item in pairs(filesByPath) do -- 1501
		files[#files + 1] = { -- 1502
			path = item.path, -- 1503
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1504
			beforeExists = item.beforeExists, -- 1505
			afterExists = item.afterExists, -- 1506
			beforeContent = item.beforeContent, -- 1507
			afterContent = item.afterContent -- 1508
		} -- 1508
	end -- 1508
	__TS__ArraySort( -- 1511
		files, -- 1511
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1511
	) -- 1511
	return {success = true, files = files} -- 1512
end -- 1466
local function readWorkspaceFile(workDir, path, docLanguage) -- 1515
	local engineLog = readEngineLogFile(path) -- 1516
	if engineLog then -- 1516
		return engineLog -- 1517
	end -- 1517
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1518
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 1518
		local attr = inspectReadableFile(fullPath) -- 1520
		if not attr.success then -- 1520
			return attr -- 1521
		end -- 1521
		return { -- 1522
			success = true, -- 1522
			content = Content:load(fullPath), -- 1522
			size = attr.size -- 1522
		} -- 1522
	end -- 1522
	local docPath = resolveAgentDoraDocFilePath(path, docLanguage) -- 1524
	if docPath then -- 1524
		local attr = inspectReadableFile(docPath) -- 1526
		if not attr.success then -- 1526
			return attr -- 1527
		end -- 1527
		return { -- 1528
			success = true, -- 1528
			content = Content:load(docPath), -- 1528
			size = attr.size -- 1528
		} -- 1528
	end -- 1528
	if not fullPath then -- 1528
		return {success = false, message = "invalid path or workDir"} -- 1530
	end -- 1530
	return {success = false, message = "file not found"} -- 1531
end -- 1515
function ____exports.readFileRaw(workDir, path, docLanguage) -- 1534
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 1535
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 1535
		local attr = inspectReadableFile(path) -- 1537
		if not attr.success then -- 1537
			return attr -- 1538
		end -- 1538
		return { -- 1539
			success = true, -- 1539
			content = Content:load(path), -- 1539
			size = attr.size -- 1539
		} -- 1539
	end -- 1539
	return result -- 1541
end -- 1534
function ____exports.getLogs(req) -- 1556
	local text = getEngineLogText() -- 1557
	if text == nil then -- 1557
		return {success = false, message = "failed to read engine logs"} -- 1559
	end -- 1559
	local tailLines = math.max( -- 1561
		1, -- 1561
		math.floor(req and req.tailLines or 200) -- 1561
	) -- 1561
	local allLines = __TS__StringSplit(text, "\n") -- 1562
	local logs = __TS__ArraySlice( -- 1563
		allLines, -- 1563
		math.max(0, #allLines - tailLines) -- 1563
	) -- 1563
	return req and req.joinText and ({ -- 1564
		success = true, -- 1564
		logs = logs, -- 1564
		text = table.concat(logs, "\n") -- 1564
	}) or ({success = true, logs = logs}) -- 1564
end -- 1556
function ____exports.listFiles(req) -- 1567
	local root = req.path or "" -- 1573
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 1574
	if not searchRoot then -- 1574
		return {success = false, message = "invalid path or workDir"} -- 1576
	end -- 1576
	do -- 1576
		local function ____catch(e) -- 1576
			return true, { -- 1594
				success = false, -- 1594
				message = tostring(e) -- 1594
			} -- 1594
		end -- 1594
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1594
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 1579
			local globs = ensureSafeSearchGlobs(userGlobs) -- 1580
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 1581
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 1582
			local totalEntries = #files -- 1583
			local maxEntries = math.max( -- 1584
				1, -- 1584
				math.floor(req.maxEntries or 200) -- 1584
			) -- 1584
			local truncated = totalEntries > maxEntries -- 1585
			return true, { -- 1586
				success = true, -- 1587
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 1588
				totalEntries = totalEntries, -- 1589
				truncated = truncated, -- 1590
				maxEntries = maxEntries -- 1591
			} -- 1591
		end) -- 1591
		if not ____try then -- 1591
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1591
		end -- 1591
		if ____hasReturned then -- 1591
			return ____returnValue -- 1578
		end -- 1578
	end -- 1578
end -- 1567
local function formatReadSlice(content, startLine, endLine) -- 1598
	local lines = __TS__StringSplit(content, "\n") -- 1603
	local totalLines = #lines -- 1604
	if totalLines == 0 then -- 1604
		return { -- 1606
			success = true, -- 1607
			content = "", -- 1608
			totalLines = 0, -- 1609
			startLine = 1, -- 1610
			endLine = 0, -- 1611
			truncated = false -- 1612
		} -- 1612
	end -- 1612
	local rawStart = math.floor(startLine) -- 1615
	local rawEnd = math.floor(endLine) -- 1616
	if rawStart == 0 then -- 1616
		return {success = false, message = "startLine cannot be 0"} -- 1618
	end -- 1618
	if rawEnd == 0 then -- 1618
		return {success = false, message = "endLine cannot be 0"} -- 1621
	end -- 1621
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1623
	if start > totalLines then -- 1623
		return { -- 1627
			success = false, -- 1627
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1627
		} -- 1627
	end -- 1627
	local ____end = math.min( -- 1629
		totalLines, -- 1630
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1631
	) -- 1631
	if ____end < start then -- 1631
		return { -- 1636
			success = false, -- 1637
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1638
		} -- 1638
	end -- 1638
	local slice = {} -- 1641
	do -- 1641
		local i = start -- 1642
		while i <= ____end do -- 1642
			slice[#slice + 1] = lines[i] -- 1643
			i = i + 1 -- 1642
		end -- 1642
	end -- 1642
	local truncated = start > 1 or ____end < totalLines -- 1645
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1646
	local body = table.concat(slice, "\n") -- 1651
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1652
	return { -- 1653
		success = true, -- 1654
		content = output, -- 1655
		totalLines = totalLines, -- 1656
		startLine = start, -- 1657
		endLine = ____end, -- 1658
		truncated = truncated -- 1659
	} -- 1659
end -- 1598
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1663
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1670
	if not fallback.success or fallback.content == nil then -- 1670
		return fallback -- 1671
	end -- 1671
	local resolvedStartLine = startLine or 1 -- 1672
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1673
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1674
end -- 1663
local codeExtensions = { -- 1681
	".lua", -- 1681
	".tl", -- 1681
	".yue", -- 1681
	".ts", -- 1681
	".tsx", -- 1681
	".xml", -- 1681
	".md", -- 1681
	".yarn", -- 1681
	".wa", -- 1681
	".mod" -- 1681
} -- 1681
extensionLevels = { -- 1682
	vs = 2, -- 1683
	bl = 2, -- 1684
	ts = 1, -- 1685
	tsx = 1, -- 1686
	tl = 1, -- 1687
	yue = 1, -- 1688
	xml = 1, -- 1689
	lua = 0 -- 1690
} -- 1690
local function splitSearchPatterns(pattern) -- 1707
	local trimmed = __TS__StringTrim(pattern or "") -- 1708
	if trimmed == "" then -- 1708
		return {} -- 1709
	end -- 1709
	local out = {} -- 1710
	local seen = __TS__New(Set) -- 1711
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1712
		local p = __TS__StringTrim(tostring(p0)) -- 1713
		if p ~= "" and not seen:has(p) then -- 1713
			seen:add(p) -- 1715
			out[#out + 1] = p -- 1716
		end -- 1716
	end -- 1716
	return out -- 1719
end -- 1707
local function splitWhitespaceSearchPatterns(pattern) -- 1722
	local out = {} -- 1723
	local seen = __TS__New(Set) -- 1724
	for p0 in string.gmatch(pattern, "(%S+)") do -- 1725
		local p = __TS__StringTrim(tostring(p0)) -- 1726
		local key = string.lower(p) -- 1727
		if p ~= "" and not seen:has(key) then -- 1727
			seen:add(key) -- 1729
			out[#out + 1] = p -- 1730
		end -- 1730
	end -- 1730
	return out -- 1733
end -- 1722
local function mergeSearchFileResultsUnique(resultsList) -- 1736
	local merged = {} -- 1737
	local seen = __TS__New(Set) -- 1738
	do -- 1738
		local i = 0 -- 1739
		while i < #resultsList do -- 1739
			local list = resultsList[i + 1] -- 1740
			do -- 1740
				local j = 0 -- 1741
				while j < #list do -- 1741
					do -- 1741
						local row = list[j + 1] -- 1742
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1743
						if seen:has(key) then -- 1743
							goto __continue349 -- 1744
						end -- 1744
						seen:add(key) -- 1745
						merged[#merged + 1] = list[j + 1] -- 1746
					end -- 1746
					::__continue349:: -- 1746
					j = j + 1 -- 1741
				end -- 1741
			end -- 1741
			i = i + 1 -- 1739
		end -- 1739
	end -- 1739
	return merged -- 1749
end -- 1736
local function buildGroupedSearchResults(results) -- 1752
	local order = {} -- 1757
	local grouped = __TS__New(Map) -- 1758
	do -- 1758
		local i = 0 -- 1763
		while i < #results do -- 1763
			local row = results[i + 1] -- 1764
			local file = row.file -- 1765
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1766
			local bucket = grouped:get(key) -- 1767
			if not bucket then -- 1767
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1769
				grouped:set(key, bucket) -- 1770
				order[#order + 1] = key -- 1771
			end -- 1771
			bucket.totalMatches = bucket.totalMatches + 1 -- 1773
			local ____bucket_matches_21 = bucket.matches -- 1773
			____bucket_matches_21[#____bucket_matches_21 + 1] = results[i + 1] -- 1774
			i = i + 1 -- 1763
		end -- 1763
	end -- 1763
	local out = {} -- 1776
	do -- 1776
		local i = 0 -- 1781
		while i < #order do -- 1781
			local bucket = grouped:get(order[i + 1]) -- 1782
			if bucket then -- 1782
				out[#out + 1] = bucket -- 1783
			end -- 1783
			i = i + 1 -- 1781
		end -- 1781
	end -- 1781
	return out -- 1785
end -- 1752
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1788
	local merged = {} -- 1789
	local seen = __TS__New(Set) -- 1790
	local index = 0 -- 1791
	local advanced = true -- 1792
	while advanced do -- 1792
		advanced = false -- 1794
		do -- 1794
			local i = 0 -- 1795
			while i < #resultsList do -- 1795
				do -- 1795
					local list = resultsList[i + 1] -- 1796
					if index >= #list then -- 1796
						goto __continue361 -- 1797
					end -- 1797
					advanced = true -- 1798
					local row = list[index + 1] -- 1799
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1800
					if seen:has(key) then -- 1800
						goto __continue361 -- 1801
					end -- 1801
					seen:add(key) -- 1802
					merged[#merged + 1] = row -- 1803
				end -- 1803
				::__continue361:: -- 1803
				i = i + 1 -- 1795
			end -- 1795
		end -- 1795
		index = index + 1 -- 1805
	end -- 1805
	return merged -- 1807
end -- 1788
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1810
	if docSource ~= "api" then -- 1810
		return 100 -- 1811
	end -- 1811
	if programmingLanguage ~= "tsx" then -- 1811
		return 100 -- 1812
	end -- 1812
	repeat -- 1812
		local ____switch367 = string.lower(Path:getFilename(file)) -- 1812
		local ____cond367 = ____switch367 == "jsx.d.ts" -- 1812
		if ____cond367 then -- 1812
			return 0 -- 1814
		end -- 1814
		____cond367 = ____cond367 or ____switch367 == "dorax.d.ts" -- 1814
		if ____cond367 then -- 1814
			return 1 -- 1815
		end -- 1815
		____cond367 = ____cond367 or ____switch367 == "dora.d.ts" -- 1815
		if ____cond367 then -- 1815
			return 2 -- 1816
		end -- 1816
		do -- 1816
			return 100 -- 1817
		end -- 1817
	until true -- 1817
end -- 1810
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1821
	local sorted = __TS__ArraySlice(hits) -- 1826
	__TS__ArraySort( -- 1827
		sorted, -- 1827
		function(____, a, b) -- 1827
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1828
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1829
			if pa ~= pb then -- 1829
				return pa - pb -- 1830
			end -- 1830
			local fa = string.lower(a.file) -- 1831
			local fb = string.lower(b.file) -- 1832
			if fa ~= fb then -- 1832
				return fa < fb and -1 or 1 -- 1833
			end -- 1833
			return (a.line or 0) - (b.line or 0) -- 1834
		end -- 1827
	) -- 1827
	return sorted -- 1836
end -- 1821
function ____exports.searchFiles(req) -- 1839
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1839
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1852
		if not resolvedPath then -- 1852
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1852
		end -- 1852
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1856
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1857
		if not searchRoot then -- 1857
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1857
		end -- 1857
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1857
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1857
		end -- 1857
		local patterns = splitSearchPatterns(req.pattern) -- 1864
		if #patterns == 0 then -- 1864
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1864
		end -- 1864
		return ____awaiter_resolve( -- 1864
			nil, -- 1864
			__TS__New( -- 1868
				__TS__Promise, -- 1868
				function(____, resolve) -- 1868
					Director.systemScheduler:schedule(once(function() -- 1869
						do -- 1869
							local function ____catch(e) -- 1869
								resolve( -- 1911
									nil, -- 1911
									{ -- 1911
										success = false, -- 1911
										message = tostring(e) -- 1911
									} -- 1911
								) -- 1911
							end -- 1911
							local ____try, ____hasReturned = pcall(function() -- 1911
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1871
								local allResults = {} -- 1874
								do -- 1874
									local i = 0 -- 1875
									while i < #patterns do -- 1875
										local ____Content_26 = Content -- 1876
										local ____Content_searchFilesAsync_27 = Content.searchFilesAsync -- 1876
										local ____patterns_index_25 = patterns[i + 1] -- 1881
										local ____req_useRegex_22 = req.useRegex -- 1882
										if ____req_useRegex_22 == nil then -- 1882
											____req_useRegex_22 = false -- 1882
										end -- 1882
										local ____req_caseSensitive_23 = req.caseSensitive -- 1883
										if ____req_caseSensitive_23 == nil then -- 1883
											____req_caseSensitive_23 = false -- 1883
										end -- 1883
										local ____req_includeContent_24 = req.includeContent -- 1884
										if ____req_includeContent_24 == nil then -- 1884
											____req_includeContent_24 = true -- 1884
										end -- 1884
										allResults[#allResults + 1] = ____Content_searchFilesAsync_27( -- 1876
											____Content_26, -- 1876
											searchRoot, -- 1877
											codeExtensions, -- 1878
											extensionLevels, -- 1879
											searchGlobs, -- 1880
											____patterns_index_25, -- 1881
											____req_useRegex_22, -- 1882
											____req_caseSensitive_23, -- 1883
											____req_includeContent_24, -- 1884
											req.contentWindow or 120 -- 1885
										) -- 1885
										i = i + 1 -- 1875
									end -- 1875
								end -- 1875
								local results = mergeSearchFileResultsUnique(allResults) -- 1888
								local totalResults = #results -- 1889
								local limit = math.max( -- 1890
									1, -- 1890
									math.floor(req.limit or 20) -- 1890
								) -- 1890
								local offset = math.max( -- 1891
									0, -- 1891
									math.floor(req.offset or 0) -- 1891
								) -- 1891
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1892
								local nextOffset = offset + #paged -- 1893
								local hasMore = nextOffset < totalResults -- 1894
								local truncated = offset > 0 or hasMore -- 1895
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1896
								local groupByFile = req.groupByFile == true -- 1897
								resolve( -- 1898
									nil, -- 1898
									{ -- 1898
										success = true, -- 1899
										results = relativeResults, -- 1900
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1901
										totalResults = totalResults, -- 1902
										truncated = truncated, -- 1903
										limit = limit, -- 1904
										offset = offset, -- 1905
										nextOffset = nextOffset, -- 1906
										hasMore = hasMore, -- 1907
										groupByFile = groupByFile -- 1908
									} -- 1908
								) -- 1908
							end) -- 1908
							if not ____try then -- 1908
								____catch(____hasReturned) -- 1908
							end -- 1908
						end -- 1908
					end)) -- 1869
				end -- 1868
			) -- 1868
		) -- 1868
	end) -- 1868
end -- 1839
function ____exports.searchDoraAPI(req) -- 1917
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1917
		local pattern = __TS__StringTrim(req.pattern or "") -- 1928
		if pattern == "" then -- 1928
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1928
		end -- 1928
		local patterns = splitSearchPatterns(pattern) -- 1930
		if #patterns == 0 then -- 1930
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1930
		end -- 1930
		local docSource = req.docSource or "api" -- 1932
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1933
		local docRoot = target.root -- 1934
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1935
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1935
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1935
		end -- 1935
		local exts = target.exts -- 1939
		local dotExts = __TS__ArrayMap( -- 1940
			exts, -- 1940
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1940
		) -- 1940
		local globs = target.globs -- 1941
		local limit = math.max( -- 1942
			1, -- 1942
			math.floor(req.limit or 10) -- 1942
		) -- 1942
		return ____awaiter_resolve( -- 1942
			nil, -- 1942
			__TS__New( -- 1944
				__TS__Promise, -- 1944
				function(____, resolve) -- 1944
					Director.systemScheduler:schedule(once(function() -- 1945
						do -- 1945
							local function ____catch(e) -- 1945
								resolve( -- 2025
									nil, -- 2025
									{ -- 2025
										success = false, -- 2025
										message = tostring(e) -- 2025
									} -- 2025
								) -- 2025
							end -- 2025
							local ____try, ____hasReturned = pcall(function() -- 2025
								local allHits = {} -- 1947
								do -- 1947
									local p = 0 -- 1948
									while p < #patterns do -- 1948
										local ____Content_32 = Content -- 1949
										local ____Content_searchFilesAsync_33 = Content.searchFilesAsync -- 1949
										local ____array_31 = __TS__SparseArrayNew( -- 1949
											docRoot, -- 1950
											dotExts, -- 1951
											{}, -- 1952
											ensureSafeSearchGlobs(globs), -- 1953
											patterns[p + 1] -- 1954
										) -- 1954
										local ____req_useRegex_28 = req.useRegex -- 1955
										if ____req_useRegex_28 == nil then -- 1955
											____req_useRegex_28 = false -- 1955
										end -- 1955
										__TS__SparseArrayPush(____array_31, ____req_useRegex_28) -- 1955
										local ____req_caseSensitive_29 = req.caseSensitive -- 1956
										if ____req_caseSensitive_29 == nil then -- 1956
											____req_caseSensitive_29 = false -- 1956
										end -- 1956
										__TS__SparseArrayPush(____array_31, ____req_caseSensitive_29) -- 1956
										local ____req_includeContent_30 = req.includeContent -- 1957
										if ____req_includeContent_30 == nil then -- 1957
											____req_includeContent_30 = true -- 1957
										end -- 1957
										__TS__SparseArrayPush(____array_31, ____req_includeContent_30, req.contentWindow or 80) -- 1957
										local raw = ____Content_searchFilesAsync_33( -- 1949
											____Content_32, -- 1949
											__TS__SparseArraySpread(____array_31) -- 1949
										) -- 1949
										local hits = {} -- 1960
										do -- 1960
											local i = 0 -- 1961
											while i < #raw do -- 1961
												do -- 1961
													local row = raw[i + 1] -- 1962
													local file = toDocRelativePath(resultBaseRoot, row.file, docSource) -- 1963
													if file == "" then -- 1963
														goto __continue394 -- 1964
													end -- 1964
													hits[#hits + 1] = { -- 1965
														file = file, -- 1966
														line = type(row.line) == "number" and row.line or nil, -- 1967
														content = type(row.content) == "string" and row.content or nil -- 1968
													} -- 1968
												end -- 1968
												::__continue394:: -- 1968
												i = i + 1 -- 1961
											end -- 1961
										end -- 1961
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1971
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1971
											0, -- 1971
											limit -- 1971
										) -- 1971
										p = p + 1 -- 1948
									end -- 1948
								end -- 1948
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1973
								local fallbackPatterns -- 1974
								if #hits == 0 and #patterns == 1 and req.useRegex ~= true and (string.find(pattern, "|", nil, true) or 0) - 1 < 0 then -- 1974
									local terms = splitWhitespaceSearchPatterns(pattern) -- 1979
									if #terms > 1 then -- 1979
										fallbackPatterns = terms -- 1981
										local fallbackHits = {} -- 1982
										do -- 1982
											local p = 0 -- 1983
											while p < #terms do -- 1983
												local ____Content_37 = Content -- 1984
												local ____Content_searchFilesAsync_38 = Content.searchFilesAsync -- 1984
												local ____array_36 = __TS__SparseArrayNew( -- 1984
													docRoot, -- 1985
													dotExts, -- 1986
													{}, -- 1987
													ensureSafeSearchGlobs(globs), -- 1988
													terms[p + 1], -- 1989
													false -- 1990
												) -- 1990
												local ____req_caseSensitive_34 = req.caseSensitive -- 1991
												if ____req_caseSensitive_34 == nil then -- 1991
													____req_caseSensitive_34 = false -- 1991
												end -- 1991
												__TS__SparseArrayPush(____array_36, ____req_caseSensitive_34) -- 1991
												local ____req_includeContent_35 = req.includeContent -- 1992
												if ____req_includeContent_35 == nil then -- 1992
													____req_includeContent_35 = true -- 1992
												end -- 1992
												__TS__SparseArrayPush(____array_36, ____req_includeContent_35, req.contentWindow or 80) -- 1992
												local raw = ____Content_searchFilesAsync_38( -- 1984
													____Content_37, -- 1984
													__TS__SparseArraySpread(____array_36) -- 1984
												) -- 1984
												local termHits = {} -- 1995
												do -- 1995
													local i = 0 -- 1996
													while i < #raw do -- 1996
														do -- 1996
															local row = raw[i + 1] -- 1997
															local file = toDocRelativePath(resultBaseRoot, row.file, docSource) -- 1998
															if file == "" then -- 1998
																goto __continue401 -- 1999
															end -- 1999
															termHits[#termHits + 1] = { -- 2000
																file = file, -- 2001
																line = type(row.line) == "number" and row.line or nil, -- 2002
																content = type(row.content) == "string" and row.content or nil -- 2003
															} -- 2003
														end -- 2003
														::__continue401:: -- 2003
														i = i + 1 -- 1996
													end -- 1996
												end -- 1996
												fallbackHits[#fallbackHits + 1] = __TS__ArraySlice( -- 2006
													sortDoraAPISearchHits(termHits, docSource, req.programmingLanguage), -- 2006
													0, -- 2006
													limit -- 2006
												) -- 2006
												p = p + 1 -- 1983
											end -- 1983
										end -- 1983
										hits = mergeDoraAPISearchHitsUnique(fallbackHits) -- 2008
									end -- 2008
								end -- 2008
								resolve(nil, { -- 2011
									success = true, -- 2012
									docSource = docSource, -- 2013
									docLanguage = req.docLanguage, -- 2014
									programmingLanguage = req.programmingLanguage, -- 2015
									exts = exts, -- 2016
									results = hits, -- 2017
									hint = "Use read_file directly with the namespaced file value from a search result to view the complete authoritative document.", -- 2018
									totalResults = #hits, -- 2019
									truncated = false, -- 2020
									limit = limit, -- 2021
									fallbackPatterns = fallbackPatterns -- 2022
								}) -- 2022
							end) -- 2022
							if not ____try then -- 2022
								____catch(____hasReturned) -- 2022
							end -- 2022
						end -- 2022
					end)) -- 1945
				end -- 1944
			) -- 1944
		) -- 1944
	end) -- 1944
end -- 1917
function ____exports.searchDoraAPIHttp(req, callback) -- 2031
	local ____self_39 = ____exports.searchDoraAPI(req) -- 2031
	____self_39["then"]( -- 2031
		____self_39, -- 2031
		function(____, result) return callback(result) end -- 2042
	) -- 2042
end -- 2031
function ____exports.readDoraDoc(req) -- 2045
	local requestedFile = table.concat( -- 2051
		__TS__StringSplit(req.file or "", "\\"), -- 2051
		"/" -- 2051
	) -- 2051
	local file = requestedFile -- 2052
	local namespacedSource = nil -- 2053
	if __TS__StringStartsWith(requestedFile, AGENT_DORA_DOC_PREFIX) then -- 2053
		local namespaced = __TS__StringSlice(requestedFile, #AGENT_DORA_DOC_PREFIX) -- 2055
		if __TS__StringStartsWith(namespaced, "api/") then -- 2055
			namespacedSource = "api" -- 2057
			file = string.sub(namespaced, 5) -- 2058
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 2058
			namespacedSource = "tutorial" -- 2060
			file = string.sub(namespaced, 10) -- 2061
		else -- 2061
			return {success = false, message = "invalid Dora doc namespace"} -- 2063
		end -- 2063
	end -- 2063
	if not isValidWorkspacePath(file) or file == "." then -- 2063
		return {success = false, message = "invalid file"} -- 2067
	end -- 2067
	local lowerFile = string.lower(file) -- 2069
	local isTutorialDoc = __TS__StringEndsWith(lowerFile, ".md") -- 2070
	local isAPIDoc = __TS__StringEndsWith(lowerFile, ".ts") or __TS__StringEndsWith(lowerFile, ".tl") -- 2071
	if not isTutorialDoc and not isAPIDoc then -- 2071
		return {success = false, message = "unsupported doc file type"} -- 2072
	end -- 2072
	local docSource = namespacedSource or (isTutorialDoc and "tutorial" or "api") -- 2073
	local root = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 2074
	local fullPath = Path(root, file) -- 2075
	local relative = Path:getRelative(fullPath, root) -- 2076
	if relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 2076
		return {success = false, message = "invalid file"} -- 2078
	end -- 2078
	local readResult = ____exports.readFile(root, file, req.startLine or 1, req.endLine or -1) -- 2080
	if not readResult.success then -- 2080
		return readResult -- 2081
	end -- 2081
	return { -- 2082
		success = true, -- 2083
		docLanguage = req.docLanguage, -- 2084
		file = file, -- 2085
		content = readResult.content, -- 2086
		startLine = readResult.startLine, -- 2087
		endLine = readResult.endLine -- 2088
	} -- 2088
end -- 2045
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 2092
	if options == nil then -- 2092
		options = {} -- 2092
	end -- 2092
	if #changes == 0 then -- 2092
		return {success = false, message = "empty changes"} -- 2094
	end -- 2094
	if not isValidWorkDir(workDir) then -- 2094
		return {success = false, message = "invalid workDir"} -- 2097
	end -- 2097
	if not getTaskStatus(taskId) then -- 2097
		return {success = false, message = "task not found"} -- 2100
	end -- 2100
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 2102
	local dup = rejectDuplicatePaths(expandedChanges) -- 2103
	if dup then -- 2103
		return {success = false, message = "duplicate path in batch: " .. dup} -- 2105
	end -- 2105
	for ____, change in ipairs(expandedChanges) do -- 2108
		if not isValidWorkspacePath(change.path) then -- 2108
			return {success = false, message = "invalid path: " .. change.path} -- 2110
		end -- 2110
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 2110
			return {success = false, message = "missing content for " .. change.path} -- 2113
		end -- 2113
	end -- 2113
	local headSeq = getTaskHeadSeq(taskId) -- 2117
	if headSeq == nil then -- 2117
		return {success = false, message = "task not found"} -- 2118
	end -- 2118
	local nextSeq = headSeq + 1 -- 2119
	local checkpointId = insertCheckpoint( -- 2120
		taskId, -- 2120
		nextSeq, -- 2120
		options.summary or "", -- 2120
		options.toolName or "", -- 2120
		"PREPARED" -- 2120
	) -- 2120
	if checkpointId <= 0 then -- 2120
		return {success = false, message = "failed to create checkpoint"} -- 2122
	end -- 2122
	do -- 2122
		local i = 0 -- 2125
		while i < #expandedChanges do -- 2125
			local change = expandedChanges[i + 1] -- 2126
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 2127
			if not fullPath then -- 2127
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2129
				return {success = false, message = "invalid path: " .. change.path} -- 2130
			end -- 2130
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 2130
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2133
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 2134
			end -- 2134
			local before = getFileState(fullPath) -- 2136
			local afterExists = change.op ~= "delete" -- 2137
			local afterContent = afterExists and (change.content or "") or "" -- 2138
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 2139
				checkpointId, -- 2143
				i + 1, -- 2144
				change.path, -- 2145
				change.op, -- 2146
				before.exists and 1 or 0, -- 2147
				before.content, -- 2148
				afterExists and 1 or 0, -- 2149
				afterContent, -- 2150
				before.bytes, -- 2151
				#afterContent -- 2152
			}) -- 2152
			if inserted <= 0 then -- 2152
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2156
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 2157
			end -- 2157
			i = i + 1 -- 2125
		end -- 2125
	end -- 2125
	local appliedCount = 0 -- 2161
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 2162
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2163
		if not fullPath then -- 2163
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2165
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2166
			return {success = false, message = ("invalid path: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2167
		end -- 2167
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 2169
		if not ok then -- 2169
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2171
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount + 1) -- 2172
			return {success = false, message = ("failed to apply file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2173
		end -- 2173
		appliedCount = appliedCount + 1 -- 2175
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 2175
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2177
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2178
			return {success = false, message = ("failed to sync file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; all applied files restored")} -- 2179
		end -- 2179
	end -- 2179
	DB:exec( -- 2183
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 2183
		{ -- 2185
			"APPLIED", -- 2185
			now(), -- 2185
			checkpointId -- 2185
		} -- 2185
	) -- 2185
	DB:exec( -- 2187
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 2187
		{ -- 2189
			nextSeq, -- 2189
			now(), -- 2189
			taskId -- 2189
		} -- 2189
	) -- 2189
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 2191
end -- 2092
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 2199
	if not isValidWorkDir(workDir) then -- 2199
		return {success = false, message = "invalid workDir"} -- 2200
	end -- 2200
	if checkpointId <= 0 then -- 2200
		return {success = false, message = "invalid checkpointId"} -- 2201
	end -- 2201
	local entries = getCheckpointEntries(checkpointId, true) -- 2202
	if #entries == 0 then -- 2202
		return {success = false, message = "checkpoint not found or empty"} -- 2204
	end -- 2204
	for ____, entry in ipairs(entries) do -- 2206
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2207
		if not fullPath then -- 2207
			return {success = false, message = "invalid path: " .. entry.path} -- 2209
		end -- 2209
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 2211
		if not ok then -- 2211
			Log( -- 2213
				"Error", -- 2213
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2213
			) -- 2213
			Log( -- 2214
				"Info", -- 2214
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2214
			) -- 2214
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 2215
		end -- 2215
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 2215
			Log( -- 2218
				"Error", -- 2218
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2218
			) -- 2218
			Log( -- 2219
				"Info", -- 2219
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2219
			) -- 2219
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 2220
		end -- 2220
	end -- 2220
	DB:exec( -- 2223
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 2223
		{ -- 2223
			"REVERTED", -- 2223
			now(), -- 2223
			checkpointId -- 2223
		} -- 2223
	) -- 2223
	return {success = true, checkpointId = checkpointId} -- 2224
end -- 2199
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 2227
	if not isValidWorkDir(workDir) then -- 2227
		return {success = false, message = "invalid workDir"} -- 2228
	end -- 2228
	if not getTaskStatus(taskId) then -- 2228
		return {success = false, message = "task not found"} -- 2229
	end -- 2229
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 2230
	if #checkpoints == 0 then -- 2230
		return {success = false, message = "change set not found or empty"} -- 2232
	end -- 2232
	local lastCheckpointId = 0 -- 2234
	do -- 2234
		local i = 0 -- 2235
		while i < #checkpoints do -- 2235
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 2236
			if not result.success then -- 2236
				return {success = false, message = result.message} -- 2237
			end -- 2237
			lastCheckpointId = checkpoints[i + 1].id -- 2238
			i = i + 1 -- 2235
		end -- 2235
	end -- 2235
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 2240
end -- 2227
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 2248
	return getCheckpointEntries(checkpointId, false) -- 2249
end -- 2248
function ____exports.getCheckpointDiff(checkpointId) -- 2252
	if checkpointId <= 0 then -- 2252
		return {success = false, message = "invalid checkpointId"} -- 2254
	end -- 2254
	local entries = getCheckpointEntries(checkpointId, false) -- 2256
	if #entries == 0 then -- 2256
		return {success = false, message = "checkpoint not found or empty"} -- 2258
	end -- 2258
	return { -- 2260
		success = true, -- 2261
		files = __TS__ArrayMap( -- 2262
			entries, -- 2262
			function(____, entry) return { -- 2262
				path = entry.path, -- 2263
				op = entry.op, -- 2264
				beforeExists = entry.beforeExists, -- 2265
				afterExists = entry.afterExists, -- 2266
				beforeContent = entry.beforeContent, -- 2267
				afterContent = entry.afterContent -- 2268
			} end -- 2268
		) -- 2268
	} -- 2268
end -- 2252
local function finalizeBuildResult(workDir, messages) -- 2273
	local normalized = __TS__ArrayMap( -- 2274
		messages, -- 2274
		function(____, m) return m.success and __TS__ObjectAssign( -- 2274
			{}, -- 2275
			m, -- 2275
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2275
		) or __TS__ObjectAssign( -- 2275
			{}, -- 2276
			m, -- 2276
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2276
		) end -- 2276
	) -- 2276
	local total = #normalized -- 2277
	local failed = 0 -- 2278
	do -- 2278
		local i = 0 -- 2279
		while i < #normalized do -- 2279
			if not normalized[i + 1].success then -- 2279
				failed = failed + 1 -- 2280
			end -- 2280
			i = i + 1 -- 2279
		end -- 2279
	end -- 2279
	local passed = total - failed -- 2282
	if failed > 0 then -- 2282
		return { -- 2284
			success = false, -- 2285
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 2286
			total = total, -- 2287
			passed = passed, -- 2288
			failed = failed, -- 2289
			messages = normalized -- 2290
		} -- 2290
	end -- 2290
	return { -- 2293
		success = true, -- 2294
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 2295
		total = total, -- 2296
		passed = passed, -- 2297
		failed = 0, -- 2298
		messages = normalized -- 2299
	} -- 2299
end -- 2273
function ____exports.build(req) -- 2303
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2303
		local targetRel = req.path or "" -- 2304
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2305
		if not target then -- 2305
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2305
		end -- 2305
		if not Content:exist(target) then -- 2305
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2305
		end -- 2305
		local messages = {} -- 2312
		if not Content:isdir(target) then -- 2312
			local kind = getSupportedBuildKind(target) -- 2314
			if not kind then -- 2314
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2314
			end -- 2314
			if kind == "ts" then -- 2314
				local content = Content:load(target) -- 2319
				if content == nil then -- 2319
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2319
				end -- 2319
				if isTiledEditorContent(content) then -- 2319
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2324
					return ____awaiter_resolve( -- 2324
						nil, -- 2324
						finalizeBuildResult(req.workDir, messages) -- 2325
					) -- 2325
				end -- 2325
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2325
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2325
				end -- 2325
				if not isDtsFile(target) then -- 2325
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir)) -- 2331
				end -- 2331
			else -- 2331
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2334
			end -- 2334
			Log( -- 2336
				"Info", -- 2336
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2336
			) -- 2336
			return ____awaiter_resolve( -- 2336
				nil, -- 2336
				finalizeBuildResult(req.workDir, messages) -- 2337
			) -- 2337
		end -- 2337
		local listResult = ____exports.listFiles({ -- 2339
			workDir = req.workDir, -- 2340
			path = targetRel, -- 2341
			globs = __TS__ArrayMap( -- 2342
				codeExtensions, -- 2342
				function(____, e) return "**/*" .. e end -- 2342
			), -- 2342
			maxEntries = 10000 -- 2343
		}) -- 2343
		local relFiles = listResult.success and listResult.files or ({}) -- 2346
		local tsFileData = {} -- 2347
		local buildQueue = {} -- 2348
		for ____, rel in ipairs(relFiles) do -- 2349
			do -- 2349
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2350
				local kind = getSupportedBuildKind(file) -- 2351
				if not kind then -- 2351
					goto __continue475 -- 2352
				end -- 2352
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2353
				if kind ~= "ts" then -- 2353
					goto __continue475 -- 2355
				end -- 2355
				local content = Content:load(file) -- 2357
				if content == nil then -- 2357
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2359
					goto __continue475 -- 2360
				end -- 2360
				if isTiledEditorContent(content) then -- 2360
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2363
					goto __continue475 -- 2364
				end -- 2364
				tsFileData[file] = content -- 2366
			end -- 2366
			::__continue475:: -- 2366
		end -- 2366
		do -- 2366
			local i = 0 -- 2368
			while i < #buildQueue do -- 2368
				do -- 2368
					local ____buildQueue_index_40 = buildQueue[i + 1] -- 2369
					local file = ____buildQueue_index_40.file -- 2369
					local kind = ____buildQueue_index_40.kind -- 2369
					if kind == "ts" then -- 2369
						local content = tsFileData[file] -- 2371
						if content == nil or isDtsFile(file) then -- 2371
							goto __continue482 -- 2373
						end -- 2373
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2373
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2376
							goto __continue482 -- 2377
						end -- 2377
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir)) -- 2379
						goto __continue482 -- 2380
					end -- 2380
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2382
				end -- 2382
				::__continue482:: -- 2382
				i = i + 1 -- 2368
			end -- 2368
		end -- 2368
		if #messages == 0 then -- 2368
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2385
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2385
		end -- 2385
		Log( -- 2388
			"Info", -- 2388
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2388
		) -- 2388
		return ____awaiter_resolve( -- 2388
			nil, -- 2388
			finalizeBuildResult(req.workDir, messages) -- 2389
		) -- 2389
	end) -- 2389
end -- 2303
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2392
local EXECUTE_COMMAND_ERROR_MAX = 4000 -- 2393
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 2394
local agentEntryRuntimeOwner = "" -- 2395
local function truncateCommandOutput(output) -- 2397
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2397
		return output -- 2398
	end -- 2398
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2399
end -- 2397
local function truncateCommandError(message) -- 2402
	if #message <= EXECUTE_COMMAND_ERROR_MAX then -- 2402
		return message -- 2403
	end -- 2403
	return __TS__StringSlice(message, 0, EXECUTE_COMMAND_ERROR_MAX) .. "\n... error message truncated ..." -- 2404
end -- 2402
local function executeLuaCommand(req) -- 2407
	local code = __TS__StringTrim(req.code or "") -- 2415
	if code == "" then -- 2415
		return __TS__Promise.resolve({ -- 2417
			success = false, -- 2417
			mode = "lua", -- 2417
			output = "", -- 2417
			message = "missing code", -- 2417
			phase = "validate" -- 2417
		}) -- 2417
	end -- 2417
	local output = {} -- 2419
	local entry = require("Script.Dev.Entry") -- 2420
	local ownsEntryRuntime = false -- 2421
	local function acquireEntryRuntime() -- 2422
		if agentEntryRuntimeOwner ~= "" and agentEntryRuntimeOwner ~= req.operationId then -- 2422
			error("Dora entry runtime is busy with another Agent command") -- 2424
		end -- 2424
		agentEntryRuntimeOwner = req.operationId -- 2426
		ownsEntryRuntime = true -- 2427
	end -- 2422
	local function stopOwnedEntry() -- 2429
		if not ownsEntryRuntime then -- 2429
			return nil -- 2430
		end -- 2430
		local cleanupError -- 2431
		do -- 2431
			local function ____catch(e) -- 2431
				cleanupError = "failed to stop Agent test entry: " .. tostring(e) -- 2435
			end -- 2435
			local ____try, ____hasReturned = pcall(function() -- 2435
				entry.stop() -- 2433
			end) -- 2433
			if not ____try then -- 2433
				____catch(____hasReturned) -- 2433
			end -- 2433
		end -- 2433
		ownsEntryRuntime = false -- 2437
		if agentEntryRuntimeOwner == req.operationId then -- 2437
			agentEntryRuntimeOwner = "" -- 2439
		end -- 2439
		return cleanupError -- 2441
	end -- 2429
	local function normalizeEntryFile(value) -- 2443
		if not value or type(value) ~= "table" then -- 2443
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 2445
		end -- 2445
		local descriptor = value -- 2447
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 2448
		if relativeFile == "" then -- 2448
			relativeFile = "init" -- 2449
		end -- 2449
		if not isValidWorkspacePath(relativeFile) then -- 2449
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 2451
		end -- 2451
		local fileName = Path(req.workDir, relativeFile) -- 2453
		local ext = Path:getExt(fileName) -- 2454
		if ext ~= "" then -- 2454
			fileName = Path:replaceExt(fileName, "") -- 2455
		end -- 2455
		local luaFile = Path:replaceExt(fileName, "lua") -- 2456
		if not Content:exist(luaFile) then -- 2456
			error("Agent test entry was not built: " .. luaFile) -- 2458
		end -- 2458
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 2460
		return { -- 2461
			fileName = fileName, -- 2462
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 2463
		} -- 2463
	end -- 2443
	local function capturePrint(...) -- 2466
		local values = {...} -- 2466
		local parts = {} -- 2467
		do -- 2467
			local i = 0 -- 2468
			while i < #values do -- 2468
				parts[#parts + 1] = tostring(values[i + 1]) -- 2469
				i = i + 1 -- 2468
			end -- 2468
		end -- 2468
		output[#output + 1] = table.concat(parts, "\t") -- 2471
	end -- 2466
	local env = setmetatable( -- 2473
		{ -- 2473
			projectDir = req.workDir, -- 2474
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 2475
				if type(moduleNameValue) ~= "string" then -- 2475
					error("requireProjectModule expects a project module name string") -- 2477
				end -- 2477
				local moduleName = __TS__StringTrim(moduleNameValue) -- 2479
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 2479
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 2481
				end -- 2481
				local reloadModules = {moduleName} -- 2483
				if reloadModulesValue ~= nil then -- 2483
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 2483
						error("requireProjectModule reloadModules must be an array of module names") -- 2486
					end -- 2486
					local items = reloadModulesValue -- 2488
					do -- 2488
						local i = 0 -- 2489
						while i < #items do -- 2489
							local item = items[i + 1] -- 2490
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 2490
								error("requireProjectModule reloadModules contains an invalid module name") -- 2492
							end -- 2492
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 2492
								reloadModules[#reloadModules + 1] = item -- 2494
							end -- 2494
							i = i + 1 -- 2489
						end -- 2489
					end -- 2489
				end -- 2489
				local luaPackage = _G.package -- 2497
				local previousPath = luaPackage.path -- 2501
				local previousSearchPaths = Content.searchPaths -- 2502
				local scopedSearchPaths = {req.workDir} -- 2503
				do -- 2503
					local i = 0 -- 2504
					while i < #previousSearchPaths do -- 2504
						local searchPath = previousSearchPaths[i + 1] -- 2505
						if searchPath ~= req.workDir then -- 2505
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 2506
						end -- 2506
						i = i + 1 -- 2504
					end -- 2504
				end -- 2504
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 2508
				Content.searchPaths = scopedSearchPaths -- 2509
				do -- 2509
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2509
						do -- 2509
							local i = 0 -- 2511
							while i < #reloadModules do -- 2511
								local reloadName = reloadModules[i + 1] -- 2512
								luaPackage.loaded[reloadName] = nil -- 2513
								luaPackage.loaded[table.concat( -- 2514
									__TS__StringSplit(reloadName, "/"), -- 2514
									"." -- 2514
								)] = nil -- 2514
								luaPackage.loaded[table.concat( -- 2515
									__TS__StringSplit(reloadName, "."), -- 2515
									"/" -- 2515
								)] = nil -- 2515
								i = i + 1 -- 2511
							end -- 2511
						end -- 2511
						return true, require(table.concat( -- 2517
							__TS__StringSplit(moduleName, "/"), -- 2517
							"." -- 2517
						)) -- 2517
					end) -- 2517
					do -- 2517
						Content.searchPaths = previousSearchPaths -- 2519
						luaPackage.path = previousPath -- 2520
					end -- 2520
					if not ____try then -- 2520
						error(____hasReturned, 0) -- 2520
					end -- 2520
					if ____try and ____hasReturned then -- 2520
						return ____returnValue -- 2510
					end -- 2510
				end -- 2510
			end, -- 2475
			print = capturePrint, -- 2523
			refreshTree = function(path) -- 2524
				if path == nil then -- 2524
					return refreshProjectTree(req.workDir) -- 2526
				end -- 2526
				if type(path) ~= "string" then -- 2526
					error("refreshTree expects a project-relative file path string or no argument") -- 2529
				end -- 2529
				return refreshProjectTree(req.workDir, path) -- 2531
			end, -- 2524
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 2533
			enterEntryAsync = function(value) -- 2534
				local normalized = normalizeEntryFile(value) -- 2535
				acquireEntryRuntime() -- 2536
				entry.allClear() -- 2537
				local success, message = entry.enterEntryAsync({ -- 2538
					entryName = normalized.entryName, -- 2539
					fileName = normalized.fileName, -- 2540
					workDir = req.workDir, -- 2541
					projectRoot = req.workDir, -- 2542
					runKind = "agent_test" -- 2543
				}) -- 2543
				return success, message -- 2545
			end, -- 2534
			stopEntry = function() -- 2547
				if not ownsEntryRuntime then -- 2547
					return false -- 2548
				end -- 2548
				return entry.stop() -- 2549
			end -- 2547
		}, -- 2547
		{__index = Dora} -- 2551
	) -- 2551
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 2554
	if not fn then -- 2554
		return __TS__Promise.resolve({ -- 2556
			success = false, -- 2557
			mode = "lua", -- 2558
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2559
			message = truncateCommandError(toStr(compileErr)), -- 2560
			phase = "compile" -- 2561
		}) -- 2561
	end -- 2561
	return __TS__New( -- 2564
		__TS__Promise, -- 2564
		function(____, resolve) -- 2564
			local settled = false -- 2565
			local startedAt = App.runningTime -- 2566
			local onProgress = req.onProgress -- 2567
			local isCancelled = req.isCancelled -- 2568
			local function finish(result) -- 2569
				if settled then -- 2569
					return -- 2570
				end -- 2570
				settled = true -- 2571
				local cleanupError = stopOwnedEntry() -- 2572
				if not result.success and cleanupError ~= nil then -- 2572
					result.cleanupError = cleanupError -- 2574
				elseif result.success and cleanupError ~= nil then -- 2574
					resolve(nil, { -- 2576
						success = false, -- 2577
						mode = "lua", -- 2578
						output = result.output, -- 2579
						message = cleanupError, -- 2580
						phase = "execute", -- 2581
						cleanupError = cleanupError -- 2582
					}) -- 2582
					return -- 2584
				end -- 2584
				resolve(nil, result) -- 2586
			end -- 2569
			if onProgress then -- 2569
				onProgress(nil, { -- 2589
					state = "pending", -- 2590
					mode = "lua", -- 2591
					operationId = req.operationId, -- 2592
					stage = "lua", -- 2593
					message = "Lua command pending" -- 2594
				}) -- 2594
			end -- 2594
			Director.systemScheduler:schedule(function() -- 2597
				if settled then -- 2597
					return true -- 2598
				end -- 2598
				if isCancelled and isCancelled(nil) then -- 2598
					finish({ -- 2600
						success = false, -- 2601
						mode = "lua", -- 2602
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2603
						message = "Lua command canceled", -- 2604
						phase = "execute", -- 2605
						interrupted = true -- 2606
					}) -- 2606
					return true -- 2608
				end -- 2608
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 2608
					finish({ -- 2611
						success = false, -- 2612
						mode = "lua", -- 2613
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2614
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 2615
						phase = "timeout" -- 2616
					}) -- 2616
					return true -- 2618
				end -- 2618
				return false -- 2620
			end) -- 2597
			Director.systemScheduler:schedule(once(function() -- 2622
				if settled then -- 2622
					return -- 2623
				end -- 2623
				if onProgress then -- 2623
					onProgress(nil, { -- 2625
						state = "running", -- 2626
						mode = "lua", -- 2627
						operationId = req.operationId, -- 2628
						stage = "lua", -- 2629
						message = "Lua command running" -- 2630
					}) -- 2630
				end -- 2630
				local previousGlobalPrint = _G.print -- 2633
				_G.print = capturePrint -- 2634
				local ok, runtimeErr = pcall(fn) -- 2635
				_G.print = previousGlobalPrint -- 2636
				if not ok then -- 2636
					finish({ -- 2638
						success = false, -- 2639
						mode = "lua", -- 2640
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2641
						message = truncateCommandError(toStr(runtimeErr)), -- 2642
						phase = "execute" -- 2643
					}) -- 2643
					return -- 2645
				end -- 2645
				finish({ -- 2647
					success = true, -- 2647
					mode = "lua", -- 2647
					output = truncateCommandOutput(table.concat(output, "\n")) -- 2647
				}) -- 2647
			end)) -- 2622
		end -- 2564
	) -- 2564
end -- 2407
local function formatGitStatusOutput(status) -- 2652
	if not status then -- 2652
		return "" -- 2653
	end -- 2653
	local lines = {} -- 2654
	local state = toStr(status.state) -- 2655
	local kind = toStr(status.kind) -- 2656
	local message = toStr(status.message) -- 2657
	local errorMessage = toStr(status.error) -- 2658
	if kind ~= "" or state ~= "" then -- 2658
		lines[#lines + 1] = table.concat( -- 2660
			__TS__ArrayFilter( -- 2660
				{kind, state}, -- 2660
				function(____, item) return item ~= "" end -- 2660
			), -- 2660
			": " -- 2660
		) -- 2660
	end -- 2660
	if message ~= "" then -- 2660
		lines[#lines + 1] = message -- 2662
	end -- 2662
	if errorMessage ~= "" then -- 2662
		lines[#lines + 1] = errorMessage -- 2663
	end -- 2663
	local data = status.data -- 2664
	if data ~= nil then -- 2664
		local dataText = encodeJSON(data) -- 2666
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 2667
	end -- 2667
	return truncateCommandOutput(table.concat(lines, "\n")) -- 2669
end -- 2652
local function emitGitProgress(mode, operationId, onProgress, status) -- 2672
	if not onProgress then -- 2672
		return -- 2678
	end -- 2678
	local progress = type(status.progress) == "number" and status.progress or nil -- 2679
	local kind = toStr(status.kind) -- 2680
	local message = toStr(status.message) -- 2681
	local state = toStr(status.state) -- 2682
	local jobId = type(status.id) == "number" and status.id or nil -- 2683
	onProgress({ -- 2684
		state = "running", -- 2685
		mode = mode, -- 2686
		operationId = operationId, -- 2687
		stage = kind ~= "" and kind or "git", -- 2688
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 2689
		progress = progress, -- 2690
		jobId = jobId, -- 2691
		gitState = state ~= "" and state or nil, -- 2692
		gitKind = kind ~= "" and kind or nil -- 2693
	}) -- 2693
end -- 2672
local function cloneGitToTarget(req) -- 2697
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2697
		local parsed = parseGitCloneCommand(req.command) -- 2705
		if parsed == nil then -- 2705
			return ____awaiter_resolve(nil, nil) -- 2705
		end -- 2705
		if not parsed.success then -- 2705
			return ____awaiter_resolve(nil, { -- 2705
				success = false, -- 2708
				mode = "git", -- 2708
				output = "", -- 2708
				message = parsed.message, -- 2708
				phase = "validate" -- 2708
			}) -- 2708
		end -- 2708
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 2710
		if not target then -- 2710
			return ____awaiter_resolve(nil, { -- 2710
				success = false, -- 2712
				mode = "git", -- 2712
				output = "", -- 2712
				message = "invalid clone target path", -- 2712
				phase = "validate" -- 2712
			}) -- 2712
		end -- 2712
		if Content:exist(target) then -- 2712
			return ____awaiter_resolve(nil, { -- 2712
				success = false, -- 2715
				mode = "git", -- 2715
				output = "", -- 2715
				message = "target already exists", -- 2715
				phase = "validate" -- 2715
			}) -- 2715
		end -- 2715
		local targetParent = Path:getPath(target) -- 2717
		if not ensureDirPath(targetParent) then -- 2717
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 2717
		end -- 2717
		local tempRoot = getAgentDownloadTempRoot() -- 2721
		if not ensureDirPath(tempRoot) then -- 2721
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 2721
		end -- 2721
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 2725
		Content:remove(tempPath) -- 2726
		local depth = parsed.depth or "1" -- 2727
		local ____array_41 = __TS__SparseArrayNew( -- 2727
			"clone", -- 2729
			quoteGitArg(parsed.url), -- 2730
			quoteGitArg(Path:getFilename(tempPath)), -- 2731
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 2732
				"-b", -- 2732
				quoteGitArg(parsed.ref) -- 2732
			}) or ({})) -- 2732
		) -- 2732
		__TS__SparseArrayPush( -- 2732
			____array_41, -- 2732
			table.unpack(depth ~= "" and ({ -- 2733
				"--depth",
				quoteGitArg(depth) -- 2733
			}) or ({})) -- 2733
		) -- 2733
		local command = table.concat( -- 2728
			{__TS__SparseArraySpread(____array_41)}, -- 2728
			" " -- 2734
		) -- 2734
		local ____this_43 -- 2734
		____this_43 = req -- 2735
		local ____opt_42 = ____this_43.onProgress -- 2735
		if ____opt_42 ~= nil then -- 2735
			____opt_42(____this_43, { -- 2735
				state = "pending", -- 2736
				mode = "git", -- 2737
				operationId = req.operationId, -- 2738
				stage = "clone", -- 2739
				message = "clone pending", -- 2740
				progress = 0 -- 2741
			}) -- 2741
		end -- 2741
		local gitRes = __TS__Await(runGitAndWait( -- 2743
			tempRoot, -- 2744
			command, -- 2745
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2746
			function() -- 2747
				local ____this_45 -- 2747
				____this_45 = req -- 2747
				local ____opt_44 = ____this_45.isCancelled -- 2747
				return (____opt_44 and ____opt_44(____this_45)) == true -- 2747
			end, -- 2747
			req.timeoutSeconds -- 2748
		)) -- 2748
		if not gitRes.success then -- 2748
			local cleanupError = cleanupPath(tempPath) -- 2751
			local ____formatGitStatusOutput_result_49 = formatGitStatusOutput(gitRes.status) -- 2755
			local ____temp_50 = gitRes.message or "git clone failed" -- 2756
			local ____gitRes_interrupted_48 = gitRes.interrupted -- 2757
			if not ____gitRes_interrupted_48 then -- 2757
				local ____this_47 -- 2757
				____this_47 = req -- 2757
				local ____opt_46 = ____this_47.isCancelled -- 2757
				____gitRes_interrupted_48 = (____opt_46 and ____opt_46(____this_47)) == true -- 2757
			end -- 2757
			return ____awaiter_resolve(nil, { -- 2757
				success = false, -- 2753
				mode = "git", -- 2754
				output = ____formatGitStatusOutput_result_49, -- 2755
				message = ____temp_50, -- 2756
				interrupted = ____gitRes_interrupted_48, -- 2757
				cleanupError = cleanupError -- 2758
			}) -- 2758
		end -- 2758
		if not Content:move(tempPath, target) then -- 2758
			local cleanupError = cleanupPath(tempPath) -- 2762
			return ____awaiter_resolve( -- 2762
				nil, -- 2762
				{ -- 2763
					success = false, -- 2763
					mode = "git", -- 2763
					output = formatGitStatusOutput(gitRes.status), -- 2763
					message = "failed to move cloned repository into target path", -- 2763
					cleanupError = cleanupError -- 2763
				} -- 2763
			) -- 2763
		end -- 2763
		if not refreshProjectTree(req.workDir) then -- 2763
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 2766
		end -- 2766
		local commit = getGitHeadCommit(target) -- 2768
		local output = table.concat( -- 2769
			__TS__ArrayFilter( -- 2769
				{ -- 2769
					formatGitStatusOutput(gitRes.status), -- 2770
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 2770
					commit ~= nil and "commit " .. commit or "" -- 2772
				}, -- 2772
				function(____, item) return item ~= "" end -- 2773
			), -- 2773
			"\n" -- 2773
		) -- 2773
		return ____awaiter_resolve( -- 2773
			nil, -- 2773
			{ -- 2774
				success = true, -- 2774
				mode = "git", -- 2774
				output = truncateCommandOutput(output) -- 2774
			} -- 2774
		) -- 2774
	end) -- 2774
end -- 2697
local function loadGitProfile() -- 2777
	local rows -- 2778
	do -- 2778
		local function ____catch() -- 2778
			return true, nil -- 2782
		end -- 2782
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2782
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 2780
		end) -- 2780
		if not ____try then -- 2780
			____hasReturned, ____returnValue = ____catch() -- 2780
		end -- 2780
		if ____hasReturned then -- 2780
			return ____returnValue -- 2779
		end -- 2779
	end -- 2779
	if not rows or not rows[1] then -- 2779
		return nil -- 2784
	end -- 2784
	local name = toStr(rows[1][1]) -- 2785
	local email = toStr(rows[1][2]) -- 2786
	if name == "" and email == "" then -- 2786
		return nil -- 2787
	end -- 2787
	return {name = name, email = email} -- 2788
end -- 2777
local function applyGitProfileToCommit(command) -- 2791
	local args = shellSplit(command) -- 2792
	if args[1] ~= "commit" then -- 2792
		return command -- 2793
	end -- 2793
	local hasName = false -- 2794
	local hasEmail = false -- 2795
	for ____, arg in ipairs(args) do -- 2796
		if arg == "--author-name" then
			hasName = true -- 2797
		end -- 2797
		if arg == "--author-email" then
			hasEmail = true -- 2798
		end -- 2798
	end -- 2798
	if hasName and hasEmail then -- 2798
		return command -- 2800
	end -- 2800
	local profile = loadGitProfile() -- 2801
	if not profile then -- 2801
		return command -- 2802
	end -- 2802
	local additions = {} -- 2803
	if not hasName and profile.name ~= "" then -- 2803
		__TS__ArrayPush( -- 2805
			additions, -- 2805
			"--author-name",
			quoteGitArg(profile.name) -- 2805
		) -- 2805
	end -- 2805
	if not hasEmail and profile.email ~= "" then -- 2805
		__TS__ArrayPush( -- 2808
			additions, -- 2808
			"--author-email",
			quoteGitArg(profile.email) -- 2808
		) -- 2808
	end -- 2808
	if #additions == 0 then -- 2808
		return command -- 2810
	end -- 2810
	return (command .. " ") .. table.concat(additions, " ") -- 2811
end -- 2791
local function executeGitCommand(req) -- 2814
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2814
		local command = normalizeGitCommand(req.command or "") -- 2823
		if command == "" then -- 2823
			return ____awaiter_resolve(nil, { -- 2823
				success = false, -- 2825
				mode = "git", -- 2825
				output = "", -- 2825
				message = "missing command", -- 2825
				phase = "validate" -- 2825
			}) -- 2825
		end -- 2825
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 2827
			workDir = req.workDir, -- 2828
			command = command, -- 2829
			operationId = req.operationId, -- 2830
			timeoutSeconds = req.timeoutSeconds, -- 2831
			onProgress = req.onProgress, -- 2832
			isCancelled = req.isCancelled -- 2833
		})) -- 2833
		if cloneResult ~= nil then -- 2833
			return ____awaiter_resolve(nil, cloneResult) -- 2833
		end -- 2833
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 2836
		if not cwd.success then -- 2836
			return ____awaiter_resolve(nil, { -- 2836
				success = false, -- 2838
				mode = "git", -- 2838
				output = "", -- 2838
				cwd = req.cwd, -- 2838
				message = cwd.message, -- 2838
				phase = "validate" -- 2838
			}) -- 2838
		end -- 2838
		command = applyGitProfileToCommit(command) -- 2840
		local ____this_52 -- 2840
		____this_52 = req -- 2841
		local ____opt_51 = ____this_52.onProgress -- 2841
		if ____opt_51 ~= nil then -- 2841
			____opt_51(____this_52, { -- 2841
				state = "pending", -- 2842
				mode = "git", -- 2843
				operationId = req.operationId, -- 2844
				stage = "git", -- 2845
				message = "git command pending", -- 2846
				progress = 0 -- 2847
			}) -- 2847
		end -- 2847
		local gitRes = __TS__Await(runGitAndWait( -- 2849
			cwd.path, -- 2850
			command, -- 2851
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2852
			function() -- 2853
				local ____this_54 -- 2853
				____this_54 = req -- 2853
				local ____opt_53 = ____this_54.isCancelled -- 2853
				return (____opt_53 and ____opt_53(____this_54)) == true -- 2853
			end, -- 2853
			req.timeoutSeconds -- 2854
		)) -- 2854
		local output = formatGitStatusOutput(gitRes.status) -- 2856
		if not gitRes.success then -- 2856
			local ____output_58 = output -- 2861
			local ____cwd_relative_59 = cwd.relative -- 2862
			local ____temp_60 = gitRes.message or "git command failed" -- 2863
			local ____gitRes_interrupted_57 = gitRes.interrupted -- 2864
			if not ____gitRes_interrupted_57 then -- 2864
				local ____this_56 -- 2864
				____this_56 = req -- 2864
				local ____opt_55 = ____this_56.isCancelled -- 2864
				____gitRes_interrupted_57 = (____opt_55 and ____opt_55(____this_56)) == true -- 2864
			end -- 2864
			return ____awaiter_resolve(nil, { -- 2864
				success = false, -- 2859
				mode = "git", -- 2860
				output = ____output_58, -- 2861
				cwd = ____cwd_relative_59, -- 2862
				message = ____temp_60, -- 2863
				interrupted = ____gitRes_interrupted_57 -- 2864
			}) -- 2864
		end -- 2864
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 2864
	end) -- 2864
end -- 2814
function ____exports.executeCommand(req) -- 2870
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2870
		local mode = req.mode -- 2880
		if mode ~= "lua" and mode ~= "git" then -- 2880
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 2880
		end -- 2880
		if mode == "lua" then -- 2880
			return ____awaiter_resolve( -- 2880
				nil, -- 2880
				executeLuaCommand({ -- 2885
					workDir = req.workDir, -- 2886
					code = req.code or "", -- 2887
					timeoutSeconds = math.max( -- 2888
						1, -- 2888
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 2888
					), -- 2888
					operationId = createOperationId(), -- 2889
					onProgress = req.onProgress, -- 2890
					isCancelled = req.isCancelled -- 2891
				}) -- 2891
			) -- 2891
		end -- 2891
		local operationId = createOperationId() -- 2894
		return ____awaiter_resolve( -- 2894
			nil, -- 2894
			executeGitCommand({ -- 2895
				workDir = req.workDir, -- 2896
				command = req.command or "", -- 2897
				cwd = req.cwd, -- 2898
				timeoutSeconds = math.max( -- 2899
					1, -- 2899
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 2899
				), -- 2899
				operationId = operationId, -- 2900
				onProgress = req.onProgress, -- 2901
				isCancelled = req.isCancelled -- 2902
			}) -- 2902
		) -- 2902
	end) -- 2902
end -- 2870
function ____exports.fetchUrl(req) -- 2906
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2906
		local mode = "download" -- 2913
		local url = __TS__StringTrim(req.url or "") -- 2914
		local targetRel = __TS__StringTrim(req.target or "") -- 2915
		if not isHttpUrl(url) then -- 2915
			return ____awaiter_resolve(nil, { -- 2915
				success = false, -- 2917
				state = "failed", -- 2917
				mode = mode, -- 2917
				target = targetRel, -- 2917
				message = "fetch_url only supports http:// and https:// URLs" -- 2917
			}) -- 2917
		end -- 2917
		if targetRel == "" then -- 2917
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 2917
		end -- 2917
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 2922
		if not target then -- 2922
			return ____awaiter_resolve(nil, { -- 2922
				success = false, -- 2924
				state = "failed", -- 2924
				mode = mode, -- 2924
				target = targetRel, -- 2924
				message = "invalid target path" -- 2924
			}) -- 2924
		end -- 2924
		if Content:exist(target) then -- 2924
			return ____awaiter_resolve(nil, { -- 2924
				success = false, -- 2927
				state = "failed", -- 2927
				mode = mode, -- 2927
				target = targetRel, -- 2927
				message = "target already exists" -- 2927
			}) -- 2927
		end -- 2927
		local operationId = createOperationId() -- 2929
		local tempRoot = getAgentDownloadTempRoot() -- 2930
		if not ensureDirPath(tempRoot) then -- 2930
			return ____awaiter_resolve(nil, { -- 2930
				success = false, -- 2932
				state = "failed", -- 2932
				mode = mode, -- 2932
				target = targetRel, -- 2932
				message = "failed to create agent download temp directory" -- 2932
			}) -- 2932
		end -- 2932
		local tempPath = Path(tempRoot, operationId .. ".download") -- 2934
		Content:remove(tempPath) -- 2935
		local function emitProgress(progress) -- 2936
			if not req.onProgress then -- 2936
				return -- 2937
			end -- 2937
			req:onProgress(__TS__ObjectAssign({ -- 2938
				state = "running", -- 2939
				mode = mode, -- 2940
				operationId = operationId, -- 2941
				target = targetRel, -- 2942
				tempPath = tempPath -- 2943
			}, progress)) -- 2943
		end -- 2936
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 2947
		local function interrupted() -- 2952
			local ____this_62 -- 2952
			____this_62 = req -- 2952
			local ____opt_61 = ____this_62.isCancelled -- 2952
			return (____opt_61 and ____opt_61(____this_62)) == true -- 2952
		end -- 2952
		if not ensureDirForFile(tempPath) then -- 2952
			return ____awaiter_resolve(nil, { -- 2952
				success = false, -- 2954
				state = "failed", -- 2954
				mode = mode, -- 2954
				target = targetRel, -- 2954
				message = "failed to create temporary file directory" -- 2954
			}) -- 2954
		end -- 2954
		local downloadRes = __TS__Await(downloadFile({ -- 2956
			url = url, -- 2957
			tempPath = tempPath, -- 2958
			timeout = 600, -- 2959
			isCancelled = interrupted, -- 2960
			onProgress = function(____, current, total) -- 2961
				local totalNumber = type(total) == "number" and total or 0 -- 2962
				emitProgress({ -- 2963
					stage = "download", -- 2964
					message = "downloading", -- 2965
					current = current, -- 2966
					total = total, -- 2967
					progress = totalNumber > 0 and current / totalNumber or nil -- 2968
				}) -- 2968
			end -- 2961
		})) -- 2961
		if not downloadRes.success then -- 2961
			local cleanupError = cleanupPath(tempPath) -- 2973
			return ____awaiter_resolve( -- 2973
				nil, -- 2973
				{ -- 2974
					success = false, -- 2975
					state = "failed", -- 2976
					mode = mode, -- 2977
					target = targetRel, -- 2978
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 2979
					interrupted = downloadRes.interrupted or interrupted(), -- 2980
					cleanupError = cleanupError -- 2981
				} -- 2981
			) -- 2981
		end -- 2981
		if not ensureDirForFile(target) then -- 2981
			local cleanupError = cleanupPath(tempPath) -- 2985
			return ____awaiter_resolve(nil, { -- 2985
				success = false, -- 2986
				state = "failed", -- 2986
				mode = mode, -- 2986
				target = targetRel, -- 2986
				message = "failed to create target directory", -- 2986
				cleanupError = cleanupError -- 2986
			}) -- 2986
		end -- 2986
		if not Content:move(tempPath, target) then -- 2986
			local cleanupError = cleanupPath(tempPath) -- 2989
			return ____awaiter_resolve(nil, { -- 2989
				success = false, -- 2990
				state = "failed", -- 2990
				mode = mode, -- 2990
				target = targetRel, -- 2990
				message = "failed to move downloaded file into target path", -- 2990
				cleanupError = cleanupError -- 2990
			}) -- 2990
		end -- 2990
		local bytesWritten = downloadRes.bytesWritten -- 2992
		local ____try = __TS__AsyncAwaiter(function() -- 2992
			local size = Content:getAttr(target) -- 2994
			if bytesWritten == nil or bytesWritten <= 0 then -- 2994
				bytesWritten = type(size) == "number" and size or nil -- 2996
			end -- 2996
		end) -- 2996
		____try = ____try.catch( -- 2996
			____try, -- 2996
			function(____, _) -- 2996
				return __TS__AsyncAwaiter(function() -- 2996
				end) -- 2996
			end -- 2996
		) -- 2996
		__TS__Await(____try) -- 2993
		if bytesWritten == nil or bytesWritten <= 0 then -- 2993
			local ____try = __TS__AsyncAwaiter(function() -- 2993
				local loaded = Content:load(target) -- 3003
				if type(loaded) == "string" then -- 3003
					bytesWritten = #loaded -- 3005
				end -- 3005
			end) -- 3005
			____try = ____try.catch( -- 3005
				____try, -- 3005
				function(____, _) -- 3005
					return __TS__AsyncAwaiter(function() -- 3005
					end) -- 3005
				end -- 3005
			) -- 3005
			__TS__Await(____try) -- 3002
		end -- 3002
		if not syncDownloadedFileToWebIDE(target) then -- 3002
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 3012
		end -- 3012
		return ____awaiter_resolve(nil, { -- 3012
			success = true, -- 3014
			state = "done", -- 3014
			mode = mode, -- 3014
			target = targetRel, -- 3014
			bytesWritten = bytesWritten -- 3014
		}) -- 3014
	end) -- 3014
end -- 2906
return ____exports -- 2906