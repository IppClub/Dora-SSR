-- [ts]: CommandContent.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local ____Workspace = require("Agent.Tool.Workspace") -- 3
local isValidWorkspacePath = ____Workspace.isValidWorkspacePath -- 3
local inspectReadableFile = ____Workspace.inspectReadableFile -- 3
local isAgentContentVirtualPath = ____Workspace.isAgentContentVirtualPath -- 3
local resolveAgentContentVirtualPath = ____Workspace.resolveAgentContentVirtualPath -- 3
--- Complete Content facade with project-relative paths and command-local configuration.
function ____exports.createCommandContent(workDir, docLanguage) -- 8
	local assetPath = "." -- 9
	local writablePath = "." -- 10
	local searchPaths = {} -- 11
	local function relative(value) -- 12
		if type(value) ~= "string" then -- 12
			error("Content path must be a project-relative string") -- 13
		end -- 13
		local path = value == "" and "." or value -- 14
		if not isValidWorkspacePath(path) or (string.find(path, "\0", nil, true) or 0) - 1 >= 0 then -- 14
			error("Content path must stay inside projectDir") -- 15
		end -- 15
		return table.concat( -- 16
			__TS__StringSplit(path, "\\"), -- 16
			"/" -- 16
		) -- 16
	end -- 12
	local function directory(value) -- 18
		local path = relative(value) -- 19
		if isAgentContentVirtualPath(path) then -- 19
			error("Content virtual paths are read-only files, not search/root directories") -- 20
		end -- 20
		if not Content:isdir(Path(workDir, path)) then -- 20
			error("Content search/root path must be a project directory") -- 21
		end -- 21
		return path -- 22
	end -- 18
	local function resolve(value, write) -- 24
		local path = relative(value) -- 25
		if isAgentContentVirtualPath(path) then -- 25
			if write then -- 25
				error("Content virtual paths are read-only") -- 27
			end -- 27
			local target = resolveAgentContentVirtualPath(workDir, path, docLanguage) -- 28
			if not target then -- 28
				error("Content virtual file not found or outside its namespace") -- 29
			end -- 29
			return target -- 30
		end -- 30
		if not write then -- 30
			for ____, base in ipairs(searchPaths) do -- 33
				local candidate = Path(workDir, base, path) -- 34
				if Content:exist(candidate) then -- 34
					return candidate -- 35
				end -- 35
			end -- 35
		end -- 35
		return Path(workDir, write and writablePath or assetPath, path) -- 38
	end -- 24
	local methods = {} -- 40
	local facade -- 41
	local function argumentsOf(values) -- 42
		return values[1] == facade and __TS__ArraySlice(values, 1) or values -- 42
	end -- 42
	local function delegate(name, paths, inspect) -- 43
		if inspect == nil then -- 43
			inspect = false -- 43
		end -- 43
		methods[name] = function(...) -- 44
			local values = {...} -- 44
			local args = argumentsOf(values) -- 45
			local virtualPath = type(args[1]) == "string" and isAgentContentVirtualPath(args[1]) and args[1] or nil -- 46
			do -- 46
				local i = 0 -- 47
				while i < #paths do -- 47
					args[i + 1] = resolve(args[i + 1], paths[i + 1]) -- 47
					i = i + 1 -- 47
				end -- 47
			end -- 47
			if virtualPath and name == "getFullPath" then -- 47
				return virtualPath -- 48
			end -- 48
			if virtualPath and __TS__ArrayIndexOf({ -- 48
				"getDirs", -- 49
				"getFiles", -- 49
				"getAllFiles", -- 49
				"glob", -- 49
				"zipAsync" -- 49
			}, name) >= 0 then -- 49
				error("Content virtual paths identify individual read-only files") -- 49
			end -- 49
			if virtualPath and name == "searchFilesAsync" then -- 49
				args[4] = {Path:getFilename(args[1])} -- 51
				args[1] = Path:getPath(args[1]) -- 52
				local callback = args[10] -- 53
				if callback then -- 53
					args[10] = function(row) -- 54
						row.file = virtualPath -- 54
						return callback(row) -- 54
					end -- 54
				end -- 54
			end -- 54
			if inspect then -- 54
				local result = inspectReadableFile(args[1]) -- 57
				if not result.success then -- 57
					error(result.message or "file is not readable") -- 58
				end -- 58
			end -- 58
			local fn = Content[name] -- 60
			if virtualPath and name == "searchFilesAsync" then -- 60
				local rows = fn( -- 62
					Content, -- 62
					table.unpack(args) -- 62
				) -- 62
				for ____, row in ipairs(rows) do -- 63
					row.file = virtualPath -- 63
				end -- 63
				return rows -- 64
			end -- 64
			return fn( -- 66
				Content, -- 66
				table.unpack(args) -- 66
			) -- 66
		end -- 44
	end -- 43
	for ____, name in ipairs({ -- 69
		"exist", -- 69
		"isdir", -- 69
		"getAttr", -- 69
		"getDirs", -- 69
		"getFiles", -- 69
		"getAllFiles", -- 69
		"getFullPath", -- 69
		"glob", -- 69
		"searchFilesAsync", -- 69
		"loadExcel", -- 69
		"loadExcelAsync" -- 69
	}) do -- 69
		delegate(name, {false}) -- 69
	end -- 69
	for ____, name in ipairs({"load", "loadAsync"}) do -- 70
		delegate(name, {false}, true) -- 70
	end -- 70
	for ____, name in ipairs({"save", "saveAsync", "mkdir", "remove"}) do -- 71
		delegate(name, {true}) -- 71
	end -- 71
	for ____, name in ipairs({"copy", "copyAsync", "zipAsync", "unzipAsync"}) do -- 72
		delegate(name, {false, true}) -- 72
	end -- 72
	delegate("move", {true, true}) -- 74
	methods.isAbsolutePath = function(...) -- 75
		local values = {...} -- 75
		local path = table.unpack( -- 76
			argumentsOf(values), -- 76
			1, -- 76
			1 -- 76
		) -- 76
		if type(path) ~= "string" then -- 76
			error("Content.isAbsolutePath expects a string") -- 77
		end -- 77
		return Content:isAbsolutePath(path) -- 78
	end -- 75
	methods.addSearchPath = function(...) -- 80
		local values = {...} -- 80
		local path = table.unpack( -- 81
			argumentsOf(values), -- 81
			1, -- 81
			1 -- 81
		) -- 81
		searchPaths[#searchPaths + 1] = directory(path) -- 82
	end -- 80
	methods.insertSearchPath = function(...) -- 84
		local values = {...} -- 84
		local index, path = table.unpack( -- 85
			argumentsOf(values), -- 85
			1, -- 85
			2 -- 85
		) -- 85
		if type(index) ~= "number" or index ~= math.floor(index) or index < 1 or index > #searchPaths + 1 then -- 85
			error("Content.insertSearchPath index is out of range") -- 86
		end -- 86
		__TS__ArraySplice( -- 87
			searchPaths, -- 87
			index - 1, -- 87
			0, -- 87
			directory(path) -- 87
		) -- 87
	end -- 84
	methods.removeSearchPath = function(...) -- 89
		local values = {...} -- 89
		local value = table.unpack( -- 90
			argumentsOf(values), -- 90
			1, -- 90
			1 -- 90
		) -- 90
		local path = relative(value) -- 91
		if isAgentContentVirtualPath(path) then -- 91
			error("Content virtual paths are read-only files, not search directories") -- 92
		end -- 92
		searchPaths = __TS__ArrayFilter( -- 93
			searchPaths, -- 93
			function(____, item) return item ~= path end -- 93
		) -- 93
	end -- 89
	methods.clearPathCache = function() -- 96
	end -- 96
	facade = setmetatable( -- 97
		{}, -- 97
		{ -- 97
			__index = function(_self, key) -- 98
				if key == "assetPath" then -- 98
					return assetPath -- 99
				end -- 99
				if key == "writablePath" then -- 99
					return writablePath -- 100
				end -- 100
				if key == "appPath" then -- 100
					return "." -- 101
				end -- 101
				if key == "searchPaths" then -- 101
					return __TS__ArraySlice(searchPaths) -- 102
				end -- 102
				return methods[key] -- 103
			end, -- 98
			__newindex = function(_self, key, value) -- 105
				if key == "assetPath" then -- 105
					assetPath = directory(value) -- 106
				elseif key == "writablePath" then -- 106
					writablePath = directory(value) -- 107
				elseif key == "searchPaths" then -- 107
					if not __TS__ArrayIsArray(value) then -- 107
						error("Content.searchPaths expects an array of project-relative directories") -- 109
					end -- 109
					searchPaths = __TS__ArrayMap( -- 110
						value, -- 110
						function(____, item) return directory(item) end -- 110
					) -- 110
				else -- 110
					error(("Content." .. key) .. " is read-only") -- 111
				end -- 111
			end, -- 105
			__metatable = "Agent project Content" -- 113
		} -- 113
	) -- 113
	return facade -- 115
end -- 8
return ____exports -- 8