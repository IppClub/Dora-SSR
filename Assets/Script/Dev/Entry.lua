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
local Controller <const> = Controller -- 11
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
local rawset <const> = rawset -- 11
local getmetatable <const> = getmetatable -- 11
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
if App.platform == "Emscripten" then -- 50
	Dora.globals.webProjects = oldRequire("Script.Dev.WebProjects") -- 50
end -- 50
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "virtualGamepadEnabled", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected", "webIDETourCompleted", "showPreview", "mobileFeed", "mobileFeedCurrentCard", "mobileRemixLLMConfigId", "mobileLargeText", "authRequired") -- 52
config:load() -- 87
if not (config.writablePath ~= nil) then -- 89
	config.writablePath = Content.appPath -- 90
end -- 89
if not (config.webIDEConnected ~= nil) then -- 92
	config.webIDEConnected = false -- 93
end -- 92
if (config.fpsLimited ~= nil) then -- 95
	App.fpsLimited = config.fpsLimited -- 96
else -- 98
	config.fpsLimited = App.fpsLimited -- 98
end -- 95
if (config.targetFPS ~= nil) then -- 100
	App.targetFPS = math.floor(config.targetFPS) -- 101
else -- 103
	config.targetFPS = App.targetFPS -- 103
end -- 100
if (config.vsync ~= nil) then -- 105
	View.vsync = config.vsync -- 106
else -- 108
	config.vsync = View.vsync -- 108
end -- 105
if (config.fixedFPS ~= nil) then -- 110
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 111
else -- 113
	config.fixedFPS = Director.scheduler.fixedFPS -- 113
end -- 110
if not (config.showPreview ~= nil) then -- 115
	config.showPreview = true -- 116
end -- 115
if not (config.mobileFeed ~= nil) then -- 118
	local _val_0 = App.platform -- 119
	config.mobileFeed = "Android" == _val_0 or "iOS" == _val_0 -- 119
end -- 118
if not (config.webIDETourCompleted ~= nil) then -- 121
	config.webIDETourCompleted = false -- 122
end -- 121
if not (config.authRequired ~= nil) then -- 124
	local _val_0 = App.platform -- 125
	config.authRequired = not ("Android" == _val_0 or "iOS" == _val_0) -- 125
end -- 124
HttpServer.authRequired = config.authRequired -- 126
local showEntry = true -- 128
isDesktop = false -- 130
if (function() -- 131
	local _val_0 = App.platform -- 131
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 131
end)() then -- 131
	isDesktop = true -- 132
	if config.fullScreen then -- 133
		App.fullScreen = true -- 134
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 135
		local size = Size(config.winWidth, config.winHeight) -- 136
		if App.winSize ~= size then -- 137
			App.winSize = size -- 138
		end -- 137
		local winX, winY -- 139
		do -- 139
			local _obj_0 = App.winPosition -- 139
			winX, winY = _obj_0.x, _obj_0.y -- 139
		end -- 139
		if (config.winX ~= nil) then -- 140
			winX = config.winX -- 141
		else -- 143
			config.winX = -1 -- 143
		end -- 140
		if (config.winY ~= nil) then -- 144
			winY = config.winY -- 145
		else -- 147
			config.winY = -1 -- 147
		end -- 144
		App.winPosition = Vec2(winX, winY) -- 148
	end -- 133
	if (config.alwaysOnTop ~= nil) then -- 149
		App.alwaysOnTop = config.alwaysOnTop -- 150
	else -- 152
		config.alwaysOnTop = false -- 152
	end -- 149
	if (config.virtualGamepadEnabled ~= nil) then -- 153
		Controller.virtualGamepadEnabled = config.virtualGamepadEnabled -- 154
	else -- 156
		config.virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 156
	end -- 153
end -- 131
if (config.themeColor ~= nil) then -- 158
	App.themeColor = Color(config.themeColor) -- 159
else -- 161
	config.themeColor = App.themeColor:toARGB() -- 161
end -- 158
if not (config.locale ~= nil) then -- 163
	config.locale = App.locale -- 164
end -- 163
local showStats = false -- 166
if (config.showStats ~= nil) then -- 167
	showStats = config.showStats -- 168
else -- 170
	config.showStats = showStats -- 170
end -- 167
local showConsole = false -- 172
if (config.showConsole ~= nil) then -- 173
	showConsole = config.showConsole -- 174
else -- 176
	config.showConsole = showConsole -- 176
end -- 173
local showFooter = true -- 178
if (config.showFooter ~= nil) then -- 179
	showFooter = config.showFooter -- 180
else -- 182
	config.showFooter = showFooter -- 182
end -- 179
local setFooterVisible -- 184
setFooterVisible = function(visible) -- 184
	if visible == nil then -- 184
		visible = true -- 184
	end -- 184
	showFooter = visible -- 185
	config.showFooter = showFooter -- 186
end -- 184
_module_0["setFooterVisible"] = setFooterVisible -- 184
local filterBuf = Buffer(20) -- 188
if (config.filter ~= nil) then -- 189
	filterBuf.text = config.filter -- 190
else -- 192
	config.filter = "" -- 192
end -- 189
local engineDev = false -- 194
if (config.engineDev ~= nil) then -- 195
	engineDev = config.engineDev -- 196
else -- 198
	config.engineDev = engineDev -- 198
end -- 195
if (config.webProfiler ~= nil) then -- 200
	Director.profilerSending = config.webProfiler -- 201
else -- 203
	config.webProfiler = true -- 203
	Director.profilerSending = true -- 204
end -- 200
if not (config.drawerWidth ~= nil) then -- 206
	config.drawerWidth = 200 -- 207
end -- 206
_module_0.getConfig = function() -- 209
	return config -- 209
end -- 209
_module_0.getEngineDev = function() -- 210
	if not App.debugging then -- 211
		return false -- 211
	end -- 211
	return config.engineDev -- 212
end -- 210
local _anon_func_0 = function() -- 217
	local _val_0 = App.platform -- 217
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 217
end -- 217
_module_0.connectWebIDE = function() -- 214
	if not config.webIDEConnected then -- 215
		config.webIDEConnected = true -- 216
		if _anon_func_0() then -- 217
			local ratio = App.winSize.width / App.visualSize.width -- 218
			App.winSize = Size(640 * ratio, 480 * ratio) -- 219
		end -- 217
	end -- 215
end -- 214
local updateCheck -- 221
updateCheck = function() -- 221
	return thread(function() -- 221
		local res = HttpClient:getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest") -- 222
		if res then -- 222
			local data = json.decode(res) -- 223
			if data then -- 223
				local major, minor, patch = App.version:match("(%d+)%.(%d+)%.(%d+)%.(%d+)") -- 224
				local a, b, c = tonumber(major), tonumber(minor), tonumber(patch) -- 225
				local sa, sb, sc = data.tag_name:match("v(%d+)%.(%d+)%.(%d+)") -- 226
				local na, nb, nc = tonumber(sa), tonumber(sb), tonumber(sc) -- 227
				if na < a then -- 228
					goto not_new_version -- 229
				end -- 228
				if na == a then -- 230
					if nb < b then -- 231
						goto not_new_version -- 232
					end -- 231
					if nb == b then -- 233
						if nc < c then -- 234
							goto not_new_version -- 235
						end -- 234
						if nc == c then -- 236
							goto not_new_version -- 237
						end -- 236
					end -- 233
				end -- 230
				config.updateNotification = true -- 238
				::not_new_version:: -- 239
				config.lastUpdateCheck = os.time() -- 240
			end -- 223
		end -- 222
	end) -- 221
end -- 221
if (config.lastUpdateCheck ~= nil) then -- 242
	local diffSeconds = os.difftime(os.time(), config.lastUpdateCheck) -- 243
	if diffSeconds >= 7 * 24 * 60 * 60 then -- 244
		updateCheck() -- 245
	end -- 244
else -- 247
	updateCheck() -- 247
end -- 242
local Set, Struct, LintYueGlobals, GSplit -- 249
do -- 249
	local _obj_0 = require("Utils") -- 249
	Set, Struct, LintYueGlobals, GSplit = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals, _obj_0.GSplit -- 249
end -- 249
local yueext = yue.options.extension -- 250
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 252
local building = false -- 254
local getAllFiles -- 256
getAllFiles = function(path, exts, recursive) -- 256
	if recursive == nil then -- 256
		recursive = true -- 256
	end -- 256
	local filters = Set(exts) -- 257
	local files -- 258
	if recursive then -- 258
		files = Content:getAllFiles(path) -- 259
	else -- 261
		files = Content:getFiles(path) -- 261
	end -- 258
	local _accum_0 = { } -- 262
	local _len_0 = 1 -- 262
	for _index_0 = 1, #files do -- 262
		local file = files[_index_0] -- 262
		if not filters[Path:getExt(file)] then -- 263
			goto _continue_0 -- 263
		end -- 263
		_accum_0[_len_0] = file -- 264
		_len_0 = _len_0 + 1 -- 263
		::_continue_0:: -- 263
	end -- 262
	return _accum_0 -- 262
end -- 256
_module_0["getAllFiles"] = getAllFiles -- 256
local getFileEntries -- 266
getFileEntries = function(path, recursive, excludeFiles) -- 266
	if recursive == nil then -- 266
		recursive = true -- 266
	end -- 266
	if excludeFiles == nil then -- 266
		excludeFiles = nil -- 266
	end -- 266
	local entries = { } -- 267
	local excludes -- 268
	if excludeFiles then -- 268
		excludes = Set(excludeFiles) -- 269
	end -- 268
	local _list_0 = getAllFiles(path, { -- 270
		"lua", -- 270
		"xml", -- 270
		yueext, -- 270
		"tl" -- 270
	}, recursive) -- 270
	for _index_0 = 1, #_list_0 do -- 270
		local file = _list_0[_index_0] -- 270
		local entryName = Path:getName(file) -- 271
		if excludes and excludes[entryName] then -- 272
			goto _continue_0 -- 273
		end -- 272
		local fileName = Path:replaceExt(file, "") -- 274
		fileName = Path(path, fileName) -- 275
		local entryAdded -- 276
		for _index_1 = 1, #entries do -- 276
			local _des_0 = entries[_index_1] -- 276
			local ename, efile = _des_0.entryName, _des_0.fileName -- 276
			if entryName == ename and efile == fileName then -- 277
				entryAdded = true -- 277
				break -- 277
			end -- 277
		end -- 276
		if entryAdded then -- 278
			goto _continue_0 -- 278
		end -- 278
		local entry = { -- 279
			entryName = entryName, -- 279
			fileName = fileName -- 279
		} -- 279
		entries[#entries + 1] = entry -- 280
		::_continue_0:: -- 271
	end -- 270
	table.sort(entries, function(a, b) -- 281
		return a.entryName < b.entryName -- 281
	end) -- 281
	return entries -- 282
end -- 266
local allEntries = { -- 284
	dirty = { }, -- 284
	hasDirty = false, -- 284
	runId = 0 -- 284
} -- 284
allEntries.scanDir = function(path, dir, noPreview) -- 286
	if noPreview == nil then -- 286
		noPreview = false -- 286
	end -- 286
	local entries = { } -- 287
	if not dir:match("^%.") then -- 288
		local _list_0 = getAllFiles(Path(path, dir), { -- 289
			"lua", -- 289
			"xml", -- 289
			yueext, -- 289
			"tl", -- 289
			"wasm" -- 289
		}) -- 289
		for _index_0 = 1, #_list_0 do -- 289
			local file = _list_0[_index_0] -- 289
			if "init" == Path:getName(file):lower() then -- 290
				local fileName = Path:replaceExt(file, "") -- 291
				fileName = Path(path, dir, fileName) -- 292
				local projectPath = Path:getPath(fileName) -- 293
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 294
				local repo = nil -- 295
				if Content:exist(repoFile) then -- 296
					local str = Content:load(repoFile) -- 297
					if str then -- 297
						repo = json.decode(str) -- 298
					end -- 297
				end -- 296
				local entryName = Path:getName(projectPath) -- 299
				local entryAdded -- 300
				for _index_1 = 1, #entries do -- 300
					local _des_0 = entries[_index_1] -- 300
					local ename, efile = _des_0.entryName, _des_0.fileName -- 300
					if entryName == ename and efile == fileName then -- 301
						entryAdded = true -- 301
						break -- 301
					end -- 301
				end -- 300
				if entryAdded then -- 302
					goto _continue_0 -- 302
				end -- 302
				local examples = { } -- 303
				local tests = { } -- 304
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 305
				if Content:exist(examplePath) then -- 306
					local _list_1 = getFileEntries(examplePath) -- 307
					for _index_1 = 1, #_list_1 do -- 307
						local _des_0 = _list_1[_index_1] -- 307
						local name, ePath = _des_0.entryName, _des_0.fileName -- 307
						local entry = { -- 309
							entryName = name, -- 309
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 310
							workDir = projectPath -- 311
						} -- 308
						examples[#examples + 1] = entry -- 313
					end -- 307
				end -- 306
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 314
				if Content:exist(testPath) then -- 315
					local _list_1 = getFileEntries(testPath) -- 316
					for _index_1 = 1, #_list_1 do -- 316
						local _des_0 = _list_1[_index_1] -- 316
						local name, tPath = _des_0.entryName, _des_0.fileName -- 316
						local entry = { -- 318
							entryName = name, -- 318
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 319
							workDir = projectPath -- 320
						} -- 317
						tests[#tests + 1] = entry -- 322
					end -- 316
				end -- 315
				local entry = { -- 323
					entryName = entryName, -- 323
					fileName = fileName, -- 323
					projectPath = projectPath, -- 323
					examples = examples, -- 323
					tests = tests, -- 323
					repo = repo -- 323
				} -- 323
				local bannerFile -- 324
				do -- 324
					local _val_0 -- 324
					repeat -- 324
						if noPreview then -- 325
							_val_0 = nil -- 325
							break -- 325
						end -- 325
						if not config.showPreview then -- 326
							_val_0 = nil -- 326
							break -- 326
						end -- 326
						local f = Path(projectPath, ".dora", "banner.jpg") -- 327
						if Content:exist(f) then -- 328
							_val_0 = f -- 328
							break -- 328
						end -- 328
						f = Path(projectPath, ".dora", "banner.png") -- 329
						if Content:exist(f) then -- 330
							_val_0 = f -- 330
							break -- 330
						end -- 330
						f = Path(projectPath, "Image", "banner.jpg") -- 331
						if Content:exist(f) then -- 332
							_val_0 = f -- 332
							break -- 332
						end -- 332
						f = Path(projectPath, "Image", "banner.png") -- 333
						if Content:exist(f) then -- 334
							_val_0 = f -- 334
							break -- 334
						end -- 334
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 335
						if Content:exist(f) then -- 336
							_val_0 = f -- 336
							break -- 336
						end -- 336
					until true -- 324
					bannerFile = _val_0 -- 324
				end -- 324
				if bannerFile then -- 338
					entry.bannerFile = bannerFile -- 341
					thread(function() -- 342
						if Cache:loadAsync(bannerFile) then -- 343
							local bannerTex = Texture2D(bannerFile) -- 344
							if bannerTex then -- 344
								entry.bannerTex = bannerTex -- 345
							end -- 344
						end -- 343
					end) -- 342
				end -- 338
				entries[#entries + 1] = entry -- 346
			end -- 290
			::_continue_0:: -- 290
		end -- 289
	end -- 288
	return entries -- 347
end -- 286
local getProjectEntries -- 349
getProjectEntries = function(path, noPreview) -- 349
	if noPreview == nil then -- 349
		noPreview = false -- 349
	end -- 349
	local entries = { } -- 350
	local _list_0 = Content:getDirs(path) -- 351
	for _index_0 = 1, #_list_0 do -- 351
		local dir = _list_0[_index_0] -- 351
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 352
		for _index_1 = 1, #_list_1 do -- 352
			local entry = _list_1[_index_1] -- 352
			entries[#entries + 1] = entry -- 353
		end -- 352
	end -- 351
	table.sort(entries, function(a, b) -- 354
		return a.entryName < b.entryName -- 354
	end) -- 354
	return entries -- 355
end -- 349
_module_0["getProjectEntries"] = getProjectEntries -- 349
local gamesInDev -- 357
local doraTools -- 358
local isToolEntry -- 360
isToolEntry = function(entry) -- 360
	do -- 361
		local _type_0 = type(entry) -- 361
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 361
		if _tab_0 then -- 361
			local categories -- 361
			do -- 361
				local _obj_0 = entry.repo -- 361
				local _type_1 = type(_obj_0) -- 361
				if "table" == _type_1 or "userdata" == _type_1 then -- 361
					categories = _obj_0.categories -- 361
				end -- 361
			end -- 361
			if categories ~= nil then -- 361
				for _index_0 = 1, #categories do -- 362
					local category = categories[_index_0] -- 362
					if "string" == type(category) and category:lower() == "tool" then -- 363
						return true -- 364
					end -- 363
				end -- 362
			end -- 361
		end -- 361
	end -- 361
	return false -- 360
end -- 360
local getEntryTitle -- 366
getEntryTitle = function(entry) -- 366
	local title -- 367
	do -- 367
		local repo = entry.repo -- 367
		if repo then -- 367
			if repo.title and "table" == type(repo.title) then -- 368
				if useChinese then -- 369
					title = repo.title.zh -- 369
				else -- 369
					title = repo.title.en -- 369
				end -- 369
			end -- 368
		end -- 367
	end -- 367
	if title ~= nil then -- 370
		return title -- 370
	else -- 370
		return entry.entryName -- 370
	end -- 370
end -- 366
allEntries.rebuildEntries = function() -- 372
	gamesInDev = { } -- 373
	do -- 374
		local _accum_0 = { } -- 374
		local _len_0 = 1 -- 374
		local _list_0 = allEntries.builtinTools -- 374
		for _index_0 = 1, #_list_0 do -- 374
			local tool = _list_0[_index_0] -- 374
			_accum_0[_len_0] = tool -- 374
			_len_0 = _len_0 + 1 -- 374
		end -- 374
		doraTools = _accum_0 -- 374
	end -- 374
	local _list_0 = allEntries.projectEntries -- 375
	for _index_0 = 1, #_list_0 do -- 375
		local entry = _list_0[_index_0] -- 375
		if isToolEntry(entry) then -- 376
			entry.kind = "tool" -- 377
			doraTools[#doraTools + 1] = entry -- 378
		else -- 380
			entry.kind = "game" -- 380
			gamesInDev[#gamesInDev + 1] = entry -- 381
		end -- 376
	end -- 375
	for i = #allEntries, 1, -1 do -- 382
		allEntries[i] = nil -- 383
	end -- 382
	for _index_0 = 1, #gamesInDev do -- 384
		local game = gamesInDev[_index_0] -- 384
		allEntries[#allEntries + 1] = game -- 385
		local examples, tests = game.examples, game.tests -- 386
		for _index_1 = 1, #examples do -- 387
			local example = examples[_index_1] -- 387
			allEntries[#allEntries + 1] = example -- 388
		end -- 387
		for _index_1 = 1, #tests do -- 389
			local test = tests[_index_1] -- 389
			allEntries[#allEntries + 1] = test -- 390
		end -- 389
	end -- 384
end -- 372
local updateEntries -- 392
updateEntries = function() -- 392
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 393
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 394
	local _list_0 = allEntries.builtinTools -- 395
	for _index_0 = 1, #_list_0 do -- 395
		local tool = _list_0[_index_0] -- 395
		tool.kind = "tool" -- 396
		tool.builtin = true -- 397
	end -- 395
	return allEntries.rebuildEntries() -- 398
end -- 392
allEntries.refreshDirtyProjects = function() -- 400
	if not allEntries.hasDirty then -- 401
		return -- 401
	end -- 401
	local dirty = allEntries.dirty -- 402
	allEntries.dirty = { } -- 403
	allEntries.hasDirty = false -- 404
	for projectPath in pairs(dirty) do -- 405
		do -- 406
			local _accum_0 = { } -- 406
			local _len_0 = 1 -- 406
			local _list_0 = allEntries.projectEntries -- 406
			for _index_0 = 1, #_list_0 do -- 406
				local entry = _list_0[_index_0] -- 406
				if entry.projectPath ~= projectPath then -- 406
					_accum_0[_len_0] = entry -- 406
					_len_0 = _len_0 + 1 -- 406
				end -- 406
			end -- 406
			allEntries.projectEntries = _accum_0 -- 406
		end -- 406
		local parentPath = Path:getPath(projectPath) -- 407
		local dir = Path:getFilename(projectPath) -- 408
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 409
		for _index_0 = 1, #_list_0 do -- 409
			local entry = _list_0[_index_0] -- 409
			if entry.projectPath == projectPath then -- 410
				do -- 411
					local _obj_0 = allEntries.projectEntries -- 411
					_obj_0[#_obj_0 + 1] = entry -- 411
				end -- 411
				break -- 412
			end -- 410
		end -- 409
	end -- 405
	table.sort(allEntries.projectEntries, function(a, b) -- 413
		return a.entryName < b.entryName -- 413
	end) -- 413
	return allEntries.rebuildEntries() -- 414
end -- 400
updateEntries() -- 416
local getLaunchEntries -- 418
getLaunchEntries = function(refresh) -- 418
	if refresh == nil then -- 418
		refresh = false -- 418
	end -- 418
	if refresh then -- 419
		updateEntries() -- 419
	end -- 419
	local toInfo -- 420
	toInfo = function(entry, kind) -- 420
		local file = entry.fileName -- 421
		local asProj = not entry.builtin -- 422
		return { -- 424
			name = getEntryTitle(entry), -- 424
			file = file, -- 425
			kind = kind, -- 426
			asProj = asProj -- 427
		} -- 423
	end -- 420
	local games -- 429
	do -- 429
		local _accum_0 = { } -- 429
		local _len_0 = 1 -- 429
		for _index_0 = 1, #gamesInDev do -- 429
			local game = gamesInDev[_index_0] -- 429
			_accum_0[_len_0] = toInfo(game, "game") -- 429
			_len_0 = _len_0 + 1 -- 429
		end -- 429
		games = _accum_0 -- 429
	end -- 429
	local tools -- 430
	do -- 430
		local _accum_0 = { } -- 430
		local _len_0 = 1 -- 430
		for _index_0 = 1, #doraTools do -- 430
			local tool = doraTools[_index_0] -- 430
			_accum_0[_len_0] = toInfo(tool, "tool") -- 430
			_len_0 = _len_0 + 1 -- 430
		end -- 430
		tools = _accum_0 -- 430
	end -- 430
	return { -- 431
		games = games, -- 431
		tools = tools -- 431
	} -- 431
end -- 418
_module_0["getLaunchEntries"] = getLaunchEntries -- 418
local _anon_func_1 = function(entry, useChinese) -- 448
	local _obj_0 = entry.repo -- 448
	if _obj_0 ~= nil then -- 448
		local _obj_1 = _obj_0.description -- 448
		if _obj_1 ~= nil then -- 448
			return _obj_1[useChinese and "zh" or "en"] -- 448
		end -- 448
		return nil -- 448
	end -- 448
	return nil -- 448
end -- 448
local getMobileFeedEntries -- 433
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 433
	if refresh == nil then -- 433
		refresh = false -- 433
	end -- 433
	if dirtyProjectPath == nil then -- 433
		dirtyProjectPath = nil -- 433
	end -- 433
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 434
		allEntries.dirty[dirtyProjectPath] = true -- 435
		allEntries.hasDirty = true -- 436
	end -- 434
	if refresh then -- 437
		allEntries.dirty = { } -- 438
		allEntries.hasDirty = false -- 439
		updateEntries() -- 440
	else -- 442
		allEntries.refreshDirtyProjects() -- 442
	end -- 437
	local items = { } -- 443
	for _index_0 = 1, #gamesInDev do -- 444
		local entry = gamesInDev[_index_0] -- 444
		items[#items + 1] = { -- 446
			id = entry.entryName, -- 446
			title = getEntryTitle(entry), -- 447
			description = _anon_func_1(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 448
			fileName = entry.fileName, -- 449
			workDir = Path:getPath(entry.fileName), -- 450
			bannerFile = entry.bannerFile, -- 451
			kind = "local" -- 452
		} -- 445
	end -- 444
	return items -- 454
end -- 433
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 433
local doCompile -- 456
doCompile = function(minify) -- 456
	if building then -- 457
		return -- 457
	end -- 457
	building = true -- 458
	local startTime = App.runningTime -- 459
	local luaFiles = { } -- 460
	local yueFiles = { } -- 461
	local xmlFiles = { } -- 462
	local tlFiles = { } -- 463
	local writablePath = Content.writablePath -- 464
	local buildPaths = { -- 466
		{ -- 467
			Content.assetPath, -- 467
			Path(writablePath, ".build"), -- 468
			"" -- 469
		} -- 466
	} -- 465
	for _index_0 = 1, #gamesInDev do -- 472
		local _des_0 = gamesInDev[_index_0] -- 472
		local fileName = _des_0.fileName -- 472
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 473
		buildPaths[#buildPaths + 1] = { -- 475
			Path(writablePath, gamePath), -- 475
			Path(writablePath, ".build", gamePath), -- 476
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 477
			gamePath -- 478
		} -- 474
	end -- 472
	for _index_0 = 1, #buildPaths do -- 479
		local _des_0 = buildPaths[_index_0] -- 479
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 479
		if not Content:exist(inputPath) then -- 480
			goto _continue_0 -- 480
		end -- 480
		local _list_0 = getAllFiles(inputPath, { -- 482
			"lua" -- 482
		}) -- 482
		for _index_1 = 1, #_list_0 do -- 482
			local file = _list_0[_index_1] -- 482
			luaFiles[#luaFiles + 1] = { -- 484
				file, -- 484
				Path(inputPath, file), -- 485
				Path(outputPath, file), -- 486
				gamePath -- 487
			} -- 483
		end -- 482
		local _list_1 = getAllFiles(inputPath, { -- 489
			yueext -- 489
		}) -- 489
		for _index_1 = 1, #_list_1 do -- 489
			local file = _list_1[_index_1] -- 489
			yueFiles[#yueFiles + 1] = { -- 491
				file, -- 491
				Path(inputPath, file), -- 492
				Path(outputPath, Path:replaceExt(file, "lua")), -- 493
				searchPath, -- 494
				gamePath -- 495
			} -- 490
		end -- 489
		local _list_2 = getAllFiles(inputPath, { -- 497
			"xml" -- 497
		}) -- 497
		for _index_1 = 1, #_list_2 do -- 497
			local file = _list_2[_index_1] -- 497
			xmlFiles[#xmlFiles + 1] = { -- 499
				file, -- 499
				Path(inputPath, file), -- 500
				Path(outputPath, Path:replaceExt(file, "lua")), -- 501
				gamePath -- 502
			} -- 498
		end -- 497
		local _list_3 = getAllFiles(inputPath, { -- 504
			"tl" -- 504
		}) -- 504
		for _index_1 = 1, #_list_3 do -- 504
			local file = _list_3[_index_1] -- 504
			if not file:match(".*%.d%.tl$") then -- 505
				tlFiles[#tlFiles + 1] = { -- 507
					file, -- 507
					Path(inputPath, file), -- 508
					Path(outputPath, Path:replaceExt(file, "lua")), -- 509
					searchPath, -- 510
					gamePath -- 511
				} -- 506
			end -- 505
		end -- 504
		::_continue_0:: -- 480
	end -- 479
	local paths -- 513
	do -- 513
		local _tbl_0 = { } -- 513
		local _list_0 = { -- 514
			luaFiles, -- 514
			yueFiles, -- 514
			xmlFiles, -- 514
			tlFiles -- 514
		} -- 514
		for _index_0 = 1, #_list_0 do -- 514
			local files = _list_0[_index_0] -- 514
			for _index_1 = 1, #files do -- 515
				local file = files[_index_1] -- 515
				_tbl_0[Path:getPath(file[3])] = true -- 513
			end -- 513
		end -- 513
		paths = _tbl_0 -- 513
	end -- 513
	for path in pairs(paths) do -- 517
		Content:mkdir(path) -- 517
	end -- 517
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 519
	local fileCount = 0 -- 520
	local errors = { } -- 521
	for _index_0 = 1, #yueFiles do -- 522
		local _des_0 = yueFiles[_index_0] -- 522
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 522
		local filename -- 523
		if gamePath then -- 523
			filename = Path(gamePath, file) -- 523
		else -- 523
			filename = file -- 523
		end -- 523
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 524
			if not codes then -- 525
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 526
				return -- 527
			end -- 525
			local success, result = LintYueGlobals(codes, globals) -- 528
			local yueCodes -- 529
			if not success then -- 530
				yueCodes = Content:load(input) -- 531
				if yueCodes then -- 531
					local CheckTIC80Code -- 532
					do -- 532
						local _obj_0 = require("Utils") -- 532
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 532
					end -- 532
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 533
					if isTIC80 then -- 534
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 535
					end -- 534
				end -- 531
			end -- 530
			if success then -- 536
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 537
			else -- 539
				if yueCodes then -- 539
					local globalErrors = { } -- 540
					for _index_1 = 1, #result do -- 541
						local _des_1 = result[_index_1] -- 541
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 541
						local countLine = 1 -- 542
						local code = "" -- 543
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 544
							if countLine == line then -- 545
								code = lineCode -- 546
								break -- 547
							end -- 545
							countLine = countLine + 1 -- 548
						end -- 544
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 549
					end -- 541
					if #globalErrors > 0 then -- 550
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 550
					end -- 550
				else -- 552
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 552
				end -- 539
				if #errors == 0 then -- 553
					return codes -- 553
				end -- 553
			end -- 536
		end, function(success) -- 524
			if success then -- 554
				print("Yue compiled: " .. tostring(filename)) -- 554
			end -- 554
			fileCount = fileCount + 1 -- 555
		end) -- 524
	end -- 522
	thread(function() -- 557
		for _index_0 = 1, #xmlFiles do -- 558
			local _des_0 = xmlFiles[_index_0] -- 558
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 558
			local filename -- 559
			if gamePath then -- 559
				filename = Path(gamePath, file) -- 559
			else -- 559
				filename = file -- 559
			end -- 559
			local sourceCodes = Content:loadAsync(input) -- 560
			local codes, err = xml.tolua(sourceCodes) -- 561
			if not codes then -- 562
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 563
			else -- 565
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 565
				print("Xml compiled: " .. tostring(filename)) -- 566
			end -- 562
			fileCount = fileCount + 1 -- 567
		end -- 558
	end) -- 557
	thread(function() -- 569
		for _index_0 = 1, #tlFiles do -- 570
			local _des_0 = tlFiles[_index_0] -- 570
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 570
			local filename -- 571
			if gamePath then -- 571
				filename = Path(gamePath, file) -- 571
			else -- 571
				filename = file -- 571
			end -- 571
			local sourceCodes = Content:loadAsync(input) -- 572
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 573
			if not codes then -- 574
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 575
			else -- 577
				Content:saveAsync(output, codes) -- 577
				print("Teal compiled: " .. tostring(filename)) -- 578
			end -- 574
			fileCount = fileCount + 1 -- 579
		end -- 570
	end) -- 569
	return thread(function() -- 581
		wait(function() -- 582
			return fileCount == totalFiles -- 582
		end) -- 582
		if minify then -- 583
			local _list_0 = { -- 584
				yueFiles, -- 584
				xmlFiles, -- 584
				tlFiles -- 584
			} -- 584
			for _index_0 = 1, #_list_0 do -- 584
				local files = _list_0[_index_0] -- 584
				for _index_1 = 1, #files do -- 584
					local file = files[_index_1] -- 584
					local output = Path:replaceExt(file[3], "lua") -- 585
					luaFiles[#luaFiles + 1] = { -- 587
						Path:replaceExt(file[1], "lua"), -- 587
						output, -- 588
						output -- 589
					} -- 586
				end -- 584
			end -- 584
			local FormatMini -- 591
			do -- 591
				local _obj_0 = require("luaminify") -- 591
				FormatMini = _obj_0.FormatMini -- 591
			end -- 591
			for _index_0 = 1, #luaFiles do -- 592
				local _des_0 = luaFiles[_index_0] -- 592
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 592
				if Content:exist(input) then -- 593
					local sourceCodes = Content:loadAsync(input) -- 594
					local res, err = FormatMini(sourceCodes) -- 595
					if res then -- 596
						Content:saveAsync(output, res) -- 597
						print("Minify: " .. tostring(file)) -- 598
					else -- 600
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 600
					end -- 596
				else -- 602
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 602
				end -- 593
			end -- 592
			package.loaded["luaminify.FormatMini"] = nil -- 603
			package.loaded["luaminify.ParseLua"] = nil -- 604
			package.loaded["luaminify.Scope"] = nil -- 605
			package.loaded["luaminify.Util"] = nil -- 606
		end -- 583
		local errorMessage = table.concat(errors, "\n") -- 607
		if errorMessage ~= "" then -- 608
			print(errorMessage) -- 608
		end -- 608
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 609
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 610
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 611
		Content:clearPathCache() -- 612
		teal.clear() -- 613
		yue.clear() -- 614
		building = false -- 615
	end) -- 581
end -- 456
local doClean -- 617
doClean = function() -- 617
	if building then -- 618
		return -- 618
	end -- 618
	local writablePath = Content.writablePath -- 619
	local targetDir = Path(writablePath, ".build") -- 620
	Content:clearPathCache() -- 621
	if Content:remove(targetDir) then -- 622
		return print("Cleaned: " .. tostring(targetDir)) -- 623
	end -- 622
end -- 617
local screenScale = 2.0 -- 625
local scaleContent = false -- 626
local isInEntry = true -- 627
local currentEntry = nil -- 628
local footerWindow = nil -- 630
local entryWindow = nil -- 631
local testingThread = nil -- 632
local mobileMode = config.mobileFeed -- 633
local pendingUIMode = nil -- 634
local feedHost = nil -- 635
local remixHost = nil -- 636
local startMobileUI = nil -- 637
local webControlled = false -- 638
local mobileHosts = { } -- 639
local suspendedMobileHosts = { } -- 640
local trackMobileHost -- 642
trackMobileHost = function(host) -- 642
	do -- 643
		local _accum_0 = { } -- 643
		local _len_0 = 1 -- 643
		for _index_0 = 1, #mobileHosts do -- 643
			local item = mobileHosts[_index_0] -- 643
			if item.parent then -- 643
				_accum_0[_len_0] = item -- 643
				_len_0 = _len_0 + 1 -- 643
			end -- 643
		end -- 643
		mobileHosts = _accum_0 -- 643
	end -- 643
	mobileHosts[#mobileHosts + 1] = host -- 644
	return host -- 645
end -- 642
local clearMobileUI -- 647
clearMobileUI = function() -- 647
	for _index_0 = 1, #mobileHosts do -- 648
		local host = mobileHosts[_index_0] -- 648
		if host.parent then -- 649
			host:removeFromParent(true) -- 649
		end -- 649
	end -- 648
	mobileHosts = { } -- 650
	suspendedMobileHosts = { } -- 651
	feedHost = nil -- 652
	remixHost = nil -- 653
end -- 647
local syncWebIDEControl -- 655
syncWebIDEControl = function() -- 655
	local connected = HttpServer.wsConnectionCount > 0 -- 656
	if connected then -- 657
		pendingUIMode = nil -- 658
		for _index_0 = 1, #mobileHosts do -- 659
			local host = mobileHosts[_index_0] -- 659
			if not host.parent then -- 660
				goto _continue_0 -- 660
			end -- 660
			if not (suspendedMobileHosts[host] ~= nil) then -- 661
				suspendedMobileHosts[host] = host.visible -- 662
				host:emit("SuspendLocalUI") -- 663
			end -- 661
			host.visible = false -- 664
			::_continue_0:: -- 660
		end -- 659
	elseif webControlled then -- 665
		for host, visible in pairs(suspendedMobileHosts) do -- 666
			if host.parent then -- 667
				host.visible = visible -- 668
				host:emit("ResumeLocalUI") -- 669
			end -- 667
		end -- 666
		suspendedMobileHosts = { } -- 670
	end -- 657
	webControlled = connected -- 671
	return connected -- 672
end -- 655
local getUIMode -- 674
getUIMode = function() -- 674
	return mobileMode and "mobile" or "traditional" -- 674
end -- 674
_module_0["getUIMode"] = getUIMode -- 674
local setUIMode -- 675
setUIMode = function(mode) -- 675
	if not (("mobile" == mode or "traditional" == mode)) then -- 676
		return false -- 676
	end -- 676
	if HttpServer.wsConnectionCount > 0 then -- 677
		return false -- 677
	end -- 677
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 678
		return false -- 678
	end -- 678
	local wantsMobile = mode == "mobile" -- 679
	if wantsMobile == mobileMode then -- 680
		return true -- 680
	end -- 680
	if mobileMode then -- 681
		if not (feedHost and feedHost.visible) then -- 682
			return false -- 682
		end -- 682
		feedHost:emit("SwitchUIMode") -- 684
		return pendingUIMode == false -- 685
	end -- 681
	pendingUIMode = true -- 686
	return true -- 687
end -- 675
_module_0["setUIMode"] = setUIMode -- 675
local applyUIMode -- 689
applyUIMode = function(enabled) -- 689
	if HttpServer.wsConnectionCount > 0 then -- 691
		return false -- 691
	end -- 691
	if enabled then -- 692
		local ok, err = pcall(startMobileUI) -- 693
		if not ok then -- 694
			if feedHost then -- 695
				feedHost:removeFromParent(true) -- 695
			end -- 695
			feedHost = nil -- 696
			mobileMode = false -- 697
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 698
			return false -- 699
		end -- 694
	else -- 701
		clearMobileUI() -- 701
		updateEntries() -- 702
	end -- 692
	mobileMode = enabled -- 703
	config.mobileFeed = enabled -- 704
	return true -- 705
end -- 689
local setupEventHandlers = nil -- 707
local allClear -- 709
allClear = function() -- 709
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 711
		clearMobileUI() -- 711
	end -- 711
	local systemNodes = { } -- 714
	local preserveSystemNode -- 715
	preserveSystemNode = function(node) -- 715
		if systemNodes[node] then -- 716
			return -- 716
		end -- 716
		systemNodes[node] = true -- 717
		do -- 718
			local clip = tolua.cast(node, "ClipNode") -- 718
			if clip then -- 718
				if clip.stencil then -- 719
					preserveSystemNode(clip.stencil) -- 719
				end -- 719
			end -- 718
		end -- 718
		return node:eachChild(function(child) -- 720
			preserveSystemNode(child) -- 721
			return false -- 722
		end) -- 720
	end -- 715
	for _index_0 = 1, #Routine do -- 723
		local routine = Routine[_index_0] -- 723
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 725
			goto _continue_0 -- 726
		else -- 728
			Routine:remove(routine) -- 728
		end -- 724
		::_continue_0:: -- 724
	end -- 723
	for _index_0 = 1, #moduleCache do -- 729
		local module = moduleCache[_index_0] -- 729
		package.loaded[module] = nil -- 730
	end -- 729
	moduleCache = { } -- 731
	Director:cleanup() -- 732
	Entity:clear() -- 733
	Platformer.Data:clear() -- 734
	Platformer.UnitAction:clear() -- 735
	Audio:stopAll(0.2) -- 736
	Struct:clear() -- 737
	View.nearPlaneDistance = 0.1 -- 740
	View.farPlaneDistance = 10000 -- 741
	View.fieldOfView = 45 -- 742
	View.postEffect = nil -- 743
	View.scale = scaleContent and screenScale or 1 -- 744
	Director.clearColor = Color(0xff1a1a1a) -- 745
	teal.clear() -- 746
	yue.clear() -- 747
	preserveSystemNode(Director.systemUI) -- 750
	for _, item in pairs(ubox()) do -- 751
		local node = tolua.cast(item, "Node") -- 752
		if node then -- 752
			if not systemNodes[node] then -- 753
				node:cleanup() -- 753
			end -- 753
		end -- 752
	end -- 751
	collectgarbage() -- 754
	collectgarbage() -- 755
	Wasm:clear() -- 756
	thread(function() -- 757
		sleep() -- 758
		return Cache:removeUnused() -- 759
	end) -- 757
	setupEventHandlers() -- 760
	Content.searchPaths = searchPaths -- 761
	App.idled = true -- 762
end -- 709
_module_0["allClear"] = allClear -- 709
local clearTempFiles -- 764
clearTempFiles = function() -- 764
	local writablePath = Content.writablePath -- 765
	if Content:exist(Path(writablePath, ".upload")) then -- 766
		Content:remove(Path(writablePath, ".upload")) -- 766
	end -- 766
	if Content:exist(Path(writablePath, ".download")) then -- 767
		return Content:remove(Path(writablePath, ".download")) -- 767
	end -- 767
end -- 764
local waitForWebStart = true -- 769
thread(function() -- 770
	sleep(2) -- 771
	waitForWebStart = false -- 772
end) -- 770
local reloadDevEntry -- 774
reloadDevEntry = function() -- 774
	return thread(function() -- 774
		waitForWebStart = true -- 775
		doClean() -- 776
		allClear() -- 777
		_G.require = oldRequire -- 778
		Dora.require = oldRequire -- 779
		package.loaded["Script.Dev.Entry"] = nil -- 780
		package.loaded["Script.Dev.WebServer"] = nil -- 781
		return Director.systemScheduler:schedule(function() -- 782
			Routine:clear() -- 783
			oldRequire("Script.Dev.Entry") -- 784
			return true -- 785
		end) -- 782
	end) -- 774
end -- 774
local setWorkspace -- 787
setWorkspace = function(path) -- 787
	clearTempFiles() -- 788
	Content.writablePath = path -- 789
	config.writablePath = Content.writablePath -- 790
	return thread(function() -- 791
		sleep() -- 792
		return reloadDevEntry() -- 793
	end) -- 791
end -- 787
_module_0["setWorkspace"] = setWorkspace -- 787
local quit = false -- 795
local activeSearchId = 0 -- 797
local handleSearchFiles -- 799
handleSearchFiles = function(payload) -- 799
	if not payload then -- 800
		return -- 800
	end -- 800
	local id = payload.id -- 801
	if id == nil then -- 802
		return -- 802
	end -- 802
	activeSearchId = id -- 803
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 804
	if path == nil then -- 805
		path = "" -- 805
	end -- 805
	if exts == nil then -- 806
		exts = { } -- 806
	end -- 806
	if globs == nil then -- 807
		globs = { } -- 807
	end -- 807
	if extensionLevels == nil then -- 808
		extensionLevels = { } -- 808
	end -- 808
	if pattern == nil then -- 809
		pattern = "" -- 809
	end -- 809
	if pattern == "" then -- 811
		return -- 811
	end -- 811
	local useRegex = payload.useRegex == true -- 812
	local caseSensitive = payload.caseSensitive == true -- 813
	local includeContent = payload.includeContent ~= false -- 814
	local contentWindow = payload.contentWindow or 0 -- 815
	return Director.systemScheduler:schedule(once(function() -- 816
		local stopped = false -- 817
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 818
			if activeSearchId ~= id then -- 819
				stopped = true -- 820
				return true -- 821
			end -- 819
			emit("AppWS", "Send", json.encode({ -- 823
				name = "SearchFilesResult", -- 823
				id = id, -- 823
				result = result -- 823
			})) -- 822
			return false -- 825
		end) -- 818
		return emit("AppWS", "Send", json.encode({ -- 827
			name = "SearchFilesDone", -- 827
			id = id, -- 827
			stopped = stopped -- 827
		})) -- 826
	end)) -- 816
end -- 799
local stop -- 830
stop = function() -- 830
	if isInEntry then -- 831
		return false -- 831
	end -- 831
	allClear() -- 832
	isInEntry = true -- 833
	currentEntry = nil -- 834
	return true -- 835
end -- 830
_module_0["stop"] = stop -- 830
local getCurrentEntryStatus -- 837
getCurrentEntryStatus = function() -- 837
	local entry = currentEntry -- 838
	if not (entry and not isInEntry) then -- 839
		return { -- 839
			success = true, -- 839
			running = false, -- 839
			runId = allEntries.runId -- 839
		} -- 839
	end -- 839
	local status = { -- 841
		success = true, -- 841
		running = true, -- 842
		kind = entry.runKind or "file", -- 843
		runId = allEntries.runId, -- 844
		entryName = entry.entryName, -- 845
		fileName = entry.fileName -- 846
	} -- 840
	if entry.workDir then -- 847
		status.workDir = entry.workDir -- 847
	end -- 847
	if entry.projectRoot then -- 848
		status.projectRoot = entry.projectRoot -- 848
	end -- 848
	return status -- 849
end -- 837
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 837
local _anon_func_2 = function(_with_0) -- 868
	local _val_0 = App.platform -- 868
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 868
end -- 868
setupEventHandlers = function() -- 851
	local _with_0 = Director.postNode -- 852
	_with_0:onAppEvent(function(eventType) -- 853
		if "Quit" == eventType then -- 854
			quit = true -- 855
			allClear() -- 856
			return clearTempFiles() -- 857
		elseif "Shutdown" == eventType then -- 858
			return stop() -- 859
		end -- 853
	end) -- 853
	_with_0:onAppChange(function(settingName) -- 860
		if "Theme" == settingName then -- 861
			config.themeColor = App.themeColor:toARGB() -- 862
		elseif "Locale" == settingName then -- 863
			config.locale = App.locale -- 864
			updateLocale() -- 865
			return teal.clear(true) -- 866
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 867
			if _anon_func_2(_with_0) then -- 868
				if "FullScreen" == settingName then -- 870
					config.fullScreen = App.fullScreen -- 870
				elseif "Position" == settingName then -- 871
					local _obj_0 = App.winPosition -- 871
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 871
				elseif "Size" == settingName then -- 872
					local width, height -- 873
					do -- 873
						local _obj_0 = App.winSize -- 873
						width, height = _obj_0.width, _obj_0.height -- 873
					end -- 873
					config.winWidth = width -- 874
					config.winHeight = height -- 875
				end -- 869
			end -- 868
		end -- 860
	end) -- 860
	_with_0:onAppWS(function(event) -- 876
		if event.type == "Close" then -- 877
			if HttpServer.wsConnectionCount == 0 then -- 878
				updateEntries() -- 879
			end -- 878
			return -- 880
		end -- 877
		if not (event.type == "Receive") then -- 881
			return -- 881
		end -- 881
		local data = json.decode(event.msg) -- 882
		if not data then -- 883
			return -- 883
		end -- 883
		local _exp_0 = data.name -- 884
		if "SearchFiles" == _exp_0 then -- 885
			return handleSearchFiles(data) -- 886
		elseif "SearchFilesStop" == _exp_0 then -- 887
			if data.id == nil or data.id == activeSearchId then -- 888
				activeSearchId = 0 -- 889
			end -- 888
		end -- 884
	end) -- 876
	_with_0:slot("UpdateEntries", function() -- 890
		return updateEntries() -- 890
	end) -- 890
	return _with_0 -- 852
end -- 851
setupEventHandlers() -- 892
clearTempFiles() -- 893
local downloadFile -- 895
downloadFile = function(url, target) -- 895
	return Director.systemScheduler:schedule(once(function() -- 895
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 896
			if quit then -- 897
				return true -- 897
			end -- 897
			emit("AppWS", "Send", json.encode({ -- 899
				name = "Download", -- 899
				url = url, -- 899
				status = "downloading", -- 899
				progress = current / total -- 900
			})) -- 898
			return false -- 896
		end) -- 896
		return emit("AppWS", "Send", json.encode(success and { -- 903
			name = "Download", -- 903
			url = url, -- 903
			status = "completed", -- 903
			progress = 1.0 -- 904
		} or { -- 906
			name = "Download", -- 906
			url = url, -- 906
			status = "failed", -- 906
			progress = 0.0 -- 907
		})) -- 902
	end)) -- 895
end -- 895
_module_0["downloadFile"] = downloadFile -- 895
local _anon_func_3 = function(file, require, workDir) -- 919
	if workDir == nil then -- 919
		workDir = Path:getPath(file) -- 919
	end -- 919
	Content:insertSearchPath(1, workDir) -- 920
	local scriptPath = Path(workDir, "Script") -- 921
	if Content:exist(scriptPath) then -- 922
		Content:insertSearchPath(1, scriptPath) -- 923
	end -- 922
	local result = require(file) -- 924
	if "function" == type(result) then -- 925
		result() -- 925
	end -- 925
	return nil -- 926
end -- 919
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 955
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 955
	label.alignment = "Left" -- 956
	label.textWidth = width - fontSize -- 957
	label.text = err -- 958
	return label -- 955
end -- 955
local enterEntryAsync -- 910
enterEntryAsync = function(entry) -- 910
	allEntries.runId = allEntries.runId + 1 -- 911
	isInEntry = false -- 912
	App.idled = false -- 913
	emit(Profiler.EventName, "ClearLoader") -- 914
	currentEntry = entry -- 915
	local file, workDir = entry.fileName, entry.workDir -- 916
	sleep() -- 917
	return xpcall(_anon_func_3, function(msg) -- 926
		local err = debug.traceback(msg) -- 928
		Log("Error", err) -- 929
		allClear() -- 930
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 931
		local viewWidth, viewHeight -- 932
		do -- 932
			local _obj_0 = View.size -- 932
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 932
		end -- 932
		local width, height = viewWidth - 20, viewHeight - 20 -- 933
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 934
		Director.ui:addChild((function() -- 935
			local root = AlignNode() -- 935
			do -- 936
				local _obj_0 = App.bufferSize -- 936
				width, height = _obj_0.width, _obj_0.height -- 936
			end -- 936
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 937
			root:onAppChange(function(settingName) -- 938
				if settingName == "Size" then -- 938
					do -- 939
						local _obj_0 = App.bufferSize -- 939
						width, height = _obj_0.width, _obj_0.height -- 939
					end -- 939
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 940
				end -- 938
			end) -- 938
			root:addChild((function() -- 941
				local _with_0 = ScrollArea({ -- 942
					width = width, -- 942
					height = height, -- 943
					paddingX = 0, -- 944
					paddingY = 50, -- 945
					viewWidth = height, -- 946
					viewHeight = height -- 947
				}) -- 941
				root:onAlignLayout(function(w, h) -- 949
					_with_0.position = Vec2(w / 2, h / 2) -- 950
					w = w - 20 -- 951
					h = h - 20 -- 952
					_with_0.view.children.first.textWidth = w - fontSize -- 953
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 954
				end) -- 949
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 955
				return _with_0 -- 941
			end)()) -- 941
			return root -- 935
		end)()) -- 935
		return err -- 959
	end, file, require, workDir) -- 918
end -- 910
_module_0["enterEntryAsync"] = enterEntryAsync -- 910
local enterDemoEntry -- 961
enterDemoEntry = function(entry) -- 961
	return thread(function() -- 961
		return enterEntryAsync(entry) -- 961
	end) -- 961
end -- 961
local reloadCurrentEntry -- 963
reloadCurrentEntry = function() -- 963
	if currentEntry then -- 964
		allClear() -- 965
		return enterDemoEntry(currentEntry) -- 966
	end -- 964
end -- 963
Director.clearColor = Color(0xff1a1a1a) -- 968
local descColor = Color(0xffa1a1a1) -- 969
local extraOperations -- 971
do -- 971
	local isOSSLicenseExist = Content:exist("LICENSES") -- 972
	local ossLicenses = nil -- 973
	local ossLicenseOpen = false -- 974
	local failedSetFolder = false -- 975
	local statusFlags = { -- 976
		"NoResize", -- 976
		"NoMove", -- 976
		"NoCollapse", -- 976
		"AlwaysAutoResize", -- 976
		"NoSavedSettings" -- 976
	} -- 976
	extraOperations = function() -- 983
		local zh = useChinese -- 984
		if isDesktop then -- 985
			local alwaysOnTop = config.alwaysOnTop -- 986
			do -- 987
				local changed -- 987
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 987
				if changed then -- 987
					App.alwaysOnTop = alwaysOnTop -- 988
					config.alwaysOnTop = alwaysOnTop -- 989
				end -- 987
			end -- 987
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 990
			do -- 991
				local changed -- 991
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 991
				if changed then -- 991
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 992
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 993
				end -- 991
			end -- 991
			SameLine() -- 994
			TextColored(descColor, "(?)") -- 995
			if IsItemHovered() then -- 996
				BeginTooltip(function() -- 997
					return PushTextWrapPos(360, function() -- 998
						return Text(zh and [[键盘映射：
方向键 / WASD → 十字键
J / K / U / I → A / B / X / Y
Tab / Ctrl → Back
Q / E → LB / RB
Enter → Start

启用后，普通按键和文本输入事件都会被屏蔽；以上映射键仅作为虚拟手柄输入。]] or [[Keyboard mapping:
Arrow keys / WASD → D-pad
J / K / U / I → A / B / X / Y
Tab / Ctrl → Back
Q / E → LB / RB
Enter → Start

When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 999
					end) -- 998
				end) -- 997
			end -- 996
		end -- 985
		local showPreview, authRequired, webIDETourCompleted = config.showPreview, config.authRequired, config.webIDETourCompleted -- 1014
		do -- 1019
			local changed -- 1019
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1019
			if changed then -- 1019
				config.showPreview = showPreview -- 1020
				updateEntries() -- 1021
				if not showPreview then -- 1022
					thread(function() -- 1023
						collectgarbage() -- 1024
						return Cache:removeUnused("Texture") -- 1025
					end) -- 1023
				end -- 1022
			end -- 1019
		end -- 1019
		do -- 1026
			local changed -- 1026
			changed, authRequired = Checkbox(zh and "访问验证" or "Auth Required", authRequired) -- 1026
			if changed then -- 1026
				config.authRequired = authRequired -- 1027
				HttpServer.authRequired = authRequired -- 1028
			end -- 1026
		end -- 1026
		SameLine() -- 1029
		TextColored(descColor, "(?)") -- 1030
		if IsItemHovered() then -- 1031
			BeginTooltip(function() -- 1032
				return PushTextWrapPos(280, function() -- 1033
					return Text(zh and '请勿在不安全的网络中关闭该选项' or 'Do not turn off this option on an insecure network') -- 1034
				end) -- 1033
			end) -- 1032
		end -- 1031
		do -- 1035
			local themeColor = App.themeColor -- 1036
			local writablePath = config.writablePath -- 1037
			SeparatorText(zh and "工作目录" or "Workspace") -- 1038
			PushTextWrapPos(400, function() -- 1039
				return TextColored(themeColor, writablePath) -- 1040
			end) -- 1039
			if not isDesktop then -- 1041
				goto skipSetting -- 1041
			end -- 1041
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1042
			if Button(zh and "改变目录" or "Set Folder") then -- 1043
				App:openFileDialog(true, function(path) -- 1044
					if path == "" then -- 1045
						return -- 1045
					end -- 1045
					local relPath = Path:getRelative(Content.assetPath, path) -- 1046
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1047
						return setWorkspace(path) -- 1048
					else -- 1050
						failedSetFolder = true -- 1050
					end -- 1047
				end) -- 1044
			end -- 1043
			if failedSetFolder then -- 1051
				failedSetFolder = false -- 1052
				OpenPopup(popupName) -- 1053
			end -- 1051
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1054
			BeginPopupModal(popupName, statusFlags, function() -- 1055
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1056
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1057
					return CloseCurrentPopup() -- 1058
				end -- 1057
			end) -- 1055
			SameLine() -- 1059
			if Button(zh and "使用默认" or "Use Default") then -- 1060
				setWorkspace(Content.appPath) -- 1061
			end -- 1060
			Separator() -- 1062
			::skipSetting:: -- 1063
		end -- 1035
		if isOSSLicenseExist then -- 1064
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1065
				if not ossLicenses then -- 1066
					ossLicenses = { } -- 1067
					local licenseText = Content:load("LICENSES") -- 1068
					ossLicenseOpen = (licenseText ~= nil) -- 1069
					if ossLicenseOpen then -- 1069
						licenseText = licenseText:gsub("\r\n", "\n") -- 1070
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1071
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1072
							if name then -- 1072
								ossLicenses[#ossLicenses + 1] = { -- 1073
									name, -- 1073
									text -- 1073
								} -- 1073
							end -- 1072
						end -- 1071
					end -- 1069
				else -- 1075
					ossLicenseOpen = true -- 1075
				end -- 1066
			end -- 1065
			if ossLicenseOpen then -- 1076
				local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1077
				SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1078
				SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1079
				PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1080
					ossLicenseOpen = Begin(zh and '开源协议' or 'OSS Licenses', ossLicenseOpen, { -- 1083
						"NoSavedSettings" -- 1083
					}, function() -- 1084
						for _index_0 = 1, #ossLicenses do -- 1084
							local _des_0 = ossLicenses[_index_0] -- 1084
							local firstLine, text = _des_0[1], _des_0[2] -- 1084
							local name, license = firstLine:match("(.+): (.+)") -- 1085
							TextColored(themeColor, name) -- 1086
							SameLine() -- 1087
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1088
								return TextWrapped(text) -- 1088
							end) -- 1088
						end -- 1084
					end) -- 1080
				end) -- 1080
			end -- 1076
		end -- 1064
		if not App.debugging then -- 1090
			return -- 1090
		end -- 1090
		return TreeNode(zh and "开发操作" or "Development", function() -- 1091
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1092
				OpenPopup("build") -- 1092
			end -- 1092
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1093
				return BeginPopup("build", function() -- 1093
					if Selectable(zh and "编译" or "Compile") then -- 1094
						doCompile(false) -- 1094
					end -- 1094
					Separator() -- 1095
					if Selectable(zh and "压缩" or "Minify") then -- 1096
						doCompile(true) -- 1096
					end -- 1096
					Separator() -- 1097
					if Selectable(zh and "清理" or "Clean") then -- 1098
						return doClean() -- 1098
					end -- 1098
				end) -- 1093
			end) -- 1093
			if isInEntry then -- 1099
				if waitForWebStart then -- 1100
					BeginDisabled(function() -- 1101
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1101
					end) -- 1101
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1102
					reloadDevEntry() -- 1103
				end -- 1100
			end -- 1099
			do -- 1104
				local changed -- 1104
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1104
				if changed then -- 1104
					View.scale = scaleContent and screenScale or 1 -- 1105
				end -- 1104
			end -- 1104
			do -- 1106
				local changed -- 1106
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1106
				if changed then -- 1106
					config.engineDev = engineDev -- 1107
				end -- 1106
			end -- 1106
			do -- 1108
				local changed -- 1108
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1108
				if changed then -- 1108
					config.webIDETourCompleted = webIDETourCompleted -- 1109
				end -- 1108
			end -- 1108
			if testingThread then -- 1110
				return BeginDisabled(function() -- 1111
					return Button(zh and "开始自动测试" or "Test automatically") -- 1111
				end) -- 1111
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1112
				testingThread = thread(function() -- 1113
					local _ <close> = setmetatable({ }, { -- 1114
						__close = function() -- 1114
							allClear() -- 1115
							testingThread = nil -- 1116
							isInEntry = true -- 1117
							currentEntry = nil -- 1118
							return print("Testing done!") -- 1119
						end -- 1114
					}) -- 1114
					for _, entry in ipairs(allEntries) do -- 1120
						allClear() -- 1121
						print("Start " .. tostring(entry.entryName)) -- 1122
						enterDemoEntry(entry) -- 1123
						sleep(2) -- 1124
						print("Stop " .. tostring(entry.entryName)) -- 1125
					end -- 1120
				end) -- 1113
			end -- 1110
		end) -- 1091
	end -- 983
end -- 971
local icon = Path("Script", "Dev", "icon_s.png") -- 1127
local iconTex = nil -- 1128
thread(function() -- 1129
	if Cache:loadAsync(icon) then -- 1129
		iconTex = Texture2D(icon) -- 1129
	end -- 1129
end) -- 1129
local webStatus = nil -- 1131
local urlClicked = nil -- 1132
local authCode = string.format("%06d", math.random(0, 999999)) -- 1134
local authCodeTTL = 30.0 -- 1136
_module_0.getAuthCode = function() -- 1137
	return authCode -- 1137
end -- 1137
_module_0.invalidateAuthCode = function() -- 1138
	authCode = string.format("%06d", math.random(0, 999999)) -- 1139
	authCodeTTL = 30.0 -- 1140
end -- 1138
local AuthSession -- 1142
do -- 1142
	local pending = nil -- 1143
	local session = nil -- 1144
	AuthSession = { -- 1146
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1146
			pending = { -- 1148
				sessionId = sessionId, -- 1148
				confirmCode = confirmCode, -- 1149
				expiresAt = expiresAt, -- 1150
				ttl = ttl, -- 1151
				approved = false -- 1152
			} -- 1147
		end, -- 1146
		getPending = function() -- 1154
			return pending -- 1154
		end, -- 1154
		approvePending = function(sessionId) -- 1156
			if pending and pending.sessionId == sessionId then -- 1157
				pending.approved = true -- 1158
				return true -- 1159
			end -- 1157
			return false -- 1160
		end, -- 1156
		clearPending = function() -- 1162
			pending = nil -- 1162
		end, -- 1162
		setSession = function(sessionId, sessionSecret) -- 1164
			session = { -- 1166
				sessionId = sessionId, -- 1166
				sessionSecret = sessionSecret -- 1167
			} -- 1165
		end, -- 1164
		getSession = function() -- 1169
			return session -- 1169
		end -- 1169
	} -- 1145
end -- 1142
_module_0["AuthSession"] = AuthSession -- 1142
local transparant = Color(0x0) -- 1172
local windowFlags = { -- 1173
	"NoTitleBar", -- 1173
	"NoResize", -- 1173
	"NoMove", -- 1173
	"NoCollapse", -- 1173
	"NoSavedSettings", -- 1173
	"NoFocusOnAppearing", -- 1173
	"NoBringToFrontOnFocus" -- 1173
} -- 1173
local statusFlags = { -- 1182
	"NoTitleBar", -- 1182
	"NoResize", -- 1182
	"NoMove", -- 1182
	"NoCollapse", -- 1182
	"AlwaysAutoResize", -- 1182
	"NoSavedSettings" -- 1182
} -- 1182
local displayWindowFlags = { -- 1190
	"NoDecoration", -- 1190
	"NoSavedSettings", -- 1190
	"NoMove", -- 1190
	"NoScrollWithMouse", -- 1190
	"AlwaysAutoResize", -- 1190
	"NoFocusOnAppearing" -- 1190
} -- 1190
local gamepadInputWindowFlags = { -- 1198
	"NoDecoration", -- 1198
	"NoSavedSettings", -- 1198
	"NoMove", -- 1198
	"NoScrollbar", -- 1198
	"NoScrollWithMouse", -- 1198
	"NoFocusOnAppearing", -- 1198
	"NoBringToFrontOnFocus" -- 1198
} -- 1198
local initFooter = true -- 1207
local gamepadInputFocused = false -- 1208
local _anon_func_5 = function(allEntries, currentIndex) -- 1254
	if currentIndex > 1 then -- 1254
		return allEntries[currentIndex - 1] -- 1255
	else -- 1257
		return allEntries[#allEntries] -- 1257
	end -- 1254
end -- 1254
local _anon_func_6 = function(allEntries, currentIndex) -- 1261
	if currentIndex < #allEntries then -- 1261
		return allEntries[currentIndex + 1] -- 1262
	else -- 1264
		return allEntries[1] -- 1264
	end -- 1261
end -- 1261
footerWindow = threadLoop(function() -- 1209
	if mobileMode then -- 1210
		return -- 1210
	end -- 1210
	local zh = useChinese -- 1211
	authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1212
	if authCodeTTL <= 0 then -- 1213
		authCodeTTL = 30.0 -- 1214
		authCode = string.format("%06d", math.random(0, 999999)) -- 1215
	end -- 1213
	if HttpServer.wsConnectionCount > 0 then -- 1216
		return -- 1217
	end -- 1216
	if isInEntry and Keyboard:isKeyDown("Escape") then -- 1218
		if App.platform == "Emscripten" then -- 1219
			stop() -- 1221
		else -- 1223
			allClear() -- 1223
			App.devMode = false -- 1224
			App:shutdown() -- 1225
		end -- 1219
	end -- 1218
	do -- 1226
		local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1227
		if ctrl and Keyboard:isKeyDown("Q") then -- 1228
			stop() -- 1229
		end -- 1228
		if ctrl and Keyboard:isKeyDown("Z") then -- 1230
			reloadCurrentEntry() -- 1231
		end -- 1230
		if ctrl and Keyboard:isKeyDown(",") then -- 1232
			if showFooter then -- 1233
				showStats = not showStats -- 1233
			else -- 1233
				showStats = true -- 1233
			end -- 1233
			showFooter = true -- 1234
			config.showFooter = showFooter -- 1235
			config.showStats = showStats -- 1236
		end -- 1232
		if ctrl and Keyboard:isKeyDown(".") then -- 1237
			if showFooter then -- 1238
				showConsole = not showConsole -- 1238
			else -- 1238
				showConsole = true -- 1238
			end -- 1238
			showFooter = true -- 1239
			config.showFooter = showFooter -- 1240
			config.showConsole = showConsole -- 1241
		end -- 1237
		if ctrl and Keyboard:isKeyDown("/") then -- 1242
			showFooter = not showFooter -- 1243
			config.showFooter = showFooter -- 1244
		end -- 1242
		local left = ctrl and Keyboard:isKeyDown("Left") -- 1245
		local right = ctrl and Keyboard:isKeyDown("Right") -- 1246
		local currentIndex = nil -- 1247
		for i, entry in ipairs(allEntries) do -- 1248
			if currentEntry == entry then -- 1249
				currentIndex = i -- 1250
			end -- 1249
		end -- 1248
		if left then -- 1251
			allClear() -- 1252
			if currentIndex == nil then -- 1253
				currentIndex = #allEntries + 1 -- 1253
			end -- 1253
			enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1254
		end -- 1251
		if right then -- 1258
			allClear() -- 1259
			if currentIndex == nil then -- 1260
				currentIndex = 0 -- 1260
			end -- 1260
			enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1261
		end -- 1258
	end -- 1226
	if not showEntry then -- 1265
		return -- 1265
	end -- 1265
	if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1267
		reloadDevEntry() -- 1271
	end -- 1267
	if initFooter then -- 1272
		initFooter = false -- 1273
	end -- 1272
	local width, height -- 1275
	do -- 1275
		local _obj_0 = App.visualSize -- 1275
		width, height = _obj_0.width, _obj_0.height -- 1275
	end -- 1275
	if isInEntry then -- 1276
		gamepadInputFocused = false -- 1277
	else -- 1279
		SetNextWindowBgAlpha(0.0) -- 1279
		SetNextWindowSize(Vec2(1, 1), "Always") -- 1280
		SetNextWindowPos(Vec2.zero, "Always") -- 1281
		PushStyleVar("WindowPadding", Vec2.zero, function() -- 1282
			return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1283
				return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1284
					if not gamepadInputFocused then -- 1285
						SetWindowFocus("DoraGamepadInput") -- 1286
						gamepadInputFocused = true -- 1287
					end -- 1285
				end) -- 1284
			end) -- 1283
		end) -- 1282
	end -- 1276
	if isInEntry or showFooter then -- 1289
		SetNextWindowSize(Vec2(width, 50)) -- 1290
		SetNextWindowPos(Vec2(0, height - 50)) -- 1291
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1292
			return PushStyleVar("WindowRounding", 0, function() -- 1293
				return Begin("Footer", windowFlags, function() -- 1294
					Separator() -- 1295
					if iconTex then -- 1296
						if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1297
							showStats = not showStats -- 1298
							config.showStats = showStats -- 1299
						end -- 1297
						SameLine() -- 1300
						if Button(">_", Vec2(30, 30)) then -- 1301
							showConsole = not showConsole -- 1302
							config.showConsole = showConsole -- 1303
						end -- 1301
					end -- 1296
					if isInEntry and config.updateNotification then -- 1304
						SameLine() -- 1305
						if ImGui.Button(zh and "更新可用" or "Update") then -- 1306
							allClear() -- 1307
							config.updateNotification = false -- 1308
							enterDemoEntry({ -- 1310
								entryName = "SelfUpdater", -- 1310
								fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1311
							}) -- 1309
						end -- 1306
					end -- 1304
					if not isInEntry then -- 1312
						SameLine() -- 1313
						local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1314
						local currentIndex = nil -- 1315
						for i, entry in ipairs(allEntries) do -- 1316
							if currentEntry == entry then -- 1317
								currentIndex = i -- 1318
							end -- 1317
						end -- 1316
						if currentIndex then -- 1319
							if currentIndex > 1 then -- 1320
								SameLine() -- 1321
								if Button("<<", Vec2(30, 30)) then -- 1322
									allClear() -- 1323
									enterDemoEntry(allEntries[currentIndex - 1]) -- 1324
								end -- 1322
							end -- 1320
							if currentIndex < #allEntries then -- 1325
								SameLine() -- 1326
								if Button(">>", Vec2(30, 30)) then -- 1327
									allClear() -- 1328
									enterDemoEntry(allEntries[currentIndex + 1]) -- 1329
								end -- 1327
							end -- 1325
						end -- 1319
						SameLine() -- 1330
						if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1331
							reloadCurrentEntry() -- 1332
						end -- 1331
						if back then -- 1333
							allClear() -- 1334
							isInEntry = true -- 1335
							currentEntry = nil -- 1336
						end -- 1333
					end -- 1312
				end) -- 1294
			end) -- 1293
		end) -- 1292
	end -- 1289
	if isInEntry then -- 1338
		local showURL = true -- 1339
		local webIDEWidth -- 1340
		do -- 1340
			local base -- 1341
			if config.updateNotification then -- 1341
				base = 460 -- 1341
			else -- 1341
				base = 360 -- 1341
			end -- 1341
			local extra -- 1342
			if config.authRequired then -- 1342
				extra = 35 -- 1342
			else -- 1342
				extra = 0 -- 1342
			end -- 1342
			webIDEWidth = base + extra -- 1343
		end -- 1340
		if width < webIDEWidth then -- 1344
			showURL = false -- 1344
		end -- 1344
		SetNextWindowBgAlpha(0.0) -- 1345
		SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1346
		Begin("Web IDE", displayWindowFlags, function() -- 1347
			local pending = AuthSession.getPending() -- 1348
			local hovered = false -- 1349
			if not pending and showURL then -- 1350
				do -- 1351
					local url -- 1351
					if webStatus ~= nil then -- 1351
						url = webStatus.url -- 1351
					end -- 1351
					if url then -- 1351
						if isDesktop and not config.fullScreen then -- 1352
							if urlClicked then -- 1353
								BeginDisabled(function() -- 1354
									return Button(url) -- 1354
								end) -- 1354
							elseif Button(url) then -- 1355
								urlClicked = once(function() -- 1356
									return sleep(5) -- 1356
								end) -- 1356
								App:openURL("http://localhost:8866") -- 1357
							end -- 1353
						else -- 1359
							TextColored(descColor, url) -- 1359
						end -- 1352
					else -- 1361
						TextColored(descColor, zh and '不可用' or 'not available') -- 1361
					end -- 1351
				end -- 1351
				hovered = IsItemHovered() -- 1362
			else -- 1364
				TextColored(descColor, "(?)") -- 1364
				hovered = IsItemHovered() -- 1365
			end -- 1350
			SameLine() -- 1366
			local themeColor = App.themeColor -- 1367
			if pending then -- 1368
				if not pending.approved then -- 1369
					local remaining = math.max(0, pending.expiresAt - os.time()) -- 1370
					local ttl = pending.ttl or 1 -- 1371
					PushStyleColor("Text", themeColor, function() -- 1372
						ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1373
						hovered = hovered or IsItemHovered() -- 1374
					end) -- 1372
					SameLine() -- 1375
					if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1376
						AuthSession.approvePending(pending.sessionId) -- 1377
					end -- 1376
					if hovered then -- 1378
						return BeginTooltip(function() -- 1379
							return PushTextWrapPos(280, function() -- 1380
								return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1381
							end) -- 1380
						end) -- 1379
					end -- 1378
				end -- 1369
			else -- 1383
				if config.authRequired then -- 1383
					PushStyleColor("Text", themeColor, function() -- 1384
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1385
						hovered = hovered or IsItemHovered() -- 1386
					end) -- 1384
					if hovered then -- 1387
						return BeginTooltip(function() -- 1388
							return PushTextWrapPos(280, function() -- 1389
								local url -- 1390
								if webStatus ~= nil then -- 1390
									url = webStatus.url -- 1390
								end -- 1390
								if url then -- 1390
									local address -- 1391
									if showURL then -- 1391
										address = "Web IDE" -- 1391
									else -- 1391
										address = url -- 1391
									end -- 1391
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) .. " 并输入后面的 PIN 码进行使用 （PIN 仅用于一次认证）" or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network and enter the PIN below to start (PIN is one-time)") -- 1392
								else -- 1394
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1394
								end -- 1390
							end) -- 1389
						end) -- 1388
					end -- 1387
				else -- 1396
					if hovered then -- 1396
						return BeginTooltip(function() -- 1397
							return PushTextWrapPos(280, function() -- 1398
								local url -- 1399
								if webStatus ~= nil then -- 1399
									url = webStatus.url -- 1399
								end -- 1399
								if url then -- 1399
									local address -- 1400
									if showURL then -- 1400
										address = "Web IDE" -- 1400
									else -- 1400
										address = url -- 1400
									end -- 1400
									return Text(zh and "在本机或是本地局域网连接的其他设备上，使用浏览器访问 " .. tostring(address) or "Open " .. tostring(address) .. " in a browser on this machine or another device on the local network") -- 1401
								else -- 1403
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1403
								end -- 1399
							end) -- 1398
						end) -- 1397
					end -- 1396
				end -- 1383
			end -- 1368
		end) -- 1347
	end -- 1338
	if not isInEntry then -- 1405
		SetNextWindowSize(Vec2(50, 50)) -- 1406
		SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1407
		PushStyleColor("WindowBg", transparant, function() -- 1408
			return Begin("Show", displayWindowFlags, function() -- 1408
				if width >= 370 then -- 1409
					local changed -- 1410
					changed, showFooter = Checkbox("##dev", showFooter) -- 1410
					if changed then -- 1410
						config.showFooter = showFooter -- 1411
					end -- 1410
				end -- 1409
			end) -- 1408
		end) -- 1408
	end -- 1405
	if isInEntry or showFooter then -- 1413
		if showStats then -- 1414
			PushStyleVar("WindowRounding", 0, function() -- 1415
				SetNextWindowPos(Vec2(0, 0), "Always") -- 1416
				SetNextWindowSize(Vec2(0, height - 50)) -- 1417
				showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1418
				config.showStats = showStats -- 1419
			end) -- 1415
		end -- 1414
		if showConsole then -- 1420
			SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1421
			return PushStyleVar("WindowRounding", 6, function() -- 1422
				return ShowConsole() -- 1423
			end) -- 1422
		end -- 1420
	end -- 1413
end) -- 1209
local MaxWidth <const> = 960 -- 1425
local toolOpen = false -- 1427
local filterText = nil -- 1428
allEntries.anyEntryMatched = false -- 1429
allEntries.match = function(name) -- 1430
	local res = not filterText or name:lower():match(filterText) -- 1431
	if res then -- 1432
		allEntries.anyEntryMatched = true -- 1432
	end -- 1432
	return res -- 1433
end -- 1430
allEntries.thinSep = function() -- 1435
	return PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1435
		return SeparatorText("") -- 1435
	end) -- 1435
end -- 1435
entryWindow = threadLoop(function() -- 1437
	local connected = syncWebIDEControl() -- 1438
	if not connected and not mobileMode and isInEntry and not testingThread then -- 1440
		if not allEntries.pendingPackagePath then -- 1441
			local path = App:takeReceivedFile() -- 1442
			if path ~= "" then -- 1443
				allEntries.pendingPackagePath = path -- 1443
			end -- 1443
		end -- 1441
		if allEntries.pendingPackagePath then -- 1444
			pendingUIMode = true -- 1444
		end -- 1444
	end -- 1440
	if (pendingUIMode ~= nil) then -- 1446
		local nextMode = pendingUIMode -- 1447
		pendingUIMode = nil -- 1448
		applyUIMode(nextMode) -- 1449
	end -- 1446
	if mobileMode and not connected then -- 1450
		if isInEntry and not feedHost then -- 1451
			applyUIMode(true) -- 1451
		end -- 1451
		return -- 1452
	end -- 1450
	if App.fpsLimited ~= config.fpsLimited then -- 1453
		config.fpsLimited = App.fpsLimited -- 1454
	end -- 1453
	if App.targetFPS ~= config.targetFPS then -- 1455
		config.targetFPS = App.targetFPS -- 1456
	end -- 1455
	if View.vsync ~= config.vsync then -- 1457
		config.vsync = View.vsync -- 1458
	end -- 1457
	if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1459
		config.fixedFPS = Director.scheduler.fixedFPS -- 1460
	end -- 1459
	if Director.profilerSending ~= config.webProfiler then -- 1461
		config.webProfiler = Director.profilerSending -- 1462
	end -- 1461
	if urlClicked then -- 1463
		local _, result = coroutine.resume(urlClicked) -- 1464
		if result then -- 1465
			coroutine.close(urlClicked) -- 1466
			urlClicked = nil -- 1467
		end -- 1465
	end -- 1463
	if not isInEntry then -- 1468
		return -- 1468
	end -- 1468
	local zh = useChinese -- 1469
	local themeColor = App.themeColor -- 1470
	if connected then -- 1471
		local width, height -- 1472
		do -- 1472
			local _obj_0 = App.visualSize -- 1472
			width, height = _obj_0.width, _obj_0.height -- 1472
		end -- 1472
		SetNextWindowBgAlpha(0.5) -- 1473
		SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1474
		Begin("Web IDE Connected", displayWindowFlags, function() -- 1475
			Separator() -- 1476
			TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1477
			if iconTex then -- 1478
				Image(icon, Vec2(24, 24)) -- 1479
				SameLine() -- 1480
			end -- 1478
			local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1481
			TextColored(descColor, slogon) -- 1482
			return Separator() -- 1483
		end) -- 1475
		return -- 1484
	end -- 1471
	if not showEntry then -- 1485
		return -- 1485
	end -- 1485
	local fullWidth, height -- 1487
	do -- 1487
		local _obj_0 = App.visualSize -- 1487
		fullWidth, height = _obj_0.width, _obj_0.height -- 1487
	end -- 1487
	local width = math.min(MaxWidth, fullWidth) -- 1488
	local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1489
	local maxColumns = math.max(math.floor(width / 200), 1) -- 1490
	SetNextWindowPos(Vec2.zero) -- 1491
	SetNextWindowBgAlpha(0) -- 1492
	SetNextWindowSize(Vec2(fullWidth, 51)) -- 1493
	do -- 1494
		PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1495
			return Begin("Dora Dev", windowFlags, function() -- 1496
				Dummy(Vec2(fullWidth - 20, 0)) -- 1497
				TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1498
				SameLine() -- 1499
				if Button(zh and "Go 模式" or "Go Mode") then -- 1500
					setUIMode("mobile") -- 1501
				end -- 1500
				if fullWidth >= 540 then -- 1502
					SameLine() -- 1503
					Dummy(Vec2(fullWidth - 540, 0)) -- 1504
					SameLine() -- 1505
					SetNextItemWidth(zh and -95 or -140) -- 1506
					if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1507
						"AutoSelectAll" -- 1507
					}) then -- 1507
						config.filter = filterBuf.text -- 1508
					end -- 1507
					SameLine() -- 1509
					if Button(zh and '下载' or 'Download') then -- 1510
						allClear() -- 1511
						enterDemoEntry({ -- 1513
							entryName = "ResourceDownloader", -- 1513
							fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1514
						}) -- 1512
					end -- 1510
				end -- 1502
				return Separator() -- 1515
			end) -- 1496
		end) -- 1495
	end -- 1494
	allEntries.anyEntryMatched = false -- 1517
	SetNextWindowPos(Vec2(0, 50)) -- 1518
	SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1519
	do -- 1520
		return PushStyleColor("WindowBg", transparant, function() -- 1521
			return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1522
				return PushStyleVar("Alpha", 1, function() -- 1523
					return Begin("Content", windowFlags, function() -- 1524
						local DemoViewWidth <const> = 220 -- 1525
						filterText = filterBuf.text:match("[^%%%.%[]+") -- 1526
						if filterText then -- 1527
							filterText = filterText:lower() -- 1527
						end -- 1527
						if App.platform == "Emscripten" then -- 1528
							Dora.globals.webProjects.draw(zh, themeColor) -- 1529
							allEntries.anyEntryMatched = true -- 1530
						end -- 1528
						if #gamesInDev > 0 then -- 1531
							local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1532
							Columns(columns, false) -- 1533
							local realViewWidth = GetColumnWidth() - 50 -- 1534
							for _index_0 = 1, #gamesInDev do -- 1535
								local game = gamesInDev[_index_0] -- 1535
								local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1536
								local displayName -- 1545
								if repo then -- 1545
									if zh then -- 1546
										displayName = repo.title.zh -- 1546
									else -- 1546
										displayName = repo.title.en -- 1546
									end -- 1546
								end -- 1545
								if displayName == nil then -- 1547
									displayName = gameName -- 1547
								end -- 1547
								if allEntries.match(displayName) then -- 1548
									TextColored(themeColor, zh and "项目：" or "Project:") -- 1549
									SameLine() -- 1550
									TextWrapped(displayName) -- 1551
									if columns > 1 then -- 1552
										if bannerFile and bannerTex then -- 1553
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1554
											local displayWidth <const> = realViewWidth -- 1555
											texHeight = displayWidth * texHeight / texWidth -- 1556
											texWidth = displayWidth -- 1557
											Dummy(Vec2.zero) -- 1558
											SameLine() -- 1559
											Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1560
										end -- 1553
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1561
											enterDemoEntry(game) -- 1562
										end -- 1561
									else -- 1564
										if bannerFile and bannerTex then -- 1564
											local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1565
											local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1566
											local sizing = 0.8 -- 1567
											texHeight = displayWidth * sizing * texHeight / texWidth -- 1568
											texWidth = displayWidth * sizing -- 1569
											if texWidth > 500 then -- 1570
												sizing = 0.6 -- 1571
												texHeight = displayWidth * sizing * texHeight / texWidth -- 1572
												texWidth = displayWidth * sizing -- 1573
											end -- 1570
											local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1574
											Dummy(Vec2(padding, 0)) -- 1575
											SameLine() -- 1576
											Image(bannerFile, Vec2(texWidth, texHeight)) -- 1577
										end -- 1564
										if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1578
											enterDemoEntry(game) -- 1579
										end -- 1578
									end -- 1552
									if #tests == 0 and #examples == 0 then -- 1580
										allEntries.thinSep() -- 1581
									end -- 1580
									NextColumn() -- 1582
								end -- 1548
								local showSep = false -- 1583
								if #examples > 0 then -- 1584
									local showExample = false -- 1585
									for _index_1 = 1, #examples do -- 1586
										local _des_0 = examples[_index_1] -- 1586
										local entryName = _des_0.entryName -- 1586
										if allEntries.match(entryName) then -- 1587
											showExample = true -- 1587
											break -- 1587
										end -- 1587
									end -- 1586
									if showExample then -- 1588
										showSep = true -- 1589
										Columns(1, false) -- 1590
										TextColored(themeColor, zh and "示例：" or "Example:") -- 1591
										SameLine() -- 1592
										local opened -- 1593
										if (filterText ~= nil) then -- 1593
											opened = showExample -- 1593
										else -- 1593
											opened = false -- 1593
										end -- 1593
										if game.exampleOpen == nil then -- 1594
											game.exampleOpen = opened -- 1594
										end -- 1594
										SetNextItemOpen(game.exampleOpen) -- 1595
										TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1596
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1597
												Columns(maxColumns, false) -- 1598
												for _index_1 = 1, #examples do -- 1599
													local example = examples[_index_1] -- 1599
													local entryName = example.entryName -- 1600
													if not allEntries.match(entryName) then -- 1601
														goto _continue_0 -- 1601
													end -- 1601
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1602
														if Button(entryName, Vec2(-1, 40)) then -- 1603
															enterDemoEntry(example) -- 1604
														end -- 1603
														return NextColumn() -- 1605
													end) -- 1602
													opened = true -- 1606
													::_continue_0:: -- 1600
												end -- 1599
											end) -- 1597
										end) -- 1596
										game.exampleOpen = opened -- 1607
									end -- 1588
								end -- 1584
								if #tests > 0 then -- 1608
									local showTest = false -- 1609
									for _index_1 = 1, #tests do -- 1610
										local _des_0 = tests[_index_1] -- 1610
										local entryName = _des_0.entryName -- 1610
										if allEntries.match(entryName) then -- 1611
											showTest = true -- 1611
											break -- 1611
										end -- 1611
									end -- 1610
									if showTest then -- 1612
										showSep = true -- 1613
										Columns(1, false) -- 1614
										TextColored(themeColor, zh and "测试：" or "Test:") -- 1615
										SameLine() -- 1616
										local opened -- 1617
										if (filterText ~= nil) then -- 1617
											opened = showTest -- 1617
										else -- 1617
											opened = false -- 1617
										end -- 1617
										if game.testOpen == nil then -- 1618
											game.testOpen = opened -- 1618
										end -- 1618
										SetNextItemOpen(game.testOpen) -- 1619
										TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1620
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1621
												Columns(maxColumns, false) -- 1622
												for _index_1 = 1, #tests do -- 1623
													local test = tests[_index_1] -- 1623
													local entryName = test.entryName -- 1624
													if not allEntries.match(entryName) then -- 1625
														goto _continue_0 -- 1625
													end -- 1625
													PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1626
														if Button(entryName, Vec2(-1, 40)) then -- 1627
															enterDemoEntry(test) -- 1628
														end -- 1627
														return NextColumn() -- 1629
													end) -- 1626
													opened = true -- 1630
													::_continue_0:: -- 1624
												end -- 1623
											end) -- 1621
										end) -- 1620
										game.testOpen = opened -- 1631
									end -- 1612
								end -- 1608
								if showSep then -- 1632
									Columns(1, false) -- 1633
									allEntries.thinSep() -- 1634
									Columns(columns, false) -- 1635
								end -- 1632
							end -- 1535
						end -- 1531
						if #doraTools > 0 then -- 1636
							local showTool = false -- 1637
							for _index_0 = 1, #doraTools do -- 1638
								local _des_0 = doraTools[_index_0] -- 1638
								local entryName, repo = _des_0.entryName, _des_0.repo -- 1638
								local displayName -- 1639
								if repo then -- 1639
									if zh then -- 1640
										displayName = repo.title.zh -- 1640
									else -- 1640
										displayName = repo.title.en -- 1640
									end -- 1640
								end -- 1639
								if displayName == nil then -- 1641
									displayName = entryName -- 1641
								end -- 1641
								if allEntries.match(displayName) then -- 1642
									showTool = true -- 1642
									break -- 1642
								end -- 1642
							end -- 1638
							if not showTool then -- 1643
								goto endEntry -- 1643
							end -- 1643
							Columns(1, false) -- 1644
							TextColored(themeColor, "Dora SSR:") -- 1645
							SameLine() -- 1646
							Text(zh and "开发支持" or "Development Support") -- 1647
							Separator() -- 1648
							if #doraTools > 0 then -- 1649
								local opened -- 1650
								if (filterText ~= nil) then -- 1650
									opened = showTool -- 1650
								else -- 1650
									opened = false -- 1650
								end -- 1650
								SetNextItemOpen(toolOpen) -- 1651
								TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1652
									return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1653
										Columns(maxColumns, false) -- 1654
										for _index_0 = 1, #doraTools do -- 1655
											local tool = doraTools[_index_0] -- 1655
											local entryName, repo = tool.entryName, tool.repo -- 1656
											local displayName -- 1657
											if repo then -- 1657
												if zh then -- 1658
													displayName = repo.title.zh -- 1658
												else -- 1658
													displayName = repo.title.en -- 1658
												end -- 1658
											end -- 1657
											if displayName == nil then -- 1659
												displayName = entryName -- 1659
											end -- 1659
											if not allEntries.match(displayName) then -- 1660
												goto _continue_0 -- 1660
											end -- 1660
											if Button(displayName, Vec2(-1, 40)) then -- 1661
												enterDemoEntry(tool) -- 1662
											end -- 1661
											NextColumn() -- 1663
											::_continue_0:: -- 1656
										end -- 1655
										Columns(1, false) -- 1664
										opened = true -- 1665
									end) -- 1653
								end) -- 1652
								toolOpen = opened -- 1666
							end -- 1649
						end -- 1636
						::endEntry:: -- 1667
						if not allEntries.anyEntryMatched then -- 1668
							SetNextWindowBgAlpha(0) -- 1669
							SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1670
							Begin("Entries Not Found", displayWindowFlags, function() -- 1671
								Separator() -- 1672
								TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1673
								TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1674
								return Separator() -- 1675
							end) -- 1671
						end -- 1668
						Columns(1, false) -- 1676
						Dummy(Vec2(100, 80)) -- 1677
						return ScrollWhenDraggingOnVoid() -- 1678
					end) -- 1524
				end) -- 1523
			end) -- 1522
		end) -- 1521
	end -- 1520
end) -- 1437
if not (App.platform == "Emscripten") then -- 1683
	local sceneModuleCache = moduleCache -- 1684
	moduleCache = { } -- 1685
	webStatus = oldRequire("Script.Dev.WebServer") -- 1686
	moduleCache = sceneModuleCache -- 1687
end -- 1683
local _anon_func_7 = function(saved) -- 1710
	local _val_0 = saved.kind -- 1710
	return "local" == _val_0 or "discover" == _val_0 -- 1710
end -- 1710
local _anon_func_8 = function(saved) -- 1714
	local _val_0 = saved.activeTab -- 1714
	return "local" == _val_0 or "discover" == _val_0 -- 1714
end -- 1714
startMobileUI = function() -- 1689
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1690
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1691
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1692
	local getMobileFeedResources -- 1693
	do -- 1693
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1693
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1693
	end -- 1693
	local loadCachedCatalog -- 1694
	do -- 1694
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1694
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1694
	end -- 1694
	local getResourceInstallPath -- 1695
	do -- 1695
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1695
		getResourceInstallPath = _obj_0.getResourceInstallPath -- 1695
	end -- 1695
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1696
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1697
	local feedOptions = nil -- 1698
	local mobileLaunchErrors = { } -- 1699
	local withMobileLaunchErrors -- 1700
	withMobileLaunchErrors = function(items) -- 1700
		for _index_0 = 1, #items do -- 1701
			local item = items[_index_0] -- 1701
			item.launchError = mobileLaunchErrors[item.id] -- 1702
		end -- 1701
		return items -- 1703
	end -- 1700
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1704
	local loadRememberedMobileFeedState -- 1705
	loadRememberedMobileFeedState = function() -- 1705
		local raw = rememberedMobileFeedData -- 1706
		if not (type(raw) == "string" and raw ~= "") then -- 1707
			return -- 1707
		end -- 1707
		local ok, saved = pcall(json.decode, raw) -- 1708
		if not (ok and type(saved) == "table") then -- 1709
			return -- 1709
		end -- 1709
		if type(saved.id) == "string" and _anon_func_7(saved) then -- 1710
			local state = { -- 1711
				activeTab = saved.kind -- 1711
			} -- 1711
			state[saved.kind] = saved -- 1712
			return state -- 1713
		end -- 1710
		local state = { -- 1714
			activeTab = _anon_func_8(saved) and saved.activeTab or "local" -- 1714
		} -- 1714
		local _list_0 = { -- 1715
			"local", -- 1715
			"discover" -- 1715
		} -- 1715
		for _index_0 = 1, #_list_0 do -- 1715
			local kind = _list_0[_index_0] -- 1715
			local entry = saved[kind] -- 1716
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1717
				state[kind] = entry -- 1717
			end -- 1717
		end -- 1715
		return state -- 1718
	end -- 1705
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1719
		activeTab = "local" -- 1719
	} -- 1719
	local rememberMobileFeedEntry -- 1720
	rememberMobileFeedEntry = function(entry) -- 1720
		rememberedMobileFeedState.activeTab = entry.kind -- 1721
		rememberedMobileFeedState[entry.kind] = { -- 1723
			id = entry.id, -- 1723
			kind = entry.kind, -- 1724
			workDir = entry.workDir, -- 1725
			fileName = entry.fileName -- 1726
		} -- 1722
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1728
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1729
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1730
			rememberedMobileFeedData -- 1730
		}) -- 1730
	end -- 1720
	local restartMobileFeed -- 1731
	restartMobileFeed = function(entry) -- 1731
		if feedHost then -- 1732
			feedHost:removeFromParent(true) -- 1732
		end -- 1732
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1733
		local initialEntries = { } -- 1734
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1735
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1736
		feedOptions.initialEntries = initialEntries -- 1737
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1738
	end -- 1731
	local startMobilePlay -- 1739
	startMobilePlay = function(entry) -- 1739
		if HttpServer.wsConnectionCount > 0 then -- 1740
			return -- 1740
		end -- 1740
		local originFeed = feedHost -- 1741
		if remixHost then -- 1742
			remixHost:removeFromParent(true) -- 1742
		end -- 1742
		remixHost = nil -- 1743
		mobileLaunchErrors[entry.id] = nil -- 1744
		entry.launchError = nil -- 1745
		local playActive = true -- 1746
		local restoreMobileFeed -- 1747
		restoreMobileFeed = function() -- 1747
			if not playActive then -- 1748
				return -- 1748
			end -- 1748
			playActive = false -- 1749
			allClear() -- 1750
			isInEntry = true -- 1751
			currentEntry = nil -- 1752
			return restartMobileFeed(entry) -- 1753
		end -- 1747
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1755
			onExit = function() -- 1755
				return restoreMobileFeed() -- 1755
			end, -- 1755
			onRuntimeError = function() -- 1756
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1757
				return restoreMobileFeed() -- 1758
			end -- 1756
		})) -- 1754
		return thread(function() -- 1760
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1764
			if not playActive then -- 1765
				return -- 1765
			end -- 1765
			if success then -- 1766
				if originFeed and originFeed.parent then -- 1767
					originFeed.visible = false -- 1767
				end -- 1767
				return -- 1768
			end -- 1766
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1769
			return restoreMobileFeed() -- 1770
		end) -- 1760
	end -- 1739
	feedOptions = { -- 1772
		takeReceivedFile = function() -- 1772
			if allEntries.pendingPackagePath then -- 1773
				local path = allEntries.pendingPackagePath -- 1774
				allEntries.pendingPackagePath = nil -- 1775
				return path -- 1776
			end -- 1773
			return App:takeReceivedFile() -- 1777
		end, -- 1772
		onSwitchMode = function() -- 1778
			if HttpServer.wsConnectionCount == 0 then -- 1778
				pendingUIMode = false -- 1778
			end -- 1778
		end, -- 1778
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1779
		getLocalEntries = function(importedProjectPath) -- 1780
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1781
			feedOptions.dirtyProjectPath = nil -- 1782
			return withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1783
		end, -- 1780
		syncDiscover = function(onProgress, onDone, force) -- 1784
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1784
		end, -- 1784
		getDiscoverEntries = function() -- 1785
			local cached = loadCachedCatalog() -- 1786
			if not (cached.success and cached.snapshot) then -- 1787
				return { } -- 1787
			end -- 1787
			local items = { } -- 1788
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1789
			for _index_0 = 1, #_list_0 do -- 1789
				local resource = _list_0[_index_0] -- 1789
				local installed = lifecycle.isMobileResourceReady(resource) -- 1790
				local installPath = getResourceInstallPath(resource.id) -- 1791
				items[#items + 1] = { -- 1793
					id = resource.id, -- 1793
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1794
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1795
					kind = "discover", -- 1796
					bannerFile = resource.bannerPath, -- 1797
					workDir = installed and installPath or nil, -- 1798
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1799
					installed = installed, -- 1800
					resource = resource, -- 1801
					catalogCommit = cached.snapshot.commit, -- 1802
					launchError = mobileLaunchErrors[resource.id] -- 1803
				} -- 1792
			end -- 1789
			return items -- 1805
		end, -- 1785
		prepare = function(entry, repairIncomplete, onProgress, onDone) -- 1806
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1807
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1808
			end), repairIncomplete) -- 1807
		end, -- 1806
		createProject = function(name, language) -- 1810
			local result = projectCreate.createMobileProject(name, language) -- 1811
			if not result.success then -- 1812
				return result -- 1812
			end -- 1812
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1813
			for _index_0 = 1, #_list_0 do -- 1813
				local entry = _list_0[_index_0] -- 1813
				if entry.workDir == result.workDir then -- 1814
					return { -- 1815
						success = true, -- 1815
						entry = entry -- 1815
					} -- 1815
				end -- 1814
			end -- 1813
			return { -- 1816
				success = false, -- 1816
				error = "created-project-not-found" -- 1816
			} -- 1816
		end, -- 1810
		onPlay = function(entry) -- 1817
			return startMobilePlay(entry) -- 1817
		end, -- 1817
		onRemix = function(entry) -- 1818
			if HttpServer.wsConnectionCount > 0 then -- 1819
				return -- 1819
			end -- 1819
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1820
			local originFeed = feedHost -- 1821
			feedHost.visible = false -- 1822
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1824
				entry = entry, -- 1824
				onProjectChanged = function(current) -- 1825
					feedOptions.dirtyProjectPath = current.workDir -- 1825
				end, -- 1825
				onBack = function() -- 1826
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1827
						originFeed:emit("RestoreFeedEntry", entry) -- 1828
						originFeed.visible = true -- 1829
					end -- 1827
				end, -- 1826
				onPlay = function(current) -- 1830
					return startMobilePlay(current) -- 1830
				end -- 1830
			})) -- 1823
		end -- 1818
	} -- 1771
	return restartMobileFeed() -- 1833
end -- 1689
if mobileMode then -- 1835
	applyUIMode(true) -- 1835
end -- 1835
return _module_0 -- 1
