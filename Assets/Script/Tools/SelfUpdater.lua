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
local ____Manifest = require("Script.Tools.SelfUpdater.Manifest") -- 24
local compareVersions = ____Manifest.compareVersions -- 25
local updatePlatformForApp = ____Manifest.updatePlatformForApp -- 26
local ____UpdateSync = require("Script.Tools.SelfUpdater.UpdateSync") -- 29
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
	local packageInfo = valueSnapshot.source == "AtomGit" and valueSnapshot.manifest.packages[platform] or valueSnapshot.packages[platform] -- 173
	installing = true -- 176
	if pending.installPath and Content:exist(pending.installPath) then -- 176
		progress = {progress = 1, message = zh and "正在启动安装程序…" or "Starting installer…", source = value.source} -- 178
		App:install(pending.installPath) -- 179
		installing = false -- 180
		progress = nil -- 181
		return -- 182
	end -- 182
	progress = {progress = 0.94, message = zh and "正在解压更新…" or "Extracting update…", source = value.source} -- 184
	thread(function() -- 185
		local unzipPath = Path( -- 186
			Path:getPath(value.file), -- 186
			"unpacked" -- 186
		) -- 186
		if Content:exist(unzipPath) then -- 186
			Content:remove(unzipPath) -- 187
		end -- 187
		extractedPath = unzipPath -- 188
		local success = Content:unzipAsync(value.file, unzipPath) -- 189
		if not success then -- 189
			installing = false -- 191
			progress = nil -- 192
			Content:remove(value.cleanupPath) -- 193
			prepared = nil -- 194
			extractedPath = "" -- 195
			showPopup(zh and "解压失败" or "Failed to extract update", zh and "无法解压文件：" .. packageInfo.file or "Failed to extract: " .. packageInfo.file) -- 196
			return -- 200
		end -- 200
		progress = {progress = 1, message = zh and "正在启动安装程序…" or "Starting installer…", source = value.source} -- 202
		local installPath = platform == "android" and Path(unzipPath, ("dora-ssr-" .. version) .. "-android.apk") or (platform == "macos-universal" and Path(unzipPath, "Dora.app") or unzipPath) -- 203
		if not Content:exist(installPath) then -- 203
			installing = false -- 209
			progress = nil -- 210
			Content:remove(value.cleanupPath) -- 211
			prepared = nil -- 212
			extractedPath = "" -- 213
			showPopup(zh and "安装包无效" or "Invalid update package", zh and "更新包缺少预期的安装入口。" or "The update package does not contain the expected installer.") -- 214
			return -- 218
		end -- 218
		pending.installPath = installPath -- 220
		App:install(installPath) -- 221
		installing = false -- 222
		progress = nil -- 223
	end) -- 185
end -- 170
local function beginUpdate() -- 227
	if not snapshot or preparing or installing then -- 227
		return -- 228
	end -- 228
	local platform = updatePlatformForApp() -- 229
	if not platform then -- 229
		return -- 230
	end -- 230
	preparing = true -- 231
	canceled = false -- 232
	progress = {progress = 0, message = zh and "正在准备下载…" or "Preparing download…"}; -- 233
	(function() -- 234
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 234
			local valueSnapshot = snapshot -- 235
			local value = __TS__Await(prepareUpdatePackage( -- 236
				valueSnapshot, -- 236
				platform, -- 236
				{ -- 236
					isCanceled = function() return canceled end, -- 237
					onProgress = function(____, status) -- 238
						progress = status -- 239
					end -- 238
				} -- 238
			)) -- 238
			preparing = false -- 242
			if not value then -- 242
				progress = nil -- 244
				if not canceled then -- 244
					showPopup(zh and "下载更新失败" or "Failed to download update", zh and valueSnapshot.source .. " 下载不可用，或安装包校验失败。" or valueSnapshot.source .. " is unavailable, or the package did not pass verification.") -- 246
				end -- 246
				return ____awaiter_resolve(nil) -- 246
			end -- 246
			prepared = {snapshot = valueSnapshot, platform = platform, update = value} -- 253
			installPreparedPackage(prepared) -- 258
		end) -- 258
	end)() -- 234
end -- 227
local function cancelCurrentOperation() -- 262
	canceled = true -- 263
	progress = nil -- 264
end -- 262
local function drawMessagePopup() -- 267
	ImGui.Text(popupTitle) -- 268
	ImGui.Separator() -- 269
	ImGui.PushTextWrapPos( -- 270
		360, -- 270
		function() return ImGui.TextWrapped(popupMessage) end -- 270
	) -- 270
	if ImGui.Button( -- 270
		zh and "确认" or "OK", -- 271
		Vec2(360, 30) -- 271
	) then -- 271
		ImGui.CloseCurrentPopup() -- 272
	end -- 272
end -- 267
local function drawPlatformMessage() -- 276
	repeat -- 276
		local ____switch43 = App.platform -- 276
		local ____cond43 = ____switch43 == "Linux" -- 276
		if ____cond43 then -- 276
			ImGui.TextWrapped(zh and "请通过 Dora SSR PPA，使用 apt 工具管理更新。" or "Use the Dora SSR PPA and apt to manage updates.") -- 279
			return true -- 284
		end -- 284
		____cond43 = ____cond43 or ____switch43 == "macOS" -- 284
		if ____cond43 then -- 284
			ImGui.TextWrapped(zh and "可直接在应用内更新 Dora SSR；如果当前安装由 Homebrew 管理，也可以继续使用 brew upgrade。" or "Dora SSR can update itself in the app. If this installation is managed by Homebrew, you can continue to use brew upgrade.") -- 286
			return false -- 291
		end -- 291
		do -- 291
			return false -- 293
		end -- 293
	until true -- 293
end -- 276
threadLoop(function() -- 297
	local ____App_visualSize_2 = App.visualSize -- 298
	local width = ____App_visualSize_2.width -- 298
	ImGui.SetNextWindowPos( -- 299
		Vec2(width - 10, 10), -- 299
		"Always", -- 299
		Vec2(1, 0) -- 299
	) -- 299
	ImGui.SetNextWindowSize( -- 300
		Vec2(430, 0), -- 300
		"Always" -- 300
	) -- 300
	ImGui.Begin( -- 301
		"Dora Updater", -- 301
		windowFlags, -- 301
		function() -- 301
			ImGui.Text(zh and "Dora SSR 自更新工具" or "Dora SSR Self Updater") -- 302
			ImGui.SameLine() -- 303
			ImGui.TextDisabled("(?)") -- 304
			if ImGui.IsItemHovered() then -- 304
				ImGui.BeginTooltip(function() -- 306
					ImGui.PushTextWrapPos( -- 307
						340, -- 307
						function() -- 307
							ImGui.Text(zh and "可手动切换 GitHub 和 AtomGit 两种完整更新模式。中文环境默认使用 AtomGit，其它语言默认使用 GitHub；两种模式都会核对安装包大小和 SHA-256。" or "Choose either the complete GitHub or AtomGit update mode. Chinese locales default to AtomGit; other locales default to GitHub. Both modes verify package size and SHA-256.") -- 308
						end -- 307
					) -- 307
				end) -- 306
			end -- 306
			ImGui.Separator() -- 316
			drawPlatformMessage() -- 317
			ImGui.TextColored(themeColor, zh and "更新模式：" or "Update mode:") -- 319
			ImGui.SameLine() -- 320
			local sourceChanged, sourceIndex = ImGui.Combo("##update-source", currentSource, sources) -- 321
			if sourceChanged and not checking and not preparing and not installing then -- 321
				currentSource = sourceIndex -- 323
				loadSnapshotForSelectedSource() -- 324
			end -- 324
			ImGui.TextColored(themeColor, zh and "当前版本：" or "Current version:") -- 327
			ImGui.SameLine() -- 328
			ImGui.Text(currentDisplayVersion) -- 329
			if snapshot then -- 329
				local visibleSnapshot = snapshot -- 331
				ImGui.TextColored(themeColor, zh and "稳定版本：" or "Stable version:") -- 332
				ImGui.SameLine() -- 333
				ImGui.Text(snapshotDisplayVersion(visibleSnapshot)) -- 334
				local comparison = compareSnapshotWithCurrent(visibleSnapshot) -- 335
				ImGui.PushTextWrapPos( -- 336
					410, -- 336
					function() -- 336
						if comparison < 0 then -- 336
							ImGui.TextColored(themeColor, zh and "有可用更新！" or "Update available!") -- 338
						elseif comparison == 0 then -- 338
							ImGui.TextColored(themeColor, visibleSnapshot.source == "GitHub" and (zh and "Release 版本相同，可重新下载以获取可能更新的 revision。" or "The Release version matches; redownload to get a possible newer revision.") or (zh and "已是最新版，可按需重新下载。" or "Already up to date; you can redownload when needed.")) -- 340
						else -- 340
							ImGui.TextColored(themeColor, zh and "当前版本高于稳定版本。" or "Current version is newer than stable.") -- 347
						end -- 347
					end -- 336
				) -- 336
			end -- 336
			if progress then -- 336
				ImGui.Separator() -- 353
				ImGui.TextWrapped((progress.source and progress.source .. " · " or "") .. progress.message) -- 354
				ImGui.ProgressBar( -- 357
					progress.progress, -- 357
					Vec2(-1, 28) -- 357
				) -- 357
				if not installing and ImGui.Button( -- 357
					zh and "取消" or "Cancel", -- 358
					Vec2(-1, 30) -- 358
				) then -- 358
					cancelCurrentOperation() -- 359
				end -- 359
			else -- 359
				if ImGui.Button( -- 359
					zh and "检查更新" or "Check for updates", -- 362
					Vec2(-1, 30) -- 362
				) then -- 362
					checkForUpdates() -- 363
				end -- 363
				local platform = updatePlatformForApp() -- 365
				local installSupported = platform == "android" or platform == "windows-x86" or platform == "macos-universal" -- 366
				if installSupported then -- 366
					if prepared then -- 366
						local pending = prepared -- 371
						ImGui.TextColored(themeColor, zh and pending.update.source .. " 安装包已下载并验证。" or pending.update.source .. " package is downloaded and verified.") -- 372
						if ImGui.Button( -- 372
							zh and "继续安装" or "Continue installation", -- 378
							Vec2(-1, 30) -- 378
						) then -- 378
							installPreparedPackage(pending) -- 379
						end -- 379
					elseif snapshot then -- 379
						local comparison = compareSnapshotWithCurrent(snapshot) -- 382
						if ImGui.Button( -- 382
							comparison < 0 and (zh and "下载并安装" or "Download and install") or (zh and "重新下载并安装" or "Redownload and install"), -- 384
							Vec2(-1, 30) -- 387
						) then -- 387
							beginUpdate() -- 389
						end -- 389
					end -- 389
				end -- 389
			end -- 389
			if popupShow then -- 389
				popupShow = false -- 396
				ImGui.OpenPopup("SelfUpdaterMessage") -- 397
			end -- 397
			ImGui.BeginPopupModal("SelfUpdaterMessage", messagePopupFlags, drawMessagePopup) -- 399
		end -- 301
	) -- 301
	return false -- 401
end) -- 297
local node = Node() -- 404
node:onCleanup(function() -- 405
	canceled = true -- 406
	if prepared then -- 406
		Content:remove(prepared.update.cleanupPath) -- 407
	end -- 407
	if extractedPath ~= "" then -- 407
		Content:remove(extractedPath) -- 408
	end -- 408
end) -- 405
return ____exports -- 405