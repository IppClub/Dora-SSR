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
						Content:save( -- 312
							Path(unzipPath, "repo.json"), -- 312
							str -- 312
						) -- 312
					end -- 312
				end -- 312
				Director.postNode:emit("UpdateEntries") -- 315
			else -- 315
				Content:remove(unzipPath) -- 317
				self:showPopup(zh and "解压失败" or "Failed to unzip", zh and "无法解压文件：" .. version.file or "Failed to unzip: " .. version.file) -- 318
			end -- 318
		else -- 318
			Content:remove(targetFile) -- 324
			self:showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. version.download or "Failed to download from: " .. version.download) -- 325
		end -- 325
		self.isDownloading = false -- 331
		self.downloadProgress:delete(pkg.name) -- 332
		self.downloadTasks:delete(pkg.name) -- 333
	end) -- 278
	self.downloadTasks:set(pkg.name, task) -- 336
end -- 273
function ResourceDownloader.prototype.messagePopup(self) -- 339
	ImGui.Text(self.popupMessageTitle) -- 340
	ImGui.Separator() -- 341
	ImGui.PushTextWrapPos( -- 342
		300, -- 342
		function() -- 342
			ImGui.TextWrapped(self.popupMessage) -- 343
		end -- 342
	) -- 342
	if ImGui.Button( -- 342
		zh and "确认" or "OK", -- 345
		Vec2(300, 30) -- 345
	) then -- 345
		ImGui.CloseCurrentPopup() -- 346
	end -- 346
end -- 339
function ResourceDownloader.prototype.update(self) -- 350
	local ____App_visualSize_1 = App.visualSize -- 351
	local width = ____App_visualSize_1.width -- 351
	local height = ____App_visualSize_1.height -- 351
	local filterCategory = nil -- 352
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 353
	ImGui.SetNextWindowSize( -- 354
		Vec2(width, self.headerHeight), -- 354
		"Always" -- 354
	) -- 354
	ImGui.PushStyleVar( -- 355
		"WindowPadding", -- 355
		Vec2(10, 0), -- 355
		function() return ImGui.Begin( -- 355
			"Dora Community Header", -- 355
			windowsNoScrollFlags, -- 355
			function() -- 355
				ImGui.Dummy(Vec2(0, 0)) -- 356
				ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Resources") -- 357
				ImGui.SameLine() -- 358
				ImGui.TextDisabled("(?)") -- 359
				if ImGui.IsItemHovered() then -- 359
					ImGui.BeginTooltip(function() -- 361
						ImGui.PushTextWrapPos( -- 362
							300, -- 362
							function() -- 362
								ImGui.Text(zh and "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" or "Use this tool to download Dora SSR community resources to the `Download` directory.") -- 363
							end -- 362
						) -- 362
					end) -- 361
				end -- 361
				local padding = zh and 400 or 440 -- 367
				if width >= padding then -- 367
					ImGui.SameLine() -- 369
					ImGui.Dummy(Vec2(width - padding, 0)) -- 370
					ImGui.SameLine() -- 371
					ImGui.SetNextItemWidth((zh and -40 or -55) - 40) -- 372
					if ImGui.InputText(zh and "筛选" or "Filter", self.filterBuf, {"AutoSelectAll"}) then -- 372
						local res = string.match(self.filterBuf.text, "[^%%%.%[]+") -- 374
						self.filterText = string.lower(res or "") -- 375
					end -- 375
				else -- 375
					ImGui.SameLine() -- 378
					ImGui.Dummy(Vec2(width - (zh and 250 or 255), 0)) -- 379
				end -- 379
				ImGui.SameLine() -- 381
				if ImGui.CollapsingHeader("##option") then -- 381
					self.headerHeight = 130 -- 383
					ImGui.SetNextItemWidth(zh and -200 or -230) -- 384
					if ImGui.InputText(zh and "服务器" or "Server", url) then -- 384
						if url.text == "" then -- 384
							url.text = DefaultURL -- 387
						end -- 387
						config.url = url.text -- 389
					end -- 389
					ImGui.SameLine() -- 391
					if ImGui.Button(zh and "刷新" or "Reload") then -- 391
						local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 393
						Content:remove(packageListVersionFile) -- 394
						self:loadData() -- 395
					end -- 395
					ImGui.Separator() -- 397
				else -- 397
					self.headerHeight = 80 -- 399
				end -- 399
				ImGui.PushStyleVar( -- 401
					"WindowPadding", -- 401
					Vec2(10, 10), -- 401
					function() return ImGui.BeginTabBar( -- 401
						"categories", -- 401
						tabBarFlags, -- 401
						function() -- 401
							ImGui.BeginTabItem( -- 402
								zh and "全部" or "All", -- 402
								function() -- 402
									filterCategory = nil -- 403
								end -- 402
							) -- 402
							for ____, cat in ipairs(self.categories) do -- 405
								ImGui.BeginTabItem( -- 406
									cat, -- 406
									function() -- 406
										filterCategory = cat -- 407
									end -- 406
								) -- 406
							end -- 406
						end -- 401
					) end -- 401
				) -- 401
			end -- 355
		) end -- 355
	) -- 355
	local function matchCat(self, cat) -- 412
		return filterCategory == cat -- 412
	end -- 412
	local maxColumns = math.max( -- 413
		math.floor(width / 320), -- 413
		1 -- 413
	) -- 413
	local itemWidth = (width - 60) / maxColumns - 10 -- 414
	ImGui.SetNextWindowPos( -- 415
		Vec2(0, self.headerHeight), -- 415
		"Always", -- 415
		Vec2.zero -- 415
	) -- 415
	ImGui.SetNextWindowSize( -- 416
		Vec2(width, height - self.headerHeight - 50), -- 416
		"Always" -- 416
	) -- 416
	ImGui.PushStyleVar( -- 417
		"Alpha", -- 417
		1, -- 417
		function() return ImGui.PushStyleVar( -- 417
			"WindowPadding", -- 417
			Vec2(20, 10), -- 417
			function() return ImGui.Begin( -- 417
				"Dora Community Resources", -- 417
				windowsFlags, -- 417
				function() -- 417
					ImGui.Columns(maxColumns, false) -- 418
					for ____, pkg in ipairs(self.packages) do -- 421
						do -- 421
							local repo = self.repos:get(pkg.name) -- 422
							if not repo then -- 422
								goto __continue89 -- 423
							end -- 423
							if filterCategory ~= nil then -- 423
								if not repo.categories then -- 423
									goto __continue89 -- 425
								end -- 425
								if __TS__ArrayFind(repo.categories, matchCat) == nil then -- 425
									goto __continue89 -- 427
								end -- 427
							end -- 427
							local title = repo.title[zh and "zh" or "en"] -- 431
							if self.filterText ~= "" then -- 431
								local res = string.match( -- 434
									string.lower(title), -- 434
									self.filterText -- 434
								) -- 434
								if not res then -- 434
									goto __continue89 -- 435
								end -- 435
							end -- 435
							ImGui.TextColored(themeColor, title) -- 439
							local previewTexture = self.previewTextures:get(pkg.name) -- 442
							if previewTexture then -- 442
								local width = previewTexture.width -- 442
								local height = previewTexture.height -- 442
								local scale = (itemWidth - 30) / width -- 446
								local scaledSize = Vec2(width * scale, height * scale) -- 447
								local previewFile = self.previewFiles:get(pkg.name) -- 448
								if previewFile then -- 448
									ImGui.Dummy(Vec2.zero) -- 450
									ImGui.SameLine() -- 451
									ImGui.Image(previewFile, scaledSize) -- 452
								end -- 452
							else -- 452
								ImGui.Text(zh and "加载预览图中..." or "Loading preview...") -- 455
							end -- 455
							ImGui.TextWrapped(repo.desc[zh and "zh" or "en"]) -- 458
							ImGui.TextColored(themeColor, zh and "项目地址：" or "Repo URL:") -- 460
							ImGui.SameLine() -- 461
							if ImGui.TextLink((zh and "这里" or "here") .. "##" .. pkg.url) then -- 461
								App:openURL(pkg.url) -- 463
							end -- 463
							if ImGui.IsItemHovered() then -- 463
								ImGui.BeginTooltip(function() -- 466
									ImGui.PushTextWrapPos( -- 467
										300, -- 467
										function() -- 467
											ImGui.Text(pkg.url) -- 468
										end -- 467
									) -- 467
								end) -- 466
							end -- 466
							local currentVersion = pkg.currentVersion or 1 -- 473
							local version = pkg.versions[currentVersion] -- 474
							if type(version.updatedAt) == "number" then -- 474
								ImGui.TextColored(themeColor, zh and "同步时间：" or "Updated:") -- 476
								ImGui.SameLine() -- 477
								local dateStr = os.date("%Y-%m-%d %H:%M:%S", version.updatedAt) -- 478
								ImGui.Text(dateStr) -- 479
							end -- 479
							ImGui.TextColored(themeColor, zh and "文件大小：" or "File Size:") -- 483
							ImGui.SameLine() -- 484
							ImGui.Text(__TS__NumberToFixed(version.size / 1024 / 1024, 2) .. " MB") -- 485
							local progress = self.downloadProgress:get(pkg.name) -- 488
							if progress ~= nil then -- 488
								ImGui.ProgressBar( -- 490
									progress.progress, -- 490
									Vec2(-1, 30) -- 490
								) -- 490
								ImGui.BeginDisabled(function() -- 491
									ImGui.Button(progress.status) -- 492
								end) -- 491
							end -- 491
							if progress == nil then -- 491
								local isDownloaded = self:isDownloaded(pkg.name) -- 498
								local exeText = (zh and "运行" or "Run") .. "##run-" .. pkg.name -- 499
								local buttonText = (isDownloaded and (zh and "重新下载" or "Re-Download") or (zh and "下载" or "Download")) .. "##download-" .. pkg.name -- 500
								local deleteText = (zh and "删除" or "Delete") .. "##delete-" .. pkg.name -- 503
								local runable = repo.exe ~= false -- 504
								if self.isDownloading then -- 504
									ImGui.BeginDisabled(function() -- 506
										if runable then -- 506
											ImGui.Button(exeText) -- 508
											ImGui.SameLine() -- 509
										end -- 509
										ImGui.Button(buttonText) -- 511
										if isDownloaded then -- 511
											ImGui.SameLine() -- 513
											ImGui.Button(deleteText) -- 514
										end -- 514
									end) -- 506
								else -- 506
									if isDownloaded and runable then -- 506
										if type(repo.exe) == "table" then -- 506
											local exeList = repo.exe -- 520
											local popupId = "select-" .. pkg.name -- 521
											if ImGui.Button(exeText) then -- 521
												ImGui.OpenPopup(popupId) -- 523
											end -- 523
											ImGui.BeginPopup( -- 525
												popupId, -- 525
												function() -- 525
													for ____, entry in ipairs(exeList) do -- 526
														if ImGui.Selectable((((entry .. "##run-") .. pkg.name) .. "-") .. entry) then -- 526
															run(Path( -- 528
																Content.writablePath, -- 528
																"Download", -- 528
																pkg.name, -- 528
																entry, -- 528
																"init" -- 528
															)) -- 528
														end -- 528
													end -- 528
												end -- 525
											) -- 525
										else -- 525
											if ImGui.Button(exeText) then -- 525
												run(Path(Content.writablePath, "Download", pkg.name, "init")) -- 534
											end -- 534
										end -- 534
										ImGui.SameLine() -- 537
									end -- 537
									if ImGui.Button(buttonText) then -- 537
										self:downloadPackage(pkg) -- 540
									end -- 540
									if isDownloaded then -- 540
										ImGui.SameLine() -- 543
										if ImGui.Button(deleteText) then -- 543
											Content:remove(Path(Content.writablePath, "Download", pkg.name)) -- 545
											self.downloadedPackages:delete(pkg.name) -- 546
											Director.postNode:emit("UpdateEntries") -- 547
										end -- 547
									end -- 547
								end -- 547
							end -- 547
							if not self.isDownloading and pkg.versionNames and pkg.currentVersion then -- 547
								ImGui.SameLine() -- 554
								ImGui.SetNextItemWidth(-20) -- 555
								local changed, currentVersion = ImGui.Combo("##" .. pkg.name, pkg.currentVersion, pkg.versionNames) -- 556
								if changed then -- 556
									pkg.currentVersion = currentVersion -- 558
								end -- 558
							end -- 558
							thinSep() -- 562
							ImGui.NextColumn() -- 563
						end -- 563
						::__continue89:: -- 563
					end -- 563
					ImGui.Columns(1, false) -- 566
					ImGui.ScrollWhenDraggingOnVoid() -- 567
					if self.popupShow then -- 567
						self.popupShow = false -- 570
						ImGui.OpenPopup("MessagePopup") -- 571
					end -- 571
					ImGui.BeginPopupModal( -- 573
						"MessagePopup", -- 573
						function() return self:messagePopup() end -- 573
					) -- 573
				end -- 417
			) end -- 417
		) end -- 417
	) -- 417
end -- 350
__TS__New(ResourceDownloader) -- 578
return ____exports -- 578