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
			local version = json.decode(versionResponse) -- 145
			local packageListVersion = version -- 146
			if Content:exist(packageListVersionFile) then -- 146
				local oldVersion = json.decode(Content:load(packageListVersionFile)) -- 148
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
			local packages = json.decode(Content:load(packagesFile)) -- 174
			self.packages = packages -- 175
		else -- 175
			local packagesResponse = HttpClient:getAsync(config.url .. "/api/v1/packages") -- 177
			if packagesResponse then -- 177
				local packages = json.decode(packagesResponse) -- 180
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
			local repos = json.decode(Content:load(reposFile)) -- 206
			loadRepos(repos) -- 207
		else -- 207
			local reposResponse = HttpClient:getAsync(config.url .. "/assets/repos.json") -- 209
			if reposResponse then -- 209
				local repos = json.decode(reposResponse) -- 211
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
				local repo = self.repos:get(pkg.name) -- 297
				if repo then -- 297
					local str = json.encode(repo) -- 299
					if str then -- 299
						Content:save( -- 301
							Path(unzipPath, "repo.json"), -- 301
							str -- 301
						) -- 301
					end -- 301
				end -- 301
				Director.postNode:emit("UpdateEntries") -- 304
			else -- 304
				Content:remove(unzipPath) -- 306
				self:showPopup(zh and "解压失败" or "Failed to unzip", zh and "无法解压文件：" .. version.file or "Failed to unzip: " .. version.file) -- 307
			end -- 307
		else -- 307
			Content:remove(targetFile) -- 313
			self:showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. version.download or "Failed to download from: " .. version.download) -- 314
		end -- 314
		self.isDownloading = false -- 320
		self.downloadProgress:delete(pkg.name) -- 321
		self.downloadTasks:delete(pkg.name) -- 322
	end) -- 267
	self.downloadTasks:set(pkg.name, task) -- 325
end -- 262
function ResourceDownloader.prototype.messagePopup(self) -- 328
	ImGui.Text(self.popupMessageTitle) -- 329
	ImGui.Separator() -- 330
	ImGui.PushTextWrapPos( -- 331
		300, -- 331
		function() -- 331
			ImGui.TextWrapped(self.popupMessage) -- 332
		end -- 331
	) -- 331
	if ImGui.Button( -- 331
		zh and "确认" or "OK", -- 334
		Vec2(300, 30) -- 334
	) then -- 334
		ImGui.CloseCurrentPopup() -- 335
	end -- 335
end -- 328
function ResourceDownloader.prototype.update(self) -- 339
	local ____App_visualSize_1 = App.visualSize -- 340
	local width = ____App_visualSize_1.width -- 340
	local height = ____App_visualSize_1.height -- 340
	local filterCategory = nil -- 341
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 342
	ImGui.SetNextWindowSize( -- 343
		Vec2(width, self.headerHeight), -- 343
		"Always" -- 343
	) -- 343
	ImGui.PushStyleVar( -- 344
		"WindowPadding", -- 344
		Vec2(10, 0), -- 344
		function() return ImGui.Begin( -- 344
			"Dora Community Header", -- 344
			windowsNoScrollFlags, -- 344
			function() -- 344
				ImGui.Dummy(Vec2(0, 0)) -- 345
				ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Resources") -- 346
				ImGui.SameLine() -- 347
				ImGui.TextDisabled("(?)") -- 348
				if ImGui.IsItemHovered() then -- 348
					ImGui.BeginTooltip(function() -- 350
						ImGui.PushTextWrapPos( -- 351
							300, -- 351
							function() -- 351
								ImGui.Text(zh and "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" or "Use this tool to download Dora SSR community resources to the `Download` directory.") -- 352
							end -- 351
						) -- 351
					end) -- 350
				end -- 350
				local padding = zh and 400 or 440 -- 356
				if width >= padding then -- 356
					ImGui.SameLine() -- 358
					ImGui.Dummy(Vec2(width - padding, 0)) -- 359
					ImGui.SameLine() -- 360
					ImGui.SetNextItemWidth((zh and -40 or -55) - 40) -- 361
					if ImGui.InputText(zh and "筛选" or "Filter", self.filterBuf, {"AutoSelectAll"}) then -- 361
						local res = string.match(self.filterBuf.text, "[^%%%.%[]+") -- 363
						self.filterText = string.lower(res or "") -- 364
					end -- 364
				else -- 364
					ImGui.SameLine() -- 367
					ImGui.Dummy(Vec2(width - (zh and 250 or 255), 0)) -- 368
				end -- 368
				ImGui.SameLine() -- 370
				if ImGui.CollapsingHeader("##option") then -- 370
					self.headerHeight = 130 -- 372
					ImGui.SetNextItemWidth(zh and -200 or -230) -- 373
					if ImGui.InputText(zh and "服务器" or "Server", url) then -- 373
						if url.text == "" then -- 373
							url.text = DefaultURL -- 376
						end -- 376
						config.url = url.text -- 378
					end -- 378
					ImGui.SameLine() -- 380
					if ImGui.Button(zh and "刷新" or "Reload") then -- 380
						local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 382
						Content:remove(packageListVersionFile) -- 383
						self:loadData() -- 384
					end -- 384
					ImGui.Separator() -- 386
				else -- 386
					self.headerHeight = 80 -- 388
				end -- 388
				ImGui.PushStyleVar( -- 390
					"WindowPadding", -- 390
					Vec2(10, 10), -- 390
					function() return ImGui.BeginTabBar( -- 390
						"categories", -- 390
						tabBarFlags, -- 390
						function() -- 390
							ImGui.BeginTabItem( -- 391
								zh and "全部" or "All", -- 391
								function() -- 391
									filterCategory = nil -- 392
								end -- 391
							) -- 391
							for ____, cat in ipairs(self.categories) do -- 394
								ImGui.BeginTabItem( -- 395
									cat, -- 395
									function() -- 395
										filterCategory = cat -- 396
									end -- 395
								) -- 395
							end -- 395
						end -- 390
					) end -- 390
				) -- 390
			end -- 344
		) end -- 344
	) -- 344
	local function matchCat(self, cat) -- 401
		return filterCategory == cat -- 401
	end -- 401
	local maxColumns = math.max( -- 402
		math.floor(width / 320), -- 402
		1 -- 402
	) -- 402
	local itemWidth = (width - 60) / maxColumns - 10 -- 403
	ImGui.SetNextWindowPos( -- 404
		Vec2(0, self.headerHeight), -- 404
		"Always", -- 404
		Vec2.zero -- 404
	) -- 404
	ImGui.SetNextWindowSize( -- 405
		Vec2(width, height - self.headerHeight - 50), -- 405
		"Always" -- 405
	) -- 405
	ImGui.PushStyleVar( -- 406
		"Alpha", -- 406
		1, -- 406
		function() return ImGui.PushStyleVar( -- 406
			"WindowPadding", -- 406
			Vec2(20, 10), -- 406
			function() return ImGui.Begin( -- 406
				"Dora Community Resources", -- 406
				windowsFlags, -- 406
				function() -- 406
					ImGui.Columns(maxColumns, false) -- 407
					for ____, pkg in ipairs(self.packages) do -- 410
						do -- 410
							local repo = self.repos:get(pkg.name) -- 411
							if not repo then -- 411
								goto __continue85 -- 412
							end -- 412
							if filterCategory ~= nil then -- 412
								if not repo.categories then -- 412
									goto __continue85 -- 414
								end -- 414
								if __TS__ArrayFind(repo.categories, matchCat) == nil then -- 414
									goto __continue85 -- 416
								end -- 416
							end -- 416
							local title = repo.title[zh and "zh" or "en"] -- 420
							if self.filterText ~= "" then -- 420
								local res = string.match( -- 423
									string.lower(title), -- 423
									self.filterText -- 423
								) -- 423
								if not res then -- 423
									goto __continue85 -- 424
								end -- 424
							end -- 424
							ImGui.TextColored(themeColor, title) -- 428
							local previewTexture = self.previewTextures:get(pkg.name) -- 431
							if previewTexture then -- 431
								local width = previewTexture.width -- 431
								local height = previewTexture.height -- 431
								local scale = (itemWidth - 30) / width -- 435
								local scaledSize = Vec2(width * scale, height * scale) -- 436
								local previewFile = self.previewFiles:get(pkg.name) -- 437
								if previewFile then -- 437
									ImGui.Dummy(Vec2.zero) -- 439
									ImGui.SameLine() -- 440
									ImGui.Image(previewFile, scaledSize) -- 441
								end -- 441
							else -- 441
								ImGui.Text(zh and "加载预览图中..." or "Loading preview...") -- 444
							end -- 444
							ImGui.TextWrapped(repo.desc[zh and "zh" or "en"]) -- 447
							ImGui.TextColored(themeColor, zh and "项目地址：" or "Repo URL:") -- 449
							ImGui.SameLine() -- 450
							if ImGui.TextLink((zh and "这里" or "here") .. "##" .. pkg.url) then -- 450
								App:openURL(pkg.url) -- 452
							end -- 452
							if ImGui.IsItemHovered() then -- 452
								ImGui.BeginTooltip(function() -- 455
									ImGui.PushTextWrapPos( -- 456
										300, -- 456
										function() -- 456
											ImGui.Text(pkg.url) -- 457
										end -- 456
									) -- 456
								end) -- 455
							end -- 455
							local currentVersion = pkg.currentVersion or 1 -- 462
							local version = pkg.versions[currentVersion] -- 463
							if type(version.updatedAt) == "number" then -- 463
								ImGui.TextColored(themeColor, zh and "同步时间：" or "Updated:") -- 465
								ImGui.SameLine() -- 466
								local dateStr = os.date("%Y-%m-%d %H:%M:%S", version.updatedAt) -- 467
								ImGui.Text(dateStr) -- 468
							end -- 468
							local progress = self.downloadProgress:get(pkg.name) -- 472
							if progress ~= nil then -- 472
								ImGui.ProgressBar( -- 474
									progress.progress, -- 474
									Vec2(-1, 30) -- 474
								) -- 474
								ImGui.BeginDisabled(function() -- 475
									ImGui.Button(progress.status) -- 476
								end) -- 475
							end -- 475
							if progress == nil then -- 475
								local isDownloaded = self:isDownloaded(pkg.name) -- 482
								local buttonText = (isDownloaded and (zh and "重新下载" or "Re-Download") or (zh and "下载" or "Download")) .. "##download-" .. pkg.name -- 483
								local deleteText = (zh and "删除" or "Delete") .. "##delete-" .. pkg.name -- 486
								if self.isDownloading then -- 486
									ImGui.BeginDisabled(function() -- 488
										ImGui.Button(buttonText) -- 489
										if isDownloaded then -- 489
											ImGui.SameLine() -- 491
											ImGui.Button(deleteText) -- 492
										end -- 492
									end) -- 488
								else -- 488
									if ImGui.Button(buttonText) then -- 488
										self:downloadPackage(pkg) -- 497
									end -- 497
									if isDownloaded then -- 497
										ImGui.SameLine() -- 500
										if ImGui.Button(deleteText) then -- 500
											Content:remove(Path(Content.writablePath, "Download", pkg.name)) -- 502
											self.downloadedPackages:delete(pkg.name) -- 503
											Director.postNode:emit("UpdateEntries") -- 504
										end -- 504
									end -- 504
								end -- 504
							end -- 504
							ImGui.SameLine() -- 511
							ImGui.Text(__TS__NumberToFixed(version.size / 1024 / 1024, 2) .. " MB") -- 512
							if not self.isDownloading and pkg.versionNames and pkg.currentVersion then -- 512
								ImGui.SameLine() -- 514
								ImGui.SetNextItemWidth(-20) -- 515
								local changed, currentVersion = ImGui.Combo("##" .. pkg.name, pkg.currentVersion, pkg.versionNames) -- 516
								if changed then -- 516
									pkg.currentVersion = currentVersion -- 518
								end -- 518
							end -- 518
							thinSep() -- 522
							ImGui.NextColumn() -- 523
						end -- 523
						::__continue85:: -- 523
					end -- 523
					ImGui.Columns(1, false) -- 526
					ImGui.ScrollWhenDraggingOnVoid() -- 527
					if self.popupShow then -- 527
						self.popupShow = false -- 530
						ImGui.OpenPopup("MessagePopup") -- 531
					end -- 531
					ImGui.BeginPopupModal( -- 533
						"MessagePopup", -- 533
						function() return self:messagePopup() end -- 533
					) -- 533
				end -- 406
			) end -- 406
		) end -- 406
	) -- 406
end -- 339
__TS__New(ResourceDownloader) -- 538
return ____exports -- 538