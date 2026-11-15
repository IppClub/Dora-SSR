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
local inspectReadableFile = ____Workspace.inspectReadableFile -- 3
local isAgentContentVirtualPath = ____Workspace.isAgentContentVirtualPath -- 3
local resolveAgentContentVirtualPath = ____Workspace.resolveAgentContentVirtualPath -- 3
--- Native Content operations with project-root defaults and command-local configuration.
function ____exports.createCommandContent(workDir, docLanguage) -- 8
	local assetPath = workDir -- 9
	local writablePath = workDir -- 10
	local searchPaths = {} -- 11
	local function normalizePath(value) -- 12
		if type(value) ~= "string" then -- 12
			error("Content path must be a string") -- 13
		end -- 13
		local path = value == "" and "." or value -- 14
		if (string.find(path, "\0", nil, true) or 0) - 1 >= 0 then -- 14
			error("Content path must not contain NUL") -- 15
		end -- 15
		return table.concat( -- 16
			__TS__StringSplit(path, "\\"), -- 16
			"/" -- 16
		) -- 16
	end -- 12
	local function directory(value) -- 18
		local path = normalizePath(value) -- 19
		if isAgentContentVirtualPath(path) then -- 19
			error("Content virtual paths are read-only files, not search/root directories") -- 20
		end -- 20
		local fullPath = Content:isAbsolutePath(path) and path or Path(workDir, path) -- 21
		if not Content:isdir(fullPath) then -- 21
			error("Content search/root path must be an existing directory") -- 22
		end -- 22
		return fullPath -- 23
	end -- 18
	local function resolve(value, write) -- 25
		local path = normalizePath(value) -- 26
		if isAgentContentVirtualPath(path) then -- 26
			if write then -- 26
				error("Content virtual paths are read-only") -- 28
			end -- 28
			local target = resolveAgentContentVirtualPath(workDir, path, docLanguage) -- 29
			if not target then -- 29
				error("Content virtual file not found or outside its namespace") -- 30
			end -- 30
			return target -- 31
		end -- 31
		if Content:isAbsolutePath(path) then -- 31
			return path -- 33
		end -- 33
		if not write then -- 33
			for ____, base in ipairs(searchPaths) do -- 35
				local candidate = Path(base, path) -- 36
				if Content:exist(candidate) then -- 36
					return candidate -- 37
				end -- 37
			end -- 37
		end -- 37
		return Path(write and writablePath or assetPath, path) -- 40
	end -- 25
	local methods = {} -- 42
	local facade -- 43
	local function argumentsOf(values) -- 44
		return values[1] == facade and __TS__ArraySlice(values, 1) or values -- 44
	end -- 44
	local function delegate(name, paths, inspect) -- 45
		if inspect == nil then -- 45
			inspect = false -- 45
		end -- 45
		methods[name] = function(...) -- 46
			local values = {...} -- 46
			local args = argumentsOf(values) -- 47
			local virtualPath = type(args[1]) == "string" and isAgentContentVirtualPath(args[1]) and args[1] or nil -- 48
			do -- 48
				local i = 0 -- 49
				while i < #paths do -- 49
					args[i + 1] = resolve(args[i + 1], paths[i + 1]) -- 49
					i = i + 1 -- 49
				end -- 49
			end -- 49
			if virtualPath and name == "getFullPath" then -- 49
				return virtualPath -- 50
			end -- 50
			if virtualPath and __TS__ArrayIndexOf({ -- 50
				"getDirs", -- 51
				"getFiles", -- 51
				"getAllFiles", -- 51
				"glob", -- 51
				"zipAsync" -- 51
			}, name) >= 0 then -- 51
				error("Content virtual paths identify individual read-only files") -- 51
			end -- 51
			if virtualPath and name == "searchFilesAsync" then -- 51
				args[4] = {Path:getFilename(args[1])} -- 53
				args[1] = Path:getPath(args[1]) -- 54
				local callback = args[10] -- 55
				if callback then -- 55
					args[10] = function(row) -- 56
						row.file = virtualPath -- 56
						return callback(row) -- 56
					end -- 56
				end -- 56
			end -- 56
			if inspect then -- 56
				local result = inspectReadableFile(args[1]) -- 59
				if not result.success then -- 59
					error(result.message or "file is not readable") -- 60
				end -- 60
			end -- 60
			local fn = Content[name] -- 62
			if virtualPath and name == "searchFilesAsync" then -- 62
				local rows = fn( -- 64
					Content, -- 64
					table.unpack(args) -- 64
				) -- 64
				for ____, row in ipairs(rows) do -- 65
					row.file = virtualPath -- 65
				end -- 65
				return rows -- 66
			end -- 66
			return fn( -- 68
				Content, -- 68
				table.unpack(args) -- 68
			) -- 68
		end -- 46
	end -- 45
	for ____, name in ipairs({ -- 71
		"exist", -- 71
		"isdir", -- 71
		"getAttr", -- 71
		"getDirs", -- 71
		"getFiles", -- 71
		"getAllFiles", -- 71
		"getFullPath", -- 71
		"glob", -- 71
		"searchFilesAsync", -- 71
		"loadExcel", -- 71
		"loadExcelAsync" -- 71
	}) do -- 71
		delegate(name, {false}) -- 71
	end -- 71
	for ____, name in ipairs({"load", "loadAsync"}) do -- 72
		delegate(name, {false}, true) -- 72
	end -- 72
	for ____, name in ipairs({"save", "saveAsync", "mkdir", "remove"}) do -- 73
		delegate(name, {true}) -- 73
	end -- 73
	for ____, name in ipairs({"copy", "copyAsync", "zipAsync", "unzipAsync"}) do -- 74
		delegate(name, {false, true}) -- 74
	end -- 74
	delegate("move", {true, true}) -- 76
	methods.isAbsolutePath = function(...) -- 77
		local values = {...} -- 77
		local path = table.unpack( -- 78
			argumentsOf(values), -- 78
			1, -- 78
			1 -- 78
		) -- 78
		if type(path) ~= "string" then -- 78
			error("Content.isAbsolutePath expects a string") -- 79
		end -- 79
		return Content:isAbsolutePath(path) -- 80
	end -- 77
	methods.addSearchPath = function(...) -- 82
		local values = {...} -- 82
		local path = table.unpack( -- 83
			argumentsOf(values), -- 83
			1, -- 83
			1 -- 83
		) -- 83
		searchPaths[#searchPaths + 1] = directory(path) -- 84
	end -- 82
	methods.insertSearchPath = function(...) -- 86
		local values = {...} -- 86
		local index, path = table.unpack( -- 87
			argumentsOf(values), -- 87
			1, -- 87
			2 -- 87
		) -- 87
		if type(index) ~= "number" or index ~= math.floor(index) or index < 1 or index > #searchPaths + 1 then -- 87
			error("Content.insertSearchPath index is out of range") -- 88
		end -- 88
		__TS__ArraySplice( -- 89
			searchPaths, -- 89
			index - 1, -- 89
			0, -- 89
			directory(path) -- 89
		) -- 89
	end -- 86
	methods.removeSearchPath = function(...) -- 91
		local values = {...} -- 91
		local value = table.unpack( -- 92
			argumentsOf(values), -- 92
			1, -- 92
			1 -- 92
		) -- 92
		local path = normalizePath(value) -- 93
		if isAgentContentVirtualPath(path) then -- 93
			error("Content virtual paths are read-only files, not search directories") -- 94
		end -- 94
		local fullPath = Content:isAbsolutePath(path) and path or Path(workDir, path) -- 95
		searchPaths = __TS__ArrayFilter( -- 96
			searchPaths, -- 96
			function(____, item) return item ~= fullPath end -- 96
		) -- 96
	end -- 91
	methods.clearPathCache = function() -- 99
	end -- 99
	facade = setmetatable( -- 100
		{}, -- 100
		{ -- 100
			__index = function(_self, key) -- 101
				if key == "assetPath" then -- 101
					return assetPath -- 102
				end -- 102
				if key == "writablePath" then -- 102
					return writablePath -- 103
				end -- 103
				if key == "appPath" then -- 103
					return Content.appPath -- 104
				end -- 104
				if key == "searchPaths" then -- 104
					return __TS__ArraySlice(searchPaths) -- 105
				end -- 105
				return methods[key] -- 106
			end, -- 101
			__newindex = function(_self, key, value) -- 108
				if key == "assetPath" then -- 108
					assetPath = directory(value) -- 109
				elseif key == "writablePath" then -- 109
					writablePath = directory(value) -- 110
				elseif key == "searchPaths" then -- 110
					if not __TS__ArrayIsArray(value) then -- 110
						error("Content.searchPaths expects an array of directories") -- 112
					end -- 112
					searchPaths = __TS__ArrayMap( -- 113
						value, -- 113
						function(____, item) return directory(item) end -- 113
					) -- 113
				else -- 113
					error(("Content." .. key) .. " is read-only") -- 114
				end -- 114
			end, -- 108
			__metatable = "Agent project Content" -- 116
		} -- 116
	) -- 116
	return facade -- 118
end -- 8
return ____exports -- 8