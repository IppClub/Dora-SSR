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
	self.repos = {} -- 75
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
			self.repos = {} -- 131
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
			self.repos = repos -- 167
		else -- 167
			local reposResponse = HttpClient:getAsync(url .. "/assets/repos.json") -- 169
			if reposResponse then -- 169
				local repos = json.load(reposResponse) -- 171
				self.repos = repos -- 172
				Content:save(reposFile, reposResponse) -- 173
			end -- 173
		end -- 173
		for ____, pkg in ipairs(self.packages) do -- 178
			local downloadPath = Path(Content.writablePath, "Download", pkg.name) -- 179
			if Content:exist(downloadPath) then -- 179
				self.downloadedPackages:add(pkg.name) -- 181
			end -- 181
			self:loadPreviewImage(pkg.name) -- 183
		end -- 183
		self.isLoading = false -- 185
	end) -- 112
end -- 109
function ResourceDownloader.prototype.loadPreviewImage(self, name) -- 189
	local cachePath = Path(Content.appPath, ".cache", "preview") -- 190
	local cacheFile = Path(cachePath, name .. ".jpg") -- 191
	if Content:exist(cacheFile) then -- 191
		Cache:loadAsync(cacheFile) -- 193
		local texture = Texture2D(cacheFile) -- 194
		if texture then -- 194
			self.previewTextures:set(name, texture) -- 196
			self.previewFiles:set(name, cacheFile) -- 197
		end -- 197
		return -- 199
	end -- 199
	local imageUrl = ((url .. "/assets/") .. name) .. "/banner.jpg" -- 201
	local response = HttpClient:downloadAsync(imageUrl, cacheFile, 10) -- 202
	if response then -- 202
		Cache:loadAsync(cacheFile) -- 204
		local texture = Texture2D(cacheFile) -- 205
		if texture then -- 205
			self.previewTextures:set(name, texture) -- 207
			self.previewFiles:set(name, cacheFile) -- 208
		end -- 208
	else -- 208
		print("Failed to load preview image for " .. name) -- 211
	end -- 211
end -- 189
function ResourceDownloader.prototype.isDownloaded(self, name) -- 215
	return self.downloadedPackages:has(name) -- 216
end -- 215
function ResourceDownloader.prototype.downloadPackage(self, pkg) -- 219
	if self.downloadTasks:has(pkg.name) then -- 219
		return -- 221
	end -- 221
	local task = thread(function() -- 224
		self.isDownloading = true -- 225
		local downloadStatus = (zh and "正在下载：" or "Downloading: ") .. pkg.name -- 226
		local downloadPath = Path(Content.writablePath, ".download") -- 227
		Content:mkdir(downloadPath) -- 228
		local currentVersion = pkg.currentVersion or 1 -- 229
		local version = pkg.versions[currentVersion] -- 230
		local targetFile = Path(downloadPath, version.file) -- 231
		local success = HttpClient:downloadAsync( -- 233
			version.download, -- 234
			targetFile, -- 235
			30, -- 236
			function(current, total) -- 237
				if self.cancelDownload then -- 237
					return true -- 239
				end -- 239
				self.downloadProgress:set(pkg.name, {progress = current / total, status = downloadStatus}) -- 241
				return false -- 242
			end -- 237
		) -- 237
		if success then -- 237
			downloadStatus = zh and "解压中：" .. pkg.name or "Unziping: " .. pkg.name -- 247
			self.downloadProgress:set(pkg.name, {progress = 1, status = downloadStatus}) -- 248
			local unzipPath = Path(Content.writablePath, "Download", pkg.name) -- 249
			Content:remove(unzipPath) -- 250
			if Content:unzipAsync(targetFile, unzipPath) then -- 250
				Content:remove(targetFile) -- 252
				self.downloadedPackages:add(pkg.name) -- 253
				Director.postNode:emit("UpdateEntries") -- 254
			else -- 254
				Content:remove(unzipPath) -- 256
				self:showPopup(zh and "解压失败" or "Failed to unzip", zh and "无法解压文件：" .. version.file or "Failed to unzip: " .. version.file) -- 257
			end -- 257
		else -- 257
			Content:remove(targetFile) -- 263
			self:showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. version.download or "Failed to download from: " .. version.download) -- 264
		end -- 264
		self.isDownloading = false -- 270
		self.downloadProgress:delete(pkg.name) -- 271
		self.downloadTasks:delete(pkg.name) -- 272
	end) -- 224
	self.downloadTasks:set(pkg.name, task) -- 275
end -- 219
function ResourceDownloader.prototype.messagePopup(self) -- 278
	ImGui.Text(self.popupMessageTitle) -- 279
	ImGui.Separator() -- 280
	ImGui.PushTextWrapPos( -- 281
		300, -- 281
		function() -- 281
			ImGui.TextWrapped(self.popupMessage) -- 282
		end -- 281
	) -- 281
	if ImGui.Button( -- 281
		zh and "确认" or "OK", -- 284
		Vec2(300, 30) -- 284
	) then -- 284
		ImGui.CloseCurrentPopup() -- 285
	end -- 285
end -- 278
function ResourceDownloader.prototype.update(self) -- 289
	local ____App_visualSize_0 = App.visualSize -- 290
	local width = ____App_visualSize_0.width -- 290
	local height = ____App_visualSize_0.height -- 290
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 291
	ImGui.SetNextWindowSize( -- 292
		Vec2(width, 51), -- 292
		"Always" -- 292
	) -- 292
	ImGui.PushStyleVar( -- 293
		"WindowPadding", -- 293
		Vec2(10, 0), -- 293
		function() return ImGui.Begin( -- 293
			"Dora Community Header", -- 293
			windowsNoScrollFlags, -- 293
			function() -- 293
				ImGui.Dummy(Vec2(0, 0)) -- 294
				ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Resources") -- 295
				ImGui.SameLine() -- 296
				ImGui.TextDisabled("(?)") -- 297
				if ImGui.IsItemHovered() then -- 297
					ImGui.BeginTooltip(function() -- 299
						ImGui.PushTextWrapPos( -- 300
							300, -- 300
							function() -- 300
								ImGui.Text(zh and "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" or "Use this tool to download Dora SSR community resources to the `Download` directory.") -- 301
							end -- 300
						) -- 300
					end) -- 299
				end -- 299
				local padding = zh and 400 or 440 -- 305
				if width >= padding then -- 305
					ImGui.SameLine() -- 307
					ImGui.Dummy(Vec2(width - padding, 0)) -- 308
					ImGui.SameLine() -- 309
					ImGui.SetNextItemWidth(zh and -40 or -55) -- 310
					if ImGui.InputText(zh and "筛选" or "Filter", self.filterBuf, {"AutoSelectAll"}) then -- 310
						local res = string.match(self.filterBuf.text, "[^%%%.%[]+") -- 312
						self.filterText = string.lower(res or "") -- 313
					end -- 313
				end -- 313
				ImGui.Separator() -- 316
			end -- 293
		) end -- 293
	) -- 293
	local maxColumns = math.max( -- 318
		math.floor(width / 350), -- 318
		1 -- 318
	) -- 318
	local itemWidth = (width - 60) / maxColumns - 10 -- 319
	ImGui.SetNextWindowPos( -- 320
		Vec2(0, 51), -- 320
		"Always", -- 320
		Vec2.zero -- 320
	) -- 320
	ImGui.SetNextWindowSize( -- 321
		Vec2(width, height - 100), -- 321
		"Always" -- 321
	) -- 321
	ImGui.PushStyleVar( -- 322
		"WindowPadding", -- 322
		Vec2(20, 10), -- 322
		function() return ImGui.Begin( -- 322
			"Dora Community Resources", -- 322
			windowsFlags, -- 322
			function() -- 322
				ImGui.Columns(maxColumns, false) -- 323
				for ____, pkg in ipairs(self.packages) do -- 326
					do -- 326
						local repo = __TS__ArrayFind( -- 327
							self.repos, -- 327
							function(____, r) return r.name == pkg.name end -- 327
						) -- 327
						if not repo then -- 327
							goto __continue59 -- 328
						end -- 328
						if self.filterText ~= "" then -- 328
							local res = string.match( -- 331
								string.lower(repo.name), -- 331
								self.filterText -- 331
							) -- 331
							if not res then -- 331
								goto __continue59 -- 332
							end -- 332
						end -- 332
						ImGui.TextColored(themeColor, repo.title[zh and "zh" or "en"]) -- 336
						local previewTexture = self.previewTextures:get(pkg.name) -- 339
						if previewTexture then -- 339
							local width = previewTexture.width -- 339
							local height = previewTexture.height -- 339
							local scale = itemWidth / width -- 343
							local scaledSize = Vec2(width * scale, height * scale) -- 344
							local previewFile = self.previewFiles:get(pkg.name) -- 345
							if previewFile then -- 345
								ImGui.Image(previewFile, scaledSize) -- 347
							end -- 347
						else -- 347
							ImGui.Text(zh and "加载预览图中..." or "Loading preview...") -- 350
						end -- 350
						ImGui.TextWrapped(repo.desc[zh and "zh" or "en"]) -- 353
						ImGui.TextColored(themeColor, zh and "项目地址：" or "Repo URL:") -- 355
						ImGui.SameLine() -- 356
						if ImGui.TextLink((zh and "这里" or "here") .. "###" .. pkg.url) then -- 356
							App:openURL(pkg.url) -- 358
						end -- 358
						if ImGui.IsItemHovered() then -- 358
							ImGui.BeginTooltip(function() -- 361
								ImGui.PushTextWrapPos( -- 362
									300, -- 362
									function() -- 362
										ImGui.Text(pkg.url) -- 363
									end -- 362
								) -- 362
							end) -- 361
						end -- 361
						local currentVersion = pkg.currentVersion or 1 -- 368
						local version = pkg.versions[currentVersion] -- 369
						if type(version.updatedAt) == "number" then -- 369
							ImGui.TextColored(themeColor, zh and "同步时间：" or "Updated:") -- 371
							ImGui.SameLine() -- 372
							local dateStr = os.date("%Y-%m-%d %H:%M:%S", version.updatedAt) -- 373
							ImGui.Text(dateStr) -- 374
						end -- 374
						local progress = self.downloadProgress:get(pkg.name) -- 378
						if progress ~= nil then -- 378
							ImGui.ProgressBar( -- 380
								progress.progress, -- 380
								Vec2(-1, 30) -- 380
							) -- 380
							ImGui.BeginDisabled(function() -- 381
								ImGui.Button(progress.status) -- 382
							end) -- 381
						end -- 381
						if progress == nil then -- 381
							local isDownloaded = self:isDownloaded(pkg.name) -- 388
							local buttonText = (isDownloaded and (zh and "重新下载" or "Re-Download") or (zh and "下载" or "Download")) .. "###download-" .. pkg.name -- 389
							local deleteText = (zh and "删除" or "Delete") .. "###delete-" .. pkg.name -- 392
							if self.isDownloading then -- 392
								ImGui.BeginDisabled(function() -- 394
									ImGui.Button(buttonText) -- 395
									if isDownloaded then -- 395
										ImGui.SameLine() -- 397
										ImGui.Button(deleteText) -- 398
									end -- 398
								end) -- 394
							else -- 394
								if ImGui.Button(buttonText) then -- 394
									self:downloadPackage(pkg) -- 403
								end -- 403
								if isDownloaded then -- 403
									ImGui.SameLine() -- 406
									if ImGui.Button(deleteText) then -- 406
										Content:remove(Path(Content.writablePath, "Download", pkg.name)) -- 408
										self.downloadedPackages:delete(pkg.name) -- 409
									end -- 409
								end -- 409
							end -- 409
						end -- 409
						ImGui.SameLine() -- 416
						ImGui.Text(__TS__NumberToFixed(version.size / 1024 / 1024, 2) .. " MB") -- 417
						if not self.isDownloading and pkg.versionNames and pkg.currentVersion then -- 417
							ImGui.SameLine() -- 419
							ImGui.SetNextItemWidth(-20) -- 420
							local changed, currentVersion = ImGui.Combo("###" .. pkg.name, pkg.currentVersion, pkg.versionNames) -- 421
							if changed then -- 421
								pkg.currentVersion = currentVersion -- 423
							end -- 423
						end -- 423
						thinSep() -- 427
						ImGui.NextColumn() -- 428
					end -- 428
					::__continue59:: -- 428
				end -- 428
				ImGui.Columns(1, false) -- 431
				ImGui.ScrollWhenDraggingOnVoid() -- 432
				if self.popupShow then -- 432
					self.popupShow = false -- 435
					ImGui.OpenPopup("MessagePopup") -- 436
				end -- 436
				ImGui.BeginPopupModal( -- 438
					"MessagePopup", -- 438
					function() return self:messagePopup() end -- 438
				) -- 438
			end -- 322
		) end -- 322
	) -- 322
end -- 289
__TS__New(ResourceDownloader) -- 443
return ____exports -- 443