-- [yue]: Script/Dev/Entry.yue
local _module_0 = { } -- 1
local _ENV = Dora(Dora.ImGui) -- 9
local App <const> = App -- 11
local ShowConsole <const> = ShowConsole -- 11
local _G <const> = _G -- 11
local package <const> = package -- 11
local Dora <const> = Dora -- 11
local Content <const> = Content -- 11
local Path <const> = Path -- 11
local DB <const> = DB -- 11
local type <const> = type -- 11
local math <const> = math -- 11
local View <const> = View -- 11
local Director <const> = Director -- 11
local HttpServer <const> = HttpServer -- 11
local Size <const> = Size -- 11
local Vec2 <const> = Vec2 -- 11
local Color <const> = Color -- 11
local Buffer <const> = Buffer -- 11
local thread <const> = thread -- 11
local HttpClient <const> = HttpClient -- 11
local json <const> = json -- 11
local tonumber <const> = tonumber -- 11
local os <const> = os -- 11
local yue <const> = yue -- 11
local SetDefaultFont <const> = SetDefaultFont -- 11
local table <const> = table -- 11
local Cache <const> = Cache -- 11
local Texture2D <const> = Texture2D -- 11
local pairs <const> = pairs -- 11
local tostring <const> = tostring -- 11
local string <const> = string -- 11
local print <const> = print -- 11
local xml <const> = xml -- 11
local teal <const> = teal -- 11
local wait <const> = wait -- 11
local pcall <const> = pcall -- 11
local Log <const> = Log -- 11
local tolua <const> = tolua -- 11
local Routine <const> = Routine -- 11
local Entity <const> = Entity -- 11
local Platformer <const> = Platformer -- 11
local Audio <const> = Audio -- 11
local ubox <const> = ubox -- 11
local collectgarbage <const> = collectgarbage -- 11
local Wasm <const> = Wasm -- 11
local sleep <const> = sleep -- 11
local once <const> = once -- 11
local emit <const> = emit -- 11
local Profiler <const> = Profiler -- 11
local xpcall <const> = xpcall -- 11
local debug <const> = debug -- 11
local AlignNode <const> = AlignNode -- 11
local Label <const> = Label -- 11
local Checkbox <const> = Checkbox -- 11
local SameLine <const> = SameLine -- 11
local TextColored <const> = TextColored -- 11
local IsItemHovered <const> = IsItemHovered -- 11
local BeginTooltip <const> = BeginTooltip -- 11
local PushTextWrapPos <const> = PushTextWrapPos -- 11
local Text <const> = Text -- 11
local SeparatorText <const> = SeparatorText -- 11
local Button <const> = Button -- 11
local OpenPopup <const> = OpenPopup -- 11
local SetNextWindowPosCenter <const> = SetNextWindowPosCenter -- 11
local BeginPopupModal <const> = BeginPopupModal -- 11
local TextWrapped <const> = TextWrapped -- 11
local CloseCurrentPopup <const> = CloseCurrentPopup -- 11
local Separator <const> = Separator -- 11
local SetNextWindowSize <const> = SetNextWindowSize -- 11
local PushStyleVar <const> = PushStyleVar -- 11
local Begin <const> = Begin -- 11
local TreeNode <const> = TreeNode -- 11
local BeginPopup <const> = BeginPopup -- 11
local Selectable <const> = Selectable -- 11
local BeginDisabled <const> = BeginDisabled -- 11
local setmetatable <const> = setmetatable -- 11
local ipairs <const> = ipairs -- 11
local threadLoop <const> = threadLoop -- 11
local Keyboard <const> = Keyboard -- 11
local SetNextWindowBgAlpha <const> = SetNextWindowBgAlpha -- 11
local SetNextWindowPos <const> = SetNextWindowPos -- 11
local SetWindowFocus <const> = SetWindowFocus -- 11
local ImageButton <const> = ImageButton -- 11
local ImGui <const> = ImGui -- 11
local PushStyleColor <const> = PushStyleColor -- 11
local ShowStats <const> = ShowStats -- 11
local coroutine <const> = coroutine -- 11
local Image <const> = Image -- 11
local Dummy <const> = Dummy -- 11
local SetNextItemWidth <const> = SetNextItemWidth -- 11
local InputText <const> = InputText -- 11
local Columns <const> = Columns -- 11
local GetColumnWidth <const> = GetColumnWidth -- 11
local NextColumn <const> = NextColumn -- 11
local SetNextItemOpen <const> = SetNextItemOpen -- 11
local PushID <const> = PushID -- 11
local ScrollWhenDraggingOnVoid <const> = ScrollWhenDraggingOnVoid -- 11
App.idled = true -- 13
App.devMode = true -- 14
ShowConsole(true) -- 15
local moduleCache = { } -- 17
local oldRequire = _G.require -- 18
local require -- 19
require = function(path) -- 19
	local loaded = package.loaded[path] -- 20
	if loaded == nil then -- 21
		moduleCache[#moduleCache + 1] = path -- 22
		return oldRequire(path) -- 23
	end -- 21
	return loaded -- 24
end -- 19
_G.require = require -- 25
Dora.require = require -- 26
local searchPaths = Content.searchPaths -- 28
local useChinese = (App.locale:match("^zh") ~= nil) -- 30
local updateLocale -- 31
updateLocale = function() -- 31
	useChinese = (App.locale:match("^zh") ~= nil) -- 32
	searchPaths[#searchPaths] = Path(Content.assetPath, "Script", "Lib", "Dora", useChinese and "zh-Hans" or "en") -- 33
	Content.searchPaths = searchPaths -- 34
end -- 31
local isDesktop -- 36
do -- 36
	local _val_0 = App.platform -- 36
	isDesktop = "Windows" == _val_0 or "macOS" == _val_0 or "Linux" == _val_0 -- 36
end -- 36
if DB:exist("Config") then -- 38
	do -- 39
		local _exp_0 = DB:query("select value_str from Config where name = 'locale'") -- 39
		local _type_0 = type(_exp_0) -- 40
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 40
		if _tab_0 then -- 40
			local locale -- 40
			do -- 40
				local _obj_0 = _exp_0[1] -- 40
				local _type_1 = type(_obj_0) -- 40
				if "table" == _type_1 or "userdata" == _type_1 then -- 40
					locale = _obj_0[1] -- 40
				end -- 40
			end -- 40
			if locale ~= nil then -- 40
				if App.locale ~= locale then -- 40
					App.locale = locale -- 41
					updateLocale() -- 42
				end -- 40
			end -- 40
		end -- 39
	end -- 39
	if isDesktop then -- 43
		local _exp_0 = DB:query("select value_str from Config where name = 'writablePath'") -- 44
		local _type_0 = type(_exp_0) -- 45
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 45
		if _tab_0 then -- 45
			local writablePath -- 45
			do -- 45
				local _obj_0 = _exp_0[1] -- 45
				local _type_1 = type(_obj_0) -- 45
				if "table" == _type_1 or "userdata" == _type_1 then -- 45
					writablePath = _obj_0[1] -- 45
				end -- 45
			end -- 45
			if writablePath ~= nil then -- 45
				Content.writablePath = writablePath -- 46
			end -- 45
		end -- 44
	end -- 43
end -- 38
local Config = require("Config") -- 48
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected", "webIDETourCompleted", "showPreview", "mobileFeed", "mobileFeedCurrentCard", "mobileRemixLLMConfigId", "mobileLargeText", "authRequired") -- 50
config:load() -- 83
if not (config.writablePath ~= nil) then -- 85
	config.writablePath = Content.appPath -- 86
end -- 85
if not (config.webIDEConnected ~= nil) then -- 88
	config.webIDEConnected = false -- 89
end -- 88
if (config.fpsLimited ~= nil) then -- 91
	App.fpsLimited = config.fpsLimited -- 92
else -- 94
	config.fpsLimited = App.fpsLimited -- 94
end -- 91
if (config.targetFPS ~= nil) then -- 96
	App.targetFPS = math.floor(config.targetFPS) -- 97
else -- 99
	config.targetFPS = App.targetFPS -- 99
end -- 96
if (config.vsync ~= nil) then -- 101
	View.vsync = config.vsync -- 102
else -- 104
	config.vsync = View.vsync -- 104
end -- 101
if (config.fixedFPS ~= nil) then -- 106
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 107
else -- 109
	config.fixedFPS = Director.scheduler.fixedFPS -- 109
end -- 106
if not (config.showPreview ~= nil) then -- 111
	config.showPreview = true -- 112
end -- 111
if not (config.mobileFeed ~= nil) then -- 114
	local _val_0 = App.platform -- 115
	config.mobileFeed = "Android" == _val_0 or "iOS" == _val_0 -- 115
end -- 114
if not (config.webIDETourCompleted ~= nil) then -- 117
	config.webIDETourCompleted = false -- 118
end -- 117
if not (config.authRequired ~= nil) then -- 120
	local _val_0 = App.platform -- 121
	config.authRequired = not ("Android" == _val_0 or "iOS" == _val_0) -- 121
end -- 120
HttpServer.authRequired = config.authRequired -- 122
local showEntry = true -- 124
isDesktop = false -- 126
if (function() -- 127
	local _val_0 = App.platform -- 127
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 127
end)() then -- 127
	isDesktop = true -- 128
	if config.fullScreen then -- 129
		App.fullScreen = true -- 130
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 131
		local size = Size(config.winWidth, config.winHeight) -- 132
		if App.winSize ~= size then -- 133
			App.winSize = size -- 134
		end -- 133
		local winX, winY -- 135
		do -- 135
			local _obj_0 = App.winPosition -- 135
			winX, winY = _obj_0.x, _obj_0.y -- 135
		end -- 135
		if (config.winX ~= nil) then -- 136
			winX = config.winX -- 137
		else -- 139
			config.winX = -1 -- 139
		end -- 136
		if (config.winY ~= nil) then -- 140
			winY = config.winY -- 141
		else -- 143
			config.winY = -1 -- 143
		end -- 140
		App.winPosition = Vec2(winX, winY) -- 144
	end -- 129
	if (config.alwaysOnTop ~= nil) then -- 145
		App.alwaysOnTop = config.alwaysOnTop -- 146
	else -- 148
		config.alwaysOnTop = false -- 148
	end -- 145
end -- 127
if (config.themeColor ~= nil) then -- 150
	App.themeColor = Color(config.themeColor) -- 151
else -- 153
	config.themeColor = App.themeColor:toARGB() -- 153
end -- 150
if not (config.locale ~= nil) then -- 155
	config.locale = App.locale -- 156
end -- 155
local showStats = false -- 158
if (config.showStats ~= nil) then -- 159
	showStats = config.showStats -- 160
else -- 162
	config.showStats = showStats -- 162
end -- 159
local showConsole = false -- 164
if (config.showConsole ~= nil) then -- 165
	showConsole = config.showConsole -- 166
else -- 168
	config.showConsole = showConsole -- 168
end -- 165
local showFooter = true -- 170
if (config.showFooter ~= nil) then -- 171
	showFooter = config.showFooter -- 172
else -- 174
	config.showFooter = showFooter -- 174
end -- 171
local setFooterVisible -- 176
setFooterVisible = function(visible) -- 176
	if visible == nil then -- 176
		visible = true -- 176
	end -- 176
	showFooter = visible -- 177
	config.showFooter = showFooter -- 178
end -- 176
_module_0["setFooterVisible"] = setFooterVisible -- 176
local filterBuf = Buffer(20) -- 180
if (config.filter ~= nil) then -- 181
	filterBuf.text = config.filter -- 182
else -- 184
	config.filter = "" -- 184
end -- 181
local engineDev = false -- 186
if (config.engineDev ~= nil) then -- 187
	engineDev = config.engineDev -- 188
else -- 190
	config.engineDev = engineDev -- 190
end -- 187
if (config.webProfiler ~= nil) then -- 192
	Director.profilerSending = config.webProfiler -- 193
else -- 195
	config.webProfiler = true -- 195
	Director.profilerSending = true -- 196
end -- 192
if not (config.drawerWidth ~= nil) then -- 198
	config.drawerWidth = 200 -- 199
end -- 198
_module_0.getConfig = function() -- 201
	return config -- 201
end -- 201
_module_0.getEngineDev = function() -- 202
	if not App.debugging then -- 203
		return false -- 203
	end -- 203
	return config.engineDev -- 204
end -- 202
local _anon_func_0 = function() -- 209
	local _val_0 = App.platform -- 209
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 209
end -- 209
_module_0.connectWebIDE = function() -- 206
	if not config.webIDEConnected then -- 207
		config.webIDEConnected = true -- 208
		if _anon_func_0() then -- 209
			local ratio = App.winSize.width / App.visualSize.width -- 210
			App.winSize = Size(640 * ratio, 480 * ratio) -- 211
		end -- 209
	end -- 207
end -- 206
local updateCheck -- 213
updateCheck = function() -- 213
	return thread(function() -- 213
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 214
		if res then -- 214
			local data = json.decode(res) -- 215
			if data then -- 215
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 216
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 217
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 218
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 219
				if na < a then -- 220
					goto not_new_version -- 221
				end -- 220
				if na == a then -- 222
					if nb < b then -- 223
						goto not_new_version -- 224
					end -- 223
					if nb == b then -- 225
						if nc < c then -- 226
							goto not_new_version -- 227
						end -- 226
						if nc == c then -- 228
							goto not_new_version -- 229
						end -- 228
					end -- 225
				end -- 222
				config.updateNotification = true -- 230
				::not_new_version:: -- 231
				config.lastUpdateCheck = os.time() -- 232
			end -- 215
		end -- 214
	end) -- 213
end -- 213
if (config.lastUpdateCheck ~= nil) then -- 234
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 235
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 236
		updateCheck() -- 237
	end -- 236
else -- 239
	updateCheck() -- 239
end -- 234
local Set, Struct, LintYueGlobals, GSplit -- 241
do -- 241
	local _obj_0 = require("Utils") -- 241
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 241
end -- 241
local yueext = yue.options.extension -- 242
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 244
local building = false -- 246
local getAllFiles -- 248
getAllFiles = function(path, exts, recursive) -- 248
	if recursive == nil then -- 248
		recursive = true -- 248
	end -- 248
	local filters = Set(exts) -- 249
	local files -- 250
	if recursive then -- 250
		files = Content:getAllFiles(path) -- 251
	else -- 253
		files = Content:getFiles(path) -- 253
	end -- 250
	local _accum_0 = { } -- 254
	local _len_0 = 1 -- 254
	for _index_0 = 1, #files do -- 254
		local file = files[_index_0] -- 254
		if not filters[Path:getExt(file)] then -- 255
			goto _continue_0 -- 255
		end -- 255
		_accum_0[_len_0] = file -- 256
		_len_0 = _len_0 + 1 -- 255
		::_continue_0:: -- 255
	end -- 254
	return _accum_0 -- 254
end -- 248
_module_0["getAllFiles"] = getAllFiles -- 248
local getFileEntries -- 258
getFileEntries = function(path, recursive, excludeFiles) -- 258
	if recursive == nil then -- 258
		recursive = true -- 258
	end -- 258
	if excludeFiles == nil then -- 258
		excludeFiles = nil -- 258
	end -- 258
	local entries = { } -- 259
	local excludes -- 260
	if excludeFiles then -- 260
		excludes = Set(excludeFiles) -- 261
	end -- 260
	local _list_0 = getAllFiles(path, { -- 262
		"lua", -- 262
		"xml", -- 262
		yueext, -- 262
		"tl" -- 262
	}, recursive) -- 262
	for _index_0 = 1, #_list_0 do -- 262
		local file = _list_0[_index_0] -- 262
		local entryName = Path:getName(file) -- 263
		if excludes and excludes[entryName] then -- 264
			goto _continue_0 -- 265
		end -- 264
		local fileName = Path:replaceExt(file, "") -- 266
		fileName = Path(path, fileName) -- 267
		local entryAdded -- 268
		for _index_1 = 1, #entries do -- 268
			local _des_0 = entries[_index_1] -- 268
			local ename, efile = _des_0.entryName, _des_0.fileName -- 268
			if entryName == ename and efile == fileName then -- 269
				entryAdded = true -- 269
				break -- 269
			end -- 269
		end -- 268
		if entryAdded then -- 270
			goto _continue_0 -- 270
		end -- 270
		local entry = { -- 271
			entryName = entryName, -- 271
			fileName = fileName -- 271
		} -- 271
		entries[#entries + 1] = entry -- 272
		::_continue_0:: -- 263
	end -- 262
	table.sort(entries, function(a, b) -- 273
		return a.entryName < b.entryName -- 273
	end) -- 273
	return entries -- 274
end -- 258
local allEntries = { -- 276
	dirty = { }, -- 276
	hasDirty = false -- 276
} -- 276
allEntries.scanDir = function(path, dir, noPreview) -- 278
	if noPreview == nil then -- 278
		noPreview = false -- 278
	end -- 278
	local entries = { } -- 279
	if not dir:match("^%.") then -- 280
		local _list_0 = getAllFiles(Path(path, dir), { -- 281
			"lua", -- 281
			"xml", -- 281
			yueext, -- 281
			"tl", -- 281
			"wasm" -- 281
		}) -- 281
		for _index_0 = 1, #_list_0 do -- 281
			local file = _list_0[_index_0] -- 281
			if "init" == Path:getName(file):lower() then -- 282
				local fileName = Path:replaceExt(file, "") -- 283
				fileName = Path(path, dir, fileName) -- 284
				local projectPath = Path:getPath(fileName) -- 285
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 286
				local repo = nil -- 287
				if Content:exist(repoFile) then -- 288
					local str = Content:load(repoFile) -- 289
					if str then -- 289
						repo = json.decode(str) -- 290
					end -- 289
				end -- 288
				local entryName = Path:getName(projectPath) -- 291
				local entryAdded -- 292
				for _index_1 = 1, #entries do -- 292
					local _des_0 = entries[_index_1] -- 292
					local ename, efile = _des_0.entryName, _des_0.fileName -- 292
					if entryName == ename and efile == fileName then -- 293
						entryAdded = true -- 293
						break -- 293
					end -- 293
				end -- 292
				if entryAdded then -- 294
					goto _continue_0 -- 294
				end -- 294
				local examples = { } -- 295
				local tests = { } -- 296
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 297
				if Content:exist(examplePath) then -- 298
					local _list_1 = getFileEntries(examplePath) -- 299
					for _index_1 = 1, #_list_1 do -- 299
						local _des_0 = _list_1[_index_1] -- 299
						local name, ePath = _des_0.entryName, _des_0.fileName -- 299
						local entry = { -- 301
							entryName = name, -- 301
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 302
							workDir = projectPath -- 303
						} -- 300
						examples[#examples + 1] = entry -- 305
					end -- 299
				end -- 298
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 306
				if Content:exist(testPath) then -- 307
					local _list_1 = getFileEntries(testPath) -- 308
					for _index_1 = 1, #_list_1 do -- 308
						local _des_0 = _list_1[_index_1] -- 308
						local name, tPath = _des_0.entryName, _des_0.fileName -- 308
						local entry = { -- 310
							entryName = name, -- 310
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 311
							workDir = projectPath -- 312
						} -- 309
						tests[#tests + 1] = entry -- 314
					end -- 308
				end -- 307
				local entry = { -- 315
					entryName = entryName, -- 315
					fileName = fileName, -- 315
					projectPath = projectPath, -- 315
					examples = examples, -- 315
					tests = tests, -- 315
					repo = repo -- 315
				} -- 315
				local bannerFile -- 316
				do -- 316
					local _val_0 -- 316
					repeat -- 316
						if noPreview then -- 317
							_val_0 = nil -- 317
							break -- 317
						end -- 317
						if not config.showPreview then -- 318
							_val_0 = nil -- 318
							break -- 318
						end -- 318
						local f = Path(projectPath, ".dora", "banner.jpg") -- 319
						if Content:exist(f) then -- 320
							_val_0 = f -- 320
							break -- 320
						end -- 320
						f = Path(projectPath, ".dora", "banner.png") -- 321
						if Content:exist(f) then -- 322
							_val_0 = f -- 322
							break -- 322
						end -- 322
						f = Path(projectPath, "Image", "banner.jpg") -- 323
						if Content:exist(f) then -- 324
							_val_0 = f -- 324
							break -- 324
						end -- 324
						f = Path(projectPath, "Image", "banner.png") -- 325
						if Content:exist(f) then -- 326
							_val_0 = f -- 326
							break -- 326
						end -- 326
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 327
						if Content:exist(f) then -- 328
							_val_0 = f -- 328
							break -- 328
						end -- 328
					until true -- 316
					bannerFile = _val_0 -- 316
				end -- 316
				if bannerFile then -- 330
					entry.bannerFile = bannerFile
					thread(function() -- 334
						if Cache:loadAsync(bannerFile) then -- 331
							local bannerTex = Texture2D(bannerFile) -- 332
							if bannerTex then -- 332
								entry.bannerTex = bannerTex -- 334
							end -- 332
						end -- 331
					end) -- 330
				end -- 330
				entries[#entries + 1] = entry -- 335
			end -- 282
			::_continue_0:: -- 282
		end -- 281
	end -- 280
	return entries -- 336
end -- 278
local getProjectEntries -- 338
getProjectEntries = function(path, noPreview) -- 338
	if noPreview == nil then -- 338
		noPreview = false -- 338
	end -- 338
	local entries = { } -- 339
	local _list_0 = Content:getDirs(path) -- 340
	for _index_0 = 1, #_list_0 do -- 340
		local dir = _list_0[_index_0] -- 340
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 341
		for _index_1 = 1, #_list_1 do -- 341
			local entry = _list_1[_index_1] -- 341
			entries[#entries + 1] = entry -- 342
		end -- 341
	end -- 340
	table.sort(entries, function(a, b) -- 343
		return a.entryName < b.entryName -- 343
	end) -- 343
	return entries -- 344
end -- 338
_module_0["getProjectEntries"] = getProjectEntries -- 338
local gamesInDev -- 346
local doraTools -- 347
local isToolEntry -- 349
isToolEntry = function(entry) -- 349
	do -- 350
		local _type_0 = type(entry) -- 350
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 350
		if _tab_0 then -- 350
			local categories -- 350
			do -- 350
				local _obj_0 = entry.repo -- 350
				local _type_1 = type(_obj_0) -- 350
				if "table" == _type_1 or "userdata" == _type_1 then -- 350
					categories = _obj_0.categories -- 350
				end -- 350
			end -- 350
			if categories ~= nil then -- 350
				for _index_0 = 1, #categories do -- 351
					local category = categories[_index_0] -- 351
					if "string" == type(category) and category:lower() == "tool" then -- 352
						return true -- 353
					end -- 352
				end -- 351
			end -- 350
		end -- 350
	end -- 350
	return false -- 349
end -- 349
local getEntryTitle -- 355
getEntryTitle = function(entry) -- 355
	local title -- 356
	do -- 356
		local repo = entry.repo -- 356
		if repo then -- 356
			if repo.title and "table" == type(repo.title) then -- 357
				if useChinese then -- 358
					title = repo.title.zh -- 358
				else -- 358
					title = repo.title.en -- 358
				end -- 358
			end -- 357
		end -- 356
	end -- 356
	if title ~= nil then -- 359
		return title -- 359
	else -- 359
		return entry.entryName -- 359
	end -- 359
end -- 355
allEntries.rebuildEntries = function() -- 361
	gamesInDev = { } -- 362
	do -- 363
		local _accum_0 = { } -- 363
		local _len_0 = 1 -- 363
		local _list_0 = allEntries.builtinTools -- 363
		for _index_0 = 1, #_list_0 do -- 363
			local tool = _list_0[_index_0] -- 363
			_accum_0[_len_0] = tool -- 363
			_len_0 = _len_0 + 1 -- 363
		end -- 363
		doraTools = _accum_0 -- 363
	end -- 363
	local _list_0 = allEntries.projectEntries -- 364
	for _index_0 = 1, #_list_0 do -- 364
		local entry = _list_0[_index_0] -- 364
		if isToolEntry(entry) then -- 365
			entry.kind = "tool" -- 366
			doraTools[#doraTools + 1] = entry -- 367
		else -- 369
			entry.kind = "game" -- 369
			gamesInDev[#gamesInDev + 1] = entry -- 370
		end -- 365
	end -- 364
	for i = #allEntries, 1, -1 do -- 371
		allEntries[i] = nil -- 372
	end -- 371
	for _index_0 = 1, #gamesInDev do -- 373
		local game = gamesInDev[_index_0] -- 373
		allEntries[#allEntries + 1] = game -- 374
		local examples, tests = game.examples, game.tests -- 375
		for _index_1 = 1, #examples do -- 376
			local example = examples[_index_1] -- 376
			allEntries[#allEntries + 1] = example -- 377
		end -- 376
		for _index_1 = 1, #tests do -- 378
			local test = tests[_index_1] -- 378
			allEntries[#allEntries + 1] = test -- 379
		end -- 378
	end -- 373
end -- 361
local updateEntries -- 381
updateEntries = function() -- 381
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 382
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 383
	local _list_0 = allEntries.builtinTools -- 384
	for _index_0 = 1, #_list_0 do -- 384
		local tool = _list_0[_index_0] -- 384
		tool.kind = "tool" -- 385
		tool.builtin = true -- 386
	end -- 384
	return allEntries.rebuildEntries() -- 387
end -- 381
allEntries.refreshDirtyProjects = function() -- 389
	if not allEntries.hasDirty then -- 390
		return -- 390
	end -- 390
	local dirty = allEntries.dirty -- 391
	allEntries.dirty = { } -- 392
	allEntries.hasDirty = false -- 393
	for projectPath in pairs(dirty) do -- 394
		do -- 395
			local _accum_0 = { } -- 395
			local _len_0 = 1 -- 395
			local _list_0 = allEntries.projectEntries -- 395
			for _index_0 = 1, #_list_0 do -- 395
				local entry = _list_0[_index_0] -- 395
				if entry.projectPath ~= projectPath then -- 395
					_accum_0[_len_0] = entry -- 395
					_len_0 = _len_0 + 1 -- 395
				end -- 395
			end -- 395
			allEntries.projectEntries = _accum_0 -- 395
		end -- 395
		local parentPath = Path:getPath(projectPath) -- 396
		local dir = Path:getFilename(projectPath) -- 397
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 398
		for _index_0 = 1, #_list_0 do -- 398
			local entry = _list_0[_index_0] -- 398
			if entry.projectPath == projectPath then -- 399
				do -- 400
					local _obj_0 = allEntries.projectEntries -- 400
					_obj_0[#_obj_0 + 1] = entry -- 400
				end -- 400
				break -- 401
			end -- 399
		end -- 398
	end -- 394
	table.sort(allEntries.projectEntries, function(a, b) -- 402
		return a.entryName < b.entryName -- 402
	end) -- 402
	return allEntries.rebuildEntries() -- 403
end -- 389
updateEntries() -- 405
local getLaunchEntries -- 407
getLaunchEntries = function(refresh) -- 407
	if refresh == nil then -- 407
		refresh = false -- 407
	end -- 407
	if refresh then -- 408
		updateEntries() -- 408
	end -- 408
	local toInfo -- 409
	toInfo = function(entry, kind) -- 409
		local file = entry.fileName -- 410
		local asProj = not entry.builtin -- 411
		return { -- 413
			name = getEntryTitle(entry), -- 413
			file = file, -- 414
			kind = kind, -- 415
			asProj = asProj -- 416
		} -- 412
	end -- 409
	local games -- 418
	do -- 418
		local _accum_0 = { } -- 418
		local _len_0 = 1 -- 418
		for _index_0 = 1, #gamesInDev do -- 418
			local game = gamesInDev[_index_0] -- 418
			_accum_0[_len_0] = toInfo(game, "game") -- 418
			_len_0 = _len_0 + 1 -- 418
		end -- 418
		games = _accum_0 -- 418
	end -- 418
	local tools -- 419
	do -- 419
		local _accum_0 = { } -- 419
		local _len_0 = 1 -- 419
		for _index_0 = 1, #doraTools do -- 419
			local tool = doraTools[_index_0] -- 419
			_accum_0[_len_0] = toInfo(tool, "tool") -- 419
			_len_0 = _len_0 + 1 -- 419
		end -- 419
		tools = _accum_0 -- 419
	end -- 419
	return { -- 420
		games = games, -- 420
		tools = tools -- 420
	} -- 420
end -- 407
_module_0["getLaunchEntries"] = getLaunchEntries -- 407
local _anon_func_1 = function(entry, useChinese) -- 437
	local _obj_0 = entry.repo -- 437
	if _obj_0 ~= nil then -- 437
		local _obj_1 = _obj_0.description -- 437
		if _obj_1 ~= nil then -- 437
			return _obj_1[useChinese and "zh" or "en"] -- 437
		end -- 437
		return nil -- 437
	end -- 437
	return nil -- 437
end -- 437
local getMobileFeedEntries -- 422
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 422
	if refresh == nil then -- 422
		refresh = false -- 422
	end -- 422
	if dirtyProjectPath == nil then -- 422
		dirtyProjectPath = nil -- 422
	end -- 422
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 423
		allEntries.dirty[dirtyProjectPath] = true -- 424
		allEntries.hasDirty = true -- 425
	end -- 423
	if refresh then -- 426
		allEntries.dirty = { } -- 427
		allEntries.hasDirty = false -- 428
		updateEntries() -- 429
	else -- 431
		allEntries.refreshDirtyProjects() -- 431
	end -- 426
	local items = { } -- 432
	for _index_0 = 1, #gamesInDev do -- 433
		local entry = gamesInDev[_index_0] -- 433
		items[#items + 1] = { -- 435
			id = entry.entryName, -- 435
			title = getEntryTitle(entry), -- 436
			description = _anon_func_1(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 437
			fileName = entry.fileName, -- 438
			workDir = Path:getPath(entry.fileName), -- 439
			bannerFile = entry.bannerFile, -- 440
			kind = "local" -- 441
		} -- 434
	end -- 433
	return items -- 443
end -- 422
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 422
local doCompile -- 445
doCompile = function(minify) -- 445
	if building then -- 446
		return -- 446
	end -- 446
	building = true -- 447
	local startTime = App.runningTime -- 448
	local luaFiles = { } -- 449
	local yueFiles = { } -- 450
	local xmlFiles = { } -- 451
	local tlFiles = { } -- 452
	local writablePath = Content.writablePath -- 453
	local buildPaths = { -- 455
		{ -- 456
			Content.assetPath, -- 456
			Path(writablePath, ".build"), -- 457
			"" -- 458
		} -- 455
	} -- 454
	for _index_0 = 1, #gamesInDev do -- 461
		local _des_0 = gamesInDev[_index_0] -- 461
		local fileName = _des_0.fileName -- 461
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 462
		buildPaths[#buildPaths + 1] = { -- 464
			Path(writablePath, gamePath), -- 464
			Path(writablePath, ".build", gamePath), -- 465
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 466
			gamePath -- 467
		} -- 463
	end -- 461
	for _index_0 = 1, #buildPaths do -- 468
		local _des_0 = buildPaths[_index_0] -- 468
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 468
		if not Content:exist(inputPath) then -- 469
			goto _continue_0 -- 469
		end -- 469
		local _list_0 = getAllFiles(inputPath, { -- 471
			"lua" -- 471
		}) -- 471
		for _index_1 = 1, #_list_0 do -- 471
			local file = _list_0[_index_1] -- 471
			luaFiles[#luaFiles + 1] = { -- 473
				file, -- 473
				Path(inputPath, file), -- 474
				Path(outputPath, file), -- 475
				gamePath -- 476
			} -- 472
		end -- 471
		local _list_1 = getAllFiles(inputPath, { -- 478
			yueext -- 478
		}) -- 478
		for _index_1 = 1, #_list_1 do -- 478
			local file = _list_1[_index_1] -- 478
			yueFiles[#yueFiles + 1] = { -- 480
				file, -- 480
				Path(inputPath, file), -- 481
				Path(outputPath, Path:replaceExt(file, "lua")), -- 482
				searchPath, -- 483
				gamePath -- 484
			} -- 479
		end -- 478
		local _list_2 = getAllFiles(inputPath, { -- 486
			"xml" -- 486
		}) -- 486
		for _index_1 = 1, #_list_2 do -- 486
			local file = _list_2[_index_1] -- 486
			xmlFiles[#xmlFiles + 1] = { -- 488
				file, -- 488
				Path(inputPath, file), -- 489
				Path(outputPath, Path:replaceExt(file, "lua")), -- 490
				gamePath -- 491
			} -- 487
		end -- 486
		local _list_3 = getAllFiles(inputPath, { -- 493
			"tl" -- 493
		}) -- 493
		for _index_1 = 1, #_list_3 do -- 493
			local file = _list_3[_index_1] -- 493
			if not file:match(".*%.d%.tl$") then -- 494
				tlFiles[#tlFiles + 1] = { -- 496
					file, -- 496
					Path(inputPath, file), -- 497
					Path(outputPath, Path:replaceExt(file, "lua")), -- 498
					searchPath, -- 499
					gamePath -- 500
				} -- 495
			end -- 494
		end -- 493
		::_continue_0:: -- 469
	end -- 468
	local paths -- 502
	do -- 502
		local _tbl_0 = { } -- 502
		local _list_0 = { -- 503
			luaFiles, -- 503
			yueFiles, -- 503
			xmlFiles, -- 503
			tlFiles -- 503
		} -- 503
		for _index_0 = 1, #_list_0 do -- 503
			local files = _list_0[_index_0] -- 503
			for _index_1 = 1, #files do -- 504
				local file = files[_index_1] -- 504
				_tbl_0[Path:getPath(file[3])] = true -- 502
			end -- 502
		end -- 502
		paths = _tbl_0 -- 502
	end -- 502
	for path in pairs(paths) do -- 506
		Content:mkdir(path) -- 506
	end -- 506
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 508
	local fileCount = 0 -- 509
	local errors = { } -- 510
	for _index_0 = 1, #yueFiles do -- 511
		local _des_0 = yueFiles[_index_0] -- 511
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 511
		local filename -- 512
		if gamePath then -- 512
			filename = Path(gamePath, file) -- 512
		else -- 512
			filename = file -- 512
		end -- 512
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 513
			if not codes then -- 514
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 515
				return -- 516
			end -- 514
			local success, result = LintYueGlobals(codes, globals) -- 517
			local yueCodes -- 518
			if not success then -- 519
				yueCodes = Content:load(input) -- 520
				if yueCodes then -- 520
					local CheckTIC80Code -- 521
					do -- 521
						local _obj_0 = require("Utils") -- 521
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 521
					end -- 521
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 522
					if isTIC80 then -- 523
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 524
					end -- 523
				end -- 520
			end -- 519
			if success then -- 525
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 526
			else -- 528
				if yueCodes then -- 528
					local globalErrors = { } -- 529
					for _index_1 = 1, #result do -- 530
						local _des_1 = result[_index_1] -- 530
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 530
						local countLine = 1 -- 531
						local code = "" -- 532
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 533
							if countLine == line then -- 534
								code = lineCode -- 535
								break -- 536
							end -- 534
							countLine = countLine + 1 -- 537
						end -- 533
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 538
					end -- 530
					if #globalErrors > 0 then -- 539
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 539
					end -- 539
				else -- 541
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 541
				end -- 528
				if #errors == 0 then -- 542
					return codes -- 542
				end -- 542
			end -- 525
		end, function(success) -- 513
			if success then -- 543
				print("Yue compiled: " .. tostring(filename)) -- 543
			end -- 543
			fileCount = fileCount + 1 -- 544
		end) -- 513
	end -- 511
	thread(function() -- 546
		for _index_0 = 1, #xmlFiles do -- 547
			local _des_0 = xmlFiles[_index_0] -- 547
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 547
			local filename -- 548
			if gamePath then -- 548
				filename = Path(gamePath, file) -- 548
			else -- 548
				filename = file -- 548
			end -- 548
			local sourceCodes = Content:loadAsync(input) -- 549
			local codes, err = xml.tolua(sourceCodes) -- 550
			if not codes then -- 551
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 552
			else -- 554
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 554
				print("Xml compiled: " .. tostring(filename)) -- 555
			end -- 551
			fileCount = fileCount + 1 -- 556
		end -- 547
	end) -- 546
	thread(function() -- 558
		for _index_0 = 1, #tlFiles do -- 559
			local _des_0 = tlFiles[_index_0] -- 559
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 559
			local filename -- 560
			if gamePath then -- 560
				filename = Path(gamePath, file) -- 560
			else -- 560
				filename = file -- 560
			end -- 560
			local sourceCodes = Content:loadAsync(input) -- 561
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 562
			if not codes then -- 563
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 564
			else -- 566
				Content:saveAsync(output, codes) -- 566
				print("Teal compiled: " .. tostring(filename)) -- 567
			end -- 563
			fileCount = fileCount + 1 -- 568
		end -- 559
	end) -- 558
	return thread(function() -- 570
		wait(function() -- 571
			return fileCount == totalFiles -- 571
		end) -- 571
		if minify then -- 572
			local _list_0 = { -- 573
				yueFiles, -- 573
				xmlFiles, -- 573
				tlFiles -- 573
			} -- 573
			for _index_0 = 1, #_list_0 do -- 573
				local files = _list_0[_index_0] -- 573
				for _index_1 = 1, #files do -- 573
					local file = files[_index_1] -- 573
					local output = Path:replaceExt(file[3], "lua") -- 574
					luaFiles[#luaFiles + 1] = { -- 576
						Path:replaceExt(file[1], "lua"), -- 576
						output, -- 577
						output -- 578
					} -- 575
				end -- 573
			end -- 573
			local FormatMini -- 580
			do -- 580
				local _obj_0 = require("luaminify") -- 580
				FormatMini = _obj_0.FormatMini -- 580
			end -- 580
			for _index_0 = 1, #luaFiles do -- 581
				local _des_0 = luaFiles[_index_0] -- 581
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 581
				if Content:exist(input) then -- 582
					local sourceCodes = Content:loadAsync(input) -- 583
					local res, err = FormatMini(sourceCodes) -- 584
					if res then -- 585
						Content:saveAsync(output, res) -- 586
						print("Minify: " .. tostring(file)) -- 587
					else -- 589
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 589
					end -- 585
				else -- 591
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 591
				end -- 582
			end -- 581
			package.loaded["luaminify.FormatMini"] = nil -- 592
			package.loaded["luaminify.ParseLua"] = nil -- 593
			package.loaded["luaminify.Scope"] = nil -- 594
			package.loaded["luaminify.Util"] = nil -- 595
		end -- 572
		local errorMessage = table.concat(errors, "\n") -- 596
		if errorMessage ~= "" then -- 597
			print(errorMessage) -- 597
		end -- 597
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 598
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 599
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 600
		Content:clearPathCache() -- 601
		teal.clear() -- 602
		yue.clear() -- 603
		building = false -- 604
	end) -- 570
end -- 445
local doClean -- 606
doClean = function() -- 606
	if building then -- 607
		return -- 607
	end -- 607
	local writablePath = Content.writablePath -- 608
	local targetDir = Path(writablePath, ".build") -- 609
	Content:clearPathCache() -- 610
	if Content:remove(targetDir) then -- 611
		return print("Cleaned: " .. tostring(targetDir)) -- 612
	end -- 611
end -- 606
local screenScale = 2.0 -- 614
local scaleContent = false -- 615
local isInEntry = true -- 616
local currentEntry = nil -- 617
local footerWindow = nil -- 619
local entryWindow = nil -- 620
local testingThread = nil -- 621
local mobileMode = config.mobileFeed -- 622
local pendingUIMode = nil -- 623
local feedHost = nil -- 624
local remixHost = nil -- 625
local startMobileUI = nil -- 626
local webControlled = false -- 627
local mobileHosts = { } -- 628
local suspendedMobileHosts = { } -- 629
local trackMobileHost -- 631
trackMobileHost = function(host) -- 631
	do -- 632
		local _accum_0 = { } -- 632
		local _len_0 = 1 -- 632
		for _index_0 = 1, #mobileHosts do -- 632
			local item = mobileHosts[_index_0] -- 632
			if item.parent then -- 632
				_accum_0[_len_0] = item -- 632
				_len_0 = _len_0 + 1 -- 632
			end -- 632
		end -- 632
		mobileHosts = _accum_0 -- 632
	end -- 632
	mobileHosts[#mobileHosts + 1] = host -- 633
	return host -- 634
end -- 631
local clearMobileUI -- 636
clearMobileUI = function() -- 636
	for _index_0 = 1, #mobileHosts do -- 637
		local host = mobileHosts[_index_0] -- 637
		if host.parent then -- 638
			host:removeFromParent(true) -- 638
		end -- 638
	end -- 637
	mobileHosts = { } -- 639
	suspendedMobileHosts = { } -- 640
	feedHost = nil -- 641
	remixHost = nil -- 642
end -- 636
local syncWebIDEControl -- 644
syncWebIDEControl = function() -- 644
	local connected = HttpServer.wsConnectionCount > 0 -- 645
	if connected then -- 646
		pendingUIMode = nil -- 647
		for _index_0 = 1, #mobileHosts do -- 648
			local host = mobileHosts[_index_0] -- 648
			if not host.parent then -- 649
				goto _continue_0 -- 649
			end -- 649
			if not (suspendedMobileHosts[host] ~= nil) then -- 650
				suspendedMobileHosts[host] = host.visible -- 651
				host:emit("SuspendLocalUI") -- 652
			end -- 650
			host.visible = false -- 653
			::_continue_0:: -- 649
		end -- 648
	elseif webControlled then -- 654
		for host, visible in pairs(suspendedMobileHosts) do -- 655
			if host.parent then -- 656
				host.visible = visible -- 657
				host:emit("ResumeLocalUI") -- 658
			end -- 656
		end -- 655
		suspendedMobileHosts = { } -- 659
	end -- 646
	webControlled = connected -- 660
	return connected -- 661
end -- 644
local getUIMode -- 663
getUIMode = function() -- 663
	return mobileMode and "mobile" or "traditional" -- 663
end -- 663
_module_0["getUIMode"] = getUIMode -- 663
local setUIMode -- 664
setUIMode = function(mode) -- 664
	if not (("mobile" == mode or "traditional" == mode)) then -- 665
		return false -- 665
	end -- 665
	if HttpServer.wsConnectionCount > 0 then -- 666
		return false -- 666
	end -- 666
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 667
		return false -- 667
	end -- 667
	local wantsMobile = mode == "mobile" -- 668
	if wantsMobile == mobileMode then -- 669
		return true -- 669
	end -- 669
	if mobileMode then -- 670
		if not (feedHost and feedHost.visible) then -- 671
			return false -- 671
		end -- 671
		feedHost:emit("SwitchUIMode") -- 673
		return pendingUIMode == false -- 674
	end -- 670
	pendingUIMode = true -- 675
	return true -- 676
end -- 664
_module_0["setUIMode"] = setUIMode -- 664
local applyUIMode -- 678
applyUIMode = function(enabled) -- 678
	if HttpServer.wsConnectionCount > 0 then -- 680
		return false -- 680
	end -- 680
	if enabled then -- 681
		local ok, err = pcall(startMobileUI) -- 682
		if not ok then -- 683
			if feedHost then -- 684
				feedHost:removeFromParent(true) -- 684
			end -- 684
			feedHost = nil -- 685
			mobileMode = false -- 686
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 687
			return false -- 688
		end -- 683
	else -- 690
		clearMobileUI() -- 690
		updateEntries() -- 691
	end -- 681
	mobileMode = enabled -- 692
	config.mobileFeed = enabled -- 693
	return true -- 694
end -- 678
local setupEventHandlers = nil -- 696
local allClear -- 698
allClear = function() -- 698
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 700
		clearMobileUI() -- 700
	end -- 700
	local systemNodes = { } -- 703
	local preserveSystemNode -- 704
	preserveSystemNode = function(node) -- 704
		if systemNodes[node] then -- 705
			return -- 705
		end -- 705
		systemNodes[node] = true -- 706
		do -- 707
			local clip = tolua.cast(node, "ClipNode") -- 707
			if clip then -- 707
				if clip.stencil then -- 708
					preserveSystemNode(clip.stencil) -- 708
				end -- 708
			end -- 707
		end -- 707
		return node:eachChild(function(child) -- 709
			preserveSystemNode(child) -- 710
			return false -- 711
		end) -- 709
	end -- 704
	for _index_0 = 1, #Routine do -- 712
		local routine = Routine[_index_0] -- 712
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 714
			goto _continue_0 -- 715
		else -- 717
			Routine:remove(routine) -- 717
		end -- 713
		::_continue_0:: -- 713
	end -- 712
	for _index_0 = 1, #moduleCache do -- 718
		local module = moduleCache[_index_0] -- 718
		package.loaded[module] = nil -- 719
	end -- 718
	moduleCache = { } -- 720
	Director:cleanup() -- 721
	Entity:clear() -- 722
	Platformer.Data:clear() -- 723
	Platformer.UnitAction:clear() -- 724
	Audio:stopAll(0.2) -- 725
	Struct:clear() -- 726
	View.postEffect = nil -- 727
	View.scale = scaleContent and screenScale or 1 -- 728
	Director.clearColor = Color(0xff1a1a1a) -- 729
	teal.clear() -- 730
	yue.clear() -- 731
	preserveSystemNode(Director.systemUI) -- 734
	for _, item in pairs(ubox()) do -- 735
		local node = tolua.cast(item, "Node") -- 736
		if node then -- 736
			if not systemNodes[node] then -- 737
				node:cleanup() -- 737
			end -- 737
		end -- 736
	end -- 735
	collectgarbage() -- 738
	collectgarbage() -- 739
	Wasm:clear() -- 740
	thread(function() -- 741
		sleep() -- 742
		return Cache:removeUnused() -- 743
	end) -- 741
	setupEventHandlers() -- 744
	Content.searchPaths = searchPaths -- 745
	App.idled = true -- 746
end -- 698
_module_0["allClear"] = allClear -- 698
local clearTempFiles -- 748
clearTempFiles = function() -- 748
	local writablePath = Content.writablePath -- 749
	if Content:exist(Path(writablePath, ".upload")) then -- 750
		Content:remove(Path(writablePath, ".upload")) -- 750
	end -- 750
	if Content:exist(Path(writablePath, ".download")) then -- 751
		return Content:remove(Path(writablePath, ".download")) -- 751
	end -- 751
end -- 748
local waitForWebStart = true -- 753
thread(function() -- 754
	sleep(2) -- 755
	waitForWebStart = false -- 756
end) -- 754
local reloadDevEntry -- 758
reloadDevEntry = function() -- 758
	return thread(function() -- 758
		waitForWebStart = true -- 759
		doClean() -- 760
		allClear() -- 761
		_G.require = oldRequire -- 762
		Dora.require = oldRequire -- 763
		package.loaded["Script.Dev.Entry"] = nil -- 764
		package.loaded["Script.Dev.WebServer"] = nil -- 765
		return Director.systemScheduler:schedule(function() -- 766
			Routine:clear() -- 767
			oldRequire("Script.Dev.Entry") -- 768
			return true -- 769
		end) -- 766
	end) -- 758
end -- 758
local setWorkspace -- 771
setWorkspace = function(path) -- 771
	clearTempFiles() -- 772
	Content.writablePath = path -- 773
	config.writablePath = Content.writablePath -- 774
	return thread(function() -- 775
		sleep() -- 776
		return reloadDevEntry() -- 777
	end) -- 775
end -- 771
_module_0["setWorkspace"] = setWorkspace -- 771
local quit = false -- 779
local activeSearchId = 0 -- 781
local handleSearchFiles -- 783
handleSearchFiles = function(payload) -- 783
	if not payload then -- 784
		return -- 784
	end -- 784
	local id = payload.id -- 785
	if id == nil then -- 786
		return -- 786
	end -- 786
	activeSearchId = id -- 787
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 788
	if path == nil then -- 789
		path = "" -- 789
	end -- 789
	if exts == nil then -- 790
		exts = { } -- 790
	end -- 790
	if globs == nil then -- 791
		globs = { } -- 791
	end -- 791
	if extensionLevels == nil then -- 792
		extensionLevels = { } -- 792
	end -- 792
	if pattern == nil then -- 793
		pattern = "" -- 793
	end -- 793
	if pattern == "" then -- 795
		return -- 795
	end -- 795
	local useRegex = payload.useRegex == true -- 796
	local caseSensitive = payload.caseSensitive == true -- 797
	local includeContent = payload.includeContent ~= false -- 798
	local contentWindow = payload.contentWindow or 0 -- 799
	return Director.systemScheduler:schedule(once(function() -- 800
		local stopped = false -- 801
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 802
			if activeSearchId ~= id then -- 803
				stopped = true -- 804
				return true -- 805
			end -- 803
			emit("AppWS", "Send", json.encode({ -- 807
				name = "SearchFilesResult", -- 807
				id = id, -- 807
				result = result -- 807
			})) -- 806
			return false -- 809
		end) -- 802
		return emit("AppWS", "Send", json.encode({ -- 811
			name = "SearchFilesDone", -- 811
			id = id, -- 811
			stopped = stopped -- 811
		})) -- 810
	end)) -- 800
end -- 783
local stop -- 814
stop = function() -- 814
	if isInEntry then -- 815
		return false -- 815
	end -- 815
	allClear() -- 816
	isInEntry = true -- 817
	currentEntry = nil -- 818
	return true -- 819
end -- 814
_module_0["stop"] = stop -- 814
local getCurrentEntryStatus -- 821
getCurrentEntryStatus = function() -- 821
	local entry = currentEntry -- 822
	if not (entry and not isInEntry) then -- 823
		return { -- 823
			success = true, -- 823
			running = false -- 823
		} -- 823
	end -- 823
	local status = { -- 825
		success = true, -- 825
		running = true, -- 826
		kind = entry.runKind or "file", -- 827
		entryName = entry.entryName, -- 828
		fileName = entry.fileName -- 829
	} -- 824
	if entry.workDir then -- 830
		status.workDir = entry.workDir -- 830
	end -- 830
	if entry.projectRoot then -- 831
		status.projectRoot = entry.projectRoot -- 831
	end -- 831
	return status -- 832
end -- 821
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 821
local _anon_func_2 = function(_with_0) -- 851
	local _val_0 = App.platform -- 851
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 851
end -- 851
setupEventHandlers = function() -- 834
	local _with_0 = Director.postNode -- 835
	_with_0:onAppEvent(function(eventType) -- 836
		if "Quit" == eventType then -- 837
			quit = true -- 838
			allClear() -- 839
			return clearTempFiles() -- 840
		elseif "Shutdown" == eventType then -- 841
			return stop() -- 842
		end -- 836
	end) -- 836
	_with_0:onAppChange(function(settingName) -- 843
		if "Theme" == settingName then -- 844
			config.themeColor = App.themeColor:toARGB() -- 845
		elseif "Locale" == settingName then -- 846
			config.locale = App.locale -- 847
			updateLocale() -- 848
			return teal.clear(true) -- 849
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 850
			if _anon_func_2(_with_0) then -- 851
				if "FullScreen" == settingName then -- 853
					config.fullScreen = App.fullScreen -- 853
				elseif "Position" == settingName then -- 854
					local _obj_0 = App.winPosition -- 854
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 854
				elseif "Size" == settingName then -- 855
					local width, height -- 856
					do -- 856
						local _obj_0 = App.winSize -- 856
						width, height = _obj_0.width, _obj_0.height -- 856
					end -- 856
					config.winWidth = width -- 857
					config.winHeight = height -- 858
				end -- 852
			end -- 851
		end -- 843
	end) -- 843
	_with_0:onAppWS(function(event) -- 859
		if event.type == "Close" then -- 860
			if HttpServer.wsConnectionCount == 0 then -- 861
				updateEntries() -- 862
			end -- 861
			return -- 863
		end -- 860
		if not (event.type == "Receive") then -- 864
			return -- 864
		end -- 864
		local data = json.decode(event.msg) -- 865
		if not data then -- 866
			return -- 866
		end -- 866
		local _exp_0 = data.name -- 867
		if "SearchFiles" == _exp_0 then -- 868
			return handleSearchFiles(data) -- 869
		elseif "SearchFilesStop" == _exp_0 then -- 870
			if data.id == nil or data.id == activeSearchId then -- 871
				activeSearchId = 0 -- 872
			end -- 871
		end -- 867
	end) -- 859
	_with_0:slot("UpdateEntries", function() -- 873
		return updateEntries() -- 873
	end) -- 873
	return _with_0 -- 835
end -- 834
setupEventHandlers() -- 875
clearTempFiles() -- 876
local downloadFile -- 878
downloadFile = function(url, target) -- 878
	return Director.systemScheduler:schedule(once(function() -- 878
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 879
			if quit then -- 880
				return true -- 880
			end -- 880
			emit("AppWS", "Send", json.encode({ -- 882
				name = "Download", -- 882
				url = url, -- 882
				status = "downloading", -- 882
				progress = current / total -- 883
			})) -- 881
			return false -- 879
		end) -- 879
		return emit("AppWS", "Send", json.encode(success and { -- 886
			name = "Download", -- 886
			url = url, -- 886
			status = "completed", -- 886
			progress = 1.0 -- 887
		} or { -- 889
			name = "Download", -- 889
			url = url, -- 889
			status = "failed", -- 889
			progress = 0.0 -- 890
		})) -- 885
	end)) -- 878
end -- 878
_module_0["downloadFile"] = downloadFile -- 878
local _anon_func_3 = function(file, require, workDir) -- 901
	if workDir == nil then -- 901
		workDir = Path:getPath(file) -- 901
	end -- 901
	Content:insertSearchPath(1, workDir) -- 902
	local scriptPath = Path(workDir, "Script") -- 903
	if Content:exist(scriptPath) then -- 904
		Content:insertSearchPath(1, scriptPath) -- 905
	end -- 904
	local result = require(file) -- 906
	if "function" == type(result) then -- 907
		result() -- 907
	end -- 907
	return nil -- 908
end -- 901
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 937
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 937
	label.alignment = "Left" -- 938
	label.textWidth = width - fontSize -- 939
	label.text = err -- 940
	return label -- 937
end -- 937
local enterEntryAsync -- 893
enterEntryAsync = function(entry) -- 893
	isInEntry = false -- 894
	App.idled = false -- 895
	emit(Profiler.EventName, "ClearLoader") -- 896
	currentEntry = entry -- 897
	local file, workDir = entry.fileName, entry.workDir -- 898
	sleep() -- 899
	return xpcall(_anon_func_3, function(msg) -- 908
		local err = debug.traceback(msg) -- 910
		Log("Error", err) -- 911
		allClear() -- 912
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 913
		local viewWidth, viewHeight -- 914
		do -- 914
			local _obj_0 = View.size -- 914
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 914
		end -- 914
		local width, height = viewWidth - 20, viewHeight - 20 -- 915
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 916
		Director.ui:addChild((function() -- 917
			local root = AlignNode() -- 917
			do -- 918
				local _obj_0 = App.bufferSize -- 918
				width, height = _obj_0.width, _obj_0.height -- 918
			end -- 918
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 919
			root:onAppChange(function(settingName) -- 920
				if settingName == "Size" then -- 920
					do -- 921
						local _obj_0 = App.bufferSize -- 921
						width, height = _obj_0.width, _obj_0.height -- 921
					end -- 921
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 922
				end -- 920
			end) -- 920
			root:addChild((function() -- 923
				local _with_0 = ScrollArea({ -- 924
					width = width, -- 924
					height = height, -- 925
					paddingX = 0, -- 926
					paddingY = 50, -- 927
					viewWidth = height, -- 928
					viewHeight = height -- 929
				}) -- 923
				root:onAlignLayout(function(w, h) -- 931
					_with_0.position = Vec2(w / 2, h / 2) -- 932
					w = w - 20 -- 933
					h = h - 20 -- 934
					_with_0.view.children.first.textWidth = w - fontSize -- 935
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 936
				end) -- 931
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 937
				return _with_0 -- 923
			end)()) -- 923
			return root -- 917
		end)()) -- 917
		return err -- 941
	end, file, require, workDir) -- 900
end -- 893
_module_0["enterEntryAsync"] = enterEntryAsync -- 893
local enterDemoEntry -- 943
enterDemoEntry = function(entry) -- 943
	return thread(function() -- 943
		return enterEntryAsync(entry) -- 943
	end) -- 943
end -- 943
local reloadCurrentEntry -- 945
reloadCurrentEntry = function() -- 945
	if currentEntry then -- 946
		allClear() -- 947
		return enterDemoEntry(currentEntry) -- 948
	end -- 946
end -- 945
Director.clearColor = Color(0xff1a1a1a) -- 950
local descColor = Color(0xffa1a1a1) -- 951
local extraOperations -- 953
do -- 953
	local isOSSLicenseExist = Content:exist("LICENSES") -- 954
	local ossLicenses = nil -- 955
	local ossLicenseOpen = false -- 956
	local failedSetFolder = false -- 957
	local statusFlags = { -- 958
		"NoResize", -- 958
		"NoMove", -- 958
		"NoCollapse", -- 958
		"AlwaysAutoResize", -- 958
		"NoSavedSettings" -- 958
	} -- 958
	extraOperations = function() -- 965
		local zh = useChinese -- 966
		if isDesktop then -- 967
			local alwaysOnTop = config.alwaysOnTop -- 968
			local changed -- 969
			changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 969
			if changed then -- 969
				App.alwaysOnTop = alwaysOnTop -- 970
				config.alwaysOnTop = alwaysOnTop -- 971
			end -- 969
		end -- 967
		local showPreview, authRequired, webIDETourCompleted = config.showPreview, config.authRequired, config.webIDETourCompleted -- 972
		do -- 977
			local changed -- 977
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 977
			if changed then -- 977
				config.showPreview = showPreview -- 978
				updateEntries() -- 979
				if not showPreview then -- 980
					thread(function() -- 981
						collectgarbage() -- 982
						return Cache:removeUnused("Texture") -- 983
					end) -- 981
				end -- 980
			end -- 977
		end -- 977
		do -- 984
			local changed -- 984
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 984
			if changed then -- 984
				config.authRequired = authRequired -- 985
				HttpServer.authRequired = authRequired -- 986
			end -- 984
		end -- 984
		SameLine() -- 987
		TextColored(descColor, "(?)") -- 988
		if IsItemHovered() then -- 989
			BeginTooltip(function() -- 990
				return PushTextWrapPos(280, function() -- 991
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 992
				end) -- 991
			end) -- 990
		end -- 989
		do -- 993
			local themeColor = App.themeColor -- 994
			local writablePath = config.writablePath -- 995
			SeparatorText(zh and "工作目录" or "Workspace") -- 996
			PushTextWrapPos(400, function() -- 997
				return TextColored(themeColor, writablePath) -- 998
			end) -- 997
			if not isDesktop then -- 999
				goto skipSetting -- 999
			end -- 999
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1000
			if Button(zh and "改变目录" or "Set Folder") then -- 1001
				App:openFileDialog(true, function(path) -- 1002
					if path == "" then -- 1003
						return -- 1003
					end -- 1003
					local relPath = Path:getRelative(Content.assetPath, path) -- 1004
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1005
						return setWorkspace(path) -- 1006
					else -- 1008
						failedSetFolder = true -- 1008
					end -- 1005
				end) -- 1002
			end -- 1001
			if failedSetFolder then -- 1009
				failedSetFolder = false -- 1010
				OpenPopup(popupName) -- 1011
			end -- 1009
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1012
			BeginPopupModal(popupName, statusFlags, function() -- 1013
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1014
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1015
					return CloseCurrentPopup() -- 1016
				end -- 1015
			end) -- 1013
			SameLine() -- 1017
			if Button(zh and "使用默认" or "Use Default") then -- 1018
				setWorkspace(Content.appPath) -- 1019
			end -- 1018
			Separator() -- 1020
			::skipSetting:: -- 1021
		end -- 993
		if isOSSLicenseExist then -- 1022
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1023
				if not ossLicenses then -- 1024
					ossLicenses = { } -- 1025
					local licenseText = Content:load("LICENSES") -- 1026
					ossLicenseOpen = (licenseText ~= nil) -- 1027
					if ossLicenseOpen then -- 1027
						licenseText = licenseText:gsub("\r\n", "\n") -- 1028
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1029
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1030
							if name then -- 1030
								ossLicenses[#ossLicenses + 1] = { -- 1031
									name, -- 1031
									text -- 1031
								} -- 1031
							end -- 1030
						end -- 1029
					end -- 1027
				else -- 1033
					ossLicenseOpen = true -- 1033
				end -- 1024
			end -- 1023
			if ossLicenseOpen then -- 1034
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1035
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1036
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1037
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1038
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 1041
						"NoSavedSettings" -- 1041
					}, function() -- 1042
						for _index_0 = 1, #ossLicenses do -- 1042
							local _des_0 = ossLicenses[_index_0] -- 1042
							local firstLine, text = _des_0[1], _des_0[2] -- 1042
							local name, license = firstLine:match("(.+): (.+)") -- 1043
							TextColored(themeColor, name) -- 1044
							SameLine() -- 1045
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1046
								return TextWrapped(text) -- 1046
							end) -- 1046
						end -- 1042
					end) -- 1038
				end) -- 1038
			end -- 1034
		end -- 1022
		if not App.debugging then -- 1048
			return -- 1048
		end -- 1048
		return TreeNode(zh and "开发操作" or "Development", function() -- 1049
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1050
				OpenPopup("build") -- 1050
			end -- 1050
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1051
				return BeginPopup("build", function() -- 1051
					if Selectable(zh and "编译" or "Compile") then -- 1052
						doCompile(false) -- 1052
					end -- 1052
					Separator() -- 1053
					if Selectable(zh and "压缩" or "Minify") then -- 1054
						doCompile(true) -- 1054
					end -- 1054
					Separator() -- 1055
					if Selectable(zh and "清理" or "Clean") then -- 1056
						return doClean() -- 1056
					end -- 1056
				end) -- 1051
			end) -- 1051
			if isInEntry then -- 1057
				if waitForWebStart then -- 1058
					BeginDisabled(function() -- 1059
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1059
					end) -- 1059
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1060
					reloadDevEntry() -- 1061
				end -- 1058
			end -- 1057
			do -- 1062
				local changed -- 1062
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1062
				if changed then -- 1062
					View.scale = scaleContent and screenScale or 1 -- 1063
				end -- 1062
			end -- 1062
			do -- 1064
				local changed -- 1064
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1064
				if changed then -- 1064
					config.engineDev = engineDev -- 1065
				end -- 1064
			end -- 1064
			do -- 1066
				local changed -- 1066
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1066
				if changed then -- 1066
					config.webIDETourCompleted = webIDETourCompleted -- 1067
				end -- 1066
			end -- 1066
			if testingThread then -- 1068
				return BeginDisabled(function() -- 1069
					return Button(zh and "开始自动测试" or "Test automatically") -- 1069
				end) -- 1069
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1070
				testingThread = thread(function() -- 1071
					local _ <close> = setmetatable({ }, { -- 1072
						__close = function() -- 1072
							allClear() -- 1073
							testingThread = nil -- 1074
							isInEntry = true -- 1075
							currentEntry = nil -- 1076
							return print("Testing done!") -- 1077
						end -- 1072
					}) -- 1072
					for _, entry in ipairs(allEntries) do -- 1078
						allClear() -- 1079
						print("Start " .. tostring(entry.entryName)) -- 1080
						enterDemoEntry(entry) -- 1081
						sleep(2) -- 1082
						print("Stop " .. tostring(entry.entryName)) -- 1083
					end -- 1078
				end) -- 1071
			end -- 1068
		end) -- 1049
	end -- 965
end -- 953
local icon = Path("Script", "Dev", "icon_s.png") -- 1085
local iconTex = nil -- 1086
thread(function() -- 1087
	if Cache:loadAsync(icon) then -- 1087
		iconTex = Texture2D(icon) -- 1087
	end -- 1087
end) -- 1087
local webStatus = nil -- 1089
local urlClicked = nil -- 1090
local authCode = string.format("%06d", math.random(0, 999999)) -- 1092
local authCodeTTL = 30.0 -- 1094
_module_0.getAuthCode = function() -- 1095
	return authCode -- 1095
end -- 1095
_module_0.invalidateAuthCode = function() -- 1096
	authCode = string.format("%06d", math.random(0, 999999)) -- 1097
	authCodeTTL = 30.0 -- 1098
end -- 1096
local AuthSession -- 1100
do -- 1100
	local pending = nil -- 1101
	local session = nil -- 1102
	AuthSession = { -- 1104
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1104
			pending = { -- 1106
				sessionId = sessionId, -- 1106
				confirmCode = confirmCode, -- 1107
				expiresAt = expiresAt, -- 1108
				ttl = ttl, -- 1109
				approved = false -- 1110
			} -- 1105
		end, -- 1104
		getPending = function() -- 1112
			return pending -- 1112
		end, -- 1112
		approvePending = function(sessionId) -- 1114
			if pending and pending.sessionId == sessionId then -- 1115
				pending.approved = true -- 1116
				return true -- 1117
			end -- 1115
			return false -- 1118
		end, -- 1114
		clearPending = function() -- 1120
			pending = nil -- 1120
		end, -- 1120
		setSession = function(sessionId, sessionSecret) -- 1122
			session = { -- 1124
				sessionId = sessionId, -- 1124
				sessionSecret = sessionSecret -- 1125
			} -- 1123
		end, -- 1122
		getSession = function() -- 1127
			return session -- 1127
		end -- 1127
	} -- 1103
end -- 1100
_module_0["AuthSession"] = AuthSession -- 1100
local transparant = Color(0x0) -- 1130
local windowFlags = { -- 1131
	"NoTitleBar", -- 1131
	"NoResize", -- 1131
	"NoMove", -- 1131
	"NoCollapse", -- 1131
	"NoSavedSettings", -- 1131
	"NoFocusOnAppearing", -- 1131
	"NoBringToFrontOnFocus" -- 1131
} -- 1131
local statusFlags = { -- 1140
	"NoTitleBar", -- 1140
	"NoResize", -- 1140
	"NoMove", -- 1140
	"NoCollapse", -- 1140
	"AlwaysAutoResize", -- 1140
	"NoSavedSettings" -- 1140
} -- 1140
local displayWindowFlags = { -- 1148
	"NoDecoration", -- 1148
	"NoSavedSettings", -- 1148
	"NoMove", -- 1148
	"NoScrollWithMouse", -- 1148
	"AlwaysAutoResize", -- 1148
	"NoFocusOnAppearing" -- 1148
} -- 1148
local gamepadInputWindowFlags = { -- 1156
	"NoDecoration", -- 1156
	"NoSavedSettings", -- 1156
	"NoMove", -- 1156
	"NoScrollbar", -- 1156
	"NoScrollWithMouse", -- 1156
	"NoFocusOnAppearing", -- 1156
	"NoBringToFrontOnFocus" -- 1156
} -- 1156
local initFooter = true -- 1165
local gamepadInputFocused = false -- 1166
local _anon_func_5 = function(allEntries, currentIndex) -- 1208
	if currentIndex > 1 then -- 1208
		return allEntries[currentIndex - 1] -- 1209
	else -- 1211
		return allEntries[#allEntries] -- 1211
	end -- 1208
end -- 1208
local _anon_func_6 = function(allEntries, currentIndex) -- 1215
	if currentIndex < #allEntries then -- 1215
		return allEntries[currentIndex + 1] -- 1216
	else -- 1218
		return allEntries[1] -- 1218
	end -- 1215
end -- 1215
footerWindow = threadLoop(function() -- 1167
	if mobileMode then -- 1168
		return -- 1168
	end -- 1168
	local zh = useChinese -- 1169
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1170
	if authCodeTTL <= 0 then -- 1171
		authCodeTTL = 30.0 -- 1172
		authCode = string.format("%06d", math.random(0, 999999)) -- 1173
	end -- 1171
	if HttpServer.wsConnectionCount > 0 then -- 1174
		return -- 1175
	end -- 1174
	if Keyboard:isKeyDown("Escape") then -- 1176
		allClear() -- 1177
		App.devMode = false -- 1178
		App:shutdown() -- 1179
	end -- 1176
	do -- 1180
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1181
		if ctrl and Keyboard:isKeyDown("Q") then -- 1182
			stop() -- 1183
		end -- 1182
		if ctrl and Keyboard:isKeyDown("Z") then -- 1184
			reloadCurrentEntry() -- 1185
		end -- 1184
		if ctrl and Keyboard:isKeyDown(",") then -- 1186
			if showFooter then -- 1187
				showStats = not showStats -- 1187
			else -- 1187
				showStats = true -- 1187
			end -- 1187
			showFooter = true -- 1188
			config.showFooter = showFooter -- 1189
			config.showStats = showStats -- 1190
		end -- 1186
		if ctrl and Keyboard:isKeyDown(".") then -- 1191
			if showFooter then -- 1192
				showConsole = not showConsole -- 1192
			else -- 1192
				showConsole = true -- 1192
			end -- 1192
			showFooter = true -- 1193
			config.showFooter = showFooter -- 1194
			config.showConsole = showConsole -- 1195
		end -- 1191
		if ctrl and Keyboard:isKeyDown("/") then -- 1196
			showFooter = not showFooter -- 1197
			config.showFooter = showFooter -- 1198
		end -- 1196
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1199
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1200
		local currentIndex = nil -- 1201
		for i, entry in ipairs(allEntries) do -- 1202
			if currentEntry == entry then -- 1203
				currentIndex = i -- 1204
			end -- 1203
		end -- 1202
		if left then -- 1205
			allClear() -- 1206
			if currentIndex == nil then -- 1207
				currentIndex = #allEntries + 1 -- 1207
			end -- 1207
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1208
		end -- 1205
		if right then -- 1212
			allClear() -- 1213
			if currentIndex == nil then -- 1214
				currentIndex = 0 -- 1214
			end -- 1214
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1215
		end -- 1212
	end -- 1180
	if not showEntry then -- 1219
		return -- 1219
	end -- 1219
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1221
		reloadDevEntry() -- 1225
	end -- 1221
	if initFooter then -- 1226
		initFooter = false -- 1227
	end -- 1226
	local width, height -- 1229
	do -- 1229
		local _obj_0 = App.visualSize -- 1229
		width, height = _obj_0.width, _obj_0.height -- 1229
	end -- 1229
	if isInEntry then -- 1230
		gamepadInputFocused = false -- 1231
	else -- 1233
		SetNextWindowBgAlpha(0.0) -- 1233
		SetNextWindowSize(Vec2(1, 1), "Always") -- 1234
		SetNextWindowPos(Vec2.zero, "Always") -- 1235
		PushStyleVar("WindowPadding", Vec2.zero, function() -- 1236
			return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1237
				return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1238
					if not gamepadInputFocused then -- 1239
						SetWindowFocus("DoraGamepadInput") -- 1240
						gamepadInputFocused = true -- 1241
					end -- 1239
				end) -- 1238
			end) -- 1237
		end) -- 1236
	end -- 1230
	if isInEntry or showFooter then -- 1243
		SetNextWindowSize(Vec2(width, 50)) -- 1244
		SetNextWindowPos(Vec2(0, height - 50)) -- 1245
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1246
			return PushStyleVar("WindowRounding", 0, function() -- 1247
				return Begin("Footer", windowFlags, function() -- 1248
					Separator() -- 1249
					if iconTex then -- 1250
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1251
							showStats = not showStats -- 1252
							config.showStats = showStats -- 1253
						end -- 1251
						SameLine() -- 1254
						if Button(">_", Vec2(30, 30)) then -- 1255
							showConsole = not showConsole -- 1256
							config.showConsole = showConsole -- 1257
						end -- 1255
					end -- 1250
					if isInEntry and config.updateNotification then -- 1258
						SameLine() -- 1259
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1260
							allClear() -- 1261
							config.updateNotification = false -- 1262
							enterDemoEntry({ -- 1264
								entryName = "SelfUpdater", -- 1264
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1265
							}) -- 1263
						end -- 1260
					end -- 1258
					if not isInEntry then -- 1266
						SameLine() -- 1267
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1268
						local currentIndex = nil -- 1269
						for i, entry in ipairs(allEntries) do -- 1270
							if currentEntry == entry then -- 1271
								currentIndex = i -- 1272
							end -- 1271
						end -- 1270
						if currentIndex then -- 1273
							if currentIndex > 1 then -- 1274
								SameLine() -- 1275
								if Button("<<", Vec2(30, 30)) then -- 1276
									allClear() -- 1277
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1278
								end -- 1276
							end -- 1274
							if currentIndex < #allEntries then -- 1279
								SameLine() -- 1280
								if Button(">>", Vec2(30, 30)) then -- 1281
									allClear() -- 1282
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1283
								end -- 1281
							end -- 1279
						end -- 1273
						SameLine() -- 1284
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1285
							reloadCurrentEntry() -- 1286
						end -- 1285
						if back then -- 1287
							allClear() -- 1288
							isInEntry = true -- 1289
							currentEntry = nil -- 1290
						end -- 1287
					end -- 1266
				end) -- 1248
			end) -- 1247
		end) -- 1246
	end -- 1243
	if isInEntry then -- 1292
		local showURL = true -- 1293
		local webIDEWidth -- 1294
		do -- 1294
			local base -- 1295
			if config.updateNotification then -- 1295
				base = 460 -- 1295
			else -- 1295
				base = 360 -- 1295
			end -- 1295
			local extra -- 1296
			if config.authRequired then -- 1296
				extra = 35 -- 1296
			else -- 1296
				extra = 0 -- 1296
			end -- 1296
			webIDEWidth = base + extra -- 1297
		end -- 1294
		if width < webIDEWidth then -- 1298
			showURL = false -- 1298
		end -- 1298
		SetNextWindowBgAlpha(0.0) -- 1299
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1300
		Begin("Web IDE", displayWindowFlags, function() -- 1301
			local pending = AuthSession.getPending() -- 1302
			local hovered = false -- 1303
			if not pending and showURL then -- 1304
				do -- 1305
					local url -- 1305
					if webStatus ~= nil then -- 1305
						url = webStatus.url -- 1305
					end -- 1305
					if url then -- 1305
						if isDesktop and not config.fullScreen then -- 1306
							if urlClicked then -- 1307
								BeginDisabled(function() -- 1308
									return Button(url) -- 1308
								end) -- 1308
							elseif Button(url) then -- 1309
								urlClicked = once(function() -- 1310
									return sleep(5) -- 1310
								end) -- 1310
								App:openURL("http://localhost:8866") -- 1311
							end -- 1307
						else -- 1313
							TextColored(descColor, url) -- 1313
						end -- 1306
					else -- 1315
						TextColored(descColor, zh and '不可用' or 'not available') -- 1315
					end -- 1305
				end -- 1305
				hovered = IsItemHovered() -- 1316
			else -- 1318
				TextColored(descColor, "(?)") -- 1318
				hovered = IsItemHovered() -- 1319
			end -- 1304
			SameLine() -- 1320
			local themeColor = App.themeColor -- 1321
			if pending then -- 1322
				if not pending.approved then -- 1323
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1324
					local ttl = pending.ttl or 1 -- 1325
					PushStyleColor("Text", themeColor, function() -- 1326
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1327
						hovered = hovered or IsItemHovered() -- 1328
					end) -- 1326
					SameLine() -- 1329
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1330
						AuthSession.approvePending(pending.sessionId) -- 1331
					end -- 1330
					if hovered then -- 1332
						return BeginTooltip(function() -- 1333
							return PushTextWrapPos(280, function() -- 1334
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1335
							end) -- 1334
						end) -- 1333
					end -- 1332
				end -- 1323
			else -- 1337
				if config.authRequired then -- 1337
					PushStyleColor("Text", themeColor, function() -- 1338
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1339
						hovered = hovered or IsItemHovered() -- 1340
					end) -- 1338
					if hovered then -- 1341
						return BeginTooltip(function() -- 1342
							return PushTextWrapPos(280, function() -- 1343
								local url -- 1344
								if webStatus ~= nil then -- 1344
									url = webStatus.url -- 1344
								end -- 1344
								if url then -- 1344
									local address -- 1345
									if showURL then -- 1345
										address = "Web IDE" -- 1345
									else -- 1345
										address = url -- 1345
									end -- 1345
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) .. " 并输入后面的 PIN 码进行使用 （PIN 仅用于一次认证）" or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network and enter the PIN below to start (PIN is one-time)") -- 1346
								else -- 1348
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1348
								end -- 1344
							end) -- 1343
						end) -- 1342
					end -- 1341
				else -- 1350
					if hovered then -- 1350
						return BeginTooltip(function() -- 1351
							return PushTextWrapPos(280, function() -- 1352
								local url -- 1353
								if webStatus ~= nil then -- 1353
									url = webStatus.url -- 1353
								end -- 1353
								if url then -- 1353
									local address -- 1354
									if showURL then -- 1354
										address = "Web IDE" -- 1354
									else -- 1354
										address = url -- 1354
									end -- 1354
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network") -- 1355
								else -- 1357
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1357
								end -- 1353
							end) -- 1352
						end) -- 1351
					end -- 1350
				end -- 1337
			end -- 1322
		end) -- 1301
	end -- 1292
	if not isInEntry then -- 1359
		SetNextWindowSize(Vec2(50, 50)) -- 1360
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1361
		PushStyleColor("WindowBg", transparant, function() -- 1362
			return Begin("Show", displayWindowFlags, function() -- 1362
				if width >= 370 then -- 1363
					local changed -- 1364
					changed, showFooter = Checkbox("##dev", showFooter) -- 1364
					if changed then -- 1364
						config.showFooter = showFooter -- 1365
					end -- 1364
				end -- 1363
			end) -- 1362
		end) -- 1362
	end -- 1359
	if isInEntry or showFooter then -- 1367
		if showStats then -- 1368
			PushStyleVar("WindowRounding", 0, function() -- 1369
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1370
				SetNextWindowSize(Vec2(0, height - 50)) -- 1371
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1372
				config.showStats = showStats -- 1373
			end) -- 1369
		end -- 1368
		if showConsole then -- 1374
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1375
			return PushStyleVar("WindowRounding", 6, function() -- 1376
				return ShowConsole() -- 1377
			end) -- 1376
		end -- 1374
	end -- 1367
end) -- 1167
local MaxWidth <const> = 960 -- 1379
local toolOpen = false -- 1381
local filterText = nil -- 1382
local anyEntryMatched = false -- 1383
local match -- 1384
match = function(name) -- 1384
	local res = not filterText or name:lower():match(filterText) -- 1385
	if res then -- 1386
		anyEntryMatched = true -- 1386
	end -- 1386
	return res -- 1387
end -- 1384
local sep -- 1389
sep = function() -- 1389
	return SeparatorText("") -- 1389
end -- 1389
local thinSep -- 1390
thinSep = function() -- 1390
	return PushStyleVar("SeparatorTextBorderSize", 1, sep) -- 1390
end -- 1390
entryWindow = threadLoop(function() -- 1392
	local connected = syncWebIDEControl() -- 1393
	if (pendingUIMode ~= nil) then -- 1395
		local nextMode = pendingUIMode -- 1396
		pendingUIMode = nil -- 1397
		applyUIMode(nextMode) -- 1398
	end -- 1395
	if mobileMode and not connected then -- 1399
		if isInEntry and not feedHost then -- 1400
			applyUIMode(true) -- 1400
		end -- 1400
		return -- 1401
	end -- 1399
	if App.fpsLimited ~= config.fpsLimited then -- 1402
		config.fpsLimited = App.fpsLimited -- 1403
	end -- 1402
	if App.targetFPS ~= config.targetFPS then -- 1404
		config.targetFPS = App.targetFPS -- 1405
	end -- 1404
	if View.vsync ~= config.vsync then -- 1406
		config.vsync = View.vsync -- 1407
	end -- 1406
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1408
		config.fixedFPS = Director.scheduler.fixedFPS -- 1409
	end -- 1408
	if Director.profilerSending ~= config.webProfiler then -- 1410
		config.webProfiler = Director.profilerSending -- 1411
	end -- 1410
	if urlClicked then -- 1412
		local _, result = coroutine.resume(urlClicked) -- 1413
		if result then -- 1414
			coroutine.close(urlClicked) -- 1415
			urlClicked = nil -- 1416
		end -- 1414
	end -- 1412
	if not isInEntry then -- 1417
		return -- 1417
	end -- 1417
	local zh = useChinese -- 1418
	local themeColor = App.themeColor -- 1419
	if connected then -- 1420
		local width, height -- 1421
		do -- 1421
			local _obj_0 = App.visualSize -- 1421
			width, height = _obj_0.width, _obj_0.height -- 1421
		end -- 1421
		SetNextWindowBgAlpha(0.5) -- 1422
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1423
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1424
			Separator() -- 1425
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1426
			if iconTex then -- 1427
				Image(icon, Vec2(24, 24)) -- 1428
				SameLine() -- 1429
			end -- 1427
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1430
			TextColored(descColor, slogon) -- 1431
			return Separator() -- 1432
		end) -- 1424
		return -- 1433
	end -- 1420
	if not showEntry then -- 1434
		return -- 1434
	end -- 1434
	local fullWidth, height -- 1436
	do -- 1436
		local _obj_0 = App.visualSize -- 1436
		fullWidth, height = _obj_0.width, _obj_0.height -- 1436
	end -- 1436
	local width = math.min(MaxWidth, fullWidth) -- 1437
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1438
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1439
	SetNextWindowPos(Vec2.zero) -- 1440
	SetNextWindowBgAlpha(0) -- 1441
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1442
	do -- 1443
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1444
			return Begin("Dora Dev", windowFlags, function() -- 1445
				Dummy(Vec2(fullWidth - 20, 0)) -- 1446
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1447
				SameLine() -- 1448
				if Button(zh and "Go 模式" or "Go Mode") then -- 1449
					setUIMode("mobile") -- 1450
				end -- 1449
				if fullWidth >= 540 then -- 1451
					SameLine() -- 1452
					Dummy(Vec2(fullWidth - 540, 0)) -- 1453
					SameLine() -- 1454
					SetNextItemWidth(zh and -95 or -140) -- 1455
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1456
						"AutoSelectAll" -- 1456
					}) then -- 1456
						config.filter = filterBuf.text -- 1457
					end -- 1456
					SameLine() -- 1458
					if Button(zh and '下载' or 'Download') then -- 1459
						allClear() -- 1460
						enterDemoEntry({ -- 1462
							entryName = "ResourceDownloader", -- 1462
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1463
						}) -- 1461
					end -- 1459
				end -- 1451
				return Separator() -- 1464
			end) -- 1445
		end) -- 1444
	end -- 1443
	anyEntryMatched = false -- 1466
	SetNextWindowPos(Vec2(0, 50)) -- 1467
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1468
	do -- 1469
		return PushStyleColor("WindowBg", transparant, function() -- 1470
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1471
				return PushStyleVar("Alpha", 1, function() -- 1472
					return Begin("Content", windowFlags, function() -- 1473
						local DemoViewWidth <const> = 220 -- 1474
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1475
						if filterText then -- 1476
							filterText = filterText:lower() -- 1476
						end -- 1476
						if #gamesInDev > 0 then -- 1477
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1478
							Columns(columns, false) -- 1479
							local realViewWidth = GetColumnWidth() - 50 -- 1480
							for _index_0 = 1, #gamesInDev do -- 1481
								local game = gamesInDev[_index_0] -- 1481
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1482
								local displayName -- 1491
								if repo then -- 1491
									if zh then -- 1492
										displayName = repo.title.zh -- 1492
									else -- 1492
										displayName = repo.title.en -- 1492
									end -- 1492
								end -- 1491
								if displayName == nil then -- 1493
									displayName = gameName -- 1493
								end -- 1493
								if match(displayName) then -- 1494
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1495
									SameLine() -- 1496
									TextWrapped(displayName) -- 1497
									if columns > 1 then -- 1498
									if bannerFile and bannerTex then -- 1499
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1500
											local displayWidth <const> = realViewWidth -- 1501
											texHeight = displayWidth * texHeight / texWidth -- 1502
											texWidth = displayWidth -- 1503
											Dummy(Vec2.zero) -- 1504
											SameLine() -- 1505
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1506
										end -- 1499
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1507
											enterDemoEntry(game) -- 1508
										end -- 1507
									else -- 1510
									if bannerFile and bannerTex then -- 1510
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1511
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1512
											local sizing = 0.8 -- 1513
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1514
											texWidth = displayWidth * sizing -- 1515
											if texWidth > 500 then -- 1516
												sizing = 0.6 -- 1517
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1518
												texWidth = displayWidth * sizing -- 1519
											end -- 1516
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1520
											Dummy(Vec2(padding, 0)) -- 1521
											SameLine() -- 1522
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1523
										end -- 1510
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1524
											enterDemoEntry(game) -- 1525
										end -- 1524
									end -- 1498
									if #tests == 0 and #examples == 0 then -- 1526
										thinSep() -- 1527
									end -- 1526
									NextColumn() -- 1528
								end -- 1494
								local showSep = false -- 1529
								if #examples > 0 then -- 1530
									local showExample = false -- 1531
									for _index_1 = 1, #examples do -- 1532
										local _des_0 = examples[_index_1] -- 1532
										local entryName = _des_0.entryName -- 1532
										if match(entryName) then -- 1533
											showExample = true -- 1533
											break -- 1533
										end -- 1533
									end -- 1532
									if showExample then -- 1534
										showSep = true -- 1535
										Columns(1, false) -- 1536
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1537
										SameLine() -- 1538
										local opened -- 1539
										if (filterText ~= nil) then -- 1539
											opened = showExample -- 1539
										else -- 1539
											opened = false -- 1539
										end -- 1539
										if game.exampleOpen == nil then -- 1540
											game.exampleOpen = opened -- 1540
										end -- 1540
										SetNextItemOpen(game.exampleOpen) -- 1541
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1542
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1543
												Columns(maxColumns, false) -- 1544
												for _index_1 = 1, #examples do -- 1545
													local example = examples[_index_1] -- 1545
													local entryName = example.entryName -- 1546
													if not match(entryName) then -- 1547
														goto _continue_0 -- 1547
													end -- 1547
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1548
														if Button(entryName, Vec2(-1, 40)) then -- 1549
															enterDemoEntry(example) -- 1550
														end -- 1549
														return NextColumn() -- 1551
													end) -- 1548
													opened = true -- 1552
													::_continue_0:: -- 1546
												end -- 1545
											end) -- 1543
										end) -- 1542
										game.exampleOpen = opened -- 1553
									end -- 1534
								end -- 1530
								if #tests > 0 then -- 1554
									local showTest = false -- 1555
									for _index_1 = 1, #tests do -- 1556
										local _des_0 = tests[_index_1] -- 1556
										local entryName = _des_0.entryName -- 1556
										if match(entryName) then -- 1557
											showTest = true -- 1557
											break -- 1557
										end -- 1557
									end -- 1556
									if showTest then -- 1558
										showSep = true -- 1559
										Columns(1, false) -- 1560
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1561
										SameLine() -- 1562
										local opened -- 1563
										if (filterText ~= nil) then -- 1563
											opened = showTest -- 1563
										else -- 1563
											opened = false -- 1563
										end -- 1563
										if game.testOpen == nil then -- 1564
											game.testOpen = opened -- 1564
										end -- 1564
										SetNextItemOpen(game.testOpen) -- 1565
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1566
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1567
												Columns(maxColumns, false) -- 1568
												for _index_1 = 1, #tests do -- 1569
													local test = tests[_index_1] -- 1569
													local entryName = test.entryName -- 1570
													if not match(entryName) then -- 1571
														goto _continue_0 -- 1571
													end -- 1571
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1572
														if Button(entryName, Vec2(-1, 40)) then -- 1573
															enterDemoEntry(test) -- 1574
														end -- 1573
														return NextColumn() -- 1575
													end) -- 1572
													opened = true -- 1576
													::_continue_0:: -- 1570
												end -- 1569
											end) -- 1567
										end) -- 1566
										game.testOpen = opened -- 1577
									end -- 1558
								end -- 1554
								if showSep then -- 1578
									Columns(1, false) -- 1579
									thinSep() -- 1580
									Columns(columns, false) -- 1581
								end -- 1578
							end -- 1481
						end -- 1477
						if #doraTools > 0 then -- 1582
							local showTool = false -- 1583
							for _index_0 = 1, #doraTools do -- 1584
								local _des_0 = doraTools[_index_0] -- 1584
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1584
								local displayName -- 1585
								if repo then -- 1585
									if zh then -- 1586
										displayName = repo.title.zh -- 1586
									else -- 1586
										displayName = repo.title.en -- 1586
									end -- 1586
								end -- 1585
								if displayName == nil then -- 1587
									displayName = entryName -- 1587
								end -- 1587
								if match(displayName) then -- 1588
									showTool = true -- 1588
									break -- 1588
								end -- 1588
							end -- 1584
							if not showTool then -- 1589
								goto endEntry -- 1589
							end -- 1589
							Columns(1, false) -- 1590
							TextColored(themeColor, "Dora SSR:") -- 1591
							SameLine() -- 1592
							Text(zh and "开发支持" or "Development Support") -- 1593
							Separator() -- 1594
							if #doraTools > 0 then -- 1595
								local opened -- 1596
								if (filterText ~= nil) then -- 1596
									opened = showTool -- 1596
								else -- 1596
									opened = false -- 1596
								end -- 1596
								SetNextItemOpen(toolOpen) -- 1597
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1598
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1599
										Columns(maxColumns, false) -- 1600
										for _index_0 = 1, #doraTools do -- 1601
											local tool = doraTools[_index_0] -- 1601
											local entryName, repo = tool.entryName, tool.repo -- 1602
											local displayName -- 1603
											if repo then -- 1603
												if zh then -- 1604
													displayName = repo.title.zh -- 1604
												else -- 1604
													displayName = repo.title.en -- 1604
												end -- 1604
											end -- 1603
											if displayName == nil then -- 1605
												displayName = entryName -- 1605
											end -- 1605
											if not match(displayName) then -- 1606
												goto _continue_0 -- 1606
											end -- 1606
											if Button(displayName, Vec2(-1, 40)) then -- 1607
												enterDemoEntry(tool) -- 1608
											end -- 1607
											NextColumn() -- 1609
											::_continue_0:: -- 1602
										end -- 1601
										Columns(1, false) -- 1610
										opened = true -- 1611
									end) -- 1599
								end) -- 1598
								toolOpen = opened -- 1612
							end -- 1595
						end -- 1582
						::endEntry:: -- 1613
						if not anyEntryMatched then -- 1614
							SetNextWindowBgAlpha(0) -- 1615
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1616
							Begin("Entries Not Found", displayWindowFlags, function() -- 1617
								Separator() -- 1618
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1619
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1620
								return Separator() -- 1621
							end) -- 1617
						end -- 1614
						Columns(1, false) -- 1622
						Dummy(Vec2(100, 80)) -- 1623
						return ScrollWhenDraggingOnVoid() -- 1624
					end) -- 1473
				end) -- 1472
			end) -- 1471
		end) -- 1470
	end -- 1469
end) -- 1392
local sceneModuleCache = moduleCache -- 1629
moduleCache = { } -- 1630
webStatus = oldRequire("Script.Dev.WebServer") -- 1631
moduleCache = sceneModuleCache -- 1632
startMobileUI = function() -- 1634
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1635
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1636
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1637
	local getMobileFeedResources -- 1638
	do -- 1638
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1638
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1638
	end -- 1638
	local loadCachedCatalog -- 1639
	do -- 1639
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1639
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1639
	end -- 1639
	local getResourceInstallPath -- 1640
	do -- 1640
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1640
		getResourceInstallPath = _obj_0.getResourceInstallPath -- 1640
	end -- 1640
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1641
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1642
	local feedOptions = nil -- 1643
	local mobileLaunchErrors = { } -- 1644
	local withMobileLaunchErrors -- 1645
	withMobileLaunchErrors = function(items) -- 1645
		for _index_0 = 1, #items do -- 1646
			local item = items[_index_0] -- 1646
			item.launchError = mobileLaunchErrors[item.id] -- 1647
		end -- 1646
		return items -- 1648
	end -- 1645
	local rememberedMobileFeedData = config.mobileFeedCurrentCard
	local function loadRememberedMobileFeedState()
		local raw = rememberedMobileFeedData
		if type(raw) ~= "string" or raw == "" then
			return nil
		end
		local ok, saved = pcall(json.decode, raw)
		if not ok or type(saved) ~= "table" then
			return nil
		end
		if type(saved.id) == "string" and (saved.kind == "local" or saved.kind == "discover") then
			local state = {activeTab = saved.kind}
			state[saved.kind] = saved
			return state
		end
		local state = {activeTab = (saved.activeTab == "local" or saved.activeTab == "discover") and saved.activeTab or "local"}
		for _, kind in ipairs({"local", "discover"}) do
			local entry = saved[kind]
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then
				state[kind] = entry
			end
		end
		return state
	end
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or {activeTab = "local"}
	local function rememberMobileFeedEntry(entry)
		rememberedMobileFeedState.activeTab = entry.kind
		rememberedMobileFeedState[entry.kind] = {id = entry.id, kind = entry.kind, workDir = entry.workDir, fileName = entry.fileName}
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState)
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData)
		DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", {rememberedMobileFeedData})
	end
	local restartMobileFeed -- 1649
	restartMobileFeed = function(entry) -- 1649
		if feedHost then -- 1650
			feedHost:removeFromParent(true) -- 1650
		end -- 1650
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1651
		local initialEntries = {}
		initialEntries["local"] = rememberedMobileFeedState["local"]
		initialEntries["discover"] = rememberedMobileFeedState["discover"]
		feedOptions.initialEntries = initialEntries
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1652
	end -- 1649
	local startMobilePlay -- 1653
	startMobilePlay = function(entry) -- 1653
		if HttpServer.wsConnectionCount > 0 then -- 1654
			return -- 1654
		end -- 1654
		local originFeed = feedHost
		if remixHost then -- 1655
			remixHost:removeFromParent(true) -- 1655
		end -- 1655
		remixHost = nil -- 1656
		mobileLaunchErrors[entry.id] = nil -- 1658
		entry.launchError = nil -- 1659
		local playActive = true
		local restoreMobileFeed -- 1660
		restoreMobileFeed = function() -- 1660
			if not playActive then
				return
			end
			playActive = false
			allClear() -- 1661
			isInEntry = true -- 1662
			currentEntry = nil -- 1663
			return restartMobileFeed(entry) -- 1664
		end -- 1660
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1666
			onExit = function() -- 1666
				return restoreMobileFeed() -- 1666
			end, -- 1666
			onRuntimeError = function() -- 1667
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1668
				return restoreMobileFeed() -- 1669
			end -- 1667
		})) -- 1665
		return thread(function() -- 1671
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1672
			if not playActive then
				return
			end
			if success then -- 1673
				if originFeed and originFeed.parent then
					originFeed.visible = false
				end
				return -- 1673
			end -- 1673
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1674
			return restoreMobileFeed() -- 1675
		end) -- 1671
	end -- 1653
	feedOptions = { -- 1677
		onSwitchMode = function() -- 1677
			if HttpServer.wsConnectionCount == 0 then -- 1677
				pendingUIMode = false -- 1677
			end -- 1677
		end, -- 1677
		onCurrentEntryChanged = rememberMobileFeedEntry,
		getLocalEntries = function() -- 1678
			local dirtyProjectPath = feedOptions.dirtyProjectPath -- 1679
			feedOptions.dirtyProjectPath = nil -- 1680
			return withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1681
		end, -- 1678
		syncDiscover = function(onProgress, onDone) -- 1682
			return mobileCatalog.syncMobileCatalog(onProgress, onDone) -- 1682
		end, -- 1682
		getDiscoverEntries = function() -- 1683
			local cached = loadCachedCatalog() -- 1684
			if not (cached.success and cached.snapshot) then -- 1685
				return { } -- 1685
			end -- 1685
			local items = { } -- 1686
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1687
			for _index_0 = 1, #_list_0 do -- 1687
				local resource = _list_0[_index_0] -- 1687
				local installed = lifecycle.isMobileResourceReady(resource) -- 1688
				local installPath = getResourceInstallPath(resource.id) -- 1689
				items[#items + 1] = { -- 1691
					id = resource.id, -- 1691
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1692
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1693
					kind = "discover", -- 1694
					bannerFile = resource.bannerPath, -- 1695
					workDir = installed and installPath or nil, -- 1696
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1697
					installed = installed, -- 1698
					resource = resource, -- 1699
					catalogCommit = cached.snapshot.commit, -- 1700
					launchError = mobileLaunchErrors[resource.id] -- 1701
				} -- 1690
			end -- 1687
			return items -- 1703
		end, -- 1683
		prepare = function(entry, repairIncomplete, onProgress, onDone) -- 1704
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1705
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1706
			end), repairIncomplete) -- 1705
		end, -- 1704
		createProject = function(name) -- 1708
			local result = projectCreate.createMobileTypeScriptProject(name) -- 1709
			if not result.success then -- 1710
				return result -- 1710
			end -- 1710
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1711
			for _index_0 = 1, #_list_0 do -- 1711
				local entry = _list_0[_index_0] -- 1711
				if entry.workDir == result.workDir then -- 1712
					return { -- 1713
						success = true, -- 1713
						entry = entry -- 1713
					} -- 1713
				end -- 1712
			end -- 1711
			return { -- 1714
				success = false, -- 1714
				error = "created-project-not-found" -- 1714
			} -- 1714
		end, -- 1708
		onPlay = function(entry) -- 1715
			return startMobilePlay(entry) -- 1715
		end, -- 1715
		onRemix = function(entry) -- 1716
			if HttpServer.wsConnectionCount > 0 then -- 1717
				return -- 1717
			end -- 1717
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1718
			local originFeed = feedHost -- 1719
			feedHost.visible = false -- 1720
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1722
				entry = entry, -- 1722
				onProjectChanged = function(current) -- 1723
					feedOptions.dirtyProjectPath = current.workDir -- 1723
				end, -- 1723
				onBack = function() -- 1724
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1725
						originFeed:emit("RestoreFeedEntry", entry) -- 1726
						originFeed.visible = true -- 1727
					end -- 1725
				end, -- 1724
				onPlay = function(current) -- 1728
					return startMobilePlay(current) -- 1728
				end -- 1728
			})) -- 1721
		end -- 1716
	} -- 1676
	return restartMobileFeed() -- 1731
end -- 1634
if mobileMode then -- 1733
	applyUIMode(true) -- 1733
end -- 1733
return _module_0 -- 1
