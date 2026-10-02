-- [ts]: Lifecycle.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
local ____GitInstaller = require("Tools.ResourceDownloader.GitInstaller") -- 3
local getResourceInstallPath = ____GitInstaller.getResourceInstallPath -- 3
local installResource = ____GitInstaller.installResource -- 3
local isResourceInstalled = ____GitInstaller.isResourceInstalled -- 3
local syncResource = ____GitInstaller.syncResource -- 3
local ____CatalogSync = require("Tools.ResourceDownloader.CatalogSync") -- 4
local loadCachedCatalog = ____CatalogSync.loadCachedCatalog -- 4
____exports.syncMobileResource = function(resourceId, force, onProgress, onDone, isCanceled) -- 32
	local function synchronize() -- 39
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 39
			local catalog = loadCachedCatalog() -- 42
			if not catalog.success or not catalog.snapshot then -- 42
				return ____awaiter_resolve(nil, {success = false, message = catalog.message or "Catalog is unavailable"}) -- 42
			end -- 42
			local resource = __TS__ArrayFind( -- 46
				catalog.snapshot.catalog.resources, -- 46
				function(____, item) return item.id == resourceId end -- 46
			) -- 46
			local version = resource and resource.versions[math.max(1, resource.selectedVersion)] -- 47
			if not resource or not version then -- 47
				return ____awaiter_resolve(nil, {success = false, message = "project is no longer available in Catalog"}) -- 47
			end -- 47
			local result = __TS__Await(syncResource( -- 51
				resource, -- 51
				version, -- 51
				{ -- 51
					catalogCommit = catalog.snapshot.commit, -- 52
					isCanceled = isCanceled, -- 52
					onProgress = function(____, status) return onProgress(status.progress, status.message, status.transferredBytes) end -- 53
				}, -- 53
				force -- 54
			)) -- 54
			return ____awaiter_resolve( -- 54
				nil, -- 54
				__TS__ObjectAssign( -- 57
					{}, -- 57
					result, -- 57
					{entry = result.success and ({workDir = result.targetPath or getResourceInstallPath(resource.id)}) or nil} -- 57
				) -- 57
			) -- 57
		end) -- 57
	end -- 39
	local ____self_2 = synchronize() -- 39
	____self_2["then"]( -- 39
		____self_2, -- 39
		function(____, result) return onDone(result) end, -- 59
		function(____, ____error) return onDone({ -- 59
			success = false, -- 59
			message = tostring(____error) -- 59
		}) end -- 59
	) -- 59
end -- 32
local function installedEntry(resource) -- 62
	local workDir = getResourceInstallPath(resource.id) -- 63
	return { -- 64
		fileName = Path( -- 65
			workDir, -- 65
			Path:replaceExt(resource.entrypoints[1].path, "") -- 65
		), -- 65
		workDir = workDir, -- 66
		installed = true -- 67
	} -- 67
end -- 62
____exports.resolveMobileLaunchEntry = function(entry) return { -- 73
	fileName = entry.fileName, -- 74
	workDir = Path:getPath(entry.fileName) -- 75
} end -- 75
____exports.isMobileResourceReady = function(resource) -- 78
	local entrypoint = resource.entrypoints[1] -- 79
	if entrypoint == nil or not isResourceInstalled(resource.id) then -- 79
		return false -- 80
	end -- 80
	local entryPath = Path( -- 81
		getResourceInstallPath(resource.id), -- 81
		entrypoint.path -- 81
	) -- 81
	if Content:exist(entryPath) then -- 81
		return true -- 82
	end -- 82
	if Path:getExt(entrypoint.path) ~= "" then -- 82
		return false -- 83
	end -- 83
	for ____, extension in ipairs({ -- 84
		"lua", -- 84
		"xml", -- 84
		"yue", -- 84
		"tl", -- 84
		"wasm" -- 84
	}) do -- 84
		if Content:exist((entryPath .. ".") .. extension) then -- 84
			return true -- 85
		end -- 85
	end -- 85
	return false -- 87
end -- 78
local function reserveRecoveryPath(resourceId) -- 90
	local downloadPath = Path(Content.writablePath, "Download") -- 91
	local stem = (resourceId .. ".recovery-") .. tostring(os.time()) -- 92
	local recoveryPath = Path(downloadPath, stem) -- 93
	local suffix = 1 -- 94
	while Content:exist(recoveryPath) do -- 94
		recoveryPath = Path( -- 96
			downloadPath, -- 96
			(stem .. "-") .. tostring(suffix) -- 96
		) -- 96
		suffix = suffix + 1 -- 97
	end -- 97
	return recoveryPath -- 99
end -- 90
____exports.prepareMobileResource = function(resource, catalogCommit, onProgress, onDone, repairIncomplete, isCanceled) -- 102
	if repairIncomplete == nil then -- 102
		repairIncomplete = false -- 107
	end -- 107
	if ____exports.isMobileResourceReady(resource) then -- 107
		onDone({ -- 111
			success = true, -- 111
			entry = installedEntry(resource) -- 111
		}) -- 111
		return -- 112
	end -- 112
	local index = math.max( -- 114
		1, -- 114
		math.min(resource.selectedVersion, #resource.versions) -- 114
	) -- 114
	local version = resource.versions[index] -- 115
	if version == nil then -- 115
		onDone({success = false, message = "resource version is unavailable"}) -- 117
		return -- 118
	end -- 118
	local recoveryPath -- 120
	local installPath = getResourceInstallPath(resource.id) -- 121
	if isResourceInstalled(resource.id) then -- 121
		if not repairIncomplete then -- 121
			onDone({success = false, message = "installed resource is incomplete; tap again to repair it", repairable = true}) -- 124
			return -- 129
		end -- 129
		recoveryPath = reserveRecoveryPath(resource.id) -- 131
		if not Content:move(installPath, recoveryPath) then -- 131
			onDone({success = false, message = "failed to preserve the incomplete installation"}) -- 133
			return -- 134
		end -- 134
	end -- 134
	(function() -- 137
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 137
			local result = __TS__Await(installResource( -- 138
				resource, -- 138
				version, -- 138
				{ -- 138
					catalogCommit = catalogCommit, -- 139
					onProgress = function(____, item) return onProgress(item.progress, item.message, item.transferredBytes) end, -- 140
					isCanceled = isCanceled -- 141
				} -- 141
			)) -- 141
			if not result.success then -- 141
				local message = result.message or "installation failed" -- 144
				if recoveryPath and not Content:exist(installPath) then -- 144
					if Content:move(recoveryPath, installPath) then -- 144
						message = message .. "; previous installation restored" -- 146
					else -- 146
						message = message .. "; previous installation remains at " .. recoveryPath -- 147
					end -- 147
				end -- 147
				onDone({ -- 149
					success = false, -- 149
					message = message, -- 149
					repairable = isResourceInstalled(resource.id) -- 149
				}) -- 149
				return ____awaiter_resolve(nil) -- 149
			end -- 149
			onDone({ -- 152
				success = true, -- 152
				entry = installedEntry(resource) -- 152
			}) -- 152
		end) -- 152
	end)() -- 137
end -- 102
return ____exports -- 102