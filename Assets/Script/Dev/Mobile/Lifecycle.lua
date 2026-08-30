-- [ts]: Lifecycle.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
local ____GitInstaller = require("Tools.ResourceDownloader.GitInstaller") -- 3
local getResourceInstallPath = ____GitInstaller.getResourceInstallPath -- 3
local installResource = ____GitInstaller.installResource -- 3
local isResourceInstalled = ____GitInstaller.isResourceInstalled -- 3
local function installedEntry(resource) -- 23
	local workDir = getResourceInstallPath(resource.id) -- 24
	return { -- 25
		fileName = Path( -- 26
			workDir, -- 26
			Path:replaceExt(resource.entrypoints[1].path, "") -- 26
		), -- 26
		workDir = workDir, -- 27
		installed = true -- 28
	} -- 28
end -- 23
____exports.resolveMobileLaunchEntry = function(entry) return { -- 34
	fileName = entry.fileName, -- 35
	workDir = Path:getPath(entry.fileName) -- 36
} end -- 36
____exports.isMobileResourceReady = function(resource) -- 39
	local entrypoint = resource.entrypoints[1] -- 40
	if not entrypoint or not isResourceInstalled(resource.id) then -- 40
		return false -- 41
	end -- 41
	local entryPath = Path( -- 42
		getResourceInstallPath(resource.id), -- 42
		entrypoint.path -- 42
	) -- 42
	if Content:exist(entryPath) then -- 42
		return true -- 43
	end -- 43
	if Path:getExt(entrypoint.path) ~= "" then -- 43
		return false -- 44
	end -- 44
	for ____, extension in ipairs({ -- 45
		"lua", -- 45
		"xml", -- 45
		"yue", -- 45
		"tl", -- 45
		"wasm" -- 45
	}) do -- 45
		if Content:exist((entryPath .. ".") .. extension) then -- 45
			return true -- 46
		end -- 46
	end -- 46
	return false -- 48
end -- 39
local function reserveRecoveryPath(resourceId) -- 51
	local downloadPath = Path(Content.writablePath, "Download") -- 52
	local stem = (resourceId .. ".recovery-") .. tostring(os.time()) -- 53
	local recoveryPath = Path(downloadPath, stem) -- 54
	local suffix = 1 -- 55
	while Content:exist(recoveryPath) do -- 55
		recoveryPath = Path( -- 57
			downloadPath, -- 57
			(stem .. "-") .. tostring(suffix) -- 57
		) -- 57
		suffix = suffix + 1 -- 58
	end -- 58
	return recoveryPath -- 60
end -- 51
____exports.prepareMobileResource = function(resource, catalogCommit, onProgress, onDone, repairIncomplete) -- 63
	if repairIncomplete == nil then -- 63
		repairIncomplete = false -- 68
	end -- 68
	if ____exports.isMobileResourceReady(resource) then -- 68
		onDone({ -- 71
			success = true, -- 71
			entry = installedEntry(resource) -- 71
		}) -- 71
		return -- 72
	end -- 72
	local index = math.max( -- 74
		1, -- 74
		math.min(resource.selectedVersion, #resource.versions) -- 74
	) -- 74
	local version = resource.versions[index] -- 75
	if not version then -- 75
		onDone({success = false, message = "resource version is unavailable"}) -- 77
		return -- 78
	end -- 78
	local recoveryPath -- 80
	local installPath = getResourceInstallPath(resource.id) -- 81
	if isResourceInstalled(resource.id) then -- 81
		if not repairIncomplete then -- 81
			onDone({success = false, message = "installed resource is incomplete; tap again to repair it", repairable = true}) -- 84
			return -- 89
		end -- 89
		recoveryPath = reserveRecoveryPath(resource.id) -- 91
		if not Content:move(installPath, recoveryPath) then -- 91
			onDone({success = false, message = "failed to preserve the incomplete installation"}) -- 93
			return -- 94
		end -- 94
	end -- 94
	(function() -- 97
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 97
			local result = __TS__Await(installResource( -- 98
				resource, -- 98
				version, -- 98
				{ -- 98
					catalogCommit = catalogCommit, -- 99
					onProgress = function(____, item) return onProgress(item.progress, item.message) end -- 100
				} -- 100
			)) -- 100
			if not result.success then -- 100
				local message = result.message or "installation failed" -- 103
				if recoveryPath and not Content:exist(installPath) then -- 103
					if Content:move(recoveryPath, installPath) then -- 103
						message = message .. "; previous installation restored" -- 105
					else -- 105
						message = message .. "; previous installation remains at " .. recoveryPath -- 106
					end -- 106
				end -- 106
				onDone({ -- 108
					success = false, -- 108
					message = message, -- 108
					repairable = isResourceInstalled(resource.id) -- 108
				}) -- 108
				return ____awaiter_resolve(nil) -- 108
			end -- 108
			onDone({ -- 111
				success = true, -- 111
				entry = installedEntry(resource) -- 111
			}) -- 111
		end) -- 111
	end)() -- 97
end -- 63
return ____exports -- 63