-- [ts]: ResourceDownloader.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Set = ____lualib.Set -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
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
local zh = false -- 6
do -- 6
	local res = string.match(App.locale, "^zh") -- 8
	zh = res ~= nil and ImGui.IsFontLoaded() -- 9
end -- 9
local windowsNoScrollFlags = { -- 47
	"NoMove", -- 48
	"NoCollapse", -- 49
	"NoResize", -- 50
	"NoDecoration", -- 51
	"NoNav", -- 52
	"NoBringToFrontOnFocus" -- 53
} -- 53
local windowsFlags = { -- 56
	"NoMove", -- 57
	"NoCollapse", -- 58
	"NoResize", -- 59
	"NoDecoration", -- 60
	"NoNav", -- 61
	"AlwaysVerticalScrollbar", -- 62
	"NoBringToFrontOnFocus" -- 63
} -- 63
local themeColor = App.themeColor -- 66
local function sep() -- 68
	return ImGui.SeparatorText("") -- 68
end -- 68
local function thinSep() -- 69
	return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 69
end -- 69
local ResourceDownloader = __TS__Class() -- 71
ResourceDownloader.name = "ResourceDownloader" -- 71
function ResourceDownloader.prototype.____constructor(self) -- 89
	self.packages = {} -- 72
	self.repos = {} -- 73
	self.downloadProgress = __TS__New(Map) -- 74
	self.downloadTasks = __TS__New(Map) -- 75
	self.popupMessageTitle = "" -- 76
	self.popupMessage = "" -- 77
	self.popupShow = false -- 78
	self.cancelDownload = false -- 79
	self.isDownloading = false -- 80
	self.previewTextures = __TS__New(Map) -- 82
	self.previewFiles = __TS__New(Map) -- 83
	self.downloadedPackages = __TS__New(Set) -- 84
	self.isLoading = false -- 85
	self.filterBuf = Buffer(20) -- 86
	self.filterText = "" -- 87
	self.node = Node() -- 90
	self.node:schedule(function() -- 91
		self:update() -- 92
		return false -- 93
	end) -- 91
	self.node:onCleanup(function() -- 95
		self.cancelDownload = true -- 96
	end) -- 95
	self:loadData() -- 98
end -- 89
function ResourceDownloader.prototype.showPopup(self, title, msg) -- 101
	self.popupMessageTitle = title -- 102
	self.popupMessage = msg -- 103
	self.popupShow = true -- 104
end -- 101
function ResourceDownloader.prototype.loadData(self) -- 107
	if self.isLoading then -- 107
		return -- 108
	end -- 108
	self.isLoading = true -- 109
	thread(function() -- 110
		local reload = false -- 111
		local versionResponse = HttpClient:getAsync("http://39.155.148.157:8866/api/v1/package-list-version") -- 112
		local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 113
		if versionResponse then -- 113
			local version = json.load(versionResponse) -- 115
			local packageListVersion = version -- 116
			if Content:exist(packageListVersionFile) then -- 116
				local oldVersion = json.load(Content:load(packageListVersionFile)) -- 118
				local oldPackageListVersion = oldVersion -- 119
				if packageListVersion.version ~= oldPackageListVersion.version then -- 119
					reload = true -- 121
				end -- 121
			else -- 121
				reload = true -- 124
			end -- 124
		end -- 124
		if reload then -- 124
			self.packages = {} -- 128
			self.repos = {} -- 129
			self.previewTextures:clear() -- 130
			self.previewFiles:clear() -- 131
			local cachePath = Path(Content.appPath, ".cache", "preview") -- 132
			Content:remove(cachePath) -- 133
		end -- 133
		local cachePath = Path(Content.appPath, ".cache", "preview") -- 136
		Content:mkdir(cachePath) -- 137
		if reload and versionResponse then -- 137
			Content:save(packageListVersionFile, versionResponse) -- 139
		end -- 139
		local packagesFile = Path(cachePath, "packages.json") -- 141
		if Content:exist(packagesFile) then -- 141
			local packages = json.load(Content:load(packagesFile)) -- 143
			self.packages = packages -- 144
		else -- 144
			local packagesResponse = HttpClient:getAsync("http://39.155.148.157:8866/api/v1/packages") -- 146
			if packagesResponse then -- 146
				local packages = json.load(packagesResponse) -- 149
				self.packages = packages -- 150
				Content:save(packagesFile, packagesResponse) -- 151
			end -- 151
		end -- 151
		for ____, pkg in ipairs(self.packages) do -- 154
			pkg.currentVersion = 1 -- 155
			pkg.versionNames = __TS__ArrayMap( -- 156
				pkg.versions, -- 156
				function(____, v) -- 156
					return v.tag == "" and "No Tag" or v.tag -- 157
				end -- 156
			) -- 156
		end -- 156
		local reposFile = Path(cachePath, "repos.json") -- 162
		if Content:exist(reposFile) then -- 162
			local repos = json.load(Content:load(reposFile)) -- 164
			self.repos = repos -- 165
		else -- 165
			local reposResponse = HttpClient:getAsync("http://39.155.148.157:8866/assets/repos.json") -- 167
			if reposResponse then -- 167
				local repos = json.load(reposResponse) -- 169
				self.repos = repos -- 170
				Content:save(reposFile, reposResponse) -- 171
			end -- 171
		end -- 171
		for ____, pkg in ipairs(self.packages) do -- 176
			local downloadPath = Path(Content.writablePath, "Download", pkg.name) -- 177
			if Content:exist(downloadPath) then -- 177
				self.downloadedPackages:add(pkg.name) -- 179
			end -- 179
			self:loadPreviewImage(pkg.name) -- 181
		end -- 181
		self.isLoading = false -- 183
	end) -- 110
end -- 107
function ResourceDownloader.prototype.loadPreviewImage(self, name) -- 187
	local cachePath = Path(Content.appPath, ".cache", "preview") -- 188
	local cacheFile = Path(cachePath, name .. ".jpg") -- 189
	if Content:exist(cacheFile) then -- 189
		Cache:loadAsync(cacheFile) -- 191
		local texture = Texture2D(cacheFile) -- 192
		if texture then -- 192
			self.previewTextures:set(name, texture) -- 194
			self.previewFiles:set(name, cacheFile) -- 195
		end -- 195
		return -- 197
	end -- 197
	local imageUrl = ("http://39.155.148.157:8866/assets/" .. name) .. "/banner.jpg" -- 199
	local response = HttpClient:downloadAsync(imageUrl, cacheFile, 10) -- 200
	if response then -- 200
		Cache:loadAsync(cacheFile) -- 202
		local texture = Texture2D(cacheFile) -- 203
		if texture then -- 203
			self.previewTextures:set(name, texture) -- 205
			self.previewFiles:set(name, cacheFile) -- 206
		end -- 206
	else -- 206
		print("Failed to load preview image for " .. name) -- 209
	end -- 209
end -- 187
function ResourceDownloader.prototype.isDownloaded(self, name) -- 213
	return self.downloadedPackages:has(name) -- 214
end -- 213
function ResourceDownloader.prototype.downloadPackage(self, pkg) -- 217
	if self.downloadTasks:has(pkg.name) then -- 217
		return -- 219
	end -- 219
	local task = thread(function() -- 222
		self.isDownloading = true -- 223
		local downloadStatus = (zh and "正在下载：" or "Downloading: ") .. pkg.name -- 224
		local downloadPath = Path(Content.writablePath, ".download") -- 225
		Content:mkdir(downloadPath) -- 226
		local currentVersion = pkg.currentVersion or 1 -- 227
		local version = pkg.versions[currentVersion] -- 228
		local targetFile = Path(downloadPath, version.file) -- 229
		local success = HttpClient:downloadAsync( -- 231
			version.download, -- 232
			targetFile, -- 233
			30, -- 234
			function(current, total) -- 235
				if self.cancelDownload then -- 235
					return true -- 237
				end -- 237
				self.downloadProgress:set(pkg.name, {progress = current / total, status = downloadStatus}) -- 239
				return false -- 240
			end -- 235
		) -- 235
		if success then -- 235
			downloadStatus = zh and "解压中：" .. pkg.name or "Unziping: " .. pkg.name -- 245
			self.downloadProgress:set(pkg.name, {progress = 1, status = downloadStatus}) -- 246
			local unzipPath = Path(Content.writablePath, "Download", pkg.name) -- 247
			Content:remove(unzipPath) -- 248
			if Content:unzipAsync(targetFile, unzipPath) then -- 248
				Content:remove(targetFile) -- 250
				self.downloadedPackages:add(pkg.name) -- 251
				Director.postNode:emit("UpdateEntries") -- 252
			else -- 252
				Content:remove(unzipPath) -- 254
				self:showPopup(zh and "解压失败" or "Failed to unzip", zh and "无法解压文件：" .. version.file or "Failed to unzip: " .. version.file) -- 255
			end -- 255
		else -- 255
			Content:remove(targetFile) -- 261
			self:showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. version.download or "Failed to download from: " .. version.download) -- 262
		end -- 262
		self.isDownloading = false -- 268
		self.downloadProgress:delete(pkg.name) -- 269
		self.downloadTasks:delete(pkg.name) -- 270
	end) -- 222
	self.downloadTasks:set(pkg.name, task) -- 273
end -- 217
function ResourceDownloader.prototype.messagePopup(self) -- 276
	ImGui.Text(self.popupMessageTitle) -- 277
	ImGui.Separator() -- 278
	ImGui.PushTextWrapPos( -- 279
		300, -- 279
		function() -- 279
			ImGui.TextWrapped(self.popupMessage) -- 280
		end -- 279
	) -- 279
	if ImGui.Button( -- 279
		zh and "确认" or "OK", -- 282
		Vec2(300, 30) -- 282
	) then -- 282
		ImGui.CloseCurrentPopup() -- 283
	end -- 283
end -- 276
function ResourceDownloader.prototype.update(self) -- 287
	local ____App_visualSize_0 = App.visualSize -- 288
	local width = ____App_visualSize_0.width -- 288
	local height = ____App_visualSize_0.height -- 288
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 289
	ImGui.SetNextWindowSize( -- 290
		Vec2(width, 51), -- 290
		"Always" -- 290
	) -- 290
	ImGui.PushStyleVar( -- 291
		"WindowPadding", -- 291
		Vec2(10, 0), -- 291
		function() return ImGui.Begin( -- 291
			"Dora Community Header", -- 291
			windowsNoScrollFlags, -- 291
			function() -- 291
				ImGui.Dummy(Vec2(0, 0)) -- 292
				ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Resources") -- 293
				ImGui.SameLine() -- 294
				ImGui.TextDisabled("(?)") -- 295
				if ImGui.IsItemHovered() then -- 295
					ImGui.BeginTooltip(function() -- 297
						ImGui.PushTextWrapPos( -- 298
							300, -- 298
							function() -- 298
								ImGui.Text(zh and "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" or "Use this tool to download Dora SSR community resources to the `Download` directory.") -- 299
							end -- 298
						) -- 298
					end) -- 297
				end -- 297
				local padding = zh and 400 or 440 -- 303
				if width >= padding then -- 303
					ImGui.SameLine() -- 305
					ImGui.Dummy(Vec2(width - padding, 0)) -- 306
					ImGui.SameLine() -- 307
					ImGui.SetNextItemWidth(zh and -40 or -55) -- 308
					if ImGui.InputText(zh and "筛选" or "Filter", self.filterBuf, {"AutoSelectAll"}) then -- 308
						local res = string.match(self.filterBuf.text, "[^%%%.%[]+") -- 310
						self.filterText = string.lower(res or "") -- 311
					end -- 311
				end -- 311
				ImGui.Separator() -- 314
			end -- 291
		) end -- 291
	) -- 291
	local maxColumns = math.max( -- 316
		math.floor(width / 350), -- 316
		1 -- 316
	) -- 316
	local itemWidth = (width - 60) / maxColumns - 10 -- 317
	ImGui.SetNextWindowPos( -- 318
		Vec2(0, 51), -- 318
		"Always", -- 318
		Vec2.zero -- 318
	) -- 318
	ImGui.SetNextWindowSize( -- 319
		Vec2(width, height - 100), -- 319
		"Always" -- 319
	) -- 319
	ImGui.PushStyleVar( -- 320
		"WindowPadding", -- 320
		Vec2(20, 10), -- 320
		function() return ImGui.Begin( -- 320
			"Dora Community Resources", -- 320
			windowsFlags, -- 320
			function() -- 320
				ImGui.Columns(maxColumns, false) -- 321
				for ____, pkg in ipairs(self.packages) do -- 324
					do -- 324
						local repo = __TS__ArrayFind( -- 325
							self.repos, -- 325
							function(____, r) return r.name == pkg.name end -- 325
						) -- 325
						if not repo then -- 325
							goto __continue59 -- 326
						end -- 326
						if self.filterText ~= "" then -- 326
							local res = string.match( -- 329
								string.lower(repo.name), -- 329
								self.filterText -- 329
							) -- 329
							if not res then -- 329
								goto __continue59 -- 330
							end -- 330
						end -- 330
						ImGui.TextColored(themeColor, repo.title[zh and "zh" or "en"]) -- 334
						local previewTexture = self.previewTextures:get(pkg.name) -- 337
						if previewTexture then -- 337
							local width = previewTexture.width -- 337
							local height = previewTexture.height -- 337
							local scale = itemWidth / width -- 341
							local scaledSize = Vec2(width * scale, height * scale) -- 342
							local previewFile = self.previewFiles:get(pkg.name) -- 343
							if previewFile then -- 343
								ImGui.Image(previewFile, scaledSize) -- 345
							end -- 345
						else -- 345
							ImGui.Text(zh and "加载预览图中..." or "Loading preview...") -- 348
						end -- 348
						ImGui.TextWrapped(repo.desc[zh and "zh" or "en"]) -- 351
						ImGui.TextColored(themeColor, zh and "项目地址：" or "Repo URL:") -- 353
						ImGui.SameLine() -- 354
						if ImGui.TextLink((zh and "这里" or "here") .. "###" .. pkg.url) then -- 354
							App:openURL(pkg.url) -- 356
						end -- 356
						if ImGui.IsItemHovered() then -- 356
							ImGui.BeginTooltip(function() -- 359
								ImGui.PushTextWrapPos( -- 360
									300, -- 360
									function() -- 360
										ImGui.Text(pkg.url) -- 361
									end -- 360
								) -- 360
							end) -- 359
						end -- 359
						local currentVersion = pkg.currentVersion or 1 -- 366
						local version = pkg.versions[currentVersion] -- 367
						if type(version.updatedAt) == "number" then -- 367
							ImGui.TextColored(themeColor, zh and "同步时间：" or "Updated:") -- 369
							ImGui.SameLine() -- 370
							local dateStr = os.date("%Y-%m-%d %H:%M:%S", version.updatedAt) -- 371
							ImGui.Text(dateStr) -- 372
						end -- 372
						local progress = self.downloadProgress:get(pkg.name) -- 376
						if progress ~= nil then -- 376
							ImGui.ProgressBar( -- 378
								progress.progress, -- 378
								Vec2(-1, 30) -- 378
							) -- 378
							ImGui.BeginDisabled(function() -- 379
								ImGui.Button(progress.status) -- 380
							end) -- 379
						end -- 379
						if progress == nil then -- 379
							local isDownloaded = self:isDownloaded(pkg.name) -- 386
							local buttonText = isDownloaded and (zh and "重新下载" or "Re-Download") or (zh and "下载" or "Download") -- 387
							if self.isDownloading then -- 387
								ImGui.BeginDisabled(function() -- 391
									ImGui.PushID( -- 392
										pkg.name, -- 392
										function() -- 392
											ImGui.Button(buttonText) -- 393
										end -- 392
									) -- 392
								end) -- 391
							else -- 391
								ImGui.PushID( -- 397
									pkg.name, -- 397
									function() -- 397
										if ImGui.Button(buttonText) then -- 397
											self:downloadPackage(pkg) -- 399
										end -- 399
									end -- 397
								) -- 397
							end -- 397
						end -- 397
						ImGui.SameLine() -- 406
						ImGui.Text(__TS__NumberToFixed(version.size / 1024 / 1024, 2) .. " MB") -- 407
						if not self.isDownloading and pkg.versionNames and pkg.currentVersion then -- 407
							ImGui.SameLine() -- 409
							ImGui.SetNextItemWidth(-20) -- 410
							local changed, currentVersion = ImGui.Combo("###" .. pkg.name, pkg.currentVersion, pkg.versionNames) -- 411
							if changed then -- 411
								pkg.currentVersion = currentVersion -- 413
							end -- 413
						end -- 413
						thinSep() -- 417
						ImGui.NextColumn() -- 418
					end -- 418
					::__continue59:: -- 418
				end -- 418
				ImGui.ScrollWhenDraggingOnVoid() -- 421
				if self.popupShow then -- 421
					self.popupShow = false -- 424
					ImGui.OpenPopup("MessagePopup") -- 425
				end -- 425
				ImGui.BeginPopupModal( -- 427
					"MessagePopup", -- 427
					function() return self:messagePopup() end -- 427
				) -- 427
			end -- 320
		) end -- 320
	) -- 320
end -- 287
__TS__New(ResourceDownloader) -- 432
return ____exports -- 432