-- [ts]: SelfUpdater.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
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
local windowsUpdatePlatform = ____Manifest.windowsUpdatePlatform -- 27
local isWindowsUpdatePlatform = ____Manifest.isWindowsUpdatePlatform -- 28
local ____UpdateSync = require("Tools.SelfUpdater.UpdateSync") -- 31
local checkGitHubRelease = ____UpdateSync.checkGitHubRelease -- 32
local loadCachedUpdateManifest = ____UpdateSync.loadCachedUpdateManifest -- 33
local prepareUpdatePackage = ____UpdateSync.prepareUpdatePackage -- 34
local syncUpdateManifest = ____UpdateSync.syncUpdateManifest -- 35
local updateSourcesForLocale = ____UpdateSync.updateSourcesForLocale -- 36
local zh = false -- 43
do -- 43
	local matched = string.match(App.locale, "^zh") -- 45
	zh = matched ~= nil -- 46
end -- 46
local major, minor, patch, revision = string.match(App.version, "(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 49
local currentVersion = (((("v" .. major) .. ".") .. minor) .. ".") .. patch -- 50
local currentRevision = tonumber(revision) or 0 -- 51
local currentDisplayVersion = (currentVersion .. "-") .. tostring(currentRevision) -- 52
local ____App_0 = App -- 53
local themeColor = ____App_0.themeColor -- 53
local sources = updateSourcesForLocale(App.locale) -- 54
local currentSource = 1 -- 55
local function selectedSource() -- 56
	return sources[currentSource] -- 56
end -- 56
local windowFlags = {"NoDecoration", "NoSavedSettings", "NoMove"} -- 58
local messagePopupFlags = {"NoSavedSettings", "AlwaysAutoResize", "NoTitleBar"} -- 63
local snapshot -- 69
local installedPlatform = updatePlatformForApp() -- 70
local targetBackend = installedPlatform and __TS__StringIncludes(installedPlatform, "-opengl") and 2 or 1 -- 71
local checking = false -- 72
local preparing = false -- 73
local installing = false -- 74
local canceled = false -- 75
local progress -- 76
local prepared -- 83
local extractedPath = "" -- 84
local popupTitle = "" -- 85
local popupMessage = "" -- 86
local popupShow = false -- 87
local function showPopup(title, message) -- 89
	popupTitle = title -- 90
	popupMessage = message -- 91
	popupShow = true -- 92
end -- 89
local function applySnapshot(value) -- 95
	snapshot = value -- 96
end -- 95
local cached = loadCachedUpdateManifest() -- 99
if selectedSource() == "AtomGit" and cached.success and cached.snapshot then -- 99
	applySnapshot(cached.snapshot) -- 100
end -- 100
local function loadSnapshotForSelectedSource() -- 102
	snapshot = nil -- 103
	if selectedSource() ~= "AtomGit" then -- 103
		return -- 104
	end -- 104
	local result = loadCachedUpdateManifest() -- 105
	if result.success and result.snapshot then -- 105
		applySnapshot(result.snapshot) -- 106
	end -- 106
end -- 102
local function snapshotVersion(value) -- 109
	return value.source == "AtomGit" and value.manifest.version or value.version -- 109
end -- 109
local function snapshotRevision(value) -- 113
	return value.source == "AtomGit" and value.manifest.revision or nil -- 113
end -- 113
local function snapshotDisplayVersion(value) -- 117
	local version = snapshotVersion(value) -- 118
	local revision = snapshotRevision(value) -- 119
	return revision == nil and version or (version .. "-") .. tostring(revision) -- 120
end -- 117
local function compareSnapshotWithCurrent(value) -- 123
	local base = compareVersions( -- 124
		currentVersion, -- 124
		snapshotVersion(value) -- 124
	) -- 124
	if base ~= 0 or value.source == "GitHub" then -- 124
		return base -- 125
	end -- 125
	return currentRevision == value.manifest.revision and 0 or (currentRevision < value.manifest.revision and -1 or 1) -- 126
end -- 123
local function checkForUpdates() -- 131
	if checking or preparing or installing then -- 131
		return -- 132
	end -- 132
	checking = true -- 133
	canceled = false -- 134
	local source = selectedSource() -- 135
	progress = {progress = 0, message = source == "AtomGit" and (zh and "正在连接 AtomGit 更新仓库…" or "Connecting to the AtomGit update repository…") or (zh and "正在查询 GitHub Release…" or "Checking GitHub Releases…"), source = source}; -- 136
	(function() -- 143
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 143
			local result = __TS__Await(source == "AtomGit" and syncUpdateManifest({ -- 144
				isCanceled = function() return canceled end, -- 145
				onProgress = function(____, status) -- 146
					progress = status -- 147
				end -- 146
			}) or checkGitHubRelease({ -- 146
				isCanceled = function() return canceled end, -- 150
				onProgress = function(____, status) -- 151
					progress = status -- 152
				end -- 151
			})) -- 151
			checking = false -- 155
			progress = nil -- 156
			if result.success and result.snapshot then -- 156
				applySnapshot(result.snapshot) -- 158
				if source == "AtomGit" and result.usedCache and result.message then -- 158
					showPopup(zh and "正在使用已验证缓存" or "Using verified cache", result.message) -- 160
				end -- 160
				return ____awaiter_resolve(nil) -- 160
			end -- 160
			showPopup(zh and "检查更新失败" or "Failed to check for updates", result.message or (zh and "无法读取可信更新清单。" or "Unable to read trusted update metadata.")) -- 167
		end) -- 167
	end)() -- 143
end -- 131
local function installPreparedPackage(pending) -- 174
	local ____pending_1 = pending -- 175
	local valueSnapshot = ____pending_1.snapshot -- 175
	local platform = ____pending_1.platform -- 175
	local value = ____pending_1.update -- 175
	local version = snapshotVersion(valueSnapshot) -- 176
	local ____temp_2 -- 177
	if valueSnapshot.source == "AtomGit" then -- 177
		____temp_2 = valueSnapshot.manifest.packages[platform] -- 178
	else -- 178
		____temp_2 = valueSnapshot.packages[platform] -- 179
	end -- 179
	local packageInfo = ____temp_2 -- 177
	if not packageInfo then -- 177
		prepared = nil -- 180
		return -- 180
	end -- 180
	installing = true -- 181
	if pending.installPath and Content:exist(pending.installPath) then -- 181
		progress = {progress = 1, message = zh and "正在启动安装程序…" or "Starting installer…", source = value.source} -- 183
		App:install(pending.installPath) -- 184
		installing = false -- 185
		progress = nil -- 186
		return -- 187
	end -- 187
	if __TS__StringEndsWith(platform, "-msi") then -- 187
		pending.installPath = value.file -- 190
		App:install(value.file) -- 191
		installing = false -- 192
		progress = nil -- 193
		return -- 194
	end -- 194
	progress = {progress = 0.94, message = zh and "正在解压更新…" or "Extracting update…", source = value.source} -- 196
	thread(function() -- 197
		local unzipPath = Path( -- 198
			Path:getPath(value.file), -- 198
			"unpacked" -- 198
		) -- 198
		if Content:exist(unzipPath) then -- 198
			Content:remove(unzipPath) -- 199
		end -- 199
		extractedPath = unzipPath -- 200
		local success = Content:unzipAsync(value.file, unzipPath) -- 201
		if not success then -- 201
			installing = false -- 203
			progress = nil -- 204
			Content:remove(value.cleanupPath) -- 205
			prepared = nil -- 206
			extractedPath = "" -- 207
			showPopup(zh and "解压失败" or "Failed to extract update", zh and "无法解压文件：" .. packageInfo.file or "Failed to extract: " .. packageInfo.file) -- 208
			return -- 212
		end -- 212
		progress = {progress = 1, message = zh and "正在启动安装程序…" or "Starting installer…", source = value.source} -- 214
		local installPath = platform == "android" and Path(unzipPath, ("dora-ssr-" .. version) .. "-android.apk") or ((platform == "macos-universal" or platform == "macos-arm64") and Path(unzipPath, "Dora.app") or unzipPath) -- 215
		if not Content:exist(installPath) then -- 215
			installing = false -- 221
			progress = nil -- 222
			Content:remove(value.cleanupPath) -- 223
			prepared = nil -- 224
			extractedPath = "" -- 225
			showPopup(zh and "安装包无效" or "Invalid update package", zh and "更新包缺少预期的安装入口。" or "The update package does not contain the expected installer.") -- 226
			return -- 230
		end -- 230
		pending.installPath = installPath -- 232
		App:install(installPath) -- 233
		installing = false -- 234
		progress = nil -- 235
	end) -- 197
end -- 174
local function beginUpdate(platform) -- 239
	if platform == nil then -- 239
		platform = updatePlatformForApp() -- 239
	end -- 239
	if not snapshot or preparing or installing then -- 239
		return -- 240
	end -- 240
	if not platform then -- 240
		return -- 241
	end -- 241
	preparing = true -- 242
	canceled = false -- 243
	progress = {progress = 0, message = zh and "正在准备下载…" or "Preparing download…"}; -- 244
	(function() -- 245
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 245
			local valueSnapshot = snapshot -- 246
			local value = __TS__Await(prepareUpdatePackage( -- 247
				valueSnapshot, -- 247
				platform, -- 247
				{ -- 247
					isCanceled = function() return canceled end, -- 248
					onProgress = function(____, status) -- 249
						progress = status -- 250
					end -- 249
				} -- 249
			)) -- 249
			preparing = false -- 253
			if not value then -- 253
				progress = nil -- 255
				if not canceled then -- 255
					showPopup(zh and "下载更新失败" or "Failed to download update", zh and valueSnapshot.source .. " 下载不可用，或安装包校验失败。" or valueSnapshot.source .. " is unavailable, or the package did not pass verification.") -- 257
				end -- 257
				return ____awaiter_resolve(nil) -- 257
			end -- 257
			prepared = {snapshot = valueSnapshot, platform = platform, update = value} -- 264
			installPreparedPackage(prepared) -- 269
		end) -- 269
	end)() -- 245
end -- 239
local function cancelCurrentOperation() -- 273
	canceled = true -- 274
	progress = nil -- 275
end -- 273
local function drawMessagePopup() -- 278
	ImGui.Text(popupTitle) -- 279
	ImGui.Separator() -- 280
	ImGui.PushTextWrapPos( -- 281
		360, -- 281
		function() return ImGui.TextWrapped(popupMessage) end -- 281
	) -- 281
	if ImGui.Button( -- 281
		zh and "确认" or "OK", -- 282
		Vec2(360, 30) -- 282
	) then -- 282
		ImGui.CloseCurrentPopup() -- 283
	end -- 283
end -- 278
local function drawPlatformMessage() -- 287
	repeat -- 287
		local ____switch45 = App.platform -- 287
		local ____cond45 = ____switch45 == "Linux" -- 287
		if ____cond45 then -- 287
			ImGui.TextWrapped(zh and "请通过 Dora SSR PPA，使用 apt 工具管理更新。" or "Use the Dora SSR PPA and apt to manage updates.") -- 290
			return true -- 295
		end -- 295
		____cond45 = ____cond45 or ____switch45 == "macOS" -- 295
		if ____cond45 then -- 295
			ImGui.TextWrapped(zh and "可直接在应用内更新 Dora SSR；如果当前安装由 Homebrew 管理，也可以继续使用 brew upgrade。" or "Dora SSR can update itself in the app. If this installation is managed by Homebrew, you can continue to use brew upgrade.") -- 297
			return false -- 302
		end -- 302
		do -- 302
			return false -- 304
		end -- 304
	until true -- 304
end -- 287
threadLoop(function() -- 308
	local ____App_visualSize_3 = App.visualSize -- 309
	local width = ____App_visualSize_3.width -- 309
	ImGui.SetNextWindowPos( -- 310
		Vec2(width - 10, 10), -- 310
		"Always", -- 310
		Vec2(1, 0) -- 310
	) -- 310
	ImGui.SetNextWindowSize( -- 311
		Vec2(430, 0), -- 311
		"Always" -- 311
	) -- 311
	ImGui.Begin( -- 312
		"Dora Updater", -- 312
		windowFlags, -- 312
		function() -- 312
			ImGui.Text(zh and "Dora SSR 自更新工具" or "Dora SSR Self Updater") -- 313
			ImGui.SameLine() -- 314
			ImGui.TextDisabled("(?)") -- 315
			if ImGui.IsItemHovered() then -- 315
				ImGui.BeginTooltip(function() -- 317
					ImGui.PushTextWrapPos( -- 318
						340, -- 318
						function() -- 318
							ImGui.Text(zh and "可手动切换 GitHub 和 AtomGit 两种完整更新模式。中文环境默认使用 AtomGit，其它语言默认使用 GitHub；两种模式都会核对安装包大小和 SHA-256。" or "Choose either the complete GitHub or AtomGit update mode. Chinese locales default to AtomGit; other locales default to GitHub. Both modes verify package size and SHA-256.") -- 319
						end -- 318
					) -- 318
				end) -- 317
			end -- 317
			ImGui.Separator() -- 327
			drawPlatformMessage() -- 328
			ImGui.TextColored(themeColor, zh and "更新模式：" or "Update mode:") -- 330
			ImGui.SameLine() -- 331
			local sourceChanged, sourceIndex = ImGui.Combo("##update-source", currentSource, sources) -- 332
			if sourceChanged and not checking and not preparing and not installing then -- 332
				currentSource = sourceIndex -- 334
				loadSnapshotForSelectedSource() -- 335
			end -- 335
			ImGui.TextColored(themeColor, zh and "当前版本：" or "Current version:") -- 338
			ImGui.SameLine() -- 339
			ImGui.Text(currentDisplayVersion) -- 340
			if installedPlatform and isWindowsUpdatePlatform(installedPlatform) then -- 340
				ImGui.Text(((zh and "当前图形版本：" or "Current graphics: ") .. (__TS__StringIncludes(installedPlatform, "-opengl") and "OpenGL" or "D3D12")) .. (__TS__StringEndsWith(installedPlatform, "-msi") and " · MSI" or " · ZIP")) -- 342
			end -- 342
			if snapshot then -- 342
				local visibleSnapshot = snapshot -- 347
				ImGui.TextColored(themeColor, zh and "稳定版本：" or "Stable version:") -- 348
				ImGui.SameLine() -- 349
				ImGui.Text(snapshotDisplayVersion(visibleSnapshot)) -- 350
				local comparison = compareSnapshotWithCurrent(visibleSnapshot) -- 351
				ImGui.PushTextWrapPos( -- 352
					410, -- 352
					function() -- 352
						if comparison < 0 then -- 352
							ImGui.TextColored(themeColor, zh and "有可用更新！" or "Update available!") -- 354
						elseif comparison == 0 then -- 354
							ImGui.TextColored(themeColor, visibleSnapshot.source == "GitHub" and (zh and "Release 版本相同，可重新下载以获取可能更新的 revision。" or "The Release version matches; redownload to get a possible newer revision.") or (zh and "已是最新版，可按需重新下载。" or "Already up to date; you can redownload when needed.")) -- 356
						else -- 356
							ImGui.TextColored(themeColor, zh and "当前版本高于稳定版本。" or "Current version is newer than stable.") -- 363
						end -- 363
					end -- 352
				) -- 352
			end -- 352
			if progress then -- 352
				ImGui.Separator() -- 369
				ImGui.TextWrapped((progress.source and progress.source .. " · " or "") .. progress.message) -- 370
				ImGui.ProgressBar( -- 373
					progress.progress, -- 373
					Vec2(-1, 28) -- 373
				) -- 373
				if not installing and ImGui.Button( -- 373
					zh and "取消" or "Cancel", -- 374
					Vec2(-1, 30) -- 374
				) then -- 374
					cancelCurrentOperation() -- 375
				end -- 375
			else -- 375
				if ImGui.Button( -- 375
					zh and "检查更新" or "Check for updates", -- 378
					Vec2(-1, 30) -- 378
				) then -- 378
					checkForUpdates() -- 379
				end -- 379
				local platform = updatePlatformForApp() -- 381
				local installSupported = platform == "android" or platform == "windows-x86" or platform == "macos-universal" or platform ~= nil and isWindowsUpdatePlatform(platform) or platform == "macos-arm64" -- 382
				if installSupported then -- 382
					if prepared then -- 382
						local pending = prepared -- 389
						ImGui.TextColored(themeColor, zh and pending.update.source .. " 安装包已下载并验证。" or pending.update.source .. " package is downloaded and verified.") -- 390
						if ImGui.Button( -- 390
							zh and "继续安装" or "Continue installation", -- 396
							Vec2(-1, 30) -- 396
						) then -- 396
							installPreparedPackage(pending) -- 397
						end -- 397
					elseif snapshot then -- 397
						local comparison = compareSnapshotWithCurrent(snapshot) -- 400
						if ImGui.Button( -- 400
							comparison < 0 and (zh and "下载并安装" or "Download and install") or (zh and "重新下载并安装" or "Redownload and install"), -- 402
							Vec2(-1, 30) -- 405
						) then -- 405
							beginUpdate() -- 407
						end -- 407
					end -- 407
				end -- 407
			end -- 407
			if installedPlatform and isWindowsUpdatePlatform(installedPlatform) and snapshot and not checking and not preparing and not installing and not prepared then -- 407
				ImGui.Separator() -- 415
				local changed, choice = ImGui.Combo(zh and "切换图形版本" or "Switch graphics", targetBackend, {"D3D12", "OpenGL"}) -- 416
				if changed then -- 416
					targetBackend = choice -- 417
				end -- 417
				local target = windowsUpdatePlatform( -- 418
					targetBackend == 2 and "wgl" or "d3d12", -- 418
					__TS__StringEndsWith(installedPlatform, "-msi") -- 418
				) -- 418
				local packages = snapshot.source == "AtomGit" and snapshot.manifest.packages or snapshot.packages -- 419
				if target ~= installedPlatform then -- 419
					ImGui.TextWrapped(zh and "切换将安装所选版本并重新启动，保留用户项目和设置。" or "Switching installs the selected version and restarts Dora, preserving user projects and settings.") -- 421
					if packages[target] and compareVersions( -- 421
						snapshotVersion(snapshot), -- 422
						currentVersion -- 422
					) >= 0 then -- 422
						if ImGui.Button( -- 422
							zh and "下载切换版本并重启" or "Download, switch and restart", -- 423
							Vec2(-1, 30) -- 423
						) then -- 423
							beginUpdate(target) -- 423
						end -- 423
					else -- 423
						ImGui.TextWrapped(zh and "当前更新源没有可切换的同版本或更新版本安装包。" or "This source has no matching or newer package for the selected backend.") -- 424
					end -- 424
				end -- 424
			end -- 424
			if popupShow then -- 424
				popupShow = false -- 429
				ImGui.OpenPopup("SelfUpdaterMessage") -- 430
			end -- 430
			ImGui.BeginPopupModal("SelfUpdaterMessage", messagePopupFlags, drawMessagePopup) -- 432
		end -- 312
	) -- 312
	return false -- 434
end) -- 308
local node = Node() -- 437
node:onCleanup(function() -- 438
	canceled = true -- 439
	if prepared then -- 439
		Content:remove(prepared.update.cleanupPath) -- 440
	end -- 440
	if extractedPath ~= "" then -- 440
		Content:remove(extractedPath) -- 441
	end -- 441
end) -- 438
return ____exports -- 438
