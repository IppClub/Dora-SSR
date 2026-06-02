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
local windowsNoScrollFlags = { -- 65
	"NoMove", -- 66
	"NoCollapse", -- 67
	"NoResize", -- 68
	"NoDecoration", -- 69
	"NoNav", -- 70
	"NoSavedSettings", -- 71
	"NoFocusOnAppearing", -- 72
	"NoBringToFrontOnFocus" -- 73
} -- 73
local windowsFlags = { -- 76
	"NoMove", -- 77
	"NoCollapse", -- 78
	"NoResize", -- 79
	"NoDecoration", -- 80
	"NoNav", -- 81
	"NoSavedSettings", -- 82
	"AlwaysVerticalScrollbar", -- 83
	"NoFocusOnAppearing", -- 84
	"NoBringToFrontOnFocus" -- 85
} -- 85
local tabBarFlags = {"FittingPolicyScroll", "DrawSelectedOverline", "NoCloseWithMiddleMouseButton", "TabListPopupButton"} -- 88
local themeColor = App.themeColor -- 95
local function sep() -- 97
	return ImGui.SeparatorText("") -- 97
end -- 97
local function thinSep() -- 98
	return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 98
end -- 98
local function run(fileName) -- 100
	local moduleName = "Script.Dev.Entry" -- 101
	local Entry = require(moduleName) -- 102
	Entry.allClear() -- 103
	thread(function() -- 104
		Entry.enterEntryAsync({entryName = "Project", fileName = fileName}) -- 105
	end) -- 104
end -- 100
local ResourceDownloader = __TS__Class() -- 109
ResourceDownloader.name = "ResourceDownloader" -- 109
function ResourceDownloader.prototype.____constructor(self) -- 129
	self.packages = {} -- 110
	self.repos = __TS__New(Map) -- 111
	self.downloadProgress = __TS__New(Map) -- 112
	self.downloadTasks = __TS__New(Map) -- 113
	self.popupMessageTitle = "" -- 114
	self.popupMessage = "" -- 115
	self.popupShow = false -- 116
	self.cancelDownload = false -- 117
	self.isDownloading = false -- 118
	self.previewTextures = __TS__New(Map) -- 120
	self.previewFiles = __TS__New(Map) -- 121
	self.downloadedPackages = __TS__New(Set) -- 122
	self.isLoading = false -- 123
	self.filterBuf = Buffer(20) -- 124
	self.filterText = "" -- 125
	self.categories = {} -- 126
	self.headerHeight = 80 -- 127
	self.node = Node() -- 130
	self.node:schedule(function() -- 131
		self:update() -- 132
		return false -- 133
	end) -- 131
	self.node:onCleanup(function() -- 135
		self.cancelDownload = true -- 136
	end) -- 135
	self:loadData() -- 138
end -- 129
function ResourceDownloader.prototype.showPopup(self, title, msg) -- 141
	self.popupMessageTitle = title -- 142
	self.popupMessage = msg -- 143
	self.popupShow = true -- 144
end -- 141
function ResourceDownloader.prototype.loadData(self) -- 147
	if self.isLoading then -- 147
		return -- 148
	end -- 148
	self.isLoading = true -- 149
	thread(function() -- 150
		local reload = false -- 151
		local versionResponse = HttpClient:getAsync(config.url .. "/api/v1/package-list-version") -- 152
		local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 153
		if versionResponse then -- 153
			local version = json.decode(versionResponse) -- 155
			local packageListVersion = version -- 156
			if Content:exist(packageListVersionFile) then -- 156
				local oldVersion = json.decode(Content:load(packageListVersionFile)) -- 158
				local oldPackageListVersion = oldVersion -- 159
				if packageListVersion.version ~= oldPackageListVersion.version then -- 159
					reload = true -- 161
				end -- 161
			else -- 161
				reload = true -- 164
			end -- 164
		end -- 164
		if reload then -- 164
			self.categories = {} -- 168
			self.packages = {} -- 169
			self.repos = __TS__New(Map) -- 170
			self.previewTextures:clear() -- 171
			self.previewFiles:clear() -- 172
			local cachePath = Path(Content.appPath, ".cache", "preview") -- 173
			Content:remove(cachePath) -- 174
		end -- 174
		local cachePath = Path(Content.appPath, ".cache", "preview") -- 177
		Content:mkdir(cachePath) -- 178
		if reload and versionResponse then -- 178
			Content:save(packageListVersionFile, versionResponse) -- 180
		end -- 180
		local packagesFile = Path(cachePath, "packages.json") -- 182
		if Content:exist(packagesFile) then -- 182
			local packages = json.decode(Content:load(packagesFile)) -- 184
			self.packages = packages -- 185
		else -- 185
			local packagesResponse = HttpClient:getAsync(config.url .. "/api/v1/packages") -- 187
			if packagesResponse then -- 187
				local packages = json.decode(packagesResponse) -- 190
				self.packages = packages -- 191
				Content:save(packagesFile, packagesResponse) -- 192
			end -- 192
		end -- 192
		for ____, pkg in ipairs(self.packages) do -- 195
			pkg.currentVersion = 1 -- 196
			pkg.versionNames = __TS__ArrayMap( -- 197
				pkg.versions, -- 197
				function(____, v) -- 197
					return v.tag == "" and "No Tag" or v.tag -- 198
				end -- 197
			) -- 197
		end -- 197
		local catSet = __TS__New(Set) -- 203
		local function loadRepos(repos) -- 204
			for ____, repo in ipairs(repos) do -- 205
				self.repos:set(repo.name, repo) -- 206
				if repo.categories then -- 206
					for ____, cat in ipairs(repo.categories) do -- 208
						catSet:add(cat) -- 209
					end -- 209
				end -- 209
			end -- 209
		end -- 204
		local reposFile = Path(cachePath, "repos.json") -- 214
		if Content:exist(reposFile) then -- 214
			local repos = json.decode(Content:load(reposFile)) -- 216
			loadRepos(repos) -- 217
		else -- 217
			local reposResponse = HttpClient:getAsync(config.url .. "/assets/repos.json") -- 219
			if reposResponse then -- 219
				local repos = json.decode(reposResponse) -- 221
				loadRepos(repos) -- 222
				Content:save(reposFile, reposResponse) -- 223
			end -- 223
		end -- 223
		for ____, cat in __TS__Iterator(catSet) do -- 226
			local ____self_categories_0 = self.categories -- 226
			____self_categories_0[#____self_categories_0 + 1] = cat -- 227
		end -- 227
		for ____, pkg in ipairs(self.packages) do -- 231
			local downloadPath = Path(Content.writablePath, "Download", pkg.name) -- 232
			if Content:exist(downloadPath) then -- 232
				self.downloadedPackages:add(pkg.name) -- 234
			end -- 234
		end -- 234
		for ____, pkg in ipairs(self.packages) do -- 237
			self:loadPreviewImage(pkg.name) -- 238
		end -- 238
		self.isLoading = false -- 240
	end) -- 150
end -- 147
function ResourceDownloader.prototype.loadPreviewImage(self, name) -- 244
	local cachePath = Path(Content.appPath, ".cache", "preview") -- 245
	local cacheFile = Path(cachePath, name .. ".jpg") -- 246
	if Content:exist(cacheFile) then -- 246
		Cache:loadAsync(cacheFile) -- 248
		local texture = Texture2D(cacheFile) -- 249
		if texture then -- 249
			self.previewTextures:set(name, texture) -- 251
			self.previewFiles:set(name, cacheFile) -- 252
		end -- 252
		return -- 254
	end -- 254
	local imageUrl = ((config.url .. "/assets/") .. name) .. "/banner.jpg" -- 256
	local response = HttpClient:downloadAsync(imageUrl, cacheFile, 10) -- 257
	if response then -- 257
		Cache:loadAsync(cacheFile) -- 259
		local texture = Texture2D(cacheFile) -- 260
		if texture then -- 260
			self.previewTextures:set(name, texture) -- 262
			self.previewFiles:set(name, cacheFile) -- 263
		end -- 263
	else -- 263
		print("Failed to load preview image for " .. name) -- 266
	end -- 266
end -- 244
function ResourceDownloader.prototype.isDownloaded(self, name) -- 270
	return self.downloadedPackages:has(name) -- 271
end -- 270
function ResourceDownloader.prototype.downloadPackage(self, pkg) -- 274
	if self.downloadTasks:has(pkg.name) then -- 274
		return -- 276
	end -- 276
	local task = thread(function() -- 279
		self.isDownloading = true -- 280
		local downloadStatus = (zh and "正在下载：" or "Downloading: ") .. pkg.name -- 281
		local downloadPath = Path(Content.writablePath, ".download") -- 282
		Content:mkdir(downloadPath) -- 283
		local currentVersion = pkg.currentVersion or 1 -- 284
		local version = pkg.versions[currentVersion] -- 285
		local targetFile = Path(downloadPath, version.file) -- 286
		local success = HttpClient:downloadAsync( -- 288
			version.download, -- 289
			targetFile, -- 290
			1200, -- 291
			function(current, total) -- 292
				if self.cancelDownload then -- 292
					return true -- 294
				end -- 294
				self.downloadProgress:set(pkg.name, {progress = current / total, status = downloadStatus}) -- 296
				return false -- 297
			end -- 292
		) -- 292
		if success then -- 292
			downloadStatus = zh and "解压中：" .. pkg.name or "Unziping: " .. pkg.name -- 302
			self.downloadProgress:set(pkg.name, {progress = 1, status = downloadStatus}) -- 303
			local unzipPath = Path(Content.writablePath, "Download", pkg.name) -- 304
			Content:remove(unzipPath) -- 305
			if Content:unzipAsync(targetFile, unzipPath) then -- 305
				Content:remove(targetFile) -- 307
				self.downloadedPackages:add(pkg.name) -- 308
				local repo = self.repos:get(pkg.name) -- 309
				if repo then -- 309
					local str = json.encode(repo) -- 311
					if str then -- 311
						if Content:mkdir(Path(unzipPath, ".dora")) then -- 311
							Content:save( -- 314
								Path(unzipPath, ".dora", "repo.json"), -- 314
								str -- 314
							) -- 314
							local previewFile = self.previewFiles:get(pkg.name) -- 315
							if previewFile and Content:exist(previewFile) then -- 315
								Content:copy( -- 317
									previewFile, -- 317
									Path(unzipPath, ".dora", "banner.jpg") -- 317
								) -- 317
							end -- 317
						end -- 317
					end -- 317
				end -- 317
				Director.postNode:emit("UpdateEntries") -- 322
			else -- 322
				Content:remove(unzipPath) -- 324
				self:showPopup(zh and "解压失败" or "Failed to unzip", zh and "无法解压文件：" .. version.file or "Failed to unzip: " .. version.file) -- 325
			end -- 325
		else -- 325
			Content:remove(targetFile) -- 331
			self:showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. version.download or "Failed to download from: " .. version.download) -- 332
		end -- 332
		self.isDownloading = false -- 338
		self.downloadProgress:delete(pkg.name) -- 339
		self.downloadTasks:delete(pkg.name) -- 340
	end) -- 279
	self.downloadTasks:set(pkg.name, task) -- 343
end -- 274
function ResourceDownloader.prototype.messagePopup(self) -- 346
	ImGui.Text(self.popupMessageTitle) -- 347
	ImGui.Separator() -- 348
	ImGui.PushTextWrapPos( -- 349
		300, -- 349
		function() -- 349
			ImGui.TextWrapped(self.popupMessage) -- 350
		end -- 349
	) -- 349
	if ImGui.Button( -- 349
		zh and "确认" or "OK", -- 352
		Vec2(300, 30) -- 352
	) then -- 352
		ImGui.CloseCurrentPopup() -- 353
	end -- 353
end -- 346
function ResourceDownloader.prototype.update(self) -- 357
	local ____App_visualSize_1 = App.visualSize -- 358
	local width = ____App_visualSize_1.width -- 358
	local height = ____App_visualSize_1.height -- 358
	local filterCategory = nil -- 359
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 360
	ImGui.SetNextWindowSize( -- 361
		Vec2(width, self.headerHeight), -- 361
		"Always" -- 361
	) -- 361
	ImGui.PushStyleVar( -- 362
		"WindowPadding", -- 362
		Vec2(10, 0), -- 362
		function() return ImGui.Begin( -- 362
			"Dora Community Header", -- 362
			windowsNoScrollFlags, -- 362
			function() -- 362
				ImGui.Dummy(Vec2(0, 0)) -- 363
				ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Resources") -- 364
				ImGui.SameLine() -- 365
				ImGui.TextDisabled("(?)") -- 366
				if ImGui.IsItemHovered() then -- 366
					ImGui.BeginTooltip(function() -- 368
						ImGui.PushTextWrapPos( -- 369
							300, -- 369
							function() -- 369
								ImGui.Text(zh and "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" or "Use this tool to download Dora SSR community resources to the `Download` directory.") -- 370
							end -- 369
						) -- 369
					end) -- 368
				end -- 368
				local padding = zh and 400 or 440 -- 374
				if width >= padding then -- 374
					ImGui.SameLine() -- 376
					ImGui.Dummy(Vec2(width - padding, 0)) -- 377
					ImGui.SameLine() -- 378
					ImGui.SetNextItemWidth((zh and -40 or -55) - 40) -- 379
					if ImGui.InputText(zh and "筛选" or "Filter", self.filterBuf, {"AutoSelectAll"}) then -- 379
						local res = string.match(self.filterBuf.text, "[^%%%.%[]+") -- 381
						self.filterText = string.lower(res or "") -- 382
					end -- 382
				else -- 382
					ImGui.SameLine() -- 385
					ImGui.Dummy(Vec2(width - (zh and 250 or 255), 0)) -- 386
				end -- 386
				ImGui.SameLine() -- 388
				if ImGui.CollapsingHeader("##option") then -- 388
					self.headerHeight = 130 -- 390
					ImGui.SetNextItemWidth(zh and -200 or -230) -- 391
					if ImGui.InputText(zh and "服务器" or "Server", url) then -- 391
						if url.text == "" then -- 391
							url.text = DefaultURL -- 394
						end -- 394
						config.url = url.text -- 396
					end -- 396
					ImGui.SameLine() -- 398
					if ImGui.Button(zh and "刷新" or "Reload") then -- 398
						local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 400
						Content:remove(packageListVersionFile) -- 401
						self:loadData() -- 402
					end -- 402
					ImGui.Separator() -- 404
				else -- 404
					self.headerHeight = 80 -- 406
				end -- 406
				ImGui.PushStyleVar( -- 408
					"WindowPadding", -- 408
					Vec2(10, 10), -- 408
					function() return ImGui.BeginTabBar( -- 408
						"categories", -- 408
						tabBarFlags, -- 408
						function() -- 408
							ImGui.BeginTabItem( -- 409
								zh and "全部" or "All", -- 409
								function() -- 409
									filterCategory = nil -- 410
								end -- 409
							) -- 409
							for ____, cat in ipairs(self.categories) do -- 412
								ImGui.BeginTabItem( -- 413
									cat, -- 413
									function() -- 413
										filterCategory = cat -- 414
									end -- 413
								) -- 413
							end -- 413
						end -- 408
					) end -- 408
				) -- 408
			end -- 362
		) end -- 362
	) -- 362
	local function matchCat(self, cat) -- 419
		return filterCategory == cat -- 419
	end -- 419
	local maxColumns = math.max( -- 420
		math.floor(width / 320), -- 420
		1 -- 420
	) -- 420
	local itemWidth = (width - 60) / maxColumns - 10 -- 421
	ImGui.SetNextWindowPos( -- 422
		Vec2(0, self.headerHeight), -- 422
		"Always", -- 422
		Vec2.zero -- 422
	) -- 422
	ImGui.SetNextWindowSize( -- 423
		Vec2(width, height - self.headerHeight - 50), -- 423
		"Always" -- 423
	) -- 423
	ImGui.PushStyleVar( -- 424
		"Alpha", -- 424
		1, -- 424
		function() return ImGui.PushStyleVar( -- 424
			"WindowPadding", -- 424
			Vec2(20, 10), -- 424
			function() return ImGui.Begin( -- 424
				"Dora Community Resources", -- 424
				windowsFlags, -- 424
				function() -- 424
					ImGui.Columns(maxColumns, false) -- 425
					for ____, pkg in ipairs(self.packages) do -- 428
						do -- 428
							local repo = self.repos:get(pkg.name) -- 429
							if not repo then -- 429
								goto __continue91 -- 430
							end -- 430
							if filterCategory ~= nil then -- 430
								if not repo.categories then -- 430
									goto __continue91 -- 432
								end -- 432
								if __TS__ArrayFind(repo.categories, matchCat) == nil then -- 432
									goto __continue91 -- 434
								end -- 434
							end -- 434
							local title = repo.title[zh and "zh" or "en"] -- 438
							if self.filterText ~= "" then -- 438
								local res = string.match( -- 441
									string.lower(title), -- 441
									self.filterText -- 441
								) -- 441
								if not res then -- 441
									goto __continue91 -- 442
								end -- 442
							end -- 442
							ImGui.TextColored(themeColor, title) -- 446
							local previewTexture = self.previewTextures:get(pkg.name) -- 449
							if previewTexture then -- 449
								local width = previewTexture.width -- 449
								local height = previewTexture.height -- 449
								local scale = (itemWidth - 30) / width -- 453
								local scaledSize = Vec2(width * scale, height * scale) -- 454
								local previewFile = self.previewFiles:get(pkg.name) -- 455
								if previewFile then -- 455
									ImGui.Dummy(Vec2.zero) -- 457
									ImGui.SameLine() -- 458
									ImGui.Image(previewFile, scaledSize) -- 459
								end -- 459
							else -- 459
								ImGui.Text(zh and "加载预览图中..." or "Loading preview...") -- 462
							end -- 462
							ImGui.TextWrapped(repo.desc[zh and "zh" or "en"]) -- 465
							ImGui.TextColored(themeColor, zh and "项目地址：" or "Repo URL:") -- 467
							ImGui.SameLine() -- 468
							if ImGui.TextLink((zh and "这里" or "here") .. "##" .. pkg.url) then -- 468
								App:openURL(pkg.url) -- 470
							end -- 470
							if ImGui.IsItemHovered() then -- 470
								ImGui.BeginTooltip(function() -- 473
									ImGui.PushTextWrapPos( -- 474
										300, -- 474
										function() -- 474
											ImGui.Text(pkg.url) -- 475
										end -- 474
									) -- 474
								end) -- 473
							end -- 473
							local currentVersion = pkg.currentVersion or 1 -- 480
							local version = pkg.versions[currentVersion] -- 481
							if type(version.updatedAt) == "number" then -- 481
								ImGui.TextColored(themeColor, zh and "同步时间：" or "Updated:") -- 483
								ImGui.SameLine() -- 484
								local dateStr = os.date("%Y-%m-%d %H:%M:%S", version.updatedAt) -- 485
								ImGui.Text(dateStr) -- 486
							end -- 486
							ImGui.TextColored(themeColor, zh and "文件大小：" or "File Size:") -- 490
							ImGui.SameLine() -- 491
							ImGui.Text(__TS__NumberToFixed(version.size / 1024 / 1024, 2) .. " MB") -- 492
							local progress = self.downloadProgress:get(pkg.name) -- 495
							if progress ~= nil then -- 495
								ImGui.ProgressBar( -- 497
									progress.progress, -- 497
									Vec2(-1, 30) -- 497
								) -- 497
								ImGui.BeginDisabled(function() -- 498
									ImGui.Button(progress.status) -- 499
								end) -- 498
							end -- 498
							if progress == nil then -- 498
								local isDownloaded = self:isDownloaded(pkg.name) -- 505
								local exeText = (zh and "测试" or "Test") .. "##test-" .. pkg.name -- 506
								local buttonText = (isDownloaded and (zh and "重新下载" or "Re-Download") or (zh and "下载" or "Download")) .. "##download-" .. pkg.name -- 507
								local deleteText = (zh and "删除" or "Delete") .. "##delete-" .. pkg.name -- 510
								local runable = repo.exe ~= false -- 511
								if self.isDownloading then -- 511
									ImGui.BeginDisabled(function() -- 513
										if runable then -- 513
											ImGui.Button(exeText) -- 515
											ImGui.SameLine() -- 516
										end -- 516
										ImGui.Button(buttonText) -- 518
										if isDownloaded then -- 518
											ImGui.SameLine() -- 520
											ImGui.Button(deleteText) -- 521
										end -- 521
									end) -- 513
								else -- 513
									if isDownloaded and runable then -- 513
										if type(repo.exe) == "table" then -- 513
											local exeList = repo.exe -- 527
											local popupId = "select-" .. pkg.name -- 528
											if ImGui.Button(exeText) then -- 528
												ImGui.OpenPopup(popupId) -- 530
											end -- 530
											ImGui.BeginPopup( -- 532
												popupId, -- 532
												function() -- 532
													for ____, entry in ipairs(exeList) do -- 533
														if ImGui.Selectable((((entry .. "##run-") .. pkg.name) .. "-") .. entry) then -- 533
															run(Path( -- 535
																Content.writablePath, -- 535
																"Download", -- 535
																pkg.name, -- 535
																entry, -- 535
																"init" -- 535
															)) -- 535
														end -- 535
													end -- 535
												end -- 532
											) -- 532
										else -- 532
											if ImGui.Button(exeText) then -- 532
												run(Path(Content.writablePath, "Download", pkg.name, "init")) -- 541
											end -- 541
										end -- 541
										ImGui.SameLine() -- 544
									end -- 544
									if ImGui.Button(buttonText) then -- 544
										self:downloadPackage(pkg) -- 547
									end -- 547
									if isDownloaded then -- 547
										ImGui.SameLine() -- 550
										if ImGui.Button(deleteText) then -- 550
											Content:remove(Path(Content.writablePath, "Download", pkg.name)) -- 552
											self.downloadedPackages:delete(pkg.name) -- 553
											Director.postNode:emit("UpdateEntries") -- 554
										end -- 554
									end -- 554
								end -- 554
							end -- 554
							if not self.isDownloading and pkg.versionNames and pkg.currentVersion then -- 554
								ImGui.SameLine() -- 561
								ImGui.SetNextItemWidth(-20) -- 562
								local changed, currentVersion = ImGui.Combo("##" .. pkg.name, pkg.currentVersion, pkg.versionNames) -- 563
								if changed then -- 563
									pkg.currentVersion = currentVersion -- 565
								end -- 565
							end -- 565
							thinSep() -- 569
							ImGui.NextColumn() -- 570
						end -- 570
						::__continue91:: -- 570
					end -- 570
					ImGui.Columns(1, false) -- 573
					ImGui.ScrollWhenDraggingOnVoid() -- 574
					if self.popupShow then -- 574
						self.popupShow = false -- 577
						ImGui.OpenPopup("MessagePopup") -- 578
					end -- 578
					ImGui.BeginPopupModal( -- 580
						"MessagePopup", -- 580
						function() return self:messagePopup() end -- 580
					) -- 580
				end -- 424
			) end -- 424
		) end -- 424
	) -- 424
end -- 357
__TS__New(ResourceDownloader) -- 585
return ____exports -- 585