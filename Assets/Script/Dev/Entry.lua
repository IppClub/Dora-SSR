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
local Log <const> = Log -- 11
local tostring <const> = tostring -- 11
local math <const> = math -- 11
local View <const> = View -- 11
local Director <const> = Director -- 11
local Size <const> = Size -- 11
local Vec2 <const> = Vec2 -- 11
local Controller <const> = Controller -- 11
local Color <const> = Color -- 11
local Buffer <const> = Buffer -- 11
local os <const> = os -- 11
local thread <const> = thread -- 11
local sleep <const> = sleep -- 11
local yue <const> = yue -- 11
local SetDefaultFont <const> = SetDefaultFont -- 11
local table <const> = table -- 11
local json <const> = json -- 11
local Cache <const> = Cache -- 11
local Texture2D <const> = Texture2D -- 11
local pairs <const> = pairs -- 11
local string <const> = string -- 11
local print <const> = print -- 11
local xml <const> = xml -- 11
local teal <const> = teal -- 11
local wait <const> = wait -- 11
local HttpServer <const> = HttpServer -- 11
local pcall <const> = pcall -- 11
local tolua <const> = tolua -- 11
local Routine <const> = Routine -- 11
local Entity <const> = Entity -- 11
local Platformer <const> = Platformer -- 11
local Audio <const> = Audio -- 11
local ubox <const> = ubox -- 11
local collectgarbage <const> = collectgarbage -- 11
local Wasm <const> = Wasm -- 11
local once <const> = once -- 11
local emit <const> = emit -- 11
local HttpClient <const> = HttpClient -- 11
local Profiler <const> = Profiler -- 11
local xpcall <const> = xpcall -- 11
local debug <const> = debug -- 11
local AlignNode <const> = AlignNode -- 11
local Label <const> = Label -- 11
local ImGui <const> = ImGui -- 11
local setmetatable <const> = setmetatable -- 11
local ipairs <const> = ipairs -- 11
local threadLoop <const> = threadLoop -- 11
local Keyboard <const> = Keyboard -- 11
local coroutine <const> = coroutine -- 11
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
		if not (path == "Script.Dev.AgentHost" or path == "Script.Dev.AgentStoragePanel" or path:match("^Agent[./]")) then -- 24
			moduleCache[#moduleCache + 1] = path -- 25
		end -- 24
		return oldRequire(path) -- 26
	end -- 21
	return loaded -- 27
end -- 19
_G.require = require -- 28
Dora.require = require -- 29
local searchPaths = Content.searchPaths -- 31
local useChinese = (App.locale:match("^zh") ~= nil) -- 33
local updateLocale -- 34
updateLocale = function() -- 34
	useChinese = (App.locale:match("^zh") ~= nil) -- 35
	searchPaths[#searchPaths] = Path(Content.assetPath, "Script", "Lib", "Dora", useChinese and "zh-Hans" or "en") -- 36
	Content.searchPaths = searchPaths -- 37
end -- 34
local isDesktop -- 39
do -- 39
	local _val_0 = App.platform -- 39
	isDesktop = "Windows" == _val_0 or "macOS" == _val_0 or "Linux" == _val_0 -- 39
end -- 39
if DB:exist("Config") then -- 41
	do -- 42
		local _exp_0 = DB:query("select value_str from Config where name = 'locale'") -- 42
		local _type_0 = type(_exp_0) -- 43
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 43
		if _tab_0 then -- 43
			local locale -- 43
			do -- 43
				local _obj_0 = _exp_0[1] -- 43
				local _type_1 = type(_obj_0) -- 43
				if "table" == _type_1 or "userdata" == _type_1 then -- 43
					locale = _obj_0[1] -- 43
				end -- 43
			end -- 43
			if locale ~= nil then -- 43
				if App.locale ~= locale then -- 43
					App.locale = locale -- 44
					updateLocale() -- 45
				end -- 43
			end -- 43
		end -- 42
	end -- 42
	if isDesktop then -- 46
		local _exp_0 = DB:query("select value_str from Config where name = 'writablePath'") -- 47
		local _type_0 = type(_exp_0) -- 48
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 48
		if _tab_0 then -- 48
			local writablePath -- 48
			do -- 48
				local _obj_0 = _exp_0[1] -- 48
				local _type_1 = type(_obj_0) -- 48
				if "table" == _type_1 or "userdata" == _type_1 then -- 48
					writablePath = _obj_0[1] -- 48
				end -- 48
			end -- 48
			if writablePath ~= nil then -- 48
				if writablePath ~= "" and Content:exist(writablePath) and Content:isdir(writablePath) then -- 49
					Content.writablePath = writablePath -- 50
				else -- 52
					Log("Warning", "saved writable path \"" .. tostring(writablePath) .. "\" is unavailable; using \"" .. tostring(Content.writablePath) .. "\" instead") -- 52
					if not DB:exec("update Config set value_str = ? where name = ?", { -- 53
						Content.writablePath, -- 53
						"writablePath" -- 53
					}) then -- 53
						Log("Warning", "failed to persist the fallback writable path") -- 54
					end -- 53
				end -- 49
			end -- 48
		end -- 47
	end -- 46
end -- 41
local Config = require("Config") -- 56
if App.platform == "Emscripten" then -- 58
	Dora.globals.webProjects = oldRequire("Script.Dev.WebProjects") -- 58
end -- 58
local config = Config("", "fpsLimited", "targetFPS", "fixedFPS", "vsync", "fullScreen", "alwaysOnTop", "virtualGamepadEnabled", "winX", "winY", "winWidth", "winHeight", "themeColor", "locale", "editingInfo", "showStats", "showConsole", "showFooter", "filter", "engineDev", "webProfiler", "drawerWidth", "lastUpdateCheck", "updateNotification", "writablePath", "webIDEConnected", "webIDETourCompleted", "showPreview", "mobileFeed", "mobileFeedCurrentCard", "agentLLMConfigVersion", "mobileRemixLLMConfigId", "mobileLargeText", "webIDEEnabled") -- 60
config:load() -- 96
if not (config.webIDEEnabled ~= nil) then -- 98
	config.webIDEEnabled = true -- 99
end -- 98
App.webIDEEnabled = config.webIDEEnabled -- 100
if not (config.writablePath ~= nil) then -- 102
	config.writablePath = Content.appPath -- 103
end -- 102
if not (config.webIDEConnected ~= nil) then -- 105
	config.webIDEConnected = false -- 106
end -- 105
if (config.fpsLimited ~= nil) then -- 108
	App.fpsLimited = config.fpsLimited -- 109
else -- 111
	config.fpsLimited = App.fpsLimited -- 111
end -- 108
if (config.targetFPS ~= nil) then -- 113
	App.targetFPS = math.floor(config.targetFPS) -- 114
else -- 116
	config.targetFPS = App.targetFPS -- 116
end -- 113
if (config.vsync ~= nil) then -- 118
	View.vsync = config.vsync -- 119
else -- 121
	config.vsync = View.vsync -- 121
end -- 118
if (config.fixedFPS ~= nil) then -- 123
	Director.scheduler.fixedFPS = math.floor(config.fixedFPS) -- 124
else -- 126
	config.fixedFPS = Director.scheduler.fixedFPS -- 126
end -- 123
if not (config.showPreview ~= nil) then -- 128
	config.showPreview = true -- 129
end -- 128
if not (config.mobileFeed ~= nil) then -- 131
	local _val_0 = App.platform -- 132
	config.mobileFeed = "Android" == _val_0 or "iOS" == _val_0 -- 132
end -- 131
if not (config.webIDETourCompleted ~= nil) then -- 134
	config.webIDETourCompleted = false -- 135
end -- 134
local showEntry = true -- 138
isDesktop = false -- 140
if (function() -- 141
	local _val_0 = App.platform -- 141
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 141
end)() then -- 141
	isDesktop = true -- 142
	if config.fullScreen then -- 143
		App.fullScreen = true -- 144
	elseif (config.winWidth ~= nil) and (config.winHeight ~= nil) then -- 145
		local size = Size(config.winWidth, config.winHeight) -- 146
		if App.winSize ~= size then -- 147
			App.winSize = size -- 148
		end -- 147
		local winX, winY -- 149
		do -- 149
			local _obj_0 = App.winPosition -- 149
			winX, winY = _obj_0.x, _obj_0.y -- 149
		end -- 149
		if (config.winX ~= nil) then -- 150
			winX = config.winX -- 151
		else -- 153
			config.winX = -1 -- 153
		end -- 150
		if (config.winY ~= nil) then -- 154
			winY = config.winY -- 155
		else -- 157
			config.winY = -1 -- 157
		end -- 154
		App.winPosition = Vec2(winX, winY) -- 158
	end -- 143
	if (config.alwaysOnTop ~= nil) then -- 159
		App.alwaysOnTop = config.alwaysOnTop -- 160
	else -- 162
		config.alwaysOnTop = false -- 162
	end -- 159
	if (config.virtualGamepadEnabled ~= nil) then -- 163
		Controller.virtualGamepadEnabled = config.virtualGamepadEnabled -- 164
	else -- 166
		config.virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 166
	end -- 163
end -- 141
if (config.themeColor ~= nil) then -- 168
	App.themeColor = Color(config.themeColor) -- 169
else -- 171
	config.themeColor = App.themeColor:toARGB() -- 171
end -- 168
if not (config.locale ~= nil) then -- 173
	config.locale = App.locale -- 174
end -- 173
local showStats = false -- 176
if (config.showStats ~= nil) then -- 177
	showStats = config.showStats -- 178
else -- 180
	config.showStats = showStats -- 180
end -- 177
local showConsole = false -- 182
if (config.showConsole ~= nil) then -- 183
	showConsole = config.showConsole -- 184
else -- 186
	config.showConsole = showConsole -- 186
end -- 183
local showFooter = true -- 188
if (config.showFooter ~= nil) then -- 189
	showFooter = config.showFooter -- 190
else -- 192
	config.showFooter = showFooter -- 192
end -- 189
local setFooterVisible -- 194
setFooterVisible = function(visible) -- 194
	if visible == nil then -- 194
		visible = true -- 194
	end -- 194
	showFooter = visible -- 195
	config.showFooter = showFooter -- 196
end -- 194
_module_0["setFooterVisible"] = setFooterVisible -- 194
local filterBuf = Buffer(20) -- 198
if (config.filter ~= nil) then -- 199
	filterBuf.text = config.filter -- 200
else -- 202
	config.filter = "" -- 202
end -- 199
local engineDev = false -- 204
if (config.engineDev ~= nil) then -- 205
	engineDev = config.engineDev -- 206
else -- 208
	config.engineDev = engineDev -- 208
end -- 205
if (config.webProfiler ~= nil) then -- 210
	Director.profilerSending = config.webProfiler -- 211
else -- 213
	config.webProfiler = true -- 213
	Director.profilerSending = true -- 214
end -- 210
if not (config.drawerWidth ~= nil) then -- 216
	config.drawerWidth = 200 -- 217
end -- 216
_module_0.getConfig = function() -- 219
	return config -- 219
end -- 219
_module_0.getEngineDev = function() -- 220
	if not App.debugging then -- 221
		return false -- 221
	end -- 221
	return config.engineDev -- 222
end -- 220
local _anon_func_0 = function() -- 227
	local _val_0 = App.platform -- 227
	return "Windows" == _val_0 or "Linux" == _val_0 or "macOS" == _val_0 -- 227
end -- 227
_module_0.connectWebIDE = function(embedded) -- 224
	if embedded == nil then -- 224
		embedded = false -- 224
	end -- 224
	if not config.webIDEConnected then -- 225
		config.webIDEConnected = true -- 226
		if not embedded and _anon_func_0() then -- 227
			local ratio = App.winSize.width / App.visualSize.width -- 228
			App.winSize = Size(640 * ratio, 480 * ratio) -- 229
		end -- 227
	end -- 225
end -- 224
local updateSceneCache = moduleCache -- 232
moduleCache = { } -- 233
local updater = oldRequire("Tools.SelfUpdater.Service") -- 234
moduleCache = updateSceneCache -- 235
local updateState = updater.getState() -- 237
updateState.available = config.updateNotification == true -- 238
updater.bindEntryState((function() -- 239
	return updateState -- 239
end), function(state) -- 239
	updateState = state -- 240
	config.updateNotification = state.available -- 241
	if state.checkedAt > 0 and not state.usedCache and state.checkedAt ~= config.lastUpdateCheck then -- 242
		config.lastUpdateCheck = state.checkedAt -- 243
	end -- 242
end) -- 239
_module_0.getUpdateState = function() -- 244
	return updateState -- 244
end -- 244
local checkForUpdates -- 245
checkForUpdates = function(manual, source) -- 245
	if manual == nil then -- 245
		manual = true -- 245
	end -- 245
	if source == nil then -- 245
		source = nil -- 245
	end -- 245
	if not manual then -- 246
		if App.platform == "Emscripten" then -- 247
			return false -- 247
		end -- 247
		if (config.lastUpdateCheck ~= nil) and os.difftime(os.time(), config.lastUpdateCheck) < 7 * 24 * 60 * 60 then -- 248
			return false -- 249
		end -- 248
	end -- 246
	return updater.checkForUpdates(source) -- 250
end -- 245
_module_0["checkForUpdates"] = checkForUpdates -- 245
thread(function() -- 251
	sleep(2) -- 252
	return checkForUpdates(false) -- 253
end) -- 251
local Set, Struct, LintYueGlobals -- 255
do -- 255
	local _obj_0 = require("Utils") -- 255
	Set, Struct, LintYueGlobals = _obj_0.Set, _obj_0.Struct, _obj_0.LintYueGlobals -- 255
end -- 255
local yueext = yue.options.extension -- 256
SetDefaultFont("sarasa-mono-sc-regular", 20) -- 258
local building = false -- 260
local getAllFiles -- 262
getAllFiles = function(path, exts, recursive) -- 262
	if recursive == nil then -- 262
		recursive = true -- 262
	end -- 262
	local filters = Set(exts) -- 263
	local files -- 264
	if recursive then -- 264
		files = Content:getAllFiles(path) -- 265
	else -- 267
		files = Content:getFiles(path) -- 267
	end -- 264
	local _accum_0 = { } -- 268
	local _len_0 = 1 -- 268
	for _index_0 = 1, #files do -- 268
		local file = files[_index_0] -- 268
		if not filters[Path:getExt(file)] then -- 269
			goto _continue_0 -- 269
		end -- 269
		_accum_0[_len_0] = file -- 270
		_len_0 = _len_0 + 1 -- 269
		::_continue_0:: -- 269
	end -- 268
	return _accum_0 -- 268
end -- 262
_module_0["getAllFiles"] = getAllFiles -- 262
local getFileEntries -- 272
getFileEntries = function(path, recursive, excludeFiles) -- 272
	if recursive == nil then -- 272
		recursive = true -- 272
	end -- 272
	if excludeFiles == nil then -- 272
		excludeFiles = nil -- 272
	end -- 272
	local entries = { } -- 273
	local excludes -- 274
	if excludeFiles then -- 274
		excludes = Set(excludeFiles) -- 275
	end -- 274
	local _list_0 = getAllFiles(path, { -- 276
		"lua", -- 276
		"xml", -- 276
		yueext, -- 276
		"tl" -- 276
	}, recursive) -- 276
	for _index_0 = 1, #_list_0 do -- 276
		local file = _list_0[_index_0] -- 276
		local entryName = Path:getName(file) -- 277
		if excludes and excludes[entryName] then -- 278
			goto _continue_0 -- 279
		end -- 278
		local fileName = Path:replaceExt(file, "") -- 280
		fileName = Path(path, fileName) -- 281
		local entryAdded -- 282
		for _index_1 = 1, #entries do -- 282
			local _des_0 = entries[_index_1] -- 282
			local ename, efile = _des_0.entryName, _des_0.fileName -- 282
			if entryName == ename and efile == fileName then -- 283
				entryAdded = true -- 283
				break -- 283
			end -- 283
		end -- 282
		if entryAdded then -- 284
			goto _continue_0 -- 284
		end -- 284
		local entry = { -- 285
			entryName = entryName, -- 285
			fileName = fileName -- 285
		} -- 285
		entries[#entries + 1] = entry -- 286
		::_continue_0:: -- 277
	end -- 276
	table.sort(entries, function(a, b) -- 287
		return a.entryName < b.entryName -- 287
	end) -- 287
	return entries -- 288
end -- 272
local allEntries = { -- 290
	dirty = { }, -- 290
	hasDirty = false, -- 290
	runId = 0 -- 290
} -- 290
allEntries.scanDir = function(path, dir, noPreview) -- 292
	if noPreview == nil then -- 292
		noPreview = false -- 292
	end -- 292
	local entries = { } -- 293
	if not dir:match("^%.") then -- 294
		local _list_0 = getAllFiles(Path(path, dir), { -- 295
			"lua", -- 295
			"xml", -- 295
			yueext, -- 295
			"tl", -- 295
			"wasm" -- 295
		}) -- 295
		for _index_0 = 1, #_list_0 do -- 295
			local file = _list_0[_index_0] -- 295
			if "init" == Path:getName(file):lower() then -- 296
				local fileName = Path:replaceExt(file, "") -- 297
				fileName = Path(path, dir, fileName) -- 298
				local projectPath = Path:getPath(fileName) -- 299
				local repoFile = Path(projectPath, ".dora", "repo.json") -- 300
				local repo = nil -- 301
				if Content:exist(repoFile) then -- 302
					local str = Content:load(repoFile) -- 303
					if str then -- 303
						repo = json.decode(str) -- 304
					end -- 303
				end -- 302
				local entryName = Path:getName(projectPath) -- 305
				local entryAdded -- 306
				for _index_1 = 1, #entries do -- 306
					local _des_0 = entries[_index_1] -- 306
					local ename, efile = _des_0.entryName, _des_0.fileName -- 306
					if entryName == ename and efile == fileName then -- 307
						entryAdded = true -- 307
						break -- 307
					end -- 307
				end -- 306
				if entryAdded then -- 308
					goto _continue_0 -- 308
				end -- 308
				local examples = { } -- 309
				local tests = { } -- 310
				local examplePath = Path(path, dir, Path:getPath(file), "Example") -- 311
				if Content:exist(examplePath) then -- 312
					local _list_1 = getFileEntries(examplePath) -- 313
					for _index_1 = 1, #_list_1 do -- 313
						local _des_0 = _list_1[_index_1] -- 313
						local name, ePath = _des_0.entryName, _des_0.fileName -- 313
						local entry = { -- 315
							entryName = name, -- 315
							fileName = Path(path, dir, Path:getPath(file), ePath), -- 316
							workDir = projectPath -- 317
						} -- 314
						examples[#examples + 1] = entry -- 319
					end -- 313
				end -- 312
				local testPath = Path(path, dir, Path:getPath(file), "Test") -- 320
				if Content:exist(testPath) then -- 321
					local _list_1 = getFileEntries(testPath) -- 322
					for _index_1 = 1, #_list_1 do -- 322
						local _des_0 = _list_1[_index_1] -- 322
						local name, tPath = _des_0.entryName, _des_0.fileName -- 322
						local entry = { -- 324
							entryName = name, -- 324
							fileName = Path(path, dir, Path:getPath(file), tPath), -- 325
							workDir = projectPath -- 326
						} -- 323
						tests[#tests + 1] = entry -- 328
					end -- 322
				end -- 321
				local entry = { -- 329
					entryName = entryName, -- 329
					fileName = fileName, -- 329
					projectPath = projectPath, -- 329
					examples = examples, -- 329
					tests = tests, -- 329
					repo = repo -- 329
				} -- 329
				local bannerFile -- 330
				do -- 330
					local _val_0 -- 330
					repeat -- 330
						if noPreview then -- 331
							_val_0 = nil -- 331
							break -- 331
						end -- 331
						if not config.showPreview then -- 332
							_val_0 = nil -- 332
							break -- 332
						end -- 332
						local f = Path(projectPath, ".dora", "banner.jpg") -- 333
						if Content:exist(f) then -- 334
							_val_0 = f -- 334
							break -- 334
						end -- 334
						f = Path(projectPath, ".dora", "banner.png") -- 335
						if Content:exist(f) then -- 336
							_val_0 = f -- 336
							break -- 336
						end -- 336
						f = Path(projectPath, "Image", "banner.jpg") -- 337
						if Content:exist(f) then -- 338
							_val_0 = f -- 338
							break -- 338
						end -- 338
						f = Path(projectPath, "Image", "banner.png") -- 339
						if Content:exist(f) then -- 340
							_val_0 = f -- 340
							break -- 340
						end -- 340
						f = Path(Content.assetPath, "Image", "banner.jpg") -- 341
						if Content:exist(f) then -- 342
							_val_0 = f -- 342
							break -- 342
						end -- 342
					until true -- 330
					bannerFile = _val_0 -- 330
				end -- 330
				if bannerFile then -- 344
					entry.bannerFile = bannerFile -- 347
					thread(function() -- 348
						if Cache:loadAsync(bannerFile) then -- 349
							local bannerTex = Texture2D(bannerFile) -- 350
							if bannerTex then -- 350
								entry.bannerTex = bannerTex -- 351
							end -- 350
						end -- 349
					end) -- 348
				end -- 344
				entries[#entries + 1] = entry -- 352
			end -- 296
			::_continue_0:: -- 296
		end -- 295
	end -- 294
	return entries -- 353
end -- 292
local getProjectEntries -- 355
getProjectEntries = function(path, noPreview) -- 355
	if noPreview == nil then -- 355
		noPreview = false -- 355
	end -- 355
	local entries = { } -- 356
	local _list_0 = Content:getDirs(path) -- 357
	for _index_0 = 1, #_list_0 do -- 357
		local dir = _list_0[_index_0] -- 357
		local _list_1 = allEntries.scanDir(path, dir, noPreview) -- 358
		for _index_1 = 1, #_list_1 do -- 358
			local entry = _list_1[_index_1] -- 358
			entries[#entries + 1] = entry -- 359
		end -- 358
	end -- 357
	table.sort(entries, function(a, b) -- 360
		return a.entryName < b.entryName -- 360
	end) -- 360
	return entries -- 361
end -- 355
_module_0["getProjectEntries"] = getProjectEntries -- 355
local gamesInDev -- 363
local doraTools -- 364
local isToolEntry -- 366
isToolEntry = function(entry) -- 366
	do -- 367
		local _type_0 = type(entry) -- 367
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 367
		if _tab_0 then -- 367
			local categories -- 367
			do -- 367
				local _obj_0 = entry.repo -- 367
				local _type_1 = type(_obj_0) -- 367
				if "table" == _type_1 or "userdata" == _type_1 then -- 367
					categories = _obj_0.categories -- 367
				end -- 367
			end -- 367
			if categories ~= nil then -- 367
				for _index_0 = 1, #categories do -- 368
					local category = categories[_index_0] -- 368
					if "string" == type(category) and category:lower() == "tool" then -- 369
						return true -- 370
					end -- 369
				end -- 368
			end -- 367
		end -- 367
	end -- 367
	return false -- 366
end -- 366
local getEntryTitle -- 372
getEntryTitle = function(entry) -- 372
	local title -- 373
	do -- 373
		local repo = entry.repo -- 373
		if repo then -- 373
			if repo.title and "table" == type(repo.title) then -- 374
				if useChinese then -- 375
					title = repo.title.zh -- 375
				else -- 375
					title = repo.title.en -- 375
				end -- 375
			end -- 374
		end -- 373
	end -- 373
	if title ~= nil then -- 376
		return title -- 376
	else -- 376
		return entry.entryName -- 376
	end -- 376
end -- 372
allEntries.rebuildEntries = function() -- 378
	gamesInDev = { } -- 379
	do -- 380
		local _accum_0 = { } -- 380
		local _len_0 = 1 -- 380
		local _list_0 = allEntries.builtinTools -- 380
		for _index_0 = 1, #_list_0 do -- 380
			local tool = _list_0[_index_0] -- 380
			_accum_0[_len_0] = tool -- 380
			_len_0 = _len_0 + 1 -- 380
		end -- 380
		doraTools = _accum_0 -- 380
	end -- 380
	local _list_0 = allEntries.projectEntries -- 381
	for _index_0 = 1, #_list_0 do -- 381
		local entry = _list_0[_index_0] -- 381
		if isToolEntry(entry) then -- 382
			entry.kind = "tool" -- 383
			doraTools[#doraTools + 1] = entry -- 384
		else -- 386
			entry.kind = "game" -- 386
			gamesInDev[#gamesInDev + 1] = entry -- 387
		end -- 382
	end -- 381
	for i = #allEntries, 1, -1 do -- 388
		allEntries[i] = nil -- 389
	end -- 388
	for _index_0 = 1, #gamesInDev do -- 390
		local game = gamesInDev[_index_0] -- 390
		allEntries[#allEntries + 1] = game -- 391
		local examples, tests = game.examples, game.tests -- 392
		for _index_1 = 1, #examples do -- 393
			local example = examples[_index_1] -- 393
			allEntries[#allEntries + 1] = example -- 394
		end -- 393
		for _index_1 = 1, #tests do -- 395
			local test = tests[_index_1] -- 395
			allEntries[#allEntries + 1] = test -- 396
		end -- 395
	end -- 390
end -- 378
local updateEntries -- 398
updateEntries = function() -- 398
	allEntries.projectEntries = getProjectEntries(Content.writablePath) -- 399
	allEntries.builtinTools = getFileEntries(Path(Content.assetPath, "Script", "Tools"), false) -- 400
	local _list_0 = allEntries.builtinTools -- 401
	for _index_0 = 1, #_list_0 do -- 401
		local tool = _list_0[_index_0] -- 401
		tool.kind = "tool" -- 402
		tool.builtin = true -- 403
	end -- 401
	return allEntries.rebuildEntries() -- 404
end -- 398
allEntries.refreshDirtyProjects = function() -- 406
	if not allEntries.hasDirty then -- 407
		return -- 407
	end -- 407
	local dirty = allEntries.dirty -- 408
	allEntries.dirty = { } -- 409
	allEntries.hasDirty = false -- 410
	for projectPath in pairs(dirty) do -- 411
		do -- 412
			local _accum_0 = { } -- 412
			local _len_0 = 1 -- 412
			local _list_0 = allEntries.projectEntries -- 412
			for _index_0 = 1, #_list_0 do -- 412
				local entry = _list_0[_index_0] -- 412
				if entry.projectPath ~= projectPath then -- 412
					_accum_0[_len_0] = entry -- 412
					_len_0 = _len_0 + 1 -- 412
				end -- 412
			end -- 412
			allEntries.projectEntries = _accum_0 -- 412
		end -- 412
		local parentPath = Path:getPath(projectPath) -- 413
		local dir = Path:getFilename(projectPath) -- 414
		local _list_0 = allEntries.scanDir(parentPath, dir) -- 415
		for _index_0 = 1, #_list_0 do -- 415
			local entry = _list_0[_index_0] -- 415
			if entry.projectPath == projectPath then -- 416
				do -- 417
					local _obj_0 = allEntries.projectEntries -- 417
					_obj_0[#_obj_0 + 1] = entry -- 417
				end -- 417
				break -- 418
			end -- 416
		end -- 415
	end -- 411
	table.sort(allEntries.projectEntries, function(a, b) -- 419
		return a.entryName < b.entryName -- 419
	end) -- 419
	return allEntries.rebuildEntries() -- 420
end -- 406
updateEntries() -- 422
local getLaunchEntries -- 424
getLaunchEntries = function(refresh) -- 424
	if refresh == nil then -- 424
		refresh = false -- 424
	end -- 424
	if refresh then -- 425
		updateEntries() -- 425
	end -- 425
	local toInfo -- 426
	toInfo = function(entry, kind) -- 426
		local file = entry.fileName -- 427
		local asProj = not entry.builtin -- 428
		return { -- 430
			name = getEntryTitle(entry), -- 430
			file = file, -- 431
			kind = kind, -- 432
			asProj = asProj -- 433
		} -- 429
	end -- 426
	local games -- 435
	do -- 435
		local _accum_0 = { } -- 435
		local _len_0 = 1 -- 435
		for _index_0 = 1, #gamesInDev do -- 435
			local game = gamesInDev[_index_0] -- 435
			_accum_0[_len_0] = toInfo(game, "game") -- 435
			_len_0 = _len_0 + 1 -- 435
		end -- 435
		games = _accum_0 -- 435
	end -- 435
	local tools -- 436
	do -- 436
		local _accum_0 = { } -- 436
		local _len_0 = 1 -- 436
		for _index_0 = 1, #doraTools do -- 436
			local tool = doraTools[_index_0] -- 436
			_accum_0[_len_0] = toInfo(tool, "tool") -- 436
			_len_0 = _len_0 + 1 -- 436
		end -- 436
		tools = _accum_0 -- 436
	end -- 436
	return { -- 437
		games = games, -- 437
		tools = tools -- 437
	} -- 437
end -- 424
_module_0["getLaunchEntries"] = getLaunchEntries -- 424
local _anon_func_1 = function(entry, useChinese) -- 454
	local _obj_0 = entry.repo -- 454
	if _obj_0 ~= nil then -- 454
		local _obj_1 = _obj_0.description -- 454
		if _obj_1 ~= nil then -- 454
			return _obj_1[useChinese and "zh" or "en"] -- 454
		end -- 454
		return nil -- 454
	end -- 454
	return nil -- 454
end -- 454
local getMobileFeedEntries -- 439
getMobileFeedEntries = function(refresh, dirtyProjectPath) -- 439
	if refresh == nil then -- 439
		refresh = false -- 439
	end -- 439
	if dirtyProjectPath == nil then -- 439
		dirtyProjectPath = nil -- 439
	end -- 439
	if dirtyProjectPath and dirtyProjectPath ~= "" then -- 440
		allEntries.dirty[dirtyProjectPath] = true -- 441
		allEntries.hasDirty = true -- 442
	end -- 440
	if refresh then -- 443
		allEntries.dirty = { } -- 444
		allEntries.hasDirty = false -- 445
		updateEntries() -- 446
	else -- 448
		allEntries.refreshDirtyProjects() -- 448
	end -- 443
	local items = { } -- 449
	for _index_0 = 1, #gamesInDev do -- 450
		local entry = gamesInDev[_index_0] -- 450
		items[#items + 1] = { -- 452
			id = entry.entryName, -- 452
			title = getEntryTitle(entry), -- 453
			description = _anon_func_1(entry, useChinese) or (useChinese and "本地 Dora 游戏作品" or "Local Dora game"), -- 454
			fileName = entry.fileName, -- 455
			workDir = Path:getPath(entry.fileName), -- 456
			bannerFile = entry.bannerFile, -- 457
			kind = "local" -- 458
		} -- 451
	end -- 450
	return items -- 460
end -- 439
_module_0["getMobileFeedEntries"] = getMobileFeedEntries -- 439
local doCompile -- 462
doCompile = function(minify) -- 462
	if building then -- 463
		return -- 463
	end -- 463
	building = true -- 464
	local startTime = App.runningTime -- 465
	local luaFiles = { } -- 466
	local yueFiles = { } -- 467
	local xmlFiles = { } -- 468
	local tlFiles = { } -- 469
	local writablePath = Content.writablePath -- 470
	local buildPaths = { -- 472
		{ -- 473
			Content.assetPath, -- 473
			Path(writablePath, ".build"), -- 474
			"" -- 475
		} -- 472
	} -- 471
	for _index_0 = 1, #gamesInDev do -- 478
		local _des_0 = gamesInDev[_index_0] -- 478
		local fileName = _des_0.fileName -- 478
		local gamePath = Path:getPath(Path:getRelative(fileName, writablePath)) -- 479
		buildPaths[#buildPaths + 1] = { -- 481
			Path(writablePath, gamePath), -- 481
			Path(writablePath, ".build", gamePath), -- 482
			Path(writablePath, gamePath, "Script", "?.lua") .. ";" .. Path(writablePath, gamePath, "?.lua"), -- 483
			gamePath -- 484
		} -- 480
	end -- 478
	for _index_0 = 1, #buildPaths do -- 485
		local _des_0 = buildPaths[_index_0] -- 485
		local inputPath, outputPath, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 485
		if not Content:exist(inputPath) then -- 486
			goto _continue_0 -- 486
		end -- 486
		local _list_0 = getAllFiles(inputPath, { -- 488
			"lua" -- 488
		}) -- 488
		for _index_1 = 1, #_list_0 do -- 488
			local file = _list_0[_index_1] -- 488
			luaFiles[#luaFiles + 1] = { -- 490
				file, -- 490
				Path(inputPath, file), -- 491
				Path(outputPath, file), -- 492
				gamePath -- 493
			} -- 489
		end -- 488
		local _list_1 = getAllFiles(inputPath, { -- 495
			yueext -- 495
		}) -- 495
		for _index_1 = 1, #_list_1 do -- 495
			local file = _list_1[_index_1] -- 495
			yueFiles[#yueFiles + 1] = { -- 497
				file, -- 497
				Path(inputPath, file), -- 498
				Path(outputPath, Path:replaceExt(file, "lua")), -- 499
				searchPath, -- 500
				gamePath -- 501
			} -- 496
		end -- 495
		local _list_2 = getAllFiles(inputPath, { -- 503
			"xml" -- 503
		}) -- 503
		for _index_1 = 1, #_list_2 do -- 503
			local file = _list_2[_index_1] -- 503
			xmlFiles[#xmlFiles + 1] = { -- 505
				file, -- 505
				Path(inputPath, file), -- 506
				Path(outputPath, Path:replaceExt(file, "lua")), -- 507
				gamePath -- 508
			} -- 504
		end -- 503
		local _list_3 = getAllFiles(inputPath, { -- 510
			"tl" -- 510
		}) -- 510
		for _index_1 = 1, #_list_3 do -- 510
			local file = _list_3[_index_1] -- 510
			if not file:match(".*%.d%.tl$") then -- 511
				tlFiles[#tlFiles + 1] = { -- 513
					file, -- 513
					Path(inputPath, file), -- 514
					Path(outputPath, Path:replaceExt(file, "lua")), -- 515
					searchPath, -- 516
					gamePath -- 517
				} -- 512
			end -- 511
		end -- 510
		::_continue_0:: -- 486
	end -- 485
	local paths -- 519
	do -- 519
		local _tbl_0 = { } -- 519
		local _list_0 = { -- 520
			luaFiles, -- 520
			yueFiles, -- 520
			xmlFiles, -- 520
			tlFiles -- 520
		} -- 520
		for _index_0 = 1, #_list_0 do -- 520
			local files = _list_0[_index_0] -- 520
			for _index_1 = 1, #files do -- 521
				local file = files[_index_1] -- 521
				_tbl_0[Path:getPath(file[3])] = true -- 519
			end -- 519
		end -- 519
		paths = _tbl_0 -- 519
	end -- 519
	for path in pairs(paths) do -- 523
		Content:mkdir(path) -- 523
	end -- 523
	local totalFiles = #yueFiles + #xmlFiles + #tlFiles -- 525
	local fileCount = 0 -- 526
	local errors = { } -- 527
	for _index_0 = 1, #yueFiles do -- 528
		local _des_0 = yueFiles[_index_0] -- 528
		local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 528
		local filename -- 529
		if gamePath then -- 529
			filename = Path(gamePath, file) -- 529
		else -- 529
			filename = file -- 529
		end -- 529
		yue.compile(input, output, searchPath, function(codes, err, globals) -- 530
			if not codes then -- 531
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 532
				return -- 533
			end -- 531
			local success, result = LintYueGlobals(codes, globals) -- 534
			local yueCodes -- 535
			if not success then -- 536
				yueCodes = Content:load(input) -- 537
				if yueCodes then -- 537
					local CheckTIC80Code -- 538
					do -- 538
						local _obj_0 = require("Utils") -- 538
						CheckTIC80Code = _obj_0.CheckTIC80Code -- 538
					end -- 538
					local isTIC80, tic80APIs = CheckTIC80Code(yueCodes) -- 539
					if isTIC80 then -- 540
						success, result = LintYueGlobals(codes, globals, true, tic80APIs) -- 541
					end -- 540
				end -- 537
			end -- 536
			if success then -- 542
				return "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 543
			else -- 545
				if yueCodes then -- 545
					local globalErrors = { } -- 546
					for _index_1 = 1, #result do -- 547
						local _des_1 = result[_index_1] -- 547
						local name, line, col = _des_1[1], _des_1[2], _des_1[3] -- 547
						local countLine = 1 -- 548
						local code = "" -- 549
						for lineCode in yueCodes:gmatch("([^\r\n]*)\r?\n?") do -- 550
							if countLine == line then -- 551
								code = lineCode -- 552
								break -- 553
							end -- 551
							countLine = countLine + 1 -- 554
						end -- 550
						globalErrors[#globalErrors + 1] = "invalid global variable \"" .. tostring(name) .. "\"\nin \"" .. tostring(filename) .. "\", at line " .. tostring(line) .. ", col " .. tostring(col) .. ".\n" .. tostring(code:gsub("\t", " ") .. '\n' .. string.rep(" ", col - 1) .. "^") -- 555
					end -- 547
					if #globalErrors > 0 then -- 556
						errors[#errors + 1] = table.concat(globalErrors, "\n") -- 556
					end -- 556
				else -- 558
					errors[#errors + 1] = "failed to load file " .. tostring(input) -- 558
				end -- 545
				if #errors == 0 then -- 559
					return codes -- 559
				end -- 559
			end -- 542
		end, function(success) -- 530
			if success then -- 560
				print("Yue compiled: " .. tostring(filename)) -- 560
			end -- 560
			fileCount = fileCount + 1 -- 561
		end) -- 530
	end -- 528
	thread(function() -- 563
		for _index_0 = 1, #xmlFiles do -- 564
			local _des_0 = xmlFiles[_index_0] -- 564
			local file, input, output, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 564
			local filename -- 565
			if gamePath then -- 565
				filename = Path(gamePath, file) -- 565
			else -- 565
				filename = file -- 565
			end -- 565
			local sourceCodes = Content:loadAsync(input) -- 566
			local codes, err = xml.tolua(sourceCodes) -- 567
			if not codes then -- 568
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 569
			else -- 571
				Content:saveAsync(output, "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes)) -- 571
				print("Xml compiled: " .. tostring(filename)) -- 572
			end -- 568
			fileCount = fileCount + 1 -- 573
		end -- 564
	end) -- 563
	thread(function() -- 575
		for _index_0 = 1, #tlFiles do -- 576
			local _des_0 = tlFiles[_index_0] -- 576
			local file, input, output, searchPath, gamePath = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 576
			local filename -- 577
			if gamePath then -- 577
				filename = Path(gamePath, file) -- 577
			else -- 577
				filename = file -- 577
			end -- 577
			local sourceCodes = Content:loadAsync(input) -- 578
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 579
			if not codes then -- 580
				errors[#errors + 1] = "Compile errors in " .. tostring(filename) .. ".\n" .. tostring(err) -- 581
			else -- 583
				Content:saveAsync(output, codes) -- 583
				print("Teal compiled: " .. tostring(filename)) -- 584
			end -- 580
			fileCount = fileCount + 1 -- 585
		end -- 576
	end) -- 575
	return thread(function() -- 587
		wait(function() -- 588
			return fileCount == totalFiles -- 588
		end) -- 588
		if minify then -- 589
			local _list_0 = { -- 590
				yueFiles, -- 590
				xmlFiles, -- 590
				tlFiles -- 590
			} -- 590
			for _index_0 = 1, #_list_0 do -- 590
				local files = _list_0[_index_0] -- 590
				for _index_1 = 1, #files do -- 590
					local file = files[_index_1] -- 590
					local output = Path:replaceExt(file[3], "lua") -- 591
					luaFiles[#luaFiles + 1] = { -- 593
						Path:replaceExt(file[1], "lua"), -- 593
						output, -- 594
						output -- 595
					} -- 592
				end -- 590
			end -- 590
			local FormatMini -- 597
			do -- 597
				local _obj_0 = require("luaminify") -- 597
				FormatMini = _obj_0.FormatMini -- 597
			end -- 597
			for _index_0 = 1, #luaFiles do -- 598
				local _des_0 = luaFiles[_index_0] -- 598
				local file, input, output = _des_0[1], _des_0[2], _des_0[3] -- 598
				if Content:exist(input) then -- 599
					local sourceCodes = Content:loadAsync(input) -- 600
					local res, err = FormatMini(sourceCodes) -- 601
					if res then -- 602
						Content:saveAsync(output, res) -- 603
						print("Minify: " .. tostring(file)) -- 604
					else -- 606
						errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 606
					end -- 602
				else -- 608
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 608
				end -- 599
			end -- 598
			package.loaded["luaminify.FormatMini"] = nil -- 609
			package.loaded["luaminify.ParseLua"] = nil -- 610
			package.loaded["luaminify.Scope"] = nil -- 611
			package.loaded["luaminify.Util"] = nil -- 612
		end -- 589
		local errorMessage = table.concat(errors, "\n") -- 613
		if errorMessage ~= "" then -- 614
			print(errorMessage) -- 614
		end -- 614
		local builtFiles = totalFiles + (minify and #luaFiles or 0) - #errors -- 615
		print(tostring(builtFiles) .. " " .. tostring(builtFiles == 1 and 'file' or 'files') .. " built! Cost " .. tostring(string.format('%.2f', App.runningTime - startTime)) .. "s") -- 616
		print(tostring(#errors) .. " " .. tostring(#errors == 1 and 'file failed' or 'files failed') .. " to build.") -- 617
		Content:clearPathCache() -- 618
		teal.clear() -- 619
		yue.clear() -- 620
		building = false -- 621
	end) -- 587
end -- 462
local doClean -- 623
doClean = function() -- 623
	if building then -- 624
		return -- 624
	end -- 624
	local writablePath = Content.writablePath -- 625
	local targetDir = Path(writablePath, ".build") -- 626
	Content:clearPathCache() -- 627
	if Content:remove(targetDir) then -- 628
		return print("Cleaned: " .. tostring(targetDir)) -- 629
	end -- 628
end -- 623
local screenScale = 2.0 -- 631
local scaleContent = false -- 632
local isInEntry = true -- 633
local currentEntry = nil -- 634
local footerWindow = nil -- 636
local entryWindow = nil -- 637
local testingThread = nil -- 638
local mobileMode = config.mobileFeed -- 639
local pendingUIMode = nil -- 640
local feedHost = nil -- 641
local remixHost = nil -- 642
local startMobileUI = nil -- 643
local webControlled = false -- 644
local mobileHosts = { } -- 645
local suspendedMobileHosts = { } -- 646
local trackMobileHost -- 648
trackMobileHost = function(host) -- 648
	do -- 649
		local _accum_0 = { } -- 649
		local _len_0 = 1 -- 649
		for _index_0 = 1, #mobileHosts do -- 649
			local item = mobileHosts[_index_0] -- 649
			if item.parent then -- 649
				_accum_0[_len_0] = item -- 649
				_len_0 = _len_0 + 1 -- 649
			end -- 649
		end -- 649
		mobileHosts = _accum_0 -- 649
	end -- 649
	mobileHosts[#mobileHosts + 1] = host -- 650
	return host -- 651
end -- 648
local clearMobileUI -- 653
clearMobileUI = function() -- 653
	for _index_0 = 1, #mobileHosts do -- 654
		local host = mobileHosts[_index_0] -- 654
		if host.parent then -- 655
			host:removeFromParent(true) -- 655
		end -- 655
	end -- 654
	mobileHosts = { } -- 656
	suspendedMobileHosts = { } -- 657
	feedHost = nil -- 658
	remixHost = nil -- 659
end -- 653
local syncWebIDEControl -- 661
syncWebIDEControl = function() -- 661
	local connected = HttpServer.wsConnectionCount > 0 -- 662
	if connected then -- 663
		pendingUIMode = nil -- 664
		for _index_0 = 1, #mobileHosts do -- 665
			local host = mobileHosts[_index_0] -- 665
			if not host.parent then -- 666
				goto _continue_0 -- 666
			end -- 666
			if not (suspendedMobileHosts[host] ~= nil) then -- 667
				suspendedMobileHosts[host] = host.visible -- 668
				host:emit("SuspendLocalUI") -- 669
			end -- 667
			host.visible = false -- 670
			::_continue_0:: -- 666
		end -- 665
	elseif webControlled then -- 671
		for host, visible in pairs(suspendedMobileHosts) do -- 672
			if host.parent then -- 673
				host.visible = visible -- 674
				host:emit("ResumeLocalUI") -- 675
			end -- 673
		end -- 672
		suspendedMobileHosts = { } -- 676
	end -- 663
	webControlled = connected -- 677
	return connected -- 678
end -- 661
local getUIMode -- 680
getUIMode = function() -- 680
	return mobileMode and "mobile" or "traditional" -- 680
end -- 680
_module_0["getUIMode"] = getUIMode -- 680
local setUIMode -- 681
setUIMode = function(mode) -- 681
	if not (("mobile" == mode or "traditional" == mode)) then -- 682
		return false -- 682
	end -- 682
	if HttpServer.wsConnectionCount > 0 then -- 683
		return false -- 683
	end -- 683
	if (pendingUIMode ~= nil) or not isInEntry or testingThread then -- 684
		return false -- 684
	end -- 684
	local wantsMobile = mode == "mobile" -- 685
	if wantsMobile == mobileMode then -- 686
		return true -- 686
	end -- 686
	if mobileMode then -- 687
		if not (feedHost and feedHost.visible) then -- 688
			return false -- 688
		end -- 688
		feedHost:emit("SwitchUIMode") -- 690
		return pendingUIMode == false -- 691
	end -- 687
	pendingUIMode = true -- 692
	return true -- 693
end -- 681
_module_0["setUIMode"] = setUIMode -- 681
local applyUIMode -- 695
applyUIMode = function(enabled) -- 695
	if HttpServer.wsConnectionCount > 0 then -- 697
		return false -- 697
	end -- 697
	if enabled then -- 698
		local ok, err = pcall(startMobileUI) -- 699
		if not ok then -- 700
			if feedHost then -- 701
				feedHost:removeFromParent(true) -- 701
			end -- 701
			feedHost = nil -- 702
			mobileMode = false -- 703
			Log("Error", "Failed to start Mobile UI: " .. tostring(err)) -- 704
			return false -- 705
		end -- 700
	else -- 707
		clearMobileUI() -- 707
		updateEntries() -- 708
	end -- 698
	mobileMode = enabled -- 709
	config.mobileFeed = enabled -- 710
	return true -- 711
end -- 695
local setupEventHandlers = nil -- 713
local allClear -- 715
allClear = function() -- 715
	if webControlled or HttpServer.wsConnectionCount > 0 then -- 717
		clearMobileUI() -- 717
	end -- 717
	local systemNodes = { } -- 720
	local preserveSystemNode -- 721
	preserveSystemNode = function(node) -- 721
		if systemNodes[node] then -- 722
			return -- 722
		end -- 722
		systemNodes[node] = true -- 723
		do -- 724
			local clip = tolua.cast(node, "ClipNode") -- 724
			if clip then -- 724
				if clip.stencil then -- 725
					preserveSystemNode(clip.stencil) -- 725
				end -- 725
			end -- 724
		end -- 724
		return node:eachChild(function(child) -- 726
			preserveSystemNode(child) -- 727
			return false -- 728
		end) -- 726
	end -- 721
	for _index_0 = 1, #Routine do -- 729
		local routine = Routine[_index_0] -- 729
		if footerWindow == routine or entryWindow == routine or testingThread == routine then -- 731
			goto _continue_0 -- 732
		else -- 734
			Routine:remove(routine) -- 734
		end -- 730
		::_continue_0:: -- 730
	end -- 729
	for _index_0 = 1, #moduleCache do -- 735
		local module = moduleCache[_index_0] -- 735
		package.loaded[module] = nil -- 736
	end -- 735
	moduleCache = { } -- 737
	Director:cleanup() -- 738
	Entity:clear() -- 739
	Platformer.Data:clear() -- 740
	Platformer.UnitAction:clear() -- 741
	Audio:stopAll(0.2) -- 742
	Struct:clear() -- 743
	View.nearPlaneDistance = 0.1 -- 746
	View.farPlaneDistance = 10000 -- 747
	View.fieldOfView = 45 -- 748
	View.postEffect = nil -- 749
	View.scale = scaleContent and screenScale or 1 -- 750
	Director.clearColor = Color(0xff1a1a1a) -- 751
	teal.clear() -- 752
	yue.clear() -- 753
	preserveSystemNode(Director.systemUI) -- 756
	for _, item in pairs(ubox()) do -- 757
		local node = tolua.cast(item, "Node") -- 758
		if node then -- 758
			if not systemNodes[node] then -- 759
				node:cleanup() -- 759
			end -- 759
		end -- 758
	end -- 757
	collectgarbage() -- 760
	collectgarbage() -- 761
	Wasm:clear() -- 762
	thread(function() -- 763
		sleep() -- 764
		return Cache:removeUnused() -- 765
	end) -- 763
	setupEventHandlers() -- 766
	Content.searchPaths = searchPaths -- 767
	App.idled = true -- 768
end -- 715
_module_0["allClear"] = allClear -- 715
local clearTempFiles -- 770
clearTempFiles = function() -- 770
	local writablePath = Content.writablePath -- 771
	local uploadPath = Path(writablePath, ".upload") -- 772
	if Content:exist(uploadPath) then -- 773
		local _list_0 = Content:getDirs(uploadPath) -- 775
		for _index_0 = 1, #_list_0 do -- 775
			local dir = _list_0[_index_0] -- 775
			if dir ~= "resume" then -- 776
				Content:remove(Path(uploadPath, dir)) -- 776
			end -- 776
		end -- 775
		local _list_1 = Content:getFiles(uploadPath) -- 777
		for _index_0 = 1, #_list_1 do -- 777
			local file = _list_1[_index_0] -- 777
			Content:remove(Path(uploadPath, file)) -- 778
		end -- 777
	end -- 773
	if Content:exist(Path(writablePath, ".download")) then -- 779
		return Content:remove(Path(writablePath, ".download")) -- 779
	end -- 779
end -- 770
local waitForWebStart = true -- 781
thread(function() -- 782
	sleep(2) -- 783
	waitForWebStart = false -- 784
end) -- 782
local reloadDevEntry -- 786
reloadDevEntry = function() -- 786
	return thread(function() -- 786
		waitForWebStart = true -- 787
		doClean() -- 788
		allClear() -- 789
		_G.require = oldRequire -- 790
		Dora.require = oldRequire -- 791
		package.loaded["Script.Dev.Entry"] = nil -- 792
		package.loaded["Script.Dev.WebServer"] = nil -- 793
		return Director.systemScheduler:schedule(function() -- 794
			Routine:clear() -- 795
			oldRequire("Script.Dev.Entry") -- 796
			return true -- 797
		end) -- 794
	end) -- 786
end -- 786
local setWorkspace -- 799
setWorkspace = function(path) -- 799
	clearTempFiles() -- 800
	Content.writablePath = path -- 801
	config.writablePath = Content.writablePath -- 802
	return thread(function() -- 803
		sleep() -- 804
		return reloadDevEntry() -- 805
	end) -- 803
end -- 799
_module_0["setWorkspace"] = setWorkspace -- 799
local quit = false -- 807
local activeSearchId = 0 -- 809
local handleSearchFiles -- 811
handleSearchFiles = function(payload) -- 811
	if not payload then -- 812
		return -- 812
	end -- 812
	local id = payload.id -- 813
	if id == nil then -- 814
		return -- 814
	end -- 814
	activeSearchId = id -- 815
	local path, exts, globs, extensionLevels, pattern = payload.path, payload.exts, payload.globs, payload.extensionLevels, payload.pattern -- 816
	if path == nil then -- 817
		path = "" -- 817
	end -- 817
	if exts == nil then -- 818
		exts = { } -- 818
	end -- 818
	if globs == nil then -- 819
		globs = { } -- 819
	end -- 819
	if extensionLevels == nil then -- 820
		extensionLevels = { } -- 820
	end -- 820
	if pattern == nil then -- 821
		pattern = "" -- 821
	end -- 821
	if pattern == "" then -- 823
		return -- 823
	end -- 823
	local useRegex = payload.useRegex == true -- 824
	local caseSensitive = payload.caseSensitive == true -- 825
	local includeContent = payload.includeContent ~= false -- 826
	local contentWindow = payload.contentWindow or 0 -- 827
	return Director.systemScheduler:schedule(once(function() -- 828
		local stopped = false -- 829
		Content:searchFilesAsync(path, exts, extensionLevels, globs, pattern, useRegex, caseSensitive, includeContent, contentWindow, function(result) -- 830
			if activeSearchId ~= id then -- 831
				stopped = true -- 832
				return true -- 833
			end -- 831
			emit("AppWS", "Send", json.encode({ -- 835
				name = "SearchFilesResult", -- 835
				id = id, -- 835
				result = result -- 835
			})) -- 834
			return false -- 837
		end) -- 830
		return emit("AppWS", "Send", json.encode({ -- 839
			name = "SearchFilesDone", -- 839
			id = id, -- 839
			stopped = stopped -- 839
		})) -- 838
	end)) -- 828
end -- 811
local stop -- 842
stop = function() -- 842
	if isInEntry then -- 843
		return false -- 843
	end -- 843
	allClear() -- 844
	isInEntry = true -- 845
	currentEntry = nil -- 846
	return true -- 847
end -- 842
_module_0["stop"] = stop -- 842
local getCurrentEntryStatus -- 849
getCurrentEntryStatus = function() -- 849
	local entry = currentEntry -- 850
	if not (entry and not isInEntry) then -- 851
		return { -- 851
			success = true, -- 851
			running = false, -- 851
			runId = allEntries.runId -- 851
		} -- 851
	end -- 851
	local status = { -- 853
		success = true, -- 853
		running = true, -- 854
		kind = entry.runKind or "file", -- 855
		runId = allEntries.runId, -- 856
		entryName = entry.entryName, -- 857
		fileName = entry.fileName -- 858
	} -- 852
	if entry.workDir then -- 859
		status.workDir = entry.workDir -- 859
	end -- 859
	if entry.projectRoot then -- 860
		status.projectRoot = entry.projectRoot -- 860
	end -- 860
	return status -- 861
end -- 849
_module_0["getCurrentEntryStatus"] = getCurrentEntryStatus -- 849
local _anon_func_2 = function(_with_0) -- 880
	local _val_0 = App.platform -- 880
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 880
end -- 880
setupEventHandlers = function() -- 863
	local _with_0 = Director.postNode -- 864
	_with_0:onAppEvent(function(eventType) -- 865
		if "Quit" == eventType then -- 866
			quit = true -- 867
			allClear() -- 868
			return clearTempFiles() -- 869
		elseif "Shutdown" == eventType then -- 870
			return stop() -- 871
		end -- 865
	end) -- 865
	_with_0:onAppChange(function(settingName) -- 872
		if "Theme" == settingName then -- 873
			config.themeColor = App.themeColor:toARGB() -- 874
		elseif "Locale" == settingName then -- 875
			config.locale = App.locale -- 876
			updateLocale() -- 877
			return teal.clear(true) -- 878
		elseif "FullScreen" == settingName or "Size" == settingName or "Position" == settingName then -- 879
			if _anon_func_2(_with_0) then -- 880
				if "FullScreen" == settingName then -- 882
					config.fullScreen = App.fullScreen -- 882
				elseif "Position" == settingName then -- 883
					local _obj_0 = App.winPosition -- 883
					config.winX, config.winY = _obj_0.x, _obj_0.y -- 883
				elseif "Size" == settingName then -- 884
					local width, height -- 885
					do -- 885
						local _obj_0 = App.winSize -- 885
						width, height = _obj_0.width, _obj_0.height -- 885
					end -- 885
					config.winWidth = width -- 886
					config.winHeight = height -- 887
				end -- 881
			end -- 880
		end -- 872
	end) -- 872
	_with_0:onAppWS(function(event) -- 888
		if event.type == "Close" then -- 889
			if HttpServer.wsConnectionCount == 0 then -- 890
				updateEntries() -- 891
			end -- 890
			return -- 892
		end -- 889
		if not (event.type == "Receive") then -- 893
			return -- 893
		end -- 893
		local data = json.decode(event.msg) -- 894
		if not data then -- 895
			return -- 895
		end -- 895
		local _exp_0 = data.name -- 896
		if "SearchFiles" == _exp_0 then -- 897
			return handleSearchFiles(data) -- 898
		elseif "SearchFilesStop" == _exp_0 then -- 899
			if data.id == nil or data.id == activeSearchId then -- 900
				activeSearchId = 0 -- 901
			end -- 900
		end -- 896
	end) -- 888
	_with_0:slot("UpdateEntries", function() -- 902
		return updateEntries() -- 902
	end) -- 902
	return _with_0 -- 864
end -- 863
setupEventHandlers() -- 904
clearTempFiles() -- 905
local downloadFile -- 907
downloadFile = function(url, target) -- 907
	return Director.systemScheduler:schedule(once(function() -- 907
		local success = HttpClient:downloadAsync(url, target, 30, function(current, total) -- 908
			if quit then -- 909
				return true -- 909
			end -- 909
			emit("AppWS", "Send", json.encode({ -- 911
				name = "Download", -- 911
				url = url, -- 911
				status = "downloading", -- 911
				progress = current / total -- 912
			})) -- 910
			return false -- 908
		end) -- 908
		return emit("AppWS", "Send", json.encode(success and { -- 915
			name = "Download", -- 915
			url = url, -- 915
			status = "completed", -- 915
			progress = 1.0 -- 916
		} or { -- 918
			name = "Download", -- 918
			url = url, -- 918
			status = "failed", -- 918
			progress = 0.0 -- 919
		})) -- 914
	end)) -- 907
end -- 907
_module_0["downloadFile"] = downloadFile -- 907
local _anon_func_3 = function(file, require, workDir) -- 931
	if workDir == nil then -- 931
		workDir = Path:getPath(file) -- 931
	end -- 931
	Content:insertSearchPath(1, workDir) -- 932
	local scriptPath = Path(workDir, "Script") -- 933
	if Content:exist(scriptPath) then -- 934
		Content:insertSearchPath(1, scriptPath) -- 935
	end -- 934
	local result = require(file) -- 936
	if "function" == type(result) then -- 937
		result() -- 937
	end -- 937
	return nil -- 938
end -- 931
local _anon_func_4 = function(_with_0, err, fontSize, width) -- 967
	local label = Label("sarasa-mono-sc-regular", fontSize) -- 967
	label.alignment = "Left" -- 968
	label.textWidth = width - fontSize -- 969
	label.text = err -- 970
	return label -- 967
end -- 967
local enterEntryAsync -- 922
enterEntryAsync = function(entry) -- 922
	allEntries.runId = allEntries.runId + 1 -- 923
	isInEntry = false -- 924
	App.idled = false -- 925
	emit(Profiler.EventName, "ClearLoader") -- 926
	currentEntry = entry -- 927
	local file, workDir = entry.fileName, entry.workDir -- 928
	sleep() -- 929
	return xpcall(_anon_func_3, function(msg) -- 938
		local err = debug.traceback(msg) -- 940
		Log("Error", err) -- 941
		allClear() -- 942
		local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 943
		local viewWidth, viewHeight -- 944
		do -- 944
			local _obj_0 = View.size -- 944
			viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 944
		end -- 944
		local width, height = viewWidth - 20, viewHeight - 20 -- 945
		local fontSize = math.floor(20 * App.devicePixelRatio) -- 946
		Director.ui:addChild((function() -- 947
			local root = AlignNode() -- 947
			do -- 948
				local _obj_0 = App.bufferSize -- 948
				width, height = _obj_0.width, _obj_0.height -- 948
			end -- 948
			root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 949
			root:onAppChange(function(settingName) -- 950
				if settingName == "Size" then -- 950
					do -- 951
						local _obj_0 = App.bufferSize -- 951
						width, height = _obj_0.width, _obj_0.height -- 951
					end -- 951
					return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 952
				end -- 950
			end) -- 950
			root:addChild((function() -- 953
				local _with_0 = ScrollArea({ -- 954
					width = width, -- 954
					height = height, -- 955
					paddingX = 0, -- 956
					paddingY = 50, -- 957
					viewWidth = height, -- 958
					viewHeight = height -- 959
				}) -- 953
				root:onAlignLayout(function(w, h) -- 961
					_with_0.position = Vec2(w / 2, h / 2) -- 962
					w = w - 20 -- 963
					h = h - 20 -- 964
					_with_0.view.children.first.textWidth = w - fontSize -- 965
					return _with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 966
				end) -- 961
				_with_0.view:addChild(_anon_func_4(_with_0, err, fontSize, width)) -- 967
				return _with_0 -- 953
			end)()) -- 953
			return root -- 947
		end)()) -- 947
		return err -- 971
	end, file, require, workDir) -- 930
end -- 922
_module_0["enterEntryAsync"] = enterEntryAsync -- 922
local enterDemoEntry -- 973
enterDemoEntry = function(entry) -- 973
	return thread(function() -- 973
		return enterEntryAsync(entry) -- 973
	end) -- 973
end -- 973
local reloadCurrentEntry -- 975
reloadCurrentEntry = function() -- 975
	if currentEntry then -- 976
		allClear() -- 977
		return enterDemoEntry(currentEntry) -- 978
	end -- 976
end -- 975
Director.clearColor = Color(0xff1a1a1a) -- 980
local descColor = Color(0xffa1a1a1) -- 981
local extraOperations -- 984
do -- 984
	local BeginDisabled, BeginPopup, BeginPopupModal = ImGui.BeginDisabled, ImGui.BeginPopup, ImGui.BeginPopupModal -- 985
	local BeginTooltip, Button, Checkbox = ImGui.BeginTooltip, ImGui.Button, ImGui.Checkbox -- 986
	local CloseCurrentPopup, IsItemHovered, OpenPopup = ImGui.CloseCurrentPopup, ImGui.IsItemHovered, ImGui.OpenPopup -- 987
	local PushStyleVar, PushTextWrapPos, SameLine = ImGui.PushStyleVar, ImGui.PushTextWrapPos, ImGui.SameLine -- 988
	local Selectable, Separator, SeparatorText = ImGui.Selectable, ImGui.Separator, ImGui.SeparatorText -- 989
	local SetNextWindowPosCenter, SetNextWindowSize, Text = ImGui.SetNextWindowPosCenter, ImGui.SetNextWindowSize, ImGui.Text -- 990
	local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 991
	local renderAgentStorage = require("Script.Dev.AgentStoragePanel") -- 992
	local isOSSLicenseExist = Content:exist("LICENSES") -- 993
	local ossLicenses = nil -- 994
	local ossLicensePopup = tostring(useChinese and '开源协议' or 'OSS Licenses') .. "##ossLicenses" -- 995
	local failedSetFolder = false -- 996
	local statusFlags = { -- 997
		"NoResize", -- 997
		"NoMove", -- 997
		"NoCollapse", -- 997
		"AlwaysAutoResize", -- 997
		"NoSavedSettings" -- 997
	} -- 997
	extraOperations = function() -- 1004
		local zh = useChinese -- 1005
		if isDesktop then -- 1006
			local alwaysOnTop = config.alwaysOnTop -- 1007
			do -- 1008
				local changed -- 1008
				changed, alwaysOnTop = Checkbox(zh and "窗口置顶" or "Always On Top", alwaysOnTop) -- 1008
				if changed then -- 1008
					App.alwaysOnTop = alwaysOnTop -- 1009
					config.alwaysOnTop = alwaysOnTop -- 1010
				end -- 1008
			end -- 1008
			local virtualGamepadEnabled = Controller.virtualGamepadEnabled -- 1011
			do -- 1012
				local changed -- 1012
				changed, virtualGamepadEnabled = Checkbox(zh and "键盘模拟手柄" or "Keyboard as Gamepad", virtualGamepadEnabled) -- 1012
				if changed then -- 1012
					Controller.virtualGamepadEnabled = virtualGamepadEnabled -- 1013
					config.virtualGamepadEnabled = virtualGamepadEnabled -- 1014
				end -- 1012
			end -- 1012
			SameLine() -- 1015
			TextColored(descColor, "(?)") -- 1016
			if IsItemHovered() then -- 1017
				BeginTooltip(function() -- 1018
					return PushTextWrapPos(360, function() -- 1019
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
When enabled, regular key and text input events are suppressed; mapped keys are delivered only as virtual gamepad input.]]) -- 1020
					end) -- 1019
				end) -- 1018
			end -- 1017
		end -- 1006
		local showPreview, webIDETourCompleted = config.showPreview, config.webIDETourCompleted -- 1035
		do -- 1039
			local changed -- 1039
			changed, showPreview = Checkbox(zh and "显示预览图" or "Show Preview", showPreview) -- 1039
			if changed then -- 1039
				config.showPreview = showPreview -- 1040
				updateEntries() -- 1041
				if not showPreview then -- 1042
					thread(function() -- 1043
						collectgarbage() -- 1044
						return Cache:removeUnused("Texture") -- 1045
					end) -- 1043
				end -- 1042
			end -- 1039
		end -- 1039
		if App.platform == "Android" or App.platform == "macOS" or App.platform == "Windows" then -- 1046
			local changed, webIDEEnabled = Checkbox(zh and "内嵌 Web IDE" or "Embedded Web IDE", App.webIDEEnabled) -- 1047
			if changed then -- 1047
				config.webIDEEnabled = webIDEEnabled -- 1048
				App.webIDEEnabled = webIDEEnabled -- 1049
			end -- 1047
		end -- 1046
		do -- 1050
			local themeColor = App.themeColor -- 1051
			local writablePath = config.writablePath -- 1052
			SeparatorText(zh and "工作目录" or "Workspace") -- 1053
			PushTextWrapPos(400, function() -- 1054
				return TextColored(themeColor, writablePath) -- 1055
			end) -- 1054
			if not isDesktop then -- 1056
				goto skipSetting -- 1056
			end -- 1056
			local popupName = tostring(zh and '工作目录错误' or 'Invalid Workspace Path') .. "##failedSetFolder" -- 1057
			if Button(zh and "改变目录" or "Set Folder") then -- 1058
				App:openFileDialog(true, function(path) -- 1059
					if path == "" then -- 1060
						return -- 1060
					end -- 1060
					local relPath = Path:getRelative(Content.assetPath, path) -- 1061
					if "" == relPath or ".." == relPath:sub(1, 2) then -- 1062
						return setWorkspace(path) -- 1063
					else -- 1065
						failedSetFolder = true -- 1065
					end -- 1062
				end) -- 1059
			end -- 1058
			if failedSetFolder then -- 1066
				failedSetFolder = false -- 1067
				OpenPopup(popupName) -- 1068
			end -- 1066
			SetNextWindowPosCenter("Always", Vec2(0.5, 0.5)) -- 1069
			BeginPopupModal(popupName, statusFlags, function() -- 1070
				TextWrapped(zh and "工作目录不能包含引擎内置资源目录" or "Built-in assets path should not be under the workspace path") -- 1071
				if Button(tostring(zh and '确认' or 'Confirm') .. "##closeErrorPopup", Vec2(240, 30)) then -- 1072
					return CloseCurrentPopup() -- 1073
				end -- 1072
			end) -- 1070
			SameLine() -- 1074
			if Button(zh and "使用默认" or "Use Default") then -- 1075
				setWorkspace(Content.appPath) -- 1076
			end -- 1075
			Separator() -- 1077
			::skipSetting:: -- 1078
		end -- 1050
		renderAgentStorage(zh) -- 1079
		if isOSSLicenseExist then -- 1080
			if Button(zh and '开源协议' or 'OSS Licenses') then -- 1081
				if not ossLicenses then -- 1082
					local licenseText = Content:load("LICENSES") -- 1083
					if licenseText then -- 1083
						local GSplit -- 1084
						do -- 1084
							local _obj_0 = require("Utils") -- 1084
							GSplit = _obj_0.GSplit -- 1084
						end -- 1084
						ossLicenses = { } -- 1085
						licenseText = licenseText:gsub("\r\n", "\n") -- 1086
						for license in GSplit(licenseText, "\n--------\n", true) do -- 1087
							local name, text = license:match("[%s\n]*([^\n]*)[\n]*(.*)") -- 1088
							if name then -- 1088
								ossLicenses[#ossLicenses + 1] = { -- 1089
									name, -- 1089
									text -- 1089
								} -- 1089
							end -- 1088
						end -- 1087
					end -- 1083
				end -- 1082
				if ossLicenses then -- 1090
					OpenPopup(ossLicensePopup) -- 1090
				end -- 1090
			end -- 1081
			local width, height, themeColor = App.visualSize.width, App.visualSize.height, App.themeColor -- 1091
			SetNextWindowPosCenter("Appearing", Vec2(0.5, 0.5)) -- 1092
			SetNextWindowSize(Vec2(math.min(width * 0.8, 750), height * 0.8), "Appearing") -- 1093
			PushStyleVar("WindowPadding", Vec2(20, 10), function() -- 1094
				return BeginPopupModal(ossLicensePopup, true, { -- 1097
					"NoSavedSettings" -- 1097
				}, function() -- 1098
					for _index_0 = 1, #ossLicenses do -- 1099
						local _des_0 = ossLicenses[_index_0] -- 1099
						local firstLine, text = _des_0[1], _des_0[2] -- 1099
						local name, license = firstLine:match("(.+): (.+)") -- 1101
						if name then -- 1101
							TextColored(themeColor, name) -- 1102
							SameLine() -- 1103
							TreeNode(tostring(license) .. "##" .. tostring(name), function() -- 1104
								return TextWrapped(text) -- 1104
							end) -- 1104
						end -- 1101
					end -- 1099
				end) -- 1094
			end) -- 1094
		end -- 1080
		if not App.debugging then -- 1107
			return -- 1107
		end -- 1107
		return TreeNode(zh and "开发操作" or "Development", function() -- 1108
			if Button(zh and "脚本编译测试" or "Script Build Test") then -- 1109
				OpenPopup("build") -- 1109
			end -- 1109
			PushStyleVar("WindowPadding", Vec2(10, 10), function() -- 1110
				return BeginPopup("build", function() -- 1110
					if Selectable(zh and "编译" or "Compile") then -- 1111
						doCompile(false) -- 1111
					end -- 1111
					Separator() -- 1112
					if Selectable(zh and "压缩" or "Minify") then -- 1113
						doCompile(true) -- 1113
					end -- 1113
					Separator() -- 1114
					if Selectable(zh and "清理" or "Clean") then -- 1115
						return doClean() -- 1115
					end -- 1115
				end) -- 1110
			end) -- 1110
			if isInEntry then -- 1116
				if waitForWebStart then -- 1117
					BeginDisabled(function() -- 1118
						return Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") -- 1118
					end) -- 1118
				elseif Button(zh and "重载开发程序(Ctrl+Z)" or "Reload Dev Entry(Ctrl+Z)") then -- 1119
					reloadDevEntry() -- 1120
				end -- 1117
			end -- 1116
			do -- 1121
				local changed -- 1121
				changed, scaleContent = Checkbox(string.format("%.1fx " .. tostring(zh and '屏幕缩放' or 'Screen'), screenScale), scaleContent) -- 1121
				if changed then -- 1121
					View.scale = scaleContent and screenScale or 1 -- 1122
				end -- 1121
			end -- 1121
			do -- 1123
				local changed -- 1123
				changed, engineDev = Checkbox(zh and '引擎开发模式' or 'Engine Dev Mode', engineDev) -- 1123
				if changed then -- 1123
					config.engineDev = engineDev -- 1124
				end -- 1123
			end -- 1123
			do -- 1125
				local changed -- 1125
				changed, webIDETourCompleted = Checkbox(zh and "导览已完成" or "User Tour Done", webIDETourCompleted) -- 1125
				if changed then -- 1125
					config.webIDETourCompleted = webIDETourCompleted -- 1126
				end -- 1125
			end -- 1125
			if testingThread then -- 1127
				return BeginDisabled(function() -- 1128
					return Button(zh and "开始自动测试" or "Test automatically") -- 1128
				end) -- 1128
			elseif Button(zh and "开始自动测试" or "Test automatically") then -- 1129
				testingThread = thread(function() -- 1130
					local _ <close> = setmetatable({ }, { -- 1131
						__close = function() -- 1131
							allClear() -- 1132
							testingThread = nil -- 1133
							isInEntry = true -- 1134
							currentEntry = nil -- 1135
							return print("Testing done!") -- 1136
						end -- 1131
					}) -- 1131
					for _, entry in ipairs(allEntries) do -- 1137
						allClear() -- 1138
						print("Start " .. tostring(entry.entryName)) -- 1139
						enterDemoEntry(entry) -- 1140
						sleep(2) -- 1141
						print("Stop " .. tostring(entry.entryName)) -- 1142
					end -- 1137
				end) -- 1130
			end -- 1127
		end) -- 1108
	end -- 1004
end -- 984
local icon = Path("Script", "Dev", "icon_s.png") -- 1144
local iconTex = nil -- 1145
thread(function() -- 1146
	if Cache:loadAsync(icon) then -- 1146
		iconTex = Texture2D(icon) -- 1146
	end -- 1146
end) -- 1146
local webStatus = nil -- 1148
local urlClicked = nil -- 1149
local authCode = string.format("%06d", math.random(0, 999999)) -- 1151
local authCodeTTL = 30.0 -- 1153
_module_0.getAuthCode = function() -- 1154
	return authCode -- 1154
end -- 1154
_module_0.invalidateAuthCode = function() -- 1155
	authCode = string.format("%06d", math.random(0, 999999)) -- 1156
	authCodeTTL = 30.0 -- 1157
end -- 1155
local AuthSession -- 1159
do -- 1159
	local pending = nil -- 1160
	local session = nil -- 1161
	AuthSession = { -- 1163
		beginPending = function(sessionId, confirmCode, expiresAt, ttl) -- 1163
			pending = { -- 1165
				sessionId = sessionId, -- 1165
				confirmCode = confirmCode, -- 1166
				expiresAt = expiresAt, -- 1167
				ttl = ttl, -- 1168
				approved = false -- 1169
			} -- 1164
		end, -- 1163
		getPending = function() -- 1171
			return pending -- 1171
		end, -- 1171
		approvePending = function(sessionId) -- 1173
			if pending and pending.sessionId == sessionId then -- 1174
				pending.approved = true -- 1175
				return true -- 1176
			end -- 1174
			return false -- 1177
		end, -- 1173
		clearPending = function() -- 1179
			pending = nil -- 1179
		end, -- 1179
		setSession = function(sessionId, sessionSecret) -- 1181
			session = { -- 1183
				sessionId = sessionId, -- 1183
				sessionSecret = sessionSecret -- 1184
			} -- 1182
		end, -- 1181
		getSession = function() -- 1186
			return session -- 1186
		end -- 1186
	} -- 1162
end -- 1159
_module_0["AuthSession"] = AuthSession -- 1159
local transparant = Color(0x0) -- 1189
local windowFlags = { -- 1190
	"NoTitleBar", -- 1190
	"NoResize", -- 1190
	"NoMove", -- 1190
	"NoCollapse", -- 1190
	"NoSavedSettings", -- 1190
	"NoFocusOnAppearing", -- 1190
	"NoBringToFrontOnFocus" -- 1190
} -- 1190
local statusFlags = { -- 1199
	"NoTitleBar", -- 1199
	"NoResize", -- 1199
	"NoMove", -- 1199
	"NoCollapse", -- 1199
	"AlwaysAutoResize", -- 1199
	"NoSavedSettings" -- 1199
} -- 1199
local displayWindowFlags = { -- 1207
	"NoDecoration", -- 1207
	"NoSavedSettings", -- 1207
	"NoMove", -- 1207
	"NoScrollWithMouse", -- 1207
	"AlwaysAutoResize", -- 1207
	"NoFocusOnAppearing" -- 1207
} -- 1207
local _anon_func_5 = function(allEntries, currentIndex) -- 1280
	if currentIndex > 1 then -- 1280
		return allEntries[currentIndex - 1] -- 1281
	else -- 1283
		return allEntries[#allEntries] -- 1283
	end -- 1280
end -- 1280
local _anon_func_6 = function(allEntries, currentIndex) -- 1287
	if currentIndex < #allEntries then -- 1287
		return allEntries[currentIndex + 1] -- 1288
	else -- 1290
		return allEntries[1] -- 1290
	end -- 1287
end -- 1287
do -- 1216
	local gamepadInputWindowFlags = { -- 1217
		"NoDecoration", -- 1217
		"NoSavedSettings", -- 1217
		"NoMove", -- 1217
		"NoScrollbar", -- 1217
		"NoScrollWithMouse", -- 1217
		"NoFocusOnAppearing", -- 1217
		"NoBringToFrontOnFocus" -- 1217
	} -- 1217
	local initFooter = true -- 1226
	local gamepadInputFocused = false -- 1227
	footerWindow = threadLoop(function() -- 1228
		local Begin, BeginDisabled, BeginTooltip = ImGui.Begin, ImGui.BeginDisabled, ImGui.BeginTooltip -- 1229
		local Button, Checkbox, ImageButton = ImGui.Button, ImGui.Checkbox, ImGui.ImageButton -- 1230
		local IsItemHovered, PushStyleColor, PushStyleVar = ImGui.IsItemHovered, ImGui.PushStyleColor, ImGui.PushStyleVar -- 1231
		local PushTextWrapPos, SameLine, Separator = ImGui.PushTextWrapPos, ImGui.SameLine, ImGui.Separator -- 1232
		local SetNextWindowBgAlpha, SetNextWindowPos, SetNextWindowSize = ImGui.SetNextWindowBgAlpha, ImGui.SetNextWindowPos, ImGui.SetNextWindowSize -- 1233
		local SetWindowFocus, ShowConsole, ShowStats = ImGui.SetWindowFocus, ImGui.ShowConsole, ImGui.ShowStats -- 1234
		local Text, TextColored = ImGui.Text, ImGui.TextColored -- 1235
		if mobileMode then -- 1236
			return -- 1236
		end -- 1236
		local zh = useChinese -- 1237
		authCodeTTL = math.max(0, authCodeTTL - App.deltaTime) -- 1238
		if authCodeTTL <= 0 then -- 1239
			authCodeTTL = 30.0 -- 1240
			authCode = string.format("%06d", math.random(0, 999999)) -- 1241
		end -- 1239
		if HttpServer.wsConnectionCount > 0 then -- 1242
			return -- 1243
		end -- 1242
		if isInEntry and Keyboard:isKeyDown("Escape") then -- 1244
			if App.platform == "Emscripten" then -- 1245
				stop() -- 1247
			else -- 1249
				allClear() -- 1249
				App.devMode = false -- 1250
				App:shutdown() -- 1251
			end -- 1245
		end -- 1244
		do -- 1252
			local ctrl = Keyboard:isKeyPressed("LCtrl") -- 1253
			if ctrl and Keyboard:isKeyDown("Q") then -- 1254
				stop() -- 1255
			end -- 1254
			if ctrl and Keyboard:isKeyDown("Z") then -- 1256
				reloadCurrentEntry() -- 1257
			end -- 1256
			if ctrl and Keyboard:isKeyDown(",") then -- 1258
				if showFooter then -- 1259
					showStats = not showStats -- 1259
				else -- 1259
					showStats = true -- 1259
				end -- 1259
				showFooter = true -- 1260
				config.showFooter = showFooter -- 1261
				config.showStats = showStats -- 1262
			end -- 1258
			if ctrl and Keyboard:isKeyDown(".") then -- 1263
				if showFooter then -- 1264
					showConsole = not showConsole -- 1264
				else -- 1264
					showConsole = true -- 1264
				end -- 1264
				showFooter = true -- 1265
				config.showFooter = showFooter -- 1266
				config.showConsole = showConsole -- 1267
			end -- 1263
			if ctrl and Keyboard:isKeyDown("/") then -- 1268
				showFooter = not showFooter -- 1269
				config.showFooter = showFooter -- 1270
			end -- 1268
			local left = ctrl and Keyboard:isKeyDown("Left") -- 1271
			local right = ctrl and Keyboard:isKeyDown("Right") -- 1272
			local currentIndex = nil -- 1273
			for i, entry in ipairs(allEntries) do -- 1274
				if currentEntry == entry then -- 1275
					currentIndex = i -- 1276
				end -- 1275
			end -- 1274
			if left then -- 1277
				allClear() -- 1278
				if currentIndex == nil then -- 1279
					currentIndex = #allEntries + 1 -- 1279
				end -- 1279
				enterDemoEntry(_anon_func_5(allEntries, currentIndex)) -- 1280
			end -- 1277
			if right then -- 1284
				allClear() -- 1285
				if currentIndex == nil then -- 1286
					currentIndex = 0 -- 1286
				end -- 1286
				enterDemoEntry(_anon_func_6(allEntries, currentIndex)) -- 1287
			end -- 1284
		end -- 1252
		if not showEntry then -- 1291
			return -- 1291
		end -- 1291
		if isInEntry and not waitForWebStart and Keyboard:isKeyPressed("LCtrl") and Keyboard:isKeyDown("Z") then -- 1293
			reloadDevEntry() -- 1297
		end -- 1293
		if initFooter then -- 1298
			initFooter = false -- 1299
		end -- 1298
		local width, height -- 1301
		do -- 1301
			local _obj_0 = App.visualSize -- 1301
			width, height = _obj_0.width, _obj_0.height -- 1301
		end -- 1301
		if isInEntry then -- 1302
			gamepadInputFocused = false -- 1303
		else -- 1305
			SetNextWindowBgAlpha(0.0) -- 1305
			SetNextWindowSize(Vec2(1, 1), "Always") -- 1306
			SetNextWindowPos(Vec2.zero, "Always") -- 1307
			PushStyleVar("WindowPadding", Vec2.zero, function() -- 1308
				return PushStyleVar("WindowMinSize", Vec2(1, 1), function() -- 1309
					return Begin("DoraGamepadInput", gamepadInputWindowFlags, function() -- 1310
						if not gamepadInputFocused then -- 1311
							SetWindowFocus("DoraGamepadInput") -- 1312
							gamepadInputFocused = true -- 1313
						end -- 1311
					end) -- 1310
				end) -- 1309
			end) -- 1308
		end -- 1302
		if isInEntry or showFooter then -- 1315
			SetNextWindowSize(Vec2(width, 50)) -- 1316
			SetNextWindowPos(Vec2(0, height - 50)) -- 1317
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1318
				return PushStyleVar("WindowRounding", 0, function() -- 1319
					return Begin("Footer", windowFlags, function() -- 1320
						Separator() -- 1321
						if iconTex then -- 1322
							if ImageButton("sideBtn", icon, Vec2(20, 20)) then -- 1323
								showStats = not showStats -- 1324
								config.showStats = showStats -- 1325
							end -- 1323
							SameLine() -- 1326
							if Button(">_", Vec2(30, 30)) then -- 1327
								showConsole = not showConsole -- 1328
								config.showConsole = showConsole -- 1329
							end -- 1327
						end -- 1322
						if isInEntry and updateState.available then -- 1330
							SameLine() -- 1331
							if ImGui.Button(zh and "更新可用" or "Update") then -- 1332
								allClear() -- 1333
								enterDemoEntry({ -- 1335
									entryName = "SelfUpdater", -- 1335
									fileName = Path(Content.assetPath, "Script", "Tools", "SelfUpdater") -- 1336
								}) -- 1334
							end -- 1332
						end -- 1330
						if not isInEntry then -- 1337
							SameLine() -- 1338
							local back = Button(zh and "退出" or "Quit", Vec2(70, 30)) -- 1339
							local currentIndex = nil -- 1340
							for i, entry in ipairs(allEntries) do -- 1341
								if currentEntry == entry then -- 1342
									currentIndex = i -- 1343
								end -- 1342
							end -- 1341
							if currentIndex then -- 1344
								if currentIndex > 1 then -- 1345
									SameLine() -- 1346
									if Button("<<", Vec2(30, 30)) then -- 1347
										allClear() -- 1348
										enterDemoEntry(allEntries[currentIndex - 1]) -- 1349
									end -- 1347
								end -- 1345
								if currentIndex < #allEntries then -- 1350
									SameLine() -- 1351
									if Button(">>", Vec2(30, 30)) then -- 1352
										allClear() -- 1353
										enterDemoEntry(allEntries[currentIndex + 1]) -- 1354
									end -- 1352
								end -- 1350
							end -- 1344
							SameLine() -- 1355
							if Button(zh and "刷新" or "Reload", Vec2(70, 30)) then -- 1356
								reloadCurrentEntry() -- 1357
							end -- 1356
							if back then -- 1358
								allClear() -- 1359
								isInEntry = true -- 1360
								currentEntry = nil -- 1361
							end -- 1358
						end -- 1337
					end) -- 1320
				end) -- 1319
			end) -- 1318
		end -- 1315
		if isInEntry then -- 1363
			local showURL = true -- 1364
			local webIDEWidth -- 1365
			do -- 1365
				local base -- 1366
				if updateState.available then -- 1366
					base = 460 -- 1366
				else -- 1366
					base = 360 -- 1366
				end -- 1366
				local extra = 35 -- 1367
				webIDEWidth = base + extra -- 1368
			end -- 1365
			if width < webIDEWidth then -- 1369
				showURL = false -- 1369
			end -- 1369
			SetNextWindowBgAlpha(0.0) -- 1370
			SetNextWindowPos(Vec2(width, height - 50), "Always", Vec2(1, 0)) -- 1371
			Begin("Web IDE", displayWindowFlags, function() -- 1372
				local pending = AuthSession.getPending() -- 1373
				local hovered = false -- 1374
				if not pending and showURL then -- 1375
					do -- 1376
						local url -- 1376
						if webStatus ~= nil then -- 1376
							url = webStatus.url -- 1376
						end -- 1376
						if url then -- 1376
							if isDesktop and not config.fullScreen then -- 1377
								if urlClicked then -- 1378
									BeginDisabled(function() -- 1379
										return Button(url) -- 1379
									end) -- 1379
								elseif Button(url) then -- 1380
									urlClicked = once(function() -- 1381
										return sleep(5) -- 1381
									end) -- 1381
									App:openURL("http://localhost:8866") -- 1382
								end -- 1378
							else -- 1384
								TextColored(descColor, url) -- 1384
							end -- 1377
						else -- 1386
							TextColored(descColor, zh and '不可用' or 'not available') -- 1386
						end -- 1376
					end -- 1376
					hovered = IsItemHovered() -- 1387
				else -- 1389
					TextColored(descColor, "(?)") -- 1389
					hovered = IsItemHovered() -- 1390
				end -- 1375
				SameLine() -- 1391
				local themeColor = App.themeColor -- 1392
				if pending then -- 1393
					if not pending.approved then -- 1394
						local remaining = math.max(0, pending.expiresAt - os.time()) -- 1395
						local ttl = pending.ttl or 1 -- 1396
						PushStyleColor("Text", themeColor, function() -- 1397
							ImGui.ProgressBar(remaining / ttl, Vec2(40, 30), pending.confirmCode) -- 1398
							hovered = hovered or IsItemHovered() -- 1399
						end) -- 1397
						SameLine() -- 1400
						if Button(zh and "确认" or "Approve", Vec2(70, 30)) then -- 1401
							AuthSession.approvePending(pending.sessionId) -- 1402
						end -- 1401
						if hovered then -- 1403
							return BeginTooltip(function() -- 1404
								return PushTextWrapPos(280, function() -- 1405
									return Text(zh and 'Web IDE 正在等待确认，请核对浏览器中的会话码并点击确认' or 'Web IDE is waiting for confirmation. Match the session code in the browser and click approve.') -- 1406
								end) -- 1405
							end) -- 1404
						end -- 1403
					end -- 1394
				else -- 1408
					PushStyleColor("Text", themeColor, function() -- 1408
						ImGui.ProgressBar(authCodeTTL / 30.0, Vec2(60, 30), authCode) -- 1409
						hovered = hovered or IsItemHovered() -- 1410
					end) -- 1408
					if hovered then -- 1411
						return BeginTooltip(function() -- 1412
							return PushTextWrapPos(280, function() -- 1413
								local url -- 1414
								if webStatus ~= nil then -- 1414
									url = webStatus.url -- 1414
								end -- 1414
								if url then -- 1414
									local address -- 1415
									if showURL then -- 1415
										address = "Web IDE" -- 1415
									else -- 1415
										address = url -- 1415
									end -- 1415
									return Text(zh and "本机同源访问无需认证；其他设备或跨域访问 " .. tostring(address) .. " 时输入后面的 PIN 码（仅用于一次认证）" or "Local same-origin access needs no authentication. For another device or cross-origin access to " .. tostring(address) .. ", enter the one-time PIN below") -- 1416
								else -- 1418
									return Text(zh and 'Web IDE 不可用' or 'Web IDE not available') -- 1418
								end -- 1414
							end) -- 1413
						end) -- 1412
					end -- 1411
				end -- 1393
			end) -- 1372
		end -- 1363
		if not isInEntry then -- 1419
			SetNextWindowSize(Vec2(50, 50)) -- 1420
			SetNextWindowPos(Vec2(width - 50, height - 50)) -- 1421
			PushStyleColor("WindowBg", transparant, function() -- 1422
				return Begin("Show", displayWindowFlags, function() -- 1422
					if width >= 370 then -- 1423
						local changed -- 1424
						changed, showFooter = Checkbox("##dev", showFooter) -- 1424
						if changed then -- 1424
							config.showFooter = showFooter -- 1425
						end -- 1424
					end -- 1423
				end) -- 1422
			end) -- 1422
		end -- 1419
		if isInEntry or showFooter then -- 1427
			if showStats then -- 1428
				PushStyleVar("WindowRounding", 0, function() -- 1429
					SetNextWindowPos(Vec2(0, 0), "Always") -- 1430
					SetNextWindowSize(Vec2(0, height - 50)) -- 1431
					showStats = ShowStats(showStats, statusFlags, extraOperations) -- 1432
					config.showStats = showStats -- 1433
				end) -- 1429
			end -- 1428
			if showConsole then -- 1434
				SetNextWindowPos(Vec2(width - 425, height - 375), "FirstUseEver") -- 1435
				return PushStyleVar("WindowRounding", 6, function() -- 1436
					return ShowConsole() -- 1437
				end) -- 1436
			end -- 1434
		end -- 1427
	end) -- 1228
end -- 1216
do -- 1440
	local MaxWidth <const> = 960 -- 1441
	local toolOpen = false -- 1443
	local filterText = nil -- 1444
	allEntries.anyEntryMatched = false -- 1445
	allEntries.match = function(name) -- 1446
		local res = not filterText or name:lower():match(filterText) -- 1447
		if res then -- 1448
			allEntries.anyEntryMatched = true -- 1448
		end -- 1448
		return res -- 1449
	end -- 1446
	allEntries.thinSep = function() -- 1451
		return ImGui.PushStyleVar("SeparatorTextBorderSize", 1, function() -- 1451
			return ImGui.SeparatorText("") -- 1451
		end) -- 1451
	end -- 1451
	entryWindow = threadLoop(function() -- 1452
		local Begin, Button, Columns = ImGui.Begin, ImGui.Button, ImGui.Columns -- 1453
		local Dummy, GetColumnWidth, Image = ImGui.Dummy, ImGui.GetColumnWidth, ImGui.Image -- 1454
		local InputText, NextColumn, PushID = ImGui.InputText, ImGui.NextColumn, ImGui.PushID -- 1455
		local PushStyleColor, PushStyleVar, SameLine = ImGui.PushStyleColor, ImGui.PushStyleVar, ImGui.SameLine -- 1456
		local ScrollWhenDraggingOnVoid, Separator = ImGui.ScrollWhenDraggingOnVoid, ImGui.Separator -- 1457
		local SetNextItemOpen, SetNextItemWidth, SetNextWindowBgAlpha = ImGui.SetNextItemOpen, ImGui.SetNextItemWidth, ImGui.SetNextWindowBgAlpha -- 1458
		local SetNextWindowPos, SetNextWindowSize, Text = ImGui.SetNextWindowPos, ImGui.SetNextWindowSize, ImGui.Text -- 1459
		local TextColored, TextWrapped, TreeNode = ImGui.TextColored, ImGui.TextWrapped, ImGui.TreeNode -- 1460
		local connected = syncWebIDEControl() -- 1461
		if not connected and not mobileMode and isInEntry and not testingThread then -- 1463
			if not allEntries.pendingPackagePath then -- 1464
				local path = App:takeReceivedFile() -- 1465
				if path ~= "" then -- 1466
					allEntries.pendingPackagePath = path -- 1466
				end -- 1466
			end -- 1464
			if allEntries.pendingPackagePath then -- 1467
				pendingUIMode = true -- 1467
			end -- 1467
		end -- 1463
		if (pendingUIMode ~= nil) then -- 1469
			local nextMode = pendingUIMode -- 1470
			pendingUIMode = nil -- 1471
			applyUIMode(nextMode) -- 1472
		end -- 1469
		if mobileMode and not connected then -- 1473
			if isInEntry and not feedHost then -- 1474
				applyUIMode(true) -- 1474
			end -- 1474
			return -- 1475
		end -- 1473
		if App.fpsLimited ~= config.fpsLimited then -- 1476
			config.fpsLimited = App.fpsLimited -- 1477
		end -- 1476
		if App.targetFPS ~= config.targetFPS then -- 1478
			config.targetFPS = App.targetFPS -- 1479
		end -- 1478
		if View.vsync ~= config.vsync then -- 1480
			config.vsync = View.vsync -- 1481
		end -- 1480
		if Director.scheduler.fixedFPS ~= config.fixedFPS then -- 1482
			config.fixedFPS = Director.scheduler.fixedFPS -- 1483
		end -- 1482
		if Director.profilerSending ~= config.webProfiler then -- 1484
			config.webProfiler = Director.profilerSending -- 1485
		end -- 1484
		if urlClicked then -- 1486
			local _, result = coroutine.resume(urlClicked) -- 1487
			if result then -- 1488
				coroutine.close(urlClicked) -- 1489
				urlClicked = nil -- 1490
			end -- 1488
		end -- 1486
		if not isInEntry then -- 1491
			return -- 1491
		end -- 1491
		local zh = useChinese -- 1492
		local themeColor = App.themeColor -- 1493
		if connected then -- 1494
			local width, height -- 1495
			do -- 1495
				local _obj_0 = App.visualSize -- 1495
				width, height = _obj_0.width, _obj_0.height -- 1495
			end -- 1495
			SetNextWindowBgAlpha(0.5) -- 1496
			SetNextWindowPos(Vec2(width / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1497
			Begin("Web IDE Connected", displayWindowFlags, function() -- 1498
				Separator() -- 1499
				TextColored(themeColor, tostring(zh and 'Web IDE 已连接 ……' or 'Web IDE connected ...')) -- 1500
				if iconTex then -- 1501
					Image(icon, Vec2(24, 24)) -- 1502
					SameLine() -- 1503
				end -- 1501
				local slogon = zh and 'Dora 启动！' or 'Dora Start!' -- 1504
				TextColored(descColor, slogon) -- 1505
				return Separator() -- 1506
			end) -- 1498
			return -- 1507
		end -- 1494
		if not showEntry then -- 1508
			return -- 1508
		end -- 1508
		local fullWidth, height -- 1510
		do -- 1510
			local _obj_0 = App.visualSize -- 1510
			fullWidth, height = _obj_0.width, _obj_0.height -- 1510
		end -- 1510
		local width = math.min(MaxWidth, fullWidth) -- 1511
		local paddingX = math.max(10, fullWidth / 2 - width / 2 - 10) -- 1512
		local maxColumns = math.max(math.floor(width / 200), 1) -- 1513
		SetNextWindowPos(Vec2.zero) -- 1514
		SetNextWindowBgAlpha(0) -- 1515
		SetNextWindowSize(Vec2(fullWidth, 51)) -- 1516
		do -- 1517
			PushStyleVar("WindowPadding", Vec2(10, 0), function() -- 1518
				return Begin("Dora Dev", windowFlags, function() -- 1519
					Dummy(Vec2(fullWidth - 20, 0)) -- 1520
					TextColored(themeColor, "Dora SSR " .. tostring(zh and '开发' or 'Dev')) -- 1521
					SameLine() -- 1522
					if Button(zh and "Go 模式" or "Go Mode") then -- 1523
						setUIMode("mobile") -- 1524
					end -- 1523
					if fullWidth >= 540 then -- 1525
						SameLine() -- 1526
						Dummy(Vec2(fullWidth - 540, 0)) -- 1527
						SameLine() -- 1528
						SetNextItemWidth(zh and -95 or -140) -- 1529
						if InputText(zh and '筛选' or 'Filter', filterBuf, { -- 1530
							"AutoSelectAll" -- 1530
						}) then -- 1530
							config.filter = filterBuf.text -- 1531
						end -- 1530
						SameLine() -- 1532
						if Button(zh and '下载' or 'Download') then -- 1533
							allClear() -- 1534
							enterDemoEntry({ -- 1536
								entryName = "ResourceDownloader", -- 1536
								fileName = Path(Content.assetPath, "Script", "Tools", "ResourceDownloader") -- 1537
							}) -- 1535
						end -- 1533
					end -- 1525
					return Separator() -- 1538
				end) -- 1519
			end) -- 1518
		end -- 1517
		allEntries.anyEntryMatched = false -- 1540
		SetNextWindowPos(Vec2(0, 50)) -- 1541
		SetNextWindowSize(Vec2(fullWidth, height - 100)) -- 1542
		local scrollbarSize <const> = 25 -- 1544
		ImGui.SetNextWindowContentSize(Vec2(math.max(1, fullWidth - paddingX * 2 - scrollbarSize), 0)) -- 1545
		do -- 1546
			return PushStyleColor("WindowBg", transparant, function() -- 1547
				return PushStyleVar("WindowPadding", Vec2(paddingX, 10), function() -- 1548
					return PushStyleVar("ScrollbarSize", scrollbarSize, function() -- 1549
						return PushStyleVar("Alpha", 1, function() -- 1550
							return Begin("Content", windowFlags, function() -- 1551
								local DemoViewWidth <const> = 220 -- 1552
								filterText = filterBuf.text:match("[^%%%.%[]+") -- 1553
								if filterText then -- 1554
									filterText = filterText:lower() -- 1554
								end -- 1554
								if App.platform == "Emscripten" then -- 1555
									Dora.globals.webProjects.draw(zh, themeColor) -- 1556
									allEntries.anyEntryMatched = true -- 1557
								end -- 1555
								if #gamesInDev > 0 then -- 1558
									local columns = math.max(math.floor(width / DemoViewWidth), 1) -- 1559
									Columns(columns, false) -- 1560
									local realViewWidth = GetColumnWidth() - 50 -- 1561
									for _index_0 = 1, #gamesInDev do -- 1562
										local game = gamesInDev[_index_0] -- 1562
										local gameName, fileName, examples, tests, repo, bannerFile, bannerTex = game.entryName, game.fileName, game.examples, game.tests, game.repo, game.bannerFile, game.bannerTex -- 1563
										local displayName -- 1572
										if repo then -- 1572
											if zh then -- 1573
												displayName = repo.title.zh -- 1573
											else -- 1573
												displayName = repo.title.en -- 1573
											end -- 1573
										end -- 1572
										if displayName == nil then -- 1574
											displayName = gameName -- 1574
										end -- 1574
										if allEntries.match(displayName) then -- 1575
											TextColored(themeColor, zh and "项目：" or "Project:") -- 1576
											SameLine() -- 1577
											TextWrapped(displayName) -- 1578
											if columns > 1 then -- 1579
												if bannerFile and bannerTex then -- 1580
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1581
													local displayWidth <const> = realViewWidth -- 1582
													texHeight = displayWidth * texHeight / texWidth -- 1583
													texWidth = displayWidth -- 1584
													Dummy(Vec2.zero) -- 1585
													SameLine() -- 1586
													Image(bannerFile, Vec2(texWidth + 10, texHeight)) -- 1587
												end -- 1580
												if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1588
													enterDemoEntry(game) -- 1589
												end -- 1588
											else -- 1591
												if bannerFile and bannerTex then -- 1591
													local texWidth, texHeight = bannerTex.width, bannerTex.height -- 1592
													local displayWidth = (fullWidth / 2 - paddingX) * 2 - 35 -- 1593
													local sizing = 0.8 -- 1594
													texHeight = displayWidth * sizing * texHeight / texWidth -- 1595
													texWidth = displayWidth * sizing -- 1596
													if texWidth > 500 then -- 1597
														sizing = 0.6 -- 1598
														texHeight = displayWidth * sizing * texHeight / texWidth -- 1599
														texWidth = displayWidth * sizing -- 1600
													end -- 1597
													local padding = displayWidth * (1 - sizing) / 2 - 10 -- 1601
													Dummy(Vec2(padding, 0)) -- 1602
													SameLine() -- 1603
													Image(bannerFile, Vec2(texWidth, texHeight)) -- 1604
												end -- 1591
												if Button(tostring(zh and "开始测试" or "Game Test") .. "##" .. tostring(fileName), Vec2(-1, 40)) then -- 1605
													enterDemoEntry(game) -- 1606
												end -- 1605
											end -- 1579
											if #tests == 0 and #examples == 0 then -- 1607
												allEntries.thinSep() -- 1608
											end -- 1607
											NextColumn() -- 1609
										end -- 1575
										local showSep = false -- 1610
										if #examples > 0 then -- 1611
											local showExample = false -- 1612
											for _index_1 = 1, #examples do -- 1613
												local _des_0 = examples[_index_1] -- 1613
												local entryName = _des_0.entryName -- 1613
												if allEntries.match(entryName) then -- 1614
													showExample = true -- 1614
													break -- 1614
												end -- 1614
											end -- 1613
											if showExample then -- 1615
												showSep = true -- 1616
												Columns(1, false) -- 1617
												TextColored(themeColor, zh and "示例：" or "Example:") -- 1618
												SameLine() -- 1619
												local opened -- 1620
												if (filterText ~= nil) then -- 1620
													opened = showExample -- 1620
												else -- 1620
													opened = false -- 1620
												end -- 1620
												if game.exampleOpen == nil then -- 1621
													game.exampleOpen = opened -- 1621
												end -- 1621
												SetNextItemOpen(game.exampleOpen) -- 1622
												TreeNode(tostring(gameName) .. "##example-" .. tostring(fileName), function() -- 1623
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1624
														Columns(maxColumns, false) -- 1625
														for _index_1 = 1, #examples do -- 1626
															local example = examples[_index_1] -- 1626
															local entryName = example.entryName -- 1627
															if not allEntries.match(entryName) then -- 1628
																goto _continue_0 -- 1628
															end -- 1628
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " example", function() -- 1629
																if Button(entryName, Vec2(-1, 40)) then -- 1630
																	enterDemoEntry(example) -- 1631
																end -- 1630
																return NextColumn() -- 1632
															end) -- 1629
															opened = true -- 1633
															::_continue_0:: -- 1627
														end -- 1626
													end) -- 1624
												end) -- 1623
												game.exampleOpen = opened -- 1634
											end -- 1615
										end -- 1611
										if #tests > 0 then -- 1635
											local showTest = false -- 1636
											for _index_1 = 1, #tests do -- 1637
												local _des_0 = tests[_index_1] -- 1637
												local entryName = _des_0.entryName -- 1637
												if allEntries.match(entryName) then -- 1638
													showTest = true -- 1638
													break -- 1638
												end -- 1638
											end -- 1637
											if showTest then -- 1639
												showSep = true -- 1640
												Columns(1, false) -- 1641
												TextColored(themeColor, zh and "测试：" or "Test:") -- 1642
												SameLine() -- 1643
												local opened -- 1644
												if (filterText ~= nil) then -- 1644
													opened = showTest -- 1644
												else -- 1644
													opened = false -- 1644
												end -- 1644
												if game.testOpen == nil then -- 1645
													game.testOpen = opened -- 1645
												end -- 1645
												SetNextItemOpen(game.testOpen) -- 1646
												TreeNode(tostring(gameName) .. "##test-" .. tostring(fileName), function() -- 1647
													return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1648
														Columns(maxColumns, false) -- 1649
														for _index_1 = 1, #tests do -- 1650
															local test = tests[_index_1] -- 1650
															local entryName = test.entryName -- 1651
															if not allEntries.match(entryName) then -- 1652
																goto _continue_0 -- 1652
															end -- 1652
															PushID(tostring(gameName) .. " " .. tostring(entryName) .. " test", function() -- 1653
																if Button(entryName, Vec2(-1, 40)) then -- 1654
																	enterDemoEntry(test) -- 1655
																end -- 1654
																return NextColumn() -- 1656
															end) -- 1653
															opened = true -- 1657
															::_continue_0:: -- 1651
														end -- 1650
													end) -- 1648
												end) -- 1647
												game.testOpen = opened -- 1658
											end -- 1639
										end -- 1635
										if showSep then -- 1659
											Columns(1, false) -- 1660
											allEntries.thinSep() -- 1661
											Columns(columns, false) -- 1662
										end -- 1659
									end -- 1562
								end -- 1558
								if #doraTools > 0 then -- 1663
									local showTool = false -- 1664
									for _index_0 = 1, #doraTools do -- 1665
										local _des_0 = doraTools[_index_0] -- 1665
										local entryName, repo = _des_0.entryName, _des_0.repo -- 1665
										local displayName -- 1666
										if repo then -- 1666
											if zh then -- 1667
												displayName = repo.title.zh -- 1667
											else -- 1667
												displayName = repo.title.en -- 1667
											end -- 1667
										end -- 1666
										if displayName == nil then -- 1668
											displayName = entryName -- 1668
										end -- 1668
										if allEntries.match(displayName) then -- 1669
											showTool = true -- 1669
											break -- 1669
										end -- 1669
									end -- 1665
									if not showTool then -- 1670
										goto endEntry -- 1670
									end -- 1670
									Columns(1, false) -- 1671
									TextColored(themeColor, "Dora SSR:") -- 1672
									SameLine() -- 1673
									Text(zh and "开发支持" or "Development Support") -- 1674
									Separator() -- 1675
									if #doraTools > 0 then -- 1676
										local opened -- 1677
										if (filterText ~= nil) then -- 1677
											opened = showTool -- 1677
										else -- 1677
											opened = false -- 1677
										end -- 1677
										SetNextItemOpen(toolOpen) -- 1678
										TreeNode(zh and "引擎工具" or "Engine Tools", function() -- 1679
											return PushStyleVar("ItemSpacing", Vec2(20, 10), function() -- 1680
												Columns(maxColumns, false) -- 1681
												for _index_0 = 1, #doraTools do -- 1682
													local tool = doraTools[_index_0] -- 1682
													local entryName, repo = tool.entryName, tool.repo -- 1683
													local displayName -- 1684
													if repo then -- 1684
														if zh then -- 1685
															displayName = repo.title.zh -- 1685
														else -- 1685
															displayName = repo.title.en -- 1685
														end -- 1685
													end -- 1684
													if displayName == nil then -- 1686
														displayName = entryName -- 1686
													end -- 1686
													if not allEntries.match(displayName) then -- 1687
														goto _continue_0 -- 1687
													end -- 1687
													if Button(displayName, Vec2(-1, 40)) then -- 1688
														enterDemoEntry(tool) -- 1689
													end -- 1688
													NextColumn() -- 1690
													::_continue_0:: -- 1683
												end -- 1682
												Columns(1, false) -- 1691
												opened = true -- 1692
											end) -- 1680
										end) -- 1679
										toolOpen = opened -- 1693
									end -- 1676
								end -- 1663
								::endEntry:: -- 1694
								if not allEntries.anyEntryMatched then -- 1695
									SetNextWindowBgAlpha(0) -- 1696
									SetNextWindowPos(Vec2(fullWidth / 2, height / 2), "Always", Vec2(0.5, 0.5)) -- 1697
									Begin("Entries Not Found", displayWindowFlags, function() -- 1698
										Separator() -- 1699
										TextColored(themeColor, zh and "多萝：" or "Dora:") -- 1700
										TextColored(descColor, zh and '别担心，改变一些咒语，我们会找到新的冒险～' or 'Don\'t worry, more magic words and we\'ll find a new adventure!') -- 1701
										return Separator() -- 1702
									end) -- 1698
								end -- 1695
								Columns(1, false) -- 1703
								Dummy(Vec2(100, 80)) -- 1704
								return ScrollWhenDraggingOnVoid() -- 1705
							end) -- 1551
						end) -- 1550
					end) -- 1549
				end) -- 1548
			end) -- 1547
		end -- 1546
	end) -- 1452
end -- 1440
if not (App.platform == "Emscripten") then -- 1710
	local sceneModuleCache = moduleCache -- 1711
	moduleCache = { } -- 1712
	webStatus = oldRequire("Script.Dev.WebServer") -- 1713
	moduleCache = sceneModuleCache -- 1714
	if (App.platform == "Windows" or App.platform == "macOS") and App.webIDEEnabled then -- 1715
		thread(function() -- 1716
			wait(function() -- 1717
				return webStatus.url ~= nil or not App.webIDEEnabled -- 1717
			end) -- 1717
			if App.webIDEEnabled then -- 1718
				return emit("AppWebView", "/ide/show", true) -- 1718
			end -- 1718
		end) -- 1716
	end -- 1715
end -- 1710
local _anon_func_7 = function(saved) -- 1741
	local _val_0 = saved.kind -- 1741
	return "local" == _val_0 or "discover" == _val_0 -- 1741
end -- 1741
local _anon_func_8 = function(saved) -- 1745
	local _val_0 = saved.activeTab -- 1745
	return "local" == _val_0 or "discover" == _val_0 -- 1745
end -- 1745
startMobileUI = function() -- 1720
	local mobileFeed = oldRequire("Script.Dev.Mobile.Feed") -- 1721
	local mobileCatalog = oldRequire("Script.Dev.Mobile.MobileCatalog") -- 1722
	local projectCreate = oldRequire("Script.Dev.Mobile.ProjectCreate") -- 1723
	local getMobileFeedResources -- 1724
	do -- 1724
		local _obj_0 = require("Script.Tools.ResourceDownloader.Catalog") -- 1724
		getMobileFeedResources = _obj_0.getMobileFeedResources -- 1724
	end -- 1724
	local loadCachedCatalog -- 1725
	do -- 1725
		local _obj_0 = require("Script.Tools.ResourceDownloader.CatalogSync") -- 1725
		loadCachedCatalog = _obj_0.loadCachedCatalog -- 1725
	end -- 1725
	local getResourceInstallPath, getInstalledCatalogResource -- 1726
	do -- 1726
		local _obj_0 = require("Script.Tools.ResourceDownloader.GitInstaller") -- 1726
		getResourceInstallPath, getInstalledCatalogResource = _obj_0.getResourceInstallPath, _obj_0.getInstalledCatalogResource -- 1726
	end -- 1726
	local lifecycle = oldRequire("Script.Dev.Mobile.Lifecycle") -- 1727
	local playOverlay = oldRequire("Script.Dev.Mobile.PlayOverlay") -- 1728
	local feedOptions = nil -- 1729
	local mobileLaunchErrors = { } -- 1730
	local withMobileLaunchErrors -- 1731
	withMobileLaunchErrors = function(items) -- 1731
		for _index_0 = 1, #items do -- 1732
			local item = items[_index_0] -- 1732
			item.launchError = mobileLaunchErrors[item.id] -- 1733
		end -- 1732
		return items -- 1734
	end -- 1731
	local rememberedMobileFeedData = config.mobileFeedCurrentCard -- 1735
	local loadRememberedMobileFeedState -- 1736
	loadRememberedMobileFeedState = function() -- 1736
		local raw = rememberedMobileFeedData -- 1737
		if not (type(raw) == "string" and raw ~= "") then -- 1738
			return -- 1738
		end -- 1738
		local ok, saved = pcall(json.decode, raw) -- 1739
		if not (ok and type(saved) == "table") then -- 1740
			return -- 1740
		end -- 1740
		if type(saved.id) == "string" and _anon_func_7(saved) then -- 1741
			local state = { -- 1742
				activeTab = saved.kind -- 1742
			} -- 1742
			state[saved.kind] = saved -- 1743
			return state -- 1744
		end -- 1741
		local state = { -- 1745
			activeTab = _anon_func_8(saved) and saved.activeTab or "local" -- 1745
		} -- 1745
		local _list_0 = { -- 1746
			"local", -- 1746
			"discover" -- 1746
		} -- 1746
		for _index_0 = 1, #_list_0 do -- 1746
			local kind = _list_0[_index_0] -- 1746
			local entry = saved[kind] -- 1747
			if type(entry) == "table" and type(entry.id) == "string" and entry.kind == kind then -- 1748
				state[kind] = entry -- 1748
			end -- 1748
		end -- 1746
		return state -- 1749
	end -- 1736
	local rememberedMobileFeedState = loadRememberedMobileFeedState() or { -- 1750
		activeTab = "local" -- 1750
	} -- 1750
	local rememberMobileFeedEntry -- 1751
	rememberMobileFeedEntry = function(entry) -- 1751
		rememberedMobileFeedState.activeTab = entry.kind -- 1752
		rememberedMobileFeedState[entry.kind] = { -- 1754
			id = entry.id, -- 1754
			kind = entry.kind, -- 1755
			workDir = entry.workDir, -- 1756
			fileName = entry.fileName -- 1757
		} -- 1753
		rememberedMobileFeedData = json.encode(rememberedMobileFeedState) -- 1759
		rawset(config, getmetatable(config).mobileFeedCurrentCard, rememberedMobileFeedData) -- 1760
		return DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileFeedCurrentCard', NULL, ?, NULL)", { -- 1761
			rememberedMobileFeedData -- 1761
		}) -- 1761
	end -- 1751
	local restartMobileFeed -- 1762
	restartMobileFeed = function(entry) -- 1762
		if feedHost then -- 1763
			feedHost:removeFromParent(true) -- 1763
		end -- 1763
		feedOptions.initialEntry = entry or rememberedMobileFeedState[rememberedMobileFeedState.activeTab] -- 1764
		local initialEntries = { } -- 1765
		initialEntries["local"] = rememberedMobileFeedState["local"] -- 1766
		initialEntries["discover"] = rememberedMobileFeedState["discover"] -- 1767
		feedOptions.initialEntries = initialEntries -- 1768
		feedHost = trackMobileHost(mobileFeed.startMobileFeed(feedOptions)) -- 1769
	end -- 1762
	local startMobilePlay -- 1770
	startMobilePlay = function(entry) -- 1770
		if HttpServer.wsConnectionCount > 0 then -- 1771
			return -- 1771
		end -- 1771
		local originFeed = feedHost -- 1772
		if remixHost then -- 1773
			remixHost:removeFromParent(true) -- 1773
		end -- 1773
		remixHost = nil -- 1774
		mobileLaunchErrors[entry.id] = nil -- 1775
		entry.launchError = nil -- 1776
		local playActive = true -- 1777
		local restoreMobileFeed -- 1778
		restoreMobileFeed = function() -- 1778
			if not playActive then -- 1779
				return -- 1779
			end -- 1779
			playActive = false -- 1780
			allClear() -- 1781
			isInEntry = true -- 1782
			currentEntry = nil -- 1783
			return restartMobileFeed(entry) -- 1784
		end -- 1778
		trackMobileHost(playOverlay.startMobilePlayOverlay({ -- 1786
			onExit = function() -- 1786
				return restoreMobileFeed() -- 1786
			end, -- 1786
			onRuntimeError = function() -- 1787
				mobileLaunchErrors[entry.id] = useChinese and "作品运行异常，已安全返回作品卡，请修改后重试。" or "The game stopped after a runtime error. Fix it and try again." -- 1788
				return restoreMobileFeed() -- 1789
			end -- 1787
		})) -- 1785
		return thread(function() -- 1791
			local success, err = enterEntryAsync(lifecycle.resolveMobileLaunchEntry(entry)) -- 1795
			if not playActive then -- 1796
				return -- 1796
			end -- 1796
			if success then -- 1797
				if originFeed and originFeed.parent then -- 1798
					originFeed.visible = false -- 1798
				end -- 1798
				return -- 1799
			end -- 1797
			mobileLaunchErrors[entry.id] = useChinese and "作品启动失败，已返回作品卡，请修改后重试。" or "The game failed to start. Fix it and try again." -- 1800
			return restoreMobileFeed() -- 1801
		end) -- 1791
	end -- 1770
	feedOptions = { -- 1803
		takeReceivedFile = function() -- 1803
			if allEntries.pendingPackagePath then -- 1804
				local path = allEntries.pendingPackagePath -- 1805
				allEntries.pendingPackagePath = nil -- 1806
				return path -- 1807
			end -- 1804
			return App:takeReceivedFile() -- 1808
		end, -- 1803
		onSwitchMode = function() -- 1809
			if HttpServer.wsConnectionCount == 0 then -- 1809
				pendingUIMode = false -- 1809
			end -- 1809
		end, -- 1809
		onCurrentEntryChanged = rememberMobileFeedEntry, -- 1810
		getLocalEntries = function(importedProjectPath) -- 1811
			local dirtyProjectPath = importedProjectPath or feedOptions.dirtyProjectPath -- 1812
			feedOptions.dirtyProjectPath = nil -- 1813
			local items = withMobileLaunchErrors(getMobileFeedEntries(false, dirtyProjectPath)) -- 1814
			local cached = loadCachedCatalog() -- 1815
			if cached.success and cached.snapshot then -- 1816
				for _index_0 = 1, #items do -- 1817
					local entry = items[_index_0] -- 1817
					local resource = getInstalledCatalogResource(entry.workDir, cached.snapshot.catalog.resources) -- 1818
					if resource then -- 1819
						entry.resource = resource -- 1820
						entry.catalogCommit = cached.snapshot.commit -- 1821
					end -- 1819
				end -- 1817
			end -- 1816
			return items -- 1822
		end, -- 1811
		syncDiscover = function(onProgress, onDone, force) -- 1823
			return mobileCatalog.syncMobileCatalog(onProgress, onDone, nil, force) -- 1823
		end, -- 1823
		getDiscoverEntries = function() -- 1824
			local cached = loadCachedCatalog() -- 1825
			if not (cached.success and cached.snapshot) then -- 1826
				return { } -- 1826
			end -- 1826
			local items = { } -- 1827
			local _list_0 = getMobileFeedResources(cached.snapshot.catalog.resources) -- 1828
			for _index_0 = 1, #_list_0 do -- 1828
				local resource = _list_0[_index_0] -- 1828
				local installed = lifecycle.isMobileResourceReady(resource) -- 1829
				local installPath = getResourceInstallPath(resource.id) -- 1830
				items[#items + 1] = { -- 1832
					id = resource.id, -- 1832
					title = resource.title[useChinese and "zh-Hans" or "en"], -- 1833
					description = resource.description[useChinese and "zh-Hans" or "en"], -- 1834
					kind = "discover", -- 1835
					bannerFile = resource.bannerPath, -- 1836
					webPlayUrl = not (resource.runnable and #resource.entrypoints > 0) and resource.playUrl or nil, -- 1837
					sourceUrl = resource.versions[1].sources[1].url, -- 1838
					workDir = installed and installPath or nil, -- 1839
					fileName = installed and Path(installPath, Path:replaceExt(resource.entrypoints[1].path, "")) or nil, -- 1840
					installed = installed, -- 1841
					resource = resource, -- 1842
					catalogCommit = cached.snapshot.commit, -- 1843
					launchError = mobileLaunchErrors[resource.id] -- 1844
				} -- 1831
			end -- 1828
			return items -- 1846
		end, -- 1824
		prepare = function(entry, repairIncomplete, onProgress, onDone, isCanceled) -- 1847
			return lifecycle.prepareMobileResource(entry.resource, entry.catalogCommit, onProgress, (function(result) -- 1848
				return onDone(result.success, result.entry, result.message, result.repairable) -- 1849
			end), repairIncomplete, isCanceled) -- 1848
		end, -- 1847
		sync = function(entry, force, onProgress, onDone, isCanceled) -- 1851
			return lifecycle.syncMobileResource(entry.resource.id, force, onProgress, (function(result) -- 1852
				return onDone(result.success, result.entry, result.message, result.forceable) -- 1853
			end), isCanceled) -- 1852
		end, -- 1851
		createProject = function(name, language) -- 1855
			local result = projectCreate.createMobileProject(name, language) -- 1856
			if not result.success then -- 1857
				return result -- 1857
			end -- 1857
			local _list_0 = getMobileFeedEntries(false, result.workDir) -- 1858
			for _index_0 = 1, #_list_0 do -- 1858
				local entry = _list_0[_index_0] -- 1858
				if entry.workDir == result.workDir then -- 1859
					return { -- 1860
						success = true, -- 1860
						entry = entry -- 1860
					} -- 1860
				end -- 1859
			end -- 1858
			return { -- 1861
				success = false, -- 1861
				error = "created-project-not-found" -- 1861
			} -- 1861
		end, -- 1855
		onPlay = function(entry) -- 1862
			return startMobilePlay(entry) -- 1862
		end, -- 1862
		onRemix = function(entry) -- 1863
			if HttpServer.wsConnectionCount > 0 then -- 1864
				return -- 1864
			end -- 1864
			local remix = oldRequire("Script.Dev.Mobile.Remix") -- 1865
			local originFeed = feedHost -- 1866
			feedHost.visible = false -- 1867
			remixHost = trackMobileHost(remix.startMobileRemix({ -- 1869
				entry = entry, -- 1869
				onProjectChanged = function(current) -- 1870
					feedOptions.dirtyProjectPath = current.workDir -- 1870
				end, -- 1870
				onBack = function() -- 1871
					if mobileMode and feedHost == originFeed and originFeed.parent then -- 1872
						originFeed:emit("RestoreFeedEntry", entry) -- 1873
						originFeed.visible = true -- 1874
					end -- 1872
				end, -- 1871
				onPlay = function(current) -- 1875
					return startMobilePlay(current) -- 1875
				end -- 1875
			})) -- 1868
		end -- 1863
	} -- 1802
	return restartMobileFeed() -- 1878
end -- 1720
if mobileMode then -- 1880
	applyUIMode(true) -- 1880
end -- 1880
return _module_0 -- 1
