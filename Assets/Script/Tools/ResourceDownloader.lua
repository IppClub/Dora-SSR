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
			self:loadPreviewImage(pkg.name) -- 235
		end -- 235
		self.isLoading = false -- 237
	end) -- 149
end -- 146
function ResourceDownloader.prototype.loadPreviewImage(self, name) -- 241
	local cachePath = Path(Content.appPath, ".cache", "preview") -- 242
	local cacheFile = Path(cachePath, name .. ".jpg") -- 243
	if Content:exist(cacheFile) then -- 243
		Cache:loadAsync(cacheFile) -- 245
		local texture = Texture2D(cacheFile) -- 246
		if texture then -- 246
			self.previewTextures:set(name, texture) -- 248
			self.previewFiles:set(name, cacheFile) -- 249
		end -- 249
		return -- 251
	end -- 251
	local imageUrl = ((config.url .. "/assets/") .. name) .. "/banner.jpg" -- 253
	local response = HttpClient:downloadAsync(imageUrl, cacheFile, 10) -- 254
	if response then -- 254
		Cache:loadAsync(cacheFile) -- 256
		local texture = Texture2D(cacheFile) -- 257
		if texture then -- 257
			self.previewTextures:set(name, texture) -- 259
			self.previewFiles:set(name, cacheFile) -- 260
		end -- 260
	else -- 260
		print("Failed to load preview image for " .. name) -- 263
	end -- 263
end -- 241
function ResourceDownloader.prototype.isDownloaded(self, name) -- 267
	return self.downloadedPackages:has(name) -- 268
end -- 267
function ResourceDownloader.prototype.downloadPackage(self, pkg) -- 271
	if self.downloadTasks:has(pkg.name) then -- 271
		return -- 273
	end -- 273
	local task = thread(function() -- 276
		self.isDownloading = true -- 277
		local downloadStatus = (zh and "正在下载：" or "Downloading: ") .. pkg.name -- 278
		local downloadPath = Path(Content.writablePath, ".download") -- 279
		Content:mkdir(downloadPath) -- 280
		local currentVersion = pkg.currentVersion or 1 -- 281
		local version = pkg.versions[currentVersion] -- 282
		local targetFile = Path(downloadPath, version.file) -- 283
		local success = HttpClient:downloadAsync( -- 285
			version.download, -- 286
			targetFile, -- 287
			30, -- 288
			function(current, total) -- 289
				if self.cancelDownload then -- 289
					return true -- 291
				end -- 291
				self.downloadProgress:set(pkg.name, {progress = current / total, status = downloadStatus}) -- 293
				return false -- 294
			end -- 289
		) -- 289
		if success then -- 289
			downloadStatus = zh and "解压中：" .. pkg.name or "Unziping: " .. pkg.name -- 299
			self.downloadProgress:set(pkg.name, {progress = 1, status = downloadStatus}) -- 300
			local unzipPath = Path(Content.writablePath, "Download", pkg.name) -- 301
			Content:remove(unzipPath) -- 302
			if Content:unzipAsync(targetFile, unzipPath) then -- 302
				Content:remove(targetFile) -- 304
				self.downloadedPackages:add(pkg.name) -- 305
				local repo = self.repos:get(pkg.name) -- 306
				if repo then -- 306
					local str = json.encode(repo) -- 308
					if str then -- 308
						Content:save( -- 310
							Path(unzipPath, "repo.json"), -- 310
							str -- 310
						) -- 310
					end -- 310
				end -- 310
				Director.postNode:emit("UpdateEntries") -- 313
			else -- 313
				Content:remove(unzipPath) -- 315
				self:showPopup(zh and "解压失败" or "Failed to unzip", zh and "无法解压文件：" .. version.file or "Failed to unzip: " .. version.file) -- 316
			end -- 316
		else -- 316
			Content:remove(targetFile) -- 322
			self:showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. version.download or "Failed to download from: " .. version.download) -- 323
		end -- 323
		self.isDownloading = false -- 329
		self.downloadProgress:delete(pkg.name) -- 330
		self.downloadTasks:delete(pkg.name) -- 331
	end) -- 276
	self.downloadTasks:set(pkg.name, task) -- 334
end -- 271
function ResourceDownloader.prototype.messagePopup(self) -- 337
	ImGui.Text(self.popupMessageTitle) -- 338
	ImGui.Separator() -- 339
	ImGui.PushTextWrapPos( -- 340
		300, -- 340
		function() -- 340
			ImGui.TextWrapped(self.popupMessage) -- 341
		end -- 340
	) -- 340
	if ImGui.Button( -- 340
		zh and "确认" or "OK", -- 343
		Vec2(300, 30) -- 343
	) then -- 343
		ImGui.CloseCurrentPopup() -- 344
	end -- 344
end -- 337
function ResourceDownloader.prototype.update(self) -- 348
	local ____App_visualSize_1 = App.visualSize -- 349
	local width = ____App_visualSize_1.width -- 349
	local height = ____App_visualSize_1.height -- 349
	local filterCategory = nil -- 350
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 351
	ImGui.SetNextWindowSize( -- 352
		Vec2(width, self.headerHeight), -- 352
		"Always" -- 352
	) -- 352
	ImGui.PushStyleVar( -- 353
		"WindowPadding", -- 353
		Vec2(10, 0), -- 353
		function() return ImGui.Begin( -- 353
			"Dora Community Header", -- 353
			windowsNoScrollFlags, -- 353
			function() -- 353
				ImGui.Dummy(Vec2(0, 0)) -- 354
				ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Resources") -- 355
				ImGui.SameLine() -- 356
				ImGui.TextDisabled("(?)") -- 357
				if ImGui.IsItemHovered() then -- 357
					ImGui.BeginTooltip(function() -- 359
						ImGui.PushTextWrapPos( -- 360
							300, -- 360
							function() -- 360
								ImGui.Text(zh and "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" or "Use this tool to download Dora SSR community resources to the `Download` directory.") -- 361
							end -- 360
						) -- 360
					end) -- 359
				end -- 359
				local padding = zh and 400 or 440 -- 365
				if width >= padding then -- 365
					ImGui.SameLine() -- 367
					ImGui.Dummy(Vec2(width - padding, 0)) -- 368
					ImGui.SameLine() -- 369
					ImGui.SetNextItemWidth((zh and -40 or -55) - 40) -- 370
					if ImGui.InputText(zh and "筛选" or "Filter", self.filterBuf, {"AutoSelectAll"}) then -- 370
						local res = string.match(self.filterBuf.text, "[^%%%.%[]+") -- 372
						self.filterText = string.lower(res or "") -- 373
					end -- 373
				else -- 373
					ImGui.SameLine() -- 376
					ImGui.Dummy(Vec2(width - (zh and 250 or 255), 0)) -- 377
				end -- 377
				ImGui.SameLine() -- 379
				if ImGui.CollapsingHeader("##option") then -- 379
					self.headerHeight = 130 -- 381
					ImGui.SetNextItemWidth(zh and -200 or -230) -- 382
					if ImGui.InputText(zh and "服务器" or "Server", url) then -- 382
						if url.text == "" then -- 382
							url.text = DefaultURL -- 385
						end -- 385
						config.url = url.text -- 387
					end -- 387
					ImGui.SameLine() -- 389
					if ImGui.Button(zh and "刷新" or "Reload") then -- 389
						local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 391
						Content:remove(packageListVersionFile) -- 392
						self:loadData() -- 393
					end -- 393
					ImGui.Separator() -- 395
				else -- 395
					self.headerHeight = 80 -- 397
				end -- 397
				ImGui.PushStyleVar( -- 399
					"WindowPadding", -- 399
					Vec2(10, 10), -- 399
					function() return ImGui.BeginTabBar( -- 399
						"categories", -- 399
						tabBarFlags, -- 399
						function() -- 399
							ImGui.BeginTabItem( -- 400
								zh and "全部" or "All", -- 400
								function() -- 400
									filterCategory = nil -- 401
								end -- 400
							) -- 400
							for ____, cat in ipairs(self.categories) do -- 403
								ImGui.BeginTabItem( -- 404
									cat, -- 404
									function() -- 404
										filterCategory = cat -- 405
									end -- 404
								) -- 404
							end -- 404
						end -- 399
					) end -- 399
				) -- 399
			end -- 353
		) end -- 353
	) -- 353
	local function matchCat(self, cat) -- 410
		return filterCategory == cat -- 410
	end -- 410
	local maxColumns = math.max( -- 411
		math.floor(width / 320), -- 411
		1 -- 411
	) -- 411
	local itemWidth = (width - 60) / maxColumns - 10 -- 412
	ImGui.SetNextWindowPos( -- 413
		Vec2(0, self.headerHeight), -- 413
		"Always", -- 413
		Vec2.zero -- 413
	) -- 413
	ImGui.SetNextWindowSize( -- 414
		Vec2(width, height - self.headerHeight - 50), -- 414
		"Always" -- 414
	) -- 414
	ImGui.PushStyleVar( -- 415
		"Alpha", -- 415
		1, -- 415
		function() return ImGui.PushStyleVar( -- 415
			"WindowPadding", -- 415
			Vec2(20, 10), -- 415
			function() return ImGui.Begin( -- 415
				"Dora Community Resources", -- 415
				windowsFlags, -- 415
				function() -- 415
					ImGui.Columns(maxColumns, false) -- 416
					for ____, pkg in ipairs(self.packages) do -- 419
						do -- 419
							local repo = self.repos:get(pkg.name) -- 420
							if not repo then -- 420
								goto __continue87 -- 421
							end -- 421
							if filterCategory ~= nil then -- 421
								if not repo.categories then -- 421
									goto __continue87 -- 423
								end -- 423
								if __TS__ArrayFind(repo.categories, matchCat) == nil then -- 423
									goto __continue87 -- 425
								end -- 425
							end -- 425
							local title = repo.title[zh and "zh" or "en"] -- 429
							if self.filterText ~= "" then -- 429
								local res = string.match( -- 432
									string.lower(title), -- 432
									self.filterText -- 432
								) -- 432
								if not res then -- 432
									goto __continue87 -- 433
								end -- 433
							end -- 433
							ImGui.TextColored(themeColor, title) -- 437
							local previewTexture = self.previewTextures:get(pkg.name) -- 440
							if previewTexture then -- 440
								local width = previewTexture.width -- 440
								local height = previewTexture.height -- 440
								local scale = (itemWidth - 30) / width -- 444
								local scaledSize = Vec2(width * scale, height * scale) -- 445
								local previewFile = self.previewFiles:get(pkg.name) -- 446
								if previewFile then -- 446
									ImGui.Dummy(Vec2.zero) -- 448
									ImGui.SameLine() -- 449
									ImGui.Image(previewFile, scaledSize) -- 450
								end -- 450
							else -- 450
								ImGui.Text(zh and "加载预览图中..." or "Loading preview...") -- 453
							end -- 453
							ImGui.TextWrapped(repo.desc[zh and "zh" or "en"]) -- 456
							ImGui.TextColored(themeColor, zh and "项目地址：" or "Repo URL:") -- 458
							ImGui.SameLine() -- 459
							if ImGui.TextLink((zh and "这里" or "here") .. "##" .. pkg.url) then -- 459
								App:openURL(pkg.url) -- 461
							end -- 461
							if ImGui.IsItemHovered() then -- 461
								ImGui.BeginTooltip(function() -- 464
									ImGui.PushTextWrapPos( -- 465
										300, -- 465
										function() -- 465
											ImGui.Text(pkg.url) -- 466
										end -- 465
									) -- 465
								end) -- 464
							end -- 464
							local currentVersion = pkg.currentVersion or 1 -- 471
							local version = pkg.versions[currentVersion] -- 472
							if type(version.updatedAt) == "number" then -- 472
								ImGui.TextColored(themeColor, zh and "同步时间：" or "Updated:") -- 474
								ImGui.SameLine() -- 475
								local dateStr = os.date("%Y-%m-%d %H:%M:%S", version.updatedAt) -- 476
								ImGui.Text(dateStr) -- 477
							end -- 477
							ImGui.TextColored(themeColor, zh and "文件大小：" or "File Size:") -- 481
							ImGui.SameLine() -- 482
							ImGui.Text(__TS__NumberToFixed(version.size / 1024 / 1024, 2) .. " MB") -- 483
							local progress = self.downloadProgress:get(pkg.name) -- 486
							if progress ~= nil then -- 486
								ImGui.ProgressBar( -- 488
									progress.progress, -- 488
									Vec2(-1, 30) -- 488
								) -- 488
								ImGui.BeginDisabled(function() -- 489
									ImGui.Button(progress.status) -- 490
								end) -- 489
							end -- 489
							if progress == nil then -- 489
								local isDownloaded = self:isDownloaded(pkg.name) -- 496
								local exeText = (zh and "运行" or "Run") .. "##run-" .. pkg.name -- 497
								local buttonText = (isDownloaded and (zh and "重新下载" or "Re-Download") or (zh and "下载" or "Download")) .. "##download-" .. pkg.name -- 498
								local deleteText = (zh and "删除" or "Delete") .. "##delete-" .. pkg.name -- 501
								local runable = repo.exe ~= false -- 502
								if self.isDownloading then -- 502
									ImGui.BeginDisabled(function() -- 504
										if runable then -- 504
											ImGui.Button(exeText) -- 506
											ImGui.SameLine() -- 507
										end -- 507
										ImGui.Button(buttonText) -- 509
										if isDownloaded then -- 509
											ImGui.SameLine() -- 511
											ImGui.Button(deleteText) -- 512
										end -- 512
									end) -- 504
								else -- 504
									if isDownloaded and runable then -- 504
										if type(repo.exe) == "table" then -- 504
											local exeList = repo.exe -- 518
											local popupId = "select-" .. pkg.name -- 519
											if ImGui.Button(exeText) then -- 519
												ImGui.OpenPopup(popupId) -- 521
											end -- 521
											ImGui.BeginPopup( -- 523
												popupId, -- 523
												function() -- 523
													for ____, entry in ipairs(exeList) do -- 524
														if ImGui.Selectable((((entry .. "##run-") .. pkg.name) .. "-") .. entry) then -- 524
															run(Path( -- 526
																Content.writablePath, -- 526
																"Download", -- 526
																pkg.name, -- 526
																entry, -- 526
																"init" -- 526
															)) -- 526
														end -- 526
													end -- 526
												end -- 523
											) -- 523
										else -- 523
											if ImGui.Button(exeText) then -- 523
												run(Path(Content.writablePath, "Download", pkg.name, "init")) -- 532
											end -- 532
										end -- 532
										ImGui.SameLine() -- 535
									end -- 535
									if ImGui.Button(buttonText) then -- 535
										self:downloadPackage(pkg) -- 538
									end -- 538
									if isDownloaded then -- 538
										ImGui.SameLine() -- 541
										if ImGui.Button(deleteText) then -- 541
											Content:remove(Path(Content.writablePath, "Download", pkg.name)) -- 543
											self.downloadedPackages:delete(pkg.name) -- 544
											Director.postNode:emit("UpdateEntries") -- 545
										end -- 545
									end -- 545
								end -- 545
							end -- 545
							if not self.isDownloading and pkg.versionNames and pkg.currentVersion then -- 545
								ImGui.SameLine() -- 552
								ImGui.SetNextItemWidth(-20) -- 553
								local changed, currentVersion = ImGui.Combo("##" .. pkg.name, pkg.currentVersion, pkg.versionNames) -- 554
								if changed then -- 554
									pkg.currentVersion = currentVersion -- 556
								end -- 556
							end -- 556
							thinSep() -- 560
							ImGui.NextColumn() -- 561
						end -- 561
						::__continue87:: -- 561
					end -- 561
					ImGui.Columns(1, false) -- 564
					ImGui.ScrollWhenDraggingOnVoid() -- 565
					if self.popupShow then -- 565
						self.popupShow = false -- 568
						ImGui.OpenPopup("MessagePopup") -- 569
					end -- 569
					ImGui.BeginPopupModal( -- 571
						"MessagePopup", -- 571
						function() return self:messagePopup() end -- 571
					) -- 571
				end -- 415
			) end -- 415
		) end -- 415
	) -- 415
end -- 348
__TS__New(ResourceDownloader) -- 576
return ____exports -- 576