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
	local Entry = require("Script.Dev.Entry") -- 101
	Entry.allClear() -- 102
	thread(function() -- 103
		Entry.enterEntryAsync({entryName = "Project", fileName = fileName}) -- 104
	end) -- 103
end -- 100
local ResourceDownloader = __TS__Class() -- 108
ResourceDownloader.name = "ResourceDownloader" -- 108
function ResourceDownloader.prototype.____constructor(self) -- 128
	self.packages = {} -- 109
	self.repos = __TS__New(Map) -- 110
	self.downloadProgress = __TS__New(Map) -- 111
	self.downloadTasks = __TS__New(Map) -- 112
	self.popupMessageTitle = "" -- 113
	self.popupMessage = "" -- 114
	self.popupShow = false -- 115
	self.cancelDownload = false -- 116
	self.isDownloading = false -- 117
	self.previewTextures = __TS__New(Map) -- 119
	self.previewFiles = __TS__New(Map) -- 120
	self.downloadedPackages = __TS__New(Set) -- 121
	self.isLoading = false -- 122
	self.filterBuf = Buffer(20) -- 123
	self.filterText = "" -- 124
	self.categories = {} -- 125
	self.headerHeight = 80 -- 126
	self.node = Node() -- 129
	self.node:schedule(function() -- 130
		self:update() -- 131
		return false -- 132
	end) -- 130
	self.node:onCleanup(function() -- 134
		self.cancelDownload = true -- 135
	end) -- 134
	self:loadData() -- 137
end -- 128
function ResourceDownloader.prototype.showPopup(self, title, msg) -- 140
	self.popupMessageTitle = title -- 141
	self.popupMessage = msg -- 142
	self.popupShow = true -- 143
end -- 140
function ResourceDownloader.prototype.loadData(self) -- 146
	if self.isLoading then -- 146
		return -- 147
	end -- 147
	self.isLoading = true -- 148
	thread(function() -- 149
		local reload = false -- 150
		local versionResponse = HttpClient:getAsync(config.url .. "/api/v1/package-list-version") -- 151
		local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 152
		if versionResponse then -- 152
			local version = json.decode(versionResponse) -- 154
			local packageListVersion = version -- 155
			if Content:exist(packageListVersionFile) then -- 155
				local oldVersion = json.decode(Content:load(packageListVersionFile)) -- 157
				local oldPackageListVersion = oldVersion -- 158
				if packageListVersion.version ~= oldPackageListVersion.version then -- 158
					reload = true -- 160
				end -- 160
			else -- 160
				reload = true -- 163
			end -- 163
		end -- 163
		if reload then -- 163
			self.categories = {} -- 167
			self.packages = {} -- 168
			self.repos = __TS__New(Map) -- 169
			self.previewTextures:clear() -- 170
			self.previewFiles:clear() -- 171
			local cachePath = Path(Content.appPath, ".cache", "preview") -- 172
			Content:remove(cachePath) -- 173
		end -- 173
		local cachePath = Path(Content.appPath, ".cache", "preview") -- 176
		Content:mkdir(cachePath) -- 177
		if reload and versionResponse then -- 177
			Content:save(packageListVersionFile, versionResponse) -- 179
		end -- 179
		local packagesFile = Path(cachePath, "packages.json") -- 181
		if Content:exist(packagesFile) then -- 181
			local packages = json.decode(Content:load(packagesFile)) -- 183
			self.packages = packages -- 184
		else -- 184
			local packagesResponse = HttpClient:getAsync(config.url .. "/api/v1/packages") -- 186
			if packagesResponse then -- 186
				local packages = json.decode(packagesResponse) -- 189
				self.packages = packages -- 190
				Content:save(packagesFile, packagesResponse) -- 191
			end -- 191
		end -- 191
		for ____, pkg in ipairs(self.packages) do -- 194
			pkg.currentVersion = 1 -- 195
			pkg.versionNames = __TS__ArrayMap( -- 196
				pkg.versions, -- 196
				function(____, v) -- 196
					return v.tag == "" and "No Tag" or v.tag -- 197
				end -- 196
			) -- 196
		end -- 196
		local catSet = __TS__New(Set) -- 202
		local function loadRepos(repos) -- 203
			for ____, repo in ipairs(repos) do -- 204
				self.repos:set(repo.name, repo) -- 205
				if repo.categories then -- 205
					for ____, cat in ipairs(repo.categories) do -- 207
						catSet:add(cat) -- 208
					end -- 208
				end -- 208
			end -- 208
		end -- 203
		local reposFile = Path(cachePath, "repos.json") -- 213
		if Content:exist(reposFile) then -- 213
			local repos = json.decode(Content:load(reposFile)) -- 215
			loadRepos(repos) -- 216
		else -- 216
			local reposResponse = HttpClient:getAsync(config.url .. "/assets/repos.json") -- 218
			if reposResponse then -- 218
				local repos = json.decode(reposResponse) -- 220
				loadRepos(repos) -- 221
				Content:save(reposFile, reposResponse) -- 222
			end -- 222
		end -- 222
		for ____, cat in __TS__Iterator(catSet) do -- 225
			local ____self_categories_0 = self.categories -- 225
			____self_categories_0[#____self_categories_0 + 1] = cat -- 226
		end -- 226
		for ____, pkg in ipairs(self.packages) do -- 230
			local downloadPath = Path(Content.writablePath, "Download", pkg.name) -- 231
			if Content:exist(downloadPath) then -- 231
				self.downloadedPackages:add(pkg.name) -- 233
			end -- 233
		end -- 233
		for ____, pkg in ipairs(self.packages) do -- 236
			self:loadPreviewImage(pkg.name) -- 237
		end -- 237
		self.isLoading = false -- 239
	end) -- 149
end -- 146
function ResourceDownloader.prototype.loadPreviewImage(self, name) -- 243
	local cachePath = Path(Content.appPath, ".cache", "preview") -- 244
	local cacheFile = Path(cachePath, name .. ".jpg") -- 245
	if Content:exist(cacheFile) then -- 245
		Cache:loadAsync(cacheFile) -- 247
		local texture = Texture2D(cacheFile) -- 248
		if texture then -- 248
			self.previewTextures:set(name, texture) -- 250
			self.previewFiles:set(name, cacheFile) -- 251
		end -- 251
		return -- 253
	end -- 253
	local imageUrl = ((config.url .. "/assets/") .. name) .. "/banner.jpg" -- 255
	local response = HttpClient:downloadAsync(imageUrl, cacheFile, 10) -- 256
	if response then -- 256
		Cache:loadAsync(cacheFile) -- 258
		local texture = Texture2D(cacheFile) -- 259
		if texture then -- 259
			self.previewTextures:set(name, texture) -- 261
			self.previewFiles:set(name, cacheFile) -- 262
		end -- 262
	else -- 262
		print("Failed to load preview image for " .. name) -- 265
	end -- 265
end -- 243
function ResourceDownloader.prototype.isDownloaded(self, name) -- 269
	return self.downloadedPackages:has(name) -- 270
end -- 269
function ResourceDownloader.prototype.downloadPackage(self, pkg) -- 273
	if self.downloadTasks:has(pkg.name) then -- 273
		return -- 275
	end -- 275
	local task = thread(function() -- 278
		self.isDownloading = true -- 279
		local downloadStatus = (zh and "正在下载：" or "Downloading: ") .. pkg.name -- 280
		local downloadPath = Path(Content.writablePath, ".download") -- 281
		Content:mkdir(downloadPath) -- 282
		local currentVersion = pkg.currentVersion or 1 -- 283
		local version = pkg.versions[currentVersion] -- 284
		local targetFile = Path(downloadPath, version.file) -- 285
		local success = HttpClient:downloadAsync( -- 287
			version.download, -- 288
			targetFile, -- 289
			30, -- 290
			function(current, total) -- 291
				if self.cancelDownload then -- 291
					return true -- 293
				end -- 293
				self.downloadProgress:set(pkg.name, {progress = current / total, status = downloadStatus}) -- 295
				return false -- 296
			end -- 291
		) -- 291
		if success then -- 291
			downloadStatus = zh and "解压中：" .. pkg.name or "Unziping: " .. pkg.name -- 301
			self.downloadProgress:set(pkg.name, {progress = 1, status = downloadStatus}) -- 302
			local unzipPath = Path(Content.writablePath, "Download", pkg.name) -- 303
			Content:remove(unzipPath) -- 304
			if Content:unzipAsync(targetFile, unzipPath) then -- 304
				Content:remove(targetFile) -- 306
				self.downloadedPackages:add(pkg.name) -- 307
				local repo = self.repos:get(pkg.name) -- 308
				if repo then -- 308
					local str = json.encode(repo) -- 310
					if str then -- 310
						if Content:mkdir(Path(unzipPath, ".dora")) then -- 310
							Content:save( -- 313
								Path(unzipPath, ".dora", "repo.json"), -- 313
								str -- 313
							) -- 313
							local previewFile = self.previewFiles:get(pkg.name) -- 314
							if previewFile and Content:exist(previewFile) then -- 314
								Content:copy( -- 316
									previewFile, -- 316
									Path(unzipPath, ".dora", "banner.jpg") -- 316
								) -- 316
							end -- 316
						end -- 316
					end -- 316
				end -- 316
				Director.postNode:emit("UpdateEntries") -- 321
			else -- 321
				Content:remove(unzipPath) -- 323
				self:showPopup(zh and "解压失败" or "Failed to unzip", zh and "无法解压文件：" .. version.file or "Failed to unzip: " .. version.file) -- 324
			end -- 324
		else -- 324
			Content:remove(targetFile) -- 330
			self:showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. version.download or "Failed to download from: " .. version.download) -- 331
		end -- 331
		self.isDownloading = false -- 337
		self.downloadProgress:delete(pkg.name) -- 338
		self.downloadTasks:delete(pkg.name) -- 339
	end) -- 278
	self.downloadTasks:set(pkg.name, task) -- 342
end -- 273
function ResourceDownloader.prototype.messagePopup(self) -- 345
	ImGui.Text(self.popupMessageTitle) -- 346
	ImGui.Separator() -- 347
	ImGui.PushTextWrapPos( -- 348
		300, -- 348
		function() -- 348
			ImGui.TextWrapped(self.popupMessage) -- 349
		end -- 348
	) -- 348
	if ImGui.Button( -- 348
		zh and "确认" or "OK", -- 351
		Vec2(300, 30) -- 351
	) then -- 351
		ImGui.CloseCurrentPopup() -- 352
	end -- 352
end -- 345
function ResourceDownloader.prototype.update(self) -- 356
	local ____App_visualSize_1 = App.visualSize -- 357
	local width = ____App_visualSize_1.width -- 357
	local height = ____App_visualSize_1.height -- 357
	local filterCategory = nil -- 358
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 359
	ImGui.SetNextWindowSize( -- 360
		Vec2(width, self.headerHeight), -- 360
		"Always" -- 360
	) -- 360
	ImGui.PushStyleVar( -- 361
		"WindowPadding", -- 361
		Vec2(10, 0), -- 361
		function() return ImGui.Begin( -- 361
			"Dora Community Header", -- 361
			windowsNoScrollFlags, -- 361
			function() -- 361
				ImGui.Dummy(Vec2(0, 0)) -- 362
				ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Resources") -- 363
				ImGui.SameLine() -- 364
				ImGui.TextDisabled("(?)") -- 365
				if ImGui.IsItemHovered() then -- 365
					ImGui.BeginTooltip(function() -- 367
						ImGui.PushTextWrapPos( -- 368
							300, -- 368
							function() -- 368
								ImGui.Text(zh and "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" or "Use this tool to download Dora SSR community resources to the `Download` directory.") -- 369
							end -- 368
						) -- 368
					end) -- 367
				end -- 367
				local padding = zh and 400 or 440 -- 373
				if width >= padding then -- 373
					ImGui.SameLine() -- 375
					ImGui.Dummy(Vec2(width - padding, 0)) -- 376
					ImGui.SameLine() -- 377
					ImGui.SetNextItemWidth((zh and -40 or -55) - 40) -- 378
					if ImGui.InputText(zh and "筛选" or "Filter", self.filterBuf, {"AutoSelectAll"}) then -- 378
						local res = string.match(self.filterBuf.text, "[^%%%.%[]+") -- 380
						self.filterText = string.lower(res or "") -- 381
					end -- 381
				else -- 381
					ImGui.SameLine() -- 384
					ImGui.Dummy(Vec2(width - (zh and 250 or 255), 0)) -- 385
				end -- 385
				ImGui.SameLine() -- 387
				if ImGui.CollapsingHeader("##option") then -- 387
					self.headerHeight = 130 -- 389
					ImGui.SetNextItemWidth(zh and -200 or -230) -- 390
					if ImGui.InputText(zh and "服务器" or "Server", url) then -- 390
						if url.text == "" then -- 390
							url.text = DefaultURL -- 393
						end -- 393
						config.url = url.text -- 395
					end -- 395
					ImGui.SameLine() -- 397
					if ImGui.Button(zh and "刷新" or "Reload") then -- 397
						local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 399
						Content:remove(packageListVersionFile) -- 400
						self:loadData() -- 401
					end -- 401
					ImGui.Separator() -- 403
				else -- 403
					self.headerHeight = 80 -- 405
				end -- 405
				ImGui.PushStyleVar( -- 407
					"WindowPadding", -- 407
					Vec2(10, 10), -- 407
					function() return ImGui.BeginTabBar( -- 407
						"categories", -- 407
						tabBarFlags, -- 407
						function() -- 407
							ImGui.BeginTabItem( -- 408
								zh and "全部" or "All", -- 408
								function() -- 408
									filterCategory = nil -- 409
								end -- 408
							) -- 408
							for ____, cat in ipairs(self.categories) do -- 411
								ImGui.BeginTabItem( -- 412
									cat, -- 412
									function() -- 412
										filterCategory = cat -- 413
									end -- 412
								) -- 412
							end -- 412
						end -- 407
					) end -- 407
				) -- 407
			end -- 361
		) end -- 361
	) -- 361
	local function matchCat(self, cat) -- 418
		return filterCategory == cat -- 418
	end -- 418
	local maxColumns = math.max( -- 419
		math.floor(width / 320), -- 419
		1 -- 419
	) -- 419
	local itemWidth = (width - 60) / maxColumns - 10 -- 420
	ImGui.SetNextWindowPos( -- 421
		Vec2(0, self.headerHeight), -- 421
		"Always", -- 421
		Vec2.zero -- 421
	) -- 421
	ImGui.SetNextWindowSize( -- 422
		Vec2(width, height - self.headerHeight - 50), -- 422
		"Always" -- 422
	) -- 422
	ImGui.PushStyleVar( -- 423
		"Alpha", -- 423
		1, -- 423
		function() return ImGui.PushStyleVar( -- 423
			"WindowPadding", -- 423
			Vec2(20, 10), -- 423
			function() return ImGui.Begin( -- 423
				"Dora Community Resources", -- 423
				windowsFlags, -- 423
				function() -- 423
					ImGui.Columns(maxColumns, false) -- 424
					for ____, pkg in ipairs(self.packages) do -- 427
						do -- 427
							local repo = self.repos:get(pkg.name) -- 428
							if not repo then -- 428
								goto __continue91 -- 429
							end -- 429
							if filterCategory ~= nil then -- 429
								if not repo.categories then -- 429
									goto __continue91 -- 431
								end -- 431
								if __TS__ArrayFind(repo.categories, matchCat) == nil then -- 431
									goto __continue91 -- 433
								end -- 433
							end -- 433
							local title = repo.title[zh and "zh" or "en"] -- 437
							if self.filterText ~= "" then -- 437
								local res = string.match( -- 440
									string.lower(title), -- 440
									self.filterText -- 440
								) -- 440
								if not res then -- 440
									goto __continue91 -- 441
								end -- 441
							end -- 441
							ImGui.TextColored(themeColor, title) -- 445
							local previewTexture = self.previewTextures:get(pkg.name) -- 448
							if previewTexture then -- 448
								local width = previewTexture.width -- 448
								local height = previewTexture.height -- 448
								local scale = (itemWidth - 30) / width -- 452
								local scaledSize = Vec2(width * scale, height * scale) -- 453
								local previewFile = self.previewFiles:get(pkg.name) -- 454
								if previewFile then -- 454
									ImGui.Dummy(Vec2.zero) -- 456
									ImGui.SameLine() -- 457
									ImGui.Image(previewFile, scaledSize) -- 458
								end -- 458
							else -- 458
								ImGui.Text(zh and "加载预览图中..." or "Loading preview...") -- 461
							end -- 461
							ImGui.TextWrapped(repo.desc[zh and "zh" or "en"]) -- 464
							ImGui.TextColored(themeColor, zh and "项目地址：" or "Repo URL:") -- 466
							ImGui.SameLine() -- 467
							if ImGui.TextLink((zh and "这里" or "here") .. "##" .. pkg.url) then -- 467
								App:openURL(pkg.url) -- 469
							end -- 469
							if ImGui.IsItemHovered() then -- 469
								ImGui.BeginTooltip(function() -- 472
									ImGui.PushTextWrapPos( -- 473
										300, -- 473
										function() -- 473
											ImGui.Text(pkg.url) -- 474
										end -- 473
									) -- 473
								end) -- 472
							end -- 472
							local currentVersion = pkg.currentVersion or 1 -- 479
							local version = pkg.versions[currentVersion] -- 480
							if type(version.updatedAt) == "number" then -- 480
								ImGui.TextColored(themeColor, zh and "同步时间：" or "Updated:") -- 482
								ImGui.SameLine() -- 483
								local dateStr = os.date("%Y-%m-%d %H:%M:%S", version.updatedAt) -- 484
								ImGui.Text(dateStr) -- 485
							end -- 485
							ImGui.TextColored(themeColor, zh and "文件大小：" or "File Size:") -- 489
							ImGui.SameLine() -- 490
							ImGui.Text(__TS__NumberToFixed(version.size / 1024 / 1024, 2) .. " MB") -- 491
							local progress = self.downloadProgress:get(pkg.name) -- 494
							if progress ~= nil then -- 494
								ImGui.ProgressBar( -- 496
									progress.progress, -- 496
									Vec2(-1, 30) -- 496
								) -- 496
								ImGui.BeginDisabled(function() -- 497
									ImGui.Button(progress.status) -- 498
								end) -- 497
							end -- 497
							if progress == nil then -- 497
								local isDownloaded = self:isDownloaded(pkg.name) -- 504
								local exeText = (zh and "测试" or "Test") .. "##test-" .. pkg.name -- 505
								local buttonText = (isDownloaded and (zh and "重新下载" or "Re-Download") or (zh and "下载" or "Download")) .. "##download-" .. pkg.name -- 506
								local deleteText = (zh and "删除" or "Delete") .. "##delete-" .. pkg.name -- 509
								local runable = repo.exe ~= false -- 510
								if self.isDownloading then -- 510
									ImGui.BeginDisabled(function() -- 512
										if runable then -- 512
											ImGui.Button(exeText) -- 514
											ImGui.SameLine() -- 515
										end -- 515
										ImGui.Button(buttonText) -- 517
										if isDownloaded then -- 517
											ImGui.SameLine() -- 519
											ImGui.Button(deleteText) -- 520
										end -- 520
									end) -- 512
								else -- 512
									if isDownloaded and runable then -- 512
										if type(repo.exe) == "table" then -- 512
											local exeList = repo.exe -- 526
											local popupId = "select-" .. pkg.name -- 527
											if ImGui.Button(exeText) then -- 527
												ImGui.OpenPopup(popupId) -- 529
											end -- 529
											ImGui.BeginPopup( -- 531
												popupId, -- 531
												function() -- 531
													for ____, entry in ipairs(exeList) do -- 532
														if ImGui.Selectable((((entry .. "##run-") .. pkg.name) .. "-") .. entry) then -- 532
															run(Path( -- 534
																Content.writablePath, -- 534
																"Download", -- 534
																pkg.name, -- 534
																entry, -- 534
																"init" -- 534
															)) -- 534
														end -- 534
													end -- 534
												end -- 531
											) -- 531
										else -- 531
											if ImGui.Button(exeText) then -- 531
												run(Path(Content.writablePath, "Download", pkg.name, "init")) -- 540
											end -- 540
										end -- 540
										ImGui.SameLine() -- 543
									end -- 543
									if ImGui.Button(buttonText) then -- 543
										self:downloadPackage(pkg) -- 546
									end -- 546
									if isDownloaded then -- 546
										ImGui.SameLine() -- 549
										if ImGui.Button(deleteText) then -- 549
											Content:remove(Path(Content.writablePath, "Download", pkg.name)) -- 551
											self.downloadedPackages:delete(pkg.name) -- 552
											Director.postNode:emit("UpdateEntries") -- 553
										end -- 553
									end -- 553
								end -- 553
							end -- 553
							if not self.isDownloading and pkg.versionNames and pkg.currentVersion then -- 553
								ImGui.SameLine() -- 560
								ImGui.SetNextItemWidth(-20) -- 561
								local changed, currentVersion = ImGui.Combo("##" .. pkg.name, pkg.currentVersion, pkg.versionNames) -- 562
								if changed then -- 562
									pkg.currentVersion = currentVersion -- 564
								end -- 564
							end -- 564
							thinSep() -- 568
							ImGui.NextColumn() -- 569
						end -- 569
						::__continue91:: -- 569
					end -- 569
					ImGui.Columns(1, false) -- 572
					ImGui.ScrollWhenDraggingOnVoid() -- 573
					if self.popupShow then -- 573
						self.popupShow = false -- 576
						ImGui.OpenPopup("MessagePopup") -- 577
					end -- 577
					ImGui.BeginPopupModal( -- 579
						"MessagePopup", -- 579
						function() return self:messagePopup() end -- 579
					) -- 579
				end -- 423
			) end -- 423
		) end -- 423
	) -- 423
end -- 356
__TS__New(ResourceDownloader) -- 584
return ____exports -- 584