-- [ts]: ResourceDownloader.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local Map = ____lualib.Map -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Set = ____lualib.Set -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
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
local ____CatalogSync = require("Script.Tools.ResourceDownloader.CatalogSync") -- 13
local loadCachedCatalog = ____CatalogSync.loadCachedCatalog -- 14
local syncCatalog = ____CatalogSync.syncCatalog -- 15
local ____GitInstaller = require("Script.Tools.ResourceDownloader.GitInstaller") -- 19
local getResourceInstallPath = ____GitInstaller.getResourceInstallPath -- 20
local installResource = ____GitInstaller.installResource -- 21
local isResourceInstalled = ____GitInstaller.isResourceInstalled -- 22
local windowsNoScrollFlags = { -- 26
	"NoMove", -- 27
	"NoCollapse", -- 28
	"NoResize", -- 29
	"NoDecoration", -- 30
	"NoSavedSettings", -- 31
	"NoFocusOnAppearing", -- 32
	"NoBringToFrontOnFocus" -- 33
} -- 33
local ____array_0 = __TS__SparseArrayNew(table.unpack(windowsNoScrollFlags)) -- 33
__TS__SparseArrayPush(____array_0, "AlwaysVerticalScrollbar") -- 33
local windowsFlags = {__TS__SparseArraySpread(____array_0)} -- 36
local tabBarFlags = {"FittingPolicyScroll", "DrawSelectedOverline", "NoCloseWithMiddleMouseButton", "TabListPopupButton"} -- 41
local zh = false -- 48
do -- 48
	local matchedLocale = string.match(App.locale, "^zh") -- 50
	zh = matchedLocale ~= nil -- 51
end -- 51
local themeColor = App.themeColor -- 53
local function defaultBanner() -- 54
	return Path(Content.assetPath, "Image", "banner.jpg") -- 54
end -- 54
local function run(fileName) -- 56
	local Entry = require("Script.Dev.Entry") -- 57
	Entry.allClear() -- 58
	thread(function() return Entry.enterEntryAsync({entryName = "Project", fileName = fileName}) end) -- 59
end -- 56
local function inlineText(text) -- 62
	local collapsed = string.gsub(text, "%s+", " ") -- 63
	local withoutLeadingSpace = string.gsub(collapsed, "^%s+", "") -- 64
	local trimmed = string.gsub(withoutLeadingSpace, "%s+$", "") -- 65
	return trimmed -- 66
end -- 62
local function truncateText(text, byteLimit) -- 69
	if string.len(text) <= byteLimit then -- 69
		return {text = text, truncated = false} -- 70
	end -- 70
	local nextCharacter = utf8.offset(text, 0, byteLimit + 1) or byteLimit + 1 -- 71
	return { -- 72
		text = string.sub(text, 1, nextCharacter - 1) .. "…", -- 73
		truncated = true -- 74
	} -- 74
end -- 69
local function displayText(text, byteLimit) -- 78
	return truncateText(text, byteLimit).text -- 78
end -- 78
local ResourceDownloader = __TS__Class() -- 80
ResourceDownloader.name = "ResourceDownloader" -- 80
function ResourceDownloader.prototype.____constructor(self) -- 110
	self.filterBuffer = Buffer(80) -- 82
	self.resources = {} -- 83
	self.categories = {} -- 84
	self.section = "featured" -- 86
	self.categoryIndex = 1 -- 87
	self.filterText = "" -- 88
	self.page = 0 -- 89
	self.resetListScroll = false -- 90
	self.headerHeight = 88 -- 91
	self.isCatalogLoading = false -- 92
	self.catalogWarning = "" -- 94
	self.catalogError = "" -- 95
	self.cancelOperations = false -- 96
	self.popupTitle = "" -- 99
	self.popupMessage = "" -- 100
	self.popupShow = false -- 101
	self.deletePopupShow = false -- 103
	self.detailsPopupShow = false -- 105
	self.previewTextures = __TS__New(Map) -- 106
	self.pendingPreviews = __TS__New(Set) -- 107
	self.previewOrder = {} -- 108
	self.node = Node() -- 111
	self.node:schedule(function() -- 112
		self:update() -- 113
		return false -- 114
	end) -- 112
	self.node:onCleanup(function() -- 116
		self.cancelOperations = true -- 117
		self.previewTextures:clear() -- 118
		self.pendingPreviews:clear() -- 119
	end) -- 116
	local cached = loadCachedCatalog() -- 121
	if cached.success and cached.snapshot then -- 121
		self:applySnapshot(cached.snapshot) -- 122
	end -- 122
	self:refreshCatalog(false) -- 123
end -- 110
function ResourceDownloader.prototype.applySnapshot(self, snapshot) -- 126
	self.snapshot = snapshot -- 127
	self.resources = snapshot.catalog.resources -- 128
	self.categories = snapshot.catalog.categories -- 129
	self.page = 0 -- 130
end -- 126
function ResourceDownloader.prototype.refreshCatalog(self, force) -- 133
	if self.isCatalogLoading then -- 133
		return -- 134
	end -- 134
	self.isCatalogLoading = true -- 135
	self.catalogError = "" -- 136
	self.catalogWarning = ""; -- 137
	(function() -- 138
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 138
			local result = __TS__Await(syncCatalog({ -- 139
				force = force, -- 140
				isCanceled = function() return self.cancelOperations end, -- 141
				onStatus = function(____, status) -- 142
					if self.isCatalogLoading then -- 142
						self.catalogStatus = status -- 143
					end -- 143
				end -- 142
			})) -- 142
			self.isCatalogLoading = false -- 146
			self.catalogStatus = nil -- 147
			if result.success and result.snapshot then -- 147
				self:applySnapshot(result.snapshot) -- 149
				if result.usedCache and result.message then -- 149
					self.catalogWarning = result.message -- 150
				end -- 150
			else -- 150
				self.catalogError = result.message or (zh and "资源目录同步失败" or "Catalog synchronization failed") -- 152
			end -- 152
		end) -- 152
	end)() -- 138
end -- 133
function ResourceDownloader.prototype.showMessage(self, title, message) -- 157
	self.popupTitle = title -- 158
	self.popupMessage = message -- 159
	self.popupShow = true -- 160
end -- 157
function ResourceDownloader.prototype.touchPreview(self, file) -- 163
	local oldIndex = __TS__ArrayIndexOf(self.previewOrder, file) -- 164
	if oldIndex >= 0 then -- 164
		__TS__ArraySplice(self.previewOrder, oldIndex, 1) -- 165
	end -- 165
	local ____self_previewOrder_1 = self.previewOrder -- 165
	____self_previewOrder_1[#____self_previewOrder_1 + 1] = file -- 166
	while #self.previewOrder > 36 do -- 166
		local expiredFile = table.remove(self.previewOrder, 1) -- 168
		if not expiredFile then -- 168
			break -- 169
		end -- 169
		self.previewTextures:delete(expiredFile) -- 170
		Cache:unload(expiredFile) -- 171
	end -- 171
end -- 163
function ResourceDownloader.prototype.loadPreview(self, resource) -- 175
	local file = resource.bannerPath or defaultBanner() -- 176
	local existing = self.previewTextures:get(file) -- 177
	if existing then -- 177
		self:touchPreview(file) -- 179
		return existing -- 180
	end -- 180
	if self.pendingPreviews:has(file) then -- 180
		return nil -- 182
	end -- 182
	if not Content:exist(file) then -- 182
		return nil -- 183
	end -- 183
	self.pendingPreviews:add(file) -- 184
	thread(function() -- 185
		Cache:loadAsync(file) -- 186
		self.pendingPreviews:delete(file) -- 187
		if self.cancelOperations then -- 187
			return -- 188
		end -- 188
		local texture = Texture2D(file) -- 189
		if not texture then -- 189
			return -- 190
		end -- 190
		if texture.width > 4096 or texture.height > 4096 then -- 190
			Cache:unload(file) -- 192
			return -- 193
		end -- 193
		self.previewTextures:set(file, texture) -- 195
		self:touchPreview(file) -- 196
	end) -- 185
	return nil -- 198
end -- 175
function ResourceDownloader.prototype.selectedVersion(self, resource) -- 201
	local index = math.max( -- 202
		1, -- 202
		math.min(resource.selectedVersion, #resource.versions) -- 202
	) -- 202
	resource.selectedVersion = index -- 203
	return resource.versions[index] -- 204
end -- 201
function ResourceDownloader.prototype.install(self, resource) -- 207
	if self.installingId or not self.snapshot then -- 207
		return -- 208
	end -- 208
	local version = self:selectedVersion(resource) -- 209
	self.installingId = resource.id -- 210
	self.installProgress = {progress = 0, message = zh and "准备安装" or "Preparing installation"}; -- 211
	(function() -- 212
		return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 212
			local ____installResource_5 = installResource -- 213
			local ____resource_4 = resource -- 213
			local ____opt_2 = self.snapshot -- 213
			local result = __TS__Await(____installResource_5( -- 213
				____resource_4, -- 213
				version, -- 213
				{ -- 213
					catalogCommit = ____opt_2 and ____opt_2.commit or "", -- 214
					isCanceled = function() return self.cancelOperations end, -- 215
					onProgress = function(____, progress) -- 216
						self.installProgress = progress -- 217
					end -- 216
				} -- 216
			)) -- 216
			self.installingId = nil -- 220
			self.installProgress = nil -- 221
			if not result.success and not result.canceled then -- 221
				self:showMessage(zh and "安装失败" or "Installation failed", result.message or (zh and "无法安装资源" or "Could not install the resource")) -- 223
			end -- 223
		end) -- 223
	end)() -- 212
end -- 207
function ResourceDownloader.prototype.runResource(self, resource) -- 231
	local basePath = getResourceInstallPath(resource.id) -- 232
	if #resource.entrypoints == 0 then -- 232
		run(Path(basePath, "init")) -- 234
		return -- 235
	end -- 235
	if #resource.entrypoints == 1 then -- 235
		run(Path(basePath, resource.entrypoints[1].path)) -- 238
		return -- 239
	end -- 239
	ImGui.OpenPopup("run-" .. resource.id) -- 241
end -- 231
function ResourceDownloader.prototype.drawRunPopup(self, resource) -- 244
	if #resource.entrypoints <= 1 then -- 244
		return -- 245
	end -- 245
	ImGui.BeginPopup( -- 246
		"run-" .. resource.id, -- 246
		function() -- 246
			for ____, entry in ipairs(resource.entrypoints) do -- 247
				if ImGui.Selectable((((entry.name .. "##") .. resource.id) .. "-") .. entry.path) then -- 247
					run(Path( -- 249
						getResourceInstallPath(resource.id), -- 249
						entry.path -- 249
					)) -- 249
				end -- 249
			end -- 249
		end -- 246
	) -- 246
end -- 244
function ResourceDownloader.prototype.drawStatusLine(self) -- 255
	if self.catalogStatus then -- 255
		ImGui.TextDisabled(self.catalogStatus.message) -- 257
		ImGui.SameLine() -- 258
		ImGui.ProgressBar( -- 259
			self.catalogStatus.progress, -- 259
			Vec2(130, 0) -- 259
		) -- 259
		return -- 260
	end -- 260
	if self.snapshot then -- 260
		ImGui.TextDisabled(((zh and "目录" or "Catalog") .. " ") .. __TS__StringSubstring(self.snapshot.commit, 0, 8)) -- 263
		if ImGui.IsItemHovered() then -- 263
			ImGui.BeginTooltip(function() -- 267
				ImGui.PushTextWrapPos( -- 268
					420, -- 268
					function() -- 268
						local ____ImGui_TextWrapped_9 = ImGui.TextWrapped -- 269
						local ____temp_8 = zh and "来源" or "Source" -- 269
						local ____opt_6 = self.snapshot -- 269
						____ImGui_TextWrapped_9((____temp_8 .. ": ") .. (____opt_6 and ____opt_6.source or "")) -- 269
						local ____ImGui_Text_13 = ImGui.Text -- 270
						local ____temp_12 = zh and "同步时间" or "Synced" -- 270
						local ____opt_10 = self.snapshot -- 270
						____ImGui_Text_13((____temp_12 .. ": ") .. (____opt_10 and ____opt_10.syncedAt or "")) -- 270
					end -- 268
				) -- 268
			end) -- 267
		end -- 267
		return -- 274
	end -- 274
	ImGui.TextDisabled(self.catalogError ~= "" and (zh and "目录不可用" or "Catalog unavailable") or (zh and "正在获取资源目录…" or "Fetching the resource catalog…")) -- 276
end -- 255
function ResourceDownloader.prototype.drawHeader(self, width, page) -- 283
	self.headerHeight = (self.catalogError ~= "" or self.catalogWarning ~= "") and 148 or 118 -- 284
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 285
	ImGui.SetNextWindowSize( -- 286
		Vec2(width, self.headerHeight), -- 286
		"Always" -- 286
	) -- 286
	ImGui.PushStyleVar( -- 287
		"WindowPadding", -- 287
		Vec2(16, 8), -- 287
		function() -- 287
			ImGui.Begin( -- 288
				"Dora Resource Catalog Header", -- 288
				windowsNoScrollFlags, -- 288
				function() -- 288
					ImGui.TextColored(themeColor, zh and "Dora SSR 社区资源" or "Dora SSR Community") -- 289
					ImGui.SameLine() -- 290
					ImGui.TextDisabled("(?)") -- 291
					if ImGui.IsItemHovered() then -- 291
						ImGui.BeginTooltip(function() -- 293
							ImGui.PushTextWrapPos( -- 294
								420, -- 294
								function() -- 294
									ImGui.TextWrapped(zh and "项目通过 Git 安装到 Download；安装后可通过 Git 继续更新和维护。" or "Projects are installed with Git. After installation, your Git workflow owns updates and local changes.") -- 295
								end -- 294
							) -- 294
						end) -- 293
					end -- 293
					ImGui.SameLine() -- 303
					self:drawStatusLine() -- 304
					local refreshWidth = zh and 80 or 85 -- 305
					ImGui.SameLine() -- 306
					ImGui.Dummy(Vec2( -- 307
						math.max( -- 307
							0, -- 307
							width - ImGui.GetCursorPosX() - refreshWidth - 24 -- 307
						), -- 307
						0 -- 307
					)) -- 307
					ImGui.SameLine() -- 308
					if self.isCatalogLoading then -- 308
						ImGui.BeginDisabled(function() return ImGui.Button( -- 310
							zh and "同步中" or "Syncing", -- 310
							Vec2(refreshWidth, 0) -- 310
						) end) -- 310
					elseif ImGui.Button( -- 310
						zh and "刷新目录" or "Refresh", -- 311
						Vec2(refreshWidth, 0) -- 311
					) then -- 311
						self:refreshCatalog(true) -- 312
					end -- 312
					if self.catalogError ~= "" then -- 312
						ImGui.TextColored( -- 316
							Color(4294924890), -- 316
							displayText(self.catalogError, 150) -- 316
						) -- 316
					elseif self.catalogWarning ~= "" then -- 316
						ImGui.TextColored( -- 318
							Color(4284920831), -- 318
							displayText(self.catalogWarning, 150) -- 318
						) -- 318
					end -- 318
					ImGui.BeginTabBar( -- 321
						"resource-sections", -- 321
						tabBarFlags, -- 321
						function() -- 321
							ImGui.BeginTabItem( -- 322
								zh and "作品" or "Projects", -- 322
								function() -- 322
									if self.section ~= "featured" then -- 322
										self.section = "featured" -- 324
										self.page = 0 -- 325
									end -- 325
								end -- 322
							) -- 322
							ImGui.BeginTabItem( -- 328
								"Mini Games", -- 328
								function() -- 328
									if self.section ~= "minigame" then -- 328
										self.section = "minigame" -- 330
										self.page = 0 -- 331
									end -- 331
								end -- 328
							) -- 328
							ImGui.BeginTabItem( -- 334
								zh and "全部" or "All", -- 334
								function() -- 334
									if self.section ~= "all" then -- 334
										self.section = "all" -- 336
										self.page = 0 -- 337
									end -- 337
								end -- 334
							) -- 334
						end -- 321
					) -- 321
					ImGui.SameLine() -- 342
					ImGui.SetNextItemWidth(zh and 150 or 165) -- 343
					local categoryNames = { -- 344
						zh and "全部分类" or "All categories", -- 344
						table.unpack(self.categories) -- 344
					} -- 344
					local categoryChanged, categoryIndex = ImGui.Combo("##resource-category", self.categoryIndex, categoryNames) -- 345
					if categoryChanged then -- 345
						self.categoryIndex = categoryIndex -- 347
						self.page = 0 -- 348
					end -- 348
					ImGui.SameLine() -- 350
					ImGui.TextDisabled(zh and "搜索" or "Search") -- 351
					ImGui.SameLine() -- 352
					ImGui.SetNextItemWidth(-1) -- 353
					if ImGui.InputText("##resource-search", self.filterBuffer, {"AutoSelectAll"}) then -- 353
						self.filterText = self.filterBuffer.text -- 355
						self.page = 0 -- 356
					end -- 356
					if #self.resources > 0 then -- 356
						ImGui.TextDisabled(zh and ((((("共 " .. tostring(page.total)) .. " 项 · 第 ") .. tostring(page.page + 1)) .. "/") .. tostring(page.pageCount)) .. " 页" or (((tostring(page.total) .. " items · page ") .. tostring(page.page + 1)) .. "/") .. tostring(page.pageCount)) -- 360
						ImGui.SameLine() -- 365
						if page.page > 0 and ImGui.SmallButton(zh and "上一页" or "Previous") then -- 365
							self.page = self.page - 1 -- 367
							self.resetListScroll = true -- 368
						end -- 368
						if page.page > 0 then -- 368
							ImGui.SameLine() -- 370
						end -- 370
						if page.page + 1 < page.pageCount and ImGui.SmallButton(zh and "下一页" or "Next") then -- 370
							self.page = self.page + 1 -- 372
							self.resetListScroll = true -- 373
						end -- 373
					end -- 373
				end -- 288
			) -- 288
		end -- 287
	) -- 287
end -- 283
function ResourceDownloader.prototype.drawPreview(self, resource, itemWidth, previewHeight) -- 380
	local texture = self:loadPreview(resource) -- 381
	local availableWidth = itemWidth - 20 -- 382
	if not texture then -- 382
		ImGui.Dummy(Vec2(availableWidth, previewHeight)) -- 384
		return -- 385
	end -- 385
	local scale = math.min(availableWidth / texture.width, previewHeight / texture.height) -- 387
	local imageWidth = texture.width * scale -- 388
	local imageHeight = texture.height * scale -- 389
	if imageWidth < availableWidth then -- 389
		ImGui.Dummy(Vec2((availableWidth - imageWidth) / 2, 0)) -- 391
		ImGui.SameLine() -- 392
	end -- 392
	ImGui.Image( -- 394
		resource.bannerPath or defaultBanner(), -- 394
		Vec2(imageWidth, imageHeight) -- 394
	) -- 394
	if imageHeight < previewHeight then -- 394
		ImGui.Dummy(Vec2(0, previewHeight - imageHeight)) -- 395
	end -- 395
end -- 380
function ResourceDownloader.prototype.drawResourceCard(self, resource, itemWidth) -- 398
	local title = resource.title[zh and "zh-Hans" or "en"] -- 399
	local description = inlineText(resource.description[zh and "zh-Hans" or "en"]) -- 400
	local displayedDescription = truncateText(description, 160) -- 401
	local descriptionLines = (itemWidth >= 500 and 2 or (itemWidth >= 340 and 3 or 4)) + (zh and 0 or 1) -- 402
	local descriptionHeight = ImGui.GetTextLineHeightWithSpacing() * descriptionLines -- 403
	local previewHeight = math.max( -- 404
		150, -- 404
		math.min(240, (itemWidth - 20) * 0.45) -- 404
	) -- 404
	local cardHeight = 164 + previewHeight + descriptionHeight -- 405
	local version = self:selectedVersion(resource) -- 406
	local source = version.sources[1] -- 407
	local installed = isResourceInstalled(resource.id) -- 408
	ImGui.BeginChild( -- 409
		"card-" .. resource.id, -- 409
		Vec2(itemWidth, cardHeight), -- 409
		{"NavFlattened"}, -- 409
		function() -- 409
			ImGui.TextColored( -- 410
				themeColor, -- 410
				displayText(title, 46) -- 410
			) -- 410
			if isMinigame(resource) then -- 410
				ImGui.SameLine() -- 412
				ImGui.TextDisabled("MINI") -- 413
			end -- 413
			if resource.status ~= "active" then -- 413
				ImGui.SameLine() -- 416
				ImGui.TextDisabled(string.upper(resource.status)) -- 417
			end -- 417
			self:drawPreview(resource, itemWidth, previewHeight) -- 419
			ImGui.BeginChild( -- 420
				"description-" .. resource.id, -- 421
				Vec2(-1, descriptionHeight), -- 422
				{}, -- 423
				{"NoScrollbar", "NoScrollWithMouse"}, -- 424
				function() -- 425
					ImGui.TextWrapped(displayedDescription.text) -- 426
				end -- 425
			) -- 425
			if source ~= nil and ImGui.TextLink(((zh and "项目仓库" or "Repository") .. "##repo-") .. resource.id) then -- 425
				App:openURL(source.url) -- 430
			end -- 430
			if source ~= nil and ImGui.IsItemHovered() then -- 430
				ImGui.BeginTooltip(function() -- 433
					ImGui.PushTextWrapPos( -- 434
						420, -- 434
						function() return ImGui.Text(source.url) end -- 434
					) -- 434
				end) -- 433
			end -- 433
			if source ~= nil then -- 433
				ImGui.SameLine() -- 437
			end -- 437
			if ImGui.TextLink(((zh and "详情" or "Details") .. "##details-") .. resource.id) then -- 437
				self.detailsResource = resource -- 439
				self.detailsPopupShow = true -- 440
			end -- 440
			ImGui.TextDisabled(((version.name .. " · ") .. (resource.license.status == "pending" and (zh and "许可待完善" or "license pending") or resource.license.spdx))) -- 442
			local versionNames = __TS__ArrayMap( -- 449
				resource.versions, -- 449
				function(____, item) return item.name end -- 449
			) -- 449
			if #versionNames > 1 and not installed then -- 449
				ImGui.SetNextItemWidth(-1) -- 451
				local changed, selected = ImGui.Combo("##version-" .. resource.id, resource.selectedVersion, versionNames) -- 452
				if changed then -- 452
					resource.selectedVersion = selected -- 453
				end -- 453
			end -- 453
			local currentInstall = self.installingId == resource.id -- 455
			if currentInstall and self.installProgress then -- 455
				ImGui.ProgressBar( -- 457
					self.installProgress.progress, -- 457
					Vec2(-1, 26) -- 457
				) -- 457
				ImGui.TextDisabled(displayText(self.installProgress.message, 60)) -- 458
			elseif installed then -- 458
				if resource.runnable and resource.status ~= "blocked" then -- 458
					if ImGui.Button(((zh and "测试" or "Run") .. "##run-button-") .. resource.id) then -- 458
						self:runResource(resource) -- 462
					end -- 462
					ImGui.SameLine() -- 464
				end -- 464
				ImGui.BeginDisabled(function() return ImGui.Button(((zh and "已安装" or "Installed") .. "##installed-") .. resource.id) end) -- 466
				ImGui.SameLine() -- 467
				if ImGui.Button(((zh and "删除" or "Delete") .. "##delete-") .. resource.id) then -- 467
					self.deleteResource = resource -- 469
					self.deletePopupShow = true -- 470
				end -- 470
			else -- 470
				local cannotInstall = self.installingId ~= nil or resource.status == "unavailable" or resource.status == "blocked" or not self.snapshot -- 473
				if cannotInstall then -- 473
					ImGui.BeginDisabled(function() return ImGui.Button(((zh and "安装" or "Install") .. "##install-") .. resource.id) end) -- 478
				elseif ImGui.Button(((zh and "安装" or "Install") .. "##install-") .. resource.id) then -- 478
					self:install(resource) -- 480
				end -- 480
			end -- 480
			self:drawRunPopup(resource) -- 483
		end -- 409
	) -- 409
end -- 398
function ResourceDownloader.prototype.drawDetailsPopup(self) -- 487
	local popupTitle = zh and "作品详情" or "Project Details" -- 488
	if self.detailsPopupShow then -- 488
		self.detailsPopupShow = false -- 490
		ImGui.OpenPopup(popupTitle) -- 491
	end -- 491
	local ____App_visualSize_14 = App.visualSize -- 493
	local width = ____App_visualSize_14.width -- 493
	local height = ____App_visualSize_14.height -- 493
	ImGui.SetNextWindowSize( -- 494
		Vec2( -- 495
			math.max( -- 496
				260, -- 496
				math.min(560, width - 40) -- 496
			), -- 496
			math.max( -- 497
				220, -- 497
				math.min(420, height - 40) -- 497
			) -- 497
		), -- 497
		"Appearing" -- 499
	) -- 499
	ImGui.BeginPopupModal( -- 501
		popupTitle, -- 501
		function() -- 501
			local resource = self.detailsResource -- 502
			if not resource then -- 502
				ImGui.CloseCurrentPopup() -- 504
				return -- 505
			end -- 505
			local version = self:selectedVersion(resource) -- 507
			local status = resource.status == "active" and (zh and "可用" or "Available") or (resource.status == "deprecated" and (zh and "已弃用" or "Deprecated") or (resource.status == "unavailable" and (zh and "暂不可用" or "Unavailable") or (zh and "已阻止" or "Blocked"))) -- 508
			local license = resource.license.status == "pending" and (zh and "许可待完善" or "Pending") or resource.license.spdx -- 515
			local function detailLine(label, value) -- 518
				ImGui.TextDisabled(label .. ":") -- 519
				ImGui.SameLine() -- 520
				ImGui.TextWrapped(value) -- 521
			end -- 518
			ImGui.TextColored(themeColor, resource.title[zh and "zh-Hans" or "en"]) -- 523
			ImGui.Separator() -- 524
			ImGui.BeginChild( -- 525
				"resource-details-text", -- 525
				Vec2(-1, -48), -- 525
				function() -- 525
					ImGui.TextColored(themeColor, zh and "简介" or "Description") -- 526
					ImGui.TextWrapped(resource.description[zh and "zh-Hans" or "en"]) -- 527
					ImGui.Spacing() -- 528
					ImGui.TextColored(themeColor, zh and "项目信息" or "Project Information") -- 529
					detailLine( -- 530
						zh and "类型" or "Type", -- 530
						isMinigame(resource) and (zh and "小游戏" or "Mini Game") or (zh and "社区作品" or "Community Project") -- 530
					) -- 530
					detailLine( -- 531
						zh and "分类" or "Categories", -- 532
						#resource.categories > 0 and table.concat(resource.categories, " · ") or (zh and "未分类" or "Uncategorized") -- 533
					) -- 533
					detailLine( -- 537
						zh and "标签" or "Tags", -- 538
						#resource.tags > 0 and table.concat(resource.tags, " · ") or (zh and "无" or "None") -- 539
					) -- 539
					detailLine(zh and "状态" or "Status", status) -- 541
					detailLine(zh and "版本" or "Version", version.name) -- 542
					detailLine(zh and "发布时间" or "Published", version.publishedAt) -- 543
					detailLine(zh and "许可证" or "License", license) -- 545
					ImGui.ScrollWhenDraggingOnVoid() -- 546
				end -- 525
			) -- 525
			if ImGui.Button( -- 525
				zh and "关闭" or "Close", -- 548
				Vec2(-1, 30) -- 548
			) then -- 548
				self.detailsResource = nil -- 549
				ImGui.CloseCurrentPopup() -- 550
			end -- 550
		end -- 501
	) -- 501
end -- 487
function ResourceDownloader.prototype.drawDeletePopup(self) -- 555
	local popupTitle = zh and "删除项目" or "Delete project" -- 556
	if self.deletePopupShow then -- 556
		self.deletePopupShow = false -- 558
		ImGui.OpenPopup(popupTitle) -- 559
	end -- 559
	ImGui.BeginPopupModal( -- 561
		popupTitle, -- 561
		function() -- 561
			local resource = self.deleteResource -- 562
			if not resource then -- 562
				ImGui.CloseCurrentPopup() -- 564
				return -- 565
			end -- 565
			ImGui.TextWrapped(zh and ("将删除 Download/" .. resource.id) .. "，其中可能包含你的 Git 提交和本地修改。" or ("This removes Download/" .. resource.id) .. ", including any local Git commits and changes.") -- 567
			if ImGui.Button( -- 567
				zh and "取消" or "Cancel", -- 572
				Vec2(120, 30) -- 572
			) then -- 572
				self.deleteResource = nil -- 573
				ImGui.CloseCurrentPopup() -- 574
			end -- 574
			ImGui.SameLine() -- 576
			if ImGui.Button( -- 576
				zh and "确认删除" or "Delete", -- 577
				Vec2(120, 30) -- 577
			) then -- 577
				local removed = Content:remove(getResourceInstallPath(resource.id)) -- 578
				self.deleteResource = nil -- 579
				if removed then -- 579
					Director.postNode:emit("UpdateEntries") -- 581
				else -- 581
					self:showMessage(zh and "删除失败" or "Deletion failed", zh and "无法删除项目目录，请检查文件是否正被占用。" or "Could not remove the project directory.") -- 583
				end -- 583
				ImGui.CloseCurrentPopup() -- 588
			end -- 588
		end -- 561
	) -- 561
end -- 555
function ResourceDownloader.prototype.drawMessagePopup(self) -- 593
	if self.popupShow then -- 593
		self.popupShow = false -- 595
		ImGui.OpenPopup("ResourceMessage") -- 596
	end -- 596
	ImGui.BeginPopupModal( -- 598
		"ResourceMessage", -- 598
		function() -- 598
			ImGui.Text(self.popupTitle) -- 599
			ImGui.Separator() -- 600
			ImGui.PushTextWrapPos( -- 601
				380, -- 601
				function() return ImGui.TextWrapped(self.popupMessage) end -- 601
			) -- 601
			if ImGui.Button( -- 601
				zh and "确认" or "OK", -- 602
				Vec2(380, 30) -- 602
			) then -- 602
				ImGui.CloseCurrentPopup() -- 602
			end -- 602
		end -- 598
	) -- 598
end -- 593
function ResourceDownloader.prototype.update(self) -- 606
	local ____App_visualSize_15 = App.visualSize -- 607
	local width = ____App_visualSize_15.width -- 607
	local height = ____App_visualSize_15.height -- 607
	local maxColumns = math.max( -- 608
		math.floor(width / 360), -- 608
		1 -- 608
	) -- 608
	local category = self.categoryIndex > 1 and self.categories[self.categoryIndex - 2 + 1] or nil -- 609
	local filtered = filterResources(self.resources, {section = self.section, category = category, query = self.filterText}) -- 610
	local pageSize = 12 -- 615
	local page = paginateResources(filtered, self.page, pageSize) -- 616
	self.page = page.page -- 617
	self:drawHeader(width, page) -- 618
	ImGui.SetNextWindowPos( -- 620
		Vec2(0, self.headerHeight), -- 620
		"Always", -- 620
		Vec2.zero -- 620
	) -- 620
	ImGui.SetNextWindowSize( -- 621
		Vec2(width, height - self.headerHeight), -- 621
		"Always" -- 621
	) -- 621
	ImGui.PushStyleVar( -- 622
		"WindowPadding", -- 622
		Vec2(14, 10), -- 622
		function() -- 622
			ImGui.Begin( -- 623
				"Dora Resource Catalog", -- 623
				windowsFlags, -- 623
				function() -- 623
					if self.resetListScroll then -- 623
						self.resetListScroll = false -- 625
						ImGui.SetScrollY(0) -- 626
					end -- 626
					if #self.resources == 0 then -- 626
						ImGui.Dummy(Vec2(0, 30)) -- 629
						ImGui.TextWrapped(self.catalogError ~= "" and self.catalogError or (zh and "正在准备资源目录…" or "Preparing the resource catalog…")) -- 630
					else -- 630
						ImGui.Columns(maxColumns, false) -- 636
						for ____, resource in ipairs(page.items) do -- 637
							self:drawResourceCard( -- 638
								resource, -- 638
								ImGui.GetContentRegionAvail().x -- 638
							) -- 638
							ImGui.NextColumn() -- 639
						end -- 639
						ImGui.Columns(1, false) -- 641
						ImGui.Dummy(Vec2(0, 60)) -- 642
					end -- 642
					self:drawDetailsPopup() -- 644
					self:drawDeletePopup() -- 645
					self:drawMessagePopup() -- 646
					ImGui.ScrollWhenDraggingOnVoid() -- 647
				end -- 623
			) -- 623
		end -- 622
	) -- 622
end -- 606
__TS__New(ResourceDownloader) -- 653
return ____exports -- 653
