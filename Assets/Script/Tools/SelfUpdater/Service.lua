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
local ignoredVersion -- 24
local readEntryState -- 26
local publishEntryState -- 27
____exports.bindEntryState = function(read, publish, ignored) -- 28
	readEntryState = read -- 29
	publishEntryState = publish -- 29
	ignoredVersion = ignored -- 30
end -- 28
local function changed() -- 32
	serial = serial + 1 -- 32
	if publishEntryState ~= nil then -- 32
		publishEntryState(buildState()) -- 32
	end -- 32
	Director.postNode:emit("EngineUpdateChanged") -- 32
end -- 32
local function fail(title, detail) -- 33
	phase = "error" -- 33
	message = (title .. ": ") .. detail -- 33
	progress = nil -- 33
	changed() -- 33
end -- 33
local function snapshotVersion(value) -- 34
	return value.source == "AtomGit" and value.manifest.version or value.version -- 34
end -- 34
local function snapshotDisplayVersion(value) -- 35
	return value.source == "AtomGit" and (value.manifest.version .. "-") .. tostring(value.manifest.revision) or value.version -- 35
end -- 35
____exports.compareSnapshotWithCurrent = function(value) -- 36
	local base = compareVersions( -- 37
		currentVersion, -- 37
		snapshotVersion(value) -- 37
	) -- 37
	if base ~= 0 or value.source == "GitHub" then -- 37
		return base -- 38
	end -- 38
	return currentRevision == value.manifest.revision and 0 or (currentRevision < value.manifest.revision and -1 or 1) -- 39
end -- 36
local function busy() -- 41
	return phase == "checking" or phase == "downloading" or phase == "canceling" or phase == "installing" -- 41
end -- 41
local function packageFor(value, platform) -- 42
	local ____temp_2 -- 42
	if value.source == "AtomGit" then -- 42
		____temp_2 = value.manifest.packages[platform] -- 42
	else -- 42
		____temp_2 = value.packages[platform] -- 42
	end -- 42
	return ____temp_2 -- 42
end -- 42
buildState = function() -- 43
	local platform = updatePlatformForApp() -- 44
	local ____temp_3 -- 45
	if snapshot and platform then -- 45
		____temp_3 = packageFor(snapshot, platform) -- 45
	else -- 45
		____temp_3 = nil -- 45
	end -- 45
	local item = ____temp_3 -- 45
	local comparison = snapshot and ____exports.compareSnapshotWithCurrent(snapshot) or nil -- 46
	local ignored = snapshot ~= nil and snapshotDisplayVersion(snapshot) == ignoredVersion -- 47
	local newer = checkedAt > 0 and not usedCache and comparison == -1 and (not platform or item ~= nil) -- 48
	return { -- 49
		serial = serial, -- 50
		phase = phase, -- 50
		source = source, -- 50
		currentVersion = (currentVersion .. "-") .. tostring(currentRevision), -- 50
		targetVersion = snapshot and snapshotDisplayVersion(snapshot) or nil, -- 51
		publishedAt = snapshot and (snapshot.source == "AtomGit" and snapshot.manifest.publishedAt or snapshot.publishedAt) or nil, -- 52
		releaseUrl = snapshot and "https://github.com/IppClub/Dora-SSR/releases/tag/" .. snapshotVersion(snapshot) or nil, -- 53
		available = newer and not ignored and phase ~= "checking" and phase ~= "error" and phase ~= "canceling", -- 54
		ignored = ignored, -- 55
		ignoredVersion = ignoredVersion, -- 55
		canIgnore = newer and not ignored and not busy() and not prepared, -- 55
		comparison = comparison, -- 56
		platform = App.platform, -- 56
		packagePlatform = platform, -- 56
		packageSize = item and item.size, -- 56
		installSupported = item ~= nil and App.platform ~= "Linux", -- 57
		canDownload = item ~= nil and comparison ~= nil and comparison <= 0 and not busy() and not prepared, -- 58
		windows = platform ~= nil and isWindowsUpdatePlatform(platform), -- 59
		prepared = prepared ~= nil, -- 60
		checkedAt = checkedAt, -- 60
		usedCache = usedCache, -- 60
		message = message, -- 60
		progress = progress -- 60
	} -- 60
end -- 43
____exports.getState = function() return readEntryState and readEntryState() or buildState() end -- 63
____exports.ignoreUpdate = function() -- 64
	if not buildState().canIgnore or not snapshot then -- 64
		return false -- 65
	end -- 65
	ignoredVersion = snapshotDisplayVersion(snapshot) -- 66
	changed() -- 66
	return true -- 66
end -- 64
____exports.checkForUpdates = function(selected) -- 68
	if selected == nil then -- 68
		selected = source -- 68
	end -- 68
	if busy() or prepared then -- 68
		return false -- 69
	end -- 69
	source = selected -- 70
	snapshot = nil -- 70
	checkedAt = 0 -- 70
	usedCache = false -- 70
	message = "" -- 70
	canceled = false -- 70
	phase = "checking" -- 70
	progress = nil -- 70
	changed(); -- 70
	(function() -- 71
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 71
			local ____hasReturned, ____returnValue -- 71
			local ____try = __TS__AsyncAwaiter(function() -- 71
				local options = { -- 73
					isCanceled = function() return canceled end, -- 73
					onProgress = function(____, value) -- 73
						progress = value -- 73
						changed() -- 73
					end -- 73
				} -- 73
				local result = __TS__Await(source == "AtomGit" and syncUpdateManifest(options) or checkGitHubRelease(options)) -- 74
				progress = nil -- 75
				if canceled then -- 75
					phase = "idle" -- 76
					message = zh and "检查已取消。" or "Check canceled." -- 76
					changed() -- 76
					____hasReturned = true -- 76
					return -- 76
				end -- 76
				if not result.success or not result.snapshot then -- 76
					fail(zh and "检查失败" or "Check failed", result.message or "Unable to read update metadata") -- 77
					____hasReturned = true -- 77
					return -- 77
				end -- 77
				snapshot = result.snapshot -- 78
				usedCache = result.usedCache == true -- 78
				checkedAt = os.time() -- 78
				message = result.message or "" -- 79
				phase = ____exports.compareSnapshotWithCurrent(snapshot) < 0 and "available" or "current" -- 79
				changed() -- 79
			end) -- 79
			____try = ____try.catch( -- 79
				____try, -- 79
				function(____, err) -- 79
					return __TS__AsyncAwaiter(function() -- 79
						fail( -- 80
							zh and "检查失败" or "Check failed", -- 80
							tostring(err) -- 80
						) -- 80
					end) -- 80
				end -- 80
			) -- 80
			__TS__Await(____try) -- 72
			if ____hasReturned then -- 72
				return ____awaiter_resolve(nil, ____returnValue) -- 72
			end -- 72
		end) -- 72
	end)() -- 71
	return true -- 82
end -- 68
____exports.cancelOperation = function() -- 84
	if phase ~= "checking" and phase ~= "downloading" then -- 84
		return false -- 85
	end -- 85
	canceled = true -- 86
	phase = "canceling" -- 86
	changed() -- 86
	return true -- 86
end -- 84
local function installPreparedPackage(pending) -- 88
	local ____pending_6 = pending -- 89
	local valueSnapshot = ____pending_6.snapshot -- 89
	local platform = ____pending_6.platform -- 89
	local value = ____pending_6.update -- 89
	local version = snapshotVersion(valueSnapshot) -- 90
	local ____temp_7 -- 91
	if valueSnapshot.source == "AtomGit" then -- 91
		____temp_7 = valueSnapshot.manifest.packages[platform] -- 92
	else -- 92
		____temp_7 = valueSnapshot.packages[platform] -- 93
	end -- 93
	local packageInfo = ____temp_7 -- 91
	if not packageInfo then -- 91
		prepared = nil -- 94
		return -- 94
	end -- 94
	phase = "installing" -- 95
	changed() -- 95
	if pending.installPath and Content:exist(pending.installPath) then -- 95
		progress = {progress = 1, message = zh and "正在启动安装程序…" or "Starting installer…", source = value.source} -- 97
		App:install(pending.installPath) -- 98
		phase = "ready" -- 99
		progress = nil -- 99
		changed() -- 99
		return -- 100
	end -- 100
	if __TS__StringEndsWith(platform, "-msi") then -- 100
		pending.installPath = value.file -- 103
		App:install(value.file) -- 104
		phase = "ready" -- 105
		progress = nil -- 105
		changed() -- 105
		return -- 106
	end -- 106
	progress = {progress = 0.94, message = zh and "正在解压更新…" or "Extracting update…", source = value.source} -- 108
	thread(function() -- 109
		local unzipPath = Path( -- 110
			Path:getPath(value.file), -- 110
			"unpacked" -- 110
		) -- 110
		if Content:exist(unzipPath) then -- 110
			Content:remove(unzipPath) -- 111
		end -- 111
		extractedPath = unzipPath -- 112
		local success = Content:unzipAsync(value.file, unzipPath) -- 113
		if not success then -- 113
			phase = "ready" -- 115
			changed() -- 115
			progress = nil -- 116
			Content:remove(value.cleanupPath) -- 117
			prepared = nil -- 118
			extractedPath = "" -- 119
			fail(zh and "解压失败" or "Failed to extract update", zh and "无法解压文件：" .. packageInfo.file or "Failed to extract: " .. packageInfo.file) -- 120
			return -- 124
		end -- 124
		progress = {progress = 1, message = zh and "正在启动安装程序…" or "Starting installer…", source = value.source} -- 126
		local installPath = platform == "android" and Path(unzipPath, ("dora-ssr-" .. version) .. "-android.apk") or ((platform == "macos-universal" or platform == "macos-arm64") and Path(unzipPath, "Dora.app") or unzipPath) -- 127
		if not Content:exist(installPath) then -- 127
			phase = "ready" -- 133
			changed() -- 133
			progress = nil -- 134
			Content:remove(value.cleanupPath) -- 135
			prepared = nil -- 136
			extractedPath = "" -- 137
			fail(zh and "安装包无效" or "Invalid update package", zh and "更新包缺少预期的安装入口。" or "The update package does not contain the expected installer.") -- 138
			return -- 142
		end -- 142
		pending.installPath = installPath -- 144
		App:install(installPath) -- 145
		phase = "ready" -- 146
		progress = nil -- 146
		changed() -- 146
	end) -- 109
end -- 88
____exports.downloadUpdate = function(target) -- 150
	local platform = target or updatePlatformForApp() -- 151
	if busy() or prepared or not snapshot or not platform or not packageFor(snapshot, platform) then -- 151
		return false -- 152
	end -- 152
	if ____exports.compareSnapshotWithCurrent(snapshot) > 0 then -- 152
		return false -- 154
	end -- 154
	local installed = updatePlatformForApp() -- 155
	if target and target ~= installed and (not installed or not isWindowsUpdatePlatform(installed) or not isWindowsUpdatePlatform(target) or __TS__StringEndsWith(installed, "-msi") ~= __TS__StringEndsWith(target, "-msi")) then -- 155
		return false -- 156
	end -- 156
	local valueSnapshot = snapshot -- 157
	phase = "downloading" -- 158
	canceled = false -- 158
	message = "" -- 158
	progress = nil -- 158
	changed(); -- 158
	(function() -- 159
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 159
			local ____hasReturned, ____returnValue -- 159
			local ____try = __TS__AsyncAwaiter(function() -- 159
				local update = __TS__Await(prepareUpdatePackage( -- 161
					valueSnapshot, -- 161
					platform, -- 161
					{ -- 161
						isCanceled = function() return canceled end, -- 161
						onProgress = function(____, value) -- 161
							progress = value -- 161
							changed() -- 161
						end -- 161
					} -- 161
				)) -- 161
				progress = nil -- 162
				if canceled then -- 162
					if update then -- 162
						Content:remove(update.cleanupPath) -- 163
					end -- 163
					phase = ____exports.compareSnapshotWithCurrent(valueSnapshot) < 0 and "available" or "current" -- 163
					message = zh and "下载已取消。" or "Download canceled." -- 163
					changed() -- 163
					____hasReturned = true -- 163
					return -- 163
				end -- 163
				if not update then -- 163
					fail(zh and "下载失败" or "Download failed", zh and "更新源不可用，或安装包未通过校验。可重试或切换更新源。" or "Source unavailable or package verification failed. Retry or switch sources.") -- 164
					____hasReturned = true -- 164
					return -- 164
				end -- 164
				prepared = {snapshot = valueSnapshot, platform = platform, update = update} -- 165
				phase = "ready" -- 165
				changed() -- 165
			end) -- 165
			____try = ____try.catch( -- 165
				____try, -- 165
				function(____, err) -- 165
					return __TS__AsyncAwaiter(function() -- 165
						fail( -- 166
							zh and "下载失败" or "Download failed", -- 166
							tostring(err) -- 166
						) -- 166
					end) -- 166
				end -- 166
			) -- 166
			__TS__Await(____try) -- 160
			if ____hasReturned then -- 160
				return ____awaiter_resolve(nil, ____returnValue) -- 160
			end -- 160
		end) -- 160
	end)() -- 159
	return true -- 168
end -- 150
____exports.installUpdate = function(confirmed) -- 170
	if not confirmed or phase ~= "ready" or not prepared then -- 170
		return false -- 171
	end -- 171
	installPreparedPackage(prepared) -- 172
	return true -- 172
end -- 170
____exports.discardPrepared = function() -- 174
	if busy() or not prepared then -- 174
		return false -- 175
	end -- 175
	Content:remove(prepared.update.cleanupPath) -- 176
	prepared = nil -- 176
	extractedPath = "" -- 176
	phase = "idle" -- 176
	changed() -- 176
	return true -- 176
end -- 174
return ____exports -- 174