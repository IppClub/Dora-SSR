local CLI = Dora.CLI
local json = require("json")

local defaultHost = "127.0.0.1"
local defaultPort = 8866
local defaultTimeout = 30

local apiFiles = {
	["BlocklyGen.d.ts"] = true,
	["flow.d.ts"] = true,
	["Config.d.ts"] = true,
	["Dora.d.ts"] = true,
	["DoraX.d.ts"] = true,
	["es6-subset.d.ts"] = true,
	["ImGui.d.ts"] = true,
	["InputManager.d.ts"] = true,
	["jsx.d.ts"] = true,
	["lua.d.ts"] = true,
	["nvg.d.ts"] = true,
	["Platformer.d.ts"] = true,
	["PlatformerX.d.ts"] = true,
	["YarnRunner.d.ts"] = true,
	["Button.d.ts"] = true,
	["CircleButton.d.ts"] = true,
	["Ruler.d.ts"] = true,
	["ScrollArea.d.ts"] = true,
	["Circle.d.ts"] = true,
	["LineRect.d.ts"] = true,
	["Rectangle.d.ts"] = true,
	["Star.d.ts"] = true,
	["Utils.d.ts"] = true,
	["tic80.d.ts"] = true,
}

local ignoredDirs = {
	[".build"] = true,
	[".cache"] = true,
	[".download"] = true,
	[".git"] = true,
	[".upload"] = true,
	[".www"] = true,
	API = true,
	build = true,
	dist = true,
	node_modules = true,
	target = true,
	vendor = true,
}

local function fail(message)
	error(message, 0)
end

local function help()
	print([[
Usage: dora cli <command> [options]

Commands:
	ts install [-p project] [-l zh-Hans|en]
	wa install [-p project]
	build [-p project] [-f file] [--lang all|ts|yue|tl|xml|wa|yarn]
	run [-p project] [--entry init.lua]
	buildrun [-p project] [-f file] [--lang ...] [--entry init.lua]
	stop
	status [-p project]
	doctor [-p project] [--fix]
	log [-n lines]
	doc search <pattern> [-l zh-Hans|en] [--source api|tutorial] [--lang ts|tsx|lua|yue|tl|wa] [-n limit]
	doc read <file> [-l zh-Hans|en] [--start line] [--end line]
	rust build [-p project]
	rust run <target-path> [-p project]
	rust upload <target-path> [-p project] [--run]

Connection options: --host, --port, --timeout
]])
end

local function isHelpArg(arg)
	return arg == "-h" or arg == "--help"
end

local function toolchainHelp(kind, action)
	if kind == "ts" then
		if action == "install" then
			print([[
Usage: dora cli ts install [-p project] [-l zh-Hans|en]

Install or update Dora TypeScript API definitions.
]])
		else
			print([[
Usage: dora cli ts <command> [options]

Commands:
	install [-p project] [-l zh-Hans|en]
]])
		end
	elseif kind == "wa" then
		if action == "install" then
			print([[
Usage: dora cli wa install [-p project]

Install or update Dora Wa project files and vendor/dora.
]])
		else
			print([[
Usage: dora cli wa <command> [options]

Commands:
	install [-p project]
]])
		end
	elseif kind == "rust" then
		if action == "build" then
			print([[
Usage: dora cli rust build [-p project]

Build a Rust WASM project.
]])
		elseif action == "run" then
			print([[
Usage: dora cli rust run <target-path> [-p project]

Build, upload, and run a Rust WASM project.
]])
		elseif action == "upload" then
			print([[
Usage: dora cli rust upload <target-path> [-p project] [--run]

Upload an already-built Rust WASM file, optionally running it.
]])
		else
			print([[
Usage: dora cli rust <command> [options]

Commands:
	build [-p project]
	run <target-path> [-p project]
	upload <target-path> [-p project] [--run]
]])
		end
	else
		help()
	end
end

local function docHelp(action)
	if action == "search" then
		print([[
Usage: dora cli doc search <pattern> [-l zh-Hans|en] [--source api|tutorial] [--lang ts|tsx|lua|yue|tl|wa] [-n limit]

Search Dora SSR API docs or tutorials.
Use | inside pattern to search alternatives.
]])
	elseif action == "read" then
		print([[
Usage: dora cli doc read <file> [-l zh-Hans|en] [--start line] [--end line]

Read a Dora SSR doc file returned by doc search.
]])
	else
		print([[
Usage: dora cli doc <command> [options]

Commands:
	search <pattern> [-l zh-Hans|en] [--source api|tutorial] [--lang ts|tsx|lua|yue|tl|wa] [-n limit]
	read <file> [-l zh-Hans|en] [--start line] [--end line]
]])
	end
end

local function pathJoin(...)
	local parts = {...}
	local out = {}
	for _, part in ipairs(parts) do
		part = tostring(part):gsub("\\", "/")
		if part ~= "" then
			if #out == 0 then
				out[#out + 1] = part:gsub("/+$", "")
			else
				out[#out + 1] = part:gsub("^/+", ""):gsub("/+$", "")
			end
		end
	end
	return table.concat(out, "/")
end

local function filename(path)
	return (path:gsub("\\", "/"):match("([^/]+)$") or path)
end

local function stem(path)
	return (filename(path):match("(.+)%.[^%.]+$") or filename(path))
end

local function dirname(path)
	return (path:gsub("\\", "/"):match("^(.*)/[^/]*$") or "")
end

local function extension(path)
	return (filename(path):match("%.([^%.]+)$") or ""):lower()
end

local function startsWith(text, prefix)
	return text:sub(1, #prefix) == prefix
end

local function isAbs(path)
	return path:match("^/") or path:match("^%a:[/\\]")
end

local function resolve(project, target)
	if not target or target == "" then
		return CLI.absolute(project)
	end
	if isAbs(target) then
		return CLI.absolute(target)
	end
	return CLI.absolute(pathJoin(project, target))
end

local function assetRoot()
	return dirname(dirname(dirname(CLI.scriptPath)))
end

local function relativeToRoot(path, root)
	if not root or root == "" then
		return nil
	end
	local fullPath = CLI.absolute(path):gsub("\\", "/"):gsub("/+$", "")
	local fullRoot = CLI.absolute(root):gsub("\\", "/"):gsub("/+$", "")
	if fullPath == fullRoot then
		return ""
	end
	local prefix = fullRoot .. "/"
	if startsWith(fullPath, prefix) then
		return fullPath:sub(#prefix + 1)
	end
	return nil
end

local function serverPath(path)
	local roots = {}
	if Content then
		roots[#roots + 1] = Content.assetPath
		roots[#roots + 1] = Content.writablePath
	end
	roots[#roots + 1] = assetRoot()
	for _, root in ipairs(roots) do
		local relative = relativeToRoot(path, root)
		if relative ~= nil then
			return relative
		end
	end
	return CLI.absolute(path):gsub("\\", "/")
end

local function parseNumber(value, fallback)
	value = tonumber(value)
	if value == nil then
		return fallback
	end
	return value
end

local function parseOptions(args, index)
	local options = {
		host = CLI.env("DORA_HOST", defaultHost),
		port = parseNumber(CLI.env("DORA_PORT", tostring(defaultPort)), defaultPort),
		timeout = parseNumber(CLI.env("DORA_TIMEOUT", tostring(defaultTimeout)), defaultTimeout),
		project = CLI.absolute(CLI.env("DORA_PROJECT", CLI.cwd())),
		language = "zh-Hans",
		languageProvided = false,
		entry = "init.lua",
		lang = "all",
		langProvided = false,
		docSource = "tutorial",
		docCode = nil,
		json = false,
		startLine = nil,
		endLine = nil,
		files = {},
		runAfterUpload = false,
		fix = false,
	}
	while index <= #args do
		local arg = args[index]
		if arg == "-p" or arg == "--project" then
			index = index + 1
			if index > #args then fail(arg .. " expects a value") end
			options.project = CLI.absolute(args[index])
			index = index + 1
		elseif arg == "--host" then
			index = index + 1
			if index > #args then fail("--host expects a value") end
			options.host = args[index]
			index = index + 1
		elseif arg == "--port" then
			index = index + 1
			if index > #args then fail("--port expects a value") end
			options.port = tonumber(args[index]) or fail("--port expects a number")
			index = index + 1
		elseif arg == "--timeout" then
			index = index + 1
			if index > #args then fail("--timeout expects a value") end
			options.timeout = tonumber(args[index]) or fail("--timeout expects a number")
			index = index + 1
		elseif arg == "-n" then
			index = index + 1
			if index > #args then fail("-n expects a value") end
			options.logLines = tonumber(args[index]) or fail("-n expects a number")
			index = index + 1
		elseif arg == "-l" or arg == "--language" then
			index = index + 1
			if index > #args then fail(arg .. " expects a value") end
			options.language = args[index]
			options.languageProvided = true
			index = index + 1
		elseif arg == "--entry" then
			index = index + 1
			if index > #args then fail("--entry expects a value") end
			options.entry = args[index]
			index = index + 1
		elseif arg == "-f" or arg == "--file" then
			index = index + 1
			if index > #args then fail(arg .. " expects a value") end
			options.files[#options.files + 1] = args[index]
			index = index + 1
		elseif arg == "--lang" then
			index = index + 1
			if index > #args then fail("--lang expects a value") end
			options.lang = args[index]
			options.langProvided = true
			index = index + 1
		elseif arg == "--source" or arg == "--doc-source" then
			index = index + 1
			if index > #args then fail(arg .. " expects a value") end
			options.docSource = args[index]
			index = index + 1
		elseif arg == "--code" then
			index = index + 1
			if index > #args then fail("--code expects a value") end
			options.docCode = args[index]
			index = index + 1
		elseif arg == "--start" or arg == "--start-line" then
			index = index + 1
			if index > #args then fail(arg .. " expects a value") end
			options.startLine = tonumber(args[index]) or fail(arg .. " expects a number")
			index = index + 1
		elseif arg == "--end" or arg == "--end-line" then
			index = index + 1
			if index > #args then fail(arg .. " expects a value") end
			options.endLine = tonumber(args[index]) or fail(arg .. " expects a number")
			index = index + 1
		elseif arg == "--json" then
			options.json = true
			index = index + 1
		elseif arg == "--run" then
			options.runAfterUpload = true
			index = index + 1
		elseif arg == "--fix" then
			options.fix = true
			index = index + 1
		else
			break
		end
	end
	return options, index
end

local function parseOptionsExact(args, index)
	local options, nextIndex = parseOptions(args, index)
	if nextIndex <= #args then
		fail("Unexpected argument: " .. tostring(args[nextIndex]))
	end
	return options
end

local function ensureProject(options)
	if not CLI.exists(options.project) then
		fail("Project directory does not exist: " .. options.project)
	end
	if not CLI.isDir(options.project) then
		fail("Project path is not a directory: " .. options.project)
	end
	return options.project
end

local function findProjectRoot(start, isDir)
	local dir = CLI.absolute(isDir and start or dirname(start)):gsub("\\", "/"):gsub("/+$", "")
	while dir and dir ~= "" do
		for _, entry in ipairs(CLI.listDir(dir)) do
			if entry.isFile and stem(entry.name):lower() == "init" then
				return dir
			end
		end
		local parent = dirname(dir)
		if not parent or parent == "" or parent == dir then
			break
		end
		dir = parent
	end
	return nil
end

local function projectRootFor(project, target, targetIsDir)
	return findProjectRoot(target, targetIsDir) or findProjectRoot(project, true) or project
end

local function baseUrl(options)
	return "http://" .. options.host .. ":" .. tostring(options.port)
end

local function tryPostJson(options, path, data, timeout)
	local body = json.encode(data or {})
	local res = CLI.http("POST", baseUrl(options) .. path, {["Content-Type"] = "application/json"}, body, timeout or options.timeout)
	if res.netStatus ~= 0 or res.statusCode < 200 or res.statusCode >= 400 then
		return nil, ("Request failed: %s%s (network=%s, http=%d)"):format(baseUrl(options), path, res.netStatusName, res.statusCode)
	end
	local decoded, err = json.decode(res.body)
	if decoded == nil then
		return nil, "Invalid JSON response from " .. path .. ": " .. tostring(err)
	end
	return decoded
end

local function postJson(options, path, data)
	local decoded, err = tryPostJson(options, path, data)
	if decoded == nil then fail(err) end
	return decoded
end

local function expectSuccess(doc, prefix)
	if type(doc) ~= "table" or doc.success ~= true then
		fail(prefix .. " " .. tostring(doc and (doc.message or doc.err) or "Unknown error."))
	end
end

local function buildableSource(path, kind)
	if kind == "tl" then
		return not filename(path):find("%.d%.tl$")
	end
	if kind == "ts" then
		return not filename(path):find("%.d%.ts$")
	end
	return true
end

local function sourceFiles(project, kind)
	local files = {}
	local wantExt = kind
	local function scan(dir)
		local entries = CLI.listDir(dir)
		table.sort(entries, function(a, b) return a.path < b.path end)
		for _, entry in ipairs(entries) do
			if entry.isDir then
				if not ignoredDirs[entry.name] then
					scan(entry.path)
				end
			elseif entry.isFile and extension(entry.path) == wantExt and buildableSource(entry.path, kind) then
				files[#files + 1] = CLI.absolute(entry.path)
			end
		end
	end
	scan(project)
	table.sort(files)
	return files
end

local function buildFileKinds(lang)
	if lang == "all" then
		return {"ts", "tsx", "yue", "tl", "xml", "wa", "yarn"}
	elseif lang == "ts" then
		return {"ts", "tsx"}
	elseif lang == "yue" or lang == "tl" or lang == "xml" or lang == "wa" or lang == "yarn" then
		return {lang}
	else
		fail("Unsupported build language: " .. tostring(lang))
	end
end

local function collectBuildFiles(project, lang)
	local files = {}
	for _, kind in ipairs(buildFileKinds(lang)) do
		for _, file in ipairs(sourceFiles(project, kind)) do
			files[#files + 1] = file
		end
	end
	table.sort(files)
	return files
end

local function inferBuildKind(project, target)
	if target and target ~= "" then
		local ext = extension(target)
		if ext == "ts" or ext == "tsx" then return "ts" end
		if ext == "yue" or ext == "tl" or ext == "xml" or ext == "wa" or ext == "yarn" then return ext end
		fail("Cannot infer build language from file extension: " .. target)
	end
	return "all"
end

local function buildTs(options, project, target)
	local buildTarget = resolve(project, target or "")
	print("Compiling Dora SSR TypeScript project: " .. buildTarget)
	local doc = postJson(options, "/ts/build", {
		path = buildTarget:gsub("\\", "/"),
		projectRoot = projectRootFor(project, buildTarget, CLI.isDir(buildTarget)):gsub("\\", "/"),
	})
	expectSuccess(doc, "Compilation failed.")
	print("Compilation complete.")
	if type(doc.messages) == "table" then
		for _, item in ipairs(doc.messages) do
			if item.success and item.file then
				print("[info] " .. item.file .. " built.")
			elseif item.message then
				print("[error] " .. item.message)
			end
		end
	end
end

local function buildScriptFile(options, project, kind, target)
	local defaults = {yue = "init.yue", tl = "init.tl", xml = "init.xml"}
	local source = resolve(project, target and target ~= "" and target or defaults[kind])
	if extension(source) ~= kind then
		fail(("%s build expects a .%s file: %s"):format(kind, kind, source))
	end
	if not buildableSource(source, kind) then
		fail(("%s build does not accept definition files: %s"):format(kind, source))
	end
	print("Compiling Dora SSR " .. kind .. " file: " .. source)
	local doc = postJson(options, "/build", {
		path = serverPath(source),
		projectRoot = projectRootFor(project, source, false):gsub("\\", "/"),
	})
	expectSuccess(doc, "Compilation failed.")
	print("Compilation complete.")
end

local function updateWaVendor(options, project)
	print("Updating Wa vendor/dora from engine template...")
	local doc = postJson(options, "/wa/update_dora", {path = project})
	expectSuccess(doc, "Failed to update Wa vendor/dora.")
	print("Wa vendor/dora updated.")
end

local function buildWa(options, project, target)
	local buildTarget = resolve(project, target or "")
	print("Compiling Dora SSR Wa project: " .. buildTarget)
	local doc = postJson(options, "/build", {path = buildTarget:gsub("\\", "/")})
	expectSuccess(doc, "Compilation failed.")
	print("Compilation complete.")
end

local function checkYarn(options, project, target)
	local source = resolve(project, target or "")
	if extension(source) ~= "yarn" then
		fail("Yarn check expects a .yarn file: " .. source)
	end
	local content, err = CLI.readFile(source)
	if content == nil then fail(err) end
	print("Checking Dora SSR Yarn file: " .. source)
	local doc = postJson(options, "/yarn/check-file", {code = content})
	if type(doc) ~= "table" or doc.success ~= true then
		local parts = {source}
		if doc and doc.node then parts[#parts + 1] = "node " .. tostring(doc.node) end
		if doc and doc.line then
			local location = "line " .. tostring(doc.line)
			if doc.column then location = location .. ", column " .. tostring(doc.column) end
			parts[#parts + 1] = location
		end
		local message = doc and (doc.message or doc.err) or "Unknown error."
		fail("Yarn check failed: " .. table.concat(parts, ": ") .. ": " .. tostring(message))
	end
	print("Yarn check complete.")
end

local function isWaProject(project)
	return CLI.exists(pathJoin(project, "wa.mod"))
end

local function waMod()
	return [[name = "init"
pkgpath = "dora_wa"
target = "wasi"
]]
end

local function waMain()
	return [[import "dora"

func init {
	sprite := dora.NewSpriteWithTexture(dora.Nvg.GetDoraSsr(1.0))
	sprite.SetWidth(400)
	sprite.SetHeight(400)

	root := dora.NewNode()
	root.AddChild(sprite.Node)
	root.OnTapBegan(func(touch: dora.Touch) {
		sprite.PerformDef(dora.ActionDefMoveTo(
			1.0,
			sprite.GetPosition(),
			touch.GetLocation(),
			dora.EaseOutBack,
		), false)
	})
}
]]
end

local function writeNewFile(path, content)
	if CLI.exists(path) then
		fail("File already exists: " .. path)
	end
	CLI.writeFile(path, content)
end

local function initWaProject(options, project)
	if CLI.exists(project) and not CLI.isDir(project) then
		fail("Project path is not a directory: " .. project)
	end
	local isNewProject = not CLI.exists(project)
	CLI.mkdirs(project)
	CLI.mkdirs(pathJoin(project, "src"))
	if isNewProject then
		writeNewFile(pathJoin(project, "wa.mod"), waMod())
		writeNewFile(pathJoin(project, "src/main.wa"), waMain())
		print("Wa project initialized in " .. project .. ".")
	elseif not CLI.exists(pathJoin(project, "wa.mod")) then
		writeNewFile(pathJoin(project, "wa.mod"), waMod())
		if not CLI.exists(pathJoin(project, "src/main.wa")) then
			writeNewFile(pathJoin(project, "src/main.wa"), waMain())
		end
		print("Wa module file written to " .. pathJoin(project, "wa.mod") .. ".")
	end
	updateWaVendor(options, project)
end

local function buildOne(options, project, kind, target)
	if kind == "all" then
		for _, file in ipairs(collectBuildFiles(project, "all")) do
			buildOne(options, project, inferBuildKind(project, file), file)
		end
	elseif kind == "ts" then
		buildTs(options, project, target)
	elseif kind == "wa" then
		buildWa(options, project, target)
	elseif kind == "yarn" then
		if target and target ~= "" then
			checkYarn(options, project, target)
		else
			local files = sourceFiles(project, kind)
			if #files == 0 then
				print("No " .. kind .. " files found.")
			end
			for _, file in ipairs(files) do
				checkYarn(options, project, file)
			end
		end
	elseif kind == "yue" or kind == "tl" or kind == "xml" then
		if target and target ~= "" then
			buildScriptFile(options, project, kind, target)
		else
			local files = sourceFiles(project, kind)
			if #files == 0 then
				print("No " .. kind .. " files found.")
			end
			for _, file in ipairs(files) do
				buildScriptFile(options, project, kind, file)
			end
		end
	else
		fail("Unsupported build language: " .. tostring(kind))
	end
end

local function runBuild(options)
	local project = ensureProject(options)
	if #options.files > 0 then
		for _, target in ipairs(options.files) do
			local kind = options.lang == "all" and inferBuildKind(project, target) or options.lang
			buildOne(options, project, kind, target)
		end
		return
	end
	local files = collectBuildFiles(project, options.lang)
	if #files == 0 then
		fail("No supported source files found for --lang " .. tostring(options.lang) .. ".")
	end
	for _, target in ipairs(files) do
		buildOne(options, project, inferBuildKind(project, target), target)
	end
end

local findLatestWasm
local runLocalFile

local function runProject(options)
	local project = ensureProject(options)
	local asProject = options.entry == "init.lua"
	if asProject and isWaProject(project) then
		buildWa(options, project)
		runLocalFile(options, findLatestWasm("wa", project))
		return
	end
	local runFile = asProject and pathJoin(project, "__dora_project_root_search__.lua") or resolve(project, options.entry)
	local doc = postJson(options, "/run", {
		file = runFile:gsub("\\", "/"),
		asProj = asProject,
		projectRoot = projectRootFor(project, runFile, false):gsub("\\", "/"),
	})
	expectSuccess(doc, "Failed to run project at " .. project .. ".")
	print("Start running " .. tostring(doc.target or options.entry) .. "...")
end

local function runBuildRun(options)
	local project = ensureProject(options)
	if options.entry == "init.lua" and #options.files == 0 and options.lang == "all" and isWaProject(project) then
		runProject(options)
		return
	end
	runBuild(options)
	runProject(options)
end

local function stopProject(options)
	local doc = postJson(options, "/stop", {})
	if type(doc) == "table" and doc.success == true then
		print("Stopped running.")
	else
		print("No running project.")
	end
end

local function isLocalHost(host)
	return host == "127.0.0.1" or host == "localhost" or host == "::1"
end

local function shellQuote(value)
	value = tostring(value)
	if package.config:sub(1, 1) == "\\" then
		return '"' .. value:gsub('"', '\\"') .. '"'
	end
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function appBundlePath(executable)
	local path = executable:gsub("\\", "/")
	local app = path:match("^(.-%.app)/Contents/MacOS/[^/]+$")
	return app
end

local function startNativeEngine()
	local executable = CLI.executablePath
	if not executable or executable == "" then
		fail("Cannot start native engine: CLI executable path is unavailable.")
	end
	local assets = assetRoot()
	local command
	if package.config:sub(1, 1) == "\\" then
		command = ("start \"\" %s --asset %s"):format(shellQuote(executable), shellQuote(assets))
	elseif appBundlePath(executable) then
		command = ("open -n %s --args --asset %s"):format(shellQuote(appBundlePath(executable)), shellQuote(assets))
	else
		command = ("nohup %s --asset %s >/dev/null 2>&1 &"):format(shellQuote(executable), shellQuote(assets))
	end
	return CLI.system(command, dirname(executable))
end

local function waitOneSecond()
	if package.config:sub(1, 1) == "\\" then
		CLI.system("timeout /t 1 /nobreak >nul")
	else
		CLI.system("sleep 1")
	end
end

local function waitForStatus(options, seconds)
	for _ = 1, seconds do
		local doc = tryPostJson(options, "/status", {}, 1)
		if doc then return doc end
		waitOneSecond()
	end
	return nil
end

local function statusText(value)
	return value and "yes" or "no"
end

local function printDoctorField(name, value)
	print(name .. ": " .. tostring(value == nil and "unknown" or value))
end

local function initFilesIn(dir)
	local files = {}
	if not dir or dir == "" or not CLI.exists(dir) or not CLI.isDir(dir) then
		return files
	end
	for _, entry in ipairs(CLI.listDir(dir)) do
		if entry.isFile and stem(entry.name):lower() == "init" then
			files[#files + 1] = entry.name
		end
	end
	table.sort(files)
	return files
end

local function joinList(items)
	return #items > 0 and table.concat(items, ", ") or "no"
end

local function printDoctorCliContext(options)
	print("CLI:")
	printDoctorField("  Executable", CLI.executablePath)
	printDoctorField("  Script", CLI.scriptPath)
	printDoctorField("  CWD", CLI.cwd())
	printDoctorField("  CLI asset root", assetRoot())
	if Content and Content.assetPath then
		printDoctorField("  --asset", Content.assetPath)
	end
	printDoctorField("  Project option", options.project)
end

local function printDoctorProject(options)
	local project = options.project
	print("Project:")
	print("  Path exists: " .. statusText(CLI.exists(project)))
	print("  Is directory: " .. statusText(CLI.exists(project) and CLI.isDir(project)))
	if not CLI.exists(project) or not CLI.isDir(project) then
		return
	end
	local projectRoot = findProjectRoot(project, true)
	printDoctorField("  Project root", projectRoot or "not found")
	local root = projectRoot or project
	print("  Init files: " .. joinList(initFilesIn(root)))
	local scriptDir = pathJoin(root, "Script")
	print("  Script dir: " .. statusText(CLI.exists(scriptDir) and CLI.isDir(scriptDir)) .. " (" .. scriptDir .. ")")
	print("  wa.mod: " .. statusText(CLI.exists(pathJoin(root, "wa.mod"))))
	print("  tsconfig.json: " .. statusText(CLI.exists(pathJoin(root, "tsconfig.json"))))
	print("  API dir: " .. statusText(CLI.exists(pathJoin(root, "API")) and CLI.isDir(pathJoin(root, "API"))))
	local buildDir = pathJoin(root, ".build")
	if CLI.exists(buildDir) then
		print("  .build dir: " .. statusText(CLI.isDir(buildDir)) .. " (" .. buildDir .. ")")
	else
		print("  .build dir: no (" .. buildDir .. ")")
	end
end

local function runLog(options)
	local count = options.logLines or 20
	if count < 1 or count ~= math.floor(count) then
		fail("-n expects a positive integer")
	end
	local doc = postJson(options, "/log", {count = count})
	expectSuccess(doc, "Log failed.")
	io.write(tostring(doc.log or ""))
end

local function docLanguage(options)
	if not options.languageProvided then
		return "en"
	end
	if options.language == "zh" then
		return "zh-Hans"
	end
	if options.language == "zh-Hans" or options.language == "en" then
		return options.language
	end
	fail("Unsupported doc language: " .. tostring(options.language))
end

local function docProgrammingLanguage(options)
	local language
	if options.docCode and options.docCode ~= "" then
		language = options.docCode
	elseif options.langProvided then
		language = options.lang
	else
		language = "ts"
	end
	if language == "teal" then
		return "tl"
	end
	if language == "ts" or language == "tsx" or language == "lua" or language == "yue" or language == "tl" or language == "wa" then
		return language
	end
	fail("Unsupported doc code language: " .. tostring(language))
end

local function docSource(options)
	if options.docSource == "api" or options.docSource == "tutorial" then
		return options.docSource
	end
	fail("Unsupported doc source: " .. tostring(options.docSource))
end

local function printDocSearchResults(doc)
	local results = doc.results or {}
	if #results == 0 then
		print("No doc results found.")
		return
	end
	for i, item in ipairs(results) do
		local location = tostring(item.file or "")
		if item.line then
			location = location .. ":" .. tostring(item.line)
		end
		print(("%d. %s"):format(i, location))
		if item.content and item.content ~= "" then
			print("   " .. tostring(item.content):gsub("\n", "\n   "))
		end
	end
	if doc.truncated then
		print("Results truncated.")
	end
end

local function runDocCommand(args)
	local action = args[2]
	if not action or isHelpArg(action) then
		docHelp()
		return
	end
	if isHelpArg(args[3]) then
		docHelp(action)
		return
	end
	if action == "search" then
		local pattern = args[3] or fail("Missing search pattern.")
		local options = parseOptionsExact(args, 4)
		local limit = options.logLines or 10
		if limit < 1 or limit ~= math.floor(limit) then
			fail("-n expects a positive integer")
		end
		local doc = postJson(options, "/doc/search", {
			pattern = pattern,
			docLanguage = docLanguage(options),
			docSource = docSource(options),
			programmingLanguage = docProgrammingLanguage(options),
			limit = limit,
			includeContent = true,
			contentWindow = 100,
		})
		expectSuccess(doc, "Doc search failed.")
		if options.json then
			print(json.encode(doc))
		else
			printDocSearchResults(doc)
		end
	elseif action == "read" then
		local file = args[3] or fail("Missing doc file.")
		local options = parseOptionsExact(args, 4)
		local doc = postJson(options, "/doc/read", {
			file = file,
			docLanguage = docLanguage(options),
			startLine = options.startLine or 1,
			endLine = options.endLine or -1,
		})
		expectSuccess(doc, "Doc read failed.")
		if options.json then
			print(json.encode(doc))
		else
			io.write(tostring(doc.content or ""))
			if tostring(doc.content or ""):sub(-1) ~= "\n" then
				io.write("\n")
			end
		end
	else
		fail("Unsupported doc command: " .. tostring(action) .. ". Run Dora cli doc --help.")
	end
end

local function runDoctor(options, diagnose)
	if diagnose then
		printDoctorCliContext(options)
		printDoctorProject(options)
	end
	print("Checking Dora SSR service at " .. baseUrl(options) .. "...")
	local doc, err = tryPostJson(options, "/status", {}, math.min(options.timeout, 2))
	local nativeStarted = false
	if doc == nil then
		print("Native engine: no")
		if options.fix and diagnose then
			if not isLocalHost(options.host) then
				fail("doctor --fix can only start a local Dora service. Use --host 127.0.0.1 or start the native engine manually.")
			end
			print("Starting native Dora engine...")
			local result = startNativeEngine()
			if result ~= 0 then
				fail("Failed to start native Dora engine.")
			end
			nativeStarted = true
			doc = waitForStatus(options, 10)
			if doc == nil then
				fail("Native Dora engine was started, but the Web IDE service did not become ready.")
			end
		else
			print("Service error: " .. tostring(err))
			if diagnose then
				print("Hint: run Dora cli doctor --fix to start the local native engine.")
			end
			return
		end
	else
		print("Native engine: yes")
	end
	expectSuccess(doc, "Doctor failed.")
	if diagnose then
		print("Service:")
	end
	print("Dora SSR: " .. tostring(doc.version or "unknown") .. " on " .. tostring(doc.platform or "unknown"))
	print("Web IDE URL: " .. tostring(doc.url or "unavailable"))
	print("Web IDE connected: " .. statusText(doc.webIDEConnected) .. " (" .. tostring(doc.wsConnectionCount or 0) .. ")")
	if diagnose then
		printDoctorField("Asset path", doc.assetPath)
		printDoctorField("Writable path", doc.writablePath)
		printDoctorField("App path", doc.appPath)
	end
	if type(doc.running) == "table" and doc.running.running then
		print("Running: " .. tostring(doc.running.kind or "file") .. " " .. tostring(doc.running.fileName or doc.running.entryName or ""))
	else
		print("Running: no")
	end
	if diagnose then
		print("Tooling:")
		print("Wa template: " .. statusText(doc.waTemplateReady))
	end
	if options.fix then
		if not doc.webIDEConnected then
			if not isLocalHost(options.host) then
				fail("doctor --fix can only open Web IDE for a local Dora service. Use --host 127.0.0.1 or open the Web IDE URL manually.")
			end
			local fixed = postJson(options, "/doctor/fix", {openWebIDE = true, waitSeconds = 3})
			expectSuccess(fixed, "Doctor fix failed.")
			if nativeStarted then
				print("Native engine started.")
			end
			print(tostring(fixed.message or "Doctor fix complete."))
		elseif nativeStarted then
			print("Native engine started.")
		else
			print("No fix needed.")
		end
	elseif diagnose and not doc.webIDEConnected then
		print("Hint: run Dora cli doctor --fix to open the local Web IDE.")
	end
end

local function tsConfig()
	return [[
{
	"compilerOptions": {
		"jsx": "react",
		"target": "ESNext",
		"module": "ESNext",
		"strict": true,
		"esModuleInterop": false,
		"skipLibCheck": true,
		"forceConsistentCasingInFileNames": true,
		"allowSyntheticDefaultImports": true,
		"rootDir": "./",
		"typeRoots": ["API"],
		"types": ["Dora"]
	},
	"include": ["**/*.ts", "**/*.tsx"],
	"exclude": ["node_modules", "dist"]
}
]]
end

local function collectApiTargets(node, builtinKey, language, out)
	if type(node) ~= "table" then return end
	if node.dir then
		if type(node.children) == "table" then
			for _, child in ipairs(node.children) do
				collectApiTargets(child, builtinKey, language, out)
			end
		end
		return
	end
	if type(node.title) ~= "string" or type(node.key) ~= "string" or not apiFiles[node.title] then
		return
	end
	local key = node.key
	local normalized = key:gsub("\\", "/")
	if normalized:find("Script/Lib/Dora", 1, true) then
		if normalized:find("Script/Lib/Dora/" .. language, 1, true) then
			out[#out + 1] = {relative = node.title, key = key}
		end
		return
	end
	local prefix = builtinKey .. "/Script/Lib/"
	local pos = key:find(prefix, 1, true)
	out[#out + 1] = {relative = pos and key:sub(pos + #prefix) or node.title, key = key}
end

local function installTsProject(options)
	local project = ensureProject(options)
	print("Installing Dora SSR TypeScript support in " .. project .. "...")
	local assets = postJson(options, "/assets", {})
	if type(assets.children) ~= "table" or type(assets.children[1]) ~= "table" or type(assets.children[1].key) ~= "string" then
		fail("Unexpected /assets response: missing builtin asset tree.")
	end
	local targets = {}
	collectApiTargets(assets.children[1], assets.children[1].key, options.language, targets)
	local apiDir = pathJoin(project, "API")
	CLI.mkdirs(apiDir)
	for _, target in ipairs(targets) do
		local read = postJson(options, "/read", {path = target.key})
		expectSuccess(read, "Failed to read " .. target.key)
		CLI.writeFile(pathJoin(apiDir, target.relative), read.content or "")
	end
	local tsconfigPath = pathJoin(project, "tsconfig.json")
	if not CLI.exists(tsconfigPath) then
		CLI.writeFile(tsconfigPath, tsConfig())
		print("TypeScript config written to " .. tsconfigPath)
	end
	print("API files written to " .. apiDir)
end

local function buildWasm(kind, project)
	local command
	if kind == "rust" then
		command = "cargo build --release --target wasm32-wasip1"
	else
		fail("Unsupported WASM toolchain: " .. tostring(kind))
	end
	print("Compiling " .. kind .. " project in " .. project .. "...")
	local result = CLI.system(command, project)
	if result ~= 0 then
		fail(kind .. " compilation failed.")
	end
	print("Compilation complete.")
end

findLatestWasm = function(kind, project)
	local latest, latestTime = nil, 0
	local buildDirs = kind == "rust"
		and {pathJoin(project, "target/wasm32-wasip1/release")}
		or {project, pathJoin(project, "output")}
	local function scan(dir)
		if not CLI.exists(dir) then
			return
		end
		for _, entry in ipairs(CLI.listDir(dir)) do
			if entry.isDir then
				scan(entry.path)
			elseif entry.isFile and extension(entry.path) == "wasm" then
				local time = CLI.mtime(entry.path)
				if latest == nil or time > latestTime then
					latest = entry.path
					latestTime = time
				end
			end
		end
	end
	for _, dir in ipairs(buildDirs) do
		scan(dir)
	end
	if latest == nil then
		fail("No .wasm file found in " .. table.concat(buildDirs, " or ") .. ".")
	end
	print("Found .wasm file: " .. latest)
	return latest
end

local function urlEncode(text)
	return (text:gsub("([^%w%-_%.~])", function(char)
		return ("%%%02X"):format(char:byte())
	end))
end

local function uploadFile(options, file, targetPath)
	local content, err = CLI.readFile(file)
	if content == nil then fail(err) end
	local boundary = "----DoraCliBoundary7MA4YWxkTrZu0gW"
	local body = "--" .. boundary .. "\r\n"
		.. "Content-Disposition: form-data; name=\"file\"; filename=\"" .. filename(file) .. "\"\r\n"
		.. "Content-Type: application/octet-stream\r\n\r\n"
		.. content
		.. "\r\n--" .. boundary .. "--\r\n"
	print("Uploading .wasm file...")
	local res = CLI.http(
		"POST",
		baseUrl(options) .. "/upload?path=" .. urlEncode(targetPath),
		{["Content-Type"] = "multipart/form-data; boundary=" .. boundary},
		body,
		options.timeout)
	if res.netStatus ~= 0 or res.statusCode < 200 or res.statusCode >= 400 then
		fail("Failed to upload file " .. file .. ".")
	end
	local remote = pathJoin(targetPath, filename(file))
	print("File uploaded to " .. remote .. ".")
	return remote
end

local function runRemoteFile(options, remoteFile)
	expectSuccess(postJson(options, "/run", {file = remoteFile, asProj = false}), "Failed to run uploaded file " .. remoteFile)
	print("Started running.")
end

runLocalFile = function(options, file)
	expectSuccess(postJson(options, "/run", {file = file, asProj = false}), "Failed to run file " .. file)
	print("Started running.")
end

local function runToolchainCommand(kind, args)
	local action = args[2]
	if not action or isHelpArg(action) then
		toolchainHelp(kind)
		return
	end
	if isHelpArg(args[3]) then
		toolchainHelp(kind, action)
		return
	end
	if kind == "ts" and action == "install" then
		local options = parseOptionsExact(args, 3)
		installTsProject(options)
	elseif kind == "wa" and action == "install" then
		local options = parseOptionsExact(args, 3)
		initWaProject(options, options.project)
	elseif kind == "rust" and action == "build" then
		local options = parseOptionsExact(args, 3)
		local project = ensureProject(options)
		buildWasm(kind, project)
	elseif kind == "rust" and (action == "run" or action == "upload") then
		local targetPath = args[3] or fail("Missing target path.")
		local options = parseOptionsExact(args, 4)
		local project = ensureProject(options)
		if action == "run" then
			buildWasm(kind, project)
		end
		local remote = uploadFile(options, findLatestWasm(kind, project), targetPath)
		if action == "run" or options.runAfterUpload then
			runRemoteFile(options, remote)
		end
	else
		fail("Unsupported " .. kind .. " command: " .. tostring(action) .. ". Run Dora cli " .. kind .. " --help.")
	end
end

local function main()
	local args = CLI.args
	if #args < 1 or args[1] == "-h" or args[1] == "--help" then
		help()
		return #args < 1 and 1 or 0
	end
	local command = args[1]
	if command == "build" then
		local options = parseOptionsExact(args, 2)
		runBuild(options)
	elseif command == "run" then
		local options = parseOptionsExact(args, 2)
		runProject(options)
	elseif command == "buildrun" then
		local options = parseOptionsExact(args, 2)
		runBuildRun(options)
	elseif command == "stop" then
		local options = parseOptionsExact(args, 2)
		stopProject(options)
	elseif command == "status" then
		local options = parseOptionsExact(args, 2)
		runDoctor(options, false)
	elseif command == "doctor" then
		local options = parseOptionsExact(args, 2)
		runDoctor(options, true)
	elseif command == "log" then
		local options = parseOptionsExact(args, 2)
		runLog(options)
	elseif command == "doc" then
		runDocCommand(args)
	elseif command == "rust" or command == "wa" or command == "ts" then
		runToolchainCommand(command, args)
	else
		help()
		return 1
	end
	return 0
end

local ok, result = xpcall(main, function(err)
	return tostring(err)
end)
if not ok then
	io.stderr:write(result .. "\n")
	return 1
end
return result or 0
