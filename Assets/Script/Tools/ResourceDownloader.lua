-- [ts]: ResourceDownloader.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Set = ____lualib.Set -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__Iterator = ____lualib.__TS__Iterator -- 1
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
local Config = require("Config") -- 5
local DefaultURL = "http://39.155.148.157:8866" -- 7
local url = Buffer(1024) -- 13
local config = Config(".ResConf", "url") -- 14
config:load() -- 15
if type(config.url) == "string" then -- 15
	url.text = config.url -- 18
else -- 18
	config.url = DefaultURL -- 20
	url.text = DefaultURL -- 20
end -- 20
local zh = false -- 23
do -- 23
	local res = string.match(App.locale, "^zh") -- 25
	zh = res ~= nil -- 26
end -- 26
local windowsNoScrollFlags = { -- 64
	"NoMove", -- 65
	"NoCollapse", -- 66
	"NoResize", -- 67
	"NoDecoration", -- 68
	"NoNav", -- 69
	"NoSavedSettings", -- 70
	"NoFocusOnAppearing", -- 71
	"NoBringToFrontOnFocus" -- 72
} -- 72
local windowsFlags = { -- 75
	"NoMove", -- 76
	"NoCollapse", -- 77
	"NoResize", -- 78
	"NoDecoration", -- 79
	"NoNav", -- 80
	"NoSavedSettings", -- 81
	"AlwaysVerticalScrollbar", -- 82
	"NoFocusOnAppearing", -- 83
	"NoBringToFrontOnFocus" -- 84
} -- 84
local tabBarFlags = {"FittingPolicyScroll", "DrawSelectedOverline", "NoCloseWithMiddleMouseButton", "TabListPopupButton"} -- 87
local themeColor = App.themeColor -- 94
local function sep() -- 96
	return ImGui.SeparatorText("") -- 96
end -- 96
local function thinSep() -- 97
	return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 97
end -- 97
local ResourceDownloader = __TS__Class() -- 99
ResourceDownloader.name = "ResourceDownloader" -- 99
function ResourceDownloader.prototype.____constructor(self) -- 119
	self.packages = {} -- 100
	self.repos = __TS__New(Map) -- 101
	self.downloadProgress = __TS__New(Map) -- 102
	self.downloadTasks = __TS__New(Map) -- 103
	self.popupMessageTitle = "" -- 104
	self.popupMessage = "" -- 105
	self.popupShow = false -- 106
	self.cancelDownload = false -- 107
	self.isDownloading = false -- 108
	self.previewTextures = __TS__New(Map) -- 110
	self.previewFiles = __TS__New(Map) -- 111
	self.downloadedPackages = __TS__New(Set) -- 112
	self.isLoading = false -- 113
	self.filterBuf = Buffer(20) -- 114
	self.filterText = "" -- 115
	self.categories = {} -- 116
	self.headerHeight = 80 -- 117
	self.node = Node() -- 120
	self.node:schedule(function() -- 121
		self:update() -- 122
		return false -- 123
	end) -- 121
	self.node:onCleanup(function() -- 125
		self.cancelDownload = true -- 126
	end) -- 125
	self:loadData() -- 128
end -- 119
function ResourceDownloader.prototype.showPopup(self, title, msg) -- 131
	self.popupMessageTitle = title -- 132
	self.popupMessage = msg -- 133
	self.popupShow = true -- 134
end -- 131
function ResourceDownloader.prototype.loadData(self) -- 137
	if self.isLoading then -- 137
		return -- 138
	end -- 138
	self.isLoading = true -- 139
	thread(function() -- 140
		local reload = false -- 141
		local versionResponse = HttpClient:getAsync(config.url .. "/api/v1/package-list-version") -- 142
		local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 143
		if versionResponse then -- 143
			local version = json.load(versionResponse) -- 145
			local packageListVersion = version -- 146
			if Content:exist(packageListVersionFile) then -- 146
				local oldVersion = json.load(Content:load(packageListVersionFile)) -- 148
				local oldPackageListVersion = oldVersion -- 149
				if packageListVersion.version ~= oldPackageListVersion.version then -- 149
					reload = true -- 151
				end -- 151
			else -- 151
				reload = true -- 154
			end -- 154
		end -- 154
		if reload then -- 154
			self.categories = {} -- 158
			self.packages = {} -- 159
			self.repos = __TS__New(Map) -- 160
			self.previewTextures:clear() -- 161
			self.previewFiles:clear() -- 162
			local cachePath = Path(Content.appPath, ".cache", "preview") -- 163
			Content:remove(cachePath) -- 164
		end -- 164
		local cachePath = Path(Content.appPath, ".cache", "preview") -- 167
		Content:mkdir(cachePath) -- 168
		if reload and versionResponse then -- 168
			Content:save(packageListVersionFile, versionResponse) -- 170
		end -- 170
		local packagesFile = Path(cachePath, "packages.json") -- 172
		if Content:exist(packagesFile) then -- 172
			local packages = json.load(Content:load(packagesFile)) -- 174
			self.packages = packages -- 175
		else -- 175
			local packagesResponse = HttpClient:getAsync(config.url .. "/api/v1/packages") -- 177
			if packagesResponse then -- 177
				local packages = json.load(packagesResponse) -- 180
				self.packages = packages -- 181
				Content:save(packagesFile, packagesResponse) -- 182
			end -- 182
		end -- 182
		for ____, pkg in ipairs(self.packages) do -- 185
			pkg.currentVersion = 1 -- 186
			pkg.versionNames = __TS__ArrayMap( -- 187
				pkg.versions, -- 187
				function(____, v) -- 187
					return v.tag == "" and "No Tag" or v.tag -- 188
				end -- 187
			) -- 187
		end -- 187
		local catSet = __TS__New(Set) -- 193
		local function loadRepos(repos) -- 194
			for ____, repo in ipairs(repos) do -- 195
				self.repos:set(repo.name, repo) -- 196
				if repo.categories then -- 196
					for ____, cat in ipairs(repo.categories) do -- 198
						catSet:add(cat) -- 199
					end -- 199
				end -- 199
			end -- 199
		end -- 194
		local reposFile = Path(cachePath, "repos.json") -- 204
		if Content:exist(reposFile) then -- 204
			local repos = json.load(Content:load(reposFile)) -- 206
			loadRepos(repos) -- 207
		else -- 207
			local reposResponse = HttpClient:getAsync(config.url .. "/assets/repos.json") -- 209
			if reposResponse then -- 209
				local repos = json.load(reposResponse) -- 211
				loadRepos(repos) -- 212
				Content:save(reposFile, reposResponse) -- 213
			end -- 213
		end -- 213
		for ____, cat in __TS__Iterator(catSet) do -- 216
			local ____self_categories_0 = self.categories -- 216
			____self_categories_0[#____self_categories_0 + 1] = cat -- 217
		end -- 217
		for ____, pkg in ipairs(self.packages) do -- 221
			local downloadPath = Path(Content.writablePath, "Download", pkg.name) -- 222
			if Content:exist(downloadPath) then -- 222
				self.downloadedPackages:add(pkg.name) -- 224
			end -- 224
			self:loadPreviewImage(pkg.name) -- 226
		end -- 226
		self.isLoading = false -- 228
	end) -- 140
end -- 137
function ResourceDownloader.prototype.loadPreviewImage(self, name) -- 232
	local cachePath = Path(Content.appPath, ".cache", "preview") -- 233
	local cacheFile = Path(cachePath, name .. ".jpg") -- 234
	if Content:exist(cacheFile) then -- 234
		Cache:loadAsync(cacheFile) -- 236
		local texture = Texture2D(cacheFile) -- 237
		if texture then -- 237
			self.previewTextures:set(name, texture) -- 239
			self.previewFiles:set(name, cacheFile) -- 240
		end -- 240
		return -- 242
	end -- 242
	local imageUrl = ((config.url .. "/assets/") .. name) .. "/banner.jpg" -- 244
	local response = HttpClient:downloadAsync(imageUrl, cacheFile, 10) -- 245
	if response then -- 245
		Cache:loadAsync(cacheFile) -- 247
		local texture = Texture2D(cacheFile) -- 248
		if texture then -- 248
			self.previewTextures:set(name, texture) -- 250
			self.previewFiles:set(name, cacheFile) -- 251
		end -- 251
	else -- 251
		print("Failed to load preview image for " .. name) -- 254
	end -- 254
end -- 232
function ResourceDownloader.prototype.isDownloaded(self, name) -- 258
	return self.downloadedPackages:has(name) -- 259
end -- 258
function ResourceDownloader.prototype.downloadPackage(self, pkg) -- 262
	if self.downloadTasks:has(pkg.name) then -- 262
		return -- 264
	end -- 264
	local task = thread(function() -- 267
		self.isDownloading = true -- 268
		local downloadStatus = (zh and "正在下载：" or "Downloading: ") .. pkg.name -- 269
		local downloadPath = Path(Content.writablePath, ".download") -- 270
		Content:mkdir(downloadPath) -- 271
		local currentVersion = pkg.currentVersion or 1 -- 272
		local version = pkg.versions[currentVersion] -- 273
		local targetFile = Path(downloadPath, version.file) -- 274
		local success = HttpClient:downloadAsync( -- 276
			version.download, -- 277
			targetFile, -- 278
			30, -- 279
			function(current, total) -- 280
				if self.cancelDownload then -- 280
					return true -- 282
				end -- 282
				self.downloadProgress:set(pkg.name, {progress = current / total, status = downloadStatus}) -- 284
				return false -- 285
			end -- 280
		) -- 280
		if success then -- 280
			downloadStatus = zh and "解压中：" .. pkg.name or "Unziping: " .. pkg.name -- 290
			self.downloadProgress:set(pkg.name, {progress = 1, status = downloadStatus}) -- 291
			local unzipPath = Path(Content.writablePath, "Download", pkg.name) -- 292
			Content:remove(unzipPath) -- 293
			if Content:unzipAsync(targetFile, unzipPath) then -- 293
				Content:remove(targetFile) -- 295
				self.downloadedPackages:add(pkg.name) -- 296
				Director.postNode:emit("UpdateEntries") -- 297
			else -- 297
				Content:remove(unzipPath) -- 299
				self:showPopup(zh and "解压失败" or "Failed to unzip", zh and "无法解压文件：" .. version.file or "Failed to unzip: " .. version.file) -- 300
			end -- 300
		else -- 300
			Content:remove(targetFile) -- 306
			self:showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. version.download or "Failed to download from: " .. version.download) -- 307
		end -- 307
		self.isDownloading = false -- 313
		self.downloadProgress:delete(pkg.name) -- 314
		self.downloadTasks:delete(pkg.name) -- 315
	end) -- 267
	self.downloadTasks:set(pkg.name, task) -- 318
end -- 262
function ResourceDownloader.prototype.messagePopup(self) -- 321
	ImGui.Text(self.popupMessageTitle) -- 322
	ImGui.Separator() -- 323
	ImGui.PushTextWrapPos( -- 324
		300, -- 324
		function() -- 324
			ImGui.TextWrapped(self.popupMessage) -- 325
		end -- 324
	) -- 324
	if ImGui.Button( -- 324
		zh and "确认" or "OK", -- 327
		Vec2(300, 30) -- 327
	) then -- 327
		ImGui.CloseCurrentPopup() -- 328
	end -- 328
end -- 321
function ResourceDownloader.prototype.update(self) -- 332
	local ____App_visualSize_1 = App.visualSize -- 333
	local width = ____App_visualSize_1.width -- 333
	local height = ____App_visualSize_1.height -- 333
	local filterCategory = nil -- 334
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 335
	ImGui.SetNextWindowSize( -- 336
		Vec2(width, self.headerHeight), -- 336
		"Always" -- 336
	) -- 336
	ImGui.PushStyleVar( -- 337
		"WindowPadding", -- 337
		Vec2(10, 0), -- 337
		function() return ImGui.Begin( -- 337
			"Dora Community Header", -- 337
			windowsNoScrollFlags, -- 337
			function() -- 337
				ImGui.Dummy(Vec2(0, 0)) -- 338
				ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Resources") -- 339
				ImGui.SameLine() -- 340
				ImGui.TextDisabled("(?)") -- 341
				if ImGui.IsItemHovered() then -- 341
					ImGui.BeginTooltip(function() -- 343
						ImGui.PushTextWrapPos( -- 344
							300, -- 344
							function() -- 344
								ImGui.Text(zh and "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" or "Use this tool to download Dora SSR community resources to the `Download` directory.") -- 345
							end -- 344
						) -- 344
					end) -- 343
				end -- 343
				local padding = zh and 400 or 440 -- 349
				if width >= padding then -- 349
					ImGui.SameLine() -- 351
					ImGui.Dummy(Vec2(width - padding, 0)) -- 352
					ImGui.SameLine() -- 353
					ImGui.SetNextItemWidth((zh and -40 or -55) - 40) -- 354
					if ImGui.InputText(zh and "筛选" or "Filter", self.filterBuf, {"AutoSelectAll"}) then -- 354
						local res = string.match(self.filterBuf.text, "[^%%%.%[]+") -- 356
						self.filterText = string.lower(res or "") -- 357
					end -- 357
				else -- 357
					ImGui.SameLine() -- 360
					ImGui.Dummy(Vec2(width - (zh and 250 or 255), 0)) -- 361
				end -- 361
				ImGui.SameLine() -- 363
				if ImGui.CollapsingHeader("##option") then -- 363
					self.headerHeight = 130 -- 365
					ImGui.SetNextItemWidth(zh and -200 or -230) -- 366
					if ImGui.InputText(zh and "服务器" or "Server", url) then -- 366
						if url.text == "" then -- 366
							url.text = DefaultURL -- 369
						end -- 369
						config.url = url.text -- 371
					end -- 371
					ImGui.SameLine() -- 373
					if ImGui.Button(zh and "刷新" or "Reload") then -- 373
						local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 375
						Content:remove(packageListVersionFile) -- 376
						self:loadData() -- 377
					end -- 377
					ImGui.Separator() -- 379
				else -- 379
					self.headerHeight = 80 -- 381
				end -- 381
				ImGui.PushStyleVar( -- 383
					"WindowPadding", -- 383
					Vec2(10, 10), -- 383
					function() return ImGui.BeginTabBar( -- 383
						"categories", -- 383
						tabBarFlags, -- 383
						function() -- 383
							ImGui.BeginTabItem( -- 384
								zh and "全部" or "All", -- 384
								function() -- 384
									filterCategory = nil -- 385
								end -- 384
							) -- 384
							for ____, cat in ipairs(self.categories) do -- 387
								ImGui.BeginTabItem( -- 388
									cat, -- 388
									function() -- 388
										filterCategory = cat -- 389
									end -- 388
								) -- 388
							end -- 388
						end -- 383
					) end -- 383
				) -- 383
			end -- 337
		) end -- 337
	) -- 337
	local function matchCat(self, cat) -- 394
		return filterCategory == cat -- 394
	end -- 394
	local maxColumns = math.max( -- 395
		math.floor(width / 320), -- 395
		1 -- 395
	) -- 395
	local itemWidth = (width - 60) / maxColumns - 10 -- 396
	ImGui.SetNextWindowPos( -- 397
		Vec2(0, self.headerHeight), -- 397
		"Always", -- 397
		Vec2.zero -- 397
	) -- 397
	ImGui.SetNextWindowSize( -- 398
		Vec2(width, height - self.headerHeight - 50), -- 398
		"Always" -- 398
	) -- 398
	ImGui.PushStyleVar( -- 399
		"Alpha", -- 399
		1, -- 399
		function() return ImGui.PushStyleVar( -- 399
			"WindowPadding", -- 399
			Vec2(20, 10), -- 399
			function() return ImGui.Begin( -- 399
				"Dora Community Resources", -- 399
				windowsFlags, -- 399
				function() -- 399
					ImGui.Columns(maxColumns, false) -- 400
					for ____, pkg in ipairs(self.packages) do -- 403
						do -- 403
							local repo = self.repos:get(pkg.name) -- 404
							if not repo then -- 404
								goto __continue83 -- 405
							end -- 405
							if filterCategory ~= nil then -- 405
								if not repo.categories then -- 405
									goto __continue83 -- 407
								end -- 407
								if __TS__ArrayFind(repo.categories, matchCat) == nil then -- 407
									goto __continue83 -- 409
								end -- 409
							end -- 409
							if self.filterText ~= "" then -- 409
								local res = string.match( -- 414
									string.lower(repo.name), -- 414
									self.filterText -- 414
								) -- 414
								if not res then -- 414
									goto __continue83 -- 415
								end -- 415
							end -- 415
							ImGui.TextColored(themeColor, repo.title[zh and "zh" or "en"]) -- 419
							local previewTexture = self.previewTextures:get(pkg.name) -- 422
							if previewTexture then -- 422
								local width = previewTexture.width -- 422
								local height = previewTexture.height -- 422
								local scale = (itemWidth - 30) / width -- 426
								local scaledSize = Vec2(width * scale, height * scale) -- 427
								local previewFile = self.previewFiles:get(pkg.name) -- 428
								if previewFile then -- 428
									ImGui.Dummy(Vec2.zero) -- 430
									ImGui.SameLine() -- 431
									ImGui.Image(previewFile, scaledSize) -- 432
								end -- 432
							else -- 432
								ImGui.Text(zh and "加载预览图中..." or "Loading preview...") -- 435
							end -- 435
							ImGui.TextWrapped(repo.desc[zh and "zh" or "en"]) -- 438
							ImGui.TextColored(themeColor, zh and "项目地址：" or "Repo URL:") -- 440
							ImGui.SameLine() -- 441
							if ImGui.TextLink((zh and "这里" or "here") .. "##" .. pkg.url) then -- 441
								App:openURL(pkg.url) -- 443
							end -- 443
							if ImGui.IsItemHovered() then -- 443
								ImGui.BeginTooltip(function() -- 446
									ImGui.PushTextWrapPos( -- 447
										300, -- 447
										function() -- 447
											ImGui.Text(pkg.url) -- 448
										end -- 447
									) -- 447
								end) -- 446
							end -- 446
							local currentVersion = pkg.currentVersion or 1 -- 453
							local version = pkg.versions[currentVersion] -- 454
							if type(version.updatedAt) == "number" then -- 454
								ImGui.TextColored(themeColor, zh and "同步时间：" or "Updated:") -- 456
								ImGui.SameLine() -- 457
								local dateStr = os.date("%Y-%m-%d %H:%M:%S", version.updatedAt) -- 458
								ImGui.Text(dateStr) -- 459
							end -- 459
							local progress = self.downloadProgress:get(pkg.name) -- 463
							if progress ~= nil then -- 463
								ImGui.ProgressBar( -- 465
									progress.progress, -- 465
									Vec2(-1, 30) -- 465
								) -- 465
								ImGui.BeginDisabled(function() -- 466
									ImGui.Button(progress.status) -- 467
								end) -- 466
							end -- 466
							if progress == nil then -- 466
								local isDownloaded = self:isDownloaded(pkg.name) -- 473
								local buttonText = (isDownloaded and (zh and "重新下载" or "Re-Download") or (zh and "下载" or "Download")) .. "##download-" .. pkg.name -- 474
								local deleteText = (zh and "删除" or "Delete") .. "##delete-" .. pkg.name -- 477
								if self.isDownloading then -- 477
									ImGui.BeginDisabled(function() -- 479
										ImGui.Button(buttonText) -- 480
										if isDownloaded then -- 480
											ImGui.SameLine() -- 482
											ImGui.Button(deleteText) -- 483
										end -- 483
									end) -- 479
								else -- 479
									if ImGui.Button(buttonText) then -- 479
										self:downloadPackage(pkg) -- 488
									end -- 488
									if isDownloaded then -- 488
										ImGui.SameLine() -- 491
										if ImGui.Button(deleteText) then -- 491
											Content:remove(Path(Content.writablePath, "Download", pkg.name)) -- 493
											self.downloadedPackages:delete(pkg.name) -- 494
											Director.postNode:emit("UpdateEntries") -- 495
										end -- 495
									end -- 495
								end -- 495
							end -- 495
							ImGui.SameLine() -- 502
							ImGui.Text(__TS__NumberToFixed(version.size / 1024 / 1024, 2) .. " MB") -- 503
							if not self.isDownloading and pkg.versionNames and pkg.currentVersion then -- 503
								ImGui.SameLine() -- 505
								ImGui.SetNextItemWidth(-20) -- 506
								local changed, currentVersion = ImGui.Combo("##" .. pkg.name, pkg.currentVersion, pkg.versionNames) -- 507
								if changed then -- 507
									pkg.currentVersion = currentVersion -- 509
								end -- 509
							end -- 509
							thinSep() -- 513
							ImGui.NextColumn() -- 514
						end -- 514
						::__continue83:: -- 514
					end -- 514
					ImGui.Columns(1, false) -- 517
					ImGui.ScrollWhenDraggingOnVoid() -- 518
					if self.popupShow then -- 518
						self.popupShow = false -- 521
						ImGui.OpenPopup("MessagePopup") -- 522
					end -- 522
					ImGui.BeginPopupModal( -- 524
						"MessagePopup", -- 524
						function() return self:messagePopup() end -- 524
					) -- 524
				end -- 399
			) end -- 399
		) end -- 399
	) -- 399
end -- 332
__TS__New(ResourceDownloader) -- 529
return ____exports -- 529