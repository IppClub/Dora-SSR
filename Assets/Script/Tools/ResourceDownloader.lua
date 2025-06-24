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
local themeColor = App.themeColor -- 90
local function sep() -- 92
	return ImGui.SeparatorText("") -- 92
end -- 92
local function thinSep() -- 93
	return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 93
end -- 93
local ResourceDownloader = __TS__Class() -- 95
ResourceDownloader.name = "ResourceDownloader" -- 95
function ResourceDownloader.prototype.____constructor(self) -- 115
	self.packages = {} -- 96
	self.repos = __TS__New(Map) -- 97
	self.downloadProgress = __TS__New(Map) -- 98
	self.downloadTasks = __TS__New(Map) -- 99
	self.popupMessageTitle = "" -- 100
	self.popupMessage = "" -- 101
	self.popupShow = false -- 102
	self.cancelDownload = false -- 103
	self.isDownloading = false -- 104
	self.previewTextures = __TS__New(Map) -- 106
	self.previewFiles = __TS__New(Map) -- 107
	self.downloadedPackages = __TS__New(Set) -- 108
	self.isLoading = false -- 109
	self.filterBuf = Buffer(20) -- 110
	self.filterText = "" -- 111
	self.categories = {} -- 112
	self.headerHeight = 80 -- 113
	self.node = Node() -- 116
	self.node:schedule(function() -- 117
		self:update() -- 118
		return false -- 119
	end) -- 117
	self.node:onCleanup(function() -- 121
		self.cancelDownload = true -- 122
	end) -- 121
	self:loadData() -- 124
end -- 115
function ResourceDownloader.prototype.showPopup(self, title, msg) -- 127
	self.popupMessageTitle = title -- 128
	self.popupMessage = msg -- 129
	self.popupShow = true -- 130
end -- 127
function ResourceDownloader.prototype.loadData(self) -- 133
	if self.isLoading then -- 133
		return -- 134
	end -- 134
	self.isLoading = true -- 135
	thread(function() -- 136
		local reload = false -- 137
		local versionResponse = HttpClient:getAsync(config.url .. "/api/v1/package-list-version") -- 138
		local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 139
		if versionResponse then -- 139
			local version = json.load(versionResponse) -- 141
			local packageListVersion = version -- 142
			if Content:exist(packageListVersionFile) then -- 142
				local oldVersion = json.load(Content:load(packageListVersionFile)) -- 144
				local oldPackageListVersion = oldVersion -- 145
				if packageListVersion.version ~= oldPackageListVersion.version then -- 145
					reload = true -- 147
				end -- 147
			else -- 147
				reload = true -- 150
			end -- 150
		end -- 150
		if reload then -- 150
			self.categories = {} -- 154
			self.packages = {} -- 155
			self.repos = __TS__New(Map) -- 156
			self.previewTextures:clear() -- 157
			self.previewFiles:clear() -- 158
			local cachePath = Path(Content.appPath, ".cache", "preview") -- 159
			Content:remove(cachePath) -- 160
		end -- 160
		local cachePath = Path(Content.appPath, ".cache", "preview") -- 163
		Content:mkdir(cachePath) -- 164
		if reload and versionResponse then -- 164
			Content:save(packageListVersionFile, versionResponse) -- 166
		end -- 166
		local packagesFile = Path(cachePath, "packages.json") -- 168
		if Content:exist(packagesFile) then -- 168
			local packages = json.load(Content:load(packagesFile)) -- 170
			self.packages = packages -- 171
		else -- 171
			local packagesResponse = HttpClient:getAsync(config.url .. "/api/v1/packages") -- 173
			if packagesResponse then -- 173
				local packages = json.load(packagesResponse) -- 176
				self.packages = packages -- 177
				Content:save(packagesFile, packagesResponse) -- 178
			end -- 178
		end -- 178
		for ____, pkg in ipairs(self.packages) do -- 181
			pkg.currentVersion = 1 -- 182
			pkg.versionNames = __TS__ArrayMap( -- 183
				pkg.versions, -- 183
				function(____, v) -- 183
					return v.tag == "" and "No Tag" or v.tag -- 184
				end -- 183
			) -- 183
		end -- 183
		local catSet = __TS__New(Set) -- 189
		local function loadRepos(repos) -- 190
			for ____, repo in ipairs(repos) do -- 191
				self.repos:set(repo.name, repo) -- 192
				if repo.categories then -- 192
					for ____, cat in ipairs(repo.categories) do -- 194
						catSet:add(cat) -- 195
					end -- 195
				end -- 195
			end -- 195
		end -- 190
		local reposFile = Path(cachePath, "repos.json") -- 200
		if Content:exist(reposFile) then -- 200
			local repos = json.load(Content:load(reposFile)) -- 202
			loadRepos(repos) -- 203
		else -- 203
			local reposResponse = HttpClient:getAsync(config.url .. "/assets/repos.json") -- 205
			if reposResponse then -- 205
				local repos = json.load(reposResponse) -- 207
				loadRepos(repos) -- 208
				Content:save(reposFile, reposResponse) -- 209
			end -- 209
		end -- 209
		for ____, cat in __TS__Iterator(catSet) do -- 212
			local ____self_categories_0 = self.categories -- 212
			____self_categories_0[#____self_categories_0 + 1] = cat -- 213
		end -- 213
		for ____, pkg in ipairs(self.packages) do -- 217
			local downloadPath = Path(Content.writablePath, "Download", pkg.name) -- 218
			if Content:exist(downloadPath) then -- 218
				self.downloadedPackages:add(pkg.name) -- 220
			end -- 220
			self:loadPreviewImage(pkg.name) -- 222
		end -- 222
		self.isLoading = false -- 224
	end) -- 136
end -- 133
function ResourceDownloader.prototype.loadPreviewImage(self, name) -- 228
	local cachePath = Path(Content.appPath, ".cache", "preview") -- 229
	local cacheFile = Path(cachePath, name .. ".jpg") -- 230
	if Content:exist(cacheFile) then -- 230
		Cache:loadAsync(cacheFile) -- 232
		local texture = Texture2D(cacheFile) -- 233
		if texture then -- 233
			self.previewTextures:set(name, texture) -- 235
			self.previewFiles:set(name, cacheFile) -- 236
		end -- 236
		return -- 238
	end -- 238
	local imageUrl = ((config.url .. "/assets/") .. name) .. "/banner.jpg" -- 240
	local response = HttpClient:downloadAsync(imageUrl, cacheFile, 10) -- 241
	if response then -- 241
		Cache:loadAsync(cacheFile) -- 243
		local texture = Texture2D(cacheFile) -- 244
		if texture then -- 244
			self.previewTextures:set(name, texture) -- 246
			self.previewFiles:set(name, cacheFile) -- 247
		end -- 247
	else -- 247
		print("Failed to load preview image for " .. name) -- 250
	end -- 250
end -- 228
function ResourceDownloader.prototype.isDownloaded(self, name) -- 254
	return self.downloadedPackages:has(name) -- 255
end -- 254
function ResourceDownloader.prototype.downloadPackage(self, pkg) -- 258
	if self.downloadTasks:has(pkg.name) then -- 258
		return -- 260
	end -- 260
	local task = thread(function() -- 263
		self.isDownloading = true -- 264
		local downloadStatus = (zh and "正在下载：" or "Downloading: ") .. pkg.name -- 265
		local downloadPath = Path(Content.writablePath, ".download") -- 266
		Content:mkdir(downloadPath) -- 267
		local currentVersion = pkg.currentVersion or 1 -- 268
		local version = pkg.versions[currentVersion] -- 269
		local targetFile = Path(downloadPath, version.file) -- 270
		local success = HttpClient:downloadAsync( -- 272
			version.download, -- 273
			targetFile, -- 274
			30, -- 275
			function(current, total) -- 276
				if self.cancelDownload then -- 276
					return true -- 278
				end -- 278
				self.downloadProgress:set(pkg.name, {progress = current / total, status = downloadStatus}) -- 280
				return false -- 281
			end -- 276
		) -- 276
		if success then -- 276
			downloadStatus = zh and "解压中：" .. pkg.name or "Unziping: " .. pkg.name -- 286
			self.downloadProgress:set(pkg.name, {progress = 1, status = downloadStatus}) -- 287
			local unzipPath = Path(Content.writablePath, "Download", pkg.name) -- 288
			Content:remove(unzipPath) -- 289
			if Content:unzipAsync(targetFile, unzipPath) then -- 289
				Content:remove(targetFile) -- 291
				self.downloadedPackages:add(pkg.name) -- 292
				Director.postNode:emit("UpdateEntries") -- 293
			else -- 293
				Content:remove(unzipPath) -- 295
				self:showPopup(zh and "解压失败" or "Failed to unzip", zh and "无法解压文件：" .. version.file or "Failed to unzip: " .. version.file) -- 296
			end -- 296
		else -- 296
			Content:remove(targetFile) -- 302
			self:showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. version.download or "Failed to download from: " .. version.download) -- 303
		end -- 303
		self.isDownloading = false -- 309
		self.downloadProgress:delete(pkg.name) -- 310
		self.downloadTasks:delete(pkg.name) -- 311
	end) -- 263
	self.downloadTasks:set(pkg.name, task) -- 314
end -- 258
function ResourceDownloader.prototype.messagePopup(self) -- 317
	ImGui.Text(self.popupMessageTitle) -- 318
	ImGui.Separator() -- 319
	ImGui.PushTextWrapPos( -- 320
		300, -- 320
		function() -- 320
			ImGui.TextWrapped(self.popupMessage) -- 321
		end -- 320
	) -- 320
	if ImGui.Button( -- 320
		zh and "确认" or "OK", -- 323
		Vec2(300, 30) -- 323
	) then -- 323
		ImGui.CloseCurrentPopup() -- 324
	end -- 324
end -- 317
function ResourceDownloader.prototype.update(self) -- 328
	local ____App_visualSize_1 = App.visualSize -- 329
	local width = ____App_visualSize_1.width -- 329
	local height = ____App_visualSize_1.height -- 329
	local filterCategory = nil -- 330
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 331
	ImGui.SetNextWindowSize( -- 332
		Vec2(width, self.headerHeight), -- 332
		"Always" -- 332
	) -- 332
	ImGui.PushStyleVar( -- 333
		"WindowPadding", -- 333
		Vec2(10, 0), -- 333
		function() return ImGui.Begin( -- 333
			"Dora Community Header", -- 333
			windowsNoScrollFlags, -- 333
			function() -- 333
				ImGui.Dummy(Vec2(0, 0)) -- 334
				ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Resources") -- 335
				ImGui.SameLine() -- 336
				ImGui.TextDisabled("(?)") -- 337
				if ImGui.IsItemHovered() then -- 337
					ImGui.BeginTooltip(function() -- 339
						ImGui.PushTextWrapPos( -- 340
							300, -- 340
							function() -- 340
								ImGui.Text(zh and "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" or "Use this tool to download Dora SSR community resources to the `Download` directory.") -- 341
							end -- 340
						) -- 340
					end) -- 339
				end -- 339
				local padding = zh and 400 or 440 -- 345
				if width >= padding then -- 345
					ImGui.SameLine() -- 347
					ImGui.Dummy(Vec2(width - padding, 0)) -- 348
					ImGui.SameLine() -- 349
					ImGui.SetNextItemWidth((zh and -40 or -55) - 40) -- 350
					if ImGui.InputText(zh and "筛选" or "Filter", self.filterBuf, {"AutoSelectAll"}) then -- 350
						local res = string.match(self.filterBuf.text, "[^%%%.%[]+") -- 352
						self.filterText = string.lower(res or "") -- 353
					end -- 353
				else -- 353
					ImGui.SameLine() -- 356
					ImGui.Dummy(Vec2(width - (zh and 250 or 255), 0)) -- 357
				end -- 357
				ImGui.SameLine() -- 359
				if ImGui.CollapsingHeader("###option") then -- 359
					self.headerHeight = 130 -- 361
					ImGui.SetNextItemWidth(zh and -200 or -230) -- 362
					if ImGui.InputText(zh and "服务器" or "Server", url) then -- 362
						if url.text == "" then -- 362
							url.text = DefaultURL -- 365
						end -- 365
						config.url = url.text -- 367
					end -- 367
					ImGui.SameLine() -- 369
					if ImGui.Button(zh and "刷新" or "Reload") then -- 369
						local packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json") -- 371
						Content:remove(packageListVersionFile) -- 372
						self:loadData() -- 373
					end -- 373
					ImGui.Separator() -- 375
				else -- 375
					self.headerHeight = 80 -- 377
				end -- 377
				ImGui.PushStyleVar( -- 379
					"WindowPadding", -- 379
					Vec2(10, 10), -- 379
					function() return ImGui.BeginTabBar( -- 379
						"categories", -- 379
						tabBarFlags, -- 379
						function() -- 379
							ImGui.BeginTabItem( -- 380
								zh and "全部" or "All", -- 380
								function() -- 380
									filterCategory = nil -- 381
								end -- 380
							) -- 380
							for ____, cat in ipairs(self.categories) do -- 383
								ImGui.BeginTabItem( -- 384
									cat, -- 384
									function() -- 384
										filterCategory = cat -- 385
									end -- 384
								) -- 384
							end -- 384
						end -- 379
					) end -- 379
				) -- 379
			end -- 333
		) end -- 333
	) -- 333
	local function matchCat(self, cat) -- 390
		return filterCategory == cat -- 390
	end -- 390
	local maxColumns = math.max( -- 391
		math.floor(width / 320), -- 391
		1 -- 391
	) -- 391
	local itemWidth = (width - 60) / maxColumns - 10 -- 392
	ImGui.SetNextWindowPos( -- 393
		Vec2(0, self.headerHeight), -- 393
		"Always", -- 393
		Vec2.zero -- 393
	) -- 393
	ImGui.SetNextWindowSize( -- 394
		Vec2(width, height - self.headerHeight - 50), -- 394
		"Always" -- 394
	) -- 394
	ImGui.PushStyleVar( -- 395
		"Alpha", -- 395
		1, -- 395
		function() return ImGui.PushStyleVar( -- 395
			"WindowPadding", -- 395
			Vec2(20, 10), -- 395
			function() return ImGui.Begin( -- 395
				"Dora Community Resources", -- 395
				windowsFlags, -- 395
				function() -- 395
					ImGui.Columns(maxColumns, false) -- 396
					for ____, pkg in ipairs(self.packages) do -- 399
						do -- 399
							local repo = self.repos:get(pkg.name) -- 400
							if not repo then -- 400
								goto __continue83 -- 401
							end -- 401
							if filterCategory ~= nil then -- 401
								if not repo.categories then -- 401
									goto __continue83 -- 403
								end -- 403
								if __TS__ArrayFind(repo.categories, matchCat) == nil then -- 403
									goto __continue83 -- 405
								end -- 405
							end -- 405
							if self.filterText ~= "" then -- 405
								local res = string.match( -- 410
									string.lower(repo.name), -- 410
									self.filterText -- 410
								) -- 410
								if not res then -- 410
									goto __continue83 -- 411
								end -- 411
							end -- 411
							ImGui.TextColored(themeColor, repo.title[zh and "zh" or "en"]) -- 415
							local previewTexture = self.previewTextures:get(pkg.name) -- 418
							if previewTexture then -- 418
								local width = previewTexture.width -- 418
								local height = previewTexture.height -- 418
								local scale = (itemWidth - 30) / width -- 422
								local scaledSize = Vec2(width * scale, height * scale) -- 423
								local previewFile = self.previewFiles:get(pkg.name) -- 424
								if previewFile then -- 424
									ImGui.Dummy(Vec2.zero) -- 426
									ImGui.SameLine() -- 427
									ImGui.Image(previewFile, scaledSize) -- 428
								end -- 428
							else -- 428
								ImGui.Text(zh and "加载预览图中..." or "Loading preview...") -- 431
							end -- 431
							ImGui.TextWrapped(repo.desc[zh and "zh" or "en"]) -- 434
							ImGui.TextColored(themeColor, zh and "项目地址：" or "Repo URL:") -- 436
							ImGui.SameLine() -- 437
							if ImGui.TextLink((zh and "这里" or "here") .. "###" .. pkg.url) then -- 437
								App:openURL(pkg.url) -- 439
							end -- 439
							if ImGui.IsItemHovered() then -- 439
								ImGui.BeginTooltip(function() -- 442
									ImGui.PushTextWrapPos( -- 443
										300, -- 443
										function() -- 443
											ImGui.Text(pkg.url) -- 444
										end -- 443
									) -- 443
								end) -- 442
							end -- 442
							local currentVersion = pkg.currentVersion or 1 -- 449
							local version = pkg.versions[currentVersion] -- 450
							if type(version.updatedAt) == "number" then -- 450
								ImGui.TextColored(themeColor, zh and "同步时间：" or "Updated:") -- 452
								ImGui.SameLine() -- 453
								local dateStr = os.date("%Y-%m-%d %H:%M:%S", version.updatedAt) -- 454
								ImGui.Text(dateStr) -- 455
							end -- 455
							local progress = self.downloadProgress:get(pkg.name) -- 459
							if progress ~= nil then -- 459
								ImGui.ProgressBar( -- 461
									progress.progress, -- 461
									Vec2(-1, 30) -- 461
								) -- 461
								ImGui.BeginDisabled(function() -- 462
									ImGui.Button(progress.status) -- 463
								end) -- 462
							end -- 462
							if progress == nil then -- 462
								local isDownloaded = self:isDownloaded(pkg.name) -- 469
								local buttonText = (isDownloaded and (zh and "重新下载" or "Re-Download") or (zh and "下载" or "Download")) .. "###download-" .. pkg.name -- 470
								local deleteText = (zh and "删除" or "Delete") .. "###delete-" .. pkg.name -- 473
								if self.isDownloading then -- 473
									ImGui.BeginDisabled(function() -- 475
										ImGui.Button(buttonText) -- 476
										if isDownloaded then -- 476
											ImGui.SameLine() -- 478
											ImGui.Button(deleteText) -- 479
										end -- 479
									end) -- 475
								else -- 475
									if ImGui.Button(buttonText) then -- 475
										self:downloadPackage(pkg) -- 484
									end -- 484
									if isDownloaded then -- 484
										ImGui.SameLine() -- 487
										if ImGui.Button(deleteText) then -- 487
											Content:remove(Path(Content.writablePath, "Download", pkg.name)) -- 489
											self.downloadedPackages:delete(pkg.name) -- 490
											Director.postNode:emit("UpdateEntries") -- 491
										end -- 491
									end -- 491
								end -- 491
							end -- 491
							ImGui.SameLine() -- 498
							ImGui.Text(__TS__NumberToFixed(version.size / 1024 / 1024, 2) .. " MB") -- 499
							if not self.isDownloading and pkg.versionNames and pkg.currentVersion then -- 499
								ImGui.SameLine() -- 501
								ImGui.SetNextItemWidth(-20) -- 502
								local changed, currentVersion = ImGui.Combo("###" .. pkg.name, pkg.currentVersion, pkg.versionNames) -- 503
								if changed then -- 503
									pkg.currentVersion = currentVersion -- 505
								end -- 505
							end -- 505
							thinSep() -- 509
							ImGui.NextColumn() -- 510
						end -- 510
						::__continue83:: -- 510
					end -- 510
					ImGui.Columns(1, false) -- 513
					ImGui.ScrollWhenDraggingOnVoid() -- 514
					if self.popupShow then -- 514
						self.popupShow = false -- 517
						ImGui.OpenPopup("MessagePopup") -- 518
					end -- 518
					ImGui.BeginPopupModal( -- 520
						"MessagePopup", -- 520
						function() return self:messagePopup() end -- 520
					) -- 520
				end -- 395
			) end -- 395
		) end -- 395
	) -- 395
end -- 328
__TS__New(ResourceDownloader) -- 525
return ____exports -- 525