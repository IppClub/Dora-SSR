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
function normalizeEscapedGitQuotes(command) -- 680
	local result = "" -- 681
	do -- 681
		local i = 0 -- 682
		while i < #command do -- 682
			do -- 682
				local ch = __TS__StringCharAt(command, i) -- 683
				local next = __TS__StringCharAt(command, i + 1) -- 684
				if ch == "\\" and (next == "\"" or next == "'") then -- 684
					result = result .. next -- 686
					i = i + 1 -- 687
					goto __continue112 -- 688
				end -- 688
				result = result .. ch -- 690
			end -- 690
			::__continue112:: -- 690
			i = i + 1 -- 682
		end -- 682
	end -- 682
	return result -- 692
end -- 692
function encodeJSON(obj) -- 1214
	local text = safeJsonEncode(obj) -- 1215
	return text -- 1216
end -- 1216
function ____exports.sendWebIDEFileUpdate(file, exists, content) -- 1219
	if HttpServer.wsConnectionCount == 0 then -- 1219
		return true -- 1221
	end -- 1221
	local payload = encodeJSON({name = "UpdateFile", file = file, exists = exists, content = content}) -- 1223
	if not payload then -- 1223
		return false -- 1225
	end -- 1225
	emit("AppWS", "Send", payload) -- 1227
	return true -- 1228
end -- 1219
function getEngineLogText() -- 1557
	local folder = Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR) -- 1558
	if not Content:exist(folder) then -- 1558
		Content:mkdir(folder) -- 1560
	end -- 1560
	local logPath = Path(folder, ENGINE_LOG_FILE) -- 1562
	if not App:saveLog(logPath) then -- 1562
		return nil -- 1564
	end -- 1564
	return Content:load(logPath) -- 1566
end -- 1566
function ensureSafeSearchGlobs(globs) -- 1706
	local result = {} -- 1707
	do -- 1707
		local i = 0 -- 1708
		while i < #globs do -- 1708
			result[#result + 1] = globs[i + 1] -- 1709
			i = i + 1 -- 1708
		end -- 1708
	end -- 1708
	local requiredExcludes = {"!**/.*/**", "!**/node_modules/**"} -- 1711
	do -- 1711
		local i = 0 -- 1712
		while i < #requiredExcludes do -- 1712
			if __TS__ArrayIndexOf(result, requiredExcludes[i + 1]) == -1 then -- 1712
				result[#result + 1] = requiredExcludes[i + 1] -- 1714
			end -- 1714
			i = i + 1 -- 1712
		end -- 1712
	end -- 1712
	return result -- 1717
end -- 1717
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
local TABLE_TASK = "AgentTask" -- 400
local TABLE_CP = "AgentCheckpoint" -- 401
local TABLE_ENTRY = "AgentCheckpointEntry" -- 402
ENGINE_LOG_DOWNLOAD_DIR = ".download" -- 403
ENGINE_LOG_FILE = "dora_full_logs.txt" -- 404
local AGENT_DOWNLOAD_TEMP_DIR = "agent" -- 405
local function now() -- 406
	return os.time() -- 406
end -- 406
local function toBool(v) -- 408
	return v ~= 0 and v ~= false and v ~= nil -- 409
end -- 408
local function toStr(v) -- 412
	if v == false or v == nil then -- 412
		return "" -- 413
	end -- 413
	return tostring(v) -- 414
end -- 412
local function isValidWorkspacePath(path) -- 417
	if not path or #path == 0 then -- 417
		return false -- 418
	end -- 418
	if Content:isAbsolutePath(path) then -- 418
		return false -- 419
	end -- 419
	if __TS__StringIncludes(path, "..") then -- 419
		return false -- 420
	end -- 420
	return true -- 421
end -- 417
local function isValidWorkDir(workDir) -- 424
	if not workDir or #workDir == 0 then -- 424
		return false -- 425
	end -- 425
	if not Content:isAbsolutePath(workDir) then -- 425
		return false -- 426
	end -- 426
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 426
		return false -- 427
	end -- 427
	return true -- 428
end -- 424
local function isValidSearchPath(path) -- 431
	if path == "" then -- 431
		return true -- 432
	end -- 432
	if Content:isAbsolutePath(path) then -- 432
		return false -- 433
	end -- 433
	if not path or #path == 0 then -- 433
		return false -- 434
	end -- 434
	if __TS__StringIncludes(path, "..") then -- 434
		return false -- 435
	end -- 435
	return true -- 436
end -- 431
local function resolveWorkspaceFilePath(workDir, path) -- 439
	if not isValidWorkDir(workDir) then -- 439
		return nil -- 440
	end -- 440
	if not isValidWorkspacePath(path) then -- 440
		return nil -- 441
	end -- 441
	return Path(workDir, path) -- 442
end -- 439
local function resolveWorkspaceSearchPath(workDir, path) -- 445
	if not isValidWorkDir(workDir) then -- 445
		return nil -- 446
	end -- 446
	if not isValidSearchPath(path) then -- 446
		return nil -- 447
	end -- 447
	return path == "" and workDir or Path(workDir, path) -- 448
end -- 445
local function toWorkspaceRelativePath(workDir, path) -- 451
	if not path or #path == 0 then -- 451
		return path -- 452
	end -- 452
	if not Content:isAbsolutePath(path) then -- 452
		return path -- 453
	end -- 453
	return Path:getRelative(path, workDir) -- 454
end -- 451
local function toWorkspaceRelativeFileList(workDir, files) -- 457
	return __TS__ArrayMap( -- 458
		files, -- 458
		function(____, file) return toWorkspaceRelativePath(workDir, file) end -- 458
	) -- 458
end -- 457
local function toWorkspaceRelativeSearchResults(workDir, results) -- 461
	local mapped = {} -- 462
	do -- 462
		local i = 0 -- 463
		while i < #results do -- 463
			local row = results[i + 1] -- 464
			local clone = __TS__ObjectAssign({}, row) -- 465
			clone.file = toWorkspaceRelativePath(workDir, clone.file) -- 466
			mapped[#mapped + 1] = clone -- 467
			i = i + 1 -- 463
		end -- 463
	end -- 463
	return mapped -- 469
end -- 461
local function resolveWorkspaceDirectoryPath(workDir, path) -- 472
	local relative = __TS__StringTrim(path or "") -- 473
	if relative == "" then -- 473
		return {success = true, path = workDir, relative = "."} -- 475
	end -- 475
	if not isValidWorkDir(workDir) or not isValidWorkspacePath(relative) then -- 475
		return {success = false, message = "invalid cwd path"} -- 478
	end -- 478
	local resolved = Path(workDir, relative) -- 480
	if not Content:exist(resolved) then -- 480
		return {success = false, message = "cwd does not exist"} -- 482
	end -- 482
	if not Content:isdir(resolved) then -- 482
		return {success = false, message = "cwd is not a directory"} -- 485
	end -- 485
	return {success = true, path = resolved, relative = relative} -- 487
end -- 472
local function getDoraAPIDocRoot(docLanguage) -- 490
	local zhDir = Path( -- 491
		Content.assetPath, -- 491
		"Script", -- 491
		"Lib", -- 491
		"Dora", -- 491
		"zh-Hans" -- 491
	) -- 491
	local enDir = Path( -- 492
		Content.assetPath, -- 492
		"Script", -- 492
		"Lib", -- 492
		"Dora", -- 492
		"en" -- 492
	) -- 492
	return docLanguage == "zh" and zhDir or enDir -- 493
end -- 490
local function getDoraTutorialDocRoot(docLanguage) -- 496
	local zhDir = Path(Content.assetPath, "Doc", "zh-Hans", "Tutorial") -- 497
	local enDir = Path(Content.assetPath, "Doc", "en", "Tutorial") -- 498
	return docLanguage == "zh" and zhDir or enDir -- 499
end -- 496
local function getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 502
	if programmingLanguage == "ts" or programmingLanguage == "tsx" then -- 502
		return {"ts"} -- 504
	end -- 504
	return {"tl"} -- 506
end -- 502
local function getTutorialProgrammingLanguageDir(programmingLanguage) -- 509
	repeat -- 509
		local ____switch65 = programmingLanguage -- 509
		local ____cond65 = ____switch65 == "teal" -- 509
		if ____cond65 then -- 509
			return "tl" -- 511
		end -- 511
		____cond65 = ____cond65 or ____switch65 == "tl" -- 511
		if ____cond65 then -- 511
			return "tl" -- 512
		end -- 512
		do -- 512
			return programmingLanguage -- 513
		end -- 513
	until true -- 513
end -- 509
local function getDoraDocSearchTarget(docSource, docLanguage, programmingLanguage) -- 517
	if docSource == "tutorial" then -- 517
		local tutorialRoot = getDoraTutorialDocRoot(docLanguage) -- 523
		local langDir = getTutorialProgrammingLanguageDir(programmingLanguage) -- 524
		return { -- 525
			root = Path(tutorialRoot, langDir), -- 526
			exts = {"md"}, -- 527
			globs = {"**/*.md"} -- 528
		} -- 528
	end -- 528
	local exts = getDoraAPIDocExtsByCodeLanguage(programmingLanguage) -- 531
	return { -- 532
		root = getDoraAPIDocRoot(docLanguage), -- 533
		exts = exts, -- 534
		globs = __TS__ArrayMap( -- 535
			exts, -- 535
			function(____, ext) return "**/*." .. ext end -- 535
		) -- 535
	} -- 535
end -- 517
local function getDoraDocResultBaseRoot(docSource, docLanguage) -- 539
	if docSource == "tutorial" then -- 539
		return getDoraTutorialDocRoot(docLanguage) -- 541
	end -- 541
	return getDoraAPIDocRoot(docLanguage) -- 543
end -- 539
local AGENT_DORA_DOC_PREFIX = "@dora-doc/" -- 546
local function toDocRelativePath(baseRoot, path, docSource) -- 548
	if not path or #path == 0 then -- 548
		return path -- 549
	end -- 549
	local relative = Content:isAbsolutePath(path) and Path:getRelative(path, baseRoot) or path -- 550
	return ((AGENT_DORA_DOC_PREFIX .. docSource) .. "/") .. relative -- 551
end -- 548
local function resolveAgentDoraDocFilePath(path, docLanguage) -- 554
	if not docLanguage then -- 554
		return nil -- 555
	end -- 555
	local relative = path -- 556
	local source = "tutorial" -- 557
	if __TS__StringStartsWith(path, AGENT_DORA_DOC_PREFIX) then -- 557
		local namespaced = __TS__StringSlice(path, #AGENT_DORA_DOC_PREFIX) -- 559
		if __TS__StringStartsWith(namespaced, "api/") then -- 559
			source = "api" -- 561
			relative = string.sub(namespaced, 5) -- 562
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 562
			relative = string.sub(namespaced, 10) -- 564
		else -- 564
			return nil -- 566
		end -- 566
	end -- 566
	if not isValidWorkspacePath(relative) then -- 566
		return nil -- 569
	end -- 569
	local candidate = Path( -- 570
		getDoraDocResultBaseRoot(source, docLanguage), -- 570
		relative -- 570
	) -- 570
	local root = getDoraDocResultBaseRoot(source, docLanguage) -- 571
	local checked = Path:getRelative(candidate, root) -- 572
	if checked == ".." or __TS__StringStartsWith(checked, "../") or __TS__StringStartsWith(checked, "..\\") then -- 572
		return nil -- 573
	end -- 573
	if Content:exist(candidate) and not Content:isdir(candidate) then -- 573
		return candidate -- 575
	end -- 575
	return nil -- 577
end -- 554
local function ensureDirPath(dir) -- 580
	if not dir or dir == "." or dir == "" then -- 580
		return true -- 581
	end -- 581
	if Content:exist(dir) then -- 581
		return Content:isdir(dir) -- 582
	end -- 582
	local parent = Path:getPath(dir) -- 583
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 583
		if not ensureDirPath(parent) then -- 583
			return false -- 585
		end -- 585
	end -- 585
	return Content:mkdir(dir) -- 587
end -- 580
local function ensureDirForFile(path) -- 590
	local dir = Path:getPath(path) -- 591
	return ensureDirPath(dir) -- 592
end -- 590
local function isHttpUrl(url) -- 595
	local normalized = string.lower(__TS__StringTrim(url)) -- 596
	return __TS__StringStartsWith(normalized, "http://") or __TS__StringStartsWith(normalized, "https://") -- 597
end -- 595
local function createOperationId() -- 600
	local raw = (tostring(os.time()) .. "-") .. tostring(math.floor(math.random() * 1000000000)) -- 601
	local safe = string.gsub(raw, "[^%w%-_]", "-") -- 602
	return safe -- 603
end -- 600
local function getAgentDownloadTempRoot() -- 606
	return Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR, AGENT_DOWNLOAD_TEMP_DIR) -- 607
end -- 606
local function cleanupPath(path) -- 610
	if not path or path == "" or not Content:exist(path) then -- 610
		return nil -- 611
	end -- 611
	if Content:remove(path) then -- 611
		return nil -- 612
	end -- 612
	return "failed to remove temporary path: " .. path -- 613
end -- 610
local function quoteGitArg(value) -- 616
	local plain = string.match(value, "^[%w%._%-%/]+$") -- 617
	if plain ~= nil then -- 617
		return value -- 619
	end -- 619
	local escaped = string.gsub(value, "\\", "\\\\") -- 621
	escaped = string.gsub(escaped, "\"", "\\\"") -- 622
	return ("\"" .. escaped) .. "\"" -- 623
end -- 616
local function shellSplit(command) -- 626
	local args = {} -- 627
	local current = "" -- 628
	local quote = "" -- 629
	local escaped = false -- 630
	do -- 630
		local i = 0 -- 631
		while i < #command do -- 631
			do -- 631
				local ch = __TS__StringCharAt(command, i) -- 632
				if escaped then -- 632
					current = current .. ch -- 634
					escaped = false -- 635
					goto __continue98 -- 636
				end -- 636
				if ch == "\\" then -- 636
					escaped = true -- 639
					goto __continue98 -- 640
				end -- 640
				if quote ~= "" then -- 640
					if ch == quote then -- 640
						quote = "" -- 644
					else -- 644
						current = current .. ch -- 646
					end -- 646
					goto __continue98 -- 648
				end -- 648
				if ch == "'" or ch == "\"" then -- 648
					quote = ch -- 651
					goto __continue98 -- 652
				end -- 652
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 652
					if current ~= "" then -- 652
						args[#args + 1] = current -- 656
						current = "" -- 657
					end -- 657
					goto __continue98 -- 659
				end -- 659
				current = current .. ch -- 661
			end -- 661
			::__continue98:: -- 661
			i = i + 1 -- 631
		end -- 631
	end -- 631
	if escaped then -- 631
		current = current .. "\\" -- 664
	end -- 664
	if current ~= "" then -- 664
		args[#args + 1] = current -- 667
	end -- 667
	return args -- 669
end -- 626
local function normalizeGitCommand(command) -- 672
	local trimmed = __TS__StringTrim(command) -- 673
	local normalized = string.lower(string.sub(trimmed, 1, 4)) == "git " and __TS__StringTrim(string.sub(trimmed, 5)) or trimmed -- 674
	return normalizeEscapedGitQuotes(normalized) -- 677
end -- 672
local function gitDefaultTargetFromUrl(url) -- 695
	local target = url -- 696
	local hashIndex = (string.find(target, "#", nil, true) or 0) - 1 -- 697
	if hashIndex >= 0 then -- 697
		target = __TS__StringSlice(target, 0, hashIndex) -- 698
	end -- 698
	local queryIndex = (string.find(target, "?", nil, true) or 0) - 1 -- 699
	if queryIndex >= 0 then -- 699
		target = __TS__StringSlice(target, 0, queryIndex) -- 700
	end -- 700
	target = string.gsub(target, "/+$", "") -- 701
	local name = string.match(target, "([^/]+)$") -- 702
	if name ~= nil and name ~= "" then -- 702
		target = name -- 703
	end -- 703
	if __TS__StringEndsWith( -- 703
		string.lower(target), -- 704
		".git" -- 704
	) then -- 704
		target = __TS__StringSlice(target, 0, #target - 4) -- 705
	end -- 705
	return target ~= "" and target or "repo" -- 707
end -- 695
local function parseGitCloneCommand(command) -- 710
	local args = shellSplit(normalizeGitCommand(command)) -- 720
	if #args == 0 or args[1] ~= "clone" then -- 720
		return nil -- 721
	end -- 721
	local url = "" -- 722
	local target = "" -- 723
	local ref -- 724
	local depth -- 725
	do -- 725
		local i = 1 -- 726
		while i < #args do -- 726
			do -- 726
				local arg = args[i + 1] -- 727
				if arg == "-b" or arg == "--branch" then
					i = i + 1 -- 729
					if i >= #args then -- 729
						return {success = false, message = arg .. " requires a value"} -- 730
					end -- 730
					ref = args[i + 1] -- 731
					goto __continue122 -- 732
				end -- 732
				if arg == "--depth" then
					i = i + 1 -- 735
					if i >= #args then -- 735
						return {success = false, message = "--depth requires a value"}
					end -- 736
					depth = args[i + 1] -- 737
					goto __continue122 -- 738
				end -- 738
				if __TS__StringStartsWith(arg, "--depth=") then
					depth = __TS__StringSlice(arg, #"--depth=")
					goto __continue122 -- 742
				end -- 742
				if __TS__StringStartsWith(arg, "-") then -- 742
					return {success = false, message = "unsupported clone option: " .. arg} -- 745
				end -- 745
				if url == "" then -- 745
					url = arg -- 748
					goto __continue122 -- 749
				end -- 749
				if target == "" then -- 749
					target = arg -- 752
					goto __continue122 -- 753
				end -- 753
				return {success = false, message = "unexpected clone argument: " .. arg} -- 755
			end -- 755
			::__continue122:: -- 755
			i = i + 1 -- 726
		end -- 726
	end -- 726
	if url == "" then -- 726
		return {success = false, message = "git clone requires a URL"} -- 757
	end -- 757
	if not isHttpUrl(url) then -- 757
		return {success = false, message = "git clone only supports http:// and https:// URLs"} -- 758
	end -- 758
	if target == "" then -- 758
		target = gitDefaultTargetFromUrl(url) -- 759
	end -- 759
	return { -- 760
		success = true, -- 761
		url = url, -- 762
		target = target, -- 763
		ref = ref, -- 764
		depth = depth ~= nil and depth ~= "" and depth or "1" -- 765
	} -- 765
end -- 710
local function getGitHeadCommit(repoPath) -- 769
	local headPath = Path(repoPath, ".git", "HEAD") -- 770
	if not Content:exist(headPath) then -- 770
		return nil -- 771
	end -- 771
	local head = __TS__StringTrim(toStr(Content:load(headPath))) -- 772
	local ref = string.match(head, "^ref:%s*(.-)%s*$") -- 773
	if ref ~= nil and ref ~= "" then -- 773
		local refPath = Path(repoPath, ".git", ref) -- 775
		if Content:exist(refPath) then -- 775
			local commit = __TS__StringTrim(toStr(Content:load(refPath))) -- 777
			return commit ~= "" and commit or nil -- 778
		end -- 778
		return nil -- 780
	end -- 780
	return head ~= "" and head or nil -- 782
end -- 769
local function runGitAndWait(repoPath, command, onStatus, isCancelled, timeout) -- 785
	if timeout == nil then -- 785
		timeout = 600 -- 790
	end -- 790
	return __TS__New( -- 792
		__TS__Promise, -- 792
		function(____, resolve) -- 792
			local status -- 793
			local jobId = 0 -- 794
			local settled = false -- 795
			local canceled = false -- 796
			local function finish(result) -- 797
				if settled then -- 797
					return -- 798
				end -- 798
				settled = true -- 799
				resolve(nil, result) -- 800
			end -- 797
			local function finishFromStatus() -- 802
				local state = toStr(status and status.state) -- 803
				if state == "done" then -- 803
					finish({success = true, status = status}) -- 805
					return true -- 806
				end -- 806
				if state == "error" or state == "canceled" then -- 806
					local errorMessage = toStr(status and status.error) -- 809
					local statusMessage = toStr(status and status.message) -- 810
					finish({success = false, message = errorMessage ~= "" and errorMessage or (statusMessage ~= "" and statusMessage or (state == "canceled" and "git command canceled" or "git command failed")), status = status, interrupted = state == "canceled"}) -- 811
					return true -- 817
				end -- 817
				return false -- 819
			end -- 802
			jobId = Git:run( -- 821
				repoPath, -- 821
				command, -- 821
				function(nextStatus) -- 821
					status = nextStatus -- 822
					if onStatus then -- 822
						onStatus(status) -- 823
					end -- 823
					return finishFromStatus() -- 824
				end, -- 821
				"" -- 825
			) -- 825
			if jobId == nil or jobId <= 0 then -- 825
				finish({success = false, message = "failed to start git command"}) -- 827
				return -- 828
			end -- 828
			if not status then -- 828
				local kind = string.match(command, "^(%S+)") -- 831
				status = { -- 832
					id = jobId, -- 833
					state = "queued", -- 834
					kind = toStr(kind), -- 835
					repoPath = repoPath, -- 836
					progress = 0, -- 837
					message = "queued" -- 838
				} -- 838
			end -- 838
			if onStatus then -- 838
				onStatus(status) -- 841
			end -- 841
			local startedAt = os.time() -- 842
			local lastEmitAt = startedAt -- 843
			Director.systemScheduler:schedule(function() -- 844
				if settled then -- 844
					return true -- 845
				end -- 845
				if not canceled and isCancelled and isCancelled() then -- 845
					canceled = true -- 847
					Git:cancel(jobId) -- 848
					finish({success = false, message = "git command canceled", status = status, interrupted = true}) -- 849
					return true -- 850
				end -- 850
				if finishFromStatus() then -- 850
					return true -- 852
				end -- 852
				local nowTime = os.time() -- 853
				if nowTime - startedAt >= timeout then -- 853
					Git:cancel(jobId) -- 855
					finish({success = false, message = "git command timed out", status = status}) -- 856
					return true -- 857
				end -- 857
				if onStatus and status and nowTime > lastEmitAt then -- 857
					lastEmitAt = nowTime -- 860
					onStatus(status) -- 861
				end -- 861
				return false -- 863
			end) -- 844
		end -- 792
	) -- 792
end -- 785
local function downloadFile(req) -- 868
	return __TS__New( -- 875
		__TS__Promise, -- 875
		function(____, resolve) -- 875
			local requestId = 0 -- 876
			local settled = false -- 877
			local bytesWritten = 0 -- 878
			local function finish(result) -- 879
				if settled then -- 879
					return -- 880
				end -- 880
				settled = true -- 881
				requestId = 0 -- 882
				resolve(nil, result) -- 883
			end -- 879
			Director.systemScheduler:schedule(function() -- 885
				if settled then -- 885
					return true -- 886
				end -- 886
				local ____this_9 -- 886
				____this_9 = req -- 887
				local ____opt_8 = ____this_9.isCancelled -- 887
				if (____opt_8 and ____opt_8(____this_9)) == true and requestId ~= 0 then -- 887
					HttpClient:cancel(requestId) -- 888
					finish({success = false, interrupted = true, message = "download canceled"}) -- 889
					return true -- 890
				end -- 890
				if requestId ~= 0 and not HttpClient:isRequestActive(requestId) then -- 890
					finish({success = false, message = "download request ended without a completion callback"}) -- 893
					return true -- 894
				end -- 894
				return false -- 896
			end) -- 885
			Director.systemScheduler:schedule(once(function() -- 898
				requestId = HttpClient:download( -- 899
					req.url, -- 899
					req.tempPath, -- 899
					req.timeout, -- 899
					function(interrupted, current, total) -- 899
						if type(current) == "number" and current > bytesWritten then -- 899
							bytesWritten = current -- 901
						end -- 901
						if interrupted then -- 901
							finish({success = false, interrupted = true, message = "download failed"}) -- 904
							return true -- 905
						end -- 905
						local ____this_11 -- 905
						____this_11 = req -- 907
						local ____opt_10 = ____this_11.isCancelled -- 907
						if (____opt_10 and ____opt_10(____this_11)) == true then -- 907
							finish({success = false, interrupted = true, message = "download canceled"}) -- 908
							return true -- 909
						end -- 909
						if current == total then -- 909
							finish({success = true, bytesWritten = bytesWritten}) -- 912
							return false -- 913
						end -- 913
						req:onProgress(current, total) -- 915
						return false -- 916
					end -- 899
				) -- 899
				if requestId == 0 then -- 899
					finish({success = false, message = "failed to schedule download request"}) -- 919
				else -- 919
					local ____this_13 -- 919
					____this_13 = req -- 920
					local ____opt_12 = ____this_13.isCancelled -- 920
					if (____opt_12 and ____opt_12(____this_13)) == true then -- 920
						HttpClient:cancel(requestId) -- 921
						finish({success = false, interrupted = true, message = "download canceled"}) -- 922
					end -- 922
				end -- 922
			end)) -- 898
		end -- 875
	) -- 875
end -- 868
local function getFileState(path) -- 928
	local exists = Content:exist(path) -- 929
	if not exists then -- 929
		return {exists = false, content = "", bytes = 0} -- 931
	end -- 931
	if Content:isdir(path) then -- 931
		return {exists = true, content = "", bytes = 0, isDirectory = true} -- 938
	end -- 938
	local content = Content:load(path) -- 945
	if type(content) ~= "string" then -- 945
		return {exists = true, content = "", bytes = 0} -- 947
	end -- 947
	return {exists = true, content = content, bytes = #content} -- 953
end -- 928
local function inspectReadableFile(path) -- 960
	do -- 960
		local function ____catch(e) -- 960
			Log( -- 982
				"Warn", -- 982
				(("[Agent.Tools] Content.getAttr failed for " .. path) .. ": ") .. tostring(e) -- 982
			) -- 982
			return true, {success = true} -- 983
		end -- 983
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 983
			local size, isBinary = Content:getAttr(path) -- 962
			if size == nil then -- 962
				return true, {success = false, message = "failed to read file"} -- 964
			end -- 964
			if isBinary then -- 964
				return true, { -- 970
					success = false, -- 971
					message = "file is binary and cannot be previewed by read_file" .. (type(size) == "number" and (" (" .. tostring(size)) .. " bytes)" or ""), -- 972
					size = type(size) == "number" and size or nil, -- 973
					isBinary = true -- 974
				} -- 974
			end -- 974
			return true, { -- 977
				success = true, -- 978
				size = type(size) == "number" and size or nil -- 979
			} -- 979
		end) -- 979
		if not ____try then -- 979
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 979
		end -- 979
		if ____hasReturned then -- 979
			return ____returnValue -- 961
		end -- 961
	end -- 961
end -- 960
local function isEngineLogFilePath(path) -- 987
	return path == ENGINE_LOG_FILE -- 988
end -- 987
local function readEngineLogFile(path) -- 991
	if not isEngineLogFilePath(path) then -- 991
		return nil -- 992
	end -- 992
	local content = getEngineLogText() -- 993
	if content == nil then -- 993
		return {success = false, message = "failed to read engine logs"} -- 995
	end -- 995
	return {success = true, content = content, size = #content} -- 997
end -- 991
local function queryOne(sql, args) -- 1000
	local ____args_14 -- 1001
	if args then -- 1001
		____args_14 = DB:query(sql, args) -- 1001
	else -- 1001
		____args_14 = DB:query(sql) -- 1001
	end -- 1001
	local rows = ____args_14 -- 1001
	if not rows or #rows == 0 then -- 1001
		return nil -- 1002
	end -- 1002
	return rows[1] -- 1003
end -- 1000
do -- 1000
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_TASK) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tstatus TEXT NOT NULL,\n\t\tprompt TEXT NOT NULL DEFAULT '',\n\t\thead_seq INTEGER NOT NULL DEFAULT 0,\n\t\twork_mode TEXT NOT NULL DEFAULT 'code',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 1008
	local taskColumns = DB:query(("PRAGMA table_info(" .. TABLE_TASK) .. ")") or ({}) -- 1017
	local hasTaskWorkMode = false -- 1018
	do -- 1018
		local i = 0 -- 1019
		while i < #taskColumns do -- 1019
			if tostring(taskColumns[i + 1][2]) == "work_mode" then -- 1019
				hasTaskWorkMode = true -- 1021
				break -- 1022
			end -- 1022
			i = i + 1 -- 1019
		end -- 1019
	end -- 1019
	if not hasTaskWorkMode then -- 1019
		DB:exec(("ALTER TABLE " .. TABLE_TASK) .. " ADD COLUMN work_mode TEXT NOT NULL DEFAULT 'code';") -- 1026
	end -- 1026
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_CP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\ttask_id INTEGER NOT NULL,\n\t\tseq INTEGER NOT NULL,\n\t\tstatus TEXT NOT NULL,\n\t\tsummary TEXT NOT NULL DEFAULT '',\n\t\ttool_name TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tapplied_at INTEGER,\n\t\treverted_at INTEGER\n\t);") -- 1028
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_cp_task_seq ON " .. TABLE_CP) .. "(task_id, seq);") -- 1039
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_ENTRY) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tcheckpoint_id INTEGER NOT NULL,\n\t\tord INTEGER NOT NULL,\n\t\tpath TEXT NOT NULL,\n\t\top TEXT NOT NULL,\n\t\tbefore_exists INTEGER NOT NULL,\n\t\tbefore_content TEXT,\n\t\tafter_exists INTEGER NOT NULL,\n\t\tafter_content TEXT,\n\t\tbytes_before INTEGER NOT NULL DEFAULT 0,\n\t\tbytes_after INTEGER NOT NULL DEFAULT 0\n\t);") -- 1040
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_entry_cp_ord ON " .. TABLE_ENTRY) .. "(checkpoint_id, ord);") -- 1053
end -- 1053
local function isDtsFile(path) -- 1056
	return Path:getExt(Path:getName(path)) == "d" -- 1057
end -- 1056
local function isTiledEditorContent(content) -- 1060
	return __TS__StringStartsWith( -- 1061
		__TS__StringTrim(content), -- 1061
		"<?xml" -- 1061
	) -- 1061
end -- 1060
local function getSupportedBuildKind(path) -- 1066
	repeat -- 1066
		local ____switch195 = Path:getExt(path) -- 1066
		local ____cond195 = ____switch195 == "ts" or ____switch195 == "tsx" -- 1066
		if ____cond195 then -- 1066
			return "ts" -- 1068
		end -- 1068
		____cond195 = ____cond195 or ____switch195 == "xml" -- 1068
		if ____cond195 then -- 1068
			return "xml" -- 1069
		end -- 1069
		____cond195 = ____cond195 or ____switch195 == "tl" -- 1069
		if ____cond195 then -- 1069
			return "teal" -- 1070
		end -- 1070
		____cond195 = ____cond195 or ____switch195 == "lua" -- 1070
		if ____cond195 then -- 1070
			return "lua" -- 1071
		end -- 1071
		____cond195 = ____cond195 or ____switch195 == "yue" -- 1071
		if ____cond195 then -- 1071
			return "yue" -- 1072
		end -- 1072
		____cond195 = ____cond195 or ____switch195 == "yarn" -- 1072
		if ____cond195 then -- 1072
			return "yarn" -- 1073
		end -- 1073
		do -- 1073
			return nil -- 1074
		end -- 1074
	until true -- 1074
end -- 1066
local function getTaskHeadSeq(taskId) -- 1078
	local row = queryOne(("SELECT head_seq FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1079
	if not row then -- 1079
		return nil -- 1080
	end -- 1080
	return row[1] or 0 -- 1081
end -- 1078
local function getTaskStatus(taskId) -- 1084
	local row = queryOne(("SELECT status FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1085
	if not row then -- 1085
		return nil -- 1086
	end -- 1086
	return toStr(row[1]) -- 1087
end -- 1084
local function getLastInsertRowId() -- 1090
	local row = queryOne("SELECT last_insert_rowid()") -- 1091
	return row and (row[1] or 0) or 0 -- 1092
end -- 1090
local function insertCheckpoint(taskId, seq, summary, toolName, status) -- 1095
	DB:exec( -- 1096
		("INSERT INTO " .. TABLE_CP) .. "(task_id, seq, status, summary, tool_name, created_at) VALUES(?, ?, ?, ?, ?, ?)", -- 1096
		{ -- 1098
			taskId, -- 1098
			seq, -- 1098
			status, -- 1098
			summary, -- 1098
			toolName, -- 1098
			now() -- 1098
		} -- 1098
	) -- 1098
	return getLastInsertRowId() -- 1100
end -- 1095
local function getCheckpointEntries(checkpointId, desc) -- 1103
	if desc == nil then -- 1103
		desc = false -- 1103
	end -- 1103
	local rows = DB:query((("SELECT id, ord, path, op, before_exists, before_content, after_exists, after_content\n\t\tFROM " .. TABLE_ENTRY) .. "\n\t\tWHERE checkpoint_id = ?\n\t\tORDER BY ord ") .. (desc and "DESC" or "ASC"), {checkpointId}) -- 1104
	if not rows then -- 1104
		return {} -- 1111
	end -- 1111
	local result = {} -- 1112
	do -- 1112
		local i = 0 -- 1113
		while i < #rows do -- 1113
			local row = rows[i + 1] -- 1114
			result[#result + 1] = { -- 1115
				id = row[1], -- 1116
				ord = row[2], -- 1117
				path = toStr(row[3]), -- 1118
				op = toStr(row[4]), -- 1119
				beforeExists = toBool(row[5]), -- 1120
				beforeContent = toStr(row[6]), -- 1121
				afterExists = toBool(row[7]), -- 1122
				afterContent = toStr(row[8]) -- 1123
			} -- 1123
			i = i + 1 -- 1113
		end -- 1113
	end -- 1113
	return result -- 1126
end -- 1103
local function rejectDuplicatePaths(changes) -- 1129
	local seen = __TS__New(Set) -- 1130
	for ____, change in ipairs(changes) do -- 1131
		local key = change.path -- 1132
		if seen:has(key) then -- 1132
			return key -- 1133
		end -- 1133
		seen:add(key) -- 1134
	end -- 1134
	return nil -- 1136
end -- 1129
local function getLinkedDeletePaths(workDir, path) -- 1139
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1140
	if not fullPath or not Content:exist(fullPath) or Content:isdir(fullPath) then -- 1140
		return {} -- 1141
	end -- 1141
	local parent = Path:getPath(fullPath) -- 1142
	local baseName = string.lower(Path:getName(fullPath)) -- 1143
	local ext = Path:getExt(fullPath) -- 1144
	local linked = {} -- 1145
	for ____, file in ipairs(Content:getFiles(parent)) do -- 1146
		do -- 1146
			if string.lower(Path:getName(file)) ~= baseName then -- 1146
				goto __continue212 -- 1147
			end -- 1147
			local siblingExt = Path:getExt(file) -- 1148
			if siblingExt == "tl" and ext == "vs" then -- 1148
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1150
					workDir, -- 1150
					Path(parent, file) -- 1150
				) -- 1150
				goto __continue212 -- 1151
			end -- 1151
			if siblingExt == "lua" and (ext == "tl" or ext == "yue" or ext == "ts" or ext == "tsx" or ext == "vs" or ext == "bl" or ext == "xml") then -- 1151
				linked[#linked + 1] = toWorkspaceRelativePath( -- 1154
					workDir, -- 1154
					Path(parent, file) -- 1154
				) -- 1154
			end -- 1154
		end -- 1154
		::__continue212:: -- 1154
	end -- 1154
	return linked -- 1157
end -- 1139
local function expandLinkedDeleteChanges(workDir, changes) -- 1160
	local expanded = {} -- 1161
	local seen = __TS__New(Set) -- 1162
	do -- 1162
		local i = 0 -- 1163
		while i < #changes do -- 1163
			do -- 1163
				local change = changes[i + 1] -- 1164
				if not seen:has(change.path) then -- 1164
					seen:add(change.path) -- 1166
					expanded[#expanded + 1] = change -- 1167
				end -- 1167
				if change.op ~= "delete" then -- 1167
					goto __continue219 -- 1169
				end -- 1169
				local linkedPaths = getLinkedDeletePaths(workDir, change.path) -- 1170
				do -- 1170
					local j = 0 -- 1171
					while j < #linkedPaths do -- 1171
						do -- 1171
							local linkedPath = linkedPaths[j + 1] -- 1172
							if seen:has(linkedPath) then -- 1172
								goto __continue223 -- 1173
							end -- 1173
							seen:add(linkedPath) -- 1174
							expanded[#expanded + 1] = {path = linkedPath, op = "delete"} -- 1175
						end -- 1175
						::__continue223:: -- 1175
						j = j + 1 -- 1171
					end -- 1171
				end -- 1171
			end -- 1171
			::__continue219:: -- 1171
			i = i + 1 -- 1163
		end -- 1163
	end -- 1163
	return expanded -- 1178
end -- 1160
local function applySingleFile(path, exists, content) -- 1181
	if exists then -- 1181
		if not ensureDirForFile(path) then -- 1181
			return false -- 1183
		end -- 1183
		return Content:save(path, content) -- 1184
	end -- 1184
	if Content:exist(path) then -- 1184
		return Content:remove(path) -- 1187
	end -- 1187
	return true -- 1189
end -- 1181
local function rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 1192
	local entries = getCheckpointEntries(checkpointId, true) -- 1197
	local remaining = appliedCount -- 1198
	local failures = {} -- 1199
	do -- 1199
		local i = 0 -- 1200
		while i < #entries and remaining > 0 do -- 1200
			do -- 1200
				local entry = entries[i + 1] -- 1201
				if entry.ord > appliedCount then -- 1201
					goto __continue231 -- 1202
				end -- 1202
				local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 1203
				if not fullPath or not applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) then -- 1203
					failures[#failures + 1] = entry.path -- 1205
				else -- 1205
					____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) -- 1207
				end -- 1207
				remaining = remaining - 1 -- 1209
			end -- 1209
			::__continue231:: -- 1209
			i = i + 1 -- 1200
		end -- 1200
	end -- 1200
	return #failures > 0 and "rollback failed for: " .. table.concat(failures, ", ") or nil -- 1211
end -- 1192
function ____exports.sendWebIDERefreshTree() -- 1231
	if HttpServer.wsConnectionCount == 0 then -- 1231
		return true -- 1233
	end -- 1233
	local payload = encodeJSON({name = "RefreshTree"}) -- 1235
	if not payload then -- 1235
		return false -- 1237
	end -- 1237
	emit("AppWS", "Send", payload) -- 1239
	return true -- 1240
end -- 1231
local function syncProjectFileToWebIDE(workDir, path) -- 1243
	local target = resolveWorkspaceFilePath(workDir, path) -- 1244
	if not target then -- 1244
		return false -- 1245
	end -- 1245
	if not Content:exist(target) then -- 1245
		return ____exports.sendWebIDEFileUpdate(target, false, "") -- 1247
	end -- 1247
	if Content:isdir(target) then -- 1247
		return ____exports.sendWebIDERefreshTree() -- 1250
	end -- 1250
	local content = "" -- 1252
	do -- 1252
		local function ____catch(e) -- 1252
			Log( -- 1260
				"Warn", -- 1260
				(("[Agent.Tools] failed to inspect file for Web IDE update file=" .. target) .. ": ") .. tostring(e) -- 1260
			) -- 1260
		end -- 1260
		local ____try, ____hasReturned = pcall(function() -- 1260
			local ____, isBinary = Content:getAttr(target) -- 1254
			if not isBinary then -- 1254
				local loaded = Content:load(target) -- 1256
				content = type(loaded) == "string" and loaded or "" -- 1257
			end -- 1257
		end) -- 1257
		if not ____try then -- 1257
			____catch(____hasReturned) -- 1257
		end -- 1257
	end -- 1257
	return ____exports.sendWebIDEFileUpdate(target, true, content) -- 1262
end -- 1243
local function refreshProjectTree(workDir, path) -- 1265
	local normalized = type(path) == "string" and __TS__StringTrim(path) or "" -- 1266
	if normalized == "" then -- 1266
		return ____exports.sendWebIDERefreshTree() -- 1268
	end -- 1268
	return syncProjectFileToWebIDE(workDir, normalized) -- 1270
end -- 1265
local function syncDownloadedFileToWebIDE(file) -- 1273
	local content = "" -- 1274
	do -- 1274
		local function ____catch(e) -- 1274
			Log( -- 1282
				"Warn", -- 1282
				(("[fetch_url] failed to inspect downloaded file for Web IDE update file=" .. file) .. ": ") .. tostring(e) -- 1282
			) -- 1282
		end -- 1282
		local ____try, ____hasReturned = pcall(function() -- 1282
			local ____, isBinary = Content:getAttr(file) -- 1276
			if not isBinary then -- 1276
				local loaded = Content:load(file) -- 1278
				content = type(loaded) == "string" and loaded or "" -- 1279
			end -- 1279
		end) -- 1279
		if not ____try then -- 1279
			____catch(____hasReturned) -- 1279
		end -- 1279
	end -- 1279
	return ____exports.sendWebIDEFileUpdate(file, true, content) -- 1284
end -- 1273
local function runSingleNonTsBuild(file) -- 1287
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1287
		return ____awaiter_resolve( -- 1287
			nil, -- 1287
			__TS__New( -- 1288
				__TS__Promise, -- 1288
				function(____, resolve) -- 1288
					local moduleName = "Script.Dev.WebServer" -- 1289
					local ____require_result_15 = require(moduleName) -- 1290
					local buildAsync = ____require_result_15.buildAsync -- 1290
					Director.systemScheduler:schedule(once(function() -- 1291
						local result = buildAsync(file) -- 1292
						resolve(nil, result) -- 1293
					end)) -- 1291
				end -- 1288
			) -- 1288
		) -- 1288
	end) -- 1288
end -- 1287
local transpileRequestSeq = 0 -- 1298
function ____exports.runSingleTsTranspile(file, content, projectRoot) -- 1300
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1300
		local done = false -- 1301
		transpileRequestSeq = transpileRequestSeq + 1 -- 1302
		local requestId = "agent-build-" .. tostring(transpileRequestSeq) -- 1303
		local result = {success = false, file = file, message = "transpile timeout or Web IDE not connected"} -- 1304
		if HttpServer.wsConnectionCount == 0 then -- 1304
			return ____awaiter_resolve(nil, result) -- 1304
		end -- 1304
		local listener = Node() -- 1312
		listener:gslot( -- 1313
			"AppWS", -- 1313
			function(event) -- 1313
				if event.type ~= "Receive" then -- 1313
					return -- 1314
				end -- 1314
				local res = safeJsonDecode(event.msg) -- 1315
				if not res or __TS__ArrayIsArray(res) then -- 1315
					return -- 1316
				end -- 1316
				local payload = res -- 1317
				if payload.name ~= "TranspileTS" then -- 1317
					return -- 1318
				end -- 1318
				if payload.id ~= requestId then -- 1318
					return -- 1319
				end -- 1319
				if payload.success then -- 1319
					local luaFile = Path:replaceExt(file, "lua") -- 1321
					if Content:save( -- 1321
						luaFile, -- 1322
						tostring(payload.luaCode) -- 1322
					) then -- 1322
						result = {success = true, file = file} -- 1323
					else -- 1323
						result = {success = false, file = file, message = "failed to save " .. luaFile} -- 1325
					end -- 1325
				else -- 1325
					result = { -- 1328
						success = false, -- 1328
						file = file, -- 1328
						message = tostring(payload.message) -- 1328
					} -- 1328
				end -- 1328
				done = true -- 1330
			end -- 1313
		) -- 1313
		local payload = encodeJSON({ -- 1332
			name = "TranspileTS", -- 1333
			id = requestId, -- 1334
			file = file, -- 1335
			content = content, -- 1336
			projectRoot = projectRoot -- 1337
		}) -- 1337
		if not payload then -- 1337
			listener:removeFromParent() -- 1340
			return ____awaiter_resolve(nil, {success = false, file = file, message = "failed to encode transpile request"}) -- 1340
		end -- 1340
		__TS__Await(__TS__New( -- 1343
			__TS__Promise, -- 1343
			function(____, resolve) -- 1343
				Director.systemScheduler:schedule(once(function() -- 1344
					emit("AppWS", "Send", payload) -- 1345
					wait(function() return done end) -- 1346
					if not done then -- 1346
						listener:removeFromParent() -- 1348
					end -- 1348
					resolve(nil) -- 1350
				end)) -- 1344
			end -- 1343
		)) -- 1343
		return ____awaiter_resolve(nil, result) -- 1343
	end) -- 1343
end -- 1300
function ____exports.createTask(prompt, workMode) -- 1356
	if prompt == nil then -- 1356
		prompt = "" -- 1356
	end -- 1356
	if workMode == nil then -- 1356
		workMode = "code" -- 1356
	end -- 1356
	local t = now() -- 1357
	local affected = DB:exec(("INSERT INTO " .. TABLE_TASK) .. "(status, prompt, head_seq, work_mode, created_at, updated_at) VALUES(?, ?, 0, ?, ?, ?)", { -- 1358
		"RUNNING", -- 1360
		prompt, -- 1360
		workMode, -- 1360
		t, -- 1360
		t -- 1360
	}) -- 1360
	if affected <= 0 then -- 1360
		return {success = false, message = "failed to create task"} -- 1363
	end -- 1363
	return { -- 1365
		success = true, -- 1365
		taskId = getLastInsertRowId() -- 1365
	} -- 1365
end -- 1356
function ____exports.setTaskStatus(taskId, status) -- 1368
	DB:exec( -- 1369
		("UPDATE " .. TABLE_TASK) .. " SET status = ?, updated_at = ? WHERE id = ?", -- 1369
		{ -- 1369
			status, -- 1369
			now(), -- 1369
			taskId -- 1369
		} -- 1369
	) -- 1369
	Log( -- 1370
		"Info", -- 1370
		(("[task:" .. tostring(taskId)) .. "] status=") .. status -- 1370
	) -- 1370
end -- 1368
function ____exports.listCheckpoints(taskId) -- 1373
	local rows = DB:query(("SELECT id, task_id, seq, status, summary, tool_name, created_at\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ?\n\t\tORDER BY seq DESC", {taskId}) -- 1374
	if not rows then -- 1374
		return {} -- 1381
	end -- 1381
	local items = {} -- 1382
	do -- 1382
		local i = 0 -- 1383
		while i < #rows do -- 1383
			local row = rows[i + 1] -- 1384
			items[#items + 1] = { -- 1385
				id = row[1], -- 1386
				taskId = row[2], -- 1387
				seq = row[3], -- 1388
				status = toStr(row[4]), -- 1389
				summary = toStr(row[5]), -- 1390
				toolName = toStr(row[6]), -- 1391
				createdAt = row[7] -- 1392
			} -- 1392
			i = i + 1 -- 1383
		end -- 1383
	end -- 1383
	return items -- 1395
end -- 1373
local function listCheckpointIdsForTask(taskId, desc) -- 1398
	if desc == nil then -- 1398
		desc = false -- 1398
	end -- 1398
	local rows = DB:query((("SELECT id, seq\n\t\tFROM " .. TABLE_CP) .. "\n\t\tWHERE task_id = ? AND status IN ('APPLIED', 'REVERTED')\n\t\tORDER BY seq ") .. (desc and "DESC" or "ASC"), {taskId}) -- 1399
	if not rows then -- 1399
		return {} -- 1406
	end -- 1406
	local items = {} -- 1407
	do -- 1407
		local i = 0 -- 1408
		while i < #rows do -- 1408
			local row = rows[i + 1] -- 1409
			items[#items + 1] = {id = row[1], seq = row[2]} -- 1410
			i = i + 1 -- 1408
		end -- 1408
	end -- 1408
	return items -- 1415
end -- 1398
local function deriveFileOp(beforeExists, afterExists) -- 1418
	if not beforeExists and afterExists then -- 1418
		return "create" -- 1419
	end -- 1419
	if beforeExists and not afterExists then -- 1419
		return "delete" -- 1420
	end -- 1420
	return "write" -- 1421
end -- 1418
function ____exports.summarizeTaskChangeSet(taskId) -- 1424
	if not getTaskStatus(taskId) then -- 1424
		return {success = false, message = "task not found"} -- 1426
	end -- 1426
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1428
	local filesByPath = {} -- 1429
	local latestCheckpointId = nil -- 1435
	local latestCheckpointSeq = nil -- 1436
	do -- 1436
		local i = 0 -- 1437
		while i < #checkpoints do -- 1437
			local checkpoint = checkpoints[i + 1] -- 1438
			latestCheckpointId = checkpoint.id -- 1439
			latestCheckpointSeq = checkpoint.seq -- 1440
			local entries = getCheckpointEntries(checkpoint.id, false) -- 1441
			do -- 1441
				local j = 0 -- 1442
				while j < #entries do -- 1442
					local entry = entries[j + 1] -- 1443
					local item = filesByPath[entry.path] -- 1444
					if not item then -- 1444
						item = {path = entry.path, beforeExists = entry.beforeExists, afterExists = entry.afterExists, checkpointIds = {}} -- 1446
						filesByPath[entry.path] = item -- 1452
					end -- 1452
					item.afterExists = entry.afterExists -- 1454
					local ____item_checkpointIds_16 = item.checkpointIds -- 1454
					____item_checkpointIds_16[#____item_checkpointIds_16 + 1] = checkpoint.id -- 1455
					j = j + 1 -- 1442
				end -- 1442
			end -- 1442
			i = i + 1 -- 1437
		end -- 1437
	end -- 1437
	local files = {} -- 1458
	for ____, item in pairs(filesByPath) do -- 1459
		files[#files + 1] = { -- 1460
			path = item.path, -- 1461
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1462
			checkpointCount = #item.checkpointIds, -- 1463
			checkpointIds = item.checkpointIds -- 1464
		} -- 1464
	end -- 1464
	__TS__ArraySort( -- 1467
		files, -- 1467
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1467
	) -- 1467
	return { -- 1468
		success = true, -- 1469
		taskId = taskId, -- 1470
		checkpointCount = #checkpoints, -- 1471
		filesChanged = #files, -- 1472
		files = files, -- 1473
		latestCheckpointId = latestCheckpointId, -- 1474
		latestCheckpointSeq = latestCheckpointSeq -- 1475
	} -- 1475
end -- 1424
function ____exports.getTaskChangeSetDiff(taskId) -- 1479
	if not getTaskStatus(taskId) then -- 1479
		return {success = false, message = "task not found"} -- 1481
	end -- 1481
	local checkpoints = listCheckpointIdsForTask(taskId, false) -- 1483
	if #checkpoints == 0 then -- 1483
		return {success = false, message = "change set not found or empty"} -- 1485
	end -- 1485
	local filesByPath = {} -- 1487
	do -- 1487
		local i = 0 -- 1494
		while i < #checkpoints do -- 1494
			local entries = getCheckpointEntries(checkpoints[i + 1].id, false) -- 1495
			do -- 1495
				local j = 0 -- 1496
				while j < #entries do -- 1496
					local entry = entries[j + 1] -- 1497
					local item = filesByPath[entry.path] -- 1498
					if not item then -- 1498
						item = { -- 1500
							path = entry.path, -- 1501
							beforeExists = entry.beforeExists, -- 1502
							beforeContent = entry.beforeContent, -- 1503
							afterExists = entry.afterExists, -- 1504
							afterContent = entry.afterContent -- 1505
						} -- 1505
						filesByPath[entry.path] = item -- 1507
					end -- 1507
					item.afterExists = entry.afterExists -- 1509
					item.afterContent = entry.afterContent -- 1510
					j = j + 1 -- 1496
				end -- 1496
			end -- 1496
			i = i + 1 -- 1494
		end -- 1494
	end -- 1494
	local files = {} -- 1513
	for ____, item in pairs(filesByPath) do -- 1514
		files[#files + 1] = { -- 1515
			path = item.path, -- 1516
			op = deriveFileOp(item.beforeExists, item.afterExists), -- 1517
			beforeExists = item.beforeExists, -- 1518
			afterExists = item.afterExists, -- 1519
			beforeContent = item.beforeContent, -- 1520
			afterContent = item.afterContent -- 1521
		} -- 1521
	end -- 1521
	__TS__ArraySort( -- 1524
		files, -- 1524
		function(____, a, b) return a.path < b.path and -1 or (a.path > b.path and 1 or 0) end -- 1524
	) -- 1524
	return {success = true, files = files} -- 1525
end -- 1479
local function readWorkspaceFile(workDir, path, docLanguage) -- 1528
	local engineLog = readEngineLogFile(path) -- 1529
	if engineLog then -- 1529
		return engineLog -- 1530
	end -- 1530
	local fullPath = resolveWorkspaceFilePath(workDir, path) -- 1531
	if fullPath and Content:exist(fullPath) and not Content:isdir(fullPath) then -- 1531
		local attr = inspectReadableFile(fullPath) -- 1533
		if not attr.success then -- 1533
			return attr -- 1534
		end -- 1534
		return { -- 1535
			success = true, -- 1535
			content = Content:load(fullPath), -- 1535
			size = attr.size -- 1535
		} -- 1535
	end -- 1535
	local docPath = resolveAgentDoraDocFilePath(path, docLanguage) -- 1537
	if docPath then -- 1537
		local attr = inspectReadableFile(docPath) -- 1539
		if not attr.success then -- 1539
			return attr -- 1540
		end -- 1540
		return { -- 1541
			success = true, -- 1541
			content = Content:load(docPath), -- 1541
			size = attr.size -- 1541
		} -- 1541
	end -- 1541
	if not fullPath then -- 1541
		return {success = false, message = "invalid path or workDir"} -- 1543
	end -- 1543
	return {success = false, message = "file not found"} -- 1544
end -- 1528
function ____exports.readFileRaw(workDir, path, docLanguage) -- 1547
	local result = readWorkspaceFile(workDir, path, docLanguage) -- 1548
	if not result.success and Content:exist(path) and not Content:isdir(path) then -- 1548
		local attr = inspectReadableFile(path) -- 1550
		if not attr.success then -- 1550
			return attr -- 1551
		end -- 1551
		return { -- 1552
			success = true, -- 1552
			content = Content:load(path), -- 1552
			size = attr.size -- 1552
		} -- 1552
	end -- 1552
	return result -- 1554
end -- 1547
function ____exports.getLogs(req) -- 1569
	local text = getEngineLogText() -- 1570
	if text == nil then -- 1570
		return {success = false, message = "failed to read engine logs"} -- 1572
	end -- 1572
	local tailLines = math.max( -- 1574
		1, -- 1574
		math.floor(req and req.tailLines or 200) -- 1574
	) -- 1574
	local allLines = __TS__StringSplit(text, "\n") -- 1575
	local logs = __TS__ArraySlice( -- 1576
		allLines, -- 1576
		math.max(0, #allLines - tailLines) -- 1576
	) -- 1576
	return req and req.joinText and ({ -- 1577
		success = true, -- 1577
		logs = logs, -- 1577
		text = table.concat(logs, "\n") -- 1577
	}) or ({success = true, logs = logs}) -- 1577
end -- 1569
function ____exports.listFiles(req) -- 1580
	local root = req.path or "" -- 1586
	local searchRoot = resolveWorkspaceSearchPath(req.workDir, root) -- 1587
	if not searchRoot then -- 1587
		return {success = false, message = "invalid path or workDir"} -- 1589
	end -- 1589
	do -- 1589
		local function ____catch(e) -- 1589
			return true, { -- 1607
				success = false, -- 1607
				message = tostring(e) -- 1607
			} -- 1607
		end -- 1607
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 1607
			local userGlobs = req.globs and #req.globs > 0 and req.globs or ({"**"}) -- 1592
			local globs = ensureSafeSearchGlobs(userGlobs) -- 1593
			local files = Content:glob(searchRoot, globs, extensionLevels) -- 1594
			files = toWorkspaceRelativeFileList(req.workDir, files) -- 1595
			local totalEntries = #files -- 1596
			local maxEntries = math.max( -- 1597
				1, -- 1597
				math.floor(req.maxEntries or 200) -- 1597
			) -- 1597
			local truncated = totalEntries > maxEntries -- 1598
			return true, { -- 1599
				success = true, -- 1600
				files = truncated and __TS__ArraySlice(files, 0, maxEntries) or files, -- 1601
				totalEntries = totalEntries, -- 1602
				truncated = truncated, -- 1603
				maxEntries = maxEntries -- 1604
			} -- 1604
		end) -- 1604
		if not ____try then -- 1604
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 1604
		end -- 1604
		if ____hasReturned then -- 1604
			return ____returnValue -- 1591
		end -- 1591
	end -- 1591
end -- 1580
local function formatReadSlice(content, startLine, endLine) -- 1611
	local lines = __TS__StringSplit(content, "\n") -- 1616
	local totalLines = #lines -- 1617
	if totalLines == 0 then -- 1617
		return { -- 1619
			success = true, -- 1620
			content = "", -- 1621
			totalLines = 0, -- 1622
			startLine = 1, -- 1623
			endLine = 0, -- 1624
			truncated = false -- 1625
		} -- 1625
	end -- 1625
	local rawStart = math.floor(startLine) -- 1628
	local rawEnd = math.floor(endLine) -- 1629
	if rawStart == 0 then -- 1629
		return {success = false, message = "startLine cannot be 0"} -- 1631
	end -- 1631
	if rawEnd == 0 then -- 1631
		return {success = false, message = "endLine cannot be 0"} -- 1634
	end -- 1634
	local start = rawStart > 0 and rawStart or math.max(1, totalLines + rawStart + 1) -- 1636
	if start > totalLines then -- 1636
		return { -- 1640
			success = false, -- 1640
			message = (("startLine " .. tostring(start)) .. " exceeds file length ") .. tostring(totalLines) -- 1640
		} -- 1640
	end -- 1640
	local ____end = math.min( -- 1642
		totalLines, -- 1643
		rawEnd > 0 and rawEnd or math.max(1, totalLines + rawEnd + 1) -- 1644
	) -- 1644
	if ____end < start then -- 1644
		return { -- 1649
			success = false, -- 1650
			message = (("resolved endLine " .. tostring(____end)) .. " is before startLine ") .. tostring(start) -- 1651
		} -- 1651
	end -- 1651
	local slice = {} -- 1654
	do -- 1654
		local i = start -- 1655
		while i <= ____end do -- 1655
			slice[#slice + 1] = lines[i] -- 1656
			i = i + 1 -- 1655
		end -- 1655
	end -- 1655
	local truncated = start > 1 or ____end < totalLines -- 1658
	local hint = ____end < totalLines and ((((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ". Use startLine=") .. tostring(____end + 1)) .. " to continue.)" or (truncated and ((((("(Showing lines " .. tostring(start)) .. "-") .. tostring(____end)) .. " of ") .. tostring(totalLines)) .. ".)" or ("(End of file - " .. tostring(totalLines)) .. " lines total)") -- 1659
	local body = table.concat(slice, "\n") -- 1664
	local output = body == "" and hint or (body .. "\n\n") .. hint -- 1665
	return { -- 1666
		success = true, -- 1667
		content = output, -- 1668
		totalLines = totalLines, -- 1669
		startLine = start, -- 1670
		endLine = ____end, -- 1671
		truncated = truncated -- 1672
	} -- 1672
end -- 1611
function ____exports.readFile(workDir, path, startLine, endLine, docLanguage) -- 1676
	local fallback = ____exports.readFileRaw(workDir, path, docLanguage) -- 1683
	if not fallback.success or fallback.content == nil then -- 1683
		return fallback -- 1684
	end -- 1684
	local resolvedStartLine = startLine or 1 -- 1685
	local resolvedEndLine = endLine or (resolvedStartLine < 0 and -1 or 300) -- 1686
	return formatReadSlice(fallback.content, resolvedStartLine, resolvedEndLine) -- 1687
end -- 1676
local codeExtensions = { -- 1694
	".lua", -- 1694
	".tl", -- 1694
	".yue", -- 1694
	".ts", -- 1694
	".tsx", -- 1694
	".xml", -- 1694
	".md", -- 1694
	".yarn", -- 1694
	".wa", -- 1694
	".mod" -- 1694
} -- 1694
extensionLevels = { -- 1695
	vs = 2, -- 1696
	bl = 2, -- 1697
	ts = 1, -- 1698
	tsx = 1, -- 1699
	tl = 1, -- 1700
	yue = 1, -- 1701
	xml = 1, -- 1702
	lua = 0 -- 1703
} -- 1703
local function splitSearchPatterns(pattern) -- 1720
	local trimmed = __TS__StringTrim(pattern or "") -- 1721
	if trimmed == "" then -- 1721
		return {} -- 1722
	end -- 1722
	local out = {} -- 1723
	local seen = __TS__New(Set) -- 1724
	for p0 in string.gmatch(trimmed, "([^|]+)") do -- 1725
		local p = __TS__StringTrim(tostring(p0)) -- 1726
		if p ~= "" and not seen:has(p) then -- 1726
			seen:add(p) -- 1728
			out[#out + 1] = p -- 1729
		end -- 1729
	end -- 1729
	return out -- 1732
end -- 1720
local function splitWhitespaceSearchPatterns(pattern) -- 1735
	local out = {} -- 1736
	local seen = __TS__New(Set) -- 1737
	for p0 in string.gmatch(pattern, "(%S+)") do -- 1738
		local p = __TS__StringTrim(tostring(p0)) -- 1739
		local key = string.lower(p) -- 1740
		if p ~= "" and not seen:has(key) then -- 1740
			seen:add(key) -- 1742
			out[#out + 1] = p -- 1743
		end -- 1743
	end -- 1743
	return out -- 1746
end -- 1735
local function mergeSearchFileResultsUnique(resultsList) -- 1749
	local merged = {} -- 1750
	local seen = __TS__New(Set) -- 1751
	do -- 1751
		local i = 0 -- 1752
		while i < #resultsList do -- 1752
			local list = resultsList[i + 1] -- 1753
			do -- 1753
				local j = 0 -- 1754
				while j < #list do -- 1754
					do -- 1754
						local row = list[j + 1] -- 1755
						local key = (((((row.file .. ":") .. tostring(row.pos)) .. ":") .. tostring(row.line)) .. ":") .. tostring(row.column) -- 1756
						if seen:has(key) then -- 1756
							goto __continue353 -- 1757
						end -- 1757
						seen:add(key) -- 1758
						merged[#merged + 1] = list[j + 1] -- 1759
					end -- 1759
					::__continue353:: -- 1759
					j = j + 1 -- 1754
				end -- 1754
			end -- 1754
			i = i + 1 -- 1752
		end -- 1752
	end -- 1752
	return merged -- 1762
end -- 1749
local function buildGroupedSearchResults(results) -- 1765
	local order = {} -- 1770
	local grouped = __TS__New(Map) -- 1771
	do -- 1771
		local i = 0 -- 1776
		while i < #results do -- 1776
			local row = results[i + 1] -- 1777
			local file = row.file -- 1778
			local key = file ~= "" and file or ("(unknown:" .. tostring(i)) .. ")" -- 1779
			local bucket = grouped:get(key) -- 1780
			if not bucket then -- 1780
				bucket = {file = file ~= "" and file or "(unknown)", totalMatches = 0, matches = {}} -- 1782
				grouped:set(key, bucket) -- 1783
				order[#order + 1] = key -- 1784
			end -- 1784
			bucket.totalMatches = bucket.totalMatches + 1 -- 1786
			local ____bucket_matches_21 = bucket.matches -- 1786
			____bucket_matches_21[#____bucket_matches_21 + 1] = results[i + 1] -- 1787
			i = i + 1 -- 1776
		end -- 1776
	end -- 1776
	local out = {} -- 1789
	do -- 1789
		local i = 0 -- 1794
		while i < #order do -- 1794
			local bucket = grouped:get(order[i + 1]) -- 1795
			if bucket then -- 1795
				out[#out + 1] = bucket -- 1796
			end -- 1796
			i = i + 1 -- 1794
		end -- 1794
	end -- 1794
	return out -- 1798
end -- 1765
local function mergeDoraAPISearchHitsUnique(resultsList) -- 1801
	local merged = {} -- 1802
	local seen = __TS__New(Set) -- 1803
	local index = 0 -- 1804
	local advanced = true -- 1805
	while advanced do -- 1805
		advanced = false -- 1807
		do -- 1807
			local i = 0 -- 1808
			while i < #resultsList do -- 1808
				do -- 1808
					local list = resultsList[i + 1] -- 1809
					if index >= #list then -- 1809
						goto __continue365 -- 1810
					end -- 1810
					advanced = true -- 1811
					local row = list[index + 1] -- 1812
					local key = (((row.file .. ":") .. tostring(row.line or "")) .. ":") .. tostring(row.content or "") -- 1813
					if seen:has(key) then -- 1813
						goto __continue365 -- 1814
					end -- 1814
					seen:add(key) -- 1815
					merged[#merged + 1] = row -- 1816
				end -- 1816
				::__continue365:: -- 1816
				i = i + 1 -- 1808
			end -- 1808
		end -- 1808
		index = index + 1 -- 1818
	end -- 1818
	return merged -- 1820
end -- 1801
local function getDoraAPIFilePriority(file, docSource, programmingLanguage) -- 1823
	if docSource ~= "api" then -- 1823
		return 100 -- 1824
	end -- 1824
	if programmingLanguage ~= "tsx" then -- 1824
		return 100 -- 1825
	end -- 1825
	repeat -- 1825
		local ____switch371 = string.lower(Path:getFilename(file)) -- 1825
		local ____cond371 = ____switch371 == "jsx.d.ts" -- 1825
		if ____cond371 then -- 1825
			return 0 -- 1827
		end -- 1827
		____cond371 = ____cond371 or ____switch371 == "dorax.d.ts" -- 1827
		if ____cond371 then -- 1827
			return 1 -- 1828
		end -- 1828
		____cond371 = ____cond371 or ____switch371 == "dora.d.ts" -- 1828
		if ____cond371 then -- 1828
			return 2 -- 1829
		end -- 1829
		do -- 1829
			return 100 -- 1830
		end -- 1830
	until true -- 1830
end -- 1823
local function sortDoraAPISearchHits(hits, docSource, programmingLanguage) -- 1834
	local sorted = __TS__ArraySlice(hits) -- 1839
	__TS__ArraySort( -- 1840
		sorted, -- 1840
		function(____, a, b) -- 1840
			local pa = getDoraAPIFilePriority(a.file, docSource, programmingLanguage) -- 1841
			local pb = getDoraAPIFilePriority(b.file, docSource, programmingLanguage) -- 1842
			if pa ~= pb then -- 1842
				return pa - pb -- 1843
			end -- 1843
			local fa = string.lower(a.file) -- 1844
			local fb = string.lower(b.file) -- 1845
			if fa ~= fb then -- 1845
				return fa < fb and -1 or 1 -- 1846
			end -- 1846
			return (a.line or 0) - (b.line or 0) -- 1847
		end -- 1840
	) -- 1840
	return sorted -- 1849
end -- 1834
function ____exports.searchFiles(req) -- 1852
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1852
		local resolvedPath = resolveWorkspaceSearchPath(req.workDir, req.path) -- 1865
		if not resolvedPath then -- 1865
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1865
		end -- 1865
		local searchIsSingleFile = Content:exist(resolvedPath) and not Content:isdir(resolvedPath) -- 1869
		local searchRoot = searchIsSingleFile and Path:getPath(resolvedPath) or resolvedPath -- 1870
		if not searchRoot then -- 1870
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 1870
		end -- 1870
		if not req.pattern or __TS__StringTrim(req.pattern) == "" then -- 1870
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1870
		end -- 1870
		local patterns = splitSearchPatterns(req.pattern) -- 1877
		if #patterns == 0 then -- 1877
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1877
		end -- 1877
		return ____awaiter_resolve( -- 1877
			nil, -- 1877
			__TS__New( -- 1881
				__TS__Promise, -- 1881
				function(____, resolve) -- 1881
					Director.systemScheduler:schedule(once(function() -- 1882
						do -- 1882
							local function ____catch(e) -- 1882
								resolve( -- 1924
									nil, -- 1924
									{ -- 1924
										success = false, -- 1924
										message = tostring(e) -- 1924
									} -- 1924
								) -- 1924
							end -- 1924
							local ____try, ____hasReturned = pcall(function() -- 1924
								local searchGlobs = searchIsSingleFile and ({Path:getFilename(resolvedPath)}) or ensureSafeSearchGlobs(req.globs or ({"**"})) -- 1884
								local allResults = {} -- 1887
								do -- 1887
									local i = 0 -- 1888
									while i < #patterns do -- 1888
										local ____Content_26 = Content -- 1889
										local ____Content_searchFilesAsync_27 = Content.searchFilesAsync -- 1889
										local ____patterns_index_25 = patterns[i + 1] -- 1894
										local ____req_useRegex_22 = req.useRegex -- 1895
										if ____req_useRegex_22 == nil then -- 1895
											____req_useRegex_22 = false -- 1895
										end -- 1895
										local ____req_caseSensitive_23 = req.caseSensitive -- 1896
										if ____req_caseSensitive_23 == nil then -- 1896
											____req_caseSensitive_23 = false -- 1896
										end -- 1896
										local ____req_includeContent_24 = req.includeContent -- 1897
										if ____req_includeContent_24 == nil then -- 1897
											____req_includeContent_24 = true -- 1897
										end -- 1897
										allResults[#allResults + 1] = ____Content_searchFilesAsync_27( -- 1889
											____Content_26, -- 1889
											searchRoot, -- 1890
											codeExtensions, -- 1891
											extensionLevels, -- 1892
											searchGlobs, -- 1893
											____patterns_index_25, -- 1894
											____req_useRegex_22, -- 1895
											____req_caseSensitive_23, -- 1896
											____req_includeContent_24, -- 1897
											req.contentWindow or 120 -- 1898
										) -- 1898
										i = i + 1 -- 1888
									end -- 1888
								end -- 1888
								local results = mergeSearchFileResultsUnique(allResults) -- 1901
								local totalResults = #results -- 1902
								local limit = math.max( -- 1903
									1, -- 1903
									math.floor(req.limit or 20) -- 1903
								) -- 1903
								local offset = math.max( -- 1904
									0, -- 1904
									math.floor(req.offset or 0) -- 1904
								) -- 1904
								local paged = offset >= totalResults and ({}) or __TS__ArraySlice(results, offset, offset + limit) -- 1905
								local nextOffset = offset + #paged -- 1906
								local hasMore = nextOffset < totalResults -- 1907
								local truncated = offset > 0 or hasMore -- 1908
								local relativeResults = toWorkspaceRelativeSearchResults(req.workDir, paged) -- 1909
								local groupByFile = req.groupByFile == true -- 1910
								resolve( -- 1911
									nil, -- 1911
									{ -- 1911
										success = true, -- 1912
										results = relativeResults, -- 1913
										groupedResults = groupByFile and buildGroupedSearchResults(relativeResults) or nil, -- 1914
										totalResults = totalResults, -- 1915
										truncated = truncated, -- 1916
										limit = limit, -- 1917
										offset = offset, -- 1918
										nextOffset = nextOffset, -- 1919
										hasMore = hasMore, -- 1920
										groupByFile = groupByFile -- 1921
									} -- 1921
								) -- 1921
							end) -- 1921
							if not ____try then -- 1921
								____catch(____hasReturned) -- 1921
							end -- 1921
						end -- 1921
					end)) -- 1882
				end -- 1881
			) -- 1881
		) -- 1881
	end) -- 1881
end -- 1852
function ____exports.searchDoraAPI(req) -- 1930
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1930
		local pattern = __TS__StringTrim(req.pattern or "") -- 1941
		if pattern == "" then -- 1941
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1941
		end -- 1941
		local patterns = splitSearchPatterns(pattern) -- 1943
		if #patterns == 0 then -- 1943
			return ____awaiter_resolve(nil, {success = false, message = "empty pattern"}) -- 1943
		end -- 1943
		local docSource = req.docSource or "api" -- 1945
		local target = getDoraDocSearchTarget(docSource, req.docLanguage, req.programmingLanguage) -- 1946
		local docRoot = target.root -- 1947
		local resultBaseRoot = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 1948
		if not Content:exist(docRoot) or not Content:isdir(docRoot) then -- 1948
			return ____awaiter_resolve(nil, {success = false, message = "doc root not found: " .. docRoot}) -- 1948
		end -- 1948
		local exts = target.exts -- 1952
		local dotExts = __TS__ArrayMap( -- 1953
			exts, -- 1953
			function(____, ext) return __TS__StringStartsWith(ext, ".") and ext or "." .. ext end -- 1953
		) -- 1953
		local globs = target.globs -- 1954
		local limit = math.max( -- 1955
			1, -- 1955
			math.floor(req.limit or 10) -- 1955
		) -- 1955
		return ____awaiter_resolve( -- 1955
			nil, -- 1955
			__TS__New( -- 1957
				__TS__Promise, -- 1957
				function(____, resolve) -- 1957
					Director.systemScheduler:schedule(once(function() -- 1958
						do -- 1958
							local function ____catch(e) -- 1958
								resolve( -- 2038
									nil, -- 2038
									{ -- 2038
										success = false, -- 2038
										message = tostring(e) -- 2038
									} -- 2038
								) -- 2038
							end -- 2038
							local ____try, ____hasReturned = pcall(function() -- 2038
								local allHits = {} -- 1960
								do -- 1960
									local p = 0 -- 1961
									while p < #patterns do -- 1961
										local ____Content_32 = Content -- 1962
										local ____Content_searchFilesAsync_33 = Content.searchFilesAsync -- 1962
										local ____array_31 = __TS__SparseArrayNew( -- 1962
											docRoot, -- 1963
											dotExts, -- 1964
											{}, -- 1965
											ensureSafeSearchGlobs(globs), -- 1966
											patterns[p + 1] -- 1967
										) -- 1967
										local ____req_useRegex_28 = req.useRegex -- 1968
										if ____req_useRegex_28 == nil then -- 1968
											____req_useRegex_28 = false -- 1968
										end -- 1968
										__TS__SparseArrayPush(____array_31, ____req_useRegex_28) -- 1968
										local ____req_caseSensitive_29 = req.caseSensitive -- 1969
										if ____req_caseSensitive_29 == nil then -- 1969
											____req_caseSensitive_29 = false -- 1969
										end -- 1969
										__TS__SparseArrayPush(____array_31, ____req_caseSensitive_29) -- 1969
										local ____req_includeContent_30 = req.includeContent -- 1970
										if ____req_includeContent_30 == nil then -- 1970
											____req_includeContent_30 = true -- 1970
										end -- 1970
										__TS__SparseArrayPush(____array_31, ____req_includeContent_30, req.contentWindow or 80) -- 1970
										local raw = ____Content_searchFilesAsync_33( -- 1962
											____Content_32, -- 1962
											__TS__SparseArraySpread(____array_31) -- 1962
										) -- 1962
										local hits = {} -- 1973
										do -- 1973
											local i = 0 -- 1974
											while i < #raw do -- 1974
												do -- 1974
													local row = raw[i + 1] -- 1975
													local file = toDocRelativePath(resultBaseRoot, row.file, docSource) -- 1976
													if file == "" then -- 1976
														goto __continue398 -- 1977
													end -- 1977
													hits[#hits + 1] = { -- 1978
														file = file, -- 1979
														line = type(row.line) == "number" and row.line or nil, -- 1980
														content = type(row.content) == "string" and row.content or nil -- 1981
													} -- 1981
												end -- 1981
												::__continue398:: -- 1981
												i = i + 1 -- 1974
											end -- 1974
										end -- 1974
										allHits[#allHits + 1] = __TS__ArraySlice( -- 1984
											sortDoraAPISearchHits(hits, docSource, req.programmingLanguage), -- 1984
											0, -- 1984
											limit -- 1984
										) -- 1984
										p = p + 1 -- 1961
									end -- 1961
								end -- 1961
								local hits = mergeDoraAPISearchHitsUnique(allHits) -- 1986
								local fallbackPatterns -- 1987
								if #hits == 0 and #patterns == 1 and req.useRegex ~= true and (string.find(pattern, "|", nil, true) or 0) - 1 < 0 then -- 1987
									local terms = splitWhitespaceSearchPatterns(pattern) -- 1992
									if #terms > 1 then -- 1992
										fallbackPatterns = terms -- 1994
										local fallbackHits = {} -- 1995
										do -- 1995
											local p = 0 -- 1996
											while p < #terms do -- 1996
												local ____Content_37 = Content -- 1997
												local ____Content_searchFilesAsync_38 = Content.searchFilesAsync -- 1997
												local ____array_36 = __TS__SparseArrayNew( -- 1997
													docRoot, -- 1998
													dotExts, -- 1999
													{}, -- 2000
													ensureSafeSearchGlobs(globs), -- 2001
													terms[p + 1], -- 2002
													false -- 2003
												) -- 2003
												local ____req_caseSensitive_34 = req.caseSensitive -- 2004
												if ____req_caseSensitive_34 == nil then -- 2004
													____req_caseSensitive_34 = false -- 2004
												end -- 2004
												__TS__SparseArrayPush(____array_36, ____req_caseSensitive_34) -- 2004
												local ____req_includeContent_35 = req.includeContent -- 2005
												if ____req_includeContent_35 == nil then -- 2005
													____req_includeContent_35 = true -- 2005
												end -- 2005
												__TS__SparseArrayPush(____array_36, ____req_includeContent_35, req.contentWindow or 80) -- 2005
												local raw = ____Content_searchFilesAsync_38( -- 1997
													____Content_37, -- 1997
													__TS__SparseArraySpread(____array_36) -- 1997
												) -- 1997
												local termHits = {} -- 2008
												do -- 2008
													local i = 0 -- 2009
													while i < #raw do -- 2009
														do -- 2009
															local row = raw[i + 1] -- 2010
															local file = toDocRelativePath(resultBaseRoot, row.file, docSource) -- 2011
															if file == "" then -- 2011
																goto __continue405 -- 2012
															end -- 2012
															termHits[#termHits + 1] = { -- 2013
																file = file, -- 2014
																line = type(row.line) == "number" and row.line or nil, -- 2015
																content = type(row.content) == "string" and row.content or nil -- 2016
															} -- 2016
														end -- 2016
														::__continue405:: -- 2016
														i = i + 1 -- 2009
													end -- 2009
												end -- 2009
												fallbackHits[#fallbackHits + 1] = __TS__ArraySlice( -- 2019
													sortDoraAPISearchHits(termHits, docSource, req.programmingLanguage), -- 2019
													0, -- 2019
													limit -- 2019
												) -- 2019
												p = p + 1 -- 1996
											end -- 1996
										end -- 1996
										hits = mergeDoraAPISearchHitsUnique(fallbackHits) -- 2021
									end -- 2021
								end -- 2021
								resolve(nil, { -- 2024
									success = true, -- 2025
									docSource = docSource, -- 2026
									docLanguage = req.docLanguage, -- 2027
									programmingLanguage = req.programmingLanguage, -- 2028
									exts = exts, -- 2029
									results = hits, -- 2030
									hint = "Use read_file directly with the namespaced file value from a search result to view the complete authoritative document.", -- 2031
									totalResults = #hits, -- 2032
									truncated = false, -- 2033
									limit = limit, -- 2034
									fallbackPatterns = fallbackPatterns -- 2035
								}) -- 2035
							end) -- 2035
							if not ____try then -- 2035
								____catch(____hasReturned) -- 2035
							end -- 2035
						end -- 2035
					end)) -- 1958
				end -- 1957
			) -- 1957
		) -- 1957
	end) -- 1957
end -- 1930
function ____exports.searchDoraAPIHttp(req, callback) -- 2044
	local ____self_39 = ____exports.searchDoraAPI(req) -- 2044
	____self_39["then"]( -- 2044
		____self_39, -- 2044
		function(____, result) return callback(result) end -- 2055
	) -- 2055
end -- 2044
function ____exports.readDoraDoc(req) -- 2058
	local requestedFile = table.concat( -- 2064
		__TS__StringSplit(req.file or "", "\\"), -- 2064
		"/" -- 2064
	) -- 2064
	local file = requestedFile -- 2065
	local namespacedSource = nil -- 2066
	if __TS__StringStartsWith(requestedFile, AGENT_DORA_DOC_PREFIX) then -- 2066
		local namespaced = __TS__StringSlice(requestedFile, #AGENT_DORA_DOC_PREFIX) -- 2068
		if __TS__StringStartsWith(namespaced, "api/") then -- 2068
			namespacedSource = "api" -- 2070
			file = string.sub(namespaced, 5) -- 2071
		elseif __TS__StringStartsWith(namespaced, "tutorial/") then -- 2071
			namespacedSource = "tutorial" -- 2073
			file = string.sub(namespaced, 10) -- 2074
		else -- 2074
			return {success = false, message = "invalid Dora doc namespace"} -- 2076
		end -- 2076
	end -- 2076
	if not isValidWorkspacePath(file) or file == "." then -- 2076
		return {success = false, message = "invalid file"} -- 2080
	end -- 2080
	local lowerFile = string.lower(file) -- 2082
	local isTutorialDoc = __TS__StringEndsWith(lowerFile, ".md") -- 2083
	local isAPIDoc = __TS__StringEndsWith(lowerFile, ".ts") or __TS__StringEndsWith(lowerFile, ".tl") -- 2084
	if not isTutorialDoc and not isAPIDoc then -- 2084
		return {success = false, message = "unsupported doc file type"} -- 2085
	end -- 2085
	local docSource = namespacedSource or (isTutorialDoc and "tutorial" or "api") -- 2086
	local root = getDoraDocResultBaseRoot(docSource, req.docLanguage) -- 2087
	local fullPath = Path(root, file) -- 2088
	local relative = Path:getRelative(fullPath, root) -- 2089
	if relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 2089
		return {success = false, message = "invalid file"} -- 2091
	end -- 2091
	local readResult = ____exports.readFile(root, file, req.startLine or 1, req.endLine or -1) -- 2093
	if not readResult.success then -- 2093
		return readResult -- 2094
	end -- 2094
	return { -- 2095
		success = true, -- 2096
		docLanguage = req.docLanguage, -- 2097
		file = file, -- 2098
		content = readResult.content, -- 2099
		startLine = readResult.startLine, -- 2100
		endLine = readResult.endLine -- 2101
	} -- 2101
end -- 2058
function ____exports.applyFileChanges(taskId, workDir, changes, options) -- 2105
	if options == nil then -- 2105
		options = {} -- 2105
	end -- 2105
	if #changes == 0 then -- 2105
		return {success = false, message = "empty changes"} -- 2107
	end -- 2107
	if not isValidWorkDir(workDir) then -- 2107
		return {success = false, message = "invalid workDir"} -- 2110
	end -- 2110
	if not getTaskStatus(taskId) then -- 2110
		return {success = false, message = "task not found"} -- 2113
	end -- 2113
	local expandedChanges = expandLinkedDeleteChanges(workDir, changes) -- 2115
	local dup = rejectDuplicatePaths(expandedChanges) -- 2116
	if dup then -- 2116
		return {success = false, message = "duplicate path in batch: " .. dup} -- 2118
	end -- 2118
	for ____, change in ipairs(expandedChanges) do -- 2121
		if not isValidWorkspacePath(change.path) then -- 2121
			return {success = false, message = "invalid path: " .. change.path} -- 2123
		end -- 2123
		if (change.op == "write" or change.op == "create") and change.content == nil then -- 2123
			return {success = false, message = "missing content for " .. change.path} -- 2126
		end -- 2126
	end -- 2126
	local headSeq = getTaskHeadSeq(taskId) -- 2130
	if headSeq == nil then -- 2130
		return {success = false, message = "task not found"} -- 2131
	end -- 2131
	local nextSeq = headSeq + 1 -- 2132
	local checkpointId = insertCheckpoint( -- 2133
		taskId, -- 2133
		nextSeq, -- 2133
		options.summary or "", -- 2133
		options.toolName or "", -- 2133
		"PREPARED" -- 2133
	) -- 2133
	if checkpointId <= 0 then -- 2133
		return {success = false, message = "failed to create checkpoint"} -- 2135
	end -- 2135
	do -- 2135
		local i = 0 -- 2138
		while i < #expandedChanges do -- 2138
			local change = expandedChanges[i + 1] -- 2139
			local fullPath = resolveWorkspaceFilePath(workDir, change.path) -- 2140
			if not fullPath then -- 2140
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2142
				return {success = false, message = "invalid path: " .. change.path} -- 2143
			end -- 2143
			if change.op == "delete" and Content:exist(fullPath) and Content:isdir(fullPath) then -- 2143
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2146
				return {success = false, message = "delete_file only supports files, not directories: " .. change.path} -- 2147
			end -- 2147
			local before = getFileState(fullPath) -- 2149
			local afterExists = change.op ~= "delete" -- 2150
			local afterContent = afterExists and (change.content or "") or "" -- 2151
			local inserted = DB:exec(("INSERT INTO " .. TABLE_ENTRY) .. "(checkpoint_id, ord, path, op, before_exists, before_content, after_exists, after_content, bytes_before, bytes_after)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 2152
				checkpointId, -- 2156
				i + 1, -- 2157
				change.path, -- 2158
				change.op, -- 2159
				before.exists and 1 or 0, -- 2160
				before.content, -- 2161
				afterExists and 1 or 0, -- 2162
				afterContent, -- 2163
				before.bytes, -- 2164
				#afterContent -- 2165
			}) -- 2165
			if inserted <= 0 then -- 2165
				DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2169
				return {success = false, message = "failed to insert checkpoint entry: " .. change.path} -- 2170
			end -- 2170
			i = i + 1 -- 2138
		end -- 2138
	end -- 2138
	local appliedCount = 0 -- 2174
	for ____, entry in ipairs(getCheckpointEntries(checkpointId, false)) do -- 2175
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2176
		if not fullPath then -- 2176
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2178
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2179
			return {success = false, message = ("invalid path: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2180
		end -- 2180
		local ok = applySingleFile(fullPath, entry.afterExists, entry.afterContent) -- 2182
		if not ok then -- 2182
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2184
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount + 1) -- 2185
			return {success = false, message = ("failed to apply file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; previously applied files restored")} -- 2186
		end -- 2186
		appliedCount = appliedCount + 1 -- 2188
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.afterExists, entry.afterContent) then -- 2188
			DB:exec(("UPDATE " .. TABLE_CP) .. " SET status = ? WHERE id = ?", {"FAILED", checkpointId}) -- 2190
			local rollbackError = rollbackPreparedFileChanges(checkpointId, workDir, appliedCount) -- 2191
			return {success = false, message = ("failed to sync file change: " .. entry.path) .. (rollbackError ~= nil and "; " .. rollbackError or "; all applied files restored")} -- 2192
		end -- 2192
	end -- 2192
	DB:exec( -- 2196
		("UPDATE " .. TABLE_CP) .. " SET status = ?, applied_at = ? WHERE id = ?", -- 2196
		{ -- 2198
			"APPLIED", -- 2198
			now(), -- 2198
			checkpointId -- 2198
		} -- 2198
	) -- 2198
	DB:exec( -- 2200
		("UPDATE " .. TABLE_TASK) .. " SET head_seq = ?, updated_at = ? WHERE id = ?", -- 2200
		{ -- 2202
			nextSeq, -- 2202
			now(), -- 2202
			taskId -- 2202
		} -- 2202
	) -- 2202
	return {success = true, taskId = taskId, checkpointId = checkpointId, checkpointSeq = nextSeq} -- 2204
end -- 2105
function ____exports.rollbackCheckpoint(checkpointId, workDir) -- 2212
	if not isValidWorkDir(workDir) then -- 2212
		return {success = false, message = "invalid workDir"} -- 2213
	end -- 2213
	if checkpointId <= 0 then -- 2213
		return {success = false, message = "invalid checkpointId"} -- 2214
	end -- 2214
	local entries = getCheckpointEntries(checkpointId, true) -- 2215
	if #entries == 0 then -- 2215
		return {success = false, message = "checkpoint not found or empty"} -- 2217
	end -- 2217
	for ____, entry in ipairs(entries) do -- 2219
		local fullPath = resolveWorkspaceFilePath(workDir, entry.path) -- 2220
		if not fullPath then -- 2220
			return {success = false, message = "invalid path: " .. entry.path} -- 2222
		end -- 2222
		local ok = applySingleFile(fullPath, entry.beforeExists, entry.beforeContent) -- 2224
		if not ok then -- 2224
			Log( -- 2226
				"Error", -- 2226
				(("Agent rollback failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2226
			) -- 2226
			Log( -- 2227
				"Info", -- 2227
				(("[rollback] failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2227
			) -- 2227
			return {success = false, message = "failed to rollback file: " .. entry.path} -- 2228
		end -- 2228
		if not ____exports.sendWebIDEFileUpdate(fullPath, entry.beforeExists, entry.beforeContent) then -- 2228
			Log( -- 2231
				"Error", -- 2231
				(("Agent rollback sync failed at checkpoint " .. tostring(checkpointId)) .. ", file ") .. entry.path -- 2231
			) -- 2231
			Log( -- 2232
				"Info", -- 2232
				(("[rollback] sync_failed checkpoint=" .. tostring(checkpointId)) .. " file=") .. entry.path -- 2232
			) -- 2232
			return {success = false, message = "failed to sync rollback file: " .. entry.path} -- 2233
		end -- 2233
	end -- 2233
	DB:exec( -- 2236
		("UPDATE " .. TABLE_CP) .. " SET status = ?, reverted_at = ? WHERE id = ?", -- 2236
		{ -- 2236
			"REVERTED", -- 2236
			now(), -- 2236
			checkpointId -- 2236
		} -- 2236
	) -- 2236
	return {success = true, checkpointId = checkpointId} -- 2237
end -- 2212
function ____exports.rollbackTaskChangeSet(taskId, workDir) -- 2240
	if not isValidWorkDir(workDir) then -- 2240
		return {success = false, message = "invalid workDir"} -- 2241
	end -- 2241
	if not getTaskStatus(taskId) then -- 2241
		return {success = false, message = "task not found"} -- 2242
	end -- 2242
	local checkpoints = listCheckpointIdsForTask(taskId, true) -- 2243
	if #checkpoints == 0 then -- 2243
		return {success = false, message = "change set not found or empty"} -- 2245
	end -- 2245
	local lastCheckpointId = 0 -- 2247
	do -- 2247
		local i = 0 -- 2248
		while i < #checkpoints do -- 2248
			local result = ____exports.rollbackCheckpoint(checkpoints[i + 1].id, workDir) -- 2249
			if not result.success then -- 2249
				return {success = false, message = result.message} -- 2250
			end -- 2250
			lastCheckpointId = checkpoints[i + 1].id -- 2251
			i = i + 1 -- 2248
		end -- 2248
	end -- 2248
	return {success = true, taskId = taskId, checkpointId = lastCheckpointId, checkpointCount = #checkpoints} -- 2253
end -- 2240
function ____exports.getCheckpointEntriesForDebug(checkpointId) -- 2261
	return getCheckpointEntries(checkpointId, false) -- 2262
end -- 2261
function ____exports.getCheckpointDiff(checkpointId) -- 2265
	if checkpointId <= 0 then -- 2265
		return {success = false, message = "invalid checkpointId"} -- 2267
	end -- 2267
	local entries = getCheckpointEntries(checkpointId, false) -- 2269
	if #entries == 0 then -- 2269
		return {success = false, message = "checkpoint not found or empty"} -- 2271
	end -- 2271
	return { -- 2273
		success = true, -- 2274
		files = __TS__ArrayMap( -- 2275
			entries, -- 2275
			function(____, entry) return { -- 2275
				path = entry.path, -- 2276
				op = entry.op, -- 2277
				beforeExists = entry.beforeExists, -- 2278
				afterExists = entry.afterExists, -- 2279
				beforeContent = entry.beforeContent, -- 2280
				afterContent = entry.afterContent -- 2281
			} end -- 2281
		) -- 2281
	} -- 2281
end -- 2265
local function finalizeBuildResult(workDir, messages) -- 2286
	local normalized = __TS__ArrayMap( -- 2287
		messages, -- 2287
		function(____, m) return m.success and __TS__ObjectAssign( -- 2287
			{}, -- 2288
			m, -- 2288
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2288
		) or __TS__ObjectAssign( -- 2288
			{}, -- 2289
			m, -- 2289
			{file = toWorkspaceRelativePath(workDir, m.file)} -- 2289
		) end -- 2289
	) -- 2289
	local total = #normalized -- 2290
	local failed = 0 -- 2291
	do -- 2291
		local i = 0 -- 2292
		while i < #normalized do -- 2292
			if not normalized[i + 1].success then -- 2292
				failed = failed + 1 -- 2293
			end -- 2293
			i = i + 1 -- 2292
		end -- 2292
	end -- 2292
	local passed = total - failed -- 2295
	if failed > 0 then -- 2295
		return { -- 2297
			success = false, -- 2298
			message = ((("Build failed: " .. tostring(failed)) .. "/") .. tostring(total)) .. " file(s) failed.", -- 2299
			total = total, -- 2300
			passed = passed, -- 2301
			failed = failed, -- 2302
			messages = normalized -- 2303
		} -- 2303
	end -- 2303
	return { -- 2306
		success = true, -- 2307
		message = ((("Build passed: " .. tostring(passed)) .. "/") .. tostring(total)) .. " file(s).", -- 2308
		total = total, -- 2309
		passed = passed, -- 2310
		failed = 0, -- 2311
		messages = normalized -- 2312
	} -- 2312
end -- 2286
function ____exports.build(req) -- 2316
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2316
		local targetRel = req.path or "" -- 2317
		local target = resolveWorkspaceSearchPath(req.workDir, targetRel) -- 2318
		if not target then -- 2318
			return ____awaiter_resolve(nil, {success = false, message = "invalid path or workDir"}) -- 2318
		end -- 2318
		if not Content:exist(target) then -- 2318
			return ____awaiter_resolve(nil, {success = false, message = "path not existed"}) -- 2318
		end -- 2318
		local messages = {} -- 2325
		if not Content:isdir(target) then -- 2325
			local kind = getSupportedBuildKind(target) -- 2327
			if not kind then -- 2327
				return ____awaiter_resolve(nil, {success = false, message = "expecting a ts/tsx, tl, lua, yue or yarn file"}) -- 2327
			end -- 2327
			if kind == "ts" then -- 2327
				local content = Content:load(target) -- 2332
				if content == nil then -- 2332
					return ____awaiter_resolve(nil, {success = false, message = "failed to read file"}) -- 2332
				end -- 2332
				if isTiledEditorContent(content) then -- 2332
					Log("Info", "[build] skip tiled editor file=" .. target) -- 2337
					return ____awaiter_resolve( -- 2337
						nil, -- 2337
						finalizeBuildResult(req.workDir, messages) -- 2338
					) -- 2338
				end -- 2338
				if not ____exports.sendWebIDEFileUpdate(target, true, content) then -- 2338
					return ____awaiter_resolve(nil, {success = false, message = "failed to encode UpdateFile request"}) -- 2338
				end -- 2338
				if not isDtsFile(target) then -- 2338
					messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(target, content, req.workDir)) -- 2344
				end -- 2344
			else -- 2344
				messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(target)) -- 2347
			end -- 2347
			Log( -- 2349
				"Info", -- 2349
				(("[build] file=" .. target) .. " messages=") .. tostring(#messages) -- 2349
			) -- 2349
			return ____awaiter_resolve( -- 2349
				nil, -- 2349
				finalizeBuildResult(req.workDir, messages) -- 2350
			) -- 2350
		end -- 2350
		local listResult = ____exports.listFiles({ -- 2352
			workDir = req.workDir, -- 2353
			path = targetRel, -- 2354
			globs = __TS__ArrayMap( -- 2355
				codeExtensions, -- 2355
				function(____, e) return "**/*" .. e end -- 2355
			), -- 2355
			maxEntries = 10000 -- 2356
		}) -- 2356
		local relFiles = listResult.success and listResult.files or ({}) -- 2359
		local tsFileData = {} -- 2360
		local buildQueue = {} -- 2361
		for ____, rel in ipairs(relFiles) do -- 2362
			do -- 2362
				local file = Content:isAbsolutePath(rel) and rel or Path(target, rel) -- 2363
				local kind = getSupportedBuildKind(file) -- 2364
				if not kind then -- 2364
					goto __continue479 -- 2365
				end -- 2365
				buildQueue[#buildQueue + 1] = {file = file, kind = kind} -- 2366
				if kind ~= "ts" then -- 2366
					goto __continue479 -- 2368
				end -- 2368
				local content = Content:load(file) -- 2370
				if content == nil then -- 2370
					messages[#messages + 1] = {success = false, file = file, message = "failed to read file"} -- 2372
					goto __continue479 -- 2373
				end -- 2373
				if isTiledEditorContent(content) then -- 2373
					Log("Info", "[build] skip tiled editor file=" .. file) -- 2376
					goto __continue479 -- 2377
				end -- 2377
				tsFileData[file] = content -- 2379
			end -- 2379
			::__continue479:: -- 2379
		end -- 2379
		do -- 2379
			local i = 0 -- 2381
			while i < #buildQueue do -- 2381
				do -- 2381
					local ____buildQueue_index_40 = buildQueue[i + 1] -- 2382
					local file = ____buildQueue_index_40.file -- 2382
					local kind = ____buildQueue_index_40.kind -- 2382
					if kind == "ts" then -- 2382
						local content = tsFileData[file] -- 2384
						if content == nil or isDtsFile(file) then -- 2384
							goto __continue486 -- 2386
						end -- 2386
						if not ____exports.sendWebIDEFileUpdate(file, true, content) then -- 2386
							messages[#messages + 1] = {success = false, file = file, message = "failed to encode UpdateFile request"} -- 2389
							goto __continue486 -- 2390
						end -- 2390
						messages[#messages + 1] = __TS__Await(____exports.runSingleTsTranspile(file, content, req.workDir)) -- 2392
						goto __continue486 -- 2393
					end -- 2393
					messages[#messages + 1] = __TS__Await(runSingleNonTsBuild(file)) -- 2395
				end -- 2395
				::__continue486:: -- 2395
				i = i + 1 -- 2381
			end -- 2381
		end -- 2381
		if #messages == 0 then -- 2381
			Log("Info", ("[build] dir=" .. target) .. " messages=0 no buildable code files found") -- 2398
			return ____awaiter_resolve(nil, {success = false, message = "No code files were found to build."}) -- 2398
		end -- 2398
		Log( -- 2401
			"Info", -- 2401
			(("[build] dir=" .. target) .. " messages=") .. tostring(#messages) -- 2401
		) -- 2401
		return ____awaiter_resolve( -- 2401
			nil, -- 2401
			finalizeBuildResult(req.workDir, messages) -- 2402
		) -- 2402
	end) -- 2402
end -- 2316
local EXECUTE_COMMAND_OUTPUT_MAX = 12000 -- 2405
local EXECUTE_COMMAND_ERROR_MAX = 4000 -- 2406
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 2407
local agentEntryRuntimeOwner = "" -- 2408
local function truncateCommandOutput(output) -- 2410
	if #output <= EXECUTE_COMMAND_OUTPUT_MAX then -- 2410
		return output -- 2411
	end -- 2411
	return __TS__StringSlice(output, 0, EXECUTE_COMMAND_OUTPUT_MAX) .. "\n... output truncated ..." -- 2412
end -- 2410
local function truncateCommandError(message) -- 2415
	if #message <= EXECUTE_COMMAND_ERROR_MAX then -- 2415
		return message -- 2416
	end -- 2416
	return __TS__StringSlice(message, 0, EXECUTE_COMMAND_ERROR_MAX) .. "\n... error message truncated ..." -- 2417
end -- 2415
local function executeLuaCommand(req) -- 2420
	local code = __TS__StringTrim(req.code or "") -- 2428
	if code == "" then -- 2428
		return __TS__Promise.resolve({ -- 2430
			success = false, -- 2430
			mode = "lua", -- 2430
			output = "", -- 2430
			message = "missing code", -- 2430
			phase = "validate" -- 2430
		}) -- 2430
	end -- 2430
	local output = {} -- 2432
	local entry = require("Script.Dev.Entry") -- 2433
	local ownsEntryRuntime = false -- 2434
	local function acquireEntryRuntime() -- 2435
		if agentEntryRuntimeOwner ~= "" and agentEntryRuntimeOwner ~= req.operationId then -- 2435
			error("Dora entry runtime is busy with another Agent command") -- 2437
		end -- 2437
		agentEntryRuntimeOwner = req.operationId -- 2439
		ownsEntryRuntime = true -- 2440
	end -- 2435
	local function stopOwnedEntry() -- 2442
		if not ownsEntryRuntime then -- 2442
			return nil -- 2443
		end -- 2443
		local cleanupError -- 2444
		do -- 2444
			local function ____catch(e) -- 2444
				cleanupError = "failed to stop Agent test entry: " .. tostring(e) -- 2448
			end -- 2448
			local ____try, ____hasReturned = pcall(function() -- 2448
				entry.stop() -- 2446
			end) -- 2446
			if not ____try then -- 2446
				____catch(____hasReturned) -- 2446
			end -- 2446
		end -- 2446
		ownsEntryRuntime = false -- 2450
		if agentEntryRuntimeOwner == req.operationId then -- 2450
			agentEntryRuntimeOwner = "" -- 2452
		end -- 2452
		return cleanupError -- 2454
	end -- 2442
	local function normalizeEntryFile(value) -- 2456
		if not value or type(value) ~= "table" then -- 2456
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 2458
		end -- 2458
		local descriptor = value -- 2460
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 2461
		if relativeFile == "" then -- 2461
			relativeFile = "init" -- 2462
		end -- 2462
		if not isValidWorkspacePath(relativeFile) then -- 2462
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 2464
		end -- 2464
		local fileName = Path(req.workDir, relativeFile) -- 2466
		local ext = Path:getExt(fileName) -- 2467
		if ext ~= "" then -- 2467
			fileName = Path:replaceExt(fileName, "") -- 2468
		end -- 2468
		local luaFile = Path:replaceExt(fileName, "lua") -- 2469
		if not Content:exist(luaFile) then -- 2469
			error("Agent test entry was not built: " .. luaFile) -- 2471
		end -- 2471
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 2473
		return { -- 2474
			fileName = fileName, -- 2475
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 2476
		} -- 2476
	end -- 2456
	local function capturePrint(...) -- 2479
		local values = {...} -- 2479
		local parts = {} -- 2480
		do -- 2480
			local i = 0 -- 2481
			while i < #values do -- 2481
				parts[#parts + 1] = tostring(values[i + 1]) -- 2482
				i = i + 1 -- 2481
			end -- 2481
		end -- 2481
		output[#output + 1] = table.concat(parts, "\t") -- 2484
	end -- 2479
	local env = setmetatable( -- 2486
		{ -- 2486
			projectDir = req.workDir, -- 2487
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 2488
				if type(moduleNameValue) ~= "string" then -- 2488
					error("requireProjectModule expects a project module name string") -- 2490
				end -- 2490
				local moduleName = __TS__StringTrim(moduleNameValue) -- 2492
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 2492
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 2494
				end -- 2494
				local reloadModules = {moduleName} -- 2496
				if reloadModulesValue ~= nil then -- 2496
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 2496
						error("requireProjectModule reloadModules must be an array of module names") -- 2499
					end -- 2499
					local items = reloadModulesValue -- 2501
					do -- 2501
						local i = 0 -- 2502
						while i < #items do -- 2502
							local item = items[i + 1] -- 2503
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 2503
								error("requireProjectModule reloadModules contains an invalid module name") -- 2505
							end -- 2505
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 2505
								reloadModules[#reloadModules + 1] = item -- 2507
							end -- 2507
							i = i + 1 -- 2502
						end -- 2502
					end -- 2502
				end -- 2502
				local luaPackage = _G.package -- 2510
				local previousPath = luaPackage.path -- 2514
				local previousSearchPaths = Content.searchPaths -- 2515
				local scopedSearchPaths = {req.workDir} -- 2516
				do -- 2516
					local i = 0 -- 2517
					while i < #previousSearchPaths do -- 2517
						local searchPath = previousSearchPaths[i + 1] -- 2518
						if searchPath ~= req.workDir then -- 2518
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 2519
						end -- 2519
						i = i + 1 -- 2517
					end -- 2517
				end -- 2517
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 2521
				Content.searchPaths = scopedSearchPaths -- 2522
				do -- 2522
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2522
						do -- 2522
							local i = 0 -- 2524
							while i < #reloadModules do -- 2524
								local reloadName = reloadModules[i + 1] -- 2525
								luaPackage.loaded[reloadName] = nil -- 2526
								luaPackage.loaded[table.concat( -- 2527
									__TS__StringSplit(reloadName, "/"), -- 2527
									"." -- 2527
								)] = nil -- 2527
								luaPackage.loaded[table.concat( -- 2528
									__TS__StringSplit(reloadName, "."), -- 2528
									"/" -- 2528
								)] = nil -- 2528
								i = i + 1 -- 2524
							end -- 2524
						end -- 2524
						return true, require(table.concat( -- 2530
							__TS__StringSplit(moduleName, "/"), -- 2530
							"." -- 2530
						)) -- 2530
					end) -- 2530
					do -- 2530
						Content.searchPaths = previousSearchPaths -- 2532
						luaPackage.path = previousPath -- 2533
					end -- 2533
					if not ____try then -- 2533
						error(____hasReturned, 0) -- 2533
					end -- 2533
					if ____try and ____hasReturned then -- 2533
						return ____returnValue -- 2523
					end -- 2523
				end -- 2523
			end, -- 2488
			print = capturePrint, -- 2536
			refreshTree = function(path) -- 2537
				if path == nil then -- 2537
					return refreshProjectTree(req.workDir) -- 2539
				end -- 2539
				if type(path) ~= "string" then -- 2539
					error("refreshTree expects a project-relative file path string or no argument") -- 2542
				end -- 2542
				return refreshProjectTree(req.workDir, path) -- 2544
			end, -- 2537
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 2546
			enterEntryAsync = function(value) -- 2547
				local normalized = normalizeEntryFile(value) -- 2548
				acquireEntryRuntime() -- 2549
				entry.allClear() -- 2550
				local success, message = entry.enterEntryAsync({ -- 2551
					entryName = normalized.entryName, -- 2552
					fileName = normalized.fileName, -- 2553
					workDir = req.workDir, -- 2554
					projectRoot = req.workDir, -- 2555
					runKind = "agent_test" -- 2556
				}) -- 2556
				return success, message -- 2558
			end, -- 2547
			stopEntry = function() -- 2560
				if not ownsEntryRuntime then -- 2560
					return false -- 2561
				end -- 2561
				return entry.stop() -- 2562
			end -- 2560
		}, -- 2560
		{__index = Dora} -- 2564
	) -- 2564
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 2567
	if not fn then -- 2567
		return __TS__Promise.resolve({ -- 2569
			success = false, -- 2570
			mode = "lua", -- 2571
			output = truncateCommandOutput(table.concat(output, "\n")), -- 2572
			message = truncateCommandError(toStr(compileErr)), -- 2573
			phase = "compile" -- 2574
		}) -- 2574
	end -- 2574
	return __TS__New( -- 2577
		__TS__Promise, -- 2577
		function(____, resolve) -- 2577
			local settled = false -- 2578
			local startedAt = App.runningTime -- 2579
			local onProgress = req.onProgress -- 2580
			local isCancelled = req.isCancelled -- 2581
			local function finish(result) -- 2582
				if settled then -- 2582
					return -- 2583
				end -- 2583
				settled = true -- 2584
				local cleanupError = stopOwnedEntry() -- 2585
				if not result.success and cleanupError ~= nil then -- 2585
					result.cleanupError = cleanupError -- 2587
				elseif result.success and cleanupError ~= nil then -- 2587
					resolve(nil, { -- 2589
						success = false, -- 2590
						mode = "lua", -- 2591
						output = result.output, -- 2592
						message = cleanupError, -- 2593
						phase = "execute", -- 2594
						cleanupError = cleanupError -- 2595
					}) -- 2595
					return -- 2597
				end -- 2597
				resolve(nil, result) -- 2599
			end -- 2582
			if onProgress then -- 2582
				onProgress(nil, { -- 2602
					state = "pending", -- 2603
					mode = "lua", -- 2604
					operationId = req.operationId, -- 2605
					stage = "lua", -- 2606
					message = "Lua command pending" -- 2607
				}) -- 2607
			end -- 2607
			Director.systemScheduler:schedule(function() -- 2610
				if settled then -- 2610
					return true -- 2611
				end -- 2611
				if isCancelled and isCancelled(nil) then -- 2611
					finish({ -- 2613
						success = false, -- 2614
						mode = "lua", -- 2615
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2616
						message = "Lua command canceled", -- 2617
						phase = "execute", -- 2618
						interrupted = true -- 2619
					}) -- 2619
					return true -- 2621
				end -- 2621
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 2621
					finish({ -- 2624
						success = false, -- 2625
						mode = "lua", -- 2626
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2627
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 2628
						phase = "timeout" -- 2629
					}) -- 2629
					return true -- 2631
				end -- 2631
				return false -- 2633
			end) -- 2610
			Director.systemScheduler:schedule(once(function() -- 2635
				if settled then -- 2635
					return -- 2636
				end -- 2636
				if onProgress then -- 2636
					onProgress(nil, { -- 2638
						state = "running", -- 2639
						mode = "lua", -- 2640
						operationId = req.operationId, -- 2641
						stage = "lua", -- 2642
						message = "Lua command running" -- 2643
					}) -- 2643
				end -- 2643
				local previousGlobalPrint = _G.print -- 2646
				_G.print = capturePrint -- 2647
				local ok, runtimeErr = pcall(fn) -- 2648
				_G.print = previousGlobalPrint -- 2649
				if not ok then -- 2649
					finish({ -- 2651
						success = false, -- 2652
						mode = "lua", -- 2653
						output = truncateCommandOutput(table.concat(output, "\n")), -- 2654
						message = truncateCommandError(toStr(runtimeErr)), -- 2655
						phase = "execute" -- 2656
					}) -- 2656
					return -- 2658
				end -- 2658
				finish({ -- 2660
					success = true, -- 2660
					mode = "lua", -- 2660
					output = truncateCommandOutput(table.concat(output, "\n")) -- 2660
				}) -- 2660
			end)) -- 2635
		end -- 2577
	) -- 2577
end -- 2420
local function formatGitStatusOutput(status) -- 2665
	if not status then -- 2665
		return "" -- 2666
	end -- 2666
	local lines = {} -- 2667
	local state = toStr(status.state) -- 2668
	local kind = toStr(status.kind) -- 2669
	local message = toStr(status.message) -- 2670
	local errorMessage = toStr(status.error) -- 2671
	if kind ~= "" or state ~= "" then -- 2671
		lines[#lines + 1] = table.concat( -- 2673
			__TS__ArrayFilter( -- 2673
				{kind, state}, -- 2673
				function(____, item) return item ~= "" end -- 2673
			), -- 2673
			": " -- 2673
		) -- 2673
	end -- 2673
	if message ~= "" then -- 2673
		lines[#lines + 1] = message -- 2675
	end -- 2675
	if errorMessage ~= "" then -- 2675
		lines[#lines + 1] = errorMessage -- 2676
	end -- 2676
	local data = status.data -- 2677
	if data ~= nil then -- 2677
		local dataText = encodeJSON(data) -- 2679
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 2680
	end -- 2680
	return truncateCommandOutput(table.concat(lines, "\n")) -- 2682
end -- 2665
local function emitGitProgress(mode, operationId, onProgress, status) -- 2685
	if not onProgress then -- 2685
		return -- 2691
	end -- 2691
	local progress = type(status.progress) == "number" and status.progress or nil -- 2692
	local kind = toStr(status.kind) -- 2693
	local message = toStr(status.message) -- 2694
	local state = toStr(status.state) -- 2695
	local jobId = type(status.id) == "number" and status.id or nil -- 2696
	onProgress({ -- 2697
		state = "running", -- 2698
		mode = mode, -- 2699
		operationId = operationId, -- 2700
		stage = kind ~= "" and kind or "git", -- 2701
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 2702
		progress = progress, -- 2703
		jobId = jobId, -- 2704
		gitState = state ~= "" and state or nil, -- 2705
		gitKind = kind ~= "" and kind or nil -- 2706
	}) -- 2706
end -- 2685
local function cloneGitToTarget(req) -- 2710
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2710
		local parsed = parseGitCloneCommand(req.command) -- 2718
		if parsed == nil then -- 2718
			return ____awaiter_resolve(nil, nil) -- 2718
		end -- 2718
		if not parsed.success then -- 2718
			return ____awaiter_resolve(nil, { -- 2718
				success = false, -- 2721
				mode = "git", -- 2721
				output = "", -- 2721
				message = parsed.message, -- 2721
				phase = "validate" -- 2721
			}) -- 2721
		end -- 2721
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 2723
		if not target then -- 2723
			return ____awaiter_resolve(nil, { -- 2723
				success = false, -- 2725
				mode = "git", -- 2725
				output = "", -- 2725
				message = "invalid clone target path", -- 2725
				phase = "validate" -- 2725
			}) -- 2725
		end -- 2725
		if Content:exist(target) then -- 2725
			return ____awaiter_resolve(nil, { -- 2725
				success = false, -- 2728
				mode = "git", -- 2728
				output = "", -- 2728
				message = "target already exists", -- 2728
				phase = "validate" -- 2728
			}) -- 2728
		end -- 2728
		local targetParent = Path:getPath(target) -- 2730
		if not ensureDirPath(targetParent) then -- 2730
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 2730
		end -- 2730
		local tempRoot = getAgentDownloadTempRoot() -- 2734
		if not ensureDirPath(tempRoot) then -- 2734
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 2734
		end -- 2734
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 2738
		Content:remove(tempPath) -- 2739
		local depth = parsed.depth or "1" -- 2740
		local ____array_41 = __TS__SparseArrayNew( -- 2740
			"clone", -- 2742
			quoteGitArg(parsed.url), -- 2743
			quoteGitArg(Path:getFilename(tempPath)), -- 2744
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 2745
				"-b", -- 2745
				quoteGitArg(parsed.ref) -- 2745
			}) or ({})) -- 2745
		) -- 2745
		__TS__SparseArrayPush( -- 2745
			____array_41, -- 2745
			table.unpack(depth ~= "" and ({ -- 2746
				"--depth",
				quoteGitArg(depth) -- 2746
			}) or ({})) -- 2746
		) -- 2746
		local command = table.concat( -- 2741
			{__TS__SparseArraySpread(____array_41)}, -- 2741
			" " -- 2747
		) -- 2747
		local ____this_43 -- 2747
		____this_43 = req -- 2748
		local ____opt_42 = ____this_43.onProgress -- 2748
		if ____opt_42 ~= nil then -- 2748
			____opt_42(____this_43, { -- 2748
				state = "pending", -- 2749
				mode = "git", -- 2750
				operationId = req.operationId, -- 2751
				stage = "clone", -- 2752
				message = "clone pending", -- 2753
				progress = 0 -- 2754
			}) -- 2754
		end -- 2754
		local gitRes = __TS__Await(runGitAndWait( -- 2756
			tempRoot, -- 2757
			command, -- 2758
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2759
			function() -- 2760
				local ____this_45 -- 2760
				____this_45 = req -- 2760
				local ____opt_44 = ____this_45.isCancelled -- 2760
				return (____opt_44 and ____opt_44(____this_45)) == true -- 2760
			end, -- 2760
			req.timeoutSeconds -- 2761
		)) -- 2761
		if not gitRes.success then -- 2761
			local cleanupError = cleanupPath(tempPath) -- 2764
			local ____formatGitStatusOutput_result_49 = formatGitStatusOutput(gitRes.status) -- 2768
			local ____temp_50 = gitRes.message or "git clone failed" -- 2769
			local ____gitRes_interrupted_48 = gitRes.interrupted -- 2770
			if not ____gitRes_interrupted_48 then -- 2770
				local ____this_47 -- 2770
				____this_47 = req -- 2770
				local ____opt_46 = ____this_47.isCancelled -- 2770
				____gitRes_interrupted_48 = (____opt_46 and ____opt_46(____this_47)) == true -- 2770
			end -- 2770
			return ____awaiter_resolve(nil, { -- 2770
				success = false, -- 2766
				mode = "git", -- 2767
				output = ____formatGitStatusOutput_result_49, -- 2768
				message = ____temp_50, -- 2769
				interrupted = ____gitRes_interrupted_48, -- 2770
				cleanupError = cleanupError -- 2771
			}) -- 2771
		end -- 2771
		if not Content:move(tempPath, target) then -- 2771
			local cleanupError = cleanupPath(tempPath) -- 2775
			return ____awaiter_resolve( -- 2775
				nil, -- 2775
				{ -- 2776
					success = false, -- 2776
					mode = "git", -- 2776
					output = formatGitStatusOutput(gitRes.status), -- 2776
					message = "failed to move cloned repository into target path", -- 2776
					cleanupError = cleanupError -- 2776
				} -- 2776
			) -- 2776
		end -- 2776
		if not refreshProjectTree(req.workDir) then -- 2776
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 2779
		end -- 2779
		local commit = getGitHeadCommit(target) -- 2781
		local output = table.concat( -- 2782
			__TS__ArrayFilter( -- 2782
				{ -- 2782
					formatGitStatusOutput(gitRes.status), -- 2783
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 2783
					commit ~= nil and "commit " .. commit or "" -- 2785
				}, -- 2785
				function(____, item) return item ~= "" end -- 2786
			), -- 2786
			"\n" -- 2786
		) -- 2786
		return ____awaiter_resolve( -- 2786
			nil, -- 2786
			{ -- 2787
				success = true, -- 2787
				mode = "git", -- 2787
				output = truncateCommandOutput(output) -- 2787
			} -- 2787
		) -- 2787
	end) -- 2787
end -- 2710
local function loadGitProfile() -- 2790
	local rows -- 2791
	do -- 2791
		local function ____catch() -- 2791
			return true, nil -- 2795
		end -- 2795
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 2795
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 2793
		end) -- 2793
		if not ____try then -- 2793
			____hasReturned, ____returnValue = ____catch() -- 2793
		end -- 2793
		if ____hasReturned then -- 2793
			return ____returnValue -- 2792
		end -- 2792
	end -- 2792
	if not rows or not rows[1] then -- 2792
		return nil -- 2797
	end -- 2797
	local name = toStr(rows[1][1]) -- 2798
	local email = toStr(rows[1][2]) -- 2799
	if name == "" and email == "" then -- 2799
		return nil -- 2800
	end -- 2800
	return {name = name, email = email} -- 2801
end -- 2790
local function applyGitProfileToCommit(command) -- 2804
	local args = shellSplit(command) -- 2805
	if args[1] ~= "commit" then -- 2805
		return command -- 2806
	end -- 2806
	local hasName = false -- 2807
	local hasEmail = false -- 2808
	for ____, arg in ipairs(args) do -- 2809
		if arg == "--author-name" then
			hasName = true -- 2810
		end -- 2810
		if arg == "--author-email" then
			hasEmail = true -- 2811
		end -- 2811
	end -- 2811
	if hasName and hasEmail then -- 2811
		return command -- 2813
	end -- 2813
	local profile = loadGitProfile() -- 2814
	if not profile then -- 2814
		return command -- 2815
	end -- 2815
	local additions = {} -- 2816
	if not hasName and profile.name ~= "" then -- 2816
		__TS__ArrayPush( -- 2818
			additions, -- 2818
			"--author-name",
			quoteGitArg(profile.name) -- 2818
		) -- 2818
	end -- 2818
	if not hasEmail and profile.email ~= "" then -- 2818
		__TS__ArrayPush( -- 2821
			additions, -- 2821
			"--author-email",
			quoteGitArg(profile.email) -- 2821
		) -- 2821
	end -- 2821
	if #additions == 0 then -- 2821
		return command -- 2823
	end -- 2823
	return (command .. " ") .. table.concat(additions, " ") -- 2824
end -- 2804
local function executeGitCommand(req) -- 2827
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2827
		local command = normalizeGitCommand(req.command or "") -- 2836
		if command == "" then -- 2836
			return ____awaiter_resolve(nil, { -- 2836
				success = false, -- 2838
				mode = "git", -- 2838
				output = "", -- 2838
				message = "missing command", -- 2838
				phase = "validate" -- 2838
			}) -- 2838
		end -- 2838
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 2840
			workDir = req.workDir, -- 2841
			command = command, -- 2842
			operationId = req.operationId, -- 2843
			timeoutSeconds = req.timeoutSeconds, -- 2844
			onProgress = req.onProgress, -- 2845
			isCancelled = req.isCancelled -- 2846
		})) -- 2846
		if cloneResult ~= nil then -- 2846
			return ____awaiter_resolve(nil, cloneResult) -- 2846
		end -- 2846
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 2849
		if not cwd.success then -- 2849
			return ____awaiter_resolve(nil, { -- 2849
				success = false, -- 2851
				mode = "git", -- 2851
				output = "", -- 2851
				cwd = req.cwd, -- 2851
				message = cwd.message, -- 2851
				phase = "validate" -- 2851
			}) -- 2851
		end -- 2851
		command = applyGitProfileToCommit(command) -- 2853
		local ____this_52 -- 2853
		____this_52 = req -- 2854
		local ____opt_51 = ____this_52.onProgress -- 2854
		if ____opt_51 ~= nil then -- 2854
			____opt_51(____this_52, { -- 2854
				state = "pending", -- 2855
				mode = "git", -- 2856
				operationId = req.operationId, -- 2857
				stage = "git", -- 2858
				message = "git command pending", -- 2859
				progress = 0 -- 2860
			}) -- 2860
		end -- 2860
		local gitRes = __TS__Await(runGitAndWait( -- 2862
			cwd.path, -- 2863
			command, -- 2864
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 2865
			function() -- 2866
				local ____this_54 -- 2866
				____this_54 = req -- 2866
				local ____opt_53 = ____this_54.isCancelled -- 2866
				return (____opt_53 and ____opt_53(____this_54)) == true -- 2866
			end, -- 2866
			req.timeoutSeconds -- 2867
		)) -- 2867
		local output = formatGitStatusOutput(gitRes.status) -- 2869
		if not gitRes.success then -- 2869
			local ____output_58 = output -- 2874
			local ____cwd_relative_59 = cwd.relative -- 2875
			local ____temp_60 = gitRes.message or "git command failed" -- 2876
			local ____gitRes_interrupted_57 = gitRes.interrupted -- 2877
			if not ____gitRes_interrupted_57 then -- 2877
				local ____this_56 -- 2877
				____this_56 = req -- 2877
				local ____opt_55 = ____this_56.isCancelled -- 2877
				____gitRes_interrupted_57 = (____opt_55 and ____opt_55(____this_56)) == true -- 2877
			end -- 2877
			return ____awaiter_resolve(nil, { -- 2877
				success = false, -- 2872
				mode = "git", -- 2873
				output = ____output_58, -- 2874
				cwd = ____cwd_relative_59, -- 2875
				message = ____temp_60, -- 2876
				interrupted = ____gitRes_interrupted_57 -- 2877
			}) -- 2877
		end -- 2877
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 2877
	end) -- 2877
end -- 2827
function ____exports.executeCommand(req) -- 2883
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2883
		local mode = req.mode -- 2893
		if mode ~= "lua" and mode ~= "git" then -- 2893
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 2893
		end -- 2893
		if mode == "lua" then -- 2893
			return ____awaiter_resolve( -- 2893
				nil, -- 2893
				executeLuaCommand({ -- 2898
					workDir = req.workDir, -- 2899
					code = req.code or "", -- 2900
					timeoutSeconds = math.max( -- 2901
						1, -- 2901
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 2901
					), -- 2901
					operationId = createOperationId(), -- 2902
					onProgress = req.onProgress, -- 2903
					isCancelled = req.isCancelled -- 2904
				}) -- 2904
			) -- 2904
		end -- 2904
		local operationId = createOperationId() -- 2907
		return ____awaiter_resolve( -- 2907
			nil, -- 2907
			executeGitCommand({ -- 2908
				workDir = req.workDir, -- 2909
				command = req.command or "", -- 2910
				cwd = req.cwd, -- 2911
				timeoutSeconds = math.max( -- 2912
					1, -- 2912
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 2912
				), -- 2912
				operationId = operationId, -- 2913
				onProgress = req.onProgress, -- 2914
				isCancelled = req.isCancelled -- 2915
			}) -- 2915
		) -- 2915
	end) -- 2915
end -- 2883
function ____exports.fetchUrl(req) -- 2919
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2919
		local mode = "download" -- 2926
		local url = __TS__StringTrim(req.url or "") -- 2927
		local targetRel = __TS__StringTrim(req.target or "") -- 2928
		if not isHttpUrl(url) then -- 2928
			return ____awaiter_resolve(nil, { -- 2928
				success = false, -- 2930
				state = "failed", -- 2930
				mode = mode, -- 2930
				target = targetRel, -- 2930
				message = "fetch_url only supports http:// and https:// URLs" -- 2930
			}) -- 2930
		end -- 2930
		if targetRel == "" then -- 2930
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 2930
		end -- 2930
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 2935
		if not target then -- 2935
			return ____awaiter_resolve(nil, { -- 2935
				success = false, -- 2937
				state = "failed", -- 2937
				mode = mode, -- 2937
				target = targetRel, -- 2937
				message = "invalid target path" -- 2937
			}) -- 2937
		end -- 2937
		if Content:exist(target) then -- 2937
			return ____awaiter_resolve(nil, { -- 2937
				success = false, -- 2940
				state = "failed", -- 2940
				mode = mode, -- 2940
				target = targetRel, -- 2940
				message = "target already exists" -- 2940
			}) -- 2940
		end -- 2940
		local operationId = createOperationId() -- 2942
		local tempRoot = getAgentDownloadTempRoot() -- 2943
		if not ensureDirPath(tempRoot) then -- 2943
			return ____awaiter_resolve(nil, { -- 2943
				success = false, -- 2945
				state = "failed", -- 2945
				mode = mode, -- 2945
				target = targetRel, -- 2945
				message = "failed to create agent download temp directory" -- 2945
			}) -- 2945
		end -- 2945
		local tempPath = Path(tempRoot, operationId .. ".download") -- 2947
		Content:remove(tempPath) -- 2948
		local function emitProgress(progress) -- 2949
			if not req.onProgress then -- 2949
				return -- 2950
			end -- 2950
			req:onProgress(__TS__ObjectAssign({ -- 2951
				state = "running", -- 2952
				mode = mode, -- 2953
				operationId = operationId, -- 2954
				target = targetRel, -- 2955
				tempPath = tempPath -- 2956
			}, progress)) -- 2956
		end -- 2949
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 2960
		local function interrupted() -- 2965
			local ____this_62 -- 2965
			____this_62 = req -- 2965
			local ____opt_61 = ____this_62.isCancelled -- 2965
			return (____opt_61 and ____opt_61(____this_62)) == true -- 2965
		end -- 2965
		if not ensureDirForFile(tempPath) then -- 2965
			return ____awaiter_resolve(nil, { -- 2965
				success = false, -- 2967
				state = "failed", -- 2967
				mode = mode, -- 2967
				target = targetRel, -- 2967
				message = "failed to create temporary file directory" -- 2967
			}) -- 2967
		end -- 2967
		local downloadRes = __TS__Await(downloadFile({ -- 2969
			url = url, -- 2970
			tempPath = tempPath, -- 2971
			timeout = 600, -- 2972
			isCancelled = interrupted, -- 2973
			onProgress = function(____, current, total) -- 2974
				local totalNumber = type(total) == "number" and total or 0 -- 2975
				emitProgress({ -- 2976
					stage = "download", -- 2977
					message = "downloading", -- 2978
					current = current, -- 2979
					total = total, -- 2980
					progress = totalNumber > 0 and current / totalNumber or nil -- 2981
				}) -- 2981
			end -- 2974
		})) -- 2974
		if not downloadRes.success then -- 2974
			local cleanupError = cleanupPath(tempPath) -- 2986
			return ____awaiter_resolve( -- 2986
				nil, -- 2986
				{ -- 2987
					success = false, -- 2988
					state = "failed", -- 2989
					mode = mode, -- 2990
					target = targetRel, -- 2991
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 2992
					interrupted = downloadRes.interrupted or interrupted(), -- 2993
					cleanupError = cleanupError -- 2994
				} -- 2994
			) -- 2994
		end -- 2994
		if not ensureDirForFile(target) then -- 2994
			local cleanupError = cleanupPath(tempPath) -- 2998
			return ____awaiter_resolve(nil, { -- 2998
				success = false, -- 2999
				state = "failed", -- 2999
				mode = mode, -- 2999
				target = targetRel, -- 2999
				message = "failed to create target directory", -- 2999
				cleanupError = cleanupError -- 2999
			}) -- 2999
		end -- 2999
		if not Content:move(tempPath, target) then -- 2999
			local cleanupError = cleanupPath(tempPath) -- 3002
			return ____awaiter_resolve(nil, { -- 3002
				success = false, -- 3003
				state = "failed", -- 3003
				mode = mode, -- 3003
				target = targetRel, -- 3003
				message = "failed to move downloaded file into target path", -- 3003
				cleanupError = cleanupError -- 3003
			}) -- 3003
		end -- 3003
		local bytesWritten = downloadRes.bytesWritten -- 3005
		local ____try = __TS__AsyncAwaiter(function() -- 3005
			local size = Content:getAttr(target) -- 3007
			if bytesWritten == nil or bytesWritten <= 0 then -- 3007
				bytesWritten = type(size) == "number" and size or nil -- 3009
			end -- 3009
		end) -- 3009
		____try = ____try.catch( -- 3009
			____try, -- 3009
			function(____, _) -- 3009
				return __TS__AsyncAwaiter(function() -- 3009
				end) -- 3009
			end -- 3009
		) -- 3009
		__TS__Await(____try) -- 3006
		if bytesWritten == nil or bytesWritten <= 0 then -- 3006
			local ____try = __TS__AsyncAwaiter(function() -- 3006
				local loaded = Content:load(target) -- 3016
				if type(loaded) == "string" then -- 3016
					bytesWritten = #loaded -- 3018
				end -- 3018
			end) -- 3018
			____try = ____try.catch( -- 3018
				____try, -- 3018
				function(____, _) -- 3018
					return __TS__AsyncAwaiter(function() -- 3018
					end) -- 3018
				end -- 3018
			) -- 3018
			__TS__Await(____try) -- 3015
		end -- 3015
		if not syncDownloadedFileToWebIDE(target) then -- 3015
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 3025
		end -- 3025
		return ____awaiter_resolve(nil, { -- 3025
			success = true, -- 3027
			state = "done", -- 3027
			mode = mode, -- 3027
			target = targetRel, -- 3027
			bytesWritten = bytesWritten -- 3027
		}) -- 3027
	end) -- 3027
end -- 2919
return ____exports -- 2919