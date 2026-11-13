local Dora = require("Dora")
local GitTools = require("Tools.ResourceDownloader.Git")
local Content, Path = Dora.Content, Dora.Path

local apiOrigin = "https://atompie.osgame.org"
local localPort = math.tointeger(tonumber(os.getenv("DORA_ATOMPIE_LOCAL_PORT") or ""))
if localPort and localPort >= 1 and localPort <= 65535 then
	apiOrigin = "http://127.0.0.1:" .. localPort
end
local api = apiOrigin .. "/api/v1/assets/"
local hosts = {["atomgit.com"] = true, ["github.com"] = true, ["gitee.com"] = true, ["gitcode.com"] = true}
local extensions = {ts = 1, tsx = 2, yue = 3, tl = 4, lua = 5, xml = 6, wasm = 7}
local importing = {}
local sequence = 0

local function repositoryOf(asset, id)
	if type(asset) ~= "table" or asset.id ~= tonumber(id) or asset.asset_type ~= "game"
		or type(asset.repository_url) ~= "string" then return nil end
	local url = asset.repository_url:match("^%s*(.-)%s*$")
	local host, owner, repo = url:match("^https://([%w%.%-]+)/([%w_.%-]+)/([%w_.%-]+)/?$")
	if not hosts[host] or owner == "." or owner == ".." or repo == "." or repo == ".." then return nil end
	if type(asset.game_metadata) == "table" then
		if asset.game_metadata.engine == "dora_ssr" then return url:gsub("/$", "") end
		return nil
	end
	if type(asset.tags) ~= "table" then return nil end
	for _, tag in ipairs(asset.tags) do
		if type(tag) == "table" and type(tag.name) == "string" and tag.name:lower():match("^dora[%s%-]*ssr$") then
			return url:gsub("/$", "")
		end
	end
end

local function entryAt(projectPath)
	local best, bestDepth, bestPriority
	for _, item in ipairs(Content:getAllFiles(projectPath)) do
		local file = item:gsub("\\", "/")
		local lower = file:lower()
		if file:sub(1, 1) ~= "." and not file:find("/%.") and not ("/" .. lower):find("/node_modules/", 1, true) then
			local name = lower:match("([^/]+)$")
			local priority = extensions[name and name:match("^init%.(%w+)$")]
			if priority then
				local _, depth = file:gsub("/", "")
				if not best or depth < bestDepth or (depth == bestDepth
					and (priority < bestPriority or (priority == bestPriority and file < best))) then
					best, bestDepth, bestPriority = file, depth, priority
				end
			end
		end
	end
	return best
end

local function runGit(path, command, onStatus)
	local result
	local job = GitTools.runGit(path, command, {timeout = 600, onStatus = onStatus})
	job["then"](job, function(_, value) result = value end, function(_, reason)
		result = {success = false, message = tostring(reason)}
	end)
	Dora.wait(function() return result ~= nil end)
	return result
end

local function importProject(id, stage, onProgress)
	local workspace = Content.writablePath
	local target = Path(workspace, "AtomPie-" .. id)
	local marker = Path(target, ".git", "dora-atompie-id")
	if Content:exist(target) then
		if not Content:isdir(target) or not Content:exist(marker) or Content:load(marker) ~= id then
			return nil, "project directory already exists"
		end
		local entry = entryAt(target)
		return entry and Path(target, entry), "local project has no init file"
	end

	onProgress("resolve")
	local body = Dora.HttpClient:getAsync(api .. id, 20)
	local response = body and Dora.json.decode(body)
	local url = type(response) == "table" and repositoryOf(response.data, id)
	if not url then return nil, "public Dora game or supported HTTPS repository unavailable" end

	local tempName, tempPath
	repeat
		sequence = sequence + 1
		tempName = ".atompie-import-" .. id .. "-" .. os.time() .. "-" .. sequence
		tempPath = Path(workspace, tempName)
	until not Content:exist(tempPath)
	stage.path = tempPath
	onProgress("clone")
	-- An external open request must not contact LFS endpoints supplied by the repository.
	local clone = runGit(workspace, "clone --depth 1 --no-lfs " .. GitTools.quoteGitArgument(url) .. " " .. GitTools.quoteGitArgument(tempName), function(_, status)
		if status.state == "running" then
			onProgress("clone", status.progress, status.transferredBytes)
		end
	end)
	if not clone.success then return nil, clone.message or "Git clone failed" end
	onProgress("verify")
	local verified = runGit(tempPath, "verify-resource")
	if not verified.success then return nil, verified.message or "invalid project files" end
	local entry = entryAt(tempPath)
	if not entry then return nil, "repository has no Dora init file" end
	if not Content:save(Path(tempPath, ".git", "dora-atompie-id"), id) then return nil, "could not record the imported project" end
	if not Content:renameFolder(tempPath, target) then return nil, "could not move the project into the workspace" end
	stage.path = nil
	return Path(target, entry)
end

local function open(id, onOpen, onError, onProgress)
	if type(id) ~= "string" or not id:match("^[1-9]%d*$") or #id > 10 or tonumber(id) > 2147483647 then
		onError("invalid AtomPie asset ID")
		return
	end
	if importing[id] then return false end
	importing[id] = true
	Dora.Director.systemScheduler:schedule(Dora.once(function()
		local stage = {}
		local ok, entry, failure = pcall(importProject, id, stage, onProgress)
		importing[id] = nil
		if stage.path and Content:exist(stage.path) then Content:remove(stage.path) end
		if ok and entry then onOpen(entry) else onError(ok and failure or entry) end
	end))
	return true
end

return {open = open, entryAt = entryAt}
