-- [ts]: Service.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local ____exports = {} -- 1
local buildState -- 1
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local Content = ____Dora.Content -- 3
local Director = ____Dora.Director -- 3
local Path = ____Dora.Path -- 3
local thread = ____Dora.thread -- 3
local ____Manifest = require("Tools.SelfUpdater.Manifest") -- 4
local compareVersions = ____Manifest.compareVersions -- 4
local updatePlatformForApp = ____Manifest.updatePlatformForApp -- 4
local isWindowsUpdatePlatform = ____Manifest.isWindowsUpdatePlatform -- 4
local ____UpdateSync = require("Tools.SelfUpdater.UpdateSync") -- 5
local checkGitHubRelease = ____UpdateSync.checkGitHubRelease -- 5
local prepareUpdatePackage = ____UpdateSync.prepareUpdatePackage -- 5
local syncUpdateManifest = ____UpdateSync.syncUpdateManifest -- 5
local updateSourcesForLocale = ____UpdateSync.updateSourcesForLocale -- 5
local zh = (string.match(App.locale, "^zh")) ~= nil -- 8
local major, minor, patch, revision = string.match(App.version, "(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 9
local currentVersion = (((("v" .. major) .. ".") .. minor) .. ".") .. patch -- 10
local currentRevision = tonumber(revision) or 0 -- 11
local source = updateSourcesForLocale(App.locale)[1] -- 12
local phase = "idle" -- 13
local snapshot -- 14
local progress -- 15
local message = "" -- 16
local checkedAt = 0 -- 17
local usedCache = false -- 18
local canceled = false -- 19
local serial = 0 -- 20
local extractedPath = "" -- 21
local prepared -- 23
local readEntryState -- 25
local publishEntryState -- 26
____exports.bindEntryState = function(read, publish) -- 27
	readEntryState = read -- 28
	publishEntryState = publish -- 28
end -- 27
local function changed() -- 30
	serial = serial + 1 -- 30
	if publishEntryState ~= nil then -- 30
		publishEntryState(buildState()) -- 30
	end -- 30
	Director.postNode:emit("EngineUpdateChanged") -- 30
end -- 30
local function fail(title, detail) -- 31
	phase = "error" -- 31
	message = (title .. ": ") .. detail -- 31
	progress = nil -- 31
	changed() -- 31
end -- 31
local function snapshotVersion(value) -- 32
	return value.source == "AtomGit" and value.manifest.version or value.version -- 32
end -- 32
local function snapshotDisplayVersion(value) -- 33
	return value.source == "AtomGit" and (value.manifest.version .. "-") .. tostring(value.manifest.revision) or value.version -- 33
end -- 33
____exports.compareSnapshotWithCurrent = function(value) -- 34
	local base = compareVersions( -- 35
		currentVersion, -- 35
		snapshotVersion(value) -- 35
	) -- 35
	if base ~= 0 or value.source == "GitHub" then -- 35
		return base -- 36
	end -- 36
	return currentRevision == value.manifest.revision and 0 or (currentRevision < value.manifest.revision and -1 or 1) -- 37
end -- 34
local function busy() -- 39
	return phase == "checking" or phase == "downloading" or phase == "canceling" or phase == "installing" -- 39
end -- 39
local function packageFor(value, platform) -- 40
	local ____temp_2 -- 40
	if value.source == "AtomGit" then -- 40
		____temp_2 = value.manifest.packages[platform] -- 40
	else -- 40
		____temp_2 = value.packages[platform] -- 40
	end -- 40
	return ____temp_2 -- 40
end -- 40
buildState = function() -- 41
	local platform = updatePlatformForApp() -- 42
	local ____temp_3 -- 43
	if snapshot and platform then -- 43
		____temp_3 = packageFor(snapshot, platform) -- 43
	else -- 43
		____temp_3 = nil -- 43
	end -- 43
	local item = ____temp_3 -- 43
	local comparison = snapshot and ____exports.compareSnapshotWithCurrent(snapshot) or nil -- 44
	return { -- 45
		serial = serial, -- 46
		phase = phase, -- 46
		source = source, -- 46
		currentVersion = (currentVersion .. "-") .. tostring(currentRevision), -- 46
		targetVersion = snapshot and snapshotDisplayVersion(snapshot) or nil, -- 47
		publishedAt = snapshot and (snapshot.source == "AtomGit" and snapshot.manifest.publishedAt or snapshot.publishedAt) or nil, -- 48
		releaseUrl = snapshot and "https://github.com/IppClub/Dora-SSR/releases/tag/" .. snapshotVersion(snapshot) or nil, -- 49
		available = checkedAt > 0 and not usedCache and comparison == -1 and phase ~= "checking" and phase ~= "error" and phase ~= "canceling" and (not platform or item ~= nil), -- 50
		comparison = comparison, -- 51
		platform = App.platform, -- 51
		packagePlatform = platform, -- 51
		packageSize = item and item.size, -- 51
		installSupported = item ~= nil and App.platform ~= "Linux", -- 52
		canDownload = item ~= nil and comparison ~= nil and comparison <= 0 and not busy() and not prepared, -- 53
		windows = platform ~= nil and isWindowsUpdatePlatform(platform), -- 54
		prepared = prepared ~= nil, -- 55
		checkedAt = checkedAt, -- 55
		usedCache = usedCache, -- 55
		message = message, -- 55
		progress = progress -- 55
	} -- 55
end -- 41
____exports.getState = function() return readEntryState and readEntryState() or buildState() end -- 58
____exports.checkForUpdates = function(selected) -- 59
	if selected == nil then -- 59
		selected = source -- 59
	end -- 59
	if busy() or prepared then -- 59
		return false -- 60
	end -- 60
	source = selected -- 61
	snapshot = nil -- 61
	checkedAt = 0 -- 61
	usedCache = false -- 61
	message = "" -- 61
	canceled = false -- 61
	phase = "checking" -- 61
	progress = nil -- 61
	changed(); -- 61
	(function() -- 62
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 62
			local ____hasReturned, ____returnValue -- 62
			local ____try = __TS__AsyncAwaiter(function() -- 62
				local options = { -- 64
					isCanceled = function() return canceled end, -- 64
					onProgress = function(value) -- 64
						progress = value -- 64
						changed() -- 64
					end -- 64
				} -- 64
				local result = __TS__Await(source == "AtomGit" and syncUpdateManifest(options) or checkGitHubRelease(options)) -- 65
				progress = nil -- 66
				if canceled then -- 66
					phase = "idle" -- 67
					message = zh and "检查已取消。" or "Check canceled." -- 67
					changed() -- 67
					____hasReturned = true -- 67
					return -- 67
				end -- 67
				if not result.success or not result.snapshot then -- 67
					fail(zh and "检查失败" or "Check failed", result.message or "Unable to read update metadata") -- 68
					____hasReturned = true -- 68
					return -- 68
				end -- 68
				snapshot = result.snapshot -- 69
				usedCache = result.usedCache == true -- 69
				checkedAt = os.time() -- 69
				message = result.message or "" -- 70
				phase = ____exports.compareSnapshotWithCurrent(snapshot) < 0 and "available" or "current" -- 70
				changed() -- 70
			end) -- 70
			____try = ____try.catch( -- 70
				____try, -- 70
				function(____, err) -- 70
					return __TS__AsyncAwaiter(function() -- 70
						fail( -- 71
							zh and "检查失败" or "Check failed", -- 71
							tostring(err) -- 71
						) -- 71
					end) -- 71
				end -- 71
			) -- 71
			__TS__Await(____try) -- 63
			if ____hasReturned then -- 63
				return ____awaiter_resolve(nil, ____returnValue) -- 63
			end -- 63
		end) -- 63
	end)() -- 62
	return true -- 73
end -- 59
____exports.cancelOperation = function() -- 75
	if phase ~= "checking" and phase ~= "downloading" then -- 75
		return false -- 76
	end -- 76
	canceled = true -- 77
	phase = "canceling" -- 77
	changed() -- 77
	return true -- 77
end -- 75
local function installPreparedPackage(pending) -- 79
	local ____pending_6 = pending -- 80
	local valueSnapshot = ____pending_6.snapshot -- 80
	local platform = ____pending_6.platform -- 80
	local value = ____pending_6.update -- 80
	local version = snapshotVersion(valueSnapshot) -- 81
	local ____temp_7 -- 82
	if valueSnapshot.source == "AtomGit" then -- 82
		____temp_7 = valueSnapshot.manifest.packages[platform] -- 83
	else -- 83
		____temp_7 = valueSnapshot.packages[platform] -- 84
	end -- 84
	local packageInfo = ____temp_7 -- 82
	if not packageInfo then -- 82
		prepared = nil -- 85
		return -- 85
	end -- 85
	phase = "installing" -- 86
	changed() -- 86
	if pending.installPath and Content:exist(pending.installPath) then -- 86
		progress = {progress = 1, message = zh and "正在启动安装程序…" or "Starting installer…", source = value.source} -- 88
		App:install(pending.installPath) -- 89
		phase = "ready" -- 90
		changed() -- 90
		progress = nil -- 91
		return -- 92
	end -- 92
	if __TS__StringEndsWith(platform, "-msi") then -- 92
		pending.installPath = value.file -- 95
		App:install(value.file) -- 96
		phase = "ready" -- 97
		changed() -- 97
		progress = nil -- 98
		return -- 99
	end -- 99
	progress = {progress = 0.94, message = zh and "正在解压更新…" or "Extracting update…", source = value.source} -- 101
	thread(function() -- 102
		local unzipPath = Path( -- 103
			Path:getPath(value.file), -- 103
			"unpacked" -- 103
		) -- 103
		if Content:exist(unzipPath) then -- 103
			Content:remove(unzipPath) -- 104
		end -- 104
		extractedPath = unzipPath -- 105
		local success = Content:unzipAsync(value.file, unzipPath) -- 106
		if not success then -- 106
			phase = "ready" -- 108
			changed() -- 108
			progress = nil -- 109
			Content:remove(value.cleanupPath) -- 110
			prepared = nil -- 111
			extractedPath = "" -- 112
			fail(zh and "解压失败" or "Failed to extract update", zh and "无法解压文件：" .. packageInfo.file or "Failed to extract: " .. packageInfo.file) -- 113
			return -- 117
		end -- 117
		progress = {progress = 1, message = zh and "正在启动安装程序…" or "Starting installer…", source = value.source} -- 119
		local installPath = platform == "android" and Path(unzipPath, ("dora-ssr-" .. version) .. "-android.apk") or ((platform == "macos-universal" or platform == "macos-arm64") and Path(unzipPath, "Dora.app") or unzipPath) -- 120
		if not Content:exist(installPath) then -- 120
			phase = "ready" -- 126
			changed() -- 126
			progress = nil -- 127
			Content:remove(value.cleanupPath) -- 128
			prepared = nil -- 129
			extractedPath = "" -- 130
			fail(zh and "安装包无效" or "Invalid update package", zh and "更新包缺少预期的安装入口。" or "The update package does not contain the expected installer.") -- 131
			return -- 135
		end -- 135
		pending.installPath = installPath -- 137
		App:install(installPath) -- 138
		phase = "ready" -- 139
		changed() -- 139
		progress = nil -- 140
	end) -- 102
end -- 79
____exports.downloadUpdate = function(target) -- 144
	local platform = target or updatePlatformForApp() -- 145
	if busy() or prepared or not snapshot or not platform or not packageFor(snapshot, platform) then -- 145
		return false -- 146
	end -- 146
	if ____exports.compareSnapshotWithCurrent(snapshot) > 0 then -- 146
		return false -- 148
	end -- 148
	local installed = updatePlatformForApp() -- 149
	if target and target ~= installed and (not installed or not isWindowsUpdatePlatform(installed) or not isWindowsUpdatePlatform(target) or __TS__StringEndsWith(installed, "-msi") ~= __TS__StringEndsWith(target, "-msi")) then -- 149
		return false -- 150
	end -- 150
	local valueSnapshot = snapshot -- 151
	phase = "downloading" -- 152
	canceled = false -- 152
	message = "" -- 152
	progress = nil -- 152
	changed(); -- 152
	(function() -- 153
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 153
			local ____hasReturned, ____returnValue -- 153
			local ____try = __TS__AsyncAwaiter(function() -- 153
				local update = __TS__Await(prepareUpdatePackage( -- 155
					valueSnapshot, -- 155
					platform, -- 155
					{ -- 155
						isCanceled = function() return canceled end, -- 155
						onProgress = function(____, value) -- 155
							progress = value -- 155
							changed() -- 155
						end -- 155
					} -- 155
				)) -- 155
				progress = nil -- 156
				if canceled then -- 156
					if update then -- 156
						Content:remove(update.cleanupPath) -- 157
					end -- 157
					phase = ____exports.compareSnapshotWithCurrent(valueSnapshot) < 0 and "available" or "current" -- 157
					message = zh and "下载已取消。" or "Download canceled." -- 157
					changed() -- 157
					____hasReturned = true -- 157
					return -- 157
				end -- 157
				if not update then -- 157
					fail(zh and "下载失败" or "Download failed", zh and "更新源不可用，或安装包未通过校验。可重试或切换更新源。" or "Source unavailable or package verification failed. Retry or switch sources.") -- 158
					____hasReturned = true -- 158
					return -- 158
				end -- 158
				prepared = {snapshot = valueSnapshot, platform = platform, update = update} -- 159
				phase = "ready" -- 159
				changed() -- 159
			end) -- 159
			____try = ____try.catch( -- 159
				____try, -- 159
				function(____, err) -- 159
					return __TS__AsyncAwaiter(function() -- 159
						fail( -- 160
							zh and "下载失败" or "Download failed", -- 160
							tostring(err) -- 160
						) -- 160
					end) -- 160
				end -- 160
			) -- 160
			__TS__Await(____try) -- 154
			if ____hasReturned then -- 154
				return ____awaiter_resolve(nil, ____returnValue) -- 154
			end -- 154
		end) -- 154
	end)() -- 153
	return true -- 162
end -- 144
____exports.installUpdate = function(confirmed) -- 164
	if not confirmed or phase ~= "ready" or not prepared then -- 164
		return false -- 165
	end -- 165
	installPreparedPackage(prepared) -- 166
	return true -- 166
end -- 164
____exports.discardPrepared = function() -- 168
	if busy() or not prepared then -- 168
		return false -- 169
	end -- 169
	Content:remove(prepared.update.cleanupPath) -- 170
	prepared = nil -- 170
	extractedPath = "" -- 170
	phase = "idle" -- 170
	changed() -- 170
	return true -- 170
end -- 168
return ____exports -- 168
