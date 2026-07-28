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
local prepared -- 73
local extractedPath = "" -- 74
local popupTitle = "" -- 75
local popupMessage = "" -- 76
local popupShow = false -- 77
local function showPopup(title, message) -- 79
	popupTitle = title -- 80
	popupMessage = message -- 81
	popupShow = true -- 82
end -- 79
local function applySnapshot(value) -- 85
	snapshot = value -- 86
end -- 85
local cached = loadCachedUpdateManifest() -- 89
if selectedSource() == "AtomGit" and cached.success and cached.snapshot then -- 89
	applySnapshot(cached.snapshot) -- 90
end -- 90
local function loadSnapshotForSelectedSource() -- 92
	snapshot = nil -- 93
	if selectedSource() ~= "AtomGit" then -- 93
		return -- 94
	end -- 94
	local result = loadCachedUpdateManifest() -- 95
	if result.success and result.snapshot then -- 95
		applySnapshot(result.snapshot) -- 96
	end -- 96
end -- 92
local function snapshotVersion(value) -- 99
	return value.source == "AtomGit" and value.manifest.version or value.version -- 99
end -- 99
local function snapshotRevision(value) -- 103
	return value.source == "AtomGit" and value.manifest.revision or nil -- 103
end -- 103
local function snapshotDisplayVersion(value) -- 107
	local version = snapshotVersion(value) -- 108
	local revision = snapshotRevision(value) -- 109
	return revision == nil and version or (version .. "-") .. tostring(revision) -- 110
end -- 107
local function compareSnapshotWithCurrent(value) -- 113
	local base = compareVersions( -- 114
		currentVersion, -- 114
		snapshotVersion(value) -- 114
	) -- 114
	if base ~= 0 or value.source == "GitHub" then -- 114
		return base -- 115
	end -- 115
	return currentRevision == value.manifest.revision and 0 or (currentRevision < value.manifest.revision and -1 or 1) -- 116
end -- 113
local function checkForUpdates() -- 121
	if checking or preparing or installing then -- 121
		return -- 122
	end -- 122
	checking = true -- 123
	canceled = false -- 124
	local source = selectedSource() -- 125
	progress = {progress = 0, message = source == "AtomGit" and (zh and "正在连接 AtomGit 更新仓库…" or "Connecting to the AtomGit update repository…") or (zh and "正在查询 GitHub Release…" or "Checking GitHub Releases…"), source = source}; -- 126
	(function() -- 133
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 133
			local result = __TS__Await(source == "AtomGit" and syncUpdateManifest({ -- 134
				isCanceled = function() return canceled end, -- 135
				onProgress = function(____, status) -- 136
					progress = status -- 137
				end -- 136
			}) or checkGitHubRelease({ -- 136
				isCanceled = function() return canceled end, -- 140
				onProgress = function(____, status) -- 141
					progress = status -- 142
				end -- 141
			})) -- 141
			checking = false -- 145
			progress = nil -- 146
			if result.success and result.snapshot then -- 146
				applySnapshot(result.snapshot) -- 148
				if source == "AtomGit" and result.usedCache and result.message then -- 148
					showPopup(zh and "正在使用已验证缓存" or "Using verified cache", result.message) -- 150
				end -- 150
				return ____awaiter_resolve(nil) -- 150
			end -- 150
			showPopup(zh and "检查更新失败" or "Failed to check for updates", result.message or (zh and "无法读取可信更新清单。" or "Unable to read trusted update metadata.")) -- 157
		end) -- 157
	end)() -- 133
end -- 121
local function installPreparedPackage(valueSnapshot, platform, value) -- 164
	local version = snapshotVersion(valueSnapshot) -- 169
	local packageInfo = valueSnapshot.source == "AtomGit" and valueSnapshot.manifest.packages[platform] or valueSnapshot.packages[platform] -- 170
	installing = true -- 173
	progress = {progress = 0.94, message = zh and "正在解压更新…" or "Extracting update…", source = value.source} -- 174
	thread(function() -- 175
		local unzipPath = Path( -- 176
			Path:getPath(value.file), -- 176
			"unpacked" -- 176
		) -- 176
		if Content:exist(unzipPath) then -- 176
			Content:remove(unzipPath) -- 177
		end -- 177
		extractedPath = unzipPath -- 178
		local success = Content:unzipAsync(value.file, unzipPath) -- 179
		if not success then -- 179
			installing = false -- 181
			progress = nil -- 182
			Content:remove(value.cleanupPath) -- 183
			prepared = nil -- 184
			extractedPath = "" -- 185
			showPopup(zh and "解压失败" or "Failed to extract update", zh and "无法解压文件：" .. packageInfo.file or "Failed to extract: " .. packageInfo.file) -- 186
			return -- 190
		end -- 190
		progress = {progress = 1, message = zh and "正在启动安装程序…" or "Starting installer…", source = value.source} -- 192
		local installPath = platform == "android" and Path(unzipPath, ("dora-ssr-" .. version) .. "-android.apk") or (platform == "macos-universal" and Path(unzipPath, "Dora.app") or unzipPath) -- 193
		if not Content:exist(installPath) then -- 193
			installing = false -- 199
			progress = nil -- 200
			Content:remove(value.cleanupPath) -- 201
			prepared = nil -- 202
			extractedPath = "" -- 203
			showPopup(zh and "安装包无效" or "Invalid update package", zh and "更新包缺少预期的安装入口。" or "The update package does not contain the expected installer.") -- 204
			return -- 208
		end -- 208
		App:install(installPath) -- 210
		installing = false -- 211
		progress = nil -- 212
	end) -- 175
end -- 164
local function beginUpdate() -- 216
	if not snapshot or preparing or installing then -- 216
		return -- 217
	end -- 217
	local platform = updatePlatformForApp() -- 218
	if not platform then -- 218
		return -- 219
	end -- 219
	preparing = true -- 220
	canceled = false -- 221
	progress = {progress = 0, message = zh and "正在准备下载…" or "Preparing download…"}; -- 222
	(function() -- 223
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 223
			local valueSnapshot = snapshot -- 224
			local value = __TS__Await(prepareUpdatePackage( -- 225
				valueSnapshot, -- 225
				platform, -- 225
				{ -- 225
					isCanceled = function() return canceled end, -- 226
					onProgress = function(____, status) -- 227
						progress = status -- 228
					end -- 227
				} -- 227
			)) -- 227
			preparing = false -- 231
			if not value then -- 231
				progress = nil -- 233
				if not canceled then -- 233
					showPopup(zh and "下载更新失败" or "Failed to download update", zh and valueSnapshot.source .. " 下载不可用，或安装包校验失败。" or valueSnapshot.source .. " is unavailable, or the package did not pass verification.") -- 235
				end -- 235
				return ____awaiter_resolve(nil) -- 235
			end -- 235
			prepared = value -- 242
			installPreparedPackage(valueSnapshot, platform, value) -- 243
		end) -- 243
	end)() -- 223
end -- 216
local function cancelCurrentOperation() -- 247
	canceled = true -- 248
	progress = nil -- 249
end -- 247
local function drawMessagePopup() -- 252
	ImGui.Text(popupTitle) -- 253
	ImGui.Separator() -- 254
	ImGui.PushTextWrapPos( -- 255
		360, -- 255
		function() return ImGui.TextWrapped(popupMessage) end -- 255
	) -- 255
	if ImGui.Button( -- 255
		zh and "确认" or "OK", -- 256
		Vec2(360, 30) -- 256
	) then -- 256
		ImGui.CloseCurrentPopup() -- 257
	end -- 257
end -- 252
local function drawPlatformMessage() -- 261
	repeat -- 261
		local ____switch42 = App.platform -- 261
		local ____cond42 = ____switch42 == "Linux" -- 261
		if ____cond42 then -- 261
			ImGui.TextWrapped(zh and "请通过 Dora SSR PPA，使用 apt 工具管理更新。" or "Use the Dora SSR PPA and apt to manage updates.") -- 264
			return true -- 269
		end -- 269
		____cond42 = ____cond42 or ____switch42 == "macOS" -- 269
		if ____cond42 then -- 269
			ImGui.TextWrapped(zh and "可直接在应用内更新 Dora SSR；如果当前安装由 Homebrew 管理，也可以继续使用 brew upgrade。" or "Dora SSR can update itself in the app. If this installation is managed by Homebrew, you can continue to use brew upgrade.") -- 271
			return false -- 276
		end -- 276
		do -- 276
			return false -- 278
		end -- 278
	until true -- 278
end -- 261
threadLoop(function() -- 282
	local ____App_visualSize_1 = App.visualSize -- 283
	local width = ____App_visualSize_1.width -- 283
	ImGui.SetNextWindowPos( -- 284
		Vec2(width - 10, 10), -- 284
		"Always", -- 284
		Vec2(1, 0) -- 284
	) -- 284
	ImGui.SetNextWindowSize( -- 285
		Vec2(430, 0), -- 285
		"Always" -- 285
	) -- 285
	ImGui.Begin( -- 286
		"Dora Updater", -- 286
		windowFlags, -- 286
		function() -- 286
			ImGui.Text(zh and "Dora SSR 自更新工具" or "Dora SSR Self Updater") -- 287
			ImGui.SameLine() -- 288
			ImGui.TextDisabled("(?)") -- 289
			if ImGui.IsItemHovered() then -- 289
				ImGui.BeginTooltip(function() -- 291
					ImGui.PushTextWrapPos( -- 292
						340, -- 292
						function() -- 292
							ImGui.Text(zh and "可手动切换 GitHub 和 AtomGit 两种完整更新模式。中文环境默认使用 AtomGit，其它语言默认使用 GitHub；两种模式都会核对安装包大小和 SHA-256。" or "Choose either the complete GitHub or AtomGit update mode. Chinese locales default to AtomGit; other locales default to GitHub. Both modes verify package size and SHA-256.") -- 293
						end -- 292
					) -- 292
				end) -- 291
			end -- 291
			ImGui.Separator() -- 301
			drawPlatformMessage() -- 302
			ImGui.TextColored(themeColor, zh and "更新模式：" or "Update mode:") -- 304
			ImGui.SameLine() -- 305
			local sourceChanged, sourceIndex = ImGui.Combo("##update-source", currentSource, sources) -- 306
			if sourceChanged and not checking and not preparing and not installing then -- 306
				currentSource = sourceIndex -- 308
				loadSnapshotForSelectedSource() -- 309
			end -- 309
			ImGui.TextColored(themeColor, zh and "当前版本：" or "Current version:") -- 312
			ImGui.SameLine() -- 313
			ImGui.Text(currentDisplayVersion) -- 314
			if snapshot then -- 314
				local visibleSnapshot = snapshot -- 316
				ImGui.TextColored(themeColor, zh and "稳定版本：" or "Stable version:") -- 317
				ImGui.SameLine() -- 318
				ImGui.Text(snapshotDisplayVersion(visibleSnapshot)) -- 319
				ImGui.TextColored(themeColor, zh and "更新来源：" or "Update source:") -- 320
				ImGui.SameLine() -- 321
				ImGui.Text(visibleSnapshot.source) -- 322
				if ImGui.IsItemHovered() then -- 322
					ImGui.BeginTooltip(function() -- 324
						ImGui.PushTextWrapPos( -- 325
							390, -- 325
							function() -- 325
								if visibleSnapshot.source == "AtomGit" then -- 325
									ImGui.Text(((zh and "清单提交" or "Manifest commit") .. ": ") .. visibleSnapshot.commit) -- 327
									ImGui.Text(((zh and "签名者" or "Signer") .. ": ") .. visibleSnapshot.signer) -- 328
									ImGui.Text(((zh and "验证时间" or "Verified") .. ": ") .. visibleSnapshot.verifiedAt) -- 329
								else -- 329
									ImGui.Text(((zh and "发布时间" or "Published") .. ": ") .. visibleSnapshot.publishedAt) -- 331
									ImGui.TextWrapped(zh and "GitHub API 只提供 Release 版本号，无法判断同版本安装包的 revision；需要时可直接重新下载。" or "The GitHub API exposes only the Release version, so it cannot identify package revisions within the same version. You can redownload when needed.") -- 332
								end -- 332
							end -- 325
						) -- 325
					end) -- 324
				end -- 324
				local comparison = compareSnapshotWithCurrent(visibleSnapshot) -- 341
				ImGui.PushTextWrapPos( -- 342
					410, -- 342
					function() -- 342
						if comparison < 0 then -- 342
							ImGui.TextColored(themeColor, zh and "有可用更新！" or "Update available!") -- 344
						elseif comparison == 0 then -- 344
							ImGui.TextColored(themeColor, visibleSnapshot.source == "GitHub" and (zh and "Release 版本相同，可重新下载以获取可能更新的 revision。" or "The Release version matches; redownload to get a possible newer revision.") or (zh and "已是最新版，可按需重新下载。" or "Already up to date; you can redownload when needed.")) -- 346
						else -- 346
							ImGui.TextColored(themeColor, zh and "当前版本高于稳定版本。" or "Current version is newer than stable.") -- 353
						end -- 353
					end -- 342
				) -- 342
			end -- 342
			if progress then -- 342
				ImGui.Separator() -- 359
				ImGui.TextWrapped((progress.source and progress.source .. " · " or "") .. progress.message) -- 360
				ImGui.ProgressBar( -- 363
					progress.progress, -- 363
					Vec2(-1, 28) -- 363
				) -- 363
				if not installing and ImGui.Button( -- 363
					zh and "取消" or "Cancel", -- 364
					Vec2(-1, 30) -- 364
				) then -- 364
					cancelCurrentOperation() -- 365
				end -- 365
			else -- 365
				if ImGui.Button( -- 365
					zh and "检查更新" or "Check for updates", -- 368
					Vec2(-1, 30) -- 368
				) then -- 368
					checkForUpdates() -- 369
				end -- 369
				local platform = updatePlatformForApp() -- 371
				local installSupported = platform == "android" or platform == "windows-x86" or platform == "macos-universal" -- 372
				if snapshot and installSupported then -- 372
					local comparison = compareSnapshotWithCurrent(snapshot) -- 376
					if ImGui.Button( -- 376
						comparison < 0 and (zh and "下载并安装" or "Download and install") or (zh and "重新下载并安装" or "Redownload and install"), -- 378
						Vec2(-1, 30) -- 381
					) then -- 381
						beginUpdate() -- 383
					end -- 383
				end -- 383
			end -- 383
			if popupShow then -- 383
				popupShow = false -- 389
				ImGui.OpenPopup("SelfUpdaterMessage") -- 390
			end -- 390
			ImGui.BeginPopupModal("SelfUpdaterMessage", messagePopupFlags, drawMessagePopup) -- 392
		end -- 286
	) -- 286
	return false -- 394
end) -- 282
local node = Node() -- 397
node:onCleanup(function() -- 398
	canceled = true -- 399
	if prepared then -- 399
		Content:remove(prepared.cleanupPath) -- 400
	end -- 400
	if extractedPath ~= "" then -- 400
		Content:remove(extractedPath) -- 401
	end -- 401
end) -- 398
return ____exports -- 398