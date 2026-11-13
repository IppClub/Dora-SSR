-- [ts]: Import.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local ____Git = require("Tools.ResourceDownloader.Git") -- 3
local runGit = ____Git.runGit -- 3
local quoteGitArgument = ____Git.quoteGitArgument -- 3
function ____exports.normalizeRepository(input) -- 5
	local url = string.gsub(input, "^%s*(.-)%s*$", "%1") -- 6
	url = string.gsub(url, "/$", "") -- 7
	local host, owner, repo = string.match(url, "^https://([%w%.%-]+)/([%w_.%-]+)/([%w_.%-]+)$") -- 8
	if host == nil or owner == nil or repo == nil or owner == "." or owner == ".." or repo == "." or repo == ".." then -- 8
		return -- 9
	end -- 9
	if host ~= "github.com" and host ~= "atomgit.com" and host ~= "gitee.com" and host ~= "gitcode.com" then -- 9
		return -- 10
	end -- 10
	url = string.gsub(url, "%.git$", "") -- 11
	if __TS__StringEndsWith(url, "/") then -- 11
		return -- 12
	end -- 12
	return url -- 13
end -- 5
function ____exports.findEntry(root) -- 16
	local priority = { -- 17
		ts = 1, -- 17
		tsx = 2, -- 17
		yue = 3, -- 17
		tl = 4, -- 17
		lua = 5, -- 17
		xml = 6, -- 17
		wasm = 7 -- 17
	} -- 17
	local best -- 18
	local bestDepth = math.huge -- 18
	local bestPriority = math.huge -- 18
	for ____, item in ipairs(Content:getAllFiles(root)) do -- 19
		do -- 19
			local file = string.gsub(item, "\\", "/") -- 20
			if __TS__StringStartsWith(file, ".") or (string.find(file, "/%.")) ~= nil or (string.find( -- 20
				"/" .. string.lower(file), -- 21
				"/node_modules/", -- 21
				1, -- 21
				true -- 21
			)) ~= nil then -- 21
				goto __continue7 -- 21
			end -- 21
			local ext = string.match( -- 22
				string.lower(file), -- 22
				"init%.(%w+)$" -- 22
			) -- 22
			if ext == nil or string.lower(Path:getName(file)) ~= "init" or priority[ext] == nil then -- 22
				goto __continue7 -- 23
			end -- 23
			local ____, depth = string.gsub(file, "/", "") -- 24
			if depth < bestDepth or depth == bestDepth and (priority[ext] < bestPriority or priority[ext] == bestPriority and (best == nil or file < best)) then -- 24
				best = file -- 26
				bestDepth = depth -- 26
				bestPriority = priority[ext] -- 26
			end -- 26
		end -- 26
		::__continue7:: -- 26
	end -- 26
	local ____temp_0 -- 29
	if best == nil then -- 29
		____temp_0 = nil -- 29
	else -- 29
		____temp_0 = Path(root, best) -- 29
	end -- 29
	return ____temp_0 -- 29
end -- 16
function ____exports.importRepository(url, operation) -- 42
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 42
		local repository = ____exports.normalizeRepository(url) -- 43
		if not repository then -- 43
			error( -- 44
				__TS__New(Error, "Use a public HTTPS repository on GitHub, AtomGit, Gitee or GitCode."), -- 44
				0 -- 44
			) -- 44
		end -- 44
		local name = string.gsub( -- 45
			__TS__StringSubstring(repository, 8), -- 45
			"/", -- 45
			"-" -- 45
		) -- 45
		local root = Path(Content.writablePath, name) -- 46
		local marker = Path(root, ".git", "dora-import-repository") -- 47
		if Content:exist(root) then -- 47
			if not Content:isdir(root) or Content:load(marker) ~= repository then -- 47
				error( -- 49
					__TS__New(Error, "The destination already exists and belongs to another project."), -- 49
					0 -- 49
				) -- 49
			end -- 49
			local entry = ____exports.findEntry(root) -- 50
			if not entry then -- 50
				error( -- 51
					__TS__New(Error, "The local project has no init entry."), -- 51
					0 -- 51
				) -- 51
			end -- 51
			return ____awaiter_resolve(nil, {root = root, entry = entry, existing = true}) -- 51
		end -- 51
		local temporary -- 54
		repeat -- 54
			do -- 54
				temporary = Path( -- 55
					Content.writablePath, -- 55
					((".import-" .. tostring(os.time())) .. "-") .. tostring(math.random(1, 2147483647)) -- 55
				) -- 55
			end -- 55
		until not Content:exist(temporary) -- 55
		local ____hasReturned, ____returnValue -- 55
		local ____try = __TS__AsyncAwaiter(function() -- 55
			operation.phase = "clone" -- 57
			local clone = __TS__Await(runGit( -- 58
				Content.writablePath, -- 58
				(("clone --depth 1 --no-lfs " .. quoteGitArgument(repository)) .. " ") .. quoteGitArgument(Path:getFilename(temporary)),
				{ -- 58
					timeout = 600, -- 59
					isCanceled = function() return operation.canceled end, -- 59
					onStatus = function(____, status) -- 59
						operation.status = status -- 59
					end -- 59
				} -- 59
			)) -- 59
			if operation.canceled then -- 59
				error( -- 61
					__TS__New(Error, "Canceled"), -- 61
					0 -- 61
				) -- 61
			end -- 61
			if not clone.success then -- 61
				error( -- 62
					__TS__New(Error, clone.message or "Clone failed"), -- 62
					0 -- 62
				) -- 62
			end -- 62
			operation.phase = "verify" -- 63
			local verified = __TS__Await(runGit( -- 64
				temporary, -- 64
				"verify-resource", -- 64
				{isCanceled = function() return operation.canceled end} -- 64
			)) -- 64
			if operation.canceled then -- 64
				error( -- 65
					__TS__New(Error, "Canceled"), -- 65
					0 -- 65
				) -- 65
			end -- 65
			if not verified.success then -- 65
				error( -- 66
					__TS__New(Error, verified.message or "Project verification failed"), -- 66
					0 -- 66
				) -- 66
			end -- 66
			local entry = ____exports.findEntry(temporary) -- 67
			if not entry then -- 67
				error( -- 68
					__TS__New(Error, "The repository has no Dora init entry."), -- 68
					0 -- 68
				) -- 68
			end -- 68
			if not Content:save( -- 68
				Path(temporary, ".git", "dora-import-repository"), -- 69
				repository -- 69
			) then -- 69
				error( -- 69
					__TS__New(Error, "Could not record the repository."), -- 69
					0 -- 69
				) -- 69
			end -- 69
			if Content:exist(root) or not Content:move(temporary, root) then -- 69
				error( -- 72
					__TS__New(Error, "Could not move the project into the workspace."), -- 72
					0 -- 72
				) -- 72
			end -- 72
			____hasReturned = true -- 73
			____returnValue = { -- 73
				root = root, -- 73
				entry = Path( -- 73
					root, -- 73
					Path:getRelative(entry, temporary) -- 73
				), -- 73
				existing = false -- 73
			} -- 73
			return -- 73
		end) -- 73
		____try = ____try.finally( -- 73
			____try, -- 73
			function() -- 73
				return __TS__AsyncAwaiter(function() -- 73
					if Content:exist(temporary) then -- 73
						Content:remove(temporary) -- 75
					end -- 75
				end) -- 75
			end -- 75
		) -- 75
		__TS__Await(____try) -- 56
		if ____hasReturned then -- 56
			return ____awaiter_resolve(nil, ____returnValue) -- 56
		end -- 56
	end) -- 56
end -- 42
return ____exports -- 42