-- [ts]: ResourceDownloader.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Set = ____lualib.Set -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__StringReplace = ____lualib.__TS__StringReplace -- 1
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
local ImGui = require("ImGui") -- 4
local zh = false -- 6
do -- 6
	local res = string.match(App.locale, "^zh") -- 8
	zh = res ~= nil and ImGui.IsFontLoaded() -- 9
end -- 9
local windowsNoScrollFlags = { -- 38
	"NoMove", -- 39
	"NoCollapse", -- 40
	"NoResize", -- 41
	"NoDecoration", -- 42
	"NoNav", -- 43
	"NoBringToFrontOnFocus" -- 44
} -- 44
local windowsFlags = { -- 47
	"NoMove", -- 48
	"NoCollapse", -- 49
	"NoResize", -- 50
	"NoDecoration", -- 51
	"NoNav", -- 52
	"AlwaysVerticalScrollbar", -- 53
	"NoBringToFrontOnFocus" -- 54
} -- 54
local themeColor = App.themeColor -- 57
local function sep() -- 59
	return ImGui.SeparatorText("") -- 59
end -- 59
local function thinSep() -- 60
	return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 60
end -- 60
local ResourceDownloader = __TS__Class() -- 62
ResourceDownloader.name = "ResourceDownloader" -- 62
function ResourceDownloader.prototype.____constructor(self) -- 80
	self.packages = {} -- 63
	self.repos = {} -- 64
	self.downloadProgress = __TS__New(Map) -- 65
	self.downloadTasks = __TS__New(Map) -- 66
	self.popupMessageTitle = "" -- 67
	self.popupMessage = "" -- 68
	self.popupShow = false -- 69
	self.cancelDownload = false -- 70
	self.isDownloading = false -- 71
	self.previewTextures = __TS__New(Map) -- 73
	self.previewFiles = __TS__New(Map) -- 74
	self.downloadedPackages = __TS__New(Set) -- 75
	self.isLoading = false -- 76
	self.filterBuf = Buffer(20) -- 77
	self.filterText = "" -- 78
	self.node = Node() -- 81
	self.node:schedule(function() -- 82
		self:update() -- 83
		return false -- 84
	end) -- 82
	self.node:onCleanup(function() -- 86
		self.cancelDownload = true -- 87
	end) -- 86
	self:loadData() -- 89
end -- 80
function ResourceDownloader.prototype.showPopup(self, title, msg) -- 92
	self.popupMessageTitle = title -- 93
	self.popupMessage = msg -- 94
	self.popupShow = true -- 95
end -- 92
function ResourceDownloader.prototype.loadData(self, reload) -- 98
	if reload == nil then -- 98
		reload = false -- 98
	end -- 98
	if self.isLoading then -- 98
		return -- 99
	end -- 99
	self.isLoading = true -- 100
	if reload then -- 100
		self.packages = {} -- 102
		self.repos = {} -- 103
		self.previewTextures:clear() -- 104
		self.previewFiles:clear() -- 105
		local cachePath = Path(Content.appPath, ".cache", "preview") -- 106
		Content:remove(cachePath) -- 107
	end -- 107
	thread(function() -- 109
		local cachePath = Path(Content.appPath, ".cache", "preview") -- 111
		Content:mkdir(cachePath) -- 112
		local packagesFile = Path(cachePath, "packages.json") -- 113
		if Content:exist(packagesFile) then -- 113
			local packages = json.load(Content:load(packagesFile)) -- 115
			self.packages = packages -- 116
		else -- 116
			local packagesResponse = HttpClient:getAsync("http://39.155.148.157:8866/api/v1/packages") -- 118
			if packagesResponse then -- 118
				local packages = json.load(packagesResponse) -- 121
				self.packages = packages -- 122
				Content:save(packagesFile, packagesResponse) -- 123
			end -- 123
		end -- 123
		local reposFile = Path(cachePath, "repos.json") -- 128
		if Content:exist(reposFile) then -- 128
			local repos = json.load(Content:load(reposFile)) -- 130
			self.repos = repos -- 131
		else -- 131
			local reposResponse = HttpClient:getAsync("http://39.155.148.157:8866/assets/repos.json") -- 133
			if reposResponse then -- 133
				local repos = json.load(reposResponse) -- 135
				self.repos = repos -- 136
				Content:save(reposFile, reposResponse) -- 137
			end -- 137
		end -- 137
		for ____, pkg in ipairs(self.packages) do -- 142
			local downloadPath = Path(Content.writablePath, "Download", pkg.name) -- 143
			if Content:exist(downloadPath) then -- 143
				self.downloadedPackages:add(pkg.name) -- 145
			end -- 145
			self:loadPreviewImage(pkg.name) -- 147
		end -- 147
		self.isLoading = false -- 149
	end) -- 109
end -- 98
function ResourceDownloader.prototype.loadPreviewImage(self, name) -- 153
	local cachePath = Path(Content.appPath, ".cache", "preview") -- 154
	local cacheFile = Path(cachePath, name .. ".jpg") -- 155
	if Content:exist(cacheFile) then -- 155
		Cache:loadAsync(cacheFile) -- 157
		local texture = Texture2D(cacheFile) -- 158
		if texture then -- 158
			self.previewTextures:set(name, texture) -- 160
			self.previewFiles:set(name, cacheFile) -- 161
		end -- 161
		return -- 163
	end -- 163
	local imageUrl = ("http://39.155.148.157:8866/assets/" .. name) .. "/banner.jpg" -- 165
	local response = HttpClient:downloadAsync(imageUrl, cacheFile, 10) -- 166
	if response then -- 166
		Cache:loadAsync(cacheFile) -- 168
		local texture = Texture2D(cacheFile) -- 169
		if texture then -- 169
			self.previewTextures:set(name, texture) -- 171
			self.previewFiles:set(name, cacheFile) -- 172
		end -- 172
	else -- 172
		print("Failed to load preview image for " .. name) -- 175
	end -- 175
end -- 153
function ResourceDownloader.prototype.isDownloaded(self, name) -- 179
	return self.downloadedPackages:has(name) -- 180
end -- 179
function ResourceDownloader.prototype.downloadPackage(self, pkg) -- 183
	if self.downloadTasks:has(pkg.name) then -- 183
		return -- 185
	end -- 185
	local task = thread(function() -- 188
		self.isDownloading = true -- 189
		local downloadStatus = (zh and "正在下载：" or "Downloading: ") .. pkg.name -- 190
		local downloadPath = Path(Content.writablePath, ".download") -- 191
		Content:mkdir(downloadPath) -- 192
		local targetFile = Path(downloadPath, pkg.latest.file) -- 193
		local success = HttpClient:downloadAsync( -- 195
			pkg.latest.download, -- 196
			targetFile, -- 197
			30, -- 198
			function(current, total) -- 199
				if self.cancelDownload then -- 199
					return true -- 201
				end -- 201
				self.downloadProgress:set(pkg.name, {progress = current / total, status = downloadStatus}) -- 203
				return false -- 204
			end -- 199
		) -- 199
		if success then -- 199
			downloadStatus = zh and "解压中：" .. pkg.name or "Unziping: " .. pkg.name -- 209
			self.downloadProgress:set(pkg.name, {progress = 1, status = downloadStatus}) -- 210
			local unzipPath = Path(Content.writablePath, "Download", pkg.name) -- 211
			Content:remove(unzipPath) -- 212
			if Content:unzipAsync(targetFile, unzipPath) then -- 212
				Content:remove(targetFile) -- 214
				self.downloadedPackages:add(pkg.name) -- 215
			else -- 215
				Content:remove(unzipPath) -- 217
				self:showPopup(zh and "解压失败" or "Failed to unzip", zh and "无法解压文件：" .. pkg.latest.file or "Failed to unzip: " .. pkg.latest.file) -- 218
			end -- 218
		else -- 218
			Content:remove(targetFile) -- 224
			self:showPopup(zh and "下载失败" or "Download failed", zh and "无法从该地址下载：" .. pkg.latest.download or "Failed to download from: " .. pkg.latest.download) -- 225
		end -- 225
		self.isDownloading = false -- 231
		self.downloadProgress:delete(pkg.name) -- 232
		self.downloadTasks:delete(pkg.name) -- 233
	end) -- 188
	self.downloadTasks:set(pkg.name, task) -- 236
end -- 183
function ResourceDownloader.prototype.messagePopup(self) -- 239
	ImGui.Text(self.popupMessageTitle) -- 240
	ImGui.Separator() -- 241
	ImGui.PushTextWrapPos( -- 242
		300, -- 242
		function() -- 242
			ImGui.TextWrapped(self.popupMessage) -- 243
		end -- 242
	) -- 242
	if ImGui.Button( -- 242
		zh and "确认" or "OK", -- 245
		Vec2(300, 30) -- 245
	) then -- 245
		ImGui.CloseCurrentPopup() -- 246
	end -- 246
end -- 239
function ResourceDownloader.prototype.update(self) -- 250
	local ____App_visualSize_0 = App.visualSize -- 251
	local width = ____App_visualSize_0.width -- 251
	local height = ____App_visualSize_0.height -- 251
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 252
	ImGui.SetNextWindowSize( -- 253
		Vec2(width, 51), -- 253
		"Always" -- 253
	) -- 253
	ImGui.PushStyleVar( -- 254
		"WindowPadding", -- 254
		Vec2(10, 0), -- 254
		function() return ImGui.Begin( -- 254
			"Dora Community Header", -- 254
			windowsNoScrollFlags, -- 254
			function() -- 254
				ImGui.Dummy(Vec2(0, 0)) -- 255
				ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Resources") -- 256
				ImGui.SameLine() -- 257
				ImGui.TextDisabled("(?)") -- 258
				if ImGui.IsItemHovered() then -- 258
					ImGui.BeginTooltip(function() -- 260
						ImGui.PushTextWrapPos( -- 261
							300, -- 261
							function() -- 261
								ImGui.Text(zh and "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" or "Use this tool to download Dora SSR community resources to the `Download` directory.") -- 262
							end -- 261
						) -- 261
					end) -- 260
				end -- 260
				ImGui.SameLine() -- 266
				if self.isDownloading or self.isLoading then -- 266
					ImGui.BeginDisabled(function() -- 268
						ImGui.Button(zh and "刷新" or "Refresh") -- 269
					end) -- 268
				else -- 268
					if ImGui.Button(zh and "刷新" or "Refresh") then -- 268
						self:loadData(true) -- 273
					end -- 273
				end -- 273
				local padding = zh and 400 or 440 -- 276
				if width >= padding then -- 276
					ImGui.SameLine() -- 278
					ImGui.Dummy(Vec2(width - padding, 0)) -- 279
					ImGui.SameLine() -- 280
					ImGui.SetNextItemWidth(zh and -40 or -55) -- 281
					if ImGui.InputText(zh and "筛选" or "Filter", self.filterBuf, {"AutoSelectAll"}) then -- 281
						local res = string.match(self.filterBuf.text, "[^%%%.%[]+") -- 283
						self.filterText = string.lower(res or "") -- 284
					end -- 284
				end -- 284
				ImGui.Separator() -- 287
			end -- 254
		) end -- 254
	) -- 254
	local maxColumns = math.max( -- 289
		math.floor(width / 350), -- 289
		1 -- 289
	) -- 289
	local itemWidth = (width - 60) / maxColumns - 10 -- 290
	ImGui.SetNextWindowPos( -- 291
		Vec2(0, 51), -- 291
		"Always", -- 291
		Vec2.zero -- 291
	) -- 291
	ImGui.SetNextWindowSize( -- 292
		Vec2(width, height - 100), -- 292
		"Always" -- 292
	) -- 292
	ImGui.PushStyleVar( -- 293
		"WindowPadding", -- 293
		Vec2(20, 10), -- 293
		function() return ImGui.Begin( -- 293
			"Dora Community Resources", -- 293
			windowsFlags, -- 293
			function() -- 293
				ImGui.Columns(maxColumns, false) -- 294
				for ____, pkg in ipairs(self.packages) do -- 297
					do -- 297
						local repo = __TS__ArrayFind( -- 298
							self.repos, -- 298
							function(____, r) return r.name == pkg.name end -- 298
						) -- 298
						if not repo then -- 298
							goto __continue55 -- 299
						end -- 299
						if self.filterText ~= "" then -- 299
							local res = string.match( -- 302
								string.lower(repo.name), -- 302
								self.filterText -- 302
							) -- 302
							if not res then -- 302
								goto __continue55 -- 303
							end -- 303
						end -- 303
						ImGui.TextColored(themeColor, repo.title[zh and "zh" or "en"]) -- 307
						local previewTexture = self.previewTextures:get(pkg.name) -- 310
						if previewTexture then -- 310
							local width = previewTexture.width -- 310
							local height = previewTexture.height -- 310
							local scale = itemWidth / width -- 314
							local scaledSize = Vec2(width * scale, height * scale) -- 315
							local previewFile = self.previewFiles:get(pkg.name) -- 316
							if previewFile then -- 316
								ImGui.Image(previewFile, scaledSize) -- 318
							end -- 318
						else -- 318
							ImGui.Text(zh and "加载预览图中..." or "Loading preview...") -- 321
						end -- 321
						ImGui.TextWrapped(repo.desc[zh and "zh" or "en"]) -- 324
						ImGui.TextColored(themeColor, zh and "项目地址：" or "Repo URL:") -- 326
						ImGui.SameLine() -- 327
						ImGui.TextLinkOpenURL((zh and "这里" or "here") .. "###" .. pkg.url, pkg.url) -- 328
						ImGui.TextColored(themeColor, zh and "同步时间：" or "Updated:") -- 330
						ImGui.SameLine() -- 331
						local dateStr = __TS__StringReplace( -- 332
							__TS__StringReplace(pkg.latest.updatedAt, "T", " "), -- 332
							"Z", -- 332
							"" -- 332
						) -- 332
						ImGui.Text(dateStr) -- 333
						local progress = self.downloadProgress:get(pkg.name) -- 336
						if progress ~= nil then -- 336
							ImGui.ProgressBar( -- 338
								progress.progress, -- 338
								Vec2(-1, 30) -- 338
							) -- 338
							ImGui.BeginDisabled(function() -- 339
								ImGui.Button(progress.status) -- 340
							end) -- 339
						end -- 339
						if progress == nil then -- 339
							local isDownloaded = self:isDownloaded(pkg.name) -- 346
							local buttonText = isDownloaded and (zh and "重新下载" or "Download Again") or (zh and "下载" or "Download") -- 347
							if self.isDownloading then -- 347
								ImGui.BeginDisabled(function() -- 351
									ImGui.PushID( -- 352
										pkg.name, -- 352
										function() -- 352
											ImGui.Button(buttonText) -- 353
										end -- 352
									) -- 352
								end) -- 351
							else -- 351
								ImGui.PushID( -- 357
									pkg.name, -- 357
									function() -- 357
										if ImGui.Button(buttonText) then -- 357
											self:downloadPackage(pkg) -- 359
										end -- 359
									end -- 357
								) -- 357
							end -- 357
						end -- 357
						ImGui.SameLine() -- 366
						ImGui.Text(__TS__NumberToFixed(pkg.latest.size / 1024 / 1024, 2) .. " MB") -- 367
						thinSep() -- 369
						ImGui.NextColumn() -- 370
					end -- 370
					::__continue55:: -- 370
				end -- 370
				ImGui.ScrollWhenDraggingOnVoid() -- 373
				if self.popupShow then -- 373
					self.popupShow = false -- 376
					ImGui.OpenPopup("MessagePopup") -- 377
				end -- 377
				ImGui.BeginPopupModal( -- 379
					"MessagePopup", -- 379
					function() return self:messagePopup() end -- 379
				) -- 379
			end -- 293
		) end -- 293
	) -- 293
end -- 250
__TS__New(ResourceDownloader) -- 384
return ____exports -- 384