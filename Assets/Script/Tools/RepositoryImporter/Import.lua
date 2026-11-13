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
		local host, owner, repo = string.match(repository, "^https://([^/]+)/([^/]+)/([^/]+)$") -- 45
		local name = (((owner .. "-") .. repo) .. "-") .. host -- 46
		local root = Path(Content.writablePath, name) -- 47
		local legacyRoot = Path(Content.writablePath, (((host .. "-") .. owner) .. "-") .. repo) -- 49
		if not Content:exist(root) and Content:load(Path(legacyRoot, ".git", "dora-import-repository")) == repository then -- 49
			root = legacyRoot -- 50
		end -- 50
		local marker = Path(root, ".git", "dora-import-repository") -- 51
		if Content:exist(root) then -- 51
			if not Content:isdir(root) or Content:load(marker) ~= repository then -- 51
				error( -- 53
					__TS__New(Error, "The destination already exists and belongs to another project."), -- 53
					0 -- 53
				) -- 53
			end -- 53
			local entry = ____exports.findEntry(root) -- 54
			if not entry then -- 54
				error( -- 55
					__TS__New(Error, "The local project has no init entry."), -- 55
					0 -- 55
				) -- 55
			end -- 55
			return ____awaiter_resolve(nil, {root = root, entry = entry, existing = true}) -- 55
		end -- 55
		local temporary -- 58
		repeat -- 58
			do -- 58
				temporary = Path( -- 59
					Content.writablePath, -- 59
					((".import-" .. tostring(os.time())) .. "-") .. tostring(math.random(1, 2147483647)) -- 59
				) -- 59
			end -- 59
		until not Content:exist(temporary) -- 59
		local ____hasReturned, ____returnValue -- 59
		local ____try = __TS__AsyncAwaiter(function() -- 59
			operation.phase = "clone" -- 61
			local clone = __TS__Await(runGit( -- 62
				Content.writablePath, -- 62
				(("clone --depth 1 --no-lfs " .. quoteGitArgument(repository)) .. " ") .. quoteGitArgument(Path:getFilename(temporary)),
				{ -- 62
					timeout = 600, -- 63
					isCanceled = function() return operation.canceled end, -- 63
					onStatus = function(____, status) -- 63
						operation.status = status -- 63
					end -- 63
				} -- 63
			)) -- 63
			if operation.canceled then -- 63
				error( -- 65
					__TS__New(Error, "Canceled"), -- 65
					0 -- 65
				) -- 65
			end -- 65
			if not clone.success then -- 65
				error( -- 66
					__TS__New(Error, clone.message or "Clone failed"), -- 66
					0 -- 66
				) -- 66
			end -- 66
			operation.phase = "verify" -- 67
			local verified = __TS__Await(runGit( -- 68
				temporary, -- 68
				"verify-resource", -- 68
				{isCanceled = function() return operation.canceled end} -- 68
			)) -- 68
			if operation.canceled then -- 68
				error( -- 69
					__TS__New(Error, "Canceled"), -- 69
					0 -- 69
				) -- 69
			end -- 69
			if not verified.success then -- 69
				error( -- 70
					__TS__New(Error, verified.message or "Project verification failed"), -- 70
					0 -- 70
				) -- 70
			end -- 70
			local entry = ____exports.findEntry(temporary) -- 71
			if not entry then -- 71
				error( -- 72
					__TS__New(Error, "The repository has no Dora init entry."), -- 72
					0 -- 72
				) -- 72
			end -- 72
			if not Content:save( -- 72
				Path(temporary, ".git", "dora-import-repository"), -- 73
				repository -- 73
			) then -- 73
				error( -- 73
					__TS__New(Error, "Could not record the repository."), -- 73
					0 -- 73
				) -- 73
			end -- 73
			if Content:exist(root) or not Content:move(temporary, root) then -- 73
				error( -- 76
					__TS__New(Error, "Could not move the project into the workspace."), -- 76
					0 -- 76
				) -- 76
			end -- 76
			____hasReturned = true -- 77
			____returnValue = { -- 77
				root = root, -- 77
				entry = Path( -- 77
					root, -- 77
					Path:getRelative(entry, temporary) -- 77
				), -- 77
				existing = false -- 77
			} -- 77
			return -- 77
		end) -- 77
		____try = ____try.finally( -- 77
			____try, -- 77
			function() -- 77
				return __TS__AsyncAwaiter(function() -- 77
					if Content:exist(temporary) then -- 77
						Content:remove(temporary) -- 79
					end -- 79
				end) -- 79
			end -- 79
		) -- 79
		__TS__Await(____try) -- 60
		if ____hasReturned then -- 60
			return ____awaiter_resolve(nil, ____returnValue) -- 60
		end -- 60
	end) -- 60
end -- 42
return ____exports -- 42