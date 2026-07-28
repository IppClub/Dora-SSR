-- [ts]: ResourceDownloader.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__Iterator = ____lualib.__TS__Iterator -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Set = ____lualib.Set -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Buffer = ____Dora.Buffer -- 2
local Cache = ____Dora.Cache -- 2
local Color = ____Dora.Color -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local Node = ____Dora.Node -- 2
local Path = ____Dora.Path -- 2
local Texture2D = ____Dora.Texture2D -- 2
local thread = ____Dora.thread -- 2
local Vec2 = ____Dora.Vec2 -- 2
local ImGui = require("ImGui") -- 4
local ____Catalog = require("Script.Tools.ResourceDownloader.Catalog") -- 5
local filterResources = ____Catalog.filterResources -- 6
local isMinigame = ____Catalog.isMinigame -- 7
local paginateResources = ____Catalog.paginateResources -- 8
local ____CatalogSync = require("Script.Tools.ResourceDownloader.CatalogSync") -- 12
local loadCachedCatalog = ____CatalogSync.loadCachedCatalog -- 13
local syncCatalog = ____CatalogSync.syncCatalog -- 14
local ____GitInstaller = require("Script.Tools.ResourceDownloader.GitInstaller") -- 18
local getResourceInstallPath = ____GitInstaller.getResourceInstallPath -- 19
local installResource = ____GitInstaller.installResource -- 20
local isResourceInstalled = ____GitInstaller.isResourceInstalled -- 21
local windowsNoScrollFlags = { -- 25
	"NoMove", -- 26
	"NoCollapse", -- 27
	"NoResize", -- 28
	"NoDecoration", -- 29
	"NoSavedSettings", -- 30
	"NoFocusOnAppearing", -- 31
	"NoBringToFrontOnFocus" -- 32
} -- 32
local ____array_0 = __TS__SparseArrayNew(table.unpack(windowsNoScrollFlags)) -- 32
__TS__SparseArrayPush(____array_0, "AlwaysVerticalScrollbar") -- 32
local windowsFlags = {__TS__SparseArraySpread(____array_0)} -- 35
local tabBarFlags = {"FittingPolicyScroll", "DrawSelectedOverline", "NoCloseWithMiddleMouseButton", "TabListPopupButton"} -- 40
local zh = false -- 47
do -- 47
	local matchedLocale = string.match(App.locale, "^zh") -- 49
	zh = matchedLocale ~= nil -- 50
end -- 50
local themeColor = App.themeColor -- 52
local function defaultBanner() -- 53
	return Path(Content.assetPath, "Image", "banner.jpg") -- 53
end -- 53
local function run(fileName) -- 55
	local Entry = require("Script.Dev.Entry") -- 56
	Entry.allClear() -- 57
	thread(function() return Entry.enterEntryAsync({entryName = "Project", fileName = fileName}) end) -- 58
end -- 55
local function displayText(text, limit) -- 61
	return #text <= limit and text or __TS__StringSubstring(text, 0, limit - 1) .. "…" -- 62
end -- 61
local ResourceDownloader = __TS__Class() -- 64
ResourceDownloader.name = "ResourceDownloader" -- 64
function ResourceDownloader.prototype.____constructor(self) -- 91
	self.filterBuffer = Buffer(80) -- 66
	self.resources = {} -- 67
	self.categories = {} -- 68
	self.section = "featured" -- 70
	self.categoryIndex = 1 -- 71
	self.filterText = "" -- 72
	self.page = 0 -- 73
	self.headerHeight = 118 -- 74
	self.isCatalogLoading = false -- 75
	self.catalogWarning = "" -- 77
	self.catalogError = "" -- 78
	self.cancelOperations = false -- 79
	self.popupTitle = "" -- 82
	self.popupMessage = "" -- 83
	self.popupShow = false -- 84
	self.deletePopupShow = false -- 86
	self.previewTextures = __TS__New(Map) -- 87
	self.pendingPreviews = __TS__New(Set) -- 88
	self.previewOrder = {} -- 89
	self.node = Node() -- 92
	self.node:schedule(function() -- 93
		self:update() -- 94
		return false -- 95
	end) -- 93
	self.node:onCleanup(function() -- 97
		self.cancelOperations = true -- 98
		for ____, file in __TS__Iterator(self.previewTextures:keys()) do -- 99
			Cache:unload(file) -- 99
		end -- 99
		self.previewTextures:clear() -- 100
		self.pendingPreviews:clear() -- 101
	end) -- 97
	local cached = loadCachedCatalog() -- 103
	if cached.success and cached.snapshot then -- 103
		self:applySnapshot(cached.snapshot) -- 104
	end -- 104
	self:refreshCatalog(false) -- 105
end -- 91
function ResourceDownloader.prototype.applySnapshot(self, snapshot) -- 108
	self.snapshot = snapshot -- 109
	self.resources = snapshot.catalog.resources -- 110
	self.categories = snapshot.catalog.categories -- 111
	self.page = 0 -- 112
end -- 108
function ResourceDownloader.prototype.refreshCatalog(self, force) -- 115
	if self.isCatalogLoading then -- 115
		return -- 116
	end -- 116
	self.isCatalogLoading = true -- 117
	self.catalogError = "" -- 118
	self.catalogWarning = ""; -- 119
	(function() -- 120
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 120
			local result = __TS__Await(syncCatalog({ -- 121
				force = force, -- 122
				isCanceled = function() return self.cancelOperations end, -- 123
				onStatus = function(____, status) -- 124
					if self.isCatalogLoading then -- 124
						self.catalogStatus = status -- 125
					end -- 125
				end -- 124
			})) -- 124
			self.isCatalogLoading = false -- 128
			self.catalogStatus = nil -- 129
			if result.success and result.snapshot then -- 129
				self:applySnapshot(result.snapshot) -- 131
				if result.usedCache and result.message then -- 131
					self.catalogWarning = result.message -- 132
				end -- 132
			else -- 132
				self.catalogError = result.message or (zh and "资源目录同步失败" or "Catalog synchronization failed") -- 134
			end -- 134
		end) -- 134
	end)() -- 120
end -- 115
function ResourceDownloader.prototype.showMessage(self, title, message) -- 139
	self.popupTitle = title -- 140
	self.popupMessage = message -- 141
	self.popupShow = true -- 142
end -- 139
function ResourceDownloader.prototype.touchPreview(self, file) -- 145
	local oldIndex = __TS__ArrayIndexOf(self.previewOrder, file) -- 146
	if oldIndex >= 0 then -- 146
		__TS__ArraySplice(self.previewOrder, oldIndex, 1) -- 147
	end -- 147
	local ____self_previewOrder_1 = self.previewOrder -- 147
	____self_previewOrder_1[#____self_previewOrder_1 + 1] = file -- 148
	while #self.previewOrder > 36 do -- 148
		local expiredFile = table.remove(self.previewOrder, 1) -- 150
		if not expiredFile then -- 150
			break -- 151
		end -- 151
		self.previewTextures:delete(expiredFile) -- 152
		Cache:unload(expiredFile) -- 153
	end -- 153
end -- 145
function ResourceDownloader.prototype.loadPreview(self, resource) -- 157
	local file = resource.bannerPath or defaultBanner() -- 158
	local existing = self.previewTextures:get(file) -- 159
	if existing then -- 159
		self:touchPreview(file) -- 161
		return existing -- 162
	end -- 162
	if self.pendingPreviews:has(file) then -- 162
		return nil -- 164
	end -- 164
	if not Content:exist(file) then -- 164
		return nil -- 165
	end -- 165
	self.pendingPreviews:add(file) -- 166
	thread(function() -- 167
		Cache:loadAsync(file) -- 168
		self.pendingPreviews:delete(file) -- 169
		if self.cancelOperations then -- 169
			return -- 170
		end -- 170
		local texture = Texture2D(file) -- 171
		if not texture then -- 171
			return -- 172
		end -- 172
		if texture.width > 4096 or texture.height > 4096 then -- 172
			Cache:unload(file) -- 174
			return -- 175
		end -- 175
		self.previewTextures:set(file, texture) -- 177
		self:touchPreview(file) -- 178
	end) -- 167
	return nil -- 180
end -- 157
function ResourceDownloader.prototype.selectedVersion(self, resource) -- 183
	local index = math.max( -- 184
		1, -- 184
		math.min(resource.selectedVersion, #resource.versions) -- 184
	) -- 184
	resource.selectedVersion = index -- 185
	return resource.versions[index] -- 186
end -- 183
function ResourceDownloader.prototype.install(self, resource) -- 189
	if self.installingId or not self.snapshot then -- 189
		return -- 190
	end -- 190
	local version = self:selectedVersion(resource) -- 191
	self.installingId = resource.id -- 192
	self.installProgress = {progress = 0, message = zh and "准备安装" or "Preparing installation"}; -- 193
	(function() -- 194
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 194
			local ____installResource_5 = installResource -- 195
			local ____resource_4 = resource -- 195
			local ____opt_2 = self.snapshot -- 195
			local result = __TS__Await(____installResource_5( -- 195
				____resource_4, -- 195
				version, -- 195
				{ -- 195
					catalogCommit = ____opt_2 and ____opt_2.commit or "", -- 196
					isCanceled = function() return self.cancelOperations end, -- 197
					onProgress = function(____, progress) -- 198
						self.installProgress = progress -- 199
					end -- 198
				} -- 198
			)) -- 198
			self.installingId = nil -- 202
			self.installProgress = nil -- 203
			if not result.success and not result.canceled then -- 203
				self:showMessage(zh and "安装失败" or "Installation failed", result.message or (zh and "无法安装资源" or "Could not install the resource")) -- 205
			end -- 205
		end) -- 205
	end)() -- 194
end -- 189
function ResourceDownloader.prototype.runResource(self, resource) -- 213
	local basePath = getResourceInstallPath(resource.id) -- 214
	if #resource.entrypoints == 0 then -- 214
		run(Path(basePath, "init")) -- 216
		return -- 217
	end -- 217
	if #resource.entrypoints == 1 then -- 217
		run(Path(basePath, resource.entrypoints[1].path)) -- 220
		return -- 221
	end -- 221
	ImGui.OpenPopup("run-" .. resource.id) -- 223
end -- 213
function ResourceDownloader.prototype.drawRunPopup(self, resource) -- 226
	if #resource.entrypoints <= 1 then -- 226
		return -- 227
	end -- 227
	ImGui.BeginPopup( -- 228
		"run-" .. resource.id, -- 228
		function() -- 228
			for ____, entry in ipairs(resource.entrypoints) do -- 229
				if ImGui.Selectable((((entry.name .. "##") .. resource.id) .. "-") .. entry.path) then -- 229
					run(Path( -- 231
						getResourceInstallPath(resource.id), -- 231
						entry.path -- 231
					)) -- 231
				end -- 231
			end -- 231
		end -- 228
	) -- 228
end -- 226
function ResourceDownloader.prototype.drawStatusLine(self) -- 237
	if self.catalogStatus then -- 237
		ImGui.TextDisabled(self.catalogStatus.message) -- 239
		ImGui.SameLine() -- 240
		ImGui.ProgressBar( -- 241
			self.catalogStatus.progress, -- 241
			Vec2(130, 0) -- 241
		) -- 241
		return -- 242
	end -- 242
	if self.snapshot then -- 242
		ImGui.TextDisabled(((zh and "目录" or "Catalog") .. " ") .. __TS__StringSubstring(self.snapshot.commit, 0, 8)) -- 245
		if ImGui.IsItemHovered() then -- 245
			ImGui.BeginTooltip(function() -- 249
				ImGui.PushTextWrapPos( -- 250
					420, -- 250
					function() -- 250
						local ____ImGui_TextWrapped_9 = ImGui.TextWrapped -- 251
						local ____temp_8 = zh and "来源" or "Source" -- 251
						local ____opt_6 = self.snapshot -- 251
						____ImGui_TextWrapped_9((____temp_8 .. ": ") .. (____opt_6 and ____opt_6.source or "")) -- 251
						local ____ImGui_Text_13 = ImGui.Text -- 252
						local ____temp_12 = zh and "同步时间" or "Synced" -- 252
						local ____opt_10 = self.snapshot -- 252
						____ImGui_Text_13((____temp_12 .. ": ") .. (____opt_10 and ____opt_10.syncedAt or "")) -- 252
					end -- 250
				) -- 250
			end) -- 249
		end -- 249
		return -- 256
	end -- 256
	ImGui.TextDisabled(self.catalogError ~= "" and (zh and "目录不可用" or "Catalog unavailable") or (zh and "正在获取资源目录…" or "Fetching the resource catalog…")) -- 258
end -- 237
function ResourceDownloader.prototype.drawHeader(self, width) -- 265
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 266
	ImGui.SetNextWindowSize( -- 267
		Vec2(width, self.headerHeight), -- 267
		"Always" -- 267
	) -- 267
	ImGui.PushStyleVar( -- 268
		"WindowPadding", -- 268
		Vec2(16, 8), -- 268
		function() -- 268
			ImGui.Begin( -- 269
				"Dora Resource Catalog Header", -- 269
				windowsNoScrollFlags, -- 269
				function() -- 269
					ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Community") -- 270
					ImGui.SameLine() -- 271
					self:drawStatusLine() -- 272
					local refreshWidth = zh and 80 or 85 -- 273
					ImGui.SameLine() -- 274
					ImGui.Dummy(Vec2( -- 275
						math.max( -- 275
							0, -- 275
							width - ImGui.GetCursorPosX() - refreshWidth - 24 -- 275
						), -- 275
						0 -- 275
					)) -- 275
					ImGui.SameLine() -- 276
					if self.isCatalogLoading then -- 276
						ImGui.BeginDisabled(function() return ImGui.Button( -- 278
							zh and "同步中" or "Syncing", -- 278
							Vec2(refreshWidth, 0) -- 278
						) end) -- 278
					elseif ImGui.Button( -- 278
						zh and "刷新目录" or "Refresh", -- 279
						Vec2(refreshWidth, 0) -- 279
					) then -- 279
						self:refreshCatalog(true) -- 280
					end -- 280
					if self.catalogError ~= "" then -- 280
						ImGui.TextColored( -- 284
							Color(4294924890), -- 284
							displayText(self.catalogError, 150) -- 284
						) -- 284
					elseif self.catalogWarning ~= "" then -- 284
						ImGui.TextColored( -- 286
							Color(4284920831), -- 286
							displayText(self.catalogWarning, 150) -- 286
						) -- 286
					else -- 286
						ImGui.TextDisabled(zh and "项目通过 Git 安装到 Download；安装后可通过 Git 继续更新和维护。" or "Projects are installed with Git. After installation, your Git workflow owns updates and local changes.") -- 288
					end -- 288
					ImGui.BeginTabBar( -- 295
						"resource-sections", -- 295
						tabBarFlags, -- 295
						function() -- 295
							ImGui.BeginTabItem( -- 296
								zh and "作品" or "Projects", -- 296
								function() -- 296
									if self.section ~= "featured" then -- 296
										self.section = "featured" -- 298
										self.page = 0 -- 299
									end -- 299
								end -- 296
							) -- 296
							ImGui.BeginTabItem( -- 302
								"Mini Games", -- 302
								function() -- 302
									if self.section ~= "minigame" then -- 302
										self.section = "minigame" -- 304
										self.page = 0 -- 305
									end -- 305
								end -- 302
							) -- 302
							ImGui.BeginTabItem( -- 308
								zh and "全部" or "All", -- 308
								function() -- 308
									if self.section ~= "all" then -- 308
										self.section = "all" -- 310
										self.page = 0 -- 311
									end -- 311
								end -- 308
							) -- 308
						end -- 295
					) -- 295
					ImGui.SameLine() -- 316
					ImGui.SetNextItemWidth(zh and 150 or 165) -- 317
					local categoryNames = { -- 318
						zh and "全部分类" or "All categories", -- 318
						table.unpack(self.categories) -- 318
					} -- 318
					local categoryChanged, categoryIndex = ImGui.Combo("##resource-category", self.categoryIndex, categoryNames) -- 319
					if categoryChanged then -- 319
						self.categoryIndex = categoryIndex -- 321
						self.page = 0 -- 322
					end -- 322
					ImGui.SameLine() -- 324
					ImGui.TextDisabled(zh and "搜索" or "Search") -- 325
					ImGui.SameLine() -- 326
					ImGui.SetNextItemWidth(-1) -- 327
					if ImGui.InputText("##resource-search", self.filterBuffer, {"AutoSelectAll"}) then -- 327
						self.filterText = self.filterBuffer.text -- 329
						self.page = 0 -- 330
					end -- 330
				end -- 269
			) -- 269
		end -- 268
	) -- 268
end -- 265
function ResourceDownloader.prototype.drawPreview(self, resource, itemWidth) -- 336
	local texture = self:loadPreview(resource) -- 337
	local availableWidth = itemWidth - 20 -- 338
	local previewHeight = 150 -- 339
	if not texture then -- 339
		ImGui.Dummy(Vec2(availableWidth, previewHeight)) -- 341
		return -- 342
	end -- 342
	local scale = math.min(availableWidth / texture.width, previewHeight / texture.height) -- 344
	local imageWidth = texture.width * scale -- 345
	local imageHeight = texture.height * scale -- 346
	if imageWidth < availableWidth then -- 346
		ImGui.Dummy(Vec2((availableWidth - imageWidth) / 2, 0)) -- 348
		ImGui.SameLine() -- 349
	end -- 349
	ImGui.Image( -- 351
		resource.bannerPath or defaultBanner(), -- 351
		Vec2(imageWidth, imageHeight) -- 351
	) -- 351
	if imageHeight < previewHeight then -- 351
		ImGui.Dummy(Vec2(0, previewHeight - imageHeight)) -- 352
	end -- 352
end -- 336
function ResourceDownloader.prototype.drawResourceCard(self, resource, itemWidth) -- 355
	local title = resource.title[zh and "zh-Hans" or "en"] -- 356
	local description = resource.description[zh and "zh-Hans" or "en"] -- 357
	local version = self:selectedVersion(resource) -- 358
	local installed = isResourceInstalled(resource.id) -- 359
	ImGui.BeginChild( -- 360
		"card-" .. resource.id, -- 360
		Vec2(itemWidth, 420), -- 360
		function() -- 360
			ImGui.TextColored( -- 361
				themeColor, -- 361
				displayText(title, 46) -- 361
			) -- 361
			if isMinigame(resource) then -- 361
				ImGui.SameLine() -- 363
				ImGui.TextDisabled("MINI") -- 364
			end -- 364
			if resource.status ~= "active" then -- 364
				ImGui.SameLine() -- 367
				ImGui.TextDisabled(string.upper(resource.status)) -- 368
			end -- 368
			self:drawPreview(resource, itemWidth) -- 370
			ImGui.PushTextWrapPos( -- 371
				itemWidth - 12, -- 371
				function() -- 371
					ImGui.TextWrapped(displayText(description, 190)) -- 372
				end -- 371
			) -- 371
			ImGui.TextDisabled((((version.name .. " · ") .. __TS__StringSubstring(version.commit, 0, 8)) .. " · ") .. (resource.license.status == "pending" and (zh and "许可待完善" or "license pending") or resource.license.spdx)) -- 374
			local source = version.sources[1] -- 381
			if source ~= nil and ImGui.TextLink(((zh and "项目仓库" or "Repository") .. "##repo-") .. resource.id) then -- 381
				App:openURL(source.url) -- 383
			end -- 383
			if source ~= nil and ImGui.IsItemHovered() then -- 383
				ImGui.BeginTooltip(function() -- 386
					ImGui.PushTextWrapPos( -- 387
						420, -- 387
						function() return ImGui.Text(source.url) end -- 387
					) -- 387
				end) -- 386
			end -- 386
			local versionNames = __TS__ArrayMap( -- 390
				resource.versions, -- 390
				function(____, item) return ((item.name .. " (") .. __TS__StringSubstring(item.commit, 0, 7)) .. ")" end -- 390
			) -- 390
			if #versionNames > 1 and not installed then -- 390
				ImGui.SetNextItemWidth(-1) -- 392
				local changed, selected = ImGui.Combo("##version-" .. resource.id, resource.selectedVersion, versionNames) -- 393
				if changed then -- 393
					resource.selectedVersion = selected -- 394
				end -- 394
			end -- 394
			local currentInstall = self.installingId == resource.id -- 396
			if currentInstall and self.installProgress then -- 396
				ImGui.ProgressBar( -- 398
					self.installProgress.progress, -- 398
					Vec2(-1, 26) -- 398
				) -- 398
				ImGui.TextDisabled(displayText(self.installProgress.message, 60)) -- 399
			elseif installed then -- 399
				if resource.runnable and resource.status ~= "blocked" then -- 399
					if ImGui.Button(((zh and "测试" or "Run") .. "##run-button-") .. resource.id) then -- 399
						self:runResource(resource) -- 403
					end -- 403
					ImGui.SameLine() -- 405
				end -- 405
				ImGui.BeginDisabled(function() return ImGui.Button(((zh and "已安装" or "Installed") .. "##installed-") .. resource.id) end) -- 407
				ImGui.SameLine() -- 408
				if ImGui.Button(((zh and "删除" or "Delete") .. "##delete-") .. resource.id) then -- 408
					self.deleteResource = resource -- 410
					self.deletePopupShow = true -- 411
				end -- 411
			else -- 411
				local cannotInstall = self.installingId ~= nil or resource.status == "unavailable" or resource.status == "blocked" or not self.snapshot -- 414
				if cannotInstall then -- 414
					ImGui.BeginDisabled(function() return ImGui.Button(((zh and "安装" or "Install") .. "##install-") .. resource.id) end) -- 419
				elseif ImGui.Button(((zh and "安装" or "Install") .. "##install-") .. resource.id) then -- 419
					self:install(resource) -- 421
				end -- 421
			end -- 421
			self:drawRunPopup(resource) -- 424
		end -- 360
	) -- 360
end -- 355
function ResourceDownloader.prototype.drawDeletePopup(self) -- 428
	local popupTitle = zh and "删除项目" or "Delete project" -- 429
	if self.deletePopupShow then -- 429
		self.deletePopupShow = false -- 431
		ImGui.OpenPopup(popupTitle) -- 432
	end -- 432
	ImGui.BeginPopupModal( -- 434
		popupTitle, -- 434
		function() -- 434
			local resource = self.deleteResource -- 435
			if not resource then -- 435
				ImGui.CloseCurrentPopup() -- 437
				return -- 438
			end -- 438
			ImGui.TextWrapped(zh and ("将删除 Download/" .. resource.id) .. "，其中可能包含你的 Git 提交和本地修改。" or ("This removes Download/" .. resource.id) .. ", including any local Git commits and changes.") -- 440
			if ImGui.Button( -- 440
				zh and "取消" or "Cancel", -- 445
				Vec2(120, 30) -- 445
			) then -- 445
				self.deleteResource = nil -- 446
				ImGui.CloseCurrentPopup() -- 447
			end -- 447
			ImGui.SameLine() -- 449
			if ImGui.Button( -- 449
				zh and "确认删除" or "Delete", -- 450
				Vec2(120, 30) -- 450
			) then -- 450
				local removed = Content:remove(getResourceInstallPath(resource.id)) -- 451
				self.deleteResource = nil -- 452
				if removed then -- 452
					Director.postNode:emit("UpdateEntries") -- 454
				else -- 454
					self:showMessage(zh and "删除失败" or "Deletion failed", zh and "无法删除项目目录，请检查文件是否正被占用。" or "Could not remove the project directory.") -- 456
				end -- 456
				ImGui.CloseCurrentPopup() -- 461
			end -- 461
		end -- 434
	) -- 434
end -- 428
function ResourceDownloader.prototype.drawMessagePopup(self) -- 466
	if self.popupShow then -- 466
		self.popupShow = false -- 468
		ImGui.OpenPopup("ResourceMessage") -- 469
	end -- 469
	ImGui.BeginPopupModal( -- 471
		"ResourceMessage", -- 471
		function() -- 471
			ImGui.Text(self.popupTitle) -- 472
			ImGui.Separator() -- 473
			ImGui.PushTextWrapPos( -- 474
				380, -- 474
				function() return ImGui.TextWrapped(self.popupMessage) end -- 474
			) -- 474
			if ImGui.Button( -- 474
				zh and "确认" or "OK", -- 475
				Vec2(380, 30) -- 475
			) then -- 475
				ImGui.CloseCurrentPopup() -- 475
			end -- 475
		end -- 471
	) -- 471
end -- 466
function ResourceDownloader.prototype.update(self) -- 479
	local ____App_visualSize_14 = App.visualSize -- 480
	local width = ____App_visualSize_14.width -- 480
	local height = ____App_visualSize_14.height -- 480
	self:drawHeader(width) -- 481
	local maxColumns = math.max( -- 482
		math.floor(width / 360), -- 482
		1 -- 482
	) -- 482
	local itemWidth = (width - 36 - (maxColumns - 1) * 12) / maxColumns -- 483
	local category = self.categoryIndex > 1 and self.categories[self.categoryIndex - 2 + 1] or nil -- 484
	local filtered = filterResources(self.resources, {section = self.section, category = category, query = self.filterText}) -- 485
	local pageSize = maxColumns * 3 -- 490
	local page = paginateResources(filtered, self.page, pageSize) -- 491
	self.page = page.page -- 492
	ImGui.SetNextWindowPos( -- 494
		Vec2(0, self.headerHeight), -- 494
		"Always", -- 494
		Vec2.zero -- 494
	) -- 494
	ImGui.SetNextWindowSize( -- 495
		Vec2(width, height - self.headerHeight), -- 495
		"Always" -- 495
	) -- 495
	ImGui.PushStyleVar( -- 496
		"WindowPadding", -- 496
		Vec2(14, 10), -- 496
		function() -- 496
			ImGui.Begin( -- 497
				"Dora Resource Catalog", -- 497
				windowsFlags, -- 497
				function() -- 497
					if #self.resources == 0 then -- 497
						ImGui.Dummy(Vec2(0, 30)) -- 499
						ImGui.TextWrapped(self.catalogError ~= "" and self.catalogError or (zh and "正在准备资源目录…" or "Preparing the resource catalog…")) -- 500
					else -- 500
						ImGui.TextDisabled(zh and ((((("共 " .. tostring(page.total)) .. " 项 · 第 ") .. tostring(page.page + 1)) .. "/") .. tostring(page.pageCount)) .. " 页" or (((tostring(page.total) .. " items · page ") .. tostring(page.page + 1)) .. "/") .. tostring(page.pageCount)) -- 506
						ImGui.SameLine() -- 511
						if page.page > 0 and ImGui.SmallButton(zh and "上一页" or "Previous") then -- 511
							self.page = self.page - 1 -- 512
						end -- 512
						if page.page > 0 then -- 512
							ImGui.SameLine() -- 513
						end -- 513
						if page.page + 1 < page.pageCount and ImGui.SmallButton(zh and "下一页" or "Next") then -- 513
							self.page = self.page + 1 -- 514
						end -- 514
						ImGui.Separator() -- 515
						ImGui.Columns(maxColumns, false) -- 516
						for ____, resource in ipairs(page.items) do -- 517
							self:drawResourceCard(resource, itemWidth) -- 518
							ImGui.NextColumn() -- 519
						end -- 519
						ImGui.Columns(1, false) -- 521
					end -- 521
					self:drawDeletePopup() -- 523
					self:drawMessagePopup() -- 524
					ImGui.ScrollWhenDraggingOnVoid() -- 525
				end -- 497
			) -- 497
		end -- 496
	) -- 496
end -- 479
__TS__New(ResourceDownloader) -- 531
return ____exports -- 531