-- [ts]: ResourceDownloader.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Set = ____lualib.Set -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local HttpClient = ____Dora.HttpClient -- 2
local json = ____Dora.json -- 2
local thread = ____Dora.thread -- 2
local App = ____Dora.App -- 2
local Vec2 = ____Dora.Vec2 -- 2
local Path = ____Dora.Path -- 2
local Content = ____Dora.Content -- 2
local Node = ____Dora.Node -- 2
local Texture2D = ____Dora.Texture2D -- 2
local Cache = ____Dora.Cache -- 2
local Buffer = ____Dora.Buffer -- 2
local Director = ____Dora.Director -- 2
local ImGui = require("ImGui") -- 4
local url = "http://39.155.148.157:8866" -- 6
local zh = false -- 8
do -- 8
	local res = string.match(App.locale, "^zh") -- 10
	zh = res ~= nil and ImGui.IsFontLoaded() -- 11
end -- 11
local windowsNoScrollFlags = { -- 49
	"NoMove", -- 50
	"NoCollapse", -- 51
	"NoResize", -- 52
	"NoDecoration", -- 53
	"NoNav", -- 54
	"NoBringToFrontOnFocus" -- 55
} -- 55
local windowsFlags = { -- 58
	"NoMove", -- 59
	"NoCollapse", -- 60
	"NoResize", -- 61
	"NoDecoration", -- 62
	"NoNav", -- 63
	"AlwaysVerticalScrollbar", -- 64
	"NoBringToFrontOnFocus" -- 65
} -- 65
local themeColor = App.themeColor -- 68
local function sep() -- 70
	return ImGui.SeparatorText("") -- 70
end -- 70
local function thinSep() -- 71
	return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 71
end -- 71
local ResourceDownloader = __TS__Class() -- 73
ResourceDownloader.name = "ResourceDownloader" -- 73
function ResourceDownloader.prototype.____constructor(self) -- 91
	self.packages = {} -- 74
	self.repos = __TS__New(Map) -- 75
	self.downloadProgress = __TS__New(Map) -- 76
	self.downloadTasks = __TS__New(Map) -- 77
	self.popupMessageTitle = "" -- 78
	self.popupMessage = "" -- 79
	self.popupShow = false -- 80
	self.cancelDownload = false -- 81
	self.isDownloading = false -- 82
	self.previewTextures = __TS__New(Map) -- 84
	self.previewFiles = __TS__New(Map) -- 85
	self.downloadedPackages = __TS__New(Set) -- 86
	self.isLoading = false -- 87
	self.filterBuf = Buffer(20) -- 88
	self.filterText = "" -- 89
	self.node = Node() -- 92
	self.node:schedule(function() -- 93
		self:update() -- 94
		return false -- 95
	end) -- 93
	self.node:onCleanup(function() -- 97
		self.cancelDownload = true -- 98
	end) -- 97
	self:loadData() -- 100
end -- 91
function ResourceDownloader.prototype.showPopup(self, title, msg) -- 103
	self.popupMessageTitle = title -- 104
	self.popupMessage = msg -- 105
	self.popupShow = true -- 106
end -- 103
function ResourceDownloader.prototype.loadData(self) -- 109
	if self.isLoading then -- 109
		return -- 110
	end -- 110
	self.isLoading = true -- 111
	thread(function() -- 112
		local reload = false -- 113
		local versionResponse = HttpClient:getAsync(url .. "/api/v1/package-list-version") -- 114
		local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 115
		if versionResponse then -- 115
			local version = json.load(versionResponse) -- 117
			local packageListVersion = version -- 118
			if Content:exist(packageListVersionFile) then -- 118
				local oldVersion = json.load(Content:load(packageListVersionFile)) -- 120
				local oldPackageListVersion = oldVersion -- 121
				if packageListVersion.version ~= oldPackageListVersion.version then -- 121
					reload = true -- 123
				end -- 123
			else -- 123
				reload = true -- 126
			end -- 126
		end -- 126
		if reload then -- 126
			self.packages = {} -- 130
			self.repos = __TS__New(Map) -- 131
			self.previewTextures:clear() -- 132
			self.previewFiles:clear() -- 133
			local cachePath = Path(Content.appPath, ".cache", "preview") -- 134
			Content:remove(cachePath) -- 135
		end -- 135
		local cachePath = Path(Content.appPath, ".cache", "preview") -- 138
		Content:mkdir(cachePath) -- 139
		if reload and versionResponse then -- 139
			Content:save(packageListVersionFile, versionResponse) -- 141
		end -- 141
		local packagesFile = Path(cachePath, "packages.json") -- 143
		if Content:exist(packagesFile) then -- 143
			local packages = json.load(Content:load(packagesFile)) -- 145
			self.packages = packages -- 146
		else -- 146
			local packagesResponse = HttpClient:getAsync(url .. "/api/v1/packages") -- 148
			if packagesResponse then -- 148
				local packages = json.load(packagesResponse) -- 151
				self.packages = packages -- 152
				Content:save(packagesFile, packagesResponse) -- 153
			end -- 153
		end -- 153
		for ____, pkg in ipairs(self.packages) do -- 156
			pkg.currentVersion = 1 -- 157
			pkg.versionNames = __TS__ArrayMap( -- 158
				pkg.versions, -- 158
				function(____, v) -- 158
					return v.tag == "" and "No Tag" or v.tag -- 159
				end -- 158
			) -- 158
		end -- 158
		local reposFile = Path(cachePath, "repos.json") -- 164
		if Content:exist(reposFile) then -- 164
			local repos = json.load(Content:load(reposFile)) -- 166
			for ____, repo in ipairs(repos) do -- 167
				self.repos:set(repo.name, repo) -- 168
			end -- 168
		else -- 168
			local reposResponse = HttpClient:getAsync(url .. "/assets/repos.json") -- 171
			if reposResponse then -- 171
				local repos = json.load(reposResponse) -- 173
				for ____, repo in ipairs(repos) do -- 174
					self.repos:set(repo.name, repo) -- 175
				end -- 175
				Content:save(reposFile, reposResponse) -- 177
			end -- 177
		end -- 177
		for ____, pkg in ipairs(self.packages) do -- 182
			local downloadPath = Path(Content.writablePath, "Download", pkg.name) -- 183
			if Content:exist(downloadPath) then -- 183
				self.downloadedPackages:add(pkg.name) -- 185
			end -- 185
			self:loadPreviewImage(pkg.name) -- 187
		end -- 187
		self.isLoading = false -- 189
	end) -- 112
end -- 109
function ResourceDownloader.prototype.loadPreviewImage(self, name) -- 193
	local cachePath = Path(Content.appPath, ".cache", "preview") -- 194
	local cacheFile = Path(cachePath, name .. ".jpg") -- 195
	if Content:exist(cacheFile) then -- 195
		Cache:loadAsync(cacheFile) -- 197
		local texture = Texture2D(cacheFile) -- 198
		if texture then -- 198
			self.previewTextures:set(name, texture) -- 200
			self.previewFiles:set(name, cacheFile) -- 201
		end -- 201
		return -- 203
	end -- 203
	local imageUrl = ((url .. "/assets/") .. name) .. "/banner.jpg" -- 205
	local response = HttpClient:downloadAsync(imageUrl, cacheFile, 10) -- 206
	if response then -- 206
		Cache:loadAsync(cacheFile) -- 208
		local texture = Texture2D(cacheFile) -- 209
		if texture then -- 209
			self.previewTextures:set(name, texture) -- 211
			self.previewFiles:set(name, cacheFile) -- 212
		end -- 212
	else -- 212
		print("Failed to load preview image for " .. name) -- 215
	end -- 215
end -- 193
function ResourceDownloader.prototype.isDownloaded(self, name) -- 219
	return self.downloadedPackages:has(name) -- 220
end -- 219
function ResourceDownloader.prototype.downloadPackage(self, pkg) -- 223
	if self.downloadTasks:has(pkg.name) then -- 223
		return -- 225
	end -- 225
	local task = thread(function() -- 228
		self.isDownloading = true -- 229
		local downloadStatus = (zh and "正在下载：" or "Downloading: ") .. pkg.name -- 230
		local downloadPath = Path(Content.writablePath, ".download") -- 231
		Content:mkdir(downloadPath) -- 232
		local currentVersion = pkg.currentVersion or 1 -- 233
		local version = pkg.versions[currentVersion] -- 234
		local targetFile = Path(downloadPath, version.file) -- 235
		local success = HttpClient:downloadAsync( -- 237
			version.download, -- 238
			targetFile, -- 239
			30, -- 240
			function(current, total) -- 241
				if self.cancelDownload then -- 241
					return true -- 243
				end -- 243
				self.downloadProgress:set(pkg.name, {progress = current / total, status = downloadStatus}) -- 245
				return false -- 246
			end -- 241
		) -- 241
		if success then -- 241
			downloadStatus = zh and "解压中：" .. pkg.name or "Unziping: " .. pkg.name -- 251
			self.downloadProgress:set(pkg.name, {progress = 1, status = downloadStatus}) -- 252
			local unzipPath = Path(Content.writablePath, "Download", pkg.name) -- 253
			Content:remove(unzipPath) -- 254
			if Content:unzipAsync(targetFile, unzipPath) then -- 254
				Content:remove(targetFile) -- 256
				self.downloadedPackages:add(pkg.name) -- 257
				Director.postNode:emit("UpdateEntries") -- 258
			else -- 258
				Content:remove(unzipPath) -- 260
				self:showPopup(zh and "解压失败" or "Failed to unzip", zh and "无法解压文件：" .. version.file or "Failed to unzip: " .. version.file) -- 261
			end -- 261
		else -- 261
			Content:remove(targetFile) -- 267
			self:showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. version.download or "Failed to download from: " .. version.download) -- 268
		end -- 268
		self.isDownloading = false -- 274
		self.downloadProgress:delete(pkg.name) -- 275
		self.downloadTasks:delete(pkg.name) -- 276
	end) -- 228
	self.downloadTasks:set(pkg.name, task) -- 279
end -- 223
function ResourceDownloader.prototype.messagePopup(self) -- 282
	ImGui.Text(self.popupMessageTitle) -- 283
	ImGui.Separator() -- 284
	ImGui.PushTextWrapPos( -- 285
		300, -- 285
		function() -- 285
			ImGui.TextWrapped(self.popupMessage) -- 286
		end -- 285
	) -- 285
	if ImGui.Button( -- 285
		zh and "确认" or "OK", -- 288
		Vec2(300, 30) -- 288
	) then -- 288
		ImGui.CloseCurrentPopup() -- 289
	end -- 289
end -- 282
function ResourceDownloader.prototype.update(self) -- 293
	local ____App_visualSize_0 = App.visualSize -- 294
	local width = ____App_visualSize_0.width -- 294
	local height = ____App_visualSize_0.height -- 294
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 295
	ImGui.SetNextWindowSize( -- 296
		Vec2(width, 51), -- 296
		"Always" -- 296
	) -- 296
	ImGui.PushStyleVar( -- 297
		"WindowPadding", -- 297
		Vec2(10, 0), -- 297
		function() return ImGui.Begin( -- 297
			"Dora Community Header", -- 297
			windowsNoScrollFlags, -- 297
			function() -- 297
				ImGui.Dummy(Vec2(0, 0)) -- 298
				ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Resources") -- 299
				ImGui.SameLine() -- 300
				ImGui.TextDisabled("(?)") -- 301
				if ImGui.IsItemHovered() then -- 301
					ImGui.BeginTooltip(function() -- 303
						ImGui.PushTextWrapPos( -- 304
							300, -- 304
							function() -- 304
								ImGui.Text(zh and "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" or "Use this tool to download Dora SSR community resources to the `Download` directory.") -- 305
							end -- 304
						) -- 304
					end) -- 303
				end -- 303
				local padding = zh and 400 or 440 -- 309
				if width >= padding then -- 309
					ImGui.SameLine() -- 311
					ImGui.Dummy(Vec2(width - padding, 0)) -- 312
					ImGui.SameLine() -- 313
					ImGui.SetNextItemWidth(zh and -40 or -55) -- 314
					if ImGui.InputText(zh and "筛选" or "Filter", self.filterBuf, {"AutoSelectAll"}) then -- 314
						local res = string.match(self.filterBuf.text, "[^%%%.%[]+") -- 316
						self.filterText = string.lower(res or "") -- 317
					end -- 317
				end -- 317
				ImGui.Separator() -- 320
			end -- 297
		) end -- 297
	) -- 297
	local maxColumns = math.max( -- 322
		math.floor(width / 320), -- 322
		1 -- 322
	) -- 322
	local itemWidth = (width - 60) / maxColumns - 10 -- 323
	ImGui.SetNextWindowPos( -- 324
		Vec2(0, 51), -- 324
		"Always", -- 324
		Vec2.zero -- 324
	) -- 324
	ImGui.SetNextWindowSize( -- 325
		Vec2(width, height - 100), -- 325
		"Always" -- 325
	) -- 325
	ImGui.PushStyleVar( -- 326
		"Alpha", -- 326
		1, -- 326
		function() return ImGui.PushStyleVar( -- 326
			"WindowPadding", -- 326
			Vec2(20, 10), -- 326
			function() return ImGui.Begin( -- 326
				"Dora Community Resources", -- 326
				windowsFlags, -- 326
				function() -- 326
					ImGui.Columns(maxColumns, false) -- 327
					for ____, pkg in ipairs(self.packages) do -- 330
						do -- 330
							local repo = self.repos:get(pkg.name) -- 331
							if not repo then -- 331
								goto __continue64 -- 332
							end -- 332
							if self.filterText ~= "" then -- 332
								local res = string.match( -- 335
									string.lower(repo.name), -- 335
									self.filterText -- 335
								) -- 335
								if not res then -- 335
									goto __continue64 -- 336
								end -- 336
							end -- 336
							ImGui.TextColored(themeColor, repo.title[zh and "zh" or "en"]) -- 340
							local previewTexture = self.previewTextures:get(pkg.name) -- 343
							if previewTexture then -- 343
								local width = previewTexture.width -- 343
								local height = previewTexture.height -- 343
								local scale = (itemWidth - 30) / width -- 347
								local scaledSize = Vec2(width * scale, height * scale) -- 348
								local previewFile = self.previewFiles:get(pkg.name) -- 349
								if previewFile then -- 349
									ImGui.Dummy(Vec2.zero) -- 351
									ImGui.SameLine() -- 352
									ImGui.Image(previewFile, scaledSize) -- 353
								end -- 353
							else -- 353
								ImGui.Text(zh and "加载预览图中..." or "Loading preview...") -- 356
							end -- 356
							ImGui.TextWrapped(repo.desc[zh and "zh" or "en"]) -- 359
							ImGui.TextColored(themeColor, zh and "项目地址：" or "Repo URL:") -- 361
							ImGui.SameLine() -- 362
							if ImGui.TextLink((zh and "这里" or "here") .. "###" .. pkg.url) then -- 362
								App:openURL(pkg.url) -- 364
							end -- 364
							if ImGui.IsItemHovered() then -- 364
								ImGui.BeginTooltip(function() -- 367
									ImGui.PushTextWrapPos( -- 368
										300, -- 368
										function() -- 368
											ImGui.Text(pkg.url) -- 369
										end -- 368
									) -- 368
								end) -- 367
							end -- 367
							local currentVersion = pkg.currentVersion or 1 -- 374
							local version = pkg.versions[currentVersion] -- 375
							if type(version.updatedAt) == "number" then -- 375
								ImGui.TextColored(themeColor, zh and "同步时间：" or "Updated:") -- 377
								ImGui.SameLine() -- 378
								local dateStr = os.date("%Y-%m-%d %H:%M:%S", version.updatedAt) -- 379
								ImGui.Text(dateStr) -- 380
							end -- 380
							local progress = self.downloadProgress:get(pkg.name) -- 384
							if progress ~= nil then -- 384
								ImGui.ProgressBar( -- 386
									progress.progress, -- 386
									Vec2(-1, 30) -- 386
								) -- 386
								ImGui.BeginDisabled(function() -- 387
									ImGui.Button(progress.status) -- 388
								end) -- 387
							end -- 387
							if progress == nil then -- 387
								local isDownloaded = self:isDownloaded(pkg.name) -- 394
								local buttonText = (isDownloaded and (zh and "重新下载" or "Re-Download") or (zh and "下载" or "Download")) .. "###download-" .. pkg.name -- 395
								local deleteText = (zh and "删除" or "Delete") .. "###delete-" .. pkg.name -- 398
								if self.isDownloading then -- 398
									ImGui.BeginDisabled(function() -- 400
										ImGui.Button(buttonText) -- 401
										if isDownloaded then -- 401
											ImGui.SameLine() -- 403
											ImGui.Button(deleteText) -- 404
										end -- 404
									end) -- 400
								else -- 400
									if ImGui.Button(buttonText) then -- 400
										self:downloadPackage(pkg) -- 409
									end -- 409
									if isDownloaded then -- 409
										ImGui.SameLine() -- 412
										if ImGui.Button(deleteText) then -- 412
											Content:remove(Path(Content.writablePath, "Download", pkg.name)) -- 414
											self.downloadedPackages:delete(pkg.name) -- 415
											Director.postNode:emit("UpdateEntries") -- 416
										end -- 416
									end -- 416
								end -- 416
							end -- 416
							ImGui.SameLine() -- 423
							ImGui.Text(__TS__NumberToFixed(version.size / 1024 / 1024, 2) .. " MB") -- 424
							if not self.isDownloading and pkg.versionNames and pkg.currentVersion then -- 424
								ImGui.SameLine() -- 426
								ImGui.SetNextItemWidth(-20) -- 427
								local changed, currentVersion = ImGui.Combo("###" .. pkg.name, pkg.currentVersion, pkg.versionNames) -- 428
								if changed then -- 428
									pkg.currentVersion = currentVersion -- 430
								end -- 430
							end -- 430
							thinSep() -- 434
							ImGui.NextColumn() -- 435
						end -- 435
						::__continue64:: -- 435
					end -- 435
					ImGui.Columns(1, false) -- 438
					ImGui.ScrollWhenDraggingOnVoid() -- 439
					if self.popupShow then -- 439
						self.popupShow = false -- 442
						ImGui.OpenPopup("MessagePopup") -- 443
					end -- 443
					ImGui.BeginPopupModal( -- 445
						"MessagePopup", -- 445
						function() return self:messagePopup() end -- 445
					) -- 445
				end -- 326
			) end -- 326
		) end -- 326
	) -- 326
end -- 293
__TS__New(ResourceDownloader) -- 450
return ____exports -- 450