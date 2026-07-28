-- [ts]: CatalogSync.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local json = ____Dora.json -- 2
local Path = ____Dora.Path -- 2
local ____Catalog = require("Script.Tools.ResourceDownloader.Catalog") -- 3
local loadCatalog = ____Catalog.loadCatalog -- 3
local ____Git = require("Script.Tools.ResourceDownloader.Git") -- 4
local gitHeadFromStatus = ____Git.gitHeadFromStatus -- 4
local quoteGitArgument = ____Git.quoteGitArgument -- 4
local runGit = ____Git.runGit -- 4
local GITHUB_CATALOG_REMOTE = "https://github.com/ippclub/Dora-Catalog.git" -- 6
local ATOMGIT_CATALOG_REMOTE = "https://gitcode.com/ippclub/Dora-Catalog.git" -- 7
____exports.catalogRemotesForLocale = function(locale) -- 9
	local isChinese = string.match(locale, "^zh") -- 10
	return isChinese ~= nil and ({ATOMGIT_CATALOG_REMOTE, GITHUB_CATALOG_REMOTE}) or ({GITHUB_CATALOG_REMOTE, ATOMGIT_CATALOG_REMOTE}) -- 11
end -- 9
____exports.CATALOG_REMOTES = ____exports.catalogRemotesForLocale(App.locale) -- 16
local CACHE_TTL_SECONDS = 6 * 60 * 60 -- 54
local function cacheRoot() -- 56
	return Path(Content.appPath, ".cache", "resource-catalog") -- 56
end -- 56
local function repoPath() -- 57
	return Path( -- 57
		cacheRoot(), -- 57
		"repo" -- 57
	) -- 57
end -- 57
local function statePath() -- 58
	return Path( -- 58
		cacheRoot(), -- 58
		"state.json" -- 58
	) -- 58
end -- 58
local function readState() -- 60
	local file = statePath() -- 61
	if not Content:exist(file) then -- 61
		return nil -- 62
	end -- 62
	local decoded, err = json.decode(Content:load(file)) -- 63
	if err ~= nil or type(decoded) ~= "table" or decoded == nil then -- 63
		return nil -- 64
	end -- 64
	local state = decoded -- 65
	if state.schemaVersion ~= 1 or type(state.commit) ~= "string" or type(state.source) ~= "string" or type(state.syncedAt) ~= "string" or type(state.checkedAt) ~= "number" then -- 65
		return nil -- 71
	end -- 71
	return state -- 73
end -- 60
local function writeState(state) -- 76
	local text = json.encode(state) -- 77
	return text ~= nil and Content:save( -- 78
		statePath(), -- 78
		text -- 78
	) -- 78
end -- 76
local function emitStatus(options, progress, message, source) -- 81
	if options.onStatus then -- 81
		options:onStatus({progress = progress, message = message, source = source}) -- 87
	end -- 87
end -- 81
local function snapshotFrom(path, state) -- 90
	local catalog = loadCatalog(path) -- 94
	if #catalog.resources == 0 then -- 94
		return {success = false, message = "catalog contains no usable resources"} -- 96
	end -- 96
	if #catalog.issues > 0 then -- 96
		local first = catalog.issues[1] -- 99
		return {success = false, message = (("catalog validation failed at " .. (first.project ~= "" and first.project or "root")) .. ": ") .. first.message} -- 100
	end -- 100
	return {success = true, snapshot = {catalog = catalog, commit = state.commit, source = state.source, syncedAt = state.syncedAt}} -- 105
end -- 90
____exports.loadCachedCatalog = function() -- 116
	local state = readState() -- 117
	local path = repoPath() -- 118
	if not state or not Content:isdir(path) then -- 118
		return {success = false, message = "no catalog cache is available"} -- 120
	end -- 120
	local result = snapshotFrom(path, state) -- 122
	if result.success then -- 122
		result.usedCache = true -- 123
	end -- 123
	return result -- 124
end -- 116
____exports.syncCatalog = function(options) -- 127
	if options == nil then -- 127
		options = {} -- 127
	end -- 127
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 127
		local remotes = options.remotes ~= nil and #options.remotes > 0 and options.remotes or ____exports.CATALOG_REMOTES -- 128
		local existingState = readState() -- 131
		local cached = ____exports.loadCachedCatalog() -- 132
		if not options.force and cached.success and existingState and (existingState.preferredSource or existingState.source) == remotes[1] and os.time() - existingState.checkedAt < CACHE_TTL_SECONDS then -- 132
			return ____awaiter_resolve(nil, cached) -- 132
		end -- 132
		local root = cacheRoot() -- 140
		if not Content:mkdir(root) and not Content:isdir(root) then -- 140
			return ____awaiter_resolve(nil, cached.success and cached or ({success = false, message = "failed to create catalog cache directory"})) -- 140
		end -- 140
		local lastMessage = "catalog sources are unavailable" -- 144
		local candidateName = "candidate" -- 145
		local candidatePath = Path(root, candidateName) -- 146
		for ____, source in ipairs(remotes) do -- 147
			do -- 147
				if options.isCanceled and options:isCanceled() then -- 147
					return ____awaiter_resolve(nil, {success = false, message = "catalog synchronization canceled"}) -- 147
				end -- 147
				if Content:exist(candidatePath) then -- 147
					Content:remove(candidatePath) -- 151
				end -- 151
				emitStatus(options, 0.02, "Connecting to catalog", source) -- 152
				local cloneResult = __TS__Await(runGit( -- 153
					root, -- 154
					(("clone " .. quoteGitArgument(source)) .. " ") .. quoteGitArgument(candidateName), -- 154
					{ -- 156
						timeout = 300, -- 157
						isCanceled = options.isCanceled, -- 158
						onStatus = function(____, status) -- 159
							emitStatus( -- 160
								options, -- 161
								math.max( -- 162
									0.03, -- 162
									math.min(0.78, status.progress * 0.78) -- 162
								), -- 162
								status.message or "Receiving catalog", -- 163
								source -- 164
							) -- 164
						end -- 159
					} -- 159
				)) -- 159
				if not cloneResult.success then -- 159
					Content:remove(candidatePath) -- 170
					lastMessage = cloneResult.message or "failed to clone catalog" -- 171
					goto __continue22 -- 172
				end -- 172
				local commit = gitHeadFromStatus(cloneResult.status) -- 174
				if not commit then -- 174
					Content:remove(candidatePath) -- 176
					lastMessage = "catalog clone did not return a commit hash" -- 177
					goto __continue22 -- 178
				end -- 178
				emitStatus(options, 0.82, "Validating catalog entries", source) -- 180
				local candidateState = { -- 181
					schemaVersion = 1, -- 182
					commit = commit, -- 183
					source = source, -- 184
					syncedAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 185
					checkedAt = os.time(), -- 186
					preferredSource = remotes[1] -- 187
				} -- 187
				local candidateSnapshot = snapshotFrom(candidatePath, candidateState) -- 189
				if not candidateSnapshot.success then -- 189
					Content:remove(candidatePath) -- 191
					lastMessage = candidateSnapshot.message or "catalog validation failed" -- 192
					goto __continue22 -- 193
				end -- 193
				local currentPath = repoPath() -- 195
				local backupPath = Path(root, "repo-backup") -- 196
				if Content:exist(backupPath) then -- 196
					Content:remove(backupPath) -- 197
				end -- 197
				if Content:exist(currentPath) and not Content:move(currentPath, backupPath) then -- 197
					Content:remove(candidatePath) -- 199
					lastMessage = "failed to prepare catalog cache replacement" -- 200
					goto __continue22 -- 201
				end -- 201
				if not Content:move(candidatePath, currentPath) then -- 201
					if Content:exist(backupPath) then -- 201
						Content:move(backupPath, currentPath) -- 204
					end -- 204
					Content:remove(candidatePath) -- 205
					lastMessage = "failed to activate the downloaded catalog" -- 206
					goto __continue22 -- 207
				end -- 207
				if not writeState(candidateState) then -- 207
					Content:remove(currentPath) -- 210
					if Content:exist(backupPath) then -- 210
						Content:move(backupPath, currentPath) -- 211
					end -- 211
					lastMessage = "failed to save catalog state" -- 212
					goto __continue22 -- 213
				end -- 213
				if Content:exist(backupPath) then -- 213
					Content:remove(backupPath) -- 215
				end -- 215
				emitStatus(options, 1, "Catalog is ready", source) -- 216
				return ____awaiter_resolve( -- 216
					nil, -- 216
					snapshotFrom(currentPath, candidateState) -- 217
				) -- 217
			end -- 217
			::__continue22:: -- 217
		end -- 217
		if cached.success then -- 217
			cached.message = lastMessage -- 220
			cached.usedCache = true -- 221
			return ____awaiter_resolve(nil, cached) -- 221
		end -- 221
		return ____awaiter_resolve(nil, {success = false, message = lastMessage}) -- 221
	end) -- 221
end -- 127
return ____exports -- 127