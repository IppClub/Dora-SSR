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
	local Entry = require("Script.Dev.Entry") -- 102
	Entry.allClear() -- 103
	thread(function() -- 104
		Entry.enterEntryAsync({entryName = "Project", fileName = fileName}) -- 105
	end) -- 104
end -- 101
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
	local repo = self.repos:get(name) -- 245
	if repo ~= nil and repo.noBanner then -- 245
		local cacheFile = Path(Content.assetPath, "Image", "banner.jpg") -- 247
		if Content:exist(cacheFile) then -- 247
			Cache:loadAsync(cacheFile) -- 249
			local texture = Texture2D(cacheFile) -- 250
			if texture then -- 250
				self.previewTextures:set(name, texture) -- 252
				self.previewFiles:set(name, cacheFile) -- 253
			end -- 253
			return -- 255
		end -- 255
	end -- 255
	local cachePath = Path(Content.appPath, ".cache", "preview") -- 258
	local cacheFile = Path(cachePath, name .. ".jpg") -- 259
	if Content:exist(cacheFile) then -- 259
		Cache:loadAsync(cacheFile) -- 261
		local texture = Texture2D(cacheFile) -- 262
		if texture then -- 262
			self.previewTextures:set(name, texture) -- 264
			self.previewFiles:set(name, cacheFile) -- 265
		end -- 265
		return -- 267
	end -- 267
	local imageUrl = ((config.url .. "/assets/") .. name) .. "/banner.jpg" -- 269
	local response = HttpClient:downloadAsync(imageUrl, cacheFile, 10) -- 270
	if response then -- 270
		Cache:loadAsync(cacheFile) -- 272
		local texture = Texture2D(cacheFile) -- 273
		if texture then -- 273
			self.previewTextures:set(name, texture) -- 275
			self.previewFiles:set(name, cacheFile) -- 276
		end -- 276
	else -- 276
		print("Failed to load preview image for " .. name) -- 279
	end -- 279
end -- 244
function ResourceDownloader.prototype.isDownloaded(self, name) -- 283
	return self.downloadedPackages:has(name) -- 284
end -- 283
function ResourceDownloader.prototype.downloadPackage(self, pkg) -- 287
	if self.downloadTasks:has(pkg.name) then -- 287
		return -- 289
	end -- 289
	local task = thread(function() -- 292
		self.isDownloading = true -- 293
		local downloadStatus = (zh and "正在下载：" or "Downloading: ") .. pkg.name -- 294
		local downloadPath = Path(Content.writablePath, ".download") -- 295
		Content:mkdir(downloadPath) -- 296
		local currentVersion = pkg.currentVersion or 1 -- 297
		local version = pkg.versions[currentVersion] -- 298
		local targetFile = Path(downloadPath, version.file) -- 299
		local success = HttpClient:downloadAsync( -- 301
			version.download, -- 302
			targetFile, -- 303
			1200, -- 304
			function(current, total) -- 305
				if self.cancelDownload then -- 305
					return true -- 307
				end -- 307
				self.downloadProgress:set(pkg.name, {progress = current / total, status = downloadStatus}) -- 309
				return false -- 310
			end -- 305
		) -- 305
		if success then -- 305
			downloadStatus = zh and "解压中：" .. pkg.name or "Unziping: " .. pkg.name -- 315
			self.downloadProgress:set(pkg.name, {progress = 1, status = downloadStatus}) -- 316
			local unzipPath = Path(Content.writablePath, "Download", pkg.name) -- 317
			Content:remove(unzipPath) -- 318
			if Content:unzipAsync(targetFile, unzipPath) then -- 318
				Content:remove(targetFile) -- 320
				self.downloadedPackages:add(pkg.name) -- 321
				local repo = self.repos:get(pkg.name) -- 322
				if repo then -- 322
					local str = json.encode(repo) -- 324
					if str then -- 324
						if Content:mkdir(Path(unzipPath, ".dora")) then -- 324
							Content:save( -- 327
								Path(unzipPath, ".dora", "repo.json"), -- 327
								str -- 327
							) -- 327
							local previewFile = self.previewFiles:get(pkg.name) -- 328
							if previewFile and Content:exist(previewFile) then -- 328
								Content:copy( -- 330
									previewFile, -- 330
									Path(unzipPath, ".dora", "banner.jpg") -- 330
								) -- 330
							end -- 330
						end -- 330
					end -- 330
				end -- 330
				Director.postNode:emit("UpdateEntries") -- 335
			else -- 335
				Content:remove(unzipPath) -- 337
				self:showPopup(zh and "解压失败" or "Failed to unzip", zh and "无法解压文件：" .. version.file or "Failed to unzip: " .. version.file) -- 338
			end -- 338
		else -- 338
			Content:remove(targetFile) -- 344
			self:showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. version.download or "Failed to download from: " .. version.download) -- 345
		end -- 345
		self.isDownloading = false -- 351
		self.downloadProgress:delete(pkg.name) -- 352
		self.downloadTasks:delete(pkg.name) -- 353
	end) -- 292
	self.downloadTasks:set(pkg.name, task) -- 356
end -- 287
function ResourceDownloader.prototype.messagePopup(self) -- 359
	ImGui.Text(self.popupMessageTitle) -- 360
	ImGui.Separator() -- 361
	ImGui.PushTextWrapPos( -- 362
		300, -- 362
		function() -- 362
			ImGui.TextWrapped(self.popupMessage) -- 363
		end -- 362
	) -- 362
	if ImGui.Button( -- 362
		zh and "确认" or "OK", -- 365
		Vec2(300, 30) -- 365
	) then -- 365
		ImGui.CloseCurrentPopup() -- 366
	end -- 366
end -- 359
function ResourceDownloader.prototype.update(self) -- 370
	local ____App_visualSize_1 = App.visualSize -- 371
	local width = ____App_visualSize_1.width -- 371
	local height = ____App_visualSize_1.height -- 371
	local filterCategory = nil -- 372
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 373
	ImGui.SetNextWindowSize( -- 374
		Vec2(width, self.headerHeight), -- 374
		"Always" -- 374
	) -- 374
	ImGui.PushStyleVar( -- 375
		"WindowPadding", -- 375
		Vec2(10, 0), -- 375
		function() return ImGui.Begin( -- 375
			"Dora Community Header", -- 375
			windowsNoScrollFlags, -- 375
			function() -- 375
				ImGui.Dummy(Vec2(0, 0)) -- 376
				ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Resources") -- 377
				ImGui.SameLine() -- 378
				ImGui.TextDisabled("(?)") -- 379
				if ImGui.IsItemHovered() then -- 379
					ImGui.BeginTooltip(function() -- 381
						ImGui.PushTextWrapPos( -- 382
							300, -- 382
							function() -- 382
								ImGui.Text(zh and "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" or "Use this tool to download Dora SSR community resources to the `Download` directory.") -- 383
							end -- 382
						) -- 382
					end) -- 381
				end -- 381
				local padding = zh and 400 or 440 -- 387
				if width >= padding then -- 387
					ImGui.SameLine() -- 389
					ImGui.Dummy(Vec2(width - padding, 0)) -- 390
					ImGui.SameLine() -- 391
					ImGui.SetNextItemWidth((zh and -40 or -55) - 40) -- 392
					if ImGui.InputText(zh and "筛选" or "Filter", self.filterBuf, {"AutoSelectAll"}) then -- 392
						local res = string.match(self.filterBuf.text, "[^%%%.%[]+") -- 394
						self.filterText = string.lower(res or "") -- 395
					end -- 395
				else -- 395
					ImGui.SameLine() -- 398
					ImGui.Dummy(Vec2(width - (zh and 250 or 255), 0)) -- 399
				end -- 399
				ImGui.SameLine() -- 401
				if ImGui.CollapsingHeader("##option") then -- 401
					self.headerHeight = 130 -- 403
					ImGui.SetNextItemWidth(zh and -200 or -230) -- 404
					if ImGui.InputText(zh and "服务器" or "Server", url) then -- 404
						if url.text == "" then -- 404
							url.text = DefaultURL -- 407
						end -- 407
						config.url = url.text -- 409
					end -- 409
					ImGui.SameLine() -- 411
					if ImGui.Button(zh and "刷新" or "Reload") then -- 411
						local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 413
						Content:remove(packageListVersionFile) -- 414
						self:loadData() -- 415
					end -- 415
					ImGui.Separator() -- 417
				else -- 417
					self.headerHeight = 80 -- 419
				end -- 419
				ImGui.PushStyleVar( -- 421
					"WindowPadding", -- 421
					Vec2(10, 10), -- 421
					function() return ImGui.BeginTabBar( -- 421
						"categories", -- 421
						tabBarFlags, -- 421
						function() -- 421
							ImGui.BeginTabItem( -- 422
								zh and "全部" or "All", -- 422
								function() -- 422
									filterCategory = nil -- 423
								end -- 422
							) -- 422
							for ____, cat in ipairs(self.categories) do -- 425
								ImGui.BeginTabItem( -- 426
									cat, -- 426
									function() -- 426
										filterCategory = cat -- 427
									end -- 426
								) -- 426
							end -- 426
						end -- 421
					) end -- 421
				) -- 421
			end -- 375
		) end -- 375
	) -- 375
	local function matchCat(self, cat) -- 432
		return filterCategory == cat -- 432
	end -- 432
	local maxColumns = math.max( -- 433
		math.floor(width / 320), -- 433
		1 -- 433
	) -- 433
	local itemWidth = (width - 60) / maxColumns - 10 -- 434
	ImGui.SetNextWindowPos( -- 435
		Vec2(0, self.headerHeight), -- 435
		"Always", -- 435
		Vec2.zero -- 435
	) -- 435
	ImGui.SetNextWindowSize( -- 436
		Vec2(width, height - self.headerHeight - 50), -- 436
		"Always" -- 436
	) -- 436
	ImGui.PushStyleVar( -- 437
		"Alpha", -- 437
		1, -- 437
		function() return ImGui.PushStyleVar( -- 437
			"WindowPadding", -- 437
			Vec2(20, 10), -- 437
			function() return ImGui.Begin( -- 437
				"Dora Community Resources", -- 437
				windowsFlags, -- 437
				function() -- 437
					ImGui.Columns(maxColumns, false) -- 438
					for ____, pkg in ipairs(self.packages) do -- 441
						do -- 441
							local repo = self.repos:get(pkg.name) -- 442
							if not repo then -- 442
								goto __continue94 -- 443
							end -- 443
							if filterCategory ~= nil then -- 443
								if not repo.categories then -- 443
									goto __continue94 -- 445
								end -- 445
								if __TS__ArrayFind(repo.categories, matchCat) == nil then -- 445
									goto __continue94 -- 447
								end -- 447
							end -- 447
							local title = repo.title[zh and "zh" or "en"] -- 451
							if self.filterText ~= "" then -- 451
								local res = string.match( -- 454
									string.lower(title), -- 454
									self.filterText -- 454
								) -- 454
								if not res then -- 454
									goto __continue94 -- 455
								end -- 455
							end -- 455
							ImGui.TextColored(themeColor, title) -- 459
							local previewTexture = self.previewTextures:get(pkg.name) -- 462
							if previewTexture then -- 462
								local width = previewTexture.width -- 462
								local height = previewTexture.height -- 462
								local scale = (itemWidth - 30) / width -- 466
								local scaledSize = Vec2(width * scale, height * scale) -- 467
								local previewFile = self.previewFiles:get(pkg.name) -- 468
								if previewFile then -- 468
									ImGui.Dummy(Vec2.zero) -- 470
									ImGui.SameLine() -- 471
									ImGui.Image(previewFile, scaledSize) -- 472
								end -- 472
							else -- 472
								ImGui.Text(zh and "加载预览图中..." or "Loading preview...") -- 475
							end -- 475
							ImGui.TextWrapped(repo.desc[zh and "zh" or "en"]) -- 478
							ImGui.TextColored(themeColor, zh and "项目地址：" or "Repo URL:") -- 480
							ImGui.SameLine() -- 481
							if ImGui.TextLink((zh and "这里" or "here") .. "##" .. pkg.url) then -- 481
								App:openURL(pkg.url) -- 483
							end -- 483
							if ImGui.IsItemHovered() then -- 483
								ImGui.BeginTooltip(function() -- 486
									ImGui.PushTextWrapPos( -- 487
										300, -- 487
										function() -- 487
											ImGui.Text(pkg.url) -- 488
										end -- 487
									) -- 487
								end) -- 486
							end -- 486
							local currentVersion = pkg.currentVersion or 1 -- 493
							local version = pkg.versions[currentVersion] -- 494
							if type(version.updatedAt) == "number" then -- 494
								ImGui.TextColored(themeColor, zh and "同步时间：" or "Updated:") -- 496
								ImGui.SameLine() -- 497
								local dateStr = os.date("%Y-%m-%d %H:%M:%S", version.updatedAt) -- 498
								ImGui.Text(dateStr) -- 499
							end -- 499
							ImGui.TextColored(themeColor, zh and "文件大小：" or "File Size:") -- 503
							ImGui.SameLine() -- 504
							ImGui.Text(__TS__NumberToFixed(version.size / 1024 / 1024, 2) .. " MB") -- 505
							local progress = self.downloadProgress:get(pkg.name) -- 508
							if progress ~= nil then -- 508
								ImGui.ProgressBar( -- 510
									progress.progress, -- 510
									Vec2(-1, 30) -- 510
								) -- 510
								ImGui.BeginDisabled(function() -- 511
									ImGui.Button(progress.status) -- 512
								end) -- 511
							end -- 511
							if progress == nil then -- 511
								local isDownloaded = self:isDownloaded(pkg.name) -- 518
								local exeText = (zh and "测试" or "Test") .. "##test-" .. pkg.name -- 519
								local buttonText = (isDownloaded and (zh and "重新下载" or "Re-Download") or (zh and "下载" or "Download")) .. "##download-" .. pkg.name -- 520
								local deleteText = (zh and "删除" or "Delete") .. "##delete-" .. pkg.name -- 523
								local runable = repo.exe ~= false -- 524
								if self.isDownloading then -- 524
									ImGui.BeginDisabled(function() -- 526
										if runable then -- 526
											ImGui.Button(exeText) -- 528
											ImGui.SameLine() -- 529
										end -- 529
										ImGui.Button(buttonText) -- 531
										if isDownloaded then -- 531
											ImGui.SameLine() -- 533
											ImGui.Button(deleteText) -- 534
										end -- 534
									end) -- 526
								else -- 526
									if isDownloaded and runable then -- 526
										if type(repo.exe) == "table" then -- 526
											local exeList = repo.exe -- 540
											local popupId = "select-" .. pkg.name -- 541
											if ImGui.Button(exeText) then -- 541
												ImGui.OpenPopup(popupId) -- 543
											end -- 543
											ImGui.BeginPopup( -- 545
												popupId, -- 545
												function() -- 545
													for ____, entry in ipairs(exeList) do -- 546
														if ImGui.Selectable((((entry .. "##run-") .. pkg.name) .. "-") .. entry) then -- 546
															run(Path( -- 548
																Content.writablePath, -- 548
																"Download", -- 548
																pkg.name, -- 548
																entry, -- 548
																"init" -- 548
															)) -- 548
														end -- 548
													end -- 548
												end -- 545
											) -- 545
										else -- 545
											if ImGui.Button(exeText) then -- 545
												run(Path(Content.writablePath, "Download", pkg.name, "init")) -- 554
											end -- 554
										end -- 554
										ImGui.SameLine() -- 557
									end -- 557
									if ImGui.Button(buttonText) then -- 557
										self:downloadPackage(pkg) -- 560
									end -- 560
									if isDownloaded then -- 560
										ImGui.SameLine() -- 563
										if ImGui.Button(deleteText) then -- 563
											Content:remove(Path(Content.writablePath, "Download", pkg.name)) -- 565
											self.downloadedPackages:delete(pkg.name) -- 566
											Director.postNode:emit("UpdateEntries") -- 567
										end -- 567
									end -- 567
								end -- 567
							end -- 567
							if not self.isDownloading and pkg.versionNames and pkg.currentVersion then -- 567
								ImGui.SameLine() -- 574
								ImGui.SetNextItemWidth(-20) -- 575
								local changed, currentVersion = ImGui.Combo("##" .. pkg.name, pkg.currentVersion, pkg.versionNames) -- 576
								if changed then -- 576
									pkg.currentVersion = currentVersion -- 578
								end -- 578
							end -- 578
							thinSep() -- 582
							ImGui.NextColumn() -- 583
						end -- 583
						::__continue94:: -- 583
					end -- 583
					ImGui.Columns(1, false) -- 586
					ImGui.ScrollWhenDraggingOnVoid() -- 587
					if self.popupShow then -- 587
						self.popupShow = false -- 590
						ImGui.OpenPopup("MessagePopup") -- 591
					end -- 591
					ImGui.BeginPopupModal( -- 593
						"MessagePopup", -- 593
						function() return self:messagePopup() end -- 593
					) -- 593
				end -- 437
			) end -- 437
		) end -- 437
	) -- 437
end -- 370
__TS__New(ResourceDownloader) -- 598
return ____exports -- 598