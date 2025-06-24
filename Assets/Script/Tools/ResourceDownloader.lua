-- [ts]: ResourceDownloader.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Set = ____lualib.Set -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__Iterator = ____lualib.__TS__Iterator -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
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
local GitPullOrCloneAsync = ____Dora.GitPullOrCloneAsync -- 2
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
	zh = res ~= nil and ImGui.IsFontLoaded() -- 26
end -- 26
local windowsNoScrollFlags = { -- 64
	"NoMove", -- 65
	"NoCollapse", -- 66
	"NoResize", -- 67
	"NoDecoration", -- 68
	"NoNav", -- 69
	"NoBringToFrontOnFocus" -- 70
} -- 70
local windowsFlags = { -- 73
	"NoMove", -- 74
	"NoCollapse", -- 75
	"NoResize", -- 76
	"NoDecoration", -- 77
	"NoNav", -- 78
	"AlwaysVerticalScrollbar", -- 79
	"NoBringToFrontOnFocus" -- 80
} -- 80
local tabBarFlags = {"FittingPolicyScroll", "DrawSelectedOverline", "NoCloseWithMiddleMouseButton", "TabListPopupButton"} -- 83
local syncWindowFlags = {"NoResize", "NoMove"} -- 90
local themeColor = App.themeColor -- 95
local function sep() -- 97
	return ImGui.SeparatorText("") -- 97
end -- 97
local function thinSep() -- 98
	return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 98
end -- 98
local ResourceDownloader = __TS__Class() -- 100
ResourceDownloader.name = "ResourceDownloader" -- 100
function ResourceDownloader.prototype.____constructor(self) -- 123
	self.packages = {} -- 101
	self.repos = __TS__New(Map) -- 102
	self.downloadProgress = __TS__New(Map) -- 103
	self.downloadTasks = __TS__New(Map) -- 104
	self.popupMessageTitle = "" -- 105
	self.popupMessage = "" -- 106
	self.popupShow = false -- 107
	self.cancelDownload = false -- 108
	self.isDownloading = false -- 109
	self.previewTextures = __TS__New(Map) -- 111
	self.previewFiles = __TS__New(Map) -- 112
	self.downloadedPackages = __TS__New(Set) -- 113
	self.isLoading = false -- 114
	self.filterBuf = Buffer(20) -- 115
	self.filterText = "" -- 116
	self.categories = {} -- 117
	self.headerHeight = 80 -- 118
	self.cloneURL = Buffer(1024) -- 119
	self.syncing = false -- 120
	self.gitProgress = "" -- 121
	self.node = Node() -- 124
	self.node:schedule(function() -- 125
		self:update() -- 126
		return false -- 127
	end) -- 125
	self.node:onCleanup(function() -- 129
		self.cancelDownload = true -- 130
	end) -- 129
	self:loadData() -- 132
end -- 123
function ResourceDownloader.prototype.showPopup(self, title, msg) -- 135
	self.popupMessageTitle = title -- 136
	self.popupMessage = msg -- 137
	self.popupShow = true -- 138
end -- 135
function ResourceDownloader.prototype.loadData(self) -- 141
	if self.isLoading then -- 141
		return -- 142
	end -- 142
	self.isLoading = true -- 143
	thread(function() -- 144
		local reload = false -- 145
		local versionResponse = HttpClient:getAsync(config.url .. "/api/v1/package-list-version") -- 146
		local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 147
		if versionResponse then -- 147
			local version = json.load(versionResponse) -- 149
			local packageListVersion = version -- 150
			if Content:exist(packageListVersionFile) then -- 150
				local oldVersion = json.load(Content:load(packageListVersionFile)) -- 152
				local oldPackageListVersion = oldVersion -- 153
				if packageListVersion.version ~= oldPackageListVersion.version then -- 153
					reload = true -- 155
				end -- 155
			else -- 155
				reload = true -- 158
			end -- 158
		end -- 158
		if reload then -- 158
			self.categories = {} -- 162
			self.packages = {} -- 163
			self.repos = __TS__New(Map) -- 164
			self.previewTextures:clear() -- 165
			self.previewFiles:clear() -- 166
			local cachePath = Path(Content.appPath, ".cache", "preview") -- 167
			Content:remove(cachePath) -- 168
		end -- 168
		local cachePath = Path(Content.appPath, ".cache", "preview") -- 171
		Content:mkdir(cachePath) -- 172
		if reload and versionResponse then -- 172
			Content:save(packageListVersionFile, versionResponse) -- 174
		end -- 174
		local packagesFile = Path(cachePath, "packages.json") -- 176
		if Content:exist(packagesFile) then -- 176
			local packages = json.load(Content:load(packagesFile)) -- 178
			self.packages = packages -- 179
		else -- 179
			local packagesResponse = HttpClient:getAsync(config.url .. "/api/v1/packages") -- 181
			if packagesResponse then -- 181
				local packages = json.load(packagesResponse) -- 184
				self.packages = packages -- 185
				Content:save(packagesFile, packagesResponse) -- 186
			end -- 186
		end -- 186
		for ____, pkg in ipairs(self.packages) do -- 189
			pkg.currentVersion = 1 -- 190
			pkg.versionNames = __TS__ArrayMap( -- 191
				pkg.versions, -- 191
				function(____, v) -- 191
					return v.tag == "" and "No Tag" or v.tag -- 192
				end -- 191
			) -- 191
		end -- 191
		local catSet = __TS__New(Set) -- 197
		local function loadRepos(repos) -- 198
			for ____, repo in ipairs(repos) do -- 199
				self.repos:set(repo.name, repo) -- 200
				if repo.categories then -- 200
					for ____, cat in ipairs(repo.categories) do -- 202
						catSet:add(cat) -- 203
					end -- 203
				end -- 203
			end -- 203
		end -- 198
		local reposFile = Path(cachePath, "repos.json") -- 208
		if Content:exist(reposFile) then -- 208
			local repos = json.load(Content:load(reposFile)) -- 210
			loadRepos(repos) -- 211
		else -- 211
			local reposResponse = HttpClient:getAsync(config.url .. "/assets/repos.json") -- 213
			if reposResponse then -- 213
				local repos = json.load(reposResponse) -- 215
				loadRepos(repos) -- 216
				Content:save(reposFile, reposResponse) -- 217
			end -- 217
		end -- 217
		for ____, cat in __TS__Iterator(catSet) do -- 220
			local ____self_categories_0 = self.categories -- 220
			____self_categories_0[#____self_categories_0 + 1] = cat -- 221
		end -- 221
		for ____, pkg in ipairs(self.packages) do -- 225
			local downloadPath = Path(Content.writablePath, "Download", pkg.name) -- 226
			if Content:exist(downloadPath) then -- 226
				self.downloadedPackages:add(pkg.name) -- 228
			end -- 228
			self:loadPreviewImage(pkg.name) -- 230
		end -- 230
		self.isLoading = false -- 232
	end) -- 144
end -- 141
function ResourceDownloader.prototype.loadPreviewImage(self, name) -- 236
	local cachePath = Path(Content.appPath, ".cache", "preview") -- 237
	local cacheFile = Path(cachePath, name .. ".jpg") -- 238
	if Content:exist(cacheFile) then -- 238
		Cache:loadAsync(cacheFile) -- 240
		local texture = Texture2D(cacheFile) -- 241
		if texture then -- 241
			self.previewTextures:set(name, texture) -- 243
			self.previewFiles:set(name, cacheFile) -- 244
		end -- 244
		return -- 246
	end -- 246
	local imageUrl = ((config.url .. "/assets/") .. name) .. "/banner.jpg" -- 248
	local response = HttpClient:downloadAsync(imageUrl, cacheFile, 10) -- 249
	if response then -- 249
		Cache:loadAsync(cacheFile) -- 251
		local texture = Texture2D(cacheFile) -- 252
		if texture then -- 252
			self.previewTextures:set(name, texture) -- 254
			self.previewFiles:set(name, cacheFile) -- 255
		end -- 255
	else -- 255
		print("Failed to load preview image for " .. name) -- 258
	end -- 258
end -- 236
function ResourceDownloader.prototype.isDownloaded(self, name) -- 262
	return self.downloadedPackages:has(name) -- 263
end -- 262
function ResourceDownloader.prototype.downloadPackage(self, pkg) -- 266
	if self.downloadTasks:has(pkg.name) then -- 266
		return -- 268
	end -- 268
	local task = thread(function() -- 271
		self.isDownloading = true -- 272
		local downloadStatus = (zh and "正在下载：" or "Downloading: ") .. pkg.name -- 273
		local downloadPath = Path(Content.writablePath, ".download") -- 274
		Content:mkdir(downloadPath) -- 275
		local currentVersion = pkg.currentVersion or 1 -- 276
		local version = pkg.versions[currentVersion] -- 277
		local targetFile = Path(downloadPath, version.file) -- 278
		local success = HttpClient:downloadAsync( -- 280
			version.download, -- 281
			targetFile, -- 282
			30, -- 283
			function(current, total) -- 284
				if self.cancelDownload then -- 284
					return true -- 286
				end -- 286
				self.downloadProgress:set(pkg.name, {progress = current / total, status = downloadStatus}) -- 288
				return false -- 289
			end -- 284
		) -- 284
		if success then -- 284
			downloadStatus = zh and "解压中：" .. pkg.name or "Unziping: " .. pkg.name -- 294
			self.downloadProgress:set(pkg.name, {progress = 1, status = downloadStatus}) -- 295
			local unzipPath = Path(Content.writablePath, "Download", pkg.name) -- 296
			Content:remove(unzipPath) -- 297
			if Content:unzipAsync(targetFile, unzipPath) then -- 297
				Content:remove(targetFile) -- 299
				self.downloadedPackages:add(pkg.name) -- 300
				Director.postNode:emit("UpdateEntries") -- 301
			else -- 301
				Content:remove(unzipPath) -- 303
				self:showPopup(zh and "解压失败" or "Failed to unzip", zh and "无法解压文件：" .. version.file or "Failed to unzip: " .. version.file) -- 304
			end -- 304
		else -- 304
			Content:remove(targetFile) -- 310
			self:showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. version.download or "Failed to download from: " .. version.download) -- 311
		end -- 311
		self.isDownloading = false -- 317
		self.downloadProgress:delete(pkg.name) -- 318
		self.downloadTasks:delete(pkg.name) -- 319
	end) -- 271
	self.downloadTasks:set(pkg.name, task) -- 322
end -- 266
function ResourceDownloader.prototype.messagePopup(self) -- 325
	ImGui.Text(self.popupMessageTitle) -- 326
	ImGui.Separator() -- 327
	ImGui.PushTextWrapPos( -- 328
		300, -- 328
		function() -- 328
			ImGui.TextWrapped(self.popupMessage) -- 329
		end -- 328
	) -- 328
	if ImGui.Button( -- 328
		zh and "确认" or "OK", -- 331
		Vec2(300, 30) -- 331
	) then -- 331
		ImGui.CloseCurrentPopup() -- 332
	end -- 332
end -- 325
function ResourceDownloader.prototype.update(self) -- 336
	local ____App_visualSize_1 = App.visualSize -- 337
	local width = ____App_visualSize_1.width -- 337
	local height = ____App_visualSize_1.height -- 337
	local filterCategory = nil -- 338
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 339
	ImGui.SetNextWindowSize( -- 340
		Vec2(width, self.headerHeight), -- 340
		"Always" -- 340
	) -- 340
	ImGui.PushStyleVar( -- 341
		"WindowPadding", -- 341
		Vec2(10, 0), -- 341
		function() return ImGui.Begin( -- 341
			"Dora Community Header", -- 341
			windowsNoScrollFlags, -- 341
			function() -- 341
				ImGui.Dummy(Vec2(0, 0)) -- 342
				ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Resources") -- 343
				ImGui.SameLine() -- 344
				ImGui.TextDisabled("(?)") -- 345
				if ImGui.IsItemHovered() then -- 345
					ImGui.BeginTooltip(function() -- 347
						ImGui.PushTextWrapPos( -- 348
							300, -- 348
							function() -- 348
								ImGui.Text(zh and "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" or "Use this tool to download Dora SSR community resources to the `Download` directory.") -- 349
							end -- 348
						) -- 348
					end) -- 347
				end -- 347
				local padding = zh and 400 or 440 -- 353
				if width >= padding then -- 353
					ImGui.SameLine() -- 355
					ImGui.Dummy(Vec2(width - padding, 0)) -- 356
					ImGui.SameLine() -- 357
					ImGui.SetNextItemWidth((zh and -40 or -55) - 40) -- 358
					if ImGui.InputText(zh and "筛选" or "Filter", self.filterBuf, {"AutoSelectAll"}) then -- 358
						local res = string.match(self.filterBuf.text, "[^%%%.%[]+") -- 360
						self.filterText = string.lower(res or "") -- 361
					end -- 361
				else -- 361
					ImGui.SameLine() -- 364
					ImGui.Dummy(Vec2(width - (zh and 250 or 255), 0)) -- 365
				end -- 365
				ImGui.SameLine() -- 367
				if ImGui.CollapsingHeader("###option") then -- 367
					self.headerHeight = 130 -- 369
					ImGui.SetNextItemWidth(zh and -200 or -230) -- 370
					if ImGui.InputText(zh and "服务器" or "Server", url) then -- 370
						if url.text == "" then -- 370
							url.text = DefaultURL -- 373
						end -- 373
						config.url = url.text -- 375
					end -- 375
					ImGui.SameLine() -- 377
					if ImGui.Button(zh and "刷新" or "Reload") then -- 377
						local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 379
						Content:remove(packageListVersionFile) -- 380
						self:loadData() -- 381
					end -- 381
					ImGui.SameLine() -- 383
					if ImGui.Button(zh and "同步仓库" or "Sync Repo") then -- 383
						ImGui.OpenPopup((zh and "同步仓库" or "Sync Repo") .. "###SyncRepo") -- 385
					end -- 385
					local popupWidth = math.min(500, width * 0.8) -- 387
					ImGui.SetNextWindowSize(Vec2( -- 388
						popupWidth, -- 388
						math.min(400, height * 0.8) -- 388
					)) -- 388
					ImGui.SetNextWindowPosCenter( -- 389
						"Always", -- 389
						Vec2(0.5, 0.5) -- 389
					) -- 389
					ImGui.BeginPopupModal( -- 390
						(zh and "同步仓库" or "Sync Repo") .. "###SyncRepo", -- 390
						syncWindowFlags, -- 390
						function() -- 390
							ImGui.Dummy(Vec2(0, 0)) -- 391
							ImGui.InputText(zh and "仓库地址" or "Repo URL", self.cloneURL) -- 392
							local cloneURL = self.cloneURL.text -- 393
							local trailing = string.match(cloneURL, "[^/]*$") -- 394
							local name = string.gsub(trailing, "%..*$", "") -- 395
							local repoPath = Path(Content.writablePath, "Repo", name) -- 396
							if self.syncing then -- 396
								ImGui.BeginDisabled(function() return ImGui.Button(zh and "删除本地仓库" or "Delete Local Repo") end) -- 398
							elseif ImGui.Button(zh and "删除本地仓库" or "Delete Local Repo") then -- 398
								if Content:remove(repoPath) then -- 398
									local sep = self.gitProgress == "" and "" or "\r" -- 401
									self.gitProgress = self.gitProgress .. sep .. (zh and "删除成功！" or "Deleted!") -- 402
									Director.postNode:emit("UpdateEntries") -- 403
								end -- 403
							end -- 403
							ImGui.SameLine() -- 406
							if self.syncing then -- 406
								ImGui.BeginDisabled(function() return ImGui.Button(zh and "开始同步" or "Start Sync") end) -- 408
							elseif ImGui.Button(zh and "开始同步" or "Start Sync") then -- 408
								self.syncing = true -- 410
								self.gitProgress = "" -- 411
								local depth = 0 -- 412
								if not Content:exist(repoPath) then -- 412
									depth = 1 -- 414
								end -- 414
								local node = Node() -- 416
								node:gslot( -- 417
									"WaLang", -- 417
									function(event, message) -- 417
										repeat -- 417
											local ____switch83 = event -- 417
											local sep -- 417
											local ____cond83 = ____switch83 == "GitPullOrClone" -- 417
											if ____cond83 then -- 417
												self.syncing = false -- 420
												node:removeFromParent() -- 421
												sep = self.gitProgress == "" and "" or "\r" -- 422
												if message ~= "" then -- 422
													self.gitProgress = self.gitProgress .. sep .. message -- 424
												else -- 424
													self.gitProgress = self.gitProgress .. sep .. (zh and "同步成功！" or "Sync done!") -- 426
												end -- 426
												Director.postNode:emit("UpdateEntries") -- 428
												break -- 429
											end -- 429
											____cond83 = ____cond83 or ____switch83 == "GitProgress" -- 429
											if ____cond83 then -- 429
												self.gitProgress = self.gitProgress .. message -- 431
												break -- 432
											end -- 432
										until true -- 432
									end -- 417
								) -- 417
								thread(function() -- 435
									local success = GitPullOrCloneAsync(cloneURL, repoPath, depth) -- 436
									if not success then -- 436
										local sep = self.gitProgress == "" and "" or "\r" -- 438
										self.gitProgress = self.gitProgress .. sep .. "Failed to synchronize repo." -- 439
										self.syncing = false -- 440
									end -- 440
								end) -- 435
							end -- 435
							ImGui.Separator() -- 444
							ImGui.BeginChild( -- 445
								"LogArea", -- 445
								Vec2(0, -50), -- 445
								function() -- 445
									for ____, part in ipairs(__TS__StringSplit(self.gitProgress, "\r")) do -- 446
										ImGui.TextWrapped(part) -- 447
									end -- 447
									if ImGui.GetScrollY() >= ImGui.GetScrollMaxY() then -- 447
										ImGui.SetScrollHereY(1) -- 450
									end -- 450
								end -- 445
							) -- 445
							ImGui.Dummy(Vec2(popupWidth - 80, 0)) -- 453
							ImGui.SameLine() -- 454
							if self.syncing then -- 454
								ImGui.BeginDisabled(function() return ImGui.Button(zh and "关闭" or "Close") end) -- 456
							else -- 456
								if ImGui.Button(zh and "关闭" or "Close") then -- 456
									ImGui.CloseCurrentPopup() -- 459
								end -- 459
							end -- 459
						end -- 390
					) -- 390
					ImGui.Separator() -- 463
				else -- 463
					self.headerHeight = 80 -- 465
				end -- 465
				ImGui.PushStyleVar( -- 467
					"WindowPadding", -- 467
					Vec2(10, 10), -- 467
					function() return ImGui.BeginTabBar( -- 467
						"categories", -- 467
						tabBarFlags, -- 467
						function() -- 467
							ImGui.BeginTabItem( -- 468
								zh and "全部" or "All", -- 468
								function() -- 468
									filterCategory = nil -- 469
								end -- 468
							) -- 468
							for ____, cat in ipairs(self.categories) do -- 471
								ImGui.BeginTabItem( -- 472
									cat, -- 472
									function() -- 472
										filterCategory = cat -- 473
									end -- 472
								) -- 472
							end -- 472
						end -- 467
					) end -- 467
				) -- 467
			end -- 341
		) end -- 341
	) -- 341
	local function matchCat(self, cat) -- 478
		return filterCategory == cat -- 478
	end -- 478
	local maxColumns = math.max( -- 479
		math.floor(width / 320), -- 479
		1 -- 479
	) -- 479
	local itemWidth = (width - 60) / maxColumns - 10 -- 480
	ImGui.SetNextWindowPos( -- 481
		Vec2(0, self.headerHeight), -- 481
		"Always", -- 481
		Vec2.zero -- 481
	) -- 481
	ImGui.SetNextWindowSize( -- 482
		Vec2(width, height - self.headerHeight - 50), -- 482
		"Always" -- 482
	) -- 482
	ImGui.PushStyleVar( -- 483
		"Alpha", -- 483
		1, -- 483
		function() return ImGui.PushStyleVar( -- 483
			"WindowPadding", -- 483
			Vec2(20, 10), -- 483
			function() return ImGui.Begin( -- 483
				"Dora Community Resources", -- 483
				windowsFlags, -- 483
				function() -- 483
					ImGui.Columns(maxColumns, false) -- 484
					for ____, pkg in ipairs(self.packages) do -- 487
						do -- 487
							local repo = self.repos:get(pkg.name) -- 488
							if not repo then -- 488
								goto __continue107 -- 489
							end -- 489
							if filterCategory ~= nil then -- 489
								if not repo.categories then -- 489
									goto __continue107 -- 491
								end -- 491
								if __TS__ArrayFind(repo.categories, matchCat) == nil then -- 491
									goto __continue107 -- 493
								end -- 493
							end -- 493
							if self.filterText ~= "" then -- 493
								local res = string.match( -- 498
									string.lower(repo.name), -- 498
									self.filterText -- 498
								) -- 498
								if not res then -- 498
									goto __continue107 -- 499
								end -- 499
							end -- 499
							ImGui.TextColored(themeColor, repo.title[zh and "zh" or "en"]) -- 503
							local previewTexture = self.previewTextures:get(pkg.name) -- 506
							if previewTexture then -- 506
								local width = previewTexture.width -- 506
								local height = previewTexture.height -- 506
								local scale = (itemWidth - 30) / width -- 510
								local scaledSize = Vec2(width * scale, height * scale) -- 511
								local previewFile = self.previewFiles:get(pkg.name) -- 512
								if previewFile then -- 512
									ImGui.Dummy(Vec2.zero) -- 514
									ImGui.SameLine() -- 515
									ImGui.Image(previewFile, scaledSize) -- 516
								end -- 516
							else -- 516
								ImGui.Text(zh and "加载预览图中..." or "Loading preview...") -- 519
							end -- 519
							ImGui.TextWrapped(repo.desc[zh and "zh" or "en"]) -- 522
							ImGui.TextColored(themeColor, zh and "项目地址：" or "Repo URL:") -- 524
							ImGui.SameLine() -- 525
							if ImGui.TextLink((zh and "这里" or "here") .. "###" .. pkg.url) then -- 525
								App:openURL(pkg.url) -- 527
							end -- 527
							if ImGui.IsItemHovered() then -- 527
								ImGui.BeginTooltip(function() -- 530
									ImGui.PushTextWrapPos( -- 531
										300, -- 531
										function() -- 531
											ImGui.Text(pkg.url) -- 532
										end -- 531
									) -- 531
								end) -- 530
							end -- 530
							local currentVersion = pkg.currentVersion or 1 -- 537
							local version = pkg.versions[currentVersion] -- 538
							if type(version.updatedAt) == "number" then -- 538
								ImGui.TextColored(themeColor, zh and "同步时间：" or "Updated:") -- 540
								ImGui.SameLine() -- 541
								local dateStr = os.date("%Y-%m-%d %H:%M:%S", version.updatedAt) -- 542
								ImGui.Text(dateStr) -- 543
							end -- 543
							local progress = self.downloadProgress:get(pkg.name) -- 547
							if progress ~= nil then -- 547
								ImGui.ProgressBar( -- 549
									progress.progress, -- 549
									Vec2(-1, 30) -- 549
								) -- 549
								ImGui.BeginDisabled(function() -- 550
									ImGui.Button(progress.status) -- 551
								end) -- 550
							end -- 550
							if progress == nil then -- 550
								local isDownloaded = self:isDownloaded(pkg.name) -- 557
								local buttonText = (isDownloaded and (zh and "重新下载" or "Re-Download") or (zh and "下载" or "Download")) .. "###download-" .. pkg.name -- 558
								local deleteText = (zh and "删除" or "Delete") .. "###delete-" .. pkg.name -- 561
								if self.isDownloading then -- 561
									ImGui.BeginDisabled(function() -- 563
										ImGui.Button(buttonText) -- 564
										if isDownloaded then -- 564
											ImGui.SameLine() -- 566
											ImGui.Button(deleteText) -- 567
										end -- 567
									end) -- 563
								else -- 563
									if ImGui.Button(buttonText) then -- 563
										self:downloadPackage(pkg) -- 572
									end -- 572
									if isDownloaded then -- 572
										ImGui.SameLine() -- 575
										if ImGui.Button(deleteText) then -- 575
											Content:remove(Path(Content.writablePath, "Download", pkg.name)) -- 577
											self.downloadedPackages:delete(pkg.name) -- 578
											Director.postNode:emit("UpdateEntries") -- 579
										end -- 579
									end -- 579
								end -- 579
							end -- 579
							ImGui.SameLine() -- 586
							ImGui.Text(__TS__NumberToFixed(version.size / 1024 / 1024, 2) .. " MB") -- 587
							if not self.isDownloading and pkg.versionNames and pkg.currentVersion then -- 587
								ImGui.SameLine() -- 589
								ImGui.SetNextItemWidth(-20) -- 590
								local changed, currentVersion = ImGui.Combo("###" .. pkg.name, pkg.currentVersion, pkg.versionNames) -- 591
								if changed then -- 591
									pkg.currentVersion = currentVersion -- 593
								end -- 593
							end -- 593
							thinSep() -- 597
							ImGui.NextColumn() -- 598
						end -- 598
						::__continue107:: -- 598
					end -- 598
					ImGui.Columns(1, false) -- 601
					ImGui.ScrollWhenDraggingOnVoid() -- 602
					if self.popupShow then -- 602
						self.popupShow = false -- 605
						ImGui.OpenPopup("MessagePopup") -- 606
					end -- 606
					ImGui.BeginPopupModal( -- 608
						"MessagePopup", -- 608
						function() return self:messagePopup() end -- 608
					) -- 608
				end -- 483
			) end -- 483
		) end -- 483
	) -- 483
end -- 336
__TS__New(ResourceDownloader) -- 613
return ____exports -- 613