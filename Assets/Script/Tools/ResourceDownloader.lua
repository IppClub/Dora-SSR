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
local windowsNoScrollFlags = { -- 66
	"NoMove", -- 67
	"NoCollapse", -- 68
	"NoResize", -- 69
	"NoDecoration", -- 70
	"NoNav", -- 71
	"NoSavedSettings", -- 72
	"NoFocusOnAppearing", -- 73
	"NoBringToFrontOnFocus" -- 74
} -- 74
local windowsFlags = { -- 77
	"NoMove", -- 78
	"NoCollapse", -- 79
	"NoResize", -- 80
	"NoDecoration", -- 81
	"NoNav", -- 82
	"NoSavedSettings", -- 83
	"AlwaysVerticalScrollbar", -- 84
	"NoFocusOnAppearing", -- 85
	"NoBringToFrontOnFocus" -- 86
} -- 86
local tabBarFlags = {"FittingPolicyScroll", "DrawSelectedOverline", "NoCloseWithMiddleMouseButton", "TabListPopupButton"} -- 89
local themeColor = App.themeColor -- 96
local function sep() -- 98
	return ImGui.SeparatorText("") -- 98
end -- 98
local function thinSep() -- 99
	return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 99
end -- 99
local function run(fileName) -- 101
	local moduleName = "Script.Dev.Entry" -- 102
	local Entry = require(moduleName) -- 103
	Entry.allClear() -- 104
	thread(function() -- 105
		Entry.enterEntryAsync({entryName = "Project", fileName = fileName}) -- 106
	end) -- 105
end -- 101
local ResourceDownloader = __TS__Class() -- 110
ResourceDownloader.name = "ResourceDownloader" -- 110
function ResourceDownloader.prototype.____constructor(self) -- 130
	self.packages = {} -- 111
	self.repos = __TS__New(Map) -- 112
	self.downloadProgress = __TS__New(Map) -- 113
	self.downloadTasks = __TS__New(Map) -- 114
	self.popupMessageTitle = "" -- 115
	self.popupMessage = "" -- 116
	self.popupShow = false -- 117
	self.cancelDownload = false -- 118
	self.isDownloading = false -- 119
	self.previewTextures = __TS__New(Map) -- 121
	self.previewFiles = __TS__New(Map) -- 122
	self.downloadedPackages = __TS__New(Set) -- 123
	self.isLoading = false -- 124
	self.filterBuf = Buffer(20) -- 125
	self.filterText = "" -- 126
	self.categories = {} -- 127
	self.headerHeight = 80 -- 128
	self.node = Node() -- 131
	self.node:schedule(function() -- 132
		self:update() -- 133
		return false -- 134
	end) -- 132
	self.node:onCleanup(function() -- 136
		self.cancelDownload = true -- 137
	end) -- 136
	self:loadData() -- 139
end -- 130
function ResourceDownloader.prototype.showPopup(self, title, msg) -- 142
	self.popupMessageTitle = title -- 143
	self.popupMessage = msg -- 144
	self.popupShow = true -- 145
end -- 142
function ResourceDownloader.prototype.loadData(self) -- 148
	if self.isLoading then -- 148
		return -- 149
	end -- 149
	self.isLoading = true -- 150
	thread(function() -- 151
		local reload = false -- 152
		local versionResponse = HttpClient:getAsync(config.url .. "/api/v1/package-list-version") -- 153
		local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 154
		if versionResponse then -- 154
			local version = json.decode(versionResponse) -- 156
			local packageListVersion = version -- 157
			if Content:exist(packageListVersionFile) then -- 157
				local oldVersion = json.decode(Content:load(packageListVersionFile)) -- 159
				local oldPackageListVersion = oldVersion -- 160
				if packageListVersion.version ~= oldPackageListVersion.version then -- 160
					reload = true -- 162
				end -- 162
			else -- 162
				reload = true -- 165
			end -- 165
		end -- 165
		if reload then -- 165
			self.categories = {} -- 169
			self.packages = {} -- 170
			self.repos = __TS__New(Map) -- 171
			self.previewTextures:clear() -- 172
			self.previewFiles:clear() -- 173
			local cachePath = Path(Content.appPath, ".cache", "preview") -- 174
			Content:remove(cachePath) -- 175
		end -- 175
		local cachePath = Path(Content.appPath, ".cache", "preview") -- 178
		Content:mkdir(cachePath) -- 179
		if reload and versionResponse then -- 179
			Content:save(packageListVersionFile, versionResponse) -- 181
		end -- 181
		local packagesFile = Path(cachePath, "packages.json") -- 183
		if Content:exist(packagesFile) then -- 183
			local packages = json.decode(Content:load(packagesFile)) -- 185
			self.packages = packages -- 186
		else -- 186
			local packagesResponse = HttpClient:getAsync(config.url .. "/api/v1/packages") -- 188
			if packagesResponse then -- 188
				local packages = json.decode(packagesResponse) -- 191
				self.packages = packages -- 192
				Content:save(packagesFile, packagesResponse) -- 193
			end -- 193
		end -- 193
		for ____, pkg in ipairs(self.packages) do -- 196
			pkg.currentVersion = 1 -- 197
			pkg.versionNames = __TS__ArrayMap( -- 198
				pkg.versions, -- 198
				function(____, v) -- 198
					return v.tag == "" and "No Tag" or v.tag -- 199
				end -- 198
			) -- 198
		end -- 198
		local catSet = __TS__New(Set) -- 204
		local function loadRepos(repos) -- 205
			for ____, repo in ipairs(repos) do -- 206
				self.repos:set(repo.name, repo) -- 207
				if repo.categories then -- 207
					for ____, cat in ipairs(repo.categories) do -- 209
						catSet:add(cat) -- 210
					end -- 210
				end -- 210
			end -- 210
		end -- 205
		local reposFile = Path(cachePath, "repos.json") -- 215
		if Content:exist(reposFile) then -- 215
			local repos = json.decode(Content:load(reposFile)) -- 217
			loadRepos(repos) -- 218
		else -- 218
			local reposResponse = HttpClient:getAsync(config.url .. "/assets/repos.json") -- 220
			if reposResponse then -- 220
				local repos = json.decode(reposResponse) -- 222
				loadRepos(repos) -- 223
				Content:save(reposFile, reposResponse) -- 224
			end -- 224
		end -- 224
		for ____, cat in __TS__Iterator(catSet) do -- 227
			local ____self_categories_0 = self.categories -- 227
			____self_categories_0[#____self_categories_0 + 1] = cat -- 228
		end -- 228
		for ____, pkg in ipairs(self.packages) do -- 232
			local downloadPath = Path(Content.writablePath, "Download", pkg.name) -- 233
			if Content:exist(downloadPath) then -- 233
				self.downloadedPackages:add(pkg.name) -- 235
			end -- 235
		end -- 235
		for ____, pkg in ipairs(self.packages) do -- 238
			self:loadPreviewImage(pkg.name) -- 239
		end -- 239
		self.isLoading = false -- 241
	end) -- 151
end -- 148
function ResourceDownloader.prototype.loadPreviewImage(self, name) -- 245
	local repo = self.repos:get(name) -- 246
	if repo ~= nil and repo.noBanner then -- 246
		local cacheFile = Path(Content.assetPath, "Image", "banner.jpg") -- 248
		if Content:exist(cacheFile) then -- 248
			Cache:loadAsync(cacheFile) -- 250
			local texture = Texture2D(cacheFile) -- 251
			if texture then -- 251
				self.previewTextures:set(name, texture) -- 253
				self.previewFiles:set(name, cacheFile) -- 254
			end -- 254
			return -- 256
		end -- 256
	end -- 256
	local cachePath = Path(Content.appPath, ".cache", "preview") -- 259
	local cacheFile = Path(cachePath, name .. ".jpg") -- 260
	if Content:exist(cacheFile) then -- 260
		Cache:loadAsync(cacheFile) -- 262
		local texture = Texture2D(cacheFile) -- 263
		if texture then -- 263
			self.previewTextures:set(name, texture) -- 265
			self.previewFiles:set(name, cacheFile) -- 266
		end -- 266
		return -- 268
	end -- 268
	local imageUrl = ((config.url .. "/assets/") .. name) .. "/banner.jpg" -- 270
	local response = HttpClient:downloadAsync(imageUrl, cacheFile, 10) -- 271
	if response then -- 271
		Cache:loadAsync(cacheFile) -- 273
		local texture = Texture2D(cacheFile) -- 274
		if texture then -- 274
			self.previewTextures:set(name, texture) -- 276
			self.previewFiles:set(name, cacheFile) -- 277
		end -- 277
	else -- 277
		print("Failed to load preview image for " .. name) -- 280
	end -- 280
end -- 245
function ResourceDownloader.prototype.isDownloaded(self, name) -- 284
	return self.downloadedPackages:has(name) -- 285
end -- 284
function ResourceDownloader.prototype.downloadPackage(self, pkg) -- 288
	if self.downloadTasks:has(pkg.name) then -- 288
		return -- 290
	end -- 290
	local task = thread(function() -- 293
		self.isDownloading = true -- 294
		local downloadStatus = (zh and "正在下载：" or "Downloading: ") .. pkg.name -- 295
		local downloadPath = Path(Content.writablePath, ".download") -- 296
		Content:mkdir(downloadPath) -- 297
		local currentVersion = pkg.currentVersion or 1 -- 298
		local version = pkg.versions[currentVersion] -- 299
		local targetFile = Path(downloadPath, version.file) -- 300
		local success = HttpClient:downloadAsync( -- 302
			version.download, -- 303
			targetFile, -- 304
			1200, -- 305
			function(current, total) -- 306
				if self.cancelDownload then -- 306
					return true -- 308
				end -- 308
				self.downloadProgress:set(pkg.name, {progress = current / total, status = downloadStatus}) -- 310
				return false -- 311
			end -- 306
		) -- 306
		if success then -- 306
			downloadStatus = zh and "解压中：" .. pkg.name or "Unziping: " .. pkg.name -- 316
			self.downloadProgress:set(pkg.name, {progress = 1, status = downloadStatus}) -- 317
			local unzipPath = Path(Content.writablePath, "Download", pkg.name) -- 318
			Content:remove(unzipPath) -- 319
			if Content:unzipAsync(targetFile, unzipPath) then -- 319
				Content:remove(targetFile) -- 321
				self.downloadedPackages:add(pkg.name) -- 322
				local repo = self.repos:get(pkg.name) -- 323
				if repo then -- 323
					local str = json.encode(repo) -- 325
					if str then -- 325
						if Content:mkdir(Path(unzipPath, ".dora")) then -- 325
							Content:save( -- 328
								Path(unzipPath, ".dora", "repo.json"), -- 328
								str -- 328
							) -- 328
							local previewFile = self.previewFiles:get(pkg.name) -- 329
							if previewFile and Content:exist(previewFile) then -- 329
								Content:copy( -- 331
									previewFile, -- 331
									Path(unzipPath, ".dora", "banner.jpg") -- 331
								) -- 331
							end -- 331
						end -- 331
					end -- 331
				end -- 331
				Director.postNode:emit("UpdateEntries") -- 336
			else -- 336
				Content:remove(unzipPath) -- 338
				self:showPopup(zh and "解压失败" or "Failed to unzip", zh and "无法解压文件：" .. version.file or "Failed to unzip: " .. version.file) -- 339
			end -- 339
		else -- 339
			Content:remove(targetFile) -- 345
			self:showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. version.download or "Failed to download from: " .. version.download) -- 346
		end -- 346
		self.isDownloading = false -- 352
		self.downloadProgress:delete(pkg.name) -- 353
		self.downloadTasks:delete(pkg.name) -- 354
	end) -- 293
	self.downloadTasks:set(pkg.name, task) -- 357
end -- 288
function ResourceDownloader.prototype.messagePopup(self) -- 360
	ImGui.Text(self.popupMessageTitle) -- 361
	ImGui.Separator() -- 362
	ImGui.PushTextWrapPos( -- 363
		300, -- 363
		function() -- 363
			ImGui.TextWrapped(self.popupMessage) -- 364
		end -- 363
	) -- 363
	if ImGui.Button( -- 363
		zh and "确认" or "OK", -- 366
		Vec2(300, 30) -- 366
	) then -- 366
		ImGui.CloseCurrentPopup() -- 367
	end -- 367
end -- 360
function ResourceDownloader.prototype.update(self) -- 371
	local ____App_visualSize_1 = App.visualSize -- 372
	local width = ____App_visualSize_1.width -- 372
	local height = ____App_visualSize_1.height -- 372
	local filterCategory = nil -- 373
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 374
	ImGui.SetNextWindowSize( -- 375
		Vec2(width, self.headerHeight), -- 375
		"Always" -- 375
	) -- 375
	ImGui.PushStyleVar( -- 376
		"WindowPadding", -- 376
		Vec2(10, 0), -- 376
		function() return ImGui.Begin( -- 376
			"Dora Community Header", -- 376
			windowsNoScrollFlags, -- 376
			function() -- 376
				ImGui.Dummy(Vec2(0, 0)) -- 377
				ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Resources") -- 378
				ImGui.SameLine() -- 379
				ImGui.TextDisabled("(?)") -- 380
				if ImGui.IsItemHovered() then -- 380
					ImGui.BeginTooltip(function() -- 382
						ImGui.PushTextWrapPos( -- 383
							300, -- 383
							function() -- 383
								ImGui.Text(zh and "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" or "Use this tool to download Dora SSR community resources to the `Download` directory.") -- 384
							end -- 383
						) -- 383
					end) -- 382
				end -- 382
				local padding = zh and 400 or 440 -- 388
				if width >= padding then -- 388
					ImGui.SameLine() -- 390
					ImGui.Dummy(Vec2(width - padding, 0)) -- 391
					ImGui.SameLine() -- 392
					ImGui.SetNextItemWidth((zh and -40 or -55) - 40) -- 393
					if ImGui.InputText(zh and "筛选" or "Filter", self.filterBuf, {"AutoSelectAll"}) then -- 393
						local res = string.match(self.filterBuf.text, "[^%%%.%[]+") -- 395
						self.filterText = string.lower(res or "") -- 396
					end -- 396
				else -- 396
					ImGui.SameLine() -- 399
					ImGui.Dummy(Vec2(width - (zh and 250 or 255), 0)) -- 400
				end -- 400
				ImGui.SameLine() -- 402
				if ImGui.CollapsingHeader("##option") then -- 402
					self.headerHeight = 130 -- 404
					ImGui.SetNextItemWidth(zh and -200 or -230) -- 405
					if ImGui.InputText(zh and "服务器" or "Server", url) then -- 405
						if url.text == "" then -- 405
							url.text = DefaultURL -- 408
						end -- 408
						config.url = url.text -- 410
					end -- 410
					ImGui.SameLine() -- 412
					if ImGui.Button(zh and "刷新" or "Reload") then -- 412
						local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 414
						Content:remove(packageListVersionFile) -- 415
						self:loadData() -- 416
					end -- 416
					ImGui.Separator() -- 418
				else -- 418
					self.headerHeight = 80 -- 420
				end -- 420
				ImGui.PushStyleVar( -- 422
					"WindowPadding", -- 422
					Vec2(10, 10), -- 422
					function() return ImGui.BeginTabBar( -- 422
						"categories", -- 422
						tabBarFlags, -- 422
						function() -- 422
							ImGui.BeginTabItem( -- 423
								zh and "全部" or "All", -- 423
								function() -- 423
									filterCategory = nil -- 424
								end -- 423
							) -- 423
							for ____, cat in ipairs(self.categories) do -- 426
								ImGui.BeginTabItem( -- 427
									cat, -- 427
									function() -- 427
										filterCategory = cat -- 428
									end -- 427
								) -- 427
							end -- 427
						end -- 422
					) end -- 422
				) -- 422
			end -- 376
		) end -- 376
	) -- 376
	local function matchCat(self, cat) -- 433
		return filterCategory == cat -- 433
	end -- 433
	local maxColumns = math.max( -- 434
		math.floor(width / 320), -- 434
		1 -- 434
	) -- 434
	local itemWidth = (width - 60) / maxColumns - 10 -- 435
	ImGui.SetNextWindowPos( -- 436
		Vec2(0, self.headerHeight), -- 436
		"Always", -- 436
		Vec2.zero -- 436
	) -- 436
	ImGui.SetNextWindowSize( -- 437
		Vec2(width, height - self.headerHeight - 50), -- 437
		"Always" -- 437
	) -- 437
	ImGui.PushStyleVar( -- 438
		"Alpha", -- 438
		1, -- 438
		function() return ImGui.PushStyleVar( -- 438
			"WindowPadding", -- 438
			Vec2(20, 10), -- 438
			function() return ImGui.Begin( -- 438
				"Dora Community Resources", -- 438
				windowsFlags, -- 438
				function() -- 438
					ImGui.Columns(maxColumns, false) -- 439
					for ____, pkg in ipairs(self.packages) do -- 442
						do -- 442
							local repo = self.repos:get(pkg.name) -- 443
							if not repo then -- 443
								goto __continue94 -- 444
							end -- 444
							if filterCategory ~= nil then -- 444
								if not repo.categories then -- 444
									goto __continue94 -- 446
								end -- 446
								if __TS__ArrayFind(repo.categories, matchCat) == nil then -- 446
									goto __continue94 -- 448
								end -- 448
							end -- 448
							local title = repo.title[zh and "zh" or "en"] -- 452
							if self.filterText ~= "" then -- 452
								local res = string.match( -- 455
									string.lower(title), -- 455
									self.filterText -- 455
								) -- 455
								if not res then -- 455
									goto __continue94 -- 456
								end -- 456
							end -- 456
							ImGui.TextColored(themeColor, title) -- 460
							local previewTexture = self.previewTextures:get(pkg.name) -- 463
							if previewTexture then -- 463
								local width = previewTexture.width -- 463
								local height = previewTexture.height -- 463
								local scale = (itemWidth - 30) / width -- 467
								local scaledSize = Vec2(width * scale, height * scale) -- 468
								local previewFile = self.previewFiles:get(pkg.name) -- 469
								if previewFile then -- 469
									ImGui.Dummy(Vec2.zero) -- 471
									ImGui.SameLine() -- 472
									ImGui.Image(previewFile, scaledSize) -- 473
								end -- 473
							else -- 473
								ImGui.Text(zh and "加载预览图中..." or "Loading preview...") -- 476
							end -- 476
							ImGui.TextWrapped(repo.desc[zh and "zh" or "en"]) -- 479
							ImGui.TextColored(themeColor, zh and "项目地址：" or "Repo URL:") -- 481
							ImGui.SameLine() -- 482
							if ImGui.TextLink((zh and "这里" or "here") .. "##" .. pkg.url) then -- 482
								App:openURL(pkg.url) -- 484
							end -- 484
							if ImGui.IsItemHovered() then -- 484
								ImGui.BeginTooltip(function() -- 487
									ImGui.PushTextWrapPos( -- 488
										300, -- 488
										function() -- 488
											ImGui.Text(pkg.url) -- 489
										end -- 488
									) -- 488
								end) -- 487
							end -- 487
							local currentVersion = pkg.currentVersion or 1 -- 494
							local version = pkg.versions[currentVersion] -- 495
							if type(version.updatedAt) == "number" then -- 495
								ImGui.TextColored(themeColor, zh and "同步时间：" or "Updated:") -- 497
								ImGui.SameLine() -- 498
								local dateStr = os.date("%Y-%m-%d %H:%M:%S", version.updatedAt) -- 499
								ImGui.Text(dateStr) -- 500
							end -- 500
							ImGui.TextColored(themeColor, zh and "文件大小：" or "File Size:") -- 504
							ImGui.SameLine() -- 505
							ImGui.Text(__TS__NumberToFixed(version.size / 1024 / 1024, 2) .. " MB") -- 506
							local progress = self.downloadProgress:get(pkg.name) -- 509
							if progress ~= nil then -- 509
								ImGui.ProgressBar( -- 511
									progress.progress, -- 511
									Vec2(-1, 30) -- 511
								) -- 511
								ImGui.BeginDisabled(function() -- 512
									ImGui.Button(progress.status) -- 513
								end) -- 512
							end -- 512
							if progress == nil then -- 512
								local isDownloaded = self:isDownloaded(pkg.name) -- 519
								local exeText = (zh and "测试" or "Test") .. "##test-" .. pkg.name -- 520
								local buttonText = (isDownloaded and (zh and "重新下载" or "Re-Download") or (zh and "下载" or "Download")) .. "##download-" .. pkg.name -- 521
								local deleteText = (zh and "删除" or "Delete") .. "##delete-" .. pkg.name -- 524
								local runable = repo.exe ~= false -- 525
								if self.isDownloading then -- 525
									ImGui.BeginDisabled(function() -- 527
										if runable then -- 527
											ImGui.Button(exeText) -- 529
											ImGui.SameLine() -- 530
										end -- 530
										ImGui.Button(buttonText) -- 532
										if isDownloaded then -- 532
											ImGui.SameLine() -- 534
											ImGui.Button(deleteText) -- 535
										end -- 535
									end) -- 527
								else -- 527
									if isDownloaded and runable then -- 527
										if type(repo.exe) == "table" then -- 527
											local exeList = repo.exe -- 541
											local popupId = "select-" .. pkg.name -- 542
											if ImGui.Button(exeText) then -- 542
												ImGui.OpenPopup(popupId) -- 544
											end -- 544
											ImGui.BeginPopup( -- 546
												popupId, -- 546
												function() -- 546
													for ____, entry in ipairs(exeList) do -- 547
														if ImGui.Selectable((((entry .. "##run-") .. pkg.name) .. "-") .. entry) then -- 547
															run(Path( -- 549
																Content.writablePath, -- 549
																"Download", -- 549
																pkg.name, -- 549
																entry, -- 549
																"init" -- 549
															)) -- 549
														end -- 549
													end -- 549
												end -- 546
											) -- 546
										else -- 546
											if ImGui.Button(exeText) then -- 546
												run(Path(Content.writablePath, "Download", pkg.name, "init")) -- 555
											end -- 555
										end -- 555
										ImGui.SameLine() -- 558
									end -- 558
									if ImGui.Button(buttonText) then -- 558
										self:downloadPackage(pkg) -- 561
									end -- 561
									if isDownloaded then -- 561
										ImGui.SameLine() -- 564
										if ImGui.Button(deleteText) then -- 564
											Content:remove(Path(Content.writablePath, "Download", pkg.name)) -- 566
											self.downloadedPackages:delete(pkg.name) -- 567
											Director.postNode:emit("UpdateEntries") -- 568
										end -- 568
									end -- 568
								end -- 568
							end -- 568
							if not self.isDownloading and pkg.versionNames and pkg.currentVersion then -- 568
								ImGui.SameLine() -- 575
								ImGui.SetNextItemWidth(-20) -- 576
								local changed, currentVersion = ImGui.Combo("##" .. pkg.name, pkg.currentVersion, pkg.versionNames) -- 577
								if changed then -- 577
									pkg.currentVersion = currentVersion -- 579
								end -- 579
							end -- 579
							thinSep() -- 583
							ImGui.NextColumn() -- 584
						end -- 584
						::__continue94:: -- 584
					end -- 584
					ImGui.Columns(1, false) -- 587
					ImGui.ScrollWhenDraggingOnVoid() -- 588
					if self.popupShow then -- 588
						self.popupShow = false -- 591
						ImGui.OpenPopup("MessagePopup") -- 592
					end -- 592
					ImGui.BeginPopupModal( -- 594
						"MessagePopup", -- 594
						function() return self:messagePopup() end -- 594
					) -- 594
				end -- 438
			) end -- 438
		) end -- 438
	) -- 438
end -- 371
__TS__New(ResourceDownloader) -- 599
return ____exports -- 599