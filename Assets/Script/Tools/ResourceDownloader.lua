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
	"NoSavedSettings", -- 71
	"NoFocusOnAppearing", -- 72
	"NoBringToFrontOnFocus" -- 73
} -- 73
local windowsFlags = { -- 76
	"NoMove", -- 77
	"NoCollapse", -- 78
	"NoResize", -- 79
	"NoDecoration", -- 80
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
local function run(fileName) -- 99
	local Entry = require("Script.Dev.Entry") -- 100
	Entry.allClear() -- 101
	thread(function() -- 102
		Entry.enterEntryAsync({entryName = "Project", fileName = fileName}) -- 103
	end) -- 102
end -- 99
local ResourceDownloader = __TS__Class() -- 107
ResourceDownloader.name = "ResourceDownloader" -- 107
function ResourceDownloader.prototype.____constructor(self) -- 127
	self.packages = {} -- 108
	self.repos = __TS__New(Map) -- 109
	self.downloadProgress = __TS__New(Map) -- 110
	self.downloadTasks = __TS__New(Map) -- 111
	self.popupMessageTitle = "" -- 112
	self.popupMessage = "" -- 113
	self.popupShow = false -- 114
	self.cancelDownload = false -- 115
	self.isDownloading = false -- 116
	self.previewTextures = __TS__New(Map) -- 118
	self.previewFiles = __TS__New(Map) -- 119
	self.downloadedPackages = __TS__New(Set) -- 120
	self.isLoading = false -- 121
	self.filterBuf = Buffer(20) -- 122
	self.filterText = "" -- 123
	self.categories = {} -- 124
	self.headerHeight = 80 -- 125
	self.node = Node() -- 128
	self.node:schedule(function() -- 129
		self:update() -- 130
		return false -- 131
	end) -- 129
	self.node:onCleanup(function() -- 133
		self.cancelDownload = true -- 134
	end) -- 133
	self:loadData() -- 136
end -- 127
function ResourceDownloader.prototype.showPopup(self, title, msg) -- 139
	self.popupMessageTitle = title -- 140
	self.popupMessage = msg -- 141
	self.popupShow = true -- 142
end -- 139
function ResourceDownloader.prototype.loadData(self) -- 145
	if self.isLoading then -- 145
		return -- 146
	end -- 146
	self.isLoading = true -- 147
	thread(function() -- 148
		local reload = false -- 149
		local versionResponse = HttpClient:getAsync(config.url .. "/api/v1/package-list-version") -- 150
		local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 151
		if versionResponse then -- 151
			local version = json.decode(versionResponse) -- 153
			local packageListVersion = version -- 154
			if Content:exist(packageListVersionFile) then -- 154
				local oldVersion = json.decode(Content:load(packageListVersionFile)) -- 156
				local oldPackageListVersion = oldVersion -- 157
				if packageListVersion.version ~= oldPackageListVersion.version then -- 157
					reload = true -- 159
				end -- 159
			else -- 159
				reload = true -- 162
			end -- 162
		end -- 162
		if reload then -- 162
			self.categories = {} -- 166
			self.packages = {} -- 167
			self.repos = __TS__New(Map) -- 168
			self.previewTextures:clear() -- 169
			self.previewFiles:clear() -- 170
			local cachePath = Path(Content.appPath, ".cache", "preview") -- 171
			Content:remove(cachePath) -- 172
		end -- 172
		local cachePath = Path(Content.appPath, ".cache", "preview") -- 175
		Content:mkdir(cachePath) -- 176
		if reload and versionResponse then -- 176
			Content:save(packageListVersionFile, versionResponse) -- 178
		end -- 178
		local packagesFile = Path(cachePath, "packages.json") -- 180
		if Content:exist(packagesFile) then -- 180
			local packages = json.decode(Content:load(packagesFile)) -- 182
			self.packages = packages -- 183
		else -- 183
			local packagesResponse = HttpClient:getAsync(config.url .. "/api/v1/packages") -- 185
			if packagesResponse then -- 185
				local packages = json.decode(packagesResponse) -- 188
				self.packages = packages -- 189
				Content:save(packagesFile, packagesResponse) -- 190
			end -- 190
		end -- 190
		for ____, pkg in ipairs(self.packages) do -- 193
			pkg.currentVersion = 1 -- 194
			pkg.versionNames = __TS__ArrayMap( -- 195
				pkg.versions, -- 195
				function(____, v) -- 195
					return v.tag == "" and "No Tag" or v.tag -- 196
				end -- 195
			) -- 195
		end -- 195
		local catSet = __TS__New(Set) -- 201
		local function loadRepos(repos) -- 202
			for ____, repo in ipairs(repos) do -- 203
				self.repos:set(repo.name, repo) -- 204
				if repo.categories then -- 204
					for ____, cat in ipairs(repo.categories) do -- 206
						catSet:add(cat) -- 207
					end -- 207
				end -- 207
			end -- 207
		end -- 202
		local reposFile = Path(cachePath, "repos.json") -- 212
		if Content:exist(reposFile) then -- 212
			local repos = json.decode(Content:load(reposFile)) -- 214
			loadRepos(repos) -- 215
		else -- 215
			local reposResponse = HttpClient:getAsync(config.url .. "/assets/repos.json") -- 217
			if reposResponse then -- 217
				local repos = json.decode(reposResponse) -- 219
				loadRepos(repos) -- 220
				Content:save(reposFile, reposResponse) -- 221
			end -- 221
		end -- 221
		for ____, cat in __TS__Iterator(catSet) do -- 224
			local ____self_categories_0 = self.categories -- 224
			____self_categories_0[#____self_categories_0 + 1] = cat -- 225
		end -- 225
		for ____, pkg in ipairs(self.packages) do -- 229
			local downloadPath = Path(Content.writablePath, "Download", pkg.name) -- 230
			if Content:exist(downloadPath) then -- 230
				self.downloadedPackages:add(pkg.name) -- 232
			end -- 232
		end -- 232
		for ____, pkg in ipairs(self.packages) do -- 235
			self:loadPreviewImage(pkg.name) -- 236
		end -- 236
		self.isLoading = false -- 238
	end) -- 148
end -- 145
function ResourceDownloader.prototype.loadPreviewImage(self, name) -- 242
	local repo = self.repos:get(name) -- 243
	if repo ~= nil and repo.noBanner then -- 243
		local cacheFile = Path(Content.assetPath, "Image", "banner.jpg") -- 245
		if Content:exist(cacheFile) then -- 245
			Cache:loadAsync(cacheFile) -- 247
			local texture = Texture2D(cacheFile) -- 248
			if texture then -- 248
				self.previewTextures:set(name, texture) -- 250
				self.previewFiles:set(name, cacheFile) -- 251
			end -- 251
			return -- 253
		end -- 253
	end -- 253
	local cachePath = Path(Content.appPath, ".cache", "preview") -- 256
	local cacheFile = Path(cachePath, name .. ".jpg") -- 257
	if Content:exist(cacheFile) then -- 257
		Cache:loadAsync(cacheFile) -- 259
		local texture = Texture2D(cacheFile) -- 260
		if texture then -- 260
			self.previewTextures:set(name, texture) -- 262
			self.previewFiles:set(name, cacheFile) -- 263
		end -- 263
		return -- 265
	end -- 265
	local imageUrl = ((config.url .. "/assets/") .. name) .. "/banner.jpg" -- 267
	local response = HttpClient:downloadAsync(imageUrl, cacheFile, 10) -- 268
	if response then -- 268
		Cache:loadAsync(cacheFile) -- 270
		local texture = Texture2D(cacheFile) -- 271
		if texture then -- 271
			self.previewTextures:set(name, texture) -- 273
			self.previewFiles:set(name, cacheFile) -- 274
		end -- 274
	else -- 274
		print("Failed to load preview image for " .. name) -- 277
	end -- 277
end -- 242
function ResourceDownloader.prototype.isDownloaded(self, name) -- 281
	return self.downloadedPackages:has(name) -- 282
end -- 281
function ResourceDownloader.prototype.downloadPackage(self, pkg) -- 285
	if self.downloadTasks:has(pkg.name) then -- 285
		return -- 287
	end -- 287
	local task = thread(function() -- 290
		self.isDownloading = true -- 291
		local downloadStatus = (zh and "正在下载：" or "Downloading: ") .. pkg.name -- 292
		local downloadPath = Path(Content.writablePath, ".download") -- 293
		Content:mkdir(downloadPath) -- 294
		local currentVersion = pkg.currentVersion or 1 -- 295
		local version = pkg.versions[currentVersion] -- 296
		local targetFile = Path(downloadPath, version.file) -- 297
		local success = HttpClient:downloadAsync( -- 299
			version.download, -- 300
			targetFile, -- 301
			1200, -- 302
			function(current, total) -- 303
				if self.cancelDownload then -- 303
					return true -- 305
				end -- 305
				self.downloadProgress:set(pkg.name, {progress = current / total, status = downloadStatus}) -- 307
				return false -- 308
			end -- 303
		) -- 303
		if success then -- 303
			downloadStatus = zh and "解压中：" .. pkg.name or "Unziping: " .. pkg.name -- 313
			self.downloadProgress:set(pkg.name, {progress = 1, status = downloadStatus}) -- 314
			local unzipPath = Path(Content.writablePath, "Download", pkg.name) -- 315
			Content:remove(unzipPath) -- 316
			if Content:unzipAsync(targetFile, unzipPath) then -- 316
				Content:remove(targetFile) -- 318
				self.downloadedPackages:add(pkg.name) -- 319
				local repo = self.repos:get(pkg.name) -- 320
				if repo then -- 320
					local str = json.encode(repo) -- 322
					if str then -- 322
						if Content:mkdir(Path(unzipPath, ".dora")) then -- 322
							Content:save( -- 325
								Path(unzipPath, ".dora", "repo.json"), -- 325
								str -- 325
							) -- 325
							local previewFile = self.previewFiles:get(pkg.name) -- 326
							if previewFile and Content:exist(previewFile) then -- 326
								Content:copy( -- 328
									previewFile, -- 328
									Path(unzipPath, ".dora", "banner.jpg") -- 328
								) -- 328
							end -- 328
						end -- 328
					end -- 328
				end -- 328
				Director.postNode:emit("UpdateEntries") -- 333
			else -- 333
				Content:remove(unzipPath) -- 335
				self:showPopup(zh and "解压失败" or "Failed to unzip", zh and "无法解压文件：" .. version.file or "Failed to unzip: " .. version.file) -- 336
			end -- 336
		else -- 336
			Content:remove(targetFile) -- 342
			self:showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. version.download or "Failed to download from: " .. version.download) -- 343
		end -- 343
		self.isDownloading = false -- 349
		self.downloadProgress:delete(pkg.name) -- 350
		self.downloadTasks:delete(pkg.name) -- 351
	end) -- 290
	self.downloadTasks:set(pkg.name, task) -- 354
end -- 285
function ResourceDownloader.prototype.messagePopup(self) -- 357
	ImGui.Text(self.popupMessageTitle) -- 358
	ImGui.Separator() -- 359
	ImGui.PushTextWrapPos( -- 360
		300, -- 360
		function() -- 360
			ImGui.TextWrapped(self.popupMessage) -- 361
		end -- 360
	) -- 360
	if ImGui.Button( -- 360
		zh and "确认" or "OK", -- 363
		Vec2(300, 30) -- 363
	) then -- 363
		ImGui.CloseCurrentPopup() -- 364
	end -- 364
end -- 357
function ResourceDownloader.prototype.update(self) -- 368
	local ____App_visualSize_1 = App.visualSize -- 369
	local width = ____App_visualSize_1.width -- 369
	local height = ____App_visualSize_1.height -- 369
	local filterCategory = nil -- 370
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 371
	ImGui.SetNextWindowSize( -- 372
		Vec2(width, self.headerHeight), -- 372
		"Always" -- 372
	) -- 372
	ImGui.PushStyleVar( -- 373
		"WindowPadding", -- 373
		Vec2(10, 0), -- 373
		function() return ImGui.Begin( -- 373
			"Dora Community Header", -- 373
			windowsNoScrollFlags, -- 373
			function() -- 373
				ImGui.Dummy(Vec2(0, 0)) -- 374
				ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Resources") -- 375
				ImGui.SameLine() -- 376
				ImGui.TextDisabled("(?)") -- 377
				if ImGui.IsItemHovered() then -- 377
					ImGui.BeginTooltip(function() -- 379
						ImGui.PushTextWrapPos( -- 380
							300, -- 380
							function() -- 380
								ImGui.Text(zh and "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" or "Use this tool to download Dora SSR community resources to the `Download` directory.") -- 381
							end -- 380
						) -- 380
					end) -- 379
				end -- 379
				local padding = zh and 400 or 440 -- 385
				if width >= padding then -- 385
					ImGui.SameLine() -- 387
					ImGui.Dummy(Vec2(width - padding, 0)) -- 388
					ImGui.SameLine() -- 389
					ImGui.SetNextItemWidth((zh and -40 or -55) - 40) -- 390
					if ImGui.InputText(zh and "筛选" or "Filter", self.filterBuf, {"AutoSelectAll"}) then -- 390
						local res = string.match(self.filterBuf.text, "[^%%%.%[]+") -- 392
						self.filterText = string.lower(res or "") -- 393
					end -- 393
				else -- 393
					ImGui.SameLine() -- 396
					ImGui.Dummy(Vec2(width - (zh and 250 or 255), 0)) -- 397
				end -- 397
				ImGui.SameLine() -- 399
				if ImGui.CollapsingHeader("##option") then -- 399
					self.headerHeight = 130 -- 401
					ImGui.SetNextItemWidth(zh and -200 or -230) -- 402
					if ImGui.InputText(zh and "服务器" or "Server", url) then -- 402
						if url.text == "" then -- 402
							url.text = DefaultURL -- 405
						end -- 405
						config.url = url.text -- 407
					end -- 407
					ImGui.SameLine() -- 409
					if ImGui.Button(zh and "刷新" or "Reload") then -- 409
						local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 411
						Content:remove(packageListVersionFile) -- 412
						self:loadData() -- 413
					end -- 413
					ImGui.Separator() -- 415
				else -- 415
					self.headerHeight = 80 -- 417
				end -- 417
				ImGui.PushStyleVar( -- 419
					"WindowPadding", -- 419
					Vec2(10, 10), -- 419
					function() return ImGui.BeginTabBar( -- 419
						"categories", -- 419
						tabBarFlags, -- 419
						function() -- 419
							ImGui.BeginTabItem( -- 420
								zh and "全部" or "All", -- 420
								function() -- 420
									filterCategory = nil -- 421
								end -- 420
							) -- 420
							for ____, cat in ipairs(self.categories) do -- 423
								ImGui.BeginTabItem( -- 424
									cat, -- 424
									function() -- 424
										filterCategory = cat -- 425
									end -- 424
								) -- 424
							end -- 424
						end -- 419
					) end -- 419
				) -- 419
			end -- 373
		) end -- 373
	) -- 373
	local function matchCat(self, cat) -- 430
		return filterCategory == cat -- 430
	end -- 430
	local maxColumns = math.max( -- 431
		math.floor(width / 320), -- 431
		1 -- 431
	) -- 431
	local itemWidth = (width - 60) / maxColumns - 10 -- 432
	ImGui.SetNextWindowPos( -- 433
		Vec2(0, self.headerHeight), -- 433
		"Always", -- 433
		Vec2.zero -- 433
	) -- 433
	ImGui.SetNextWindowSize( -- 434
		Vec2(width, height - self.headerHeight - 50), -- 434
		"Always" -- 434
	) -- 434
	ImGui.PushStyleVar( -- 435
		"Alpha", -- 435
		1, -- 435
		function() return ImGui.PushStyleVar( -- 435
			"WindowPadding", -- 435
			Vec2(20, 10), -- 435
			function() return ImGui.Begin( -- 435
				"Dora Community Resources", -- 435
				windowsFlags, -- 435
				function() -- 435
					ImGui.Columns(maxColumns, false) -- 436
					for ____, pkg in ipairs(self.packages) do -- 439
						do -- 439
							local repo = self.repos:get(pkg.name) -- 440
							if not repo then -- 440
								goto __continue94 -- 441
							end -- 441
							if filterCategory ~= nil then -- 441
								if not repo.categories then -- 441
									goto __continue94 -- 443
								end -- 443
								if __TS__ArrayFind(repo.categories, matchCat) == nil then -- 443
									goto __continue94 -- 445
								end -- 445
							end -- 445
							local title = repo.title[zh and "zh" or "en"] -- 449
							if self.filterText ~= "" then -- 449
								local res = string.match( -- 452
									string.lower(title), -- 452
									self.filterText -- 452
								) -- 452
								if not res then -- 452
									goto __continue94 -- 453
								end -- 453
							end -- 453
							ImGui.TextColored(themeColor, title) -- 457
							local previewTexture = self.previewTextures:get(pkg.name) -- 460
							if previewTexture then -- 460
								local width = previewTexture.width -- 460
								local height = previewTexture.height -- 460
								local scale = (itemWidth - 30) / width -- 464
								local scaledSize = Vec2(width * scale, height * scale) -- 465
								local previewFile = self.previewFiles:get(pkg.name) -- 466
								if previewFile then -- 466
									ImGui.Dummy(Vec2.zero) -- 468
									ImGui.SameLine() -- 469
									ImGui.Image(previewFile, scaledSize) -- 470
								end -- 470
							else -- 470
								ImGui.Text(zh and "加载预览图中..." or "Loading preview...") -- 473
							end -- 473
							ImGui.TextWrapped(repo.desc[zh and "zh" or "en"]) -- 476
							ImGui.TextColored(themeColor, zh and "项目地址：" or "Repo URL:") -- 478
							ImGui.SameLine() -- 479
							if ImGui.TextLink((zh and "这里" or "here") .. "##" .. pkg.url) then -- 479
								App:openURL(pkg.url) -- 481
							end -- 481
							if ImGui.IsItemHovered() then -- 481
								ImGui.BeginTooltip(function() -- 484
									ImGui.PushTextWrapPos( -- 485
										300, -- 485
										function() -- 485
											ImGui.Text(pkg.url) -- 486
										end -- 485
									) -- 485
								end) -- 484
							end -- 484
							local currentVersion = pkg.currentVersion or 1 -- 491
							local version = pkg.versions[currentVersion] -- 492
							if type(version.updatedAt) == "number" then -- 492
								ImGui.TextColored(themeColor, zh and "同步时间：" or "Updated:") -- 494
								ImGui.SameLine() -- 495
								local dateStr = os.date("%Y-%m-%d %H:%M:%S", version.updatedAt) -- 496
								ImGui.Text(dateStr) -- 497
							end -- 497
							ImGui.TextColored(themeColor, zh and "文件大小：" or "File Size:") -- 501
							ImGui.SameLine() -- 502
							ImGui.Text(__TS__NumberToFixed(version.size / 1024 / 1024, 2) .. " MB") -- 503
							local progress = self.downloadProgress:get(pkg.name) -- 506
							if progress ~= nil then -- 506
								ImGui.ProgressBar( -- 508
									progress.progress, -- 508
									Vec2(-1, 30) -- 508
								) -- 508
								ImGui.BeginDisabled(function() -- 509
									ImGui.Button(progress.status) -- 510
								end) -- 509
							end -- 509
							if progress == nil then -- 509
								local isDownloaded = self:isDownloaded(pkg.name) -- 516
								local exeText = (zh and "测试" or "Test") .. "##test-" .. pkg.name -- 517
								local buttonText = (isDownloaded and (zh and "重新下载" or "Re-Download") or (zh and "下载" or "Download")) .. "##download-" .. pkg.name -- 518
								local deleteText = (zh and "删除" or "Delete") .. "##delete-" .. pkg.name -- 521
								local runable = repo.exe ~= false -- 522
								if self.isDownloading then -- 522
									ImGui.BeginDisabled(function() -- 524
										if runable then -- 524
											ImGui.Button(exeText) -- 526
											ImGui.SameLine() -- 527
										end -- 527
										ImGui.Button(buttonText) -- 529
										if isDownloaded then -- 529
											ImGui.SameLine() -- 531
											ImGui.Button(deleteText) -- 532
										end -- 532
									end) -- 524
								else -- 524
									if isDownloaded and runable then -- 524
										if type(repo.exe) == "table" then -- 524
											local exeList = repo.exe -- 538
											local popupId = "select-" .. pkg.name -- 539
											if ImGui.Button(exeText) then -- 539
												ImGui.OpenPopup(popupId) -- 541
											end -- 541
											ImGui.BeginPopup( -- 543
												popupId, -- 543
												function() -- 543
													for ____, entry in ipairs(exeList) do -- 544
														if ImGui.Selectable((((entry .. "##run-") .. pkg.name) .. "-") .. entry) then -- 544
															run(Path( -- 546
																Content.writablePath, -- 546
																"Download", -- 546
																pkg.name, -- 546
																entry, -- 546
																"init" -- 546
															)) -- 546
														end -- 546
													end -- 546
												end -- 543
											) -- 543
										else -- 543
											if ImGui.Button(exeText) then -- 543
												run(Path(Content.writablePath, "Download", pkg.name, "init")) -- 552
											end -- 552
										end -- 552
										ImGui.SameLine() -- 555
									end -- 555
									if ImGui.Button(buttonText) then -- 555
										self:downloadPackage(pkg) -- 558
									end -- 558
									if isDownloaded then -- 558
										ImGui.SameLine() -- 561
										if ImGui.Button(deleteText) then -- 561
											Content:remove(Path(Content.writablePath, "Download", pkg.name)) -- 563
											self.downloadedPackages:delete(pkg.name) -- 564
											Director.postNode:emit("UpdateEntries") -- 565
										end -- 565
									end -- 565
								end -- 565
							end -- 565
							if not self.isDownloading and pkg.versionNames and pkg.currentVersion then -- 565
								ImGui.SameLine() -- 572
								ImGui.SetNextItemWidth(-20) -- 573
								local changed, currentVersion = ImGui.Combo("##" .. pkg.name, pkg.currentVersion, pkg.versionNames) -- 574
								if changed then -- 574
									pkg.currentVersion = currentVersion -- 576
								end -- 576
							end -- 576
							thinSep() -- 580
							ImGui.NextColumn() -- 581
						end -- 581
						::__continue94:: -- 581
					end -- 581
					ImGui.Columns(1, false) -- 584
					ImGui.ScrollWhenDraggingOnVoid() -- 585
					if self.popupShow then -- 585
						self.popupShow = false -- 588
						ImGui.OpenPopup("MessagePopup") -- 589
					end -- 589
					ImGui.BeginPopupModal( -- 591
						"MessagePopup", -- 591
						function() return self:messagePopup() end -- 591
					) -- 591
				end -- 435
			) end -- 435
		) end -- 435
	) -- 435
end -- 368
__TS__New(ResourceDownloader) -- 596
return ____exports -- 596