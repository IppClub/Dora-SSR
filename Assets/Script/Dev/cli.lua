local CLI = Dora.CLI
local json = require("json")

local defaultHost = "127.0.0.1"
local defaultPort = 8866
local defaultTimeout = 10

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
  init [-p project] [-l zh-Hans|en]
  build [-p project] [-f file] [--lang auto|all|ts|yue|tl|xml|wa]
  run [-p project] [--entry init.lua]
  buildrun [-p project] [-f file] [--lang ...] [--entry init.lua]
  stop
  status [-p project]
  doctor [-p project] [--fix]
  rust build [-p project]
  rust run <target-path> [-p project]
  rust upload <target-path> [-p project] [--run]
  wa build [-p project]
  wa run [-p project]
  wa init [project] [-p parent]
  wa update [-p project]

Connection options: --host, --port, --timeout
]])
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
		entry = "init.lua",
		lang = "auto",
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
		elseif arg == "-l" or arg == "--language" then
			index = index + 1
			if index > #args then fail(arg .. " expects a value") end
			options.language = args[index]
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

local function baseUrl(options)
	return "http://" .. options.host .. ":" .. tostring(options.port)
end

local function postJson(options, path, data)
	local body = json.encode(data or {})
	local res = CLI.http("POST", baseUrl(options) .. path, {["Content-Type"] = "application/json"}, body, options.timeout)
	if res.netStatus ~= 0 or res.statusCode < 200 or res.statusCode >= 400 then
		fail(("Request failed: %s%s (network=%s, http=%d)"):format(baseUrl(options), path, res.netStatusName, res.statusCode))
	end
	local decoded, err = json.decode(res.body)
	if decoded == nil then
		fail("Invalid JSON response from " .. path .. ": " .. tostring(err))
	end
	return decoded
end

local function expectSuccess(doc, prefix)
	if type(doc) ~= "table" or doc.success ~= true then
		fail(prefix .. " " .. tostring(doc and (doc.message or doc.err) or "Unknown error."))
	end
end

local function buildableSource(path, kind)
	return kind ~= "tl" or not filename(path):find("%.d%.tl$")
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

local function detectBuildKinds(project)
	local kinds = {}
	if CLI.exists(pathJoin(project, "tsconfig.json")) or CLI.exists(pathJoin(project, "init.ts")) or CLI.exists(pathJoin(project, "init.tsx")) then
		kinds[#kinds + 1] = "ts"
	end
	if CLI.exists(pathJoin(project, "wa.mod")) then
		kinds[#kinds + 1] = "wa"
	end
	for _, kind in ipairs({"yue", "tl", "xml"}) do
		if #sourceFiles(project, kind) > 0 then
			kinds[#kinds + 1] = kind
		end
	end
	return kinds
end

local function inferBuildKind(project, target)
	if target and target ~= "" then
		local ext = extension(target)
		if ext == "ts" or ext == "tsx" then return "ts" end
		if ext == "yue" or ext == "tl" or ext == "xml" or ext == "wa" then return ext end
		fail("Cannot infer build language from file extension: " .. target)
	end
	local kinds = detectBuildKinds(project)
	if #kinds == 0 then
		fail("Cannot infer build language. Please specify --lang or pass -f with a supported source file.")
	end
	if #kinds == 1 then return kinds[1] end
	return "all"
end

local function buildTs(options, project, target)
	local buildTarget = resolve(project, target or "")
	print("Compiling Dora SSR TypeScript project: " .. buildTarget)
	local doc = postJson(options, "/ts/build", {path = buildTarget})
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
	local doc = postJson(options, "/build", {path = source})
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
	local doc = postJson(options, "/build", {path = buildTarget})
	expectSuccess(doc, "Compilation failed.")
	print("Compilation complete.")
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
	CLI.mkdirs(project)
	CLI.mkdirs(pathJoin(project, "src"))
	writeNewFile(pathJoin(project, "wa.mod"), waMod())
	writeNewFile(pathJoin(project, "src/main.wa"), waMain())
	print("Wa project initialized in " .. project .. ".")
	updateWaVendor(options, project)
end

local function buildOne(options, project, kind, target)
	if kind == "all" then
		for _, detected in ipairs(detectBuildKinds(project)) do
			buildOne(options, project, detected, target)
		end
	elseif kind == "ts" then
		buildTs(options, project, target)
	elseif kind == "wa" then
		buildWa(options, project, target)
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
			local kind = (options.lang == "auto" or options.lang == "all") and inferBuildKind(project, target) or options.lang
			buildOne(options, project, kind, target)
		end
		return
	end
	local kinds = (options.lang == "auto" or options.lang == "all") and detectBuildKinds(project) or {options.lang}
	if #kinds == 0 then
		fail("Cannot infer build language. Please specify --lang or pass -f with a supported source file.")
	end
	for _, kind in ipairs(kinds) do
		buildOne(options, project, kind)
	end
end

local function runProject(options)
	local project = ensureProject(options)
	local asProject = options.entry == "init.lua"
	local runFile = asProject and pathJoin(project, "__dora_project_root_search__.lua") or resolve(project, options.entry)
	local doc = postJson(options, "/run", {file = runFile, asProj = asProject})
	expectSuccess(doc, "Failed to run project at " .. project .. ".")
	print("Start running " .. tostring(doc.target or options.entry) .. "...")
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

local function statusText(value)
	return value and "yes" or "no"
end

local function runDoctor(options)
	print("Checking Dora SSR service at " .. baseUrl(options) .. "...")
	local doc = postJson(options, "/status", {})
	expectSuccess(doc, "Doctor failed.")
	print("Dora SSR: " .. tostring(doc.version or "unknown") .. " on " .. tostring(doc.platform or "unknown"))
	print("Web IDE URL: " .. tostring(doc.url or "unavailable"))
	print("Web IDE connected: " .. statusText(doc.webIDEConnected) .. " (" .. tostring(doc.wsConnectionCount or 0) .. ")")
	if type(doc.running) == "table" and doc.running.running then
		print("Running: " .. tostring(doc.running.kind or "file") .. " " .. tostring(doc.running.fileName or doc.running.entryName or ""))
	else
		print("Running: no")
	end
	print("Wa template: " .. statusText(doc.waTemplateReady))
	if options.fix then
		if doc.webIDEConnected then
			print("No fix needed.")
		elseif not isLocalHost(options.host) then
			fail("doctor --fix can only open Web IDE for a local Dora service. Use --host 127.0.0.1 or open the Web IDE URL manually.")
		else
			local fixed = postJson(options, "/doctor/fix", {openWebIDE = true})
			expectSuccess(fixed, "Doctor fix failed.")
			print(tostring(fixed.message or "Doctor fix complete."))
		end
	elseif not doc.webIDEConnected then
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

local function initProject(options)
	local project = ensureProject(options)
	print("Initializing Dora SSR TypeScript project in " .. project .. "...")
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
	CLI.writeFile(pathJoin(project, "tsconfig.json"), tsConfig())
	print("API files written to " .. apiDir)
	print("TypeScript config written to " .. pathJoin(project, "tsconfig.json"))
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

local function findLatestWasm(kind, project)
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

local function runLocalFile(options, file)
	expectSuccess(postJson(options, "/run", {file = file, asProj = false}), "Failed to run file " .. file)
	print("Started running.")
end

local function runToolchainCommand(kind, args)
	local action = args[2] or fail("Missing " .. kind .. " command.")
	if action == "build" then
		local options = parseOptionsExact(args, 3)
		local project = ensureProject(options)
		if kind == "wa" then
			buildWa(options, project)
		else
			buildWasm(kind, project)
		end
	elseif kind == "wa" and action == "init" then
		local target = args[3]
		local optionIndex = 3
		if target and not startsWith(target, "-") then
			optionIndex = 4
		else
			target = nil
		end
		local options = parseOptionsExact(args, optionIndex)
		local project = target and resolve(options.project, target) or options.project
		initWaProject(options, project)
	elseif kind == "wa" and action == "update" then
		local options = parseOptionsExact(args, 3)
		updateWaVendor(options, ensureProject(options))
	elseif kind == "wa" and action == "run" then
		local options = parseOptionsExact(args, 3)
		local project = ensureProject(options)
		buildWa(options, project)
		runLocalFile(options, findLatestWasm(kind, project))
	elseif kind == "rust" and (action == "run" or action == "upload") then
		local targetPath = args[3] or fail("Missing target path.")
		local options = parseOptionsExact(args, 4)
		local project = ensureProject(options)
		if action == "run" then
			if kind == "wa" then
				buildWa(options, project)
			else
				buildWasm(kind, project)
			end
		end
		local remote = uploadFile(options, findLatestWasm(kind, project), targetPath)
		if action == "run" or options.runAfterUpload then
			runRemoteFile(options, remote)
		end
	else
		fail("Unsupported " .. kind .. " command: " .. tostring(action))
	end
end

local function main()
	local args = CLI.args
	if #args < 1 or args[1] == "-h" or args[1] == "--help" then
		help()
		return #args < 1 and 1 or 0
	end
	local command = args[1]
	if command == "init" then
		local options = parseOptionsExact(args, 2)
		initProject(options)
	elseif command == "build" then
		local options = parseOptionsExact(args, 2)
		runBuild(options)
	elseif command == "run" then
		local options = parseOptionsExact(args, 2)
		runProject(options)
	elseif command == "buildrun" then
		local options = parseOptionsExact(args, 2)
		runBuild(options)
		runProject(options)
	elseif command == "stop" then
		local options = parseOptionsExact(args, 2)
		stopProject(options)
	elseif command == "status" then
		local options = parseOptionsExact(args, 2)
		runDoctor(options)
	elseif command == "doctor" then
		local options = parseOptionsExact(args, 2)
		runDoctor(options)
	elseif command == "rust" or command == "wa" then
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
