-- [ts]: SelfUpdater.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 21
local App = ____Dora.App -- 21
local Content = ____Dora.Content -- 21
local Node = ____Dora.Node -- 21
local Path = ____Dora.Path -- 21
local thread = ____Dora.thread -- 21
local threadLoop = ____Dora.threadLoop -- 21
local Vec2 = ____Dora.Vec2 -- 21
local ImGui = require("ImGui") -- 23
local ____Manifest = require("Tools.SelfUpdater.Manifest") -- 24
local compareVersions = ____Manifest.compareVersions -- 25
local updatePlatformForApp = ____Manifest.updatePlatformForApp -- 26
local ____UpdateSync = require("Tools.SelfUpdater.UpdateSync") -- 29
local checkGitHubRelease = ____UpdateSync.checkGitHubRelease -- 30
local loadCachedUpdateManifest = ____UpdateSync.loadCachedUpdateManifest -- 31
local prepareUpdatePackage = ____UpdateSync.prepareUpdatePackage -- 32
local syncUpdateManifest = ____UpdateSync.syncUpdateManifest -- 33
local updateSourcesForLocale = ____UpdateSync.updateSourcesForLocale -- 34
local zh = false -- 41
do -- 41
	local matched = string.match(App.locale, "^zh") -- 43
	zh = matched ~= nil -- 44
end -- 44
local major, minor, patch, revision = string.match(App.version, "(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 47
local currentVersion = (((("v" .. major) .. ".") .. minor) .. ".") .. patch -- 48
local currentRevision = tonumber(revision) or 0 -- 49
local currentDisplayVersion = (currentVersion .. "-") .. tostring(currentRevision) -- 50
local ____App_0 = App -- 51
local themeColor = ____App_0.themeColor -- 51
local sources = updateSourcesForLocale(App.locale) -- 52
local currentSource = 1 -- 53
local function selectedSource() -- 54
	return sources[currentSource] -- 54
end -- 54
local windowFlags = {"NoDecoration", "NoSavedSettings", "NoMove"} -- 56
local messagePopupFlags = {"NoSavedSettings", "AlwaysAutoResize", "NoTitleBar"} -- 61
local snapshot -- 67
local checking = false -- 68
local preparing = false -- 69
local installing = false -- 70
local canceled = false -- 71
local progress -- 72
local prepared -- 79
local extractedPath = "" -- 80
local popupTitle = "" -- 81
local popupMessage = "" -- 82
local popupShow = false -- 83
local function showPopup(title, message) -- 85
	popupTitle = title -- 86
	popupMessage = message -- 87
	popupShow = true -- 88
end -- 85
local function applySnapshot(value) -- 91
	snapshot = value -- 92
end -- 91
local cached = loadCachedUpdateManifest() -- 95
if selectedSource() == "AtomGit" and cached.success and cached.snapshot then -- 95
	applySnapshot(cached.snapshot) -- 96
end -- 96
local function loadSnapshotForSelectedSource() -- 98
	snapshot = nil -- 99
	if selectedSource() ~= "AtomGit" then -- 99
		return -- 100
	end -- 100
	local result = loadCachedUpdateManifest() -- 101
	if result.success and result.snapshot then -- 101
		applySnapshot(result.snapshot) -- 102
	end -- 102
end -- 98
local function snapshotVersion(value) -- 105
	return value.source == "AtomGit" and value.manifest.version or value.version -- 105
end -- 105
local function snapshotRevision(value) -- 109
	return value.source == "AtomGit" and value.manifest.revision or nil -- 109
end -- 109
local function snapshotDisplayVersion(value) -- 113
	local version = snapshotVersion(value) -- 114
	local revision = snapshotRevision(value) -- 115
	return revision == nil and version or (version .. "-") .. tostring(revision) -- 116
end -- 113
local function compareSnapshotWithCurrent(value) -- 119
	local base = compareVersions( -- 120
		currentVersion, -- 120
		snapshotVersion(value) -- 120
	) -- 120
	if base ~= 0 or value.source == "GitHub" then -- 120
		return base -- 121
	end -- 121
	return currentRevision == value.manifest.revision and 0 or (currentRevision < value.manifest.revision and -1 or 1) -- 122
end -- 119
local function checkForUpdates() -- 127
	if checking or preparing or installing then -- 127
		return -- 128
	end -- 128
	checking = true -- 129
	canceled = false -- 130
	local source = selectedSource() -- 131
	progress = {progress = 0, message = source == "AtomGit" and (zh and "正在连接 AtomGit 更新仓库…" or "Connecting to the AtomGit update repository…") or (zh and "正在查询 GitHub Release…" or "Checking GitHub Releases…"), source = source}; -- 132
	(function() -- 139
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 139
			local result = __TS__Await(source == "AtomGit" and syncUpdateManifest({ -- 140
				isCanceled = function() return canceled end, -- 141
				onProgress = function(____, status) -- 142
					progress = status -- 143
				end -- 142
			}) or checkGitHubRelease({ -- 142
				isCanceled = function() return canceled end, -- 146
				onProgress = function(____, status) -- 147
					progress = status -- 148
				end -- 147
			})) -- 147
			checking = false -- 151
			progress = nil -- 152
			if result.success and result.snapshot then -- 152
				applySnapshot(result.snapshot) -- 154
				if source == "AtomGit" and result.usedCache and result.message then -- 154
					showPopup(zh and "正在使用已验证缓存" or "Using verified cache", result.message) -- 156
				end -- 156
				return ____awaiter_resolve(nil) -- 156
			end -- 156
			showPopup(zh and "检查更新失败" or "Failed to check for updates", result.message or (zh and "无法读取可信更新清单。" or "Unable to read trusted update metadata.")) -- 163
		end) -- 163
	end)() -- 139
end -- 127
local function installPreparedPackage(pending) -- 170
	local ____pending_1 = pending -- 171
	local valueSnapshot = ____pending_1.snapshot -- 171
	local platform = ____pending_1.platform -- 171
	local value = ____pending_1.update -- 171
	local version = snapshotVersion(valueSnapshot) -- 172
	local ____temp_2 -- 173
	if valueSnapshot.source == "AtomGit" then -- 173
		____temp_2 = valueSnapshot.manifest.packages[platform] -- 174
	else -- 174
		____temp_2 = valueSnapshot.packages[platform] -- 175
	end -- 175
	local packageInfo = ____temp_2 -- 173
	if not packageInfo then -- 173
		prepared = nil -- 176
		return -- 176
	end -- 176
	installing = true -- 177
	if pending.installPath and Content:exist(pending.installPath) then -- 177
		progress = {progress = 1, message = zh and "正在启动安装程序…" or "Starting installer…", source = value.source} -- 179
		App:install(pending.installPath) -- 180
		installing = false -- 181
		progress = nil -- 182
		return -- 183
	end -- 183
	progress = {progress = 0.94, message = zh and "正在解压更新…" or "Extracting update…", source = value.source} -- 185
	thread(function() -- 186
		local unzipPath = Path( -- 187
			Path:getPath(value.file), -- 187
			"unpacked" -- 187
		) -- 187
		if Content:exist(unzipPath) then -- 187
			Content:remove(unzipPath) -- 188
		end -- 188
		extractedPath = unzipPath -- 189
		local success = Content:unzipAsync(value.file, unzipPath) -- 190
		if not success then -- 190
			installing = false -- 192
			progress = nil -- 193
			Content:remove(value.cleanupPath) -- 194
			prepared = nil -- 195
			extractedPath = "" -- 196
			showPopup(zh and "解压失败" or "Failed to extract update", zh and "无法解压文件：" .. packageInfo.file or "Failed to extract: " .. packageInfo.file) -- 197
			return -- 201
		end -- 201
		progress = {progress = 1, message = zh and "正在启动安装程序…" or "Starting installer…", source = value.source} -- 203
		local installPath = platform == "android" and Path(unzipPath, ("dora-ssr-" .. version) .. "-android.apk") or ((platform == "macos-universal" or platform == "macos-arm64") and Path(unzipPath, "Dora.app") or unzipPath) -- 204
		if not Content:exist(installPath) then -- 204
			installing = false -- 210
			progress = nil -- 211
			Content:remove(value.cleanupPath) -- 212
			prepared = nil -- 213
			extractedPath = "" -- 214
			showPopup(zh and "安装包无效" or "Invalid update package", zh and "更新包缺少预期的安装入口。" or "The update package does not contain the expected installer.") -- 215
			return -- 219
		end -- 219
		pending.installPath = installPath -- 221
		App:install(installPath) -- 222
		installing = false -- 223
		progress = nil -- 224
	end) -- 186
end -- 170
local function beginUpdate() -- 228
	if not snapshot or preparing or installing then -- 228
		return -- 229
	end -- 229
	local platform = updatePlatformForApp() -- 230
	if not platform then -- 230
		return -- 231
	end -- 231
	preparing = true -- 232
	canceled = false -- 233
	progress = {progress = 0, message = zh and "正在准备下载…" or "Preparing download…"}; -- 234
	(function() -- 235
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 235
			local valueSnapshot = snapshot -- 236
			local value = __TS__Await(prepareUpdatePackage( -- 237
				valueSnapshot, -- 237
				platform, -- 237
				{ -- 237
					isCanceled = function() return canceled end, -- 238
					onProgress = function(____, status) -- 239
						progress = status -- 240
					end -- 239
				} -- 239
			)) -- 239
			preparing = false -- 243
			if not value then -- 243
				progress = nil -- 245
				if not canceled then -- 245
					showPopup(zh and "下载更新失败" or "Failed to download update", zh and valueSnapshot.source .. " 下载不可用，或安装包校验失败。" or valueSnapshot.source .. " is unavailable, or the package did not pass verification.") -- 247
				end -- 247
				return ____awaiter_resolve(nil) -- 247
			end -- 247
			prepared = {snapshot = valueSnapshot, platform = platform, update = value} -- 254
			installPreparedPackage(prepared) -- 259
		end) -- 259
	end)() -- 235
end -- 228
local function cancelCurrentOperation() -- 263
	canceled = true -- 264
	progress = nil -- 265
end -- 263
local function drawMessagePopup() -- 268
	ImGui.Text(popupTitle) -- 269
	ImGui.Separator() -- 270
	ImGui.PushTextWrapPos( -- 271
		360, -- 271
		function() return ImGui.TextWrapped(popupMessage) end -- 271
	) -- 271
	if ImGui.Button( -- 271
		zh and "确认" or "OK", -- 272
		Vec2(360, 30) -- 272
	) then -- 272
		ImGui.CloseCurrentPopup() -- 273
	end -- 273
end -- 268
local function drawPlatformMessage() -- 277
	repeat -- 277
		local ____switch44 = App.platform -- 277
		local ____cond44 = ____switch44 == "Linux" -- 277
		if ____cond44 then -- 277
			ImGui.TextWrapped(zh and "请通过 Dora SSR PPA，使用 apt 工具管理更新。" or "Use the Dora SSR PPA and apt to manage updates.") -- 280
			return true -- 285
		end -- 285
		____cond44 = ____cond44 or ____switch44 == "macOS" -- 285
		if ____cond44 then -- 285
			ImGui.TextWrapped(zh and "可直接在应用内更新 Dora SSR；如果当前安装由 Homebrew 管理，也可以继续使用 brew upgrade。" or "Dora SSR can update itself in the app. If this installation is managed by Homebrew, you can continue to use brew upgrade.") -- 287
			return false -- 292
		end -- 292
		do -- 292
			return false -- 294
		end -- 294
	until true -- 294
end -- 277
threadLoop(function() -- 298
	local ____App_visualSize_3 = App.visualSize -- 299
	local width = ____App_visualSize_3.width -- 299
	ImGui.SetNextWindowPos( -- 300
		Vec2(width - 10, 10), -- 300
		"Always", -- 300
		Vec2(1, 0) -- 300
	) -- 300
	ImGui.SetNextWindowSize( -- 301
		Vec2(430, 0), -- 301
		"Always" -- 301
	) -- 301
	ImGui.Begin( -- 302
		"Dora Updater", -- 302
		windowFlags, -- 302
		function() -- 302
			ImGui.Text(zh and "Dora SSR 自更新工具" or "Dora SSR Self Updater") -- 303
			ImGui.SameLine() -- 304
			ImGui.TextDisabled("(?)") -- 305
			if ImGui.IsItemHovered() then -- 305
				ImGui.BeginTooltip(function() -- 307
					ImGui.PushTextWrapPos( -- 308
						340, -- 308
						function() -- 308
							ImGui.Text(zh and "可手动切换 GitHub 和 AtomGit 两种完整更新模式。中文环境默认使用 AtomGit，其它语言默认使用 GitHub；两种模式都会核对安装包大小和 SHA-256。" or "Choose either the complete GitHub or AtomGit update mode. Chinese locales default to AtomGit; other locales default to GitHub. Both modes verify package size and SHA-256.") -- 309
						end -- 308
					) -- 308
				end) -- 307
			end -- 307
			ImGui.Separator() -- 317
			drawPlatformMessage() -- 318
			ImGui.TextColored(themeColor, zh and "更新模式：" or "Update mode:") -- 320
			ImGui.SameLine() -- 321
			local sourceChanged, sourceIndex = ImGui.Combo("##update-source", currentSource, sources) -- 322
			if sourceChanged and not checking and not preparing and not installing then -- 322
				currentSource = sourceIndex -- 324
				loadSnapshotForSelectedSource() -- 325
			end -- 325
			ImGui.TextColored(themeColor, zh and "当前版本：" or "Current version:") -- 328
			ImGui.SameLine() -- 329
			ImGui.Text(currentDisplayVersion) -- 330
			if snapshot then -- 330
				local visibleSnapshot = snapshot -- 332
				ImGui.TextColored(themeColor, zh and "稳定版本：" or "Stable version:") -- 333
				ImGui.SameLine() -- 334
				ImGui.Text(snapshotDisplayVersion(visibleSnapshot)) -- 335
				local comparison = compareSnapshotWithCurrent(visibleSnapshot) -- 336
				ImGui.PushTextWrapPos( -- 337
					410, -- 337
					function() -- 337
						if comparison < 0 then -- 337
							ImGui.TextColored(themeColor, zh and "有可用更新！" or "Update available!") -- 339
						elseif comparison == 0 then -- 339
							ImGui.TextColored(themeColor, visibleSnapshot.source == "GitHub" and (zh and "Release 版本相同，可重新下载以获取可能更新的 revision。" or "The Release version matches; redownload to get a possible newer revision.") or (zh and "已是最新版，可按需重新下载。" or "Already up to date; you can redownload when needed.")) -- 341
						else -- 341
							ImGui.TextColored(themeColor, zh and "当前版本高于稳定版本。" or "Current version is newer than stable.") -- 348
						end -- 348
					end -- 337
				) -- 337
			end -- 337
			if progress then -- 337
				ImGui.Separator() -- 354
				ImGui.TextWrapped((progress.source and progress.source .. " · " or "") .. progress.message) -- 355
				ImGui.ProgressBar( -- 358
					progress.progress, -- 358
					Vec2(-1, 28) -- 358
				) -- 358
				if not installing and ImGui.Button( -- 358
					zh and "取消" or "Cancel", -- 359
					Vec2(-1, 30) -- 359
				) then -- 359
					cancelCurrentOperation() -- 360
				end -- 360
			else -- 360
				if ImGui.Button( -- 360
					zh and "检查更新" or "Check for updates", -- 363
					Vec2(-1, 30) -- 363
				) then -- 363
					checkForUpdates() -- 364
				end -- 364
				local platform = updatePlatformForApp() -- 366
				local installSupported = platform == "android" or platform == "windows-x86" or platform == "macos-universal" or platform == "windows-x64" or platform == "macos-arm64" -- 367
				if installSupported then -- 367
					if prepared then -- 367
						local pending = prepared -- 374
						ImGui.TextColored(themeColor, zh and pending.update.source .. " 安装包已下载并验证。" or pending.update.source .. " package is downloaded and verified.") -- 375
						if ImGui.Button( -- 375
							zh and "继续安装" or "Continue installation", -- 381
							Vec2(-1, 30) -- 381
						) then -- 381
							installPreparedPackage(pending) -- 382
						end -- 382
					elseif snapshot then -- 382
						local comparison = compareSnapshotWithCurrent(snapshot) -- 385
						if ImGui.Button( -- 385
							comparison < 0 and (zh and "下载并安装" or "Download and install") or (zh and "重新下载并安装" or "Redownload and install"), -- 387
							Vec2(-1, 30) -- 390
						) then -- 390
							beginUpdate() -- 392
						end -- 392
					end -- 392
				end -- 392
			end -- 392
			if popupShow then -- 392
				popupShow = false -- 399
				ImGui.OpenPopup("SelfUpdaterMessage") -- 400
			end -- 400
			ImGui.BeginPopupModal("SelfUpdaterMessage", messagePopupFlags, drawMessagePopup) -- 402
		end -- 302
	) -- 302
	return false -- 404
end) -- 298
local node = Node() -- 407
node:onCleanup(function() -- 408
	canceled = true -- 409
	if prepared then -- 409
		Content:remove(prepared.update.cleanupPath) -- 410
	end -- 410
	if extractedPath ~= "" then -- 410
		Content:remove(extractedPath) -- 411
	end -- 411
end) -- 408
return ____exports -- 408